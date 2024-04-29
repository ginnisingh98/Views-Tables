--------------------------------------------------------
--  DDL for Package GL_FLATTEN_SEG_VAL_HIERARCHIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FLATTEN_SEG_VAL_HIERARCHIES" AUTHID CURRENT_USER AS
/* $Header: gluflshs.pls 120.4.12010000.1 2008/07/28 13:30:48 appldev ship $ */

 -- ********************************************************************
-- Function
--   Flatten_Seg_Val_Hier
-- Purpose
--   This Function  is the entry point for maintaining the tables
--   GL_SEG_VAL_NORM_HIERARCHY  and GL_SEG_VAL_HIERARCHIES.
-- History
--   25-04-2001       Srini Pala    Created
-- Arguments
--   Is_seg_hier_changed            Indicates changes in the segment hierarchy
-- Example
--   ret_status := Flatten_Seg_Val_Hier(Is_Seg_Hier_Changed OUT NOCOPY BOOLEAN)
--

   Function  Flatten_Seg_Val_Hier(Is_Seg_Hier_Changed OUT NOCOPY BOOLEAN)
                                  RETURN BOOLEAN ;


-- ******************************************************************
-- Function
--   Fix_Norm_Table
-- Purpose
--   This Function  maintains the table GL_SEG_VAL_NORM_HIERARCHY
-- History
--   25-04-2001   Srini Pala    Created
-- Arguments
--   Is_Norm_table_Changed      Indicates changes in Norm table -values BOOLEAN
-- Example
--   ret_status := Fix_Norm_Table();
--
   Function  Fix_Norm_Table(Is_Norm_table_Changed OUT NOCOPY BOOLEAN)
                            RETURN BOOLEAN;

-- *****************************************************************

-- Function
--   Fix_Flattened_Table
-- Purpose
--   This Function  maintains the table GL_SEG_VAL_HIERARCHIES
-- History
--   25-04-2001       Srini Pala    Created
-- Arguments
--  Is_Flattened_Tab_changed        Indicates changes in the flattened table
-- Example
--   ret_status := Fix_Flattened_Table();
--
   Function  Fix_Flattened_Table(Is_Flattened_Tab_Changed OUT NOCOPY BOOLEAN)
                                 RETURN BOOLEAN;


-- ******************************************************************

-- FUNCTION
--   Clean_Up
-- Purpose
--   This function  is to bring all records to its final state in the tables
--   GL_SEG_VAL_NORM_HIERARCHY  and GL_SEG_VAL_HIERARCHIES
-- History
--   25-04-2001       Srini Pala    Created
-- Arguments

-- Example
--   ret_status := Clean_Up();
--
   FUNCTION  Clean_Up RETURN BOOLEAN ;



-- ******************************************************************

  END GL_FLATTEN_SEG_VAL_HIERARCHIES;


/
