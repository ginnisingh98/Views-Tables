--------------------------------------------------------
--  DDL for Package Body EDW_CHECK_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_CHECK_DATA_INTEGRITY" AS
/*$Header: EDWCHDTB.pls 120.1 2005/10/18 04:18:59 amitgupt noship $*/
 version          CONSTANT CHAR (80)
            := '$Header: EDWCHDTB.pls 120.1 2005/10/18 04:18:59 amitgupt noship $';

   PROCEDURE check_dimensions_data (
      errbuf                OUT NOCOPY     VARCHAR2,
      retcode               OUT NOCOPY     VARCHAR2,
      p_dim_string1         IN       VARCHAR2,
      p_check_against_ltc   IN       VARCHAR2,
      p_check_tot_recs      IN       VARCHAR2,
      p_detailed_check      IN       VARCHAR2,
      p_sample_size         IN       NUMBER
   )
   IS
   BEGIN
      retcode := '0';

      IF p_detailed_check = 'Y'
      THEN
         g_detailed_check := TRUE;
      ELSE
         g_detailed_check := FALSE;
      END IF;

      --    init_all;
      g_number_names := 1;
      g_names (g_number_names) := p_dim_string1;

      --get the long names
      IF get_long_names = FALSE
      THEN
         fnd_message.set_name ('BIS', 'EDW_CDI_NO_LONG_DIM');
         errbuf := fnd_message.get;
         write_to_out (errbuf);
         --errbuf:='Could not get long names for the dimensions. Stopping Data Check';
         retcode := '2';
         RETURN;
      END IF;

      g_number_sample := p_sample_size;
      write_to_log_n (   'Sample size='
                      || g_number_sample);

      IF p_check_against_ltc = 'Y'
      THEN
         g_check_against_ltc := TRUE;
         write_to_log_n ('check against level tables on');
      ELSE
         write_to_log_n ('check against level tables off');
      END IF;

      IF p_check_tot_recs = 'Y'
      THEN
         g_check_hier := TRUE;
         write_to_log_n ('check of total records making into wh on');
      ELSE
         write_to_log_n ('check of total records making into wh off');
      END IF;

      errbuf := NULL;

      FOR i IN 1 .. g_number_names
      LOOP
         g_check_dimension := FALSE;
         g_object_name := g_names (i);
         g_object_id := g_ids (i);
         g_object_type := 'DIMENSION';

         IF check_dimension (g_names (i)) = FALSE
         THEN
            errbuf := g_status_message;
            retcode := '2';
         END IF;
      END LOOP;
   EXCEPTION
      WHEN g_stg_tables_not_found
      THEN
         errbuf := NULL;
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         errbuf := SQLERRM;
         retcode := '2';
   END check_dimensions_data;

   FUNCTION check_dimension (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_dim_long_name   VARCHAR2 (200);
   BEGIN
      g_number_lstg_tables := 0;
      g_lstg_fk_number := 0;
      g_number_hier_distinct := 0;
      g_number_ltc_tables := 0;
      g_bottom_records := 0;
      init_all (p_dim_name);

      IF g_results_table_flag
      THEN
         IF delete_cdi_results_table (p_dim_name) = FALSE
         THEN
            RETURN FALSE;
         END IF;
      END IF;

      l_dim_long_name := get_long_for_short_name (p_dim_name);

      IF g_debug
      THEN
         write_to_log_n (
               'long name for '
            || p_dim_name
            || ' got is '
            || l_dim_long_name
         );
      END IF;

      write_to_out_log ('--------------------------------------------------');
      write_to_out_log (   '        '
                        || l_dim_long_name);
      write_to_out_log ('--------------------------------------------------');

      IF get_lstg_ltc_keys (p_dim_name) = FALSE
      THEN
         write_to_log_n (
               'Error in getting lstg, ltc and key info. cannot check this dimension '
            || p_dim_name
            || ' Time '
            || get_time
         );
         RETURN FALSE;
      END IF;

      write_to_log_n (   'get_lstg_ltc_keys done '
                      || get_time);

      IF make_sql_statements = FALSE
      THEN
         write_to_log_n (
               'Error in making sql statements. cannot check this dimension '
            || p_dim_name
            || ' Time '
            || get_time
         );
         RETURN FALSE;
      END IF;

      write_to_log_n (   'make_sql_statements done '
                      || get_time);

      IF g_exec_flag
      THEN
         IF execute_dim_check (p_dim_name) = FALSE
         THEN
            write_to_log_n (
                  'Error in executing dim data check. cannot check this dimension '
               || p_dim_name
               || ' Time '
               || get_time
            );
            RETURN FALSE;
         END IF;

         write_to_log_n (
               'execute_dim_check done for '
            || p_dim_name
            || ' '
            || get_time
         );
      ELSE
         write_to_log_n ('Execute option turned off. No check done');
      END IF;

      write_to_out_log_n (
         '--------------------------------------------------'
      );
      fnd_message.set_name ('BIS', 'EDW_CDI_END_DATA_CHECK');
      write_to_out_log (   fnd_message.get
                        || '       '
                        || l_dim_long_name);
      write_to_out_log ('--------------------------------------------------');
      write_to_out_log ('  ');
      RETURN TRUE;
   EXCEPTION
      WHEN g_stg_tables_not_found
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END check_dimension;

   FUNCTION get_lstg_ltc_keys (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF get_lstg_ltc_pk (p_dim_name) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      IF get_lstg_ltc_fk (p_dim_name) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN g_stg_tables_not_found
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END get_lstg_ltc_keys;

   FUNCTION get_lstg_ltc_pk (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt   VARCHAR2 (30000);
      l_var    VARCHAR2 (400);

      TYPE curtyp IS REF CURSOR;

      cv       curtyp;
   BEGIN
      l_stmt :=
               'SELECT  rel.relation_id, rel.relation_name, rel.relation_long_name, pk.column_name, '
            || 'pk.column_id, lvl.level_table_name, tbl.long_name '
            || 'from '
            || 'edw_levels_md_v lvl, '
            || 'edw_relations_md_v rel, '
            || 'edw_relationmapping_md_v map, '
            || 'edw_unique_key_columns_md_v pk, '
            || 'edw_unique_keys_md_v uk, '
            || 'edw_tables_md_v tbl '
            || 'where lvl.dim_name =:s '
            || 'AND map.targetdataentity = lvl.level_table_id '
            || 'AND rel.relation_id = map.sourcedataentity '
            || 'AND lvl.level_table_name = lvl.level_name || ''_LTC'' '
            || 'AND uk.entity_id = rel.relation_id '
            || 'AND pk.key_id = uk.key_id '
            || 'AND lvl.level_table_id = tbl.elementid ';

      IF g_debug
      THEN
         write_to_log_n (l_stmt);
      END IF;

      g_number_lstg_tables := 1;
      g_number_ltc_tables := 1;
      OPEN cv FOR l_stmt USING p_dim_name;

      LOOP
         FETCH cv INTO g_lstg_tables_id (g_number_lstg_tables),
                       g_lstg_tables (g_number_lstg_tables),
                       g_lstg_table_long_name (g_number_lstg_tables),
                       g_lstg_pk (g_number_lstg_tables),
                       g_lstg_pk_id (g_number_lstg_tables),
                       g_ltc_tables (g_number_ltc_tables),
                       g_ltc_tables_long (g_number_ltc_tables);
         --g_ltc_pk(g_number_ltc_tables);
         EXIT WHEN cv%NOTFOUND;
         g_number_lstg_tables :=   g_number_lstg_tables
                                 + 1;
         g_number_ltc_tables :=   g_number_ltc_tables
                                + 1;
      END LOOP;

      g_number_lstg_tables :=   g_number_lstg_tables
                              - 1;
      g_number_ltc_tables :=   g_number_ltc_tables
                             - 1;
      CLOSE cv;

      IF g_number_lstg_tables = 0
      THEN
         fnd_message.set_name ('BIS', 'EDW_CDI_NO_IT_TABLE_FOUND');
         write_to_out_log_n (fnd_message.get);
         --write_to_out_log_n('No Interface tables found. Aborting Data Check.');
         RAISE g_stg_tables_not_found;
      --      RETURN TRUE;
      END IF;

      --get the instance column
      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         g_lstg_instance_col (i) :=
                 edw_owb_collection_util.get_instance_col (g_lstg_tables (i));
      END LOOP;

      IF g_debug
      THEN
         write_to_log_n ('The instance column of the staging tables');

         FOR i IN 1 .. g_number_lstg_tables
         LOOP
            write_to_log (
                  g_lstg_tables (i)
               || '('
               || g_lstg_instance_col (i)
               || ')'
            );
         END LOOP;
      END IF;

      /*
       we need to check for all level because when we are looking at
       the top but one level fk, we need to make sure its "ALL"...
       there is no interface table for all level
      */
      l_stmt :=
               'SELECT rel.relation_long_name longname '
            || 'FROM edw_levels_md_v lvl, '
            || 'edw_relations_md_v rel '
            || 'WHERE lvl.dim_name = :s '
            || 'AND lvl.level_name = SUBSTR (dim_name, 1, INSTR (dim_name, ''_M'', -1) - 1) || ''_A'' '
            || 'AND rel.relation_name = lvl.level_name || ''_LTC''';
      l_var := NULL;
      g_all_level_exists := FALSE;
      g_all_level := '';
      OPEN cv FOR l_stmt USING p_dim_name;
      FETCH cv INTO l_var;
      CLOSE cv;

      IF l_var IS NOT NULL
      THEN
         g_number_ltc_tables :=   g_number_ltc_tables
                                + 1;
         g_ltc_tables (g_number_ltc_tables) := l_var;
         --g_ltc_pk(g_number_ltc_tables):='ALL_PK';
         g_all_level_exists := TRUE;
         g_all_level := l_var;
      END IF;

      IF g_debug
      THEN
         write_to_log_n ('The lstg table, PK, ltc table');

         FOR i IN 1 .. g_number_lstg_tables
         LOOP
            write_to_log (
                  g_lstg_table_long_name (i)
               || '('
               || g_lstg_tables (i)
               || ')   '
               || g_lstg_pk (i)
               || '('
               || g_lstg_pk_id (i)
               || ')  '
               || g_ltc_tables (i)
            );
         END LOOP;
      END IF;
      --code fix for 4596697
      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         g_lstg_pk_table (i) :=    g_bis_owner
                                || '.'
                                || substr(g_lstg_tables (i),1,28)
                                || 'CP';
         g_lstg_dup_pk_table (i) :=
                                   g_bis_owner
                                || '.'
                                || substr(g_lstg_tables (i),1,28)
                                || 'CD';
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN g_stg_tables_not_found
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END get_lstg_ltc_pk;

   FUNCTION get_lstg_ltc_fk (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt                      VARCHAR2 (30000);
      l_str                       VARCHAR2 (20000);

      TYPE curtyp IS REF CURSOR;

      cv                          curtyp;
      l_ltc_child                 edw_owb_collection_util.varchartabletype;
      l_ltc_parent                edw_owb_collection_util.varchartabletype;
      l_lstg_ltc_parent_pk        edw_owb_collection_util.varchartabletype;
      l_lstg_ltc_parent_pk_long   edw_owb_collection_util.varchartabletype;
      l_found                     BOOLEAN;

/*
l_lstg_child
l_lstg_child_fk
l_lstg_ltc_parent
l_number_lstg
used for getting the lstg, fk and parent ltcs
*/
      l_lstg_child                edw_owb_collection_util.varchartabletype;
      l_lstg_child_fk             edw_owb_collection_util.varchartabletype;
      l_lstg_ltc_parent           edw_owb_collection_util.varchartabletype;
      l_lstg_child_fk_long        edw_owb_collection_util.varchartabletype;
      l_lstg_ltc_parent_long      edw_owb_collection_util.varchartabletype;
      l_number_lstg               NUMBER;
   BEGIN
      /*
       we nede to reuse the lstg-ltc info we found out earlier
       first get all the names of ltcs involved in the relationships
      */
      /*
      we order by child_level.name, parent_level.name so that if there is
      caes like the res dim where there are 2 hiers running through the
      same levels, we need to be able to check both the keys.
      used in get_lstg_fk_for_ltc;
      */
      /*
       the below id reqd for hierarchy information...its important...
      */
      l_stmt :=
               'SELECT hrc.hier_long_name, chil_lvltbl_name, parent_lvltbl_name '
            || 'FROM edw_level_relations_md_v lrl, edw_hierarchies_md_v hrc '
            || 'WHERE lrl.dim_name = :s '
            || 'AND lrl.hier_id = hrc.hier_id '
            || 'ORDER BY chil_lvltbl_name, parent_lvltbl_name';
      g_lstg_fk_number := 1;
      OPEN cv FOR l_stmt USING p_dim_name;

      LOOP
         FETCH cv INTO g_hier (g_lstg_fk_number),
                       l_ltc_child (g_lstg_fk_number),
                       l_ltc_parent (g_lstg_fk_number);
         EXIT WHEN cv%NOTFOUND;
         g_lstg_fk_number :=   g_lstg_fk_number
                             + 1;
      END LOOP;

      g_lstg_fk_number :=   g_lstg_fk_number
                          - 1;
      CLOSE cv;

      IF g_debug
      THEN
         write_to_log_n ('The hierarchies, child ltc and parent ltc ');

         FOR i IN 1 .. g_lstg_fk_number
         LOOP
            write_to_log (
                  g_hier (i)
               || '  '
               || l_ltc_child (i)
               || '  '
               || l_ltc_parent (i)
            );
         END LOOP;
      END IF;

      /*
       find the bottom level
      */
      l_found := FALSE;

      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         l_found := FALSE;

         FOR j IN 1 .. g_lstg_fk_number
         LOOP
            IF l_ltc_child (i) = l_ltc_parent (j)
            THEN
               l_found := TRUE;
               EXIT;
            END IF;
         END LOOP;

         IF l_found = FALSE
         THEN
            g_bottom_level := l_ltc_child (i);
            EXIT;
         END IF;
      END LOOP;

      IF g_debug
      THEN
         write_to_log_n (   'Bottom level is '
                         || g_bottom_level);
      END IF;

      l_str := '';

      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF i = 1
         THEN
            l_str :=    l_str
                     || g_lstg_tables_id (i);
         ELSE
            l_str :=    l_str
                     || ','
                     || g_lstg_tables_id (i);
         END IF;
      END LOOP;

      --get the lstgs, fks and the parent ltcs
      l_stmt :=
               'SELECT lstg.relation_name, fk.fk_column_name, fk_col.business_name, '
            || 'uk.entity_name, rel.relation_name, pk.column_name, pk_col.business_name '
            || 'FROM edw_relations_md_v lstg, '
            || 'edw_foreign_key_columns_md_v fk, '
            || 'edw_unique_keys_md_v uk, '
            || 'edw_unique_key_columns_md_v pk, '
            || 'edw_all_columns_md_v fk_col, '
            || 'edw_all_columns_md_v pk_col, '
            || 'edw_relations_md_v rel '
            || 'WHERE lstg.relation_id IN ('
            || l_str
            || ') '
            || 'AND fk.entity_id = lstg.relation_id '
            || 'AND uk.key_id = fk.pk_id '
            || 'AND pk.key_id = uk.key_id '
            || 'AND fk.entity_id = fk_col.entity_id '
            || 'AND fk.fk_column_id = fk_col.column_id '
            || 'AND pk.column_id = pk_col.column_id '
            || 'AND rel.relation_id = uk.entity_id '
            || 'AND pk_col.entity_id = uk.entity_id';

      IF g_debug
      THEN
         write_to_log_n (l_stmt);
      END IF;

      l_number_lstg := 1;
      OPEN cv FOR l_stmt;

      LOOP
         FETCH cv INTO l_lstg_child (l_number_lstg),
                       l_lstg_child_fk (l_number_lstg),
                       l_lstg_child_fk_long (l_number_lstg),
                       l_lstg_ltc_parent (l_number_lstg),
                       l_lstg_ltc_parent_long (l_number_lstg),
                       l_lstg_ltc_parent_pk (l_number_lstg),
                       l_lstg_ltc_parent_pk_long (l_number_lstg);
         EXIT WHEN cv%NOTFOUND;
         l_number_lstg :=   l_number_lstg
                          + 1;
      END LOOP;

      l_number_lstg :=   l_number_lstg
                       - 1;

      IF g_debug
      THEN
         write_to_log_n ('The lstg table, fk and parent ltc table and pk');

         FOR i IN 1 .. l_number_lstg
         LOOP
            write_to_log (
                  l_lstg_child (i)
               || '   '
               || l_lstg_child_fk (i)
               || '    '
               || l_lstg_ltc_parent (i)
               || '  '
               || l_lstg_ltc_parent_pk (i)
            );
         END LOOP;
      END IF;


/*
g_lstg_fk_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_lstg_fk_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_ltc_fk_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_lstg_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_lstg_fk_position EDW_OWB_COLLECTION_UTIL.numberTableType; --??
*/

      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         g_lstg_fk_table (i) := get_lstg_given_ltc (l_ltc_child (i));
         --if l_ltc_parent(i) is the all level ltc then get_lstg_given_ltc
         -- returns ALL
         g_parent_lstg_fk_table (i) := get_lstg_given_ltc (l_ltc_parent (i));
         g_parent_lstg_fk_table_pk (i) :=
                                 get_pk_for_lstg (g_parent_lstg_fk_table (i));
         g_parent_ltc_fk_table (i) := l_ltc_parent (i);
         g_parent_ltc_fk_table_long (i) :=
               get_parent_ltc_long (
                  g_parent_ltc_fk_table (i),
                  l_lstg_ltc_parent,
                  l_lstg_ltc_parent_long,
                  l_number_lstg
               );
         g_parent_ltc_fk_table_pk (i) :=
               get_pk_for_ltc (
                  g_parent_ltc_fk_table (i),
                  l_lstg_ltc_parent,
                  l_lstg_ltc_parent_pk,
                  l_number_lstg
               );
         g_parent_ltc_fk_table_pk_long (i) :=
               get_ltc_pk_long (
                  g_parent_ltc_fk_table_pk (i),
                  l_lstg_ltc_parent_pk,
                  l_lstg_ltc_parent_pk_long,
                  l_number_lstg
               );

         IF i > 1
         THEN
            /*
            we pass the previous lstg, fk etc so that if there is a repeat,
            get the more later one...like res dimension
            */
            g_lstg_fk (i) := get_lstg_fk_for_ltc (
                                l_lstg_child,
                                l_lstg_child_fk,
                                l_lstg_ltc_parent,
                                l_number_lstg,
                                g_lstg_fk_table (i),
                                g_parent_ltc_fk_table (i),
                                g_lstg_fk_table (  i
                                                 - 1),
                                g_parent_ltc_fk_table (  i
                                                       - 1),
                                g_lstg_fk (  i
                                           - 1)
                             );
         ELSE
            g_lstg_fk (i) := get_lstg_fk_for_ltc (
                                l_lstg_child,
                                l_lstg_child_fk,
                                l_lstg_ltc_parent,
                                l_number_lstg,
                                g_lstg_fk_table (i),
                                g_parent_ltc_fk_table (i),
                                NULL,
                                NULL,
                                NULL
                             );
         END IF;

         g_lstg_fk_long (i) := get_fk_long (
                                  g_lstg_fk (i),
                                  l_lstg_child_fk,
                                  l_lstg_child_fk_long,
                                  l_number_lstg
                               );
         g_lstg_fk_id (i) :=
               edw_owb_collection_util.get_column_id (
                  g_lstg_fk (i),
                  g_lstg_fk_table (i)
               );
      END LOOP;

      g_bottom_level := get_lstg_given_ltc (g_bottom_level);

      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         g_lstg_fk_table_id (i) :=
                  edw_owb_collection_util.get_object_id (g_lstg_fk_table (i));

         IF g_parent_lstg_fk_table (i) IS NOT NULL
         THEN
            g_parent_lstg_fk_table_id (i) :=
                  edw_owb_collection_util.get_object_id (
                     g_parent_lstg_fk_table (i)
                  );
         ELSE
            g_parent_lstg_fk_table_id (i) := NULL;
         END IF;

         IF g_parent_ltc_fk_table (i) IS NOT NULL
         THEN
            g_parent_ltc_fk_table_id (i) :=
                  edw_owb_collection_util.get_object_id (
                     g_parent_ltc_fk_table (i)
                  );
         ELSE
            g_parent_ltc_fk_table_id (i) := NULL;
         END IF;
      END LOOP;

      IF g_debug
      THEN
         write_to_log_n ('The globals...');

         FOR i IN 1 .. g_lstg_fk_number
         LOOP
            write_to_log (
                  g_lstg_fk_table (i)
               || '('
               || g_lstg_fk_table_id (i)
               || ') '
               || g_lstg_fk (i)
               || '('
               || g_lstg_fk_id (i)
               || ') '
               || g_parent_lstg_fk_table (i)
               || '('
               || g_parent_lstg_fk_table_id (i)
               || ') '
               || g_parent_lstg_fk_table_pk (i)
               || '  '
               || g_parent_ltc_fk_table (i)
               || '('
               || g_parent_ltc_fk_table_id (i)
               || ') '
               || g_parent_ltc_fk_table_pk (i)
            );
         END LOOP;
      END IF;

      /*
      get the distinct hier names
      */
      l_str := g_hier (1);
      g_number_hier_distinct := 1;
      g_hier_distinct (1) := g_hier (1);
      l_found := FALSE;

      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         l_found := FALSE;

         FOR j IN 1 .. g_number_hier_distinct
         LOOP
            IF g_hier (i) = g_hier_distinct (j)
            THEN
               l_found := TRUE;
               EXIT;
            END IF;
         END LOOP;

         IF l_found = FALSE
         THEN
            g_number_hier_distinct :=   g_number_hier_distinct
                                      + 1;
            g_hier_distinct (g_number_hier_distinct) := g_hier (i);
         END IF;
      END LOOP;

      IF g_debug
      THEN
         write_to_log_n ('The distinct hierarchies');

         FOR i IN 1 .. g_number_hier_distinct
         LOOP
            write_to_log (g_hier_distinct (i));
         END LOOP;
      END IF;

      --name the tables
      DECLARE
         l_name   VARCHAR2 (400);
      BEGIN
         FOR i IN 1 .. g_lstg_fk_number
         LOOP
            l_name := SUBSTR (
                         g_lstg_fk_table (i),
                         1,
                           LENGTH (g_lstg_fk_table (i))
                         - 4
                      );
            g_lstg_fk_hold_table (i) :=
                                        g_bis_owner
                                     || '.'
                                     || l_name
                                     || 'CF'
                                     || i;
            g_lstg_ok_table (i) :=    g_bis_owner
                                   || '.'
                                   || l_name
                                   || 'CK'
                                   || i;
            g_lstg_dang_table (i) :=    g_bis_owner
                                     || '.'
                                     || l_name
                                     || 'SD'
                                     || i;
            g_lstg_dang_rowid_table (i) :=
                                        g_bis_owner
                                     || '.'
                                     || l_name
                                     || 'SR'
                                     || i;
            g_ltc_ok_table (i) :=    g_bis_owner
                                  || '.'
                                  || l_name
                                  || 'LK'
                                  || i;
            --not used now
            g_ltc_dang_table (i) :=    g_bis_owner
                                    || '.'
                                    || l_name
                                    || 'TD'
                                    || i;
            --not used now
            g_ltc_dang_rowid_table (i) :=
                                        g_bis_owner
                                     || '.'
                                     || l_name
                                     || 'TR'
                                     || i;
            --not used now
            g_main_lstg_fk_table (i) :=
                                        g_bis_owner
                                     || '.'
                                     || l_name
                                     || 'MF'
                                     || i;
         END LOOP;

         IF g_debug
         THEN
            FOR i IN 1 .. g_lstg_fk_number
            LOOP
               write_to_log (
                     'g_main_lstg_fk_table('
                  || i
                  || ')='
                  || g_main_lstg_fk_table (i)
               );
            END LOOP;
         END IF;
      END;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END get_lstg_ltc_fk;

   FUNCTION get_pk_for_lstg (p_lstg IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF g_lstg_tables (i) = p_lstg
         THEN
            RETURN g_lstg_pk (i);
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_pk_for_lstg;

   FUNCTION get_pk_for_ltc (
      p_ltc                  IN   VARCHAR2,
      l_lstg_ltc_parent      IN   edw_owb_collection_util.varchartabletype,
      l_lstg_ltc_parent_pk   IN   edw_owb_collection_util.varchartabletype,
      l_number_lstg          IN   NUMBER
   )
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. l_number_lstg
      LOOP
         IF l_lstg_ltc_parent (i) = p_ltc
         THEN
            RETURN l_lstg_ltc_parent_pk (i);
         END IF;
      END LOOP;

      /*
      for i in 1..g_number_ltc_tables loop
        if g_ltc_tables(i)=p_ltc then
          return g_ltc_pk(i);
        end if;
      end loop;
      */
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_pk_for_ltc;

   FUNCTION get_lstg_given_ltc (p_ltc IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_ltc = g_all_level
      THEN
         RETURN 'ALL';
      END IF;

      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF g_ltc_tables (i) = p_ltc
         THEN
            RETURN g_lstg_tables (i);
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_lstg_given_ltc;

   FUNCTION get_lstg_fk_for_ltc (
      p_lstg_child                 IN   edw_owb_collection_util.varchartabletype,
      p_lstg_child_fk              IN   edw_owb_collection_util.varchartabletype,
      p_lstg_ltc_parent            IN   edw_owb_collection_util.varchartabletype,
      p_lstg_number                IN   NUMBER,
      p_lstg_fk_table              IN   VARCHAR2,
      p_parent_ltc_fk_table        IN   VARCHAR2,
      p_lstg_fk_table_prev         IN   VARCHAR2,
      p_parent_ltc_fk_table_prev   IN   VARCHAR2,
      p_lstg_fk_prev               IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_key   VARCHAR2 (400);
   BEGIN
      /*
       the prev are for dims like resource...
      */
      l_key := NULL;

      FOR i IN 1 .. p_lstg_number
      LOOP
         IF      p_lstg_child (i) = p_lstg_fk_table
             AND p_lstg_ltc_parent (i) = p_parent_ltc_fk_table
         THEN
            l_key := p_lstg_child_fk (i);

            IF    p_lstg_fk_table_prev IS NULL
               OR p_parent_ltc_fk_table_prev IS NULL
               OR p_lstg_fk_prev IS NULL
            THEN
               RETURN p_lstg_child_fk (i);
            ELSIF    p_lstg_child (i) <> p_lstg_fk_table_prev
                  OR p_lstg_ltc_parent (i) <> p_parent_ltc_fk_table_prev
                  OR p_lstg_child_fk (i) <> p_lstg_fk_prev
            THEN
               RETURN p_lstg_child_fk (i);
            END IF;
         END IF;
      END LOOP;

      IF l_key IS NOT NULL
      THEN
         RETURN l_key;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_lstg_fk_for_ltc;

   FUNCTION make_sql_statements
      RETURN BOOLEAN
   IS
   BEGIN
      IF make_hier_count_stmt = FALSE
      THEN
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END make_sql_statements;

   FUNCTION make_hier_count_stmt
      RETURN BOOLEAN
   IS
   BEGIN
      g_hier_stmt_num := 'select nvl(count(1),0) from ';

      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF i = 1
         THEN
            g_hier_stmt_num :=
                         g_hier_stmt_num
                      || ' '
                      || g_lstg_tables (i)
                      || ' A_'
                      || i;
         ELSE
            g_hier_stmt_num :=
                         g_hier_stmt_num
                      || ','
                      || g_lstg_tables (i)
                      || ' A_'
                      || i;
         END IF;
      END LOOP;

      g_hier_stmt_num :=    g_hier_stmt_num
                         || ' where 1=1 ';

      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         g_hier_stmt_num :=
                  g_hier_stmt_num
               || ' And A_'
               || i
               || '.collection_status in (''READY'',''DANGLING'',''DUPLICATE'') ';
      END LOOP;

      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         g_hier_stmt_num :=    g_hier_stmt_num
                            || ' and A_'
                            || i
                            || '.'
                            || g_lstg_pk (i)
                            || ' in (select '
                            || g_lstg_pk (i)
                            || ' from '
                            || g_lstg_tables (i)
                            || ' having
   count('
                            || g_lstg_pk (i)
                            || ') =1 group by '
                            || g_lstg_pk (i)
                            || ' ) ';
      END LOOP;

      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         IF g_parent_lstg_fk_table (i) = 'ALL'
         THEN
            g_hier_stmt_num :=    g_hier_stmt_num
                               || ' and '
                               || get_table_alias (g_lstg_fk_table (i))
                               || '.'
                               || g_lstg_fk (i)
                               || ' = ''ALL'' ';
         ELSE
            g_hier_stmt_num :=    g_hier_stmt_num
                               || ' and '
                               || get_table_alias (g_lstg_fk_table (i))
                               || '.'
                               || g_lstg_fk (i)
                               || ' = '
                               || get_table_alias (
                                     g_parent_lstg_fk_table (i)
                                  )
                               || '.'
                               || g_parent_lstg_fk_table_pk (i)
                               || ' ';
         END IF;
      END LOOP;

      IF g_debug
      THEN
         write_to_log_n ('The total records making in counter');
         write_to_log_n (g_hier_stmt_num);
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END make_hier_count_stmt;

   FUNCTION get_table_alias (p_table IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF p_table = g_lstg_tables (i)
         THEN
            RETURN    'A_'
                   || i;
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_table_alias;

   FUNCTION execute_dim_check (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF execute_dim_all_records (p_dim_name) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      IF g_check_dimension
      THEN
         IF g_duplicate_check = TRUE
         THEN
            IF execute_dim_duplicate_check (p_dim_name) = FALSE
            THEN
               RETURN FALSE;
            ELSE
               write_to_log_n (
                     'execute_dim_duplicate_check done...'
                  || get_time
               );
            END IF;
         END IF;

         IF execute_dim_dangling_check (p_dim_name) = FALSE
         THEN
            RETURN FALSE;
         END IF;

         IF g_check_hier
         THEN
            --if execute_hier_count(p_dim_name)= false  then
              --return false;
            --end if;
            NULL;
         END IF;

         IF drop_lstg_fk_tables = FALSE
         THEN
            NULL;
         END IF;

         IF drop_lstg_pk_tables = FALSE
         THEN
            NULL;
         END IF;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status_message := SQLERRM;
         write_to_out_log_n (SQLERRM);
         RETURN FALSE;
   END execute_dim_check;

   FUNCTION execute_dim_all_records (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt    VARCHAR2 (3000);

      TYPE curtyp IS REF CURSOR;

      l_owner   VARCHAR2 (400);
   BEGIN
      write_to_out ('  ');
      fnd_message.set_name ('BIS', 'EDW_CDI_TOTAL_RECORDS');
      write_to_out (fnd_message.get);
      --write_to_out('Total number of records in the interface tables with status of ');
      --write_to_out('''READY'',''DANGLING'' or ''DUPLICATE''');
      write_to_out ('  ');
      l_owner := edw_owb_collection_util.get_table_owner (p_dim_name);

      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         --EDW_OWB_COLLECTION_UTIL.analyze_table_stats(g_lstg_tables(i), l_owner);
         g_lstg_total_records (i) := 0;
         l_stmt :=    'create table '
                   || g_lstg_pk_table (i)
                   || ' tablespace '
                   || g_op_table_space;

         IF g_parallel IS NULL
         THEN
            l_stmt :=
                     l_stmt
                  || ' as select '
                  || g_lstg_pk (i)
                  || ',rowid row_id from '
                  || g_lstg_tables (i)
                  || ' where collection_status in (''READY'',''DANGLING'',''DUPLICATE'') ';
         ELSE
            l_stmt :=    l_stmt
                      || ' parallel (degree '
                      || g_parallel
                      || ') ';
            l_stmt :=    l_stmt
                      || ' as select /*+PARALLEL('
                      || g_lstg_tables (i)
                      || ','
                      || g_parallel
                      || ')*/ '
                      || g_lstg_pk (i)
                      || ','
                      || ' rowid row_id from '
                      || g_lstg_tables (i)
                      || ' where collection_status in '
                      || '(''READY'',''DANGLING'',''DUPLICATE'') ';
         END IF;

         IF edw_owb_collection_util.drop_table (g_lstg_pk_table (i)) = FALSE
         THEN
            NULL;
         END IF;

         IF g_debug
         THEN
            write_to_log_n (   'going to execute '
                            || l_stmt
                            || get_time);
         END IF;

         EXECUTE IMMEDIATE l_stmt;
         g_lstg_total_records (i) := SQL%ROWCOUNT;

         IF g_lstg_total_records (i) > 0
         THEN
            g_check_dimension := TRUE;
         END IF;

         IF g_debug
         THEN
            write_to_log_n (
                  'Created '
               || g_lstg_pk_table (i)
               || ' with '
               || g_lstg_total_records (i)
               || ' rows'
               || get_time
            );
         END IF;

         fnd_message.set_name ('BIS', 'EDW_CDI_TABLE_AND_RECORDS');
         fnd_message.set_token ('TABLE', g_lstg_table_long_name (i));
         fnd_message.set_token ('RECORDS', g_lstg_total_records (i));
         write_to_out (fnd_message.get);
         --write_to_out('Table '||g_lstg_table_long_name(i)||' has '||g_lstg_total_records(i)||' records');
         edw_owb_collection_util.analyze_table_stats (
            SUBSTR (
               g_lstg_pk_table (i),
                 INSTR (g_lstg_pk_table (i), '.')
               + 1,
               LENGTH (g_lstg_pk_table (i))
            ),
            SUBSTR (
               g_lstg_pk_table (i),
               1,
                 INSTR (g_lstg_pk_table (i), '.')
               - 1
            )
         );
      END LOOP;

      g_bottom_records := get_num_recs_lstg (g_bottom_level);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_dim_all_records;

   FUNCTION execute_dim_duplicate_check (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt             VARCHAR2 (30000);

      TYPE curtyp IS REF CURSOR;

      cv                 curtyp;
      l_num_dup          NUMBER;
      l_num_dup_log      NUMBER;
      l_dup_str          edw_owb_collection_util.varchartabletype;
      l_dup_count        edw_owb_collection_util.numbertabletype;
      l_number_dup_str   NUMBER;
   BEGIN
      write_to_out (' ');
      fnd_message.set_name ('BIS', 'EDW_CDI_DUPLICATE_DATA_CHECK');
      write_to_out (fnd_message.get);

      --write_to_out('Duplicate Data Check ');
      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF g_lstg_total_records (i) = 0
         THEN
            fnd_message.set_name ('BIS', 'EDW_CDI_NO_READY_RECORDS');
            fnd_message.set_token ('TABLE', g_lstg_table_long_name (i));
            write_to_out (fnd_message.get);
            --write_to_out('Table '||g_lstg_table_long_name(i)||' has no records with status of ');
            --write_to_out('''READY'',''DANGLING'' or ''DUPLICATE''.');
            fnd_message.set_name ('BIS', 'EDW_CDI_NO_DUP_DATA_CHECK');
            write_to_out (fnd_message.get);
            --write_to_out('No duplicate check done');
            RETURN TRUE;
         END IF;

         l_stmt :=    'create table '
                   || g_lstg_dup_pk_table (i)
                   || ' tablespace '
                   || g_op_table_space;

         IF g_parallel IS NOT NULL
         THEN
            l_stmt :=    l_stmt
                      || ' parallel (degree '
                      || g_parallel
                      || ') ';
         END IF;

         l_stmt :=    l_stmt
                   || ' as select '
                   || g_lstg_pk (i)
                   || ' PK ,count(1) dup_count from '
                   || g_lstg_pk_table (i)
                   || ' having count('
                   || g_lstg_pk (i)
                   || ')>1 group by '
                   || g_lstg_pk (i);

         IF edw_owb_collection_util.drop_table (g_lstg_dup_pk_table (i)) =
                                                                         FALSE
         THEN
            NULL;
         END IF;

         IF g_debug
         THEN
            write_to_log_n (   'going to execute '
                            || l_stmt
                            || get_time);
         END IF;

         EXECUTE IMMEDIATE l_stmt;

         IF g_debug
         THEN
            write_to_log_n (
                  'Created '
               || g_lstg_dup_pk_table (i)
               || ' with '
               || SQL%ROWCOUNT
               || ' rows'
               || get_time
            );
         END IF;

         edw_owb_collection_util.analyze_table_stats (
            SUBSTR (
               g_lstg_dup_pk_table (i),
                 INSTR (g_lstg_dup_pk_table (i), '.')
               + 1,
               LENGTH (g_lstg_dup_pk_table (i))
            ),
            SUBSTR (
               g_lstg_dup_pk_table (i),
               1,
                 INSTR (g_lstg_dup_pk_table (i), '.')
               - 1
            )
         );
         l_stmt :=    'select sum(dup_count) from '
                   || g_lstg_dup_pk_table (i);
         l_num_dup := NULL;

         IF g_debug
         THEN
            write_to_log_n (   'going to execute '
                            || l_stmt
                            || get_time);
         END IF;

         OPEN cv FOR l_stmt;
         FETCH cv INTO l_num_dup;
         CLOSE cv;
         fnd_message.set_name ('BIS', 'EDW_CDI_RECORDS_DUPLICATE');
         fnd_message.set_token ('TABLE', g_lstg_table_long_name (i));
         fnd_message.set_token ('DUPLICATE', NVL (l_num_dup, 0));
         fnd_message.set_token ('TOTAL', g_lstg_total_records (i));
         write_to_out (fnd_message.get);

         --if l_num_dup is null then
           --write_to_out('Table '||g_lstg_table_long_name(i)||' 0 records are duplicate ');
         --else
           --write_to_out('Table '||g_lstg_table_long_name(i)||' '||l_num_dup||' records out of '||
           --g_lstg_total_records(i)||' are duplicate ');
         --end if;
         IF g_results_table_flag
         THEN
            IF l_num_dup IS NULL
            THEN
               l_num_dup_log := 0;
            ELSE
               l_num_dup_log := l_num_dup;
            END IF;

            IF log_into_cdi_results_table (
                  g_object_name,
                  g_object_type,
                  g_object_id,
                  g_lstg_tables (i),
                  g_lstg_tables_id (i),
                  g_lstg_pk (i),
                  g_lstg_pk_id (i),
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  l_num_dup_log,
                  NULL,
                  g_lstg_total_records (i),
                  'DUPLICATE'
               ) = FALSE
            THEN
               RETURN FALSE;
            END IF;
         END IF;

         IF  l_num_dup > 0 AND g_sample_on
         THEN
            l_number_dup_str := 1;
            l_stmt :=    'select PK,dup_count from '
                      || g_lstg_dup_pk_table (i);

            IF g_debug
            THEN
               write_to_log_n (   'going to execute '
                               || l_stmt
                               || get_time);
            END IF;

            write_to_out ('  ');
            fnd_message.set_name ('BIS', 'EDW_CDI_SAMPLE_DUPLICATE');
            write_to_out (fnd_message.get);
            --write_to_out('Sample duplicate records and their count');
            OPEN cv FOR l_stmt;

            LOOP
               FETCH cv INTO l_dup_str (1), l_dup_count (1);
               EXIT WHEN cv%NOTFOUND;

               IF      g_number_max_sample IS NOT NULL
                   AND l_number_dup_str > g_number_max_sample
               THEN
                  EXIT;
               END IF;

               IF log_into_cdi_dang_table (
                     g_lstg_pk_id (i),
                     g_lstg_tables_id (i),
                     NULL,
                     l_dup_str (1),
                     l_dup_count (1),
                     NULL
                  ) = FALSE
               THEN
                  RETURN FALSE;
               END IF;

               IF l_number_dup_str <= g_number_sample
               THEN
                  write_to_out (   l_dup_str (1)
                                || ' ('
                                || l_dup_count (1)
                                || ')');
               END IF;

               l_number_dup_str :=   l_number_dup_str
                                   + 1;
            END LOOP;

            CLOSE cv;
            l_number_dup_str :=   l_number_dup_str
                                - 1;
            write_to_out (' ');
         END IF;

         IF edw_owb_collection_util.drop_table (g_lstg_dup_pk_table (i)) =
                                                                         FALSE
         THEN
            NULL;
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_dim_duplicate_check;

   FUNCTION execute_dim_dangling_check (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF create_main_lstg_fk_tables = FALSE
      THEN
         RETURN FALSE;
      END IF;

      IF create_lstg_fk_tables = FALSE
      THEN
         RETURN FALSE;
      END IF;

      IF execute_dim_dang_check_lstg (p_dim_name) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      IF g_check_against_ltc = TRUE
      THEN
         IF execute_dim_dang_check_ltc (p_dim_name) = FALSE
         THEN
            RETURN FALSE;
         END IF;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_dim_dangling_check;

   FUNCTION create_main_lstg_fk_tables
      RETURN BOOLEAN
   IS
      l_lstg_index                NUMBER;
      l_stmt                      VARCHAR2 (20000);
      l_fk                        edw_owb_collection_util.varchartabletype;
      l_number_fk                 NUMBER;
      l_table_considered          edw_owb_collection_util.varchartabletype;
      l_number_table_considered   NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (   'In create_main_lstg_fk_tables '
                         || get_time);
      END IF;

      g_number_main_lstg_fk_table := 0;
      l_number_table_considered := 0;

      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         --g_main_lstg_fk_table
         --g_number_main_lstg_fk_table
         l_number_fk := 0;

         IF edw_owb_collection_util.value_in_table (
               l_table_considered,
               l_number_table_considered,
               g_lstg_fk_table (i)
            ) = FALSE
         THEN
            l_number_table_considered :=   l_number_table_considered
                                         + 1;
            l_table_considered (l_number_table_considered) :=
                                                          g_lstg_fk_table (i);
            l_lstg_index :=
                  edw_owb_collection_util.index_in_table (
                     g_lstg_tables,
                     g_number_lstg_tables,
                     g_lstg_fk_table (i)
                  );

            IF g_debug
            THEN
               write_to_log (   'l_lstg_index='
                             || l_lstg_index);
            END IF;

            FOR j IN 1 .. g_lstg_fk_number
            LOOP
               IF g_lstg_fk_table (j) = g_lstg_fk_table (i)
               THEN
                  IF edw_owb_collection_util.value_in_table (
                        l_fk,
                        l_number_fk,
                        g_lstg_fk (j)
                     ) = FALSE
                  THEN
                     l_number_fk :=   l_number_fk
                                    + 1;
                     l_fk (l_number_fk) := g_lstg_fk (j);
                  END IF;
               END IF;
            END LOOP;

            g_number_main_lstg_fk_table :=   g_number_main_lstg_fk_table
                                           + 1;
            g_main_lstg_fk_table (g_number_main_lstg_fk_table) :=
                     g_bis_owner
                  || '.'
                  || SUBSTR (
                        g_lstg_fk_table (i),
                        1,
                          LENGTH (g_lstg_fk_table (i))
                        - 4
                     )
                  || 'MF'
                  || i;
            g_main_lstg_fk_table_lstg (g_number_main_lstg_fk_table) :=
                                                           g_lstg_fk_table (i);
            l_stmt :=    'create table '
                      || g_main_lstg_fk_table (g_number_main_lstg_fk_table)
                      || ' tablespace '
                      || g_op_table_space;

            IF g_parallel IS NOT NULL
            THEN
               l_stmt :=    l_stmt
                         || ' parallel (degree '
                         || g_parallel
                         || ') ';
               l_stmt :=    l_stmt
                         || ' as select /*+ORDERED*/ /*+PARALLEL('
                         || g_lstg_fk_table (i)
                         || ','
                         || g_parallel
                         || ')*/ ';
            ELSE
               l_stmt :=    l_stmt
                         || ' as select /*+ORDERED*/ ';
            END IF;

            FOR j IN 1 .. l_number_fk
            LOOP
               l_stmt :=    l_stmt
                         || g_lstg_fk_table (i)
                         || '.'
                         || l_fk (j)
                         || ',';
            END LOOP;

            IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
            THEN
               l_stmt :=    l_stmt
                         || g_lstg_fk_table (i)
                         || '.'
                         || g_lstg_instance_col (l_lstg_index)
                         || ',';
            END IF;

            l_stmt :=    l_stmt
                      || g_lstg_fk_table (i)
                      || '.rowid row_id from '
                      || g_lstg_pk_table (l_lstg_index)
                      || ','
                      || g_lstg_fk_table (i)
                      || ' where '
                      || g_lstg_fk_table (i)
                      || '.rowid='
                      || g_lstg_pk_table (l_lstg_index)
                      || '.row_id';

            IF edw_owb_collection_util.drop_table (
                  g_main_lstg_fk_table (g_number_main_lstg_fk_table)
               ) = FALSE
            THEN
               NULL;
            END IF;

            IF g_debug
            THEN
               write_to_log_n (   'going to execute '
                               || l_stmt
                               || get_time);
            END IF;

            EXECUTE IMMEDIATE l_stmt;

            IF g_debug
            THEN
               write_to_log_n (
                     'Created '
                  || g_main_lstg_fk_table (g_number_main_lstg_fk_table)
                  || ' with '
                  || SQL%ROWCOUNT
                  || ' rows'
                  || get_time
               );
            END IF;

            /*
            l_stmt:='create unique index '||g_main_lstg_fk_table(g_number_main_lstg_fk_table)||'u on '||
            g_main_lstg_fk_table(g_number_main_lstg_fk_table)||'(row_id)';
            if g_debug then
              write_to_log_n('going to execute '||l_stmt||get_time);
            end if;
            execute immediate l_stmt;
            if g_debug then
              write_to_log_n('Created unique index on '||g_main_lstg_fk_table(g_number_main_lstg_fk_table)||get_time);
            end if;*/

            edw_owb_collection_util.analyze_table_stats (
               SUBSTR (
                  g_main_lstg_fk_table (g_number_main_lstg_fk_table),
                    INSTR (
                       g_main_lstg_fk_table (g_number_main_lstg_fk_table),
                       '.'
                    )
                  + 1,
                  LENGTH (g_main_lstg_fk_table (g_number_main_lstg_fk_table))
               ),
               SUBSTR (
                  g_main_lstg_fk_table (g_number_main_lstg_fk_table),
                  1,
                    INSTR (
                       g_main_lstg_fk_table (g_number_main_lstg_fk_table),
                       '.'
                    )
                  - 1
               )
            );
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END create_main_lstg_fk_tables;

   FUNCTION create_lstg_fk_tables
      RETURN BOOLEAN
   IS
      l_lstg_index   NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (   'In create_lstg_fk_tables '
                         || get_time);
      END IF;

      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         l_lstg_index :=
               edw_owb_collection_util.index_in_table (
                  g_main_lstg_fk_table_lstg,
                  g_number_main_lstg_fk_table,
                  g_lstg_fk_table (i)
               );
         g_lstg_fk_hold_table (i) := g_main_lstg_fk_table (l_lstg_index);

         IF g_debug
         THEN
            write_to_log (
                  g_lstg_fk_table (i)
               || '   '
               || g_lstg_fk_hold_table (i)
            );
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END create_lstg_fk_tables;

   FUNCTION drop_lstg_fk_tables
      RETURN BOOLEAN
   IS
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (   'In drop_lstg_fk_tables '
                         || get_time);
      END IF;

      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         IF edw_owb_collection_util.drop_table (g_lstg_fk_hold_table (i)) =
                                                                        FALSE
         THEN
            NULL;
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END drop_lstg_fk_tables;

   FUNCTION drop_lstg_pk_tables
      RETURN BOOLEAN
   IS
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (   'In drop_lstg_pk_tables '
                         || get_time);
      END IF;

      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF edw_owb_collection_util.drop_table (g_lstg_pk_table (i)) = FALSE
         THEN
            NULL;
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END drop_lstg_pk_tables;

   FUNCTION execute_dim_dang_check_lstg (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt                 VARCHAR2 (30000);

      TYPE curtyp IS REF CURSOR;

      cv                     curtyp;
      l_num_dang             NUMBER;
      l_number_dang_str      NUMBER;
      l_total_recs           NUMBER;
      l_dang_str             edw_owb_collection_util.varchartabletype;
      l_dang_count           edw_owb_collection_util.numbertabletype;
      l_dang_instance        edw_owb_collection_util.varchartabletype;
      l_lstg_fk_table_long   edw_owb_collection_util.varchartabletype;
      l_lstg_index           NUMBER;
      l_lstg_parent_index    NUMBER;
      l_fk_ok_number         NUMBER;
   BEGIN
      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         l_lstg_fk_table_long (i) := get_lstg_long_name (g_lstg_fk_table (i));
      END LOOP;

      IF g_debug
      THEN
         write_to_log_n ('The long names for the interface tables');

         FOR i IN 1 .. g_lstg_fk_number
         LOOP
            write_to_log (
                  l_lstg_fk_table_long (i)
               || '('
               || g_lstg_fk_table (i)
               || ')'
            );
         END LOOP;
      END IF;

      write_to_out (' ');
      fnd_message.set_name ('BIS', 'EDW_CDI_DANGLING_CHECK_IT');
      write_to_out (fnd_message.get);
      --write_to_out('Dangling Records Check against parent LSTG Tables');
      write_to_out (' ');

      FOR i IN 1 .. g_number_hier_distinct
      LOOP
         write_to_out (' ');
         write_to_out (' ');
         fnd_message.set_name ('BIS', 'EDW_CDI_HIERARCHY');
         fnd_message.set_token ('HIER', g_hier_distinct (i));
         write_to_out (fnd_message.get);

         --write_to_out('Hierarchy '||g_hier_distinct(i));
         FOR j IN 1 .. g_lstg_fk_number
         LOOP
            IF g_hier (j) = g_hier_distinct (i)
            THEN
               l_total_recs := get_num_recs_lstg (g_lstg_fk_table (j));

               IF g_debug
               THEN
                  write_to_log (
                        'Table '
                     || g_lstg_fk_table (j)
                     || ' '
                     || l_total_recs
                     || ' total recs returned'
                  );
               END IF;

               IF l_total_recs > 0
               THEN
                  l_lstg_index :=
                        edw_owb_collection_util.index_in_table (
                           g_lstg_tables,
                           g_number_lstg_tables,
                           g_lstg_fk_table (j)
                        );
                  --join with the parent lstg pk table and create the ok table
                  l_lstg_parent_index :=
                        edw_owb_collection_util.index_in_table (
                           g_lstg_tables,
                           g_number_lstg_tables,
                           g_parent_lstg_fk_table (j)
                        );

                  IF      g_parent_lstg_fk_table (j) <> 'ALL'
                      AND l_lstg_parent_index IS NULL
                  THEN
                     write_to_log_n (
                           'Parent lstg table not found for '
                        || g_lstg_fk_table (j)
                     );
                     RETURN FALSE;
                  END IF;

                  IF g_parent_lstg_fk_table (j) <> 'ALL'
                  THEN
                     l_stmt :=    'create table '
                               || g_lstg_ok_table (j)
                               || ' tablespace '
                               || g_op_table_space;

                     IF g_parallel IS NOT NULL
                     THEN
                        l_stmt :=    l_stmt
                                  || ' parallel (degree '
                                  || g_parallel
                                  || ') ';
                     END IF;

                     l_stmt :=    l_stmt
                               || ' as select /*+ORDERED*/ '
                               || g_lstg_fk_hold_table (j)
                               || '.row_id ';
                     l_stmt :=    l_stmt
                               || ' from '
                               || g_lstg_fk_hold_table (j)
                               || ','
                               || g_lstg_pk_table (l_lstg_parent_index)
                               || ' where '
                               || g_lstg_fk_hold_table (j)
                               || '.'
                               || g_lstg_fk (j)
                               || '='
                               || g_lstg_pk_table (l_lstg_parent_index)
                               || '.'
                               || g_lstg_pk (l_lstg_parent_index)
                               || ' union select '
                               || g_lstg_fk_hold_table (j)
                               || '.row_id ';
                     l_stmt :=    l_stmt
                               || ' from '
                               || g_lstg_fk_hold_table (j)
                               || ' where '
                               || g_lstg_fk_hold_table (j)
                               || '.'
                               || g_lstg_fk (j)
                               || '=''NA_EDW''';

                     IF edw_owb_collection_util.drop_table (
                           g_lstg_ok_table (j)
                        ) = FALSE
                     THEN
                        NULL;
                     END IF;

                     IF g_debug
                     THEN
                        write_to_log_n (
                              'going to execute '
                           || l_stmt
                           || get_time
                        );
                     END IF;

                     EXECUTE IMMEDIATE l_stmt;
                     l_fk_ok_number := SQL%ROWCOUNT;

                     IF g_debug
                     THEN
                        write_to_log_n (
                              'Created '
                           || g_lstg_ok_table (j)
                           || ' with '
                           || l_fk_ok_number
                           || ' rows'
                           || get_time
                        );
                     END IF;

                     edw_owb_collection_util.analyze_table_stats (
                        SUBSTR (
                           g_lstg_ok_table (j),
                             INSTR (g_lstg_ok_table (j), '.')
                           + 1,
                           LENGTH (g_lstg_ok_table (j))
                        ),
                        SUBSTR (
                           g_lstg_ok_table (j),
                           1,
                             INSTR (g_lstg_ok_table (j), '.')
                           - 1
                        )
                     );
                     l_num_dang :=   l_total_recs
                                   - l_fk_ok_number;
                  ELSE
                     l_stmt :=    'select count(1) from '
                               || g_lstg_fk_hold_table (j)
                               || ' where '
                               || g_lstg_fk (j)
                               || '=''ALL''';

                     IF g_debug
                     THEN
                        write_to_log_n (
                              'going to execute '
                           || l_stmt
                           || get_time
                        );
                     END IF;

                     OPEN cv FOR l_stmt;
                     FETCH cv INTO l_fk_ok_number;
                     CLOSE cv;
                     l_num_dang :=   l_total_recs
                                   - l_fk_ok_number;

                     IF g_debug
                     THEN
                        write_to_log_n (get_time);
                     END IF;
                  END IF;

                  IF l_num_dang <= 0
                  THEN
                     IF g_parent_lstg_fk_table (j) = 'ALL'
                     THEN
                        write_to_out (' ');
                        fnd_message.set_name ('BIS', 'EDW_CDI_TABLE_AND_FK');
                        fnd_message.set_token (
                           'TABLE',
                           l_lstg_fk_table_long (j)
                        );
                        fnd_message.set_token ('FK', g_lstg_fk_long (j));
                        write_to_out (fnd_message.get);

                        --write_to_out('Table '||l_lstg_fk_table_long(j)||', Foreign Key '||g_lstg_fk_long(j));
                        IF g_results_table_flag
                        THEN
                           IF log_into_cdi_results_table (
                                 g_object_name,
                                 g_object_type,
                                 g_object_id,
                                 g_lstg_fk_table (j),
                                 g_lstg_fk_table_id (j),
                                 NULL,
                                 NULL,
                                 g_lstg_fk (j), --p_interface_table_fk
                                 g_lstg_fk_id (j),
                                 NULL, --p_parent_table
                                 NULL, --p_parent_table_id
                                 NULL, --p_parent_table_pk
                                 NULL,
                                 l_num_dang, --p_number_dangling
                                 NULL,
                                 NULL,
                                 l_total_recs,
                                 'DANGLING'
                              ) = FALSE
                           THEN
                              RETURN FALSE;
                           END IF;
                        END IF;
                     ELSE
                        write_to_out (' ');
                        fnd_message.set_name ('BIS', 'EDW_CDI_TABLE_AND_FK');
                        fnd_message.set_token (
                           'TABLE',
                           l_lstg_fk_table_long (j)
                        );
                        fnd_message.set_token ('FK', g_lstg_fk_long (j));
                        write_to_out (fnd_message.get);
                        --write_to_out('Table '||l_lstg_fk_table_long(j)||', Foreign Key '||g_lstg_fk_long(j));
                        fnd_message.set_name (
                           'BIS',
                           'EDW_CDI_PARENT_TABLE_AND_PK'
                        );
                        fnd_message.set_token (
                           'TABLE',
                           get_lstg_long_name (g_parent_lstg_fk_table (j))
                        );
                        fnd_message.set_token (
                           'PK',
                           get_lstg_pk (g_parent_lstg_fk_table (j))
                        );
                        write_to_out (fnd_message.get);

                        --write_to_out('Parent Table '||get_lstg_long_name(g_parent_lstg_fk_table(j))||
                        --', Primary Key '||get_lstg_pk(g_parent_lstg_fk_table(j)));
                        IF g_results_table_flag
                        THEN
                           IF log_into_cdi_results_table (
                                 g_object_name,
                                 g_object_type,
                                 g_object_id,
                                 g_lstg_fk_table (j),
                                 g_lstg_fk_table_id (j),
                                 NULL,
                                 NULL,
                                 g_lstg_fk (j), --p_interface_table_fk
                                 g_lstg_fk_id (j),
                                 g_parent_lstg_fk_table (j), --p_parent_table
                                 g_parent_lstg_fk_table_id (j),
                                 --p_parent_table_id
                                 g_lstg_pk (l_lstg_parent_index),
                                 --p_parent_table_pk
                                 NULL,
                                 l_num_dang, --p_number_dangling
                                 NULL,
                                 NULL,
                                 l_total_recs,
                                 'DANGLING'
                              ) = FALSE
                           THEN
                              RETURN FALSE;
                           END IF;
                        END IF;
                     END IF;

                     fnd_message.set_name ('BIS', 'EDW_CDI_NO_RECS_DANGLING');
                     write_to_out (fnd_message.get);
                  --write_to_out(' 0 records are dangling');
                  ELSE
                     IF g_parent_lstg_fk_table (j) = 'ALL'
                     THEN
                        write_to_out (' ');
                        fnd_message.set_name ('BIS', 'EDW_CDI_TABLE_AND_FK');
                        fnd_message.set_token (
                           'TABLE',
                           l_lstg_fk_table_long (j)
                        );
                        fnd_message.set_token ('FK', g_lstg_fk_long (j));
                        write_to_out (fnd_message.get);

                        --write_to_out('Table '||l_lstg_fk_table_long(j)||', Foreign Key '||g_lstg_fk_long(j));
                        IF g_results_table_flag
                        THEN
                           IF log_into_cdi_results_table (
                                 g_object_name,
                                 g_object_type,
                                 g_object_id,
                                 g_lstg_fk_table (j),
                                 g_lstg_fk_table_id (j),
                                 NULL,
                                 NULL,
                                 g_lstg_fk (j), --p_interface_table_fk
                                 g_lstg_fk_id (j),
                                 NULL, --p_parent_table
                                 NULL, --p_parent_table_id
                                 NULL, --p_parent_table_pk
                                 NULL, --p_parent_table_pk_id
                                 l_num_dang, --p_number_dangling
                                 NULL,
                                 NULL,
                                 l_total_recs,
                                 'DANGLING'
                              ) = FALSE
                           THEN
                              RETURN FALSE;
                           END IF;
                        END IF;
                     ELSE
                        write_to_out (' ');
                        fnd_message.set_name ('BIS', 'EDW_CDI_TABLE_AND_FK');
                        fnd_message.set_token (
                           'TABLE',
                           l_lstg_fk_table_long (j)
                        );
                        fnd_message.set_token ('FK', g_lstg_fk_long (j));
                        write_to_out (fnd_message.get);
                        --write_to_out('Table '||l_lstg_fk_table_long(j)||', Foreign Key '||g_lstg_fk_long(j));
                        fnd_message.set_name ('BIS', 'EDW_CDI_NO_LONG_DIM');
                        fnd_message.set_token (
                           'TABLE',
                           get_lstg_long_name (g_parent_lstg_fk_table (j))
                        );
                        fnd_message.set_token (
                           'PK',
                           get_lstg_pk (g_parent_lstg_fk_table (j))
                        );
                        write_to_out (fnd_message.get);

                        --write_to_out('Parent Table '||get_lstg_long_name(g_parent_lstg_fk_table(j))
                         --||', Primary Key '||get_lstg_pk(g_parent_lstg_fk_table(j)));
                        IF g_results_table_flag
                        THEN
                           IF log_into_cdi_results_table (
                                 g_object_name,
                                 g_object_type,
                                 g_object_id,
                                 g_lstg_fk_table (j),
                                 g_lstg_fk_table_id (j),
                                 NULL,
                                 NULL,
                                 g_lstg_fk (j), --p_interface_table_fk
                                 g_lstg_fk_id (j),
                                 g_parent_lstg_fk_table (j), --p_parent_table
                                 g_parent_lstg_fk_table_id (j),
                                 --p_parent_table_id
                                 g_lstg_pk (l_lstg_parent_index),
                                 --p_parent_table_pk
                                 NULL,
                                 l_num_dang, --p_number_dangling
                                 NULL,
                                 NULL,
                                 l_total_recs,
                                 'DANGLING'
                              ) = FALSE
                           THEN
                              RETURN FALSE;
                           END IF;
                        END IF;
                     END IF;

                     fnd_message.set_name ('BIS', 'EDW_CDI_RECS_DANGLING');
                     fnd_message.set_token ('DANGLING', l_num_dang);
                     fnd_message.set_token ('TOTAL', l_total_recs);
                     write_to_out (fnd_message.get);
                  --write_to_out(l_num_dang||' records out of '||l_total_recs||' are dangling');
                  END IF;

                  IF  l_num_dang > 0 AND g_sample_on
                  THEN
                     --make the dang table with MINUS
                     IF g_parent_lstg_fk_table (j) <> 'ALL'
                     THEN
                        l_stmt :=    'create table '
                                  || g_lstg_dang_rowid_table (j)
                                  || ' tablespace '
                                  || g_op_table_space;

                        IF g_parallel IS NOT NULL
                        THEN
                           l_stmt :=    l_stmt
                                     || ' parallel (degree '
                                     || g_parallel
                                     || ') ';
                        END IF;

                        l_stmt :=    l_stmt
                                  || ' as select row_id from '
                                  || g_lstg_fk_hold_table (j)
                                  || ' MINUS select row_id from '
                                  || g_lstg_ok_table (j);

                        IF edw_owb_collection_util.drop_table (
                              g_lstg_dang_rowid_table (j)
                           ) = FALSE
                        THEN
                           NULL;
                        END IF;

                        IF g_debug
                        THEN
                           write_to_log_n (
                                 'going to execute '
                              || l_stmt
                              || get_time
                           );
                        END IF;

                        EXECUTE IMMEDIATE l_stmt;

                        IF g_debug
                        THEN
                           write_to_log_n (
                                 'Created '
                              || g_lstg_dang_rowid_table (j)
                              || ' with '
                              || SQL%ROWCOUNT
                              || ' rows'
                              || get_time
                           );
                        END IF;

                        edw_owb_collection_util.analyze_table_stats (
                           SUBSTR (
                              g_lstg_dang_rowid_table (j),
                                INSTR (g_lstg_dang_rowid_table (j), '.')
                              + 1,
                              LENGTH (g_lstg_dang_rowid_table (j))
                           ),
                           SUBSTR (
                              g_lstg_dang_rowid_table (j),
                              1,
                                INSTR (g_lstg_dang_rowid_table (j), '.')
                              - 1
                           )
                        );
                        --create the dang table
                        l_stmt :=    'select /*+ORDERED*/ '
                                  || g_lstg_fk_hold_table (j)
                                  || '.'
                                  || g_lstg_fk (j);

                        IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
                        THEN
                           l_stmt :=    l_stmt
                                     || ','
                                     || g_lstg_fk_hold_table (j)
                                     || '.'
                                     || g_lstg_instance_col (l_lstg_index);
                        END IF;

                        l_stmt :=    l_stmt
                                  || ',count(1)  from '
                                  || g_lstg_dang_rowid_table (j)
                                  || ','
                                  || g_lstg_fk_hold_table (j)
                                  || ' where '
                                  || g_lstg_fk_hold_table (j)
                                  || '.row_id='
                                  || g_lstg_dang_rowid_table (j)
                                  || '.row_id group by '
                                  || g_lstg_fk_hold_table (j)
                                  || '.'
                                  || g_lstg_fk (j);

                        IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
                        THEN
                           l_stmt :=    l_stmt
                                     || ','
                                     || g_lstg_fk_hold_table (j)
                                     || '.'
                                     || g_lstg_instance_col (l_lstg_index);
                        END IF;

                        l_stmt :=    l_stmt
                                  || ' order by count(1) desc';
                        write_to_out ('  ');
                        fnd_message.set_name ('BIS', 'EDW_CDI_SAMPLE_DANGLING');
                        write_to_out (fnd_message.get);
                        --write_to_out('Sample dangling records and their count ');
                        l_number_dang_str := 1;

                        IF g_debug
                        THEN
                           write_to_log_n (
                                 'going to execute '
                              || l_stmt
                              || get_time
                           );
                        END IF;

                        OPEN cv FOR l_stmt;
                        l_dang_instance (1) := NULL;

                        LOOP
                           IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
                           THEN
                              FETCH cv INTO l_dang_str (1),
                                            l_dang_instance (1),
                                            l_dang_count (1);
                           ELSE
                              FETCH cv INTO l_dang_str (1), l_dang_count (1);
                           END IF;

                           EXIT WHEN cv%NOTFOUND;

                           IF      g_number_max_sample IS NOT NULL
                               AND l_number_dang_str > g_number_max_sample
                           THEN
                              EXIT;
                           END IF;

                           IF log_into_cdi_dang_table (
                                 g_lstg_fk_id (j),
                                 g_lstg_fk_table_id (j),
                                 g_parent_lstg_fk_table_id (j),
                                 l_dang_str (1),
                                 l_dang_count (1),
                                 l_dang_instance (1)
                              ) = FALSE
                           THEN
                              RETURN FALSE;
                           END IF;

                           IF l_number_dang_str <= g_number_sample
                           THEN
                              IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
                              THEN
                                 write_to_out (
                                       l_dang_str (1)
                                    || ' ('
                                    || l_dang_instance (1)
                                    || ') ('
                                    || l_dang_count (1)
                                    || ')'
                                 );
                              ELSE
                                 write_to_out (
                                       l_dang_str (1)
                                    || ' ('
                                    || l_dang_count (1)
                                    || ')'
                                 );
                              END IF;
                           END IF;

                           l_number_dang_str :=   l_number_dang_str
                                                + 1;
                        END LOOP;

                        write_to_out (' ');

                        IF g_debug
                        THEN
                           write_to_log_n (get_time);
                        END IF;

                        CLOSE cv;
                        l_number_dang_str :=   l_number_dang_str
                                             - 1;

                        IF edw_owb_collection_util.drop_table (
                              g_lstg_dang_rowid_table (j)
                           ) = FALSE
                        THEN
                           NULL;
                        END IF;
                     ELSE --parent is ALL
                        write_to_out ('  ');
                        fnd_message.set_name (
                           'BIS',
                           'EDW_CDI_SAMPLE_DANGLING'
                        );
                        write_to_out (fnd_message.get);
                        --write_to_out('Sample dangling records and their count ');
                        write_to_out (   'ALL('
                                      || l_num_dang
                                      || ')');
                        write_to_out (' ');
                        l_dang_instance (1) := NULL;

                        IF log_into_cdi_dang_table (
                              g_lstg_fk_id (j),
                              g_lstg_fk_table_id (j),
                              NULL,
                              'ALL',
                              l_num_dang,
                              l_dang_instance (1)
                           ) = FALSE
                        THEN
                           RETURN FALSE;
                        END IF;
                     END IF;
                  END IF; --if l_fk_number>l_fk_ok_number and g_sample_on then

                  IF edw_owb_collection_util.drop_table (g_lstg_ok_table (j)) =
                                                                         FALSE
                  THEN
                     NULL;
                  END IF;
               ELSE --if number of recs in the interface table > 0
                  write_to_log_n (
                        'Interface table '
                     || g_lstg_fk_table (j)
                     || ' has no records. No dangling check done'
                  );
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_dim_dang_check_lstg;

   FUNCTION execute_dim_dang_check_ltc (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt                 VARCHAR2 (30000);

      TYPE curtyp IS REF CURSOR;

      cv                     curtyp;
      l_num_dang             NUMBER;
      l_total_recs           NUMBER;
      l_number_dang_str      NUMBER;
      l_fk_ok_number         NUMBER;
      l_lstg_index           NUMBER;
      l_lstg_parent_index    NUMBER;
      l_dang_str             edw_owb_collection_util.varchartabletype;
      l_dang_count           edw_owb_collection_util.numbertabletype;
      l_dang_instance        edw_owb_collection_util.varchartabletype;
      l_lstg_fk_table_long   edw_owb_collection_util.varchartabletype;
   BEGIN
      FOR i IN 1 .. g_lstg_fk_number
      LOOP
         l_lstg_fk_table_long (i) := get_lstg_long_name (g_lstg_fk_table (i));
      END LOOP;

      write_to_out ('-------------------------------------------------------');
      fnd_message.set_name ('BIS', 'EDW_CDI_DANGLING_CHECK_LTC');
      write_to_out (fnd_message.get);
      --write_to_out('Dangling Records Check against Parent Level Tables');
      write_to_out ('-------------------------------------------------------');

      FOR i IN 1 .. g_number_hier_distinct
      LOOP
         write_to_out (' ');
         write_to_out ('  ');
         fnd_message.set_name ('BIS', 'EDW_CDI_HIERARCHY');
         fnd_message.set_token ('HIER', g_hier_distinct (i));
         write_to_out (fnd_message.get);

         --write_to_out('Hierarchy '||g_hier_distinct(i));
         FOR j IN 1 .. g_lstg_fk_number
         LOOP
            IF g_hier (j) = g_hier_distinct (i)
            THEN
               l_total_recs := get_num_recs_lstg (g_lstg_fk_table (j));

               IF g_debug
               THEN
                  write_to_log_n (
                        'Table '
                     || g_lstg_fk_table (j)
                     || ' '
                     || l_total_recs
                     || ' total recs returned'
                  );
               END IF;

               IF l_total_recs > 0
               THEN
                  l_lstg_index :=
                        edw_owb_collection_util.index_in_table (
                           g_lstg_tables,
                           g_number_lstg_tables,
                           g_lstg_fk_table (j)
                        );
                  --join with the parent lstg pk table and create the ok table
                  l_lstg_parent_index :=
                        edw_owb_collection_util.index_in_table (
                           g_lstg_tables,
                           g_number_lstg_tables,
                           g_parent_lstg_fk_table (j)
                        );
                  l_stmt :=    'create table '
                            || g_lstg_ok_table (j)
                            || ' tablespace '
                            || g_op_table_space;

                  IF g_parallel IS NOT NULL
                  THEN
                     l_stmt :=
                             l_stmt
                          || ' parallel (degree '
                          || g_parallel
                          || ') ';
                  END IF;

                  l_stmt :=    l_stmt
                            || ' as select /*+ORDERED*/ '
                            || g_lstg_fk_hold_table (j)
                            || '.row_id from '
                            || g_lstg_fk_hold_table (j)
                            || ','
                            || g_parent_ltc_fk_table (j)
                            || ' where '
                            || g_lstg_fk_hold_table (j)
                            || '.'
                            || g_lstg_fk (j)
                            || '='
                            || g_parent_ltc_fk_table (j)
                            || '.'
                            || g_parent_ltc_fk_table_pk (j);

                  IF edw_owb_collection_util.drop_table (g_lstg_ok_table (j)) =
                                                                         FALSE
                  THEN
                     NULL;
                  END IF;

                  IF g_debug
                  THEN
                     write_to_log_n (
                           'going to execute '
                        || l_stmt
                        || get_time
                     );
                  END IF;

                  EXECUTE IMMEDIATE l_stmt;
                  l_fk_ok_number := SQL%ROWCOUNT;

                  IF g_debug
                  THEN
                     write_to_log_n (
                           'Created '
                        || g_lstg_ok_table (j)
                        || ' with '
                        || l_fk_ok_number
                        || ' rows'
                        || get_time
                     );
                  END IF;

                  edw_owb_collection_util.analyze_table_stats (
                     SUBSTR (
                        g_lstg_ok_table (j),
                          INSTR (g_lstg_ok_table (j), '.')
                        + 1,
                        LENGTH (g_lstg_ok_table (j))
                     ),
                     SUBSTR (
                        g_lstg_ok_table (j),
                        1,
                          INSTR (g_lstg_ok_table (j), '.')
                        - 1
                     )
                  );
                  l_num_dang :=   l_total_recs
                                - l_fk_ok_number;

                  IF l_num_dang <= 0
                  THEN
                     write_to_out (' ');
                     fnd_message.set_name ('BIS', 'EDW_CDI_TABLE_AND_FK');
                     fnd_message.set_token (
                        'TABLE',
                        l_lstg_fk_table_long (j)
                     );
                     fnd_message.set_token ('FK', g_lstg_fk_long (j));
                     write_to_out (fnd_message.get);
                     --write_to_out('Table '||l_lstg_fk_table_long(j)||', Foreign Key '||g_lstg_fk_long(j));
                     fnd_message.set_name (
                        'BIS',
                        'EDW_CDI_PARENT_TABLE_AND_PK'
                     );
                     fnd_message.set_token (
                        'TABLE',
                        g_parent_ltc_fk_table_long (j)
                     );
                     fnd_message.set_token (
                        'PK',
                        g_parent_ltc_fk_table_pk_long (j)
                     );
                     write_to_out (fnd_message.get);
                     --write_to_out('Parent Level Table '||g_parent_ltc_fk_table_long(j)||' with Primary Key '||
                     --g_parent_ltc_fk_table_pk_long(j));
                     fnd_message.set_name ('BIS', 'EDW_CDI_NO_RECS_DANGLING');
                     write_to_out (fnd_message.get);
                  --write_to_out(' 0 records are dangling');
                  ELSE
                     write_to_out (' ');
                     fnd_message.set_name ('BIS', 'EDW_CDI_TABLE_AND_FK');
                     fnd_message.set_token (
                        'TABLE',
                        l_lstg_fk_table_long (j)
                     );
                     fnd_message.set_token ('FK', g_lstg_fk_long (j));
                     write_to_out (fnd_message.get);
                     --write_to_out('Table '||l_lstg_fk_table_long(j)||', Foreign Key '||g_lstg_fk_long(j));
                     fnd_message.set_name (
                        'BIS',
                        'EDW_CDI_PARENT_TABLE_AND_PK'
                     );
                     fnd_message.set_token (
                        'TABLE',
                        g_parent_ltc_fk_table_long (j)
                     );
                     fnd_message.set_token (
                        'PK',
                        g_parent_ltc_fk_table_pk_long (j)
                     );
                     write_to_out (fnd_message.get);
                     --write_to_out('Parent Level Table '||g_parent_ltc_fk_table_long(j)||' with Primary Key '||
                     --g_parent_ltc_fk_table_pk_long(j));
                     fnd_message.set_name ('BIS', 'EDW_CDI_RECS_DANGLING');
                     fnd_message.set_token ('DANGLING', l_num_dang);
                     fnd_message.set_token ('TOTAL', l_total_recs);
                     write_to_out (fnd_message.get);
                  --write_to_out(l_num_dang||' records  out of '||l_total_recs||' are dangling');
                  END IF;

                  IF g_results_table_flag
                  THEN
                     IF log_into_cdi_results_table (
                           g_object_name,
                           g_object_type,
                           g_object_id,
                           g_lstg_fk_table (j),
                           g_lstg_fk_table_id (j),
                           NULL,
                           NULL,
                           g_lstg_fk (j), --p_interface_table_fk
                           g_lstg_fk_id (j),
                           g_parent_ltc_fk_table (j), --p_parent_table
                           g_parent_ltc_fk_table_id (j), --p_parent_table_id
                           g_parent_ltc_fk_table_pk (j), --p_parent_table_pk
                           NULL,
                           l_num_dang, --p_number_dangling
                           NULL,
                           NULL,
                           l_total_recs,
                           'DANGLING'
                        ) = FALSE
                     THEN
                        RETURN FALSE;
                     END IF;
                  END IF;

                  IF  l_num_dang > 0 AND g_sample_on
                  THEN
                     --make the dang table with MINUS
                     l_stmt :=    'create table '
                               || g_lstg_dang_rowid_table (j)
                               || ' tablespace '
                               || g_op_table_space;

                     IF g_parallel IS NOT NULL
                     THEN
                        l_stmt :=    l_stmt
                                  || ' parallel (degree '
                                  || g_parallel
                                  || ') ';
                     END IF;

                     l_stmt :=    l_stmt
                               || ' as select row_id from '
                               || g_lstg_fk_hold_table (j)
                               || ' MINUS select row_id from '
                               || g_lstg_ok_table (j);

                     IF edw_owb_collection_util.drop_table (
                           g_lstg_dang_rowid_table (j)
                        ) = FALSE
                     THEN
                        NULL;
                     END IF;

                     IF g_debug
                     THEN
                        write_to_log_n (
                              'going to execute '
                           || l_stmt
                           || get_time
                        );
                     END IF;

                     EXECUTE IMMEDIATE l_stmt;

                     IF g_debug
                     THEN
                        write_to_log_n (
                              'Created '
                           || g_lstg_dang_rowid_table (j)
                           || ' with '
                           || SQL%ROWCOUNT
                           || ' rows'
                           || get_time
                        );
                     END IF;

                     edw_owb_collection_util.analyze_table_stats (
                        SUBSTR (
                           g_lstg_dang_rowid_table (j),
                             INSTR (g_lstg_dang_rowid_table (j), '.')
                           + 1,
                           LENGTH (g_lstg_dang_rowid_table (j))
                        ),
                        SUBSTR (
                           g_lstg_dang_rowid_table (j),
                           1,
                             INSTR (g_lstg_dang_rowid_table (j), '.')
                           - 1
                        )
                     );
                     --create the dang table
                     l_stmt :=    'select /*+ORDERED*/ '
                               || g_lstg_fk_hold_table (j)
                               || '.'
                               || g_lstg_fk (j);

                     IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
                     THEN
                        l_stmt :=    l_stmt
                                  || ','
                                  || g_lstg_fk_hold_table (j)
                                  || '.'
                                  || g_lstg_instance_col (l_lstg_index);
                     END IF;

                     l_stmt :=    l_stmt
                               || ' ,count(1)  from '
                               || g_lstg_dang_rowid_table (j)
                               || ','
                               || g_lstg_fk_hold_table (j)
                               || ' where '
                               || g_lstg_fk_hold_table (j)
                               || '.row_id='
                               || g_lstg_dang_rowid_table (j)
                               || '.row_id group by '
                               || g_lstg_fk_hold_table (j)
                               || '.'
                               || g_lstg_fk (j);

                     IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
                     THEN
                        l_stmt :=    l_stmt
                                  || ','
                                  || g_lstg_fk_hold_table (j)
                                  || '.'
                                  || g_lstg_instance_col (l_lstg_index);
                     END IF;

                     l_stmt :=    l_stmt
                               || ' order by count(1) desc';
                     write_to_out ('  ');
                     fnd_message.set_name ('BIS', 'EDW_CDI_SAMPLE_DANGLING');
                     write_to_out (fnd_message.get);
                     --write_to_out('Sample dangling records and their count ');
                     l_number_dang_str := 1;

                     IF g_debug
                     THEN
                        write_to_log_n (
                              'going to execute '
                           || l_stmt
                           || get_time
                        );
                     END IF;

                     OPEN cv FOR l_stmt;
                     l_dang_instance (1) := NULL;

                     LOOP
                        IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
                        THEN
                           FETCH cv INTO l_dang_str (1),
                                         l_dang_instance (1),
                                         l_dang_count (1);
                        ELSE
                           FETCH cv INTO l_dang_str (1), l_dang_count (1);
                        END IF;

                        EXIT WHEN cv%NOTFOUND;

                        IF      g_number_max_sample IS NOT NULL
                            AND l_number_dang_str > g_number_max_sample
                        THEN
                           EXIT;
                        END IF;

                        IF log_into_cdi_dang_table (
                              g_lstg_fk_id (j),
                              g_lstg_fk_table_id (j),
                              g_parent_ltc_fk_table_id (j),
                              l_dang_str (1),
                              l_dang_count (1),
                              l_dang_instance (1)
                           ) = FALSE
                        THEN
                           RETURN FALSE;
                        END IF;

                        IF l_number_dang_str <= g_number_sample
                        THEN
                           IF g_lstg_instance_col (l_lstg_index) IS NOT NULL
                           THEN
                              write_to_out (
                                    l_dang_str (1)
                                 || ' ('
                                 || l_dang_instance (1)
                                 || ') ('
                                 || l_dang_count (1)
                                 || ')'
                              );
                           ELSE
                              write_to_out (
                                    l_dang_str (1)
                                 || ' ('
                                 || l_dang_count (1)
                                 || ')'
                              );
                           END IF;
                        END IF;

                        l_number_dang_str :=   l_number_dang_str
                                             + 1;
                     END LOOP;

                     CLOSE cv;

                     IF g_debug
                     THEN
                        write_to_log_n (get_time);
                     END IF;

                     write_to_out (' ');
                     l_number_dang_str :=   l_number_dang_str
                                          - 1;

                     IF edw_owb_collection_util.drop_table (
                           g_lstg_dang_rowid_table (j)
                        ) = FALSE
                     THEN
                        NULL;
                     END IF;
                  END IF; --if l_fk_number>l_fk_ok_number and g_sample_on then

                  IF edw_owb_collection_util.drop_table (g_lstg_ok_table (j)) =
                                                                         FALSE
                  THEN
                     NULL;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_dim_dang_check_ltc;

   FUNCTION execute_hier_count (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      TYPE curtyp IS REF CURSOR;

      cv              curtyp;
      l_hier_number   NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || g_hier_stmt_num);
      END IF;

      write_to_out (' ');
      write_to_out (
            'Total number of records making into the WH'
         || get_time
      );

      IF g_debug
      THEN
         write_to_log_n (
               'going to execute '
            || g_hier_stmt_num
            || get_time
         );
      END IF;

      OPEN cv FOR g_hier_stmt_num;
      FETCH cv INTO l_hier_number;

      IF    l_hier_number IS NULL
         OR l_hier_number = 0
      THEN
         write_to_out ('0 total records will make it into the WH from');
         write_to_out ('the Level Interface Tables');
      ELSE
         write_to_out (
               l_hier_number
            || ' out of '
            || g_bottom_records
            || ' total records will make it into the WH based on'
         );
         write_to_out ('the LSTG tables');
      END IF;

      IF g_debug
      THEN
         write_to_log_n (get_time);
      END IF;

      write_to_out (' ');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cv;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         g_status_message := SQLERRM;
         write_to_out_log_n (SQLERRM);
         RETURN FALSE;
   END execute_hier_count;

   FUNCTION get_num_recs_lstg (p_lstg IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF g_lstg_tables (i) = p_lstg
         THEN
            RETURN g_lstg_total_records (i);
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN 0;
   END get_num_recs_lstg;

   PROCEDURE init_all (p_object_name IN VARCHAR2)
   IS
      l_status         BOOLEAN;
      l_option_value   VARCHAR2(500);
   BEGIN
      g_number_names := 0;
      g_log_name := 'CHECK_DATA_INT';
      g_debug := FALSE; --make this false
      g_duplicate_check := TRUE;
      l_status := TRUE;
      --edw_owb_collection_util.setup_conc_program_log (g_log_name);
      edw_owb_collection_util.init_all(g_log_name,null,'bis.edw.check_data_validity');
      IF edw_option.get_warehouse_option (
            p_object_name,
            NULL,
            'TRACE',
            l_option_value
         )
      THEN
         IF l_option_value = 'Y'
         THEN
            write_to_log_n ('Trace turned ON');
            edw_owb_collection_util.alter_session ('TRACE');
         ELSE
            write_to_log_n ('Trace turned OFF');
         END IF;
      ELSE
         l_status := FALSE;
      END IF;

      IF edw_option.get_warehouse_option (
            p_object_name,
            NULL,
            'DEBUG',
            l_option_value
         )
      THEN
         IF l_option_value = 'Y'
         THEN
            g_debug := TRUE;
         ELSE
            g_debug := FALSE;
         END IF;

         write_to_log_n (   'EDW_DEBUG the value is '
                         || l_option_value);
      ELSE
         l_status := FALSE;
      END IF;
      edw_owb_collection_util.set_debug(g_debug);
      IF edw_option.get_warehouse_option (
            p_object_name,
            NULL,
            'OPTABLESPACE',
            l_option_value
         )
      THEN
         g_op_table_space :=
               NVL (
                  l_option_value,
                  edw_owb_collection_util.get_table_space (g_bis_owner)
               );
         write_to_log_n (
               'EDW_Operation tablespace is '
            || g_op_table_space
         );
      ELSE
         l_status := FALSE;
      END IF;

      IF edw_option.get_warehouse_option (
            p_object_name,
            NULL,
            'DUPLICATE',
            l_option_value
         )
      THEN
         IF l_option_value = 'Y'
         THEN
            g_duplicate_check := FALSE;
         ELSE
            g_duplicate_check := TRUE;
         END IF;

         write_to_log_n (
               'EDW_DUPLICATE_COLLECT set to true, the value is '
            || l_option_value
         );
      ELSE
         l_status := FALSE;
      END IF;

      IF edw_option.get_warehouse_option (
            p_object_name,
            NULL,
            'PARALLELISM',
            l_option_value
         )
      THEN
         g_parallel := l_option_value;

	 --for Bug #2886705
	 IF g_parallel <= 0 THEN
		g_parallel := NULL;
	 END IF;

         IF g_parallel IS NOT NULL
         THEN
            edw_owb_collection_util.alter_session ('PARALLEL');
            edw_owb_collection_util.set_parallel (g_parallel);
            COMMIT;
         END IF;
      ELSE
         l_status := FALSE;
      END IF;

      IF edw_option.get_warehouse_option (
            p_object_name,
            NULL,
            'SORTAREA',
            l_option_value
         )
      THEN
         write_to_log_n (   'l_sort_area_size='
                         || l_option_value);

         IF l_option_value IS NOT NULL
         THEN
            EXECUTE IMMEDIATE    'alter session set hash_area_size='
                              || l_option_value;
         END IF;
      ELSE
         l_status := FALSE;
      END IF;

      IF edw_option.get_warehouse_option (
            p_object_name,
            NULL,
            'HASHAREA',
            l_option_value
         )
      THEN
         write_to_log_n (   'l_hash_area_size='
                         || l_option_value);

         IF l_option_value IS NOT NULL
         THEN
            EXECUTE IMMEDIATE    'alter session set sort_area_size='
                              || l_option_value;
         END IF;
      ELSE
         l_status := FALSE;
      END IF;

      IF l_status = FALSE
      THEN
         write_to_log_n (
               'Error. Reading of Object Settings Failed. Object: '
            || p_object_name
         );
         RAISE g_read_object_settings_failure;
      END IF;

      edw_owb_collection_util.set_debug (g_debug);

      /********for bug 2966892 *****/
      --g_number_sample := 10;
      --g_check_against_ltc := FALSE;
      --g_check_hier := FALSE;
      /****************************/

      g_sample_on := g_detailed_check;

      IF g_sample_on
      THEN
         write_to_log_n ('Sample ON');
      ELSE
         write_to_log_n ('Sample OFF');
      END IF;

      g_exec_flag := TRUE;
      g_bis_owner := edw_owb_collection_util.get_db_user ('BIS');
      g_number_fk_to_check := 0;
      g_results_table := 'EDW_CDI_RESULTS';

      IF edw_owb_collection_util.check_table (g_results_table) = TRUE
      THEN
         g_results_table_flag := TRUE;
      ELSE
         g_results_table_flag := FALSE;
      END IF;

      g_request_id := fnd_global.conc_request_id;
      g_number_max_sample := fnd_profile.VALUE ('EDW_MAX_SAMPLE_SIZE');
      write_to_log_n (   'Max sample size(tables)='
                      || g_number_max_sample);
      g_process_dang_keys := TRUE;
   END init_all;

   PROCEDURE close_all
   IS
   BEGIN
      NULL;
   END close_all;

   PROCEDURE write_to_log (p_message IN VARCHAR2)
   IS
   BEGIN
      edw_owb_collection_util.write_to_log_file (p_message);
   END write_to_log;

   PROCEDURE write_to_log_n (p_message IN VARCHAR2)
   IS
   BEGIN
      write_to_log ('   ');
      write_to_log (p_message);
   END write_to_log_n;

   PROCEDURE write_to_out (p_message IN VARCHAR2)
   IS
   BEGIN
      edw_owb_collection_util.write_to_out_file (p_message);
   END write_to_out;

   PROCEDURE write_to_out_n (p_message IN VARCHAR2)
   IS
   BEGIN
      write_to_out ('  ');
      write_to_out (p_message);
   END write_to_out_n;

   PROCEDURE write_to_out_log (p_message IN VARCHAR2)
   IS
   BEGIN
      write_to_out (p_message);
      write_to_log (p_message);
   END write_to_out_log;

   PROCEDURE write_to_out_log_n (p_message IN VARCHAR2)
   IS
   BEGIN
      write_to_out_n (p_message);
      write_to_log_n (p_message);
   END write_to_out_log_n;

   FUNCTION get_time
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    '  '
             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS');
   END get_time;

   FUNCTION parse_names (
      p_dim_string1   IN   VARCHAR2,
      p_dim_string2   IN   VARCHAR2,
      p_dim_string3   IN   VARCHAR2,
      p_dim_string4   IN   VARCHAR2,
      p_dim_string5   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      l_start        NUMBER;
      l_end          NUMBER;
      l_len          NUMBER;
      l_dim_string   VARCHAR2 (200);
   BEGIN
      FOR i IN 1 .. 5
      LOOP
         IF i = 1
         THEN
            l_dim_string := p_dim_string1;
         ELSIF i = 2
         THEN
            l_dim_string := p_dim_string2;
         ELSIF i = 3
         THEN
            l_dim_string := p_dim_string3;
         ELSIF i = 4
         THEN
            l_dim_string := p_dim_string4;
         ELSE
            l_dim_string := p_dim_string5;
         END IF;

         IF l_dim_string IS NULL
         THEN
            RETURN TRUE;
         END IF;

         l_start := 1;
         l_end := 1;
         l_len := LENGTH (l_dim_string);
         g_number_names := 0;

         LOOP
            l_end := INSTR (l_dim_string, ':', l_start);

            IF l_end = -1
            THEN
               EXIT;
            END IF;

            g_number_names :=   g_number_names
                              + 1;
            g_names (g_number_names) :=
                             SUBSTR (l_dim_string, l_start,   l_end
                                                            - l_start);
            l_start :=   l_end
                       + 1;

            IF l_start >= l_len
            THEN
               EXIT;
            END IF;
         END LOOP;
      END LOOP;

      write_to_log_n ('Objects to check ');

      FOR i IN 1 .. g_number_names
      LOOP
         write_to_log (g_names (i));
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END parse_names;

   FUNCTION get_long_names
      RETURN BOOLEAN
   IS
      l_stmt   VARCHAR2 (1000);

      TYPE curtyp IS REF CURSOR;

      cv       curtyp;
   BEGIN
      write_to_log_n ('Finding the long names');

      FOR i IN 1 .. g_number_names
      LOOP
         l_stmt :=
               'select relation_id, relation_long_name from edw_relations_md_v where relation_name =:s';
         OPEN cv FOR l_stmt USING g_names (i);
         FETCH cv INTO g_ids (i), g_names_long (i);
         write_to_log (
               g_names_long (i)
            || '('
            || g_names (i)
            || ')  '
            || g_ids (i)
         );
         CLOSE cv;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (
               'Error in function get_long_names '
            || SQLERRM
            || ', Time '
            || get_time
         );
         g_status_message := SQLERRM;
         RETURN FALSE;
   END get_long_names;

   FUNCTION get_long_for_short_name (p_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. g_number_names
      LOOP
         IF g_names (i) = p_name
         THEN
            RETURN g_names_long (i);
            EXIT;
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (
               'Error in function get_long_for_short_name for '
            || p_name
            || ' '
            || SQLERRM
         );
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_long_for_short_name;

   FUNCTION get_lstg_long_name (p_table IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF g_lstg_tables (i) = p_table
         THEN
            RETURN g_lstg_table_long_name (i);
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (
               'Error in function get_lstg_long_name for '
            || p_table
            || ' '
            || SQLERRM
         );
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_lstg_long_name;

   FUNCTION get_lstg_pk (p_table IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. g_number_lstg_tables
      LOOP
         IF g_lstg_tables (i) = p_table
         THEN
            RETURN g_lstg_pk (i);
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (
               'Error in function get_lstg_pk for '
            || p_table
            || ' '
            || SQLERRM
         );
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_lstg_pk;

   FUNCTION get_fk_long (
      p_fk              IN   VARCHAR2,
      fk_table_long     IN   edw_owb_collection_util.varchartabletype,
      fk_table          IN   edw_owb_collection_util.varchartabletype,
      fk_table_number   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. fk_table_number
      LOOP
         IF fk_table (i) = p_fk
         THEN
            RETURN fk_table_long (i);
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (
               'Error in function get_fk_long for '
            || p_fk
            || ' '
            || SQLERRM
         );
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_fk_long;

   FUNCTION get_parent_ltc_long (
      p_ltc                    IN   VARCHAR2,
      p_lstg_ltc_parent        IN   edw_owb_collection_util.varchartabletype,
      p_lstg_ltc_parent_long   IN   edw_owb_collection_util.varchartabletype,
      p_number_lstg            IN   NUMBER
   )
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. p_number_lstg
      LOOP
         IF p_ltc = p_lstg_ltc_parent (i)
         THEN
            RETURN p_lstg_ltc_parent_long (i);
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (
               'Error in function get_parent_ltc_long for '
            || p_ltc
            || ' '
            || SQLERRM
         );
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_parent_ltc_long;

   FUNCTION get_ltc_pk_long (
      p_parent_ltc_fk_table_pk    IN   VARCHAR2,
      p_lstg_ltc_parent_pk        IN   edw_owb_collection_util.varchartabletype,
      p_lstg_ltc_parent_pk_long   IN   edw_owb_collection_util.varchartabletype,
      p_number_lstg               IN   NUMBER
   )
      RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1 .. p_number_lstg
      LOOP
         IF p_parent_ltc_fk_table_pk = p_lstg_ltc_parent_pk (i)
         THEN
            RETURN p_lstg_ltc_parent_pk_long (i);
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (
               'Error in function get_ltc_pk_long for '
            || p_parent_ltc_fk_table_pk
            || ' '
            || SQLERRM
         );
         g_status_message := SQLERRM;
         RETURN NULL;
   END get_ltc_pk_long;


/*
-------------------------------------------------------
Procedures to check facts
-------------------------------------------------------
*/
   PROCEDURE check_facts_data (
      errbuf             OUT NOCOPY     VARCHAR2,
      retcode            OUT NOCOPY     VARCHAR2,
      p_fact_string1     IN       VARCHAR2,
      p_check_tot_recs   IN       VARCHAR2,
      p_detailed_check   IN       VARCHAR2,
      p_sample_size      IN       NUMBER,
      p_fk_to_check      IN       VARCHAR2
   )
   IS
   BEGIN
      retcode := '0';

      IF p_detailed_check = 'Y'
      THEN
         g_detailed_check := TRUE;
      ELSE
         g_detailed_check := FALSE;
      END IF;

      --   init_all;
      g_number_names := 1;
      g_names (g_number_names) := p_fact_string1;
      g_number_fk_to_check := 0;

      IF get_fk_to_check (p_fk_to_check) = FALSE
      THEN
         fnd_message.set_name ('BIS', 'EDW_CDI_ERROR_METADATA_READ');
         errbuf := fnd_message.get;
         write_to_out (errbuf);
         retcode := '2';
         RETURN;
      END IF;

      IF get_long_names = FALSE
      THEN
         fnd_message.set_name ('BIS', 'EDW_CDI_NO_FACT_LONG_NAME');
         write_to_log_n (
               'Could not get long name for the fact. Stopping Data Check, Time '
            || get_time
         );
         errbuf := fnd_message.get;
         write_to_out_n (errbuf);
         retcode := '2';
         RETURN;
      END IF;

      g_number_sample := p_sample_size;
      write_to_log_n (   'Sample size='
                      || g_number_sample);
      g_check_hier := FALSE;
      /*if p_check_tot_recs = 'Y' then
       g_check_hier :=true;
       write_to_log_n('check total records making into wh on');
      else
       write_to_log_n('check total records making into wh off');
      end if;*/

      errbuf := NULL;

      FOR i IN 1 .. g_number_names
      LOOP
         g_object_name := g_names (i);
         g_object_id := g_ids (i);
         g_object_type := 'FACT';

         IF check_fact (g_names (i), g_names_long (i)) = FALSE
         THEN
            errbuf := g_status_message;
            retcode := '2';
         END IF;
      END LOOP;

      clean_up;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         errbuf := SQLERRM;
         retcode := '2';
   END check_facts_data;

   FUNCTION check_fact (p_fact_name IN VARCHAR2, p_fact_name_long IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      write_to_out_log_n (
         '--------------------------------------------------'
      );
      fnd_message.set_name ('BIS', 'EDW_CDI_CHECKING_FACT');
      fnd_message.set_token ('FACT', p_fact_name_long);
      write_to_out (fnd_message.get);
      write_to_log (
            '        Checking fact '
         || p_fact_name_long
         || '('
         || p_fact_name
         || ')'
      );
      write_to_out_log ('--------------------------------------------------');
      write_to_out_log ('  ');
      init_all (p_fact_name);

      IF g_results_table_flag
      THEN
         IF delete_cdi_results_table (p_fact_name) = FALSE
         THEN
            RETURN FALSE;
         END IF;
      END IF;

      IF get_fstg_dim_keys (p_fact_name) = FALSE
      THEN
         write_to_log_n (
               'Error in getting fstg, dim and key info. cannot check this fact '
            || p_fact_name
         );
         fnd_message.set_name ('BIS', 'EDW_CDI_END_DATA_CHECK');
         write_to_out (fnd_message.get);
         --write_to_out('Error in reading metadata for fact. Stopping Data Check');
         RETURN FALSE;
      END IF;

      IF generate_fk_table (p_fact_name) = FALSE
      THEN
         write_to_log_n (   'Error in generate_fk_table '
                         || p_fact_name);
         fnd_message.set_name ('BIS', 'EDW_CDI_ERROR_GENERATE_TABLE');
         write_to_out (fnd_message.get);
         --write_to_out('Error in generating fk table. Stopping Data Check');
         RETURN FALSE;
      END IF;

      /*if make_sql_statements_fact(p_fact_name)=false then
       write_to_log_n('Error in making sql statements. cannot check this fact '||p_fact_name);
       write_to_out('Error in reading metadata for fact. Stopping Data Check');
       return false;
      end if;
      write_to_log_n('make_sql_statements_fact done '||get_time);*/

      IF g_exec_flag
      THEN
         IF execute_fact_check (p_fact_name) = FALSE
         THEN
            write_to_log_n (
                  'Error in executing fact data check. cannot check this fact '
               || p_fact_name
            );
            fnd_message.set_name ('BIS', 'EDW_CDI_ERROR_FACT_CHECK');
            write_to_out (fnd_message.get);
            --write_to_out('Error in executing Data Check for fact. Stopping Data Check');
            RETURN FALSE;
         END IF;

         write_to_log_n (
               'execute_fact_check done for '
            || p_fact_name
            || ' '
            || get_time
         );

         /*
         if drop_fstg_fk_tables(p_fact_name)=false then
           null;
         end if;*/
         IF drop_fstg_pk_table (p_fact_name) = FALSE
         THEN
            NULL;
         END IF;
      ELSE
         write_to_log_n ('Execute option turned off. No check done');
      END IF;

      IF g_fstg_total_records > 0
      THEN
         IF g_process_dang_keys
         THEN
            IF process_dang_keys (p_fact_name) = FALSE
            THEN
               RETURN FALSE;
            END IF;
         END IF;
      END IF;

      --drop the fk tabke
      IF drop_fk_table (p_fact_name) = FALSE
      THEN
         NULL;
      END IF;

      write_to_out_log_n (
         '--------------------------------------------------'
      );
      fnd_message.set_name ('BIS', 'EDW_CDI_END_DATA_CHECK');
      write_to_out (fnd_message.get);
      write_to_log (   '   End Check for fact '
                    || p_fact_name_long);
      write_to_out_log ('--------------------------------------------------');
      write_to_out_log ('  ');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END check_fact;

   FUNCTION get_fstg_dim_keys (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt                  VARCHAR2 (30000);

      TYPE curtyp IS REF CURSOR;

      cv                      curtyp;
      l_fstg_fk               edw_owb_collection_util.varchartabletype;
      l_fstg_fk_id            edw_owb_collection_util.numbertabletype;
      l_fstg_fk_long          edw_owb_collection_util.varchartabletype;
      l_fact_dims_id          edw_owb_collection_util.numbertabletype;
      l_fact_dims             edw_owb_collection_util.varchartabletype;
      l_fact_dims_long        edw_owb_collection_util.varchartabletype;
      l_fact_dims_pk          edw_owb_collection_util.varchartabletype;
      l_fact_dims_pk_long     edw_owb_collection_util.varchartabletype;
      l_number_fstg_fk        NUMBER;
      l_skipped_cols          edw_owb_collection_util.varchartabletype;
      l_number_skipped_cols   NUMBER;
      l_map_src_col           edw_owb_collection_util.varchartabletype;
      l_map_tgt_col           edw_owb_collection_util.varchartabletype;
      l_number_map_cols       NUMBER;
      l_index                 NUMBER;
   BEGIN
      l_stmt :=
               'SELECT fstg.relation_id, fstg.relation_name,  fstg.relation_long_name, '
            || 'pk.column_name, pk.column_id, pk_col.business_name '
            || 'FROM edw_relations_md_v fstg, edw_relationmapping_md_v map, edw_facts_md_v fact, '
            || 'edw_unique_key_columns_md_v pk, '
            || 'edw_unique_keys_md_v uk, '
            || 'edw_all_columns_md_v pk_col '
            || 'WHERE fact.fact_name = :s '
            || 'AND map.targetdataentity = fact.fact_id '
            || 'AND fstg.relation_id = map.sourcedataentity '
            || 'AND uk.entity_id = fstg.relation_id '
            || 'AND pk.key_id = uk.key_id '
            || 'AND pk.column_id = pk_col.column_id '
            || 'AND uk.entity_id = pk_col.entity_id ';

      IF g_debug
      THEN
         write_to_log_n (   'going to execute '
                         || l_stmt);
      END IF;

      OPEN cv FOR l_stmt USING p_fact_name;
      FETCH cv INTO g_fstg_id,
                    g_fstg_name,
                    g_fstg_name_long,
                    g_fstg_pk,
                    g_fstg_pk_id,
                    g_fstg_pk_long;
      CLOSE cv;
      write_to_log_n (
            'FSTG table for fact '
         || g_fstg_name_long
         || '('
         || g_fstg_name
         || ')'
         || ' with pk '
         || g_fstg_pk_long
         || '('
         || g_fstg_pk
         || ')'
      );

      IF g_fstg_name IS NULL
      THEN
         write_to_log_n ('No staging table for fact found.');
         RETURN FALSE;
      END IF;

      g_fact_pk_table :=    g_bis_owner
                         || '.'
                         || p_fact_name
                         || 'CP';
      g_fact_dup_pk_table :=    g_bis_owner
                             || '.'
                             || p_fact_name
                             || 'PD';
      l_stmt :=
               'SELECT fk_col.fk_column_name, fk_col.fk_column_id, fcol.business_name, '
            || 'dim.dim_id, dim.dim_name, dim.dim_long_name, uk_col.column_name, '
            || 'ucol.business_name '
            || 'FROM edw_relations_md_v fact, '
            || 'edw_foreign_key_columns_md_v fk_col, '
            || 'edw_unique_key_columns_md_v uk_col, '
            || 'edw_dimensions_md_v dim, '
            || 'edw_unique_keys_md_v uk, '
            || 'edw_all_columns_md_v fcol, '
            || 'edw_all_columns_md_v ucol '
            || 'WHERE fact.relation_name = :a '
            || 'and fact.relation_id = fk_col.entity_id '
            || 'and fk_col.pk_id = uk_col.key_id '
            || 'and uk_col.key_id = uk.key_id '
            || 'and uk.entity_id = dim.dim_id '
            || 'and fcol.column_id = fk_col.fk_column_id '
            || 'and fcol.entity_id = fact.relation_id '
            || 'and ucol.column_id = uk_col.column_id '
            || 'and ucol.entity_id = dim.dim_id ';
      l_number_fstg_fk := 1;
      OPEN cv FOR l_stmt USING g_fstg_name;

      LOOP
         FETCH cv INTO l_fstg_fk (l_number_fstg_fk),
                       l_fstg_fk_id (l_number_fstg_fk),
                       l_fstg_fk_long (l_number_fstg_fk),
                       l_fact_dims_id (l_number_fstg_fk),
                       l_fact_dims (l_number_fstg_fk),
                       l_fact_dims_long (l_number_fstg_fk),
                       l_fact_dims_pk (l_number_fstg_fk),
                       l_fact_dims_pk_long (l_number_fstg_fk);
         EXIT WHEN cv%NOTFOUND;
         l_number_fstg_fk :=   l_number_fstg_fk
                             + 1;
      END LOOP;

      l_number_fstg_fk :=   l_number_fstg_fk
                          - 1;

      IF l_number_fstg_fk = 0
      THEN
         write_to_log_n (   'No FKs found for fact '
                         || p_fact_name);
         RETURN FALSE;
      END IF;

      --get the skipped fks
      IF edw_owb_collection_util.get_item_set_cols (
            l_skipped_cols,
            l_number_skipped_cols,
            p_fact_name,
            'SKIP_LOAD_SET'
         ) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      IF g_debug
      THEN
         write_to_log_n ('The skipped cols of the fact');

         FOR i IN 1 .. l_number_skipped_cols
         LOOP
            write_to_log (l_skipped_cols (i));
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
          write_to_log_n(l_stmt||' '||p_fact_name);
        end if;
        open cv for l_stmt using p_fact_name;
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
        --4063140. we now pass null for job id.
        if EDW_OWB_COLLECTION_UTIL.get_stg_map_fk_details(
          l_fstgTableUsageId,
          l_fstgTableId,
          l_mapping_id,
          null,
          g_op_table_space,
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
         write_to_log_n ('The Mapping relations between the keys');

         FOR i IN 1 .. l_number_map_cols
         LOOP
            write_to_log (   l_map_src_col (i)
                          || ' -> '
                          || l_map_tgt_col (i));
         END LOOP;
      END IF;

      g_number_fstg_fk := 0;

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
            g_number_fstg_fk :=   g_number_fstg_fk
                                + 1;
            g_fstg_fk (g_number_fstg_fk) := l_fstg_fk (l_index);
            g_fstg_fk_id (g_number_fstg_fk) := l_fstg_fk_id (l_index);
            g_fstg_fk_long (g_number_fstg_fk) := l_fstg_fk_long (l_index);
            g_fact_dims_id (g_number_fstg_fk) := l_fact_dims_id (l_index);
            g_fact_dims (g_number_fstg_fk) := l_fact_dims (l_index);
            g_fact_dims_long (g_number_fstg_fk) := l_fact_dims_long (l_index);
            g_fact_dims_pk (g_number_fstg_fk) := l_fact_dims_pk (l_index);
            g_fact_dims_pk_long (g_number_fstg_fk) :=
                                                l_fact_dims_pk_long (l_index);
         END IF;
      END LOOP;

      --get the instance column
      g_fstg_instance_col :=
                        edw_owb_collection_util.get_instance_col (g_fstg_name);

      IF edw_owb_collection_util.value_in_table (
            g_fstg_fk,
            g_number_fstg_fk,
            g_fstg_instance_col
         ) = FALSE
      THEN
         l_index := NULL;
         l_index :=
               edw_owb_collection_util.index_in_table (
                  l_fstg_fk,
                  l_number_fstg_fk,
                  g_fstg_instance_col
               );

         IF l_index IS NOT NULL
         THEN
            g_number_fstg_fk :=   g_number_fstg_fk
                                + 1;
            g_fstg_fk (g_number_fstg_fk) := l_fstg_fk (l_index);
            g_fstg_fk_id (g_number_fstg_fk) := l_fstg_fk_id (l_index);
            g_fstg_fk_long (g_number_fstg_fk) := l_fstg_fk_long (l_index);
            g_fact_dims_id (g_number_fstg_fk) := l_fact_dims_id (l_index);
            g_fact_dims (g_number_fstg_fk) := l_fact_dims (l_index);
            g_fact_dims_long (g_number_fstg_fk) := l_fact_dims_long (l_index);
            g_fact_dims_pk (g_number_fstg_fk) := l_fact_dims_pk (l_index);
            g_fact_dims_pk_long (g_number_fstg_fk) :=
                                                l_fact_dims_pk_long (l_index);
         END IF;
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         g_fk_check_flag (i) := TRUE; --default
      END LOOP;

      IF g_number_fk_to_check > 0
      THEN
         FOR i IN 1 .. g_number_fstg_fk
         LOOP
            IF edw_owb_collection_util.value_in_table (
                  g_fk_to_check,
                  g_number_fk_to_check,
                  g_fstg_fk (i)
               )
            THEN
               g_fk_check_flag (i) := TRUE;
            ELSE
               g_fk_check_flag (i) := FALSE;
            END IF;
         END LOOP;
      END IF;

      IF g_debug
      THEN
         write_to_log_n ('The fact FKs, parent dims and dim pks');

         FOR i IN 1 .. g_number_fstg_fk
         LOOP
            write_to_log (
                  g_fstg_fk (i)
               || '  '
               || g_fact_dims (i)
               || '  '
               || g_fact_dims_pk (i)
            );
         END LOOP;

         write_to_log_n ('The long names:-');

         FOR i IN 1 .. g_number_fstg_fk
         LOOP
            write_to_log (
                  g_fstg_fk_long (i)
               || '  '
               || g_fact_dims_long (i)
               || '  '
               || g_fact_dims_pk_long (i)
            );
         END LOOP;

         IF g_number_fk_to_check > 0
         THEN
            write_to_log_n ('The FKs that will be checked');

            FOR i IN 1 .. g_number_fstg_fk
            LOOP
               IF g_fk_check_flag (i)
               THEN
                  write_to_log (g_fstg_fk (i));
               END IF;
            END LOOP;
         END IF;

         write_to_log_n (   'The instance column '
                         || g_fstg_instance_col);
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         g_fact_fk_table (i) :=    g_bis_owner
                                || '.'
                                || p_fact_name
                                || 'CF'
                                || i;
         g_fact_fk_ok_table (i) :=
                                   g_bis_owner
                                || '.'
                                || p_fact_name
                                || 'CO'
                                || i;
         g_fact_fk_dang_rowid_table (i) :=
                                   g_bis_owner
                                || '.'
                                || p_fact_name
                                || 'CR'
                                || i;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END get_fstg_dim_keys;

   FUNCTION make_sql_statements_fact (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      g_fact_dup_stmt_num :=    'select nvl(sum(count(1)),0) from '
                             || g_fk_table
                             || ' '
                             || ' having count('
                             || g_fstg_pk
                             || ') > 1 group by '
                             || g_fstg_pk;
      g_fact_dup_stmt_str :=    'select distinct '
                             || g_fstg_pk
                             || ' from '
                             || g_fk_table
                             || '  having count('
                             || g_fstg_pk
                             || ') > 1 group by '
                             || g_fstg_pk;
      g_number_dang_stmt := 0;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         g_fact_dang_stmt_num (i) :=
                  'select nvl(count(1),0) from '
               || g_fk_table
               || ' abc where
    not exists (select 1 from '
               || g_fact_dims (i)
               || ' where '
               || g_fact_dims (i)
               || '.'
               || g_fact_dims_pk (i)
               || ' = abc.'
               || g_fstg_fk (i)
               || ') ';
         g_fact_dang_stmt_str (i) :=
                  'select distinct abc.'
               || g_fstg_fk (i)
               || ' from '
               || g_fk_table
               || ' abc where  not
   exists (select 1 from '
               || g_fact_dims (i)
               || ' where '
               || g_fact_dims (i)
               || '.'
               || g_fact_dims_pk (i)
               || ' = abc.'
               || g_fstg_fk (i)
               || ') ';
         g_number_dang_stmt :=   g_number_dang_stmt
                               + 1;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END make_sql_statements_fact;

   FUNCTION execute_fact_check (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF execute_fact_total_records (p_fact_name) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      write_to_log_n ('Executed execute_fact_total_records');
      fnd_message.set_name ('BIS', 'EDW_CDI_TABLE_AND_RECORDS');
      fnd_message.set_token ('TABLE', g_fstg_name);
      fnd_message.set_token ('RECORDS', g_fstg_total_records);
      write_to_out (fnd_message.get);

      --write_to_out('Fstg table '||g_fstg_name||' has '||g_fstg_total_records||' total records with collection status of');
      --write_to_out('''READY'' ''DANGLING'' or ''DUPLICATE''');
      IF g_fstg_total_records = 0
      THEN
         fnd_message.set_name ('BIS', 'EDW_CDI_END_DATA_CHECK');
         write_to_out (fnd_message.get);
         --write_to_out('No data to check.');
         RETURN TRUE;
      END IF;

      --get the duplicates;
      IF g_duplicate_check = TRUE
      THEN
         IF execute_fact_duplicate_check (p_fact_name) = FALSE
         THEN
            RETURN FALSE;
         END IF;

         write_to_log_n ('Executed execute_fact_duplicate_check...');
      END IF;

      IF execute_fact_dangling_check (p_fact_name) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      write_to_log_n ('Executed execute_fact_dangling_check');

      IF g_check_hier
      THEN
         write_to_log_n (
            'Checking the total number of records making into the wh'
         );

         IF execute_fstg_makeit_stmt (p_fact_name) = FALSE
         THEN
            RETURN FALSE;
         END IF;

         write_to_log_n ('Executed execute_fstg_makeit_stmt');
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_fact_check;

   FUNCTION execute_fact_total_records (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt   VARCHAR2 (2000);
   BEGIN
      --make the rowid table
      l_stmt :=    'create table '
                || g_fact_pk_table
                || ' tablespace '
                || g_op_table_space;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel (degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=    l_stmt
                || ' as select ';
      l_stmt :=    l_stmt
                || g_fstg_pk
                || ',row_id from '
                || g_fk_table;

      IF edw_owb_collection_util.drop_table (g_fact_pk_table) = FALSE
      THEN
         NULL;
      END IF;

      IF g_debug
      THEN
         write_to_log_n (   'going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      EXECUTE IMMEDIATE l_stmt;
      g_fstg_total_records := SQL%ROWCOUNT;

      IF g_debug
      THEN
         write_to_log_n (
               'Created '
            || g_fact_pk_table
            || ' with '
            || g_fstg_total_records
            || ' rows'
            || get_time
         );
      END IF;

      edw_owb_collection_util.analyze_table_stats (
         SUBSTR (
            g_fact_pk_table,
              INSTR (g_fact_pk_table, '.')
            + 1,
            LENGTH (g_fact_pk_table)
         ),
         SUBSTR (g_fact_pk_table, 1,   INSTR (g_fact_pk_table, '.')
                                     - 1)
      );
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_fact_total_records;

   FUNCTION execute_fact_duplicate_check (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt             VARCHAR2 (30000);

      TYPE curtyp IS REF CURSOR;

      cv                 curtyp;
      l_num_dup          NUMBER                                   := 0;
      l_dup_str          edw_owb_collection_util.varchartabletype;
      l_dup_count        edw_owb_collection_util.numbertabletype;
      l_number_dup_str   NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (   'going to execute '
                         || g_fact_dup_stmt_num);
      END IF;

      fnd_message.set_name ('BIS', 'EDW_CDI_DUPLICATE_DATA_CHECK');
      write_to_out (   '----------'
                    || fnd_message.get
                    || '----------');

--write_to_out('----------- Duplicate Check -------------');
      write_to_out (' ');
      l_stmt :=    'create table '
                || g_fact_dup_pk_table
                || ' tablespace '
                || g_op_table_space;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel (degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=    l_stmt
                || ' as select '
                || g_fstg_pk
                || ' PK,count(1) dup_count from '
                || g_fact_pk_table
                || ' having count('
                || g_fstg_pk
                || ')>1 group by '
                || g_fstg_pk;

      IF edw_owb_collection_util.drop_table (g_fact_dup_pk_table) = FALSE
      THEN
         NULL;
      END IF;

      IF g_debug
      THEN
         write_to_log_n (   'going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      EXECUTE IMMEDIATE l_stmt;
      l_num_dup := SQL%ROWCOUNT;

      IF g_debug
      THEN
         write_to_log_n (
               'Created '
            || g_fact_dup_pk_table
            || ' with '
            || l_num_dup
            || ' rows'
            || get_time
         );
      END IF;

      IF l_num_dup <= 0
      THEN
         fnd_message.set_name ('BIS', 'EDW_CDI_RECORDS_DUPLICATE');
         fnd_message.set_token ('TABLE', p_fact_name);
         fnd_message.set_token ('DUPLICATE', 0);
         fnd_message.set_token ('TOTAL', g_fstg_total_records);
         write_to_out (fnd_message.get);
         --write_to_out_log_n('No Duplicate records found');
         RETURN TRUE;
      END IF;

      --EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_fact_dup_pk_table,instr(g_fact_dup_pk_table,'.')+1,
      --length(g_fact_dup_pk_table)),substr(g_fact_dup_pk_table,1,instr(g_fact_dup_pk_table,'.')-1));
      --write_to_out_log_n('Number of duplicate records in interface table '||l_num_dup);

      l_stmt :=    'select sum(dup_count) from '
                || g_fact_dup_pk_table;

      IF g_debug
      THEN
         write_to_log_n (   'going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      OPEN cv FOR l_stmt;
      FETCH cv INTO l_num_dup;
      CLOSE cv;
      fnd_message.set_name ('BIS', 'EDW_CDI_RECORDS_DUPLICATE');
      fnd_message.set_token ('TABLE', p_fact_name);
      fnd_message.set_token ('DUPLICATE', l_num_dup);
      fnd_message.set_token ('TOTAL', g_fstg_total_records);
      write_to_out (fnd_message.get);
      write_to_log_n (
            'Number of duplicate records in interface table '
         || l_num_dup
      );

      IF g_results_table_flag
      THEN
         IF log_into_cdi_results_table (
               g_object_name,
               g_object_type,
               g_object_id,
               g_fstg_name,
               g_fstg_id,
               g_fstg_pk,
               g_fstg_pk_id,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               l_num_dup,
               NULL,
               g_fstg_total_records,
               'DUPLICATE'
            ) = FALSE
         THEN
            RETURN FALSE;
         END IF;
      END IF;

      IF g_sample_on
      THEN
         l_stmt :=    'select PK,dup_count from '
                   || g_fact_dup_pk_table;

         IF g_debug
         THEN
            write_to_log_n (   'going to execute '
                            || l_stmt
                            || get_time);
         END IF;

         l_number_dup_str := 1;
         write_to_out ('  ');
         fnd_message.set_name ('BIS', 'EDW_CDI_SAMPLE_DUPLICATE');
         write_to_out (fnd_message.get);

         --write_to_out('Sample Duplicate Records and their Count');
         IF g_debug
         THEN
            write_to_log_n (   'going to execute '
                            || l_stmt
                            || get_time);
         END IF;

         OPEN cv FOR l_stmt;

         LOOP
            FETCH cv INTO l_dup_str (1), l_dup_count (1);
            EXIT WHEN cv%NOTFOUND;

            IF      g_number_max_sample IS NOT NULL
                AND l_number_dup_str > g_number_max_sample
            THEN
               EXIT;
            END IF;

            IF log_into_cdi_dang_table (
                  g_fstg_pk_id,
                  g_fstg_id,
                  NULL,
                  l_dup_str (1),
                  l_dup_count (1),
                  NULL
               ) = FALSE
            THEN
               RETURN FALSE;
            END IF;

            IF l_number_dup_str <= g_number_sample
            THEN
               write_to_out (   l_dup_str (1)
                             || ' ('
                             || l_dup_count (1)
                             || ')');
            END IF;

            l_number_dup_str :=   l_number_dup_str
                                + 1;
         END LOOP;

         l_number_dup_str :=   l_number_dup_str
                             - 1;
         CLOSE cv;

         IF g_debug
         THEN
            write_to_log_n (get_time);
         END IF;

         write_to_out ('  ');
      END IF;

      IF edw_owb_collection_util.drop_table (g_fact_dup_pk_table) = FALSE
      THEN
         NULL;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_fact_duplicate_check;

   FUNCTION drop_fstg_fk_tables (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         IF edw_owb_collection_util.drop_table (g_fact_fk_table (i)) = FALSE
         THEN
            NULL;
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END drop_fstg_fk_tables;

   FUNCTION drop_fstg_pk_table (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF edw_owb_collection_util.drop_table (g_fact_pk_table) = FALSE
      THEN
         NULL;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END drop_fstg_pk_table;

   FUNCTION drop_fk_table (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF edw_owb_collection_util.drop_table (g_fk_table) = FALSE
      THEN
         NULL;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END drop_fk_table;

   FUNCTION create_fstg_fk_tables (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt   VARCHAR2 (30000);
   BEGIN
      IF g_debug
      THEN
         write_to_log_n ('In create_fstg_fk_tables');
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         l_stmt :=    'create table '
                   || g_fact_fk_table (i)
                   || ' tablespace '
                   || g_op_table_space;

         IF g_parallel IS NOT NULL
         THEN
            l_stmt :=    l_stmt
                      || ' parallel (degree '
                      || g_parallel
                      || ') ';
            l_stmt :=    l_stmt
                      || ' as select /*+PARELLEL('
                      || g_fstg_name
                      || ','
                      || g_parallel
                      || ')*/ ';
         ELSE
            l_stmt :=    l_stmt
                      || ' as select ';
         END IF;

         l_stmt :=    l_stmt
                   || g_fstg_fk (i)
                   || ' FK,'
                   || g_fstg_name
                   || '.rowid row_id from '
                   || g_fstg_name
                   || ','
                   || g_fact_pk_table
                   || ' where '
                   || g_fstg_name
                   || '.rowid='
                   || g_fact_pk_table
                   || '.row_id';

         IF edw_owb_collection_util.drop_table (g_fact_fk_table (i)) = FALSE
         THEN
            NULL;
         END IF;

         IF g_debug
         THEN
            write_to_log_n (   'going to execute '
                            || l_stmt
                            || get_time);
         END IF;

         EXECUTE IMMEDIATE l_stmt;
         g_number_fact_fk_table (i) := SQL%ROWCOUNT;

         IF g_debug
         THEN
            write_to_log_n (
                  'Created '
               || g_fact_fk_table (i)
               || ' with '
               || g_number_fact_fk_table (i)
               || ' rows'
               || get_time
            );
         END IF;

         edw_owb_collection_util.analyze_table_stats (
            SUBSTR (
               g_fact_fk_table (i),
                 INSTR (g_fact_fk_table (i), '.')
               + 1,
               LENGTH (g_fact_fk_table (i))
            ),
            SUBSTR (
               g_fact_fk_table (i),
               1,
                 INSTR (g_fact_fk_table (i), '.')
               - 1
            )
         );
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END create_fstg_fk_tables;

   FUNCTION execute_fact_dangling_check (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt              VARCHAR2 (30000);

      TYPE curtyp IS REF CURSOR;

      cv                  curtyp;
      l_num_dang          NUMBER;
      l_dang_str          edw_owb_collection_util.varchartabletype;
      l_dang_count        edw_owb_collection_util.numbertabletype;
      l_dang_instance     edw_owb_collection_util.varchartabletype;
      l_number_dang_str   NUMBER;
      l_fk_ok_number      NUMBER;
   BEGIN
      fnd_message.set_name ('BIS', 'EDW_CDI_DANGLING_CHECK');
      write_to_out (   '-----------'
                    || fnd_message.get
                    || '-----------');

--write_to_out('----------- Dangling Check -------------');
      write_to_out (' ');

      /*
      if create_fstg_fk_tables(p_fact_name)=false then
        return false;
      end if;*/
      IF g_debug
      THEN
         write_to_log_n ('In execute_fact_dangling_check');
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         IF g_fk_check_flag (i)
         THEN
            l_stmt :=    'create table '
                      || g_fact_fk_ok_table (i)
                      || ' tablespace '
                      || g_op_table_space;

            IF g_parallel IS NOT NULL
            THEN
               l_stmt :=    l_stmt
                         || ' parallel (degree '
                         || g_parallel
                         || ') ';
               l_stmt :=    l_stmt
                         || ' as select /*+ORDERED*/ /*+PARELLEL('
                         || g_fact_dims (i)
                         || ','
                         || g_parallel
                         || ')*/ ';
            ELSE
               l_stmt :=    l_stmt
                         || ' as select /*+ORDERED*/ ';
            END IF;

            l_stmt :=    l_stmt
                      || g_fk_table
                      || '.row_id from '
                      || g_fk_table
                      || ','
                      || g_fact_dims (i)
                      || ' where '
                      || g_fact_dims (i)
                      || '.'
                      || g_fact_dims_pk (i)
                      || '='
                      || g_fk_table
                      || '.'
                      || g_fstg_fk (i);

            IF edw_owb_collection_util.drop_table (g_fact_fk_ok_table (i)) =
                                                                         FALSE
            THEN
               NULL;
            END IF;

            IF g_debug
            THEN
               write_to_log_n (   'going to execute '
                               || l_stmt
                               || get_time);
            END IF;

            EXECUTE IMMEDIATE l_stmt;
            l_fk_ok_number := SQL%ROWCOUNT;

            IF g_debug
            THEN
               write_to_log_n (
                     'Created '
                  || g_fact_fk_ok_table (i)
                  || ' with '
                  || l_fk_ok_number
                  || ' rows'
                  || get_time
               );
            END IF;

            edw_owb_collection_util.analyze_table_stats (
               SUBSTR (
                  g_fact_fk_ok_table (i),
                    INSTR (g_fact_fk_ok_table (i), '.')
                  + 1,
                  LENGTH (g_fact_fk_ok_table (i))
               ),
               SUBSTR (
                  g_fact_fk_ok_table (i),
                  1,
                    INSTR (g_fact_fk_ok_table (i), '.')
                  - 1
               )
            );
            l_num_dang :=   g_fstg_total_records
                          - l_fk_ok_number;

            IF g_results_table_flag
            THEN
               IF log_into_cdi_results_table (
                     g_object_name,
                     g_object_type,
                     g_object_id,
                     g_fstg_name,
                     g_fstg_id,
                     NULL,
                     NULL,
                     g_fstg_fk (i), --p_interface_table_fk
                     g_fstg_fk_id (i),
                     g_fact_dims (i), --p_parent_table
                     g_fact_dims_id (i), --p_parent_table_id
                     g_fact_dims_pk (i), --p_parent_table_pk
                     NULL,
                     l_num_dang, --p_number_dangling
                     NULL,
                     NULL,
                     g_fstg_total_records,
                     'DANGLING'
                  ) = FALSE
               THEN
                  RETURN FALSE;
               END IF;
            END IF;

            IF l_num_dang <= 0
            THEN
               write_to_out (' ');
               fnd_message.set_name ('BIS', 'EDW_CDI_NO_DANGLING_KEYS');
               fnd_message.set_token ('FK', g_fstg_fk_long (i));
               write_to_out (fnd_message.get);
            --write_to_out('No Dangling Records found for Foreign Key '||g_fstg_fk_long(i));
            ELSE
               write_to_out (' ');
               fnd_message.set_name ('BIS', 'EDW_CDI_FACT_DANGLING_KEYS');
               fnd_message.set_token ('FK', g_fstg_fk_long (i));
               fnd_message.set_token ('DIM', g_fact_dims_long (i));
               fnd_message.set_token ('PK', g_fact_dims_pk_long (i));
               fnd_message.set_token ('DANG', l_num_dang);
               fnd_message.set_token ('TOTAL', g_fstg_total_records);
               write_to_out (fnd_message.get);

               --write_to_out('For Foreign Key '||g_fstg_fk_long(i));
               --write_to_out('Parent Dimension '||g_fact_dims_long(i));
               --write_to_out('Primary Key '||g_fact_dims_pk_long(i));
               --write_to_out(l_num_dang||' out of '||g_fstg_total_records||' records are dangling');
               IF g_sample_on
               THEN
                  l_stmt :=    'create table '
                            || g_fact_fk_dang_rowid_table (i)
                            || ' tablespace '
                            || g_op_table_space;

                  IF g_parallel IS NOT NULL
                  THEN
                     l_stmt :=
                             l_stmt
                          || ' parallel (degree '
                          || g_parallel
                          || ') ';
                  END IF;

                  l_stmt :=    l_stmt
                            || ' as select row_id from '
                            || g_fact_pk_table
                            || ' MINUS select row_id from '
                            || g_fact_fk_ok_table (i);

                  IF edw_owb_collection_util.drop_table (
                        g_fact_fk_dang_rowid_table (i)
                     ) = FALSE
                  THEN
                     NULL;
                  END IF;

                  IF g_debug
                  THEN
                     write_to_log_n (
                           'going to execute '
                        || l_stmt
                        || get_time
                     );
                  END IF;

                  EXECUTE IMMEDIATE l_stmt;

                  IF g_debug
                  THEN
                     write_to_log_n (
                           'Created '
                        || g_fact_fk_dang_rowid_table (i)
                        || ' with '
                        || SQL%ROWCOUNT
                        || ' rows'
                        || get_time
                     );
                  END IF;

                  edw_owb_collection_util.analyze_table_stats (
                     SUBSTR (
                        g_fact_fk_dang_rowid_table (i),
                          INSTR (g_fact_fk_dang_rowid_table (i), '.')
                        + 1,
                        LENGTH (g_fact_fk_dang_rowid_table (i))
                     ),
                     SUBSTR (
                        g_fact_fk_dang_rowid_table (i),
                        1,
                          INSTR (g_fact_fk_dang_rowid_table (i), '.')
                        - 1
                     )
                  );
                  l_stmt :=    'select /*+ORDERED*/ '
                            || g_fk_table
                            || '.'
                            || g_fstg_fk (i);

                  IF g_fstg_instance_col IS NOT NULL
                  THEN
                     l_stmt :=    l_stmt
                               || ','
                               || g_fk_table
                               || '.'
                               || g_fstg_instance_col;
                  END IF;

                  l_stmt :=    l_stmt
                            || ', count(1) from '
                            || g_fact_fk_dang_rowid_table (i)
                            || ','
                            || g_fk_table
                            || ' where '
                            || g_fk_table
                            || '.row_id='
                            || g_fact_fk_dang_rowid_table (i)
                            || '.row_id group by '
                            || g_fk_table
                            || '.'
                            || g_fstg_fk (i);

                  IF g_fstg_instance_col IS NOT NULL
                  THEN
                     l_stmt :=    l_stmt
                               || ','
                               || g_fk_table
                               || '.'
                               || g_fstg_instance_col;
                  END IF;

                  l_stmt :=    l_stmt
                            || ' order by count(1) desc';

                  IF g_debug
                  THEN
                     write_to_log_n (
                           'going to execute '
                        || l_stmt
                        || get_time
                     );
                  END IF;

                  OPEN cv FOR l_stmt;
                  l_number_dang_str := 1;
                  write_to_out ('  ');
                  fnd_message.set_name ('BIS', 'EDW_CDI_SAMPLE_DANGLING');
                  write_to_out (fnd_message.get);
                  --write_to_out('Sample Dangling Records and their count ');
                  l_dang_instance (1) := NULL;

                  LOOP
                     IF g_fstg_instance_col IS NOT NULL
                     THEN
                        FETCH cv INTO l_dang_str (1),
                                      l_dang_instance (1),
                                      l_dang_count (1);
                     ELSE
                        FETCH cv INTO l_dang_str (1), l_dang_count (1);
                     END IF;

                     EXIT WHEN cv%NOTFOUND;

                     IF      g_number_max_sample IS NOT NULL
                         AND l_number_dang_str > g_number_max_sample
                     THEN
                        EXIT;
                     END IF;

                     IF log_into_cdi_dang_table (
                           g_fstg_fk_id (i),
                           g_fstg_id,
                           g_fact_dims_id (i),
                           l_dang_str (1),
                           l_dang_count (1),
                           l_dang_instance (1)
                        ) = FALSE
                     THEN
                        RETURN FALSE;
                     END IF;

                     IF l_number_dang_str <= g_number_sample
                     THEN
                        IF g_fstg_instance_col IS NOT NULL
                        THEN
                           write_to_out (
                                 l_dang_str (1)
                              || ' ('
                              || l_dang_instance (1)
                              || ') ('
                              || l_dang_count (1)
                              || ')'
                           );
                        ELSE
                           write_to_out (
                                 l_dang_str (1)
                              || ' ('
                              || l_dang_count (1)
                              || ')'
                           );
                        END IF;
                     END IF;

                     l_number_dang_str :=   l_number_dang_str
                                          + 1;
                  END LOOP;

                  write_to_out (' ');
                  CLOSE cv;

                  IF g_debug
                  THEN
                     write_to_log_n (get_time);
                  END IF;

                  IF edw_owb_collection_util.drop_table (
                        g_fact_fk_dang_rowid_table (i)
                     ) = FALSE
                  THEN
                     NULL;
                  END IF;
               END IF; --if g_sample_on
            END IF;

            --create the dang rowid table
            IF edw_owb_collection_util.drop_table (g_fact_fk_ok_table (i)) =
                                                                         FALSE
            THEN
               NULL;
            END IF;
         END IF; --if g_fk_check_flag(i) then
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_fact_dangling_check;

   FUNCTION execute_fstg_makeit_stmt (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt            VARCHAR2 (30000);

      TYPE curtyp IS REF CURSOR;

      cv                curtyp;
      l_number_makeit   NUMBER;
   BEGIN
      l_stmt :=    'select nvl(count(1),0) from '
                || g_fk_table
                || ' A ';

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         l_stmt :=    l_stmt
                   || ','
                   || g_fact_dims (i)
                   || ' B'
                   || i
                   || ' ';
      END LOOP;

      l_stmt :=    l_stmt
                || ' where 1=1 ';

      IF g_duplicate_check
      THEN
         l_stmt :=    l_stmt
                   || ' and A.'
                   || g_fstg_pk
                   || ' in (select '
                   || g_fstg_pk
                   || ' from '
                   || g_fk_table
                   || ' having count('
                   || g_fstg_pk
                   || ') = 1 group by '
                   || g_fstg_pk
                   || ') ';
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         l_stmt :=    l_stmt
                   || ' and A.'
                   || g_fstg_fk (i)
                   || ' = B'
                   || i
                   || '.'
                   || g_fact_dims_pk (i)
                   || ' ';
      END LOOP;

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      OPEN cv FOR l_stmt;
      FETCH cv INTO l_number_makeit;
      CLOSE cv;

      IF g_debug
      THEN
         write_to_log_n (get_time);
      END IF;

      write_to_out ('        ');
      fnd_message.set_name ('BIS', 'EDW_CDI_RECORDS_INTO_FACT');
      fnd_message.set_token ('RECORDS', l_number_makeit);
      fnd_message.set_token ('TOTAL', g_fstg_total_records);
      write_to_out (fnd_message.get);
      --write_to_out_n('The total number of records in the fact interface');
      --write_to_out('table that will make it into the WH');
      --write_to_out(l_number_makeit||' out of '||g_fstg_total_records);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END execute_fstg_makeit_stmt;

   FUNCTION generate_fk_table (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt    VARCHAR2 (30000);
      l_owner   VARCHAR2 (400);
      l_col     VARCHAR2 (400);
   BEGIN
      l_owner := edw_owb_collection_util.get_table_owner (g_fstg_name);
      g_fk_table :=    g_bis_owner
                    || '.'
                    || SUBSTR (p_fact_name, 1, 26)
                    || 'CS';

      IF edw_owb_collection_util.drop_table (g_fk_table) = FALSE
      THEN
         NULL;
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

      l_stmt :=
              'create table '
           || g_fk_table
           || ' tablespace '
           || g_op_table_space;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel (degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=    l_stmt
                || ' as select ';

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' /*+PARELLEL('
                   || g_fstg_name
                   || ','
                   || g_parallel
                   || ')*/ ';
      END IF;

      FOR i IN 1 .. g_number_fstg_fk
      LOOP
         IF g_fk_check_flag (i)
         THEN
            l_stmt :=    l_stmt
                      || g_fstg_fk (i)
                      || ',';
         END IF;
      END LOOP;

      l_stmt :=    l_stmt
                || g_fstg_pk
                || ',rowid row_id,'
                || l_col
                || ' col ';
      l_stmt :=
               l_stmt
            || ' from '
            || g_fstg_name
            || ' where collection_status in (''READY'',''DANGLING'',''DUPLICATE'')';

      BEGIN
         IF g_debug
         THEN
            write_to_log_n (   'Going to execute '
                            || l_stmt
                            || get_time);
         END IF;

         EXECUTE IMMEDIATE l_stmt;

         IF g_debug
         THEN
            write_to_log_n (
                  'Created '
               || g_fk_table
               || ' with '
               || SQL%ROWCOUNT
               || ' rows'
               || get_time
            );
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            write_to_log_n (
                  'Error creating table '
               || g_fk_table
               || ' '
               || SQLERRM
            );
            g_status_message := SQLERRM;
            RETURN FALSE;
      END;

      edw_owb_collection_util.analyze_table_stats (
         SUBSTR (g_fk_table,   INSTR (g_fk_table, '.')
                             + 1, LENGTH (g_fk_table)),
         SUBSTR (g_fk_table, 1,   INSTR (g_fk_table, '.')
                                - 1)
      );
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END generate_fk_table;

   PROCEDURE clean_up
   IS
   BEGIN
      IF edw_owb_collection_util.drop_table (g_fk_table) = FALSE
      THEN
         NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
   END clean_up;

   FUNCTION get_fk_to_check (p_fk_to_check IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_start   NUMBER;
      l_end     NUMBER;
      l_len     NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (
               'In get_fk_to_check p_fk_to_check='
            || p_fk_to_check
         );
      END IF;

      IF p_fk_to_check IS NULL
      THEN
         RETURN TRUE;
      END IF;

      l_len := LENGTH (p_fk_to_check);

      IF INSTR (p_fk_to_check, ',') = 0
      THEN
         g_number_fk_to_check := 1;
         g_fk_to_check (1) := p_fk_to_check;
         RETURN TRUE;
      END IF;

      l_start := 1;
      l_end := 1;

      LOOP
         l_end := INSTR (p_fk_to_check, ',', l_start);

         IF l_end = 0
         THEN
            l_end :=   LENGTH (p_fk_to_check)
                     + 1;
         END IF;

         g_number_fk_to_check :=   g_number_fk_to_check
                                 + 1;
         g_fk_to_check (g_number_fk_to_check) :=
                            SUBSTR (p_fk_to_check, l_start,   l_end
                                                            - l_start);
         l_start :=   l_end
                    + 1;

         IF l_start > l_len
         THEN
            EXIT;
         END IF;
      END LOOP;

      IF g_debug
      THEN
         write_to_log_n ('FKs to check');

         FOR i IN 1 .. g_number_fk_to_check
         LOOP
            write_to_log (g_fk_to_check (i));
         END LOOP;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_out_log_n (SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END get_fk_to_check;

   FUNCTION log_into_cdi_results_table (
      p_object                  IN   VARCHAR2,
      p_object_type             IN   VARCHAR2,
      p_object_id               IN   NUMBER,
      p_interface_table         IN   VARCHAR2,
      p_interface_table_id      IN   NUMBER,
      p_interface_table_pk      IN   VARCHAR2,
      p_interface_table_pk_id   IN   NUMBER,
      p_interface_table_fk      IN   VARCHAR2,
      p_interface_table_fk_id   IN   NUMBER,
      p_parent_table            IN   VARCHAR2,
      p_parent_table_id         IN   NUMBER,
      p_parent_table_pk         IN   VARCHAR2,
      p_parent_table_pk_id      IN   NUMBER,
      p_number_dangling         IN   NUMBER,
      p_number_duplicate        IN   NUMBER,
      p_number_error            IN   NUMBER,
      p_total_records           IN   NUMBER,
      p_error_type              IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
   BEGIN
      IF edw_owb_collection_util.log_into_cdi_results_table (
            p_object,
            p_object_type,
            p_object_id,
            p_interface_table,
            p_interface_table_id,
            p_interface_table_pk,
            p_interface_table_pk_id,
            p_interface_table_fk,
            p_interface_table_fk_id,
            p_parent_table,
            p_parent_table_id,
            p_parent_table_pk,
            p_parent_table_pk_id,
            p_number_dangling,
            p_number_duplicate,
            p_number_error,
            p_total_records,
            p_error_type
         ) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (   'Error in log_into_cdi_results_table '
                         || SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END log_into_cdi_results_table;

   FUNCTION delete_cdi_results_table (p_object_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt       VARCHAR2 (2000);
      l_table_id   NUMBER;

      TYPE curtyp IS REF CURSOR;

      cv           curtyp;
   BEGIN
      l_stmt :=
            'select distinct interface_table_id from EDW_CDI_RESULTS where object_name=:a';

      IF g_debug
      THEN
         write_to_log_n (
               'Going to execute '
            || l_stmt
            || ' using '
            || p_object_name
         );
      END IF;

      OPEN cv FOR l_stmt USING p_object_name;

      LOOP
         FETCH cv INTO l_table_id;
         EXIT WHEN cv%NOTFOUND;
         l_stmt := 'delete EDW_CDI_KEY_VALUES where table_id=:a';

         IF g_debug
         THEN
            write_to_log_n (
                  'Going to execute '
               || l_stmt
               || ' using '
               || l_table_id
            );
         END IF;

         EXECUTE IMMEDIATE l_stmt USING l_table_id;
         COMMIT;
      END LOOP;

      l_stmt :=    'delete '
                || g_results_table
                || ' where object_name=:a';

      IF g_debug
      THEN
         write_to_log_n (
               'Going to execute '
            || l_stmt
            || ' using '
            || p_object_name
         );
      END IF;

      EXECUTE IMMEDIATE l_stmt USING p_object_name;
      COMMIT;
      l_table_id := edw_owb_collection_util.get_object_id (p_object_name);
      l_stmt := 'delete edw_cdi_dim_missing_keys where fact_id=:a';

      IF g_debug
      THEN
         write_to_log_n (
               'Going to execute '
            || l_stmt
            || ' using '
            || l_table_id
         );
      END IF;

      EXECUTE IMMEDIATE l_stmt USING l_table_id;
      COMMIT;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (   'Error in delete_cdi_results_table '
                         || SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END delete_cdi_results_table;

   FUNCTION log_into_cdi_dang_table (
      p_key_id             IN   NUMBER,
      p_table_id           IN   NUMBER,
      p_parent_table_id    IN   NUMBER,
      p_key_value          IN   VARCHAR2,
      p_number_key_value   IN   NUMBER,
      p_instance           IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
   BEGIN
      IF edw_owb_collection_util.log_into_cdi_dang_table (
            p_key_id,
            p_table_id,
            p_parent_table_id,
            p_key_value,
            p_number_key_value,
            p_instance,
            'N'
         ) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         write_to_log_n (   'Error in log_into_cdi_dang_table '
                         || SQLERRM);
         g_status_message := SQLERRM;
         RETURN FALSE;
   END log_into_cdi_dang_table;


/*
this is meant to consolidate all dang dim values when there are multiple keys pointing to the same dim
*/
   FUNCTION create_g_dim_missing_keys_op (p_object_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt     VARCHAR2 (10000);
      l_object   VARCHAR2 (100);
      l_count    NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (   'In create_g_dim_missing_keys_op'
                         || get_time);
      END IF;

      l_object := SUBSTR (p_object_name, 1, 28);
      g_dim_missing_keys_op :=    g_bis_owner
                               || '.'
                               || l_object
                               || 'M';
      l_stmt :=    'create table '
                || g_dim_missing_keys_op
                || ' tablespace '
                || g_op_table_space;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel (degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=    l_stmt
                || ' as select ';

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || '/*+PARALLEL(B,'
                   || g_parallel
                   || ')*/ ';
      END IF;

      l_stmt :=
               l_stmt
            || ' A.parent_table_id,B.key_value,sum(B.number_key_value) number_key_value,B.instance '
            || 'from edw_cdi_results A,edw_cdi_key_values B '
            || 'where  '
            || 'A.interface_table_fk_id=B.key_id '
            || 'and A.parent_table_id=B.parent_table_id '
            || 'and A.object_name='''
            || p_object_name
            || ''' '
            || 'group by A.parent_table_id,B.key_value,B.instance ';

      IF edw_owb_collection_util.drop_table (g_dim_missing_keys_op) = FALSE
      THEN
         NULL;
      END IF;

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      EXECUTE IMMEDIATE l_stmt;
      l_count := SQL%ROWCOUNT;

      IF g_debug
      THEN
         write_to_log_n (
               'Created '
            || g_dim_missing_keys_op
            || ' with '
            || l_count
            || ' rows '
            || get_time
         );
      END IF;

      edw_owb_collection_util.analyze_table_stats (
         SUBSTR (
            g_dim_missing_keys_op,
              INSTR (g_dim_missing_keys_op, '.')
            + 1,
            LENGTH (g_dim_missing_keys_op)
         ),
         SUBSTR (
            g_dim_missing_keys_op,
            1,
              INSTR (g_dim_missing_keys_op, '.')
            - 1
         )
      );
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status_message := SQLERRM;
         write_to_log_n (g_status_message);
         RETURN FALSE;
   END create_g_dim_missing_keys_op;

   FUNCTION process_dang_keys (p_fact IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt                    VARCHAR2 (8000);

      TYPE curtyp IS REF CURSOR;

      cv                        curtyp;
      l_dang_dim                edw_owb_collection_util.varchartabletype;
      l_dang_dim_id             edw_owb_collection_util.numbertabletype;
      l_number_dang_dim         NUMBER;
      l_fact_id                 NUMBER;
      l_instances               edw_owb_collection_util.varchartabletype;
      l_instances_name          edw_owb_collection_util.l_varchartabletype;
      l_wh_apps_links           edw_owb_collection_util.varchartabletype;
      l_number_instances        NUMBER;
      l_dang_dim_instance_id    edw_owb_collection_util.numbertabletype;
      --which dims in which instances have dang values
      l_dang_instances          edw_owb_collection_util.varchartabletype;
      --the instances where dims have dang
      l_number_dang_instances   NUMBER;
      l_index                   NUMBER;
      l_fact_list               VARCHAR2 (1000);
      l_dim_list                VARCHAR2 (32000);
      l_status                  NUMBER;
      l_prev_instance           VARCHAR2 (400);
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (   'In process_dang_keys '
                         || get_time);
      END IF;

      IF create_g_dim_missing_keys_op (p_fact) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      l_stmt :=
               'select NAME,INSTANCE_CODE,WAREHOUSE_TO_INSTANCE_LINK from edw_source_instances '
            || 'where ENABLED_FLAG=''Y''';

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      l_number_instances := 1;
      OPEN cv FOR l_stmt;

      LOOP
         FETCH cv INTO l_instances_name (l_number_instances),
                       l_instances (l_number_instances),
                       l_wh_apps_links (l_number_instances);
         EXIT WHEN cv%NOTFOUND;
         l_number_instances :=   l_number_instances
                               + 1;
      END LOOP;

      l_number_instances :=   l_number_instances
                            - 1;
      CLOSE cv;

      IF g_debug
      THEN
         write_to_log_n ('The instances');

         FOR i IN 1 .. l_number_instances
         LOOP
            write_to_log (
                  l_instances_name (i)
               || '('
               || l_instances (i)
               || ' with link '
               || l_wh_apps_links (i)
               || ')'
            );
         END LOOP;
      END IF;

      l_number_dang_dim := 1;
      l_stmt :=
               'select distinct parent_table,parent_table_id from edw_cdi_results where number_dangling>0 '
            || 'and object_name=:a';

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      OPEN cv FOR l_stmt USING p_fact;

      LOOP
         FETCH cv INTO l_dang_dim (l_number_dang_dim),
                       l_dang_dim_id (l_number_dang_dim);
         EXIT WHEN cv%NOTFOUND;
         l_number_dang_dim :=   l_number_dang_dim
                              + 1;
      END LOOP;

      CLOSE cv;
      l_number_dang_dim :=   l_number_dang_dim
                           - 1;

      IF g_debug
      THEN
         write_to_log_n ('The dimension with dang rows ');

         FOR i IN 1 .. l_number_dang_dim
         LOOP
            write_to_log (   l_dang_dim (i)
                          || '('
                          || l_dang_dim_id (i)
                          || ')');
         END LOOP;
      END IF;

      --find which dims from which instances are dangling
      l_number_dang_instances := 1;
      l_stmt :=    'select distinct parent_table_id,instance from '
                || g_dim_missing_keys_op
                || ' order by instance';

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      OPEN cv FOR l_stmt;

      LOOP
         FETCH cv INTO l_dang_dim_instance_id (l_number_dang_instances),
                       l_dang_instances (l_number_dang_instances);
         EXIT WHEN cv%NOTFOUND;
         l_number_dang_instances :=   l_number_dang_instances
                                    + 1;
      END LOOP;

      l_number_dang_instances :=   l_number_dang_instances
                                 - 1;

      IF g_debug
      THEN
         write_to_log_n (   'Results'
                         || get_time);

         FOR i IN 1 .. l_number_dang_instances
         LOOP
            write_to_log (
                  l_dang_dim_instance_id (i)
               || '  '
               || l_dang_instances (i)
            );
         END LOOP;
      END IF;

      l_fact_id := edw_owb_collection_util.get_object_id (p_fact);

      FOR j IN 1 .. l_number_dang_instances
      LOOP
         l_index :=
               edw_owb_collection_util.index_in_table (
                  l_instances,
                  l_number_instances,
                  l_dang_instances (j)
               );

         IF l_index > 0
         THEN
            IF    l_prev_instance IS NULL
               OR l_prev_instance <> l_dang_instances (j)
            THEN
               fnd_message.set_name ('BIS', 'EDW_CDI_MDR_INSTANCE');
               fnd_message.set_token ('INSTANCE', l_instances_name (l_index));
               write_to_out_n (fnd_message.get);
               write_to_log_n (
                     'Missing Date Range for Instance '
                  || l_instances_name (l_index)
                  || '('
                  || l_dang_instances (j)
                  || ')'
               );
               l_prev_instance := l_dang_instances (j);
            END IF;

            FOR i IN 1 .. l_number_dang_dim
            LOOP
               IF l_dang_dim_instance_id (j) = l_dang_dim_id (i)
               THEN
                  IF find_missing_date_range (
                        p_fact,
                        l_fact_id,
                        l_dang_dim (i),
                        l_dang_dim_id (i),
                        l_dang_instances (j),
                        l_wh_apps_links (l_index)
                     ) = FALSE
                  THEN
                     RETURN FALSE;
                  END IF;
               END IF;
            END LOOP;
         ELSE
            write_to_log_n (
                  'Instance '
               || l_dang_instances (j)
               || ' is not present in source instances'
            );
         END IF;
      END LOOP;

      l_fact_list := p_fact;
      l_dim_list := NULL;

      --find the bad records
      FOR i IN 1 .. l_number_dang_dim
      LOOP
         l_status := create_bad_key_tables (
                        p_fact,
                        l_fact_id,
                        l_dang_dim (i),
                        l_dang_dim_id (i),
                        l_dang_dim_instance_id,
                        l_dang_instances,
                        l_number_dang_instances
                     );

         IF l_status = -1
         THEN
            RETURN FALSE;
         END IF;

         IF l_status = 1
         THEN
            l_dim_list :=    l_dim_list
                          || l_dang_dim (i)
                          || ',';
         END IF;
      --if l_status=0 then do not pass this dim for checking error tables
      END LOOP;

      IF edw_owb_collection_util.drop_table (g_dim_missing_keys_op) = FALSE
      THEN
         NULL;
      END IF;

      IF l_status = 1
      THEN
         edw_wh_dang_recovery.load_error_table (
            l_fact_list,
            l_dim_list,
            g_op_table_space,
            g_parallel,
            g_bis_owner,
            NULL, --p_instance,
            g_debug,
            'CDI', --p_mode
            'CDI', --p_called_from
            g_fk_table
         );

         IF edw_wh_dang_recovery.g_status = FALSE
         THEN
            g_status_message := edw_wh_dang_recovery.g_status_message;
            RETURN FALSE;
         END IF;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status_message := SQLERRM;
         write_to_log_n (g_status_message);
         RETURN FALSE;
   END process_dang_keys;

   FUNCTION find_missing_date_range (
      p_fact            IN   VARCHAR2,
      p_fact_id         IN   NUMBER,
      p_dim             IN   VARCHAR2,
      p_dim_id          IN   NUMBER,
      p_instance        IN   VARCHAR2,
      p_instance_link   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      l_view        VARCHAR2 (200);
      l_min_date    DATE;
      l_max_date    DATE;
      l_long_name   VARCHAR2 (400);
   BEGIN
      l_view := edw_owb_collection_util.get_pk_view (p_dim, p_instance_link);
      l_long_name := edw_owb_collection_util.get_logical_name (p_dim_id);

      IF l_view IS NULL
      THEN
         --write_to_out_n('Dimension '||l_long_name);
         fnd_message.set_name ('BIS', 'EDW_CDI_MDR_PK_VIEW_NOT_FOUND');
         fnd_message.set_token ('DIM', l_long_name);
         fnd_message.set_token ('PK_VIEW', l_view);
         write_to_out (fnd_message.get);
         --write_to_out('Primary Key View '||l_view||' not found in source database');
         RETURN TRUE;
      END IF;

      IF find_missing_date_range (
            p_fact,
            p_fact_id,
            p_dim,
            p_dim_id,
            p_instance,
            p_instance_link,
            l_view,
            l_min_date,
            l_max_date
         ) = FALSE
      THEN
         RETURN FALSE;
      END IF;

      fnd_message.set_name ('BIS', 'EDW_CDI_DIM_NAME');
      fnd_message.set_token ('DIM', l_long_name);
      write_to_out_n (fnd_message.get);
      write_to_log_n (   'Dimension '
                      || l_long_name);

      IF l_min_date IS NOT NULL
      THEN
         fnd_message.set_name ('BIS', 'EDW_CDI_DATE_RANGE');
         fnd_message.set_token (
            'FROM',
            TO_CHAR (l_min_date, 'MM/DD/YYYY HH24:MI:SS')
         );
         fnd_message.set_token (
            'TO',
            TO_CHAR (l_max_date, 'MM/DD/YYYY HH24:MI:SS')
         );
         write_to_out (fnd_message.get);
         write_to_log (
               'From '
            || TO_CHAR (l_min_date, 'MM/DD/YYYY HH24:MI:SS')
            || ' To '
            || TO_CHAR (l_max_date, 'MM/DD/YYYY HH24:MI:SS')
         );
      ELSE
         fnd_message.set_name ('BIS', 'EDW_CDI_NO_DATE_RANGE');
         write_to_out (fnd_message.get);
         write_to_log (
            'From and To Date could not be determined as no match was found with'
         );
         write_to_log ('the source Primary Key View');
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status_message := SQLERRM;
         write_to_log_n (g_status_message);
         RETURN FALSE;
   END find_missing_date_range;

   FUNCTION find_missing_date_range (
      p_fact            IN       VARCHAR2,
      p_fact_id         IN       NUMBER,
      p_dim             IN       VARCHAR2,
      p_dim_id          IN       NUMBER,
      p_instance        IN       VARCHAR2,
      p_instance_link   IN       VARCHAR2,
      p_view            IN       VARCHAR2,
      p_min_date        OUT NOCOPY     DATE,
      p_max_date        OUT NOCOPY     DATE
   )
      RETURN BOOLEAN
   IS
      l_stmt    VARCHAR2 (8000);

      TYPE curtyp IS REF CURSOR;

      cv        curtyp;
      l_table   VARCHAR2 (200);
      l_count   NUMBER;
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (
               'In find_missing_date_range p_fact='
            || p_fact
            || ',p_dim='
            || p_dim
            || ',p_instance='
            || p_instance
            || ',link='
            || p_instance_link
            || ',view='
            || p_view
         );
      END IF;

      l_table :=    g_bis_owner
                 || '.D_'
                 || p_instance
                 || '_'
                 || p_fact_id
                 || '_'
                 || p_dim_id;
      --there are dependencies to this name
      l_stmt :=
                 'create table '
              || l_table
              || ' tablespace '
              || g_op_table_space;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel (degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=
               l_stmt
            || ' as select A.rowid row_id,B.dim_pk_date pk_date,A.key_value,A.number_key_value '
            || 'from '
            || g_dim_missing_keys_op
            || ' A,'
            || p_view
            || '@'
            || p_instance_link
            || ' B where '
            || 'A.parent_table_id='
            || p_dim_id
            || ' and A.instance='''
            || p_instance
            || ''' and B.dim_pk=A.key_value';

      IF edw_owb_collection_util.drop_table (l_table) = FALSE
      THEN
         NULL;
      END IF;

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      EXECUTE IMMEDIATE l_stmt;
      l_count := SQL%ROWCOUNT;

      IF g_debug
      THEN
         write_to_log_n (
               'Created '
            || l_table
            || ' with '
            || l_count
            || ' rows '
            || get_time
         );
      END IF;

      l_stmt :=    'select min(pk_date),max(pk_date) from '
                || l_table;

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      OPEN cv FOR l_stmt;
      FETCH cv INTO p_min_date, p_max_date;
      CLOSE cv;

      IF g_debug
      THEN
         write_to_log (
               'Results '
            || TO_CHAR (p_min_date, 'MM/DD/YYYY HH24:MI:SS')
            || '  '
            || TO_CHAR (p_max_date, 'MM/DD/YYYY HH24:MI:SS')
         );
      END IF;

      l_stmt :=
               'insert into edw_cdi_dim_missing_keys(dim_id,fact_id,instance,key_value,number_key_value,'
            || 'missing_date) select '
            || p_dim_id
            || ','
            || p_fact_id
            || ','''
            || p_instance
            || ''',a.key_value,a.number_key_value,'
            || 'b.day_pk_key from '
            || l_table
            || ' a,edw_time_day_ltc b where to_char(a.pk_date,''DD-MM-YYYY'')=b.day_pk';

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      EXECUTE IMMEDIATE l_stmt;

      IF g_debug
      THEN
         write_to_log_n (   'Inserted '
                         || SQL%ROWCOUNT
                         || ' rows '
                         || get_time);
      END IF;

      COMMIT;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status_message := SQLERRM;
         write_to_log_n (g_status_message);
         RETURN FALSE;
   END find_missing_date_range;


/*
return:
-1 error
0 : bad key table not created
1: all ok
*/
   FUNCTION create_bad_key_tables (
      p_fact                    IN   VARCHAR2,
      p_fact_id                 IN   NUMBER,
      p_dang_dim                IN   VARCHAR2,
      p_dang_dim_id             IN   NUMBER,
      p_dang_dim_instance_id    IN   edw_owb_collection_util.numbertabletype,
      p_dang_instances          IN   edw_owb_collection_util.varchartabletype,
      p_number_dang_instances   IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_stmt            VARCHAR2 (20000);
      l_tables          edw_owb_collection_util.varchartabletype;
      l_number_tables   NUMBER;
      l_op_table        VARCHAR2 (200);
      l_rowid_table     VARCHAR2 (200);
      l_bad_table       VARCHAR2 (200);
   BEGIN
      IF g_debug
      THEN
         write_to_log_n (
               'In create_bad_key_tables fact='
            || p_fact
            || ',dim='
            || p_dang_dim
            || get_time
         );
      END IF;

      l_number_tables := 0;
      l_op_table :=
                     g_bis_owner
                  || '.CBKTO_'
                  || p_fact_id
                  || '_'
                  || p_dang_dim_id;
      l_rowid_table :=
                     g_bis_owner
                  || '.CBKTR_'
                  || p_fact_id
                  || '_'
                  || p_dang_dim_id;
      l_bad_table :=
                   g_bis_owner
                || '.B_NOINS_'
                || p_fact_id
                || '_'
                || p_dang_dim_id;

      FOR i IN 1 .. p_number_dang_instances
      LOOP
         IF p_dang_dim_instance_id (i) = p_dang_dim_id
         THEN
            l_number_tables :=   l_number_tables
                               + 1;
            l_tables (l_number_tables) :=    g_bis_owner
                                          || '.D_'
                                          || p_dang_instances (i)
                                          || '_'
                                          || p_fact_id
                                          || '_'
                                          || p_dang_dim_id;

            IF edw_owb_collection_util.check_table (
                  l_tables (l_number_tables)
               ) = FALSE
            THEN
               l_number_tables :=   l_number_tables
                                  - 1;
            END IF;
         --there are dependencies to this name
         END IF;
      END LOOP;

      IF l_number_tables = 0
      THEN
         IF g_debug
         THEN
            write_to_log_n ('There are no tables to find bad keys');
         END IF;

         RETURN 0;
      END IF;

      l_stmt :=
              'create table '
           || l_op_table
           || ' tablespace '
           || g_op_table_space;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel (degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=    l_stmt
                || ' as ';

      FOR i IN 1 .. l_number_tables
      LOOP
         l_stmt :=
                  l_stmt
               || 'select row_id from '
               || l_tables (i)
               || ' UNION ALL ';
      END LOOP;

      l_stmt := SUBSTR (l_stmt, 1,   LENGTH (l_stmt)
                                   - 10);

      IF edw_owb_collection_util.drop_table (l_op_table) = FALSE
      THEN
         NULL;
      END IF;

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      EXECUTE IMMEDIATE l_stmt;

      IF g_debug
      THEN
         write_to_log_n (
               'Created '
            || l_op_table
            || ' with '
            || SQL%ROWCOUNT
            || ' rows '
            || get_time
         );
      END IF;

      l_stmt :=    'create table '
                || l_rowid_table
                || ' tablespace '
                || g_op_table_space;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel (degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=    l_stmt
                || ' as select rowid row_id from '
                || g_dim_missing_keys_op
                || ' where '
                || 'parent_table_id='
                || p_dang_dim_id
                || ' MINUS select row_id from '
                || l_op_table;

      IF edw_owb_collection_util.drop_table (l_rowid_table) = FALSE
      THEN
         NULL;
      END IF;

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      EXECUTE IMMEDIATE l_stmt;

      IF g_debug
      THEN
         write_to_log_n (
               'Created '
            || l_rowid_table
            || ' with '
            || SQL%ROWCOUNT
            || ' rows '
            || get_time
         );
      END IF;

      IF edw_owb_collection_util.drop_table (l_op_table) = FALSE
      THEN
         NULL;
      END IF;

      l_stmt :=
             'create table '
          || l_bad_table
          || ' tablespace '
          || g_op_table_space;

      IF g_parallel IS NOT NULL
      THEN
         l_stmt :=    l_stmt
                   || ' parallel (degree '
                   || g_parallel
                   || ') ';
      END IF;

      l_stmt :=
               l_stmt
            || ' as select /*+ORDERED*/ A.key_value,A.instance from '
            || l_rowid_table
            || ' B, '
            || g_dim_missing_keys_op
            || ' A where B.row_id=A.rowid';

      IF g_debug
      THEN
         write_to_log_n (   'Going to execute '
                         || l_stmt
                         || get_time);
      END IF;

      IF edw_owb_collection_util.drop_table (l_bad_table) = FALSE
      THEN
         NULL;
      END IF;

      EXECUTE IMMEDIATE l_stmt;

      IF g_debug
      THEN
         write_to_log_n (
               'Created '
            || l_bad_table
            || ' with '
            || SQL%ROWCOUNT
            || ' rows '
            || get_time
         );
      END IF;

      IF edw_owb_collection_util.drop_table (l_rowid_table) = FALSE
      THEN
         NULL;
      END IF;

      FOR i IN 1 .. l_number_tables
      LOOP
         IF edw_owb_collection_util.drop_table (l_tables (i)) = FALSE
         THEN
            NULL;
         END IF;
      END LOOP;

      RETURN 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status_message := SQLERRM;
         write_to_log_n (g_status_message);
         RETURN -1;
   END create_bad_key_tables;
END edw_check_data_integrity;

/
