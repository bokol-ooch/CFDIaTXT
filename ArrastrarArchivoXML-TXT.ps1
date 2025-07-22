Add-Type -AssemblyName 'System.Windows.Forms'
Add-Type -AssemblyName 'System.Drawing'

# Crear la ventana del formulario
$form = New-Object System.Windows.Forms.Form
$form.Text = "Arrastra tu archivo XML aquí"
$form.Width = 400
$form.Height = 200

# Crear un control Label para mostrar las instrucciones
$label = New-Object System.Windows.Forms.Label
$label.Text = "Arrastra y suelta un archivo XML"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(100, 50)
$form.Controls.Add($label)

# Habilitar el arrastre de archivos
$form.AllowDrop = $true

# Definir el comportamiento cuando un archivo se suelta
$form.Add_DragEnter({
    if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = [System.Windows.Forms.DragDropEffects]::Copy
    } else {
        $_.Effect = [System.Windows.Forms.DragDropEffects]::None
    }
})

# Acción cuando un archivo es soltado
$form.Add_DragDrop({
    $file = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)[0]
    if ($file.EndsWith(".xml")) {
        $txtFile = [System.IO.Path]::ChangeExtension($file, ".txt")
        
        try {
            # Leer el contenido XML y convertirlo a texto
            $xmlContent = [xml](Get-Content $file)
            $txtContent = $xmlContent.OuterXml

            # Guardar el contenido como archivo de texto
            $txtContent | Out-File $txtFile -Encoding UTF8

            [System.Windows.Forms.MessageBox]::Show("El archivo XML fue convertido a TXT exitosamente.", "Éxito", [System.Windows.Forms.MessageBoxButtons]::OK)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Hubo un error al procesar el archivo.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK)
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Por favor, suelta un archivo XML.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK)
    }
})

# Mostrar el formulario
$form.ShowDialog()