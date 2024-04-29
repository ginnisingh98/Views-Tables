--------------------------------------------------------
--  DDL for Package FEM_DIMENSION_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIMENSION_MIGRATION_PKG" AUTHID CURRENT_USER AS
-- $Header: femdimmig_pkh.pls 120.1 2005/07/25 14:45:43 appldev noship $
/*==========================================================================+
 |    Copyright (c) 2005 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    femdimmig_pkh.pls
 |
 | NAME fem_dimension_migration_pkg
 |
 | DESCRIPTION
 |
 |   Package fem_dimension_migration_pkg. This package is the engine for
 |   migrating dimension members, member translatable names/descriptions,
 |   and member attribute assignments from a source database into the dimension
 |   member loader interface tables in the target database
 |
 | FUNCTIONS/PROCEDURES
 |
 |  Main
 | errbuf                       OUT NOCOPY     VARCHAR2
 | retcode                      OUT NOCOPY     VARCHAR2
 | p_execution_mode             IN       VARCHAR2
 | p_object_definition_id       IN       NUMBER DEFAULT 1200
 | p_dimension_varchar_label    IN       VARCHAR2
 | p_date_format_mask           IN       VARCHAR2
 |
 | NOTES
 |
 |
 | HISTORY
 |
 |    25-APR-05  PRANDALL Created
 +=========================================================================*/

---------------------------------------------
--  Package Constants
---------------------------------------------
   c_block  CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_dimension_migration_pkg';
   c_fem    CONSTANT  VARCHAR2(3)  := 'FEM';
   c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;
   c_object_version_number CONSTANT NUMBER := 1;
   c_enabled_flag   VARCHAR2(1) := 'Y';
   c_personal_flag  VARCHAR2(1) := 'Y';
   c_read_only_flag VARCHAR2(1) := 'Y';

   c_false        CONSTANT  VARCHAR2(1)      := FND_API.G_FALSE;
   c_true         CONSTANT  VARCHAR2(1)      := FND_API.G_TRUE;
   c_success      CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_SUCCESS;
   c_error        CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_ERROR;
   c_unexp        CONSTANT  VARCHAR2(1)      := FND_API.G_RET_STS_UNEXP_ERROR;
   c_api_version  CONSTANT  NUMBER           := 1.0;
   c_fetch_limit  CONSTANT  NUMBER           := 99999;



---------Message Constants--------------
--G_DIM_NOT_FOUND VARCHAR2(30)      := 'FEM_DIM_NOT_FOUND';
--G_INVALID_SIMPLE_DIM VARCHAR2(30)   := 'FEM_DIM_LOADS_NOT_ALLOWED';
--G_INVALID_DATE_FORMAT VARCHAR2(30)    := 'FEM_INVALID_DATE_FORMAT';
--G_INVALID_EXEC_MODE VARCHAR2(30)      := 'FEM_DIM_MEMBER_LDR_EXEC_MODE';
G_EXEC_LOCK_EXISTS VARCHAR2(30)       := 'FEM_PL_OBJ_EXECLOCK_EXISTS_ERR';
--G_INVALID_OBJ_DEF VARCHAR2(30)        := 'FEM_DATAX_LDR_BAD_OBJ_ERR';
--G_EXT_LDR_POST_PROC_ERR VARCHAR2(30)  := 'FEM_EXT_LDR_POST_PROC_ERR';
--G_EXT_LDR_EXEC_STATUS   VARCHAR2(30)  := 'FEM_EXT_LDR_EXEC_STATUS';
G_PL_REG_REQUEST_ERR VARCHAR2(30)     := 'FEM_PL_REG_REQUEST_ERR';
G_PL_OBJ_EXEC_LOCK_ERR VARCHAR2(30)  := 'FEM_PL_OBJ_EXEC_LOCK_ERR';
--G_MULT_DEFAULT_VERSION VARCHAR2(30)  := 'FEM_TOO_MANY_DEFAULT_VERSIONS';
--G_NO_ROWS_TO_LOAD VARCHAR2(30)       := 'FEM_DIM_MBR_LDR_NO_ROWS_LOAD';
G_MESSAGE VARCHAR2(30) := 'FEM_MISSING_MESSAGE';

