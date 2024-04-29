--------------------------------------------------------
--  DDL for Package EDW_COLLECTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_COLLECTION_UTIL" AUTHID CURRENT_USER AS
/* $Header: EDWSRCTS.pls 115.28 2003/10/13 18:12:19 vsurendr ship $  */
   version               CONSTANT VARCHAR (80)
            := '$Header: EDWSRCTS.pls 115.28 2003/10/13 18:12:19 vsurendr ship $';

-- ------------------------
-- Global Variables
-- ------------------------
   g_object_name                  VARCHAR2 (30);
   g_instance_code                VARCHAR2 (30);
   g_user_id                      PLS_INTEGER     := 0;
   g_login_id                     PLS_INTEGER     := 0;
   g_default_rate_type            VARCHAR2 (30);
   g_global_currency              VARCHAR2 (30);
   g_wh_curr_push_start_date      DATE;
   g_wh_curr_push_end_date        DATE;
   g_local_curr_push_start_date   DATE;
   g_local_curr_push_end_date     DATE;
   g_wh_last_push_end_date        DATE;
   g_local_last_push_start_date   DATE;
   g_wh_last_coll_start_date      DATE;
   g_wh_last_coll_end_date        DATE;
   g_deletion_curr_ver_date       DATE;
   g_start_time                   DATE;
   g_offset                       INTEGER         := 0;
   g_object_type                  VARCHAR2 (100);
   g_errbuf                       VARCHAR2 (2000);
   g_retcode                      VARCHAR2 (200);
   g_push_size                    PLS_INTEGER     := 0;
   g_request_id                   PLS_INTEGER;
   g_push_remote_failure          EXCEPTION;

   TYPE tbl_rectype IS RECORD (
      tbl_name                      user_tables.table_name%TYPE,
      tbl_owner                     user_users.username%TYPE,
      row_count                     PLS_INTEGER);

   TYPE tablist_type IS TABLE OF tbl_rectype
      INDEX BY BINARY_INTEGER;

   TYPE curtyp IS REF CURSOR;

   edw_dim               CONSTANT VARCHAR2 (10)   := 'DIMENSION';
   edw_fact              CONSTANT VARCHAR2 (10)   := 'FACT';


-- ------------------------
-- Public Procedures
-- ------------------------
  FUNCTION setup (p_object_name IN VARCHAR2) RETURN BOOLEAN ;
   FUNCTION setup (
      p_object_name        IN   VARCHAR2,
      p_pk_view            IN   VARCHAR2,
      p_missing_key_view   IN   VARCHAR2,
      p_transport_data     IN   BOOLEAN
   )
      RETURN BOOLEAN;

   FUNCTION setup (
      p_object_name            IN       VARCHAR2,
      p_local_staging_table    IN       VARCHAR2,
      p_remote_staging_table   IN       VARCHAR2,
      p_exception_msg          OUT NOCOPY     VARCHAR2
   )
      RETURN BOOLEAN;
   FUNCTION setup (
      p_object_name            IN       VARCHAR2,
      p_local_staging_table    IN       VARCHAR2,
      p_remote_staging_table   IN       VARCHAR2,
      p_exception_msg          OUT NOCOPY     VARCHAR2,
      p_pk_view                IN       VARCHAR2,
      p_missing_key_view       IN       VARCHAR2,
      p_transport_data         IN       BOOLEAN
   )
      RETURN BOOLEAN;
   PROCEDURE wrapup (
      p_sucessful       IN   BOOLEAN
   );
   PROCEDURE wrapup (
      p_sucessful       IN   BOOLEAN,
      p_rows_inserted   IN   NUMBER
   );
   /*
   Bug 2875426
   This API is only meant for EDW_UNSPSC_M_C
   This API DOES NOT populate the from and to dates. No collection program must
   call it!
   */
   PROCEDURE wrapup(
      p_sucessful       IN   BOOLEAN,
      p_rows_inserted   IN   NUMBER,
      p_exception_msg   IN   VARCHAR2
   );
   PROCEDURE wrapup (
      p_sucessful       IN   BOOLEAN,
      p_rows_inserted   IN   NUMBER,
      p_period_start    IN   DATE,
      p_period_end      IN   DATE
   );
   PROCEDURE wrapup (
      p_sucessful       IN   BOOLEAN,
      p_rows_inserted   IN   NUMBER,
      p_exception_msg   IN   VARCHAR2,
      p_period_start    IN   DATE,
      p_period_end      IN   DATE
   );
   FUNCTION is_instance_enabled
      RETURN BOOLEAN;

   FUNCTION source_same_as_target
      RETURN BOOLEAN;


-- FUNCTION get_level_dp(p_lookup_code in varchar2) return VARCHAR2;
-- ------------------------
-- Private Procedures
-- ------------------------

   PROCEDURE get_push_globals (p_staging_table_name IN VARCHAR2);
   PROCEDURE staging_log (
      p_no_of_records       IN   NUMBER,
      p_status              IN   VARCHAR2,
      p_exception_message   IN   VARCHAR2
   );
   PROCEDURE staging_log (
      p_no_of_records       IN   NUMBER,
      p_status              IN   VARCHAR2,
      p_exception_message   IN   VARCHAR2,
      p_period_start        IN   DATE,
      p_period_end          IN   DATE
   );

   PROCEDURE set_push_end_dates;

   FUNCTION set_wh_language
      RETURN BOOLEAN;

   FUNCTION get_wh_lookup_value (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION get_wh_language
      RETURN VARCHAR2;

   FUNCTION get_object_type (p_object IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION set_status_ready (p_tab_list IN tablist_type)
      RETURN NUMBER;

   PROCEDURE truncate_stg (p_tab_list IN tablist_type);

   FUNCTION get_lookup_value (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION get_last_push_date (p_object IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_last_push_date_logical (p_object_logical_name IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE get_dblink_names (
      x_source_link   OUT NOCOPY  VARCHAR2,
      x_target_link   OUT NOCOPY  VARCHAR2
   );

   PROCEDURE clean_up (p_tab_list IN tablist_type, suffix IN VARCHAR2);

   PROCEDURE get_stg_table_names (
      p_object_name   IN       VARCHAR2,
      tablist         OUT  NOCOPY   tablist_type
   );

   FUNCTION push_to_target
      RETURN NUMBER;

   FUNCTION get_syn_info (syn_name IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE put_timestamp;

   PROCEDURE put_debug_msg (p_message IN VARCHAR2);

   FUNCTION is_object_for_local_load (p_object_name IN VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE set_transaction_rbs (p_rbs IN VARCHAR2);
END edw_collection_util;


 

/
