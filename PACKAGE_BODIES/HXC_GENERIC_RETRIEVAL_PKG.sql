--------------------------------------------------------
--  DDL for Package Body HXC_GENERIC_RETRIEVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_GENERIC_RETRIEVAL_PKG" AS
/* $Header: hxcgnret.pkb 120.22.12010000.19 2010/05/12 12:00:52 asrajago ship $ */

   -- global package data type and variables
   TYPE r_parameters IS RECORD (
      p_process             hxc_retrieval_processes.NAME%TYPE,
      p_transaction_code    hxc_transactions.transaction_code%TYPE,
      p_start_date          DATE,
      p_end_date            DATE,
      p_incremental         VARCHAR2 (1),
      p_rerun_flag          VARCHAR2 (1),
      p_where_clause        VARCHAR2 (3000),
      p_scope               VARCHAR2 (10),
      p_clusive             VARCHAR2 (2),
      p_unique_params       VARCHAR2 (2000),
      transfer_batch_size   NUMBER,
      retrieval_options     VARCHAR2 (10),
      since_date            DATE,
      l_using_dates         BOOLEAN
   );

   g_params                        r_parameters;
   glb_debug                       BOOLEAN                 := FALSE;
   g_debug                         BOOLEAN         := hr_utility.debug_enabled;
                           -- Used for conditionally enabling hr_utility calls
-- variables for storing the old bld blk information
   t_old_time_seq                  DBMS_SQL.number_table;
   t_old_day_seq                   DBMS_SQL.number_table;
   t_old_detail_seq                DBMS_SQL.number_table;
   t_old_time_bb_id                DBMS_SQL.number_table;
   t_old_day_bb_id                 DBMS_SQL.number_table;
   t_old_detail_bb_id              DBMS_SQL.number_table;
   t_old_time_ovn                  DBMS_SQL.number_table;
   t_old_day_ovn                   DBMS_SQL.number_table;
   t_old_detail_ovn                DBMS_SQL.number_table;
-- dynamic SQL arrays
   t_timecard_bb_id                DBMS_SQL.number_table;
   t_timecard_ovn                  DBMS_SQL.number_table;
   t_timecard_max_ovn              DBMS_SQL.number_table;
   t_timecard_start_time           DBMS_SQL.date_table;
   t_timecard_stop_time            DBMS_SQL.date_table;
   t_timecard_comment_text         DBMS_SQL.varchar2_table;
   t_timecard_deleted              DBMS_SQL.varchar2_table;
   t_day_bb_id                     DBMS_SQL.number_table;
   t_day_ovn                       DBMS_SQL.number_table;
   t_day_start_time                DBMS_SQL.date_table;
   t_day_stop_time                 DBMS_SQL.date_table;
   t_day_max_ovn                   DBMS_SQL.number_table;
   t_detail_bb_id                  DBMS_SQL.number_table;
   t_detail_parent_id              DBMS_SQL.number_table;
   t_detail_resource_type          DBMS_SQL.varchar2_table;
   t_detail_resource_id            DBMS_SQL.number_table;
   t_detail_comment_text           DBMS_SQL.varchar2_table;
   t_detail_start_time             DBMS_SQL.date_table;
   t_detail_stop_time              DBMS_SQL.date_table;
   t_detail_measure                DBMS_SQL.number_table;
   t_detail_scope                  DBMS_SQL.varchar2_table;
   t_detail_type                   DBMS_SQL.varchar2_table;
   t_detail_ta_id                  DBMS_SQL.number_table;
   t_detail_bld_blk_info_type_id   DBMS_SQL.number_table;
   t_detail_attribute1             DBMS_SQL.varchar2_table;
   t_detail_attribute2             DBMS_SQL.varchar2_table;
   t_detail_attribute3             DBMS_SQL.varchar2_table;
   t_detail_attribute4             DBMS_SQL.varchar2_table;
   t_detail_attribute5             DBMS_SQL.varchar2_table;
   t_detail_attribute6             DBMS_SQL.varchar2_table;
   t_detail_attribute7             DBMS_SQL.varchar2_table;
   t_detail_attribute8             DBMS_SQL.varchar2_table;
   t_detail_attribute9             DBMS_SQL.varchar2_table;
   t_detail_attribute10            DBMS_SQL.varchar2_table;
   t_detail_attribute11            DBMS_SQL.varchar2_table;
   t_detail_attribute12            DBMS_SQL.varchar2_table;
   t_detail_attribute13            DBMS_SQL.varchar2_table;
   t_detail_attribute14            DBMS_SQL.varchar2_table;
   t_detail_attribute15            DBMS_SQL.varchar2_table;
   t_detail_attribute16            DBMS_SQL.varchar2_table;
   t_detail_attribute17            DBMS_SQL.varchar2_table;
   t_detail_attribute18            DBMS_SQL.varchar2_table;
   t_detail_attribute19            DBMS_SQL.varchar2_table;
   t_detail_attribute20            DBMS_SQL.varchar2_table;
   t_detail_attribute21            DBMS_SQL.varchar2_table;
   t_detail_attribute22            DBMS_SQL.varchar2_table;
   t_detail_attribute23            DBMS_SQL.varchar2_table;
   t_detail_attribute24            DBMS_SQL.varchar2_table;
   t_detail_attribute25            DBMS_SQL.varchar2_table;
   t_detail_attribute26            DBMS_SQL.varchar2_table;
   t_detail_attribute27            DBMS_SQL.varchar2_table;
   t_detail_attribute28            DBMS_SQL.varchar2_table;
   t_detail_attribute29            DBMS_SQL.varchar2_table;
   t_detail_attribute30            DBMS_SQL.varchar2_table;
   t_detail_attribute_category     DBMS_SQL.varchar2_table;
   t_detail_ovn                    DBMS_SQL.number_table;
   t_detail_max_ovn                DBMS_SQL.number_table;
   t_detail_deleted                DBMS_SQL.varchar2_table;
   t_detail_uom                    DBMS_SQL.varchar2_table;
   t_detail_date_from              DBMS_SQL.date_table;
   t_detail_date_to                DBMS_SQL.date_table;
   t_detail_approval_status        DBMS_SQL.varchar2_table;
   t_detail_approval_style_id      DBMS_SQL.number_table;

-- time attribute types
   TYPE tab_ta_fk_bb_id IS TABLE OF hxc_time_building_blocks.time_building_block_id%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE tab_ta_field_name IS TABLE OF hxc_mapping_components.field_name%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE tab_ta_attribute IS TABLE OF hxc_time_attributes.attribute1%TYPE
      INDEX BY BINARY_INTEGER;

-- global package variable in order to reference table.LAST in the procedure populate_attribute
   t_attribute_fk_bb_id            tab_ta_fk_bb_id;
   l_pkg_range_start               NUMBER;
   l_pkg_range_stop                NUMBER;
   l_pkg_retrieval_range_id        NUMBER (15);
   l_alter_session                 VARCHAR2 (50);
   e_no_ranges                     EXCEPTION;

-- package cursor
   CURSOR csr_get_tx_id
   IS
      SELECT hxc_transactions_s.NEXTVAL
        FROM SYS.DUAL;

   -- Bug 9346163
   -- Rewrote the cursor to pick nextval(s) from the sequence.
   -- The old cursor would not return values in case the table in the FROM
   -- clause is empty. While it is a bad idea to use a physical table
   -- in such a case, using a transactional table is asking for trouble.
   -- Dual with Connect by would give the same result and is safe.

   /*
   CURSOR csr_get_tx_detail_id (p_max BINARY_INTEGER)
   IS
      SELECT /*+ INDEX_FFS(TXD HXC_TRANSACTION_DETAILS_PK) *
             hxc_transaction_details_s.NEXTVAL
        FROM hxc_transaction_details txd
       WHERE ROWNUM <= p_max;
   */

   CURSOR csr_get_tx_detail_id (p_max BINARY_INTEGER)
   IS
      SELECT hxc_transaction_details_s.NEXTVAL
        FROM SYS.DUAL
     CONNECT BY LEVEL <= p_max ;

   g_conc_request_id               NUMBER (15);

   PROCEDURE insert_query (p_query LONG
/*PROFILER(457): LONG (advise: migrate to LOB) is Oracle 7.0 (deprecated in 8.1.5) */
                                       , p_type VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DELETE FROM hxc_debug_text
            WHERE process = 'RETRIEVAL' AND TYPE = p_type;

      INSERT INTO hxc_debug_text
                  (process, TYPE, text
                  )
           VALUES ('RETRIEVAL', p_type, p_query
                  );

      COMMIT;
   END insert_query;

   FUNCTION initialise_g_resource (p_resource_id NUMBER)
      RETURN NUMBER
   IS
   BEGIN
-- just in case deterministic is not working use EXISTS
      IF (NOT hxc_generic_retrieval_utils.g_resources.EXISTS (p_resource_id)
         )
      THEN
         hxc_generic_retrieval_utils.g_resources (p_resource_id).resource_id :=
                                                                p_resource_id;
         -- NOTE: these setting are not the wrong way round
         -- need a date for when the first LEAST/GREATEST comparison is done, so we always get the
         -- TC start/stop time
         hxc_generic_retrieval_utils.g_resources (p_resource_id).start_time :=
                                                       hr_general.end_of_time;
         hxc_generic_retrieval_utils.g_resources (p_resource_id).stop_time :=
                                                     hr_general.start_of_time;
      END IF;

      RETURN 1;
   END initialise_g_resource;

   FUNCTION replace_timecard_string (p_where VARCHAR2)
      RETURN VARCHAR2
   IS
      l_where   VARCHAR2 (2000);
   BEGIN
      IF (g_params.p_process = 'Maintenance Retrieval Process')
      THEN
         l_where := REPLACE (p_where, 'TIMECARD_BLOCK', 'tbb_latest');
         l_where := REPLACE (l_where, 'DAY_BLOCK', 'tbb_latest');
         l_where := REPLACE (l_where, 'DETAIL_BLOCK', 'tbb_latest');
      ELSE
         l_where := REPLACE (p_where, 'TIMECARD_BLOCK', 'tbb');
         l_where := REPLACE (l_where, 'DAY_BLOCK', 'tbb');
         l_where := REPLACE (l_where, 'DETAIL_BLOCK', 'tbb');
      END IF;

      RETURN l_where;
   END replace_timecard_string;

-- private procedure
--    parse_it
--
-- description
--    Used to parse the application specific WHERE clause
--    passed to the generic retrieval
--
-- parameters
--   p_where_clause  -  the application specific WHERE clause
   PROCEDURE parse_it (
      p_where_clause_blk   IN OUT NOCOPY   VARCHAR2,
      p_where_clause_att   IN OUT NOCOPY   VARCHAR2
   )
   IS
      l_text   VARCHAR2 (2000);
      l_proc   VARCHAR2 (72);

      PROCEDURE translate_it (
         p_text       IN OUT NOCOPY   VARCHAR2,
         p_text_blk   IN OUT NOCOPY   VARCHAR2,
         p_text_att   IN OUT NOCOPY   VARCHAR2
      )
      IS
--
         l_proc                          VARCHAR2 (72);
         l_start_position                NUMBER (4);
         l_end_position                  NUMBER (4);
         l_new_start_position            NUMBER (4);
         l_absolute_start_position       NUMBER (4);
         l_absolute_end_position         NUMBER (4);
         l_blk_absolute_start_position   NUMBER (4);
         l_blk_absolute_end_position     NUMBER (4);
         l_att_absolute_start_position   NUMBER (4);
         l_att_absolute_end_position     NUMBER (4);
         l_placeholder                   VARCHAR2 (100);
         l_predicate                     VARCHAR2 (2000);
         l_attribute                     VARCHAR2 (15);
         l_table_dot_column              VARCHAR2 (2000);
         l_blk_table_dot_column          VARCHAR2 (2000);
         l_att_table_dot_column          VARCHAR2 (2000);
         l_info_type_id                  hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;
         l_detail_exists                 VARCHAR2 (400)
            := '
 EXISTS ( select 1 from hxc_time_attribute_usages usage,
                        hxc_time_attributes att
          where usage.time_building_Block_id  = detail_block.time_building_block_id AND
                usage.time_building_block_ovn = detail_block.object_version_number
          and
                att.time_attribute_id = usage.time_attribute_id and
                att.';
         l_exists                        VARCHAR2 (400)
            := '
 EXISTS ( select 1 from hxc_time_attribute_usages usage,
                        hxc_time_attributes att
          where usage.time_building_Block_id  = timecard_block.time_building_block_id AND
                usage.time_building_block_ovn = timecard_block.object_version_number
          and
                att.time_attribute_id = usage.time_attribute_id and
                att.';
      BEGIN                                                    -- translate_it
         IF g_debug
         THEN
            l_proc := g_package || 'translate_it';
            hr_utility.set_location ('Entering ' || l_proc, 10);
         END IF;

-- placeholder is delimited by [ ], find the delimited string
         l_start_position := INSTR (p_text, '[', 1, 1) + 1;
         l_end_position :=
                 ((INSTR (p_text, ']', 1, 1) - INSTR (p_text, '[', 1, 1)) - 1
                 );
         l_placeholder := SUBSTR (p_text, l_start_position, l_end_position);

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 20);
         END IF;

-- predicate is delimited by {}, find the predicate
         l_start_position := INSTR (p_text, '{', 1, 1) + 1;
         l_end_position :=
                 ((INSTR (p_text, '}', 1, 1) - INSTR (p_text, '{', 1, 1)) - 1
                 );
         l_predicate := SUBSTR (p_text, l_start_position, l_end_position);

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 30);
         END IF;

-- now that we have the string ensure it is not a reserved keyword.
-- if it is then we can leave it be, otherwise we need to map this
-- against the field mappings
         IF (UPPER (l_placeholder) IN
                ('TIMECARD_BLOCK.COMMENT_TEXT',
                 'TIMECARD_BLOCK.RESOURCE_TYPE',
                 'TIMECARD_BLOCK.RESOURCE_ID',
                 'DAY_BLOCK.COMMENT_TEXT',
                 'DAY_BLOCK.RESOURCE_TYPE',
                 'DAY_BLOCK.RESOURCE_ID',
                 'DETAIL_BLOCK.COMMENT_TEXT',
                 'DETAIL_BLOCK.RESOURCE_TYPE',
                 'DETAIL_BLOCK.RESOURCE_ID'
                )
            )
         THEN
            l_table_dot_column := l_placeholder || ' ' || l_predicate;
            l_blk_table_dot_column := l_placeholder || ' ' || l_predicate;
         ELSE
            -- find which attribute it is associated with by looping through the mappings table
            FOR map_cnt IN
               g_field_mappings_table.FIRST .. g_field_mappings_table.LAST
            LOOP
               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 40);
               END IF;

               -- check to see if placeholder matches field name
               IF (g_field_mappings_table (map_cnt).field_name =
                                                         UPPER (l_placeholder)
                  )
               THEN
                  l_attribute := g_field_mappings_table (map_cnt).ATTRIBUTE;
                  l_info_type_id :=
                        g_field_mappings_table (map_cnt).bld_blk_info_type_id;
                  EXIT;
               END IF;
            END LOOP;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 50);
            END IF;

            IF (g_params.p_process = 'Projects Retrieval Process')
            THEN
               l_table_dot_column :=
                     l_exists
                  || l_attribute
                  || ' '
                  || l_predicate
                  || ' and att.bld_blk_info_type_id = '
                  || l_info_type_id
                  || ' ) ';
               l_att_table_dot_column :=
                     l_exists
                  || l_attribute
                  || ' '
                  || l_predicate
                  || ' and att.bld_blk_info_type_id = '
                  || l_info_type_id
                  || ' ) ';
            ELSE
               l_table_dot_column :=
                     l_detail_exists
                  || l_attribute
                  || ' '
                  || l_predicate
                  || ' and att.bld_blk_info_type_id = '
                  || l_info_type_id
                  || ' ) ';
               l_att_table_dot_column :=
                     l_detail_exists
                  || l_attribute
                  || ' '
                  || l_predicate
                  || ' and att.bld_blk_info_type_id = '
                  || l_info_type_id
                  || ' ) ';
            END IF;
         END IF;                                       -- UPPER( l_placeholder

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 60);
         END IF;

-- now replace the placeholder with the table dot column expression and remove the predicate all together
         l_absolute_start_position := INSTR (p_text, '[', 1, 1);
         l_absolute_end_position := INSTR (p_text, '}', 1, 1) + 1;
         p_text :=
               REPLACE (SUBSTR (p_text, 1, l_absolute_start_position), '[')
            || ' '
            || l_table_dot_column
            || ' '
            || SUBSTR (p_text, l_absolute_end_position);
         l_blk_absolute_start_position := INSTR (p_text_blk, '[', 1, 1);
         l_blk_absolute_end_position := INSTR (p_text_blk, '}', 1, 1) + 1;
         l_att_absolute_start_position := INSTR (p_text_att, '[', 1, 1);
         l_att_absolute_end_position := INSTR (p_text_att, '}', 1, 1) + 1;

-- This next seciton of code is to support EAM which can pass a mixture of both ATTribute and
-- BLK level where clause.
         IF (    l_blk_absolute_start_position >= 5
             AND l_blk_table_dot_column IS NULL
            )
         THEN
            l_new_start_position :=
               INSTR (p_text_blk,
                      'AND',
                      (l_blk_absolute_start_position - 4),
                      1
                     );

            IF (l_new_start_position <> 0)
            THEN
               l_blk_absolute_start_position := l_new_start_position - 1;
            END IF;
         ELSIF (    l_blk_absolute_start_position = 5
                AND l_blk_table_dot_column IS NOT NULL
               )
         THEN
            l_blk_absolute_start_position := 0;
         END IF;

         IF (    l_att_absolute_start_position >= 5
             AND l_att_table_dot_column IS NULL
            )
         THEN
            l_new_start_position :=
               INSTR (p_text_att,
                      'AND',
                      (l_att_absolute_start_position - 4),
                      1
                     );

            IF (l_new_start_position <> 0)
            THEN
               l_att_absolute_start_position := l_new_start_position - 1;
            END IF;
         ELSIF (    l_att_absolute_start_position = 5
                AND l_att_table_dot_column IS NOT NULL
               )
         THEN
            l_att_absolute_start_position := 0;
         END IF;

         p_text_blk :=
            LTRIM (RTRIM (   REPLACE (SUBSTR (p_text_blk,
                                              1,
                                              l_blk_absolute_start_position
                                             ),
                                      '['
                                     )
                          || ' '
                          || l_blk_table_dot_column
                          || ' '
                          || SUBSTR (p_text_blk, l_blk_absolute_end_position)
                         )
                  );
         p_text_att :=
            LTRIM (RTRIM (   REPLACE (SUBSTR (p_text_att,
                                              1,
                                              l_att_absolute_start_position
                                             ),
                                      '['
                                     )
                          || ' '
                          || l_att_table_dot_column
                          || ' '
                          || SUBSTR (p_text_att, l_att_absolute_end_position)
                         )
                  );
      END translate_it;
   BEGIN                                                           -- parse it
      IF g_debug
      THEN
         l_proc := g_package || 'parse_it';
         hr_utility.set_location ('Entering ' || l_proc, 10);
      END IF;

      l_text := p_where_clause_blk;

-- first check that there is something to decode
      IF INSTR (l_text, '[', 1, 1) <> 0
      THEN
         WHILE INSTR (l_text, '[', 1, 1) <> 0
         LOOP
            translate_it (p_text          => l_text,
                          p_text_blk      => p_where_clause_blk,
                          p_text_att      => p_where_clause_att
                         );

            IF g_debug
            THEN
               hr_utility.TRACE ('where blk is ' || p_where_clause_blk);
               hr_utility.TRACE ('where att is ' || p_where_clause_att);
            END IF;
         END LOOP;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving ' || l_proc, 20);
      END IF;

-- using length since the ASCII new line is left when the WHERE has carriage returns
      IF (LENGTH (LTRIM (RTRIM (p_where_clause_att))) > 5)
      THEN
         p_where_clause_att := ' AND ' || p_where_clause_att || ' ';
      END IF;

      IF (LENGTH (LTRIM (RTRIM (p_where_clause_blk))) > 5)
      THEN
         p_where_clause_blk := ' AND ' || p_where_clause_blk || ' ';
      END IF;
   END parse_it;

   PROCEDURE maintain_ranges (
      p_process_id                     NUMBER,
      p_range_start    IN OUT NOCOPY   NUMBER,
      p_range_stop     IN OUT NOCOPY   NUMBER,
      p_where_clause                   VARCHAR2
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_proc                    VARCHAR2 (72);

      CURSOR csr_get_next_range
      IS
         SELECT        rr.retrieval_range_id, rr.range_start, rr.range_stop
                  FROM hxc_retrieval_ranges rr
                 WHERE rr.retrieval_process_id = p_process_id
                   AND rr.transaction_id = 0
                   AND (   rr.where_clause = g_params.p_where_clause
                        OR rr.where_clause IS NULL
                       )
              ORDER BY rr.seq
         FOR UPDATE OF transaction_id NOWAIT;

      r_range                   csr_get_next_range%ROWTYPE;
      l_dummy                   VARCHAR2 (1);
      l_cnt                     PLS_INTEGER                               := 0;
      l_not_maintained_ranges   BOOLEAN                                := TRUE;
      l_first_resource_id       hxc_time_building_blocks.resource_id%TYPE;
      l_last_resource_id        hxc_time_building_blocks.resource_id%TYPE;
      l_dynamic_sql             VARCHAR2 (32000);
      l_range_start             NUMBER;
      l_range_stop              NUMBER;

      TYPE tab_rr_id IS TABLE OF hxc_retrieval_ranges.retrieval_range_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE tab_retrieval_process_id IS TABLE OF hxc_retrieval_ranges.retrieval_process_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE tab_range_start IS TABLE OF hxc_retrieval_ranges.range_start%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE tab_range_stop IS TABLE OF hxc_retrieval_ranges.range_stop%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE tab_seq IS TABLE OF hxc_retrieval_ranges.seq%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE tab_where_clause IS TABLE OF hxc_retrieval_ranges.where_clause%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE r_resource_id IS RECORD (
         resource_id   NUMBER (15)
      );

      TYPE tab_resource_id IS TABLE OF r_resource_id
         INDEX BY BINARY_INTEGER;

      t_rr_id                   tab_rr_id;
      t_retrieval_process_id    tab_retrieval_process_id;
      t_range_start             tab_range_start;
      t_range_stop              tab_range_stop;
      t_seq                     tab_seq;
      t_where_clause            tab_where_clause;
      t_resource_id_bulk        tab_resource_id;
      t_resource_id             DBMS_SQL.number_table;
      t_retrieval_range_id      DBMS_SQL.number_table;
      l_resource_list           DBMS_SQL.number_table;
      l_rows_fetched            INTEGER;
      l_csr                     INTEGER;
      l_since_date              DATE;
      x                         PLS_INTEGER                               := 0;
      l_chunk_size              NUMBER;
      l_rr_id                   NUMBER (15);
      l_ind                     PLS_INTEGER;

-- private procedure
--   generate_resource_sql
--
-- description
--   returns the dynamic SQL used to generate the resource list
--
      PROCEDURE generate_resource_sql (
         p_dynamic_sql         IN OUT NOCOPY   VARCHAR2,
         p_first_resource_id   IN OUT NOCOPY   NUMBER,
         p_last_resource_id    IN OUT NOCOPY   NUMBER,
         p_where_clause                        VARCHAR2
      )
      IS
         l_proc                VARCHAR2 (72);

         CURSOR csr_get_range (p_range VARCHAR2)
         IS
            SELECT TYPE
              FROM hxc_debug_text
             WHERE process = p_range;

         -- Bug 8888911
         -- Cursor to pick up all application sets for this process.
         CURSOR get_app_sets ( p_process  VARCHAR2)
             IS   SELECT has.application_set_id
                    FROM hxc_retrieval_processes hrp,
                  	     hxc_application_set_comps_v has
                   WHERE hrp.name = DECODE(p_process,
                                           'Apply Schedule Rules','BEE Retrieval Process',
                                           p_process)
                     AND hrp.time_recipient_id = has.time_recipient_id;



         l_first_resource_id   hxc_time_building_blocks.resource_id%TYPE
                                                                        := -1;
         l_last_resource_id    hxc_time_building_blocks.resource_id%TYPE
                                                                        := -1;
         l_where_blk           VARCHAR2 (2000);
         l_where_att           VARCHAR2 (2000);
         l_dynamic_sql         VARCHAR2 (32000);
         l_range_caveat        BOOLEAN                               := FALSE;
         l_root                VARCHAR2 (2500)
            := '
SELECT DISTINCT tbb.resource_id
FROM   hxc_latest_details tbb
WHERE  tbb.last_update_date > :p_since_date ';


-- Bug 9394444
-- Retrieval performance upgrade, using the new tables in these new sql strings.
l_root_pa               VARCHAR2(2500)
:= '
SELECT DISTINCT tbb.resource_id
FROM   hxc_pa_latest_details tbb
WHERE  tbb.last_update_date > :p_since_date ';

l_root_pay               VARCHAR2(2500)
:= '
SELECT DISTINCT tbb.resource_id
FROM   hxc_pay_latest_details tbb
WHERE  tbb.last_update_date > :p_since_date ';


         l_root_day            VARCHAR2 (2500)
            := '
SELECT DISTINCT tbb.resource_id
FROM   hxc_latest_details tbb
WHERE  tbb.last_update_date > :p_since_date ';


-- Bug 9394444
         l_root_day_pa            VARCHAR2 (2500)
            := '
SELECT DISTINCT tbb.resource_id
FROM   hxc_pa_latest_details tbb
WHERE  tbb.last_update_date > :p_since_date ';

         l_root_day_pay            VARCHAR2 (2500)
            := '
SELECT DISTINCT tbb.resource_id
FROM   hxc_pay_latest_details tbb
WHERE  tbb.last_update_date > :p_since_date ';

         l_order_by            VARCHAR2 (100)                := ' ORDER BY 1';


         -- Bug 8888911
         -- New variables added for processing Org and appln stripping.
         l_org_strip           VARCHAR2(500);
         l_appln_strip         VARCHAR2(500) :=
      ' AND tbb.application_set_id IN (';
         l_rtp_id              NUMBER;

         -- Bug 9662478
         l_rdb_process_sql     VARCHAR2(32000) :=
' INSERT INTO hxc_rdb_process_timecards
              (timecard_id,
               resource_id,
               start_time,
               stop_time,
               stage,
               request_id,
               ret_user_id,
               process)
SELECT DISTINCT tbb.timecard_id,
               sum.resource_id,
               sum.start_time,
               TRUNC(sum.stop_time),
               ''PENDING'',
               fnd_global.conc_request_id,
               fnd_global.user_id,
               RETRIEVALPROCESS
  FROM LATEST_DETAILS tbb,
       hxc_time_building_blocks sum
 WHERE sum.resource_id = tbb.resource_id
   AND sum.time_building_block_id = tbb.timecard_id
   AND tbb.last_update_date > :p_since_date';


          -- Bug 9458888
          -- Used for Retrieval Dashboard process tab.

          PROCEDURE mark_for_retrieval(p_since_date  IN DATE,
                                       p_sql         IN VARCHAR2,
                                       p_start_date  IN DATE DEFAULT NULL,
                                       p_end_date    IN DATE DEFAULT NULL)
          IS

          PRAGMA AUTONOMOUS_TRANSACTION;
          l_sql VARCHAR2(32000);
          -- Bug 9494444
          -- Added new parameter for post retrieval processing
          l_request_id  NUMBER;
          BEGIN

              IF g_debug
              THEN
                 hr_utility.trace('P_start_date '||p_start_date);
                 hr_utility.trace('P_end_date   '||p_end_date);
              END IF;

              IF p_start_date IS NULL
                AND p_end_date IS NULL
              THEN
                  IF g_debug
                  THEN
                     hr_utility.trace(p_sql);
                  END IF;
                  EXECUTE IMMEDIATE p_sql USING p_since_date;
              ELSIF p_start_date IS NULL
               AND p_end_date IS NOT NULL
              THEN
                  l_sql := p_sql|| ' AND  tbb.start_time <= :p_end_date ';
                  IF g_debug
                  THEN
                     hr_utility.trace(l_sql);
                  END IF;
                  EXECUTE IMMEDIATE l_sql USING p_since_date, p_end_date ;
              ELSIF p_start_date IS NOT NULL
               AND p_end_date IS NULL
              THEN
                  l_sql := p_sql|| ' AND  tbb.stop_time >= :p_start_date ';
                  IF g_debug
                  THEN
                     hr_utility.trace(l_sql);
                  END IF;
                  EXECUTE IMMEDIATE l_sql USING p_since_date, p_start_date ;
              ELSIF p_start_date IS NOT NULL
               AND p_end_date IS NOT NULL
              THEN
                  l_sql := p_sql|| ' AND  tbb.stop_time >= :p_start_date ';
                  l_sql := l_sql|| ' AND  tbb.start_time <= :p_end_date ';
                  IF g_debug
                  THEN
                     hr_utility.trace(l_sql);
                  END IF;
                  EXECUTE IMMEDIATE l_sql USING p_since_date, p_start_date, p_end_date ;
              END IF;
              COMMIT;


              -- Bug 9494444
              -- Added this call to process the Recipient Snapshot.
              -- Currently this is required only for projects.
              -- Controlled by the profile option listed below.
              -- If the profile says NO, insert the request details into the
              -- below table so that it can process later.
              IF g_params.p_process = 'Projects Retrieval Process'
              THEN

                 IF NVL(FND_PROFILE.VALUE('HXC_PARALLEL_RDB_SNAPSHOT'),'Y') = 'Y'
                 THEN
                     l_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                                               ,program     => 'HXCRDBSNP'
                                                               ,description => NULL
                                                               ,sub_request => FALSE
                                                               ,argument1   => FND_GLOBAL.conc_request_id);

                      COMMIT;
                 ELSE
                    INSERT INTO HXC_RDB_PENDING_PROCESSES
                           ( request_id,
                             concurrent_program_id,
                             user_id,
                             status)
                    VALUES ( FND_GLOBAL.conc_request_id,
                             FND_GLOBAL.conc_program_id,
                             FND_GLOBAL.user_id,
                             'PENDING_SNAPSHOT');
                    COMMIT;

                 END IF;

              END IF;

          END mark_for_retrieval;



      BEGIN
         IF g_debug
         THEN
            l_proc := g_package || 'generate_resource_sql';
            hr_utility.TRACE ('in generate resource sql');
         END IF;

         -- Bug 9394444
         -- Description : This bugfix is actually a performance upgrade thru a data model
         --   change.  HXC_LATEST_DETAILS, which was the driving table for retrieval, is
         --   now replaced by two separate tables for Payroll and projects.  The bug fix
         --   only changes the name of the tables in all the dynamic queries used.
         --   This new upgrade is dependant on the new profile option OTL: Use Upgraded
         --   Retrieval Process and would work only if the respective upgrades are
         --   completed, using the OTL: Generic Upgrade Program.
         --   Upgrades to be completed are
         --      Retrieval - Payroll Performance Upgrade
         --      Retrieval - Projects Performance Upgrade.

         -- If the new datamodel is to be considered, use the new query texts.

         IF g_params.p_process = 'Projects Retrieval Process'
          AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PA')
          AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
         THEN
             l_root_day := l_root_day_pa;
             l_root     := l_root_pa;
         ELSIF g_params.p_process IN ('BEE Retrieval Process','Apply Schedule Rules')
          AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PAY')
          AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
         THEN
             l_root_day := l_root_day_pay;
             l_root     := l_root_pay;
         END IF;


         -- Bug 8888911
         -- Picking up the Org id or BG id to trim hxc_latest_details.
         -- do this only if the upgrade is complete.
         IF g_params.p_process = 'Projects Retrieval Process'
           AND hxc_upgrade_pkg.ret_upgrade_completed
         THEN
             IF Pa_Utils.Pa_Morg_Implemented = 'Y'
             THEN
                l_org_strip :=
                   '  AND tbb.org_id = '||to_char(Pa_Moac_Utils.Get_Current_Org_Id)||' ';
             ELSE
                l_org_strip := ' ';
             END IF;
         ELSIF g_params.p_process IN ('BEE Retrieval Process','Apply Schedule Rules')
           AND hxc_upgrade_pkg.ret_upgrade_completed
         THEN
            l_org_strip :=
              ' AND tbb.business_group_id = '||to_char(fnd_profile.value('PER_BUSINESS_GROUP_ID'))||' ';
         ELSE
            l_org_strip := ' ';
         END IF;

         OPEN get_app_sets(g_params.p_process);
         LOOP
           FETCH get_app_sets INTO l_rtp_id;
           EXIT WHEN get_app_sets%NOTFOUND;
           l_appln_strip := l_appln_strip||l_rtp_id||' ,';
         END LOOP;
         CLOSE get_app_sets;
         l_appln_strip := RTRIM(l_appln_strip,',');
         l_appln_strip := l_appln_strip||')';

         -- Bug 8888911
         -- Also modified creation of l_dynamic_sql below.


