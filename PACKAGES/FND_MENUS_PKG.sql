--------------------------------------------------------
--  DDL for Package FND_MENUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_MENUS_PKG" AUTHID CURRENT_USER as
/* $Header: AFMNMNUS.pls 120.1.12010000.1 2008/07/25 14:16:28 appldev ship $ */
/*#
* Table Handler to insert or update data in FND_MENUS table.
* @rep:scope public
* @rep:product FND
* @rep:displayname Menu
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_FUNC_SECURITY
* @rep:ihelp FND/@o_funcsec#o_funcsec See the related online help
*/

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_MENU_ID in NUMBER,
  X_MENU_NAME in VARCHAR2,
  X_USER_MENU_NAME in VARCHAR2,
  X_MENU_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_MENU_ID in NUMBER,
  X_MENU_NAME in VARCHAR2,
  X_USER_MENU_NAME in VARCHAR2,
  X_MENU_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_MENU_ID in NUMBER,
  X_MENU_NAME in VARCHAR2,
  X_USER_MENU_NAME in VARCHAR2,
  X_MENU_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
/* Overloaded version below */
procedure LOAD_ROW (
  X_MENU_NAME in VARCHAR2,
  X_MENU_TYPE in VARCHAR2,
  X_USER_MENU_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);
procedure DELETE_ROW (
  X_MENU_ID in NUMBER
);
procedure ADD_LANGUAGE;

/* Overloaded version below */
procedure TRANSLATE_ROW (
  X_MENU_ID in NUMBER,
  X_USER_MENU_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);

procedure SET_NEW_MENU;

function NEXT_ENTRY_SEQUENCE return number;

currentryseq number := 0;

function VALIDATE_MENU_TYPE(X_MENU_TYPE in VARCHAR2) return boolean;

/* Overloaded version above */
    /*#
     * Creates or updates Menu data as appropriate
     * @param x_menu_name Menu Name
     * @param x_menu_type Menu Type
     * @param x_user_menu_name User Menu Name
     * @param x_description Description
     * @param x_owner Owner Name
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Insert/Update Date
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update Menu
     * @rep:compatibility S
     * @rep:ihelp FND/@dev_p_funcworks#dev_p_funcworks See the related online help
     */
procedure LOAD_ROW (
  X_MENU_NAME in VARCHAR2,
  X_MENU_TYPE in VARCHAR2,
  X_USER_MENU_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
);
/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_MENU_ID in NUMBER,
  X_USER_MENU_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
);
end FND_MENUS_PKG;

/
