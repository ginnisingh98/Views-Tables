--------------------------------------------------------
--  DDL for Package Body AST_UWQ_OPP_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_OPP_ENUMS_PVT" AS
/* $Header: ASTENOPB.pls 115.20 2004/08/10 06:40:31 rkumares ship $ */

-- Sub-Program Units

PROCEDURE ENUMERATE_OPP_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_opp_list  IEU_PUB.EnumeratorDataRecordList;
  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_bind_list2 IEU_PUB.BindVariableRecordList ;
  l_Access   varchar2(10);
  l_OrgID    number;
  l_view_name	VARCHAR2(50);
  l_ds_name	VARCHAR2(50);
  l_src_code_select VARCHAR2(2);

  CURSOR c_OPP_nodes IS
    SELECT status_code, meaning
    FROM
      as_statuses_vl
    WHERE
      enabled_flag = 'Y' and OPP_FLAG = 'Y' and OPP_OPEN_STATUS_FLAG = 'Y';
--      ORDER BY 1;

   lkp_type VARCHAR2(30) := 'AST_UWQ_LABELS';
   lkp_code VARCHAR2(30) := 'OPPS_WORK_CLASS_LABEL';
BEGIN

  /* label, view, and where for main node taken from enum table anyway */

  l_node_counter  := 0;
  l_Access := NVL(FND_PROFILE.VALUE('AS_OPP_ACCESS'), 'T');
  l_OrgID  := FND_PROFILE.VALUE('ORG_ID');


  SAVEPOINT start_opp_enumeration;

  /*
  Select meaning into l_node_label
  from fnd_lookup_values_vl
  where lookup_type = 'IEU_NODE_LABELS'
  and view_application_id = 696
  and lookup_code = 'IEU_OPPORTUNITIES_LBL';
  */

  Select meaning into l_node_label
  from ast_lookups
  where lookup_type = lkp_type
  and lookup_code = lkp_code;

  /** check the profile AST_SOURCE_UWQ_OPP. **/
  l_src_code_select := NVL(FND_PROFILE.VALUE('AST_SOURCE_UWQ_OPP'), 'N');
  IF (l_src_code_select = 'N') THEN
	l_view_name := 'AST_SALESOPP_UWQ_V';
	l_ds_name := 'AST_SALESOPP_UWQ_DS';
  ELSIF (l_src_code_select = 'P') THEN
	l_view_name := 'AST_SALESOPP_CODE_UWQ_V';
	l_ds_name := 'AST_SALESOPP_CODE_UWQ_DS';
  ELSIF (l_src_code_select = 'Y') THEN
	l_view_name := 'AST_SALESOPP_NAME_UWQ_V';
	l_ds_name := 'AST_SALESOPP_NAME_UWQ_DS';
  END IF;

  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID ';

  if (l_Access = 'O') then
  		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID ';
		l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
		l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  end if;

  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 1;

  l_node_counter := l_node_counter + 1;

-- Add another level of nodes with time line 30 DAYS
--where decision_date >= trunc(sysdate) and (decision_date - trunc(sysdate) ) <= 30

  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
                                               ' DECISION_DATE >= TRUNC(SYSDATE) AND (DECISION_DATE - TRUNC(SYSDATE)) <= 30';

	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
												   ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 30' ;
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_30_DAYS_FOR_OPP');
  l_node_label :=   fnd_message.get;
  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 30 days. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP
		l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
		l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
		l_bind_list(1).bind_var_data_type := 'NUMBER' ;

		l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
		l_bind_list(2).bind_var_value := cur_rec.status_code ;
		l_bind_list(2).bind_var_data_type := 'CHAR' ;

		l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND ' ||
												   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 30';

		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
													   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 30' ;
		end if;

		l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
		l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
		l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
		l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

		l_opp_list(l_node_counter).NODE_TYPE := 0;
		l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
		l_opp_list(l_node_counter).NODE_DEPTH := 3;
		l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	   --added by vimpi on 2nd nov/01

		l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;

		l_node_counter := l_node_counter + 1;
  END LOOP;
