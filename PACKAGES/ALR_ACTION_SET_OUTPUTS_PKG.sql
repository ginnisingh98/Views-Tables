--------------------------------------------------------
--  DDL for Package ALR_ACTION_SET_OUTPUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ALR_ACTION_SET_OUTPUTS_PKG" AUTHID CURRENT_USER as
/* $Header: ALRASOTS.pls 120.3.12010000.1 2008/07/27 06:58:32 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_SUPPRESS_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_ALERT_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_ACTION_SET_OUTPUT_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_SEQUENCE in VARCHAR2,
  X_SUPPRESS_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_SUPPRESS_FLAG in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_SUPPRESS_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_NAME in VARCHAR2
);
end ALR_ACTION_SET_OUTPUTS_PKG;

/
