--------------------------------------------------------
--  DDL for Package Body PN_VAR_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_CONSTRAINTS_PKG" as
/* $Header: PNVRCONB.pls 120.3 2007/03/14 12:23:33 pikhar noship $ */

-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-JUL-05 Piagrawa o Bug 4284035 - Replaced PN_VAR_CONSTRAINTS with _ALL table.
-- 14-MAR-07 Pikhar   o Bug 5930407. Commented call to CHECK_MAX_CONSTR
-------------------------------------------------------------------------------

procedure INSERT_ROW (
  X_ROWID                 in out NOCOPY VARCHAR2,
  X_CONSTRAINT_ID         in out NOCOPY NUMBER,
  X_CONSTRAINT_NUM        in out NOCOPY NUMBER,
  X_PERIOD_ID             in NUMBER,
  X_CONSTR_CAT_CODE       in VARCHAR2,
  X_TYPE_CODE             in VARCHAR2,
  X_AMOUNT                in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_CONSTR_TEMPLATE_ID    in NUMBER,
  X_CONSTR_DEFAULT_ID     in NUMBER,
  X_COMMENTS              in VARCHAR2,
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
  X_ATTRIBUTE15           in VARCHAR2,
  X_ORG_ID                in NUMBER,
  X_CREATION_DATE         in DATE,
  X_CREATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_CONSTR_START_DATE     in DATE,
  X_CONSTR_END_DATE       in DATE
)
IS
   CURSOR C IS
      SELECT ROWID
      FROM PN_VAR_CONSTRAINTS_ALL
      WHERE CONSTRAINT_ID = X_CONSTRAINT_ID;

    l_return_status         VARCHAR2(30)    := NULL;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_CONSTRAINTS_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- We need to generate the constraints number
   -------------------------------------------------------
   SELECT  nvl(max(CONSTRAINT_NUM),0)
   INTO    X_CONSTRAINT_NUM
   FROM    PN_VAR_CONSTRAINTS_ALL
   WHERE   PERIOD_ID = X_PERIOD_ID;

   X_CONSTRAINT_NUM := X_CONSTRAINT_NUM + 1;

   -------------------------------------------------------
   -- Select the nextval for constraints id
   -------------------------------------------------------
   IF ( X_CONSTRAINT_ID IS NULL) THEN
     SELECT  pn_var_constraints_s.nextval
     INTO    X_CONSTRAINT_ID
     FROM    dual;
   END IF;

    -- Check for constraint range
    /*l_return_status     := NULL;
    PN_VAR_CONSTRAINTS_PKG.CHECK_MAX_CONSTR
        (
            l_return_status,
            x_period_id,
            x_constraint_id,
            x_constr_cat_code,
            x_type_code,
            x_amount
        );
    IF (l_return_status IS NOT NULL) THEN
        APP_EXCEPTION.Raise_Exception;
    END IF;*/


   INSERT INTO PN_VAR_CONSTRAINTS_ALL
   (
    CONSTRAINT_ID,
    CONSTRAINT_NUM,
    PERIOD_ID,
    CONSTR_CAT_CODE,
    TYPE_CODE,
    AMOUNT,
    AGREEMENT_TEMPLATE_ID,
    CONSTR_TEMPLATE_ID,
    CONSTR_DEFAULT_ID,
    COMMENTS,
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
    ORG_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CONSTR_START_DATE,
    CONSTR_END_DATE
  )
   VALUES
   (
    X_CONSTRAINT_ID,
    X_CONSTRAINT_NUM,
    X_PERIOD_ID,
    X_CONSTR_CAT_CODE,
    X_TYPE_CODE,
    X_AMOUNT,
    X_AGREEMENT_TEMPLATE_ID,
    X_CONSTR_TEMPLATE_ID,
    X_CONSTR_DEFAULT_ID,
    X_COMMENTS,
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
    X_ORG_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CONSTR_START_DATE,
    X_CONSTR_END_DATE);

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%notfound) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   PNP_DEBUG_PKG.debug ('PN_VAR_CONSTRAINTS_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : loacks the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_CONSTRAINTS with _ALL table.
-------------------------------------------------------------------------------

procedure LOCK_ROW (
   X_CONSTRAINT_ID         in NUMBER,
   X_CONSTRAINT_NUM        in NUMBER,
   X_PERIOD_ID             in NUMBER,
   X_CONSTR_CAT_CODE       in VARCHAR2,
   X_TYPE_CODE             in VARCHAR2,
   X_AMOUNT                in NUMBER,
   X_AGREEMENT_TEMPLATE_ID in NUMBER,
   X_CONSTR_TEMPLATE_ID    in NUMBER,
   X_CONSTR_DEFAULT_ID     in NUMBER,
   X_COMMENTS              in VARCHAR2,
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
   X_ATTRIBUTE15           in VARCHAR2,
   X_CONSTR_START_DATE     in DATE,
   X_CONSTR_END_DATE       in DATE
)
IS
  CURSOR c1 IS
     SELECT *
     FROM PN_VAR_CONSTRAINTS_ALL
     WHERE CONSTRAINT_ID = X_CONSTRAINT_ID
     FOR UPDATE OF CONSTRAINT_ID NOWAIT;

  tlinfo c1%rowtype;

BEGIN
   PNP_DEBUG_PKG.debug ('PN_VAR_CONSTRAINTS_PKG.LOCK_ROW (+)');

   OPEN c1;
       FETCH c1 INTO tlinfo;
       IF (c1%notfound) THEN
             CLOSE c1;
             RETURN;
       END IF;
   CLOSE c1;


   if (tlinfo.CONSTRAINT_ID = X_CONSTRAINT_ID) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CONSTRAINT_ID', to_char(tlinfo.CONSTRAINT_ID));
   end if;

   if (tlinfo.CONSTRAINT_NUM = X_CONSTRAINT_NUM) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CONSTRAINT_NUM',to_char(tlinfo.CONSTRAINT_NUM));
   end if;

   if ((tlinfo.PERIOD_ID = X_PERIOD_ID)
       OR ((tlinfo.PERIOD_ID is null) AND (X_PERIOD_ID is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_ID',to_char(tlinfo.PERIOD_ID));
   end if;

   if (tlinfo.CONSTR_CAT_CODE = X_CONSTR_CAT_CODE) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CONSTR_CAT_CODE',tlinfo.CONSTR_CAT_CODE);
   end if;

   if (tlinfo.TYPE_CODE = X_TYPE_CODE) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('TYPE_CODE',tlinfo.TYPE_CODE);
   end if;

   if ((tlinfo.AMOUNT = X_AMOUNT)
       OR ((tlinfo.AMOUNT is null) AND (X_AMOUNT is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AMOUNT',to_char(tlinfo.AMOUNT));
   end if;

   if ((tlinfo.AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID)
       OR ((tlinfo.AGREEMENT_TEMPLATE_ID is null) AND (X_AGREEMENT_TEMPLATE_ID is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AGREEMENT_TEMPLATE_ID',to_char(tlinfo.AGREEMENT_TEMPLATE_ID));
   end if;

   if ((tlinfo.CONSTR_DEFAULT_ID = X_CONSTR_DEFAULT_ID)
       OR ((tlinfo.CONSTR_DEFAULT_ID is null) AND (X_CONSTR_DEFAULT_ID is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CONSTR_DEFAULT_ID',to_char(tlinfo.CONSTR_DEFAULT_ID));
   end if;

   if ((tlinfo.CONSTR_TEMPLATE_ID = X_CONSTR_TEMPLATE_ID)
       OR ((tlinfo.CONSTR_TEMPLATE_ID is null) AND (X_CONSTR_TEMPLATE_ID is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CONSTR_TEMPLATE_ID',to_char(tlinfo.CONSTR_TEMPLATE_ID));
   end if;

   if ((tlinfo.COMMENTS = X_COMMENTS)
       OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('COMMENTS',tlinfo.COMMENTS);
   end if;

   if ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
       OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE_CATEGORY',tlinfo.ATTRIBUTE_CATEGORY);
   end if;

   if ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
       OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   end if;

   if ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
       OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE2',tlinfo.ATTRIBUTE2);
   end if;

   if ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
       OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE3',tlinfo.ATTRIBUTE3);
   end if;

   if ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
       OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE4',tlinfo.ATTRIBUTE4);
   end if;

   if ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
       OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE5',tlinfo.ATTRIBUTE5);
   end if;

   if ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
       OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE6',tlinfo.ATTRIBUTE6);
   end if;

   if ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
       OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE7',tlinfo.ATTRIBUTE7);
   end if;

   if ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
       OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE8',tlinfo.ATTRIBUTE8);
   end if;

   if ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
       OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
   end if;

   if ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
       OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE10', tlinfo.ATTRIBUTE10);
   end if;

   if ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
       OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE11',tlinfo.ATTRIBUTE11);
   end if;

   if ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
       OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE12',tlinfo.ATTRIBUTE12);
   end if;

   if ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
       OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE13',tlinfo.ATTRIBUTE13);
   end if;

   if ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
       OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE14',tlinfo.ATTRIBUTE14);
   end if;

   if ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
       OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
   end if;

   if ((tlinfo.CONSTR_START_DATE = X_CONSTR_START_DATE)
       OR ((tlinfo.CONSTR_START_DATE is null) AND (X_CONSTR_START_DATE is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CONSTR_START_DATE',tlinfo.CONSTR_START_DATE);
   end if;
   if ((tlinfo.CONSTR_END_DATE = X_CONSTR_END_DATE)
       OR ((tlinfo.CONSTR_END_DATE is null) AND (X_CONSTR_END_DATE is null))) then
          null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CONSTR_END_DATE',tlinfo.CONSTR_END_DATE);
   end if;

   PNP_DEBUG_PKG.debug ('PN_VAR_CONSTRAINTS_PKG.LOCK_ROW (-)');

END LOCK_ROW;


-------------------------------------------------------------------------------
-- PROCDURE : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 04-JUL-05 piagrawa o Bug 4284035 - Replaced PN_VAR_CONSTRAINTS with _ALL table.
-- 14-MAR-07 Pikhar o Bug 5930407. Commented call to CHECK_MAX_CONSTR
-------------------------------------------------------------------------------

procedure UPDATE_ROW (
  X_CONSTRAINT_ID         in NUMBER,
  X_CONSTRAINT_NUM        in NUMBER,
  X_PERIOD_ID             in NUMBER,
  X_CONSTR_CAT_CODE       in VARCHAR2,
  X_TYPE_CODE             in VARCHAR2,
  X_AMOUNT                in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_CONSTR_TEMPLATE_ID    in NUMBER,
  X_CONSTR_DEFAULT_ID     in NUMBER,
  X_COMMENTS              in VARCHAR2,
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
  X_ATTRIBUTE15           in VARCHAR2,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_CONSTR_START_DATE     in DATE,
  X_CONSTR_END_DATE       in DATE
)
IS
    l_return_status         VARCHAR2(30)    := NULL;

BEGIN

  PNP_DEBUG_PKG.debug ('PN_VAR_CONSTRAINTS_PKG.UPDATE_ROW (+)');

    -- Check for constraint range
    l_return_status     := NULL;

    /*PN_VAR_CONSTRAINTS_PKG.CHECK_MAX_CONSTR
        (
            l_return_status,
            x_period_id,
            x_constraint_id,
            x_constr_cat_code,
            x_type_code,
            x_amount
        );
    IF (l_return_status IS NOT NULL) THEN
        APP_EXCEPTION.Raise_Exception;
    END IF;*/

  UPDATE PN_VAR_CONSTRAINTS_ALL SET
    CONSTRAINT_NUM        = X_CONSTRAINT_NUM,
    PERIOD_ID             = X_PERIOD_ID,
    CONSTR_CAT_CODE       = X_CONSTR_CAT_CODE,
    TYPE_CODE             = X_TYPE_CODE,
    AMOUNT                = X_AMOUNT,
    AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID,
    CONSTR_TEMPLATE_ID    = X_CONSTR_TEMPLATE_ID,
    CONSTR_DEFAULT_ID     = X_CONSTR_DEFAULT_ID,
    COMMENTS              = X_COMMENTS,
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
    ATTRIBUTE15           = X_ATTRIBUTE15,
    LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN,
    CONSTR_START_DATE     = X_CONSTR_START_DATE,
    CONSTR_END_DATE       = X_CONSTR_END_DATE
  WHERE CONSTRAINT_ID = X_CONSTRAINT_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  PNP_DEBUG_PKG.debug ('PN_VAR_CONSTRAINTS_PKG.UPDATE_ROW (+)');

END UPDATE_ROW;


-------------------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_CONSTRAINTS with _ALL table.
-------------------------------------------------------------------------------

procedure DELETE_ROW (
  X_CONSTRAINT_ID in NUMBER
)
IS
BEGIN

  PNP_DEBUG_PKG.debug ('PN_VAR_CONSTRAINTS_PKG.DELETE_ROW (+)');

  DELETE FROM PN_VAR_CONSTRAINTS_ALL
  WHERE CONSTRAINT_ID = X_CONSTRAINT_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  PNP_DEBUG_PKG.debug ('PN_VAR_CONSTRAINTS_PKG.DELETE_ROW (-)');

END DELETE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : CHECK_MAX_CONSTR
-- INVOKED FROM : INSERT_ROW and UPDATE_ROW procedure
-- PURPOSE      : checks for maximum constraint
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_CONSTRAINTS with _ALL table.
-------------------------------------------------------------------------------

PROCEDURE CHECK_MAX_CONSTR
        (
            x_return_status     IN OUT NOCOPY  VARCHAR2,
            x_period_id         IN             NUMBER,
            x_constraint_id     IN             NUMBER,
            x_constr_cat_code   IN             VARCHAR2,
            x_type_code         IN             VARCHAR2,
            x_amount            IN             NUMBER
        )
IS
    l_dummy             NUMBER;
BEGIN
    PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.CHECK_MAX_CONSTR (+)');

    IF x_type_code = 'MIN' THEN

    SELECT  1
    INTO    l_dummy
    FROM    dual
    WHERE   not exists
        (
            SELECT  1
            FROM    pn_var_constraints_all   constr
            WHERE   constr.amount           < (x_amount)
            AND     ((x_constraint_id       is null) or
                      (constr.constraint_id <> x_constraint_id))
            AND     constr.period_id        = x_period_id
            AND     constr.constr_cat_code  = x_constr_cat_code
            AND     constr.type_code        = 'MAX'
        );

    END IF;

    PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.CHECK_MAX_CONSTR (-)');

    EXCEPTION
        WHEN NO_DATA_FOUND  THEN
            fnd_message.set_name ('PN','PN_VAR_WRONG_RANGE');
            --fnd_message.set_token('RENT_NUMBER',
                    --x_rent_num);
            x_return_status := 'E';
END CHECK_MAX_CONSTR;

END PN_VAR_CONSTRAINTS_PKG;

/