--
-- ***************************************
-- Add another level of nodes with time line 90 DAYS
-- ****************************************
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_90_DAYS_FOR_OPP');
  l_node_label :=   fnd_message.get;

  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
  										      ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 90';
	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
										   ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 90' ;
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 90 days. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

       l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND ' ||
	   										   	  ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 90';
		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
											   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 90' ;
		end if;

        l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
        l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
        l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

        l_opp_list(l_node_counter).NODE_TYPE := 0;
        l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_ld_list(l_node_counter).NODE_DEPTH := 2;
        l_opp_list(l_node_counter).NODE_DEPTH := 3;

	   l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;
-- ***************************************
-- Add another level of nodes with time line 6 MONTHS
-- ****************************************
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
                                               ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 180';
	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		--added by vimpi in 7th dec to lower cost
		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
									   ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 180' ;
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_6_MNTHS_FOR_OPP');
  l_node_label :=   fnd_message.get;
  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 180 days. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND
												 STATUS_CODE = :STATUS_CODE'|| ' and DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 180';

		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
											   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 180' ;
		end if;

        l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
        l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
        l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

        l_opp_list(l_node_counter).NODE_TYPE := 0;
        l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_opp_list(l_node_counter).NODE_DEPTH := 2;
        l_opp_list(l_node_counter).NODE_DEPTH := 3;
        --added by vimpi on 2nd nov/01

        l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;


-- ***************************************
-- Add another level of nodes with time line 1 Year
-- ****************************************
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
                                               ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 365';
	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
									   ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 365' ;
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_1_YEAR_FOR_OPP');
  l_node_label :=   fnd_message.get;
  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 365 days. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND
												 STATUS_CODE = :STATUS_CODE'|| ' and DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 365';

		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
											   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 365' ;
		end if;

        l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
        l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
        l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

        l_opp_list(l_node_counter).NODE_TYPE := 0;
        l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_opp_list(l_node_counter).NODE_DEPTH := 2;
        l_opp_list(l_node_counter).NODE_DEPTH := 3;

        l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';



        l_node_counter := l_node_counter + 1;

  END LOOP;


-- ***************************************
-- Add another level of nodes with time line ALL
-- ****************************************
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID  ';
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_V';
	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		--added by vimpi in 7th dec to lower cost
		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID';
	     l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_ALL_OPPS');
  l_node_label :=   fnd_message.get;
  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for All Opptys. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND ' ||
 												   ' STATUS_CODE = :STATUS_CODE';
		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
													   'STATUS_CODE = :STATUS_CODE';
		end if;

        l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESOPP_UWQ_REF_SUB_V';
        l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
        l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

        l_opp_list(l_node_counter).NODE_TYPE := 0;
        l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_opp_list(l_node_counter).NODE_DEPTH := 2;
        l_opp_list(l_node_counter).NODE_DEPTH := 3;

        l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;


  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_opp_list
  );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_opp_enumeration;
    RAISE;

END ENUMERATE_OPP_NODES;

PROCEDURE ENUMERATE_TEAM_OPP_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_opp_list  IEU_PUB.EnumeratorDataRecordList;
  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_bind_list2 IEU_PUB.BindVariableRecordList ;
  l_Access   varchar2(10);
  l_OrgID    number;
  l_view_name	VARCHAR2(50);
  l_ds_name	VARCHAR2(50);
  l_src_code_select VARCHAR2(2);

  CURSOR c_OPP_nodes IS
    SELECT status_code, meaning
    FROM
      as_statuses_vl
    WHERE
      enabled_flag = 'Y' and OPP_FLAG = 'Y' and OPP_OPEN_STATUS_FLAG = 'Y';
--      ORDER BY 1;

   lkp_type VARCHAR2(30) := 'AST_UWQ_LABELS';
   lkp_code VARCHAR2(30) := 'OPPS_TEAMWORK_CLASS_LABEL';
