--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_COMPILER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_COMPILER_PKG" as
/* $Header: AFOAMDSCCOMPB.pls 120.8 2006/07/10 19:11:28 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCFG_COMPILER_PKG.';

   -- Defaults used when creating engine entities
   B_DEFAULT_NUM_BUNDLES                CONSTANT NUMBER         := 1;
   B_DEFAULT_RUN_MODE                   CONSTANT VARCHAR2(30)   := FND_OAM_DSCRAM_UTILS_PKG.G_MODE_NORMAL;

   --Pseudo-private state set and returned by public Getters
   B_DEFAULT_WORKERS_ALLOWED            NUMBER                  := NULL; -- set to MAX(#CPU-1,1) by first call to compile_config_instance
   B_DEFAULT_BATCH_SIZE                 CONSTANT NUMBER         := 10000;
   B_DEFAULT_VALID_CHECK_INTERVAL       CONSTANT NUMBER         := 300; --5 minutes
   -- # of blocks under which we don't parallelize, if NULL engine parallelizes everything with a weight.
   -- NULL weights are always parallelized to be safe.  50 blocks corresponds to around 30k rows.
   B_DEFAULT_MIN_PARALLEL_WEIGHT        CONSTANT NUMBER         := 50;

   -- Constant used for DSCRAM Unit phases for various types of objects in a dependency group
   B_PHASE_INCREMENT                    CONSTANT NUMBER := 10;
   B_BASE_PHASE_TRUNCATES               CONSTANT NUMBER := 1000000;
   B_BASE_PHASE_UNBOUND_PLSQLS          CONSTANT NUMBER := 2000000;
   B_BASE_PHASE_BOUND_OPERATIONS        CONSTANT NUMBER := 3000000;
   B_BASE_PRIORITY_DELETES              CONSTANT NUMBER := 100;
   B_BASE_PRIORITY_BOUND_PLSQLS         CONSTANT NUMBER := 200;
   B_BASE_PRIORITY_UPDATES              CONSTANT NUMBER := 300;

   -- Default weight modifiers for various kinds of operations
   -- TODO: these need some investigation
   B_TRUNCATE_WEIGHT_MODIFIER           CONSTANT NUMBER := .01;
   B_DELETE_WEIGHT_MODIFIER             CONSTANT NUMBER := 1.01; --according to explain plan cost, delete is a little more than a one column update

   -- The maximum length of a generated SQL statement.  This needs to be the max
   -- varchar2 length - space typically used for adding AD Splitting clauses.
   B_STMT_MAXLEN                        CONSTANT NUMBER := 3900;

   ----------------------------------------
   -- Private Body Variables
   ----------------------------------------

   --*****
   --Types
   --*****

   -- List of numbers
   TYPE b_number_list_type IS TABLE OF NUMBER;

   -- List of domains
   TYPE b_domain_list_type IS TABLE OF VARCHAR2(120);

   -- Map of domains for easy lookup
   TYPE b_domain_map_type IS TABLE OF BOOLEAN INDEX BY VARCHAR2(120);

   -- Mapping from primary_domain name to list of object_ids with that primary domain
   TYPE b_primary_domains_type IS TABLE OF b_number_list_type INDEX BY VARCHAR2(120);

   -- A dependency group loosely maps to a task in the engine.  The dependency group is a list of primary domains and additional
   -- domains which overlap due to the definitions of the objects in these domains.
   TYPE b_dependency_group_def_type IS RECORD
      (
       primary_domains          b_domain_list_type      := NULL,
       additional_domains       b_domain_map_type,
       task_id                  NUMBER                  := NULL,
       priority                 NUMBER                  := NULL,
       weight                   NUMBER                  := NULL
       );

   -- Mapping from dependency_group_id to a record containing component primary domains/additional domains
   TYPE b_dependency_groups_type IS TABLE OF b_dependency_group_def_type INDEX BY BINARY_INTEGER;

   -- Mapping from domain name to owning dependency_group_id
   TYPE b_domain_to_group_map_type IS TABLE OF NUMBER INDEX BY VARCHAR2(120);

   -- Represents a DSCFG_PROPERTIES row.
   TYPE b_property_def_type IS RECORD
      (
       property_id              NUMBER          := NULL,
       property_name            VARCHAR2(120)   := NULL,
       datatype                 VARCHAR2(30)    := NULL,
       canonical_value          VARCHAR2(4000)  := NULL
       );
   -- Table of properties, indexed by property_id.
   TYPE b_properties_type IS TABLE OF b_property_def_type INDEX BY BINARY_INTEGER;

   -- Represents a DSCFG_OBJECTS row.  Records the type most importantly but also any top level, object metadata.
   TYPE b_object_def_type IS RECORD
      (
       object_id                NUMBER                  := NULL,
       object_type              VARCHAR2(30)            := NULL,
       target_type              VARCHAR2(30)            := NULL,
       target_id                NUMBER                  := NULL,
       new_errors_found_flag    VARCHAR2(3)             := NULL,
       new_message              VARCHAR2(4000)          := NULL,  --new message to write to the object's message field
       is_dirty                 BOOLEAN                 := FALSE,  --determines if we need to write the object out
       primary_domain           VARCHAR2(120)           := NULL,
       additional_domains       b_domain_list_type      := NULL
       --properties     b_properties_type
       );
   -- master objects map, key=object_id, value = an object_def_type record.  Exists as an indirect
   -- to allow other structures to be type-agnostic by using object_ids that can be looked up in this
   -- htable to determine the htable where the object's definition is stored based on the object_type.
   TYPE b_objects_type IS TABLE OF b_object_def_type INDEX BY BINARY_INTEGER;

   -- Record and Table types for DML_UPDATE_SEGMENT-typed objects.
   TYPE b_dml_update_segment_def_type IS RECORD
      (
       table_owner      VARCHAR2(30)    := NULL,
       table_name       VARCHAR2(30)    := NULL,
       column_name      VARCHAR2(30)    := NULL,
       new_column_value VARCHAR2(4000)  := NULL,
       where_clause     VARCHAR2(4000)  := NULL,
       weight_modifier  NUMBER          := 1
       );
   TYPE b_dml_update_segments_type IS TABLE OF b_dml_update_segment_def_type INDEX BY BINARY_INTEGER;

   -- Record and Table types for DML_DELETE-typed objects.
   TYPE b_dml_delete_stmt_def_type IS RECORD
      (
       table_owner      VARCHAR2(30)    := NULL,
       table_name       VARCHAR2(30)    := NULL,
       where_clause     VARCHAR2(4000)  := NULL,
       weight           NUMBER          := NULL
       );
   TYPE b_dml_delete_stmts_type IS TABLE OF b_dml_delete_stmt_def_type INDEX BY BINARY_INTEGER;

   -- Record and Table types for DML_TRUNCATE-typed objects.
   TYPE b_dml_truncate_stmt_def_type IS RECORD
      (
       table_owner      VARCHAR2(30)    := NULL,
       table_name       VARCHAR2(30)    := NULL,
       weight           NUMBER          := NULL
       );
   TYPE b_dml_truncate_stmts_type IS TABLE OF b_dml_truncate_stmt_def_type INDEX BY BINARY_INTEGER;

   -- Record and Table types for PLSQL_TEXT-typed objects.
   TYPE b_plsql_text_def_type IS RECORD
      (
       plsql_text       VARCHAR2(4000)  := NULL,
       table_owner      VARCHAR2(30)    := NULL, --used for table-specific splittable pl/sqls
       table_name       VARCHAR2(30)    := NULL,
       weight           NUMBER          := NULL
       );
   TYPE b_plsql_texts_type IS TABLE OF b_plsql_text_def_type INDEX BY BINARY_INTEGER;

   -- Holds metadata concering the dscram_run entity
   TYPE b_run_type IS RECORD
      (
       object_id                NUMBER          := NULL,
       run_id                   NUMBER          := NULL,
       run_mode                 VARCHAR2(30)    := NULL,
       valid_check_interval     NUMBER          := NULL,
       num_bundles              NUMBER          := NULL,
       weight                   NUMBER          := NULL,
       assigned_physical_weight NUMBER          := 0
       );

   -- Holds metadata concering the dscram_bundle entity
   TYPE b_bundle_def_type IS RECORD
      (
       bundle_id                NUMBER          := NULL,
       target_hostname          VARCHAR2(256)   := NULL,
       workers_allowed          NUMBER          := NULL,
       batch_size               NUMBER          := NULL,
       min_parallel_unit_weight NUMBER          := NULL,
       weight                   NUMBER          := NULL,
       assigned_physical_weight NUMBER          := 0,
       assigned_task_count      NUMBER          := 0
       );
   TYPE b_bundles_type IS TABLE OF b_bundle_def_type INDEX BY BINARY_INTEGER;

   -- Holds metadata related to a particular domain
   TYPE b_domain_metadata_type IS RECORD
      (
       -- TODO: allow domain_metadata to specify a target_hostname to allow user-driven task partitioning.
       weight                   NUMBER          := NULL,
       priority                 NUMBER          := NULL,
       phase                    NUMBER          := NULL,
       workers_allowed          NUMBER          := NULL,
       disable_splitting        VARCHAR2(3)     := NULL,
       error_fatality_level     VARCHAR2(30)    := NULL,
       batch_size               NUMBER          := NULL
       );
   -- Map from object_type(may be null) to domain_metadata record
   TYPE b_domain_obj_metadata_map_type IS TABLE OF b_domain_metadata_type INDEX BY VARCHAR2(30);
   -- Map from domain name to (Map of object types-> domain metadata).  Allows us to stripe metadata by particular types of
   -- objects.
   TYPE b_domain_metadata_map_type IS TABLE OF b_domain_obj_metadata_map_type INDEX BY VARCHAR2(120);

   -- Map from a host name to the bundle object_id that represents it
   TYPE b_host_name_map_type IS TABLE OF NUMBER INDEX BY VARCHAR2(256);

   -- Map from column_name -> object_id
   TYPE b_column_name_map_type IS TABLE OF NUMBER INDEX BY VARCHAR2(30);

   -- Map from where_clause -> map of column_name->object_id
   TYPE b_where_clause_column_map_type IS TABLE OF b_column_name_map_type INDEX BY VARCHAR2(4000);

   -- Map from where_clause -> list of object_ids
   TYPE b_where_clause_map_type IS TABLE OF NUMBER INDEX BY VARCHAR2(4000);

   -- Stores references to the various objects under a given table owner/name
   TYPE b_table_objects_def_type IS RECORD
      (
       update_map       b_where_clause_column_map_type,
       delete_map       b_where_clause_map_type,
       plsqls           b_number_list_type := b_number_list_type()
       );

   -- Map from table_name -> table_objects_def_type struct
   TYPE b_table_name_map_type IS TABLE OF b_table_objects_def_type INDEX BY VARCHAR2(30);

   -- Map from table_owner -> map from table_name->table_objects struct containing corresponding object_ids
   TYPE b_table_bound_map_type IS TABLE OF b_table_name_map_type INDEX BY VARCHAR2(30);

   --*********
   --State
   --*********

   --b_config_instance_id               NUMBER := NULL;
   -- Package level hash-tables to store parsed data fetched from
   b_objects                    b_objects_type;
   b_dml_update_segments        b_dml_update_segments_type;
   b_dml_delete_stmts           b_dml_delete_stmts_type;
   b_dml_truncate_stmts         b_dml_truncate_stmts_type;
   b_plsql_texts                b_plsql_texts_type;

   b_primary_domains            b_primary_domains_type;
   b_domain_metadata_map        b_domain_metadata_map_type;

   b_dependency_groups          b_dependency_groups_type;
   b_domain_to_group_map        b_domain_to_group_map_type; --transient, used while coalescing domains into dependency groups

   b_run                        b_run_type;
   b_bundles                    b_bundles_type;

   b_host_name_map              b_host_name_map_type;
   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Private, allocates a new property definition type
   FUNCTION CREATE_PROPERTY_DEF(p_property_id           IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                p_datatype              IN VARCHAR2,
                                p_canonical_value       IN VARCHAR2)
      RETURN b_property_def_type
   IS
      l_property        b_property_def_type;
   BEGIN
      l_property.property_id            := p_property_id;
      l_property.property_name          := p_property_name;
      l_property.datatype               := p_datatype;
      l_property.canonical_value        := p_canonical_value;

      RETURN l_property;
   END;

   -- Private, allocates a new object definition type
   FUNCTION CREATE_OBJECT_DEF(p_object_id       IN NUMBER,
                              p_object_type     IN VARCHAR2,
                              p_target_type     IN VARCHAR2 DEFAULT NULL,
                              p_target_id       IN NUMBER DEFAULT NULL)
      RETURN b_object_def_type
   IS
      l_object  b_object_def_type;
   BEGIN
      l_object.object_id        := p_object_id;
      l_object.object_type      := p_object_type;
      l_object.target_type      := p_target_type;
      l_object.target_id        := p_target_id;

      RETURN l_object;
   END;

   -- Private, allocates a new property definition type
   FUNCTION CREATE_DEPENDENCY_GROUP_DEF(p_primary_domain        IN VARCHAR2)
      RETURN b_dependency_group_def_type
   IS
      l_group   b_dependency_group_def_type;
   BEGIN
      l_group.primary_domains           := b_domain_list_type(p_primary_domain);

      RETURN l_group;
   END;

   -- Private, allocates a new property definition type
   FUNCTION CREATE_BUNDLE_DEF(p_target_hostname         IN VARCHAR2)

      RETURN b_bundle_def_type
   IS
      l_bundle  b_bundle_def_type;
   BEGIN
      l_bundle.target_hostname          := p_target_hostname;
      l_bundle.workers_allowed          := GET_DEFAULT_NUM_WORKERS;
      l_bundle.batch_size               := GET_DEFAULT_BATCH_SIZE;
      l_bundle.min_parallel_unit_weight := GET_DFLT_MIN_PARALLEL_WEIGHT;

      RETURN l_bundle;
   END;

   -- Private, allocates a new table_objects_type.
   FUNCTION CREATE_TABLE_OBJECTS_DEF
      RETURN b_table_objects_def_type
   IS
      l_table_objects   b_table_objects_def_type;
   BEGIN

      RETURN l_table_objects;
   END;

   -- Private, attach an error message
   PROCEDURE MARK_OBJECT_AS_ERRORED(px_object           IN OUT NOCOPY b_object_def_type,
                                    p_message           IN VARCHAR2)
   IS
   BEGIN
      px_object.new_errors_found_flag := FND_API.G_TRUE;
      IF px_object.new_message IS NULL THEN
         px_object.new_message := p_message;
      ELSE
         px_object.new_message := px_object.new_message||', '||p_message;
      END IF;
      px_object.is_dirty := TRUE;
      RETURN;
   END;

   -- Private, attach an error message
   PROCEDURE MARK_OBJECT_AS_ERRORED(p_object_id         IN NUMBER,
                                    p_message           IN VARCHAR2)
   IS
   BEGIN
      b_objects(p_object_id).new_errors_found_flag := FND_API.G_TRUE;
      IF b_objects(p_object_id).new_message IS NULL THEN
         b_objects(p_object_id).new_message := p_message;
      ELSE
         b_objects(p_object_id).new_message := b_objects(p_object_id).new_message||', '||p_message;
      END IF;
      b_objects(p_object_id).is_dirty := TRUE;
      RETURN;
   END;

   -- Wrapper on other mark_object_as_errored calls for exceptions.
   PROCEDURE MARK_OBJECT_AS_ERRORED(p_object_id         IN NUMBER,
                                    p_ctxt              IN VARCHAR2,
                                    p_error_code        IN NUMBER,
                                    p_error_msg         IN VARCHAR2)
   IS
      l_msg     VARCHAR2(4000);
   BEGIN
      l_msg := 'Exception: (Code('||p_error_code||'), Message("'||p_error_msg||'"))';
      fnd_oam_debug.log(3, p_ctxt, l_msg);
      l_msg := '['||p_ctxt||']'||l_msg;
      MARK_OBJECT_AS_ERRORED(p_object_id,
                             l_msg);
   END;

   -- Private, attach a warning message
   PROCEDURE MARK_OBJECT_WITH_WARNING(p_object_id       IN NUMBER,
                                      p_ctxt            IN VARCHAR2,
                                      p_message         IN VARCHAR2)
   IS
      l_prefix  VARCHAR2(30) := 'WARNING: ';
      l_msg     VARCHAR2(4000);
   BEGIN
      -- prepare the message
      IF length(p_message) + length(l_prefix) < 4000 THEN
         l_msg := l_prefix||p_message;
      ELSE
         l_msg := p_message;
      END IF;
      --don't log a level 3 because this is a common case.
      fnd_oam_debug.log(1, p_ctxt, l_msg);

      IF b_objects(p_object_id).new_message IS NULL THEN
         b_objects(p_object_id).new_message := l_msg;
      ELSE
         b_objects(p_object_id).new_message := b_objects(p_object_id).new_message||', '||l_msg;
      END IF;
      b_objects(p_object_id).is_dirty := TRUE;

      RETURN;
   END;

   -- Private, helper to the CACHE_<OBJECT_TYPE> procedures to handle properties
   -- which are common by setting them in the object.  Returns a boolean of whether the property was
   -- handled sucessfully.
   PROCEDURE HANDLE_INVALID_PROPERTY(p_ctxt             IN VARCHAR2,
                                     px_object          IN OUT NOCOPY b_object_def_type,
                                     px_prop            IN OUT NOCOPY b_property_def_type,
                                     p_error_code       IN NUMBER,
                                     p_error_msg        IN VARCHAR2)
   IS
      l_msg             VARCHAR2(4000);
   BEGIN
      l_msg := 'Invalid Property "'||px_prop.property_name||'"('||px_prop.property_id||'), Error: (Code('||p_error_code||'), Message("'||p_error_msg||'"))';
      fnd_oam_debug.log(3, p_ctxt, l_msg);
      MARK_OBJECT_AS_ERRORED(px_object,
                             l_msg);
   END;

   -- Private, used to mark an object as errored when an unknown property is seen.  This can be made a warning but
   -- for now it's an error to keep people from seeding attributes that are ignored by the engine.
   PROCEDURE HANDLE_UNKNOWN_PROPERTY(p_ctxt             IN VARCHAR2,
                                     px_object          IN OUT NOCOPY b_object_def_type,
                                     px_prop            IN OUT NOCOPY b_property_def_type)
   IS
      l_msg             VARCHAR2(4000);
   BEGIN
      l_msg := 'Unrecognized Property: '||px_prop.property_name||'('||px_prop.property_id||')';
      fnd_oam_debug.log(3, p_ctxt, l_msg);
      --unrecognized property
      MARK_OBJECT_AS_ERRORED(px_object,
                             l_msg);
   END;

   -- Private, helper to the CACHE_<OBJECT_TYPE> procedures to handle properties
   -- which are common by setting them in the object.  Returns a boolean of whether the property was
   -- handled sucessfully.
   FUNCTION HANDLE_COMMON_PROPERTY(px_object            IN OUT NOCOPY b_object_def_type,
                                   px_prop              IN OUT NOCOPY b_property_def_type)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'HANDLE_COMMON_PROPERTY';
      l_msg             VARCHAR2(4000);
   BEGIN
      CASE px_prop.property_name
         WHEN FND_OAM_DSCFG_API_PKG.G_PROP_PRIMARY_DOMAIN THEN
            --force all domains to be case insensitive
            px_object.primary_domain := UPPER(TRIM(px_prop.canonical_value));

         WHEN FND_OAM_DSCFG_API_PKG.G_PROP_ADDITIONAL_DOMAIN THEN
            --the additional domain can't be null
            IF px_prop.canonical_value IS NULL THEN
               l_msg := 'Additional Domain properties cannot have NULL values.';
               fnd_oam_debug.log(3, l_ctxt, l_msg);
               --unrecognized property
               MARK_OBJECT_AS_ERRORED(px_object,
                                      l_msg);
               RETURN FALSE;
            END IF;

            --append the domain
            fnd_oam_debug.log(1, l_ctxt, 'found additional_domain: '||px_prop.canonical_value);
            IF px_object.additional_domains IS NOT NULL THEN
               px_object.additional_domains.EXTEND;
               px_object.additional_domains(px_object.additional_domains.COUNT) := UPPER(TRIM(px_prop.canonical_value));
            ELSE
               px_object.additional_domains := b_domain_list_type(UPPER(TRIM(px_prop.canonical_value)));
            END IF;

         ELSE
            HANDLE_UNKNOWN_PROPERTY(l_ctxt,
                                    px_object,
                                    px_prop);
            RETURN FALSE;
      END CASE;

      -- sucessfully handled
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         HANDLE_INVALID_PROPERTY(l_ctxt,
                                 px_object,
                                 px_prop,
                                 SQLCODE,
                                 SQLERRM);
         RETURN FALSE;
   END;

   -- Private, simple helper to get rid of extra spaces and the 'where' if present.
   PROCEDURE CLEANUP_WHERE_CLAUSE(px_where_clause       IN OUT NOCOPY VARCHAR2)
   IS
      l_str     VARCHAR2(30);
   BEGIN
      px_where_clause := TRIM(px_where_clause);
      IF UPPER(SUBSTR(px_where_clause, 1, 6)) = 'WHERE ' THEN
         px_where_clause := SUBSTR(px_where_clause, 7);
      END IF;
   END;

   -- Private, Helper to ADD_ENGINE_UNITS_FOR_DOMAIN to validate an object of type DML_UPDATE_SEGMENT.
   -- Returns TRUE if valid.
   FUNCTION VALIDATE_DML_UPDATE_SEGMENT(px_object       IN OUT NOCOPY b_object_def_type,
                                        p_segment       IN b_dml_update_segment_def_type)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_DML_UPDATE_SEGMENT';

      l_valid                   BOOLEAN := TRUE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --check for our properties, add messages for each not found
      IF p_segment.table_owner IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_OWNER);
         l_valid := FALSE;
      END IF;

      IF p_segment.table_name IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_NAME);
         l_valid := FALSE;
      END IF;

      IF p_segment.column_name IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_COLUMN_NAME);
         l_valid := FALSE;
      END IF;

      IF p_segment.new_column_value IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_NEW_COLUMN_VALUE);
         l_valid := FALSE;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Verdict: '||FND_OAM_DSCFG_UTILS_PKG.BOOLEAN_TO_CANONICAL(l_valid));

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN l_valid;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to CACHE_OBJECT to cache an object of type DML_UPDATE_SEGMENT
   --
   PROCEDURE CACHE_DML_UPDATE_SEGMENT(px_object         IN OUT NOCOPY b_object_def_type,
                                      px_object_props   IN OUT NOCOPY b_properties_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CACHE_DML_UPDATE_SEGMENT';

      l_dml_update_segment      b_dml_update_segment_def_type;

      k                         NUMBER;
      l_prop                    b_property_def_type := NULL;
      l_msg                     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --loop through the object properties, filling in the details of the dml_update_segment
      BEGIN
         k := px_object_props.FIRST;
         WHILE k IS NOT NULL LOOP
            l_prop := px_object_props(k);

            CASE l_prop.property_name
               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_OWNER THEN
                  l_dml_update_segment.table_owner := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_NAME THEN
                  l_dml_update_segment.table_name := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_COLUMN_NAME THEN
                  l_dml_update_segment.column_name := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_NEW_COLUMN_VALUE THEN
                  l_dml_update_segment.new_column_value := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WHERE_CLAUSE THEN
                  l_dml_update_segment.where_clause := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WEIGHT_MODIFIER THEN
                  l_dml_update_segment.weight_modifier := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               ELSE
                  --defer to the common handler if none of the object_type-specific property names match.
                  IF NOT HANDLE_COMMON_PROPERTY(px_object,
                                                l_prop) THEN
                     fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                     RETURN;
                  END IF;
            END CASE;

            k := px_object_props.NEXT(k);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            -- covers character string buffer too small
            HANDLE_INVALID_PROPERTY(l_ctxt,
                                    px_object,
                                    l_prop,
                                    SQLCODE,
                                    SQLERRM);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      -- only cache it if it's valid
      IF VALIDATE_DML_UPDATE_SEGMENT(px_object,
                                     l_dml_update_segment) THEN

         --if it's valid, do some cleanup
         l_dml_update_segment.table_owner := UPPER(TRIM(l_dml_update_segment.table_owner));
         l_dml_update_segment.table_name := UPPER(TRIM(l_dml_update_segment.table_name));
         IF l_dml_update_segment.where_clause IS NOT NULL THEN
            CLEANUP_WHERE_CLAUSE(l_dml_update_segment.where_clause);
         END IF;

         --default the primary_domain using the table_owner.table_name if not specified as a property
         IF px_object.primary_domain IS NULL THEN
            px_object.primary_domain := l_dml_update_segment.table_owner||'.'||l_dml_update_segment.table_name;
         END IF;

         --put it in the dml_update_segments cache
         b_dml_update_segments(px_object.object_id) := l_dml_update_segment;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, Helper to ADD_ENGINE_UNITS_FOR_DOMAIN to validate an object of type DML_DELETE_STMT
   -- Returns TRUE if valid.
   FUNCTION VALIDATE_DML_DELETE_STMT(px_object  IN OUT NOCOPY b_object_def_type,
                                     p_stmt     IN b_dml_delete_stmt_def_type)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_DML_DELETE_STMT';

      l_valid                   BOOLEAN := TRUE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --check for our properties, add messages for each not found
      IF p_stmt.table_owner IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_OWNER);
         l_valid := FALSE;
      END IF;

      IF p_stmt.table_name IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_NAME);
         l_valid := FALSE;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Verdict: '||FND_OAM_DSCFG_UTILS_PKG.BOOLEAN_TO_CANONICAL(l_valid));

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN l_valid;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to CACHE_OBJECT to cache an object of type DML_DELETE_STMT
   --
   PROCEDURE CACHE_DML_DELETE_STMT(px_object            IN OUT NOCOPY b_object_def_type,
                                   px_object_props      IN OUT NOCOPY b_properties_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CACHE_DML_DELETE_STMT';

      l_dml_delete_stmt         b_dml_delete_stmt_def_type;

      k                         NUMBER;
      l_prop                    b_property_def_type := NULL;
      l_msg                     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --loop through the object properties, filling in the details of the dml_delete_stmt
      BEGIN
         k := px_object_props.FIRST;
         WHILE k IS NOT NULL LOOP
            l_prop := px_object_props(k);

            CASE l_prop.property_name
               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_OWNER THEN
                  l_dml_delete_stmt.table_owner := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_NAME THEN
                  l_dml_delete_stmt.table_name := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WHERE_CLAUSE THEN
                  l_dml_delete_stmt.where_clause := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WEIGHT THEN
                  l_dml_delete_stmt.weight := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               ELSE
                  --defer to the common handler if none of the object_type-specific property names match.
                  IF NOT HANDLE_COMMON_PROPERTY(px_object,
                                                l_prop) THEN
                     fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                     RETURN;
                  END IF;
            END CASE;

            k := px_object_props.NEXT(k);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            -- covers character string buffer too small
            HANDLE_INVALID_PROPERTY(l_ctxt,
                                    px_object,
                                    l_prop,
                                    SQLCODE,
                                    SQLERRM);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      -- only cache it if it's valid
      IF VALIDATE_DML_DELETE_STMT(px_object,
                                  l_dml_delete_stmt) THEN

         --if it's valid, do some cleanup
         l_dml_delete_stmt.table_owner := UPPER(TRIM(l_dml_delete_stmt.table_owner));
         l_dml_delete_stmt.table_name := UPPER(TRIM(l_dml_delete_stmt.table_name));
         IF l_dml_delete_stmt.where_clause IS NOT NULL THEN
            CLEANUP_WHERE_CLAUSE(l_dml_delete_stmt.where_clause);
         END IF;

         --default the primary_domain using the table_owner.table_name if not specified as a property
         IF px_object.primary_domain IS NULL THEN
            px_object.primary_domain := l_dml_delete_stmt.table_owner||'.'||l_dml_delete_stmt.table_name;
         END IF;

         --put it in the dml_delete_stmts cache
         b_dml_delete_stmts(px_object.object_id) := l_dml_delete_stmt;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, Helper to ADD_ENGINE_UNITS_FOR_DOMAIN to validate an object of type DML_TRUNCATE_STMT
   -- Returns TRUE if valid.
   FUNCTION VALIDATE_DML_TRUNCATE_STMT(px_object        IN OUT NOCOPY b_object_def_type,
                                       p_stmt           IN b_dml_truncate_stmt_def_type)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_DML_TRUNCATE_STMT';

      l_valid                   BOOLEAN := TRUE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --check for our properties, add messages for each not found
      IF p_stmt.table_owner IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_OWNER);
         l_valid := FALSE;
      END IF;

      IF p_stmt.table_name IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_NAME);
         l_valid := FALSE;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Verdict: '||FND_OAM_DSCFG_UTILS_PKG.BOOLEAN_TO_CANONICAL(l_valid));

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN l_valid;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to CACHE_OBJECT to cache an object of type DML_TRUNCATE_STMT
   --
   PROCEDURE CACHE_DML_TRUNCATE_STMT(px_object          IN OUT NOCOPY b_object_def_type,
                                     px_object_props    IN OUT NOCOPY b_properties_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CACHE_DML_TRUNCATE_STMT';

      l_dml_truncate_stmt       b_dml_truncate_stmt_def_type;

      k                         NUMBER;
      l_prop                    b_property_def_type := NULL;
      l_msg                     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --loop through the object properties, filling in the details of the dml_truncate_stmt
      BEGIN
         k := px_object_props.FIRST;
         WHILE k IS NOT NULL LOOP
            l_prop := px_object_props(k);

            CASE l_prop.property_name
               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_OWNER THEN
                  l_dml_truncate_stmt.table_owner := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_NAME THEN
                  l_dml_truncate_stmt.table_name := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WEIGHT THEN
                  l_dml_truncate_stmt.weight := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               ELSE
                  --defer to the common handler if none of the object_type-specific property names match.
                  IF NOT HANDLE_COMMON_PROPERTY(px_object,
                                                l_prop) THEN
                     fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                     RETURN;
                  END IF;
            END CASE;

            k := px_object_props.NEXT(k);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            -- covers character string buffer too small
            HANDLE_INVALID_PROPERTY(l_ctxt,
                                    px_object,
                                    l_prop,
                                    SQLCODE,
                                    SQLERRM);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      -- only cache it if it's valid
      IF VALIDATE_DML_TRUNCATE_STMT(px_object,
                                    l_dml_truncate_stmt) THEN

         --if it's valid, do some cleanup
         l_dml_truncate_stmt.table_owner := UPPER(TRIM(l_dml_truncate_stmt.table_owner));
         l_dml_truncate_stmt.table_name := UPPER(TRIM(l_dml_truncate_stmt.table_name));

         --default the primary_domain using the table_owner.table_name if not specified as a property
         IF px_object.primary_domain IS NULL THEN
            px_object.primary_domain := l_dml_truncate_stmt.table_owner||'.'||l_dml_truncate_stmt.table_name;
         END IF;

         --put it in the dml_truncate_stmts cache
         b_dml_truncate_stmts(px_object.object_id) := l_dml_truncate_stmt;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, Helper to ADD_ENGINE_UNITS_FOR_DOMAIN to validate an object of type PLSQL_TEXT
   -- Returns TRUE if valid.
   FUNCTION VALIDATE_PLSQL_TEXT(px_object       IN OUT NOCOPY b_object_def_type,
                                p_plsql         IN b_plsql_text_def_type)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_PLSQL_TEXT';

      l_valid                   BOOLEAN := TRUE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --check for our properties, add messages for each not found
      IF p_plsql.plsql_text IS NULL THEN
         MARK_OBJECT_AS_ERRORED(px_object,
                                'Missing Property: '||FND_OAM_DSCFG_API_PKG.G_PROP_PLSQL_TEXT);
         l_valid := FALSE;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Verdict: '||FND_OAM_DSCFG_UTILS_PKG.BOOLEAN_TO_CANONICAL(l_valid));

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN l_valid;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to CACHE_OBJECT to cache an object of type PLSQL_TEXT
   --
   PROCEDURE CACHE_PLSQL_TEXT(px_object         IN OUT NOCOPY b_object_def_type,
                              px_object_props   IN OUT NOCOPY b_properties_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CACHE_PLSQL_TEXT';

      l_plsql_text      b_plsql_text_def_type;

      k                         NUMBER;
      l_prop                    b_property_def_type := NULL;
      l_msg                     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --loop through the object properties, filling in the details of the plsql_text
      BEGIN
         k := px_object_props.FIRST;
         WHILE k IS NOT NULL LOOP
            l_prop := px_object_props(k);

            CASE l_prop.property_name
               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_PLSQL_TEXT THEN
                  l_plsql_text.plsql_text := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_OWNER THEN
                  l_plsql_text.table_owner := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TABLE_NAME THEN
                  l_plsql_text.table_name := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WEIGHT THEN
                  l_plsql_text.weight := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               ELSE
                  --defer to the common handler if none of the object_type-specific property names match.
                  IF NOT HANDLE_COMMON_PROPERTY(px_object,
                                                l_prop) THEN
                     fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                     RETURN;
                  END IF;
            END CASE;

            k := px_object_props.NEXT(k);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            -- covers character string buffer too small
            HANDLE_INVALID_PROPERTY(l_ctxt,
                                    px_object,
                                    l_prop,
                                    SQLCODE,
                                    SQLERRM);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      -- only cache it if it's valid
      IF VALIDATE_PLSQL_TEXT(px_object,
                             l_plsql_text) THEN

         -- try to default the primary_domain using the table_owner/name if specified
         IF px_object.primary_domain IS NULL THEN
            IF l_plsql_text.table_owner IS NOT NULL AND l_plsql_text.table_name IS NOT NULL THEN
               px_object.primary_domain := l_plsql_text.table_owner||'.'||l_plsql_text.table_name;
            END IF;
         END IF;

         --put it in the plsql_texts cache
         b_plsql_texts(px_object.object_id) := l_plsql_text;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to CACHE_OBJECT to cache the run metadata information
   --
   PROCEDURE CACHE_RUN(px_object        IN OUT NOCOPY b_object_def_type,
                       px_object_props  IN OUT NOCOPY b_properties_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CACHE_RUN';

      k                         NUMBER;
      l_prop                    b_property_def_type := NULL;
      l_msg                     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --if we've already initialized the run metadata, this object is invalid, we need only one
      --run metadata entry per config instance
      IF b_run.object_id IS NOT NULL THEN
         l_msg := 'Run Metadata already defined by Object ID: "'||b_run.object_id||'"';
         fnd_oam_debug.log(3, l_ctxt, l_msg);
         MARK_OBJECT_AS_ERRORED(px_object,
                                l_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --loop through the object properties, filling in the details of the run object
      BEGIN
         k := px_object_props.FIRST;
         WHILE k IS NOT NULL LOOP
            l_prop := px_object_props(k);

            CASE l_prop.property_name
               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_RUN_ID THEN
                  b_run.run_id := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_RUN_MODE THEN
                  b_run.run_mode := l_prop.canonical_value;

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_VALID_CHECK_INTERVAL THEN
                  b_run.valid_check_interval := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_NUM_BUNDLES THEN
                  b_run.num_bundles := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WEIGHT THEN
                  b_run.weight := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               ELSE
                  --invalid property
                  HANDLE_UNKNOWN_PROPERTY(l_ctxt,
                                          px_object,
                                          l_prop);
                  fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                  RETURN;
            END CASE;

            k := px_object_props.NEXT(k);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            -- covers character string buffer too small
            HANDLE_INVALID_PROPERTY(l_ctxt,
                                    px_object,
                                    l_prop,
                                    SQLCODE,
                                    SQLERRM);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      --defer validation until the GENERATE-phase because we need to have read in all objects to
      --get definitive answers.

      --set the object_id to mark that we've seen runtime metadata
      b_run.object_id := px_object.object_id;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to CACHE_OBJECT to cache the metadata for a bundle
   --
   PROCEDURE CACHE_BUNDLE(px_object             IN OUT NOCOPY b_object_def_type,
                          px_object_props       IN OUT NOCOPY b_properties_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CACHE_BUNDLE';

      l_bundle                  b_bundle_def_type;

      k                         NUMBER;
      l_prop                    b_property_def_type := NULL;
      l_msg                     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --if we've already seen run.num_bundles of bundles, this one is too many
      IF b_run.num_bundles IS NOT NULL AND b_run.num_bundles = b_bundles.COUNT THEN
         l_msg := 'Already seen expected number of bundles: "'||b_run.num_bundles||'".';
         fnd_oam_debug.log(3, l_ctxt, l_msg);
         MARK_OBJECT_AS_ERRORED(px_object,
                                l_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --loop through the object properties, filling in the details of the run object
      BEGIN
         k := px_object_props.FIRST;
         WHILE k IS NOT NULL LOOP
            l_prop := px_object_props(k);

            CASE l_prop.property_name
               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_BUNDLE_ID THEN
                  l_bundle.bundle_id := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_TARGET_HOSTNAME THEN
                  l_bundle.target_hostname := UPPER(l_prop.canonical_value);

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WORKERS_ALLOWED THEN
                  l_bundle.workers_allowed := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_BATCH_SIZE THEN
                  l_bundle.batch_size := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_MIN_PARALLEL_WEIGHT THEN
                  l_bundle.min_parallel_unit_weight := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WEIGHT THEN
                  l_bundle.weight := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               ELSE
                  --invalid property
                  HANDLE_UNKNOWN_PROPERTY(l_ctxt,
                                          px_object,
                                          l_prop);
                  fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                  RETURN;
            END CASE;

            k := px_object_props.NEXT(k);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            -- covers character string buffer too small
            HANDLE_INVALID_PROPERTY(l_ctxt,
                                    px_object,
                                    l_prop,
                                    SQLCODE,
                                    SQLERRM);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      --defer validation until the GENERATE-phase because we need to have read in all objects to
      --get definitive answers.

      --add the bundle to the bundles list
      b_bundles(px_object.object_id) := l_bundle;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

/*
   --TODO:
   -- Private, helper to CACHE_OBJECT to cache the metadata for a domain
   --
   PROCEDURE CACHE_DOMAIN_METADATA(px_object            IN OUT NOCOPY b_object_def_type,
                                   px_object_props      IN OUT NOCOPY b_properties_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CACHE_DOMAIN_METADATA';

      l_domain                          VARCHAR2(120) := NULL;
      l_table_owner                     VARCHAR2(30) := NULL;
      l_table_name                      VARCHAR2(30) := NULL;
      l_object_type                     VARCHAR2(30) := NULL;
      l_domain_metadata                 b_domain_metadata_type;
      l_domain_obj_metadata_map         b_domain_obj_metadata_map_type;

      k                                 NUMBER;
      l_prop                            b_property_def_type := NULL;
      l_msg                             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --loop through the object properties, filling in the details of the run object
      BEGIN
         k := px_object_props.FIRST;
         WHILE k IS NOT NULL LOOP
            l_prop := px_object_props(k);

            CASE l_prop.property_name
               WHEN FND_OAM_DSCFG_API_PKG.G_PROP_WEIGHT THEN
                  l_bundle.weight := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_prop.canonical_value);

               ELSE
                  --invalid property
                  HANDLE_UNKNOWN_PROPERTY(l_ctxt,
                                          px_object,
                                          l_prop);
                  fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                  RETURN;
            END CASE;

            k := px_object_props.NEXT(k);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            -- covers character string buffer too small
            HANDLE_INVALID_PROPERTY(l_ctxt,
                                    px_object,
                                    l_prop,
                                    SQLCODE,
                                    SQLERRM);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      --add the bundle to the bundles list
      --b_bundles(px_object.object_id) := l_bundle;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;
*/
   -- Private, used by FETCH_COMPILABLE_OBJECTS to put a new object into the various
   -- package caches
   PROCEDURE CACHE_OBJECT(px_object             IN OUT NOCOPY b_object_def_type,
                          px_object_props       IN OUT NOCOPY b_properties_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CACHE_OBJECT';

      l_number_list             b_number_list_type;
      l_msg                     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --prepare the object and cache it in the object_type-specific cache
      CASE px_object.object_type
         WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_UPDATE_SEGMENT THEN
            CACHE_DML_UPDATE_SEGMENT(px_object,
                                     px_object_props);
         WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_DELETE_STMT THEN
            CACHE_DML_DELETE_STMT(px_object,
                                  px_object_props);
         WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_TRUNCATE_STMT THEN
            CACHE_DML_TRUNCATE_STMT(px_object,
                                    px_object_props);
         WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_PLSQL_TEXT THEN
            CACHE_PLSQL_TEXT(px_object,
                             px_object_props);
         WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_RUN THEN
            CACHE_RUN(px_object,
                      px_object_props);
         WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_BUNDLE THEN
            CACHE_BUNDLE(px_object,
                         px_object_props);
         --WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_DOMAIN_METADATA THEN
         --   CACHE_DOMAIN_METADATA(px_object,
         --                       px_object_props);
         ELSE
            --unknown object type, add a message, set the errors flag
            l_msg := 'Object Type: "'||px_object.object_type||'" not supported';
            fnd_oam_debug.log(3, l_ctxt, l_msg);
            MARK_OBJECT_AS_ERRORED(px_object,
                                   l_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END CASE;

      --check that the object came back with a primary domain
      IF px_object.primary_domain IS NULL AND
         px_object.object_type NOT IN (FND_OAM_DSCFG_API_PKG.G_OTYPE_RUN,
                                       FND_OAM_DSCFG_API_PKG.G_OTYPE_BUNDLE) THEN
         l_msg := 'Object has no primary domain - this is not allowed.';
         fnd_oam_debug.log(3, l_ctxt, l_msg);
         MARK_OBJECT_AS_ERRORED(px_object,
                                l_msg);
      END IF;

      --store the object in the b_objects cache in any case
      b_objects(px_object.object_id) := px_object;

      --so we don't have to traverse the object list right after this, go ahead and add this object to
      --the primary domains cache if it hasn't errored out yet.
      IF px_object.new_errors_found_flag IS NULL AND px_object.primary_domain IS NOT NULL THEN
         fnd_oam_debug.log(1, l_ctxt, 'Caching valid primary_domain('||px_object.primary_domain||'), object_id('||px_object.object_id||')');
         IF b_primary_domains.EXISTS(px_object.primary_domain) THEN
            --add this object_id
            b_primary_domains(px_object.primary_domain).EXTEND;
            b_primary_domains(px_object.primary_domain)(b_primary_domains(px_object.primary_domain).COUNT) := px_object.object_id;
         ELSE
            --new number list
            l_number_list := b_number_list_type(px_object.object_id);
            b_primary_domains(px_object.primary_domain) := l_number_list;
         END IF;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         --any errors in the CACHE_<OBJECT_TYPE> come up to this level as program_errors, catch them and swallow
         --so we can work try other objects
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private
   -- Helper to compile_config_instance to query out all objects
   PROCEDURE FETCH_COMPILABLE_OBJECTS(p_config_instance_id      IN NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'FETCH_COMPILABLE_OBJECTS';

      -- temp variables for bulk collecting objects
      l_object_ids      DBMS_SQL.NUMBER_TABLE;
      l_object_types    DBMS_SQL.VARCHAR2_TABLE;
      l_target_types    DBMS_SQL.VARCHAR2_TABLE;
      l_target_ids      DBMS_SQL.NUMBER_TABLE;

      TYPE long_varchar2_table_type IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

      -- temp variables for bulk collecting properties
      l_prop_ids                DBMS_SQL.NUMBER_TABLE;
      l_prop_object_ids         DBMS_SQL.NUMBER_TABLE;
      l_prop_names              DBMS_SQL.VARCHAR2_TABLE;
      l_datatypes               DBMS_SQL.VARCHAR2_TABLE;
      l_canonical_values        long_varchar2_table_type;

      -- variables for traversal of the bulk collections
      l_curr_object_id          NUMBER;
      l_curr_object             b_object_def_type;
      l_curr_prop               b_property_def_type;
      l_curr_object_props       b_properties_type;
      l_curr_object_index       NUMBER;
      l_curr_prop_index         NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      fnd_oam_debug.log(1, l_ctxt, 'Fetching compilable objects...');
      -- obtain all compilable objects
      SELECT object_id, object_type, target_type, target_id
         BULK COLLECT INTO l_object_ids, l_object_types, l_target_types, l_target_ids
         FROM fnd_oam_dscfg_objects
         WHERE config_instance_id = p_config_instance_id
         AND object_type IN (FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_UPDATE_SEGMENT,
                             FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_DELETE_STMT,
                             FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_TRUNCATE_STMT,
                             FND_OAM_DSCFG_API_PKG.G_OTYPE_PLSQL_TEXT,
                             FND_OAM_DSCFG_API_PKG.G_OTYPE_RUN,
                             FND_OAM_DSCFG_API_PKG.G_OTYPE_BUNDLE,
                             FND_OAM_DSCFG_API_PKG.G_OTYPE_DOMAIN_METADATA)
         ORDER BY object_id DESC;
      fnd_oam_debug.log(1, l_ctxt, '...Done');

      -- since we can't use l_object_ids to only get the properties we want, duplicate the object conditions above
      -- for selecting the entire list of properties
      fnd_oam_debug.log(1, l_ctxt, 'Fetching all corresponding object properties...');
      SELECT property_id, parent_id, property_name, datatype, canonical_value
         BULK COLLECT INTO l_prop_ids, l_prop_object_ids, l_prop_names, l_datatypes, l_canonical_values
         FROM fnd_oam_dscfg_properties
         WHERE parent_type = FND_OAM_DSCFG_API_PKG.G_TYPE_OBJECT
         AND parent_id in (SELECT object_id
                           FROM fnd_oam_dscfg_objects
                           WHERE config_instance_id = p_config_instance_id
                           AND object_type IN (FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_UPDATE_SEGMENT,
                                               FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_DELETE_STMT,
                                               FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_TRUNCATE_STMT,
                                               FND_OAM_DSCFG_API_PKG.G_OTYPE_PLSQL_TEXT,
                                               FND_OAM_DSCFG_API_PKG.G_OTYPE_RUN,
                                               FND_OAM_DSCFG_API_PKG.G_OTYPE_BUNDLE,
                                               FND_OAM_DSCFG_API_PKG.G_OTYPE_DOMAIN_METADATA))
         ORDER BY parent_id DESC, property_id DESC;
      fnd_oam_debug.log(1, l_ctxt, '...Done');

      --now we need to go through and create b_objects entries and b_<object_type> entries.
      l_curr_object_index := l_object_ids.FIRST;
      l_curr_prop_index := l_prop_ids.FIRST;
      WHILE l_curr_object_index IS NOT NULL LOOP
         l_curr_object_id := l_object_ids(l_curr_object_index);

         fnd_oam_debug.log(1, l_ctxt, 'Processing object_id: '||l_curr_object_id);
         --for each object create a new object def record
         l_curr_object := CREATE_OBJECT_DEF(l_curr_object_id,
                                            l_object_types(l_curr_object_index),
                                            l_target_types(l_curr_object_index),
                                            l_target_ids(l_curr_object_index));

         --now we need to snag the properties for this object
         l_curr_object_props.DELETE;
         WHILE l_curr_prop_index IS NOT NULL LOOP
            --since the l_prop_object_ids is ordered, we just need to keep going until the object id isn't ours
            IF l_prop_object_ids(l_curr_prop_index) <> l_curr_object_id THEN
               EXIT;
            END IF;

            fnd_oam_debug.log(1, l_ctxt, 'Processing property_id: '||l_prop_ids(l_curr_prop_index));
            --property belongs to this object, make a prop def and add it to the object props with the prop_id as the key
            l_curr_prop := CREATE_PROPERTY_DEF(l_prop_ids(l_curr_prop_index),
                                               l_prop_names(l_curr_prop_index),
                                               l_datatypes(l_curr_prop_index),
                                               l_canonical_values(l_curr_prop_index));
            l_curr_object_props(l_curr_prop.property_id) := l_curr_prop;

            --move to the next prop index
            l_curr_prop_index := l_prop_ids.NEXT(l_curr_prop_index);
         END LOOP;

         --now that we have the object and its list of properties, create an object_type-specific
         --cache entry
         CACHE_OBJECT(l_curr_object,
                      l_curr_object_props);

         --move on to the next object
         l_curr_object_index := l_object_ids.NEXT(l_curr_object_index);
      END LOOP;

      --all objects fetched and cached, return success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN;
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private
   PROCEDURE ADD_ADDITIONAL_DOMAIN_TO_GROUP(p_group_id          IN NUMBER,
                                            p_additional_domain IN VARCHAR2)
   IS
   BEGIN
      -- uses index by table to keep out dupes
      b_dependency_groups(p_group_id).additional_domains(p_additional_domain) := TRUE;
   END;

   -- Private
   -- Used to move the contents of one dependency group to another.  This is done by appending the list of
   -- primary_domains (because those are only listed once in any given group) and inserting the list of
   -- additional domains into the current group.  For each moved domain, we also update the domain_to_group_map.
   PROCEDURE REASSIGN_DEPENDENCY_GROUP(p_from_group_id          IN NUMBER,
                                       p_to_group_id            IN NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'REASSIGN_DEPENDENCY_GROUP';

      l_from_group              b_dependency_group_def_type;
      --l_from_primary_domains          b_domain_list_type;
      --l_from_additional_domains               b_domain_map_type;
      l_domain                  VARCHAR2(120);
      l_from_index              NUMBER;
      l_to_index                NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      fnd_oam_debug.log(1, l_ctxt, 'Reassigning group '||p_from_group_id||' to '||p_to_group_id);

      --get a local handle to the from
      l_from_group := b_dependency_groups(p_from_group_id);

      --extend and copy the primary domains
      l_to_index := b_dependency_groups(p_to_group_id).primary_domains.COUNT + 1;
      b_dependency_groups(p_to_group_id).primary_domains.EXTEND(l_from_group.primary_domains.COUNT);
      l_from_index := l_from_group.primary_domains.FIRST;
      WHILE l_from_index IS NOT NULL LOOP
         l_domain := l_from_group.primary_domains(l_from_index);
         fnd_oam_debug.log(1, l_ctxt, 'Moving primary_domain: '||l_domain);
         b_domain_to_group_map(l_domain) := p_to_group_id;
         b_dependency_groups(p_to_group_id).primary_domains(l_to_index) := l_domain;
         l_to_index := l_to_index + 1;
         l_from_index := l_from_group.primary_domains.NEXT(l_from_index);
      END LOOP;

      --insert the additional domains
      l_domain := l_from_group.additional_domains.FIRST;
      WHILE l_domain IS NOT NULL LOOP
         fnd_oam_debug.log(2, l_ctxt, 'Moving additional_domain: '||l_domain);
         b_domain_to_group_map(l_domain) := p_to_group_id;
         ADD_ADDITIONAL_DOMAIN_TO_GROUP(p_to_group_id,
                                        l_domain);
         l_domain := l_from_group.additional_domains.NEXT(l_domain);
      END LOOP;

      --remove the from group
      fnd_oam_debug.log(1, l_ctxt, 'Removing the from group.');
      b_dependency_groups.DELETE(p_from_group_id);

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private
   PROCEDURE COMPUTE_DEPENDENCY_GROUPS
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPUTE_DEPENDENCY_GROUPS';

      l_primary_domain          VARCHAR2(120);
      l_additional_domain       VARCHAR2(120);
      l_additional_domains      b_domain_list_type;
      l_object_id               NUMBER;
      l_object_ids              b_number_list_type;

      l_next_group_id   NUMBER := 1;
      l_this_group_id   NUMBER;
      l_found_group_id  NUMBER;

      k                 NUMBER;
      j                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --traverse the map of primary domains, ignore the NULL domain key, shouldn't be allowed.
      l_primary_domain := b_primary_domains.FIRST;
      WHILE l_primary_domain IS NOT NULL LOOP
         --default objects in this primary domain to the next available group_id and store
         --the bidirectional mapping between them.  All future conflicting domains will be rolled into this
         --one.
         fnd_oam_debug.log(1, l_ctxt, 'Processing primary_domain: '||l_primary_domain);
         l_this_group_id := l_next_group_id;
         fnd_oam_debug.log(1, l_ctxt, 'Given group ID: '||l_this_group_id);
         l_next_group_id := l_next_group_id + 1;
         b_domain_to_group_map(l_primary_domain) := l_this_group_id;
         b_dependency_groups(l_this_group_id) := CREATE_DEPENDENCY_GROUP_DEF(l_primary_domain);

         --get the objects in this primary domain and loop over them to look for additional domains
         --that may conflict with existing dependency groups.
         l_object_ids := b_primary_domains(l_primary_domain);
         k := l_object_ids.FIRST;
         WHILE k IS NOT NULL LOOP
            l_object_id := l_object_ids(k);
            fnd_oam_debug.log(1, l_ctxt, 'Processing domain object_id: '||l_object_id);
            -- see if the object_id has any additional domains, if it doesn't then this object produces no conflicts.
            IF b_objects(l_object_id).additional_domains IS NOT NULL THEN
               fnd_oam_debug.log(1, l_ctxt, 'Has Additional Domains');
               --loop over the additional domains
               l_additional_domains := b_objects(l_object_id).additional_domains;
               j := l_additional_domains.FIRST;
               WHILE j IS NOT NULL LOOP
                  l_additional_domain := l_additional_domains(j);
                  fnd_oam_debug.log(1, l_ctxt, 'Processing additional_domain: '||l_additional_domain);
                  --see if the additional domain has already been seen
                  IF b_domain_to_group_map.EXISTS(l_additional_domain) THEN
                     --see if the additional domain is not already in this group, if it is we don't have to do anything
                     l_found_group_id := b_domain_to_group_map(l_additional_domain);
                     IF l_found_group_id <> l_this_group_id THEN
                        --migrate the contents of the found group to the current,"this" group
                        REASSIGN_DEPENDENCY_GROUP(p_from_group_id       => l_found_group_id,
                                                  p_to_group_id         => l_this_group_id);
                     END IF;
                  ELSE
                     --hasn't been seen before, just add the domain_to_group mapping
                     b_domain_to_group_map(l_additional_domain) := l_this_group_id;
                  END IF;

                  --always add this additional domain to the current group in case the re-assign took somebody else's
                  --primary.
                  ADD_ADDITIONAL_DOMAIN_TO_GROUP(l_this_group_id,
                                                 l_additional_domain);

                  j := l_additional_domains.NEXT(j);
               END LOOP;
            END IF;
            k := l_object_ids.NEXT(k);
         END LOOP;

         l_primary_domain := b_primary_domains.NEXT(l_primary_domain);
      END LOOP;

      -- success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN;
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to COMPILE_CONFIG_INSTANCE to dump out the run entity
   PROCEDURE GENERATE_ENGINE_RUN(p_config_instance_id           IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'GENERATE_ENGINE_RUN';

      l_dbname          VARCHAR2(30);
      l_property_id     NUMBER;
      l_msg             VARCHAR2(4000);

      l_display_name    VARCHAR2(120);
      l_description     VARCHAR2(2000);
      l_language        VARCHAR2(12);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --see if we need to create a run object if none was cached on fetch
      IF b_run.object_id IS NULL THEN
         fnd_oam_debug.log(2, l_ctxt, 'Creating new run object');
         FND_OAM_DSCFG_API_PKG.ADD_OBJECT(p_object_type => FND_OAM_DSCFG_API_PKG.G_OTYPE_RUN,
                                          x_object_id   => b_run.object_id);
         fnd_oam_debug.log(2, l_ctxt, 'run object_id: '||b_run.object_id);
         --add an entry to the b_objects array so we can cache messages there
         b_objects(b_run.object_id) := CREATE_OBJECT_DEF(b_run.object_id,
                                                         FND_OAM_DSCFG_API_PKG.G_OTYPE_RUN);
      END IF;

      --validate the run mode
      IF b_run.run_mode IS NULL THEN
         b_run.run_mode := B_DEFAULT_RUN_MODE;
         FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id          => b_run.object_id,
                                                   p_property_name      => FND_OAM_DSCFG_API_PKG.G_PROP_RUN_MODE,
                                                   p_varchar2_value     => b_run.run_mode,
                                                   x_property_id        => l_property_id);
      ELSE
         IF b_run.run_mode NOT IN (FND_OAM_DSCRAM_UTILS_PKG.G_MODE_NORMAL,
                                   FND_OAM_DSCRAM_UTILS_PKG.G_MODE_TEST,
                                   FND_OAM_DSCRAM_UTILS_PKG.G_MODE_TEST_NO_EXEC,
                                   FND_OAM_DSCRAM_UTILS_PKG.G_MODE_DIAGNOSTIC) THEN
            l_msg := 'Invalid run mode specified: "'||b_run.run_mode||'".';
            fnd_oam_debug.log(3, l_ctxt, l_msg);
            MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                   l_msg);
            RAISE PROGRAM_ERROR;
         END IF;
      END IF;
      fnd_oam_debug.log(1, l_ctxt, 'Run Mode: '||b_run.run_mode);

      --default the valid_check_interval if not present
      IF b_run.valid_check_interval IS NULL THEN
         b_run.valid_check_interval := GET_DFLT_VALID_CHECK_INTERVAL;
         FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id          => b_run.object_id,
                                                   p_property_name      => FND_OAM_DSCFG_API_PKG.G_PROP_VALID_CHECK_INTERVAL,
                                                   p_number_value       => b_run.valid_check_interval,
                                                   x_property_id        => l_property_id);
      ELSE
         IF b_run.valid_check_interval < 0 THEN
            l_msg := 'Invalid valid_check_interval specified: "'||b_run.valid_check_interval||'".';
            fnd_oam_debug.log(3, l_ctxt, l_msg);
            MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                   l_msg);
            RAISE PROGRAM_ERROR;
         END IF;
      END IF;
      fnd_oam_debug.log(1, l_ctxt, 'Valid Check Interval: '||b_run.valid_check_interval);

      --default the # of bundles using what we've read into b_bundles or the default
      IF b_run.num_bundles IS NULL THEN
         IF b_bundles.COUNT > 0 THEN
            b_run.num_bundles := b_bundles.COUNT;
            --defer the check if this is greater than the # of hosts in the instance until GENERATE_BUNDLES
         ELSE
            b_run.num_bundles := B_DEFAULT_NUM_BUNDLES;
         END IF;
         FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id          => b_run.object_id,
                                                   p_property_name      => FND_OAM_DSCFG_API_PKG.G_PROP_NUM_BUNDLES,
                                                   p_number_value       => b_run.num_bundles,
                                                   x_property_id        => l_property_id);
      ELSE
         IF b_run.num_bundles < 1 THEN
            l_msg := 'Invalid num_bundles specified: "'||b_run.num_bundles||'".';
            fnd_oam_debug.log(3, l_ctxt, l_msg);
            MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                   l_msg);
            RAISE PROGRAM_ERROR;
         END IF;
      END IF;
      fnd_oam_debug.log(1, l_ctxt, 'Number of Bundles: '||b_run.num_bundles);

      --make sure the num_bundles is >= the # of bundle objects we read in
      IF b_bundles.COUNT > b_run.num_bundles THEN
         l_msg := 'Number of specified run bundles, '||b_run.num_bundles||', less than the number of bundles seen in configuration, '||b_bundles.COUNT;
         fnd_oam_debug.log(3, l_ctxt, l_msg);
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_msg);
         RAISE PROGRAM_ERROR;
      END IF;

      --now we need to prep the actual engine entity
      IF b_run.run_id IS NULL THEN
         --get a run_id
         SELECT FND_OAM_DSCRAM_RUNS_S.NEXTVAL
            INTO b_run.run_id
            FROM dual;
      ELSE
         fnd_oam_debug.log(1, l_ctxt, 'Deleting Existing, Stale run_id: '||b_run.run_id);
         --TODO: make this smarter
         IF NOT FND_OAM_DSCRAM_UTILS_PKG.DELETE_RUN(b_run.run_id) THEN
            l_msg := 'Failed to delete previously compiled run: '||b_run.run_id;
            fnd_oam_debug.log(3, l_ctxt, l_msg);
         END IF;
      END IF;

      --query the current db as the target_dbname
      SELECT UPPER(name)
         INTO l_dbname
         FROM v$database
         WHERE rownum < 2;

      --at this point insert a new run, we'll update the weight later
      INSERT INTO FND_OAM_DSCRAM_RUNS_B (RUN_ID,
                                         RUN_STATUS,
                                         RUN_MODE,
                                         TARGET_DBNAME,
                                         CONFIG_INSTANCE_ID,
                                         VALID_CHECK_INTERVAL,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN
                                         )
         VALUES
            (b_run.run_id,
             FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
             b_run.run_mode,
             l_dbname,
             p_config_instance_id,
             b_run.valid_check_interval,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING run_id INTO b_run.run_id;
      fnd_oam_debug.log(1, l_ctxt, 'Created new run_id: '||b_run.run_id);

      --store the run_id
      FND_OAM_DSCFG_API_PKG.SET_OR_ADD_OBJECT_PROPERTY(p_object_id      => b_run.object_id,
                                                       p_property_name  => FND_OAM_DSCFG_API_PKG.G_PROP_RUN_ID,
                                                       p_number_value   => b_run.run_id,
                                                       x_property_id    => l_property_id);

      fnd_oam_debug.log(1, l_ctxt, 'Querying config_instance attributes');
      -- get the name/description from the config instance
      SELECT name, description, language
         INTO l_display_name, l_description, l_language
         FROM fnd_oam_dscfg_instances
         WHERE config_instance_id = p_config_instance_id;

      fnd_oam_debug.log(1, l_ctxt, 'Inserting runs_tl row');
      INSERT INTO FND_OAM_DSCRAM_RUNS_TL (RUN_ID,
                                          DISPLAY_NAME,
                                          DESCRIPTION,
                                          LANGUAGE,
                                          SOURCE_LANG,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN
                                          )
         VALUES
            (b_run.run_id,
             l_display_name||'('||b_run.run_id||')',
             l_description,
             l_language,
             l_language,
             --FND_GLOBAL.CURRENT_LANGUAGE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID);

      COMMIT;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         --try to mark the run object
         IF b_run.object_id IS NOT NULL THEN
            MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                   l_ctxt,
                                   SQLCODE,
                                   SQLERRM);
         END IF;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to COMPILE_CONFIG_INSTANCE to dump out bundle entities
   PROCEDURE GENERATE_ENGINE_BUNDLES
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'GENERATE_ENGINE_BUNDLES';


      l_host_names              DBMS_SQL.VARCHAR2_TABLE;
      l_host_name               VARCHAR2(256);
      l_bundle_object_id        NUMBER;
      l_property_id             NUMBER;

      k                         NUMBER;
      j                         NUMBER;
      l_msg                     VARCHAR2(4000);
      l_found                   BOOLEAN;
      l_bundles_to_create       NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get the list of hosts for this DB
      SELECT UPPER(host_name)
         BULK COLLECT INTO l_host_names
         FROM gv$instance;

      --make sure we don't have more bundles than hosts
      IF b_run.num_bundles > l_host_names.COUNT THEN
         l_msg := 'More bundles defined in run configuration, '||b_run.num_bundles||', than defined for database: '||l_host_names.COUNT;
         fnd_oam_debug.log(3, l_ctxt, l_msg);
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_msg);
         RAISE PROGRAM_ERROR;
      END IF;

      --make sure each bundle with a hostname has a valid, different hostname.  Also check and default the
      --workers_allowed, batch_size and min_parallel_weight attributes
      k := b_bundles.FIRST;
      WHILE k IS NOT NULL LOOP
         l_host_name := b_bundles(k).target_hostname;
         fnd_oam_debug.log(1, l_ctxt, 'Validating Bundle with object_id: '||k);

         --if a host is specified, do validation/bookkeeping
         IF l_host_name IS NOT NULL THEN
            fnd_oam_debug.log('Validating specified host_name: '||l_host_name);
            --see if the host name is already used
            IF b_host_name_map.EXISTS(l_host_name) THEN
               l_msg := 'Target Hostname "'||l_host_name||'" already used by object id: '||b_host_name_map(l_host_name);
               fnd_oam_debug.log(3, l_ctxt, l_msg);
               MARK_OBJECT_AS_ERRORED(k,
                                      l_msg);
               RAISE PROGRAM_ERROR;
            ELSE
               --hostname not seen yet, remove it from l_host_names
               l_found := FALSE;
               j := l_host_names.FIRST;
               WHILE j IS NOT NULL LOOP
                  IF l_host_names(j) = l_host_name THEN
                     l_host_names.DELETE(j);
                     l_found := TRUE;
                     EXIT;
                  END IF;
                  j := l_host_names.NEXT(j);
               END LOOP;

               --if we didn't find it, it's invalid
               IF NOT l_found THEN
                  l_msg := 'Target Hostname "'||l_host_name||'" is not a hostname attached to this instance, check gv$instance.host_name.';
                  fnd_oam_debug.log(3, l_ctxt, l_msg);
                  MARK_OBJECT_AS_ERRORED(k,
                                         l_msg);
                  RAISE PROGRAM_ERROR;
               END IF;

               --add it to the used host names map
               b_host_name_map(l_host_name) := k;
            END IF;
         END IF;

         --validate the workers_allowed
         IF b_bundles(k).workers_allowed IS NULL THEN
            b_bundles(k).workers_allowed := GET_DEFAULT_NUM_WORKERS;
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id       => k,
                                                      p_property_name   => FND_OAM_DSCFG_API_PKG.G_PROP_WORKERS_ALLOWED,
                                                      p_number_value    => b_bundles(k).workers_allowed,
                                                      x_property_id     => l_property_id);
         ELSE
            IF b_bundles(k).workers_allowed < 1 THEN
               l_msg := 'Invalid workers_allowed specified: "'||b_bundles(k).workers_allowed||'".';
               fnd_oam_debug.log(3, l_ctxt, l_msg);
               MARK_OBJECT_AS_ERRORED(k,
                                      l_msg);
               RAISE PROGRAM_ERROR;
            END IF;
         END IF;
         fnd_oam_debug.log(1, l_ctxt, 'Workers Allowed: '||b_bundles(k).workers_allowed);

         --validate the batch_size
         IF b_bundles(k).batch_size IS NULL THEN
            b_bundles(k).batch_size := GET_DEFAULT_BATCH_SIZE;
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id       => k,
                                                      p_property_name   => FND_OAM_DSCFG_API_PKG.G_PROP_BATCH_SIZE,
                                                      p_number_value    => b_bundles(k).batch_size,
                                                      x_property_id     => l_property_id);
         ELSE
            IF b_bundles(k).batch_size < 1 THEN
               l_msg := 'Invalid batch_size specified: "'||b_bundles(k).batch_size||'".';
               fnd_oam_debug.log(3, l_ctxt, l_msg);
               MARK_OBJECT_AS_ERRORED(k,
                                      l_msg);
               RAISE PROGRAM_ERROR;
            END IF;
         END IF;
         fnd_oam_debug.log(1, l_ctxt, 'Batch Size: '||b_bundles(k).batch_size);

         --validate the min_parallel_unit_weight
         IF b_bundles(k).min_parallel_unit_weight IS NULL THEN
            b_bundles(k).min_parallel_unit_weight := GET_DFLT_MIN_PARALLEL_WEIGHT;
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id       => k,
                                                      p_property_name   => FND_OAM_DSCFG_API_PKG.G_PROP_MIN_PARALLEL_WEIGHT,
                                                      p_number_value    => b_bundles(k).min_parallel_unit_weight,
                                                      x_property_id     => l_property_id);
         ELSE
            IF b_bundles(k).min_parallel_unit_weight < 1 THEN
               l_msg := 'Invalid min_parallel_unit_weight specified: "'||b_bundles(k).min_parallel_unit_weight||'".';
               fnd_oam_debug.log(3, l_ctxt, l_msg);
               MARK_OBJECT_AS_ERRORED(k,
                                      l_msg);
               RAISE PROGRAM_ERROR;
            END IF;
         END IF;
         fnd_oam_debug.log(1, l_ctxt, 'Minimum unit weight to parallelize: '||b_bundles(k).min_parallel_unit_weight);

         k := b_bundles.NEXT(k);
      END LOOP;

      --if there's more than one bundle, loop through the bundles and give each one without a hostname one from l_host_names
      IF b_bundles.COUNT > 1 THEN
         k := b_bundles.FIRST;
         WHILE k IS NOT NULL LOOP
            l_host_name := b_bundles(k).target_hostname;

            IF l_host_name IS NULL THEN
               --just get the next one off of l_host_names
               b_bundles(k).target_hostname := l_host_names(l_host_names.FIRST);
               fnd_oam_debug.log(1, l_ctxt, 'Assigned host_name "'||l_host_name||'" to bundle_object_id: '||k);
               l_host_names.DELETE(l_host_names.FIRST);
               b_host_name_map(b_bundles(k).target_hostname) := k;

               FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id            => k,
                                                         p_property_name        => FND_OAM_DSCFG_API_PKG.G_PROP_TARGET_HOSTNAME,
                                                         p_varchar2_value       => b_bundles(k).target_hostname,
                                                         x_property_id          => l_property_id);
            END IF;

            k := b_bundles.NEXT(k);
         END LOOP;
      END IF;

      --make sure we've got as many b_bundles entries as expected by b_run.num_bundles.
      --As an invariant, we can't have more but if we have less we need to create some default bundles.
      IF b_bundles.COUNT < b_run.num_bundles THEN
         l_bundles_to_create := b_run.num_bundles - b_bundles.COUNT;
         fnd_oam_debug.log(1, l_ctxt, 'Creating '||l_bundles_to_create||' bundle objects...');
         FOR k in 1..l_bundles_to_create LOOP
            --create a bundle object
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT(p_object_type      => FND_OAM_DSCFG_API_PKG.G_OTYPE_BUNDLE,
                                             x_object_id        => l_bundle_object_id);
            fnd_oam_debug.log(1, l_ctxt, 'Bundle object_id: '||l_bundle_object_id);
            b_objects(l_bundle_object_id) := CREATE_OBJECT_DEF(l_bundle_object_id,
                                                               FND_OAM_DSCFG_API_PKG.G_OTYPE_BUNDLE);

            --use the next available host name
            b_bundles(l_bundle_object_id) := CREATE_BUNDLE_DEF(l_host_names(l_host_names.FIRST));
            l_host_names.DELETE(l_host_names.FIRST);
            b_host_name_map(b_bundles(l_bundle_object_id).target_hostname) := l_bundle_object_id;

            --add properties for mandatory attributes
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id       => l_bundle_object_id,
                                                      p_property_name   => FND_OAM_DSCFG_API_PKG.G_PROP_TARGET_HOSTNAME,
                                                      p_varchar2_value  => b_bundles(l_bundle_object_id).target_hostname,
                                                      x_property_id     => l_property_id);
            fnd_oam_debug.log(1, l_ctxt, 'Target Hostname: '||b_bundles(l_bundle_object_id).target_hostname);
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id       => l_bundle_object_id,
                                                      p_property_name   => FND_OAM_DSCFG_API_PKG.G_PROP_WORKERS_ALLOWED,
                                                      p_number_value    => b_bundles(l_bundle_object_id).workers_allowed,
                                                      x_property_id     => l_property_id);
            fnd_oam_debug.log(1, l_ctxt, 'Workers Allowed: '||b_bundles(l_bundle_object_id).workers_allowed);
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id       => l_bundle_object_id,
                                                      p_property_name   => FND_OAM_DSCFG_API_PKG.G_PROP_BATCH_SIZE,
                                                      p_number_value    => b_bundles(l_bundle_object_id).batch_size,
                                                      x_property_id     => l_property_id);
            fnd_oam_debug.log(1, l_ctxt, 'Batch Size: '||b_bundles(l_bundle_object_id).batch_size);
            FND_OAM_DSCFG_API_PKG.ADD_OBJECT_PROPERTY(p_object_id       => l_bundle_object_id,
                                                      p_property_name   => FND_OAM_DSCFG_API_PKG.G_PROP_MIN_PARALLEL_WEIGHT,
                                                      p_number_value    => b_bundles(l_bundle_object_id).min_parallel_unit_weight,
                                                      x_property_id     => l_property_id);
            fnd_oam_debug.log(1, l_ctxt, 'Min Parallel Unit Weight: '||b_bundles(l_bundle_object_id).min_parallel_unit_weight);
         END LOOP;
      END IF;

      --At this point, we should have b_run.num_bundles entries in b_bundles and each should be valid, create entries for each.
      --TODO: when we make the run smarter so existing runs are partially re-compiled, this section will need to be
      --addressed to use the bundle_id.  For now, just overwrite it.
      k := b_bundles.FIRST;
      WHILE k IS NOT NULL LOOP
         --do the insert, update weight later
         INSERT INTO FND_OAM_DSCRAM_BUNDLES (BUNDLE_ID,
                                             RUN_ID,
                                             BUNDLE_STATUS,
                                             TARGET_HOSTNAME,
                                             WORKERS_ALLOWED,
                                             WORKERS_ASSIGNED,
                                             BATCH_SIZE,
                                             MIN_PARALLEL_UNIT_WEIGHT,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATE_LOGIN
                                             )
            VALUES
               (FND_OAM_DSCRAM_BUNDLES_S.NEXTVAL,
                b_run.run_id,
                FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
                b_bundles(k).target_hostname,
                b_bundles(k).workers_allowed,
                0,
                b_bundles(k).batch_size,
                b_bundles(k).min_parallel_unit_weight,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID)
         RETURNING bundle_id INTO b_bundles(k).bundle_id;
         fnd_oam_debug.log(1, l_ctxt, 'Bundle Object ID ('||k||') created bundle_id ('||b_bundles(k).bundle_id||')');

         --add the property for bundle id
         FND_OAM_DSCFG_API_PKG.SET_OR_ADD_OBJECT_PROPERTY(p_object_id           => k,
                                                          p_property_name       => FND_OAM_DSCFG_API_PKG.G_PROP_BUNDLE_ID,
                                                          p_number_value        => b_bundles(k).bundle_id,
                                                          x_property_id         => l_property_id);

         k := b_bundles.NEXT(k);
      END LOOP;

      COMMIT;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         --mark the run object
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_ctxt,
                                SQLCODE,
                                SQLERRM);
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, gets the table_objects_def entity from the px_table_bound_map or creates one if necessary.
   FUNCTION GET_TABLE_OBJECTS_DEF(px_table_bound_map    IN OUT NOCOPY b_table_bound_map_type,
                                  p_table_owner         IN VARCHAR2,
                                  p_table_name          IN VARCHAR2)
      RETURN b_table_objects_def_type
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_TABLE_OBJECTS_DEF';

      l_table_name_map          b_table_name_map_type;
      l_table_objects_def       b_table_objects_def_type; --allocate a new one using it's create each time
   BEGIN
      --see if the table_bound_map has this table_owner
      IF px_table_bound_map.EXISTS(p_table_owner) THEN
         IF px_table_bound_map(p_table_owner).EXISTS(p_table_name) THEN
            RETURN px_table_bound_map(p_table_owner)(p_table_name);
         ELSE
            --has owner, but no table_name entry
            l_table_objects_def := CREATE_TABLE_OBJECTS_DEF;
            px_table_bound_map(p_table_owner)(p_table_name) := l_table_objects_def;
            RETURN l_table_objects_def;
         END IF;
      ELSE
         --owner isn't present so add the table name to the name_map with a new table_objects_def
         l_table_objects_def := CREATE_TABLE_OBJECTS_DEF;
         l_table_name_map(p_table_name) := l_table_objects_def;
         px_table_bound_map(p_table_owner) := l_table_name_map;
         RETURN l_table_objects_def;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RAISE;
   END;

   -- Private, helper to ADD_ENGINE_UNITS to do the physical insert
   PROCEDURE ADD_ENGINE_UNIT(p_task_id                          IN NUMBER,
                             p_unit_type                        IN VARCHAR2,
                             p_concurrent_group_unit_id         IN NUMBER DEFAULT NULL,
                             p_phase                            IN NUMBER DEFAULT NULL,
                             p_priority                         IN NUMBER DEFAULT NULL,
                             p_weight                           IN NUMBER DEFAULT NULL,
                             p_workers_allowed                  IN NUMBER DEFAULT NULL,
                             p_unit_object_owner                IN VARCHAR2 DEFAULT NULL,
                             p_unit_object_name                 IN VARCHAR2 DEFAULT NULL,
                             p_batch_size                       IN VARCHAR2 DEFAULT NULL,
                             p_error_fatality_level             IN VARCHAR2 DEFAULT NULL,
                             p_disable_splitting                IN VARCHAR2 DEFAULT NULL,
                             px_unit_id                         IN OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_UNIT';

      l_unit_id         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      IF px_unit_id IS NULL THEN
         SELECT FND_OAM_DSCRAM_UNITS_S.NEXTVAL
            INTO px_unit_id
            FROM dual;
      END IF;

      INSERT INTO FND_OAM_DSCRAM_UNITS (UNIT_ID,
                                        TASK_ID,
                                        CONCURRENT_GROUP_UNIT_ID,
                                        UNIT_TYPE,
                                        UNIT_STATUS,
                                        PHASE,
                                        PRIORITY,
                                        WEIGHT,
                                        SUGGEST_WORKERS_ALLOWED,
                                        WORKERS_ASSIGNED,
                                        UNIT_OBJECT_OWNER,
                                        UNIT_OBJECT_NAME,
                                        BATCH_SIZE,
                                        ERROR_FATALITY_LEVEL,
                                        SUGGEST_DISABLE_SPLITTING,
                                        CREATED_BY,
                                        CREATION_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATE_LOGIN
                                        )
         VALUES
            (px_unit_id,
             p_task_id,
             p_concurrent_group_unit_id,
             p_unit_type,
             FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
             p_phase,
             p_priority,
             p_weight,
             p_workers_allowed,
             0,
             p_unit_object_owner,
             p_unit_object_name,
             p_batch_size,
             p_error_fatality_level,
             p_disable_splitting,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING UNIT_ID INTO l_unit_id;

      px_unit_id := l_unit_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   --Simple helper to get the next unit id from its sequence.
   FUNCTION GET_NEXT_UNIT_ID
      RETURN NUMBER
   IS
      l_retval          NUMBER;
   BEGIN
      SELECT FND_OAM_DSCRAM_UNITS_S.NEXTVAL
         INTO l_retval
         FROM DUAL;
      RETURN l_retval;
   END;

   -- Helper to ADD_ENGINE_UNITS to update the logical and physical weight counters.
   PROCEDURE INTEGRATE_WEIGHTS(px_parent_logical_weight         IN OUT NOCOPY NUMBER,
                               px_parent_physical_weight        IN OUT NOCOPY NUMBER,
                               p_child_logical_weight           IN NUMBER,
                               p_child_physical_weight          IN NUMBER)
   IS
   BEGIN
      IF px_parent_logical_weight IS NOT NULL THEN
         IF p_child_logical_weight IS NULL THEN
            px_parent_logical_weight := NULL;
         ELSE
            px_parent_logical_weight := px_parent_logical_weight + p_child_logical_weight;
         END IF;
      END IF;
      px_parent_physical_weight := px_parent_physical_weight + NVL(p_child_physical_weight, 0);
   END;

   -- create a dml entry for a given unit
   PROCEDURE ADD_ENGINE_DML(p_unit_id           IN NUMBER,
                            p_stmt              IN VARCHAR2,
                            p_where_clause      IN VARCHAR2 DEFAULT NULL,
                            p_priority          IN NUMBER DEFAULT NULL,
                            p_weight            IN NUMBER DEFAULT NULL,
                            x_dml_id            OUT NOCOPY NUMBER)
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'ADD_ENGINE_DML';
      l_dml_id  NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      INSERT INTO FND_OAM_DSCRAM_DMLS (DML_ID,
                                       UNIT_ID,
                                       PRIORITY,
                                       WEIGHT,
                                       DML_STMT,
                                       DML_WHERE_CLAUSE,
                                       CREATED_BY,
                                       CREATION_DATE,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATE_LOGIN
                                       )
         VALUES
            (FND_OAM_DSCRAM_DMLS_S.NEXTVAL,
             p_unit_id,
             p_priority,
             p_weight,
             p_stmt,
             p_where_clause,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING DML_ID INTO l_dml_id;

      x_dml_id := l_dml_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Helper to construct a DML DELETE statement and add it to a unit.
   FUNCTION ADD_ENGINE_DELETE_DML(p_unit_id             IN NUMBER,
                                  p_object_id           IN NUMBER,
                                  x_weight              OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'ADD_ENGINE_DELETE_DML';

      l_delete_def      b_dml_delete_stmt_def_type;
      l_stmt            VARCHAR2(4000);
      l_weight          NUMBER;
      l_dml_id          NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get a reference
      l_delete_def := b_dml_delete_stmts(p_object_id);

      --construct the delete stmt
      l_stmt := 'DELETE FROM '||l_delete_def.table_owner||'.'||l_delete_def.table_name;

      --compute the weight
      l_weight := CEIL(NVL(l_delete_def.weight, B_DELETE_WEIGHT_MODIFIER *
                                                FND_OAM_DSCFG_UTILS_PKG.GET_TABLE_WEIGHT(l_delete_def.table_owner,
                                                                                         l_delete_def.table_name)));
      --add the dml
      ADD_ENGINE_DML(p_unit_id,
                     l_stmt,
                     l_delete_def.where_clause,
                     p_priority => B_BASE_PRIORITY_DELETES,
                     p_weight   => l_weight,
                     x_dml_id   => l_dml_id);

      --success
      x_weight := l_weight;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         MARK_OBJECT_AS_ERRORED(p_object_id,
                                l_ctxt,
                                SQLCODE,
                                SQLERRM);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Helper to construct a DML DELETE statement and add it to a unit.
   FUNCTION ADD_ENGINE_UPDATE_DMLS(p_unit_id            IN NUMBER,
                                   p_table_owner        IN VARCHAR2,
                                   p_table_name         IN VARCHAR2,
                                   p_where_clause       IN VARCHAR2,
                                   px_column_map        IN OUT NOCOPY b_column_name_map_type,
                                   x_logical_weight     OUT NOCOPY NUMBER,
                                   x_physical_weight    OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'ADD_ENGINE_UPDATE_DMLS';

      l_dml_id          NUMBER;

      l_logical_weight          NUMBER := 0;
      l_physical_weight         NUMBER := 0;
      l_initial_set_clause      VARCHAR2(10) := ' SET ';
      l_set_snippet             VARCHAR2(4000);
      l_set_clause              VARCHAR2(4000);
      l_prefix                  VARCHAR2(100);
      l_prefix_len              NUMBER;
      l_suffix                  VARCHAR2(4000);
      l_suffix_len              NUMBER;
      l_column                  VARCHAR2(30);
      l_column_count            NUMBER;
      l_table_weight            NUMBER;

      l_weight          NUMBER;
      k                 NUMBER;
      l_msg             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --prep the dml prefix and suffix
      l_prefix := 'UPDATE '||p_table_owner||'.'||p_table_name;
      IF p_where_clause IS NOT NULL THEN
         l_suffix := ' WHERE ';
         IF length(l_suffix) + length(p_where_clause) > B_STMT_MAXLEN THEN
            l_msg := 'Table '||p_table_owner||'.'||p_table_name||' has a where clause that is too long.';
            fnd_oam_debug.log(3, l_ctxt, l_msg);
            MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                   l_msg);
            RAISE PROGRAM_ERROR;
         ELSE
            l_suffix := l_suffix||p_where_clause;
         END IF;
      ELSE
         l_suffix := '';
      END IF;
      l_prefix_len := length(l_prefix);
      l_suffix_len := NVL(length(l_suffix), 0);

      --get the table weight
      l_table_weight := FND_OAM_DSCFG_UTILS_PKG.GET_TABLE_WEIGHT(p_table_owner,
                                                                 p_table_name);

      -- initialize pieces we use to identify the currently accumulating sql statement
      l_set_clause := l_initial_set_clause;
      l_column_count := 0;
      l_weight := l_table_weight;

      --loop over the list of columns
      l_column := px_column_map.FIRST;
      WHILE l_column IS NOT NULL LOOP
         --compose the column=value snippet
         l_set_snippet := l_column||'='||b_dml_update_segments(px_column_map(l_column)).new_column_value;
         IF l_column_count <> 0 THEN
            l_set_snippet := ', '||l_set_snippet;
         END IF;
         --see if we have room
         IF l_prefix_len + length(l_set_clause) + length(l_set_snippet) + l_suffix_len <= B_STMT_MAXLEN THEN
            --has room, add the snippet, adjust the weight and increment our counters
            l_set_clause := l_set_clause||l_set_snippet;
            IF b_dml_update_segments(px_column_map(l_column)).weight_modifier IS NOT NULL THEN
               l_weight := l_weight * b_dml_update_segments(px_column_map(l_column)).weight_modifier;
            END IF;
            l_column_count := l_column_count + 1;
            l_column := px_column_map.NEXT(l_column);
         ELSE
            --no room left
            IF l_column_count = 0 THEN
               --no room for the first element, this is bad
               l_msg := 'This set clause alone is too large('||to_char(l_prefix_len + length(l_set_clause) + length(l_set_snippet) + l_suffix_len)||') for a single statement with the where clause provided.';
               fnd_oam_debug.log(3, l_ctxt, l_msg);
               MARK_OBJECT_AS_ERRORED(px_column_map(l_column),
                                      l_msg);
               RAISE PROGRAM_ERROR;
            END IF;

            --make a dml for the currently accumulated statement, the suffix is only used to do length limitations, it is
            --discarded at this point and the formal where clause is passed as the other param.
            ADD_ENGINE_DML(p_unit_id,
                           l_prefix||l_set_clause,
                           p_where_clause       => p_where_clause,
                           p_priority           => B_BASE_PRIORITY_UPDATES,
                           p_weight             => l_weight,
                           x_dml_id             => l_dml_id);
            INTEGRATE_WEIGHTS(l_logical_weight,
                              l_physical_weight,
                              l_weight,
                              l_weight);

            --re-initialize the statement variables, don't increment the column so we see it on the next loop
            l_set_clause := l_initial_set_clause;
            l_column_count := 0;
            l_weight := l_table_weight;
         END IF;
      END LOOP;

      --get any remaining statement if we exited the loop with in-progress columns
      IF l_column_count > 0 THEN
            ADD_ENGINE_DML(p_unit_id,
                           l_prefix||l_set_clause,
                           p_where_clause       => p_where_clause,
                           p_priority           => B_BASE_PRIORITY_UPDATES,
                           p_weight             => l_weight,
                           x_dml_id             => l_dml_id);
         INTEGRATE_WEIGHTS(l_logical_weight,
                           l_physical_weight,
                           l_weight,
                           l_weight);
      END IF;

      --success
      x_logical_weight := l_logical_weight;
      x_physical_weight := l_physical_weight;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_ctxt,
                                SQLCODE,
                                SQLERRM);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- create a plsql entry for a given unit
   PROCEDURE ADD_ENGINE_PLSQL(p_unit_id                IN NUMBER,
                              p_plsql_text             IN VARCHAR2,
                              p_priority               IN NUMBER DEFAULT NULL,
                              p_weight                 IN NUMBER DEFAULT NULL,
                              x_plsql_id               OUT NOCOPY NUMBER)
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'ADD_ENGINE_PLSQL';

      l_plsql_id  NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      INSERT INTO FND_OAM_DSCRAM_PLSQLS (PLSQL_ID,
                                         UNIT_ID,
                                         PRIORITY,
                                         WEIGHT,
                                         PLSQL_TEXT,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN
                                       )
         VALUES
            (FND_OAM_DSCRAM_PLSQLS_S.NEXTVAL,
             p_unit_id,
             p_priority,
             p_weight,
             p_plsql_text,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING PLSQL_ID INTO l_plsql_id;

      x_plsql_id := l_plsql_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Helper function to ADD_ENGINE_UNITS_FOR_DOMAIN to handle the table_bound objects of a specific domain.
   -- This is part of the parent's autonomous transaction and is split out primarily because it's too much
   -- code to include in an already large parent function.  Each table owner/table_name spawns its own unit
   -- or set of units in the case of a concurrent_meta_unit.
   FUNCTION ADD_ENGINE_TABLE_BOUND_UNITS(p_task_id                      IN NUMBER,
                                         px_table_bound_map             IN OUT NOCOPY b_table_bound_map_type,
                                         px_bound_operations_phase      IN OUT NOCOPY NUMBER,
                                         x_logical_weight               OUT NOCOPY NUMBER,
                                         x_physical_weight              OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_ENGINE_TABLE_BOUND_UNITS';

      l_total_logical_weight    NUMBER := 0;
      l_total_physical_weight   NUMBER := 0;
      l_unit_logical_weight     NUMBER;
      l_unit_physical_weight    NUMBER;
      l_logical_weight          NUMBER;
      l_physical_weight         NUMBER;

      l_table_objects_def       b_table_objects_def_type; --allocate a new one using it's create each time
      l_unit_id                 NUMBER;
      l_dml_unit_id             NUMBER;
      l_plsql_unit_id           NUMBER;
      l_table_name              VARCHAR2(30);
      l_table_owner             VARCHAR2(30);
      l_has_dmls                BOOLEAN;
      l_has_plsqls              BOOLEAN;
      l_plsql_id                NUMBER;
      l_where_clause            VARCHAR2(4000);
      l_weight                  NUMBER;
      k                         NUMBER;
      j                         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- Go through each owner/name
      -- combo and create units.  For now, each owner/name combo will produce one unit in a different phase.  Other tables
      -- in the same domain usually means overlap so they'd need a different phase anyhow.  Lumping all the operations
      -- on one table into a single unit is ok because if they want seperation, they should specify a different primary_domain.
      -- Finally, use and increment the passed in phases for each instead of using NULLs to keep NULL open for any ops the user
      -- wants to have run at the very end.
      l_table_owner := px_table_bound_map.FIRST;
      WHILE l_table_owner IS NOT NULL LOOP
         fnd_oam_debug.log(1, l_ctxt, 'Processing Table Owner: '||l_table_owner);
         --loop over the table names for this owner
         l_table_name := px_table_bound_map(l_table_owner).FIRST;
         WHILE l_table_name IS NOT NULL LOOP
            fnd_oam_debug.log(1, l_ctxt, 'Processing Table Name: '||l_table_name);
            --get a reference to the table_objects_def
            l_table_objects_def := px_table_bound_map(l_table_owner)(l_table_name);

            --see if we've got dmls and plsqls, this requires a concurrent unit
            l_has_dmls := (l_table_objects_def.update_map.COUNT > 0) OR (l_table_objects_def.delete_map.COUNT > 0);
            l_has_plsqls := (l_table_objects_def.plsqls.COUNT > 0);
            l_unit_logical_weight := 0;
            l_unit_physical_weight := 0;

            IF l_has_dmls AND l_has_plsqls THEN
               --get an id for the concurrent meta-unit, otherwise tag it with a NULL
               l_unit_id := GET_NEXT_UNIT_ID;
            ELSE
               l_unit_id := NULL;
            END IF;
            IF l_has_dmls THEN
               l_dml_unit_id := GET_NEXT_UNIT_ID;
            END IF;
            IF l_has_plsqls THEN
               l_plsql_unit_id := GET_NEXT_UNIT_ID;
            END IF;

            --create DMLs for each update where clause, can't loop on WHILE because we allow NULL keys
            j := l_table_objects_def.update_map.COUNT;
            l_where_clause := l_table_objects_def.update_map.FIRST;
            FOR k IN 1..j LOOP
               IF ADD_ENGINE_UPDATE_DMLS(l_dml_unit_id,
                                         l_table_owner,
                                         l_table_name,
                                         l_where_clause,
                                         l_table_objects_def.update_map(l_where_clause),
                                         l_logical_weight,
                                         l_physical_weight) THEN
                  INTEGRATE_WEIGHTS(l_unit_logical_weight,
                                    l_unit_physical_weight,
                                    l_logical_weight,
                                    l_physical_weight);
               END IF;
               l_where_clause := l_table_objects_def.update_map.NEXT(l_where_clause);
            END LOOP;

            --create DMLs for each delete where clause, can't loop on WHILE because we allow NULL keys
            j := l_table_objects_def.delete_map.COUNT;
            l_where_clause := l_table_objects_def.delete_map.FIRST;
            FOR k IN 1..j LOOP
               IF ADD_ENGINE_DELETE_DML(l_dml_unit_id,
                                        l_table_objects_def.delete_map(l_where_clause),
                                        l_weight) THEN
                  INTEGRATE_WEIGHTS(l_unit_logical_weight,
                                    l_unit_physical_weight,
                                    l_weight,
                                    l_weight);
               END IF;
               l_where_clause := l_table_objects_def.delete_map.NEXT(l_where_clause);
            END LOOP;

            --create plsqls for each table bound plsql
            j := l_table_objects_def.plsqls.FIRST;
            WHILE j IS NOT NULL LOOP
               k := l_table_objects_def.plsqls(j);
               --no need for a checked return value, throws an exception if it fails
               ADD_ENGINE_PLSQL(l_plsql_unit_id,
                                b_plsql_texts(k).plsql_text,
                                p_weight        => b_plsql_texts(k).weight,
                                x_plsql_id      => l_plsql_id);

               INTEGRATE_WEIGHTS(l_unit_logical_weight,
                                 l_unit_physical_weight,
                                 b_plsql_texts(k).weight,
                                 b_plsql_texts(k).weight);
               j := l_table_objects_def.plsqls.NEXT(j);
            END LOOP;

            --create the necessary units
            IF l_unit_id IS NOT NULL THEN
               --concurrent_units case
               ADD_ENGINE_UNIT(p_task_id,
                               FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_CONC_GROUP,
                               p_phase                  => px_bound_operations_phase,
                               p_weight                 => l_unit_logical_weight,
                               p_unit_object_owner      => l_table_owner,
                               p_unit_object_name       => l_table_name,
                               px_unit_id               => l_unit_id);
               -- create child units, weight and phase are meaningless here
               IF l_dml_unit_id IS NOT NULL THEN
                  ADD_ENGINE_UNIT(p_task_id,
                                  FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_DML_SET,
                                  p_concurrent_group_unit_id    => l_unit_id,
                                  px_unit_id                    => l_dml_unit_id);
               END IF;
               IF l_plsql_unit_id IS NOT NULL THEN
                  ADD_ENGINE_UNIT(p_task_id,
                                  FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET,
                                  p_concurrent_group_unit_id    => l_unit_id,
                                  px_unit_id                    => l_plsql_unit_id);
               END IF;
            ELSE
               --create topmost unit depending on which unit_id isn't null
               IF l_dml_unit_id IS NOT NULL THEN
                  ADD_ENGINE_UNIT(p_task_id,
                                  FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_DML_SET,
                                  p_phase                       => px_bound_operations_phase,
                                  p_weight                      => l_unit_logical_weight,
                                  p_unit_object_owner           => l_table_owner,
                                  p_unit_object_name            => l_table_name,
                                  px_unit_id                    => l_dml_unit_id);
               ELSIF l_plsql_unit_id IS NOT NULL THEN
                  ADD_ENGINE_UNIT(p_task_id,
                                  FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET,
                                  p_phase                       => px_bound_operations_phase,
                                  p_weight                      => l_unit_logical_weight,
                                  p_unit_object_owner           => l_table_owner,
                                  p_unit_object_name            => l_table_name,
                                  px_unit_id                    => l_plsql_unit_id);
               END IF;
            END IF;

            --increment the phase
            px_bound_operations_phase := px_bound_operations_phase + B_PHASE_INCREMENT;

            fnd_oam_debug.log(1, l_ctxt, 'Unit logical/physical weight: ('||l_unit_logical_weight||')('||l_unit_physical_weight||')');
            --integrate the unit's logical/physical weights
            INTEGRATE_WEIGHTS(l_total_logical_weight,
                              l_total_physical_weight,
                              l_unit_logical_weight,
                              l_unit_physical_weight);

            l_table_name := px_table_bound_map(l_table_owner).NEXT(l_table_name);
         END LOOP;
         l_table_owner := px_table_bound_map.NEXT(l_table_owner);
      END LOOP;

      COMMIT;

      --success
      x_logical_weight := l_total_logical_weight;
      x_physical_weight := l_total_physical_weight;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         --mark the run becaues we have no place better.
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_ctxt,
                                SQLCODE,
                                SQLERRM);
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Private, helper to COMPILE_CONFIG_INSTANCE to dump out tasks/units for a specific primary domain.
   FUNCTION ADD_ENGINE_UNITS_FOR_DOMAIN(p_task_id                       IN NUMBER,
                                        p_primary_domain                IN VARCHAR2,
                                        px_truncate_phase               IN OUT NOCOPY NUMBER,
                                        px_unbound_plsql_phase          IN OUT NOCOPY NUMBER,
                                        px_bound_operations_phase       IN OUT NOCOPY NUMBER,
                                        x_logical_weight                OUT NOCOPY NUMBER,
                                        x_physical_weight               OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_ENGINE_UNITS_FOR_DOMAIN';

      --Types used to dup-check truncates for a domain
      --Hash Table of table_name->truncate object_id
      TYPE l_truncate_table_name_map_t IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
      --Hash Table of owner_name->table_name map
      TYPE l_truncate_table_owner_map_t IS TABLE OF l_truncate_table_name_map_t INDEX BY VARCHAR2(30);

      --temporarily collect truncates into this map
      l_truncate_table_owner_map        l_truncate_table_owner_map_t;

      --collect table_bound objects in the domain into this map to pass to ADD_ENGINE_TABLE_BOUND_UNITS
      l_table_bound_map         b_table_bound_map_type;

      --counters for the weight of this domain
      l_domain_logical_weight           NUMBER := 0;
      l_domain_physical_weight          NUMBER := 0;

      --temporary structures/variables
      l_table_objects_def               b_table_objects_def_type; --allocate a new one using it's create each time
      l_column_map                      b_column_name_map_type;
      l_segment                         b_dml_update_segment_def_type;
      l_delete_stmt                     b_dml_delete_stmt_def_type;
      l_truncate_stmt                   b_dml_truncate_stmt_def_type;
      l_plsql                           b_plsql_text_def_type;
      l_truncate_table_name_map         l_truncate_table_name_map_t;

      l_object_id               NUMBER;
      l_object_id2              NUMBER;
      l_unit_id                 NUMBER;
      l_dml_id                  NUMBER;
      l_plsql_id                NUMBER;
      l_weight                  NUMBER;
      l_table_owner             VARCHAR2(30);
      l_table_name              VARCHAR2(30);
      l_where_clause            VARCHAR2(4000);
      l_logical_weight          NUMBER;
      l_physical_weight         NUMBER;
      k                         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- loop through the domain's contents, grouping the objects
      k := b_primary_domains(p_primary_domain).FIRST;
      WHILE k IS NOT NULL LOOP
         l_object_id := b_primary_domains(p_primary_domain)(k);
         fnd_oam_debug.log(1, l_ctxt, 'Parsing object_id: '||l_object_id||'('||b_objects(l_object_id).object_type||')');
         --case the object type
         CASE b_objects(l_object_id).object_type
            WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_UPDATE_SEGMENT THEN
               l_segment := b_dml_update_segments(l_object_id);

               --get the table_objects_def reference to update
               l_table_objects_def := GET_TABLE_OBJECTS_DEF(l_table_bound_map,
                                                            l_segment.table_owner,
                                                            l_segment.table_name);

               --ADD this update segment to the table_objects_def if it doesn't conflict

               --see if the where clause exists
               l_where_clause := NVL(l_segment.where_clause, '');
               IF l_table_objects_def.update_map.EXISTS(l_where_clause) THEN
                  --see if the column name's been seen before
                  IF l_table_objects_def.update_map(l_where_clause).EXISTS(l_segment.column_name) THEN
                     --see if the values are the same, if not this is a conflict otherwise it's just a dupe
                     l_object_id2 := l_table_objects_def.update_map(l_where_clause)(l_segment.column_name);
                     IF (b_dml_update_segments(l_object_id2).new_column_value <> l_segment.new_column_value) THEN
                        MARK_OBJECT_AS_ERRORED(l_object_id,
                                               'New Column Value conflicts with Object ID: '||l_object_id2);
                     ELSE
                        MARK_OBJECT_WITH_WARNING(l_object_id,
                                                 l_ctxt,
                                                 'Duplicate of Object ID: '||l_object_id2);
                     END IF;
                  ELSE
                     --new column_name
                     l_table_objects_def.update_map(l_where_clause)(l_segment.column_name) := l_object_id;
                  END IF;
               ELSE
                  --new where clause
                  l_column_map.DELETE;
                  l_column_map(l_segment.column_name) := l_object_id;
                  l_table_objects_def.update_map(l_where_clause) := l_column_map;
               END IF;

               --set the table_objects_def back
               l_table_bound_map(l_segment.table_owner)(l_segment.table_name) := l_table_objects_def;
            WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_DELETE_STMT THEN
               l_delete_stmt := b_dml_delete_stmts(l_object_id);

               --get the table_objects_def reference to update
               l_table_objects_def := GET_TABLE_OBJECTS_DEF(l_table_bound_map,
                                                            l_delete_stmt.table_owner,
                                                            l_delete_stmt.table_name);

               --ADD this update segment to the table_objects_def if it doesn't conflict

               --see if the where clause exists
               l_where_clause := NVL(l_delete_stmt.where_clause, '');
               IF l_table_objects_def.delete_map.EXISTS(l_where_clause) THEN
                  --can't delete the same table/where clause twice, mark it as a dupe
                  MARK_OBJECT_WITH_WARNING(l_object_id,
                                           l_ctxt,
                                           'Duplicate of Object ID: '||l_table_objects_def.delete_map(l_where_clause));
               ELSE
                  --add it
                  fnd_oam_debug.log(1, l_ctxt, 'New where clause');
                  l_table_objects_def.delete_map(NVL(l_where_clause, '')) := l_object_id;
               END IF;

               --set the table_objects_def back
               l_table_bound_map(l_delete_stmt.table_owner)(l_delete_stmt.table_name) := l_table_objects_def;
            WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_DML_TRUNCATE_STMT THEN
               l_truncate_stmt := b_dml_truncate_stmts(l_object_id);

               --if the run mode isn't normal, truncates need to become deletes so they can be rolled back
               IF b_run.run_mode <> FND_OAM_DSCRAM_UTILS_PKG.G_MODE_NORMAL THEN
                  --since these deletes can take a long time, give a more accurate perf viewpoint by just skipping
                  --the truncate
                  MARK_OBJECT_WITH_WARNING(l_object_id,
                                           l_ctxt,
                                           'Skipping Truncate operation because of run mode: '||b_run.run_mode);
                  /*
                  --convert this truncate to a delete
                  --get the table_objects_def reference to update
                  l_table_objects_def := GET_TABLE_OBJECTS_DEF(l_table_bound_map,
                                                               l_truncate_stmt.table_owner,
                                                               l_truncate_stmt.table_name);

                  --ADD this delete segment to the table_objects_def if it doesn't conflict

                  --see if an entry exists for a NULL where clause
                  IF l_table_objects_def.delete_map.EXISTS(NULL) THEN
                     --can't delete the same table/where clause twice, mark it as a dupe
                     MARK_OBJECT_WITH_WARNING(l_object_id,
                                              l_ctxt,
                                              'Duplicate of Object ID: '||l_table_objects_def.delete_map(NULL));
                  ELSE
                     --add it
                     l_table_objects_def.delete_map(NULL) := l_object_id;
                  END IF;

                  --set the table_objects_def back
                  l_table_bound_map(l_truncate_stmt.table_owner)(l_truncate_stmt.table_name) := l_table_objects_def;
                  */
               ELSE
                  --instead of creating the truncate right away, look for a dup in the truncate_owner_map, store non-dups
                  --in this struct for processing outside of this domain objects loop.
                  IF l_truncate_table_owner_map.EXISTS(l_truncate_stmt.table_owner) THEN
                     IF l_truncate_table_owner_map(l_truncate_stmt.table_owner).EXISTS(l_truncate_stmt.table_name) THEN
                        --dupe
                        MARK_OBJECT_WITH_WARNING(l_object_id,
                                                 l_ctxt,
                                                 'Duplicate of Object ID: '||l_truncate_table_owner_map(l_truncate_stmt.table_owner)(l_truncate_stmt.table_name));
                     ELSE
                        --new table name
                        l_truncate_table_owner_map(l_truncate_stmt.table_owner)(l_truncate_stmt.table_name) := l_object_id;
                     END IF;
                  ELSE
                     --new owner
                     l_truncate_table_name_map.DELETE;
                     l_truncate_table_name_map(l_truncate_stmt.table_name) := l_object_id;
                     l_truncate_table_owner_map(l_truncate_stmt.table_owner) := l_truncate_table_name_map;
                  END IF;

               END IF;
            WHEN FND_OAM_DSCFG_API_PKG.G_OTYPE_PLSQL_TEXT THEN
               l_plsql := b_plsql_texts(l_object_id);

               --see if we've got a table owner and name, meaning the pl/sql is table bound
               IF l_plsql.table_owner IS NOT NULL and l_plsql.table_name IS NOT NULL THEN
                  --get the table_objects_def reference to update
                  l_table_objects_def := GET_TABLE_OBJECTS_DEF(l_table_bound_map,
                                                               l_plsql.table_owner,
                                                               l_plsql.table_name);

                  --ADD this plsql to the list of plsqls

                  l_table_objects_def.plsqls.EXTEND;
                  l_table_objects_def.plsqls(l_table_objects_def.plsqls.COUNT) := l_object_id;

                  --set the table_objects_def back
                  l_table_bound_map(l_plsql.table_owner)(l_plsql.table_name) := l_table_objects_def;
               ELSE
                  --unbound pl/sql, run in phases after truncate and also can't be split
                  BEGIN
                     l_unit_id := NULL;
                     ADD_ENGINE_UNIT(p_task_id,
                                     FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET,
                                     p_phase                    => px_unbound_plsql_phase,
                                     p_weight                   => l_plsql.weight,
                                     p_disable_splitting        => FND_API.G_TRUE,
                                     px_unit_id                 => l_unit_id);

                     --and its corresponding PL/SQL
                     ADD_ENGINE_PLSQL(l_unit_id,
                                      l_plsql.plsql_text,
                                      p_weight          => l_plsql.weight,
                                      x_plsql_id        => l_plsql_id);

                     --increment the unbound plsql phase
                     px_unbound_plsql_phase := px_unbound_plsql_phase + B_PHASE_INCREMENT;
                     INTEGRATE_WEIGHTS(l_domain_logical_weight,
                                       l_domain_physical_weight,
                                       l_plsql.weight,
                                       l_plsql.weight);
                  EXCEPTION
                     WHEN OTHERS THEN
                        --put the error in the object and move on
                        MARK_OBJECT_AS_ERRORED(l_object_id,
                                               l_ctxt,
                                               SQLCODE,
                                               SQLERRM);
                  END;
               END IF;
            ELSE
               --unmatched object type, shouldn't happen
               fnd_oam_debug.log(6, l_ctxt, 'Unknown Object Type: '||b_objects(l_object_id).object_type);
               RAISE PROGRAM_ERROR;
            END CASE;

         k := b_primary_domains(p_primary_domain).NEXT(k);
      END LOOP;

      --loop over the truncates, create solo units for each
      l_table_owner := l_truncate_table_owner_map.FIRST;
      WHILE l_table_owner IS NOT NULL LOOP
         l_table_name := l_truncate_table_owner_map(l_table_owner).FIRST;
         WHILE l_table_name IS NOT NULL LOOP
            l_object_id := l_truncate_table_owner_map(l_table_owner)(l_table_name);
            l_truncate_stmt := b_dml_truncate_stmts(l_object_id);

            --figure out the true weight to use
            l_weight := CEIL(NVL(l_truncate_stmt.weight, B_TRUNCATE_WEIGHT_MODIFIER *
                                                         FND_OAM_DSCFG_UTILS_PKG.GET_TABLE_WEIGHT(l_table_owner,
                                                                                                  l_table_name)));
            BEGIN
               l_unit_id := NULL;
               --even though truncates don't use AD splitting, store the unit object owner/name to simplify reporting
               ADD_ENGINE_UNIT(p_task_id,
                               FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_DML_SET,
                               p_phase                  => px_truncate_phase,
                               p_weight                 => l_weight,
                               p_unit_object_owner      => l_table_owner,
                               p_unit_object_name       => l_table_name,
                               p_disable_splitting      => FND_API.G_TRUE,
                               px_unit_id               => l_unit_id);

               --and its corresponding DML
               --TODO: See if the PURGE MATERIALIZED VIEW LOG option is acceptable here
               ADD_ENGINE_DML(l_unit_id,
                              'TRUNCATE TABLE '||l_table_owner||'.'||l_table_name,
                              p_weight  => l_weight,
                              x_dml_id  => l_dml_id);

               --increment the truncate phase and update the weight counters
               px_truncate_phase := px_truncate_phase + B_PHASE_INCREMENT;
               INTEGRATE_WEIGHTS(l_domain_logical_weight,
                                 l_domain_physical_weight,
                                 l_weight,
                                 l_weight);
            EXCEPTION
               WHEN OTHERS THEN
                  --put the error in the object and move on
                  MARK_OBJECT_AS_ERRORED(l_object_id,
                                         l_ctxt,
                                         SQLCODE,
                                         SQLERRM);
            END;
            l_table_name := l_truncate_table_owner_map(l_table_owner).NEXT(l_table_name);
         END LOOP;
         l_table_owner := l_truncate_table_owner_map.NEXT(l_table_owner);
      END LOOP;

      -- split out the logic to create the table bound units and integrate their collective weight into the domain's
      -- overall weight.
      IF ADD_ENGINE_TABLE_BOUND_UNITS(p_task_id,
                                      l_table_bound_map,
                                      px_bound_operations_phase,
                                      l_logical_weight,
                                      l_physical_weight) THEN
         INTEGRATE_WEIGHTS(l_domain_logical_weight,
                           l_domain_physical_weight,
                           l_logical_weight,
                           l_physical_weight);
      END IF;

      COMMIT;

      --success
      fnd_oam_debug.log(1, l_ctxt, 'Domain logical/physical weights: ('||l_domain_logical_weight||')('||l_domain_physical_weight||')');
      x_logical_weight := l_domain_logical_weight;
      x_physical_weight := l_domain_physical_weight;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         --mark the run becaues we have no place better.
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_ctxt,
                                SQLCODE,
                                SQLERRM);
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- To support multiple bundles/bundle work partitioning, use this call to encapsulate the
   -- assignment of a task to a bundle based on whatever scheme we figure is best.  Returns the object_id
   -- of the bundle_metadata object.
   -- Invariant: b_bundles_metadata has at least one entry by now
   FUNCTION GET_BUNDLE_FOR_GROUP(p_group        b_dependency_group_def_type)
      RETURN NUMBER
   IS
      l_least_weight_id         NUMBER := NULL;
      l_least_weight            NUMBER := NULL;
      l_least_count_id          NUMBER := NULL;
      l_least_count             NUMBER := NULL;

      k                         NUMBER;
   BEGIN
      --skip assignment if there's only one, the common case
      IF b_bundles.COUNT > 1 THEN
         --find the bundle with the least physical_weight
         k := b_bundles.FIRST;
         WHILE k IS NOT NULL LOOP
            IF l_least_weight IS NULL OR b_bundles(k).assigned_physical_weight < l_least_weight THEN
               l_least_weight := b_bundles(k).assigned_physical_weight;
               l_least_weight_id := k;
            END IF;
            IF l_least_count IS NULL OR b_bundles(k).assigned_task_count < l_least_count THEN
               l_least_count := b_bundles(k).assigned_task_count;
               l_least_count_id := k;
            END IF;
            k := b_bundles.NEXT(k);
         END LOOP;

         --if the least weight is > 0, use it - otherwise use the least count which we know is incrementing.
         IF l_least_weight > 0 THEN
            RETURN l_least_weight_id;
         ELSE
            RETURN l_least_count_id;
         END IF;
      ELSE
         --only one bundle, return it's id
         RETURN b_bundles.FIRST;
      END IF;
   END;

   -- Private, helper to GENERATE_ENGINE_TASKS to dump out tasks/units for a specific dependency group
   FUNCTION ADD_ENGINE_TASK_WITH_UNITS(p_group_id               IN NUMBER)
      RETURN BOOLEAN
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_ENGINE_TASK_WITH_UNITS';

      l_bundle_object_id        NUMBER;
      l_task_id                 NUMBER;
      l_truncate_phase          NUMBER := B_BASE_PHASE_TRUNCATES;
      l_unbound_plsql_phase     NUMBER := B_BASE_PHASE_UNBOUND_PLSQLS;
      l_bound_operations_phase  NUMBER := B_BASE_PHASE_BOUND_OPERATIONS;
      l_task_logical_weight     NUMBER := 0;
      l_task_physical_weight    NUMBER := 0;

      l_domain                  VARCHAR2(120);
      l_weight                  NUMBER;
      l_logical_weight          NUMBER;
      l_physical_weight         NUMBER;

      k                         NUMBER;
      j                         NUMBER;
      l_msg                     VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- fetch a task_id to use for creating units
      SELECT FND_OAM_DSCRAM_TASKS_S.NEXTVAL
         INTO l_task_id
         FROM dual;
      b_dependency_groups(p_group_id).task_id := l_task_id;
      fnd_oam_debug.log(1, l_ctxt, 'Using task_id: '||l_task_id);

      -- loop through the primary domains, creating units for each kind of object in each domain - we don't allow
      -- collecting objects across primary domains.
      k := b_dependency_groups(p_group_id).primary_domains.FIRST;
      WHILE k IS NOT NULL LOOP
         l_domain := b_dependency_groups(p_group_id).primary_domains(k);
         fnd_oam_debug.log(1, l_ctxt, 'Processing primary_domain: '||l_domain);
         --for a given domain, create the units, only do weight calculation if it came back true for sucess.
         IF ADD_ENGINE_UNITS_FOR_DOMAIN(l_task_id,
                                        l_domain,
                                        l_truncate_phase,
                                        l_unbound_plsql_phase,
                                        l_bound_operations_phase,
                                        l_logical_weight,
                                        l_physical_weight) THEN
            --only integrate the logical_weight, physical_weight if user hasn't supplied a weight
            IF b_dependency_groups(p_group_id).weight IS NULL THEN
               INTEGRATE_WEIGHTS(l_task_logical_weight,
                                 l_task_physical_weight,
                                 l_logical_weight,
                                 l_physical_weight);
            END IF;
         END IF;

         k := b_dependency_groups(p_group_id).primary_domains.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(1, l_ctxt, 'Task logical/physical weights: ('||l_task_logical_weight||')('||l_task_physical_weight||')');
      -- now that we've composed the task components, figure out what bundle to give it to and make the task
      fnd_oam_debug.log(1, l_ctxt, 'Getting bundle for group...');
      l_bundle_object_id := GET_BUNDLE_FOR_GROUP(b_dependency_groups(p_group_id));
      fnd_oam_debug.log(1, l_ctxt, 'Using Bundle_id: '||b_bundles(l_bundle_object_id).bundle_id);
      l_weight := NVL(b_dependency_groups(p_group_id).weight, l_task_logical_weight);
      fnd_oam_debug.log(1, l_ctxt, 'Using Task Weight: '||l_weight);

      --skip the PRIORITY column for now
      INSERT INTO FND_OAM_DSCRAM_TASKS (TASK_ID,
                                        BUNDLE_ID,
                                        TASK_STATUS,
                                        WEIGHT,
                                        WORKERS_ASSIGNED,
                                        CREATED_BY,
                                        CREATION_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATE_LOGIN
                                        )
         VALUES
            (l_task_id,
             b_bundles(l_bundle_object_id).bundle_id,
             FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
             l_weight,
             0,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID);

      --update the bundle's assigned weight and task count
      b_bundles(l_bundle_object_id).assigned_task_count := b_bundles(l_bundle_object_id).assigned_task_count + 1;
      b_bundles(l_bundle_object_id).assigned_physical_weight := b_bundles(l_bundle_object_id).assigned_physical_weight + NVL(l_weight, l_task_physical_weight);

      COMMIT;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         --quick fail, cause other tasks to skip so we can write the error somewhere
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         --mark the run object
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_ctxt,
                                SQLCODE,
                                SQLERRM);
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to COMPILE_CONFIG_INSTANCE to dump out tasks/units
   PROCEDURE GENERATE_ENGINE_TASKS
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GENERATE_ENGINE_TASKS';

      l_group_id                NUMBER;
      l_ignore                  BOOLEAN;

      k                         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- loop through the dependency groups
      l_group_id := b_dependency_groups.FIRST;
      WHILE l_group_id IS NOT NULL LOOP
         --TODO: come up with a way to identify a task we've already compiled.
         --Problem: group_ids are transient and can be totally different based on the domain distribution.  re-compiling
         --and trying to match them up would require a full task comparison?
         --For now, just create a new task for each dependency group
         fnd_oam_debug.log(1, l_ctxt, 'Adding Task for group_id: '||l_group_id);
         l_ignore := ADD_ENGINE_TASK_WITH_UNITS(l_group_id);

         l_group_id := b_dependency_groups.NEXT(l_group_id);
      END LOOP;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         --mark the run object
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_ctxt,
                                SQLCODE,
                                SQLERRM);
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to COMPILE_CONFIG_INSTANCE to write the updated weight of the run/bundles to the db.
   PROCEDURE UPDATE_RUN_BUNDLE_WEIGHTS
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'UPDATE_RUN_BUNDLE_WEIGHTS';
      l_weight          NUMBER;
      k                         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      k := b_bundles.FIRST;
      WHILE k IS NOT NULL LOOP
         l_weight := NVL(b_bundles(k).weight, b_bundles(k).assigned_physical_weight);
         --add this bundle's weight to the run's assigned_physical_weight
         b_run.assigned_physical_weight := b_run.assigned_physical_weight + l_weight;
         fnd_oam_debug.log(1, l_ctxt, 'Updating bundle_id('||b_bundles(k).bundle_id||') weight('||l_weight||')');
         UPDATE fnd_oam_dscram_bundles
            SET weight = l_weight
            WHERE bundle_id = b_bundles(k).bundle_id;
         k := b_bundles.NEXT(k);
      END LOOP;

      l_weight := NVL(b_run.weight, b_run.assigned_physical_weight);
      fnd_oam_debug.log(1, l_ctxt, 'Updating run_id('||b_run.run_id||') weight ('||l_weight||')');
      UPDATE fnd_oam_dscram_runs_b
         SET weight = l_weight
         WHERE run_id = b_run.run_id;

      COMMIT;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                l_ctxt,
                                SQLCODE,
                                SQLERRM);
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE PROGRAM_ERROR;
   END;

   -- Private, helper to COMPILE_CONFIG_INSTANCE to write dirty objects to the db.
   PROCEDURE WRITE_DIRTY_OBJECTS
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'WRITE_DIRTY_OBJECTS';

      k                         NUMBER;
      l_error_found             BOOLEAN := FALSE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --TODO: see if we can make this bulk
      --TODO: need to write the target_type/target_id at some point - probably requires many changes.
      k := b_objects.FIRST;
      WHILE k IS NOT NULL LOOP
         IF b_objects(k).is_dirty THEN
            --all objects in b_objects should have db objects already created so just try to update
            BEGIN
               UPDATE fnd_oam_dscfg_objects
                  SET errors_found_flag = b_objects(k).new_errors_found_flag,
                  message = b_objects(k).new_message,
                  target_type = b_objects(k).target_type,
                  target_id = b_objects(k).target_id,
                  last_update_date = SYSDATE,
                  last_updated_by = FND_GLOBAL.USER_ID,
                  last_update_login = FND_GLOBAL.USER_ID
                  WHERE object_id = b_objects(k).object_id;
            EXCEPTION
               WHEN OTHERS THEN
                  fnd_oam_debug.log(3, l_ctxt, 'While writing object_id('||b_objects(k).object_id||'): Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
                  l_error_found := TRUE;
            END;
         END IF;
         k := b_objects.NEXT(k);
      END LOOP;

      --commit whatever we could do
      COMMIT;

      --raise an error if we couldn't write something
      IF l_error_found THEN
         RAISE STORAGE_ERROR;
      END IF;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN STORAGE_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         --raise a special kind of error to signal the caller
         RAISE STORAGE_ERROR;
   END;

   -- Public
   PROCEDURE COMPILE_CONFIG_INSTANCE(x_run_id   OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPILE_CONFIG_INSTANCE';

      l_config_instance_id      NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get the config_instance_id, throws error if not initialized
      l_config_instance_id := FND_OAM_DSCFG_INSTANCES_PKG.GET_CURRENT_ID;
      fnd_oam_debug.log(1, l_ctxt, 'Using config instance id: '||l_config_instance_id);

      --clear the package state data
      fnd_oam_debug.log(1, l_ctxt, 'Resetting package state variables');
      b_objects.DELETE;
      b_dml_update_segments.DELETE;
      b_dml_delete_stmts.DELETE;
      b_dml_truncate_stmts.DELETE;
      b_primary_domains.DELETE;
      b_domain_metadata_map.DELETE;
      b_dependency_groups.DELETE;
      b_domain_to_group_map.DELETE;
      b_run.object_id := NULL;
      b_bundles.DELETE;

      --bulk fetch the objects from the database and fill the state
      fnd_oam_debug.log(1, l_ctxt, 'Fetching Compilable Objects');
      FETCH_COMPILABLE_OBJECTS(l_config_instance_id);

      --now that all the objects have been fetched and cached, traverse the caches
      --and figure out which primary domains are related to one another and group them into
      --dependency groups
      fnd_oam_debug.log(1, l_ctxt, 'Computing Dependency Groups');
      COMPUTE_DEPENDENCY_GROUPS;

      --ALL of the data should be parsed into groups and validated by this point.

      --dump out the engine entities, if any fail, skip processing the rest since we don't
      --have a solid way to
      BEGIN
         fnd_oam_debug.log(1, l_ctxt, 'Generating an Engine Run Entity');
         GENERATE_ENGINE_RUN(l_config_instance_id);

         --generate the engine bundles
         fnd_oam_debug.log(1, l_ctxt, 'Generating Engine Bundles');
         GENERATE_ENGINE_BUNDLES;

         --traverse the dependency groups and output
         fnd_oam_debug.log(1, l_ctxt, 'Generating Engine Tasks');
         GENERATE_ENGINE_TASKS;

         --write out the updated run and bundle weights
         UPDATE_RUN_BUNDLE_WEIGHTS;
      EXCEPTION
         WHEN PROGRAM_ERROR THEN
            -- a child function failed, it should have written a message somewhere.
            RAISE;
         WHEN OTHERS THEN
            --if we can write this error to the run, do so
            IF b_run.object_id IS NOT NULL THEN
               MARK_OBJECT_AS_ERRORED(b_run.object_id,
                                      l_ctxt,
                                      SQLCODE,
                                      SQLERRM);
            END IF;
            RAISE PROGRAM_ERROR;
      END;

      --finally write out all dirty objects
      WRITE_DIRTY_OBJECTS;

      --success
      x_run_id := b_run.run_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN STORAGE_ERROR THEN
         -- only raised by write_dirty_objects to tell us it failed and we should skip trying to
         -- write the dirty objects again.
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN PROGRAM_ERROR THEN
         -- one of the child methods failed, try to write dirty objects out
         BEGIN
            WRITE_DIRTY_OBJECTS;
         EXCEPTION
            WHEN OTHERS THEN
               -- if we can't then there's nothing else we can do but raise the exception and hope
               -- there's something in the logs.
               null;
         END;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN NO_DATA_FOUND THEN
         --just exit, this should only occur at the beginning before processing
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         -- this should only occur locally if something is really wrong, just raise it up
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   FUNCTION GET_DEFAULT_NUM_WORKERS
      RETURN NUMBER
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_DEFAULT_NUM_WORKERS';
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --make sure we've set the default_workers_allowed
      IF B_DEFAULT_WORKERS_ALLOWED IS NULL THEN
         BEGIN
            SELECT NVL(to_number(value), 1) - 1
               INTO B_DEFAULT_WORKERS_ALLOWED
               FROM v$system_parameter
               WHERE name = 'cpu_count';

            IF B_DEFAULT_WORKERS_ALLOWED <= 0 THEN
               B_DEFAULT_WORKERS_ALLOWED := 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               B_DEFAULT_WORKERS_ALLOWED := 1;
         END;
      END IF;
      fnd_oam_debug.log(1, l_ctxt, 'Default Workers Allowed: '||B_DEFAULT_WORKERS_ALLOWED);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN B_DEFAULT_WORKERS_ALLOWED;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   FUNCTION GET_DEFAULT_BATCH_SIZE
      RETURN NUMBER
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_DEFAULT_BATCH_SIZE';
   BEGIN
      --currently static
      RETURN B_DEFAULT_BATCH_SIZE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   FUNCTION GET_DFLT_VALID_CHECK_INTERVAL
      RETURN NUMBER
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_DFLT_VALID_CHECK_INTERVAL';
   BEGIN
      --currently static
      RETURN B_DEFAULT_VALID_CHECK_INTERVAL;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   FUNCTION GET_DFLT_MIN_PARALLEL_WEIGHT
      RETURN NUMBER
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_DFLT_MIN_PARALLEL_WEIGHT';
   BEGIN
      --currently static
      RETURN B_DEFAULT_MIN_PARALLEL_WEIGHT;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

END FND_OAM_DSCFG_COMPILER_PKG;

/

  GRANT EXECUTE ON "APPS"."FND_OAM_DSCFG_COMPILER_PKG" TO "EM_OAM_MONITOR_ROLE";
