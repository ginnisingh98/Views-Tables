--------------------------------------------------------
--  DDL for Package Body AR_BPA_DATA_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_DATA_SOURCES_PKG" as
/* $Header: ARBPDSTB.pls 120.1 2004/12/03 01:45:08 orashid noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATA_SOURCE_ID in NUMBER,
  X_DATA_SOURCE_TYPE in VARCHAR2,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_INTERFACE_LINE_CONTEXT in VARCHAR2,
  X_MODULE_NAME in VARCHAR2,
  X_VO_INIT_SEQUENCE in NUMBER,
  X_VO_USAGE_FULL_NAME in VARCHAR2,
  X_VO_USAGE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_INVOICED_LINE_ACCTG_LEVEL in VARCHAR2,
  X_TAX_SOURCE_FLAG in VARCHAR2,
  X_SOURCE_LINE_TYPE in VARCHAR2
) is
begin
	NULL;
end INSERT_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DATA_SOURCE_ID in NUMBER,
  X_DATA_SOURCE_TYPE in VARCHAR2,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_INTERFACE_LINE_CONTEXT in VARCHAR2,
  X_MODULE_NAME in VARCHAR2,
  X_VO_INIT_SEQUENCE in NUMBER,
  X_VO_USAGE_FULL_NAME in VARCHAR2,
  X_VO_USAGE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_INVOICED_LINE_ACCTG_LEVEL  in VARCHAR2,
  X_TAX_SOURCE_FLAG in VARCHAR2,
  X_SOURCE_LINE_TYPE in VARCHAR2
) is
begin
	NULL;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DATA_SOURCE_ID in NUMBER
) is
begin
	NULL;
end DELETE_ROW;

procedure LOAD_ROW (
        X_APPLICATION_ID                 IN NUMBER,
        X_DATA_SOURCE_ID                 IN NUMBER,
        X_DATA_SOURCE_TYPE               IN VARCHAR2,
        X_DISPLAY_LEVEL                  IN VARCHAR2,
        X_INTERFACE_LINE_CONTEXT         IN VARCHAR2,
        X_MODULE_NAME                    IN VARCHAR2,
        X_VO_INIT_SEQUENCE               IN NUMBER,
        X_VO_USAGE_FULL_NAME             IN VARCHAR2,
        X_VO_USAGE_NAME                  IN VARCHAR2,
        X_OWNER                 		 IN VARCHAR2,
		X_INVOICED_LINE_ACCTG_LEVEL      IN VARCHAR2,
  		X_TAX_SOURCE_FLAG 				 IN VARCHAR2,
  	    X_SOURCE_LINE_TYPE 				 IN VARCHAR2
) IS
begin
	NULL;
end LOAD_ROW;

end AR_BPA_DATA_SOURCES_PKG;

/