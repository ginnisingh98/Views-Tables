--------------------------------------------------------
--  DDL for Package Body IBE_DISPLAYCONTEXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DISPLAYCONTEXT_GRP" AS
  /* $Header: IBEGCTXB.pls 120.3 2006/07/03 10:31:33 apgupta noship $ */

-----------------------------------------------------------------+
-- NOTES
--    1. Raises an exception if the api_version is not valid
--    2. If the context_id is passed in the record, the existing display
--       context is updated.
--    3. If the context_id is set to null, a new display context record
--       is inserted
--    4. If the context_id is passed for update operation, and the object
--       version number does not match , an exception is raised
---   5. If deliverable_id is passed, then the deliverable_id should have
--       the DELIVERABLE_TYPE_CODE (JTF_AMV_ITEMS_B) same as context_type
--       Valid context_types are TEMPLATE OR MEDIA
--       6. Access name is unique for a context_type
--    7. Raises an exception if the access name is null
---------------------------------------------------------------------+
PROCEDURE save_display_context(
          p_api_version           IN      NUMBER,
          p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
          p_commit                IN      VARCHAR2 := FND_API.g_false,
          x_return_status         OUT NOCOPY     VARCHAR2,
          x_msg_count             OUT NOCOPY     NUMBER,
          x_msg_data              OUT NOCOPY     VARCHAR2,
          p_display_context_rec   IN OUT NOCOPY  DISPLAY_CONTEXT_REC_TYPE )
IS
  l_api_name       CONSTANT VARCHAR2(30) := 'save_display_context';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_operation_type VARCHAR2(10) := 'INSERT';
  l_return_status  VARCHAR2(1);
  l_index          NUMBER ;
  l_context_id     NUMBER;
  l_deliverable_id NUMBER := null;
  l_access_name    VARCHAR2(40);

CURSOR context_id_seq IS
  SELECT ibe_dsp_context_b_s1.NEXTVAL
    FROM DUAL;

