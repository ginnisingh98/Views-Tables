--------------------------------------------------------
--  DDL for Package Body CS_SR_LINK_VALID_OBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_LINK_VALID_OBJ_PKG" AS
/* $Header: cstlnvob.pls 115.2 2002/12/09 20:13:59 dejoseph noship $ */

PROCEDURE INSERT_ROW (
   PX_LINK_VALID_OBJ_ID      IN OUT NOCOPY NUMBER,
   P_SUBJECT_TYPE            IN VARCHAR2,
   P_OBJECT_TYPE             IN VARCHAR2,
   P_LINK_TYPE_ID            IN NUMBER,
   P_START_DATE_ACTIVE       IN DATE,
   P_END_DATE_ACTIVE         IN DATE,
   P_USER_ID                 IN NUMBER,
   P_LOGIN_ID                IN NUMBER,
   P_SECURITY_GROUP_ID       IN NUMBER,
   P_APPLICATION_ID          IN NUMBER,
   P_SEEDED_FLAG             IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER   IN NUMBER )
IS
   cursor c1 is
   select cs_sr_link_valid_obj_s.nextval
   from dual;
BEGIN

   if ( px_link_valid_obj_id IS NULL )             OR
      ( px_link_valid_obj_id = FND_API.G_MISS_NUM) THEN
      open c1;
      fetch c1 into px_link_valid_obj_id;
      close c1;
   end if;

   INSERT INTO CS_SR_LINK_VALID_OBJ (
      LINK_VALID_OBJ_ID,    SUBJECT_TYPE,            OBJECT_TYPE,
      LINK_TYPE_ID,         START_DATE_ACTIVE,       END_DATE_ACTIVE,
      CREATED_BY,           CREATION_DATE,           LAST_UPDATE_DATE,
      LAST_UPDATED_BY,      LAST_UPDATE_LOGIN,       APPLICATION_ID,
      SEEDED_FLAG,          OBJECT_VERSION_NUMBER,   SECURITY_GROUP_ID )
   VALUES (
      PX_LINK_VALID_OBJ_ID, P_SUBJECT_TYPE,          P_OBJECT_TYPE,
      P_LINK_TYPE_ID,       P_START_DATE_ACTIVE,     P_END_DATE_ACTIVE,
      P_USER_ID,            SYSDATE,                 SYSDATE,
      P_LOGIN_ID,           P_LOGIN_ID,              P_APPLICATION_ID,
      P_SEEDED_FLAG,        P_OBJECT_VERSION_NUMBER, P_SECURITY_GROUP_ID );

END INSERT_ROW;

PROCEDURE LOCK_ROW (
   P_LINK_VALID_OBJ_ID       IN NUMBER,
   P_OBJECT_VERSION_NUMBER   IN NUMBER )
IS
   cursor c is
   select 1
   from   cs_sr_link_valid_obj
   where  link_valid_obj_id     = p_link_valid_obj_id
   and    object_version_number = p_object_version_number;

   l_dummy             number(3);
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
   P_LINK_VALID_OBJ_ID       IN NUMBER,
   P_SUBJECT_TYPE            IN VARCHAR2,
   P_OBJECT_TYPE             IN VARCHAR2,
   P_LINK_TYPE_ID            IN NUMBER,
   P_START_DATE_ACTIVE       IN DATE,
   P_END_DATE_ACTIVE         IN DATE,
   P_USER_ID                 IN NUMBER,
   P_LOGIN_ID                IN NUMBER,
   P_SECURITY_GROUP_ID       IN NUMBER,
   P_APPLICATION_ID          IN NUMBER,
   P_SEEDED_FLAG             IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER   IN NUMBER )
IS

