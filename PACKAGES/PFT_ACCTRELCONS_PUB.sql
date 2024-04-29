--------------------------------------------------------
--  DDL for Package PFT_ACCTRELCONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PFT_ACCTRELCONS_PUB" AUTHID CURRENT_USER AS
/* $Header: pftparcs.pls 120.4 2006/05/25 09:23:43 ssthiaga noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------
   g_block                CONSTANT  VARCHAR2(80) := 'FEM.PLSQL.PFT_ACCTRELCONS_PUB';
   g_pft                  CONSTANT  VARCHAR2(3)  := 'PFT';
   g_fem                  CONSTANT  VARCHAR2(3)  := 'FEM';
   g_calling_api_version  CONSTANT  NUMBER       :=  1.0;
   g_complete_normal      CONSTANT  VARCHAR2(30) := 'COMPLETE:NORMAL';

   g_false        CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
   g_true         CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
   g_success      CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
   g_error        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
   g_unexp        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
   g_api_version  CONSTANT  NUMBER       := 1.0;

--------Message Constants--------------

   G_ENG_ENGINE_POST_PROC_ERR    CONSTANT  VARCHAR2(30) := 'PFT_PPROF_ENGINE_POST_PROC_ERR';
   G_ENG_INVALIDRULETYPE_ERR     CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INVALID_RULETYPE_ERR';
   G_ENG_INVALID_OBJ_ERR         CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INVALID_OBJ_ERR';
   G_ENG_NO_OUTPUT_DS_ERR        CONSTANT  VARCHAR2(30) := 'PFT_PPROF_NO_OUTPUT_DS_ERR';
   G_ENG_INVALID_OBJ_DEFN_ERR    CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INVALID_OBJ_DEFN_ERR';
   G_ENG_INV_OBJ_DEFN_RS_ERR     CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INV_OBJ_DEFN_RS_ERR';
   G_PL_REG_REQUEST_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_REG_REQUEST_ERR';
   G_PL_OBJ_EXEC_LOCK_ERR        CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_REG_OBJ_EXEC_ERR';
   G_PL_OBJ_EXECLOCK_EXISTS_ERR  CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_EXE_LCK_EXIST_ERR';
   G_PL_DEP_OBJ_DEF_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_DEP_OBJ_DEF_ERR';
   G_PL_REG_TABLE_ERR            CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_REG_TABLE_ERR';
   G_ENG_COL_POP_API_ERR         CONSTANT  VARCHAR2(30) := 'PFT_PPROF_COL_POP_API_ERR';
   G_ENG_MULTI_PROC_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_MULTI_PROC_ERR';
   G_PL_OP_UPD_ROWS_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_OP_UPD_ROWS_ERR';
   G_PL_IP_UPD_ROWS_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_IP_UPD_ROWS_ERR';
   G_ENG_SINGLE_RULE_ERR         CONSTANT  VARCHAR2(30) := 'PFT_PPROF_SINGLE_RULE_ERR';
   G_ENG_PRE_PROC_RS_ERR         CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PRE_PROC_RS_ERR';
   G_PL_REG_EXEC_STEP_ERR        CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_REG_EXEC_STEP_ERR';
   G_PL_UPD_EXEC_STEP_ERR        CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_UPD_EXEC_STEP_ERR';
   G_PL_REG_UPD_COL_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_REG_UPD_COL_ERR';
   G_ENG_INVALID_LEDGER_ERR      CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INVALID_LEDGER_ERR';
   G_ENG_INVALID_GVSC_ERR        CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INVALID_GVSC_ERR';
   G_PL_REG_CHAIN_ERR            CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_REG_CHAIN_ERR';
   G_ENG_NO_OP_ROWS_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_ARC_NO_OP_ROWS_ERR';
   G_ENG_BAD_CONC_REQ_PARAM_ERR  CONSTANT  VARCHAR2(30) := 'FEM_ENG_BAD_CONC_REQ_PARAM_ERR';
   G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(30) := 'FEM_UNEXPECTED_ERROR';
   G_ENG_GENERIC_5_ERR           CONSTANT  VARCHAR2(30) := 'PFT_PPROF_GENERIC_ENGINE_5_ERR';
   G_ENG_COL_POP_GEN_ARC_AGG_ERR CONSTANT  VARCHAR2(30) := 'PFT_PPROF_GEN_CPOP_ARC_AGG_ERR';
   G_ENG_SEC_NO_OP_ROWS_ERR      CONSTANT  VARCHAR2(30) := 'PFT_PPROF_SEC_NO_OP_ROWS_ERR';

--------------------------------------------
--  Variable Types
---------------------------------------------
   id                              NUMBER(9);
   pct                             NUMBER(3,2);
   flag                            VARCHAR2(1);
   currency_code                   VARCHAR2(15);
   varchar2_std                    VARCHAR2(30);
   varchar2_150                    VARCHAR2(150);
   varchar2_240                    VARCHAR2(240);
   varchar2_1000                   VARCHAR2(1000);
   varchar2_10000                  VARCHAR2(10000);

---------------------------------------------
--  Package Types
---------------------------------------------

   TYPE cv_curs                IS REF CURSOR;
   TYPE rowid_tbl_type         IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
   TYPE number_tbl_type        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE date_tbl_type          IS TABLE OF DATE INDEX BY BINARY_INTEGER;
   TYPE flag_type              IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
   TYPE varchar2_std_tbl_type  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE varchar2_150_tbl_type  IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
   TYPE varchar2_1000_tbl_type IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

   TYPE dimension_record IS RECORD (
              dimension_id                  NUMBER
              ,dimension_varchar_label      varchar2_std%TYPE
              ,composite_dimension_flag     flag%TYPE
              ,member_col                   varchar2_std%TYPE
              ,member_b_table               varchar2_std%TYPE
              ,attr_table                   varchar2_std%TYPE
              ,hier_table                   varchar2_std%TYPE
              ,hier_rollup_table            varchar2_std%TYPE
              ,hier_versioning_type_code    varchar2_std%TYPE);

   TYPE param_record IS RECORD (
               cond_obj_id                  id%TYPE
              ,dataset_io_obj_def_id        id%TYPE
              ,dataset_grp_obj_id           id%TYPE
              ,dataset_grp_name             varchar2_240%TYPE
              ,effective_date               DATE
              ,effective_date_varchar       varchar2_240%TYPE
              ,continue_process_on_err_flg  varchar2_std%TYPE
              ,source_system_code           NUMBER
              ,ledger_id                    NUMBER
              ,local_vs_combo_id            id%TYPE
              ,login_id                     NUMBER
              ,output_cal_period_id         NUMBER
              ,output_dataset_code          NUMBER
              ,input_dataset_code           NUMBER
              ,pgm_app_id                   NUMBER
              ,pgm_id                       NUMBER
              ,resp_id                      NUMBER
              ,request_id                   NUMBER
              ,obj_id                       NUMBER
              ,obj_type_code                varchar2_std%TYPE
              ,object_name                  varchar2_150%TYPE
              ,crnt_proc_child_obj_id       NUMBER
              ,crnt_proc_child_obj_defn_id  NUMBER
              ,user_id                      NUMBER
              ,return_status                varchar2_std%TYPE
              ,sec_relns_flag               VARCHAR2(1)
              ,rows_processed               NUMBER
              ,rows_loaded                  NUMBER
              ,rows_rejected                NUMBER);

  /*===========================================================================+
 | PROCEDURE
 |          Process_Request
 |
 | DESCRIPTION
 |          The procedure combines the customer account data with the account
 |          relationship data by placing the results in pft_party_profit_detail
 |          table
 |
 | SCOPE - PUBLIC
 |
 +===========================================================================*/

   PROCEDURE Process_Request (Errbuf                        OUT NOCOPY VARCHAR2,
                              Retcode                       OUT NOCOPY NUMBER,
                              p_obj_id                      IN  NUMBER,
                              p_effective_date              IN  VARCHAR2,
                              p_ledger_id                   IN  NUMBER,
                              p_output_cal_period_id        IN  NUMBER,
                              p_dataset_grp_obj_def_id      IN  NUMBER,
                              p_continue_process_on_err_flg IN  VARCHAR2,
                              p_source_system_code          IN  NUMBER);


END PFT_AcctRelCons_PUB;

 

/
