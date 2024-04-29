--------------------------------------------------------
--  DDL for Package Body AST_UWQ_LEADS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_LEADS_ENUMS_PVT" AS
/* $Header: ASTENLDB.pls 120.1 2006/03/16 12:21:45 solin noship $ */

-- Sub-Program Units



PROCEDURE ENUMERATE_LEADS_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(1000);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;

  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_prior_days             VARCHAR2(10) ;

  -- SOLIN, bug 5094263
  CURSOR c_get_node_label(c_lookup_type VARCHAR2, c_lookup_code VARCHAR2) IS
    Select meaning
    from ast_lookups
    where lookup_type = c_lookup_type
    and lookup_code = c_lookup_code;
  -- SOLIN, end bug 5094263

    CURSOR c_lead_nodes IS
    SELECT status_code, meaning
    FROM
      as_statuses_vl
    WHERE
      enabled_flag = 'Y' and LEAD_FLAG = 'Y' and OPP_OPEN_STATUS_FLAG = 'Y'
    ORDER BY 1;

   /* Removed  the USAGE indicator check
     changes made by vimpi on 19th october 20001
     CURSOR c_lead_nodes IS
     select status_code,meaning
     from as_statuses_vl
     where enabled_flag = 'Y'
     and lead_flag = 'Y'
     and opp_open_status_flag = 'Y'
     and usage_indicator in ('ALL','OS','PRM')
     order by 1 ;
   */

BEGIN

  /* label, view, and where for main node taken from enum table anyway */

  l_node_counter := 0;
  l_prior_days := NVL(fnd_profile.value('AST_DEFAULT_PRIOR_DAYS'), '30');

  SAVEPOINT start_lead_enumeration;

-- ***************************************
-- swkhanna 9/3
-- Base Node 'My Leads (Owner)' will be defaulted to 30 DAYS
-- ***************************************

  -- SOLIN, bug 5094263
  OPEN c_get_node_label('AST_UWQ_LABELS', 'LEADS_WORK_CLASS_LABEL');
  FETCH c_get_node_label INTO l_node_label;
  CLOSE c_get_node_label;
  -- SOLIN, end bug 5094263

  -- swkhanna 9/3
--  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
--  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
 -- l_bind_list(1).bind_var_data_type := 'NUMBER' ;
  -- swkhanna 9/3

  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
  --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
-- swkhanna 9/3
  -- added by vimpi on 7th dec to decrease cost
  -- 4/29/03 commented by swkhanna
  --  l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND  (sysdate - last_update_date) <= 30';
  -- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	 l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 30)';
-- swkhanna 9/3
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;

  l_node_counter := l_node_counter + 1;


-- ***************************************
-- swkhanna 9/5
-- Add another level of nodes with time line 30 DAYS
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_30_DAYS');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
    --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	 l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
-- l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '|| ' (sysdate - last_update_date) <= 30';
-- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
    l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 30)';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 30 days. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
		--3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
		  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
--added by vimpi on 7th december to lower the cost

       -- l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE' || ' and (sysdate - last_update_date) <= 30';

-- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
    l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE AND (creation_date >= sysdate - 30)';

        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        l_ld_list(l_node_counter).NODE_DEPTH := 3;
	   --added by vimpi on 2nd nov/01

	   l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;
--
-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line 90 DAYS
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_90_DAYS');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
    --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	 l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  --l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '|| ' (sysdate - last_update_date) <= 90';

  -- 4/29 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	 l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID  AND (creation_date >= sysdate - 90)';

  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 90 days. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
		--3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
		  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
--added by vimpi on 7th december to lower the cost

 --l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE' || ' and (sysdate - last_update_date) <= 90';

-- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
  l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE AND (creation_date >= sysdate - 90)';

        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_ld_list(l_node_counter).NODE_DEPTH := 2;
        l_ld_list(l_node_counter).NODE_DEPTH := 3;
	   --added by vimpi on 2nd nov/01

	   l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;
-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line 6 MONTHS
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_6_MNTHS');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
    --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	 l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  --l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '|| '(sysdate - last_update_date) <= 180';

  -- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	 l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 180)';

  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 180 days. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
		--3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
		  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
--added by vimpi on 7th december to lower the cost

--        l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE'|| ' and (sysdate - last_update_date) <= 180';

-- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
    l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE AND (creation_date >= sysdate - 180)';

        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_ld_list(l_node_counter).NODE_DEPTH := 2;
        l_ld_list(l_node_counter).NODE_DEPTH := 3;
        --added by vimpi on 2nd nov/01

        l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';



        l_node_counter := l_node_counter + 1;

  END LOOP;


-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line 1 Year
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_1_YEAR');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
    --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	 l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
--  l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '|| '(sysdate - last_update_date) <= 365';

-- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
    l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 365)';

  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 365 days. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
		--3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
		  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
--added by vimpi on 7th december to lower the cost

        --l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE'|| ' and (sysdate - last_update_date) <= 365';

 -- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	  l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE AND (creation_date >= sysdate - 365)';

        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_ld_list(l_node_counter).NODE_DEPTH := 2;
        l_ld_list(l_node_counter).NODE_DEPTH := 3;
        --added by vimpi on 2nd nov/01

        l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';



        l_node_counter := l_node_counter + 1;

  END LOOP;