BEGIN

  --------------------- initialize -----------------------+
  SAVEPOINT save_display_context;

  IF NOT FND_API.compatible_api_call( g_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the context type is valid
  IF ibe_dspmgrvalidation_grp.check_valid_context_type(
                             p_display_context_rec.context_type) = false
  THEN
    RAISE FND_API.g_exc_error;
  END IF;

  --- Check if the context_id exists if not null
  IF p_display_context_rec.context_id IS NOT NULL
  THEN
    IF ibe_dspmgrvalidation_grp.check_context_exists(
           p_display_context_rec.context_id,
           p_display_context_rec.context_type,
           p_display_context_rec.Object_version_Number) = false
    THEN
      RAISE FND_API.g_exc_error;
    END IF;

    l_operation_type:='UPDATE';
  END IF;

  --- Check if the access name of the context exists if not null
  l_access_name := TRIM(p_display_context_rec.access_name);
  IF l_access_name is not null
  THEN
    IF NOT ibe_dspmgrvalidation_grp.check_context_accessname(
                                    l_access_name,
                                    p_display_context_rec.context_type,
                                    p_display_context_rec.context_id)
    THEN
      RAISE FND_API.g_exc_error;
    END IF;
  ELSE
    RAISE ibe_dspmgrvalidation_grp.context_accname_req_exception;
  END IF;

  --- Check if the deliverable id exists if deliverable is not null,
  --- else ignore.
  IF p_display_context_rec.default_deliverable_id is not null AND
     p_display_context_rec.default_deliverable_id <> FND_API.g_miss_num
  THEN
    IF ibe_dspmgrvalidation_grp.check_deliverable_type_exists(
                 p_display_context_rec.Default_deliverable_id ,
                 p_display_context_rec.context_type)
    THEN
      l_deliverable_id := p_display_context_rec.Default_deliverable_id;
    ELSE
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  IF  l_operation_type = 'INSERT'
  THEN
    OPEN  context_id_seq;
    FETCH context_id_seq INTO l_context_id;
    CLOSE context_id_seq;
  END IF;

  IF l_operation_type = 'INSERT'
  THEN
    INSERT INTO IBE_DSP_CONTEXT_B (
           CONTEXT_ID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           ACCESS_NAME,
           CONTEXT_TYPE_CODE,
           ITEM_ID,
                 COMPONENT_TYPE_CODE )
    VALUES (
           l_context_id,
           1,
           SYSDATE,
           FND_GLOBAL.user_id,
           SYSDATE,
           FND_GLOBAL.user_id,
           FND_GLOBAL.user_id,
           p_display_context_rec.access_name,
           p_display_context_rec.context_type,
           l_deliverable_id,
                 p_display_context_rec.component_type_code);

    --- Insert into the TL table
    INSERT INTO IBE_DSP_CONTEXT_TL (
           CONTEXT_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           NAME,
           DESCRIPTION,
           LANGUAGE,
           SOURCE_LANG )
    SELECT l_context_id,
           SYSDATE,
           FND_GLOBAL.user_id,
           SYSDATE,
           FND_GLOBAL.user_id,
           FND_GLOBAL.user_id,
           1,
           p_display_context_rec.display_name,
           p_display_context_rec.description,
           L.LANGUAGE_CODE,
           USERENV('LANG')
      FROM FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND NOT EXISTS (SELECT NULL
                         FROM IBE_DSP_CONTEXT_TL T
                        WHERE T.CONTEXT_ID = l_context_id
                          AND T.language   = L.LANGUAGE_CODE);

    p_display_context_rec.context_id := l_context_id;
    p_display_context_rec.object_version_number := 1;

  ELSIF l_operation_type = 'UPDATE'
  THEN
    UPDATE  IBE_DSP_CONTEXT_B
       SET  LAST_UPDATE_DATE      = SYSDATE,
            LAST_UPDATED_BY       = FND_GLOBAL.user_id,
            LAST_UPDATE_login     = FND_GLOBAL.user_id,
            ACCESS_NAME           = p_display_context_rec.access_name,
            CONTEXT_TYPE_CODE     = p_display_context_rec.context_type,
            ITEM_ID               = l_deliverable_id ,
                  COMPONENT_TYPE_CODE   = p_display_context_rec.component_type_code,
            OBJECT_VERSION_NUMBER =
                        p_display_context_rec.object_version_number + 1
     WHERE  CONTEXT_ID            = p_display_context_rec.context_id
       AND  OBJECT_VERSION_NUMBER =
                          p_display_context_rec.object_version_number;

    --- Update the TL table
    UPDATE IBE_DSP_CONTEXT_TL
       SET NAME = DECODE( p_display_context_rec.display_name,
                          FND_API.G_MISS_CHAR, NAME,
                          p_display_context_rec.display_name),
           DESCRIPTION = decode( p_display_context_rec.description,
                                 FND_API.G_MISS_CHAR, DESCRIPTION,
                                 p_display_context_rec.description),
           LAST_UPDATE_DATE      = SYSDATE,
           LAST_UPDATED_BY       = FND_GLOBAL.user_id,
           LAST_UPDATE_LOGIN     = FND_GLOBAL.user_id,
           OBJECT_VERSION_NUMBER =
                     p_display_context_rec.object_version_number +1 ,
           SOURCE_LANG           = USERENV('LANG')
     WHERE CONTEXT_id   = p_display_context_rec.context_id
       AND USERENV('LANG') IN  (LANGUAGE, SOURCE_LANG);
  END IF;

  --- Check if the caller requested to commit ,
  --- If p_commit set to true, commit the transaction
  IF  FND_API.to_boolean(p_commit)
  THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.COUNT_AND_GET( p_encoded => FND_API.g_false,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data );
EXCEPTION
   WHEN FND_API.g_exc_error
   THEN
     ROLLBACK TO save_display_context;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.g_false,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data );
   WHEN FND_API.g_exc_unexpected_error
   THEN
     ROLLBACK TO save_display_context;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.g_false,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data );
   WHEN ibe_dspmgrvalidation_grp.context_accname_req_exception
   THEN
     ROLLBACK TO save_display_context;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.SET_NAME('IBE','IBE_DSP_CONTEXT_ACCNAME_REQ');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.g_false,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data );
   WHEN OTHERS
   THEN
     ROLLBACK TO save_display_context;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.g_false,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data );

