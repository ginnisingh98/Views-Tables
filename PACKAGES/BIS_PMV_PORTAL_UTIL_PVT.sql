--------------------------------------------------------
--  DDL for Package BIS_PMV_PORTAL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_PORTAL_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: BISPMVPS.pls 120.0 2005/06/01 14:33:23 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.4=120.0):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPMVPS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This is the utility package for Oracle Portal                     |
REM |                                                                       |
REM | HISTORY                                                               |
REM | kiprabha	02/27/03	Initial Creation                            |
REM | kiprabha	08/01/03	Hanging Related Link Cleanup                |
REM | nkishore  03/02/03	BugFix 3417849                              |
REM +=======================================================================+
*/

TYPE bis_pmv_ref_path_rec_type IS RECORD
(
ref_path VARCHAR2(100)
) ;
TYPE bis_pmv_ref_path_tbl_type IS TABLE OF bis_pmv_ref_path_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE clean_portlets
(
	 p_user_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,p_page_id in NUMBER DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,p_page_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,x_return_status  OUT NOCOPY VARCHAR2
	,x_msg_count   OUT NOCOPY NUMBER
	,x_msg_data    OUT NOCOPY VARCHAR2
	,p_function_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
) ;

PROCEDURE get_reference_paths
(
	 p_user_name       IN VARCHAR2
	,p_page_id       IN NUMBER
	,x_ref_path_tbl OUT NOCOPY BIS_PMV_PORTAL_UTIL_PVT.BIS_PMV_REF_PATH_TBL_TYPE
	,x_return_status  OUT NOCOPY VARCHAR2
        ,x_msg_count   OUT NOCOPY NUMBER
        ,x_msg_data    OUT NOCOPY VARCHAR2

) ;


--BugFix 3417849
-- OA Pages enhancement
PROCEDURE get_oa_reference_paths
(
	p_page_id       IN NUMBER
	,x_ref_path_tbl IN OUT NOCOPY BIS_PMV_PORTAL_UTIL_PVT.BIS_PMV_REF_PATH_TBL_TYPE
	,x_return_status  OUT NOCOPY VARCHAR2
        ,x_msg_count   OUT NOCOPY NUMBER
        ,x_msg_data    OUT NOCOPY VARCHAR2

) ;

-- OA Pages enhancement
FUNCTION get_oa_page_id
(
  p_page_name  IN VARCHAR2 DEFAULT NULL
 ,p_function_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
) RETURN NUMBER ;

PROCEDURE bulk_delete_schedules
(
 p_schedule_ids IN BISVIEWER.t_num
) ;

-- OA Pages : added p_page_id
PROCEDURE bulk_delete_attributes
(
 p_schedule_ids IN BISVIEWER.t_num
,p_page_id IN NUMBER
) ;

--Delete Hanging Related Links -ansingh
PROCEDURE DELETE_HANGING_RELATED_LINKS (pUserId IN NUMBER, pPlugIdArray IN BISVIEWER.t_num);

END BIS_PMV_PORTAL_UTIL_PVT;

 

/
