--------------------------------------------------------
--  DDL for Package BISVIEWER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISVIEWER" AUTHID CURRENT_USER as
/* $Header: BISVIEWS.pls 120.4 2006/02/06 00:49:15 ksadagop noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.116=120.4):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      bisviewer                                               --
--                                                                        --
--  DESCRIPTION:  Report Generate main engine.                            --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  XX-XXX-XX  XXXXXXXX   Initial creation                                --
--  11-NOV-01  aleung     initial creation                                --
--  10-MAY-02  nkishore   Added pParameters for showReport                --
--  10-OCT-02 mdamle      Added parameter for pEnableForecastGraph        --
--  16-APR-03 nkishore    Added pRespId to get_notify_rpt_url bug 2833251 --
--  27-JUN-03 rcmuthuk    Added p_UserId to get_notify_rpt_url bug 2810397--
--  07-JUN-03 gsanap      Added p_NextExtraViewBy to drilldown bug 3007145--
--  28-JAN-04 nkishore    BugFix 3075441                                  --
--  20-APR-04 nbarik      Enh 3378782 - Parameter Validation              --
--  13-Oct-04 ugodavar    added pMaxResultSetSize & pOutputFormat         --
--  18-Jan-05 smargand    Enh #4031345 Report XML definition              --
--  05-Jan-06 ugodavar    bug.fix.4922183, added pPrevBCInfo              --
----------------------------------------------------------------------------

  type t_num is table of number index by binary_integer;
  type t_bool is table of boolean index by binary_integer;
  type t_char is table of varchar2(32000) index by binary_integer;
  type t_date is table of date index by binary_integer;

  procedure showReport(pRegionCode       in varchar2 ,
                       pFunctionName     in varchar2 ,
                       pApplicationId    in varchar2 default NULL,
                       pSessionId        in varchar2 default NULL,
                       pUserId           in varchar2 default NULL,
                       pResponsibilityId in varchar2 default NULL,
                       pFirstTime        in number default 1,
                       pHideParm         in varchar2 default 'false',
                       pHideGraph        in varchar2 default 'false',
                       pHideTable        in varchar2 default 'false',
                       pHideRinfo        in varchar2 default 'false',
                       pSortInfo         in varchar2 default NULL,
                       pMode             in varchar2 default 'SHOW',
                       pPreFunctionName  in varchar2 default NULL,
                       pScheduleId       in varchar2 default NULL,
                       pRequestType      in varchar2 default 'R',
		       pFileId	       in number default null,
                       pParameterDisplayOnly in varchar2 default 'N',
                       pForceRun             in varchar2 default 'N',
                       pDisplayParameters    in varchar2 default 'Y',
                       pReportSchedule       in varchar2 default 'Y',
                       pCSVFileName in varchar2 default NULL,
                       pPageId in varchar2 default NULL,
                       pParameters in varchar2 default NULL,
		       -- mdamle 10/10/2002 - Enh# 2460903 - Forecast Graph
               	       pEnableForecastGraph  in varchar2 default NULL,
               	       -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
               	       pCustomView  in varchar2 default NULL,
                       -- Bug Fix 2997706
                       pObjectType IN VARCHAR2 DEFAULT NULL,
                       pautoRefresh IN VARCHAR2 DEFAULT NULL,
		       -- Enh Display Run Button
		       pDispRun IN VARCHAR2 DEFAULT NULL,
               -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
		       pDrillDefaultParameters IN VARCHAR2 DEFAULT NULL,
		       --ugodavar -Enahncement 3946492
	             pMaxResultSetSize IN number DEFAULT NULL,
	             pOutputFormat IN VARCHAR2 DEFAULT NULL,
                 -- nbarik - 02/08/05 - Enhancement 4120795
                 hideNav IN VARCHAR2 DEFAULT NULL,
                 tab IN VARCHAR2 DEFAULT NULL,
                 displayOnlyParameters IN VARCHAR2 DEFAULT NULL,
                 displayOnlyNoViewByParams IN VARCHAR2 DEFAULT NULL,
                 pBCFromFunctionName IN VARCHAR2 DEFAULT NULL,
                 pPrevBCInfo IN VARCHAR2 DEFAULT NULL,
                 pResetView IN VARCHAR2 DEFAULT NULL
                         );

  procedure drilldown ( pRegionCode         in  varchar2,
                        pFunctionName       in  varchar2,
                        pSessionId          in  Varchar2,
                        pUserId             in  Varchar2,
                        pResponsibilityId   in  Varchar2,
                        pCurrValue          in  varchar2,
                        pCurrLevel          in  varchar2,
                        pCurrAttCode        in  varchar2,
                        pNextLevel          in  varchar2,
                        pNextAttCode        in  varchar2,
                        pDimension          in  varchar2,
                        pYaxisView          in  varchar2,
                        pOrgParam           in  varchar2,
                        pOrgValue           in  varchar2,
                        pScheduleId         in  varchar2 default null,
                        pPageId             in  varchar2 default NULL,
                        pNextExtraViewBy    in  varchar2 default NULL  );

 procedure displayErrorMessage (p_reportTitle           in varchar2,
                                p_dimn_level_short_name in varchar2,
                                p_dimn_level_value      in varchar2,
                                p_error_no              in number,
                                pRegionCode             in varchar2 default null);

 procedure displayError (pErrorNumber        in Number,
                         pOracleErrorNo      in varchar2,
                         pOracleErrorMessage in varchar2);
 --BugFix 3075441, add p_NlsLangCode
 function get_notify_rpt_url(
                    p_measure_id                  IN   VARCHAR2,
                    p_region_code                 in   varchar2 default null,
                    p_function_name               in   varchar2 default null,
                    p_bplan_name                  IN   VARCHAR2 default null,
                    p_viewby_level_short_name     IN   VARCHAR2 default null,
                    p_Parm1Level_short_name  IN   VARCHAR2 default null, p_Parm1Value_name  IN   VARCHAR2 default null,
                    p_Parm2Level_short_name  IN   VARCHAR2 default null, p_Parm2Value_name  IN   VARCHAR2 default null,
                    p_Parm3Level_short_name  IN   VARCHAR2 default null, p_Parm3Value_name  IN   VARCHAR2 default null,
                    p_Parm4Level_short_name  IN   VARCHAR2 default null, p_Parm4Value_name  IN   VARCHAR2 default null,
                    p_Parm5Level_short_name  IN   VARCHAR2 default null, p_Parm5Value_name  IN   VARCHAR2 default null,
                    p_Parm6Level_short_name  IN   VARCHAR2 default null, p_Parm6Value_name  IN   VARCHAR2 default null,
                    p_Parm7Level_short_name  IN   VARCHAR2 default null, p_Parm7Value_name  IN   VARCHAR2 default null,
                    p_Parm8Level_short_name  IN   VARCHAR2 default null, p_Parm8Value_name  IN   VARCHAR2 default null,
                    p_Parm9Level_short_name  IN   VARCHAR2 default null, p_Parm9Value_name  IN   VARCHAR2 default null,
                    p_Parm10Level_short_name IN   VARCHAR2 default null, p_Parm10Value_name IN   VARCHAR2 default null,
                    p_Parm11Level_short_name IN   VARCHAR2 default null, p_Parm11Value_name IN   VARCHAR2 default null,
                    p_Parm12Level_short_name IN   VARCHAR2 default null, p_Parm12Value_name IN   VARCHAR2 default null,
                    p_Parm13Level_short_name IN   VARCHAR2 default null, p_Parm13Value_name IN   VARCHAR2 default null,
                    p_TimeParmLevel_short_name in varchar2 default null, p_TimeFromParmValue_name in varchar2 default null,
                    p_TimeToParmValue_name in varchar2 default null, p_resp_id in varchar2 default null, p_UserId IN VARCHAR2 default null,
                    p_NlsLangCode in varchar2 default null) return varchar2;


-- Report XML enhancement
procedure showXmlReport(reportName in varchar2 ,
                     sourceType in varchar2 default 'MDS',
                     pFunctionName in varchar2 ,
                     pApplicationId in varchar2 default NULL,
                     pSessionId    in varchar2 default NULL,
                     pUserId       in varchar2 default NULL,
                     pResponsibilityId in varchar2 default NULL,
                     pFirstTime   in number default 1,
                     pHideParm    in varchar2 default 'false',
                     pHideGraph   in varchar2 default 'false',
                     pHideTable   in varchar2 default 'false',
                     pHideRinfo   in varchar2 default 'false',
                     pSortInfo    in varchar2 default null,
                     pMode        in varchar2 default 'SHOW',
                     pPreFunctionName in varchar2 default NULL,
                     pScheduleId       in varchar2 default NULL,
                     pRequestType      in varchar2 default 'R',
		     pFileId	       in number default null,
                     pParameterDisplayOnly in varchar2 default 'N',
                     pForceRun             in varchar2 default 'N',
                     pDisplayParameters    in varchar2 default 'Y',
                     pReportSchedule       in varchar2 default 'Y',
	             pCSVFileName in varchar2 default NULL,
                     pPageId in varchar2 default NULL,
               	     pParameters in varchar2 default NULL,
		     -- mdamle 10/10/2002 - Enh# 2460903 - Forecast Graph
               	     pEnableForecastGraph  in varchar2 default NULL,
               	     -- jprabhud - 01/27/03 - Enh 2485974 Custom Views
               	     pCustomView  in varchar2 default NULL,
                     pObjectType IN VARCHAR2 DEFAULT NULL,
                     pautoRefresh IN VARCHAR2 DEFAULT NULL,
		       -- Enh Display Run Button
		     pDispRun IN VARCHAR2 DEFAULT NULL,
             -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
             pDrillDefaultParameters IN VARCHAR2 DEFAULT NULL,
             --ugodavar - 10/12/04 - Enh.3946492
             pMaxResultSetSize IN number DEFAULT NULL,
             pOutputFormat IN VARCHAR2 DEFAULT NULL
               );
end bisviewer;

 

/
