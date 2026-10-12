# Stop hook: show a Windows toast when Claude finishes a turn.
[Console]::InputEncoding = [Text.Encoding]::UTF8
$name = ''
try {
  $in = [Console]::In.ReadToEnd() | ConvertFrom-Json
  $name = Split-Path -Leaf $in.cwd
  # Session name: /rename title wins over the auto-generated one; fall back to the folder.
  $lines = Select-String -LiteralPath $in.transcript_path -Encoding UTF8 -Pattern '"type":"(custom|ai)-title"' | ForEach-Object { $_.Line | ConvertFrom-Json }
  $custom = $lines | Where-Object customTitle | Select-Object -Last 1
  $ai = $lines | Where-Object aiTitle | Select-Object -Last 1
  if ($custom) { $name = $custom.customTitle } elseif ($ai) { $name = $ai.aiTitle }
} catch {}

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
$xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
$t = $xml.GetElementsByTagName('text')
$t.Item(0).AppendChild($xml.CreateTextNode('Claude Code')) > $null
$t.Item(1).AppendChild($xml.CreateTextNode("Done: $name")) > $null
# AppId of Windows PowerShell, so the toast shows without registering a custom app.
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe').Show([Windows.UI.Notifications.ToastNotification]::new($xml))
