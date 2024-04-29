--------------------------------------------------------
--  DDL for Package Body GL_AUTOPOST_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTOPOST_SETS_PKG" AS
/* $Header: glistasb.pls 120.4 2005/05/05 01:22:28 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(x_autopost_set_name      VARCHAR2,
		         x_chart_of_accounts_id   NUMBER,
                         x_period_set_name        VARCHAR2,
                         x_accounted_period_type  VARCHAR2,
			 row_id                   VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_AUTOMATIC_POSTING_SETS sets
      WHERE  sets.autopost_set_name = x_autopost_set_name
      AND    sets.chart_of_accounts_id = x_Chart_Of_Accounts_Id
      AND    sets.period_set_name = x_Period_Set_Name
      AND    sets.accounted_period_type = x_Accounted_Period_Type
      AND    (   row_id is null
              OR sets.rowid <> row_id);
    dummy VARCHAR2(10);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_AUTOPOST_SETS');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_autopost_sets_pkg.check_unique');
      RAISE;
  END check_unique;

PROCEDURE Insert_Row(X_Rowid	             IN OUT NOCOPY VARCHAR2,
		     X_Autopost_Set_Id       IN OUT NOCOPY NUMBER,
                     X_Autopost_Set_Name                   VARCHAR2,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Accounted_Period_Type               VARCHAR2,
                     X_Enabled_Flag                        VARCHAR2,
                     X_Security_Flag                       VARCHAR2,
                     X_Submit_All_Priorities_Flag          VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
		     X_description			   VARCHAR2,
		     X_num_of_priority_options             NUMBER,
		     X_effective_days_before               NUMBER,
		     X_effective_days_after                NUMBER,
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
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_AUTOMATIC_POSTING_SETS
             WHERE autopost_set_id = X_autopost_set_id
             AND   autopost_set_name = X_autopost_set_name;

   CURSOR C2 IS SELECT gl_automatic_posting_sets_s.nextval FROM DUAL;


BEGIN

  if (X_autopost_set_id IS NULL) then
    OPEN C2;
    FETCH C2 INTO X_autopost_set_id;
    CLOSE C2;
  end if;
  INSERT INTO GL_AUTOMATIC_POSTING_SETS(
	  autopost_set_id,
	  autopost_set_name,
          chart_of_accounts_id,
          period_set_name,
          accounted_period_type,
	  enabled_flag,
          security_flag,
	  submit_all_priorities_flag,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
	  description,
	  num_of_priority_options,
	  effective_days_before,
	  effective_days_after,
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
          attribute15,
          context
         ) VALUES (
          X_Autopost_Set_Id,
          X_Autopost_Set_Name,
          X_Chart_Of_Accounts_Id,
          X_Period_Set_Name,
          X_Accounted_Period_Type,
          X_Enabled_Flag,
          X_Security_Flag,
          X_Submit_All_Priorities_Flag,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
	  X_Description,
	  X_Num_Of_Priority_Options,
	  X_Effective_Days_Before,
	  X_Effective_Days_After,
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
          X_Attribute15,
          X_Context

  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE   Lock_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Autopost_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Autopost_Set_Name                     VARCHAR2,
                     X_Chart_Of_Accounts_Id                  NUMBER,
                     X_Period_Set_Name                       VARCHAR2,
                     X_Accounted_Period_Type                 VARCHAR2,
                     X_Enabled_Flag                          VARCHAR2,
                     X_Security_Flag                         VARCHAR2,
                     X_Submit_All_Priorities_Flag            VARCHAR2,
		     X_description			     VARCHAR2,
                     X_Num_Of_Priority_Options               NUMBER,
                     X_Effective_Days_Before                 NUMBER,
                     X_Effective_Days_After                  NUMBER,
                     X_Attribute1                            VARCHAR2,
                     X_Attribute2                            VARCHAR2,
                     X_Attribute3                            VARCHAR2,
                     X_Attribute4                            VARCHAR2,
                     X_Attribute5                            VARCHAR2,
                     X_Attribute6                            VARCHAR2,
                     X_Attribute7                            VARCHAR2,
                     X_Attribute8                            VARCHAR2,
                     X_Attribute9                            VARCHAR2,
                     X_Attribute10                           VARCHAR2,
                     X_Attribute11                           VARCHAR2,
                     X_Attribute12                           VARCHAR2,
                     X_Attribute13                           VARCHAR2,
                     X_Attribute14                           VARCHAR2,
                     X_Attribute15                           VARCHAR2,
                     X_Context                               VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_AUTOMATIC_POSTING_SETS
      WHERE  rowid = X_Rowid
      FOR UPDATE of autopost_set_id NOWAIT;
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
          (   (Recinfo.autopost_set_id = X_autopost_set_id)
           OR (    (Recinfo.autopost_set_id IS NULL)
               AND (X_autopost_set_id IS NULL)))
      AND (   (Recinfo.autopost_set_name = X_autopost_set_name)
           OR (    (Recinfo.autopost_set_name IS NULL)
               AND (X_autopost_set_name IS NULL)))
      AND (   (Recinfo.chart_of_accounts_id = X_chart_of_accounts_id)
           OR (    (Recinfo.chart_of_accounts_id IS NULL)
               AND (X_chart_of_accounts_id IS NULL)))
      AND (   (Recinfo.period_set_name = X_period_set_name)
           OR (    (Recinfo.period_set_name IS NULL)
               AND (X_period_set_name IS NULL)))
      AND (   (Recinfo.accounted_period_type = X_accounted_period_type)
           OR (    (Recinfo.accounted_period_type IS NULL)
               AND (X_accounted_period_type IS NULL)))
      AND (   (Recinfo.enabled_flag = X_enabled_flag)
           OR (    (Recinfo.enabled_flag IS NULL)
               AND (X_enabled_flag IS NULL)))
      AND (   (Recinfo.security_flag = X_security_flag)
           OR (    (Recinfo.security_flag IS NULL)
               AND (X_security_flag IS NULL)))
      AND (   (Recinfo.submit_all_priorities_flag = X_submit_all_priorities_flag)
           OR (    (Recinfo.submit_all_priorities_flag IS NULL)
               AND (X_submit_all_priorities_flag IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.num_of_priority_options = X_Num_Of_Priority_Options)
           OR (    (Recinfo.num_of_priority_options IS NULL)
               AND (X_Num_Of_Priority_Options IS NULL)))
      AND (   (Recinfo.effective_days_before = X_Effective_Days_Before)
           OR (    (Recinfo.effective_days_before IS NULL)
               AND (X_Effective_Days_Before IS NULL)))
      AND (   (Recinfo.effective_days_after = X_Effective_Days_After)
           OR (    (Recinfo.effective_days_after IS NULL)
               AND (X_Effective_Days_After IS NULL)))
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
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
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

PROCEDURE Update_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                     X_Autopost_Set_ID       IN OUT NOCOPY NUMBER,
                     X_Autopost_Set_Name                   VARCHAR2,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Accounted_Period_Type               VARCHAR2,
                     X_Enabled_Flag                        VARCHAR2,
                     X_Security_Flag                       VARCHAR2,
                     X_Submit_All_Priorities_Flag          VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Description                         VARCHAR2,
                     X_Num_Of_Priority_Options             NUMBER,
                     X_Effective_Days_Before               NUMBER,
                     X_Effective_Days_After                NUMBER,
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
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2
) IS
BEGIN
  UPDATE GL_AUTOMATIC_POSTING_SETS
  SET

    autopost_set_id                           =    X_Autopost_Set_Id,
    autopost_set_name                         =    X_autopost_set_name,
    chart_of_accounts_id                      =    X_Chart_Of_Accounts_Id,
    period_set_name                           =    X_Period_Set_Name,
    accounted_period_type                     =    X_Accounted_Period_Type,
    enabled_flag                              =    X_enabled_flag,
    security_flag                             =    X_Security_Flag,
    submit_all_priorities_flag                =    X_submit_all_priorities_flag,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    creation_date			      =    X_Creation_Date,
    created_by                                =    X_Created_By,
    description                               =    X_Description,
    num_of_priority_options                   =    X_Num_Of_Priority_Options,
    effective_days_before                     =    X_effective_days_before,
    effective_days_after                      =    X_effective_days_after,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    context                                   =    X_Context
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;


PROCEDURE Delete_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Autopost_Set_ID              IN OUT NOCOPY NUMBER ) IS
BEGIN
  DELETE FROM GL_AUTOMATIC_POSTING_OPTIONS
  WHERE  autopost_set_id = X_Autopost_Set_Id;

  DELETE FROM GL_AUTOMATIC_POSTING_SETS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

FUNCTION	submit_request	(
		X_access_set_id         NUMBER,
		X_autopost_set_id	NUMBER) RETURN NUMBER IS
	   ret_code	NUMBER;
        BEGIN
	       ret_code :=  FND_REQUEST.SUBMIT_REQUEST(
    		'SQLGL',
    		'GLPAUTOP',
    		'',
    		'',
    		FALSE,
    		to_char(X_access_set_id),
    		to_char(X_autopost_set_id),
    		chr(0), '', '', '', '',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','');
	   COMMIT;
	   RETURN (ret_code);
     	END submit_request;

END gl_autopost_sets_pkg;

/
