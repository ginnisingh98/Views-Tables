--------------------------------------------------------
--  DDL for Package BIS_VG_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_LOG" AUTHID CURRENT_USER AS
/* $Header: BISTLOGS.pls 115.7 2002/03/27 08:18:41 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTLOGB.pls
--
--  DESCRIPTION
--
--      body of package which writes the log for generated business views
--
--  NOTES
--
--  HISTORY
--
--  21-Aug-1998 ANSINGHA created
--  08-Jan-2001 Walid.Nasrallah Modified to add write_error_to_string
--  10-DEC-01 Edited by DBOWLES Added db driver comment
--
-- ============================================================================
-- EXCEPTIONS
-- ============================================================================

numeric_or_value_error exception;
pragma exception_init(numeric_or_value_error, -6502);

-- ============================================================================
--PROCEDURE : Init_Log
--PARAMETERS
--  1. x_return_status    error or normal
--  2. x_error_Tbl        table of error messages

--COMMENT   : Call this function to start logging the messages
--RETURN    : None
--EXCEPTION : None
-- ============================================================================

PROCEDURE init_log
    ( x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    )
;

-- ============================================================================
--PROCEDURE : Update_Success_Log
--PARAMETERS: 1. p_OrigBV - Original business view  name
--            2. p_GenBV  - Generated Business View name
--            3. x_return_status    error or normal
--            4. x_error_Tbl        table of error messages
--COMMENT   : Call this function to log a successful generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE update_success_log
    ( p_origbv IN bis_vg_types.view_name_type
    , p_genbv  IN bis_vg_types.view_name_type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    );

-- ============================================================================
--PROCEDURE : Update_Failure_Log
--PARAMETERS: 1. p_OrigBV - Original business view  name
--            2. p_code   - code for the error message
--            3. p_errm   - error message
--            4. x_return_status    error or normal
--            5. x_error_Tbl        table of error messages
--COMMENT   : Call this function to log failed generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE update_failure_log
    ( p_origbv IN bis_vg_types.view_name_type
    , p_code   IN NUMBER
    , p_errm   IN VARCHAR2
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    );

-- ============================================================================
--PROCEDURE : Update_Failure_Log
--PARAMETERS: 1. p_error_Tbl - table containint one or more error messages
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
--COMMENT   : This overloaded version of Update_Failure_Log generates
--            a partiual log of failure at teh point where it occurs.
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE update_failure_log
    ( p_error_Tbl           IN BIS_VG_UTIL.Error_Tbl_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    );

-- ============================================================================
--PROCEDURE : backpatch_failure_log
--PARAMETERS: 1. p_OrigBV - Original business view  name
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
--COMMENT   : Function fills in view name where missing.  Used in
--            conjunction with the short version of update_failure_log.
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE backpatch_failure_log
    ( p_origbv IN bis_vg_types.view_name_type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    );


-- ============================================================================
--PROCEDURE : Write_Log
--PARAMETERS 1. p_mode                IN  bis_vg_Types.view_generator_mode_type
--           2. p_all_flag            IN  VARCHAR2
--           3. p_App_Short_Name      IN  BIS_VG_TYPES.App_Short_Name_Type
--           4. p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
--           5. p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type
--           6. p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
--           7. p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type
--           8. p_Lookup_Table_Name   IN  VARCHAR2
--           9. p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type
--           10. p_View_Name          IN  BIS_VG_TYPES.View_Name_Type
--           11. x_return_status    error or normal
--           12. x_error_Tbl        table of error messages
--COMMENT   : Call this function to write the log to the out file in production
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE write_log
    ( p_mode                IN  bis_vg_types.View_Generator_Mode_Type
    , p_all_flag            IN  VARCHAR2
    , p_App_Short_Name      IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type
    , p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type
    , p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type
    , p_Lookup_Table_Name   IN  VARCHAR2
    , p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type
    , p_View_Name           IN  BIS_VG_TYPES.View_Name_Type
    , x_return_status       OUT VARCHAR2
    , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
    );
-- ============================================================================
-- PROCEDURE : Write_Error_to_String
-- PARAMETERS 1. x_error_string        String to hold error messages
-- COMMENT   : Call this function to access the list of errors in g_failure_log
-- RETURN    : None
-- EXCEPTION : None
-- ============================================================================
PROCEDURE write_error_to_string
( x_error_string       OUT VARCHAR2
);

END BIS_VG_LOG;

 

/
