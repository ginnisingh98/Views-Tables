--------------------------------------------------------
--  DDL for Package EDW_CHECK_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_CHECK_DATA_INTEGRITY" AUTHID CURRENT_USER AS
/*$Header: EDWCHDTS.pls 120.0 2005/06/01 17:28:36 appldev noship $*/
 version               CONSTANT VARCHAR (80)
            := '$Header: EDWCHDTS.pls 120.0 2005/06/01 17:28:36 appldev noship $';

   TYPE varchartabletypel IS TABLE OF VARCHAR2 (4000)
      INDEX BY BINARY_INTEGER;

   g_read_object_settings_failure   EXCEPTION;
   g_stg_tables_not_found           EXCEPTION;
   g_file                           UTL_FILE.file_type;
   g_lstg_tables                    edw_owb_collection_util.varchartabletype;
   g_lstg_table_long_name           edw_owb_collection_util.varchartabletype;
   g_lstg_tables_id                 edw_owb_collection_util.numbertabletype;
   g_number_lstg_tables             NUMBER;
   g_lstg_instance_col              edw_owb_collection_util.varchartabletype;
   --the instance column
   g_lstg_pk                        edw_owb_collection_util.varchartabletype;
   g_lstg_pk_id                     edw_owb_collection_util.numbertabletype;
   g_lstg_pk_long                   edw_owb_collection_util.varchartabletype;
   g_lstg_total_records             edw_owb_collection_util.numbertabletype;
   g_detailed_check                 BOOLEAN;
   g_parallel                       NUMBER;
   g_fk_table                       VARCHAR2 (400);

--all fk variables..we store the staging table name again
--in g_lstg_fk_table to make queries...
--g_parent_ltc_fk_table is the parent ltc table
--g_hier is which hierarchy

   g_main_lstg_fk_table             edw_owb_collection_util.varchartabletype;
   --if a lstg table has 3 keys, this will have 3 keys
   g_main_lstg_fk_table_lstg        edw_owb_collection_util.varchartabletype;
   --which is the lstg table
   g_number_main_lstg_fk_table      NUMBER;
   g_lstg_fk_table                  edw_owb_collection_util.varchartabletype;
   --only points to g_main_lstg_fk_table
   g_lstg_fk_table_id               edw_owb_collection_util.numbertabletype;
   g_parent_lstg_fk_table           edw_owb_collection_util.varchartabletype;
   g_parent_lstg_fk_table_id        edw_owb_collection_util.numbertabletype;
   g_parent_lstg_fk_table_pk        edw_owb_collection_util.varchartabletype;
   g_parent_ltc_fk_table            edw_owb_collection_util.varchartabletype;
   g_parent_ltc_fk_table_id         edw_owb_collection_util.numbertabletype;
   g_parent_ltc_fk_table_long       edw_owb_collection_util.varchartabletype;
   g_parent_ltc_fk_table_pk         edw_owb_collection_util.varchartabletype;
   g_parent_ltc_fk_table_pk_long    edw_owb_collection_util.varchartabletype;
   g_lstg_fk                        edw_owb_collection_util.varchartabletype;
   g_lstg_fk_id                     edw_owb_collection_util.numbertabletype;
   g_lstg_fk_long                   edw_owb_collection_util.varchartabletype;
   g_lstg_fk_number                 NUMBER;
   g_hier                           edw_owb_collection_util.varchartabletype;

--we need distinct list of hierarchies....
   g_hier_distinct                  edw_owb_collection_util.varchartabletype;
   g_number_hier_distinct           NUMBER;
   g_check_dimension                BOOLEAN;
   g_lstg_fk_position               edw_owb_collection_util.numbertabletype;
                                                                         --??
