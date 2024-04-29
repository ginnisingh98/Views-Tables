--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_OBJECTS_PKG" as
/* $Header: AFOAMDSCOBJB.pls 120.2 2006/01/17 11:36 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCFG_OBJECTS_PKG.';

   --stateless, only contains a table handler to insert a new object with no properties

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   PROCEDURE ADD_OBJECT(p_object_type           IN VARCHAR2,
                        p_parent_object_id      IN NUMBER,
                        p_source_type           IN VARCHAR2,
                        p_source_id             IN NUMBER,
                        p_errors_found_flag     IN VARCHAR2,
                        p_message               IN VARCHAR2,
                        x_object_id             OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_OBJECT';

      l_config_instance_id      NUMBER;
      l_proc_id         NUMBER := NULL;

      l_object_id               NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get the config_instance_id, throws error if not initialized
      l_config_instance_id := FND_OAM_DSCFG_INSTANCES_PKG.GET_CURRENT_ID;

      --try to get the import proc id
      IF FND_OAM_DSCFG_PROCS_PKG.IS_INITIALIZED THEN
         l_proc_id := FND_OAM_DSCFG_PROCS_PKG.GET_CURRENT_ID;
      END IF;

      --do the insert
      INSERT INTO fnd_oam_dscfg_objects (OBJECT_ID,
                                         CONFIG_INSTANCE_ID,
                                         OBJECT_TYPE,
                                         PARENT_OBJECT_ID,
                                         SOURCE_PROC_ID,
                                         SOURCE_TYPE,
                                         SOURCE_ID,
                                         ERRORS_FOUND_FLAG,
                                         MESSAGE,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN)
         VALUES (FND_OAM_DSCFG_OBJECTS_S.NEXTVAL,
                 l_config_instance_id,
                 p_object_type,
                 p_parent_object_id,
                 l_proc_id,
                 p_source_type,
                 p_source_id,
                 p_errors_found_flag,
                 p_message,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID)
         RETURNING OBJECT_ID INTO l_object_id;

      x_object_id := l_object_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE GET_OBJECTS_FOR_TYPE(p_object_type         IN VARCHAR2,
                                  x_object_ids          OUT NOCOPY DBMS_SQL.NUMBER_TABLE)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_OBJECTS_FOR_TYPE';

      l_object_ids              DBMS_SQL.NUMBER_TABLE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --do the fetch
      SELECT object_id
         BULK COLLECT INTO l_object_ids
         FROM fnd_oam_dscfg_objects
         WHERE object_type = p_object_type
         ORDER BY object_id asc;

      x_object_ids := l_object_ids;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE GET_OBJECTS_FOR_TYPE(p_object_type         IN VARCHAR2,
                                  p_errors_found_flag   IN VARCHAR2,
                                  x_object_ids          OUT NOCOPY DBMS_SQL.NUMBER_TABLE)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_OBJECTS_FOR_TYPE(errors_found_flag)';

      l_object_ids              DBMS_SQL.NUMBER_TABLE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --do the fetch
      IF p_errors_found_flag IS NULL THEN
         SELECT object_id
            BULK COLLECT INTO l_object_ids
            FROM fnd_oam_dscfg_objects
            WHERE object_type = p_object_type
            AND errors_found_flag IS NULL
            ORDER BY object_id asc;
      ELSE
         SELECT object_id
            BULK COLLECT INTO l_object_ids
            FROM fnd_oam_dscfg_objects
            WHERE object_type = p_object_type
            AND errors_found_flag = p_errors_found_flag
            ORDER BY object_id asc;
      END IF;

      x_object_ids := l_object_ids;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   FUNCTION DELETE_OBJECT(p_object_id   IN NUMBER,
                          p_recurse     IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_OBJECT';

      l_prop_ids        DBMS_SQL.NUMBER_TABLE;

      k                 NUMBER;
      l_failed          BOOLEAN := FALSE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first nuke the properties
      IF p_recurse IS NOT NULL AND p_recurse = FND_API.G_TRUE THEN
         --delete all the leaf properties at once.
         IF NOT FND_OAM_DSCFG_PROPERTIES_PKG.DELETE_PROPERTIES(FND_OAM_DSCFG_API_PKG.G_TYPE_OBJECT,
                                                               p_object_id) THEN
            RETURN FALSE;
         END IF;
      END IF;

      --now delete the object
      DELETE FROM fnd_oam_dscfg_objects
         WHERE object_id = p_object_id;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

END FND_OAM_DSCFG_OBJECTS_PKG;

/
