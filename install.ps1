<#
  一键装齐 DSH 插件（霖栗同款清单）
  =====================================
  这个脚本只做一件事：按清单把插件一个个装进当前 DSH 配置档（profile）。

  一行装完（Windows PowerShell）：
      irm https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1 | iex

  想改参数（profile / 跳过某些插件）就用这行：
      & ([scriptblock]::Create((irm https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1))) -Profile desktop -Skip dsh-pet,dshmarket

  参数：
      -Profile        配置档名，默认取 $env:DSH_PROFILE，否则 desktop
      -Skip           要跳过的插件名（逗号分隔）
      -CoreOnly       只装核心那几个（跳过宠物/挂件/市场/统计这类可选项）
      -DryRun         只打印命令，不真的装

  说明：
      * 本脚本不复制任何插件源码，只调用 `dsh plugin add`，版权归各自作者。
      * 装完要重启 DSH（或刷新面板）才会生效。
      * dsh-at-file 默认跳过：0.6.3 在 DSH 0.2.2-rc.5 上激活失败，等作者修。
#>
[CmdletBinding()]
param(
  [string]$Profile = $(if ($env:DSH_PROFILE) { $env:DSH_PROFILE } else { 'desktop' }),
  [string[]]$Skip = @(),
  [switch]$CoreOnly,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

# 清单：name = 包名；optional = 只有 -CoreOnly 之外才装；skip = 默认跳过
$plugins = @(
  @{ name = 'dsh-soul-md';        optional = $false; skip = $false },
  @{ name = 'dsh-context';        optional = $false; skip = $false },
  @{ name = 'billion-context';    optional = $false; skip = $false },
  @{ name = 'dsh-genui';          optional = $false; skip = $false },
  @{ name = 'dsh-speak-up';       optional = $false; skip = $false },
  @{ name = '@liustack/modlens';  optional = $false; skip = $false },
  @{ name = 'dsh-token-diet';     optional = $true;  skip = $false },
  @{ name = 'dsh-whale-widget';   optional = $true;  skip = $false },
  @{ name = 'dshmarket';          optional = $true;  skip = $false },
  @{ name = 'dsh-pet';            optional = $true;  skip = $false },
  @{ name = 'dsh-at-file';        optional = $true;  skip = $true  }
)

function Resolve-DshCli {
  $cmd = Get-Command dsh -ErrorAction SilentlyContinue
  if ($cmd) { return @{ kind = 'dsh'; path = $cmd.Source } }
  $npx = Get-Command npx -ErrorAction SilentlyContinue
  if ($npx) { return @{ kind = 'npx'; path = $npx.Source } }
  return $null
}

function Invoke-Install($cli, [string]$spec) {
  $dshArgs = @('plugin', '--profile', $Profile, 'add', $spec)
  if ($cli.kind -eq 'dsh') {
    $out = & $cli.path @dshArgs 2>&1
  } else {
    $out = & $cli.path -y '@deepseek-ai/dsh@latest' @dshArgs 2>&1
  }
  $code = $LASTEXITCODE
  foreach ($line in @($out)) {
    Write-Host ('   ' + [string]$line) -ForegroundColor DarkGray
  }
  return $code
}

Write-Host ''
Write-Host 'DSH 插件合集 · 一键安装' -ForegroundColor Cyan
Write-Host ("配置档 profile = {0}" -f $Profile) -ForegroundColor DarkGray

$cli = Resolve-DshCli
if (-not $cli) {
  Write-Host ''
  Write-Host '这台机器上没有 dsh 命令，也没有 npx。' -ForegroundColor Yellow
  Write-Host '两条路，随便挑一条：' -ForegroundColor Yellow
  Write-Host ''
  Write-Host ' A) 用 DSH 桌面端装（最省事）：' -ForegroundColor Cyan
  Write-Host '    打开 DSH →「插件」页 → 安装 → 把这些名字一个一个粘进去：' -ForegroundColor Gray
  ($plugins | Where-Object { -not $_.skip } | ForEach-Object { $_.name }) | ForEach-Object { Write-Host ('       ' + $_) -ForegroundColor Gray }
  Write-Host ''
  Write-Host ' B) 先装 Node.js（>=22）再跑这个脚本：' -ForegroundColor Cyan
  Write-Host '    winget install OpenJS.NodeJS.LTS' -ForegroundColor Gray
  Write-Host '    关掉这个窗口重开，再执行同一行命令。' -ForegroundColor Gray
  Write-Host ''
  Write-Host ('目标配置档目录：{0}\.dsh\profiles\{1}' -f $HOME, $Profile) -ForegroundColor DarkGray
  exit 1
}

Write-Host ("用 {0} 安装：{1}" -f $cli.kind, $cli.path) -ForegroundColor DarkGray

$skipSet = New-Object System.Collections.Generic.HashSet[string]
foreach ($s in $Skip) {
  if ($s -and $s.Trim() -ne '') { [void]$skipSet.Add($s.Trim()) }
}

$done = @()
$failed = @()
$skipped = @()

foreach ($p in $plugins) {
  $name = $p.name
  if ($p.skip -and -not $skipSet.Contains('!' + $name)) { $skipped += $name; continue }
  if ($CoreOnly -and $p.optional) { $skipped += $name; continue }
  if ($skipSet.Contains($name)) { $skipped += $name; continue }

  $line = ('→ {0}' -f $name)
  Write-Host $line -ForegroundColor Cyan
  if ($DryRun) {
    Write-Host ('   [dry-run] dsh plugin --profile {0} add {1}' -f $Profile, $name) -ForegroundColor DarkGray
    $done += $name
    continue
  }
  try {
    $code = Invoke-Install $cli $name
    if ($code -eq 0) {
      Write-Host '   ✓ 装好了' -ForegroundColor Green
      $done += $name
    } else {
      Write-Host ('   ✗ 失败（exit {0}）' -f $code) -ForegroundColor Red
      $failed += $name
    }
  } catch {
    Write-Host ('   ✗ 失败：{0}' -f $_.Exception.Message) -ForegroundColor Red
    $failed += $name
  }
}

Write-Host ''
Write-Host '—— 结果 ——' -ForegroundColor Cyan
Write-Host ('装好 {0} 个：{1}' -f $done.Count, ($done -join ', ')) -ForegroundColor Green
if ($failed.Count -gt 0) { Write-Host ('失败 {0} 个：{1}' -f $failed.Count, ($failed -join ', ')) -ForegroundColor Red }
if ($skipped.Count -gt 0) { Write-Host ('跳过 {0} 个：{1}' -f $skipped.Count, ($skipped -join ', ')) -ForegroundColor DarkGray }

Write-Host ''
Write-Host '接下来：' -ForegroundColor Yellow
Write-Host '  1) 重启 DSH（或刷新面板），让插件加载；'
Write-Host '  2) 打开「插件」页确认它们都是启用状态；'
Write-Host '  3) 人设卡去 插件 → dsh-soul-md 里写，别写在提示词里。'
Write-Host ''
Write-Host '手动重装/补装的完整命令：' -ForegroundColor DarkGray
$manual = ($plugins | Where-Object { -not $_.skip } | ForEach-Object { $_.name }) -join ' '
Write-Host ('  dsh plugin --profile {0} add {1}' -f $Profile, $manual) -ForegroundColor DarkGray
