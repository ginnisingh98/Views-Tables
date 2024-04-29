--------------------------------------------------------
--  DDL for Package Body CN_CREDIT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CREDIT_TYPES_PKG" as
/* $Header: cncrtdnb.pls 120.3 2005/09/25 23:49:45 raramasa ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CREDIT_TYPE_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MONETARY_FLAG in VARCHAR2,
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
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PRECISION in NUMBER,
  X_EXTENDED_PRECISION in NUMBER
) is
  cursor C is select ROWID from CN_CREDIT_TYPES_ALL_B
    where CREDIT_TYPE_ID = X_CREDIT_TYPE_ID
    ;
begin
  insert into CN_CREDIT_TYPES_ALL_B (
    CREDIT_TYPE_ID,
    ORG_ID,
    DESCRIPTION,
    MONETARY_FLAG,
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
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    PRECISION,
    EXTENDED_PRECISION
  ) VALUES(
    X_CREDIT_TYPE_ID,
    X_ORG_ID,
    X_DESCRIPTION,
    X_MONETARY_FLAG,
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
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_PRECISION,
    X_EXTENDED_PRECISION
);

  insert into CN_CREDIT_TYPES_ALL_TL (
    CREDIT_TYPE_ID,
    ORG_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREDIT_TYPE_ID,
    X_ORG_ID,
    X_NAME,
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
    from CN_CREDIT_TYPES_ALL_TL T
    where T.CREDIT_TYPE_ID = X_CREDIT_TYPE_ID
    and T.LANGUAGE = L.language_code AND
        T.ORG_ID = X_ORG_ID
     );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

/*procedure LOCK_ROW (
  X_CREDIT_TYPE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MONETARY_FLAG in VARCHAR2,
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
  X_PRECISION in NUMBER,
  X_EXTENDED_PRECISION in NUMBER
) is
  cursor c is select
      DESCRIPTION,
      MONETARY_FLAG,
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
      PRECISION,
      EXTENDED_PRECISION
    from CN_CREDIT_TYPES_ALL_B
    where CREDIT_TYPE_ID = X_CREDIT_TYPE_ID AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    for update of CREDIT_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CN_CREDIT_TYPES_ALL_TL
    where CREDIT_TYPE_ID = X_CREDIT_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
     NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    for update of CREDIT_TYPE_ID nowait;

begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (   ((recinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND (recinfo.MONETARY_FLAG = X_MONETARY_FLAG)
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
          AND ((recinfo.PRECISION = X_PRECISION)
               OR ((recinfo.PRECISION is null) AND (X_PRECISION is null)))
          AND ((recinfo.EXTENDED_PRECISION = X_EXTENDED_PRECISION)
               OR ((recinfo.EXTENDED_PRECISION is null) AND (X_EXTENDED_PRECISION is null)))
      ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

end LOCK_ROW;*/

