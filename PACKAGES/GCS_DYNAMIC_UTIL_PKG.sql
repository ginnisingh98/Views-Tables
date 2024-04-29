--------------------------------------------------------
--  DDL for Package GCS_DYNAMIC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DYNAMIC_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdynutils.pls 120.1 2005/10/30 05:17:53 appldev noship $ */


  -- Definition of Global Data Types and Variables

   -- Action types for writing module information to the log file.
--   g_module_enter         CONSTANT VARCHAR2 (2)  := '>>';
--   g_module_success       CONSTANT VARCHAR2 (2)  := '<<';
--   g_module_failure       CONSTANT VARCHAR2 (2)  := '<x';
   -- A newline character. Included for convenience when writing long strings.
--   g_nl                   CONSTANT VARCHAR2 (1)  := fnd_global.local_chr(10);

   g_applsys_username     VARCHAR2(30);


  --
  -- Procedure
  --   Build_Comma_List
  -- Purpose
  --   Build a list of the dimensions, delimited by commas. Use
  --   p_default_text if the dimension is not used.
  --   It is useful to build the columns for a Select, Order By or Group By.
  -- Arguments
  --   p_prefix		The prefix to put on the dimensions
  --   p_suffix		The suffix to put on the dimensions
  --   p_default_text	The text to be inserted for the dim. not required case
  --   p_first_rownum	The first row number to use for ad_ddl
  -- Example
  --   GCS_DYNAMIC_UTIL_PKG.Build_Comma_List('g.', '', '', 123);
  -- Notes
  --   1. If p_default_text is not null, it must include the ',' at the end.
  --   2. Returns the line number for the next row after the list.
  --
  FUNCTION Build_Comma_List(p_prefix		VARCHAR2,
			    p_suffix		VARCHAR2,
			    p_default_text	VARCHAR2,
			    p_first_rownum	NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   Build_Join_List
  -- Purpose
  --   Build a list of the dimension join conditions, delimited by commas.
  --   Skip if the dimension is not used.
  --   It is useful to build the join conditions for the Where clauses.
  -- Arguments
  --   p_left		The text to put before the left dimension
  --   p_middle		The text to put between the two dimensions
  --   p_right		The text to put after the right dimension
  --   p_first_rownum	The first row number to use for ad_ddl
  -- Example
  --   GCS_DYNAMIC_UTIL_PKG.Build_Join_List('AND g.', ' = h.', '', 123);
  -- Notes
  --   Returns the line number for the next row after the list.
  --
  FUNCTION Build_Join_List(p_left		VARCHAR2,
			   p_middle		VARCHAR2,
			   p_right		VARCHAR2,
			   p_first_rownum	NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   Build_Fem_Comma_List
  -- Purpose
  --   Build a list of the dimensions, delimited by commas. Use
  --   p_default_text if the dimension is not used.
  --   It is useful to build the columns for a Select, Order By or Group By.
  -- Arguments
  --   p_prefix		The prefix to put on the dimensions
  --   p_suffix		The suffix to put on the dimensions
  --   p_default_text	The text to be inserted for the dim. not required case
  --   p_first_rownum	The first row number to use for ad_ddl
  --   p_value_req      Default value required or not
  -- Example
  --   GCS_DYNAMIC_UTIL_PKG.Build_Fem_Comma_List('g.', '', '', 123, 'N');
  -- Notes
  --   1. If p_default_text is not null, it must include the ',' at the end.
  --   2. Returns the line number for the next row after the list.
  --
  FUNCTION Build_Fem_Comma_List(p_prefix		VARCHAR2,
			    p_suffix		VARCHAR2,
			    p_default_text	VARCHAR2,
			    p_first_rownum	NUMBER,
                            p_value_req         VARCHAR2) RETURN NUMBER;


  --
  -- Procedure
  --   Build_interco_Comma_List
  -- Purpose
  --   Build a list of the dimensions, delimited by commas. Use
  --   p_default_text if the dimension is not used.
  --   It is useful to build the columns for a Select, Order By or Group By.
  -- Arguments
  --   p_prefix		The prefix to put on the dimensions
  --   p_suffix		The suffix to put on the dimensions
  --   p_default_text	The text to be inserted for the dim. not required case
  --   p_first_rownum	The first row number to use for ad_ddl
  -- Example
  --   GCS_DYNAMIC_UTIL_PKG.Build_interco_Comma_List('g.', '', '', 123);
  -- Notes
  --   1. If p_default_text is not null, it must include the ',' at the end.
  --   2. Returns the line number for the next row after the list.
  --
  FUNCTION Build_interco_Comma_List( p_pre_prefix		VARCHAR2,
                            p_prefix		VARCHAR2,
                            P_post_prefix        VARCHAR2,
                            p_pre_suffix        VARCHAR2,
			    p_suffix		VARCHAR2,
                            p_post_suffix       VARCHAR2,
			    p_default_text	VARCHAR2,
			    p_first_rownum	NUMBER) RETURN NUMBER;

  -- Function
  --   Index_Col_List
  -- Purpose
  --   Build a list of the dimensions required by GCS , delimited by commas.
  --   Its used for listing the columns when creating the dynamic indexes
  -- Arguments
  --   collist          Contains the concatenated list of columns
  -- Example
  --   GCS_DYNAMIC_UTIL_PKG.Index_Col_List( collist);
  --
  FUNCTION Index_Col_List( collist OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

END GCS_DYNAMIC_UTIL_PKG;

 

/
