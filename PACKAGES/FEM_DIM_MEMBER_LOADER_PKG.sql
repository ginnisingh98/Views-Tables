--------------------------------------------------------
--  DDL for Package FEM_DIM_MEMBER_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_MEMBER_LOADER_PKG" AUTHID CURRENT_USER AS
--$Header: femdimldr_pkh.pls 120.5 2006/08/04 21:12:26 rflippo noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    femdimldr_pkh.pls
 |
 | NAME fem_dim_member_loader_pkg
 |
 | DESCRIPTION
 |
 |   Package Spec for fem_dim_member_loader_pkg. This package is the engine for
 |   loading dimension members, member translatable names/descriptions,
 |   and member attribute assignments from interface tables into the FEM
 |   database.
 |
 | NOTES
 |
 |
 | HISTORY
 |
 |    20-OCT-03  RFlippo Created
 |    31-MAR-04  RFlippo Added new exceptions for Error Reprocessing
 |    06-MAY-04  RFlippo Exposed sub-processes to the public spec for MP
 |    21-SEP-04  RFlippo Bug#3900960 Insufficient messaging for snapshot
 |                       load with 0 rows
 |    28-Sep-04  RFlippo Bug#3906218 NEED ABILITY TO UNDELETE DIMENSIONS
 |                       modified the Base_Update procedure signature
 |    22-Nov-04  RFlippo Bug#4019853 Date Overlap logic - added pragma exception
 |    14-DEC-04  RFlippo Bug#4061097 Get ORA-1722 when try to load budget member
 |                       Bug#3654256 Change loader to use dimension_id as in parm
 |                       so that the list comes from Xdim metadata.
 |    18-MAR-05  RFlippo Bug#4244082 Modify base_update signature to
 |                       accomodate the update of the dimgrp for a member
 |    28-APR-05  sshanmug Added support for Composite dimension Loader
 |    26-MAY-05  RFlippo Bug#4107370 Added new message for folder security
 |                       violation
 |    31-MAY-05  RFlippo Bug#3923485 removed date_format_mask parm from Main
 |                       since now using ICX: Date Format Mask profile option
 |    13-JUN-05  RFlippo Bug#3895203 lvl specific attributes required new
 |                       parm in pre_validation_attr
 |    24-JAN-06  RFlippo Bug#4927869 Added new message for G_INVALID_DATE_MASK
 |    28-APR-06  RFlippo Bug#5174039 Added new exception
 |                       e_invalid_calp_start_date
 |    04-AUG-06  RFlippo Bug 5060746 Modify signatures to use bind variables
 |                       push MP methodology
 +=========================================================================*/

---------------------------------------------
--  Package Constants
---------------------------------------------
   c_block  CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_dim_member_loader_pkg';
   c_fem    CONSTANT  VARCHAR2(3)  := 'FEM';
   c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;
   c_object_version_number CONSTANT NUMBER := 1;
   c_enabled_flag   VARCHAR2(1) := 'Y';
   c_personal_flag  VARCHAR2(1) := 'N';
   c_read_only_flag VARCHAR2(1) := 'Y';

   c_false        CONSTANT  VARCHAR2(1)      := FND_API.G_FALSE;
   c_true         CONSTANT  VARCHAR2(1)      := FND_API.G_TRUE;
   c_success      CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_SUCCESS;
   c_error        CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_ERROR;
   c_unexp        CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_UNEXP_ERROR;
   c_api_version  CONSTANT  NUMBER           := 1.0;
   c_fetch_limit  CONSTANT  NUMBER           := 99999;



