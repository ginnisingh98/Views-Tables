--------------------------------------------------------
--  DDL for Package Body CS_SR_LINK_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_LINK_TYPES_PKG" AS
/* $Header: cstlntyb.pls 115.3 2002/12/11 22:53:35 dejoseph noship $ */

PROCEDURE INSERT_ROW (
   PX_LINK_TYPE_ID           IN OUT NOCOPY  NUMBER,
   P_NAME                    IN VARCHAR2,
   P_DESCRIPTION             IN VARCHAR2,
   P_RECIPROCAL_LINK_TYPE_ID IN NUMBER,
   P_START_DATE_ACTIVE       IN DATE,
   P_END_DATE_ACTIVE         IN DATE,
   P_APPLICATION_ID          IN NUMBER,
   P_SEEDED_FLAG             IN VARCHAR2,
   P_USER_ID                 IN NUMBER, -- used for created and updated by
   P_LOGIN_ID                IN NUMBER, -- used for last update login id.
   P_ATTRIBUTE1              IN VARCHAR2,
   P_ATTRIBUTE2              IN VARCHAR2,
   P_ATTRIBUTE3              IN VARCHAR2,
   P_ATTRIBUTE4              IN VARCHAR2,
   P_ATTRIBUTE5              IN VARCHAR2,
   P_ATTRIBUTE6              IN VARCHAR2,
   P_ATTRIBUTE7              IN VARCHAR2,
   P_ATTRIBUTE8              IN VARCHAR2,
   P_ATTRIBUTE9              IN VARCHAR2,
   P_ATTRIBUTE10             IN VARCHAR2,
   P_ATTRIBUTE11             IN VARCHAR2,
   P_ATTRIBUTE12             IN VARCHAR2,
   P_ATTRIBUTE13             IN VARCHAR2,
   P_ATTRIBUTE14             IN VARCHAR2,
   P_ATTRIBUTE15             IN VARCHAR2,
   P_CONTEXT                 IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER   IN NUMBER,
   P_SECURITY_GROUP_ID       IN NUMBER,
   P_ATTRIBUTE_CONTEXT       IN VARCHAR2,
   X_RETURN_STATUS	     OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		     OUT NOCOPY   NUMBER,
   X_MSG_DATA		     OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER,
   X_RECIPROCAL_LINK_ID      OUT NOCOPY   NUMBER,
   X_LINK_ID	             OUT NOCOPY   NUMBER )
IS
   cursor c1 is
   select cs_sr_link_types_b_s.nextval
   from dual;

BEGIN
   if ( px_link_type_id IS NULL ) OR ( px_link_type_id = FND_API.G_MISS_NUM) THEN
      open c1;
      fetch c1 into px_link_type_id;
      close c1;
   end if;

   insert into CS_SR_LINK_TYPES_B (
      LINK_TYPE_ID,         END_DATE_ACTIVE,          RECIPROCAL_LINK_TYPE_ID,
      START_DATE_ACTIVE,    APPLICATION_ID,           SEEDED_FLAG,
      CREATED_BY,           CREATION_DATE,            LAST_UPDATED_BY,
      LAST_UPDATE_DATE,     LAST_UPDATE_LOGIN,
      ATTRIBUTE1,           ATTRIBUTE2,               ATTRIBUTE3,
      ATTRIBUTE4,           ATTRIBUTE5,               ATTRIBUTE6,
      ATTRIBUTE7,           ATTRIBUTE8,               ATTRIBUTE9,
      ATTRIBUTE10,          ATTRIBUTE11,              ATTRIBUTE12,
      ATTRIBUTE13,          ATTRIBUTE14,              ATTRIBUTE15,
      OBJECT_VERSION_NUMBER,SECURITY_GROUP_ID,        ATTRIBUTE_CONTEXT )
   VALUES (
      PX_LINK_TYPE_ID,      P_END_DATE_ACTIVE,        P_RECIPROCAL_LINK_TYPE_ID,
      P_START_DATE_ACTIVE,  P_APPLICATION_ID,         P_SEEDED_FLAG,
      p_user_id,            SYSDATE,                  p_user_id,
      SYSDATE,              p_login_id,
      P_ATTRIBUTE1,         P_ATTRIBUTE2,             P_ATTRIBUTE3,
      P_ATTRIBUTE4,         P_ATTRIBUTE5,             P_ATTRIBUTE6,
      P_ATTRIBUTE7,         P_ATTRIBUTE8,             P_ATTRIBUTE9,
      P_ATTRIBUTE10,        P_ATTRIBUTE11,            P_ATTRIBUTE12,
      P_ATTRIBUTE13,        P_ATTRIBUTE14,            P_ATTRIBUTE15,
      P_OBJECT_VERSION_NUMBER,  P_SECURITY_GROUP_ID,  P_ATTRIBUTE_CONTEXT );


   INSERT INTO CS_SR_LINK_TYPES_TL (
      LINK_TYPE_ID,         NAME,                     DESCRIPTION,
      LAST_UPDATE_DATE,     LAST_UPDATED_BY,          CREATION_DATE,
      CREATED_BY,           LAST_UPDATE_LOGIN,        SECURITY_GROUP_ID,
      LANGUAGE,             SOURCE_LANG)
   SELECT
      PX_LINK_TYPE_ID,      P_NAME,                   P_DESCRIPTION,
      SYSDATE,              P_USER_ID,                SYSDATE,
      P_USER_ID,            P_LOGIN_ID,               P_SECURITY_GROUP_ID,
      L.LANGUAGE_CODE,      userenv('LANG')
   FROM  FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG in ('I', 'B')
   AND NOT EXISTS ( SELECT NULL
                    FROM   CS_SR_LINK_TYPES_TL T
                    WHERE  T.LINK_TYPE_ID = PX_LINK_TYPE_ID
                    AND    T.LANGUAGE = L.LANGUAGE_CODE);
