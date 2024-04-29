--------------------------------------------------------
--  DDL for Package Body IEX_UWQ_STRAT_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_UWQ_STRAT_ENUMS_PVT" AS
/* $Header: iexenstb.pls 120.21.12010000.10 2009/11/03 07:32:13 barathsr ship $ */

-- Sub-Program Units

PG_DEBUG NUMBER(2);

PROCEDURE ENUMERATE_STRAT_NODES
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
  l_person_id NUMBER;
  l_Level   varchar2(15);
  l_check    NUMBER;

  CURSOR c_person IS
    select source_id
    from jtf_rs_resource_extns
    where resource_id = p_resource_id;

  CURSOR c_del_new_nodes is
    select lookup_code, meaning from fnd_lookup_values
    where lookup_type = 'IEX_UWQ_NODE_STATUS'
    and lookup_code in ('ACTIVE', 'PENDING')  -- added by jypark 01/02/2003 not show 'COMPLETE' node
    and LANGUAGE = userenv('LANG');

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
  l_str_and VARCHAR2(10);
   l_str_str VARCHAR2(1000);
  l_str_bkr VARCHAR2(1000);
  l_str_bkr_2 VARCHAR2(1000);
 -- l_org_id NUMBER;  --commented for bug 8826561 PNAVEENK
  l_Complete_Days VARCHAR2(40);
  l_bkr_filter VARCHAR2(240);

  l_full_brk  VARCHAR2(2000);
  l_str_or    VARCHAR2(10);
  l_restrict_res_grp varchar2(700);
  l_restrict_assign_resource varchar2(700);

  L VARCHAR2(240);

  CURSOR C_ORG_ID IS SELECT ORGANIZATION_ID FROM HR_OPERATING_UNITS
    WHERE MO_GLOBAL.CHECK_ACCESS(ORGANIZATION_ID) = 'Y';
  l_additional_str varchar2(200);
/* Added by gnramasa 25-Apr-2007 Bug 5874874 Display strategy only at that level */
  l_strategy_level VARCHAR2(30);
  l_new_resource_ID NUMBER;

CURSOR c_strategy_level IS
    SELECT PREFERENCE_VALUE
	FROM IEX_APP_PREFERENCES_B
    WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
    and org_id is null--Modified for Bug 9079394 by barathsr 03-Nov-2009
    and enabled_flag='Y'; --bug#6717849 schekuri 31-Jul-2009
/* Added by gnramasa 25-Apr-2007 Bug 5874874 Display strategy only at that level */

 --begin bug#6717849 schekuri 31-Jul-2009
  l_level_count number;
  cursor c_multi_level(p_multi_level varchar2)
  is select lookup_code
  from iex_lookups_v
  where lookup_type='IEX_RUNNING_LEVEL'
  and lookup_code= p_multi_level
  and  iex_utilities.validate_running_level(LOOKUP_CODE)='Y';
  --end bug#6717849 schekuri 31-Jul-2009

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

  -- SAVEPOINT start_str_enumeration;

  l_node_counter := 0;
  l_Access := NVL(FND_PROFILE.VALUE('IEX_CUST_ACCESS'), 'F');
  l_Level  := NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');

  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
  l_bkr_filter  := NVL(fnd_profile.value('IEX_BANKRUPTCY_FILTER'), 'Y');
