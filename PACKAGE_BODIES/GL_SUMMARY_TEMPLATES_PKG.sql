--------------------------------------------------------
--  DDL for Package Body GL_SUMMARY_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SUMMARY_TEMPLATES_PKG" AS
/*  $Header: gliactpb.pls 120.5 2005/07/11 05:22:34 agovil ship $ */


  --
  -- PUBLIC FUNCTIONS
  --

FUNCTION is_funds_check_not_none (
  x_ledger_id  NUMBER ) RETURN BOOLEAN  IS

    CURSOR c_not_fc IS
      SELECT 'found'
      FROM   GL_SUMMARY_TEMPLATES st
      WHERE  st.ledger_id = x_ledger_id
      AND EXISTS (SELECT 'found'
                  FROM GL_SUMMARY_BC_OPTIONS sb
                  WHERE st.template_id = sb.template_id);

    dummy VARCHAR2(100);

  BEGIN

    OPEN  c_not_fc;
    FETCH c_not_fc INTO dummy;

    IF c_not_fc%FOUND THEN
      CLOSE c_not_fc;
      RETURN( TRUE );
    ELSE
      CLOSE c_not_fc;
      RETURN( FALSE );
    END IF;

    CLOSE c_not_fc;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_SUMMARY_TEMPLATES_PKG.is_funds_check_not_none');
      RAISE;

  END is_funds_check_not_none;



PROCEDURE check_unique_name(
  	X_rowid			    VARCHAR2,
  	X_ledger_id	        NUMBER,
	X_template_name		VARCHAR2)
IS
  X_name 	NUMBER := 0;
BEGIN

  SELECT 1
  INTO X_name
  FROM GL_SUMMARY_TEMPLATES st
  WHERE ((X_rowid is NULL) OR (X_rowid <> st.rowid))
  AND   X_ledger_id   = st.ledger_id
  AND   X_template_name     = st.template_name;

  IF (X_name = 1) THEN
    fnd_message.set_name('SQLGL','GL_DUP_TEMPLATE_NAME');
    app_exception.raise_exception;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN;

END check_unique_name;


