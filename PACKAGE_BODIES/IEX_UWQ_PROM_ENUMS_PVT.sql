--------------------------------------------------------
--  DDL for Package Body IEX_UWQ_PROM_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_UWQ_PROM_ENUMS_PVT" AS
/* $Header: iexenprb.pls 120.22.12010000.10 2010/05/17 11:36:11 pnaveenk ship $ */

-- Sub-Program Units

PG_DEBUG NUMBER(2);

PROCEDURE SET_MO_GLOBAL IS
L VARCHAR2(240);
CURSOR C_ORG_ID IS SELECT ORGANIZATION_ID FROM HR_OPERATING_UNITS
    WHERE MO_GLOBAL.CHECK_ACCESS(ORGANIZATION_ID) = 'Y';
BEGIN

  MO_GLOBAL.INIT('IEX');
  MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);


  FOR I_ORG IN C_ORG_ID LOOP
  MO_GLOBAL.SET_POLICY_CONTEXT('S',I_ORG.ORGANIZATION_ID);

  L := IEX_UTILITIES.get_cache_value('GL_CURRENCY'||I_ORG.ORGANIZATION_ID,
     'SELECT  GLSOB.CURRENCY_CODE CURRENCY from GL_SETS_OF_BOOKS GLSOB, AR_SYSTEM_PARAMETERS ARSYS WHERE ARSYS.SET_OF_BOOKS_ID ' ||
     ' = GLSOB.SET_OF_BOOKS_ID');
  L := IEX_UTILITIES.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE'||I_ORG.ORGANIZATION_ID, 'SELECT DEFAULT_EXCHANGE_RATE_TYPE FROM AR_CMGT_SETUP_OPTIONS');
  END LOOP;

  MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);

END SET_MO_GLOBAL;

PROCEDURE ENUMERATE_PROM_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;

  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_Access   varchar2(10);
  l_Level    varchar2(15);
  l_person_id NUMBER;


  CURSOR c_person IS
    select source_id
    from jtf_rs_resource_extns
    where resource_id = p_resource_id;

  CURSOR c_del_new_nodes is
    select lookup_code, meaning from fnd_lookup_values
    where lookup_type = 'IEX_UWQ_NODE_STATUS' and LANGUAGE = userenv('LANG');

  CURSOR c_node_label(in_lookup_type VARCHAR2,in_lookup_code VARCHAR2) IS
    SELECT meaning
    FROM fnd_lookup_values
    WHERE lookup_type = in_lookup_type
    AND lookup_code = in_lookup_code
    AND LANGUAGE = userenv('LANG');

  CURSOR c_sel_enum(in_sel_enum_id NUMBER) IS
    SELECT work_q_view_for_primary_node, work_q_label_lu_type, work_q_label_lu_code
    FROM ieu_uwq_sel_enumerators
    WHERE sel_enum_id = in_sel_enum_id;

  -- Added for bug 8708271 PNAVEENK
  CURSOR c_ml_setup IS
  select DEFINE_PARTY_RUNNING_LEVEL,DEFINE_OU_RUNNING_LEVEL
  from IEX_QUESTIONNAIRE_ITEMS;
  -- End for bug 8708271
  l_sel_enum_rec c_sel_enum%ROWTYPE;

  l_Complete_Days varchar2(40);
  l_data_source VARCHAR2(1000);
  l_default_where VARCHAR2(1000);
  l_security_where VARCHAR2(2000);
  l_node_where VARCHAR2(2000);
  l_uwq_where VARCHAR2(1000);
 -- l_org_id NUMBER; -- commented for bug 8826561 PNAVEENK

  type tbl_wclause is table of varchar2(500) index by binary_integer;

  l_wclause tbl_wclause;
  l_str1  VARCHAR2(2000);
  l_str2  VARCHAR2(2000);
  l_str_and VARCHAR2(100);
  l_str_prom VARCHAR2(1000);
  l_bkr_filter VARCHAR2(240);
  l_str_bkr VARCHAR2(1000);
  l_check NUMBER(5);
  -- Begin -jypark- 05/25/05 - 4608220 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes   varchar2(10);
  -- End -jypark- 05/25/05 - 4608220 - Added profile to show/hide UWQ sub-nodes
  l_party_override varchar2(1); -- Added for bug 8708271 PNAVEENK
  l_org_override varchar2(1); -- Added for bug 8708271 PNAVEENK
