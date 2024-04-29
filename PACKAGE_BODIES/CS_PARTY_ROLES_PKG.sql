--------------------------------------------------------
--  DDL for Package Body CS_PARTY_ROLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_PARTY_ROLES_PKG" as
/* $Header: csxptyrb.pls 120.0 2005/08/18 19:25 aneemuch noship $ */
procedure INSERT_ROW (
  PX_PARTY_ROLE_CODE in out NOCOPY VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_SEEDED_FLAG in VARCHAR2,
  P_SORT_ORDER     in NUMBER,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
 l_object_version_number NUMBER := 1;
begin
  insert into CS_PARTY_ROLES_B (
    PARTY_ROLE_CODE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    SEEDED_FLAG,
    SORT_ORDER,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    PX_PARTY_ROLE_CODE,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_SEEDED_FLAG,
    P_SORT_ORDER,
    l_object_version_number,
    Decode(P_CREATION_DATE,NULL,SYSDATE,P_CREATION_DATE),
    P_CREATED_BY,
    Decode(P_LAST_UPDATE_DATE,NULL,SYSDATE,P_LAST_UPDATE_DATE),
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  insert into CS_PARTY_ROLES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PARTY_ROLE_CODE,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    PX_PARTY_ROLE_CODE,
    P_NAME,
    P_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_PARTY_ROLES_TL T
    where T.PARTY_ROLE_CODE = PX_PARTY_ROLE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

 x_object_version_number := l_object_version_number;
end INSERT_ROW;

procedure UPDATE_ROW (
  P_PARTY_ROLE_CODE in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_SEEDED_FLAG in VARCHAR2,
  P_SORT_ORDER  in NUMBER  ,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER
) is
	l_object_Version_number number;
begin
  update CS_PARTY_ROLES_B set
    START_DATE_ACTIVE = P_START_DATE_ACTIVE,
    END_DATE_ACTIVE = P_END_DATE_ACTIVE,
    SEEDED_FLAG = P_SEEDED_FLAG,
    SORT_ORDER = P_SORT_ORDER,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where PARTY_ROLE_CODE = P_PARTY_ROLE_CODE
  RETURNING OBJECT_VERSION_NUMBER INTO L_OBJECT_VERSION_NUMBER;

  X_OBJECT_VERSION_NUMBER := l_object_version_number;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_PARTY_ROLES_TL set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PARTY_ROLE_CODE = P_PARTY_ROLE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_PARTY_ROLE_CODE in VARCHAR2
) is
begin
  delete from CS_PARTY_ROLES_TL
  where PARTY_ROLE_CODE = P_PARTY_ROLE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_PARTY_ROLES_B
  where PARTY_ROLE_CODE = P_PARTY_ROLE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_PARTY_ROLES_TL T
  where not exists
    (select NULL
    from CS_PARTY_ROLES_B B
    where B.PARTY_ROLE_CODE = T.PARTY_ROLE_CODE
    );

  update CS_PARTY_ROLES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_PARTY_ROLES_TL B
    where B.PARTY_ROLE_CODE = T.PARTY_ROLE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARTY_ROLE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.PARTY_ROLE_CODE,
      SUBT.LANGUAGE
    from CS_PARTY_ROLES_TL SUBB, CS_PARTY_ROLES_TL SUBT
    where SUBB.PARTY_ROLE_CODE = SUBT.PARTY_ROLE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_PARTY_ROLES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PARTY_ROLE_CODE,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PARTY_ROLE_CODE,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_PARTY_ROLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_PARTY_ROLES_TL T
    where T.PARTY_ROLE_CODE = B.PARTY_ROLE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
  P_PARTY_ROLE_CODE            IN VARCHAR2,
  P_START_DATE_ACTIVE          IN VARCHAR2,
  P_END_DATE_ACTIVE            IN VARCHAR2,
  P_SEEDED_FLAG                IN VARCHAR2,
  P_SORT_ORDER                 IN VARCHAR2,
  P_NAME                       IN VARCHAR2,
  P_DESCRIPTION                IN VARCHAR2,
  P_OWNER                      IN VARCHAR2,
  P_CREATION_DATE              IN VARCHAR2,
  P_CREATED_BY                 IN NUMBER,
  P_LAST_UPDATE_DATE           IN VARCHAR2,
  P_LAST_UPDATED_BY            IN NUMBER,
  P_LAST_UPDATE_LOGIN          IN NUMBER,
  P_OBJECT_VERSION_NUMBER      IN NUMBER )