FUNCTION check_unique_template(
  	X_rowid			    VARCHAR2,
  	X_ledger_id	        NUMBER,
   	X_segment1_type		VARCHAR2,
   	X_segment2_type		VARCHAR2,
   	X_segment3_type		VARCHAR2,
   	X_segment4_type		VARCHAR2,
   	X_segment5_type		VARCHAR2,
   	X_segment6_type		VARCHAR2,
   	X_segment7_type		VARCHAR2,
   	X_segment8_type		VARCHAR2,
   	X_segment9_type		VARCHAR2,
   	X_segment10_type	VARCHAR2,
   	X_segment11_type	VARCHAR2,
   	X_segment12_type	VARCHAR2,
   	X_segment13_type	VARCHAR2,
   	X_segment14_type	VARCHAR2,
   	X_segment15_type	VARCHAR2,
   	X_segment16_type	VARCHAR2,
   	X_segment17_type	VARCHAR2,
   	X_segment18_type	VARCHAR2,
   	X_segment19_type	VARCHAR2,
   	X_segment20_type	VARCHAR2,
   	X_segment21_type	VARCHAR2,
   	X_segment22_type	VARCHAR2,
   	X_segment23_type	VARCHAR2,
   	X_segment24_type	VARCHAR2,
   	X_segment25_type	VARCHAR2,
   	X_segment26_type	VARCHAR2,
   	X_segment27_type	VARCHAR2,
   	X_segment28_type	VARCHAR2,
   	X_segment29_type	VARCHAR2,
   	X_segment30_type	VARCHAR2) RETURN BOOLEAN IS

  X_template	NUMBER :=0;

  BEGIN

  SELECT 1
  INTO X_template
  FROM GL_SUMMARY_TEMPLATES st
  WHERE ((X_rowid is NULL) OR (X_rowid <> st.rowid))
  AND 	X_ledger_id  = st.ledger_id
  AND  	nvl(X_segment1_type,'*') = nvl(st.segment1_type,'*')
  AND	nvl(X_segment2_type,'*') = nvl(st.segment2_type,'*')
  AND	nvl(X_segment3_type,'*') = nvl(st.segment3_type,'*')
  AND	nvl(X_segment4_type,'*') = nvl(st.segment4_type,'*')
  AND	nvl(X_segment5_type,'*') = nvl(st.segment5_type,'*')
  AND	nvl(X_segment6_type,'*') = nvl(st.segment6_type,'*')
  AND	nvl(X_segment7_type,'*') = nvl(st.segment7_type,'*')
  AND	nvl(X_segment8_type,'*') = nvl(st.segment8_type,'*')
  AND	nvl(X_segment9_type,'*') = nvl(st.segment9_type,'*')
  AND	nvl(X_segment10_type,'*') = nvl(st.segment10_type,'*')
  AND	nvl(X_segment11_type,'*') = nvl(st.segment11_type,'*')
  AND	nvl(X_segment12_type,'*') = nvl(st.segment12_type,'*')
  AND	nvl(X_segment13_type,'*') = nvl(st.segment13_type,'*')
  AND	nvl(X_segment14_type,'*') = nvl(st.segment14_type,'*')
  AND	nvl(X_segment15_type,'*') = nvl(st.segment15_type,'*')
  AND	nvl(X_segment16_type,'*') = nvl(st.segment16_type,'*')
  AND	nvl(X_segment17_type,'*') = nvl(st.segment17_type,'*')
  AND	nvl(X_segment18_type,'*') = nvl(st.segment18_type,'*')
  AND	nvl(X_segment19_type,'*') = nvl(st.segment19_type,'*')
  AND	nvl(X_segment20_type,'*') = nvl(st.segment20_type,'*')
  AND	nvl(X_segment21_type,'*') = nvl(st.segment21_type,'*')
  AND	nvl(X_segment22_type,'*') = nvl(st.segment22_type,'*')
  AND	nvl(X_segment23_type,'*') = nvl(st.segment23_type,'*')
  AND	nvl(X_segment24_type,'*') = nvl(st.segment24_type,'*')
  AND	nvl(X_segment25_type,'*') = nvl(st.segment25_type,'*')
  AND	nvl(X_segment26_type,'*') = nvl(st.segment26_type,'*')
  AND	nvl(X_segment27_type,'*') = nvl(st.segment27_type,'*')
  AND	nvl(X_segment28_type,'*') = nvl(st.segment28_type,'*')
  AND	nvl(X_segment29_type,'*') = nvl(st.segment29_type,'*')
  AND	nvl(X_segment30_type,'*') = nvl(st.segment30_type,'*');

  IF (X_template = 1) THEN
    RETURN(TRUE);
  ELSE /* the template is not a duplicate */
    RETURN(FALSE);
  END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(FALSE);
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_SUMMARY_TEMPLATES_PKG.check_unique_template');
      RAISE;

END check_unique_template;


FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR c_getid IS
      SELECT GL_SUMMARY_TEMPLATES_S.NEXTVAL
      FROM   dual;
    id NUMBER;

  BEGIN
    OPEN  c_getid;
    FETCH c_getid INTO id;

    IF c_getid%FOUND THEN
      CLOSE c_getid;
      RETURN( id );
    ELSE
      CLOSE c_getid;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_SUMMARY_TEMPLATES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN APP_EXCEPTION.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_summary_templates_pkg.get_unique_id');
      RAISE;
END get_unique_id;

