--------------------------------------------------------
--  DDL for Package Body PA_CAPITAL_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CAPITAL_EVENTS_PKG" as
/* $Header: PAXEVNTB.pls 120.2 2005/08/26 13:08:01 skannoji noship $ */

  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Capital_Event_Id               IN OUT NOCOPY NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Capital_Event_Number           NUMBER,
                       X_Event_Type                     VARCHAR2,
                       X_Event_Name                     VARCHAR2,
                       X_Asset_Allocation_Method        VARCHAR2,
                       X_Event_Period                   VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Request_Id                     NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE
                      ) IS

    CURSOR C IS
        SELECT  rowid
        FROM    pa_capital_events
        WHERE   capital_event_id = X_Capital_Event_Id;

    CURSOR C2 IS
        SELECT  pa_capital_events_s.nextval
        FROM    sys.dual;

   BEGIN
      IF (X_Capital_Event_Id IS NULL) THEN
        OPEN C2;
        FETCH C2 INTO X_Capital_Event_Id;
        CLOSE C2;
      END IF;

       INSERT INTO pa_capital_events(
              capital_event_id,
              project_id,
              capital_event_number,
              event_type,
              event_name,
              asset_allocation_method,
              event_period,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date
             ) VALUES (
              X_Capital_Event_Id,
              X_Project_Id,
              X_Capital_Event_Number,
              X_Event_Type,
              X_Event_Name,
              X_Asset_Allocation_Method,
              X_Event_Period,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Request_Id,
              X_Program_Application_Id,
              X_Program_Id,
              X_Program_Update_Date
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CAPITAL_EVENTS_PKG',
                                p_procedure_name => 'INSERT_ROW',
                                p_error_text => SUBSTRB(SQLERRM,1,240));
        RAISE;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                     X_Capital_Event_Id               IN OUT NOCOPY NUMBER,
                     X_Project_Id                     NUMBER,
                     X_Capital_Event_Number           NUMBER,
                     X_Event_Type                     VARCHAR2,
                     X_Event_Name                     VARCHAR2,
                     X_Asset_Allocation_Method        VARCHAR2,
                     X_Event_Period                   VARCHAR2
                     ) IS

	CURSOR C IS
	   SELECT  *
	   FROM    pa_capital_events
       WHERE   pa_capital_events.rowid = X_Rowid
       FOR UPDATE of Capital_Event_Id NOWAIT;

    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;
    IF (
               (Recinfo.capital_event_id =  X_Capital_Event_Id)
           AND (Recinfo.project_id =  X_Project_Id)
           AND (Recinfo.capital_event_number =  X_Capital_Event_Number)
           AND (Recinfo.event_type =  X_Event_Type)
           AND (Recinfo.event_name =  X_Event_Name)
           AND (Recinfo.asset_allocation_method =  X_Asset_Allocation_Method)
           AND (   (Recinfo.event_period =  X_Event_Period)
                OR (    (Recinfo.event_period IS NULL)
                    AND (X_Event_Period IS NULL)))
                 ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Capital_Event_Id               IN OUT NOCOPY NUMBER,
                     X_Project_Id                     NUMBER,
                     X_Capital_Event_Number           NUMBER,
                     X_Event_Type                     VARCHAR2,
                     X_Event_Name                     VARCHAR2,
                     X_Asset_Allocation_Method        VARCHAR2,
                     X_Event_Period                   VARCHAR2,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER,
                     X_Request_Id                     NUMBER,
                     X_Program_Application_Id         NUMBER,
                     X_Program_Id                     NUMBER,
                     X_Program_Update_Date            DATE
                    ) IS

  BEGIN
    UPDATE pa_capital_events
    SET
       capital_event_id                =     X_Capital_Event_Id,
       project_id                      =     X_Project_Id,
       capital_event_number            =     X_Capital_Event_Number,
       event_type                      =     X_Event_Type,
       event_name                      =     X_Event_Name,
       asset_allocation_method         =     X_Asset_Allocation_Method,
       event_period                    =     X_Event_Period,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       request_id                      =     X_Request_Id,
       program_application_id          =     X_Program_Application_Id,
       program_id                      =     X_Program_Id,
       program_update_date             =     X_Program_Update_Date
    WHERE rowid = X_Rowid
    OR    capital_event_id = X_Capital_Event_Id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CAPITAL_EVENTS_PKG',
                                p_procedure_name => 'UPDATE_ROW',
                                p_error_text => SUBSTRB(SQLERRM,1,240));
        RAISE;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
			           X_Capital_Event_Id NUMBER) IS
  BEGIN

    DELETE FROM pa_capital_events
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Delete_Row;


END PA_CAPITAL_EVENTS_PKG;

/
