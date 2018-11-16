<#
.Synopsis
   Draw cluster group movement Gantt chart using clusterlogs (Get-ClusterLog)
.DESCRIPTION
   Draw cluster group movement Gantt chart using clusterlogs (Get-ClusterLog)
   may be wrong if not all logs available, or not all logs consistent
   unreliable for placement data before first move and after last move, charts -1 and +1 days for each resouce since first/last movement
.EXAMPLE
   Show-ClusterLogResourceMoveChart
   Generate chart using *cluster.log files in current folder
.EXAMPLE
   Show-ClusterLogResourceMoveChart -Path c:\clusterlogs
   Generate chart using *cluster.log files in c:\clusterlogs folder
.EXAMPLE
   Show-ClusterLogResourceMoveChart -Path c:\clusterlogs -ForceRebuild
   Force reparses and regenerates datasource even if _groupMovementData.xml exists. _groupMovementData.xml  will be overwritten
.EXAMPLE
   Show-ClusterLogResourceMoveChart -ClusterGroupsToChart "Available Storage", "Cluster Resources", "GROUP01"
   Generate chart using *cluster.log files in current folder for "Available Storage", "Cluster Resources", "GROUP01" ClusterGroups only
#>
function Show-ClusterLogResourceMoveChart {
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1', 
        SupportsShouldProcess = $true, 
        PositionalBinding = $false,
        HelpUri = 'http://www.microsoft.com/',
        ConfirmImpact = 'Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Path to folder with clusterlogs
        [Parameter(
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Path = ".",

        # Cluster Groups to Draw
        [Parameter(ParameterSetName = 'Parameter Set 1')]
        [String[]]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        $ClusterGroupsToChart = @(),

        # Force reprocess *cluster.log files even if _groupMovementData.xml exists. Existing file _groupMovementData.xml will be overwritten 
        [Parameter(ParameterSetName = 'Parameter Set 1')]
        [switch] $ForceRebuild
    )

    Begin {
        
    }
    Process {




        function AddDataToChartAndRedraw () {
    
 
            #region Add data to chart 
            $Chart.Series.Clear()
            $logselector="*"
            if ($DropDownLogs.SelectedIndex -ne 0) {$logselector=$DropDownLogs.SelectedItem}
            if ($DropDownGroups.SelectedIndex -ne 0) {$ClusterGroupsToChart=$DropDownGroups.SelectedItem}
            foreach ($keyGroup in $groupMovementData.Keys) {
                if ($ClusterGroupsToChart.Contains($keyGroup) -or $ClusterGroupsToChart.Count -eq 0) {
                    [void]$Chart.Series.Add($keyGroup)
                    $Chart.Series["$keyGroup"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::RangeBar;

                    #unreliable - before first move, chart 1 day before it
                    $Chart.Series[$keyGroup].Points.AddXY([int]$groupMovementData[$keyGroup][0][3].Split('()')[1], $groupMovementData[$keyGroup][0][0].AddDays(-1),$groupMovementData[$keyGroup][0][0])| Out-Null

                    for ($i = 0; $i -lt $groupMovementData[$keyGroup].count; $i++) {



                        if ($groupMovementData[$keyGroup][$i][2] -like $logselector) {
                            if ($i + 1 -ge $groupMovementData[$keyGroup].count) {
                                #unreliable - after last move, chart 1 days after it
                                $Chart.Series[$keyGroup].Points.AddXY([int]$groupMovementData[$keyGroup][$i][1].Split('()')[1], $groupMovementData[$keyGroup][$i][0], $groupMovementData[$keyGroup][$i][0].AddDays(1))| Out-Null
                            }
                            else {
                                $Chart.Series[$keyGroup].Points.AddXY([int]$groupMovementData[$keyGroup][$i][1].Split('()')[1], $groupMovementData[$keyGroup][$i][0], $groupMovementData[$keyGroup][$i + 1][0]) | Out-Null
                            }
                        }
                    }
                }
            }
            $Chart.Refresh()
            #endregion
        }



        #region parse logs and build dataset, or reload if available
        $logfiles = Get-ChildItem -Path $Path -Filter *cluster.log 
        if ((Test-Path "$Path\_groupMovementData.xml") -and !$ForceRebuild) {
            $groupMovementData = Import-Clixml "$Path\_groupMovementData.xml" 

        }
        else {
            $groupMoveSeparators = @("::", " INFO  [RCM] move of group ", " from ", " to ", " of type ", " is about to succeed")
            $groupMovementData = @{ }
            foreach ($logfile in $logfiles) {
                $logfile.Name
                $lineEnumerator = [System.IO.File]::ReadLines($logfile.FullName)
                foreach ($line in $lineEnumerator) {
                    if ($line.Contains("[RCM] move of group") -and $line.Contains("is about to succeed")) {
                        $data = $line.Split($groupMoveSeparators, 0)
                        $timestamp = [datetime]::parseexact($data[1], 'yyyy/MM/dd-HH:mm:ss.fff', $null)
                        $groupName = $data[2]
                        $nodeFrom = $data[3]
                        $nodeTo = $data[4]


                        if (!$groupMovementData.ContainsKey($groupName)) {$groupMovementData.Add($groupName, $(New-Object System.Collections.ArrayList))}
                        [void]$groupMovementData[$groupName].Add(@($timestamp, $nodeTo, $logfile.Name, $nodeFrom))
                    }
                }
            }
            #sort resulting arraylists by timestamps
            [string[]]$keysTemp=$groupMovementData.Keys
            foreach ($key in $keysTemp){$groupMovementData[$key]=$groupMovementData[$key]|Sort-Object -Property {$_[0]}}

            $groupMovementData | Export-Clixml "$Path\_groupMovementData.xml" -Force
        }
        #endregion



        [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
        [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
        $Form = New-Object Windows.Forms.Form 
        $Form.Text = "ClusterLog Chart" 
        $Form.Width = 600 
        $Form.Height = 600 


        #region drop down selectors

        $DropDownLogs = new-object System.Windows.Forms.ComboBox
        $DropDownLogs.Location = new-object System.Drawing.Size(40, 40)
        $DropDownLogs.Size = new-object System.Drawing.Size(330, 30)
        $DropDownLogs.Items.Add("All logs combined")
        $DropDownLogs.SelectedItem = $DropDownLogs.Items[0]
        $DropDownLogs.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left 
        ForEach ($Item in $logfiles) {
            [void] $DropDownLogs.Items.Add($Item)
        }
        $DropDownLogs.add_SelectedIndexChanged( {AddDataToChartAndRedraw})
        $Form.Controls.Add($DropDownLogs)




        $DropDownGroups = new-object System.Windows.Forms.ComboBox
        $DropDownGroups.Location = new-object System.Drawing.Size(40, 10)
        $DropDownGroups.Size = new-object System.Drawing.Size(330, 30)
        $DropDownGroups.Items.Add("All groups combined")
        $DropDownGroups.SelectedItem = $DropDownGroups.Items[0]
        $DropDownGroups.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left 
        ForEach ($Item in $groupMovementData.Keys) {
            [void] $DropDownGroups.Items.Add($Item)
        }
        $DropDownGroups.add_SelectedIndexChanged( {AddDataToChartAndRedraw})
        $Form.Controls.Add($DropDownGroups)

        #endregion


        #region Create Chart object and tune it 
        # create chart object 
        $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
        $Chart.Width = 500 
        $Chart.Height = 400 
        $Chart.Left = 40 
        $Chart.Top = 80
        #$Chart.Cursor
        # create a chartarea to draw on and add to chart 
        $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea 
        $Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend

        $ChartArea.CursorY.IsUserEnabled = $true
        $ChartArea.CursorY.IsUserSelectionEnabled = $true
        $ChartArea.CursorX.IsUserEnabled = $true
        $ChartArea.CursorX.IsUserSelectionEnabled = $true
        #$ChartArea.AxisY.IntervalAutoMode = 1
        $ChartArea.AxisY.IntervalType = 8
        $ChartArea.AxisY.LabelStyle.Format = "yyyy/MM/dd-HH:mm:ss"
        $ChartArea.AxisX.Title = "NodeID"
        $ChartArea.AxisX.IsMarginVisible = $true
        $ChartArea.AxisX.LineWidth = 0

        $ChartArea.CursorY.IntervalType = 8
        $Legend.Title="Cluster Groups"
        $Legend.Enabled = $true
        $Chart.Legends.Add($Legend)
        $Chart.ChartAreas.Add($ChartArea)

        #endregion 

        AddDataToChartAndRedraw

        # display the chart on a form 
        $Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor 
        [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left 
        $Form.Controls.Add($Chart) 


        #region save button 

        
        $SaveFileDialog = New-Object Windows.Forms.SaveFileDialog   
        $SaveFileDialog.initialDirectory =  $env:HOMEDRIVE+$env:HOMEPATH
        $SaveFileDialog.title = "Save current graph to disk"   
        $SaveFileDialog.filter = "PNG files|*.PNG" 


        $SaveButton = New-Object Windows.Forms.Button 
        $SaveButton.Text = "Save Current View to File" 
        $SaveButton.Top = 40 
        $SaveButton.Left = 465 
        $SaveButton.AutoSize=$true
        $SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right 
        $SaveButton.add_click( {
                $result = $SaveFileDialog.ShowDialog()    
        $result 
        if($result -eq "OK")    {    
                $Chart.SaveImage($SaveFileDialog.filename, "PNG")
        }       
        }) 
        $Form.controls.add($SaveButton)
        #endregion




        $Form.Add_Shown( {$Form.Activate()}) 
        $Form.ShowDialog()



    }
    End {
    }
}
