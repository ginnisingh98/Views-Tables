--------------------------------------------------------
--  DDL for Package FND_OAM_BF_WIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_BF_WIT_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMFWS.pls 120.1 2005/07/02 03:04:23 appldev noship $ */


procedure LOAD_ROW (
    X_BIZ_FLOW_KEY in VARCHAR2,
    X_ITEM_TYPE in VARCHAR2,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2);

procedure LOAD_ROW (
    X_BIZ_FLOW_KEY in VARCHAR2,
    X_ITEM_TYPE in VARCHAR2,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure UPDATE_ROW (
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2
);

end FND_OAM_BF_WIT_PKG;

 

/
