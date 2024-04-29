--------------------------------------------------------
--  DDL for Package JG_GL_ACCT_HIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_GL_ACCT_HIER_PKG" AUTHID CURRENT_USER AS
/* $Header: jgglachs.pls 120.1.12010000.1 2008/07/28 07:54:49 appldev ship $ */

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   populate_acct_hier_table
  -- Purpose
  --   Populate the account hierarchy temporary table.
  -- Parameter
  --   p_value_set_id		Account Segment Value Set ID
  --   p_top_parent_acct        The Top Level Parent Account Value
  -- Note
  --   Must be called before attempting to retrieve level account value/desc.
  --
  PROCEDURE populate_acct_hier_table(p_value_set_id	IN NUMBER,
                                     p_top_parent_acct	IN VARCHAR2);

  --
  -- Function
  --   get_level_acct_value
  -- Purpose
  --   Get the specified level's account value.
  -- Parameter
  --   p_value_set_id		Account Segment Value Set ID
  --   p_report_acct_level	Account Level for the Report
  --   p_detail_acct		The Detail Account Value
  --   p_detail_acct_desc	The Detail Account Value Description
  --   p_acct_delimiter		Account Delimiter
  --   p_level			Level of the Requested Value
  -- Note
  --
  FUNCTION get_level_acct_value(p_value_set_id		IN NUMBER,
                                p_report_acct_level	IN NUMBER,
                                p_detail_acct		IN VARCHAR2,
                                p_detail_acct_desc	IN VARCHAR2,
                                p_acct_delimiter	IN VARCHAR2,
                                p_level			IN NUMBER)
      RETURN VARCHAR2;

  --
  -- Function
  --   get_level_acct_desc
  -- Purpose
  --   Get the specified level's account value description.
  -- Parameter
  --   p_value_set_id		Account Segment Value Set ID
  --   p_report_acct_level	Account Level for the Report
  --   p_detail_acct		The Detail Account Value
  --   p_detail_acct_desc	The Detail Account Value Description
  --   p_acct_delimiter		Account Delimiter
  --   p_level			Level of the Requested Value Description
  -- Note
  --
  FUNCTION get_level_acct_desc(p_value_set_id		IN NUMBER,
                               p_report_acct_level	IN NUMBER,
                               p_detail_acct		IN VARCHAR2,
                               p_detail_acct_desc	IN VARCHAR2,
                               p_acct_delimiter		IN VARCHAR2,
                               p_level			IN NUMBER)
      RETURN VARCHAR2;

  --
  -- Function
  --   get_delimited_detail_acct
  -- Purpose
  --   Get the detail account value with delimiters.
  -- Parameter
  --   p_value_set_id		Account Segment Value Set ID
  --   p_report_acct_level	Account Level for the Report
  --   p_detail_acct		The Detail Account Value
  --   p_detail_acct_desc	The Detail Account Value Description
  --   p_acct_delimiter		Account Delimiter
  -- Note
  --
  FUNCTION get_delimited_detail_acct(p_value_set_id		IN NUMBER,
                                     p_report_acct_level	IN NUMBER,
                                     p_detail_acct		IN VARCHAR2,
                                     p_detail_acct_desc		IN VARCHAR2,
                                     p_acct_delimiter		IN VARCHAR2)
      RETURN VARCHAR2;

END JG_GL_ACCT_HIER_PKG;

/