---------Message Constants--------------
G_INVALID_DATE_MASK VARCHAR2(30) := 'FEM_DIM_MBR_LDR_DATE_MASK';
G_DIM_NOT_FOUND VARCHAR2(30)      := 'FEM_DIM_NOT_FOUND';
G_INVALID_SIMPLE_DIM VARCHAR2(30)   := 'FEM_DIM_LOADS_NOT_ALLOWED';
G_INVALID_DATE_FORMAT VARCHAR2(30)    := 'FEM_INVALID_DATE_FORMAT';
G_INVALID_EXEC_MODE VARCHAR2(30)      := 'FEM_DIM_MEMBER_LDR_EXEC_MODE';
G_EXEC_LOCK_EXISTS VARCHAR2(30)       := 'FEM_PL_OBJ_EXECLOCK_EXISTS_ERR';
G_INVALID_OBJ_DEF VARCHAR2(30)        := 'FEM_DATAX_LDR_BAD_OBJ_ERR';
G_EXT_LDR_POST_PROC_ERR VARCHAR2(30)  := 'FEM_EXT_LDR_POST_PROC_ERR';
G_EXT_LDR_EXEC_STATUS   VARCHAR2(30)  := 'FEM_EXT_LDR_EXEC_STATUS';
G_PL_REG_REQUEST_ERR VARCHAR2(30)     := 'FEM_PL_REG_REQUEST_ERR';
G_PL_OBJ_EXEC_LOCK_ERR VARCHAR2(30)  := 'FEM_PL_OBJ_EXEC_LOCK_ERR';
G_MULT_DEFAULT_VERSION VARCHAR2(30)  := 'FEM_TOO_MANY_DEFAULT_VERSIONS';
G_NO_ROWS_TO_LOAD VARCHAR2(30)       := 'FEM_DIM_MBR_LDR_NO_ROWS_LOAD';
G_NO_STRUCTURE_DEFINED VARCHAR2(30)  := 'FEM_DIM_NO_STRUCTURE_DEFINED';
G_NO_FOLDER_PRIVS VARCHAR2(30)       := 'FEM_DIM_MBR_LDR_FOLDER_PRIV';

---------------------------------------
------------------------
-- Declare Exceptions --
------------------------
   e_dimension_not_found       EXCEPTION;
   e_dim_load_not_enabled      EXCEPTION;
   e_invalid_simple_dim        EXCEPTION;
   e_invalid_number                 EXCEPTION;
   e_invalid_number1722             EXCEPTION;
   e_invalid_date                   EXCEPTION;
   e_invalid_date_numeric           EXCEPTION;
   e_invalid_date_format            EXCEPTION;
   e_invalid_date_result            EXCEPTION;
   e_invalid_date_mask              EXCEPTION;
   e_invalid_date_between              EXCEPTION;
   e_invalid_date_year              EXCEPTION;
   e_invalid_date_day              EXCEPTION;
   e_invalid_date_month            EXCEPTION;
   e_date_string_too_long           EXCEPTION;
   e_invalid_calp_start_date        EXCEPTION;
   e_invalid_cal_period_end_date    EXCEPTION;
   e_invalid_cal_period_number      EXCEPTION;
   e_invalid_acct_year              EXCEPTION;
   e_terminate                      EXCEPTION;
   e_main_terminate                 EXCEPTION;
   e_mult_default_version           EXCEPTION;
   e_invalid_exec_mode         EXCEPTION;
   e_exec_lock_exists          EXCEPTION;
   e_unable_to_register_req    EXCEPTION;
   e_invalid_obj_def           EXCEPTION;
   e_pl_registration_failed    EXCEPTION;
   e_no_rows_to_load           EXCEPTION;
   e_no_structure_defined      EXCEPTION;
   e_no_folder_privs           EXCEPTION;

   PRAGMA EXCEPTION_INIT(e_invalid_number, -6502);
   PRAGMA EXCEPTION_INIT(e_invalid_number1722, -1722);
   PRAGMA EXCEPTION_INIT(e_invalid_date, -1843);
   PRAGMA EXCEPTION_INIT(e_invalid_date_result, -1821);
   PRAGMA EXCEPTION_INIT(e_date_string_too_long, -1830);
   PRAGMA EXCEPTION_INIT(e_invalid_date_numeric, -1858);
   PRAGMA EXCEPTION_INIT(e_invalid_date_between, -1841);
   PRAGMA EXCEPTION_INIT(e_invalid_date_year, -1847);
   PRAGMA EXCEPTION_INIT(e_invalid_date_format, -1861);
   PRAGMA EXCEPTION_INIT(e_invalid_date_month, -1816);
   PRAGMA EXCEPTION_INIT(e_invalid_date_day, -1839);

---------------------------------------

---------------------------------------------
--  Package Types
---------------------------------------------
TYPE cv_curs IS REF CURSOR;
TYPE rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE number_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE varchar2_std_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE varchar2_150_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE desc_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
TYPE flag_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE lang_type IS TABLE OF VARCHAR2(4) INDEX BY BINARY_INTEGER;
TYPE varchar2_1000_type IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;



PROCEDURE Main (
   errbuf                       OUT NOCOPY     VARCHAR2
  ,retcode                      OUT NOCOPY     VARCHAR2
  ,p_execution_mode             IN       VARCHAR2
  ,p_dimension_id            IN       NUMBER
);

