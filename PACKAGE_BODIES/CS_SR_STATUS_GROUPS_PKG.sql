--------------------------------------------------------
--  DDL for Package Body CS_SR_STATUS_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_STATUS_GROUPS_PKG" AS
/* $Header: cststgrb.pls 120.0 2006/02/28 11:53:50 spusegao noship $ */

PROCEDURE INSERT_ROW (
  X_ROWID                      in out NOCOPY VARCHAR2 ,
  X_STATUS_GROUP_ID            in NUMBER,
  X_SECURITY_GROUP_ID          in NUMBER,
  X_TRANSITION_IND             in VARCHAR2,
  X_OBJECT_VERSION_NUMBER      in NUMBER,
  X_ORIG_SYSTEM_REFERENCE_ID   in NUMBER,
  X_END_DATE                   in DATE,
  X_START_DATE                 in DATE,
  X_DEFAULT_INCIDENT_STATUS_ID in NUMBER,
  X_GROUP_NAME                 in VARCHAR2,
  X_DESCRIPTION                in VARCHAR2,
  X_LANGUAGE                   in VARCHAR2,
  X_SOURCE_LANG                in VARCHAR2,
  X_CREATION_DATE              in DATE,
  X_CREATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE           in DATE,
  X_LAST_UPDATED_BY            in NUMBER,
  X_LAST_UPDATE_LOGIN          in NUMBER)

IS
    cursor C is select ROWID from CS_SR_STATUS_GROUPS_B
    where STATUS_GROUP_ID = X_STATUS_GROUP_ID;

   cursor c1 is
   select cs_sr_status_groups_b_s.nextval
   from   dual;

   l_status_group_id NUMBER ;

BEGIN
   if ( x_status_group_id IS NULL  OR  x_status_group_id = FND_API.G_MISS_NUM ) then
      open  c1;
      fetch c1 into l_status_group_id;
      close c1;
   end if;

   INSERT INTO CS_SR_STATUS_GROUPS_B (
      STATUS_GROUP_ID,
      SECURITY_GROUP_ID,
      TRANSITION_IND,
      DEFAULT_INCIDENT_STATUS_ID,
      ORIG_SYSTEM_REFERENCE_ID,
      END_DATE,
      START_DATE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER )
   VALUES (
      NVL(X_STATUS_GROUP_ID,l_status_group_id ),
      X_SECURITY_GROUP_ID,
      X_TRANSITION_IND,
      X_DEFAULT_INCIDENT_STATUS_ID,
      X_ORIG_SYSTEM_REFERENCE_ID,
      X_END_DATE,
      X_START_DATE,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_OBJECT_VERSION_NUMBER );


   INSERT INTO CS_SR_STATUS_GROUPS_TL (
      STATUS_GROUP_ID,
      GROUP_NAME,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN )
   SELECT
      NVL(X_STATUS_GROUP_ID,l_status_group_id ),
      X_GROUP_NAME,
      X_DESCRIPTION,
      L.LANGUAGE_CODE,
      userenv('LANG'),
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN
   FROM  FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG in ('I', 'B')
   AND   NOT EXISTS ( SELECT NULL
                      FROM   CS_SR_STATUS_GROUPS_TL T
                      WHERE  T.STATUS_GROUP_ID = X_STATUS_GROUP_ID
                      AND    T.LANGUAGE        = L.LANGUAGE_CODE);

   open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;