G_DB_LINK_NOT_REGISTERED VARCHAR2(30) := 'FEM_DM_DB_LINK_NOT_REGISTERED';
G_DB_LINK_NOT_FUNCTIONAL VARCHAR2(30) := 'FEM_DM_DB_LINK_NOT_FUNCTIONAL';
G_INVALID_VERSION_PARAM VARCHAR2(30) := 'FEM_DM_INV_VERSION_PARAM';
G_MISSING_VERSION_PARAM VARCHAR2(30) := 'FEM_DM_MISSING_VERSION_PARAM';
G_INVALID_SRC_USER_DIM VARCHAR2(30) := 'FEM_DM_INV_SOURCE_USER_DIM';
G_USER_DIM_MISMATCH VARCHAR2(30) := 'FEM_DM_USER_DIM_MISMATCH';
G_VERSION_EXISTS VARCHAR2(30) := 'FEM_DM_VERSION_EXISTS';
G_INVALID_HIERARCHY VARCHAR2(30) := 'FEM_DM_INV_HIER_OBJ';
G_INVALID_HIER_VERSION VARCHAR2(30) := 'FEM_DM_INV_HIER_OBJ_DEF';
G_MISSING_LANG VARCHAR2(30) := 'FEM_DM_MISSING_LANG';
G_DIM_NOT_SUPPORTED VARCHAR2(30) := 'FEM_DM_DIM_CANNOT_MIGRATE';
G_INVALID_DIMENSION VARCHAR2(30) := 'FEM_DM_INVALID_DIMENSION';
G_UNHANDLED_ERROR VARCHAR2(30) := 'FEM_DM_UNHANDLED_ERROR';
G_INSERT_ERROR VARCHAR2(30) := 'FEM_DM_INSERT_ERROR';
G_PL_MIGRATION_ERROR VARCHAR2(30) := 'FEM_DM_PL_EXEC_ERROR';
G_HIERARCHY_RULE_EXISTS VARCHAR2(30) := 'FEM_DM_TGT_HIER_EXISTS';
G_INVALID_VERSION_DISP_CD VARCHAR2(30) := 'FEM_DM_INV_VERSION_DC';
G_INVALID_VERSION_NAME VARCHAR2(30) := 'FEM_DM_INV_VERSION_NAME';
G_DIM_HIER_NOT_SUPPORTED VARCHAR2(30) := 'FEM_DM_DIM_HIER_NOT_SUPPORTED';


---------------------------------------
------------------------
-- Declare Exceptions --
------------------------
   /*e_dimension_not_found       EXCEPTION;
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
   e_no_rows_to_load           EXCEPTION;*/


e_pl_registration_failed   EXCEPTION;
e_dimension_not_supported  EXCEPTION;
e_invalid_dimension  EXCEPTION;
e_db_link_not_registered  EXCEPTION;
e_db_link_not_functional  EXCEPTION;
e_invalid_version_param   EXCEPTION;
e_dim_not_user_extensible EXCEPTION;
e_missing_version_params  EXCEPTION;
e_invalid_obj_def  EXCEPTION;
--e_invalid_source_dim_name EXCEPTION;
e_invalid_version_name  EXCEPTION;
e_invalid_version_display_code EXCEPTION;
e_invalid_source_vs_name EXCEPTION;
e_terminate EXCEPTION;
e_main_terminate EXCEPTION;
e_post_process EXCEPTION;
e_src_dim_not_user_extensible EXCEPTION;
e_invalid_hierarchy EXCEPTION;
e_invalid_hierarchy_version EXCEPTION;
e_target_hierarchy_exists EXCEPTION;
e_insert_b_exception EXCEPTION;
e_insert_tl_exception EXCEPTION;
e_insert_attr_exception EXCEPTION;
e_insert_hier_exception EXCEPTION;
e_dim_hier_not_supported EXCEPTION;

   /*PRAGMA EXCEPTION_INIT(e_invalid_number, -6502);
   PRAGMA EXCEPTION_INIT(e_invalid_number1722, -1722);
   PRAGMA EXCEPTION_INIT(e_invalid_date, -1843);
   PRAGMA EXCEPTION_INIT(e_invalid_date_result, -1821);
   PRAGMA EXCEPTION_INIT(e_date_string_too_long, -1830);
   PRAGMA EXCEPTION_INIT(e_invalid_date_numeric, -1858);
   PRAGMA EXCEPTION_INIT(e_invalid_date_between, -1841);
   PRAGMA EXCEPTION_INIT(e_invalid_date_year, -1847);
   PRAGMA EXCEPTION_INIT(e_invalid_date_format, -1861);
   PRAGMA EXCEPTION_INIT(e_invalid_date_month, -1816);
   PRAGMA EXCEPTION_INIT(e_invalid_date_day, -1839);*/

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

