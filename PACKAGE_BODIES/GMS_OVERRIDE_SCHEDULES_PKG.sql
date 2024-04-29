--------------------------------------------------------
--  DDL for Package Body GMS_OVERRIDE_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_OVERRIDE_SCHEDULES_PKG" as
/* $Header: gmsicovb.pls 115.8 2002/11/25 23:41:38 jmuthuku ship $ */

PROCEDURE Insert_Row(p_rowid          		IN OUT NOCOPY 		VARCHAR2,
		     p_award_id       		IN		NUMBER,
		     p_project_id 		IN		NUMBER,
                     p_task_id    		IN		NUMBER,
                     p_idc_schedule_id  	IN		NUMBER,
                     p_cost_ind_sch_fixed_date 	IN  		DATE,
 		     p_mode 			IN		VARCHAR2 default 'R') IS
  CURSOR 	get_rowid IS
  SELECT 	rowid
  FROM 		GMS_OVERRIDE_SCHEDULES
  WHERE 	award_id = p_award_id
  AND		project_id = p_project_id
  AND 		(task_id = p_task_id
  OR 		(task_id is NULL AND p_task_id is NULL));

  l_last_update_date	DATE;
  l_last_updated_by	NUMBER;
  l_last_update_login	NUMBER;
Begin
  l_last_update_date := SYSDATE;
  IF (p_mode = 'I') THEN
  	l_last_updated_by := 1;
	l_last_update_login := 0;
  ELSIF (p_mode = 'R') THEN
	l_last_updated_by := FND_GLOBAL.USER_ID;
	IF (l_last_updated_by is NULL) THEN
      		l_last_updated_by := -1;
	END IF;
	l_last_update_login :=FND_GLOBAL.LOGIN_ID;
	IF (l_last_update_login is NULL) THEN
      		l_last_update_login := -1;
	END IF;
  ELSE
	FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
	app_exception.raise_exception;
  END IF;

  INSERT into GMS_OVERRIDE_SCHEDULES
	(award_id,
 	 project_id,
	 task_id,
	 idc_schedule_id,
	 cost_ind_sch_fixed_date,
 	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login
	)
  VALUES
	(p_award_id,
	 p_project_id,
	 p_task_id,
	 p_idc_schedule_id,
	 p_cost_ind_sch_fixed_date,
	 l_last_update_date,
	 l_last_updated_by,
	 l_last_update_date,
	 l_last_updated_by,
	 l_last_update_login
	);

  OPEN  get_rowid;
  FETCH get_rowid INTO p_rowid;
  IF (get_rowid%NOTFOUND) THEN
        CLOSE get_rowid;
        raise no_data_found;
  END IF;
  CLOSE get_rowid;

End insert_row;


PROCEDURE Update_Row(p_rowid          		IN 		VARCHAR2,
		     p_project_id 		IN		NUMBER,
		     p_task_id    		IN		NUMBER,
		     p_idc_schedule_id   	IN		NUMBER,
	  	     p_cost_ind_sch_fixed_date 	IN  		DATE,
		     p_mode			IN 		VARCHAR2 default 'R') IS
  l_last_update_date	DATE;
  l_last_updated_by	NUMBER;
  l_last_update_login	NUMBER;
Begin
  l_last_update_date := SYSDATE;
  IF (p_mode = 'I') THEN
	l_last_updated_by := 1;
	l_last_update_login := 0;
  ELSIF (p_mode = 'R') THEN
	l_last_updated_by := FND_GLOBAL.USER_ID;
	IF (l_last_updated_by is NULL) THEN
      		l_last_updated_by := -1;
	END IF;
 	l_last_update_login :=FND_GLOBAL.LOGIN_ID;
	IF (l_last_update_login is NULL) THEN
		l_last_update_login := -1;
	END IF;
  ELSE
	FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    	app_exception.raise_exception;
  END IF;

  UPDATE GMS_OVERRIDE_SCHEDULES
  SET	 project_id = p_project_id,
	 task_id =  p_task_id,
	 idc_schedule_id = p_idc_schedule_id,
	 cost_ind_sch_fixed_date =  p_cost_ind_sch_fixed_date,
	 last_update_date =  l_last_update_date,
	 last_updated_by = l_last_updated_by,
	 last_update_login = l_last_update_login
  WHERE rowid = p_rowid;

  IF (sql%NOTFOUND) THEN
         raise no_data_found;
  END IF;

End update_row;


PROCEDURE Delete_Row(p_rowid             	IN 		VARCHAR2) IS
Begin
  DELETE	gms_override_schedules
  WHERE		rowid = p_rowid;

  IF (sql%NOTFOUND) THEN
  	raise no_data_found;
  END IF;

End delete_row;

PROCEDURE Lock_Row(p_rowid          		IN 		VARCHAR2,
		   p_award_id       		IN		NUMBER,
		   p_project_id 		IN		NUMBER,
		   p_task_id    		IN		NUMBER,
		   p_idc_schedule_id   		IN		NUMBER,
		   p_cost_ind_sch_fixed_date   	IN  		DATE) IS
  CURSOR ovr_sch IS
  SELECT award_id, project_id, task_id, idc_schedule_id, cost_ind_sch_fixed_date
  FROM 	 GMS_OVERRIDE_SCHEDULES
  WHERE  rowid = p_rowid
  for update of idc_schedule_id, cost_ind_sch_fixed_date nowait;

  recinfo ovr_sch%rowtype;

BEGIN
  OPEN 	ovr_sch;
  FETCH ovr_sch INTO Recinfo;
  IF (ovr_sch %NOTFOUND)  THEN
      	CLOSE ovr_sch;
	FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
	APP_EXCEPTION.Raise_Exception;
  END IF;
  CLOSE ovr_sch;
  IF  (recinfo.award_id = p_award_id
  AND recinfo.project_id = p_project_id
  AND (recinfo.task_id = p_task_id OR (recinfo.task_id is null AND p_task_id is null))
  AND recinfo.idc_schedule_id = p_idc_schedule_id
  AND (recinfo.cost_ind_sch_fixed_date = p_cost_ind_sch_fixed_date OR (recinfo.cost_ind_sch_fixed_date is
      null AND p_cost_ind_sch_fixed_date is null)))  THEN
	return;
  ELSE
	FND_MESSAGE.set_name('FND','FORM_RECORD_CHANGED');
	APP_EXCEPTION.Raise_Exception;
  END IF;

End lock_row;

END GMS_OVERRIDE_SCHEDULES_PKG;

/