END save_display_context;

---------------------------------------------------------------+
-- NOTES
--    1. Raise exception if the p_api_version doesn't match.
--    2. Raises exception if the context_id does not exist
--    3. The context_id passed should have context_type and the correct
--       object_version_number to be deleted.Else an exception is raised
--    4. All corresponding entries for the context_id are also deleted
--       from TL tables
--------------------------------------------------------------------+
PROCEDURE delete_display_context(
          p_api_version         IN     NUMBER,
          p_init_msg_list       IN     VARCHAR2 := FND_API.g_false,
          p_commit              IN     VARCHAR2 := FND_API.g_false,
          x_return_status       OUT NOCOPY    VARCHAR2,
          x_msg_count           OUT NOCOPY    NUMBER,
          x_msg_data            OUT NOCOPY    VARCHAR2,
          p_display_context_rec IN OUT NOCOPY DISPLAY_CONTEXT_REC_TYPE )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_display_context';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_index       NUMBER;
  l_context_id  NUMBER;
BEGIN
  --------------------- initialize -----------------------+
  SAVEPOINT delete_display_context;

  IF NOT FND_API.compatible_api_call(g_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --- Check if the context_id exists
  IF p_display_context_rec.context_id <> FND_API.g_miss_num  AND
     p_display_context_rec.context_id IS NOT NULL
  THEN
    --  Check if the context_id is valid
    IF ibe_dspmgrvalidation_grp.check_context_exists(
       p_display_context_rec.context_id,
       p_display_context_rec.context_type,
       p_display_context_rec.Object_version_Number) = false
    THEN
      RAISE FND_API.g_exc_error;
    END IF;

    DELETE  FROM IBE_DSP_CONTEXT_B
      WHERE CONTEXT_ID           = p_display_context_rec.context_id
      AND   CONTEXT_TYPE_code    = p_display_context_rec.context_type
      AND   OBJECT_VERSION_NUMBER= p_display_context_rec.object_version_number;

    p_display_context_rec.context_id := null;

    DELETE  FROM IBE_DSP_CONTEXT_TL
      WHERE CONTEXT_ID = p_display_context_rec.context_id;

    --Delete all entries from ibe_dsp_obj_lgl_ctnt which use the context_id
    IBE_LogicalContent_GRP.delete_context(p_display_context_rec.context_id);

    IBE_DSP_SECTION_GRP.Update_Dsp_Context_To_Null(
      p_api_version,
      FND_API.g_false,
      FND_API.g_false,
      FND_API.G_VALID_LEVEL_FULL,
      p_display_context_rec.context_id,
      x_return_status,
      x_msg_count,
      x_msg_data );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSE
    FND_MESSAGE.SET_NAME('IBE','IBE_DSP_CONTEXT_ID_REQ');
    FND_MSG_PUB.ADD;
    RAISE FND_API.g_exc_error;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --- Check if the caller requested to commit ,
  --- If p_commit set to true, commit the transaction
  IF  FND_API.to_boolean(p_commit)
  THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.COUNT_AND_GET(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data );
EXCEPTION
   WHEN FND_API.g_exc_error
   THEN
     ROLLBACK TO delete_display_context;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.COUNT_AND_GET(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );
   WHEN FND_API.g_exc_unexpected_error
   THEN
     ROLLBACK TO delete_display_context;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.COUNT_AND_GET(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );
   WHEN OTHERS THEN
     ROLLBACK TO delete_display_context;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.COUNT_AND_GET(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );
END delete_display_context;

---------------------------------------------------------------
-- NOTES
--    1. Raise exception if the p_api_version doesn't match.
--    2. If context_delete is FND_API.g_true, then operation is
--       delete and delete_display_context is called with appropriate
--       parameters
--    3. If the context_id is passed in the record, the existing display
--       context is updated.
--    4. If the context_id is set to null, a new display context record
--       is inserted  and context_delete is FND_API.g_false
--    5. If the operation is an insert/update, save_display_context with
--         appropriate parameters is called
--    6. Raises exception if the context_id does not exist for an update
--          operation
--    7. If the context_id is passed for update operation, and the object
--       version number does not match , the update operation fails and
--         an exception is raised
--    8. All corresponding entries for the context_id are also inserted
--          updated,deleted from TL tables depending on the operation (2,3)
--------------------------------------------------------------------
PROCEDURE save_delete_display_context(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2  := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_display_context_tbl IN OUT NOCOPY DISPLAY_CONTEXT_TBL_TYPE )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'save_delete_display_context';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status        VARCHAR2(1);
  l_index                NUMBER;
  l_context_id           NUMBER;
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(80);
BEGIN
  --------------------- initialize -----------------------+
  SAVEPOINT save_delete_display_context;

  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR l_index  IN 1..p_display_context_tbl.COUNT
  LOOP
    IF p_display_context_tbl(l_index).context_delete = FND_API.g_true
    THEN
      delete_display_context(
        p_api_version,
        FND_API.g_false,
        FND_API.g_false,
        l_return_status,
        l_msg_count,
        l_msg_data,
        p_display_context_tbl(l_index));

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ELSIF p_display_context_tbl(l_index).context_delete = FND_API.g_false
    THEN
      save_display_context(
        p_api_version,
        FND_API.g_false,
        FND_API.g_false,
        l_return_status,
        l_msg_count,
        l_msg_data,
        p_display_context_tbl(l_index));

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      x_return_status := l_return_status;
    END IF;
  END LOOP;

  --- Check if the caller requested to commit ,
  --- If p_commit set to true, commit the transaction
  IF  FND_API.to_boolean(p_commit)
  THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.COUNT_AND_GET(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data );
EXCEPTION
   WHEN FND_API.g_exc_unexpected_error
   THEN
     ROLLBACK TO save_delete_display_context;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.COUNT_AND_GET(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );
   WHEN OTHERS THEN
     ROLLBACK TO save_delete_display_context;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.COUNT_AND_GET(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data);
END save_delete_display_context;

---------------------------------------------------------------+
-- NOTES
--    1. Raise exception if there is a database error
--    2. Sets the item_id in IBE_DSP_CONTEXT_B to null for
--         the deliverable id passed
--    3. No api level exceptions are raised
---------------------------------------------------------------+
PROCEDURE delete_deliverable(p_deliverable_id IN  NUMBER )
IS
BEGIN
  SAVEPOINT delete_deliverable;

  IF p_deliverable_id <> FND_API.g_miss_num OR
     p_deliverable_id IS NOT NULL
  THEN
    -- Set the deliverable id to null for any display context
    UPDATE IBE_DSP_CONTEXT_B
      SET  item_id = NULL
     WHERE item_id = p_deliverable_id;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK TO delete_deliverable;
END delete_deliverable;

/* ------ Begin Insert_row ------------- */
PROCEDURE INSERT_ROW (
                      X_ROWID                   in out NOCOPY   VARCHAR2,
                      X_CONTEXT_ID              in      NUMBER,
                      X_OBJECT_VERSION_NUMBER   in      NUMBER,
                      X_ACCESS_NAME             in      VARCHAR2,
                      X_CONTEXT_TYPE_CODE       in      VARCHAR2,
                      X_ITEM_ID                 in      NUMBER,
                      X_NAME                    in      VARCHAR2,
                      X_DESCRIPTION             in      VARCHAR2,
                      X_CREATION_DATE           in      DATE,
                      X_CREATED_BY              in      NUMBER,
                      X_LAST_UPDATE_DATE        in      DATE,
                      X_LAST_UPDATED_BY         in      NUMBER,
                      X_LAST_UPDATE_LOGIN       in      NUMBER,
                                  X_COMPONENT_TYPE_CODE in VARCHAR2)
IS
  CURSOR C IS
    SELECT ROWID
      FROM IBE_DSP_CONTEXT_B
     WHERE CONTEXT_ID = X_CONTEXT_ID;
BEGIN
  INSERT INTO IBE_DSP_CONTEXT_B (
    CONTEXT_ID,
    OBJECT_VERSION_NUMBER,
    ACCESS_NAME,
    CONTEXT_TYPE_CODE,
    ITEM_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    COMPONENT_TYPE_CODE)
    VALUES (
    X_CONTEXT_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ACCESS_NAME,
    X_CONTEXT_TYPE_CODE,
    X_ITEM_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_COMPONENT_TYPE_CODE);

  INSERT INTO IBE_DSP_CONTEXT_TL (
    CONTEXT_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG)
    SELECT
          X_CONTEXT_ID,
          X_OBJECT_VERSION_NUMBER,
          X_CREATED_BY,
          X_CREATION_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATE_LOGIN,
          X_NAME,
          X_DESCRIPTION,
          L.LANGUAGE_CODE,
          USERENV('LANG')
      FROM  FND_LANGUAGES L
      WHERE L.INSTALLED_FLAG in ('I', 'B')
        AND NOT EXISTS(
            SELECT NULL
              FROM IBE_DSP_CONTEXT_TL T
              WHERE T.CONTEXT_ID = X_CONTEXT_ID
                AND T.LANGUAGE = L.LANGUAGE_CODE);
    OPEN c;
    FETCH c INTO X_ROWID;
    IF (c%NOTFOUND)
    THEN
      CLOSE c;
      RAISE no_data_found;
    END IF;
    CLOSE c;
END INSERT_ROW;
---- End INSERT_ROW Procedure -----+

---- Start LOCK_ROW Procedue ---+
PROCEDURE LOCK_ROW (
                    X_CONTEXT_ID                in      NUMBER,
                    X_OBJECT_VERSION_NUMBER     in      NUMBER,
                    X_ACCESS_NAME               in      VARCHAR2,
                    X_CONTEXT_TYPE_CODE         in      VARCHAR2,
                    X_ITEM_ID                   in      NUMBER,
                    X_NAME                      in      VARCHAR2,
                    X_DESCRIPTION               in      VARCHAR2)
IS
  CURSOR c IS
    SELECT
           OBJECT_VERSION_NUMBER,
           ACCESS_NAME,
           CONTEXT_TYPE_CODE,
           ITEM_ID
      FROM IBE_DSP_CONTEXT_B
     WHERE CONTEXT_ID = X_CONTEXT_ID
      FOR UPDATE OF CONTEXT_ID NOWAIT;

    recinfo c%rowtype;

    CURSOR c1 IS
      SELECT NAME,
             DESCRIPTION,
             DECODE(LANGUAGE, userenv('LANG'), 'Y', 'N') baselang
        FROM IBE_DSP_CONTEXT_TL
        WHERE CONTEXT_ID = X_CONTEXT_ID
          AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
          FOR UPDATE OF CONTEXT_ID NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE c;

  IF ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER) AND
      (recinfo.ACCESS_NAME = X_ACCESS_NAME) AND
      (recinfo.CONTEXT_TYPE_CODE = X_CONTEXT_TYPE_CODE) AND
      ((recinfo.ITEM_ID = X_ITEM_ID) OR
      ((recinfo.ITEM_ID is null) AND (X_ITEM_ID is null))))
  THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  FOR tlinfo IN c1
  LOOP
    IF (tlinfo.BASELANG = 'Y')
    THEN
      IF (((tlinfo.NAME = X_NAME) OR
          ((tlinfo.NAME is null) AND
          (X_NAME is null))) AND
          ((tlinfo.DESCRIPTION = X_DESCRIPTION) OR
          ((tlinfo.DESCRIPTION is null) AND
          (X_DESCRIPTION is null))))
      THEN
        NULL;
      ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END LOCK_ROW;
