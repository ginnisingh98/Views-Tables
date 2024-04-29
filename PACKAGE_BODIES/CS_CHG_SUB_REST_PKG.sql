--------------------------------------------------------
--  DDL for Package Body CS_CHG_SUB_REST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHG_SUB_REST_PKG" AS
/* $Header: csxresttb.pls 115.0 2004/06/04 01:46:02 aseethep noship $ */

   PROCEDURE INSERT_ROW (
      PX_RESTRICTION_ID         IN OUT NOCOPY NUMBER,
      P_RESTRICTION_TYPE        IN VARCHAR2,
      P_CONDITION             	IN VARCHAR2,
      P_VALUE_OBJECT_ID 	IN NUMBER,
      P_VALUE_AMOUNT       	IN NUMBER,
      P_CURRENCY_CODE         	IN VARCHAR2,
      P_START_DATE_ACTIVE 	IN DATE,
      P_END_DATE_ACTIVE 	IN DATE,
      P_CREATION_DATE 		IN DATE,
      P_CREATED_BY		IN NUMBER,
      P_LAST_UPDATE_DATE        IN DATE,
      P_LAST_UPDATED_BY		IN NUMBER,
      P_LAST_UPDATE_LOGIN	IN NUMBER,
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
      P_SECURITY_GROUP_ID       IN NUMBER)
IS
   cursor c1 is
   select cs_chg_sub_restrictions_s.nextval
   from dual;

BEGIN
   if ( px_restriction_id IS NULL ) OR ( px_restriction_id = FND_API.G_MISS_NUM) THEN
      open c1;
      fetch c1 into px_restriction_id;
      close c1;
   end if;

   insert into CS_CHG_SUB_RESTRICTIONS (
      RESTRICTION_ID,		RESTRICTION_TYPE,	CONDITION,
      VALUE_OBJECT_ID,		VALUE_AMOUNT, 		CURRENCY_CODE,
      START_DATE_ACTIVE, 	END_DATE_ACTIVE, 	CREATION_DATE,
      CREATED_BY,		LAST_UPDATE_DATE, 	LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,	ATTRIBUTE1,             ATTRIBUTE2,
      ATTRIBUTE3, 		ATTRIBUTE4, 		ATTRIBUTE5,
      ATTRIBUTE6, 		ATTRIBUTE7, 		ATTRIBUTE8,
      ATTRIBUTE9, 		ATTRIBUTE10, 		ATTRIBUTE11,
      ATTRIBUTE12, 		ATTRIBUTE13, 		ATTRIBUTE14,
      ATTRIBUTE15,		CONTEXT, 		OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID)
   VALUES (
      PX_RESTRICTION_ID,	P_RESTRICTION_TYPE,	P_CONDITION,
      P_VALUE_OBJECT_ID,	P_VALUE_AMOUNT, 	P_CURRENCY_CODE,
      P_START_DATE_ACTIVE, 	P_END_DATE_ACTIVE, 	P_CREATION_DATE,
      P_CREATED_BY,		P_LAST_UPDATE_DATE, 	P_LAST_UPDATED_BY,
      P_LAST_UPDATE_LOGIN,	P_ATTRIBUTE1, 		P_ATTRIBUTE2,
      P_ATTRIBUTE3, 		P_ATTRIBUTE4, 		P_ATTRIBUTE5,
      P_ATTRIBUTE6, 		P_ATTRIBUTE7, 		P_ATTRIBUTE8,
      P_ATTRIBUTE9, 		P_ATTRIBUTE10,          P_ATTRIBUTE11,
      P_ATTRIBUTE12, 		P_ATTRIBUTE13,          P_ATTRIBUTE14,
      P_ATTRIBUTE15,		P_CONTEXT, 		P_OBJECT_VERSION_NUMBER,
      P_SECURITY_GROUP_ID);


END INSERT_ROW;


PROCEDURE LOCK_ROW (
   P_RESTRICTION_ID            IN NUMBER,
   P_OBJECT_VERSION_NUMBER     IN NUMBER)
IS
   cursor c is
   select 1
   from   cs_chg_sub_restrictions
   where  restriction_id          = p_restriction_id
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
      P_RESTRICTION_ID         	IN NUMBER,
      P_RESTRICTION_TYPE        IN VARCHAR2,
      P_CONDITION             	IN VARCHAR2,
      P_VALUE_OBJECT_ID 	IN NUMBER,
      P_VALUE_AMOUNT       	IN NUMBER,
      P_CURRENCY_CODE         	IN VARCHAR2,
      P_START_DATE_ACTIVE 	IN DATE,
      P_END_DATE_ACTIVE 	IN DATE,
      P_CREATION_DATE 		IN DATE,
      P_CREATED_BY		IN NUMBER,
      P_LAST_UPDATE_DATE        IN DATE,
      P_LAST_UPDATED_BY		IN NUMBER,
      P_LAST_UPDATE_LOGIN	IN NUMBER,
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
      P_SECURITY_GROUP_ID       IN NUMBER)
