--------------------------------------------------------
--  DDL for Package BIS_VG_COMPILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_COMPILE" AUTHID CURRENT_USER AS
/* $Header: BISTCMPS.pls 120.4 2006/06/15 16:40:47 dbowles ship $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTWRTB.pls
--
--  DESCRIPTION
--
--      body of package which writes the business views
--
--  NOTES
--
--  HISTORY
--
--  21-AUG-98 ANSINGHA created
--  19-MAR-99 Edited by WNASRALL@US for exception handling
--  06-APR-01 Edited by DBOWLES.  Added 2 new parameter to write_View.
--            Both parameters are of type
--            bis_vg_types.Flex_Column_Comment_Table_Type
--  10-DEC-01 Edited by DBOWLES Added db driver comment
--
-- ============================================================================
expected_overflow_error exception;
numeric_or_value_error exception;
pragma exception_init(numeric_or_value_error, -6502);


PROCEDURE write_View -- PUBLIC PROCEDURE
( p_mode                      IN NUMBER
, p_View_Name                 IN VARCHAR2
, p_View_Create_Text_Table    IN bis_vg_types.View_Text_Table_Type
, p_View_Select_Text_Table    IN bis_vg_types.view_text_table_type
, p_View_Column_Comment_Table IN bis_vg_types.Flex_Column_Comment_Table_Type
, x_View_Column_Comment_Table OUT bis_vg_types.Flex_Column_Comment_Table_Type
---, x_return_status       OUT VARCHAR2
, x_error_Tbl                 OUT BIS_VG_UTIL.Error_Tbl_Type
);

END BIS_VG_COMPILE;

 

/