BEGIN

   UPDATE CS_SR_LINK_VALID_OBJ SET
      SUBJECT_TYPE             = P_SUBJECT_TYPE,
      OBJECT_TYPE              = P_OBJECT_TYPE,
      LINK_TYPE_ID             = P_LINK_TYPE_ID,
      START_DATE_ACTIVE        = P_START_DATE_ACTIVE,
      END_DATE_ACTIVE          = P_END_DATE_ACTIVE,
      LAST_UPDATE_DATE         = SYSDATE,
      LAST_UPDATED_BY          = P_USER_ID,
      LAST_UPDATE_LOGIN        = P_LOGIN_ID,
      APPLICATION_ID           = P_APPLICATION_ID,
      SEEDED_FLAG              = P_SEEDED_FLAG,
      OBJECT_VERSION_NUMBER    = OBJECT_VERSION_NUMBER + 1,
      SECURITY_GROUP_ID        = P_SECURITY_GROUP_ID
   WHERE LINK_VALID_OBJ_ID     = P_LINK_VALID_OBJ_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
   P_LINK_VALID_OBJ_ID in NUMBER )
IS
BEGIN
   delete from cs_sr_link_valid_obj
   where link_valid_obj_id = p_link_valid_obj_id;

   if (sql%notfound) then
      raise no_data_found;
   end if;

END DELETE_ROW;

PROCEDURE LOAD_ROW (
   P_LINK_VALID_OBJ_ID       IN NUMBER,
   P_SUBJECT_TYPE            IN VARCHAR2,
   P_OBJECT_TYPE             IN VARCHAR2,
   P_LINK_TYPE_ID            IN NUMBER,
   P_START_DATE_ACTIVE       IN VARCHAR2,
   P_END_DATE_ACTIVE         IN VARCHAR2,
   P_OWNER                   IN VARCHAR2,
   P_APPLICATION_ID          IN NUMBER,
   P_SEEDED_FLAG             IN VARCHAR2,
   P_SECURITY_GROUP_ID       IN NUMBER,
   P_OBJECT_VERSION_NUMBER   IN NUMBER )
IS
   l_user_id                 NUMBER;
   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_link_valid_obj_id        NUMBER;
BEGIN
   if ( p_owner = 'SEED' ) then
      l_user_id := 1;
   end if;

   l_link_valid_obj_id := p_link_valid_obj_id;

   UPDATE_ROW (
      P_LINK_VALID_OBJ_ID       => p_link_valid_obj_id,
      P_SUBJECT_TYPE            => p_subject_type,
      P_OBJECT_TYPE             => p_object_type,
      P_LINK_TYPE_ID            => p_link_type_id,
      P_START_DATE_ACTIVE       => to_date(p_start_date_active, 'DD-MM-YYYY'),
      P_END_DATE_ACTIVE         => to_date(p_end_date_active, 'DD-MM-YYYY'),
      P_USER_ID                 => l_user_id,
      P_LOGIN_ID                => 0,
      P_SECURITY_GROUP_ID       => p_security_group_id,
      P_APPLICATION_ID          => p_application_id,
      P_SEEDED_FLAG             => p_seeded_flag,
      P_OBJECT_VERSION_NUMBER   => p_object_version_number );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
         PX_LINK_VALID_OBJ_ID      => l_link_valid_obj_id,
         P_SUBJECT_TYPE            => p_subject_type,
         P_OBJECT_TYPE             => p_object_type,
         P_LINK_TYPE_ID            => p_link_type_id,
         P_START_DATE_ACTIVE       => to_date(p_start_date_active, 'DD-MM-YYYY'),
         P_END_DATE_ACTIVE         => to_date(p_end_date_active, 'DD-MM-YYYY'),
         P_USER_ID                 => l_user_id,
         P_LOGIN_ID                => 0,
         P_SECURITY_GROUP_ID       => p_security_group_id,
         P_APPLICATION_ID          => p_application_id,
         P_SEEDED_FLAG             => p_seeded_flag,
         P_OBJECT_VERSION_NUMBER   => p_object_version_number );

END LOAD_ROW;

END CS_SR_LINK_VALID_OBJ_PKG;

/
