--------------------------------------------------------
--  DDL for Package Body EDW_WH_DANG_RECOVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_WH_DANG_RECOVERY" AS
/*$Header: EDWWHDRB.pls 115.10 2003/11/06 00:57:15 vsurendr noship $*/
 version          CONSTANT CHAR (80)
            := '$Header: EDWWHDRB.pls 115.10 2003/11/06 00:57:15 vsurendr noship $';


   PROCEDURE load_error_table (
      p_fact_list       IN   VARCHAR2,
      p_dim_list        IN   VARCHAR2,
      p_op_tablespace   IN   VARCHAR2,
      p_parallel        IN   NUMBER,
      p_bis_owner       IN   VARCHAR2,
      p_instance        IN   VARCHAR2,
      p_debug           IN   BOOLEAN,
      p_mode            IN   VARCHAR2,
      p_called_from     IN   VARCHAR2,
      p_fk_table        IN   VARCHAR2
   )
   IS
   BEGIN
      g_bis_owner := p_bis_owner;
      g_op_tablespace := p_op_tablespace;
      g_parallel := p_parallel;
      g_instance := p_instance;
      g_debug := p_debug;
      g_mode := p_mode; --CDI or LOADER
      g_called_from := p_called_from; --CDI or INSTANCE
      g_fk_table := p_fk_table;


