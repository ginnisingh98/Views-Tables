--------------------------------------------------------
--  DDL for Package CS_SR_SAVED_ADV_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_SAVED_ADV_CRITERIA_PKG" AUTHID CURRENT_USER as
/* $Header: csxtssas.pls 115.1 2003/09/18 04:44:59 aktripat noship $*/

procedure INSERT_ROW (  X_ROWID in out  nocopy VARCHAR2,
		    X_SEARCH_ID in NUMBER,
		    X_FIELD_NAME in VARCHAR2,
		    X_ROWNUM_IN_LAYOUT in NUMBER,
		    X_FIELD_NAME_ID in VARCHAR2,
		    X_CONDITION in VARCHAR2,
		    X_FIELD_VALUE_ID in VARCHAR2,
		    X_OBJECT_VERSION_NUMBER in NUMBER,
		    X_FIELD_VALUE in VARCHAR2,
		    X_CREATION_DATE in DATE,
		    X_CREATED_BY in NUMBER,
		    X_LAST_UPDATE_DATE in DATE,
	            X_LAST_UPDATED_BY in NUMBER,
		    X_LAST_UPDATE_LOGIN in NUMBER,
		    X_COMMIT_FLAG in VARCHAR2);

procedure LOCK_ROW (  X_SEARCH_ID in NUMBER,
		      X_FIELD_NAME in VARCHAR2,
		      X_ROWNUM_IN_LAYOUT in NUMBER,
		      X_FIELD_NAME_ID in VARCHAR2,
		      X_CONDITION in VARCHAR2,
		      X_FIELD_VALUE_ID in VARCHAR2,
		      X_OBJECT_VERSION_NUMBER in NUMBER,
		      X_SECURITY_GROUP_ID in NUMBER,
		      X_FIELD_VALUE in VARCHAR2);

procedure UPDATE_ROW (  X_SEARCH_ID in NUMBER,
		      X_FIELD_NAME in VARCHAR2,
		      X_ROWNUM_IN_LAYOUT in NUMBER,
		      X_FIELD_NAME_ID in VARCHAR2,
		      X_CONDITION in VARCHAR2,
		      X_FIELD_VALUE_ID in VARCHAR2,
		      X_OBJECT_VERSION_NUMBER in NUMBER,
		      X_SECURITY_GROUP_ID in NUMBER,
		      X_FIELD_VALUE in VARCHAR2,
		      X_LAST_UPDATE_DATE in DATE,
		      X_LAST_UPDATED_BY in NUMBER,
		      X_LAST_UPDATE_LOGIN in NUMBER);

procedure DELETE_ROW (  X_SEARCH_ID in NUMBER );
end CS_SR_SAVED_ADV_CRITERIA_PKG;

 

/
