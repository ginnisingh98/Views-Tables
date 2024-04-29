--------------------------------------------------------
--  DDL for Package Body CS_KB_SOLN_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SOLN_CATEGORIES_PKG" AS
/* $Header: cskbcatb.pls 115.10 2003/11/21 22:30:56 mkettle noship $ */

  procedure INSERT_ROW
  (
    X_ROWID                in OUT NOCOPY   VARCHAR2,
    X_CATEGORY_ID          in OUT NOCOPY   NUMBER,
    X_PARENT_CATEGORY_ID   in       NUMBER,
    X_NAME                 in       VARCHAR2,
    X_DESCRIPTION          in       VARCHAR2,
    X_CREATION_DATE        in       DATE,
    X_CREATED_BY           in       NUMBER,
    X_LAST_UPDATE_DATE     in       DATE,
    X_LAST_UPDATED_BY      in       NUMBER,
    X_LAST_UPDATE_LOGIN    in       NUMBER,
    X_VISIBILITY_ID        in       NUMBER
  )
  IS
    cursor getNewCategoryIdCsr is
      select cs_kb_soln_categories_s.nextval
      from dual;

    cursor verifyRowCursor is
      select ROWID
      from CS_KB_SOLN_CATEGORIES_B
      where CATEGORY_ID = X_CATEGORY_ID;
  BEGIN

    /* Get a new category id if none is passed */
    IF (X_CATEGORY_ID IS NULL)
    THEN
      OPEN getNewCategoryIdCsr;
      FETCH getNewCategoryIdCsr INTO X_CATEGORY_ID;
      CLOSE getNewCategoryIdCsr;
    END IF;

    /* created base table record */
    insert into CS_KB_SOLN_CATEGORIES_B
    (
      CATEGORY_ID,
      PARENT_CATEGORY_ID,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      VISIBILITY_ID
    )
    values
    (
      X_CATEGORY_ID,
      X_PARENT_CATEGORY_ID,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_VISIBILITY_ID
    );

    /* create translation table record(s) */
    insert into CS_KB_SOLN_CATEGORIES_TL
    (
      CATEGORY_ID,
      NAME,
      DESCRIPTION,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    )
    select
      X_CATEGORY_ID,
      X_NAME,
      X_DESCRIPTION,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
      (select NULL
       from CS_KB_SOLN_CATEGORIES_TL T
       where T.CATEGORY_ID = X_CATEGORY_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);


    OPEN verifyRowCursor;
    FETCH verifyRowCursor INTO X_ROWID;
    IF (verifyRowCursor%NOTFOUND)
    THEN
      CLOSE verifyRowCursor;
      RAISE NO_DATA_FOUND;
    ELSE
      CLOSE verifyRowCursor;
    END IF;

  END INSERT_ROW;

  procedure UPDATE_ROW
  (
    X_CATEGORY_ID          in       NUMBER,
    X_PARENT_CATEGORY_ID   in       NUMBER,
    X_NAME                 in       VARCHAR2,
    X_DESCRIPTION          in       VARCHAR2,
    X_LAST_UPDATE_DATE     in       DATE,
    X_LAST_UPDATED_BY      in       NUMBER,
    X_LAST_UPDATE_LOGIN    in       NUMBER,
    X_VISIBILITY_ID        in       NUMBER
  )
  is
  begin
    update cs_kb_soln_categories_b
    set
      parent_category_id = X_PARENT_CATEGORY_ID,
      last_update_date   = X_LAST_UPDATE_DATE,
      last_updated_by    = X_LAST_UPDATED_BY,
      last_update_login  = X_LAST_UPDATE_LOGIN,
      visibility_id      = x_visibility_id
    where category_id    = X_CATEGORY_ID;

    if (SQL%NOTFOUND)
    then
      raise NO_DATA_FOUND;
    end if;

    update cs_kb_soln_categories_tl
    set
      name               = X_NAME,
      description        = X_DESCRIPTION,
      last_update_date   = X_LAST_UPDATE_DATE,
      last_updated_by    = X_LAST_UPDATED_BY,
      last_update_login  = X_LAST_UPDATE_LOGIN,
      source_lang = USERENV('LANG')
    where category_id    = X_CATEGORY_ID
    AND USERENV('LANG') IN (language, source_lang);

    if (SQL%NOTFOUND)
    then
      raise NO_DATA_FOUND;
    end if;

  end UPDATE_ROW;

  procedure DELETE_ROW
  (
    X_CATEGORY_ID          in       NUMBER
  )
  is
  begin
    delete from cs_kb_soln_categories_tl
    where category_id = X_CATEGORY_ID;

    if (sql%notfound) then
      raise no_data_found;
    end if;

    delete from cs_kb_soln_categories_b
    where category_id = X_CATEGORY_ID;

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end DELETE_ROW;

  procedure LOCK_ROW
  (
    X_CATEGORY_ID          in       NUMBER,
    X_PARENT_CATEGORY_ID   in       NUMBER,
    X_NAME                 in       VARCHAR2,
    X_DESCRIPTION          in       VARCHAR2,
    X_CREATION_DATE        in       DATE,
    X_CREATED_BY           in       NUMBER,
    X_LAST_UPDATE_DATE     in       DATE,
    X_LAST_UPDATED_BY      in       NUMBER,
    X_LAST_UPDATE_LOGIN    in       NUMBER,
    X_VISIBILITY_ID        in       NUMBER
  )
  is
  begin
    null;
  end LOCK_ROW;

  procedure ADD_LANGUAGE
  is
  begin
    delete from CS_KB_SOLN_CATEGORIES_TL T
    where not exists
      (select NULL
      from CS_KB_SOLN_CATEGORIES_B B
      where B.CATEGORY_ID = T.CATEGORY_ID
      );

    update CS_KB_SOLN_CATEGORIES_TL T
    set ( NAME, DESCRIPTION ) =
    ( select
      T2.NAME,
      T2.DESCRIPTION
      from CS_KB_SOLN_CATEGORIES_TL T2
      where T2.CATEGORY_ID = T.CATEGORY_ID
      and T2.LANGUAGE = T.SOURCE_LANG
    )
    where
    (
        T.CATEGORY_ID,
        T.LANGUAGE
    ) in
    ( select
        SUBT.CATEGORY_ID,
        SUBT.LANGUAGE
      from CS_KB_SOLN_CATEGORIES_TL SUBB, CS_KB_SOLN_CATEGORIES_TL SUBT
      where SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or (SUBB.DESCRIPTION <> SUBT.DESCRIPTION)
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null))
    );

    insert into CS_KB_SOLN_CATEGORIES_TL
   (
      CATEGORY_ID,
      NAME,
      DESCRIPTION,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    ) select
      T.CATEGORY_ID,
      T.NAME,
      T.DESCRIPTION,
      T.CREATION_DATE,
      T.CREATED_BY,
      T.LAST_UPDATE_DATE,
      T.LAST_UPDATED_BY,
      T.LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      T.SOURCE_LANG
    from CS_KB_SOLN_CATEGORIES_TL T, FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and T.LANGUAGE = userenv('LANG')
    and not exists
      (select NULL
      from CS_KB_SOLN_CATEGORIES_TL T2
      where T2.CATEGORY_ID = T.CATEGORY_ID
      and T2.LANGUAGE = L.LANGUAGE_CODE);
  end ADD_LANGUAGE;

  PROCEDURE TRANSLATE_ROW
  (
    X_CATEGORY_ID           in NUMBER,
    X_NAME                  in VARCHAR2,
    X_DESCRIPTION           in VARCHAR2,
    X_OWNER                 in VARCHAR2
  )
  is
  begin
    update CS_KB_SOLN_CATEGORIES_TL
    set
      name = X_NAME,
      description = X_DESCRIPTION,
      last_update_date  = sysdate,
      last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
      last_update_login = 0,
      source_lang       = userenv('LANG')
    where category_id = X_CATEGORY_ID
      and userenv('LANG') in (language, source_lang);
  end TRANSLATE_ROW;

  PROCEDURE LOAD_ROW
  (
    X_CATEGORY_ID           in NUMBER,
    X_PARENT_CATEGORY_ID    in NUMBER,
    X_NAME                  in VARCHAR2,
    X_DESCRIPTION           in VARCHAR2,
    X_OWNER                 in VARCHAR2,
    X_VISIBILITY_ID         in NUMBER
  )
  is
    l_user_id number;
    l_rowid varchar2(100);
    l_category_id number := x_category_id;

    CURSOR Check_Last_Updated_By IS
     SELECT last_updated_by
     FROM cs_kb_soln_categories_b
     WHERE category_id  = X_CATEGORY_ID;

    l_last_upd_by NUMBER := NULL;

  begin
    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

    OPEN  Check_Last_Updated_By;
    FETCH Check_Last_Updated_By INTO l_last_upd_by;
    CLOSE Check_Last_Updated_By;

    IF l_last_upd_by = 1 OR
       l_last_upd_by IS NULL THEN

      update_row
      ( x_category_id => x_category_id,
        x_parent_category_id => x_parent_category_id,
        x_name => x_name,
        x_description => x_description,
        x_last_update_date => sysdate,
        x_last_updated_by => l_user_id,
        x_last_update_login => 0,
        x_visibility_id => x_visibility_id );
    END IF;

  exception
    when no_data_found
    then
      insert_row
      (
        x_rowid              => l_rowid,
        x_category_id        => l_category_id,
        x_parent_category_id => x_parent_category_id,
        x_name               => x_name,
        x_description        => x_description,
        x_creation_date      => sysdate,
        x_created_by         => l_user_id,
        x_last_update_date   => sysdate,
        x_last_updated_by    => l_user_id,
        x_last_update_login  => 0,
        x_visibility_id      => x_visibility_id
      );
  end LOAD_ROW;

END CS_KB_SOLN_CATEGORIES_PKG;

/
