--------------------------------------------------------
--  DDL for Package Body JTF_NAV_VIEWBYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NAV_VIEWBYS_PKG" as
/* $Header: jtfnvbyb.pls 120.2 2005/12/12 15:48:32 stopiwal ship $ */

procedure INSERT_ROW (
  X_VIEWBY_VALUE in VARCHAR2,
  X_TAB_id in number,
  X_SEQUENCE_NUMBER in NUMBER,
  X_VIEWBY_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is

   l_viewby_id number := 0;

BEGIN
   SELECT jtf_nav_viewbys_s.nextval
     INTO l_viewby_id
     FROM dual;
   insert into JTF_NAV_VIEWBYS_B
     (viewby_id,
     VIEWBY_VALUE,
     TAB_id,
     SEQUENCE_NUMBER,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
     ) values (
     l_viewby_id,
     X_VIEWBY_VALUE,
     X_TAB_id,
     X_SEQUENCE_NUMBER,
     X_CREATION_DATE,
     X_CREATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN);

   insert into JTF_NAV_VIEWBYS_TL (
     viewby_id,
     VIEWBY_LABEL,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATE_LOGIN,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LANGUAGE,
     SOURCE_LANG)
     select
     l_viewby_id,
       X_VIEWBY_LABEL,
       X_CREATED_BY,
       X_CREATION_DATE,
       X_LAST_UPDATE_LOGIN,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       L.LANGUAGE_CODE,
       userenv('LANG')
       from FND_LANGUAGES L
       where L.INSTALLED_FLAG in ('I', 'B')
       and not exists
       (select NULL
       from JTF_NAV_VIEWBYS_TL T
       where T.VIEWBY_id = l_viewby_id
       and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure UPDATE_ROW
  (x_viewby_id IN number,
  X_VIEWBY_VALUE in VARCHAR2,
  X_TAB_id in number,
  X_SEQUENCE_NUMBER in NUMBER,
  X_VIEWBY_LABEL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is
begin
   update JTF_NAV_VIEWBYS_B SET
     viewby_value = x_viewby_value,
     TAB_id = X_TAB_id,
     SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
     LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
     LAST_UPDATED_BY = X_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
     where VIEWBY_id = X_VIEWBY_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_NAV_VIEWBYS_TL set
    VIEWBY_LABEL = X_VIEWBY_LABEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VIEWBY_id = X_VIEWBY_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure LOCK_ROW (
  X_VIEWBY_id in number,
  X_TAB_id in number,
  X_VIEWBY_VALUE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_VIEWBY_LABEL in VARCHAR2) is

   cursor c IS
     select viewby_value, TAB_id, SEQUENCE_NUMBER
       from JTF_NAV_VIEWBYS_B
       where VIEWBY_id = X_VIEWBY_id
       for update of VIEWBY_id nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VIEWBY_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_NAV_VIEWBYS_TL
    where VIEWBY_id = X_VIEWBY_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VIEWBY_id nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.TAB_id = X_TAB_id)
           OR ((recinfo.TAB_id is null) AND (X_TAB_id is null)))
    AND (recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
    AND (recinfo.viewby_value = x_viewby_value)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.VIEWBY_LABEL = X_VIEWBY_LABEL)
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

procedure DELETE_ROW (
  X_VIEWBY_id in number) is
begin
  delete from JTF_NAV_VIEWBYS_TL
  where VIEWBY_id = X_VIEWBY_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_NAV_VIEWBYS_B
  where VIEWBY_id = X_VIEWBY_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_NAV_VIEWBYS_TL T
  where not exists
    (select NULL
    from JTF_NAV_VIEWBYS_B B
    where B.VIEWBY_id = T.VIEWBY_id
    );

  update JTF_NAV_VIEWBYS_TL T set (
      VIEWBY_LABEL
    ) = (select
      B.VIEWBY_LABEL
    from JTF_NAV_VIEWBYS_TL B
    where B.VIEWBY_id = T.VIEWBY_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VIEWBY_id,
      T.LANGUAGE
  ) in (select
      SUBT.VIEWBY_id,
      SUBT.LANGUAGE
    from JTF_NAV_VIEWBYS_TL SUBB, JTF_NAV_VIEWBYS_TL SUBT
    where SUBB.VIEWBY_id = SUBT.VIEWBY_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VIEWBY_LABEL <> SUBT.VIEWBY_LABEL
  ));

  insert into JTF_NAV_VIEWBYS_TL (
    VIEWBY_id,
    VIEWBY_LABEL,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.VIEWBY_id,
    B.VIEWBY_LABEL,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_NAV_VIEWBYS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_NAV_VIEWBYS_TL T
    where T.VIEWBY_id = B.VIEWBY_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- --------------------------------------------------------------------
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed data.
-- --------------------------------------------------------------------
PROCEDURE LOAD_row
  (X_VIEWBY_VALUE in VARCHAR2,
   X_TAB_VALUE in VARCHAR2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_VIEWBY_LABEL in VARCHAR2,
   X_OWNER in VARCHAR2) IS
   user_id NUMBER;
   l_tab_id number;
   l_viewby_id number;

BEGIN
   -- Validate input data
   IF (x_viewby_value IS NULL) OR (x_viewby_label IS NULL)
     OR (x_tab_value IS NULL) THEN
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

   --select the tab id
   SELECT tab_id
     INTO l_tab_id
     FROM jtf_nav_tabs_b
     WHERE tab_value = x_tab_value;

   -- Load The record to _B table
   UPDATE  jtf_nav_viewbys_b SET
     tab_id = l_tab_id,
     sequence_number = x_sequence_number,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
     WHERE viewby_value = x_viewby_value;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      SELECT jtf_nav_viewbys_s.nextval
        INTO l_viewby_id
        FROM dual;

      INSERT INTO jtf_nav_viewbys_b
        (viewby_id,
        viewby_value,
        tab_id,
        sequence_number,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
        ) VALUES
        (l_viewby_id,
        x_viewby_value,
        l_tab_id,
        x_sequence_number,
        sysdate,
        user_id,
        sysdate,
        user_id,
        0
        );
   END IF;

   --select the viewby id
   SELECT viewby_id
     INTO l_viewby_id
     FROM jtf_nav_viewbys_b
     WHERE viewby_value = x_viewby_value;

   -- Load The record to _TL table
   UPDATE jtf_nav_viewbys_tl SET
     viewby_label = x_viewby_label,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE viewby_id = l_viewby_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO jtf_nav_viewbys_tl
        (viewby_id,
         viewby_label,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         language,
         source_lang)
        SELECT
        l_viewby_id,
        x_viewby_label,
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
         FROM jtf_nav_viewbys_tl t
         WHERE t.viewby_id = l_viewby_id
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
  ( x_viewby_VALUE IN VARCHAR2,
    x_viewby_label IN VARCHAR2,
    x_owner IN VARCHAR2) IS
   user_id NUMBER;
   l_viewby_id number;

BEGIN
    -- Validate input data
   IF (x_viewby_value IS NULL) OR (x_viewby_label IS NULL) THEN
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

   --select the viewby_id
   SELECT viewby_id
     INTO l_viewby_id
     FROM jtf_nav_viewbys_b
     WHERE viewby_value = x_viewby_value;

   -- Update the translation
   UPDATE jtf_nav_viewbys_tl SET
     viewby_label = x_viewby_label,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE viewby_id = l_viewby_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

END JTF_NAV_VIEWBYS_PKG;

/
