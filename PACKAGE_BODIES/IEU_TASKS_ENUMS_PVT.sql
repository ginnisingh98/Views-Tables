--------------------------------------------------------
--  DDL for Package Body IEU_TASKS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_TASKS_ENUMS_PVT" AS
/* $Header: IEUENTNB.pls 120.1.12010000.3 2008/10/15 19:17:45 spamujul ship $ */

-- Sub-Program Units


PROCEDURE ENUMERATE_TASK_NODES
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
  l_sql_stmt               VARCHAR2(2000);
  l_lookup_type            VARCHAR2(2000);
  l_view_application_id    VARCHAR2(2000);
  l_lookup_code            VARCHAR2(2000);

  l_tk_list                IEU_PUB.EnumeratorDataRecordList;
  l_tk_bind_list   IEU_PUB.BindVariableRecordList;
  l_ind_own_tk_bind_list   IEU_PUB.BindVariableRecordList;
  l_ind_asg_tk_bind_list   IEU_PUB.BindVariableRecordList;
  l_grp_own_tk_bind_list   IEU_PUB.BindVariableRecordList;
  l_grp_asg_tk_bind_list   IEU_PUB.BindVariableRecordList;
  l_team_own_tk_bind_list   IEU_PUB.BindVariableRecordList;
  l_team_asg_tk_bind_list   IEU_PUB.BindVariableRecordList;


  -- 02/07/01 Type_id of 22 is 'Escalations' and Tasks team asked to eliminate these.


  -- Owned By Me
  CURSOR c_ind_own_task_nodes_1 IS
   SELECT TYPES.TASK_TYPE_ID TASK_TYPE_ID,TYPES.NAME TASK_TYPE
   FROM JTF_TASK_TYPES_TL TYPES
   WHERE EXISTS (
      SELECT 1
        FROM   JTF_TASKS_B TASKS
        WHERE  OPEN_FLAG = 'Y'
          AND TASKS.OWNER_ID = p_resource_id
          AND TASKS.OWNER_TYPE_CODE NOT IN ( 'RS_GROUP','RS_TEAM'  )
          AND TASKS.entity = 'TASK'
          AND NVL(TASKS.DELETED_FLAG,'N') = 'N'
          AND TASKS.TASK_TYPE_ID =TYPES.TASK_TYPE_ID
   )
   and types.language = userenv('lang')
   ORDER BY 2;

  -- Owned by Group
-- Begin fix for 7412700 by spamujul
-- Commented the Following code to improved the performance
 --  CURSOR c_grp_own_task_nodes_1 IS
 --  SELECT /*+ first_rows */ TYPES.TASK_TYPE_ID TASK_TYPE_ID,TYPES.NAME TASK_TYPE
 --  FROM JTF_TASK_TYPES_TL TYPES
 --  WHERE types.task_type_id in
 --    (SELECT /*+ use_nl(tasks) */  task_type_id   FROM JTF_TASKS_B TASKS
 --     WHERE OPEN_FLAG = 'Y'
 --     and TASKS.OWNER_TYPE_CODE= 'RS_GROUP'
 --     AND exists  (SELECT /*+ no_unnest index(m jtf_rs_group_members_n1) */ null
 --               FROM JTF_RS_GROUP_MEMBERS m
 --               WHERE RESOURCE_ID = p_resource_id
 --               and GROUP_ID=TASKS.OWNER_ID
 --               AND NVL(DELETE_FLAG,'N') <> 'Y' )
 --     AND TASKS.entity = 'TASK'
 --     AND NVL(TASKS.DELETED_FLAG,'N') = 'N'
 --    )
 --  and types.language = userenv('lang')
 --  ORDER BY 2;
 -- End fix for 7412700 by spamujul
 CURSOR c_grp_own_task_nodes_1 IS
  SELECT  /*+ first_rows */
        TYPES.TASK_TYPE_ID TASK_TYPE_ID,
        TYPES.NAME TASK_TYPE
  FROM    JTF_TASK_TYPES_TL TYPES
  WHERE   EXISTS
        ( SELECT    1
                FROM    JTF_RS_GROUP_MEMBERS M,
			    JTF_TASKS_B			   TASKS
          WHERE         M.RESOURCE_ID    = p_resource_id
              AND          TYPES.TASK_TYPE_ID=TASKS.TASK_TYPE_ID
              AND    NVL(M.DELETE_FLAG,'N') <> 'Y'
              AND    TASKS.OWNER_ID              =M.GROUP_ID
              AND    TASKS.OPEN_FLAG            = 'Y'
              AND    TASKS.OWNER_TYPE_CODE= 'RS_GROUP'
              AND    TASKS.ENTITY                = 'TASK'
              AND     NVL(TASKS.DELETED_FLAG,'N') = 'N')
