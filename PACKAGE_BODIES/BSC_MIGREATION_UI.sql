--------------------------------------------------------
--  DDL for Package Body BSC_MIGREATION_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MIGREATION_UI" AS
/*$Header: BSCMGUIB.pls 120.3 2005/12/16 01:42 amitgupt noship $*/

procedure createDbLink( p_dblink_sql IN varchar2,
			p_dblink_name IN varchar2,
		        p_create_status OUT NOCOPY NUMBER) IS

l_sql varchar2(1000);
l_stmt varchar2(1000);
l_stmt_remote varchar2(1000);
l_sid varchar2(100);
l_sid_remote varchar2(100);

BEGIN

        Execute immediate p_dblink_sql;

	l_sql := 'Select sysdate from dual@' ||p_dblink_name;

	execute immediate l_sql;

	p_create_status  := 0;

	-- See if db link is created to the same database (loop back dblink)
	--bug 4400763
	l_stmt := 'select name from v$database';
	l_stmt_remote := 'select name from v$database@'||p_dblink_name;
	execute immediate l_stmt into l_sid;
        execute immediate l_stmt_remote into l_sid_remote;

	if (l_sid =l_sid_remote) then
		p_create_status  := -4;
		dropDbLink(p_dblink_name);
	end if;


EXCEPTION
	WHEN OTHERS THEN
	IF sqlcode = -02019 or sqlcode = -12545 THEN  -- wrong connection information
		p_create_status  := -1;
	ELSE
		IF sqlcode = -01017 THEN --wrong username/password
			p_create_status  := -2;
	        ELSE IF sqlcode = -02011 THEN --duplicate db link name
		         p_create_status  := -3;
			 return;
                     ELSE
			p_create_status  := -100; --any other error
                      END IF;

		END IF;
	END IF;

	dropDbLink(p_dblink_name);

END createDbLink;

procedure dropDbLink(p_dblink_name IN varchar2) IS

l_sql varchar2(1000);
l_dummy date;
BEGIN
	---if(p_dblink_name == 'BSC_SRC_DBLINK_UI')
	select sysdate into l_dummy from dual;
	--rollback; -- we have to see if we can remove this roll back

	begin
          EXECUTE IMMEDIATE 'ALTER SESSION CLOSE DATABASE LINK '|| p_dblink_name;
	exception
	when others then
	null;
	end;

	l_sql := 'drop database link ' ||p_dblink_name;

	execute immediate l_sql;

EXCEPTION
 WHEN OTHERS THEN
	raise;
END;

procedure initRespTmpTable(p_process_id IN varchar2,
                           p_dblink_name IN varchar2,
                           num_rows OUT NOCOPY Number) IS

defRespTab RespMapTable;

TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(2000);

l_src_resp_id   BSC_RESPONSIBILITY_VL.RESPONSIBILITY_ID%TYPE;
l_src_resp_name BSC_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE;
l_tar_resp_id   BSC_RESPONSIBILITY_VL.RESPONSIBILITY_ID%TYPE;
l_tar_resp_name BSC_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE;

