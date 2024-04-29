--------------------------------------------------------
--  DDL for Package Body CSF_PLAN_TERRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_PLAN_TERRS_PKG" AS
/* $Header: CSFVPLTB.pls 120.3 2007/12/18 06:21:59 ipananil ship $ */

/*
+========================================================================+
|                 Copyright (c) 1999 Oracle Corporation                  |
|                    Redwood Shores, California, USA                     |
|                         All rights reserved.                           |
+========================================================================+
Name
----
CSF_PLAN_TERRS_PKG

Purpose
-------
Insert, lock and delete records in the CSF_PLAN_TERRS table.
Check uniqueness of columns PLAN_TERR_ID and TERR_ID/GROUP_ID combinations.
Check referential integrity of the TERR_ID and GROUP_ID columns.

History
-------
06-JAN-2000 ipels         - First creation
26-SEP-2000 ipels         - Fixed bug# 1413810
13-NOV-2002 jgrondel      Bug 2663989.
                          Added NOCOPY hint to procedure
                          out-parameters.
13-NOV-2002 jgrondel      Added dbdrv.
03-dec-2002 jgrondel      Bug 2692082.
                          Added NOCOPY hint to procedure
                          out-parameters.
30-Nov-2004 vrajeev       Bug Fixed 3224947
                          Changed code in Delete_Row
+========================================================================+
*/


PROCEDURE Check_Unique
( p_rowid    IN VARCHAR2,
  p_terr_id  IN NUMBER,
  p_group_id IN NUMBER
)
IS

	CURSOR c_unique IS
	  SELECT NULL
	    FROM csf_plan_terrs
	   WHERE ( p_rowid IS NULL OR rowid <> p_rowid )
		 AND terr_id  = p_terr_id
		 AND group_id = p_group_id;

	r_unique c_unique%ROWTYPE;

BEGIN

	OPEN c_unique;
	FETCH c_unique INTO r_unique;
	IF c_unique%FOUND THEN
		CLOSE c_unique;
		FND_MESSAGE.Set_Name('CSF', 'CSF_PLAN_TERRS_NOT_UNIQUE');
		FND_MESSAGE.Set_Token('P_TERR_ID', p_terr_id);
		FND_MESSAGE.Set_Token('P_GROUP_ID', p_group_id);
		APP_EXCEPTION.Raise_Exception;
	END IF;
	CLOSE c_unique;

END Check_Unique;


PROCEDURE Check_References
( p_terr_id  IN NUMBER,
  p_group_id IN NUMBER
)
IS

	CURSOR c_terr IS
	  SELECT NULL
	    FROM jtf_terr_all
	   WHERE terr_id  = p_terr_id;

	CURSOR c_group IS
	  SELECT NULL
	    FROM jtf_rs_groups_b
	   WHERE group_id  = p_group_id;

	r_terr	c_terr%ROWTYPE;
	r_group	c_group%ROWTYPE;

BEGIN

	OPEN c_terr;
	FETCH c_terr INTO r_terr;
	IF c_terr%NOTFOUND THEN
		CLOSE c_terr;
		FND_MESSAGE.Set_Name('CSF', 'CSF_PLAN_TERRS_INVALID_TERR');
		FND_MESSAGE.Set_Token('P_TERR_ID', p_terr_id);
		APP_EXCEPTION.Raise_Exception;
	END IF;
	CLOSE c_terr;

	OPEN c_group;
	FETCH c_group INTO r_group;
	IF c_group%NOTFOUND THEN
		CLOSE c_group;
		FND_MESSAGE.Set_Name('CSF', 'CSF_PLAN_TERRS_INVALID_GROUP');
		FND_MESSAGE.Set_Token('P_GROUP_ID', p_group_id);
		APP_EXCEPTION.Raise_Exception;
	END IF;
	CLOSE c_group;

END Check_References;