AND TYPES.LANGUAGE = USERENV('lang')
ORDER BY 2;

-- Owned by Team added
-- Begin fix for 7412700 by spamujul
-- Commented the Following code to improved the performance
--  CURSOR c_team_own_task_nodes_1 IS
--   SELECT /*+ first_rows */ TYPES.TASK_TYPE_ID TASK_TYPE_ID,TYPES.NAME TASK_TYPE
--   FROM JTF_TASK_TYPES_TL TYPES
--   WHERE types.task_type_id in
--     (SELECT /*+ use_nl(tasks) */  task_type_id   FROM JTF_TASKS_B TASKS
--      WHERE OPEN_FLAG = 'Y'
--      and TASKS.OWNER_TYPE_CODE= 'RS_TEAM'
--      AND exists  (SELECT /*+ no_unnest index(m jtf_rs_group_members_n1) */ null
--                FROM JTF_RS_TEAM_MEMBERS m
--                WHERE TEAM_RESOURCE_ID = p_resource_id
--                and TEAM_ID=TASKS.OWNER_ID
--                AND NVL(DELETE_FLAG,'N') <> 'Y' )
--      AND TASKS.entity = 'TASK'
--      AND NVL(TASKS.DELETED_FLAG,'N') = 'N'
--     )
--   and types.language = userenv('lang')
--   ORDER BY 2;
CURSOR c_team_own_task_nodes_1 IS
SELECT  /*+ first_rows */
        TYPES.TASK_TYPE_ID TASK_TYPE_ID,
        TYPES.NAME TASK_TYPE
FROM    JTF_TASK_TYPES_TL TYPES
WHERE   EXISTS
        ( SELECT    1
                FROM    JTF_RS_TEAM_MEMBERS M,
			    JTF_TASKS_B			   TASKS
          WHERE         M.TEAM_RESOURCE_ID    = p_resource_id
              and          TYPES.TASK_TYPE_ID=TASKS.TASK_TYPE_ID
              AND    NVL(M.DELETE_FLAG,'N') <> 'Y'
              AND    TASKS.OWNER_ID              =M.TEAM_ID
              AND    TASKS.OPEN_FLAG            = 'Y'
              AND    TASKS.OWNER_TYPE_CODE= 'RS_TEAM'
              AND    TASKS.ENTITY                = 'TASK'
              AND     NVL(TASKS.DELETED_FLAG,'N') = 'N')
