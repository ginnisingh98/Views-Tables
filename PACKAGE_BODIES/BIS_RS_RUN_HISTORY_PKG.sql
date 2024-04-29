--------------------------------------------------------
--  DDL for Package Body BIS_RS_RUN_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RS_RUN_HISTORY_PKG" AS
/*$Header: BISRSTHB.pls 120.0 2005/06/01 14:53 appldev noship $*/

PROCEDURE Insert_Row(p_Request_set_id   NUMBER
			, p_Set_app_id       NUMBER
			, p_request_set_name VARCHAR2
			, p_Request_id       NUMBER
			, p_rs_refresh_type  VARCHAR2
			, p_Start_date       DATE
			, p_Completion_date  DATE
			, p_Phase_code	     Varchar2
			, p_Status_code      VARCHAR2
			, p_Creation_date    DATE
			, p_Created_by       NUMBER
			, p_Last_update_date DATE
			, p_Last_updated_by  NUMBER
                        , p_completion_text  VARCHAR2)
IS
CURSOR C_check IS SELECT ROWID from BIS_RS_RUN_HISTORY
where Request_set_id =p_Request_set_id;
X_Rowid  varchar2(200);
BEGIN
insert into BIS_RS_RUN_HISTORY
			(Request_set_id
			,Set_app_id
			,Request_id
			,request_set_type
			,Start_date
			,Completion_date
			, Phase_code
			, Status_code
			, Creation_date
			, Created_by
			, Last_update_date
			, Last_updated_by
                        , Completion_Text
			, REQUEST_SET_NAME)
			values
			( p_Request_set_id
			, p_Set_app_id
			, p_Request_id
			, p_rs_refresh_type
			, p_Start_date
			, p_Completion_date
			, p_Phase_code
			, p_Status_code
			, p_Creation_date
			, p_Created_by
			, p_Last_update_date
			, p_Last_updated_by
			, p_completion_text
			, p_request_set_name
			);

	OPEN C_check;
	    FETCH C_check INTO X_Rowid;
	    if (C_check%NOTFOUND) then
	      CLOSE C_check;
	      Raise NO_DATA_FOUND;
	    end if;
	    CLOSE C_check;
		commit;
EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_RUN_HISTORY_PKG.Insert_Row ' ||  sqlerrm);
     raise;
END;

FUNCTION Update_Row ( p_Request_id       NUMBER
			, p_Request_set_id        NUMBER     DEFAULT NULL
			, p_Set_app_id       NUMBER DEFAULT NULL
			, p_Start_date       DATE DEFAULT NULL
			, p_Completion_date  DATE DEFAULT NULL
			, p_Phase_code	     VARCHAR2 DEFAULT NULL
			, p_Status_code      VARCHAR2 DEFAULT NULL
			, p_Last_update_date DATE
			, p_Last_updated_by  NUMBER
                        , p_completion_text  VARCHAR2  DEFAULT NULL) RETURN boolean
IS
setClause varchar2(1024):=null;
stmt varchar2(2048):=null;

BEGIN

if (p_Request_id is null) then
return false;
end if;

if(p_Start_date is not null) then
	setClause :=setClause || 'Start_date =to_date('''|| to_char(p_Start_date,'MM/DD/YYYY HH:MI:SS AM') ||''',''MM/DD/YYYY HH:MI:SS AM''),';
end if;

if(p_Completion_date is not null) then
	setClause :=setClause || 'Completion_date =to_date('''|| to_char(p_Completion_date,'MM/DD/YYYY HH:MI:SS AM') ||''',''MM/DD/YYYY HH:MI:SS AM''),';
end if;

if(p_Phase_code is not null) then
	setClause :=setClause || 'Phase_code = ''' || p_Phase_code || ''', ' ;
end if;

if(p_Status_code is not null) then
	setClause :=setClause || 'Status_code = ''' || p_Status_code  || ''', ' ;
end if;

if setClause is null then
	return false;
end if;

setClause :=setClause || 'Last_update_date = ''' || p_Last_update_date  || ''', ' ;
setClause :=setClause || 'Last_updated_by= ' || p_Last_updated_by ;


stmt := 'update BIS_RS_RUN_HISTORY set ' || setClause ;
stmt := stmt || ' where   Request_id = ' || p_Request_id ;


execute immediate stmt;

if(p_completion_text is not null) then
  update BIS_RS_RUN_HISTORY
  set Completion_text = p_completion_text
  where Request_id = p_Request_id;
end if;

commit;

RETURN TRUE;

EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_RUN_HISTORY_PKG.Update_Row ' ||  sqlerrm);
     raise;

END;


PROCEDURE Delete_Row(p_last_update_date date)
IS
BEGIN

	DELETE FROM BIS_RS_RUN_HISTORY
	   WHERE Last_update_date <= p_last_update_date;

	   commit;

EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_RS_RUN_HISTORY_PKG.Delete_Row ' ||  sqlerrm);
     raise;

END;

END BIS_RS_RUN_HISTORY_PKG;

/
