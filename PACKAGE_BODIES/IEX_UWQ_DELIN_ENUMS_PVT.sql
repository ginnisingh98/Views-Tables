--------------------------------------------------------
--  DDL for Package Body IEX_UWQ_DELIN_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_UWQ_DELIN_ENUMS_PVT" AS
/* $Header: iexendlb.pls 120.28.12010000.7 2009/08/07 11:05:45 schekuri ship $ */

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

PROCEDURE ENUMERATE_DELIN_NODES
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
  -- Territory Assignment Changes
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
  -- Start for bug 8708271 PNAVEENK
  CURSOR c_ml_setup IS
  select DEFINE_PARTY_RUNNING_LEVEL,DEFINE_OU_RUNNING_LEVEL
  from IEX_QUESTIONNAIRE_ITEMS;
  -- end for bug 8708271
  l_sel_enum_rec c_sel_enum%ROWTYPE;

  l_Complete_Days varchar2(40);
  l_data_source VARCHAR2(1000);
  l_default_where VARCHAR2(1000);
  l_security_where VARCHAR2(2000);
  l_node_where VARCHAR2(2000);
  l_uwq_where VARCHAR2(1000);
  l_org_id NUMBER;

  type tbl_wclause is table of varchar2(500) index by binary_integer;

  l_wclause tbl_wclause;
  l_str_and VARCHAR2(100);
  l_str_del   VARCHAR2(1000);
  l_str_bkr VARCHAR2(1000);
  l_str_bkr2 VARCHAR2(1000);

  l_bkr_filter VARCHAR2(240);
  l_check      NUMBER;

  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes   varchar2(10);
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-node

  l_additional_where VARCHAR2(2500);

  -- Bug #6311505 bibeura 23-Oct-2007
  l_strategy_level varchar2(100);
  l_filter_col_str1 varchar2(1000);
  l_filter_col_str2 varchar2(1000);
  l_filter_cond_str varchar2(1000);

  l_party_override varchar2(1); -- Added for bug 8708271 PNAVEENK
  l_org_override varchar2(1); -- Added for bug 8708271 PNAVEENK

