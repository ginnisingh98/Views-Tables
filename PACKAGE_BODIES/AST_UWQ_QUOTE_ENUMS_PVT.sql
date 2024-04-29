--------------------------------------------------------
--  DDL for Package Body AST_UWQ_QUOTE_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_QUOTE_ENUMS_PVT" AS
/* $Header: ASTENQUB.pls 120.1 2006/01/17 21:17:25 rkumares noship $ */

-- Sub-Program Units

PROCEDURE ENUMERATE_QUOTE_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;

  l_node_counter           NUMBER;

  CURSOR c_quote_nodes IS
    SELECT status_code, meaning
    FROM
      aso_quote_statuses_vl where
	 enabled_flag = 'Y' and
	 status_code NOT IN ('ORDERED', 'ENTERED')
    ORDER BY 1;

  lkp_type VARCHAR2(30) := 'AST_UWQ_LABELS';
  lkp_code VARCHAR2(30) := 'QUOTE_WORK_CLASS_LABEL';

BEGIN

  /* label, view, and where for main node taken from enum table anyway */

  l_node_counter := 0;


  Select meaning into l_node_label
  from ast_lookups
  where lookup_type = lkp_type
  and lookup_code = lkp_code;


  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_QUOTES_UWQ_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_QUOTES_UWQ';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE NOT IN (''ORDERED'', ''ENTERED'') ';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;

  l_node_counter := l_node_counter + 1;

  SAVEPOINT start_quote_enumeration;

  FOR cur_rec IN c_quote_nodes LOOP


        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_QUOTES_UWQ_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_QUOTES_UWQ';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
        l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID+0 = :RESOURCE_ID AND  STATUS_CODE = ''' || cur_rec.status_code || '''';
        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        l_ld_list(l_node_counter).NODE_DEPTH := 2;

        l_node_counter := l_node_counter + 1;

  END LOOP;

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_quote_enumeration;
    RAISE;

END ENUMERATE_QUOTE_NODES;

-- PL/SQL Block
END AST_UWQ_QUOTE_ENUMS_PVT;

/