PROCEDURE Insert_Row
( x_rowid    IN OUT NOCOPY VARCHAR2,
  p_terr_id  IN     NUMBER,
  p_group_id IN     NUMBER
)
IS

	l_plan_terr_id	            NUMBER;
	l_last_update_date	    DATE   ;
	l_last_updated_by	    NUMBER ;
	l_creation_date 	    DATE   ;
	l_created_by		    NUMBER ;
	l_last_update_login	    NUMBER ;
	l_object_version_number NUMBER := 1;

	CURSOR c_plan_terrs IS
	  SELECT rowid
	    FROM csf_plan_terrs
	   WHERE plan_terr_id = l_plan_terr_id;

BEGIN

	l_last_update_date	    := SYSDATE;
	l_last_updated_by	    := FND_GLOBAL.User_Id;
	l_creation_date 	    := SYSDATE;
	l_created_by		    := FND_GLOBAL.User_Id;
	l_last_update_login	    := FND_GLOBAL.Login_Id;

	SELECT CSF_PLAN_TERRS_S.NEXTVAL
	  INTO l_plan_terr_id
	  FROM dual;

	INSERT INTO csf_plan_terrs
		( plan_terr_id			,
		  last_update_date		,
		  last_updated_by		,
		  creation_date			,
		  created_by			,
		  last_update_login		,
		  object_version_number		,
		  terr_id			,
		  group_id
		)
	VALUES
		( l_plan_terr_id		,
		  l_last_update_date		,
		  l_last_updated_by		,
		  l_creation_date		,
		  l_created_by			,
		  l_last_update_login		,
		  l_object_version_number	,
		  p_terr_id			,
		  p_group_id
		);

	OPEN c_plan_terrs;
	FETCH c_plan_terrs INTO x_rowid;
	IF (c_plan_terrs%NOTFOUND) THEN
		CLOSE c_plan_terrs;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE c_plan_terrs;

END Insert_Row;


PROCEDURE Delete_Row
( p_rowid IN VARCHAR2
)
IS
  l_selected_terr  varchar2(4000);
  l_del_terr       varchar2(4000);
  l_dummy          boolean;
  CURSOR c_deleted_terr is
      SELECT terr_id
      FROM csf_plan_terrs
      WHERE rowid = p_rowid;
BEGIN
    -- BUG Fixed 3224947
    -- After deleting a territory from the planner group
    -- The territory should be removed from profile 'CSF: Selcted Territories'
    -- To avoid resources belonging to that territory appearing on the Plan Board and Gantt.
    OPEN c_deleted_terr;
    FETCH c_deleted_terr INTO l_del_terr;
    IF (c_deleted_terr%NOTFOUND) THEN
		CLOSE c_deleted_terr;
		RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_deleted_terr;
    -- Get selected territories
    l_selected_terr := csf_util_pvt.get_selected_terr(fnd_global.user_id);

    if l_selected_terr is not null
    then
       l_selected_terr := replace(l_selected_terr, l_del_terr);
       l_selected_terr := replace(l_selected_terr,',,',',');
       l_selected_terr := ltrim(l_selected_terr,',');
       l_selected_terr := rtrim(l_selected_terr,',');

       -- Save the modified list
       csf_util_pvt.set_selected_terr( l_selected_terr, fnd_global.user_id );
     end if;
     DELETE FROM csf_plan_terrs
	      WHERE rowid = p_rowid;
     IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
     END IF;

END Delete_Row;


PROCEDURE Lock_Row
( p_rowid                 IN VARCHAR2,
  p_object_version_number IN NUMBER
)
IS

	l_object_version_number NUMBER;

	CURSOR c_plan_terrs IS
	  SELECT object_version_number
	    FROM csf_plan_terrs
	   WHERE rowid = p_rowid
		 FOR UPDATE NOWAIT;

BEGIN

	OPEN c_plan_terrs;
	FETCH c_plan_terrs INTO l_object_version_number;
	IF (c_plan_terrs%NOTFOUND) THEN
		CLOSE c_plan_terrs;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
	CLOSE c_plan_terrs;

	IF (l_object_version_number = p_object_version_number) THEN
		NULL;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;

END Lock_Row;


END CSF_PLAN_TERRS_PKG;



/