BEGIN

  -- SAVEPOINT start_delin_enumeration;
  --Moac Changes Start. Set the context.
  MO_GLOBAL.INIT('IEX');
  MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);
  --Moac Changes End. Set the context.

  l_str_and  := ' AND ';
  l_str_del  := ' AND NUMBER_OF_DELINQUENCIES > 0 ';
  l_node_counter := 0;
  l_check   := 0;

  l_Access   := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  l_Level    :=  NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
  --Bug4221359. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
  /* l_additional_where :=
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp, ' ||
	  ' JTF_RS_GROUPS_DENORM jrg ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  ' AND jtgrp.group_id = jrg.group_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID ) ';
   */
  --Bug4221359. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

  --Begin Bug #6311505 bibeura 23-Oct-2007
  select preference_value
  into l_strategy_level
  from iex_app_preferences_b
  where preference_name='COLLECTIONS STRATEGY LEVEL'
  and org_id is null
  and enabled_flag='Y';
  -- Start for bug 8708271 PNAVEENK
  open c_ml_setup;
  fetch c_ml_setup into l_party_override,l_org_override;
  close c_ml_setup;

  if l_party_override = 'Y' or l_org_override = 'Y' then
     l_strategy_level := 'DELINQUENCY';
  end if;
  if l_strategy_level='CUSTOMER' then
	l_filter_col_str1 := 'customer_id in (select hp.party_id ';
	l_filter_col_str2 := 'select hp.party_id ';
	l_filter_cond_str := ' AND hp.cust_account_id = -1 '||
			     ' AND hp.site_use_id is null ';
  elsif l_strategy_level='ACCOUNT' then
        l_filter_col_str1 := 'cust_account_id in (select hp.cust_account_id ';
	l_filter_col_str2 := 'select hp.cust_account_id ';
	l_filter_cond_str := ' AND hp.cust_account_id <> -1 ' ||
	                     ' AND hp.site_use_id is null ';
  elsif l_strategy_level='BILL_TO' then
        l_filter_col_str1 := 'site_use_id in (select hp.site_use_id ';
	l_filter_col_str2 := 'select hp.site_use_id ';
	l_filter_cond_str := ' AND hp.site_use_id is not null ';
  else
	l_filter_col_str1 := 'customer_id in (select hp.party_id ';
	l_filter_col_str2 := 'select hp.party_id ';
	l_filter_cond_str := ' ';
  end if;
  --End Bug #6311505 bibeura 23-Oct-2007

  l_wclause(1) :=
        ' (RESOURCE_ID = :RESOURCE_ID) and ' ||
        ' (UWQ_STATUS IS NULL or  UWQ_STATUS = :UWQ_STATUS or ' ||
        '  (trunc(UWQ_ACTIVE_DATE) <= trunc(SYSDATE) and UWQ_STATUS = ''PENDING'' )) ';

  l_wclause(2) :=
        ' (RESOURCE_ID = :RESOURCE_ID) and ' ||
        ' (UWQ_STATUS = :UWQ_STATUS and (trunc(UWQ_ACTIVE_DATE) > trunc(SYSDATE))) ';

  l_wclause(3) :=
        ' (RESOURCE_ID = :RESOURCE_ID) and ' ||
        ' (UWQ_STATUS = :UWQ_STATUS and (trunc(UWQ_COMPLETE_DATE) + ' || l_Complete_Days || ' >  trunc(SYSDATE))) ';

  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;

  l_data_source := 'IEX_DELINQUENCIES_UWQ';

  l_str_bkr := ' AND NUMBER_OF_BANKRUPTCIES = 0 ';
 -- Start for bug#7693986 by PNAVEENK on 12-1-2009
 /* l_str_bkr2 := ' AND NOT EXISTS (SELECT 1 FROM iex_bankruptcies bkr WHERE bkr.party_id = '
  || l_sel_enum_rec.work_q_view_for_primary_node || '.customer_id '
  --Bug5261831. Fix By LKKUMAR on 14-Jun-2006. Start.
  || ' AND NVL(BKR.DISPOSITION_CODE,''GRANTED'') NOT IN (''DISMISSED'',''NEGOTIATION'',''WITHDRAWN'')) ';
  --Bug5261831. Fix By LKKUMAR on 14-Jun-2006. End.
*/

 IF p_sel_enum_id = 13069 THEN
    l_str_bkr2 := ' AND NOT EXISTS (SELECT 1  FROM iex_bankruptcies bkr WHERE bkr.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.customer_id and NVL(BKR.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ) ' ;
 -- Commented for bug#8536993 by PNAVEENK on 21-5-2009
 -- ELSE
 --   l_str_bkr2 :=  ' AND NOT EXISTS (SELECT 1 FROM iex_bankruptcies bkr WHERE bkr.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.party_id and NVL(BKR.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ) ' ;
 -- end for bug#8536993
  END IF;
  -- End for bug#7693986
  l_default_where := ' RESOURCE_ID = :RESOURCE_ID AND :UWQ_STATUS = :UWQ_STATUS ';

  -- Territory Assignment Changes
  IF (l_Access = 'T') THEN
   SELECT count(*) into l_check from iex_assignments where
   alt_resource_id =  p_RESOURCE_ID
   AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
   AND NVL(DELETED_FLAG,'N') = 'N';
  END IF;

  If (l_check > 0) then
        l_security_where :=
          --'customer_id in (select hp.party_id '||
	  l_filter_col_str1||       -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
	  l_filter_cond_str||        -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1 ' || Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
          --' UNION ALL select hp.party_id '||
	  ' UNION ALL '|| l_filter_col_str2  ||   -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
	  l_filter_cond_str||            -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1 ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
	  ' UNION ALL ' || l_filter_col_str2 ||  -- Added for Bug #6311505 bibeura 23-Oct-2007
          --' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  l_filter_cond_str||            -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1   ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  )'; -- Changed by gnramasa for bug 6363290 27-Aug-07

    if l_party_override = 'Y' then
       if l_org_override = 'Y' then
          l_security_where := l_security_where || ' AND iex_utilities.get_party_running_level (iex_delinquencies_uwq_v.customer_id , iex_delinquencies_uwq_v.org_id ) = ''DELINQUENCY'' ';
       else
           l_security_where := l_security_where || ' and exists ( select 1 from hz_party_preferences hzprf where hzprf.value_varchar2= ''DELINQUENCY'' '
	                                                         ||' and hzprf.module= ''COLLECTIONS''and hzprf.category = ''COLLECTIONS LEVEL'' '
								 ||' and hzprf.preference_code = ''PARTY_ID'' and hzprf.party_id= iex_delinquencies_uwq_v.customer_id) ';
       end if;
    else
       if l_org_override = 'Y' then
          l_security_where := l_security_where || ' and exists (select 1 from iex_app_preferences_b pref where pref.preference_name=''COLLECTIONS STRATEGY LEVEL'' '
	                                          ||' and pref.preference_value=''DELINQUENCY'' and pref.org_id = iex_delinquencies_uwq_v.org_id) ';
       end if;
    end if;
          --Bug4221359. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
  	  l_security_where := l_security_where || l_additional_where;
          --Bug4221359. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
   Else
        l_security_where :=
          --'customer_id in (select hp.party_id '||
	  l_filter_col_str1 ||                -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
	  l_filter_cond_str ||                -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1 ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          --' UNION ALL  SELECT hp.party_id ' ||
	  ' UNION ALL ' || l_filter_col_str2  ||      -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  l_filter_cond_str ||          -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1   ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  )'; -- Changed by gnramasa for bug 6363290 27-Aug-07
      if l_party_override = 'Y' then
       if l_org_override = 'Y' then
          l_security_where := l_security_where || ' AND iex_utilities.get_party_running_level (iex_delinquencies_uwq_v.customer_id , iex_delinquencies_uwq_v.org_id ) = ''DELINQUENCY'' ';
       else
           l_security_where := l_security_where || ' and exists ( select 1 from hz_party_preferences hzprf where hzprf.value_varchar2= ''DELINQUENCY'' '
	                                                          ||' and hzprf.module=''COLLECTIONS'' and hzprf.category = ''COLLECTIONS LEVEL''  '
								  ||' and hzprf.preference_code = ''PARTY_ID'' and hzprf.party_id = iex_delinquencies_uwq_v.customer_id) ';
       end if;
      else
       if l_org_override = 'Y' then
          l_security_where := l_security_where || ' and exists (select 1 from iex_app_preferences_b pref where pref.preference_name=''COLLECTIONS STRATEGY LEVEL'' '
	                                          ||' and pref.preference_value=''DELINQUENCY'' and pref.org_id=iex_delinquencies_uwq_v.org_id) ';
       end if;
      end if;
	  -- end for bug 8708271
	  --Bug4221359. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
  	  l_security_where := l_security_where || l_additional_where;
          --Bug4221359. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
   End If;


  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := l_sel_enum_rec.work_q_view_for_primary_node;
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

  l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
  l_bind_list(1).bind_var_value := 'ALL';
  l_bind_list(1).bind_var_data_type := 'CHAR' ;

  l_bind_list(2).bind_var_name := ':RESOURCE_ID';
  l_bind_list(2).bind_var_value := 1;
  l_bind_list(2).bind_var_data_type := 'NUMBER' ;

  IF ( l_access in ('F', 'P')) THEN
    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_bkr2;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  ELSE
    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;

    l_bind_list(3).bind_var_name := ':PERSON_ID' ;
    l_bind_list(3).bind_var_value := l_person_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_bkr2;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;

  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;


  l_node_counter := l_node_counter + 1;


  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes :=  NVL(FND_PROFILE.VALUE('IEX_ENABLE_UWQ_STATUS'),'N');

  if (l_EnableNodes <> 'N') then
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes

  FOR cur_rec IN c_del_new_nodes LOOP
    IF (cur_rec.lookup_code = 'ACTIVE') THEN
      l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
      l_bind_list(1).bind_var_value := 'ACTIVE';
      l_bind_list(1).bind_var_data_type := 'CHAR' ;
      l_uwq_where := l_wclause(1);
      l_node_where := l_default_where || ' AND ACTIVE_DELINQUENCIES > 0 ';
    ELSIF (cur_rec.lookup_code = 'PENDING') THEN
      l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
      l_bind_list(1).bind_var_value := 'PENDING';
      l_bind_list(1).bind_var_data_type := 'CHAR' ;
      l_uwq_where := l_wclause(2);
      l_node_where := l_default_where || ' AND PENDING_DELINQUENCIES > 0 ';
    ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
      l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
      l_bind_list(1).bind_var_value := 'COMPLETE';
      l_bind_list(1).bind_var_data_type := 'CHAR' ;
      l_uwq_where := l_wclause(3);
      l_node_where := l_default_where || ' AND COMPLETE_DELINQUENCIES > 0 ';
    END IF;

    If (l_check > 0) then
        l_security_where :=
          --'customer_id in (select hp.party_id '||
	  l_filter_col_str1||  -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
	  l_filter_cond_str||   -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1 ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
          --' UNION ALL select hp.party_id '||
	  ' UNION ALL ' || l_filter_col_str2  ||    -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
	  l_filter_cond_str||         -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1 ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          --' UNION ALL  SELECT hp.party_id ' ||
	  ' UNION ALL ' || l_filter_col_str2  ||     -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  l_filter_cond_str||                -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1   ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
   	  l_security_where := l_security_where || l_additional_where;
   Else
        l_security_where :=
          --'customer_id in (select hp.party_id '||
	  l_filter_col_str1||           -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
	  l_filter_cond_str||           -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1 ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          --' UNION ALL  SELECT hp.party_id ' ||
	  ' UNION ALL ' || l_filter_col_str2  ||       -- Added for Bug #6311505 bibeura 23-Oct-2007
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  l_filter_cond_str    ||              -- Added for Bug #6311505 bibeura 23-Oct-2007
          -- ' AND hp.cust_account_id = -1   ' ||  Bug4775052. Fix By LKKUMAR on 29-Nov-2005
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
   	 l_security_where := l_security_where || l_additional_where;
   End If;

    l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
    l_ld_list(l_node_counter).VIEW_NAME := l_sel_enum_rec.work_q_view_for_primary_node;
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

    l_bind_list(2).bind_var_name := ':RESOURCE_ID' ;
    l_bind_list(2).bind_var_value := 1;
    l_bind_list(2).bind_var_data_type := 'NUMBER' ;

    IF ( l_access in ('P', 'F')) THEN
      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_uwq_where || l_str_bkr2;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_uwq_where;
      END IF;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;

    ELSE
      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_uwq_where || l_str_and || l_security_where || l_str_bkr2;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_uwq_where || l_str_and || l_security_where;
      END IF;

      l_bind_list(3).bind_var_name := ':PERSON_ID' ;
      l_bind_list(3).bind_var_value := l_person_id;
      l_bind_list(3).bind_var_data_type := 'NUMBER' ;
      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
    END IF;

    l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_ld_list(l_node_counter).NODE_TYPE := 0;
    l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_ld_list(l_node_counter).NODE_DEPTH := 2;

    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

    l_node_counter := l_node_counter + 1;
  END LOOP;
  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  end if;
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes


  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    -- ROLLBACK TO start_delin_enumeration;
    RAISE;