procedure UPDATE_ROW (
  X_CREDIT_TYPE_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MONETARY_FLAG in VARCHAR2,
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PRECISION in NUMBER,
  X_EXTENDED_PRECISION in NUMBER
) is
begin
  update CN_CREDIT_TYPES_ALL_B set
    DESCRIPTION = X_DESCRIPTION,
    MONETARY_FLAG = X_MONETARY_FLAG,
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
    PRECISION = X_PRECISION,
    EXTENDED_PRECISION = X_EXTENDED_PRECISION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CREDIT_TYPE_ID = X_CREDIT_TYPE_ID AND
        ORG_ID = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CN_CREDIT_TYPES_ALL_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CREDIT_TYPE_ID = X_CREDIT_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
             ORG_ID = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_CREDIT_TYPE_ID in NUMBER,
  X_ORG_ID in NUMBER
) is
begin
  delete from CN_CREDIT_TYPES_ALL_TL
  where CREDIT_TYPE_ID = X_CREDIT_TYPE_ID AND
        ORG_ID = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CN_CREDIT_TYPES_ALL_B
  where CREDIT_TYPE_ID = X_CREDIT_TYPE_ID AND
        ORG_ID = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CN_CREDIT_TYPES_ALL_TL T
  where not exists
    (select NULL
    from CN_CREDIT_TYPES_ALL_B B
     where B.CREDIT_TYPE_ID = T.credit_type_id
    and   B.org_id = T.org_id
    );

  update CN_CREDIT_TYPES_ALL_TL T set (
      NAME
    ) = (select
      B.NAME
    from CN_CREDIT_TYPES_ALL_TL B
    where B.CREDIT_TYPE_ID = T.CREDIT_TYPE_ID
    and B.LANGUAGE = T.source_lang
    and   B.org_id = T.org_id)
  where (
      T.CREDIT_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CREDIT_TYPE_ID,
      SUBT.LANGUAGE
    from CN_CREDIT_TYPES_ALL_TL SUBB, CN_CREDIT_TYPES_ALL_TL SUBT
    where SUBB.CREDIT_TYPE_ID = SUBT.CREDIT_TYPE_ID
    and SUBB.LANGUAGE = SUBT.source_lang
    and   SUBB.org_id = SUBT.org_id
    and (SUBB.NAME <> SUBT.name
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
  ));

  insert into CN_CREDIT_TYPES_ALL_TL (
    ORG_ID,
    CREDIT_TYPE_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    b.org_id,
    B.CREDIT_TYPE_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CN_CREDIT_TYPES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_CREDIT_TYPES_ALL_TL T
    where T.CREDIT_TYPE_ID = B.CREDIT_TYPE_ID
     and T.LANGUAGE = L.language_code
    and   T.org_id = B.org_id);
end ADD_LANGUAGE;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( X_CREDIT_TYPE_ID IN NUMBER,
    X_ORG_ID IN NUMBER,
    X_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_MONETARY_FLAG in VARCHAR2,
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
    X_PRECISION in NUMBER,
    X_EXTENDED_PRECISION in NUMBER,
    x_owner IN VARCHAR2) IS
       user_id NUMBER;

BEGIN
   -- Validate input data
   IF (x_credit_type_id IS NULL) OR (x_monetary_flag IS NULL)
     OR (x_name IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;

   -- Load The record to _B table
   UPDATE  cn_credit_types_all_b SET
     DESCRIPTION = X_DESCRIPTION,
     MONETARY_FLAG = X_MONETARY_FLAG,
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
     PRECISION = X_PRECISION,
     EXTENDED_PRECISION = X_EXTENDED_PRECISION,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
     WHERE credit_type_id = x_credit_type_id;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      INSERT INTO cn_credit_types_all_b
	(
         CREDIT_TYPE_ID,
         ORG_ID,
         DESCRIPTION,
         MONETARY_FLAG,
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
         PRECISION,
         EXTENDED_PRECISION,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login
	 ) VALUES
	(X_CREDIT_TYPE_ID,
	     X_ORG_ID,
         X_DESCRIPTION,
         X_MONETARY_FLAG,
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
         X_PRECISION,
         X_EXTENDED_PRECISION,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	 0
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE cn_credit_types_all_tl SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE credit_type_id = x_credit_type_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO cn_credit_types_all_tl
	(credit_type_id,
	 org_id,
	 name,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 language,
	 source_lang)
	SELECT
	x_credit_type_id,
	x_org_id,
	x_name,
	sysdate,
	user_id,
	sysdate,
	user_id,
	0,
	l.language_code,
	userenv('LANG')
	FROM fnd_languages l
	WHERE l.installed_flag IN ('I', 'B')
	AND NOT EXISTS
	(SELECT NULL
	 FROM cn_credit_types_all_tl t
	 WHERE t.credit_type_id = x_credit_type_id
	 AND t.language = l.language_code
     AND org_id = x_org_id);
   END IF;
   << end_load_row >>
     NULL;
END LOAD_ROW ;

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_credit_type_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2) IS
       user_id NUMBER;
BEGIN
    -- Validate input data
   IF (x_credit_type_id IS NULL) OR (x_name IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE cn_credit_types_all_tl SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE credit_type_id = x_credit_type_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

end CN_CREDIT_TYPES_PKG;

/
