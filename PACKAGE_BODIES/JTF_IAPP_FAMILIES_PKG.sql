--------------------------------------------------------
--  DDL for Package Body JTF_IAPP_FAMILIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IAPP_FAMILIES_PKG" as
/* $Header: jtfiappb.pls 120.2 2005/10/25 05:20:37 psanyal ship $ */

G_LOGIN_ID	NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID	NUMBER := FND_GLOBAL.USER_ID;

procedure INSERT_ROW (
  X_APP_FAMILY_ID IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
  X_APP_FAMILY_ACCESS_NAME IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_APP_FAMILY_DISPLAY_NAME in VARCHAR2,
  X_APP_FAMILY_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
  cursor C is select APP_FAMILY_ID from JTF_IAPP_FAMILIES_B
    where APP_FAMILY_ID = X_APP_FAMILY_ID
    ;

  cursor C_2 is
    select JTF_IAPP_FAMILIES_B_S.nextval from SYS.DUAL
    ;

   l_app_family_id NUMBER :=	NULL;
   l_last_updated_by NUMBER := G_USER_ID;

begin

   If (X_APP_FAMILY_ID IS NULL) then
       OPEN C_2;
       FETCH C_2 INTO X_APP_FAMILY_ID;
       CLOSE C_2;
   End If;

   if (X_APP_FAMILY_ACCESS_NAME IS NULL) then
   	X_APP_FAMILY_ACCESS_NAME := 'JTFFAM' || to_char(X_APP_FAMILY_ID);
   end if;

   -- check if this is from a seed upload
   if (X_OWNER = 'SEED') then
   	l_last_updated_by := 1;
   else
   	l_last_updated_by := G_USER_ID;
   end if;

  insert into JTF_IAPP_FAMILIES_B (
    APP_FAMILY_ID,
    APP_FAMILY_ACCESS_NAME,
    DISPLAY_SEQUENCE,
    ENABLED_FLAG,
    DELETED_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APP_FAMILY_ID,
    X_APP_FAMILY_ACCESS_NAME,
    X_DISPLAY_SEQUENCE,
    X_ENABLED_FLAG,
    'N',
    0,
    SYSDATE,
    G_USER_ID,
    SYSDATE,
    l_last_updated_by,
    G_LOGIN_ID
  );

  insert into JTF_IAPP_FAMILIES_TL (
    APP_FAMILY_ID,
    APP_FAMILY_DISPLAY_NAME,
    APP_FAMILY_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APP_FAMILY_ID,
    X_APP_FAMILY_DISPLAY_NAME,
    X_APP_FAMILY_DESCRIPTION,
    G_USER_ID,
    SYSDATE,
    SYSDATE,
    l_last_updated_by,
    G_LOGIN_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_IAPP_FAMILIES_TL T
    where T.APP_FAMILY_ID = X_APP_FAMILY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into l_app_family_id;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_APP_FAMILY_ID in NUMBER,
  X_APP_FAMILY_ACCESS_NAME in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APP_FAMILY_DISPLAY_NAME in VARCHAR2,
  X_APP_FAMILY_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is

   l_last_updated_by NUMBER := G_USER_ID;

begin
  update JTF_IAPP_FAMILIES_B set
    APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME,
    DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = G_USER_ID,
    LAST_UPDATE_LOGIN = G_LOGIN_ID
  where APP_FAMILY_ID = X_APP_FAMILY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

   -- check if this is from a seed upload
   if (X_OWNER = 'SEED') then
   	l_last_updated_by := 1;
   else
   	l_last_updated_by := G_USER_ID;
   end if;

  update JTF_IAPP_FAMILIES_TL set
    APP_FAMILY_DISPLAY_NAME = X_APP_FAMILY_DISPLAY_NAME,
    APP_FAMILY_DESCRIPTION = X_APP_FAMILY_DESCRIPTION,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = l_last_updated_by,
    LAST_UPDATE_LOGIN = G_LOGIN_ID,
    SOURCE_LANG = userenv('LANG')
  where APP_FAMILY_ID = X_APP_FAMILY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APP_FAMILY_ID in NUMBER
) is
begin
  delete from JTF_IAPP_FAMILIES_TL
  where APP_FAMILY_ID = X_APP_FAMILY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_IAPP_FAMILIES_B
  where APP_FAMILY_ID = X_APP_FAMILY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

-- ALL APP to FAMILY related procedures

procedure ADD_APP_TO_FAMILY (
  X_APP_FAMILY_ACCESS_NAME in VARCHAR2,
  X_APP_ID in NUMBER
) is

  cursor C is select APP_FAMILY_ID from JTF_IAPP_FAMILIES_B
    where APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME
    ;

  cursor C_2 is select f.APP_FAMILY_ID, APPLICATION_ID
  		from JTF_IAPP_FAMILIES_B f, JTF_IAPP_FAMILY_APP_MAP a
    		where f.APP_FAMILY_ID = a.APP_FAMILY_ID
    		AND f.APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME
    		AND a.APPLICATION_ID = X_APP_ID
    ;

   l_app_family_id NUMBER := NULL;
   l_app_id NUMBER := NULL;

begin

   If (X_APP_FAMILY_ACCESS_NAME IS NOT NULL AND X_APP_ID IS NOT NULL ) then

       OPEN C_2;
       FETCH C_2 INTO l_app_family_id, l_app_id;

     if (C_2%notfound) then

      If (X_APP_FAMILY_ACCESS_NAME IS NOT NULL) then
          OPEN C;
          FETCH C INTO l_app_family_id;
          CLOSE C;
      End If;

       insert into JTF_IAPP_FAMILY_APP_MAP (
        APP_FAMILY_ID,
        APPLICATION_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
       ) values (
         l_app_family_id,
         X_APP_ID,
         G_USER_ID,
         SYSDATE,
         SYSDATE,
         G_USER_ID,
         G_LOGIN_ID
       );

     end if;

   CLOSE C_2;
  End If;

end ADD_APP_TO_FAMILY;

procedure DELETE_ALL_APPS_IN_FAMILY (
  X_APP_FAMILY_ACCESS_NAME in VARCHAR2
) is

  cursor C is select APP_FAMILY_ID from JTF_IAPP_FAMILIES_B
    where APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME
    ;

   l_app_family_id NUMBER := NULL;
begin

   If (X_APP_FAMILY_ACCESS_NAME IS NOT NULL) then
       OPEN C;
       FETCH C INTO l_app_family_id;
       CLOSE C;
   End If;

  delete from JTF_IAPP_FAMILY_APP_MAP
  where APP_FAMILY_ID = l_app_family_id;

--  if (sql%notfound) then
--    raise no_data_found;
--  end if;

end DELETE_ALL_APPS_IN_FAMILY;


procedure DELETE_FAMILY_AND_APPS (
  X_APP_FAMILY_ACCESS_NAME in VARCHAR2
) is

begin

   jtf_iapp_families_pkg.DELETE_ALL_APPS_IN_FAMILY (X_APP_FAMILY_ACCESS_NAME => X_APP_FAMILY_ACCESS_NAME);

   update JTF_IAPP_FAMILIES_B set DELETED_FLAG = 'Y' where APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_FAMILY_AND_APPS;


procedure DELETE_APP_IN_FAMILY (
  X_APP_FAMILY_ACCESS_NAME in VARCHAR2,
  X_APP_ID in NUMBER
) is

  cursor C is select APP_FAMILY_ID from JTF_IAPP_FAMILIES_B
    where APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME
    ;

   l_app_family_id NUMBER := NULL;
begin

   If (X_APP_FAMILY_ACCESS_NAME IS NOT NULL) then
       OPEN C;
       FETCH C INTO l_app_family_id;
       CLOSE C;
   End If;

  delete from JTF_IAPP_FAMILY_APP_MAP
  where APP_FAMILY_ID = l_app_family_id
  	AND APPLICATION_ID = X_APP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


end DELETE_APP_IN_FAMILY;

procedure ADD_USER_DEF_RESP (
  X_APP_FAMILY_ACCESS_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_DEFAULT_RESP_ID in NUMBER
) is

  cursor C is select APP_FAMILY_ID from JTF_IAPP_FAMILIES_B
    where APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME
    ;

  cursor C_2 is select f.APP_FAMILY_ID, USER_ID
  		from JTF_IAPP_FAMILIES_B f, JTF_IAPP_FAMILY_USR_MAP u
    		where f.APP_FAMILY_ID = u.APP_FAMILY_ID
    		AND f.APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME
    		AND u.USER_ID = X_USER_ID
    ;

   l_app_family_id NUMBER := NULL;
   l_user_id NUMBER := NULL;

begin

   If (X_APP_FAMILY_ACCESS_NAME IS NOT NULL
   	AND X_USER_ID IS NOT NULL ) then
       OPEN C_2;
       FETCH C_2 INTO l_app_family_id, l_user_id;

        If (X_APP_FAMILY_ACCESS_NAME IS NOT NULL) then
            OPEN C;
            FETCH C INTO l_app_family_id;
            CLOSE C;
        End If;

       if (C_2%notfound) then
         insert into JTF_IAPP_FAMILY_USR_MAP (
          APP_FAMILY_ID,
          USER_ID,
          DEFAULT_RESP_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN
         ) values (
           l_app_family_id,
           X_USER_ID,
           X_DEFAULT_RESP_ID,
           G_USER_ID,
           SYSDATE,
           SYSDATE,
           G_USER_ID,
           G_LOGIN_ID
         );
       else

        update JTF_IAPP_FAMILY_USR_MAP set
         DEFAULT_RESP_ID = X_DEFAULT_RESP_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = G_USER_ID,
         LAST_UPDATE_LOGIN = G_LOGIN_ID
        where APP_FAMILY_ID = l_app_family_id
        	AND USER_ID = X_USER_ID;

         if (sql%notfound) then
           raise no_data_found;
         end if;

      end if;

   CLOSE C_2;

  End If;

end ADD_USER_DEF_RESP;

procedure DELETE_USER_DEF_RESP (
  X_APP_FAMILY_ACCESS_NAME in VARCHAR2,
  X_USER_ID in NUMBER
) is

  cursor C is select APP_FAMILY_ID from JTF_IAPP_FAMILIES_B
    where APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME
    ;

   l_app_family_id NUMBER := NULL;

begin

   If (X_APP_FAMILY_ACCESS_NAME IS NOT NULL) then

     OPEN C;
     FETCH C INTO l_app_family_id;
     CLOSE C;

	delete from JTF_IAPP_FAMILY_USR_MAP
	where APP_FAMILY_ID = l_app_family_id
	AND USER_ID = X_USER_ID;

    if (sql%notfound) then
      raise no_data_found;
    end if;

   End If;

end DELETE_USER_DEF_RESP;

procedure DELETE_USER_DEF_RESP_USING_ID (
  X_APP_FAMILY_ID in NUMBER,
  X_USER_ID in NUMBER
) is

begin

   If (X_APP_FAMILY_ID IS NOT NULL AND X_USER_ID IS NOT NULL) then

	delete from JTF_IAPP_FAMILY_USR_MAP
	where APP_FAMILY_ID = X_APP_FAMILY_ID
	AND USER_ID = X_USER_ID;

    if (sql%notfound) then
      raise no_data_found;
    end if;

   End If;

end DELETE_USER_DEF_RESP_USING_ID;


procedure LOAD_ROW (
  X_APP_FAMILY_ID in NUMBER,
  X_APP_FAMILY_ACCESS_NAME in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_APP_FAMILY_DISPLAY_NAME in VARCHAR2,
  X_APP_FAMILY_DESCRIPTION in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OWNER in VARCHAR2
)is

  cursor C is select APP_FAMILY_ID from JTF_IAPP_FAMILIES_B
    where APP_FAMILY_ACCESS_NAME = X_APP_FAMILY_ACCESS_NAME
    ;
  cursor c_2 is select nvl(max(app_family_id), 0)
    from jtf_iapp_families_b where app_family_id < 10000
    ;

   l_app_family_id NUMBER := X_APP_FAMILY_ID;
   l_app_pseudo_seq NUMBER := NULL;
   l_app_family_name VARCHAR2(60) := X_APP_FAMILY_ACCESS_NAME;

begin

   OPEN C;
     FETCH C INTO l_app_family_id;
   CLOSE C;

   if(C%notfound) then

     --  generate pseudo sequence
     OPEN C_2;
       FETCH C_2 INTO l_app_pseudo_seq;
       l_app_pseudo_seq := l_app_pseudo_seq + 1;
     CLOSE C_2;

      jtf_iapp_families_pkg.INSERT_ROW (
      X_APP_FAMILY_ID => l_app_pseudo_seq,
      X_APP_FAMILY_ACCESS_NAME => l_app_family_name,
      X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
      X_ENABLED_FLAG => X_ENABLED_FLAG,
      X_APP_FAMILY_DISPLAY_NAME => X_APP_FAMILY_DISPLAY_NAME,
      X_APP_FAMILY_DESCRIPTION => X_APP_FAMILY_DESCRIPTION,
      X_OWNER => X_OWNER
      );
   else
      jtf_iapp_families_pkg.UPDATE_ROW (
      X_APP_FAMILY_ID => l_app_family_id,
      X_APP_FAMILY_ACCESS_NAME => l_app_family_name,
      X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
      X_ENABLED_FLAG => X_ENABLED_FLAG,
      X_OBJECT_VERSION_NUMBER => null,
      X_APP_FAMILY_DISPLAY_NAME => X_APP_FAMILY_DISPLAY_NAME,
      X_APP_FAMILY_DESCRIPTION => X_APP_FAMILY_DESCRIPTION,
      X_OWNER => X_OWNER
      );
   end if;

  jtf_iapp_families_pkg.ADD_APP_TO_FAMILY (
  X_APP_FAMILY_ACCESS_NAME => X_APP_FAMILY_ACCESS_NAME,
  X_APP_ID => X_APPLICATION_ID);

end LOAD_ROW;

procedure TRANSLATE_ROW (
   x_APP_FAMILY_ACCESS_NAME in VARCHAR2,
   x_APP_FAMILY_DISPLAY_NAME in VARCHAR2,
   x_APP_FAMILY_DESCRIPTION in VARCHAR2,
   x_OWNER in VARCHAR2
)is

begin
      update JTF_IAPP_FAMILIES_TL set
        APP_FAMILY_DISPLAY_NAME = x_APP_FAMILY_DISPLAY_NAME,
        APP_FAMILY_DESCRIPTION = x_APP_FAMILY_DESCRIPTION,
        LAST_UPDATE_DATE = sysdate,
        LAST_UPDATED_BY = decode(x_OWNER, 'SEED', 1, 0),
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG = userenv('LANG')
      where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      and APP_FAMILY_ID = (select APP_FAMILY_ID from JTF_IAPP_FAMILIES_B
      			where APP_FAMILY_ACCESS_NAME = x_APP_FAMILY_ACCESS_NAME);
end TRANSLATE_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from JTF_IAPP_FAMILIES_TL T
  where not exists
    (select NULL
    from JTF_IAPP_FAMILIES_B B
    where B.APP_FAMILY_ID = T.APP_FAMILY_ID
    );

  update JTF_IAPP_FAMILIES_TL T set (
      APP_FAMILY_DISPLAY_NAME,
      APP_FAMILY_DESCRIPTION
    ) = (select
      B.APP_FAMILY_DISPLAY_NAME,
      B.APP_FAMILY_DESCRIPTION
    from JTF_IAPP_FAMILIES_TL B
    where B.APP_FAMILY_ID = T.APP_FAMILY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APP_FAMILY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APP_FAMILY_ID,
      SUBT.LANGUAGE
    from JTF_IAPP_FAMILIES_TL SUBB, JTF_IAPP_FAMILIES_TL SUBT
    where SUBB.APP_FAMILY_ID = SUBT.APP_FAMILY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.APP_FAMILY_DISPLAY_NAME <> SUBT.APP_FAMILY_DISPLAY_NAME
      or SUBB.APP_FAMILY_DESCRIPTION <> SUBT.APP_FAMILY_DESCRIPTION
      or (SUBB.APP_FAMILY_DESCRIPTION is null and SUBT.APP_FAMILY_DESCRIPTION is not null)
      or (SUBB.APP_FAMILY_DESCRIPTION is not null and SUBT.APP_FAMILY_DESCRIPTION is null)
  ));

  insert into JTF_IAPP_FAMILIES_TL (
    APP_FAMILY_ID,
    APP_FAMILY_DISPLAY_NAME,
    APP_FAMILY_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APP_FAMILY_ID,
    B.APP_FAMILY_DISPLAY_NAME,
    B.APP_FAMILY_DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_IAPP_FAMILIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_IAPP_FAMILIES_TL T
    where T.APP_FAMILY_ID = B.APP_FAMILY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end JTF_IAPP_FAMILIES_PKG;

/