END ENUMERATE_DELIN_NODES;

-- added by jypark 09/26/2004 for performance

PROCEDURE ENUMERATE_CU_DELIN_NODES
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
  --Territory Assignment Changes.
  l_Access   Varchar2(10);
  l_Level    Varchar2(15);
  l_person_id NUMBER;
  l_check     NUMBER;
  l_collector_id NUMBER;  -- 5874874

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

  CURSOR c_collector_id IS
    SELECT collector_id from AR_COLLECTORS where resource_id = p_resource_id
      and resource_type = 'RS_RESOURCE';

  l_sel_enum_rec c_sel_enum%ROWTYPE;

  l_Complete_Days varchar2(40);
  l_data_source VARCHAR2(1000);
  l_default_where VARCHAR2(1000);
  l_security_where VARCHAR2(2000);
  l_node_where VARCHAR2(2000);
  l_uwq_where VARCHAR2(1000);
  l_org_id NUMBER;

  type tbl_wclause is table of varchar2(500) index by binary_integer;

  l_str_and VARCHAR2(100);
  l_str_del   VARCHAR2(1000);
  l_str_bkr VARCHAR2(1000);

  l_bkr_filter VARCHAR2(240);
  l_view_name VARCHAR2(240);
  l_refresh_view_name VARCHAR2(240);
  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes   varchar2(10);
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-node

  l_additional_where VARCHAR2(2000);

  L VARCHAR2(240);

  CURSOR C_ORG_ID IS SELECT ORGANIZATION_ID FROM HR_OPERATING_UNITS
    WHERE MO_GLOBAL.CHECK_ACCESS(ORGANIZATION_ID) = 'Y';

  CURSOR c_strategy_level IS
    SELECT PREFERENCE_VALUE
	FROM IEX_APP_PREFERENCES_B
    WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
    and org_id is null
    and enabled_flag='Y';

  l_strategy_level VARCHAR2(30);

  l_group_check number;

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
  -- SAVEPOINT start_delin_enumeration;

  SET_MO_GLOBAL;


  l_Access   := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  l_Level    :=  NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');

  --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
  /* l_additional_where :=
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp, ' ||
	  ' JTF_RS_GROUPS_DENORM jrg ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  ' AND jtgrp.group_id = jrg.group_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID ) ';
  */
  --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.


  l_str_and  := ' AND ';
  l_str_del   := ' AND NUMBER_OF_DELINQUENCIES > 0 ';
  l_node_counter := 0;
  l_check     := 0;

  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;

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

  l_data_source := 'IEX_CU_DLN_ALL_UWQ';
  l_view_name := 'IEX_CU_DLN_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_DLN_ALL_UWQ_V';

 IF l_strategy_level = 'CUSTOMER' THEN
  l_str_bkr := ' AND NUMBER_OF_BANKRUPTCIES = 0 ';

  l_data_source := 'IEX_CU_DLN_ALL_UWQ';
  l_view_name := 'IEX_CU_DLN_ALL_UWQ_V';
  --Bug5237039. Performance Fix by LKKUMAR on 24-May-2006. Start.
  -- l_refresh_view_name := 'IEX_CU_DLN_CNT_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_DLN_ALL_UWQ_V';
  --Bug5237039. Performance Fix by LKKUMAR on 24-May-2006. End.

  l_default_where := ' RESOURCE_ID = :RESOURCE_ID and IEU_PARAM_PK_COL=''PARTY_ID'' ';

  -- Territory Assignment Changes
  IF (l_Access = 'T') THEN
   OPEN c_collector_id;
   FETCH c_collector_ID INTO l_collector_id;
   CLOSE c_collector_id;

   SELECT count(*) INTO l_check FROM iex_assignments where
   alt_resource_id = p_RESOURCE_ID
   AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
   AND NVL(DELETED_FLAG,'N') = 'N';

   select count(1) into l_group_check
   from ar_collectors where status='A' and
   nvl(inactive_date,sysdate)>=sysdate and resource_type='RS_GROUP';

  END IF;

  --Start bug#5874874 gnramasa 25-Apr-2007
  /* If (l_check > 0 ) then
    l_security_where :=
          'party_id in  (select hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.resource_id = iea.resource_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE)  ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles  hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
      --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
      l_security_where := l_security_where || l_additional_where;
      --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

  Else
     l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles  hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
     --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
     l_security_where := l_security_where || l_additional_where;
     --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
  End If; */

     if l_check>0 or l_group_check>0 then
        --l_security_where := ' :person_id = :person_id and collector_resource_id in (select :COLLECTOR_RESOURCE_ID from dual ';
        l_security_where := ' :person_id = :person_id and collector_resource_id in (select resource_id from ar_collectors where resource_type = ''RS_RESOURCE'' and resource_id = :COLLECTOR_RESOURCE_ID ';

     else
	l_security_where := ' :person_id = :person_id and collector_resource_id = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 then
	l_security_where := l_security_where || ' union all SELECT ac.resource_id FROM iex_assignments iea,ar_collectors ac where '||
    	                    ' iea.alt_employee_id = :PERSON_ID '||
			    ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
			    ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                            ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' '||
                            ' and ac.resource_id=iea.resource_id '||
                            ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP'') ';
     end if;

     if l_group_check>0 then
        l_security_where := l_security_where || ' union all SELECT ac.resource_ID '||
			    ' FROM ar_collectors ac , jtf_rs_group_members jtgrp '||
			    ' WHERE ac.resource_ID = jtgrp.group_id '||
			    ' AND ac.resource_type = ''RS_GROUP'''||
			    ' AND NVL(jtgrp.delete_flag,''N'') = ''N'''||
			    ' AND jtgrp.resource_ID = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 or l_group_check>0 then
	l_security_where := l_security_where || ' ) ';
     end if;
  --End bug#5874874 gnramasa 25-Apr-2007

  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
  l_bind_list(1).bind_var_value := 1;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  IF ( l_access in ('F', 'P')) THEN
    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_del || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_del;
    END IF;
    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  ELSE

    /* No count view when the security is enabled */
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;

    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;

    l_bind_list(2).bind_var_name := ':PERSON_ID' ;
    l_bind_list(2).bind_var_value := l_person_id;
    l_bind_list(2).bind_var_data_type := 'NUMBER' ;

    l_bind_list(3).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
    l_bind_list(3).bind_var_value := p_resource_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_del || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_del;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;
