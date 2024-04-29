--------------------------------------------------------
--  DDL for Package PA_ALLOC_TARGET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ALLOC_TARGET_LINES_PKG" AUTHID CURRENT_USER AS
 /* $Header: PAXATTLS.pls 120.1 2005/08/18 15:02:47 dlanka noship $   */
procedure INSERT_ROW (
  X_ROWID 		in out NOCOPY VARCHAR2,
  X_RULE_ID 		in NUMBER,
  X_LINE_NUM 		in NUMBER,
  X_PROJECT_ORG_ID 	in NUMBER,
  X_TASK_ORG_ID 	in NUMBER,
  X_PROJECT_TYPE 	in VARCHAR2,
  X_CLASS_CATEGORY 	in VARCHAR2,
  X_CLASS_CODE 		in VARCHAR2,
  X_SERVICE_TYPE 	in VARCHAR2,
  X_PROJECT_ID 		in NUMBER,
  X_TASK_ID 		in NUMBER,
  X_EXCLUDE_FLAG 	in VARCHAR2,
  X_BILLABLE_ONLY_FLAG 	in VARCHAR2,
  X_LINE_PERCENT 	in NUMBER,
  X_CREATED_BY		in NUMBER,
  X_CREATION_DATE	in DATE,
  X_LAST_UPDATE_DATE	in DATE,
  X_LAST_UPDATED_BY	in NUMBER,
  X_LAST_UPDATE_LOGIN	in NUMBER
  );

procedure LOCK_ROW (
  X_RULE_ID 		in NUMBER,
  X_LINE_NUM 		in NUMBER,
  X_PROJECT_ORG_ID 	in NUMBER,
  X_TASK_ORG_ID 	in NUMBER,
  X_PROJECT_TYPE 	in VARCHAR2,
  X_CLASS_CATEGORY 	in VARCHAR2,
  X_CLASS_CODE 		in VARCHAR2,
  X_SERVICE_TYPE 	in VARCHAR2,
  X_PROJECT_ID 		in NUMBER,
  X_TASK_ID 		in NUMBER,
  X_EXCLUDE_FLAG 	in VARCHAR2,
  X_BILLABLE_ONLY_FLAG 	in VARCHAR2,
  X_LINE_PERCENT 	in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID   		IN VARCHAR2,
  X_RULE_ID 		in NUMBER,
  X_LINE_NUM 		in NUMBER,
  X_PROJECT_ORG_ID 	in NUMBER,
  X_TASK_ORG_ID 	in NUMBER,
  X_PROJECT_TYPE 	in VARCHAR2,
  X_CLASS_CATEGORY 	in VARCHAR2,
  X_CLASS_CODE 		in VARCHAR2,
  X_SERVICE_TYPE 	in VARCHAR2,
  X_PROJECT_ID 		in NUMBER,
  X_TASK_ID 		in NUMBER,
  X_EXCLUDE_FLAG 	in VARCHAR2,
  X_BILLABLE_ONLY_FLAG 	in VARCHAR2,
  X_LINE_PERCENT 	in NUMBER,
  X_LAST_UPDATE_DATE	in DATE,
  X_LAST_UPDATED_BY	in NUMBER,
  X_LAST_UPDATE_LOGIN	in NUMBER
  );

procedure DELETE_ROW (
  X_ROWID  IN VARCHAR2
  --X_RULE_ID in NUMBER,
  --X_LINE_NUM in NUMBER
);
   end PA_ALLOC_TARGET_LINES_PKG;

 

/