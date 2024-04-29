--------------------------------------------------------
--  DDL for Package Body GL_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_INTERFACE_PKG" AS
/* $Header: glijiinb.pls 120.10.12010000.1 2008/07/28 13:25:18 appldev ship $ */

--
-- PRIVATE FUNCTIONS
--
PROCEDURE Lock_Budget_Transfer_Row(
		   X_Rowid                            	   VARCHAR2,
		   X_Status				   VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_User_Je_Source_Name                   VARCHAR2,
		   X_Group_Id				   NUMBER,
                   X_User_Je_Category_Name                 VARCHAR2,
		   X_Budget_Version_Id			   NUMBER,
		   X_Je_Batch_Name			   VARCHAR2,
                   X_Currency_Code                         VARCHAR2,
		   X_Code_Combination_Id		   NUMBER,
		   X_Combination_Number			   NUMBER,
		   X_Period_Name			   VARCHAR2,
                   X_Entered_Dr                            NUMBER,
                   X_Entered_Cr                            NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_INTERFACE
      WHERE  rowid = X_Rowid
      FOR UPDATE of User_Je_Source_Name NOWAIT;
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
          (   (Recinfo.status = X_Status)
           OR (    (Recinfo.status IS NULL)
               AND (X_Status IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.user_je_source_name = X_User_Je_Source_Name)
           OR (    (Recinfo.user_je_source_name IS NULL)
               AND (X_User_Je_Source_Name IS NULL)))
      AND (   (Recinfo.group_id = X_Group_Id)
           OR (    (Recinfo.group_id IS NULL)
               AND (X_Group_Id IS NULL)))
      AND (   (Recinfo.user_je_category_name = X_User_Je_Category_Name)
           OR (    (Recinfo.user_je_category_name IS NULL)
               AND (X_User_Je_Category_Name IS NULL)))
      AND (Recinfo.actual_flag = 'B')
      AND (   (Recinfo.budget_version_id = X_Budget_Version_Id)
           OR (    (Recinfo.budget_version_id IS NULL)
               AND (X_Budget_Version_Id IS NULL)))
      AND (   (Recinfo.reference1 = X_Je_Batch_Name)
           OR (    (Recinfo.reference1 IS NULL)
               AND (X_Je_Batch_Name IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.code_combination_id = X_Code_Combination_Id)
           OR (    (Recinfo.code_combination_id IS NULL)
               AND (X_Code_Combination_Id IS NULL)))
      AND (   (Recinfo.je_batch_id = X_Combination_Number)
           OR (    (Recinfo.je_batch_id IS NULL)
               AND (X_Combination_Number IS NULL)))
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.entered_dr = X_Entered_Dr)
           OR (    (Recinfo.entered_dr IS NULL)
               AND (X_Entered_Dr IS NULL)))
      AND (   (Recinfo.entered_cr = X_Entered_Cr)
           OR (    (Recinfo.entered_cr IS NULL)
               AND (X_Entered_Cr IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Budget_Transfer_Row;


--
-- PUBLIC FUNCTIONS
--
  FUNCTION Get_Ledger_Column_Name(
		 Itable				VARCHAR2,
                 Resp_Id                        NUMBER,
                 Resp_Appl_Id                   NUMBER ) RETURN VARCHAR2 IS
    ledger_column_num VARCHAR2(30);
    syntname          VARCHAR2(30);
    syntown           VARCHAR2(30);
  BEGIN
    SELECT upper(nvl(max(syn.table_name),'')),
                    upper(nvl(max(syn.table_owner),''))
    INTO syntname, syntown
    FROM user_synonyms syn
    WHERE syn.synonym_name = upper(Itable);

    IF (syntname IS NULL) THEN
      SELECT upper(Itable), upper(nvl(max(usr.oracle_username),''))
      INTO syntname, syntown
      FROM fnd_responsibility resp, fnd_data_group_units dg,
           fnd_oracle_userid usr
      WHERE resp.application_id = Resp_appl_id
      AND   resp.responsibility_id = Resp_id
      AND   dg.application_id = resp.data_group_application_id
      AND   dg.data_group_id = resp.data_group_id
      AND   usr.oracle_id = dg.oracle_id;
    END IF;

    SELECT nvl(sum(decode(column_name, 'LEDGER_ID', 10,
                                       'SET_OF_BOOKS_ID', 1)),10)
    INTO ledger_column_num
    FROM dba_tab_columns tab
    WHERE tab.table_name = syntname
    AND   tab.owner = syntown;

    IF (ledger_column_num = 10) THEN
      RETURN('LEDGER_ID');
    ELSIF (ledger_column_num = 1) THEN
      RETURN('SET_OF_BOOKS_ID');
    ELSE
      RETURN('decode(LEDGER_ID, -1, SET_OF_BOOKS_ID, LEDGER_ID)');
    END IF;
  END Get_Ledger_Column_Name;

  FUNCTION Get_Ledger_Id(
		 Itable				VARCHAR2,
                 Ledger_Column_Name             VARCHAR2,
                 X_Rowid                        VARCHAR2) RETURN NUMBER IS
    TYPE ledger_curr_type IS REF CURSOR;
    lgrcur     ledger_curr_type;
    lgr_id     NUMBER;
    lgrstr     VARCHAR2(1000);
  BEGIN

    lgrstr := 'SELECT '|| Ledger_Column_Name || ' ' ||
              'FROM ' || Itable || ' ' ||
              'WHERE rowid = :X_Rowid ';

    OPEN lgrcur FOR lgrstr USING X_Rowid;

    FETCH lgrcur INTO lgr_id;

    CLOSE lgrcur;

    RETURN(lgr_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (null);
  END Get_Ledger_Id;

PROCEDURE Insert_Budget_Transfer_Row(
		     X_From_Rowid                   IN OUT NOCOPY VARCHAR2,
		     X_To_Rowid                     IN OUT NOCOPY VARCHAR2,
		     X_Status				   VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Group_Id                            NUMBER,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
                     X_To_Entered_Dr                       NUMBER,
                     X_To_Entered_Cr                       NUMBER,
                     X_Date_Created                        DATE,
                     X_Created_By                          NUMBER
) IS
     CURSOR C (ccid IN NUMBER, unique_value IN VARCHAR2) IS
                 SELECT rowid FROM GL_INTERFACE
                 WHERE user_je_source_name = X_User_Je_Source_Name
                 AND   group_id = X_Group_Id
		 AND   ledger_id = X_Ledger_Id
		 AND   status_description = unique_value
                 AND   code_combination_id = ccid
                 AND   je_batch_id = X_Combination_Number
                 AND   period_name = X_Period_Name;
BEGIN

  -- Insert the From line
  INSERT INTO GL_INTERFACE(
          status,
          ledger_id,
          user_je_source_name,
          user_je_category_name,
          accounting_date,
          currency_code,
          date_created,
          created_by,
          actual_flag,
          budget_version_id,
          entered_dr,
          entered_cr,
          reference1,
          group_id,
          period_name,
          je_batch_id,
          status_description,
          code_combination_id
         ) VALUES (
          X_Status,
          X_Ledger_Id,
          X_User_Je_Source_Name,
          X_User_Je_Category_Name,
          sysdate,
          X_Currency_Code,
          X_Date_Created,
          X_Created_By,
          'B',
          X_Budget_Version_Id,
          X_From_Entered_Dr,
          X_From_Entered_Cr,
          X_Je_Batch_Name,
          X_Group_Id,
          X_Period_Name,
          X_Combination_Number,
          'New Budget Transfer Row',
          X_From_Code_Combination_Id);

  OPEN C(X_From_Code_Combination_Id, 'New Budget Transfer Row');
  FETCH C INTO X_From_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  -- Insert the to line, switching the Cr and Dr
  INSERT INTO GL_INTERFACE(
          status,
          ledger_id,
          user_je_source_name,
          user_je_category_name,
          accounting_date,
          currency_code,
          date_created,
          created_by,
          actual_flag,
          budget_version_id,
          entered_dr,
          entered_cr,
          reference1,
          group_id,
          period_name,
          je_batch_id,
          status_description,
          code_combination_id
         ) VALUES (
          X_Status,
          X_Ledger_Id,
          X_User_Je_Source_Name,
          X_User_Je_Category_Name,
          sysdate,
          X_Currency_Code,
          X_Date_Created,
          X_Created_By,
          'B',
          X_Budget_Version_Id,
          X_To_Entered_Dr,
          X_To_Entered_Cr,
          X_Je_Batch_Name,
          X_Group_Id,
          X_Period_Name,
          X_Combination_Number,
          X_From_RowId,
          X_To_Code_Combination_Id);

  OPEN C(X_To_Code_Combination_Id, X_From_RowId);
  FETCH C INTO X_To_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;


  -- Change the from status description to the to rowid.
  UPDATE GL_INTERFACE
  SET    status_description = X_To_RowId
  WHERE  user_je_source_name = X_User_Je_Source_Name
  AND    group_id = X_Group_Id
  AND    ledger_id = X_Ledger_Id
  AND    status_description = 'New Budget Transfer Row'
  AND    code_combination_id = X_From_Code_Combination_Id
  AND    je_batch_id = X_Combination_Number
  AND    period_name = X_Period_Name;

END Insert_Budget_Transfer_Row;


PROCEDURE Lock_Budget_Transfer_Row(
		   X_From_Rowid                            VARCHAR2,
		   X_To_Rowid				   VARCHAR2,
		   X_Status				   VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_User_Je_Source_Name                   VARCHAR2,
		   X_Group_Id				   NUMBER,
                   X_User_Je_Category_Name                 VARCHAR2,
		   X_Budget_Version_Id			   NUMBER,
		   X_Je_Batch_Name			   VARCHAR2,
                   X_Currency_Code                         VARCHAR2,
		   X_From_Code_Combination_Id		   NUMBER,
		   X_To_Code_Combination_Id		   NUMBER,
		   X_Combination_Number			   NUMBER,
		   X_Period_Name			   VARCHAR2,
                   X_From_Entered_Dr                       NUMBER,
                   X_From_Entered_Cr                       NUMBER,
                   X_To_Entered_Dr                         NUMBER,
                   X_To_Entered_Cr                         NUMBER
) IS
BEGIN

  -- Lock the from row
  GL_INTERFACE_PKG.Lock_Budget_Transfer_Row(
          X_Rowid                => X_From_RowId,
	  X_Status		 => X_Status,
          X_Ledger_Id            => X_Ledger_Id,
          X_User_Je_Source_Name  => X_User_Je_Source_Name,
          X_Group_Id             => X_Group_Id,
          X_User_Je_Category_Name=> X_User_Je_Category_Name,
          X_Currency_Code        => X_Currency_Code,
          X_Budget_Version_Id    => X_Budget_Version_Id,
          X_Period_Name          => X_Period_Name,
          X_Code_Combination_Id  => X_From_Code_Combination_Id,
          X_Combination_Number   => X_Combination_Number,
          X_Entered_Dr           => X_From_Entered_Dr,
          X_Entered_Cr           => X_From_Entered_Cr,
          X_Je_Batch_Name        => X_Je_Batch_Name
  );

  -- Lock the to row
  GL_INTERFACE_PKG.Lock_Budget_Transfer_Row(
          X_Rowid                => X_To_RowId,
	  X_Status		 => X_Status,
          X_Ledger_Id            => X_Ledger_Id,
          X_User_Je_Source_Name  => X_User_Je_Source_Name,
          X_Group_Id             => X_Group_Id,
          X_User_Je_Category_Name=> X_User_Je_Category_Name,
          X_Currency_Code        => X_Currency_Code,
          X_Budget_Version_Id    => X_Budget_Version_Id,
          X_Period_Name          => X_Period_Name,
          X_Code_Combination_Id  => X_To_Code_Combination_Id,
          X_Combination_Number   => X_Combination_Number,
          X_Entered_Dr           => X_To_Entered_Dr,
          X_Entered_Cr           => X_To_Entered_Cr,
          X_Je_Batch_Name        => X_Je_Batch_Name
  );

END Lock_Budget_Transfer_Row;

PROCEDURE Update_Budget_Transfer_Row(
		   X_From_Rowid                            VARCHAR2,
		   X_To_Rowid				   VARCHAR2,
		   X_Status				   VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_User_Je_Source_Name                   VARCHAR2,
		   X_Group_Id				   NUMBER,
                   X_User_Je_Category_Name                 VARCHAR2,
		   X_Budget_Version_Id			   NUMBER,
		   X_Je_Batch_Name			   VARCHAR2,
                   X_Currency_Code                         VARCHAR2,
		   X_From_Code_Combination_Id		   NUMBER,
		   X_To_Code_Combination_Id		   NUMBER,
		   X_Combination_Number			   NUMBER,
		   X_Period_Name			   VARCHAR2,
                   X_From_Entered_Dr                       NUMBER,
                   X_From_Entered_Cr                       NUMBER,
                   X_To_Entered_Dr                         NUMBER,
                   X_To_Entered_Cr                         NUMBER
) IS
BEGIN
  UPDATE GL_INTERFACE
  SET
    status                = X_Status,
    ledger_id             = X_Ledger_Id,
    user_je_source_name   = X_User_Je_Source_Name,
    group_id              = X_Group_Id,
    user_je_category_name = X_User_Je_Category_Name,
    actual_flag           = 'B',
    budget_version_id     = X_Budget_Version_Id,
    reference1            = X_Je_Batch_Name,
    currency_code         = X_Currency_Code,
    code_combination_id   = decode(rowid,
                                   X_From_Rowid, X_From_Code_Combination_Id,
				   X_To_Rowid, X_To_Code_Combination_Id),
    je_batch_id          = X_Combination_Number,
    period_name           = X_Period_Name,
    entered_dr            = decode(rowid,
				   X_From_Rowid, X_From_Entered_Dr,
				   X_To_Rowid, X_To_Entered_Dr),
    entered_cr            = decode(rowid,
				   X_From_Rowid, X_From_Entered_Cr,
				   X_To_Rowid, X_To_Entered_Cr)
  WHERE rowid IN (X_From_Rowid, X_To_RowId);

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Budget_Transfer_Row;

PROCEDURE Delete_Budget_Transfer_Row(X_From_Rowid VARCHAR2,
                                     X_To_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM GL_INTERFACE
  WHERE  rowid IN (X_From_Rowid, X_To_Rowid);

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Budget_Transfer_Row;

  PROCEDURE delete_rows(x_ledger_id           NUMBER,
			x_user_je_source_name VARCHAR2,
			x_group_id	      NUMBER DEFAULT NULL,
			x_je_batch_id	      NUMBER DEFAULT NULL) IS
  BEGIN
    DELETE gl_interface
    WHERE  ledger_id = x_ledger_id
    AND    user_je_source_name = x_user_je_source_name
    AND    nvl(group_id,-1) = nvl(x_group_id, -1)
    AND    nvl(je_batch_id, -1) = nvl(x_je_batch_id, nvl(je_batch_id, -1));
  END delete_rows;

  FUNCTION exists_data(x_ledger_id           NUMBER,
		       x_user_je_source_name VARCHAR2,
		       x_group_id	     NUMBER DEFAULT NULL
                      ) RETURN BOOLEAN IS
    CURSOR check_for_data IS
      SELECT 'Has data'
      FROM dual
      WHERE EXISTS (SELECT 'Has data'
                    FROM gl_interface
                    WHERE ledger_id           = x_ledger_id
		    AND   user_je_source_name = x_user_je_source_name
		    AND   group_id            = x_group_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN check_for_data;
    FETCH check_for_data INTO dummy;

    IF check_for_data%FOUND THEN
      CLOSE check_for_data;
      return(TRUE);
    ELSE
      CLOSE check_for_data;
      return(FALSE);
    END IF;

  END exists_data;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ITABLE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_ACCOUNTING_DATE in DATE,
  X_CURRENCY_CODE in VARCHAR2,
  X_DATE_CREATED in DATE,
  X_CREATED_BY in NUMBER,
  X_ACTUAL_FLAG in VARCHAR2,
  X_USER_JE_CATEGORY_NAME in VARCHAR2,
  X_USER_JE_SOURCE_NAME in VARCHAR2,
  X_CURRENCY_CONVERSION_DATE in DATE,
  X_ENCUMBRANCE_TYPE_ID in NUMBER,
  X_BUDGET_VERSION_ID in NUMBER,
  X_USER_CURRENCY_CONV_TYPE in VARCHAR2,
  X_CURRENCY_CONVERSION_RATE in NUMBER,
  X_AVERAGE_JOURNAL_FLAG in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_SEGMENT8 in VARCHAR2,
  X_SEGMENT9 in VARCHAR2,
  X_SEGMENT10 in VARCHAR2,
  X_SEGMENT11 in VARCHAR2,
  X_SEGMENT12 in VARCHAR2,
  X_SEGMENT13 in VARCHAR2,
  X_SEGMENT14 in VARCHAR2,
  X_SEGMENT15 in VARCHAR2,
  X_SEGMENT16 in VARCHAR2,
  X_SEGMENT17 in VARCHAR2,
  X_SEGMENT18 in VARCHAR2,
  X_SEGMENT19 in VARCHAR2,
  X_SEGMENT20 in VARCHAR2,
  X_SEGMENT21 in VARCHAR2,
  X_SEGMENT22 in VARCHAR2,
  X_SEGMENT23 in VARCHAR2,
  X_SEGMENT24 in VARCHAR2,
  X_SEGMENT25 in VARCHAR2,
  X_SEGMENT26 in VARCHAR2,
  X_SEGMENT27 in VARCHAR2,
  X_SEGMENT28 in VARCHAR2,
  X_SEGMENT29 in VARCHAR2,
  X_SEGMENT30 in VARCHAR2,
  X_ENTERED_DR in NUMBER,
  X_ENTERED_CR in NUMBER,
  X_ACCOUNTED_DR in NUMBER,
  X_ACCOUNTED_CR in NUMBER,
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in VARCHAR2,
  X_REFERENCE3 in VARCHAR2,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  X_REFERENCE6 in VARCHAR2,
  X_REFERENCE7 in VARCHAR2,
  X_REFERENCE8 in VARCHAR2,
  X_REFERENCE9 in VARCHAR2,
  X_REFERENCE10 in VARCHAR2,
  X_REFERENCE11 in VARCHAR2,
  X_REFERENCE12 in VARCHAR2,
  X_REFERENCE13 in VARCHAR2,
  X_REFERENCE14 in VARCHAR2,
  X_REFERENCE15 in VARCHAR2,
  X_REFERENCE16 in VARCHAR2,
  X_REFERENCE17 in VARCHAR2,
  X_REFERENCE18 in VARCHAR2,
  X_REFERENCE19 in VARCHAR2,
  X_REFERENCE20 in VARCHAR2,
  X_REFERENCE21 in VARCHAR2,
  X_REFERENCE22 in VARCHAR2,
  X_REFERENCE23 in VARCHAR2,
  X_REFERENCE24 in VARCHAR2,
  X_REFERENCE25 in VARCHAR2,
  X_REFERENCE26 in VARCHAR2,
  X_REFERENCE27 in VARCHAR2,
  X_REFERENCE28 in VARCHAR2,
  X_REFERENCE29 in VARCHAR2,
  X_REFERENCE30 in VARCHAR2,
  X_PERIOD_NAME in VARCHAR2,
  X_CODE_COMBINATION_ID in NUMBER,
  X_STAT_AMOUNT in NUMBER,
  X_GROUP_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_SUBLEDGER_DOC_SEQUENCE_ID in NUMBER,
  X_SUBLEDGER_DOC_SEQUENCE_VALUE in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_CONTEXT2 in VARCHAR2,
  X_INVOICE_DATE in DATE,
  X_TAX_CODE in VARCHAR2,
  X_INVOICE_IDENTIFIER in VARCHAR2,
  X_INVOICE_AMOUNT in NUMBER,
  X_CONTEXT3 in VARCHAR2,
  X_USSGL_TRANSACTION_CODE in VARCHAR2,
  X_JGZZ_RECON_REF in VARCHAR2,
  X_ORIGINATING_BAL_SEG_VALUE in VARCHAR2,
  X_GL_SL_LINK_ID in NUMBER,
  X_GL_SL_LINK_TABLE in VARCHAR2
) IS
  sqlstmt VARCHAR2(10000);

  STATUS  			VARCHAR2(50);
  LEDGER_ID  			NUMBER;
  ACCOUNTING_DATE  		DATE;
  CURRENCY_CODE  		VARCHAR2(15);
  DATE_CREATED  		DATE;
  CREATED_BY  			NUMBER;
  ACTUAL_FLAG  			VARCHAR2(1);
  USER_JE_CATEGORY_NAME  	VARCHAR2(25);
  USER_JE_SOURCE_NAME  		VARCHAR2(25);
  CURRENCY_CONVERSION_DATE  	DATE;
  ENCUMBRANCE_TYPE_ID  		NUMBER;
  BUDGET_VERSION_ID  		NUMBER;
  USER_CURRENCY_CONVERSION_TYPE VARCHAR2(30);
  CURRENCY_CONVERSION_RATE  	NUMBER;
  AVERAGE_JOURNAL_FLAG  	VARCHAR2(1);
  SEGMENT1  			VARCHAR2(25);
  SEGMENT2  			VARCHAR2(25);
  SEGMENT3  			VARCHAR2(25);
  SEGMENT4  			VARCHAR2(25);
  SEGMENT5  			VARCHAR2(25);
  SEGMENT6  			VARCHAR2(25);
  SEGMENT7  			VARCHAR2(25);
  SEGMENT8  			VARCHAR2(25);
  SEGMENT9  			VARCHAR2(25);
  SEGMENT10  			VARCHAR2(25);
  SEGMENT11  			VARCHAR2(25);
  SEGMENT12  			VARCHAR2(25);
  SEGMENT13  			VARCHAR2(25);
  SEGMENT14  			VARCHAR2(25);
  SEGMENT15  			VARCHAR2(25);
  SEGMENT16  			VARCHAR2(25);
  SEGMENT17  			VARCHAR2(25);
  SEGMENT18  			VARCHAR2(25);
  SEGMENT19  			VARCHAR2(25);
  SEGMENT20  			VARCHAR2(25);
  SEGMENT21  			VARCHAR2(25);
  SEGMENT22 			VARCHAR2(25);
  SEGMENT23  			VARCHAR2(25);
  SEGMENT24  			VARCHAR2(25);
  SEGMENT25  			VARCHAR2(25);
  SEGMENT26  			VARCHAR2(25);
  SEGMENT27  			VARCHAR2(25);
  SEGMENT28  			VARCHAR2(25);
  SEGMENT29  			VARCHAR2(25);
  SEGMENT30  			VARCHAR2(25);
  ENTERED_DR  			NUMBER;
  ENTERED_CR  			NUMBER;
  ACCOUNTED_DR  		NUMBER;
  ACCOUNTED_CR  		NUMBER;
  REFERENCE1  			VARCHAR2(100);
  REFERENCE2  			VARCHAR2(240);
  REFERENCE3  			VARCHAR2(100);
  REFERENCE4  			VARCHAR2(100);
  REFERENCE5  			VARCHAR2(240);
  REFERENCE6  			VARCHAR2(100);
  REFERENCE7  			VARCHAR2(100);
  REFERENCE8  			VARCHAR2(100);
  REFERENCE9  			VARCHAR2(100);
  REFERENCE10  			VARCHAR2(240);
  REFERENCE11  			VARCHAR2(100);
  REFERENCE12  			VARCHAR2(100);
  REFERENCE13  			VARCHAR2(100);
  REFERENCE14  			VARCHAR2(100);
  REFERENCE15  			VARCHAR2(100);
  REFERENCE16  			VARCHAR2(100);
  REFERENCE17  			VARCHAR2(100);
  REFERENCE18  			VARCHAR2(100);
  REFERENCE19  			VARCHAR2(100);
  REFERENCE20  			VARCHAR2(240);
  REFERENCE21  			VARCHAR2(240);
  REFERENCE22  			VARCHAR2(240);
  REFERENCE23  			VARCHAR2(240);
  REFERENCE24  			VARCHAR2(240);
  REFERENCE25  			VARCHAR2(240);
  REFERENCE26  			VARCHAR2(240);
  REFERENCE27  			VARCHAR2(240);
  REFERENCE28  			VARCHAR2(240);
  REFERENCE29  			VARCHAR2(240);
  REFERENCE30  			VARCHAR2(240);
  PERIOD_NAME			VARCHAR2(15);
  CODE_COMBINATION_ID  		NUMBER;
  STAT_AMOUNT  			NUMBER;
  GROUP_ID  			NUMBER;
  REQUEST_ID  			NUMBER;
  SUBLEDGER_DOC_SEQUENCE_ID  	NUMBER;
  SUBLEDGER_DOC_SEQUENCE_VALUE 	NUMBER;
  ATTRIBUTE1  			VARCHAR2(150);
  ATTRIBUTE2  			VARCHAR2(150);
  ATTRIBUTE3  			VARCHAR2(150);
  ATTRIBUTE4  			VARCHAR2(150);
  ATTRIBUTE5  			VARCHAR2(150);
  ATTRIBUTE6  			VARCHAR2(150);
  ATTRIBUTE7  			VARCHAR2(150);
  ATTRIBUTE8  			VARCHAR2(150);
  ATTRIBUTE9  			VARCHAR2(150);
  ATTRIBUTE10  			VARCHAR2(150);
  ATTRIBUTE11  			VARCHAR2(150);
  ATTRIBUTE12  			VARCHAR2(150);
  ATTRIBUTE13  			VARCHAR2(150);
  ATTRIBUTE14  			VARCHAR2(150);
  ATTRIBUTE15  			VARCHAR2(150);
  ATTRIBUTE16  			VARCHAR2(150);
  ATTRIBUTE17  			VARCHAR2(150);
  ATTRIBUTE18  			VARCHAR2(150);
  ATTRIBUTE19  			VARCHAR2(150);
  ATTRIBUTE20  			VARCHAR2(150);
  CONTEXT  			VARCHAR2(150);
  CONTEXT2  			VARCHAR2(150);
  INVOICE_DATE  		DATE;
  TAX_CODE  			VARCHAR2(15);
  INVOICE_IDENTIFIER  		VARCHAR2(20);
  INVOICE_AMOUNT  		NUMBER;
  CONTEXT3  			VARCHAR2(150);
  USSGL_TRANSACTION_CODE  	VARCHAR2(30);
  JGZZ_RECON_REF  		VARCHAR2(240);
  ORIGINATING_BAL_SEG_VALUE	VARCHAR2(25);
  GL_SL_LINK_ID 		NUMBER;
  GL_SL_LINK_TABLE 		VARCHAR2(30);
BEGIN
  sqlstmt := 'select
      STATUS,
      decode(LEDGER_ID, -1, SET_OF_BOOKS_ID, LEDGER_ID),
      ACCOUNTING_DATE,
      CURRENCY_CODE,
      DATE_CREATED,
      CREATED_BY,
      ACTUAL_FLAG,
      USER_JE_CATEGORY_NAME,
      USER_JE_SOURCE_NAME,
      CURRENCY_CONVERSION_DATE,
      ENCUMBRANCE_TYPE_ID,
      BUDGET_VERSION_ID,
      USER_CURRENCY_CONVERSION_TYPE,
      CURRENCY_CONVERSION_RATE,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT11,
      SEGMENT12,
      SEGMENT13,
      SEGMENT14,
      SEGMENT15,
      SEGMENT16,
      SEGMENT17,
      SEGMENT18,
      SEGMENT19,
      SEGMENT20,
      SEGMENT21,
      SEGMENT22,
      SEGMENT23,
      SEGMENT24,
      SEGMENT25,
      SEGMENT26,
      SEGMENT27,
      SEGMENT28,
      SEGMENT29,
      SEGMENT30,
      ENTERED_DR,
      ENTERED_CR,
      ACCOUNTED_DR,
      ACCOUNTED_CR,
      REFERENCE1,
      REFERENCE2,
      REFERENCE3,
      REFERENCE4,
      REFERENCE5,
      REFERENCE6,
      REFERENCE7,
      REFERENCE8,
      REFERENCE9,
      REFERENCE10,
      REFERENCE11,
      REFERENCE12,
      REFERENCE13,
      REFERENCE14,
      REFERENCE15,
      REFERENCE16,
      REFERENCE17,
      REFERENCE18,
      REFERENCE19,
      REFERENCE20,
      REFERENCE21,
      REFERENCE22,
      REFERENCE23,
      REFERENCE24,
      REFERENCE25,
      REFERENCE26,
      REFERENCE27,
      REFERENCE28,
      REFERENCE29,
      REFERENCE30,
      PERIOD_NAME,
      CODE_COMBINATION_ID,
      STAT_AMOUNT,
      GROUP_ID,
      SUBLEDGER_DOC_SEQUENCE_ID,
      SUBLEDGER_DOC_SEQUENCE_VALUE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      CONTEXT,
      CONTEXT2,
      INVOICE_DATE,
      TAX_CODE,
      INVOICE_IDENTIFIER,
      INVOICE_AMOUNT,
      CONTEXT3,
      USSGL_TRANSACTION_CODE,
      JGZZ_RECON_REF,
      AVERAGE_JOURNAL_FLAG,
      ORIGINATING_BAL_SEG_VALUE,
      GL_SL_LINK_ID,
      GL_SL_LINK_TABLE
    from ' || X_ITABLE ||
'   where ROWID = :X_ROWID
    for update of USER_JE_SOURCE_NAME nowait';

  EXECUTE IMMEDIATE sqlstmt
  INTO
      STATUS,
      LEDGER_ID,
      ACCOUNTING_DATE,
      CURRENCY_CODE,
      DATE_CREATED,
      CREATED_BY,
      ACTUAL_FLAG,
      USER_JE_CATEGORY_NAME,
      USER_JE_SOURCE_NAME,
      CURRENCY_CONVERSION_DATE,
      ENCUMBRANCE_TYPE_ID,
      BUDGET_VERSION_ID,
      USER_CURRENCY_CONVERSION_TYPE,
      CURRENCY_CONVERSION_RATE,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT11,
      SEGMENT12,
      SEGMENT13,
      SEGMENT14,
      SEGMENT15,
      SEGMENT16,
      SEGMENT17,
      SEGMENT18,
      SEGMENT19,
      SEGMENT20,
      SEGMENT21,
      SEGMENT22,
      SEGMENT23,
      SEGMENT24,
      SEGMENT25,
      SEGMENT26,
      SEGMENT27,
      SEGMENT28,
      SEGMENT29,
      SEGMENT30,
      ENTERED_DR,
      ENTERED_CR,
      ACCOUNTED_DR,
      ACCOUNTED_CR,
      REFERENCE1,
      REFERENCE2,
      REFERENCE3,
      REFERENCE4,
      REFERENCE5,
      REFERENCE6,
      REFERENCE7,
      REFERENCE8,
      REFERENCE9,
      REFERENCE10,
      REFERENCE11,
      REFERENCE12,
      REFERENCE13,
      REFERENCE14,
      REFERENCE15,
      REFERENCE16,
      REFERENCE17,
      REFERENCE18,
      REFERENCE19,
      REFERENCE20,
      REFERENCE21,
      REFERENCE22,
      REFERENCE23,
      REFERENCE24,
      REFERENCE25,
      REFERENCE26,
      REFERENCE27,
      REFERENCE28,
      REFERENCE29,
      REFERENCE30,
      PERIOD_NAME,
      CODE_COMBINATION_ID,
      STAT_AMOUNT,
      GROUP_ID,
      SUBLEDGER_DOC_SEQUENCE_ID,
      SUBLEDGER_DOC_SEQUENCE_VALUE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      CONTEXT,
      CONTEXT2,
      INVOICE_DATE,
      TAX_CODE,
      INVOICE_IDENTIFIER,
      INVOICE_AMOUNT,
      CONTEXT3,
      USSGL_TRANSACTION_CODE,
      JGZZ_RECON_REF,
      AVERAGE_JOURNAL_FLAG,
      ORIGINATING_BAL_SEG_VALUE,
      GL_SL_LINK_ID,
      GL_SL_LINK_TABLE
  USING X_ROWID;

  IF (    (rtrim(STATUS) = X_STATUS)
      AND (LEDGER_ID = X_LEDGER_ID)
      AND (ACCOUNTING_DATE = X_ACCOUNTING_DATE)
      AND (CURRENCY_CODE = X_CURRENCY_CODE)
      AND (DATE_CREATED = X_DATE_CREATED)
      AND (CREATED_BY = X_CREATED_BY)
      AND (ACTUAL_FLAG = X_ACTUAL_FLAG)
      AND (USER_JE_CATEGORY_NAME = X_USER_JE_CATEGORY_NAME)
      AND (USER_JE_SOURCE_NAME = X_USER_JE_SOURCE_NAME)
      AND ((CURRENCY_CONVERSION_DATE = X_CURRENCY_CONVERSION_DATE)
           OR ((CURRENCY_CONVERSION_DATE is null) AND (X_CURRENCY_CONVERSION_DATE is null)))
      AND ((ENCUMBRANCE_TYPE_ID = X_ENCUMBRANCE_TYPE_ID)
           OR ((ENCUMBRANCE_TYPE_ID is null) AND (X_ENCUMBRANCE_TYPE_ID is null)))
      AND ((BUDGET_VERSION_ID = X_BUDGET_VERSION_ID)
           OR ((BUDGET_VERSION_ID is null) AND (X_BUDGET_VERSION_ID is null)))
      AND ((USER_CURRENCY_CONVERSION_TYPE = X_USER_CURRENCY_CONV_TYPE)
           OR ((USER_CURRENCY_CONVERSION_TYPE is null) AND (X_USER_CURRENCY_CONV_TYPE is null)))
      AND ((CURRENCY_CONVERSION_RATE = X_CURRENCY_CONVERSION_RATE)
           OR ((CURRENCY_CONVERSION_RATE is null) AND (X_CURRENCY_CONVERSION_RATE is null)))
      AND ((AVERAGE_JOURNAL_FLAG = X_AVERAGE_JOURNAL_FLAG)
           OR ((AVERAGE_JOURNAL_FLAG is null) AND (X_AVERAGE_JOURNAL_FLAG is null)))
      AND ((SEGMENT1 = X_SEGMENT1)
           OR ((SEGMENT1 is null) AND (X_SEGMENT1 is null)))
      AND ((SEGMENT2 = X_SEGMENT2)
           OR ((SEGMENT2 is null) AND (X_SEGMENT2 is null)))
      AND ((SEGMENT3 = X_SEGMENT3)
           OR ((SEGMENT3 is null) AND (X_SEGMENT3 is null)))
      AND ((SEGMENT4 = X_SEGMENT4)
           OR ((SEGMENT4 is null) AND (X_SEGMENT4 is null)))
      AND ((SEGMENT5 = X_SEGMENT5)
           OR ((SEGMENT5 is null) AND (X_SEGMENT5 is null)))
      AND ((SEGMENT6 = X_SEGMENT6)
           OR ((SEGMENT6 is null) AND (X_SEGMENT6 is null)))
      AND ((SEGMENT7 = X_SEGMENT7)
           OR ((SEGMENT7 is null) AND (X_SEGMENT7 is null)))
      AND ((SEGMENT8 = X_SEGMENT8)
           OR ((SEGMENT8 is null) AND (X_SEGMENT8 is null)))
      AND ((SEGMENT9 = X_SEGMENT9)
           OR ((SEGMENT9 is null) AND (X_SEGMENT9 is null)))
      AND ((SEGMENT10 = X_SEGMENT10)
           OR ((SEGMENT10 is null) AND (X_SEGMENT10 is null)))
      AND ((SEGMENT11 = X_SEGMENT11)
           OR ((SEGMENT11 is null) AND (X_SEGMENT11 is null)))
      AND ((SEGMENT12 = X_SEGMENT12)
           OR ((SEGMENT12 is null) AND (X_SEGMENT12 is null)))
      AND ((SEGMENT13 = X_SEGMENT13)
           OR ((SEGMENT13 is null) AND (X_SEGMENT13 is null)))
      AND ((SEGMENT14 = X_SEGMENT14)
           OR ((SEGMENT14 is null) AND (X_SEGMENT14 is null)))
      AND ((SEGMENT15 = X_SEGMENT15)
           OR ((SEGMENT15 is null) AND (X_SEGMENT15 is null)))
      AND ((SEGMENT16 = X_SEGMENT16)
           OR ((SEGMENT16 is null) AND (X_SEGMENT16 is null)))
      AND ((SEGMENT17 = X_SEGMENT17)
           OR ((SEGMENT17 is null) AND (X_SEGMENT17 is null)))
      AND ((SEGMENT18 = X_SEGMENT18)
           OR ((SEGMENT18 is null) AND (X_SEGMENT18 is null)))
      AND ((SEGMENT19 = X_SEGMENT19)
           OR ((SEGMENT19 is null) AND (X_SEGMENT19 is null)))
      AND ((SEGMENT20 = X_SEGMENT20)
           OR ((SEGMENT20 is null) AND (X_SEGMENT20 is null)))
      AND ((SEGMENT21 = X_SEGMENT21)
           OR ((SEGMENT21 is null) AND (X_SEGMENT21 is null)))
      AND ((SEGMENT22 = X_SEGMENT22)
           OR ((SEGMENT22 is null) AND (X_SEGMENT22 is null)))
      AND ((SEGMENT23 = X_SEGMENT23)
           OR ((SEGMENT23 is null) AND (X_SEGMENT23 is null)))
      AND ((SEGMENT24 = X_SEGMENT24)
           OR ((SEGMENT24 is null) AND (X_SEGMENT24 is null)))
      AND ((SEGMENT25 = X_SEGMENT25)
           OR ((SEGMENT25 is null) AND (X_SEGMENT25 is null)))
      AND ((SEGMENT26 = X_SEGMENT26)
           OR ((SEGMENT26 is null) AND (X_SEGMENT26 is null)))
      AND ((SEGMENT27 = X_SEGMENT27)
           OR ((SEGMENT27 is null) AND (X_SEGMENT27 is null)))
      AND ((SEGMENT28 = X_SEGMENT28)
           OR ((SEGMENT28 is null) AND (X_SEGMENT28 is null)))
      AND ((SEGMENT29 = X_SEGMENT29)
           OR ((SEGMENT29 is null) AND (X_SEGMENT29 is null)))
      AND ((SEGMENT30 = X_SEGMENT30)
           OR ((SEGMENT30 is null) AND (X_SEGMENT30 is null)))
      AND ((ENTERED_DR = X_ENTERED_DR)
           OR ((ENTERED_DR is null) AND (X_ENTERED_DR is null)))
      AND ((ENTERED_CR = X_ENTERED_CR)
           OR ((ENTERED_CR is null) AND (X_ENTERED_CR is null)))
      AND ((ACCOUNTED_DR = X_ACCOUNTED_DR)
           OR ((ACCOUNTED_DR is null) AND (X_ACCOUNTED_DR is null)))
      AND ((ACCOUNTED_CR = X_ACCOUNTED_CR)
           OR ((ACCOUNTED_CR is null) AND (X_ACCOUNTED_CR is null)))
      AND ((rtrim(REFERENCE1) = X_REFERENCE1)
           OR ((rtrim(REFERENCE1) is null) AND (X_REFERENCE1 is null)))
      AND ((rtrim(REFERENCE2) = X_REFERENCE2)
           OR ((rtrim(REFERENCE2) is null) AND (X_REFERENCE2 is null)))
      AND ((rtrim(REFERENCE3) = X_REFERENCE3)
           OR ((rtrim(REFERENCE3) is null) AND (X_REFERENCE3 is null)))
      AND ((rtrim(REFERENCE4) = X_REFERENCE4)
           OR ((rtrim(REFERENCE4) is null) AND (X_REFERENCE4 is null)))
      AND ((rtrim(REFERENCE5) = X_REFERENCE5)
           OR ((rtrim(REFERENCE5) is null) AND (X_REFERENCE5 is null)))
      AND ((rtrim(REFERENCE6) = X_REFERENCE6)
           OR ((rtrim(REFERENCE6) is null) AND (X_REFERENCE6 is null)))
      AND ((rtrim(REFERENCE7) = X_REFERENCE7)
           OR ((rtrim(REFERENCE7) is null) AND (X_REFERENCE7 is null)))
      AND ((rtrim(REFERENCE8) = X_REFERENCE8)
           OR ((rtrim(REFERENCE8) is null) AND (X_REFERENCE8 is null)))
      AND ((rtrim(REFERENCE9) = X_REFERENCE9)
           OR ((rtrim(REFERENCE9) is null) AND (X_REFERENCE9 is null)))
      AND ((rtrim(REFERENCE10) = X_REFERENCE10)
           OR ((rtrim(REFERENCE10) is null) AND (X_REFERENCE10 is null)))
      AND ((rtrim(REFERENCE11) = X_REFERENCE11)
           OR ((rtrim(REFERENCE11) is null) AND (X_REFERENCE11 is null)))
      AND ((rtrim(REFERENCE12) = X_REFERENCE12)
           OR ((rtrim(REFERENCE12) is null) AND (X_REFERENCE12 is null)))
      AND ((rtrim(REFERENCE13) = X_REFERENCE13)
           OR ((rtrim(REFERENCE13) is null) AND (X_REFERENCE13 is null)))
      AND ((rtrim(REFERENCE14) = X_REFERENCE14)
           OR ((rtrim(REFERENCE14) is null) AND (X_REFERENCE14 is null)))
      AND ((rtrim(REFERENCE15) = X_REFERENCE15)
           OR ((rtrim(REFERENCE15) is null) AND (X_REFERENCE15 is null)))
      AND ((rtrim(REFERENCE16) = X_REFERENCE16)
           OR ((rtrim(REFERENCE16) is null) AND (X_REFERENCE16 is null)))
      AND ((rtrim(REFERENCE17) = X_REFERENCE17)
           OR ((rtrim(REFERENCE17) is null) AND (X_REFERENCE17 is null)))
      AND ((rtrim(REFERENCE18) = X_REFERENCE18)
           OR ((rtrim(REFERENCE18) is null) AND (X_REFERENCE18 is null)))
      AND ((rtrim(REFERENCE19) = X_REFERENCE19)
           OR ((rtrim(REFERENCE19) is null) AND (X_REFERENCE19 is null)))
      AND ((rtrim(REFERENCE20) = X_REFERENCE20)
           OR ((rtrim(REFERENCE20) is null) AND (X_REFERENCE20 is null)))
      AND ((rtrim(REFERENCE21) = X_REFERENCE21)
           OR ((rtrim(REFERENCE21) is null) AND (X_REFERENCE21 is null)))
      AND ((rtrim(REFERENCE22) = X_REFERENCE22)
           OR ((rtrim(REFERENCE22) is null) AND (X_REFERENCE22 is null)))
      AND ((rtrim(REFERENCE23) = X_REFERENCE23)
           OR ((rtrim(REFERENCE23) is null) AND (X_REFERENCE23 is null)))
      AND ((rtrim(REFERENCE24) = X_REFERENCE24)
           OR ((rtrim(REFERENCE24) is null) AND (X_REFERENCE24 is null)))
      AND ((rtrim(REFERENCE25) = X_REFERENCE25)
           OR ((rtrim(REFERENCE25) is null) AND (X_REFERENCE25 is null)))
      AND ((rtrim(REFERENCE26) = X_REFERENCE26)
           OR ((rtrim(REFERENCE26) is null) AND (X_REFERENCE26 is null)))
      AND ((rtrim(REFERENCE27) = X_REFERENCE27)
           OR ((rtrim(REFERENCE27) is null) AND (X_REFERENCE27 is null)))
      AND ((rtrim(REFERENCE28) = X_REFERENCE28)
           OR ((rtrim(REFERENCE28) is null) AND (X_REFERENCE28 is null)))
      AND ((rtrim(REFERENCE29) = X_REFERENCE29)
           OR ((rtrim(REFERENCE29) is null) AND (X_REFERENCE29 is null)))
      AND ((rtrim(REFERENCE30) = X_REFERENCE30)
           OR ((rtrim(REFERENCE30) is null) AND (X_REFERENCE30 is null)))
      AND ((PERIOD_NAME = X_PERIOD_NAME)
           OR ((PERIOD_NAME is null) AND (X_PERIOD_NAME is null)))
      AND ((CODE_COMBINATION_ID = X_CODE_COMBINATION_ID)
           OR ((CODE_COMBINATION_ID is null) AND (X_CODE_COMBINATION_ID is null)))
      AND ((STAT_AMOUNT = X_STAT_AMOUNT)
           OR ((STAT_AMOUNT is null) AND (X_STAT_AMOUNT is null)))
      AND ((GROUP_ID = X_GROUP_ID)
           OR ((GROUP_ID is null) AND (X_GROUP_ID is null)))
      AND ((SUBLEDGER_DOC_SEQUENCE_ID = X_SUBLEDGER_DOC_SEQUENCE_ID)
           OR ((SUBLEDGER_DOC_SEQUENCE_ID is null) AND (X_SUBLEDGER_DOC_SEQUENCE_ID is null)))
      AND ((SUBLEDGER_DOC_SEQUENCE_VALUE = X_SUBLEDGER_DOC_SEQUENCE_VALUE)
           OR ((SUBLEDGER_DOC_SEQUENCE_VALUE is null) AND (X_SUBLEDGER_DOC_SEQUENCE_VALUE is null)))
      AND ((rtrim(ATTRIBUTE1) = X_ATTRIBUTE1)
           OR ((rtrim(ATTRIBUTE1) is null) AND (X_ATTRIBUTE1 is null)))
      AND ((rtrim(ATTRIBUTE2) = X_ATTRIBUTE2)
           OR ((rtrim(ATTRIBUTE2) is null) AND (X_ATTRIBUTE2 is null)))
      AND ((rtrim(ATTRIBUTE3) = X_ATTRIBUTE3)
           OR ((rtrim(ATTRIBUTE3) is null) AND (X_ATTRIBUTE3 is null)))
      AND ((rtrim(ATTRIBUTE4) = X_ATTRIBUTE4)
           OR ((rtrim(ATTRIBUTE4) is null) AND (X_ATTRIBUTE4 is null)))
      AND ((rtrim(ATTRIBUTE5) = X_ATTRIBUTE5)
           OR ((rtrim(ATTRIBUTE5) is null) AND (X_ATTRIBUTE5 is null)))
      AND ((rtrim(ATTRIBUTE6) = X_ATTRIBUTE6)
           OR ((rtrim(ATTRIBUTE6) is null) AND (X_ATTRIBUTE6 is null)))
      AND ((rtrim(ATTRIBUTE7) = X_ATTRIBUTE7)
           OR ((rtrim(ATTRIBUTE7) is null) AND (X_ATTRIBUTE7 is null)))
      AND ((rtrim(ATTRIBUTE8) = X_ATTRIBUTE8)
           OR ((rtrim(ATTRIBUTE8) is null) AND (X_ATTRIBUTE8 is null)))
      AND ((rtrim(ATTRIBUTE9) = X_ATTRIBUTE9)
           OR ((rtrim(ATTRIBUTE9) is null) AND (X_ATTRIBUTE9 is null)))
      AND ((rtrim(ATTRIBUTE10) = X_ATTRIBUTE10)
           OR ((rtrim(ATTRIBUTE10) is null) AND (X_ATTRIBUTE10 is null)))
      AND ((rtrim(ATTRIBUTE11) = X_ATTRIBUTE11)
           OR ((rtrim(ATTRIBUTE11) is null) AND (X_ATTRIBUTE11 is null)))
      AND ((rtrim(ATTRIBUTE12) = X_ATTRIBUTE12)
           OR ((rtrim(ATTRIBUTE12) is null) AND (X_ATTRIBUTE12 is null)))
      AND ((rtrim(ATTRIBUTE13) = X_ATTRIBUTE13)
           OR ((rtrim(ATTRIBUTE13) is null) AND (X_ATTRIBUTE13 is null)))
      AND ((rtrim(ATTRIBUTE14) = X_ATTRIBUTE14)
           OR ((rtrim(ATTRIBUTE14) is null) AND (X_ATTRIBUTE14 is null)))
      AND ((rtrim(ATTRIBUTE15) = X_ATTRIBUTE15)
           OR ((rtrim(ATTRIBUTE15) is null) AND (X_ATTRIBUTE15 is null)))
      AND ((rtrim(ATTRIBUTE16) = X_ATTRIBUTE16)
           OR ((rtrim(ATTRIBUTE16) is null) AND (X_ATTRIBUTE16 is null)))
      AND ((rtrim(ATTRIBUTE17) = X_ATTRIBUTE17)
           OR ((rtrim(ATTRIBUTE17) is null) AND (X_ATTRIBUTE17 is null)))
      AND ((rtrim(ATTRIBUTE18) = X_ATTRIBUTE18)
           OR ((rtrim(ATTRIBUTE18) is null) AND (X_ATTRIBUTE18 is null)))
      AND ((rtrim(ATTRIBUTE19) = X_ATTRIBUTE19)
           OR ((rtrim(ATTRIBUTE19) is null) AND (X_ATTRIBUTE19 is null)))
      AND ((rtrim(ATTRIBUTE20) = X_ATTRIBUTE20)
           OR ((rtrim(ATTRIBUTE20) is null) AND (X_ATTRIBUTE20 is null)))
      AND ((rtrim(CONTEXT) = X_CONTEXT)
           OR ((rtrim(CONTEXT) is null) AND (X_CONTEXT is null)))
      AND ((rtrim(CONTEXT2) = X_CONTEXT2)
           OR ((rtrim(CONTEXT2) is null) AND (X_CONTEXT2 is null)))
      AND ((INVOICE_DATE = X_INVOICE_DATE)
           OR ((INVOICE_DATE is null) AND (X_INVOICE_DATE is null)))
      AND ((rtrim(TAX_CODE) = X_TAX_CODE)
           OR ((rtrim(TAX_CODE) is null) AND (X_TAX_CODE is null)))
      AND ((rtrim(INVOICE_IDENTIFIER) = X_INVOICE_IDENTIFIER)
           OR ((rtrim(INVOICE_IDENTIFIER) is null) AND (X_INVOICE_IDENTIFIER is null)))
      AND ((INVOICE_AMOUNT = X_INVOICE_AMOUNT)
           OR ((INVOICE_AMOUNT is null) AND (X_INVOICE_AMOUNT is null)))
      AND ((rtrim(CONTEXT3) = X_CONTEXT3)
           OR ((rtrim(CONTEXT3) is null) AND (X_CONTEXT3 is null)))
      AND ((USSGL_TRANSACTION_CODE = X_USSGL_TRANSACTION_CODE)
           OR ((USSGL_TRANSACTION_CODE is null) AND (X_USSGL_TRANSACTION_CODE is null)))
      AND ((JGZZ_RECON_REF = X_JGZZ_RECON_REF)
           OR ((JGZZ_RECON_REF is null) AND (X_JGZZ_RECON_REF is null)))
      AND ((ORIGINATING_BAL_SEG_VALUE = X_ORIGINATING_BAL_SEG_VALUE)
           OR ((ORIGINATING_BAL_SEG_VALUE is null) AND (X_ORIGINATING_BAL_SEG_VALUE is null)))
      AND ((GL_SL_LINK_ID = X_GL_SL_LINK_ID)
           OR ((GL_SL_LINK_ID is null) AND (X_GL_SL_LINK_ID is null)))
      AND ((GL_SL_LINK_TABLE = X_GL_SL_LINK_TABLE)
           OR ((GL_SL_LINK_TABLE is null) AND (X_GL_SL_LINK_TABLE is null)))
     ) THEN
    null;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
end lock_row;


procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ITABLE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_ACCOUNTING_DATE in DATE,
  X_CURRENCY_CODE in VARCHAR2,
  X_DATE_CREATED in DATE,
  X_CREATED_BY in NUMBER,
  X_ACTUAL_FLAG in VARCHAR2,
  X_USER_JE_CATEGORY_NAME in VARCHAR2,
  X_USER_JE_SOURCE_NAME in VARCHAR2,
  X_CURRENCY_CONVERSION_DATE in DATE,
  X_ENCUMBRANCE_TYPE_ID in NUMBER,
  X_BUDGET_VERSION_ID in NUMBER,
  X_USER_CURRENCY_CONV_TYPE in VARCHAR2,
  X_CURRENCY_CONVERSION_RATE in NUMBER,
  X_AVERAGE_JOURNAL_FLAG in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_SEGMENT8 in VARCHAR2,
  X_SEGMENT9 in VARCHAR2,
  X_SEGMENT10 in VARCHAR2,
  X_SEGMENT11 in VARCHAR2,
  X_SEGMENT12 in VARCHAR2,
  X_SEGMENT13 in VARCHAR2,
  X_SEGMENT14 in VARCHAR2,
  X_SEGMENT15 in VARCHAR2,
  X_SEGMENT16 in VARCHAR2,
  X_SEGMENT17 in VARCHAR2,
  X_SEGMENT18 in VARCHAR2,
  X_SEGMENT19 in VARCHAR2,
  X_SEGMENT20 in VARCHAR2,
  X_SEGMENT21 in VARCHAR2,
  X_SEGMENT22 in VARCHAR2,
  X_SEGMENT23 in VARCHAR2,
  X_SEGMENT24 in VARCHAR2,
  X_SEGMENT25 in VARCHAR2,
  X_SEGMENT26 in VARCHAR2,
  X_SEGMENT27 in VARCHAR2,
  X_SEGMENT28 in VARCHAR2,
  X_SEGMENT29 in VARCHAR2,
  X_SEGMENT30 in VARCHAR2,
  X_ENTERED_DR in NUMBER,
  X_ENTERED_CR in NUMBER,
  X_ACCOUNTED_DR in NUMBER,
  X_ACCOUNTED_CR in NUMBER,
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in VARCHAR2,
  X_REFERENCE3 in VARCHAR2,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  X_REFERENCE6 in VARCHAR2,
  X_REFERENCE7 in VARCHAR2,
  X_REFERENCE8 in VARCHAR2,
  X_REFERENCE9 in VARCHAR2,
  X_REFERENCE10 in VARCHAR2,
  X_REFERENCE11 in VARCHAR2,
  X_REFERENCE12 in VARCHAR2,
  X_REFERENCE13 in VARCHAR2,
  X_REFERENCE14 in VARCHAR2,
  X_REFERENCE15 in VARCHAR2,
  X_REFERENCE16 in VARCHAR2,
  X_REFERENCE17 in VARCHAR2,
  X_REFERENCE18 in VARCHAR2,
  X_REFERENCE19 in VARCHAR2,
  X_REFERENCE20 in VARCHAR2,
  X_REFERENCE21 in VARCHAR2,
  X_REFERENCE22 in VARCHAR2,
  X_REFERENCE23 in VARCHAR2,
  X_REFERENCE24 in VARCHAR2,
  X_REFERENCE25 in VARCHAR2,
  X_REFERENCE26 in VARCHAR2,
  X_REFERENCE27 in VARCHAR2,
  X_REFERENCE28 in VARCHAR2,
  X_REFERENCE29 in VARCHAR2,
  X_REFERENCE30 in VARCHAR2,
  X_PERIOD_NAME in VARCHAR2,
  X_CODE_COMBINATION_ID in NUMBER,
  X_STAT_AMOUNT in NUMBER,
  X_GROUP_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_SUBLEDGER_DOC_SEQUENCE_ID in NUMBER,
  X_SUBLEDGER_DOC_SEQUENCE_VALUE in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_CONTEXT2 in VARCHAR2,
  X_INVOICE_DATE in DATE,
  X_TAX_CODE in VARCHAR2,
  X_INVOICE_IDENTIFIER in VARCHAR2,
  X_INVOICE_AMOUNT in NUMBER,
  X_CONTEXT3 in VARCHAR2,
  X_USSGL_TRANSACTION_CODE in VARCHAR2,
  X_JGZZ_RECON_REF in VARCHAR2,
  X_ORIGINATING_BAL_SEG_VALUE in VARCHAR2,
  X_GL_SL_LINK_ID in NUMBER,
  X_GL_SL_LINK_TABLE in VARCHAR2
) IS
  sqlstmt	VARCHAR2(10000);
BEGIN
sqlstmt :=
 'update ' || X_ITABLE || ' set
    STATUS = :X_STATUS,
    LEDGER_ID = :X_LEDGER_ID,
    ACCOUNTING_DATE = :X_ACCOUNTING_DATE,
    CURRENCY_CODE = :X_CURRENCY_CODE,
    DATE_CREATED = :X_DATE_CREATED,
    CREATED_BY = :X_CREATED_BY,
    ACTUAL_FLAG = :X_ACTUAL_FLAG,
    USER_JE_CATEGORY_NAME = :X_USER_JE_CATEGORY_NAME,
    USER_JE_SOURCE_NAME = :X_USER_JE_SOURCE_NAME,
    CURRENCY_CONVERSION_DATE = :X_CURRENCY_CONVERSION_DATE,
    ENCUMBRANCE_TYPE_ID = :X_ENCUMBRANCE_TYPE_ID,
    BUDGET_VERSION_ID = :X_BUDGET_VERSION_ID,
    USER_CURRENCY_CONVERSION_TYPE = :X_USER_CURRENCY_CONV_TYPE,
    CURRENCY_CONVERSION_RATE = :X_CURRENCY_CONVERSION_RATE,
    AVERAGE_JOURNAL_FLAG = :X_AVERAGE_JOURNAL_FLAG,
    SEGMENT1 = :X_SEGMENT1,
    SEGMENT2 = :X_SEGMENT2,
    SEGMENT3 = :X_SEGMENT3,
    SEGMENT4 = :X_SEGMENT4,
    SEGMENT5 = :X_SEGMENT5,
    SEGMENT6 = :X_SEGMENT6,
    SEGMENT7 = :X_SEGMENT7,
    SEGMENT8 = :X_SEGMENT8,
    SEGMENT9 = :X_SEGMENT9,
    SEGMENT10 = :X_SEGMENT10,
    SEGMENT11 = :X_SEGMENT11,
    SEGMENT12 = :X_SEGMENT12,
    SEGMENT13 = :X_SEGMENT13,
    SEGMENT14 = :X_SEGMENT14,
    SEGMENT15 = :X_SEGMENT15,
    SEGMENT16 = :X_SEGMENT16,
    SEGMENT17 = :X_SEGMENT17,
    SEGMENT18 = :X_SEGMENT18,
    SEGMENT19 = :X_SEGMENT19,
    SEGMENT20 = :X_SEGMENT20,
    SEGMENT21 = :X_SEGMENT21,
    SEGMENT22 = :X_SEGMENT22,
    SEGMENT23 = :X_SEGMENT23,
    SEGMENT24 = :X_SEGMENT24,
    SEGMENT25 = :X_SEGMENT25,
    SEGMENT26 = :X_SEGMENT26,
    SEGMENT27 = :X_SEGMENT27,
    SEGMENT28 = :X_SEGMENT28,
    SEGMENT29 = :X_SEGMENT29,
    SEGMENT30 = :X_SEGMENT30,
    ENTERED_DR = :X_ENTERED_DR,
    ENTERED_CR = :X_ENTERED_CR,
    ACCOUNTED_DR = :X_ACCOUNTED_DR,
    ACCOUNTED_CR = :X_ACCOUNTED_CR,
    REFERENCE1 = :X_REFERENCE1,
    REFERENCE2 = :X_REFERENCE2,
    REFERENCE3 = :X_REFERENCE3,
    REFERENCE4 = :X_REFERENCE4,
    REFERENCE5 = :X_REFERENCE5,
    REFERENCE6 = :X_REFERENCE6,
    REFERENCE7 = :X_REFERENCE7,
    REFERENCE8 = :X_REFERENCE8,
    REFERENCE9 = :X_REFERENCE9,
    REFERENCE10 = :X_REFERENCE10,
    REFERENCE11 = :X_REFERENCE11,
    REFERENCE12 = :X_REFERENCE12,
    REFERENCE13 = :X_REFERENCE13,
    REFERENCE14 = :X_REFERENCE14,
    REFERENCE15 = :X_REFERENCE15,
    REFERENCE16 = :X_REFERENCE16,
    REFERENCE17 = :X_REFERENCE17,
    REFERENCE18 = :X_REFERENCE18,
    REFERENCE19 = :X_REFERENCE19,
    REFERENCE20 = :X_REFERENCE20,
    REFERENCE21 = :X_REFERENCE21,
    REFERENCE22 = :X_REFERENCE22,
    REFERENCE23 = :X_REFERENCE23,
    REFERENCE24 = :X_REFERENCE24,
    REFERENCE25 = :X_REFERENCE25,
    REFERENCE26 = :X_REFERENCE26,
    REFERENCE27 = :X_REFERENCE27,
    REFERENCE28 = :X_REFERENCE28,
    REFERENCE29 = :X_REFERENCE29,
    REFERENCE30 = :X_REFERENCE30,
    PERIOD_NAME = :X_PERIOD_NAME,
    CODE_COMBINATION_ID = :X_CODE_COMBINATION_ID,
    STAT_AMOUNT = :X_STAT_AMOUNT,
    GROUP_ID = :X_GROUP_ID,
    REQUEST_ID = :X_REQUEST_ID,
    SUBLEDGER_DOC_SEQUENCE_ID = :X_SUBLEDGER_DOC_SEQUENCE_ID,
    SUBLEDGER_DOC_SEQUENCE_VALUE = :X_SUBLEDGER_DOC_SEQUENCE_VALUE,
    ATTRIBUTE1 = :X_ATTRIBUTE1,
    ATTRIBUTE2 = :X_ATTRIBUTE2,
    ATTRIBUTE3 = :X_ATTRIBUTE3,
    ATTRIBUTE4 = :X_ATTRIBUTE4,
    ATTRIBUTE5 = :X_ATTRIBUTE5,
    ATTRIBUTE6 = :X_ATTRIBUTE6,
    ATTRIBUTE7 = :X_ATTRIBUTE7,
    ATTRIBUTE8 = :X_ATTRIBUTE8,
    ATTRIBUTE9 = :X_ATTRIBUTE9,
    ATTRIBUTE10 = :X_ATTRIBUTE10,
    ATTRIBUTE11 = :X_ATTRIBUTE11,
    ATTRIBUTE12 = :X_ATTRIBUTE12,
    ATTRIBUTE13 = :X_ATTRIBUTE13,
    ATTRIBUTE14 = :X_ATTRIBUTE14,
    ATTRIBUTE15 = :X_ATTRIBUTE15,
    ATTRIBUTE16 = :X_ATTRIBUTE16,
    ATTRIBUTE17 = :X_ATTRIBUTE17,
    ATTRIBUTE18 = :X_ATTRIBUTE18,
    ATTRIBUTE19 = :X_ATTRIBUTE19,
    ATTRIBUTE20 = :X_ATTRIBUTE20,
    CONTEXT = :X_CONTEXT,
    CONTEXT2 = :X_CONTEXT2,
    INVOICE_DATE = :X_INVOICE_DATE,
    TAX_CODE = :X_TAX_CODE,
    INVOICE_IDENTIFIER = :X_INVOICE_IDENTIFIER,
    INVOICE_AMOUNT = :X_INVOICE_AMOUNT,
    CONTEXT3 = :X_CONTEXT3,
    USSGL_TRANSACTION_CODE = :X_USSGL_TRANSACTION_CODE,
    JGZZ_RECON_REF = :X_JGZZ_RECON_REF,
    ORIGINATING_BAL_SEG_VALUE = :X_ORIGINATING_BAL_SEG_VALUE,
    GL_SL_LINK_ID = :X_GL_SL_LINK_ID,
    GL_SL_LINK_TABLE = :X_GL_SL_LINK_TABLE
  where ROWID = :X_ROWID';

  EXECUTE IMMEDIATE sqlstmt
  USING
      X_STATUS,
      X_LEDGER_ID,
      X_ACCOUNTING_DATE,
      X_CURRENCY_CODE,
      X_DATE_CREATED,
      X_CREATED_BY,
      X_ACTUAL_FLAG,
      X_USER_JE_CATEGORY_NAME,
      X_USER_JE_SOURCE_NAME,
      X_CURRENCY_CONVERSION_DATE,
      X_ENCUMBRANCE_TYPE_ID,
      X_BUDGET_VERSION_ID,
      X_USER_CURRENCY_CONV_TYPE,
      X_CURRENCY_CONVERSION_RATE,
      X_AVERAGE_JOURNAL_FLAG,
      X_SEGMENT1,
      X_SEGMENT2,
      X_SEGMENT3,
      X_SEGMENT4,
      X_SEGMENT5,
      X_SEGMENT6,
      X_SEGMENT7,
      X_SEGMENT8,
      X_SEGMENT9,
      X_SEGMENT10,
      X_SEGMENT11,
      X_SEGMENT12,
      X_SEGMENT13,
      X_SEGMENT14,
      X_SEGMENT15,
      X_SEGMENT16,
      X_SEGMENT17,
      X_SEGMENT18,
      X_SEGMENT19,
      X_SEGMENT20,
      X_SEGMENT21,
      X_SEGMENT22,
      X_SEGMENT23,
      X_SEGMENT24,
      X_SEGMENT25,
      X_SEGMENT26,
      X_SEGMENT27,
      X_SEGMENT28,
      X_SEGMENT29,
      X_SEGMENT30,
      X_ENTERED_DR,
      X_ENTERED_CR,
      X_ACCOUNTED_DR,
      X_ACCOUNTED_CR,
      X_REFERENCE1,
      X_REFERENCE2,
      X_REFERENCE3,
      X_REFERENCE4,
      X_REFERENCE5,
      X_REFERENCE6,
      X_REFERENCE7,
      X_REFERENCE8,
      X_REFERENCE9,
      X_REFERENCE10,
      X_REFERENCE11,
      X_REFERENCE12,
      X_REFERENCE13,
      X_REFERENCE14,
      X_REFERENCE15,
      X_REFERENCE16,
      X_REFERENCE17,
      X_REFERENCE18,
      X_REFERENCE19,
      X_REFERENCE20,
      X_REFERENCE21,
      X_REFERENCE22,
      X_REFERENCE23,
      X_REFERENCE24,
      X_REFERENCE25,
      X_REFERENCE26,
      X_REFERENCE27,
      X_REFERENCE28,
      X_REFERENCE29,
      X_REFERENCE30,
      X_PERIOD_NAME,
      X_CODE_COMBINATION_ID,
      X_STAT_AMOUNT,
      X_GROUP_ID,
      X_REQUEST_ID,
      X_SUBLEDGER_DOC_SEQUENCE_ID,
      X_SUBLEDGER_DOC_SEQUENCE_VALUE,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15,
      X_ATTRIBUTE16,
      X_ATTRIBUTE17,
      X_ATTRIBUTE18,
      X_ATTRIBUTE19,
      X_ATTRIBUTE20,
      X_CONTEXT,
      X_CONTEXT2,
      X_INVOICE_DATE,
      X_TAX_CODE,
      X_INVOICE_IDENTIFIER,
      X_INVOICE_AMOUNT,
      X_CONTEXT3,
      X_USSGL_TRANSACTION_CODE,
      X_JGZZ_RECON_REF,
      X_ORIGINATING_BAL_SEG_VALUE,
      X_GL_SL_LINK_ID,
      X_GL_SL_LINK_TABLE,
      X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
  null;
END update_row;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  X_ITABLE in VARCHAR2
) IS
  sqlstmt VARCHAR2(2000);
BEGIN
  sqlstmt :=
    'delete from ' || X_ITABLE || ' ' ||
    'where ROW_ID = :X_ROWID';

  EXECUTE IMMEDIATE sqlstmt
  USING X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
  null;
END delete_row;


END gl_interface_pkg;

/