IS

 -- Out local variables for the update / insert row procedures.
   lx_object_version_number  NUMBER := 0;
   l_user_id                 NUMBER := 0;

   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_PARTY_ROLE_CODE              VARCHAR2(30);

BEGIN

   if ( p_owner = 'SEED' ) then
         l_user_id := 1;
   end if;

   l_PARTY_ROLE_CODE := p_PARTY_ROLE_CODE;

   UPDATE_ROW (
       P_PARTY_ROLE_CODE                 =>l_PARTY_ROLE_CODE,
       P_START_DATE_ACTIVE          =>to_date(p_start_date_active,'DD-MM-YYYY'),
       P_END_DATE_ACTIVE            =>to_date(p_end_date_active,'DD-MM-YYYY'),
       P_SEEDED_FLAG                =>p_seeded_flag,
       P_SORT_ORDER                 =>p_sort_order    ,
       P_NAME                       =>p_name,
       P_DESCRIPTION                =>p_description,
       P_LAST_UPDATE_DATE           =>nvl(to_date(p_last_update_date,
                                                 'DD-MM-YYYY'),sysdate),
       P_LAST_UPDATED_BY            =>l_user_id,
       P_LAST_UPDATE_LOGIN          =>0,
       X_OBJECT_VERSION_NUMBER      =>lx_object_version_number
   );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
        PX_PARTY_ROLE_CODE               =>l_PARTY_ROLE_CODE,
        P_START_DATE_ACTIVE         =>to_date(p_start_date_active,'DD-MM-YYYY'),
        P_END_DATE_ACTIVE           =>to_date(p_end_date_active,'DD-MM-YYYY'),
        P_SEEDED_FLAG               =>p_seeded_flag,
        P_SORT_ORDER                =>p_sort_order ,
        P_NAME                      =>p_name,
        P_DESCRIPTION               =>p_description,
        P_CREATION_DATE             =>nvl(to_date( p_creation_date,
                                                  'DD-MM-YYYY'),sysdate),
        P_CREATED_BY                =>l_user_id,
        P_LAST_UPDATE_DATE          =>nvl(to_date( p_last_update_date,
                                                  'DD-MM-YYYY'),sysdate),
        P_LAST_UPDATED_BY           =>l_user_id,
        P_LAST_UPDATE_LOGIN         =>0,
        X_OBJECT_VERSION_NUMBER     =>lx_object_version_number
       );

END LOAD_ROW;

procedure TRANSLATE_ROW ( X_PARTY_ROLE_CODE  in  varchar2,
                          X_NAME in varchar2,
                          X_DESCRIPTION  in varchar2,
                          X_LAST_UPDATE_DATE in date,
                          X_LAST_UPDATE_LOGIN in number,
                          X_OWNER in varchar2)
is

l_user_id  number;

begin

if X_OWNER = 'SEED' then
  l_user_id := 1;
else
  l_user_id := 0;
end if;

update CS_PARTY_ROLES_TL set
 name = nvl(x_name,name),
 description = nvl(x_description,name),
 last_update_date = nvl(x_last_update_date,sysdate),
 last_updated_by = l_user_id,
 last_update_login = 0,
 source_lang = userenv('LANG')
 where PARTY_ROLE_CODE = x_PARTY_ROLE_CODE
 and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;

end CS_PARTY_ROLES_PKG;

/
