--------------------------------------------------------
--  DDL for Package BIS_PMV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_UTIL" AUTHID CURRENT_USER as
/* $Header: BISPMVUS.pls 120.3.12010000.2 2008/08/12 07:41:27 bijain ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(120.3.12000000.2=120.4):~PROD:~PATH:~FILE
-- Purpose: LOV for PM Viewer
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- aleung      7/13/01  initial creation
-- amkulkar    7/18/01  Added function to sort attributecodes based on their lengths
-- mdamle     12/12/01  Added getParameterValue
-- mdamle     12/19/01  Added getDefaultResponsibility
-- nbarik     03/09/02  Bug Fix 2503143 Added getICXCurrentDateTime
-- nbarik     01/10/03  Enhancement : 2638594 - Portlet Builder
--                      Added function getRegionApplicationId
-- nkishore   04/25/03  BugFix 2823330 Added Get_Last_Refresh_Date
-- ansingh    06/09/03  BugFix 2995675 Staling of RL Portlets based on PlugId
-- nbarik     08/21/03  Bug Fix 3099831 - Added hasfunctionAccess
-- mdamle     08/04/04  Added getRegionDataSourceType
-- ---------   -------  ------------------------------------------
type lob_varchar_pieces is table of varchar2(32000) index by binary_integer;
g_db_nls_lang    varchar2(200) := userenv('LANGUAGE');
g_db_charset     varchar2(200) := substr(g_db_nls_lang, instr(g_db_nls_lang, '.')+1);

function readFndLobs (pFileId in number) return lob_varchar_pieces;

procedure sortAttributeCode
(p_attributeCode_tbl    in OUT   NOCOPY BISVIEWER.t_char
,p_attributeValue_tbl   in OUT   NOCOPY BISVIEWER.t_char
,x_return_status        OUT      NOCOPY VARCHAR2
,x_msg_count            OUT      NOCOPY NUMBER
,x_msg_data             OUT      NOCOPY VARCHAR2
);

procedure getCurrentDateTime (x_current_date_time out NOCOPY varchar2,
                              x_current_date out NOCOPY varchar2,
                              x_current_hour out NOCOPY varchar2,
                              x_current_minute out NOCOPY varchar2);

--Bug Fix 2503143 nbarik 03/sep/2002
procedure getICXCurrentDateTime( p_icx_date_format IN VARCHAR2,
                                 x_current_date_time OUT NOCOPY VARCHAR2,
                                 x_current_date OUT NOCOPY VARCHAR2,
                                 x_current_hour OUT NOCOPY VARCHAR2,
                                 x_current_minute OUT NOCOPY VARCHAR2);

PROCEDURE RETRIEVE_DATA
( document_id           IN       NUMBER
  ,document              IN OUT   NOCOPY VARCHAR2
);

function getAppendTitle(pRegionCode in varchar2) return varchar2;
procedure getReportTitle
(pFunctionName		IN	VARCHAR2
,pRegionCode		IN	VARCHAR2	DEFAULT NULL
,pRegionName		IN	VARCHAR2	DEFAULT NULL
,xTitleString		OUT	NOCOPY VARCHAR2
,xBrowserTitle          OUT     NOCOPY VARCHAR2
);

function getHierarchyElementId(pElementShortName   in varchar2,
                               pDimensionShortNAme in varchar2) return varchar2;

function getDimensionForAttribute(pAttributeCode in varchar2,
                                  pRegionCode    in varchar2) return varchar2;

function getAttributeForDimension(pDimension     in varchar2,
                                  pRegionCode    in varchar2) return varchar2;

function encode (p_url     in varchar2,
                 p_charset in varchar2 default null) return varchar2;

function decode1 (p_url     in varchar2,
                 p_charset in varchar2 default null) return varchar2;

-- mdamle 11/08/2001
function getReportRegion(pFunctionName IN VARCHAR2) return varchar2;

-- mdamle 12/05/01
function getFormattedDate(pInputDate in date, pFormatMask in varchar2) return varchar2;

-- mdamle 12/12/01
function getParameterValue(pParameters IN VARCHAR2, pParameterKey IN VARCHAR2) return varchar2;

-- mdamle 12/19/2001
function getDefaultResponsibility(pUserId 	in varchar2
				, pFunctionName	in varchar2
				, pCheckPMVSpecific in varchar2 default 'N') return varchar2;

procedure stale_portlet(pUserId in varchar2,
                        pFunctionName in varchar2,
			pPlugId in varchar2 default null);
procedure update_portlets_bypage(p_Page_Id in varchar2);
function get_render_type
(p_region_code in varchar2
,p_user_id     in varchar2
,p_responsibility_id in varchar2)
return varchar2;

-- mdamle 10/31/2002 - Bug#2560743 - Use previous page parameters for linked page
function getPortalPageId(pPageName in varchar2) return number;

-- nbarik 01/10/03 - Portlet Builder
FUNCTION getRegionApplicationId(pRegionCode IN VARCHAR2) RETURN NUMBER;

PROCEDURE stale_portlet_by_RefPath (pReferencePath IN VARCHAR2);

--BugFix 2995675: ansingh
PROCEDURE STALE_PORTLET_BY_PLUGID(pPlugId IN VARCHAR2);

PROCEDURE SETUP_BIND_VARIABLES
(p_bind_variables in varchar2,
 x_bind_var_tbl  out NOCOPY BISVIEWER.t_char);


--This api has been deprecated, But to be on the safer side has not been deleted.
--BugFix 2823330 Get lastrefreshDate
FUNCTION GET_LAST_REFRESH_DATE(pObjectType varchar2, pFunctionName in varchar2) return varchar2;
FUNCTION GET_LAST_REFRESH_DATE(pObjectType varchar2, pFunctionName in varchar2,pRFUrl in varchar2) return varchar2;

--This api has been deprecated, But to be on the safer side has not been deleted.
FUNCTION GET_LAST_REFRESH_DATE_URL(pObjectType in varchar2, pFunctionName in varchar2) return varchar2;
FUNCTION GET_LAST_REFRESH_DATE_URL(pObjectType in varchar2, pFunctionName in varchar2,pRFUrl in varchar2) return varchar2;
-- nbarik 08/21/03 - Bug Fix 3099831
FUNCTION hasFunctionAccess(pUserId IN VARCHAR2, pFunctionName IN VARCHAR2, pPMVSpecific IN VARCHAR2) RETURN VARCHAR2;

--serao-09/05-bug3122867
PROCEDURE bis_run_function(
               pApplication_id IN VARCHAR2,
               pResponsibility_id IN VARCHAR2,
               pSecurity_group_id IN VARCHAR2,
               pFunction_id IN VARCHAR2,
               pParameters IN VARCHAR2 DEFAULT NULL
);

-- nbarik 03/01/2004
-- udua 07/25/2005 - Changed API name and behavior.
FUNCTION getParamPortletFuncName(pPageFunctionName IN VARCHAR2) RETURN VARCHAR2;
-- nbarik 03/01/2004
FUNCTION getDocumentID(pFullPathName VARCHAR2) RETURN NUMBER;
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
FUNCTION getRoleIds(pPrivileges IN VARCHAR2) RETURN BISVIEWER.t_char;
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
PROCEDURE getDelegations(
    pRoleIdsTbl IN BISVIEWER.t_char
  , pParamName  IN VARCHAR2
  , pParameterView IN VARCHAR2
  , pAsOfDate   IN DATE
  , xDelegatorIdTbl OUT NOCOPY BISVIEWER.t_char
  , xDelegatorValueTbl OUT NOCOPY BISVIEWER.t_char
);

--=============================================================================
-- gbhaloti 05/25/04 Generic Report Designer
FUNCTION getPortletType(pType IN VARCHAR2, pParameters IN VARCHAR2) RETURN VARCHAR2;

--=============================================================================
-- gbhaloti 05/25/04 Generic Report Designer
FUNCTION getPortletTypeCode(pType IN VARCHAR2, pParameters IN VARCHAR2) RETURN CHAR;

--=============================================================================
-- gbhaloti 05/25/04 Generic Report Designer
FUNCTION getRegionCode(pType IN VARCHAR2, pParameters IN VARCHAR2, webHtmlCall IN VARCHAR2, functionName IN VARCHAR2) RETURN CHAR;
--=============================================================================
-- gbhaloti 05/25/04 Generic Report Designer
FUNCTION getRegionApplicationName(pRegionCode IN VARCHAR2) RETURN VARCHAR2;
--==============================================================================

-- mdamle 08/04/2004
FUNCTION getRegionDataSourceType(pRegionCode IN VARCHAR2) RETURN VARCHAR2;

-- msaran 08/31/2005 eliminate mod_plsql
PROCEDURE readBinaryFile (p_file_id IN VARCHAR2, content_type OUT NOCOPY VARCHAR2, data OUT NOCOPY BLOB);

end BIS_PMV_UTIL;

/
