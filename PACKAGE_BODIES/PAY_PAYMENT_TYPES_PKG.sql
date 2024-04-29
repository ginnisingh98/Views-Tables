--------------------------------------------------------
--  DDL for Package Body PAY_PAYMENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYMENT_TYPES_PKG" as
/* $Header: pypyt01t.pkb 120.0.12010000.3 2009/07/12 10:21:45 namgoyal ship $ */
g_dummy number(1);

PROCEDURE Is_Unique(X_Rowid VARCHAR2,X_Payment_Type_Name VARCHAR2,X_Territory_Code VARCHAR2) IS
result varchar2(255);
Begin
  SELECT NULL INTO result
  FROM PAY_PAYMENT_TYPES
  WHERE UPPER(payment_type_name) = UPPER(X_Payment_Type_Name)
  AND UPPER(Territory_Code) = UPPER(X_Territory_Code)
  AND (Rowid <> X_Rowid OR X_Rowid is NULL);
  IF (SQL%FOUND) THEN
    hr_utility.set_message(801,'HR_6714_PAYM_ALREADY_EXISTS');
    hr_utility.raise_error;
  END IF;
  EXCEPTION
  when NO_DATA_FOUND then
  null;
END Is_Unique;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Payment_Type_Id              IN OUT NOCOPY NUMBER,
                     X_Territory_Code                             VARCHAR2,
                     X_Currency_Code                              VARCHAR2,
                     X_Category                                   VARCHAR2,
                     X_Payment_Type_Name                          VARCHAR2,
-- --
                     X_Base_Payment_Type_Name                     VARCHAR2,
-- --
                     X_Allow_As_Default                           VARCHAR2,
                     X_Description                                VARCHAR2,
                     X_Pre_Validation_Required                    VARCHAR2,
                     X_Procedure_Name                             VARCHAR2,
                     X_Validation_Days                            NUMBER,
                     X_Validation_Value                           VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM PAY_PAYMENT_TYPES

             WHERE payment_type_id = X_Payment_Type_Id;
--
  l_max_id pay_payment_types.payment_type_id%type;
BEGIN
--
  Is_Unique(X_Rowid,X_Payment_Type_Name,X_Territory_Code);
  SELECT Pay_Payment_Types_s.nextval
  INTO X_Payment_Type_Id
  FROM dual;

  /* Defensive coding to prevent duplicate primary keys.
     We've seen issues where the sequence on payment_type has been
     reset and we end up selecting a sequence value which already
     exists on the table.                                         */

  SELECT nvl(max(payment_type_id),0)
  INTO   l_max_id
  FROM   pay_payment_types;

  WHILE X_Payment_Type_Id <= l_max_id LOOP
    SELECT Pay_Payment_Types_s.nextval
    INTO X_Payment_Type_Id
    FROM dual;
  END LOOP;

  INSERT INTO PAY_PAYMENT_TYPES(
          payment_type_id,
          territory_code,
          currency_code,
          category,
          payment_type_name,
          allow_as_default,
          description,
          pre_validation_required,
          procedure_name,
          validation_days,
          validation_value
         ) VALUES (
          X_Payment_Type_Id,
          X_Territory_Code,
          X_Currency_Code,
          X_Category,
          --X_Payment_Type_Name,
-- --
          X_Base_Payment_Type_Name,
-- --
          X_Allow_As_Default,
          X_Description,
          X_Pre_Validation_Required,
          X_Procedure_Name,
          X_Validation_Days,
          X_Validation_Value
  );