AND TYPES.LANGUAGE = USERENV('lang')
ORDER BY 2;
-- End fix for 7412700 by spamujul
  -- Assigned to Me


  CURSOR c_assign_ind_task_nodes_1 IS
  SELECT TYPES.TASK_TYPE_ID TASK_TYPE_ID,TYPES.NAME TASK_TYPE
  FROM JTF_TASK_TYPES_TL TYPES
  WHERE TYPES.TASK_TYPE_ID IN
       (SELECT /*+ use_nl(tasks asg) */  TASKS.TASK_TYPE_ID
               FROM JTF_TASK_ASSIGNMENTS ASG,JTF_TASKS_B TASKS
       WHERE exists
            (SELECT null
               FROM JTF_OBJECT_USAGES
              WHERE OBJECT_USER_CODE = 'RESOURCES'
              and object_code = ASG.RESOURCE_TYPE_CODE
              AND OBJECT_CODE NOT IN ( 'RS_GROUP','RS_TEAM'  ))
         AND TASKS.TASK_ID = ASG.TASK_ID
         AND TASKS.OPEN_FLAG = 'Y'
         AND TASKS.entity = 'TASK'
         and ASG.RESOURCE_ID = p_resource_id
         AND NVL(TASKS.DELETED_FLAG,'N') = 'N' )
  and types.language = userenv('lang')
  ORDER BY 2;


  -- Assigned to Group

  CURSOR c_assign_grp_task_nodes_1 IS
  SELECT TYPES.TASK_TYPE_ID TASK_TYPE_ID,TYPES.NAME TASK_TYPE
  FROM
  JTF_TASK_TYPES_TL TYPES
   WHERE TYPES.TASK_TYPE_ID IN (SELECT /*+ use_nl(tasks asg) */  TASKS.TASK_TYPE_ID
                   FROM JTF_TASK_ASSIGNMENTS ASG,JTF_TASKS_B TASKS
                  WHERE exists
                  (SELECT null
                     FROM JTF_RS_GROUP_MEMBERS
                    WHERE RESOURCE_ID = p_resource_id
                      and group_id=asg.resource_id
                      AND NVL(DELETE_FLAG,'N') <> 'Y' )
                  AND TASKS.TASK_ID = ASG.TASK_ID
                  AND TASKS.OPEN_FLAG = 'Y'
                  AND TASKS.entity = 'TASK'
                  and asg.resource_type_code='RS_GROUP'
                  AND NVL(TASKS.DELETED_FLAG,'N') = 'N' )
 and types.language = userenv('lang')
 ORDER BY 2;

    -- Assigned to TEAM added on 7/25/03 by dolee

  CURSOR c_assign_team_task_nodes_1 IS
  SELECT TYPES.TASK_TYPE_ID TASK_TYPE_ID,TYPES.NAME TASK_TYPE
  FROM
  JTF_TASK_TYPES_TL TYPES
   WHERE TYPES.TASK_TYPE_ID IN (SELECT /*+ use_nl(tasks asg) */  TASKS.TASK_TYPE_ID
                   FROM JTF_TASK_ASSIGNMENTS ASG,JTF_TASKS_B TASKS
                  WHERE exists
                  (SELECT null
                     FROM JTF_RS_TEAM_MEMBERS
                    WHERE TEAM_RESOURCE_ID = p_resource_id
                      and team_id=asg.resource_id
                      AND NVL(DELETE_FLAG,'N') <> 'Y' )
                  AND TASKS.TASK_ID = ASG.TASK_ID
                  AND TASKS.OPEN_FLAG = 'Y'
                  AND TASKS.entity = 'TASK'
                  and asg.resource_type_code='RS_TEAM'
                  AND NVL(TASKS.DELETED_FLAG,'N') = 'N' )
 and types.language = userenv('lang')
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
  IF (FND_PROFILE.VALUE('IEU_QEN_NEW_TASKS') = 'N' ) THEN
    RETURN;
  END IF;

  l_node_counter  := 0;

  SAVEPOINT start_enumeration;

   l_sql_stmt := 'Select meaning from fnd_lookup_values_vl where lookup_type = :1 and view_application_id = :2 and lookup_code = :3';

   l_lookup_type := 'IEU_NODE_LABELS';
   l_view_application_id := 696;
   l_lookup_code := 'IEU_NEW_TASKS_LBL';

   execute immediate l_sql_stmt into l_node_label using l_lookup_type,l_view_application_id,l_lookup_code;

/*   Select meaning into l_node_label
   from fnd_lookup_values_vl
   where lookup_type = 'IEU_NODE_LABELS'
   and view_application_id = 696
   and lookup_code = 'IEU_NEW_TASKS_LBL';
 */

  l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
  l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_NODE_V';
  l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_NODE_DS';
  l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_tk_list(l_node_counter).WHERE_CLAUSE := '';
  l_tk_list(l_node_counter).NODE_TYPE := 91;
  l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_tk_list(l_node_counter).NODE_DEPTH := 1;
  l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'Y';
  l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASKS_NODE_V';
  l_tk_list(l_node_counter).REFRESH_VIEW_SUM_COL := 'COUNT';
  l_tk_list(l_node_counter).WHERE_CLAUSE :=  'resource_id = :resource_id and
                                              resource_id+0 = :resource_id';

  l_node_counter := l_node_counter + 1;

--Now build the subnodes

   -- Owned by Me

    l_ind_own_tk_bind_list(1).bind_var_name  := ':resource_id';
    l_ind_own_tk_bind_list(1).bind_var_value  := p_resource_id;
    l_ind_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';


   l_lookup_type := 'IEU_NODE_LABELS';
   l_view_application_id := 696;
   l_lookup_code := 'IEU_MY_OWN_LBL';

   execute immediate l_sql_stmt into l_node_label using l_lookup_type,l_view_application_id,l_lookup_code;

