--------------------------------------------------------
--  DDL for Package Body CN_EVENTS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_EVENTS_ALL_PKG" as
/* $Header: cnmlevnb.pls 120.6.12010000.2 2008/10/10 07:18:41 rajukum ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY  VARCHAR2,
  X_EVENT_ID in NUMBER,
  X_APPLICATION_REPOSITORY_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID in NUMBER)
  is
  cursor C is select ROWID from CN_EVENTS_ALL_B
    where EVENT_ID = X_EVENT_ID
    AND ORG_ID = X_ORG_ID;

begin
  insert into CN_EVENTS_ALL_B (
    EVENT_ID,
    APPLICATION_REPOSITORY_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    object_Version_number
  ) values (
    X_EVENT_ID,
    X_APPLICATION_REPOSITORY_ID,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ORG_ID,
	1);

  insert into CN_EVENTS_ALL_TL (
    EVENT_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    X_EVENT_ID,
    X_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_ORG_ID
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CN_EVENTS_ALL_TL T
    where T.EVENT_ID = X_EVENT_ID
    and T.LANGUAGE = L.language_code AND
     ORG_ID = X_ORG_ID);

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_EVENT_ID in NUMBER,
  X_APPLICATION_REPOSITORY_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_ORG_ID IN VARCHAR2
) is
  cursor c is select
      APPLICATION_REPOSITORY_ID,
      DESCRIPTION
    from CN_EVENTS_ALL_B
    where EVENT_ID = X_EVENT_ID AND
	 ORG_ID = X_ORG_ID
    for update of EVENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CN_EVENTS_ALL_TL
    where EVENT_ID = X_EVENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
	 ORG_ID = X_ORG_ID
    for update of EVENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.APPLICATION_REPOSITORY_ID = X_APPLICATION_REPOSITORY_ID)
      AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_EVENT_ID in NUMBER,
  X_APPLICATION_REPOSITORY_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER,
  P_OBJECT_VERSION_NUMBER     IN OUT NOCOPY NUMBER)
IS
	-- Added For R12

	l_object_version_number  CN_EVENTS_ALL_B.OBJECT_VERSION_NUMBER%TYPE;

	CURSOR l_ovn_csr IS
	SELECT object_version_number
	FROM CN_EVENTS_ALL_B
	WHERE EVENT_ID = x_event_id
	AND org_id = x_org_id;
	-- Added For R12

BEGIN

	OPEN l_ovn_csr;
	FETCH l_ovn_csr INTO l_object_version_number;
	CLOSE l_ovn_csr;

	P_OBJECT_VERSION_NUMBER := l_object_version_number;

  update CN_EVENTS_ALL_B set
    APPLICATION_REPOSITORY_ID = X_APPLICATION_REPOSITORY_ID,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER
  where EVENT_ID = x_event_id  AND
        ORG_ID = X_ORG_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  UPDATE CN_EVENTS_ALL_TL
  SET NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  WHERE EVENT_ID = X_EVENT_ID
  AND userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  AND ORG_ID = X_ORG_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;
 END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  X_EVENT_ID in NUMBER,
  X_ORG_ID   IN NUMBER
) is
begin
  delete from CN_EVENTS_ALL_TL
  where EVENT_ID = X_EVENT_ID AND
        ORG_ID = X_ORG_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

  delete from CN_EVENTS_ALL_B
  where EVENT_ID = X_EVENT_ID AND
        ORG_ID = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
END DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CN_EVENTS_ALL_TL T
  where not exists
    (select NULL
    from CN_EVENTS_ALL_B B
    where B.EVENT_ID = T.event_id
    and   B.ORG_ID = T.ORG_ID);

  update CN_EVENTS_ALL_TL T set (
      NAME
    ) = (select
      B.NAME
    from CN_EVENTS_ALL_TL B
    where B.EVENT_ID = T.EVENT_ID
    and B.LANGUAGE = T.source_lang
    and B.ORG_ID = T.ORG_ID)

  where (
      T.EVENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EVENT_ID,
      SUBT.LANGUAGE
    from CN_EVENTS_ALL_TL SUBB, CN_EVENTS_ALL_TL SUBT
    where SUBB.EVENT_ID = SUBT.EVENT_ID
    and SUBB.LANGUAGE = SUBT.source_lang
    and SUBB.org_id = SUBT.org_id
     and (SUBB.NAME <> SUBT.name
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
  ));

  insert into CN_EVENTS_ALL_TL (
    ORG_ID,
    EVENT_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_ID,
    B.EVENT_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CN_EVENTS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_EVENTS_ALL_TL T
    where T.EVENT_ID = B.EVENT_ID
    and T.LANGUAGE = L.language_code
    and T.ORG_ID = B.ORG_ID);
end ADD_LANGUAGE;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_event_id IN NUMBER,
    x_description IN VARCHAR2,
    x_application_repository_id  IN NUMBER,
    x_name IN VARCHAR2,
    x_org_id IN NUMBER,
    x_owner IN VARCHAR2) IS
    user_id NUMBER;

BEGIN
   -- Validate input data
   IF (x_event_id IS NULL) OR (x_application_repository_id IS NULL)
     OR (x_name IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Load The record to _B table
   UPDATE  cn_events_all_b SET
     description = x_description,
     application_repository_id = x_application_repository_id,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
     WHERE event_id = x_event_id
       AND org_id = x_org_id;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      INSERT INTO cn_events_all_b
	(event_id,
	 description,
	 application_repository_id,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	last_update_login,
	org_id
	 ) VALUES
	(x_event_id,
	 x_description,
	 x_application_repository_id,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	0,
	x_org_id
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE cn_events_all_tl SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE event_id = x_event_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
     AND org_id = x_org_id;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO cn_events_all_tl
	(event_id,
	 name,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
         org_id,
	 language,
	 source_lang)
	SELECT
	x_event_id,
	x_name,
	sysdate,
	user_id,
	sysdate,
	user_id,
	0,
        x_org_id,
	l.language_code,
	userenv('LANG')
	FROM fnd_languages l
	WHERE l.installed_flag IN ('I', 'B')
	AND NOT EXISTS
	(SELECT NULL
	 FROM cn_events_all_tl t
	 WHERE t.event_id = x_event_id
	 AND t.language = l.language_code);
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
  ( x_event_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2) IS
       user_id NUMBER;
BEGIN
    -- Validate input data
   IF (x_event_id IS NULL) OR (x_name IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE cn_events_all_tl SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE event_id = x_event_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

end CN_EVENTS_ALL_PKG;

/