ELSE  /* IF l_strategy_level <> 'CUSTOMER' */

    l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;
    l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID';

    l_bind_list(1).bind_var_name := ':RESOURCE_ID';
    l_bind_list(1).bind_var_value := -1;
    l_bind_list(1).bind_var_data_type := 'NUMBER' ;
    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
END IF;

  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;


  l_node_counter := l_node_counter + 1;
  --l_check := 0;

  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes :=  NVL(FND_PROFILE.VALUE('IEX_ENABLE_UWQ_STATUS'),'N');

  if (l_EnableNodes <> 'N') then
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes

  FOR cur_rec IN c_del_new_nodes LOOP
    IF l_strategy_level = 'CUSTOMER' THEN
      IF (cur_rec.lookup_code = 'ACTIVE') THEN
        --Bug5237039. Performance Fix by LKKUMAR on 24-May-2006. Start.
        l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0  AND ACTIVE_DELINQUENCIES IS NOT NULL ';
        l_data_source := 'IEX_CU_DLN_ACT_UWQ';
        --l_view_name := 'IEX_CU_DLN_ACT_UWQ_V';
        --l_refresh_view_name := 'IEX_CU_DLN_CNT_ACT_UWQ_V';
        l_view_name          := 'IEX_CU_DLN_ALL_UWQ_V';
        l_refresh_view_name  := 'IEX_CU_DLN_ALL_UWQ_V';
        --Bug5237039. Performance Fix by LKKUMAR on 24-May-2006. End.

    ELSIF (cur_rec.lookup_code = 'PENDING') THEN
      --Bug5237039. Performance Fix by LKKUMAR on 24-May-2006. Start.
      l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0 AND PENDING_DELINQUENCIES IS NOT NULL ';
      l_data_source := 'IEX_CU_DLN_PEND_UWQ';
      -- l_view_name := 'IEX_CU_DLN_PEND_UWQ_V';
      -- l_refresh_view_name := 'IEX_CU_DLN_CNT_PEND_UWQ_V';
      l_view_name          := 'IEX_CU_DLN_ALL_UWQ_V';
      l_refresh_view_name  := 'IEX_CU_DLN_ALL_UWQ_V';
      --Bug5237039. Performance Fix by LKKUMAR on 24-May-2006. End.

    ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
      --Bug5237039. Performance Fix by LKKUMAR on 24-May-2006. Start.
      l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0 AND COMPLETE_DELINQUENCIES IS NOT NULL ';
      l_data_source := 'IEX_CU_DLN_COMP_UWQ';
      -- l_view_name := 'IEX_CU_DLN_COMP_UWQ_V';
      -- l_refresh_view_name := 'IEX_CU_DLN_CNT_COMP_UWQ_V';
      l_view_name          := 'IEX_CU_DLN_ALL_UWQ_V';
      l_refresh_view_name  := 'IEX_CU_DLN_ALL_UWQ_V';
      --Bug5237039. Performance Fix by LKKUMAR on 24-May-2006. End.

    END IF;

    --Start bug#5874874 gnramasa 25-Apr-2007
     /* If (l_check > 0 ) then
      l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.resource_id = iea.resource_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID   ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND hp.cust_account_id = -1  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
          --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	  l_security_where := l_security_where || l_additional_where;
          --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND hp.cust_account_id = -1  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
          --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	  l_security_where := l_security_where || l_additional_where;
          --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     End If; */


     if l_check>0 or l_group_check>0 then
        --l_security_where := ' :person_id = :person_id and collector_resource_id in (select :COLLECTOR_RESOURCE_ID from dual ';
        l_security_where := ' :person_id = :person_id and collector_resource_id in (select resource_id from ar_collectors where resource_type = ''RS_RESOURCE'' and resource_id = :COLLECTOR_RESOURCE_ID ';

     else
	l_security_where := ' :person_id = :person_id and collector_resource_id = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 then
	l_security_where := l_security_where || ' union all SELECT ac.resource_id FROM iex_assignments iea,ar_collectors ac where '||
    	                    ' iea.alt_employee_id = :PERSON_ID '||
			    ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
			    ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                            ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' '||
                            ' and ac.resource_id=iea.resource_id '||
                            ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP'') ';
     end if;

     if l_group_check>0 then
        l_security_where := l_security_where || ' union all SELECT ac.resource_ID '||
			    ' FROM ar_collectors ac , jtf_rs_group_members jtgrp '||
			    ' WHERE ac.resource_ID = jtgrp.group_id '||
			    ' AND ac.resource_type = ''RS_GROUP'''||
			    ' AND NVL(jtgrp.delete_flag,''N'') = ''N'''||
			    ' AND jtgrp.resource_ID = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 or l_group_check>0 then
	l_security_where := l_security_where || ' ) ';
     end if;
 --End bug#5874874 gnramasa 25-Apr-2007

    l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

    l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
    l_bind_list(1).bind_var_value := 1;
    l_bind_list(1).bind_var_data_type := 'NUMBER' ;

    IF ( l_access in ('P', 'F')) THEN
      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_bkr;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where;
      END IF;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;

    ELSE
       /* No count view when the security is enabled */
       l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;

      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_and || l_security_where || l_str_bkr;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_and || l_security_where;
      END IF;

      l_bind_list(2).bind_var_name := ':PERSON_ID' ;
      l_bind_list(2).bind_var_value := l_person_id;
      l_bind_list(2).bind_var_data_type := 'NUMBER' ;

      l_bind_list(3).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
      l_bind_list(3).bind_var_value := p_resource_id;
      l_bind_list(3).bind_var_data_type := 'NUMBER' ;
      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
     END IF;
   ELSE /* l_strategy_level <> 'CUSTOMER' THEN */
      IF (cur_rec.lookup_code = 'ACTIVE') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_ACT_UWQ';
      ELSIF (cur_rec.lookup_code = 'PENDING') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_PEND_UWQ';
      ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_COMP_UWQ';
      END IF;

      l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
      l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
      l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
      l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;
      l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID';

      l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
      l_bind_list(1).bind_var_value := -1;
      l_bind_list(1).bind_var_data_type := 'NUMBER' ;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
    END IF;

    l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_ld_list(l_node_counter).NODE_TYPE := 0;
    l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_ld_list(l_node_counter).NODE_DEPTH := 2;

    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

    l_node_counter := l_node_counter + 1;
    --l_check        := 0;
  END LOOP;
  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  end if;
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes


  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    -- ROLLBACK TO start_delin_enumeration;
    RAISE;