-- preserve caveat for skipping resources
         OPEN csr_get_range ('LOWER');

         FETCH csr_get_range
          INTO l_first_resource_id;

         IF (csr_get_range%FOUND)
         THEN
            CLOSE csr_get_range;

            OPEN csr_get_range ('UPPER');

            FETCH csr_get_range
             INTO l_last_resource_id;

            IF (csr_get_range%FOUND)
            THEN
               CLOSE csr_get_range;

               l_range_caveat := TRUE;

               IF g_debug
               THEN
                  hr_utility.TRACE ('Using range caveat');
               END IF;
            END IF;
         ELSE
            CLOSE csr_get_range;
         END IF;

         IF (    (INSTR (UPPER (p_where_clause), 'TIMECARD_ATT') = 0)
             AND (INSTR (UPPER (p_where_clause), 'DAY_ATT') = 0)
             AND (INSTR (UPPER (p_where_clause), 'DETAIL_ATT') = 0)
             AND (INSTR (UPPER (p_where_clause), 'RESOURCE_ID') <> 0)
            )
         THEN
            l_where_blk := LTRIM (RTRIM (p_where_clause));
            l_where_att := LTRIM (RTRIM (p_where_clause));
            parse_it (p_where_clause_blk      => l_where_blk,
                      p_where_clause_att      => l_where_att
                     );

            IF g_debug
            THEN
               hr_utility.TRACE ('after parse ');
               hr_utility.TRACE (SUBSTR (l_where_blk, 1, 250));
            END IF;

            l_where_blk := replace_timecard_string (l_where_blk);

            IF g_debug
            THEN
               hr_utility.TRACE ('after replace ');
               hr_utility.TRACE (SUBSTR (l_where_blk, 1, 250));
            END IF;

            IF (g_params.l_using_dates)
            THEN
               IF g_debug
               THEN
                  hr_utility.TRACE ('Using Dates');
               END IF;

               IF (l_range_caveat)
               THEN
                  l_dynamic_sql :=
                        l_root_day
                     || ' '
                     || l_where_blk
                     || ' and tbb.resource_id between '
                     || l_first_resource_id
                     || ' AND '
                     || l_last_resource_id
                     || l_org_strip   -- Bug 8888911
                     || l_appln_strip -- Bug 8888911
                     || l_order_by;

             -- Bug 9458888
             l_rdb_process_sql := l_rdb_process_sql||' '
                     || ' '
                     || l_where_blk
                     || ' and tbb.resource_id between '
                     || l_first_resource_id
                     || ' AND '
                     || l_last_resource_id
                     ||l_org_strip||l_appln_strip;
               ELSE
                  l_dynamic_sql :=
                               l_root_day || ' ' || l_where_blk ||l_org_strip||l_appln_strip|| l_order_by; -- Bug 8888911

                  -- Bug 9458888
                  l_rdb_process_sql := l_rdb_process_sql||' '|| l_where_blk
                                      ||l_org_strip||l_appln_strip;
               END IF;
            ELSE
               IF g_debug
               THEN
                  hr_utility.TRACE ('Not using dates');
               END IF;

               IF (l_range_caveat)
               THEN
                  l_dynamic_sql :=
                        l_root
                     || ' '
                     || l_where_blk
                     || ' and tbb.resource_id between '
                     || l_first_resource_id
                     || ' AND '
                     || l_last_resource_id
                     || l_org_strip              -- Bug 8888911
                     || l_appln_strip            -- Bug 8888911
                     || l_order_by;

                   -- Bug 9458888
                   l_rdb_process_sql := l_rdb_process_sql||' '
                     || ' '
                     || l_where_blk
                     || ' and tbb.resource_id between '
                     || l_first_resource_id
                     || ' AND '
                     || l_last_resource_id
                     ||l_org_strip||l_appln_strip;
               ELSE
                  l_dynamic_sql := l_root || ' ' || l_where_blk||l_org_strip||l_appln_strip|| l_order_by; -- Bug 8888911
                  -- Bug 9458888
                  l_rdb_process_sql := l_rdb_process_sql||' '|| l_where_blk
                                       ||l_org_strip||l_appln_strip;
               END IF;
            END IF;
         ELSE
            IF (g_params.l_using_dates)
            THEN
               IF g_debug
               THEN
                  hr_utility.TRACE ('Using Dates');
               END IF;

               IF (l_range_caveat)
               THEN
                  l_dynamic_sql :=
                        l_root_day
                     || ' '
                     || ' and tbb.resource_id between '
                     || l_first_resource_id
                     || ' AND '
                     || l_last_resource_id
                     || l_org_strip         -- Bug 8888911
                     || l_appln_strip       -- Bug 8888911
                     || l_order_by;

                    -- Bug 9458888
                    l_rdb_process_sql := l_rdb_process_sql||' '
                     || ' and tbb.resource_id between '
                     || l_first_resource_id
                     || ' AND '
                     || l_last_resource_id
                    ||l_org_strip||l_appln_strip;
               ELSE
                  l_dynamic_sql := l_root_day || ' ' ||l_org_strip||l_appln_strip|| l_order_by;  -- Bug 8888911

                  -- Bug 9458888
                  l_rdb_process_sql := l_rdb_process_sql||' '||l_org_strip||l_appln_strip;
               END IF;
            ELSE
               IF g_debug
               THEN
                  hr_utility.TRACE ('Not using dates');
               END IF;

               IF (l_range_caveat)
               THEN
                  l_dynamic_sql :=
                        l_root
                     || ' '
                     || ' and tbb.resource_id between '
                     || l_first_resource_id
                     || ' AND '
                     || l_last_resource_id
                     || l_org_strip              -- Bug 8888911
                     || l_appln_strip            -- Bug 8888911
                     || l_order_by;

                   -- Bug 9458888
                   l_rdb_process_sql := l_rdb_process_sql||' '
                     || ' and tbb.resource_id between '
                     || l_first_resource_id
                     || ' AND '
                     || l_last_resource_id
                     ||l_org_strip||l_appln_strip;
               ELSE
                  l_dynamic_sql := l_root || ' '||l_org_strip||l_appln_strip|| l_order_by;  -- Bug 8888911

                  -- Bug 9458888
                  l_rdb_process_sql := l_rdb_process_sql||' '
                                 ||l_org_strip||l_appln_strip;
               END IF;
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE ('dynamic sql is ');
            hr_utility.TRACE (SUBSTR (l_dynamic_sql, 1, 250));
            hr_utility.TRACE (SUBSTR (l_dynamic_sql, 251, 250));
            hr_utility.TRACE (SUBSTR (l_dynamic_sql, 501, 250));
            hr_utility.TRACE (SUBSTR (l_dynamic_sql, 751, 250));
            hr_utility.TRACE (SUBSTR (l_dynamic_sql, 1001, 250));
            hr_utility.TRACE (SUBSTR (l_dynamic_sql, 1251, 250));
            hr_utility.TRACE (   'FIRST RESOURCE IS : '
                              || TO_CHAR (l_first_resource_id)
                             );
            hr_utility.TRACE (   'LAST RESOURCE IS  : '
                              || TO_CHAR (l_last_resource_id)
                             );
         END IF;

         p_first_resource_id := l_first_resource_id;
         p_last_resource_id := l_last_resource_id;
         p_dynamic_sql := l_dynamic_sql;
         insert_query (l_dynamic_sql, 'RANGE');


         -- Bug 9458888
         IF g_params.p_process = 'Projects Retrieval Process'
          AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PA')
         THEN
             l_rdb_process_sql := REPLACE(l_rdb_process_sql,'LATEST_DETAILS','HXC_PA_LATEST_DETAILS');
             l_rdb_process_sql := REPLACE(l_rdb_process_sql,'RETRIEVALPROCESS',''''||g_params.p_process||'''');
             l_rdb_process_sql := l_rdb_process_sql||' '||l_org_strip||l_appln_strip;
             mark_for_retrieval(TRUNC(SYSDATE) - fnd_profile.value('HXC_RETRIEVAL_CHANGES_DATE'),
                                l_rdb_process_sql);
         ELSIF g_params.p_process IN ('BEE Retrieval Process','Apply Schedule Rules')
          AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PAY')
         THEN
             l_rdb_process_sql := REPLACE(l_rdb_process_sql,'LATEST_DETAILS','HXC_PAY_LATEST_DETAILS');
             l_rdb_process_sql := REPLACE(l_rdb_process_sql,'RETRIEVALPROCESS',''''||g_params.p_process||'''');

             mark_for_retrieval(TRUNC(SYSDATE) - fnd_profile.value('HXC_RETRIEVAL_CHANGES_DATE'),
                                l_rdb_process_sql,
                                g_params.p_start_date,
                                g_params.p_end_date);
         END IF;



      END generate_resource_sql;

      PROCEDURE insert_rr_resources (
         p_resource_list   IN              DBMS_SQL.number_table,
         p_rr_id           IN OUT NOCOPY   NUMBER
      )
      IS
         CURSOR csr_get_rr_id
         IS
            SELECT hxc_retrieval_ranges_s.NEXTVAL
              FROM DUAL;

         l_rr_id   NUMBER (15);
         l_proc    VARCHAR2 (72);
      BEGIN
         IF g_debug
         THEN
            l_proc := g_package || '.insert_rr_resources';
            hr_utility.set_location ('Entering ' || l_proc, 10);
         END IF;

         OPEN csr_get_rr_id;

         FETCH csr_get_rr_id
          INTO l_rr_id;

         CLOSE csr_get_rr_id;

         p_rr_id := l_rr_id;
         FORALL rrx IN p_resource_list.FIRST .. p_resource_list.LAST
            INSERT INTO hxc_retrieval_range_resources
                        (retrieval_range_id, resource_id
                        )
                 VALUES (l_rr_id, p_resource_list (rrx)
                        );

         -- Bug 8888911
         -- Added this code to store all the resources in this global table.
         FOR rrx IN p_resource_list.FIRST..p_resource_list.LAST
         LOOP
            g_res_list(p_resource_list(rrx)):= l_rr_id;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location ('Leaving ' || l_proc, 10);
         END IF;
      END insert_rr_resources;

      FUNCTION chk_empty
         RETURN BOOLEAN
      IS
         CURSOR csr_chk_rr
         IS
            SELECT 'x'
              FROM hxc_retrieval_ranges rr
             WHERE rr.retrieval_process_id = p_process_id
               AND (   rr.where_clause IS NULL
                    OR rr.where_clause = g_params.p_where_clause
                   )
               AND rr.transaction_id = 0;

         CURSOR csr_chk_tx
         IS
            SELECT 'x'
              FROM hxc_transactions tx
             WHERE tx.status = 'IN PROGRESS'
               AND tx.TYPE = 'RETRIEVAL'
               AND tx.transaction_process_id = p_process_id
               AND EXISTS (SELECT 'y'
                             FROM hxc_retrieval_ranges rr
                            WHERE rr.transaction_id = tx.transaction_id
                             AND (   rr.where_clause IS NULL
                                      OR rr.where_clause = g_params.p_where_clause)
                            );

         l_dummy   VARCHAR2 (1);
      BEGIN
         OPEN csr_chk_tx;

         FETCH csr_chk_tx
          INTO l_dummy;

         IF csr_chk_tx%NOTFOUND
         THEN
            OPEN csr_chk_rr;

            FETCH csr_chk_rr
             INTO l_dummy;

            IF csr_chk_rr%NOTFOUND
            THEN
               CLOSE csr_chk_tx;

               CLOSE csr_chk_rr;

               RETURN TRUE;
            END IF;
         END IF;

         CLOSE csr_chk_tx;

         RETURN FALSE;
      END chk_empty;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'maintain_ranges';
         hr_utility.set_location ('Processing ' || l_proc, 10);
      END IF;

-- if the table is empty for the retrieval process
-- then insert the rows

      -- NOTE: put this is an anonymous PL/SQL block to handle
--       the ORA-00054: resource busy and acquire with NOWAIT specified
--       exception. If this occurs then we want to requery the table
--       until no exception
      IF g_debug
      THEN
         hr_utility.TRACE ('Entering maintain_ranges');
      END IF;

      WHILE l_not_maintained_ranges
      LOOP
         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 20);
         END IF;

         BEGIN
            IF g_debug
            THEN
               hr_utility.TRACE ('Locking table');
            END IF;

            IF NOT hxc_generic_retrieval_pkg.g_in_loop
            THEN
               -- LOCK the table
               LOCK TABLE hxc_retrieval_ranges
                  IN EXCLUSIVE MODE NOWAIT;

               IF g_debug
               THEN
                  hr_utility.TRACE ('Before chk empty');
               END IF;

               IF (chk_empty)
               THEN
                  generate_resource_sql
                                 (p_dynamic_sql            => l_dynamic_sql,
                                  p_first_resource_id      => l_first_resource_id,
                                  p_last_resource_id       => l_last_resource_id,
                                  p_where_clause           => p_where_clause
                                 );
                  l_chunk_size := g_params.transfer_batch_size;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'Chunk Size Profile Value is '
                                       || TO_CHAR (l_chunk_size)
                                      );
                  END IF;


                  -- Bug 7595581
                  -- Retrieval Log
                  -- Bug 9173209
                  -- Retrieval Log adjustment
                  fnd_file.put_line (fnd_file.LOG,
                                        '  '||fnd_date.date_to_canonical (SYSDATE)
			|| ' > Chunk Size Profile Value is '
			|| TO_CHAR (l_chunk_size));

                  IF ((l_chunk_size = 0) OR (l_chunk_size IS NULL))
                  THEN
                     l_chunk_size := 100;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('Inserting rows');
                  END IF;

                  -- insert rows
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('using dynamic SQL for resource list');
                  END IF;

                  -- use dynamic SQL BULK FETCH to generate resource list
                  l_rows_fetched := l_chunk_size;
                  l_csr := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse (l_csr, l_dynamic_sql, DBMS_SQL.native);
                  -- bind variables needed by all queries
                  DBMS_SQL.bind_variable (l_csr,
                                          ':p_since_date',
                                          g_params.since_date
                                         );
                  -- define arrays for each item in the select list
                  DBMS_SQL.define_array (c                => l_csr,
                                         POSITION         => 1,
                                         n_tab            => t_resource_id,
                                         cnt              => l_chunk_size,
                                         lower_bound      => 1
                                        );
                  l_dummy := DBMS_SQL.EXECUTE (l_csr);

                  -- loop to ensure we fetch all the rows
                  WHILE (l_rows_fetched = l_chunk_size)
                  LOOP
                     IF g_debug
                     THEN
                        hr_utility.TRACE ('in loop');
                     END IF;

                     l_rows_fetched := DBMS_SQL.fetch_rows (l_csr);

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'rows fetched is '
                                          || TO_CHAR (l_rows_fetched)
                                         );
                     END IF;

                     IF (l_rows_fetched = 0 AND t_range_start.COUNT = 0)
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.TRACE ('No ranges !!!');
                        END IF;

                        DBMS_SQL.close_cursor (l_csr);
                        RAISE e_no_ranges;
                     ELSIF (l_rows_fetched > 0)
                     THEN
                        DBMS_SQL.column_value (c             => l_csr,
                                               POSITION      => 1,
                                               n_tab         => t_resource_id
                                              );
                        -- populate retrieval range resources
                        l_range_start := t_resource_id (t_resource_id.FIRST);
                        l_range_stop := t_resource_id (t_resource_id.LAST);
                        insert_rr_resources (p_resource_list      => t_resource_id,
                                             p_rr_id              => l_rr_id
                                            );
                        x := x + 1;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'range_start is '
                                             || TO_CHAR (l_range_start)
                                            );
                           hr_utility.TRACE (   'range_stop  is '
                                             || TO_CHAR (l_range_stop)
                                            );
                        END IF;

                        t_rr_id (x) := l_rr_id;
                        t_retrieval_process_id (x) := p_process_id;
                        t_range_start (x) := l_range_start;
                        t_range_stop (x) := l_range_stop;
                        t_seq (x) := x;
                        t_where_clause (x) := g_params.p_where_clause;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'loop conditions is '
                                             || TO_CHAR (l_rows_fetched)
                                             || ':'
                                             || TO_CHAR (l_chunk_size)
                                            );
                        END IF;

                        t_resource_id.DELETE;
                     END IF;                               -- l_rows_fetch = 0
                  END LOOP;                      -- dynamic fetch of resources

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('Leaving loop');
                  END IF;

                  DBMS_SQL.close_cursor (l_csr);
                  -- now insert retrieval ranges
                  FORALL rrx IN 1 .. x
                     INSERT INTO hxc_retrieval_ranges
                                 (retrieval_range_id,
                                  retrieval_process_id,
                                  range_start, range_stop,
                                  seq, transaction_id, where_clause,
                                  unique_params, conc_request_id
                                 )
                          VALUES (t_rr_id (rrx),
                                  t_retrieval_process_id (rrx),
                                  t_range_start (rrx), t_range_stop (rrx),
                                  t_seq (rrx), 0, t_where_clause (rrx),
                                  g_params.p_unique_params, g_conc_request_id
                                 );

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('After bulk insert');
                  END IF;

                  l_not_maintained_ranges := FALSE;
               END IF;                                            -- chk_empty

               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 30);
               END IF;
            END IF;                 -- NOT hxc_generic_retrieval_pkg.G_IN_LOOP

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 40);
               hr_utility.TRACE ('About to get range value');
            END IF;

            -- if the table is not empty then select the next row, lock it
            -- set the range values and update the row
            OPEN csr_get_next_range;

            FETCH csr_get_next_range
             INTO r_range;

            IF (csr_get_next_range%FOUND)
            THEN
               IF g_debug
               THEN
                  hr_utility.TRACE ('FOUND range value');
               END IF;

               -- maintain range
               UPDATE hxc_retrieval_ranges rr
                  SET rr.transaction_id =
                                    hxc_generic_retrieval_pkg.g_transaction_id,
                      rr.conc_request_id = g_conc_request_id
                WHERE rr.retrieval_range_id = r_range.retrieval_range_id;

               hxc_generic_retrieval_pkg.g_in_loop := TRUE;
               p_range_start := r_range.range_start;
               p_range_stop := r_range.range_stop;
               l_pkg_retrieval_range_id := r_range.retrieval_range_id;
            ELSE
               IF g_debug
               THEN
                  hr_utility.TRACE ('NOT FOUND range value');
               END IF;

               -- no more ranges

               -- set the G_IN_LOOP, G_LAST_CHUNK and dummy ranges
               hxc_generic_retrieval_pkg.g_in_loop := TRUE;
               hxc_generic_retrieval_pkg.g_last_chunk := TRUE;
               p_range_start := r_range.range_start;
               p_range_stop := r_range.range_stop;
               l_pkg_retrieval_range_id := -1;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 50);
            END IF;

            CLOSE csr_get_next_range;

            l_not_maintained_ranges := FALSE;
            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               -- Bug 9394444
               hr_utility.trace(dbms_utility.format_error_backtrace);
               IF g_debug
               THEN
                  hr_utility.TRACE ('sqlerrm is ' || SQLERRM);
                  hr_utility.TRACE ('sqlcode is ' || SQLCODE);
               END IF;

               IF (SQLCODE = '-54')
               THEN
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('TABLE LOCKED!!!!');
                  END IF;

                  l_cnt := l_cnt + 1;
                  -- wait for 30 seconds before attempting to lock again
                  DBMS_LOCK.sleep (30);
               ELSE
                  RAISE;
               END IF;
         END;                 -- anonymous PL/SQL block to trap lock exception

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 60);
         END IF;

         IF (l_cnt > 60)
         THEN
            -- after 60 attempts (30 minutes)
            fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
            fnd_message.set_token ('PROCEDURE', l_proc);
            fnd_message.set_token ('STEP', 'cannot maintain ranges');
            fnd_message.raise_error;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 70);
         END IF;
      END LOOP;
   END maintain_ranges;

--   maintain_chunks
--
-- description
--   sets the chunk size based on the profile option
--   sets the ranges for each iteration
--   intialises the following global variables
--
--      G_LAST_CHUNK
--      G_IN_LOOP
--      G_OVERALL_SUCCESS
--
--   NOTE: for now only Projects Retrieval Process uses chunks
--
--
--
-- Parameters
--   None
   PROCEDURE maintain_chunks (p_where_clause VARCHAR2)
   IS
      l_proc   VARCHAR2 (72);
   BEGIN
      IF g_debug
      THEN
         l_proc := g_package || 'maintain_chunks';
         hr_utility.set_location ('Entering ' || l_proc, 10);
      END IF;

      IF (g_params.p_process IN
             ('Projects Retrieval Process',
              'BEE Retrieval Process',
              'Apply Schedule Rules',
              'Purchasing Retrieval Process'
             )
         )
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('Entering ' || l_proc, 20);
         END IF;

         maintain_ranges (p_process_id        => g_retrieval_process_id,
                          p_range_start       => l_pkg_range_start,
                          p_range_stop        => l_pkg_range_stop,
                          p_where_clause      => p_where_clause
                         );

         IF g_debug
         THEN
            hr_utility.set_location ('Entering ' || l_proc, 50);
         END IF;
      ELSE
         IF g_debug
         THEN
            hr_utility.set_location ('Entering ' || l_proc, 80);
         END IF;

         -- not the Project Retrieval Process
         -- set range to be full range
         l_pkg_range_start := 0;
         l_pkg_range_stop := 999999999999999999;
      END IF;       -- IF ( g_params.p_process = 'Projects Retrieval Process')

      IF g_debug
      THEN
         hr_utility.TRACE ('');
         hr_utility.TRACE ('******* GLOBALS AFTER MAINTAIN CHUNKS ********');
      END IF;

      IF (g_in_loop)
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('G_IN_LOOP is TRUE');
         END IF;
      ELSE
         IF g_debug
         THEN
            hr_utility.TRACE ('G_IN_LOOP is FALSE');
         END IF;
      END IF;

      IF (g_last_chunk)
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('G_LAST_CHUNK is TRUE');
         END IF;
      ELSE
         IF g_debug
         THEN
            hr_utility.TRACE ('G_LAST_CHUNK is FALSE');
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('l_range_start is ' || TO_CHAR (l_pkg_range_start));
         hr_utility.TRACE ('l_range_stop is ' || TO_CHAR (l_pkg_range_stop));
         hr_utility.TRACE (   'l retrieval range id is '
                           || TO_CHAR (l_pkg_retrieval_range_id)
                          );
      END IF;
   END maintain_chunks;

   PROCEDURE populate_ret_range_blks
   IS
      CURSOR csr_get_ret_range_blks
      IS
         SELECT TO_CHAR (time_building_block_id) tbb_id,
                TO_CHAR (object_version_number) tbb_ovn
           FROM hxc_retrieval_range_blks;

      l_ret_range_rec         csr_get_ret_range_blks%ROWTYPE;
      l_select_from           VARCHAR2 (250)
         := '
SELECT /*+ ordered */
       tbb_latest.time_building_block_id,
       tbb_latest.object_version_number insert_latest
FROM    hxc_retrieval_ranges rr
,       hxc_retrieval_range_resources rrr
,       hxc_latest_details tbb_latest ';

-- Bug 9394444
-- The Application specific version of the queries.

      l_select_from_pa           VARCHAR2 (250)
         := '
SELECT /*+ ordered */
       tbb_latest.time_building_block_id,
       tbb_latest.object_version_number insert_latest
FROM    hxc_retrieval_ranges rr
,       hxc_retrieval_range_resources rrr
,       hxc_pa_latest_details tbb_latest ';

      l_select_from_pay           VARCHAR2 (250)
         := '
SELECT /*+ ordered */
       tbb_latest.time_building_block_id,
       tbb_latest.object_version_number insert_latest
FROM    hxc_retrieval_ranges rr
,       hxc_retrieval_range_resources rrr
,       hxc_pay_latest_details tbb_latest ';



      l_where                 VARCHAR2 (1500)
               := '
      WHERE   rr.retrieval_range_id = :p_rr_id
      AND
              rrr.retrieval_range_id = rr.retrieval_range_id
      AND
              tbb_latest.resource_id = rrr.resource_id    AND
              tbb_latest.approval_status <> ''ERROR''       AND
        tbb_latest.last_update_date >= :p_since_date ';

      l_day_ex                VARCHAR2 (200)
         := '
AND
        tbb_latest.start_time
        BETWEEN :p_start_date AND :p_end_date	AND
        tbb_latest.stop_time
        BETWEEN :p_start_date AND :p_end_date ';
      l_day_in                VARCHAR2 (200)
         := '
AND
        :p_start_date <= tbb_latest.stop_time	AND
        :p_end_date   >= tbb_latest.start_time ';
      l_not_exists            VARCHAR2 (450)
         := '
AND NOT EXISTS (select ''x''
			FROM	hxc_transaction_details txd
			,	hxc_transactions tx
			WHERE	tx.transaction_process_id	= :p_process_id
			AND	tx.type				= ''RETRIEVAL''
			AND	tx.status			= ''SUCCESS''
			AND	tx.transaction_id		= txd.transaction_id
			AND	txd.status			= ''SUCCESS''
		AND	txd.time_building_block_id	= tbb_latest.time_building_block_id
		AND     txd.time_building_block_ovn     = tbb_latest.object_version_number) ';
      t_tbb_id                DBMS_SQL.number_table;
      t_tbb_ovn               DBMS_SQL.number_table;
      l_start_date            DATE;
      l_end_date              DATE;
      l_csr                   INTEGER;
      l_rows_fetched          INTEGER;
      l_dummy                 INTEGER;
      l_app_set               VARCHAR2 (200);
      l_ret_range_query       VARCHAR2 (3000);
      l_ret_criteria_clause   VARCHAR2 (1000);

      -- Bug 8888911
      l_ind                   BINARY_INTEGER;
   BEGIN
      l_ret_criteria_clause := hxc_generic_retrieval_utils.get_ret_criteria;

      -- Bug 9394444
      -- For respective processes, if the upgraded process is chosen,
      -- use the new queries.
      -- Here, l_not_exists is not added because these tables are
      -- dynamically maintained with only the records left to be retrieved.
      IF g_params.p_process = 'Projects Retrieval Process'
        AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PA')
        AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
      THEN
          l_select_from := l_select_from_pa;
          l_not_exists := ' ';
      ELSIF g_params.p_process IN ('BEE Retrieval Process','Apply Schedule Rules')
          AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PAY')
          AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
      THEN
          l_select_from := l_select_from_pay;
          l_not_exists := ' ';
      END IF;


      -- Bug 8888911
      -- Print Skipped blocks here, before processing the next chunk.

      IF(hxc_generic_retrieval_pkg.g_detail_skipped.COUNT > 0)
      THEN
         	 put_log( '  ===============================================================================================');
 	         put_log( '     RESOURCE ID   '
				     || '     TIMECARD      '
				     || '     DETAIL        '
				     || '     REMARKS       ');
 	         put_log( '  -----------------------------------------------------------------------------------------------');

                 -- Bug 9458888
                 l_skipped_tc_id := VARCHARTAB();
                 l_skipped_bb_id := VARCHARTAB();
                 l_skipped_bb_ovn := VARCHARTAB();
                 l_skipped_desc := VARCHARTAB();
                 l_index := 0;

 	         FOR i IN hxc_generic_retrieval_pkg.g_detail_skipped.FIRST .. hxc_generic_retrieval_pkg.g_detail_skipped.LAST
 	         LOOP
                     put_log( '     '||hxc_generic_retrieval_pkg.g_detail_skipped(i).resource_id
	                             || '           '
 	                             || hxc_generic_retrieval_pkg.g_detail_skipped(i).timecard_id
	                             || ' ['
	                             || hxc_generic_retrieval_pkg.g_detail_skipped(i).timecard_ovn
	                             || ']          '
	                             || hxc_generic_retrieval_pkg.g_detail_skipped(i).bb_id
	                             || ' ['
	                             || hxc_generic_retrieval_pkg.g_detail_skipped(i).ovn
	                             || ']          '
	                             || hxc_generic_retrieval_pkg.g_detail_skipped(i).description);

 	              g_temp_tc_list(i) := hxc_generic_retrieval_pkg.g_detail_skipped(i).timecard_id;

                      l_skipped_tc_id.EXTEND(1);
                      l_skipped_bb_id.EXTEND(1);
                      l_skipped_bb_ovn.EXTEND(1);
                      l_skipped_desc.EXTEND(1);
                      l_index := l_index + 1;

                      l_skipped_tc_id(l_index)  := hxc_generic_retrieval_pkg.g_detail_skipped(i).timecard_id;
                      l_skipped_bb_id(l_index)  := hxc_generic_retrieval_pkg.g_detail_skipped(i).bb_id;
                      l_skipped_bb_ovn(l_index) := hxc_generic_retrieval_pkg.g_detail_skipped(i).ovn;
                      l_skipped_desc(l_index)   := hxc_generic_retrieval_pkg.g_detail_skipped(i).description;

                      hxc_generic_retrieval_pkg.g_detail_skipped.DELETE(i);
	          END LOOP;

	          update_rdb_status(g_temp_tc_list,
	                            'PENDING',
	                            'SKIPPED');
                  g_temp_tc_list.DELETE;


                  FORALL i IN l_skipped_tc_id.FIRST..l_skipped_tc_id.LAST
                      INSERT INTO hxc_rdb_process_details
                           ( timecard_id,
                             detail_id,
                             detail_ovn,
                             skipped_reason,
                             skip_level,
                             ret_user_id,
                             request_id ,
                             process)
                      VALUES ( l_skipped_tc_id(i),
                               l_skipped_bb_id (i),
                               l_skipped_bb_ovn(i),
                               l_skipped_desc(i),
                               'OTL_PROC',
                               FND_GLOBAL.user_ID,
                               FND_GLOBAL.conc_request_id,
                               g_params.p_process);
    	END IF;
   	put_log( '  ===============================================================================================');
        put_log(' ');

      -- Bug 8888911
      -- Print out the next chunk of records.
      IF g_res_list.COUNT > 0
      THEN
          put_log('  ==================================================================');
          put_log('  Process is considering the following resources for this iteration');
          put_log('  ------------------------------------------------------------------');
      END IF;
      l_ind := g_res_list.FIRST;
      LOOP
         EXIT WHEN NOT g_res_list.EXISTS(l_ind);
         IF l_pkg_retrieval_range_id = g_res_list(l_ind)
         THEN
            put_log('       '||l_ind);
            g_res_list.DELETE(l_ind);
         END IF;
         l_ind := g_res_list.NEXT(l_ind);
      END LOOP;
      IF g_res_list.COUNT > 0
      THEN
         put_log('  ==================================================================');
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('Entering populate_ret_range_blks');
      END IF;

-- only use temp table for processes which loop
      IF (g_params.p_process IN
             ('BEE Retrieval Process',
              'Apply Schedule Rules',
              'Purchasing Retrieval Process',
              'Projects Retrieval Process'
             )
         )
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('starting to build query');
         END IF;

         IF (g_params.l_using_dates)
         THEN
            IF g_debug
            THEN
               hr_utility.TRACE ('Using Dates');
            END IF;

            l_start_date :=
                         NVL (g_params.p_start_date, hr_general.start_of_time);
            l_end_date := NVL (g_params.p_end_date, hr_general.end_of_time);
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE ('About to delete rows');
         END IF;

         DELETE FROM hxc_retrieval_range_blks;

-- build query
         l_app_set :=
                     g_app_set_id_string (g_retrieval_tr_id).app_set_id_string;

-- Bind ALL variables needed by the query
         IF (g_params.p_rerun_flag = 'Y')
         THEN
            NULL;
         ELSIF (NOT g_params.l_using_dates)
         THEN
            l_ret_range_query :=
                  l_select_from
               || l_where
               || l_not_exists
               || l_app_set
               || l_ret_criteria_clause;
         ELSIF (g_params.p_scope IN ('TIME', 'DAY', 'DETAIL'))
         THEN
            IF (g_params.p_clusive = 'EX')
            THEN
               l_ret_range_query :=
                     l_select_from
                  || l_where
                  || l_day_ex
                  || l_not_exists
                  || l_app_set
                  || l_ret_criteria_clause;
            ELSIF (g_params.p_clusive = 'IN')
            THEN
               l_ret_range_query :=
                     l_select_from
                  || l_where
                  || l_day_in
                  || l_not_exists
                  || l_app_set
                  || l_ret_criteria_clause;
            ELSE
               fnd_message.set_name ('HXC', 'HXC_0014_GNRET_INVLD_P_CLUSIVE');
               fnd_message.raise_error;
            END IF;
         ELSE
            fnd_message.set_name ('HXC', 'HXC_0015_GNRET_INVLD_P_SCOPE');
            fnd_message.raise_error;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE ('dynamic ret range blk sql is ');
            hr_utility.TRACE (SUBSTR (l_ret_range_query, 1, 250));
            hr_utility.TRACE (SUBSTR (l_ret_range_query, 251, 250));
            hr_utility.TRACE (SUBSTR (l_ret_range_query, 501, 250));
            hr_utility.TRACE (SUBSTR (l_ret_range_query, 751, 250));
            hr_utility.TRACE (SUBSTR (l_ret_range_query, 1001, 250));
            hr_utility.TRACE (SUBSTR (l_ret_range_query, 1251, 250));
            hr_utility.TRACE (SUBSTR (l_ret_range_query, 1501, 250));
            hr_utility.TRACE (SUBSTR (l_ret_range_query, 1751, 250));
         END IF;

         insert_query (l_ret_range_query, 'RET_RANGE_BLKS');
-- now fetch and insert the rows
         l_rows_fetched := 100;
         l_csr := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_csr, l_ret_range_query, DBMS_SQL.native);

         -- Bug 9394444
         IF ( g_params.p_process = 'Projects Retrieval Process'
              AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PA')
              AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'    )
               OR ( g_params.p_process  IN ( 'BEE Retrieval Process','Apply Schedule Rules')
              AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PAY')
              AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'    )
         THEN
             NULL;
         ELSE
             DBMS_SQL.bind_variable (l_csr,
                                 ':p_process_id',
                                 g_retrieval_process_id
                                );
         END IF;

         DBMS_SQL.bind_variable (l_csr, ':p_since_date', g_params.since_date);
         DBMS_SQL.bind_variable (l_csr, ':p_rr_id', l_pkg_retrieval_range_id);

         IF (g_params.l_using_dates)
         THEN
            DBMS_SQL.bind_variable (l_csr, ':p_start_date', l_start_date);
            DBMS_SQL.bind_variable (l_csr, ':p_end_date', l_end_date);
         END IF;

         IF g_ret_criteria.gre_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_csr, ':p_gre_id',
                                    g_ret_criteria.gre_id);
         END IF;

         IF g_ret_criteria.payroll_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_csr,
                                    ':p_payroll_id',
                                    g_ret_criteria.payroll_id
                                   );
         END IF;

         IF g_ret_criteria.location_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_csr,
                                    ':p_location_id',
                                    g_ret_criteria.location_id
                                   );
         END IF;

         IF g_ret_criteria.organization_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_csr,
                                    ':p_org_id',
                                    g_ret_criteria.organization_id
                                   );
         END IF;

         DBMS_SQL.define_array (c                => l_csr,
                                POSITION         => 1,
                                n_tab            => t_tbb_id,
                                cnt              => 100,
                                lower_bound      => 1
                               );
         DBMS_SQL.define_array (c                => l_csr,
                                POSITION         => 2,
                                n_tab            => t_tbb_ovn,
                                cnt              => 100,
                                lower_bound      => 1
                               );
         l_dummy := DBMS_SQL.EXECUTE (l_csr);

-- loop to ensure we fetch all the rows
         WHILE (l_rows_fetched = 100)
         LOOP
            l_rows_fetched := DBMS_SQL.fetch_rows (l_csr);

            IF (l_rows_fetched > 0)
            THEN
               DBMS_SQL.column_value (c             => l_csr,
                                      POSITION      => 1,
                                      n_tab         => t_tbb_id
                                     );
               DBMS_SQL.column_value (c             => l_csr,
                                      POSITION      => 2,
                                      n_tab         => t_tbb_ovn
                                     );
               -- populate retrieval range blks
               FORALL rrx IN t_tbb_id.FIRST .. t_tbb_id.LAST
                  INSERT INTO hxc_retrieval_range_blks
                              (time_building_block_id, object_version_number
                              )
                       VALUES (t_tbb_id (rrx), t_tbb_ovn (rrx)
                              );
               t_tbb_id.DELETE;
               t_tbb_ovn.DELETE;
            END IF;                                        -- l_rows_fetch = 0
         END LOOP;                               -- dynamic fetch of resources

         DBMS_SQL.close_cursor (l_csr);
      ELSE
         -- Retrievals which do not loop do not use
         -- this new table
         NULL;
      END IF;                                       -- check retrieval process
/*

if g_debug then
   hr_utility.trace('Here is the table ');
end if;
open csr_get_ret_Range_blks;

fetch csr_get_ret_range_blks into l_ret_range_rec;

WHILE csr_get_ret_range_blks%FOUND
LOOP

   if g_debug then
      hr_utility.trace('ret range blks is '||l_ret_range_rec.tbb_id||':'||l_ret_range_rec.tbb_ovn);
   end if;

   fetch csr_get_ret_range_blks into l_ret_range_rec;

END LOOP;

close csr_get_ret_range_blks;

*/
   END populate_ret_range_blks;

   PROCEDURE populate_max_ovn (p_where_clause VARCHAR2)
   IS
      CURSOR csr_get_max_ovn_debug
      IS
         SELECT time_building_block_id || ':' || max_ovn ovn
           FROM hxc_max_ovn;

      CURSOR csr_get_max_ovn_rrb (p_retrieval_process_id NUMBER)
      IS
         SELECT   /*+ ORDERED INDEX(TXD) INDEX(TX) USE_NL(TXD, TX) */
                  txd.time_building_block_id,
                  NVL (MAX (txd.time_building_block_ovn), 0)
             FROM hxc_retrieval_range_blks rrb,
                  hxc_transaction_details txd,
                  hxc_transactions tx
            WHERE tx.transaction_process_id = p_retrieval_process_id
              AND tx.TYPE = 'RETRIEVAL'
              AND tx.status = 'SUCCESS'
              AND tx.transaction_id = txd.transaction_id
              AND txd.status = 'SUCCESS'
              AND rrb.time_building_block_id = txd.time_building_block_id
              AND rrb.object_version_number > txd.time_building_block_ovn
         GROUP BY txd.time_building_block_id;

     CURSOR csr_get_max_ovn_day (
              p_retrieval_process_id   NUMBER,
              p_start_date             DATE,
              p_end_date               DATE,
              p_since_date             DATE
           )
           IS
              SELECT   txd.time_building_block_id,
                       NVL (MAX (txd.time_building_block_ovn), 0)
                  FROM hxc_transaction_details txd, hxc_transactions tx
                 WHERE tx.transaction_process_id = p_retrieval_process_id
                   AND tx.TYPE = 'RETRIEVAL'
                   AND tx.status = 'SUCCESS'
                   AND tx.transaction_id = txd.transaction_id
                   AND txd.status = 'SUCCESS'
                   AND EXISTS (
                          SELECT 'x'
                            FROM hxc_latest_details tbb_det
                           WHERE tbb_det.start_time <= p_end_date
                             AND tbb_det.stop_time >= p_start_date
                             AND tbb_det.last_update_date > p_since_date
                             AND tbb_det.time_building_block_id =
                                                         txd.time_building_block_id
                             AND tbb_det.object_version_number >
                                                        txd.time_building_block_ovn
                             AND tbb_det.resource_id BETWEEN l_pkg_range_start
                                                         AND l_pkg_range_stop)
         GROUP BY txd.time_building_block_id;

     CURSOR csr_get_max_ovn (p_retrieval_process_id NUMBER, p_since_date DATE)
           IS
              SELECT   txd.time_building_block_id,
                       NVL (MAX (txd.time_building_block_ovn), 0)
                  FROM hxc_transaction_details txd, hxc_transactions tx
                 WHERE tx.transaction_process_id = p_retrieval_process_id
                   AND tx.TYPE = 'RETRIEVAL'
                   AND tx.status = 'SUCCESS'
                   AND tx.transaction_id = txd.transaction_id
                   AND txd.status = 'SUCCESS'
                   AND EXISTS (
                          SELECT 'x'
                            FROM hxc_latest_details tbb_det
                           WHERE tbb_det.time_building_block_id =
                                                         txd.time_building_block_id
                             AND tbb_det.last_update_date > p_since_date
                             AND tbb_det.object_version_number >
                                                        txd.time_building_block_ovn
                             AND tbb_det.resource_id BETWEEN l_pkg_range_start
                                                         AND l_pkg_range_stop)
         GROUP BY txd.time_building_block_id;

      l_max_ovn         csr_get_max_ovn_debug%ROWTYPE;

      TYPE tab_max_ovn_bb_id IS TABLE OF hxc_time_building_blocks.time_building_block_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE tab_max_ovn IS TABLE OF hxc_time_building_blocks.object_version_number%TYPE
         INDEX BY BINARY_INTEGER;

      t_max_ovn_bb_id   tab_max_ovn_bb_id;
      t_max_ovn         tab_max_ovn;
      l_cnt             NUMBER (15);
      l_start_date      DATE;
      l_end_date        DATE;
   BEGIN
      IF g_debug
      THEN
         hr_utility.TRACE ('Entering populate_max_ovn');
      END IF;

