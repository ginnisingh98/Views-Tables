--------------------------------------------------------
--  DDL for Package Body JTF_NAV_TABS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NAV_TABS_PKG" AS
  /* $Header: jtfntabb.pls 120.2 2005/12/12 15:19:48 stopiwal ship $ */

PROCEDURE INSERT_ROW (X_TAB_VALUE in VARCHAR2,
                      X_NAVIGATOR_TYPE IN VARCHAR2,
                      X_APPLICATION_ID in NUMBER,
                      X_ICON_NAME in VARCHAR2,
                      X_SEQUENCE_NUMBER in NUMBER,
                      X_TAB_LABEL in VARCHAR2,
                      X_CREATION_DATE in DATE,
                      X_CREATED_BY in NUMBER,
                      X_LAST_UPDATE_DATE in DATE,
                      X_LAST_UPDATED_BY in NUMBER,
                      X_LAST_UPDATE_LOGIN in NUMBER)
IS

   l_tab_id number := 0;

BEGIN
   -- since our view is based on two tables, make sure the right columns
   -- of each table get updated

   SELECT jtf_nav_tabs_s.nextval
     INTO l_tab_id
     FROM dual;
   insert into JTF_NAV_TABS_b
     (tab_id,
     TAB_VALUE,
     NAVIGATOR_TYPE,
     APPLICATION_ID,
     ICON_NAME,
     SEQUENCE_NUMBER,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
     ) values (
     l_tab_id,
     X_TAB_VALUE,
     x_navigator_type,
     X_APPLICATION_ID,
     X_ICON_NAME,
     X_SEQUENCE_NUMBER,
     X_CREATION_DATE,
     X_CREATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN);

 insert into JTF_NAV_TABS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    tab_id,
    TAB_LABEL,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    l_tab_id,
    X_TAB_LABEL,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_NAV_TABS_TL T
    where T.TAB_id = l_tab_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure UPDATE_ROW
  (x_tab_id IN number,
   X_TAB_VALUE in VARCHAR2,
   X_NAVIGATOR_TYPE IN VARCHAR2,
   X_APPLICATION_ID in NUMBER,
   X_ICON_NAME in VARCHAR2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_TAB_LABEL in VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER) IS
begin
   update JTF_NAV_TABS_B SET
     tab_value = x_tab_value,
     NAVIGATOR_type = X_NAVIGATOR_TYPE,
     APPLICATION_ID = X_APPLICATION_ID,
     ICON_NAME = X_ICON_NAME,
     SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
     LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
     LAST_UPDATED_BY = X_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
     where TAB_id = X_TAB_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_NAV_TABS_TL set
    TAB_LABEL = X_TAB_LABEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TAB_id = X_TAB_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure LOCK_ROW
  (X_TAB_ID in NUMBER,
   X_TAB_VALUE in VARCHAR2,
   X_NAVIGATOR_TYPE IN VARCHAR2,
   X_APPLICATION_ID in NUMBER,
   X_ICON_NAME in VARCHAR2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_TAB_LABEL in VARCHAR2) IS
   cursor c IS
     SELECT tab_value, APPLICATION_ID, ICON_NAME,
       sequence_number, navigator_type
       FROM JTF_NAV_TABS_B
       WHERE TAB_id = X_TAB_id
       FOR UPDATE OF TAB_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TAB_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_NAV_TABS_TL
    where TAB_id = X_TAB_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAB_id nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
    AND (recinfo.ICON_NAME = X_ICON_NAME)
    AND (recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
    AND (recinfo.tab_value = x_tab_value)
    AND ((recinfo.navigator_type = x_navigator_type) OR
    (x_navigator_type IS NULL AND recinfo.navigator_type IS null))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TAB_LABEL = X_TAB_LABEL)
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

