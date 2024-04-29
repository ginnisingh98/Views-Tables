--------------------------------------------------------
--  DDL for Package Body GL_ACCESS_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ACCESS_SETS_PKG" AS
/* $Header: glistaxb.pls 120.9 2005/05/05 01:22:42 kvora ship $ */

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Used to select a particular access set row
  -- History
  --   06-26-2001   T Cheng      Created
  -- Arguments
  --   recinfo		Varies information about the row
  -- Notes
  --
  PROCEDURE select_row(recinfo IN OUT NOCOPY gl_access_sets%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_access_sets
    WHERE access_set_id = recinfo.access_set_id;
  END select_row;

  --
  -- PUBLIC FUNCTIONS
  --

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT GL_ACCESS_SETS_S.NEXTVAL
      FROM dual;
    new_id NUMBER;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      RETURN (new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_ACCESS_SETS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_access_sets_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  FUNCTION has_details_in_db (X_Access_Set_Id NUMBER) RETURN BOOLEAN IS
    num     NUMBER;
    CURSOR details IS
      SELECT 1
      FROM dual
      WHERE EXISTS (SELECT 1
                    FROM  GL_ACCESS_SET_NORM_ASSIGN
                    WHERE access_set_id = X_Access_Set_Id
                    AND   (status_code   <> 'D' OR status_code IS NULL));
  BEGIN
    OPEN details;
    FETCH details INTO num;
    IF details%NOTFOUND THEN
      CLOSE details;
      RETURN FALSE;
    END IF;

    CLOSE details;
    RETURN TRUE;
  END has_details_in_db;

  FUNCTION maintain_def_ledger_assign(X_Access_Set_Id NUMBER) RETURN BOOLEAN IS
    CURSOR default_ledger_assign (def_ledger NUMBER) IS
      SELECT 1
      FROM  GL_ACCESS_SET_NORM_ASSIGN
      WHERE access_set_id = X_Access_Set_Id
      AND   ledger_id     = def_ledger
      AND   (status_code   <> 'D' OR status_code IS NULL)
      AND   rownum < 2;

    dumnum  NUMBER;
    rowid   VARCHAR2(30);

    def_ledger_id NUMBER;
    updated_by    NUMBER;
    update_login  NUMBER;
    update_date   DATE;
  BEGIN
    SELECT default_ledger_id, last_updated_by,
           last_update_login, last_update_date
    INTO   def_ledger_id, updated_by, update_login, update_date
    FROM   GL_ACCESS_SETS
    WHERE  access_set_id = X_Access_Set_ID;

    OPEN default_ledger_assign(def_ledger_id);
    FETCH default_ledger_assign INTO dumnum;
    IF default_ledger_assign%FOUND THEN
      CLOSE default_ledger_assign;
      RETURN FALSE;
    END IF;
    CLOSE default_ledger_assign;

    -- Insert default ledger assignment
    GL_ACCESS_DETAILS_PKG.Insert_Row(
      rowid,
      X_Access_Set_Id,
      def_ledger_id,
      'Y',    -- all_segment_value_flag
      'S',    -- segment_value_type_code
      'B',    -- access_privilege_code
      GL_ACCESS_DETAILS_PKG.get_record_id,   -- record_id
      updated_by,
      update_login,
      update_date,
      NULL,   -- segment_value
      NULL,   -- start_date
      NULL,   -- end_date
      'I');   -- status_code

    RETURN TRUE;
  END maintain_def_ledger_assign;

  FUNCTION get_value_set_id (X_Chart_Of_Accounts_Id   NUMBER,
                             X_Segment_Type           VARCHAR2) RETURN NUMBER
  IS
    value_set_id    NUMBER;
    CURSOR get_vs_id IS
      SELECT t1.flex_value_set_id
      FROM fnd_id_flex_segments t1, fnd_segment_attribute_values t2
      WHERE t1.application_id          = t2.application_id
      AND   t1.id_flex_code            = t2.id_flex_code
      AND   t1.id_flex_num             = t2.id_flex_num
      AND   t1.application_column_name = t2.application_column_name
      AND   t1.application_id = 101
      AND   t1.id_flex_code = 'GL#'
      AND   t1.id_flex_num = X_Chart_Of_Accounts_Id
      AND   t2.segment_attribute_type = X_Segment_Type
      AND   t2.attribute_value = 'Y';

    dummy    VARCHAR2(20);
    CURSOR check_mgt_seg IS
      SELECT 'management segment'
      FROM   fnd_segment_attribute_values
      WHERE  application_id = 101
      AND    id_flex_code = 'GL#'
      AND    id_flex_num = X_Chart_Of_Accounts_Id
      AND    segment_attribute_type = 'GL_MANAGEMENT'
      AND    attribute_value = 'Y';
  BEGIN
    OPEN get_vs_id;
    FETCH get_vs_id INTO value_set_id;

    IF get_vs_id%NOTFOUND THEN
      CLOSE get_vs_id;
      IF (X_Segment_Type = 'GL_BALANCING') THEN
        FND_MESSAGE.SET_NAME('SQLGL', 'GL_LEDGER_ERR_GETTING_BAL_SEG');

      ELSIF (X_Segment_Type = 'GL_MANAGEMENT') THEN
        -- Check if the management segment is specified for the COA
        OPEN check_mgt_seg;
        FETCH check_mgt_seg INTO dummy;

        IF check_mgt_seg%NOTFOUND THEN
          -- The COA does not have a management segment.
          FND_MESSAGE.SET_NAME('SQLGL', 'GL_ACCESS_COA_NO_MGT_SEG');
        ELSE
          FND_MESSAGE.SET_NAME('SQLGL', 'GL_LEDGER_ERR_GETTING_MGT_SEG');
        END IF;

        CLOSE check_mgt_seg;

      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE get_vs_id;
    RETURN value_set_id;

  EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'gl_access_sets_pkg.get_value_set_id');
      RAISE;
  END get_value_set_id;

  PROCEDURE select_columns(X_access_set_id			 NUMBER,
			   X_name		   IN OUT NOCOPY VARCHAR2,
			   X_security_segment_code IN OUT NOCOPY VARCHAR2,
			   X_coa_id		   IN OUT NOCOPY NUMBER,
			   X_period_set_name	   IN OUT NOCOPY VARCHAR2,
			   X_accounted_period_type IN OUT NOCOPY VARCHAR2,
			   X_auto_created_flag	   IN OUT NOCOPY VARCHAR2) IS
    recinfo gl_access_sets%ROWTYPE;
  BEGIN
    recinfo.access_set_id := X_access_set_id;
    select_row(recinfo);

    X_name := recinfo.name;
    X_security_segment_code := recinfo.security_segment_code;
    X_coa_id := recinfo.chart_of_accounts_id;
    X_period_set_name := recinfo.period_set_name;
    X_accounted_period_type := recinfo.accounted_period_type;
    X_auto_created_flag := recinfo.automatically_created_flag;
  END select_columns;


  FUNCTION Create_Implicit_Access_Set(X_Name                     VARCHAR2,
                                      X_Security_Segment_Code    VARCHAR2,
                                      X_Chart_Of_Accounts_Id     NUMBER,
                                      X_Period_Set_Name          VARCHAR2,
                                      X_Accounted_Period_Type    VARCHAR2,
                                      X_Secured_Seg_Value_Set_Id NUMBER,
                                      X_Default_Ledger_Id        NUMBER,
                                      X_Last_Updated_By          NUMBER,
                                      X_Last_Update_Login        NUMBER,
                                      X_Creation_Date            DATE,
                                      X_Description              VARCHAR2) RETURN NUMBER
  IS
    X_Access_Set_Id   NUMBER(15) := null;
    X_Row_Id          ROWID := null;
  BEGIN
    -- Get unique access set id
    X_Access_Set_Id := GL_ACCESS_SETS_PKG.get_unique_id;

    -- Create an implicit access set header for the corresponding new created ledger.
    GL_ACCESS_SETS_PKG.Insert_Row(
                       X_Row_Id,
                       X_Access_Set_Id,
                       X_Name,
                       X_Security_Segment_Code,
                       'Y',
                       X_Chart_Of_Accounts_Id,
                       X_Period_Set_Name,
                       X_Accounted_Period_Type,
                       'Y',
                       X_Secured_Seg_Value_Set_Id,
                       X_Default_Ledger_Id,
                       X_Last_Updated_By,
                       X_Last_Update_Login,
                       X_Creation_Date,
                       X_Description);

    RETURN X_Access_Set_Id;

  END Create_Implicit_Access_Set;

  PROCEDURE Update_Implicit_Access_Set(X_Access_Set_Id            NUMBER,
                                       X_Name                     VARCHAR2,
                                       X_Last_Update_Date         DATE,
                                       X_Last_Updated_By          NUMBER,
                                       X_Last_Update_Login        NUMBER)
  IS
  BEGIN
    -- Update the name of an implicit access set header when it is updated
    -- for the corresponding ledger.
    UPDATE GL_ACCESS_SETS
    SET
      name                        = X_Name,
      last_update_date            = X_Last_Update_Date,
      last_updated_by             = X_Last_Updated_By,
      last_update_login           = X_Last_Update_Login
    WHERE
      access_set_id = X_Access_Set_Id
      AND automatically_created_flag = 'Y';

  END Update_Implicit_Access_Set;

  PROCEDURE Insert_Row(
                       X_Rowid         IN OUT NOCOPY VARCHAR2,
                       X_Access_Set_Id               NUMBER,
                       X_Name                        VARCHAR2,
                       X_Security_Segment_Code       VARCHAR2,
                       X_Enabled_Flag                VARCHAR2,
                       X_Chart_Of_Accounts_Id        NUMBER,
                       X_Period_Set_Name             VARCHAR2,
                       X_Accounted_Period_Type       VARCHAR2,
                       X_Automatically_Created_Flag  VARCHAR2,
		       X_Secured_Seg_Value_Set_Id    NUMBER,
		       X_Default_Ledger_Id           NUMBER,
                       X_User_Id                     NUMBER,
                       X_Login_Id                    NUMBER,
                       X_Date                        DATE,
                       X_Description                 VARCHAR2 DEFAULT NULL,
                       X_Context                     VARCHAR2 DEFAULT NULL,
                       X_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_Attribute15                 VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
      SELECT rowid
      FROM GL_ACCESS_SETS
      WHERE access_set_id = X_Access_Set_Id;
  BEGIN
    INSERT INTO GL_ACCESS_SETS (
        access_set_id,
        name,
        security_segment_code,
        enabled_flag,
        chart_of_accounts_id,
        period_set_name,
        accounted_period_type,
        automatically_created_flag,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
	secured_seg_value_set_id,
	default_ledger_id,
        description,
        context,
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
        X_Access_Set_Id,
        X_Name,
        X_Security_Segment_Code,
        X_Enabled_Flag,
        X_Chart_Of_Accounts_Id,
        X_Period_Set_Name,
        X_Accounted_Period_Type,
        X_Automatically_Created_Flag,
        X_Date,
        X_User_Id,
        X_Date,
        X_User_Id,
        X_Login_Id,
	X_Secured_Seg_Value_Set_Id,
	X_Default_Ledger_Id,
        X_Description,
        X_Context,
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

  PROCEDURE Update_Row(
                       X_Rowid                       VARCHAR2,
                       X_Access_Set_Id               NUMBER,
                       X_Name                        VARCHAR2,
                       X_Security_Segment_Code       VARCHAR2,
                       X_Enabled_Flag                VARCHAR2,
                       X_Chart_Of_Accounts_Id        NUMBER,
                       X_Period_Set_Name             VARCHAR2,
                       X_Accounted_Period_Type       VARCHAR2,
                       X_Automatically_Created_Flag  VARCHAR2,
		       X_Secured_Seg_Value_Set_Id    NUMBER,
		       X_Default_Ledger_Id           NUMBER,
                       X_User_Id                     NUMBER,
                       X_Login_Id                    NUMBER,
                       X_Date                        DATE,
                       X_Description                 VARCHAR2 DEFAULT NULL,
                       X_Context                     VARCHAR2 DEFAULT NULL,
                       X_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_Attribute15                 VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
    UPDATE GL_ACCESS_SETS
    SET
      access_set_id               = X_Access_Set_Id,
      name                        = X_Name,
      security_segment_code       = X_Security_Segment_Code,
      enabled_flag                = X_Enabled_Flag,
      chart_of_accounts_id        = X_Chart_Of_Accounts_Id,
      period_set_name             = X_Period_Set_Name,
      accounted_period_type       = X_Accounted_Period_Type,
      automatically_created_flag  = X_Automatically_Created_Flag,
      secured_seg_value_set_id	  = X_Secured_Seg_Value_Set_Id,
      default_ledger_id           = X_Default_Ledger_Id,
      last_update_date            = X_Date,
      last_updated_by             = X_User_Id,
      last_update_login           = X_Login_Id,
      description                 = X_Description,
      context                     = X_Context,
      attribute1                  = X_Attribute1,
      attribute2                  = X_Attribute2,
      attribute3                  = X_Attribute3,
      attribute4                  = X_Attribute4,
      attribute5                  = X_Attribute5,
      attribute6                  = X_Attribute6,
      attribute7                  = X_Attribute7,
      attribute8                  = X_Attribute8,
      attribute9                  = X_Attribute9,
      attribute10                 = X_Attribute10,
      attribute11                 = X_Attribute11,
      attribute12                 = X_Attribute12,
      attribute13                 = X_Attribute13,
      attribute14                 = X_Attribute14,
      attribute15                 = X_Attribute15
    WHERE
      rowid = X_Rowid;
  END Update_Row;

  PROCEDURE Lock_Row(
                       X_Rowid                       VARCHAR2,
                       X_Access_Set_Id               NUMBER,
                       X_Name                        VARCHAR2,
                       X_Security_Segment_Code       VARCHAR2,
                       X_Enabled_Flag                VARCHAR2,
                       X_Chart_Of_Accounts_Id        NUMBER,
                       X_Period_Set_Name             VARCHAR2,
                       X_Accounted_Period_Type       VARCHAR2,
                       X_Automatically_Created_Flag  VARCHAR2,
		       X_Secured_Seg_Value_Set_Id    NUMBER,
		       X_Default_Ledger_Id           NUMBER,
                       X_Last_Update_Date            DATE,
                       X_Last_Updated_By             NUMBER,
                       X_Creation_Date               DATE,
                       X_Created_By                  NUMBER,
                       X_Last_Update_Login           NUMBER,
                       X_Description                 VARCHAR2 DEFAULT NULL,
                       X_Context                     VARCHAR2 DEFAULT NULL,
                       X_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_Attribute15                 VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
      SELECT *
      FROM GL_ACCESS_SETS
      WHERE rowid = X_Rowid
      FOR UPDATE of Access_Set_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    CLOSE C;

    if (
          (   (Recinfo.access_set_id = X_Access_Set_Id)
           OR (    (Recinfo.access_set_id IS NULL)
               AND (X_Access_Set_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.security_segment_code = X_Security_Segment_Code)
           OR (    (Recinfo.security_segment_code IS NULL)
               AND (X_Security_Segment_Code IS NULL)))
      AND (   (Recinfo.enabled_flag = X_Enabled_Flag)
           OR (    (Recinfo.enabled_flag IS NULL)
               AND (X_Enabled_Flag IS NULL)))
      AND (   (Recinfo.chart_of_accounts_id = X_Chart_Of_Accounts_Id)
           OR (    (Recinfo.chart_of_accounts_id IS NULL)
               AND (X_Chart_Of_Accounts_Id IS NULL)))
      AND (   (Recinfo.period_set_name = X_Period_Set_Name)
           OR (    (Recinfo.period_set_name IS NULL)
               AND (X_Period_Set_Name IS NULL)))
      AND (   (Recinfo.accounted_period_type = X_Accounted_Period_Type)
           OR (    (Recinfo.accounted_period_type IS NULL)
               AND (X_Accounted_Period_Type IS NULL)))
      AND (   (Recinfo.automatically_created_flag = X_Automatically_created_Flag)
           OR (    (Recinfo.automatically_created_flag IS NULL)
               AND (X_Automatically_Created_Flag IS NULL)))
      AND (   (Recinfo.secured_seg_value_set_id = X_Secured_Seg_Value_Set_Id)
           OR (    (Recinfo.secured_seg_value_set_id IS NULL)
               AND (X_Secured_Seg_Value_Set_Id IS NULL)))
      AND (   (Recinfo.default_ledger_id = X_Default_Ledger_Id)
           OR (    (Recinfo.default_ledger_id IS NULL)
               AND (X_Default_Ledger_Id IS NULL)))
      AND (   (Recinfo.last_update_date = X_Last_Update_Date)
           OR (    (Recinfo.last_update_date IS NULL)
               AND (X_Last_Update_Date IS NULL)))
      AND (   (Recinfo.last_updated_by = X_Last_Updated_By)
           OR (    (Recinfo.last_updated_by IS NULL)
               AND (X_Last_Updated_By IS NULL)))
      AND (   (Recinfo.creation_date = X_Creation_Date)
           OR (    (Recinfo.creation_date IS NULL)
               AND (X_Creation_Date IS NULL)))
      AND (   (Recinfo.created_by = X_Created_By)
           OR (    (Recinfo.created_by IS NULL)
               AND (X_Created_By IS NULL)))
      AND (   (Recinfo.last_update_login = X_Last_Update_Login)
           OR (    (Recinfo.last_update_login IS NULL)
               AND (X_Last_Update_Login IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
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
    ) then
      return;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

  END Lock_Row;

END gl_access_sets_pkg;

/
