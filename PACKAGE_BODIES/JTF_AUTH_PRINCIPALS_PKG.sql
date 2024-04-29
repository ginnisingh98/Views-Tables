--------------------------------------------------------
--  DDL for Package Body JTF_AUTH_PRINCIPALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AUTH_PRINCIPALS_PKG" as
/* $Header: JTFSEPRB.pls 120.2 2005/10/25 05:02:00 psanyal ship $ */
procedure INSERT_ROW (
  X_JTF_AUTH_PRINCIPAL_ID in NUMBER,
  X_PRINCIPAL_DESC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PRINCIPAL_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_IS_USER_FLAG in NUMBER,
  X_DAC_ROLE_FLAG in NUMBER,
  X_PRINCIPAL_DESC in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_AUTH_PRINCIPALS_B
    where JTF_AUTH_PRINCIPAL_ID = X_JTF_AUTH_PRINCIPAL_ID
    ;
begin
  insert into JTF_AUTH_PRINCIPALS_B (
    JTF_AUTH_PRINCIPAL_ID,
    OBJECT_VERSION_NUMBER,
    PRINCIPAL_NAME,
    APPLICATION_ID,
    USER_ID,
    PRINCIPAL_DESC_ID,
    IS_USER_FLAG,
    DAC_ROLE_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_JTF_AUTH_PRINCIPAL_ID,
    X_OBJECT_VERSION_NUMBER,
    X_PRINCIPAL_NAME,
    X_APPLICATION_ID,
    X_USER_ID,
    X_PRINCIPAL_DESC_ID,
    X_IS_USER_FLAG,
    X_DAC_ROLE_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_AUTH_PRINCIPALS_TL (
    PRINCIPAL_DESC_ID,
    PRINCIPAL_DESC,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_JTF_AUTH_PRINCIPAL_ID,
    X_PRINCIPAL_DESC,
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
    from JTF_AUTH_PRINCIPALS_TL T
    where T.PRINCIPAL_DESC_ID = X_JTF_AUTH_PRINCIPAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_JTF_AUTH_PRINCIPAL_ID in NUMBER,
  X_PRINCIPAL_DESC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PRINCIPAL_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_IS_USER_FLAG in NUMBER,
  X_DAC_ROLE_FLAG in NUMBER,
  X_PRINCIPAL_DESC in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PRINCIPAL_DESC_ID,
      OBJECT_VERSION_NUMBER,
      PRINCIPAL_NAME,
      APPLICATION_ID,
      USER_ID,
      IS_USER_FLAG,
      DAC_ROLE_FLAG
    from JTF_AUTH_PRINCIPALS_B
    where JTF_AUTH_PRINCIPAL_ID = X_JTF_AUTH_PRINCIPAL_ID
    for update of JTF_AUTH_PRINCIPAL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PRINCIPAL_DESC,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_AUTH_PRINCIPALS_TL
    where PRINCIPAL_DESC_ID = X_JTF_AUTH_PRINCIPAL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PRINCIPAL_DESC_ID nowait;
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
       ((recinfo.PRINCIPAL_DESC_ID = X_PRINCIPAL_DESC_ID)
	   OR ((recinfo.PRINCIPAL_DESC_ID is null) AND (X_PRINCIPAL_DESC_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.PRINCIPAL_NAME = X_PRINCIPAL_NAME)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND ((recinfo.USER_ID = X_USER_ID)
           OR ((recinfo.USER_ID is null) AND (X_USER_ID is null)))
      AND (recinfo.IS_USER_FLAG = X_IS_USER_FLAG)
      AND ((recinfo.DAC_ROLE_FLAG = X_DAC_ROLE_FLAG)
           OR ((recinfo.DAC_ROLE_FLAG is null) AND (X_DAC_ROLE_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.PRINCIPAL_DESC = X_PRINCIPAL_DESC)
               OR ((tlinfo.PRINCIPAL_DESC is null) AND (X_PRINCIPAL_DESC is null)))
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
  X_JTF_AUTH_PRINCIPAL_ID in NUMBER,
  X_PRINCIPAL_DESC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PRINCIPAL_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_IS_USER_FLAG in NUMBER,
  X_DAC_ROLE_FLAG in NUMBER,
  X_PRINCIPAL_DESC in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_AUTH_PRINCIPALS_B set
    PRINCIPAL_DESC_ID = X_PRINCIPAL_DESC_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    PRINCIPAL_NAME = X_PRINCIPAL_NAME,
    APPLICATION_ID = X_APPLICATION_ID,
    USER_ID = X_USER_ID,
    IS_USER_FLAG = X_IS_USER_FLAG,
    DAC_ROLE_FLAG = X_DAC_ROLE_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where JTF_AUTH_PRINCIPAL_ID = X_JTF_AUTH_PRINCIPAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_AUTH_PRINCIPALS_TL set
    PRINCIPAL_DESC = X_PRINCIPAL_DESC,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PRINCIPAL_DESC_ID = X_JTF_AUTH_PRINCIPAL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_JTF_AUTH_PRINCIPAL_ID in NUMBER
) is
begin

  NULL;

end DELETE_ROW;

PROCEDURE delete_row (
  p_principal_name IN VARCHAR2,
  p_is_user_flag IN VARCHAR2,
  x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

  l_if_referred_flag VARCHAR2(1);
  l_return_status VARCHAR2(255);
  l_is_role_flag VARCHAR(1);

 BEGIN

  IF (p_is_user_flag = 'N') THEN
    jtf_um_role_verification.is_auth_principal_referred(
	  auth_principal_name => p_principal_name,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
	  x_msg_data => x_msg_data);

    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      DELETE
      FROM JTF_AUTH_PRINCIPALS_B
      WHERE PRINCIPAL_NAME = p_principal_name
	  AND IS_USER_FLAG = 0;
    END IF;
  ELSE
    DELETE
    FROM JTF_AUTH_PRINCIPALS_B
    WHERE PRINCIPAL_NAME = p_principal_name
	AND IS_USER_FLAG = 1;
    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END IF;

END delete_row;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_AUTH_PRINCIPALS_TL T
  where not exists
    (select NULL
    from JTF_AUTH_PRINCIPALS_B B
    where B.JTF_AUTH_PRINCIPAL_ID = T.PRINCIPAL_DESC_ID
    );

  update JTF_AUTH_PRINCIPALS_TL T set (
      PRINCIPAL_DESC,
      DESCRIPTION
    ) = (select
      B.PRINCIPAL_DESC,
      B.DESCRIPTION
    from JTF_AUTH_PRINCIPALS_TL B
    where B.PRINCIPAL_DESC_ID = T.PRINCIPAL_DESC_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PRINCIPAL_DESC_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PRINCIPAL_DESC_ID,
      SUBT.LANGUAGE
    from JTF_AUTH_PRINCIPALS_TL SUBB, JTF_AUTH_PRINCIPALS_TL SUBT
    where SUBB.PRINCIPAL_DESC_ID = SUBT.PRINCIPAL_DESC_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PRINCIPAL_DESC <> SUBT.PRINCIPAL_DESC
      or (SUBB.PRINCIPAL_DESC is null and SUBT.PRINCIPAL_DESC is not null)
      or (SUBB.PRINCIPAL_DESC is not null and SUBT.PRINCIPAL_DESC is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into JTF_AUTH_PRINCIPALS_TL (
    PRINCIPAL_DESC_ID,
    PRINCIPAL_DESC,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PRINCIPAL_DESC_ID,
    B.PRINCIPAL_DESC,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_AUTH_PRINCIPALS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_AUTH_PRINCIPALS_TL T
    where T.PRINCIPAL_DESC_ID = B.PRINCIPAL_DESC_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- NEW DEVELOPER ADDED PROCEDURES

procedure TRANSLATE_ROW (
  X_JTF_AUTH_PRINCIPAL_ID in NUMBER, -- key field
  X_PRINCIPAL_DESC in VARCHAR2, -- translated field
  X_DESCRIPTION in VARCHAR2, -- translated field
  X_OWNER in VARCHAR2 -- owner fields
) is

begin
        update JTF_AUTH_PRINCIPALS_TL set
            PRINCIPAL_DESC      = x_PRINCIPAL_DESC,
            DESCRIPTION         = x_DESCRIPTION,
            LAST_UPDATE_DATE    = sysdate,
            LAST_UPDATED_BY     = decode(x_owner, 'SEED', 1, 0),
            LAST_UPDATE_LOGIN   = 0,
            SOURCE_LANG         = userenv('LANG')
        where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
          and PRINCIPAL_DESC_ID = X_JTF_AUTH_PRINCIPAL_ID;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_JTF_AUTH_PRINCIPAL_ID in NUMBER, -- key fields
  X_PRINCIPAL_DESC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER, -- data fields
  X_PRINCIPAL_NAME in VARCHAR2, -- data fields
  X_APPLICATION_ID in NUMBER, -- data fields
  X_USER_ID in NUMBER, -- data fields
  X_IS_USER_FLAG in NUMBER, -- data fields
  X_DAC_ROLE_FLAG in NUMBER, -- data fields
  X_PRINCIPAL_DESC in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2 -- owner fields
) is

l_rowid  VARCHAR2(64);
l_user_id NUMBER := 0;

begin
        if(x_owner = 'SEED') then
                l_user_id := 1;
        end if;

      -- Update row if present
      JTF_AUTH_PRINCIPALS_PKG.UPDATE_ROW (
        X_JTF_AUTH_PRINCIPAL_ID => X_JTF_AUTH_PRINCIPAL_ID,
        X_PRINCIPAL_DESC_ID     => X_PRINCIPAL_DESC_ID,
        X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
        X_PRINCIPAL_NAME	=> X_PRINCIPAL_NAME,
	X_APPLICATION_ID	=> X_APPLICATION_ID,
	X_USER_ID		=> X_USER_ID,
	X_IS_USER_FLAG		=> X_IS_USER_FLAG,
	X_DAC_ROLE_FLAG		=> X_DAC_ROLE_FLAG,
	X_PRINCIPAL_DESC	=> X_PRINCIPAL_DESC,
	X_DESCRIPTION		=> X_DESCRIPTION,
        X_LAST_UPDATE_DATE      => sysdate,
        X_LAST_UPDATED_BY       => l_user_id,
        X_LAST_UPDATE_LOGIN     => 0 );
   exception
   when NO_DATA_FOUND then
      -- Insert a row
      JTF_AUTH_PRINCIPALS_PKG.INSERT_ROW (
--      X_ROWID                 => l_rowid,
        X_JTF_AUTH_PRINCIPAL_ID => X_JTF_AUTH_PRINCIPAL_ID,
        X_PRINCIPAL_DESC_ID     => X_PRINCIPAL_DESC_ID,
        X_OBJECT_VERSION_NUMBER	=> X_OBJECT_VERSION_NUMBER,
        X_PRINCIPAL_NAME	=> X_PRINCIPAL_NAME,
	X_APPLICATION_ID	=> X_APPLICATION_ID,
	X_USER_ID		=> X_USER_ID,
	X_IS_USER_FLAG		=> X_IS_USER_FLAG,
	X_DAC_ROLE_FLAG		=> X_DAC_ROLE_FLAG,
	X_PRINCIPAL_DESC	=> X_PRINCIPAL_DESC,
	X_DESCRIPTION		=> X_DESCRIPTION,
        X_CREATION_DATE         => sysdate,
        X_CREATED_BY            => l_user_id,
        X_LAST_UPDATE_DATE      => sysdate,
        X_LAST_UPDATED_BY       => l_user_id,
        X_LAST_UPDATE_LOGIN     => 0 );

end LOAD_ROW;

end JTF_AUTH_PRINCIPALS_PKG;

/
