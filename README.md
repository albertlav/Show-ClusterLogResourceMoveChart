# Show-ClusterLogResourceMoveChart
Builds cluster group movement chart based on clusterlogs (Get-Cluserlog output)

   Draw cluster group movement Gantt chart using clusterlogs (Get-ClusterLog)
   may be wrong if not all logs available, or not all logs consistent
   unreliable for placement data before first move and after last move, charts -1 and +1 days for each resouce since first/last movement


load in powershell session using .
for example

PS C:\clusterlogs> . \\vallav1\testshare\Show-ClusterLogResourceMoveChart.ps1

note that space is important between dot and path to ps1 file
