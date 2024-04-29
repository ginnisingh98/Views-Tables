--------------------------------------------------------
--  DDL for Package Body BIS_RS_PROG_RUN_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RS_PROG_RUN_HISTORY_PKG" AS
/*$Header: BISPRTHB.pls 120.0 2005/06/01 14:27 appldev noship $*/
PROCEDURE Insert_Row(	 p_Set_request_id	Number,
			 p_Stage_request_id 	Number,
			 p_Request_id		Number,
			 p_Program_id		Number,
			 p_Prog_app_id		Number,
			 p_Status_code		Varchar2,
			 p_Phase_code		Varchar2,
			 p_Start_date		DATE,
			 p_Completion_date	Date,
			 p_Creation_date         DATE,
			 p_Created_by            NUMBER,
			 p_Last_update_date      DATE,
			 p_Last_updated_by       NUMBER,
                         p_completion_text       VARCHAR2
                      )
is

BEGIN

	insert into BIS_RS_PROG_RUN_HISTORY
				(Set_request_id,
				 Stage_request_id,
				 Request_id,
				 Program_id,
				 Prog_app_id,
				 Status_code,
				 Phase_code,
				 Start_date,
				 Completion_date,
				 Creation_date,
				 Created_by,
				 Last_update_date,
				 Last_updated_by,
				 Completion_Text )
				values
				(p_Set_request_id,
				 p_Stage_request_id,
				 p_Request_id,
				 p_Program_id,
				 p_Prog_app_id,
				 p_Status_code,
				 p_Phase_code,
				 p_Start_date,
				 p_Completion_date,
				 p_Creation_date,
				 p_Created_by,
				 p_Last_update_date,
				 p_Last_updated_by,
				 p_completion_text);

	   commit;
EXCEPTION
  when others then
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_PROG_RUN_HISTORY_PKG.Insert_Row ' ||  sqlerrm);
     raise;

END;


FUNCTION Update_Row(	 p_Set_request_id	Number,
			 p_Stage_request_id 	Number,
			 p_Request_id		Number,
			 p_Program_id		Number DEFAULT NULL,
			 p_Prog_app_id		Number DEFAULT NULL,
			 p_Status_code		Varchar2 DEFAULT NULL,
			 p_Phase_code		Varchar2 DEFAULT NULL,
			 p_Completion_date	Date DEFAULT NULL,
			 p_Last_update_date      DATE,
			 p_Last_updated_by       NUMBER,
                         p_completion_text       VARCHAR2 DEFAULT NULL) RETURN BOOLEAN
IS

setClause varchar2(5000):=null;
stmt varchar2(5000):=null;

BEGIN

if(p_Set_request_id is null or p_Request_id is null or p_Last_update_date is null or p_Last_updated_by  is null) THEN
	return FALSE;
END iF;

if(p_Completion_date is not null) then
	setClause :=setClause || 'Completion_date = to_date(''' ||to_char(p_Completion_date,'MM/DD/YYYY HH:MI:SS AM')||''',''MM/DD/YYYY HH:MI:SS AM''),';
end if;

if(p_Stage_request_id is not null) then
	setClause :=setClause || 'Stage_request_id = ' || p_Stage_request_id ||', ';
end if;

if(p_Phase_code is not null) then
	setClause :=setClause || 'Phase_code = ''' || p_Phase_code || ''', ' ;
end if;

if(p_Status_code is not null) then
	setClause :=setClause || 'Status_code = ''' || p_Status_code  ||''', ' ;
end if;

if(p_Program_id	is not null) then
	setClause :=setClause || 'Program_id = ' || p_Program_id || ', ' ;
end if;

if(p_Prog_app_id is not null) then
	setClause :=setClause || 'Prog_app_id = ' || p_Prog_app_id || ', ' ;
end if;

if setClause is null then
	return false;
end if;

setClause :=setClause || 'Last_update_date = '''|| p_Last_update_date  || ''', ' ;
setClause :=setClause || 'Last_updated_by= ' || p_Last_updated_by ;

stmt := stmt || 'update BIS_RS_PROG_RUN_HISTORY set '|| setClause;
stmt := stmt || ' where Set_request_id   = :1 and Request_id = :2 ';

execute immediate stmt using p_Set_request_id ,p_Request_id;

if(p_completion_text is not null) then
   update BIS_RS_PROG_RUN_HISTORY
   set Completion_text = p_completion_text
   where Set_request_id  = p_Set_request_id and Request_id = p_Request_id;
end if;

Commit;
RETURN TRUE;

EXCEPTION
  when others then
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_PROG_RUN_HISTORY_PKG.Update_Row ' ||  sqlerrm);
     raise;

END;


PROCEDURE Delete_Row (p_set_rq_id number)
IS
BEGIN

	DELETE FROM BIS_RS_PROG_RUN_HISTORY
	   WHERE SET_REQUEST_ID =p_set_rq_id;

EXCEPTION
  when others then
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_PROG_RUN_HISTORY_PKG.Delete_Row ' ||  sqlerrm);
     raise;
END;


END BIS_RS_PROG_RUN_HISTORY_PKG;

/