------- End LOCK_ROW Procedure -------+

------- start UPDATE_ROW Procedure ---+
PROCEDURE update_row (
                      x_context_id              in      number,
                      x_object_version_number   in      number,
                      x_access_name             in      varchar2,
                      x_context_type_code       in      varchar2,
                      x_item_id                 in      number,
                      x_name                    in      varchar2,
                      x_description             in      varchar2,
                      x_last_update_date        in      date,
                      x_last_updated_by         in      number,
                      x_last_update_login       in      number,
                                  x_component_type_code in VARCHAR2)
IS
BEGIN
  UPDATE IBE_DSP_CONTEXT_B
    SET  OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
         ACCESS_NAME = X_ACCESS_NAME,
         CONTEXT_TYPE_CODE = X_CONTEXT_TYPE_CODE,
         ITEM_ID = X_ITEM_ID,
         LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = X_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
            COMPONENT_TYPE_CODE = x_component_type_code
  WHERE  CONTEXT_ID = X_CONTEXT_ID;

  IF (sql%NOTFOUND)
  THEN
    RAISE no_data_found;
  END IF;

  UPDATE IBE_DSP_CONTEXT_TL
     SET NAME = X_NAME,
         DESCRIPTION = X_DESCRIPTION,
         LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = X_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
         SOURCE_LANG = userenv('LANG')
   WHERE CONTEXT_ID = X_CONTEXT_ID
     AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (sql%notfound)
  THEN
    RAISE no_data_found;
  END IF;
