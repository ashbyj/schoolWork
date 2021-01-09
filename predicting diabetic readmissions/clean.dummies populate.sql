insert into clean.dummies
select encId
    , readmitted
    , ipEnc
    , edEnc
    , metformin
    , dmRx
    , case when primDxClus = '2' then 1 else 0 end
    , case when primDxClus = '5' then 1 else 0 end
    , case when primDxClus = '6' then 1 else 0 end
    , case when primDxClus = '7' then 1 else 0 end
    , case when primDxClus = '8' then 1 else 0 end
    , case when race = 'Caucasian' then 1 else 0 end
    , case when race = 'AfricanAmerican' then 1 else 0 end
    , case when dischargeDisp = 'home' then 1 else 0 end
    , case when dischargeDisp = 'transfer' then 1 else 0 end
    , case when admitSpecialty = 'emergency' then 1 else 0 end
    , case when admitSpecialty = 'other specialty' then 1 else 0 end
    , case when admitSpecialty = 'pcp' then 1 else 0 end
    , case when admitSpecialty = 'surgery' then 1 else 0 end
    , case when age = '[0-40)' then 1 else 0 end
    , case when age = '[40-50)' then 1 else 0 end
    , case when age = '[50-60)' then 1 else 0 end
    , case when age = '[60-70)' then 1 else 0 end
    , case when age = '[70-80)' then 1 else 0 end
    , case when age = '[80-90)' then 1 else 0 end
    , case when age = '[90-100)' then 1 else 0 end
    , case when race = 'AfricanAmerican' and age = '[0-40)' then 1 else 0 end
    , case when race = 'AfricanAmerican' and age = '[40-50)' then 1 else 0 end
    , case when race = 'AfricanAmerican' and age = '[50-60)' then 1 else 0 end
    , case when race = 'AfricanAmerican' and age = '[60-70)' then 1 else 0 end
    , case when race = 'AfricanAmerican' and age = '[70-80)' then 1 else 0 end
    , case when race = 'AfricanAmerican' and age = '[80-90)' then 1 else 0 end
    , case when race = 'AfricanAmerican' and age = '[90-100)' then 1 else 0 end
    , case when race = 'Caucasian' and age = '[0-40)' then 1 else 0 end
    , case when race = 'Caucasian' and age = '[40-50)' then 1 else 0 end
    , case when race = 'Caucasian' and age = '[50-60)' then 1 else 0 end
    , case when race = 'Caucasian' and age = '[60-70)' then 1 else 0 end
    , case when race = 'Caucasian' and age = '[70-80)' then 1 else 0 end
    , case when race = 'Caucasian' and age = '[80-90)' then 1 else 0 end
    , case when race = 'Caucasian' and age = '[90-100)' then 1 else 0 end
    , case when dischargeDisp = 'home' and age = '[0-40)' then 1 else 0 end
    , case when dischargeDisp = 'home' and age = '[40-50)' then 1 else 0 end
    , case when dischargeDisp = 'home' and age = '[50-60)' then 1 else 0 end
    , case when dischargeDisp = 'home' and age = '[60-70)' then 1 else 0 end
    , case when dischargeDisp = 'home' and age = '[70-80)' then 1 else 0 end
    , case when dischargeDisp = 'home' and age = '[80-90)' then 1 else 0 end
    , case when dischargeDisp = 'home' and age = '[90-100)' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and age = '[0-40)' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and age = '[40-50)' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and age = '[50-60)' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and age = '[60-70)' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and age = '[70-80)' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and age = '[80-90)' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and age = '[90-100)' then 1 else 0 end
    , case when dischargeDisp = 'home' and admitSpecialty = 'emergency' then 1 else 0 end
    , case when dischargeDisp = 'home' and admitSpecialty = 'other specialty' then 1 else 0 end
    , case when dischargeDisp = 'home' and admitSpecialty = 'pcp' then 1 else 0 end
    , case when dischargeDisp = 'home' and admitSpecialty = 'surgery' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and admitSpecialty = 'emergency' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and admitSpecialty = 'other specialty' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and admitSpecialty = 'pcp' then 1 else 0 end
    , case when dischargeDisp = 'transfer' and admitSpecialty = 'surgery' then 1 else 0 end
from clean.diabeticData