--  l_org_id  := TO_NUMBER(oe_profile.value('OE_ORGANIZATION_ID', fnd_profile.value('ORG_ID'))); --commented for bug 8826561 PNAVEENK

  l_str_and  := ' AND ';
  l_str_or   := ' OR ';
  l_str_str  := ' AND NUMBER_OF_STRATEGIES > 0 ';

  OPEN c_strategy_level;
  FETCH c_strategy_level INTO l_strategy_level;
  CLOSE c_strategy_level;
  --begin bug#6717849 schekuri 31-Jul-2009
  select count(1)
  into l_level_count
  from iex_lookups_v
  where lookup_type='IEX_RUNNING_LEVEL'
  and  iex_utilities.validate_running_level(LOOKUP_CODE)='Y';
  --end bug#6717849 schekuri 31-Jul-2009

  OPEN c_sel_enum(p_sel_enum_id);
  FETCH c_sel_enum INTO l_sel_enum_rec;
  CLOSE c_sel_enum;

  OPEN c_node_label(l_sel_enum_rec.work_q_label_lu_type, l_sel_enum_rec.work_q_label_lu_code);
  FETCH c_node_label INTO l_node_label;
  CLOSE c_node_label;

  OPEN c_person;
  FETCH c_person INTO l_person_id;
  CLOSE c_person;

  l_new_resource_id := p_Resource_id;

  IF p_sel_enum_id = 13067 THEN
    l_data_source := 'IEX_CU_STR_UWQ';
    --begin bug#6717849 schekuri 31-Jul-2009
      if l_level_count>1 then
      open c_multi_level('CUSTOMER');
      fetch c_multi_level into l_strategy_level;
      close c_multi_level;
     end if;
     --End bug#6717849 schekuri 31-Jul-2009
    /* Begin - Added by gnramasa 26-Sep-2008 Bug 7433430 Display strategy only at that level */
    if l_strategy_level <> 'DELINQUENCY' then
	l_restrict_assign_resource := ' and ieu_param_pk_col=''PARTY_ID'' ';
    else
	l_restrict_assign_resource := ' and ieu_param_pk_col = NULL ';
    end if;
    /* End - Added by gnramasa 26-Sep-2008 Bug 7433430 Display strategy only at that level */
    /* Begin - Added by gnramasa 25-Apr-2007 Bug 5874874  Display strategy only at that level */
    if l_strategy_level <>  'CUSTOMER' then
       l_new_Resource_id := -1;
       l_person_id := -1;
    end if;
   /* End - Added by gnramasa 25-Apr-2007 Bug 5874874  Display strategy only at that level */
  ELSIF p_sel_enum_id = 13068 THEN
    l_data_source := 'IEX_ACC_STR_UWQ';
        --begin bug#6717849 schekuri 31-Jul-2009
      if l_level_count>1 then
      open c_multi_level('ACCOUNT');
      fetch c_multi_level into l_strategy_level;
      close c_multi_level;
     end if;
     --End bug#6717849 schekuri 31-Jul-2009
    /* Begin - Added by gnramasa 26-Sep-2008 Bug 7433430 Display strategy only at that level */
    if l_strategy_level <> 'DELINQUENCY' then
	l_restrict_assign_resource := ' and ieu_param_pk_col=''CUST_ACCOUNT_ID'' ';
    else
	l_restrict_assign_resource := ' and ieu_param_pk_col = NULL ';
    end if;
    /* End - Added by gnramasa 26-Sep-2008 Bug 7433430 Display strategy only at that level */
    /* Begin - Added by gnramasa 25-Apr-2007 Bug 5874874  Display strategy only at that level, destroy the bind value  */
    if l_strategy_level <>  'ACCOUNT' then
       l_new_Resource_id := -1;
       l_person_id := -1;
    end if;
   /* End - Added by gnramasa 25-Apr-2007 Bug 5874874  Display strategy only at that level destroy the bind value */
  ELSIF p_sel_enum_id = 13072 THEN
    l_data_source := 'IEX_BILLTO_STR_UWQ';
        --begin bug#6717849 schekuri 31-Jul-2009
      if l_level_count>1 then
      open c_multi_level('BILL_TO');
      fetch c_multi_level into l_strategy_level;
      close c_multi_level;
     end if;
     --End bug#6717849 schekuri 31-Jul-2009
    /* Begin - Added by gnramasa 26-Sep-2008 Bug 7433430 Display strategy only at that level */
    if l_strategy_level <> 'DELINQUENCY' then
	l_restrict_assign_resource := ' and ieu_param_pk_col=''CUSTOMER_SITE_USE_ID'' ';
    else
	l_restrict_assign_resource := ' and ieu_param_pk_col = NULL ';
    end if;
    /* End - Added by gnramasa 26-Sep-2008 Bug 7433430 Display strategy only at that level */
    /* Begin - Added by gnramasa 25-Apr-2007 Bug 5874874  Display strategy only at that level destroy the bind value*/
    if l_strategy_level <>  'BILL_TO' then
       l_new_Resource_id := -1;
       l_person_id := -1;
    end if;
   /* End - Added by gnramasa 25-Apr-2007 Bug 5874874  Display strategy only at that level */
  ELSIF p_sel_enum_id = 13069 THEN
    l_data_source := 'IEX_STRATEGIES_UWQ';
    /* Begin - Added by gnramasa 26-Sep-2008 Bug 7433430 Display strategy only at that level */
    if l_strategy_level = 'DELINQUENCY' then
	l_restrict_assign_resource := '';
    end if;
    /* End - Added by gnramasa 26-Sep-2008 Bug 7433430 Display strategy only at that level */
  END IF;

  /*
  l_default_where := ' RESOURCE_ID = :RESOURCE_ID AND :UWQ_STATUS = :UWQ_STATUS ';

  l_str_bkr :=  ' AND NOT EXISTS (SELECT 1 FROM iex_bankruptcies bkr WHERE bkr.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.party_id) ' ;

  l_str_bkr_2  := ' AND NOT EXISTS (SELECT 1  FROM iex_bankruptcies bkr WHERE bkr.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.customer_id) ' ;

  --Bug4775893. Fix by LKKUMAR on 07-Dec-2005. Start.
  l_full_brk := ' OR  :RESOURCE_ID ' ||
   	        ' IN  (select iea.alt_resource_id '||
                ' FROM  iex_assignments iea ' ||
                ' WHERE  nvl(iea.deleted_flag,''N'') = ''N'' ' ||
                ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
                ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
		' AND iea.resource_id =  ' ||  l_sel_enum_rec.work_q_view_for_primary_node ||'.RESOURCE_ID ) ' ;

  l_restrict_assign_resource := ' select iea.alt_resource_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac, ' ||
          ' iex_assignments iea ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_id = iea.alt_resource_id ' ||
          ' AND  iea.alt_employee_id = :PERSON_ID  ' ||
          ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) ' ||
          ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >=  TRUNC(SYSDATE) ' ||
	  ' AND ac.resource_id IS NOT NULL ';

  --Bug4775893. Fix by LKKUMAR on 07-Dec-2005. End.

  l_restrict_res_grp := ' select ac.resource_id '||
          ' FROM hz_customer_profiles hp, ar_collectors ac ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND  ac.employee_id = :PERSON_ID ' ||
          ' AND ac.resource_type = ''RS_RESOURCE'' ' ||
	  ' AND ac.resource_id IS NOT NULL  ' ||
          ' UNION ALL  SELECT jtgrp.resource_id ' ||
          ' FROM hz_customer_profiles hp, ar_collectors ac , jtf_rs_group_members jtgrp ' ||
          ' WHERE hp.collector_id = ac.collector_id ' ||
          ' AND ac.resource_ID = jtgrp.group_id ' ||
          ' AND ac.resource_type = ''RS_GROUP'' ' ||
  	  ' AND ac.resource_id IS NOT NULL ' ||
          ' AND NVL(jtgrp.delete_flag,''N'') = ''N'' ' ||
	  ' AND jtgrp.resource_id = :RESOURCE_ID ' ||
	  ' AND ' || l_sel_enum_rec.work_q_view_for_primary_node  ||
          '.resource_id = :RESOURCE_ID ' ||
          ' AND jtgrp.PERSON_ID = :PERSON_ID ';
 */
 /*
  IF( p_sel_enum_id IN (13067,13068,13072) and l_level = 'PARTY') THEN
    l_additional_str := ' AND hp.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.party_id';
  ELSIF (p_sel_enum_id IN (13068,13072) and l_level = 'ACCOUNT') THEN
     l_additional_str := ' AND hp.cust_account_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.cust_account_id';
  ELSIF (p_sel_enum_id = 13072 and l_level = 'BILLTO') THEN
     l_additional_str := ' AND hp.site_use_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.site_use_id';
  END IF;
*/
  l_default_where := ' :UWQ_STATUS = :UWQ_STATUS ';

  -- Changed for bug#7693986 by PNAVEENK on 12-1-2009
  IF p_sel_enum_id = 13069 THEN
    l_str_bkr := ' AND NOT EXISTS (SELECT 1  FROM iex_bankruptcies bkr WHERE bkr.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.customer_id and NVL(BKR.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ) ' ;
    l_Access := 'T';
  ELSE
    l_str_bkr :=  ' AND NOT EXISTS (SELECT 1 FROM iex_bankruptcies bkr WHERE bkr.party_id = ' || l_sel_enum_rec.work_q_view_for_primary_node || '.party_id and NVL(BKR.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ) ' ;
  END IF;
  -- End for bug#7693986
