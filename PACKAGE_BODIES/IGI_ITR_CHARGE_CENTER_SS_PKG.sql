--------------------------------------------------------
--  DDL for Package Body IGI_ITR_CHARGE_CENTER_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_CHARGE_CENTER_SS_PKG" as
-- $Header: igiitrlb.pls 120.5.12000000.1 2007/09/12 10:31:48 mbremkum ship $
--

  l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level number	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level number	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_Name                           VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
         	       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Description                     VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_itr_charge_center
                 WHERE charge_center_id = X_Charge_Center_Id;

   BEGIN
       INSERT INTO IGI_itr_charge_center(
                       Charge_Center_Id,
                       Name,
                       Set_Of_Books_Id,
		       Start_Date_Active,
		       End_Date_Active,
                       Description,
                       Creation_Date,
                       Created_By,
                       Last_Update_Login,
                       Last_Update_Date,
                       Last_Updated_By
					   )
		VALUES (
		       X_Charge_Center_Id,
		       X_Name,
		       X_Set_Of_Books_Id,
		       X_Start_Date_Active,
                       X_End_Date_Active,
                       X_Description,
                       X_Creation_Date,
                       X_Created_By,
                       X_Last_Update_Login,
                       X_Last_Update_Date,
                       X_Last_Updated_By             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(  X_Rowid                          VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_Name                           VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
         	       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Description                    VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   IGI_itr_charge_center
        WHERE  rowid = X_Rowid
        FOR UPDATE of Charge_Center_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrlb.IGI_ITR_CHARGE_CENTER_SS.lock_row.msg1', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
	           (Recinfo.charge_center_id 	    =  X_Charge_Center_Id)
                   AND (Recinfo.name                =  X_Name)
                   AND (Recinfo.set_Of_books_id     =  X_Set_Of_Books_Id)
		   AND (Recinfo.start_date_active   =  X_Start_Date_Active)
		   AND (  (Recinfo.end_date_active     =  X_End_Date_Active)
                       OR (    (Recinfo.end_date_active IS NULL)
                           AND (X_End_Date_Active IS NULL)))
		   AND (  (Recinfo.description         =  X_Description)
                        OR (    (Recinfo.description IS NULL)
                            AND (X_Description IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrlb.IGI_ITR_CHARGE_CENTER_SS.lock_row.msg2', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_Name                           VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
		       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Description                    VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS

  BEGIN
    UPDATE IGI_itr_charge_center
    SET

	          charge_center_id   = 		X_Charge_Center_Id,
	          name               =  	X_Name,
	          set_of_books_id    =          X_Set_Of_Books_Id,
	          start_date_active  =          X_Start_Date_Active,
	          end_date_Active    =           X_End_Date_Active,
	          description        =          X_Description ,
	          last_update_login  =          X_Last_Update_Login ,
	          last_update_date   =          X_Last_Update_Date ,
                  last_updated_by    =          X_Last_Updated_By

    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_itr_charge_center
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;



  PROCEDURE check_unique_cc( x_rowid           VARCHAR2,
                             x_name            VARCHAR2,
                             x_set_of_books_id NUMBER) IS

    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   igi_itr_charge_center cc
      WHERE  cc.name = x_name
      AND    cc.set_of_books_id = x_set_of_books_id
      AND    (x_rowid IS NULL
              OR
              cc.rowid <> x_rowid);

     dummy VARCHAR2(100);

   BEGIN

     OPEN c_dup;
     FETCH c_dup INTO dummy;

     IF c_dup%FOUND THEN
       CLOSE c_dup;
       fnd_message.set_name('IGI','IGI_ITR_DPL_CC_NAME');

	IF( l_error_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_error_level,'igi.plsql.igiitrlb.IGI_ITR_CHARGE_CENTER_SS_PKG.check_unique_cc.msg3', FALSE);
	END IF;

       app_exception.raise_exception;
     END IF;

     CLOSE c_dup;

  END check_unique_cc;

END IGI_ITR_CHARGE_CENTER_SS_PKG;

/
