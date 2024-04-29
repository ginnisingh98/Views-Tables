--------------------------------------------------------
--  DDL for Package Body JTF_NAV_TREE_ROOTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NAV_TREE_ROOTS_PKG" as
/* $Header: jtfntrb.pls 120.2 2005/12/12 15:20:53 stopiwal ship $ */

procedure INSERT_ROW
(X_ROOT_VALUE in VARCHAR2,
 X_VIEWBY_id in number,
 X_SEQUENCE_NUMBER in NUMBER,
 X_ROOT_LABEL in VARCHAR2,
 X_CREATION_DATE in DATE,
 X_CREATED_BY in NUMBER,
 X_LAST_UPDATE_DATE in DATE,
 X_LAST_UPDATED_BY in NUMBER,
 X_LAST_UPDATE_LOGIN in NUMBER) is

   l_tree_root_id number := 0;

BEGIN
   SELECT jtf_nav_tree_roots_s.nextval
     INTO l_tree_root_id
     FROM dual;
   insert into JTF_NAV_TREE_ROOTS_B (
     tree_root_id,
     ROOT_VALUE,
     VIEWBY_id,
     SEQUENCE_NUMBER,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN) values (
     l_tree_root_id,
     X_ROOT_VALUE,
     X_VIEWBY_id,
     X_SEQUENCE_NUMBER,
     X_CREATION_DATE,
     X_CREATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN);

   insert into JTF_NAV_TREE_ROOTS_TL (
    tree_root_id,
    ROOT_LABEL,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    l_tree_root_id,
      X_ROOT_LABEL,
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
      from JTF_NAV_TREE_ROOTS_TL T
      where T.tree_root_id = l_tree_root_id
      and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure UPDATE_ROW
  (x_tree_root_id IN number,
   X_ROOT_VALUE in VARCHAR2,
   X_VIEWBY_id in number,
   X_SEQUENCE_NUMBER in NUMBER,
   X_ROOT_LABEL in VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER) is
begin
   update JTF_NAV_TREE_ROOTS_B SET
     root_value = x_root_value,
     VIEWBY_id = X_VIEWBY_id,
     SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
     LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
     LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where tree_root_id = x_tree_root_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_NAV_TREE_ROOTS_TL set
    ROOT_LABEL = X_ROOT_LABEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where tree_root_id = x_tree_root_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
     raise no_data_found;
  end if;
end UPDATE_ROW;

procedure LOCK_ROW
  (x_tree_root_id in number,
   X_VIEWBY_id in number,
   x_root_value IN varchar2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_ROOT_LABEL in VARCHAR2) is

   cursor c IS
     SELECT root_value, VIEWBY_id, SEQUENCE_NUMBER
    from JTF_NAV_TREE_ROOTS_B
    where tree_root_id = x_tree_root_id
    for update of tree_root_id nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ROOT_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_NAV_TREE_ROOTS_TL
    where tree_root_id = x_tree_root_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of tree_root_id nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.VIEWBY_id = X_VIEWBY_id)
           OR ((recinfo.VIEWBY_id is null) AND (X_VIEWBY_id is null)))
    AND (recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
    AND (recinfo.root_value = x_root_value)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ROOT_LABEL = X_ROOT_LABEL)
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

procedure DELETE_ROW
  (X_tree_ROOT_id in number) is

begin
  delete from JTF_NAV_TREE_ROOTS_TL
    where tree_root_id = X_tree_ROOT_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_NAV_TREE_ROOTS_B
  where tree_root_id = X_tree_ROOT_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_NAV_TREE_ROOTS_TL T
  where not exists
    (select NULL
    from JTF_NAV_TREE_ROOTS_B B
    where B.tree_root_id = T.tree_root_id
    );

  update JTF_NAV_TREE_ROOTS_TL T set (
      ROOT_LABEL
    ) = (select
      B.ROOT_LABEL
    from JTF_NAV_TREE_ROOTS_TL B
    where B.tree_root_id = T.tree_root_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.tree_root_id,
      T.LANGUAGE
  ) in (select
      SUBT.tree_root_id,
      SUBT.LANGUAGE
    from JTF_NAV_TREE_ROOTS_TL SUBB, JTF_NAV_TREE_ROOTS_TL SUBT
    where SUBB.tree_root_id = SUBT.tree_root_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ROOT_LABEL <> SUBT.ROOT_LABEL
  ));

  insert into JTF_NAV_TREE_ROOTS_TL (
    tree_root_id,
    ROOT_LABEL,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.tree_root_id,
    B.ROOT_LABEL,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_NAV_TREE_ROOTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_NAV_TREE_ROOTS_TL T
    where T.tree_root_id = B.tree_root_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- --------------------------------------------------------------------
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed data.
-- --------------------------------------------------------------------
PROCEDURE LOAD_row
  (X_ROOT_VALUE in VARCHAR2,
   X_VIEWBY_VALUE in VARCHAR2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_ROOT_LABEL in VARCHAR2,
   X_OWNER in VARCHAR2) IS
   user_id NUMBER;
   l_viewby_id number;
   l_tree_root_id number;
BEGIN
   -- Validate input data
   IF (x_root_value IS NULL) OR (x_root_label IS NULL)
     OR (x_viewby_value IS NULL) THEN
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

   --select the viewby id
   SELECT viewby_id
     INTO l_viewby_id
     FROM jtf_nav_viewbys_b
     WHERE viewby_value = x_viewby_value;

   -- Load The record to _B table
   UPDATE  jtf_nav_tree_roots_b SET
     viewby_id = l_viewby_id,
     sequence_number = x_sequence_number,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
     WHERE root_value = x_root_value;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      SELECT jtf_nav_tree_roots_s.nextval
        INTO l_tree_root_id
        FROM dual;

      INSERT INTO jtf_nav_tree_roots_b
        (tree_root_id,
        root_value,
        viewby_id,
        sequence_number,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
        ) VALUES
        (l_tree_root_id,
        x_root_value,
        l_viewby_id,
        x_sequence_number,
        sysdate,
        user_id,
        sysdate,
        user_id,
        0
        );
   END IF;

   --select the tree root id
   SELECT tree_root_id
     INTO l_tree_root_id
     FROM jtf_nav_tree_roots_b
     WHERE root_value = x_root_value;

   -- Load The record to _TL table
   UPDATE jtf_nav_tree_roots_tl SET
     root_label = x_root_label,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE tree_root_id = l_tree_root_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO jtf_nav_tree_roots_tl
        (tree_root_id,
         root_label,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         language,
         source_lang)
        SELECT
        l_tree_root_id,
        x_root_label,
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
         FROM jtf_nav_tree_roots_tl t
          WHERE t.tree_root_id = l_tree_root_id
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
  ( x_root_value IN VARCHAR2,
    x_root_label IN VARCHAR2,
    x_owner IN VARCHAR2) IS
   user_id NUMBER;
   l_tree_root_id number;

BEGIN
    -- Validate input data
   IF (x_root_value IS NULL) OR (x_root_label IS NULL) THEN
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

   --select the tree root id
   SELECT tree_root_id
     INTO l_tree_root_id
     FROM jtf_nav_tree_roots_b
     WHERE root_value = x_root_value;

   -- Update the translation
   UPDATE jtf_nav_tree_roots_tl SET
     root_label = x_root_label,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE tree_root_id = l_tree_root_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

END JTF_NAV_TREE_ROOTS_PKG;

/
