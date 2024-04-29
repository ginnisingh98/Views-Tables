--------------------------------------------------------
--  DDL for Package Body CN_LEDGER_BAL_TYPES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_LEDGER_BAL_TYPES_ALL_PKG" as
/* $Header: cnmllbtb.pls 115.9 2001/10/29 17:08:28 pkm ship    $ */
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
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CN_LEDGER_BAL_TYPES_ALL_B
    where BALANCE_ID = X_BALANCE_ID
    ;
begin
  insert into CN_LEDGER_BAL_TYPES_ALL_B (
--    CREDIT_TYPE_ID,
--    INCENTIVE_TYPE_ID,
    STATISTICAL_TYPE,
    PAYMENT_TYPE,
    BALANCE_ID,
    COLUMN_NAME,
    BALANCE_TYPE,
    SCREEN_SEQUENCE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
--    X_CREDIT_TYPE_ID,
--    X_INCENTIVE_TYPE_ID,
    X_STATISTICAL_TYPE,
    X_PAYMENT_TYPE,
    X_BALANCE_ID,
    X_COLUMN_NAME,
    X_BALANCE_TYPE,
    X_SCREEN_SEQUENCE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CN_LEDGER_BAL_TYPES_ALL_TL (
    BALANCE_ID,
    BALANCE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_BALANCE_ID,
    X_BALANCE_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CN_LEDGER_BAL_TYPES_ALL_TL T
    where T.BALANCE_ID = X_BALANCE_ID
    and T.LANGUAGE = L.language_code AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99));

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

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
) is
  cursor c is select
--      CREDIT_TYPE_ID,
--      INCENTIVE_TYPE_ID,
      STATISTICAL_TYPE,
      PAYMENT_TYPE,
      COLUMN_NAME,
      BALANCE_TYPE,
      SCREEN_SEQUENCE
    from CN_LEDGER_BAL_TYPES_ALL_B
    where BALANCE_ID = x_balance_id AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    for update of BALANCE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      BALANCE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CN_LEDGER_BAL_TYPES_ALL_TL
    where BALANCE_ID = X_BALANCE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    for update of BALANCE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (
--      ((recinfo.CREDIT_TYPE_ID = X_CREDIT_TYPE_ID)
--           OR ((recinfo.CREDIT_TYPE_ID is null) AND (X_CREDIT_TYPE_ID is null)))
--      AND
--      ((recinfo.INCETNIVE_TYPE_ID = X_INCENTIVE_TYPE_ID)
--           OR ((recinfo.INCENTIVE_TYPE_ID is null) AND (X_INCENTIVE_TYPE_ID is null)))
--      AND
      ((recinfo.STATISTICAL_TYPE = X_STATISTICAL_TYPE)
           OR ((recinfo.STATISTICAL_TYPE is null) AND (X_STATISTICAL_TYPE is null)))
      AND ((recinfo.PAYMENT_TYPE = X_PAYMENT_TYPE)
           OR ((recinfo.PAYMENT_TYPE is null) AND (X_PAYMENT_TYPE is null)))
      AND (recinfo.COLUMN_NAME = X_COLUMN_NAME)
      AND (recinfo.BALANCE_TYPE = X_BALANCE_TYPE)
      AND (recinfo.SCREEN_SEQUENCE = X_SCREEN_SEQUENCE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.BALANCE_NAME = X_BALANCE_NAME)
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
) is
begin
  update CN_LEDGER_BAL_TYPES_ALL_B set
