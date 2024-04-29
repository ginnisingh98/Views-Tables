--------------------------------------------------------
--  DDL for Package Body GL_LEDGER_NORM_SEG_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_LEDGER_NORM_SEG_VALS_PKG" AS
/*  $Header: glistsvb.pls 120.5 2003/04/24 01:35:34 djogg noship $  */

  --
  -- PUBLIC FUNCTIONS
  --

  FUNCTION Get_Record_Id RETURN NUMBER
  IS
    CURSOR get_id IS
      SELECT GL_LEDGER_NORM_SEG_VALS_REC_S.NEXTVAL
      FROM dual;

    v_record_id         NUMBER(15);

  BEGIN
    OPEN get_id;
    FETCH get_id INTO v_record_id;

    IF get_id%FOUND THEN
      CLOSE get_id;
    ELSE
      CLOSE get_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_LEDGER_NORM_SEG_VALS_REC_S');
      app_exception.raise_exception;
    END IF;

    RETURN (v_record_id);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'GL_LEDGER_NORM_SEG_VALS_PKG.Get_Record_Id');
      RAISE;

  END Get_Record_Id;

  -- **********************************************************************

  PROCEDURE Check_Unique(X_Rowid                          VARCHAR2,
                         X_Ledger_Id                      NUMBER,
                         X_Segment_Value                  VARCHAR2,
                         X_Segment_Type_Code              VARCHAR2,
                         X_Start_Date                     DATE,
                         X_End_Date                       DATE
  ) IS
    dummy  VARCHAR2(1);

    CURSOR check_unique IS
        SELECT 'X'
        FROM   GL_LEDGER_NORM_SEG_VALS
        WHERE  ledger_id            = X_Ledger_Id
          AND  segment_value        = X_Segment_Value
          AND  segment_type_code    = X_Segment_Type_Code
          AND  (start_date <= X_End_Date
                OR start_date IS NULL
                OR X_End_Date IS NULL)
          AND  (end_date >= X_Start_Date
                OR end_date IS NULL
                OR X_Start_Date IS NULL)
          AND  NVL(status_code,'X') <> 'D'
          AND  ((X_Rowid IS NULL) or (rowid <> X_Rowid)) ;

