--------------------------------------------------------
--  DDL for Package Body GL_DEFAS_RESP_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DEFAS_RESP_ASSIGN_PKG" AS
/* $Header: glistrab.pls 120.5 2005/09/02 10:35:14 adesu ship $ */

  PROCEDURE Insert_Row(
                       X_Rowid                 IN OUT NOCOPY VARCHAR2,
                       X_Definition_Access_Set_Id   IN NUMBER,
                       X_Security_Group_Id     IN NUMBER,
                       X_Responsibility_Id     IN NUMBER,
                       X_Application_Id        IN NUMBER,
                       X_Last_Update_Date      IN DATE,
                       X_Last_Updated_By       IN NUMBER,
                       X_Last_Update_Login     IN NUMBER,
                       X_Creation_Date         IN DATE,
                       X_Created_By            IN NUMBER,
                       X_Status_Code           IN VARCHAR2,
                       X_Request_Id            IN VARCHAR2,
                       X_Attribute1            IN VARCHAR2,
                       X_Attribute2            IN VARCHAR2,
                       X_Attribute3            IN VARCHAR2,
                       X_Attribute4            IN VARCHAR2,
                       X_Attribute5            IN VARCHAR2,
                       X_Attribute6            IN VARCHAR2,
                       X_Attribute7            IN VARCHAR2,
                       X_Attribute8            IN VARCHAR2,
                       X_Attribute9            IN VARCHAR2,
                       X_Attribute10           IN VARCHAR2,
                       X_Attribute11           IN VARCHAR2,
                       X_Attribute12           IN VARCHAR2,
                       X_Attribute13           IN VARCHAR2,
                       X_Attribute14           IN VARCHAR2,
                       X_Attribute15           IN VARCHAR2,
                       X_Context               IN VARCHAR2,                                           X_Default_Flag          IN VARCHAR2,
                       X_Default_View_Flag     IN VARCHAR2,
                       X_Default_Use_Flag      IN VARCHAR2,
                       X_Default_Modify_Flag   IN VARCHAR2
                      ) IS
       CURSOR C IS
       SELECT rowid
       FROM gl_defas_resp_assign
       WHERE definition_access_set_id = X_Definition_Access_Set_Id
       AND   application_id = X_Application_Id
       AND   responsibility_id = X_Responsibility_Id;

  BEGIN
       INSERT INTO gl_defas_resp_assign(
       security_group_id,
       application_id,
       responsibility_id,
       definition_access_set_id,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by,
       status_code,
       request_id,
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
       context,
       default_flag,
       default_view_access_flag,
       default_use_access_flag,
       default_modify_access_flag)
       VALUES(
       X_Security_Group_Id,
       X_Application_Id,
       X_Responsibility_Id,
       X_Definition_Access_Set_Id,
       X_Last_Update_Date,
       X_Last_Updated_By,
       X_Last_Update_Login,
       X_Creation_Date,
       X_Created_By,
       X_Status_Code,
       X_Request_Id,
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
       X_Context,
       X_Default_Flag,
       X_Default_View_Flag,
       X_Default_Use_Flag,
       X_Default_Modify_Flag);

       OPEN C;
       FETCH C INTO X_Rowid;
       if (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
       end if;
       CLOSE C;

  END Insert_Row;


  PROCEDURE Lock_Row(
                       X_Rowid                 IN OUT NOCOPY VARCHAR2,
                       X_Definition_Access_Set_Id   IN NUMBER,
                       X_Security_Group_Id     IN NUMBER,
                       X_Responsibility_Id     IN NUMBER,
                       X_Application_Id        IN NUMBER,
                       X_Last_Update_Date      IN DATE,
                       X_Last_Updated_By       IN NUMBER,
                       X_Last_Update_Login     IN NUMBER,
                       X_Creation_Date         IN DATE,
                       X_Created_By            IN NUMBER,
                       X_Status_Code           IN VARCHAR2,
                       X_Request_Id            IN VARCHAR2,
                       X_Attribute1            IN VARCHAR2,
                       X_Attribute2            IN VARCHAR2,
                       X_Attribute3            IN VARCHAR2,
                       X_Attribute4            IN VARCHAR2,
                       X_Attribute5            IN VARCHAR2,
                       X_Attribute6            IN VARCHAR2,
                       X_Attribute7            IN VARCHAR2,
                       X_Attribute8            IN VARCHAR2,
                       X_Attribute9            IN VARCHAR2,
                       X_Attribute10           IN VARCHAR2,
                       X_Attribute11           IN VARCHAR2,
                       X_Attribute12           IN VARCHAR2,
                       X_Attribute13           IN VARCHAR2,
                       X_Attribute14           IN VARCHAR2,
                       X_Attribute15           IN VARCHAR2,
                       X_Context               IN VARCHAR2,
                       X_Default_Flag          IN VARCHAR2,
                       X_Default_View_Flag     IN VARCHAR2,
                       X_Default_Use_Flag      IN VARCHAR2,
                       X_Default_Modify_Flag   IN VARCHAR2
                      ) IS
      CURSOR C IS
       SELECT *
       FROM gl_defas_resp_assign
       WHERE rowid = X_Rowid
       FOR UPDATE of Definition_Access_Set_Id NOWAIT;
      Recinfo C%ROWTYPE;
      l_request_id     NUMBER(15);
      l_call_status    BOOLEAN;
      l_rphase         VARCHAR2(80);
      l_rstatus        VARCHAR2(80);
      l_dphase         VARCHAR2(30);
      l_dstatus        VARCHAR2(30);
      l_message        VARCHAR2(240);

  BEGIN
     IF(X_Request_Id IS NOT NULL) THEN
        l_request_id := X_Request_Id;
        l_call_status :=
        FND_CONCURRENT.GET_REQUEST_STATUS(request_id     => l_request_id,
                                          appl_shortname => 'SQLGL',
                                          program        => 'GL',
                                          phase          => l_rphase,
                                          status         => l_rstatus,
                                          dev_phase      => l_dphase,
                                          dev_status     => l_dstatus,
                                          message        => l_message);

        IF (l_dphase = 'RUNNING') THEN
            FND_MESSAGE.Set_Name('GL', 'GL_LEDGER_RECORD_PROC_BY_FLAT');
            APP_EXCEPTION.Raise_Exception;
        END IF;
     END IF;

     OPEN C;
     FETCH C INTO Recinfo;
     if (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
     end if;
     CLOSE C;

     if (
           (   (Recinfo.definition_access_set_id = X_Definition_Access_Set_Id)
            OR (    (Recinfo.definition_access_set_id IS NULL)
                AND (X_Definition_Access_Set_Id IS NULL)))
       AND (   (Recinfo.security_group_id = X_Security_Group_Id)
            OR (    (Recinfo.security_group_id IS NULL)
                AND (X_Security_Group_Id IS NULL)))
       AND (   (Recinfo.application_id = X_Application_Id)
            OR (    (Recinfo.application_id IS NULL)
                AND (X_Application_Id IS NULL)))
       AND (   (Recinfo.responsibility_id = X_Responsibility_Id)
            OR (    (Recinfo.responsibility_Id IS NULL)
                AND (X_Responsibility_Id IS NULL)))
       AND (   (Recinfo.last_update_date = X_Last_Update_Date)
            OR (    (Recinfo.last_update_date IS NULL)
                AND (X_Last_Update_Date IS NULL)))
       AND (   (Recinfo.last_updated_by = X_Last_Updated_By)
            OR (    (Recinfo.last_updated_by IS NULL)
                AND (X_Last_Updated_By IS NULL)))
       AND (   (Recinfo.last_update_login = X_Last_Update_Login)
            OR (    (Recinfo.last_update_login IS NULL)
                AND (X_Last_Update_Login IS NULL)))
       AND (   (Recinfo.creation_date = X_Creation_Date)
            OR (    (Recinfo.creation_date IS NULL)
                AND (X_Creation_Date IS NULL)))
       AND (   (Recinfo.created_by = X_Created_By)
            OR (    (Recinfo.created_by IS NULL)
                AND (X_Created_By IS NULL)))
       AND (   (Recinfo.status_code = X_Status_Code)
            OR (    (Recinfo.status_code IS NULL)
                AND (X_Status_Code IS NULL)))
       AND (   (Recinfo.request_id = X_Request_Id)
            OR (    (Recinfo.request_id IS NULL)
                AND (X_Request_Id IS NULL)))
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
       AND (   (Recinfo.attribute14 =X_Attribute14)
            OR (    (Recinfo.attribute14 IS NULL)
                AND (X_Attribute14 IS NULL)))
       AND (   (Recinfo.attribute15 = X_Attribute15)
            OR (    (Recinfo.attribute15 IS NULL)
                AND (X_Attribute15 IS NULL)))
       AND (   (Recinfo.context = X_Context)
            OR (    (Recinfo.context IS NULL)
                AND (X_Context IS NULL)))
       AND (   (Recinfo.default_flag = X_Default_Flag)
            OR (    (Recinfo.default_flag IS NULL)
                AND (X_Default_Flag IS NULL)))
       AND (   (Recinfo.default_view_access_flag = X_Default_View_Flag)
            OR (    (Recinfo.default_view_access_flag IS NULL)
                AND (X_Default_View_Flag IS NULL)))
       AND (   (Recinfo.default_use_access_flag = X_Default_Use_Flag)
            OR (    (Recinfo.default_use_access_flag IS NULL)
                AND (X_Default_Use_Flag IS NULL)))
       AND (   (Recinfo.default_modify_access_flag = X_Default_Modify_Flag)
            OR (    (Recinfo.default_modify_access_flag IS NULL)
                AND (X_Default_Modify_Flag IS NULL)))
      ) then
       return;
    else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

  END Lock_Row;

  PROCEDURE Update_Row(
                       X_Rowid                 IN OUT NOCOPY VARCHAR2,
                       X_Last_Update_Date      IN DATE,
                       X_Last_Updated_By       IN NUMBER,
                       X_Last_Update_Login     IN NUMBER,
                       X_Status_Code           IN VARCHAR2,
                       X_Request_Id            IN VARCHAR2,
                       X_Attribute1            IN VARCHAR2,
                       X_Attribute2            IN VARCHAR2,
                       X_Attribute3            IN VARCHAR2,
                       X_Attribute4            IN VARCHAR2,
                       X_Attribute5            IN VARCHAR2,
                       X_Attribute6            IN VARCHAR2,
                       X_Attribute7            IN VARCHAR2,
                       X_Attribute8            IN VARCHAR2,
                       X_Attribute9            IN VARCHAR2,
                       X_Attribute10           IN VARCHAR2,
                       X_Attribute11           IN VARCHAR2,
                       X_Attribute12           IN VARCHAR2,
                       X_Attribute13           IN VARCHAR2,
                       X_Attribute14           IN VARCHAR2,
                       X_Attribute15           IN VARCHAR2,
                       X_Context               IN VARCHAR2,
                       X_Default_Flag          IN VARCHAR2,
                       X_Default_View_Flag     IN VARCHAR2,
                       X_Default_Use_Flag      IN VARCHAR2,
                       X_Default_Modify_Flag   IN VARCHAR2
                      ) IS
  BEGIN
  UPDATE gl_defas_resp_assign
  SET last_update_date = X_Last_Update_Date,
      last_updated_by = X_Last_Updated_By,
      last_update_login = X_Last_Update_Login,
      status_code = X_Status_Code,
      request_id = X_Request_Id,
      attribute1 = X_Attribute1,
      attribute2 = X_Attribute2,
      attribute3 = X_Attribute3,
      attribute4 = X_Attribute4,
      attribute5 = X_Attribute5,
      attribute6 = X_Attribute6,
      attribute7 = X_Attribute7,
      attribute8 = X_Attribute8,
      attribute9 = X_Attribute9,
      attribute10 = X_Attribute10,
      attribute11 = X_Attribute11,
      attribute12 = X_Attribute12,
      attribute13 = X_Attribute13,
      attribute14 = X_Attribute14,
      attribute15 = X_Attribute15,
      context = X_Context,
      default_flag = X_Default_Flag,
      default_view_access_flag = X_Default_View_Flag,
      default_use_access_flag = X_Default_Use_Flag,
      default_modify_access_flag = X_Default_Modify_Flag
  WHERE rowid = X_Rowid;

  if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
  end if;

  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid       VARCHAR2) IS
  BEGIN
     UPDATE GL_DEFAS_RESP_ASSIGN
     SET status_code = 'D'
     WHERE rowid = X_Rowid;

     if SQL%NOTFOUND then
     RAISE NO_DATA_FOUND;
     end if;

  END Delete_Row;


  PROCEDURE check_unique_set(X_Definition_Access_Set_Id NUMBER,
                             X_Application_Id         NUMBER,
                             X_Responsibility_Id      NUMBER,
                             X_Security_Group_Id      NUMBER)IS

  CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   GL_DEFAS_RESP_ASSIGN r
      WHERE  r.application_id = X_Application_Id
      AND    r.responsibility_Id = X_Responsibility_Id
      AND    r.security_group_id = X_Security_Group_Id
      AND    r.definition_access_set_id = X_Definition_Access_Set_Id
      AND    (r.status_code <>'D' or r.status_code is null);

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DEFAS_ASSIGN_RESP_DUP' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_DEFAS_RESP_ASSIGN_PKG.check_unique_set');
      RAISE;

  END check_unique_set;


END gl_defas_resp_assign_pkg;

/
