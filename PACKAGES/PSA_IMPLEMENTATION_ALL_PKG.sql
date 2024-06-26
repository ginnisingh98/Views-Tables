--------------------------------------------------------
--  DDL for Package PSA_IMPLEMENTATION_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_IMPLEMENTATION_ALL_PKG" AUTHID CURRENT_USER as
 /* $Header: PSAIMPLS.pls 120.2 2006/09/13 11:54:41 agovil ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_MAPPING_REQUIRED in VARCHAR2,
  X_PROGRAM_INSTALLED in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_MAPPING_REQUIRED in VARCHAR2,
  X_PROGRAM_INSTALLED in VARCHAR2
);
procedure UPDATE_ROW (
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_MAPPING_REQUIRED in VARCHAR2,
  X_PROGRAM_INSTALLED in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_MAPPING_REQUIRED in VARCHAR2,
  X_PROGRAM_INSTALLED in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER
);
end PSA_IMPLEMENTATION_ALL_PKG;

 

/
