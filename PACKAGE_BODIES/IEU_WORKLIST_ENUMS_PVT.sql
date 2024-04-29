--------------------------------------------------------
--  DDL for Package Body IEU_WORKLIST_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WORKLIST_ENUMS_PVT" AS
/* $Header: IEUENWLB.pls 120.0 2005/06/02 15:52:22 appldev noship $ */

PROCEDURE ENUMERATE_WORKLIST_NODES
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

  l_wl_list                IEU_PUB.EnumeratorDataRecordList;
  l_bind_list              IEU_PUB.BindVariableRecordList;
  l_ind_own_bind_list      IEU_PUB.BindVariableRecordList;
  l_ind_asg_bind_list      IEU_PUB.BindVariableRecordList;
  l_grp_own_bind_list      IEU_PUB.BindVariableRecordList;
  l_grp_asg_bind_list      IEU_PUB.BindVariableRecordList;

BEGIN

  IF (FND_PROFILE.VALUE('IEU_QEN_WORKLIST') = 'N' ) THEN
    RETURN;
  END IF;

  l_node_counter  := 0;

  SAVEPOINT start_enumeration;

   Select meaning into l_node_label
   from fnd_lookup_values_vl
   where lookup_type = 'IEU_NODE_LABELS'
   and view_application_id = 696
   and lookup_code = 'IEU_WORKLIST_LBL';

  l_bind_list(1).bind_var_name  := ':owner_id';
  l_bind_list(1).bind_var_value := p_resource_id;
  l_bind_list(1).bind_var_data_type :='NUMBER';
  l_bind_list(2).bind_var_name  := ':assignee_id';
  l_bind_list(2).bind_var_value  := p_resource_id;
  l_bind_list(2).bind_var_data_type := 'NUMBER';

  l_wl_list(l_node_counter).NODE_LABEL := l_node_label;
  l_wl_list(l_node_counter).VIEW_NAME := 'IEU_UWQM_WL_NODE_V';
  l_wl_list(l_node_counter).DATA_SOURCE := 'IEU_UWQM_WL_NODE_DS';
  l_wl_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_wl_list(l_node_counter).WHERE_CLAUSE := 'resource_id = :owner_id or resource_id = :assignee_id';
  l_wl_list(l_node_counter).NODE_TYPE := 1;
  l_wl_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_wl_list(l_node_counter).NODE_DEPTH := 1;
  l_wl_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_bind_list);
  l_wl_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

