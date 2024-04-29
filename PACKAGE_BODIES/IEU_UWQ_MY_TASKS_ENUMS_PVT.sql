--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_MY_TASKS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_MY_TASKS_ENUMS_PVT" AS
/* $Header: IEUEMTOB.pls 120.0 2005/06/02 15:48:31 appldev noship $ */

-- Sub-Program Units


PROCEDURE ENUMERATE_MY_TASKS_OWN_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_counter           NUMBER;
  l_node_pid               NUMBER;
  l_node_label             VARCHAR2(100);
  l_open_flag		VARCHAR2(1);
  l_owner_type_code1	VARCHAR2(10);
  l_owner_type_code2	VARCHAR2(10);
  l_entity		VARCHAR2(10);
  l_deleted_flag	VARCHAR2(1);
  l_lookup_type		VARCHAR2(50);
  l_application_id	NUMBER(4);
  l_lookup_code		VARCHAR2(50);

  l_tk_list  IEU_PUB.EnumeratorDataRecordList;

  CURSOR c_task_nodes_1 IS

/* New Query for Task types from Performance Team - 03/04/03 */

  SELECT TYPES.TASK_TYPE_ID TASK_TYPE_ID,TYPES.NAME TASK_TYPE
  FROM JTF_TASK_TYPES_TL TYPES
  WHERE  TYPES.LANGUAGE = USERENV('LANG')
  AND EXISTS (
    SELECT 1
    FROM JTF_TASKS_B TASKS
    WHERE tasks.open_flag = l_open_flag
    AND TASKS.OWNER_ID = P_RESOURCE_ID
    AND TASKS.OWNER_TYPE_CODE NOT IN ( l_owner_type_code1, l_owner_type_code2 )
    AND TASKS.ENTITY = l_entity
    AND NVL(TASKS.DELETED_FLAG,'N') = l_deleted_flag
    AND TASKS.TASK_TYPE_ID =TYPES.TASK_TYPE_ID )
  ORDER BY 2;


  CURSOR c_task_nodes_2 IS
    SELECT
      task_type_id, name task_type
    FROM
      jtf_task_types_vl
    WHERE
      trunc(sysdate) between trunc(nvl(start_date_active, sysdate))
	                and     trunc(nvl(end_date_active,   sysdate))
    ORDER BY 2;

BEGIN

  l_open_flag		:= 'Y';
  l_owner_type_code1	:= 'RS_GROUP';
  l_owner_type_code2	:= 'RS_TEAM';
  l_entity		:= 'TASK';
  l_deleted_flag	:= 'N';
  l_lookup_type		:= 'IEU_NODE_LABELS';
  l_application_id	:= 696;
  l_lookup_code		:= 'IEU_TASKS_MYOWN_LBL';
  l_node_counter  := 0;

  SAVEPOINT start_enumeration;
--  dbms_output.put_line('in my tasks enum proc);

  /* label, view, and where for main node taken from enum table anyway */

   Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = l_lookup_type
    and view_application_id = l_application_id
    and lookup_code = l_lookup_code;

  l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
  l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_MYOWN_V';
  l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_MYOWN_DS';
  l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_tk_list(l_node_counter).WHERE_CLAUSE := '';
  l_tk_list(l_node_counter).NODE_TYPE := 0;
  l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_tk_list(l_node_counter).NODE_DEPTH := 1;
  l_node_counter := l_node_counter + 1;

--Now build the subnodes
--Dbms_output.put_line('Node Label : '||l_node_label);

 IF (FND_PROFILE.VALUE('IEU_TASK_TYPES') = 'Y') THEN
  IF (FND_PROFILE.VALUE('IEU_CLI_UI_SHOW_ALL_NODES') = 'N') THEN

    FOR cur_rec IN c_task_nodes_1 LOOP

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_MYOWN_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_MYOWN_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE := ' TASK_TYPE_ID = ' || cur_rec.task_type_id;
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 2;
      l_node_counter := l_node_counter + 1;

--	Dbms_output.put_line('where clause : '||l_tk_list(l_node_counter).WHERE_CLAUSE);
--	insert into uwq_foo_test values ('where clause : '||l_tk_list(l_node_counter).WHERE_CLAUSE );


    END LOOP;
  ELSE

    FOR cur_rec IN c_task_nodes_2 LOOP

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_MYOWN_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_MYOWN_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE := ' TASK_TYPE_ID = ' || cur_rec.task_type_id;
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 2;
      l_node_counter := l_node_counter + 1;

--	Dbms_output.put_line('where clause : '||l_tk_list(l_node_counter).WHERE_CLAUSE);
--	insert into uwq_foo_test values ('where clause : '||l_tk_list(l_node_counter).WHERE_CLAUSE );

    END LOOP;

  END IF;
 END IF; -- Task Types

  -- Now add everything
  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_tk_list
  );

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('Exception in enumerate my tasks nodes'||sqlerrm);
    ROLLBACK TO start_enumeration;
    RAISE;

END ENUMERATE_MY_TASKS_OWN_NODES;


/* Used to refresh task nodes for Forms tree view. */
PROCEDURE REFRESH_MY_TASKS_OWN_NODES( P_RESOURCE_ID IN NUMBER, P_NODE_ID IN NUMBER, P_COUNT OUT NOCOPY NUMBER)
 AS
  l_count NUMBER:=0;
  l_where_clause VARCHAR(1000);

  l_sql_own_count varchar2(30000);

BEGIN
l_where_clause := '';
select where_clause
into   l_where_clause
from   ieu_uwq_sel_rt_nodes
where  resource_id=P_RESOURCE_ID
and    node_id=P_NODE_ID;

if (l_where_clause is NOT NULL) then
  l_where_clause := ' and '|| l_where_clause;
end if;

  BEGIN
-- Get count

   l_sql_own_count :=
		'begin select /*+ index(tasks jtf_tasks_b_n2) */ count(*)  into :l_count from jtf_tasks_b tasks '||
		'where '||
		'( tasks.owner_id = :resource_id
       and tasks.owner_type_code not in ('||''''||'RS_GROUP'||''''||','||''''||'RS_TEAM'||''''||') ) '||
    'and exists
       ( select task_status_id
             from  jtf_task_statuses_vl tsv
             where tasks.open_flag = '||''''||'Y'||''''||
           ' and   tsv.task_status_id = tasks.task_status_id )
             and tasks.entity = ' ||''''|| 'TASK' ||''''|| '
             and nvl(tasks.deleted_flag,'||''''||'N'||''''||') = '||''''||'N'||''''||l_where_clause ||' ; end; ';

	execute immediate l_sql_own_count
	USING OUT l_count, IN p_resource_id;

  EXCEPTION
        WHEN OTHERS THEN

         -- dbms_output.put_line(SQLCODE);
         -- dbms_output.put_line(SQLERRM);
          l_count := 0;
  END;

  IF (l_count IS NULL)
  THEN
      l_count := 0;
  END IF;

  P_COUNT:=l_count;

END REFRESH_MY_TASKS_OWN_NODES;

-- PL/SQL Block
END IEU_UWQ_MY_TASKS_ENUMS_PVT;

/
