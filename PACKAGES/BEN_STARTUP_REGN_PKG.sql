--------------------------------------------------------
--  DDL for Package BEN_STARTUP_REGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_STARTUP_REGN_PKG" AUTHID CURRENT_USER as
/* $Header: besrg01t.pkh 120.0 2005/05/28 11:53:15 appldev noship $ */
procedure OWNER_TO_WHO (
  P_OWNER in VARCHAR2,
  P_CREATION_DATE out nocopy DATE,
  P_CREATED_BY out nocopy NUMBER,
  P_LAST_UPDATE_DATE out nocopy DATE,
  P_LAST_UPDATED_BY out nocopy NUMBER,
  P_LAST_UPDATE_LOGIN out nocopy NUMBER
);

procedure INSERT_ROW (
  P_ROWID in out nocopy VARCHAR2,
  P_STTRY_CITN_NAME in VARCHAR2,
  P_LEGISLATION_CODE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  P_STTRY_CITN_NAME in VARCHAR2,
  P_LEGISLATION_CODE in VARCHAR2,
  P_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  P_STTRY_CITN_NAME in VARCHAR2,
  P_LEGISLATION_CODE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  P_STTRY_CITN_NAME in VARCHAR2
);
procedure UPLOAD_ROW(P_STTRY_CITN_NAME in VARCHAR2,
                     P_LEGISLATION_CODE in VARCHAR2,
                     P_NAME in VARCHAR2,
                     P_OWNER in VARCHAR2);

procedure TRANSLATE_ROW(P_STTRY_CITN_NAME in VARCHAR2,
                        P_NAME in VARCHAR2,
                        P_OWNER in VARCHAR2);
procedure ADD_LANGUAGE;
end BEN_STARTUP_REGN_PKG;

 

/
