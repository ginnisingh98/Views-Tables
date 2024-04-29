--------------------------------------------------------
--  DDL for Package GL_CONS_SEGMENT_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_SEGMENT_ACTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: glicosas.pls 120.5 2005/05/05 01:05:57 kvora ship $ */
--
-- Package
--   GL_CONS_SEGMENT_ACTIONS_PKG
-- Purpose
--   Package procedures for Chart of Accounts Mapping Setup form,
--     Chart of Accounts Mapping Segment Actions block
-- History
--   19-Feb-97	U Thimmappa	Created
--

--
-- PUBLIC VARIABLES
--
	coa_mapping_id			NUMBER;
	to_chart_of_accounts_id		NUMBER;
	from_chart_of_accounts_id	NUMBER;
--

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Insert new records into table GL_CONS_SEGMENT_MAP
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SEGMENT_ACTIONS_PKG.Insert_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Segment_Map_Id                IN OUT NOCOPY NUMBER,
                       X_Coa_Mapping_Id                       NUMBER,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_To_Value_Set_Id                      NUMBER,
                       X_To_Application_Column_Name           VARCHAR2,
                       X_Segment_Map_Type                     VARCHAR2,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_From_Value_Set_Id                    NUMBER,
                       X_From_Application_Column_Name         VARCHAR2,
                       X_Single_Value                         VARCHAR2,
                       X_Attribute1                           VARCHAR2,
                       X_Attribute2                           VARCHAR2,
                       X_Attribute3                           VARCHAR2,
                       X_Attribute4                           VARCHAR2,
                       X_Attribute5                           VARCHAR2,
                       X_Context                              VARCHAR2,
		       X_Parent_Rollup_Value                  VARCHAR2
                       );

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   Lock records in table GL_CONS_SEGMENT_MAP
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SEGMENT_ACTIONS_PKG.Lock_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                     X_Segment_Map_Id                         NUMBER
                     );

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Update table GL_CONS_SEGMENT_MAP
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SEGMENT_ACTIONS_PKG.Update_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                       X_Segment_Map_Id                      NUMBER,
                       X_Coa_Mapping_Id                      NUMBER,
                       X_Last_Update_Date                    DATE,
                       X_Last_Updated_By                     NUMBER,
                       X_To_Value_Set_Id                     NUMBER,
                       X_To_Application_Column_Name          VARCHAR2,
                       X_Segment_Map_Type                    VARCHAR2,
                       X_Last_Update_Login                   NUMBER,
                       X_From_Value_Set_Id                   NUMBER,
                       X_From_Application_Column_Name        VARCHAR2,
                       X_Single_Value                        VARCHAR2,
                       X_Attribute1                          VARCHAR2,
                       X_Attribute2                          VARCHAR2,
                       X_Attribute3                          VARCHAR2,
                       X_Attribute4                          VARCHAR2,
                       X_Attribute5                          VARCHAR2,
                       X_Context                             VARCHAR2,
		       X_Parent_Rollup_Value                 VARCHAR2
                       );

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   Delete records from table GL_CONS_SEGMENT_MAP
  -- Arguments
  --   Row_Id     Rowid of row to be deleted
  -- Example
  --   GL_CONS_SEGMENT_ACTIONS_PKG.Delete_Row(:SEGMENT_MAP.Row_Id)
  -- Notes
  --
  PROCEDURE Delete_Row( X_Coa_Mapping_Id NUMBER, X_to_application_column_name VARCHAR2 );

  --
  -- Procedure
  --   Check_Duplicate_Rules
  -- Purpose
  --   Check for duplicate chart of accounts segment map rules
  -- Arguments
  --   Segment_Map_Type            Type of segment rule - Rollup Ranges,
  --                               Single Value, or Copy Value
  --   Coa_Mapping_Id              Chart of Accounts Mapping Id
  --   To_Application_Column_Name  Parent segment column name
  --   To_Value_Set_Id             Parent segment column value set
  --   RowId                       Segment mapping rule row id
  -- Example
  --    Check_Duplicate_Rules(:SEGMENT_MAP.rowid,
  --                          :SEGMENT_MAP.Coa_Mapping_Id,
  --                          :SEGMENT_MAP.To_Application_Column_Name,
  --                          :SEGMENT_MAP.To_Value_Set_Id,
  --                          :SEGMENT_MAP.Segment_Map_Type)
  -- Notes
  --
  PROCEDURE Check_Duplicate_Rules(X_Rowid   VARCHAR2,
                           X_Single_Value   VARCHAR2,
                    X_Parent_Rollup_Value   VARCHAR2,
                         X_Coa_Mapping_Id   NUMBER,
             X_To_Application_Column_Name   VARCHAR2,
           X_From_Application_Column_Name   VARCHAR2,
                        X_To_Value_Set_Id   NUMBER,
                      X_From_Value_Set_Id   NUMBER,
                       X_Segment_Map_Type   VARCHAR2);
  --
  -- Procedure
  --   Get_Validation_Type
  -- Purpose
  --   Get the validation type for segment value when rule is
  --   Single Value
  -- Arguments
  --   To_Value_Set_Id             Parent segment column value set
  --   Validation_Type             Validation type return value
  -- Example
  --    Get_Validation_Type(:SEGMENT_MAP.To_Value_Set_Id,
  --                        :SEGMENT_MAP.Validation_Type)
  -- Notes
  --
  PROCEDURE Get_Validation_Type(X_To_Value_Set_Id          NUMBER,
                                X_Validation_Type  IN OUT NOCOPY  VARCHAR2);
  --
  -- Procedure
  -- set_criteria
  --  PURPOSE sets ALL (non-secondary) the package (global) variables
  -- History: 19-Feb-97  U Thimmappa  Created
  -- Arguments: All the global values of this package
  -- Notes:
  PROCEDURE set_criteria (X_coa_mapping_id 	    	NUMBER,
       			  X_to_chart_of_accounts_id    	NUMBER,
        		  X_from_chart_of_accounts_id  	NUMBER);

  --
  -- Function
  --   Validate_From_Segment
  -- Purpose
  --   Validate that the value set of the "From" subsidiary segment has a
  --   less than or equal maximum size as the value set of the
  --   "To" parent segment.
  -- History
  --   13-Jun-01	T Cheng		Created
  --   01-Aug-02        T Cheng         Now returns BOOLEAN
  -- Arguments
  --   X_from_value_set_id     from_segment's value set id
  --   X_to_value_set_id       to_segment's value set id
  -- Notes
  --
  FUNCTION Validate_From_Segment (X_from_value_set_id   NUMBER,
				  X_to_value_set_id     NUMBER) RETURN BOOLEAN;

--
-- PUBLIC FUNCTIONS
--
  --
  -- Procedure
  --  get_coa_mapping_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History: 19-Feb-97  U Thimmappa  Created
  -- Notes
  --
	FUNCTION	get_coa_mapping_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_coa_mapping_id,WNDS,WNPS);

  --
  -- Procedure
  --  get_to_coa_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History: 19-Feb-97  U Thimmappa  Created
  -- Notes
  --
	FUNCTION	get_to_coa_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_to_coa_id,WNDS,WNPS);
  --
  -- Procedure
  --  get_from_coa_id
  --   PURPOSE gets the package (global) variable, USED in base view's where part
  -- History: 19-Feb-97  U Thimmappa  Created
  -- Notes
  --
	FUNCTION	get_from_coa_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_from_coa_id,WNDS,WNPS);

END GL_CONS_SEGMENT_ACTIONS_PKG;

 

/
