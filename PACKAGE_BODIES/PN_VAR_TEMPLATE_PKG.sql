--------------------------------------------------------
--  DDL for Package Body PN_VAR_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_TEMPLATE_PKG" as
/* $Header: PNVRTEMB.pls 120.3.12010000.2 2010/04/22 09:44:57 kkorada ship $*/

-----------------------------------------------------------------------
-- PROCDURE :    INSERT_ROW
-----------------------------------------------------------------------

procedure    INSERT_ROW (
  X_ROWID                  in out NOCOPY VARCHAR2,
  X_AGREEMENT_TEMPLATE_ID  in out NOCOPY NUMBER,
  X_AGREEMENT_TEMPLATE     in VARCHAR2,
  X_PURPOSE_CODE           in VARCHAR2,
  X_TYPE_CODE              in VARCHAR2,
  X_CUMULATIVE_VOL         in VARCHAR2,
  X_INVOICE_ON             in VARCHAR2,
  X_NEGATIVE_RENT          in VARCHAR2,
  X_TERM_TEMPLATE_ID       in NUMBER,
  X_ABATEMENT_AMOUNT       in NUMBER,
  X_PRORATION_RULE         in VARCHAR2,
  X_PERIOD_FREQ_CODE       in VARCHAR2,
  X_USE_GL_CALENDAR        in VARCHAR2,
  X_YEAR_START_DATE        in DATE,
  X_GL_PERIOD_SET_NAME     in VARCHAR2,
  X_PERIOD_TYPE            in VARCHAR2,
  X_REPTG_FREQ_CODE        in VARCHAR2,
  X_REPTG_DAY_OF_MONTH     in NUMBER,
  X_REPTG_DAYS_AFTER       in NUMBER,
  X_INVG_FREQ_CODE         in VARCHAR2,
  X_INVG_SPREAD_CODE       in VARCHAR2,
  X_INVG_DAY_OF_MONTH      in NUMBER,
  X_INVG_DAYS_AFTER        in NUMBER,
  X_COMMENTS               in VARCHAR2,
  X_ORG_ID                 in NUMBER,
  X_CREATION_DATE          in DATE,
  X_CREATED_BY             in NUMBER,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER,
  X_VRG_REPTG_FREQ_CODE    in VARCHAR2,
  X_ATTRIBUTE_CATEGORY     in VARCHAR2,
  X_ATTRIBUTE1             in VARCHAR2,
  X_ATTRIBUTE2             in VARCHAR2,
  X_ATTRIBUTE3             in VARCHAR2,
  X_ATTRIBUTE4             in VARCHAR2,
  X_ATTRIBUTE5             in VARCHAR2,
  X_ATTRIBUTE6             in VARCHAR2,
  X_ATTRIBUTE7             in VARCHAR2,
  X_ATTRIBUTE8             in VARCHAR2,
  X_ATTRIBUTE9             in VARCHAR2,
  X_ATTRIBUTE10            in VARCHAR2,
  X_ATTRIBUTE11            in VARCHAR2,
  X_ATTRIBUTE12            in VARCHAR2,
  X_ATTRIBUTE13            in VARCHAR2,
  X_ATTRIBUTE14            in VARCHAR2,
  X_ATTRIBUTE15            in VARCHAR2
) is

  cursor C is
  select ROWID
  from PN_VAR_TEMPLATES_ALL
  where AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID;

    l_return_status   VARCHAR2(30)    := NULL;

