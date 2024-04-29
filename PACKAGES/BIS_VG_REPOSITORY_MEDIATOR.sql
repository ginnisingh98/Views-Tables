--------------------------------------------------------
--  DDL for Package BIS_VG_REPOSITORY_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_REPOSITORY_MEDIATOR" AUTHID CURRENT_USER AS
/* $Header: BISTRPMS.pls 115.14 2002/03/27 08:18:47 pkm ship     $ */

--  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BISTRPMS.pls
--
--  DESCRIPTION
--
--      specification of repository mediator package
--
--  NOTES
--
--  HISTORY
--
--  23-JUL-98 Created
--
--  10-DEC-01 Edited by DBOWLES Added db driver comment
--
--
--
--- ======================================================================================
---   PROCEDURE : create_View_Text_Tables
---   PARAMETERS:
---   1. p_View_Table_Rec         view table record
---   2. x_View_Create_Text_Table table of varchars to hold create view text
---   3. x_View_Select_Text_Table table of varchars to hold create view text
---   4. x_error_Tbl        table of error messages
---
---   COMMENT   : Call this procedure to retrieve the view text from the runtime repository.
---   EXCEPTION : None
---  ======================================================================================
   PROCEDURE create_View_Text_Tables
   ( p_View_name         IN  BIS_VG_TYPES.View_name_type := null
   , x_View_Column_Text_Table OUT BIS_VG_TYPES.View_Text_Table_Type
   , x_View_Select_Text_Table OUT BIS_VG_TYPES.View_Text_Table_Type
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   );
--
/* ======================================================================================
   PROCEDURE : retrieve_Business_Views
   PARAMETERS:
   1. p_all_flag           retrieve all views for all products
   2. p_App_Short_Name     application short name
   3. p_KF_Appl_Short_Name application short name
   4. p_Key_Flex_Code      key flexfield code
   5. p_DF_Appl_Short_Name application short name
   6. p_Desc_Flex_Name     descriptive flexfield name
   7. p_Lookup_Table_Name  lookup table name
   8. p_Lookup_Code        lookup code
   9. p_View_Name          name of view to generate
   10. p_View_Table         table to hold view definition
   11. x_return_status    error or normal
   12. x_error_Tbl        table of error messages

   COMMENT   : Call this procedure to retrieve the business views from the runtime repository.
   EXCEPTION : None
  ====================================================================================== */
   PROCEDURE retrieve_Business_Views
   ( p_all_flag            IN  VARCHAR2                         := NULL
   , p_App_Short_name      IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_KF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_Key_Flex_Code       IN  BIS_VG_TYPES.Key_Flex_Code_Type  := NULL
   , p_DF_Appl_Short_Name  IN  BIS_VG_TYPES.App_Short_Name_Type := NULL
   , p_Desc_Flex_Name      IN  BIS_VG_TYPES.Desc_Flex_Name_Type := NULL
   , p_Lookup_Table_Name   IN  VARCHAR2                         := NULL
   , p_Lookup_Type         IN  BIS_VG_TYPES.Lookup_Code_Type    := NULL
   , p_View_Name           IN  BIS_VG_TYPES.View_name_Type      := NULL
   , x_View_Table          OUT BIS_VG_TYPES.View_Table_Type
   , x_return_status       OUT VARCHAR2
   , x_error_Tbl           OUT BIS_VG_UTIL.Error_Tbl_Type
   );
--
--
END BIS_VG_REPOSITORY_MEDIATOR;

 

/
