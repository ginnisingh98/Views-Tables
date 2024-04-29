--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_TYPES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_TYPES_ALL_PKG" as
/* $Header: ozflclmb.pls 120.5 2006/08/04 12:51:24 kdhulipa ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_CLAIM_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_FROM in VARCHAR2,
  X_CLAIM_CLASS in VARCHAR2,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_POST_TO_GL_FLAG in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_CREATION_SIGN in VARCHAR2,
  X_GL_ID_DED_ADJ in NUMBER,
  X_GL_ID_DED_ADJ_CLEARING in NUMBER,
  X_GL_ID_DED_CLEARING in NUMBER,
  X_GL_ID_ACCR_PROMO_LIAB in NUMBER,
  X_TRANSACTION_TYPE in NUMBER,
  X_CM_TRX_TYPE_ID in NUMBER,
  X_DM_TRX_TYPE_ID in NUMBER,
  X_CB_TRX_TYPE_ID in NUMBER,
  X_WO_REC_TRX_ID in NUMBER,
  X_ADJ_REC_TRX_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_adjustment_type in VARCHAR2,
  X_ORDER_TYPE_ID in NUMBER,
  X_NEG_WO_REC_TRX_ID in NUMBER,
  X_GL_BALANCING_FLEX_VALUE in VARCHAR2,
  X_ORG_ID in NUMBER
) is
  cursor C is select ROWID from ozf_claim_types_all_b
    where CLAIM_TYPE_ID = X_CLAIM_TYPE_ID
    ;
begin

  insert into ozf_claim_types_all_b (
    ORG_ID,
    CLAIM_TYPE_ID,
    OBJECT_VERSION_NUMBER,
    REQUEST_ID,
    CREATED_FROM,
    CLAIM_CLASS,
    SET_OF_BOOKS_ID,
    POST_TO_GL_FLAG,
    START_DATE,
    END_DATE,
    CREATION_SIGN,
    GL_ID_DED_ADJ,
    GL_ID_DED_ADJ_CLEARING,
    GL_ID_DED_CLEARING,
    GL_ID_ACCR_PROMO_LIAB,
    TRANSACTION_TYPE,
    CM_TRX_TYPE_ID,
    DM_TRX_TYPE_ID,
    CB_TRX_TYPE_ID,
    WO_REC_TRX_ID,
    ADJ_REC_TRX_ID,
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
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    adjustment_type,
    ORDER_TYPE_ID,
    NEG_WO_REC_TRX_ID,
    GL_BALANCING_FLEX_VALUE
  ) values (
    X_ORG_ID,
    X_CLAIM_TYPE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_REQUEST_ID,
    X_CREATED_FROM,
    X_CLAIM_CLASS,
    X_SET_OF_BOOKS_ID,
    X_POST_TO_GL_FLAG,
    X_START_DATE,
    X_END_DATE,
    X_CREATION_SIGN,
    X_GL_ID_DED_ADJ,
    X_GL_ID_DED_ADJ_CLEARING,
    X_GL_ID_DED_CLEARING,
    X_GL_ID_ACCR_PROMO_LIAB,
    X_TRANSACTION_TYPE,
    X_CM_TRX_TYPE_ID,
    X_DM_TRX_TYPE_ID,
    X_CB_TRX_TYPE_ID,
    X_WO_REC_TRX_ID,
    X_ADJ_REC_TRX_ID,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    x_adjustment_type,
    X_ORDER_TYPE_ID,
    X_NEG_WO_REC_TRX_ID,
    X_GL_BALANCING_FLEX_VALUE
  );

  insert into ozf_claim_types_all_tl (
    ORG_ID,
    CLAIM_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ORG_ID,
    X_CLAIM_TYPE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    X_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ozf_claim_types_all_tl T
    where T.CLAIM_TYPE_ID = X_CLAIM_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE
    and   ORG_ID = X_ORG_ID);

    /* and  NVL(ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99) );

  */

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CLAIM_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_FROM in VARCHAR2,
  X_CLAIM_CLASS in VARCHAR2,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_POST_TO_GL_FLAG in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_CREATION_SIGN in VARCHAR2,
  X_GL_ID_DED_ADJ in NUMBER,
  X_GL_ID_DED_ADJ_CLEARING in NUMBER,
  X_GL_ID_DED_CLEARING in NUMBER,
  X_GL_ID_ACCR_PROMO_LIAB in NUMBER,
  X_TRANSACTION_TYPE in NUMBER,
  X_CM_TRX_TYPE_ID in NUMBER,
  X_DM_TRX_TYPE_ID in NUMBER,
  X_CB_TRX_TYPE_ID in NUMBER,
  X_WO_REC_TRX_ID in NUMBER,
  X_ADJ_REC_TRX_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_adjustment_type in VARCHAR2,
  X_ORDER_TYPE_ID in NUMBER  ,
  X_NEG_WO_REC_TRX_ID in NUMBER,
  X_GL_BALANCING_FLEX_VALUE in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      REQUEST_ID,
      CREATED_FROM,
      CLAIM_CLASS,
      SET_OF_BOOKS_ID,
      POST_TO_GL_FLAG,
      START_DATE,
      END_DATE,
      CREATION_SIGN,
      GL_ID_DED_ADJ,
      GL_ID_DED_ADJ_CLEARING,
      GL_ID_DED_CLEARING,
      GL_ID_ACCR_PROMO_LIAB,
      TRANSACTION_TYPE,
      CM_TRX_TYPE_ID,
      DM_TRX_TYPE_ID,
      CB_TRX_TYPE_ID,
      WO_REC_TRX_ID,
      ADJ_REC_TRX_ID,
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
      ATTRIBUTE15,
      adjustment_type,
      ORDER_TYPE_ID,
      NEG_WO_REC_TRX_ID,
      GL_BALANCING_FLEX_VALUE
    from ozf_claim_types_all_b
    where CLAIM_TYPE_ID = X_CLAIM_TYPE_ID
    for update of CLAIM_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ozf_claim_types_all_tl
    where CLAIM_TYPE_ID = X_CLAIM_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    and   NVL(ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    for update of CLAIM_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.CREATED_FROM = X_CREATED_FROM)
           OR ((recinfo.CREATED_FROM is null) AND (X_CREATED_FROM is null)))
      AND (recinfo.CLAIM_CLASS = X_CLAIM_CLASS)
      AND (recinfo.SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID)
      AND (recinfo.POST_TO_GL_FLAG = X_POST_TO_GL_FLAG)
      AND (recinfo.START_DATE = X_START_DATE)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.CREATION_SIGN = X_CREATION_SIGN)
           OR ((recinfo.CREATION_SIGN is null) AND (X_CREATION_SIGN is null)))
      AND ((recinfo.GL_ID_DED_ADJ = X_GL_ID_DED_ADJ)
           OR ((recinfo.GL_ID_DED_ADJ is null) AND (X_GL_ID_DED_ADJ is null)))
      AND ((recinfo.GL_ID_DED_ADJ_CLEARING = X_GL_ID_DED_ADJ_CLEARING)
           OR ((recinfo.GL_ID_DED_ADJ_CLEARING is null) AND (X_GL_ID_DED_ADJ_CLEARING is null)))
      AND ((recinfo.GL_ID_DED_CLEARING = X_GL_ID_DED_CLEARING)
           OR ((recinfo.GL_ID_DED_CLEARING is null) AND (X_GL_ID_DED_CLEARING is null)))
      AND ((recinfo.GL_ID_ACCR_PROMO_LIAB = X_GL_ID_ACCR_PROMO_LIAB)
           OR ((recinfo.GL_ID_ACCR_PROMO_LIAB is null) AND (X_GL_ID_ACCR_PROMO_LIAB is null)))
      AND ((recinfo.TRANSACTION_TYPE = X_TRANSACTION_TYPE)
           OR ((recinfo.TRANSACTION_TYPE is null) AND (X_TRANSACTION_TYPE is null)))
      AND ((recinfo.CM_TRX_TYPE_ID = X_CM_TRX_TYPE_ID)
           OR ((recinfo.CM_TRX_TYPE_ID is null) AND (X_CM_TRX_TYPE_ID is null)))
      AND ((recinfo.DM_TRX_TYPE_ID = X_DM_TRX_TYPE_ID)
           OR ((recinfo.DM_TRX_TYPE_ID is null) AND (X_DM_TRX_TYPE_ID is null)))
      AND ((recinfo.CB_TRX_TYPE_ID = X_CB_TRX_TYPE_ID)
           OR ((recinfo.CB_TRX_TYPE_ID is null) AND (X_CB_TRX_TYPE_ID is null)))
      AND ((recinfo.WO_REC_TRX_ID = X_WO_REC_TRX_ID)
           OR ((recinfo.WO_REC_TRX_ID is null) AND (X_WO_REC_TRX_ID is null)))
      AND ((recinfo.ADJ_REC_TRX_ID = X_ADJ_REC_TRX_ID)
           OR ((recinfo.ADJ_REC_TRX_ID is null) AND (X_ADJ_REC_TRX_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.adjustment_type = X_adjustment_type)
           OR ((recinfo.adjustment_type is null) AND (X_adjustment_type is null)))
       AND ((recinfo.order_type_id = X_ORDER_TYPE_ID)
           OR ((recinfo.order_type_id is null) AND (X_ORDER_TYPE_ID is null)))
      AND ((recinfo.NEG_WO_REC_TRX_ID = X_NEG_WO_REC_TRX_ID)
           OR ((recinfo.NEG_WO_REC_TRX_ID is null) AND (X_NEG_WO_REC_TRX_ID is null)))
      AND ((recinfo.GL_BALANCING_FLEX_VALUE = X_GL_BALANCING_FLEX_VALUE)
           OR ((recinfo.GL_BALANCING_FLEX_VALUE is null) AND (X_GL_BALANCING_FLEX_VALUE is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_CLAIM_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_FROM in VARCHAR2,
  X_CLAIM_CLASS in VARCHAR2,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_POST_TO_GL_FLAG in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_CREATION_SIGN in VARCHAR2,
  X_GL_ID_DED_ADJ in NUMBER,
  X_GL_ID_DED_ADJ_CLEARING in NUMBER,
  X_GL_ID_DED_CLEARING in NUMBER,
  X_GL_ID_ACCR_PROMO_LIAB in NUMBER,
  X_TRANSACTION_TYPE in NUMBER,
  X_CM_TRX_TYPE_ID in NUMBER,
  X_DM_TRX_TYPE_ID in NUMBER,
  X_CB_TRX_TYPE_ID in NUMBER,
  X_WO_REC_TRX_ID in NUMBER,
  X_ADJ_REC_TRX_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_adjustment_type in VARCHAR2,
  X_ORDER_TYPE_ID in NUMBER  ,
  X_NEG_WO_REC_TRX_ID IN NUMBER,
  X_GL_BALANCING_FLEX_VALUE in VARCHAR2,
  X_ORG_ID in NUMBER
) is

begin

 /* IF X_ORG_ID IS NULL THEN
     select nvl(LTRIM(RTRIM(SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
       into L_ORG_ID
       from dual;
  ELSE
     L_ORG_ID := X_ORG_ID;
  END IF; */

  update ozf_claim_types_all_b set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUEST_ID = X_REQUEST_ID,
    CREATED_FROM = X_CREATED_FROM,
    CLAIM_CLASS = X_CLAIM_CLASS,
    SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID,
    POST_TO_GL_FLAG = X_POST_TO_GL_FLAG,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    CREATION_SIGN = X_CREATION_SIGN,
    GL_ID_DED_ADJ = X_GL_ID_DED_ADJ,
    GL_ID_DED_ADJ_CLEARING = X_GL_ID_DED_ADJ_CLEARING,
    GL_ID_DED_CLEARING = X_GL_ID_DED_CLEARING,
    GL_ID_ACCR_PROMO_LIAB = X_GL_ID_ACCR_PROMO_LIAB,
    TRANSACTION_TYPE = X_TRANSACTION_TYPE,
    CM_TRX_TYPE_ID = X_CM_TRX_TYPE_ID,
    DM_TRX_TYPE_ID = X_DM_TRX_TYPE_ID,
    CB_TRX_TYPE_ID = X_CB_TRX_TYPE_ID,
    WO_REC_TRX_ID = X_WO_REC_TRX_ID,
    ADJ_REC_TRX_ID = X_ADJ_REC_TRX_ID,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    adjustment_type = x_adjustment_type,
    ORDER_TYPE_ID   = X_ORDER_TYPE_ID,
    NEG_WO_REC_TRX_ID = X_NEG_WO_REC_TRX_ID,
    GL_BALANCING_FLEX_VALUE = X_GL_BALANCING_FLEX_VALUE
  where CLAIM_TYPE_ID = X_CLAIM_TYPE_ID
  and   ORG_ID = X_ORG_ID;
    /*
    and   NVL(ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
    */
  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ozf_claim_types_all_tl set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CLAIM_TYPE_ID = X_CLAIM_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  and ORG_ID = X_ORG_ID;
  /*
  and NVL(ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
      NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
      NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
      NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
  */
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CLAIM_TYPE_ID in NUMBER,
  X_ORG_ID in NUMBER
) is
begin
  delete from ozf_claim_types_all_tl
  where CLAIM_TYPE_ID = X_CLAIM_TYPE_ID
  and ORG_ID = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ozf_claim_types_all_b
  where CLAIM_TYPE_ID = X_CLAIM_TYPE_ID
  and ORG_ID = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ozf_claim_types_all_tl T
  where not exists
    (select NULL
    from ozf_claim_types_all_b B
    where B.CLAIM_TYPE_ID = T.CLAIM_TYPE_ID
    and   B.ORG_ID = T.ORG_ID
    );

   update ozf_claim_types_all_tl T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from ozf_claim_types_all_tl B
    where B.CLAIM_TYPE_ID = T.CLAIM_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG
    and B.ORG_ID = T.ORG_ID)
  where (
      T.CLAIM_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CLAIM_TYPE_ID,
      SUBT.LANGUAGE
    from ozf_claim_types_all_b SUBB, ozf_claim_types_all_tl SUBT
    where SUBB.CLAIM_TYPE_ID = SUBT.CLAIM_TYPE_ID
    and SUBB.ORG_ID = SUBT.ORG_ID
    );

  insert into ozf_claim_types_all_tl (
    ORG_ID,
    CLAIM_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_ID,
    B.CLAIM_TYPE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ozf_claim_types_all_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ozf_claim_types_all_tl T
    where T.CLAIM_TYPE_ID = B.CLAIM_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE
    and B.ORG_ID = T.ORG_ID );
end ADD_LANGUAGE;


procedure LOAD_SEED_ROW (
  X_UPLOAD_MODE in VARCHAR2,
  X_CLAIM_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_FROM in VARCHAR2,
  X_CLAIM_CLASS in VARCHAR2,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_POST_TO_GL_FLAG in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_CREATION_SIGN in VARCHAR2,
  X_GL_ID_DED_ADJ in NUMBER,
  X_GL_ID_DED_ADJ_CLEARING in NUMBER,
  X_GL_ID_DED_CLEARING in NUMBER,
  X_GL_ID_ACCR_PROMO_LIAB in NUMBER,
  X_TRANSACTION_TYPE in NUMBER,
  X_CM_TRX_TYPE_ID in NUMBER,
  X_DM_TRX_TYPE_ID in NUMBER,
  X_CB_TRX_TYPE_ID in NUMBER,
  X_WO_REC_TRX_ID in NUMBER,
  X_ADJ_REC_TRX_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  x_adjustment_type in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER       in    VARCHAR2,
  X_ORDER_TYPE_ID in NUMBER,
  X_NEG_WO_REC_TRX_ID IN NUMBER ,
  X_GL_BALANCING_FLEX_VALUE IN VARCHAR2,
  X_ORG_ID in NUMBER default NULL
  )
is
begin
     if (X_UPLOAD_MODE = 'NLS') then
         OZF_CLAIM_TYPES_ALL_PKG.TRANSLATE_ROW (
              X_CLAIM_TYPE_ID   => X_CLAIM_TYPE_ID
            , X_NAME            => X_NAME
	    , X_DESCRIPTION     => X_DESCRIPTION
            , X_OWNER           => X_OWNER
	    );
     else
         OZF_CLAIM_TYPES_ALL_PKG.LOAD_ROW (
      X_CLAIM_TYPE_ID	        =>X_CLAIM_TYPE_ID
     ,X_OBJECT_VERSION_NUMBER   =>X_OBJECT_VERSION_NUMBER
     ,X_REQUEST_ID              =>X_REQUEST_ID
     ,X_CREATED_FROM 	        =>X_CREATED_FROM
     ,X_CLAIM_CLASS 	        =>X_CLAIM_CLASS
     ,X_SET_OF_BOOKS_ID	        =>X_SET_OF_BOOKS_ID
     ,X_POST_TO_GL_FLAG	        =>X_POST_TO_GL_FLAG
     ,X_START_DATE 	        =>X_START_DATE
     ,X_END_DATE 	        =>X_END_DATE
     ,X_CREATION_SIGN 	        =>X_CREATION_SIGN
     ,X_GL_ID_DED_ADJ 	        =>X_GL_ID_DED_ADJ
     ,X_GL_ID_DED_ADJ_CLEARING	=>X_GL_ID_DED_ADJ_CLEARING
     ,X_GL_ID_DED_CLEARING	=>X_GL_ID_DED_CLEARING
     ,X_GL_ID_ACCR_PROMO_LIAB	=>X_GL_ID_ACCR_PROMO_LIAB
     ,X_TRANSACTION_TYPE        =>X_TRANSACTION_TYPE
     ,X_CM_TRX_TYPE_ID          =>X_CM_TRX_TYPE_ID
     ,X_DM_TRX_TYPE_ID          =>X_DM_TRX_TYPE_ID
     ,X_CB_TRX_TYPE_ID          =>X_CB_TRX_TYPE_ID
     ,X_WO_REC_TRX_ID           =>X_WO_REC_TRX_ID
     ,X_ADJ_REC_TRX_ID          =>X_ADJ_REC_TRX_ID
     ,X_ATTRIBUTE_CATEGORY      =>X_ATTRIBUTE_CATEGORY
     ,X_ATTRIBUTE1	        =>X_ATTRIBUTE1
     ,X_ATTRIBUTE2	        =>X_ATTRIBUTE2
     ,X_ATTRIBUTE3 	        =>X_ATTRIBUTE3
     ,X_ATTRIBUTE4	        =>X_ATTRIBUTE4
     ,X_ATTRIBUTE5 	        =>X_ATTRIBUTE5
     ,X_ATTRIBUTE6	        =>X_ATTRIBUTE6
     ,X_ATTRIBUTE7    	        =>X_ATTRIBUTE7
     ,X_ATTRIBUTE8	        =>X_ATTRIBUTE8
     ,X_ATTRIBUTE9 	        =>X_ATTRIBUTE9
     ,X_ATTRIBUTE10	        =>X_ATTRIBUTE10
     ,X_ATTRIBUTE11 	        =>X_ATTRIBUTE11
     ,X_ATTRIBUTE12 	        =>X_ATTRIBUTE12
     ,X_ATTRIBUTE13  	        =>X_ATTRIBUTE13
     ,X_ATTRIBUTE14   	        =>X_ATTRIBUTE14
     ,X_ATTRIBUTE15 	        =>X_ATTRIBUTE15
     ,X_ADJUSTMENT_TYPE         =>X_ADJUSTMENT_TYPE
     ,X_NAME	                =>X_NAME
     ,X_DESCRIPTION   	        =>X_DESCRIPTION
     ,X_OWNER 	                =>X_OWNER
     ,X_ORDER_TYPE_ID           =>X_ORDER_TYPE_ID
     ,X_NEG_WO_REC_TRX_ID	=>X_NEG_WO_REC_TRX_ID
     ,X_GL_BALANCING_FLEX_VALUE	=>X_GL_BALANCING_FLEX_VALUE
     ,X_ORG_ID                  =>X_ORG_ID
	    );
	end if;


end;

procedure LOAD_ROW (
  X_CLAIM_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_FROM in VARCHAR2,
  X_CLAIM_CLASS in VARCHAR2,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_POST_TO_GL_FLAG in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_CREATION_SIGN in VARCHAR2,
  X_GL_ID_DED_ADJ in NUMBER,
  X_GL_ID_DED_ADJ_CLEARING in NUMBER,
  X_GL_ID_DED_CLEARING in NUMBER,
  X_GL_ID_ACCR_PROMO_LIAB in NUMBER,
  X_TRANSACTION_TYPE in NUMBER,
  X_CM_TRX_TYPE_ID in NUMBER,
  X_DM_TRX_TYPE_ID in NUMBER,
  X_CB_TRX_TYPE_ID in NUMBER,
  X_WO_REC_TRX_ID in NUMBER,
  X_ADJ_REC_TRX_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ADJUSTMENT_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_ORDER_TYPE_ID in NUMBER,
  X_NEG_WO_REC_TRX_ID in NUMBER,
  x_GL_BALANCING_FLEX_VALUE in VARCHAR2,
  X_ORG_ID in NUMBER
)
IS
--begin

-- declare
     user_id            number := 0;
     row_id             varchar2(64);

    l_dummy_number     number;

     CURSOR csr_chk_claim_type_exist( cv_claim_type_id IN NUMBER
                                    , cv_org_id IN NUMBER) IS
       SELECT 1
       FROM ozf_claim_types_all_vl
       WHERE claim_type_id = cv_claim_type_id
       AND org_id = cv_org_id;


  begin

     if (X_OWNER = 'SEED') then
        user_id := -1;
     end if;

     OPEN csr_chk_claim_type_exist(X_CLAIM_TYPE_ID, X_ORG_ID);
     FETCH csr_chk_claim_type_exist INTO l_dummy_number;

     IF csr_chk_claim_type_exist%NOTFOUND THEN

       OZF_claim_types_All_PKG.INSERT_ROW (
          X_ROWID => row_id,
          X_CLAIM_TYPE_ID => X_CLAIM_TYPE_ID,
          X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
          X_REQUEST_ID => X_REQUEST_ID,
          X_CREATED_FROM => X_CREATED_FROM,
          X_CLAIM_CLASS => X_CLAIM_CLASS,
          X_SET_OF_BOOKS_ID => X_SET_OF_BOOKS_ID,
          X_POST_TO_GL_FLAG => X_POST_TO_GL_FLAG,
          X_START_DATE => X_START_DATE,
          X_END_DATE => X_END_DATE,
          X_CREATION_SIGN => X_CREATION_SIGN,
          X_GL_ID_DED_ADJ => X_GL_ID_DED_ADJ,
          X_GL_ID_DED_ADJ_CLEARING => X_GL_ID_DED_ADJ_CLEARING,
          X_GL_ID_DED_CLEARING => X_GL_ID_DED_CLEARING,
          X_GL_ID_ACCR_PROMO_LIAB => X_GL_ID_ACCR_PROMO_LIAB,
          X_TRANSACTION_TYPE => X_TRANSACTION_TYPE,
          X_CM_TRX_TYPE_ID => X_CM_TRX_TYPE_ID,
          X_DM_TRX_TYPE_ID => X_DM_TRX_TYPE_ID,
          X_CB_TRX_TYPE_ID => X_CB_TRX_TYPE_ID,
          X_WO_REC_TRX_ID => X_WO_REC_TRX_ID,
          X_ADJ_REC_TRX_ID => X_ADJ_REC_TRX_ID,
          X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1 => X_ATTRIBUTE1,
          X_ATTRIBUTE2 => X_ATTRIBUTE2,
          X_ATTRIBUTE3 => X_ATTRIBUTE3,
          X_ATTRIBUTE4 => X_ATTRIBUTE4,
          X_ATTRIBUTE5 => X_ATTRIBUTE5,
          X_ATTRIBUTE6 => X_ATTRIBUTE6,
          X_ATTRIBUTE7 => X_ATTRIBUTE7,
          X_ATTRIBUTE8 => X_ATTRIBUTE8,
          X_ATTRIBUTE9 => X_ATTRIBUTE9,
          X_ATTRIBUTE10 => X_ATTRIBUTE10,
          X_ATTRIBUTE11 => X_ATTRIBUTE11,
          X_ATTRIBUTE12 => X_ATTRIBUTE12,
          X_ATTRIBUTE13 => X_ATTRIBUTE13,
          X_ATTRIBUTE14 => X_ATTRIBUTE14,
          X_ATTRIBUTE15 => X_ATTRIBUTE15,
          X_NAME => X_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
	  X_CREATION_DATE => sysdate,
          X_CREATED_BY => user_id,
          X_LAST_UPDATE_DATE => sysdate,
          X_LAST_UPDATED_BY => user_id,
          X_LAST_UPDATE_LOGIN => 0,
          x_adjustment_type => x_adjustment_type,
          X_ORDER_TYPE_ID => X_ORDER_TYPE_ID,
	  X_NEG_WO_REC_TRX_ID => X_NEG_WO_REC_TRX_ID,
	  X_GL_BALANCING_FLEX_VALUE => X_GL_BALANCING_FLEX_VALUE,
	  X_ORG_ID => X_ORG_ID
     );
 ELSE
     OZF_claim_types_All_PKG.UPDATE_ROW (
          X_CLAIM_TYPE_ID => X_CLAIM_TYPE_ID,
          X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
          X_REQUEST_ID => X_REQUEST_ID,
          X_CREATED_FROM => X_CREATED_FROM,
          X_CLAIM_CLASS => X_CLAIM_CLASS,
          X_SET_OF_BOOKS_ID => X_SET_OF_BOOKS_ID,
          X_POST_TO_GL_FLAG => X_POST_TO_GL_FLAG,
          X_START_DATE => X_START_DATE,
          X_END_DATE => X_END_DATE,
          X_CREATION_SIGN => X_CREATION_SIGN,
          X_GL_ID_DED_ADJ => X_GL_ID_DED_ADJ,
          X_GL_ID_DED_ADJ_CLEARING => X_GL_ID_DED_ADJ_CLEARING,
          X_GL_ID_DED_CLEARING => X_GL_ID_DED_CLEARING,
          X_GL_ID_ACCR_PROMO_LIAB => X_GL_ID_ACCR_PROMO_LIAB,
          X_TRANSACTION_TYPE => X_TRANSACTION_TYPE,
          X_CM_TRX_TYPE_ID => X_CM_TRX_TYPE_ID,
          X_DM_TRX_TYPE_ID => X_DM_TRX_TYPE_ID,
          X_CB_TRX_TYPE_ID => X_CB_TRX_TYPE_ID,
          X_WO_REC_TRX_ID => X_WO_REC_TRX_ID,
          X_ADJ_REC_TRX_ID => X_ADJ_REC_TRX_ID,
          X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1 => X_ATTRIBUTE1,
          X_ATTRIBUTE2 => X_ATTRIBUTE2,
          X_ATTRIBUTE3 => X_ATTRIBUTE3,
          X_ATTRIBUTE4 => X_ATTRIBUTE4,
          X_ATTRIBUTE5 => X_ATTRIBUTE5,
          X_ATTRIBUTE6 => X_ATTRIBUTE6,
          X_ATTRIBUTE7 => X_ATTRIBUTE7,
          X_ATTRIBUTE8 => X_ATTRIBUTE8,
          X_ATTRIBUTE9 => X_ATTRIBUTE9,
          X_ATTRIBUTE10 => X_ATTRIBUTE10,
          X_ATTRIBUTE11 => X_ATTRIBUTE11,
          X_ATTRIBUTE12 => X_ATTRIBUTE12,
          X_ATTRIBUTE13 => X_ATTRIBUTE13,
          X_ATTRIBUTE14 => X_ATTRIBUTE14,
          X_ATTRIBUTE15 => X_ATTRIBUTE15,
          X_NAME => X_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_LAST_UPDATE_DATE => sysdate,
          X_LAST_UPDATED_BY => user_id,
          X_LAST_UPDATE_LOGIN => 0,
          x_adjustment_type => x_adjustment_type,
          X_ORDER_TYPE_ID => X_ORDER_TYPE_ID,
          X_NEG_WO_REC_TRX_ID => X_NEG_WO_REC_TRX_ID,
          X_GL_BALANCING_FLEX_VALUE => X_GL_BALANCING_FLEX_VALUE,
          X_ORG_ID => X_ORG_ID
     );
     END IF;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_CLAIM_TYPE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    -- note org_id is not used here because in NLS mode it is important
    -- update a line id across all orgs because data will be translated
    -- only once for a single org

    update ozf_claim_types_all_tl
      set name = X_NAME,
          description = X_DESCRIPTION,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', -1, 0),
          last_update_login = 0
    where claim_type_id = X_CLAIM_TYPE_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end OZF_claim_types_All_PKG;

/