END UPDATE_ROW;
---- End UPDATE_ROW Procedure ----------+

---- Start DELETE_ROW Procedure -----+
PROCEDURE DELETE_ROW (X_CONTEXT_ID  IN NUMBER )
IS
BEGIN
  DELETE FROM IBE_DSP_CONTEXT_TL
   WHERE CONTEXT_ID = X_CONTEXT_ID;

  IF (sql%notfound)
  THEN
    RAISE no_data_found;
  END IF;

  DELETE FROM IBE_DSP_CONTEXT_B
   WHERE CONTEXT_ID = X_CONTEXT_ID;

  IF (sql%notfound)
  THEN
    RAISE no_data_found;
  END IF;
END DELETE_ROW;
--- End DELETE_ROW Procedure ----+

-- Start TRANSLATE_ROW Procedure --+
PROCEDURE TRANSLATE_ROW (
                         X_CONTEXT_ID           in      NUMBER,
                         X_OWNER                in      VARCHAR2,
                         X_NAME                 in      VARCHAR2,
                         X_DESCRIPTION          in      VARCHAR2,
                         X_LAST_UPDATE_DATE     in      VARCHAR2,
                         X_CUSTOM_MODE          in      VARCHAR2 )
IS
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file

BEGIN

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  UPDATE ibe_dsp_context_tl
     SET language = USERENV('LANG'),
         source_lang = USERENV('LANG'),
         name = X_NAME,
         description = X_DESCRIPTION,
         last_updated_by  = decode(X_OWNER,'SEED',1,0),
         last_update_date = f_ludate,
         last_update_login= f_luby
   WHERE USERENV('LANG') IN (language,source_lang)
     AND context_id = X_CONTEXT_ID;

