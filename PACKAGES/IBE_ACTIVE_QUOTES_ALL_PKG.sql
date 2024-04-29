--------------------------------------------------------
--  DDL for Package IBE_ACTIVE_QUOTES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ACTIVE_QUOTES_ALL_PKG" AUTHID CURRENT_USER as
/*$Header: IBEVAQRS.pls 120.1 2005/08/24 21:53:54 appldev ship $ */
procedure INSERT_ROW (
  X_OBJECT_VERSION_NUMBER in NUMBER,
  /*X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID             in NUMBER,
  X_PROGRAM_UPDATE_DATE    in DATE,*/
  X_QUOTE_HEADER_ID       in NUMBER := FND_API.G_MISS_NUM,
  X_PARTY_ID              in NUMBER,
  X_CUST_ACCOUNT_ID       in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_CREATION_DATE         in DATE,
  X_CREATED_BY            in NUMBER,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_RECORD_TYPE           in VARCHAR2,
  X_ORDER_HEADER_ID       in NUMBER := FND_API.G_MISS_NUM,
  X_CURRENCY_CODE         in VARCHAR2,
  X_ORG_ID                in NUMBER := MO_GLOBAL.get_current_org_id()
  );

-- For QUOTES flow
-- Combination is: party_id, cust_acct_id, org_id, record_type
-- currency_code - should be sent as G_MISS_CHAR

-- For RETURNS flow
-- Combination is: party_id, cust_acct_id, org_id, record_type, currency_code.

procedure UPDATE_ROW (
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUOTE_HEADER_ID       in NUMBER := FND_API.G_MISS_NUM,
  X_PARTY_ID              in NUMBER,
  X_CUST_ACCOUNT_ID       in NUMBER,
  X_ORDER_HEADER_ID       in NUMBER   := FND_API.G_MISS_NUM,
  X_RECORD_TYPE           in VARCHAR2,
  X_CURRENCY_CODE         in VARCHAR2 := FND_API.G_MISS_CHAR,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER
);

procedure DELETE_ROW (
  X_QUOTE_HEADER_ID IN NUMBER := FND_API.G_MISS_NUM,
  X_PARTY_ID        IN NUMBER := FND_API.G_MISS_NUM,
  X_ORDER_HEADER_ID IN NUMBER := FND_API.G_MISS_NUM,
  X_CURRENCY_CODE   IN VARCHAR2,
  X_RECORD_TYPE     IN VARCHAR2,
  X_CUST_ACCOUNT_ID IN NUMBER
);

End IBE_ACTIVE_QUOTES_ALL_PKG;

 

/
