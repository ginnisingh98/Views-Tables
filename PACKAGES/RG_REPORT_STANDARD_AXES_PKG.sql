--------------------------------------------------------
--  DDL for Package RG_REPORT_STANDARD_AXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_STANDARD_AXES_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirstds.pls 120.3 2003/08/13 10:42:10 nkasu ship $ */
--
-- Name
--   rg_report_standard_axes_pkg
-- Purpose
--   to include all sever side procedures and packages for table
--   rg_report_standard_axes
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
--
-- Procedures

-- Name
--   select_row
-- Purpose
--   querying a row
-- Arguments
--   recinfo        record inforation
--
PROCEDURE select_row(recinfo in out NOCOPY rg_report_standard_axes_tl%ROWTYPE);

-- Name
--   select_columns
-- Purpose
--   querying columns from a row for populating non-database fields
--   in POST-QUERY
-- Arguments
--   recinfo        record inforation
PROCEDURE select_columns(X_standard_axis_id NUMBER,
                         X_name IN OUT NOCOPY VARCHAR2);

--
-- Name
--   insert_row
-- Purpose
--   Insert a row into RG_REPORT_STANDARD_AXES
--
PROCEDURE insert_row(  X_rowid                 IN OUT NOCOPY   VARCHAR2,
		       X_application_id			NUMBER,
                       X_last_update_date               DATE,
                       X_last_updated_by                NUMBER,
                       X_last_update_login              NUMBER,
                       X_creation_date                  DATE,
                       X_created_by                     NUMBER,
		       X_standard_axis_id		NUMBER,
  		       X_standard_axis_name		VARCHAR2,
  		       X_class				VARCHAR2,
     		       X_display_in_std_list_flag 	VARCHAR2,
                       X_precedence_level		NUMBER,
  		       X_database_column		VARCHAR2,
  		       X_simple_where_name		VARCHAR2,
  		       X_period_query			VARCHAR2,
  		       X_standard_axis1_id		NUMBER,
  		       X_axis1_operator			VARCHAR2,
                       X_standard_axis2_id		NUMBER,
  		       X_axis2_operator			VARCHAR2,
                       X_constant			NUMBER,
  		       X_variance_flag 			VARCHAR2,
		       X_sign_flag			VARCHAR2,
 		       X_description	                VARCHAR2 );

--
-- Name
--   update_row
-- Purpose
--   Update a row in RG_REPORT_STANDARD_AXES
--
PROCEDURE update_row(  X_rowid                   IN OUT NOCOPY VARCHAR2,
	               X_application_id			NUMBER,
		       X_standard_axis_id		NUMBER,
  		       X_standard_axis_name		VARCHAR2,
                       X_last_update_date        	DATE,
                       X_last_updated_by                NUMBER,
                       X_last_update_login              NUMBER,
  		       X_class				VARCHAR2,
     		       X_display_in_std_list_flag 	VARCHAR2,
                       X_precedence_level		NUMBER,
  		       X_database_column		VARCHAR2,
  		       X_simple_where_name		VARCHAR2,
  		       X_period_query			VARCHAR2,
  		       X_standard_axis1_id		NUMBER,
  		       X_axis1_operator			VARCHAR2,
                       X_standard_axis2_id		NUMBER,
  		       X_axis2_operator			VARCHAR2,
                       X_constant			NUMBER,
  		       X_variance_flag 			VARCHAR2,
		       X_sign_flag			VARCHAR2,
 		       X_description	                VARCHAR2 );

--
-- Name
--   Load_Row
-- Purpose
--   Load a row in RG_REPORT_STANDARD_AXES for NLS support
--

PROCEDURE Load_Row (   X_Application_Id			NUMBER,
		       X_Standard_Axis_Id		NUMBER,
  		       X_Class				VARCHAR2,
     		       X_Display_In_Std_List_Flag 	VARCHAR2,
                       X_Precedence_Level		NUMBER,
  		       X_Database_Column		VARCHAR2,
  		       X_Simple_Where_Name		VARCHAR2,
  		       X_Period_Query			VARCHAR2,
  		       X_Standard_Axis1_Id		NUMBER,
  		       X_Axis1_Operator			VARCHAR2,
                       X_Standard_Axis2_Id		NUMBER,
  		       X_Axis2_Operator			VARCHAR2,
                       X_Constant			NUMBER,
  		       X_Variance_Flag 			VARCHAR2,
		       X_Sign_Flag			VARCHAR2,
  		       X_Standard_Axis_Name		VARCHAR2,
 		       X_Description                    VARCHAR2,
		       X_Owner				VARCHAR2,
		       X_Force_Edits			VARCHAR2 );

--
-- Name
--   Translate_Row
-- Purpose
--   Translate a row in RG_REPORT_STANDARD_AXES for NLS support
--
PROCEDURE Translate_Row (
                       X_Standard_Axis_Name VARCHAR2,
                       X_Description        VARCHAR2,
	               X_Standard_Axis_Id   NUMBER,
                       X_Owner              VARCHAR2,
	               X_Force_Edits        VARCHAR2 );

 --
  -- Procedure
  --  Add_Language
  -- Purpose
  --   To add a new language row to the rg_report_standrad_axes_b
  -- History
  --   29-JUL-03  N Kasu	Created
  -- Arguments
  -- 	None
  -- Example
  --   rg_report_standard_axes_pkg.Add_Language(....;
  -- Notes
  --
procedure ADD_LANGUAGE;

END RG_REPORT_STANDARD_AXES_PKG;

 

/
