--------------------------------------------------------
--  DDL for Package GL_FLATTEN_LEDGER_SEG_VALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FLATTEN_LEDGER_SEG_VALS" AUTHID CURRENT_USER AS
/* $Header: glufllvs.pls 120.4 2005/05/05 01:38:35 kvora ship $ */

 -- ********************************************************************
-- Function
--   Fix_By_Coa
-- Purpose
--   This Function  is the entry point When Flattening program is called in
--   mode LV, it indicates changes in the Ledger definition.
-- History
--   06-04-2001       Srini Pala    Created
-- Arguments

-- Example
--   ret_status := Fix_By_Coa()
--
   Function  Fix_By_Coa RETURN BOOLEAN ;


-- ******************************************************************
-- Function
--   Fix_By Value_Set()
-- Purpose
--   This Function  is the entry point When Flattening program is called in
--   mode SH, it indicates changes in Segment hierarchy.
-- History
--   06-04-2001       Srini Pala    Created
-- Arguments

-- Example
--   ret_status := Fix_By_Value_set()
--
   Function Fix_By_Value_Set RETURN BOOLEAN;

-- *****************************************************************
-- FUNCTION
--   Clean_Up_By_Coa
-- Purpose
--   This Function is to clean the tables GL_LEDGER_NORM_SEG_VALUES
--   and GL_LEDGER_SEGMENT_VALUES for a particular chart of accounts.
-- History
--   06-04-2001       Srini Pala    Created
-- Arguments

-- Example
--   ret_status := Clean_Up_By_Coa();
--

   FUNCTION  Clean_Up_By_Coa RETURN BOOLEAN ;



-- ******************************************************************

-- FUNCTION
--   Clean_Up_By_Value_Set
-- Purpose
--   This FUNCTION is to clean the tables GL_LEDGER_NORM_SEG_VALUES
--   and GL_LEDGER_SEGMENT_VALUES for a particular value set.
-- History
--   06-04-2001       Srini Pala    Created
-- Arguments

-- Example
--   ret_status := Clean_Up_By_Value_Set();
--

   FUNCTION  Clean_Up_By_Value_Set RETURN BOOLEAN ;



-- ******************************************************************

-- FUNCTION
--   Error_check
-- Purpose
--   This FUNCTION  checks if a segment value has been assigned to a
--   particular ledger more than once on a given date.
--   If it returns TRUE then program should error out
-- History
--   06-04-2001       Srini Pala    Created
-- Arguments
--
-- Example
--   ret_status := Error_Check();
--

   FUNCTION  Error_Check  RETURN BOOLEAN ;



-- ******************************************************************

  END GL_FLATTEN_LEDGER_SEG_VALS;


 

/
