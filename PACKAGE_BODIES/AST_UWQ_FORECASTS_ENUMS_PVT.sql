--------------------------------------------------------
--  DDL for Package Body AST_UWQ_FORECASTS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_FORECASTS_ENUMS_PVT" AS
/* $Header: ASTENFRB.pls 115.3 2002/02/06 12:32:34 pkm ship     $ */

-- Sub-Program Units

PROCEDURE ENUMERATE_FORECASTS_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_fr_list  IEU_PUB.EnumeratorDataRecordList;

BEGIN

  /* label, view, and where for main node taken from enum table anyway */

  Select meaning into l_node_label
  from ast_lookups
  where lookup_type = 'AST_UWQ_LABELS'
  and lookup_code = 'FORECASTS_WORK_CLASS_LABEL';

  l_fr_list(0).NODE_LABEL := l_node_label;
  l_fr_list(0).VIEW_NAME := 'AST_FORECAST_UWQ_V';
  l_fr_list(0).DATA_SOURCE := 'AST_FORECAST_UWQ_DS';
  l_fr_list(0).MEDIA_TYPE_ID := '';
  l_fr_list(0).WHERE_CLAUSE := '';
  l_fr_list(0).NODE_TYPE := 0;
  l_fr_list(0).HIDE_IF_EMPTY := '';
  l_fr_list(0).NODE_DEPTH := 1;

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_fr_list
  );

END ENUMERATE_FORECASTS_NODES;

-- PL/SQL Block
END AST_UWQ_FORECASTS_ENUMS_PVT;

/
