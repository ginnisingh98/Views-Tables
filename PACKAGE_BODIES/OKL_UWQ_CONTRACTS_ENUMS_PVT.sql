--------------------------------------------------------
--  DDL for Package Body OKL_UWQ_CONTRACTS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UWQ_CONTRACTS_ENUMS_PVT" AS
/* $Header: OKLRSWQB.pls 115.1 2002/04/23 11:26:03 pkm ship       $ */

-- Sub-Program Units

PROCEDURE ENUMERATE_CONTRACTS_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_fr_list  Ieu_Pub.EnumeratorDataRecordList;

BEGIN

  /* label, view, and where for main node taken from enum table anyway */

  SELECT meaning INTO l_node_label
  FROM fnd_lookups
  WHERE lookup_type = 'OKL_UWQ_LABELS'
  AND lookup_code = 'OKL_UWQ_CONTRACT_LABEL';

  l_fr_list(0).NODE_LABEL := l_node_label;
  l_fr_list(0).VIEW_NAME := 'OKL_WORKNODE_UWQ_UV';
  l_fr_list(0).DATA_SOURCE := 'OKL_WORKNODE_UWQ_DS';
  l_fr_list(0).MEDIA_TYPE_ID := '';
  l_fr_list(0).WHERE_CLAUSE := '';
  l_fr_list(0).NODE_TYPE := 0;
  l_fr_list(0).HIDE_IF_EMPTY := 'Y';
  l_fr_list(0).NODE_DEPTH := 1;
  l_fr_list(0).REFRESH_VIEW_NAME := 'OKL_WORKNODE_UWQ_REFRESH_UV';
  l_fr_list(0).RES_CAT_ENUM_FLAG := 'Y';

  Ieu_Pub.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_fr_list
  );

END ENUMERATE_CONTRACTS_NODES;

-- PL/SQL Block
END Okl_Uwq_Contracts_Enums_Pvt;

/