END ENUMERATE_CU_DELIN_NODES;

-- added by jypark 10/11/2004 for performance

PROCEDURE ENUMERATE_ACC_DELIN_NODES
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
  l_collector_id NUMBER;

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

  CURSOR c_collector_id IS
    SELECT collector_id from AR_COLLECTORS where resource_id = p_resource_id
      and resource_type = 'RS_RESOURCE';

  l_sel_enum_rec c_sel_enum%ROWTYPE;

  l_Complete_Days varchar2(40);
  l_data_source VARCHAR2(1000);
  l_default_where VARCHAR2(1000);
  l_security_where VARCHAR2(2000);
  l_node_where VARCHAR2(2000);
  l_uwq_where VARCHAR2(1000);
  l_org_id NUMBER;

  type tbl_wclause is table of varchar2(500) index by binary_integer;

  l_str_and VARCHAR2(100);
  l_str_del   VARCHAR2(1000);
  l_str_bkr VARCHAR2(1000);

  l_bkr_filter VARCHAR2(240);
  l_view_name VARCHAR2(240);
  l_refresh_view_name VARCHAR2(240);
  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes   varchar2(10);
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-node

  l_additional_where1 VARCHAR2(2000);
  l_additional_where2 VARCHAR2(2000);

  L VARCHAR2(240);

  CURSOR C_ORG_ID IS SELECT ORGANIZATION_ID FROM HR_OPERATING_UNITS
  WHERE MO_GLOBAL.CHECK_ACCESS(ORGANIZATION_ID) = 'Y';

  CURSOR c_strategy_level IS
    SELECT PREFERENCE_VALUE
	FROM IEX_APP_PREFERENCES_B
    WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
    and org_id is null
    and enabled_flag='Y'; --bug#6717849 schekuri 31-Jul-2009

  l_strategy_level VARCHAR2(30);
  l_group_check number;

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

  l_Access   := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  l_Level    :=  NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
  l_str_and  := ' AND ';
  l_str_del  := ' AND NUMBER_OF_DELINQUENCIES > 0 ';
  l_node_counter := 0;
  l_check  :=0;

  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;

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


  l_data_source := 'IEX_ACC_DLN_ALL_UWQ';
  l_view_name := 'IEX_CU_DLN_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_DLN_ALL_UWQ_V';

  --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
  /* l_additional_where1 :=
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp, ' ||
	  ' JTF_RS_GROUPS_DENORM jrg ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  ' AND jtgrp.group_id = jrg.group_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID ) ';

  l_additional_where2 :=
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp, ' ||
	  ' JTF_RS_GROUPS_DENORM jrg ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  ' AND jtgrp.group_id = jrg.group_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID ) ';
   */
  --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

IF l_strategy_level = 'ACCOUNT' THEN
  l_str_bkr := ' AND NUMBER_OF_BANKRUPTCIES = 0 ';
  l_default_where := ' RESOURCE_ID = :RESOURCE_ID and IEU_PARAM_PK_COL=''CUST_ACCOUNT_ID'' ';

  -- Territory Assignment Changes.
  IF (l_Access = 'T') THEN
   OPEN c_collector_id;
   FETCH c_collector_id INTO l_collector_id;
   CLOSE c_collector_id;

   SELECT count(*) INTO l_check FROM iex_assignments where
   alt_resource_id =  P_RESOURCE_ID
    AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
   --Bug4646657 . Check for Deleted flag .Fixed by lkkumar. Start.
   AND NVL(DELETED_FLAG,'N') = 'N';
   --Bug4646657 . Check for Deleted flag .Fixed by lkkumar. End.

   select count(1) into l_group_check
   from ar_collectors where status='A' and
   nvl(inactive_date,sysdate)>=sysdate and resource_type='RS_GROUP';

  END IF;

 /* IF l_Level = 'PARTY' then
      If (l_check > 0) then
        l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND iea.alt_employee_id = :PERSON_ID  '||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL  select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND hp.cust_account_id = -1  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
	   --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where2;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
      Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND hp.cust_account_id = -1  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
  	   --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where2;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

      End If;
   ELSE
      If (l_check > 0) then
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
  	   --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

      Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
  	   --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

      END IF;
    END IF; */

     if l_check>0 or l_group_check>0 then
        --l_security_where := ' :person_id = :person_id and collector_resource_id in (select :COLLECTOR_RESOURCE_ID from dual ';
        l_security_where := ' :person_id = :person_id and collector_resource_id in (select resource_id from ar_collectors where resource_type = ''RS_RESOURCE'' and resource_id = :COLLECTOR_RESOURCE_ID ';

     else
	l_security_where := ' :person_id = :person_id and collector_resource_id = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 then
	l_security_where := l_security_where || ' union all SELECT ac.resource_id FROM iex_assignments iea,ar_collectors ac where '||
    	                    ' iea.alt_employee_id = :PERSON_ID '||
			    ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
			    ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                            ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' '||
                            ' and ac.resource_id=iea.resource_id '||
                            ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP'') ';
     end if;

     if l_group_check>0 then
        l_security_where := l_security_where || ' union all SELECT ac.resource_ID '||
			    ' FROM ar_collectors ac , jtf_rs_group_members jtgrp '||
			    ' WHERE ac.resource_ID = jtgrp.group_id '||
			    ' AND ac.resource_type = ''RS_GROUP'''||
			    ' AND NVL(jtgrp.delete_flag,''N'') = ''N'''||
			    ' AND jtgrp.resource_ID = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 or l_group_check>0 then
	l_security_where := l_security_where || ' ) ';
     end if;
 --End bug#5874874 gnramasa 25-apr-2007

  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
  l_bind_list(1).bind_var_value := 1;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  IF ( l_access in ('F', 'P')) THEN
    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_del || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_del;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  ELSE
    /* No count view when the security is enabled */
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;

    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;

    l_bind_list(2).bind_var_name := ':PERSON_ID' ;
    l_bind_list(2).bind_var_value := l_person_id;
    l_bind_list(2).bind_var_data_type := 'NUMBER' ;

    l_bind_list(3).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
    l_bind_list(3).bind_var_value := p_resource_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_del || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_del;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;
