--------------------------------------------------------
--  DDL for Package Body GL_BUDGET_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGET_ENTITIES_PKG" AS
/* $Header: glibdorb.pls 120.8.12010000.2 2009/03/20 06:03:02 skotakar ship $ */

--
-- PRIVATE FUNCTIONS
--

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Used to select a particular budget organization row
  -- History
  --   21-MAR-93  D. J. Ogg    Created
  -- Arguments
  --   recinfo			Various information about the row
  -- Example
  --   gl_budget_entities_pkg.select_row(recinfo)
  -- Notes
  --
  PROCEDURE select_row( recinfo	IN OUT NOCOPY gl_budget_entities%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_budget_entities
    WHERE budget_entity_id = recinfo.budget_entity_id;
  END SELECT_ROW;


--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(lgr_id NUMBER, org_name VARCHAR2,
                         row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT status_code
      FROM   GL_BUDGET_ENTITIES be
      WHERE  be.ledger_id = lgr_id
      AND    be.name = org_name
      AND    (   row_id is null
              OR be.rowid <> row_id);
     status_code VARCHAR2(1);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO status_code;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      IF ( status_code = 'D' ) THEN
        fnd_message.set_name('SQLGL', 'GL_DUP_BUD_ORG_DEL_INP');
        app_exception.raise_exception;
      ELSE
        fnd_message.set_name('SQLGL', 'GL_DUPLICATE_BUD_ORG_NAME');
        app_exception.raise_exception;
      END IF;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_entities_pkg.check_unique');
      RAISE;
  END check_unique;

  FUNCTION check_for_all(lgr_id NUMBER, row_id VARCHAR2) RETURN BOOLEAN IS
    CURSOR check_for_all is
      SELECT 'Exists'
      FROM   GL_BUDGET_ENTITIES be, gl_lookups l
      WHERE  l.lookup_type = 'LITERAL'
      AND    l.lookup_code = 'ALL'
      AND    upper(be.name) = upper(l.meaning)
      AND    be.ledger_id = lgr_id
      AND    (   row_id is null
              OR be.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN check_for_all;
    FETCH check_for_all INTO dummy;

    IF check_for_all%FOUND THEN
      CLOSE check_for_all;
      return(TRUE);
    ELSE
      CLOSE check_for_all;
      return(FALSE);
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_entities_pkg.check_for_all');
      RAISE;
  END check_for_all;

  FUNCTION has_ranges(org_id NUMBER) RETURN BOOLEAN IS
    CURSOR check_for_ranges is
      SELECT 'Has ranges'
      FROM   GL_BUDGET_ASSIGNMENT_RANGES bar
      WHERE  bar.budget_entity_id = org_id;
    dummy VARCHAR2(100);
  BEGIN
    OPEN check_for_ranges;
    FETCH check_for_ranges INTO dummy;

    IF check_for_ranges%FOUND THEN
      CLOSE check_for_ranges;
      return(TRUE);
    ELSE
      CLOSE check_for_ranges;
      return(FALSE);
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_entities_pkg.has_ranges');
      RAISE;
  END has_ranges;

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_budget_entities_s.NEXTVAL
      FROM dual;
    new_id number;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_BUDGET_ENTITIES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_entities_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  PROCEDURE lock_organization(org_id NUMBER) IS
    CURSOR lock_org is
      SELECT 'Locked organization'
      FROM   GL_BUDGET_ENTITIES be
      WHERE  be.budget_entity_id = org_id
      AND    not be.status_code = 'D'
      FOR UPDATE OF status_code;
    dummy VARCHAR2(100);
  BEGIN
    OPEN lock_org;
    FETCH lock_org INTO dummy;

    IF NOT lock_org%FOUND THEN
      CLOSE lock_org;
      fnd_message.set_name('SQLGL', 'GL_BUDORG_DELETED');
      app_exception.raise_exception;
    END IF;

    CLOSE lock_org;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_entities_pkg.lock_organization');
      RAISE;
  END lock_organization;

  PROCEDURE select_columns( entity_id			NUMBER,
			    entity_name			IN OUT NOCOPY VARCHAR2,
			    password_required_flag	IN OUT NOCOPY VARCHAR2,
			    encrypted_password		IN OUT NOCOPY VARCHAR2,
			    status_code			IN OUT NOCOPY VARCHAR2,
			    security_flag               IN OUT NOCOPY VARCHAR2--Added as part of bug7382899
			    ) IS
    recinfo gl_budget_entities%ROWTYPE;

  BEGIN
    recinfo.budget_entity_id := entity_id;

    select_row(recinfo);

    entity_name := recinfo.name;
    password_required_flag := recinfo.budget_password_required_flag;
    encrypted_password := recinfo.encrypted_budget_password;
    status_code := recinfo.status_code;
    security_flag := recinfo.security_flag;--Added as part of bug7382899
  END select_columns;

  PROCEDURE budget_and_account_seg_info(
                               lgr_id               NUMBER,
                               coa_id               NUMBER,
                               x_budget_version_id  IN OUT NOCOPY NUMBER,
                               x_budget_name        IN OUT NOCOPY VARCHAR2,
                               x_bj_required        IN OUT NOCOPY VARCHAR2,
                               x_segment_name       OUT NOCOPY VARCHAR2) IS
   BEGIN
    IF (lgr_id IS NOT NULL) then
      x_segment_name := gl_flexfields_pkg.get_account_segment(coa_id);
    END IF;
    gl_budget_utils_pkg.get_current_budget(lgr_id,
                                           x_budget_version_id,
                                           x_budget_name,
                                           x_bj_required);
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                          'gl_budget_entities_pkg.budget_and_acount_seg_info');
      RAISE;
   END budget_and_account_seg_info;

--** Added Security_Flag for Definition Access Set enhancement
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Budget_Entity_Id        IN OUT NOCOPY NUMBER,
                       X_Name                           VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Budget_Password_Required       VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Encrypted_Budget_Password      VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Segment1_Type                  NUMBER,
                       X_Segment2_Type                  NUMBER,
                       X_Segment3_Type                  NUMBER,
                       X_Segment4_Type                  NUMBER,
                       X_Segment5_Type                  NUMBER,
                       X_Segment6_Type                  NUMBER,
                       X_Segment7_Type                  NUMBER,
                       X_Segment8_Type                  NUMBER,
                       X_Segment9_Type                  NUMBER,
                       X_Segment10_Type                 NUMBER,
                       X_Segment11_Type                 NUMBER,
                       X_Segment12_Type                 NUMBER,
                       X_Segment13_Type                 NUMBER,
                       X_Segment14_Type                 NUMBER,
                       X_Segment15_Type                 NUMBER,
                       X_Segment16_Type                 NUMBER,
                       X_Segment17_Type                 NUMBER,
                       X_Segment18_Type                 NUMBER,
                       X_Segment19_Type                 NUMBER,
                       X_Segment20_Type                 NUMBER,
                       X_Segment21_Type                 NUMBER,
                       X_Segment22_Type                 NUMBER,
                       X_Segment23_Type                 NUMBER,
                       X_Segment24_Type                 NUMBER,
                       X_Segment25_Type                 NUMBER,
                       X_Segment26_Type                 NUMBER,
                       X_Segment27_Type                 NUMBER,
                       X_Segment28_Type                 NUMBER,
                       X_Segment29_Type                 NUMBER,
                       X_Segment30_Type                 NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_All_Name                       BOOLEAN,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Security_Flag			VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM gl_budget_entities
                 WHERE budget_entity_id = X_Budget_Entity_Id;

    L_Status_Code VARCHAR2(1);

   BEGIN
       -- Make sure only one ALL organization
       IF (X_All_Name AND
           gl_budget_entities_pkg.check_for_all(
               X_Ledger_Id,
               X_Rowid)) THEN
         fnd_message.set_name('SQLGL', 'GL_BUDGET_ONLY_ONE_ALL');
         app_exception.raise_exception;
       END IF;

       -- Set budget_entity_id
       -- Changed functionality to retrieve id from sequence only if
       -- routine is not called from the iSpeed API, since the API
       -- retrieves and passes in the id.

       IF (X_Status_Code = 'ISPEED') THEN
          L_Status_Code := 'C';
       ELSE
          L_Status_Code := X_Status_Code;
       END IF;

    -- Insert the corresponding rows in gl_entity_budgets.
    gl_entity_budgets_pkg.insert_entity(
      X_Budget_Entity_Id,
      X_Ledger_Id,
      X_Last_Updated_By,
      X_Last_Update_Login);

    -- Insert a budget timestamp for the chart of accounts,
    -- if necessary.
    gl_bc_event_tstamps_pkg.insert_event_timestamp(
      X_Chart_Of_Accounts_Id,
      'B',
      X_Last_Updated_By,
      X_Last_Update_Login);


       INSERT INTO gl_budget_entities(

              budget_entity_id,
              name,
              ledger_id,
              last_update_date,
              last_updated_by,
              budget_password_required_flag,
              status_code,
              creation_date,
              created_by,
              last_update_login,
              encrypted_budget_password,
              description,
              start_date,
              end_date,
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
              context,
              security_flag)
            VALUES (

              X_Budget_Entity_Id,
              X_Name,
              X_Ledger_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Budget_Password_Required,
              L_Status_Code,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Encrypted_Budget_Password,
              X_Description,
              X_Start_Date,
              X_End_Date,
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
              X_Context,
              X_Security_Flag);

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_entities_pkg.insert_row');
      RAISE;
  END Insert_Row;

--** Added Security_Flag for Definition Access Set enhancement
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Budget_Entity_Id               NUMBER,
                       X_Name                           VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Budget_Password_Required       VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Encrypted_Budget_Password      VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Segment1_Type                  NUMBER,
                       X_Segment2_Type                  NUMBER,
                       X_Segment3_Type                  NUMBER,
                       X_Segment4_Type                  NUMBER,
                       X_Segment5_Type                  NUMBER,
                       X_Segment6_Type                  NUMBER,
                       X_Segment7_Type                  NUMBER,
                       X_Segment8_Type                  NUMBER,
                       X_Segment9_Type                  NUMBER,
                       X_Segment10_Type                 NUMBER,
                       X_Segment11_Type                 NUMBER,
                       X_Segment12_Type                 NUMBER,
                       X_Segment13_Type                 NUMBER,
                       X_Segment14_Type                 NUMBER,
                       X_Segment15_Type                 NUMBER,
                       X_Segment16_Type                 NUMBER,
                       X_Segment17_Type                 NUMBER,
                       X_Segment18_Type                 NUMBER,
                       X_Segment19_Type                 NUMBER,
                       X_Segment20_Type                 NUMBER,
                       X_Segment21_Type                 NUMBER,
                       X_Segment22_Type                 NUMBER,
                       X_Segment23_Type                 NUMBER,
                       X_Segment24_Type                 NUMBER,
                       X_Segment25_Type                 NUMBER,
                       X_Segment26_Type                 NUMBER,
                       X_Segment27_Type                 NUMBER,
                       X_Segment28_Type                 NUMBER,
                       X_Segment29_Type                 NUMBER,
                       X_Segment30_Type                 NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_All_Name                       BOOLEAN,
                       X_Security_Flag			VARCHAR2

  ) IS
  BEGIN

    -- Make sure only one ALL organization
    IF (X_All_Name AND
        gl_budget_entities_pkg.check_for_all(
            X_Ledger_Id,
            X_Rowid)) THEN
      fnd_message.set_name('SQLGL', 'GL_BUDGET_ONLY_ONE_ALL');
      app_exception.raise_exception;
    END IF;

    UPDATE gl_budget_entities
    SET
       budget_entity_id                =     X_Budget_Entity_Id,
       name                            =     X_Name,
       ledger_id                       =     X_Ledger_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       budget_password_required_flag   =     X_Budget_Password_Required,
       status_code                     =     X_Status_Code,
       last_update_login               =     X_Last_Update_Login,
       encrypted_budget_password       =     X_Encrypted_Budget_Password,
       description                     =     X_Description,
       start_date                      =     X_Start_Date,
       end_date                        =     X_End_Date,
       segment1_type                   =     X_Segment1_Type,
       segment2_type                   =     X_Segment2_Type,
       segment3_type                   =     X_Segment3_Type,
       segment4_type                   =     X_Segment4_Type,
       segment5_type                   =     X_Segment5_Type,
       segment6_type                   =     X_Segment6_Type,
       segment7_type                   =     X_Segment7_Type,
       segment8_type                   =     X_Segment8_Type,
       segment9_type                   =     X_Segment9_Type,
       segment10_type                  =     X_Segment10_Type,
       segment11_type                  =     X_Segment11_Type,
       segment12_type                  =     X_Segment12_Type,
       segment13_type                  =     X_Segment13_Type,
       segment14_type                  =     X_Segment14_Type,
       segment15_type                  =     X_Segment15_Type,
       segment16_type                  =     X_Segment16_Type,
       segment17_type                  =     X_Segment17_Type,
       segment18_type                  =     X_Segment18_Type,
       segment19_type                  =     X_Segment19_Type,
       segment20_type                  =     X_Segment20_Type,
       segment21_type                  =     X_Segment21_Type,
       segment22_type                  =     X_Segment22_Type,
       segment23_type                  =     X_Segment23_Type,
       segment24_type                  =     X_Segment24_Type,
       segment25_type                  =     X_Segment25_Type,
       segment26_type                  =     X_Segment26_Type,
       segment27_type                  =     X_Segment27_Type,
       segment28_type                  =     X_Segment28_Type,
       segment29_type                  =     X_Segment29_Type,
       segment30_type                  =     X_Segment30_Type,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       context                         =     X_Context,
       security_flag		       =     X_Security_Flag
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_entities_pkg.update_row');
      RAISE;
  END Update_Row;

  --** Added for Definition Access Set enhancement
  PROCEDURE Lock_Row  (X_Rowid                IN OUT NOCOPY    VARCHAR2,
                       X_Budget_Entity_Id     IN OUT NOCOPY    NUMBER,
                       X_Name                           VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Budget_Password_Required       VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Encrypted_Budget_Password      VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Segment1_Type                  NUMBER,
                       X_Segment2_Type                  NUMBER,
                       X_Segment3_Type                  NUMBER,
                       X_Segment4_Type                  NUMBER,
                       X_Segment5_Type                  NUMBER,
                       X_Segment6_Type                  NUMBER,
                       X_Segment7_Type                  NUMBER,
                       X_Segment8_Type                  NUMBER,
                       X_Segment9_Type                  NUMBER,
                       X_Segment10_Type                 NUMBER,
                       X_Segment11_Type                 NUMBER,
                       X_Segment12_Type                 NUMBER,
                       X_Segment13_Type                 NUMBER,
                       X_Segment14_Type                 NUMBER,
                       X_Segment15_Type                 NUMBER,
                       X_Segment16_Type                 NUMBER,
                       X_Segment17_Type                 NUMBER,
                       X_Segment18_Type                 NUMBER,
                       X_Segment19_Type                 NUMBER,
                       X_Segment20_Type                 NUMBER,
                       X_Segment21_Type                 NUMBER,
                       X_Segment22_Type                 NUMBER,
                       X_Segment23_Type                 NUMBER,
                       X_Segment24_Type                 NUMBER,
                       X_Segment25_Type                 NUMBER,
                       X_Segment26_Type                 NUMBER,
                       X_Segment27_Type                 NUMBER,
                       X_Segment28_Type                 NUMBER,
                       X_Segment29_Type                 NUMBER,
                       X_Segment30_Type                 NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Security_Flag			VARCHAR2
  ) IS
  CURSOR C IS SELECT
         Budget_Entity_Id ,
         Name,
         Ledger_Id,
         Budget_Password_Required_Flag,
         Status_Code,
         Encrypted_Budget_Password,
         Description,
         Start_Date,
         End_Date,
         Segment1_Type,
         Segment2_Type,
         Segment3_Type,
         Segment4_Type,
         Segment5_Type,
         Segment6_Type,
         Segment7_Type,
         Segment8_Type,
         Segment9_Type,
         Segment10_Type,
         Segment11_Type,
         Segment12_Type,
         Segment13_Type,
         Segment14_Type,
         Segment15_Type,
         Segment16_Type,
         Segment17_Type,
         Segment18_Type,
         Segment19_Type,
         Segment20_Type,
         Segment21_Type,
         Segment22_Type,
         Segment23_Type,
         Segment24_Type,
         Segment25_Type,
         Segment26_Type,
         Segment27_Type,
         Segment28_Type,
         Segment29_Type,
         Segment30_Type,
         Attribute1,
         Attribute2,
         Attribute3,
         Attribute4,
         Attribute5,
         Attribute6,
         Attribute7,
         Attribute8,
         Attribute9,
         Attribute10,
         Context,
         Security_Flag
    FROM Gl_Budget_Entities
    WHERE ROWID = X_Rowid
    FOR UPDATE OF Budget_Entity_Id NOWAIT;
  recinfo C%ROWTYPE;

BEGIN
    OPEN C;
    FETCH C INTO recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
    CLOSE C;

    IF (
        (recinfo.Budget_Entity_Id = X_Budget_Entity_Id)
        AND (recinfo.Name = X_Name)
        AND (recinfo.Ledger_Id = X_Ledger_Id)
        AND (recinfo.Budget_Password_Required_Flag = X_Budget_Password_Required)
        AND (recinfo.Status_Code = X_Status_Code)
        AND (recinfo.Security_Flag = X_Security_Flag)

        AND ((recinfo.Encrypted_Budget_Password = X_Encrypted_Budget_Password)
             OR ((recinfo.Encrypted_Budget_Password is null)
                 AND (X_Encrypted_Budget_Password is null)))

        AND ((recinfo.Description = X_Description)
             OR ((recinfo.Description is null)
                 AND (X_Description is null)))

        AND ((recinfo.Context = X_Context)
             OR ((recinfo.Context is null)
                 AND (X_Context is null)))

        AND ((recinfo.Start_Date = X_Start_Date)
             OR ((recinfo.Start_Date is null)
                 AND (X_Start_Date is null)))

        AND ((recinfo.End_Date = X_End_Date)
             OR ((recinfo.End_Date is null)
                 AND (X_End_Date is null)))

        AND ((recinfo.Segment1_Type = X_Segment1_Type)
             OR ((recinfo.Segment1_Type is null)
                 AND (X_Segment1_Type is null)))

        AND ((recinfo.Segment2_Type = X_Segment2_Type)
             OR ((recinfo.Segment2_Type is null)
                 AND (X_Segment2_Type is null)))

        AND ((recinfo.Segment3_Type = X_Segment3_Type)
             OR ((recinfo.Segment3_Type is null)
                 AND (X_Segment3_Type is null)))

        AND ((recinfo.Segment4_Type = X_Segment4_Type)
             OR ((recinfo.Segment4_Type is null)
                 AND (X_Segment4_Type is null)))

        AND ((recinfo.Segment5_Type = X_Segment5_Type)
             OR ((recinfo.Segment5_Type is null)
                 AND (X_Segment5_Type is null)))

        AND ((recinfo.Segment6_Type = X_Segment6_Type)
             OR ((recinfo.Segment6_Type is null)
                 AND (X_Segment6_Type is null)))

        AND ((recinfo.Segment7_Type = X_Segment7_Type)
             OR ((recinfo.Segment7_Type is null)
                 AND (X_Segment7_Type is null)))

        AND ((recinfo.Segment8_Type = X_Segment8_Type)
             OR ((recinfo.Segment8_Type is null)
                 AND (X_Segment8_Type is null)))

        AND ((recinfo.Segment9_Type = X_Segment9_Type)
             OR ((recinfo.Segment9_Type is null)
                 AND (X_Segment9_Type is null)))

        AND ((recinfo.Segment10_Type = X_Segment10_Type)
             OR ((recinfo.Segment10_Type is null)
                 AND (X_Segment10_Type is null)))

        AND ((recinfo.Segment11_Type = X_Segment11_Type)
             OR ((recinfo.Segment11_Type is null)
                 AND (X_Segment11_Type is null)))

        AND ((recinfo.Segment12_Type = X_Segment12_Type)
             OR ((recinfo.Segment12_Type is null)
                 AND (X_Segment12_Type is null)))

        AND ((recinfo.Segment13_Type = X_Segment13_Type)
             OR ((recinfo.Segment13_Type is null)
                 AND (X_Segment13_Type is null)))

        AND ((recinfo.Segment14_Type = X_Segment14_Type)
             OR ((recinfo.Segment14_Type is null)
                 AND (X_Segment14_Type is null)))

        AND ((recinfo.Segment15_Type = X_Segment15_Type)
             OR ((recinfo.Segment15_Type is null)
                 AND (X_Segment15_Type is null)))

        AND ((recinfo.Segment16_Type = X_Segment16_Type)
             OR ((recinfo.Segment16_Type is null)
                 AND (X_Segment16_Type is null)))

        AND ((recinfo.Segment17_Type = X_Segment17_Type)
             OR ((recinfo.Segment17_Type is null)
                 AND (X_Segment17_Type is null)))

        AND ((recinfo.Segment18_Type = X_Segment18_Type)
             OR ((recinfo.Segment18_Type is null)
                 AND (X_Segment18_Type is null)))

        AND ((recinfo.Segment19_Type = X_Segment19_Type)
             OR ((recinfo.Segment19_Type is null)
                 AND (X_Segment19_Type is null)))

        AND ((recinfo.Segment20_Type = X_Segment20_Type)
             OR ((recinfo.Segment20_Type is null)
                 AND (X_Segment20_Type is null)))

        AND ((recinfo.Segment21_Type = X_Segment21_Type)
             OR ((recinfo.Segment21_Type is null)
                 AND (X_Segment21_Type is null)))

        AND ((recinfo.Segment22_Type = X_Segment22_Type)
             OR ((recinfo.Segment22_Type is null)
                 AND (X_Segment22_Type is null)))

        AND ((recinfo.Segment23_Type = X_Segment23_Type)
             OR ((recinfo.Segment23_Type is null)
                 AND (X_Segment23_Type is null)))

        AND ((recinfo.Segment24_Type = X_Segment24_Type)
             OR ((recinfo.Segment24_Type is null)
                 AND (X_Segment24_Type is null)))

        AND ((recinfo.Segment25_Type = X_Segment25_Type)
             OR ((recinfo.Segment25_Type is null)
                 AND (X_Segment25_Type is null)))

        AND ((recinfo.Segment26_Type = X_Segment26_Type)
             OR ((recinfo.Segment26_Type is null)
                 AND (X_Segment26_Type is null)))

        AND ((recinfo.Segment27_Type = X_Segment27_Type)
             OR ((recinfo.Segment27_Type is null)
                 AND (X_Segment27_Type is null)))

        AND ((recinfo.Segment28_Type = X_Segment28_Type)
             OR ((recinfo.Segment28_Type is null)
                 AND (X_Segment28_Type is null)))

        AND ((recinfo.Segment29_Type = X_Segment29_Type)
             OR ((recinfo.Segment29_Type is null)
                 AND (X_Segment29_Type is null)))

        AND ((recinfo.Segment30_Type = X_Segment30_Type)
             OR ((recinfo.Segment30_Type is null)
                 AND (X_Segment30_Type is null)))

        AND ((recinfo.Attribute1 = X_Attribute1)
             OR ((recinfo.Attribute1 is null)
                 AND (X_Attribute1 is null)))

        AND ((recinfo.Attribute2 = X_Attribute2)
             OR ((recinfo.Attribute2 is null)
                 AND (X_Attribute2 is null)))

        AND ((recinfo.Attribute3 = X_Attribute3)
             OR ((recinfo.Attribute3 is null)
                 AND (X_Attribute3 is null)))

        AND ((recinfo.Attribute4 = X_Attribute4)
             OR ((recinfo.Attribute4 is null)
                 AND (X_Attribute4 is null)))

        AND ((recinfo.Attribute5 = X_Attribute5)
             OR ((recinfo.Attribute5 is null)
                 AND (X_Attribute5 is null)))

        AND ((recinfo.Attribute6 = X_Attribute6)
             OR ((recinfo.Attribute6 is null)
                 AND (X_Attribute6 is null)))

        AND ((recinfo.Attribute7 = X_Attribute7)
             OR ((recinfo.Attribute7 is null)
                 AND (X_Attribute7 is null)))

        AND ((recinfo.Attribute8 = X_Attribute8)
             OR ((recinfo.Attribute8 is null)
                 AND (X_Attribute8 is null)))

        AND ((recinfo.Attribute9 = X_Attribute9)
             OR ((recinfo.Attribute9 is null)
                 AND (X_Attribute9 is null)))

        AND ((recinfo.Attribute10 = X_Attribute10)
             OR ((recinfo.Attribute10 is null)
                 AND (X_Attribute10 is null)))
    ) THEN
        return;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

  END Lock_Row;

  --** Modified call to Insert_Row
  PROCEDURE Insert_Org(X_Rowid                IN OUT NOCOPY    VARCHAR2,
                       X_Budget_Entity_Id     IN OUT NOCOPY    NUMBER,
                       X_Name                           VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Budget_Password_Required       VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Encrypted_Budget_Password      VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Segment1_Type                  NUMBER,
                       X_Segment2_Type                  NUMBER,
                       X_Segment3_Type                  NUMBER,
                       X_Segment4_Type                  NUMBER,
                       X_Segment5_Type                  NUMBER,
                       X_Segment6_Type                  NUMBER,
                       X_Segment7_Type                  NUMBER,
                       X_Segment8_Type                  NUMBER,
                       X_Segment9_Type                  NUMBER,
                       X_Segment10_Type                 NUMBER,
                       X_Segment11_Type                 NUMBER,
                       X_Segment12_Type                 NUMBER,
                       X_Segment13_Type                 NUMBER,
                       X_Segment14_Type                 NUMBER,
                       X_Segment15_Type                 NUMBER,
                       X_Segment16_Type                 NUMBER,
                       X_Segment17_Type                 NUMBER,
                       X_Segment18_Type                 NUMBER,
                       X_Segment19_Type                 NUMBER,
                       X_Segment20_Type                 NUMBER,
                       X_Segment21_Type                 NUMBER,
                       X_Segment22_Type                 NUMBER,
                       X_Segment23_Type                 NUMBER,
                       X_Segment24_Type                 NUMBER,
                       X_Segment25_Type                 NUMBER,
                       X_Segment26_Type                 NUMBER,
                       X_Segment27_Type                 NUMBER,
                       X_Segment28_Type                 NUMBER,
                       X_Segment29_Type                 NUMBER,
                       X_Segment30_Type                 NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Context                        VARCHAR2
   ) IS

   L_All_Org BOOLEAN;
   L_Coa_Id  NUMBER(15);
   L_Translated_All VARCHAR2(80);
   L_Message VARCHAR2(240);

  BEGIN

     SELECT chart_of_accounts_id
     INTO   L_Coa_Id
     FROM   GL_LEDGERS
     WHERE  ledger_id = X_Ledger_Id;

     SELECT meaning
     INTO   L_Translated_All
     FROM   GL_LOOKUPS
     WHERE  lookup_type = 'LITERAL'
     AND    lookup_code = 'ALL';

     IF (upper(X_Name) = L_Translated_All) THEN
        L_All_Org := TRUE;
     ELSE
        L_All_Org := FALSE;
     END IF;

     GL_BUDGET_ENTITIES_PKG.Insert_Row(
              X_Rowid,
              X_Budget_Entity_Id,
              X_Name,
              X_Ledger_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Budget_Password_Required,
              X_Status_Code,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Encrypted_Budget_Password,
              X_Description,
              X_Start_Date,
              X_End_Date,
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
              X_Context,
              L_All_Org,
              L_Coa_Id,
              'N');
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_BUDGET_ENTITIES_PKG.Insert_Org');
      RAISE;
  END Insert_Org;


  FUNCTION Submit_Assign_Ranges_Request(
			  X_Ledger_id       IN VARCHAR2,
			  X_Orgid       IN VARCHAR2)
			  return NUMBER IS

  L_request_id NUMBER;
  request_failed EXCEPTION;

  BEGIN

  L_request_id := 0;

  L_request_id := FND_REQUEST.SUBMIT_REQUEST(
		 'SQLGL', 'GLBAAR', NULL, NULL, FALSE,
		 X_Ledger_id,  X_Orgid,  chr(0),
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '', '', '', '',
                 '', '', '', '', '', '', '');

  IF (L_request_id = 0) THEN
     RAISE request_failed;
  END IF;

  RETURN (L_request_id);

  EXCEPTION
    WHEN request_failed THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_BUDGET_ENTITIES_PKG.Insert_Org');
      RAISE;

  END Submit_Assign_Ranges_Request;


  PROCEDURE Set_BC_Timestamp(X_Ledger_Id       NUMBER) IS

  L_User_Id    NUMBER;
  L_Login_Id   NUMBER;
  L_Coa_Id     NUMBER;

  BEGIN

  L_User_Id := FND_GLOBAL.user_id;
  L_Login_Id := FND_GLOBAL.login_id;

  SELECT chart_of_accounts_id
  INTO   L_Coa_Id
  FROM   gl_ledgers
  WHERE  ledger_id = X_Ledger_Id;

  GL_BC_EVENT_TSTAMPS_PKG.Set_Event_Timestamp(L_Coa_Id,
                                              'B',
                                              L_User_Id,
                                              L_Login_Id);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_BUDGET_ORG_PKG.Set_BC_Timestamp');
      RAISE;
  END Set_BC_Timestamp;

END gl_budget_entities_pkg;

/
