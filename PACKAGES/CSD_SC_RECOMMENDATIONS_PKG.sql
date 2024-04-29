--------------------------------------------------------
--  DDL for Package CSD_SC_RECOMMENDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_SC_RECOMMENDATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtscrs.pls 120.0 2005/10/26 12:52:56 swai noship $ */

procedure INSERT_ROW (
  -- P_ROWID in out nocopy VARCHAR2,
  PX_SC_RECOMMENDATION_ID in out nocopy NUMBER,
  P_SC_DOMAIN_ID in NUMBER,
  P_RECOMMENDATION_TYPE_CODE in VARCHAR2,
  P_ACTIVE_FROM in DATE,
  P_ACTIVE_TO in DATE,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_SC_RECOMMENDATION_NAME in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  P_SC_RECOMMENDATION_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  P_SC_RECOMMENDATION_ID in NUMBER,
  P_SC_DOMAIN_ID in NUMBER,
  P_RECOMMENDATION_TYPE_CODE in VARCHAR2,
  P_ACTIVE_FROM in DATE,
  P_ACTIVE_TO in DATE,
  P_SC_RECOMMENDATION_NAME in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  P_SC_RECOMMENDATION_ID in NUMBER
);

procedure ADD_LANGUAGE;

end CSD_SC_RECOMMENDATIONS_PKG;
 

/