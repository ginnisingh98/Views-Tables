--------------------------------------------------------
--  DDL for Package GL_FLATTEN_LEDGER_SETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FLATTEN_LEDGER_SETS" AUTHID CURRENT_USER AS
/* $Header: glufllss.pls 120.4 2005/05/05 01:38:21 kvora ship $ */

-- ********************************************************************
-- Function
--   Fix_Explicit_Sets
-- Purpose
--   This routine will process all changes to explicit ledger sets
--   made through the form.
-- History
--   07-18-2001       	S Kung		Created
-- Arguments
--   None
-- Example
--   ret_val := GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets;
--

  FUNCTION  Fix_Explicit_Sets RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Fix_Implicit_Sets
-- Purpose
--   This routine will call other routines to process all changes
--   to the implicit ledger sets due to changes in the ledger hierarchy
-- History
--   07-18-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_LEDGER_SETS.Fix_Implicit_Sets;
--

--  Function  Fix_Implicit_Sets RETURN BOOLEAN;

-- *****************************************************************
-- Function
--   Fix_Norm_Table
-- Purpose
--   This routine will populate changes in the ledger hierarchy to
--   the GL_LEDGER_SET_NORM_ASSIGN table.
-- History
--   07-18-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_LEDGER_SETS.Fix_Norm_Table;
--

--  Function  Fix_Norm_Table RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Fix_Flattened_Table
-- Purpose
--   This routine will populate changes to the ledger hierarchy to
--   the GL_LEDGER_SET_ASSIGNMENTS table.
-- History
--   07-18-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_LEDGER_SETS.Fix_Flattened_Table;
--

--  Function  Fix_Flattened_Table RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Clean_Up_Explicit_Sets
-- Purpose
--   This routine will set explicit ledger set data to the current
--   status.
-- History
--   07-18-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets;
--

  Function  Clean_Up_Explicit_Sets RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Clean_Up_Implicit_Sets
-- Purpose
--   This routine will set implicit ledger set data to the current
--   status.
-- History
--   07-18-2001		S Kung		Created
-- Arguments
--   None
-- Example
--   ret_status := GL_FLATTEN_LEDGER_SETS.Clean_Up_Implicit_Sets;
--

--  Function  Clean_Up_Implicit_Sets RETURN BOOLEAN;

-- ******************************************************************

END GL_FLATTEN_LEDGER_SETS;


 

/
