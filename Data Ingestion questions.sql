
-- 1. How many action records are present for each type major?

SELECT
	U1.action_type_major,
	COUNT (DISTINCT action_mysql_id) NumberOfAction_ForEachMajor
FROM [dbo].[User_Activity] AS U1
GROUP BY U1.action_type_major
;


-- 2. What is the time range of the data set?

SELECT MIN (session_start_date_time) MIN_SESSION_DATE, MAX(session_end_date_time) MAX_SESSION_DATE
FROM [dbo].[User_Activity] WITH (NOLOCK)
WHERE session_start_date_time != '1970-01-01 00:00:00.000'


-- 3. What is the average, minimum, and maximum number of action records on each day? A day should be 
----  considered midnight to midnight in EDT (Eastern Daylight Time, UTC-4).

SELECT 
	AVG(NUMBER_OF_ACTION_RECORDS) [Avg of action records on each day],
	MIN(NUMBER_OF_ACTION_RECORDS) [Max of action records on each day],
	MAX(NUMBER_OF_ACTION_RECORDS) [Min of action records on each day]
FROM 
(
	SELECT 
		CAST (action_request_time AS DATE ) AS ACTION_DAY,
		COUNT(*) NUMBER_OF_ACTION_RECORDS
	FROM [dbo].[User_Activity] AS U1
	GROUP BY CAST (action_request_time AS DATE )
) AS T1
;


-- 4. What is the average dwell time per page view?


-- Using aggregation analytic functions with CTE
WITH CTE_1 AS (
SELECT 
	U1.*,
	AVG(ABS( CAST (DATEDIFF(MINUTE, U1.action_request_time, U1.action_invisible_time ) AS BIGINT))) OVER (PARTITION BY U1.action_resource_major ) AVG_DWELL_TIME,
	ROW_NUMBER () OVER (PARTITION BY U1.action_resource_major ORDER BY U1.action_resource_major) AS RN
FROM [dbo].[User_Activity] AS U1
WHERE U1.action_type_major = 'V'
)
SELECT action_resource_major, AVG_DWELL_TIME FROM CTE_1
WHERE RN = 1


-- using direct group by command
SELECT 
	U1.ACTION_RESOURCE_MAJOR,
	ABS(SUM( CAST (DATEDIFF(MINUTE, U1.action_request_time, U1.action_invisible_time )AS BIGINT)) / COUNT(*)) DWELL_TIME_BY_MINUTE
FROM [dbo].[User_Activity] AS U1
WHERE U1.action_type_major = 'V'
GROUP BY U1.ACTION_RESOURCE_MAJOR


-- 5. What is the average number of page views per session and per device?

SELECT AVG(T1.COUNT_OF_PAGE_VIEW) [Avg number of page views for per device]
FROM
(
	SELECT device_id, COUNT (*) COUNT_OF_PAGE_VIEW
	FROM [dbo].[User_Activity] AS U1
	WHERE U1.action_type_major = 'V'
	GROUP BY device_id
)AS T1 


SELECT AVG(T1.COUNT_OF_PAGE_VIEW) [Avg number of page views for per session]
FROM
(
	SELECT session_id, COUNT (*) COUNT_OF_PAGE_VIEW
	FROM [dbo].[User_Activity] AS U1
	WHERE U1.action_type_major = 'V'
	GROUP BY session_id
)AS T1 


SELECT CAST (T1.[Hours] AS NVARCHAR (50)) + ':00',
	SUM (PAGE_VIEW)	AS PAGE_VIEW,
	SUM (PUSH_VIEW) AS PUSH_VIEW,
	SUM (PUSH_CLICK) AS PUSH_CLICK,
	SUM (BANNER_WAS_VIEWED) AS BANNER_WAS_VIEWED,
	SUM (BANNER_WAS_CLICKED) AS BANNER_WAS_CLICKED
FROM (
	SELECT 
		DATEPART(HOUR, action_request_time) [Hours],
		CASE WHEN ACTION_TYPE_MAJOR = 'AD_BAN_CLICK' THEN COUNT (*) ELSE 0 END BANNER_WAS_CLICKED,
		CASE WHEN ACTION_TYPE_MAJOR = 'AD_BAN_IMP' THEN COUNT (*) ELSE 0 END BANNER_WAS_VIEWED,
		CASE WHEN ACTION_TYPE_MAJOR = 'PUSH_CLICK' THEN COUNT (*) ELSE 0 END PUSH_CLICK,
		CASE WHEN ACTION_TYPE_MAJOR = 'PUSH_VIEW' THEN COUNT (*) ELSE 0 END PUSH_VIEW,
		CASE WHEN ACTION_TYPE_MAJOR = 'V' THEN COUNT (*) ELSE 0 END PAGE_VIEW
	FROM [dbo].[User_Activity] AS U1
	GROUP BY DATEPART(HOUR, action_request_time),ACTION_TYPE_MAJOR
) AS T1
GROUP BY T1.[Hours]
;





