--------------------------------------------------------
--  DDL for Package Body AST_UWQ_PLISTS_CONTS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_PLISTS_CONTS_ENUMS_PVT" as
/* $Header: ASTENPCB.pls 115.9 2004/08/10 06:41:17 rkumares noship $ */

-- Sub-Program Unit
PROCEDURE ENUMERATE_PLISTS_CONTACTS_NODE
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS
  l_node_counter           		NUMBER;
  l_node_label             		VARCHAR2(100);
  l_node_pid               		NUMBER := 3100;
  l_tk_list                		IEU_PUB.EnumeratorDataRecordList;
  l_def_where              		VARCHAR2(20000);
  l_bind_list 					IEU_PUB.BindVariableRecordList ;

  l_OrgID    number;
  l_view_name	VARCHAR2(50);
  l_ds_name	VARCHAR2(50);


  CURSOR c_contact_lists(c_resource_id IN number)  IS
  SELECT
  alh.list_name,
  alh.list_header_id,
  alh.list_source_type
  from ams_list_headers_vl alh
  where
  owner_user_id = c_resource_id
  and list_type='MANUAL' and
  list_source_type in ('CONTACT', 'CONSUMER')
  and enabled_flag = 'Y' and
  list_source='UWQ'
  order by creation_date desc;

  l_Access  varchar2(10) ;

  lkp_type VARCHAR2(30) := 'AST_UWQ_LABELS';
  lkp_code VARCHAR2(30) := 'PLIST_CONTS_WORK_CLASS_LABEL';
BEGIN
/*
--Set node counter
-- Obtain label of nodes from ast_lookup to be attached to node/sub-node.
-- choice of label, view, where clause to be taken from enum node registered table
*/

     		l_node_counter := 0;

     		Select meaning into l_node_label
          		from ast_lookups
          		where lookup_type = lkp_type
                and lookup_code = lkp_code;

   l_Access := NVL(fnd_profile.value('AS_CUST_ACCESS'), 'T');

--Build root node with common definitions given such as node label obtained, view name, data source, etc.
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID;
  l_bind_list(1).bind_var_data_type := 'NUMBER';

  l_tk_list(l_node_counter).NODE_LABEL := l_node_label;
  l_tk_list(l_node_counter).VIEW_NAME := 'AST_PLIST_NAMES_UWQ_V';
  l_tk_list(l_node_counter).DATA_SOURCE := 'AST_PLIST_NAMES_UWQ_DS';
  l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_tk_list(l_node_counter).WHERE_CLAUSE := 'list_type = ''MANUAL'' and list_source_type in (''CONTACT'', ''CONSUMER'')' ||
'and list_source = ''UWQ'' AND enabled_flag = ''Y'' and resource_id  =  :resource_id';
  l_tk_list(l_node_counter).NODE_TYPE := 0;
  l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_tk_list(l_node_counter).NODE_DEPTH := 1;
  l_tk_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list);
  l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

  l_node_counter := l_node_counter + 1;

 SAVEPOINT start_pclist_node_enumeration;
  --Now loop through and build the subnodes based on the cursor that contains the names of the lists.

    FOR cur_rec IN c_contact_lists(P_RESOURCE_ID) LOOP

-- insert the bind variable names and values into l_bind_list
--and then call the function ieu_pub.setBindVar to get the String

      l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
      l_bind_list(1).bind_var_value := P_RESOURCE_ID;
      l_bind_list(1).bind_var_data_type := 'NUMBER';
      l_bind_list(2).bind_var_name  := ':LIST_HEADER_ID';
      l_bind_list(2).bind_var_value  := cur_rec.list_header_id;
      l_bind_list(2).bind_var_data_type := 'NUMBER';

      l_tk_list(l_node_counter).NODE_LABEL := cur_rec.LIST_NAME;

	  l_tk_list(l_node_counter).WHERE_CLAUSE :=  'resource_id = :resource_id ' ||
				'and list_header_id = :list_header_id and list_type = ''MANUAL''' ||
                'and list_source = ''UWQ'' and enabled_flag = ''Y''';

	  --Now taking refresh view into account for list type views..
        l_tk_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_PLIST_REF_UWQ_V';

   	  if cur_rec.list_source_type = 'CONTACT' then

      	 l_tk_list(l_node_counter).VIEW_NAME :=  'AST_PLIST_REL_UWQ_V';
     	 l_tk_list(l_node_counter).DATA_SOURCE := 'AST_PLIST_REL_UWQ_DS';
		 l_tk_list(l_node_counter).WHERE_CLAUSE :=   l_tk_list(l_node_counter).WHERE_CLAUSE ||
		 ' and list_source_type in (''CONTACT'')';

      elsif  cur_rec.list_source_type = 'CONSUMER' then

      	 l_tk_list(l_node_counter).VIEW_NAME :=  'AST_PLIST_PERS_UWQ_V';
      	 l_tk_list(l_node_counter).DATA_SOURCE := 'AST_PLIST_PERS_UWQ_DS';
		 l_tk_list(l_node_counter).WHERE_CLAUSE :=   l_tk_list(l_node_counter).WHERE_CLAUSE ||
		 ' and list_source_type in (''CONSUMER'')';

      end if;


      /* Need to check for security */
      if l_access = 'T' then
	  l_tk_list(l_node_counter).WHERE_CLAUSE :=  l_tk_list(l_node_counter).WHERE_CLAUSE ||
		 ' and EXISTS (SELECT /*+ no_unnest */ 1 ' ||
            			' FROM AS_ACCESSES_ALL ASS ' ||
            			' WHERE ASS.SALESFORCE_ID = :resource_id ' ||
				        ' AND CUSTOMER_ID = ASS.CUSTOMER_ID) ';
      end if;

      l_tk_list(l_node_counter).MEDIA_TYPE_ID := '';
      l_tk_list(l_node_counter).NODE_TYPE := 0;
      l_tk_list(l_node_counter).HIDE_IF_EMPTY := '';
      l_tk_list(l_node_counter).NODE_DEPTH := 2;
      l_tk_list(l_node_counter).BIND_VARS  := ieu_pub.set_bind_var_data(l_bind_list);
      l_tk_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

      l_node_counter := l_node_counter + 1;

    END LOOP;

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_tk_list
  );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_pclist_node_enumeration;
    RAISE;

END ENUMERATE_PLISTS_CONTACTS_NODE;

-- PL/SQL Block
END AST_UWQ_PLISTS_CONTS_ENUMS_PVT;

/