PROCEDURE Insert_Row(X_Rowid                  IN OUT NOCOPY       VARCHAR2,
                     X_Template_Name                       VARCHAR2,
                     X_Start_Actuals_Period_Name           VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Account_Category_Code               VARCHAR2,
                     X_Template_Id                         NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Status                              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_by                     NUMBER,
                     X_Concatenated_Description            VARCHAR2,
                     X_Max_Code_Combination_Id             NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Segment1_Type                       VARCHAR2,
                     X_Segment2_Type                       VARCHAR2,
                     X_Segment3_Type                       VARCHAR2,
                     X_Segment4_Type                       VARCHAR2,
                     X_Segment5_Type                       VARCHAR2,
                     X_Segment6_Type                       VARCHAR2,
                     X_Segment7_Type                       VARCHAR2,
                     X_Segment8_Type                       VARCHAR2,
                     X_Segment9_Type                       VARCHAR2,
                     X_Segment10_Type                      VARCHAR2,
                     X_Segment11_Type                      VARCHAR2,
                     X_Segment12_Type                      VARCHAR2,
                     X_Segment13_Type                      VARCHAR2,
                     X_Segment14_Type                      VARCHAR2,
                     X_Segment15_Type                      VARCHAR2,
                     X_Segment16_Type                      VARCHAR2,
                     X_Segment17_Type                      VARCHAR2,
                     X_Segment18_Type                      VARCHAR2,
                     X_Segment19_Type                      VARCHAR2,
                     X_Segment20_Type                      VARCHAR2,
                     X_Segment21_Type                      VARCHAR2,
                     X_Segment22_Type                      VARCHAR2,
                     X_Segment23_Type                      VARCHAR2,
                     X_Segment24_Type                      VARCHAR2,
                     X_Segment25_Type                      VARCHAR2,
                     X_Segment26_Type                      VARCHAR2,
                     X_Segment27_Type                      VARCHAR2,
                     X_Segment28_Type                      VARCHAR2,
                     X_Segment29_Type                      VARCHAR2,
                     X_Segment30_Type                      VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2
                     ) IS
               CURSOR C IS SELECT rowid FROM GL_SUMMARY_TEMPLATES
                           WHERE template_id = X_Template_Id;
BEGIN
  INSERT INTO GL_SUMMARY_TEMPLATES(
        template_id,
        ledger_id,
        status,
        last_update_date,
        last_updated_by,
        template_name,
        concatenated_description,
        account_category_code,
        max_code_combination_id,
        start_actuals_period_name,
        created_by,
        creation_date,
        last_update_login,
        segment1_type,
        segment2_type,
        segment3_type,
        segment4_type,
        segment5_type,
        segment6_type,
        segment7_type,
        segment8_type,
        segment9_type,
        segment10_type,
        segment11_type,
        segment12_type,
        segment13_type,
        segment14_type,
        segment15_type,
        segment16_type,
        segment17_type,
        segment18_type,
        segment19_type,
        segment20_type,
        segment21_type,
        segment22_type,
        segment23_type,
        segment24_type,
        segment25_type,
        segment26_type,
        segment27_type,
        segment28_type,
        segment29_type,
        segment30_type,
        description,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        context)
   VALUES (
        X_Template_Id,
        X_Ledger_id,
        X_Status,
        X_Last_Update_Date,
        X_Last_Updated_By,
        X_Template_Name,
        X_Concatenated_Description,
        X_Account_Category_Code,
        X_Max_Code_Combination_Id,
        X_Start_Actuals_Period_Name,
        X_Created_By,
        X_Creation_Date,
        X_Last_Update_Login,
        X_Segment1_Type,
        X_Segment2_Type,
        X_Segment3_Type,
        X_Segment4_Type,
        X_Segment5_Type,
        X_Segment6_Type,
        X_Segment7_Type,
        X_Segment8_Type,
        X_Segment9_Type,
        X_Segment10_Type,
        X_Segment11_Type,
        X_Segment12_Type,
        X_Segment13_Type,
        X_Segment14_Type,
        X_Segment15_Type,
        X_Segment16_Type,
        X_Segment17_Type,
        X_Segment18_Type,
        X_Segment19_Type,
        X_Segment20_Type,
        X_Segment21_Type,
        X_Segment22_Type,
        X_Segment23_Type,
        X_Segment24_Type,
        X_Segment25_Type,
        X_Segment26_Type,
        X_Segment27_Type,
        X_Segment28_Type,
        X_Segment29_Type,
        X_Segment30_Type,
        X_Description,
        X_Attribute1,
        X_Attribute2,
        X_Attribute3,
        X_Attribute4,
        X_Attribute5,
        X_Attribute6,
        X_Attribute7,
        X_Attribute8,
        X_Context);

     OPEN C;
     FETCH C INTO X_Rowid;
     if (C%NOTFOUND) then
        CLOSE C;
        RAISE NO_DATA_FOUND;
     end if;
     CLOSE C;
