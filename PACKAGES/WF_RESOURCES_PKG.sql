--------------------------------------------------------
--  DDL for Package WF_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_RESOURCES_PKG" AUTHID CURRENT_USER as
/* $Header: wfress.pls 120.3 2005/10/04 23:15:40 hgandiko ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_ID in NUMBER,
  X_TEXT in VARCHAR2
);
procedure LOCK_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_ID in NUMBER,
  X_TEXT in VARCHAR2
);
procedure UPDATE_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_ID in NUMBER,
  X_TEXT in VARCHAR2);
procedure DELETE_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;
end WF_RESOURCES_PKG;

 

/