procedure DELETE_ROW (X_TAB_id in NUMBER) IS
begin
  delete from JTF_NAV_TABS_TL
  where TAB_id = X_TAB_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_NAV_TABS_B
  where TAB_id = X_TAB_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_NAV_TABS_TL T
  where not exists
    (select NULL
    from JTF_NAV_TABS_B B
    where B.TAB_id = T.TAB_id
    );

  update JTF_NAV_TABS_TL T set (
      TAB_LABEL
    ) = (select
      B.TAB_LABEL
    from JTF_NAV_TABS_TL B
    where B.TAB_id = T.TAB_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAB_id,
      T.LANGUAGE
  ) in (select
      SUBT.TAB_id,
      SUBT.LANGUAGE
    from JTF_NAV_TABS_TL SUBB, JTF_NAV_TABS_TL SUBT
    where SUBB.TAB_id = SUBT.TAB_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAB_LABEL <> SUBT.TAB_LABEL
  ));

  insert into JTF_NAV_TABS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    TAB_id,
    TAB_LABEL,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.TAB_id,
    B.TAB_LABEL,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_NAV_TABS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_NAV_TABS_TL T
    where T.TAB_id = B.TAB_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- --------------------------------------------------------------------
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed data.
-- --------------------------------------------------------------------
PROCEDURE LOAD_row
  (X_TAB_VALUE in VARCHAR2,
   X_NAVIGATOR_TYPE IN varchar2,
   X_APPLICATION_ID in NUMBER,
   X_ICON_NAME in VARCHAR2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_TAB_LABEL in VARCHAR2,
   X_OWNER in VARCHAR2) IS
   user_id NUMBER;
   l_tab_id number;

BEGIN
   -- Validate input data
   IF (x_tab_value IS NULL) OR (x_application_id IS NULL)
     OR (x_tab_label IS NULL) THEN
      GOTO end_load_row;
   END IF;

   /*
   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   */
   user_id := fnd_load_util.owner_id(x_owner);

   -- Load The record to _B table
   UPDATE  jtf_nav_tabs_b SET
     navigator_type = x_navigator_type,
     application_id = x_application_id,
     icon_name = x_icon_name,
     sequence_number = x_sequence_number,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
     WHERE tab_value = x_tab_value;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      SELECT jtf_nav_tabs_s.nextval
        INTO l_tab_id
        FROM dual;

      INSERT INTO jtf_nav_tabs_b
        (tab_id,
        tab_value,
        navigator_type,
        application_id,
        icon_name,
        sequence_number,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
        ) VALUES
        (l_tab_id,
        x_tab_value,
        x_navigator_type,
        x_application_id,
        x_icon_name,
        x_sequence_number,
        sysdate,
        user_id,
        sysdate,
        user_id,
        0
        );
   END IF;

   SELECT tab_id
     INTO l_tab_id
     FROM jtf_nav_tabs_b
     WHERE tab_value = x_tab_value;

   -- Load The record to _TL table
   UPDATE jtf_nav_tabs_tl SET
     tab_label = x_tab_label,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE tab_id = l_tab_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO jtf_nav_tabs_tl
        (tab_id,
         tab_label,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         language,
         source_lang)
        SELECT
        l_tab_id,
        x_tab_label,
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
         FROM jtf_nav_tabs_tl t
         WHERE t.tab_id = l_tab_id
         AND t.language = l.language_code);
   END IF;
   << end_load_row >>
     NULL;
END LOAD_ROW ;

-- --------------------------------------------------------------------
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas.
-- --------------------------------------------------------------------
PROCEDURE TRANSLATE_ROW
  ( x_tab_value IN VARCHAR2,
    x_tab_label IN VARCHAR2,
    x_owner IN VARCHAR2) IS
   user_id NUMBER;
   l_tab_id number;

BEGIN
    -- Validate input data
   IF (x_tab_value IS NULL) OR (x_tab_label IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   /*
   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   */
   user_id := fnd_load_util.owner_id(x_owner);

   --find the correct tab id
   SELECT tab_id
     INTO l_tab_id
     FROM jtf_nav_tabs_b
     WHERE tab_value = x_tab_value;

   -- Update the translation
   UPDATE jtf_nav_tabs_tl SET
     tab_label = x_tab_label,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE tab_id = l_tab_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

END JTF_NAV_TABS_PKG;

/
