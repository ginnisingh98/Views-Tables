--------------------------------------------------------
--  DDL for Package Body BIS_OBJ_REFRESH_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_OBJ_REFRESH_HISTORY_PKG" AS
/*$Header: BISOBTHB.pls 120.1 2006/05/18 12:29:50 aguwalan noship $*/
PROCEDURE Insert_Row (  p_Prog_request_id                NUMBER ,
			p_Object_type                   VARCHAR2,
			p_Object_name                   VARCHAR2,
			p_Refresh_type			VARCHAR2,
			p_Object_row_count               NUMBER,
			p_Object_space_usage            NUMBER ,
			p_Tablespace_name               VARCHAR2,
			p_Free_tablespace_size          VARCHAR2,
			p_Creation_date                  DATE,
			p_Created_by                     NUMBER,
			p_Last_update_date               DATE,
			p_Last_updated_by                NUMBER
                      )
is
CURSOR C_check IS SELECT 1 from BIS_OBJ_REFRESH_HISTORY
where   Prog_request_id =p_Prog_request_id and
	OBJECT_TYPE     =p_Object_type  and
	OBJECT_NAME	=p_Object_name ;

c_check_rec C_check%rowtype;

BEGIN
--for bug 4174608
 for c_check_rec in C_check loop
	BIS_COLLECTION_UTILITIES.put_line('Following record already exist in BIS_OBJ_REFRESH_HISTORY ');
	BIS_COLLECTION_UTILITIES.put_line('Prog_request_id '||p_Prog_request_id ||' OBJECT_TYPE '|| p_Object_type||' OBJECT_NAME '||p_Object_name);
	return;
end loop;
	insert into BIS_OBJ_REFRESH_HISTORY
				(Prog_request_id ,
				Object_type      ,
				Object_name      ,
				Refresh_type	 ,
				Object_row_count ,
				Object_space_usage,
				Tablespace_name   ,
				Free_tablespace_size,
				Creation_date       ,
				Created_by          ,
				Last_update_date    ,
				Last_updated_by     )
				values
				(p_Prog_request_id ,
				p_Object_type      ,
				p_Object_name      ,
				p_Refresh_type	 ,
				p_Object_row_count ,
				p_Object_space_usage,
				p_Tablespace_name   ,
				p_Free_tablespace_size,
				p_Creation_date       ,
				p_Created_by          ,
				p_Last_update_date    ,
				p_Last_updated_by
				);


	    commit;
EXCEPTION
  when others then
     BIS_COLLECTION_UTILITIES.put_line('Prog_request_id ' || p_Prog_request_id);
     BIS_COLLECTION_UTILITIES.put_line('Object_type  '|| p_Object_type);
     BIS_COLLECTION_UTILITIES.put_line('Object_name  '||p_Object_name);
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_OBJ_REFRESH_HISTORY_PKG.Insert_Row ' ||  sqlerrm);
     raise;
END;


FUNCTION Update_Row (  p_Prog_request_id                NUMBER,
			p_new_Prog_request_id                NUMBER DEFAULT NULL,
			p_Object_type                   VARCHAR2 DEFAULT NULL,
			p_Object_name                   VARCHAR2 DEFAULT NULL,
			p_Refresh_type			VARCHAR2 DEFAULT NULL,
			p_Object_row_count               NUMBER DEFAULT NULL,
			p_Object_space_usage            NUMBER DEFAULT NULL,
			p_Tablespace_name               VARCHAR2 DEFAULT NULL,
			p_Free_tablespace_size          VARCHAR2 DEFAULT NULL,
			p_Last_update_date               DATE,
			p_Last_updated_by                NUMBER) RETURN BOOLEAN
IS

setClause varchar2(1024):=null;
stmt varchar2(2048):=null;

BEGIN

	if(p_Prog_request_id is null or p_Last_update_date is null or p_Last_updated_by  is null
           or p_Object_type is null or p_Object_name is null) THEN
		return FALSE;
	END iF;
        /*  Object Type and Object Name should not be updateable; they form the primary key
	if(p_Object_type is not null) then
		setClause :=setClause || 'Object_type = ''' || p_Object_type ||''', ';
	end if;

	if(p_Object_name is not null) then
		setClause :=setClause || 'Object_name = ''' || p_Object_name || ''', ' ;
	end if;
	*/
	if(p_Refresh_type is not null) then
		setClause :=setClause || 'Refresh_type = ''' || p_Refresh_type  || ''', ' ;
	end if;

	if(p_Object_row_count	is not null) then
		setClause :=setClause || 'Object_row_count = ' || p_Object_row_count || ', ' ;
	end if;

	if(p_Object_space_usage is not null) then
		setClause :=setClause || 'Object_space_usage = ' || p_Object_space_usage || ', ' ;
	end if;

	if(p_Tablespace_name is not null) then
		setClause :=setClause || 'Tablespace_name = ''' || p_Tablespace_name || ''', ' ;
	end if;

	if(p_Free_tablespace_size is not null) then
		setClause :=setClause || 'Free_tablespace_size = ''' || p_Free_tablespace_size || ''', ' ;
	end if;

	if(p_new_Prog_request_id is not null) then
		setClause :=setClause || 'Prog_request_id = ' || p_new_Prog_request_id || ', ' ;
	end if;


	if setClause is null then
		return false;
	end if;

	setClause :=setClause || 'Last_update_date = ''' || p_Last_update_date  || ''', ' ;
	setClause :=setClause || 'Last_updated_by= ' || p_Last_updated_by ;

	stmt := stmt || 'update BIS_OBJ_REFRESH_HISTORY set ' || setClause ;
	stmt := stmt || ' where Prog_request_id = ' || p_Prog_request_id ;
	stmt := stmt || ' and Object_type = ''' || p_Object_type ||''' ';
	stmt := stmt || ' and Object_name = ''' || p_Object_name  ||''' ' ;

	execute immediate stmt;
	commit;
	RETURN TRUE;

EXCEPTION
  when others then
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_OBJ_REFRESH_HISTORY_PKG.Update_Row ' ||  sqlerrm);
     raise;

END;

PROCEDURE Delete_Row (p_prog_req_id number)
IS
	BEGIN
	DELETE FROM BIS_OBJ_REFRESH_HISTORY
	   WHERE PROG_REQUEST_ID = p_prog_req_id;

EXCEPTION
  when others then
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in BIS_OBJ_REFRESH_HISTORY_PKG.Delete_Row ' ||  sqlerrm);
     raise;
END;


END BIS_OBJ_REFRESH_HISTORY_PKG;

/
