--------------------------------------------------------
--  DDL for Package EDW_WH_DANG_RECOVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_WH_DANG_RECOVERY" AUTHID CURRENT_USER AS
/*$Header: EDWWHDRS.pls 115.6 2002/12/05 23:18:11 sbuenits noship $*/
   version               CONSTANT VARCHAR (80)
            := '$Header: EDWWHDRS.pls 115.6 2002/12/05 23:18:11 sbuenits noship $';

   g_status                  BOOLEAN;
   g_status_varchar          VARCHAR2 (40);
   g_status_message          VARCHAR2 (4000);
   g_debug                   BOOLEAN;
   g_fact_list               edw_owb_collection_util.varchartabletype;
   g_number_fact_list        PLS_INTEGER;
   g_fact                    VARCHAR2 (400);
   g_dim_list                edw_owb_collection_util.varchartabletype;
   g_dim_id_list             edw_owb_collection_util.numbertabletype;
   g_number_dim_list         PLS_INTEGER;
   g_fstg_name               VARCHAR2 (400);
   g_fstg_op_table           VARCHAR2 (400);
   g_fstg_id                 PLS_INTEGER;
   g_fstg_pk                 VARCHAR2 (400);
   g_fact_id                 PLS_INTEGER;
   g_fstg_fk                 edw_owb_collection_util.varchartabletype;
   g_fstg_fk_id              edw_owb_collection_util.numbertabletype;
   g_number_fstg_fk          PLS_INTEGER;
   g_fstg_all_fk             edw_owb_collection_util.varchartabletype;
   g_number_fstg_all_fk      PLS_INTEGER;
   g_fstg_cols               edw_owb_collection_util.varchartabletype;
   g_number_fstg_cols        PLS_INTEGER;
   g_fk_dim                  edw_owb_collection_util.varchartabletype;
   g_bad_key_tables          edw_owb_collection_util.varchartabletype;
   g_bad_fk_tables           edw_owb_collection_util.varchartabletype; --for each fk
   g_instance                VARCHAR2 (400);
   g_fstg_error_table        VARCHAR2 (400);
   g_fstg_error_table_flag   BOOLEAN;
   g_mode                    VARCHAR2 (200);
   g_called_from             VARCHAR2 (200);
   g_fk_table                VARCHAR2 (200);
   g_op_fstg_table_empty     BOOLEAN;
   g_instance_col            VARCHAR2 (200);

-----------profiles-------------
   g_parallel                PLS_INTEGER;
   g_op_tablespace           VARCHAR2 (400);
   g_bis_owner               VARCHAR2 (400);
   g_inc_mode                BOOLEAN;


--------------------------------


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
   );

   FUNCTION load_error_table
      RETURN BOOLEAN;

   FUNCTION parse_facts_dims (p_fact_list IN VARCHAR2, p_dim_list IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION read_metadata (p_fact IN VARCHAR2, p_mode IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION generate_op_fstg_table (p_fact IN VARCHAR2, p_mode IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_dim_ids
      RETURN BOOLEAN;

   FUNCTION find_bad_fk_records (p_fstg IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_time
      RETURN VARCHAR2;

   PROCEDURE write_to_log_file (p_message IN VARCHAR2);

   PROCEDURE write_to_log_file_n (p_message IN VARCHAR2);

   PROCEDURE init_all;

   FUNCTION create_bad_fk_tables (
      p_bad_table   IN   VARCHAR2,
      p_dimension   IN   VARCHAR2
   )
      RETURN BOOLEAN;

   FUNCTION load_fstg_error_table
      RETURN BOOLEAN;

   FUNCTION create_fstg_error_table (p_mode IN VARCHAR2, p_table IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_g_status_varchar
      RETURN VARCHAR2;

   FUNCTION merge_bad_fk_tables (p_merge_table OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN;
END edw_wh_dang_recovery;

 

/
