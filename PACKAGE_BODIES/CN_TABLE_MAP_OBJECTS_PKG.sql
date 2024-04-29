--------------------------------------------------------
--  DDL for Package Body CN_TABLE_MAP_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TABLE_MAP_OBJECTS_PKG" as
/* $Header: cntmobjb.pls 120.4 2005/09/21 20:50:55 sjustina noship $ */
PROCEDURE insert_row (
  X_rowid               IN OUT NOCOPY VARCHAR2,
  X_table_map_object_id IN OUT NOCOPY NUMBER,
  X_tm_object_type      IN     VARCHAR2,
  X_table_map_id        IN     NUMBER,
  X_object_id           IN     NUMBER,
  X_creation_date       IN     DATE,
  X_created_by          IN     NUMBER,
  X_org_id              IN     NUMBER
) IS
  CURSOR c IS SELECT rowid FROM cn_table_map_objects
    WHERE table_map_object_id = x_table_map_object_id
    AND org_id = X_org_id;

BEGIN
   IF x_table_map_object_id IS NULL THEN
      SELECT cn_table_map_objects_s.NEXTVAL
	 INTO   x_table_map_object_id
	 FROM   dual;
   END IF;

  INSERT INTO cn_table_map_objects (
    table_map_object_id,
    tm_object_type,
    table_map_id,
    object_id,
    created_by,
    creation_date,
    org_id,
    object_version_number
  ) VALUES (
    x_table_map_object_id,
    x_tm_object_type,
    x_table_map_id,
    x_object_id,
    x_created_by,
    x_creation_date,
    X_org_id,
	1);

  OPEN c;
  FETCH c INTO x_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END insert_row;

PROCEDURE lock_row (
  X_table_map_object_id IN NUMBER,
  X_tm_object_type in VARCHAR2,
  X_table_map_id IN NUMBER,
  X_object_id IN NUMBER
) IS
  CURSOR c1 IS SELECt
	 tm_object_type,
      table_map_id,
      object_id
    FROM cn_table_map_objects
    WHERE table_map_object_id = x_table_map_object_id
    FOR UPDATE OF table_map_object_id NOWAIT;

  tlinfo c1%ROWTYPE;
BEGIN
   OPEN c1;
   FETCH c1 INTO tlinfo;

   IF tlinfo.table_map_id = x_table_map_id
       AND tlinfo.tm_object_type = x_tm_object_type
       AND tlinfo.object_id = x_object_id
   THEN
     NULL;
   ELSE
     CLOSE c1;
     fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
     app_exception.raise_exception;
   END IF;
  CLOSE c1;
  RETURN;
END lock_row;

PROCEDURE update_row (
  X_table_map_object_id IN NUMBER,
  X_tm_object_type in VARCHAR2,
  X_table_map_id IN NUMBER,
  X_object_id IN NUMBER,
  X_last_update_date IN DATE,
  X_last_updated_by IN NUMBER,
  X_last_update_login IN NUMBER,
  x_org_id IN NUMBER,
  x_object_version_number IN OUT NOCOPY NUMBER
) IS

	 -- Added Cursor For R12 MOAC

	CURSOR l_ovn_csr IS
		SELECT	object_version_number
		FROM 	cn_table_map_objects
		WHERE 	table_map_id = X_table_map_id
		AND 	org_id = x_org_id;

	l_object_version_number  cn_table_map_objects.object_version_number%TYPE;

BEGIN

   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version_number;
   CLOSE l_ovn_csr;

   	if (l_object_version_number <> x_object_version_number) THEN

		IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
		THEN
			fnd_message.set_name('CN', 'CL_INVALID_OVN');
			fnd_msg_pub.add;
		END IF;
		RAISE FND_API.G_EXC_ERROR;

	end if;



  UPDATE cn_table_map_objects SET
    tm_object_type = x_tm_object_type,
    table_map_id = x_table_map_id,
    object_id = x_object_id,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login,
    object_version_number = l_object_version_number + 1
  WHERE table_map_object_id = x_table_map_object_id
  AND org_id = x_org_id;

  x_object_version_number := l_object_version_number + 1;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE delete_row (
  X_table_map_object_id IN NUMBER,
  X_ORG_ID IN NUMBER
) IS
BEGIN
  DELETE FROM cn_table_map_objects
  WHERE table_map_object_id = x_table_map_object_id
  AND org_id = X_ORG_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;


PROCEDURE load_row(x_TABLE_MAP_OBJECT_ID in varchar2,
                   x_ORG_ID in varchar2,
                   x_TM_OBJECT_TYPE in varchar2,
                   x_TABLE_MAP_ID in varchar2,
                   x_OBJECT_ID in varchar2,
                   x_LAST_UPDATE_DATE in varchar2,
                   x_LAST_UPDATED_BY in varchar2,
                   x_CREATION_DATE in varchar2,
                   x_CREATED_BY in varchar2,
                   x_LAST_UPDATE_LOGIN in varchar2,
                   x_SECURITY_GROUP_ID in varchar2,
                   x_OBJECT_VERSION_NUMBER in varchar2,
                   x_APPLICATION_SHORT_NAME in varchar2,
                   x_OWNER in varchar2)