-- clear out the table
      DELETE FROM hxc_max_ovn;

      IF (g_params.p_process IN
             ('BEE Retrieval Process',
              'Apply Schedule Rules',
              'Purchasing Retrieval Process',
              'Projects Retrieval Process'
             )
         )
      THEN
         OPEN csr_get_max_ovn_rrb (g_retrieval_process_id);

         LOOP
            IF g_debug
            THEN
               hr_utility.TRACE ('in max ovn loop');
            END IF;

            FETCH csr_get_max_ovn_rrb
            BULK COLLECT INTO t_max_ovn_bb_id, t_max_ovn LIMIT 100;

            IF g_debug
            THEN
               hr_utility.TRACE (   'fetch count is '
                                 || TO_CHAR (t_max_ovn_bb_id.COUNT)
                                );
            END IF;

            IF (t_max_ovn_bb_id.COUNT <> 0)
            THEN
               FORALL x IN t_max_ovn_bb_id.FIRST .. t_max_ovn_bb_id.LAST
                  INSERT INTO hxc_max_ovn
                              (time_building_block_id, max_ovn
                              )
                       VALUES (t_max_ovn_bb_id (x), t_max_ovn (x)
                              );
               t_max_ovn_bb_id.DELETE;
               t_max_ovn.DELETE;
            END IF;

            EXIT WHEN csr_get_max_ovn_rrb%NOTFOUND;
         END LOOP;

         CLOSE csr_get_max_ovn_rrb;
      ELSE                                   -- this must be the EAM retrieval
         IF (g_params.l_using_dates)
         THEN
            l_start_date :=
                        NVL (g_params.p_start_date, hr_general.start_of_time);
            l_end_date := NVL (g_params.p_end_date, hr_general.end_of_time);
         END IF;

         IF (g_params.l_using_dates)
         THEN
            OPEN csr_get_max_ovn_day (g_retrieval_process_id,
                                      l_start_date,
                                      l_end_date,
                                      g_params.since_date
                                     );

            LOOP
               FETCH csr_get_max_ovn_day
               BULK COLLECT INTO t_max_ovn_bb_id, t_max_ovn LIMIT 100;

               IF (t_max_ovn_bb_id.COUNT <> 0)
               THEN
                  FORALL x IN t_max_ovn_bb_id.FIRST .. t_max_ovn_bb_id.LAST
                     INSERT INTO hxc_max_ovn
                                 (time_building_block_id, max_ovn
                                 )
                          VALUES (t_max_ovn_bb_id (x), t_max_ovn (x)
                                 );
                  t_max_ovn_bb_id.DELETE;
                  t_max_ovn.DELETE;
               END IF;

               EXIT WHEN csr_get_max_ovn_day%NOTFOUND;
            END LOOP;

            CLOSE csr_get_max_ovn_day;
         ELSE
            OPEN csr_get_max_ovn (g_retrieval_process_id,
                                  g_params.since_date);

            LOOP
               IF g_debug
               THEN
                  hr_utility.TRACE ('in max ovn loop');
               END IF;

               FETCH csr_get_max_ovn
               BULK COLLECT INTO t_max_ovn_bb_id, t_max_ovn LIMIT 100;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'fetch count is '
                                    || TO_CHAR (t_max_ovn_bb_id.COUNT)
                                   );
               END IF;

               IF (t_max_ovn_bb_id.COUNT <> 0)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('inserting');
                  END IF;

                  FORALL x IN t_max_ovn_bb_id.FIRST .. t_max_ovn_bb_id.LAST
                     INSERT INTO hxc_max_ovn
                                 (time_building_block_id, max_ovn
                                 )
                          VALUES (t_max_ovn_bb_id (x), t_max_ovn (x)
                                 );
                  t_max_ovn_bb_id.DELETE;
                  t_max_ovn.DELETE;
               END IF;

               EXIT WHEN csr_get_max_ovn%NOTFOUND;
            END LOOP;

            CLOSE csr_get_max_ovn;
         END IF;                                                 -- date check
      END IF;                                            -- g_params.p_process
/*
open csr_get_max_ovn_debug;

loop

   fetch csr_get_max_ovn_debug into l_max_ovn;

   if g_debug then
      hr_utility.trace(l_max_ovn.ovn);
   end if;

   exit when csr_get_max_ovn_debug%NOTFOUND;

end loop;

close csr_Get_max_ovn_debug;

*/
   END populate_max_ovn;

-- private procedure
--   audit_transaction
--
-- description
--   manages the transactions for each building block retrieved.
--   In Insert mode, inserts the transactions details bulk bound
--   In update mode, updates the transactions bulk bound after the
--   recipient API has updated the global PL/SQL table
--   In rollback mode deletes the transaction details
--
--   NOTE: the global PL/SQL transaction detail table is maintained
--   within the copy bld blks procedure.
--
-- parameters
--   p_mode    - Insert or Update the transactions
--   p_transaction_process_id - transaction_process_id
--   p_status     - status of the transaction
--   p_description   - exception description
--   p_rollback      - rollback TRUE/FALSE
   PROCEDURE audit_transaction (
      p_mode                     IN   VARCHAR2,
      p_transaction_process_id   IN   NUMBER DEFAULT NULL,
      p_status                   IN   VARCHAR2 DEFAULT NULL,
      p_description              IN   VARCHAR2 DEFAULT NULL,
      p_rollback                 IN   BOOLEAN DEFAULT FALSE
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_tx_id                 hxc_transactions.transaction_id%TYPE;
      l_time_max              INTEGER;
      l_day_max               INTEGER;
      l_detail_max            INTEGER;
      l_error_max             INTEGER;
      l_proc                  VARCHAR2 (72);
      l_temp_transaction_id   t_transaction_id;
   BEGIN                                                  -- audit transaction
      IF g_debug
      THEN
         l_proc := g_package || 'audit_transaction';
         hr_utility.set_location ('Entering ' || l_proc, 10);
         hr_utility.TRACE ('Audit Transaction Params');
         hr_utility.TRACE ('p_mode is ' || p_mode);
         hr_utility.TRACE (   'p_transaction_process_id is '
                           || TO_CHAR (p_transaction_process_id)
                          );
         hr_utility.TRACE ('p_status is ' || p_status);
         hr_utility.TRACE ('p_description is ' || p_description);
         hr_utility.TRACE (   'Global Transaction ID is '
                           || TO_CHAR
                                   (hxc_generic_retrieval_pkg.g_transaction_id)
                          );
      END IF;

      l_time_max := hxc_generic_retrieval_pkg.t_tx_time_bb_id.COUNT;
      l_day_max := hxc_generic_retrieval_pkg.t_tx_day_bb_id.COUNT;
      l_detail_max := hxc_generic_retrieval_pkg.t_tx_detail_bb_id.COUNT;
      l_error_max := hxc_generic_retrieval_pkg.t_tx_error_bb_id.COUNT;

      IF (p_mode = 'I')                                 -- insert transactions
      THEN
-- check to see if header already inserted
         IF (hxc_generic_retrieval_pkg.g_transaction_id IS NOT NULL)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 7);
            END IF;

            -- already inserted - lets update it!
            UPDATE hxc_transactions
               SET status = p_status,
                   exception_description = p_description
             WHERE transaction_id = hxc_generic_retrieval_pkg.g_transaction_id;
         ELSE
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 20);
            END IF;

            OPEN csr_get_tx_id;

            FETCH csr_get_tx_id
             INTO hxc_generic_retrieval_pkg.g_transaction_id;

            CLOSE csr_get_tx_id;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 30);
            END IF;

            INSERT INTO hxc_transactions
                        (transaction_id,
                         transaction_process_id, transaction_date,
                         transaction_code,
                         TYPE, status, exception_description
                        )
                 VALUES (hxc_generic_retrieval_pkg.g_transaction_id,
                         p_transaction_process_id, SYSDATE,
                         NVL (g_params.p_transaction_code,
                              TO_CHAR (SYSDATE, 'DD/MM/YYYY')
                             ),
                         'RETRIEVAL', p_status, p_description
                        );

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 40);
            END IF;
         END IF;                                     -- transaction id IS NULL

         IF l_error_max <> 0
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 85);
            END IF;

-- now let's bulk fetch all the transaction detail id
            OPEN csr_get_tx_detail_id (l_error_max);

            FETCH csr_get_tx_detail_id
            BULK COLLECT INTO l_temp_transaction_id;

            CLOSE csr_get_tx_detail_id;

            hxc_generic_retrieval_pkg.t_tx_error_transaction_id :=
                                                         l_temp_transaction_id;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 90);
            END IF;

            FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_error_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_error_transaction_id.LAST
               INSERT INTO hxc_transaction_details
                           (transaction_detail_id,
                            time_building_block_id,
                            time_building_block_ovn,
                            transaction_id,
                            status,
                            exception_description
                           )
                    VALUES (hxc_generic_retrieval_pkg.t_tx_error_transaction_id
                                                                     (tx_error),
                            hxc_generic_retrieval_pkg.t_tx_error_bb_id
                                                                     (tx_error),
                            hxc_generic_retrieval_pkg.t_tx_error_bb_ovn
                                                                     (tx_error),
                            hxc_generic_retrieval_pkg.g_transaction_id,
                            hxc_generic_retrieval_pkg.t_tx_error_status
                                                                     (tx_error),
                            hxc_generic_retrieval_pkg.t_tx_error_exception
                                                                     (tx_error)
                           );



-- given we are only going to do this once and the recipient app does not need
-- to maintain these statuses we can delete the arrays
            hxc_generic_retrieval_pkg.t_tx_error_transaction_id.DELETE;
            hxc_generic_retrieval_pkg.t_tx_error_bb_id.DELETE;
            hxc_generic_retrieval_pkg.t_tx_error_bb_ovn.DELETE;
            hxc_generic_retrieval_pkg.t_tx_error_status.DELETE;
            hxc_generic_retrieval_pkg.t_tx_error_exception.DELETE;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 100);
            END IF;
         END IF;                                           -- l_error_max <> 0
      ELSIF (p_mode = 'U')                              -- update transactions
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 110);
         END IF;

         OPEN csr_get_tx_id;

         FETCH csr_get_tx_id
          INTO l_tx_id;

         CLOSE csr_get_tx_id;

         INSERT INTO hxc_transactions
                     (transaction_id, transaction_process_id,
                      transaction_date, TYPE, status,
                      exception_description
                     )
              VALUES (l_tx_id, p_transaction_process_id,
                      SYSDATE, 'RETRIEVAL_STATUS_UPDATE', p_status,
                      p_description
                     );

         IF (p_description IS NULL OR p_description LIKE '%ORA-20001%')
         THEN
            -- insure we do not write over a meaningful excpetion already
            -- set within the retrieval
            UPDATE hxc_transactions
               SET status = p_status
             WHERE transaction_id = hxc_generic_retrieval_pkg.g_transaction_id;
         ELSE
            -- record the proper exception most likely thrown by the recipient
            -- application code
            UPDATE hxc_transactions
               SET status = p_status,
                   exception_description = p_description
             WHERE transaction_id = hxc_generic_retrieval_pkg.g_transaction_id;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 130);
         END IF;

-- check to see if any tx time details
         IF l_time_max <> 0
         THEN
-- now let's bulk fetch all the transaction detail id
            OPEN csr_get_tx_detail_id (l_time_max);

            FETCH csr_get_tx_detail_id
            BULK COLLECT INTO l_temp_transaction_id;

            CLOSE csr_get_tx_detail_id;

            hxc_generic_retrieval_pkg.t_tx_time_transaction_id :=
                                                        l_temp_transaction_id;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 50);
            END IF;

            FORALL tx_detail IN hxc_generic_retrieval_pkg.t_tx_time_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_time_transaction_id.LAST
               INSERT INTO hxc_transaction_details
                           (transaction_detail_id,
                            time_building_block_id,
                            time_building_block_ovn,
                            transaction_id,
                            status,
                            exception_description
                           )
                    VALUES (hxc_generic_retrieval_pkg.t_tx_time_transaction_id
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_time_bb_id
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_time_bb_ovn
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.g_transaction_id,
                            hxc_generic_retrieval_pkg.t_tx_time_status
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_time_exception
                                                                    (tx_detail)
                           );
         END IF;                                            -- l_time_max <> 0

-- check to see if any tx day details
         IF l_day_max <> 0
         THEN
-- now let's bulk fetch all the transaction detail id
            OPEN csr_get_tx_detail_id (l_day_max);

            FETCH csr_get_tx_detail_id
            BULK COLLECT INTO l_temp_transaction_id;

            CLOSE csr_get_tx_detail_id;

            hxc_generic_retrieval_pkg.t_tx_day_transaction_id :=
                                                        l_temp_transaction_id;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 60);
            END IF;

            FORALL tx_detail IN hxc_generic_retrieval_pkg.t_tx_day_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_day_transaction_id.LAST
               INSERT INTO hxc_transaction_details
                           (transaction_detail_id,
                            time_building_block_id,
                            time_building_block_ovn,
                            transaction_id,
                            status,
                            exception_description
                           )
                    VALUES (hxc_generic_retrieval_pkg.t_tx_day_transaction_id
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_day_bb_id
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_day_bb_ovn
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.g_transaction_id,
                            hxc_generic_retrieval_pkg.t_tx_day_status
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_day_exception
                                                                    (tx_detail)
                           );
         END IF;                                             -- l_day_max <> 0

-- check to see if any tx detail details
         IF l_detail_max <> 0
         THEN
-- now let's bulk fetch all the transaction detail id
            OPEN csr_get_tx_detail_id (l_detail_max);

            FETCH csr_get_tx_detail_id
            BULK COLLECT INTO l_temp_transaction_id;

            CLOSE csr_get_tx_detail_id;

            hxc_generic_retrieval_pkg.t_tx_detail_transaction_id :=
                                                        l_temp_transaction_id;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 70);
            END IF;

            FORALL tx_detail IN hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.LAST
               INSERT INTO hxc_transaction_details
                           (transaction_detail_id,
                            time_building_block_id,
                            time_building_block_ovn,
                            transaction_id,
                            status,
                            exception_description
                           )
                    VALUES (hxc_generic_retrieval_pkg.t_tx_detail_transaction_id
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_detail_bb_id
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_detail_bb_ovn
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.g_transaction_id,
                            hxc_generic_retrieval_pkg.t_tx_detail_status
                                                                    (tx_detail),
                            hxc_generic_retrieval_pkg.t_tx_detail_exception
                                                                    (tx_detail)
                           );

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 75);
            END IF;
         END IF;                                          -- l_detail_max <> 0

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 80);
         END IF;

         IF l_error_max <> 0
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 85);
            END IF;

-- now let's bulk fetch all the transaction detail id
            OPEN csr_get_tx_detail_id (l_error_max);

            FETCH csr_get_tx_detail_id
            BULK COLLECT INTO l_temp_transaction_id;

            CLOSE csr_get_tx_detail_id;

            hxc_generic_retrieval_pkg.t_tx_error_transaction_id :=
                                                         l_temp_transaction_id;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 90);
            END IF;

            FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_error_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_error_transaction_id.LAST
               INSERT INTO hxc_transaction_details
                           (transaction_detail_id,
                            time_building_block_id,
                            time_building_block_ovn,
                            transaction_id,
                            status,
                            exception_description
                           )
                    VALUES (hxc_generic_retrieval_pkg.t_tx_error_transaction_id
                                                                     (tx_error),
                            hxc_generic_retrieval_pkg.t_tx_error_bb_id
                                                                     (tx_error),
                            hxc_generic_retrieval_pkg.t_tx_error_bb_ovn
                                                                     (tx_error),
                            hxc_generic_retrieval_pkg.g_transaction_id,
                            hxc_generic_retrieval_pkg.t_tx_error_status
                                                                     (tx_error),
                            hxc_generic_retrieval_pkg.t_tx_error_exception
                                                                     (tx_error)
                           );

            -- Bug 9458888
            -- Used for Retrieval Dashboard Process Tab
            g_temp_tc_list.DELETE;

            FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_error_transaction_id.FIRST ..
                   hxc_generic_retrieval_pkg.t_tx_error_transaction_id.LAST
              UPDATE hxc_rdb_process_details
                 SET skipped_reason = hxc_generic_retrieval_pkg.t_tx_error_exception
                                                                     (tx_error),
                     skip_level = 'REC_PROC'
                WHERE detail_id = hxc_generic_retrieval_pkg.t_tx_error_bb_id
                                                                     (tx_error)
                 AND request_id = FND_GLOBAL.CONC_REQUEST_ID
                 AND process = g_params.p_process
                 AND ret_user_id = FND_global.user_id
           RETURNING timecard_id
                BULK COLLECT INTO g_temp_tc_list ;

            FORALL i IN g_temp_tc_list.FIRST..g_temp_tc_list.LAST
              UPDATE hxc_rdb_process_timecards
                 SET stage = 'ERRORED'
               WHERE timecard_id = g_temp_tc_list(i)
                 AND request_id = FND_GLOBAL.CONC_REQUEST_ID
                 AND process = g_params.p_process;


-- given we are only going to do this once and the recipient app does not need
-- to maintain these statuses we can delete the arrays
            hxc_generic_retrieval_pkg.t_tx_error_transaction_id.DELETE;
            hxc_generic_retrieval_pkg.t_tx_error_bb_id.DELETE;
            hxc_generic_retrieval_pkg.t_tx_error_bb_ovn.DELETE;
            hxc_generic_retrieval_pkg.t_tx_error_status.DELETE;
            hxc_generic_retrieval_pkg.t_tx_error_exception.DELETE;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 100);
            END IF;
         END IF;                                           -- l_error_max <> 0
      END IF;                                                        -- p_mode

      IF g_debug
      THEN
         hr_utility.TRACE ('Committing !!!');
      END IF;

      COMMIT;
   END audit_transaction;

-- private procedure
--   chk_retrieval_process
--
-- description
--   This checks that the retrieval process passed in P_PROCESS exists
--   in hxc retrieval_processes. If it does exists it returns the
--   mapping id associated with the process. The mapping id is tested
--   for null to determine if the processes exists
--
-- parameters
--   p_retrieval_process   - process name (P_PROCESS)
--   p_retrieval_process_id   - retrieval process id (OUT only)
--   p_retrieval_tr_id          - retrieval time recipient id (OUT only)
--   p_mapping_id    - mapping id (OUT only)
   PROCEDURE chk_retrieval_process (
      p_retrieval_process                      hxc_retrieval_processes.NAME%TYPE,
      p_retrieval_process_id   IN OUT NOCOPY   hxc_retrieval_processes.retrieval_process_id%TYPE,
      p_retrieval_tr_id        IN OUT NOCOPY   hxc_retrieval_processes.time_recipient_id%TYPE,
      p_mapping_id             IN OUT NOCOPY   hxc_mappings.mapping_id%TYPE
   )
   IS
--
      l_proc         VARCHAR2 (72);

--
      CURSOR csr_get_otm_mapping
      IS
         SELECT -1, rtr.time_recipient_id, rtr.mapping_id
           FROM hxc_retrieval_processes rtr
          WHERE rtr.NAME = 'BEE Retrieval Process';

      CURSOR csr_chk_retrieval
      IS
         SELECT rtr.retrieval_process_id, rtr.time_recipient_id,
                rtr.mapping_id
           FROM hxc_retrieval_processes rtr
          WHERE rtr.NAME = p_retrieval_process;

--
      l_mapping_id   NUMBER (15)   := NULL;
--
   BEGIN                                              -- chk_retrieval_process
      IF g_debug
      THEN
         l_proc := g_package || 'chk_retrieval_process';
         hr_utility.set_location ('Entering ' || l_proc, 10);
      END IF;

      IF (p_retrieval_process = 'Apply Schedule Rules')
      THEN
         OPEN csr_get_otm_mapping;

         FETCH csr_get_otm_mapping
          INTO p_retrieval_process_id, p_retrieval_tr_id, p_mapping_id;

         CLOSE csr_get_otm_mapping;
      ELSE
         OPEN csr_chk_retrieval;

         FETCH csr_chk_retrieval
          INTO p_retrieval_process_id, p_retrieval_tr_id, p_mapping_id;

         CLOSE csr_chk_retrieval;
      END IF;

-- set locking mode
      IF (p_retrieval_process IN
                            ('BEE Retrieval Process', 'Apply Schedule Rules')
         )
      THEN
         hxc_generic_retrieval_pkg.g_lock_type :=
                                   hxc_lock_util.c_plsql_pay_retrieval_action;
      ELSIF (p_retrieval_process = 'Projects Retrieval Process')
      THEN
         hxc_generic_retrieval_pkg.g_lock_type :=
                                    hxc_lock_util.c_plsql_pa_retrieval_action;
      ELSIF (p_retrieval_process = 'Purchasing Retrieval Process')
      THEN
         hxc_generic_retrieval_pkg.g_lock_type :=
                                    hxc_lock_util.c_plsql_po_retrieval_action;
      ELSE
         hxc_generic_retrieval_pkg.g_lock_type :=
                                   hxc_lock_util.c_plsql_eam_retrieval_action;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving ' || l_proc, 30);
      END IF;
--
   END chk_retrieval_process;

-- private procedure
--   populate_query_table
--
-- description
--   the dynamic query bulk collects the data into arrays. This procedure copies
--   the arrays into a single table of records to make datamanagment and
--   manipulation easier. It also deletes the arrays thus saving on memory.
--
-- parameters
--   None
   PROCEDURE populate_query_table
   IS
      l_proc    VARCHAR2 (72) := g_package || 'populate_query_table';
      l_ind     PLS_INTEGER;
      l_dummy   NUMBER (1);
   BEGIN
      IF (t_timecard_bb_id.COUNT <> 0)
      THEN
         l_ind := NVL (t_bb.LAST, 0) + 1;

         FOR x IN t_timecard_bb_id.FIRST .. t_timecard_bb_id.LAST
         LOOP
            t_bb (l_ind).time_bb_id := t_timecard_bb_id (x);
            t_bb (l_ind).time_ovn := t_timecard_ovn (x);
            t_bb (l_ind).time_max_ovn := t_timecard_max_ovn (x);
            t_bb (l_ind).time_start_time := t_timecard_start_time (x);
            t_bb (l_ind).time_stop_time := t_timecard_stop_time (x);
            t_bb (l_ind).time_comment_text := t_timecard_comment_text (x);
            t_bb (l_ind).time_deleted := t_timecard_deleted (x);
            t_bb (l_ind).day_bb_id := t_day_bb_id (x);
            t_bb (l_ind).day_start_time := t_day_start_time (x);
            t_bb (l_ind).day_stop_time := t_day_stop_time (x);
            t_bb (l_ind).day_ovn := t_day_ovn (x);
            t_bb (l_ind).day_max_ovn := t_day_max_ovn (x);
            t_bb (l_ind).detail_bb_id := t_detail_bb_id (x);
            t_bb (l_ind).detail_parent_bb_id := t_detail_parent_id (x);
            t_bb (l_ind).detail_resource_type := t_detail_resource_type (x);
            t_bb (l_ind).detail_resource_id := t_detail_resource_id (x);
            t_bb (l_ind).detail_comment_text := t_detail_comment_text (x);
            t_bb (l_ind).detail_start_time := t_detail_start_time (x);
            t_bb (l_ind).detail_stop_time := t_detail_stop_time (x);
            t_bb (l_ind).detail_measure := t_detail_measure (x);
            t_bb (l_ind).detail_scope := t_detail_scope (x);
            t_bb (l_ind).detail_type := t_detail_type (x);
            t_bb (l_ind).detail_ovn := t_detail_ovn (x);
            t_bb (l_ind).detail_max_ovn := t_detail_max_ovn (x);
            t_bb (l_ind).detail_deleted := t_detail_deleted (x);
            t_bb (l_ind).detail_uom := t_detail_uom (x);
            t_bb (l_ind).detail_date_from := t_detail_date_from (x);
            t_bb (l_ind).detail_date_to := t_detail_date_to (x);
            t_bb (l_ind).detail_approval_status :=
                                                 t_detail_approval_status (x);
            t_bb (l_ind).detail_approval_style_id :=
                                               t_detail_approval_style_id (x);
            t_bb (l_ind).detail_ta_id := t_detail_ta_id (x);
            t_bb (l_ind).detail_bld_blk_info_type_id :=
                                            t_detail_bld_blk_info_type_id (x);
            t_bb (l_ind).detail_attribute1 := t_detail_attribute1 (x);
            t_bb (l_ind).detail_attribute2 := t_detail_attribute2 (x);
            t_bb (l_ind).detail_attribute3 := t_detail_attribute3 (x);
            t_bb (l_ind).detail_attribute4 := t_detail_attribute4 (x);
            t_bb (l_ind).detail_attribute5 := t_detail_attribute5 (x);
            t_bb (l_ind).detail_attribute6 := t_detail_attribute6 (x);
            t_bb (l_ind).detail_attribute7 := t_detail_attribute7 (x);
            t_bb (l_ind).detail_attribute8 := t_detail_attribute8 (x);
            t_bb (l_ind).detail_attribute9 := t_detail_attribute9 (x);
            t_bb (l_ind).detail_attribute10 := t_detail_attribute10 (x);
            t_bb (l_ind).detail_attribute11 := t_detail_attribute11 (x);
            t_bb (l_ind).detail_attribute12 := t_detail_attribute12 (x);
            t_bb (l_ind).detail_attribute13 := t_detail_attribute13 (x);
            t_bb (l_ind).detail_attribute14 := t_detail_attribute14 (x);
            t_bb (l_ind).detail_attribute15 := t_detail_attribute15 (x);
            t_bb (l_ind).detail_attribute16 := t_detail_attribute16 (x);
            t_bb (l_ind).detail_attribute17 := t_detail_attribute17 (x);
            t_bb (l_ind).detail_attribute18 := t_detail_attribute18 (x);
            t_bb (l_ind).detail_attribute19 := t_detail_attribute19 (x);
            t_bb (l_ind).detail_attribute20 := t_detail_attribute20 (x);
            t_bb (l_ind).detail_attribute21 := t_detail_attribute21 (x);
            t_bb (l_ind).detail_attribute22 := t_detail_attribute22 (x);
            t_bb (l_ind).detail_attribute23 := t_detail_attribute23 (x);
            t_bb (l_ind).detail_attribute24 := t_detail_attribute24 (x);
            t_bb (l_ind).detail_attribute25 := t_detail_attribute25 (x);
            t_bb (l_ind).detail_attribute26 := t_detail_attribute26 (x);
            t_bb (l_ind).detail_attribute27 := t_detail_attribute27 (x);
            t_bb (l_ind).detail_attribute28 := t_detail_attribute28 (x);
            t_bb (l_ind).detail_attribute29 := t_detail_attribute29 (x);
            t_bb (l_ind).detail_attribute30 := t_detail_attribute30 (x);
            t_bb (l_ind).detail_attribute_category :=
                                              t_detail_attribute_category (x);
            l_dummy :=
               initialise_g_resource
                             (p_resource_id      => t_bb (l_ind).detail_resource_id
                             );
            hxc_generic_retrieval_utils.g_resources
                                               (t_bb (l_ind).detail_resource_id
                                               ).start_time :=
               LEAST
                  (t_bb (l_ind).time_start_time,
                   hxc_generic_retrieval_utils.g_resources
                                               (t_bb (l_ind).detail_resource_id
                                               ).start_time
                  );
            hxc_generic_retrieval_utils.g_resources
                                               (t_bb (l_ind).detail_resource_id
                                               ).stop_time :=
               GREATEST
                  (t_bb (l_ind).time_stop_time,
                   hxc_generic_retrieval_utils.g_resources
                                               (t_bb (l_ind).detail_resource_id
                                               ).stop_time
                  );
            l_ind := l_ind + 1;
         END LOOP;

-- now delete tables

         -- delete time card scope arrays
         t_timecard_bb_id.DELETE;
         t_timecard_ovn.DELETE;
         t_timecard_max_ovn.DELETE;
         t_timecard_start_time.DELETE;
         t_timecard_stop_time.DELETE;
         t_timecard_comment_text.DELETE;
         t_timecard_deleted.DELETE;
         t_day_bb_id.DELETE;
         t_day_start_time.DELETE;
         t_day_stop_time.DELETE;
         t_day_ovn.DELETE;
         t_day_max_ovn.DELETE;
         t_detail_bb_id.DELETE;
         t_detail_parent_id.DELETE;
         t_detail_resource_type.DELETE;
         t_detail_resource_id.DELETE;
         t_detail_comment_text.DELETE;
         t_detail_start_time.DELETE;
         t_detail_stop_time.DELETE;
         t_detail_measure.DELETE;
         t_detail_scope.DELETE;
         t_detail_type.DELETE;
         t_detail_ovn.DELETE;
         t_detail_deleted.DELETE;
         t_detail_max_ovn.DELETE;
         t_detail_uom.DELETE;
         t_detail_date_from.DELETE;
         t_detail_date_to.DELETE;
         t_detail_approval_status.DELETE;
         t_detail_approval_style_id.DELETE;
         t_detail_ta_id.DELETE;
         t_detail_bld_blk_info_type_id.DELETE;
         t_detail_attribute1.DELETE;
         t_detail_attribute2.DELETE;
         t_detail_attribute3.DELETE;
         t_detail_attribute4.DELETE;
         t_detail_attribute5.DELETE;
         t_detail_attribute6.DELETE;
         t_detail_attribute7.DELETE;
         t_detail_attribute8.DELETE;
         t_detail_attribute9.DELETE;
         t_detail_attribute10.DELETE;
         t_detail_attribute11.DELETE;
         t_detail_attribute12.DELETE;
         t_detail_attribute13.DELETE;
         t_detail_attribute14.DELETE;
         t_detail_attribute15.DELETE;
         t_detail_attribute16.DELETE;
         t_detail_attribute17.DELETE;
         t_detail_attribute18.DELETE;
         t_detail_attribute19.DELETE;
         t_detail_attribute20.DELETE;
         t_detail_attribute21.DELETE;
         t_detail_attribute22.DELETE;
         t_detail_attribute23.DELETE;
         t_detail_attribute24.DELETE;
         t_detail_attribute25.DELETE;
         t_detail_attribute26.DELETE;
         t_detail_attribute27.DELETE;
         t_detail_attribute28.DELETE;
         t_detail_attribute29.DELETE;
         t_detail_attribute30.DELETE;
         t_detail_attribute_category.DELETE;
      END IF;                                   -- t_timecard_bb_id.COUNT <> 0
   END populate_query_table;

-- private procedure
--   populate_attributes
--
-- description
--   This procedure is used to populate the global PL/SQL tables which
--   contain the attribution for each time building block stored in
--   HXC_TIME_ATTRIBUTES.
--   The procedure is called each time a new time attribute id is found
--   when processing the rows returned in the main query. Then, for each
--   segment/attribute in the mapping for the process, copies the associated
--   value and field name to a global PL/SQL table for use later by the
--   recipient API. The global PL/SQL table destination varies upon the SCOPE
--   and the NEW parameters. SCOPE, reflects the building block scope i.e. is
--   this a new time attribute associated with a building block of scope TIME
--   The NEW parameter refers to whether this a attribution for current building
--   block or the prior or old building block which is passed back in the case
--   of an INCREMENTAL retrieval
--
--   Parameters
--     p_building_block_id - time building block id (foreign key in PL/SQL table)
--     p_attribute_table   - table of all time building blocks and attributes
--     p_cnt         - index of p_attribute_table
--     p_scope       - scope of the time building block
--     p_new         - are these attributes for old or new bld blks?
   PROCEDURE populate_attributes (
      p_building_block_id   NUMBER,
      p_attribute_table     t_all_building_blocks,
      p_cnt                 INTEGER,
      p_scope               VARCHAR2,
      p_new                 VARCHAR2
   )
   IS
      l_att_cnt                PLS_INTEGER;
      l_bld_blk_info_type_id   hxc_time_attributes.bld_blk_info_type_id%TYPE;
      l_attribute_category     VARCHAR2 (100);
      l_proc                   VARCHAR2 (72)
                                        := g_package || 'populate_attributes';
   BEGIN
      IF p_scope = 'DETAIL'
      THEN
         FOR MAP IN
            g_field_mappings_table.FIRST .. g_field_mappings_table.LAST
         LOOP
            IF (p_scope = 'DETAIL' AND p_new = 'Y')
            THEN
               l_att_cnt :=
                    NVL (hxc_generic_retrieval_pkg.t_detail_attributes.LAST,
                         0
                        )
                  + 1;
               l_bld_blk_info_type_id :=
                         p_attribute_table (p_cnt).detail_bld_blk_info_type_id;
            ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
            THEN
               l_att_cnt :=
                    NVL
                       (hxc_generic_retrieval_pkg.t_old_detail_attributes.LAST,
                        0
                       )
                  + 1;
               l_bld_blk_info_type_id :=
                         p_attribute_table (p_cnt).detail_bld_blk_info_type_id;
            END IF;

            -- for each field mapping assign the value back to the
            -- attribute table
            IF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE_CATEGORY'
               )
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  -- WWB 3791698 - OIT to OTL migration fix to handle pre-pending of PAEXPITDFF
                  --               to existing contexts
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                        hxc_deposit_wrapper_utilities.get_dupdff_name
                           (p_attribute_table (p_cnt).detail_attribute_category
                           );
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                       g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                          g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                         g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                        hxc_deposit_wrapper_utilities.get_dupdff_name
                           (p_attribute_table (p_cnt).detail_attribute_category
                           );
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                    (l_att_cnt).field_name :=
                                       g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                    (l_att_cnt).CONTEXT :=
                                          g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                    (l_att_cnt).CATEGORY :=
                                         g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE1')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute1;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute1;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE2')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute2;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute2;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE3')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute3;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute3;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE4')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute4;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute4;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE5')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute5;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute5;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE6')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute6;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute6;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE7')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute7;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute7;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE8')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute8;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute8;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE9')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute9;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                  p_attribute_table (p_cnt).detail_attribute9;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE10')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute10;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute10;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE11')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute11;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute11;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE12')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute12;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute12;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE13')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute13;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute13;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE14')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute14;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute14;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE15')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute15;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute15;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE16')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute16;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute16;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE17')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute17;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute17;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE18')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute18;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute18;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE19')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute19;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute19;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE20')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute20;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute20;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE21')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute21;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute21;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE22')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute22;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute22;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE23')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute23;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute23;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE24')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute24;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute24;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE25')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute25;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute25;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE26')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute26;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute26;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE27')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute27;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute27;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE28')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute28;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute28;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE29')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute29;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute29;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            ELSIF (g_field_mappings_table (MAP).ATTRIBUTE = 'ATTRIBUTE30')
            THEN
               IF (g_field_mappings_table (MAP).bld_blk_info_type_id =
                                                        l_bld_blk_info_type_id
                  )
               THEN
                  IF (p_scope = 'DETAIL' AND p_new = 'Y')
                  THEN
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute30;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_detail_attributes (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  ELSIF (p_scope = 'DETAIL' AND p_new = 'N')
                  THEN
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).bb_id :=
                                                          p_building_block_id;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).VALUE :=
                                 p_attribute_table (p_cnt).detail_attribute30;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).field_name :=
                                      g_field_mappings_table (MAP).field_name;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CONTEXT :=
                                         g_field_mappings_table (MAP).CONTEXT;
                     hxc_generic_retrieval_pkg.t_old_detail_attributes
                                                                   (l_att_cnt).CATEGORY :=
                                        g_field_mappings_table (MAP).CATEGORY;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;                                           --  p_scope = 'DETAIL'
   END populate_attributes;

-- private procedure
--   query_it
--
-- description
--   This is the heart of the retrieval process. It retrieves and sorts the time
--   building blocks.
--   Retrieval:
--   The dynanmic SQL is parsed and executed and the dbms_sql arrays defined
--   and initialised. Once all the rows have been fetched the data is moved into
--   one PL/SQL table (see populate_query_table).
--   Sorting:
--   Since the bld blks are retrieved in one query there is some data repetition.
--   We loop through all the rows returned and note when the bld blk id changes
--   at the TIME, DAY and DETAIL scopes and then and only then copy the bld blk
--   to the appropriate global PL/SQL table. At any time a bld blk is copied,
--   any bld blks in the hierarchy above are also copied. The decision to
--   copy a bld blk or not is based upon the max ovn column also populated in the
--   query. For the incremental retrieval this is the ovn of the bld blk last transferred.
--   If they are the same, we do nothing, if it is smaller than the actual ovn then
--   the bld blk has changed and we must transfer. When the retrieval is not incremental
--   then the function max ovn is replaced by the actual ovn + 1 such that we always
--   transfer the bld blk.
--
-- parameters
--   p_query   - the dynamic sql to be run
   PROCEDURE query_it (p_query IN VARCHAR2)
   IS
