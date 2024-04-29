--------------------------------------------------------
--  DDL for Package Body IEC_DEFAULT_MEDIA_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_DEFAULT_MEDIA_ENUMS_PVT" AS
/* $Header: IECENMVB.pls 115.8 2003/08/22 20:41:25 hhuang ship $ */


PROCEDURE ENUMERATE_ADV_OUTB_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS
  l_node_label		   VARCHAR2(100);
  l_tk_list                IEU_PUB.EnumeratorDataRecordList;


BEGIN

	select MEANING into l_node_label
	from
		FND_LOOKUP_VALUES_VL
	where
		LOOKUP_TYPE='IEU_NODE_LABELS'
	and 	VIEW_APPLICATION_ID=696
	and	LOOKUP_CODE='IEU_ADVANCED_OUTBOUND_LBL';

      l_tk_list(0).NODE_LABEL := l_node_label;
      l_tk_list(0).VIEW_NAME := 'IEC_ADV_OUTB_WORKNODE_UWQ_V';
      l_tk_list(0).DATA_SOURCE := 'IEC_ADV_OUTB_WORKNODE_UWQ_DS';
      l_tk_list(0).MEDIA_TYPE_ID := 10009;
      l_tk_list(0).WHERE_CLAUSE :=  '';

      l_tk_list(0).NODE_TYPE := 0;
      l_tk_list(0).HIDE_IF_EMPTY := '';
      l_tk_list(0).NODE_DEPTH := 1;
      l_tk_list(0).BIND_VARS  := '';
      l_tk_list(0).RES_CAT_ENUM_FLAG := 'Y';

  IEU_PUB.ADD_UWQ_NODE_DATA
  (
   P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_tk_list
  );

EXCEPTION
    WHEN OTHERS THEN
--    dbms_output.put_line(SQLERRM);
    ROLLBACK TO start_ao_enumeration;
    RAISE;

END ENUMERATE_ADV_OUTB_NODES;

END IEC_DEFAULT_MEDIA_ENUMS_PVT;

/
