--------------------------------------------------------
--  DDL for Package Body IBC_CONTENT_ITEM_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CONTENT_ITEM_NODES_PKG" AS
/* $Header: ibctcinb.pls 115.4 2002/11/17 16:05:00 srrangar ship $*/

-- Purpose: Table Handler for Ibc_Content_Item_Nodes table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_content_item_node_id           IN OUT NOCOPY NUMBER
,p_content_item_id                 IN NUMBER
,p_directory_node_id               IN NUMBER
,p_object_version_number           IN NUMBER
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
) IS
  CURSOR C IS SELECT ROWID FROM IBC_CONTENT_ITEM_NODES
    WHERE content_item_node_id =   px_content_item_node_id;
  CURSOR c2 IS SELECT ibc_content_item_nodes_s1.NEXTVAL FROM dual;

BEGIN

  -- Primary key validation check

  IF ((px_content_item_node_id IS NULL) OR
      (px_content_item_node_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_content_item_node_id;
    CLOSE c2;
  END IF;

  INSERT INTO IBC_CONTENT_ITEM_NODES (
    content_item_node_id,
    CONTENT_ITEM_ID,
    DIRECTORY_NODE_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
     px_content_item_node_id
    ,p_content_item_id
    ,p_directory_node_id
    ,DECODE(p_object_version_number,FND_API.G_MISS_NUM,1,NULL,1,p_object_version_number)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
  );

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  p_content_item_node_id IN NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_DIRECTORY_NODE_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  CURSOR c IS SELECT
      OBJECT_VERSION_NUMBER
    FROM IBC_CONTENT_ITEM_NODES
    WHERE   content_item_node_id  =   p_content_item_node_id
    FOR UPDATE OF CONTENT_ITEM_ID NOWAIT;
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
 p_content_item_node_id            IN NUMBER
,p_content_item_id                 IN NUMBER        --DEFAULT NULL
,p_directory_node_id               IN NUMBER        --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_object_version_number           IN NUMBER        --DEFAULT NULL
) IS
BEGIN
  UPDATE IBC_CONTENT_ITEM_NODES SET
      content_item_id                = DECODE(p_content_item_id,FND_API.G_MISS_NUM,NULL,NULL,content_item_id,p_content_item_id)
     ,directory_node_id              = DECODE(p_directory_node_id,FND_API.G_MISS_NUM,NULL,NULL,directory_node_id,p_directory_node_id)
     ,object_version_number          = NVL(object_version_number,0) + 1
     ,last_update_date               = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
     ,last_updated_by                = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
     ,last_update_login              = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
  WHERE   content_item_node_id =   p_content_item_node_id
  AND object_version_number = DECODE(p_object_version_number,
                                       FND_API.G_MISS_NUM,
                                       object_version_number,
                                       NULL,
                                       object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_content_item_node_id IN NUMBER
) IS
BEGIN

  DELETE FROM IBC_CONTENT_ITEM_NODES
  WHERE content_item_node_id = p_content_item_node_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;


END Ibc_Content_Item_Nodes_Pkg;

/
