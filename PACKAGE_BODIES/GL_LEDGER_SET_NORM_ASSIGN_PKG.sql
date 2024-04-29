--------------------------------------------------------
--  DDL for Package Body GL_LEDGER_SET_NORM_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_LEDGER_SET_NORM_ASSIGN_PKG" AS
/*  $Header: glistlab.pls 120.7 2005/05/05 01:23:24 kvora ship $  */


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_unique(X_Rowid                        VARCHAR2,
                         X_Ledger_Set_Id                NUMBER,
                         X_Ledger_Id                    NUMBER) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_ledger_set_norm_assign la
      WHERE  la.ledger_set_id = X_ledger_set_id
      AND    la.ledger_id = X_ledger_id
      AND    nvl(la.status_code, 'X') <> 'D'
      AND    ( X_rowid is NULL
               OR
               la.rowid <> X_rowid );
    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_LEDGER_ASSIGN' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_LEDGER_SET_NORM_ASSIGN_PKG.check_unique');
      RAISE;

  END check_unique;

-- **********************************************************************

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Ledger_Set_Id                  NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Object_Type_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Context                        VARCHAR2,
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
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Request_Id                     NUMBER
  ) IS

    L_Ledger_Id NUMBER;
    L_Has_Loops BOOLEAN := FALSE;

    CURSOR C IS SELECT rowid FROM gl_ledger_set_norm_assign
                 WHERE ledger_set_id = X_Ledger_Set_Id
                   AND ledger_id     = X_Ledger_Id;

  BEGIN

    -- Check for loops only if assigning a ledger set.
    IF (X_Object_Type_Code = 'S') THEN
       -- Check that this ledger assignment does not create a loop.
       L_Ledger_Id := X_Ledger_Set_Id;


       -- This code checks to see if you are creating a loop by
       -- defining a ledger set as a child of itself. Since a ledger
       -- set may be a child of multiple ledger sets it is not possible
       -- to check all scenarios. The flattening program will report
       -- errors in this case.
       LOOP
         BEGIN
         SELECT ledger_set_id
         INTO   L_Ledger_Id
         FROM   gl_ledger_set_norm_assign
         WHERE  ledger_id = L_Ledger_Id
         AND    nvl(status_code, 'X') <> 'D';
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             EXIT;
           WHEN TOO_MANY_ROWS THEN
             EXIT;
         END;

         IF (X_Ledger_Id = L_Ledger_Id) THEN
            L_Has_Loops := TRUE;
            EXIT;
         END IF;
       END LOOP;

       IF (L_Has_Loops) THEN
          FND_MESSAGE.Set_Name('SQLGL', 'GL_LSET_ASSIGNMENT_LOOP');
          APP_EXCEPTION.Raise_Exception;
       END IF;

    END IF; -- if object_type_code = 'S'

    INSERT INTO gl_ledger_set_norm_assign(
              ledger_set_id,
              ledger_id,
              status_code,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              start_date,
              end_date,
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
              attribute15,
              request_id
             ) VALUES (
              X_Ledger_Set_Id,
              X_Ledger_Id,
              'I',
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Start_Date,
              X_End_Date,
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
              X_Attribute15,
              X_Request_Id
             );

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
        'GL_LEDGER_SET_NORM_ASSIGN_PKG.insert_row');
      RAISE;

  END Insert_Row;