-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line ALL
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_ALL_LEADS');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
    --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	 l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID  ';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;

  ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for All Leads. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
        l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
        l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
        l_bind_list(2).bind_var_value := cur_rec.status_code ;
        l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
		--3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
		  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_SALESLEAD_UWQ_REF_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
--added by vimpi on 7th december to lower the cost

        l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND  RESOURCE_ID+0 = :RESOURCE_ID AND
 STATUS_CODE = :STATUS_CODE';
        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        --l_ld_list(l_node_counter).NODE_DEPTH := 2;
        l_ld_list(l_node_counter).NODE_DEPTH := 3;
        --added by vimpi on 2nd nov/01

        l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';



        l_node_counter := l_node_counter + 1;

  END LOOP;






/* 9/3 commented by swkhanna. Not needed
--added by nprasad 06/17/2002 for the new node for leads last updated by specified number of days

		l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
		l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
		l_bind_list(1).bind_var_data_type := 'NUMBER' ;

           -- aug23,2002, added following to get the node label from message so it can be translated
           fnd_message.set_name('AST','AST_UWQ_OLDER_NODE');
           fnd_message.set_token('PRIOR_DAYS',l_prior_days);
           l_node_label :=   fnd_message.get;

	      l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
	     --l_ld_list(l_node_counter).NODE_LABEL := 'Older than '|| l_prior_days || ' '||'days';
	     l_ld_list(l_node_counter).VIEW_NAME := 'AST_SALESLEAD_UWQ_V';
	     l_ld_list(l_node_counter).DATA_SOURCE := 'AST_SALESLEAD_UWQ_DS';
	     l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';


l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
'STATUS_CODE in (Select status_code from as_statuses_b where opp_open_status_flag=''Y'' and lead_flag = ''Y'' and enabled_flag = ''Y'') '||
'AND (sysdate - last_update_date) >  NVL(fnd_profile.value(''AST_DEFAULT_PRIOR_DAYS''),30)';

l_ld_list(l_node_counter).NODE_TYPE := 0;
l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
l_ld_list(l_node_counter).NODE_DEPTH := 2;
*/

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_lead_enumeration;
    RAISE;

END ENUMERATE_LEADS_NODES;


PROCEDURE ENUMERATE_TEAM_LEADS_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(1000);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;

  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_prior_days             VARCHAR2(10) ;

  -- SOLIN, bug 5094263
  CURSOR c_get_node_label(c_lookup_type VARCHAR2, c_lookup_code VARCHAR2) IS
    Select meaning
    from ast_lookups
    where lookup_type = c_lookup_type
    and lookup_code = c_lookup_code;
  -- SOLIN, end bug 5094263


  CURSOR c_lead_nodes IS
    SELECT status_code, meaning
    FROM
      as_statuses_vl
    WHERE
      enabled_flag = 'Y' and LEAD_FLAG = 'Y' and OPP_OPEN_STATUS_FLAG = 'Y'
    ORDER BY 1;

BEGIN

  /* label, view, and where for main node taken from enum table anyway */

  l_node_counter := 0;
  l_prior_days := NVL(fnd_profile.value('AST_DEFAULT_PRIOR_DAYS'), '30');
  SAVEPOINT start_lead_enumeration;

  -- ***************************************
  -- swkhanna 9/3
  -- Base Node 'My Leads ( saleateam)' will be defaulted to 30 DAYS
  -- ***************************************

  -- SOLIN, bug 5094263
  OPEN c_get_node_label('AST_UWQ_LABELS', 'LEADS_TEAMWORK_CLASS_LABEL');
  FETCH c_get_node_label INTO l_node_label;
  CLOSE c_get_node_label;
  -- SOLIN, end bug 5094263


  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
    --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	 l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  -- added by vimpi on 7th dec to decrease cost
--  l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND  (sysdate - last_update_date) <= 30';

-- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
    l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 30)';

l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;

  l_node_counter := l_node_counter + 1;


-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line 30 DAYS
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_30_DAYS');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
	 --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  --l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '|| ' (sysdate - last_update_date) <= 30';

  -- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	 l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 30)';

  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;
 ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 30 days. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------

  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
	   --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
     	l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_S_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  -- added by vimpi on 7th dec to decrease cost
        -- l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND  STATUS_CODE = :STATUS_CODE ' || ' and (sysdate - last_update_date) <= 30';

  -- 4/29 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	  l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE AND (creation_date >= sysdate - 30)';

        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        l_ld_list(l_node_counter).NODE_DEPTH := 3;

	   l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;

-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line 90 DAYS
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_90_DAYS');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
  --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  --l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '|| ' (sysdate - last_update_date) <= 90';

  --4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	 l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 90)';

  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;
 ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 90 days. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------


  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
	   --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	   l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_S_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  -- added by vimpi on 7th dec to decrease cost
       -- l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND  STATUS_CODE = :STATUS_CODE ' || ' and (sysdate - last_update_date) <= 90';

-- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	 l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND  STATUS_CODE = :STATUS_CODE AND (creation_date >= sysdate - 90)';

        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        l_ld_list(l_node_counter).NODE_DEPTH := 3;

	   l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;

-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line 180 DAYS
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_6_MNTHS');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
  --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  --l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '|| ' (sysdate - last_update_date) <= 180';

  -- 4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
   l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 180)';

  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;
 ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 180 days. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------


  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
	   --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	   l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_S_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  -- added by vimpi on 7th dec to decrease cost
        --l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND  STATUS_CODE = :STATUS_CODE ' || ' and (sysdate - last_update_date) <= 180';

   -- 4/29/03/25 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	  l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE AND (creation_date >= sysdate - 180)';

        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        l_ld_list(l_node_counter).NODE_DEPTH := 3;

	   l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;


-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line 365 DAYS
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_1_YEAR');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
  --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  --l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '|| ' (sysdate - last_update_date) <= 365';

  -- 4/29/03  swkhanna Bug 2877904, reformat the last_update_clause to creation_date
     l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND (creation_date >= sysdate - 365)';

  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;
 ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for 365 days. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------


  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
	   --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	   l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_S_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  -- added by vimpi on 7th dec to decrease cost
  --    l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND  STATUS_CODE = :STATUS_CODE ' || ' and (sysdate - last_update_date) <= 365';

  --  4/29/03 swkhanna Bug 2877904, reformat the last_update_clause to creation_date
	 l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND STATUS_CODE = :STATUS_CODE AND (creation_date >= sysdate - 365)';

        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        l_ld_list(l_node_counter).NODE_DEPTH := 3;

	   l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;


-- ***************************************
-- swkhanna 9/3
-- Add another level of nodes with time line :ALL
-- ****************************************
  --SAVEPOINT start_lead_enumeration;
  l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
  l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;
 -- Get Node Label from message
  fnd_message.set_name('AST','AST_UWQ_ALL_LEADS');
  l_node_label :=   fnd_message.get;
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
  --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_REF_V';
  l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID ';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 2;

  l_node_counter := l_node_counter + 1;
 ------------------------------------------------------------------------------------
  -- Enumerate sub nodes for  all leads. The subnodes are based on the lead statuses
  ------------------------------------------------------------------------------------


  FOR cur_rec IN c_lead_nodes LOOP

        --added bind var by vimpi on 1rst nov/2001
	   l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
	   l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
	   l_bind_list(1).bind_var_data_type := 'NUMBER' ;

	   l_bind_list(2).bind_var_name := ':STATUS_CODE' ;
	   l_bind_list(2).bind_var_value := cur_rec.status_code ;
	   l_bind_list(2).bind_var_data_type := 'CHAR' ;

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
	   --3/21/03 swkhanna added the following line ie. REFRESH_VIEW_NAME for #2831426
	   l_ld_list(l_node_counter).REFRESH_VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_S_V';
        l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
        l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  -- added by vimpi on 7th dec to decrease cost
        l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND  STATUS_CODE = :STATUS_CODE ' ;
        l_ld_list(l_node_counter).NODE_TYPE := 0;
        l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
        l_ld_list(l_node_counter).NODE_DEPTH := 3;

	   l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	   l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

        l_node_counter := l_node_counter + 1;

  END LOOP;



/* swkhanna 9/5 not needed
          l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
		l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
		l_bind_list(1).bind_var_data_type := 'NUMBER' ;

           -- aug23,2002, added following to get the node label from message so it can be translated
           fnd_message.set_name('AST','AST_UWQ_OLDER_NODE');
           fnd_message.set_token('PRIOR_DAYS',l_prior_days);
           l_node_label :=   fnd_message.get;

	     l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
		--l_ld_list(l_node_counter).NODE_LABEL := 'Older than '|| l_prior_days || ' '||'days';
		l_ld_list(l_node_counter).VIEW_NAME := 'AST_MYTEAM_SALESLEAD_UWQ_V';
		l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MYTEAM_SALESLEAD_UWQ_DS';
		l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';

l_ld_list(l_node_counter).WHERE_CLAUSE :=  'RESOURCE_ID = :RESOURCE_ID AND RESOURCE_ID+0 = :RESOURCE_ID AND '||
'STATUS_CODE in (Select status_code from as_statuses_b where opp_open_status_flag=''Y'' and lead_flag = ''Y'' and enabled_flag = ''Y'') '||
'AND (sysdate - last_update_date) >  NVL(fnd_profile.value(''AST_DEFAULT_PRIOR_DAYS''),30)';

		l_ld_list(l_node_counter).NODE_TYPE := 0;
		l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
		l_ld_list(l_node_counter).NODE_DEPTH := 2;
*/

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_lead_enumeration;
    RAISE;

END ENUMERATE_TEAM_LEADS_NODES;

-- PL/SQL Block
END AST_UWQ_LEADS_ENUMS_PVT;

/
