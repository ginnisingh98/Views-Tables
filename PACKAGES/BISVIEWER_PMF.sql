--------------------------------------------------------
--  DDL for Package BISVIEWER_PMF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISVIEWER_PMF" AUTHID CURRENT_USER as
/* $Header: BISRGPMS.pls 115.11 2002/11/19 18:30:18 kiprabha noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE

Function Get_Target (pMeasureShortName     Varchar2,
                     pDimension1Level      Varchar2 default NULL,
                     pDimension2Level      Varchar2 default NULL,
                     pDimension3Level      Varchar2 default NULL,
                     pDimension4Level      Varchar2 default NULL,
                     pDimension5Level      Varchar2 default NULL,
                     pDimension6Level      Varchar2 default NULL,
                     pDimension7Level      Varchar2 default NULL,
                     pDimension1           Varchar2 default NULL,
                     pDimension2           Varchar2 default NULL,
                     pDimension3           Varchar2 default NULL,
                     pDimension4           Varchar2 default NULL,
                     pDimension5           Varchar2 default NULL,
                     pDimension6           Varchar2 default NULL,
                     pDimension7           Varchar2 default NULL,
                     pDimension1LevelValue Varchar2 default NULL,
                     pDimension2LevelValue Varchar2 default NULL,
                     pDimension3LevelValue Varchar2 default NULL,
                     pDimension4LevelValue Varchar2 default NULL,
                     pDimension5LevelValue Varchar2 default NULL,
                     pDimension6LevelValue Varchar2 default NULL,
                     pDimension7LevelValue Varchar2 default NULL,
                     pPlanId               Varchar2) return VARCHAR2;


FUNCTION Get_Target_For_Level
	( p_MEASURE_SHORT_NAME     VARCHAR2
	, p_DIMENSION1_LEVEL       VARCHAR2
	, p_DIMENSION2_LEVEL       VARCHAR2
	, p_DIMENSION3_LEVEL       VARCHAR2
	, p_DIMENSION4_LEVEL       VARCHAR2
	, p_DIMENSION5_LEVEL       VARCHAR2
	, p_DIMENSION6_LEVEL       VARCHAR2
	, p_DIMENSION7_LEVEL       VARCHAR2
	, p_DIMENSION1_LEVEL_VALUE VARCHAR2
	, p_DIMENSION2_LEVEL_VALUE VARCHAR2
	, p_DIMENSION3_LEVEL_VALUE VARCHAR2
	, p_DIMENSION4_LEVEL_VALUE VARCHAR2
	, p_DIMENSION5_LEVEL_VALUE VARCHAR2
	, p_DIMENSION6_LEVEL_VALUE VARCHAR2
	, p_DIMENSION7_LEVEL_VALUE VARCHAR2
	, p_PLAN                   VARCHAR2
	) RETURN VARCHAR2;


FUNCTION Get_Target_Value
	( p_TARGET_LEVEL_ID        VARCHAR2
	, p_DIMENSION1_LEVEL_VALUE VARCHAR2
	, p_DIMENSION2_LEVEL_VALUE VARCHAR2
	, p_DIMENSION3_LEVEL_VALUE VARCHAR2
	, p_DIMENSION4_LEVEL_VALUE VARCHAR2
	, p_DIMENSION5_LEVEL_VALUE VARCHAR2
	, p_DIMENSION6_LEVEL_VALUE VARCHAR2
	, p_DIMENSION7_LEVEL_VALUE VARCHAR2
	, p_PLAN                   VARCHAR2
	) RETURN VARCHAR2;


FUNCTION Get_LEVEL_ID ( p_Level_Short_Name IN VARCHAR2 ) RETURN NUMBER ;



procedure toleranceTest(pTargetLowHigh in varchar2,
                        pValue         in varchar2,
						pTarget        out NOCOPY number,
						pToleranceFlag out NOCOPY varchar2);


Function Schedule_Alert_Link
   (pMeasureShortName     Varchar2,
    pOrgLevel             Varchar2,
    pTimeLevel            Varchar2,
    pDimension1Level      Varchar2 default NULL,
    pDimension2Level      Varchar2 default NULL,
    pDimension3Level      Varchar2 default NULL,
    pDimension4Level      Varchar2 default NULL,
    pDimension5Level      Varchar2 default NULL,
    pDimension1           Varchar2 default NULL,
    pDimension2           Varchar2 default NULL,
    pDimension3           Varchar2 default NULL,
    pDimension4           Varchar2 default NULL,
    pDimension5           Varchar2 default NULL,
    pOrgLevelValue        Varchar2 ,
    pTimeLevelValue       Varchar2 ,
    pDimension1LevelValue Varchar2 default NULL,
    pDimension2LevelValue Varchar2 default NULL,
    pDimension3LevelValue Varchar2 default NULL,
    pDimension4LevelValue Varchar2 default NULL,
    pDimension5LevelValue Varchar2 default NULL,
    pPlanId               Varchar2) Return VARCHAR2;


FUNCTION Schedule_Alert_URL
( p_MEASURE_SHORT_NAME     VARCHAR2
, p_ORG_LEVEL              VARCHAR2
, p_TIME_LEVEL             VARCHAR2
, p_DIMENSION1_LEVEL       VARCHAR2
, p_DIMENSION2_LEVEL       VARCHAR2
, p_DIMENSION3_LEVEL       VARCHAR2
, p_DIMENSION4_LEVEL       VARCHAR2
, p_DIMENSION5_LEVEL       VARCHAR2
, p_ORG_LEVEL_VALUE        VARCHAR2
, p_TIME_LEVEL_VALUE       VARCHAR2
, p_DIMENSION1_LEVEL_VALUE VARCHAR2
, p_DIMENSION2_LEVEL_VALUE VARCHAR2
, p_DIMENSION3_LEVEL_VALUE VARCHAR2
, p_DIMENSION4_LEVEL_VALUE VARCHAR2
, p_DIMENSION5_LEVEL_VALUE VARCHAR2
, p_PLAN                   VARCHAR2
) RETURN VARCHAR2;


procedure scheduleReports(
    pRegionCode         in  varchar2,
    pFunctionName       in  varchar2,
    pUserId             in  varchar2,
    pSessionId          in  varchar2,
    pResponsibilityId   in  varchar2,
    pReportTitle        in  varchar2 default NULL,
    pApplicationId      in  varchar2 default NULL,
    pParmPrint          in  varchar2 default NULL,
    pRequestType        in  varchar2 default 'R',
    pPlugId             in  varchar2 default NULL,
    pGraphType          in  varchar2 default NULL
);

Function Schedule_Reports_Link
   (pRegionCode           Varchar2,
    pFunctionName         Varchar2,
    pApplicationId        Varchar2 default NULL,
    pOrgLevel             Varchar2,
    pTimeLevel            Varchar2,
    pDimension1Level      Varchar2 default NULL,
    pDimension2Level      Varchar2 default NULL,
    pDimension3Level      Varchar2 default NULL,
    pDimension4Level      Varchar2 default NULL,
    pDimension5Level      Varchar2 default NULL,
    pDimension1           Varchar2 default NULL,
    pDimension2           Varchar2 default NULL,
    pDimension3           Varchar2 default NULL,
    pDimension4           Varchar2 default NULL,
    pDimension5           Varchar2 default NULL,
    pOrgLevelValue        Varchar2 ,
    pTimeLevelValue       Varchar2 ,
    pDimension1LevelValue Varchar2 default NULL,
    pDimension2LevelValue Varchar2 default NULL,
    pDimension3LevelValue Varchar2 default NULL,
    pDimension4LevelValue Varchar2 default NULL,
    pDimension5LevelValue Varchar2 default NULL,
    pPlanId               Varchar2,
    pViewByLevel          Varchar2) Return VARCHAR2;

   function  getTargetParm(Display in varchar2,
                           Measure in varchar2,
                           PlanId in varchar2,
                           Dim1Level in varchar2 default null,
                           Dim2Level in varchar2 default null,
                           Dim3Level in varchar2 default null,
                           Dim4Level in varchar2 default null,
                           Dim5Level in varchar2 default null,
                           Dim6Level in varchar2 default null,
                           Dim7Level in varchar2 default null,
                           Dim1LevelValue in varchar2 default null,
                           Dim2LevelValue in varchar2 default null,
                           Dim3LevelValue in varchar2 default null,
                           Dim4LevelValue in varchar2 default null,
                           Dim5LevelValue in varchar2 default null,
                           Dim6LevelValue in varchar2 default null,
                           Dim7LevelValue in varchar2 default null) return varchar2;

procedure getTotalDimValue(pDimSource in varchar2,
                           pDimension in varchar2 default null,
                           pDimensionLevel in out NOCOPY varchar2,
                           pDimensionLevelValue out NOCOPY varchar2);

function getTotalDimLevelName(pDimShortName IN VARCHAR2
                             ,pSource       IN VARCHAR2)
RETURN VARCHAR2;

end bisviewer_pmf;

 

/
