--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_INSTANCES_PKG" as
/* $Header: AFOAMDSCINSTB.pls 120.1 2005/12/19 09:51 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCFG_INSTANCES_PKG.';

   TYPE b_config_instance_cache_type IS RECORD
      (
       initialized              BOOLEAN         := FALSE,
       config_instance_id       NUMBER          := NULL,
       target_dbname            VARCHAR2(30)    := NULL,
       config_instance_type     VARCHAR2(30)    := NULL,
       last_imported            DATE            := NULL,
       import_duration          NUMBER          := NULL,
       last_compiled            DATE            := NULL,
       compile_duration         NUMBER          := NULL,
       source_dbname            VARCHAR2(30)    := NULL,
       clone_key                VARCHAR2(1040)  := NULL,
       policyset_id             NUMBER(15)      := NULL
       );
   b_config_instance_info       b_config_instance_cache_type;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION IS_INITIALIZED
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN b_config_instance_info.initialized;
   END;

   -- Public
   FUNCTION GET_CURRENT_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.config_instance_id;
   END;

   -- Public
   FUNCTION GET_CURRENT_TYPE
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.config_instance_type;
   END;

   -- Public
   FUNCTION GET_CURRENT_SOURCE_DBNAME
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.source_dbname;
   END;

   -- Public
   FUNCTION GET_CURRENT_CLONE_KEY
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.clone_key;
   END;

   -- Public
   FUNCTION GET_CURRENT_POLICYSET_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.policyset_id;
   END;

   -- Public
   PROCEDURE SET_LAST_IMPORTED(p_last_imported  IN DATE)
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE fnd_oam_dscfg_instances
         SET last_imported = p_last_imported
         WHERE config_instance_id = b_config_instance_info.config_instance_id;

      b_config_instance_info.last_imported := p_last_imported;
   END;

   -- Public
   FUNCTION GET_LAST_IMPORTED
      RETURN DATE
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.last_imported;
   END;

   -- Public
   PROCEDURE SET_IMPORT_DURATION(p_import_duration  IN NUMBER)
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE fnd_oam_dscfg_instances
         SET import_duration = p_import_duration
         WHERE config_instance_id = b_config_instance_info.config_instance_id;

      b_config_instance_info.import_duration := p_import_duration;
   END;

   -- Public
   FUNCTION GET_IMPORT_DURATION
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.import_duration;
   END;


   -- Public
   PROCEDURE SET_LAST_COMPILED(p_last_compiled  IN DATE)
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE fnd_oam_dscfg_instances
         SET last_compiled = p_last_compiled
         WHERE config_instance_id = b_config_instance_info.config_instance_id;

      b_config_instance_info.last_compiled := p_last_compiled;
   END;

   -- Public
   FUNCTION GET_LAST_COMPILED
      RETURN DATE
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.last_compiled;
   END;


   -- Public
   PROCEDURE SET_COMPILE_DURATION(p_compile_duration  IN NUMBER)
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE fnd_oam_dscfg_instances
         SET compile_duration = p_compile_duration
         WHERE config_instance_id = b_config_instance_info.config_instance_id;

      b_config_instance_info.compile_duration := p_compile_duration;
   END;

   -- Public
   FUNCTION GET_COMPILE_DURATION
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_config_instance_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_config_instance_info.compile_duration;
   END;

   -- Public
   FUNCTION CONFIG_INSTANCE_EXISTS(p_target_dbname              IN VARCHAR2,
                                   p_config_instance_type       IN VARCHAR2,
                                   p_clone_key                  IN VARCHAR2     DEFAULT NULL,
                                   p_policyset_id               IN NUMBER       DEFAULT NULL,
                                   x_config_instance_id         OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CONFIG_INSTANCE_EXISTS';

      l_config_instance_id      NUMBER;
      l_found                   BOOLEAN := FALSE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --perform different lookup depending on the config_instance_type
      CASE p_config_instance_type
         WHEN FND_OAM_DSCFG_API_PKG.G_CONFTYPE_CLONING THEN
            SELECT config_instance_id
               INTO l_config_instance_id
               FROM fnd_oam_dscfg_instances
               WHERE config_instance_type = p_config_instance_type
               AND target_dbname = p_target_dbname
               AND clone_key = p_clone_key
               AND ((policyset_id IS NULL) OR (policyset_id = p_policyset_id));
            --if it wasn't found, an exception was thrown
            x_config_instance_id := l_config_instance_id;
            l_found := TRUE;
      END CASE;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN l_found;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN TOO_MANY_ROWS THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- Private
   -- Helper to CREATE/USE_CONFIG_INSTANCE to initialize the package state
   PROCEDURE INIT_STATE(p_config_instance_id    IN NUMBER,
                        p_target_dbname         IN VARCHAR2,
                        p_config_instance_type  IN VARCHAR2,
                        p_last_imported         IN DATE         DEFAULT NULL,
                        p_import_duration       IN NUMBER       DEFAULT NULL,
                        p_last_compiled         IN DATE         DEFAULT NULL,
                        p_compile_duration      IN NUMBER       DEFAULT NULL,
                        p_source_dbname         IN VARCHAR2     DEFAULT NULL,
                        p_clone_key             IN VARCHAR2     DEFAULT NULL,
                        p_policyset_id          IN NUMBER       DEFAULT NULL)
   IS
   BEGIN
      b_config_instance_info.config_instance_id         := p_config_instance_id;
      b_config_instance_info.target_dbname              := p_target_dbname;
      b_config_instance_info.config_instance_type       := p_config_instance_type;
      b_config_instance_info.last_imported              := p_last_imported;
      b_config_instance_info.import_duration            := p_import_duration;
      b_config_instance_info.last_compiled              := p_last_compiled;
      b_config_instance_info.compile_duration           := p_compile_duration;
      b_config_instance_info.source_dbname              := p_source_dbname;
      b_config_instance_info.clone_key                  := p_clone_key;
      b_config_instance_info.policyset_id               := p_policyset_id;
      b_config_instance_info.initialized                := TRUE;
   END;

   -- Public
   PROCEDURE ADD_CONFIG_INSTANCE(p_target_dbname        IN VARCHAR2,
                                 p_config_instance_type IN VARCHAR2,
                                 p_name                 IN VARCHAR2,
                                 p_description          IN VARCHAR2,
                                 p_language             IN VARCHAR2,
                                 p_source_dbname        IN VARCHAR2,
                                 p_clone_key            IN VARCHAR2,
                                 p_policyset_id         IN NUMBER,
                                 x_config_instance_id   OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_CONFIG_INSTANCE';

      l_config_instance_id      NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first check if we're allowed to make config changes
      IF NOT FND_OAM_DSCFG_API_PKG.ARE_CONFIG_CHANGES_ALLOWED THEN
         --raise a program error
         fnd_oam_debug.log(6, l_ctxt, 'Scrambling Configuration changes currently not allowed.');
         RAISE PROGRAM_ERROR;
      END IF;

      --do the insert
      INSERT INTO fnd_oam_dscfg_instances (CONFIG_INSTANCE_ID,
                                           TARGET_DBNAME,
                                           CONFIG_INSTANCE_TYPE,
                                           NAME,
                                           DESCRIPTION,
                                           LANGUAGE,
                                           SOURCE_DBNAME,
                                           CLONE_KEY,
                                           POLICYSET_ID,
                                           CREATED_BY,
                                           CREATION_DATE,
                                           LAST_UPDATED_BY,
                                           LAST_UPDATE_DATE,
                                           LAST_UPDATE_LOGIN)
         VALUES (FND_OAM_DSCFG_INSTANCES_S.NEXTVAL,
                 p_target_dbname,
                 p_config_instance_type,
                 p_name,
                 p_description,
                 NVL(p_language, USERENV('LANG')),
                 p_source_dbname,
                 p_clone_key,
                 p_policyset_id,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID)
         RETURNING CONFIG_INSTANCE_ID INTO l_config_instance_id;

      --success, init the state and commit
      INIT_STATE(p_config_instance_id   => l_config_instance_id,
                 p_target_dbname        => p_target_dbname,
                 p_config_instance_type => p_config_instance_type,
                 p_source_dbname        => p_source_dbname,
                 p_clone_key            => p_clone_key,
                 p_policyset_id         => p_policyset_id);
      x_config_instance_id := l_config_instance_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE SET_CURRENT_CONFIG_INSTANCE(p_config_instance_id   IN NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'SET_CURRENT_CONFIG_INSTANCE';

      l_target_dbname           VARCHAR2(30);
      l_config_instance_type    VARCHAR2(30);
      l_last_imported           DATE;
      l_import_duration         NUMBER;
      l_last_compiled           DATE;
      l_compile_duration        NUMBER;
      l_source_dbname           VARCHAR2(30);
      l_clone_key               VARCHAR2(1040);
      l_policyset_id            NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first check if we're allowed to make config changes
      IF NOT FND_OAM_DSCFG_API_PKG.ARE_CONFIG_CHANGES_ALLOWED THEN
         --raise a program error
         fnd_oam_debug.log(6, l_ctxt, 'Scrambling Configuration changes currently not allowed.');
         RAISE PROGRAM_ERROR;
      END IF;

      --query out the instance attributes
      SELECT target_dbname, config_instance_type, last_imported, import_duration, last_compiled, compile_duration, source_dbname, clone_key, policyset_id
         INTO l_target_dbname, l_config_instance_type, l_last_imported, l_import_duration, l_last_compiled, l_compile_duration, l_source_dbname, l_clone_key, l_policyset_id
         FROM fnd_oam_dscfg_instances
         WHERE config_instance_id = p_config_instance_id;

      --set the state
      INIT_STATE(p_config_instance_id   => p_config_instance_id,
                 p_target_dbname        => l_target_dbname,
                 p_config_instance_type => l_config_instance_type,
                 p_last_imported        => l_last_imported,
                 p_import_duration      => l_import_duration,
                 p_last_compiled        => l_last_compiled,
                 p_compile_duration     => l_compile_duration,
                 p_source_dbname        => l_source_dbname,
                 p_clone_key            => l_clone_key,
                 p_policyset_id         => l_policyset_id);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   FUNCTION DELETE_CONFIG_INSTANCE(p_config_instance_id IN NUMBER,
                                   p_recurse_config     IN VARCHAR2 DEFAULT NULL,
                                   p_recurse_engine     IN VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_CONFIG_INSTANCE';

      l_run_ids         DBMS_SQL.NUMBER_TABLE;
      l_object_ids      DBMS_SQL.NUMBER_TABLE;

      k                 NUMBER;
      l_failed          BOOLEAN := FALSE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first nuke the dscram runs
      IF p_recurse_engine IS NOT NULL AND p_recurse_engine = FND_API.G_TRUE THEN
         SELECT run_id
            BULK COLLECT INTO l_run_ids
            FROM fnd_oam_dscram_runs_b
            WHERE config_instance_id = p_config_instance_id;

         fnd_oam_debug.log(1, l_ctxt, 'Deleting '||l_run_ids.COUNT||' engine runs...');
         k := l_run_ids.FIRST;
         WHILE k IS NOT NULL LOOP
            IF NOT FND_OAM_DSCRAM_UTILS_PKG.DELETE_RUN(l_run_ids(k)) THEN
               l_failed := TRUE;
               EXIT;
            END IF;
            k := l_run_ids.NEXT(k);
         END LOOP;

         --see if we failed, if so don't delete the instance
         IF l_failed THEN
            RETURN FALSE;
         END IF;
      END IF;

      --next nuke the objects
      IF p_recurse_config IS NOT NULL AND p_recurse_config = FND_API.G_TRUE THEN
         SELECT object_id
            BULK COLLECT INTO l_object_ids
            FROM fnd_oam_dscfg_objects
            WHERE config_instance_id = p_config_instance_id;

         fnd_oam_debug.log(1, l_ctxt, 'Deleting '||l_object_ids.COUNT||' configuration objects...');
         k := l_object_ids.FIRST;
         WHILE k IS NOT NULL LOOP
            IF NOT FND_OAM_DSCFG_OBJECTS_PKG.DELETE_OBJECT(l_object_ids(k),
                                                           p_recurse_config) THEN
               l_failed := TRUE;
               EXIT;
            END IF;
            k := l_object_ids.NEXT(k);
         END LOOP;

         --see if we failed, if so don't delete the instance
         IF l_failed THEN
            RETURN FALSE;
         END IF;
      END IF;

      --now delete the config instance
      fnd_oam_debug.log(1, l_ctxt, 'Deleting the instance row');
      DELETE FROM fnd_oam_dscfg_instances
         WHERE config_instance_id = p_config_instance_id;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

END FND_OAM_DSCFG_INSTANCES_PKG;

/
