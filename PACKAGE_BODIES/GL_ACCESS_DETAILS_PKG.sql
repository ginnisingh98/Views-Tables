--------------------------------------------------------
--  DDL for Package Body GL_ACCESS_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ACCESS_DETAILS_PKG" AS
/* $Header: glistadb.pls 120.7 2005/05/05 01:21:59 kvora ship $ */

  FUNCTION get_record_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT GL_ACCESS_SET_NORM_ASSIGN_S.NEXTVAL
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
      fnd_message.set_token('SEQUENCE', 'GL_ACCESS_SET_NORM_ASSIGN_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_access_details_pkg.next_record_id');
      RAISE;
  END get_record_id;

  FUNCTION is_ledger_set(X_Ledger_Id NUMBER) RETURN BOOLEAN IS
    type_code   VARCHAR2(1);
  BEGIN
    SELECT object_type_code
    INTO type_code
    FROM GL_LEDGERS
    WHERE ledger_id = X_Ledger_Id;

    RETURN (type_code = 'S');
  END is_ledger_set;

  PROCEDURE Insert_Row(
                       X_Rowid              IN OUT NOCOPY VARCHAR2,
                       X_Access_Set_Id             NUMBER,
                       X_Ledger_Id                 NUMBER,
                       X_All_Segment_Value_Flag    VARCHAR2,
                       X_Segment_Value_Type_Code   VARCHAR2,
                       X_Access_Privilege_Code     VARCHAR2,
                       X_Record_Id                 NUMBER,
                       X_User_Id                   NUMBER,
                       X_Login_Id                  NUMBER,
                       X_Date                      DATE,
                       X_Segment_Value             VARCHAR2 DEFAULT NULL,
                       X_Start_Date                DATE     DEFAULT NULL,
                       X_End_Date                  DATE     DEFAULT NULL,
                       X_Status_Code               VARCHAR2 DEFAULT NULL,
                       X_Link_Id                   NUMBER   DEFAULT NULL,
                       X_Request_Id                NUMBER   DEFAULT NULL,
                       X_Context                   VARCHAR2 DEFAULT NULL,
                       X_Attribute1                VARCHAR2 DEFAULT NULL,
                       X_Attribute2                VARCHAR2 DEFAULT NULL,
                       X_Attribute3                VARCHAR2 DEFAULT NULL,
                       X_Attribute4                VARCHAR2 DEFAULT NULL,
                       X_Attribute5                VARCHAR2 DEFAULT NULL,
                       X_Attribute6                VARCHAR2 DEFAULT NULL,
                       X_Attribute7                VARCHAR2 DEFAULT NULL,
                       X_Attribute8                VARCHAR2 DEFAULT NULL,
                       X_Attribute9                VARCHAR2 DEFAULT NULL,
                       X_Attribute10               VARCHAR2 DEFAULT NULL,
                       X_Attribute11               VARCHAR2 DEFAULT NULL,
                       X_Attribute12               VARCHAR2 DEFAULT NULL,
                       X_Attribute13               VARCHAR2 DEFAULT NULL,
                       X_Attribute14               VARCHAR2 DEFAULT NULL,
                       X_Attribute15               VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
      SELECT rowid
      FROM GL_ACCESS_SET_NORM_ASSIGN
      WHERE access_set_id = X_Access_Set_Id
      AND   ledger_id = X_Ledger_Id
      AND   all_segment_value_flag = X_All_Segment_Value_Flag
      AND   segment_value_type_code = X_Segment_Value_Type_Code
      AND   access_privilege_code = X_Access_Privilege_Code
      AND   (segment_value = X_Segment_Value OR segment_value IS NULL)
      AND   (start_date = X_Start_Date OR start_date IS NULL)
      AND   (end_date = X_End_Date OR end_date IS NULL);
  BEGIN
    INSERT INTO GL_ACCESS_SET_NORM_ASSIGN (
      access_set_id,
      ledger_id,
      all_segment_value_flag,
      segment_value_type_code,
      access_privilege_code,
      record_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      segment_value,
      start_date,
      end_date,
      status_code,
      link_id,
      request_id,
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
      X_Ledger_Id,
      X_All_Segment_Value_Flag,
      X_Segment_Value_Type_Code,
      X_Access_Privilege_Code,
      X_Record_Id,
      X_Date,
      X_User_Id,
      X_Date,
      X_User_Id,
      X_Login_Id,
      X_Segment_Value,
      X_Start_Date,
      X_End_Date,
      X_Status_Code,
      X_Link_Id,
      X_Request_Id,
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

  PROCEDURE Lock_Row(
                       X_Rowid                     VARCHAR2,
                       X_Access_Set_Id             NUMBER,
                       X_Ledger_Id                 NUMBER,
                       X_All_Segment_Value_Flag    VARCHAR2,
                       X_Segment_Value_Type_Code   VARCHAR2,
                       X_Access_Privilege_Code     VARCHAR2,
                       X_Record_Id                 NUMBER,
                       X_Last_Update_Date          DATE,
                       X_Last_Updated_By           NUMBER,
                       X_Creation_Date             DATE,
                       X_Created_By                NUMBER,
                       X_Last_Update_Login         NUMBER,
                       X_Segment_Value             VARCHAR2 DEFAULT NULL,
                       X_Start_Date                DATE     DEFAULT NULL,
                       X_End_Date                  DATE     DEFAULT NULL,
                       X_Status_Code               VARCHAR2 DEFAULT NULL,
                       X_Link_Id                   NUMBER   DEFAULT NULL,
                       X_Request_Id                NUMBER   DEFAULT NULL,
                       X_Context                   VARCHAR2 DEFAULT NULL,
                       X_Attribute1                VARCHAR2 DEFAULT NULL,
                       X_Attribute2                VARCHAR2 DEFAULT NULL,
                       X_Attribute3                VARCHAR2 DEFAULT NULL,
                       X_Attribute4                VARCHAR2 DEFAULT NULL,
                       X_Attribute5                VARCHAR2 DEFAULT NULL,
                       X_Attribute6                VARCHAR2 DEFAULT NULL,
                       X_Attribute7                VARCHAR2 DEFAULT NULL,
                       X_Attribute8                VARCHAR2 DEFAULT NULL,
                       X_Attribute9                VARCHAR2 DEFAULT NULL,
                       X_Attribute10               VARCHAR2 DEFAULT NULL,
                       X_Attribute11               VARCHAR2 DEFAULT NULL,
                       X_Attribute12               VARCHAR2 DEFAULT NULL,
                       X_Attribute13               VARCHAR2 DEFAULT NULL,
                       X_Attribute14               VARCHAR2 DEFAULT NULL,
                       X_Attribute15               VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
      SELECT *
      FROM GL_ACCESS_SET_NORM_ASSIGN
      WHERE rowid = X_Rowid
      FOR UPDATE of Access_Set_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
    CLOSE C;

    if (
          (   (Recinfo.access_set_id = X_Access_Set_Id)
           OR (    (Recinfo.access_set_id IS NULL)
               AND (X_Access_Set_Id IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.all_segment_value_flag = X_All_Segment_Value_Flag)
           OR (    (Recinfo.all_segment_value_flag IS NULL)
               AND (X_All_Segment_Value_Flag IS NULL)))
      AND (   (Recinfo.segment_value_type_code = X_Segment_Value_Type_Code)
           OR (    (Recinfo.segment_value_type_code IS NULL)
               AND (X_Segment_Value_Type_Code IS NULL)))
      AND (   (Recinfo.access_privilege_code = X_Access_Privilege_Code)
           OR (    (Recinfo.access_privilege_code IS NULL)
               AND (X_Access_Privilege_Code IS NULL)))
      AND (   (Recinfo.record_id = X_Record_Id)
           OR (    (Recinfo.record_id IS NULL)
               AND (X_Record_Id IS NULL)))
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
      AND (   (Recinfo.segment_value = X_Segment_Value)
           OR (    (Recinfo.segment_value IS NULL)
               AND (X_Segment_Value IS NULL)))
      AND (   (Recinfo.start_date = X_Start_Date)
           OR (    (Recinfo.start_date IS NULL)
               AND (X_Start_Date IS NULL)))
      AND (   (Recinfo.end_date = X_End_Date)
           OR (    (Recinfo.end_date IS NULL)
               AND (X_End_Date IS NULL)))
      AND (   (Recinfo.status_code = X_Status_Code)
           OR (    (Recinfo.status_code IS NULL)
               AND (X_Status_Code IS NULL)))
      AND (   (Recinfo.link_id = X_Link_Id)
           OR (    (Recinfo.link_id IS NULL)
               AND (X_Link_Id IS NULL)))
      AND (   (Recinfo.request_id = X_Request_Id)
           OR (    (Recinfo.request_id IS NULL)
               AND (X_Request_Id IS NULL)))
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
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

  PROCEDURE Delete_Row(X_Rowid  VARCHAR2) IS
  BEGIN
    UPDATE GL_ACCESS_SET_NORM_ASSIGN
    SET status_code = 'D'
    WHERE rowid = X_Rowid;

    if SQL%NOTFOUND then
      RAISE NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE check_duplicate(
                            X_Access_Set_Id             NUMBER,
                            X_Ledger_Id                 NUMBER,
                            X_All_Segment_Value_Flag    VARCHAR2,
                            X_Segment_Value_Type_Code   VARCHAR2,
                            X_Access_Privilege_Code     VARCHAR2,
                            X_Segment_Value		VARCHAR2) IS
    CURSOR get_duplicate IS
      SELECT 'duplicate'
      FROM gl_access_set_norm_assign
      WHERE access_set_id = X_Access_Set_Id
      AND   ledger_id = X_Ledger_Id
      AND   all_segment_value_flag = X_All_Segment_Value_Flag
      AND   segment_value_type_code = X_Segment_Value_Type_Code
      AND   access_privilege_code = X_Access_Privilege_Code
      AND   nvl(segment_value,'X') = nvl(X_Segment_Value, 'X')
      AND   (status_code <> 'D' or status_code is NULL);

    dummy   VARCHAR2(100);

  BEGIN
    OPEN  get_duplicate;
    FETCH get_duplicate INTO dummy;

    IF get_duplicate%FOUND THEN
      CLOSE get_duplicate;
      fnd_message.set_name('SQLGL', 'GL_ACCESS_SET_DUPLICATE_DETAIL');
      app_exception.raise_exception;
    END IF;

    CLOSE get_duplicate;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_ACCESS_DETAILS_PKG.check_duplicate');
      RAISE;
  END check_duplicate;

  PROCEDURE validate_access_detail(X_Das_Coa_Id              NUMBER,
                                   X_Das_Period_Set_Name     VARCHAR2,
                                   X_Das_Period_Type         VARCHAR2,
                                   X_Das_Security_Code       VARCHAR2,
                                   X_Das_Value_Set_Id        NUMBER,
                                   X_Ledger_Id               NUMBER,
                                   X_All_Segment_Value_Flag  VARCHAR2,
                                   X_Segment_Value           VARCHAR2,
                                   X_Segment_Value_Type_Code VARCHAR2) IS
    l_ledger_coa_id          NUMBER;
    l_ledger_period_set_name VARCHAR2(30);
    l_ledger_period_type     VARCHAR2(30);

    l_summary_flag           VARCHAR2(1);
  BEGIN
    -- get ledger info
    SELECT chart_of_accounts_id, period_set_name, accounted_period_type
    INTO   l_ledger_coa_id, l_ledger_period_set_name, l_ledger_period_type
    FROM   GL_LEDGERS
    WHERE  ledger_id = X_Ledger_Id;

    -- check ledger info against access set
    IF (   X_das_coa_id <> l_ledger_coa_id
        OR X_das_period_set_name <> l_ledger_period_set_name
        OR X_das_period_type <> l_ledger_period_type) THEN
      fnd_message.set_name('SQLGL', 'GL_API_DAS_DETL_LEDGER_ERROR');
      app_exception.raise_exception;
    END IF;

    -- check access set type vs. all_segment_value_flag
    IF (X_das_security_code = 'F' AND X_All_Segment_Value_Flag <> 'Y') THEN
      fnd_message.set_name('SQLGL', 'GL_API_DEPENDENT_VALUE');
      fnd_message.set_token('DEPATTR', 'AllSegmentValueFlag');
      fnd_message.set_token('VALUE', X_das_security_code);
      fnd_message.set_token('ATTRIBUTE', 'SecuritySegmentCode');
      app_exception.raise_exception;
    END IF;

    -- check all_segment_value_flag, segment_value and segment_value_type_code
    IF (X_All_Segment_Value_Flag = 'Y') THEN
      IF (X_Segment_Value IS NOT NULL) THEN
        fnd_message.set_name('SQLGL', 'GL_API_DEP_NULL_VALUE');
        fnd_message.set_token('DEPATTR', 'SegmentValue');
        fnd_message.set_token('VALUE', X_All_Segment_Value_Flag);
        fnd_message.set_token('ATTRIBUTE', 'AllSegmentValueFlag');
        app_exception.raise_exception;
      ELSIF (X_Segment_Value_Type_Code <> 'S') THEN
        fnd_message.set_name('SQLGL', 'GL_API_DEPENDENT_VALUE');
        fnd_message.set_token('DEPATTR', 'SegmentValueTypeCode');
        fnd_message.set_token('VALUE', X_All_Segment_Value_Flag);
        fnd_message.set_token('ATTRIBUTE', 'AllSegmentValueFlag');
        app_exception.raise_exception;
      END IF;

    ELSE
      IF (X_Segment_Value IS NULL) THEN
        fnd_message.set_name('SQLGL', 'GL_API_DEPENDENT_VALUE');
        fnd_message.set_token('DEPATTR', 'SegmentValue');
        fnd_message.set_token('VALUE', X_All_Segment_Value_Flag);
        fnd_message.set_token('ATTRIBUTE', 'AllSegmentValueFlag');
        app_exception.raise_exception;
      ELSE
        -- attempt to get the summary flag of the segment value
        BEGIN
          l_summary_flag := GL_FLEXFIELDS_PKG.get_summary_flag(
                                                X_das_value_set_id,
                                                X_Segment_Value);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
            fnd_message.set_token('VALUE', X_Segment_Value);
            fnd_message.set_token('ATTRIBUTE', 'SegmentValue');
            app_exception.raise_exception;
          WHEN OTHERS THEN
            RAISE;
        END;

        IF ((l_summary_flag = 'Y' AND X_Segment_Value_Type_Code <> 'C') OR
            (l_summary_flag = 'N' AND X_Segment_Value_Type_Code <> 'S')) THEN
          fnd_message.set_name('SQLGL', 'GL_API_DEPENDENT_VALUE');
          fnd_message.set_token('DEPATTR', 'SegmentValueTypeCode');
          fnd_message.set_token('VALUE', X_Segment_Value);
          fnd_message.set_token('ATTRIBUTE', 'SegmentValue');
          app_exception.raise_exception;
        END IF;

      END IF;  -- end X_Segment_Value
    END IF;  -- end X_All_Segment_Value_Flag

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_ACCESS_DETAILS_PKG.validate_access_detail');
      RAISE;
  END validate_access_detail;

END gl_access_details_pkg;

/