ELSE  /* IF l_strategy_level <> 'BILL_TO' */

    l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

    l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID';
    l_bind_list(1).bind_var_name := ':RESOURCE_ID';
    l_bind_list(1).bind_var_value := -1;
    l_bind_list(1).bind_var_data_type := 'NUMBER' ;
    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;

  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;


  l_node_counter := l_node_counter + 1;
  --l_check        := 0;

  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes :=  NVL(FND_PROFILE.VALUE('IEX_ENABLE_UWQ_STATUS'),'N');

  if (l_EnableNodes <> 'N') then
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes

  FOR cur_rec IN c_del_new_nodes LOOP
    IF l_strategy_level = 'ACCOUNT' THEN
      IF (cur_rec.lookup_code = 'ACTIVE') THEN
        l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0  AND ACTIVE_DELINQUENCIES IS NOT NULL ';
        l_data_source := 'IEX_ACC_DLN_ACT_UWQ';

    ELSIF (cur_rec.lookup_code = 'PENDING') THEN
      l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0 AND PENDING_DELINQUENCIES IS NOT NULL ';
      l_data_source := 'IEX_ACC_DLN_PEND_UWQ';

    ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
      l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0 AND COMPLETE_DELINQUENCIES IS NOT NULL ';
      l_data_source := 'IEX_ACC_DLN_COMP_UWQ';

    END IF;

    -- Territory Assignment Change
--Begin bug#5874874 gnramasa 25-Apr-2007
    /* IF l_Level = 'PARTY' then
      If (l_check > 0) then
        l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
  	   --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where2;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

      Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
  	   --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where2;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

      End If;
    ELSE
      If (l_check > 0) then
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID ' ||
          ' AND TRUNC(iea.START_DATE) <=  TRUNC(SYSDATE)  ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND  ac.employee_id = :PERSON_ID  '||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
  	   --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

      Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND  ac.employee_id = :PERSON_ID  '||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
  	   --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

      END IF;
     END IF; */

     if l_check>0 or l_group_check>0 then
        --l_security_where := ' :person_id = :person_id and collector_resource_id in (select :COLLECTOR_RESOURCE_ID from dual ';
        l_security_where := ' :person_id = :person_id and collector_resource_id in (select resource_id from ar_collectors where resource_type = ''RS_RESOURCE'' and resource_id = :COLLECTOR_RESOURCE_ID ';

     else
	l_security_where := ' :person_id = :person_id and collector_resource_id = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 then
	l_security_where := l_security_where || ' union all SELECT ac.resource_id FROM iex_assignments iea,ar_collectors ac where '||
    	                    ' iea.alt_employee_id = :PERSON_ID '||
			    ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
			    ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                            ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' '||
                            ' and ac.resource_id=iea.resource_id '||
                            ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP'') ';
     end if;

     if l_group_check>0 then
        l_security_where := l_security_where || ' union all SELECT ac.resource_ID '||
			    ' FROM ar_collectors ac , jtf_rs_group_members jtgrp '||
			    ' WHERE ac.resource_ID = jtgrp.group_id '||
			    ' AND ac.resource_type = ''RS_GROUP'''||
			    ' AND NVL(jtgrp.delete_flag,''N'') = ''N'''||
			    ' AND jtgrp.resource_ID = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 or l_group_check>0 then
	l_security_where := l_security_where || ' ) ';
     end if;
--End bug#5874874 gnramasa 25-Apr-2007

    l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

    l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
    l_bind_list(1).bind_var_value := 1;
    l_bind_list(1).bind_var_data_type := 'NUMBER' ;

    IF ( l_access in ('P', 'F')) THEN
      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_bkr;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where;
      END IF;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;

    ELSE
      /* No count view when the security is enabled */
      l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;

      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_and || l_security_where || l_str_bkr;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_and || l_security_where;
      END IF;

      l_bind_list(2).bind_var_name := ':PERSON_ID' ;
      l_bind_list(2).bind_var_value := l_person_id;
      l_bind_list(2).bind_var_data_type := 'NUMBER' ;

      l_bind_list(3).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
      l_bind_list(3).bind_var_value := p_resource_id;
      l_bind_list(3).bind_var_data_type := 'NUMBER' ;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
     END IF;

    ELSE /* l_strategy_level <> 'ACCOUNT' THEN */
      IF (cur_rec.lookup_code = 'ACTIVE') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_ACT_UWQ';
      ELSIF (cur_rec.lookup_code = 'PENDING') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_PEND_UWQ';
      ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_COMP_UWQ';
      END IF;

      l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
      l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
      l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
      l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

      l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
      l_bind_list(1).bind_var_value := -1;
      l_bind_list(1).bind_var_data_type := 'NUMBER' ;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
    END IF;

    l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_ld_list(l_node_counter).NODE_TYPE := 0;
    l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_ld_list(l_node_counter).NODE_DEPTH := 2;

    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

    l_node_counter := l_node_counter + 1;
    -- l_check   := 0;
  END LOOP;
  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  end if;
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes


  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    -- ROLLBACK TO start_delin_enumeration;
    RAISE;

END ENUMERATE_ACC_DELIN_NODES;

-- added by jypark 10/11/2004 for performance