--Start bug 6908307 gnramasa 13th June 08

 IF (l_Access = 'T') THEN --commented for bug#7499019 by PNAVEENK on 18-Nov-2008
	   SELECT count(*) into l_check from iex_assignments where
	   alt_resource_id =  p_RESOURCE_ID
	   AND TRUNC(START_DATE) <= TRUNC(SYSDATE)
	   AND TRUNC(NVL(END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
	   AND NVL(DELETED_FLAG,'N') = 'N';

	  If (l_check > 0) then

	--	l_restrict_assign_resource := l_restrict_assign_resource || ' and resource_id in (select resource_id from ar_collectors where '
	--				      || ' resource_type = ''RS_RESOURCE'' and resource_id = :RESOURCE_ID ';
	        l_restrict_assign_resource := l_restrict_assign_resource||' and resource_id in (select :RESOURCE_ID+0 from dual ';  --Added for bug#7499019 by PNAVEENK
		/* l_security_where := l_sel_enum_rec.work_q_view_for_primary_node || '.resource_id in ( '
		    || l_restrict_res_grp || ' UNION ALL ' || l_restrict_assign_resource || ' ) ' ;
		*/
		 l_restrict_assign_resource := l_restrict_assign_resource ||
                            ' union all (SELECT iea.resource_id FROM iex_assignments iea where '||
                            ' iea.alt_employee_id = :PERSON_ID '||
                            ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
                            ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                            ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' ))';
                         --   ' and ac.resource_id=iea.resource_id '||      -- commented for bug#7499019 by PNAVEENK
                         --   ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP''))) ';

                l_bind_list(3).bind_var_name := ':PERSON_ID' ;
                l_bind_list(3).bind_var_value := l_person_id;
                l_bind_list(3).bind_var_data_type := 'NUMBER' ;

	  Else
		l_restrict_assign_resource := l_restrict_assign_resource||' and resource_id = :RESOURCE_ID ';
		/* l_security_where :=   l_sel_enum_rec.work_q_view_for_primary_node || '.resource_id in ( '
		  || l_restrict_res_grp  || ' ) ' ;
		*/
	  End If;
 ELSE
