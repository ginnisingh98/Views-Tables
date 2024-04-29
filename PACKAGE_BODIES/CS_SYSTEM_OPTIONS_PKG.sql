--------------------------------------------------------
--  DDL for Package Body CS_SYSTEM_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SYSTEM_OPTIONS_PKG" AS
/* $Header: cstsyopb.pls 120.0 2005/08/12 15:28:12 aneemuch noship $ */

PROCEDURE INSERT_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER,
   P_SR_AGENT_SECURITY         IN   VARCHAR2,
   P_SS_SRTYPE_RESTRICT        IN   VARCHAR2,
   P_CREATION_DATE             IN   DATE,
   P_CREATED_BY                IN   NUMBER,
   P_LAST_UPDATE_DATE          IN   DATE,
   P_LAST_UPDATED_BY           IN   NUMBER,
   P_LAST_UPDATE_LOGIN         IN   NUMBER,
   P_ATTRIBUTE1                IN   VARCHAR2,
   P_ATTRIBUTE2                IN   VARCHAR2,
   P_ATTRIBUTE3                IN   VARCHAR2,
   P_ATTRIBUTE4                IN   VARCHAR2,
   P_ATTRIBUTE5                IN   VARCHAR2,
   P_ATTRIBUTE6                IN   VARCHAR2,
   P_ATTRIBUTE7                IN   VARCHAR2,
   P_ATTRIBUTE8                IN   VARCHAR2,
   P_ATTRIBUTE9                IN   VARCHAR2,
   P_ATTRIBUTE10               IN   VARCHAR2,
   P_ATTRIBUTE11               IN   VARCHAR2,
   P_ATTRIBUTE12               IN   VARCHAR2,
   P_ATTRIBUTE13               IN   VARCHAR2,
   P_ATTRIBUTE14               IN   VARCHAR2,
   P_ATTRIBUTE15               IN   VARCHAR2,
   P_ATTRIBUTE_CATEGORY        IN   VARCHAR2,
   P_OBJECT_VERSION_NUMBER     IN   NUMBER )
IS

BEGIN

   INSERT INTO CS_SYSTEM_OPTIONS (
      SYSTEM_OPTION_ID,      SR_AGENT_SECURITY,     SS_SRTYPE_RESTRICT,
      CREATION_DATE,         CREATED_BY,            LAST_UPDATE_DATE,
      LAST_UPDATED_BY,       LAST_UPDATE_LOGIN,     ATTRIBUTE1,
      ATTRIBUTE2,            ATTRIBUTE3,            ATTRIBUTE4,
      ATTRIBUTE5,            ATTRIBUTE6,            ATTRIBUTE7,
      ATTRIBUTE8,            ATTRIBUTE9,            ATTRIBUTE10,
      ATTRIBUTE11,           ATTRIBUTE12,           ATTRIBUTE13,
      ATTRIBUTE14,           ATTRIBUTE15,           ATTRIBUTE_CATEGORY,
      OBJECT_VERSION_NUMBER )
   VALUES (
      P_SYSTEM_OPTION_ID,    P_SR_AGENT_SECURITY,   P_SS_SRTYPE_RESTRICT,
      P_CREATION_DATE,       P_CREATED_BY,          P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY,     P_LAST_UPDATE_LOGIN,   P_ATTRIBUTE1,
      P_ATTRIBUTE2,          P_ATTRIBUTE3,          P_ATTRIBUTE4,
      P_ATTRIBUTE5,          P_ATTRIBUTE6,          P_ATTRIBUTE7,
      P_ATTRIBUTE8,          P_ATTRIBUTE9,          P_ATTRIBUTE10,
      P_ATTRIBUTE11,         P_ATTRIBUTE12,         P_ATTRIBUTE13,
      P_ATTRIBUTE14,         P_ATTRIBUTE15,         P_ATTRIBUTE_CATEGORY,
      P_OBJECT_VERSION_NUMBER );


END INSERT_ROW;