BEGIN

  l_stmt:= null;
  -- truncate the table first to remove any data for the same session
  execute immediate 'delete BSC_PMA_MIG_TMP_RESP_MAP';

  if(p_process_id is not null) then
  --this means there is some process on hold

    l_stmt:= 'SELECT
              SRC_RLIST.RESPONSIBILITY_ID,
              SRC_RLIST.RESPONSIBILITY_NAME,
	      TAR_RLIST.RESPONSIBILITY_ID,
	      TAR_RLIST.RESPONSIBILITY_NAME
	      FROM
	      (SELECT INPUT_TABLE_NAME,
	      substr(INPUT_TABLE_NAME,3,INSTR(INPUT_TABLE_NAME,''_'',1,1)-3) ROW_COUNT,
	      RESPONSIBILITY_ID,
	      RESPONSIBILITY_NAME
	      FROM bsc_db_loader_control,BSC_RESPONSIBILITY_VL@'||p_dblink_name||
              ' SRC_RESP WHERE PROCESS_ID = :1 AND INPUT_TABLE_NAME LIKE ''SR%''
	      AND SRC_RESP.RESPONSIBILITY_ID = substr(INPUT_TABLE_NAME,INSTR(INPUT_TABLE_NAME,''_'',1,1)+1)) SRC_RLIST,
	      (SELECT INPUT_TABLE_NAME,
	       substr(INPUT_TABLE_NAME,3,INSTR(INPUT_TABLE_NAME,''_'',1,1)-3) ROW_COUNT,
	       RESPONSIBILITY_ID,
	       RESPONSIBILITY_NAME
	       FROM bsc_db_loader_control,BSC_RESPONSIBILITY_VL TAR_RESP
	       WHERE PROCESS_ID =:2 AND INPUT_TABLE_NAME LIKE ''TR%''
	       AND TAR_RESP.RESPONSIBILITY_ID = substr(INPUT_TABLE_NAME,INSTR(INPUT_TABLE_NAME,''_'',1,1)+1)) TAR_RLIST
	       WHERE
	       TAR_RLIST.ROW_COUNT =SRC_RLIST.ROW_COUNT';

    -- get the configuration from bsc_db_loader_process
    OPEN cv for l_stmt using p_process_id,p_process_id;
    FETCH cv BULK COLLECT INTO defRespTab;
    CLOSE cv;

    --now put the data in the temp table
    FORALL i IN defRespTab.FIRST..defRespTab.LAST
      INSERT INTO BSC_PMA_MIG_TMP_RESP_MAP VALUES defRespTab(i);

    num_rows := defRespTab.LAST;
  else
    --this means there is no process on hold
    -- fetch all the responsibilities that map by default
    l_stmt:= 'SELECT SRC_RESP.RESPONSIBILITY_ID, SRC_RESP.RESPONSIBILITY_NAME,
             TAR_RESP.RESPONSIBILITY_ID,TAR_RESP.RESPONSIBILITY_NAME
	     FROM BSC_RESPONSIBILITY_VL@'||p_dblink_name||
              ' SRC_RESP, FND_RESPONSIBILITY@'||p_dblink_name||
             ' SRC_FND_RESP, BSC_RESPONSIBILITY_VL TAR_RESP,
	     FND_RESPONSIBILITY  TAR_FND_RESP
	     WHERE SRC_RESP.RESPONSIBILITY_ID IN
	     (SELECT RESPONSIBILITY_ID FROM BSC_USER_KPI_ACCESS@'||p_dblink_name||
              ' UNION SELECT RESPONSIBILITY_ID FROM BSC_USER_TAB_ACCESS@'||p_dblink_name||
              ' ) AND
	     SRC_RESP.RESPONSIBILITY_ID = SRC_FND_RESP.RESPONSIBILITY_ID
	     AND
	     TAR_RESP.RESPONSIBILITY_ID = TAR_FND_RESP.RESPONSIBILITY_ID
	     AND
	     SRC_FND_RESP.RESPONSIBILITY_KEY = TAR_FND_RESP.RESPONSIBILITY_KEY';

    OPEN cv for l_stmt;
    FETCH cv BULK COLLECT INTO defRespTab;
    CLOSE cv;

    --now put the data in the temp table
    FORALL i IN defRespTab.FIRST..defRespTab.LAST
      INSERT INTO BSC_PMA_MIG_TMP_RESP_MAP VALUES defRespTab(i);

    num_rows := defRespTab.LAST;
  end if;

EXCEPTION
   WHEN OTHERS THEN
       raise;
END;

-- FetchMode =='1' means selected Indicators
-- FetchMode =='2' means selected Tabs
PROCEDURE initTmpObjTable(p_process_id IN varchar2,
                          p_dblink_name IN varchar2,
                          pFetchMode IN varchar2,
                          pRespList IN varchar2) IS
l_obj_list objectList;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(2000);

BEGIN
  -- truncate the table first to remove any data for the same session
  execute immediate 'delete from BSC_PMA_MIG_TMP_OBJ_LIST';

  if(p_process_id is not null and pFetchMode = '1') then
    -- get the configuration from bsc_db_loader_process
    -- need to fetch indicators
    l_stmt:= 'Select DISTINCT K.INDICATOR, K.NAME
              FROM bsc_db_loader_control,BSC_KPIS_VL@'||p_dblink_name||
              ' K ,BSC_USER_KPI_ACCESS@'||p_dblink_name|| ' RK
                WHERE PROCESS_ID = :1
	      AND INPUT_TABLE_NAME LIKE ''KF%''
	      AND K.INDICATOR = substr(INPUT_TABLE_NAME,INSTR(INPUT_TABLE_NAME,''_'',1,1)+1) AND
              RK.INDICATOR = K.INDICATOR AND INSTR(:2,RK.RESPONSIBILITY_ID) >0';

    OPEN cv for l_stmt using p_process_id,pRespList;
    FETCH cv BULK COLLECT INTO l_obj_list;
    CLOSE cv;

    --now put the data in the temp table
    FORALL i IN l_obj_list.FIRST..l_obj_list.LAST
      INSERT INTO BSC_PMA_MIG_TMP_OBJ_LIST VALUES l_obj_list(i);
  elsif(p_process_id is not null and pFetchMode = '2') then
    -- get the configuration from bsc_db_loader_process
    -- need to fetch tabs
    l_stmt:= 'Select DISTINCT K.TAB_ID, K.NAME
              FROM bsc_db_loader_control,BSC_TABS_VL@'||p_dblink_name||
              ' K , BSC_USER_TAB_ACCESS@'||p_dblink_name|| ' RT
              WHERE PROCESS_ID = :1
              AND INPUT_TABLE_NAME LIKE ''TF%''
              AND K.TAB_ID = substr(INPUT_TABLE_NAME,INSTR(INPUT_TABLE_NAME,''_'',1,1)+1) AND
              RT.TAB_ID = K.TAB_ID AND INSTR(:2,RT.RESPONSIBILITY_ID) >0';

    OPEN cv for l_stmt using p_process_id,pRespList;
    FETCH cv BULK COLLECT INTO l_obj_list;
    CLOSE cv;

    --now put the data in the temp table
    FORALL i IN l_obj_list.FIRST..l_obj_list.LAST
      INSERT INTO BSC_PMA_MIG_TMP_OBJ_LIST VALUES l_obj_list(i);
  end if;

END;

END BSC_MIGREATION_UI;

/
