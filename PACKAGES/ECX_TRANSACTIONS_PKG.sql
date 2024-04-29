--------------------------------------------------------
--  DDL for Package ECX_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_TRANSACTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: ECXTXNS.pls 120.2.12000000.3 2007/07/20 07:40:41 susaha ship $ */
procedure TRANSLATE_ROW(
  X_TRANSACTION_TYPE              IN      VARCHAR2,
  X_TRANSACTION_SUBTYPE           IN      VARCHAR2,
  X_PARTY_TYPE                    IN      VARCHAR2,
  X_TRANSACTION_DESCRIPTION       IN      VARCHAR2,
  X_OWNER                         IN      VARCHAR2,
  X_CUSTOM_MODE                   IN      VARCHAR2
);
procedure LOAD_ROW (
  X_TRANSACTION_TYPE              IN      VARCHAR2,
  X_TRANSACTION_SUBTYPE           IN      VARCHAR2,
  X_PARTY_TYPE                    IN      VARCHAR2,
  X_TRANSACTION_DESCRIPTION       IN      VARCHAR2,
  X_ADMIN_USER                    IN      VARCHAR2 DEFAULT NULL,
  X_OWNER                         IN      VARCHAR2,
  X_CUSTOM_MODE                   IN      VARCHAR2
);
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TRANSACTION_ID in NUMBER,
  X_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_SUBTYPE in VARCHAR2,
  X_PARTY_TYPE in VARCHAR2,
  X_TRANSACTION_DESCRIPTION in VARCHAR2,
  X_ADMIN_USER in VARCHAR2 DEFAULT NULL,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_TRANSACTION_ID in NUMBER,
  X_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_SUBTYPE in VARCHAR2,
  X_PARTY_TYPE in VARCHAR2,
  X_TRANSACTION_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_TRANSACTION_ID in NUMBER,
  X_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_SUBTYPE in VARCHAR2,
  X_PARTY_TYPE in VARCHAR2,
  X_TRANSACTION_DESCRIPTION in VARCHAR2,
  X_ADMIN_USER in VARCHAR2 DEFAULT NULL,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_TRANSACTION_ID in NUMBER
);
procedure ADD_LANGUAGE;
end ECX_TRANSACTIONS_PKG;

 

/