IS
	USER_ID NUMBER;
BEGIN
    if (x_TABLE_MAP_OBJECT_ID is NOT NULL) then

		-- Check whether SEED Data or Custom Data you are uploading
		IF (X_OWNER IS NOT NULL) AND (X_OWNER = 'SEED') THEN
      			USER_ID := 1;
    		ELSE
      			USER_ID := 0;
   		END IF;

   		update cn_table_map_objects_all set
   		  ORG_ID = to_number(x_ORG_ID),
   		  TM_OBJECT_TYPE = x_TM_OBJECT_TYPE,
   		  TABLE_MAP_ID = to_number(x_TABLE_MAP_ID),
   		  OBJECT_ID = to_number(x_OBJECT_ID),
   		  LAST_UPDATE_DATE = to_date(x_LAST_UPDATE_DATE, 'DD-MM-YYYY'),
   		  LAST_UPDATED_BY = to_number(x_LAST_UPDATED_BY),
   		  CREATION_DATE = to_date(x_CREATION_DATE, 'DD-MM-YYYY'),
   		  CREATED_BY = to_number(x_CREATED_BY),
   		  LAST_UPDATE_LOGIN = to_number(x_LAST_UPDATE_LOGIN),
   		  SECURITY_GROUP_ID = to_number(x_SECURITY_GROUP_ID),
   		  OBJECT_VERSION_NUMBER = to_number(x_OBJECT_VERSION_NUMBER)
 		where TABLE_MAP_OBJECT_ID = x_TABLE_MAP_OBJECT_ID
 		  and ORG_ID = x_ORG_ID;

	    IF (SQL%NOTFOUND)  THEN
     			-- Insert new record to CN_OBJECTS_TABLE table
			insert into cn_table_map_objects_all
			(TABLE_MAP_OBJECT_ID,
             ORG_ID,
             TM_OBJECT_TYPE,
             TABLE_MAP_ID,
             OBJECT_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             SECURITY_GROUP_ID,
             OBJECT_VERSION_NUMBER
			)
			values
			(to_number(x_TABLE_MAP_OBJECT_ID),
			 to_number(x_ORG_ID),
			 x_TM_OBJECT_TYPE,
             to_number(x_TABLE_MAP_ID),
             to_number(x_OBJECT_ID),
             to_date(x_LAST_UPDATE_DATE, 'DD-MM-YYYY'),
             to_number(x_LAST_UPDATED_BY),
             to_date(x_CREATION_DATE, 'DD-MM-YYYY'),
             to_number(x_CREATED_BY),
             to_number(x_LAST_UPDATE_LOGIN),
             to_number(x_SECURITY_GROUP_ID),
             to_number(x_OBJECT_VERSION_NUMBER)
			);
		end if;
    end if;
END load_row;

PROCEDURE load_seed_row(x_UPLOAD_MODE in varchar2,
                        x_TABLE_MAP_OBJECT_ID in varchar2,
                        x_ORG_ID in varchar2,
                        x_TM_OBJECT_TYPE in varchar2,
                        x_TABLE_MAP_ID in varchar2,
                        x_OBJECT_ID in varchar2,
                        x_LAST_UPDATE_DATE in varchar2,
                        x_LAST_UPDATED_BY in varchar2,
                        x_CREATION_DATE in varchar2,
                        x_CREATED_BY in varchar2,
                        x_LAST_UPDATE_LOGIN in varchar2,
                        x_SECURITY_GROUP_ID in varchar2,
                        x_OBJECT_VERSION_NUMBER in varchar2,
                        x_APPLICATION_SHORT_NAME in varchar2,
                        x_OWNER in varchar2)
IS
BEGIN
     if (x_upload_mode = 'NLS') then
       --CN_TABLE_MAP_OBJECTS_PKG.TRANSLATE_ROW(x_owner);
       -- As this ldt is not required to loaded translated data, you could leave it blank.
	    null;
     else
         CN_TABLE_MAP_OBJECTS_PKG.load_row(x_TABLE_MAP_OBJECT_ID,
                                           x_ORG_ID,
                                           x_TM_OBJECT_TYPE,
                                           x_TABLE_MAP_ID,
                                           x_OBJECT_ID,
                                           x_LAST_UPDATE_DATE,
                                           x_LAST_UPDATED_BY,
                                           x_CREATION_DATE,
                                           x_CREATED_BY,
                                           x_LAST_UPDATE_LOGIN,
                                           x_SECURITY_GROUP_ID,
                                           x_OBJECT_VERSION_NUMBER,
                                           x_APPLICATION_SHORT_NAME,
                                           x_OWNER);
         null;
     end if;
END load_seed_row;

END cn_table_map_objects_pkg ;

/