END INSERT_ROW;


PROCEDURE LOCK_ROW (
   P_LINK_TYPE_ID            IN NUMBER,
   P_OBJECT_VERSION_NUMBER   IN NUMBER )
IS
   cursor c is
   select 1
   from   cs_sr_link_types_vl
   where  link_type_id          = p_link_type_id
   and    object_version_number = p_object_version_number
   for    update nowait;

   l_dummy     number(3) := 0;
BEGIN
   open c;
   fetch c into l_dummy;
   if (c%notfound) then
      close c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   end if;
   close c;

END LOCK_ROW;


PROCEDURE UPDATE_ROW (
   P_LINK_TYPE_ID            IN NUMBER,
   P_RECIPROCAL_LINK_TYPE_ID IN NUMBER,
   P_START_DATE_ACTIVE       IN DATE,
   P_END_DATE_ACTIVE         IN DATE,
   P_APPLICATION_ID          IN NUMBER,
   P_SEEDED_FLAG             IN VARCHAR2,
   P_USER_ID                 IN NUMBER, -- used for created and updated by
   P_LOGIN_ID                IN NUMBER, -- used for last update login id.
   P_ATTRIBUTE1              IN VARCHAR2,
   P_ATTRIBUTE2              IN VARCHAR2,
   P_ATTRIBUTE3              IN VARCHAR2,
   P_ATTRIBUTE4              IN VARCHAR2,
   P_ATTRIBUTE5              IN VARCHAR2,
   P_ATTRIBUTE6              IN VARCHAR2,
   P_ATTRIBUTE7              IN VARCHAR2,
   P_ATTRIBUTE8              IN VARCHAR2,
   P_ATTRIBUTE9              IN VARCHAR2,
   P_ATTRIBUTE10             IN VARCHAR2,
   P_ATTRIBUTE11             IN VARCHAR2,
   P_ATTRIBUTE12             IN VARCHAR2,
   P_ATTRIBUTE13             IN VARCHAR2,
   P_ATTRIBUTE14             IN VARCHAR2,
   P_ATTRIBUTE15             IN VARCHAR2,
   P_CONTEXT                 IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER   IN NUMBER,
   P_SECURITY_GROUP_ID       IN NUMBER,
   P_ATTRIBUTE_CONTEXT       IN VARCHAR2,
   P_NAME                    IN VARCHAR2,
   P_DESCRIPTION             IN VARCHAR2,
   X_RETURN_STATUS	     OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		     OUT NOCOPY   NUMBER,
   X_MSG_DATA		     OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER,
   X_RECIPROCAL_LINK_ID      OUT NOCOPY   NUMBER,
   X_LINK_ID		     OUT NOCOPY   NUMBER )
IS