PROCEDURE UPDATE_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER,
   P_SR_AGENT_SECURITY         IN   VARCHAR2,
   P_SS_SRTYPE_RESTRICT        IN   VARCHAR2,
   P_LAST_UPDATE_DATE          IN   DATE,
   P_LAST_UPDATED_BY           IN   NUMBER,
   P_LAST_UPDATE_LOGIN         IN   NUMBER,
   P_ATTRIBUTE1                IN   VARCHAR2,
   P_ATTRIBUTE2                IN   VARCHAR2,
   P_ATTRIBUTE3                IN   VARCHAR2,
   P_ATTRIBUTE4                IN   VARCHAR2,
   P_ATTRIBUTE5                IN   VARCHAR2,
   P_ATTRIBUTE6                IN   VARCHAR2,
   P_ATTRIBUTE7                IN   VARCHAR2,
   P_ATTRIBUTE8                IN   VARCHAR2,
   P_ATTRIBUTE9                IN   VARCHAR2,
   P_ATTRIBUTE10               IN   VARCHAR2,
   P_ATTRIBUTE11               IN   VARCHAR2,
   P_ATTRIBUTE12               IN   VARCHAR2,
   P_ATTRIBUTE13               IN   VARCHAR2,
   P_ATTRIBUTE14               IN   VARCHAR2,
   P_ATTRIBUTE15               IN   VARCHAR2,
   P_ATTRIBUTE_CATEGORY        IN   VARCHAR2,
   P_OBJECT_VERSION_NUMBER     IN   NUMBER )
IS
BEGIN
   UPDATE CS_SYSTEM_OPTIONS set
      SR_AGENT_SECURITY      = P_SR_AGENT_SECURITY,
      SS_SRTYPE_RESTRICT     = P_SS_SRTYPE_RESTRICT,
      LAST_UPDATE_DATE       = P_LAST_UPDATE_DATE,
      LAST_UPDATED_BY        = P_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN      = P_LAST_UPDATE_LOGIN,
      ATTRIBUTE1             = P_ATTRIBUTE1,
      ATTRIBUTE2             = P_ATTRIBUTE2,
      ATTRIBUTE3             = P_ATTRIBUTE3,
      ATTRIBUTE4             = P_ATTRIBUTE4,
      ATTRIBUTE5             = P_ATTRIBUTE5,
      ATTRIBUTE6             = P_ATTRIBUTE6,
      ATTRIBUTE7             = P_ATTRIBUTE7,
      ATTRIBUTE8             = P_ATTRIBUTE8,
      ATTRIBUTE9             = P_ATTRIBUTE9,
      ATTRIBUTE10            = P_ATTRIBUTE10,
      ATTRIBUTE11            = P_ATTRIBUTE11,
      ATTRIBUTE12            = P_ATTRIBUTE12,
      ATTRIBUTE13            = P_ATTRIBUTE13,
      ATTRIBUTE14            = P_ATTRIBUTE14,
      ATTRIBUTE15            = P_ATTRIBUTE15,
      ATTRIBUTE_CATEGORY     = P_ATTRIBUTE_CATEGORY,
      OBJECT_VERSION_NUMBER  = P_OBJECT_VERSION_NUMBER
  WHERE SYSTEM_OPTION_ID = P_SYSTEM_OPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;


PROCEDURE DELETE_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER )
IS
BEGIN
  delete from CS_SYSTEM_OPTIONS
  where SYSTEM_OPTION_ID = P_SYSTEM_OPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END DELETE_ROW;


PROCEDURE LOCK_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER,
   P_OBJECT_VERSION_NUMBER     IN   NUMBER)
IS
  cursor c1 is
  select 1
  from   cs_system_options
  where  SYSTEM_OPTION_ID       = p_system_option_id
  and    object_version_number  = p_object_version_number
  for    update of system_option_id nowait;

  l_dummy     NUMBER := 0;

BEGIN
      open c1;
      fetch c1 into l_dummy;

      if ( c1%NOTFOUND ) then
	 close c1;
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      end if;

      close c1;

END LOCK_ROW;


