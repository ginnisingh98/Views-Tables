--------------------------------------------------------
--  DDL for Package BIS_TREND_PLUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TREND_PLUG" AUTHID CURRENT_USER as
/* $Header: BISTRNDS.pls 120.1 2006/02/02 02:08:02 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.49=120.1):~PROD:~PATH:~FILE

PROCEDURE get_graph_from_url
  (p_trend_type           IN VARCHAR2
    , p_report_Fn_URL     IN VARCHAR2
    , x_img_html          OUT NOCOPY VARCHAR2
    );

procedure Show(p_session_id pls_integer default NULL,
               p_plug_id    pls_integer default NULL,
               p_display_name  varchar2 default NULL,
               p_delete     varchar2 default 'N');

procedure setTableStyles;

procedure view_report_from_portlet(pRegionCode in varchar2,
                                   pFunctionName in varchar2,
                                   pScheduleId in number,
                                   pPageId IN VARCHAR2 DEFAULT NULL,
                                   --Bug Fix 2997706
                                   pObjectType IN VARCHAR2 DEFAULT NULL,
                                   pResponsibilityId IN VARCHAR2 DEFAULT NULL);

procedure showPortletStatus(p_report_available number, last_upd date);

-- mdamle 10/30/01 - Converted plsql customize page to jsp
-- Enh#3690747: Portlet Personalization -ansingh
procedure customizePortlet (	 pResponsibilityId	IN	VARCHAR2 default NULL
				,pSessionId		IN	VARCHAR2 default NULL
				,Region_Code  		IN	VARCHAR2 default NULL
				,Function_Name		IN	VARCHAR2 default NULL
				,pUserId 		IN	VARCHAR2 default NULL
				,pPlugId 		IN	VARCHAR2 default NULL
				,pScheduleId 		IN	VARCHAR2 default NULL
				,pFileId 		IN	VARCHAR2 default NULL
    				,pScheduleOverride	IN 	varchar2 default 'N'
				,pShowPortletSettings IN VARCHAR2 DEFAULT NULL
				,pMsrId IN VARCHAR2 DEFAULT NULL
				,pComponentType IN VARCHAR2 DEFAULT NULL
				,pIsPrintable IN VARCHAR2 DEFAULT NULL
				,pReturnURL IN VARCHAR2 DEFAULT NULL
);


PROCEDURE initialiseRLPortlet (
    pUserID IN NUMBER,
    pReferencePath IN VARCHAR2,
        x_plug_id OUT NOCOPY NUMBER
) ;

procedure invokeBISRunFunction
(function_id           in number
,pFunctionName         in VARCHAR2
,pWebHtmlCall          IN VARCHAR2
,user_id               in varchar2 default null
,responsibility_id     in varchar2 default null
,responsibility_app_id in varchar2 default null
,session_id            in varchar2 default null
,sec_grp_id            in varchar2 default null
-- jprabhud 03/04/2003 - Refresh Portal Page
,pSourcePageId 	       in number default -1
,pParameters             IN VARCHAR2 DEFAULT NULL

);
procedure invokeRFFunction
(function_id           in number
,user_id               in varchar2 default null
,responsibility_id     in varchar2 default null
,responsibility_App_id in varchar2 default null
,session_id            in varchar2 default null
-- mdamle 10/29/2002 Bug#2560743 - Use previous page parameters for linked page
,sec_grp_id            in varchar2 default null
-- jprabhud 03/04/2003 - Refresh Portal Page
,pSourcePageId 	 	in number default -1
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
,pDrillDefaultParameters IN VARCHAR2 DEFAULT NULL
);

PROCEDURE checkUsercustomizeRLPortlet (
  pUserId In NUMBER,
  pPlugId IN NUMBER,
  xCustomised OUT NOCOPY NUMBER
);


-- mdamle 11/1/2002 - Bug#2649477 - Support for ICX Patch
procedure getRespInfo(	pUserId 	in number
		      , pRespId		in number
		      , pRespAppId 	out NOCOPY number
		      , pSecGrpId       out NOCOPY number);

-- mdamle 11/1/2002 - Bug#2649477 - Support for ICX Patch
function getFunctionId (pFunctionName varchar2) return number;

PROCEDURE processLinkedPage(
         pSourcePageId 	 	in varchar2
				,pDestFunctionId 	in number
        ,pSessionId IN VARCHAR2
        ,pUserId IN NUMBER
        ,xParamRegionCode OUT NOCOPY VARCHAR2
        ,xParamFunctionName OUT NOCOPY VARCHAR2
        , xParamGroup  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type
        , xSourcePageId OUT NOCOPY NUMBER
        , xDestPageId OUT NOCOPY NUMBER
         -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
        , x_DrillDefaultParameters OUT NOCOPY VARCHAR2
) ;
-- mdamle 10/31/2002 - Bug#2560743 - Use previous page parameters for linked page
--jprabhud 11/13/03 - Bug 3253597
procedure launchLinkedPage(	 pSourcePageId 	 	in varchar2 --number
				,pDestFunctionId 	in number
				,pRespId     		in varchar2 default null
				,pRespAppId		in varchar2 default null
				,pSecGrpId           	in varchar2 default null);

-- jprabhud 03/04/2003 - Refresh Portal Page
function getFunctionName (pFunctionId number) return varchar2;

-- gsanap 4/14/2003 - added this to get user_function_name if prompt is null
function getUserFunctionName (pFunctionId number) return varchar2;

PROCEDURE processPageFromReport(
    pFunctionName In VARCHAR2
   ,pDestFunctionId IN NUMBER
   ,pSessionId IN VARCHAR2
   ,pUserId IN NUMBER
   , xDestPageID OUT NOCOPY NUMBER
   , xParamRegionCode OUT NOCOPY VARCHAR2
   , xParamFunctionName OUT NOCOPY VARCHAR2
   ,xParamGroup  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type
   -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
   ,x_DrillDefaultParameters OUT NOCOPY VARCHAR2
   ,x_return_status OUT NOCOPY varchar2
   ,x_msg_count     OUT NOCOPY number
   ,x_msg_data      OUT NOCOPY varchar2
);

PROCEDURE launchPageFromReport(
  pFunctionName IN VARCHAR2
  ,pDestFunctionId 	in number
	,pRespId     		in varchar2 default null
	,pRespAppId		in varchar2 default null
	,pSecGrpId           	in varchar2 default null
) ;

PROCEDURE checkAndSetRL (
  pUserId IN VARCHAR2,
  pPlugId IN VARCHAR2,
  pFunctionName IN VARCHAR2
) ;

end bis_trend_plug;

 

/
