--------------------------------------------------------
--  DDL for Package Body AMV_I_PERSPECTIVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_I_PERSPECTIVES_PKG" as
/* $Header: amvvpshb.pls 120.1 2005/06/21 16:49:20 appldev ship $ */
procedure Load_Row(
  x_perspective_id   in  varchar2,
  x_object_version_number in varchar2,
  x_perspective_name in  varchar2,
  x_description      in  varchar2,
  x_owner            in  varchar2
) IS
l_user_id          number := 0;
l_perspective_id   number := 0;
l_object_version_number number := 0;
l_row_id           varchar2(64);
begin
     if (X_OWNER = 'SEED') then
         l_user_id := 1;
     end if;
     l_perspective_id := to_number(x_perspective_id);
     l_object_version_number := to_number(x_object_version_number);
     --
     UPDATE_ROW (
         X_PERSPECTIVE_ID    => l_perspective_id,
         X_OBJECT_VERSION_NUMBER => l_object_version_number,
         X_PERSPECTIVE_NAME  => x_perspective_name,
         X_DESCRIPTION       => x_description,
         X_LAST_UPDATE_DATE  => sysdate,
         X_LAST_UPDATED_BY   => l_user_id,
         X_LAST_UPDATE_LOGIN => 0);
exception
     when NO_DATA_FOUND then
         INSERT_ROW (
             X_ROWID            => l_row_id,
             X_OBJECT_VERSION_NUMBER => l_object_version_number,
             X_PERSPECTIVE_ID   => l_perspective_id,
             X_PERSPECTIVE_NAME => x_perspective_name,
             X_DESCRIPTION      => x_description,
             X_CREATION_DATE    => sysdate,
             X_CREATED_BY       => l_user_id,
             X_LAST_UPDATE_DATE => sysdate,
             X_LAST_UPDATED_BY  => l_user_id,
             X_LAST_UPDATE_LOGIN => 0
         );
end Load_Row;
--
procedure Translate_row (
  x_perspective_id   in  number,
  x_perspective_name in  varchar2,
  x_description      in  varchar2,
  x_owner            in  varchar2
) is
begin
    update AMV_I_PERSPECTIVES_TL set
       PERSPECTIVE_NAME = x_perspective_name,
       DESCRIPTION      = x_description,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = decode(x_owner, 'SEED', 1, 0),
       LAST_UPDATE_LOGIN = 0,
       SOURCE_LANG = userenv('LANG')
    where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    and PERSPECTIVE_ID = x_perspective_id;
end Translate_row;
--
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSPECTIVE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSPECTIVE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMV_I_PERSPECTIVES_B
    where PERSPECTIVE_ID = X_PERSPECTIVE_ID
    ;
begin
  insert into AMV_I_PERSPECTIVES_B (
    PERSPECTIVE_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PERSPECTIVE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMV_I_PERSPECTIVES_TL (
    PERSPECTIVE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    PERSPECTIVE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PERSPECTIVE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PERSPECTIVE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMV_I_PERSPECTIVES_TL T
    where T.PERSPECTIVE_ID = X_PERSPECTIVE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_PERSPECTIVE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSPECTIVE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is
  select OBJECT_VERSION_NUMBER
    from AMV_I_PERSPECTIVES_B
    where PERSPECTIVE_ID = X_PERSPECTIVE_ID
    for update of PERSPECTIVE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PERSPECTIVE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMV_I_PERSPECTIVES_TL
    where PERSPECTIVE_ID = X_PERSPECTIVE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PERSPECTIVE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ( recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PERSPECTIVE_NAME = X_PERSPECTIVE_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_PERSPECTIVE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSPECTIVE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_sql_statement      VARCHAR2(2000);
begin
  update AMV_I_PERSPECTIVES_B set
    OBJECT_VERSION_NUMBER = decode(X_OBJECT_VERSION_NUMBER,
               FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER + 1,
               X_OBJECT_VERSION_NUMBER),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PERSPECTIVE_ID = X_PERSPECTIVE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMV_I_PERSPECTIVES_TL set
    PERSPECTIVE_NAME =
      decode(X_PERSPECTIVE_NAME, FND_API.G_MISS_CHAR, PERSPECTIVE_NAME,
                                 X_PERSPECTIVE_NAME),
    DESCRIPTION =
      decode(X_DESCRIPTION, FND_API.G_MISS_CHAR, DESCRIPTION,
                                 X_DESCRIPTION),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PERSPECTIVE_ID = X_PERSPECTIVE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_PERSPECTIVE_ID in NUMBER
) is
begin
  delete from AMV_I_PERSPECTIVES_TL
  where PERSPECTIVE_ID = X_PERSPECTIVE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMV_I_PERSPECTIVES_B
  where PERSPECTIVE_ID = X_PERSPECTIVE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMV_I_PERSPECTIVES_TL T
  where not exists
    (select NULL
    from AMV_I_PERSPECTIVES_B B
    where B.PERSPECTIVE_ID = T.PERSPECTIVE_ID
    );

  update AMV_I_PERSPECTIVES_TL T set (
      PERSPECTIVE_NAME,
      DESCRIPTION
    ) = (select
      B.PERSPECTIVE_NAME,
      B.DESCRIPTION
    from AMV_I_PERSPECTIVES_TL B
    where B.PERSPECTIVE_ID = T.PERSPECTIVE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PERSPECTIVE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PERSPECTIVE_ID,
      SUBT.LANGUAGE
    from AMV_I_PERSPECTIVES_TL SUBB, AMV_I_PERSPECTIVES_TL SUBT
    where SUBB.PERSPECTIVE_ID = SUBT.PERSPECTIVE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PERSPECTIVE_NAME <> SUBT.PERSPECTIVE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMV_I_PERSPECTIVES_TL (
    PERSPECTIVE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    PERSPECTIVE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PERSPECTIVE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PERSPECTIVE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMV_I_PERSPECTIVES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMV_I_PERSPECTIVES_TL T
    where T.PERSPECTIVE_ID = B.PERSPECTIVE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMV_I_PERSPECTIVES_PKG;

/
