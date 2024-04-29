--------------------------------------------------------
--  DDL for Package Body GL_CONSOLIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONSOLIDATION_PKG" as
/* $Header: glicostb.pls 120.13 2005/05/05 01:06:18 kvora ship $ */
--
-- PRIVATE FUNCTIONS
--

PROCEDURE Check_Same_Currency(X_To_Ledger_Id        NUMBER,
                              X_From_Ledger_Id      NUMBER) IS
CURSOR C3 IS
  SELECT  1
    FROM  GL_LEDGERS ledger1
   WHERE  ledger1.ledger_id = X_From_Ledger_Id
     AND  ledger1.currency_code = (SELECT ledger2.currency_code
             FROM GL_LEDGERS ledger2
            WHERE ledger2.ledger_id = X_To_Ledger_Id);

dummy  NUMBER;

BEGIN
  OPEN C3;
  FETCH C3 INTO dummy;

  IF C3%NOTFOUND THEN
    CLOSE C3;
    fnd_message.set_name('SQLGL','GL_SAME_CURRENCY');
    app_exception.raise_exception;
  END IF;

  CLOSE C3;
END Check_Same_Currency;

--
-- PUBLIC FUNCTIONS
--

--** Added Security_Flag
PROCEDURE Insert_Row(X_Rowid                               IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Id                    IN OUT NOCOPY NUMBER,
                     X_Name                                VARCHAR2,
                     X_Coa_Mapping_Id                      NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_From_Ledger_Id                      NUMBER,
                     X_To_Ledger_Id                        NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
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
 ) IS
   CURSOR C IS SELECT rowid FROM gl_consolidation
                WHERE consolidation_id = X_Consolidation_Id;
