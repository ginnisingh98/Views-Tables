--------------------------------------------------------
--  DDL for Package BSC_TAB_CSF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_TAB_CSF_PKG" AUTHID CURRENT_USER as
/* $Header: BSCTABCS.pls 115.7 2003/02/12 14:29:46 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER,
  X_CSF_TYPE in NUMBER,
  X_INTERMEDIATE_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2);
procedure LOCK_ROW (
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER,
  X_CSF_TYPE in NUMBER,
  X_INTERMEDIATE_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
);
procedure UPDATE_ROW (
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER,
  X_CSF_TYPE in NUMBER,
  X_INTERMEDIATE_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
);
procedure DELETE_ROW (
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER
);
procedure ADD_LANGUAGE;
end BSC_TAB_CSF_PKG;

 

/