--
-- define local variables
--
      l_proc                      VARCHAR2 (72);
      l_query_text                VARCHAR2 (32000)                 := p_query;
      l_copy_old                  VARCHAR2 (1)                         := 'N';
      l_count                     PLS_INTEGER;
      l_ind                       PLS_INTEGER;
      l_number_format 		  varchar2(2);
      l_att26    		  number;
-- timecard scope building block local variables
      l_old_timecard_bb_id        hxc_time_building_blocks.time_building_block_id%TYPE
                                                                        := -1;
      l_old_day_bb_id             hxc_time_building_blocks.time_building_block_id%TYPE
                                                                        := -1;
      l_old_detail_bb_id          hxc_time_building_blocks.time_building_block_id%TYPE
                                                                        := -1;
-- timecard scope attribute local variables
      l_old_timecard_ta_id        hxc_time_attributes.time_attribute_id%TYPE
                                                                        := -1;
      l_old_day_ta_id             hxc_time_attributes.time_attribute_id%TYPE
                                                                        := -1;
      l_old_detail_ta_id          hxc_time_attributes.time_attribute_id%TYPE
                                                                        := -1;
-- tables and temporary table local variables
      t_attribute_field_name      tab_ta_field_name;
      t_attribute_value           tab_ta_attribute;
      l_gaz_index                 INTEGER;
-- dynamic SQL local variables
      l_csr                       INTEGER;
      l_max_array_size            INTEGER;
      l_estimated_array_size      INTEGER                                := 0;
      l_rows_fetched              INTEGER;
      l_dummy                     INTEGER;
      l_timecard_copied           VARCHAR2 (1)                         := 'N';
      l_day_copied                VARCHAR2 (1)                         := 'N';
      l_detail_copied             VARCHAR2 (1)                         := 'N';
      l_time_att_copied           VARCHAR2 (1)                         := 'N';
      l_day_att_copied            VARCHAR2 (1)                         := 'N';
      l_detail_att_copied         VARCHAR2 (1)                         := 'N';
      l_bld_blks_to_transfer      VARCHAR2 (1)                         := 'N';

-- table and variable for the time/day/detail bld blk info type registers
      TYPE t_bld_blk_info_type_id IS TABLE OF hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE
         INDEX BY BINARY_INTEGER;

      t_time_bld_blk_info         t_bld_blk_info_type_id;
      t_day_bld_blk_info          t_bld_blk_info_type_id;
      t_detail_bld_blk_info       t_bld_blk_info_type_id;
      l_bld_blk_info_index        PLS_INTEGER;
      e_no_timecards              EXCEPTION;
      e_no_bld_blks_to_transfer   EXCEPTION;
      -- used in incremental when we fetched but no ovn diffs
      l_prefs                     hxc_generic_retrieval_utils.t_pref;
      l_ret_rules                 hxc_generic_retrieval_utils.t_ret_rule;
      l_rtr_outcomes              hxc_generic_retrieval_utils.t_rtr_outcome;
      l_errors                    hxc_generic_retrieval_utils.t_errors;
      l_timecard_retrieve         BOOLEAN;
      l_day_retrieve              BOOLEAN;
      l_error_flag                BOOLEAN;
      l_tc_locked                 BOOLEAN;
      l_tc_first_lock             BOOLEAN;
      l_range                     VARCHAR2 (15);
      l_already_multiplied        varchar2(1) := 'N';
      l_detail_index              number;

      -- Bug 7595581
      -- Retrieval Log

      l_detail_bld_blk_idx	  PLS_INTEGER;
      l_bb_skipped_reason	  VARCHAR2(80);

-- OTL-Absences Integration (Bug 8779478)
      l_detail_attribute_category hxc_time_attributes.attribute_category%TYPE;  -- Absences
      abs_cnt			  PLS_INTEGER;					-- Absences


      CURSOR csr_how_big_is_htbb
      IS
         SELECT COUNT (*)
           FROM hxc_time_building_blocks
          WHERE SCOPE = 'TIMECARD';

    CURSOR get_session_number_format
    is
    SELECT value
    FROM nls_session_parameters
    WHERE parameter = 'NLS_NUMERIC_CHARACTERS';

      l_htbb_size                 NUMBER;



-- define private procedures


     -- Bug 9701936
     -- Added this private procedure to be
     -- called at the end of each chunk to move all
     -- PENDING records to SKIPPED status.

     PROCEDURE skip_pending_records
     IS

       PRAGMA AUTONOMOUS_TRANSACTION;

     BEGIN

         UPDATE hxc_rdb_process_timecards
            SET stage = 'SKIPPED'
          WHERE ret_user_id = FND_GLOBAL.user_id
            AND request_id = FND_GLOBAL.conc_request_id
            AND process = g_params.p_process
            AND stage = 'PENDING';

         COMMIT;

     END skip_pending_records;


      -- private procedure
--   copy_bld_blks
--
-- description
--   Populates the global bld blks PL/SQL tables with the appropriate bld blk information
--   Also maintains the global transaction detail PL/SQL table for each bld blk
--
-- parameters
--   p_bld_blks_table   - PL/SQL table of all bld blk rows
--   pscope    - scope of the bld blk to be copied
--   p_copied     - copied flag used to prevent data duplication in tables
--   p_cnt     - index for p_bld blks_table
--   p_copy_old      - flag to indicate whether or not to maintain the 'old'
--       - bld blks PL/SQL table
      PROCEDURE copy_bld_blks (
         p_bld_blks_table                   t_all_building_blocks,
         p_scope                            VARCHAR2,
         p_copied           IN OUT NOCOPY   VARCHAR2,
         p_cnt                              INTEGER,
         p_copy_old                         VARCHAR2,
         p_errors           IN OUT NOCOPY   hxc_generic_retrieval_utils.t_errors,
         p_error                            BOOLEAN
      )
      IS
         l_bld_blk_index       PLS_INTEGER;
         l_old_bld_blk_index   PLS_INTEGER;
         l_error_index         PLS_INTEGER;
         l_proc                VARCHAR2 (72) := g_package || 'copy_bld_blks';
      BEGIN
         IF (p_scope = 'TIME')
         THEN
            l_bld_blk_index :=
                   NVL (hxc_generic_retrieval_pkg.t_tx_time_bb_id.LAST, 0)
                   + 1;
         ELSIF (p_scope = 'DAY')
         THEN
            l_bld_blk_index :=
                    NVL (hxc_generic_retrieval_pkg.t_tx_day_bb_id.LAST, 0)
                    + 1;
         ELSIF (p_scope = 'DETAIL')
         THEN
            l_bld_blk_index :=
                 NVL (hxc_generic_retrieval_pkg.t_detail_bld_blks.LAST, 0)
                 + 1;
         END IF;

         l_error_index :=
                   NVL (hxc_generic_retrieval_pkg.t_tx_error_bb_id.LAST, 0)
                   + 1;

         IF (p_scope = 'TIME' AND p_copied = 'N')
         THEN
            hxc_generic_retrieval_pkg.t_time_bld_blks (t_bb (p_cnt).time_bb_id
                                                      ).start_time :=
                                                  t_bb (p_cnt).time_start_time;
            hxc_generic_retrieval_pkg.t_time_bld_blks (t_bb (p_cnt).time_bb_id).stop_time :=
                                                   t_bb (p_cnt).time_stop_time;
            hxc_generic_retrieval_pkg.t_time_bld_blks (t_bb (p_cnt).time_bb_id).comment_text :=
                                                t_bb (p_cnt).time_comment_text;

            -- audit the transaction
            IF (NOT p_error)
            THEN
               hxc_generic_retrieval_pkg.t_tx_time_bb_id (l_bld_blk_index) :=
                                                      t_bb (p_cnt).time_bb_id;
               hxc_generic_retrieval_pkg.t_tx_time_bb_ovn (l_bld_blk_index) :=
                                                        t_bb (p_cnt).time_ovn;
               hxc_generic_retrieval_pkg.t_tx_time_status (l_bld_blk_index) :=
                                                                'IN PROGRESS';
               hxc_generic_retrieval_pkg.t_tx_time_exception (l_bld_blk_index) :=
                                                                         NULL;
            ELSE
               hxc_generic_retrieval_pkg.t_tx_error_bb_id (l_error_index) :=
                                                      t_bb (p_cnt).time_bb_id;
               hxc_generic_retrieval_pkg.t_tx_error_bb_ovn (l_error_index) :=
                                                        t_bb (p_cnt).time_ovn;
               hxc_generic_retrieval_pkg.t_tx_error_status (l_error_index) :=
                                                                     'ERRORS';
               hxc_generic_retrieval_pkg.t_tx_error_exception (l_error_index) :=
                  p_errors (t_bb (p_cnt).detail_resource_id).exception_description;
            END IF;

            p_copied := 'Y';
         ELSIF (p_scope = 'DAY' AND p_copied = 'N')
         THEN
            -- audit the transaction
            IF (NOT p_error)
            THEN
               hxc_generic_retrieval_pkg.t_tx_day_parent_id (l_bld_blk_index) :=
                                                      t_bb (p_cnt).time_bb_id;
               hxc_generic_retrieval_pkg.t_tx_day_bb_id (l_bld_blk_index) :=
                                                       t_bb (p_cnt).day_bb_id;
               hxc_generic_retrieval_pkg.t_tx_day_bb_ovn (l_bld_blk_index) :=
                                                         t_bb (p_cnt).day_ovn;
               hxc_generic_retrieval_pkg.t_tx_day_status (l_bld_blk_index) :=
                                                                'IN PROGRESS';
               hxc_generic_retrieval_pkg.t_tx_day_exception (l_bld_blk_index) :=
                                                                         NULL;
            ELSE
               hxc_generic_retrieval_pkg.t_tx_error_bb_id (l_error_index) :=
                                                       t_bb (p_cnt).day_bb_id;
               hxc_generic_retrieval_pkg.t_tx_error_bb_ovn (l_error_index) :=
                                                         t_bb (p_cnt).day_ovn;
               hxc_generic_retrieval_pkg.t_tx_error_status (l_error_index) :=
                                                                     'ERRORS';
               hxc_generic_retrieval_pkg.t_tx_error_exception (l_error_index) :=
                                                                         NULL;
            END IF;

            p_copied := 'Y';
         ELSIF (p_scope = 'DETAIL' AND p_copied = 'N')
         THEN
            IF (NOT p_error)
            THEN
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).bb_id :=
                                                    t_bb (p_cnt).detail_bb_id;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).parent_bb_id :=
                                             t_bb (p_cnt).detail_parent_bb_id;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).resource_type :=
                                            t_bb (p_cnt).detail_resource_type;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).resource_id :=
                                              t_bb (p_cnt).detail_resource_id;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).comment_text :=
                                             t_bb (p_cnt).detail_comment_text;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).start_time :=
                                                  t_bb (p_cnt).day_start_time;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).stop_time :=
                                                   t_bb (p_cnt).day_stop_time;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).measure :=
                                                  t_bb (p_cnt).detail_measure;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).uom :=
                                                      t_bb (p_cnt).detail_uom;

               IF (t_bb (p_cnt).detail_type = 'RANGE')
               THEN
                  hxc_generic_retrieval_pkg.t_detail_bld_blks
                                                             (l_bld_blk_index).start_time :=
                                               t_bb (p_cnt).detail_start_time;
                  hxc_generic_retrieval_pkg.t_detail_bld_blks
                                                             (l_bld_blk_index).stop_time :=
                                                t_bb (p_cnt).detail_stop_time;
                  hxc_generic_retrieval_pkg.t_detail_bld_blks
                                                             (l_bld_blk_index).measure :=
                       (  t_bb (p_cnt).detail_stop_time
                        - t_bb (p_cnt).detail_start_time
                       )
                     * 24;
                  hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).uom :=
                                                                       'HOURS';
               END IF;

               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).SCOPE :=
                                                     t_bb (p_cnt).detail_scope;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).TYPE :=
                                                      t_bb (p_cnt).detail_type;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).deleted :=
                                                   t_bb (p_cnt).detail_deleted;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).ovn :=
                                                       t_bb (p_cnt).detail_ovn;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).timecard_bb_id :=
                                                       t_bb (p_cnt).time_bb_id;
               hxc_generic_retrieval_pkg.t_detail_bld_blks (l_bld_blk_index).timecard_ovn :=
                                                         t_bb (p_cnt).time_ovn;
               -- set the bld blks to transfer flag if any DETAIL bld blks to transfer
               l_bld_blks_to_transfer := 'Y';

-- maintain arrays for old building block
               IF (p_copy_old = 'Y')
               THEN
                  l_old_bld_blk_index := NVL (t_old_detail_bb_id.LAST, 0) + 1;
                  t_old_detail_seq (l_old_bld_blk_index) :=
                                                          l_old_bld_blk_index;
                  t_old_detail_bb_id (l_old_bld_blk_index) :=
                                                    t_bb (p_cnt).detail_bb_id;
                  t_old_detail_ovn (l_old_bld_blk_index) :=
                                                  t_bb (p_cnt).detail_max_ovn;
                  hxc_generic_retrieval_pkg.t_detail_bld_blks
                                                             (l_bld_blk_index).changed :=
                                                                          'Y';
               ELSE
                  hxc_generic_retrieval_pkg.t_detail_bld_blks
                                                             (l_bld_blk_index).changed :=
                                                                          'N';
               END IF;
            END IF;                                          -- if not p_error

            -- audit the transaction
            IF (NOT p_error)
            THEN
               hxc_generic_retrieval_pkg.t_tx_detail_parent_id
                                                             (l_bld_blk_index) :=
                                                       t_bb (p_cnt).day_bb_id;
               hxc_generic_retrieval_pkg.t_tx_detail_bb_id (l_bld_blk_index) :=
                                                    t_bb (p_cnt).detail_bb_id;
               hxc_generic_retrieval_pkg.t_tx_detail_bb_ovn (l_bld_blk_index) :=
                                                      t_bb (p_cnt).detail_ovn;
               hxc_generic_retrieval_pkg.t_tx_detail_status (l_bld_blk_index) :=
                                                                'IN PROGRESS';
               hxc_generic_retrieval_pkg.t_tx_detail_exception
                                                             (l_bld_blk_index) :=
                                                                         NULL;
            ELSE
               hxc_generic_retrieval_pkg.t_tx_error_bb_id (l_error_index) :=
                                                    t_bb (p_cnt).detail_bb_id;
               hxc_generic_retrieval_pkg.t_tx_error_bb_ovn (l_error_index) :=
                                                      t_bb (p_cnt).detail_ovn;
               hxc_generic_retrieval_pkg.t_tx_error_status (l_error_index) :=
                                                                     'ERRORS';
               hxc_generic_retrieval_pkg.t_tx_error_exception (l_error_index) :=
                                                                         NULL;
            END IF;

            p_copied := 'Y';
         END IF;
      END copy_bld_blks;

-- private function
--   att_copied_before ?
--
-- description
--   Polls the temporary attribute PL/SQL table to ensure that this attribute has not been copied
--   already.
--   Returns TRUE if copied before, FALSE, if not
--
-- parameters
--   p_scope   - scope
--   p_bld_blk_info_type_id - bld blk info type id
      FUNCTION att_copied_before (
         p_scope                  VARCHAR2,
         p_bld_blk_info_type_id   hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE
      )
         RETURN BOOLEAN

      IS
      BEGIN
         IF p_scope = 'TIME'
         THEN
            IF t_time_bld_blk_info.COUNT <> 0
            THEN
               FOR x IN t_time_bld_blk_info.FIRST .. t_time_bld_blk_info.LAST
               LOOP
                  IF t_time_bld_blk_info (x) = p_bld_blk_info_type_id
                  THEN
                     RETURN TRUE;
                  END IF;
               END LOOP;

               RETURN FALSE;
            ELSE
               RETURN FALSE;
            END IF;
         ELSIF p_scope = 'DAY'
         THEN
            IF t_day_bld_blk_info.COUNT <> 0
            THEN
               FOR x IN t_day_bld_blk_info.FIRST .. t_day_bld_blk_info.LAST
               LOOP
                  IF t_day_bld_blk_info (x) = p_bld_blk_info_type_id
                  THEN
                     RETURN TRUE;
                  END IF;
               END LOOP;

               RETURN FALSE;
            ELSE
               RETURN FALSE;
            END IF;
         ELSIF p_scope = 'DETAIL'
         THEN
            IF t_detail_bld_blk_info.COUNT <> 0
            THEN
               FOR x IN
                  t_detail_bld_blk_info.FIRST .. t_detail_bld_blk_info.LAST
               LOOP
                  IF t_detail_bld_blk_info (x) = p_bld_blk_info_type_id
                  THEN
                     RETURN TRUE;
                  END IF;
               END LOOP;

               RETURN FALSE;
            ELSE
               RETURN FALSE;
            END IF;
         END IF;
      END att_copied_before;

   BEGIN                                                           -- query_it
      IF g_debug
      THEN
         l_proc := g_package || 'query_it';
         hr_utility.set_location ('Entering ' || l_proc, 10);
      END IF;

    OPEN get_session_number_format;
    FETCH get_session_number_format into l_number_format;
    CLOSE get_session_number_format;

      l_max_array_size := 100;
      l_rows_fetched := l_max_array_size;

      IF g_debug
      THEN
         hr_utility.set_location ('Processing ' || l_proc, 20);
      END IF;

      l_csr := DBMS_SQL.open_cursor;

      IF g_debug
      THEN
         hr_utility.set_location ('Processing ' || l_proc, 30);
      END IF;

      DBMS_SQL.parse (l_csr, l_query_text, DBMS_SQL.native);

-- bind variables needed by all queries
      IF (g_params.p_process IN
             ('Projects Retrieval Process',
              'BEE Retrieval Process',
              'Apply Schedule Rules',
              'Purchasing Retrieval Process'
             )
         )
      THEN
         NULL;                 -- no more binds - bound in pop ret range blks
      ELSE
         DBMS_SQL.bind_variable (l_csr, ':p_lower_range', l_pkg_range_start);
         DBMS_SQL.bind_variable (l_csr, ':p_upper_range', l_pkg_range_stop);

         IF (g_params.p_incremental = 'Y')
         THEN
            DBMS_SQL.bind_variable (l_csr,
                                    ':p_process_id',
                                    g_retrieval_process_id
                                   );
         END IF;

         -- bind the start and end date parameters
         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 35);
         END IF;

         IF (    (    g_params.p_start_date IS NOT NULL
                  AND g_params.p_end_date IS NOT NULL
                 )
             AND (g_params.p_rerun_flag = 'N')
            )
         THEN
            DBMS_SQL.bind_variable (l_csr,
                                    ':p_start_date',
                                    g_params.p_start_date
                                   );
            DBMS_SQL.bind_variable (l_csr, ':p_end_date', g_params.p_end_date);
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Processing ' || l_proc, 37);
      END IF;

      IF (g_params.p_rerun_flag = 'Y')
      THEN
         DBMS_SQL.bind_variable (l_csr,
                                 ':p_transaction_code',
                                 g_params.p_transaction_code
                                );
      END IF;

-- define arrays for each item in the select list
      IF g_debug
      THEN
         hr_utility.set_location ('Processing ' || l_proc, 40);
      END IF;

      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 1,
                             n_tab            => t_timecard_bb_id,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 2,
                             n_tab            => t_timecard_ovn,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 3,
                             n_tab            => t_day_bb_id,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 4,
                             n_tab            => t_day_ovn,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 5,
                             d_tab            => t_day_start_time,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 6,
                             d_tab            => t_day_stop_time,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 7,
                             n_tab            => t_detail_bb_id,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 8,
                             n_tab            => t_detail_ovn,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 9,
                             n_tab            => t_detail_parent_id,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 10,
                             c_tab            => t_detail_resource_type,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 11,
                             n_tab            => t_detail_resource_id,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 12,
                             c_tab            => t_detail_comment_text,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 13,
                             d_tab            => t_detail_start_time,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 14,
                             d_tab            => t_detail_stop_time,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 15,
                             n_tab            => t_detail_measure,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 16,
                             c_tab            => t_detail_scope,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 17,
                             c_tab            => t_detail_type,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 18,
                             n_tab            => t_detail_ta_id,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 19,
                             n_tab            => t_detail_bld_blk_info_type_id,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 20,
                             c_tab            => t_detail_attribute1,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 21,
                             c_tab            => t_detail_attribute2,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 22,
                             c_tab            => t_detail_attribute3,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 23,
                             c_tab            => t_detail_attribute4,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 24,
                             c_tab            => t_detail_attribute5,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 25,
                             c_tab            => t_detail_attribute6,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 26,
                             c_tab            => t_detail_attribute7,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 27,
                             c_tab            => t_detail_attribute8,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 28,
                             c_tab            => t_detail_attribute9,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 29,
                             c_tab            => t_detail_attribute10,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 30,
                             c_tab            => t_detail_attribute11,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 31,
                             c_tab            => t_detail_attribute12,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 32,
                             c_tab            => t_detail_attribute13,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 33,
                             c_tab            => t_detail_attribute14,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 34,
                             c_tab            => t_detail_attribute15,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 35,
                             c_tab            => t_detail_attribute16,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 36,
                             c_tab            => t_detail_attribute17,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 37,
                             c_tab            => t_detail_attribute18,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 38,
                             c_tab            => t_detail_attribute19,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 39,
                             c_tab            => t_detail_attribute20,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 40,
                             c_tab            => t_detail_attribute21,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 41,
                             c_tab            => t_detail_attribute22,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 42,
                             c_tab            => t_detail_attribute23,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 43,
                             c_tab            => t_detail_attribute24,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 44,
                             c_tab            => t_detail_attribute25,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 45,
                             c_tab            => t_detail_attribute26,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 46,
                             c_tab            => t_detail_attribute27,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 47,
                             c_tab            => t_detail_attribute28,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 48,
                             c_tab            => t_detail_attribute29,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 49,
                             c_tab            => t_detail_attribute30,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 50,
                             d_tab            => t_detail_date_from,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 51,
                             d_tab            => t_detail_date_to,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 52,
                             c_tab            => t_detail_approval_status,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 53,
                             n_tab            => t_detail_approval_style_id,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 54,
                             c_tab            => t_detail_deleted,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 55,
                             c_tab            => t_detail_attribute_category,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 56,
                             n_tab            => t_timecard_max_ovn,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 57,
                             n_tab            => t_day_max_ovn,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 58,
                             n_tab            => t_detail_max_ovn,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 59,
                             c_tab            => t_detail_uom,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 60,
                             d_tab            => t_timecard_start_time,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 61,
                             d_tab            => t_timecard_stop_time,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 62,
                             c_tab            => t_timecard_comment_text,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );
      DBMS_SQL.define_array (c                => l_csr,
                             POSITION         => 63,
                             c_tab            => t_timecard_deleted,
                             cnt              => l_max_array_size,
                             lower_bound      => 1
                            );

      IF g_debug
      THEN
         hr_utility.set_location ('Processing ' || l_proc, 50);
      END IF;

      l_dummy := DBMS_SQL.EXECUTE (l_csr);

      IF g_debug
      THEN
         hr_utility.set_location ('Processing ' || l_proc, 60);
      END IF;

-- loop to ensure we fetch all the rows
      WHILE (l_rows_fetched = l_max_array_size)
      LOOP
         l_rows_fetched := DBMS_SQL.fetch_rows (l_csr);

         IF (l_rows_fetched = 0 AND t_bb.COUNT = 0)
         THEN
            DBMS_SQL.close_cursor (l_csr);
            -- Bug 8888911
            -- Marking that this is an empty chunk.
            put_log('  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            put_log('   This is an empty chunk : No records relevant for these resources ');
            put_log('  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            IF g_debug
            THEN
               hr_utility.trace('This is an empty chunk ');
            END IF;
            RAISE e_no_timecards;
         END IF;

         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 1,
                                n_tab         => t_timecard_bb_id
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 2,
                                n_tab         => t_timecard_ovn
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 3,
                                n_tab         => t_day_bb_id
                               );
         DBMS_SQL.column_value (c             => l_csr, POSITION => 4,
                                n_tab         => t_day_ovn);
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 5,
                                d_tab         => t_day_start_time
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 6,
                                d_tab         => t_day_stop_time
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 7,
                                n_tab         => t_detail_bb_id
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 8,
                                n_tab         => t_detail_ovn
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 9,
                                n_tab         => t_detail_parent_id
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 10,
                                c_tab         => t_detail_resource_type
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 11,
                                n_tab         => t_detail_resource_id
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 12,
                                c_tab         => t_detail_comment_text
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 13,
                                d_tab         => t_detail_start_time
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 14,
                                d_tab         => t_detail_stop_time
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 15,
                                n_tab         => t_detail_measure
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 16,
                                c_tab         => t_detail_scope
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 17,
                                c_tab         => t_detail_type
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 18,
                                n_tab         => t_detail_ta_id
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 19,
                                n_tab         => t_detail_bld_blk_info_type_id
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 20,
                                c_tab         => t_detail_attribute1
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 21,
                                c_tab         => t_detail_attribute2
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 22,
                                c_tab         => t_detail_attribute3
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 23,
                                c_tab         => t_detail_attribute4
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 24,
                                c_tab         => t_detail_attribute5
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 25,
                                c_tab         => t_detail_attribute6
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 26,
                                c_tab         => t_detail_attribute7
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 27,
                                c_tab         => t_detail_attribute8
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 28,
                                c_tab         => t_detail_attribute9
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 29,
                                c_tab         => t_detail_attribute10
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 30,
                                c_tab         => t_detail_attribute11
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 31,
                                c_tab         => t_detail_attribute12
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 32,
                                c_tab         => t_detail_attribute13
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 33,
                                c_tab         => t_detail_attribute14
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 34,
                                c_tab         => t_detail_attribute15
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 35,
                                c_tab         => t_detail_attribute16
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 36,
                                c_tab         => t_detail_attribute17
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 37,
                                c_tab         => t_detail_attribute18
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 38,
                                c_tab         => t_detail_attribute19
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 39,
                                c_tab         => t_detail_attribute20
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 40,
                                c_tab         => t_detail_attribute21
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 41,
                                c_tab         => t_detail_attribute22
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 42,
                                c_tab         => t_detail_attribute23
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 43,
                                c_tab         => t_detail_attribute24
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 44,
                                c_tab         => t_detail_attribute25
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 45,
                                c_tab         => t_detail_attribute26
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 46,
                                c_tab         => t_detail_attribute27
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 47,
                                c_tab         => t_detail_attribute28
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 48,
                                c_tab         => t_detail_attribute29
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 49,
                                c_tab         => t_detail_attribute30
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 50,
                                d_tab         => t_detail_date_from
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 51,
                                d_tab         => t_detail_date_to
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 52,
                                c_tab         => t_detail_approval_status
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 53,
                                n_tab         => t_detail_approval_style_id
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 54,
                                c_tab         => t_detail_deleted
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 55,
                                c_tab         => t_detail_attribute_category
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 56,
                                n_tab         => t_timecard_max_ovn
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 57,
                                n_tab         => t_day_max_ovn
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 58,
                                n_tab         => t_detail_max_ovn
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 59,
                                c_tab         => t_detail_uom
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 60,
                                d_tab         => t_timecard_start_time
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 61,
                                d_tab         => t_timecard_stop_time
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 62,
                                c_tab         => t_timecard_comment_text
                               );
         DBMS_SQL.column_value (c             => l_csr,
                                POSITION      => 63,
                                c_tab         => t_timecard_deleted
                               );
-- to make the data more manageable copy the arrays into PL/SQL tables
-- and save space
         populate_query_table;
      END LOOP;

      DBMS_SQL.close_cursor (l_csr);

      IF g_debug
      THEN
         hr_utility.set_location ('Processing ' || l_proc, 110);
      END IF;

      IF (g_params.p_incremental = 'N')
      THEN
         -- need to populate resources table since max_ovn was not called
         FOR x IN t_bb.FIRST .. t_bb.LAST
         LOOP
            IF NOT (hxc_generic_retrieval_utils.g_resources.EXISTS
                                                   (t_bb (x).detail_resource_id
                                                   )
                   )
            THEN
               hxc_generic_retrieval_utils.g_resources
                                                  (t_bb (x).detail_resource_id
                                                  ).resource_id :=
                                                   t_bb (x).detail_resource_id;
               hxc_generic_retrieval_utils.g_resources
                                                   (t_bb (x).detail_resource_id
                                                   ).start_time :=
                                                        hr_general.end_of_time;
               hxc_generic_retrieval_utils.g_resources
                                                   (t_bb (x).detail_resource_id
                                                   ).stop_time :=
                                                      hr_general.start_of_time;
            END IF;
         END LOOP;
      END IF;

-- initialise tables
      IF g_debug
      THEN
         hr_utility.TRACE ('Params to parse_resources......');
         hr_utility.TRACE ('Process id is '
                           || TO_CHAR (g_retrieval_process_id)
                          );
         hr_utility.TRACE (   'Time Recipient id is '
                           || TO_CHAR (g_retrieval_tr_id)
                          );
      END IF;

      l_prefs.DELETE;
      l_ret_rules.DELETE;
      l_rtr_outcomes.DELETE;
      hxc_generic_retrieval_utils.parse_resources
                                      (p_process_id        => g_retrieval_process_id,
                                       p_ret_tr_id         => g_retrieval_tr_id,
                                       p_prefs             => l_prefs,
                                       p_ret_rules         => l_ret_rules,
                                       p_rtr_outcomes      => l_rtr_outcomes,
                                       p_errors            => l_errors
                                      );

      IF g_debug
      THEN
         hr_utility.TRACE (' *********** - GLOBAL TABLE INFO ************ ');
      END IF;

      l_count := hxc_generic_retrieval_utils.g_resources.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('Resources         : ' || TO_CHAR (l_count));
      END IF;

      l_count := t_bb.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('master bld blks   : ' || TO_CHAR (l_count));
      END IF;

      l_count := l_prefs.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('Prefs             : ' || TO_CHAR (l_count));
      END IF;

      l_count := l_ret_rules.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('Retrieval Rules   : ' || TO_CHAR (l_count));
      END IF;

      l_count := l_rtr_outcomes.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('Ret Rule Outcomes : ' || TO_CHAR (l_count));
      END IF;

      l_count := l_errors.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('Errors : ' || TO_CHAR (l_count));
      END IF;

-- now loop through the table and populate the building block table for those bld blks which have
-- changed
      IF g_debug
      THEN
         hr_utility.TRACE ('');
         hr_utility.TRACE ('****** Populating Global PL/SQL tables *******');
         hr_utility.TRACE ('');
      END IF;

      FOR cnt IN t_bb.FIRST .. t_bb.LAST
      LOOP
--if g_debug then
   -- hr_utility.set_location('Processing '||l_proc, 130);
--end if;

         -- Intitialise timecard scope variables
         IF (t_bb (cnt).time_bb_id <> l_old_timecard_bb_id)
         THEN
            -- set old time card id and reset copied flag

            --if g_debug then
   -- hr_utility.trace('GAZ t bb is '||to_char(t_bb(cnt).time_bb_id));
--end if;
            l_timecard_retrieve := TRUE;
            l_day_retrieve := TRUE;
            l_old_timecard_bb_id := t_bb (cnt).time_bb_id;
            l_timecard_copied := 'N';
            l_tc_locked := FALSE;
            l_tc_first_lock := TRUE;

            IF (l_errors.EXISTS (t_bb (cnt).detail_resource_id))
            THEN
               l_error_flag := TRUE;
            ELSE
               l_error_flag := FALSE;
            END IF;

            -- clear out table of copied bld blk info types for this bb_id
            t_time_bld_blk_info.DELETE;
         END IF;                                  -- timecard id changed check

-- if g_debug then
   --hr_utility.set_location('Processing '||l_proc, 140);
--end if;

         -- Initialise and maintain DAY scope variables
         IF (t_bb (cnt).day_bb_id <> l_old_day_bb_id)
         THEN
            -- set count and old bld blk id
            l_old_day_bb_id := t_bb (cnt).day_bb_id;
            l_day_copied := 'N';
            -- clear out table of copied bld blk info types for this bb_id
            t_day_bld_blk_info.DELETE;
         END IF;

-- if g_debug then
   --hr_utility.set_location('Processing '||l_proc, 160);
--end if;

         -- Maintain Detail building blocks
         IF (t_bb (cnt).detail_bb_id <> l_old_detail_bb_id)
         THEN
            -- set count and old time card id

            -- if g_debug then
   --hr_utility.trace('GAZ tbb DETAIL is '||to_char(t_bb(cnt).detail_bb_id));
