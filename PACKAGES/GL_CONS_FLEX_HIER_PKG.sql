--------------------------------------------------------
--  DDL for Package GL_CONS_FLEX_HIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_FLEX_HIER_PKG" AUTHID CURRENT_USER as
/* $Header: glicocrs.pls 120.7 2005/05/05 01:04:46 kvora ship $ */
--
-- Package
--   gl_cons_flex_hierarchies_pkg
-- Purpose
--   Package procedures for Chart of Accounts Setup form,
--     Child Ranges block
-- History
--   03-JAN-94	E Wilson	Created
--   14-OCT-96	U Thimmappa     Added new functions
--

  --
  -- Procedure
  --   Overlap
  -- Purpose
  --   Check for overlapping child segment ranges
  -- Arguments
  --   rowid
  --   segment_map_id
  --   parent_flex_value
  --   child_flex_value_low
  --   child_flex_value_high
  -- Returns a number based on whether or not an overlap was found:
  --   0: success. No overlaps
  --   1: warning. The same source is mapped to two different targets
  --
  --   This raises an exception if one source is mapped to the same target
  --   multiple times.
  -- Notes
  --
  FUNCTION Overlap(X_Rowid                        VARCHAR2,
                   X_Segment_Map_Id		  NUMBER,
                   X_Coa_Mapping_Id		  NUMBER,
                   X_To_Value_Set_Id		  NUMBER,
                   X_From_Value_Set_Id		  NUMBER,
                   X_Segment_Map_Type             VARCHAR2,
                   X_To_Application_Column_Name   VARCHAR2,
                   X_From_Application_Column_Name VARCHAR2,
                   X_Parent_Flex_Value            VARCHAR2,
                   X_Child_Flex_Value_Low         VARCHAR2,
                   X_Child_Flex_Value_High        VARCHAR2
		  ) RETURN NUMBER;

  --
  -- Procedure
  --   Count_Ranges
  -- Purpose
  --   Verify that user has entered a range of accounts before committing
  --   a consolidation whose method type is Balances
  -- Arguments
  --   segment_map_id
  -- Notes
  --
  PROCEDURE Count_Ranges(X_Segment_Map_id       NUMBER);

  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Insert new records into table GL_CONS_FLEX_HIERARCHIES
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_CHILD_RANGES_PKG.Insert_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Segment_Map_Id                       IN OUT NOCOPY NUMBER,
                       X_Parent_Flex_Value                    VARCHAR2,
                       X_Child_Flex_Value_Low                 VARCHAR2,
                       X_Child_Flex_Value_High                VARCHAR2,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Attribute1                           VARCHAR2,
                       X_Attribute2                           VARCHAR2,
                       X_Attribute3                           VARCHAR2,
                       X_Attribute4                           VARCHAR2,
                       X_Attribute5                           VARCHAR2,
                       X_Context                              VARCHAR2
                       );

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   Lock records in table GL_CONS_CHILD_RANGES
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_CHILD_RANGES.Lock_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                     X_Segment_Map_Id                         NUMBER,
                     X_Parent_Flex_Value                      VARCHAR2,
                     X_Child_Flex_Value_Low                   VARCHAR2,
                     X_Child_Flex_Value_High                  VARCHAR2,
                     X_Last_Update_Date                       DATE,
                     X_Last_Updated_By                        NUMBER,
                     X_Creation_Date                          DATE,
                     X_Created_By                             NUMBER,
                     X_Last_Update_Login                      NUMBER,
                     X_Attribute1                             VARCHAR2,
                     X_Attribute2                             VARCHAR2,
                     X_Attribute3                             VARCHAR2,
                     X_Attribute4                             VARCHAR2,
                     X_Attribute5                             VARCHAR2,
                     X_Context                                VARCHAR2
                     );

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Update table GL_CONS_CHILD_RANGES
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_CHILD_RANGES_PKG.Update_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                                  VARCHAR2,
                       X_Segment_Map_Id                         NUMBER,
                       X_Parent_Flex_Value                      VARCHAR2,
                       X_Child_Flex_Value_Low                   VARCHAR2,
                       X_Child_Flex_Value_High                  VARCHAR2,
                       X_Last_Update_Date                       DATE,
                       X_Last_Updated_By                        NUMBER,
                       X_Creation_Date                          DATE,
                       X_Created_By                             NUMBER,
                       X_Last_Update_Login                      NUMBER,
                       X_Attribute1                             VARCHAR2,
                       X_Attribute2                             VARCHAR2,
                       X_Attribute3                             VARCHAR2,
                       X_Attribute4                             VARCHAR2,
                       X_Attribute5                             VARCHAR2,
                       X_Context                                VARCHAR2
                       );

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Update table GL_CONS_CHILD_RANGES
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_CHILD_RANGES_PKG.Update_Parent_Values(<table columns>)
  -- Notes
  --
  PROCEDURE Update_Parent_Values(
                       X_Segment_Map_Id                         NUMBER,
                       X_Parent_Flex_Value                      VARCHAR2,
                       X_Last_Update_Date                       DATE,
                       X_Last_Updated_By                        NUMBER,
                       X_Last_Update_Login                      NUMBER
                       );

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   Delete records from table GL_CONS_CHILD_RANGES
  -- Arguments
  --   Row_Id     Rowid of row to be deleted
  -- Example
  --   GL_CONS_CHILD_RANGES_PKG.Delete_Row(:SEGMENT_MAP.Row_Id)
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Segment_Map_Id NUMBER );

END GL_CONS_FLEX_HIER_PKG;

 

/
