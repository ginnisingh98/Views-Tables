--------------------------------------------------------
--  DDL for Package GL_FLEXFIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FLEXFIELDS_PKG" AUTHID CURRENT_USER AS
/*  $Header: glumsfls.pls 120.8 2006/04/03 17:00:38 cma ship $ */
--
-- Package
--   gl_flexfields_pkg
-- Purpose
--   This package contains various flexfields utilities.
--   This package should eventually be outdated by AOL provided
--   PL/SQL and/or user exits
--
-- History
--   12-17-93   D J Ogg		Created
--

  --
  -- Exceptions
  --
  -- User defined exceptions for gl_seg_val_desc:
  -- o INVALID_SEGNUM   - User has passed in invalid combination of
  --                      chart of account id and segment number.
  --
  INVALID_SEGNUM      EXCEPTION;


  --
  -- Procedure
  --   get_account_segment
  -- Purpose
  --   Gets the name of the account segment for this chart of accounts
  -- History
  --   12-17-93  D. J. Ogg    Created
  -- Arguments
  --   coa_id		The chart of accounts id
  -- Example
  --   acctseg := gl_budget_entities_pkg.get_account_segment(101);
  -- Notes
  --
  FUNCTION get_account_segment(coa_id NUMBER) RETURN VARCHAR2;

   --
  -- Procedure
  --   get_description
  --
  -- Purpose
  --   Gets the description for an account or balancing segment value
  --
  -- History
  --   13-Jan-97  D J Ogg 	Created
  --
  -- Arguments
  --   x_coa_id 		ID of the current chart of accounts
  --   x_qual_text		GL_ACCOUNT or GL_BALANCING
  --   x_segment_val		Segment value
  FUNCTION get_description(
	      x_coa_id					NUMBER,
	      x_qual_text				VARCHAR2,
	      x_segment_val				VARCHAR2
	   ) RETURN VARCHAR2;

  --
  -- Procedure
  --   get_any_seg_description
  --
  -- Purpose
  --   Gets the description for any segment value
  --
  -- History
  --   01-Dec-98  K Vora 	Created
  --
  -- Arguments
  --   x_coa_id 		ID of the current chart of accounts
  --   x_qual_text		GL_ACCOUNT or GL_BALANCING
  --   x_segment_val		Segment value
  --   x_seg_num                Segment position
  FUNCTION get_any_seg_description(
	      x_coa_id					NUMBER,
	      x_qual_text				VARCHAR2,
	      x_segment_val				VARCHAR2,
              x_seg_num                                 NUMBER
	   ) RETURN VARCHAR2;


  -- Procedure
  --   get_coa_name
  --
  -- Purpose
  --   Gets the Chart of Accounts name
  --
  -- History
  --   26-Feb-98   S Kung	Created
  --
  -- Arguments
  --   coa_id			Chart of Accounts ID
  FUNCTION get_coa_name(coa_id	NUMBER) RETURN VARCHAR2;

  --   Procedure
  --     get_coa_info
  --   Purpose
  --     Gets various chart of accounts attributes based on
  --     the coa id provided.
  --   History
  --     11-12-93   K Vora      Created
  --   Arguments
  --     x_chart_of_accounts_id  ID of the chart of accounts
  --     <segment information>
  --   Example
  --     GL_FLEXFIELDS_PKG.get_coa_info(50134, <variables>);
  --
  PROCEDURE get_coa_info (x_chart_of_accounts_id    IN     NUMBER,
                          x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                          x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                          x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                          x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_ieaseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_left_prompt      IN OUT NOCOPY VARCHAR2);

  --
  -- Function
  --    get_sd_description_sql
  -- PURPOSE
  --    wrapper function to call get_description_sql to get
  --    segment value description for gl_oasis_summary_data_v
  -- History
  --    Jun-28-99       Maria Hui       Created
  -- Arguments
  --    x_coa_id        Number          Chart of account id.
  --    x_pos		Number          Indicate whether it is getting
  --					description for balancing segment (1)
  --					or drilldown segment (2).
  --    x_seg_num       Number          Segment number.
  --    x_seg_val       Varchar2        Segment value.
  -- Returns
  --    Segment value description (Varchar2)
  -- Example
  --     GL_FLEXFIELDS_PKG.get_sd_description_sql(101, 1, 3, '1110');
  -- Notes
  --

    FUNCTION get_sd_description_sql (
            x_coa_id    IN NUMBER,
            x_pos       IN NUMBER,
            x_seg_num   IN NUMBER,
            x_seg_val   IN VARCHAR2 ) RETURN VARCHAR2;


  --
  -- Function
  --    get_description_sql
  -- PURPOSE
  --    get segment value description
  -- History
  --    Jun-24-99       Maria Hui       Created
  -- Arguments
  --    x_coa_id        Number          Chart of account id.
  --    x_seg_num       Number          Segment number.
  --    x_seg_val       Varchar2        Segment value.
  -- Returns
  --    Segment value description (Varchar2)
  -- Example
  --    gl_seg_val_desc.get_description_sql(101, 3, '1110');
  -- Notes
  --
    FUNCTION get_description_sql (
            		x_coa_id    	IN NUMBER,
                        x_seg_num       IN NUMBER,
                        x_seg_val       IN VARCHAR2 ) RETURN VARCHAR2;

  --
  -- Function
  --    get_summary_flag
  -- Purpose
  --    Get the summary flag for the segment value in the given value set
  -- History
  --    Feb-28-2001	T Cheng		Created
  -- Arguments
  --    x_value_set_id		the value set id
  --    x_segment_value		the value to be examined
  -- Notes
  --
  FUNCTION get_summary_flag(x_value_set_id   NUMBER,
                            x_segment_value  VARCHAR2) RETURN VARCHAR2;


  --
  -- Function
  --    get_parent_from_children
  -- PURPOSE
  --    Determines the direct parent of a child range given
  --    the child range, an ancestor of the child range, and
  --    the value set id
  -- History
  --    08-APR-2002	D J Ogg		Created
  -- Arguments
  --    vs_id		Value Set id
  --    ancestor	Ancestor of the child range
  --    child_low	Low value of the child range
  --    child_high      High value of the child range
  --    parent_num      If child range has multiple parents,
  --                    which one to pick
  -- Returns
  --    Direct parent of the child range
  -- Example
  --    x:=gl_flexfields_pkg.get_parent_from_children(50, 'A', '100', '150', 1)
  -- Notes
  --
    FUNCTION get_parent_from_children(
			vs_id		IN NUMBER,
			ancestor	IN VARCHAR2,
			child_low	IN VARCHAR2,
			child_high	IN VARCHAR2,
			parent_num	IN NUMBER) RETURN VARCHAR2;

  --
  -- Function
  --    get_concat_description
  -- PURPOSE
  --    Retrieves the concatenated account description.
  -- History
  --    08-DEC-2004	K Vora 		Created
  -- Arguments
  --    x_coa_id                  Chart of accounts id
  --    x_ccid                    Code combination id
  --    x_enforce_value_security  Whether to enforce segment security, Y or N.
  -- Returns
  --    Concatenated account description
  -- Example
  --    descp := gl_flexfields_pkg.get_concat_description(101, 13131)
  -- Notes
  --    If x_enforce_value_security = 'Y' and the account is secured, the
  --    function will return a string not likely to be a valid description.
  --    It's the caller's responsibility to check the value before using it.
  --
  FUNCTION Get_Concat_Description(
                   x_coa_id                  NUMBER,
                   x_ccid                    NUMBER,
                   x_enforce_value_security  VARCHAR2 DEFAULT 'Y'
                   ) RETURN VARCHAR;

  --
  -- Function
  --    get_qualifier_segnum
  -- PURPOSE
  --    Retrieves the segment number corresponding to the qualifier name entered.
  -- DESCRIPTION
  --   	Gets the segment number corresponding to the **UNIQUE** qualifier
  --   	name entered.  Segment number is the display order of the segment
  --   	not to be confused with the SEGMENT_NUM column of the
  -- 	  FND_ID_FLEX_SEGMENTS table.  Returns segment_number if ok,
  -- 	  otherwise 0.
  -- History
  --    06-APR-2005	A Desu  Created
  -- Arguments
  --    x_key_flex_code        IN  VARCHAR2
  --    x_chart_of_accounts_id IN  NUMBER
  --    x_flex_qual_name       IN  VARCHAR2
  -- Returns
  --    Segment number
  -- Example
  --    seg_num := gl_flexfields_pkg.get_qualifier_segnum('GL#', 13131, '01-000-1100')
  -- Notes
  --
  FUNCTION get_qualifier_segnum(
                      x_key_flex_code        VARCHAR2,
                      x_chart_of_accounts_id NUMBER,
                      x_flex_qual_name       VARCHAR2) RETURN NUMBER;


  --
  -- Function
  --   get_validation_error_message
  -- PURPOSE
  --   Validate value security and return the error message if account is
  --   secured.
  -- History
  --   12-AUG-2005	T Cheng		Created
  -- Arguments
  --   x_ccid		Code combination id
  -- Returns
  --   The error message if validation did not pass, otherwise null.
  -- Example
  --   errmsg := gl_flexfields_pkg.get_validation_error_message(101, 12831);
  -- Notes
  --
  FUNCTION get_validation_error_message(x_coa_id    NUMBER,
                                        x_ccid      NUMBER) RETURN VARCHAR;

END gl_flexfields_pkg;

 

/
