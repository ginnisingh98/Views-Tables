--------------------------------------------------------
--  DDL for Package GL_CONS_SET_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_SET_ASSIGN_PKG" AUTHID CURRENT_USER as
/* $Header: glicomas.pls 120.3 2005/05/05 01:05:29 kvora ship $ */
--
-- Package
--   GL_CONS_SET_ASSIGN_PKG
-- Purpose
--   Package procedures for Consolidation Mapping Set form,
--     Set Assign block
-- History
--   19-NOV-96	U Thimmappa     Created.
--

  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Insert new records into table GL_CONS_SET_ASSIGNMENTS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SET_ASSIGN_PKG.Insert_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER,
                       X_Consolidation_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Context                              VARCHAR2,
                       X_Child_Cons_Set_Id                    NUMBER,
                       X_Attribute1                           VARCHAR2,
                       X_Attribute2                           VARCHAR2,
                       X_Attribute3                           VARCHAR2,
                       X_Attribute4                           VARCHAR2,
                       X_Attribute5                           VARCHAR2,
                       X_Attribute6                           VARCHAR2,
                       X_Attribute7                           VARCHAR2,
                       X_Attribute8                           VARCHAR2,
                       X_Attribute9                           VARCHAR2,
                       X_Attribute10                          VARCHAR2,
                       X_Attribute11                          VARCHAR2,
                       X_Attribute12                          VARCHAR2,
                       X_Attribute13                          VARCHAR2,
                       X_Attribute14                          VARCHAR2,
                       X_Attribute15                          VARCHAR2
                       );

  -- Procedure
  --   Lock Row
  -- Purpose
  --   Lock record in table GL_CONS_SET_ASSIGNMENTS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SET_ASSIGN_PKG.Lock_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER,
                     X_Consolidation_Id              IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2
                     );

  -- Procedure
  --   Update_Row
  -- Purpose
  --   Update table GL_CONSOLIDATION_SETS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SET_ASSIGN_PKG.Update_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER,
                       X_Consolidation_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Context                              VARCHAR2,
                       X_Child_Cons_Set_Id                    NUMBER,
                       X_Attribute1                           VARCHAR2,
                       X_Attribute2                           VARCHAR2,
                       X_Attribute3                           VARCHAR2,
                       X_Attribute4                           VARCHAR2,
                       X_Attribute5                           VARCHAR2,
                       X_Attribute6                           VARCHAR2,
                       X_Attribute7                           VARCHAR2,
                       X_Attribute8                           VARCHAR2,
                       X_Attribute9                           VARCHAR2,
                       X_Attribute10                          VARCHAR2,
                       X_Attribute11                          VARCHAR2,
                       X_Attribute12                          VARCHAR2,
                       X_Attribute13                          VARCHAR2,
                       X_Attribute14                          VARCHAR2,
                       X_Attribute15                          VARCHAR2
                       );

  -- Procedure
  --   Delete_Row
  -- Purpose
  --   Delete record from  table GL_CONSOLIDATION_SETS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SET_ASSIGN_PKG.Delete_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER,
                       X_Consolidation_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Context                              VARCHAR2
                       );

  -- Procedure
  --   Delete_All_Child_Rows
  -- Purpose
  --   Delete all records from  table GL_CONSOLIDATION_SETS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_SET_ASSIGN_PKG.Delete_All_Child_Rows(<table columns>)
  -- Notes
  --
  PROCEDURE Delete_All_Child_Rows( X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER);

  -- Procedure
  --   Check_Unique_Name
  -- Purpose
  --   Check if Consolidation name is unique
  -- Arguments
  --   X_Rowid	Rowid of record to be checked
  -- Example
  --   GL_CONS_SET_ASSIGN_PKG.Check_Unique_Name(:SET_ASSIGN.row_id,
  --                                            :SET_ASSIGN.name)
  -- Notes
  --
  PROCEDURE Check_Unique_Name(X_Rowid  			IN OUT NOCOPY VARCHAR2,
                              X_Consolidation_Set_Id	IN OUT NOCOPY NUMBER,
			      X_Consolidation_Id	IN OUT NOCOPY NUMBER);

END GL_CONS_SET_ASSIGN_PKG;

 

/
