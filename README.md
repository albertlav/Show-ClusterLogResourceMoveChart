# Show-ClusterLogResourceMoveChart
Builds cluster group movement chart based on clusterlogs (Get-Cluserlog output)


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