BEGIN
   update CS_SR_LINK_TYPES_B
   set    END_DATE_ACTIVE         = P_END_DATE_ACTIVE,
          RECIPROCAL_LINK_TYPE_ID = P_RECIPROCAL_LINK_TYPE_ID,
          START_DATE_ACTIVE       = P_START_DATE_ACTIVE,
          APPLICATION_ID          = P_APPLICATION_ID,
          SEEDED_FLAG             = P_SEEDED_FLAG,
          ATTRIBUTE1              = P_ATTRIBUTE1,
          ATTRIBUTE2              = P_ATTRIBUTE2,
          ATTRIBUTE3              = P_ATTRIBUTE3,
          ATTRIBUTE4              = P_ATTRIBUTE4,
          ATTRIBUTE5              = P_ATTRIBUTE5,
          ATTRIBUTE6              = P_ATTRIBUTE6,
          ATTRIBUTE7              = P_ATTRIBUTE7,
          ATTRIBUTE8              = P_ATTRIBUTE8,
          ATTRIBUTE9              = P_ATTRIBUTE9,
          ATTRIBUTE10             = P_ATTRIBUTE10,
          ATTRIBUTE11             = P_ATTRIBUTE11,
          ATTRIBUTE12             = P_ATTRIBUTE12,
          ATTRIBUTE13             = P_ATTRIBUTE13,
          ATTRIBUTE14             = P_ATTRIBUTE14,
          ATTRIBUTE15             = P_ATTRIBUTE15,
          OBJECT_VERSION_NUMBER   = P_OBJECT_VERSION_NUMBER,
          SECURITY_GROUP_ID       = P_SECURITY_GROUP_ID,
          ATTRIBUTE_CONTEXT       = P_ATTRIBUTE_CONTEXT,
          LAST_UPDATE_DATE        = SYSDATE,
          LAST_UPDATED_BY         = P_USER_ID,
          LAST_UPDATE_LOGIN       = P_LOGIN_ID
   WHERE LINK_TYPE_ID          = P_LINK_TYPE_ID;

   if (sql%notfound) then
      raise no_data_found;
   end if;

   update CS_SR_LINK_TYPES_TL set
      NAME                    = P_NAME,
      DESCRIPTION             = P_DESCRIPTION,
      LAST_UPDATE_DATE        = SYSDATE,
      LAST_UPDATED_BY         = P_USER_ID,
      LAST_UPDATE_LOGIN       = P_LOGIN_ID,
      SOURCE_LANG             = userenv('LANG')
   WHERE LINK_TYPE_ID   = P_LINK_TYPE_ID
   AND USERENV('LANG') in (LANGUAGE, SOURCE_LANG);

   if (sql%notfound) then
      raise no_data_found;
   end if;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  P_LINK_TYPE_ID in NUMBER)
IS
BEGIN
   delete from cs_sr_link_types_tl
   where link_type_id = p_link_type_id;

   if (sql%notfound) then
     raise no_data_found;
   end if;

   delete from cs_sr_link_types_b
   where link_type_id = p_link_type_id;

   if (sql%notfound) then
     raise no_data_found;
   end if;

END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
   delete from cs_sr_link_types_tl T
   where not exists ( select NULL
                      from   CS_SR_LINK_TYPES_B B
                      where  B.LINK_TYPE_ID = T.LINK_TYPE_ID );

   update CS_SR_LINK_TYPES_TL T
   set ( NAME, DESCRIPTION  ) = ( select B.NAME, B.DESCRIPTION
                                  from CS_SR_LINK_TYPES_TL B
                                  where B.LINK_TYPE_ID = T.LINK_TYPE_ID
                                  and B.LANGUAGE = T.SOURCE_LANG)
   where (T.LINK_TYPE_ID, T.LANGUAGE) in ( select SUBT.LINK_TYPE_ID, SUBT.LANGUAGE
                                           from   CS_SR_LINK_TYPES_TL SUBB,
						  CS_SR_LINK_TYPES_TL SUBT
                                           where  SUBB.LINK_TYPE_ID = SUBT.LINK_TYPE_ID
                                           and    SUBB.LANGUAGE = SUBT.SOURCE_LANG
                                           and    (    SUBB.NAME <> SUBT.NAME
                                                    or SUBB.DESCRIPTION <> SUBT.DESCRIPTION)
			                  );

  insert into CS_SR_LINK_TYPES_TL (
    LINK_TYPE_ID,        NAME,                 DESCRIPTION,
    LAST_UPDATE_DATE,    LAST_UPDATED_BY,      CREATION_DATE,
    CREATED_BY,          LAST_UPDATE_LOGIN,    SECURITY_GROUP_ID,
    LANGUAGE,            SOURCE_LANG )
  select
    B.LINK_TYPE_ID,      B.NAME,               B.DESCRIPTION,
    B.LAST_UPDATE_DATE,  B.LAST_UPDATED_BY,    B.CREATION_DATE,
    B.CREATED_BY,        B.LAST_UPDATE_LOGIN,  B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,     B.SOURCE_LANG
  from  CS_SR_LINK_TYPES_TL B,
	FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and   B.LANGUAGE = userenv('LANG')
  and   not exists ( select NULL
                     from   CS_SR_LINK_TYPES_TL T
                     where  T.LINK_TYPE_ID = B.LINK_TYPE_ID
                     and    T.LANGUAGE     = L.LANGUAGE_CODE);
