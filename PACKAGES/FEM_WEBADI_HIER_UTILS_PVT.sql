--------------------------------------------------------
--  DDL for Package FEM_WEBADI_HIER_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_WEBADI_HIER_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVADIHIERUTILS.pls 120.0.12000000.2 2007/08/08 05:49:12 lkiran ship $ */
--
--------------------------
-- Declare Object types --
--------------------------
-- Table types
TYPE g_number_tbl_type IS TABLE OF NUMBER       INDEX BY PLS_INTEGER ;
TYPE g_char_tbl_type   IS TABLE OF VARCHAR2(30) INDEX BY PLS_INTEGER ;
TYPE g_date_tbl_type   IS TABLE OF DATE         INDEX BY PLS_INTEGER ;
--
-- Define a record to hold Dimension Metadata global variables.
-- Bug#5959140: Match variable size to db col size.
TYPE g_global_val_rec_type
IS
RECORD
( dimension_id              NUMBER
, dimension_varchar_label   VARCHAR2(30)
, intf_member_b_table_name  VARCHAR2(30)
, intf_member_tl_table_name VARCHAR2(30)
, intf_attribute_table_name VARCHAR2(30)
, member_b_table_name       VARCHAR2(30)
, member_display_code_col   VARCHAR2(30)
, member_display_code       VARCHAR2(150)
, calendar_display_code     VARCHAR2(150)
, member_name_col           VARCHAR2(30)
, member_name               VARCHAR2(150)
, member_description        VARCHAR2(255)
, hierarchy_intf_table_name VARCHAR2(30)
, dimension_type_code       VARCHAR2(30)
, group_use_code            VARCHAR2(30)
, value_set_required_flag   VARCHAR2(1)
, value_set_display_code    VARCHAR2(150)
, dim_grp_disp_code         VARCHAR2(150)
, ledger_id                 NUMBER
) ;
--
TYPE g_global_val_tbl_type
IS
TABLE OF g_global_val_rec_type
INDEX BY PLS_INTEGER ;
--
g_global_val_tbl g_global_val_tbl_type ;
--
------------------------------
-- Declare Global variables --
------------------------------
G_LIMIT_BULK_NUMROWS CONSTANT NUMBER := 100 ; -- Limit to hold number of rows
--
-- Declare variables to hold Map table column values.
g_dim_varchar_label_tbl     g_char_tbl_type ;
g_interface_col_name_tbl    g_char_tbl_type ;
g_attribute_name_tbl        g_char_tbl_type ;
g_attribute_data_type_tbl   g_char_tbl_type ;
--
------------------------
-- Declare Procedures --
------------------------

/*===========================================================================+
Procedure name       : Upload_Hierarchy_Interface
Parameters           :
IN                   : p_folder_name                 VARCHAR2
                       p_dimension_varchar_label     VARCHAR2
                       p_hierarchy_object_name       VARCHAR2
                       p_hierarchy_obj_def_disp_name VARCHAR2
                       p_ledger_id                   NUMBER
                       p_calendar_display_code       VARCHAR2
                       p_group_seq_enforced_code     VARCHAR2
                       p_effective_start_date        DATE
                       p_effective_end_date          DATE
                       p_hierarchy_usage_code        VARCHAR2
                       p_hierarchy_type_code         VARCHAR2
                       p_multi_top_flag              VARCHAR2
                       p_multi_value_set_flag        VARCHAR2
                       p_parent_display_code         VARCHAR2
                       p_child_display_code          VARCHAR2
OUT                  :

Description          : This procedure populates Hierarchy details

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
09/22/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/

PROCEDURE Upload_Hierarchy_Interface
( p_folder_name                 IN VARCHAR2
, p_dimension_varchar_label     IN VARCHAR2
, p_hierarchy_object_name       IN VARCHAR2
, p_hierarchy_obj_def_disp_name IN VARCHAR2
, p_ledger_id                   IN NUMBER
, p_calendar_display_code       IN VARCHAR2
, p_group_seq_enforced_code     IN VARCHAR2
, p_effective_start_date        IN DATE
, p_effective_end_date          IN DATE
, p_hierarchy_usage_code        IN VARCHAR2
, p_hierarchy_type_code         IN VARCHAR2
, p_multi_top_flag              IN VARCHAR2
, p_multi_value_set_flag        IN VARCHAR2
, p_parent_display_code         IN VARCHAR2
, p_child_display_code          IN VARCHAR2
) ;

END FEM_WEBADI_HIER_UTILS_PVT ;

 

/