--end if;
            l_old_detail_bb_id := t_bb (cnt).detail_bb_id;
            l_detail_copied := 'N';
             l_already_multiplied := 'N'; --DAYS Vs HOURS
            -- clear out table of copied bld blk info types for this bb_id
            t_detail_bld_blk_info.DELETE;
            l_day_retrieve := TRUE;

            -- Do not transfer if deleted and never transferred prior
            -- ( WWB 3503607 GPM v115.102 )

            -- Bug 7595581
            -- Retrieval Log

            l_bb_skipped_reason := null;
            IF (    t_bb (cnt).detail_deleted = 'Y'
                AND t_bb (cnt).detail_max_ovn = 0
               )
            THEN
               l_day_retrieve := FALSE;

               -- Not transferring the deleted entries, but then they might need an adj
               -- ustment if the processes are BEE retrieval and Apply Schedules and the
               -- preference for Rule evaluation is changed after it its transferred.
               -- Checking that up here.
               -- Bug 8366309
               -- Check preferences before adjusting the deleted entries.

               IF    ( g_params.p_process IN ('BEE Retrieval Process',
                                              'Apply Schedule Rules') )
                 AND (hxc_generic_retrieval_utils.chk_otm_pref( t_bb(cnt).detail_resource_id,
                                                                t_bb(cnt).day_start_time,
                                                                g_retrieval_process_id))
                 AND (hxc_generic_retrieval_utils.chk_need_adj( t_bb (cnt).time_bb_id,
                                                                t_bb (cnt).time_ovn,
                                                                t_bb (cnt).detail_resource_id,
                                                                t_bb (cnt).day_start_time,
                                                                t_bb (cnt).detail_bb_id,
                                                                t_bb (cnt).detail_ovn, -- Bug 8366309
                                                                'Y',                   -- Bug 8366309;  Deleted = 'Y'
                                                                g_retrieval_process_id ) )
               THEN
                  IF g_debug
                  THEN
                     hr_utility.trace('Resource '||t_bb (cnt).detail_resource_id||
                    'had  a different rules evaluation pref and needs adj this time');
                  END IF;
               END IF;

            ELSE

               -- Absences starts
               -- OTL-Absences Integration (Bug 8779478)

               l_detail_attribute_category := null;

               abs_cnt := cnt;

               LOOP
               EXIT WHEN (t_bb (abs_cnt).detail_bb_id <> t_bb (cnt).detail_bb_id);

                    IF (t_bb (abs_cnt).detail_attribute_category like 'ELEMENT%') THEN
			l_detail_attribute_category := t_bb (abs_cnt).detail_attribute_category   ;
			EXIT;
                    ELSE
                        abs_cnt := abs_cnt + 1;
                        -- Bug 8892988
                        -- Added the below exit condition to get rid of
                        -- 1403 errors
                        IF NOT t_bb.EXISTS(abs_cnt)
                        THEN
                           EXIT;
                        END IF;
                    END IF;

               END LOOP;

               -- Absences ends


               hr_utility.TRACE ('about to call chk retrieve');
               hxc_generic_retrieval_utils.chk_retrieve
                            (p_resource_id            => t_bb (cnt).detail_resource_id,
                             p_bb_status              => t_bb (cnt).detail_approval_status,
                             p_bb_deleted             => t_bb (cnt).time_deleted,
                             p_bb_start_time          => t_bb (cnt).day_start_time,
                             p_bb_stop_time           => t_bb (cnt).day_stop_time,
                             p_bb_id                  => t_bb (cnt).detail_bb_id,
                             p_bb_ovn                 => t_bb (cnt).detail_ovn,
                             p_attribute_category     => l_detail_attribute_category,   -- Bug 8779478
                             p_process                => g_params.p_process,
                             p_prefs                  => l_prefs,
                             p_ret_rules              => l_ret_rules,
                             p_rtr_outcomes           => l_rtr_outcomes,
                             p_tc_bb_id               => t_bb (cnt).time_bb_id,
                             p_tc_bb_ovn              => t_bb (cnt).time_ovn,
                             p_timecard_retrieve      => l_timecard_retrieve,
                             p_day_retrieve           => l_day_retrieve,
                             p_tc_locked              => l_tc_locked,
                             p_tc_first_lock          => l_tc_first_lock,
                             p_bb_skipped_reason      => l_bb_skipped_reason   -- Bug 7595581
                            );
               hr_utility.TRACE ('after to call chk retrieve');
            END IF;                         -- chk deleted and not transferred

            -- if this detail block has not already been copied and the object version numbers
            -- are different then we need this building block and the day and time bld blks

            -- Bug 7595581
            -- Retrieval Log

            IF(l_bb_skipped_reason IS NULL)
            THEN
                        -- Bug 9657355
	    		l_bb_skipped_reason := 'Block is deleted and was not transferred earlier';
	    END IF;


            IF (   (    (l_detail_copied = 'N')
                    AND (t_bb (cnt).detail_ovn > t_bb (cnt).detail_max_ovn)
                    AND (l_day_retrieve)
                   )
                OR (l_error_flag)
               )
            THEN
               -- maintain time bld blk table

		-- Bug 7595581
                -- Retrieval Log
		g_rtr_detail_blks(t_bb(cnt).detail_bb_id).dummy := 'Y';

            /* -- only populate old DETAIL

                     IF ( t_bb(cnt).time_max_ovn <> 0 )
                     THEN
                        l_copy_old  := 'Y';
                     ELSE
                        l_copy_old  := 'N';
                     END IF;
               */
               copy_bld_blks (p_bld_blks_table      => t_bb,
                              p_scope               => 'TIME',
                              p_copied              => l_timecard_copied,
                              p_cnt                 => cnt,
                              p_copy_old            => 'N',
                              p_errors              => l_errors,
                              p_error               => l_error_flag
                             );
               -- maintain day bld blk table

               /* -- Only populate old DETAIL

                     IF ( t_bb(cnt).day_max_ovn <> 0 )
                     THEN
                        l_copy_old  := 'Y';
                     ELSE
                        l_copy_old  := 'N';
                     END IF;
               */
               copy_bld_blks (p_bld_blks_table      => t_bb,
                              p_scope               => 'DAY',
                              p_copied              => l_day_copied,
                              p_cnt                 => cnt,
                              p_copy_old            => 'N',
                              p_errors              => l_errors,
                              p_error               => l_error_flag
                             );

               IF (t_bb (cnt).detail_max_ovn <> 0)
               THEN
                  l_copy_old := 'Y';
               ELSE
                  l_copy_old := 'N';
               END IF;

               -- maintain detail bld blk table
               copy_bld_blks (p_bld_blks_table      => t_bb,
                              p_scope               => 'DETAIL',
                              p_copied              => l_detail_copied,
                              p_cnt                 => cnt,
                              p_copy_old            => l_copy_old,
                              p_errors              => l_errors,
                              p_error               => l_error_flag
                             );


		-- Bug 7595581
                -- Retrieval Log

		ELSE
		  IF(NOT (g_rtr_detail_blks.EXISTS(t_bb(cnt).detail_bb_id))) THEN
				l_detail_bld_blk_idx := NVL (hxc_generic_retrieval_pkg.g_detail_skipped.LAST, 0) + 1;

				hxc_generic_retrieval_pkg.g_detail_skipped(l_detail_bld_blk_idx).resource_id
										:= t_bb(cnt).detail_resource_id;
				hxc_generic_retrieval_pkg.g_detail_skipped(l_detail_bld_blk_idx).timecard_id
										:= t_bb(cnt).time_bb_id;
				hxc_generic_retrieval_pkg.g_detail_skipped(l_detail_bld_blk_idx).timecard_ovn
										:= t_bb(cnt).time_ovn;
				hxc_generic_retrieval_pkg.g_detail_skipped(l_detail_bld_blk_idx).bb_id
										:= t_bb(cnt).detail_bb_id;
				hxc_generic_retrieval_pkg.g_detail_skipped(l_detail_bld_blk_idx).ovn
										:= t_bb(cnt).detail_ovn;
				hxc_generic_retrieval_pkg.g_detail_skipped(l_detail_bld_blk_idx).description
										:= l_bb_skipped_reason;

		  END IF;


            END IF;                                               -- check ovn
         END IF;

         --***********DAYS Vs HOURS************
         IF g_params.p_process = 'Projects Retrieval Process' THEN
	  l_detail_index := NVL (hxc_generic_retrieval_pkg.t_detail_bld_blks.LAST, 0);

	 IF l_detail_index<> 0 THEN

	  IF  hxc_generic_retrieval_pkg.t_detail_bld_blks(l_detail_index).bb_id
		= t_bb(cnt).detail_bb_id  THEN

		IF l_number_format = ',.'  THEN --EUROPEAN FORMAT
		   l_att26 := to_number(replace(t_bb(cnt).detail_attribute26,'.',','));
		ELSIF  l_number_format = '.,'  THEN --US FORMAT
		   l_att26 := to_number(replace(t_bb(cnt).detail_attribute26,',','.'));
		END IF;

	      IF nvl(l_att26,1) <> 1 AND l_already_multiplied = 'N' THEN

		hxc_generic_retrieval_pkg.t_detail_bld_blks(l_detail_index).measure :=
		hxc_generic_retrieval_pkg.t_detail_bld_blks(l_detail_index).measure * l_att26;

		l_already_multiplied := 'Y';

	      END IF;

	  END IF;
	 END IF;
	END IF;
        --***********DAYS Vs HOURS************

-- Maintain Timecard Attribute rows
         IF (NOT l_error_flag)
         THEN
            IF (    l_day_retrieve
                AND (t_bb (cnt).detail_ovn > t_bb (cnt).detail_max_ovn)
               )
            THEN
               -- Maintain Detail Attribute rows

               -- must not forget that there may not be any attributes for the detail scope
               -- hence r_csr_tbb.detail_time_attribute_id may be null
               IF (    (t_bb (cnt).detail_ta_id <> l_old_detail_ta_id)
                   AND (t_bb (cnt).detail_ta_id IS NOT NULL)
                  )
               THEN
                  -- set old time card time attribute id
                  l_old_detail_ta_id := t_bb (cnt).detail_ta_id;

                  IF (att_copied_before
                         (p_scope                     => 'DETAIL',
                          p_bld_blk_info_type_id      => t_bb (cnt).detail_bld_blk_info_type_id
                         )
                     )
                  THEN
                     l_detail_att_copied := 'Y';
                  ELSE
                     l_detail_att_copied := 'N';
                  END IF;

                  -- check to see if these are attributes for a bld blk that needs to be transferred
                  IF (l_detail_att_copied = 'N')
                  THEN
                     -- loop through the global field mappings table to map attribute value to field
                     -- name and populate the detail attribute tables
                     populate_attributes
                              (p_building_block_id      => t_bb (cnt).detail_bb_id,
                               p_attribute_table        => t_bb,
                               p_cnt                    => cnt,
                               p_scope                  => 'DETAIL',
                               p_new                    => 'Y'
                              );
                     l_detail_att_copied := 'Y';
                     l_bld_blk_info_index :=
                                        NVL (t_detail_bld_blk_info.LAST, 0)
                                        + 1;
                     t_detail_bld_blk_info (l_bld_blk_info_index) :=
                                        t_bb (cnt).detail_bld_blk_info_type_id;
                  END IF;
               END IF;
            END IF;                     -- l_day_retrieve and detail ovn check
         END IF;                                    -- IF ( NOT l_error_flag )
      END LOOP;                                                -- csr_tbb loop

-- check to see if out of any of the timecards retrieved in the query were
-- copied to the global PL/SQL tables
      IF (l_bld_blks_to_transfer = 'N')
      THEN
         RAISE e_no_bld_blks_to_transfer;
      ELSE
         hxc_generic_retrieval_pkg.g_no_timecards := FALSE;
         hxc_generic_retrieval_pkg.g_overall_no_timecards := FALSE;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE (' *********** - GLOBAL TABLE INFO ************ ');
      END IF;

      l_count := hxc_generic_retrieval_pkg.t_detail_bld_blks.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('DETAIL bld blks       : ' || TO_CHAR (l_count));
      END IF;

      l_count := hxc_generic_retrieval_pkg.t_detail_attributes.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('DETAIL attributes     : ' || TO_CHAR (l_count));
      END IF;

      l_count := hxc_generic_retrieval_pkg.t_tx_detail_bb_id.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('DETAIL txd count is ' || TO_CHAR (l_count));
      END IF;

      l_count := hxc_generic_retrieval_pkg.t_tx_error_bb_id.COUNT;

      IF g_debug
      THEN
         hr_utility.TRACE ('ERROR txd count is ' || TO_CHAR (l_count));
      END IF;

-- delete the table
      t_bb.DELETE;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving ' || l_proc, 200);
      END IF;
   EXCEPTION
      WHEN e_no_timecards
      THEN
         hxc_generic_retrieval_utils.g_resources.DELETE;

         IF (NOT hxc_generic_retrieval_pkg.g_in_loop)
         THEN
            audit_transaction
                         (p_mode                        => 'I'       -- Insert
                                                              ,
                          p_transaction_process_id      => g_retrieval_process_id,
                          p_status                      => 'WARNINGS',
                          p_description                 => 'HXC_0012_GNRET_NO_TIMECARDS'
                         );
         END IF;

         -- Bug 9701936
         -- Added this call to move PENDING records to SKIPPED Status
         skip_pending_records;

         fnd_message.set_name ('HXC', 'HXC_0012_GNRET_NO_TIMECARDS');
         fnd_message.raise_error;
      WHEN e_no_bld_blks_to_transfer
      THEN
         t_bb.DELETE;
         hxc_generic_retrieval_utils.g_resources.DELETE;

         IF (NOT hxc_generic_retrieval_pkg.g_in_loop)
         THEN
            audit_transaction
                         (p_mode                        => 'I'       -- Insert
                                                              ,
                          p_transaction_process_id      => g_retrieval_process_id,
                          p_status                      => 'WARNINGS',
                          p_description                 => 'HXC_0013_GNRET_NO_BLD_BLKS'
                         );
         ELSIF (l_errors.COUNT <> 0)
         THEN
            -- Must maintain the errors WWB 3517746
            audit_transaction
                         (p_mode                        => 'I'       -- Insert
                                                              ,
                          p_transaction_process_id      => g_retrieval_process_id,
                          p_status                      => 'WARNINGS',
                          p_description                 => 'HXC_0013_GNRET_NO_BLD_BLKS'
                         );
         END IF;

         fnd_message.set_name ('HXC', 'HXC_0013_GNRET_NO_BLD_BLKS');
         fnd_message.raise_error;
      WHEN OTHERS
      THEN
         -- Bug 9394444
         hr_utility.trace(dbms_utility.format_error_backtrace);
         audit_transaction
                         (p_mode                        => 'I'       -- Insert
                                                              ,
                          p_transaction_process_id      => g_retrieval_process_id,
                          p_status                      => 'WARNINGS',
                          p_description                 => SUBSTR (SQLERRM,
                                                                   1,
                                                                   2000
                                                                  )
                         );
         RAISE;
   END query_it;

-- private procedure
--   query_old_timecard
--
-- description
--   this queries the bld blk last transferred.
--   we populate a temporary table with the bld blk id and ovn
--   of the last transferred bld blk and then bulk collect
--
-- parameters
--   none
   PROCEDURE query_old_timecard
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
--
-- define local variables
--
      l_proc                       VARCHAR2 (100);

      CURSOR gaz_chk_tmp_table
      IS
         SELECT 'x'
           FROM hxc_tmp_bld_blks;

      CURSOR csr_get_old_detail_bld_blks
      IS
         SELECT   /*+ ORDERED  INDEX(TBB) INDEX(DAY) USE_NL(TBB, DAY) */
                  tbb.time_building_block_id, tbb.object_version_number,
                  tbb.parent_building_block_id, tbb.resource_type,
                  tbb.resource_id, tbb.comment_text,
                  DECODE (tbb.TYPE,
                          'MEASURE', DAY.start_time,
                          tbb.start_time
                         ),
                  DECODE (tbb.TYPE, 'MEASURE', DAY.stop_time, tbb.stop_time),
                  DECODE (tbb.TYPE,
                          'MEASURE', tbb.measure,
                          (tbb.stop_time - tbb.start_time
                          ) * 24
                         ),
                  tbb.SCOPE, tbb.TYPE,
                  DECODE (tbb.TYPE, 'MEASURE', tbb.unit_of_measure, 'HOURS'),
                  tbb.date_from, tbb.date_to, tbb.approval_status,
                  tbb.approval_style_id
             FROM hxc_tmp_bld_blks tmp,
                  hxc_time_building_blocks tbb,
                  hxc_time_building_blocks DAY
            WHERE tbb.time_building_block_id = tmp.time_building_block_id
              AND tbb.object_version_number = tmp.time_building_block_ovn
              AND DAY.time_building_block_id = tbb.parent_building_block_id
              AND DAY.object_version_number = tbb.parent_building_block_ovn
         ORDER BY tmp.seq;

      CURSOR csr_get_old_attributes
      IS
         SELECT   /*+ ORDERED  INDEX(TAU) INDEX(TA) USE_NL(TAU, TA) */
                  tmp.time_building_block_id, ta.bld_blk_info_type_id,
                  ta.attribute_category, ta.attribute1, ta.attribute2,
                  ta.attribute3, ta.attribute4, ta.attribute5, ta.attribute6,
                  ta.attribute7, ta.attribute8, ta.attribute9, ta.attribute10,
                  ta.attribute11, ta.attribute12, ta.attribute13,
                  ta.attribute14, ta.attribute15, ta.attribute16,
                  ta.attribute17, ta.attribute18, ta.attribute19,
                  ta.attribute20, ta.attribute21, ta.attribute22,
                  ta.attribute23, ta.attribute24, ta.attribute25,
                  ta.attribute26, ta.attribute27, ta.attribute28,
                  ta.attribute29, ta.attribute30
             FROM hxc_tmp_bld_blks tmp,
                  hxc_time_attribute_usages tau,
                  hxc_time_attributes ta
            WHERE tau.time_building_block_id = tmp.time_building_block_id
              AND tau.time_building_block_ovn = tmp.time_building_block_ovn
              AND ta.time_attribute_id = tau.time_attribute_id
         ORDER BY tmp.seq;

      l_index                      PLS_INTEGER;
      l_dummy                      VARCHAR2 (1);

-- bulk collect collections
      TYPE t_old_bld_blk_bb_id IS TABLE OF hxc_time_building_blocks.time_building_block_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_bb_ovn IS TABLE OF hxc_time_building_blocks.object_version_number%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_parent_id IS TABLE OF hxc_time_building_blocks.parent_building_block_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_resource_type IS TABLE OF hxc_time_building_blocks.resource_type%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_resource_id IS TABLE OF hxc_time_building_blocks.resource_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_comment_text IS TABLE OF hxc_time_building_blocks.comment_text%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_start_time IS TABLE OF hxc_time_building_blocks.start_time%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_stop_time IS TABLE OF hxc_time_building_blocks.stop_time%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_measure IS TABLE OF hxc_time_building_blocks.measure%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_scope IS TABLE OF hxc_time_building_blocks.SCOPE%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_type IS TABLE OF hxc_time_building_blocks.TYPE%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_uom IS TABLE OF hxc_time_building_blocks.unit_of_measure%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_date_from IS TABLE OF hxc_time_building_blocks.date_from%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_date_to IS TABLE OF hxc_time_building_blocks.date_to%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_app_status IS TABLE OF hxc_time_building_blocks.approval_status%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_app_style_id IS TABLE OF hxc_time_building_blocks.approval_style_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_bb_info_type_id IS TABLE OF hxc_time_attributes.bld_blk_info_type_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_att_cat IS TABLE OF hxc_time_attributes.attribute_category%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute1 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute2 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute3 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute4 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute5 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute6 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute7 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute8 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute9 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute10 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute11 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute12 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute13 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute14 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute15 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute16 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute17 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute18 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute19 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute20 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute21 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute22 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute23 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute24 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute25 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute26 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute27 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute28 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute29 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE t_old_bld_blk_attribute30 IS TABLE OF hxc_time_attributes.attribute1%TYPE
         INDEX BY BINARY_INTEGER;

      t_old_bb_id                  t_old_bld_blk_bb_id;
      t_old_bb_ovn                 t_old_bld_blk_bb_ovn;
      t_old_att_bb_id              t_old_bld_blk_bb_id;
      t_old_parent_id              t_old_bld_blk_parent_id;
      t_old_resource_type          t_old_bld_blk_resource_type;
      t_old_resource_id            t_old_bld_blk_resource_id;
      t_old_comment_text           t_old_bld_blk_comment_text;
      t_old_start_time             t_old_bld_blk_start_time;
      t_old_stop_time              t_old_bld_blk_stop_time;
      t_old_measure                t_old_bld_blk_measure;
      t_old_scope                  t_old_bld_blk_scope;
      t_old_type                   t_old_bld_blk_type;
      t_old_uom                    t_old_bld_blk_uom;
      t_old_date_from              t_old_bld_blk_date_from;
      t_old_date_to                t_old_bld_blk_date_to;
      t_old_approval_status        t_old_bld_blk_app_status;
      t_old_approval_style_id      t_old_bld_blk_app_style_id;
      t_old_bld_blk_info_type_id   t_old_bld_blk_bb_info_type_id;
      t_old_attribute_category     t_old_bld_blk_att_cat;
      t_old_attribute1             t_old_bld_blk_attribute1;
      t_old_attribute2             t_old_bld_blk_attribute2;
      t_old_attribute3             t_old_bld_blk_attribute3;
      t_old_attribute4             t_old_bld_blk_attribute4;
      t_old_attribute5             t_old_bld_blk_attribute5;
      t_old_attribute6             t_old_bld_blk_attribute6;
      t_old_attribute7             t_old_bld_blk_attribute7;
      t_old_attribute8             t_old_bld_blk_attribute8;
      t_old_attribute9             t_old_bld_blk_attribute9;
      t_old_attribute10            t_old_bld_blk_attribute10;
      t_old_attribute11            t_old_bld_blk_attribute11;
      t_old_attribute12            t_old_bld_blk_attribute12;
      t_old_attribute13            t_old_bld_blk_attribute13;
      t_old_attribute14            t_old_bld_blk_attribute14;
      t_old_attribute15            t_old_bld_blk_attribute15;
      t_old_attribute16            t_old_bld_blk_attribute16;
      t_old_attribute17            t_old_bld_blk_attribute17;
      t_old_attribute18            t_old_bld_blk_attribute18;
      t_old_attribute19            t_old_bld_blk_attribute19;
      t_old_attribute20            t_old_bld_blk_attribute20;
      t_old_attribute21            t_old_bld_blk_attribute21;
      t_old_attribute22            t_old_bld_blk_attribute22;
      t_old_attribute23            t_old_bld_blk_attribute23;
      t_old_attribute24            t_old_bld_blk_attribute24;
      t_old_attribute25            t_old_bld_blk_attribute25;
      t_old_attribute26            t_old_bld_blk_attribute26;
      t_old_attribute27            t_old_bld_blk_attribute27;
      t_old_attribute28            t_old_bld_blk_attribute28;
      t_old_attribute29            t_old_bld_blk_attribute29;
      t_old_attribute30            t_old_bld_blk_attribute30;
      l_range_increment            NUMBER                        := 100;
      l_lower_range                PLS_INTEGER;
      l_upper_range                PLS_INTEGER;
      l_bb_index                   PLS_INTEGER;
      l_already_multiplied         varchar2(1) := 'N';
      l_detail_index               number := 0;
      l_old_detail_bb_id           number := -1;
      l_number_format              varchar2(2);
      l_att26			   number;
   BEGIN
-- populate temporary table for detail scope
      l_index := t_old_detail_bb_id.COUNT;

      IF g_debug
      THEN
         l_proc := g_package || 'query_old_timecard';
         hr_utility.set_location ('Processing ' || l_proc, 180);
      END IF;

      IF (l_index <> 0)
      THEN
         l_lower_range := t_old_detail_bb_id.FIRST;
         l_upper_range :=
            LEAST (t_old_detail_bb_id.LAST,
                   l_lower_range + l_range_increment);

         WHILE l_lower_range <= t_old_detail_bb_id.LAST
         LOOP
            FORALL x IN l_lower_range .. l_upper_range
               INSERT INTO hxc_tmp_bld_blks
                           (seq, time_building_block_id,
                            time_building_block_ovn
                           )
                    VALUES (t_old_detail_seq (x), t_old_detail_bb_id (x),
                            t_old_detail_ovn (x)
                           );

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 190);
            END IF;

            OPEN csr_get_old_detail_bld_blks;

            FETCH csr_get_old_detail_bld_blks
            BULK COLLECT INTO t_old_bb_id, t_old_bb_ovn, t_old_parent_id,
                   t_old_resource_type, t_old_resource_id, t_old_comment_text,
                   t_old_start_time, t_old_stop_time, t_old_measure,
                   t_old_scope, t_old_type, t_old_uom, t_old_date_from,
                   t_old_date_to, t_old_approval_status,
                   t_old_approval_style_id;

            CLOSE csr_get_old_detail_bld_blks;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 200);
            END IF;

            OPEN csr_get_old_attributes;

            FETCH csr_get_old_attributes
            BULK COLLECT INTO t_old_att_bb_id, t_old_bld_blk_info_type_id,
                   t_old_attribute_category, t_old_attribute1,
                   t_old_attribute2, t_old_attribute3, t_old_attribute4,
                   t_old_attribute5, t_old_attribute6, t_old_attribute7,
                   t_old_attribute8, t_old_attribute9, t_old_attribute10,
                   t_old_attribute11, t_old_attribute12, t_old_attribute13,
                   t_old_attribute14, t_old_attribute15, t_old_attribute16,
                   t_old_attribute17, t_old_attribute18, t_old_attribute19,
                   t_old_attribute20, t_old_attribute21, t_old_attribute22,
                   t_old_attribute23, t_old_attribute24, t_old_attribute25,
                   t_old_attribute26, t_old_attribute27, t_old_attribute28,
                   t_old_attribute29, t_old_attribute30;

            CLOSE csr_get_old_attributes;

            IF g_debug
            THEN
               hr_utility.set_location (   'gaz - old att table is '
                                        || TO_CHAR (t_old_att_bb_id.COUNT),
                                        999
                                       );
            END IF;

-- commit and in doing so clear out temp table
            COMMIT;

-- gaz - test to make sure tmp table is defined correctly in case
            OPEN gaz_chk_tmp_table;

            FETCH gaz_chk_tmp_table
             INTO l_dummy;

            IF gaz_chk_tmp_table%FOUND
            THEN
               CLOSE gaz_chk_tmp_table;

               fnd_message.set_name ('HXC', 'HXC_TMP_BLD_BLKS_NOT_TMP');
               fnd_message.raise_error;
            END IF;

            CLOSE gaz_chk_tmp_table;

-- populate old bld blk PL/SQL table
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 210);
            END IF;
	    l_detail_index := l_lower_range-1;	--DAYS Vs HOURS
            l_bb_index := l_lower_range;

            FOR x IN t_old_bb_id.FIRST .. t_old_bb_id.LAST
            LOOP
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).bb_id :=
                                                              t_old_bb_id (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).ovn :=
                                                             t_old_bb_ovn (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).parent_bb_id :=
                                                          t_old_parent_id (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).resource_type :=
                                                      t_old_resource_type (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).resource_id :=
                                                        t_old_resource_id (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).comment_text :=
                                                       t_old_comment_text (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).start_time :=
                                                         t_old_start_time (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).stop_time :=
                                                          t_old_stop_time (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).measure :=
                                                            t_old_measure (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).SCOPE :=
                                                              t_old_scope (x);
               hxc_generic_retrieval_pkg.t_old_detail_bld_blks (l_bb_index).TYPE :=
                                                               t_old_type (x);
               l_bb_index := l_bb_index + 1;
            END LOOP;

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 220);
            END IF;

            l_index := hxc_generic_retrieval_pkg.t_old_detail_bld_blks.COUNT;

            IF g_debug
            THEN
               hr_utility.set_location
                               (   'gaz GLOBAL old DETAIL bld blk count is '
                                || TO_CHAR (l_index),
                                999
                               );
            END IF;

            l_index := hxc_generic_retrieval_pkg.t_old_detail_attributes.COUNT;

            IF g_debug
            THEN
               hr_utility.set_location (   'gaz time att count is '
                                        || TO_CHAR (l_index),
                                        999
                                       );
            END IF;

            IF (t_old_att_bb_id.COUNT <> 0)
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 230);
               END IF;

               FOR x IN t_old_att_bb_id.FIRST .. t_old_att_bb_id.LAST
               LOOP
                  t_bb (x).detail_bb_id := t_old_att_bb_id (x);
                  t_bb (x).detail_bld_blk_info_type_id :=
                                               t_old_bld_blk_info_type_id (x);
                  t_bb (x).detail_attribute_category :=
                                                 t_old_attribute_category (x);
                  t_bb (x).detail_attribute1 := t_old_attribute1 (x);
                  t_bb (x).detail_attribute2 := t_old_attribute2 (x);
                  t_bb (x).detail_attribute3 := t_old_attribute3 (x);
                  t_bb (x).detail_attribute4 := t_old_attribute4 (x);
                  t_bb (x).detail_attribute5 := t_old_attribute5 (x);
                  t_bb (x).detail_attribute6 := t_old_attribute6 (x);
                  t_bb (x).detail_attribute7 := t_old_attribute7 (x);
                  t_bb (x).detail_attribute8 := t_old_attribute8 (x);
                  t_bb (x).detail_attribute9 := t_old_attribute9 (x);
                  t_bb (x).detail_attribute10 := t_old_attribute10 (x);
                  t_bb (x).detail_attribute11 := t_old_attribute11 (x);
                  t_bb (x).detail_attribute12 := t_old_attribute12 (x);
                  t_bb (x).detail_attribute13 := t_old_attribute13 (x);
                  t_bb (x).detail_attribute14 := t_old_attribute14 (x);
                  t_bb (x).detail_attribute15 := t_old_attribute15 (x);
                  t_bb (x).detail_attribute16 := t_old_attribute16 (x);
                  t_bb (x).detail_attribute17 := t_old_attribute17 (x);
                  t_bb (x).detail_attribute18 := t_old_attribute18 (x);
                  t_bb (x).detail_attribute19 := t_old_attribute19 (x);
                  t_bb (x).detail_attribute20 := t_old_attribute20 (x);
                  t_bb (x).detail_attribute21 := t_old_attribute21 (x);
                  t_bb (x).detail_attribute22 := t_old_attribute22 (x);
                  t_bb (x).detail_attribute23 := t_old_attribute23 (x);
                  t_bb (x).detail_attribute24 := t_old_attribute24 (x);
                  t_bb (x).detail_attribute25 := t_old_attribute25 (x);
                  t_bb (x).detail_attribute26 := t_old_attribute26 (x);
                  t_bb (x).detail_attribute27 := t_old_attribute27 (x);
                  t_bb (x).detail_attribute28 := t_old_attribute28 (x);
                  t_bb (x).detail_attribute29 := t_old_attribute29 (x);
                  t_bb (x).detail_attribute30 := t_old_attribute30 (x);

                  --********DAYS Vs HOURS*******
                 IF g_params.p_process = 'Projects Retrieval Process' THEN
		  IF (t_bb (x).detail_bb_id <> l_old_detail_bb_id) then
			l_old_detail_bb_id := t_bb (x).detail_bb_id;
			l_already_multiplied := 'N';
			l_detail_index :=l_detail_index+1;
		  END IF;

		  IF l_detail_index BETWEEN hxc_generic_retrieval_pkg.t_old_detail_bld_blks.FIRST
		      AND hxc_generic_retrieval_pkg.t_old_detail_bld_blks.LAST
		  THEN

		     IF  hxc_generic_retrieval_pkg.t_old_detail_bld_blks(l_detail_index).bb_id =
				t_bb(x).detail_bb_id THEN

			IF l_number_format = ',.'  THEN --EUROPEAN FORMAT
			   l_att26 := to_number(replace(t_bb(x).detail_attribute26,'.',','));
		        ELSIF  l_number_format = '.,'  THEN --US FORMAT
			   l_att26 := to_number(replace(t_bb(x).detail_attribute26,',','.'));
			END IF;
			 IF NVL(l_att26,1) <> 1 AND l_already_multiplied = 'N' THEN

			hxc_generic_retrieval_pkg.t_old_detail_bld_blks(l_detail_index).measure :=
			hxc_generic_retrieval_pkg.t_old_detail_bld_blks(l_detail_index).measure *
			l_att26;

			l_already_multiplied := 'Y';

			 END IF;
		     END IF;

		  END IF;
		 END IF;
		  --********DAYS VS HOURS*******


               END LOOP;

               l_index := hxc_generic_retrieval_pkg.t_bb.COUNT;

               IF g_debug
               THEN
                  hr_utility.set_location (   'gaz t bb count is '
                                           || TO_CHAR (l_index),
                                           999
                                          );
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 240);
               END IF;

               FOR x IN t_bb.FIRST .. t_bb.LAST
               LOOP
                  populate_attributes
                                (p_building_block_id      => t_bb (x).detail_bb_id,
                                 p_attribute_table        => t_bb,
                                 p_cnt                    => x,
                                 p_scope                  => 'DETAIL',
                                 p_new                    => 'N'
                                );
               END LOOP;
            END IF;                          -- ( t_old_att_bb_id.COUNT <> 0 )

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 250);
            END IF;

-- truncate temporary tables and delete arrays and table
            t_bb.DELETE;
            t_old_bb_id.DELETE;
            t_old_att_bb_id.DELETE;
            t_old_parent_id.DELETE;
            t_old_resource_type.DELETE;
            t_old_resource_id.DELETE;
            t_old_comment_text.DELETE;
            t_old_start_time.DELETE;
            t_old_stop_time.DELETE;
            t_old_measure.DELETE;
            t_old_scope.DELETE;
            t_old_type.DELETE;
            t_old_uom.DELETE;
            t_old_date_from.DELETE;
            t_old_date_to.DELETE;
            t_old_approval_status.DELETE;
            t_old_approval_style_id.DELETE;
            t_old_bld_blk_info_type_id.DELETE;
            t_old_attribute1.DELETE;
            t_old_attribute2.DELETE;
            t_old_attribute3.DELETE;
            t_old_attribute4.DELETE;
            t_old_attribute5.DELETE;
            t_old_attribute6.DELETE;
            t_old_attribute7.DELETE;
            t_old_attribute8.DELETE;
            t_old_attribute9.DELETE;
            t_old_attribute10.DELETE;
            t_old_attribute11.DELETE;
            t_old_attribute12.DELETE;
            t_old_attribute13.DELETE;
            t_old_attribute14.DELETE;
            t_old_attribute15.DELETE;
            t_old_attribute16.DELETE;
            t_old_attribute17.DELETE;
            t_old_attribute18.DELETE;
            t_old_attribute19.DELETE;
            t_old_attribute20.DELETE;
            t_old_attribute21.DELETE;
            t_old_attribute22.DELETE;
            t_old_attribute23.DELETE;
            t_old_attribute24.DELETE;
            t_old_attribute25.DELETE;
            t_old_attribute26.DELETE;
            t_old_attribute27.DELETE;
            t_old_attribute28.DELETE;
            t_old_attribute29.DELETE;
            t_old_attribute30.DELETE;
            l_lower_range := l_upper_range + 1;
            l_upper_range :=
               LEAST (l_upper_range + l_range_increment,
                      t_old_detail_bb_id.LAST
                     );
         END LOOP;           -- while l_lower_range <= t_old_detail_bb_id.LAST

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 260);
         END IF;
      END IF;                                           -- IF ( l_index <> 0 )
--if g_debug then
   -- hr_utility.set_location('Processing '||l_proc, 270);
--end if;
   END query_old_timecard;

--
-- procedure
--   execute_retrieval_process
--
-- description
--   this is the main procedure for the retrieval process. The basic process
--   flow is as follows
--
--       check the retrieval process is registered
--       (chk_retrieval_process)
--          |
--       check no other retrieval running
--    (check_concurrency_ok)
--       |
--              audit the transaction header
--                      |
--    get the field mappings for this retrieval process
--    and populate global PL/SQL table
--    (get_field_mappings)
--       |
--    parse the user defined WHERE clause
--    (parse_it)
--       |
--    build the dynamic SQL query based on parameters passed
--    (build_query)
--       |
--    execute the query
--    (query_it)
--       |
--    populate the transaction tables
--    (audit_transaction)
--          |
--    query the old time card if appropriate
--    (query_old_timecard)
--
--
--
-- parameters
--   p_process    - name of the process registered in hxc_retrieval_processes
--   p_transaction_code - user defined transaction code used for rerun
--   p_start_date - start date of the retrieval window
--   p_end_date      - end date of the retrieval window
--   p_incremental   - incremental (Y/N)
--   p_rerun_flag - rerun flag (Y/N)
--   p_where_clause  - user specified where clause
--   p_scope      - driving scope - which bld blk scope we drive the date window
--   p_clusive    - INclusive or EXclusive dates in the date window
--         (i.e. INclude or EXClude bld blks which do not completely
--                         fit in the date window)
--
   PROCEDURE execute_retrieval_process (
      p_process            IN   hxc_retrieval_processes.NAME%TYPE,
      p_transaction_code   IN   VARCHAR2,
      p_start_date         IN   DATE DEFAULT NULL,
      p_end_date           IN   DATE DEFAULT NULL,
      p_incremental        IN   VARCHAR2 DEFAULT 'Y',
      p_rerun_flag         IN   VARCHAR2 DEFAULT 'N',
      p_where_clause       IN   VARCHAR2,
      p_scope              IN   VARCHAR2 DEFAULT 'DAY',
      p_clusive            IN   VARCHAR2 DEFAULT 'EX',
      p_unique_params      IN   VARCHAR2 DEFAULT NULL,
      p_since_date         IN   VARCHAR2 DEFAULT NULL
   )
   IS
-- debug local variables
      l_debug                      VARCHAR2 (1);
      l_gaz_cnt                    PLS_INTEGER;
      l_gaz_att                    PLS_INTEGER;
      loop_ok                      BOOLEAN                            := TRUE;
      l_message_table              hxc_message_table_type;
      l_boolean                    BOOLEAN;
      l_bld_blks                   hxc_generic_retrieval_pkg.t_building_blocks;
      l_atts                       hxc_generic_retrieval_pkg.t_time_attribute;
      l_att_index                  PLS_INTEGER                          := -1;

      CURSOR csr_debug
      IS
         SELECT 'Y'
           FROM hxc_debug
          WHERE process = 'RETRIEVAL' AND TRUNC (debug_date) =
                                                              TRUNC (SYSDATE);

      l_sql                        VARCHAR2 (2000);
      l_since_date                 VARCHAR2 (100);
      l_proc                       VARCHAR2 (72)
                                  := g_package || 'execute_retrieval_process';
      l_mapping_id                 hxc_mappings.mapping_id%TYPE       := NULL;
      l_ret_id                     hxc_retrieval_processes.retrieval_process_id%TYPE;
      e_retrieval_not_registered   EXCEPTION;
      e_process_already_running    EXCEPTION;
      l_where_clause_blk           VARCHAR2 (2000);
      l_where_clause_att           VARCHAR2 (2000);
      l_dynamic_query              VARCHAR2 (32000);
      l_transaction_id             NUMBER (15);

-- define private functions and procedures

      -- private function
--   build_query
--
-- description
--   This function builds the dynamic query based on the parameters passed
--   to the retrieval API.
--   The query is broken down into its component forms of SELECT, FROM, WHERE
--   and ORDER BY. The WHERE predicates are further broken down into timecard
--   scopes. There are two SELECT portions, one for incremental and one for
--   non incremental
-- l_incremental_select
-- l_select
--   There are three FROMs, one for the rerun retrieval, one for the non incremental
--   and one for the incremental
-- l_from
--      l_incremental_from
--      l_rerun
--   Since we also control which scope of building block we are interested
--   in the time window restricting upon the WHERE is broken down into
--   bld blks scopes. Furthermore, within this the user is able to specify
--   whether or not the date range is INclusive or EXclusive of time bld
--   blks
-- l_time
-- l_time_ex
-- l_time_in
-- l_day
-- l_day_ex
-- l_day_in
-- l_detail
-- l_detail_ex
-- l_detail_in
--   Finally the order by which currently is static.
-- l_order_by
--
-- Parameters
--   p_where_clause - the recipient API defined where clause
      FUNCTION build_query (
         p_where_clause_blk   VARCHAR2,
         p_where_clause_att   VARCHAR2
      )
         RETURN VARCHAR2
      IS
         l_hint                  VARCHAR2 (170)
            := '
SELECT /*+ ordered use_nl( tbb
             detail_block detail_usage detail_att
             day_block timecard_block
             detail_max_ovn ) */ ';
         l_incremental_select    VARCHAR2 (1860)
            := '
	timecard_block.time_building_block_id
