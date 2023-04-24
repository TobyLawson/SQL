
-- HEART ATTACK PREDICTION DATA PROJECT

-- heart attack data
-- this data is on different factors affecting risk of having a heart attack
-- there are some limits to this data, download notes not overly helpful
-- details of where this sample is from not known, why this number of people, the age range, location, profession, lifestyle, all not known


create database HeartAttack

EXEC sp_databases

use HeartAttack

select * from heart

-- lets turn column titles into something more meaningful
-- working with limited and inconsistent notes from dataset download

-- age = int, patient age
-- sex = int, patient gender
-- cp = chest pain type (0 = none, 1 = typical angina, 2 = atypical angina, 3 = non-anginal pain, 4 = asymptomatic) 
-- trtbps = resting blood pressure ( 'in mm Hg' -? )
-- chol = cholesterol in mg/dl fetched via BMI sensor
-- fbs = bool, fasting blood sugar > 120 mg/dl (1 = true, 0 = false)
-- restecg = resting electrocardiographic results, 0 or 1, meaning -?
-- thalachh = maximum heart rate achieved
-- exng = bool, exercise induced angina (1 = yes, 0 = no)
-- oldpeak = ? no info
-- slp = ? no info
-- caa = number of major vessels (0-3)
-- thall = ? no info
-- output = ? no info

-- drop columns 

alter table heart drop column oldpeak, slp, thall, output, restecg, caa -- although output shows up as blue it was still droppe successfully

select * from heart

-- sex column, change 0/1 coding to 'female'/'male', there are no download notes but going by typical conventions will assume 0 female 1 male

alter table heart add GENDER varchar(10);

update heart set GENDER = 'female' where sex = 0;
update heart set GENDER = 'male' where sex = 1;

select * from heart

alter table heart drop column sex

-- cp column (chest pain), change to show actual types 
-- cp = chest pain type (0 = none, 1 = typical angina, 2 = atypical angina, 3 = non-anginal pain, 4 = asymptomatic) 

alter table heart add CHEST_PAIN varchar(20);

update heart set CHEST_PAIN = 'none' where cp = 0;
update heart set CHEST_PAIN = 'typical angina' where cp = 1;
update heart set CHEST_PAIN = 'atypical angina' where cp = 2;
update heart set CHEST_PAIN = 'non-anginal pain' where cp = 3;
update heart set CHEST_PAIN = 'asymptomatic' where cp = 4;

alter table heart drop column cp

select * from heart

-- rename columns... what's in a name...  

EXEC sp_rename 'dbo.heart.age', 'AGE', 'COLUMN';
EXEC sp_rename 'dbo.heart.chol', 'CHOLESTEROL_mg_dl', 'COLUMN';
EXEC sp_rename 'dbo.heart.thalachh', 'MAX_HEART_RATE', 'COLUMN';
EXEC sp_rename 'dbo.heart.trtbps', 'BLOOD_PRESSURE_mmHg', 'COLUMN';

select * from heart

-- exng (exercise induced angina), changed to yes/no, chose to remove 'induced' as exercise angina is clear in meaning angina as a result of exercise

alter table heart add EXERCISE_ANGINA varchar(5);

update heart set EXERCISE_ANGINA = 'yes' where exng = 1;
update heart set EXERCISE_ANGINA = 'no' where exng = 0;

alter table heart drop column exng

-- fbs (fasting blood sugar > 120 mg/dl) (1 = true, 0 = false)
-- understanding this data: fasting blood glucose under 100 is normal, 100-120 is 'impaired' or pre-diabetes, over 120 means the person is diabetic
-- i can therefor rename to DIABETIC, yes/no

alter table heart add DIABETIC varchar(5);

update heart set DIABETIC = 'yes' where fbs = 1;
update heart set DIABETIC = 'no' where fbs = 0;

alter table heart drop column fbs

-- had to be careful where naming or renaming columns, as chars such as > / or () would interfer with later code use (despite being more readable in the table)

select * from heart

-- our table is now neat and tidy and clearly named

-- what do we want to find out from this data?

-- first, lets compare angina pain in under 50s and over 50s

-- what is angina though?
-- from NHS.uk:  "Angina is chest pain caused by reduced blood flow to the heart muscles. 
-- It's not usually life threatening, but it's a warning sign that you could be at risk of a heart attack or stroke."

select AGE, CHEST_PAIN as Under_50s_Chest_Pains from heart
where AGE < 50
order by AGE desc

select AGE, CHEST_PAIN as Over_50s_Chest_Pains from heart
where AGE > 50
order by AGE asc

select AGE, count(CHEST_PAIN) as No_Chest_Pain_Under_50s from heart
where CHEST_PAIN = 'none'
group by AGE
having AGE < 50
order by AGE asc

select AGE, count(CHEST_PAIN) as No_Chest_Pain_Over_50s from heart
where CHEST_PAIN = 'none'
group by AGE
having AGE < 50
order by AGE desc


-- second, lets look at max heart rate 

-- understanding max heart rate, here's a quote: 
-- “A higher heart rate is a good thing that leads to greater fitness,” 
-- says Johns Hopkins cardiologist Michael Blaha, M.D., M.P.H

-- an average max heart rate for a twenty year old is 200 bpm
-- an average max heart rate for a seventy year old is 150 bpm

select AGE, count(MAX_HEART_RATE) as Max_Heart_Rate_over_200 from heart
where MAX_HEART_RATE > 200
group by AGE
order by AGE asc

select AGE, count(MAX_HEART_RATE) as Max_Heart_Rate_over_190 from heart
where MAX_HEART_RATE > 190
group by AGE
order by AGE asc

select AGE, count(MAX_HEART_RATE) as Max_Heart_Rate_over_170 from heart
where MAX_HEART_RATE > 170
group by AGE
order by AGE asc

select AGE, count(MAX_HEART_RATE) as Max_Heart_Rate_under_150 from heart
where MAX_HEART_RATE < 150
group by AGE
order by AGE asc

-- third, we can look at blood pressure and cholesterol

-- understanding blood pressure: 90-120 is ideal, 120-140 is pre-high, 140+ is high
-- understanding cholesterol: under 200 is desirable, 200-239 is borderline high, 240+ high

select AGE, BLOOD_PRESSURE_mmHg from heart
where BLOOD_PRESSURE_mmHg > 140
order by BLOOD_PRESSURE_mmHg desc

select AGE, CHOLESTEROL_mg_dl from heart
where CHOLESTEROL_mg_dl > 240
order by CHOLESTEROL_mg_dl desc

-- lets check those to connected to diabetics and male v female

select AGE, BLOOD_PRESSURE_mmHg from heart
where GENDER = 'male' and DIABETIC = 'yes'
order by BLOOD_PRESSURE_mmHg desc

select AGE, CHOLESTEROL_mg_dl from heart
where GENDER = 'male' and DIABETIC = 'yes'
order by CHOLESTEROL_mg_dl desc

select AGE, BLOOD_PRESSURE_mmHg from heart
where GENDER = 'female' and DIABETIC = 'yes'
order by BLOOD_PRESSURE_mmHg desc

select AGE, CHOLESTEROL_mg_dl from heart
where GENDER = 'female' and DIABETIC = 'yes'
order by CHOLESTEROL_mg_dl desc