END TRANSLATE_ROW;
---- End TRANSLATE_ROW Procedure ----+

----- Start LOAD_ROW Procedure ---+
PROCEDURE LOAD_ROW (
                    X_CONTEXT_ID                in      NUMBER,
                    X_OWNER                     in      VARCHAR2,
                    X_OBJECT_VERSION_NUMBER     in      NUMBER,
                    X_ACCESS_NAME               in      VARCHAR2,
                    X_CONTEXT_TYPE_CODE         in      VARCHAR2,
                    X_ITEM_ID                   in      NUMBER,
                    X_NAME                      in      VARCHAR2,
                    X_DESCRIPTION               in      VARCHAR2,
                    X_LAST_UPDATE_DATE          in      VARCHAR2,
                    X_CUSTOM_MODE               in      VARCHAR2,
                    X_COMPONENT_TYPE_CODE       in      VARCHAR2)
IS
  Owner_id      NUMBER := 0;
  Row_Id        VARCHAR2(64);
  f_luby        NUMBER;  -- entity owner in file
  f_ludate      DATE;    -- entity update date in file
  db_luby       NUMBER;  -- entity owner in db
  db_ludate     DATE;    -- entity update date in db

  CURSOR c_get_context_csr(c_access_name VARCHAR2,
    c_context_type_code VARCHAR2) IS
    SELECT context_id
         FROM ibe_dsp_context_b
     WHERE access_name = c_access_name
          AND context_type_code = c_context_type_code;
  l_temp NUMBER;