IS

BEGIN

      UPDATE 	CS_CHG_SUB_RESTRICTIONS
      SET 	RESTRICTION_ID		= P_RESTRICTION_ID,
		RESTRICTION_TYPE	= P_RESTRICTION_TYPE,
		CONDITION		= P_CONDITION,
      		VALUE_OBJECT_ID		= P_VALUE_OBJECT_ID,
		VALUE_AMOUNT		= P_VALUE_AMOUNT,
		CURRENCY_CODE		= P_CURRENCY_CODE,
      		START_DATE_ACTIVE	= P_START_DATE_ACTIVE,
		END_DATE_ACTIVE		= P_END_DATE_ACTIVE,
		CREATION_DATE		= P_CREATION_DATE,
      		CREATED_BY		= P_CREATED_BY,
		LAST_UPDATE_DATE	= P_LAST_UPDATE_DATE,
		LAST_UPDATED_BY		= P_LAST_UPDATED_BY,
      		LAST_UPDATE_LOGIN	= P_LAST_UPDATE_LOGIN,
		ATTRIBUTE1		= P_ATTRIBUTE1,
      		ATTRIBUTE2		= P_ATTRIBUTE2,
		ATTRIBUTE3		= P_ATTRIBUTE3,
		ATTRIBUTE4		= P_ATTRIBUTE4,
      		ATTRIBUTE5		= P_ATTRIBUTE5,
		ATTRIBUTE6		= P_ATTRIBUTE6,
		ATTRIBUTE7		= P_ATTRIBUTE7,
      		ATTRIBUTE8		= P_ATTRIBUTE8,
		ATTRIBUTE9		= P_ATTRIBUTE9,
 		ATTRIBUTE10		= P_ATTRIBUTE10,
      		ATTRIBUTE11		= P_ATTRIBUTE11,
		ATTRIBUTE12		= P_ATTRIBUTE12,
		ATTRIBUTE13		= P_ATTRIBUTE13,
      		ATTRIBUTE14		= P_ATTRIBUTE14,
		ATTRIBUTE15		= P_ATTRIBUTE15,
		CONTEXT			= P_CONTEXT,
      		OBJECT_VERSION_NUMBER	= P_OBJECT_VERSION_NUMBER,
		SECURITY_GROUP_ID	= P_SECURITY_GROUP_ID
	WHERE  RESTRICTION_ID = P_RESTRICTION_ID;

   if (sql%notfound) then
      raise no_data_found;
   end if;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  P_RESTRICTION_ID in NUMBER)
IS
BEGIN

   DELETE FROM cs_chg_sub_restrictions
   WHERE restriction_id = p_restriction_id;

   if (sql%notfound) then
     raise no_data_found;
   end if;

END DELETE_ROW;

PROCEDURE LOAD_ROW (
      P_RESTRICTION_ID          IN NUMBER,
      P_RESTRICTION_TYPE        IN VARCHAR2,
      P_CONDITION             	IN VARCHAR2,
      P_VALUE_OBJECT_ID 	IN NUMBER,
      P_VALUE_AMOUNT       	IN NUMBER,
      P_CURRENCY_CODE         	IN VARCHAR2,
      P_START_DATE_ACTIVE 	IN DATE,
      P_END_DATE_ACTIVE 	IN DATE,
      P_CREATION_DATE 		IN DATE,
      P_CREATED_BY		IN NUMBER,
      P_LAST_UPDATE_DATE        IN DATE,
      P_LAST_UPDATED_BY		IN NUMBER,
      P_LAST_UPDATE_LOGIN	IN NUMBER,
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
      P_SECURITY_GROUP_ID	IN NUMBER)
IS

 -- Out local variables for the update / insert row procedures.
   lx_object_version_number  NUMBER := 0;
   l_user_id                 NUMBER := 0;

   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_RESTRICTION_ID      NUMBER;

