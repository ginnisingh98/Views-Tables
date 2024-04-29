--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_CNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_CNT_PUB" AS
/* $Header: iexpstcb.pls 120.37.12010000.35 2010/06/07 09:48:34 gnramasa ship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow .Start Workflow will call workflow based on
 * Meth_flag in methodology base table
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_STRATEGY_CNT_PUB';
PG_DEBUG NUMBER(2) ;
l_enabled varchar2(5) ;

l_DelStatusCurrent  varchar2(30) ;
l_DelStatusDel  varchar2(30)  ;
l_DelStatusPreDel  varchar2(30) ;
  /* begin add for bug 4408860 - add checking CLOSE status from case delinquency */
l_DelStatusClose  varchar2(30) ;
  /* end add for bug 4408860 - add checking CLOSE status from case delinquency */

l_StratStatusOpen varchar2(30) ;
l_StratStatusOnhold varchar2(30);
l_StratStatusPending varchar2(30);
l_StratStatusClosed varchar2(30) ;
l_StratStatusCancelled varchar2(30) ;
l_Yes varchar2(1) ;
l_No varchar2(1) ;
l_StratObjectFilterType varchar2(10) ;

--Bug# 6870773 Naveen
l_org_enabled varchar2(1);
l_org_id number;

--Start adding for bug 8630852  by gnramasa 9-July-09
l_new_line              VARCHAR2(1);
tempResult              CLOB;
l_seq_no                number := 1;
l_custom_select         varchar2(2000);
l_no_closed_rec         number := 0;
l_no_reopen_rec         number := 0;
l_no_reassign_rec       number := 0;
l_no_new_rec            number := 0;
g_sty_level		varchar2(15);
l_coll_at_ous           varchar2(3);
--End adding for bug 8630852  by gnramasa 9-July-09

-- Start for bug 8708271 multi level strategy
l_party_override varchar(1);
l_org_override varchar(1);
l_system_strategy_level varchar2(30);
PROCEDURE cancel_strategy( p_party_id number, p_str_level varchar2 , p_str_mode varchar2,
                           p_cust_acc_id number, p_site_use_id number, p_del_id number);
-- End for bug 8708271 bug 8708271 multi level strategy
Procedure WriteLog ( p_msg IN VARCHAR2)
IS
BEGIN

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage (p_msg);
     END IF;

END WriteLog;

/* Procedure for open strategy for customer, Account, bill_to, and delinquencies based on the strategy run level*/
-- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
--PROCEDURE open_strategies
--(
--		ERRBUF      OUT NOCOPY     VARCHAR2,
--		RETCODE     OUT NOCOPY     VARCHAR2
--) IS
--Bug# 6870773 Naveen
PROCEDURE update_strat_org
(
		ERRBUF      OUT NOCOPY     VARCHAR2,
		RETCODE     OUT NOCOPY     VARCHAR2
);

Procedure gen_xml_header_data_strategy (p_strategy_mode   IN VARCHAR2);
Procedure gen_xml_body_strategy (p_strategy_id        IN NUMBER DEFAULT NULL,
                                 p_strategy_rec       IN IEX_STRATEGY_PVT.STRATEGY_REC_TYPE DEFAULT NULL,
				 p_strategy_status    IN VARCHAR2,
				 p_default_sty_level  IN NUMBER DEFAULT NULL,
				 p_party_id           IN NUMBER DEFAULT NULL,
                                 p_cust_acc_id        IN NUMBER DEFAULT NULL,
				 p_site_use_id        IN NUMBER DEFAULT NULL,
				 p_del_id             IN NUMBER DEFAULT NULL);

Procedure gen_xml_append_closetag_sty  (p_customer_name_low     IN   VARCHAR2 DEFAULT NULL,     -- added by gnramasa for bug 8833868 3-Sep-09
					p_customer_name_high    IN   VARCHAR2 DEFAULT NULL,     -- added by gnramasa for bug 8833868 3-Sep-09
					p_account_number_low    IN   VARCHAR2 DEFAULT NULL,     -- added by gnramasa for bug 8833868 3-Sep-09
					p_account_number_high   IN   VARCHAR2 DEFAULT NULL,     -- added by gnramasa for bug 8833868 3-Sep-09
					p_billto_location_low   IN   VARCHAR2 DEFAULT NULL,     -- added by gnramasa for bug 8833868 3-Sep-09
					p_billto_location_high  IN   VARCHAR2 DEFAULT NULL);	-- added by gnramasa for bug 8833868 3-Sep-09

--Start adding by gnramasa for bug 8630852 13-July-09
Procedure custom_where_clause
           (p_customer_name_low       IN VARCHAR2,
	    p_customer_name_high      IN VARCHAR2,
	    p_account_number_low      IN VARCHAR2,
	    p_account_number_high     IN VARCHAR2,
	    p_billto_location_low     IN VARCHAR2,
	    p_billto_location_high    IN VARCHAR2,
	    p_strategy_level          IN NUMBER)
IS
l_api_name       varchar2(50) := 'custom_where_clause';
BEGIN
--if l_StrategyLevelName <> 'DELINQUENCY' then
if p_strategy_level <> 40 then
	l_custom_select := ' SELECT p.party_name ' ||
			' From hz_cust_acct_sites_all acct_sites, ' ||
			'   hz_party_sites party_site, ' ||
			'   hz_cust_accounts ca, ' ||
			'   hz_cust_site_uses_all site_uses, ' ||
			'   hz_parties p ' ||
			' WHERE acct_sites.cust_account_id = ca.cust_account_id ' ||
			'  AND acct_sites.party_site_id = party_site.party_site_id ' ||
			'  AND acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id ' ||
			'  AND site_uses.site_use_code = ''BILL_TO'' ' ||
			'  AND ca.party_id = p.party_id ';
else
	l_custom_select := 'SELECT p.party_name ' ||
		' From hz_cust_acct_sites_all acct_sites, ' ||
		'   hz_party_sites party_site, ' ||
		'   hz_cust_accounts ca, ' ||
		'   hz_cust_site_uses_all site_uses, ' ||
		'   hz_parties p,' ||
		'   iex_delinquencies_all del ' ||
		' WHERE acct_sites.cust_account_id = ca.cust_account_id ' ||
		'  AND acct_sites.party_site_id = party_site.party_site_id ' ||
		'  AND acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id ' ||
		'  AND site_uses.site_use_code = ''BILL_TO'' ' ||
		'  AND ca.party_id = p.party_id ' ||
		'  AND del.customer_site_use_id = site_uses.site_use_id ';
end if;

if p_customer_name_low IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(p.party_name) >= upper(''' || p_customer_name_low || ''') ';
end if;

if p_customer_name_high IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(p.party_name) <= upper(''' || p_customer_name_high || ''') ';
end if;

if p_account_number_low IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(ca.account_number) >= upper(''' || p_account_number_low || ''') ';
end if;

if p_account_number_high IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(ca.account_number) <= upper(''' || p_account_number_high || ''') ';
end if;

if p_billto_location_low IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(site_uses.location) >= upper(''' || p_billto_location_low || ''') ';
end if;

if p_billto_location_high IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(site_uses.location) <= upper(''' || p_billto_location_high || ''') ';
end if;

/*
if l_StrategyLevelName = 'CUSTOMER' then
	l_custom_select := l_custom_select || ' AND p.party_id ';
elsif l_StrategyLevelName = 'ACCOUNT' then
	l_custom_select := l_custom_select || ' AND ca.cust_account_id ';
elsif l_StrategyLevelName = 'BILL_TO' then
	l_custom_select := l_custom_select || ' AND site_uses.site_use_id ';
else
	l_custom_select := l_custom_select || ' AND del.delinquency_id ';
end if;
*/

if p_strategy_level = 10 then
	l_custom_select := l_custom_select || ' AND p.party_id ';
elsif p_strategy_level = 20 then
	l_custom_select := l_custom_select || ' AND ca.cust_account_id ';
elsif p_strategy_level = 30 then
	l_custom_select := l_custom_select || ' AND site_uses.site_use_id ';
else
	l_custom_select := l_custom_select || ' AND del.delinquency_id ';
end if;

write_log(FND_LOG.LEVEL_STATEMENT,G_PKG_NAME || ' ' || l_api_name || ' - l_custom_select : '||l_custom_select);

END custom_where_clause;
--End adding by gnramasa for bug 8630852 13-July-09

PROCEDURE open_strategies
(
	ERRBUF      	OUT NOCOPY     VARCHAR2,
	RETCODE     	OUT NOCOPY     VARCHAR2,
	p_ignore_switch	IN 	       VARCHAR2,
	p_strategy_mode IN   VARCHAR2)  -- added by gnramasa for bug 8630852 13-July-09
-- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
IS
	l_result       VARCHAR2(10);

	l_error_msg     VARCHAR2(2000);
	l_return_status     VARCHAR2(20);
	l_msg_count     NUMBER;
	l_msg_data     VARCHAR2(2000);
	l_api_name     VARCHAR2(100) ;
	l_api_version_number          CONSTANT NUMBER   := 2.0;

    vStrategyStatus     VARCHAR2(30);
    vStrategyStatus1     VARCHAR2(30);  --Added for bug#5126770 schekuri 04-Apr-2006
    vOrginalStrategyStatus     VARCHAR2(30); --Added for bug#5202312 by schekuri on 05-May-2006
    -- ctlee score tolerance checking
    vScoreValue         number;
    vStrategyRank       VARCHAR2(10);
    vScoreTolerance     number;
    vStrategyId         number;
    vChangeStrategy     VARCHAR2(4);
    vStrategyTemplateId         number;

    l_strategy_processid NUMBER;
	l_delinquency_id number;
	l_party_cust_id number;
	l_cust_account_id number;
	l_transaction_id number;
	l_payment_schedule_id number;
	l_object_id number;
	l_object_code varchar2(40);
	l_strategy_id number;
	l_strategy_template_id number;
	l_object_version_number number := 1.0;
        l_strat_count number:=0; --Added for bug#7594370 by PNAVEENK

     Cursor c_score_exists( p_object_id number, p_object_type varchar2) is
         select score_value
                from iex_score_histories
                where score_object_id = p_object_id
                and score_object_code = p_object_type
                order by creation_date desc;

	l_stry_cnt_rec  IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE ;

   -- Begin - Andre - bug#4551569 - Change cursor to find 2 types of objects
        Cursor c_score_exists_del(p_object_id number,  p_object_type varchar2, p_object_id2 number, p_object_type2 varchar2) is
         select score_value, score_object_id, score_object_code
                from iex_score_histories
                where score_object_id in (p_object_id, p_object_id2)
                and score_object_code in (p_object_type, p_object_type2)
                order by creation_date desc;

	l_score_object_id number;
	l_score_object_code varchar2(40);
    -- End - Andre - bug#4551569 - Change cursor to find 2 types of objects

	l_strategy_rec IEX_STRATEGY_PVT.STRATEGY_REC_TYPE;
    l_default_rs_id  number ;
    l_resource_id NUMBER;
    l_StrategyTempID number;
    b_Skip varchar2(10);


    TYPE c_open_delinquenciesCurTyp IS REF CURSOR;  -- weak
    c_open_delinquencies c_open_delinquenciesCurTyp;  -- declare cursor variable

    TYPE c_strategy_existsCurTyp IS REF CURSOR;  -- weak
    c_strategy_exists c_strategy_existsCurTyp;  -- declare cursor variable

    -- get IEX Strategy grace period
    vGracePeriod Date;
    l_gracePeriod NUMBER ;
    TYPE c_gracePeriodCurTyp IS REF CURSOR;  -- weak
    c_gracePeriod c_gracePeriodCurTyp;  -- declare cursor variable

    pre_delinquency_flag varchar2(1) ;
    vCheckList varchar2(1) ;

    -- Begin - Andre Araujo -- 01/18/2005 - We should look at score histories for delinquency scores too
    l_id_save number;
    -- End - Andre Araujo -- 01/18/2005 - We should look at score histories for delinquency scores too

    -- bug 4141678 begin - ctlee
    l_batch_size NUMBER ;
    l_save_count NUMBER ;
    l_commit_count NUMBER ;
    -- TYPE STRATEGY_ID_TBL_type is Table of IEX_strategies.strategy_id%TYPE INDEX BY BINARY_INTEGER;
    -- l_strategy_tbl             STRATEGY_ID_TBL_TYPE;
    -- bug 4141678 end  - ctlee

    -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
    l_ignore_switch varchar2(1) := 'N';
    l_del_query varchar2(2500);
    -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records

    l_temp_grace_period number:=0;  --Added for bug#7594370 by PNAVEENK
    l_reassign_sty      varchar2(1):= 'N';  -- added by gnramasa for bug 8630852 13-July-09

    l_turnoff_coll_on_bankru	  varchar2(10);
    l_no_of_bankruptcy		  number;

    cursor c_no_of_bankruptcy (p_par_id number)
    is
    select nvl(count(*),0)
    from iex_bankruptcies
    where party_id = p_par_id
    and (disposition_code in ('GRANTED','NEGOTIATION')
         OR (disposition_code is NULL));



