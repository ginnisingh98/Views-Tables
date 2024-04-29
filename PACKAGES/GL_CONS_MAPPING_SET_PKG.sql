--------------------------------------------------------
--  DDL for Package GL_CONS_MAPPING_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_MAPPING_SET_PKG" AUTHID CURRENT_USER as
/* $Header: glicomps.pls 120.11 2005/05/05 01:05:43 kvora ship $ */
--
-- Package
--   gl_cons_mapping_set_pkg
-- Purpose
--   Package procedures for Consolidation Mapping Set form,
--     Mapping_Set block
-- History
--   19-NOV-96  U Thimmappa     Created.
--

  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Insert new records into table GL_CONSOLIDATION_SETS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_MAPPING_SET_PKG.Insert_Row(<table columns>)
  -- Notes
  -- Added Security_Flag column
  --
  PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER,
                       X_Parent_Ledger_Id              IN OUT NOCOPY NUMBER,
                       X_Consolidation_Set_Name               VARCHAR2,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Description                          VARCHAR2,
                       X_Context                              VARCHAR2,
                       X_Method                               VARCHAR2,
                       X_Run_Journal_Import_Flag              VARCHAR2,
                       X_Audit_Mode_Flag                      VARCHAR2,
                       X_Summarize_Lines_Flag                 VARCHAR2,
                       X_Run_Posting_Flag                     VARCHAR2,
                       X_Security_Flag                        VARCHAR2,
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
  --   Lock record in table GL_CONSOLIDATION_SETSTION_SETS
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONS_MAPPING_SET_PKG.Lock_Row(<table columns>)
  -- Notes
  -- Added Security_Flag column
  --
  PROCEDURE Lock_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER,
                     X_Parent_Ledger_Id              IN OUT NOCOPY NUMBER,
                     X_Consolidation_Set_Name               VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Description                          VARCHAR2,
                     X_Context                              VARCHAR2,
                     X_Method                               VARCHAR2,
                     X_Run_Journal_Import_Flag              VARCHAR2,
                     X_Audit_Mode_Flag                      VARCHAR2,
                     X_Summarize_Lines_Flag                 VARCHAR2,
                     X_Run_Posting_Flag                     VARCHAR2,
                     X_Security_Flag                        VARCHAR2,
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
  --   GL_CONS_MAPPING_SET_PKG.Update_Row(<table columns>)
  -- Notes
  -- Added Security_Flag column
  --
  PROCEDURE Update_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER,
                       X_Parent_Ledger_Id              IN OUT NOCOPY NUMBER,
                       X_Consolidation_Set_Name               VARCHAR2,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Description                          VARCHAR2,
                       X_Context                              VARCHAR2,
                       X_Method                               VARCHAR2,
                       X_Run_Journal_Import_Flag              VARCHAR2,
                       X_Audit_Mode_Flag                      VARCHAR2,
                       X_Summarize_Lines_Flag                 VARCHAR2,
                       X_Run_Posting_Flag                     VARCHAR2,
                       X_Security_Flag                        VARCHAR2,
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
  --   GL_CONS_MAPPING_SET_PKG.Delete_Row(<table columns>)
  -- Notes
  -- Added Security_Flag column
  --
  PROCEDURE Delete_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                       X_Consolidation_Set_Id          IN OUT NOCOPY NUMBER,
                       X_Parent_Ledger_Id              IN OUT NOCOPY NUMBER,
                       X_Consolidation_Set_Name               VARCHAR2,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Description                          VARCHAR2,
                       X_Context                              VARCHAR2,
                       X_Method                               VARCHAR2,
                       X_Run_Journal_Import_Flag              VARCHAR2,
                       X_Audit_Mode_Flag                      VARCHAR2,
                       X_Summarize_Lines_Flag                 VARCHAR2,
                       X_Run_Posting_Flag                     VARCHAR2,
                       X_Security_Flag                        VARCHAR2
                       );

  -- Procedure
  --   Check_Unique_Name
  -- Purpose
  --   Check if Consolidation name is unique
  -- Arguments
  --   X_Rowid  Rowid of record to be checked
  -- Example
  --   GL_CONS_MAPPING_SET_PKG.Check_Unique_Name(:MAPPING_SET.row_id,
  --                                             :MAPPING_SET.name)
  -- Notes
  --
  PROCEDURE Check_Unique_Name(X_Rowid         VARCHAR2,
                              X_Name          VARCHAR2);


END GL_CONS_MAPPING_SET_PKG;

 

/
