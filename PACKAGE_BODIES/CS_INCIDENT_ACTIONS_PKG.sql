--------------------------------------------------------
--  DDL for Package Body CS_INCIDENT_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENT_ACTIONS_PKG" as
/* $Header: csincab.pls 115.1 99/07/16 08:57:52 porting ship  $ */

/*  *******    LOCAL PROCEDURES   ******* */

   PROCEDURE Register_New_Action_Inc_Audit( x_action_id          NUMBER,
					    x_incident_id        NUMBER,
                                            x_change_description VARCHAR2,
					    x_action_created_by  NUMBER,
                                            x_last_Update_login  NUMBER );
  PROCEDURE Process_Action_Audit
                    (  X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
		       X_Incident_Action_Id             NUMBER,
                       X_Incident_Id                    NUMBER,
                       X_Action_Owner_Id          	NUMBER DEFAULT NULL,
                       X_Action_Status_Id               NUMBER DEFAULT NULL,
                       X_Action_Severity_Id             NUMBER DEFAULT NULL,
                       X_Expected_Resolution_Date       DATE   DEFAULT NULL,
                       X_Orig_Action_Severity_Id        NUMBER DEFAULT NULL,
                       X_Orig_Action_Type_Id            NUMBER DEFAULT NULL,
                       X_Orig_Action_Status_Id          NUMBER DEFAULT NULL,
                       X_Orig_Action_Owner_Id           NUMBER DEFAULT NULL,
                       X_Action_Type_Id                 NUMBER DEFAULT NULL,
		       X_Orig_Expected_Date             DATE   DEFAULT NULL );


