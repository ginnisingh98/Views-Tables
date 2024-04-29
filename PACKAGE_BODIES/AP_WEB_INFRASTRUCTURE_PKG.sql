--------------------------------------------------------
--  DDL for Package Body AP_WEB_INFRASTRUCTURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_INFRASTRUCTURE_PKG" AS
/* $Header: apwinfrb.pls 120.11 2005/10/02 20:15:50 albowicz ship $ */

-- Global variables
c_imagePath varchar2(100) := null;
c_HTMLPath varchar2(100) := null;
c_CSSPath varchar2(100) := null;
c_dcdName  varchar2(100):= null;
c_langCode varchar2(100):= null;
c_dateFormat varchar2(100):=null;
c_enableNewTaxFields	BOOLEAN := FALSE;


/*
Written by:
  Quan Le
Purpose:
  To initialize all data for the current session.
Output:
  None
Input Output:
  None
Assumption:
  None.
Date:
  4/10/99
*/
PROCEDURE initAll IS
  l_debugInfo    varchar2(240) := 'Get language code';
  l_languageCode varchar2(10) ;
BEGIN
  c_imagePath := '/OA_MEDIA/';
  c_HTMLPath := '/OA_HTML/';
--  c_CSSPath := '/OA_HTML/US/';

  l_debugInfo := 'Get dcdName';
--  c_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');
  c_dcdName := rtrim(FND_WEB_CONFIG.PLSQL_AGENT, '/');  -- bug 1960936

--  Bug 3629683 : Replacing the calls to icx_sec.getID since they
--                are causing a problem in Japanese language.
--  c_langCode := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
--  c_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

   SELECT        LANGUAGE_CODE
   INTO          l_languageCode
   FROM          FND_LANGUAGES
   WHERE         INSTALLED_FLAG = 'B';

  c_langCode := nvl(icx_sec.g_language_code, l_languageCode);
  c_dateFormat := nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));

  c_enableNewTaxFields := FALSE;

-- Bug 1505282
  c_CSSPath := '/OA_HTML/' || c_langCode || '/';

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'initAll');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debugInfo);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;
END initAll;

/*
Written by:
  Quan Le
Purpose:
  To return the path by the current session.
Output:
  None
Input Output:
  None
Assumption:
  None.
Date:
  4/10/99
*/
FUNCTION getImagePath RETURN VARCHAR2
IS
BEGIN
  return c_imagePath;
END getImagePath;

FUNCTION getHTMLPath RETURN VARCHAR2
IS
BEGIN
  return c_HTMLPath;
END getHTMLPath;

FUNCTION getCSSPath RETURN VARCHAR2
IS
BEGIN
  return c_CSSPath;
END getCSSPath;

FUNCTION getDCDName RETURN VARCHAR2
IS
BEGIN
  return c_dcdName;
END getDCDName;

FUNCTION getLangCode RETURN VARCHAR2
IS
BEGIN
  return c_langCode;
END getLangCode;

FUNCTION getDateFormat RETURN VARCHAR2
IS
BEGIN
  return c_dateFormat;
END getDateFormat;

FUNCTION getEnableNewTaxFields RETURN BOOLEAN
IS
BEGIN
  return c_enableNewTaxFields;
END getEnableNewTaxFields;

PROCEDURE JumpIntoFunction(p_id			IN NUMBER,
             		   p_mode		IN VARCHAR2,
                           p_url		OUT NOCOPY VARCHAR2) IS
l_org_id	AP_WEB_DB_EXPRPT_PKG.expHdr_orgID;
l_function_code VARCHAR2(30);
l_debug_info	VARCHAR2(200);
l_item_type     VARCHAR2(100)   := 'APEXP';
l_submit_from_oie   VARCHAR2(1);

BEGIN

  ---------------------------------
  l_debug_info := 'Mode = EXPENSE REPORT';
  ---------------------------------
  IF (p_mode = 'EXPENSE REPORT') THEN

  -- for bug 1652106
  -- get org id from item attribute instead of from report header

    ---------------------------------
    l_debug_info := 'Getting ORG_ID';
    ---------------------------------
    begin
      l_org_id := WF_ENGINE.GetItemAttrNumber(l_item_type,
						p_id,
						'ORG_ID');

    exception
        when others then
          if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
            -- ORG_ID item attribute doesn't exist, need to add it
            WF_ENGINE.AddItemAttr(l_item_type, p_id, 'ORG_ID');
            IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(
                                p_id,
                                l_org_id) <> TRUE ) THEN
               l_org_id := NULL;
            END IF;

            WF_ENGINE.SetItemAttrNumber(l_item_type,
                                p_id,
                                'ORG_ID',
                                l_org_ID);
          else
            raise;
          end if;

    end;

    ---------------------------------
    l_debug_info := 'Getting SUBMIT_FROM_OIE';
    ---------------------------------
    begin
      l_submit_from_oie := WF_ENGINE.GetItemAttrText(l_item_type,
						     p_id,
						     'SUBMIT_FROM_OIE');
    exception
	when others then
	  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
	    -- SUBMIT_FROM_OIE item attribute doesn't exist, need to add it
	    WF_ENGINE.AddItemAttr(l_item_type, p_id, 'SUBMIT_FROM_OIE');
	  else
	    raise;
	  end if;

    end;

