--------------------------------------------------------
--  DDL for Package BIS_PMV_PORTAL_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_PORTAL_UTIL_PUB" AUTHID CURRENT_USER as
/* $Header: BISPPUTS.pls 120.0 2005/06/01 14:39:12 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.9=120.0):~PROD:~PATH:~FILE
PROCEDURE GET_RANKING_PARAMETER(
 p_page_id            IN    VARCHAR2
,p_user_id            IN    VARCHAR2
,x_ranking_param      OUT    NOCOPY VARCHAR2
,x_return_Status      OUT    NOCOPY VARCHAR2
,x_msg_count          OUT    NOCOPY NUMBER
,x_msg_data           OUT    NOCOPY VARCHAR2
);
PROCEDURE GET_TIME_LEVEL_LABEL
(p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,x_time_level_label  OUT    NOCOPY VARCHAR2
,x_return_Status     OUT    NOCOPY VARCHAR2
,x_msg_count         OUT    NOCOPY NUMBER
,x_msg_data          OUT    NOCOPY VARCHAR2
);
FUNCTION getTimeLevelLabel (
p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
) RETURN VARCHAR2;

PROCEDURE getAsOfDateAndLabel(
  pAsOfDate IN VARCHAR2,
  xAsOfDate OUT NOCOPY VARCHAR2,
  xAsOfDateLabel OUT NOCOPY VARCHAR2
) ;

PROCEDURE get_rank_level_and_num_values(
p_page_id            IN    VARCHAR2
,p_user_id            IN VARCHAR2
,p_responsibility_id IN VARCHAR2
,x_ranking_param OUT NOCOPY VARCHAR2
,x_number_values      OUT    NOCOPY NUMBER
,x_return_Status      OUT    NOCOPY VARCHAR2
,x_msg_count          OUT    NOCOPY NUMBER
,x_msg_data           OUT    NOCOPY VARCHAR2
) ;

-- jprabhud - 04/23/04 - Bug 3573468
PROCEDURE clean_portlets
(
	 p_user_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,p_page_id in NUMBER DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,p_page_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,p_function_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,x_return_status  OUT NOCOPY VARCHAR2
	,x_msg_count   OUT NOCOPY NUMBER
	,x_msg_data    OUT NOCOPY VARCHAR2
) ;


--KPI Portlet Pesonalization -ansingh
PROCEDURE GET_RANK_LEVEL_SHRT_NAME
(  p_region_code					IN  VARCHAR2,
	 x_rank_level_shrt_name	OUT NOCOPY VARCHAR2,
	 x_return_status        OUT NOCOPY VARCHAR2,
	 x_msg_count            OUT NOCOPY NUMBER,
	 x_msg_data             OUT NOCOPY VARCHAR2
);


END BIS_PMV_PORTAL_UTIL_PUB;

 

/
