--------------------------------------------------------
--  DDL for Package Body CN_ROLLOVER_QUOTAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLLOVER_QUOTAS_PKG" as
/* $Header: cnrqpkgb.pls 115.1 2002/12/04 02:13:25 fting noship $ */



-- -------------------------------------------------------------------------+
-- |                      Variables                                         |
----------------------------------------------------------------------------+
g_temp_status_code	VARCHAR2(30) := NULL;
g_program_type      	VARCHAR2(30) := NULL;
g_quota_name        	VARCHAR2(80) := NULL;
g_plan_name		VARCHAR2(30) := NULL;
g_schedule_name	        VARCHAR2(30) := NULL;

procedure INSERT_ROW (
 X_ROWID in out NOCOPY VARCHAR2,
   X_ROLLOVER_QUOTA_ID IN OUT NOCOPY NUMBER,
   X_QUOTA_ID IN NUMBER,
   X_SOURCE_QUOTA_ID IN NUMBER,
   X_ROLLOVER IN NUMBER,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2	:= NULL,
   X_ATTRIBUTE1 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE2 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE3 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE4 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE5 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE6 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE7 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE8 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE9 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE10 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE11 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE12 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE13 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE14 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE15 IN VARCHAR2	:= NULL,
   X_CREATED_BY IN NUMBER,
   X_CREATION_DATE IN DATE,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
) is
  cursor C is select ROWID from CN_ROLLOVER_QUOTAS
    where ROLLOVER_QUOTA_ID = X_ROLLOVER_QUOTA_ID  ;

  l_rollover_quota_id NUMBER;
BEGIN

   IF (X_ROLLOVER_QUOTA_ID IS NULL) THEN
      SELECT CN_ROLLOVER_QUOTAS_S.NEXTVAL
	INTO l_rollover_quota_id
	FROM dual;
    ELSE
      l_rollover_quota_id := x_rollover_quota_id;
   END IF;

  insert into CN_ROLLOVER_QUOTAS (
    ROLLOVER_QUOTA_ID,
    QUOTA_ID,
    SOURCE_QUOTA_ID,
    ROLLOVER,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER
  ) VALUES (
    l_ROLLOVER_QUOTA_ID,
    X_QUOTA_ID,
    X_SOURCE_QUOTA_ID,
    X_ROLLOVER,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    1);

 /*open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;*/

end INSERT_ROW;



procedure UPDATE_ROW (
   X_ROLLOVER_QUOTA_ID IN NUMBER,
   X_QUOTA_ID IN NUMBER,
   X_SOURCE_QUOTA_ID IN NUMBER,
   X_ROLLOVER IN NUMBER,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2	:= NULL,
   X_ATTRIBUTE1 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE2 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE3 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE4 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE5 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE6 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE7 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE8 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE9 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE10 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE11 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE12 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE13 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE14 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE15 IN VARCHAR2	:= NULL,
   X_CREATED_BY IN NUMBER,
   X_CREATION_DATE IN DATE,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
) is
begin
  update CN_ROLLOVER_QUOTAS set
    SOURCE_QUOTA_ID = X_SOURCE_QUOTA_ID,
    ROLLOVER = X_ROLLOVER,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
  where ROLLOVER_QUOTA_ID = X_ROLLOVER_QUOTA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
 X_ROLLOVER_QUOTA_ID IN NUMBER
) is
begin
  delete from CN_ROLLOVER_QUOTAS
  where ROLLOVER_QUOTA_ID = X_ROLLOVER_QUOTA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


END CN_ROLLOVER_QUOTAS_PKG;

/