BEGIN
    -- initialize variable here
	l_api_name    := 'START_WORKFLOW';
	l_stry_cnt_rec  := IEX_STRATEGY_TYPE_PUB.INST_STRY_CNT_REC;
        l_default_rs_id  := NVL(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'), 0);
        l_resource_id :=  NVL(fnd_profile.value('IEX_STRY_FULFILMENT_RESOURCE'), 0);
        b_Skip := 'F';
        l_gracePeriod := NVL(to_number(FND_PROFILE.VALUE('IEX_STRY_GRACE_PERIOD')), 0);
        pre_delinquency_flag := 'N';
        vCheckList := 'N';
        l_batch_size := NVL(to_number(FND_PROFILE.VALUE('IEX_BATCH_SIZE')), 5000);
        l_save_count := 0;
        l_commit_count := 0;
        -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
        l_ignore_switch := NVL(p_ignore_switch, 'N');
        -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records


    -- dbms_session.set_sql_trace(true);
    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Check the required profiles for Strategy Concurrent before starting */
    if (NVL(FND_PROFILE.VALUE('IEX_STRATEGY_DISABLED'), 'N') = 'Y') then
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy creation aborted. ' );
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy Disabled by Profile ');
        return;
    end if;

    if (l_DefaultStrategyLevel = 50) Then
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy creation stopped. ' );
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'No Default Strategy Run Level from IEX_APP_PREFERENCES ');
        b_Skip := 'T';
    end if;

    l_StrategyTempID := NVL(to_number(FND_PROFILE.VALUE('IEX_STRATEGY_DEFAULT_TEMPLATE')), 0);
    if (l_StrategyTempID = 0) Then
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy creation stopped. ' );
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'No Default Strategy Template Profile ');
        b_Skip := 'T';
    end if;

    if (l_default_rs_ID = 0) Then
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy creation stopped. ' );
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy Default Resource Profile not set. IEX: Strategy Default Resource ');
        b_Skip := 'T';
    end if;

    if (l_resource_ID = 0) Then
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy creation stopped. ' );
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy Fulfilment Resource Profile not set. ');
        write_log(FND_LOG.LEVEL_UNEXPECTED, 'Fulfilment Resource should be configured for fulfilment ');
        b_Skip := 'T';
    end if;

    if (b_Skip = 'T') then
        retcode := '2';
        return;
    end if;

    write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy creation started. ' );
    -- Standard Start of API savepoint
    SAVEPOINT START_STRY_CONT;

    begin
     SELECT decode(COUNT(*), 0, 'N', 'Y') into pre_delinquency_flag FROM IEX_STRATEGY_TEMPLATES_VL
        WHERE CATEGORY_TYPE = l_DelStatusPreDel;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line(FND_FILE.LOG, 'Pre Delinquency flag raised exception; sqlcode =  ' || sqlcode || ' sqlerrm = ' || sqlerrm);
    end;

    write_log(FND_LOG.LEVEL_UNEXPECTED, 'pre-delinquency strategy template flag = ' ||pre_delinquency_flag);

    -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
    write_log(FND_LOG.LEVEL_UNEXPECTED, 'Do not automatically switch strategies flag = ' ||l_ignore_switch);
    write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy Grace Period = ' || l_graceperiod);
    -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records

    write_log(FND_LOG.LEVEL_STATEMENT, 'Delinquency cursor started ');

    write_log(FND_LOG.LEVEL_STATEMENT, 'System Strategy Level' || l_system_strategy_level);

    /* Check the strategy Run level */
    /* ctlee - add status and pass it to GetTemplateId 7/3/2003 */
    IF l_DefaultStrategyLevel = 10  THEN
        -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
        --OPEN c_open_delinquencies
         -- FOR
	   l_del_query := 'select d.party_cust_id, null, null, null, null, null,';
	   l_del_query := l_del_query || ' d.party_cust_id object_id, ''PARTY'' object_type, null';
           l_del_query := l_del_query || ' , 10 strategy_level,  d.PARTY_CUST_ID jtf_object_id, ''PARTY'' jtf_object_type';
           l_del_query := l_del_query || ' , null status';
	   l_del_query := l_del_query || ' from iex_delinquencies_all d';
           -- Start for bug 8708271 multi level strategy
           if l_party_override = 'Y' then
	   l_del_query := l_del_query || ' ,  hz_party_preferences partyPrf  ';
	   end if;

           l_del_query := l_del_query || ' where d.status = ''' || l_DelStatusDel || '''';
	   if l_party_override = 'Y' then
	   l_del_query := l_del_query || ' and partyPrf.party_id(+)  = d.party_cust_id '
                                      || ' and partyPrf.module(+) = ''COLLECTIONS'' '
	                              || ' and partyPrf.category(+)=''COLLECTIONS LEVEL'' '
	                              || ' and partyPrf.preference_code(+)=''PARTY_ID'' '
				      || ' and nvl(partyPrf.value_varchar2,'''||l_system_strategy_level||''')=''CUSTOMER'' ';
	   else

	         if l_system_strategy_level = 'CUSTOMER' then  -- proceed when system strategy level is customer otherwise return
			 null;
		 else
			 return;
		 end if;
	--   l_del_query := l_del_query || ' and l_system_strategy_level=''PARTY''';
	   end if;
	   -- end for bug 8708271 bug 8708271 multi level strategy
	   if l_custom_select IS NOT NULL then
		l_del_query := l_del_query || ' and exists ( ' || l_custom_select || ' = d.party_cust_id ) ';
	   end if;
          --Bug#6870773 Naveen
	  if l_org_enabled = 'Y' then
		l_del_query := l_del_query || ' and d.org_id = ' || l_org_id ;
	   end if;

           if l_ignore_switch = 'Y' then
	      --Bug#520231 schekuri 05-MAY-2006
	      --Changed OBJECT_TYPE and OBJECT_ID to JTF_OBJECT_TYPE and JTF_OBJECT_ID
              l_del_query := l_del_query || ' and not exists (select 1 from iex_strategies where JTF_OBJECT_TYPE = ''PARTY'' and JTF_OBJECT_ID = d.party_cust_id and STATUS_CODE = ''OPEN'') ';
           end if;

           l_del_query := l_del_query || ' group by d.party_cust_id';
	   l_del_query := l_del_query || ' order by d.party_cust_id';
          -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
    elsif l_DefaultStrategyLevel = 20 THEN
          -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
          --OPEN c_open_delinquencies
          --FOR
            l_del_query := 'select d.party_cust_id, d.cust_account_id, null, null, null, null,';
	    l_del_query := l_del_query || ' d.cust_account_id object_id, ''ACCOUNT'' object_type, null,';
            l_del_query := l_del_query || ' 20 strategy_level, d.cust_account_id jtf_object_id, ''IEX_ACCOUNT'' jtf_object_type';
            l_del_query := l_del_query || ' , null status';
	    l_del_query := l_del_query || ' from iex_delinquencies_all d';
	    -- Start for bug 8708271 multi level strategy
            if l_party_override = 'Y' then
	    l_del_query := l_del_query || ' ,  hz_party_preferences partyPrf  ';
	    end if;
            l_del_query := l_del_query || ' where d.status = ''' || l_DelStatusDel || '''';
	    if l_party_override = 'Y' then
	    l_del_query := l_del_query || ' and partyPrf.party_id(+)  = d.party_cust_id '
                                      || ' and partyPrf.module(+) = ''COLLECTIONS'' '
	                              || ' and partyPrf.category(+)=''COLLECTIONS LEVEL'' '
	                              || ' and partyPrf.preference_code(+)=''PARTY_ID'' '
				      || ' and nvl(partyPrf.value_varchar2,'''||l_system_strategy_level||''')=''ACCOUNT'' ';
	    else
	         if l_system_strategy_level = 'ACCOUNT' then
			 null;
		 else
			 return;
		 end if;
	 --  l_del_query := l_del_query || ' and l_system_strategy_level=''ACCOUNT''';
	    end if;
	    -- end for bug 8708271 bug 8708271 multi level strategy
	    if l_custom_select IS NOT NULL then
		l_del_query := l_del_query || ' and exists ( ' || l_custom_select || ' = d.cust_account_id ) ';
	    end if;
       --Bug#6870773 Naveen
         if l_org_enabled = 'Y' then
		l_del_query := l_del_query || ' and d.org_id = ' || l_org_id ;
	    end if;
            if l_ignore_switch = 'Y' then
	      --Bug#520231 schekuri 05-MAY-2006
	      --Changed OBJECT_TYPE and OBJECT_ID to JTF_OBJECT_TYPE and JTF_OBJECT_ID
              l_del_query := l_del_query || ' and not exists (select 1 from iex_strategies where JTF_OBJECT_TYPE = ''IEX_ACCOUNT'' and JTF_OBJECT_ID = d.cust_account_id and STATUS_CODE = ''OPEN'') ';
            end if;

            l_del_query := l_del_query || ' group by d.party_cust_id, d.cust_account_id';
	    l_del_query := l_del_query || ' order by d.party_cust_id, d.cust_account_id';
          -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
    elsif l_DefaultStrategyLevel = 30 THEN
          -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
          --OPEN c_open_delinquencies
          --FOR
            l_del_query := 'select d.party_cust_id, d.cust_account_id, d.customer_site_use_id, null, null, null,';
	    l_del_query := l_del_query || ' d.customer_site_use_id object_id, ''BILL_TO'' object_type, null,';
            l_del_query := l_del_query || ' 30 strategy_level, d.customer_site_use_id jtf_object_id, ''IEX_BILLTO'' jtf_object_type';
            l_del_query := l_del_query || ' , null status';
	    l_del_query := l_del_query || ' from iex_delinquencies_all d';
	     -- Start for bug 8708271 multi level strategy
            if l_party_override = 'Y' then
	     l_del_query := l_del_query || ' ,  hz_party_preferences partyPrf  ';
	    end if;
            l_del_query := l_del_query || ' where d.status = ''' || l_DelStatusDel || '''';
	    if l_party_override = 'Y' then
	    l_del_query := l_del_query || ' and partyPrf.party_id(+)  = d.party_cust_id '
                                      || ' and partyPrf.module(+) = ''COLLECTIONS'' '
	                              || ' and partyPrf.category(+)=''COLLECTIONS LEVEL'' '
	                              || ' and partyPrf.preference_code(+)=''PARTY_ID'' '
				      || ' and nvl(partyPrf.value_varchar2,'''||l_system_strategy_level||''')=''BILL_TO'' ';

	    else
	         if l_system_strategy_level = 'BILL_TO' then
			 null;
		 else
			 return;
		 end if;
	   -- l_del_query := l_del_query || ' and l_system_strategy_level=''BILL_TO''';
	    end if;
	    -- end for bug 8708271 bug 8708271 multi level strategy
	    if l_custom_select IS NOT NULL then
		l_del_query := l_del_query || ' and exists ( ' || l_custom_select || ' = d.customer_site_use_id ) ';
	    end if;
        --Bug#6870773 Naveen
		if l_org_enabled = 'Y' then
		l_del_query := l_del_query || ' and d.org_id = ' || l_org_id ;
	        end if;
            if l_ignore_switch = 'Y' then
	      --Bug#520231 schekuri 05-MAY-2006
	      --Changed OBJECT_TYPE and OBJECT_ID to JTF_OBJECT_TYPE and JTF_OBJECT_ID
              l_del_query := l_del_query || ' and not exists (select 1 from iex_strategies where JTF_OBJECT_TYPE = ''IEX_BILLTO'' and JTF_OBJECT_ID = d.customer_site_use_id and STATUS_CODE = ''OPEN'') ';
            end if;

            l_del_query := l_del_query || ' group by d.party_cust_id, d.cust_account_id, d.customer_site_use_id';
	    l_del_query := l_del_query || ' order by d.party_cust_id, d.cust_account_id, d.customer_site_use_id';
          -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
    ELSE
      if (pre_delinquency_flag = 'Y') then
         -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
         --OPEN c_open_delinquencies
         --FOR
	    l_del_query := 'select d.party_cust_id, d.cust_account_id, d.customer_site_use_id, d.delinquency_id,';
	    l_del_query := l_del_query || ' d.transaction_id, d.payment_schedule_id,';
	    l_del_query := l_del_query || ' d.delinquency_id object_id, ''DELINQUENT'' object_type ,';
	    l_del_query := l_del_query || ' d.score_value, 40 strategy_level, d.delinquency_id jtf_object_id,';
            l_del_query := l_del_query || '             ''IEX_DELINQUENCY'' jtf_object_type';
            l_del_query := l_del_query || '             , d.status status';
	    l_del_query := l_del_query || ' from iex_delinquencies_all d';
	    -- Start for bug 8708271 multi level strategy
            if l_party_override = 'Y' then
	    l_del_query := l_del_query || ' ,  hz_party_preferences partyPrf  ';
	    end if;
            l_del_query := l_del_query || ' where  (d.status = ''' || l_DelStatusDel || '''' || '  or d.status = ''' || l_DelStatusPreDel || '''' || ')';
	    if l_party_override = 'Y' then
	    l_del_query := l_del_query || ' and partyPrf.party_id(+)  = d.party_cust_id '
                                      || ' and partyPrf.module(+) = ''COLLECTIONS'' '
	                              || ' and partyPrf.category(+)=''COLLECTIONS LEVEL'' '
	                              || ' and partyPrf.preference_code(+)=''PARTY_ID'' '
				      || ' and nvl(partyPrf.value_varchar2,'''||l_system_strategy_level||''')=''DELINQUENCY'' ';
	    else
	         if l_system_strategy_level = 'DELINQUENCY' then
			 null;
		 else
			 return;
		 end if;
	   -- l_del_query := l_del_query || ' and l_system_strategy_level=''DELINQUENCY''';
            end if;
	    -- end for bug 8708271 multi level strategy
	    if l_custom_select IS NOT NULL then
		l_del_query := l_del_query || ' and exists ( ' || l_custom_select || ' = d.delinquency_id ) ';
	    end if;
     --Bug#6870773 Naveen
		if l_org_enabled = 'Y' then
		l_del_query := l_del_query || ' and d.org_id = ' || l_org_id ;
	        end if;
            if l_ignore_switch = 'Y' then
	       --Bug#520231 schekuri 05-MAY-2006
	      --Changed OBJECT_TYPE and OBJECT_ID to JTF_OBJECT_TYPE and JTF_OBJECT_ID
               l_del_query := l_del_query || ' and not exists (select 1 from iex_strategies where JTF_OBJECT_TYPE = ''IEX_DELINQUENCY'' and JTF_OBJECT_ID = d.delinquency_id and STATUS_CODE = ''OPEN'') ';
            end if;
           -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
      else
         -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
         --OPEN c_open_delinquencies
         --FOR
	   l_del_query := 'select d.party_cust_id, d.cust_account_id, d.customer_site_use_id, d.delinquency_id,';
	   l_del_query := l_del_query || ' d.transaction_id, d.payment_schedule_id,';
	   l_del_query := l_del_query || ' d.delinquency_id object_id, ''DELINQUENT'' object_type ,';
	   l_del_query := l_del_query || ' d.score_value, 40 strategy_level, d.delinquency_id jtf_object_id,';
           l_del_query := l_del_query || '             ''IEX_DELINQUENCY'' jtf_object_type';
           l_del_query := l_del_query || '             , d.status status';
	   l_del_query := l_del_query || ' from iex_delinquencies_all d';
	   -- Start for bug 8708271 multi level strategy
            if l_party_override = 'Y' then
	    l_del_query := l_del_query || ' ,  hz_party_preferences partyPrf  ';
	    end if;
            l_del_query := l_del_query || ' where   d.status = ''' || l_DelStatusDel || '''';
	    if l_party_override = 'Y' then
	    l_del_query := l_del_query || ' and partyPrf.party_id(+)  = d.party_cust_id '
                                      || ' and partyPrf.module(+) = ''COLLECTIONS'' '
	                              || ' and partyPrf.category(+)=''COLLECTIONS LEVEL'' '
	                              || ' and partyPrf.preference_code(+)=''PARTY_ID'' '
				      || ' and nvl(partyPrf.value_varchar2,'''||l_system_strategy_level||''')=''DELINQUENCY'' ';
	    else
	         if l_system_strategy_level = 'DELINQUENCY' then
			 null;
		 else
			 return;
		 end if;
	--    l_del_query := l_del_query || ' and l_system_strategy_level=''DELINQUENCY''';
            end if;
	    -- end for bug 8708271 multi level strategy
	   if l_custom_select IS NOT NULL then
		l_del_query := l_del_query || ' and exists ( ' || l_custom_select || ' = d.delinquency_id ) ';
	    end if;
      --Bug#6870773 Naveen
		if l_org_enabled = 'Y' then
		l_del_query := l_del_query || ' and d.org_id = ' || l_org_id ;
	        end if;
           if l_ignore_switch = 'Y' then
	      --Bug#520231 schekuri 05-MAY-2006
	      --Changed OBJECT_TYPE and OBJECT_ID to JTF_OBJECT_TYPE and JTF_OBJECT_ID
              l_del_query := l_del_query || ' and not exists (select 1 from iex_strategies where JTF_OBJECT_TYPE = ''IEX_DELINQUENCY'' and JTF_OBJECT_ID = d.delinquency_id and STATUS_CODE = ''OPEN'') ';
           end if;
           -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
      end if;
    END IF;
    --Bug#6870773 Naveen

	fnd_file.put_line(FND_FILE.LOG, l_del_query);
    -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
    OPEN c_open_delinquencies
       FOR l_del_query;
    -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records

    -- FOR f_delinquency_rec in  C_Open_Delinquencies loop
    LOOP

       FETCH c_open_delinquencies INTO
          l_stry_cnt_rec.party_cust_id,
          l_stry_cnt_rec.cust_account_id,
          l_stry_cnt_rec.customer_site_use_id,
          l_stry_cnt_rec.delinquency_id,
          l_stry_cnt_rec.transaction_id,
          l_stry_cnt_rec.payment_schedule_id,
          l_stry_cnt_rec.object_id,
          l_stry_cnt_rec.object_type,
          l_stry_cnt_rec.score_value,
          l_stry_cnt_rec.strategy_level,
          l_stry_cnt_rec.jtf_object_id,
          l_stry_cnt_rec.jtf_object_type,
          l_stry_cnt_rec.status;
          /* ctlee - add status and pass it to GetTemplateId 7/3/2003 */

       if c_open_delinquencies%FOUND then
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          write_log(FND_LOG.LEVEL_STATEMENT, 'Delinquency_id  = '
			|| l_stry_cnt_rec.delinquency_id
            || ' object Id = ' || l_stry_cnt_rec.object_id
            || ' object_type = ' || l_stry_cnt_rec.object_type
            || ' jtf_object Type ' || l_stry_cnt_rec.jtf_object_type
            || ' jtf_object id ' || l_stry_cnt_rec.jtf_object_id
            || ' Score Value = ' || l_stry_cnt_rec.score_value
	    || ' status = ' || l_stry_cnt_rec.status
            || ' Strategy Level = ' || l_stry_cnt_rec.strategy_level );
         END IF;

          -- Begin - Andre Araujo -- 01/18/2005 - We should look at score histories for delinquency scores too
          --IF l_DefaultStrategyLevel = 10 or l_DefaultStrategyLevel = 20 or l_DefaultStrategyLevel = 30 then
          IF l_DefaultStrategyLevel = 10 or l_DefaultStrategyLevel = 20 or l_DefaultStrategyLevel = 30 or l_DefaultStrategyLevel = 40 then
          -- End - Andre Araujo -- 01/18/2005 - We should look at score histories for delinquency scores too

          begin
             -- Begin - Andre Araujo -- bug#4551569 - 08/18/2005 - Scores for delinquencies still not being picked up
             -- Begin - Andre Araujo -- 01/18/2005 - We should look at score histories for delinquency scores too
