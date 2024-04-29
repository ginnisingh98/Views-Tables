--------------------------------------------------------
--  DDL for Package HR_NAVIGATION_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NAVIGATION_NODES_PKG" AUTHID CURRENT_USER as
/* $Header: hrdwnlct.pkh 115.1 2002/12/10 10:15:40 hjonnala noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAV_NODE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER
);
procedure LOCK_ROW (
  X_NAV_NODE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER
);
procedure UPDATE_ROW (
  X_NAV_NODE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER
);
procedure DELETE_ROW (
  X_NAV_NODE_ID in NUMBER
);
procedure LOAD_ROW (
  X_NODE_NAME in VARCHAR2,
  X_NAV_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_ORG_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CUSTOMIZED_FORM_NAME in VARCHAR2,
  X_CUSTOMIZATION_NAME in VARCHAR2
);

end HR_NAVIGATION_NODES_PKG;

 

/