TYPE DIMENSION_PROPS_REC IS RECORD(
   DIMENSION_ID                FEM_XDIM_DIMENSIONS.DIMENSION_ID%TYPE,
   MIGRATION_OBJ_ID            NUMBER,
   MIGRATION_OBJ_DEF_ID        NUMBER,
   USER_DEFINED_FLAG           FEM_XDIM_DIMENSIONS.USER_DEFINED_FLAG%TYPE,
   GROUP_USE_CODE              FEM_XDIM_DIMENSIONS.GROUP_USE_CODE%TYPE,
   SIMPLE_DIMENSION_FLAG       FEM_XDIM_DIMENSIONS.SIMPLE_DIMENSION_FLAG%TYPE,
   VALUE_SET_REQUIRED_FLAG     FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%TYPE,
   INTF_MEMBER_B_TABLE_NAME    FEM_XDIM_DIMENSIONS.INTF_MEMBER_B_TABLE_NAME%TYPE,
   INTF_MEMBER_TL_TABLE_NAME   FEM_XDIM_DIMENSIONS.INTF_MEMBER_TL_TABLE_NAME%TYPE,
   INTF_ATTRIBUTE_TABLE_NAME   FEM_XDIM_DIMENSIONS.INTF_ATTRIBUTE_TABLE_NAME %TYPE,
   MEMBER_B_TABLE_NAME         FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%TYPE,
   MEMBER_TL_TABLE_NAME        FEM_XDIM_DIMENSIONS.MEMBER_TL_TABLE_NAME %TYPE,
   ATTRIBUTE_TABLE_NAME        FEM_XDIM_DIMENSIONS.ATTRIBUTE_TABLE_NAME%TYPE,
   MEMBER_COL                  FEM_XDIM_DIMENSIONS.MEMBER_COL%TYPE,
   MEMBER_DISPLAY_CODE_COL     FEM_XDIM_DIMENSIONS.MEMBER_DISPLAY_CODE_COL%TYPE,
   MEMBER_NAME_COL             FEM_XDIM_DIMENSIONS.MEMBER_NAME_COL%TYPE,
   MEMBER_DESCRIPTION_COL      FEM_XDIM_DIMENSIONS.MEMBER_DESCRIPTION_COL%TYPE,
   HIERARCHY_TABLE_NAME        FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%TYPE,
   HIERARCHY_INTF_TABLE_NAME   FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%TYPE);


FUNCTION GET_ATTR_ASSIGN_VALUE(p_source_db_link IN VARCHAR2,
                               p_dimension_id   IN NUMBER,
                               p_value          IN VARCHAR2 ) RETURN VARCHAR2;


PROCEDURE MIGRATE_MEMBERS(x_retcode                   OUT  NOCOPY  VARCHAR2,
                          x_errug                     OUT  NOCOPY  VARCHAR2,
                          p_source_db_link            IN   VARCHAR2,
                          p_dim_varchar_lbl           IN   VARCHAR2,
                          p_autoload_dims             IN   VARCHAR2,
                          p_migrate_dependent_dims    IN   VARCHAR2,
                          p_version_mode              IN   VARCHAR2,
                          p_version_disp_cd           IN   VARCHAR2,
                          p_version_name              IN   VARCHAR2,
                          p_version_desc              IN   VARCHAR2,
                          p_hier_obj_name             IN   VARCHAR2,
                          p_hier_obj_def_name         IN   VARCHAR2,
                          p_source_user_dim_name      IN   VARCHAR2);

PROCEDURE MIGRATE_MEMBERS(x_retcode                   OUT  NOCOPY  VARCHAR2,
                          x_errug                     OUT  NOCOPY  VARCHAR2,
                          p_source_db_link            IN   VARCHAR2,
                          p_dim_varchar_lbl           IN   VARCHAR2,
                     --     p_version_mode              IN   VARCHAR2,
                      --    p_version_disp_cd           IN   VARCHAR2,
                      --    p_version_name              IN   VARCHAR2,
                      --    p_version_desc              IN   VARCHAR2,
                          p_source_user_dim_name      IN   VARCHAR2);

PROCEDURE MIGRATE_HIERARCHY(x_retcode                   OUT  NOCOPY  VARCHAR2,
                            x_errug                     OUT  NOCOPY  VARCHAR2,
                            p_source_db_link            IN   VARCHAR2,
                            p_dim_varchar_lbl           IN   VARCHAR2,
                            p_hier_obj_name             IN   VARCHAR2,
                            p_hier_obj_def_name         IN   VARCHAR2,
                            p_source_user_dim_name      IN   VARCHAR2);

END FEM_DIMENSION_MIGRATION_PKG;

 

/