--	l_restrict_assign_resource := l_restrict_assign_resource || ' and :RESOURCE_ID = :RESOURCE_ID ';
        l_restrict_assign_resource := l_restrict_assign_resource||' and :RESOURCE_ID = :RESOURCE_ID ';
 END IF;
--End bug 6908307 gnramasa 13th June 08

  l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
  l_ld_list(l_node_counter).VIEW_NAME := l_sel_enum_rec.work_q_view_for_primary_node;
  l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  l_ld_list(l_node_counter).DATA_SOURCE := l_data_source;

  l_bind_list(1).bind_var_name := ':UWQ_STATUS' ;
  l_bind_list(1).bind_var_value := 'ALL';
  l_bind_list(1).bind_var_data_type := 'CHAR' ;

  l_bind_list(2).bind_var_name := ':RESOURCE_ID';
  --l_bind_list(2).bind_var_value := p_resource_id;
  l_bind_list(2).bind_var_value := l_new_resource_id;
  l_bind_list(2).bind_var_data_type := 'NUMBER' ;

  /*
  IF ( l_access in ('F', 'P')) THEN
    IF p_sel_enum_id = 13069 THEN
      IF l_bkr_filter = 'Y' THEN
   	  l_ld_list(l_node_counter).WHERE_CLAUSE := '( ' || l_default_where  || l_full_brk || ' ) '|| l_str_bkr_2;
      ELSE
          l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_full_brk;
      END IF;
    ELSE
      IF l_bkr_filter = 'Y' THEN
	l_ld_list(l_node_counter).WHERE_CLAUSE := '( ' || l_default_where || l_full_brk || ' ) ' || l_str_str || l_str_bkr;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where ||  l_full_brk  || l_str_str ;
      END IF;
    END IF;

    l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.LogMessage('ENUMERATE_STRATEGY_NODES: full Mode: main final where clause: ' || l_ld_list(l_node_counter).WHERE_CLAUSE);
    END IF;

  ELSE
    OPEN c_person;
    FETCH c_person INTO l_person_id;
    CLOSE c_person;

    l_bind_list(3).bind_var_name := ':PERSON_ID' ;
    l_bind_list(3).bind_var_value := l_person_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

    IF p_sel_enum_id = 13069 THEN
      IF l_bkr_filter = 'Y' THEN
        l_ld_list(l_node_counter).WHERE_CLAUSE := '( ' || l_default_where || l_full_brk   || l_str_or
	                                           || l_security_where  || ' ) ' || l_str_bkr_2;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_or || l_security_where || l_full_brk;
      END IF;
    ELSE
      IF l_bkr_filter = 'Y' THEN
	l_ld_list(l_node_counter).WHERE_CLAUSE := ' ( ' || l_default_where || l_str_or
                                         || l_security_where  || l_str_str ||   l_full_brk || ' ) ' || l_str_bkr ;
      ELSE
        l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_str_or || l_security_where
	                                          || l_str_str || l_full_brk;
      END IF;
    END IF;
    */