--             if l_DefaultStrategyLevel = 40 then
--                l_id_save                      := l_stry_cnt_rec.jtf_object_id;
--                l_stry_cnt_rec.jtf_object_id   := l_stry_cnt_rec.payment_schedule_id;
--                l_stry_cnt_rec.jtf_object_type := 'IEX_INVOICES';
--             end if;
--             -- End - Andre Araujo -- 01/18/2005 - We should look at score histories for delinquency scores too
--
--             Open c_Score_Exists(l_stry_cnt_rec.jtf_object_id, l_stry_cnt_rec.jtf_object_type);
--             fetch c_Score_Exists into l_stry_cnt_rec.score_value;
--             Close c_Score_Exists;
--             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--             write_log(FND_LOG.LEVEL_STATEMENT, ' Got New Score using c_Score_Exists  '
--                || ' jtf_object Type ' || l_stry_cnt_rec.jtf_object_type
--                || ' jtf_object id ' || l_stry_cnt_rec.jtf_object_id
--                || ' Score Value = ' || l_stry_cnt_rec.score_value );
--             end if;
--
--             -- Begin - Andre Araujo -- 01/18/2005 - We should look at score histories for delinquency scores too
--             if l_DefaultStrategyLevel = 40 then
--                l_stry_cnt_rec.jtf_object_id   := l_id_save;
--                l_stry_cnt_rec.jtf_object_type := 'IEX_DELINQUENCY';
--             end if;
--             -- End - Andre Araujo -- 01/18/2005 - We should look at score histories for delinquency scores too

             if l_DefaultStrategyLevel <> 40 then -- This will pick the scores for all levels but not for delinquency
                Open c_Score_Exists(l_stry_cnt_rec.jtf_object_id, l_stry_cnt_rec.jtf_object_type);
                fetch c_Score_Exists into l_stry_cnt_rec.score_value;
                Close c_Score_Exists;

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                write_log(FND_LOG.LEVEL_STATEMENT, ' Got New Score using c_Score_Exists  '
                   || '; jtf_object Type= ' || l_stry_cnt_rec.jtf_object_type
                   || '; jtf_object id= ' || l_stry_cnt_rec.jtf_object_id
                   || '; Score Value = ' || l_stry_cnt_rec.score_value );
                end if;
             else
                -- When looking for scores for delinquencies we should look for the newest score from either the payment schedule OR Delinquency
                -- This is so because the first score of a delinquency is the score of the delinquent payment schedule
                -- but if a customer scores the delinquency we should use the delinquency score to set the strategy
                Open c_score_exists_del(l_stry_cnt_rec.payment_schedule_id, 'IEX_INVOICES', l_stry_cnt_rec.delinquency_id, 'IEX_DELINQUENCY');
                fetch c_score_exists_del into l_stry_cnt_rec.score_value, l_score_object_id, l_score_object_code;
                Close c_score_exists_del;
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                write_log(FND_LOG.LEVEL_STATEMENT, ' Got New Score using c_Score_Exists_del  '
                   || '; jtf_object Type= ' || l_score_object_code
                   || '; jtf_object id= ' || l_score_object_id
                   || '; Score Value = ' || l_stry_cnt_rec.score_value );
                end if;
             end if;
             -- End - Andre Araujo -- bug#4551569 - 08/18/2005 - Scores for delinquencies still not being picked up

          EXCEPTION
              WHEN OTHERS THEN
                 fnd_file.put_line(FND_FILE.LOG, 'NO score available ' ||
                          ' object Type ' || l_stry_cnt_rec.jtf_object_type  ||
                          ' object ID ' ||  l_stry_cnt_rec.jtf_object_id);
                 l_strategy_rec.score_value := 0;
                 l_stry_cnt_rec.score_value := 0;
                 retcode := '1';
              END;
          end if;


          -- ctlee score tolerance checking
          -- set to 0 if null
          if (l_stry_cnt_rec.score_value is null) then
             l_stry_cnt_rec.score_value := 0;
          end if;

          -- check grace period
          --  c_gracePeriod c_gracePeriodCurTyp;
          IF l_DefaultStrategyLevel = 10  THEN
             OPEN c_gracePeriod FOR
                select c.creation_date from iex_delinquencies_all c
                where (c.status = l_DelStatusDel or c.status = l_delStatusPreDel)
                and c.party_cust_id = l_stry_cnt_rec.PARTY_CUST_ID
	            order by c.creation_date asc;  -- Changed for bug#8248285 by PNAVEENK on 13-2-2009
          elsif l_DefaultStrategyLevel = 20 THEN
             OPEN c_gracePeriod FOR
                select c.creation_date from iex_delinquencies_all c
                where (c.status = l_DelStatusDel or c.status = l_delStatusPreDel)
                and c.party_cust_id = l_stry_cnt_rec.PARTY_CUST_ID
                and c.cust_account_id = l_stry_cnt_rec.CUST_ACCOUNT_ID
	            order by c.creation_date asc;   -- Changed for bug#8248285 by PNAVEENK on 13-2-2009
          elsif l_DefaultStrategyLevel = 30 THEN
             OPEN c_gracePeriod FOR
                select c.creation_date from iex_delinquencies_all c
                where (c.status = l_DelStatusDel or c.status = l_delStatusPreDel)
                and c.party_cust_id = l_stry_cnt_rec.PARTY_CUST_ID
                and c.cust_account_id = l_stry_cnt_rec.CUST_ACCOUNT_ID
                and c.customer_site_use_id = l_stry_cnt_rec.customer_site_use_ID
	            order by c.creation_date asc;  -- Changed for bug#8248285 by PNAVEENK on 13-2-2009
          ELSE
             OPEN c_gracePeriod FOR
                select c.creation_date from iex_delinquencies_all c
                where (c.status = l_DelStatusDel or c.status = l_delStatusPreDel)
                and c.party_cust_id = l_stry_cnt_rec.PARTY_CUST_ID
                and c.cust_account_id = l_stry_cnt_rec.CUST_ACCOUNT_ID
                and c.customer_site_use_id = l_stry_cnt_rec.customer_site_use_ID
                and c.delinquency_id = l_stry_cnt_rec.delinquency_id
	            order by c.creation_date asc;  -- Changed for bug#8248285 by PNAVEENK on 13-2-2009
          END IF;
          loop
             fetch c_gracePeriod into vGracePeriod;
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy grace Period ' || vGracePeriod );
             end if;
             if c_gracePeriod%notfound then
               exit;
             end if;
             exit;
          end loop;
          Close c_gracePeriod;

	  l_turnoff_coll_on_bankru	:= nvl(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'),'N');
	  write_log(FND_LOG.LEVEL_PROCEDURE, 'l_turnoff_coll_on_bankru: ' || l_turnoff_coll_on_bankru);

	  if l_turnoff_coll_on_bankru = 'Y' then
		open c_no_of_bankruptcy (l_stry_cnt_rec.PARTY_CUST_ID);
		fetch c_no_of_bankruptcy into l_no_of_bankruptcy;
		close c_no_of_bankruptcy;
	  end if;
	  write_log(FND_LOG.LEVEL_PROCEDURE, 'l_no_of_bankruptcy: ' || l_no_of_bankruptcy);

	  if (l_turnoff_coll_on_bankru = 'Y' and l_no_of_bankruptcy >0) then
		write_log(FND_LOG.LEVEL_PROCEDURE, 'Profile IEX: Turn Off Collections Activity for Bankruptcy is Yes and bankruptcy record is exist, so will skip assigning strategy');
		goto nextRec;
	  end if;


          -- check the status to see if the strategy has already run workflow
          vStrategyStatus :=  NULL;

         IF l_DefaultStrategyLevel = 10  THEN
             OPEN c_strategy_exists FOR
	        select status_code, decode(score_value, null, 0, score_value), strategy_id, strategy_template_id
                from iex_strategies where party_id = l_stry_cnt_rec.PARTY_CUST_ID
                and jtf_object_id = l_stry_cnt_rec.jtf_object_id
                and jtf_object_type = l_stry_cnt_rec.jtf_object_type
                and checklist_yn = vCheckList;
          elsif l_DefaultStrategyLevel = 20 THEN
             OPEN c_strategy_exists FOR
                select status_code, decode(score_value, null, 0, score_value), strategy_id, strategy_template_id
                from iex_strategies where CUST_ACCOUNT_ID = l_stry_cnt_rec.CUST_ACCOUNT_ID
                and jtf_object_id = l_stry_cnt_rec.jtf_object_id
                and jtf_object_type = l_stry_cnt_rec.jtf_object_type
                and checklist_yn = vCheckList;
          elsif l_DefaultStrategyLevel = 30 THEN
             OPEN c_strategy_exists FOR
                select status_code, decode(score_value, null, 0, score_value), strategy_id, strategy_template_id
                from iex_strategies where customer_site_use_ID = l_stry_cnt_rec.customer_site_use_ID
                and jtf_object_id = l_stry_cnt_rec.jtf_object_id
                and jtf_object_type = l_stry_cnt_rec.jtf_object_type
                and checklist_yn = vCheckList;
          ELSE
             OPEN c_strategy_exists FOR
     	        select status_code, decode(score_value, null, 0, score_value), strategy_id, strategy_template_id
                from iex_strategies where delinquency_id = l_stry_cnt_rec.delinquency_id
                and jtf_object_id = l_stry_cnt_rec.jtf_object_id
                and jtf_object_type = l_stry_cnt_rec.jtf_object_type
                and checklist_yn = vCheckList;
          END IF;

          /*
             Check any strategy already running then skip
             or if the open/pending strategy is out of score tolerance in its defined template then
             cancel the old strategy and create a new one (change_strategy needs to be Y)
          */
	  --Begin bug#5126770 schekuri 04-Apr-2006
          --reset the variables in each iteration of the loop
	  vStrategyStatus := NULL;
	  vStrategyStatus1 := NULL;
	  vScoreValue := NULL;
          vStrategyId := NULL;
	  vStrategyTemplateId := NULL;
	  --End bug#5126770 schekuri 04-Apr-2006

          loop
            fetch c_Strategy_Exists into vStrategyStatus, vScoreValue, vStrategyId, vStrategyTemplateId;
             if c_Strategy_exists%notfound then
               exit;
             elsif vStrategyStatus in ( l_StratStatusOpen, l_StratStatusPending, l_StratStatusOnhold) then
               exit;
             end if;
          end loop;
          Close C_Strategy_Exists;

          vOrginalStrategyStatus :=vStrategyStatus;  --Added for bug#5202312 by schekuri on 05-May-2006

          write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Status = ' || vStrategyStatus );
          write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Score Value = ' || vScoreValue );
          write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Id = ' || vStrategyId );
          write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Template Id = ' || vStrategyTemplateId );
          write_log(FND_LOG.LEVEL_PROCEDURE, 'score_history/delinquency Score Value = ' || l_stry_cnt_rec.score_value );

       if (vStrategyStatus = 'OPEN'  or vStrategyStatus = 'PENDING') then
           begin
              select strategy_rank, decode(score_tolerance, null, 0, score_tolerance), change_strategy_yn
              into vStrategyRank, vScoreTolerance, vChangeStrategy
              from iex_strategy_templates_vl where strategy_temp_id = vStrategyTemplateId;
            exception
            when others then
              vStrategyRank := '0';
              vScoreTolerance := 0;
              vChangeStrategy := 'N';
           end;
	  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       	  write_log(FND_LOG.LEVEL_PROCEDURE, 'Get Strategy Template Details of = ' || vStrategyTemplateId || ' of Strategy ID = ' || vStrategyID );
          write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Rank = ' || vStrategyRank );
          write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy score tolerance = ' || vScoreTolerance );
          write_log(FND_LOG.LEVEL_PROCEDURE, 'Change Strategy = ' || vChangeStrategy );
	  END IF;

          -- score in iex_strategies diff from score_histories/iex_delinquencies_all table
          -- and score history out of the strategy template score tolerance
          -- and strategy template change strategy flag is Y
          if (
               ( (vScoreValue <> l_stry_cnt_rec.score_value)
                 and
                 (
                   -- begin bug 4944801 ctlee 01/18/2006
                   -- (l_stry_cnt_rec.score_value > to_number(vStrategyRank) + vScoreTolerance)
                   -- or
                   -- (l_stry_cnt_rec.score_value < to_number(vStrategyRank) - vScoreTolerance)
                   (l_stry_cnt_rec.score_value > vScoreValue + vScoreTolerance)
                   or
                   (l_stry_cnt_rec.score_value < vScoreValue - vScoreTolerance)
                   -- end bug 4944801 ctlee 01/18/2006
                 )
               )
               and
                 (vChangeStrategy = 'Y')
             )  then

             --  cancel strategy
                   -- begin bug 4944801 ctlee 01/18/2006, cancel strategy only if the new strategy template id different from the old one
             -- BEGIN
               -- write_log(FND_LOG.LEVEL_PROCEDURE, 'cancel strategy id = ' || vStrategyId );
               -- IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
                 --                  strategy_id => vStrategyId,
                 --                  status      => 'CANCELLED' ) ;
             -- EXCEPTION
               -- WHEN OTHERS THEN
                 -- write_log(FND_LOG.LEVEL_PROCEDURE, 'cancel strategy exception occurred = ' );
                 -- UPDATE IEX_STRATEGIES SET STATUS_code = 'CANCELLED' WHERE STRATEGY_ID = vStrategyId;
             -- END;
                   -- end bug 4944801 ctlee 01/18/2006, cancel strategy only if the new strategy template id different from the old one
             vStrategyStatus := 'CANCELLED';
	     vStrategyStatus1 := 'CANCELLED';  --Added for bug#5126770 by schekuri on 04-Apr-2006
          end if;
        end if;  -- if OPEN or PENDING


          /* No Strategy exists or Existing running are closed, create a new strategy */
          if (((vStrategyStatus IS NULL)) or (vStrategyStatus = l_StratStatusClosed)
                                   or (vStrategyStatus = l_StratStatusCancelled)) then

             fnd_file.put_line(FND_FILE.LOG, ' Get Template for object '|| l_stry_cnt_rec.jtf_object_id);
             /* Get the strategy template ID based on the score */
    	     IEX_STRATEGY_CNT_PUB.GetStrategyTempID(
   			    x_return_status=>l_return_status,
			    p_stry_cnt_rec => l_stry_cnt_rec,
			    x_strategy_template_id => l_strategy_template_id
		     );
             fnd_file.put_line(FND_FILE.LOG, ' Template ID selected ' || l_strategy_template_id);
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             write_log(FND_LOG.LEVEL_PROCEDURE, 'Delinquency ID  ' || l_stry_cnt_rec.delinquency_id ||
                '  Strategy Template ID selected ' || l_strategy_template_id );
             end if;

             -- start for bug 8708271 multi level strategy
              --IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              write_log(FND_LOG.LEVEL_PROCEDURE, 'Cancelling strategies for Party ID  ' || l_stry_cnt_rec.party_cust_id ||
                '  if exists other than level ' || l_DefaultStrategyLevel );
              --end if;
	      cancel_strategy( l_stry_cnt_rec.party_cust_id, l_DefaultStrategyLevel,p_strategy_mode,
	                       l_stry_cnt_rec.cust_account_id, l_stry_cnt_rec.customer_site_use_id, l_stry_cnt_rec.delinquency_id);
	     -- end for bug 8708271 multi level strategy
              fnd_file.put_line(FND_FILE.LOG, 'Cancelletion of other level Strategies completed for object ' ||  l_stry_cnt_rec.party_cust_id);
		   -- begin bug 4944801 ctlee 01/18/2006
                   -- check if the template is the same
             BEGIN
                   -- old template is vStrategyTemplateId
                   -- new template is l_strategy_template_id
	       --Begin bug#5202312 schekuri 05-May-2006
	       --Need to check the status of the strategy in the database(not the modified one)
               /*if (l_strategy_template_id = vStrategyTemplateId and vStrategyStatus <> l_StratStatusClosed and
	           vStrategyStatus <> l_StratStatusCancelled) then*/
	       if (l_strategy_template_id = vStrategyTemplateId and vOrginalStrategyStatus <> l_StratStatusClosed and
	           vOrginalStrategyStatus <> l_StratStatusCancelled) then
	       --End bug#5202312 schekuri 05-May-2006

                  write_log(FND_LOG.LEVEL_PROCEDURE, 'same template and continue,  strategy template id = ' || vStrategyTemplateId );
                  goto nextRec;  -- continue to the loop for the next record, no need to change strategy

	       --Begin Bug#5126770 schekuri 04-Apr-2006
	       --Added IF condition to the following block of code to avoid junk Cancellation of Strategies
	       --Also enclosed the block of code between BEGIN and END and
	       --moved the exception handler from the outer block
               elsif vStrategyId IS NOT NULL AND vStrategyStatus1 = 'CANCELLED' THEN
		    --Start adding by gnramasa for bug 8630852 13-July-09
		    if p_strategy_mode = 'FINAL' then
			 BEGIN
				 write_log(FND_LOG.LEVEL_PROCEDURE, 'cancel strategy id = ' || vStrategyId );
				 IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
						  strategy_id => vStrategyId,
						  status      => 'CANCELLED' ) ;
			 EXCEPTION
				WHEN OTHERS THEN
				-- Added for bug 5877743 by gnramasa on 28-02-2007
				write_log(FND_LOG.LEVEL_PROCEDURE, 'cancel strategy exception occurred = ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
				UPDATE IEX_STRATEGIES SET STATUS_code = 'CANCELLED',
				last_update_date=sysdate    --Added for bug#7594370 by PNAVEENK
				WHERE STRATEGY_ID = vStrategyId;
			 END;
		     end if; --if p_strategy_mode = 'FINAL' then

		     l_reassign_sty  := 'Y';
		     --End adding by gnramasa for bug 8630852 13-July-09

		 --End Bug#5126770 schekuri 04-Apr-2006
               end if;
             EXCEPTION
               WHEN OTHERS THEN
	         --Begin bug#5126770 schekuri 04-Apr-2006
		 --Moved the exception handler to the inner block
	         NULL;
                 /*write_log(FND_LOG.LEVEL_PROCEDURE, 'cancel strategy exception occurred = ' );
                 UPDATE IEX_STRATEGIES SET STATUS_code = 'CANCELLED' WHERE STRATEGY_ID = vStrategyId;*/
		 --End bug#5126770 schekuri 04-Apr-2006
             END;
                   -- end bug 4944801 ctlee 01/18/2006


           --Start bug 6794510 gnramasa 7th feb 2008
	    if (NVL(FND_PROFILE.VALUE('IEX_SKIP_DEFAULT_STRATEGY_ASSIGNMENT'), 'N') = 'Y') then
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.LogMessage( 'Skip Default Strategy Assignment Profile value is: Y' );
			IEX_DEBUG_PUB.LogMessage( 'l_strategy_template_id: '|| l_strategy_template_id);
			IEX_DEBUG_PUB.LogMessage( 'l_StrategyTempID: '|| l_StrategyTempID);
		END IF;
		IF l_strategy_template_id = l_StrategyTempID THEN
		      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.LogMessage( 'Strategy creation aborted. ' );
			IEX_DEBUG_PUB.LogMessage( 'Skip Default Strategy Assignment by Profile ');
		      END IF;
			goto nextRec;  -- continue to the loop for the next record, no need to change strategy
		END IF;
	    end if;
	    --End bug 6794510 gnramasa 7th feb 2008
	   /* ctlee - GetTemplateId could be -1 for predelinquent status (donot use default template)
                      7/3/2003
              ctlee - Always use default template if not found; filtering at open_strategies()
                      no -1 is retrun 03/05/2004
            */
         /*   --Begin bug#7565056 schekuri 19-N0v-2008
	    --if (l_strategy_template_id <> -1)
            --and (trunc(sysdate) >= trunc(vGracePeriod) + l_gracePeriod) then
	    if vStrategyId is not null then
	    l_temp_grace_period:=0;
	    else
	    l_temp_grace_period:=l_gracePeriod;
	    end if;
          if (l_strategy_template_id <> -1)
          and (trunc(sysdate) >= trunc(vGracePeriod) + l_temp_grace_period) then
	     --End bug#7565056 schekuri 19-N0v-2008 */
           -- Begin for bug#7594370 by PNAVEENK

            if (vStrategyId is not null) and (l_strategy_template_id <> -1) then
		if vOrginalStrategyStatus in ('OPEN','ONHOLD') then
			l_temp_grace_period:=0;
		else
			select count(1)
			into l_strat_count
			from iex_strategies
			where jtf_object_id = l_stry_cnt_rec.jtf_object_id
			and jtf_object_type = l_stry_cnt_rec.jtf_object_type
			and checklist_yn = vCheckList
			and last_update_date>=trunc(sysdate)-1
			and status_code not in ('OPEN','ONHOLD');
			if l_strat_count>0 then
				l_temp_grace_period:=0;
			else
				l_temp_grace_period:=l_gracePeriod;
			end if;
		end if;
	    else
	    l_temp_grace_period:=l_gracePeriod;
	    end if;
          if (l_strategy_template_id <> -1)
          and (trunc(sysdate) >= trunc(vGracePeriod) + l_temp_grace_period) then
          -- End for bug#7594370 by PNAVEENK
           begin
             l_strategy_rec.strategy_template_id := l_strategy_template_id;
             l_strategy_rec.delinquency_id := l_stry_cnt_rec.delinquency_id;
             l_strategy_rec.party_id := l_stry_cnt_rec.party_cust_id;
             l_strategy_rec.cust_account_id := l_stry_cnt_rec.cust_account_id;
             l_strategy_rec.customer_site_use_id := l_stry_cnt_rec.customer_site_use_id;
             l_strategy_rec.next_work_item_id	:= null;
             l_strategy_rec.object_id := l_stry_cnt_rec.object_id;
             l_strategy_rec.object_type := l_stry_cnt_rec.object_type;
             l_strategy_rec.status_code := l_StratStatusOpen;
             l_strategy_rec.score_value := l_stry_cnt_rec.score_value;
             l_strategy_rec.checklist_yn := 'N';
             l_object_version_number := 1;
             l_strategy_rec.strategy_level := l_stry_cnt_rec.strategy_level;
             l_strategy_rec.jtf_object_type := l_stry_cnt_rec.jtf_object_type;
             l_strategy_rec.jtf_object_id := l_stry_cnt_rec.jtf_object_id;

      --Bug#6870773 Naveen
		if l_org_enabled = 'Y' then
			l_strategy_rec.org_id := l_org_id ;
	        else
			l_strategy_rec.org_id := null;
	         end if;

		--Start adding by gnramasa for bug 8630852 13-July-09
		if p_strategy_mode = 'FINAL' then

		     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		     write_log(FND_LOG.LEVEL_STATEMENT, 'Calling Create strategy for Delinquency ID '
				   || l_strategy_rec.delinquency_id);
		     end if;
		     Begin
			     -- bug 4141678 begin  - ctlee
			     --   p_commit set to false
			     -- bug 4141678 end  - ctlee
			fnd_file.put_line(FND_FILE.LOG,'Value of l_strategy_rec.org_id : '|| l_strategy_rec.org_id);
		        fnd_file.put_line(FND_FILE.LOG, ' Creating Strategy for ' || l_strategy_rec.object_id || ' of type ' || l_strategy_rec.object_type);
			iex_strategy_pvt.create_strategy(
					P_Api_Version_Number=>2.0,
					p_commit =>  FND_API.G_FALSE,
					P_Init_Msg_List     =>FND_API.G_TRUE,
					p_strategy_rec => l_strategy_rec,
					x_return_status=>l_return_status,
					x_msg_count=>l_msg_count,
					x_msg_data=>l_msg_data,
					x_strategy_id => l_strategy_id
			 );

			 l_strategy_rec.strategy_id := l_strategy_id;
                         fnd_file.put_line(FND_FILE.LOG, 'Strategy Created . Id = ' || l_strategy_id);
			 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			 write_log(FND_LOG.LEVEL_PROCEDURE, 'Return status = ' || l_return_status);
			 write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy created. id = ' || l_strategy_id);
			 end if;
		      -- bug 4141678 begin  - ctlee
		      -- EXCEPTION
		      --    WHEN OTHERS THEN
		      --       write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy create Return status = ' ||
		      --            l_return_status || ' ' || sqlerrm );
		      --       retcode := '2';
		      --       return;
		      -- END;
		      -- bug 4141678 end  - ctlee


		      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      write_log(FND_LOG.LEVEL_STATEMENT, 'Calling Workflow creation for Delinquency ID '
				|| l_strategy_rec.strategy_id);
		      end if;

		      -- BEGIN
		      -- bug 4141678 begin  - ctlee
		      --   p_commit set to false
		      -- bug 4141678 end  - ctlee

			 iex_strategy_wf_pub.start_workflow(
			    P_Api_Version =>2.0,
			    P_Init_Msg_List => FND_API.G_TRUE,
			    p_commit =>  FND_API.G_FALSE,
			    p_strategy_rec => l_strategy_rec,
			    x_return_status=>l_return_status,
			    x_msg_count=>l_msg_count,
			    x_msg_data=>l_msg_data
			 );

			 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			 write_log(FND_LOG.LEVEL_STATEMENT, 'Workflow Launch Return status = '
					|| l_return_status) ;
			 end if;
		      EXCEPTION
			 WHEN OTHERS THEN
			    fnd_file.put_line(FND_FILE.LOG, ' Exception: Create Strategy/Workflow Launch Return status = '
				|| l_return_status ||  ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
			    retcode := '2';
			    -- bug 4141678 begin  - ctlee
			    fnd_file.put_line(FND_FILE.LOG, 'commit count = ' || l_commit_count);
			    fnd_file.put_line(FND_FILE.LOG, 'save count = ' || l_save_count);
			    rollback;
			    l_save_count := 0;
			    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			    exit;
			    -- bug 4141678 end  - ctlee
		      END;
		end if;  --if p_strategy_mode = 'FINAL' then

		--Call gen_xml_body_strategy to insert this record to xml body
		if l_reassign_sty = 'N' then
			 gen_xml_body_strategy (p_strategy_rec       => l_strategy_rec,
						p_strategy_status    => 'CREATE');
		elsif l_reassign_sty = 'Y' then
			gen_xml_body_strategy (p_strategy_id        => vStrategyId,
					       p_strategy_rec       => l_strategy_rec,
					       p_strategy_status    => 'RECREATE');
		end if;  --if l_reassign_sty 'N' then
		l_reassign_sty  := 'N';
		--End adding by gnramasa for bug 8630852 13-July-09

              -- bug 4141678 begin  - ctlee
              l_save_count := l_save_count + 1;
              -- l_strategy_tbl(l_save_count) := l_strategy_id;
              if (l_save_count = l_batch_size) then
                  l_save_count := 0;
                  l_commit_count := l_commit_count + 1;
                  commit work;
              end if;
              -- bug 4141678 end  - ctlee
            end;
          end if; /* if template id is -1 then donot generate streategy */
         end if;  /* check status */
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         write_log(FND_LOG.LEVEL_STATEMENT, 'Delinquency cursor ends' );
         end if;
      ELSE  -- fetch failed, so exit loop
         EXIT;
      end if;   /* found cursor */
      <<nextRec>>
         null;
   END loop;

    -- bug 4141678 begin  - ctlee
    if (l_save_count > 0) then
      l_commit_count := l_commit_count + 1;
      commit work;
    end if;
    write_log(FND_LOG.LEVEL_UNEXPECTED, 'commit count = ' || l_commit_count);
    -- bug 4141678 end  - ctlee

   write_log(FND_LOG.LEVEL_UNEXPECTED, 'Delinquency cursor EXIT ');
   write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy creation completed ' );

   close c_open_delinquencies;

EXCEPTION
    WHEN OTHERS THEN
       fnd_file.put_line(FND_FILE.LOG, 'Delinquency Concurrent raised exception sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
       close c_open_delinquencies;
       -- bug 4141678 begin  - ctlee
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       -- bug 4141678 end  - ctlee
END open_strategies;

/* not used anywhere */
PROCEDURE CLOSE_ALL_STRY
(
		ERRBUF      OUT NOCOPY     VARCHAR2,
		RETCODE     OUT NOCOPY     VARCHAR2
) IS
	l_result       VARCHAR2(10);

	l_error_msg        VARCHAR2(2000);
	l_return_status    VARCHAR2(20);
	l_msg_count        NUMBER;
	l_msg_data     VARCHAR2(2000);
	l_api_name     VARCHAR2(100) ;
	l_api_version_number          CONSTANT NUMBER   := 2.0;

	vStrategyStatus     VARCHAR2(30);
	l_strategy_processid NUMBER;

	l_delinquency_id number;
	l_party_cust_id number;
	l_cust_account_id number;
	l_object_id number;
	l_object_code varchar2(40);
	l_strategy_id number;
	l_strategy_template_id number;
	l_object_version_number number := 1.0;
	l_strategy_process_id number;

    Cursor c_open_strategies is
	    select s.strategy_id, s.delinquency_id,
                s.object_id, s.object_type, s.strategy_template_id, s.jtf_object_type, s.jtf_object_id
		from iex_strategies s  where s.status_code IN (l_StratStatusOpen, l_StratStatusOnhold) AND
              checklist_yn = 'N';

	l_stry_cnt_rec  IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE ;

	l_strategy_rec IEX_STRATEGY_PVT.STRATEGY_REC_TYPE;

    l_itemtype  varchar2(30);
    l_itemkey   varchar2(50);

BEGIN

    --  initialize variables
    l_api_name    := 'START_WORKFLOW';
	l_stry_cnt_rec  := IEX_STRATEGY_TYPE_PUB.INST_STRY_CNT_REC;

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard Start of API savepoint
    SAVEPOINT CLOSE_STRY_CONT;

    write_log(FND_LOG.LEVEL_STATEMENT, 'Close Strategy cursor started ');

    FOR f_strategy_rec in  C_Open_strategies loop

        /* Create the strategy record */
        l_stry_cnt_rec.strategy_id := f_strategy_rec.strategy_id;
        l_stry_cnt_rec.delinquency_id := f_strategy_rec.delinquency_id;
        l_stry_cnt_rec.object_id := f_strategy_rec.object_id;
        l_stry_cnt_rec.object_type := f_strategy_rec.object_type;

        write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy ID ' ||  l_stry_cnt_rec.strategy_id
             || ' Delinquency ID  ' || l_stry_cnt_rec.delinquency_id
             || ' Object ID '  || l_stry_cnt_rec.object_id
             || ' Object Type '  || l_stry_cnt_rec.object_type
             || ' Strategy Template ID ' || l_strategy_template_id );

        write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Status ' || vStrategyStatus );

        l_itemtype := 'IEXSTRY';
        l_itemkey := to_char(l_stry_cnt_rec.strategy_id);

        BEGIN
            IEX_STRATEGY_WF.Send_Signal(
    		   process => l_itemtype,
               strategy_id => l_itemkey,
               status => l_StratStatusClosed
            );

            write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Closed. id = ' || l_stry_cnt_rec.strategy_id);

        EXCEPTION
            WHEN OTHERS THEN
               fnd_file.put_line(FND_FILE.LOG, 'Strategy Closed Raised Exception = ' ||
                 l_stry_cnt_rec.strategy_id || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
        END;

        write_log(FND_LOG.LEVEL_STATEMENT, 'Close Strategy cursor ends' );

	 END loop;
     write_log(FND_LOG.LEVEL_STATEMENT, 'Close Strategy cursor EXIT ');

EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG, 'Close Strategy raised exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);

END CLOSE_ALL_STRY;

/* Procedure for closing strategy when associated customer delinquencies are closed */
PROCEDURE Close_strategies
(
		ERRBUF      OUT NOCOPY     VARCHAR2,
		RETCODE     OUT NOCOPY     VARCHAR2,
		p_strategy_mode     IN     VARCHAR2   -- added by gnramasa for bug 8630852 13-July-09
) IS
	l_result       VARCHAR2(10);

	l_error_msg        VARCHAR2(2000);
	l_return_status    VARCHAR2(20);
	l_msg_count        NUMBER;
	l_msg_data     VARCHAR2(2000);
	l_api_name     VARCHAR2(100) ;
	l_api_version_number          CONSTANT NUMBER   := 2.0;

    vStrategyStatus     VARCHAR2(30);
    l_strategy_processid NUMBER;

	l_delinquency_id number;
	l_party_cust_id number;
	l_cust_account_id number;
	l_object_id number;
	l_object_code varchar2(40);
	l_strategy_id number;
	l_strategy_template_id number;
	l_object_version_number number := 1.0;
    l_strategy_process_id number;

    l_itemtype  varchar2(30);
    l_itemkey   varchar2(50);

    TYPE c_open_strategiesCurTyp IS REF CURSOR;  -- weak
    c_open_strategies c_open_strategiesCurTyp;  -- declare cursor variable

--Start added by gnramasa for bug 8630852 13-July-09
    vPLSQL	VARCHAR2(5000);

BEGIN
    --  initialize variables
    l_api_name    := 'START_WORKFLOW';

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    if (NVL(FND_PROFILE.VALUE('IEX_STRATEGY_DISABLED'), 'N') = 'Y') then
         write_log(FND_LOG.LEVEL_STATEMENT,' Profile Name  IEX: Strategy Disabled (IEX_STRATEGY_DISABLED) set to YES ');
	 return;
    end if;
    -- Standard Start of API savepoint
    SAVEPOINT CLOSE_STRY_CONT;


    --IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN  -- commented by gnramasa on 29/08/2006 for bug # 5487449
    write_log(FND_LOG.LEVEL_STATEMENT, 'Close Strategy cursor started ');
    --end if;

      --Start adding for bug 8756947 gnramasa 3rd Aug 09
      IF l_DefaultStrategyLevel = 10  THEN
         vPLSQL := 'select s.strategy_id, s.strategy_template_id, S.STATUS_CODE from iex_strategies s, iex_delinquencies_all d '||
          ' where s.strategy_level = ' || l_DefaultStrategyLevel || ' and '||
          ' s.status_code IN (''' || l_StratStatusOpen || ''', ''' || l_StratStatusOnhold || ''', ''' || l_StratStatusPending || ''') and '||
          /* begin add for bug 4408860 - add checking CLOSE status from case delinquency */
          ' (d.status = ''' || l_DelStatusCurrent || ''' or d.status = ''' || l_DelStatusClose || ''') and d.party_cust_id = s.party_id '||
          /* end add for bug 4408860 - add checking CLOSE status from case delinquency */
          ' and  not exists (select null from iex_delinquencies_all dd where dd.status '||
          '               = ''' || l_DelStatusDel || ''' and dd.party_cust_id = s.party_id) ';
			 --and dd.org_id = decode(l_org_enabled,'Y',l_org_id,dd.org_id))

	  if l_org_enabled = 'Y' then
		vPLSQL := vPLSQL || ' and nvl(s.org_id,-99) = decode( ''' || l_org_enabled || ''',''Y'', ' || l_org_id || ',nvl(s.org_id,-99)) '; --Bug# 6870773 Naveen
	  end if;
	  if l_custom_select IS NOT NULL then
		vPLSQL := vPLSQL || ' and exists ( ' || l_custom_select || '= s.party_id) ';
	  end if;
          vPLSQL := vPLSQL || ' group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE';

     elsif l_DefaultStrategyLevel = 20 THEN
          vPLSQL := 'select s.strategy_id, s.strategy_template_id, S.STATUS_CODE from iex_strategies s, iex_delinquencies_all d '||
          ' where s.strategy_level = ' || l_DefaultStrategyLevel ||' and '||
          ' s.status_code IN (''' || l_StratStatusOpen || ''', ''' || l_StratStatusOnhold || ''', ''' || l_StratStatusPending || ''') and '||
          /* begin add for bug 4408860 - add checking CLOSE status from case delinquency */
          ' (d.status = ''' || l_DelStatusCurrent || ''' or d.status = ''' || l_DelStatusClose || ''') and d.CUST_ACCOUNT_id = s.CUST_ACCOUNT_id '||
          /* end add for bug 4408860 - add checking CLOSE status from case delinquency */
          ' and not exists (select null from iex_delinquencies_all dd where dd.status '||
          '         = ''' || l_DelStatusDel || ''' and dd.CUST_ACCOUNT_id = s.CUST_ACCOUNT_id) ';
		   --and dd.org_id = decode(l_org_enabled,'Y',l_org_id,dd.org_id))
	  if l_org_enabled = 'Y' then
		vPLSQL := vPLSQL || ' and nvl(s.org_id,-99) = decode(''' || l_org_enabled || ''',''Y'',' || l_org_id || ',nvl(s.org_id,-99)) '; --Bug# 6870773 Naveen
	  end if;
	  if l_custom_select IS NOT NULL then
		vPLSQL := vPLSQL || ' and exists (' || l_custom_select || ' = s.cust_Account_id) ';
	  end if;
          vPLSQL := vPLSQL || ' group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE';

     elsif l_DefaultStrategyLevel = 30 THEN
          vPLSQL := 'select s.strategy_id, s.strategy_template_id, S.STATUS_CODE from iex_strategies s, iex_delinquencies_all d '||
          ' where s.strategy_level = ' || l_DefaultStrategyLevel || ' and '||
          ' s.status_code IN (''' || l_StratStatusOpen || ''', ''' || l_StratStatusOnhold || ''', ''' || l_StratStatusPending || ''') and '||
          /* begin add for bug 4408860 - add checking CLOSE status from case delinquency */
          ' (d.status = ''' || l_DelStatusCurrent || ''' or d.status = ''' || l_DelStatusClose || ''')  and d.customer_site_use_id = s.customer_site_use_id '||
          /* end add for bug 4408860 - add checking CLOSE status from case delinquency */
          ' and not exists (select null from iex_delinquencies_all dd where dd.status '||
          '         = ''' || l_DelStatusDel || ''' and dd.customer_site_use_id = s.customer_site_use_id) ';
		  -- and dd.org_id = decode(l_org_enabled,'Y',l_org_id,dd.org_id))
          if l_org_enabled = 'Y' then
		vPLSQL := vPLSQL || ' and nvl(s.org_id,-99) = decode(''' || l_org_enabled || ''',''Y'',' || l_org_id || ',nvl(s.org_id,-99))  '; --Bug# 6870773 Naveen
	  end if;
	  if l_custom_select IS NOT NULL then
		vPLSQL := vPLSQL || ' and exists ( ' || l_custom_select || '= s.customer_site_use_id) ';
	  end if;
          vPLSQL := vPLSQL || ' group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE';

     else
         /* begin bug 4253030 by ctlee 03/29/2005 */
         /*
            OPEN c_open_strategies
            FOR
	       select s.strategy_id, s.strategy_template_id, s.status_code
		   from iex_strategies s, iex_delinquencies_all d where d.status = l_DelStatusCurrent and
                s.strategy_level = l_DefaultStrategyLevel and
                s.object_id =  d.delinquency_id and
                s.status_code IN (l_StratStatusOpen, l_StratStatusOnhold, l_StratStatusPending);
         */
         /* end bug 4253030 by ctlee 03/29/2005 */
         vPLSQL := 'select s.strategy_id, s.strategy_template_id, s.status_code '||
		   ' from iex_strategies s, iex_delinquencies_all d  '||
                   /* begin add for bug 4408860 - add checking CLOSE status from case delinquency */
                   ' where (d.status = ''' || l_DelStatusCurrent || ''' or d.status = ''' || l_DelStatusClose || ''') and '||
                   /* end add for bug 4408860 - add checking CLOSE status from case delinquency */
                ' s.strategy_level = ' || l_DefaultStrategyLevel || ' and '||
                ' s.jtf_object_id =  d.delinquency_id and '||
                ' s.status_code IN (''' || l_StratStatusOpen || ''' , ''' || l_StratStatusOnhold || ''' , ''' || l_StratStatusPending || ''') ';
		if l_org_enabled = 'Y' then
			vPLSQL := vPLSQL || ' and nvl(s.org_id,-99) = decode(''' || l_org_enabled || ''',''Y'',' || l_org_id ||',nvl(s.org_id,-99)) ';
		end if;
		if l_custom_select IS NOT NULL then
		vPLSQL := vPLSQL || ' and exists ( ' || l_custom_select || ' = s.delinquency_id)'; --Bug# 6870773 Naveen
		end if;
      END IF;
      --End adding for bug 8756947 gnramasa 3rd Aug 09

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        write_log(FND_LOG.LEVEL_PROCEDURE, 'Close Strategies vPLSQL :' || vPLSQL);
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Close Strategies vPLSQL :' || vPLSQL);

      OPEN c_open_strategies FOR vPLSQL;

    -- FOR f_strategy_rec in  C_Open_strategies loop
     LOOP
      FETCH c_open_strategies INTO l_strategy_id, l_Strategy_template_id, vStrategyStatus ;
      if c_open_strategies%FOUND then


        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy ID ' ||  l_strategy_id
               || ' Strategy Status ' || vStrategyStatus
               || ' Strategy Template ID ' || l_strategy_template_id );

        write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Status ' || vStrategyStatus );
        end if;

	if p_strategy_mode = 'FINAL' then
		l_itemtype := 'IEXSTRY';
		l_itemkey := to_char(l_strategy_id);

		BEGIN
		    IEX_STRATEGY_WF.Send_Signal(
			   process => l_itemtype,
		       strategy_id => l_itemkey,
		       status => l_StratStatusClosed
		    );

		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    write_log(FND_LOG.LEVEL_PROCEDURE, 'Strategy Closed. id = ' || l_strategy_id);
		    end if;

		EXCEPTION
		    WHEN OTHERS THEN
			   fnd_file.put_line(FND_FILE.LOG, 'Strategy Closed Rised Exception = '
				    ||  l_strategy_id || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
		    retcode := '2';
		END;
	end if; --if p_strategy_mode = 'FINAL' then

	--Call gen_xml_body_strategy to insert this record to xml body
	gen_xml_body_strategy (p_strategy_id        => l_strategy_id,
			   p_strategy_status    => 'CLOSE');

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        write_log(FND_LOG.LEVEL_STATEMENT, 'Close Strategy cursor ends' );
        end if;
      ELSE  -- fetch failed, so exit loop
           EXIT;
      end if;
     END loop;
     write_log(FND_LOG.LEVEL_STATEMENT, 'Close Strategy cursor EXIT ');
     close c_open_strategies;
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG, 'Close Strategy raised exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
       close c_open_strategies;

END close_strategies;


--Begin Bug#7248296 28-07-2008 barathsr
PROCEDURE PROCESS_ONHOLD_STRATEGIES (p_strategy_mode  IN   VARCHAR2)
   IS
	TYPE c_onhold_strategiesCurTyp IS REF CURSOR;
        c_onhold_strategies c_onhold_strategiesCurTyp;

        vPLSQL	   VARCHAR2(5000);
/*
	cursor c_party_onhold_st is
	select s.strategy_id strategy_id,
	s.strategy_template_id strategy_template_id,
	S.STATUS_CODE STATUS_CODE,
	d.party_cust_id party_id
	from iex_strategies s, iex_delinquencies_all d
	where s.strategy_level = 10 and
	s.status_code = 'ONHOLD' and
	d.status in ('DELINQUENT','PREDELINQUENT') and
	d.party_cust_id = s.party_id and
	not exists (select 1 from iex_promise_details p
	where p.status='COLLECTABLE'
	AND d.delinquency_id=p.delinquency_id)
	and nvl(s.org_id,-99) = decode(l_org_enabled,'Y',l_org_id,nvl(s.org_id,-99))
	--and exists ( l_custom_select = s.party_id)
	group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE,d.party_cust_id;

	cursor c_account_onhold_st is
	select s.strategy_id strategy_id,
	s.strategy_template_id strategy_template_id,
	S.STATUS_CODE STATUS_CODE,
	d.cust_account_id cust_account_id
	from iex_strategies s, iex_delinquencies_all d
	where s.strategy_level = 20 and
	s.status_code = 'ONHOLD' and
	d.status in ('DELINQUENT','PREDELINQUENT') and
	d.CUST_ACCOUNT_id = s.CUST_ACCOUNT_id and
	not exists (select 1 from iex_promise_details p
	where p.status='COLLECTABLE'
	AND d.delinquency_id=p.delinquency_id)
	and nvl(s.org_id,-99) = decode(l_org_enabled,'Y',l_org_id,nvl(s.org_id,-99))
	--and exists ( l_custom_select = s.cust_Account_id)
	group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE,d.cust_account_id;

	cursor c_billto_onhold_st is
	select s.strategy_id strategy_id,
	s.strategy_template_id strategy_template_id,
	S.STATUS_CODE STATUS_CODE,
	d.customer_site_use_id billto_id
	from iex_strategies s, iex_delinquencies_all d
	where s.strategy_level = 30 and
	s.status_code = 'ONHOLD' and
	d.status in ('DELINQUENT','PREDELINQUENT') and
	d.customer_site_use_id = s.customer_site_use_id and
	not exists (select 1 from iex_promise_details p
	where p.status='COLLECTABLE'
	AND d.delinquency_id=p.delinquency_id)
	and nvl(s.org_id,-99) = decode(l_org_enabled,'Y',l_org_id,nvl(s.org_id,-99))
	--and exists ( l_custom_select = s.customer_site_use_id)
	group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE,d.customer_site_use_id;
*/
 --	l_DefaultStrategyLevel number;  -- commented for bug 8708271 multi level strategy
 --	l_StrategyLevelName varchar2(30); -- commented for bug 8708271 multi level strategy

	l_return_status			varchar2(10);
	l_msg_count			number;
	l_msg_data			varchar2(200);
	l_strategy_id                   number;
	l_strategy_template_id          number;
	l_status_code                   varchar2(50);
	l_party_id                      number;
	l_cust_account_id               number;
	l_cust_site_use_id              number;


begin

/*	select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  50),preference_value
	into l_DefaultStrategyLevel,l_StrategyLevelName
        from iex_app_preferences_vl
        where  preference_name = 'COLLECTIONS STRATEGY LEVEL' and enabled_flag = 'Y'; */

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           write_log(FND_LOG.LEVEL_STATEMENT, ' Strategy level is: ' || l_DefaultStrategyLevel);
        END IF;

	if l_DefaultStrategyLevel = 10 then
		vPLSQL := 'select s.strategy_id strategy_id, '||
			' s.strategy_template_id strategy_template_id,  '||
			' S.STATUS_CODE STATUS_CODE, '||
			' d.party_cust_id party_id '||
			' from iex_strategies s, iex_delinquencies_all d '||
			' where s.strategy_level = 10 and '||
			' s.status_code = ''ONHOLD'' and '||
			' d.status in (''DELINQUENT'',''PREDELINQUENT'') and '||
			' d.party_cust_id = s.party_id and  '||
			' not exists (select 1 from iex_promise_details p  '||
			' where p.status=''COLLECTABLE''  '||
			' AND d.delinquency_id=p.delinquency_id) ';
			--Start adding for bug 8756947 gnramasa 3rd Aug 09
			if l_org_enabled = 'Y' then
				vPLSQL := vPLSQL || ' and nvl(s.org_id,-99) = decode(''' || l_org_enabled || ''',''Y'',' || l_org_id ||',nvl(s.org_id,-99)) ';
			end if;
			if l_custom_select IS NOT NULL then
			vPLSQL := vPLSQL || ' and exists ( ' || l_custom_select || '= s.party_id) ';
			end if;
			vPLSQL := vPLSQL || ' group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE,d.party_cust_id';

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			write_log(FND_LOG.LEVEL_PROCEDURE, 'ON-HOLD vPLSQL :' || vPLSQL);
		END IF;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'ON-HOLD vPLSQL :' || vPLSQL);

		open c_onhold_strategies for vPLSQL;
		loop
		fetch c_onhold_strategies into l_strategy_id, l_strategy_template_id, l_status_code, l_party_id;
		if c_onhold_strategies%FOUND then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				 write_log(FND_LOG.LEVEL_UNEXPECTED, 'Update strategy for party id : = ' || l_party_id);
			END IF;

			if p_strategy_mode = 'FINAL' then
				iex_strategy_pub.set_strategy(
					P_Api_Version_Number         => 2.0,
					P_Init_Msg_List              => 'F',
					P_Commit                     => 'F',
					p_validation_level           => null,
					X_Return_Status              => l_return_status,
					X_Msg_Count                  => l_msg_count,
					X_Msg_Data                   => l_msg_data,
					p_DelinquencyID              => null,
					p_ObjectType                 => 'PARTY',
					p_ObjectID                   => l_party_id,
					p_Status                     => 'OPEN');
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
					 write_log(FND_LOG.LEVEL_PROCEDURE, 'Return status = ' || l_return_status);
					 write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy updated. id = ' || l_strategy_id);
				END IF;
			end if;  --if p_strategy_mode = 'FINAL' then

			--Call gen_xml_body_strategy to insert this record to xml body
			gen_xml_body_strategy (p_strategy_id        => l_strategy_id,
			                       p_strategy_status    => 'REOPEN');
		ELSE  -- fetch failed, so exit loop
			EXIT;
		end if;
		end loop;
		close c_onhold_strategies;
		write_log(FND_LOG.LEVEL_STATEMENT, 'ONHOLD Strategy cursor EXIT ');

	elsif l_DefaultStrategyLevel = 20 then
		vPLSQL := 'select s.strategy_id strategy_id, '||
			' s.strategy_template_id strategy_template_id, '||
			' S.STATUS_CODE STATUS_CODE, '||
			' d.cust_account_id cust_account_id '||
			' from iex_strategies s, iex_delinquencies_all d '||
			' where s.strategy_level = 20 and '||
			' s.status_code = ''ONHOLD'' and '||
			' d.status in (''DELINQUENT'',''PREDELINQUENT'') and '||
			' d.CUST_ACCOUNT_id = s.CUST_ACCOUNT_id and  '||
			' not exists (select 1 from iex_promise_details p  '||
			' where p.status=''COLLECTABLE'' '||
			' AND d.delinquency_id=p.delinquency_id) ';
			if l_org_enabled = 'Y' then
				vPLSQL := vPLSQL || ' and nvl(s.org_id,-99) = decode(''' || l_org_enabled || ''',''Y'',' || l_org_id ||' ,nvl(s.org_id,-99)) ';
			end if;
			if l_custom_select IS NOT NULL then
				vPLSQL := vPLSQL || ' and exists ( ' || l_custom_select || ' = s.cust_Account_id) ';
			end if;
			vPLSQL := vPLSQL || ' group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE,d.cust_account_id';

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			write_log(FND_LOG.LEVEL_PROCEDURE, 'ON-HOLD vPLSQL :' || vPLSQL);
		END IF;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'ON-HOLD vPLSQL :' || vPLSQL);

		open c_onhold_strategies for vPLSQL;
		loop
		fetch c_onhold_strategies into l_strategy_id, l_strategy_template_id, l_status_code, l_cust_account_id;
		if c_onhold_strategies%FOUND then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				 write_log(FND_LOG.LEVEL_UNEXPECTED, 'Update strategy for account id: = ' || l_cust_account_id);
			END IF;

			if p_strategy_mode = 'FINAL' then
				iex_strategy_pub.set_strategy(
					P_Api_Version_Number         => 2.0,
					P_Init_Msg_List              => 'F',
					P_Commit                     => 'F',
					p_validation_level           => null,
					X_Return_Status              => l_return_status,
					X_Msg_Count                  => l_msg_count,
					X_Msg_Data                   => l_msg_data,
					p_DelinquencyID              => null,
					p_ObjectType                 => 'ACCOUNT',
					p_ObjectID                   => l_cust_account_id,
					p_Status                     => 'OPEN');
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
					 write_log(FND_LOG.LEVEL_PROCEDURE, 'Return status = ' || l_return_status);
					 write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy updated. id = ' || l_strategy_id);
				END IF;
			end if;  --if p_strategy_mode = 'FINAL' then

			--Call gen_xml_body_strategy to insert this record to xml body
			gen_xml_body_strategy (p_strategy_id        => l_strategy_id,
			                       p_strategy_status    => 'REOPEN');
		ELSE  -- fetch failed, so exit loop
			EXIT;
		end if;
		end loop;
		close c_onhold_strategies;
		write_log(FND_LOG.LEVEL_STATEMENT, 'ONHOLD Strategy cursor EXIT ');

	elsif l_DefaultStrategyLevel = 30 then
		vPLSQL := 'select s.strategy_id strategy_id, '||
			' s.strategy_template_id strategy_template_id,  '||
			' S.STATUS_CODE STATUS_CODE, '||
			' d.customer_site_use_id billto_id '||
			' from iex_strategies s, iex_delinquencies_all d '||
			' where s.strategy_level = 30 and '||
			' s.status_code = ''ONHOLD'' and '||
			' d.status in (''DELINQUENT'',''PREDELINQUENT'') and '||
			' d.customer_site_use_id = s.customer_site_use_id and  '||
			' not exists (select 1 from iex_promise_details p  '||
			' where p.status=''COLLECTABLE''  '||
			' AND d.delinquency_id=p.delinquency_id) ';
			if l_org_enabled = 'Y' then
				vPLSQL := vPLSQL || ' and nvl(s.org_id,-99) = decode( ''' || l_org_enabled ||''',''Y'',' || l_org_id ||',nvl(s.org_id,-99)) ';
			end if;
			if l_custom_select IS NOT NULL then
				vPLSQL := vPLSQL || ' and exists ( ' || l_custom_select || '= s.customer_site_use_id) ';
			end if;
			--End adding for bug 8756947 gnramasa 3rd Aug 09
			vPLSQL := vPLSQL || ' group by s.strategy_id, s.strategy_template_id, S.STATUS_CODE,d.customer_site_use_id';

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			write_log(FND_LOG.LEVEL_PROCEDURE, 'ON-HOLD vPLSQL :' || vPLSQL);
		END IF;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'ON-HOLD vPLSQL :' || vPLSQL);

		open c_onhold_strategies for vPLSQL;
		loop
		fetch c_onhold_strategies into l_strategy_id, l_strategy_template_id, l_status_code, l_cust_site_use_id;
		if c_onhold_strategies%FOUND then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				 write_log(FND_LOG.LEVEL_UNEXPECTED, 'Update strategy for customer site use id : = ' || l_cust_site_use_id);
			END IF;

			if p_strategy_mode = 'FINAL' then
				iex_strategy_pub.set_strategy(
					P_Api_Version_Number         => 2.0,
					P_Init_Msg_List              => 'F',
					P_Commit                     => 'F',
					p_validation_level           => null,
					X_Return_Status              => l_return_status,
					X_Msg_Count                  => l_msg_count,
					X_Msg_Data                   => l_msg_data,
					p_DelinquencyID              => null,
					p_ObjectType                 => 'BILL_TO',
					p_ObjectID                   => l_cust_site_use_id,
					p_Status                     => 'OPEN');
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
					 write_log(FND_LOG.LEVEL_PROCEDURE, 'Return status = ' || l_return_status);
					 write_log(FND_LOG.LEVEL_UNEXPECTED, 'Strategy updated. id = ' || l_strategy_id);
				END IF;
			end if; --if p_strategy_mode = 'FINAL' then

			--Call gen_xml_body_strategy to insert this record to xml body
			gen_xml_body_strategy (p_strategy_id        => l_strategy_id,
			                       p_strategy_status    => 'REOPEN');
		ELSE  -- fetch failed, so exit loop
			EXIT;
		end if;
		end loop;
		close c_onhold_strategies;
		write_log(FND_LOG.LEVEL_STATEMENT, 'ONHOLD Strategy cursor EXIT ');
	else
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			write_log(FND_LOG.LEVEL_STATEMENT, ' Strategy level is: ' || l_DefaultStrategyLevel || ', no need to update the strategy');
		END IF;
	end if;
EXCEPTION
    when others then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		write_log(FND_LOG.LEVEL_STATEMENT, ' In PROCESS_ONHOLD_STRATEGIES when others exception');
	END IF;
END PROCESS_ONHOLD_STRATEGIES;
--End Bug#7248296 28-07-2008 barathsr
--End by gnramasa for bug 8630852 13-July-09

PROCEDURE GetStrategyTempID(
		p_stry_cnt_rec in	IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE,
		x_return_status out NOCOPY varchar2,
		x_strategy_template_id out NOCOPY number) IS
/*
    CURSOR c_strategyTemp(pCategoryType varchar2, pDelinquencyID number) IS
       SELECT ST.strategy_temp_id, ST.strategy_rank, OBF.ENTITY_NAME
            from  IEX_STRATEGY_TEMPLATES_B ST, IEX_OBJECT_FILTERS OBF
            where ST.category_type = pCategoryType and ST.Check_List_YN = 'N' AND
                 OBF.OBJECT_ID(+) = ST.Strategy_temp_Group_ID and
                 OBF.OBJECT_FILTER_TYPE(+) = 'IEXSTRAT'
               and not exists
                 (select 'x' from iex_strategies SS where SS.delinquency_id = pDelinquencyID
                       and SS.OBJECT_TYPE = pCategoryType)
            ORDER BY strategy_rank DESC;
*/
    C_DynSql varchar2(1000);
    v_Exists varchar2(20);
    v_SkipTemp varchar2(20);

    l_StrategyTempID number := 0;
    TYPE c_strategyTempCurTyp IS REF CURSOR;  -- weak
    c_strategyTemp c_strategyTempCurTyp;  -- declare cursor variable
    c_rec_Strategy_temp_id NUMBER;
    c_Rec_Strategy_Rank varchar2(10);
    c_Rec_ENTITY_NAME varchar2(30);
    c_Rec_active_flag varchar2(1);

    -- clchang updated for sql bind var 05/07/2003
    vstr1   varchar2(100) ;
    vstr2   varchar2(100) ;
    vstr3   varchar2(100) ;
    vstr4   varchar2(100) ;
    vstr5   varchar2(100) ;
    vstr6   varchar2(100) ;

    /* ctlee - add status and pass it to GetTemplateId by stry_rec 7/3/2003 */
    chk_obj_type varchar2(30);
BEGIN

    --  initialize variables
    vstr1   := ' select 1 from ' ;
    vstr2   := ' where delinquency_id  = :DelId ' ;
    vstr3   := ' and rownum < 2 ';
    vstr4   := ' where CUST_ACCOUNT_id  = :AcctId ';
    vstr5   := ' where party_id  = :PartyId ';
    vstr6   := ' where customer_site_use_id  = :CustomerSiteUseId ';

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    write_log(FND_LOG.LEVEL_STATEMENT, 'GetStrategyTempID: Object_Type = '
      || p_stry_cnt_rec.object_type || ' Delinquency ID = ' || p_stry_cnt_rec.delinquency_id
      || ' Strategy Level ' || l_DefaultStrategyLevel  || ' Score  ' || p_stry_cnt_rec.score_value
      || ' Party ID ' || p_stry_cnt_rec.party_cust_id || ' Account ID ' || p_stry_cnt_rec.cust_account_id
      || ' CUSTOMER_SITE_USE ID ' || p_stry_cnt_rec.customer_site_use_id );
    end if;

    x_Strategy_Template_id := l_DefaultTempID;


    /* ctlee - add status and pass it to GetTemplateId by stry_rec 7/3/2003 */
    /* C_StrategyTemp using chk_obj_type when strategy level = 30 */
    /* comment out to check if existing pre-delinquent strategy template for all 4 levels
       - filter when open_strategies()  => always use the default one if not found
       03/05/2004 ctlee
    */
    chk_obj_type := p_stry_cnt_rec.object_type;
    if (p_stry_cnt_rec.object_type = 'DELINQUENT') then
         if (p_stry_cnt_rec.status = 'PREDELINQUENT') then
            chk_obj_type :=  p_stry_cnt_rec.status;
         end if;
    end if;
    /*
    if (p_stry_cnt_rec.object_type = 'DELINQUENT') then
         chk_obj_type :=  p_stry_cnt_rec.status;
         if (chk_obj_type = 'PREDELINQUENT') then
            x_strategy_template_id :=  -1;
         end if;
    end if;
    */

        -- bug 4141678 begin  - ctlee
        --  add checking on existing iex_strategy_work_temp_xref, at least one wi required
        -- bug 4141678 end  - ctlee

      IF l_DefaultStrategyLevel = 10 or l_DefaultStrategyLevel = 20 or l_DefaultStrategyLevel = 30 THEN
         OPEN c_strategyTemp
          FOR SELECT ST.strategy_temp_id, to_number(ST.strategy_rank), OBF.ENTITY_NAME, obf.active_flag
            from  IEX_STRATEGY_TEMPLATES_B ST, IEX_OBJECT_FILTERS OBF
            where ST.Check_List_YN = l_No AND
                ((ST.ENABLED_FLAG IS NULL) or ST.ENABLED_FLAG <> l_No) and
                 st.strategy_level = l_DefaultStrategyLevel and
                 OBF.OBJECT_ID(+) = ST.Strategy_temp_Group_ID and
                 OBF.OBJECT_FILTER_TYPE(+) = l_StratObjectFilterType
                 and (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(st.valid_from_dt, SYSDATE))
                      AND TRUNC(NVL(st.valid_to_dt, SYSDATE)))
                 and exists (select 1 from IEX_STRATEGY_WORK_TEMP_XREF strx
                          where strx.strategy_temp_id = st.strategy_temp_id)
  	         -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
                 and ST.STRATEGY_RANK <= p_stry_cnt_rec.SCORE_VALUE
                 -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
                  -- Bug 7392752 by Ehuh
                 and exists (select 1 from iex_strategy_template_groups tg
                          where tg.group_id = st.strategy_temp_group_id
                            and tg.enabled_flag <> 'N'
                            and trunc(sysdate) between trunc(nvl(tg.valid_from_dt,sysdate))
                                                   and trunc(nvl(tg.valid_to_dt,sysdate))  )
		and category_type in ('DELINQUENT','PREDELINQUENT')  -- added for bug#7709114 by PNAVEENK on 22-1-2009
            ORDER BY to_number(strategy_rank) DESC;
      ELSE
         OPEN c_strategyTemp
          FOR SELECT ST.strategy_temp_id, to_number(ST.strategy_rank), OBF.ENTITY_NAME, obf.active_flag
            from  IEX_STRATEGY_TEMPLATES_B ST, IEX_OBJECT_FILTERS OBF
            where ST.category_type = chk_obj_type and ST.Check_List_YN = l_No AND
                ((ST.ENABLED_FLAG IS NULL) or ST.ENABLED_FLAG <> l_No) and
                 st.strategy_level = l_DefaultStrategyLevel and
                 OBF.OBJECT_ID(+) = ST.Strategy_temp_Group_ID and
                 OBF.OBJECT_FILTER_TYPE(+) = l_StratObjectFilterType
                 and (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(st.valid_from_dt, SYSDATE))
                      AND TRUNC(NVL(st.valid_to_dt, SYSDATE)))
                 and exists (select 1 from IEX_STRATEGY_WORK_TEMP_XREF strx
                               where strx.strategy_temp_id = st.strategy_temp_id)
                 -- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
                 and ST.STRATEGY_RANK <= p_stry_cnt_rec.SCORE_VALUE
                 -- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
                  -- Bug 7392752 by Ehuh
                 and exists (select 1 from iex_strategy_template_groups tg
                          where tg.group_id = st.strategy_temp_group_id
                            and tg.enabled_flag <> 'N'
                            and trunc(sysdate) between trunc(nvl(tg.valid_from_dt,sysdate))
                                                   and trunc(nvl(tg.valid_to_dt,sysdate))  )
            ORDER BY to_number(strategy_rank) DESC;
      END IF;


    /* Get the Strategy Template for requested Category Type */
      LOOP
        FETCH C_StrategyTemp INTO c_rec_Strategy_temp_id, c_Rec_Strategy_Rank, c_Rec_ENTITY_NAME, c_rec_active_flag ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        write_log(FND_LOG.LEVEL_STATEMENT,
                 '  Get Strategy Template: Inside Cursor. Entity Name  '
                 || c_Rec_Entity_Name
                 || ' Temp ' || c_rec_Strategy_temp_id
                 || ' c_rec_active_flag ' || c_rec_active_flag
                 || ' Rank ' || c_Rec_Strategy_Rank);
        end if;

        if C_StrategyTemp%FOUND then
           v_SkipTemp := 'F';
           if c_Rec_Entity_Name is not null and c_rec_active_flag <> 'N' then
           BEGIN
             IF l_DefaultStrategyLevel = 40 THEN
               -- clchang updated for sql bind var 05/07/2003
               C_DynSql  := vstr1 || c_Rec_ENTITY_NAME ||
                            vstr2 ||
                            vstr3;
               Execute Immediate c_DynSql into v_Exists using p_stry_cnt_rec.delinquency_id;
               /*
               C_DynSql  :=
           	    ' select 1 from ' || c_Rec_ENTITY_NAME ||
                ' where delinquency_id  = ' || p_stry_cnt_rec.delinquency_id  ||
                ' and rownum < 2 ';
               */

              elsif l_DefaultStrategyLevel = 30 THEN
               C_DynSql  := vstr1 || c_Rec_ENTITY_NAME ||
              	            vstr6 ||
                            vstr3;
               Execute Immediate c_DynSql into v_Exists using p_stry_cnt_rec.customer_site_use_id;
             elsif l_DefaultStrategyLevel = 20 THEN
               -- clchang updated for sql bind var 05/07/2003
               C_DynSql  := vstr1 || c_Rec_ENTITY_NAME ||
              	            vstr4 ||
                            vstr3;
               Execute Immediate c_DynSql into v_Exists using p_stry_cnt_rec.cust_account_id;
               /*
               C_DynSql  :=
           	    ' select 1 from ' || c_Rec_ENTITY_NAME ||
              	' where CUST_ACCOUNT_id  = ' || p_stry_cnt_rec.CUST_ACCOUNT_id  ||
                ' and rownum < 2 ';
               */
             else
               -- clchang updated for sql bind var 05/07/2003
               C_DynSql  := vstr1 || c_Rec_ENTITY_NAME ||
              	            vstr5 ||
                            vstr3;
               Execute Immediate c_DynSql into v_Exists using p_stry_cnt_rec.party_cust_id;
               /*
               C_DynSql  :=
           	    ' select 1 from ' || c_Rec_ENTITY_NAME ||
                ' where party_id  = ' || p_stry_cnt_rec.PARTY_CUST_ID  ||
                ' and rownum < 2 ';
               */
             end if;

             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             write_log(FND_LOG.LEVEL_STATEMENT, ' Dynamic SQL in GetStrategyTemplate '
                          || c_DynSql );
             end if;

             --Execute Immediate c_DynSql into v_Exists;

           EXCEPTION
             When no_data_found then
            --   fnd_file.put_line(FND_FILE.LOG, ' Get Strategy Template: When No Data Found: ' || c_DynSql  );
              write_log(FND_LOG.LEVEL_STATEMENT, '  Get Strategy Template: When No Data Found: ' || c_DynSql ); -- changed for bug 9039794
	       v_SkipTemp := 'T';
             When Others then
             --  fnd_file.put_line(FND_FILE.LOG, ' Get Strategy Template: When Others: ' || c_DynSql  );
	      write_log(FND_LOG.LEVEL_STATEMENT, ' Get Strategy Template: When Others: ' || c_DynSql ); -- changed for bug 9039794
               v_SkipTemp := 'T';
           END;
           end if;

           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           write_log(FND_LOG.LEVEL_STATEMENT, ' Get Strategy Template: ' || c_Rec_Strategy_Temp_id ||
                                ' Skip Flag ' ||  v_SkipTemp );
           end if;

           if v_SkipTemp <> 'T' then

             if p_stry_cnt_rec.score_value >= C_Rec_Strategy_Rank then
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               write_log(FND_LOG.LEVEL_STATEMENT, ' Found Template: ' || c_Rec_Strategy_Temp_id );
               end if;
               x_strategy_template_id := c_rec_Strategy_temp_id;
               return;
             end if;
           end if;
         ELSE  -- fetch failed, so exit loop
           EXIT;
        end if;
    end loop;
    close C_StrategyTemp;
EXCEPTION
    when others then
        close C_StrategyTemp;
END;


-- apply to one default strategy only because the SA would set to one level only
-- thus it will apply to the same level of the default strategy template too
FUNCTION GetDefaultStrategyTempID return NUMBER IS
    l_StrategyTempID number;
    lCursorStrategyTempID number;
    Cursor C_getFirstTempID IS
        Select st.Strategy_Temp_ID FROM IEX_STRATEGY_TEMPLATES_B  st where
            st.Check_List_YN = l_No AND st.ENABLED_FLAG <> l_No
            -- Bug 7392752 by Ehuh
                 and (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(st.valid_from_dt, SYSDATE)) AND TRUNC(NVL(st.valid_to_dt, SYSDATE)))
                 and exists (select 1 from iex_strategy_template_groups tg
                          where tg.group_id = st.strategy_temp_group_id
                            and tg.enabled_flag <> 'N'
                            and trunc(sysdate) between trunc(nvl(tg.valid_from_dt,sysdate))
                                                   and trunc(nvl(tg.valid_to_dt,sysdate))  );
BEGIN
    l_StrategyTempID := NVL(to_number(FND_PROFILE.VALUE('IEX_STRATEGY_DEFAULT_TEMPLATE')), 0);
    if (l_StrategyTempID = 0) Then
        Open C_getFirstTempID;
        fetch C_getFirstTempID into lCursorStrategyTempID;
        if C_getFirstTempID%FOUND then
            l_StrategyTempID := lCursorStrategyTempID;
        end if;
        Close C_getFirstTempID;
    end if;
    return l_StrategyTempID;
END;


-- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
--PROCEDURE MAIN (
--		ERRBUF      OUT NOCOPY     VARCHAR2,
--		RETCODE     OUT NOCOPY     VARCHAR2,
--                p_trace_mode          IN  VARCHAR2)
PROCEDURE MAIN
(
		ERRBUF                  OUT NOCOPY     VARCHAR2,
		RETCODE     	        OUT NOCOPY     VARCHAR2,
                -- p_trace_mode    IN  	       VARCHAR2, Bug5022607. Fix By LKKUMAR. Removed this parameter.
                p_org_id                IN   number,
		p_ignore_switch	        IN   VARCHAR2,
		p_strategy_mode         IN   VARCHAR2 DEFAULT 'FINAL',  -- added by gnramasa for bug 8630852 13-July-09
		p_coll_bus_level_dummy  IN   VARCHAR2,                  -- added by gnramasa for bug 8630852 13-July-09
		p_customer_name_low     IN   VARCHAR2,                  -- added by gnramasa for bug 8630852 13-July-09
		p_customer_name_high    IN   VARCHAR2,                  -- added by gnramasa for bug 8630852 13-July-09
		p_account_number_low    IN   VARCHAR2,                  -- added by gnramasa for bug 8630852 13-July-09
		p_account_number_high   IN   VARCHAR2,                  -- added by gnramasa for bug 8630852 13-July-09
		p_billto_location_dummy IN   VARCHAR2,                  -- added by gnramasa for bug 8630852 13-July-09
		p_billto_location_low   IN   VARCHAR2,                  -- added by gnramasa for bug 8630852 13-July-09
		p_billto_location_high  IN   VARCHAR2			-- added by gnramasa for bug 8630852 13-July-09
)
-- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
--Bug# 6870773 Naveen
IS

l_count        number;
l_api_name     VARCHAR2(100) ;
CURSOR c_org IS
    SELECT organization_id from hr_operating_units where
      mo_global.check_access(organization_id) = 'Y'
      AND organization_id = nvl(P_ORG_ID,organization_id);

-- Start for bug 8708271 multi level strategy

CURSOR c_str_levels IS
SELECT lookup_code FROM IEX_LOOKUPS_V
WHERE LOOKUP_TYPE='IEX_RUNNING_LEVEL'
AND iex_utilities.validate_running_level(LOOKUP_CODE)='Y';

CURSOR c_system_str_level(p_org_id number) IS
select preference_value
from iex_app_preferences_b
where preference_name='COLLECTIONS STRATEGY LEVEL'
and enabled_flag='Y'
and (org_id = p_org_id or org_id is null)
order by nvl(org_id,0) desc;

CURSOR c_system_strategy_level IS
select preference_value
from iex_app_preferences_b
where preference_name='COLLECTIONS STRATEGY LEVEL'
and enabled_flag='Y'
and org_id is null;

-- End for bug 8708271 multi level strategy

BEGIN
	--Start adding for bug 8630852 by gnramasa 13-July-09
	l_api_name  := 'Main ';
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'STRATEGYMODE                : ' || p_strategy_mode);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'CUSTOMER NAME LOW           : ' || p_customer_name_low);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'CUSTOMER NAME HIGH          : ' || p_customer_name_high);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACCOUNT NUMBER LOW		: ' || p_account_number_low);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACCOUNT NUMBER HIGH		: ' || p_account_number_high);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'BILLTO LOCATION LOW		: ' || p_billto_location_low);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'BILLTO LOCATION HIGH	: ' || p_billto_location_high);

	writelog(G_PKG_NAME || ' ' || l_api_name || ' - strategy mode			:' || p_strategy_mode);
	writelog(G_PKG_NAME || ' ' || l_api_name || ' - p_customer_name_low		:' || p_customer_name_low);
	writelog(G_PKG_NAME || ' ' || l_api_name || ' - p_customer_name_high		:' || p_customer_name_high);
	writelog(G_PKG_NAME || ' ' || l_api_name || ' - p_account_number_low		:' || p_account_number_low);
	writelog(G_PKG_NAME || ' ' || l_api_name || ' - p_account_number_high	:' || p_account_number_high);
	writelog(G_PKG_NAME || ' ' || l_api_name || ' - p_billto_location_low	:' || p_billto_location_low);
	writelog(G_PKG_NAME || ' ' || l_api_name || ' - p_billto_location_high	:' || p_billto_location_high);

	/*
	if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
	    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
		writelog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
		--Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
		    custom_where_clause
			   (p_customer_name_low       => p_customer_name_low,
			    p_customer_name_high      => p_customer_name_high,
			    p_account_number_low      => p_account_number_low,
			    p_account_number_high     => p_account_number_high,
			    p_billto_location_low     => p_billto_location_low,
			    p_billto_location_high    => p_billto_location_high);

		writelog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
	end if;
	*/

	--End adding for bug 8630852 by gnramasa 13-July-09

     --Bug5022607. Fix By LKKUMAR. Remove p_trace_mode parameter. Start.
     --  IF p_trace_mode = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'Value of profile IEX: Debug Level is : '|| PG_DEBUG);
      IF PG_DEBUG  = 1 THEN
       fnd_file.put_line(FND_FILE.LOG, ' Enabling the trace');
       dbms_session.set_sql_trace(TRUE);
       ELSE
        fnd_file.put_line(FND_FILE.LOG,' Trace not enabled');
        dbms_session.set_sql_trace(FALSE);
       END IF;
--Bug# 6870773 Naveen
	l_org_enabled := nvl(fnd_profile.value('IEX_PROC_STR_ORG'),'N');
      -- l_org_id := fnd_profile.value('ORG_ID');
       l_org_id:=p_org_id;

       --call gen_xml_header_data_strategy to generate the xml header data
       gen_xml_header_data_strategy (p_strategy_mode   => p_strategy_mode);
       fnd_file.put_line(FND_FILE.LOG, 'Update Multi Level Strategy Setup in Questionnaire table');
       writelog(' Update Multi Level Strategy Setup in Questionnaire table');
       IEX_CHECKLIST_UTILITY.UPDATE_MLSETUP;
       writelog(' End update Multi Level Setup in Questionnaire table');
       if l_org_enabled = 'Y' then
		fnd_file.put_line(FND_FILE.LOG, 'Profile for processing strategies by operating unit is On ' || ' Org Id = ' || l_org_id);

		select count(1)
		into l_count
		from iex_strategies
		where org_id is null
		and strategy_level=l_DefaultStrategyLevel;

		if l_count>0 then
			fnd_file.put_line(FND_FILE.LOG, 'Found '||l_count||' strategies without having org_id.');
			fnd_file.put_line(FND_FILE.LOG, 'Please run the script iexstorg.sql before running this concurrent program.');
			return;
		end if;
		fnd_file.put_line(FND_FILE.LOG, ' Party Level Strategy Override value ' || l_party_override );
                fnd_file.put_line(FND_FILE.LOG, ' Operating Unit Level Strategy Override value ' || l_org_override);
		 MO_GLOBAL.INIT('IEX');
		 IF P_ORG_ID IS NOT NULL THEN
			 MO_GLOBAL.SET_POLICY_CONTEXT('S',P_ORG_ID);  -- Single Org.
			 FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || p_org_id);
		 ELSE
			MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);      -- Multi Org.
			 FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || 'All');
		 END IF;
		  FOR I_ORG IN C_ORG LOOP   -- Moac Changes. Loop through for Party.
			MO_GLOBAL.SET_POLICY_CONTEXT('S',I_ORG.organization_id); -- Moac Changes. Set Org.
			 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside Party Loop, Operating Unit Set =' ||I_ORG.organization_id);
			 l_org_id:=mo_global.get_current_org_id;
                         -- Start for bug 8708271 multi level strategy

		    if l_org_override ='Y' then
                         fnd_file.put_line(FND_FILE.LOG, 'Operating Unit Level override is on');

                         open c_system_str_level(l_org_id);
			 fetch c_system_str_level into l_system_strategy_level;
                         close c_system_str_level;

			 fnd_file.put_line(FND_FILE.LOG, 'Strategy Level set for Operating Unit' || l_org_id || 'is' || l_system_strategy_level);

			 for l_str_levels in c_str_levels loop

			   l_StrategyLevelName := l_str_levels.lookup_code;

			   select  decode(l_StrategyLevelName, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  50)
		           into l_DefaultStrategyLevel from dual;

			   write_log(FND_LOG.LEVEL_STATEMENT, ' Org_id ' || l_org_id || ' Itearation Level ' || l_DefaultStrategyLevel);

			   if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
			    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
				writelog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
				--Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
				    custom_where_clause
					   (p_customer_name_low       => p_customer_name_low,
					    p_customer_name_high      => p_customer_name_high,
					    p_account_number_low      => p_account_number_low,
					    p_account_number_high     => p_account_number_high,
					    p_billto_location_low     => p_billto_location_low,
					    p_billto_location_high    => p_billto_location_high,
					    p_strategy_level          => l_DefaultStrategyLevel);

				writelog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
			  end if;

			   CLOSE_STRATEGIES(errbuf			=> errbuf,
					    retcode			=> retcode,
					     p_strategy_mode            => p_strategy_mode);


			   PROCESS_ONHOLD_STRATEGIES(p_strategy_mode  => p_strategy_mode);

			   OPEN_STRATEGIES(errbuf			=> errbuf,
					   retcode			=> retcode,
					   p_ignore_switch		=> p_ignore_switch,
					   p_strategy_mode              => p_strategy_mode);

                         end loop;
		    else
		         if l_party_override = 'Y' then

			   open c_system_strategy_level;
			   fetch c_system_strategy_level into l_system_strategy_level;
			   close c_system_strategy_level;

			   fnd_file.put_line(FND_FILE.LOG, 'Operating Unit Level override is off and Party Level override is on');
                           fnd_file.put_line(FND_FILE.LOG, 'System Strategy Level ' ||  l_system_strategy_level);

			   for l_str_levels in c_str_levels loop

			    l_StrategyLevelName := l_str_levels.lookup_code;

			    select  decode(l_StrategyLevelName, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  50)
		            into l_DefaultStrategyLevel from dual;

			    write_log(FND_LOG.LEVEL_STATEMENT, ' Org_id ' || l_org_id || ' Itearation Level ' || l_DefaultStrategyLevel);

			    if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
			    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
				writelog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
				--Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
				    custom_where_clause
					   (p_customer_name_low       => p_customer_name_low,
					    p_customer_name_high      => p_customer_name_high,
					    p_account_number_low      => p_account_number_low,
					    p_account_number_high     => p_account_number_high,
					    p_billto_location_low     => p_billto_location_low,
					    p_billto_location_high    => p_billto_location_high,
					    p_strategy_level          => l_DefaultStrategyLevel);

				writelog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
			  end if;

			    CLOSE_STRATEGIES(errbuf			=> errbuf,
					     retcode			=> retcode,
					     p_strategy_mode            => p_strategy_mode);


			    PROCESS_ONHOLD_STRATEGIES(p_strategy_mode  => p_strategy_mode);

			    OPEN_STRATEGIES(errbuf			=> errbuf,
					    retcode			=> retcode,
					    p_ignore_switch		=> p_ignore_switch,
					    p_strategy_mode             => p_strategy_mode);

                           end loop;

			 else

			 fnd_file.put_line(FND_FILE.LOG, 'Operating Unit Level override and Party Level override are off');

			 select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  50),preference_value
                         into l_DefaultStrategyLevel,l_StrategyLevelName
                         from iex_app_preferences_b
                         where preference_name='COLLECTIONS STRATEGY LEVEL'
                         and enabled_flag='Y'
			 and org_id is null;

			 l_system_strategy_level := l_StrategyLevelName;

                         write_log(FND_LOG.LEVEL_STATEMENT, ' Running Strategy Level ' || l_DefaultStrategyLevel);
                         write_log(FND_LOG.LEVEL_STATEMENT, ' System Strategy Level ' || l_system_strategy_level);

			 if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
			    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
				writelog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
				--Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
				    custom_where_clause
					   (p_customer_name_low       => p_customer_name_low,
					    p_customer_name_high      => p_customer_name_high,
					    p_account_number_low      => p_account_number_low,
					    p_account_number_high     => p_account_number_high,
					    p_billto_location_low     => p_billto_location_low,
					    p_billto_location_high    => p_billto_location_high,
					    p_strategy_level          => l_DefaultStrategyLevel);

				writelog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
			  end if;

			 CLOSE_STRATEGIES(errbuf		=> errbuf,
					  retcode		=> retcode,
					  p_strategy_mode       => p_strategy_mode);


			 PROCESS_ONHOLD_STRATEGIES (p_strategy_mode       => p_strategy_mode);

			 OPEN_STRATEGIES(errbuf			=> errbuf,
					 retcode		=> retcode,
					 p_ignore_switch	=> p_ignore_switch,
					 p_strategy_mode        => p_strategy_mode);
		         end if;  -- party override
		     end if;  -- org override



		END LOOP;

       else
		fnd_file.put_line(FND_FILE.LOG, 'Profile for processing strategies by operating unit is Off ');
                fnd_file.put_line(FND_FILE.LOG, ' Party Level Strategy Override value ' || l_party_override );
                fnd_file.put_line(FND_FILE.LOG, ' Operating Unit Level Strategy Override value ' || l_org_override);

		select count(1)
		into l_count
		from iex_strategies
		where org_id is not null
		and strategy_level=l_DefaultStrategyLevel;

		if l_count>0 then
			fnd_file.put_line(FND_FILE.LOG, 'Found '||l_count||' strategies with org_id.');
			fnd_file.put_line(FND_FILE.LOG, 'Please run the script iexstorg.sql before running this concurrent program.');
			return;
		end if;
		l_org_id := null;

		if l_org_override = 'Y' then
                        fnd_file.put_line(FND_FILE.LOG, ' Operating unit override is set. So enable profile for processing strategies by opearating');
		        return;
		end if;

	      if l_party_override ='Y' then

		 fnd_file.put_line(FND_FILE.LOG, 'Party Level override is on');

                 open c_system_strategy_level;
	         fetch c_system_strategy_level into l_system_strategy_level;
		 close c_system_strategy_level;

		 write_log(FND_LOG.LEVEL_STATEMENT, ' System Strategy Level' || l_system_strategy_level);
		 for l_str_levels in c_str_levels loop

		  l_StrategyLevelName := l_str_levels.lookup_code;

		  select  decode(l_StrategyLevelName, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  50)
		  into l_DefaultStrategyLevel from dual;

		  write_log(FND_LOG.LEVEL_STATEMENT, ' Running Strategy Level ' || l_DefaultStrategyLevel);
                  write_log(FND_LOG.LEVEL_STATEMENT, ' System Strategy Level ' || l_system_strategy_level);

		  if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
		    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
			writelog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
			--Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
			    custom_where_clause
				   (p_customer_name_low       => p_customer_name_low,
				    p_customer_name_high      => p_customer_name_high,
				    p_account_number_low      => p_account_number_low,
				    p_account_number_high     => p_account_number_high,
				    p_billto_location_low     => p_billto_location_low,
				    p_billto_location_high    => p_billto_location_high,
				    p_strategy_level          => l_DefaultStrategyLevel);

			writelog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
		  end if;

		  CLOSE_STRATEGIES(errbuf		=> errbuf,
				   retcode		=> retcode,
				   p_strategy_mode	=> p_strategy_mode);

		  PROCESS_ONHOLD_STRATEGIES (p_strategy_mode  => p_strategy_mode);

		  OPEN_STRATEGIES( errbuf			=> errbuf,
				   retcode			=> retcode,
				   p_ignore_switch		=> p_ignore_switch,
				   p_strategy_mode              => p_strategy_mode);

		 end loop;
	     else
	        fnd_file.put_line(FND_FILE.LOG, 'Party Level override is off');

		select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  50),preference_value
                into l_DefaultStrategyLevel,l_StrategyLevelName
                from iex_app_preferences_b
                where preference_name='COLLECTIONS STRATEGY LEVEL'
                and enabled_flag='Y'
		and org_id is null;

		l_system_strategy_level := l_StrategyLevelName;

		write_log(FND_LOG.LEVEL_STATEMENT, ' Running Strategy Level ' || l_DefaultStrategyLevel);

		if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
		    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
			writelog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
			--Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
			    custom_where_clause
				   (p_customer_name_low       => p_customer_name_low,
				    p_customer_name_high      => p_customer_name_high,
				    p_account_number_low      => p_account_number_low,
				    p_account_number_high     => p_account_number_high,
				    p_billto_location_low     => p_billto_location_low,
				    p_billto_location_high    => p_billto_location_high,
				    p_strategy_level          => l_DefaultStrategyLevel);

			writelog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
		  end if;

		CLOSE_STRATEGIES(errbuf			=> errbuf,
				 retcode		=> retcode,
				 p_strategy_mode        => p_strategy_mode);

	--Begin Bug#7248296 28-07-2008 barathsr
		PROCESS_ONHOLD_STRATEGIES (p_strategy_mode        => p_strategy_mode);

		OPEN_STRATEGIES(errbuf			=> errbuf,
				retcode			=> retcode,
				p_ignore_switch		=> p_ignore_switch,
				p_strategy_mode		=> p_strategy_mode);

	     end if;  -- party override



    end if;  -- org enabled
   -- end Naveen

   --Call gen_xml_append_closetag_sty to append the close tag and write the xml data to cp o/p
   -- Start adding by gnramasa for bug 8833868 3-Sep-09
   gen_xml_append_closetag_sty (p_customer_name_low       => p_customer_name_low,
				p_customer_name_high      => p_customer_name_high,
				p_account_number_low      => p_account_number_low,
				p_account_number_high     => p_account_number_high,
				p_billto_location_low     => p_billto_location_low,
				p_billto_location_high    => p_billto_location_high);
    -- End adding by gnramasa for bug 8833868 3-Sep-09

  EXCEPTION

   WHEN OTHERS THEN
   FND_FILE.put_line( FND_FILE.LOG,'err'||sqlerrm);
   writelog('In Main Procedure, err: '||sqlerrm);


END;

-- Start for bug 8708271 multi level strategy
PROCEDURE cancel_strategy( p_party_id number, p_str_level varchar2, p_str_mode varchar2,
                           p_cust_acc_id number, p_site_use_id number, p_del_id number) is

--Start for bug 9742245 gnramasa 7th June 10
cursor c_str_ids (c_party_id number , c_str_level varchar2) is
select strategy_id
from iex_strategies
where jtf_object_type in ('PARTY','IEX_ACCOUNT','IEX_BILLTO','IEX_DELINQUENCY')
and party_id = c_party_id
and strategy_level <> c_str_level
and status_code in ('OPEN' , 'ONHOLD');
--End for bug 9742245 gnramasa 7th June 10

 l_itemtype  varchar2(30);
 l_itemkey   varchar2(50);
 l_party_id  number;
 l_cust_account_id number;
 l_site_use_id number;
 l_del_id    number;
BEGIN
      --Start adding for bug 8761053 gnramasa 18th Aug 09
      for l_str_id in c_str_ids(p_party_id, p_str_level) loop


        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        write_log(FND_LOG.LEVEL_STATEMENT, 'In procedure cancel_strategy');
	write_log(FND_LOG.LEVEL_STATEMENT, 'Strategy ID ' ||  l_str_id.strategy_id );
        end if;

        l_itemtype := 'IEXSTRY';
        l_itemkey := to_char(l_str_id.strategy_id);
        fnd_file.put_line(FND_FILE.LOG, ' Found other level strategy exists for party ' || p_party_id || ' Strategy id is ' || l_str_id.strategy_id);

	if p_str_level = 10 then
		l_party_id	:= p_party_id;
	elsif p_str_level = 20 then
		l_cust_account_id	:= p_cust_acc_id;
	elsif p_str_level = 30 then
		l_site_use_id	:= p_site_use_id;
	elsif p_str_level = 40 then
		l_del_id	:= p_del_id;
	end if;

	gen_xml_body_strategy (p_strategy_id        => l_str_id.strategy_id,
			       p_strategy_status    => 'CANCEL',
			       p_default_sty_level  => p_str_level,
			       p_party_id	    => l_party_id,
			       p_cust_acc_id	    => l_cust_account_id,
			       p_site_use_id	    => l_site_use_id,
			       p_del_id		    => l_del_id);

	if p_str_mode = 'FINAL' then
	BEGIN
            IEX_STRATEGY_WF.Send_Signal(
    		   process => l_itemtype,
               strategy_id => l_itemkey,
               status => l_StratStatusCancelled
            );
            fnd_file.put_line(FND_FILE.LOG, 'Strategy Cancelled. id = '|| l_str_id.strategy_id);
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            write_log(FND_LOG.LEVEL_STATEMENT, 'Strategy Cancelled. id = ' || l_str_id.strategy_id);
            end if;

        EXCEPTION
            WHEN OTHERS THEN
                   fnd_file.put_line(FND_FILE.LOG, 'Strategy Cancelled Raised Exception = '
                            ||  l_str_id.strategy_id || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
            update iex_strategies set status_code='CANCELLED' where strategy_id = l_str_id.strategy_id;
	    commit;
        END;
	end if;

      end loop;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           write_log(FND_LOG.LEVEL_STATEMENT, 'Cancelled strategies for Party ID ' || p_party_id  );
           write_log(FND_LOG.LEVEL_STATEMENT, 'End procedure cancel_strategy');
      end if;

END;
--End adding for bug 8761053 gnramasa 18th Aug 09
-- end for bug 8708271 multi level strategy

PROCEDURE write_log(mesg_level IN NUMBER, mesg IN VARCHAR2) is
l_schema varchar2(10);
l_dot varchar2(10);
l_module varchar2(10);
BEGIN
    l_schema := 'iex';
    l_dot := '.';
    l_module := 'strategy';
    if (mesg_level >= l_msgLevel) then
        fnd_file.put_line(FND_FILE.LOG, mesg);
        FND_LOG.STRING(mesg_level, l_schema || l_dot || l_module , mesg);
    end if;
END;
--Bug# 6870773 Naveen
PROCEDURE update_strat_org
(
		ERRBUF      OUT NOCOPY     VARCHAR2,
		RETCODE     OUT NOCOPY     VARCHAR2
) IS
cursor c_bill_strat_wo_ou(p_org_id number)
is select st.strategy_id,su.org_id
from iex_strategies st,
hz_cust_site_uses_all su
where st.object_type='BILL_TO'
and st.org_id is null
and st.object_id=su.site_use_id
and su.org_id = p_org_id;

cursor c_cust_strat_wo_ou(p_org_id number)
is select st.strategy_id,p_org_id
from iex_strategies st,
hz_parties hp
where st.object_type='PARTY'
and st.org_id is null
and st.object_id=hp.party_id
and not exists(select 1 from
hz_cust_accounts ca,
hz_cust_acct_sites_all cas,
hz_cust_site_uses_all su
where hp.party_id = ca.party_id
and ca.cust_account_id=cas.cust_account_id
and cas.cust_acct_site_id=su.cust_acct_site_id
and su.org_id <> p_org_id)
group by st.strategy_id,p_org_id;

cursor c_account_strat_wo_ou(p_org_id number)
is select st.strategy_id,p_org_id
from iex_strategies st,
hz_cust_accounts ca
where st.object_type='ACCOUNT'
and st.org_id is null
and st.object_id=ca.cust_account_id
and not exists(select 1 from
hz_cust_acct_sites_all cas,
hz_cust_site_uses_all su
where ca.cust_account_id=cas.cust_account_id
and cas.cust_acct_site_id=su.cust_acct_site_id
and su.org_id <> p_org_id);


cursor c_del_strat_wo_ou(p_org_id number)
is select st.strategy_id,del.org_id
from iex_strategies st,
iex_delinquencies_all del
where st.object_type='DELINQUENT'
and st.org_id is null
and st.object_id=del.delinquency_id
and del.org_id = p_org_id;

cursor c_strat_with_ou(p_object_type varchar2)
is select st.strategy_id,null
from iex_strategies st
where st.object_type=p_object_type
and st.org_id is not null;
--and st.org_id = p_org_id;

TYPE strat_list IS TABLE OF IEX_STRATEGIES.STRATEGY_ID%TYPE;
TYPE org_list IS TABLE OF IEX_STRATEGIES.ORG_ID%TYPE;

strategies strat_list;
orgs org_list;



BEGIN

    if l_DefaultStrategyLevel = 10 THEN

	IF l_org_enabled = 'Y' THEN
	      OPEN c_cust_strat_wo_ou(l_org_id);
	      FETCH c_cust_strat_wo_ou BULK COLLECT INTO strategies,orgs;
	      CLOSE c_cust_strat_wo_ou;
	     /*for rec1 in c_cust_strat_wo_ou(l_org_id) loop
		update iex_strategies
		set org_id=rec1.org_id
		where strategy_id = rec1.strategy_id;
	     end loop;*/
	ELSE
	      OPEN c_strat_with_ou('PARTY');
	      FETCH c_strat_with_ou BULK COLLECT INTO strategies,orgs;
	      CLOSE c_strat_with_ou;
             /*for rec1 in c_cust_strat_with_ou(l_org_id) loop
		update iex_strategies
		set org_id=null
		where strategy_id = rec1.strategy_id;
	     end loop;*/
	END IF;
    elsif l_DefaultStrategyLevel = 20 THEN

	IF l_org_enabled = 'Y' THEN
	     OPEN c_account_strat_wo_ou(l_org_id);
	      FETCH c_account_strat_wo_ou BULK COLLECT INTO strategies,orgs;
	      CLOSE c_account_strat_wo_ou;
	ELSE
              OPEN c_strat_with_ou('ACCOUNT');
	      FETCH c_strat_with_ou BULK COLLECT INTO strategies,orgs;
	      CLOSE c_strat_with_ou;
	END IF;
    elsif l_DefaultStrategyLevel = 30 THEN

	IF l_org_enabled = 'Y' THEN
	      OPEN c_bill_strat_wo_ou(l_org_id);
	      FETCH c_bill_strat_wo_ou BULK COLLECT INTO strategies,orgs;
	      CLOSE c_bill_strat_wo_ou;
	      /*for rec1 in c_bill_strat_wo_ou(l_org_id) loop
		update iex_strategies
		set org_id=rec1.org_id
		where strategy_id = rec1.strategy_id;
	     end loop;*/
	ELSE
 	      OPEN c_strat_with_ou('BILL_TO');
	      FETCH c_strat_with_ou BULK COLLECT INTO strategies,orgs;
	      CLOSE c_strat_with_ou;
             /*for rec1 in c_bill_strat_with_ou(l_org_id) loop
		update iex_strategies
		set org_id=null
		where strategy_id = rec1.strategy_id;
	     end loop;*/
	END IF;
    elsif l_DefaultStrategyLevel = 40 THEN

	IF l_org_enabled = 'Y' THEN
	    OPEN c_del_strat_wo_ou(l_org_id);
	      FETCH c_del_strat_wo_ou BULK COLLECT INTO strategies,orgs;
	      CLOSE c_del_strat_wo_ou;
	ELSE
              OPEN c_strat_with_ou('DELINQUENT');
	      FETCH c_strat_with_ou BULK COLLECT INTO strategies,orgs;
	      CLOSE c_strat_with_ou;
	END IF;

    end if;
    fnd_file.put_line(FND_FILE.LOG, 'Checking..');
    fnd_file.put_line(FND_FILE.LOG, 'Updating number of strategies ' || strategies.count);
    if strategies.count>0 then

    forall i in strategies.first..strategies.last
    update iex_strategies
    set org_id=orgs(i)
    where strategy_id = strategies(i);
    commit;
    end if;

EXCEPTION
WHEN OTHERS THEN
	write_log(FND_LOG.LEVEL_STATEMENT, 'In API update_strat_org raised Exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
	fnd_file.put_line(FND_FILE.LOG, 'In API update_strat_org raised Exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
	rollback;

END;

--end Naveen

--Start adding for bug 8630852  by gnramasa 9-July-09
PROCEDURE PRINT_CLOB
  (
    lob_loc IN CLOB)
            IS
  /*-----------------------------------------------------------------------+
  | Local Variable Declarations and initializations                       |
  +-----------------------------------------------------------------------*/
  l_api_name    CONSTANT VARCHAR2(30) := 'PRINT_CLOB';
  l_api_version CONSTANT NUMBER       := 1.0;
  c_endline     CONSTANT VARCHAR2 (1) := '
';
  c_endline_len CONSTANT NUMBER       := LENGTH (c_endline);
  l_start       NUMBER                := 1;
  l_end         NUMBER;
  l_one_line    VARCHAR2 (7000);
  l_charset     VARCHAR2(100);
  /*-----------------------------------------------------------------------+
  | Cursor Declarations                                                   |
  +-----------------------------------------------------------------------*/
BEGIN
  -- LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
  LOOP
    l_end := DBMS_LOB.INSTR (lob_loc => lob_loc, pattern => c_endline, offset => l_start, nth => 1 );
    --FND_FILE.put_line( FND_FILE.LOG,'l_end-->'||l_end);
    IF (NVL (l_end, 0) < 1) THEN
      EXIT;
    END IF;
    l_one_line := DBMS_LOB.SUBSTR (lob_loc => lob_loc, amount => l_end - l_start, offset => l_start );
    --FND_FILE.put_line( FND_FILE.LOG,'l_one_line-->'||l_one_line);
    --FND_FILE.put_line( FND_FILE.LOG,'c_endline_len-->'||c_endline_len);
    l_start := l_end + c_endline_len;
    --FND_FILE.put_line( FND_FILE.LOG,'l_start-->'||l_start);
    --FND_FILE.put_line( FND_FILE.LOG,'32');
    Fnd_File.PUT_line(Fnd_File.OUTPUT,l_one_line);
  END LOOP;
END PRINT_CLOB;

/*========================================================================+
   Function which replaces the special characters in the strings to form
   a valid XML string
 +========================================================================*/
FUNCTION format_string(p_string varchar2) return varchar2 IS

  l_string varchar2(2000);
BEGIN

    l_string := replace(p_string,'&','&'||'amp;');
    l_string := replace(l_string,'<','&'||'lt;');
    l_string := replace(l_string,'>','&'||'gt;');

    RETURN l_string;

END format_string;

Procedure get_resource (p_strategy_rec            IN IEX_STRATEGY_PVT.STRATEGY_REC_TYPE,
                        p_work_item_template_id   IN NUMBER,
                        x_resource_id             OUT NOCOPY NUMBER,
			x_resource_name           OUT NOCOPY VARCHAR2)
is
l_resource_id          number;
l_resource_name        VARCHAR2(360);
l_Assignment_level     varchar2(100);
l_competence_tab       IEX_STRATEGY_WF.tab_of_comp_id;
l_index NUMBER         :=1;
l_default_resource_id  number;
bReturn                Boolean;
l_party_id             number;
l_cust_acct_id         number;
l_cust_site_use_id     number;

cursor c_get_competence_id (p_work_item_temp_id NUMBER) IS
 SELECT competence_id
 from iex_strategy_work_skills
 where work_item_temp_id = p_work_item_temp_id;

cursor c_resource_name (p_resource_id number)
is
select source_name
from jtf_rs_resource_extns
where resource_id = p_resource_id;

begin
	writelog('Begin get_resource');
	l_Assignment_Level  :=  NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');

	l_default_resource_id   :=  nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);
	l_resource_id		:= l_default_resource_id;

	l_party_id		:= p_strategy_rec.party_id;
	l_cust_acct_id		:= p_strategy_rec.cust_account_id;
	l_cust_site_use_id	:= p_strategy_rec.customer_site_use_id;

	FOR c_rec IN c_get_competence_id(p_work_item_template_id)
	LOOP
		l_competence_tab(l_index) := c_rec.competence_id;
		l_index := l_index +1;
	END LOOP;

	if p_strategy_rec.object_type =  'PARTY' then

		  if l_Assignment_Level = 'PARTY' then
			IEX_STRATEGY_WF.get_resource(p_party_id         => l_party_id,
			                             p_competence_tab   => l_competence_tab,
						     x_resource_id      => l_resource_id);
		   end if;
	 elsif p_strategy_rec.object_type = 'IEX_ACCOUNT' then

		  if l_Assignment_Level = 'PARTY' then
			IEX_STRATEGY_WF.get_resource(l_party_id,l_competence_tab,l_resource_id);
		  elsif l_Assignment_level = 'ACCOUNT' then
			bReturn := IEX_STRATEGY_WF.get_account_resource(l_cust_acct_id, l_competence_tab, l_resource_id);
		  end if;

	else
		  if l_Assignment_Level = 'PARTY' then
			IEX_STRATEGY_WF.get_resource(l_party_id,l_competence_tab,l_resource_id);
		  elsif l_Assignment_level = 'ACCOUNT' then
			bReturn := IEX_STRATEGY_WF.get_account_resource(l_cust_acct_id, l_competence_tab, l_resource_id);
		  else
			bReturn := IEX_STRATEGY_WF.get_billto_resource(l_cust_site_use_id,l_competence_tab,l_resource_id);
		  end if;

	 end if;

	  if l_resource_id is null then
             l_resource_id := l_default_resource_id;
          end if;

	x_resource_id    := l_resource_id;

	open c_resource_name (l_resource_id);
	fetch c_resource_name into l_resource_name;
	close c_resource_name;

	x_resource_name  := l_resource_name;

	writelog('In get_resource raised Exception l_resource_name: ' || l_resource_name);
EXCEPTION
WHEN OTHERS THEN
	writelog('In get_resource raised Exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
	fnd_file.put_line(FND_FILE.LOG, 'In get_resource raised Exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
end get_resource;

Procedure gen_xml_header_data_strategy (p_strategy_mode  IN VARCHAR2)
is
   l_api_version           CONSTANT NUMBER := 1.0;
   l_xml_header            varchar2(4000);
   l_xml_header_length     number;
   l_close_tag             VARCHAR2(100);
   l_report_date           varchar2(30);
   l_pro_sty_by_ou         varchar2(30);  --Changed for bug 9173177 gnramasa 11th Dec 09
   l_skip_def_sty_assign   varchar2(30);  --Changed for bug 9173177 gnramasa 11th Dec 09
   l_grace_preiod          number;
   l_resource_id           number;
   l_fulfilment_rs         VARCHAR2(700);  --Changed for bug 9027990 gnramasa 5th Nov 09
   l_terr_acc_level        varchar2(100);  --Changed for bug 9173177 gnramasa 11th Dec 09
   l_lookup_code           varchar2(100);  --Changed for bug 9173177 gnramasa 11th Dec 09
   --Start adding for bug 8708244 gnramasa 31stJuly 09
   l_process_sty_by_cust   varchar2(3);
   l_process_sty_by_acc    varchar2(3);
   l_process_sty_by_billto varchar2(3);
   l_process_sty_by_del    varchar2(3);
   l_org_override_patry    varchar2(3);
   l_strategy_level_name   varchar2(15);
   l_sty_at_multi_level    varchar2(3) := 'N';
   l_no_sty_level	   number := 0;
   l_encoding              VARCHAR2(100);  --Added for bug 9094791 gnramasa 17th Nov 09

   cursor c_get_lookup_meaning (p_lookup_code varchar2)
   is
   select
     meaning
   from fnd_lookups
   where lookup_type= 'YES_NO'
    and lookup_code = p_lookup_code;

   cursor c_resource_name (p_resource_id number)
   is
   select source_name
   from jtf_rs_resource_extns
   where resource_id = p_resource_id;

   cursor c_sty_quest_items
   is
   select using_customer_level,
          using_account_level,
	  using_billto_level,
	  using_delinquency_level,
	  define_party_running_level,
	  define_ou_running_level
   from iex_questionnaire_items;

   cursor c_system_str_level
   is
   SELECT iex_utilities.get_lookup_meaning('IEX_RUNNING_LEVEL',preference_value)
   FROM iex_app_preferences_b
   WHERE preference_name='COLLECTIONS STRATEGY LEVEL'
   AND enabled_flag     = 'Y'
   AND org_id          IS NULL;

begin
      writelog('Begin gen_xml_header_data_strategy');
      FND_FILE.put_line( FND_FILE.LOG,'XML header data generation starts');

      select to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS')
      into l_report_date
      from dual;
      writelog('gen_xml_header_data_strategy: l_report_date: ' || l_report_date);

      l_terr_acc_level	:= NVL(fnd_profile.value('IEX_ACCESS_LEVEL'), 'PARTY');
      writelog('gen_xml_header_data_strategy: l_terr_acc_level: ' || l_terr_acc_level);

      l_lookup_code	:= nvl(fnd_profile.value('IEX_PROC_STR_ORG'),'N');
      writelog('gen_xml_header_data_strategy: l_lookup_code: ' || l_lookup_code);

      open c_get_lookup_meaning (l_lookup_code);
      fetch c_get_lookup_meaning into l_pro_sty_by_ou;
      close c_get_lookup_meaning;

      l_lookup_code	:= NVL(FND_PROFILE.VALUE('IEX_SKIP_DEFAULT_STRATEGY_ASSIGNMENT'), 'N');
      open c_get_lookup_meaning (l_lookup_code);
      fetch c_get_lookup_meaning into l_skip_def_sty_assign;
      close c_get_lookup_meaning;

      l_resource_id :=  NVL(fnd_profile.value('IEX_STRY_FULFILMENT_RESOURCE'), 0);
      open c_resource_name (l_resource_id);
      fetch c_resource_name into l_fulfilment_rs;
      close c_resource_name;

      open c_sty_quest_items;
      fetch c_sty_quest_items into l_process_sty_by_cust, l_process_sty_by_acc, l_process_sty_by_billto, l_process_sty_by_del,
                                   l_org_override_patry, l_coll_at_ous;
      close c_sty_quest_items;

      open c_get_lookup_meaning (l_process_sty_by_cust);
      fetch c_get_lookup_meaning into l_process_sty_by_cust;
      close c_get_lookup_meaning;

      open c_get_lookup_meaning (l_process_sty_by_acc);
      fetch c_get_lookup_meaning into l_process_sty_by_acc;
      close c_get_lookup_meaning;

      open c_get_lookup_meaning (l_process_sty_by_billto);
      fetch c_get_lookup_meaning into l_process_sty_by_billto;
      close c_get_lookup_meaning;

      open c_get_lookup_meaning (l_process_sty_by_del);
      fetch c_get_lookup_meaning into l_process_sty_by_del;
      close c_get_lookup_meaning;

      open c_get_lookup_meaning (l_org_override_patry);
      fetch c_get_lookup_meaning into l_org_override_patry;
      close c_get_lookup_meaning;

      open c_get_lookup_meaning (l_coll_at_ous);
      fetch c_get_lookup_meaning into l_coll_at_ous;
      close c_get_lookup_meaning;

      open c_system_str_level;
      fetch c_system_str_level into l_strategy_level_name;
      close c_system_str_level;

      --Start adding for bug 8761053 gnramasa 18th Aug 09
      if l_process_sty_by_cust = 'Yes' then
		l_no_sty_level := l_no_sty_level + 1;
      end if;
      if l_process_sty_by_acc = 'Yes' then
		l_no_sty_level := l_no_sty_level + 1;
      end if;
      if l_process_sty_by_billto = 'Yes' then
		l_no_sty_level := l_no_sty_level + 1;
      end if;
      if l_process_sty_by_del = 'Yes' then
		l_no_sty_level := l_no_sty_level + 1;
      end if;

      if l_no_sty_level >1 then
		l_sty_at_multi_level := 'Y';
      else
		l_sty_at_multi_level := 'N';
      end if;



      l_grace_preiod	:= NVL(to_number(FND_PROFILE.VALUE('IEX_STRY_GRACE_PERIOD')), 0);

      FND_FILE.put_line( FND_FILE.LOG,'Start constructing the XML Header');
      l_new_line := '
';
      /*Get the special characters replaced */
      l_report_date      := format_string(l_report_date);
      l_fulfilment_rs    := format_string(l_fulfilment_rs);

      /* Prepare the tag for the report heading */
   --Start adding for bug 9094791 gnramasa 17th Nov 09
   --l_xml_header     := '<?xml version="1.0" encoding="UTF-8"?>';
   -- Instead of hard coding the value, pick the charcter set value from "ICX: Client IANA Encoding" profile.
   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
   l_xml_header     := '<?xml version="1.0" encoding="'||l_encoding||'"?>';
   --End adding for bug 9094791 gnramasa 17th Nov 09
   l_xml_header     := l_xml_header ||l_new_line||'<STRATEGYSET>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORT_DATE>'||l_report_date||'</REPORT_DATE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <STRATEGY_LEVEL>'|| l_strategy_level_name ||'</STRATEGY_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <PROCESS_STY_BY_CUST>'|| l_process_sty_by_cust ||'</PROCESS_STY_BY_CUST>';
   l_xml_header     := l_xml_header ||l_new_line||'        <PROCESS_STY_BY_ACC>'|| l_process_sty_by_acc ||'</PROCESS_STY_BY_ACC>';
   l_xml_header     := l_xml_header ||l_new_line||'        <PROCESS_STY_BY_BILLTO>'|| l_process_sty_by_billto ||'</PROCESS_STY_BY_BILLTO>';
   l_xml_header     := l_xml_header ||l_new_line||'        <PROCESS_STY_BY_DEL>'|| l_process_sty_by_del ||'</PROCESS_STY_BY_DEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ORG_OVERRIDE_PATRY>'|| l_org_override_patry ||'</ORG_OVERRIDE_PATRY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <COLL_AT_OUS>'|| l_coll_at_ous ||'</COLL_AT_OUS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <TERR_ACCESS_LEVEL>'|| l_terr_acc_level ||'</TERR_ACCESS_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <STRATEGY_MODE>' || p_strategy_mode ||'</STRATEGY_MODE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CONC_REQUEST_ID>' || FND_GLOBAL.CONC_REQUEST_ID ||'</CONC_REQUEST_ID>';
   l_xml_header     := l_xml_header ||l_new_line||'        <PROCESS_STY_BY_OU>' || l_pro_sty_by_ou ||'</PROCESS_STY_BY_OU>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SKIP_DEF_STY_ASSIGN>' || l_skip_def_sty_assign ||'</SKIP_DEF_STY_ASSIGN>';
   l_xml_header     := l_xml_header ||l_new_line||'        <STY_DEFAULT_TEMPLATE>' || format_string(l_DefaultTempName) ||'</STY_DEFAULT_TEMPLATE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <DEFAULT_RESOURCE>' || format_string(l_SourceName) ||'</DEFAULT_RESOURCE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <FULFILMENT_RESOURCE>' || l_fulfilment_rs ||'</FULFILMENT_RESOURCE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <STY_GRACE_PERIOD>' || l_grace_preiod ||'</STY_GRACE_PERIOD>';
   l_xml_header     := l_xml_header ||l_new_line||'        <STY_AT_MULTI_LEVEL>' || l_sty_at_multi_level || '</STY_AT_MULTI_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'<ROWSET>';

   --End adding for bug 8761053 gnramasa 18th Aug 09
   --End adding for bug 8708244 gnramasa 31stJuly 09


   l_xml_header_length := length(l_xml_header);
   tempResult := l_xml_header;
   FND_FILE.put_line( FND_FILE.LOG,'Constructing the XML Header is success');

   dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
   dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
   dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);

  writelog('End gen_xml_header_data_strategy');

EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.put_line( FND_FILE.LOG,'err'||sqlerrm);
   RAISE;
END gen_xml_header_data_strategy;

Procedure gen_xml_body_strategy (p_strategy_id        IN NUMBER DEFAULT NULL,
                                 p_strategy_rec       IN IEX_STRATEGY_PVT.STRATEGY_REC_TYPE DEFAULT NULL,
				 p_strategy_status    IN VARCHAR2,
				 p_default_sty_level  IN NUMBER DEFAULT NULL,
				 p_party_id           IN NUMBER DEFAULT NULL,
                                 p_cust_acc_id        IN NUMBER DEFAULT NULL,
				 p_site_use_id        IN NUMBER DEFAULT NULL,
				 p_del_id             IN NUMBER DEFAULT NULL)
is
   l_api_version	  CONSTANT NUMBER := 1.0;
   l_xml_body		  varchar2(4000);
   l_party_id             number;
   l_cust_Account_id	  number;
   l_customer_site_use_id number;
   l_delinquency_id       number;
   l_score                number;
   l_new_score            number;
   --Start changing for bug 9027990 gnramasa 5th Nov 09
   l_strategy_name        VARCHAR2(500);
   l_new_strategy_name    VARCHAR2(500);
   l_party_name           VARCHAR2(700);
   l_account_number       VARCHAR2(100);
   l_location             VARCHAR2(100);
   l_trx_number           VARCHAR2(100);
   l_first_work_item      VARCHAR2(500);
   l_work_item_temp_id    number;
   l_resource_id          number;
   l_resource_name        VARCHAR2(700);
   l_sty_workitem_st      varchar2(500);
   --Start adding for bug 8708244 gnramasa 31stJuly 09
   l_strategy_level_name  varchar2(30);
   l_strategy_level	  number;
   l_org_name		  varchar2(500);	--Added for bug 8761053 gnramasa 18th Aug 09
   --End changing for bug 9027990 gnramasa 5th Nov 09

   cursor c_strategy
   is
   select
     sty.party_id,
     sty.cust_Account_id,
     sty.customer_site_use_id,
     sty.delinquency_id,
     sty.score_value,
     tpl.strategy_name,
     stry_temp_wkitem.name,
     iex_utilities.get_lookup_meaning('IEX_STRATEGY_WORK_STATUS',swi.status_code) STATUS_MEANING,
     jtf.source_name,
     iex_utilities.get_lookup_meaning('IEX_RUNNING_LEVEL',(decode(sty.strategy_level, 10, 'CUSTOMER', 20, 'ACCOUNT',
                                       30, 'BILL_TO', 40, 'DELINQUENCY'))) strategy_level_name,
     sty.strategy_level	strategy_level
   from iex_strategies sty,
    iex_strategy_templates_tl tpl,
    iex_strategy_work_items swi,
    iex_stry_temp_work_items_vl stry_temp_wkitem,
    jtf_rs_resource_extns jtf
   where sty.strategy_id = p_strategy_id
    and sty.strategy_template_id = tpl.strategy_temp_id
    and tpl.language = userenv('LANG')
    and sty.next_work_item_id = swi.work_item_id
    and swi.work_item_template_id = stry_temp_wkitem.work_item_temp_id
    and stry_temp_wkitem.language = userenv('LANG')
    and swi.resource_id = jtf.resource_id;

   cursor c_strategy1
   is
   select
     sty.party_id,
     sty.cust_Account_id,
     sty.customer_site_use_id,
     sty.delinquency_id,
     sty.score_value,
     tpl.strategy_name,
     iex_utilities.get_lookup_meaning('IEX_RUNNING_LEVEL',(decode(sty.strategy_level, 10, 'CUSTOMER', 20, 'ACCOUNT',
                                       30, 'BILL_TO', 40, 'DELINQUENCY'))) strategy_level_name,
     sty.strategy_level	strategy_level
   from iex_strategies sty,
    iex_strategy_templates_tl tpl
   where sty.strategy_id = p_strategy_id
    and sty.strategy_template_id = tpl.strategy_temp_id
    and tpl.language = userenv('LANG');

   cursor c_strategy_name (l_sty_template_id number)
   is
   SELECT tpl.strategy_name,
	iex_utilities.get_lookup_meaning('IEX_RUNNING_LEVEL',(DECODE(p_strategy_rec.strategy_level, 10, 'CUSTOMER', 20, 'ACCOUNT',
	                                 30, 'BILL_TO', 40, 'DELINQUENCY'))) strategy_level_name
   FROM iex_strategy_templates_tl tpl,
     iex_strategy_templates_b tpb
   WHERE tpb.strategy_temp_id = tpl.strategy_temp_id
   AND tpl.strategy_temp_id   = l_sty_template_id
   AND tpl.language           = userenv('LANG');
   --End added for bug 8708244 gnramasa 31stJuly 09

   cursor c_first_work_item (l_sty_template_id number)
   is
   select stry_temp_wkitem.name,
    stry_temp_wkitem.work_item_temp_id,
    iex_utilities.get_lookup_meaning('IEX_STRATEGY_WORK_STATUS',(decode(stry_temp_wkitem.pre_execution_wait,0,'OPEN','PRE-WAIT'))) STATUS_MEANING
   from iex_strategy_work_temp_xref xref
    ,iex_stry_temp_work_items_vl stry_temp_wkitem
   where xref.work_item_temp_id = stry_temp_wkitem.work_item_temp_id
    and xref.strategy_temp_id = l_sty_template_id
    and stry_temp_wkitem.language = userenv('LANG')
    order by xref.work_item_order;

   cursor c_party (p_party_id number)
   is
   select
    party_name
   from hz_parties
   where party_id = p_party_id;

   cursor c_account (p_cust_acct_id number)
   is
   select
    p.party_name,
    c.account_number
   from hz_parties p,
    hz_cust_accounts c
   where c.cust_account_id = p_cust_acct_id
    and c.party_id = p.party_id;

   cursor c_billto (p_cust_site_use_id number)
   is
   select
    p.party_name,
    c.account_number,
    site_uses.location
   from hz_parties p,
    hz_cust_accounts c,
    hz_cust_acct_sites_all acct_sites,
    hz_cust_site_uses_all site_uses
   where site_uses.site_use_id = p_cust_site_use_id
   and acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id
   and c.cust_account_id = acct_sites.cust_account_id
   and p.party_id = c.party_id;

   cursor c_delinquency (p_delinquency_id number)
   is
   select
    p.party_name,
    aps.trx_number TRANSACTION_NUMBER
   from iex_delinquencies_all del,
    ar_payment_schedules_all aps ,
    hz_parties p
   where del.delinquency_id = p_delinquency_id
    and del.payment_Schedule_id = aps.payment_Schedule_id
    and del.party_cust_id = p.party_id;

   --Start adding for bug 8761053 gnramasa 18th Aug 09
   cursor c_org_name
   is
   select
    name
   from hr_all_organization_units_tl
   where organization_id = l_org_id
    and language = userenv('LANG');

begin
	writelog('Begin gen_xml_body_strategy');
	writelog('gen_xml_body_strategy, p_strategy_id: ' || p_strategy_id);
	writelog('gen_xml_body_strategy, p_strategy_status: ' || p_strategy_status);

	if p_strategy_rec.strategy_template_id IS NOT NULL then
		l_party_id		:= p_strategy_rec.party_id;
		l_cust_Account_id	:= p_strategy_rec.cust_account_id;
		l_customer_site_use_id	:= p_strategy_rec.customer_site_use_id;
		l_delinquency_id	:= p_strategy_rec.delinquency_id;
		l_strategy_level	:= p_strategy_rec.strategy_level;

		--Start adding for bug 8708244 gnramasa 31stJuly 09
		open c_strategy_name (p_strategy_rec.strategy_template_id);
		if p_strategy_status = 'RECREATE' then
			fetch c_strategy_name into l_new_strategy_name, l_strategy_level_name;
			l_new_score		:= p_strategy_rec.score_value;
		else
			fetch c_strategy_name into l_strategy_name, l_strategy_level_name;
			l_score			:= p_strategy_rec.score_value;
		end if;
		close c_strategy_name;

		open c_first_work_item (p_strategy_rec.strategy_template_id);
		fetch c_first_work_item into l_first_work_item, l_work_item_temp_id,l_sty_workitem_st;
		close c_first_work_item;

		writelog('gen_xml_body_strategy, before get_resource');
		get_resource(p_strategy_rec           => p_strategy_rec,
			     p_work_item_template_id  => l_work_item_temp_id,
		             x_resource_id            => l_resource_id,
			     x_resource_name          => l_resource_name);
		writelog('gen_xml_body_strategy, after get_resource');
	end if;

	if p_strategy_id IS NOT NULL then
		if p_strategy_status = 'RECREATE' then
			open c_strategy1;
			fetch c_strategy1 into l_party_id, l_cust_Account_id, l_customer_site_use_id, l_delinquency_id,
			l_score, l_strategy_name, l_strategy_level_name, l_strategy_level;
			close c_strategy1;
		else
			open c_strategy;
			fetch c_strategy into l_party_id, l_cust_Account_id, l_customer_site_use_id,
			                      l_delinquency_id, l_score, l_strategy_name,l_first_work_item,
					      l_sty_workitem_st,l_resource_name, l_strategy_level_name, l_strategy_level;
			close c_strategy;
			--End adding for bug 8708244 gnramasa 31stJuly 09
		end if;
	end if;

	--if l_StrategyLevelName = 'CUSTOMER' then
	if l_strategy_level = 10 then
		open c_party (l_party_id);
		fetch c_party into l_party_name;
		close c_party;
	--elsif l_StrategyLevelName = 'ACCOUNT' then
	elsif l_strategy_level = 20 then
		open c_account (l_cust_Account_id);
		fetch c_account into l_party_name, l_account_number;
		close c_account;
	--elsif l_StrategyLevelName = 'BILL_TO' then
	elsif l_strategy_level = 30 then
		open c_billto (l_customer_site_use_id);
		fetch c_billto into l_party_name, l_account_number, l_location;
		close c_billto;
	else
		open c_delinquency (l_delinquency_id);
		fetch c_delinquency into l_party_name, l_trx_number;
		close c_delinquency;
	end if;

	if p_strategy_status = 'CANCEL' then
		if p_default_sty_level = 10 then
			if l_party_id is NULL then
				l_party_id	:= p_party_id;
				open c_party (l_party_id);
				fetch c_party into l_party_name;
				close c_party;
			end if;
		elsif p_default_sty_level = 20 then
			if l_cust_Account_id is NULL then
				l_cust_Account_id	:= p_cust_acc_id;
				open c_account (l_cust_Account_id);
				fetch c_account into l_party_name, l_account_number;
				close c_account;
			end if;
		elsif p_default_sty_level = 30 then
			if l_customer_site_use_id is NULL then
				l_customer_site_use_id	:= p_site_use_id;
				open c_billto (l_customer_site_use_id);
				fetch c_billto into l_party_name, l_account_number, l_location;
				close c_billto;
			end if;
		elsif p_default_sty_level = 40 then
			if l_delinquency_id is NULL then
				l_delinquency_id	:= p_del_id;
				open c_delinquency (l_delinquency_id);
			fetch c_delinquency into l_party_name, l_trx_number;
			close c_delinquency;
			end if;
		end if;
	end if;

	if l_coll_at_ous = 'Yes' then
		open c_org_name;
		fetch c_org_name into l_org_name;
		close c_org_name;
	end if;

	writelog('gen_xml_body_strategy, before format_string');
	/*Get the special characters replaced */
        l_party_name         := format_string(l_party_name);
	l_account_number     := format_string(l_account_number);
	l_location           := format_string(l_location);
	l_trx_number         := format_string(l_trx_number);
	l_strategy_name      := format_string(l_strategy_name);
	l_new_strategy_name  := format_string(l_new_strategy_name);
	l_org_name	     := format_string(l_org_name);
	writelog('gen_xml_body_strategy, after format_string');

	--l_xml_body     := l_xml_body ||l_new_line||'<ROW num="' || l_seq_no || '">';
	l_xml_body     := l_xml_body ||l_new_line||'<'|| p_strategy_status||' num="' || l_seq_no || '">';
	l_xml_body     := l_xml_body ||l_new_line||'<PARTY_ID> ' || l_party_id || '</PARTY_ID>';
	l_xml_body     := l_xml_body ||l_new_line||'<PARTY_NAME>' || l_party_name || '</PARTY_NAME>';
	l_xml_body     := l_xml_body ||l_new_line||'<ACCOUNT_NUMBER>' || l_account_number || '</ACCOUNT_NUMBER>';
	l_xml_body     := l_xml_body ||l_new_line||'<LOCATION>' || l_location || '</LOCATION>';
	l_xml_body     := l_xml_body ||l_new_line||'<CUST_ACCOUNT_ID> ' || l_cust_Account_id || '</CUST_ACCOUNT_ID>';
	l_xml_body     := l_xml_body ||l_new_line||'<CUST_SITE_USE_ID> ' || l_customer_site_use_id || '</CUST_SITE_USE_ID>';
	l_xml_body     := l_xml_body ||l_new_line||'<TRANSACTION_NUMBER> ' || l_trx_number || '</TRANSACTION_NUMBER>';
        l_xml_body     := l_xml_body ||l_new_line||'<DELINQUENCY_ID> ' || l_delinquency_id || '</DELINQUENCY_ID>';
	l_xml_body     := l_xml_body ||l_new_line||'<STRATEGY_LEVEL> ' || l_strategy_level_name || '</STRATEGY_LEVEL>';  --Added for bug 8708244 gnramasa 31stJuly 09
	l_xml_body     := l_xml_body ||l_new_line||'<SCORE>' || l_score || '</SCORE>';
	l_xml_body     := l_xml_body ||l_new_line||'<STRATEGY_NAME>' || l_strategy_name || '</STRATEGY_NAME>';
	l_xml_body     := l_xml_body ||l_new_line||'<NEW_SCORE>' || l_new_score || '</NEW_SCORE>';
	l_xml_body     := l_xml_body ||l_new_line||'<NEW_STRATEGY_NAME>' || l_new_strategy_name || '</NEW_STRATEGY_NAME>';
	l_xml_body     := l_xml_body ||l_new_line||'<WORKITEM_NAME>' || l_first_work_item || '</WORKITEM_NAME>';
	l_xml_body     := l_xml_body ||l_new_line||'<WORKITEM_ASSIGNEE>' || l_resource_name ||'</WORKITEM_ASSIGNEE>';
	l_xml_body     := l_xml_body ||l_new_line||'<WORKITEM_STATUS>' || l_sty_workitem_st ||'</WORKITEM_STATUS>';
	l_xml_body     := l_xml_body ||l_new_line||'<ORGANIZATION_NAME>' || l_org_name ||'</ORGANIZATION_NAME>';
	l_xml_body     := l_xml_body ||l_new_line||'</'|| p_strategy_status ||'>';

	writelog('gen_xml_body_strategy, end of constructing body text');

	dbms_lob.writeAppend(tempResult, length(l_xml_body), l_xml_body);
	l_seq_no   := l_seq_no + 1;

	if p_strategy_status = 'CLOSE' then
		l_no_closed_rec	:= l_no_closed_rec + 1;
	elsif p_strategy_status = 'REOPEN' then
		l_no_reopen_rec	:= l_no_reopen_rec + 1;
	elsif p_strategy_status = 'RECREATE' then
		l_no_reassign_rec := l_no_reassign_rec + 1;
	elsif p_strategy_status = 'CREATE' then
		l_no_new_rec	:= l_no_new_rec + 1;
	end if;

	writelog('End gen_xml_body_strategy');

EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.put_line( FND_FILE.LOG,'err'||sqlerrm);
   writelog('in gen_xml_body_strategy, err: '||sqlerrm);
   RAISE;
END gen_xml_body_strategy;

-- Start adding by gnramasa for bug 8833868 3-Sep-09
Procedure gen_xml_append_closetag_sty  (p_customer_name_low     IN   VARCHAR2 DEFAULT NULL,
					p_customer_name_high    IN   VARCHAR2 DEFAULT NULL,
					p_account_number_low    IN   VARCHAR2 DEFAULT NULL,
					p_account_number_high   IN   VARCHAR2 DEFAULT NULL,
					p_billto_location_low   IN   VARCHAR2 DEFAULT NULL,
					p_billto_location_high  IN   VARCHAR2 DEFAULT NULL)
is
   l_api_version           CONSTANT NUMBER := 1.0;
   l_close_tag             VARCHAR2(4000) := '';
   l_mou_party_tag         VARCHAR2(4000) := '';
   l_mou_account_tag       VARCHAR2(4000) := '';
   l_party_id              number;
   --Start changing for bug 9027990 gnramasa 5th Nov 09
   l_party_name            VARCHAR2(700);
   l_account_number        VARCHAR2(60);
   --End changing for bug 9027990 gnramasa 5th Nov 09
   l_cust_account_id	   number;

   /*
   cursor c_mou_party is
   select p.party_id party_id,
          p.party_name party_name
   from hz_parties p
   where p.party_id in (
   select
    d.party_cust_id
   from
    iex_delinquencies_all d
    group by d.party_cust_id
    having count(distinct d.org_id) > 1);

   cursor c_mou_account is
   select p.party_id party_id,
          p.party_name party_name,
	  ca.account_number account_number,
	  ca.cust_account_id cust_account_id
   from hz_parties p,
        hz_cust_accounts ca
   where p.party_id = ca.party_id
    and ca.cust_account_id in (
   select
    d.cust_account_id
   from
    iex_delinquencies_all d
    group by d.cust_account_id
    having count(distinct d.org_id) > 1);


   l_c_mou_party	c_mou_party%rowtype;
   l_c_mou_account	c_mou_account%rowtype;
   */

   TYPE c_mou_partyCurTyp IS REF CURSOR;
   c_mou_party c_mou_partyCurTyp;
   TYPE c_mou_accountCurTyp IS REF CURSOR;
   c_mou_account c_mou_accountCurTyp;

   vPLSQL	   VARCHAR2(5000);
   vPLSQL1	   VARCHAR2(5000);
   l_api_name      varchar2(50) := 'gen_xml_append_closetag_sty';

begin
	writelog('Begin gen_xml_append_closetag_sty');
	FND_FILE.put_line( FND_FILE.LOG,'XML append close tag generation starts');

	if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
	    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
		writelog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
		--Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
		    custom_where_clause
			   (p_customer_name_low       => p_customer_name_low,
			    p_customer_name_high      => p_customer_name_high,
			    p_account_number_low      => p_account_number_low,
			    p_account_number_high     => p_account_number_high,
			    p_billto_location_low     => p_billto_location_low,
			    p_billto_location_high    => p_billto_location_high,
			    p_strategy_level          => 10);

		writelog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
	end if;

	vPLSQL := 'select s.party_id party_id, s.party_name party_name  from hz_parties s ' ||
		    ' where s.party_id in ( select d.party_cust_id  from iex_delinquencies_all d '||
		    ' group by d.party_cust_id  having count(distinct d.org_id) > 1)';
	if l_custom_select IS NOT NULL then
		vPLSQL := vPLSQL || ' and exists ( ' || l_custom_select || '= s.party_id) ';
	end if;
	writelog('gen_xml_append_closetag_sty: vPLSQL = ' || vPLSQL);
	FND_FILE.put_line( FND_FILE.LOG,'gen_xml_append_closetag_sty: vPLSQL = ' || vPLSQL);

	open c_mou_party for vPLSQL;
	loop
	fetch c_mou_party into l_party_id, l_party_name;
	if c_mou_party%FOUND then
	--for l_c_mou_party in c_mou_party loop

		l_party_name	:= format_string(l_party_name);

		l_mou_party_tag       := l_new_line||'<MOU_PARTY num="' || l_seq_no || '">';
		l_mou_party_tag       := l_mou_party_tag ||l_new_line||'<PARTY_ID> ' || l_party_id || '</PARTY_ID>';
		l_mou_party_tag       := l_mou_party_tag ||l_new_line||'<PARTY_NAME>' || l_party_name || '</PARTY_NAME>';
		l_mou_party_tag       := l_mou_party_tag ||l_new_line||'</MOU_PARTY>';
		dbms_lob.writeAppend(tempResult, length(l_mou_party_tag), l_mou_party_tag);
		l_seq_no   := l_seq_no + 1;
	ELSE  -- fetch failed, so exit loop
		EXIT;
	end if;
	end loop;
	close c_mou_party;

	if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
	    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
		writelog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
		--Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
		    custom_where_clause
			   (p_customer_name_low       => p_customer_name_low,
			    p_customer_name_high      => p_customer_name_high,
			    p_account_number_low      => p_account_number_low,
			    p_account_number_high     => p_account_number_high,
			    p_billto_location_low     => p_billto_location_low,
			    p_billto_location_high    => p_billto_location_high,
			    p_strategy_level          => 20);

		writelog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
	end if;
	vPLSQL1 := 'select s.party_id party_id, s.party_name party_name, cu_ac.account_number account_number, cu_ac.cust_account_id cust_account_id '||
		  ' from hz_parties s, hz_cust_accounts cu_ac  where s.party_id = cu_ac.party_id  and cu_ac.cust_account_id in ( '||
		  ' select  d.cust_account_id  from iex_delinquencies_all d  group by d.cust_account_id  having count(distinct d.org_id) > 1)';
	if l_custom_select IS NOT NULL then
		vPLSQL1 := vPLSQL1 || ' and exists ( ' || l_custom_select || '= cu_ac.cust_account_id) ';
	end if;
	writelog('gen_xml_append_closetag_sty: vPLSQL1 = ' || vPLSQL1);
	FND_FILE.put_line( FND_FILE.LOG,'gen_xml_append_closetag_sty: vPLSQL1 = ' || vPLSQL1);

	open c_mou_account for vPLSQL1;
	loop
	fetch c_mou_account into l_party_id, l_party_name, l_account_number, l_cust_account_id;
	if c_mou_account%FOUND then
	--for l_c_mou_account in c_mou_account loop

		l_party_name	      := format_string(l_party_name);
		l_account_number      := format_string(l_account_number);

		l_mou_account_tag     := l_new_line||'<MOU_ACCOUNT num="' || l_seq_no || '">';
		l_mou_account_tag     := l_mou_account_tag ||l_new_line||'<PARTY_ID> ' || l_party_id || '</PARTY_ID>';
		l_mou_account_tag     := l_mou_account_tag ||l_new_line||'<PARTY_NAME>' || l_party_name || '</PARTY_NAME>';
		l_mou_account_tag     := l_mou_account_tag ||l_new_line||'<ACCOUNT_NUMBER>' || l_account_number || '</ACCOUNT_NUMBER>';
		l_mou_account_tag     := l_mou_account_tag ||l_new_line||'<CUST_ACCOUNT_ID>' || l_cust_account_id || '</CUST_ACCOUNT_ID>';
		l_mou_account_tag     := l_mou_account_tag ||l_new_line||'</MOU_ACCOUNT>';
		dbms_lob.writeAppend(tempResult, length(l_mou_account_tag), l_mou_account_tag);
		l_seq_no   := l_seq_no + 1;
	ELSE  -- fetch failed, so exit loop
		EXIT;
	end if;
	end loop;
	close c_mou_account;
	-- End adding by gnramasa for bug 8833868 3-Sep-09

	l_close_tag      := l_new_line||'</ROWSET>';
	l_close_tag      := l_close_tag ||l_new_line||'<NO_CLOSED_REC>' || l_no_closed_rec || '</NO_CLOSED_REC>';
	l_close_tag      := l_close_tag ||l_new_line||'<NO_REOPEN_REC>' || l_no_reopen_rec || '</NO_REOPEN_REC>';
	l_close_tag      := l_close_tag ||l_new_line||'<NO_REASSIGN_REC>' || l_no_reassign_rec || '</NO_REASSIGN_REC>';
	l_close_tag      := l_close_tag ||l_new_line||'<NO_NEW_REC>' || l_no_new_rec || '</NO_NEW_REC>';
	l_close_tag      := l_close_tag ||l_new_line||'</STRATEGYSET>'||l_new_line;

	dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
	FND_FILE.put_line( FND_FILE.LOG,'Appended close tag to XML data');
	--Fnd_File.PUT_line(Fnd_File.OUTPUT,tempResult);
	print_clob(lob_loc => tempResult);
	FND_FILE.put_line( FND_FILE.LOG,'XML generation is success');
	writelog('End gen_xml_append_closetag_sty');

EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.put_line( FND_FILE.LOG,'err'||sqlerrm);
   RAISE;
END gen_xml_append_closetag_sty;
--End adding for bug 8761053 gnramasa 18th Aug 09
--End adding for bug 8630852  by gnramasa 9-July-09

BEGIN
  -- initialize values
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
  l_enabled := 'N';

  l_DelStatusCurrent  := 'CURRENT';
  /* begin add for bug 4408860 - add checking CLOSE status from case delinquency */
  l_DelStatusClose  := 'CLOSE';
  /* end add for bug 4408860 - add checking CLOSE status from case delinquency */
  l_DelStatusDel  := 'DELINQUENT';
  l_DelStatusPreDel  := 'PREDELINQUENT';

  l_StratStatusOpen := 'OPEN';
  l_StratStatusOnhold := 'ONHOLD';
  l_StratStatusPending := 'PENDING';
  l_StratStatusClosed := 'CLOSED';
  l_StratStatusCancelled := 'CANCELLED';
  l_Yes := 'Y';
  l_No := 'N';
  l_StratObjectFilterType := 'IEXSTRAT';

    l_enabled := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    if (l_enabled = 'N') then
       l_MsgLevel := FND_LOG.LEVEL_UNEXPECTED;
    else
       l_MsgLevel := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;
    l_DefaultTempID := GetDefaultStrategyTempID;

   -- Start for bug # 5487449 on 28/08/2006 by gnramasa
    write_log(FND_LOG.LEVEL_UNEXPECTED, 'Default Template ID ' || l_DefaultTempID || ' Profile Name  IEX: Strategy Default Template (IEX_STRATEGY_DEFAULT_TEMPLATE)');
   begin
    select STRATEGY_NAME ,ENABLED_FLAG
      into l_DefaultTempName, l_EnabledFlag
      from iex_strategy_templates_vl
      where STRATEGY_TEMP_ID=l_DefaultTempID;

    write_log(FND_LOG.LEVEL_UNEXPECTED, 'Default Template Name :' || l_DefaultTempName || ' , Enabled Flag :' || l_EnabledFlag );
    EXCEPTION
            WHEN OTHERS THEN
              fnd_file.put_line(FND_FILE.LOG, 'Default Template Name raised Exception ' || SQLCODE || ' ' || SQLERRM);
    END;

    begin
      l_default_rs_id  := NVL(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'), 0);
      select SOURCE_NAME,USER_NAME
        into l_SourceName,l_UserName
        from jtf_rs_resource_extns
        where RESOURCE_ID=l_default_rs_id;
      write_log(FND_LOG.LEVEL_UNEXPECTED, 'Resource Id :' || l_default_rs_id || ' Profile Name  IEX: Strategy Assignment Default Resource (IEX_STRY_DEFAULT_RESOURCE) , Resource Name :' || l_SourceName || ' , User Name :' || l_UserName);
    EXCEPTION
            WHEN OTHERS THEN
              fnd_file.put_line(FND_FILE.LOG, 'Resource Name raised Exception ' || SQLCODE || ' ' || SQLERRM);
    END;
    -- Start for bug # 5877743 on 28/02/2007 by gnramasa
    begin
        --Begin Bug#7205287  31-Jul-2008 barathsr
      write_log(FND_LOG.LEVEL_UNEXPECTED, 'Work Item Assignment Collector level from Profile (IEX: Territory Access Level) :'-- (IEX: Collector Access Level) :'
         || NVL(fnd_profile.value('IEX_ACCESS_LEVEL'), 'PARTY'));
	--End Bug#7205287  31-Jul-2008 barathsr
    EXCEPTION
            WHEN OTHERS THEN
              fnd_file.put_line(FND_FILE.LOG, 'Work Item Assignment Collector level raised exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
    END;
    -- End for bug # 5877743 on 28/02/2007 by gnramasa
    -- Start for bug 8708271 multi level strategy
  /*  begin
    select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  50),preference_value
      into l_DefaultStrategyLevel,l_StrategyLevelName
      from iex_app_preferences_vl
      where  preference_name = 'COLLECTIONS STRATEGY LEVEL' and enabled_flag = l_Yes;
    write_log(FND_LOG.LEVEL_STATEMENT, 'Current Strategy Level ' || l_DefaultStrategyLevel || '  , ' || l_StrategyLevelName);

     -- End for bug # 5487449 on 28/08/2006 by gnramasa
    EXCEPTION
            WHEN OTHERS THEN
              fnd_file.put_line(FND_FILE.LOG, 'Strategy Level Rised Exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
    END; */

    begin

       select DEFINE_PARTY_RUNNING_LEVEL,DEFINE_OU_RUNNING_LEVEL
       into l_party_override,l_org_override
       from IEX_QUESTIONNAIRE_ITEMS;

    write_log(FND_LOG.LEVEL_STATEMENT, 'Party Level Strategy Override and Operating Unit Level Override values ' || l_party_override || '  , ' || l_org_override);

    EXCEPTION
            WHEN OTHERS THEN
              fnd_file.put_line(FND_FILE.LOG, 'Strategy Level Rised Exception ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
    END;
    -- end for bug 8708271 multi level strategy
END IEX_STRATEGY_CNT_PUB;

/
