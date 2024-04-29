--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_PROC_LIBRARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_PROC_LIBRARY_PKG" as
/* $Header: AFOAMDSCPROCLIBB.pls 120.3 2006/05/04 14:30 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(30) := 'DSCFG_PROC_LIBRARY_PKG.';

   -- Object Types
   B_OTYPE_DISABLED_TRIGGER         CONSTANT VARCHAR2(30) := FND_OAM_DSCFG_API_PKG.G_INTERNAL_PREFIX||'DISABLED_TRIGGER';
   B_OTYPE_DISABLED_PRIMARY_KEY     CONSTANT VARCHAR2(30) := FND_OAM_DSCFG_API_PKG.G_INTERNAL_PREFIX||'DISABLED_PRIMARY_KEY';

   -- Property_Names
   B_PROP_TRIGGER_OWNER                 CONSTANT VARCHAR2(30) := 'TRIGGER_OWNER';
   B_PROP_TRIGGER_NAME                  CONSTANT VARCHAR2(30) := 'TRIGGER_NAME';
   B_PROP_TRIGGER_DISABLED_DATE         CONSTANT VARCHAR2(30) := 'TRIGGER_DISABLED_DATE';
   B_PROP_TRIGGER_RE_ENABLED_DATE       CONSTANT VARCHAR2(30) := 'TRIGGER_RE_ENABLED_DATE';

   B_PROP_PRIM_KEY_TABLE_OWNER          CONSTANT VARCHAR2(60) := 'PRIMARY_KEY_TABLE_OWNER';
   B_PROP_PRIM_KEY_TABLE_NAME           CONSTANT VARCHAR2(60) := 'PRIMARY_KEY_TABLE_NAME';
   B_PROP_PRIM_KEY_DISABLED_DATE        CONSTANT VARCHAR2(60) := 'PRIMARY_KEY_DISABLED_DATE';
   B_PROP_PRIM_KEY_ENABLED_DATE         CONSTANT VARCHAR2(60) := 'PRIMARY_KEY_RE_ENABLED_DATE';

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Update object with an error message
   PROCEDURE UPDATE_OBJECT_WITH_ERROR(p_ctxt            IN VARCHAR2,
                                      p_object_id       IN NUMBER,
                                      p_message         IN VARCHAR2)
   IS
      l_msg     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(3, p_ctxt, p_message);
      l_msg := '['||p_ctxt||']'||p_message;
      UPDATE fnd_oam_dscfg_objects
         SET errors_found_flag = FND_API.G_TRUE,
             message = l_msg
         WHERE object_id = p_object_id;
   END;

   --Wrapper for unhandled exceptions
   PROCEDURE UPDATE_OBJECT_WITH_ERROR(p_ctxt            IN VARCHAR2,
                                      p_object_id       IN NUMBER,
                                      p_error_code      IN NUMBER,
                                      p_error_msg       IN VARCHAR2)
   IS
      l_msg     VARCHAR2(4000);
   BEGIN
      l_msg := 'Exception: (Code('||p_error_code||'), Message("'||p_error_msg||'"))';
      UPDATE_OBJECT_WITH_ERROR(p_ctxt,
                               p_object_id,
                               l_msg);
   END;

   -- Update object with warning message
   PROCEDURE UPDATE_OBJECT_WITH_WARNING(p_ctxt          IN VARCHAR2,
                                        p_object_id     IN NUMBER,
                                        p_message       IN VARCHAR2)
   IS
      l_msg     VARCHAR2(4000);
   BEGIN
      l_msg := 'WARNING: '||p_message;
      fnd_oam_debug.log(1, p_ctxt, l_msg);
      UPDATE fnd_oam_dscfg_objects
         SET errors_found_flag = NULL,
             message = l_msg
         WHERE object_id = p_object_id;
   END;

   -- Update object with status success
   PROCEDURE UPDATE_OBJECT_WITH_SUCCESS(p_ctxt          IN VARCHAR2,
                                        p_object_id     IN NUMBER)
   IS
   BEGIN
      UPDATE fnd_oam_dscfg_objects
         SET errors_found_flag = FND_API.G_FALSE,
             message = NULL
         WHERE object_id = p_object_id;
   END;

   -- Public
   PROCEDURE DISABLE_TARGET_TABLES_TRIGGERS
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DISABLE_TARGET_TABLES_TRIGGERS';

      l_table_owners            DBMS_SQL.VARCHAR2_TABLE;
      l_table_names             DBMS_SQL.VARCHAR2_TABLE;

      l_object_id               NUMBER;
      l_property_id             NUMBER;

      k                         NUMBER;
      l_disabled                NUMBER := 0;
      l_seen                    NUMBER := 0;

      -- cursor to query the triggers enabled for a given table owner/name
      CURSOR c_table_triggers(p_table_owner     VARCHAR2,
                              p_table_name      VARCHAR2)
      IS
         SELECT owner as trigger_owner, trigger_name
         FROM   dba_triggers
         WHERE  table_owner = p_table_owner
         AND    table_name = p_table_name
         AND    status = 'ENABLED';
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get the owners/tables in scope of the engine
      FND_OAM_DSCFG_API_PKG.GET_CURRENT_TARGET_TABLE_LIST(x_table_owners        => l_table_owners,
                                                          x_table_names         => l_table_names);
      fnd_oam_debug.log(1, l_ctxt, 'Found '||l_table_owners.COUNT||' candidate target tables.');

      -- iterate across the tables found
      k := l_table_owners.FIRST;
      WHILE k IS NOT NULL LOOP
         -- only process if a corresponding names entry is present
         IF l_table_names.EXISTS(k) THEN
            FOR l_trig IN c_table_triggers(l_table_owners(k), l_table_names(k)) LOOP
               l_seen := l_seen + 1;
               fnd_oam_debug.log(1, l_ctxt, 'Processing Trigger('||l_seen||'): '||l_trig.trigger_owner||'.'||l_trig.trigger_name);

               fnd_oam_debug.log(1, l_ctxt, 'Creating corresponding dscfg_object...');
               --create the disabled trigger object first since the alter trigger call is immediate
               FND_OAM_DSCFG_API_PKG.ADD_OBJECT(p_object_type   => B_OTYPE_DISABLED_TRIGGER,
                                                x_object_id     => l_object_id);

               --keep the object creation above the alter trigger since we want this object if the alter suceeds or fails.
               --and properties for the trigger owner/name and when we disabled it
               FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id            => l_object_id,
                                                         p_property_name        => B_PROP_TRIGGER_OWNER,
                                                         p_varchar2_value       => l_trig.trigger_owner,
                                                         x_property_id          => l_property_id);
               FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id            => l_object_id,
                                                         p_property_name        => B_PROP_TRIGGER_NAME,
                                                         p_varchar2_value       => l_trig.trigger_name,
                                                         x_property_id          => l_property_id);
               FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id            => l_object_id,
                                                         p_property_name        => B_PROP_TRIGGER_DISABLED_DATE,
                                                         p_date_value           => SYSDATE,
                                                         x_property_id          => l_property_id);

               fnd_oam_debug.log(1, l_ctxt, 'Disabling the actual trigger...');

               -- disable the trigger
               BEGIN
                  EXECUTE IMMEDIATE 'ALTER TRIGGER '||l_trig.trigger_owner||'.'||l_trig.trigger_name||' DISABLE';
                  fnd_oam_debug.log(1, l_ctxt, 'Trigger disabled.');
                  l_disabled := l_disabled + 1;
               EXCEPTION
                  WHEN OTHERS THEN
                     --don't rollback so we can commit the error along with the object
                     UPDATE_OBJECT_WITH_ERROR(l_ctxt,
                                              l_object_id,
                                              SQLCODE,
                                              SQLERRM);
               END;

               -- commit the object/props since the execute succeeded
               COMMIT;

               fnd_oam_debug.log(1, l_ctxt, 'Processing finished.');
            END LOOP;
         END IF;
         k := l_table_owners.NEXT(k);
      END LOOP;
      fnd_oam_debug.log(1, l_ctxt, 'Disabled '||l_disabled||' of '||l_seen||' triggers.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE RE_ENABLE_DISABLED_TRIGGERS
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'RE_ENABLE_DISABLED_TRIGGERS';

      l_object_ids              DBMS_SQL.NUMBER_TABLE;

      l_trigger_owner           VARCHAR2(30);
      l_trigger_name            VARCHAR2(30);

      l_property_id             NUMBER;
      l_enabled                 NUMBER := 0;
      l_seen                    NUMBER := 0;

      k                         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get all objects representing disabled triggers which don't have errors(flag=T) or have already been
      --processed(flag=F).
      FND_OAM_DSCFG_API_PKG.GET_OBJECTS_FOR_TYPE(p_object_type          => B_OTYPE_DISABLED_TRIGGER,
                                                 p_errors_found_flag    => NULL,
                                                 x_object_ids           => l_object_ids);
      fnd_oam_debug.log(1, l_ctxt, 'Found '||l_object_ids.COUNT||' processable disabled trigger objects.');

      -- iterate across the objects found
      k := l_object_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         --get the trigger owner/name properties
         FND_OAM_DSCFG_API_PKG.GET_OBJECT_PROPERTY_VALUE(p_object_id            => l_object_ids(k),
                                                         p_property_name        => B_PROP_TRIGGER_OWNER,
                                                         x_varchar2_value       => l_trigger_owner);
         FND_OAM_DSCFG_API_PKG.GET_OBJECT_PROPERTY_VALUE(p_object_id            => l_object_ids(k),
                                                         p_property_name        => B_PROP_TRIGGER_NAME,
                                                         x_varchar2_value       => l_trigger_name);
         l_seen := l_seen + 1;
         fnd_oam_debug.log(1, l_ctxt, 'Processing Trigger('||l_seen||'): '||l_trigger_owner||'.'||l_trigger_name);


         -- re-enable the trigger
         fnd_oam_debug.log(1, l_ctxt, 'Performing the trigger enable...');
         BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER '||l_trigger_owner||'.'||l_trigger_name||' ENABLE';
            fnd_oam_debug.log(1, l_ctxt, 'Trigger re-enabled.');
            --add property for when the trigger was re-enabled
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id          => l_object_ids(k),
                                                      p_property_name      => B_PROP_TRIGGER_RE_ENABLED_DATE,
                                                      p_date_value         => SYSDATE,
                                                      x_property_id        => l_property_id);
            UPDATE_OBJECT_WITH_SUCCESS(l_ctxt,
                                       l_object_ids(k));
            l_enabled := l_enabled + 1;
         EXCEPTION
            WHEN OTHERS THEN
               --log the error
               UPDATE_OBJECT_WITH_ERROR(l_ctxt,
                                        l_object_ids(k),
                                        SQLCODE,
                                        SQLERRM);
         END;
         fnd_oam_debug.log(1, l_ctxt, 'Processing finished.');

         -- save the success or error flag/message
         COMMIT;

         k := l_object_ids.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(1, l_ctxt, 'Re-enabled '||l_enabled||' of '||l_seen||' triggers.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN TOO_MANY_ROWS THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE DISABLE_TARGET_PRIMARY_KEYS
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DISABLE_TARGET_PRIMARY_KEYS';

      TABLE_DOES_NOT_EXIST      EXCEPTION;
      PRAGMA EXCEPTION_INIT(TABLE_DOES_NOT_EXIST, -942);
      NO_PRIMARY_KEY_DEFINED    EXCEPTION;
      PRAGMA EXCEPTION_INIT(NO_PRIMARY_KEY_DEFINED, -2433);

      l_table_owners            DBMS_SQL.VARCHAR2_TABLE;
      l_table_names             DBMS_SQL.VARCHAR2_TABLE;

      l_object_id               NUMBER;
      l_property_id             NUMBER;
      l_disabled                NUMBER := 0;
      l_seen                    NUMBER := 0;
      l_commit                  BOOLEAN;

      k                         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get the owners/tables in scope of the engine
      FND_OAM_DSCFG_API_PKG.GET_CURRENT_TARGET_TABLE_LIST(x_table_owners        => l_table_owners,
                                                          x_table_names         => l_table_names);
      fnd_oam_debug.log(1, l_ctxt, 'Found '||l_table_owners.COUNT||' candidate target tables.');

      -- iterate across the tables found
      k := l_table_owners.FIRST;
      WHILE k IS NOT NULL LOOP
         -- only process if a corresponding names entry is present
         IF l_table_names.EXISTS(k) THEN
            l_seen := l_seen + 1;
            fnd_oam_debug.log(1, l_ctxt, 'Processing Table('||l_seen||'): '||l_table_owners(k)||'.'||l_table_names(k));

            fnd_oam_debug.log(1, l_ctxt, 'Disabling any primary key constraint(s)...');

            -- disable the primary key
            l_commit := TRUE;
            l_object_id := NULL;
            BEGIN
               EXECUTE IMMEDIATE 'ALTER TABLE '||l_table_owners(k)||'.'||l_table_names(k)||' DISABLE PRIMARY KEY CASCADE';
               fnd_oam_debug.log(1, l_ctxt, 'Primary Key(s) disabled.');

               l_disabled := l_disabled + 1;
            EXCEPTION
               WHEN NO_PRIMARY_KEY_DEFINED THEN
                  --don't need an entry
                  fnd_oam_debug.log(1, l_ctxt, 'No primary keys defined - skipping.');
                  l_commit := FALSE;
               WHEN TABLE_DOES_NOT_EXIST THEN
                  --also don't need an entry
                  fnd_oam_debug.log(1, l_ctxt, 'Table does not exist - skipping.');
                  l_commit := FALSE;
               WHEN OTHERS THEN
                  --create the object and store the error message
                  FND_OAM_DSCFG_API_PKG.ADD_OBJECT(p_object_type   => B_OTYPE_DISABLED_PRIMARY_KEY,
                                                   x_object_id     => l_object_id);
                  UPDATE_OBJECT_WITH_ERROR(l_ctxt,
                                           l_object_id,
                                           SQLCODE,
                                           SQLERRM);
            END;

            -- if we have things to commit, add the other properties and commit it all
            IF l_commit THEN
               --create the object if we haven't already created an errored object
               IF l_object_id IS NULL THEN
                  fnd_oam_debug.log(1, l_ctxt, 'Creating corresponding dscfg_object...');
                  FND_OAM_DSCFG_API_PKG.ADD_OBJECT(p_object_type   => B_OTYPE_DISABLED_PRIMARY_KEY,
                                                   x_object_id     => l_object_id);
               END IF;

               --and properties for the primary key owner/name and when we disabled it
               FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id            => l_object_id,
                                                         p_property_name        => B_PROP_PRIM_KEY_TABLE_OWNER,
                                                         p_varchar2_value       => l_table_owners(k),
                                                         x_property_id          => l_property_id);
               FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id            => l_object_id,
                                                         p_property_name        => B_PROP_PRIM_KEY_TABLE_NAME,
                                                         p_varchar2_value       => l_table_names(k),
                                                         x_property_id          => l_property_id);
               FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id            => l_object_id,
                                                         p_property_name        => B_PROP_PRIM_KEY_DISABLED_DATE,
                                                         p_date_value           => SYSDATE,
                                                         x_property_id          => l_property_id);
               fnd_oam_debug.log(1, l_ctxt, 'Comitting.');
               COMMIT;
            END IF;

            fnd_oam_debug.log(1, l_ctxt, 'Processing finished.');
         END IF;
         k := l_table_owners.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(1, l_ctxt, 'Disabled '||l_disabled||' of '||l_seen||' table primary keys.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE ENABLE_DISABLED_PRIMARY_KEYS
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ENABLE_DISABLED_PRIMARY_KEYS';

      l_object_ids              DBMS_SQL.NUMBER_TABLE;

      l_table_owner             VARCHAR2(30);
      l_table_name              VARCHAR2(30);
      l_enabled                 NUMBER := 0;
      l_seen                    NUMBER := 0;

      l_property_id             NUMBER;
      k                         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get all objects representing disabled primary keys
      FND_OAM_DSCFG_API_PKG.GET_OBJECTS_FOR_TYPE(p_object_type          => B_OTYPE_DISABLED_PRIMARY_KEY,
                                                 p_errors_found_flag    => NULL,
                                                 x_object_ids           => l_object_ids);
      fnd_oam_debug.log(1, l_ctxt, 'Found '||l_object_ids.COUNT||' processable disabled primary key objects.');

      -- iterate across the objects found
      k := l_object_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         --get the primary key table owner/name properties
         FND_OAM_DSCFG_API_PKG.GET_OBJECT_PROPERTY_VALUE(p_object_id            => l_object_ids(k),
                                                         p_property_name        => B_PROP_PRIM_KEY_TABLE_OWNER,
                                                         x_varchar2_value       => l_table_owner);
         FND_OAM_DSCFG_API_PKG.GET_OBJECT_PROPERTY_VALUE(p_object_id            => l_object_ids(k),
                                                         p_property_name        => B_PROP_PRIM_KEY_TABLE_NAME,
                                                         x_varchar2_value       => l_table_name);

         l_seen := l_seen + 1;
         fnd_oam_debug.log(1, l_ctxt, 'Processing Table('||l_seen||'): '||l_table_owner||'.'||l_table_name);

         -- re-enable the primary key(s)
         fnd_oam_debug.log(1, l_ctxt, 'Performing the primary key enable...');
         BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE '||l_table_owner||'.'||l_table_name||' ENABLE PRIMARY KEY';
            fnd_oam_debug.log(1, l_ctxt, 'Primary Key(s) re-enabled.');
            --add property for when the primary key was re-enabled
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id          => l_object_ids(k),
                                                      p_property_name      => B_PROP_PRIM_KEY_ENABLED_DATE,
                                                      p_date_value         => SYSDATE,
                                                      x_property_id        => l_property_id);
            UPDATE_OBJECT_WITH_SUCCESS(l_ctxt,
                                       l_object_ids(k));
            l_enabled := l_enabled + 1;
         EXCEPTION
            WHEN OTHERS THEN
               --log the error
               UPDATE_OBJECT_WITH_ERROR(l_ctxt,
                                        l_object_ids(k),
                                        SQLCODE,
                                        SQLERRM);
         END;
         fnd_oam_debug.log(1, l_ctxt, 'Processing finished.');

         COMMIT;

         k := l_object_ids.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(1, l_ctxt, 'Re-enabled '||l_enabled||' of '||l_seen||' table primary keys.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN TOO_MANY_ROWS THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;


END FND_OAM_DSCFG_PROC_LIBRARY_PKG;

/
