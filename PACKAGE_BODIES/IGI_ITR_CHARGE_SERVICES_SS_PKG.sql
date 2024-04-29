--------------------------------------------------------
--  DDL for Package Body IGI_ITR_CHARGE_SERVICES_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_CHARGE_SERVICES_SS_PKG" as
-- $Header: igiitrkb.pls 120.5.12000000.1 2007/09/12 10:31:40 mbremkum ship $
--

  l_debug_level number  :=      FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number  :=      FND_LOG.LEVEL_STATEMENT;
  l_proc_level number   :=      FND_LOG.LEVEL_PROCEDURE;
  l_event_level number  :=      FND_LOG.LEVEL_EVENT;
  l_excep_level number  :=      FND_LOG.LEVEL_EXCEPTION;
  l_error_level number  :=      FND_LOG.LEVEL_ERROR;
  l_unexp_level number  :=      FND_LOG.LEVEL_UNEXPECTED;



  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_Service_Id                     NUMBER,
                       X_Charge_Service_Id	        NUMBER,
		       X_Creation_Ccid                  NUMBER,
         	       X_Receiving_Ccid                 NUMBER,
		       X_Start_Date                     DATE,
		       X_End_Date                       DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_itr_charge_service
                 WHERE charge_service_id = X_Charge_Service_Id;

   BEGIN
       INSERT INTO IGI_itr_charge_service(
                       charge_center_Id,
                       charge_service_id,
                       service_id,
	               creation_ccid,
		       receiving_ccid,
		       start_date,
		       end_date,
                       creation_date,
                       created_by,
                       last_update_login,
                       last_update_date,
                       last_updated_by)
		VALUES (
			        X_Charge_Center_Id,
                                X_Charge_Service_Id,
			        X_Service_Id,
			        X_Creation_Ccid,
			        X_Receiving_Ccid,
			        X_Start_Date,
			        X_End_Date,
			        X_Creation_Date,
			        X_Created_By,
			        X_Last_Update_Login,
			        X_Last_Update_Date,
                                X_Last_Updated_By
             );

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
                       X_Charge_Service_Id              NUMBER,
                       X_Service_Id                     NUMBER,
	               X_Creation_Ccid                  NUMBER,
		       X_Receiving_Ccid                 NUMBER,
		       X_Start_Date                     DATE,
		       X_End_Date                       DATE
  ) IS

    CURSOR C IS
        SELECT *
        FROM   IGI_itr_charge_service
        WHERE  rowid = X_Rowid
        FOR UPDATE of Charge_Service_Id NOWAIT;

    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
--    fnd_message.debug('RowId  '||X_Rowid);
--    fnd_message.debug(Recinfo.charge_service_id);
    if (C%NOTFOUND) then
      CLOSE C;
--       fnd_message.debug('Form Record deleted');
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrkb.IGI_ITR_CHARGE_SERVICES_SS_PKG.lock_row.msg1', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
--      fnd_message.error;
--      RAISE form_trigger_failure;
    end if;
    CLOSE C;
    if (
	       (Recinfo.charge_center_id =  X_Charge_Center_Id)
           AND (Recinfo.service_id       =  X_Service_Id)
           AND (Recinfo.charge_service_id = X_Charge_Service_Id)
           AND (Recinfo.creation_ccid    =  X_Creation_Ccid)
	   AND (Recinfo.receiving_ccid   =  X_Receiving_Ccid)
	   AND (    (Recinfo.start_date       =  X_Start_Date)
               OR   (    (Recinfo.start_date IS NULL)
                     AND (X_Start_Date IS NULL)))
	   AND (    (Recinfo.end_date         =  X_End_Date)
                OR  (    (Recinfo.end_date IS NULL)
                     AND (X_End_Date IS NULL)))
      ) then
      return;
    else
  --    fnd_message.debug('Form record changed');
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrkb.IGI_ITR_CHARGE_SERVICES_SS_PKG.lock_row.msg2', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_Charge_Service_Id              NUMBER,
                       X_Service_Id                     NUMBER,
               	       X_Creation_Ccid                  NUMBER,
		       X_Receiving_Ccid                 NUMBER,
		       X_Start_Date                     DATE,
		       X_End_Date                       DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS

  BEGIN
    UPDATE IGI_itr_charge_service
    SET
       charge_center_id                =     X_Charge_Center_Id,
       service_id                      =     X_Service_Id,
       creation_ccid                   =     X_Creation_Ccid,
       receiving_ccid                  =     X_Receiving_Ccid,
       start_date                      =     X_Start_Date,
       end_date                        =     X_End_Date,
       last_update_login               =     X_Last_Update_Login,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By

    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_itr_charge_service
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;



END IGI_ITR_CHARGE_SERVICES_SS_PKG;

/
