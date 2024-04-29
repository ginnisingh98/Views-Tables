--------------------------------------------------------
--  DDL for Package Body IBE_ACTIVE_QUOTES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ACTIVE_QUOTES_ALL_PKG" as
/*$Header: IBEVAQRB.pls 120.1 2005/08/24 21:56:03 appldev ship $ */
procedure INSERT_ROW (
  X_OBJECT_VERSION_NUMBER  in NUMBER,
  /*X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID             in NUMBER,
  X_PROGRAM_UPDATE_DATE    in DATE,*/
  X_QUOTE_HEADER_ID       in NUMBER,
  X_PARTY_ID              in NUMBER,
  X_CUST_ACCOUNT_ID       in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_CREATION_DATE         in DATE,
  X_CREATED_BY            in NUMBER,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_RECORD_TYPE           in VARCHAR2,
  X_ORDER_HEADER_ID       in NUMBER,
  X_CURRENCY_CODE         in VARCHAR2,
  X_ORG_ID                in NUMBER := MO_GLOBAL.get_current_org_id()
) is

L_ORG_ID            NUMBER;
l_last_update_login NUMBER;
l_active_quote_id   NUMBER;

BEGIN

IF (X_RECORD_TYPE NOT IN ('CART','ORDER')) Then
   FND_MESSAGE.Set_Name('IBE','IBE_PRMT_REQUIRED_MISSING_G');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
END IF;

IF (X_RECORD_TYPE = 'CART')
THEN
  IF ((X_PARTY_ID is null OR X_PARTY_ID =FND_API.G_MISS_NUM)
  OR (X_CUST_ACCOUNT_ID is null OR X_CUST_ACCOUNT_ID = FND_API.G_MISS_NUM))
  THEN
     FND_MESSAGE.Set_Name('IBE','IBE_PRMT_REQUIRED_MISSING_G');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 END IF;

  if (X_RECORD_TYPE = 'ORDER')
  then
     if ((X_PARTY_ID is null OR X_PARTY_ID =FND_API.G_MISS_NUM)
     OR (X_CUST_ACCOUNT_ID is null OR X_CUST_ACCOUNT_ID = FND_API.G_MISS_NUM)
     OR (X_CURRENCY_CODE is null OR X_CURRENCY_CODE = FND_API.G_MISS_CHAR))
     then
       FND_MESSAGE.Set_Name('IBE','IBE_PRMT_REQUIRED_MISSING_G');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     end if;
  end if;

 l_last_update_login := FND_GLOBAL.CONC_LOGIN_ID;
 IF ((x_org_id is null ) or (x_org_id = FND_API.G_MISS_NUM)) THEN
     l_org_id := MO_GLOBAL.get_current_org_id();
 ELSE
   l_org_id := x_org_id;
 END IF;

  select nvl(IBE_ACTIVE_QUOTES_ALL_S1.nextval,0) into l_active_quote_id
  from dual;

  insert into IBE_ACTIVE_QUOTES_ALL (
    ACTIVE_QUOTE_ID,
    /*PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,*/
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    QUOTE_HEADER_ID,
    PARTY_ID,
    CUST_ACCOUNT_ID,
    RECORD_TYPE,
    ORDER_HEADER_ID,
    CURRENCY_CODE,
    ORG_ID
  )
  VALUES(
    DECODE(L_ACTIVE_QUOTE_ID ,FND_API.G_MISS_NUM,NULL,L_ACTIVE_QUOTE_ID),
    /*DECODE(x_PROGRAM_APPLICATION_ID ,FND_API.G_MISS_NUM,NULL,x_PROGRAM_APPLICATION_ID),
    DECODE(x_PROGRAM_ID             ,FND_API.G_MISS_NUM,NULL,x_PROGRAM_ID),
    DECODE(x_PROGRAM_UPDATE_DATE    ,FND_API.G_MISS_DATE,NULL,x_PROGRAM_UPDATE_DATE),*/
    DECODE(x_OBJECT_VERSION_NUMBER  ,FND_API.G_MISS_NUM,NULL,x_OBJECT_VERSION_NUMBER),
    DECODE(x_CREATED_BY             ,FND_API.G_MISS_NUM,NULL,x_CREATED_BY),
    DECODE(x_CREATION_DATE          ,FND_API.G_MISS_DATE,NULL,x_CREATION_DATE),
    DECODE(x_LAST_UPDATED_BY        ,FND_API.G_MISS_NUM,NULL,x_LAST_UPDATED_BY),
    DECODE(x_LAST_UPDATE_DATE       ,FND_API.G_MISS_DATE,NULL,x_LAST_UPDATE_DATE),
    DECODE(x_LAST_UPDATE_LOGIN      ,FND_API.G_MISS_NUM,NULL,x_LAST_UPDATE_LOGIN),
    DECODE(x_QUOTE_HEADER_ID        ,FND_API.G_MISS_NUM,NULL,x_QUOTE_HEADER_ID),
    DECODE(x_PARTY_ID               ,FND_API.G_MISS_NUM,NULL,x_PARTY_ID),
    DECODE(x_CUST_ACCOUNT_ID        ,FND_API.G_MISS_NUM,NULL,x_CUST_ACCOUNT_ID),
    DECODE(x_RECORD_TYPE            ,FND_API.G_MISS_CHAR,NULL,x_RECORD_TYPE),
    DECODE(x_ORDER_HEADER_ID        ,FND_API.G_MISS_NUM,NULL,x_ORDER_HEADER_ID),
    DECODE(x_CURRENCY_CODE          ,FND_API.G_MISS_CHAR,NULL,x_CURRENCY_CODE),
    DECODE(l_ORG_ID                 ,FND_API.G_MISS_NUM,NULL,l_ORG_ID));