BEGIN

   /* if ( p_owner = 'SEED' ) then
         l_user_id := 1;
   end if; */

   l_RESTRICTION_ID := P_RESTRICTION_ID;

  UPDATE_ROW(P_RESTRICTION_ID => l_RESTRICTION_ID,
      	     P_RESTRICTION_TYPE => P_RESTRICTION_TYPE,
      	     P_CONDITION  => P_CONDITION,
      	     P_VALUE_OBJECT_ID 	=> P_VALUE_OBJECT_ID,
      	     P_VALUE_AMOUNT     => P_VALUE_AMOUNT,
      	     P_CURRENCY_CODE    => P_CURRENCY_CODE,
      	     P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
      	     P_END_DATE_ACTIVE 	=> P_END_DATE_ACTIVE,
      	     P_CREATION_DATE    => P_CREATION_DATE,
      	     P_CREATED_BY       => P_CREATED_BY,
      	     P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
      	     P_LAST_UPDATED_BY =>  P_LAST_UPDATED_BY,
      	     P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
      	     P_ATTRIBUTE1        => P_ATTRIBUTE1,
      	     P_ATTRIBUTE2        => P_ATTRIBUTE2,
      	     P_ATTRIBUTE3        => P_ATTRIBUTE3,
      	     P_ATTRIBUTE4        => P_ATTRIBUTE4,
      	     P_ATTRIBUTE5        => P_ATTRIBUTE5,
      	     P_ATTRIBUTE6        => P_ATTRIBUTE6,
      	     P_ATTRIBUTE7        => P_ATTRIBUTE7,
      	     P_ATTRIBUTE8        => P_ATTRIBUTE8,
      	     P_ATTRIBUTE9        => P_ATTRIBUTE9,
      	     P_ATTRIBUTE10        => P_ATTRIBUTE10,
      	     P_ATTRIBUTE11        => P_ATTRIBUTE11,
      	     P_ATTRIBUTE12        => P_ATTRIBUTE12,
      	     P_ATTRIBUTE13        => P_ATTRIBUTE13,
      	     P_ATTRIBUTE14        => P_ATTRIBUTE14,
      	     P_ATTRIBUTE15        => P_ATTRIBUTE15,
      	     P_CONTEXT            => P_CONTEXT,
      	     P_OBJECT_VERSION_NUMBER   => P_OBJECT_VERSION_NUMBER,
             P_SECURITY_GROUP_ID       => P_SECURITY_GROUP_ID);

EXCEPTION
 WHEN NO_DATA_FOUND THEN

  INSERT_ROW(PX_RESTRICTION_ID => l_RESTRICTION_ID,
      	     P_RESTRICTION_TYPE => P_RESTRICTION_TYPE,
      	     P_CONDITION  => P_CONDITION,
      	     P_VALUE_OBJECT_ID 	=> P_VALUE_OBJECT_ID,
      	     P_VALUE_AMOUNT     => P_VALUE_AMOUNT,
      	     P_CURRENCY_CODE    => P_CURRENCY_CODE,
      	     P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
      	     P_END_DATE_ACTIVE 	=> P_END_DATE_ACTIVE,
      	     P_CREATION_DATE    => P_CREATION_DATE,
      	     P_CREATED_BY       => P_CREATED_BY,
      	     P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
      	     P_LAST_UPDATED_BY =>  P_LAST_UPDATED_BY,
      	     P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
      	     P_ATTRIBUTE1        => P_ATTRIBUTE1,
      	     P_ATTRIBUTE2        => P_ATTRIBUTE2,
      	     P_ATTRIBUTE3        => P_ATTRIBUTE3,
      	     P_ATTRIBUTE4        => P_ATTRIBUTE4,
      	     P_ATTRIBUTE5        => P_ATTRIBUTE5,
      	     P_ATTRIBUTE6        => P_ATTRIBUTE6,
      	     P_ATTRIBUTE7        => P_ATTRIBUTE7,
      	     P_ATTRIBUTE8        => P_ATTRIBUTE8,
      	     P_ATTRIBUTE9        => P_ATTRIBUTE9,
      	     P_ATTRIBUTE10        => P_ATTRIBUTE10,
      	     P_ATTRIBUTE11        => P_ATTRIBUTE11,
      	     P_ATTRIBUTE12        => P_ATTRIBUTE12,
      	     P_ATTRIBUTE13        => P_ATTRIBUTE13,
      	     P_ATTRIBUTE14        => P_ATTRIBUTE14,
      	     P_ATTRIBUTE15        => P_ATTRIBUTE15,
      	     P_CONTEXT            => P_CONTEXT,
      	     P_OBJECT_VERSION_NUMBER   => P_OBJECT_VERSION_NUMBER,
      	     P_SECURITY_GROUP_ID   => P_SECURITY_GROUP_ID);

END LOAD_ROW;

END CS_CHG_SUB_REST_PKG;

/
