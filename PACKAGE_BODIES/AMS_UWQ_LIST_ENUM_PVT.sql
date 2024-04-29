--------------------------------------------------------
--  DDL for Package Body AMS_UWQ_LIST_ENUM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_UWQ_LIST_ENUM_PVT" AS
/* $Header: amsenmlb.pls 115.4 2003/03/06 06:40:08 gjoby ship $ */

-- Sub-Program Units

PROCEDURE ENUMERATE_LIST_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  ) AS

  l_node_label VARCHAR2(200);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;
  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_Profile varchar2(10) := 'N';
  l_Access  varchar2(10) := 'F';

  CURSOR c_mlist_nodes(pResourceID number) IS
    SELECT schedule_id, schedule_name, list_source_type
    FROM ams_list_sch_uwq_v
    WHERE resource_id = pResourceID
    ORDER BY 1;


BEGIN

 /* label, view, and where for main node taken from enum table anyway */
 l_node_counter := 0;

 Select meaning into l_node_label
  from ams_lookups
  where lookup_type = 'AMS_UWQ_LABELS'
  and lookup_code = 'LIST_ASSIGN_LABEL';

 --l_Profile:=NVL(fnd_profile.value('AST_MLIST_ALL_CAMPAIGNS'),'Y');
 --l_Access:= NVL(fnd_profile.value('AS_CUST_ACCESS'), 'F');

 /* 'Y' - List All Campaign,  */
 /* 'N' - List only Assigned Campaign using Campaign Assignment  */

  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).WHERE_CLAUSE :=
     ' RESOURCE_ID = :RESOURCE_ID ';
  l_ld_list(l_node_counter).VIEW_NAME := 'AMS_LIST_SCH_UWQ_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AMS_LIST_SCH_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;
  l_ld_list(l_node_counter).BIND_VARS :=IEU_PUB.SET_BIND_VAR_DATA(l_bind_list);
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';


  l_node_counter := l_node_counter + 1;

  SAVEPOINT start_list_enumeration;
  FOR cur_rec IN c_mlist_nodes(p_Resource_ID) LOOP

  l_bind_list(1).bind_var_name := ':SCHEDULE_ID' ;
  l_bind_list(1).bind_var_value := cur_rec.schedule_id ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

    l_bind_list(2).bind_var_name := ':RESOURCE_ID' ;
    l_bind_list(2).bind_var_value := P_RESOURCE_ID ;
    l_bind_list(2).bind_var_data_type := 'NUMBER' ;

    l_ld_list(l_node_counter).WHERE_CLAUSE :=
     ' RESOURCE_ID = :RESOURCE_ID and SCHEDULE_ID = :SCHEDULE_ID ';


      l_ld_list(l_node_counter).VIEW_NAME := 'AMS_LIST_ENTRIES_UWQ_V';
      l_ld_list(l_node_counter).DATA_SOURCE := 'AMS_LIST_ENTRIES_UWQ_DS';


   l_ld_list(l_node_counter).NODE_LABEL := cur_rec.schedule_name;
   l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
   l_ld_list(l_node_counter).NODE_TYPE := 0;
   l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
   l_ld_list(l_node_counter).NODE_DEPTH := 2;

   l_ld_list(l_node_counter).BIND_VARS:=IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
   l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
   l_node_counter := l_node_counter + 1;
  END LOOP ;


 /* END 'Y' - List All Campaign */

--  END LOOP;

 IEU_PUB.ADD_UWQ_NODE_DATA
 (P_RESOURCE_ID,
 P_SEL_ENUM_ID,
 l_ld_list
 );


EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK TO start_mlist_enumeration;
  RAISE;

END ENUMERATE_LIST_NODES;

-- PL/SQL Block
END AMS_UWQ_LIST_ENUM_PVT ;

/