PROCEDURE LOAD_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER,
   P_SR_AGENT_SECURITY         IN   VARCHAR2,
   P_SS_SRTYPE_RESTRICT        IN   VARCHAR2,
   P_CREATION_DATE             IN   VARCHAR2,
   P_CREATED_BY                IN   NUMBER,
   P_LAST_UPDATE_DATE          IN   VARCHAR2,
   P_LAST_UPDATED_BY           IN   NUMBER,
   P_LAST_UPDATE_LOGIN         IN   NUMBER,
   P_OWNER                     IN   VARCHAR2,
   P_ATTRIBUTE1                IN   VARCHAR2,
   P_ATTRIBUTE2                IN   VARCHAR2,
   P_ATTRIBUTE3                IN   VARCHAR2,
   P_ATTRIBUTE4                IN   VARCHAR2,
   P_ATTRIBUTE5                IN   VARCHAR2,
   P_ATTRIBUTE6                IN   VARCHAR2,
   P_ATTRIBUTE7                IN   VARCHAR2,
   P_ATTRIBUTE8                IN   VARCHAR2,
   P_ATTRIBUTE9                IN   VARCHAR2,
   P_ATTRIBUTE10               IN   VARCHAR2,
   P_ATTRIBUTE11               IN   VARCHAR2,
   P_ATTRIBUTE12               IN   VARCHAR2,
   P_ATTRIBUTE13               IN   VARCHAR2,
   P_ATTRIBUTE14               IN   VARCHAR2,
   P_ATTRIBUTE15               IN   VARCHAR2,
   P_ATTRIBUTE_CATEGORY        IN   VARCHAR2,
   P_OBJECT_VERSION_NUMBER     IN   NUMBER )
IS

   l_user_id        NUMBER   := 0;

BEGIN
   if ( p_owner = 'SEED' ) then
      l_user_id  := 1;
   end if;

   UPDATE_ROW (
      P_SYSTEM_OPTION_ID          => p_system_option_id,
      P_SR_AGENT_SECURITY         => p_sr_agent_security,
      P_SS_SRTYPE_RESTRICT        => p_ss_srtype_restrict,
      P_LAST_UPDATE_DATE          => nvl(to_date(p_last_update_date, 'DD-MM-YYYY'), sysdate),
      P_LAST_UPDATED_BY           => l_user_id,
      P_LAST_UPDATE_LOGIN         => 0,
      P_ATTRIBUTE1                => p_attribute1,
      P_ATTRIBUTE2                => p_attribute2,
      P_ATTRIBUTE3                => p_attribute3,
      P_ATTRIBUTE4                => p_attribute4,
      P_ATTRIBUTE5                => p_attribute5,
      P_ATTRIBUTE6                => p_attribute6,
      P_ATTRIBUTE7                => p_attribute7,
      P_ATTRIBUTE8                => p_attribute8,
      P_ATTRIBUTE9                => p_attribute9,
      P_ATTRIBUTE10               => p_attribute10,
      P_ATTRIBUTE11               => p_attribute11,
      P_ATTRIBUTE12               => p_attribute12,
      P_ATTRIBUTE13               => p_attribute13,
      P_ATTRIBUTE14               => p_attribute14,
      P_ATTRIBUTE15               => p_attribute15,
      P_ATTRIBUTE_CATEGORY        => p_attribute_category,
      P_OBJECT_VERSION_NUMBER     => p_object_version_number );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
   INSERT_ROW (
      P_SYSTEM_OPTION_ID          => p_system_option_id,
      P_SR_AGENT_SECURITY         => p_sr_agent_security,
      P_SS_SRTYPE_RESTRICT        => p_ss_srtype_restrict,
      P_CREATION_DATE             => nvl(to_date(p_creation_date, 'DD-MM-YYYY'), sysdate),
      P_CREATED_BY                => l_user_id,
      P_LAST_UPDATE_DATE          => nvl(to_date(p_last_update_date, 'DD-MM-YYYY'), sysdate),
      P_LAST_UPDATED_BY           => l_user_id,
      P_LAST_UPDATE_LOGIN         => 0,
      P_ATTRIBUTE1                => p_attribute1,
      P_ATTRIBUTE2                => p_attribute2,
      P_ATTRIBUTE3                => p_attribute3,
      P_ATTRIBUTE4                => p_attribute4,
      P_ATTRIBUTE5                => p_attribute5,
      P_ATTRIBUTE6                => p_attribute6,
      P_ATTRIBUTE7                => p_attribute7,
      P_ATTRIBUTE8                => p_attribute8,
      P_ATTRIBUTE9                => p_attribute9,
      P_ATTRIBUTE10               => p_attribute10,
      P_ATTRIBUTE11               => p_attribute11,
      P_ATTRIBUTE12               => p_attribute12,
      P_ATTRIBUTE13               => p_attribute13,
      P_ATTRIBUTE14               => p_attribute14,
      P_ATTRIBUTE15               => p_attribute15,
      P_ATTRIBUTE_CATEGORY        => p_attribute_category,
      P_OBJECT_VERSION_NUMBER     => p_object_version_number );

END LOAD_ROW;


END CS_SYSTEM_OPTIONS_PKG;

/
