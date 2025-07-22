Add-Type -AssemblyName 'System.Windows.Forms'
Add-Type -AssemblyName 'System.Drawing'

# Crear la ventana del formulario
$form = New-Object System.Windows.Forms.Form
$form.Text = "Selecciona una carpeta con archivos XML"
$form.Width = 400
$form.Height = 200

# Crear un control Label para mostrar las instrucciones
$label = New-Object System.Windows.Forms.Label
$label.Text = "Haz clic en el boton para seleccionar una carpeta"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(100, 50)
$form.Controls.Add($label)

# Crear el botón de "Seleccionar Carpeta"
$button = New-Object System.Windows.Forms.Button
$button.Text = "Seleccionar Carpeta"
$button.Location = New-Object System.Drawing.Point(150, 100)
$form.Controls.Add($button)

# Acción cuando se haga clic en el botón
$button.Add_Click({
    # Mostrar cuadro de selección de carpeta
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.Description = "Selecciona una carpeta que contenga archivos XML"
    $folderDialog.ShowNewFolderButton = $false

    $dialogResult = $folderDialog.ShowDialog()
    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $folderPath = $folderDialog.SelectedPath

        # Crear una nueva carpeta para los archivos TXT
        $outputFolder = [System.IO.Path]::Combine($folderPath, "Archivos_TXT")
        if (-not (Test-Path $outputFolder)) {
            New-Item -Path $outputFolder -ItemType Directory
        }

        # Buscar todos los archivos XML en la carpeta seleccionada
        $xmlFiles = Get-ChildItem -Path $folderPath -Filter *.xml

        if ($xmlFiles.Count -gt 0) {
            # Procesar cada archivo XML
            foreach ($xmlFile in $xmlFiles) {
				$txtFilePath = [System.IO.Path]::Combine($outputFolder, [System.IO.Path]::GetFileNameWithoutExtension($xmlFile.Name) + ".txt")
				$txtFile = New-Object System.IO.StreamWriter($txtFilePath)
                try {
                    # Leer el contenido XML
                    $xmlContent = [xml](Get-Content $xmlFile.FullName)
					# Extraer los conceptos del CFDI
			
					# Asegurarse de que el espacio de nombres se maneje correctamente	
					$namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlContent.NameTable)
					$namespaceManager.AddNamespace("cfdi", "http://www.sat.gob.mx/cfd/4")

					$conceptos = $xmlContent.DocumentElement.SelectNodes("//cfdi:Concepto", $namespaceManager)
                    # Extraer NoIdentificacion, Cantidad e Importe
                    $output = ""
					foreach ($concepto in $conceptos){
#						$descripcion = $concepto.GetAttribute("Descripcion")
						$NoIdentificacion = $concepto.GetAttribute("NoIdentificacion")
						$ValorUnitario = $concepto.GetAttribute("ValorUnitario")
						$cantidad = $concepto.GetAttribute("Cantidad")
#						$unidad = $concepto.GetAttribute("Unidad")
#						$importe = $concepto.GetAttribute("Importe")

						$linea = "$NoIdentificacion, $ValorUnitario, $cantidad,0,0"
						$txtFile.WriteLine($linea)
					}

                    # Guardar el contenido extraído en un archivo de texto
#$output | Out-File $txtFile -Encoding UTF8
					$txtFile.Close()
                } catch {
                    Write-Host "Error al procesar el archivo: $($xmlFile.Name)"
                }
            }

            [System.Windows.Forms.MessageBox]::Show("La conversion de los archivos XML a TXT se completo exitosamente.", "Exito", [System.Windows.Forms.MessageBoxButtons]::OK)
			[System.Environment]::Exit(0)
        } else {
            [System.Windows.Forms.MessageBox]::Show("No se encontraron archivos XML en la carpeta seleccionada.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK)
        }
    }
})

# Mostrar el formulario
$form.ShowDialog()