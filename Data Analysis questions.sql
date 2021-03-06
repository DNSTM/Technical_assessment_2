-- Question 1: What times of the day is lowes and highest usage for each major type of actions?

SELECT T1.[Hours],
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