/*

  l_node_counter := l_node_counter + 1;

--Now build the subnodes

    -- Owned by Me

    Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_MY_OWN_LBL';

    l_ind_own_bind_list(1).bind_var_name  := ':owner_id';
    l_ind_own_bind_list(1).bind_var_value := p_resource_id;
    l_ind_own_bind_list(1).bind_var_data_type :='NUMBER';

    l_wl_list(l_node_counter).NODE_LABEL := l_node_label;
    l_wl_list(l_node_counter).VIEW_NAME := 'IEU_UWQM_WORKLIST_V';
    l_wl_list(l_node_counter).DATA_SOURCE := 'IEU_UWQM_WORKLIST_DS';
    l_wl_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_wl_list(l_node_counter).WHERE_CLAUSE :=  ' owner_type = '||''''||'RS_INDIVIDUAL'||''''||
                                                ' and owner_id = :owner_id and (status_id <> 3 or status_id <> 4) ';
    l_wl_list(l_node_counter).NODE_TYPE := 2;
    l_wl_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_wl_list(l_node_counter).NODE_DEPTH := 2;
    l_wl_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_ind_own_bind_list);
    l_wl_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_node_counter := l_node_counter + 1;


    -- Assigned to Me

    Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_MY_ASSIGN_LBL';

    l_ind_asg_bind_list(1).bind_var_name  := ':assignee_id';
    l_ind_asg_bind_list(1).bind_var_value  := p_resource_id;
    l_ind_asg_bind_list(1).bind_var_data_type := 'NUMBER';

    l_wl_list(l_node_counter).NODE_LABEL := l_node_label;
    l_wl_list(l_node_counter).VIEW_NAME := 'IEU_UWQM_WORKLIST_V';
    l_wl_list(l_node_counter).DATA_SOURCE := 'IEU_UWQM_WORKLIST_DS';
    l_wl_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_wl_list(l_node_counter).WHERE_CLAUSE := 'assignee_type = '||''''||'RS_INDIVIDUAL'||''''||
                                                'and assignee_id = :assignee_id and (status_id <> 3 or status_id <> 4)';
    l_wl_list(l_node_counter).NODE_TYPE := 3;
    l_wl_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_wl_list(l_node_counter).NODE_DEPTH := 2;
    l_wl_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_ind_asg_bind_list);
    l_wl_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_node_counter := l_node_counter + 1;

    -- Owned by My Groups

    Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_GRP_OWN_LBL';

    l_grp_own_bind_list(1).bind_var_name  := ':owner_id';
    l_grp_own_bind_list(1).bind_var_value := p_resource_id;
    l_grp_own_bind_list(1).bind_var_data_type :='NUMBER';


    l_wl_list(l_node_counter).NODE_LABEL := l_node_label;
    l_wl_list(l_node_counter).VIEW_NAME := 'IEU_UWQM_WORKLIST_V';
    l_wl_list(l_node_counter).DATA_SOURCE := 'IEU_UWQM_WORKLIST_DS';
    l_wl_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_wl_list(l_node_counter).WHERE_CLAUSE := 'owner_type = '||''''||'RS_GROUP'||''''||' and owner_id in
        ( select group_id from jtf_rs_group_members where resource_id= :owner_id ) and (status_id <> 3 or status_id <> 4) ';
    l_wl_list(l_node_counter).NODE_TYPE := 4;
    l_wl_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_wl_list(l_node_counter).NODE_DEPTH := 2;
    l_wl_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_grp_own_bind_list);
    l_wl_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_node_counter := l_node_counter + 1;

    -- Assigned To My Groups

    Select meaning into l_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = 'IEU_GRP_ASSIGN_LBL';

    l_grp_asg_bind_list(1).bind_var_name  := ':assignee_id';
    l_grp_asg_bind_list(1).bind_var_value  := p_resource_id;
    l_grp_asg_bind_list(1).bind_var_data_type := 'NUMBER';

    l_wl_list(l_node_counter).NODE_LABEL := l_node_label;
    l_wl_list(l_node_counter).VIEW_NAME := 'IEU_UWQM_WORKLIST_V';
    l_wl_list(l_node_counter).DATA_SOURCE := 'IEU_UWQM_WORKLIST_DS';
    l_wl_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_wl_list(l_node_counter).WHERE_CLAUSE := 'assignee_type = '||''''||'RS_GROUP'||''''||' and assignee_id in
        ( select group_id from jtf_rs_group_members where resource_id= :assignee_id ) and (status_id <> 3 or status_id <> 4) ';
    l_wl_list(l_node_counter).NODE_TYPE := 5;
    l_wl_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_wl_list(l_node_counter).NODE_DEPTH := 2;
    l_wl_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_grp_asg_bind_list);
    l_wl_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_node_counter := l_node_counter + 1;

*/

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_wl_list
  );


END ENUMERATE_WORKLIST_NODES;

PROCEDURE REFRESH_WORKLIST_NODES( P_RESOURCE_ID IN NUMBER, P_NODE_ID IN NUMBER, X_COUNT OUT NOCOPY NUMBER)
 AS

 l_curr_count NUMBER;
-- l_ind_asg_count NUMBER;
-- l_grp_own_count NUMBER;
-- l_grp_asg_count NUMBER;
 l_node_type     NUMBER(10);
 l_owner_type_ind    varchar2(25);
 l_owner_type_grp    varchar2(25);
 l_count         number(20) := 0;

 BEGIN

 l_owner_type_ind := 'RS_INDIVIDUAL';
 l_owner_type_grp := 'RS_GROUP';
 x_count := 0;

 select node_type
 into   l_node_type
 from   ieu_uwq_sel_rt_nodes
 where  resource_id=P_RESOURCE_ID
 and    node_id=P_NODE_ID;

 l_count := IEU_UWQ_GET_NEXT_WORK_PVT.GET_WORKLIST_QUEUE_COUNT(p_resource_id, 0, l_node_type);
 x_count := x_count + l_count;
 l_count := 0;

 l_count := IEU_UWQ_GET_NEXT_WORK_PVT.GET_WORKLIST_QUEUE_COUNT(p_resource_id, 1, l_node_type);
 x_count := x_count + l_count;
 l_count := 0;

 l_count := IEU_UWQ_GET_NEXT_WORK_PVT.GET_WORKLIST_QUEUE_COUNT(p_resource_id, 2, l_node_type);
 x_count := x_count + l_count;