/*  if l_check>0  then

    l_restrict_assign_resource := l_restrict_assign_resource ||
                            ' union all (SELECT iea.resource_id FROM iex_assignments iea where '||
                            ' iea.alt_employee_id = :PERSON_ID '||
                            ' AND TRUNC(iea.START_DATE) <= TRUNC(SYSDATE) '||
                            ' AND TRUNC(NVL(iea.END_DATE,SYSDATE)) >= TRUNC(SYSDATE) '||
                            ' AND NVL(iea.DELETED_FLAG,''N'') = ''N'' ))';
                         --   ' and ac.resource_id=iea.resource_id '||      -- commented for bug#7499019 by PNAVEENK
                         --   ' and ac.resource_type in (''RS_RESOURCE'',''RS_GROUP''))) ';

    l_bind_list(3).bind_var_name := ':PERSON_ID' ;
    l_bind_list(3).bind_var_value := l_person_id;
    l_bind_list(3).bind_var_data_type := 'NUMBER' ;

  end if;*/

  IF l_bkr_filter = 'Y' THEN
    l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_restrict_assign_resource || l_str_bkr;
  ELSE
    l_ld_list(l_node_counter).WHERE_CLAUSE := l_default_where || l_restrict_assign_resource;
  END IF;

  l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage('ENUMERATE_STRATEGY_NODES: restricted Mode: main final where clause: ' || l_ld_list(l_node_counter).WHERE_CLAUSE);
  END IF;

  --END IF;

  l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
  l_ld_list(l_node_counter).NODE_TYPE := 0;
  l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
  l_ld_list(l_node_counter).NODE_DEPTH := 1;


  l_node_counter := l_node_counter + 1;

  IEU_PUB.ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID,
   P_SEL_ENUM_ID,
   l_ld_list
  );

EXCEPTION
  WHEN OTHERS THEN
    -- ROLLBACK TO start_str_enumeration;
    --Begin - Bug#5344878 - Andre Araujo - Need to log exceptions
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'iex',  'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM );
    End if;
    --End - Bug#5344878 - Andre Araujo - Need to log exceptions
    RAISE;

END ENUMERATE_STRAT_NODES;

BEGIN
PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
-- PL/SQL Block
END IEX_UWQ_STRAT_ENUMS_PVT;

/