BEGIN

  -- SAVEPOINT start_prom_enumeration;
  -- Moac Changes start. Set the policy context.
  MO_GLOBAL.INIT('IEX');
  MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);
  -- Moac Changes End. Set the policy context.

  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
  --l_org_id  := TO_NUMBER(oe_profile.value('OE_ORGANIZATION_ID', fnd_profile.value('ORG_ID'))); -- commented for bug 8826561 PNAVEENK
  l_Access := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  l_Level  := NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');

  l_node_counter := 0;
  If (l_Access = 'T') then
   SELECT count(*) into l_check from iex_assignments where
   alt_resource_id =  p_RESOURCE_ID
   AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
   AND NVL(DELETED_FLAG,'N') = 'N';
  End If;

  l_str_and  := ' AND ';
  l_str_prom  := ' AND NUMBER_OF_PROMISES > 0 ';


  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;
  -- Start for bug 8708271 PNAVEENK
  open c_ml_setup;
  fetch c_ml_setup into l_party_override,l_org_override;
  close c_ml_setup;
  -- End for bug 8708271
  --Bug4775893. Fix by LKKUMAR on 14-Dec-2005.  Start.
  l_wclause(1) :=
        ' (RESOURCE_ID = :RESOURCE_ID ' ||
           ' OR  :RESOURCE_ID ' ||
             ' IN  (select iea.alt_resource_id '||
             ' FROM  iex_assignments iea ' ||
             ' WHERE  nvl(iea.deleted_flag,''N'') = ''N'' ' ||
             ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
             ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
	     ' AND iea.alt_resource_id = :RESOURCE_ID ' ||
	     ' AND iea.resource_id =  ' ||  l_sel_enum_rec.work_q_view_for_primary_node ||'.RESOURCE_ID )) ' ||
  	     ' AND ' ||      ' (UWQ_STATUS IS NULL or  UWQ_STATUS = :UWQ_STATUS or ' ||
             ' (trunc(UWQ_ACTIVE_DATE) <= trunc(SYSDATE) and UWQ_STATUS = ''PENDING'' )) ';

  l_wclause(2) :=
        ' (RESOURCE_ID = :RESOURCE_ID  ' ||
           ' OR  :RESOURCE_ID ' ||
             ' IN  (select iea.alt_resource_id '||
             ' FROM  iex_assignments iea ' ||
             ' WHERE  nvl(iea.deleted_flag,''N'') = ''N'' ' ||
             ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
             ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
	     ' AND iea.alt_resource_id = :RESOURCE_ID ' ||
	     ' AND iea.resource_id =  ' ||  l_sel_enum_rec.work_q_view_for_primary_node ||'.RESOURCE_ID )) ' ||
             ' AND' || ' (UWQ_STATUS = :UWQ_STATUS and (trunc(UWQ_ACTIVE_DATE) > trunc(SYSDATE))) ';

  l_wclause(3) :=
        ' (RESOURCE_ID = :RESOURCE_ID '   ||
           ' OR  :RESOURCE_ID ' ||
             ' IN  (select iea.alt_resource_id '||
             ' FROM  iex_assignments iea ' ||
             ' WHERE  nvl(iea.deleted_flag,''N'') = ''N'' ' ||
             ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
             ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
	     ' AND iea.alt_resource_id = :RESOURCE_ID ' ||
	     ' AND iea.resource_id =  ' ||  l_sel_enum_rec.work_q_view_for_primary_node ||'.RESOURCE_ID )) ' ||
	     ' AND ' ||
	     ' (UWQ_STATUS = :UWQ_STATUS and (trunc(UWQ_COMPLETE_DATE) + ' || l_Complete_Days || ' >  trunc(SYSDATE))) ';
 --Start for bug#7574861 by PNAVEENK
 /* If (l_check >0 ) then

  l_str1   :=
 ' OR  ' || l_sel_enum_rec.work_q_view_for_primary_node || '.PARTY_ID' || ' IN (SELECT distinct hp.party_id ' ||
          ' FROM hz_customer_profiles hp,ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) )';
     l_security_where := l_str1 ;
  Else
  l_str1 :=
  ' OR  ' || l_sel_enum_rec.work_q_view_for_primary_node || '.PARTY_ID' || ' IN (SELECT distinct hp.party_id ' ||
           ' FROM hz_customer_profiles hp,ar_collectors ac ' ||
           ' WHERE hp.collector_id = ac.collector_id ' ||
           ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
           ' AND ac.employee_id = :PERSON_ID ';
  l_str2 := ' UNION ALL SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ) ' ;

   l_security_where := l_str1 ||l_str2;
  END IF; */
  --End for bug#7574861 by PNAVEENK
  --Bug4775893. Fix by LKKUMAR on 14-Dec-2005. End.

  -- changed for bug#7693986 by PNAVEENk on 12-1-2009
   IF p_sel_enum_id = 13069 THEN
    l_str_bkr := ' AND NOT EXISTS (SELECT 1  FROM iex_bankruptcies bkr WHERE bkr.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.customer_id and NVL(BKR.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ) ' ;
  ELSE
    l_str_bkr :=  ' AND NOT EXISTS (SELECT 1 FROM iex_bankruptcies bkr WHERE bkr.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.party_id and NVL(BKR.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ) ' ;
  END IF;
  -- end for bug#7693986
  IF p_sel_enum_id = 13066 THEN
    l_data_source := 'IEX_PROMISES_UWQ';
  END IF;

  --Bug4775893. Fix by LKKUMAR on 14-Dec-2005. Start.
  l_default_where := ' ( RESOURCE_ID = :RESOURCE_ID and :UWQ_STATUS = :UWQ_STATUS ' ||
                     ' OR  :RESOURCE_ID ' ||
      	             ' IN  (select iea.alt_resource_id '||
                     ' FROM  iex_assignments iea ' ||
                     ' WHERE  nvl(iea.deleted_flag,''N'') = ''N'' ' ||
                     ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
                     ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
		     ' AND iea.alt_resource_id = :RESOURCE_ID ' ||
		     ' AND iea.resource_id =  ' ||  l_sel_enum_rec.work_q_view_for_primary_node ||'.RESOURCE_ID )) ';
--Bug4775893. Fix by LKKUMAR on 14-Dec-2005. End.
   -- Start for bug 8708271 PNAVEENK
   if l_party_override = 'Y' or l_org_override ='Y' then

      l_default_where := l_default_where || ' AND iex_utilities.get_party_running_level (party_id , org_id ) = ''DELINQUENCY'' ';
   else
      null;
   end if;
   -- End for bug 8708271
  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := l_sel_enum_rec.work_q_view_for_primary_node;
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

  l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
  l_bind_list(1).bind_var_value := 'ALL';
  l_bind_list(1).bind_var_data_type := 'CHAR' ;


  l_bind_list(2).bind_var_name := ':RESOURCE_ID';

  l_bind_list(2).bind_var_value := p_resource_id;

  l_bind_list(2).bind_var_data_type := 'NUMBER' ;

  IF ( l_access in ('F', 'P')) THEN
    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  ELSE
    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;
    -- For bug#7574861 Bind variables commented by PNAVEENK
   --Commented
  --  l_bind_list(3).bind_var_name := ':PERSON_ID' ;
  --  l_bind_list(3).bind_var_value := l_person_id;
  --  l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := '( ' ||  l_default_where  || ' ) ' || l_str_bkr; --Changed for bug#7574861 by PNAVEENK
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where;   --Changed for bug#7574861 by PNAVEENK
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;

  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;


  l_node_counter := l_node_counter + 1;

  -- Begin -jypark- 05/25/05 - 4608220 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes :=  NVL(FND_PROFILE.VALUE('IEX_ENABLE_UWQ_STATUS'),'N');

  if (l_EnableNodes <> 'N') then
  -- End -jypark- 05/25/05 - 4608220 - Added profile to show/hide UWQ sub-nodes

  FOR cur_rec IN c_del_new_nodes LOOP
    IF (cur_rec.lookup_code = 'ACTIVE') THEN
      l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
      l_bind_list(1).bind_var_value := 'ACTIVE';
      l_bind_list(1).bind_var_data_type := 'CHAR' ;
      l_uwq_where := l_wclause(1);
      l_node_where := l_default_where || ' AND ACTIVE_PROMISES > 0 ';
    ELSIF (cur_rec.lookup_code = 'PENDING') THEN
      l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
      l_bind_list(1).bind_var_value := 'PENDING';
      l_bind_list(1).bind_var_data_type := 'CHAR' ;
      l_uwq_where := l_wclause(2);
      l_node_where := l_default_where || ' AND PENDING_PROMISES > 0 ';
    ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
      l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
      l_bind_list(1).bind_var_value := 'COMPLETE';
      l_bind_list(1).bind_var_data_type := 'CHAR' ;
      l_uwq_where := l_wclause(3);
      l_node_where := l_default_where || ' AND COMPLETE_PROMISES > 0 ';
    END IF;

    l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
    l_ld_list(l_node_counter).VIEW_NAME := l_sel_enum_rec.work_q_view_for_primary_node;
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

    l_bind_list(2).bind_var_name := ':RESOURCE_ID' ;

    l_bind_list(2).bind_var_value := p_resource_id;

    l_bind_list(2).bind_var_data_type := 'NUMBER' ;

    IF ( l_access in ('P', 'F')) THEN
      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_uwq_where || l_str_bkr;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_uwq_where;
      END IF;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
    ELSE
      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE := ' ( ' ||  l_uwq_where ||  ' ) ' || l_str_bkr; --Changed for bug#7574861 by PNAVEENK
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_uwq_where; --Changed for bug#7574861 by PNAVEENK
      END IF;
     --Commented for bug#7574861 by PNAVEENK
     -- l_bind_list(3).bind_var_name := ':PERSON_ID' ;
     -- l_bind_list(3).bind_var_value := l_person_id;
     -- l_bind_list(3).bind_var_data_type := 'NUMBER' ;
      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
    END IF;

    l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_ld_list(l_node_counter).NODE_TYPE := 0;
    l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_ld_list(l_node_counter).NODE_DEPTH := 2;

    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

    l_node_counter := l_node_counter + 1;
  END LOOP;
  -- Begin -jypark- 05/25/05 - 4608220 - Added profile to show/hide UWQ sub-nodes
  end if;
  -- End -jypark- 05/25/05 - 4608220 - Added profile to show/hide UWQ sub-nodes


  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END ENUMERATE_PROM_NODES;