/*    Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_MY_OWN_LBL'; */


    l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
    l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_IO_V';
    l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_IO_DS';
    l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_tk_list(l_node_counter).WHERE_CLAUSE :=  'resource_id = :resource_id';
    l_tk_list(l_node_counter).NODE_TYPE := 0;
    l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_tk_list(l_node_counter).NODE_DEPTH := 2;
    l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_ind_own_tk_bind_list);
    l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_IO_REF_V';

    l_node_counter := l_node_counter + 1;

   IF (FND_PROFILE.VALUE('IEU_TASK_TYPES') = 'Y') THEN
      IF (FND_PROFILE.VALUE('IEU_CLI_UI_SHOW_ALL_NODES') = 'N') THEN

      FOR cur_rec IN c_ind_own_task_nodes_1 LOOP

        l_ind_own_tk_bind_list(1).bind_var_name  := ':resource_id';
        l_ind_own_tk_bind_list(1).bind_var_value  := p_resource_id;
        l_ind_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';
        l_ind_own_tk_bind_list(2).bind_var_name  := ':task_type_id';
        l_ind_own_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
        l_ind_own_tk_bind_list(2).bind_var_data_type := 'NUMBER';

        l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
        l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_IO_V';
        l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_IO_DS';
        l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
        l_tk_list(l_node_counter).WHERE_CLAUSE := 'resource_id = :resource_id and
                                                   TASK_TYPE_ID = :task_type_id';
        l_tk_list(l_node_counter).NODE_TYPE := 0;
        l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
        l_tk_list(l_node_counter).NODE_DEPTH := 3;
        l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_ind_own_tk_bind_list);
        l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
        l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_IO_REF_V';

	l_node_counter := l_node_counter + 1;

      END LOOP;

    ELSE

      FOR cur_rec IN c_task_nodes_2 LOOP

      -- insert the bind variable names and values into l_bind_list

       l_ind_own_tk_bind_list(1).bind_var_name  := ':resource_id';
       l_ind_own_tk_bind_list(1).bind_var_value  := p_resource_id;
       l_ind_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';
       l_ind_own_tk_bind_list(2).bind_var_name  := ':task_type_id';
       l_ind_own_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
       l_ind_own_tk_bind_list(2).bind_var_data_type := 'NUMBER';

       l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
       l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_IO_V';
       l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_IO_DS';
       l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
       l_tk_list(l_node_counter).WHERE_CLAUSE :=  'resource_id = :resource_id and
                                                   TASK_TYPE_ID = :task_type_id';
       l_tk_list(l_node_counter).NODE_TYPE := 0;
       l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
       l_tk_list(l_node_counter).NODE_DEPTH := 3;
       l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_ind_own_tk_bind_list);
       l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
       l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_IO_REF_V';

       l_node_counter := l_node_counter + 1;

     END LOOP;

    END IF;
   END IF; --Task Types

    -- Assigned to Me


   l_lookup_type := 'IEU_NODE_LABELS';
   l_view_application_id := 696;
   l_lookup_code := 'IEU_MY_ASSIGN_LBL';

   execute immediate l_sql_stmt into l_node_label using l_lookup_type,l_view_application_id,l_lookup_code;

   /* Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_MY_ASSIGN_LBL'; */

    l_ind_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
    l_ind_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
    l_ind_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';

    l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
    l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_IA_V';
    l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_IA_DS';
    l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_tk_list(l_node_counter).WHERE_CLAUSE :=  'resource_id = :resource_id';
    l_tk_list(l_node_counter).NODE_TYPE := 0;
    l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_tk_list(l_node_counter).NODE_DEPTH := 2;
    l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_ind_asg_tk_bind_list);
    l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_IA_REF_V';

    l_node_counter := l_node_counter + 1;

   IF (FND_PROFILE.VALUE('IEU_TASK_TYPES') = 'Y') THEN
    IF (FND_PROFILE.VALUE('IEU_CLI_UI_SHOW_ALL_NODES') = 'N') THEN

     FOR cur_rec IN c_assign_ind_task_nodes_1 LOOP

      l_ind_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
      l_ind_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
      l_ind_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';
      l_ind_asg_tk_bind_list(2).bind_var_name  := ':task_type_id';
      l_ind_asg_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
      l_ind_asg_tk_bind_list(2).bind_var_data_type := 'NUMBER';

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_IA_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_IA_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE := 'resource_id = :resource_id and
                                                TASK_TYPE_ID = :task_type_id';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 3;
      l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_ind_asg_tk_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_IA_REF_V';

      l_node_counter := l_node_counter + 1;

     END LOOP;

    ELSE

      FOR cur_rec IN c_task_nodes_2 LOOP

      -- insert the bind variable names and values into l_bind_list

       l_ind_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
       l_ind_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
       l_ind_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';
       l_ind_asg_tk_bind_list(2).bind_var_name  := ':task_type_id';
       l_ind_asg_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
       l_ind_asg_tk_bind_list(2).bind_var_data_type := 'NUMBER';

       l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
       l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_IA_V';
       l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_IA_DS';
       l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
       l_tk_list(l_node_counter).WHERE_CLAUSE := 'resource_id = :resource_id and
                                                  TASK_TYPE_ID = :task_type_id';
       l_tk_list(l_node_counter).NODE_TYPE := 0;
       l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
       l_tk_list(l_node_counter).NODE_DEPTH := 3;
       l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_ind_asg_tk_bind_list);
       l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
       l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_IA_REF_V';

       l_node_counter := l_node_counter + 1;

     END LOOP;

   END IF;
  END IF; -- Task Types

  -- Group Owned
  -- This node will be displayed if the Profile Option valus is 'A'  - Show Groups and Teams
  -- or 'S' - Show Groups.

  IF ( (nvl(FND_PROFILE.VALUE('IEU_ENT_TASK_RES_TYPES'), 'H') = 'A') OR
       (nvl(FND_PROFILE.VALUE('IEU_ENT_TASK_RES_TYPES'), 'H') = 'S') )
  then


   l_lookup_type := 'IEU_NODE_LABELS';
   l_view_application_id := 696;
   l_lookup_code := 'IEU_GRP_OWN_LBL';

   execute immediate l_sql_stmt into l_node_label using l_lookup_type,l_view_application_id,l_lookup_code;

