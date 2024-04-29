--------------------------------------------------------
--  DDL for Package Body CN_INT_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_INT_TYPE_PKG" AS
/* $Header: cntintvb.pls 120.1 2005/09/20 14:15:46 ymao noship $ */
--
-- Package Name
--   CN_INT_TYPE_PKG
-- Purpose
--   Table handler for CN_INTERVAL_TYPES
-- Form
--   CNINTTP
-- Block
--   INTERVAL_TYPES
--
-- History
--   16-Aug-99  Yonghong Mao  Created

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  get_interval_type_id
-- Purpose
--  Get the sequence number to create a new interval type
-- *--------------------------------------------------------------------------*/
PROCEDURE get_interval_type_id( x_interval_type_id IN OUT NOCOPY NUMBER) IS
BEGIN
   SELECT cn_interval_types_s.NEXTVAL
     INTO x_interval_type_id
     FROM dual;
END get_interval_type_id;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INTERVAL_TYPE_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
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
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID in NUMBER
) is
  cursor C is select ROWID from CN_INTERVAL_TYPES_ALL_B
    where INTERVAL_TYPE_ID = X_INTERVAL_TYPE_ID
      and ORG_ID = X_ORG_ID
    ;
begin
  insert into CN_INTERVAL_TYPES_ALL_B (
    INTERVAL_TYPE_ID,
    DESCRIPTION,
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
    ORG_ID
  ) values (
    X_INTERVAL_TYPE_ID,
    X_DESCRIPTION,
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
    X_ORG_ID
  );

  insert into CN_INTERVAL_TYPES_ALL_TL (
    INTERVAL_TYPE_ID,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    X_INTERVAL_TYPE_ID,
    X_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_ORG_ID
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CN_INTERVAL_TYPES_ALL_TL T
    where T.INTERVAL_TYPE_ID = X_INTERVAL_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE
	and T.ORG_ID = X_ORG_ID);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_INTERVAL_TYPE_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
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
  X_ORG_ID in NUMBER
) is
  cursor c is select
      DESCRIPTION,
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
    from CN_INTERVAL_TYPES_ALL_B
    where INTERVAL_TYPE_ID = X_INTERVAL_TYPE_ID
      and ORG_ID = nvl(X_ORG_ID, ORG_ID)
    for update of INTERVAL_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CN_INTERVAL_TYPES_ALL_TL
    where INTERVAL_TYPE_ID = X_INTERVAL_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INTERVAL_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
end LOCK_ROW;

procedure UPDATE_ROW (
  X_INTERVAL_TYPE_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID in NUMBER
) is
begin
  update CN_INTERVAL_TYPES_ALL_B set
    DESCRIPTION = X_DESCRIPTION,
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
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INTERVAL_TYPE_ID = X_INTERVAL_TYPE_ID
    and ORG_ID = nvl(X_ORG_ID, ORG_ID);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CN_INTERVAL_TYPES_ALL_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INTERVAL_TYPE_ID = X_INTERVAL_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INTERVAL_TYPE_ID in NUMBER
) is
begin
  delete from CN_INTERVAL_TYPES_ALL_TL
  where INTERVAL_TYPE_ID = X_INTERVAL_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CN_INTERVAL_TYPES_ALL_B
  where INTERVAL_TYPE_ID = X_INTERVAL_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CN_INTERVAL_TYPES_ALL_TL T
  where not exists
    (select NULL
    from CN_INTERVAL_TYPES_ALL_B B
    where B.INTERVAL_TYPE_ID = T.interval_type_id
    and   B.ORG_ID = T.ORG_ID
    );

  update CN_INTERVAL_TYPES_ALL_TL T set (
      NAME
    ) = (select
      B.NAME
    from CN_INTERVAL_TYPES_ALL_TL B
    where B.INTERVAL_TYPE_ID = T.INTERVAL_TYPE_ID
    and B.LANGUAGE = T.source_lang
    and   B.ORG_ID = T.ORG_ID)
  where (
      T.INTERVAL_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INTERVAL_TYPE_ID,
      SUBT.LANGUAGE
    from CN_INTERVAL_TYPES_ALL_TL SUBB, CN_INTERVAL_TYPES_ALL_TL SUBT
    where SUBB.INTERVAL_TYPE_ID = SUBT.INTERVAL_TYPE_ID
    and SUBB.LANGUAGE = SUBT.source_lang
    and   SUBB.ORG_ID =SUBT.ORG_ID
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
	 ));

  insert into CN_INTERVAL_TYPES_ALL_TL (
    ORG_ID,
    INTERVAL_TYPE_ID,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_ID,
    B.INTERVAL_TYPE_ID,
    B.NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CN_INTERVAL_TYPES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_INTERVAL_TYPES_ALL_TL T
    where T.INTERVAL_TYPE_ID = B.INTERVAL_TYPE_ID
    and T.LANGUAGE = L.language_code
    and   T.ORG_ID = B.ORG_ID  );
