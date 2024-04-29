--------------------------------------------------------
--  DDL for Package Body IBC_DIRECTORY_NODE_RELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_DIRECTORY_NODE_RELS_PKG" AS
/* $Header: ibctdrlb.pls 120.2 2005/08/08 14:10:52 appldev ship $*/

-- Purpose: Table Handler for Ibc_Directory_Node_Rels table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- vicho	     11/05/2002     Remove G_MISS defaulting on UPDATE_ROW

PROCEDURE INSERT_ROW (
  x_ROWID  OUT NOCOPY VARCHAR2,
  px_Directory_Node_Rel_ID IN  OUT NOCOPY NUMBER,
  p_CHILD_DIR_NODE_ID IN NUMBER,
  p_PARENT_DIR_NODE_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_CREATION_DATE IN DATE,
  p_CREATED_BY IN NUMBER,
  p_LAST_UPDATE_DATE IN DATE,
  p_LAST_UPDATED_BY IN NUMBER,
  p_LAST_UPDATE_LOGIN IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_DIRECTORY_NODE_RELS
    WHERE Directory_Node_Rel_ID = px_Directory_Node_Rel_ID;

  CURSOR c2 IS SELECT ibc_Directory_Node_Rels_s1.NEXTVAL FROM dual;

  CURSOR c_dirnode(p_dir_node_id NUMBER) IS
    SELECT directory_node_code
      FROM ibc_directory_nodes_b
     WHERE directory_node_id = p_dir_node_id;

  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

BEGIN

  -- Validating Uniqueness for Name in a particular directory
  FOR r_dirnode IN c_dirnode(p_child_dir_node_id) LOOP
    IF IBC_UTILITIES_PVT.is_name_already_used(
          p_dir_node_id          => p_parent_dir_node_id,
          p_name                 => r_dirnode.directory_node_code,
          p_language             => USERENV('lang'),
          p_chk_dir_node_id      => p_child_dir_node_id,
		  x_object_type          => l_object_type,
		  x_object_id            => l_object_id)
    THEN
      Fnd_Message.Set_Name('IBC', 'IBC_INVALID_FOLDER_NAME');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END LOOP;

  -- Primary key validation check

  IF ((px_Directory_Node_Rel_ID IS NULL) OR
      (px_Directory_Node_Rel_ID = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_Directory_Node_Rel_ID;
    CLOSE c2;
  END IF;

  INSERT INTO IBC_DIRECTORY_NODE_RELS (
    Directory_Node_Rel_ID,
    CHILD_DIR_NODE_ID,
    PARENT_DIR_NODE_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
  	px_Directory_Node_Rel_ID ,
    p_CHILD_DIR_NODE_ID,
    p_PARENT_DIR_NODE_ID,
    p_OBJECT_VERSION_NUMBER,
    DECODE(p_creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_creation_date),
    DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login)
 );

  OPEN c;
  FETCH c INTO x_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  p_Directory_Node_Rel_ID IN  NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  CURSOR c IS SELECT
      OBJECT_VERSION_NUMBER
    FROM IBC_DIRECTORY_NODE_RELS
    WHERE Directory_Node_Rel_ID = p_Directory_Node_Rel_ID
    FOR UPDATE OF CHILD_DIR_NODE_ID NOWAIT;
  recinfo c%ROWTYPE;

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

END LOCK_ROW;

PROCEDURE UPDATE_ROW (
p_Directory_Node_Rel_ID IN  NUMBER,
p_CHILD_DIR_NODE_ID	IN  NUMBER,
p_LAST_UPDATED_BY	IN  NUMBER,
p_LAST_UPDATE_DATE	IN  DATE,
p_LAST_UPDATE_LOGIN	IN  NUMBER,
p_OBJECT_VERSION_NUMBER IN  NUMBER,
p_PARENT_DIR_NODE_ID    IN  NUMBER
) IS

  CURSOR c_dirnode(p_dir_node_id NUMBER) IS
    SELECT directory_node_code
      FROM ibc_directory_nodes_b
     WHERE directory_node_id = p_dir_node_id;

  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

BEGIN

  -- Validating Uniqueness for Name in a particular directory
  FOR r_dirnode IN c_dirnode(p_child_dir_node_id) LOOP
    IF IBC_UTILITIES_PVT.is_name_already_used(
          p_dir_node_id          => p_parent_dir_node_id,
          p_name                 => r_dirnode.directory_node_code,
          p_language             => USERENV('lang'),
          p_chk_dir_node_id      => p_child_dir_node_id,
		  x_object_type          => l_object_type,
		  x_object_id            => l_object_id)
    THEN
      Fnd_Message.Set_Name('IBC', 'IBC_INVALID_FOLDER_NAME');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END LOOP;

  UPDATE IBC_DIRECTORY_NODE_RELS SET
  	CHILD_DIR_NODE_ID = DECODE(p_CHILD_DIR_NODE_ID,FND_API.G_MISS_NUM,NULL,NULL,CHILD_DIR_NODE_ID,p_CHILD_DIR_NODE_ID),
    PARENT_DIR_NODE_ID = DECODE(p_PARENT_DIR_NODE_ID,FND_API.G_MISS_NUM,NULL,NULL,PARENT_DIR_NODE_ID,p_PARENT_DIR_NODE_ID),
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    last_update_date = DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
    last_updated_by = DECODE(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = DECODE(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
  WHERE Directory_Node_Rel_ID = p_Directory_Node_Rel_ID
  AND object_version_number = DECODE(p_object_version_number,
                                     FND_API.G_MISS_NUM,object_version_number,
                                     NULL,object_version_number,
                                     p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_Directory_Node_Rel_ID IN NUMBER
) IS
BEGIN

  DELETE FROM IBC_DIRECTORY_NODE_RELS
  WHERE Directory_Node_Rel_ID = p_Directory_Node_Rel_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_DIRECTORY_NODE_REL_ID   IN  NUMBER,
  p_child_dir_NODE_ID    IN  NUMBER,
  p_pARENT_dir_NODE_ID    IN  NUMBER,
  p_OWNER IN VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS

  CURSOR c_dirnode(p_dir_node_id NUMBER) IS
    SELECT directory_node_code
      FROM ibc_directory_nodes_b
     WHERE directory_node_id = p_dir_node_id;

  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

BEGIN

  -- Validating Uniqueness for Name in a particular directory
  FOR r_dirnode IN c_dirnode(p_child_dir_node_id) LOOP
    IF IBC_UTILITIES_PVT.is_name_already_used(
          p_dir_node_id          => p_parent_dir_node_id,
          p_name                 => r_dirnode.directory_node_code,
          p_language             => USERENV('lang'),
          p_chk_dir_node_id      => p_child_dir_node_id,
		  x_object_type          => l_object_type,
		  x_object_id            => l_object_id)
    THEN
      Fnd_Message.Set_Name('IBC', 'IBC_INVALID_FOLDER_NAME');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END LOOP;

  DECLARE
    l_user_id    NUMBER := 0;
    l_last_update_date DATE;
    l_row_id     VARCHAR2(64);
    lx_DIRECTORY_NODE_REL_ID NUMBER := p_DIRECTORY_NODE_REL_ID;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;

  BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM IBC_DIRECTORY_NODE_RELS
	WHERE Directory_Node_Rel_ID = p_Directory_Node_Rel_ID
	AND object_version_number = DECODE(object_version_number,
                                     FND_API.G_MISS_NUM,object_version_number,
                                     NULL,object_version_number,
                                     object_version_number);

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

	     Ibc_Directory_Node_Rels_Pkg.UPDATE_ROW (
       	     p_DIRECTORY_NODE_REL_ID		=>	p_DIRECTORY_NODE_REL_ID	,
             p_CHILD_DIR_NODE_ID		=>	nvl(p_child_dir_NODE_ID,FND_API.G_MISS_NUM),
             p_PARENT_DIR_NODE_ID		=>	nvl(p_pARENT_dir_NODE_ID,FND_API.G_MISS_NUM),
             p_LAST_UPDATED_BY			=>	l_user_id,
             p_LAST_UPDATE_DATE			=>	sysdate,
             p_LAST_UPDATE_LOGIN		=>	0,
             p_OBJECT_VERSION_NUMBER		=>	NULL);

	END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        Ibc_Directory_Node_Rels_Pkg.INSERT_ROW (
             x_ROWID 					=>  l_row_id,
             px_DIRECTORY_NODE_REL_ID	=>	lx_DIRECTORY_NODE_REL_ID	,
             p_CHILD_DIR_NODE_ID		=>	p_child_dir_node_id,
             p_PARENT_DIR_NODE_ID		=>	p_PARENT_DIR_NODE_ID	,
             p_CREATED_BY				=>	l_user_id	,
             p_CREATION_DATE			=>	SYSDATE,
             p_LAST_UPDATED_BY			=>	l_user_id	,
             p_LAST_UPDATE_DATE			=>	sysdate	,
             p_LAST_UPDATE_LOGIN		=>	0,
             p_OBJECT_VERSION_NUMBER	=>	1);

   END;

   -- Security Inheritance Logic.
   DECLARE
     x_return_status VARCHAR2(30);
     x_msg_count     NUMBER;
     x_msg_data      VARCHAR2(4096);
     l_citem_oid     NUMBER :=
        IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM');
     l_directory_oid NUMBER :=
        IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE');
   BEGIN
     -- Establish of inheritance for Security
     IBC_DATA_SECURITY_PVT.establish_inheritance(
       p_instance_object_id     => l_directory_oid
       ,p_instance_pk1_value    => p_child_dir_NODE_ID
       ,p_container_object_id   => l_directory_oid
       ,p_container_pk1_value   => p_PARENT_DIR_NODE_ID
       ,x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
     );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END;

END LOAD_ROW;

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_DIRECTORY_NODE_REL_ID   IN  NUMBER,
  p_CHILD_DIR_NODE_ID    IN  NUMBER,
  p_PARENT_DIR_NODE_ID    IN  NUMBER,
  p_OWNER 	IN VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		NULL;
	ELSE
		Ibc_Directory_Node_Rels_Pkg.LOAD_ROW (
		p_UPLOAD_MODE	 => p_UPLOAD_MODE,
		p_DIRECTORY_NODE_REL_ID	=>	p_DIRECTORY_NODE_REL_ID,
		p_CHILD_DIR_NODE_ID	=>	p_CHILD_DIR_NODE_ID,
		p_PARENT_DIR_NODE_ID	=>	p_PARENT_DIR_NODE_ID,
		p_OWNER		=> p_OWNER,
		p_last_update_date => p_LAST_UPDATE_DATE);
	END IF;
END LOAD_SEED_ROW;

END Ibc_Directory_Node_Rels_Pkg;

/