--    CREDIT_TYPE_ID = X_CREDIT_TYPE_ID,
--    INCENTIVE_TYPE_ID = X_INCENTIVE_TYPE_ID,
    STATISTICAL_TYPE = X_STATISTICAL_TYPE,
    PAYMENT_TYPE = X_PAYMENT_TYPE,
    COLUMN_NAME = X_COLUMN_NAME,
    BALANCE_TYPE = X_BALANCE_TYPE,
    SCREEN_SEQUENCE = X_SCREEN_SEQUENCE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where BALANCE_ID = X_BALANCE_ID AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CN_LEDGER_BAL_TYPES_ALL_TL set
    BALANCE_NAME = X_BALANCE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where BALANCE_ID = X_BALANCE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_BALANCE_ID in NUMBER
) is
begin
  delete from CN_LEDGER_BAL_TYPES_ALL_TL
  where BALANCE_ID = X_BALANCE_ID AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CN_LEDGER_BAL_TYPES_ALL_B
  where BALANCE_ID = X_BALANCE_ID AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CN_LEDGER_BAL_TYPES_ALL_TL T
  where not exists
    (select NULL
    from CN_LEDGER_BAL_TYPES_ALL_B B
    where B.BALANCE_ID = T.balance_id
    and   NVL(B.ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(T.ORG_ID, NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
    );

  update CN_LEDGER_BAL_TYPES_ALL_TL T set (
      BALANCE_NAME
    ) = (select
      B.BALANCE_NAME
    from CN_LEDGER_BAL_TYPES_ALL_TL B
    where B.BALANCE_ID = T.BALANCE_ID
    and B.LANGUAGE = T.source_lang
    and   NVL(B.ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(T.ORG_ID, NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))	 )
  where (
      T.BALANCE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BALANCE_ID,
      SUBT.LANGUAGE
    from CN_LEDGER_BAL_TYPES_ALL_TL SUBB, CN_LEDGER_BAL_TYPES_ALL_TL SUBT
    where SUBB.BALANCE_ID = SUBT.BALANCE_ID
    and SUBB.LANGUAGE = SUBT.source_lang
    and   NVL(SUBB.ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(SUBT.ORG_ID, NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
    and (SUBB.BALANCE_NAME <> SUBT.BALANCE_NAME
      or (SUBB.BALANCE_NAME is null and SUBT.BALANCE_NAME is not null)
      or (SUBB.BALANCE_NAME is not null and SUBT.BALANCE_NAME is null)
	 ));

  insert into CN_LEDGER_BAL_TYPES_ALL_TL (
    ORG_ID,
    BALANCE_ID,
    BALANCE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_ID,
    B.BALANCE_ID,
    B.BALANCE_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CN_LEDGER_BAL_TYPES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_LEDGER_BAL_TYPES_ALL_TL T
    where T.BALANCE_ID = B.BALANCE_ID
    and T.LANGUAGE = L.language_code
    and   NVL(T.ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(B.ORG_ID, NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))     );
end ADD_LANGUAGE;

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
   x_owner IN VARCHAR2) IS
       user_id NUMBER;

BEGIN
   -- Validate input data
   IF (x_balance_id IS NULL)
     OR  (x_balance_name IS NULL) OR (x_balance_type  IS NULL)
       OR (x_column_name IS NULL) OR (x_screen_sequence IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Load The record to _B table
   UPDATE cn_ledger_bal_types_all_b SET
--    CREDIT_TYPE_ID = X_CREDIT_TYPE_ID,
--    INCENTIVE_TYPE_ID = X_INCENTIVE_TYPE_ID,
     STATISTICAL_TYPE = X_STATISTICAL_TYPE,
     PAYMENT_TYPE = X_PAYMENT_TYPE,
     COLUMN_NAME = X_COLUMN_NAME,
     BALANCE_TYPE = X_BALANCE_TYPE,
     SCREEN_SEQUENCE = X_SCREEN_SEQUENCE,
     LAST_UPDATE_DATE = sysdate,
     LAST_UPDATED_BY = user_id,
     LAST_UPDATE_LOGIN = 0
     WHERE BALANCE_ID = X_BALANCE_ID;
   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      INSERT INTO cn_ledger_bal_types_all_b
	(--    CREDIT_TYPE_ID,
	 --    INCENTIVE_TYPE_ID,
	 BALANCE_ID,
	 STATISTICAL_TYPE,
	 PAYMENT_TYPE,
	 COLUMN_NAME,
	 BALANCE_TYPE,
	 SCREEN_SEQUENCE,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN
	 ) values
	(--    X_CREDIT_TYPE_ID,
	 --    X_INCENTIVE_TYPE_ID,
	 X_BALANCE_ID,
	 X_STATISTICAL_TYPE,
	 X_PAYMENT_TYPE,
	 X_COLUMN_NAME,
	 X_BALANCE_TYPE,
	 X_SCREEN_SEQUENCE,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	 0
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE cn_ledger_bal_types_all_tl SET
     BALANCE_NAME = X_BALANCE_NAME,
     LAST_UPDATE_DATE = sysdate,
     LAST_UPDATED_BY = user_id,
     LAST_UPDATE_LOGIN = 0,
     SOURCE_LANG = userenv('LANG')
     WHERE BALANCE_ID = X_BALANCE_ID
     AND   userenv('LANG') IN (LANGUAGE, SOURCE_LANG);
   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO cn_ledger_bal_types_all_tl
	(BALANCE_ID,
	 BALANCE_NAME,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN,
	 CREATION_DATE,
	 CREATED_BY,
	 LANGUAGE,
	 SOURCE_LANG
	 ) SELECT
	X_BALANCE_ID,
	X_BALANCE_NAME,
	sysdate,
	user_id,
	0,
	sysdate,
	user_id,
	L.LANGUAGE_CODE,
	userenv('LANG')
	FROM FND_LANGUAGES L
	WHERE L.INSTALLED_FLAG IN ('I', 'B')
	AND NOT EXISTS
	(SELECT NULL
	 FROM CN_LEDGER_BAL_TYPES_ALL_TL T
	 WHERE T.BALANCE_ID = X_BALANCE_ID
	 AND T.LANGUAGE = L.LANGUAGE_CODE);
   END IF;
   << end_load_row >>
     NULL;
END  LOAD_ROW ;


-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
  PROCEDURE TRANSLATE_ROW
  ( x_balance_id IN NUMBER,
    x_balance_name IN VARCHAR2,
    x_owner IN VARCHAR2) IS
       user_id NUMBER;
BEGIN
   -- Validate input data
   IF (x_balance_id IS NULL) OR  (x_balance_name IS NULL)  THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE cn_ledger_bal_types_all_tl SET
     balance_name = x_balance_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE balance_id = x_balance_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;


end CN_LEDGER_BAL_TYPES_ALL_PKG;

/
