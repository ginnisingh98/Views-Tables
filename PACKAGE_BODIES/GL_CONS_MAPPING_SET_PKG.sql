--------------------------------------------------------
--  DDL for Package Body GL_CONS_MAPPING_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_MAPPING_SET_PKG" as
/* $Header: glicompb.pls 120.11 2005/05/05 01:05:36 kvora ship $ */
--
-- PUBLIC PROCEDURES
--

--** Added Security_Flag column for DAS Project
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Parent_Ledger_Id             IN OUT NOCOPY NUMBER,
                     X_Consolidation_Set_Name              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Method                              VARCHAR2,
                     X_Run_Journal_Import_Flag             VARCHAR2,
                     X_Audit_Mode_Flag                     VARCHAR2,
                     X_Summarize_Lines_Flag                VARCHAR2,
                     X_Run_Posting_Flag                    VARCHAR2,
                     X_Security_Flag                       VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_CONSOLIDATION_SETS
             WHERE consolidation_set_id = X_Consolidation_Set_Id;

BEGIN

  INSERT INTO GL_CONSOLIDATION_SETS(
          consolidation_set_id,
          to_ledger_id,
          name,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          description,
          context,
          method,
          run_journal_import_flag,
          audit_mode_flag,
          summarize_lines_flag,
          run_posting_flag,
          security_flag,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15
          ) VALUES (
          X_Consolidation_Set_Id,
          X_Parent_Ledger_Id,
          X_Consolidation_Set_Name,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Description,
          X_Context,
          X_Method,
          X_Run_journal_import_flag,
          X_Audit_mode_flag,
          X_Summarize_lines_flag,
          X_Run_posting_flag,
          X_Security_Flag,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

--** Added Security_Flag column for DAS Project
PROCEDURE Update_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Parent_Ledger_Id             IN OUT NOCOPY NUMBER,
                     X_Consolidation_Set_Name              VARCHAR2,
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
) IS

BEGIN

  UPDATE GL_CONSOLIDATION_SETS
  SET
    consolidation_set_id        =   X_Consolidation_Set_Id,
    to_ledger_id                =   X_parent_ledger_id,
    name                        =   X_Consolidation_Set_Name,
    last_update_date            =   X_Last_Update_Date,
    last_updated_by             =   X_Last_Updated_By,
    creation_date               =   X_Creation_Date,
    created_by                  =   X_Created_By,
    last_update_login           =   X_Last_Update_Login,
    description                 =   X_Description,
    context                     =   X_Context,
    method                      =   X_Method,
    run_journal_import_flag     =   X_Run_Journal_Import_Flag,
    audit_mode_flag             =   X_Audit_Mode_Flag,
    summarize_lines_flag        =   X_Summarize_Lines_Flag,
    run_posting_flag            =   X_Run_Posting_Flag,
    security_flag               =   X_Security_Flag,
    attribute1                  =   X_Attribute1,
    attribute2                  =   X_Attribute2,
    attribute3                  =   X_Attribute3,
    attribute4                  =   X_Attribute4,
    attribute5                  =   X_Attribute5,
    attribute6                  =   X_Attribute6,
    attribute7                  =   X_Attribute7,
    attribute8                  =   X_Attribute8,
    attribute9                  =   X_Attribute9,
    attribute10                 =   X_Attribute10,
    attribute11                 =   X_Attribute11,
    attribute12                 =   X_Attribute12,
    attribute13                 =   X_Attribute13,
    attribute14                 =   X_Attribute14,
    attribute15                 =   X_Attribute15
  WHERE rowid = X_rowid;

  IF ( SQL%NOTFOUND ) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;

--** Added Security_Flag column for DAS Project
PROCEDURE   Lock_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Parent_Ledger_Id             IN OUT NOCOPY NUMBER,
                     X_Consolidation_Set_Name              VARCHAR2,
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
 ) IS
   CURSOR C IS SELECT * FROM GL_CONSOLIDATION_SETS
             WHERE rowid = X_Rowid
             FOR UPDATE of consolidation_set_id NOWAIT;
   Recinfo C%ROWTYPE;