PROCEDURE Pre_Validation (p_eng_sql IN VARCHAR2
                         ,p_data_slc IN VARCHAR2
                         ,p_proc_num IN NUMBER
                         ,p_partition_code           IN  NUMBER
                         ,p_fetch_limit IN NUMBER
                         ,p_load_type IN VARCHAR2
                         ,p_dimension_varchar_label IN VARCHAR2
                         ,p_dimension_id IN NUMBER
                         ,p_source_b_table IN VARCHAR2
                         ,p_source_tl_table IN VARCHAR2
                         ,p_source_attr_table IN VARCHAR2
                         ,p_target_b_table IN VARCHAR2
                         ,p_member_t_dc_col IN VARCHAR2
                         ,p_member_dc_col IN VARCHAR2
                         ,p_value_set_required_flag IN VARCHAR2
                         ,p_simple_dimension_flag IN VARCHAR2
                         ,p_shared_dimension_flag IN VARCHAR2
                         ,p_exec_mode_clause IN VARCHAR2
                         ,p_master_request_id IN NUMBER);

PROCEDURE Pre_Validation_Attr (p_eng_sql IN VARCHAR2
                         ,p_data_slc IN VARCHAR2
                         ,p_proc_num IN VARCHAR2
                         ,p_partition_code IN NUMBER
                         ,p_fetch_limit IN NUMBER
                         ,p_load_type IN VARCHAR2
                         ,p_dimension_varchar_label IN VARCHAR2
                         ,p_dimension_id IN NUMBER
                         ,p_source_b_table IN VARCHAR2
                         ,p_source_tl_table IN VARCHAR2
                         ,p_source_attr_table IN VARCHAR2
                         ,p_target_b_table IN VARCHAR2
                         ,p_member_t_dc_col IN VARCHAR2
                         ,p_member_dc_col IN VARCHAR2
                         ,p_value_set_required_flag IN VARCHAR2
                         ,p_simple_dimension_flag IN VARCHAR2
                         ,p_shared_dimension_flag IN VARCHAR2
                         ,p_hier_dimension_flag IN VARCHAR2
                         ,p_exec_mode_clause IN VARCHAR2
                         ,p_master_request_id IN NUMBER);


PROCEDURE New_Members (p_eng_sql IN VARCHAR2
                      ,p_data_slc IN VARCHAR2
                      ,p_proc_num IN VARCHAR2
                      ,p_partition_code IN NUMBER
                      ,p_fetch_limit IN NUMBER
                      ,p_load_type IN VARCHAR2
                      ,p_dimension_varchar_label IN VARCHAR2
                      ,p_date_format_mask IN VARCHAR2
                      ,p_dimension_id IN VARCHAR2
                      ,p_target_b_table IN VARCHAR2
                      ,p_target_tl_table IN VARCHAR2
                      ,p_target_attr_table IN VARCHAR2
                      ,p_source_b_table IN VARCHAR2
                      ,p_source_tl_table IN VARCHAR2
                      ,p_source_attr_table IN VARCHAR2
                      ,p_table_handler_name IN VARCHAR2
                      ,p_member_col IN VARCHAR2
                      ,p_member_dc_col IN VARCHAR2
                      ,p_member_name_col IN VARCHAR2
                      ,p_member_t_dc_col IN VARCHAR2
                      ,p_member_t_name_col IN VARCHAR2
                      ,p_member_description_col IN VARCHAR2
                      ,p_value_set_required_flag IN VARCHAR2
                      ,p_simple_dimension_flag IN VARCHAR2
                      ,p_shared_dimension_flag IN VARCHAR2
                      ,p_hier_dimension_flag IN VARCHAR2
                      ,p_member_id_method_code IN VARCHAR2
                      ,p_exec_mode_clause IN VARCHAR2
                      ,p_master_request_id IN NUMBER);