/*    Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_GRP_OWN_LBL'; */

    l_grp_own_tk_bind_list(1).bind_var_name  := ':resource_id';
    l_grp_own_tk_bind_list(1).bind_var_value  := p_resource_id;
    l_grp_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';

    l_grp_own_tk_bind_list(2).bind_var_name  := ':delete_flag';
    l_grp_own_tk_bind_list(2).bind_var_value  := 'N';
    l_grp_own_tk_bind_list(2).bind_var_data_type := 'CHAR';

    l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
    l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_GO_V';
    l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_GO_DS';
    l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
    -- Begin fix by spamujul for 7024226
    -- Commented the Following code in include index in the where clause
    /* l_tk_list(l_node_counter).WHERE_CLAUSE :=  ' exists ( select m.resource_id
                                                from jtf_rs_group_members m
                                                where m.group_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                                ' and m.resource_id = :resource_id)'; */
    l_tk_list(l_node_counter).WHERE_CLAUSE := ' exists ( select /*+ index(m JTF_RS_GROUP_MEMBERS_N1) */
                                                m.resource_id
						from jtf_rs_group_members m
                                                where   m.group_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
						' and m.resource_id = :resource_id) ';
    -- End  fix by spamujul for 7024226
    l_tk_list(l_node_counter).NODE_TYPE := 0;
    l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_tk_list(l_node_counter).NODE_DEPTH := 2;
    l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_grp_own_tk_bind_list);
    l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_GO_REF_V v';

    l_node_counter := l_node_counter + 1;

   IF (FND_PROFILE.VALUE('IEU_TASK_TYPES') = 'Y') THEN
    IF (FND_PROFILE.VALUE('IEU_CLI_UI_SHOW_ALL_NODES') = 'N') THEN

     FOR cur_rec IN c_grp_own_task_nodes_1 LOOP

      l_grp_own_tk_bind_list(1).bind_var_name  := ':resource_id';
      l_grp_own_tk_bind_list(1).bind_var_value  := p_resource_id;
      l_grp_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';
      l_grp_own_tk_bind_list(2).bind_var_name  := ':task_type_id';
      l_grp_own_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
      l_grp_own_tk_bind_list(2).bind_var_data_type := 'NUMBER';
      l_grp_own_tk_bind_list(3).bind_var_name  := ':delete_flag';
      l_grp_own_tk_bind_list(3).bind_var_value  := 'N';
      l_grp_own_tk_bind_list(3).bind_var_data_type := 'CHAR';

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_GO_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_GO_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE := ' exists ( select m.resource_id
                                                from jtf_rs_group_members m
                                                where m.group_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                                ' and m.resource_id = :resource_id) and
                                                TASK_TYPE_ID = :task_type_id';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 3;
      l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_grp_own_tk_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_GO_REF_V v';


      l_node_counter := l_node_counter + 1;

     END LOOP;

    ELSE

      FOR cur_rec IN c_task_nodes_2 LOOP

      -- insert the bind variable names and values into l_bind_list

       l_grp_own_tk_bind_list(1).bind_var_name  := ':resource_id';
       l_grp_own_tk_bind_list(1).bind_var_value  := p_resource_id;
       l_grp_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';
       l_grp_own_tk_bind_list(2).bind_var_name  := ':task_type_id';
       l_grp_own_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
       l_grp_own_tk_bind_list(2).bind_var_data_type := 'NUMBER';
       l_grp_own_tk_bind_list(3).bind_var_name  := ':delete_flag';
       l_grp_own_tk_bind_list(3).bind_var_value  := 'N';
       l_grp_own_tk_bind_list(3).bind_var_data_type := 'CHAR';

       l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
       l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_GO_V';
       l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_GO_DS';
       l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
       l_tk_list(l_node_counter).WHERE_CLAUSE := ' exists ( select m.resource_id
                                                from jtf_rs_group_members m
                                                where m.group_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                                ' and m.resource_id = :resource_id) and
                                                TASK_TYPE_ID = :task_type_id';
       l_tk_list(l_node_counter).NODE_TYPE := 0;
       l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
       l_tk_list(l_node_counter).NODE_DEPTH := 3;
       l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_grp_own_tk_bind_list);
       l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
       l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_GO_REF_V v';

       l_node_counter := l_node_counter + 1;

     END LOOP;
    END IF;
   END IF; -- Task Types

    -- Group Assigned

   l_lookup_type := 'IEU_NODE_LABELS';
   l_view_application_id := 696;
   l_lookup_code := 'IEU_GRP_ASSIGN_LBL';

   execute immediate l_sql_stmt into l_node_label using l_lookup_type,l_view_application_id,l_lookup_code;

  /*  Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_GRP_ASSIGN_LBL'; */

    l_grp_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
    l_grp_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
    l_grp_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';
    l_grp_asg_tk_bind_list(2).bind_var_name  := ':delete_flag';
    l_grp_asg_tk_bind_list(2).bind_var_value  := 'N';
    l_grp_asg_tk_bind_list(2).bind_var_data_type := 'CHAR';

    l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
    l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_GA_V';
    l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_GA_DS';
    l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_tk_list(l_node_counter).WHERE_CLAUSE := ' exists ( select m.resource_id
                                                from jtf_rs_group_members m
                                                where   m.group_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                               ' and m.resource_id = :resource_id) ';
    l_tk_list(l_node_counter).NODE_TYPE := 0;
    l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_tk_list(l_node_counter).NODE_DEPTH := 2;
    l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_grp_asg_tk_bind_list);
    l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_GA_REF_V v';
    l_node_counter := l_node_counter + 1;

   IF (FND_PROFILE.VALUE('IEU_TASK_TYPES') = 'Y') THEN
    IF (FND_PROFILE.VALUE('IEU_CLI_UI_SHOW_ALL_NODES') = 'N') THEN

     FOR cur_rec IN c_assign_grp_task_nodes_1 LOOP

      l_grp_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
      l_grp_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
      l_grp_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';
      l_grp_asg_tk_bind_list(2).bind_var_name  := ':task_type_id';
      l_grp_asg_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
      l_grp_asg_tk_bind_list(2).bind_var_data_type := 'NUMBER';
      l_grp_asg_tk_bind_list(3).bind_var_name  := ':delete_flag';
      l_grp_asg_tk_bind_list(3).bind_var_value  := 'N';
      l_grp_asg_tk_bind_list(3).bind_var_data_type := 'CHAR';

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_GA_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_GA_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE := ' exists ( select m.resource_id
                                                from jtf_rs_group_members m
                                                where   m.group_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                               ' and m.resource_id = :resource_id)  and
                                                TASK_TYPE_ID = :task_type_id';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 3;
      l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_grp_asg_tk_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_GA_REF_V v';

      l_node_counter := l_node_counter + 1;

     END LOOP;

    ELSE

      FOR cur_rec IN c_task_nodes_2 LOOP

      -- insert the bind variable names and values into l_bind_list

       l_grp_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
       l_grp_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
       l_grp_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';
       l_grp_asg_tk_bind_list(2).bind_var_name  := ':task_type_id';
       l_grp_asg_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
       l_grp_asg_tk_bind_list(2).bind_var_data_type := 'NUMBER';
       l_grp_asg_tk_bind_list(3).bind_var_name  := ':delete_flag';
       l_grp_asg_tk_bind_list(3).bind_var_value  := 'N';
       l_grp_asg_tk_bind_list(3).bind_var_data_type := 'CHAR';

       l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
       l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_GA_V';
       l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_GA_DS';
       l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
       l_tk_list(l_node_counter).WHERE_CLAUSE := ' exists ( select m.resource_id
                                                from jtf_rs_group_members m
                                                where   m.group_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                               ' and m.resource_id = :resource_id) and
                                                  TASK_TYPE_ID = :task_type_id';
       l_tk_list(l_node_counter).NODE_TYPE := 0;
       l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
       l_tk_list(l_node_counter).NODE_DEPTH := 3;
       l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_grp_asg_tk_bind_list);
       l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
       l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_GA_REF_V v';

       l_node_counter := l_node_counter + 1;

     END LOOP;

  END IF;
  END IF;
  end if ; -- show group


  -- Team Owned
  -- This node will be displayed if the Profile Option valus is 'A'  - Show Groups and Teams
  -- or 'ST' - Show Groups.

  IF ( (nvl(FND_PROFILE.VALUE('IEU_ENT_TASK_RES_TYPES'), 'H') = 'A') OR
       (nvl(FND_PROFILE.VALUE('IEU_ENT_TASK_RES_TYPES'), 'H') = 'ST') )
  then

   l_lookup_type := 'IEU_NODE_LABELS';
   l_view_application_id := 696;
   l_lookup_code := 'IEU_TEAM_OWN_LBL';

   execute immediate l_sql_stmt into l_node_label using l_lookup_type,l_view_application_id,l_lookup_code;

  /*  Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_TEAM_OWN_LBL'; */

    l_team_own_tk_bind_list(1).bind_var_name  := ':resource_id';
    l_team_own_tk_bind_list(1).bind_var_value  := p_resource_id;
    l_team_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';
    l_team_own_tk_bind_list(2).bind_var_name  := ':delete_flag';
    l_team_own_tk_bind_list(2).bind_var_value  := 'N';
    l_team_own_tk_bind_list(2).bind_var_data_type := 'CHAR';

    l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
    l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_TO_V';
    l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_TO_DS';
    l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_tk_list(l_node_counter).WHERE_CLAUSE :=  ' exists ( select m.team_resource_id
                                                from jtf_rs_team_members m
                                                where m.team_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                                ' and m.team_resource_id = :resource_id)';
    l_tk_list(l_node_counter).NODE_TYPE := 0;
    l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_tk_list(l_node_counter).NODE_DEPTH := 2;
    l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_team_own_tk_bind_list);
    l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_TO_REF_V';

    l_node_counter := l_node_counter + 1;

   IF (FND_PROFILE.VALUE('IEU_TASK_TYPES') = 'Y') THEN
    IF (FND_PROFILE.VALUE('IEU_CLI_UI_SHOW_ALL_NODES') = 'N') THEN

     FOR cur_rec IN c_team_own_task_nodes_1 LOOP

      l_team_own_tk_bind_list(1).bind_var_name  := ':resource_id';
      l_team_own_tk_bind_list(1).bind_var_value  := p_resource_id;
      l_team_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';
      l_team_own_tk_bind_list(2).bind_var_name  := ':task_type_id';
      l_team_own_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
      l_team_own_tk_bind_list(2).bind_var_data_type := 'NUMBER';
      l_team_own_tk_bind_list(3).bind_var_name  := ':delete_flag';
      l_team_own_tk_bind_list(3).bind_var_value  := 'N';
      l_team_own_tk_bind_list(3).bind_var_data_type := 'CHAR';

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_TO_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_TO_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE :=  ' exists ( select m.team_resource_id
                                                   from jtf_rs_team_members m
                                                   where m.team_id = owner_id
                                                   and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                                 ' and m.team_resource_id = :resource_id) and
                                                   TASK_TYPE_ID = :task_type_id';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 3;
      l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_team_own_tk_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_TO_REF_V';


      l_node_counter := l_node_counter + 1;

     END LOOP;

    ELSE

      FOR cur_rec IN c_task_nodes_2 LOOP

      -- insert the bind variable names and values into l_bind_list

       l_team_own_tk_bind_list(1).bind_var_name  := ':resource_id';
       l_team_own_tk_bind_list(1).bind_var_value  := p_resource_id;
       l_team_own_tk_bind_list(1).bind_var_data_type := 'NUMBER';
       l_team_own_tk_bind_list(2).bind_var_name  := ':task_type_id';
       l_team_own_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
       l_team_own_tk_bind_list(2).bind_var_data_type := 'NUMBER';
       l_team_own_tk_bind_list(3).bind_var_name  := ':delete_flag';
       l_team_own_tk_bind_list(3).bind_var_value  := 'N';
       l_team_own_tk_bind_list(3).bind_var_data_type := 'CHAR';

       l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
       l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_TO_V';
       l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_TO_DS';
       l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE :=  ' exists ( select m.team_resource_id
                                                   from jtf_rs_team_members m
                                                   where m.team_id = owner_id
                                                   and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                                 ' and m.team_resource_id = :resource_id) and
                                                   TASK_TYPE_ID = :task_type_id';
       l_tk_list(l_node_counter).NODE_TYPE := 0;
       l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
       l_tk_list(l_node_counter).NODE_DEPTH := 3;
       l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_team_own_tk_bind_list);
       l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
       l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_TO_REF_V';

       l_node_counter := l_node_counter + 1;

     END LOOP;

    END IF;
   END IF; -- Task Types

    -- Team Assigned

   l_lookup_type := 'IEU_NODE_LABELS';
   l_view_application_id := 696;
   l_lookup_code := 'IEU_TEAM_ASSIGN_LBL';

   execute immediate l_sql_stmt into l_node_label using l_lookup_type,l_view_application_id,l_lookup_code;