PROCEDURE ENUMERATE_CU_PROM_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;

  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_Access   varchar2(10);
  l_Level    varchar2(15);


  CURSOR c_del_new_nodes is
    select lookup_code, meaning from fnd_lookup_values
    where lookup_type = 'IEX_UWQ_NODE_STATUS' and LANGUAGE = userenv('LANG');

  CURSOR c_node_label(in_lookup_type VARCHAR2,in_lookup_code VARCHAR2) IS
    SELECT meaning
    FROM fnd_lookup_values
    WHERE lookup_type = in_lookup_type
    AND lookup_code = in_lookup_code
    AND LANGUAGE = userenv('LANG');

  CURSOR c_sel_enum(in_sel_enum_id NUMBER) IS
    SELECT work_q_view_for_primary_node, work_q_label_lu_type, work_q_label_lu_code
    FROM ieu_uwq_sel_enumerators
    WHERE sel_enum_id = in_sel_enum_id;

  l_sel_enum_rec c_sel_enum%ROWTYPE;

  l_Complete_Days varchar2(40);
  l_data_source VARCHAR2(1000);
  l_default_where VARCHAR2(1000);
  l_security_where VARCHAR2(2000);
  l_node_where VARCHAR2(2000);
  l_uwq_where VARCHAR2(1000);
-- l_org_id NUMBER; -- commented for bug 8826561 PNAVEENK

  type tbl_wclause is table of varchar2(500) index by binary_integer;

  l_wclause tbl_wclause;
  l_str1  VARCHAR2(2000);
  l_str_and VARCHAR2(100);
  l_str_or  VARCHAR2(10);
  l_str_prom VARCHAR2(1000);
  l_bkr_filter VARCHAR2(240);
  l_str_bkr VARCHAR2(1000);
  l_view_name VARCHAR2(240);
  l_refresh_view_name VARCHAR2(240);
  l_check NUMBER(5);

  l_EnableNodes   varchar2(10);

  l_collector_id number;

    CURSOR c_collector_id IS
        SELECT collector_id from AR_COLLECTORS where resource_id = p_resource_id
          and resource_type = 'RS_RESOURCE';

    CURSOR c_person IS
        select source_id
        from jtf_rs_resource_extns
        where resource_id = p_resource_id;

  l_person_id number;

    CURSOR c_strategy_level IS
      SELECT PREFERENCE_VALUE
  	FROM IEX_APP_PREFERENCES_B
      WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
      and org_id is null
      and enabled_flag='Y';

  l_strategy_level VARCHAR2(30);
  l_temp_str	     varchar2(5);  -- Added for bug#8537638 PNAVEENK 11-8-2009
    --begin bug#6717849 schekuri 31-Jul-2009
  l_level_count number;
  cursor c_multi_level
  is select lookup_code
  from iex_lookups_v
  where lookup_type='IEX_RUNNING_LEVEL'
  and lookup_code= 'CUSTOMER'
  and  iex_utilities.validate_running_level(LOOKUP_CODE)='Y';
  --end bug#6717849 schekuri 31-Jul-2009

BEGIN

  SET_MO_GLOBAL;

  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
 -- l_org_id  := TO_NUMBER(oe_profile.value('OE_ORGANIZATION_ID', fnd_profile.value('ORG_ID'))); -- commented for bug 8826561 PNAVEENK
  l_Access := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  l_Level  := NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');

 /* IF (l_Access = 'T') THEN
   SELECT count(*) INTO l_check FROM iex_assignments where
   alt_resource_id = p_RESOURCE_ID
   AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
   AND NVL(DELETED_FLAG,'N') = 'N';
  END IF;


  l_str_and  := ' AND ';
  l_str_prom := ' AND NUMBER_OF_PROMISES > 0 ';
  l_str_or := ' OR ';
  */
  l_node_counter := 0;

-- !!
-- !!!!!!!!!! BUILDING MAIN NODE WHERE CLAUSE
-- !!

  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;

-- Start bug 5874874 gnramasa 25-Apr-07
  l_data_source := 'IEX_CU_PRO_ALL_UWQ';
  l_view_name := 'IEX_CU_PRO_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_PRO_ALL_UWQ_V';

