--------------------------------------------------------
--  DDL for Package BIS_PMV_PMF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_PMF_PVT" AUTHID CURRENT_USER as
/* $Header: BISVPMPS.pls 120.1 2005/09/23 03:57:29 msaran noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.11=120.1):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_PMV_PMF_PVT
--                                                                        --
--  DESCRIPTION:  Target related APIs for PMV
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  10/17/00   amkulkar   Initial creation                                --
--  4/16/2003  nkishore    Added pRespId to get_notify_rpt_url bug 2833251--
--  6/27/03    rcmuthuk    Added p_UserId to get_notify_rpt_url bug 2810397--
--  1/28/2004  nkishore    BugFix 3075441                                  --
----------------------------------------------------------------------------

--jprabhud enhancement#2184054
G_DIMENSION_LEVEL varchar2(20) := 'DIMENSION LEVEL';
G_DIM_LEVEL_SINGLE_VALUE varchar2(30) := 'DIM LEVEL SINGLE VALUE';
G_VIEWBY_PARAMETER varchar2(20) := 'VIEWBY PARAMETER';


FUNCTION GET_TARGET
(pSource		IN	VARCHAR2
,pSessionId		IN	VARCHAR2
,pRegionCode		IN	VARCHAR2
,pFunctionName		IN	VARCHAR2
,pMeasureShortName 	IN	VARCHAR2	DEFAULT NULL
,pPlanId		IN	VARCHAR2	DEFAULT NULL
,pDimension1		IN	VARCHAR2	DEFAULT NULL
,pDim1Level		IN      VARCHAR2	DEFAULT NULL
,pDim1LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension2		IN	VARCHAR2	DEFAULT NULL
,pDim2Level		IN      VARCHAR2	DEFAULT NULL
,pDim2LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension3		IN	VARCHAR2	DEFAULT NULL
,pDim3Level		IN      VARCHAR2	DEFAULT NULL
,pDim3LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension4		IN	VARCHAR2	DEFAULT NULL
,pDim4Level		IN      VARCHAR2	DEFAULT NULL
,pDim4LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension5		IN	VARCHAR2	DEFAULT NULL
,pDim5Level		IN      VARCHAR2	DEFAULT NULL
,pDim5LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension6		IN	VARCHAR2	DEFAULT NULL
,pDim6Level		IN      VARCHAR2	DEFAULT NULL
,pDim6LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension7		IN	VARCHAR2	DEFAULT NULL
,pDim7Level		IN      VARCHAR2	DEFAULT NULL
,pDim7LevelValue	IN	VARCHAR2	DEFAULT NULL
)
RETURN VARCHAR2;
FUNCTION GETTOTALDIMVALUE
(pDimSource 		IN 	VARCHAR2,
 pDimension 		IN 	VARCHAR2 DEFAULT NULL,
 pDimensionLevel 	IN 	VARCHAR2
)
RETURN VARCHAR2;
Function GETTOTALDIMlEVELNAME
(pDimShortName IN VARCHAR2
,pSource      IN VARCHAR2
)
RETURN VARCHAR2;
PROCEDURE TOLERANCE_TEST
(p_target_value		IN	VARCHAR2
,p_actual_value		IN	VARCHAR2
,p_range1_high	        IN	VARCHAR2
,p_range1_low		IN	VARCHAR2
,x_tolerance		OUT	NOCOPY VARCHAR2
);

--BugFix 3075441, add p_NlsLangCode
FUNCTION GET_NOTIFY_RPT_URL(
 p_measure_id                  IN   VARCHAR2
,p_region_code                 in   varchar2 default null
,p_function_name               in   varchar2 default null
,p_bplan_name                  IN   VARCHAR2 default null
,p_viewby_level_short_name     IN   VARCHAR2 default null
,p_Parm1Level_short_name  IN   VARCHAR2 default null
,p_Parm1Value_name  IN   VARCHAR2 default null
,p_Parm2Level_short_name  IN   VARCHAR2 default null
,p_Parm2Value_name  IN   VARCHAR2 default null
,p_Parm3Level_short_name  IN   VARCHAR2 default null
,p_Parm3Value_name  IN   VARCHAR2 default null
,p_Parm4Level_short_name  IN   VARCHAR2 default null
,p_Parm4Value_name  IN   VARCHAR2 default null
,p_Parm5Level_short_name  IN   VARCHAR2 default null
,p_Parm5Value_name  IN   VARCHAR2 default null
,p_Parm6Level_short_name  IN   VARCHAR2 default null
,p_Parm6Value_name  IN   VARCHAR2 default null
,p_Parm7Level_short_name  IN   VARCHAR2 default null
,p_Parm7Value_name  IN   VARCHAR2 default null
,p_Parm8Level_short_name  IN   VARCHAR2 default null
,p_Parm8Value_name  IN   VARCHAR2 default null
,p_Parm9Level_short_name  IN   VARCHAR2 default null
,p_Parm9Value_name  IN   VARCHAR2 default null
,p_Parm10Level_short_name IN   VARCHAR2 default null
,p_Parm10Value_name IN   VARCHAR2 default null
,p_Parm11Level_short_name IN   VARCHAR2 default null
,p_Parm11Value_name IN   VARCHAR2 default null
,p_Parm12Level_short_name IN   VARCHAR2 default null
,p_Parm12Value_name IN   VARCHAR2 default null
,p_Parm13Level_short_name IN   VARCHAR2 default null
,p_Parm13Value_name IN   VARCHAR2 default null
,p_TimeParmLevel_short_name in varchar2 default null
,p_TimeFromParmValue_name in varchar2 default null
,p_TimeToParmValue_name in varchar2 default null
,p_resp_id in varchar2 default null
,p_UserId IN VARCHAR2 default null
,p_NlsLangCode IN VARCHAR2 default null)
RETURN VARCHAR2;

--msaran:4415814 - return report run url, to handle ssl
PROCEDURE GET_NOTIFY_RPT_RUN_URL(
 p_measure_id                  IN   VARCHAR2
,p_region_code                 in   varchar2 default null
,p_function_name               in   varchar2 default null
,p_bplan_name                  IN   VARCHAR2 default null
,p_viewby_level_short_name     IN   VARCHAR2 default null
,p_Parm1Level_short_name  IN   VARCHAR2 default null
,p_Parm1Value_name  IN   VARCHAR2 default null
,p_Parm2Level_short_name  IN   VARCHAR2 default null
,p_Parm2Value_name  IN   VARCHAR2 default null
,p_Parm3Level_short_name  IN   VARCHAR2 default null
,p_Parm3Value_name  IN   VARCHAR2 default null
,p_Parm4Level_short_name  IN   VARCHAR2 default null
,p_Parm4Value_name  IN   VARCHAR2 default null
,p_Parm5Level_short_name  IN   VARCHAR2 default null
,p_Parm5Value_name  IN   VARCHAR2 default null
,p_Parm6Level_short_name  IN   VARCHAR2 default null
,p_Parm6Value_name  IN   VARCHAR2 default null
,p_Parm7Level_short_name  IN   VARCHAR2 default null
,p_Parm7Value_name  IN   VARCHAR2 default null
,p_Parm8Level_short_name  IN   VARCHAR2 default null
,p_Parm8Value_name  IN   VARCHAR2 default null
,p_Parm9Level_short_name  IN   VARCHAR2 default null
,p_Parm9Value_name  IN   VARCHAR2 default null
,p_Parm10Level_short_name IN   VARCHAR2 default null
,p_Parm10Value_name IN   VARCHAR2 default null
,p_Parm11Level_short_name IN   VARCHAR2 default null
,p_Parm11Value_name IN   VARCHAR2 default null
,p_Parm12Level_short_name IN   VARCHAR2 default null
,p_Parm12Value_name IN   VARCHAR2 default null
,p_Parm13Level_short_name IN   VARCHAR2 default null
,p_Parm13Value_name IN   VARCHAR2 default null
,p_TimeParmLevel_short_name in varchar2 default null
,p_TimeFromParmValue_name in varchar2 default null
,p_TimeToParmValue_name in varchar2 default null
,p_resp_id in varchar2 default null
,p_UserId IN VARCHAR2 default null
,p_NlsLangCode IN VARCHAR2 default null
--msaran:4415814 - added out params from fileId and reportURL
,vFileId OUT NOCOPY NUMBER
,vReportURL OUT NOCOPY VARCHAR2
);

--serao 02/10/02 - added as replacement for get_target
FUNCTION GET_TARGET_NEW
(pSource		IN      VARCHAR2
,pSessionId		IN	VARCHAR2
,pRegionCode		IN	VARCHAR2
,pFunctionName		IN	VARCHAR2
,pMeasureShortName 	IN	VARCHAR2	DEFAULT NULL
,pPlanId		IN	VARCHAR2	DEFAULT NULL
,pTarget_level_id IN NUMBER DEFAULT NULL
,pDimension1		IN	VARCHAR2	DEFAULT NULL
,pDim1Level		IN      VARCHAR2	DEFAULT NULL
,pDim1LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension2		IN	VARCHAR2	DEFAULT NULL
,pDim2Level		IN      VARCHAR2	DEFAULT NULL
,pDim2LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension3		IN	VARCHAR2	DEFAULT NULL
,pDim3Level		IN      VARCHAR2	DEFAULT NULL
,pDim3LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension4		IN	VARCHAR2	DEFAULT NULL
,pDim4Level		IN      VARCHAR2	DEFAULT NULL
,pDim4LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension5		IN	VARCHAR2	DEFAULT NULL
,pDim5Level		IN      VARCHAR2	DEFAULT NULL
,pDim5LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension6		IN	VARCHAR2	DEFAULT NULL
,pDim6Level		IN      VARCHAR2	DEFAULT NULL
,pDim6LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension7		IN	VARCHAR2	DEFAULT NULL
,pDim7Level		IN      VARCHAR2	DEFAULT NULL
,pDim7LevelValue	IN	VARCHAR2	DEFAULT NULL
) RETURN VARCHAR2;

END BIS_PMV_PMF_PVT;

 

/