BEGIN

    OPEN check_unique;
    FETCH check_unique INTO dummy;
    IF check_unique%FOUND THEN
      CLOSE check_unique;
      fnd_message.set_name( 'SQLGL', 'GL_LEDGER_UNIQUE_SEGVAL_ASSIGN' );
      app_exception.raise_exception;
    END IF;

    CLOSE check_unique;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_LEDGER_NORM_SEG_VALS_PKG.check_unique');
      RAISE;
  END Check_Unique;

  -- **********************************************************************

  FUNCTION Check_Exist(X_Ledger_Id                      NUMBER,
                       X_Segment_Type_Code              VARCHAR2) RETURN BOOLEAN
  IS
    dummy  VARCHAR2(1);

    CURSOR check_exist IS
        SELECT 'X'
        FROM   GL_LEDGER_NORM_SEG_VALS
        WHERE  ledger_id            = X_Ledger_Id
          AND  segment_type_code    = X_Segment_Type_Code
          AND  NVL(status_code,'X') <> 'D';

  BEGIN
    OPEN check_exist;
    FETCH check_exist INTO dummy;
    IF check_exist%NOTFOUND THEN
      CLOSE check_exist;
      RETURN FALSE;
    ELSE
      CLOSE check_exist;
      RETURN TRUE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_LEDGER_NORM_SEG_VALS_PKG.Check_Exist');
      RAISE;

  END Check_Exist;

  -- **********************************************************************

  FUNCTION Check_Conc_With_Flat(X_Ledger_Id           NUMBER,
                                X_Segment_Type_Code   VARCHAR2) RETURN BOOLEAN
  IS
    CURSOR Seg_Val_Request_Id IS
        SELECT DISTINCT request_id
        FROM   GL_LEDGER_NORM_SEG_VALS
        WHERE  ledger_id            = X_Ledger_Id
          AND  segment_type_code    = X_Segment_Type_Code
          AND  request_id IS NOT NULL
          AND  NVL(status_code,'X') <> 'D';

    v_request_id Seg_Val_Request_Id%ROWTYPE;

    call_status    BOOLEAN;
    rphase         VARCHAR2(80);
    rstatus        VARCHAR2(80);
    dphase         VARCHAR2(30);
    dstatus        VARCHAR2(30);
    message        VARCHAR2(240);
    request_id     NUMBER(15);

  BEGIN
    FOR v_request_id IN Seg_Val_Request_Id LOOP
      --
      -- Prevent a record from be modified if it is currenlty processed by
      -- the Flattening program
      --
      request_id := v_request_id.request_id;

      call_status :=
        FND_CONCURRENT.GET_REQUEST_STATUS(request_id     => request_id,
                                          appl_shortname => 'SQLGL',
                                          program        => 'GLSTFL',
                                          phase          => rphase,
                                          status         => rstatus,
                                          dev_phase      => dphase,
                                          dev_status     => dstatus,
                                          message        => message);

      IF (dphase = 'RUNNING') THEN
        return (FALSE);
      END IF;

    END LOOP;

    return (TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_LEDGER_NORM_SEG_VALS_PKG.Check_Conc_With_Flat');
      RAISE;

  END Check_Conc_With_Flat;

  -- **********************************************************************

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Segment_Type_Code              VARCHAR2,
                       X_Segment_Value                  VARCHAR2,
                       X_Segment_Value_Type_Code        VARCHAR2,
                       X_Record_Id                      NUMBER,
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
    CURSOR C
      IS SELECT rowid
         FROM GL_LEDGER_NORM_SEG_VALS
         WHERE ledger_id = X_Ledger_Id
           AND segment_type_code = X_Segment_Type_Code
           AND segment_value = X_Segment_Value
           AND (start_date = X_Start_Date OR
                  (start_date IS NULL AND X_Start_Date IS NULL))
           AND (end_date = X_End_Date OR
                  (end_date IS NULL AND X_End_Date IS NULL))
           AND  NVL(status_code,'X') <> 'D';

  BEGIN
    -- Verify that this combination is unique and does not overlap with other dates.
    GL_LEDGER_NORM_SEG_VALS_PKG.Check_Unique(X_Rowid,
                                             X_Ledger_Id,
                                             X_Segment_Value,
                                             X_Segment_Type_Code,
                                             X_Start_Date,
                                             X_End_Date);

    INSERT INTO GL_LEDGER_NORM_SEG_VALS(
              ledger_id,
              segment_type_code,
              segment_value,
              segment_value_type_code,
              status_code,
              record_id,
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
              X_Ledger_Id,
              X_Segment_Type_Code,
              X_Segment_Value,
              X_Segment_Value_Type_Code,
              'I',
              X_Record_Id,
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
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
  END Insert_Row;

  -- **********************************************************************

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Ledger_Id                        NUMBER,
                     X_Segment_Type_Code                VARCHAR2,
                     X_Segment_Value                    VARCHAR2,
                     X_Segment_Value_Type_Code          VARCHAR2,
                     X_Record_Id                        NUMBER,
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
        FROM   GL_LEDGER_NORM_SEG_VALS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Ledger_Id NOWAIT;
    Recinfo C%ROWTYPE;

    call_status    BOOLEAN;
    rphase         VARCHAR2(80);
    rstatus        VARCHAR2(80);
    dphase         VARCHAR2(30);
    dstatus        VARCHAR2(30);
    message        VARCHAR2(240);
    v_request_id   NUMBER(15);

  BEGIN
    --
    -- Prevent a record from being modified if it is currently being
    -- processed by the Flattening program
    --
    IF(X_Request_Id IS NOT NULL) THEN
      v_request_id := X_Request_Id;
      call_status :=
        FND_CONCURRENT.GET_REQUEST_STATUS(request_id     => v_request_id,
                                          appl_shortname => 'SQLGL',
                                          program        => 'GLSTFL',
                                          phase          => rphase,
                                          status         => rstatus,
                                          dev_phase      => dphase,
                                          dev_status     => dstatus,
                                          message        => message);

      IF (dphase = 'RUNNING') THEN
        FND_MESSAGE.Set_Name('SQLGL', 'GL_LEDGER_RECORD_PROC_BY_FLAT');
        APP_EXCEPTION.Raise_Exception;
      END IF;
    END IF;

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    IF (
        (   (Recinfo.ledger_id = X_Ledger_Id)
             OR (    (Recinfo.ledger_id IS NULL)
                 AND (X_Ledger_Id IS NULL)))
        AND (   (Recinfo.segment_type_code = X_Segment_Type_Code)
             OR (    (Recinfo.segment_type_code IS NULL)
                 AND (X_Segment_Type_Code IS NULL)))
        AND (   (Recinfo.segment_value = X_Segment_Value)
             OR (    (Recinfo.segment_value IS NULL)
                 AND (X_Segment_Value IS NULL)))
        AND (   (Recinfo.segment_value_type_code = X_Segment_Value_Type_Code)
             OR (    (Recinfo.segment_value_type_code IS NULL)
                 AND (X_Segment_Value_Type_Code IS NULL)))
        AND (   (Recinfo.record_id = X_Record_Id)
             OR (    (Recinfo.record_id IS NULL)
                 AND (X_Record_Id IS NULL)))
        AND (   (Recinfo.start_date = X_Start_Date)
             OR (    (Recinfo.start_date IS NULL)
                 AND (X_Start_Date IS NULL)))
         AND (   (Recinfo.end_date = X_End_Date)
             OR (    (Recinfo.end_date IS NULL)
                 AND (X_End_Date IS NULL)))
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
         AND (   (Recinfo.request_id = X_Request_Id)
             OR (    (Recinfo.request_id IS NULL)
                 AND (X_Request_Id IS NULL)))
      ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
  END Lock_Row;

  -- **********************************************************************

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Segment_Type_Code              VARCHAR2,
                       X_Segment_Value                  VARCHAR2,
                       X_Segment_Value_Type_Code        VARCHAR2,
                       X_Record_Id                      NUMBER,
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
  )
  IS
    v_status_code      VARCHAR2(1);

  BEGIN
    -- Verify that this combination is unique and does not overlap with other dates.
    GL_LEDGER_NORM_SEG_VALS_PKG.Check_Unique(X_Rowid,
                                             X_Ledger_Id,
                                             X_Segment_Value,
                                             X_Segment_Type_Code,
                                             X_Start_Date,
                                             X_End_Date);

    -- If a row has a status_code of 'I', the Flattening Program has not been run yet.
    -- In this case, the status_code should remain 'I'.
    -- Otherwise, the status_code should be 'U'.
    SELECT NVL(status_code,'X')
    INTO v_status_code
    FROM GL_LEDGER_NORM_SEG_VALS
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF (v_status_code <> 'I') THEN
      v_status_code := 'U';
    END IF;

    UPDATE GL_LEDGER_NORM_SEG_VALS
    SET
       ledger_id                       =     X_Ledger_Id,
       segment_type_code               =     X_Segment_Type_Code,
       segment_value                   =     X_Segment_Value,
       segment_value_type_code         =     X_Segment_Value_Type_Code,
       status_code                     =     v_status_code,
       record_id                       =     X_Record_Id,
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

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Update_Row;

  -- **********************************************************************

  PROCEDURE Delete_Row(X_Rowid              VARCHAR2) IS
  BEGIN
    -- This is a norm table. We do not delete row since the Flattening program will
    -- take care of this.
    -- Set the status code to 'Delete'.
    UPDATE GL_LEDGER_NORM_SEG_VALS
    SET status_code = 'D'
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END Delete_Row;

  -- **********************************************************************

  PROCEDURE Delete_All_Rows(X_Ledger_Id NUMBER,
                            X_Segment_Type_Code VARCHAR2) IS
  BEGIN
    -- This is a norm table. We do not delete row since the Flattening program will
    -- take care of this.
    -- Set the status code to 'Delete'.
    UPDATE GL_LEDGER_NORM_SEG_VALS
    SET status_code = 'D'
    WHERE ledger_id = X_Ledger_Id
      and segment_type_code = X_Segment_Type_Code;

  END Delete_All_Rows;

END GL_LEDGER_NORM_SEG_VALS_PKG;

/