/*
  l_str_bkr := ' AND NUMBER_OF_BANKRUPTCIES = 0 ';
    IF (l_check  >0 ) THEN
       l_str1   := ASSIGNMENTS_WHERE_CLAUSE('PARTY', l_view_name) || ' AND ' || RESOURCES_WHERE_CLAUSE('PARTY', l_view_name) || ' ) ';
    ELSE
       l_str1   :=  RESOURCES_WHERE_CLAUSE('PARTY', l_view_name);
    END IF;

  l_security_where := l_str1 ;
  l_default_where := ' ( RESOURCE_ID = :RESOURCE_ID OR'  || ASSIGNMENTS_WHERE_CLAUSE('PARTY', l_view_name) || ' ) ';

  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
  l_bind_list(1).bind_var_value := 1;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  --Begin - Bug#5344878 - Andre Araujo - Need to add bind variables
  l_bind_list(2).bind_var_name := ':REAL_RESOURCE_ID';
  l_bind_list(2).bind_var_value := p_resource_id;
  l_bind_list(2).bind_var_data_type := 'NUMBER' ;
  --End - Bug#5344878 - Andre Araujo - Need to add bind variables

  IF ( l_access in ('F', 'P')) THEN
    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_prom || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_prom;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  ELSE

     -- No count view when the security is enabled
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;
    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;


    l_bind_list(3).bind_var_name := ':PERSON_ID' ;
    l_bind_list(3).bind_var_value := l_person_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_prom || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_prom;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;
  */
  OPEN c_strategy_level;
  FETCH c_strategy_level INTO l_strategy_level;
  CLOSE c_strategy_level;

      --begin bug#6717849 schekuri 31-Jul-2009
  select count(1)
  into l_level_count
  from iex_lookups_v
  where lookup_type='IEX_RUNNING_LEVEL'
  and  iex_utilities.validate_running_level(LOOKUP_CODE)='Y';

  if l_level_count>1 then
  open c_multi_level;
  fetch c_multi_level into l_strategy_level;
  close c_multi_level;
  end if;
  --end bug#6717849 schekuri 31-Jul-2009

 IF l_strategy_level = 'CUSTOMER' THEN

      l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
      l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
      l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
      l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

   --   l_default_where :=  ' IEU_PARAM_PK_COL=''PARTY_ID'' and '||attach_where_clause(p_resource_id); --bug#6717849 schekuri 31-Jul-2009
        l_default_where :=  ' IEU_PARAM_PK_COL=''PARTY_ID'' ' ||attach_where_clause(p_resource_id); -- bug 8537638 PNAVEENK 11-8-2009
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where;

      IF (l_access = 'T' ) THEN
        OPEN c_collector_id;
        FETCH c_collector_id INTO l_collector_id;
        CLOSE c_collector_id;

        OPEN c_person;
        FETCH c_person INTO l_person_id;
        CLOSE c_person;

        l_bind_list(1).bind_var_name := ':PERSON_ID' ;
        l_bind_list(1).bind_var_value := l_person_id;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
        l_bind_list(2).bind_var_value := p_resource_id;
        l_bind_list(2).bind_var_data_type := 'NUMBER' ;

        l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
      ELSE    -- bug 9453423 PNAVEENK
       IF l_default_where IS NULL THEN
          l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID';

	  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
          l_bind_list(1).bind_var_value := 1;
          l_bind_list(1).bind_var_data_type := 'NUMBER' ;

          l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
       END IF;
      END IF;
   ELSE  /* IF l_strategy_level <> 'CUSTOMER' */

      l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
      l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
      l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

      l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND :UWQ_STATUS = :UWQ_STATUS ';

      l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
      l_bind_list(1).bind_var_value := 'ALL';
      l_bind_list(1).bind_var_data_type := 'CHAR' ;

      l_bind_list(2).bind_var_name := ':RESOURCE_ID';
      l_bind_list(2).bind_var_value := -1;
      l_bind_list(2).bind_var_data_type := 'NUMBER' ;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
   END IF;
-- End bug 5874874 gnramasa 25-Apr-07
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;


  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.LogMessage('ENUMERATE_CU_PROM_NODES: main final where clause: ' || l_ld_list(l_node_counter).WHERE_CLAUSE);
  END IF;

  l_node_counter := l_node_counter + 1;
  l_EnableNodes :=  NVL(FND_PROFILE.VALUE('IEX_ENABLE_UWQ_STATUS'),'N');

  if (l_EnableNodes <> 'N') then
    l_view_name := 'IEX_CU_PRO_ALL_UWQ_V';
    l_refresh_view_name := 'IEX_CU_PRO_ALL_UWQ_V';
  -- Start for bug 8537638 PNAVEENK 11-8-2009
   if l_ld_list(0).WHERE_CLAUSE is not null then
	l_temp_str := ' and ';
      else
	l_temp_str := ' ';
      end if;

  FOR cur_rec IN c_del_new_nodes LOOP
    IF l_strategy_level = 'CUSTOMER' THEN
      IF (cur_rec.lookup_code = 'ACTIVE') THEN
        l_data_source := 'IEX_CU_PRO_ACT_UWQ';
        --l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and active_promises is not null';
	--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(active_promises,0)  > 0 ';
        l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(active_promises,0)  > 0 ';
      ELSIF (cur_rec.lookup_code = 'PENDING') THEN
        l_data_source := 'IEX_CU_PRO_PEND_UWQ';
        --l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and pending_promises is not null';
	--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(pending_promises,0)  > 0 ';
         l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(pending_promises,0)  > 0 ';
      ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
        l_data_source := 'IEX_CU_PRO_COMP_UWQ';
        --l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and complete_promises is not null';
	--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(complete_promises,0)  > 0 ';
          l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(complete_promises,0)  > 0 ';
      END IF;
     -- end for bug 8537638

    l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;
    l_ld_list(l_node_counter).WHERE_CLAUSE := l_node_where;
    l_ld_list(l_node_counter).BIND_VARS    := l_ld_list(0).BIND_VARS;
  ELSE  /* IF l_strategy_level <> 'CUSTOMER' */

    l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

    l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND :UWQ_STATUS = :UWQ_STATUS ';

    l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
    l_bind_list(1).bind_var_value := 'ALL';
    l_bind_list(1).bind_var_data_type := 'CHAR' ;

    l_bind_list(2).bind_var_name := ':RESOURCE_ID';
    l_bind_list(2).bind_var_value := -1;
    l_bind_list(2).bind_var_data_type := 'NUMBER' ;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;

    l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_ld_list(l_node_counter).NODE_TYPE := 0;
    l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_ld_list(l_node_counter).NODE_DEPTH := 2;

    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage('ENUMERATE_CU_PROM_NODES: Subnode final where clause: ' || l_ld_list(l_node_counter).WHERE_CLAUSE);
    END IF;


    l_node_counter := l_node_counter + 1;
  END LOOP;
  END IF;

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'iex',  'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM );
    End if;
    RAISE;

END ENUMERATE_CU_PROM_NODES;


