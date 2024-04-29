--------------------------------------------------------
--  DDL for Package Body IEM_INBE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_INBE_PVT" AS
/* $Header: ieminbvb.pls 120.1.12010000.3 2009/08/13 13:34:55 lkullamb ship $ */

PROCEDURE ENUMERATE_INBOUND_NODES
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
  p_user_flag              varchar2(1);
  p_acct_flag              varchar2(1);

  CURSOR c_inb_nodes_1 IS
    select a.from_name, a.email_account_id, c.resource_id
    from iem_mstemail_accounts a,iem_agents c
    where   a.email_account_id=c.email_account_id
    and c.resource_id=p_resource_id
    group by a.from_name,a.email_account_id,c.resource_id
    order by 1;

 BEGIN
 IF (FND_PROFILE.VALUE('IEU_QEN_INB_EMAIL') = 'N' ) THEN
    RETURN;
  END IF;

  l_node_counter  := 0;

  SAVEPOINT start_enumeration;

   l_def_where := ieu_pub.get_enum_res_cat(p_sel_enum_id);

   Select meaning into l_node_label
   from fnd_lookups
   where lookup_type = 'IEM_UWQ_EMAIL_LABELS'
   and lookup_code = 'IEM_INBOUND_EMAIL_LBL';

  l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
  l_tk_list(l_node_counter).VIEW_NAME := 'IEM_INBEMAIL_SUMM_V';
  l_tk_list(l_node_counter).DATA_SOURCE := 'IEM_INBOUND_EMAIL_SUMM_DS';
  l_tk_list(l_node_counter).MEDIA_TYPE_ID := 10001;
  l_tk_list(l_node_counter).WHERE_CLAUSE := '';
  l_tk_list(l_node_counter).NODE_TYPE := 0;
  l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_tk_list(l_node_counter).NODE_DEPTH := 1;
  l_tk_list(l_node_counter).BIND_VARS := '';
  l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEM_REFINBEMAIL_ACCOUNTS_V';
  l_tk_list(l_node_counter).REFRESH_VIEW_SUM_COL := 'Total';

  l_node_counter := l_node_counter + 1;

--Now build the subnodes

    FOR cur_rec IN c_inb_nodes_1 LOOP
      l_bind_list(1).bind_var_name := ':resource_id';
      l_bind_list(1).bind_var_value := p_resource_id;
      l_bind_list(1).bind_var_data_type := 'NUMBER';
      l_bind_list(2).bind_var_name := ':ACCOUNT_ID';
      l_bind_list(2).bind_var_value := cur_rec.email_account_id;
      l_bind_list(2).bind_var_data_type := 'CHAR';

 /*   whether cherry pick is enabled at user and account level or not */

       begin
/*  query to check the cherry pick flag at the user and account level*/
       select acc.cherry_pick_flag ,agents.cherry_pick_flag
       into  p_acct_flag,p_user_flag
       from iem_mstemail_accounts acc, iem_agents agents
       where acc.email_account_id=cur_rec.email_account_id
       and agents.resource_id =p_resource_id
       and acc.email_account_id = agents.email_account_id;

       exception when others then
        p_acct_flag := 'N';
        p_user_flag := 'N';
	end;

       If (p_acct_flag = 'Y' and p_user_flag = 'Y') then
/* Both user and account cherry pick enabled */
      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.from_name;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEM_QUEUEEMAIL_CHERRYPICK_v';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEM_QUEUEEMAIL_CHERRYPICK_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := 10001;
      l_tk_list(l_node_counter).WHERE_CLAUSE := l_def_where ||'and EMAIL_ACCOUNT_ID =' ||':ACCOUNT_ID';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 2;
      l_tk_list(l_node_counter).BIND_VARS := ieu_pub.set_bind_var_data(l_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEM_REFINBEMAIL_ACCOUNTS_V';
      l_tk_list(l_node_counter).REFRESH_VIEW_SUM_COL := 'Total';

      l_node_counter := l_node_counter + 1;

    else
      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.from_name;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEM_INBEMAIL_COUNTS_V';
     -- l_tk_list(l_node_counter).DATA_SOURCE := 'IEM_INBOUND_EMAIL_DS';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEM_INBOUND_ACCOUNT_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := 10001;
      l_tk_list(l_node_counter).WHERE_CLAUSE := l_def_where ||'and EMAIL_ACCOUNT_ID = ' || ':ACCOUNT_ID';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 2;
      l_tk_list(l_node_counter).BIND_VARS := ieu_pub.set_bind_var_data(l_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEM_REFINBEMAIL_ACCOUNTS_V';
      l_tk_list(l_node_counter).REFRESH_VIEW_SUM_COL := 'Total';

      l_node_counter := l_node_counter + 1;
      end if;

    END LOOP;

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_tk_list
  );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_enumeration;
    RAISE;

END ENUMERATE_INBOUND_NODES;

END IEM_INBE_PVT;

/
