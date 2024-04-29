--------------------------------------------------------
--  DDL for Package Body CS_PARTY_ROLE_GROUP_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_PARTY_ROLE_GROUP_MAPS_PKG" as
/* $Header: csptyrgb.pls 120.0 2005/08/18 19:24 aneemuch noship $ */
procedure INSERT_ROW (
  PX_PARTY_ROLE_GROUP_MAPPING_ID in out NOCOPY NUMBER,
  PX_PARTY_ROLE_GROUP_CODE in out NOCOPY VARCHAR2,
  PX_PARTY_ROLE_CODE in out NOCOPY VARCHAR2,
  P_SEEDED_FLAG in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
  l_object_Version_number number := 1;
begin
  insert into CS_PARTY_ROLE_GROUP_MAPS (
    PARTY_ROLE_GROUP_MAPPING_ID,
    PARTY_ROLE_GROUP_CODE,
    PARTY_ROLE_CODE,
    SEEDED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    PX_PARTY_ROLE_GROUP_MAPPING_ID,
    PX_PARTY_ROLE_GROUP_CODE,
    PX_PARTY_ROLE_CODE,
    P_SEEDED_FLAG,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    L_OBJECT_VERSION_NUMBER);

  x_object_version_number := l_object_version_number;

end INSERT_ROW;


procedure UPDATE_ROW (
  P_PARTY_ROLE_GROUP_MAPPING_ID in NUMBER,
  P_PARTY_ROLE_GROUP_CODE in VARCHAR2,
  P_PARTY_ROLE_CODE in VARCHAR2,
  P_SEEDED_FLAG in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
begin
  update CS_PARTY_ROLE_GROUP_MAPS set
    SEEDED_FLAG = P_SEEDED_FLAG,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    START_DATE_ACTIVE = P_START_DATE_ACTIVE,
    END_DATE_ACTIVE = P_END_DATE_ACTIVE,
    PARTY_ROLE_GROUP_CODE = P_PARTY_ROLE_GROUP_CODE,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where PARTY_ROLE_GROUP_CODE = P_PARTY_ROLE_GROUP_CODE
  and PARTY_ROLE_CODE = P_PARTY_ROLE_CODE
  and PARTY_ROLE_GROUP_MAPPING_ID = P_PARTY_ROLE_GROUP_MAPPING_ID
  RETURNING OBJECT_VERSION_NUMBER INTO X_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_PARTY_ROLE_GROUP_CODE in VARCHAR2,
  P_PARTY_ROLE_CODE in VARCHAR2
) is
begin
  delete from CS_PARTY_ROLE_GROUP_MAPS
  where PARTY_ROLE_GROUP_CODE = P_PARTY_ROLE_GROUP_CODE
  and PARTY_ROLE_CODE = P_PARTY_ROLE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE LOAD_ROW (
  P_PARTY_ROLE_GROUP_MAPPING_ID  IN NUMBER,
  P_PARTY_ROLE_GROUP_CODE        IN VARCHAR2,
  P_PARTY_ROLE_CODE              IN VARCHAR2,
  P_SEEDED_FLAG                IN VARCHAR2,
  P_START_DATE_ACTIVE          IN VARCHAR2,
  P_END_DATE_ACTIVE            IN VARCHAR2,
  P_OWNER                      IN VARCHAR2,
  P_CREATION_DATE              IN VARCHAR2,
  P_CREATED_BY                 IN NUMBER,
  P_LAST_UPDATE_DATE           IN VARCHAR2,
  P_LAST_UPDATED_BY            IN NUMBER,
  P_LAST_UPDATE_LOGIN          IN NUMBER,
  P_OBJECT_VERSION_NUMBER      IN NUMBER
)

IS
 -- Out local variables for the update / insert row procedures.
   lx_object_version_number  NUMBER := 0;
   l_user_id                 NUMBER := 0;

   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_PARTY_ROLE_CODE             VARCHAR2(30);
   l_PARTY_ROLE_GROUP_CODE       VARCHAR2(30);
   l_PARTY_ROLE_GROUP_MAPPING_ID NUMBER;

BEGIN

   if ( p_owner = 'SEED' ) then
         l_user_id := 1;
   end if;

   l_PARTY_ROLE_CODE        := p_PARTY_ROLE_CODE;
   l_PARTY_ROLE_GROUP_CODE  := p_PARTY_ROLE_GROUP_CODE;
   l_PARTY_ROLE_GROUP_MAPPING_ID  := p_PARTY_ROLE_GROUP_MAPPING_ID;

   UPDATE_ROW (
     P_PARTY_ROLE_GROUP_MAPPING_ID =>l_PARTY_ROLE_GROUP_MAPPING_ID,
     P_PARTY_ROLE_GROUP_CODE      =>l_PARTY_ROLE_GROUP_CODE,
     P_PARTY_ROLE_CODE            =>l_PARTY_ROLE_CODE,
     P_SEEDED_FLAG                =>p_seeded_flag,
     P_START_DATE_ACTIVE          =>to_date(p_start_date_active,'DD-MM-YYYY'),
     P_END_DATE_ACTIVE            =>to_date(p_end_date_active,'DD-MM-YYYY'),
     P_LAST_UPDATE_DATE           =>nvl(to_date(p_last_update_date,
                                                'DD-MM-YYYY'),sysdate),
     P_LAST_UPDATED_BY            =>l_user_id,
     P_LAST_UPDATE_LOGIN          =>0,
     X_OBJECT_VERSION_NUMBER      =>lx_object_version_number
     );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
         PX_PARTY_ROLE_GROUP_MAPPING_ID   =>l_PARTY_ROLE_GROUP_MAPPING_ID,
         PX_PARTY_ROLE_GROUP_CODE   =>l_PARTY_ROLE_GROUP_CODE,
         PX_PARTY_ROLE_CODE         =>l_PARTY_ROLE_CODE,
         P_SEEDED_FLAG            =>p_seeded_flag,
         P_START_DATE_ACTIVE      =>to_date(p_start_date_active,'DD-MM-YYYY'),
         P_END_DATE_ACTIVE        =>to_date(p_end_date_active,'DD-MM-YYYY'),
         P_CREATION_DATE          =>nvl(to_date( p_creation_date,
                                                'DD-MM-YYYY'),sysdate),
         P_CREATED_BY             =>l_user_id,
         P_LAST_UPDATE_DATE       =>nvl(to_date( p_last_update_date,
                                                'DD-MM-YYYY'),sysdate),
         P_LAST_UPDATED_BY        =>l_user_id,
         P_LAST_UPDATE_LOGIN      =>0,
         X_OBJECT_VERSION_NUMBER  =>lx_object_version_number
         );

END LOAD_ROW;

end CS_PARTY_ROLE_GROUP_MAPS_PKG;

/