PROCEDURE ENUMERATE_BILLTO_DELIN_NODES
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
  --Territory Assignment Change
  l_Access   varchar2(10);
  l_Level    varchar2(15);
  l_check    NUMBER;
  l_collector_id NUMBER;
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

  CURSOR c_collector_id IS
    SELECT collector_id from AR_COLLECTORS where resource_id = p_resource_id
      and resource_type = 'RS_RESOURCE';

  l_sel_enum_rec c_sel_enum%ROWTYPE;

  l_Complete_Days varchar2(40);
  l_data_source VARCHAR2(1000);
  l_default_where VARCHAR2(1000);
  l_security_where VARCHAR2(2000);
  l_node_where VARCHAR2(2000);
  l_uwq_where VARCHAR2(1000);
  l_org_id NUMBER;

  type tbl_wclause is table of varchar2(500) index by binary_integer;

  l_str_and VARCHAR2(100);
  l_str_del   VARCHAR2(1000);
  l_str_bkr VARCHAR2(1000);

  l_bkr_filter VARCHAR2(240);
  l_view_name VARCHAR2(240);
  l_refresh_view_name VARCHAR2(240);
  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes   varchar2(10);
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-node

  l_additional_where1 VARCHAR2(2000);
  l_additional_where2 VARCHAR2(2000);

  L VARCHAR2(240);


  CURSOR C_ORG_ID IS SELECT ORGANIZATION_ID FROM HR_OPERATING_UNITS
    WHERE MO_GLOBAL.CHECK_ACCESS(ORGANIZATION_ID) = 'Y';

  CURSOR c_strategy_level IS
    SELECT PREFERENCE_VALUE
	FROM IEX_APP_PREFERENCES_B
    WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
    and org_id is null
    and enabled_flag='Y';

  l_strategy_level VARCHAR2(30);
  l_group_check number;

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


  l_Access   := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  l_Level    :=  NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
  l_str_and  := ' AND ';
  l_str_del  := ' AND NUMBER_OF_DELINQUENCIES > 0 ';

  l_node_counter := 0;
  l_check := 0;

  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;

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

  l_data_source := 'IEX_BILLTO_DLN_ALL_UWQ';
  l_view_name := 'IEX_CU_DLN_ALL_UWQ_V';
  l_refresh_view_name := 'IEX_CU_DLN_ALL_UWQ_V';

IF l_strategy_level = 'BILL_TO' THEN
  l_str_bkr := ' AND NUMBER_OF_BANKRUPTCIES = 0 ';

  l_default_where := ' RESOURCE_ID = :RESOURCE_ID and IEU_PARAM_PK_COL=''CUSTOMER_SITE_USE_ID'' ';

 --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
 /* l_additional_where1 :=
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp, ' ||
	  ' JTF_RS_GROUPS_DENORM jrg ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  ' AND jtgrp.group_id = jrg.group_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID ) ';

  l_additional_where2 :=
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp, ' ||
	  ' JTF_RS_GROUPS_DENORM jrg ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
	  ' AND jtgrp.group_id = jrg.group_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID ) ';
  */
  --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.


  IF (l_Access = 'T') THEN
   OPEN c_collector_id;
   FETCH c_collector_id INTO l_collector_id;
   CLOSE c_collector_id;

   SELECT count(*) INTO l_check FROM iex_assignments where
   alt_resource_id =  p_RESOURCE_ID
   AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
   --Bug4646657 . Check for Deleted flag .Fixed by lkkumar. Start.
   AND NVL(DELETED_FLAG,'N') = 'N';
   --Bug4646657 . Check for Deleted flag .Fixed by lkkumar. End.

   select count(1) into l_group_check
   from ar_collectors where status='A' and
   nvl(inactive_date,sysdate)>=sysdate and resource_type='RS_GROUP';

  END IF;

--Begin bug#5874874 gnramasa 25-Apr-2007
   /* IF l_Level = 'PARTY' then
      If (l_check > 0) then
        l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <=  TRUNC(SYSDATE)  ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' '||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
          --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where2;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
      Else
        l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
          --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where2;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     End If;
    ELSIF l_level = 'ACCOUNT' then
     If (l_check > 0) then
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND hp.site_use_id is NULL '||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE)  ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' '||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL '||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL '||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
          --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL '||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND hp.site_use_id is NULL '||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
          --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     End If;
    Else
     If (l_check > 0) then
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE)  ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     End If;
    END IF;  */

    if l_check>0 or l_group_check>0 then
	--l_security_where := ' :person_id = :person_id and collector_resource_id in (select :COLLECTOR_RESOURCE_ID from dual ';
	l_security_where := ' :person_id = :person_id and collector_resource_id in (select resource_id from ar_collectors where resource_type = ''RS_RESOURCE'' and resource_id = :COLLECTOR_RESOURCE_ID ';
     else
	l_security_where := ' :person_id = :person_id and collector_resource_id = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 then
	l_security_where := l_security_where || ' union all SELECT ac.resource_id FROM iex_assignments iea,ar_collectors ac where '||
    	                    ' iea.alt_employee_id = :PERSON_ID '||
			    ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
			    ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                            ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' '||
                            ' and ac.resource_id=iea.resource_id '||
                            ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP'') ';
     end if;

     if l_group_check>0 then
        l_security_where := l_security_where || ' union all SELECT ac.resource_ID '||
			    ' FROM ar_collectors ac , jtf_rs_group_members jtgrp '||
			    ' WHERE ac.resource_ID = jtgrp.group_id '||
			    ' AND ac.resource_type = ''RS_GROUP'''||
			    ' AND NVL(jtgrp.delete_flag,''N'') = ''N'''||
			    ' AND jtgrp.resource_ID = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 or l_group_check>0 then
	l_security_where := l_security_where || ' ) ';
     end if;
-- End Bug#5874874 gnramasa 25-Apr-2007

  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
  l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

  l_bind_list(1).bind_var_name := ':RESOURCE_ID';
  l_bind_list(1).bind_var_value := 1;
  l_bind_list(1).bind_var_data_type := 'NUMBER' ;

  IF ( l_access in ('F', 'P')) THEN
    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_del || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_del;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  ELSE
      /* No count view when the security is enabled */
      l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;

    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;

    l_bind_list(2).bind_var_name := ':PERSON_ID' ;
    l_bind_list(2).bind_var_value := l_person_id;
    l_bind_list(2).bind_var_data_type := 'NUMBER' ;

    l_bind_list(3).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
    l_bind_list(3).bind_var_value := p_resource_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF l_bkr_filter = 'Y' THEN
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_del || l_str_bkr;
    ELSE
      l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_and || l_security_where || l_str_del;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
  END IF;
ELSE  /* IF l_strategy_level <> 'BILL_TO' */

    l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

    l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID';
    l_bind_list(1).bind_var_name := ':RESOURCE_ID';
    l_bind_list(1).bind_var_value := -1;
    l_bind_list(1).bind_var_data_type := 'NUMBER' ;
    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