end INSERT_ROW;

procedure UPDATE_ROW (
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUOTE_HEADER_ID       in NUMBER,
  X_PARTY_ID              in NUMBER,
  X_CUST_ACCOUNT_ID       in NUMBER,
  X_ORDER_HEADER_ID       in NUMBER,
  X_RECORD_TYPE           in VARCHAR2,
  X_CURRENCY_CODE         in VARCHAR2,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER
) is
L_ORG_ID            NUMBER := 204; --$$check this hard coding$$
l_last_update_login NUMBER;
begin
  l_last_update_login := FND_GLOBAL.CONC_LOGIN_ID;
  l_org_id := MO_GLOBAL.get_current_org_id();

    --$$GET THE ORG_ID HERE$$
    if (X_RECORD_TYPE = 'CART')
    then

    update IBE_ACTIVE_QUOTES_ALL set
      OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
      QUOTE_HEADER_ID       = DECODE(X_QUOTE_HEADER_ID,FND_API.G_MISS_NUM,NULL,X_QUOTE_HEADER_ID),
      ORDER_HEADER_ID       = DECODE(X_ORDER_HEADER_ID,FND_API.G_MISS_NUM,NULL,X_ORDER_HEADER_ID),
      PARTY_ID              = X_PARTY_ID,
      CUST_ACCOUNT_ID       = X_CUST_ACCOUNT_ID,
      LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN
    where nvl(ORG_ID,-99)   = nvl(l_org_id,-99)
    AND   PARTY_ID        = X_PARTY_ID
    AND   CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID
    AND   RECORD_TYPE     = X_RECORD_TYPE;

   elsif (X_RECORD_TYPE='ORDER') then

      update IBE_ACTIVE_QUOTES_ALL set
      OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
      QUOTE_HEADER_ID       = DECODE(X_QUOTE_HEADER_ID,FND_API.G_MISS_NUM,NULL,X_QUOTE_HEADER_ID),
      ORDER_HEADER_ID       = DECODE(X_ORDER_HEADER_ID,FND_API.G_MISS_NUM,NULL,X_ORDER_HEADER_ID),
      PARTY_ID              = X_PARTY_ID,
      CUST_ACCOUNT_ID       = X_CUST_ACCOUNT_ID,
      LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN
    where nvl(ORG_ID,-99)   = nvl(l_org_id,-99)
    AND   PARTY_ID        = X_PARTY_ID
    AND   CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID
    AND   RECORD_TYPE     = X_RECORD_TYPE
    AND   CURRENCY_CODE   = X_CURRENCY_CODE;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUOTE_HEADER_ID IN NUMBER,
  X_PARTY_ID        IN NUMBER,
  X_ORDER_HEADER_ID IN NUMBER,
  X_CURRENCY_CODE   IN VARCHAR2,
  X_RECORD_TYPE     IN VARCHAR2,
  X_CUST_ACCOUNT_ID IN NUMBER
) is
begin

 IF (X_RECORD_TYPE = 'CART')
 THEN
    delete from IBE_ACTIVE_QUOTES
    where quote_header_id = x_quote_header_id
    and   party_id        = x_party_id
   and   cust_account_id = x_cust_account_id
   and record_type = x_record_type;

  ELSIF (X_RECORD_TYPE = 'ORDER')
  THEN
    delete from IBE_ACTIVE_QUOTES
    where order_header_id = x_order_header_id
    and   party_id        = x_party_id
    and   cust_account_id = x_cust_account_id
    and record_type = x_record_type
    and currency_code = x_currency_code;
  END IF;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IBE_ACTIVE_QUOTES_ALL_PKG;

/