,	timecard_block.object_version_number
,	day_block.time_building_block_id
,	day_block.object_version_number
,	day_block.start_time
,	day_block.stop_time
,	detail_block.time_building_block_id
,	detail_block.object_version_number
,	detail_block.parent_building_block_id
,	detail_block.resource_type
,	detail_block.resource_id
,	detail_block.comment_text
,	detail_block.start_time
,	detail_block.stop_time
,	detail_block.measure
,	detail_block.scope
,	detail_block.type
,	detail_att.time_attribute_id
,	detail_att.bld_blk_info_type_id
,	detail_att.attribute1
,	detail_att.attribute2
,	detail_att.attribute3
,	detail_att.attribute4
,	detail_att.attribute5
,	detail_att.attribute6
,	detail_att.attribute7
,	detail_att.attribute8
,	detail_att.attribute9
,	detail_att.attribute10
,	detail_att.attribute11
,	detail_att.attribute12
,	detail_att.attribute13
,	detail_att.attribute14
,	detail_att.attribute15
,	detail_att.attribute16
,	detail_att.attribute17
,	detail_att.attribute18
,	detail_att.attribute19
,	detail_att.attribute20
,	detail_att.attribute21
,	detail_att.attribute22
,	detail_att.attribute23
,	detail_att.attribute24
,	detail_att.attribute25
,	detail_att.attribute26
,	detail_att.attribute27
,	detail_att.attribute28
,	detail_att.attribute29
,	detail_att.attribute30
,	detail_block.date_from
,	detail_block.date_to
,	detail_block.approval_status
,	detail_block.approval_style_id
,	DECODE ( detail_block.date_to, hr_general.end_of_time, ''N'', ''Y'' )
,	detail_att.attribute_category
,       1
,       1
,       NVL(detail_max_ovn.max_ovn, 0)
,	detail_block.unit_of_measure
,	timecard_block.start_time
,	timecard_block.stop_time
,       timecard_block.comment_text
,	DECODE ( timecard_block.date_to, hr_general.end_of_time, ''N'', ''Y'' ) ';
         l_select                VARCHAR2 (1945)
            := '
SELECT /*+ ordered use_nl(
             detail_block detail_usage detail_att
             day_block timecard_block
             detail_max_ovn ) */
	timecard_block.time_building_block_id
,	timecard_block.object_version_number
,	day_block.time_building_block_id
,	day_block.object_version_number
,	day_block.start_time
,	day_block.stop_time
,	detail_block.time_building_block_id
,	detail_block.object_version_number
,	detail_block.parent_building_block_id
,	detail_block.resource_type
,	detail_block.resource_id
,	detail_block.comment_text
,	detail_block.start_time
,	detail_block.stop_time
,	detail_block.measure
,	detail_block.scope
,	detail_block.type
,	detail_att.time_attribute_id
,	detail_att.bld_blk_info_type_id
,	detail_att.attribute1
,	detail_att.attribute2
,	detail_att.attribute3
,	detail_att.attribute4
,	detail_att.attribute5
,	detail_att.attribute6
,	detail_att.attribute7
,	detail_att.attribute8
,	detail_att.attribute9
,	detail_att.attribute10
,	detail_att.attribute11
,	detail_att.attribute12
,	detail_att.attribute13
,	detail_att.attribute14
,	detail_att.attribute15
,	detail_att.attribute16
,	detail_att.attribute17
,	detail_att.attribute18
,	detail_att.attribute19
,	detail_att.attribute20
,	detail_att.attribute21
,	detail_att.attribute22
,	detail_att.attribute23
,	detail_att.attribute24
,	detail_att.attribute25
,	detail_att.attribute26
,	detail_att.attribute27
,	detail_att.attribute28
,	detail_att.attribute29
,	detail_att.attribute30
,	detail_block.date_from
,	detail_block.date_to
,	detail_block.approval_status
,	detail_block.approval_style_id
,	DECODE ( detail_block.date_to, hr_general.end_of_time, ''N'', ''Y'' )
,	detail_att.attribute_category
,       1
,       1
,	detail_block.object_version_number -1
,	detail_block.unit_of_measure
,	timecard_block.start_time
,	timecard_block.stop_time
,       timecard_block.comment_text
,	DECODE ( timecard_block.date_to, hr_general.end_of_time, ''N'', ''Y'' ) ';
         l_from                  VARCHAR2 (200)
            := '
FROM
	hxc_time_building_blocks	timecard_block
,	hxc_time_building_blocks	day_block
,	Hxc_time_building_blocks	detail_block
,	Hxc_time_attribute_usages	detail_usage
,	Hxc_time_attributes		detail_att';
         l_inline_view_range     VARCHAR2 (800)
            := '
FROM
	(select /*+ no_merge ordered */
        time_building_block_id,
	object_version_number
from 	Hxc_latest_details tbb_latest
where	tbb_latest.resource_id BETWEEN :p_lower_range and :p_upper_range
and     tbb_latest.approval_status <> ''ERROR''
AND	NOT EXISTS (select ''x''
			FROM	hxc_transaction_details txd
			,	hxc_transactions tx
			WHERE	tx.transaction_process_id	= :p_process_id
			AND	tx.type				= ''RETRIEVAL''
			AND	tx.status			= ''SUCCESS''
			AND	tx.transaction_id		= txd.transaction_id
			AND	txd.status			= ''SUCCESS''
		AND	txd.time_building_block_id	= tbb_latest.time_building_block_id
		AND     txd.time_building_block_ovn     = tbb_latest.object_version_number
		)

';
-- Bug 9394444

         l_inline_view_range_pa     VARCHAR2 (800)
            := '
FROM
	(select /*+ no_merge ordered */
        time_building_block_id,
	object_version_number
from 	Hxc_pa_latest_details tbb_latest
where	tbb_latest.resource_id BETWEEN :p_lower_range and :p_upper_range
and     tbb_latest.approval_status <> ''ERROR''
AND	NOT EXISTS (select ''x''
			FROM	hxc_transaction_details txd
			,	hxc_transactions tx
			WHERE	tx.transaction_process_id	= :p_process_id
			AND	tx.type				= ''RETRIEVAL''
			AND	tx.status			= ''SUCCESS''
			AND	tx.transaction_id		= txd.transaction_id
			AND	txd.status			= ''SUCCESS''
		AND	txd.time_building_block_id	= tbb_latest.time_building_block_id
		AND     txd.time_building_block_ovn     = tbb_latest.object_version_number
		)
';

         l_inline_view_range_pay     VARCHAR2 (800)
            := '
FROM
	(select /*+ no_merge ordered */
        time_building_block_id,
	object_version_number
from 	Hxc_pay_latest_details tbb_latest
where	tbb_latest.resource_id BETWEEN :p_lower_range and :p_upper_range
and     tbb_latest.approval_status <> ''ERROR''
AND	NOT EXISTS (select ''x''
			FROM	hxc_transaction_details txd
			,	hxc_transactions tx
			WHERE	tx.transaction_process_id	= :p_process_id
			AND	tx.type				= ''RETRIEVAL''
			AND	tx.status			= ''SUCCESS''
			AND	tx.transaction_id		= txd.transaction_id
			AND	txd.status			= ''SUCCESS''
		AND	txd.time_building_block_id	= tbb_latest.time_building_block_id
		AND     txd.time_building_block_ovn     = tbb_latest.object_version_number
		)
';



         l_inline_view           VARCHAR2 (2000)
	             := '
	 FROM
	 	(select /*+ no_merge ordered */
	         tbb_latest.time_building_block_id,
	 	tbb_latest.object_version_number
	 from 	hxc_retrieval_ranges rr,
	         hxc_retrieval_range_resources rrr,
	         hxc_latest_details tbb_latest
	 where	rr.retrieval_range_id = :p_rr_id AND
	         rr.retrieval_range_id = rrr.retrieval_range_id AND
	         tbb_latest.resource_id = rrr.resource_id AND
	         tbb_latest.last_update_date > :p_since_date
	         AND tbb_latest.approval_status <> ''ERROR''
	 AND	NOT EXISTS (select ''x''
	 			FROM	hxc_transaction_details txd
	 			,	hxc_transactions tx
	 			WHERE	tx.transaction_process_id	= :p_process_id
	 			AND	tx.type				= ''RETRIEVAL''
	 			AND	tx.status			= ''SUCCESS''
	 			AND	tx.transaction_id		= txd.transaction_id
	 			AND	txd.status			= ''SUCCESS''
	 		AND	txd.time_building_block_id	= tbb_latest.time_building_block_id
	 		AND     txd.time_building_block_ovn     = tbb_latest.object_version_number
	 		)
';
-- Bug 9394444
         l_inline_view_pa           VARCHAR2 (2000)
	             := '
	 FROM
	 	(select /*+ no_merge ordered */
	         tbb_latest.time_building_block_id,
	 	tbb_latest.object_version_number
	 from 	hxc_retrieval_ranges rr,
	         hxc_retrieval_range_resources rrr,
	         hxc_pa_latest_details tbb_latest
	 where	rr.retrieval_range_id = :p_rr_id AND
	         rr.retrieval_range_id = rrr.retrieval_range_id AND
	         tbb_latest.resource_id = rrr.resource_id AND
	         tbb_latest.last_update_date > :p_since_date
	         AND tbb_latest.approval_status <> ''ERROR''
	 AND	NOT EXISTS (select ''x''
	 			FROM	hxc_transaction_details txd
	 			,	hxc_transactions tx
	 			WHERE	tx.transaction_process_id	= :p_process_id
	 			AND	tx.type				= ''RETRIEVAL''
	 			AND	tx.status			= ''SUCCESS''
	 			AND	tx.transaction_id		= txd.transaction_id
	 			AND	txd.status			= ''SUCCESS''
	 		AND	txd.time_building_block_id	= tbb_latest.time_building_block_id
	 		AND     txd.time_building_block_ovn     = tbb_latest.object_version_number
	 		)
';

         l_inline_view_pay           VARCHAR2 (2000)
	             := '
	 FROM
	 	(select /*+ no_merge ordered */
	         tbb_latest.time_building_block_id,
	 	tbb_latest.object_version_number
	 from 	hxc_retrieval_ranges rr,
	         hxc_retrieval_range_resources rrr,
	         hxc_pay_latest_details tbb_latest
	 where	rr.retrieval_range_id = :p_rr_id AND
	         rr.retrieval_range_id = rrr.retrieval_range_id AND
	         tbb_latest.resource_id = rrr.resource_id AND
	         tbb_latest.last_update_date > :p_since_date
	         AND tbb_latest.approval_status <> ''ERROR''
	 AND	NOT EXISTS (select ''x''
	 			FROM	hxc_transaction_details txd
	 			,	hxc_transactions tx
	 			WHERE	tx.transaction_process_id	= :p_process_id
	 			AND	tx.type				= ''RETRIEVAL''
	 			AND	tx.status			= ''SUCCESS''
	 			AND	tx.transaction_id		= txd.transaction_id
	 			AND	txd.status			= ''SUCCESS''
	 		AND	txd.time_building_block_id	= tbb_latest.time_building_block_id
	 		AND     txd.time_building_block_ovn     = tbb_latest.object_version_number
	 		)
';


         l_noloop_from           VARCHAR2 (250)
            := '
 ) tbb
,	Hxc_time_building_blocks        detail_block
,	Hxc_time_attribute_usages	detail_usage
,	Hxc_time_attributes		detail_att
,	hxc_time_building_blocks	day_block
,	hxc_time_building_blocks	timecard_block
,	hxc_max_ovn			detail_max_ovn';
         l_incremental_from      VARCHAR2 (400)
            := '
FROM
        hxc_retrieval_range_blks        tbb
,	Hxc_time_building_blocks        detail_block
,	Hxc_time_attribute_usages	detail_usage
,	Hxc_time_attributes		detail_att
,	hxc_time_building_blocks	day_block
,	hxc_time_building_blocks	timecard_block
,	hxc_latest_details    hld
,	hxc_max_ovn			detail_max_ovn';
         l_time                  VARCHAR2 (400)
            := '
WHERE
        timecard_block.scope = ''TIMECARD'' AND
        timecard_block.approval_status <> ''ERROR'' AND
        timecard_block.object_version_number = (
                SELECT  /*+ no_unnest */ MAX ( tovn.object_version_number )
                FROM    hxc_time_building_blocks tovn
                WHERE   tovn.time_building_block_id = timecard_block.time_building_block_id ) ';
-- Bug 9394444
         l_incremental_from_pa      VARCHAR2 (400)
            := '
FROM
        hxc_retrieval_range_blks        tbb
,	Hxc_time_building_blocks        detail_block
,	Hxc_time_attribute_usages	detail_usage
,	Hxc_time_attributes		detail_att
,	hxc_time_building_blocks	day_block
,	hxc_time_building_blocks	timecard_block
,	hxc_pa_latest_details    hld
,	hxc_max_ovn			detail_max_ovn';

         l_incremental_from_pay      VARCHAR2 (400)
            := '
FROM
        hxc_retrieval_range_blks        tbb
,	Hxc_time_building_blocks        detail_block
,	Hxc_time_attribute_usages	detail_usage
,	Hxc_time_attributes		detail_att
,	hxc_time_building_blocks	day_block
,	hxc_time_building_blocks	timecard_block
,	hxc_pay_latest_details    hld
,	hxc_max_ovn			detail_max_ovn';



         l_time_ex               VARCHAR2 (560)
            := '
WHERE
        timecard_block.scope = ''TIMECARD'' AND
        timecard_block.approval_status <> ''ERROR'' AND
        timecard_block.object_version_number = (
                SELECT   /*+ no_unnest */ MAX ( tovn.object_version_number )
                FROM    hxc_time_building_blocks tovn
                WHERE   tovn.time_building_block_id = timecard_block.time_building_block_id )
AND
        timecard_block.start_time
        BETWEEN :p_start_date AND :p_end_date AND
        timecard_block.stop_time
        BETWEEN :p_start_date AND :p_end_date ';
         l_time_in               VARCHAR2 (650)
            := '
WHERE
        timecard_block.scope = ''TIMECARD'' AND
        timecard_block.approval_status <> ''ERROR'' AND
        timecard_block.object_version_number = (
                SELECT   /*+ no_unnest */ MAX ( tovn.object_version_number )
		FROM    hxc_time_building_blocks tovn
                WHERE   tovn.time_building_block_id = timecard_block.time_building_block_id )
        AND
        :p_start_date   <=      timecard_block.stop_time   AND
        :p_end_date     >=      timecard_block.start_time ';
         l_day                   VARCHAR2 (600)
            := '
AND
        day_block.parent_building_block_id
                                = timecard_block.time_building_block_id AND
        day_block.scope         = ''DAY'' AND
        day_block.approval_status <> ''ERROR'' AND
        day_block.object_version_number = (
                SELECT  /*+ no_unnest */ MAX ( dyovn.object_version_number )
		FROM    hxc_time_building_blocks dyovn
                WHERE   dyovn.time_building_block_id = day_block.time_building_block_id ) ';
         l_detail                VARCHAR2 (350)
            := '
AND
        detail_block.parent_building_block_id  = day_block.time_building_block_id
AND
        detail_usage.time_building_block_id  = detail_block.time_building_block_id AND
        detail_usage.time_building_block_ovn = detail_block.object_version_number
AND
        detail_att.time_attribute_id = detail_usage.time_attribute_id';
         l_inline_day_ex         VARCHAR2 (200)
            := '
AND
        tbb_latest.start_time
        BETWEEN :p_start_date AND :p_end_date	AND
        tbb_latest.stop_time
        BETWEEN :p_start_date AND :p_end_date ';
         l_inline_day_in         VARCHAR2 (200)
            := '
AND
        :p_start_date <= tbb_latest.stop_time	AND
        :p_end_date   >= tbb_latest.start_time ';
         l_rerun                 VARCHAR2 (1100)
            := '
FROM
	hxc_time_attributes		detail_att
,	hxc_time_attribute_usages	detail_usage
,	hxc_time_building_blocks	detail_block
,	hxc_time_building_blocks	day_block
,	hxc_time_attributes		timecard_att
,	hxc_transaction_details		txd
,	hxc_transactions		tx
WHERE
	tx.transaction_code	= :p_transaction_code
AND
	txd.transaction_id	= tx.transaction_id
AND
	timecard_block.time_building_block_id	= txd.time_building_block_id	AND
	timecard_block.object_version_number	= txd.time_building_block_ovn	AND
	timecard_block.scope 	= ''TIMECARD''
AND
	day_block.parent_building_block_id
				= timecard_block.time_building_block_id AND
	day_block.scope		= ''DAY''	AND
	day_block.time_building_block_id	= txd.time_building_block_id	AND
	day_block.object_version_number		= txd.time_building_block_ovn
AND
	detail_block.parent_building_block_id	= day_block.time_building_block_id AND
	detail_block.scope			= ''DETAIL'' AND
	detail_block.time_building_block_id	= txd.time_building_block_id	AND
	detail_block.object_version_number	= txd.time_building_block_ovn';
-- GPM v115.41
         /*l_not_exists            VARCHAR2 (500)
            := '
 AND
    detail_max_ovn.time_building_block_id(+) = detail_block.time_building_block_id
AND
	detail_block.time_building_block_id = tbb.time_building_block_id AND
	detail_block.object_version_number  = tbb.object_version_number';*/

	l_not_exists            VARCHAR2 (500)
		             := '
		  AND
		     detail_max_ovn.time_building_block_id(+) = detail_block.time_building_block_id
		 AND
		 	detail_block.time_building_block_id = tbb.time_building_block_id AND
		 	detail_block.object_version_number  = tbb.object_version_number
		 	AND( ( detail_block.start_time IS NOT NULL AND detail_block.stop_time IS NOT NULL )
		 	OR (detail_block.measure IS NOT NULL))
	';

         l_latest_double_check   VARCHAR2 (400)
            := ' AND detail_block.time_building_block_id = hld.time_building_block_id
                 AND detail_block.object_version_number  = hld.object_version_number';
         l_order_by              VARCHAR2 (200)
            := '
ORDER BY
        timecard_block.resource_id
,	timecard_block.start_time
,       timecard_block.time_building_block_id
,       day_block.start_time
,	detail_block.time_building_block_id';
         l_time_store_query      VARCHAR2 (32000);
         l_inline_day            VARCHAR2 (200)   := ' ';
         l_app_set               VARCHAR2 (200);
      BEGIN                                                     -- build query

         -- Bug 9394444
         IF g_params.p_process = 'Projects Retrieval Process'
          AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PA')
          AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
         THEN
               l_inline_view := l_inline_view_pa;
               l_incremental_from     := l_incremental_from_pa;
         ELSIF g_params.p_process IN ('BEE Retrieval Process','Apply Schedule Rules')
           AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
                AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PAY')
         THEN
               l_inline_view := l_inline_view_pay;
               l_incremental_from     := l_incremental_from_pay;
         END IF;

--Elp changes sonarasi 14-Mar-2003
--A string of application set ids like (1,2,3,5) etc are obtained for the corresponding time
--recipient id of the application. As per ELP changes, the Application Set Id for the detail,
--day and timecard scopes are added in hxc_time_building_blocks table. Here we retrieve only
--blocks that the Retrieval Application is interested in. So we just add to the where clause
--to compare if the detail building block's application set id is within the list of
--application set ids generated for the corresponding time recipient.
         l_app_set :=
                    g_app_set_id_string (g_retrieval_tr_id).app_set_id_string;

--Elp changes sonarasi over
         IF (g_params.p_rerun_flag = 'Y')
         THEN
            l_time_store_query := l_select || l_rerun || l_order_by;
         ELSIF (g_params.p_start_date IS NULL AND g_params.p_end_date IS NULL
               )
         THEN
            l_time_store_query := l_time || l_day || l_detail;
         ELSIF (g_params.p_scope = 'TIME')
         THEN
            IF (g_params.p_clusive = 'EX')
            THEN
               l_time_store_query := l_time_ex || l_day || l_detail;
            ELSIF (g_params.p_clusive = 'IN')
            THEN
               l_time_store_query := l_time_in || l_day || l_detail;
            ELSE
               fnd_message.set_name ('HXC', 'HXC_0014_GNRET_INVLD_P_CLUSIVE');
               fnd_message.raise_error;
            END IF;
         ELSIF (g_params.p_scope = 'DAY')
         THEN
            IF (g_params.p_clusive = 'EX')
            THEN
               l_time_store_query := l_time || l_day || l_detail;
               l_inline_day := l_inline_day_ex;
            ELSIF (g_params.p_clusive = 'IN')
            THEN
               l_time_store_query := l_time || l_day || l_detail;
               l_inline_day := l_inline_day_in;
            ELSE
               fnd_message.set_name ('HXC', 'HXC_0014_GNRET_INVLD_P_CLUSIVE');
               fnd_message.raise_error;
            END IF;
         ELSIF (g_params.p_scope = 'DETAIL')
         THEN
            IF (g_params.p_clusive = 'EX')
            THEN
               l_time_store_query := l_time || l_day || l_detail;
               l_inline_day := l_inline_day_ex;
            ELSIF (g_params.p_clusive = 'IN')
            THEN
               l_time_store_query := l_time || l_day || l_detail;
               l_inline_day := l_inline_day_in;
            ELSE
               fnd_message.set_name ('HXC', 'HXC_0014_GNRET_INVLD_P_CLUSIVE');
               fnd_message.raise_error;
            END IF;
         ELSE
            fnd_message.set_name ('HXC', 'HXC_0015_GNRET_INVLD_P_SCOPE');
            fnd_message.raise_error;
         END IF;

         IF (g_params.p_rerun_flag = 'N')
         THEN
            IF (g_params.p_incremental = 'Y')
            THEN
               IF (g_params.p_process IN
                            ('BEE Retrieval Process', 'Apply Schedule Rules')
                  )
               THEN
                  -- since the Transfer from OTL to BEE default where is a resource id filter
                  -- there is no need to include this in this query since it has already been
                  -- applied to populate the hxc retrieval range resource table
                  l_time_store_query :=
                        l_hint
                     || l_incremental_select
                     || l_incremental_from
                     || l_time_store_query
                     || l_not_exists
                     || l_latest_double_check
                     || l_order_by;
               ELSIF (g_params.p_process IN
                         ('Purchasing Retrieval Process',
                          'Projects Retrieval Process'
                         )
                     )
               THEN
                  -- Applications whose default where does not filter on person and LOOP
                  l_time_store_query :=
                        l_hint
                     || l_incremental_select
                     || l_incremental_from
                     || l_time_store_query
                     || p_where_clause_blk
                     || p_where_clause_att
                     || l_not_exists
                     || l_latest_double_check
                     || l_order_by;
               ELSIF (g_params.p_process IN ('Maintenance Retrieval Process')
                     )
               THEN
                  -- Applications which do not LOOP
                  l_time_store_query :=
                        l_hint
                     || l_incremental_select
                     || l_inline_view_range
                     || l_inline_day
                     || l_app_set
                     || p_where_clause_blk
                     || l_noloop_from
                     || l_time_store_query
                     || p_where_clause_att
                     || l_not_exists
                     || l_order_by;
               ELSE
                  fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                  fnd_message.set_token ('PROCEDURE', 'Integration catch');
                  fnd_message.set_token ('STEP', ': whereclause');
                  fnd_message.raise_error;
               END IF;
            ELSE
               l_time_store_query :=
                     l_select
                  || l_from
                  || l_time_store_query
                  || l_app_set
                  || p_where_clause_blk
                  || p_where_clause_att
                  || l_order_by;
            END IF;
         END IF;

         RETURN l_time_store_query;
      END build_query;

      FUNCTION check_concurrency_ok (
         p_process_id          NUMBER,
         p_retrieval_process   VARCHAR2,
         p_where_clause        VARCHAR2,
         p_unique_params       VARCHAR2
      )
         RETURN BOOLEAN
      IS
         CURSOR chk_transaction
         IS
            SELECT transaction_id
              FROM hxc_transactions tx
             WHERE transaction_process_id = p_process_id
               AND status = 'IN PROGRESS';

         CURSOR csr_chk_where_clause (
            p_transaction_id   NUMBER,
            p_where_clause     VARCHAR2,
            p_unique_params    VARCHAR2
         )
         IS
            SELECT 'x'
              FROM hxc_retrieval_ranges rr
             WHERE rr.transaction_id = p_transaction_id
               AND (   rr.where_clause = p_where_clause
                    OR (p_where_clause IS NULL AND rr.where_clause IS NULL)
                   )
               AND (   rr.unique_params = p_unique_params
                    OR (p_unique_params IS NULL AND rr.unique_params IS NULL
                       )
                   );

         CURSOR csr_chk_range_exists (p_transaction_id NUMBER)
         IS
            SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS DD-MON-YY')
              FROM hxc_retrieval_ranges
             WHERE transaction_id = p_transaction_id;

         l_transaction_id   hxc_transactions.transaction_id%TYPE;
         l_bee_ok           VARCHAR2 (1);
         l_cnt              PLS_INTEGER                            := 0;
         l_no_ranges        BOOLEAN                                := TRUE;
         l_dummy            VARCHAR2 (20);
      BEGIN                                            -- check concurrency ok
         IF g_debug
         THEN
            hr_utility.TRACE (   'in check concurrency - process id is   '
                              || TO_CHAR (p_process_id)
                             );
            hr_utility.TRACE (   'in check concurrency - retrieval id is '
                              || p_retrieval_process
                             );
            hr_utility.TRACE (   'in check concurrency - where clause is '
                              || SUBSTR (p_where_clause, 1, 300)
                             );
         END IF;

         OPEN chk_transaction;

         FETCH chk_transaction
          INTO l_transaction_id;

         CLOSE chk_transaction;

-- if another process is running check to see if the transfer batch size is
-- set otherwise the processes will conflict
         IF g_debug
         THEN
            hr_utility.TRACE ('l running is ' || TO_CHAR (l_transaction_id));
         END IF;

         IF (p_retrieval_process = 'Projects Retrieval Process')
         THEN
            RETURN TRUE;
         END IF;

-- check the unique params
         IF (    p_retrieval_process IN
                            ('Apply Schedule Rules', 'BEE Retrieval Process')
             AND l_transaction_id IS NOT NULL
            )
         THEN
            IF g_debug
            THEN
               hr_utility.TRACE ('Checking BEE');
            END IF;

            -- make sure that ranges have been inserted already by the IN PROGRESS
            -- process
            WHILE l_no_ranges
            LOOP
               IF g_debug
               THEN
                  hr_utility.TRACE ('looking for ranges');
               END IF;

               OPEN csr_chk_range_exists (l_transaction_id);

               FETCH csr_chk_range_exists
                INTO l_dummy;

               IF (csr_chk_range_exists%NOTFOUND)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'No ranges yet for '
                                       || TO_CHAR (l_transaction_id)
                                      );
                  END IF;

                  l_cnt := l_cnt + 1;

                  IF (l_cnt > 100000)
                  THEN
                     fnd_message.set_name ('HXC', 'HXC_RET_NO_RANGES');
                     fnd_message.set_token ('TERM_TIME', l_dummy);
                     fnd_message.raise_error;
                  END IF;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('found ranges');
                  END IF;

                  l_no_ranges := FALSE;
               END IF;

               CLOSE csr_chk_range_exists;
            END LOOP;

            OPEN csr_chk_where_clause (p_transaction_id      => l_transaction_id,
                                       p_where_clause        => p_where_clause,
                                       p_unique_params       => p_unique_params
                                      );

            FETCH csr_chk_where_clause
             INTO l_bee_ok;

            CLOSE csr_chk_where_clause;

            IF g_debug
            THEN
               hr_utility.TRACE ('l bee ok is ' || l_bee_ok);
            END IF;
         END IF;

         IF (   (    l_transaction_id IS NOT NULL
                 AND p_retrieval_process NOT IN
                            ('Apply Schedule Rules', 'BEE Retrieval Process')
                )
             OR (l_transaction_id IS NOT NULL AND l_bee_ok IS NULL)
            )
         THEN
            IF g_debug
            THEN
               hr_utility.TRACE ('FALSE');
            END IF;

            RETURN FALSE;
         ELSE
            IF g_debug
            THEN
               hr_utility.TRACE ('TRUE');
            END IF;

            RETURN TRUE;
         END IF;
      END check_concurrency_ok;

-- private procedure
--   chk_a_and_r_overlap
--
-- description
--   Archive and Restore validation to check if the date params
--   include any Archive and Restore period.
--   Writes message to the log
--
-- parameters
--   p_start_date, p_end_date
      PROCEDURE check_a_and_r_overlap (p_start_date DATE, p_end_date DATE)
      IS
         CURSOR chk_a_and_r_overlap (p_start_date DATE, p_end_date DATE)
         IS
            SELECT 'x'
              FROM hxc_data_sets hds
             WHERE hds.start_date <= p_end_date
               AND hds.end_date >= p_start_date
               AND hds.status IN
                      ('OFF_LINE', 'RESTORE_IN_PROGRESS',
                       'BACKUP_IN_PROGRESS');

         l_message_text   VARCHAR2 (2000);
         l_start_date     DATE := NVL (p_start_date, hr_general.start_of_time);
         l_end_date       DATE     := NVL (p_end_date, hr_general.end_of_time);
      BEGIN
         IF g_debug
         THEN
            hr_utility.TRACE ('Entering chk_a_and_r_overlap');
         END IF;

         OPEN chk_a_and_r_overlap (l_start_date, l_end_date);

         FETCH chk_a_and_r_overlap
          INTO l_message_text;

         IF (chk_a_and_r_overlap%FOUND)
         THEN
            fnd_message.set_name ('HXC', 'HXC_RET_ARCHIVE_DATA');
            l_message_text := SUBSTR (fnd_message.get (), 1, 2000);
            -- Bug 9173209
            -- Retrieval Log adjustment
            fnd_file.put_line (fnd_file.LOG,'  '||l_message_text);
         END IF;

         CLOSE chk_a_and_r_overlap;

         IF g_debug
         THEN
            hr_utility.TRACE ('Leaving chk_a_and_r_overlap');
         END IF;
      END check_a_and_r_overlap;

-- private procedure
--   get_field_mappings
--
-- description
--   Retrieves the mapping components for a given mapping_id
--   and populates the Global PL/SQL table g_field_mappings
--   table
--
-- parameters
--   p_mapping_id   - mapping_id
      FUNCTION get_field_mappings (p_mapping_id hxc_mappings.mapping_id%TYPE)
         RETURN t_field_mappings
      IS
--
         l_mapping_record   r_field_mappings;
         l_mappings_table   t_field_mappings;

--
         CURSOR csr_get_mappings
         IS
            SELECT   mpc.bld_blk_info_type_id, UPPER (mpc.field_name),
                     mpc.SEGMENT, bbit.bld_blk_info_type CONTEXT,
                     bbitu.building_block_category CATEGORY
                FROM hxc_bld_blk_info_type_usages bbitu,
                     hxc_bld_blk_info_types bbit,
                     hxc_mapping_components mpc,
                     hxc_mapping_comp_usages mcu,
                     hxc_mappings MAP
               WHERE MAP.mapping_id = p_mapping_id
                 AND mcu.mapping_id = MAP.mapping_id
                 AND mpc.mapping_component_id = mcu.mapping_component_id
                 AND bbit.bld_blk_info_type_id = mpc.bld_blk_info_type_id
                 AND bbitu.bld_blk_info_type_id = bbit.bld_blk_info_type_id
            ORDER BY 1, 2, 3;

         l_table_index      NUMBER           := 0;
         l_proc             VARCHAR2 (72);
      BEGIN                                              -- get field mappings
         IF g_debug
         THEN
            l_proc := g_package || 'get_field_mappings';
            hr_utility.set_location ('Entering ' || l_proc, 10);
         END IF;

         OPEN csr_get_mappings;

         FETCH csr_get_mappings
          INTO l_mapping_record;

         IF csr_get_mappings%NOTFOUND
         THEN
            fnd_message.set_name ('HXC', 'HXC_0016_GNRET_NO_MAPPINGS');
            fnd_message.raise_error;

            CLOSE csr_get_mappings;
         END IF;

         LOOP
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 20);
            END IF;

            l_table_index := l_table_index + 1;
            l_mappings_table (l_table_index) := l_mapping_record;

            FETCH csr_get_mappings
             INTO l_mapping_record;

            EXIT WHEN csr_get_mappings%NOTFOUND;
         END LOOP;

         CLOSE csr_get_mappings;

         IF g_debug
         THEN
            hr_utility.set_location ('Leaving ' || l_proc, 30);
         END IF;

         RETURN l_mappings_table;
      END get_field_mappings;

      PROCEDURE maintain_globals
      IS
      BEGIN
         g_conc_request_id := fnd_profile.VALUE ('CONC_REQUEST_ID');

         IF g_debug
         THEN
            hr_utility.TRACE ('Conc Req ID is ' || TO_CHAR (g_conc_request_id)
                             );
         END IF;

         -- Bug 9173209
         -- Retrieval Log adjustment
         fnd_file.put_line (fnd_file.LOG,
                            '  Conc Req ID is '
                            || TO_CHAR (g_conc_request_id)
                           );

         g_params.p_process := NULL;
         g_params.p_transaction_code := NULL;
         g_params.p_incremental := NULL;
         g_params.p_rerun_flag := NULL;
         g_params.p_where_clause := NULL;
         g_params.p_scope := NULL;
         g_params.p_clusive := NULL;
         g_params.p_unique_params := NULL;
         g_transaction_id := NULL;
         hxc_generic_retrieval_pkg.t_detail_bld_blks.DELETE;
         hxc_generic_retrieval_pkg.t_old_detail_bld_blks.DELETE;
         hxc_generic_retrieval_pkg.t_detail_attributes.DELETE;
         hxc_generic_retrieval_pkg.t_old_detail_attributes.DELETE;
         hxc_generic_retrieval_pkg.t_time_bld_blks.DELETE;
         t_old_detail_seq.DELETE;
         t_old_detail_bb_id.DELETE;
         t_old_detail_ovn.DELETE;
         hxc_generic_retrieval_pkg.t_tx_time_bb_id.DELETE;
         hxc_generic_retrieval_pkg.t_tx_time_bb_ovn.DELETE;
         hxc_generic_retrieval_pkg.t_tx_time_transaction_id.DELETE;
         hxc_generic_retrieval_pkg.t_tx_time_status.DELETE;
         hxc_generic_retrieval_pkg.t_tx_time_exception.DELETE;
         hxc_generic_retrieval_pkg.t_tx_day_bb_id.DELETE;
         hxc_generic_retrieval_pkg.t_tx_day_parent_id.DELETE;
         hxc_generic_retrieval_pkg.t_tx_day_bb_ovn.DELETE;
         hxc_generic_retrieval_pkg.t_tx_day_transaction_id.DELETE;
         hxc_generic_retrieval_pkg.t_tx_day_status.DELETE;
         hxc_generic_retrieval_pkg.t_tx_day_exception.DELETE;
         hxc_generic_retrieval_pkg.t_tx_detail_bb_id.DELETE;
         hxc_generic_retrieval_pkg.t_tx_detail_parent_id.DELETE;
         hxc_generic_retrieval_pkg.t_tx_detail_bb_ovn.DELETE;
         hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.DELETE;
         hxc_generic_retrieval_pkg.t_tx_detail_status.DELETE;
         hxc_generic_retrieval_pkg.t_tx_detail_exception.DELETE;
         -- Bug 9494444
         -- Added some new global tables, so deleting those also
         -- here.
         hxc_generic_retrieval_pkg.t_detail_rec_lines.DELETE;
         hxc_generic_retrieval_pkg.t_old_detail_rec_lines.DELETE;
         hxc_generic_retrieval_pkg.g_old_bb_ids.DELETE;
         hxc_generic_retrieval_pkg.t_bb.DELETE;
         hxc_generic_retrieval_pkg.g_no_timecards := TRUE;
         hxc_generic_retrieval_utils.g_resources.DELETE;

	 -- Bug 7595581
	 -- Retrieval Log

	 hxc_generic_retrieval_pkg.g_detail_skipped.DELETE;

         IF (NOT hxc_generic_retrieval_pkg.g_in_loop)
         THEN
            g_retrieval_process_id := NULL;
            g_retrieval_tr_id := NULL;
            g_field_mappings_table.DELETE;
         END IF;
      END maintain_globals;

-- private function get_valid_app_sets
-- (added for ELP related changes to the retrieval process 14-Mar-2003 sonarasi)
--
-- description
-- This function is used to return a string of valid application set ids for a given
-- time recipient. If the process is 'Apply Schedule Rules' or 'BEE Retrieval Process'
-- then we have an additional requirement. i,e the list of application set ids for
-- hr time recipient needs to be added to the list.
-- Parameters
--  p_retrieval_process : The Retrieval Process Name
--  p_retrieval_tr_id   : The time recipient id of the application.
      FUNCTION get_valid_app_sets (
         p_retrieval_process   hxc_retrieval_processes.NAME%TYPE,
         p_retrieval_tr_id     NUMBER
      )
         RETURN VARCHAR2
      IS
         CURSOR c_application_set_id (
            p_ret_tr_id_1   NUMBER,
            p_ret_tr_id_2   NUMBER
         )
         IS
            SELECT DISTINCT application_set_id
                       FROM hxc_application_set_comps_v
                      WHERE time_recipient_id IN
                                              (p_ret_tr_id_1, p_ret_tr_id_2);

         CURSOR csr_get_tr_id (p_application_id NUMBER)
         IS
            SELECT tr.time_recipient_id
              FROM hxc_time_recipients tr
             WHERE tr.application_id = p_application_id;

         l_application_set_id_string   VARCHAR2 (200)                   := '';
         l_ret_tr_id                   NUMBER            := p_retrieval_tr_id;
         l_hr_tr                       hxc_time_recipients.time_recipient_id%TYPE;
         l_ret_tr_id_1                 NUMBER            := p_retrieval_tr_id;
         l_ret_tr_id_2                 NUMBER                         := NULL;
      BEGIN
-- if the process is BEE retrieval process then we need to add the application set ids of
-- corresponding to hr time recipient id also.
         IF (p_retrieval_process IN
                            ('Apply Schedule Rules', 'BEE Retrieval Process')
            )
         THEN
            OPEN csr_get_tr_id (800);

            FETCH csr_get_tr_id
             INTO l_hr_tr;

            IF (csr_get_tr_id%NOTFOUND)
            THEN
               CLOSE csr_get_tr_id;

               fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
               fnd_message.set_token ('PROCEDURE', l_proc);
               fnd_message.set_token ('STEP', 'no HR Time Recipient ID');
               fnd_message.raise_error;
            END IF;

            CLOSE csr_get_tr_id;

            l_ret_tr_id_2 := l_hr_tr;
         END IF;

         FOR l_rec IN c_application_set_id (l_ret_tr_id_1, l_ret_tr_id_2)
         LOOP
            l_application_set_id_string :=
               l_application_set_id_string || ',' || l_rec.application_set_id;
         END LOOP;

         l_application_set_id_string :=
               ' AND
tbb_latest.application_set_id IN ('
            || SUBSTR (l_application_set_id_string, 2)
            || ')';
         RETURN l_application_set_id_string;
      END get_valid_app_sets;
   BEGIN                                          -- execute retrieval process
-- this is to handle the case where the OTLR and BEE are processed in
-- the loop
      g_debug := hr_utility.debug_enabled;

      IF (    g_params.p_process <> p_process
          AND hxc_generic_retrieval_pkg.g_in_loop
         )
      THEN
         -- reset global looping variables
         hxc_generic_retrieval_pkg.g_in_loop := FALSE;
         hxc_generic_retrieval_pkg.g_last_chunk := FALSE;
         hxc_generic_retrieval_pkg.g_no_timecards := TRUE;
         hxc_generic_retrieval_pkg.g_overall_no_timecards := TRUE;
      END IF;

      -- Bug 9173209
      -- Retrieval Log adjustment
      put_log('  ');
      put_log('  ');
      fnd_file.put_line (fnd_file.LOG,
                            fnd_date.date_to_canonical (SYSDATE)
                         || ' ******** OTL Processing Starts ******'
                        );
      put_log('##------------------------------------------------------## ');
      put_log(' Retrieval Process: '||UPPER(p_process));
      put_log('##------------------------------------------------------## ');

      -- Bug 9394444
      -- Added the following comments for the Retrieval Log
      put_log(' ');
      put_log(' ');

      IF p_process = 'Projects Retrieval Process'
       AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PA')
       AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
      THEN
          put_log('Process is running on Upgraded Mode ');
      ELSIF p_process IN ('BEE Retrieval Process','Apply Schedule Rules')
        AND hxc_upgrade_pkg.performance_upgrade_complete('RETRIEVAL_PAY')
        AND NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
      THEN
          put_log('Process is running on Upgraded Mode ');
      ELSIF NVL(FND_PROFILE.VALUE('HXC_USE_UPGRADED_RETRIEVAL_PROCESS'),'N') = 'Y'
      THEN
          put_log('Process is not running on Upgraded Mode because one or more ');
          put_log('Upgrade processes are not complete.  ');
      END IF;

      put_log(' ');
      put_log(' ');

      maintain_globals;

      IF (    hxc_generic_retrieval_pkg.g_in_loop
          AND hxc_generic_retrieval_pkg.g_last_chunk
         )
      THEN
         -- do nothing, this is the last iteration, we are in a loop and the last chunk
         -- has already been processed
         NULL;
      ELSE
         g_params.p_process := p_process;
         g_params.p_transaction_code := p_transaction_code;
         g_params.p_incremental := p_incremental;
         g_params.p_rerun_flag := p_rerun_flag;
         g_params.p_where_clause := p_where_clause;
         g_params.p_scope := p_scope;
         g_params.p_clusive := p_clusive;
         g_params.p_unique_params := p_unique_params;
         g_params.transfer_batch_size :=
                               fnd_profile.VALUE ('HXC_RETRIEVAL_BATCH_SIZE');
         g_params.retrieval_options :=
                    NVL (fnd_profile.VALUE ('HXC_RETRIEVAL_OPTIONS'), 'BOTH');

         IF (p_since_date IS NULL)
         THEN
            -- then get value from the profile option
            l_since_date :=
               NVL (SUBSTR (fnd_profile.VALUE ('HXC_RETRIEVAL_CHANGES_DATE'),
                            1,
                            3
                           ),
                    60
                   );

            BEGIN
               SELECT TO_NUMBER (l_since_date)
                 INTO l_since_date
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_since_date := 60;
            END;

            g_params.since_date := SYSDATE - TO_NUMBER (l_since_date);
         ELSE
            g_params.since_date :=
                              TO_DATE (p_since_date, 'RRRR/MM/DD HH24:MI:SS');
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE (   'final since date is '
                              || TO_CHAR (g_params.since_date,
                                          'hh24:mi:ss dd-mon-yy'
                                         )
                             );
         END IF;

         IF (p_start_date IS NOT NULL AND p_end_date IS NOT NULL)
         THEN
            g_params.p_start_date := TRUNC (p_start_date);
            g_params.p_end_date :=
               TO_DATE (   TO_CHAR (TRUNC (p_end_date), 'DD/MM/YYYY')
                        || ' 23:59:59',
                        'DD/MM/YYYY HH24:MI:SS'
                       );
            g_params.l_using_dates := TRUE;
         ELSIF (p_start_date IS NOT NULL AND p_end_date IS NULL)
         THEN
            g_params.p_start_date := TRUNC (p_start_date);
            g_params.p_end_date :=
               TO_DATE (   TO_CHAR (TRUNC (hr_general.end_of_time),
                                    'DD/MM/YYYY'
                                   )
                        || ' 23:59:59',
                        'DD/MM/YYYY HH24:MI:SS'
                       );
            g_params.l_using_dates := TRUE;
         ELSIF (p_start_date IS NULL AND p_end_date IS NOT NULL)
         THEN
            g_params.p_start_date := hr_general.start_of_time;
            g_params.p_end_date :=
               TO_DATE (   TO_CHAR (TRUNC (p_end_date), 'DD/MM/YYYY')
                        || ' 23:59:59',
                        'DD/MM/YYYY HH24:MI:SS'
                       );
            g_params.l_using_dates := TRUE;
         ELSE
            g_params.p_start_date := NULL;
            g_params.p_end_date := NULL;
            g_params.l_using_dates := FALSE;
         END IF;

-- check archived and restore over lap
         IF (    (NOT hxc_generic_retrieval_pkg.g_in_loop)
             AND (   (    g_params.retrieval_options = 'BOTH'
                      AND NOT g_params.p_process = 'BEE Retrieval Process'
                     )
                  OR (    g_params.retrieval_options = 'BEE'
                      AND g_params.p_process = 'BEE Retrieval Process'
                     )
                  OR (    g_params.retrieval_options = 'OTLR'
                      AND g_params.p_process = 'Apply Schedule Rules'
                     )
                  OR (g_params.p_process NOT IN
                            ('BEE Retrieval Process', 'Apply Schedule Rules')
                     )
                 )
            )
         THEN
            -- only want to do this once for the first loop since the params
            -- do not change for each loop and once for the Transfer Time from OTL to BEE
            check_a_and_r_overlap (g_params.p_start_date,
                                   g_params.p_end_date);
         END IF;

-- check to see if we want to turn trace on
         OPEN csr_debug;

         FETCH csr_debug
          INTO l_debug;

         CLOSE csr_debug;

         IF l_debug = 'Y'
         THEN
            glb_debug := TRUE;

            IF g_debug
            THEN
               hr_utility.trace_on
                              (trace_mode              => NULL,
                               session_identifier      => NVL
                                                             (p_transaction_code,
                                                              'RETRIEVAL'
                                                             )
                              );
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('Entering ' || l_proc, 10);
         END IF;

         IF (   g_params.p_transaction_code LIKE 'GAZ%'
             OR g_params.p_transaction_code IS NULL
            )
         THEN
            NULL;
--l_alter_session := 'alter session set sql_trace TRUE';

         --execute immediate l_alter_session;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE ('****  Retrieval Params are.... ****');
            hr_utility.TRACE ('');
            hr_utility.TRACE ('Process is          :' || g_params.p_process);
            hr_utility.TRACE (   'Transaction code is :'
                              || g_params.p_transaction_code
                             );
            hr_utility.TRACE ('Start Date is       :' || g_params.p_start_date);
            hr_utility.TRACE ('End Date is         :' || g_params.p_end_date);
            hr_utility.TRACE ('Incremental is      :'
                              || g_params.p_incremental
                             );
            hr_utility.TRACE ('Rerun Flag is       :' || g_params.p_rerun_flag);
            hr_utility.TRACE (   'Where Clause is     :'
                              || SUBSTR (g_params.p_where_clause, 1, 200)
                             );
            hr_utility.TRACE (SUBSTR (g_params.p_where_clause, 201, 200));
            hr_utility.TRACE (SUBSTR (g_params.p_where_clause, 401, 200));
            hr_utility.TRACE ('Scope is            :' || g_params.p_scope);
            hr_utility.TRACE ('Clusive is          :' || g_params.p_clusive);
            hr_utility.TRACE ('');
            hr_utility.TRACE ('****  Retrieval LOOPING GLOBALS are.... ****');
         END IF;

         IF (g_in_loop)
         THEN
            IF g_debug
            THEN
               hr_utility.TRACE ('G_IN_LOOP is TRUE');
            END IF;
         ELSE
            IF g_debug
            THEN
               hr_utility.TRACE ('G_IN_LOOP is FALSE');
            END IF;
         END IF;

         IF (g_last_chunk)
         THEN
            IF g_debug
            THEN
               hr_utility.TRACE ('G_LAST_CHUNK is TRUE');
            END IF;
         ELSE
            IF g_debug
            THEN
               hr_utility.TRACE ('G_LAST_CHUNK is FALSE');
            END IF;
         END IF;

         IF (g_no_timecards)
         THEN
            IF g_debug
            THEN
               hr_utility.TRACE ('G_NO_TIMECARDS is TRUE');
            END IF;
         ELSE
            IF g_debug
            THEN
               hr_utility.TRACE ('G_NO_TIMECARDS is FALSE');
            END IF;
         END IF;

         IF (g_overall_no_timecards)
         THEN
            IF g_debug
            THEN
               hr_utility.TRACE ('G_OVERALL_NO_TIMECARDS is TRUE');
            END IF;
         ELSE
            IF g_debug
            THEN
               hr_utility.TRACE ('G_OVERALL_NO_TIMECARDS is FALSE');
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE (   'l_range_start is '
                              || TO_CHAR (l_pkg_range_start)
                             );
            hr_utility.TRACE ('l_range_stop is ' || TO_CHAR (l_pkg_range_stop));
         END IF;

         IF (NOT hxc_generic_retrieval_pkg.g_in_loop)
         THEN
            -- check that the process is registered and return the mapping id
            -- and retrieval_process id
            chk_retrieval_process
                           (p_retrieval_process         => p_process,
                            p_retrieval_process_id      => g_retrieval_process_id,
                            p_retrieval_tr_id           => g_retrieval_tr_id,
                            p_mapping_id                => l_mapping_id
                           );

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 20);
            END IF;

            -- check to see if mapping_id exists and thus retrieval process registered
            IF (l_mapping_id IS NULL)
            THEN
               RAISE e_retrieval_not_registered;
            END IF;

-- now check to see if this retrieval is already running
-- only need to do this if NOT the 'Projects Retrieval Process'
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 30);
            END IF;

            IF (g_params.p_process = 'Apply Schedule Rules')
            THEN
               SELECT rp.retrieval_process_id
                 INTO l_ret_id
                 FROM hxc_retrieval_processes rp
                WHERE rp.NAME = 'BEE Retrieval Process';

               -- check to see that the last retrieval completed normally
               hxc_generic_retrieval_utils.RECOVERY
                                      (p_process_id      => g_retrieval_process_id,
                                       p_process         => p_process
                                      );

               IF NOT check_concurrency_ok
                                  (p_process_id             => g_retrieval_process_id,
                                   p_retrieval_process      => g_params.p_process,
                                   p_where_clause           => g_params.p_where_clause,
                                   p_unique_params          => g_params.p_unique_params
                                  )
               THEN
                  RAISE e_process_already_running;
               END IF;

               IF (g_params.retrieval_options = 'BOTH')
               THEN
                  hxc_generic_retrieval_utils.RECOVERY
                                        (p_process_id      => l_ret_id,
                                         p_process         => 'BEE Retrieval Process'
                                        );

                  -- check that the BEE Retrieval isn't also running
                  IF NOT check_concurrency_ok
                              (p_process_id             => l_ret_id,
                               p_retrieval_process      => 'BEE Retrieval Process',
                               p_where_clause           => g_params.p_where_clause,
                               p_unique_params          => g_params.p_unique_params
                              )
                  THEN
                     RAISE e_process_already_running;
                  END IF;
               END IF;
            ELSIF (g_params.p_process = 'BEE Retrieval Process')
            THEN
               -- check the HXC_RETRIEVAL_OPTIONS profile value
               IF (g_params.retrieval_options = 'BEE')
               THEN
                  -- Apply Schedule Rules was not called
                  hxc_generic_retrieval_utils.RECOVERY
                                     (p_process_id      => g_retrieval_process_id,
                                      p_process         => p_process
                                     );

                  IF NOT check_concurrency_ok
                                  (p_process_id             => g_retrieval_process_id,
                                   p_retrieval_process      => g_params.p_process,
                                   p_where_clause           => g_params.p_where_clause,
                                   p_unique_params          => g_params.p_unique_params
                                  )
                  THEN
                     RAISE e_process_already_running;
                  END IF;
               ELSE
                  -- we have already checked the BEE Retrieval when the process
                  -- started and cleaned up if appropriate
                  NULL;
               END IF;
            ELSE
               hxc_generic_retrieval_utils.RECOVERY
                                     (p_process_id      => g_retrieval_process_id,
                                      p_process         => p_process
                                     );

               IF NOT check_concurrency_ok
                                  (p_process_id             => g_retrieval_process_id,
                                   p_retrieval_process      => g_params.p_process,
                                   p_where_clause           => g_params.p_where_clause,
                                   p_unique_params          => g_params.p_unique_params
                                  )
               THEN
                  RAISE e_process_already_running;
               END IF;
            END IF;
         END IF;     -- IF ( NOT hxc_generic_retrieval_process_pkg.G_IN_LOOP )

-- audit the transaction (header)
         audit_transaction
                          (p_mode                        => 'I'      -- Insert
                                                               ,
                           p_transaction_process_id      => g_retrieval_process_id,
                           p_status                      => 'IN PROGRESS',
                           p_description                 => ''
                          );

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 40);
         END IF;

         IF NOT hxc_generic_retrieval_pkg.g_in_loop
         THEN
--Elp changes sonarasi 14-Mar-2003
--Now that we have the time recipient id, let us find out the application set id string.
--We call the get_valid_app_sets function to get the application set id string
--However we do a check here to see if the application set id string has already been
--obtained..Only if it is not obtained do we hit the database to find it.
--Note : g_app_set_id_string is indexed on g_retrieval_tr_id
            IF NOT (g_app_set_id_string.EXISTS (g_retrieval_tr_id))
            THEN
               g_app_set_id_string (g_retrieval_tr_id).app_set_id_string :=
                  get_valid_app_sets (p_retrieval_process      => p_process,
                                      p_retrieval_tr_id        => g_retrieval_tr_id
                                     );
            END IF;

--Elp changes sonarasi over

            --  get the field mappings associated with the mapping id
--  This populates the global table g_field_mappings_table
            g_field_mappings_table :=
                             get_field_mappings (p_mapping_id      => l_mapping_id);
         END IF;                    -- NOT hxc_generic_retrieval_pkg.G_IN_LOOP

-- parse the where clause and build the final query for execution
         l_where_clause_blk := LTRIM (RTRIM (p_where_clause));
         l_where_clause_att := LTRIM (RTRIM (p_where_clause));
         parse_it (p_where_clause_blk      => l_where_clause_blk,
                   p_where_clause_att      => l_where_clause_att
                  );
         l_where_clause_blk := replace_timecard_string (l_where_clause_blk);

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 60);
         END IF;

         l_dynamic_query :=
            build_query (p_where_clause_blk      => l_where_clause_blk,
                         p_where_clause_att      => l_where_clause_att
                        );

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 70);
         END IF;

