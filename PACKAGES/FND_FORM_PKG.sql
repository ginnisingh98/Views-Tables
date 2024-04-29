--------------------------------------------------------
--  DDL for Package FND_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FORM_PKG" AUTHID CURRENT_USER as
/* $Header: AFFMFBFS.pls 120.3 2005/10/05 23:03:42 stadepal ship $ */
/*#
* Table Handler to insert or update data in FND_FORM table.
* @rep:scope public
* @rep:product FND
* @rep:displayname Form
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_FORM
* @rep:ihelp FND/@o_funcsec#o_funcsec See the related online help
*/

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
/* Overloaded version below */
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER
);
procedure ADD_LANGUAGE;
/* Overloaded version below */
procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);
/* Overloaded version above */
    /*#
     * Creates or updates Form data as appropriate
     * @param x_application_short_name Application Short Name
     * @param x_form_name Form Name
     * @param x_audit_enabled_flag Audit Enabled Flag
     * @param x_user_form_name User Form Name
     * @param x_description Description
     * @param x_owner Owner Name
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Insert/Update Date
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update Form Data
     * @rep:compatibility S
     * @rep:ihelp FND/@dev_sp_subfunc#dev_sp_subfunc See the related online help
     */
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
);
/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
);
end FND_FORM_PKG;

 

/
