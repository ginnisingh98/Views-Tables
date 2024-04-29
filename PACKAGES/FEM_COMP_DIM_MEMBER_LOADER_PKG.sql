--------------------------------------------------------
--  DDL for Package FEM_COMP_DIM_MEMBER_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_COMP_DIM_MEMBER_LOADER_PKG" AUTHID CURRENT_USER AS
/* $Header: femcompdimldrs.pls 120.1 2006/09/07 12:26:23 navekuma noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------
   c_block  CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_comp_dim_member_loader_pkg';
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


   c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
   c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
   c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
   c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
   c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
   c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

   -- Engine SQL for Composite Dimension Loader
   g_select_statement  LONG;

   ---------------------------------------------
   --  Message Constants
   ---------------------------------------------

   G_NO_STRUCTURE_DEFINED VARCHAR2(30)  := 'FEM_DIM_NO_STRUCTURE_DEFINED';

   ---------------------------------------------
   -- Declare Exceptions --
   ---------------------------------------------

   e_no_structure_defined      EXCEPTION;
   e_terminate                 EXCEPTION;

   ---------------------------------------------
   --  Package Types
   ---------------------------------------------
   TYPE rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
   t_rowid rowid_type;

   TYPE date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
   TYPE varchar2_std_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE varchar2_150_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
   t_status        varchar2_150_type;

   -- This stores the details of each component dimensions of Flex Field

   TYPE rt_metadata IS RECORD (
     dimension_id            fem_xdim_dimensions.dimension_id%TYPE,
     member_col              fem_xdim_dimensions.member_col%TYPE,
     member_display_code_col fem_xdim_dimensions.member_display_code_col%TYPE,
     member_b_table_name     fem_xdim_dimensions.member_b_table_name%TYPE,
     value_set_required_flag fem_xdim_dimensions.value_set_required_flag%TYPE,
     dimension_varchar_label VARCHAR2(100),
     member_sql              VARCHAR2(200));

   TYPE tt_metadata IS TABLE OF rt_metadata  INDEX BY BINARY_INTEGER;
     t_metadata      tt_metadata;

   -- This is used to store the values of the Interface(_T) tables

   TYPE display_code_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
    t_global_vs_combo_dc   display_code_type;
    t_fin_elem_dc   display_code_type;
    t_ledger_dc     display_code_type;
    t_cctr_org_dc   display_code_type;
    t_product_dc    display_code_type;
    t_channel_dc    display_code_type;
    t_project_dc    display_code_type;
    t_customer_dc   display_code_type;
    t_task_dc       display_code_type;
    t_user_dim1_dc  display_code_type;
    t_user_dim2_dc  display_code_type;
    t_user_dim3_dc  display_code_type;
    t_user_dim4_dc  display_code_type;
    t_user_dim5_dc  display_code_type;
    t_user_dim6_dc  display_code_type;
    t_user_dim7_dc  display_code_type;
    t_user_dim8_dc  display_code_type;
    t_user_dim9_dc  display_code_type;
    t_user_dim10_dc display_code_type;

    -- This stores the concatenated display code for composite dimension
    t_display_code  display_code_type;

    -- This stores the value of 'UOM_CODE' column for FEM_COST_OBECTS Table.
    t_uom_code      display_code_type;

    --This is used to store the component dimensions of Composite Dimension

    TYPE dim_structure IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
    t_component_dim_dc dim_structure;

    TYPE number_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    t_global_vs_combo_id    number_type;
    t_fin_elem_id    number_type;
    t_ledger_id    number_type;
    t_cctr_org_id    number_type;
    t_product_id     number_type;
    t_channel_id     number_type;
    t_project_id     number_type;
    t_customer_id    number_type;
    t_task_id        number_type;
    t_user_dim1_id   number_type;
    t_user_dim2_id   number_type;
    t_user_dim3_id   number_type;
    t_user_dim4_id   number_type;
    t_user_dim5_id   number_type;
    t_user_dim6_id   number_type;
    t_user_dim7_id   number_type;
    t_user_dim8_id   number_type;
    t_user_dim9_id   number_type;
    t_user_dim10_id  number_type;


    PROCEDURE Process_Rows (p_eng_sql IN VARCHAR2
                           ,p_slc_pred IN VARCHAR2
                           ,p_proc_num IN VARCHAR2
                           ,p_part_code IN VARCHAR2
                           ,p_fetch_limit IN NUMBER
                           ,p_dimension_varchar_label IN VARCHAR2
                           ,p_execution_mode IN VARCHAR2
                           ,p_structure_id IN NUMBER
                           ,p_req_id IN NUMBER );


END FEM_COMP_DIM_MEMBER_LOADER_PKG;
 

/