PROCEDURE ENUMERATE_ACC_PROM_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;

  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_Access   varchar2(10);
  l_Level    varchar2(15);
  l_person_id NUMBER;
  l_check    NUMBER;

  CURSOR c_del_new_nodes is
    select lookup_code, meaning from fnd_lookup_values
    where lookup_type = 'IEX_UWQ_NODE_STATUS' and LANGUAGE = userenv('LANG');

  CURSOR c_node_label(in_lookup_type VARCHAR2,in_lookup_code VARCHAR2) IS
    SELECT meaning
    FROM fnd_lookup_values
    WHERE lookup_type = in_lookup_type
    AND lookup_code = in_lookup_code
    AND LANGUAGE = userenv('LANG');

  CURSOR c_sel_enum(in_sel_enum_id NUMBER) IS
    SELECT work_q_view_for_primary_node, work_q_label_lu_type, work_q_label_lu_code
    FROM ieu_uwq_sel_enumerators
    WHERE sel_enum_id = in_sel_enum_id;

  l_sel_enum_rec c_sel_enum%ROWTYPE;

  l_Complete_Days varchar2(40);
  l_data_source VARCHAR2(1000);
  l_default_where VARCHAR2(1000);
  l_security_where VARCHAR2(2000);
  l_node_where VARCHAR2(2000);
  l_uwq_where VARCHAR2(1000);
 -- l_org_id NUMBER;  -- commented for bug 8826561 PNAVEENK

  type tbl_wclause is table of varchar2(500) index by binary_integer;

  l_wclause tbl_wclause;
  l_str1  VARCHAR2(2000);
  l_str_and VARCHAR2(100);
  l_str_prom VARCHAR2(1000);
  l_bkr_filter VARCHAR2(240);
  l_str_bkr VARCHAR2(1000);
  l_view_name VARCHAR2(240);
  l_refresh_view_name VARCHAR2(240);
  l_EnableNodes   varchar2(10);

  l_collector_id number;
  l_resource_id number;

  CURSOR c_collector_id IS
      SELECT collector_id from AR_COLLECTORS where resource_id = p_resource_id
        and resource_type = 'RS_RESOURCE';

  CURSOR c_person IS
      select source_id
      from jtf_rs_resource_extns
      where resource_id = p_resource_id;

  CURSOR c_strategy_level IS
    SELECT PREFERENCE_VALUE
    FROM IEX_APP_PREFERENCES_B
    WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
    and org_id is null
    and enabled_flag='Y';

  l_strategy_level VARCHAR2(30);
  l_temp_str	     varchar2(5); -- Added for bug 8537638 PNAVEENK 11-8-2009
    --begin bug#6717849 schekuri 31-Jul-2009
  l_level_count number;
  cursor c_multi_level
  is select lookup_code
  from iex_lookups_v
  where lookup_type='IEX_RUNNING_LEVEL'
  and lookup_code= 'ACCOUNT'
  and  iex_utilities.validate_running_level(LOOKUP_CODE)='Y';
  --end bug#6717849 schekuri 31-Jul-2009

BEGIN

  SET_MO_GLOBAL;

  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
 -- l_org_id  := TO_NUMBER(oe_profile.value('OE_ORGANIZATION_ID', fnd_profile.value('ORG_ID'))); -- commented for bug 8826561 PNAVEENK

  l_Access := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  /*
  l_Level  := NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'), 'PARTY');

  -- !!
  -- !!!!!!!!!! BUILDING MAIN NODE WHERE CLAUSE
  -- !!

  l_str_and  := ' AND ';
  l_str_prom  := ' AND NUMBER_OF_PROMISES > 0 ';
  */
  l_node_counter := 0;

  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;
  -- Start bug 5874874 gnramasa 25-Apr-07
  l_data_source := 'IEX_ACC_PRO_ALL_UWQ';
  l_view_name := 'IEX_CU_PRO_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_PRO_ALL_UWQ_V';

  /*
  l_str_bkr := ' AND NUMBER_OF_BANKRUPTCIES = 0 ';


  IF (l_Access = 'T') then
   SELECT count(*) INTO l_check FROM iex_assignments where
   alt_resource_id =  P_RESOURCE_ID
   AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
   AND NVL(DELETED_FLAG,'N') = 'N';
  END IF;

  IF (l_Level = 'PARTY') then
      If (l_check > 0) then
       l_str1   := ASSIGNMENTS_WHERE_CLAUSE('PARTY', l_sel_enum_rec.work_q_view_for_primary_node) || ' AND ' || RESOURCES_WHERE_CLAUSE('PARTY', l_sel_enum_rec.work_q_view_for_primary_node) || ' ) ';
      Else
       l_str1   :=  RESOURCES_WHERE_CLAUSE('PARTY', l_sel_enum_rec.work_q_view_for_primary_node);
      End If;
  ELSE
      If (l_check > 0) then
       l_str1   := ASSIGNMENTS_WHERE_CLAUSE('ACCOUNT', l_sel_enum_rec.work_q_view_for_primary_node) || ' AND ' || RESOURCES_WHERE_CLAUSE('ACCOUNT', l_sel_enum_rec.work_q_view_for_primary_node) || ' ) ';
      Else
       l_str1   :=  RESOURCES_WHERE_CLAUSE('ACCOUNT', l_sel_enum_rec.work_q_view_for_primary_node);
      End If;
   END IF;

   l_security_where := l_str1;

   l_default_where := ' ( RESOURCE_ID = :RESOURCE_ID OR'  || ASSIGNMENTS_WHERE_CLAUSE('ACCOUNT', l_view_name) || ' ) ';


  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
  l_bind_list(1).bind_var_value := 1;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;


  l_bind_list(2).bind_var_name := ':REAL_RESOURCE_ID';
  l_bind_list(2).bind_var_value := p_resource_id;
  l_bind_list(2).bind_var_data_type := 'NUMBER' ;


  IF ( l_access in ('F', 'P')) THEN
    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_prom || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_prom;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  ELSE
    -- No count view when the security is enabled
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;

    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;

    l_bind_list(3).bind_var_name := ':PERSON_ID' ;
    l_bind_list(3).bind_var_value := l_person_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_prom || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_prom;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;
  */
    OPEN c_strategy_level;
    FETCH c_strategy_level INTO l_strategy_level;
    CLOSE c_strategy_level;

        --begin bug#6717849 schekuri 31-Jul-2009
  select count(1)
  into l_level_count
  from iex_lookups_v
  where lookup_type='IEX_RUNNING_LEVEL'
  and  iex_utilities.validate_running_level(LOOKUP_CODE)='Y';

  if l_level_count>1 then
  open c_multi_level;
  fetch c_multi_level into l_strategy_level;
  close c_multi_level;
  end if;
  --end bug#6717849 schekuri 31-Jul-2009

    IF l_strategy_level = 'ACCOUNT' THEN

      l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
      l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
      l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
      l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

    --  l_default_where := ' IEU_PARAM_PK_COL=''CUST_ACCOUNT_ID'' and '||attach_where_clause(p_resource_id); --bug#6717849 schekuri 31-Jul-2009
        l_default_where := ' IEU_PARAM_PK_COL=''CUST_ACCOUNT_ID'' ' ||attach_where_clause(p_resource_id); -- bug 8537638 PNAVEENK 11-8-2009
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where;

      IF (l_access = 'T' ) THEN
        OPEN c_collector_id;
        FETCH c_collector_id INTO l_collector_id;
        CLOSE c_collector_id;

        OPEN c_person;
        FETCH c_person INTO l_person_id;
        CLOSE c_person;

        l_bind_list(1).bind_var_name := ':PERSON_ID' ;
        l_bind_list(1).bind_var_value := l_person_id;
        l_bind_list(1).bind_var_data_type := 'NUMBER' ;

        -- Begin fix bug #5660900-12/16/2006-Use resource_id instead of collector_id because employee is assigned to more 2 or more collectors
        -- l_bind_list(2).bind_var_name := ':COLLECTOR_ID' ;
        -- l_bind_list(2).bind_var_value := l_collector_id;
        -- l_bind_list(2).bind_var_data_type := 'NUMBER' ;

        l_bind_list(2).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
        l_bind_list(2).bind_var_value := p_resource_id;
        l_bind_list(2).bind_var_data_type := 'NUMBER' ;

        -- End fix bug #5660900-12/16/2006-Use resource_id instead of collector_id because employee is assigned to more 2 or more collectors
        l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
       ELSE    -- bug 9453423 PNAVEENK
        IF l_default_where IS NULL THEN
          l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID';

	  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
          l_bind_list(1).bind_var_value := 1;
          l_bind_list(1).bind_var_data_type := 'NUMBER' ;

          l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
        END IF;
       END IF;

    ELSE  /* IF l_strategy_level <> 'ACCOUNT' */

      l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
      l_ld_list(l_node_counter).VIEW_NAME := l_sel_enum_rec.work_q_view_for_primary_node;
      l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
      l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

      l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND :UWQ_STATUS = :UWQ_STATUS ';

      l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
      l_bind_list(1).bind_var_value := 'ALL';
      l_bind_list(1).bind_var_data_type := 'CHAR' ;

      l_bind_list(2).bind_var_name := ':RESOURCE_ID';
      l_bind_list(2).bind_var_value := -1;
      l_bind_list(2).bind_var_data_type := 'NUMBER' ;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
    END IF;
    -- End bug 5874874 gnramasa 25-Apr-07
  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;


  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.LogMessage('ENUMERATE_ACC_PROM_NODES: main final where clause: ' || l_ld_list(l_node_counter).WHERE_CLAUSE);
  END IF;


  -- !!
  -- !!!!!!!!!! BUILDING SUB NODES WHERE CLAUSE
  -- !!

  l_node_counter := l_node_counter + 1;


  l_EnableNodes :=  NVL(FND_PROFILE.VALUE('IEX_ENABLE_UWQ_STATUS'),'N');

  if (l_EnableNodes <> 'N') then
  l_view_name := 'IEX_CU_PRO_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_PRO_ALL_UWQ_V';

  -- Start for bug 8537638 PNAVEENK 11-8-2009
  if l_ld_list(0).WHERE_CLAUSE is not null then
	l_temp_str := ' and ';
    else
	l_temp_str := ' ';
    end if;

  FOR cur_rec IN c_del_new_nodes LOOP
   IF l_strategy_level = 'ACCOUNT' THEN
	IF (cur_rec.lookup_code = 'ACTIVE') THEN
		l_data_source := 'IEX_ACC_PRO_ACT_UWQ';
		--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and active_promises is not null';
		--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(active_promises,0)  > 0 ';
	          l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(active_promises,0)  > 0 ';
	ELSIF (cur_rec.lookup_code = 'PENDING') THEN
		l_data_source := 'IEX_ACC_PRO_PEND_UWQ';
		--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and pending_promises is not null';
		--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(pending_promises,0)  > 0 ';
	        l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(pending_promises,0)  > 0 ';
	ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
		l_data_source := 'IEX_ACC_PRO_COMP_UWQ';
		--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and complete_promises is not null';
		--l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(complete_promises,0) > 0 ';
	        l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(complete_promises,0) > 0 ';
	END IF;
        -- end for bug 8537638

	l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
	l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
	l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
	l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;


	l_ld_list(l_node_counter).WHERE_CLAUSE := l_node_where;
	l_ld_list(l_node_counter).BIND_VARS    := l_ld_list(0).BIND_VARS;
   ELSE  /* IF l_strategy_level <> 'ACCOUNT' */

        l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
        l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
        l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
        l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

        l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND :UWQ_STATUS = :UWQ_STATUS ';

        l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
        l_bind_list(1).bind_var_value := 'ALL';
        l_bind_list(1).bind_var_data_type := 'CHAR' ;

        l_bind_list(2).bind_var_name := ':RESOURCE_ID';
        l_bind_list(2).bind_var_value := -1;
        l_bind_list(2).bind_var_data_type := 'NUMBER' ;

        l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
   END IF;

    l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_ld_list(l_node_counter).NODE_TYPE := 0;
    l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_ld_list(l_node_counter).NODE_DEPTH := 2;

    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage('ENUMERATE_ACC_PROM_NODES: Subnode final where clause: ' || l_ld_list(l_node_counter).WHERE_CLAUSE);
    END IF;

    l_node_counter := l_node_counter + 1;
  END LOOP;

  END IF;



  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'iex',  'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM );
    End if;
    RAISE;

