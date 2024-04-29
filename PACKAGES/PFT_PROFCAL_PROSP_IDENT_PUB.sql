--------------------------------------------------------
--  DDL for Package PFT_PROFCAL_PROSP_IDENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PFT_PROFCAL_PROSP_IDENT_PUB" AUTHID CURRENT_USER AS
/* $Header: PFTPIDNTS.pls 120.1 2006/05/25 10:34:47 ssthiaga noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------
   g_block                CONSTANT  VARCHAR2(80) := 'FEM.PLSQL.PFT_PROFCAL_PROSP_IDENT_PUB';
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
   G_ENG_NO_OP_ROWS_ERR          CONSTANT  VARCHAR2(30) := 'PFT_PPROF_PC_NO_OP_ROWS_ERR';
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

 /*============================================================================+
 | Procedure
 |              Process_Request
 |
 | DESCRIPTION
 |   The Procedure Performs The Prospect Identification Process of the Profit
 | Calculation Step
 |
 | scope - public
 |
 +===========================================================================*/

   PROCEDURE Process_Single_Rule ( p_rule_obj_id            IN NUMBER
                                  ,p_cal_period_id          IN NUMBER
                                  ,p_dataset_io_obj_def_id  IN NUMBER
                                  ,p_output_dataset_code    IN NUMBER
                                  ,p_effective_date         IN VARCHAR2
                                  ,p_ledger_id              IN NUMBER
                                  ,p_source_system_code     IN NUMBER
                                  ,p_exec_state             IN VARCHAR2
                                  ,x_return_status          OUT NOCOPY VARCHAR2
   );

   END PFT_PROFCAL_PROSP_IDENT_PUB;

 

/
