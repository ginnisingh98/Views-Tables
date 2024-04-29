--------------------------------------------------------
--  DDL for Package GL_FLATTEN_ACCESS_SETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FLATTEN_ACCESS_SETS" AUTHID CURRENT_USER AS
/* $Header: gluflass.pls 120.3 2005/05/05 01:38:08 kvora ship $ */

-- ********************************************************************
-- Function
--   Fix_Explicit_Sets
-- Purpose
--   This routine will process all changes to explicit access sets
--   made through the form.
-- History
--   07-24-2001       	S Kung		Created
-- Arguments
--   None
-- Example
--   ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets;
--

  FUNCTION  Fix_Explicit_Sets RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Fix_Implicit_Sets
-- Purpose
--   This routine will call other routines to process all changes
--   to the implicit access sets due to changes in the ledger hierarchy
-- History
--   07-24-2001		S Kung		Created
-- Arguments
--   Any_Ledger_Hier_Changes  BOOLEAN indicating if ledger hierarchy
--                            has changed
-- Example
--   ret_status := GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets(TRUE);
--

  Function  Fix_Implicit_Sets(Any_Ledger_Hier_Changes BOOLEAN)
							RETURN BOOLEAN;

-- *****************************************************************
-- Function
--   Fix_Norm_Table
-- Purpose
--   This routine will populate changes in the ledger hierarchy to
--   the GL_ACCESS_SET_NORM_ASSIGN table.
-- History
--   07-24-2001		S Kung		Created
-- Arguments
--   Ledgers_And_Hier	BOOLEAN indicating if routine needs to process both
--                      new ledgers and ledger hierarchy changes.
-- Example
--   ret_status := GL_FLATTEN_ACCESS_SETS.Fix_Norm_Table(FALSE);
--

  Function  Fix_Norm_Table(Ledgers_And_Hier BOOLEAN) RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Fix_Flattened_Table
-- Purpose
--   This routine will populate changes to the ledger hierarchy to
--   the GL_ACCESS_SET_ASSIGNMENTS table.
-- History
--   07-18-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table;
--

  Function  Fix_Flattened_Table RETURN BOOLEAN;


-- ******************************************************************
-- Function
--   Populate_Temp_Table
-- Purpose
--   This routine will populate the temporary table
--   GL_ACCESS_SET_ASSIGN_INT with changes to access set assignments
--   based on different modes of operation.  Such information will
--   be used to populate GL_ACCESS_SET_ASSIGNMENTS later.
-- History
--   07-24-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_ACCESS_SETS.Populate_Temp_Table;
--

  Function  Populate_Temp_Table RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Enable_Record
-- Purpose
--   This routine will process all access set assignments in
--   GL_ACCESS_SET_ASSIGN_INT and enable/disable records.
-- History
--   07-24-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_ACCESS_SETS.Enable_Record;
--

  Function  Enable_Record RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Clean_Up_By_Coa
-- Purpose
--   This routine will set access set data to the current status.
-- History
--   07-18-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa;
--

  Function  Clean_Up_By_Coa RETURN BOOLEAN;

-- ******************************************************************

END GL_FLATTEN_ACCESS_SETS;


 

/
