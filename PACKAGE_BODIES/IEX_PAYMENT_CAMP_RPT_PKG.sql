--------------------------------------------------------
--  DDL for Package Body IEX_PAYMENT_CAMP_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PAYMENT_CAMP_RPT_PKG" AS
/* $Header: iexpcmrb.pls 120.0.12010000.11 2009/08/20 09:48:19 barathsr noship $ */
  G_PKG_NAME VARCHAR2(100)         :='iex_payment_camp_rpt_pkg';
   G_LOG_ENABLED                   varchar2(5);
  G_MSG_LEVEL                     NUMBER;

  Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= G_MSG_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);

    end if;

    if FND_GLOBAL.Conc_Request_Id is not null then
        fnd_file.put_line(FND_FILE.LOG, p_msg);
    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;

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
  LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
  LOOP
    l_end := DBMS_LOB.INSTR (lob_loc => lob_loc, pattern => c_endline, offset => l_start, nth => 1 );
    FND_FILE.put_line( FND_FILE.LOG,'l_end-->'||l_end);
    IF (NVL (l_end, 0) < 1) THEN
      EXIT;
    END IF;
    l_one_line := DBMS_LOB.SUBSTR (lob_loc => lob_loc, amount => l_end - l_start, offset => l_start );
    FND_FILE.put_line( FND_FILE.LOG,'l_one_line-->'||l_one_line);
    FND_FILE.put_line( FND_FILE.LOG,'c_endline_len-->'||c_endline_len);
    l_start := l_end + c_endline_len;
    FND_FILE.put_line( FND_FILE.LOG,'l_start-->'||l_start);
    FND_FILE.put_line( FND_FILE.LOG,'32');
    Fnd_File.PUT_line(Fnd_File.OUTPUT,l_one_line);
  END LOOP;
END PRINT_CLOB;
PROCEDURE gen_xml_data_pcamp
  (
    ERRBUF OUT NOCOPY  VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    p_org_id in number,
    p_date_from    IN DATE,
    p_date_to      IN DATE,
    p_currency     IN VARCHAR2,
    p_campaign     IN VARCHAR2,
    p_collector    IN VARCHAR2,
    p_report_level IN VARCHAR2,
    p_summ_det     IN VARCHAR2,
    p_payment_type IN VARCHAR2,
    p_goal         IN VARCHAR2,
    p_goal_amount NUMBER )
                                IS
 l_api_name CONSTANT VARCHAR2(30) := 'gen_xml_data_pcamp';
  l_api_version CONSTANT NUMBER := 1.0;
  ctx DBMS_XMLQUERY.ctxType;
  result CLOB;
  qryCtx DBMS_XMLquery.ctxHandle;
  l_result CLOB;
  tempResult CLOB;
  l_where         VARCHAR2(8000):='';
  l_group_by      VARCHAR2(4000);
  l_order_by      VARCHAR2(4000);
  l_res_id        NUMBER;
  l_version       VARCHAR2(20);
  l_compatibility VARCHAR2(20);
  l_suffix        VARCHAR2(2);
  l_majorVersion  NUMBER;
  l_resultOffset  NUMBER;
  l_xml_header CLOB;--varchar2(4000);
  l_xml_header_length NUMBER;
  l_errNo             NUMBER;
  l_errMsg            VARCHAR2(200);
  queryCtx DBMS_XMLquery.ctxType;
  l_xml_query VARCHAR2(32767);