BEGIN

  PNP_DEBUG_PKG.debug ('PN_VAR_TEMPLATE_PKG.INSERT_ROW (+)');

  IF ( X_AGREEMENT_TEMPLATE_ID IS NULL) THEN
     Select PN_VAR_TEMPLATES_S.nextval
       into X_AGREEMENT_TEMPLATE_ID
       FROM DUAL;
  END IF;

  insert into PN_VAR_TEMPLATES_ALL (
    AGREEMENT_TEMPLATE_ID,
    AGREEMENT_TEMPLATE,
    PURPOSE_CODE,
    TYPE_CODE,
    CUMULATIVE_VOL,
    INVOICE_ON,
    NEGATIVE_RENT,
    TERM_TEMPLATE_ID,
    ABATEMENT_AMOUNT,
    PRORATION_RULE,
    PERIOD_FREQ_CODE,
    USE_GL_CALENDAR,
    YEAR_START_DATE,
    GL_PERIOD_SET_NAME,
    PERIOD_TYPE,
    REPTG_FREQ_CODE,
    REPTG_DAY_OF_MONTH,
    REPTG_DAYS_AFTER,
    INVG_FREQ_CODE,
    INVG_SPREAD_CODE,
    INVG_DAY_OF_MONTH,
    INVG_DAYS_AFTER,
    COMMENTS,
    ORG_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    VRG_REPTG_FREQ_CODE,
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
  )
  values
   (
    X_AGREEMENT_TEMPLATE_ID,
    X_AGREEMENT_TEMPLATE,
    X_PURPOSE_CODE,
    X_TYPE_CODE,
    X_CUMULATIVE_VOL,
    X_INVOICE_ON,
    X_NEGATIVE_RENT,
    X_TERM_TEMPLATE_ID,
    X_ABATEMENT_AMOUNT,
    X_PRORATION_RULE,
    X_PERIOD_FREQ_CODE,
    X_USE_GL_CALENDAR,
    X_YEAR_START_DATE,
    X_GL_PERIOD_SET_NAME,
    X_PERIOD_TYPE,
    X_REPTG_FREQ_CODE,
    X_REPTG_DAY_OF_MONTH,
    X_REPTG_DAYS_AFTER,
    X_INVG_FREQ_CODE,
    X_INVG_SPREAD_CODE,
    X_INVG_DAY_OF_MONTH,
    X_INVG_DAYS_AFTER,
    X_COMMENTS,
    NVL(X_ORG_ID,FND_GLOBAL.ORG_ID),
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_VRG_REPTG_FREQ_CODE,
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
    X_ATTRIBUTE15);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  PNP_DEBUG_PKG.debug ('PN_VAR_TEMPLATE_PKG.INSERT_ROW (-)');

end INSERT_ROW;


-----------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-----------------------------------------------------------------------

procedure LOCK_ROW (
  X_AGREEMENT_TEMPLATE_ID  in NUMBER,
  X_AGREEMENT_TEMPLATE     in VARCHAR2,
  X_PURPOSE_CODE           in VARCHAR2,
  X_TYPE_CODE              in VARCHAR2,
  X_CUMULATIVE_VOL         in VARCHAR2,
  X_INVOICE_ON             in VARCHAR2,
  X_NEGATIVE_RENT          in VARCHAR2,
  X_TERM_TEMPLATE_ID       in NUMBER,
  X_ABATEMENT_AMOUNT       in NUMBER,
  X_PRORATION_RULE         in VARCHAR2,
  X_PERIOD_FREQ_CODE       in VARCHAR2,
  X_USE_GL_CALENDAR        in VARCHAR2,
  X_YEAR_START_DATE        in DATE,
  X_GL_PERIOD_SET_NAME     in VARCHAR2,
  X_PERIOD_TYPE            in VARCHAR2,
  X_REPTG_FREQ_CODE        in VARCHAR2,
  X_REPTG_DAY_OF_MONTH     in NUMBER,
  X_REPTG_DAYS_AFTER       in NUMBER,
  X_INVG_FREQ_CODE         in VARCHAR2,
  X_INVG_SPREAD_CODE       in VARCHAR2,
  X_INVG_DAY_OF_MONTH      in NUMBER,
  X_INVG_DAYS_AFTER        in NUMBER,
  X_COMMENTS               in VARCHAR2,
  X_VRG_REPTG_FREQ_CODE    in VARCHAR2,
  X_ATTRIBUTE_CATEGORY     in VARCHAR2,
  X_ATTRIBUTE1             in VARCHAR2,
  X_ATTRIBUTE2             in VARCHAR2,
  X_ATTRIBUTE3             in VARCHAR2,
  X_ATTRIBUTE4             in VARCHAR2,
  X_ATTRIBUTE5             in VARCHAR2,
  X_ATTRIBUTE6             in VARCHAR2,
  X_ATTRIBUTE7             in VARCHAR2,
  X_ATTRIBUTE8             in VARCHAR2,
  X_ATTRIBUTE9             in VARCHAR2,
  X_ATTRIBUTE10            in VARCHAR2,
  X_ATTRIBUTE11            in VARCHAR2,
  X_ATTRIBUTE12            in VARCHAR2,
  X_ATTRIBUTE13            in VARCHAR2,
  X_ATTRIBUTE14            in VARCHAR2,
  X_ATTRIBUTE15            in VARCHAR2
) is
  cursor c1
  is
  select *
  from PN_VAR_TEMPLATES_ALL
  where AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID
  for update of AGREEMENT_TEMPLATE_ID nowait;

  tlinfo c1%rowtype;