/* Bug 2694616 : Removed reference to ICX_OIE_OPEN_EXP */
    if (l_submit_from_oie <> AP_WEB_EXPENSE_WF.C_SUBMIT_FROM_OIE) then
      -----------------------------------------------
      l_debug_info := 'use ICX_AP_WEB_OPEN_EXP function';
      -----------------------------------------------
      l_function_code := 'ICX_AP_WEB_OPEN_EXP';
    end if;

  ELSIF (p_mode = 'PCARD EMP VERI') THEN
-- chiho:p-card related, ignored:
    SELECT distinct(nvl(fl.org_id,fd.org_id))
    INTO   l_org_id
    FROM   ap_expense_feed_lines_all fl,
	   ap_expense_feed_dists_all fd
    WHERE  fl.employee_verification_id = p_id
    OR     (fd.feed_line_id = fl.feed_line_id AND
	   fd.employee_verification_id = p_id);

    l_function_code := 'ICX_AP_WEB_OPEN_PCARD_TRANS';

  ELSIF (p_mode = 'PCARD MANAGER APPR') THEN
-- chiho:p-card related, ignored:
    SELECT distinct(org_id)
    INTO   l_org_id
    FROM   ap_expense_feed_dists_all
    WHERE  manager_approval_id = p_id;

    l_function_code := 'ICX_AP_WEB_OPEN_PCARD_TRANS';

  END IF;

    -----------------------------------------------
    l_debug_info := 'If OIE then strip url and append OA.jsp call';
    -----------------------------------------------
/* Bug 2694616 : Added JSP: to the url being formed. */

    if (p_mode = 'EXPENSE REPORT' and
        l_submit_from_oie = AP_WEB_EXPENSE_WF.C_SUBMIT_FROM_OIE) then
      /*
        strip url and append OA.jsp call for Expense Lines page
      */
      /* Bug 2832919 :  Added parameter retainAM=Y */
      /* Bug 4082366 :  Added parameter OIERefreshAM=Y */
      p_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=OIEMAINPAGE'
                  ||'&' || 'akRegionApplicationId=200'
                  ||'&' || 'CurrentPage=OIEConfirmPage'
                  ||'&' || 'retainAM=Y'
                  ||'&' || 'OIERefreshAM=Y'
                  ||'&' || 'startFrom=WF'
                  ||'&' || 'ReportHeaderId='||p_id
                  ||'&' || 'NtfId=-' || '&' || '#NID-';
    else
    -----------------------------------------------
    l_debug_info := 'Calling ICX JumpIntoFunction';
    -----------------------------------------------
    p_url := ICX_SEC.jumpIntoFunction(
		 	p_application_id     => 200,
			p_function_code	     => l_function_code,
			p_parameter1	     => to_char(p_id),
			p_parameter2	     => p_mode,
                        p_parameter11        => to_char(l_org_id));

    end if;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INFRASTRUCTURE_PKG', 'JumpIntoFunction',
                     'APEXP', to_char(p_id), to_char(0), l_debug_info);
    raise;
END JumpIntoFunction;

PROCEDURE ICXSetOrgContext(p_session_id	IN VARCHAR2,
			   p_org_id	IN VARCHAR2) IS
l_debug_info 	VARCHAR2(200);
BEGIN

  ----------------------------------------------
  l_debug_info := 'Calling ICX Set_Org_context';
  ----------------------------------------------
  icx_sec.set_org_context(p_session_id, icx_call.decrypt(p_org_id));

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INFRASTRUCTURE_PKG', 'ICXGetOrgContext',
                     'APEXP', null , to_char(0), l_debug_info);
    raise;
END ICXSetOrgContext;




FUNCTION GetICXApplicationId RETURN NUMBER IS
BEGIN
  return 178;
END GetICXApplicationId;

function validateSession(p_func in varchar2 default null,
			 p_commit in boolean default TRUE,
			 p_update in boolean default TRUE) return boolean is

begin

  return icx_sec.validatesession(p_func, '', p_commit, p_update);

  -- return true;

end;

--------------------------------------------------------------------------
FUNCTION GetDirectionAttribute RETURN VARCHAR2 IS
--------------------------------------------------------------------------
  l_sDirection      VARCHAR2(20);

BEGIN
  -- Obtain direction
  -- Defined to be 'LTR' for now. This is a placeholder until cabo or
  -- ICX comes up with an api that determines the direction from the
  -- given language.
  l_sDirection := 'LTR';

  RETURN (l_sDirection);
END GetDirectionAttribute;


BEGIN
  -- initialize all the data
  --Bug 3426625:Call FND_GLOBAL.Apps_Initialize before all initialization.

  FND_GLOBAL.Apps_Initialize(FND_GLOBAL.USER_ID,
                             FND_GLOBAL.RESP_ID,
                             FND_GLOBAL.RESP_APPL_ID);
  initAll;

END AP_WEB_INFRASTRUCTURE_PKG;

/