END ENUMERATE_ACC_PROM_NODES;

PROCEDURE ENUMERATE_BILLTO_PROM_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

  l_node_label VARCHAR2(200);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;

  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;
  l_Access   varchar2(10);
  l_Level    varchar2(15);
  l_person_id NUMBER;


  CURSOR c_del_new_nodes is
    select lookup_code, meaning from fnd_lookup_values
    where lookup_type = 'IEX_UWQ_NODE_STATUS' and LANGUAGE = userenv('LANG');

  CURSOR c_node_label(in_lookup_type VARCHAR2,in_lookup_code VARCHAR2) IS
    SELECT meaning
    FROM fnd_lookup_values
    WHERE lookup_type = in_lookup_type
    AND lookup_code = in_lookup_code
    AND LANGUAGE = userenv('LANG');

  CURSOR c_sel_enum(in_sel_enum_id NUMBER) IS
    SELECT work_q_view_for_primary_node, work_q_label_lu_type, work_q_label_lu_code
    FROM ieu_uwq_sel_enumerators
    WHERE sel_enum_id = in_sel_enum_id;

  l_sel_enum_rec c_sel_enum%ROWTYPE;

  l_data_source VARCHAR2(1000);
  l_default_where VARCHAR2(1000);
  l_security_where VARCHAR2(2000);
  l_node_where VARCHAR2(2000);
  l_uwq_where VARCHAR2(1000);

  type tbl_wclause is table of varchar2(500) index by binary_integer;

  l_wclause tbl_wclause;
  l_str_bkr VARCHAR2(1000);
  l_view_name VARCHAR2(240);
  l_refresh_view_name VARCHAR2(240);
  --l_org_id NUMBER; -- commented for bug 8826561 PNAVEENK
  l_Complete_Days VARCHAR2(40);
  l_bkr_filter VARCHAR2(240);
  l_str1  VARCHAR2(2000);
  l_str_and VARCHAR2(100);
  l_str_prom VARCHAR2(1000);
  l_check NUMBER;
  l_EnableNodes   varchar2(10);
  l_collector_id number;
  l_resource_id number;

  CURSOR c_collector_id IS
      SELECT collector_id from AR_COLLECTORS where resource_id = p_resource_id
        and resource_type = 'RS_RESOURCE';

  CURSOR c_person IS
      select source_id
      from jtf_rs_resource_extns
      where resource_id = p_resource_id;

  CURSOR c_strategy_level IS
    SELECT PREFERENCE_VALUE
	FROM IEX_APP_PREFERENCES_B
    WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
    and org_id is null
    and enabled_flag='Y';

  l_strategy_level VARCHAR2(30);
  l_temp_str	   varchar2(5);  -- Added for bug 8537638 PNAVEENK 11-8-2009
    --begin bug#6717849 schekuri 31-Jul-2009
  l_level_count number;
  cursor c_multi_level
  is select lookup_code
  from iex_lookups_v
  where lookup_type='IEX_RUNNING_LEVEL'
  and lookup_code= 'BILL_TO'
  and  iex_utilities.validate_running_level(LOOKUP_CODE)='Y';
  --end bug#6717849 schekuri 31-Jul-2009