-- lets see the query
         insert_query (l_dynamic_query, 'QUERY');
         maintain_chunks (p_where_clause => p_where_clause);
         populate_ret_range_blks;
         populate_max_ovn (p_where_clause => p_where_clause);

-- get the bulding blocks
-- execute the query, populate the tables
         IF (hxc_generic_retrieval_pkg.g_in_loop)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 71);
            END IF;

            WHILE (hxc_generic_retrieval_pkg.g_no_timecards)
            LOOP
               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 72);
               END IF;

               BEGIN
                  query_it (p_query => l_dynamic_query);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     -- Bug 9394444
                     hr_utility.trace(dbms_utility.format_error_backtrace);
                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'query EXCEPTION is '
                                          || SUBSTR (SQLERRM, 1, 60)
                                         );
                        hr_utility.TRACE (   'query EXCEPTION is '
                                          || SUBSTR (SQLERRM, 61, 120)
                                         );
                        hr_utility.TRACE (   'query EXCEPTION is '
                                          || SUBSTR (SQLERRM, 121, 180)
                                         );
                        hr_utility.TRACE (   'query EXCEPTION is '
                                          || SUBSTR (SQLERRM, 181, 240)
                                         );
                     END IF;

                     IF (    (   SQLERRM LIKE
                                      'ORA-20001: HXC_0013_GNRET_NO_BLD_BLKS%'
                              OR SQLERRM LIKE
                                     'ORA-20001: HXC_0012_GNRET_NO_TIMECARDS%'
                             )
                         AND (NOT hxc_generic_retrieval_pkg.g_last_chunk)
                        )
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location ('Processing ' || l_proc,
                                                    73
                                                   );
                        END IF;

                        -- Bug 8888911
                        -- Mark the exception to the log.
                        put_log('  ==================================================================================');
                        put_log('   There are no valid records for this set of resources to the recipient application');
                        put_log('  ===================================================================================');
                        IF g_detail_skipped.COUNT > 0
                        THEN
                            put_log('  ---- The following records were considered and are skipped for the below reason ----  ');
                        END IF;

                        maintain_chunks (p_where_clause => p_where_clause);
                        populate_ret_range_blks;
                        populate_max_ovn (p_where_clause => p_where_clause);
                     ELSIF (   SQLERRM LIKE
                                      'ORA-20001: HXC_0013_GNRET_NO_BLD_BLKS%'
                            OR SQLERRM LIKE
                                     'ORA-20001: HXC_0012_GNRET_NO_TIMECARDS%'
                           )
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location ('Processing ' || l_proc,
                                                    74
                                                   );
                        END IF;

                        IF (hxc_generic_retrieval_pkg.g_overall_no_timecards
                           )
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location ('Processing ' || l_proc,
                                                       75
                                                      );
                           END IF;

                           -- this is the last chunk and there have been no timecards
                           fnd_message.raise_error;
                           -- GPM v115.41
                           EXIT;
                        ELSE
                           -- last chunk and there were timecards but just not in this
                           -- this iteration
                           EXIT;
                        END IF;
                     ELSE
                        IF g_debug
                        THEN
                           hr_utility.set_location ('Processing ' || l_proc,
                                                    76
                                                   );
                        END IF;

                        audit_transaction
                           (p_mode                        => 'I'     -- Insert
                                                                ,
                            p_transaction_process_id      => g_retrieval_process_id,
                            p_status                      => 'ERRORS',
                            p_description                 => SUBSTR (SQLERRM,
                                                                     1,
                                                                     2000
                                                                    )
                           );
                        RAISE;
                     END IF;
               END;
            END LOOP;
         ELSE
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 77);
            END IF;

            query_it (p_query => l_dynamic_query);
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 80);
         END IF;

         IF (NOT hxc_generic_retrieval_pkg.g_last_chunk)
         THEN
            IF (g_params.p_incremental = 'Y')
            THEN
               query_old_timecard;
            END IF;
         END IF;          -- IF ( NOT hxc_generic_retrieval_pkg.G_LAST_CHUNK )

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 100);
         END IF;
      END IF;

-- ( hxc_generic_retrieval_pkg.G_IN_LOOP AND hxc_generic_retrieval_pkg.G_LAST_CHUNK );

      -- before we pass control to the recipient application check to make sure the conc
-- process has not been terminated

      -- Bug 9173209
      -- Retrieval Log adjustment
      fnd_file.put_line (fnd_file.LOG,
                            '  '||fnd_date.date_to_canonical (SYSDATE)
                         || ' > SKIPPED Blocks COUNT > '
                         || hxc_generic_retrieval_pkg.g_detail_skipped.COUNT
                        );

      IF (hxc_generic_retrieval_pkg.g_detail_skipped.COUNT > 0)
      THEN

           -- Bug 9458888
           -- Used for Retrieval Dashboard Process Tab
           l_skipped_tc_id := VARCHARTAB();
           l_skipped_bb_id := VARCHARTAB();
           l_skipped_bb_ovn := VARCHARTAB();
           l_skipped_desc := VARCHARTAB();
           l_index := 0;

         fnd_file.put_line
                         (fnd_file.LOG,
                             '  '||fnd_date.date_to_canonical (SYSDATE)
                          || ' > ******* Printing SKIPPED Detail Blocks *******'
                         );

	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

	fnd_file.put_line(fnd_file.log, '     RESOURCE ID   '
				     || '     TIMECARD      '
				     || '     DETAIL        '
				     || '     REMARKS       ');
	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

	FOR i IN hxc_generic_retrieval_pkg.g_detail_skipped.FIRST .. hxc_generic_retrieval_pkg.g_detail_skipped.LAST
	LOOP

	fnd_file.put_line(fnd_file.log, '     '
	    ||hxc_generic_retrieval_pkg.g_detail_skipped(i).resource_id
	    || '           '
	    || hxc_generic_retrieval_pkg.g_detail_skipped(i).timecard_id
	    || ' ['
	    || hxc_generic_retrieval_pkg.g_detail_skipped(i).timecard_ovn
	    || ']          '
	    || hxc_generic_retrieval_pkg.g_detail_skipped(i).bb_id
	    || ' ['
	    || hxc_generic_retrieval_pkg.g_detail_skipped(i).ovn
	    || ']          '
	    || hxc_generic_retrieval_pkg.g_detail_skipped(i).description);

	    -- Bug 9458888

	    g_temp_tc_list(i) := hxc_generic_retrieval_pkg.g_detail_skipped(i).timecard_id;

           l_skipped_tc_id.EXTEND(1);
           l_skipped_bb_id.EXTEND(1);
           l_skipped_bb_ovn.EXTEND(1);
           l_skipped_desc.EXTEND(1);
           l_index := l_index + 1;

           l_skipped_tc_id(l_index) := hxc_generic_retrieval_pkg.g_detail_skipped(i).timecard_id;
           l_skipped_bb_id(l_index) := hxc_generic_retrieval_pkg.g_detail_skipped(i).bb_id;
           l_skipped_bb_ovn(l_index) := hxc_generic_retrieval_pkg.g_detail_skipped(i).ovn;
           l_skipped_desc(l_index) := hxc_generic_retrieval_pkg.g_detail_skipped(i).description;


	END LOOP;

	-- Bug 9458888
	update_rdb_status(g_temp_tc_list,
	                  'PENDING',
	                  'SKIPPED');

        g_temp_tc_list.DELETE;

        FORALL i IN l_skipped_tc_id.FIRST..l_skipped_tc_id.LAST
             INSERT INTO hxc_rdb_process_details
                  ( timecard_id,
                    detail_id,
                    detail_ovn,
                    skipped_reason,
                    skip_level,
                    ret_user_id,
                    request_id,
                    process)
             VALUES ( l_skipped_tc_id(i),
                      l_skipped_bb_id (i),
                      l_skipped_bb_ovn(i),
                      l_skipped_desc(i),
                      'OTL_PROC',
                      FND_GLOBAL.user_ID,
                      FND_GLOBAL.conc_request_id,
                      g_params.p_process);

	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

    END IF;
      fnd_file.put_line
                (fnd_file.LOG,
                    '  '||fnd_date.date_to_canonical (SYSDATE)
                 || ' > Blocks COUNT being passed to RECIPIENT APPLICATION > '
                 || hxc_generic_retrieval_pkg.t_detail_bld_blks.COUNT
                );

      IF (hxc_generic_retrieval_pkg.t_detail_bld_blks.COUNT > 0)
      THEN
           -- Bug 9458888
           l_skipped_tc_id := VARCHARTAB();
           l_skipped_bb_id := VARCHARTAB();
           l_skipped_bb_ovn := VARCHARTAB();
           l_skipped_desc := VARCHARTAB();
           l_index := 0;

         fnd_file.put_line
             (fnd_file.LOG,
                 '  '||fnd_date.date_to_canonical (SYSDATE)
              || ' > ******* Passing the following blocks for RETRIEVAL *******'
             );

	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
	fnd_file.put_line(fnd_file.log, '     RESOURCE ID   '
				     || '     TIMECARD      '
				     || '     DETAIL        ');
	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

	FOR i IN hxc_generic_retrieval_pkg.t_detail_bld_blks.FIRST .. hxc_generic_retrieval_pkg.t_detail_bld_blks.LAST
	LOOP

	fnd_file.put_line(fnd_file.log, '     '
	    || hxc_generic_retrieval_pkg.t_detail_bld_blks(i).resource_id
	    || '          '
	    || hxc_generic_retrieval_pkg.t_detail_bld_blks(i).timecard_bb_id
	    || ' ['
	    || hxc_generic_retrieval_pkg.t_detail_bld_blks(i).timecard_ovn
	    || ']        '
	    || hxc_generic_retrieval_pkg.t_detail_bld_blks(i).bb_id
	    || ' ['
	    || hxc_generic_retrieval_pkg.t_detail_bld_blks(i).ovn
	    || '] ');

           l_skipped_tc_id.EXTEND(1);
           l_skipped_bb_id.EXTEND(1);
           l_skipped_bb_ovn.EXTEND(1);
           l_skipped_desc.EXTEND(1);
           l_index := l_index + 1;

           l_skipped_tc_id(l_index) := hxc_generic_retrieval_pkg.t_detail_bld_blks(i).timecard_bb_id;
           l_skipped_bb_id(l_index) := hxc_generic_retrieval_pkg.t_detail_bld_blks(i).bb_id;
           l_skipped_bb_ovn(l_index) := hxc_generic_retrieval_pkg.t_detail_bld_blks(i).ovn;
           l_skipped_desc(l_index) := NULL ;

	   g_temp_tc_list(i) := hxc_generic_retrieval_pkg.t_detail_bld_blks(i).timecard_bb_id;

           -- Bug 9494444
           -- The below tables record all the actual details that are getting retrieved
           --  old or new, but not just deleted entries.  This is for Payroll application
           --  where the batch details are plugged in these tables later.
           t_detail_rec_lines(i).bb_id :=  hxc_generic_retrieval_pkg.t_detail_bld_blks(i).bb_id;
           t_detail_rec_lines(i).ovn   :=  hxc_generic_retrieval_pkg.t_detail_bld_blks(i).ovn;


	END LOOP;

        -- Bug 9494444
        -- The below tables record all the old bb id ovns going out for retro adjustments.
        -- Used by Payroll application later when the actual batch details are plugged into these
        -- tables.
        IF t_old_detail_bld_blks.COUNT > 0
  	THEN
  	   l_index := t_old_detail_bld_blks.FIRST;
  	   LOOP
  	      t_old_detail_rec_lines(l_index).bb_id := t_old_detail_bld_blks(l_index).bb_id;
  	      t_old_detail_rec_lines(l_index).ovn   := t_old_detail_bld_blks(l_index).ovn;
  	      g_old_bb_ids(t_old_detail_bld_blks(l_index).bb_id) := t_old_detail_bld_blks(l_index).bb_id;
  	      l_index := t_old_detail_bld_blks.NEXT(l_index);
  	      EXIT WHEN NOT t_old_detail_bld_blks.EXISTS(l_index);
  	   END LOOP;
  	END IF;


	-- Bug 9458888
	update_rdb_status(g_temp_tc_list,
	                  'PENDING',
	                  'PROCESSING');
	update_rdb_status(g_temp_tc_list,
	                  'SKIPPED',
	                  'PROCESSING_PARTIAL');
	g_temp_tc_list.DELETE;

         FORALL i IN l_skipped_tc_id.FIRST..l_skipped_tc_id.LAST
             INSERT INTO hxc_rdb_process_details
                  ( timecard_id,
                    detail_id,
                    detail_ovn,
                    skipped_reason,
                    skip_level,
                    ret_user_id,
                    request_id,
                    process)
             VALUES ( l_skipped_tc_id(i),
                      l_skipped_bb_id (i),
                      l_skipped_bb_ovn(i),
                      l_skipped_desc(i),
                      'OTL_PROC',
                      FND_GLOBAL.user_ID,
                      FND_GLOBAL.conc_request_id,
                      g_params.p_process);


	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

	END IF;





      IF (hxc_generic_retrieval_utils.chk_terminated (g_conc_request_id))
      THEN
         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', 'Generic Retrieval');
         fnd_message.set_token ('STEP', ': Process Terminated');
         fnd_message.raise_error;
      END IF;
   EXCEPTION
      WHEN e_retrieval_not_registered
      THEN
         fnd_message.set_name ('HXC', 'HXC_0011_GNRET_NOT_REGISTERED');
         fnd_message.raise_error;
      WHEN e_process_already_running
      THEN
         fnd_message.set_name ('HXC', 'HXC_0017_GNRET_PROCESS_RUNNING');
         fnd_message.raise_error;
      WHEN e_no_ranges
      THEN
         fnd_message.set_name ('HXC', 'HXC_0012_GNRET_NO_TIMECARDS');
         fnd_message.raise_error;
      WHEN OTHERS
      THEN
         -- Bug 9394444
         hr_utility.trace(dbms_utility.format_error_backtrace);
         audit_transaction
                         (p_mode                        => 'I'       -- Insert
                                                              ,
                          p_transaction_process_id      => g_retrieval_process_id,
                          p_status                      => 'ERRORS',
                          p_description                 => SUBSTR (SQLERRM,
                                                                   1,
                                                                   2000
                                                                  )
                         );
-- now we need to unlock any TCs which were locked
         hxc_lock_api.release_lock
            (p_row_lock_id              => NULL,
             p_process_locker_type      => hxc_generic_retrieval_pkg.g_lock_type,
             p_transaction_lock_id      => hxc_generic_retrieval_pkg.g_transaction_id,
             p_released_success         => l_boolean
            );
         RAISE;
--
   END execute_retrieval_process;

-- private procedure
--    delete_retrieval_ranges
--
-- description
--    Deletes retrieval_ranges which is filled up by each retrieval process id
--    Gets called when the transaction is updated with either 'SUCESS' or 'DELETE'
--    from update_transaction_status
--    Deletes based on concurrent process id which is unique for each process
--    Ref. Bug 5669202
  PROCEDURE delete_retrieval_ranges (p_transaction_id IN hxc_transactions.transaction_id%TYPE)
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

       DELETE FROM HXC_RETRIEVAL_RANGE_RESOURCES
       WHERE RETRIEVAL_RANGE_ID IN
           ( SELECT RETRIEVAL_RANGE_ID
             FROM HXC_RETRIEVAL_RANGES
             WHERE CONC_REQUEST_ID = g_conc_request_id
	     AND   TRANSACTION_ID = p_transaction_id);

       DELETE FROM HXC_RETRIEVAL_RANGES
       WHERE  CONC_REQUEST_ID = g_conc_request_id
       AND    TRANSACTION_ID = p_transaction_id;

       COMMIT;
  END delete_retrieval_ranges;

-- public procedure
--   update_transaction_status
--
-- description
--   Wrapper process such that audit transaction can be called externally.
--   Updates the transactions for the retrieval once the recipient API has
--   processed all the time bld blks. This procedure is called from the
--   recipient API. The retrieval has already populated a global PL/SQL table
--   with transaction details for each bld blk. The recipient API will have
--   maintained this table appropriately. All this process does is
--   update the transaction bulk bound (for performance) and maintain the
--   transaction header records. unless of course the retrieval is being
--   rolled back in which case all the detail records are deleted.
--
-- Parameters
--   p_process - retrieval process name
--   p_status  - the status of the overall retrieval
--   p_exception_description - exception description
--   p_rollback - is the retrieval being rolled back
   PROCEDURE update_transaction_status (
      p_process                 hxc_retrieval_processes.NAME%TYPE,
      p_status                  hxc_transactions.status%TYPE,
      p_exception_description   hxc_transactions.exception_description%TYPE,
      p_rollback                BOOLEAN DEFAULT FALSE
   )
   IS
-- going to call the chk_retrieval_process procedure - do not need mapping id
      l_process_id            hxc_retrieval_processes.retrieval_process_id%TYPE;
      l_mapping_id            hxc_mappings.mapping_id%TYPE;
      l_tx_id                 hxc_transactions.transaction_id%TYPE;
      l_proc                  VARCHAR2 (72);
      l_time_max              INTEGER;
      l_day_max               INTEGER;
      l_detail_max            INTEGER;
      l_error_max             INTEGER;
      l_lock_ind              PLS_INTEGER;
      l_message_table         hxc_message_table_type;
      l_boolean               BOOLEAN;
      l_temp_transaction_id   t_transaction_id;
      l_ranges_to_process     number;


      -- Bug 9494444
      -- A whole set of types and variables declared here, used for
      -- taking the snapshot of the records used by the retrieval.
      TYPE VARCHARTAB IS TABLE OF VARCHAR2(500);
      TYPE DATETAB    IS TABLE OF DATE;
      TYPE NUMTAB     IS TABLE OF NUMBER;

      t_l_resource_id                NUMTAB ;
      t_l_time_building_block_id     NUMTAB ;
      t_l_approval_status            VARCHARTAB ;
      t_l_start_time                 DATETAB ;
      t_l_stop_time                  DATETAB ;
      t_l_org_id                     NUMTAB ;
      t_l_business_group_id          NUMTAB ;
      t_l_timecard_id                NUMTAB ;
      t_l_attribute1                 VARCHARTAB ;
      t_l_attribute2                 VARCHARTAB ;
      t_l_attribute3                 VARCHARTAB ;
      t_l_measure                    NUMTAB ;
      t_l_object_version_number      NUMTAB ;



      l_resource_id                  NUMTAB     := NUMTAB()  ;
      l_time_building_block_id       NUMTAB     := NUMTAB() ;
      l_approval_status              VARCHARTAB := VARCHARTAB() ;
      l_start_time                   DATETAB    := DATETAB() ;
      l_stop_time                    DATETAB    := DATETAB() ;
      l_org_id                       NUMTAB     := NUMTAB() ;
      l_business_group_id            NUMTAB     := NUMTAB() ;
      l_timecard_id                  NUMTAB     := NUMTAB() ;
      l_attribute1                   VARCHARTAB := VARCHARTAB() ;
      l_attribute2                   VARCHARTAB := VARCHARTAB() ;
      l_attribute3                   VARCHARTAB := VARCHARTAB() ;
      l_measure                      NUMTAB     := NUMTAB() ;
      l_object_version_number        NUMTAB     := NUMTAB() ;

      l_counter     BINARY_INTEGER := 0;

      l_old_tbb       NUMTAB;
      l_exists_tbb    NUMBERTABLE;
      l_index         BINARY_INTEGER := 0;

      l_rec_bb_id     NUMTAB := NUMTAB();
      l_rec_ovn       NUMTAB := NUMTAB();
      l_rec_id        NUMTAB := NUMTAB();
      l_batch_id      NUMTAB := NUMTAB();


      -- Bug 9701936
      -- Added these tables to effectively process Success and Error status
      -- details.
      l_success_tc    NUMTABLE;
      l_error_tc      NUMTABLE;



   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'update_transaction_status';
         hr_utility.TRACE ('In Update Transaction Status');
      END IF;

-- get the process id
      chk_retrieval_process (p_retrieval_process         => p_process,
                             p_retrieval_process_id      => l_process_id,
                             p_retrieval_tr_id           => g_retrieval_tr_id,
                             p_mapping_id                => l_mapping_id
                            );

