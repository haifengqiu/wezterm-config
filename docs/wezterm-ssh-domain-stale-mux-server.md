# WezTerm SSH 域报「服务器版本是 2024xxx」排查案例

## 环境

| 端 | 系统 | WezTerm 版本 |
|---|---|---|
| 本机 | Windows | 20260705-075440-5cc2d1ef |
| 远程 | Linux 服务器 | 20260716-195552-76b606ec |

本机 `config/ssh.lua` 中配置了 SSH 多路复用域:

```lua
config.ssh_domains = {
  {
    name = 'my-server',
    remote_address = 'example.com:22',
    username = 'your_username',
    timeout = 60,
  },
}
```

## 症状

远程 wezterm 已从 2024 升级到 2026(`wezterm --version` 两边都确认为 2026),
但本机连接该 SSH 域时仍报错:

> Please install the same version of wezterm on both the client and server!
> **The server version is 20240203-xxxxxx (codec version N)**,
> which is not compatible with our version 20260705-075440 (codec version M).

即:报错里报告的「服务器」仍是 2024 版。

## 根因

与 tmux 无关(WezTerm SSH 域不经过 tmux)。WezTerm SSH 域的工作方式:

1. 连接时,本机通过 SSH 在远程执行 `wezterm cli --prefer-mux proxy`
   (源码 [`wezterm-client/src/client.rs`][client-rs] → `Reconnectable::ssh_connect`;
   重连时带 `--no-auto-start`);
2. 该命令附着到远程**常驻的 mux server**(`wezterm-mux-server --daemonize`),
   默认 socket:`$XDG_RUNTIME_DIR/wezterm/sock`,无 XDG 时 `/tmp/wezterm-<用户名>/sock`;
   server 不在跑才会自动拉起新的;
3. 握手按 **codec 版本**(`codec/src/lib.rs` 的 `CODEC_VERSION`)校验,
   不匹配即抛 `IncompatibleVersionError`,就是上面那条报错。

2024 时代连接过,远程残留了一个 `--daemonize` 的 2024 版 `wezterm-mux-server`
进程占着 socket。**升级二进制不会杀掉已在运行的守护进程**,
所以每次重连都附着到旧 server,报 2024 版本不匹配。

## 排查(SSH 到远程执行)

```bash
pgrep -af wezterm-mux-server   # 确认旧进程存在
```

## 修复

```bash
# 1. 杀掉残留的旧 mux server(其上的旧复用会话会丢失,本来也连不上)
pkill -f wezterm-mux-server

# 2. 清理残留 socket / pid 文件
rm -rf "${XDG_RUNTIME_DIR:-/tmp}/wezterm" "/tmp/wezterm-$(id -un)"

# 3. 确认非交互 shell 的 PATH 能解析到新版二进制
#    (SSH exec 走非交互 PATH,新版若只装在 ~/.local/bin 可能找不到)
which -a wezterm && wezterm --version
```

然后在本机 WezTerm 重连该 domain:首次连接会自动用新版二进制拉起新的
mux-server,握手通过,恢复多路复用。

## 注意事项

- **PATH 解析**:若第 3 步 `which wezterm` 指向旧版/找不到,在 domain 配置里显式指定:
  ```lua
  remote_wezterm_path = '/usr/local/bin/wezterm',  -- 新版完整路径
  ```
- **两端 build 不必逐字节一致**:握手只比较 codec 版本,相邻 nightly 通常相同,
  能连上即可。若清理后仍报 `IncompatibleVersionError` 且 server 版本已是 2026,
  说明这两个 build 的 codec 版本不同,把两端对齐到同一 build。
- **预防**:以后升级远程 wezterm 后,若之前用过 SSH 域复用,顺手执行
  `pkill -f wezterm-mux-server`,下次连接自动用新版本重启 server。

## 源码参考(wezterm main 分支)

| 位置 | 作用 |
|---|---|
| [`wezterm-client/src/client.rs`][client-rs] → `ssh_connect` | SSH 域在远程执行 `wezterm cli --prefer-mux proxy` |
| [`wezterm-client/src/client.rs`][client-rs] → `IncompatibleVersionError` | 报错文本本体,按 codec 版本判定 |
| [`codec/src/lib.rs`][codec-rs] → `CODEC_VERSION` | mux 协议兼容性判据(协议变更时递增) |
| [`config/src/unix.rs`][unix-rs] | socket 默认路径 `RUNTIME_DIR/sock`;默认 `wezterm-mux-server --daemonize` |

[client-rs]: https://github.com/wez/wezterm/blob/main/wezterm-client/src/client.rs
[codec-rs]: https://github.com/wez/wezterm/blob/main/codec/src/lib.rs
[unix-rs]: https://github.com/wez/wezterm/blob/main/config/src/unix.rs
