--------------------------------------------------------
--  DDL for Package Body BIS_RS_STAGE_RUN_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RS_STAGE_RUN_HISTORY_PKG" AS
/*$Header: BISSTTHB.pls 120.3 2006/01/24 08:24 aguwalan noship $*/
PROCEDURE Insert_Row (	p_Request_set_id   NUMBER
			, p_Set_app_id       NUMBER
			, p_Stage_id         NUMBER
			, p_Request_id       NUMBER
			, p_Set_request_id   NUMBER
			, p_Start_date       DATE
			, p_Completion_date  DATE
			, p_Status_code      VARCHAR2
			, p_phase_code       VARCHAR2
			, p_Creation_date    DATE
			, p_Created_by       NUMBER
			, p_Last_update_date DATE
			, p_Last_updated_by  NUMBER
                        , p_completion_text  VARCHAR2
                      )
is
CURSOR C_check IS SELECT ROWID from BIS_RS_STAGE_RUN_HISTORY
where Request_set_id =p_Request_set_id;
X_Rowid  varchar2(200);
BEGIN
insert into BIS_RS_STAGE_RUN_HISTORY
			(Request_set_id
			, Set_app_id
			, Stage_id
			, Request_id
			, Set_request_id
			, Start_date
			, Completion_date
			, Status_code
			, phase_code
			, Creation_date
			, Created_by
			, Last_update_date
			, Last_updated_by
                        , Completion_Text)
			values
			(p_Request_set_id
			, p_Set_app_id
			, p_Stage_id
			, p_Request_id
			, p_Set_request_id
			, p_Start_date
			, p_Completion_date
			, p_Status_code
			, p_phase_code
			, p_Creation_date
			, p_Created_by
			, p_Last_update_date
			, p_Last_updated_by
			, p_completion_text);

	OPEN C_check;
	    FETCH C_check INTO X_Rowid;
	    if (C_check%NOTFOUND) then
	      CLOSE C_check;
	      Raise NO_DATA_FOUND;
	    end if;
	    CLOSE C_check;
	    Commit;
EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_STAGE_RUN_HISTORY_PKG.Insert_Row ' ||  sqlerrm);
     raise;
END;
-- modified aguwalan
function Update_Row (p_Request_id       NUMBER
			, p_Set_request_id   NUMBER
			, p_start_date       DATE DEFAULT NULL
			, p_Completion_date  DATE DEFAULT NULL
			, p_Status_code      VARCHAR2 DEFAULT NULL
			, p_phase_code       VARCHAR2 DEFAULT NULL
			, p_Last_update_date DATE
			, p_Last_updated_by  NUMBER
                        , p_completion_text  VARCHAR2  DEFAULT NULL) return boolean
IS

	setClause varchar2(1024):=null;
	stmt varchar2(2048):=null;

	BEGIN
	if(p_Request_id is null or p_Set_request_id is null or p_Last_update_date is null or p_Last_updated_by  is null) THEN
		return FALSE;
	END iF;

	if(p_start_date is not null) then
		setClause :=setClause || 'START_DATE = to_date(''' ||to_char(p_start_date ,'MM/DD/YYYY HH:MI:SS AM')||''',''MM/DD/YYYY HH:MI:SS AM''),';
	end if;

	if(p_Completion_date is not null) then
		setClause :=setClause || 'Completion_date = to_date(''' ||to_char(p_Completion_date,'MM/DD/YYYY HH:MI:SS AM')||''',''MM/DD/YYYY HH:MI:SS AM''),';
	end if;

	if(p_Phase_code is not null) then
		setClause :=setClause || 'Phase_code = ''' || p_Phase_code || ''', ' ;
	end if;

	if(p_Status_code is not null) then
		setClause :=setClause || 'Status_code = ''' || p_Status_code  || ''', ' ;
	end if;


	if setClause is not null then
	  setClause :=setClause || 'Last_update_date = ''' || p_Last_update_date  || ''', ' ;
	  setClause :=setClause || 'Last_updated_by= ' || p_Last_updated_by  ;
          stmt := 'update BIS_RS_STAGE_RUN_HISTORY set '|| setClause ;
	  stmt := stmt || ' where Set_request_id  = :1 and Request_id = :2';
	  execute immediate stmt USING p_Set_request_id, p_Request_id;
	end if;

	-- this is kept outside to handle pseudo languege issues

	if(p_completion_text is not null) then
	 update BIS_RS_STAGE_RUN_HISTORY
	   set   Completion_text = p_completion_text ,
	         Last_update_date = p_Last_update_date ,
	         Last_updated_by = p_Last_updated_by
           where Set_request_id  = p_Set_request_id
		 and Request_id = p_Request_id;
         end if;
	Commit;

	RETURN TRUE;

EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_STAGE_RUN_HISTORY_PKG.Update_Row ' ||  sqlerrm);
     raise;
END;


PROCEDURE Delete_Row (p_set_req_id number)
IS
BEGIN

	DELETE FROM BIS_RS_STAGE_RUN_HISTORY
	   WHERE SET_REQUEST_ID = p_set_req_id;

 EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_STAGE_RUN_HISTORY_PKG.Delete_Row ' ||  sqlerrm);
     raise;

END;

END BIS_RS_STAGE_RUN_HISTORY_PKG;

/