END ADD_LANGUAGE;


PROCEDURE TRANSLATE_ROW (
   P_LINK_TYPE_ID            IN NUMBER,
   P_NAME                    IN VARCHAR2,
   P_DESCRIPTION             IN VARCHAR2,
   P_OWNER                   IN VARCHAR2 )
IS
BEGIN
   UPDATE  cs_sr_link_types_tl
   SET     name              = p_name,
           description       = NVL(p_description,description),
           last_update_date  = sysdate,
           last_updated_by   = DECODE(p_owner, 'SEED', 1, 0),
           last_update_login = 0,
           source_lang       = userenv('LANG')
   WHERE   link_type_id    =    p_link_type_id
   AND     userenv('LANG') IN (language, source_lang) ;
END TRANSLATE_ROW ;

PROCEDURE LOAD_ROW (
   P_LINK_TYPE_ID            IN NUMBER,
   P_NAME                    IN VARCHAR2,
   P_DESCRIPTION             IN VARCHAR2,
   P_RECIPROCAL_LINK_TYPE_ID IN NUMBER,
   P_START_DATE_ACTIVE       IN VARCHAR2,
   P_END_DATE_ACTIVE         IN VARCHAR2,
   P_OWNER                   IN VARCHAR2,
   P_APPLICATION_ID          IN NUMBER,
   P_SEEDED_FLAG             IN VARCHAR2,
   P_ATTRIBUTE1              IN VARCHAR2,
   P_ATTRIBUTE2              IN VARCHAR2,
   P_ATTRIBUTE3              IN VARCHAR2,
   P_ATTRIBUTE4              IN VARCHAR2,
   P_ATTRIBUTE5              IN VARCHAR2,
   P_ATTRIBUTE6              IN VARCHAR2,
   P_ATTRIBUTE7              IN VARCHAR2,
   P_ATTRIBUTE8              IN VARCHAR2,
   P_ATTRIBUTE9              IN VARCHAR2,
   P_ATTRIBUTE10             IN VARCHAR2,
   P_ATTRIBUTE11             IN VARCHAR2,
   P_ATTRIBUTE12             IN VARCHAR2,
   P_ATTRIBUTE13             IN VARCHAR2,
   P_ATTRIBUTE14             IN VARCHAR2,
   P_ATTRIBUTE15             IN VARCHAR2,
   P_CONTEXT                 IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER   IN NUMBER,
   P_SECURITY_GROUP_ID       IN NUMBER,
   P_ATTRIBUTE_CONTEXT       IN VARCHAR2 )
IS

   -- Out local variables for the update / insert row procedures.
   lx_return_status	     VARCHAR2(3);
   lx_msg_count		     NUMBER(15);
   lx_msg_data		     VARCHAR2(2000);
   lx_reciprocal_link_id     NUMBER;
   lx_link_id		     NUMBER;
   lx_object_version_number  NUMBER := 0;

   l_user_id                 NUMBER;

   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_link_type_id            NUMBER;

