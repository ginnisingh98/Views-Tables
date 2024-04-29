--------------------------------------------------------
--  DDL for Package BIS_VIEW_GENERATOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VIEW_GENERATOR_PVT" AUTHID CURRENT_USER AS
/* $Header: BISTBVGS.pls 120.1.12010000.2 2008/10/24 23:57:59 dbowles ship $ */

---  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---  FILENAME
---
---      BISTBVGS.pls
---
---  DESCRIPTION
---
---      specification  of package which generates the business views
---
---  NOTES
---
---  HISTORY
---
---  29-JUL-98 Created
---  19-MAR-99 Edited by WNASRALL@US for exception handling
---  03-NOV-00 Walid.Nasrallah  added new API Generate_Pruned_View
---  04-JAN-01 Walid.Nasrallah changed signature of Generate_Pruned_View
---  10-JAN-01 Walid.Nasrallah separated two signatures for
---                            Generate_Pruned_View
---  10-DEC-01 Edited by DBOWLES Added db driver comment
---  18-JAN-05 Modified by AMITGUPT for GSCC warnings
---
---
g_debug_file  VARCHAR2(2000);
---  Bug 6819715
---  variable to control whether or not to use optimizer hints
g_use_optimizer_hints   VARCHAR2(3);
g_db_version            VARCHAR2(2);
--- ============================================================================
---   PROCEDURE : Generate_Pruned_View
---   PARAMETERS: 1. p_viewname        Name of source view
---               2. p_column_table    Table of column names to generate
---               3. x_success         Specifies if generate was successful
---               4. x_error_string    Holds error message if unsuccesful
---   COMMENT   : API to be called from Application Integrator.
---               Generates one view only, throws exceptionson failure.
---   EXCEPTIONS:
---
---
--- ============================================================================

PROCEDURE Generate_Pruned_View
   (   p_viewname      IN BIS_VG_TYPES.view_name_type
     , p_objectname    IN VARCHAR2
     , p_gen_viewname  IN VARCHAR2 DEFAULT NULL
   );

--- ============================================================================
---   PROCEDURE : generate_Views
---    PARAMETERS: 1. x_error_buf          error buffer to hold concurrent program error
---                2. x_ret_code           return code of concurrent program
---                3. p_all_flag           generate all views for all products
---                4. p_Appl_Short_Name    application product_short name
---                5. p_KF_Appl_Short_Name application product_short name
---                6. p_Key_Flex_Code      key flexfield code
---                7. p_DF_Appl_Short_Name application product_short name
---                8. p_Desc_Flex_Name     descriptive flex field name
---                9. p_Lookup_Table_Name  lookup table name
---               10. p_Lookup_Type        lookup code type
---               11. p_View_Name          name of view to generate
---
---    COMMENT   : Launch this program to generate the business view(s) with the key flexfield,
---                descriptive flexfield and lookup information.
---    EXCEPTION : None
--- ============================================================================
   PROCEDURE generate_Views
   ( x_error_buf           OUT NOCOPY VARCHAR2
   , x_ret_code            OUT NOCOPY NUMBER
   , p_all_flag            IN  VARCHAR2                         := NULL
   , p_App_Short_Name      IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type  := NULL
   , p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type := NULL
   , p_Lookup_Table_Name   IN  VARCHAR2                         := NULL
   , p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type    := NULL
   , p_View_Name           IN  BIS_VG_TYPES.View_Name_Type      := NULL
   );

--- ============================================================================
---   IMPORTANT NOTE
---     The following procedure and the mode is ONLY for test purposes only
---     It should not be used by anybody except for testing
--- =============================================================================

---  ============================================================================
---    PROCEDURE : set_mode
---    PARAMETERS:
---    1. p_mode               in View_Generator_Mode_Type
---    2. x_return_status    error or normal
---    3. x_error_Tbl        table of error messages
---
---    COMMENT   : sets the behaviour mode for the program.  Two versions for
--- 		backward compatibility.
---    EXCEPTION : None
--- ============================================================================
PROCEDURE set_mode
(p_mode IN bis_vg_types.view_generator_mode_type);

PROCEDURE set_mode
(p_mode IN bis_vg_types.view_generator_mode_type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_VG_UTIL.Error_Tbl_Type

);

--
--
--============================================================================
--  EXCEPTIONS and ERROR MESSAGES
--  ==========================================================================

  NO_WAREHOUSE_LINK_FOUND      EXCEPTION;
  NO_VIEW_NAME_PASSED          EXCEPTION;
  CANNOT_PRUNE_NON_EDW_VIEW    EXCEPTION;
  NO_COLUMNS_SELECTED          EXCEPTION;

  GENERATOR_NO_VIEWS   CONSTANT VARCHAR2(50):= 'BIS_VG_UNDEFINED_VIEW';


  MISMATCHED_TAG_EXCEPTION EXCEPTION;
  MISMATCHED_TAG_EXCEPTION_MSG CONSTANT VARCHAR2(50) := 'BIS_VG_MISMATCHED_TAG_MSG';
---
  INVALID_TAG_EXCEPTION EXCEPTION;
  INVALID_TAG_EXCEPTION_MSG CONSTANT VARCHAR2(50) := 'BIS_VG_INVALID_TAG_MSG';
---
--  ==========================================================================
--  CONSTANTS
--  ==========================================================================


END BIS_VIEW_GENERATOR_PVT;

/