END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                               VARCHAR2,
                   X_Template_Name                       VARCHAR2,
                   X_Start_Actuals_Period_Name           VARCHAR2,
                   X_Description                         VARCHAR2,
                   X_Account_Category_Code               VARCHAR2,
                   X_Template_Id                         NUMBER,
                   X_Ledger_Id                           NUMBER,
                   X_Status                              VARCHAR2,
                   X_Last_Update_Date                    DATE,
                   X_Last_Updated_by                     NUMBER,
                   X_Concatenated_Description            VARCHAR2,
                   X_Max_Code_Combination_Id             NUMBER,
                   X_Created_By                          NUMBER,
                   X_Creation_Date                       DATE,
                   X_Last_Update_Login                   NUMBER,
                   X_Segment1_Type                       VARCHAR2,
                   X_Segment2_Type                       VARCHAR2,
                   X_Segment3_Type                       VARCHAR2,
                   X_Segment4_Type                       VARCHAR2,
                   X_Segment5_Type                       VARCHAR2,
                   X_Segment6_Type                       VARCHAR2,
                   X_Segment7_Type                       VARCHAR2,
                   X_Segment8_Type                       VARCHAR2,
                   X_Segment9_Type                       VARCHAR2,
                   X_Segment10_Type                      VARCHAR2,
                   X_Segment11_Type                      VARCHAR2,
                   X_Segment12_Type                      VARCHAR2,
                   X_Segment13_Type                      VARCHAR2,
                   X_Segment14_Type                      VARCHAR2,
                   X_Segment15_Type                      VARCHAR2,
                   X_Segment16_Type                      VARCHAR2,
                   X_Segment17_Type                      VARCHAR2,
                   X_Segment18_Type                      VARCHAR2,
                   X_Segment19_Type                      VARCHAR2,
                   X_Segment20_Type                      VARCHAR2,
                   X_Segment21_Type                      VARCHAR2,
                   X_Segment22_Type                      VARCHAR2,
                   X_Segment23_Type                      VARCHAR2,
                   X_Segment24_Type                      VARCHAR2,
                   X_Segment25_Type                      VARCHAR2,
                   X_Segment26_Type                      VARCHAR2,
                   X_Segment27_Type                      VARCHAR2,
                   X_Segment28_Type                      VARCHAR2,
                   X_Segment29_Type                      VARCHAR2,
                   X_Segment30_Type                      VARCHAR2,
                   X_Attribute1                          VARCHAR2,
                   X_Attribute2                          VARCHAR2,
                   X_Attribute3                          VARCHAR2,
                   X_Attribute4                          VARCHAR2,
                   X_Attribute5                          VARCHAR2,
                   X_Attribute6                          VARCHAR2,
                   X_Attribute7                          VARCHAR2,
                   X_Attribute8                          VARCHAR2,
                   X_Context                             VARCHAR2
                   ) IS
      CURSOR C IS
          SELECT *
          FROM GL_SUMMARY_TEMPLATES
          WHERE  rowid = X_Rowid
          FOR UPDATE of Ledger_Id NOWAIT;
      Recinfo  C%ROWTYPE;