TYPE ref_cur IS   REF CURSOR;
    l_xml_stmt ref_cur;
    l_rows_processed NUMBER;
    l_new_line       VARCHAR2(1);
    l_close_tag      VARCHAR2(100);
    l_res_cnt        NUMBER;
    l_res_qry        VARCHAR2(5000);
    l_pro_status     VARCHAR2(20);
    l_pro_state      VARCHAR2(20);
    l_ctr_enbl_flg   VARCHAR2(1);
    l_base_op_curr   VARCHAR2(10);
    l_coll_rate      VARCHAR2(20);
    l_query      VARCHAR2(11000);
    l_org_id         VARCHAR2(100);
    l_hourly_goal    NUMBER;
    l_daily_goal     NUMBER;
    l_pay_typ_meaning varchar2(100);
    l_collector varchar2(200);
    l_campaign varchar2(200);
    l_sysdate date;
  BEGIN
    FND_FILE.put_line( FND_FILE.LOG,'*************start of the proc***************');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || '');
   --start of get filters

   if p_date_from is not null and p_date_to is not null then
      l_where:=l_where||'and trunc(p.creation_date) >=to_date('''||p_date_from||''',''DD-MON-RRRR'') ';
      l_where:=l_where||'and trunc(p.creation_date) <=to_date('''||p_date_to||''',''DD-MON-RRRR'')+1 ';
    end if;

    if p_org_id is not null then
      l_where:=l_where||' and d.org_id='||p_org_id;
       select name
	  into l_org_id
	  from hr_operating_units
	  where organization_id=p_org_id;
     else
	  l_org_id:='All';
    end if;


    select nvl(fnd_profile.value('IEX_COLLECTIONS_RATE_TYPE'),'N')
    into l_coll_rate
    from dual;

/*if l_coll_rate is null then
  select default_exchange_rate_type
  into l_coll_rate
  from ar_cmgt_setup_options;
end if;*/

if l_coll_rate is null then
  l_coll_rate:='Corporate';
end if;


     if  p_campaign is not null then
       select source_code
       into l_campaign
       from ams_source_codes
       where source_code_id=p_campaign;
	  FND_FILE.put_line( FND_FILE.LOG,'6');
	   l_where:=l_where||' and p.campaign_sched_id ='||p_campaign;
     else
	   l_where:=l_where||' and (p.campaign_sched_id in (Select source_code_id '||
 	                     'from  ams_source_codes '||
			     'where arc_source_code_for =''CAMP'') '||
 	                     'OR p.campaign_sched_id is NULL)';
     end if;

  IF p_collector IS NOT NULL THEN
    --  FND_FILE.put_line( FND_FILE.LOG,'4.5');
     select source_name
     into l_collector
     from jtf_rs_resource_extns
     where resource_id=p_collector;
    IF p_report_level='GROUP' THEN
      SELECT DISTINCT COUNT(resource_id)
         INTO l_res_cnt
         FROM JTF_RS_RESOURCE_EXTNS
        WHERE source_id IN
        ( SELECT DISTINCT b.person_id
           FROM jtf_rs_rep_managers b,
          JTF_RS_RESOURCE_EXTNS a
          WHERE b.manager_person_id = a.source_id
        AND a.resource_id           = p_collector
        );--100000937);
      IF l_res_cnt <> 0 THEN
        l_res_qry  := '(select distinct resource_id '||
	'from '|| 'JTF_RS_RESOURCE_EXTNS '||
	'where source_id in (select distinct b.person_id '||
	'from jtf_rs_rep_managers b, JTF_RS_RESOURCE_EXTNS a '||
	'where b.manager_person_id = a.source_id '|| 'and a.resource_id = '||p_collector;
        l_where    :=l_where||' and p.resource_id in '|| l_res_qry ;
        l_where    :=l_where||'))';
      ELSE
        FND_FILE.put_line( FND_FILE.LOG,'This Collector can see only promises assigned to him');
        l_where:=l_where||' and p.resource_id= '|| p_collector;
      END IF;
    ELSE
      --    FND_FILE.put_line( FND_FILE.LOG,'4.6');
      l_where:=l_where||' and p.resource_id= '|| p_collector;
    END IF;
  END IF;

  if p_collector is null then
   l_collector :=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  elsif p_campaign is null then
   l_campaign:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  end if;

  IF p_payment_type IS NOT NULL THEN
    --    FND_FILE.put_line( FND_FILE.LOG,'4.7');
    l_where:=l_where||' and l.lookup_code='''||p_payment_type||'''';
    select meaning
    into l_pay_typ_meaning
    from iex_lookups_v
    where lookup_type='IEX_PAYMENT_TYPES'
    and lookup_code=p_payment_type;
     else
      l_pay_typ_meaning:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  END IF;
  --end of get filters
  --report mode DETAIL
  IF p_summ_det    = 'DETAIL' THEN

      l_query := 'SELECT l.meaning payment_method,p.ipayment_status payment_status,c.source_code,p.campaign_sched_id campaign_schedule_id ,'||
      'c.source_code,to_char(p.creation_date,''DD-Mon-YYYY'') payment_date,gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount) amount,'||
      'p.payment_id,d.delinquency_id,p.resource_id,j.source_name collector,hca.account_number,s.trx_number invoice_id,d.payment_schedule_id,s.class,'||
      'gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',s.amount_due_remaining) amount_due_remaining,'||
      'gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',s.amount_due_original) amount_due_original,'||
      'r.currency_code currency_code,l.lookup_code payment_method_lookup_code '||
      'FROM iex_delinquencies d,'|| 'iex_payments p,'||
      'ar_payment_schedules_all s,'|| 'iex_del_pay_xref xdp,'|| 'ams_source_codes c,'|| 'jtf_rs_resource_extns j,'|| 'iex_pay_receipt_xref xpr,'||'ar_cash_receipts_all r,'||
      'iex_lookups_v l,hz_cust_accounts hca,ar_system_parameters asp '||
      'WHERE xdp.payment_id = p.payment_id '|| 'AND xdp.DELINQUENCY_ID= d.DELINQUENCY_ID '|| 'AND d.payment_schedule_id = s.payment_schedule_id '||
      'AND c.source_code_id(+)   = p.campaign_sched_id '|| 'AND p.resource_id         = j.resource_id(+) '|| 'AND hca.cust_account_id=d.cust_account_id '||
      'AND p.payment_id          = xpr.payment_id '||      'AND r.cash_receipt_id     = xpr.cash_receipt_id and d.org_id=asp.org_id '||
      'AND l.lookup_type         = ''IEX_PAYMENT_TYPES'' '|| 'AND p.payment_method      = l.lookup_code '||'and s.class=''INV'' ';

    l_order_by :=' order by d.cust_account_id,p.payment_id';
    l_query:=l_query||l_where;
    l_query:=l_query||l_order_by;
    FND_FILE.put_line( FND_FILE.LOG,'qry-->'||l_query);
    ctx := DBMS_XMLQUERY.newContext(l_query);
    --FND_FILE.put_line( FND_FILE.LOG,'21');
  END IF;
  --report mode SUMMARY
  IF p_summ_det          = 'SUMMARY' THEN
    IF p_goal           IS NOT NULL THEN
      IF (p_goal_amount IS NOT NULL AND p_goal_amount >0) THEN
        --  FND_FILE.put_line( FND_FILE.LOG,'4.8');
        FND_FILE.put_line( FND_FILE.LOG,'hourly-->'||p_goal);
        IF p_goal       ='HOURLY' THEN
          l_hourly_goal:=round(p_goal_amount);
          l_daily_goal :=round(p_goal_amount*8); --default 8 hours per day
          FND_FILE.put_line( FND_FILE.LOG,'l_hourly_goal1-->'||l_hourly_goal);
        ELSE
          l_hourly_goal:=round(p_goal_amount/8);
          l_daily_goal :=round(p_goal_amount);
          FND_FILE.put_line( FND_FILE.LOG,'l_hourly_goal2-->'||l_hourly_goal);
        END IF;
      ELSE
        FND_FILE.put_line( FND_FILE.LOG,'Goal Amount cannot be null or negative');
      END IF;
    END IF;

      --FND_FILE.put_line( FND_FILE.LOG,'5');
      l_query:='SELECT c.source_code Campaign,j.source_name Collector,'||
      'SUM(gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount)) Total_Amount_Collected,'||
      'ROUND((SUM(gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount))/((to_date('''||p_date_to||
      ''',''DD-MON-RRRR'')-to_date('''||p_date_from||''',''DD-MON-RRRR''))+1))/8,2) Hourly_Average,'||l_hourly_goal||' Hourly_Goal,'||
      'ROUND(((((SUM(gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount))/((to_date('''||p_date_to||
      ''',''DD-MON-RRRR'')-to_date('''||p_date_from||''',''DD-MON-RRRR''))+1))/8)/'||l_hourly_goal||') *100),2) percent_hourly_avr,'||
      'ROUND((SUM(gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount))/((to_date('''||p_date_to||
      ''',''DD-MON-RRRR'')-to_date('''||p_date_from||''',''DD-MON-RRRR''))+1)),2) Daily_Average,'|| l_daily_goal||' Daily_Goal,'||
      'ROUND((((SUM(gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount))/((to_date('''||p_date_to||
      ''',''DD-MON-RRRR'')-to_date('''||p_date_from||''',''DD-MON-RRRR''))+1))/'||l_daily_goal||') *100),2) percent_daily_avr,'||
      'COUNT(DISTINCT(p.payment_id)) Payments,'||
      'ROUND(SUM(gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount))/COUNT(DISTINCT(p.payment_id)),2) Average_Payment,'||
      'COUNT(DISTINCT(d.transaction_id)) Invoices,'||
      'ROUND(SUM(gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount))/COUNT(DISTINCT(d.transaction_id)),2) Average_Invoices,'||
      'COUNT(DISTINCT(d.cust_account_id)) Accounts,'||
      'ROUND(SUM(gl_currency_api.convert_amount(r.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',r.amount))/COUNT(DISTINCT(d.cust_account_id)),2) Average_Account '||
      'FROM '|| 'iex_delinquencies d,iex_payments p, ar_payment_schedules_all s , iex_del_pay_xref xdp,'||
      'ams_source_codes c,jtf_rs_resource_extns j,iex_pay_receipt_xref xpr,ar_cash_receipts_all r,'|| 'iex_lookups_v l,ar_system_parameters asp '||
      'WHERE xdp.payment_id      = p.payment_id '|| 'AND xdp.DELINQUENCY_ID      = d.DELINQUENCY_ID '|| 'AND d.payment_schedule_id   = s.payment_schedule_id '||
      'AND c.source_code_id(+)     = p.campaign_sched_id '|| 'AND p.resource_id = j.resource_id(+) '|| 'AND p.payment_id = xpr.payment_id and d.org_id = asp.org_id '||
      'AND r.cash_receipt_id       = xpr.cash_receipt_id '|| 'AND l.lookup_type           = ''IEX_PAYMENT_TYPES'' '|| 'AND p.payment_method        = l.lookup_code '||
      'AND s.class                 =''INV'' ';

    l_group_by  :=' group by c.source_code,j.source_name';
    l_query:=l_query||l_where;
    l_query:=l_query||l_group_by;
    --call procedure to calculate pmt_cnt and pmt_amt
    FND_FILE.put_line( FND_FILE.LOG,'l_query_summ-->'||l_query);
    ctx := DBMS_XMLQUERY.newContext(l_query);
    FND_FILE.put_line( FND_FILE.LOG,'7.5');
  END IF;
  DBMS_XMLQUERY.setRaiseNoRowsException(ctx,TRUE);

  -- Bind Mandatory Variables
 -- DBMS_XMLQUERY.setBindValue(ctx, 'p_date_from', p_date_from);
 -- DBMS_XMLQUERY.setBindValue(ctx, 'p_date_to', p_date_to);

  --get the result
  BEGIN
    l_result := DBMS_XMLQUERY.getXML(ctx);
    DBMS_XMLQUERY.closeContext(ctx);
    l_rows_processed := 1;
    FND_FILE.put_line( FND_FILE.LOG,'l_res_len-->'||dbms_lob.getlength(l_result));
    --FND_FILE.put_line( FND_FILE.LOG,'l_res-->'||l_result);
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_XMLQUERY.getExceptionContent(ctx,l_errNo,l_errMsg);
    FND_FILE.put_line( FND_FILE.LOG,'l_errMsg-->'||l_errMsg);
    IF l_errNo          = 1403 THEN
      l_rows_processed := 0;
    END IF;
    DBMS_XMLQUERY.closeContext(ctx);
  END;
  IF l_rows_processed <> 0 THEN
    FND_FILE.put_line( FND_FILE.LOG,'8') ;

    --get the length of the rowset header
    l_resultOffset := DBMS_LOB.INSTR(l_result,'>');
    FND_FILE.put_line( FND_FILE.LOG,'l_res_off-->'||l_resultOffset) ;
  ELSE
    l_resultOffset := 0;
  END IF;

  select trunc(sysdate)
  into l_sysdate
  from dual;

  l_new_line := '
';
  FND_FILE.put_line( FND_FILE.LOG,'10') ;
  /* Prepare the tag for the report heading */
  l_xml_header   := '<?xml version="1.0" encoding="UTF-8"?>';
  l_xml_header   := l_xml_header ||l_new_line||'<PAYCOLLECTOR>';
  l_xml_header   := l_xml_header ||l_new_line||' <PARAMETERS>';
  l_xml_header   := l_xml_header ||l_new_line||' <P_DATE_FROM>'||p_date_from||'</P_DATE_FROM>';
  l_xml_header   := l_xml_header ||l_new_line||' <P_DATE_TO>' ||p_date_to ||'</P_DATE_TO>';
  l_xml_header   := l_xml_header ||l_new_line||' <P_CURRENCY>' ||p_currency||'</P_CURRENCY>';
   l_xml_header   := l_xml_header ||l_new_line||' <P_CAMPAIGN>' ||l_campaign ||'</P_CAMPAIGN>';
  l_xml_header   := l_xml_header ||l_new_line||' <P_COLLECTOR>' ||l_collector ||'</P_COLLECTOR>';
  l_xml_header   := l_xml_header ||l_new_line||' <P_REPORT_LEVEL>' ||iex_utilities.get_lookup_meaning('IEX_REPORT_LEVEL',p_report_level)||'</P_REPORT_LEVEL>';
  l_xml_header   := l_xml_header ||l_new_line||' <P_REPORT_TYPE>' ||iex_utilities.get_lookup_meaning('IEX_REPORT_MODE',p_summ_det)||'</P_REPORT_TYPE>';
  l_xml_header   := l_xml_header ||l_new_line||' <P_PAYMENT_TYPE>' ||l_pay_typ_meaning||'</P_PAYMENT_TYPE>';
  IF p_summ_det   ='SUMMARY' THEN
    l_xml_header := l_xml_header ||l_new_line||' <P_GOAL>' ||iex_utilities.get_lookup_meaning('IEX_GOAL_TYPES',p_goal)||'</P_GOAL>';
    l_xml_header := l_xml_header ||l_new_line||' <P_GOAL_AMOUNT>' ||p_goal_amount||'</P_GOAL_AMOUNT>';
  END IF;
  l_xml_header   := l_xml_header ||l_new_line||' <P_ORG_ID>' ||l_org_id||'</P_ORG_ID>';
   l_xml_header      := l_xml_header ||l_new_line||' <CURR_DATE>' ||l_sysdate||'</CURR_DATE>';
    l_xml_header    := l_xml_header ||l_new_line||' <DATA_FOUND>' ||l_rows_processed||'</DATA_FOUND>';
   l_xml_header        := l_xml_header ||l_new_line||' </PARAMETERS>';
  l_close_tag         := l_new_line||'</PAYCOLLECTOR>'||l_new_line;
  l_xml_header_length := dbms_lob.getlength(l_xml_header);
  tempResult          :=l_xml_header;
  FND_FILE.put_line( FND_FILE.LOG,'tempRes0-->'||tempResult);
  IF l_rows_processed <> 0 THEN
    --copy result set to tempResult
    dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset, l_xml_header_length,l_resultOffset);
  FND_FILE.put_line( FND_FILE.LOG,'11') ;
  --  FND_FILE.put_line( FND_FILE.LOG,'tempRes1-->'||tempResult);
  ELSE
  FND_FILE.put_line( FND_FILE.LOG,'12') ;
    dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
    dbms_lob.writeAppend(tempResult, LENGTH(l_xml_header), l_xml_header);
  END IF;

  --append the close tag to tempResult
  dbms_lob.writeAppend(tempResult, LENGTH(l_close_tag), l_close_tag);
--  FND_FILE.put_line( FND_FILE.LOG,'tempRes2-->'||tempResult);
  --print to the o/p file
  print_clob(lob_loc => tempResult);
  FND_FILE.put_line( FND_FILE.LOG,'15--end') ;
  LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || '-end');
EXCEPTION
WHEN OTHERS THEN
 -- dbms_output.put_line('err'||sqlerrm);
  LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' -');
END gen_xml_data_pcamp;
BEGIN
   G_LOG_ENABLED := 'N';
   G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;

   /* getting msg logging info */
   G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
   if (G_LOG_ENABLED = 'N') then
      G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
   else
      G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
   end if;

   LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);

END;

/