/* ********* END LOCAL PROCEDURES ********** */


  PROCEDURE Insert_Row(X_Rowid                   	IN OUT VARCHAR2,
                       X_Incident_Action_Id      	IN OUT NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Incident_Id                    NUMBER,
                       X_Action_Code                    VARCHAR2,
                       X_Action_Num              	NUMBER,
                       X_Action_Type_Id                 NUMBER DEFAULT NULL,
                       X_Action_Status_Id               NUMBER DEFAULT NULL,
                       X_Responsible_Person_Id          NUMBER DEFAULT NULL,
                       X_Text                           VARCHAR2 DEFAULT NULL,
                       X_Completion_Date                DATE DEFAULT NULL,
                       X_actual_time                    number  DEFAULT NULL,
                       X_Action_Severity_Id             NUMBER DEFAULT NULL,
                       X_Text_Description               VARCHAR2 DEFAULT NULL,
                       X_Text_Resolution                VARCHAR2 DEFAULT NULL,
                       X_Action_Effective_Date          DATE DEFAULT NULL,
                       X_Expected_Resolution_Date       DATE DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Context                        VARCHAR2 DEFAULT NULL,
		       X_OPEN_FLAG               	VARCHAR2 DEFAULT NULL ) IS

    CURSOR C IS SELECT rowid FROM cs_incident_actions
                 WHERE incident_action_id = X_Incident_Action_Id;
    CURSOR C2 IS SELECT cs_incident_actions_s.nextval FROM sys.dual;

   BEGIN
     IF (X_Incident_Action_Id IS NULL) THEN
       OPEN C2;
       FETCH C2 INTO X_Incident_Action_Id;
       CLOSE C2;
     END IF;

     INSERT INTO cs_incident_actions(
              incident_action_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              incident_id,
              action_code,
              action_num,
              action_type_id,
              action_status_id,
              responsible_person_id,
              text,
              completion_date,
              actual_time   ,
              action_severity_id,
              text_description,
              text_resolution,
              action_effective_date,
              expected_resolution_date,
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
              open_flag
             ) VALUES (
              X_Incident_Action_Id,
              trunc(sysdate),
              X_Last_Updated_By,
              trunc(sysdate),
              X_Created_By,
              X_Last_Update_Login,
              X_Incident_Id,
              X_Action_Code,
              X_Action_Num,
              X_Action_Type_Id,
              X_Action_Status_Id,
              X_Responsible_Person_Id,
              X_Text,
              X_Completion_Date,
              X_actual_time   ,
              X_Action_Severity_Id,
              X_Text_Description,
              X_Text_Resolution,
              X_Action_Effective_Date,
              X_Expected_Resolution_Date,
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
              X_Open_Flag
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    /* Insert into cs_incidents_audit table that an action has been created */
    Register_New_Action_Inc_Audit (x_incident_action_id,
				   x_incident_id,
				   x_text,
				   x_created_by,
                                   x_last_Update_login);

  END Insert_Row;

  PROCEDURE Register_New_Action_Inc_Audit( x_action_id NUMBER,
                                           x_incident_id NUMBER,
                                           x_change_description VARCHAR2,
					   x_action_created_by  NUMBER,
					   x_last_Update_login NUMBER ) IS

      	X_INCIDENT_AUDIT_ID               NUMBER ;
	X_CHG_INCIDENT_STATUS_FLAG        CHAR(1) := 'N';
 	X_CHG_INCIDENT_TYPE_FLAG          CHAR(1) := 'N';
 	X_CHG_INCIDENT_URGENCY_FLAG       CHAR(1) := 'N';
 	X_CHG_INCIDENT_SEVERITY_FLAG      CHAR(1) := 'N';
 	X_CHG_INCIDENT_OWNER_FLAG         CHAR(1) := 'N';
 	X_CHG_RESOLUTION_FLAG             CHAR(1) := 'N';
        X_CREATE_MANUAL_ACTION            CHAR(1) := 'N';

        X_INCIDENT_OWNER_ID               NUMBER := NULL;
        X1_INCIDENT_STATUS_ID             NUMBER := NULL;
        X1_INCIDENT_TYPE_ID               NUMBER := NULL;
        X1_INCIDENT_URGENCY_ID            NUMBER := NULL;
        X1_INCIDENT_SEVERITY_ID           NUMBER := NULL;
        X1_EXPECTED_RESOLUTION_DATE       DATE   := NULL;
        X1_INCIDENT_OWNER_ID              NUMBER := NULL;
        X1_Orig_status_id       	  NUMBER := NULL;
        X1_Orig_Incident_Type_Id       	  NUMBER := NULL;
        X1_Orig_urgency_id       	  NUMBER := NULL;
        X1_Orig_Severity_id       	  NUMBER := NULL;
        X1_Orig_Owner_Id      	 	  NUMBER := NULL;
        X1_Orig_resolution_date       	  DATE   := NULL;


      CURSOR C2 IS SELECT cs_incidents_audit_s1.nextval FROM sys.dual;

   BEGIN
     OPEN C2;
     FETCH C2 INTO X_Incident_Audit_Id;
     CLOSE C2;

     X_create_manual_Action := 'Y';

     INSERT INTO CS_Incidents_Audit(
		incident_audit_id            ,
 		incident_id                  ,
 		last_update_date             ,
 		last_updated_by              ,
 		creation_date                ,
 		created_by                   ,
 		last_update_login            ,
 		creation_time                ,
 		incident_status_id           ,
 		old_incident_status_id       ,
 		change_incident_status_flag  ,
 		incident_type_id             ,
 		old_incident_type_id         ,
 		change_incident_type_flag    ,
 		incident_urgency_id          ,
 		old_incident_urgency_id      ,
 		change_incident_urgency_flag ,
 		incident_severity_id         ,
 		old_incident_severity_id     ,
 		change_incident_severity_flag,
 		incident_owner_id            ,
 		old_incident_owner_id        ,
 		change_incident_owner_flag   ,
 		create_manual_action         ,
 		action_id                    ,
 		expected_resolution_date     ,
 		old_expected_resolution_date ,
 		change_resolution_flag       ,
 		change_description          )
           VALUES(
                X_Incident_Audit_Id,
                X_Incident_id,
                trunc(sysdate),
                x_action_created_by,
                trunc(sysdate),
                x_action_created_by,
                X_last_update_login,
                to_char(sysdate,'HH:MI PM'),
                X1_Incident_Status_Id,
                X1_Orig_status_id,
                X_Chg_incident_status_flag,
                X1_Incident_Type_Id,
                X1_Orig_Incident_Type_Id,
                X_Chg_INCIDENT_TYPE_FLAG,
                X1_Incident_Urgency_Id,
                X1_Orig_urgency_id,
                X_Chg_incident_urgency_flag,
                X1_Incident_Severity_Id,
                X1_Orig_Severity_id,
                X_Chg_incident_Severity_flag,
                X1_Incident_Owner_Id,
                X1_Orig_Owner_Id,
                X_Chg_incident_owner_flag,
                X_Create_Manual_Action,
                X_Action_Id,
      	 	X1_Expected_Resolution_Date,
                X1_Orig_resolution_date,
                X_Chg_resolution_flag,
                X_Change_Description );

   END  Register_New_Action_Inc_Audit;

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Incident_Action_Id               NUMBER,
                     X_Incident_Id                      NUMBER,
                     X_Action_Code                      VARCHAR2,
                     X_Action_Num                       NUMBER DEFAULT NULL,
                     X_Action_Type_Id                   NUMBER DEFAULT NULL,
                     X_Action_Status_Id                 NUMBER DEFAULT NULL,
                     X_Responsible_Person_Id            NUMBER DEFAULT NULL,
                     X_Text                             VARCHAR2 DEFAULT NULL,
                     X_Completion_Date                  DATE DEFAULT NULL,
                     X_actual_time                     number DEFAULT NULL,
                     X_Action_Severity_Id               NUMBER DEFAULT NULL,
                     X_Text_Description                 VARCHAR2 DEFAULT NULL,
                     X_Text_Resolution                  VARCHAR2 DEFAULT NULL,
                     X_Action_Effective_Date            DATE DEFAULT NULL,
                     X_Expected_Resolution_Date         DATE DEFAULT NULL,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Attribute6                       VARCHAR2 DEFAULT NULL,
                     X_Attribute7                       VARCHAR2 DEFAULT NULL,
                     X_Attribute8                       VARCHAR2 DEFAULT NULL,
                     X_Attribute9                       VARCHAR2 DEFAULT NULL,
                     X_Attribute10                      VARCHAR2 DEFAULT NULL,
                     X_Attribute11                      VARCHAR2 DEFAULT NULL,
                     X_Attribute12                      VARCHAR2 DEFAULT NULL,
                     X_Attribute13                      VARCHAR2 DEFAULT NULL,
                     X_Attribute14                      VARCHAR2 DEFAULT NULL,
                     X_Attribute15                      VARCHAR2 DEFAULT NULL,
                     X_Context                          VARCHAR2 DEFAULT NULL,
		   X_dispatcher_orig_syst	VARCHAR2 DEFAULT NULL,
		   X_dispatcher_orig_syst_id	NUMBER DEFAULT NULL,
		   X_dispatch_role_name	VARCHAR2 DEFAULT NULL ) IS
    CURSOR C IS
        SELECT *
        FROM   cs_incident_actions
        WHERE  rowid = X_Rowid
        FOR UPDATE of Incident_Action_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    IF (
               (Recinfo.incident_action_id =  X_Incident_Action_Id)
           AND (Recinfo.incident_id =  X_Incident_Id)
           AND (   (Recinfo.action_num =  X_Action_Num)
                OR (    (Recinfo.action_num IS NULL)
                    AND (X_Action_Num IS NULL)))
           AND (   (Recinfo.action_type_id =  X_Action_Type_Id)
                OR (    (Recinfo.action_type_id IS NULL)
                    AND (X_Action_Type_Id IS NULL)))
           AND (   (Recinfo.action_status_id =  X_Action_Status_Id)
                OR (    (Recinfo.action_status_id IS NULL)
                    AND (X_Action_Status_Id IS NULL)))
           AND (   (Recinfo.responsible_person_id =  X_Responsible_Person_Id)
                OR (    (Recinfo.responsible_person_id IS NULL)
                    AND (X_Responsible_Person_Id IS NULL)))
           AND (   (Recinfo.text =  X_Text)
                OR (    (Recinfo.text IS NULL)
                    AND (X_Text IS NULL)))
           AND (   (Recinfo.completion_date =  X_Completion_Date)
                OR (    (Recinfo.completion_date IS NULL)
                    AND (X_Completion_Date IS NULL)))
           AND (   (Recinfo.actual_time =  X_actual_time)
                OR (    (Recinfo.actual_time IS NULL)
                    AND (X_actual_time IS NULL)))
           AND (   (Recinfo.action_severity_id =  X_Action_Severity_Id)
                OR (    (Recinfo.action_severity_id IS NULL)
                    AND (X_Action_Severity_Id IS NULL)))
           AND (   (Recinfo.text_description =  X_Text_Description)
                OR (    (Recinfo.text_description IS NULL)
                    AND (X_Text_Description IS NULL)))
           AND (   (Recinfo.text_resolution =  X_Text_Resolution)
                OR (    (Recinfo.text_resolution IS NULL)
                    AND (X_Text_Resolution IS NULL)))
           AND (   (Recinfo.action_effective_date =  X_Action_Effective_Date)
                OR (    (Recinfo.action_effective_date IS NULL)
                    AND (X_Action_Effective_Date IS NULL)))
           AND (   (Recinfo.expected_resolution_date =  X_Expected_Resolution_Date)
                OR (    (Recinfo.expected_resolution_date IS NULL)
                    AND (X_Expected_Resolution_Date IS NULL)))
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
           AND (   (Recinfo.context =  X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.dispatcher_orig_syst =  X_dispatcher_orig_syst)
                OR (    (Recinfo.dispatcher_orig_syst IS NULL)
                    AND (X_dispatcher_orig_syst IS NULL)))
           AND (   (Recinfo.dispatcher_orig_syst_id =  X_dispatcher_orig_syst_id)
                OR (    (Recinfo.dispatcher_orig_syst_id IS NULL)
                    AND (X_dispatcher_orig_syst_id IS NULL)))
           AND (   (Recinfo.dispatch_role_name =  X_dispatch_role_name)
                OR (    (Recinfo.dispatch_role_name IS NULL)
                    AND (X_dispatch_role_name IS NULL)))


                        ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Incident_Action_Id             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Incident_Id                    NUMBER,
                       X_Action_Code                    VARCHAR2,
                       X_Action_Num                     NUMBER DEFAULT NULL,
                       X_Action_Type_Id                 NUMBER DEFAULT NULL,
                       X_Action_Status_Id               NUMBER DEFAULT NULL,
                       X_Responsible_Person_Id          NUMBER DEFAULT NULL,
                       X_Text                           VARCHAR2 DEFAULT NULL,
                       X_Completion_Date                DATE DEFAULT NULL,
                       X_actual_time 			NUMBER DEFAULT NULL,
                       X_Action_Severity_Id             NUMBER DEFAULT NULL,
                       X_Text_Description               VARCHAR2 DEFAULT NULL,
                       X_Text_Resolution                VARCHAR2 DEFAULT NULL,
                       X_Action_Effective_Date          DATE DEFAULT NULL,
                       X_Expected_Resolution_Date       DATE DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Context                        VARCHAR2 DEFAULT NULL,
    		       X_Orig_Action_Severity_Id        NUMBER   DEFAULT NULL,
		       X_Orig_Action_Type_Id            NUMBER   DEFAULT NULL,
		       X_Orig_Action_Status_id		NUMBER   DEFAULT NULL,
		       X_Orig_Action_Owner_id		NUMBER   DEFAULT NULL,
      		       X_Orig_Expected_Date             DATE     DEFAULT NULL,
                       X_Open_Flag               	VARCHAR2 DEFAULT NULL,
		   X_dispatcher_orig_syst	VARCHAR2 DEFAULT NULL,
		   X_dispatcher_orig_syst_id	NUMBER DEFAULT NULL,
		   X_dispatch_role_name	VARCHAR2 DEFAULT NULL
				   ) IS

  BEGIN

    UPDATE cs_incident_actions
    SET
       incident_action_id              =     X_Incident_Action_Id,
       last_update_date                =     trunc(sysdate),
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       incident_id                     =     X_Incident_Id,
       action_code                     =     X_Action_Code,
       action_num                      =     X_Action_Num,
       action_type_id                  =     X_Action_Type_Id,
       action_status_id                =     X_Action_Status_Id,
       responsible_person_id           =     X_Responsible_Person_Id,
       text                            =     X_Text,
       completion_date                 =     X_Completion_Date,
       actual_time		       =     X_actual_time,
       action_severity_id              =     X_Action_Severity_Id,
       text_description                =     X_Text_Description,
       text_resolution                 =     X_Text_Resolution,
       action_effective_date           =     X_Action_Effective_Date,
       expected_resolution_date        =     X_Expected_Resolution_Date,
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
       context                         =     X_Context,
       open_flag                       =     X_Open_Flag ,
	  dispatcher_orig_syst		    = 	X_Dispatcher_orig_syst,
	  dispatcher_orig_syst_id		    = 	X_Dispatcher_orig_syst_id,
	  dispatch_role_name		    = 	X_Dispatch_role_name
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

   /* insert a record into the incident action audit table */

   Process_Action_Audit(  X_Last_Update_Date          ,
                          X_Last_Updated_By           ,
                          X_Last_Update_Login         ,
                          X_Incident_Action_Id        ,
                       	  X_Incident_Id               ,
                       	  X_Responsible_Person_Id     ,
                       	  X_Action_Status_Id          ,
                       	  X_Action_Severity_Id        ,
                          X_Expected_Resolution_Date  ,
                       	  X_Orig_Action_Severity_Id   ,
                       	  X_Orig_Action_Type_Id       ,
                       	  X_Orig_Action_Status_Id     ,
                       	  X_Orig_Action_Owner_Id      ,
                       	  X_Action_Type_Id            ,
       		          X_Orig_Expected_Date         );

  END Update_Row;


  PROCEDURE Process_Action_Audit
                    (  X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
		       X_Incident_Action_Id             NUMBER,
                       X_Incident_Id                    NUMBER,
                       X_Action_Owner_Id          	NUMBER DEFAULT NULL,
                       X_Action_Status_Id               NUMBER DEFAULT NULL,
                       X_Action_Severity_Id             NUMBER DEFAULT NULL,
                       X_Expected_Resolution_Date       DATE   DEFAULT NULL,
                       X_Orig_Action_Severity_Id        NUMBER DEFAULT NULL,
                       X_Orig_Action_Type_Id            NUMBER DEFAULT NULL,
                       X_Orig_Action_Status_Id          NUMBER DEFAULT NULL,
                       X_Orig_Action_Owner_Id           NUMBER DEFAULT NULL,
                       X_Action_Type_Id                 NUMBER DEFAULT NULL,
		       X_Orig_Expected_Date             DATE   DEFAULT NULL ) IS

       	X_Action_Response_Flag           CHAR   := 'N';
       	X_Change_Action_Type_Flag        CHAR   := 'N';
       	X_Change_Action_Status_Flag      CHAR   := 'N';
       	X_Change_Action_Owner_Flag       CHAR   := 'N';
       	X_Change_Action_Severity_Flag    CHAR   := 'N';
       	X_Change_Expected_Date_Flag      CHAR   := 'N';
       	X_Action_Response                CHAR   := NULL;
       	X_Incident_Action_Audit_Id       NUMBER := NULL;

       	l_Action_Owner_ID		NUMBER := NULL;
	l_Action_Severity_ID		NUMBER := NULL;
	l_Action_Status_ID		NUMBER := NULL;
	l_Action_Type_ID		NUMBER := NULL;
	l_Expected_Resolution_Date	Date   := NULL;
       	l_Orig_Action_Owner_ID		NUMBER := NULL;
	l_Orig_Action_Severity_ID	NUMBER := NULL;
	l_Orig_Action_Status_ID		NUMBER := NULL;
	l_Orig_Action_Type_ID		NUMBER := NULL;
	l_Orig_Expected_Date		Date   := NULL;

      CURSOR C2 IS SELECT cs_incident_action_audit_s.nextval FROM sys.dual;

   BEGIN

      OPEN C2;
      FETCH C2 INTO X_Incident_Action_Audit_Id;
      CLOSE C2;

      IF (NOT (    X_Action_Type_ID IS NULL
	       AND X_Orig_Action_Type_ID IS NULL)) AND
         (X_Action_Type_ID IS NULL OR
	  X_Orig_Action_Type_ID IS NULL OR
	  X_Action_Type_Id <> X_Orig_Action_Type_Id) THEN
        X_Change_Action_Type_Flag := 'Y';
	l_Action_Type_ID := X_Action_Type_ID;
	l_Orig_Action_Type_ID := X_Orig_Action_Type_ID;
      END IF;

      IF (NOT (    X_Action_Status_ID IS NULL
	       AND X_Orig_Action_Status_ID IS NULL)) AND
         (X_Action_Status_ID IS NULL OR
	  X_Orig_Action_Status_ID IS NULL OR
	  X_Action_Status_Id <> X_Orig_Action_Status_Id) THEN
        X_Change_Action_Status_Flag := 'Y';
	l_Action_Status_ID := X_Action_Status_ID;
	l_Orig_Action_Status_ID := X_Orig_Action_Status_ID;
      END IF;

      IF (NOT (    X_Action_Owner_ID IS NULL
	       AND X_Orig_Action_Owner_ID IS NULL)) AND
         (X_Action_Owner_ID IS NULL OR
	  X_Orig_Action_Owner_ID IS NULL OR
	  X_Action_Owner_Id <> X_Orig_Action_Owner_Id) THEN
        X_Change_Action_Owner_Flag := 'Y';
	l_Action_Owner_ID := X_Action_Owner_ID;
	l_Orig_Action_Owner_ID := X_Orig_Action_Owner_ID;
      END IF;

      IF (NOT (    X_Action_Severity_ID IS NULL
	       AND X_Orig_Action_Severity_ID IS NULL)) AND
         (X_Action_Severity_ID IS NULL OR
	  X_Orig_Action_Severity_ID IS NULL OR
	  X_Action_Severity_Id <> X_Orig_Action_Severity_Id) THEN
        X_Change_Action_Severity_Flag := 'Y';
	l_Action_Severity_ID := X_Action_Severity_ID;
	l_Orig_Action_Severity_ID := X_Orig_Action_Severity_ID;
      END IF;

      IF (NOT (    X_Expected_Resolution_Date IS NULL
	       AND X_Orig_Expected_Date IS NULL)) AND
         (X_Expected_Resolution_Date IS NULL OR
	  X_Orig_Expected_Date IS NULL OR
	  X_Expected_Resolution_Date <> X_Orig_Expected_Date) THEN
        X_Change_Action_Severity_Flag := 'Y';
	l_Expected_Resolution_Date := X_Expected_Resolution_Date;
	l_Orig_Expected_Date := X_Orig_Expected_Date;
      END IF;

      IF  X_Change_Action_Type_Flag      = 'Y' OR
          X_Change_Action_Status_Flag    = 'Y' OR
          X_Change_Action_Owner_Flag     = 'Y' OR
          X_Change_Action_Severity_Flag  = 'Y' OR
          X_Change_Expected_Date_Flag    = 'Y' THEN

       INSERT INTO cs_incident_action_audit(
              incident_action_audit_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              incident_action_id,
              incident_id,
              action_owner_id,
              action_response_flag,
              action_status_id,
              action_severity_id,
              change_action_type_flag,
              old_action_severity_id,
              old_action_type_id,
              old_action_status_id,
              old_action_owner_id,
              change_action_status_flag,
              change_action_owner_flag,
              action_type_id,
              action_response,
              change_expected_date_flag,
              expected_resolution_date,
              old_expected_resolution_date
             ) VALUES (
              X_Incident_Action_Audit_Id,
              X_last_update_date,
              X_last_updated_by,
              X_last_update_date,
              X_last_updated_by,
              X_last_update_login,
              X_Incident_Action_Id,
              X_Incident_Id,
              l_Action_Owner_Id,
              X_Action_Response_Flag,
              l_Action_Status_Id,
              l_Action_Severity_Id,
              X_Change_Action_Type_Flag,
              l_Orig_Action_Severity_Id,
              l_Orig_Action_Type_Id,
              l_Orig_Action_Status_Id,
              l_Orig_Action_Owner_Id,
              X_Change_Action_Status_Flag,
              X_Change_Action_Owner_Flag,
              l_Action_Type_Id,
              X_Action_Response,
              X_Change_Expected_Date_Flag,
              l_Expected_Resolution_Date,
              l_Orig_Expected_Date );
   END IF;

  END Process_Action_Audit;


  PROCEDURE Select_Summary(X_INCIDENT_ID		NUMBER,
			   X_TOTAL			IN OUT NUMBER,
			   X_TOTAL_RTOT_DB		IN OUT NUMBER) IS
  BEGIN

    SELECT NVL(SUM(ACTUAL_TIME), 0)
      INTO X_TOTAL
      FROM CS_INCIDENT_ACTIONS
     WHERE INCIDENT_ID = X_INCIDENT_ID;

    X_TOTAL_RTOT_DB := X_TOTAL;

  END Select_Summary;

END CS_INCIDENT_ACTIONS_PKG ;

/
