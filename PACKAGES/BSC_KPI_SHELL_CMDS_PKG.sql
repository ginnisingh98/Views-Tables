--------------------------------------------------------
--  DDL for Package BSC_KPI_SHELL_CMDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_SHELL_CMDS_PKG" AUTHID CURRENT_USER as
/* $Header: BSCKSHLS.pls 115.7 2003/02/12 14:26:05 adrao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INDICATOR in NUMBER,
  X_SHELL_CMD_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2);
procedure LOCK_ROW (
  X_INDICATOR in NUMBER,
  X_SHELL_CMD_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_INDICATOR in NUMBER,
  X_SHELL_CMD_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2
);
procedure DELETE_ROW (
  X_INDICATOR in NUMBER,
  X_SHELL_CMD_ID in NUMBER
);
procedure ADD_LANGUAGE;
end BSC_KPI_SHELL_CMDS_PKG;

 

/