BEGIN
      OPEN C;
      FETCH C INTO Recinfo;
      if (C%NOTFOUND) then
          CLOSE C;
          RAISE NO_DATA_FOUND;
      end if;
      CLOSE C;
      if(
             ( (Recinfo.template_id = X_Template_Id)
                OR (    (Recinfo.template_id IS NULL)
                    AND (X_Template_Id IS NULL)))
         AND ( (Recinfo.ledger_id = X_Ledger_ID)
                OR (    (Recinfo.ledger_id IS NULL)
                    AND (X_Ledger_Id IS NULL)))
         AND ( (Recinfo.status = X_Status)
                OR (    (Recinfo.status IS NULL)
                    AND (X_Status IS NULL)))
         AND ( (Recinfo.last_update_date = X_Last_Update_Date)
                OR (    (Recinfo.last_update_date IS NULL)
                    AND (X_Last_Update_Date IS NULL)))
         AND ( (Recinfo.last_updated_by = X_Last_Updated_By)
                OR (    (Recinfo.last_updated_by IS NULL)
                    AND (X_Last_Updated_By IS NULL)))
         AND ( (Recinfo.template_name = X_Template_Name)
                OR (    (Recinfo.template_name IS NULL)
                    AND (X_Template_Name IS NULL)))
         AND ( (Recinfo.concatenated_description = X_Concatenated_Description)
                OR (    (Recinfo.concatenated_description IS NULL)
                    AND (X_Concatenated_Description IS NULL)))
         AND ( (Recinfo.account_category_code = X_Account_Category_Code)
                OR (    (Recinfo.account_category_code IS NULL)
                    AND (X_Account_Category_Code IS NULL)))
         AND ( (Recinfo.max_code_combination_id = X_Max_Code_Combination_Id)
                OR (    (Recinfo.max_code_combination_id IS NULL)
                    AND (X_Max_Code_Combination_Id IS NULL)))
         AND ( (Recinfo.start_actuals_period_name = X_Start_Actuals_Period_Name)
                OR (    (Recinfo.start_actuals_period_name IS NULL)
                    AND (X_Start_Actuals_Period_Name IS NULL)))
         AND ( (Recinfo.created_by = X_Created_By)
                OR (    (Recinfo.created_by IS NULL)
                    AND (X_Created_By IS NULL)))
         AND ( (Recinfo.creation_date = X_Creation_Date)
                OR (    (Recinfo.creation_date IS NULL)
                    AND (X_Creation_Date IS NULL)))
         AND ( (Recinfo.last_update_login = X_Last_Update_Login)
                OR (    (Recinfo.last_update_login IS NULL)
                    AND (X_Last_Update_Login IS NULL)))
         AND ( (Recinfo.segment1_type = X_Segment1_Type)
                OR (    (Recinfo.segment1_type IS NULL)
                    AND (X_Segment1_Type IS NULL)))
         AND ( (Recinfo.segment2_type = X_Segment2_Type)
                OR (    (Recinfo.segment2_type IS NULL)
                    AND (X_Segment2_Type IS NULL)))
         AND ( (Recinfo.segment3_type = X_Segment3_Type)
                OR (    (Recinfo.segment3_type IS NULL)
                    AND (X_Segment3_Type IS NULL)))
         AND ( (Recinfo.segment4_type = X_Segment4_Type)
                OR (    (Recinfo.segment4_type IS NULL)
                    AND (X_Segment4_Type IS NULL)))
         AND ( (Recinfo.segment5_type = X_Segment5_Type)
                OR (    (Recinfo.segment5_type IS NULL)
                    AND (X_Segment5_Type IS NULL)))
         AND ( (Recinfo.segment6_type = X_Segment6_Type)
                OR (    (Recinfo.segment6_type IS NULL)
                    AND (X_Segment6_Type IS NULL)))
         AND ( (Recinfo.segment7_type = X_Segment7_Type)
                OR (    (Recinfo.segment7_type IS NULL)
                    AND (X_Segment7_Type IS NULL)))
         AND ( (Recinfo.segment8_type = X_Segment8_Type)
                OR (    (Recinfo.segment8_type IS NULL)
                    AND (X_Segment8_Type IS NULL)))
         AND ( (Recinfo.segment9_type = X_Segment9_Type)
                OR (    (Recinfo.segment9_type IS NULL)
                    AND (X_Segment9_Type IS NULL)))
         AND ( (Recinfo.segment10_type = X_Segment10_Type)
                OR (    (Recinfo.segment10_type IS NULL)
                    AND (X_Segment10_Type IS NULL)))
         AND ( (Recinfo.segment11_type = X_Segment11_Type)
                OR (    (Recinfo.segment11_type IS NULL)
                    AND (X_Segment11_Type IS NULL)))
         AND ( (Recinfo.segment12_type = X_Segment12_Type)
                OR (    (Recinfo.segment12_type IS NULL)
                    AND (X_Segment12_Type IS NULL)))
         AND ( (Recinfo.segment13_type = X_Segment13_Type)
                OR (    (Recinfo.segment13_type IS NULL)
                    AND (X_Segment13_Type IS NULL)))
         AND ( (Recinfo.segment14_type = X_Segment14_Type)
                OR (    (Recinfo.segment14_type IS NULL)
                    AND (X_Segment14_Type IS NULL)))
         AND ( (Recinfo.segment15_type = X_Segment15_Type)
                OR (    (Recinfo.segment15_type IS NULL)
                    AND (X_Segment15_Type IS NULL)))
         AND ( (Recinfo.segment16_type = X_Segment16_Type)
                OR (    (Recinfo.segment16_type IS NULL)
                    AND (X_Segment16_Type IS NULL)))
         AND ( (Recinfo.segment17_type = X_Segment17_Type)
                OR (    (Recinfo.segment17_type IS NULL)
                    AND (X_Segment17_Type IS NULL)))
         AND ( (Recinfo.segment18_type = X_Segment18_Type)
                OR (    (Recinfo.segment18_type IS NULL)
                    AND (X_Segment18_Type IS NULL)))
         AND ( (Recinfo.segment19_type = X_Segment19_Type)
                OR (    (Recinfo.segment19_type IS NULL)
                    AND (X_Segment19_Type IS NULL)))
         AND ( (Recinfo.segment20_type = X_Segment20_Type)
                OR (    (Recinfo.segment20_type IS NULL)
                    AND (X_Segment20_Type IS NULL)))
         AND ( (Recinfo.segment21_type = X_Segment21_Type)
                OR (    (Recinfo.segment21_type IS NULL)
                    AND (X_Segment21_Type IS NULL)))
         AND ( (Recinfo.segment22_type = X_Segment22_Type)
                OR (    (Recinfo.segment22_type IS NULL)
                    AND (X_Segment22_Type IS NULL)))
         AND ( (Recinfo.segment23_type = X_Segment23_Type)
                OR (    (Recinfo.segment23_type IS NULL)
                    AND (X_Segment23_Type IS NULL)))
         AND ( (Recinfo.segment24_type = X_Segment24_Type)
                OR (    (Recinfo.segment24_type IS NULL)
                    AND (X_Segment24_Type IS NULL)))
         AND ( (Recinfo.segment25_type = X_Segment25_Type)
                OR (    (Recinfo.segment25_type IS NULL)
                    AND (X_Segment25_Type IS NULL)))
         AND ( (Recinfo.segment26_type = X_Segment26_Type)
                OR (    (Recinfo.segment26_type IS NULL)
                    AND (X_Segment26_Type IS NULL)))
         AND ( (Recinfo.segment27_type = X_Segment27_Type)
                OR (    (Recinfo.segment27_type IS NULL)
                    AND (X_Segment27_Type IS NULL)))
         AND ( (Recinfo.segment28_type = X_Segment28_Type)
                OR (    (Recinfo.segment28_type IS NULL)
                    AND (X_Segment28_Type IS NULL)))
         AND ( (Recinfo.segment29_type = X_Segment29_Type)
                OR (    (Recinfo.segment29_type IS NULL)
                    AND (X_Segment29_Type IS NULL)))
         AND ( (Recinfo.segment30_type = X_Segment30_Type)
                OR (    (Recinfo.segment30_type IS NULL)
                    AND (X_Segment30_Type IS NULL)))
         AND ( (Recinfo.description = X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
         AND ( (Recinfo.attribute1 = X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
         AND ( (Recinfo.attribute2 = X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
         AND ( (Recinfo.attribute3 = X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
         AND ( (Recinfo.attribute4 = X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
         AND ( (Recinfo.attribute5 = X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
         AND ( (Recinfo.attribute6 = X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
         AND ( (Recinfo.attribute7 = X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
         AND ( (Recinfo.attribute8 = X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
         AND ( (Recinfo.context = X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
        ) then
         return;
    else
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Template_Name                       VARCHAR2,
                     X_Start_Actuals_Period_Name           VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Account_Category_Code               VARCHAR2,
                     X_Template_Id                         NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Status                              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_by                     NUMBER,
                     X_Concatenated_Description            VARCHAR2,
                     X_Max_Code_Combination_Id             NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Segment1_Type                       VARCHAR2,
                     X_Segment2_Type                       VARCHAR2,
                     X_Segment3_Type                       VARCHAR2,
                     X_Segment4_Type                       VARCHAR2,
                     X_Segment5_Type                       VARCHAR2,
                     X_Segment6_Type                       VARCHAR2,
                     X_Segment7_Type                       VARCHAR2,
                     X_Segment8_Type                       VARCHAR2,
                     X_Segment9_Type                       VARCHAR2,
                     X_Segment10_Type                      VARCHAR2,
                     X_Segment11_Type                      VARCHAR2,
                     X_Segment12_Type                      VARCHAR2,
                     X_Segment13_Type                      VARCHAR2,
                     X_Segment14_Type                      VARCHAR2,
                     X_Segment15_Type                      VARCHAR2,
                     X_Segment16_Type                      VARCHAR2,
                     X_Segment17_Type                      VARCHAR2,
                     X_Segment18_Type                      VARCHAR2,
                     X_Segment19_Type                      VARCHAR2,
                     X_Segment20_Type                      VARCHAR2,
                     X_Segment21_Type                      VARCHAR2,
                     X_Segment22_Type                      VARCHAR2,
                     X_Segment23_Type                      VARCHAR2,
                     X_Segment24_Type                      VARCHAR2,
                     X_Segment25_Type                      VARCHAR2,
                     X_Segment26_Type                      VARCHAR2,
                     X_Segment27_Type                      VARCHAR2,
                     X_Segment28_Type                      VARCHAR2,
                     X_Segment29_Type                      VARCHAR2,
                     X_Segment30_Type                      VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2
                     ) IS

BEGIN
     UPDATE GL_SUMMARY_TEMPLATES
     SET
            template_id                   = X_Template_Id,
            ledger_id                     = X_Ledger_id,
            status                        = X_Status,
            last_update_date              = X_Last_Update_Date,
            last_updated_by               = X_Last_Updated_By,
            template_name                 = X_Template_Name,
            concatenated_description      = X_Concatenated_Description,
            account_category_code         = X_Account_Category_Code,
            max_code_combination_id       = X_Max_Code_Combination_Id,
            start_actuals_period_name     = X_Start_Actuals_Period_Name,
            created_by                    = X_Created_By,
            creation_date                 = X_Creation_Date,
            last_update_login             = X_Last_Update_Login,
            segment1_type                 = X_Segment1_Type,
            segment2_type                 = X_Segment2_Type,
            segment3_type                 = X_Segment3_Type,
            segment4_type                 = X_Segment4_Type,
            segment5_type                 = X_Segment5_Type,
            segment6_type                 = X_Segment6_Type,
            segment7_type                 = X_Segment7_Type,
            segment8_type                 = X_Segment8_Type,
            segment9_type                 = X_Segment9_Type,
            segment10_type                = X_Segment10_Type,
            segment11_type                = X_Segment11_Type,
            segment12_type                = X_Segment12_Type,
            segment13_type                = X_Segment13_Type,
            segment14_type                = X_Segment14_Type,
            segment15_type                = X_Segment15_Type,
            segment16_type                = X_Segment16_Type,
            segment17_type                = X_Segment17_Type,
            segment18_type                = X_Segment18_Type,
            segment19_type                = X_Segment19_Type,
            segment20_type                = X_Segment20_Type,
            segment21_type                = X_Segment21_Type,
            segment22_type                = X_Segment22_Type,
            segment23_type                = X_Segment23_Type,
            segment24_type                = X_Segment24_Type,
            segment25_type                = X_Segment25_Type,
            segment26_type                = X_Segment26_Type,
            segment27_type                = X_Segment27_Type,
            segment28_type                = X_Segment28_Type,
            segment29_type                = X_Segment29_Type,
            segment30_type                = X_Segment30_Type,
            description                   = X_Description,
            attribute1                    = X_Attribute1,
            attribute2                    = X_Attribute2,
            attribute3                    = X_Attribute3,
            attribute4                    = X_Attribute4,
            attribute5                    = X_Attribute5,
            attribute6                    = X_Attribute6,
            attribute7                    = X_Attribute7,
            attribute8                    = X_Attribute8,
            context                       = X_Context
     WHERE  rowid = X_Rowid;
     if(SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
     end if;
END Update_Row;


END GL_SUMMARY_TEMPLATES_PKG;

/
