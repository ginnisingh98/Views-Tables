--------------------------------------------------------
--  DDL for Package Body OZF_FUND_UTILIZED_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_UTILIZED_ALL_PKG" as
/* $Header: ozflfutb.pls 120.1 2008/03/28 06:27:03 bkunjan noship $ */
procedure INSERT_ROW (
   X_ROWID                     IN OUT NOCOPY VARCHAR2,
   P_UTILIZATION_ID             IN NUMBER,
   P_LAST_UPDATE_DATE           IN DATE,
   P_LAST_UPDATED_BY            IN NUMBER,
   P_LAST_UPDATE_LOGIN          IN NUMBER,
   P_CREATION_DATE              IN DATE,
   P_CREATED_BY                 IN NUMBER,
   P_CREATED_FROM               IN VARCHAR2,
   P_REQUEST_ID                 IN NUMBER,
   P_UTILIZATION_TYPE           IN VARCHAR2,
   P_FUND_ID                    IN NUMBER,
   P_PLAN_TYPE                  IN VARCHAR2,
   P_PLAN_ID                    IN NUMBER,
   P_COMPONENT_TYPE             IN VARCHAR2,
   P_COMPONENT_ID               IN NUMBER,
   P_OBJECT_TYPE                IN VARCHAR2,
   P_OBJECT_ID                  IN NUMBER,
   P_ORDER_ID                   IN NUMBER,
   P_INVOICE_ID                 IN NUMBER,
   P_AMOUNT                     IN NUMBER,
   P_ACCTD_AMOUNT               IN NUMBER,
   P_CURRENCY_CODE              IN VARCHAR2,
   P_EXCHANGE_RATE_TYPE         IN VARCHAR2,
   P_EXCHANGE_RATE_DATE         IN DATE,
   P_EXCHANGE_RATE              IN NUMBER,
   P_ADJUSTMENT_TYPE            IN VARCHAR2,
   P_ADJUSTMENT_DATE            IN DATE,
   P_ADJUSTMENT_DESC            IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER      IN NUMBER,
   P_ATTRIBUTE_CATEGORY         IN VARCHAR2,
   P_ATTRIBUTE1                 IN VARCHAR2,
   P_ATTRIBUTE2                 IN VARCHAR2,
   P_ATTRIBUTE3                 IN VARCHAR2,
   P_ATTRIBUTE4                 IN VARCHAR2,
   P_ATTRIBUTE5                 IN VARCHAR2,
   P_ATTRIBUTE6                 IN VARCHAR2,
   P_ATTRIBUTE7                 IN VARCHAR2,
   P_ATTRIBUTE8                 IN VARCHAR2,
   P_ATTRIBUTE9                 IN VARCHAR2,
   P_ATTRIBUTE10                IN VARCHAR2,
   P_ATTRIBUTE11                IN VARCHAR2,
   P_ATTRIBUTE12                IN VARCHAR2,
   P_ATTRIBUTE13                IN VARCHAR2,
   P_ATTRIBUTE14                IN VARCHAR2,
   P_ATTRIBUTE15                IN VARCHAR2
) is

  cursor C is
    select ROWID from OZF_FUNDS_UTILIZED_ALL_B
    where UTILIZATION_ID = P_UTILIZATION_ID;

