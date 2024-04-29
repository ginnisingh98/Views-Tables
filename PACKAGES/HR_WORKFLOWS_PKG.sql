--------------------------------------------------------
--  DDL for Package HR_WORKFLOWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WORKFLOWS_PKG" AUTHID CURRENT_USER as
/* $Header: hrdwflct.pkh 115.4 2002/12/10 10:02:01 hjonnala noship $ */
G_LOAD_TASKFLOW VARCHAR2(1) DEFAULT 'Y';
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_WORKFLOW_ID in NUMBER,
  X_WORKFLOW_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2
);
procedure LOCK_ROW (
  X_WORKFLOW_ID in NUMBER,
  X_WORKFLOW_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2
);
procedure UPDATE_ROW (
  X_WORKFLOW_ID in NUMBER,
  X_WORKFLOW_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2
);
procedure DELETE_ROW (
  X_WORKFLOW_ID in NUMBER
);
procedure LOAD_ROW (
  X_WORKFLOW_NAME in VARCHAR2,
  X_LEGISLATION_NAME in VARCHAR2
);
end HR_WORKFLOWS_PKG;

 

/