BEGIN
   if ( p_owner = 'SEED' ) then
	 l_user_id := 1;
   end if;

   l_link_type_id := p_link_type_id;

   UPDATE_ROW (
      P_LINK_TYPE_ID            => l_link_type_id,
      P_RECIPROCAL_LINK_TYPE_ID => p_reciprocal_link_type_id,
      P_START_DATE_ACTIVE       => to_date(p_start_date_active,'DD-MM-YYYY'),
      P_END_DATE_ACTIVE         => to_date(p_end_date_active,'DD-MM-YYYY'),
      P_APPLICATION_ID          => p_application_id,
      P_SEEDED_FLAG             => p_seeded_flag,
      P_USER_ID                 => l_user_id,
      P_LOGIN_ID                => 0,
      P_ATTRIBUTE1              => p_attribute1,
      P_ATTRIBUTE2              => p_attribute2,
      P_ATTRIBUTE3              => p_attribute3,
      P_ATTRIBUTE4              => p_attribute4,
      P_ATTRIBUTE5              => p_attribute5,
      P_ATTRIBUTE6              => p_attribute6,
      P_ATTRIBUTE7              => p_attribute7,
      P_ATTRIBUTE8              => p_attribute8,
      P_ATTRIBUTE9              => p_attribute9,
      P_ATTRIBUTE10             => p_attribute10,
      P_ATTRIBUTE11             => p_attribute11,
      P_ATTRIBUTE12             => p_attribute12,
      P_ATTRIBUTE13             => p_attribute13,
      P_ATTRIBUTE14             => p_attribute14,
      P_ATTRIBUTE15             => p_attribute15,
      P_CONTEXT                 => p_context,
      P_OBJECT_VERSION_NUMBER   => p_object_version_number,
      P_SECURITY_GROUP_ID       => p_security_group_id,
      P_ATTRIBUTE_CONTEXT       => p_attribute_context,
      P_NAME                    => p_name,
      P_DESCRIPTION             => p_description,
      X_RETURN_STATUS	        => lx_return_status,
      X_MSG_COUNT		=> lx_msg_count,
      X_MSG_DATA		=> lx_msg_data,
      X_OBJECT_VERSION_NUMBER   => lx_object_version_number,
      X_RECIPROCAL_LINK_ID      => lx_reciprocal_link_id,
      X_LINK_ID		        => lx_link_id ) ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
         PX_LINK_TYPE_ID           => l_link_type_id,
         P_RECIPROCAL_LINK_TYPE_ID => p_reciprocal_link_type_id,
         P_START_DATE_ACTIVE       => to_date(p_start_date_active,'DD-MM-YYYY'),
         P_END_DATE_ACTIVE         => to_date(p_end_date_active,'DD-MM-YYYY'),
         P_APPLICATION_ID          => p_application_id,
         P_SEEDED_FLAG             => p_seeded_flag,
         P_USER_ID                 => l_user_id,
         P_LOGIN_ID                => 0,
         P_ATTRIBUTE1              => p_attribute1,
         P_ATTRIBUTE2              => p_attribute2,
         P_ATTRIBUTE3              => p_attribute3,
         P_ATTRIBUTE4              => p_attribute4,
         P_ATTRIBUTE5              => p_attribute5,
         P_ATTRIBUTE6              => p_attribute6,
         P_ATTRIBUTE7              => p_attribute7,
         P_ATTRIBUTE8              => p_attribute8,
         P_ATTRIBUTE9              => p_attribute9,
         P_ATTRIBUTE10             => p_attribute10,
         P_ATTRIBUTE11             => p_attribute11,
         P_ATTRIBUTE12             => p_attribute12,
         P_ATTRIBUTE13             => p_attribute13,
         P_ATTRIBUTE14             => p_attribute14,
         P_ATTRIBUTE15             => p_attribute15,
         P_CONTEXT                 => p_context,
         P_OBJECT_VERSION_NUMBER   => p_object_version_number,
         P_SECURITY_GROUP_ID       => p_security_group_id,
         P_ATTRIBUTE_CONTEXT       => p_attribute_context,
         P_NAME                    => p_name,
         P_DESCRIPTION             => p_description,
         X_RETURN_STATUS	   => lx_return_status,
         X_MSG_COUNT		   => lx_msg_count,
         X_MSG_DATA		   => lx_msg_data,
         X_OBJECT_VERSION_NUMBER   => lx_object_version_number,
         X_RECIPROCAL_LINK_ID      => lx_reciprocal_link_id,
         X_LINK_ID		   => lx_link_id ) ;

END LOAD_ROW;

END CS_SR_LINK_TYPES_PKG;

/