BEGIN

  OPEN C;

  FETCH C INTO Recinfo;

  IF ( C%NOTFOUND ) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE C;

  IF (
           (  Recinfo.consolidation_set_id = X_Consolidation_Set_id
              OR ( ( Recinfo.consolidation_set_id IS NULL )
              AND  ( X_Consolidation_Set_Id IS NULL ) ) )
       AND (  Recinfo.to_ledger_id = X_Parent_Ledger_Id
              OR ( ( Recinfo.to_ledger_id IS NULL )
              AND  ( X_Parent_Ledger_Id IS NULL ) ) )
       AND (  Recinfo.name = X_Consolidation_Set_Name
              OR ( ( Recinfo.name IS NULL )
              AND  ( X_Consolidation_Set_Name IS NULL ) ) )
       AND (  Recinfo.creation_date = X_Creation_Date
              OR ( ( Recinfo.creation_date IS NULL )
              AND  ( X_Creation_Date IS NULL ) ) )
       AND (  Recinfo.created_by = X_Created_By
              OR ( ( Recinfo.created_by IS NULL )
              AND  ( X_Created_By IS NULL ) ) )
       AND (  Recinfo.last_update_date = X_Last_Update_Date
              OR ( ( Recinfo.last_update_date IS NULL )
              AND  ( X_Last_Update_Date IS NULL ) ) )
       AND (  Recinfo.last_updated_by = X_Last_Updated_By
              OR ( ( Recinfo.last_updated_by IS NULL )
              AND  ( X_Last_Updated_By IS NULL ) ) )
       AND (  Recinfo.last_update_login = X_Last_Update_Login
              OR ( ( Recinfo.last_update_login IS NULL )
              AND  ( X_Last_Update_Login IS NULL ) ) )
       AND (  Recinfo.description = X_Description
              OR ( ( Recinfo.description IS NULL )
              AND  ( X_Description IS NULL ) ) )
       AND (  Recinfo.context = X_Context
              OR ( ( Recinfo.context IS NULL )
              AND  ( X_Context IS NULL ) ) )
       AND (  Recinfo.method = X_Method
              OR ( ( Recinfo.method IS NULL )
              AND  ( X_Method IS NULL ) ) )
       AND (  Recinfo.run_journal_import_flag = X_Run_Journal_Import_Flag
              OR ( ( Recinfo.run_journal_import_flag IS NULL )
              AND  ( X_Run_Journal_Import_Flag IS NULL ) ) )
       AND (  Recinfo.audit_mode_flag = X_Audit_Mode_Flag
              OR ( ( Recinfo.audit_mode_flag IS NULL )
              AND  ( X_Audit_Mode_Flag IS NULL ) ) )
       AND (  Recinfo.summarize_lines_flag = X_Summarize_Lines_Flag
              OR ( ( Recinfo.summarize_lines_flag IS NULL )
              AND  ( X_Summarize_Lines_Flag IS NULL ) ) )
       AND (  Recinfo.run_posting_flag = X_Run_Posting_Flag
              OR ( ( Recinfo.run_posting_flag IS NULL )
              AND  ( X_Run_Posting_Flag IS NULL ) ) )
       AND (  Recinfo.security_flag = X_Security_Flag
              OR ( ( Recinfo.security_flag IS NULL )
              AND  ( X_Security_Flag IS NULL ) ) )
       AND (  Recinfo.attribute1 = X_Attribute1
              OR ( ( Recinfo.attribute1 IS NULL )
              AND  ( X_Attribute1 IS NULL ) ) )
       AND (  Recinfo.attribute2 = X_Attribute2
              OR ( ( Recinfo.attribute2 IS NULL )
              AND  ( X_Attribute2 IS NULL ) ) )
       AND (  Recinfo.attribute3 = X_Attribute3
              OR ( ( Recinfo.attribute3 IS NULL )
              AND  ( X_Attribute3 IS NULL ) ) )
       AND (  Recinfo.attribute4 = X_Attribute4
              OR ( ( Recinfo.attribute4 IS NULL )
              AND  ( X_Attribute4 IS NULL ) ) )
       AND (  Recinfo.attribute5 = X_Attribute5
              OR ( ( Recinfo.attribute5 IS NULL )
              AND  ( X_Attribute5 IS NULL ) ) )
       AND (  Recinfo.attribute6 = X_Attribute6
              OR ( ( Recinfo.attribute6 IS NULL )
              AND  ( X_Attribute6 IS NULL ) ) )
       AND (  Recinfo.attribute7 = X_Attribute7
              OR ( ( Recinfo.attribute7 IS NULL )
              AND  ( X_Attribute7 IS NULL ) ) )
       AND (  Recinfo.attribute8 = X_Attribute8
              OR ( ( Recinfo.attribute8 IS NULL )
              AND  ( X_Attribute8 IS NULL ) ) )
       AND (  Recinfo.attribute9 = X_Attribute9
              OR ( ( Recinfo.attribute9 IS NULL )
              AND  ( X_Attribute9 IS NULL ) ) )
       AND (  Recinfo.attribute10 = X_Attribute10
              OR ( ( Recinfo.attribute10 IS NULL )
              AND  ( X_Attribute10 IS NULL ) ) )
       AND (  Recinfo.attribute11 = X_Attribute11
              OR ( ( Recinfo.attribute11 IS NULL )
              AND  ( X_Attribute11 IS NULL ) ) )
       AND (  Recinfo.attribute12 = X_Attribute12
              OR ( ( Recinfo.attribute12 IS NULL )
              AND  ( X_Attribute12 IS NULL ) ) )
       AND (  Recinfo.attribute13 = X_Attribute13
              OR ( ( Recinfo.attribute13 IS NULL )
              AND  ( X_Attribute13 IS NULL ) ) )
       AND (  Recinfo.attribute14 = X_Attribute14
              OR ( ( Recinfo.attribute14 IS NULL )
              AND  ( X_Attribute14 IS NULL ) ) )
       AND (  Recinfo.attribute15 = X_Attribute15
              OR ( ( Recinfo.attribute15 IS NULL )
              AND  ( X_Attribute15 IS NULL ) ) )
     ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name( 'FND', 'FORM_RECORD_CHANGED' );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

END Lock_Row;

--** Added Security_Flag column for DAS Project
PROCEDURE Delete_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Parent_Ledger_Id             IN OUT NOCOPY NUMBER,
                     X_Consolidation_Set_Name              VARCHAR2,
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
 ) IS
BEGIN

  DELETE FROM GL_CONSOLIDATION_SETS
  WHERE  rowid = X_Rowid;

  IF ( SQL%NOTFOUND ) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;

PROCEDURE Check_Unique_Name(X_Rowid           VARCHAR2,
                            X_Name            VARCHAR2) IS
CURSOR check_dups IS
  SELECT  1
    FROM  GL_CONSOLIDATION_SETS glc
   WHERE  glc.name = X_Name
     AND  ( X_Rowid is NULL
           OR glc.rowid <> X_Rowid);

dummy  NUMBER;

BEGIN
  OPEN check_dups;
  FETCH check_dups INTO dummy;

  IF check_dups%FOUND THEN
    CLOSE check_dups;
    fnd_message.set_name('SQLGL','GL_DUP_CONSOLIDATION_SETS_NAME');
    app_exception.raise_exception;
  END IF;

  CLOSE check_dups;
END Check_Unique_Name;


END GL_CONS_MAPPING_SET_PKG;

/
