--------------------------------------------------------
--  DDL for Package Body GL_BUDGETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGETS_PKG" AS
/* $Header: glibddfb.pls 120.5 2005/05/05 01:01:17 kvora ship $ */

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Procedure
  --   check_detail_budgets
  -- Purpose
  --   Checks to make sure the budget isn't assigned to a detail budget
  --   between the time its last valid period is changed and the time
  --   this change is committed.  Due to the check done in lock_master_budgets,
  --   this could only occur if the same user was modifying both budgets.
  -- History
  --   10-25-93  D. J. Ogg        Created
  --   04-02-01  N. A. Alvarez    Replaced set_of_books with ledger_id
  -- Arguments
  --   x_budget_version_id        Budget version ID of the updated budget
  --   x_budget_name              Name of the updated budget
  --   x_first_valid_period_name  New first valid period of the updated budget
  --   x_last_valid_period_name   New last valid period of the updated budget
  -- Example
  --   gl_budget_misc_pkg.check_detail_budgets(1000, 'JAN-91', 'DEC-91')
  -- Notes
  --
  PROCEDURE check_detail_budgets(
  		x_budget_version_id NUMBER,
                x_budget_name VARCHAR2,
                x_first_valid_period_name VARCHAR2,
                x_last_valid_period_name VARCHAR2) IS
    CURSOR chk_details IS
      SELECT 'Master budget'
      FROM   gl_budget_versions bv, gl_budgets b
      WHERE  bv.control_budget_version_id =
               x_budget_version_id
      AND    b.budget_name = bv.budget_name
      AND    b.budget_type = bv.budget_type
      AND    (    (b.first_valid_period_name <>
                    x_first_valid_period_name)
              OR  (b.last_valid_period_name <>
                    x_last_valid_period_name));
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_details;
    FETCH chk_details INTO dummy;

    IF chk_details%FOUND THEN
      CLOSE chk_details;
      fnd_message.set_name('SQLGL',
                           'GL_BUD_NOT_W_MASTER_DETAIL');
      app_exception.raise_exception;
    ELSE
      CLOSE chk_details;
    END IF;
  END check_detail_budgets;

  --
  -- Procedure
  --   lock_master_budgets
  -- Purpose
  --   Lock the master budget to make sure its last valid period is not
  --   changed between the time it is checked in the pre-insert/pre-update
  --   triggers and the time it is committed.
  -- History
  --   10-25-93  D. J. Ogg    Created
  -- Arguments
  --   x_budget_version_id        Budget version ID of the updated budget
  --   x_first_valid_period_name  New first valid period of the updated budget
  --   x_last_valid_period_name   New last valid period of the updated budget
  -- Example
  --   gl_budget_misc_pkg.lock_master_budgets(1000, 'JAN-91', 'DEC-91')
  -- Notes
  --
  PROCEDURE lock_master_budget(
    		x_master_budget_version_id NUMBER,
                x_first_valid_period_name VARCHAR2,
                x_last_valid_period_name VARCHAR2) IS
    CURSOR lock_master IS
      SELECT 'Master budget'
      FROM   gl_budgets b
      WHERE  b.budget_name =
        (SELECT bv.budget_name
         FROM   gl_budget_versions bv
         WHERE  bv.budget_version_id =
                  x_master_budget_version_id)
      AND    b.budget_type = 'standard'
      AND    b.first_valid_period_name =
               x_first_valid_period_name
      AND    b.last_valid_period_name =
               x_last_valid_period_name
      FOR UPDATE OF b.first_valid_period_name,
                    b.last_valid_period_name;
    dummy VARCHAR2(100);
  BEGIN
    OPEN lock_master;
    FETCH lock_master INTO dummy;

    IF lock_master%FOUND THEN
      CLOSE lock_master;
    ELSE
      CLOSE lock_master;
      fnd_message.set_name('SQLGL', 'GL_BUD_MASTER_CHANGED');
      app_exception.raise_exception;
    END IF;
  END lock_master_budget;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_unique(name VARCHAR2,
                         row_id VARCHAR2) IS
    CURSOR chk_duplicates IS
      SELECT 'Duplicate'
      FROM   GL_BUDGETS bud
      WHERE  bud.budget_name = name
      AND    bud.budget_type = 'standard'
      AND    (   row_id is null
              OR bud.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_BUDGET_NAME');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_budgets_pkg.check_unique');
      RAISE;
  END check_unique;

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_budget_versions_s.NEXTVAL
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
      fnd_message.set_token('SEQUENCE', 'GL_BUDGET_VERSIONS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_budgets_pkg.get_unique_id');
      RAISE;
  END get_unique_id;


  FUNCTION is_budget_journals_not_req(
    x_ledger_id  NUMBER ) RETURN BOOLEAN  IS

    CURSOR c_no_journal IS
      SELECT 'found'
      FROM   GL_BUDGETS b
      WHERE  b.ledger_id = x_ledger_id
      AND    b.require_budget_journals_flag = 'N';

    dummy VARCHAR2(100);

  BEGIN

    OPEN  c_no_journal;
    FETCH c_no_journal INTO dummy;

    IF c_no_journal%FOUND THEN
      CLOSE c_no_journal;
      RETURN( TRUE );
    ELSE
      CLOSE c_no_journal;
      RETURN( FALSE );
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_BUDGET_ASGM_RNG_PKG.is_budget_journals_not_req');
      RAISE;

  END is_budget_journals_not_req;


  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_budgets%ROWTYPE )  IS
  BEGIN
    SELECT  *
    INTO    recinfo
    FROM    gl_budgets
    WHERE   ledger_id = recinfo.ledger_id
    AND     budget_name = recinfo.budget_name ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budgets.select_row');
      RAISE;
  END select_row;


  PROCEDURE select_columns(
              x_budget_name                     VARCHAR2,
              x_ledger_id                       NUMBER,
              x_budget_type                     IN OUT NOCOPY  VARCHAR2,
              x_status                          IN OUT NOCOPY  VARCHAR2,
              x_required_bj_flag                IN OUT NOCOPY  VARCHAR2,
              x_latest_opened_year              IN OUT NOCOPY  NUMBER,
              x_first_valid_period_name         IN OUT NOCOPY  VARCHAR2,
              x_last_valid_period_name          IN OUT NOCOPY  VARCHAR2 ) IS

    recinfo gl_budgets%ROWTYPE;

  BEGIN
    recinfo.ledger_id := x_ledger_id;
    recinfo.budget_name := x_budget_name;
    select_row( recinfo );
    x_budget_type := recinfo.budget_type;
    x_status := recinfo.status;
    x_required_bj_flag := recinfo.require_budget_journals_flag;
    x_latest_opened_year := recinfo.latest_opened_year;
    x_first_valid_period_name := recinfo.first_valid_period_name;
    x_last_valid_period_name := recinfo.last_valid_period_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budgets.select_columns');
      RAISE;
  END select_columns;


