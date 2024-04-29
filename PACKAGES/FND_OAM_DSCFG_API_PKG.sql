--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_API_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCAPIS.pls 120.3 2006/01/17 11:29 ilawler noship $ */

   ---------------
   -- Constants --
   ---------------
   -- Data Scramling Configuration Entity Types - used as the PARENT_TYPE for properties
   G_TYPE_INSTANCE                      CONSTANT VARCHAR2(30) := 'INSTANCE';
   G_TYPE_OBJECT                        CONSTANT VARCHAR2(30) := 'OBJECT';
   G_TYPE_PROC                          CONSTANT VARCHAR2(30) := 'PROC';

   -- Config Procedure Types
   G_PROCTYPE_TARGET_PLSQL              CONSTANT VARCHAR2(30) := 'TARGET_PLSQL';
   G_PROCTYPE_AGENT_JAVA                CONSTANT VARCHAR2(30) := 'AGENT_JAVA';

   -- Config Procedure Stages
   G_STAGE_IMPORT                       CONSTANT VARCHAR2(30) := 'IMPORT';
   G_STAGE_PRE_COMPILE                  CONSTANT VARCHAR2(30) := 'PRE_COMPILE';
   G_STAGE_POST_COMPILE                 CONSTANT VARCHAR2(30) := 'POST_COMPILE';
   G_STAGE_PRE_EXECUTE                  CONSTANT VARCHAR2(30) := 'PRE_EXECUTE';
   G_STAGE_POST_EXECUTE                 CONSTANT VARCHAR2(30) := 'POST_EXECUTE';
   G_STAGE_CLEANUP                      CONSTANT VARCHAR2(30) := 'CLEANUP';

   -- Configuration Instance Types
   G_CONFTYPE_CLONING                   CONSTANT VARCHAR2(30) := 'CLONING';

   -- Config Object Types
   G_INTERNAL_PREFIX                    CONSTANT VARCHAR2(30) := '_ORA_';
   G_OTYPE_DML_UPDATE_SEGMENT           CONSTANT VARCHAR2(30) := G_INTERNAL_PREFIX||'DML_UPDATE_SEGMENT';
   G_OTYPE_DML_DELETE_STMT              CONSTANT VARCHAR2(30) := G_INTERNAL_PREFIX||'DML_DELETE_STMT';
   G_OTYPE_DML_TRUNCATE_STMT            CONSTANT VARCHAR2(30) := G_INTERNAL_PREFIX||'DML_TRUNCATE_STMT';
   G_OTYPE_PLSQL_TEXT                   CONSTANT VARCHAR2(30) := G_INTERNAL_PREFIX||'PLSQL_TEXT';
   G_OTYPE_RUN                          CONSTANT VARCHAR2(30) := G_INTERNAL_PREFIX||'RUN';
   G_OTYPE_BUNDLE                       CONSTANT VARCHAR2(30) := G_INTERNAL_PREFIX||'BUNDLE';
   G_OTYPE_DOMAIN_METADATA              CONSTANT VARCHAR2(30) := G_INTERNAL_PREFIX||'DOMAIN_METADATA';

   -- Property Data Types
   G_DATATYPE_VARCHAR2  CONSTANT VARCHAR2(30) := 'VARCHAR2';
   G_DATATYPE_NUMBER    CONSTANT VARCHAR2(30) := 'NUMBER';
   G_DATATYPE_DATE      CONSTANT VARCHAR2(30) := 'DATE';
   G_DATATYPE_BOOLEAN   CONSTANT VARCHAR2(30) := 'BOOLEAN'; --not a supported SQL type, but can be used for better typed logic
   G_DATATYPE_ROWID     CONSTANT VARCHAR2(30) := 'ROWID';
   G_DATATYPE_RAW       CONSTANT VARCHAR2(30) := 'RAW';

   -- Property Names
   --  Object Properties
   G_PROP_TABLE_OWNER           CONSTANT VARCHAR2(30) := 'TABLE_OWNER';
   G_PROP_TABLE_NAME            CONSTANT VARCHAR2(30) := 'TABLE_NAME';
   G_PROP_COLUMN_NAME           CONSTANT VARCHAR2(30) := 'COLUMN_NAME';
   G_PROP_NEW_COLUMN_VALUE      CONSTANT VARCHAR2(30) := 'NEW_COLUMN_VALUE';
   G_PROP_WHERE_CLAUSE          CONSTANT VARCHAR2(30) := 'WHERE_CLAUSE';
   G_PROP_PLSQL_TEXT            CONSTANT VARCHAR2(30) := 'PLSQL_TEXT';
   G_PROP_WEIGHT_MODIFIER       CONSTANT VARCHAR2(30) := 'WEIGHT_MODIFIER';
   --  Run Metadata
   G_PROP_RUN_ID                CONSTANT VARCHAR2(30) := 'RUN_ID';
   G_PROP_RUN_MODE              CONSTANT VARCHAR2(30) := 'RUN_MODE';
   G_PROP_VALID_CHECK_INTERVAL  CONSTANT VARCHAR2(30) := 'VALID_CHECK_INTERVAL';
   G_PROP_NUM_BUNDLES           CONSTANT VARCHAR2(30) := 'NUM_BUNDLES';
   --  Bundle Metadata
   G_PROP_BUNDLE_ID             CONSTANT VARCHAR2(30) := 'BUNDLE_ID';
   G_PROP_TARGET_HOSTNAME       CONSTANT VARCHAR2(30) := 'TARGET_HOSTNAME';
   G_PROP_WORKERS_ALLOWED       CONSTANT VARCHAR2(30) := 'WORKERS_ALLOWED';
   G_PROP_MIN_PARALLEL_WEIGHT   CONSTANT VARCHAR2(30) := 'MIN_PARALLEL_WEIGHT';
   G_PROP_BATCH_SIZE            CONSTANT VARCHAR2(30) := 'BATCH_SIZE';
   --  Unit Metadata
   G_PROP_PHASE                 CONSTANT VARCHAR2(30) := 'PHASE';
   G_PROP_DISABLE_SPLITTING     CONSTANT VARCHAR2(30) := 'DISABLE_SPLITTING';
   G_PROP_ERROR_FATALITY_LEVEL  CONSTANT VARCHAR2(30) := 'ERROR_FATALITY_LEVEL';
   --  Run/Bundle/Task/Unit Metadata
   G_PROP_WEIGHT                CONSTANT VARCHAR2(30) := 'WEIGHT';
   G_PROP_PRIORITY              CONSTANT VARCHAR2(30) := 'PRIORITY';
   -- Common Object Properties
   G_PROP_PRIMARY_DOMAIN        CONSTANT VARCHAR2(30) := 'PRIMARY_DOMAIN';
   G_PROP_ADDITIONAL_DOMAIN     CONSTANT VARCHAR2(30) := 'ADDITIONAL_DOMAIN';

   --Execution Run Modes - must be kept in sync with DSCRAM_UTILS_PKG.G_MODE_*
   G_RUNMODE_NORMAL             CONSTANT VARCHAR2(30) := 'NORMAL';
   G_RUNMODE_TEST               CONSTANT VARCHAR2(30) := 'TEST';
   G_RUNMODE_TEST_NO_EXEC       CONSTANT VARCHAR2(30) := 'TEST_NO_EXEC';

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- ####################
   --  General Utility  --
   -- ####################

   -- Function to check the safety harness to see if scrambling configuration changes are allowed.
   -- Invariants:
   --   None
   -- Parameters:
   --   None
   -- Returns:
   --   Boolean indicating whether scrambling config changes are allowed.
   -- Exceptions:
   --   None Expected
   FUNCTION ARE_CONFIG_CHANGES_ALLOWED
      RETURN BOOLEAN;

   -- ################################################
   --  Wrapper Accessors for Import Procedure State  --
   -- ################################################

   -- Accessor function, obtains proc_id stored in the PROCS_PKG state for the last fetched proc.
   -- Invariants:
   --   Only has a value during execute a proc has been get/set.
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the in-progress proc.
   -- Exceptions:
   --   If the proc package state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_PROC_ID
      RETURN NUMBER;

   -- ################################################
   --  Wrapper Accessors for Config Instance State  --
   -- ################################################

   -- Accessor function, checks if the config instance state is initialized.
   -- Invariants:
   --   None
   -- Parameters:
   --   None
   -- Returns:
   --   Boolean where TRUE=Initialized
   -- Exceptions:
   --   None
   FUNCTION IS_CONFIG_INSTANCE_INITIALIZED
      RETURN BOOLEAN;

   -- Accessor function, obtains the config_instance_id associated with currently in-progress config instance.
   -- Invariants:
   --   Only has a value after the configuration instance has been initialized with a call to ADD_CONFIG_INSTANCE/
   --   SET_CURRENT_CONFIG_INSTANCE.
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the in-progress configuration instance.
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_CONFIG_INSTANCE_ID
      RETURN NUMBER;

   -- Accessor function, obtains policyset_id associated with currently in-progress configuration instance.
   -- Invariants:
   --   Only has a value after the configuration instance has been initialized with a call to ADD_CONFIG_INSTANCE/
   --   SET_CURRENT_CONFIG_INSTANCE.
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the Policy Set associated with the in-progress configuration instance, may be NULL
   --   if there is no policyset_id associated with this instance.
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_POLICYSET_ID
      RETURN NUMBER;

   -- ######################################################
   --  Configuration Instance-Related Utility Procedures  --
   -- ######################################################

   -- This API is used to return a list of all owners and tables that are in the scope of the Data Scrambling Engine.
   -- Setup procedures that need to modify any characteristics of the tables to be scrambled can use this procedure.
   -- Invariants:
   --   Assumes Configuration Instance has been initialized, throws NO_DATA_FOUND if not.
   -- Parameters:
   --   x_table_owners        OWNER of the target table
   --   x_table_names         NAME of the target table, indicies match between lists.
   -- Return Statuses:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE GET_CURRENT_TARGET_TABLE_LIST(x_table_owners       OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
                                           x_table_names        OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE);

   -- ##################################################
   --  Object+Properties Complex Creation Procedures  --
   -- ##################################################

   -- This API is used to create a new configuration object representing a table's column to be updated using DML.
   -- Invariants:
   --   Assumes Configuration Instance has been initialized, throws NO_DATA_FOUND if not.
   -- Parameters:
   --   p_table_owner         DML update target table's owner
   --   p_table_name          DML update target table
   --   p_column_name         DML update target table's column name
   --   p_new_column_value    New value for target column, expressed as text that you'd find in the SQL statement.  This means
   --                         new values that are strings will need to be expressed as 'VALUE' with the apostrophes to distinguish
   --                         from numbers or other column references.
   --   p_where_clause        [OPTIONAL]Where clause to use when updating this column.
   --   p_source_type         [OPTIONAL]A VARCHAR2(30) sized field used for declaring a type of the source object, for use
   --                         in directives to identify a link to part of the original configuration source.
   --   p_source_id           [OPTIONAL]A corresponding Number ID for the source_type.  May refer to a mapped ID
   --                         obtained from FND_OAM_DSCFG_MAPPED_KEYS if the source requires a complex or varchar2 key.
   --
   --   x_object_id:          The corresponding ID of the newly created, corresponding configuration object.
   -- Return Statuses:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE ADD_DML_UPDATE_SEGMENT(p_table_owner               IN VARCHAR2,
                                    p_table_name                IN VARCHAR2,
                                    p_column_name               IN VARCHAR2,
                                    p_new_column_value          IN VARCHAR2,
                                    p_where_clause              IN VARCHAR2     DEFAULT NULL,
                                    p_weight_modifier           IN NUMBER       DEFAULT NULL,
                                    p_source_type               IN VARCHAR2     DEFAULT NULL,
                                    p_source_id                 IN NUMBER       DEFAULT NULL,
                                    x_object_id                 OUT NOCOPY NUMBER);

   -- This API is used to create a new configuration object representing a DML delete statement.
   -- Invariants:
   --   Assumes Configuration Instance has been initialized, throws NO_DATA_FOUND if not.
   -- Parameters:
   --   p_table_owner         DML delete target table's owner
   --   p_table_name          DML delete target table
   --   p_where_clause        [OPTIONAL]Where clause to use when deleting rows from this target table.
   --   p_source_type         [OPTIONAL]A VARCHAR2(30) sized field used for declaring a type of the source object, for use
   --                         in directives to identify a link to part of the original configuration source.
   --   p_source_id           [OPTIONAL]A corresponding Number ID for the source_type.  May refer to a mapped ID
   --                         obtained from FND_OAM_DSCFG_MAPPED_KEYS if the source requires a complex or varchar2 key.
   --
   --   x_object_id:          The corresponding ID of the newly created, corresponding configuration object.
   -- Return Statuses:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE ADD_DML_DELETE_STMT(p_table_owner          IN VARCHAR2,
                                 p_table_name           IN VARCHAR2,
                                 p_where_clause         IN VARCHAR2     DEFAULT NULL,
                                 p_weight               IN NUMBER       DEFAULT NULL,
                                 p_source_type          IN VARCHAR2     DEFAULT NULL,
                                 p_source_id            IN NUMBER       DEFAULT NULL,
                                 x_object_id            OUT NOCOPY NUMBER);

   -- This API is used to create a new configuration object representing a DML truncate statement.
   -- Invariants:
   --   Assumes Configuration Instance has been initialized, throws NO_DATA_FOUND if not.
   -- Parameters:
   --   p_table_owner         DML truncate target table's owner
   --   p_table_name          DML truncate target table
   --   p_source_type         [OPTIONAL]A VARCHAR2(30) sized field used for declaring a type of the source object, for use
   --                         in directives to identify a link to part of the original configuration source.
   --   p_source_id           [OPTIONAL]A corresponding Number ID for the source_type.  May refer to a mapped ID
   --                         obtained from FND_OAM_DSCFG_MAPPED_KEYS if the source requires a complex or varchar2 key.
   --
   --   x_object_id:          The corresponding ID of the newly created, corresponding configuration object.
   -- Return Statuses:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE ADD_DML_TRUNCATE_STMT(p_table_owner        IN VARCHAR2,
                                   p_table_name         IN VARCHAR2,
                                   p_weight             IN NUMBER       DEFAULT NULL,
                                   p_source_type        IN VARCHAR2     DEFAULT NULL,
                                   p_source_id          IN NUMBER       DEFAULT NULL,
                                   x_object_id          OUT NOCOPY NUMBER);

   -- This API is used to create a new configuration object representing a chunk of PL/SQL text.  This text
   -- will be executed by wrapping it in an anonymous BEGIN END; block and issuing it through the DBMS_SQL package.
   -- Invariants:
   --   Assumes Configuration Instance has been initialized, throws NO_DATA_FOUND if not.
   -- Parameters:
   --   p_plsql_text          PL/SQL text - this should typically be a reference to a PROCEDURE whose inputs are
   --                         either hardcoded or represented with argument-type objects.
   --   p_source_type         [OPTIONAL]A VARCHAR2(30) sized field used for declaring a type of the source object, for use
   --                         in directives to identify a link to part of the original configuration source.
   --   p_source_id           [OPTIONAL]A corresponding Number ID for the source_type.  May refer to a mapped ID
   --                         obtained from FND_OAM_DSCFG_MAPPED_KEYS if the source requires a complex or varchar2 key.
   --
   --   x_object_id:          The corresponding ID of the newly created, corresponding configuration object.
   -- Return Statuses:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE ADD_PLSQL_TEXT(p_plsql_text                IN VARCHAR2,
                            p_table_owner               IN VARCHAR2 DEFAULT NULL,
                            p_table_name                IN VARCHAR2 DEFAULT NULL,
                            p_primary_domain            IN VARCHAR2 DEFAULT NULL,
                            p_weight                    IN NUMBER DEFAULT NULL,
                            p_source_type               IN VARCHAR2     DEFAULT NULL,
                            p_source_id                 IN NUMBER       DEFAULT NULL,
                            x_object_id                 OUT NOCOPY NUMBER);

   -- This API is used to create a new engine run object.  At most one of these can be created for a single config
   -- instance.  If not run object is added, a default one is created by the configuration compiler.
   -- Invariants:
   --   Assumes Configuration Instance has been initialized, throws NO_DATA_FOUND if not.
   -- Parameters:
   --   p_run_mode              Mode to use for execution - use G_RUNMODE_* constants.  Default=NORMAL.
   --   p_valid_check_interval  Interval expressed in number of seconds controlling how often runtime entities are polled
   --                           for status updates.  This controls how responsive the engine is to user STOP requests.
   --                           Default=600 seconds.
   --   p_num_bundles           Number of bundles to use. Default=1.
   --   p_weight                Forced Weight of the run, may be provided if the compiler's calculated run weight is insufficient.
   --
   --   x_object_id:            The corresponding ID of the newly created, corresponding configuration object.
   -- Return Statuses:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE ADD_RUN_OBJECT(p_run_mode                  IN VARCHAR2 DEFAULT NULL,
                            p_valid_check_interval      IN NUMBER DEFAULT NULL,
                            p_num_bundles               IN NUMBER DEFAULT NULL,
                            p_weight                    IN NUMBER DEFAULT NULL,
                            x_object_id                 OUT NOCOPY NUMBER);

   -- This API is used to create a new engine bundle object.  A bundle object can be created for each node
   -- of a database which will participate in the scramble.
   -- Invariants:
   --   Assumes Configuration Instance has been initialized, throws NO_DATA_FOUND if not.
   -- Parameters:
   --   p_target_hostname       Hostname from v$instance to which this bundle should be attached.  If left NULL, the compiler
   --                           will choose a host at random.
   --   p_workers_allowed       Number of workers to use on this host.  Default=2xcpu_count.
   --   p_batch_size            The default number of rows each parallelized worker should request when working on a splitable
   --                           work item.  Default=10000.
   --   p_min_parallel_unit_weight  The minimum weight which will be parallelized. Default=50.
   --   p_weight                Forced Weight of the bundle, may be provided if the compiler's calculated weight is insufficient.
   --
   --   x_object_id:            The corresponding ID of the newly created, corresponding configuration object.
   -- Return Statuses:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE ADD_BUNDLE_OBJECT(p_target_hostname                IN VARCHAR2 DEFAULT NULL,
                               p_workers_allowed                IN NUMBER DEFAULT NULL,
                               p_batch_size                     IN NUMBER DEFAULT NULL,
                               p_min_parallel_unit_weight       IN NUMBER DEFAULT NULL,
                               p_weight                         IN NUMBER DEFAULT NULL,
                               x_object_id                      OUT NOCOPY NUMBER);

   -- This API is used to create a new configuration object with an error message.  This is typically used by import
   -- procedures to make a record of an object it failed to import.
   -- Invariants:
   --   Assumes Configuration Instance has been initialized, throws NO_DATA_FOUND if not.
   -- Parameters:
   --   p_object_type           The type of the configuration object that should have been created.  Use the G_OTYPE_* constants.
   --   p_message               VARCHAR2(4000) field to explain the error.
   --   p_source_type           [OPTIONAL]A VARCHAR2(30) sized field used for declaring a type of the source object, for use
   --                           in directives to identify a link to part of the original configuration source.
   --   p_source_id             [OPTIONAL]A corresponding Number ID for the source_type.  May refer to a mapped ID
   --                           obtained from FND_OAM_DSCFG_MAPPED_KEYS if the source requires a complex or varchar2 key.
   --
   --   x_object_id:            The corresponding ID of the newly created, corresponding configuration object.
   -- Return Statuses:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE ADD_ERRORED_OBJECT(p_object_type           IN VARCHAR2,
                                p_message               IN VARCHAR2     DEFAULT NULL,
                                p_source_type           IN VARCHAR2     DEFAULT NULL,
                                p_source_id             IN NUMBER       DEFAULT NULL,
                                x_object_id             OUT NOCOPY NUMBER);

   -- ##############################################
   --  Wrappers for Generic Operations on Procs   --
   -- ##############################################

   -- See FND_OAM_DSCFG_PROCS_PKG.GET_NEXT_PROC for description.
   PROCEDURE GET_NEXT_PROC(p_stage              IN VARCHAR2,
                           x_proc_id            OUT NOCOPY NUMBER,
                           x_proc_type          OUT NOCOPY VARCHAR2,
                           x_error_is_fatal     OUT NOCOPY VARCHAR2,
                           x_location           OUT NOCOPY VARCHAR2,
                           x_executable         OUT NOCOPY VARCHAR2);

   -- #########################################################
   --  Wrappers for Generic Operations on Config Instances   --
   -- #########################################################

   -- See FND_OAM_DSCFG_INSTANCES_PKG.ADD_CONFIG_INSTANCE for description.
   PROCEDURE ADD_CONFIG_INSTANCE(p_target_dbname        IN VARCHAR2,
                                 p_config_instance_type IN VARCHAR2,
                                 p_name                 IN VARCHAR2,
                                 p_description          IN VARCHAR2     DEFAULT NULL,
                                 p_language             IN VARCHAR2     DEFAULT NULL,
                                 p_source_dbname        IN VARCHAR2     DEFAULT NULL,
                                 p_clone_key            IN VARCHAR2     DEFAULT NULL,
                                 p_policyset_id         IN NUMBER       DEFAULT NULL,
                                 x_config_instance_id   OUT NOCOPY NUMBER);

   -- See FND_OAM_DSCFG_INSTANCES_PKG.SET_CURRENT_CONFIG_INSTANCE for description.
   PROCEDURE SET_CURRENT_CONFIG_INSTANCE(p_config_instance_id   IN NUMBER);

   -- ################################################
   --  Wrappers for Generic Operations on Objects   --
   -- ################################################

   -- See FND_OAM_DSCFG_OBJECTS_PKG.ADD_OBJECT for description.
   PROCEDURE ADD_OBJECT(p_object_type           IN VARCHAR2,
                        p_parent_object_id      IN NUMBER       DEFAULT NULL,
                        p_source_type           IN VARCHAR2     DEFAULT NULL,
                        p_source_id             IN NUMBER       DEFAULT NULL,
                        p_errors_found_flag     IN VARCHAR2     DEFAULT NULL,
                        p_message               IN VARCHAR2     DEFAULT NULL,
                        x_object_id             OUT NOCOPY NUMBER);

   -- See FND_OAM_DSCFG_OBJECTS_PKG.GET_OBJECTS_FOR_TYPE for description.
   PROCEDURE GET_OBJECTS_FOR_TYPE(p_object_type         IN VARCHAR2,
                                  x_object_ids          OUT NOCOPY DBMS_SQL.NUMBER_TABLE);

   -- See FND_OAM_DSCFG_OBJECTS_PKG.GET_OBJECTS_FOR_TYPE for description.
   PROCEDURE GET_OBJECTS_FOR_TYPE(p_object_type         IN VARCHAR2,
                                  p_errors_found_flag   IN VARCHAR2,
                                  x_object_ids          OUT NOCOPY DBMS_SQL.NUMBER_TABLE);

   -- ###################################################
   --  Wrappers for Generic Operations on Properties   --
   -- ###################################################

   -- See FND_OAM_DSCFG_PROPERTIES_PKG.ADD_PROPERTY for description.
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_datatype            IN VARCHAR2,
                          p_canonical_value     IN VARCHAR2,
                          x_property_id         OUT NOCOPY NUMBER);

   -- Simple wrapper on ADD_PROPERTY to default in parent_type = G_OBJECT, datatype = VARCHAR2
   PROCEDURE ADD_OBJECT_PROPERTY(p_object_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_varchar2_value       IN VARCHAR2,
                                 x_property_id          OUT NOCOPY NUMBER);

   -- Simple wrapper on ADD_PROPERTY to default in parent_type = G_OBJECT, datatype = NUMBER
   PROCEDURE ADD_OBJECT_PROPERTY(p_object_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_number_value         IN NUMBER,
                                 x_property_id          OUT NOCOPY NUMBER);

   -- Simple wrapper on ADD_PROPERTY to default in parent_type = G_OBJECT, datatype = DATE
   PROCEDURE ADD_OBJECT_PROPERTY(p_object_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_date_value           IN DATE,
                                 x_property_id          OUT NOCOPY NUMBER);

   -- See FND_OAM_DSCFG_PROPERTIES_PKG.GET_PROPERTY_CANONICAL_VALUE for description.
   PROCEDURE GET_PROPERTY_CANONICAL_VALUE(p_parent_type         IN VARCHAR2,
                                          p_parent_id           IN NUMBER,
                                          p_property_name       IN VARCHAR2,
                                          x_canonical_value     OUT NOCOPY VARCHAR2);

   -- Simple wrapper on GET_PROPERTY_CANONICAL_VALUE to default in parent_type = G_OBJECT, datatype = VARCHAR2
   PROCEDURE GET_OBJECT_PROPERTY_VALUE(p_object_id              IN NUMBER,
                                       p_property_name          IN VARCHAR2,
                                       x_varchar2_value         OUT NOCOPY VARCHAR2);

   -- Simple wrapper on GET_PROPERTY_CANONICAL_VALUE to default in parent_type = G_OBJECT, datatype = NUMBER
   PROCEDURE GET_OBJECT_PROPERTY_VALUE(p_object_id              IN NUMBER,
                                       p_property_name          IN VARCHAR2,
                                       x_number_value           OUT NOCOPY NUMBER);

   -- Simple wrapper on GET_PROPERTY_CANONICAL_VALUE to default in parent_type = G_OBJECT, datatype = DATE
   PROCEDURE GET_OBJECT_PROPERTY_VALUE(p_object_id              IN NUMBER,
                                       p_property_name          IN VARCHAR2,
                                       x_date_value             OUT NOCOPY DATE);

   -- See FND_OAM_DSCFG_PROPERTIES_PKG.SET_OR_ADD_PROPERTY for description.
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_datatype             IN VARCHAR2,
                                 p_canonical_value      IN VARCHAR2,
                                 x_property_id          OUT NOCOPY NUMBER);

   -- Simple wrapper on SET_OR_ADD_PROPERTY to default in parent_type = G_OBJECT, datatype = VARCHAR2
   PROCEDURE SET_OR_ADD_OBJECT_PROPERTY(p_object_id             IN NUMBER,
                                        p_property_name         IN VARCHAR2,
                                        p_varchar2_value        IN VARCHAR2,
                                        x_property_id           OUT NOCOPY NUMBER);

   -- Simple wrapper on SET_OR_ADD_PROPERTY to default in parent_type = G_OBJECT, datatype = NUMBER
   PROCEDURE SET_OR_ADD_OBJECT_PROPERTY(p_object_id             IN NUMBER,
                                        p_property_name         IN VARCHAR2,
                                        p_number_value          IN NUMBER,
                                        x_property_id           OUT NOCOPY NUMBER);

   -- Simple wrapper on SET_OR_ADD_PROPERTY to default in parent_type = G_OBJECT, datatype = DATE
   PROCEDURE SET_OR_ADD_OBJECT_PROPERTY(p_object_id             IN NUMBER,
                                        p_property_name         IN VARCHAR2,
                                        p_date_value            IN DATE,
                                        x_property_id           OUT NOCOPY NUMBER);

END FND_OAM_DSCFG_API_PKG;

 

/
