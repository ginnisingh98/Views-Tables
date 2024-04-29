--------------------------------------------------------
--  DDL for Package Body AMV_STOCK_LD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_STOCK_LD_PKG" as
/* $Header: amvtstkb.pls 120.1 2005/06/21 17:45:04 appldev ship $ */
procedure Load_Row(
  X_STOCK_ID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
--  X_OWNER in VARCHAR2,
  X_STOCK_SYMBOL in VARCHAR2,
  X_STOCK_RIC in VARCHAR2,
  X_STOCK_TYPE in VARCHAR2,
  X_STOCK_DESC in VARCHAR2,
  X_COUNTRY_ID in VARCHAR2,
  X_EXCHANGE in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_INDUSTRY_CLASS in VARCHAR2,
  X_ISSUE_TYPE in VARCHAR2
) AS
--
l_user_id NUMBER := 1;
l_row_id VARCHAR2(2000);
l_stock_id NUMBER;
l_object_version_number NUMBER;
l_country_id NUMBER;
l_industry_class NUMBER;
l_issue_type NUMBER;

BEGIN
   l_stock_id := to_number(X_STOCK_ID);
   l_object_version_number := to_number(X_OBJECT_VERSION_NUMBER);
   l_country_id := to_number(X_COUNTRY_ID);
   l_industry_class := to_number(X_INDUSTRY_CLASS);
   l_issue_type := to_number(X_ISSUE_TYPE);

   UPDATE_ROW(
          X_STOCK_ID => l_stock_id,
          X_OBJECT_VERSION_NUMBER => l_object_version_number,
          X_LAST_UPDATE_DATE => sysdate,
          X_LAST_UPDATED_BY => l_user_id,
          X_LAST_UPDATE_LOGIN => 0,
          X_STOCK_SYMBOL => X_STOCK_SYMBOL,
          X_STOCK_RIC => X_STOCK_RIC,
          X_STOCK_TYPE => X_STOCK_TYPE,
          X_STOCK_DESC => X_STOCK_DESC,
          X_COUNTRY_ID => l_country_id,
          X_EXCHANGE => X_EXCHANGE,
          X_CURRENCY_CODE => X_CURRENCY_CODE,
          X_INDUSTRY_CLASS => X_INDUSTRY_CLASS,
          X_ISSUE_TYPE => X_ISSUE_TYPE
   );

   if (sql%notfound) then
      raise no_data_found;
   end if;

EXCEPTION
   WHEN no_data_found THEN
   --dbms_output.put_line('before insert_row');
       INSERT_ROW(
          X_ROWID => l_row_id,
          X_STOCK_ID => l_stock_id,
          X_OBJECT_VERSION_NUMBER => l_object_version_number,
          X_LAST_UPDATE_DATE => sysdate,
          X_LAST_UPDATED_BY => l_user_id,
          X_CREATION_DATE => sysdate,
          X_CREATED_BY => l_user_id,
          X_LAST_UPDATE_LOGIN => 0,
          X_STOCK_SYMBOL => X_STOCK_SYMBOL,
          X_STOCK_RIC => X_STOCK_RIC,
          X_STOCK_TYPE => X_STOCK_TYPE,
          X_STOCK_DESC => X_STOCK_DESC,
          X_OBSOLETE_FLAG => FND_API.G_FALSE,
          X_COUNTRY_ID => l_country_id,
          X_EXCHANGE => X_EXCHANGE,
          X_CURRENCY_CODE => X_CURRENCY_CODE,
          X_INDUSTRY_CLASS => l_industry_class,
          X_ISSUE_TYPE => l_issue_type
       );
END;
procedure INSERT_ROW(
  X_ROWID in out NOCOPY VARCHAR2,
  X_STOCK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_STOCK_SYMBOL in VARCHAR2,
  X_STOCK_RIC in VARCHAR2,
  X_STOCK_TYPE in VARCHAR2,
  X_STOCK_DESC in VARCHAR2,
  X_OBSOLETE_FLAG in VARCHAR2,
  X_COUNTRY_ID in NUMBER,
  X_EXCHANGE in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_INDUSTRY_CLASS in NUMBER,
  X_ISSUE_TYPE in NUMBER
) AS
  cursor C is select ROWID from AMV_STOCKS
    where stock_id = x_stock_id;

BEGIN
   insert into AMV_STOCKS (
      STOCK_ID,
      OBJECT_VERSION_NUMBER,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      STOCK_SYMBOL,
      STOCK_RIC,
      STOCK_TYPE,
      STOCK_DESC,
      OBSOLETE_FLAG,
      COUNTRY_ID,
      EXCHANGE,
      CURRENCY_CODE,
      INDUSTRY_CLASS,
      ISSUE_TYPE
   ) VALUES (
       X_STOCK_ID,
       X_OBJECT_VERSION_NUMBER,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_LOGIN,
       X_STOCK_SYMBOL,
       X_STOCK_RIC,
       X_STOCK_TYPE,
       X_STOCK_DESC,
       X_OBSOLETE_FLAG,
       X_COUNTRY_ID,
       X_EXCHANGE,
       X_CURRENCY_CODE,
       X_INDUSTRY_CLASS,
       X_ISSUE_TYPE
   );

 open c;
 fetch c into X_ROWID;
 if (c%notfound) then
    close c;
    raise no_data_found;
 end if;
 close c;
END;
procedure UPDATE_ROW(
  X_STOCK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_STOCK_SYMBOL in VARCHAR2,
  X_STOCK_RIC in VARCHAR2,
  X_STOCK_TYPE in VARCHAR2,
  X_STOCK_DESC in VARCHAR2,
  X_COUNTRY_ID in NUMBER,
  X_EXCHANGE in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_INDUSTRY_CLASS in NUMBER,
  X_ISSUE_TYPE in NUMBER
) AS
BEGIN
   Update AMV_STOCKS SET
        OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        STOCK_SYMBOL = X_STOCK_SYMBOL,
        STOCK_RIC = X_STOCK_RIC,
        STOCK_TYPE = X_STOCK_TYPE,
        STOCK_DESC = X_STOCK_DESC,
        COUNTRY_ID = X_COUNTRY_ID,
        EXCHANGE = X_EXCHANGE,
        CURRENCY_CODE = X_CURRENCY_CODE,
        INDUSTRY_CLASS = X_INDUSTRY_CLASS,
        ISSUE_TYPE = X_ISSUE_TYPE
   where stock_id = X_STOCK_ID;
END;

END AMV_STOCK_LD_PKG;

/