PROCEDURE TL_Update (p_eng_sql IN VARCHAR2
                    ,p_data_slc IN VARCHAR2
                    ,p_proc_num IN VARCHAR2
                    ,p_partition_code IN NUMBER
                    ,p_fetch_limit IN NUMBER
                    ,p_load_type IN VARCHAR2
                    ,p_dimension_varchar_label IN VARCHAR2
                    ,p_dimension_id IN VARCHAR2
                    ,p_target_b_table IN VARCHAR2
                    ,p_target_tl_table IN VARCHAR2
                    ,p_source_b_table IN VARCHAR2
                    ,p_source_tl_table IN VARCHAR2
                    ,p_member_col IN VARCHAR2
                    ,p_member_dc_col IN VARCHAR2
                    ,p_member_name_col IN VARCHAR2
                    ,p_member_t_dc_col IN VARCHAR2
                    ,p_member_t_name_col IN VARCHAR2
                    ,p_member_description_col IN VARCHAR2
                    ,p_value_set_required_flag IN VARCHAR2
                    ,p_simple_dimension_flag IN VARCHAR2
                    ,p_shared_dimension_flag IN VARCHAR2
                    ,p_hier_dimension_flag IN VARCHAR2
                    ,p_exec_mode_clause IN VARCHAR2
                    ,p_master_request_id IN NUMBER);

PROCEDURE Base_Update (p_eng_sql IN VARCHAR2
                      ,p_data_slc IN VARCHAR2
                      ,p_proc_num IN VARCHAR2
                      ,p_partition_code IN NUMBER
                      ,p_fetch_limit IN NUMBER
                      ,p_load_type IN VARCHAR2
                      ,p_dimension_varchar_label IN VARCHAR2
                      ,p_simple_dimension_flag IN VARCHAR2
                      ,p_shared_dimension_flag IN VARCHAR2
                      ,p_dimension_id IN NUMBER
                      ,p_value_set_required_flag IN VARCHAR2
                      ,p_hier_table_name IN VARCHAR2
                      ,p_hier_dimension_flag IN VARCHAR2
                      ,p_source_b_table IN VARCHAR2
                      ,p_target_b_table IN VARCHAR2
                      ,p_member_dc_col IN VARCHAR2
                      ,p_member_t_dc_col IN VARCHAR2
                      ,p_member_col IN VARCHAR2
                      ,p_exec_mode_clause IN VARCHAR2
                      ,p_master_request_id IN NUMBER);

PROCEDURE Attr_Assign_Update (p_eng_sql IN VARCHAR2
                             ,p_data_slc IN VARCHAR2
                             ,p_proc_num IN VARCHAR2
                             ,p_partition_code IN NUMBER
                             ,p_fetch_limit IN NUMBER
                             ,p_dimension_varchar_label IN VARCHAR2
                             ,p_date_format_mask IN VARCHAR2
                             ,p_dimension_id IN VARCHAR2
                             ,p_target_b_table IN VARCHAR2
                             ,p_target_attr_table IN VARCHAR2
                             ,p_source_b_table IN VARCHAR2
                             ,p_source_attr_table IN VARCHAR2
                             ,p_member_col IN VARCHAR2
                             ,p_member_dc_col IN VARCHAR2
                             ,p_member_t_dc_col IN VARCHAR2
                             ,p_value_set_required_flag IN VARCHAR2
                             ,p_hier_dimension_flag IN VARCHAR2
                             ,p_simple_dimension_flag IN VARCHAR2
                             ,p_shared_dimension_flag IN VARCHAR2
                             ,p_exec_mode_clause IN VARCHAR2
                             ,p_master_request_id IN NUMBER);


PROCEDURE Post_Cal_Periods (p_eng_sql IN VARCHAR2
                           ,p_data_slc IN VARCHAR2
                           ,p_proc_num IN VARCHAR2
                           ,p_partition_code IN NUMBER
                           ,p_fetch_limit IN NUMBER
                           ,p_operation_mode IN VARCHAR2
                           ,p_master_request_id IN NUMBER);


/*PROCEDURE Process_Rows (x_status OUT NOCOPY NUMBER
                      ,x_message OUT NOCOPY VARCHAR2
                      ,x_rows_processed OUT NOCOPY NUMBER
                      ,x_rows_loaded OUT NOCOPY NUMBER
                      ,x_rows_rejected OUT NOCOPY NUMBER
                      ,p_eng_sql IN VARCHAR2
                      ,p_data_slc IN VARCHAR2
                      ,p_proc_num IN VARCHAR2
                      ,p_slice_id IN VARCHAR2
                      ,p_fetch_limit IN NUMBER
                      ,p_load_type IN VARCHAR2
                      ,p_dimension_varchar_label IN VARCHAR2
                      ,p_execution_mode IN VARCHAR2
                      ,p_structure_id IN NUMBER); */


END FEM_DIM_MEMBER_LOADER_PKG;






 

/
