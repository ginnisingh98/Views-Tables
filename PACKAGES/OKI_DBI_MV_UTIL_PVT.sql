--------------------------------------------------------
--  DDL for Package OKI_DBI_MV_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_MV_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRIMUS.pls 115.5 2003/04/18 18:47:18 mezra noship $ */

  procedure drop_mv_log
  (   p_mv_log IN VARCHAR2
  ) ;

  procedure create_mv_log
  (   p_base_table IN VARCHAR2
   ,  p_column_list IN VARCHAR2
   ,  p_sequence_flag IN VARCHAR2
   ,  p_rowid IN VARCHAR2
   ,  p_new_values IN VARCHAR2
   ,  p_data_tablespace IN VARCHAR2
   ,  p_index_tablespace IN VARCHAR2
   ,  p_next_extent IN VARCHAR2
  ) ;

  procedure drop_mv
  (   p_mv IN VARCHAR2
  ) ;

  procedure create_mv
  (   p_mv_name IN VARCHAR2
   ,  p_mv_sql IN VARCHAR2
   ,  p_build_mode IN VARCHAR2  -- D = DEFERRED, I = IMMEDIATE
   ,  p_refresh_mode IN VARCHAR2  -- F = FAST , C = COMPLETE
   ,  p_enable_qrewrite IN VARCHAR2
   ,  p_partition_flag IN VARCHAR2
   ,  p_next_extent IN VARCHAR2
  ) ;

  procedure create_mv_index
  (   p_mv_name IN VARCHAR2
   ,  p_ind_name IN VARCHAR2
   ,  p_ind_col_list IN VARCHAR2
   ,  p_unique_flag IN VARCHAR2
   ,  p_ind_type IN VARCHAR2  -- B = BTree , M = BitMap
   ,  p_next_extent IN VARCHAR2
   ,  p_partition_type IN VARCHAR2
  ) ;

  PROCEDURE drop_index
  (   p_index_name IN VARCHAR2
  ) ;

  PROCEDURE refresh
  (  p_mv_name         IN  VARCHAR2
   , p_parallel_degree IN  NUMBER

  ) ;

  PROCEDURE crt_mx
  (  p_id       IN NUMBER
   , p_user_id  IN NUMBER
   , p_run_date IN DATE
   , p_login_id IN NUMBER
  ) ;

END oki_dbi_mv_util_pvt ;

 

/
