--------------------------------------------------------
--  DDL for Package HR_NAVIGATION_NODE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NAVIGATION_NODE_USAGES_PKG" AUTHID CURRENT_USER as
/* $Header: hrnvnlct.pkh 115.1 2002/12/10 12:49:55 hjonnala noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAV_NODE_USAGE_ID in NUMBER,
  X_WORKFLOW_ID in NUMBER,
  X_NAV_NODE_ID in NUMBER,
  X_TOP_NODE in VARCHAR2
);
procedure LOCK_ROW (
  X_NAV_NODE_USAGE_ID in NUMBER,
  X_WORKFLOW_ID in NUMBER,
  X_NAV_NODE_ID in NUMBER,
  X_TOP_NODE in VARCHAR2
);
procedure UPDATE_ROW (
  X_NAV_NODE_USAGE_ID in NUMBER,
  X_WORKFLOW_ID in NUMBER,
  X_NAV_NODE_ID in NUMBER,
  X_TOP_NODE in VARCHAR2
);
procedure DELETE_ROW (
  X_NAV_NODE_USAGE_ID in NUMBER
);
procedure LOAD_ROW (
  X_WORKFLOW_NAME in VARCHAR2,
  X_NODE_NAME in VARCHAR2,
  X_TOP_NODE in VARCHAR2
);
end HR_NAVIGATION_NODE_USAGES_PKG;

 

/
