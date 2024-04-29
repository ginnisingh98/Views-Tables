--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_API_PKG" as
/* $Header: AFOAMDSCAPIB.pls 120.4 2006/01/17 11:31 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCFG_API_PKG.';

   -- Profile option names controlling whether the product is enabled and whether the instance is in a state where
   -- scrambling operations are allowed.
   B_DSCRAM_ENABLED_PROFILE_NAME        CONSTANT VARCHAR2(30) := 'OAM_DSCRAM_ENABLED';
   B_DSCRAM_ALLOWED_PROFILE_NAME        CONSTANT VARCHAR2(30) := 'OAM_DSCRAM_ALLOWED';

   B_PROFILE_ENABLED_VALUE              CONSTANT VARCHAR2(30) := 'YES';

   -- Since this is an API package, this should be pretty much stateless.

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   FUNCTION ARE_CONFIG_CHANGES_ALLOWED
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ARE_CONFIG_CHANGES_ALLOWED';

      l_prof_value      VARCHAR2(20) := NULL;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      -- check that data scrambling is enabled first
      FND_PROFILE.GET(B_DSCRAM_ENABLED_PROFILE_NAME,
                      l_prof_value);
      IF l_prof_value IS NULL OR UPPER(l_prof_value) <> B_PROFILE_ENABLED_VALUE THEN
         RAISE PROGRAM_ERROR;
      END IF;

      -- now check that data scrambling operations are allowed
      l_prof_value := NULL;
      FND_PROFILE.GET(B_DSCRAM_ALLOWED_PROFILE_NAME,
                      l_prof_value);
      IF l_prof_value IS NULL OR UPPER(l_prof_value) <> B_PROFILE_ENABLED_VALUE THEN
         RAISE PROGRAM_ERROR;
      END IF;

      -- success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         --don't push the exception
         RETURN FALSE;
   END;

   -- Public
   -- Convenience wrapper.
   FUNCTION GET_CURRENT_PROC_ID
      RETURN NUMBER
   IS
   BEGIN
      RETURN FND_OAM_DSCFG_PROCS_PKG.GET_CURRENT_ID;
   END;

   -- Public
   -- Convenience wrapper.
   FUNCTION IS_CONFIG_INSTANCE_INITIALIZED
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN FND_OAM_DSCFG_INSTANCES_PKG.IS_INITIALIZED;
   END;

   -- Public
   -- Convenience wrapper.
   FUNCTION GET_CURRENT_CONFIG_INSTANCE_ID
      RETURN NUMBER
   IS
   BEGIN
      RETURN FND_OAM_DSCFG_INSTANCES_PKG.GET_CURRENT_ID;
   END;

   -- Public
   -- Convenience wrapper.
   FUNCTION GET_CURRENT_POLICYSET_ID
      RETURN NUMBER
   IS
   BEGIN
      RETURN FND_OAM_DSCFG_INSTANCES_PKG.GET_CURRENT_POLICYSET_ID;
   END;

   -- Public
   PROCEDURE GET_CURRENT_TARGET_TABLE_LIST(x_table_owners       OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
                                           x_table_names        OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE)
   IS
      l_ctxt                    VARCHAR2(60) := PKG_NAME||'ADD_DML_UPDATE_SEGMENT';

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- make sure we have the state we need
      IF NOT FND_OAM_DSCFG_INSTANCES_PKG.IS_INITIALIZED THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- FIXME: the object_id subselect is ugly and will be repeated in the compiler.  Options include moving
      -- the sub-select into a view.  Real fix is support for using PL/SQL tables in a SQL 'IN'.

      -- select out all distinct table_owner/table_name combinations for compilable objects
      SELECT DISTINCT p1.canonical_value, p2.canonical_value
         BULK COLLECT INTO x_table_owners, x_table_names
         FROM (SELECT object_id
               FROM fnd_oam_dscfg_objects
               WHERE config_instance_id = FND_OAM_DSCFG_INSTANCES_PKG.GET_CURRENT_ID
               AND object_type in (G_OTYPE_DML_UPDATE_SEGMENT,
                                   G_OTYPE_DML_DELETE_STMT,
                                   G_OTYPE_DML_TRUNCATE_STMT,
                                   G_OTYPE_PLSQL_TEXT)) o,
         fnd_oam_dscfg_properties p1,
         fnd_oam_dscfg_properties p2
         WHERE p1.parent_type = G_TYPE_OBJECT
         AND p1.parent_id = o.object_id
         AND p1.property_name = G_PROP_TABLE_OWNER
         AND p2.parent_type = G_TYPE_OBJECT
         AND p2.parent_id = o.object_id
         AND p2.property_name = G_PROP_TABLE_NAME;

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
   PROCEDURE ADD_DML_UPDATE_SEGMENT(p_table_owner               IN VARCHAR2,
                                    p_table_name                IN VARCHAR2,
                                    p_column_name               IN VARCHAR2,
                                    p_new_column_value          IN VARCHAR2,
                                    p_where_clause              IN VARCHAR2,
                                    p_weight_modifier           IN NUMBER,
                                    p_source_type               IN VARCHAR2,
                                    p_source_id                 IN NUMBER,
                                    x_object_id                 OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_DML_UPDATE_SEGMENT';

      l_object_id       NUMBER;
      l_prop_id         NUMBER;

      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- go ahead and create the object, if there's no config instance it'll throw an exception
      FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT(p_object_type        => G_OTYPE_DML_UPDATE_SEGMENT,
                                           p_source_type        => p_source_type,
                                           p_source_id          => p_source_id,
                                           x_object_id          => l_object_id);

      --now create properties for the arguments
      --table owner
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_TABLE_OWNER,
                                                p_varchar2_value        => p_table_owner,
                                                x_property_id           => l_prop_id);
      --table name
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_TABLE_NAME,
                                                p_varchar2_value        => p_table_name,
                                                x_property_id           => l_prop_id);
      --column name
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_COLUMN_NAME,
                                                p_varchar2_value        => p_column_name,
                                                x_property_id           => l_prop_id);
      --new column value
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_NEW_COLUMN_VALUE,
                                                p_varchar2_value        => p_new_column_value,
                                                x_property_id           => l_prop_id);
      --where clause, only if non-null
      IF p_where_clause IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WHERE_CLAUSE,
                                                   p_varchar2_value     => p_where_clause,
                                                   x_property_id        => l_prop_id);
      END IF;

      --weight_modifier, only if non-null
      IF p_weight_modifier IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WEIGHT_MODIFIER,
                                                   p_varchar2_value     => p_weight_modifier,
                                                   x_property_id        => l_prop_id);
      END IF;
      x_object_id := l_object_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --occurs when create object or prop couldn't find needed state
         x_object_id := NULL;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         x_object_id := NULL;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE ADD_DML_DELETE_STMT(p_table_owner          IN VARCHAR2,
                                 p_table_name           IN VARCHAR2,
                                 p_where_clause         IN VARCHAR2,
                                 p_weight               IN NUMBER,
                                 p_source_type          IN VARCHAR2,
                                 p_source_id            IN NUMBER,
                                 x_object_id            OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_DML_DELETE_STMT';

      l_object_id       NUMBER;
      l_prop_id         NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- go ahead and create the object, if there's no config instance it'll throw an exception
      FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT(p_object_type        => G_OTYPE_DML_DELETE_STMT,
                                           p_source_type        => p_source_type,
                                           p_source_id          => p_source_id,
                                           x_object_id          => l_object_id);
      fnd_oam_debug.log(1, l_ctxt, 'Object Created: '||l_object_id);

      --now create properties for the arguments
      --table owner
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_TABLE_OWNER,
                                                p_varchar2_value        => p_table_owner,
                                                x_property_id           => l_prop_id);
      --table name
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_TABLE_NAME,
                                                p_varchar2_value        => p_table_name,
                                                x_property_id           => l_prop_id);
      --where clause, only if non-null
      IF p_where_clause IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WHERE_CLAUSE,
                                                   p_varchar2_value     => p_where_clause,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_weight IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WEIGHT,
                                                   p_number_value       => p_weight,
                                                   x_property_id        => l_prop_id);
      END IF;

      x_object_id := l_object_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --occurs when create object or prop couldn't find needed state
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE ADD_DML_TRUNCATE_STMT(p_table_owner        IN VARCHAR2,
                                   p_table_name         IN VARCHAR2,
                                   p_weight             IN NUMBER,
                                   p_source_type        IN VARCHAR2,
                                   p_source_id          IN NUMBER,
                                   x_object_id          OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_DML_TRUNCATE_STMT';

      l_object_id       NUMBER;
      l_prop_id         NUMBER;

      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- go ahead and create the object, if there's no config instance it'll throw an exception
      FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT(p_object_type        => G_OTYPE_DML_TRUNCATE_STMT,
                                           p_source_type        => p_source_type,
                                           p_source_id          => p_source_id,
                                           x_object_id          => l_object_id);

      --now create properties for the arguments
      --table owner
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_TABLE_OWNER,
                                                p_varchar2_value        => p_table_owner,
                                                x_property_id           => l_prop_id);
      --table name
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_TABLE_NAME,
                                                p_varchar2_value        => p_table_name,
                                                x_property_id           => l_prop_id);

      IF p_weight IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WEIGHT,
                                                   p_number_value       => p_weight,
                                                   x_property_id        => l_prop_id);
      END IF;

      x_object_id := l_object_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --occurs when create object or prop couldn't find needed state
         x_object_id := NULL;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         x_object_id := NULL;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE ADD_PLSQL_TEXT(p_plsql_text        IN VARCHAR2,
                            p_table_owner       IN VARCHAR2,
                            p_table_name        IN VARCHAR2,
                            p_primary_domain    IN VARCHAR2,
                            p_weight            IN NUMBER,
                            p_source_type       IN VARCHAR2,
                            p_source_id         IN NUMBER,
                            x_object_id         OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_PLSQL_TEXT';

      l_object_id       NUMBER;
      l_prop_id         NUMBER;

      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- go ahead and create the object, if there's no config instance it'll throw an exception
      FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT(p_object_type        => G_OTYPE_PLSQL_TEXT,
                                           p_source_type        => p_source_type,
                                           p_source_id          => p_source_id,
                                           x_object_id          => l_object_id);

      --now create properties for the arguments
      --plsql_text
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => l_object_id,
                                                p_property_name         => G_PROP_PLSQL_TEXT,
                                                p_varchar2_value        => p_plsql_text,
                                                x_property_id           => l_prop_id);

      -- optional table_owner for table-bound pl/sqls
      IF p_table_owner IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_TABLE_OWNER,
                                                   p_varchar2_value     => p_table_owner,
                                                   x_property_id        => l_prop_id);
      END IF;

      -- optional table_name for table-bound pl/sqls
      IF p_table_name IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_TABLE_NAME,
                                                   p_varchar2_value     => p_table_name,
                                                   x_property_id        => l_prop_id);
      END IF;

      -- optional primary_domain
      IF p_primary_domain IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_PRIMARY_DOMAIN,
                                                   p_varchar2_value     => p_primary_domain,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_weight IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WEIGHT,
                                                   p_number_value       => p_weight,
                                                   x_property_id        => l_prop_id);
      END IF;

      x_object_id := l_object_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --occurs when create object or prop couldn't find needed state
         x_object_id := NULL;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         x_object_id := NULL;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE ADD_RUN_OBJECT(p_run_mode                  IN VARCHAR2 DEFAULT NULL,
                            p_valid_check_interval      IN NUMBER DEFAULT NULL,
                            p_num_bundles               IN NUMBER DEFAULT NULL,
                            p_weight                    IN NUMBER DEFAULT NULL,
                            x_object_id                 OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_RUN_OBJECT';

      l_object_id       NUMBER;
      l_prop_id         NUMBER;

      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- go ahead and create the object, if there's no config instance it'll throw an exception
      FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT(p_object_type        => G_OTYPE_RUN,
                                           x_object_id          => l_object_id);

      --now create properties for the arguments

      IF p_run_mode IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_RUN_MODE,
                                                   p_varchar2_value     => p_run_mode,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_valid_check_interval IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_VALID_CHECK_INTERVAL,
                                                   p_number_value       => p_valid_check_interval,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_num_bundles IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_NUM_BUNDLES,
                                                   p_number_value       => p_num_bundles,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_weight IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WEIGHT,
                                                   p_number_value       => p_weight,
                                                   x_property_id        => l_prop_id);
      END IF;

      x_object_id := l_object_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --occurs when create object or prop couldn't find needed state
         x_object_id := NULL;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         x_object_id := NULL;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE ADD_BUNDLE_OBJECT(p_target_hostname                IN VARCHAR2 DEFAULT NULL,
                               p_workers_allowed                IN NUMBER DEFAULT NULL,
                               p_batch_size                     IN NUMBER DEFAULT NULL,
                               p_min_parallel_unit_weight       IN NUMBER DEFAULT NULL,
                               p_weight                         IN NUMBER DEFAULT NULL,
                               x_object_id                      OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_BUNDLE_OBJECT';

      l_object_id       NUMBER;
      l_prop_id         NUMBER;

      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- go ahead and create the object, if there's no config instance it'll throw an exception
      FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT(p_object_type        => G_OTYPE_BUNDLE,
                                           x_object_id          => l_object_id);

      --now create properties for the arguments

      IF p_target_hostname IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_TARGET_HOSTNAME,
                                                   p_varchar2_value     => p_target_hostname,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_workers_allowed IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WORKERS_ALLOWED,
                                                   p_number_value       => p_workers_allowed,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_batch_size IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_BATCH_SIZE,
                                                   p_number_value       => p_batch_size,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_min_parallel_unit_weight IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_MIN_PARALLEL_WEIGHT,
                                                   p_number_value       => p_min_parallel_unit_weight,
                                                   x_property_id        => l_prop_id);
      END IF;

      IF p_weight IS NOT NULL THEN
         FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type        => G_TYPE_OBJECT,
                                                   p_parent_id          => l_object_id,
                                                   p_property_name      => G_PROP_WEIGHT,
                                                   p_number_value       => p_weight,
                                                   x_property_id        => l_prop_id);
      END IF;

      x_object_id := l_object_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --occurs when create object or prop couldn't find needed state
         x_object_id := NULL;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         x_object_id := NULL;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE ADD_ERRORED_OBJECT(p_object_type           IN VARCHAR2,
                                   p_message            IN VARCHAR2,
                                   p_source_type        IN VARCHAR2,
                                   p_source_id          IN NUMBER,
                                   x_object_id          OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_ERRORED_OBJECT';

      l_object_id       NUMBER;
      l_prop_id         NUMBER;

      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- go ahead and create the object, if there's no config instance it'll throw an exception
      FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT(p_object_type        => p_object_type,
                                           p_source_type        => p_source_type,
                                           p_source_id          => p_source_id,
                                           p_errors_found_flag  => FND_API.G_TRUE,
                                           p_message            => p_message,
                                           x_object_id          => l_object_id);

      x_object_id := l_object_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --occurs when create object or prop couldn't find needed state
         x_object_id := NULL;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         x_object_id := NULL;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE GET_NEXT_PROC(p_stage              IN VARCHAR2,
                           x_proc_id            OUT NOCOPY NUMBER,
                           x_proc_type          OUT NOCOPY VARCHAR2,
                           x_error_is_fatal     OUT NOCOPY VARCHAR2,
                           x_location           OUT NOCOPY VARCHAR2,
                           x_executable         OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      FND_OAM_DSCFG_PROCS_PKG.GET_NEXT_PROC(p_stage             => p_stage,
                                            x_proc_id           => x_proc_id,
                                            x_proc_type         => x_proc_type,
                                            x_error_is_fatal    => x_error_is_fatal,
                                            x_location          => x_location,
                                            x_executable        => x_executable);
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
   BEGIN
      FND_OAM_DSCFG_INSTANCES_PKG.ADD_CONFIG_INSTANCE(p_target_dbname           => p_target_dbname,
                                                      p_config_instance_type    => p_config_instance_type,
                                                      p_name                    => p_name,
                                                      p_description             => p_description,
                                                      p_language                => p_language,
                                                      p_source_dbname           => p_source_dbname,
                                                      p_clone_key               => p_clone_key,
                                                      p_policyset_id            => p_policyset_id,
                                                      x_config_instance_id      => x_config_instance_id);
   END;

   -- Public
   PROCEDURE SET_CURRENT_CONFIG_INSTANCE(p_config_instance_id   IN NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_INSTANCES_PKG.SET_CURRENT_CONFIG_INSTANCE(p_config_instance_id      => p_config_instance_id);
   END;

   -- Public
   PROCEDURE ADD_OBJECT(p_object_type           IN VARCHAR2,
                        p_parent_object_id      IN NUMBER,
                        p_source_type           IN VARCHAR2,
                        p_source_id             IN NUMBER,
                        p_errors_found_flag     IN VARCHAR2,
                        p_message               IN VARCHAR2,
                        x_object_id             OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT(p_object_type        => p_object_type,
                                           p_parent_object_id   => p_parent_object_id,
                                           p_source_type        => p_source_type,
                                           p_source_id          => p_source_id,
                                           p_errors_found_flag  => p_errors_found_flag,
                                           p_message            => p_message,
                                           x_object_id          => x_object_id);
   END;

   -- Public
   PROCEDURE GET_OBJECTS_FOR_TYPE(p_object_type         IN VARCHAR2,
                                  x_object_ids          OUT NOCOPY DBMS_SQL.NUMBER_TABLE)
   IS
   BEGIN
      FND_OAM_DSCFG_OBJECTS_PKG.GET_OBJECTS_FOR_TYPE(p_object_type      => p_object_type,
                                                     x_object_ids       => x_object_ids);
   END;

   -- Public
   PROCEDURE GET_OBJECTS_FOR_TYPE(p_object_type         IN VARCHAR2,
                                  p_errors_found_flag   IN VARCHAR2,
                                  x_object_ids          OUT NOCOPY DBMS_SQL.NUMBER_TABLE)
   IS
   BEGIN
      FND_OAM_DSCFG_OBJECTS_PKG.GET_OBJECTS_FOR_TYPE(p_object_type              => p_object_type,
                                                     p_errors_found_flag        => p_errors_found_flag,
                                                     x_object_ids               => x_object_ids);
   END;

   -- Public
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_datatype            IN VARCHAR2,
                          p_canonical_value     IN VARCHAR2,
                          x_property_id         OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => p_parent_type,
                                                p_parent_id             => p_parent_id,
                                                p_property_name         => p_property_name,
                                                p_datatype              => p_datatype,
                                                p_canonical_value       => p_canonical_value,
                                                x_property_id           => x_property_id);
   END;

   -- Public
   PROCEDURE ADD_OBJECT_PROPERTY(p_object_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_varchar2_value       IN VARCHAR2,
                                 x_property_id          OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => p_object_id,
                                                p_property_name         => p_property_name,
                                                p_varchar2_value        => p_varchar2_value,
                                                x_property_id           => x_property_id);
   END;

   -- Public
   PROCEDURE ADD_OBJECT_PROPERTY(p_object_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_number_value         IN NUMBER,
                                 x_property_id          OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => p_object_id,
                                                p_property_name         => p_property_name,
                                                p_number_value          => p_number_value,
                                                x_property_id           => x_property_id);
   END;

   -- Public
   PROCEDURE ADD_OBJECT_PROPERTY(p_object_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_date_value           IN DATE,
                                 x_property_id          OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY(p_parent_type           => G_TYPE_OBJECT,
                                                p_parent_id             => p_object_id,
                                                p_property_name         => p_property_name,
                                                p_date_value            => p_date_value,
                                                x_property_id           => x_property_id);
   END;

   -- Public
   PROCEDURE GET_PROPERTY_CANONICAL_VALUE(p_parent_type         IN VARCHAR2,
                                          p_parent_id           IN NUMBER,
                                          p_property_name       IN VARCHAR2,
                                          x_canonical_value     OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.GET_PROPERTY_CANONICAL_VALUE(p_parent_type           => p_parent_type,
                                                                p_parent_id             => p_parent_id,
                                                                p_property_name         => p_property_name,
                                                                x_canonical_value       => x_canonical_value);
   END;

   -- Public
   PROCEDURE GET_OBJECT_PROPERTY_VALUE(p_object_id              IN NUMBER,
                                       p_property_name          IN VARCHAR2,
                                       x_varchar2_value         OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.GET_PROPERTY_VALUE(p_parent_type             => G_TYPE_OBJECT,
                                                      p_parent_id               => p_object_id,
                                                      p_property_name           => p_property_name,
                                                      x_varchar2_value          => x_varchar2_value);
   END;

   -- Public
   PROCEDURE GET_OBJECT_PROPERTY_VALUE(p_object_id              IN NUMBER,
                                       p_property_name          IN VARCHAR2,
                                       x_number_value           OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.GET_PROPERTY_VALUE(p_parent_type             => G_TYPE_OBJECT,
                                                      p_parent_id               => p_object_id,
                                                      p_property_name           => p_property_name,
                                                      x_number_value            => x_number_value);
   END;

   -- Public
   PROCEDURE GET_OBJECT_PROPERTY_VALUE(p_object_id              IN NUMBER,
                                       p_property_name          IN VARCHAR2,
                                       x_date_value             OUT NOCOPY DATE)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.GET_PROPERTY_VALUE(p_parent_type             => G_TYPE_OBJECT,
                                                      p_parent_id               => p_object_id,
                                                      p_property_name           => p_property_name,
                                                      x_date_value              => x_date_value);
   END;

   -- Public
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_datatype             IN VARCHAR2,
                                 p_canonical_value      IN VARCHAR2,
                                 x_property_id          OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.SET_OR_ADD_PROPERTY(p_parent_type            => p_parent_type,
                                                       p_parent_id              => p_parent_id,
                                                       p_property_name          => p_property_name,
                                                       p_datatype               => p_datatype,
                                                       p_canonical_value        => p_canonical_value,
                                                       x_property_id            => x_property_id);
   END;


   -- Public
   PROCEDURE SET_OR_ADD_OBJECT_PROPERTY(p_object_id             IN NUMBER,
                                        p_property_name         IN VARCHAR2,
                                        p_varchar2_value        IN VARCHAR2,
                                        x_property_id           OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.SET_OR_ADD_PROPERTY(p_parent_type            => G_TYPE_OBJECT,
                                                       p_parent_id              => p_object_id,
                                                       p_property_name          => p_property_name,
                                                       p_varchar2_value         => p_varchar2_value,
                                                       x_property_id            => x_property_id);
   END;


   -- Public
   PROCEDURE SET_OR_ADD_OBJECT_PROPERTY(p_object_id             IN NUMBER,
                                        p_property_name         IN VARCHAR2,
                                        p_number_value          IN NUMBER,
                                        x_property_id           OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.SET_OR_ADD_PROPERTY(p_parent_type            => G_TYPE_OBJECT,
                                                       p_parent_id              => p_object_id,
                                                       p_property_name          => p_property_name,
                                                       p_number_value           => p_number_value,
                                                       x_property_id            => x_property_id);
   END;


   -- Public
   PROCEDURE SET_OR_ADD_OBJECT_PROPERTY(p_object_id             IN NUMBER,
                                        p_property_name         IN VARCHAR2,
                                        p_date_value            IN DATE,
                                        x_property_id           OUT NOCOPY NUMBER)
   IS
   BEGIN
      FND_OAM_DSCFG_PROPERTIES_PKG.SET_OR_ADD_PROPERTY(p_parent_type            => G_TYPE_OBJECT,
                                                       p_parent_id              => p_object_id,
                                                       p_property_name          => p_property_name,
                                                       p_date_value             => p_date_value,
                                                       x_property_id            => x_property_id);
   END;



END FND_OAM_DSCFG_API_PKG;

/
