--------------------------------------------------------
--  DDL for Package Body IEM_ACQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ACQ_PVT" AS
/* $Header: iemacqvb.pls 120.1 2005/10/26 16:34:03 rtripath noship $ */

PROCEDURE ENUMERATE_ACQUIRED_NODES
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


  CURSOR c_inb_nodes_1 IS
    select a.from_name,b.resource_id,b.email_account_id
    from iem_mstemail_accounts a,iem_agents b
    where a.email_account_id=b.email_account_id
      and   b.resource_id=p_resource_id
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
   and lookup_code = 'IEM_ACQUIRED_EMAIL_LBL';

  l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
  l_tk_list(l_node_counter).VIEW_NAME := 'IEM_ACQEMAIL_DTL_V';
  l_tk_list(l_node_counter).DATA_SOURCE := 'IEM_ACQD_EMAIL_DS';
  l_tk_list(l_node_counter).MEDIA_TYPE_ID := 10008;
  l_tk_list(l_node_counter).WHERE_CLAUSE := '';
  l_tk_list(l_node_counter).NODE_TYPE := 0;
  l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_tk_list(l_node_counter).NODE_DEPTH := 1;
  l_tk_list(l_node_counter).BIND_VARS := '';
  l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEM_REFACQEMAIL_ACCOUNTS_V';
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

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.from_name;
      l_tk_list(l_node_counter).VIEW_NAME := 'IEM_ACQEMAIL_DTL_V';
     -- l_tk_list(l_node_counter).DATA_SOURCE := 'IEM_ACQ_EMAIL_DS';
      l_tk_list(l_node_counter).DATA_SOURCE := 'IEM_ACQ_ACCOUNT_DS';
      l_tk_list(l_node_counter).MEDIA_TYPE_ID := 10008;
      l_tk_list(l_node_counter).WHERE_CLAUSE := l_def_where ||'and EMAIL_ACCOUNT_ID = ' || ':ACCOUNT_ID';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 2;
      l_tk_list(l_node_counter).BIND_VARS := ieu_pub.set_bind_var_data(l_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'IEM_REFACQEMAIL_ACCOUNTS_V';
      l_tk_list(l_node_counter).REFRESH_VIEW_SUM_COL := 'Total';

      l_node_counter := l_node_counter + 1;

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

END ENUMERATE_ACQUIRED_NODES;

END IEM_ACQ_PVT;

/
