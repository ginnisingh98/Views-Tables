--------------------------------------------------------
--  DDL for Package Body PN_VAR_CONSTR_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_CONSTR_DEFAULTS_PKG" AS
/* $Header: PNVRCDFB.pls 120.0 2007/10/03 14:28:29 rthumma noship $ */

-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
--  14-MAR-07 Pikhar o Bug 5930407. Commented call to CHECK_MAX_CONSTR
-------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID                 in out NOCOPY VARCHAR2,
  X_CONSTR_DEFAULT_ID     in out NOCOPY NUMBER,
  X_CONSTR_DEFAULT_NUM    in out NOCOPY NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_CONSTR_TEMPLATE_ID    in NUMBER,
  X_CONSTR_START_DATE     in DATE,
  X_CONSTR_END_DATE       in DATE,
  X_CONSTR_CAT_CODE       in VARCHAR2,
  X_TYPE_CODE             in VARCHAR2,
  X_AMOUNT                in NUMBER,
  X_CREATION_DATE         in DATE,
  X_CREATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_ORG_ID                in NUMBER,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2
) is

  cursor C is
    select ROWID
    from PN_VAR_CONSTR_DEFAULTS_ALL
    where CONSTR_DEFAULT_ID = X_CONSTR_DEFAULT_ID;

    l_return_status         VARCHAR2(30)    := NULL;

begin

        PNP_DEBUG_PKG.debug ('PN_VAR_CONSTR_DEFAULTS_PKG.INSERT_ROW (+)');

        -------------------------------------------------------
        -- We need to generate the line number
        -------------------------------------------------------
        select  nvl(max(constr.CONSTR_DEFAULT_NUM),0)
        into    X_CONSTR_DEFAULT_NUM
        from    PN_VAR_CONSTR_DEFAULTS      constr
        where   constr.VAR_RENT_ID    =  X_VAR_RENT_ID;

        X_CONSTR_DEFAULT_NUM    := X_CONSTR_DEFAULT_NUM + 1;

        -------------------------------------------------------
        -- Select the nextval for constraint default id
        -------------------------------------------------------
        IF ( X_CONSTR_DEFAULT_ID IS NULL) THEN

                select  PN_VAR_CONSTR_DEFAULTS_S.nextval
                into    X_CONSTR_DEFAULT_ID
                from    dual;
        END IF;

    -- Check for constraint range
    /*l_return_status     := NULL;

    PN_VAR_CONSTR_DEFAULTS_PKG.CHECK_MAX_CONSTR
        (
            x_return_status     => l_return_status,
            x_constraint_default_id     => x_constr_default_id,
            x_constr_cat_code   => x_constr_cat_code,
            x_type_code         => x_type_code,
            x_var_rent_id        => x_var_rent_id,
            x_amount            => x_amount);

    IF (l_return_status IS NOT NULL) THEN
        APP_EXCEPTION.Raise_Exception;
    END IF;*/

  insert into PN_VAR_CONSTR_DEFAULTS_ALL (
    CONSTR_DEFAULT_ID,
    CONSTR_DEFAULT_NUM,
    VAR_RENT_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    AGREEMENT_TEMPLATE_ID,
    CONSTR_TEMPLATE_ID,
    CONSTR_START_DATE,
    CONSTR_END_DATE,
    CONSTR_CAT_CODE,
    TYPE_CODE,
    AMOUNT,
    ORG_ID,
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
    X_CONSTR_DEFAULT_ID,
    X_CONSTR_DEFAULT_NUM,
    X_VAR_RENT_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_AGREEMENT_TEMPLATE_ID,
    X_CONSTR_TEMPLATE_ID,
    X_CONSTR_START_DATE,
    X_CONSTR_END_DATE,
    X_CONSTR_CAT_CODE,
    X_TYPE_CODE,
    X_AMOUNT,
    X_ORG_ID,
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
    X_ATTRIBUTE15
);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

        PNP_DEBUG_PKG.debug ('PN_CONSTR_DEFAULTS_PKG.INSERT_ROW (-)');

end INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure LOCK_ROW (
  X_CONSTR_DEFAULT_ID     in NUMBER,
  X_CONSTR_DEFAULT_NUM    in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_CONSTR_TEMPLATE_ID    in NUMBER,
  X_CONSTR_START_DATE     in DATE,
  X_CONSTR_END_DATE       in DATE,
  X_CONSTR_CAT_CODE       in VARCHAR2,
  X_TYPE_CODE             in VARCHAR2,
  X_AMOUNT                in NUMBER,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2
) is
  cursor c1 is select
      *
    from PN_VAR_CONSTR_DEFAULTS_ALL
    where CONSTR_DEFAULT_ID = X_CONSTR_DEFAULT_ID
    for update of CONSTR_DEFAULT_ID nowait;

begin

        PNP_DEBUG_PKG.debug ('PN_CONSTR_DEFAULTS_PKG.LOCK_ROW (+)');

  for tlinfo in c1 loop
      if (    (tlinfo.CONSTR_DEFAULT_ID = X_CONSTR_DEFAULT_ID)
          AND (tlinfo.CONSTR_DEFAULT_NUM = X_CONSTR_DEFAULT_NUM)
          AND (tlinfo.VAR_RENT_ID = X_VAR_RENT_ID)
          AND ((tlinfo.AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID)
               OR ((tlinfo.AGREEMENT_TEMPLATE_ID is null) AND (X_AGREEMENT_TEMPLATE_ID is null)))
          AND ((tlinfo.CONSTR_TEMPLATE_ID = X_CONSTR_TEMPLATE_ID)
               OR ((tlinfo.CONSTR_TEMPLATE_ID is null) AND (X_CONSTR_TEMPLATE_ID is null)))
          AND ((tlinfo.CONSTR_START_DATE = X_CONSTR_START_DATE)
               OR ((tlinfo.CONSTR_START_DATE is null) AND (X_CONSTR_START_DATE is null)))
          AND ((tlinfo.CONSTR_END_DATE = X_CONSTR_END_DATE)
               OR ((tlinfo.CONSTR_END_DATE is null) AND (X_CONSTR_END_DATE is null)))
          AND (tlinfo.CONSTR_CAT_CODE = X_CONSTR_CAT_CODE)
          AND ((tlinfo.TYPE_CODE = X_TYPE_CODE)
               OR ((tlinfo.TYPE_CODE is null) AND (X_TYPE_CODE is null)))
          AND ((tlinfo.AMOUNT = X_AMOUNT)
               OR ((tlinfo.AMOUNT is null) AND (X_AMOUNT is null)))
          AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
                         OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
                         OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
                         OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
                         OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
                         OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
                         OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
                         OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
                         OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
                         OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
          AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
                         OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
          AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
                         OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
          AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
                         OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
          AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
                         OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
          AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
                         OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
          AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
                         OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      ) then
        null;


      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;

        PNP_DEBUG_PKG.debug ('PN_CONSTR_DEFAULTS_PKG.LOCK_ROW (-)');

end LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
--  14-MAR-07 Pikhar o Bug 5930407. Commented call to CHECK_MAX_CONSTR
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_CONSTR_DEFAULT_ID     in NUMBER,
  X_CONSTR_DEFAULT_NUM    in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_CONSTR_TEMPLATE_ID    in NUMBER,
  X_CONSTR_START_DATE     in DATE,
  X_CONSTR_END_DATE       in DATE,
  X_CONSTR_CAT_CODE       in VARCHAR2,
  X_TYPE_CODE             in VARCHAR2,
  X_AMOUNT                in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2
) is

    l_return_status         VARCHAR2(30)    := NULL;

