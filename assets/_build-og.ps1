Add-Type -AssemblyName System.Drawing

$out = "c:\Projects\Cana Chic Residences\assets\og-image.jpg"

$W = 1200
$H = 630

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Diagonal gradient — noir top-left, champagne-tinted deep noir bottom-right
$gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.PointF(0, 0)),
  (New-Object System.Drawing.PointF($W, $H)),
  [System.Drawing.Color]::FromArgb(255, 11, 11, 12),
  [System.Drawing.Color]::FromArgb(255, 38, 28, 16)
)
$blend = New-Object System.Drawing.Drawing2D.ColorBlend(3)
$blend.Colors = @(
  [System.Drawing.Color]::FromArgb(255, 8, 8, 9),
  [System.Drawing.Color]::FromArgb(255, 22, 18, 14),
  [System.Drawing.Color]::FromArgb(255, 44, 32, 18)
)
$blend.Positions = @(0.0, 0.55, 1.0)
$gradBrush.InterpolationColors = $blend
$g.FillRectangle($gradBrush, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))

# Subtle champagne radial accent at bottom-right
$radialPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$radialPath.AddEllipse(($W - 700), ($H - 400), 1100, 800)
$pgBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($radialPath)
$pgBrush.CenterPoint = New-Object System.Drawing.PointF(($W + 100), ($H + 100))
$pgBrush.CenterColor = [System.Drawing.Color]::FromArgb(70, 201, 162, 106)
$pgBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$g.FillPath($pgBrush, $radialPath)

# Champagne and white brushes
$champagneBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 201, 162, 106))
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 244, 241, 234))

# Text fonts
$middot = [char]0xB7
$uAcute = [char]0xDA
$oAcute = [char]0xD3
$tagText = "SANTIAGO  $middot  REP$($uAcute)BLICA DOMINICANA"
$tagFont = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold)
$titleFont = New-Object System.Drawing.Font("Georgia", 78, [System.Drawing.FontStyle]::Regular)
$subtitleFont = New-Object System.Drawing.Font("Georgia", 34, [System.Drawing.FontStyle]::Italic)

$strFmt = New-Object System.Drawing.StringFormat
$strFmt.Alignment = [System.Drawing.StringAlignment]::Center
$strFmt.LineAlignment = [System.Drawing.StringAlignment]::Center

# Layout: tag, title, subtitle, circle CTA — vertically centered as a group
$tagSize = $g.MeasureString($tagText, $tagFont)
$titleSize = $g.MeasureString("Cana Chic Residences", $titleFont)
$subtitleSize = $g.MeasureString("Avenida Hispanoamericana, Santiago", $subtitleFont)

$ctaDiameter = 76
$gapTagTitle = 22
$gapTitleSub = 12
$gapSubCta = 38

$stackH = $tagSize.Height + $gapTagTitle + $titleSize.Height + $gapTitleSub + $subtitleSize.Height + $gapSubCta + $ctaDiameter
$stackY = ($H - $stackH) / 2

# Tag
$tagRect = New-Object System.Drawing.RectangleF(0, $stackY, $W, $tagSize.Height)
$g.DrawString($tagText, $tagFont, $champagneBrush, $tagRect, $strFmt)

# Title
$titleY = $stackY + $tagSize.Height + $gapTagTitle
$titleRect = New-Object System.Drawing.RectangleF(0, $titleY, $W, $titleSize.Height)
$g.DrawString("Cana Chic Residences", $titleFont, $whiteBrush, $titleRect, $strFmt)

# Subtitle
$subY = $titleY + $titleSize.Height + $gapTitleSub
$subRect = New-Object System.Drawing.RectangleF(0, $subY, $W, $subtitleSize.Height)
$g.DrawString("Avenida Hispanoamericana, Santiago", $subtitleFont, $whiteBrush, $subRect, $strFmt)

# Circle CTA — champagne ring, centered, with arrow inside
$ctaY = [int]($subY + $subtitleSize.Height + $gapSubCta)
$ctaX = [int](($W - $ctaDiameter) / 2)
$ctaPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 201, 162, 106), 2.4)
$g.DrawEllipse($ctaPen, $ctaX, $ctaY, $ctaDiameter, $ctaDiameter)

# Arrow inside the circle — drawn as 3 line segments
$arrowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 201, 162, 106), 2.4)
$arrowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$arrowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$arrowPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

$cx = $ctaX + $ctaDiameter / 2
$cy = $ctaY + $ctaDiameter / 2
$arrowLen = 24
$arrowHeadSize = 9

# Shaft
$g.DrawLine($arrowPen, ($cx - $arrowLen / 2), $cy, ($cx + $arrowLen / 2), $cy)
# Head — two diagonal lines from tip
$tipX = $cx + $arrowLen / 2
$g.DrawLine($arrowPen, $tipX, $cy, ($tipX - $arrowHeadSize), ($cy - $arrowHeadSize))
$g.DrawLine($arrowPen, $tipX, $cy, ($tipX - $arrowHeadSize), ($cy + $arrowHeadSize))

$qualityParam = New-Object System.Drawing.Imaging.EncoderParameters(1)
$qualityParam.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]92)
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$bmp.Save($out, $jpegCodec, $qualityParam)

$g.Dispose()
$bmp.Dispose()

Write-Output "Saved $out (${W}x${H})"