BEGIN

  SET_MO_GLOBAL;

  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
  --l_org_id  := TO_NUMBER(oe_profile.value('OE_ORGANIZATION_ID', fnd_profile.value('ORG_ID'))); -- commented for bug 8826561 PNAVEENK
  l_Access := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  l_node_counter := 0;

  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;

  -- Start bug 5874874 gnramasa 25-Apr-07
  l_data_source := 'IEX_BILLTO_PRO_ALL_UWQ';
  l_view_name := 'IEX_CU_PRO_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_PRO_ALL_UWQ_V';

  /*
  l_str_bkr := ' AND NUMBER_OF_BANKRUPTCIES = 0 ';


  IF l_Access = 'T' then
   SELECT count(*) INTO l_check FROM iex_assignments where
   alt_resource_id =  p_RESOURCE_ID
   AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
   AND NVL(DELETED_FLAG,'N') = 'N';
  END IF;

   IF (l_level = 'PARTY') then
     IF (l_check > 0 ) then
       l_str1   := ASSIGNMENTS_WHERE_CLAUSE('PARTY', l_sel_enum_rec.work_q_view_for_primary_node) || ' AND ' || RESOURCES_WHERE_CLAUSE('PARTY', l_sel_enum_rec.work_q_view_for_primary_node) || ' ) ';
     ELSE
       l_str1   :=  RESOURCES_WHERE_CLAUSE('PARTY', l_sel_enum_rec.work_q_view_for_primary_node);
     END IF;
   ELSIF (l_level = 'ACCOUNT') then
     IF (l_check > 0 ) then
       l_str1   := ASSIGNMENTS_WHERE_CLAUSE('ACCOUNT', l_sel_enum_rec.work_q_view_for_primary_node) || ' AND ' || RESOURCES_WHERE_CLAUSE('ACCOUNT', l_sel_enum_rec.work_q_view_for_primary_node) || ' ) ';
     ELSE
       l_str1   :=  RESOURCES_WHERE_CLAUSE('ACCOUNT', l_sel_enum_rec.work_q_view_for_primary_node);
     END IF;
   ELSE
     IF l_check > 0 then
       l_str1   := ASSIGNMENTS_WHERE_CLAUSE('BILLTO', l_sel_enum_rec.work_q_view_for_primary_node) || ' AND ' || RESOURCES_WHERE_CLAUSE('BILLTO', l_sel_enum_rec.work_q_view_for_primary_node) || ' ) ';
     ELSE
       l_str1   :=  RESOURCES_WHERE_CLAUSE('BILLTO', l_sel_enum_rec.work_q_view_for_primary_node);
     END IF;
  END IF;

  l_security_where := l_str1;

  l_default_where := ' ( RESOURCE_ID = :RESOURCE_ID OR'  || ASSIGNMENTS_WHERE_CLAUSE('BILLTO', l_view_name) || ' ) ';


  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
  l_bind_list(1).bind_var_value := 1;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  l_bind_list(2).bind_var_name := ':REAL_RESOURCE_ID';
  l_bind_list(2).bind_var_value := p_resource_id;
  l_bind_list(2).bind_var_data_type := 'NUMBER' ;

  IF ( l_access in ('F', 'P')) THEN
    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_prom || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_prom;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  ELSE

    -- No count view when the security is enabled
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;

    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;

    l_bind_list(3).bind_var_name := ':PERSON_ID' ;
    l_bind_list(3).bind_var_value := l_person_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_prom || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_prom;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;
 */

  OPEN c_strategy_level;
  FETCH c_strategy_level INTO l_strategy_level;
  CLOSE c_strategy_level;

      --begin bug#6717849 schekuri 31-Jul-2009
  select count(1)
  into l_level_count
  from iex_lookups_v
  where lookup_type='IEX_RUNNING_LEVEL'
  and  iex_utilities.validate_running_level(LOOKUP_CODE)='Y';

  if l_level_count>1 then
  open c_multi_level;
  fetch c_multi_level into l_strategy_level;
  close c_multi_level;
  end if;
  --end bug#6717849 schekuri 31-Jul-2009

  IF l_strategy_level = 'BILL_TO' THEN
    l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

   -- l_default_where :=' IEU_PARAM_PK_COL=''CUSTOMER_SITE_USE_ID'' and '||attach_where_clause(p_resource_id); --bug#6717849 schekuri 31-Jul-2009
      l_default_where :=' IEU_PARAM_PK_COL=''CUSTOMER_SITE_USE_ID'' ' || attach_where_clause(p_resource_id); -- bug 8537638 PNAVEENK 11-8-2009
    l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where;

    IF (l_access = 'T' ) THEN
      OPEN c_collector_id;
      FETCH c_collector_id INTO l_collector_id;
      CLOSE c_collector_id;

      OPEN c_person;
      FETCH c_person INTO l_person_id;
      CLOSE c_person;

      l_bind_list(1).bind_var_name := ':PERSON_ID' ;
      l_bind_list(1).bind_var_value := l_person_id;
      l_bind_list(1).bind_var_data_type := 'NUMBER' ;

      l_bind_list(2).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
      l_bind_list(2).bind_var_value := p_resource_id;
      l_bind_list(2).bind_var_data_type := 'NUMBER' ;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
    ELSE    -- bug 9453423 PNAVEENK
       IF l_default_where IS NULL THEN
          l_ld_list(l_node_counter).WHERE_CLAUSE := ' RESOURCE_ID = :RESOURCE_ID';

	  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
          l_bind_list(1).bind_var_value := 1;
          l_bind_list(1).bind_var_data_type := 'NUMBER' ;

          l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
       END IF;
    END IF;
  ELSE  /* IF l_strategy_level <> 'BILL_TO' */

    l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
    l_ld_list(l_node_counter).VIEW_NAME := l_sel_enum_rec.work_q_view_for_primary_node;
    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

    l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND :UWQ_STATUS = :UWQ_STATUS ';

    l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
    l_bind_list(1).bind_var_value := 'ALL';
    l_bind_list(1).bind_var_data_type := 'CHAR' ;

    l_bind_list(2).bind_var_name := ':RESOURCE_ID';
    l_bind_list(2).bind_var_value := -1;
    l_bind_list(2).bind_var_data_type := 'NUMBER' ;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;


  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;
  -- End bug 5874874 gnramasa 25-Apr-07

  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.LogMessage('ENUMERATE_BILLTO_PROM_NODES: main final where clause: ' || l_ld_list(l_node_counter).WHERE_CLAUSE);
  END IF;

  -- !!
  -- !!!!!!!!!! BUILDING SUB NODES WHERE CLAUSE
  -- !!

  l_node_counter := l_node_counter + 1;


  l_EnableNodes :=  NVL(FND_PROFILE.VALUE('IEX_ENABLE_UWQ_STATUS'),'N');

  if (l_EnableNodes <> 'N') then
  l_view_name := 'IEX_CU_PRO_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_PRO_ALL_UWQ_V';

  -- Start for bug 8537638 PNAVEENK 31-8-2009
  if l_ld_list(0).WHERE_CLAUSE is not null then
	l_temp_str := ' and ';
    else
	l_temp_str := ' ';
    end if;

  FOR cur_rec IN c_del_new_nodes LOOP
	IF l_strategy_level = 'BILL_TO' THEN
	    IF (cur_rec.lookup_code = 'ACTIVE') THEN
	      l_data_source := 'IEX_BILLTO_PRO_ACT_UWQ';
	      --l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and active_promises is not null';
	      --l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(active_promises,0)  > 0 ';
	      l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(active_promises,0)  > 0 ';
	    ELSIF (cur_rec.lookup_code = 'PENDING') THEN
	      l_data_source := 'IEX_BILLTO_PRO_PEND_UWQ';
	      --l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and pending_promises is not null';
	      -- l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(pending_promises,0)  > 0 ';
	        l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(pending_promises,0)  > 0 ';
	    ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
	      l_data_source := 'IEX_BILLTO_PRO_COMP_UWQ';
	      --l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and complete_promises is not null';
	      --l_node_where := l_ld_list(0).WHERE_CLAUSE || ' and NVL(complete_promises,0)  > 0 ';
	       l_node_where := l_ld_list(0).WHERE_CLAUSE || l_temp_str || ' NVL(complete_promises,0)  > 0 ';
	    END IF;
           -- end for bug 8537638

	l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
	l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
	l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
	l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;


	l_ld_list(l_node_counter).WHERE_CLAUSE := l_node_where;
	l_ld_list(l_node_counter).BIND_VARS    := l_ld_list(0).BIND_VARS;

	ELSE  /* IF l_strategy_level <> 'BILL_TO' */

		l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
		l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
		l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
		l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

		l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID AND :UWQ_STATUS = :UWQ_STATUS ';

		l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
		l_bind_list(1).bind_var_value := 'ALL';
		l_bind_list(1).bind_var_data_type := 'CHAR' ;

		l_bind_list(2).bind_var_name := ':RESOURCE_ID';
		l_bind_list(2).bind_var_value := -1;
		l_bind_list(2).bind_var_data_type := 'NUMBER' ;

		l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
	END IF;

    l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_ld_list(l_node_counter).NODE_TYPE := 0;
    l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_ld_list(l_node_counter).NODE_DEPTH := 2;

    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';


    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage('ENUMERATE_BILLTO_PROM_NODES: Subnode final where clause: ' || l_ld_list(l_node_counter).WHERE_CLAUSE);
    END IF;

    l_node_counter := l_node_counter + 1;
  END LOOP;

  END IF;

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'iex',  'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM );
    End if;
    RAISE;