--g_lstg_fk_position will have g_number_lstg_tables entries
--each entry is an index into g_lstg_fk

   g_ltc_tables                     edw_owb_collection_util.varchartabletype;
   g_ltc_tables_long                edw_owb_collection_util.varchartabletype;
   g_ltc_tables_long_name           edw_owb_collection_util.varchartabletype;
   g_number_ltc_tables              NUMBER;
   g_ltc_pk                         edw_owb_collection_util.varchartabletype;
   g_all_level_exists               BOOLEAN;
   g_all_level                      VARCHAR2 (400);
   g_bottom_level                   VARCHAR2 (400);
   g_bottom_records                 NUMBER;

/*
the sql statements
these are varchars instead of tables because we use binding
for high performance...like CBR929RR....
*/
   g_dup_stmt_num                   varchartabletypel;
   g_dup_stmt_str                   varchartabletypel;
   g_lstg_lstg_dangling_stmt_num    varchartabletypel;
   g_lstg_lstg_null_stmt_num        varchartabletypel;
   g_lstg_lstg_dangling_stmt_str    varchartabletypel;
   g_lstg_ltc_dangling_stmt_num     varchartabletypel;
   g_lstg_ltc_dangling_stmt_str     varchartabletypel;
   g_hier_stmt_num                  VARCHAR2 (30000);
   g_collection_status_stmt_num     varchartabletypel;
   g_log_name                       VARCHAR2 (200);
   g_debug                          BOOLEAN;
   g_number_sample                  NUMBER;
   --this is for logging into the output
   g_number_max_sample              NUMBER;
   --this is for logging into the tables
   g_check_against_ltc              BOOLEAN;
   g_check_hier                     BOOLEAN;
   g_sample_on                      BOOLEAN;
   g_names                          edw_owb_collection_util.varchartabletype;
   g_names_long                     edw_owb_collection_util.varchartabletype;
   g_ids                            edw_owb_collection_util.numbertabletype;
   g_number_names                   NUMBER;
   g_object_name                    VARCHAR2 (200);
   g_object_type                    VARCHAR2 (40);
   g_object_id                      NUMBER;
   g_status_message                 VARCHAR2 (4000);
   g_exec_flag                      BOOLEAN;
   g_duplicate_check                BOOLEAN;

/***********************************************
   Fact Variables
************************************************/
   g_fstg_name                      VARCHAR2 (400);
   g_fstg_id                        NUMBER;
   g_fstg_name_long                 VARCHAR2 (400);
   g_fstg_pk                        VARCHAR2 (400);
   g_fstg_pk_id                     NUMBER;
   g_fstg_pk_long                   VARCHAR2 (400);
   g_fstg_fk                        edw_owb_collection_util.varchartabletype;
   g_fstg_fk_id                     edw_owb_collection_util.numbertabletype;
   g_fstg_fk_long                   edw_owb_collection_util.varchartabletype;
   g_number_fstg_fk                 NUMBER;
   g_fstg_instance_col              VARCHAR2 (400);
   --assume that this is a fk for now
   g_fact_dims                      edw_owb_collection_util.varchartabletype;
   g_fact_dims_id                   edw_owb_collection_util.numbertabletype;
   g_fact_dims_long                 edw_owb_collection_util.varchartabletype;
   g_fact_dims_pk                   edw_owb_collection_util.varchartabletype;
   g_fact_dims_pk_long              edw_owb_collection_util.varchartabletype;
   g_fstg_total_records             NUMBER;

/***********STATEMENTS*****************/
   g_fact_dup_stmt_num              VARCHAR2 (20000);
   g_fact_dup_stmt_str              VARCHAR2 (20000);
   g_fact_dang_stmt_num             varchartabletypel;
   g_fact_dang_stmt_str             varchartabletypel;
   g_number_dang_stmt               NUMBER;
   g_fstg_makeit_stmt               VARCHAR2 (30000);

--g_lstg_rowid_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
   g_lstg_pk_table                  edw_owb_collection_util.varchartabletype;
   g_lstg_dup_pk_table              edw_owb_collection_util.varchartabletype;
                                                 --holds the dup pk and count