PROCEDURE Insert_Row(X_Rowid                           IN OUT NOCOPY VARCHAR2,
                     X_Budget_Type                     VARCHAR2,
                     X_Budget_Name                     VARCHAR2,
                     X_ledger_id                       NUMBER,
                     X_Status                          VARCHAR2,
                     X_Date_Created                    DATE,
                     X_Require_Budget_Journals_Flag    VARCHAR2,
                     X_Current_Version_Id              NUMBER DEFAULT NULL,
                     X_Latest_Opened_Year              NUMBER DEFAULT NULL,
                     X_First_Valid_Period_Name         VARCHAR2 DEFAULT NULL,
                     X_Last_Valid_Period_Name          VARCHAR2 DEFAULT NULL,
                     X_Description                     VARCHAR2 DEFAULT NULL,
                     X_Date_Closed                     DATE DEFAULT NULL,
                     X_Attribute1                      VARCHAR2 DEFAULT NULL,
                     X_Attribute2                      VARCHAR2 DEFAULT NULL,
                     X_Attribute3                      VARCHAR2 DEFAULT NULL,
                     X_Attribute4                      VARCHAR2 DEFAULT NULL,
                     X_Attribute5                      VARCHAR2 DEFAULT NULL,
                     X_Attribute6                      VARCHAR2 DEFAULT NULL,
                     X_Attribute7                      VARCHAR2 DEFAULT NULL,
                     X_Attribute8                      VARCHAR2 DEFAULT NULL,
                     X_Context                         VARCHAR2 DEFAULT NULL,
		     X_User_Id 			       NUMBER,
		     X_Login_Id			       NUMBER,
		     X_Date                            DATE,
		     X_Budget_Version_Id	       NUMBER,
		     X_Master_Budget_Version_Id        NUMBER DEFAULT NULL
 ) IS
   CURSOR C IS SELECT rowid FROM GL_BUDGETS
           WHERE budget_name = X_Budget_Name;
 BEGIN

   -- If the budget is the current budget, then make sure there are no
   -- other current budgets.
   IF (X_Status = 'C') THEN
     DECLARE
        bvid            NUMBER;
        bname           VARCHAR2(15);
        bj_required     VARCHAR2(2);
     BEGIN
       gl_budget_utils_pkg.get_current_budget(
         X_ledger_id,
         bvid,
         bname,
         bj_required);

       IF (    (bvid IS NOT NULL)
           AND (bvid <> X_Budget_Version_Id)) THEN
         fnd_message.set_name('SQLGL', 'GL_BUD_MULTIPLE_CURRENT_BUDGET');
         app_exception.raise_exception;

       END IF;
     END;
   END IF;

   -- Lock and check the master budget
   IF (x_master_budget_version_id IS NOT NULL) THEN
     gl_budgets_pkg.lock_master_budget(x_master_budget_version_id,
                                       x_first_valid_period_name,
                                       x_last_valid_period_name);
   END IF;


  -- Do the insert
  INSERT INTO GL_BUDGETS(
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         budget_type,
         budget_name,
         ledger_id,
         status,
         date_created,
         require_budget_journals_flag,
         current_version_id,
         latest_opened_year,
         first_valid_period_name,
         last_valid_period_name,
         description,
         date_closed,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         context

        ) VALUES (
        X_Date,
        X_User_Id,
        X_Date,
        X_User_Id,
        X_Login_Id,
        X_Budget_Type,
        X_Budget_Name,
        X_ledger_id,
        X_Status,
        X_Date_Created,
        X_Require_Budget_Journals_Flag,
        X_Current_Version_Id,
        X_Latest_Opened_Year,
        X_First_Valid_Period_Name,
        X_Last_Valid_Period_Name,
        X_Description,
        X_Date_Closed,
        X_Attribute1,
        X_Attribute2,
        X_Attribute3,
        X_Attribute4,
        X_Attribute5,
        X_Attribute6,
        X_Attribute7,
        X_Attribute8,
        X_Context

  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  -- Insert the associated rows in gl_budget_versions
  gl_budget_versions_pkg.insert_record(	x_budget_version_id,
				 	x_budget_name,
					x_status,
					x_master_budget_version_id,
					x_user_id,
					x_login_id);

  -- Insert the associated rows in gl_budget_batches
  gl_budget_batches_pkg.insert_budget( 	x_budget_version_id,
				      	x_ledger_id,
					x_user_id);

  -- Insert the associated rows in gl_entity_budgets
  gl_entity_budgets_pkg.insert_budget(	x_budget_version_id,
					x_ledger_id,
					x_user_id,
					x_login_id);

END Insert_Row;

PROCEDURE Lock_Row(
		   X_Rowid                             VARCHAR2,
                   X_Budget_Type                       VARCHAR2,
                   X_Budget_Name                       VARCHAR2,
                   X_ledger_id                         NUMBER,
                   X_Last_Update_Date                  DATE,
                   X_Last_Updated_By                   NUMBER,
                   X_Status                            VARCHAR2,
                   X_Date_Created                      DATE,
                   X_Require_Budget_Journals_Flag      VARCHAR2,
                   X_Creation_Date                     DATE DEFAULT NULL,
                   X_Created_By                        NUMBER DEFAULT NULL,
                   X_Last_Update_Login                 NUMBER DEFAULT NULL,
                   X_Current_Version_Id                NUMBER DEFAULT NULL,
                   X_Latest_Opened_Year                NUMBER DEFAULT NULL,
                   X_First_Valid_Period_Name           VARCHAR2 DEFAULT NULL,
                   X_Last_Valid_Period_Name            VARCHAR2 DEFAULT NULL,
                   X_Description                       VARCHAR2 DEFAULT NULL,
                   X_Date_Closed                       DATE DEFAULT NULL,
                   X_Attribute1                        VARCHAR2 DEFAULT NULL,
                   X_Attribute2                        VARCHAR2 DEFAULT NULL,
                   X_Attribute3                        VARCHAR2 DEFAULT NULL,
                   X_Attribute4                        VARCHAR2 DEFAULT NULL,
                   X_Attribute5                        VARCHAR2 DEFAULT NULL,
                   X_Attribute6                        VARCHAR2 DEFAULT NULL,
                   X_Attribute7                        VARCHAR2 DEFAULT NULL,
                   X_Attribute8                        VARCHAR2 DEFAULT NULL,
                   X_Context                           VARCHAR2 DEFAULT NULL

) IS
  CURSOR C IS
      SELECT *
      FROM   GL_BUDGETS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Budget_Name NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  CLOSE C;

  if (
         (   (Recinfo.budget_type = X_Budget_Type)
          OR (    (Recinfo.budget_type IS NULL)
              AND (X_Budget_Type IS NULL)))
     AND (   (Recinfo.budget_name = X_Budget_Name)
          OR (    (Recinfo.budget_name IS NULL)
              AND (X_Budget_Name IS NULL)))
     AND (   (Recinfo.ledger_id = X_ledger_id)
          OR (    (Recinfo.ledger_id IS NULL)
              AND (X_ledger_id IS NULL)))
     AND (   (Recinfo.last_update_date = X_Last_Update_Date)
          OR (    (Recinfo.last_update_date IS NULL)
              AND (X_Last_Update_Date IS NULL)))
     AND (   (Recinfo.last_updated_by = X_Last_Updated_By)
          OR (    (Recinfo.last_updated_by IS NULL)
              AND (X_Last_Updated_By IS NULL)))
     AND (   (Recinfo.status = X_Status)
          OR (    (Recinfo.status IS NULL)
              AND (X_Status IS NULL)))
     AND (   (Recinfo.date_created = X_Date_Created)
          OR (    (Recinfo.date_created IS NULL)
              AND (X_Date_Created IS NULL)))
     AND (   (Recinfo.require_budget_journals_flag =
     X_Require_Budget_Journals_Flag)
          OR (    (Recinfo.require_budget_journals_flag IS NULL)
              AND (X_Require_Budget_Journals_Flag IS NULL)))
     AND (   (Recinfo.creation_date = X_Creation_Date)
          OR (    (Recinfo.creation_date IS NULL)
              AND (X_Creation_Date IS NULL)))
     AND (   (Recinfo.created_by = X_Created_By)
          OR (    (Recinfo.created_by IS NULL)
              AND (X_Created_By IS NULL)))
     AND (   (Recinfo.last_update_login = X_Last_Update_Login)
          OR (    (Recinfo.last_update_login IS NULL)
              AND (X_Last_Update_Login IS NULL)))
     AND (   (Recinfo.current_version_id = X_Current_Version_Id)
          OR (    (Recinfo.current_version_id IS NULL)
              AND (X_Current_Version_Id IS NULL)))
     AND (   (Recinfo.latest_opened_year = X_Latest_Opened_Year)
          OR (    (Recinfo.latest_opened_year IS NULL)
              AND (X_Latest_Opened_Year IS NULL)))
     AND (   (Recinfo.first_valid_period_name = X_First_Valid_Period_Name)
          OR (    (Recinfo.first_valid_period_name IS NULL)
              AND (X_First_Valid_Period_Name IS NULL)))
     AND (   (Recinfo.last_valid_period_name = X_Last_Valid_Period_Name)
          OR (    (Recinfo.last_valid_period_name IS NULL)
              AND (X_Last_Valid_Period_Name IS NULL)))
     AND (   (Recinfo.description = X_Description)
          OR (    (Recinfo.description IS NULL)
              AND (X_Description IS NULL)))
     AND (   (Recinfo.date_closed = X_Date_Closed)
          OR (    (Recinfo.date_closed IS NULL)
              AND (X_Date_Closed IS NULL)))
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
     AND (   (Recinfo.attribute6 = X_Attribute6)
          OR (    (Recinfo.attribute6 IS NULL)
              AND (X_Attribute6 IS NULL)))
     AND (   (Recinfo.attribute7 = X_Attribute7)
          OR (    (Recinfo.attribute7 IS NULL)
              AND (X_Attribute7 IS NULL)))
     AND (   (Recinfo.attribute8 = X_Attribute8)
          OR (    (Recinfo.attribute8 IS NULL)
              AND (X_Attribute8 IS NULL)))
     AND (   (Recinfo.context = X_Context)
          OR (    (Recinfo.context IS NULL)
              AND (X_Context IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                           VARCHAR2,
                     X_Budget_Type                     VARCHAR2,
                     X_Budget_Name                     VARCHAR2,
                     X_ledger_id                       NUMBER,
                     X_Status                          VARCHAR2,
                     X_Date_Created                    DATE,
                     X_Require_Budget_Journals_Flag    VARCHAR2,
                     X_Current_Version_Id              NUMBER DEFAULT NULL,
                     X_Latest_Opened_Year              NUMBER DEFAULT NULL,
                     X_First_Valid_Period_Name         VARCHAR2 DEFAULT NULL,
                     X_Last_Valid_Period_Name          VARCHAR2 DEFAULT NULL,
                     X_Description                     VARCHAR2 DEFAULT NULL,
                     X_Date_Closed                     DATE DEFAULT NULL,
                     X_Attribute1                      VARCHAR2 DEFAULT NULL,
                     X_Attribute2                      VARCHAR2 DEFAULT NULL,
                     X_Attribute3                      VARCHAR2 DEFAULT NULL,
                     X_Attribute4                      VARCHAR2 DEFAULT NULL,
                     X_Attribute5                      VARCHAR2 DEFAULT NULL,
                     X_Attribute6                      VARCHAR2 DEFAULT NULL,
                     X_Attribute7                      VARCHAR2 DEFAULT NULL,
                     X_Attribute8                      VARCHAR2 DEFAULT NULL,
                     X_Context                         VARCHAR2 DEFAULT NULL,
                     X_User_Id                         NUMBER,
                     X_Login_Id                        NUMBER,
                     X_Date                            DATE,
		     X_Budget_Version_Id	       NUMBER,
		     X_Master_Budget_Version_Id        NUMBER DEFAULT NULL

) IS
BEGIN

   -- If the budget is the current budget, then make sure there are no
   -- other current budgets.
   IF (X_Status = 'C') THEN
     DECLARE
        bvid            NUMBER;
        bname           VARCHAR2(15);
        bj_required     VARCHAR2(2);
     BEGIN
       gl_budget_utils_pkg.get_current_budget(
         X_ledger_id,
         bvid,
         bname,
         bj_required);

       IF (    (bvid IS NOT NULL)
           AND (bvid <> X_Budget_Version_Id)) THEN
         fnd_message.set_name('SQLGL', 'GL_BUD_MULTIPLE_CURRENT_BUDGET');
         app_exception.raise_exception;

       END IF;
     END;
   END IF;

   -- Lock and check the master budget
   IF (x_master_budget_version_id IS NOT NULL) THEN
     gl_budgets_pkg.lock_master_budget(x_master_budget_version_id,
                                       x_first_valid_period_name,
                                       x_last_valid_period_name);
   END IF;

  -- Check any detail budgets that may have been changed by this same
  -- commit
  gl_budgets_pkg.check_detail_budgets(	x_budget_version_id,
                                        x_budget_name,
					x_first_valid_period_name,
					x_last_valid_period_name);

  UPDATE GL_BUDGETS
  SET
    last_updated_by                      =   X_User_Id,
    last_update_login                    =   X_Login_Id,
    last_update_date                     =   X_Date,
    budget_type                          =   X_Budget_Type,
    budget_name                          =   X_Budget_Name,
    ledger_id                            =   X_ledger_id,
    status                               =   X_Status,
    date_created                         =   X_Date_Created,
    require_budget_journals_flag         =   X_Require_Budget_Journals_Flag,
    current_version_id                   =   X_Current_Version_Id,
    latest_opened_year                   =   X_Latest_Opened_Year,
    first_valid_period_name              =   X_First_Valid_Period_Name,
    last_valid_period_name               =   X_Last_Valid_Period_Name,
    description                          =   X_Description,
    date_closed                          =   X_Date_Closed,
    attribute1                           =   X_Attribute1,
    attribute2                           =   X_Attribute2,
    attribute3                           =   X_Attribute3,
    attribute4                           =   X_Attribute4,
    attribute5                           =   X_Attribute5,
    attribute6                           =   X_Attribute6,
    attribute7                           =   X_Attribute7,
    attribute8                           =   X_Attribute8,
    context                              =   X_Context
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  -- Update the associated row in gl_budget_versions
  gl_budget_versions_pkg.update_record(	x_budget_version_id,
				 	x_budget_name,
					x_status,
					x_master_budget_version_id,
					x_user_id,
					x_login_id);

    exception
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budgets_pkg.update_row');
      RAISE;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM GL_BUDGETS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END gl_budgets_pkg;

/