--if called from CDI, the fk table name is passed. so no need to recreate it.

      --if g_instance is null, this call is from check data validity
      --else its from a source instance
      IF g_called_from = 'INSTANCE'
      THEN
         EDW_OWB_COLLECTION_UTIL.init_all('ABC',null,'bis.edw.loader');
      END IF;

      IF p_dim_list IS NULL
      THEN
         g_status := FALSE;
         g_status_message :=
                     edw_owb_collection_util.get_message ('EDW_NO_DIM_FOUND');
         g_status_varchar := 'ERROR';
         write_to_log_file_n (g_status_message);
         RETURN;
      END IF;

      IF p_fact_list IS NULL
      THEN
         g_status := FALSE;
         g_status_message :=
                   edw_owb_collection_util.get_message ('EDW_NO_FACTS_FOUND');
         g_status_varchar := 'ERROR';
         write_to_log_file_n (g_status_message);
         RETURN;
      END IF;

      init_all;

      IF parse_facts_dims (p_fact_list, p_dim_list) = FALSE
      THEN
         g_status_varchar := 'ERROR';
         RETURN;
      END IF;

      IF get_dim_ids = FALSE
      THEN
         g_status_varchar := 'ERROR';
         RETURN;
      END IF;

      IF load_error_table = FALSE
      THEN
         g_status_varchar := 'ERROR';
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         g_status_varchar := 'ERROR';
         write_to_log_file_n (g_status_message);
   END load_error_table;

   FUNCTION load_error_table
      RETURN BOOLEAN
   IS
   BEGIN
      FOR i IN 1 .. g_number_fact_list
      LOOP
         IF read_metadata (g_fact_list (i), g_mode) = FALSE
         THEN
            RETURN FALSE;
         END IF;

         IF generate_op_fstg_table (g_fact_list (i), g_mode) = FALSE
         THEN
            RETURN FALSE;
         END IF;

         IF g_op_fstg_table_empty = TRUE
         THEN
            write_to_log_file_n ('No fresh data to be checked for bad keys');
         END IF;

         IF find_bad_fk_records (g_fstg_op_table) = FALSE
         THEN
            RETURN FALSE;
         END IF;

         IF load_fstg_error_table = FALSE
         THEN
            RETURN FALSE;
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END load_error_table;

   FUNCTION parse_facts_dims (p_fact_list IN VARCHAR2, p_dim_list IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF edw_owb_collection_util.parse_names (
            p_fact_list,
            g_fact_list,
            g_number_fact_list
         ) = FALSE
      THEN
         g_status_message := edw_owb_collection_util.g_status_message;
         RETURN FALSE;
      END IF;

      IF edw_owb_collection_util.parse_names (
            p_dim_list,
            g_dim_list,
            g_number_dim_list
         ) = FALSE
      THEN
         g_status_message := edw_owb_collection_util.g_status_message;
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END parse_facts_dims;

   FUNCTION get_dim_ids
      RETURN BOOLEAN
   IS
   BEGIN
      FOR i IN 1 .. g_number_dim_list
      LOOP
         g_dim_id_list (i) :=
                       edw_owb_collection_util.get_object_id (g_dim_list (i));
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END get_dim_ids;

   FUNCTION read_metadata (p_fact IN VARCHAR2, p_mode IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt                  VARCHAR2 (10000);

      TYPE curtyp IS REF CURSOR;

      cv                      curtyp;
      l_dim_list              VARCHAR2 (30000);
      l_fstg_fk               edw_owb_collection_util.varchartabletype;
      l_fstg_fk_id            edw_owb_collection_util.numbertabletype;
      l_fk_dim                edw_owb_collection_util.varchartabletype;
      l_number_fstg_fk        NUMBER;
      l_map_src_col           edw_owb_collection_util.varchartabletype;
      l_map_tgt_col           edw_owb_collection_util.varchartabletype;
      l_number_map_cols       NUMBER;
      l_skipped_cols          edw_owb_collection_util.varchartabletype;
      l_number_skipped_cols   NUMBER;
      l_index                 NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_file_n (   'In read_metadata'
                              || get_time);
      END IF;

      g_fact := p_fact;
      l_stmt :=
               'SELECT rel.relation_name, rel.relation_id, fact.fact_id '
            || 'FROM edw_relations_md_v  rel, edw_relationmapping_md_v map, edw_facts_md_v fact '
            || 'WHERE fact.fact_name = :a '
            || 'AND map.targetdataentity = fact.fact_id '
            || 'AND rel.relation_id = map.sourcedataentity ';

      IF g_debug
      THEN
         write_to_log_file_n (
               'Going to execute '
            || l_stmt
            || ' using '
            || p_fact
         );
      END IF;

      OPEN cv FOR l_stmt USING p_fact;
      FETCH cv INTO g_fstg_name, g_fstg_id, g_fact_id;
      CLOSE cv;

      IF g_debug
      THEN
         write_to_log_file_n (
               'Results '
            || g_fstg_name
            || ','
            || g_fstg_id
            || ','
            || g_fact_id
         );
      END IF;

      l_stmt :=
               'select uk.column_name from edw_unique_key_columns_md_v uk, '
            || 'edw_all_columns_md_v col '
            || 'where col.column_id = uk.column_id and '
            || 'col.entity_id = :a ';

      IF g_debug
      THEN
         write_to_log_file_n (
               'Going to execute '
            || l_stmt
            || ' using '
            || g_fstg_id
         );
      END IF;

      OPEN cv FOR l_stmt USING g_fstg_id;
      FETCH cv INTO g_fstg_pk;
      CLOSE cv;

      IF g_debug
      THEN
         write_to_log_file_n (   'PK is '
                              || g_fstg_pk);
      END IF;

      IF g_fstg_pk IS NULL
      THEN
         g_status_message :=
               edw_owb_collection_util.get_message (
                  'EDW_NO_PK_FOR_INTERFACE_TABLE'
               );
         RETURN FALSE;
      END IF;

      l_dim_list := NULL;

      FOR i IN 1 .. g_number_dim_list
      LOOP
         l_dim_list :=    l_dim_list
                       || ''''
                       || g_dim_list (i)
                       || ''',';
      END LOOP;

      l_dim_list := SUBSTR (l_dim_list, 1,   LENGTH (l_dim_list)
                                           - 1);

      IF g_debug
      THEN
         write_to_log_file_n (   'Dim list='
                              || l_dim_list);
      END IF;

      l_stmt :=    'SELECT fk.fk_column_name, fk.fk_column_id, dim.dim_name '
                || 'FROM edw_dimensions_md_v dim, '
                || 'edw_unique_keys_md_v uk, '
                || 'edw_foreign_key_columns_md_v fk, '
                || 'edw_all_columns_md_v col '
                || 'WHERE dim.dim_name in ('
                || l_dim_list
                || ') '
                || 'AND uk.entity_id = dim.dim_id '
                || 'AND fk.pk_id = uk.key_id '
                || 'AND col.column_id = fk.fk_column_id '
                || 'AND col.entity_id = :a ';

      IF g_debug
      THEN
         write_to_log_file_n (
               'Going to execute '
            || l_stmt
            || ' using '
            || g_fstg_id
         );
      END IF;

      l_number_fstg_fk := 1;
      OPEN cv FOR l_stmt USING g_fstg_id;

      LOOP
         FETCH cv INTO l_fstg_fk (l_number_fstg_fk),
                       l_fstg_fk_id (l_number_fstg_fk),
                       l_fk_dim (l_number_fstg_fk);
         EXIT WHEN cv%NOTFOUND;
         l_number_fstg_fk :=   l_number_fstg_fk
                             + 1;
      END LOOP;

      CLOSE cv;
      l_number_fstg_fk :=   l_number_fstg_fk
                          - 1;

      IF g_debug
      THEN
         write_to_log_file_n ('The FK of the fstg table');

         FOR i IN 1 .. l_number_fstg_fk
         LOOP
            write_to_log_file (
                  l_fstg_fk (i)
               || '('
               || l_fstg_fk_id (i)
               || ')   '
               || l_fk_dim (i)
            );
         END LOOP;
      END IF;
      --Fix for bug P1 2739489.
      --get the mapping details
      declare
        l_mapping_id number;
        l_fstgTableUsageId  number;
        l_fstgTableId  number;
        l_fstgTableName  varchar2(200);
        l_factTableUsageId  number;
        l_factTableId  number;
        l_factTableName  varchar2(200);
        l_fstgPKName  varchar2(200);
        l_factPKName  varchar2(200);
        l_dimTableName EDW_OWB_COLLECTION_UTIL.varcharTableType;
        l_dim_row_count EDW_OWB_COLLECTION_UTIL.numberTableType;
        l_dimTableId EDW_OWB_COLLECTION_UTIL.numberTableType;
        l_dimUserPKName EDW_OWB_COLLECTION_UTIL.varcharTableType;
      begin
        --fix for bug 2847694
        l_stmt:='select mapping_id '||
        'from edw_pvt_map_properties_md_v,edw_relations_md_v '||
        'where edw_relations_md_v.relation_name=:1 '||
        'and edw_relations_md_v.relation_id=edw_pvt_map_properties_md_v.primary_target ';
        if g_debug then
          write_to_log_file_n(l_stmt||' '||p_fact);
        end if;
        open cv for l_stmt using p_fact;
        fetch cv into l_mapping_id;
        if EDW_OWB_COLLECTION_UTIL.get_stg_map_pk_params(
          l_mapping_id,
          l_fstgTableUsageId,
          l_fstgTableId,
          l_fstgTableName,
          l_factTableUsageId,
          l_factTableId,
          l_factTableName,
          l_fstgPKName,
          l_factPKName
          )=false then
          return false;
        end if;
        if EDW_OWB_COLLECTION_UTIL.get_stg_map_fk_details(
          l_fstgTableUsageId,
          l_fstgTableId,
          l_mapping_id,
          1000002,
          g_op_tablespace,
          g_bis_owner,
          l_dimTableName,
          l_dim_row_count,
          l_dimTableId,
          l_dimUserPKName,
          l_map_src_col,
          l_map_tgt_col,
          l_number_map_cols)=false then
          return false;
        end if;
      end;
      IF g_debug
      THEN
         write_to_log_file_n ('The Mapping relations between the keys');

         FOR i IN 1 .. l_number_map_cols
         LOOP
            write_to_log_file (
                  l_map_src_col (i)
               || ' -> '
               || l_map_tgt_col (i)
            );
         END LOOP;
      END IF;

      IF edw_owb_collection_util.get_item_set_cols (
            l_skipped_cols,
            l_number_skipped_cols,
            p_fact,
            'SKIP_LOAD_SET'
         ) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      IF g_debug
      THEN
         write_to_log_file_n ('The skipped cols of the fact');

         FOR i IN 1 .. l_number_skipped_cols
         LOOP
            write_to_log_file (l_skipped_cols (i));
         END LOOP;
      END IF;

      g_number_fstg_fk := 0;

      --l_fstg_fk(l_number_fstg_fk),l_fstg_fk_id(l_number_fstg_fk),l_fk_dim(l_number_fstg_fk);
      FOR i IN 1 .. l_number_map_cols
      LOOP
         IF edw_owb_collection_util.value_in_table (
               l_skipped_cols,
               l_number_skipped_cols,
               l_map_tgt_col (i)
            ) = FALSE
         THEN
            l_index :=
                  edw_owb_collection_util.index_in_table (
                     l_fstg_fk,
                     l_number_fstg_fk,
                     l_map_src_col (i)
                  );

            IF l_index > 0
            THEN
               g_number_fstg_fk :=   g_number_fstg_fk
                                   + 1;
               g_fstg_fk (g_number_fstg_fk) := l_fstg_fk (l_index);
               g_fstg_fk_id (g_number_fstg_fk) := l_fstg_fk_id (l_index);
               g_fk_dim (g_number_fstg_fk) := l_fk_dim (l_index);
            END IF;
         END IF;
      END LOOP;

      IF g_debug
      THEN
         write_to_log_file_n ('The final list of fks to consider');

         FOR i IN 1 .. g_number_fstg_fk
         LOOP
            write_to_log_file (
                  g_fstg_fk (i)
               || '('
               || g_fstg_fk_id (i)
               || ')  '
               || g_fk_dim (i)
            );
         END LOOP;
      END IF;

      l_stmt :=    'SELECT fk.fk_column_name '
                || 'FROM edw_dimensions_md_v dim, '
                || 'edw_unique_keys_md_v uk, '
                || 'edw_foreign_key_columns_md_v fk, '
                || 'edw_all_columns_md_v col '
                || 'WHERE dim.dim_name = ''EDW_INSTANCE_M'' '
                || 'AND uk.entity_id = dim.dim_id '
                || 'AND fk.pk_id = uk.key_id '
                || 'AND col.column_id = fk.fk_column_id '
                || 'AND col.entity_id = :a ';
      OPEN cv FOR l_stmt USING g_fstg_id;
      FETCH cv INTO g_instance_col;
      CLOSE cv;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         IF p_mode = 'CDI'
         THEN
            g_bad_fk_tables (i) :=
                    g_bis_owner
                 || '.FBC_'
                 || g_fstg_fk_id (i)
                 || '_'
                 || g_fstg_id;
         ELSE
            g_bad_fk_tables (i) :=
                    g_bis_owner
                 || '.FBL_'
                 || g_fstg_fk_id (i)
                 || '_'
                 || g_fstg_id;
         END IF;
      END LOOP;

      IF g_debug
      THEN
         write_to_log_file_n (   'Instance col '
                              || g_instance_col);
      END IF;

      g_number_fstg_all_fk := 0;

      IF edw_owb_collection_util.get_fks_for_table (
            g_fstg_name,
            g_fstg_all_fk,
            g_number_fstg_all_fk
         ) = FALSE
      THEN
         g_status_message := edw_owb_collection_util.g_status_message;
         RETURN FALSE;
      END IF;

      IF g_debug
      THEN
         write_to_log_file_n ('All FKs of the staging table');

         FOR i IN 1 .. g_number_fstg_all_fk
         LOOP
            write_to_log_file (g_fstg_all_fk (i));
         END LOOP;
      END IF;

      g_number_fstg_cols := 0;

      IF edw_owb_collection_util.get_columns_for_table (
            g_fstg_name,
            g_fstg_cols,
            g_number_fstg_cols
         ) = FALSE
      THEN
         g_status_message := edw_owb_collection_util.g_status_message;
         RETURN FALSE;
      END IF;

      IF g_debug
      THEN
         write_to_log_file_n ('All Columns of the staging table');

         FOR i IN 1 .. g_number_fstg_cols
         LOOP
            write_to_log_file (g_fstg_cols (i));
         END LOOP;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END read_metadata;

   FUNCTION generate_op_fstg_table (p_fact IN VARCHAR2, p_mode IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt    VARCHAR2 (20000);
      l_count   NUMBER;
      l_col     VARCHAR2 (400);
   BEGIN
      IF g_debug
      THEN
         write_to_log_file_n (   'In generate_op_fstg_table'
                              || get_time);
      END IF;

      IF g_fk_table IS NOT NULL
      THEN
         g_fstg_op_table := g_fk_table;
         RETURN TRUE;
      END IF;

      IF p_mode = 'CDI'
      THEN
         g_fstg_op_table :=    g_bis_owner
                            || '.STG_'
                            || g_fstg_id;
      ELSE
         g_fstg_op_table :=    g_bis_owner
                            || '.S';

         FOR i IN 1 .. g_number_dim_list
         LOOP
            g_fstg_op_table :=    g_fstg_op_table
                               || '_'
                               || g_dim_id_list (i);
         END LOOP;
      END IF;

      IF edw_owb_collection_util.does_table_have_data (
            g_fstg_name,
            'LAST_UPDATE_DATE IS NOT NULL'
         ) = 2
      THEN
         l_col := 'LAST_UPDATE_DATE';
      ELSE
         l_col := 'ROWNUM';
      END IF;

      l_stmt :=    'create table '
                || g_fstg_op_table
                || ' tablespace '
                || g_op_tablespace;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel(degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=    l_stmt
                || ' as select ';

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' /*+PARALLEL('
                   || g_fstg_name
                   || ','
                   || g_parallel
                   || ')*/ ';
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         l_stmt :=    l_stmt
                   || g_fstg_fk (i)
                   || ',';
      END LOOP;

      l_stmt :=    l_stmt
                || g_fstg_pk
                || ',rowid row_id,'
                || l_col
                || ' col from '
                || g_fstg_name
                || ' where collection_status in (''READY'',''DANGLING'')';

      IF edw_owb_collection_util.drop_table (g_fstg_op_table) = FALSE
      THEN
         NULL;
      END IF;

      IF g_debug
      THEN
         write_to_log_file_n (   'Going to execute '
                              || l_stmt
                              || get_time);
      END IF;

      EXECUTE IMMEDIATE l_stmt;
      l_count := SQL%ROWCOUNT;

      IF g_debug
      THEN
         write_to_log_file_n (
               'Created '
            || g_fstg_op_table
            || ' with '
            || l_count
            || ' rows '
            || get_time
         );
      END IF;

      IF l_count = 0
      THEN
         g_op_fstg_table_empty := TRUE;
      END IF;

      edw_owb_collection_util.analyze_table_stats (
         SUBSTR (
            g_fstg_op_table,
              INSTR (g_fstg_op_table, '.')
            + 1,
            LENGTH (g_fstg_op_table)
         ),
         SUBSTR (g_fstg_op_table, 1,   INSTR (g_fstg_op_table, '.')
                                     - 1)
      );
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END generate_op_fstg_table;


/*
each time a fact is processed, some table needs to hold this info. i another process comes along,
that one exits
*/
   FUNCTION find_bad_fk_records (p_fstg IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF g_debug
      THEN
         write_to_log_file_n (   'In find_bad_fk_records '
                              || get_time);
      END IF;

      FOR i IN 1 .. g_number_dim_list
      LOOP
         IF g_instance IS NULL
         THEN
            g_bad_key_tables (i) :=    g_bis_owner
                                    || '.B_NOINS_'
                                    || g_fact_id
                                    || '_'
                                    || g_dim_id_list (i); --this name has
         --dependency with CDI code
         ELSE
            g_bad_key_tables (i) :=    g_bis_owner
                                    || '.B_'
                                    || g_instance
                                    || '_'
                                    || g_fact_id
                                    || '_'
                                    || g_dim_id_list (i);
         --has dep with source pack
         END IF;
      END LOOP;

      IF g_debug
      THEN
         write_to_log_file_n ('The bad key tables are ');

         FOR i IN 1 .. g_number_dim_list
         LOOP
            write_to_log_file (
                  'Dim '
               || g_dim_list (i)
               || '  '
               || g_bad_key_tables (i)
            );
         END LOOP;
      END IF;

      FOR i IN 1 .. g_number_dim_list
      LOOP
         IF create_bad_fk_tables (g_bad_key_tables (i), g_dim_list (i)) =
                                                                        FALSE
         THEN
            RETURN FALSE;
         END IF;
      END LOOP;

      FOR i IN 1 .. g_number_dim_list
      LOOP
         IF edw_owb_collection_util.drop_table (g_bad_key_tables (i)) = FALSE
         THEN
            NULL;
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END find_bad_fk_records;

   FUNCTION create_bad_fk_tables (
      p_bad_table   IN   VARCHAR2,
      p_dimension   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      l_stmt   VARCHAR2 (20000);
   BEGIN
      IF g_debug
      THEN
         write_to_log_file_n (
               'In create_bad_fk_tables for dimension '
            || p_dimension
            || get_time
         );
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         IF g_fk_dim (i) = p_dimension
         THEN
            l_stmt :=    'create table '
                      || g_bad_fk_tables (i)
                      || ' tablespace '
                      || g_op_tablespace;

            IF g_parallel IS NOT NULL
            THEN
               l_stmt :=    l_stmt
                         || ' parallel(degree '
                         || g_parallel
                         || ') ';
            END IF;

            l_stmt :=    l_stmt
                      || ' as select /*+ORDERED*/ ';

            IF g_parallel IS NOT NULL
            THEN
               IF g_fstg_name = g_fstg_op_table
               THEN
                  l_stmt :=
                              l_stmt
                           || ' /*+PARALLEL(A,'
                           || g_parallel
                           || ')*/ ';
               END IF;
            END IF;

            IF g_fstg_name = g_fstg_op_table
            THEN
               l_stmt :=    l_stmt
                         || 'A.rowid row_id,';
            ELSE
               l_stmt :=    l_stmt
                         || 'A.row_id row_id,';
            END IF;

            l_stmt :=    l_stmt
                      || '''GN'' '
                      || g_fstg_fk (i)
                      || 'FL '
                      || ' from '
                      || g_fstg_op_table
                      || ' A,'
                      || p_bad_table
                      || ' B where A.'
                      || g_fstg_fk (i)
                      || '=B.KEY_VALUE'
                      || ' and A.'
                      || g_instance_col
                      || '=B.instance';

            IF g_fstg_name = g_fstg_op_table
            THEN
               l_stmt :=
                        l_stmt
                     || ' and A.collection_status in (''READY'',''DANGLING'')';
            END IF;

            IF edw_owb_collection_util.drop_table (g_bad_fk_tables (i)) =
                                                                         FALSE
            THEN
               NULL;
            END IF;

            IF g_debug
            THEN
               write_to_log_file_n (
                     'Going to execute '
                  || l_stmt
                  || get_time
               );
            END IF;

            EXECUTE IMMEDIATE l_stmt;

            IF g_debug
            THEN
               write_to_log_file_n (
                     'Created '
                  || g_bad_fk_tables (i)
                  || ' with '
                  || SQL%ROWCOUNT
                  || ' rows '
                  || get_time
               );
            END IF;
         --EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_bad_fk_tables(i),instr(g_bad_fk_tables(i),'.')+1,
         --length(g_bad_fk_tables(i))),substr(g_bad_fk_tables(i),1,instr(g_bad_fk_tables(i),'.')-1));
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END create_bad_fk_tables;

   FUNCTION load_fstg_error_table
      RETURN BOOLEAN
   IS
      l_table         VARCHAR2 (400);
      l_merge_table   VARCHAR2 (400);
   BEGIN
      IF g_debug
      THEN
         write_to_log_file_n (   'In load_fstg_error_table '
                              || get_time);
      END IF;

      g_fstg_error_table :=    g_bis_owner
                            || '.'
                            || SUBSTR (g_fact, 1, 28)
                            || 'BR';
      l_table := SUBSTR (
                    g_fstg_error_table,
                      INSTR (g_fstg_error_table, '.')
                    + 1,
                    LENGTH (g_fstg_error_table)
                 );

      IF merge_bad_fk_tables (l_merge_table) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      IF create_fstg_error_table ('DATA', l_merge_table) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         IF edw_owb_collection_util.drop_table (g_bad_fk_tables (i)) = FALSE
         THEN
            NULL;
         END IF;
      END LOOP;

      IF edw_owb_collection_util.drop_table (g_fstg_op_table) = FALSE
      THEN
         NULL;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END load_fstg_error_table;

   FUNCTION create_fstg_error_table (p_mode IN VARCHAR2, p_table IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt    VARCHAR2 (32000);
      l_table   VARCHAR2 (400);
      l_index   NUMBER;
      l_count   NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_file_n (   'In create_fstg_error_table '
                              || get_time);
      END IF;

      l_table := SUBSTR (
                    g_fstg_error_table,
                      INSTR (g_fstg_error_table, '.')
                    + 1,
                    LENGTH (g_fstg_error_table)
                 );

      IF p_mode = 'NO-DATA'
      THEN
         l_stmt :=    'create table '
                   || g_fstg_error_table
                   || ' tablespace '
                   || g_op_tablespace
                   || ' as select '
                   || ' * from '
                   || g_fstg_name
                   || ' where 1=2';

         IF g_debug
         THEN
            write_to_log_file_n (   'Going to execute '
                                 || l_stmt
                                 || get_time);
         END IF;

         EXECUTE IMMEDIATE l_stmt;

         IF g_debug
         THEN
            write_to_log_file_n (
                  'Created '
               || g_fstg_error_table
               || ' with '
               || SQL%ROWCOUNT
               || ' rows '
               || get_time
            );
         END IF;

         l_stmt :=    'alter table '
                   || g_fstg_error_table
                   || ' add (';

         FOR i IN 1 .. g_number_fstg_all_fk
         LOOP
            l_stmt :=    l_stmt
                      || g_fstg_all_fk (i)
                      || 'FL varchar2(2),';
         END LOOP;

         l_stmt :=    SUBSTR (l_stmt, 1,   LENGTH (l_stmt)
                                         - 1)
                   || ')';

         IF g_debug
         THEN
            write_to_log_file_n (   'Going to execute '
                                 || l_stmt
                                 || get_time);
         END IF;

         EXECUTE IMMEDIATE l_stmt;

         IF edw_owb_collection_util.create_synonym (
               l_table,
               g_fstg_error_table
            ) = FALSE
         THEN
            RETURN FALSE;
         END IF;
      ELSE
         --p_table is the merged table
         IF edw_owb_collection_util.drop_table (g_fstg_error_table) = FALSE
         THEN
            NULL;
         END IF;

         l_stmt :=    'create table '
                   || g_fstg_error_table
                   || ' tablespace '
                   || g_op_tablespace
                   || ' as select '
                   || ' /*+ORDERED*/ ';

         IF g_parallel IS NOT NULL
         THEN
            l_stmt :=    l_stmt
                      || ' /*+PARALLEL(A,'
                      || g_parallel
                      || ')*/ ';
         END IF;

         FOR i IN 1 .. g_number_fstg_cols
         LOOP
            l_stmt :=    l_stmt
                      || 'A.'
                      || g_fstg_cols (i)
                      || ',';
         END LOOP;

         FOR i IN 1 .. g_number_fstg_all_fk
         LOOP
            l_index :=
                  edw_owb_collection_util.index_in_table (
                     g_fstg_fk,
                     g_number_fstg_fk,
                     g_fstg_all_fk (i)
                  );

            IF l_index = -1
            THEN
               g_status_message := edw_owb_collection_util.g_status_message;
               RETURN FALSE;
            END IF;

            IF l_index = 0
            THEN
               l_stmt :=    l_stmt
                         || '''GY'' '
                         || g_fstg_all_fk (i)
                         || 'FL,';
            ELSE
               l_stmt :=    l_stmt
                         || p_table
                         || '.'
                         || g_fstg_all_fk (i)
                         || 'FL,';
            END IF;
         END LOOP;

         l_stmt := SUBSTR (l_stmt, 1,   LENGTH (l_stmt)
                                      - 1);
         l_stmt :=    l_stmt
                   || ' from '
                   || p_table
                   || ','
                   || g_fstg_name
                   || ' A where '
                   || p_table
                   || '.row_id=A.rowid ';

         IF g_debug
         THEN
            write_to_log_file_n (   'Going to execute '
                                 || l_stmt
                                 || get_time);
         END IF;

         EXECUTE IMMEDIATE l_stmt;
         l_count := SQL%ROWCOUNT;

         IF g_debug
         THEN
            write_to_log_file_n (
                  'Created '
               || g_fstg_error_table
               || ' with '
               || l_count
               || ' rows '
               || get_time
            );
         END IF;

         IF edw_owb_collection_util.create_synonym (
               l_table,
               g_fstg_error_table
            ) = FALSE
         THEN
            RETURN FALSE;
         END IF;

         IF edw_owb_collection_util.drop_table (p_table) = FALSE
         THEN
            NULL;
         END IF;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END create_fstg_error_table;

   FUNCTION merge_bad_fk_tables (p_merge_table OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt                      VARCHAR2 (32000);
      l_start                     NUMBER;
      l_end                       NUMBER;
      l_table_name                VARCHAR2 (200);
      l_max_count                 NUMBER;
      l_index_table               edw_owb_collection_util.varchartabletype;
      l_number_index_table        NUMBER;
      l_index_table_copy          edw_owb_collection_util.varchartabletype;
      l_number_index_table_copy   NUMBER;
      l_union_table               VARCHAR2 (200);
      l_table                     VARCHAR2 (200);
      l_columns                   edw_owb_collection_util.varchartabletype;
      l_number_columns            NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_file_n ('In merge_bad_fk_tables');
      END IF;

      l_table_name :=    g_bis_owner
                      || '.MERGE_'
                      || g_fact_id;
      l_union_table :=    g_bis_owner
                       || '.UNION_'
                       || g_fact_id;
      l_max_count := 0;
      l_number_index_table := 0;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         l_number_index_table :=   l_number_index_table
                                 + 1;
         l_index_table (l_number_index_table) := g_bad_fk_tables (i);
      END LOOP;

      LOOP
         l_start := 1;
         EXIT WHEN l_number_index_table = 1;
         l_index_table_copy := l_index_table;
         l_number_index_table_copy := l_number_index_table;
         l_number_index_table := 0;

         LOOP --through l_index_table. each loop creates a table
            l_end :=   l_start
                     + 9;

            IF l_end > l_number_index_table_copy
            THEN
               l_end := l_number_index_table_copy;
            ELSIF (  l_end
                   + 1
                  ) = l_number_index_table_copy
            THEN
               l_end :=   l_end
                        + 1;
            END IF;

            l_stmt :=    'create table '
                      || l_union_table
                      || ' tablespace '
                      || g_op_tablespace;

            IF g_parallel IS NOT NULL
            THEN
               l_stmt :=    l_stmt
                         || ' parallel (degree '
                         || g_parallel
                         || ') ';
            END IF;

            l_stmt :=    l_stmt
                      || ' ';
            l_stmt :=    l_stmt
                      || ' as ';

            FOR i IN l_start .. l_end
            LOOP
               l_stmt :=    l_stmt
                         || ' select row_id from '
                         || l_index_table_copy (i)
                         || ' union ';
            END LOOP;

            l_stmt := SUBSTR (l_stmt, 1,   LENGTH (l_stmt)
                                         - 6);

            IF edw_owb_collection_util.drop_table (l_union_table) = FALSE
            THEN
               NULL;
            END IF;

            IF g_debug
            THEN
               write_to_log_file_n (
                     'Going to execute '
                  || l_stmt
                  || get_time
               );
            END IF;

            EXECUTE IMMEDIATE l_stmt;

            IF g_debug
            THEN
               write_to_log_file_n (
                     'Created '
                  || l_union_table
                  || ' with '
                  || SQL%ROWCOUNT
                  || ' rows '
                  || get_time
               );
            END IF;

            l_max_count :=   l_max_count
                           + 1;
            l_table :=    l_table_name
                       || '_O_'
                       || l_max_count;
            l_number_index_table :=   l_number_index_table
                                    + 1;
            l_index_table (l_number_index_table) := l_table;
            l_number_columns := 0;
            l_stmt :=
                  'create table '
               || l_table
               || ' tablespace '
               || g_op_tablespace;

            IF g_parallel IS NOT NULL
            THEN
               l_stmt :=    l_stmt
                         || ' parallel (degree '
                         || g_parallel
                         || ') ';
            END IF;

            l_stmt :=    l_stmt
                      || ' ';
            l_stmt :=    l_stmt
                      || ' as select ';

            FOR i IN l_start .. l_end
            LOOP
               IF edw_owb_collection_util.get_db_columns_for_table (
                     SUBSTR (
                        l_index_table_copy (i),
                          INSTR (l_index_table_copy (i), '.')
                        + 1,
                        LENGTH (l_index_table_copy (i))
                     ),
                     l_columns,
                     l_number_columns,
                     g_bis_owner
                  ) = FALSE
               THEN
                  g_status_message :=
                                     edw_owb_collection_util.g_status_message;
                  write_to_log_file_n (g_status_message);
                  g_status := FALSE;
                  RETURN FALSE;
               END IF;

               FOR j IN 1 .. l_number_columns
               LOOP
                  IF UPPER (l_columns (j)) <> 'ROW_ID'
                  THEN
                     l_stmt :=    l_stmt
                               || 'decode('
                               || l_index_table_copy (i)
                               || '.rowid,null,''GY'','
                               || l_columns (j)
                               || ') '
                               || l_columns (j)
                               || ',';
                  END IF;
               END LOOP;
            END LOOP; --for i in l_start..l_end loop

            l_stmt :=    l_stmt
                      || l_union_table
                      || '.ROW_ID from ';

            FOR i IN l_start .. l_end
            LOOP
               l_stmt :=    l_stmt
                         || l_index_table_copy (i)
                         || ',';
            END LOOP;

            l_stmt :=    l_stmt
                      || l_union_table;
            l_stmt :=    l_stmt
                      || ' where ';

            FOR i IN l_start .. l_end
            LOOP
               l_stmt :=    l_stmt
                         || l_union_table
                         || '.ROW_ID='
                         || l_index_table_copy (i)
                         || '.ROW_ID(+) and ';
            END LOOP;

            l_stmt := SUBSTR (l_stmt, 1,   LENGTH (l_stmt)
                                         - 4);

            IF edw_owb_collection_util.drop_table (l_table) = FALSE
            THEN
               NULL;
            END IF;

            IF g_debug
            THEN
               write_to_log_file_n (
                     'Going to execute '
                  || l_stmt
                  || get_time
               );
            END IF;

            BEGIN
               EXECUTE IMMEDIATE l_stmt;

               IF g_debug
               THEN
                  write_to_log_file_n (
                        'Created '
                     || l_table
                     || ' with '
                     || SQL%ROWCOUNT
                     || ' rows '
                     || get_time
                  );
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  g_status_message := SQLERRM;
                  write_to_log_file_n (g_status_message);
                  g_status := FALSE;
                  RETURN FALSE;
            END;

            --drop the tables
            FOR i IN l_start .. l_end
            LOOP
               IF edw_owb_collection_util.drop_table (l_index_table_copy (i)) =
                                                                        FALSE
               THEN
                  NULL;
               END IF;
            END LOOP;

            l_start :=   l_end
                       + 1;
            EXIT WHEN l_start > l_number_index_table_copy;
         END LOOP;
      END LOOP;

      IF edw_owb_collection_util.drop_table (l_union_table) = FALSE
      THEN
         NULL;
      END IF;

      p_merge_table := l_index_table (1);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_merge_table :='';
         g_status := FALSE;
         g_status_message := SQLERRM;
         write_to_log_file_n (g_status_message);
         RETURN FALSE;
   END merge_bad_fk_tables;

   FUNCTION get_time
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    ' Time '
             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS');
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_file_n (   'Error in get_time '
                              || SQLERRM);
   END get_time;

   PROCEDURE write_to_log_file (p_message IN VARCHAR2)
   IS
   BEGIN
      edw_owb_collection_util.write_to_log_file (p_message);
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END write_to_log_file;

   PROCEDURE write_to_log_file_n (p_message IN VARCHAR2)
   IS
   BEGIN
      write_to_log_file ('   ');
      write_to_log_file (p_message);
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END write_to_log_file_n;

   PROCEDURE init_all
   IS
   BEGIN
      NULL;
      g_status := TRUE;
      g_op_fstg_table_empty := FALSE;
      g_inc_mode := FALSE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_file_n (   'Error in init_all '
                              || SQLERRM);
   END init_all;

   FUNCTION get_g_status_varchar
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_status_varchar;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_file_n (   'Error in get_g_status_varchar '
                              || SQLERRM);
   END get_g_status_varchar;
END edw_wh_dang_recovery;

/
