drop table clean.diabeticData

select *
into clean.diabeticData
from orig.diabetic_data

delete d
from clean.diabeticData d
    join clean.idMapping id
        on id.idValue = d.discharge_disposition_id
where id.idType = 'discharge_disposition_id'
    and (id.[description] like '%hospice%' or
         id.[description] like '%expired%')

delete
from clean.diabeticData
where discharge_disposition_id in (9,15)

;with patDups as (
    select row_number() over(partition by patient_nbr order by encounter_id) [seq]
    from clean.diabeticData
)
delete
from patDups
where seq <> 1

alter table clean.diabeticData
drop column num_lab_procedures, num_medications, num_procedures,
            number_diagnoses, diag_2, diag_3, arcabose, acetohexamide,
            chlorpropamide, citoglipton, examide, [glimepiride-pioglitazone],
            glipizide, [glyburide-metformin], max_glu_serum, 
            [metformin-pioglitazone], [metformin-rosiglitazone],
            miglitol, nateglinide, payer_code, repaglinide, tolazamide, 
            tolbutamide, troglitazone, [weight]

update clean.diabeticData
set age = '[0-40)'
where age in ('[0-10)','[10-20)','[20-30)','[30-40)')

delete
from clean.diabeticData
where gender = 'Unknown/Invalid'

update clean.diabeticData
set admission_type_id = 'Emergency'
where admission_type_id in (1,2)

update clean.diabeticData
set admission_type_id = 'Elective'
where admission_type_id = '3'

update clean.diabeticData
set admission_type_id = 'Other'
where isnumeric(admission_type_id) = 1

update clean.diabeticData
set admission_source_id = 'referral'
where admission_source_id in (1,2,3)

update clean.diabeticData
set admission_source_id = 'transfer'
where admission_source_id in ('4','5','6','10','18','19','22','25','26')

update clean.diabeticData
set admission_source_id = 'emergency'
where admission_source_id = '7'

update clean.diabeticData
set admission_source_id = 'other'
where isnumeric(admission_source_id) = 1

update clean.diabeticData
set medical_specialty = 'unknown'
where medical_specialty in ('?','PhysicianNotFound')

update clean.diabeticData
set medical_specialty = 'emergency'
where medical_specialty in ('dcpteam','emergency/trauma')

update clean.diabeticData
set medical_specialty = 'pcp'
where medical_specialty in ('family/generalpractice','internalmedicine','outreachservices')

update clean.diabeticData
set medical_specialty = 'surgery'
where medical_specialty like 'surg%'

update clean.diabeticData
set medical_specialty = 'other specialty'
where medical_specialty not in ('unknown','emergency','pcp','surgery')

update clean.diabeticData
set number_emergency = 1
where number_emergency != 0

update clean.diabeticData
set number_inpatient = 1
where number_inpatient != 0

update clean.diabeticData
set number_outpatient = 1
where number_outpatient != 0

update clean.diabeticData
set readmitted = case when readmitted = '<30' then 1 else 0 end

delete 
from clean.diabeticData
where discharge_disposition_id in (10,2,22,23,27,28,4,5)

update clean.diabeticData
set discharge_disposition_id = 
    case when discharge_disposition_id in ('1','6','8') then 'home'
         when discharge_disposition_id in ('3','12','16','18','24') then 'transfer'
         else 'other' end

update clean.diabeticData
set glimepiride = '0' 
where glimepiride = 'no'

update clean.diabeticData
set glimepiride = '1'
where glimepiride != '0'

update clean.diabeticData
set Glyburide = '0' 
where Glyburide = 'no'

update clean.diabeticData
set Glyburide = '1'
where Glyburide != '0'

update clean.diabeticData
set Metformin = '0' 
where Metformin = 'no'

update clean.diabeticData
set Metformin = '1'
where Metformin != '0'

update clean.diabeticData
set Pioglitazone = '0' 
where Pioglitazone = 'no'

update clean.diabeticData
set Pioglitazone = '1'
where Pioglitazone != '0'

update clean.diabeticData
set Rosiglitazone = '0' 
where Rosiglitazone = 'no'

update clean.diabeticData
set Rosiglitazone = '1'
where Rosiglitazone != '0'

update clean.diabeticData
set race = 'other'
where not race in ('AfricanAmerican','Caucasian')

update clean.diabeticData
set medChanged = '0'
where medChanged = 'No'

update clean.diabeticData
set medChanged = '1'
where medChanged != '0'

;with goodDx as (
    select primDx
    from clean.diabeticData
    where readmitted = 1
    group by primDx
    having count(1) >= 5
    intersect
    select primDx
    from clean.diabeticData
    where readmitted = 0
    group by primDx
    having count(1) >=5
)
update c
set primDx = 'other'
from clean.diabeticData c
    left join goodDx g
        on g.primDx = c.primDx
where g.primDx is null