END ENUMERATE_BILLTO_PROM_NODES;


FUNCTION ATTACH_WHERE_CLAUSE(P_RESOURCE_ID NUMBER) return varchar2 IS
l_check number := 0;
l_collector_id number;
l_security_where varchar2(2000);

l_Access varchar2(1)   := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
l_bkr_filter varchar2(1) := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
l_person_id number;

l_bind_list IEU_PUB.BindVariableRecordList ;
l_ld_list  IEU_PUB.EnumeratorDataRecordList;
l_group_check number := 0;

BEGIN

    IF (l_Access = 'T') THEN
      SELECT count(*) INTO l_check FROM iex_assignments where
      alt_resource_id = p_RESOURCE_ID
      AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
      AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
      AND NVL(DELETED_FLAG,'N') = 'N';

      select count(1) into l_group_check
      from ar_collectors where status='A' and
      nvl(inactive_date,sysdate)>=sysdate and resource_type='RS_GROUP';


     if l_check>0 or l_group_check>0 then
        l_security_where := ' :person_id = :person_id and collector_resource_id in (select resource_id from ar_collectors where resource_type = ''RS_RESOURCE'' and resource_id = :COLLECTOR_RESOURCE_ID ';
     else
	    l_security_where := ' :person_id = :person_id and collector_resource_id = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 then
	    l_security_where := l_security_where ||
                ' union all SELECT ac.resource_id FROM iex_assignments iea,ar_collectors ac where '||
                ' iea.alt_employee_id = :PERSON_ID '||
                ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
                ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' '||
                ' and ac.resource_id=iea.resource_id '||
                ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP'') ';
     end if;

     if l_group_check>0 then
        l_security_where := l_security_where ||
                ' union all SELECT ac.resource_ID '||
			    ' FROM ar_collectors ac , jtf_rs_group_members jtgrp '||
			    ' WHERE ac.resource_ID = jtgrp.group_id '||
			    ' AND ac.resource_type = ''RS_GROUP'''||
			    ' AND NVL(jtgrp.delete_flag,''N'') = ''N'''||
			    ' AND jtgrp.resource_ID = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 or l_group_check>0 then
	    l_security_where := l_security_where || ' ) ';
     end if;


     IF (l_bkr_filter = 'Y') THEN
       l_security_where := l_security_where || ' AND NUMBER_OF_BANKRUPTCIES = 0 ';
     END IF;
  ELSE  --full mode
     IF (l_bkr_filter = 'Y') THEN
       l_security_where := l_security_where || ' NUMBER_OF_BANKRUPTCIES = 0 ';
     END IF;
  END IF;



  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.LogMessage('RESOURCES_WHERE_CLAUSE: final where clause: ' || l_security_where  );
  END IF;
  -- Start for bug 8538637 PNAVEENK 11-8-2009
  if l_security_where is not null then
   l_security_where := 'and ' || l_security_where;
   return l_security_where;
  else
   return null;
  end if;
  -- end for bug 8538637
EXCEPTION WHEN OTHERS THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	iex_debug_pub.LogMessage('Error occurred while constructing the where clause ' || sqlerrm);
 END IF;

 return null;

END ATTACH_WHERE_CLAUSE;

-- PL/SQL Block
BEGIN
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
END IEX_UWQ_PROM_ENUMS_PVT;

/
