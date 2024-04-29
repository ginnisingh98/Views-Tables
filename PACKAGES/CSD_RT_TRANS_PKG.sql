--------------------------------------------------------
--  DDL for Package CSD_RT_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RT_TRANS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtrtts.pls 120.0 2005/06/30 21:06:35 vkjain noship $ */

procedure INSERT_ROW (
  -- P_ROWID in out nocopy VARCHAR2,
  PX_RT_TRAN_ID in out nocopy NUMBER,
  P_FROM_REPAIR_TYPE_ID in NUMBER,
  P_TO_REPAIR_TYPE_ID in NUMBER,
  P_COMMON_FLOW_STATUS_ID in NUMBER,
  P_REASON_REQUIRED_FLAG in VARCHAR2,
  P_CAPTURE_ACTIVITY_FLAG in VARCHAR2,
  P_ALLOW_ALL_RESP_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_DESCRIPTION in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  P_RT_TRAN_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  P_RT_TRAN_ID in NUMBER,
  P_FROM_REPAIR_TYPE_ID in NUMBER,
  P_TO_REPAIR_TYPE_ID in NUMBER,
  P_COMMON_FLOW_STATUS_ID in NUMBER,
  P_REASON_REQUIRED_FLAG in VARCHAR2,
  P_CAPTURE_ACTIVITY_FLAG in VARCHAR2,
  P_ALLOW_ALL_RESP_FLAG in VARCHAR2,
  P_DESCRIPTION         in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  P_RT_TRAN_ID in NUMBER
);

procedure ADD_LANGUAGE;

end CSD_RT_TRANS_PKG;
 

/
