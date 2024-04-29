--------------------------------------------------------
--  DDL for Package Body CN_COLLECTIONS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECTIONS_V_PKG" AS
-- $Header: cncocvb.pls 120.0 2005/09/03 03:13:21 apink noship $
--
-- Procedure Name
--   insert_row

l_org_id      NUMBER;

PROCEDURE insert_row(
                        X_module_id NUMBER,
                        X_rep_id NUMBER,
                        X_set_of_books NUMBER,
                        X_source_id NUMBER,
                        X_version VARCHAR2,
                        X_schema  VARCHAR2,
                        X_status  VARCHAR2,
                        X_description VARCHAR2,
                        X_type    VARCHAR2,
						x_org_id IN NUMBER) IS
  l_rowid		ROWID;
  l_date		DATE;
  l_user_id		NUMBER;
  l_login_id          	NUMBER;

  BEGIN

	l_org_id := x_org_id;


    IF X_source_id IS NOT NULL THEN

      INSERT INTO cn_repositories(
        repository_id,
        version,
        SCHEMA,
        status,
        application_type,
        description,
		org_id,
		object_version_number)
      VALUES(
        X_source_id,
        X_version,
        X_schema,
        X_status,
        X_type,
        X_description,
		l_org_id,
		1);
    END IF;

   SELECT sysdate
   INTO l_date
   FROM dual;

   l_user_id := nvl(fnd_profile.value('USER_ID'),-1);
   l_login_id := nvl(fnd_profile.value('LOGIN_ID'),-1);

    cn_modules_pkg.insert_row(
			X_ROWID => l_rowid,
			X_MODULE_ID => X_module_id,
			X_MODULE_TYPE => 'COL',
			X_REPOSITORY_ID => X_rep_id,
			X_DESCRIPTION => NULL,
			X_PARENT_MODULE_ID => NULL,
			X_SOURCE_REPOSITORY_ID => x_source_id,
			X_MODULE_STATUS => NULL,
			X_EVENT_ID => NULL,
			X_LAST_MODIFICATION => l_date,
			X_LAST_SYNCHRONIZATION => l_date,
			X_OUTPUT_FILENAME => NULL,
			X_COLLECT_FLAG => NULL,
			X_NAME => NULL,
			X_CREATION_DATE => l_date,
			X_CREATED_BY => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY => l_user_id,
			x_last_update_login => l_login_id,
			x_org_id => l_org_id);


  END insert_row;



  -- Procedure Name
  --   insert_collection
  -- Purpose
  --   Insert a collection without creating a new repository to collect into
  -- History
  --                    Tony Lower              Created
  PROCEDURE insert_collection (
                        X_module_id NUMBER,
                        X_rep_id NUMBER,
                        X_event_id NUMBER,
                        X_module_type VARCHAR2,
                        X_set_of_books NUMBER,
                        X_source_id NUMBER,
                        X_version VARCHAR2,
                        X_schema  VARCHAR2,
                        X_status  VARCHAR2,
                        X_description VARCHAR2,
		        		X_type    VARCHAR2,
						x_org_id IN NUMBER) IS
  l_rowid		ROWID;
  l_date		DATE;
  l_user_id		NUMBER;
  l_login_id          	NUMBER;

  BEGIN

   SELECT sysdate
   INTO l_date
   FROM dual;

   l_user_id := nvl(fnd_profile.value('USER_ID'),-1);
   l_login_id := nvl(fnd_profile.value('LOGIN_ID'),-1);

    cn_modules_pkg.insert_row(
			X_ROWID => l_rowid ,
			X_MODULE_ID => X_module_id,
			X_MODULE_TYPE => X_module_type,
			X_REPOSITORY_ID => X_rep_id,
			X_DESCRIPTION => NULL,
			X_PARENT_MODULE_ID => NULL,
			X_SOURCE_REPOSITORY_ID => x_source_id,
			X_MODULE_STATUS => NULL,
			X_EVENT_ID => x_event_id,
			X_LAST_MODIFICATION => l_date,
			X_LAST_SYNCHRONIZATION => l_date,
			X_OUTPUT_FILENAME => NULL,
			X_COLLECT_FLAG => NULL,
			X_NAME => NULL,
			X_CREATION_DATE => l_date,
			X_CREATED_BY => l_user_id,
			X_LAST_UPDATE_DATE => l_date,
			X_LAST_UPDATED_BY => l_user_id,
			x_last_update_login => l_login_id,
			x_org_id => l_org_id);


    IF X_source_id IS NOT NULL THEN

      UPDATE cn_repositories
        SET          version = X_version,
                      SCHEMA = X_schema,
                      status = X_status,
            application_type = X_type,
                 description = X_description,
       object_version_number = object_version_number + 1
         WHERE repository_id = X_source_id
		 AND   org_id = l_org_id;

    END IF;

  END insert_collection;



  --
  -- Procedure Name
  --   update_row
  -- History
  --                    Tony Lower              Created
  PROCEDURE update_row(
                        X_module_id NUMBER,
                        X_rep_id NUMBER,
                        X_event_id NUMBER,
                        X_module_type VARCHAR2,
                        X_set_of_books NUMBER,
                        X_source_id NUMBER,
                        X_version VARCHAR2,
                        X_schema  VARCHAR2,
                        X_status  VARCHAR2,
                        X_type    VARCHAR2,
						x_org_id IN NUMBER,
						x_object_Version_number IN OUT NOCOPY NUMBER)
  IS

  CURSOR ovn_csr IS
  SELECT object_version_number
  FROM   cn_repositories
  WHERE  repository_id = x_source_id
  AND    org_id = x_org_id;

  l_ovn_csr ovn_csr%ROWTYPE;


  BEGIN

    l_org_id := x_org_id;

    OPEN ovn_csr;
    FETCH ovn_csr INTO l_ovn_csr;
    CLOSE ovn_csr;

    IF X_source_id IS NOT NULL THEN

      UPDATE cn_repositories SET
        version = X_version,
        SCHEMA = X_schema,
        status = X_status,
        application_type = X_type,
        object_version_number = l_ovn_csr.object_version_number + 1
      WHERE repository_id = X_source_id
      AND   org_id = l_org_id;

      x_object_Version_number := l_ovn_csr.object_version_number + 1;

    END IF;

    cn_modules_pkg.update_row(
       x_repository_id => X_rep_id,
       x_event_id => X_event_id,
       x_module_type => X_module_type,
       x_source_repository_id => x_source_id,
       x_module_id => X_module_id,
	   x_org_id => l_org_id);

  END update_row;



  --
  -- Procedure Name
  --   lock_row
  -- History
  --                    Tony Lower              Created
  -- 07-28-95           Amy Erickson            Updated

  PROCEDURE lock_row (x_module_id  NUMBER) IS
        temp_id  NUMBER;
  BEGIN

    SELECT module_id
      INTO temp_id
      FROM cn_modules
     WHERE module_id = x_module_id
       FOR UPDATE ;

    SELECT cn_repositories.repository_id
      INTO temp_id
      FROM cn_repositories, cn_modules
     WHERE cn_modules.source_repository_id = cn_repositories.repository_id (+)
       AND cn_modules.module_id = x_module_id;

    IF temp_id IS NOT NULL THEN

      SELECT repository_id
        INTO temp_id
        FROM cn_repositories
       WHERE repository_id = temp_ID
         FOR UPDATE;

    END IF;

  END lock_row;

  --
  -- Procedure Name
  --   update_collect_flag
  -- History
  --   07-28-95         Amy Erickson            Created
  --
  PROCEDURE update_collect_flag (x_module_id     NUMBER,
                                 x_collect_flag  VARCHAR2,
								 x_org_id IN NUMBER) IS

  BEGIN

     l_org_id := x_org_id;


     IF x_module_id IS NOT NULL THEN

-- MLS changes: have to use tbl handler
--    UPDATE cn_modules
--       SET collect_flag = x_collect_flag
--      WHERE module_id = x_module_id;

     cn_modules_pkg.update_row(
       x_collect_flag => x_collect_flag,
       x_module_id => X_module_id,
	   x_org_id => l_org_id);

     END IF;

  END update_collect_flag;


END cn_collections_v_pkg;

/
