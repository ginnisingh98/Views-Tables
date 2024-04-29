--------------------------------------------------------
--  DDL for Package GL_CONS_SEGMENT_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_SEGMENT_MAP_PKG" AUTHID CURRENT_USER as
/* $Header: glicosrs.pls 120.7 2005/05/05 01:06:11 kvora ship $ */
--
-- Package
--   gl_cons_segment_map_pkg
-- Purpose
--   Package procedures for Consolidation Setup form,
--     Consolidation Segment Rules block
-- History
--   03-JAN-94	E Wilson	Created
--

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Insert new records into table GL_CONS_SEGMENT_MAP
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SEGMENT_MAP_PKG.Insert_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Segment_Map_Id                       IN OUT NOCOPY NUMBER,
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
  --   GL_CONS_SEGMENT_MAP_PKG.Lock_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                     X_Segment_Map_Id                         NUMBER,
                     X_Coa_Mapping_Id                         NUMBER,
                     X_To_Value_Set_Id                        NUMBER,
                     X_To_Application_Column_Name             VARCHAR2,
                     X_Segment_Map_Type                       VARCHAR2,
                     X_From_Value_Set_Id                      NUMBER,
                     X_From_Application_Column_Name           VARCHAR2,
                     X_Single_Value                           VARCHAR2,
                     X_Attribute1                             VARCHAR2,
                     X_Attribute2                             VARCHAR2,
                     X_Attribute3                             VARCHAR2,
                     X_Attribute4                             VARCHAR2,
                     X_Attribute5                             VARCHAR2,
                     X_Context                                VARCHAR2,
		     X_Parent_Rollup_Value                    VARCHAR2
                     );

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Update table GL_CONS_SEGMENT_MAP
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SEGMENT_MAP_PKG.Update_Row(<table columns>)
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
  --   GL_CONS_SEGMENT_MAP_PKG.Delete_Row(:SEGMENT_MAP.Row_Id)
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Segment_Map_Id NUMBER );

  --
  -- Procedure
  --   Check_Duplicate_Rules
  -- Purpose
  --   Check for duplicate consolidation segment map rules
  -- Arguments
  --   Segment_Map_Type            Type of segment rule - Rollup Ranges,
  --                               Single Value, or Copy Value
  --   Coa_Mapping_Id              COA Mapping ID
  --   To_Application_Column_Name  Parent segment column name
  --   To_Value_Set_Id             Parent segment column value set
  --   RowId                       Segment mapping rule row id
  -- Returns
  --   0   Success, no duplicates
  --   1   Overlap with different targets
  --
  --   If an overlap with the same target multiple times occurs, an exception
  --   is raised.
  -- Example
  --    Check_Duplicate_Rules(:SEGMENT_MAP.rowid,
  --                          :SEGMENT_MAP.Mapping_Id,
  --                          :SEGMENT_MAP.To_Application_Column_Name,
  --                          :SEGMENT_MAP.To_Value_Set_Id,
  --                          :SEGMENT_MAP.Segment_Map_Type)
  -- Notes
  --
  FUNCTION Check_Duplicate_Rules(X_Rowid   VARCHAR2,
                          X_Single_Value   VARCHAR2,
                   X_Parent_Rollup_Value   VARCHAR2,
                        X_Coa_Mapping_Id   NUMBER,
            X_To_Application_Column_Name   VARCHAR2,
          X_From_Application_Column_Name   VARCHAR2,
                       X_To_Value_Set_Id   NUMBER,
                     X_From_Value_Set_Id   NUMBER,
                      X_Segment_Map_Type   VARCHAR2) RETURN NUMBER;
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
  --   Check_Any_Parent_Rules
  -- Purpose
  --   Check to see whether there any summary rules defined
  -- Arguments
  --   X_Coa_Mapping_Id            Coa_Mapping_ID
  --   X_Parent_Rules_Present      Parent Rules Present
  -- Example
  --    Check_Any_Parent_Rules(X_Coa_Mapping_Id
  --                           X_Parent_Rules_Present)
  -- Notes
  --
  PROCEDURE Check_Any_Parent_Rules(X_Coa_Mapping_Id       IN OUT NOCOPY  NUMBER,
                                   X_Parent_Rules_Present IN OUT NOCOPY  VARCHAR2);

END GL_CONS_SEGMENT_MAP_PKG;

 

/