begin

        PNP_DEBUG_PKG.debug ('PN_CONSTR_DEFAULTS_PKG.UPDATE_ROW (+)');

    -- Check for constraint range
    /*l_return_status     := NULL;
    PN_VAR_CONSTR_DEFAULTS_PKG.CHECK_MAX_CONSTR
        (
            x_return_status => l_return_status,
            x_constraint_default_id => x_constr_default_id,
            x_constr_cat_code => x_constr_cat_code,
            x_var_rent_id => x_var_rent_id,
            x_type_code => x_type_code,
            x_amount => x_amount
        );

    IF (l_return_status IS NOT NULL) THEN
        APP_EXCEPTION.Raise_Exception;
    END IF;*/

  update PN_VAR_CONSTR_DEFAULTS_ALL set
    CONSTR_DEFAULT_NUM    = X_CONSTR_DEFAULT_NUM,
    VAR_RENT_ID           = X_VAR_RENT_ID,
    AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID,
    CONSTR_TEMPLATE_ID    = X_CONSTR_TEMPLATE_ID,
    CONSTR_START_DATE     = X_CONSTR_START_DATE,
    CONSTR_END_DATE       = X_CONSTR_END_DATE,
    CONSTR_CAT_CODE       = X_CONSTR_CAT_CODE,
    TYPE_CODE             = X_TYPE_CODE,
    AMOUNT                = X_AMOUNT,
    CONSTR_DEFAULT_ID     = X_CONSTR_DEFAULT_ID,
    LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY    = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1            = X_ATTRIBUTE1,
    ATTRIBUTE2            = X_ATTRIBUTE2,
    ATTRIBUTE3            = X_ATTRIBUTE3,
    ATTRIBUTE4            = X_ATTRIBUTE4,
    ATTRIBUTE5            = X_ATTRIBUTE5,
    ATTRIBUTE6            = X_ATTRIBUTE6,
    ATTRIBUTE7            = X_ATTRIBUTE7,
    ATTRIBUTE8            = X_ATTRIBUTE8,
    ATTRIBUTE9            = X_ATTRIBUTE9,
    ATTRIBUTE10           = X_ATTRIBUTE10,
    ATTRIBUTE11           = X_ATTRIBUTE11,
    ATTRIBUTE12           = X_ATTRIBUTE12,
    ATTRIBUTE13           = X_ATTRIBUTE13,
    ATTRIBUTE14           = X_ATTRIBUTE14,
    ATTRIBUTE15           = X_ATTRIBUTE15
  where CONSTR_DEFAULT_ID = X_CONSTR_DEFAULT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

        PNP_DEBUG_PKG.debug ('PN_CONSTR_DEFAULTS_PKG.UPDATE_ROW (-)');

end UPDATE_ROW;

-----------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-----------------------------------------------------------------------

procedure DELETE_ROW (
  X_CONSTR_DEFAULT_ID in NUMBER
) is

begin

        PNP_DEBUG_PKG.debug ('PN_CONSTR_DEFAULTS_PKG.DELETE_ROW (+)');

  delete from PN_VAR_CONSTR_DEFAULTS_ALL
  where CONSTR_DEFAULT_ID = X_CONSTR_DEFAULT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

        PNP_DEBUG_PKG.debug ('PN_CONSTR_DEFAULTS_PKG.DELETE_ROW (-)');

end DELETE_ROW;


-----------------------------------------------------------------------
-- PROCDURE : CHECK_MAX_CONSTR
-----------------------------------------------------------------------

PROCEDURE CHECK_MAX_CONSTR
        (
            x_return_status     in out NOCOPY  varchar2,
            x_constraint_default_id     in      number,
            x_constr_cat_code   in      varchar2,
            x_var_rent_id   in      number,
            x_type_code         in      varchar2,
            x_amount            in      number
        )
IS
    l_dummy             NUMBER;
BEGIN
    PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.CHECK_MAX_CONSTR (+)');

    IF x_type_code = 'MIN' THEN

    select  1
    into    l_dummy
    from    dual
    where   not exists
        (
            select  1
            from    pn_var_constr_defaults_all   constr
            where   constr.amount           < (x_amount)
            and     ((x_constraint_default_id       is null) or
                      (constr.constr_default_id <> x_constraint_default_id))
            and     constr.constr_cat_code  = x_constr_cat_code
            and     constr.var_rent_id = x_var_rent_id
            and     constr.type_code        = 'MAX'
        );

    END IF;

    PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.CHECK_MAX_CONSTR (-)');

    EXCEPTION
        when NO_DATA_FOUND  then
            fnd_message.set_name ('PN','PN_VAR_WRONG_RANGE');
            --fnd_message.set_token('RENT_NUMBER',
                    --x_rent_num);
            x_return_status := 'E';

END CHECK_MAX_CONSTR;

end PN_VAR_CONSTR_DEFAULTS_PKG;

/
