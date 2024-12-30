--- NEW MTA
SELECT m.id, MIN(t.created_at) AS tgl_transaksi
FROM members m JOIN transaksi t
ON m.id = t.member_id
WHERE status_pengisian = 'Berhasil' 
AND type_transaksi = 'Transaksi'
GROUP BY 1
HAVING MIN(t.created_at) BETWEEN '2023-04-01 00:00:00' 
AND '2023-05-01 00:00:00' 
ORDER BY 2 ASC;

-- TOTAL MTA
SELECT DATE_FORMAT(t.created_at, '%Y-%m-01') AS tgl_transaksi, 
COUNT(DISTINCT m.id) AS total_user
FROM members m LEFT JOIN transaksi t
ON m.id = t.member_id
WHERE t.created_at BETWEEN '2022-05-01 00:00:00' 
AND '2023-05-01 00:00:00' 
AND status_pengisian = 'Berhasil' 
AND type_transaksi = 'Transaksi'
GROUP BY 1;

--- RETAINED
with new_users as (
select
 member_id,
    DATE_FORMAT(created_at, '%Y-%m-01') as cohort_month
from bang_pulsa.transaksi
where created_at BETWEEN '2023-03-01 00:00:00' AND '2023-05-01 00:00:00' AND
 status_pengisian='berhasil' and
    type_transaksi='transaksi'
group by 1),
retained as (
select
 t.member_id,
    timestampdiff(month, n.cohort_month, date_format(created_at, '%Y-%m-01')) month_number, n.cohort_month
from bang_pulsa.transaksi t
left join new_users as n
on t.member_id = n.member_id
where
 t.created_at between '2023-03-01' and '2023-05-01' and
    n.cohort_month between '2023-03-01' and '2023-04-01' and
    t.status_pengisian='berhasil' and
    t.type_transaksi='transaksi'
group by 1,2),
cohort as (
select
 cohort_month,
    count(member_id) total_user
from new_users
where
 cohort_month between '2023-03-01' and '2023-04-01'
group by 1),
retention as (
select
 cohort_month,
    month_number,
    count(member_id) total_user
from retained
group by 1,2),
tabel as (
select
 r.cohort_month,
    c.total_user cohort_size,
    r.month_number,
    r.total_user,
    round((cast(r.total_user as decimal)/c.total_user)*100,0) percent
from retention as r
left join cohort as c
on r.cohort_month = c.cohort_month
order by 1,3)
select 
 cohort_month,
    sum(if(month_number=0, total_user, null)) as '0',
    sum(if(month_number=1, total_user, null)) as '1'
from tabel
group by 1;

--- RESURRECTED MTA
WITH monthly_activity AS (
SELECT DISTINCT EXTRACT(MONTH FROM created_at) AS month, member_id
FROM transaksi
),
first_activity AS (
SELECT member_id, DATE(MIN(created_at)) AS month
FROM transaksi
GROUP BY 1
)
SELECT this_month.month, COUNT(DISTINCT last_month.member_id)
FROM monthly_activity this_month LEFT JOIN monthly_activity last_month
ON this_month.member_id = last_month.member_id
AND this_month.month = add_month(last_month.month, 1)
JOIN first_activity
ON this_month.member_id = first_activity.member_id
AND first_activity.month != this_month.month
WHERE last_month.member_id IS NULL
GROUP BY 1;

-- COHORT (ANGKA)
with new_users as(
select
 member_id,
    min(date_format(created_at, '%Y-%m-01')) as cohort_month
from bang_pulsa.transaksi
where
 status_pengisian='berhasil' and
    type_transaksi='transaksi'
group by 1
),
retained as (
select
 t.member_id,
    timestampdiff(month, n.cohort_month, date_format(created_at, '%Y-%m-01')) month_number, 
    n.cohort_month
from bang_pulsa.transaksi t
left join new_users as n
on t.member_id = n.member_id
where
 t.created_at between '2022-05-01' and '2023-05-01' and
    n.cohort_month between '2022-05-01' and '2023-04-01' and
    t.status_pengisian='berhasil' and
    t.type_transaksi='transaksi'
group by 1,2
),
cohort as (
select
 cohort_month,
    count(member_id) total_user
from new_users
where
 cohort_month between '2022-05-01' and '2023-04-01'
group by 1
),
retention as (
select
 cohort_month,
    month_number,
    count(member_id) total_user
from retained
group by 1,2
),
tabel as (
select
 r.cohort_month,
    c.total_user cohort_size,
    r.month_number,
    r.total_user,
    round((cast(r.total_user as decimal)/c.total_user)*100,0) percent
from retention as r
left join cohort as c
on r.cohort_month = c.cohort_month
order by 1,3
)
select 
 cohort_month,
    sum(if(month_number=0, percent, null)) as '0',
    sum(if(month_number=1, percent, null)) as '1',
    sum(if(month_number=2, percent, null)) as '2',
    sum(if(month_number=3, percent, null)) as '3',
    sum(if(month_number=4, percent, null)) as '4',
    sum(if(month_number=5, percent, null)) as '5',
    sum(if(month_number=6, percent, null)) as '6',
    sum(if(month_number=7, percent, null)) as '7',
    sum(if(month_number=8, percent, null)) as '8',
    sum(if(month_number=9, percent, null)) as '9',
    sum(if(month_number=10, percent, null)) as '10',
    sum(if(month_number=11, percent, null)) as '11'
from tabel
group by 1;


with new_users as(
select
 member_id,
    min(date_format(created_at, '%Y-%m-01')) as cohort_month
from bang_pulsa.transaksi
where
 status_pengisian='berhasil' and
    type_transaksi='transaksi'
group by 1
),
retained as (
select
 t.member_id,
    timestampdiff(month, n.cohort_month, date_format(created_at, '%Y-%m-01')) month_number, n.cohort_month
from bang_pulsa.transaksi t
left join new_users as n
on t.member_id = n.member_id
where
 t.created_at between '2022-05-01' and '2023-05-01' and
    n.cohort_month between '2022-05-01' and '2023-04-01' and
    t.status_pengisian='berhasil' and
    t.type_transaksi='transaksi'
group by 1,2
),
cohort as (
select
 cohort_month,
    count(member_id) total_user
from new_users
where
 cohort_month between '2022-05-01' and '2023-04-01'
group by 1
),
retention as (
select
 cohort_month,
    month_number,
    count(member_id) total_user
from retained
group by 1,2
),
tabel as (
select
 r.cohort_month,
    c.total_user cohort_size,
    r.month_number,
    r.total_user,
    round((cast(r.total_user as decimal)/c.total_user)*100,0) percent
from retention as r
left join cohort as c
on r.cohort_month = c.cohort_month
order by 1,3
)
select 
 cohort_month,
    sum(if(month_number=0, total_user, null)) as '0',
    sum(if(month_number=1, total_user, null)) as '1',
    sum(if(month_number=2, total_user, null)) as '2',
    sum(if(month_number=3, total_user, null)) as '3',
    sum(if(month_number=4, total_user, null)) as '4',
    sum(if(month_number=5, total_user, null)) as '5',
    sum(if(month_number=6, total_user, null)) as '6',
    sum(if(month_number=7, total_user, null)) as '7',
    sum(if(month_number=8, total_user, null)) as '8',
    sum(if(month_number=9, total_user, null)) as '9',
    sum(if(month_number=10, total_user, null)) as '10',
    sum(if(month_number=11, total_user, null)) as '11'
from tabel
group by 1;