--
-- **************************************************************************
--  insert into MLS table (TL)
--
  insert into PAY_PAYMENT_TYPES_TL (
    PAYMENT_TYPE_ID,
    PAYMENT_TYPE_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PAYMENT_TYPE_ID,
    X_PAYMENT_TYPE_NAME,
    X_DESCRIPTION,
    sysdate,
    sysdate,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PAY_PAYMENT_TYPES_TL T
    where T.PAYMENT_TYPE_ID = X_PAYMENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
--
-- *******************************************************************************
--
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;

procedure validate_translation(payment_type_id IN NUMBER,
			       language IN VARCHAR2,
			       payment_type_name IN VARCHAR2,
			       description IN VARCHAR2) IS
/*

This procedure is used to ensure uniqueness of translated payment type names.
It fails if a payment type translation is already present in
the table for a given language.  Otherwise, no action is performed.

Two cursors are required, in case the user does not commit the base table
record before opening the MLS widget and entering a translation.

*/

--
-- This cursor is used if there isn't a valid payment_type_id
-- In this case, we know that the record hasn't yet made it into the
-- database, so no existing translated payment type name should have
-- the same name.
--

   cursor c_translation_exists(p_language IN VARCHAR2,
                               p_payment_type_name IN VARCHAR2) IS
     SELECT 1
     FROM   pay_payment_types_tl
       WHERE language = p_language
       AND upper(payment_type_name) = upper(p_payment_type_name);

--
-- The second cursor implements the validation we actually require,
-- but this will only work if the record exists in the db already,
-- and we have a primary key id.
--

     cursor c_trans_check(p_language IN VARCHAR2,
                             p_payment_type_name IN VARCHAR2,
                             p_payment_type_id IN NUMBER)  IS
       SELECT  1
	 FROM  pay_payment_types_tl ptt,
	       pay_payment_types pty
	 WHERE upper(ptt.payment_type_name)=upper(p_payment_type_name)
	 AND   ptt.payment_type_id = pty.payment_type_id
	 AND   ptt.language = p_language
	 AND   pty.payment_type_id <> p_payment_type_id;

    l_package_name VARCHAR2(80) := 'PAY_PAYMENT_TYPES_PKG.VALIDATE_TRANSLATION';

BEGIN

   hr_utility.set_location (l_package_name,10);

   IF (payment_type_id IS NOT NULL) THEN
      -- We know this record is in the database, and can use
      -- full validation
      OPEN c_trans_check(language, payment_type_name,payment_type_id);
      	hr_utility.set_location (l_package_name,20);
       FETCH c_trans_check INTO g_dummy;

       IF c_trans_check%NOTFOUND THEN
      	hr_utility.set_location (l_package_name,30);
	  CLOSE c_trans_check;
       ELSE
      	hr_utility.set_location (l_package_name,40);
	  CLOSE c_trans_check;
	  fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
	  fnd_message.raise_error;
       END IF;
   ELSE
       OPEN c_translation_exists(language, payment_type_name);
      	hr_utility.set_location (l_package_name,50);
       FETCH c_translation_exists INTO g_dummy;

       IF c_translation_exists%NOTFOUND THEN
      	hr_utility.set_location (l_package_name,60);
	  CLOSE c_translation_exists;
       ELSE
      	hr_utility.set_location (l_package_name,70);
	  CLOSE c_translation_exists;
	  fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
	  fnd_message.raise_error;
       END IF;
   END IF;
      	hr_utility.set_location ('Leaving:'||l_package_name,80);

END validate_translation;

--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Payment_Type_Id                       NUMBER,
                   X_Territory_Code                        VARCHAR2,
                   X_Currency_Code                         VARCHAR2,
                   X_Category                              VARCHAR2,
                   --X_Payment_Type_Name                     VARCHAR2,
-- --
                   X_Base_Payment_Type_Name                     VARCHAR2,
-- --
                   X_Allow_As_Default                      VARCHAR2,
                   X_Description                           VARCHAR2,
                   X_Pre_Validation_Required               VARCHAR2,
                   X_Procedure_Name                        VARCHAR2,
                   X_Validation_Days                       NUMBER,
                   X_Validation_Value                      VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PAY_PAYMENT_TYPES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Payment_Type_Id NOWAIT;
  Recinfo C%ROWTYPE;
--
-- ***************************************************************************
-- cursor for MLS
--
  cursor csr_payment_type_tl is select
      PAYMENT_TYPE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PAY_PAYMENT_TYPES_TL
    where PAYMENT_TYPE_ID = X_PAYMENT_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PAYMENT_TYPE_ID nowait;
--
-- ***************************************************************************
--
      l_mls_count  NUMBER :=0;
--
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Lock_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
--
/** sbilling **/
-- removed explicit lock of _TL table,
-- the MLS strategy requires that the base table is locked before update of the
-- _TL table can take place,
-- which implies it is not necessary to lock both tables.
-- ***************************************************************************
-- code for MLS
--
--  for tlinfo in csr_payment_type_tl LOOP
--     l_mls_count := l_mls_count+1;
--    if (tlinfo.BASELANG = 'Y') then
--      if ((tlinfo.PAYMENT_TYPE_NAME = X_PAYMENT_TYPE_NAME)
--          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
--               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
--      ) then
--        null;
--      else
--        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
--        app_exception.raise_exception;
--      end if;
--    end if;
--  end loop;
----
--if (l_mls_count=0) then -- Trap system errors
--  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
--  hr_utility.set_message_token ('PROCEDURE','PAY_PAYMENT_TYPES_PKG.LOCK_TL_ROW');
--end if;
--
-- ***************************************************************************
--
recinfo.territory_code := rtrim(recinfo.territory_code);
recinfo.currency_code := rtrim(recinfo.currency_code);
recinfo.category := rtrim(recinfo.category);
recinfo.payment_type_name := rtrim(recinfo.payment_type_name);
recinfo.allow_as_default := rtrim(recinfo.allow_as_default);
recinfo.description := rtrim(recinfo.description);
recinfo.pre_validation_required := rtrim(recinfo.pre_validation_required);
recinfo.procedure_name := rtrim(recinfo.procedure_name);
recinfo.validation_value := rtrim(recinfo.validation_value);                    --
  if (
          (   (Recinfo.payment_type_id = X_Payment_Type_Id)
           OR (    (Recinfo.payment_type_id IS NULL)
               AND (X_Payment_Type_Id IS NULL)))
      AND (   (Recinfo.territory_code = X_Territory_Code)
           OR (    (Recinfo.territory_code IS NULL)
               AND (X_Territory_Code IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.category = X_Category)
           OR (    (Recinfo.category IS NULL)
               AND (X_Category IS NULL)))
--    AND (   (Recinfo.payment_type_name = X_Payment_Type_Name)
--         OR (    (Recinfo.payment_type_name IS NULL)
--             AND (X_Payment_Type_Name IS NULL)))
-- --
      AND (   (Recinfo.payment_type_name = X_Base_Payment_Type_Name)
           OR (    (Recinfo.payment_type_name IS NULL)
               AND (X_Base_Payment_Type_Name IS NULL)))
-- --
      AND (   (Recinfo.allow_as_default = X_Allow_As_Default)
           OR (    (Recinfo.allow_as_default IS NULL)
               AND (X_Allow_As_Default IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.pre_validation_required = X_Pre_Validation_Required)
           OR (    (Recinfo.pre_validation_required IS NULL)
               AND (X_Pre_Validation_Required IS NULL)))
      AND (   (Recinfo.procedure_name = X_Procedure_Name)
           OR (    (Recinfo.procedure_name IS NULL)
               AND (X_Procedure_Name IS NULL)))
      AND (   (Recinfo.validation_days = X_Validation_Days)
           OR (    (Recinfo.validation_days IS NULL)
               AND (X_Validation_Days IS NULL)))
      AND (   (Recinfo.validation_value = X_Validation_Value)
           OR (    (Recinfo.validation_value IS NULL)
               AND (X_Validation_Value IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Payment_Type_Id                     NUMBER,
                     X_Territory_Code                      VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Category                            VARCHAR2,
                     X_Payment_Type_Name                   VARCHAR2,
                     X_Allow_As_Default                    VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Pre_Validation_Required             VARCHAR2,
                     X_Procedure_Name                      VARCHAR2,
                     X_Validation_Days                     NUMBER,
                     X_Validation_Value                    VARCHAR2,
                     X_Base_Payment_Type_Name              VARCHAR2
) IS
BEGIN
--
  Is_Unique(X_Rowid,X_Payment_Type_Name,X_Territory_Code);
  UPDATE PAY_PAYMENT_TYPES
  SET

    payment_type_id                           =    X_Payment_Type_Id,
    territory_code                            =    X_Territory_Code,
    currency_code                             =    X_Currency_Code,
    category                                  =    X_Category,
-- --
    --payment_type_name                         =    X_Payment_Type_Name,
-- --
-- -- for bug # 2511059
    payment_type_name                         =    X_Base_Payment_Type_Name,
-- --
    allow_as_default                          =    X_Allow_As_Default,
    description                               =    X_Description,
    pre_validation_required                   =    X_Pre_Validation_Required,
    procedure_name                            =    X_Procedure_Name,
    validation_days                           =    X_Validation_Days,
    validation_value                          =    X_Validation_Value
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Update_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
--
-- ****************************************************************************************
--
--  update MLS table (TL)
--
update PAY_PAYMENT_TYPES_TL
set PAYMENT_TYPE_NAME = X_PAYMENT_TYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = sysdate,
    SOURCE_LANG = userenv('LANG')
where PAYMENT_TYPE_ID = X_PAYMENT_TYPE_ID
and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
--
if (sql%notfound) then	-- trap system errors during update
  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token ('PROCEDURE','PAY_PAYMENT_TYPES_PKG.UPDATE_TL_ROW');
end if;
--
-- ***************************************************************************************
--
END Update_Row;

PROCEDURE Delete_Row(X_payment_type_id NUMBER, X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PAY_PAYMENT_TYPES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Delete_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
--
-- ********************************************************************************
--
-- delete from MLS table (TL)
--
  delete from PAY_PAYMENT_TYPES_TL
  where PAYMENT_TYPE_ID = X_PAYMENT_TYPE_ID;
--
  if sql%notfound then -- trap system errors during deletion
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token ('PROCEDURE','PAY_PAYMENT_TYPES_PKG.DELETE_TL_ROW');
  end if;
--
-- ********************************************************************************
--
END Delete_Row;

----------------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PAY_PAYMENT_TYPES_TL T
  where not exists
    (select NULL
    from PAY_PAYMENT_TYPES B
    where B.PAYMENT_TYPE_ID = T.PAYMENT_TYPE_ID
    );

  update PAY_PAYMENT_TYPES_TL T set (
      PAYMENT_TYPE_NAME,
      DESCRIPTION
    ) = (select
      B.PAYMENT_TYPE_NAME,
      B.DESCRIPTION
    from PAY_PAYMENT_TYPES_TL B
    where B.PAYMENT_TYPE_ID = T.PAYMENT_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PAYMENT_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PAYMENT_TYPE_ID,
      SUBT.LANGUAGE
    from PAY_PAYMENT_TYPES_TL SUBB, PAY_PAYMENT_TYPES_TL SUBT
    where SUBB.PAYMENT_TYPE_ID = SUBT.PAYMENT_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PAYMENT_TYPE_NAME <> SUBT.PAYMENT_TYPE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PAY_PAYMENT_TYPES_TL (
    PAYMENT_TYPE_ID,
    PAYMENT_TYPE_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PAYMENT_TYPE_ID,
    B.PAYMENT_TYPE_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_PAYMENT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_PAYMENT_TYPES_TL T
    where T.PAYMENT_TYPE_ID = B.PAYMENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
------------------------------------------------------------------------------
procedure unique_chk(x_payment_type_name in VARCHAR2,x_territory_code    in VARCHAR2)
is
  result varchar2(255);
Begin
  SELECT count(*) INTO result
  FROM PAY_PAYMENT_TYPES
  WHERE UPPER(payment_type_name) = UPPER(X_Payment_Type_Name)
  AND   UPPER(territory_code) = UPPER(x_territory_code);
  --
  IF (result>1) THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_PAYMENT_TYPES_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_PAYMENT_TYPES_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
end unique_chk;
--
procedure TRANSLATE_ROW(x_b_payment_type_name in VARCHAR2,
                        x_territory_code    in VARCHAR2,
                        x_payment_type_name in VARCHAR2,
                        x_owner             in VARCHAR2,
                        x_description       in VARCHAR2)
is
begin
  -- unique_chk(x_b_payment_type_name,x_territory_code);
  --
  UPDATE pay_payment_types_tl
    SET description = nvl(x_description,description),
        payment_type_name = nvl(x_payment_type_name,payment_type_name),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND payment_type_id IN
        (SELECT PPT.PAYMENT_TYPE_ID
           FROM pay_payment_types ppt
          WHERE nvl(upper(x_territory_code),'~null~') = nvl(upper(ppt.territory_code),'~null~')
            AND nvl(upper(x_b_payment_type_name),'~null~') = nvl(upper(ppt.payment_type_name),'~null~'));
  --
  if (sql%notfound) then  -- trap system errors during update
  --   hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  --   hr_utility.set_message_token ('PROCEDURE','PAY_PAYMENT_TYPES_PKG.TRANSLATE_ROW');
  --   hr_utility.set_message_token('STEP','1');
  --   hr_utility.raise_error;
  null;
  end if;
end TRANSLATE_ROW;
------------------------------------------------------------------------------
procedure LOAD_ROW(x_b_payment_type_name in VARCHAR2,
                   x_territory_code    in VARCHAR2,
                   x_currency_code     in VARCHAR2,
                   x_category          in VARCHAR2,
                   x_allow_as_default  in VARCHAR2,
                   x_pre_validation_required     in VARCHAR2,
                   x_procedure_name    in VARCHAR2,
                   x_validation_days   in NUMBER,
                   x_validation_value  in VARCHAR2,
                   x_payment_type_name in VARCHAR2,
                   x_owner             in VARCHAR2,
                   x_description       in VARCHAR2,
		   x_reconciliation_function in VARCHAR2)
is
  X_PAYMENT_TYPE_ID NUMBER(9);
  CURSOR C IS SELECT PAYMENT_TYPE_ID FROM PAY_PAYMENT_TYPES
               WHERE payment_type_id = X_PAYMENT_TYPE_ID;
begin
  -- unique_chk(x_b_payment_type_name,x_territory_code);
  --
  UPDATE pay_payment_types
    SET description = nvl(x_description,description),
  --      payment_type_name = nvl(x_payment_type_name,payment_type_name),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        currency_code = nvl(x_currency_code,currency_code),
        category = x_category,
        allow_as_default =nvl(x_allow_as_default,allow_as_default),
        pre_validation_required = nvl(x_pre_validation_required,pre_validation_required),
        procedure_name = nvl(x_procedure_name,procedure_name),
        validation_days = nvl(x_validation_days,validation_days),
        validation_value = nvl(x_validation_value,validation_value),
        territory_code = nvl(x_territory_code,territory_code),
	reconciliation_function = x_reconciliation_function
  WHERE nvl(upper(x_territory_code),'~null~') = nvl(upper(territory_code),'~null~')
    AND nvl(upper(x_b_payment_type_name),'~null~') = nvl(upper(payment_type_name),'~null~');
  --
--  exception
--  when NO_DATA_FOUND then
  if (SQL%rowcount = 0) then
  SELECT pay_payment_types_s.nextval
  INTO X_PAYMENT_TYPE_ID
  FROM dual;
  INSERT INTO pay_payment_types(
          PAYMENT_TYPE_ID,
          TERRITORY_CODE,
          CURRENCY_CODE,
          CATEGORY,
          PAYMENT_TYPE_NAME,
          ALLOW_AS_DEFAULT,
          DESCRIPTION,
          PRE_VALIDATION_REQUIRED,
          PROCEDURE_NAME,
          VALIDATION_DAYS,
          VALIDATION_VALUE,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date,
	  reconciliation_function
  )VALUES(
          X_PAYMENT_TYPE_ID,
          X_TERRITORY_CODE,
          X_CURRENCY_CODE,
          X_CATEGORY,
          X_B_PAYMENT_TYPE_NAME,
          X_ALLOW_AS_DEFAULT,
          X_DESCRIPTION,
          X_PRE_VALIDATION_REQUIRED,
          X_PROCEDURE_NAME,
          X_VALIDATION_DAYS,
          X_VALIDATION_VALUE,
          SYSDATE,
          decode(x_owner,'SEED',1,0),
          0,
          decode(x_owner,'SEED',1,0),
          SYSDATE,
	  X_RECONCILIATION_FUNCTION
  );
 INSERT INTO pay_payment_types_tl(
          PAYMENT_TYPE_ID,
          PAYMENT_TYPE_NAME,
          DESCRIPTION,
          LANGUAGE,
          SOURCE_LANG,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATED_BY,
          CREATION_DATE
  ) select
          X_PAYMENT_TYPE_ID,
          X_PAYMENT_TYPE_NAME,
          X_DESCRIPTION,
          L.LANGUAGE_CODE,
          userenv('LANG'),
          SYSDATE,
          decode(x_owner,'SEED',1,0),
          0,
          decode(x_owner,'SEED',1,0),
          SYSDATE
     from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
      and not exists
    (select NULL
    from pay_payment_types_tl T
    where T.PAYMENT_TYPE_ID = X_PAYMENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  OPEN C;
  FETCH C INTO X_PAYMENT_TYPE_ID;
  if (C%NOTFOUND) then
  --  CLOSE C;
  --  hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
  --  hr_utility.set_message_token('PROCEDURE','Insert_Row');
  --  hr_utility.set_message_token('STEP','1');
  --  hr_utility.raise_error;
  null;
  end if;
  CLOSE C;
  -- Bug # 6124985.
  -- Added else part to update the pay_payment_types_tl table if the above
  -- update is successful.
  else
    UPDATE pay_payment_types_tl
    SET description = nvl(x_description,description),
        payment_type_name = nvl(x_payment_type_name,payment_type_name),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
    WHERE userenv('LANG') IN (language,source_lang)
    AND payment_type_id IN
        (SELECT PPT.PAYMENT_TYPE_ID
           FROM pay_payment_types ppt
          WHERE nvl(upper(x_territory_code),'~null~') = nvl(upper(ppt.territory_code),'~null~')
            AND nvl(upper(x_b_payment_type_name),'~null~') = nvl(upper(ppt.payment_type_name),'~null~'));
  end if;
end LOAD_ROW;
------------------------------------------------------------------------------
END PAY_PAYMENT_TYPES_PKG;

/
