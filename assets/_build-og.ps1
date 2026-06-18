Add-Type -AssemblyName System.Drawing

$src = "c:\Projects\Cana Chic Residences\assets\render-corner.jpg"
$out = "c:\Projects\Cana Chic Residences\assets\og-image.jpg"

$img = [System.Drawing.Image]::FromFile($src)

$W = 1200
$H = 630

$srcW = $img.Width
$srcH = $img.Height
$srcRatio = $srcW / $srcH
$targetRatio = $W / $H

if ($srcRatio -gt $targetRatio) {
  $cropH = $srcH
  $cropW = [int]($srcH * $targetRatio)
  $cropX = [int](($srcW - $cropW) / 2)
  $cropY = 0
} else {
  $cropW = $srcW
  $cropH = [int]($srcW / $targetRatio)
  $cropX = 0
  $cropY = [int](($srcH - $cropH) / 2)
}

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

$srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
$destRect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$g.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

# Heavy uniform dark overlay so centered title reads clearly anywhere over the render
$darkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150, 11, 11, 12))
$g.FillRectangle($darkBrush, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))

# Subtle bottom-weighted vignette for additional depth
$gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.PointF(0, 0)),
  (New-Object System.Drawing.PointF(0, $H)),
  [System.Drawing.Color]::Transparent,
  [System.Drawing.Color]::FromArgb(80, 11, 11, 12)
)
$blend = New-Object System.Drawing.Drawing2D.ColorBlend(3)
$blend.Colors = @(
  [System.Drawing.Color]::FromArgb(60, 11, 11, 12),
  [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
  [System.Drawing.Color]::FromArgb(120, 11, 11, 12)
)
$blend.Positions = @(0.0, 0.5, 1.0)
$gradBrush.InterpolationColors = $blend
$g.FillRectangle($gradBrush, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))

# Brand mark — small uppercase champagne tagline above the title
$middot = [char]0xB7
$uAcute = [char]0xDA
$tagText = "SANTIAGO  $middot  REP$($uAcute)BLICA DOMINICANA"
$tagFont = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold)
$champagneBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 201, 162, 106))

$strFmt = New-Object System.Drawing.StringFormat
$strFmt.Alignment = [System.Drawing.StringAlignment]::Center
$strFmt.LineAlignment = [System.Drawing.StringAlignment]::Center

# Title block — two centered lines
$titleFont = New-Object System.Drawing.Font("Georgia", 82, [System.Drawing.FontStyle]::Regular)
$subtitleFont = New-Object System.Drawing.Font("Georgia", 36, [System.Drawing.FontStyle]::Italic)
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 244, 241, 234))

# CTA setup — measure first so we can include it in the vertical stack
$oAcute = [char]0xD3
$ctaText = "SOLICITA INFORMACI$($oAcute)N  $([char]0x2192)"
$ctaFont = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold)
$ctaSize = $g.MeasureString($ctaText, $ctaFont)
$ctaPadH = 28
$ctaPadV = 16
$ctaW = [int]($ctaSize.Width + $ctaPadH * 2)
$ctaH = [int]($ctaSize.Height + $ctaPadV * 2)

# Layout: tag, title, subtitle, CTA — vertically centered as a group
$tagSize = $g.MeasureString($tagText, $tagFont)
$titleSize = $g.MeasureString("Cana Chic Residences", $titleFont)
$subtitleSize = $g.MeasureString("Avenida Hispanoamericana, Santiago", $subtitleFont)

$gapTagTitle = 24
$gapTitleSub = 14
$gapSubCta = 36
$stackH = $tagSize.Height + $gapTagTitle + $titleSize.Height + $gapTitleSub + $subtitleSize.Height + $gapSubCta + $ctaH
$stackY = ($H - $stackH) / 2

# Draw tag
$tagRect = New-Object System.Drawing.RectangleF(0, $stackY, $W, $tagSize.Height)
$g.DrawString($tagText, $tagFont, $champagneBrush, $tagRect, $strFmt)

# Draw title
$titleY = $stackY + $tagSize.Height + $gapTagTitle
$titleRect = New-Object System.Drawing.RectangleF(0, $titleY, $W, $titleSize.Height)
$g.DrawString("Cana Chic Residences", $titleFont, $whiteBrush, $titleRect, $strFmt)

# Draw subtitle
$subY = $titleY + $titleSize.Height + $gapTitleSub
$subRect = New-Object System.Drawing.RectangleF(0, $subY, $W, $subtitleSize.Height)
$g.DrawString("Avenida Hispanoamericana, Santiago", $subtitleFont, $whiteBrush, $subRect, $strFmt)

# Draw CTA pill — centered
$ctaY = [int]($subY + $subtitleSize.Height + $gapSubCta)
$ctaX = [int](($W - $ctaW) / 2)
$pillPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$pillPath.AddRectangle((New-Object System.Drawing.Rectangle($ctaX, $ctaY, $ctaW, $ctaH)))
$pillPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 201, 162, 106), 2)
$g.DrawPath($pillPen, $pillPath)
$g.DrawString($ctaText, $ctaFont, $champagneBrush, ($ctaX + $ctaPadH), ($ctaY + $ctaPadV))

$qualityParam = New-Object System.Drawing.Imaging.EncoderParameters(1)
$qualityParam.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]88)
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$bmp.Save($out, $jpegCodec, $qualityParam)

$g.Dispose()
$bmp.Dispose()
$img.Dispose()

Write-Output "Saved $out (${W}x${H})"