/*g_parent_lstg EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_lstg EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_lstg_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_lstg_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_parent_lstg number;
g_parent_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_ltc_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;*/
   g_lstg_fk_hold_table             edw_owb_collection_util.varchartabletype;
   --will hold the fks from the lstg
   g_number_lstg_fk_hold_table      edw_owb_collection_util.numbertabletype;
   g_lstg_ok_table                  edw_owb_collection_util.varchartabletype;
   -- rowids of the staging table that are ok with lstg
   g_lstg_dang_table                edw_owb_collection_util.varchartabletype;
   -- FKS and the count of the staging table that are dang with lstgs
   g_lstg_dang_rowid_table          edw_owb_collection_util.varchartabletype;
   -- rowids of the staging table that are dang with lstgs
   g_ltc_ok_table                   edw_owb_collection_util.varchartabletype;
   -- rowids of the staging table that are ok with ltc
   g_ltc_dang_table                 edw_owb_collection_util.varchartabletype;
   -- rowids of the staging table that are dang with ltc
   g_ltc_dang_rowid_table           edw_owb_collection_util.varchartabletype;

--g_fact_rowid_table varchar2(400);
   g_fact_pk_table                  VARCHAR2 (400);
   g_fact_dup_pk_table              VARCHAR2 (400);
   g_fact_fk_table                  edw_owb_collection_util.varchartabletype;
   g_number_fact_fk_table           edw_owb_collection_util.numbertabletype;
   g_fact_fk_ok_table               edw_owb_collection_util.varchartabletype;
   g_fact_fk_dang_rowid_table       edw_owb_collection_util.varchartabletype;
   g_bis_owner                      VARCHAR2 (400);
   g_fk_to_check                    edw_owb_collection_util.varchartabletype;
   g_number_fk_to_check             NUMBER;
   g_fk_check_flag                  edw_owb_collection_util.booleantabletype;
   g_results_table_flag             BOOLEAN;
   g_results_table                  VARCHAR2 (200);
   g_request_id                     NUMBER;
   g_op_table_space                 VARCHAR2 (400);
   g_dim_missing_keys_op            VARCHAR2 (400);
   g_process_dang_keys              BOOLEAN;

   PROCEDURE init_all (p_object_name IN VARCHAR2);

   PROCEDURE close_all;

   PROCEDURE write_to_log (p_message IN VARCHAR2);

   PROCEDURE write_to_log_n (p_message IN VARCHAR2);

   PROCEDURE write_to_out (p_message IN VARCHAR2);

   PROCEDURE write_to_out_n (p_message IN VARCHAR2);

   FUNCTION check_dimension (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_time
      RETURN VARCHAR2;

   FUNCTION get_lstg_ltc_keys (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_lstg_ltc_pk (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_lstg_ltc_fk (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE check_dimensions_data (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY     VARCHAR2,
      p_dim_string1         IN       VARCHAR2,
      p_check_against_ltc   IN       VARCHAR2,
      p_check_tot_recs      IN       VARCHAR2,
      p_detailed_check      IN       VARCHAR2,
      p_sample_size         IN       NUMBER
   );

   FUNCTION parse_names (
      p_dim_string1   IN   VARCHAR2,
      p_dim_string2   IN   VARCHAR2,
      p_dim_string3   IN   VARCHAR2,
      p_dim_string4   IN   VARCHAR2,
      p_dim_string5   IN   VARCHAR2
   )
      RETURN BOOLEAN;

   FUNCTION get_lstg_given_ltc (p_ltc IN VARCHAR2)
      RETURN VARCHAR2;

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
      RETURN VARCHAR2;

   FUNCTION make_sql_statements
      RETURN BOOLEAN;

   FUNCTION make_hier_count_stmt
      RETURN BOOLEAN;

   FUNCTION execute_dim_check (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_dim_duplicate_check (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_dim_dangling_check (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_pk_for_lstg (p_lstg IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_pk_for_ltc (
      p_ltc                  IN   VARCHAR2,
      l_lstg_ltc_parent      IN   edw_owb_collection_util.varchartabletype,
      l_lstg_ltc_parent_pk   IN   edw_owb_collection_util.varchartabletype,
      l_number_lstg          IN   NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION execute_dim_dang_check_lstg (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_dim_dang_check_ltc (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_dim_all_records (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_num_recs_lstg (p_lstg IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION execute_hier_count (p_dim_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_table_alias (p_table IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE write_to_out_log (p_message IN VARCHAR2);

   PROCEDURE write_to_out_log_n (p_message IN VARCHAR2);

   FUNCTION get_long_names
      RETURN BOOLEAN;

   FUNCTION get_long_for_short_name (p_name IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_lstg_long_name (p_table IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_fk_long (
      p_fk              IN   VARCHAR2,
      fk_table_long     IN   edw_owb_collection_util.varchartabletype,
      fk_table          IN   edw_owb_collection_util.varchartabletype,
      fk_table_number   IN   NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_parent_ltc_long (
      p_ltc                    IN   VARCHAR2,
      p_lstg_ltc_parent        IN   edw_owb_collection_util.varchartabletype,
      p_lstg_ltc_parent_long   IN   edw_owb_collection_util.varchartabletype,
      p_number_lstg            IN   NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_ltc_pk_long (
      p_parent_ltc_fk_table_pk    IN   VARCHAR2,
      p_lstg_ltc_parent_pk        IN   edw_owb_collection_util.varchartabletype,
      p_lstg_ltc_parent_pk_long   IN   edw_owb_collection_util.varchartabletype,
      p_number_lstg               IN   NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_lstg_pk (p_table IN VARCHAR2)
      RETURN VARCHAR2;


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
      p_fk_to_check      IN       VARCHAR2 DEFAULT NULL
   );

   FUNCTION check_fact (p_fact_name IN VARCHAR2, p_fact_name_long IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_fstg_dim_keys (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_fact_check (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION make_sql_statements_fact (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_fact_duplicate_check (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_fact_dangling_check (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_fact_total_records (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION execute_fstg_makeit_stmt (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION generate_fk_table (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE clean_up;

   FUNCTION drop_lstg_fk_tables
      RETURN BOOLEAN;

   FUNCTION create_lstg_fk_tables
      RETURN BOOLEAN;

   FUNCTION drop_lstg_pk_tables
      RETURN BOOLEAN;

   FUNCTION create_fstg_fk_tables (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION drop_fstg_fk_tables (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION drop_fstg_pk_table (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION drop_fk_table (p_fact_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION create_main_lstg_fk_tables
      RETURN BOOLEAN;

   FUNCTION get_fk_to_check (p_fk_to_check IN VARCHAR2)
      RETURN BOOLEAN;

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
      RETURN BOOLEAN;

   FUNCTION delete_cdi_results_table (p_object_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION log_into_cdi_dang_table (
      p_key_id             IN   NUMBER,
      p_table_id           IN   NUMBER,
      p_parent_table_id    IN   NUMBER,
      p_key_value          IN   VARCHAR2,
      p_number_key_value   IN   NUMBER,
      p_instance           IN   VARCHAR2
   )
      RETURN BOOLEAN;

   FUNCTION create_g_dim_missing_keys_op (p_object_name IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION process_dang_keys (p_fact IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION find_missing_date_range (
      p_fact            IN   VARCHAR2,
      p_fact_id         IN   NUMBER,
      p_dim             IN   VARCHAR2,
      p_dim_id          IN   NUMBER,
      p_instance        IN   VARCHAR2,
      p_instance_link   IN   VARCHAR2
   )
      RETURN BOOLEAN;

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
      RETURN BOOLEAN;

   FUNCTION create_bad_key_tables (
      p_fact                    IN   VARCHAR2,
      p_fact_id                 IN   NUMBER,
      p_dang_dim                IN   VARCHAR2,
      p_dang_dim_id             IN   NUMBER,
      p_dang_dim_instance_id    IN   edw_owb_collection_util.numbertabletype,
      p_dang_instances          IN   edw_owb_collection_util.varchartabletype,
      p_number_dang_instances   IN   NUMBER
   )
      RETURN NUMBER;
END edw_check_data_integrity;

 

/
