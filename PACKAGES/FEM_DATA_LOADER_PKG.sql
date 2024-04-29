--------------------------------------------------------
--  DDL for Package FEM_DATA_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DATA_LOADER_PKG" AUTHID CURRENT_USER AS
/* $Header: FEMDATALEDGERLDR.pls 120.0 2006/05/23 07:30:11 kkulkarn noship $ */

  --------------------------------------------------------------------------------
                           -- Declare all global variables --
  --------------------------------------------------------------------------------

     g_log_level_1                CONSTANT  NUMBER      := fnd_log.level_statement;
     g_log_level_2                CONSTANT  NUMBER      := fnd_log.level_procedure;
     g_log_level_3                CONSTANT  NUMBER      := fnd_log.level_event;
     g_log_level_4                CONSTANT  NUMBER      := fnd_log.level_exception;
     g_log_level_5                CONSTANT  NUMBER      := fnd_log.level_error;
     g_log_level_6                CONSTANT  NUMBER      := fnd_log.level_unexpected;

     g_block     	                CONSTANT VARCHAR2(30) := 'FEM_DATA_LOADER_PKG';

     c_false                      CONSTANT  VARCHAR2(1)  := fnd_api.g_false;
     c_true                       CONSTANT  VARCHAR2(1)  := fnd_api.g_true;
     c_success                    CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_success;
     c_error                      CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_error;
     c_unexp                      CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_unexp_error;
     c_api_version                CONSTANT  NUMBER       := 1.0;

     c_data_ledger_loader         CONSTANT  VARCHAR2(20) := 'DATA_LEDGER_LOADER';
     c_dim_loader                 CONSTANT  VARCHAR2(10) := 'DIMENSIONS';
     c_hier_loader                CONSTANT  VARCHAR2(15) := 'HIERARCHIES';

     c_interval                   CONSTANT  NUMBER       := 3.0;
     c_max_wait_time              CONSTANT  NUMBER       := 1200.0;

     c_not_dupe_text              CONSTANT  VARCHAR2(20) := 'DATA_NOT_FETCHED';
     c_dupe_text                  CONSTANT  VARCHAR2(20) := 'DATA_FETCHED';

     g_approval_flag              BOOLEAN;
     g_loader_type                VARCHAR2(30);
     g_int_table_name             VARCHAR2(30);

     g_ledger_dim_id              NUMBER;
     g_cal_period_hier_attr       NUMBER;
     g_cal_period_dim_id          NUMBER;
     g_start_date_attr            NUMBER;
     g_end_date_attr              NUMBER;
     g_dataset_dim_id             NUMBER;
     g_dataset_bal_attr           NUMBER;
     g_production_attr            NUMBER;
     g_budget_dim_id              NUMBER;

     --g_start_date                 DATE;
     --g_end_date                   DATE;

     g_start_date                 VARCHAR2(35);
     g_end_date                   VARCHAR2(35);

     g_hier_object_def_id         NUMBER;
     g_hierarchy_exists           BOOLEAN;
     g_evaluate_parameters        BOOLEAN;

  --------------------------------------------------------------------------------
                           -- Declare all pl/sql collections --
  --------------------------------------------------------------------------------


     TYPE interface_data_rec IS RECORD
     (ledger                            NUMBER,
      dataset                           NUMBER,
      budget_display_code               VARCHAR2(30),
      encumbrance_type_code             VARCHAR2(30),
      source_system                     NUMBER,
      cal_period_number                 NUMBER,
      cal_period_level                  NUMBER,
      cal_period_end_date               DATE,
      table_name                        VARCHAR2(30),
      table_row                         NUMBER
      );

     TYPE interface_data_tab IS TABLE OF interface_data_rec INDEX BY BINARY_INTEGER;

     TYPE cal_period_rec IS RECORD
     (ledger_id                         NUMBER,
      cal_period_id                     NUMBER,
      dim_grp_id                        NUMBER,
      status                            VARCHAR2(10),
      valid                             VARCHAR2(10)
     );

     TYPE cal_period_tab IS TABLE OF cal_period_rec INDEX BY BINARY_INTEGER;

     TYPE master_rec IS RECORD
     (ledger_id                         NUMBER,
      dataset_code                      NUMBER,
      cal_period_id                     NUMBER,
      source_system_code                NUMBER,
      ledger_display_code               VARCHAR2(150),
      dataset_display_code              VARCHAR2(150),
      source_system_display_code        VARCHAR2(150),
      budget_id                         NUMBER,
      budget_display_code               VARCHAR2(150),
      enc_type_id                       NUMBER,
      enc_type_code                     VARCHAR2(150),
      table_name                        VARCHAR2(30),
      table_row                         NUMBER,
      request_id                        NUMBER,
      status                            VARCHAR2(1)
     );

     TYPE master_rec_tab IS TABLE OF master_rec INDEX BY BINARY_INTEGER;

     TYPE number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     TYPE char_table IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
     TYPE date_table IS TABLE OF DATE INDEX BY BINARY_INTEGER;
     TYPE sql_stmt_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

  --------------------------------------------------------------------------------
                         -- Declare all Public procedures/functions --
  --------------------------------------------------------------------------------


     PROCEDURE process_request(errbuf OUT NOCOPY VARCHAR2,
                               retcode OUT NOCOPY VARCHAR2,
                               p_obj_def_id IN NUMBER,
                               p_start_date IN VARCHAR2,
                               p_end_date IN VARCHAR2,
                               p_balance_type IN VARCHAR2);

     PROCEDURE trace(p_trace_what IN VARCHAR2);


END Fem_Data_Loader_Pkg;
 

/
