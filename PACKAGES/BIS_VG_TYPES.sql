--------------------------------------------------------
--  DDL for Package BIS_VG_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_VG_TYPES" AUTHID CURRENT_USER AS
/* $Header: BISTTYPS.pls 115.20 2002/03/27 08:18:53 pkm ship     $ */

---  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---  FILENAME
---
---      BISTTYPS.pls
---
---  DESCRIPTION
---
---      specification of global types file
---
---  NOTES
---
---  HISTORY
---
---  23-JUL-98 Created
---  30-OCT-2000 Set MESSAGE_APPLICATION constant to FND
---  03-NOV-2000 Walid Nasrallah: Added new type Flexfield_Column_Table_Type
---              for Apps Integrator API
---  12-FEB-2001 Walid Nasrallah: Added new field APPLICATION_NAME to
---              Flexfield_Column_Rec_Type
---   05-APR-2001 Walid Nasrallah: Added new field SEGMENT_DATATYPE to
---              Flexfield_Column_Rec_Type
---   06-APR-2001 Don Bowles: Added new types Flex_Column_Comment_Rec_Type and
---              Flex_Column_Comment_Table_Type.  This record type
---              and table type is used is used to hold Flex info
---              that read when adding  comments to the generated
---              view columns derived from flex.
---   10-DEC-01 Edited by DBOWLES Added db driver comment
---
--- GLOBAL TYPES
---

--
  TYPE Flexfield_Column_Rec_Type   IS
  RECORD
    (   STRUCTURE_NUM             NUMBER(15)
      , STRUCTURE_NAME            VARCHAR2(60)
      , APPLICATION_COLUMN_NAME   VARCHAR2(60)
      , SEGMENT_NAME              VARCHAR2(60)
      , SEGMENT_DATATYPE          VARCHAR2(2)   --- added April 5, 2001
      , ID_FLEX_CODE              VARCHAR2(60)
      , FLEX_FIELD_TYPE           VARCHAR2(2)
      , FLEX_FIELD_NAME           VARCHAR2(100)
      , APPLICATION_NAME          VARCHAR2(20)   --- added Feb 12, 2001
    );

  TYPE Flexfield_Column_Table_Type
    IS
       TABLE of Flexfield_Column_Rec_Type
	 ;
---  INDEX BY BINARY_INTEGER;
---  --- (USED NESTED TABLE TYPE TO ALLOW NULL DEFAULT)

SUBTYPE App_Short_Name_Type      IS
  fnd_application.application_short_name%TYPE;
--
  SUBTYPE App_ID_Type              IS
  fnd_application.application_id%TYPE;
--
  SUBTYPE Key_Flex_Code_Type       IS
  fnd_id_flexs.id_flex_code%TYPE;
--
  SUBTYPE Desc_Flex_Name_Type      IS
  fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE;
--
  SUBTYPE Lookup_Code_Type         IS
  fnd_lookups.lookup_code%TYPE;
--
  SUBTYPE View_Name_Type           IS
  user_views.view_name%TYPE;
--
  g_dummy_Var                         VARCHAR2(256);
  SUBTYPE View_Text_Table_Rec_Type IS
  g_dummy_Var%TYPE;
--
  TYPE View_Text_Table_Type        IS
  TABLE of View_Text_Table_Rec_Type
  INDEX BY BINARY_INTEGER;
--
  TYPE View_Table_Rec_Type         IS
  RECORD
    ( Application_ID  app_id_type
    , app_short_name  app_short_name_type
    , View_Name       view_name_type
    , text_length     user_views.text_length%TYPE
    );
--
  TYPE View_Table_Type             IS
  TABLE OF View_Table_Rec_Type
  INDEX BY BINARY_INTEGER;
--
  TYPE Application_Table_Type      IS
  TABLE OF fnd_product_installations.application_id%TYPE
  INDEX BY BINARY_INTEGER;
--
  TYPE View_Character_Pointer_Type IS
  RECORD
    ( row_num NUMBER
    , col_num NUMBER
    );
--
  TYPE Flex_Column_Comment_Rec_Type IS
  RECORD
     (column_name     View_Text_Table_Rec_Type
      ,flex_type       VARCHAR2(25)
      ,column_comments VARCHAR2(255)
     );
--
  TYPE Flex_Column_Comment_Table_Type IS
  TABLE OF Flex_Column_Comment_Rec_Type
  INDEX BY BINARY_INTEGER;
---
--- application to be used while retrieving the messages from fnd_new_messages
---
  MESSAGE_APPLICATION  CONSTANT VARCHAR2(10) := 'FND';

---============================================================================
---  IMPORTANT NOTE
---    The following mode is ONLY for test purposes only
---    It should not be used by anybody except for testing
---=============================================================================

  SUBTYPE View_Generator_Mode_Type IS NUMBER;

  -- mode for release, also default
  production_mode         CONSTANT view_generator_mode_type := 1;
  -- mode where view will be generated
  test_view_gen_mode      CONSTANT view_generator_mode_type := 2;
  -- mode where views will not be generated
  test_no_view_gen_mode   CONSTANT view_generator_mode_type := 3;
  -- mode when running the view generator from sqlplus
  sqlplus_production_mode CONSTANT view_generator_mode_type := 4;
  -- mode for the generator to just remove tags from the input view
  -- This is used typically to generate the views in seed11 where all the
  -- flesfields are no defined and we want to just have the static columns
  remove_tags_mode CONSTANT view_generator_mode_type := 5;
  -- In this mode, the generator uses a passed parameter for the name
  -- of the generated view
  edw_verify_mode CONSTANT view_generator_mode_type := 7;
--
END BIS_VG_TYPES;

 

/