END IF;

  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;


  l_node_counter := l_node_counter + 1;
  --l_check        := 0;

  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  l_EnableNodes :=  NVL(FND_PROFILE.VALUE('IEX_ENABLE_UWQ_STATUS'),'N');

  if (l_EnableNodes <> 'N') then
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes

  FOR cur_rec IN c_del_new_nodes LOOP
   IF l_strategy_level = 'BILL_TO' THEN
    IF (cur_rec.lookup_code = 'ACTIVE') THEN
      l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0  AND ACTIVE_DELINQUENCIES IS NOT NULL ';
      l_data_source := 'IEX_BILLTO_DLN_ACT_UWQ';
      l_view_name         := 'IEX_CU_DLN_ALL_UWQ_V';
      l_refresh_view_name := 'IEX_CU_DLN_ALL_UWQ_V';

    ELSIF (cur_rec.lookup_code = 'PENDING') THEN
      l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0  AND PENDING_DELINQUENCIES IS NOT NULL ';
      l_data_source := 'IEX_BILLTO_DLN_PEND_UWQ';
      l_view_name         := 'IEX_CU_DLN_ALL_UWQ_V';
      l_refresh_view_name := 'IEX_CU_DLN_ALL_UWQ_V';

    ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
      l_node_where := l_default_where || ' AND NUMBER_OF_DELINQUENCIES > 0 AND COMPLETE_DELINQUENCIES IS NOT NULL ';
      l_data_source := 'IEX_BILLTO_DLN_COMP_UWQ';
      l_view_name         := 'IEX_CU_DLN_ALL_UWQ_V';
      l_refresh_view_name := 'IEX_CU_DLN_ALL_UWQ_V';

     END IF;
  --Begin bug#5874874 gnramasa 25-Apr-2007
/*
    IF l_Level = 'PARTY' then
      If (l_check > 0) then
        l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where2;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
      Else
        l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND hp.cust_account_id = -1 ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND hp.cust_account_id = -1   ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where2;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     End If;
    ELSIF l_level = 'ACCOUNT' then
     If (l_check > 0) then
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND hp.site_use_id is NULL '||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ' || l_view_name ||
          '.cust_account_id = hp.cust_account_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     End If;
    Else
     If (l_check > 0) then
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND ac.resource_id = iea.resource_id ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
  	  ' AND NVL(IEA.DELETED_FLAG,''N'') = ''N'' ' ||
          ' UNION ALL select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.

     Else
       l_security_where :=
          'party_id in (select hp.party_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND  ac.employee_id = :PERSON_ID  ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
          ' UNION ALL  SELECT hp.party_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ' || l_view_name ||
          '.site_use_id = hp.site_use_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID  ';
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. Start.
	   l_security_where := l_security_where || l_additional_where1;
           --Bug4221349. Implement Group Hierarchy. Fix By LKKUMAR on 22-Mar-2006. End.
     End If;
    END IF;
*/

     if l_check>0 or l_group_check>0 then
        --l_security_where := ' :person_id = :person_id and collector_resource_id in (select :COLLECTOR_RESOURCE_ID from dual ';
        l_security_where := ' :person_id = :person_id and collector_resource_id in (select resource_id from ar_collectors where resource_type = ''RS_RESOURCE'' and resource_id = :COLLECTOR_RESOURCE_ID ';

     else
	l_security_where := ' :person_id = :person_id and collector_resource_id = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 then
	l_security_where := l_security_where || ' union all SELECT ac.resource_id FROM iex_assignments iea,ar_collectors ac where '||
    	                    ' iea.alt_employee_id = :PERSON_ID '||
			    ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
			    ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                            ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' '||
                            ' and ac.resource_id=iea.resource_id '||
                            ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP'') ';  --Bug#5691908 replaced RS_EMPLOYEE with RS_RESOURCE by schekuri 02-Feb-2007
     end if;

     if l_group_check>0 then
        l_security_where := l_security_where || ' union all SELECT ac.resource_ID '||
			    ' FROM ar_collectors ac , jtf_rs_group_members jtgrp '||
			    ' WHERE ac.resource_ID = jtgrp.group_id '||
			    ' AND ac.resource_type = ''RS_GROUP'''||
			    ' AND NVL(jtgrp.delete_flag,''N'') = ''N'''||
			    ' AND jtgrp.resource_ID = :COLLECTOR_RESOURCE_ID ';
     end if;

     if l_check>0 or l_group_check>0 then
	l_security_where := l_security_where || ' ) ';
     end if;
  --End bug#5874874 gnramasa 25-Apr-2007

    l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
    l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
    l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
    l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

    l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
    l_bind_list(1).bind_var_value := 1;
    l_bind_list(1).bind_var_data_type := 'NUMBER' ;

    IF ( l_access in ('P', 'F')) THEN
      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_bkr;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where;
      END IF;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;

    ELSE
      /* No count view when the security is enabled */
      l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_view_name;

      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_and || l_security_where || l_str_bkr;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE :=  l_node_where || l_str_and || l_security_where;
      END IF;

      l_bind_list(2).bind_var_name := ':PERSON_ID' ;
      l_bind_list(2).bind_var_value := l_person_id;
      l_bind_list(2).bind_var_data_type := 'NUMBER' ;

      l_bind_list(3).bind_var_name := ':COLLECTOR_RESOURCE_ID' ;
      l_bind_list(3).bind_var_value := p_resource_id;
      l_bind_list(3).bind_var_data_type := 'NUMBER' ;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
    END IF;
   ELSE /* l_strategy_level <> 'BILL_TO' THEN */
      IF (cur_rec.lookup_code = 'ACTIVE') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_ACT_UWQ';
      ELSIF (cur_rec.lookup_code = 'PENDING') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_PEND_UWQ';
      ELSIF (cur_rec.lookup_code = 'COMPLETE') THEN
        l_node_where := l_default_where;
        l_data_source := 'IEX_ACC_DLN_COMP_UWQ';
      END IF;

      l_ld_list(l_node_counter).NODE_LABEL := cur_rec.meaning;
      l_ld_list(l_node_counter).VIEW_NAME := l_view_name;
      l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;
      l_ld_list(l_node_counter).REFRESH_VIEW_NAME := l_refresh_view_name;

      l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
      l_bind_list(1).bind_var_value := -1;
      l_bind_list(1).bind_var_data_type := 'NUMBER' ;

      l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
   END IF;

    l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
    l_ld_list(l_node_counter).NODE_TYPE := 0;
    l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
    l_ld_list(l_node_counter).NODE_DEPTH := 2;

    l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

    l_node_counter := l_node_counter + 1;
    --l_check        := 0;
  END LOOP;
  -- Begin - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes
  end if;
  -- End - jypark - 05/25/05 - 4605402 - Added profile to show/hide UWQ sub-nodes


  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );


EXCEPTION
  WHEN OTHERS THEN
    -- ROLLBACK TO start_delin_enumeration;
    RAISE;

END ENUMERATE_BILLTO_DELIN_NODES;


BEGIN

PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END IEX_UWQ_DELIN_ENUMS_PVT;

/
