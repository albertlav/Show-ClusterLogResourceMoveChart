# Show-ClusterLogResourceMoveChart

# What it does
    Draw cluster group movement Gantt chart using clusterlogs (Get-ClusterLog)
    Quick cluster resource placement overview from cluster logs (who was CSV coordinator, or where specific VM was placed at time Z, etc)
    may be wrong if not all logs available, or not all logs consistent
    unreliable for placement data before first move and after last move, charts -1 and +1 days for each resouce since first/last movement
    chart is little bit interactive, can be zoomed in up to milliseconds scale, on NodeID axis – there is nodeIDs
    It goes through 1 Gb of logs in 5-10 seconds on SSD, and caches parsed data in XML for reuse, so once logs parsed once it will not parse again by default
    chart created based on “[RCM] move of group  from  to  is about to succeed” events and may be inaccurate if not all logs from all nodes present

# How to use
load in powershell session using . 
for example

PS C:\clusterlogs> . c:\temp\Show-ClusterLogResourceMoveChart.ps1

note that space is important between dot and path to ps1 file

then use as any PS commandlet



    PS C:\clusterlogs> get-help Show-ClusterLogResourceMoveChart -ex
    
    NAME
        Show-ClusterLogResourceMoveChart
    
    SYNOPSIS
        Draw cluster group movement Gantt chart using clusterlogs (Get-ClusterLog)


    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Show-ClusterLogResourceMoveChart

    Generate chart using *cluster.log files in current folder




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>Show-ClusterLogResourceMoveChart -Path c:\clusterlogs

    Generate chart using *cluster.log files in c:\clusterlogs folder




    -------------------------- EXAMPLE 3 --------------------------

    PS C:\>Show-ClusterLogResourceMoveChart -Path c:\clusterlogs -ForceRebuild

    Force reparses and regenerates datasource even if _groupMovementData.xml exists. _groupMovementData.xml  will be overwritten




    -------------------------- EXAMPLE 4 --------------------------

    PS C:\>Show-ClusterLogResourceMoveChart -ClusterGroupsToChart "Available Storage", "Cluster Resources", "GROUP01"

    Generate chart using *cluster.log files in current folder for "Available Storage", "Cluster Resources", "GROUP01" ClusterGroups only