/*

 if l_node_type = 1 then
   begin
     select count(*)
     into  x_count
     from ieu_uwqm_items where
      (((owner_id in (select group_id from jtf_rs_group_members where
                 resource_id=p_resource_id ) and owner_type=l_owner_type_grp)
     OR (owner_id=p_resource_id AND owner_type = l_owner_type_ind))
     OR
      ((assignee_id in (select group_id from jtf_rs_group_members where
        resource_id=p_resource_id ) and assignee_type=l_owner_type_grp)
     OR (assignee_id=p_resource_id AND assignee_type = l_owner_type_ind)))
     and status_id not in (3,4);
exception
     when no_data_found then null;
   end;
 end if;


   if ( (l_node_type = 1) or (l_node_type = 2) )
   then
      REFRESH_IND_OWN_WL_NODES(P_RESOURCE_ID, L_CURR_COUNT);
      x_count := x_count + l_curr_count;
   end if ;

   if ( (l_node_type = 1) or (l_node_type = 3) )
   then
      REFRESH_IND_ASG_WL_NODES(P_RESOURCE_ID, L_CURR_COUNT);
      x_count := x_count + l_curr_count;
   end if;

   if ( (l_node_type = 1) or (l_node_type = 4) )
   then
      REFRESH_GRP_OWN_WL_NODES(P_RESOURCE_ID, L_CURR_COUNT);
      x_count := x_count + l_curr_count;
   end if;

   if ( (l_node_type = 1) or (l_node_type = 5) )
   then
      REFRESH_GRP_ASG_WL_NODES(P_RESOURCE_ID, L_CURR_COUNT);
      x_count := x_count + l_curr_count;
   end if;
*/

END REFRESH_WORKLIST_NODES;


PROCEDURE REFRESH_IND_OWN_WL_NODES(P_RESOURCE_ID IN NUMBER, X_IND_OWN_COUNT OUT NOCOPY NUMBER)
AS

BEGIN

   select count(*)
   into   x_ind_own_count
--   from   IEU_UWQ_WORKLIST_V
   from   ieu_uwqm_items
   where  owner_type = 'RS_INDIVIDUAL'
   and    owner_id = p_resource_id
   and    (status_id <> 3 or status_id <> 4);

END REFRESH_IND_OWN_WL_NODES;


PROCEDURE REFRESH_GRP_OWN_WL_NODES(P_RESOURCE_ID IN NUMBER, X_GRP_OWN_COUNT OUT NOCOPY NUMBER)
AS

BEGIN

   select count(*)
   into   x_grp_own_count
   from   ieu_uwqm_items
   where  owner_type ='RS_GROUP'
   and    owner_id in
          (
           select group_id from jtf_rs_group_members
           where resource_id= p_resource_id
          )
   and    (status_id <> 3 or status_id <> 4);

END REFRESH_GRP_OWN_WL_NODES;

PROCEDURE REFRESH_IND_ASG_WL_NODES(P_RESOURCE_ID IN NUMBER, X_IND_ASG_COUNT OUT NOCOPY NUMBER)
AS

BEGIN

   select count(*)
   into   x_ind_asg_count
   from   ieu_uwqm_items
   where  assignee_type ='RS_INDIVIDUAL'
   and    assignee_id = p_resource_id
   and    (status_id <> 3 or status_id <> 4);

END REFRESH_IND_ASG_WL_NODES;

PROCEDURE REFRESH_GRP_ASG_WL_NODES(P_RESOURCE_ID IN NUMBER, X_GRP_ASG_COUNT OUT NOCOPY NUMBER)
AS

BEGIN

   select count(*)
   into   x_grp_asg_count
   from   ieu_uwqm_items
   where
   assignee_type = 'RS_GROUP'
   and assignee_id in
       (
          select group_id from jtf_rs_group_members
          where resource_id= p_resource_id
       )
   and  (status_id <> 3 or status_id <> 4);

END  REFRESH_GRP_ASG_WL_NODES;


END IEU_WORKLIST_ENUMS_PVT;

/
