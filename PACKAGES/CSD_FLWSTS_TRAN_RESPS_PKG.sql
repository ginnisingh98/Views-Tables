--------------------------------------------------------
--  DDL for Package CSD_FLWSTS_TRAN_RESPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_FLWSTS_TRAN_RESPS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtflrs.pls 120.0 2005/06/30 21:03:48 vkjain noship $ */

procedure INSERT_ROW (
  -- P_ROWID in out nocopy VARCHAR2,
  PX_FLWSTS_TRAN_RESP_ID in out nocopy NUMBER,
  P_FLWSTS_TRAN_ID in NUMBER,
  P_RESPONSIBILITY_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  P_FLWSTS_TRAN_RESP_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  P_FLWSTS_TRAN_RESP_ID in NUMBER,
  P_FLWSTS_TRAN_ID in NUMBER,
  P_RESPONSIBILITY_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  P_FLWSTS_TRAN_RESP_ID in NUMBER
);

end CSD_FLWSTS_TRAN_RESPS_PKG;
 

/
