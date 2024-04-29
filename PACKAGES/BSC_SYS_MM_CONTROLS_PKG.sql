--------------------------------------------------------
--  DDL for Package BSC_SYS_MM_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SYS_MM_CONTROLS_PKG" AUTHID CURRENT_USER as
/* $Header: BSCSMMS.pls 115.7 2003/02/12 14:29:28 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_BUTTON_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2);
procedure LOCK_ROW (
  X_BUTTON_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
);
procedure UPDATE_ROW (
  X_BUTTON_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
);
procedure DELETE_ROW (
  X_BUTTON_ID in NUMBER
);
procedure ADD_LANGUAGE;
end BSC_SYS_MM_CONTROLS_PKG;

 

/
