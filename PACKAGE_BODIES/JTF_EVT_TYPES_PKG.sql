--------------------------------------------------------
--  DDL for Package Body JTF_EVT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EVT_TYPES_PKG" as
/* $Header: JTFEVTTB.pls 115.1 2002/02/14 05:44:08 appldev ship $ */
procedure INSERT_ROW (
  X_JTF_EVT_TYPES_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_JTF_EVT_TYPES_NAME in VARCHAR2,
  X_JTF_EVT_TYPES_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_EVT_TYPES_B
    where JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID
    ;
begin
  insert into JTF_EVT_TYPES_B (
    SECURITY_GROUP_ID,
    JTF_EVT_TYPES_ID,
    JTF_EVT_TYPES_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SECURITY_GROUP_ID,
    X_JTF_EVT_TYPES_ID,
    X_JTF_EVT_TYPES_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_EVT_TYPES_TL (
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    CREATED_BY,
    JTF_EVT_TYPES_ID,
    JTF_EVT_TYPES_DESC,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    X_CREATED_BY,
    X_JTF_EVT_TYPES_ID,
    X_JTF_EVT_TYPES_DESC,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_EVT_TYPES_TL T
    where T.JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  --fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_JTF_EVT_TYPES_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_JTF_EVT_TYPES_NAME in VARCHAR2,
  X_JTF_EVT_TYPES_DESC in VARCHAR2
) is
  cursor c is select
      SECURITY_GROUP_ID,
      JTF_EVT_TYPES_NAME
    from JTF_EVT_TYPES_B
    where JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID
    for update of JTF_EVT_TYPES_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      JTF_EVT_TYPES_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_EVT_TYPES_TL
    where JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of JTF_EVT_TYPES_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.JTF_EVT_TYPES_NAME = X_JTF_EVT_TYPES_NAME)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.JTF_EVT_TYPES_DESC = X_JTF_EVT_TYPES_DESC)
               OR ((tlinfo.JTF_EVT_TYPES_DESC is null) AND (X_JTF_EVT_TYPES_DESC is null)))
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
  X_JTF_EVT_TYPES_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_JTF_EVT_TYPES_NAME in VARCHAR2,
  X_JTF_EVT_TYPES_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_EVT_TYPES_B set
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    JTF_EVT_TYPES_NAME = X_JTF_EVT_TYPES_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_EVT_TYPES_TL set
    JTF_EVT_TYPES_DESC = X_JTF_EVT_TYPES_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_JTF_EVT_TYPES_ID in NUMBER
) is
begin
  delete from JTF_EVT_TYPES_TL
  where JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_EVT_TYPES_B
  where JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_EVT_TYPES_TL T
  where not exists
    (select NULL
    from JTF_EVT_TYPES_B B
    where B.JTF_EVT_TYPES_ID = T.JTF_EVT_TYPES_ID
    );

  update JTF_EVT_TYPES_TL T set (
      JTF_EVT_TYPES_DESC
    ) = (select
      B.JTF_EVT_TYPES_DESC
    from JTF_EVT_TYPES_TL B
    where B.JTF_EVT_TYPES_ID = T.JTF_EVT_TYPES_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.JTF_EVT_TYPES_ID,
      T.LANGUAGE
  ) in (select
      SUBT.JTF_EVT_TYPES_ID,
      SUBT.LANGUAGE
    from JTF_EVT_TYPES_TL SUBB, JTF_EVT_TYPES_TL SUBT
    where SUBB.JTF_EVT_TYPES_ID = SUBT.JTF_EVT_TYPES_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.JTF_EVT_TYPES_DESC <> SUBT.JTF_EVT_TYPES_DESC
      or (SUBB.JTF_EVT_TYPES_DESC is null and SUBT.JTF_EVT_TYPES_DESC is not null)
      or (SUBB.JTF_EVT_TYPES_DESC is not null and SUBT.JTF_EVT_TYPES_DESC is null)
  ));

  insert into JTF_EVT_TYPES_TL (
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    CREATED_BY,
    JTF_EVT_TYPES_ID,
    JTF_EVT_TYPES_DESC,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.CREATED_BY,
    B.JTF_EVT_TYPES_ID,
    B.JTF_EVT_TYPES_DESC,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_EVT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_EVT_TYPES_TL T
    where T.JTF_EVT_TYPES_ID = B.JTF_EVT_TYPES_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_JTF_EVT_TYPES_ID in NUMBER, -- key field
  X_JTF_EVT_TYPES_DESC in VARCHAR2, -- translated field
  X_OWNER in VARCHAR2 -- owner field
) is

begin
        update JTF_EVT_TYPES_TL set
            JTF_EVT_TYPES_DESC 	= x_JTF_EVT_TYPES_DESC,
            LAST_UPDATE_DATE 	= sysdate,
            LAST_UPDATED_BY 	= decode(x_owner, 'SEED', 1, 0),
            LAST_UPDATE_LOGIN 	= 0,
            SOURCE_LANG 	= userenv('LANG')
        where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
          and JTF_EVT_TYPES_ID = X_JTF_EVT_TYPES_ID;

end TRANSLATE_ROW;


procedure LOAD_ROW (
  X_JTF_EVT_TYPES_ID in NUMBER,	-- key fields
  X_SECURITY_GROUP_ID in NUMBER,
  X_JTF_EVT_TYPES_NAME in VARCHAR2, -- data fields
  X_JTF_EVT_TYPES_DESC in VARCHAR2,
  X_OWNER in VARCHAR2 -- owner field
) is

l_rowid  VARCHAR2(64);
l_user_id NUMBER := 0;

begin
	if(x_owner = 'SEED') then
		l_user_id := 1;
	end if;

      -- Update row if present
      JTF_EVT_TYPES_PKG.UPDATE_ROW (
  	X_JTF_EVT_TYPES_ID 		=> X_JTF_EVT_TYPES_ID,
	X_SECURITY_GROUP_ID     	=> X_SECURITY_GROUP_ID,
  	X_JTF_EVT_TYPES_NAME 	=> X_JTF_EVT_TYPES_NAME,
  	X_JTF_EVT_TYPES_DESC 	=> X_JTF_EVT_TYPES_DESC,
  	X_LAST_UPDATE_DATE 	=> sysdate,
  	X_LAST_UPDATED_BY 	=> l_user_id,
  	X_LAST_UPDATE_LOGIN 	=> 0 );
   exception
   when NO_DATA_FOUND then
      -- Insert a row
      JTF_EVT_TYPES_PKG.INSERT_ROW (
  	X_JTF_EVT_TYPES_ID 		=> X_JTF_EVT_TYPES_ID,
	X_SECURITY_GROUP_ID     	=> X_SECURITY_GROUP_ID,
  	X_JTF_EVT_TYPES_NAME 	=> X_JTF_EVT_TYPES_NAME,
  	X_JTF_EVT_TYPES_DESC 	=> X_JTF_EVT_TYPES_DESC,
  	X_CREATION_DATE 		=> sysdate,
  	X_CREATED_BY 		=> l_user_id,
  	X_LAST_UPDATE_DATE 	=> sysdate,
  	X_LAST_UPDATED_BY 	=> l_user_id,
  	X_LAST_UPDATE_LOGIN 	=> 0 );

end LOAD_ROW;

end JTF_EVT_TYPES_PKG;

/
