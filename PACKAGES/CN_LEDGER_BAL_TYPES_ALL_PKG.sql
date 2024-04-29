--------------------------------------------------------
--  DDL for Package CN_LEDGER_BAL_TYPES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_LEDGER_BAL_TYPES_ALL_PKG" AUTHID CURRENT_USER as
/* $Header: cnmllbts.pls 115.6 2001/10/29 17:08:30 pkm ship    $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_BALANCE_ID in NUMBER,
--  X_CREDIT_TYPE_ID in NUMBER,
--  X_INCENTIVE_TYPE_ID in NUMBER,
  X_STATISTICAL_TYPE in VARCHAR2,
  X_PAYMENT_TYPE in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_BALANCE_TYPE in VARCHAR2,
  X_SCREEN_SEQUENCE in NUMBER,
  X_BALANCE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_BALANCE_ID in NUMBER,
--  X_CREDIT_TYPE_ID in NUMBER,
--  X_INCENTIVE_TYPE_ID in NUMBER,
  X_STATISTICAL_TYPE in VARCHAR2,
  X_PAYMENT_TYPE in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_BALANCE_TYPE in VARCHAR2,
  X_SCREEN_SEQUENCE in NUMBER,
  X_BALANCE_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_BALANCE_ID in NUMBER,
--  X_CREDIT_TYPE_ID in NUMBER,
--  X_INCENTIVE_TYPE_ID in NUMBER,
  X_STATISTICAL_TYPE in VARCHAR2,
  X_PAYMENT_TYPE in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_BALANCE_TYPE in VARCHAR2,
  X_SCREEN_SEQUENCE in NUMBER,
  X_BALANCE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_BALANCE_ID in NUMBER
);
procedure ADD_LANGUAGE;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+

PROCEDURE LOAD_ROW
  (x_balance_id IN NUMBER,
   x_balance_name IN VARCHAR2,
   x_balance_type IN VARCHAR2,
   x_statistical_type IN VARCHAR2,
   x_payment_type IN VARCHAR2,
   x_column_name IN VARCHAR2,
   x_screen_sequence IN NUMBER,
   x_owner IN VARCHAR2);

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
  PROCEDURE TRANSLATE_ROW
  ( x_balance_id IN NUMBER,
    x_balance_name IN VARCHAR2,
    x_owner IN VARCHAR2);

end CN_LEDGER_BAL_TYPES_ALL_PKG;

 

/