/*    Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_TEAM_ASSIGN_LBL'; */

    l_team_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
    l_team_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
    l_team_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';
    l_team_asg_tk_bind_list(2).bind_var_name  := ':delete_flag';
    l_team_asg_tk_bind_list(2).bind_var_value  := 'N';
    l_team_asg_tk_bind_list(2).bind_var_data_type := 'CHAR';

    l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
    l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_TA_V';
    l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_TA_DS';
    l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_tk_list(l_node_counter).WHERE_CLAUSE :=  ' exists ( select m.team_resource_id
                                                from jtf_rs_team_members m
                                                where m.team_id = owner_id
                                                and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                              ' and m.team_resource_id = :resource_id)';
    l_tk_list(l_node_counter).NODE_TYPE := 0;
    l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_tk_list(l_node_counter).NODE_DEPTH := 2;
    l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_team_asg_tk_bind_list);
    l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_TA_REF_V';
    l_node_counter := l_node_counter + 1;

   IF (FND_PROFILE.VALUE('IEU_TASK_TYPES') = 'Y') THEN
    IF (FND_PROFILE.VALUE('IEU_CLI_UI_SHOW_ALL_NODES') = 'N') THEN

     FOR cur_rec IN c_assign_team_task_nodes_1 LOOP

      l_team_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
      l_team_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
      l_team_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';
      l_team_asg_tk_bind_list(2).bind_var_name  := ':task_type_id';
      l_team_asg_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
      l_team_asg_tk_bind_list(2).bind_var_data_type := 'NUMBER';
      l_team_asg_tk_bind_list(3).bind_var_name  := ':delete_flag';
      l_team_asg_tk_bind_list(3).bind_var_value  := 'N';
      l_team_asg_tk_bind_list(3).bind_var_data_type := 'CHAR';

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_TA_V';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_TA_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).WHERE_CLAUSE :=  ' exists ( select m.team_resource_id
                                                   from jtf_rs_team_members m
                                                   where m.team_id = owner_id
                                                   and nvl(delete_flag,'||''''||'N'||''''||') = '||':delete_flag'||
                                                 ' and m.team_resource_id = :resource_id) and
                                                   TASK_TYPE_ID = :task_type_id';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 3;
      l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_team_asg_tk_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_TA_REF_V';

      l_node_counter := l_node_counter + 1;

     END LOOP;

    ELSE

      FOR cur_rec IN c_task_nodes_2 LOOP

      -- insert the bind variable names and values into l_bind_list

       l_team_asg_tk_bind_list(1).bind_var_name  := ':resource_id';
       l_team_asg_tk_bind_list(1).bind_var_value  := p_resource_id;
       l_team_asg_tk_bind_list(1).bind_var_data_type := 'NUMBER';
       l_team_asg_tk_bind_list(2).bind_var_name  := ':task_type_id';
       l_team_asg_tk_bind_list(2).bind_var_value  := cur_rec.task_type_id;
       l_team_asg_tk_bind_list(2).bind_var_data_type := 'NUMBER';
       l_team_asg_tk_bind_list(3).bind_var_name  := ':delete_flag';
       l_team_asg_tk_bind_list(3).bind_var_value  := 'N';
       l_team_asg_tk_bind_list(3).bind_var_data_type := 'CHAR';

       l_tk_list(l_node_counter).NODE_LABEL := cur_rec.task_type;
       l_tk_list(l_node_counter).VIEW_NAME := 'IEU_UWQ_TASKS_TA_V';
       l_tk_list(l_node_counter).DATA_SOURCE := 'IEU_UWQ_TASKS_TA_DS';
       l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
       l_tk_list(l_node_counter).WHERE_CLAUSE :=  ' exists ( select m.team_resource_id
                                                   from jtf_rs_team_members m
                                                   where m.team_id = owner_id
                                                   and nvl(delete_flag,'||''''||'N'||''''||') = '|| ':delete_flag'||
                                                 ' and m.team_resource_id = :resource_id) and
                                                   TASK_TYPE_ID = :task_type_id';
       l_tk_list(l_node_counter).NODE_TYPE := 0;
       l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
       l_tk_list(l_node_counter).NODE_DEPTH := 3;
       l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_team_asg_tk_bind_list);
       l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
       l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEU_UWQ_TASK_TA_REF_V';

       l_node_counter := l_node_counter + 1;

     END LOOP;

  END IF;
  END IF;
  end if ; -- show team


  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_tk_list
  );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_enumeration;
    RAISE;

END ENUMERATE_TASK_NODES;

END IEU_TASKS_ENUMS_PVT;

/