BEGIN

   -- Check that from and to ledgers have same funcional currency
   if (X_Method = 'T') then
     Check_Same_Currency(X_To_Ledger_Id, X_From_Ledger_Id);
   end if;

   INSERT INTO gl_consolidation(
          consolidation_id,
          name,
          coa_mapping_id,
          last_update_date,
          last_updated_by,
          from_ledger_id,
          to_ledger_id,
          creation_date,
          created_by,
          last_update_login,
          description,
          method,
          from_currency_code,
          from_location,
          from_oracle_id,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          context,
          usage_code,
          run_journal_import_flag,
          audit_mode_flag,
          summarize_lines_flag,
          run_posting_flag,
          security_flag
         ) VALUES (
          X_Consolidation_Id,
          X_Name,
          X_Coa_Mapping_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_From_Ledger_Id,
          X_To_Ledger_Id,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Description,
          X_Method,
          X_From_Currency_Code,
          X_From_Location,
          X_From_Oracle_Id,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Context,
          X_Usage,
          X_Run_Journal_Import_Flag,
          X_Audit_Mode_Flag,
          X_Summarize_Lines_Flag,
          X_Run_Posting_Flag,
          X_Security_Flag
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

--** Added Security_Flag
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Consolidation_Id                      NUMBER,
                   X_Name                                  VARCHAR2,
                   X_Coa_Mapping_Id                        NUMBER,
                   X_From_Ledger_Id                        NUMBER,
                   X_To_Ledger_Id                          NUMBER,
                   X_Description                           VARCHAR2,
                   X_Method                                VARCHAR2,
                   X_From_Currency_Code                    VARCHAR2,
                   X_From_Location                         VARCHAR2,
                   X_From_Oracle_Id                        VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Usage                                 VARCHAR2,
                   X_Security_Flag                         VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_consolidation
      WHERE  rowid = X_Rowid
      FOR UPDATE of Consolidation_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.consolidation_id = X_Consolidation_Id)
           OR (    (Recinfo.consolidation_id IS NULL)
               AND (X_Consolidation_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.coa_mapping_id = X_Coa_Mapping_Id)
           OR (    (Recinfo.coa_mapping_id IS NULL)
               AND (X_Coa_Mapping_Id IS NULL)))
      AND (   (Recinfo.from_ledger_id = X_From_Ledger_Id)
           OR (    (Recinfo.from_ledger_id IS NULL)
               AND (X_From_Ledger_Id IS NULL)))
      AND (   (Recinfo.to_ledger_id = X_To_Ledger_Id)
           OR (    (Recinfo.to_ledger_id IS NULL)
               AND (X_To_Ledger_Id IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.method = X_Method)
           OR (    (Recinfo.method IS NULL)
               AND (X_Method IS NULL)))
      AND (   (Recinfo.from_currency_code = X_From_Currency_Code)
           OR (    (Recinfo.from_currency_code IS NULL)
               AND (X_From_Currency_Code IS NULL)))
      AND (   (Recinfo.from_location = X_From_Location)
           OR (    (Recinfo.from_location IS NULL)
               AND (X_From_Location IS NULL)))
      AND (   (Recinfo.from_oracle_id = X_From_Oracle_Id)
           OR (    (Recinfo.from_oracle_id IS NULL)
               AND (X_From_Oracle_Id IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.usage_code = X_Usage)
           OR (    (Recinfo.usage_code IS NULL)
               AND (X_Usage IS NULL)))
      AND (   (Recinfo.security_flag = X_Security_Flag)
           OR (    (Recinfo.security_flag IS NULL)
               AND (X_Security_Flag IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

--** Added Security_Flag
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
) IS
BEGIN

  -- Check that from and to ledgers have same funcional currency
  if (X_Method = 'T') then
    Check_Same_Currency(X_To_Ledger_Id, X_From_Ledger_Id);
  end if;

  UPDATE gl_consolidation
  SET

    consolidation_id                          =    X_Consolidation_Id,
    name                                      =    X_Name,
    coa_mapping_id                            =    X_Coa_Mapping_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    from_ledger_id                            =    X_From_Ledger_Id,
    to_ledger_id                              =    X_To_Ledger_Id,
    last_update_login                         =    X_Last_Update_Login,
    description                               =    X_Description,
    method                                    =    X_Method,
    from_currency_code                        =    X_From_Currency_Code,
    from_location                             =    X_From_Location,
    from_oracle_id                            =    X_From_Oracle_Id,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    context                                   =    X_Context,
    usage_code                                =    X_Usage,
    run_journal_import_flag                   =    X_Run_Journal_Import_Flag,
    audit_mode_flag                           =    X_Audit_Mode_Flag,
    summarize_lines_flag                      =    X_Summarize_Lines_Flag,
    run_posting_flag                          =    X_Run_Posting_Flag,
    security_flag                             =    X_Security_Flag
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Consolidation_Id NUMBER) IS
BEGIN

  DELETE FROM gl_consolidation
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

PROCEDURE Check_Unique_Name(X_Rowid    VARCHAR2,
                            X_Name     VARCHAR2) IS
CURSOR check_dups IS
  SELECT  1
    FROM  GL_CONSOLIDATION glc
   WHERE  glc.name = X_Name
     AND  ( X_Rowid is NULL
           OR glc.rowid <> X_Rowid);

dummy  NUMBER;

BEGIN
  OPEN check_dups;
  FETCH check_dups INTO dummy;

  IF check_dups%FOUND THEN
    CLOSE check_dups;
    fnd_message.set_name('SQLGL','GL_DUP_CONSOLIDATION_NAME');
    app_exception.raise_exception;
  END IF;

  CLOSE check_dups;
END Check_Unique_Name;

PROCEDURE Check_Unique(X_Rowid               VARCHAR2,
                       X_Consolidation_Id      NUMBER) IS
CURSOR C2 IS
  SELECT  1
    FROM  GL_CONSOLIDATION glc
   WHERE  glc.consolidation_id = X_Consolidation_Id
     AND  ( X_Rowid is NULL
           OR glc.rowid <> X_Rowid);

dummy  NUMBER;

BEGIN
  OPEN C2;
  FETCH C2 INTO dummy;

  IF C2%FOUND THEN
    CLOSE C2;
    fnd_message.set_name('SQLGL','GL_DUP_UNIQUE_ID');
    fnd_message.set_token('TAB_S','GL_CONSOLIDATION_S');
    app_exception.raise_exception;
  END IF;

  CLOSE C2;
END Check_Unique;

PROCEDURE Check_Mapping_Used_In_Sets( X_Consolidation_Id      NUMBER,
                                      X_Mapping_Used_In_Set IN OUT NOCOPY VARCHAR2) IS
CURSOR C4 IS
       SELECT 'Y'
       FROM   DUAL
       WHERE EXISTS
             ( SELECT 'Mapping found in a mapping set'
               FROM   GL_CONS_SET_ASSIGNMENTS ASG
               WHERE  ASG.consolidation_id = X_Consolidation_Id
             );

BEGIN
  OPEN C4;
  FETCH C4 INTO X_Mapping_Used_In_Set;

  IF C4%FOUND THEN
    X_Mapping_Used_In_Set := 'Y';
  ELSE
    X_Mapping_Used_In_Set := 'N';
  END IF;

  CLOSE C4;
END Check_Mapping_Used_In_Sets;

PROCEDURE Check_Mapping_Run( X_Consolidation_Id      NUMBER,
                             X_Mapping_Has_Been_Run IN OUT NOCOPY VARCHAR2) IS
CURSOR C4 IS
       SELECT 'Y'
       FROM   DUAL
       WHERE EXISTS
             ( SELECT 'Mapping has been run atleast once'
               FROM   GL_CONSOLIDATION_HISTORY COH
               WHERE  COH.consolidation_id = X_Consolidation_Id
             );

BEGIN
  OPEN C4;
  FETCH C4 INTO X_Mapping_Has_Been_Run;

  IF C4%FOUND THEN
    X_Mapping_Has_Been_Run := 'Y';
  ELSE
    X_Mapping_Has_Been_Run := 'N';
  END IF;

  CLOSE C4;
END Check_Mapping_Run;

END GL_CONSOLIDATION_PKG;

/