BEGIN

  /* label, view, and where for main node taken from enum table anyway */

  l_node_counter  := 0;

  l_Access := NVL(FND_PROFILE.VALUE('AS_OPP_ACCESS'), 'T');
  l_OrgID  := FND_PROFILE.VALUE('ORG_ID');

  SAVEPOINT start_opp_enumeration;

  Select meaning into l_node_label
  from ast_lookups
  where lookup_type = lkp_type
  and lookup_code = lkp_code;

  /** check the profile AST_SOURCE_UWQ_OPP. **/
  l_src_code_select := NVL(FND_PROFILE.VALUE('AST_SOURCE_UWQ_OPP'), 'N');
  IF (l_src_code_select = 'N') THEN
	l_view_name := 'AST_MYTEAM_SALESOPP_UWQ_V';
	l_ds_name := 'AST_MYTEAM_SALESOPP_UWQ_DS';
  ELSIF (l_src_code_select = 'P') THEN
	l_view_name := 'AST_MYTEAM_SALESOPP_CODE_UWQ_V';
	l_ds_name := 'AST_MYTEAM_SALESOPP_C_UWQ_DS';
  ELSIF (l_src_code_select = 'Y') THEN
	l_view_name := 'AST_MYTEAM_SALESOPP_NAME_UWQ_V';
	l_ds_name := 'AST_MYTEAM_SALESOPP_N_UWQ_DS';
  END IF;

  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_REF_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID ';

  if (l_Access = 'O') then
	l_bind_list(2).bind_var_name := ':ORG_ID' ;
	l_bind_list(2).bind_var_value := l_OrgID ;
	l_bind_list(2).bind_var_data_type := 'NUMBER' ;

     l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
	l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID ';
	l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  end if;

  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 1;

  l_node_counter := l_node_counter + 1;

-- Add another level of nodes with time line 30 DAYS

  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
                                               ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 30';

	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
												   ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 30' ;
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_30_DAYS_FOR_OPP');
  l_node_label :=   fnd_message.get;
  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 30 days. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP
		l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
		l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
		l_bind_list(1).bind_var_data_type := 'NUMBER' ;

		l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
		l_bind_list(2).bind_var_value := cur_rec.status_code ;
		l_bind_list(2).bind_var_data_type := 'CHAR' ;

		l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND ' ||
												   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 30';

		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
													   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 30' ;
		end if;

		l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
		l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
		l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
		l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

		l_opp_list(l_node_counter).NODE_TYPE := 0;
		l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
		l_opp_list(l_node_counter).NODE_DEPTH := 3;
		l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	   --added by vimpi on 2nd nov/01

		l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;

		l_node_counter := l_node_counter + 1;
  END LOOP;
--
-- ***************************************
-- Add another level of nodes with time line 90 DAYS
-- ****************************************
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_90_DAYS_FOR_OPP');
  l_node_label :=   fnd_message.get;

  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
  										      ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 90';
	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
										   ' DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 90' ;
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 90 days. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

       l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND ' ||
	   										   	  ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 90';
		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
											   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(SYSDATE) AND (DECISION_DATE - trunc(SYSDATE)) <= 90' ;
		end if;

        l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
        l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
        l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

        l_opp_list(l_node_counter).NODE_TYPE := 0;
        l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_ld_list(l_node_counter).NODE_DEPTH := 2;
        l_opp_list(l_node_counter).NODE_DEPTH := 3;

	   l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;