end ADD_LANGUAGE;

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  post_insert
-- Purpose
--  Populate the table cn_cal_per_int_types after creating an interval type
-- *--------------------------------------------------------------------------*/
PROCEDURE post_insert
  ( x_interval_type_id        cn_interval_types.interval_type_id%TYPE,
    x_last_update_date        cn_interval_types.last_update_date%TYPE,
    x_last_updated_by         cn_interval_types.last_updated_by%TYPE,
    x_creation_date           cn_interval_types.creation_date%TYPE,
    x_created_by              cn_interval_types.created_by%TYPE,
    x_last_update_login       cn_interval_types.last_update_login%TYPE,
    x_org_id                  cn_interval_types.org_id%TYPE
    ) IS
   l_period_set_id            NUMBER;
   l_period_type_id           NUMBER;
   l_period_id                NUMBER;
   l_cal_per_int_type_id      NUMBER;

   CURSOR c IS
      SELECT period_id
	FROM cn_period_statuses_all
	WHERE period_type_id = l_period_type_id
	  AND period_set_id = l_period_set_id
	  AND org_id = x_org_id;
BEGIN
   SELECT period_set_id, period_type_id
     INTO l_period_set_id, l_period_type_id
     FROM cn_repositories_all
    WHERE org_id = x_org_id;

   OPEN c;
   LOOP
      FETCH c INTO l_period_id;
      EXIT WHEN c%notfound;

      l_cal_per_int_type_id := null;
      cn_int_assign_pkg.insert_row
	(x_cal_per_int_type_id => l_cal_per_int_type_id,
	 x_interval_type_id    => x_interval_type_id,
	 x_cal_period_id       => l_period_id,
	 x_interval_number     => 1,
	 x_last_update_date    => x_last_update_date,
	 x_last_updated_by     => x_last_updated_by,
	 x_creation_date       => x_creation_date,
	 x_created_by          => x_created_by,
	 x_last_update_login   => x_last_update_login,
	 x_org_id              => x_org_id
	 );

   END LOOP;
   CLOSE c;

END post_insert;


--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  post_delete
-- Purpose
--  Delete the corresponding records in cn_cal_per_int_types after deleting an interval type
-- *--------------------------------------------------------------------------*/
PROCEDURE post_delete( x_interval_type_id  cn_interval_types.interval_type_id%TYPE) IS
BEGIN
   DELETE FROM cn_cal_per_int_types_all
     WHERE interval_type_id = x_interval_type_id;
EXCEPTION
   WHEN no_data_found THEN
      RETURN;
   WHEN OTHERS THEN
     app_exception.raise_exception;
END post_delete;
-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_interval_type_id IN NUMBER,
    x_description IN VARCHAR2,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2,
	x_org_id IN NUMBER)
IS
    user_id NUMBER;
BEGIN
   -- Validate input data
   IF (x_interval_type_id IS NULL) OR (x_name IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Load The record to _B table
   UPDATE  cn_interval_types_all_b SET
     description = x_description,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
   WHERE interval_type_id = x_interval_type_id;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
     INSERT INTO cn_interval_types_all_b
	(interval_type_id,
	 description,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 org_id
	 ) VALUES
	(x_interval_type_id,
	 x_description,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	 0,
	 x_org_id
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE cn_interval_types_all_tl SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE interval_type_id = x_interval_type_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO cn_interval_types_all_tl
	(interval_type_id,
	 name,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 language,
	 source_lang,
	 org_id)
	SELECT
	x_interval_type_id,
	x_name,
	sysdate,
	user_id,
	sysdate,
	user_id,
	0,
	l.language_code,
	userenv('LANG'),
	x_org_id
	FROM fnd_languages l
	WHERE l.installed_flag IN ('I', 'B')
	AND NOT EXISTS
	(SELECT NULL
	 FROM cn_interval_types_all_tl t
	 WHERE t.interval_type_id = x_interval_type_id
	 AND t.language = l.language_code
	 and t.org_id = x_org_id);
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
  ( x_interval_type_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2)
IS
    user_id NUMBER;
BEGIN
    -- Validate input data
   IF (x_interval_type_id IS NULL) OR (x_name IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE cn_interval_types_all_tl SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE interval_type_id = x_interval_type_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

END CN_INT_TYPE_PKG;

/