BEGIN
  IF X_OWNER = 'SEED'
  THEN
    Owner_id := 1;
  END IF;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

   -- get the value of the db_luby and db_ludate from the database
   select LAST_UPDATED_BY, LAST_UPDATE_DATE
        into db_luby, db_ludate
        from IBE_DSP_CONTEXT_B
        where CONTEXT_ID = X_CONTEXT_ID;
--Invoke standard merge comparison routine UPLOAD_TEST to determine whether to upload or not

 IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
 THEN
  UPDATE_ROW (
    X_CONTEXT_ID                =>  X_CONTEXT_ID,
    X_OBJECT_VERSION_NUMBER     =>  X_OBJECT_VERSION_NUMBER,
    X_ACCESS_NAME               =>  X_ACCESS_NAME,
    X_CONTEXT_TYPE_CODE         =>  X_CONTEXT_TYPE_CODE,
    X_ITEM_ID                   =>  X_ITEM_ID,
    X_NAME                      =>  X_NAME,
    X_DESCRIPTION               =>  X_DESCRIPTION,
    X_LAST_UPDATE_DATE          =>  f_ludate,
    X_LAST_UPDATED_BY           =>  f_luby,
    X_LAST_UPDATE_LOGIN         =>  f_luby,
    X_COMPONENT_TYPE_CODE => X_COMPONENT_TYPE_CODE);
 END IF;
EXCEPTION
   WHEN no_data_found
   THEN
        l_temp := 1;
     IF (x_access_name = 'STORE_SECTION_ADDTL_INFO'
           OR x_access_name = 'STORE_PRODUCT_ADDTL_INFO')
       AND (x_context_type_code = 'MEDIA') THEN
          OPEN c_get_context_csr(x_access_name, x_context_type_code);
          FETCH c_get_context_csr INTO l_temp;
          IF (c_get_context_csr%FOUND) THEN
            l_temp := 0;
       ELSE
            l_temp := 1;
          END IF;
          CLOSE c_get_context_csr;
     END IF;
        IF (l_temp = 1) THEN
     INSERT_ROW(
     X_ROWID                    => Row_id,
     X_CONTEXT_ID               => X_CONTEXT_ID,
     X_OBJECT_VERSION_NUMBER    => X_OBJECT_VERSION_NUMBER,
     X_ACCESS_NAME              => X_ACCESS_NAME,
     X_CONTEXT_TYPE_CODE        => X_CONTEXT_TYPE_CODE,
     X_ITEM_ID                  => X_ITEM_ID,
     X_NAME                     => X_NAME,
     X_DESCRIPTION              => X_DESCRIPTION,
     X_CREATION_DATE            => f_ludate,
     X_CREATED_BY               => f_luby,
     X_LAST_UPDATE_DATE         => f_ludate,
     X_LAST_UPDATED_BY          => f_luby,
     X_LAST_UPDATE_LOGIN        => f_luby,
     X_COMPONENT_TYPE_CODE => X_COMPONENT_TYPE_CODE);
     END IF;
