--------------------------------------------------------
--  DDL for Package FND_OAM_DS_POLICIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DS_POLICIES_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDPS.pls 120.1 2005/07/28 21:36:41 yawu noship $ */
procedure INSERT_ROW (
      X_ROWID in out nocopy VARCHAR2,
	X_POLICY_ID in NUMBER,
	X_POLICY_NAME IN VARCHAR2,
	X_DESCRIPTION IN VARCHAR2,
	X_START_DATE in DATE,
	X_END_DATE in DATE,
	X_CREATED_BY in NUMBER,
	X_CREATION_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
	X_POLICY_ID in NUMBER,
	X_POLICY_NAME IN VARCHAR2,
	X_DESCRIPTION IN VARCHAR2,
	X_START_DATE in DATE,
	X_END_DATE in DATE,
	X_CREATED_BY in NUMBER,
	X_CREATION_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATE_LOGIN in NUMBER);

procedure UPDATE_ROW (
	X_POLICY_ID in NUMBER,
	X_POLICY_NAME IN VARCHAR2,
	X_DESCRIPTION IN VARCHAR2,
	X_START_DATE in DATE,
	X_END_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_POLICY_ID in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW
(
 x_POLICY_ID  in NUMBER,
 x_POLICY_NAME in varchar2,
 x_Last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number
);

end FND_OAM_DS_POLICIES_PKG;

 

/