begin
  insert into OZF_FUNDS_UTILIZED_ALL_B (
    UTILIZATION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    CREATED_FROM,
    REQUEST_ID,
    UTILIZATION_TYPE,
    FUND_ID,
    PLAN_TYPE,
    PLAN_ID,
    COMPONENT_TYPE,
    COMPONENT_ID,
    OBJECT_TYPE,
    OBJECT_ID,
    ORDER_ID,
    INVOICE_ID,
    AMOUNT,
    ACCTD_AMOUNT,
    CURRENCY_CODE,
    EXCHANGE_RATE_TYPE,
    EXCHANGE_RATE_DATE,
    EXCHANGE_RATE,
    ADJUSTMENT_TYPE,
    ADJUSTMENT_DATE,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15
  ) values (
    P_UTILIZATION_ID,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_CREATED_FROM,
    P_REQUEST_ID,
    P_UTILIZATION_TYPE,
    P_FUND_ID,
    P_PLAN_TYPE,
    P_PLAN_ID,
    P_COMPONENT_TYPE,
    P_COMPONENT_ID,
    P_OBJECT_TYPE,
    P_OBJECT_ID,
    P_ORDER_ID,
    P_INVOICE_ID,
    P_AMOUNT,
    P_ACCTD_AMOUNT,
    P_CURRENCY_CODE,
    P_EXCHANGE_RATE_TYPE,
    P_EXCHANGE_RATE_DATE,
    P_EXCHANGE_RATE,
    P_ADJUSTMENT_TYPE,
    P_ADJUSTMENT_DATE,
    P_OBJECT_VERSION_NUMBER,
    P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15
  );

  insert into OZF_FUNDS_UTILIZED_ALL_TL (
    UTILIZATION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    CREATED_FROM,
    REQUEST_ID,
    ADJUSTMENT_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
        P_UTILIZATION_ID,
        P_LAST_UPDATE_DATE,
        P_LAST_UPDATED_BY,
        P_LAST_UPDATE_LOGIN,
        P_CREATION_DATE,
        P_CREATED_BY,
        P_CREATED_FROM,
        P_REQUEST_ID,
        P_ADJUSTMENT_DESC,
        L.LANGUAGE_CODE,
        userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists(
        select NULL
        from OZF_FUNDS_UTILIZED_ALL_TL T
        where T.UTILIZATION_ID = P_UTILIZATION_ID
        and T.LANGUAGE = L.LANGUAGE_CODE
    );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


procedure LOCK_ROW (
   P_UTILIZATION_ID             IN NUMBER,
   P_CREATED_FROM               IN VARCHAR2,
   P_REQUEST_ID                 IN NUMBER,
   P_UTILIZATION_TYPE           IN VARCHAR2,
   P_FUND_ID                    IN NUMBER,
   P_PLAN_TYPE                  IN VARCHAR2,
   P_PLAN_ID                    IN NUMBER,
   P_COMPONENT_TYPE             IN VARCHAR2,
   P_COMPONENT_ID               IN NUMBER,
   P_OBJECT_TYPE                IN VARCHAR2,
   P_OBJECT_ID                  IN NUMBER,
   P_ORDER_ID                   IN NUMBER,
   P_INVOICE_ID                 IN NUMBER,
   P_AMOUNT                     IN NUMBER,
   P_ACCTD_AMOUNT               IN NUMBER,
   P_CURRENCY_CODE              IN VARCHAR2,
   P_EXCHANGE_RATE_TYPE         IN VARCHAR2,
   P_EXCHANGE_RATE_DATE         IN DATE,
   P_EXCHANGE_RATE              IN NUMBER,
   P_ADJUSTMENT_TYPE            IN VARCHAR2,
   P_ADJUSTMENT_DATE            IN DATE,
   P_ADJUSTMENT_DESC            IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER      IN NUMBER,
   P_ATTRIBUTE_CATEGORY         IN VARCHAR2,
   P_ATTRIBUTE1                 IN VARCHAR2,
   P_ATTRIBUTE2                 IN VARCHAR2,
   P_ATTRIBUTE3                 IN VARCHAR2,
   P_ATTRIBUTE4                 IN VARCHAR2,
   P_ATTRIBUTE5                 IN VARCHAR2,
   P_ATTRIBUTE6                 IN VARCHAR2,
   P_ATTRIBUTE7                 IN VARCHAR2,
   P_ATTRIBUTE8                 IN VARCHAR2,
   P_ATTRIBUTE9                 IN VARCHAR2,
   P_ATTRIBUTE10                IN VARCHAR2,
   P_ATTRIBUTE11                IN VARCHAR2,
   P_ATTRIBUTE12                IN VARCHAR2,
   P_ATTRIBUTE13                IN VARCHAR2,
   P_ATTRIBUTE14                IN VARCHAR2,
   P_ATTRIBUTE15                IN VARCHAR2
) is
  cursor c is
     select CREATED_FROM,
            REQUEST_ID,
            UTILIZATION_TYPE,
            FUND_ID,
            PLAN_TYPE,
            PLAN_ID,
            COMPONENT_TYPE,
            COMPONENT_ID,
            OBJECT_TYPE,
            OBJECT_ID,
            ORDER_ID,
            INVOICE_ID,
            AMOUNT,
            ACCTD_AMOUNT,
            CURRENCY_CODE,
            EXCHANGE_RATE_TYPE,
            EXCHANGE_RATE_DATE,
            EXCHANGE_RATE,
            ADJUSTMENT_TYPE,
            ADJUSTMENT_DATE,
            OBJECT_VERSION_NUMBER,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15
     from OZF_FUNDS_UTILIZED_ALL_B
     where UTILIZATION_ID = P_UTILIZATION_ID
     for update of UTILIZATION_ID nowait;

  recinfo c%rowtype;

  cursor c1 is
     select ADJUSTMENT_DESC,
            decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
     from OZF_FUNDS_UTILIZED_ALL_TL
     where UTILIZATION_ID = P_UTILIZATION_ID
     and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
     for update of UTILIZATION_ID nowait;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.CREATED_FROM = P_CREATED_FROM)
           OR ((recinfo.CREATED_FROM is null) AND (P_CREATED_FROM is null)))
      AND ((recinfo.REQUEST_ID = P_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (P_REQUEST_ID is null)))
      AND ((recinfo.UTILIZATION_TYPE = p_UTILIZATION_TYPE)
           OR ((recinfo.UTILIZATION_TYPE is null) AND (P_UTILIZATION_TYPE is null)))
      AND (recinfo.FUND_ID = P_FUND_ID)
      AND ((recinfo.PLAN_TYPE = P_PLAN_TYPE)
           OR ((recinfo.PLAN_TYPE is null) AND (P_PLAN_TYPE is null)))
      AND ((recinfo.PLAN_ID = P_PLAN_ID)
           OR ((recinfo.PLAN_ID is null) AND (P_PLAN_ID is null)))
      AND ((recinfo.COMPONENT_TYPE = P_COMPONENT_TYPE)
           OR ((recinfo.COMPONENT_TYPE is null) AND (P_COMPONENT_TYPE is null)))
      AND ((recinfo.COMPONENT_ID = P_COMPONENT_ID)
           OR ((recinfo.COMPONENT_ID is null) AND (P_COMPONENT_ID is null)))
      AND ((recinfo.OBJECT_TYPE = P_OBJECT_TYPE)
           OR ((recinfo.OBJECT_TYPE is null) AND (P_OBJECT_TYPE is null)))
      AND ((recinfo.OBJECT_ID = P_OBJECT_ID)
           OR ((recinfo.OBJECT_ID is null) AND (P_OBJECT_ID is null)))
      AND ((recinfo.ORDER_ID = P_ORDER_ID)
           OR ((recinfo.ORDER_ID is null) AND (P_ORDER_ID is null)))
      AND ((recinfo.INVOICE_ID = P_INVOICE_ID)
           OR ((recinfo.INVOICE_ID is null) AND (P_INVOICE_ID is null)))
      AND (recinfo.AMOUNT = P_AMOUNT)
      AND ((recinfo.ACCTD_AMOUNT = P_ACCTD_AMOUNT)
           OR ((recinfo.ACCTD_AMOUNT is null) AND (P_ACCTD_AMOUNT is null)))
      AND ((recinfo.CURRENCY_CODE = P_CURRENCY_CODE)
           OR ((recinfo.CURRENCY_CODE is null) AND (P_CURRENCY_CODE is null)))
      AND ((recinfo.EXCHANGE_RATE_TYPE = P_EXCHANGE_RATE_TYPE)
           OR ((recinfo.EXCHANGE_RATE_TYPE is null) AND (P_EXCHANGE_RATE_TYPE is null)))
      AND ((recinfo.EXCHANGE_RATE_DATE = P_EXCHANGE_RATE_DATE)
           OR ((recinfo.EXCHANGE_RATE_DATE is null) AND (P_EXCHANGE_RATE_DATE is null)))
      AND ((recinfo.EXCHANGE_RATE = P_EXCHANGE_RATE)
           OR ((recinfo.EXCHANGE_RATE is null) AND (P_EXCHANGE_RATE is null)))
      AND ((recinfo.ADJUSTMENT_TYPE = P_ADJUSTMENT_TYPE)
           OR ((recinfo.ADJUSTMENT_TYPE is null) AND (P_ADJUSTMENT_TYPE is null)))
      AND ((recinfo.ADJUSTMENT_DATE = P_ADJUSTMENT_DATE)
           OR ((recinfo.ADJUSTMENT_DATE is null) AND (P_ADJUSTMENT_DATE is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (P_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (P_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (P_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (P_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (P_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (P_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (P_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ADJUSTMENT_DESC = P_ADJUSTMENT_DESC)
          OR ((tlinfo.ADJUSTMENT_DESC is null) AND (P_ADJUSTMENT_DESC is null))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

end LOCK_ROW;


procedure UPDATE_ROW (
   P_UTILIZATION_ID             IN NUMBER,
   P_LAST_UPDATE_DATE           IN DATE,
   P_LAST_UPDATED_BY            IN NUMBER,
   P_LAST_UPDATE_LOGIN          IN NUMBER,
   P_CREATED_FROM               IN VARCHAR2,
   P_REQUEST_ID                 IN NUMBER,
   P_UTILIZATION_TYPE           IN VARCHAR2,
   P_FUND_ID                    IN NUMBER,
   P_PLAN_TYPE                  IN VARCHAR2,
   P_PLAN_ID                    IN NUMBER,
   P_COMPONENT_TYPE             IN VARCHAR2,
   P_COMPONENT_ID               IN NUMBER,
   P_OBJECT_TYPE                IN VARCHAR2,
   P_OBJECT_ID                  IN NUMBER,
   P_ORDER_ID                   IN NUMBER,
   P_INVOICE_ID                 IN NUMBER,
   P_AMOUNT                     IN NUMBER,
   P_ACCTD_AMOUNT               IN NUMBER,
   P_CURRENCY_CODE              IN VARCHAR2,
   P_EXCHANGE_RATE_TYPE         IN VARCHAR2,
   P_EXCHANGE_RATE_DATE         IN DATE,
   P_EXCHANGE_RATE              IN NUMBER,
   P_ADJUSTMENT_TYPE            IN VARCHAR2,
   P_ADJUSTMENT_DATE            IN DATE,
   P_ADJUSTMENT_DESC            IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER      IN NUMBER,
   P_ATTRIBUTE_CATEGORY         IN VARCHAR2,
   P_ATTRIBUTE1                 IN VARCHAR2,
   P_ATTRIBUTE2                 IN VARCHAR2,
   P_ATTRIBUTE3                 IN VARCHAR2,
   P_ATTRIBUTE4                 IN VARCHAR2,
   P_ATTRIBUTE5                 IN VARCHAR2,
   P_ATTRIBUTE6                 IN VARCHAR2,
   P_ATTRIBUTE7                 IN VARCHAR2,
   P_ATTRIBUTE8                 IN VARCHAR2,
   P_ATTRIBUTE9                 IN VARCHAR2,
   P_ATTRIBUTE10                IN VARCHAR2,
   P_ATTRIBUTE11                IN VARCHAR2,
   P_ATTRIBUTE12                IN VARCHAR2,
   P_ATTRIBUTE13                IN VARCHAR2,
   P_ATTRIBUTE14                IN VARCHAR2,
   P_ATTRIBUTE15                IN VARCHAR2
) is

begin
  update OZF_FUNDS_UTILIZED_ALL_B set
        LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = P_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
        CREATED_FROM = P_CREATED_FROM,
        REQUEST_ID = P_REQUEST_ID,
        UTILIZATION_TYPE = P_UTILIZATION_TYPE,
        FUND_ID = P_FUND_ID,
        PLAN_TYPE = P_PLAN_TYPE,
        PLAN_ID = P_PLAN_ID,
        COMPONENT_TYPE = P_COMPONENT_TYPE,
        COMPONENT_ID = P_COMPONENT_ID,
        OBJECT_TYPE = P_OBJECT_TYPE,
        OBJECT_ID = P_OBJECT_ID,
        ORDER_ID = P_ORDER_ID,
        INVOICE_ID = P_INVOICE_ID,
        AMOUNT = P_AMOUNT,
        ACCTD_AMOUNT = P_ACCTD_AMOUNT,
        CURRENCY_CODE = P_CURRENCY_CODE,
        EXCHANGE_RATE_TYPE = P_EXCHANGE_RATE_TYPE,
        EXCHANGE_RATE_DATE = P_EXCHANGE_RATE_DATE,
        EXCHANGE_RATE = P_EXCHANGE_RATE,
        ADJUSTMENT_TYPE = P_ADJUSTMENT_TYPE,
        ADJUSTMENT_DATE = P_ADJUSTMENT_DATE,
        OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
        ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY,
        ATTRIBUTE1 = P_ATTRIBUTE1,
        ATTRIBUTE2 = P_ATTRIBUTE2,
        ATTRIBUTE3 = P_ATTRIBUTE3,
        ATTRIBUTE4 = P_ATTRIBUTE4,
        ATTRIBUTE5 = P_ATTRIBUTE5,
        ATTRIBUTE6 = P_ATTRIBUTE6,
        ATTRIBUTE7 = P_ATTRIBUTE7,
        ATTRIBUTE8 = P_ATTRIBUTE8,
        ATTRIBUTE9 = P_ATTRIBUTE9,
        ATTRIBUTE10 = P_ATTRIBUTE10,
        ATTRIBUTE11 = P_ATTRIBUTE11,
        ATTRIBUTE12 = P_ATTRIBUTE12,
        ATTRIBUTE13 = P_ATTRIBUTE13,
        ATTRIBUTE14 = P_ATTRIBUTE14,
        ATTRIBUTE15 = P_ATTRIBUTE15
  where UTILIZATION_ID = P_UTILIZATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OZF_FUNDS_UTILIZED_ALL_TL set
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    ADJUSTMENT_DESC = P_ADJUSTMENT_DESC,
    SOURCE_LANG = userenv('LANG')
  where UTILIZATION_ID = P_UTILIZATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
  P_UTILIZATION_ID  IN NUMBER
) is
begin
  delete from OZF_FUNDS_UTILIZED_ALL_TL
  where UTILIZATION_ID = P_UTILIZATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from OZF_FUNDS_UTILIZED_ALL_B
  where UTILIZATION_ID = P_UTILIZATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from OZF_FUNDS_UTILIZED_ALL_TL T
  where not exists
    (select NULL
     from OZF_FUNDS_UTILIZED_ALL_B B
     where B.UTILIZATION_ID = T.UTILIZATION_ID
    );

  update OZF_FUNDS_UTILIZED_ALL_TL T
  set ADJUSTMENT_DESC = (select B.ADJUSTMENT_DESC
                         from OZF_FUNDS_UTILIZED_ALL_TL B
                         where B.UTILIZATION_ID = T.UTILIZATION_ID
                         and B.LANGUAGE = T.SOURCE_LANG)
  where ( T.UTILIZATION_ID,
          T.LANGUAGE )
  in (select SUBT.UTILIZATION_ID,
             SUBT.LANGUAGE
      from OZF_FUNDS_UTILIZED_ALL_TL SUBB, OZF_FUNDS_UTILIZED_ALL_TL SUBT
      where SUBB.UTILIZATION_ID = SUBT.UTILIZATION_ID
      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and (SUBB.ADJUSTMENT_DESC <> SUBT.ADJUSTMENT_DESC
            or (SUBB.ADJUSTMENT_DESC is null and SUBT.ADJUSTMENT_DESC is not null)
            or (SUBB.ADJUSTMENT_DESC is not null and SUBT.ADJUSTMENT_DESC is null)));

  insert into OZF_FUNDS_UTILIZED_ALL_TL (
    UTILIZATION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    CREATED_FROM,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    ADJUSTMENT_DESC,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
        B.UTILIZATION_ID,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATED_BY,
        B.LAST_UPDATE_LOGIN,
        B.CREATION_DATE,
        B.CREATED_BY,
        B.CREATED_FROM,
        B.REQUEST_ID,
        B.PROGRAM_APPLICATION_ID,
        B.PROGRAM_ID,
        B.PROGRAM_UPDATE_DATE,
        B.ADJUSTMENT_DESC,
        L.LANGUAGE_CODE,
        B.SOURCE_LANG,
        B.ORG_ID
    from OZF_FUNDS_UTILIZED_ALL_TL B, FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and B.LANGUAGE = userenv('LANG')
    and not exists
    (select NULL
     from OZF_FUNDS_UTILIZED_ALL_TL T
     where T.UTILIZATION_ID = B.UTILIZATION_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


procedure TRANSLATE_ROW(
  P_UTILIZATION_ID  IN NUMBER,
  P_ADJUSTMENT_DESC IN VARCHAR2,
  P_OWNERS          IN VARCHAR2
)
is
begin
  update OZF_FUNDS_UTILIZED_ALL_TL set
    ADJUSTMENT_DESC = nvl(P_ADJUSTMENT_DESC, ADJUSTMENT_DESC),
    SOURCE_LANG = userenv('LANG'),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = decode(P_OWNERS, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0
  where UTILIZATION_ID = P_UTILIZATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end TRANSLATE_ROW;


procedure  LOAD_ROW(
   P_UTILIZATION_ID             IN NUMBER,
   P_CREATED_FROM               IN VARCHAR2,
   P_REQUEST_ID                 IN NUMBER,
   P_UTILIZATION_TYPE           IN VARCHAR2,
   P_FUND_ID                    IN NUMBER,
   P_PLAN_TYPE                  IN VARCHAR2,
   P_PLAN_ID                    IN NUMBER,
   P_COMPONENT_TYPE             IN VARCHAR2,
   P_COMPONENT_ID               IN NUMBER,
   P_OBJECT_TYPE                IN VARCHAR2,
   P_OBJECT_ID                  IN NUMBER,
   P_ORDER_ID                   IN NUMBER,
   P_INVOICE_ID                 IN NUMBER,
   P_AMOUNT                     IN NUMBER,
   P_ACCTD_AMOUNT               IN NUMBER,
   P_CURRENCY_CODE              IN VARCHAR2,
   P_EXCHANGE_RATE_TYPE         IN VARCHAR2,
   P_EXCHANGE_RATE_DATE         IN DATE,
   P_EXCHANGE_RATE              IN NUMBER,
   P_ADJUSTMENT_TYPE            IN VARCHAR2,
   P_ADJUSTMENT_DATE            IN DATE,
   P_ADJUSTMENT_DESC            IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER      IN NUMBER,
   P_ATTRIBUTE_CATEGORY         IN VARCHAR2,
   P_ATTRIBUTE1                 IN VARCHAR2,
   P_ATTRIBUTE2                 IN VARCHAR2,
   P_ATTRIBUTE3                 IN VARCHAR2,
   P_ATTRIBUTE4                 IN VARCHAR2,
   P_ATTRIBUTE5                 IN VARCHAR2,
   P_ATTRIBUTE6                 IN VARCHAR2,
   P_ATTRIBUTE7                 IN VARCHAR2,
   P_ATTRIBUTE8                 IN VARCHAR2,
   P_ATTRIBUTE9                 IN VARCHAR2,
   P_ATTRIBUTE10                IN VARCHAR2,
   P_ATTRIBUTE11                IN VARCHAR2,
   P_ATTRIBUTE12                IN VARCHAR2,
   P_ATTRIBUTE13                IN VARCHAR2,
   P_ATTRIBUTE14                IN VARCHAR2,
   P_ATTRIBUTE15                IN VARCHAR2,
   P_OWNERS                     IN VARCHAR2
)
is

  l_user_id    number := 0;
  l_version    number;
  l_utilization_id    number;
  l_dummy_char varchar2(1);
  l_row_id     varchar2(100);

  cursor c_version is
      select OBJECT_VERSION_NUMBER
      from   OZF_FUNDS_UTILIZED_ALL_B
      where  UTILIZATION_ID = P_UTILIZATION_ID;

  cursor c_utilization_exists is
      select 'x'
      from   OZF_FUNDS_UTILIZED_ALL_B
      where  UTILIZATION_ID = P_UTILIZATION_ID;

  cursor c_utilization_id is
      select OZF_FUNDS_UTILIZED_S.nextval
      from   dual;

begin

  if P_OWNERS = 'SEED' then
    l_user_id := 1;
  end if;

  open c_utilization_exists;
  fetch c_utilization_exists into l_dummy_char;

  if c_utilization_exists%notfound then
    close c_utilization_exists;
    if P_UTILIZATION_ID is not null then
	  l_utilization_id := P_UTILIZATION_ID;
    else
      open c_utilization_id;
      fetch c_utilization_id into l_utilization_id;
      close c_utilization_id;
    end if;
    l_version := 1;
    OZF_FUND_UTILIZED_ALL_PKG.INSERT_ROW(
        X_ROWID                     => l_row_id,
        P_UTILIZATION_ID            => l_utilization_id,
        P_LAST_UPDATE_DATE          => SYSDATE,
        P_LAST_UPDATED_BY           => l_user_id,
        P_LAST_UPDATE_LOGIN         => 0,
        P_CREATION_DATE             => SYSDATE,
        P_CREATED_BY                => l_user_id,
        P_CREATED_FROM              => P_CREATED_FROM,
        P_REQUEST_ID                => P_REQUEST_ID,
        P_UTILIZATION_TYPE          => P_UTILIZATION_TYPE,
        P_FUND_ID                   => P_FUND_ID,
        P_PLAN_TYPE                 => P_PLAN_TYPE,
        P_PLAN_ID                   => P_PLAN_ID,
        P_COMPONENT_TYPE            => P_COMPONENT_TYPE,
        P_COMPONENT_ID              => P_COMPONENT_ID,
        P_OBJECT_TYPE               => P_OBJECT_TYPE,
        P_OBJECT_ID                 => P_OBJECT_ID,
        P_ORDER_ID                  => P_ORDER_ID,
        P_INVOICE_ID                => P_INVOICE_ID,
        P_AMOUNT                    => P_AMOUNT,
        P_ACCTD_AMOUNT              => P_ACCTD_AMOUNT,
        P_CURRENCY_CODE             => P_CURRENCY_CODE,
        P_EXCHANGE_RATE_TYPE        => P_EXCHANGE_RATE_TYPE,
        P_EXCHANGE_RATE_DATE        => P_EXCHANGE_RATE_DATE,
        P_EXCHANGE_RATE             => P_EXCHANGE_RATE,
        P_ADJUSTMENT_TYPE           => P_ADJUSTMENT_TYPE,
        P_ADJUSTMENT_DATE           => P_ADJUSTMENT_DATE,
        P_ADJUSTMENT_DESC           => P_ADJUSTMENT_DESC,
        P_OBJECT_VERSION_NUMBER     => l_version,
        P_ATTRIBUTE_CATEGORY        => P_ATTRIBUTE_CATEGORY,
        P_ATTRIBUTE1                => P_ATTRIBUTE1,
        P_ATTRIBUTE2                => P_ATTRIBUTE2,
        P_ATTRIBUTE3                => P_ATTRIBUTE3,
        P_ATTRIBUTE4                => P_ATTRIBUTE4,
        P_ATTRIBUTE5                => P_ATTRIBUTE5,
        P_ATTRIBUTE6                => P_ATTRIBUTE6,
        P_ATTRIBUTE7                => P_ATTRIBUTE7,
        P_ATTRIBUTE8                => P_ATTRIBUTE8,
        P_ATTRIBUTE9                => P_ATTRIBUTE9,
        P_ATTRIBUTE10               => P_ATTRIBUTE10,
        P_ATTRIBUTE11               => P_ATTRIBUTE11,
        P_ATTRIBUTE12               => P_ATTRIBUTE12,
        P_ATTRIBUTE13               => P_ATTRIBUTE13,
        P_ATTRIBUTE14               => P_ATTRIBUTE14,
        P_ATTRIBUTE15               => P_ATTRIBUTE15
    );
  else
    close c_utilization_exists;
    open c_version;
    fetch c_version into l_version;
    close c_version;
    OZF_FUND_UTILIZED_ALL_PKG.UPDATE_ROW(
        P_UTILIZATION_ID            => l_utilization_id,
        P_LAST_UPDATE_DATE          => SYSDATE,
        P_LAST_UPDATED_BY           => l_user_id,
        P_LAST_UPDATE_LOGIN         => 0,
        P_CREATED_FROM              => P_CREATED_FROM,
        P_REQUEST_ID                => P_REQUEST_ID,
        P_UTILIZATION_TYPE          => P_UTILIZATION_TYPE,
        P_FUND_ID                   => P_FUND_ID,
        P_PLAN_TYPE                 => P_PLAN_TYPE,
        P_PLAN_ID                   => P_PLAN_ID,
        P_COMPONENT_TYPE            => P_COMPONENT_TYPE,
        P_COMPONENT_ID              => P_COMPONENT_ID,
        P_OBJECT_TYPE               => P_OBJECT_TYPE,
        P_OBJECT_ID                 => P_OBJECT_ID,
        P_ORDER_ID                  => P_ORDER_ID,
        P_INVOICE_ID                => P_INVOICE_ID,
        P_AMOUNT                    => P_AMOUNT,
        P_ACCTD_AMOUNT              => P_ACCTD_AMOUNT,
        P_CURRENCY_CODE             => P_CURRENCY_CODE,
        P_EXCHANGE_RATE_TYPE        => P_EXCHANGE_RATE_TYPE,
        P_EXCHANGE_RATE_DATE        => P_EXCHANGE_RATE_DATE,
        P_EXCHANGE_RATE             => P_EXCHANGE_RATE,
        P_ADJUSTMENT_TYPE           => P_ADJUSTMENT_TYPE,
        P_ADJUSTMENT_DATE           => P_ADJUSTMENT_DATE,
        P_ADJUSTMENT_DESC           => P_ADJUSTMENT_DESC,
        P_OBJECT_VERSION_NUMBER     => l_version + 1,
        P_ATTRIBUTE_CATEGORY        => P_ATTRIBUTE_CATEGORY,
        P_ATTRIBUTE1                => P_ATTRIBUTE1,
        P_ATTRIBUTE2                => P_ATTRIBUTE2,
        P_ATTRIBUTE3                => P_ATTRIBUTE3,
        P_ATTRIBUTE4                => P_ATTRIBUTE4,
        P_ATTRIBUTE5                => P_ATTRIBUTE5,
        P_ATTRIBUTE6                => P_ATTRIBUTE6,
        P_ATTRIBUTE7                => P_ATTRIBUTE7,
        P_ATTRIBUTE8                => P_ATTRIBUTE8,
        P_ATTRIBUTE9                => P_ATTRIBUTE9,
        P_ATTRIBUTE10               => P_ATTRIBUTE10,
        P_ATTRIBUTE11               => P_ATTRIBUTE11,
        P_ATTRIBUTE12               => P_ATTRIBUTE12,
        P_ATTRIBUTE13               => P_ATTRIBUTE13,
        P_ATTRIBUTE14               => P_ATTRIBUTE14,
        P_ATTRIBUTE15               => P_ATTRIBUTE15
    );
  end if;

end LOAD_ROW;


end OZF_FUND_UTILIZED_ALL_PKG;

/