BEGIN
   PNP_DEBUG_PKG.debug ('PN_VAR_TEMPLATE_PKG.LOCK_ROW (+)');

   open c1;
 fetch c1 into tlinfo;
 if (c1%notfound) then
 close c1;
 return;
 end if;
   close c1;


   if ((tlinfo.AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID) OR
    ((tlinfo.AGREEMENT_TEMPLATE_ID is null) AND (X_AGREEMENT_TEMPLATE_ID is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AGREEMENT_TEMPLATE_ID',
    to_char(tlinfo.AGREEMENT_TEMPLATE_ID));
   end if;

   if ((tlinfo.AGREEMENT_TEMPLATE = X_AGREEMENT_TEMPLATE) OR
    ((tlinfo.AGREEMENT_TEMPLATE is null) AND (X_AGREEMENT_TEMPLATE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AGREEMENT_TEMPLATE', tlinfo.AGREEMENT_TEMPLATE);
   end if;

   if ((tlinfo.PURPOSE_CODE = X_PURPOSE_CODE) OR
    ((tlinfo.PURPOSE_CODE is null) AND (X_PURPOSE_CODE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PURPOSE_CODE', tlinfo.PURPOSE_CODE);
   end if;

   if ((tlinfo.TYPE_CODE = X_TYPE_CODE) OR
    ((tlinfo.TYPE_CODE is null) AND (X_TYPE_CODE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('TYPE_CODE', tlinfo.TYPE_CODE);
   end if;

   if ((tlinfo.CUMULATIVE_VOL = X_CUMULATIVE_VOL) OR
    ((tlinfo.CUMULATIVE_VOL is null) AND (X_CUMULATIVE_VOL is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CUMULATIVE_VOL', tlinfo.CUMULATIVE_VOL);
   end if;

   if ((tlinfo.INVOICE_ON = X_INVOICE_ON) OR
    ((tlinfo.INVOICE_ON is null) AND (X_INVOICE_ON is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVOICE_ON', tlinfo.INVOICE_ON);
   end if;

   if ((tlinfo.NEGATIVE_RENT = X_NEGATIVE_RENT) OR
    ((tlinfo.NEGATIVE_RENT is null) AND (X_NEGATIVE_RENT is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('NEGATIVE_RENT', tlinfo.NEGATIVE_RENT);
   end if;

   if ((tlinfo.TERM_TEMPLATE_ID = X_TERM_TEMPLATE_ID) OR
    ((tlinfo.TERM_TEMPLATE_ID is null) AND
    (X_TERM_TEMPLATE_ID is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('TERM_TEMPLATE_ID',
    to_char(tlinfo.TERM_TEMPLATE_ID));
   end if;

   if ((tlinfo.ABATEMENT_AMOUNT = X_ABATEMENT_AMOUNT) OR
    ((tlinfo.ABATEMENT_AMOUNT is null) AND
    (X_ABATEMENT_AMOUNT is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ABATEMENT_AMOUNT',
    to_char(tlinfo.ABATEMENT_AMOUNT));
   end if;

   if ((tlinfo.PRORATION_RULE = X_PRORATION_RULE) OR
    ((tlinfo.PRORATION_RULE is null) AND (X_PRORATION_RULE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PRORATION_RULE', tlinfo.PRORATION_RULE);
   end if;

   if ((tlinfo.PERIOD_FREQ_CODE = X_PERIOD_FREQ_CODE) OR
    ((tlinfo.PERIOD_FREQ_CODE is null) AND (X_PERIOD_FREQ_CODE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_FREQ_CODE', tlinfo.PERIOD_FREQ_CODE);
   end if;

   if ((tlinfo.USE_GL_CALENDAR = X_USE_GL_CALENDAR) OR
    ((tlinfo.USE_GL_CALENDAR is null) AND (X_USE_GL_CALENDAR is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('USE_GL_CALENDAR', tlinfo.USE_GL_CALENDAR);
   end if;

   if ((tlinfo.YEAR_START_DATE = X_YEAR_START_DATE) OR
    ((tlinfo.YEAR_START_DATE is null) AND (X_YEAR_START_DATE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('YEAR_START_DATE',
    to_char(tlinfo.YEAR_START_DATE));
   end if;

   if ((tlinfo.GL_PERIOD_SET_NAME = X_GL_PERIOD_SET_NAME) OR
    ((tlinfo.GL_PERIOD_SET_NAME is null) AND (X_GL_PERIOD_SET_NAME is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('GL_PERIOD_SET_NAME', tlinfo.GL_PERIOD_SET_NAME);
   end if;
   if ((tlinfo.PERIOD_TYPE = X_PERIOD_TYPE) OR
    ((tlinfo.PERIOD_TYPE is null) AND (X_PERIOD_TYPE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_TYPE', tlinfo.PERIOD_TYPE);
   end if;
   if ((tlinfo.REPTG_FREQ_CODE = X_REPTG_FREQ_CODE) OR
    ((tlinfo.REPTG_FREQ_CODE is null) AND (X_REPTG_FREQ_CODE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('REPTG_FREQ_CODE', tlinfo.REPTG_FREQ_CODE);
   end if;
   if ((tlinfo.REPTG_DAY_OF_MONTH = X_REPTG_DAY_OF_MONTH) OR
    ((tlinfo.REPTG_DAY_OF_MONTH is null) AND (X_REPTG_DAY_OF_MONTH is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('REPTG_DAY_OF_MONTH',
    to_char(tlinfo.REPTG_DAY_OF_MONTH));
   end if;
   if ((tlinfo.REPTG_DAYS_AFTER = X_REPTG_DAYS_AFTER) OR
    ((tlinfo.REPTG_DAYS_AFTER is null) AND (X_REPTG_DAYS_AFTER is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('REPTG_DAYS_AFTER',
    to_char(tlinfo.REPTG_DAYS_AFTER));
   end if;
   if ((tlinfo.INVG_FREQ_CODE = X_INVG_FREQ_CODE) OR
    ((tlinfo.INVG_FREQ_CODE is null) AND (X_INVG_FREQ_CODE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_FREQ_CODE', tlinfo.INVG_FREQ_CODE);
   end if;

   if ((tlinfo.INVG_SPREAD_CODE = X_INVG_SPREAD_CODE) OR
    ((tlinfo.INVG_SPREAD_CODE is null) AND (X_INVG_SPREAD_CODE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_SPREAD_CODE', tlinfo.INVG_SPREAD_CODE);
   end if;

   if ((tlinfo.INVG_DAY_OF_MONTH = X_INVG_DAY_OF_MONTH) OR
    ((tlinfo.INVG_DAY_OF_MONTH is null) AND (X_INVG_DAY_OF_MONTH is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_DAY_OF_MONTH',
    to_char(tlinfo.INVG_DAY_OF_MONTH));
   end if;

   if ((tlinfo.INVG_DAYS_AFTER = X_INVG_DAYS_AFTER) OR
    ((tlinfo.INVG_DAYS_AFTER is null) AND (X_INVG_DAYS_AFTER is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_DAYS_AFTER',
    to_char(tlinfo.INVG_DAYS_AFTER));
   end if;

   if ((tlinfo.COMMENTS = X_COMMENTS) OR
    ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('COMMENTS', tlinfo.COMMENTS);
   end if;

   if ((tlinfo.VRG_REPTG_FREQ_CODE = X_VRG_REPTG_FREQ_CODE) OR
    ((tlinfo.VRG_REPTG_FREQ_CODE is null) AND (X_VRG_REPTG_FREQ_CODE is null))) then
    null;
   else
    PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VRG_REPTG_FREQ_CODE', tlinfo.VRG_REPTG_FREQ_CODE);
   end if;

   if ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
        OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE_CATEGORY', to_char(tlinfo.ATTRIBUTE_CATEGORY));
   end if;


   if ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
        OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1', to_char(tlinfo.ATTRIBUTE1));
   end if;

   if ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
        OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE2', to_char(tlinfo.ATTRIBUTE2));
   end if;

   if ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
        OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE3', to_char(tlinfo.ATTRIBUTE3));
   end if;

   if ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
        OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE4', to_char(tlinfo.ATTRIBUTE4));
   end if;

   if ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
        OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE5', to_char(tlinfo.ATTRIBUTE5));
   end if;

   if ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
        OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE6', to_char(tlinfo.ATTRIBUTE6));
   end if;

   if ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
        OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE7', to_char(tlinfo.ATTRIBUTE7));
   end if;

   if ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
        OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE8', to_char(tlinfo.ATTRIBUTE8));
   end if;

   if ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
        OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE9', to_char(tlinfo.ATTRIBUTE9));
   end if;

   if ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
        OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE10', to_char(tlinfo.ATTRIBUTE10));
   end if;

   if ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
        OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE11', to_char(tlinfo.ATTRIBUTE11));
   end if;

   if ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
        OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE12', to_char(tlinfo.ATTRIBUTE12));
   end if;

   if ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
        OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE13', to_char(tlinfo.ATTRIBUTE13));
   end if;

   if ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
        OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE14', to_char(tlinfo.ATTRIBUTE14));
   end if;

   if ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
        OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE15', to_char(tlinfo.ATTRIBUTE15));
   end if;

   PNP_DEBUG_PKG.debug ('PN_VAR_TEMPLATE_PKG.LOCK_ROW (-)');

end LOCK_ROW;


-----------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
-----------------------------------------------------------------------

procedure UPDATE_ROW (
  X_AGREEMENT_TEMPLATE_ID  in NUMBER,
  X_AGREEMENT_TEMPLATE     in VARCHAR2,
  X_PURPOSE_CODE           in VARCHAR2,
  X_TYPE_CODE              in VARCHAR2,
  X_CUMULATIVE_VOL         in VARCHAR2,
  X_INVOICE_ON             in VARCHAR2,
  X_NEGATIVE_RENT          in VARCHAR2,
  X_TERM_TEMPLATE_ID       in NUMBER,
  X_ABATEMENT_AMOUNT       in NUMBER,
  X_PRORATION_RULE         in VARCHAR2,
  X_PERIOD_FREQ_CODE       in VARCHAR2,
  X_USE_GL_CALENDAR        in VARCHAR2,
  X_YEAR_START_DATE        in DATE,
  X_GL_PERIOD_SET_NAME     in VARCHAR2,
  X_PERIOD_TYPE            in VARCHAR2,
  X_REPTG_FREQ_CODE        in VARCHAR2,
  X_REPTG_DAY_OF_MONTH     in NUMBER,
  X_REPTG_DAYS_AFTER       in NUMBER,
  X_INVG_FREQ_CODE         in VARCHAR2,
  X_INVG_SPREAD_CODE       in VARCHAR2,
  X_INVG_DAY_OF_MONTH      in NUMBER,
  X_INVG_DAYS_AFTER        in NUMBER,
  X_COMMENTS               in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER,
  X_VRG_REPTG_FREQ_CODE    in VARCHAR2,
  X_ATTRIBUTE_CATEGORY     in VARCHAR2,
  X_ATTRIBUTE1             in VARCHAR2,
  X_ATTRIBUTE2             in VARCHAR2,
  X_ATTRIBUTE3             in VARCHAR2,
  X_ATTRIBUTE4             in VARCHAR2,
  X_ATTRIBUTE5             in VARCHAR2,
  X_ATTRIBUTE6             in VARCHAR2,
  X_ATTRIBUTE7             in VARCHAR2,
  X_ATTRIBUTE8             in VARCHAR2,
  X_ATTRIBUTE9             in VARCHAR2,
  X_ATTRIBUTE10            in VARCHAR2,
  X_ATTRIBUTE11            in VARCHAR2,
  X_ATTRIBUTE12            in VARCHAR2,
  X_ATTRIBUTE13            in VARCHAR2,
  X_ATTRIBUTE14            in VARCHAR2,
  X_ATTRIBUTE15            in VARCHAR2
)
is

    l_return_status   VARCHAR2(30)    := NULL;

BEGIN

  PNP_DEBUG_PKG.debug ('PN_VAR_TEMPLATE_PKG.UPDATE_ROW (+)');

  update PN_VAR_TEMPLATES_ALL set
    AGREEMENT_TEMPLATE     = X_AGREEMENT_TEMPLATE,
    PURPOSE_CODE           = X_PURPOSE_CODE,
    TYPE_CODE              = X_TYPE_CODE,
    CUMULATIVE_VOL         = X_CUMULATIVE_VOL,
    INVOICE_ON             = X_INVOICE_ON,
    NEGATIVE_RENT          = X_NEGATIVE_RENT,
    TERM_TEMPLATE_ID       = X_TERM_TEMPLATE_ID,
    ABATEMENT_AMOUNT       = X_ABATEMENT_AMOUNT,
    PRORATION_RULE         = X_PRORATION_RULE,
    PERIOD_FREQ_CODE       = X_PERIOD_FREQ_CODE,
    USE_GL_CALENDAR        = X_USE_GL_CALENDAR,
    YEAR_START_DATE        = X_YEAR_START_DATE,
    GL_PERIOD_SET_NAME     = X_GL_PERIOD_SET_NAME,
    PERIOD_TYPE            = X_PERIOD_TYPE,
    REPTG_FREQ_CODE        = X_REPTG_FREQ_CODE,
    REPTG_DAY_OF_MONTH     = X_REPTG_DAY_OF_MONTH,
    REPTG_DAYS_AFTER       = X_REPTG_DAYS_AFTER,
    INVG_FREQ_CODE         = X_INVG_FREQ_CODE,
    INVG_SPREAD_CODE       = X_INVG_SPREAD_CODE,
    INVG_DAY_OF_MONTH      = X_INVG_DAY_OF_MONTH,
    INVG_DAYS_AFTER        = X_INVG_DAYS_AFTER,
    comments               = X_COMMENTS,
    LAST_UPDATE_DATE       = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY        = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN      = X_LAST_UPDATE_LOGIN,
    VRG_REPTG_FREQ_CODE    = X_VRG_REPTG_FREQ_CODE,
    ATTRIBUTE_CATEGORY     = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1             = X_ATTRIBUTE1,
    ATTRIBUTE2             = X_ATTRIBUTE2,
    ATTRIBUTE3             = X_ATTRIBUTE3,
    ATTRIBUTE4             = X_ATTRIBUTE4,
    ATTRIBUTE5             = X_ATTRIBUTE5,
    ATTRIBUTE6             = X_ATTRIBUTE6,
    ATTRIBUTE7             = X_ATTRIBUTE7,
    ATTRIBUTE8             = X_ATTRIBUTE8,
    ATTRIBUTE9             = X_ATTRIBUTE9,
    ATTRIBUTE10            = X_ATTRIBUTE10,
    ATTRIBUTE11            = X_ATTRIBUTE11,
    ATTRIBUTE12            = X_ATTRIBUTE12,
    ATTRIBUTE13            = X_ATTRIBUTE13,
    ATTRIBUTE14            = X_ATTRIBUTE14,
    ATTRIBUTE15            = X_ATTRIBUTE15
  where AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  PNP_DEBUG_PKG.debug ('PN_VAR_TEMPLATE_PKG.UPDATE_ROW (+)');

end UPDATE_ROW;

-----------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-----------------------------------------------------------------------

procedure DELETE_ROW (
  X_AGREEMENT_TEMPLATE_ID in NUMBER
) is

BEGIN

  PNP_DEBUG_PKG.debug ('PN_VAR_TEMPLATE_PKG.DELETE_ROW (+)');

  delete from PN_VAR_TEMPLATES_ALL
  where AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  PNP_DEBUG_PKG.debug ('PN_VAR_TEMPLATE_PKG.DELETE_ROW (-)');

END DELETE_ROW;

   PROCEDURE check_unq_vr_template (
      x_return_status IN OUT NOCOPY   VARCHAR2
     ,x_template_id   IN NUMBER
     ,x_name          IN VARCHAR2
     ,x_org_id        IN NUMBER
   ) IS
      l_dummy   NUMBER;
   BEGIN
      SELECT 1
      INTO   l_dummy
      FROM   DUAL
      WHERE NOT EXISTS (SELECT 1
                        FROM pn_var_templates_all
                        WHERE agreement_template = x_name
                        AND ((x_template_id IS NULL)
                             OR (agreement_template_id <> x_template_id))
                        AND nvl(org_id, -99) = nvl(x_org_id,nvl(org_id, -99))
                        );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_message.set_name ('PN', 'PN_DUP_TERM_TEMPLATE');
         x_return_status := 'E';
   END check_unq_vr_template;

end PN_VAR_TEMPLATE_PKG;

/