-- ***************************************
-- Add another level of nodes with time line 6 MONTHS
-- ****************************************
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
                                               ' DECISION_DATE >= trunc(sysdate) AND (DECISION_DATE - trunc(sysdate) ) <= 180';
	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		--added by vimpi in 7th dec to lower cost
		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
									   ' DECISION_DATE >= trunc(sysdate) AND (DECISION_DATE - trunc(sysdate) ) <= 180' ;
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_6_MNTHS_FOR_OPP');
  l_node_label :=   fnd_message.get;
  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 180 days. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND
												 STATUS_CODE = :STATUS_CODE'|| ' and DECISION_DATE >= trunc(sysdate) AND (DECISION_DATE - trunc(sysdate) ) <= 180';

		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
											   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(sysdate) AND (DECISION_DATE - trunc(sysdate) ) <= 180' ;
		end if;

        l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
        l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
        l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

        l_opp_list(l_node_counter).NODE_TYPE := 0;
        l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_opp_list(l_node_counter).NODE_DEPTH := 2;
        l_opp_list(l_node_counter).NODE_DEPTH := 3;
        --added by vimpi on 2nd nov/01

        l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;


-- ***************************************
-- Add another level of nodes with time line 1 Year
-- ****************************************
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
                                               ' DECISION_DATE >= trunc(sysdate) AND (DECISION_DATE - trunc(sysdate) ) <= 365';
	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
									   ' DECISION_DATE >= trunc(sysdate) AND (DECISION_DATE - trunc(sysdate) ) <= 365' ;
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_1_YEAR_FOR_OPP');
  l_node_label :=   fnd_message.get;
  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 365 days. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND
												 STATUS_CODE = :STATUS_CODE'|| ' and DECISION_DATE >= trunc(sysdate) AND (DECISION_DATE - trunc(sysdate) ) <= 365';

		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
											   ' STATUS_CODE = :STATUS_CODE AND DECISION_DATE >= trunc(sysdate) AND (DECISION_DATE - trunc(sysdate) ) <= 365' ;
		end if;

        l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
		l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
        l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
        l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

        l_opp_list(l_node_counter).NODE_TYPE := 0;
        l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_opp_list(l_node_counter).NODE_DEPTH := 2;
        l_opp_list(l_node_counter).NODE_DEPTH := 3;

        l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';



        l_node_counter := l_node_counter + 1;

  END LOOP;


-- ***************************************
-- Add another level of nodes with time line ALL
-- ****************************************
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
  l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_REF_V';
  l_opp_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID  ';
	if (l_Access = 'O') then
		l_bind_list(2).bind_var_name := ':ORG_ID' ;
		l_bind_list(2).bind_var_value := l_OrgID ;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		--added by vimpi in 7th dec to lower cost
	     l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
		l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID';
	     l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	     l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
	end if;

 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_ALL_OPPS');
  l_node_label :=   fnd_message.get;
  l_opp_list(l_node_counter).NODE_LABEL := l_node_label;
  l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
  l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
  l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_opp_list(l_node_counter).NODE_TYPE := 0;
  l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_opp_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for All Opptys. The subnodes are based on the Oppty statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_OPP_nodes LOOP
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_opp_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND ' ||
 												   ' STATUS_CODE = :STATUS_CODE';
		if (l_Access = 'O') then
			l_bind_list(3).bind_var_name := ':ORG_ID' ;
			l_bind_list(3).bind_var_value := l_OrgID ;
			l_bind_list(3).bind_var_data_type := 'NUMBER' ;

			l_Opp_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND ORG_ID = :ORG_ID AND ' ||
													   'STATUS_CODE = :STATUS_CODE';
		end if;

        l_opp_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_opp_list(l_node_counter).VIEW_NAME := l_view_name;
	   l_opp_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESOPP_UWQ_R_S_V';
        l_opp_list(l_node_counter).DATA_SOURCE := l_ds_name;
        l_opp_list(l_node_counter).MEDIA_TYPE_ID := '';

        l_opp_list(l_node_counter).NODE_TYPE := 0;
        l_opp_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_opp_list(l_node_counter).NODE_DEPTH := 2;
        l_opp_list(l_node_counter).NODE_DEPTH := 3;

        l_opp_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_opp_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_opp_list
  );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_opp_enumeration;
    RAISE;

END ENUMERATE_TEAM_OPP_NODES;

-- PL/SQL Block
END AST_UWQ_OPP_ENUMS_PVT;

/
