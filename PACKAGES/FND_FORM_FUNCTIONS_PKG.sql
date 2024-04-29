--------------------------------------------------------
--  DDL for Package FND_FORM_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FORM_FUNCTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: AFFMFUNS.pls 120.3 2006/02/17 09:29:18 jvalenti ship $ */
/*#
* Table Handler to insert or update data in FND_FORM_FUNCTIONS table.
* @rep:scope public
* @rep:product FND
* @rep:displayname Form Function
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_FUNCTION
* @rep:ihelp FND/@o_funcsec#o_funcsec See the related online help
*/


/* Overloaded version below.  This version does not have new */
/* LAST_UPDATE_DATE, MAINTENANCE_MODE_SUPPORT, or CONTEXT_DEPENDENCE */
/* columns, so that it will continue to be callable from old forms code. */
/* This API is obsolete and should not be used for new code. */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

/* Overloaded version below.  This version does not have new */
/* MAINTENANCE_MODE_SUPPORT, or CONTEXT_DEPENDENCE */
/* columns, so that it will continue to be callable from old forms code. */
/* This API is obsolete and should not be used for new code. */
procedure LOCK_ROW (
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);

/* Overloaded version below.  This version does not have new */
/* MAINTENANCE_MODE_SUPPORT, or CONTEXT_DEPENDENCE */
/* columns, so that it will continue to be callable from old forms code. */
/* This API is obsolete and should not be used for new code. */
procedure UPDATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

/* Overloaded version below.  */
/* This version does NOT have last_update_date, for old forms code*/
/* This API is obsolete and should not be used for new code. */
procedure LOAD_ROW (
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_REGION_APPLICATION_NAME in VARCHAR2,
  X_REGION_CODE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);

procedure DELETE_ROW (
  X_FUNCTION_ID in NUMBER
);

procedure ADD_LANGUAGE;

/* Overloaded version below */
/* This version does NOT have last_update_date for old forms code*/
/* This API is obsolete and should not be used for new code. */
procedure TRANSLATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);

/* Overloaded version above.  This version DOES have new */
/* LAST_UPDATE_DATE, MAINTENANCE_MODE_SUPPORT,  CONTEXT_DEPENDENCE, */
/* JRAD_REF_PATH columns so this API should be used for new code. */
    /*#
     * Creates or updates Form Function as appropriate
     * @param x_function_name Function Name
     * @param x_application_short_name Application Short Name
     * @param x_form_name Form Name
     * @param x_parameters Parameters To the Function
     * @param x_type Function Type
     * @param x_web_host_name Web Host Name
     * @param x_web_agent_name Web Agent Name
     * @param x_web_html_call HTML Call
     * @param x_web_encrypt_parameters Encrypt Parameters or Not
     * @param x_web_secured Web Secured or Not
     * @param x_web_icon Web Icon
     * @param x_object_name Object Name
     * @param x_region_application_name Region Application Name
     * @param x_region_code Region Code
     * @param x_user_function_name User Function Name
     * @param x_description Description
     * @param x_owner Owner Name
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Insert/Update Date
     * @param x_maintenance_mode_support Maintenance Mode Support
     * @param x_context_dependence Context Dependence
     * @param x_jrad_ref_path MDS Reference Path
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update Form Function
     * @rep:compatibility S
     * @rep:ihelp FND/@dev_sp_subfunc#dev_sp_subfunc See the related online help
     */
procedure LOAD_ROW (
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_REGION_APPLICATION_NAME in VARCHAR2,
  X_REGION_CODE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_MAINTENANCE_MODE_SUPPORT in VARCHAR2,
  X_CONTEXT_DEPENDENCE in VARCHAR2,
  X_JRAD_REF_PATH in VARCHAR2 default NULL
);

/* Overloaded version above.  This version DOES have new */
/* LAST_UPDATE_DATE */
/* columns, so this API should be used for new code. */
procedure TRANSLATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2);

/* Overloaded version above.  This version DOES have new */
/* MAINTENANCE_MODE_SUPPORT,  CONTEXT_DEPENDENCE, JRAD_REF_PATH */
/* columns, so this API should be used for new code. */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_MAINTENANCE_MODE_SUPPORT in VARCHAR2,
  X_CONTEXT_DEPENDENCE in VARCHAR2,
  X_JRAD_REF_PATH in VARCHAR2 default NULL
);

/* Overloaded version above.  This version DOES have new */
/* MAINTENANCE_MODE_SUPPORT,  CONTEXT_DEPENDENCE, JRAD_REF_PATH */
/* columns, so this API should be used for new code. */
procedure LOCK_ROW (
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MAINTENANCE_MODE_SUPPORT in VARCHAR2,
  X_CONTEXT_DEPENDENCE in VARCHAR2,
  X_JRAD_REF_PATH in VARCHAR2 default NULL
);

/* Overloaded version above.  This version DOES have new */
/* MAINTENANCE_MODE_SUPPORT,  CONTEXT_DEPENDENCE, JRAD_REF_PATH */
/* columns, so this API should be used for new code. */
procedure UPDATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_WEB_HTML_CALL in VARCHAR2,
  X_WEB_ENCRYPT_PARAMETERS in VARCHAR2,
  X_WEB_SECURED in VARCHAR2,
  X_WEB_ICON in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_PARAMETERS in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_USER_FUNCTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_MAINTENANCE_MODE_SUPPORT in VARCHAR2,
  X_CONTEXT_DEPENDENCE in VARCHAR2,
  X_JRAD_REF_PATH in VARCHAR2 default NULL
);

/* Function Maintenance Mode can be: FUZZY, MAINT, NONE, QUERY and OFFLINE */
/* Please refer to LOOKUP_TYPE APPS_MAINTENANCE_MODE_SUPPORT for these */
/* value and description */
/* Input                 */
/*   x_function_name : specific function name or a wildcard function name */
/*   x_function_mode : the value of the maintenance_mode_support */

procedure SET_FUNCTION_MODE (x_function_name in varchar2,
                             x_function_mode in varchar2);

function FUNCTION_VALIDATION (application_id in out nocopy number,
                               form_id in out nocopy number,
                               type in out nocopy varchar2,
                               parameters in out nocopy varchar2,
                               web_html_call in out nocopy varchar2,
                               web_host_name in varchar2,
                               region_application_id in out nocopy number,
                               region_code in out nocopy varchar2,
                               function_name in varchar2) return varchar2;


end FND_FORM_FUNCTIONS_PKG;

 

/
