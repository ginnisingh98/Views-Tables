--------------------------------------------------------
--  DDL for Package IEU_UWQM_PRIORITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQM_PRIORITIES_PKG" AUTHID CURRENT_USER as
/* $Header: IEUUWQPS.pls 120.1 2005/06/15 23:09:12 appldev  $ */
procedure INSERT_ROW (
  P_PRIORITY_ID in NUMBER,
  P_PRIORITY_CODE in VARCHAR2,
  P_PRIORITY_LEVEL in NUMBER,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  X_ROWID in out nocopy VARCHAR2
);
procedure LOCK_ROW (
  P_PRIORITY_ID in NUMBER,
  P_PRIORITY_CODE in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_PRIORITY_LEVEL in NUMBER,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  P_PRIORITY_ID in NUMBER,
  P_PRIORITY_CODE in VARCHAR2,
  P_PRIORITY_LEVEL in NUMBER,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2
);
procedure DELETE_ROW (
  P_PRIORITY_ID in NUMBER
);
procedure ADD_LANGUAGE;
PROCEDURE translate_row (
    p_priority_id IN NUMBER,
    p_name IN VARCHAR2,
    p_description IN VARCHAR2,
    p_owner IN VARCHAR2);
PROCEDURE Load_Row (
                p_priority_id IN NUMBER,
                p_priority_level IN NUMBER,
                p_priority_code IN VARCHAR2,
                p_name IN VARCHAR2,
                p_description IN VARCHAR2,
                p_owner IN VARCHAR2);
PROCEDURE load_seed_row (
                p_upload_mode in VARCHAR2,
                p_priority_id IN NUMBER,
                p_priority_level IN NUMBER,
                p_priority_code IN VARCHAR2,
                p_name IN VARCHAR2,
                p_description IN VARCHAR2,
                p_owner IN VARCHAR2);

end IEU_UWQM_PRIORITIES_PKG;

 

/