-- **********************************************************************

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Ledger_Set_Id                    NUMBER,
                     X_Ledger_Id                        NUMBER,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Context                          VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Request_Id                       NUMBER
  ) IS

    CURSOR C IS
        SELECT *
        FROM   gl_ledger_set_norm_assign
        WHERE  rowid = X_Rowid
        FOR UPDATE of Ledger_Id NOWAIT;
    Recinfo C%ROWTYPE;
    l_request_id     NUMBER(15);
    l_call_status    BOOLEAN;
    l_rphase         VARCHAR2(80);
    l_rstatus        VARCHAR2(80);
    l_dphase         VARCHAR2(30);
    l_dstatus        VARCHAR2(30);
    l_message        VARCHAR2(240);


  BEGIN
    -- Prevent a record from be modified if it is currently processed by
    -- the Flattening program
    IF(X_Request_Id IS NOT NULL) THEN
      l_request_id := X_Request_Id;
      l_call_status :=
        FND_CONCURRENT.GET_REQUEST_STATUS(request_id     => l_request_id,
                                          appl_shortname => 'SQLGL',
                                          program        => 'GLSTFL',
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
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;
    if (
               (   (Recinfo.ledger_set_id =  X_Ledger_Set_Id)
                OR (    (Recinfo.ledger_set_id IS NULL)
                    AND (X_Ledger_Set_Id IS NULL)))
           AND (   (Recinfo.ledger_id =  X_Ledger_Id)
                OR (    (Recinfo.ledger_id IS NULL)
                    AND (X_Ledger_Id IS NULL)))
           AND (   (Recinfo.start_date =  X_Start_Date)
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_Start_Date IS NULL)))
           AND (   (Recinfo.end_date =  X_End_Date)
                OR (    (Recinfo.end_date IS NULL)
                    AND (X_End_Date IS NULL)))
           AND (   (Recinfo.context =  X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.request_id =  X_Request_Id)
                OR (    (Recinfo.request_id IS NULL)
                    AND (X_Request_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

-- **********************************************************************

  /* This routine should be deleted if it is not required. The Ledger Sets
     form does not use this routine. */
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Ledger_Set_Id                  NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Context                        VARCHAR2,
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
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Request_Id                     NUMBER
  ) IS
  BEGIN

    -- If a row has a status_code of 'I', the Flattening Program has not yet
    -- been run. In this case, the status_code should remain 'I', else
    -- status_code should be 'U'.
    UPDATE gl_ledger_set_norm_assign
    SET
       ledger_set_id                   =     X_Ledger_Set_Id,
       ledger_id                       =     X_Ledger_Id,
       status_code                     =     decode(nvl(status_code, 'I'),
                                                    'I', status_code, 'U'),
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       start_date                      =     X_Start_Date,
       end_date                        =     X_End_Date,
       context                         =     X_Context,
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
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       request_id                      =     X_Request_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

-- **********************************************************************

  PROCEDURE Delete_Row(X_Rowid          VARCHAR2) IS

  BEGIN

    -- This is a norm table. We do not actually delete the row since the
    -- Flattening program will take care of this.
    -- Instead, set the status code to 'Delete'.
    UPDATE GL_LEDGER_SET_NORM_ASSIGN
    SET status_code = 'D'
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_LEDGER_SET_NORM_ASSIGN_PKG.delete_row');
      RAISE;

  END Delete_Row;

-- **********************************************************************

  FUNCTION Check_Assignments_Exist(X_Ledger_Set_Id      NUMBER)
    RETURN BOOLEAN IS

   num     NUMBER;
    CURSOR assignments IS
      SELECT 1
      FROM dual
      WHERE EXISTS (SELECT 1
                    FROM   GL_LEDGER_SET_NORM_ASSIGN
                    WHERE  ledger_set_id = X_Ledger_Set_Id
                    AND    (status_code <> 'D' OR status_code IS NULL));
  BEGIN
    OPEN assignments;
    FETCH assignments INTO num;
    IF assignments%NOTFOUND THEN
      CLOSE assignments;
      RETURN FALSE;
    END IF;

    CLOSE assignments;
    RETURN TRUE;
  END Check_Assignments_Exist;

-- **********************************************************************

  PROCEDURE validate_ledger_assignment(X_Ls_Coa_Id              NUMBER,
                                       X_Ls_Period_Set_Name     VARCHAR2,
                                       X_Ls_Period_Type         VARCHAR2,
                                       X_Ledger_Id              NUMBER) IS
    l_ledger_coa_id          NUMBER;
    l_ledger_period_set_name VARCHAR2(30);
    l_ledger_period_type     VARCHAR2(30);
  BEGIN
    -- get ledger info
    SELECT chart_of_accounts_id, period_set_name, accounted_period_type
    INTO   l_ledger_coa_id, l_ledger_period_set_name, l_ledger_period_type
    FROM   GL_LEDGERS
    WHERE  ledger_id = X_Ledger_Id;

    -- check ledger info against ledger set
    IF (   X_Ls_Coa_Id <> l_ledger_coa_id
        OR X_Ls_Period_Set_Name <> l_ledger_period_set_name
        OR X_Ls_Period_Type <> l_ledger_period_type) THEN
      fnd_message.set_name('SQLGL', 'GL_API_LS_DETL_LEDGER_ERROR');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_LEDGER_SET_NORM_ASSIGN_PKG.validate_ledger_assignment');
      RAISE;

  END validate_ledger_assignment;

-- **********************************************************************

END GL_LEDGER_SET_NORM_ASSIGN_PKG;

/
