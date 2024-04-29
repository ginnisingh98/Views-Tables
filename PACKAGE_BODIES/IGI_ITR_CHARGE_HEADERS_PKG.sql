--------------------------------------------------------
--  DDL for Package Body IGI_ITR_CHARGE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_CHARGE_HEADERS_PKG" as
-- $Header: igiitrsb.pls 120.5.12000000.1 2007/09/12 10:32:39 mbremkum ship $
--

  l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level number	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level number	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE  Insert_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                        X_It_Header_Id          IN OUT NOCOPY NUMBER,
                        X_Set_Of_Books_Id       NUMBER,
                        X_Name                  VARCHAR2,
                        X_It_Period_Name        VARCHAR2,
                        X_Submit_Flag           VARCHAR2,
                        X_It_Originator_Id      VARCHAR2,
                        X_Gl_Date               DATE,
                        X_Currency_Code         VARCHAR2,
                        X_Encumbrance_Type_Id   NUMBER,
                        X_Employee_Id           NUMBER,
                        X_Entered_Dr            NUMBER,
                        X_Entered_Cr            NUMBER,
                        X_Submit_Date           DATE,
                        X_Charge_Center_Id      NUMBER,
                        X_Creation_Date         DATE,
                        X_Created_By            NUMBER,
                        X_Last_Update_Login     NUMBER,
                        X_Last_Update_Date      DATE,
                        X_Last_Updated_By       NUMBER
  ) IS

      CURSOR C  IS SELECT rowid
                   FROM igi_itr_charge_headers
                   WHERE  it_header_id = X_It_Header_Id;

      CURSOR C2 IS SELECT igi_itr_charge_headers_s.nextval FROM sys.dual;

    BEGIN

      IF X_It_Header_Id is null THEN
        OPEN C2;
        FETCH C2 INTO X_It_Header_Id;
        CLOSE C2;
      END IF;

      INSERT INTO igi_itr_charge_headers(
                   it_header_id
                  ,set_of_books_id
                  ,name
                  ,it_period_name
                  ,submit_flag
                  ,it_originator_id
                  ,gl_date
                  ,currency_code
                  ,encumbrance_type_id
                  ,employee_id
                  ,entered_dr
                  ,entered_cr
                  ,submit_date
                  ,charge_center_id
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,last_update_date
                  ,last_updated_by
                  )  VALUES  (
                   X_It_Header_Id
                  ,X_Set_Of_Books_Id
                  ,X_Name
                  ,X_It_Period_Name
                  ,X_Submit_Flag
                  ,X_It_Originator_Id
                  ,X_Gl_Date
                  ,X_Currency_Code
                  ,X_Encumbrance_Type_Id
                  ,X_Employee_Id
                  ,X_Entered_Dr
                  ,X_Entered_Cr
                  ,X_Submit_Date
                  ,X_Charge_Center_Id
                  ,X_Creation_date
                  ,X_Created_By
                  ,X_Last_Update_Login
                  ,X_Last_Update_Date
                  ,X_Last_Updated_By
                    );

                  OPEN C;
                  FETCH C INTO X_Rowid;
                  IF (C%NOTFOUND) THEN
                     CLOSE C;
                     RAISE NO_DATA_FOUND;
                  END IF;
                  CLOSE C;

   END Insert_Row;


  PROCEDURE    Lock_Row(X_Rowid                 VARCHAR2,
                        X_It_Header_Id          NUMBER,
                        X_Set_Of_Books_Id       NUMBER,
                        X_Name                  VARCHAR2,
                        X_It_Period_Name        VARCHAR2,
                        X_Submit_Flag           VARCHAR2,
                        X_It_Originator_Id      VARCHAR2,
                        X_Gl_Date               DATE,
                        X_Currency_Code         VARCHAR2,
                        X_Encumbrance_Type_Id   NUMBER,
                        X_Employee_Id           NUMBER,
                        X_Entered_Dr            NUMBER,
                        X_Entered_Cr            NUMBER,
                        X_Submit_Date           DATE,
                        X_Charge_Center_Id      NUMBER,
                        X_Creation_Date         DATE,
                        X_Created_By            NUMBER,
                        X_Last_Update_Login     NUMBER,
                        X_Last_Update_Date      DATE,
                        X_Last_Updated_By       NUMBER
  ) IS

       CURSOR C IS
         SELECT *
         FROM   igi_itr_charge_headers
         WHERE  rowid = X_Rowid
         FOR UPDATE of it_header_id NOWAIT;

       Recinfo  C%ROWTYPE;


    BEGIN

      OPEN C;
      FETCH C INTO Recinfo;
      IF (C%NOTFOUND) THEN
        CLOSE C;
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrsb.IGI_ITR_CHARGE_HEADERS_PKG.lock_row.msg1', FALSE);
	END IF;
        app_exception.raise_exception;
      END IF;
      CLOSE C;
      IF (
               (Recinfo.it_header_id           = X_It_Header_Id)
          AND  (Recinfo.set_of_books_id        = X_Set_Of_Books_Id)
          AND  (Recinfo.name                   = X_Name)
          AND  (Recinfo.it_period_name         = X_It_Period_Name)
          AND  (Recinfo.submit_flag            = X_Submit_Flag)
          AND  (Recinfo.it_originator_id       = X_It_Originator_Id)
          AND  (Recinfo.gl_date                = X_Gl_Date)
          AND  (Recinfo.currency_code          = X_Currency_Code)
          AND  (    (Recinfo.encumbrance_type_id    = X_Encumbrance_Type_Id)
                 OR (    (Recinfo.encumbrance_type_id IS NULL)
                      AND(X_Encumbrance_Type_Id IS NULL)   ))
          AND  (    (Recinfo.employee_id            = X_Employee_Id)
                 OR (     (Recinfo.employee_id IS NULL)
                      AND (X_Employee_Id IS NULL)     ))
          AND  (    (Recinfo.entered_dr     = X_Entered_Dr)
                 OR (     (Recinfo.entered_dr IS NULL)
                      AND (X_Entered_Dr IS NULL)    ))
          AND  (    (Recinfo.entered_cr     = X_Entered_Cr)
                 OR (     (Recinfo.entered_cr IS NULL)
                      AND (X_Entered_Cr IS NULL)    ))
          AND  (    (Recinfo.submit_date    = X_Submit_Date)
                 OR (     (Recinfo.submit_date IS NULL)
                      AND (X_Submit_Date IS NULL)     ))
          AND  (Recinfo.charge_center_id       = X_Charge_Center_Id)
          AND  (Recinfo.creation_date          = X_Creation_Date)
          AND  (Recinfo.created_by             = X_Created_By)
          AND  (    (Recinfo.last_update_login      = X_Last_Update_Login)
                 OR (     (Recinfo.last_update_login IS NULL)
                      AND (X_Last_Update_Login IS NULL)    ))
          AND  (    (Recinfo.last_update_date       = X_Last_Update_Date)
                 OR (     (Recinfo.last_update_date IS NULL)
                      AND (X_Last_Update_Date IS NULL)    ))
          AND  (    (Recinfo.last_updated_by        = X_Last_Updated_By)
                 OR (     (Recinfo.last_updated_by IS NULL)
                      AND (X_Last_Updated_By IS NULL)     ))
         )  THEN
              return;
            ELSE
              fnd_message.set_name('FND','FORM_RECORD_CHANGED');
        IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrsb.IGI_ITR_CHARGE_HEADERS_PKG.lock_row.msg2', FALSE);
	END IF;
              APP_EXCEPTION.raise_exception;
            END IF;

    END Lock_Row;


  PROCEDURE  Update_Row(X_Rowid                 VARCHAR2,
                        X_It_Header_Id          NUMBER,
                        X_Set_Of_Books_Id       NUMBER,
                        X_Name                  VARCHAR2,
                        X_It_Period_Name        VARCHAR2,
                        X_Submit_Flag           VARCHAR2,
                        X_It_Originator_Id      VARCHAR2,
                        X_Gl_Date               DATE,
                        X_Currency_Code         VARCHAR2,
                        X_Encumbrance_Type_Id   NUMBER,
                        X_Employee_Id           NUMBER,
                        X_Entered_Dr            NUMBER,
                        X_Entered_Cr            NUMBER,
                        X_Submit_Date           DATE,
                        X_Charge_Center_Id      NUMBER,
                        X_Creation_Date         DATE,
                        X_Created_By            NUMBER,
                        X_Last_Update_Login     NUMBER,
                        X_Last_Update_Date      DATE,
                        X_Last_Updated_By       NUMBER
  ) IS
    BEGIN

      UPDATE igi_itr_charge_headers
      SET
        it_header_id                    = X_It_Header_Id,
        set_of_books_id                 = X_Set_Of_Books_Id,
        name                            = X_Name,
        it_period_name                  = X_It_Period_Name,
        submit_flag                     = X_Submit_Flag,
        it_originator_id                = X_It_Originator_Id,
        gl_date                         = X_Gl_Date,
        currency_code                   = X_Currency_Code,
        encumbrance_type_id             = X_Encumbrance_Type_Id,
        employee_id                     = X_Employee_Id,
        entered_dr                      = X_Entered_Dr,
        entered_cr                      = X_Entered_Cr,
        submit_date                     = X_Submit_Date,
        charge_center_id                = X_Charge_Center_Id,
        creation_date                   = X_Creation_Date,
        created_by                      = X_Created_By,
        last_update_login               = X_Last_Update_Login,
        last_update_date                = X_Last_Update_Date,
        last_updated_by                 = X_Last_Updated_By
      WHERE rowid = X_Rowid;

      IF SQL%NOTFOUND THEN
        raise NO_DATA_FOUND;
      END IF;

  END Update_Row;









  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

  -- OPSF(I) ITR Bug 1764441  22-May-2001 S Brewer  Start(1)
    CURSOR c_get_it_header_id(p_rowid VARCHAR2)
    IS
      SELECT it_header_id
      FROM   igi_itr_charge_headers
      WHERE  rowid = p_rowid;

    l_it_header_id NUMBER;
  -- OPSF(I) ITR Bug 1764441  22-May-2001 S Brewer  End(1)

  BEGIN

  -- OPSF(I) ITR Bug 1764441  22-May-2001 S Brewer  Start(2)
  -- Delete any existing lines from the charge lines table before
  -- deleting the charge header
    OPEN c_get_it_header_id(X_Rowid);
    FETCH c_get_it_header_id INTO l_it_header_id;
    IF c_get_it_header_id%FOUND THEN
      igi_itr_charge_lines_pkg.delete_lines(l_it_header_id);
    END IF;
    CLOSE c_get_it_header_id;
  -- OPSF(I) ITR Bug 1764441  22-May-2001 S Brewer  End(2)


    DELETE FROM igi_itr_charge_headers
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;


  PROCEDURE check_unique( x_rowid           VARCHAR2,
                          x_name            VARCHAR2,
                          x_set_of_books_id NUMBER) IS

    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   igi_itr_charge_headers ch
      WHERE  ch.name = x_name
      AND    ch.set_of_books_id = x_set_of_books_id
      AND    (x_rowid IS NULL
              OR
              ch.rowid <> x_rowid);

     dummy VARCHAR2(100);

   BEGIN

     OPEN c_dup;
     FETCH c_dup INTO dummy;

     IF c_dup%FOUND THEN
       CLOSE c_dup;
       fnd_message.set_name('IGI','IGI_ITR_DPL_ITR');
           IF( l_error_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_error_level,'igi.plsql.igiitrqb.IGI_ITR_CHARGE_HEADERS_PKG.check_unique.msg3', FALSE);
	END IF;
       app_exception.raise_exception;
     END IF;

     CLOSE c_dup;

  END check_unique;


END IGI_ITR_CHARGE_HEADERS_PKG;

/
