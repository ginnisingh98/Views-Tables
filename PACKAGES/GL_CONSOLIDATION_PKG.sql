--------------------------------------------------------
--  DDL for Package GL_CONSOLIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONSOLIDATION_PKG" AUTHID CURRENT_USER as
/* $Header: glicosts.pls 120.11 2005/05/05 01:06:24 kvora ship $ */
--
-- Package
--   gl_consolidation_pkg
-- Purpose
--   Package procedures for Consolidation Setup form,
--     Consolidation block
-- History
--   01/03/94   E Wilson        Created
--

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Insert new records into table GL_CONSOLIDATION
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONSOLIDATION_PKG.Insert_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                       X_Consolidation_Id                     IN OUT NOCOPY NUMBER,
                       X_Name                                 VARCHAR2,
                       X_Coa_Mapping_Id                       NUMBER,
                       X_Last_Update_Date                     DATE,
                       X_Last_Updated_By                      NUMBER,
                       X_From_Ledger_Id                       NUMBER,
                       X_To_Ledger_Id                         NUMBER,
                       X_Creation_Date                        DATE,
                       X_Created_By                           NUMBER,
                       X_Last_Update_Login                    NUMBER,
                       X_Description                          VARCHAR2,
                       X_Method                               VARCHAR2,
                       X_From_Currency_Code                   VARCHAR2,
                       X_From_Location                        VARCHAR2,
                       X_From_Oracle_Id                       VARCHAR2,
                       X_Attribute1                           VARCHAR2,
                       X_Attribute2                           VARCHAR2,
                       X_Attribute3                           VARCHAR2,
                       X_Attribute4                           VARCHAR2,
                       X_Attribute5                           VARCHAR2,
                       X_Context                              VARCHAR2,
                       X_Usage                                VARCHAR2,
                       X_Run_Journal_Import_Flag              VARCHAR2,
                       X_Audit_Mode_Flag                      VARCHAR2,
                       X_Summarize_Lines_Flag                 VARCHAR2,
                       X_Run_Posting_Flag                     VARCHAR2,
                       X_Security_Flag                        VARCHAR2
                       );

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   Lock records in table GL_CONSOLIDATION
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONSOLIDATION_PKG.Lock_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                     X_Consolidation_Id                       NUMBER,
                     X_Name                                   VARCHAR2,
                     X_Coa_Mapping_Id                         NUMBER,
                     X_From_Ledger_Id                         NUMBER,
                     X_To_Ledger_Id                           NUMBER,
                     X_Description                            VARCHAR2,
                     X_Method                                 VARCHAR2,
                     X_From_Currency_Code                     VARCHAR2,
                     X_From_Location                          VARCHAR2,
                     X_From_Oracle_Id                         VARCHAR2,
                     X_Attribute1                             VARCHAR2,
                     X_Attribute2                             VARCHAR2,
                     X_Attribute3                             VARCHAR2,
                     X_Attribute4                             VARCHAR2,
                     X_Attribute5                             VARCHAR2,
                     X_Context                                VARCHAR2,
                     X_Usage                                  VARCHAR2,
                     X_Security_Flag                          VARCHAR2
                     );

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Update table GL_CONSOLIDATION
  -- Arguments
  --   <table columns>
  -- Example
  --   GL_CONSOLIDATION_PKG.Update_Row(<table columns>)
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                       X_Consolidation_Id                    NUMBER,
                       X_Name                                VARCHAR2,
                       X_Coa_Mapping_Id                      NUMBER,
                       X_Last_Update_Date                    DATE,
                       X_Last_Updated_By                     NUMBER,
                       X_From_Ledger_Id                      NUMBER,
                       X_To_Ledger_Id                        NUMBER,
                       X_Last_Update_Login                   NUMBER,
                       X_Description                         VARCHAR2,
                       X_Method                              VARCHAR2,
                       X_From_Currency_Code                  VARCHAR2,
                       X_From_Location                       VARCHAR2,
                       X_From_Oracle_Id                      VARCHAR2,
                       X_Attribute1                          VARCHAR2,
                       X_Attribute2                          VARCHAR2,
                       X_Attribute3                          VARCHAR2,
                       X_Attribute4                          VARCHAR2,
                       X_Attribute5                          VARCHAR2,
                       X_Context                             VARCHAR2,
                       X_Usage                               VARCHAR2,
                       X_Run_Journal_Import_Flag             VARCHAR2,
                       X_Audit_Mode_Flag                     VARCHAR2,
                       X_Summarize_Lines_Flag                VARCHAR2,
                       X_Run_Posting_Flag                    VARCHAR2,
                       X_Security_Flag                       VARCHAR2
                       );

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   Delete records from table GL_CONSOLIDATION
  -- Arguments
  --   Row_Id     Rowid of row to be deleted
  -- Example
  --   GL_CONSOLIDATION_PKG.Delete_Row(:CONSOLIDATION.Row_Id)
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Consolidation_Id NUMBER);

  --
  -- Procedure
  --   Check_Unique_Name
  -- Purpose
  --   Check if Consolidation name is unique
  -- Arguments
  --   X_Rowid  Rowid of record to be checked
  -- Example
  --   GL_CONSOLIDATION_PKG.Check_Unique_Name(:CONSOLIDATION.row_id,
  --     :CONSOLIDATION.name)
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
  --   X_Consolidation_Id       Value of unique id
  -- Example
  --   GL_CONSOLIDATION_PKG.Check_Unique(:CONSOLIDATION.row_id,
  --     :CONSOLIDATION.consolidation_id)
  -- Notes
  --
  PROCEDURE Check_Unique(X_Rowid                 VARCHAR2,
                         X_Consolidation_Id      NUMBER);

  --
  -- Procedure
  --   Check_Mapping_Used_In_Sets
  -- Purpose
  --   Check at the time changing the consolidation method whether the
  --   mapping is part of a mapping set.
  -- Arguments
  --   X_Consolidation_Id
  --   X_Mapping_Used_In_Set
  -- Example
  -- Notes
  --
  PROCEDURE Check_Mapping_Used_In_Sets( X_Consolidation_Id   NUMBER,
                                        X_Mapping_Used_In_Set   IN OUT NOCOPY VARCHAR2);
  --
  -- Procedure
  --   Check_Mapping_Run
  -- Purpose
  --   Check whether the Mapping has been run atleast once.
  -- Arguments
  --   X_Consolidation_Id
  -- Example
  -- Notes
  --
  PROCEDURE Check_Mapping_Run( X_Consolidation_Id   NUMBER,
                               X_Mapping_Has_Been_Run   IN OUT NOCOPY VARCHAR2);

END GL_CONSOLIDATION_PKG;

 

/
