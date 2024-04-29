--------------------------------------------------------
--  DDL for Package Body IEU_ESCALATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_ESCALATIONS_PVT" AS
/* $Header: IEUEESVB.pls 120.0 2005/06/02 15:51:06 appldev noship $ */

PROCEDURE ENUMERATE_ESC_MYOWN_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_counter           NUMBER;
  l_node_pid               NUMBER;
  l_node_label             VARCHAR2(100);
  l_def_where              VARCHAR2(20000);
  l_tk_list                IEU_PUB.EnumeratorDataRecordList;
  l_bind_list              IEU_PUB.BindVariableRecordList;

  CURSOR c_ESC_nodes_1 IS
    SELECT /*+ index(tasks_b jtf_tasks_b_n2) */
    distinct lkups.meaning name, tasks_b.escalation_level
    from jtf_tasks_b tasks_b ,
    fnd_lookup_values_vl lkups
    WHERE tasks_b.open_flag = 'Y'
    and nvl(tasks_b.deleted_flag,'N') = 'N'
    and tasks_b.entity ='ESCALATION'
    and lkups.lookup_type = 'JTF_TASK_ESC_LEVEL'
    and lkups.lookup_code = tasks_b.escalation_level
    and tasks_b.owner_id = p_resource_id
    and tasks_b.owner_type_code = 'RS_EMPLOYEE'
    ORDER BY 1;

 CURSOR c_ESC_nodes_2 IS
    SELECT lkups.meaning name, lkups.lookup_code escalation_level
    from fnd_lookup_values_vl lkups
    WHERE lkups.lookup_type = 'JTF_TASK_ESC_LEVEL'
    ORDER BY 1;

  BEGIN

  IF (FND_PROFILE.VALUE('IEU_QEN_ESC') = 'N' ) THEN
    RETURN;
  END IF;

  l_node_counter  := 0;

  SAVEPOINT start_enumeration;


   Select meaning into l_node_label
   from fnd_lookup_values_vl
   where lookup_type = 'IEU_NODE_LABELS'
   and view_application_id = 696
   and lookup_code = 'IEU_UWQ_ESC_LBL';

  l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
  l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_ESC_MYOWN_V';
  l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_ESC_MYOWN_DS';
  l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_tk_list(l_node_counter).WHERE_CLAUSE := '';
  l_tk_list(l_node_counter).NODE_TYPE := 0;
  l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_tk_list(l_node_counter).NODE_DEPTH := 1;
  l_tk_list(l_node_counter).BIND_VARS := '';
  l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'Y';

  l_node_counter := l_node_counter + 1;

--Now build the subnodes
  IF (FND_PROFILE.VALUE('IEU_CLI_UI_SHOW_ALL_NODES') = 'N') THEN
    FOR cur_rec IN c_esc_nodes_1 LOOP

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.name;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_ESC_MYOWN_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_ESC_MYOWN_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE := 'ESCALATION_LEVEL = '||''''||cur_rec.escalation_level||'''';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 2;
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'Y';

      l_node_counter := l_node_counter + 1;

    END LOOP;

  else

    FOR cur_rec IN c_esc_nodes_2 LOOP

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.name;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_ESC_MYOWN_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_ESC_MYOWN_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE := 'ESCALATION_LEVEL = '||''''||cur_rec.escalation_level||'''';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 2;
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'Y';

      l_node_counter := l_node_counter + 1;

    END LOOP;

  end if;
  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_tk_list
  );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_enumeration;
    RAISE;

END ENUMERATE_ESC_MYOWN_NODES;

/* Used to refresh Escalation nodes for Forms tree view. */
PROCEDURE REFRESH_ESC_MYOWN_NODES( P_RESOURCE_ID IN NUMBER, P_NODE_ID IN NUMBER, P_COUNT OUT NOCOPY NUMBER)
 AS
  l_count NUMBER:=0;
  l_where_clause VARCHAR(1000);
  l_sql_count VARCHAR2(30000);
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
-- Get count 1
l_sql_count := 'begin
    SELECT /*+ index(tasks_b jtf_tasks_b_n2) */ count(*) into :l_count
    from jtf_tasks_b tasks_b ,
    jtf_task_references_b refs_b
    WHERE
    nvl(tasks_b.deleted_flag ,'||''''||'N'||''''||') <> '||''''||'Y'||''''||'
    and tasks_b.open_flag = '||''''||'Y'||''''||'
    and tasks_b.entity =  ' ||''''|| 'ESCALATION' ||''''|| '
    and refs_b.task_id(+) = tasks_b.task_id
    and tasks_b.owner_type_code = '||''''||'RS_EMPLOYEE'||''''||'
    and tasks_b.owner_id = :p_Resource_id '||l_where_clause||'; end;';

execute immediate  l_sql_count
USING OUT l_count, IN p_resource_id;

  EXCEPTION
        WHEN OTHERS THEN
          --dbms_output.put_line(SQLCODE);
          --dbms_output.put_line(SQLERRM);
          l_count := 0;
  END;
  IF (l_count IS NULL)
  THEN
      l_count := 0;
  END IF;
  --RETURN l_count;
  P_COUNT:=l_count;
END REFRESH_ESC_MYOWN_NODES;

END IEU_ESCALATIONS_PVT;

/