END LOAD_ROW;
----- End LOAD_ROW_PROCEDURE -----+

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM IBE_DSP_CONTEXT_TL T
   WHERE NOT EXISTS(
                     SELECT NULL
                       FROM IBE_DSP_CONTEXT_B B
                      WHERE B.CONTEXT_ID = T.CONTEXT_ID );

  UPDATE IBE_DSP_CONTEXT_TL T
    SET (NAME,DESCRIPTION) =
        (SELECT B.NAME,
                B.DESCRIPTION
           FROM IBE_DSP_CONTEXT_TL B
          WHERE B.CONTEXT_ID = T.CONTEXT_ID
            AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.CONTEXT_ID,T.LANGUAGE) IN
           (SELECT SUBT.CONTEXT_ID,
                   SUBT.LANGUAGE
              FROM IBE_DSP_CONTEXT_TL SUBB,
                   IBE_DSP_CONTEXT_TL SUBT
             WHERE SUBB.CONTEXT_ID = SUBT.CONTEXT_ID
               AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
               AND (SUBB.NAME <> SUBT.NAME OR
                   (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                OR (SUBB.DESCRIPTION IS NOT NULL AND
                    SUBT.DESCRIPTION IS NULL)));

  INSERT INTO IBE_DSP_CONTEXT_TL (
    CONTEXT_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG )
    SELECT
      B.CONTEXT_ID,
      B.OBJECT_VERSION_NUMBER,
      B.CREATED_BY,
      B.CREATION_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATE_LOGIN,
      B.NAME,
      B.DESCRIPTION,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
      FROM
        IBE_DSP_CONTEXT_TL B,
        FND_LANGUAGES L
      	WHERE L.INSTALLED_FLAG IN ('I', 'B')
        AND B.LANGUAGE = USERENV('LANG')
        AND NOT EXISTS
                (SELECT NULL
                   FROM IBE_DSP_CONTEXT_TL T
                  WHERE T.CONTEXT_ID = B.CONTEXT_ID
                    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;


Procedure LOAD_SEED_ROW(
                        X_CONTEXT_ID                  in VARCHAR2,
                        X_OWNER                       in VARCHAR2,
                        X_OBJECT_VERSION_NUMBER       in VARCHAR2,
                        X_ACCESS_NAME                 in VARCHAR2,
                        X_CONTEXT_TYPE_CODE           in VARCHAR2,
                        X_ITEM_ID                     in VARCHAR2,
                        X_NAME                        in VARCHAR2,
                        X_DESCRIPTION                 in VARCHAR2,
                        X_COMPONENT_TYPE_CODE         in VARCHAR2,
                        X_LAST_UPDATE_DATE            in VARCHAR2,
                        X_CUSTOM_MODE                 in VARCHAR2,
                        X_UPLOAD_MODE                 in VARCHAR2)
is

Begin
    if ( x_upload_mode = 'NLS') then
         IBE_DisplayContext_GRP.TRANSLATE_ROW(
                to_number(X_CONTEXT_ID),
                X_OWNER,
                X_NAME,
                X_DESCRIPTION,
                X_LAST_UPDATE_DATE,
                X_CUSTOM_MODE );
    Else
         IBE_DisplayContext_GRP.LOAD_ROW(
                to_number(X_CONTEXT_ID),
                X_OWNER,
                to_number(X_OBJECT_VERSION_NUMBER),
                X_ACCESS_NAME,
                X_CONTEXT_TYPE_CODE,
                to_number(X_ITEM_ID),
                X_NAME,
                X_DESCRIPTION,
                X_LAST_UPDATE_DATE,
                X_CUSTOM_MODE,
                X_COMPONENT_TYPE_CODE );
    End If;

END  LOAD_SEED_ROW;
END IBE_DisplayContext_GRP;

/