PROCEDURE LOCK_ROW (
  X_STATUS_GROUP_ID            in NUMBER,
  X_SECURITY_GROUP_ID          in NUMBER,
  X_TRANSITION_IND             in VARCHAR2,
  X_OBJECT_VERSION_NUMBER      in NUMBER,
  X_ORIG_SYSTEM_REFERENCE_ID   in NUMBER,
  X_END_DATE                   in DATE,
  X_START_DATE                 in DATE,
  X_DEFAULT_INCIDENT_STATUS_ID in NUMBER,
  X_GROUP_NAME                 in VARCHAR2,
  X_DESCRIPTION                in VARCHAR2,
  X_LANGUAGE                   in VARCHAR2,
  X_SOURCE_LANG                in VARCHAR2
) is
  cursor c is select
      SECURITY_GROUP_ID,
      TRANSITION_IND,
      OBJECT_VERSION_NUMBER,
      ORIG_SYSTEM_REFERENCE_ID,
      END_DATE,
      START_DATE,
      DEFAULT_INCIDENT_STATUS_ID
    from CS_SR_STATUS_GROUPS_B
    where STATUS_GROUP_ID = X_STATUS_GROUP_ID
    for update of STATUS_GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      GROUP_NAME,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_SR_STATUS_GROUPS_TL
    where STATUS_GROUP_ID = X_STATUS_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STATUS_GROUP_ID nowait;
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
      AND ((recinfo.TRANSITION_IND = X_TRANSITION_IND)
           OR ((recinfo.TRANSITION_IND is null) AND (X_TRANSITION_IND is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.ORIG_SYSTEM_REFERENCE_ID = X_ORIG_SYSTEM_REFERENCE_ID)
           OR ((recinfo.ORIG_SYSTEM_REFERENCE_ID is null) AND (X_ORIG_SYSTEM_REFERENCE_ID is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.DEFAULT_INCIDENT_STATUS_ID = X_DEFAULT_INCIDENT_STATUS_ID)
           OR ((recinfo.DEFAULT_INCIDENT_STATUS_ID is null) AND (X_DEFAULT_INCIDENT_STATUS_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.GROUP_NAME = X_GROUP_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND (tlinfo.LANGUAGE = X_LANGUAGE)
          AND (tlinfo.SOURCE_LANG = X_SOURCE_LANG)
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
  X_STATUS_GROUP_ID             in NUMBER,
  X_SECURITY_GROUP_ID           in NUMBER,
  X_TRANSITION_IND              in VARCHAR2,
  X_OBJECT_VERSION_NUMBER       in NUMBER,
  X_ORIG_SYSTEM_REFERENCE_ID    in NUMBER,
  X_END_DATE                    in DATE,
  X_START_DATE                  in DATE,
  X_DEFAULT_INCIDENT_STATUS_ID  in NUMBER,
  X_GROUP_NAME                  in VARCHAR2,
  X_DESCRIPTION                 in VARCHAR2,
  X_LANGUAGE                    in VARCHAR2,
  X_SOURCE_LANG                 in VARCHAR2,
  X_LAST_UPDATE_DATE            in DATE,
  X_LAST_UPDATED_BY             in NUMBER,
  X_LAST_UPDATE_LOGIN           in NUMBER) is

begin

  UPDATE CS_SR_STATUS_GROUPS_B set
    SECURITY_GROUP_ID          = X_SECURITY_GROUP_ID,
    TRANSITION_IND             = X_TRANSITION_IND,
    OBJECT_VERSION_NUMBER      = X_OBJECT_VERSION_NUMBER,
    ORIG_SYSTEM_REFERENCE_ID   = X_ORIG_SYSTEM_REFERENCE_ID,
    END_DATE                   = X_END_DATE,
    START_DATE                 = X_START_DATE,
    DEFAULT_INCIDENT_STATUS_ID = X_DEFAULT_INCIDENT_STATUS_ID,
    LAST_UPDATE_DATE           = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY            = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN          = X_LAST_UPDATE_LOGIN
  where STATUS_GROUP_ID        = X_STATUS_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  UPDATE CS_SR_STATUS_GROUPS_TL set
    GROUP_NAME        = X_GROUP_NAME,
    DESCRIPTION       = X_DESCRIPTION,
    LAST_UPDATE_DATE  = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY   = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STATUS_GROUP_ID = X_STATUS_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
END UPDATE_ROW;


PROCEDURE DELETE_ROW (
   X_STATUS_GROUP_ID              IN  NUMBER )
IS
BEGIN

  delete from CS_SR_STATUS_GROUPS_TL
  where STATUS_GROUP_ID = X_STATUS_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_SR_STATUS_GROUPS_B
  where STATUS_GROUP_ID = X_STATUS_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN

   delete from CS_SR_STATUS_GROUPS_TL T
   where  not exists ( select NULL
                       from   CS_SR_STATUS_GROUPS_B B
                       where  B.STATUS_GROUP_ID = T.STATUS_GROUP_ID );

   update CS_SR_STATUS_GROUPS_TL T
   set ( GROUP_NAME,
         DESCRIPTION
         )                       = ( select  B.GROUP_NAME,
                                             B.DESCRIPTION
                                      from   CS_SR_STATUS_GROUPS_TL B
                                      where  B.STATUS_GROUP_ID = T.STATUS_GROUP_ID
                                      and    B.LANGUAGE        = T.SOURCE_LANG)
   where ( T.STATUS_GROUP_ID, T.LANGUAGE) in ( select SUBT.STATUS_GROUP_ID, SUBT.LANGUAGE
                                               from   CS_SR_STATUS_GROUPS_TL SUBB,
						      CS_SR_STATUS_GROUPS_TL SUBT
                                               where  SUBB.STATUS_GROUP_ID = SUBT.STATUS_GROUP_ID
                                               and    SUBB.LANGUAGE = SUBT.SOURCE_LANG
                                               and (SUBB.GROUP_NAME <> SUBT.GROUP_NAME
                                                or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                                                or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
                                                or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
                                                or SUBB.LANGUAGE <> SUBT.LANGUAGE
                                                or SUBB.SOURCE_LANG <> SUBT.SOURCE_LANG
                                              ));


   INSERT INTO CS_SR_STATUS_GROUPS_TL (
      STATUS_GROUP_ID,
      GROUP_NAME,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN )
   SELECT
      B.STATUS_GROUP_ID,
      B.GROUP_NAME,
      B.DESCRIPTION,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG,
      B.CREATION_DATE,
      B.CREATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_LOGIN
   FROM    CS_SR_STATUS_GROUPS_TL B,
	   FND_LANGUAGES L
   WHERE   L.INSTALLED_FLAG in ('I', 'B')
   AND     B.LANGUAGE = userenv('LANG')
   AND     NOT EXISTS ( select NULL
		        from   CS_SR_STATUS_GROUPS_TL T
                        where  T.STATUS_GROUP_ID = B.STATUS_GROUP_ID
                        and    T.LANGUAGE        = L.LANGUAGE_CODE);
END ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
   P_STATUS_GROUP_ID              IN  NUMBER,
   P_OWNER                        IN  VARCHAR2,
   P_TRANSITION_IND               IN  VARCHAR2,
   P_DEFAULT_INCIDENT_STATUS_ID   IN  NUMBER,
   P_ORIG_SYSTEM_REFERENCE_ID     IN  NUMBER,
   P_START_DATE                   IN  VARCHAR2,
   P_END_DATE                     IN  VARCHAR2,
   P_GROUP_NAME                   IN  VARCHAR2,
   P_DESCRIPTION                  IN  VARCHAR2,
   P_LANGUAGE                     IN VARCHAR2,
   P_SOURCE_LANG                  IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER        IN  NUMBER,
   P_SECURITY_GROUP_ID            IN  NUMBER )
IS
   l_user_id                      number := 0;
   l_status_group_id              number;
   lx_object_version_number       number;
   l_rowid                        number;
BEGIN
   if ( p_owner = 'SEED' ) then
      l_user_id := 1;
   end if;

   l_status_group_id := p_status_group_id;

   UPDATE_ROW (
      X_STATUS_GROUP_ID              => l_status_group_id,
      X_OBJECT_VERSION_NUMBER        => p_object_version_number,
      X_TRANSITION_IND               => p_transition_ind,
      X_DEFAULT_INCIDENT_STATUS_ID   => p_default_incident_status_id,
      X_ORIG_SYSTEM_REFERENCE_ID     => p_orig_system_reference_id,
      X_START_DATE                   => to_date(p_start_date, 'DD-MM-YYYY'),
      X_END_DATE                     => to_date(p_end_date,   'DD-MM-YYYY'),
      X_GROUP_NAME                   => p_group_name,
      X_DESCRIPTION                  => p_description,
      X_LANGUAGE                     => p_language ,
      X_SOURCE_LANG                  => p_source_lang,
      X_LAST_UPDATE_DATE             => SYSDATE,
      X_LAST_UPDATED_BY              => l_user_id,
      X_LAST_UPDATE_LOGIN            => 0,
      X_SECURITY_GROUP_ID            => p_security_group_id );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
         X_ROWID                       => l_rowid,
         X_STATUS_GROUP_ID             => l_status_group_id,
         X_TRANSITION_IND               => p_transition_ind,
         X_DEFAULT_INCIDENT_STATUS_ID   => p_default_incident_status_id,
         X_ORIG_SYSTEM_REFERENCE_ID     => p_orig_system_reference_id,
         X_START_DATE                   => to_date(p_start_date, 'DD-MM-YYYY'),
         X_END_DATE                     => to_date(p_end_date,   'DD-MM-YYYY'),
         X_GROUP_NAME                   => p_group_name,
         X_DESCRIPTION                  => p_description,
         X_LANGUAGE                     => p_language ,
         X_SOURCE_LANG                  => p_source_lang,
         X_CREATION_DATE                => SYSDATE,
         X_CREATED_BY                   => l_user_id,
         X_LAST_UPDATE_DATE             => SYSDATE,
         X_LAST_UPDATED_BY              => l_user_id,
	 X_LAST_UPDATE_LOGIN            => 0,
         X_OBJECT_VERSION_NUMBER        => p_object_version_number,
         X_SECURITY_GROUP_ID            => p_security_group_id);

END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
   P_STATUS_GROUP_ID              IN NUMBER,
   P_GROUP_NAME                   IN VARCHAR2,
   P_DESCRIPTION                  IN VARCHAR2,
   P_OWNER                        IN VARCHAR2 )
IS
BEGIN
   UPDATE  cs_sr_status_groups_tl
   SET     group_name        = p_group_name,
           description       = NVL(p_description,description),
           last_update_date  = sysdate,
           last_updated_by   = DECODE(p_owner, 'SEED', 1, 0),
           last_update_login = 0,
           source_lang       = userenv('LANG')
   WHERE   status_group_id   = p_status_group_id
   AND     userenv('LANG') IN (language, source_lang) ;

END TRANSLATE_ROW ;

END CS_SR_STATUS_GROUPS_PKG;

/
