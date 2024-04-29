--------------------------------------------------------
--  DDL for Package DDR_ETL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_ETL_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ddruetls.pls 120.1.12010000.4 2010/03/03 04:08:55 vbhave ship $ */

  FUNCTION get_mv_refresh_job_id RETURN VARCHAR2;

  PROCEDURE refresh_mv (
        p_list                 IN VARCHAR2,
        p_method               IN VARCHAR2 DEFAULT NULL,
        p_rollback_seg         IN VARCHAR2 DEFAULT NULL,
        p_push_deferred_rpc    IN BOOLEAN  DEFAULT TRUE,
        p_refresh_after_errors IN BOOLEAN  DEFAULT FALSE,
        p_purge_option         IN BINARY_INTEGER DEFAULT 1,
        p_parallelism          IN BINARY_INTEGER DEFAULT 0,
        p_heap_size            IN BINARY_INTEGER DEFAULT 0,
        p_atomic_refresh       IN BOOLEAN  DEFAULT TRUE,
        p_job_id               IN VARCHAR2 DEFAULT NULL,
        p_refreshed_by         IN VARCHAR2 DEFAULT NULL,
        x_out                  OUT NOCOPY VARCHAR2,
        x_message              OUT NOCOPY VARCHAR2
  );

  PROCEDURE truncate_mv_log(
        p_mv_log_name          IN VARCHAR2,
        p_job_id               IN VARCHAR2 DEFAULT NULL,
        p_refreshed_by         IN VARCHAR2 DEFAULT NULL,
        x_out                  OUT NOCOPY VARCHAR2,
        x_message              OUT NOCOPY VARCHAR2
  );

  PROCEDURE Export_Error (
        p_table_name          IN VARCHAR2,
        p_load_id             IN NUMBER   DEFAULT NULL,
        p_file_name           IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE Import_Error (
        p_table_name          IN VARCHAR2,
        p_file_name           IN VARCHAR2  DEFAULT NULL
  );

  PROCEDURE Import_Error (
        p_table_name          IN VARCHAR2,
        p_file_name           IN VARCHAR2  DEFAULT NULL,
        p_err_table_name      IN VARCHAR2,
        p_load_id             IN NUMBER    DEFAULT NULL,
        p_tgt_table_type      IN VARCHAR2  DEFAULT 'I'
  );

  PROCEDURE Transfer_Data (
        p_src_table_name      IN VARCHAR2,
        p_tgt_table_name      IN VARCHAR2,
        p_load_id             IN NUMBER    DEFAULT NULL,
        p_tgt_table_type      IN VARCHAR2  DEFAULT 'I'
  );

  PROCEDURE Export_Data (
        p_table_name          IN VARCHAR2,
        p_where_clause        IN VARCHAR2  DEFAULT NULL,
        p_file_name           IN VARCHAR2  DEFAULT NULL
  );

  PROCEDURE Import_Data (
        p_table_name          IN VARCHAR2,
        p_file_name           IN VARCHAR2  DEFAULT NULL
  );

  TYPE string_tab IS TABLE OF VARCHAR2(1000)
  INDEX BY BINARY_INTEGER;

  TYPE integer_tab IS TABLE OF PLS_INTEGER
  INDEX BY BINARY_INTEGER;

  TYPE string_index_by_char_tab IS TABLE OF VARCHAR2(50)
  INDEX BY VARCHAR2(50);

END ddr_etl_util_pkg;

/
