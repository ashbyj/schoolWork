alter table clean.diabeticData
add primDxClus int null

update c
set primDxClus = d.primDxClus
from clean.diabeticData c
    join clean.dxClusters d
        on d.encId = c.encId

update clean.diabeticData
set primDxClus = -1
where primDxClus is null

alter table clean.diabeticData
drop column primDx

select distinct primDx
    , primDxClus
into clean.clusterCodes
from clean.dxClusters

update clean.diabeticData
set primDxClus = -1
where primDxClus in (1,3,4,9)


