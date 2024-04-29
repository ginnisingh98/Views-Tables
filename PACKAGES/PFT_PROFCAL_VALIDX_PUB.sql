--------------------------------------------------------
--  DDL for Package PFT_PROFCAL_VALIDX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PFT_PROFCAL_VALIDX_PUB" AUTHID CURRENT_USER AS
/* $Header: PFTPVIDXS.pls 120.1 2006/05/25 10:29:10 ssthiaga noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------
   g_block                CONSTANT  VARCHAR2(80) := 'FEM.PLSQL.PFT_PROFCAL_VALIDX_PUB';
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
   G_ENG_INVALID_LEDGER_ERR      CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INVALID_LEDGER_ERR';
   G_ENG_INVALID_GVSC_ERR        CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INVALID_GVSC_ERR';
   G_ENG_DS_WHERE_CLAUSE_ERR     CONSTANT  VARCHAR2(30) := 'PFT_PPROF_DS_WHERE_CLAS_ERR';
   G_PL_OP_UPD_ROWS_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_OP_UPD_ROWS_ERR';
   G_PL_IP_UPD_ROWS_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_IP_UPD_ROWS_ERR';
   G_ENG_INVALID_OBJ_DEFN_ERR    CONSTANT  VARCHAR2(30) := 'PFT_PPROF_INVALID_OBJ_DEFN_ERR';
   G_PL_UPD_EXEC_STEP_ERR        CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_UPD_EXEC_STEP_ERR';
   G_ENG_SINGLE_RULE_ERR         CONSTANT  VARCHAR2(30) := 'PFT_PPROF_SINGLE_RULE_ERR';
   G_ENG_MULTI_PROC_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_MULTI_PROC_ERR';
   G_ENG_COND_PRED_CLAUSE_ERR    CONSTANT  VARCHAR2(30) := 'PFT_PPROF_COND_PRED_CLAUSE_ERR';
   G_PL_REG_CHAIN_ERR            CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_REG_CHAIN_ERR';
   G_PL_REG_UPD_COL_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PL_REG_UPD_COL_ERR';
   G_ENG_NO_OP_ROWS_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PC_NO_OP_ROWS_ERR';
   G_ENG_RCNT_NO_FORMULA_ERR     CONSTANT  VARCHAR2(30) := 'PFT_PPROF_RCNT_NO_FORMULA_ERR';
   G_ENG_PPTILE_NO_FORMULA_ERR   CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PTILE_NO_FORMULA_ERR';
   G_ENG_PROD_NO_FORMULA_ERR     CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PROD_NO_FORMULA_ERR';
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

  TYPE product_list IS RECORD (
     product_id    NUMBER,
     account       NUMBER,
     factor_weight NUMBER
  );

  TYPE product_rec IS TABLE OF product_list INDEX BY BINARY_INTEGER;

  l_product_rec product_rec;

  TYPE NumTab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  l_customer_id      NumTab;
  l_child_id         NumTab;
  l_region_code_tab  NumTab;
  l_region_pct_tab   NumTab;

  TYPE region_cnt_list IS RECORD (
     customer_id NUMBER,
     region_code NUMBER,
     region_pct NUMBER,
     val_index NUMBER
  );

  TYPE region_cnt_rec IS TABLE OF region_cnt_list INDEX BY BINARY_INTEGER;

  l_region_cnt_cust region_cnt_rec;

 /*============================================================================+
 | Procedure
 |              Process_Request
 |
 | DESCRIPTION
 |    The procedure calculates the value index of the customer
 |    based on the region counting and profit percentile steps
 |
 | scope - public
 |
 +===========================================================================*/

   PROCEDURE Process_Single_Rule ( p_rule_obj_id             IN NUMBER
                                  ,p_cal_period_id           IN NUMBER
                                  ,p_dataset_io_obj_def_id   IN NUMBER
                                  ,p_output_dataset_code     IN NUMBER
                                  ,p_effective_date          IN VARCHAR2
                                  ,p_ledger_id               IN NUMBER
                                  ,p_source_system_code      IN NUMBER
                                  ,p_value_index_formula_id  IN NUMBER
                                  ,p_rule_obj_def_id         IN NUMBER
                                  ,p_region_counting_flag    IN VARCHAR2
                                  ,p_proft_percentile_flag   IN VARCHAR2
                                  ,p_customer_level          IN NUMBER
                                  ,p_cond_obj_id             IN NUMBER
                                  ,p_output_column           IN VARCHAR2
                                  ,p_exec_state              IN VARCHAR2
                                  ,x_return_status           OUT NOCOPY VARCHAR2
   );

   END PFT_PROFCAL_VALIDX_PUB;

 

/