-- now call the audit transaction appropriately
      IF g_debug
      THEN
         hr_utility.set_location ('Processing ' || l_proc, 110);
      END IF;

      -- Bug 6914381
      -- If any transaction resulted in error, there is no need to
      -- do a reversal entry.  Hence delete the same record from
      -- HXC_BEE_PREF_ADJ_LINES.
      -- Do it only for Xfer time from OTL to BEE.

      IF g_params.p_process IN ('BEE Retrieval Process', 'Apply Schedule Rules')
      THEN
         IF hxc_generic_retrieval_pkg.t_tx_detail_bb_id.COUNT > 0
         THEN
            FORALL i IN hxc_generic_retrieval_pkg.t_tx_detail_bb_id.FIRST..
                                hxc_generic_retrieval_pkg.t_tx_detail_bb_id.LAST

                DELETE FROM hxc_bee_pref_adj_lines
                   WHERE detail_bb_id = t_tx_detail_bb_id(i)
                     AND batch_source = DECODE(g_params.p_process,
                                              'BEE Retrieval Process', 'OTM',
                                              'Apply Schedule Rules' , 'Time Store')
                     AND t_tx_detail_status(i) = 'ERRORS'                         ;
         END IF;
      END IF;



      IF (p_status = 'ERRORS')
      THEN
         -- call audit transaction
         -- we want to commit these transactions for audit purposes
         -- before the process rolls them back
         audit_transaction (p_mode                        => 'U'     -- update
                                                                ,
                            p_transaction_process_id      => l_process_id,
                            p_status                      => p_status,
                            p_description                 => p_exception_description,
                            p_rollback                    => p_rollback
                           );
      ELSE
         -- retrieval was successful - do the same work as audit_transaction except
         -- allow the recipient application commit the data.
         l_time_max := hxc_generic_retrieval_pkg.t_tx_time_bb_id.COUNT;
         l_day_max := hxc_generic_retrieval_pkg.t_tx_day_bb_id.COUNT;
         l_detail_max := hxc_generic_retrieval_pkg.t_tx_detail_bb_id.COUNT;
         l_error_max := hxc_generic_retrieval_pkg.t_tx_error_bb_id.COUNT;

         OPEN csr_get_tx_id;

         FETCH csr_get_tx_id
          INTO l_tx_id;

         CLOSE csr_get_tx_id;

         INSERT INTO hxc_transactions
                     (transaction_id, transaction_process_id,
                      transaction_date, TYPE, status,
                      exception_description
                     )
              VALUES (l_tx_id, l_process_id,
                      SYSDATE, 'RETRIEVAL_STATUS_UPDATE', p_status,
                      p_exception_description
                     );

         UPDATE hxc_transactions
            SET status = p_status,
                exception_description = p_exception_description
          WHERE transaction_id = hxc_generic_retrieval_pkg.g_transaction_id;

         IF NOT p_rollback
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 130);
            END IF;

-- check to see if any tx time details
            IF l_time_max <> 0
            THEN
-- now let's bulk fetch all the transaction detail id
               OPEN csr_get_tx_detail_id (l_time_max);

               FETCH csr_get_tx_detail_id
               BULK COLLECT INTO l_temp_transaction_id;

               CLOSE csr_get_tx_detail_id;

               hxc_generic_retrieval_pkg.t_tx_time_transaction_id :=
                                                        l_temp_transaction_id;

               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 50);
               END IF;

               FORALL tx_detail IN hxc_generic_retrieval_pkg.t_tx_time_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_time_transaction_id.LAST
                  INSERT INTO hxc_transaction_details
                              (transaction_detail_id,
                               time_building_block_id,
                               time_building_block_ovn,
                               transaction_id,
                               status,
                               exception_description
                              )
                       VALUES (hxc_generic_retrieval_pkg.t_tx_time_transaction_id
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_time_bb_id
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_time_bb_ovn
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.g_transaction_id,
                               hxc_generic_retrieval_pkg.t_tx_time_status
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_time_exception
                                                                    (tx_detail)
                              );
            END IF;                                         -- l_time_max <> 0

-- check to see if any tx day details
            IF l_day_max <> 0
            THEN
-- now let's bulk fetch all the transaction detail id
               OPEN csr_get_tx_detail_id (l_day_max);

               FETCH csr_get_tx_detail_id
               BULK COLLECT INTO l_temp_transaction_id;

               CLOSE csr_get_tx_detail_id;

               hxc_generic_retrieval_pkg.t_tx_day_transaction_id :=
                                                        l_temp_transaction_id;

               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 60);
               END IF;

               FORALL tx_detail IN hxc_generic_retrieval_pkg.t_tx_day_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_day_transaction_id.LAST
                  INSERT INTO hxc_transaction_details
                              (transaction_detail_id,
                               time_building_block_id,
                               time_building_block_ovn,
                               transaction_id,
                               status,
                               exception_description
                              )
                       VALUES (hxc_generic_retrieval_pkg.t_tx_day_transaction_id
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_day_bb_id
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_day_bb_ovn
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.g_transaction_id,
                               hxc_generic_retrieval_pkg.t_tx_day_status
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_day_exception
                                                                    (tx_detail)
                              );
            END IF;                                          -- l_day_max <> 0

-- check to see if any tx detail details
            IF l_detail_max <> 0
            THEN
-- now let's bulk fetch all the transaction detail id
               OPEN csr_get_tx_detail_id (l_detail_max);

               FETCH csr_get_tx_detail_id
               BULK COLLECT INTO l_temp_transaction_id;

               CLOSE csr_get_tx_detail_id;

               hxc_generic_retrieval_pkg.t_tx_detail_transaction_id :=
                                                        l_temp_transaction_id;

               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 70);
               END IF;

               FORALL tx_detail IN hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.LAST
                  INSERT INTO hxc_transaction_details
                              (transaction_detail_id,
                               time_building_block_id,
                               time_building_block_ovn,
                               transaction_id,
                               status,
                               exception_description
                              )
                       VALUES (hxc_generic_retrieval_pkg.t_tx_detail_transaction_id
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_detail_bb_id
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_detail_bb_ovn
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.g_transaction_id,
                               hxc_generic_retrieval_pkg.t_tx_detail_status
                                                                    (tx_detail),
                               hxc_generic_retrieval_pkg.t_tx_detail_exception
                                                                    (tx_detail)
                              );

               -- Bug 9394444
               -- In case the transactions are SUCCESS, we need to delete from
               -- the tables maintaining these.
               -- This has to be done irrespective of whether Upgraded process
               -- is chosen or not.

               -- Bug 9494444
               -- Added code to return the relevant values for the mirror retrieval
               -- tables.
               IF g_params.p_process = 'Projects Retrieval Process'
               THEN
                   FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_detail_bb_id.FIRST ..
                                      hxc_generic_retrieval_pkg.t_tx_detail_bb_id.LAST
                        DELETE FROM hxc_pa_latest_details
                              WHERE time_building_block_id = hxc_generic_retrieval_pkg.t_tx_detail_bb_id(tx_error)
                               AND hxc_generic_retrieval_pkg.t_tx_detail_status
                                                                    (tx_error) = 'SUCCESS'
                         RETURNING
                                 resource_id,
                                 time_building_block_id,
                                 approval_status,
                                 start_time,
                                 stop_time,
                                 org_id,
                                 business_group_id,
                                 timecard_id,
                                 attribute1,
                                 attribute2,
                                 attribute3,
                                 measure,
                                 object_version_number
                         BULK
                          COLLECT INTO
                                t_l_resource_id,
                                t_l_time_building_block_id,
                                t_l_approval_status,
                                t_l_start_time,
                                t_l_stop_time,
                                t_l_org_id,
                                t_l_business_group_id,
                                t_l_timecard_id,
                                t_l_attribute1,
                                t_l_attribute2,
                                t_l_attribute3,
                                t_l_measure,
                                t_l_object_version_number;

                   -- If there are any successful deletes from hxc_pa_latest_details
                   -- move them to HXC_RET_PA_LATEST_DETAILS
                   -- Keep recording whichever bb ids are updated.

                   IF t_l_resource_id.COUNT > 0
                   THEN

                       FORALL i IN t_l_time_building_block_id.FIRST..t_l_time_building_block_id.LAST
                            UPDATE hxc_ret_pa_latest_details
                               SET old_attribute1 = attribute1,
                                   old_attribute2 = attribute2,
                                   old_attribute3 = attribute3,
                                   old_measure    = measure,
                                   old_ovn        = object_version_number,
                                   old_pei_id     = pei_id,
                                   old_exp_group  = exp_group,
                                   pei_id         = NULL,
                                   exp_group      = NULL,
                                   measure        = t_l_measure(i),
                                   attribute1     = t_l_attribute1(i),
                                   attribute2     = t_l_attribute2(i),
                                   attribute3     = t_l_attribute3(i),
                                   object_version_number = t_l_object_version_number(i),
                                   business_group_id = t_l_business_group_id(i),
                                   org_id     = t_l_org_id(i),
                                   approval_status = t_l_approval_status(i),
                                   old_request_id = request_id,
                                   request_id = FND_GLOBAL.conc_request_id
                             WHERE time_building_block_id = t_l_time_building_block_id(i)
                           RETURNING time_building_block_id
                                BULK COLLECT INTO l_old_tbb;

                       IF l_old_tbb.COUNT > 0
                       THEN
                          FOR i IN l_old_tbb.FIRST..l_old_tbb.LAST
                          LOOP
                             l_exists_tbb(l_old_tbb(i)) := l_old_tbb(i);
                          END LOOP;
                       END IF;


                       -- Remove the above updated bb ids from the tables, to avoid any
                       -- errors in the following insert.
                       FOR i IN t_l_time_building_block_id.FIRST..t_l_time_building_block_id.LAST
                       LOOP
                          IF NOT l_exists_tbb.EXISTS(t_l_time_building_block_id(i))
                            -- If this also exists in the retro list of building blocks,
                            -- this was retrieved earlier, but missed the update above.
                            -- Do not insert such a record into the table, because it should
                            -- have been an UPDATE.
                            AND NOT g_old_bb_ids.EXISTS(t_l_time_building_block_id(i))
                          THEN
                                l_counter := l_counter+1;
                                l_resource_id  .EXTEND(1) ;
                                l_time_building_block_id  .EXTEND(1) ;
                                l_approval_status  .EXTEND(1) ;
                                l_start_time  .EXTEND(1) ;
                                l_stop_time  .EXTEND(1) ;
                                l_org_id  .EXTEND(1) ;
                                l_business_group_id  .EXTEND(1) ;
                                l_timecard_id  .EXTEND(1) ;
                                l_attribute1  .EXTEND(1) ;
                                l_attribute2  .EXTEND(1) ;
                                l_attribute3  .EXTEND(1) ;
                                l_measure  .EXTEND(1) ;
                                l_object_version_number .EXTEND(1) ;

                                l_resource_id  (l_counter) := 		t_l_resource_id(i);
                                l_time_building_block_id  (l_counter) := 	    t_l_time_building_block_id(i);
                                l_approval_status  (l_counter) := 	    t_l_approval_status(i);
                                l_start_time  (l_counter) := 		    t_l_start_time(i);
                                l_stop_time  (l_counter) := 		    t_l_stop_time(i);
                                l_org_id  (l_counter) := 			    t_l_org_id(i);
                                l_business_group_id  (l_counter) := 	    t_l_business_group_id(i);
                                l_timecard_id  (l_counter) := 		    t_l_timecard_id(i);
                                l_attribute1  (l_counter) := 		    t_l_attribute1(i);
                                l_attribute2  (l_counter) := 		    t_l_attribute2(i);
                                l_attribute3  (l_counter) := 		    t_l_attribute3(i);
                                l_measure  (l_counter) := 		    t_l_measure(i);
                                l_object_version_number (l_counter) := 	    t_l_object_version_number (i);

                          END IF;
                       END LOOP;


                       -- Insert the records which are new into the table.
                       FORALL i IN l_time_building_block_id.FIRST..l_time_building_block_id.LAST
                          INSERT INTO hxc_ret_pa_latest_details
                                     (resource_id,
                                      time_building_block_id,
                                      approval_status,
                                      start_time,
                                      stop_time,
                                      org_id,
                                      business_group_id,
                                      timecard_id,
                                      attribute1,
                                      attribute2,
                                      attribute3,
                                      measure,
                                      object_version_number,
                                      request_id
                                      )
                             VALUES     (
                                          l_resource_id(i),
                                          l_time_building_block_id(i),
                                          l_approval_status(i),
                                          l_start_time(i),
                                          l_stop_time(i),
                                          l_org_id(i),
                                          l_business_group_id(i),
                                          l_timecard_id(i),
                                          l_attribute1(i),
                                          l_attribute2(i),
                                          l_attribute3(i),
                                          l_measure(i),
                                          l_object_version_number(i),
                                          FND_GLOBAL.conc_request_id);


                   END IF;


                   -- Bug 9458888

                   g_temp_tc_list.DELETE;

                   -- Bug 9626621
                   -- There were two deletes in place of one happening here, making
                   -- the RETURNING INTO table go empty.


                   -- Bug 9701936
                   -- Made some modifications in the DELETE and UPDATE below.


                   FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_detail_bb_id.FIRST ..
                                      hxc_generic_retrieval_pkg.t_tx_detail_bb_id.LAST
                        DELETE FROM hxc_rdb_process_details
                              WHERE detail_id   = hxc_generic_retrieval_pkg.t_tx_detail_bb_id(tx_error)
                               AND hxc_generic_retrieval_pkg.t_tx_detail_status
                                                                    (tx_error) = 'SUCCESS'
                                AND request_id  = FND_GLOBAL.CONC_REQUEST_ID
                                AND ret_user_id = FND_global.user_id
                                AND process     = g_params.p_process
                          RETURNING timecard_id
                               BULK
                            COLLECT INTO l_success_tc ;

                   -- Picking up unique timecard ids.
                   l_success_tc := SET(l_success_tc);


                   FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_detail_bb_id.FIRST ..
                                      hxc_generic_retrieval_pkg.t_tx_detail_bb_id.LAST
                        UPDATE hxc_rdb_process_details
                           SET skip_level = 'REC_PROC',
                               skipped_reason = hxc_generic_retrieval_pkg.t_tx_detail_exception
                                                                    (tx_error)
                              WHERE detail_id = hxc_generic_retrieval_pkg.t_tx_detail_bb_id(tx_error)
                               AND hxc_generic_retrieval_pkg.t_tx_detail_status
                                                                    (tx_error) = 'ERRORS'
                               AND request_id = FND_GLOBAL.CONC_REQUEST_ID
                               AND ret_user_id = FND_global.user_id
                               AND process = g_params.p_process
                         RETURNING timecard_id
                              BULK
                           COLLECT INTO l_error_tc ;

                   -- Picking up unique timecard ids.
                   l_error_tc := SET(l_error_tc);


                   -- Now we have two Nested tables one of the successful details' timecard_ids
                   -- and one of the errored details' timecard id.
                   -- Using the below SET operations, passing the relevant records to the
                   -- update procedure to mark the relevant statuses.

                   -- All Success
                   update_rdb_status((l_success_tc MULTISET EXCEPT l_error_tc),
                                      'PROCESSING',
                                      'PROCESSED');

                   -- All Success, but skipped some earlier
                   update_rdb_status((l_success_tc MULTISET EXCEPT l_error_tc),
                                      'PROCESSING_PARTIAL',
                                      'PROCESSED_PARTIALLY');

                   -- All Errors
                   update_rdb_status((l_error_tc MULTISET EXCEPT l_success_tc),
                                     'PROCESSING',
                                     'ERRORED');

                   -- All Errors, but skipped some earlier
                   update_rdb_status((l_error_tc MULTISET EXCEPT l_success_tc),
                                     'PROCESSING_PARTIAL',
                                     'ERRORED');

                   -- Some errors
                   update_rdb_status((l_error_tc MULTISET INTERSECT l_success_tc),
                                     'PROCESSING',
                                     'PROCESSED_PARTIALLY');

                   -- Some errors, but skipped some earlier
                   update_rdb_status((l_error_tc MULTISET INTERSECT l_success_tc),
                                     'PROCESSING_PARTIAL',
                                     'PROCESSED_PARTIALLY');




               END IF;

               IF g_params.p_process IN ( 'BEE Retrieval Process','Apply Schedule Rules')
               THEN
                   g_temp_tc_list.DELETE;

                   -- Similar processing like projects above.
                   FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_detail_bb_id.FIRST ..
                                      hxc_generic_retrieval_pkg.t_tx_detail_bb_id.LAST
                        DELETE FROM hxc_pay_latest_details
                              WHERE time_building_block_id = hxc_generic_retrieval_pkg.t_tx_detail_bb_id(tx_error)
                               AND hxc_generic_retrieval_pkg.t_tx_detail_status
                                                                    (tx_error) = 'SUCCESS'
                         RETURNING
                                 resource_id,
                                 time_building_block_id,
                                 approval_status,
                                 start_time,
                                 stop_time,
                                 org_id,
                                 business_group_id,
                                 timecard_id,
                                 attribute1,
                                 attribute2,
                                 attribute3,
                                 measure,
                                 object_version_number
                           BULK COLLECT INTO
                                t_l_resource_id,
                                t_l_time_building_block_id,
                                t_l_approval_status,
                                t_l_start_time,
                                t_l_stop_time,
                                t_l_org_id,
                                t_l_business_group_id,
                                t_l_timecard_id,
                                t_l_attribute1,
                                t_l_attribute2,
                                t_l_attribute3,
                                t_l_measure,
                                t_l_object_version_number;

                   IF t_l_resource_id.COUNT > 0
                   THEN

                      FORALL i IN t_l_time_building_block_id.FIRST..t_l_time_building_block_id.LAST
                          UPDATE hxc_ret_pay_latest_details
                             SET old_attribute1 = attribute1,
                                 old_attribute2 = attribute2,
                                 old_attribute3 = attribute3,
                                 old_measure    = measure,
                                 old_ovn        = object_version_number,
                                 measure = t_l_measure(i),
                                 attribute1 = t_l_attribute1(i),
                                 attribute2 = t_l_attribute2(i),
                                 attribute3 = t_l_attribute3(i),
                                 object_version_number = t_l_object_version_number(i),
                                 business_group_id = t_l_business_group_id(i),
                                 org_id     = t_l_org_id(i),
                                 approval_status = t_l_approval_status(i),
                                 old_request_id  = request_id,
                                 old_batch_id    = batch_id,
                                 request_id      = FND_global.conc_request_id
                           WHERE time_building_block_id = t_l_time_building_block_id(i)
                       RETURNING time_building_block_id
                            BULK COLLECT INTO l_old_tbb;

                       IF l_old_tbb.COUNT > 0
                       THEN
                          FOR i IN l_old_tbb.FIRST..l_old_tbb.LAST
                          LOOP
                             l_exists_tbb(l_old_tbb(i)) := l_old_tbb(i);
                          END LOOP;
                       END IF;


                       FOR i IN t_l_time_building_block_id.FIRST..t_l_time_building_block_id.LAST
                       LOOP
                          IF NOT l_exists_tbb.EXISTS(t_l_time_building_block_id(i))
                            AND NOT g_old_bb_ids.EXISTS(t_l_time_building_block_id(i))
                          THEN
                                l_counter := l_counter+1;
                                l_resource_id  .EXTEND(1) ;
                                l_time_building_block_id  .EXTEND(1) ;
                                l_approval_status  .EXTEND(1) ;
                                l_start_time  .EXTEND(1) ;
                                l_stop_time  .EXTEND(1) ;
                                l_org_id  .EXTEND(1) ;
                                l_business_group_id  .EXTEND(1) ;
                                l_timecard_id  .EXTEND(1) ;
                                l_attribute1  .EXTEND(1) ;
                                l_attribute2  .EXTEND(1) ;
                                l_attribute3  .EXTEND(1) ;
                                l_measure  .EXTEND(1) ;
                                l_object_version_number .EXTEND(1) ;

                                l_resource_id  (l_counter) := 		    t_l_resource_id(i);
                                l_time_building_block_id  (l_counter) :=    t_l_time_building_block_id(i);
                                l_approval_status  (l_counter) := 	    t_l_approval_status(i);
                                l_start_time  (l_counter) := 		    t_l_start_time(i);
                                l_stop_time  (l_counter) := 		    t_l_stop_time(i);
                                l_org_id  (l_counter) := 		    t_l_org_id(i);
                                l_business_group_id  (l_counter) := 	    t_l_business_group_id(i);
                                l_timecard_id  (l_counter) := 		    t_l_timecard_id(i);
                                l_attribute1  (l_counter) := 		    t_l_attribute1(i);
                                l_attribute2  (l_counter) := 		    t_l_attribute2(i);
                                l_attribute3  (l_counter) := 		    t_l_attribute3(i);
                                l_measure  (l_counter) := 		    t_l_measure(i);
                                l_object_version_number (l_counter) := 	    t_l_object_version_number (i);

                          END IF;
                       END LOOP;


                       FORALL i IN l_time_building_block_id.FIRST..l_time_building_block_id.LAST
                          INSERT INTO hxc_ret_pay_latest_details
                               (resource_id,
                                time_building_block_id,
                                approval_status,
                                start_time,
                                stop_time,
                                org_id,
                                business_group_id,
                                timecard_id,
                                attribute1,
                                attribute2,
                                attribute3,
                                measure,
                                object_version_number,
                                request_id
                                )
                            VALUES     (
                                    l_resource_id(i),
                                    l_time_building_block_id(i),
                                    l_approval_status(i),
                                    l_start_time(i),
                                    l_stop_time(i),
                                    l_org_id(i),
                                    l_business_group_id(i),
                                    l_timecard_id(i),
                                    l_attribute1(i),
                                    l_attribute2(i),
                                    l_attribute3(i),
                                    l_measure(i),
                                    l_object_version_number(i),
                                    FND_GLOBAL.conc_request_id);

                       -- This is payroll specific code.
                       -- Picking up the batch id information back on to the table.
                       l_counter := 0;
                       IF t_detail_rec_lines.COUNT > 0
                       THEN
                          l_index := t_detail_rec_lines.FIRST;
                          LOOP
                             l_counter := l_counter + 1;
                             l_rec_bb_id.EXTEND(1);
                             l_rec_ovn.EXTEND(1);
                             l_rec_id.EXTEND(1);
                             l_batch_id.EXTEND(1);

                             l_rec_bb_id(l_counter) := t_detail_rec_lines(l_index).bb_id;
                             l_rec_ovn(l_counter) := t_detail_rec_lines(l_index).ovn;
                             l_rec_id(l_counter) := t_detail_rec_lines(l_index).rec_id;
                             l_batch_id(l_counter) := t_detail_rec_lines(l_index).batch_id;

                             l_index := t_detail_rec_lines.NEXT(l_index);

                             EXIT WHEN NOT t_detail_rec_lines.EXISTS(l_index);
                          END LOOP;


                          FORALL i IN l_rec_bb_id.FIRST..l_rec_bb_id.LAST
                            UPDATE hxc_ret_pay_latest_details
                               SET old_pbl_id = pbl_id,
                                   pbl_id = l_rec_id(i),
                                   batch_id = l_batch_id(i)
                             WHERE time_building_block_id = l_rec_bb_id(i)
                               AND object_version_number  = l_rec_ovn(i);

                       END IF;

                       l_counter := 0;
                       IF t_old_detail_rec_lines.COUNT > 0
                       THEN
                          l_index := t_old_detail_rec_lines.FIRST;
                          LOOP
                             l_counter := l_counter + 1;
                             l_rec_bb_id.EXTEND(1);
                             l_rec_ovn.EXTEND(1);
                             l_rec_id.EXTEND(1);
                             l_batch_id.EXTEND(1);

                             l_rec_bb_id(l_counter) := t_old_detail_rec_lines(l_index).bb_id;
                             l_rec_ovn(l_counter) := t_old_detail_rec_lines(l_index).ovn;
                             l_rec_id(l_counter) := t_old_detail_rec_lines(l_index).rec_id;
                             l_batch_id(l_counter) := t_old_detail_rec_lines(l_index).batch_id;

                             l_index := t_old_detail_rec_lines.NEXT(l_index);

                             EXIT WHEN NOT t_old_detail_rec_lines.EXISTS(l_index);
                          END LOOP;


                          FORALL i IN l_rec_bb_id.FIRST..l_rec_bb_id.LAST
                            UPDATE hxc_ret_pay_latest_details
                               SET retro_pbl_id = l_rec_id(i),
                                   retro_batch_id = l_batch_id(i)
                             WHERE time_building_block_id = l_rec_bb_id(i)
                               AND old_ovn  = l_rec_ovn(i);

                   END IF;



               END IF;


                   -- Bug 9701936
                   -- Follows the same logic as Projects Application above.

                   FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_detail_bb_id.FIRST ..
                                      hxc_generic_retrieval_pkg.t_tx_detail_bb_id.LAST
                        DELETE FROM hxc_rdb_process_details
                              WHERE detail_id   = hxc_generic_retrieval_pkg.t_tx_detail_bb_id(tx_error)
                               AND hxc_generic_retrieval_pkg.t_tx_detail_status
                                                                    (tx_error) = 'SUCCESS'
                                AND request_id  = FND_GLOBAL.CONC_REQUEST_ID
                                AND ret_user_id = FND_global.user_id
                                AND process     = g_params.p_process
                          RETURNING timecard_id
                               BULK
                            COLLECT INTO l_success_tc ;

                   l_success_tc := SET(l_success_tc);



                   FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_detail_bb_id.FIRST ..
                                      hxc_generic_retrieval_pkg.t_tx_detail_bb_id.LAST
                        UPDATE hxc_rdb_process_details
                           SET skip_level     = 'REC_PROC',
                               skipped_reason = hxc_generic_retrieval_pkg.t_tx_detail_exception
                                                                    (tx_error)
                              WHERE detail_id   = hxc_generic_retrieval_pkg.t_tx_detail_bb_id(tx_error)
                               AND hxc_generic_retrieval_pkg.t_tx_detail_status
                                                                    (tx_error) = 'ERRORS'
                               AND request_id   = FND_GLOBAL.CONC_REQUEST_ID
                               AND ret_user_id  = FND_global.user_id
                               AND process      = g_params.p_process
                         RETURNING timecard_id
                              BULK
                           COLLECT INTO l_error_tc ;


                     l_error_tc := SET(l_error_tc);

                     -- All Success
                     update_rdb_status((l_success_tc MULTISET EXCEPT l_error_tc),
                                      'PROCESSING',
                                      'PROCESSED');

                     -- All Success, but skipped some earlier
                     update_rdb_status((l_success_tc MULTISET EXCEPT l_error_tc),
                                      'PROCESSING_PARTIAL',
                                      'PROCESSED_PARTIALLY');

                     -- All Errors
                     update_rdb_status((l_error_tc MULTISET EXCEPT l_success_tc),
                                      'PROCESSING',
                                      'ERRORED');
                     -- All Errors, but skipped some earlier
                     update_rdb_status((l_error_tc MULTISET EXCEPT l_success_tc),
                                      'PROCESSING_PARTIAL',
                                      'ERRORED');

                     -- Some errors
                     update_rdb_status((l_error_tc MULTISET INTERSECT l_success_tc),
                                      'PROCESSING',
                                      'PROCESSED_PARTIALLY');

                     -- Some errors, but skipped some earlier
                     update_rdb_status((l_error_tc MULTISET INTERSECT l_success_tc),
                                      'PROCESSING_PARTIAL',
                                      'PROCESSED_PARTIALLY');


               END IF;




               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 75);
               END IF;
            END IF;                                       -- l_detail_max <> 0

            IF g_debug
            THEN
               hr_utility.set_location ('Processing ' || l_proc, 80);
            END IF;

            IF l_error_max <> 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 85);
               END IF;

-- now let's bulk fetch all the transaction detail id
               OPEN csr_get_tx_detail_id (l_error_max);

               FETCH csr_get_tx_detail_id
               BULK COLLECT INTO l_temp_transaction_id;

               CLOSE csr_get_tx_detail_id;

               hxc_generic_retrieval_pkg.t_tx_error_transaction_id :=
                                                         l_temp_transaction_id;

               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 90);
               END IF;

               FORALL tx_error IN hxc_generic_retrieval_pkg.t_tx_error_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_error_transaction_id.LAST
                  INSERT INTO hxc_transaction_details
                              (transaction_detail_id,
                               time_building_block_id,
                               time_building_block_ovn,
                               transaction_id,
                               status,
                               exception_description
                              )
                       VALUES (hxc_generic_retrieval_pkg.t_tx_error_transaction_id
                                                                     (tx_error),
                               hxc_generic_retrieval_pkg.t_tx_error_bb_id
                                                                     (tx_error),
                               hxc_generic_retrieval_pkg.t_tx_error_bb_ovn
                                                                     (tx_error),
                               hxc_generic_retrieval_pkg.g_transaction_id,
                               hxc_generic_retrieval_pkg.t_tx_error_status
                                                                     (tx_error),
                               hxc_generic_retrieval_pkg.t_tx_error_exception
                                                                     (tx_error)
                              );
-- given we are only going to do this once and the recipient app does not need
-- to maintain these statuses we can delete the arrays
               hxc_generic_retrieval_pkg.t_tx_error_transaction_id.DELETE;
               hxc_generic_retrieval_pkg.t_tx_error_bb_id.DELETE;
               hxc_generic_retrieval_pkg.t_tx_error_bb_ovn.DELETE;
               hxc_generic_retrieval_pkg.t_tx_error_status.DELETE;
               hxc_generic_retrieval_pkg.t_tx_error_exception.DELETE;

               IF g_debug
               THEN
                  hr_utility.set_location ('Processing ' || l_proc, 100);
               END IF;
            END IF;                                        -- l_error_max <> 0
         END IF;                                                 -- p_rollback

         IF g_debug
         THEN
            hr_utility.set_location ('Processing ' || l_proc, 170);
         END IF;

         -- need to clean up the hxc retrieval ranges table if the process
         -- has errored.
         IF (p_status = 'ERRORS')
         THEN
            UPDATE hxc_retrieval_ranges
               SET transaction_id = -1
             WHERE retrieval_process_id = l_process_id AND transaction_id = -1;
         END IF;
      END IF;                                           -- p_status = 'ERRORS'

-- now we need to unlock any TCs which were locked
      hxc_lock_api.release_lock
         (p_row_lock_id              => NULL,
          p_process_locker_type      => hxc_generic_retrieval_pkg.g_lock_type,
          p_transaction_lock_id      => hxc_generic_retrieval_pkg.g_transaction_id,
          p_released_success         => l_boolean
         );

	--bug 5669202

	IF ((p_status = 'SUCCESS' OR p_status = 'ERRORS') AND l_process_id <> -1)
	-- DO NOT DELETE FOR 'IN PROGRESS' TRANSACTIONS
        THEN
               IF g_debug
               THEN
                       hr_utility.TRACE ('g_conc_request_id is ' || g_conc_request_id);
               END IF;

               delete_retrieval_ranges (hxc_generic_retrieval_pkg.g_transaction_id);

               IF g_debug
               THEN
                       hr_utility.set_location ('Processing ' || l_proc, 200);
               END IF;
        ELSE
               IF g_debug
               THEN
                       hr_utility.set_location ('Processing ' || l_proc, 250);
               END IF;
        END IF;

      IF (hxc_generic_retrieval_utils.chk_terminated
                                         (fnd_profile.VALUE ('CONC_REQUEST_ID')
                                         )
         )
      THEN
         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', 'Generic Retrieval');
         fnd_message.set_token ('STEP', ': Process Terminated');
         fnd_message.raise_error;

      END IF;

      fnd_file.put_line
                   (fnd_file.LOG,
                       '  '||fnd_date.date_to_canonical (SYSDATE)
                    || ' > Blocks COUNT of TRANSACTION DETAILS > '
                    || hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.COUNT
                   );

      IF (hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.COUNT > 0)
      THEN
         fnd_file.put_line
            (fnd_file.LOG,
                '  '||fnd_date.date_to_canonical (SYSDATE)
             || ' > ******* Details Recevied from the RECIPIENT APPLICATION *******'
            );

	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
	fnd_file.put_line(fnd_file.log, '     DETAIL      '
				     || '     TRANSACTON ID      '
				     || '     STATUS        '
				     || '     DESCRIPTION       ');
	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

	FOR i IN hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_detail_transaction_id.LAST
	LOOP

	fnd_file.put_line(fnd_file.log,
	     '     '
	    || hxc_generic_retrieval_pkg.t_tx_detail_bb_id(i)
	    || ' ['
	    || hxc_generic_retrieval_pkg.t_tx_detail_bb_ovn(i)
	    || ']       '
	    || hxc_generic_retrieval_pkg.t_tx_detail_transaction_id(i)
	    || '        '
	    || hxc_generic_retrieval_pkg.t_tx_detail_status(i)
	    || '        '
	    || hxc_generic_retrieval_pkg.t_tx_detail_exception(i));

	END LOOP;

	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

	END IF;

      fnd_file.put_line
                    (fnd_file.LOG,
                        '  '||fnd_date.date_to_canonical (SYSDATE)
                     || ' > ERRORed BLOCK count > '
                     || hxc_generic_retrieval_pkg.t_tx_error_transaction_id.COUNT
                    );

      IF (hxc_generic_retrieval_pkg.t_tx_error_transaction_id.COUNT > 0)
      THEN
         fnd_file.put_line
                      (fnd_file.LOG,
                          '  '||fnd_date.date_to_canonical (SYSDATE)
                       || ' > ******* The following blocks are in ERROR *******'
                      );

	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
	fnd_file.put_line(fnd_file.log, '     DETAIL      '
				     || '     TRANSACTON ID      '
				     || '     STATUS        '
				     || '     DESCRIPTION       ');
	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

	FOR i IN hxc_generic_retrieval_pkg.t_tx_error_transaction_id.FIRST .. hxc_generic_retrieval_pkg.t_tx_error_transaction_id.LAST
	LOOP

	fnd_file.put_line(fnd_file.log,
	    '    '
	    || hxc_generic_retrieval_pkg.t_tx_error_bb_id(i)
	    || ' ['
	    || hxc_generic_retrieval_pkg.t_tx_error_bb_ovn(i)
	    || ']       '
	    || hxc_generic_retrieval_pkg.t_tx_error_transaction_id(i)
	    || '        '
	    || hxc_generic_retrieval_pkg.t_tx_error_status(i)
	    || '        '
	    || hxc_generic_retrieval_pkg.t_tx_error_exception(i));

	END LOOP;

	fnd_file.put_line(fnd_file.log, '  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');


      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('Leaving Update Transaction Status');
      END IF;
   END update_transaction_status;


  -- Bug 8888911
  -- Added this new function call so that writing on to FND_FILE.LOG is easy.
  -- It is known that put_log is not grammar friendly, but since we are going to use
  -- this one quite a lot, one which is short is easier to write.
  PROCEDURE put_log(p_text   IN VARCHAR2)
  IS

  BEGIN
       FND_FILE.PUT_LINE(FND_FILE.LOG,p_text);
       IF g_debug
       THEN
          hr_utility.trace(p_text);
       END IF;
  END put_log;

-- Bug 9458888
-- Added for Retrieval Dashboard Process tab to update
-- In progress and processing timecards.
PROCEDURE update_rdb_status ( p_tc_list  NUMBERTABLE,
                              p_from_status   VARCHAR2,
                              p_to_status     VARCHAR2)
IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    TYPE NUMTAB IS TABLE OF NUMBER;
    l_tctab    NUMTAB;
    i  BINARY_INTEGER;
    l_index  BINARY_INTEGER := 0;

BEGIN

     l_tctab := NUMTAB();
     IF p_tc_list.COUNT > 0
     THEN
         i :=p_tc_list.FIRST;
         LOOP
            l_tctab.EXTEND(1);
            l_index := l_index + 1;
            l_tctab(l_index) := p_tc_list(i);
            i := p_tc_list.NEXT(i);
            EXIT WHEN NOT p_tc_list.EXISTS(i);
         END LOOP;
     END IF;

     l_tctab := SET(l_tctab);

     FORALL i IN l_tctab.FIRST..l_tctab.LAST
        UPDATE hxc_rdb_process_timecards
           SET stage = p_to_status
         WHERE timecard_id = l_tctab(i)
           AND stage = p_from_status
           AND process = g_params.p_process;

     COMMIT;

END update_rdb_status;


-- Bug 9701936
-- Added this overloaded function to take in a
-- Nested Table of numbers.  Has only the updates required.

PROCEDURE update_rdb_status ( p_tc_list  NUMTABLE,
                              p_from_status   VARCHAR2,
                              p_to_status     VARCHAR2)
IS

    PRAGMA AUTONOMOUS_TRANSACTION;


BEGIN

     IF p_tc_list.COUNT = 0
     THEN
        RETURN;
     END IF;

     FORALL i IN p_tc_list.FIRST..p_tc_list.LAST
        UPDATE hxc_rdb_process_timecards
           SET stage = p_to_status
         WHERE timecard_id = p_tc_list(i)
           AND stage = p_from_status
           AND process = g_params.p_process;

     COMMIT;

END update_rdb_status;



END hxc_generic_retrieval_pkg;

/
