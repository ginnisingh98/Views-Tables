--------------------------------------------------------
--  DDL for Package HR_INCOMPATIBILITY_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INCOMPATIBILITY_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: hrwirlct.pkh 115.1 2002/12/11 11:17:21 raranjan noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FROM_NAV_UNIT_ID in NUMBER,
  X_TO_NAV_UNIT_ID in NUMBER
);
procedure LOCK_ROW (
  X_FROM_NAV_UNIT_ID in NUMBER,
  X_TO_NAV_UNIT_ID in NUMBER
);
procedure UPDATE_ROW (
  X_FROM_NAV_UNIT_ID in NUMBER,
  X_TO_NAV_UNIT_ID in NUMBER
);
procedure DELETE_ROW (
  X_FROM_NAV_UNIT_ID in NUMBER,
  X_TO_NAV_UNIT_ID in NUMBER
);
procedure LOAD_ROW (
  X_FROM_FORM_NAME in VARCHAR2,
  X_FROM_BLOCK_NAME in VARCHAR2,
  X_TO_FORM_NAME in VARCHAR2,
  X_TO_BLOCK_NAME in VARCHAR2,
  X_NAV_FLAG in VARCHAR2
);
end HR_INCOMPATIBILITY_RULES_PKG;

 

/
