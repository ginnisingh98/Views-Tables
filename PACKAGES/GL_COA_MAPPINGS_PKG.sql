--------------------------------------------------------
--  DDL for Package GL_COA_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_COA_MAPPINGS_PKG" AUTHID CURRENT_USER as
/* $Header: glicoams.pls 120.3 2005/05/05 01:04:16 kvora ship $ */
--
-- Package
--   gl_coa_mappings_pkg
-- Purpose
--   Package procedures for Chart of Accounts Mapping form,
--     Mapping block
-- History
--   07/19/02   M Ward        Created
--

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Insert new records into table GL_COA_MAPPINGS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_COA_MAPPINGS_PKG.Insert_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                       X_Coa_Mapping_Id                       IN OUT NOCOPY NUMBER,
                       X_To_Coa_Id                            NUMBER,
                       X_From_Coa_Id                          NUMBER,
                       X_Name                                 VARCHAR2,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Description                          VARCHAR2,
                       X_Start_Date_Active                    DATE,
                       X_End_Date_Active                      DATE,
                       X_Security_Flag                        VARCHAR2
                       );

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   Lock records in table GL_COA_MAPPINGS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_COA_MAPPINGS_PKG.Lock_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                     X_Coa_Mapping_Id                       IN OUT NOCOPY NUMBER,
                     X_To_Coa_Id                            NUMBER,
                     X_From_Coa_Id                          NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Start_Date_Active                    DATE,
                     X_End_Date_Active                      DATE,
                     X_Security_Flag                        VARCHAR2
                     );

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Update table GL_COA_MAPPINGS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_COA_MAPPINGS_PKG.Update_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                       X_Coa_Mapping_Id                       IN OUT NOCOPY NUMBER,
                       X_To_Coa_Id                            NUMBER,
                       X_From_Coa_Id                          NUMBER,
                       X_Name                                 VARCHAR2,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Description                          VARCHAR2,
                       X_Start_Date_Active                    DATE,
                       X_End_Date_Active                      DATE,
                       X_Security_Flag                        VARCHAR2
                       );

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   Delete records from table GL_COA_MAPPINGS
  -- Arguments
  --   Row_Id     Rowid of row to be deleted
  --   Coa_Mapping_Id	Mapping ID for the mapping to be deleted
  -- Example
  --   GL_COA_MAPPINGS_PKG.Delete_Row(:MAPPING.Row_Id, :MAPPING.Mapping_Id)
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Coa_Mapping_Id NUMBER);

  --
  -- Procedure
  --   Check_Unique_Name
  -- Purpose
  --   Check if Coa_Mapping name is unique
  -- Arguments
  --   X_Rowid  Rowid of record to be checked
  -- Example
  --   GL_COA_MAPPING_PKG.Check_Unique_Name(:MAPPING.row_id,
  --     :MAPPING.name)
  -- Notes
  --
  PROCEDURE Check_Unique_Name(X_Rowid  VARCHAR2,
                              X_Name   VARCHAR2);

  --
  -- Procedure
  --   Check_Unique
  -- Purpose
  --   Check uniqueness of unique id
  -- Arguments
  --   X_Rowid                  Rowid of record to be checked
  --   X_Coa_Mapping_Id         Value of unique id
  -- Example
  --   GL_COA_MAPPING_PKG.Check_Unique(:MAPPING.row_id,
  --     :MAPPING.coa_mapping_id)
  -- Notes
  --
  PROCEDURE Check_Unique(X_Rowid                 VARCHAR2,
                         X_Coa_Mapping_Id        NUMBER);

  --
  -- Procedure
  --   Check_Unmapped_Sub_Segments
  -- Purpose
  --   Check at the time closing the form if there are any
  --   unmapped subsidiary segments.
  -- Arguments
  --   X_From_Coa_Id         From Chart of Accounts Id
  --   X_Coa_Mapping_Id      Coa_Mapping_Id
  --   X_Unmapped_Segment_found   Y or N
  -- Example
  --   GL_COA_MAPPING_PKG.Check_Unmapped_Sub_Segments(:MAPPING.from_coa_id,
  --     :MAPPING.coa_mapping_id, unmapped_found)
  -- Notes
  --
  PROCEDURE Check_Unmapped_Sub_Segments( X_From_Coa_Id NUMBER,
                                         X_Coa_Mapping_Id   NUMBER,
                                         X_Unmapped_Segment_Found   IN OUT NOCOPY VARCHAR2);
END GL_COA_MAPPINGS_PKG;

 

/
