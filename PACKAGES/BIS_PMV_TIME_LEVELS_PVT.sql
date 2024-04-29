--------------------------------------------------------
--  DDL for Package BIS_PMV_TIME_LEVELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_TIME_LEVELS_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVTMLS.pls 120.1 2005/07/12 17:13:21 serao noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.10=120.1):~PROD:~PATH:~FILE
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
--
--	ansingh			Apr 22, 2003	BugFix#2887200
--	nbarik			Jul 10, 2003	BugFix#2999602


   -- Enter package declarations as shown below
PROCEDURE GET_PREVIOUS_TIME_LEVEL_VALUE
(p_DimensionLevel        in  VARCHAR2
,p_region_Code           in  VARCHAR2
,p_Responsibility_id     in  VARCHAR2
,p_asof_date             in  DATE
,p_time_comparison_type  in  VARCHAR2
,x_time_level_id         OUT NOCOPY VARCHAR2
,x_time_level_value      OUT NOCOPY VARCHAR2
,x_start_Date            OUT NOCOPY DATE
,x_end_date              OUT NOCOPY DATE
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
,p_use_current_mode      IN BOOLEAN DEFAULT FALSE
);

PROCEDURE GET_TIME_LEVEL_INFO
(p_DimensionLevel       IN    VARCHAR2
,p_region_code          IN    VARCHAR2
,p_Responsibility_id     in  VARCHAR2
,p_asof_date            IN    DATE
,p_mode                  IN    VARCHAR2
,x_time_level_id        OUT   NOCOPY VARCHAR2
,x_time_level_Value     OUT   NOCOPY VARCHAR2
,x_start_Date           OUT   NOCOPY DATE
,x_end_date             OUT   NOCOPY DATE
,x_return_Status        OUT   NOCOPY VARCHAR2
,x_msg_count            OUT   NOCOPY NUMBER
,x_msg_data             OUT   NOCOPY VARCHAR2
);
PROCEDURE GET_PREVIOUS_ASOF_DATE
(p_DimensionLevel        IN    VARCHAR2
,p_time_comparison_type  IN    VARCHAR2
,p_asof_date             IN    DATE
,x_prev_asof_Date        OUT   NOCOPY DATE
,x_Return_status         OUT   NOCOPY VARCHAR2
,x_msg_count             OUT   NOCOPY NUMBER
,x_msg_data              OUT   NOCOPY VARCHAR2
);
PROCEDURE GET_BIS_COMMON_START_DATE
(x_prev_asof_Date       OUT   NOCOPY DATE
,x_return_Status        OUT   NOCOPY VARCHAR2
,x_msg_count            OUT   NOCOPY NUMBER
,x_msg_data             OUT   NOCOPY VARCHAR2
);
PROCEDURE GET_REPORT_START_DATE
(p_time_comparison_type IN  VARCHAR2
,p_asof_date            IN  DATE
,p_time_level           IN  VARCHAR2
,x_report_start_date    OUT NOCOPY DATE
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);

/*-----BugFix#2887200 -ansingh-------*/
PROCEDURE GET_TIME_PARAMETER_RECORD (
	p_TimeParamterName	IN VARCHAR2,
	p_DateParameter			IN DATE,
	x_parameterRecord   OUT NOCOPY BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
	x_return_Status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_Data          OUT NOCOPY VARCHAR2
);
/*-----BugFix#2887200 -ansingh-------*/
/*
Bug Fix 2999602 - Added x_prev_effective_start_date and x_prev_effective_end_date
*/
PROCEDURE GET_COMPUTED_DATES (
	p_region_code									 IN VARCHAR2,
	p_resp_id											 IN VARCHAR2,
	p_time_comparison_type         IN VARCHAR2,
	p_asof_date                    IN varchar2,
	p_time_level                   IN VARCHAR2,
	x_prev_asof_Date               OUT NOCOPY DATE,
	x_curr_effective_start_date    OUT NOCOPY DATE,
	x_curr_effective_end_date      OUT NOCOPY DATE,
	x_curr_report_Start_date       OUT NOCOPY DATE,
	x_prev_report_Start_date       OUT NOCOPY DATE,
	x_time_level_id								 OUT NOCOPY VARCHAR2,
	x_time_level_value						 OUT NOCOPY VARCHAR2,
        x_prev_effective_start_date    OUT NOCOPY DATE,
        x_prev_effective_end_date      OUT NOCOPY DATE,
        x_prev_time_level_id           OUT NOCOPY VARCHAR2,
        x_prev_time_level_value        OUT NOCOPY VARCHAR2,
	x_return_status                OUT NOCOPY VARCHAR2,
	x_msg_count                    OUT NOCOPY NUMBER,
	x_msg_Data                     OUT NOCOPY VARCHAR2
);


PROCEDURE GET_NESTED_PATTERN
(p_time_comparison_type IN VARCHAR2
,p_time_level           IN VARCHAR2
,x_nested_pattern       OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_Data             OUT NOCOPY VARCHAR2
);

--Combo Box Enh
PROCEDURE GET_POPLIST_DATES (
	p_asof_date                    IN DATE,
	p_rolling                      IN VARCHAR2 DEFAULT NULL,
	x_last_week	               OUT NOCOPY DATE,
	x_last_period		       OUT NOCOPY DATE,
	x_last_qtr		       OUT NOCOPY DATE,
	x_last_year		       OUT NOCOPY DATE,
	x_week			       OUT NOCOPY DATE,
        x_period		       OUT NOCOPY DATE,
        x_qtr			       OUT NOCOPY DATE,
        x_year			       OUT NOCOPY DATE,
	x_rolling_week	               OUT NOCOPY DATE,
	x_rolling_period	       OUT NOCOPY DATE,
	x_rolling_qtr		       OUT NOCOPY DATE,
	x_rolling_year		       OUT NOCOPY DATE,
	x_return_status                OUT NOCOPY VARCHAR2,
	x_msg_count                    OUT NOCOPY NUMBER,
	x_msg_Data                     OUT NOCOPY VARCHAR2
);

end BIS_PMV_TIME_LEVELS_PVT;

 

/
