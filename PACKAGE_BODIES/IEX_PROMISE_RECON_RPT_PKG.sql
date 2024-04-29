--------------------------------------------------------
--  DDL for Package Body IEX_PROMISE_RECON_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PROMISE_RECON_RPT_PKG" as
/* $Header: iexprcrb.pls 120.0.12010000.10 2009/10/28 16:27:35 barathsr noship $ */

G_PKG_NAME varchar2(100):='iex_promise_recon_rpt_pkg';
--l_api_name              CONSTANT VARCHAR2(30) := 'Promise Reconciliation';

l_res_hash l_res_hash_type;
l_pmt_cnt l_pmt_cnt_type;
l_pmt_amt l_pmt_amt_type;
g_base_curr varchar2(10) default null;
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


PROCEDURE PRINT_CLOB (lob_loc                in  clob) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name                      CONSTANT VARCHAR2(30) := 'PRINT_CLOB';
   l_api_version                   CONSTANT NUMBER := 1.0;
   c_endline                       CONSTANT VARCHAR2 (1) := '
';
   c_endline_len                   CONSTANT NUMBER       := LENGTH (c_endline);
   l_start                         NUMBER          := 1;
   l_end                           NUMBER;
   l_one_line                      VARCHAR2 (7000);
   l_charset	                   VARCHAR2(100);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   LOOP
      l_end :=
            DBMS_LOB.INSTR (lob_loc      => lob_loc,
                            pattern      => c_endline,
                            offset       => l_start,
                            nth          => 1
                           );

			   FND_FILE.put_line( FND_FILE.LOG,'l_end-->'||l_end);


      IF (NVL (l_end, 0) < 1)
      THEN
         EXIT;
      END IF;

      l_one_line :=
            DBMS_LOB.SUBSTR (lob_loc      => lob_loc,
                             amount       => l_end - l_start,
                             offset       => l_start
                            );
			    FND_FILE.put_line( FND_FILE.LOG,'l_one_line-->'||l_one_line);
			   FND_FILE.put_line( FND_FILE.LOG,'c_endline_len-->'||c_endline_len);
      l_start := l_end + c_endline_len;
      FND_FILE.put_line( FND_FILE.LOG,'l_start-->'||l_start);
      FND_FILE.put_line( FND_FILE.LOG,'32');
      Fnd_File.PUT_line(Fnd_File.OUTPUT,l_one_line);

   END LOOP;

END PRINT_CLOB;


Procedure gen_xml_data(ERRBUF                  OUT NOCOPY VARCHAR2,
                       RETCODE                 OUT NOCOPY VARCHAR2,
		       p_org_id in number,
		       p_date_from in date,
		       p_date_to in date,
		       p_currency in varchar2,
		       p_pro_state in varchar2,
		       p_pro_status in varchar2,
		       p_summ_det in varchar2,
		       p_group_by in varchar2,
		       p_group_by_mode in varchar2,
		       p_group_by_coll_dumm in varchar2 default null,
		       p_group_by_value_coll in varchar2 default null,
		       p_group_by_sch_dumm in varchar2 default null,
                       p_group_by_value_sch in varchar2 default null
		       )
 is
   l_api_name              CONSTANT VARCHAR2(30) := 'gen_xml_data';
   l_api_version           CONSTANT NUMBER := 1.0;
   ctx                     DBMS_XMLQUERY.ctxType;
   result                  CLOB;
   qryCtx                  DBMS_XMLQUERY.ctxHandle;
   l_result                CLOB;
   tempResult              CLOB;
   l_where varchar2(8000):='';
   l_group_by varchar2(4000);
   l_order_by varchar2(4000);
   l_res_id number;
   l_version               varchar2(20);
   l_compatibility         varchar2(20);
   l_suffix                varchar2(2);
   l_majorVersion          number;
  l_resultOffset          number;
   l_xml_header            clob;
   l_xml_header_length     number;
   l_errNo                 NUMBER;
   l_errMsg                VARCHAR2(200);
   queryCtx                DBMS_XMLquery.ctxType;
   l_xml_query             VARCHAR2(32767);
   TYPE ref_cur IS REF CURSOR;
   l_xml_stmt              ref_cur;
   l_rows_processed        NUMBER;
   l_new_line              VARCHAR2(1);
   l_close_tag             VARCHAR2(100);
    l_res_cnt number;
   l_res_qry varchar2(5000);
    l_pro_status varchar2(20);
     l_pro_state varchar2(20);
     l_ctr_enbl_flg varchar2(1);
     l_coll_rate varchar2(20);
 l_query varchar2(11000);
 l_org_id varchar2(100);
 l_no_data_flag number;
 l_collector varchar2(200);
 l_campaign varchar2(200);
 l_sysdate date;

begin

LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

 if p_date_from is not null and p_date_to is not null then
   l_where:=l_where||' and ipd1.promise_date between(to_date('''||p_date_from||''', ''DD-MON-RR'')) and (to_date('''||p_date_to||''',''DD-MON-RR''))';
  end if;

select NVL(FND_PROFILE.value('IEX_LEASE_ENABLED'), 'N')
into l_ctr_enbl_flg
from dual;

if l_ctr_enbl_flg='N' then
l_where :=l_where||' and ipd1.contract_id is null';
else
l_where :=l_where||' and ipd1.contract_id is not null';
end if;

select nvl(fnd_profile.value('IEX_COLLECTIONS_RATE_TYPE'),'N')
into l_coll_rate
from dual;

if l_coll_rate is null then
  l_coll_rate:='Corporate';
end if;

if p_org_id is not null then
  l_where:=l_where||' and ipd1.org_id='||p_org_id;
  select name
  into l_org_id
  from hr_operating_units
  where organization_id=p_org_id;
else
  l_org_id:='All';
end if;

 if p_pro_status is null then
  l_pro_status:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  FND_FILE.put_line( FND_FILE.LOG,'2.5');
  null;
  else
  FND_FILE.put_line( FND_FILE.LOG,'3');
 -- l_pro_status:=p_pro_status;
   l_where:=l_where||' and ipd1.status='''||p_pro_status||'''';
   select meaning
   into l_pro_status
   from iex_lookups_v
   where lookup_code=p_pro_status
   and lookup_type='IEX_PROMISE_STATUSES';
 end if;

 if p_pro_state is null then
  l_pro_state:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
   FND_FILE.put_line( FND_FILE.LOG,'3.5');
 null;
 else
 FND_FILE.put_line( FND_FILE.LOG,'4');
-- l_pro_state:=p_pro_state;
 l_where:=l_where||' and ipd1.state='''||p_pro_state||'''';
 select meaning
 into l_pro_state
 from iex_lookups_v
 where lookup_code=p_pro_state
 and lookup_type='IEX_PROMISE_STATES';
 end if;

  if p_group_by='COLLECTOR' then
   FND_FILE.put_line( FND_FILE.LOG,'4.5');
    if p_group_by_value_coll is not null then
       select source_name
       into l_collector
       from jtf_rs_resource_extns
       where resource_id=p_group_by_value_coll;

     if p_group_by_mode='GROUP' then
       select distinct count(resource_id)
       into l_res_cnt
       from
       JTF_RS_RESOURCE_EXTNS
       where source_id in ( select distinct b.person_id
       from jtf_rs_rep_managers b, JTF_RS_RESOURCE_EXTNS a
       where b.manager_person_id = a.source_id
       and a.resource_id = p_group_by_value_coll);--100000937);

       if l_res_cnt <> 0 then
       l_res_qry:= '(select distinct resource_id '||
                    'from '||
                    'JTF_RS_RESOURCE_EXTNS '||
		    'where source_id in (select distinct b.person_id '||
                    'from jtf_rs_rep_managers b, JTF_RS_RESOURCE_EXTNS a '||
		    'where b.manager_person_id = a.source_id '||
		    'and a.resource_id = '||p_group_by_value_coll;

         l_where:=l_where||' and ipd1.resource_id in '|| l_res_qry ;
	 l_where:=l_where||'))';
	 else
	  FND_FILE.put_line( FND_FILE.LOG,'This Collector can see only promises assigned to him');
          l_where:=l_where||' and ipd1.resource_id= '|| p_group_by_value_coll;
	end if;
       else
       FND_FILE.put_line( FND_FILE.LOG,'4.6');
	  l_where:=l_where||' and ipd1.resource_id= '|| p_group_by_value_coll;
       end if;
       end if;
       end if;

        if  p_group_by='SCHEDULE' then
	   FND_FILE.put_line( FND_FILE.LOG,'5');
	  if  p_group_by_value_sch is not null then
	    select source_code
	    into l_campaign
	    from ams_source_codes
	    where source_code_id=p_group_by_value_sch;


	  FND_FILE.put_line( FND_FILE.LOG,'6');
	   l_where:=l_where||' and ipd1.campaign_sched_id ='||p_group_by_value_sch;
	  end if;
	 end if;
	   l_where:=l_where||' and (ipd1.campaign_sched_id in (Select source_code_id '||
 	                     'from  ams_source_codes '||
 	                      'where arc_source_code_for =''CAMP'') '||
                              'OR IPD1.campaign_sched_id is NULL)';

	-- FND_FILE.put_line( FND_FILE.LOG,'base_curr'||g_base_curr);

--end of get filters

if p_group_by_value_coll is null then
  l_collector:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
end if;
if p_group_by_value_sch is null then
  l_campaign:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
end if;

--group_by
  if p_group_by='SCHEDULE' then
   l_group_by:= ' group by amsc.source_code_id,amsc.source_code,jrev.resource_id,jrev.resource_name)';
  else
   l_group_by:=' group by jrev.resource_id,jrev.resource_name,amsc.source_code_id,amsc.source_code)';
  end if;

 --report mode DETAIL
  --For Bug 9054660 28-Oct-2009 barathsr..
 --1)Modified the filter clause by removing the ipax.reversed_flag check to see promises of reversed payments.
 --2)Used decode for payment related columns to void the payment details for reversed payments.

  if p_summ_det = 'DETAIL' then
   l_query:=
 'select '||
 'resource_id,'||
 'resource_name,'||
 'source_code_id,'||
 'source_code,'||
 'account_number,'||
 'invoice,'||
 'installment_number,'||
 'promise_status,'||
 'p_amt,'||
 'p_itemno,'||
 'p_origdt,'||
 'p_exp_pmtdt,'||
 'remaining_balance,'||
 'pmt_dt,'||
 'pmt_amt,'||
 'pmt_type,'||
 'pmt_itemno,'||
 'currency,'||
 'promise_detail_id,'||
 'promise_state '||
 'from (select jrev.resource_id resource_id,'||
 'jrev.resource_name resource_name, amsc.source_code_id source_code_id,amsc.source_code source_code,'||
 'hca.account_number account_number, aps.trx_number invoice, aps.terms_sequence_number installment_number,'||
 'iex_utilities.get_lookup_meaning(''IEX_PROMISE_STATUSES'',ipd1.status) promise_status,'||
 'gl_currency_api.convert_amount(ipd1.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',ipd1.promise_amount) p_amt,'||
 'ipd1.promise_item_number p_itemno,to_char(ipd1.creation_date,''DD-Mon-RRRR'')p_origdt, to_char(ipd1.promise_date,''DD-Mon-RRRR'')p_exp_pmtdt,'||
 'gl_currency_api.convert_amount(ipd1.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',ipd1.amount_due_remaining) remaining_balance,'||
 'decode(nvl(ipax.reversed_flag,''N''),''N'',to_char(ara.apply_date,''DD-Mon-RRRR''),null)pmt_dt,'||
 'decode(nvl(ipax.reversed_flag,''N''),''N'',gl_currency_api.convert_amount(ipd1.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',ipax.amount_applied),null)pmt_amt,'||
 'decode(nvl(ipax.reversed_flag,''N''),''N'',acr.payment_method_dsp,null) pmt_type, decode(nvl(ipax.reversed_flag,''N''),''N'',acr.receipt_number,null) pmt_itemno,'||
 'ipd1.currency_code currency, ipd1.promise_detail_id promise_detail_id,'||
 'iex_utilities.get_lookup_meaning(''IEX_PROMISE_STATES'',ipd1.state) promise_state '||
 'from '||
 'iex_promise_details ipd1, ams_source_codes amsc, ar_cash_receipts_v acr, iex_prd_appl_xref ipax,'||
 'ar_receivable_applications ara, hz_cust_accounts hca, jtf_rs_resource_extns_vl jrev, iex_delinquencies id, ar_payment_schedules aps,ar_system_parameters asp '||
 ' where '||
 'ipd1.promise_detail_id=ipax.promise_detail_id(+) and ipax.receivable_application_id=ara.receivable_application_id(+) '||
 'and ara.cash_receipt_id=acr.cash_receipt_id(+) '||
 'and aps.payment_schedule_id(+)=id.payment_schedule_id and jrev.resource_id(+)=ipd1.resource_id and ipd1.org_id=asp.org_id '||
 'and amsc.source_code_id(+)=ipd1.campaign_sched_id '||
 'and ipd1.cust_account_id=hca.cust_account_id '||
 'and id.delinquency_id(+)=ipd1.delinquency_id ';


l_order_by:=' order by ipd1.promise_detail_id,jrev.resource_name,amsc.source_code,ipd1.cust_account_id,ipd1.promise_amount)';
l_query:=l_query||l_where;
l_query:=l_query||l_order_by;
FND_FILE.put_line( FND_FILE.LOG,'qry-->'||l_query);
 ctx := DBMS_XMLQUERY.newContext(l_query);
end if;

--report mode SUMMARY
if p_summ_det = 'SUMMARY' then
    l_query:='select '||
 'source_code_id,'||
 'source_code,'||
 'resource_id,'||
 'resource_name,'||
 'ptp_count,'||
 'ptp_amt,'||
 'pmt_count,'||
 'pmt_amt,'||
 'broken_count,'||
 'broken_amt,'||
 'open_count,'||
 'open_amt '||
 'from '||
 '(select amsc.source_code_id source_code_id,'||
 'amsc.source_code source_code,'||
 'jrev.resource_id resource_id, jrev.resource_name resource_name,'||
 'count(ipd1.promise_detail_id) ptp_count,'||
 'sum(gl_currency_api.convert_amount(ipd1.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',ipd1.promise_amount))ptp_amt,'||
 'iex_promise_recon_rpt_pkg.get_pmt_count(jrev.resource_id,amsc.source_code_id) pmt_count,'||
 'iex_promise_recon_rpt_pkg.get_pmt_amount(jrev.resource_id,amsc.source_code_id) pmt_amt,'||
 'sum(decode(ipd1.state,''BROKEN_PROMISE'',1,0))broken_count,'||
 'sum(decode(ipd1.state,''BROKEN_PROMISE'',gl_currency_api.convert_amount(ipd1.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',ipd1.promise_amount),0))broken_amt,'||
 'sum(decode(ipd1.state,''PROMISE'',1,0))open_count,'||
 'sum(decode(ipd1.state,''PROMISE'',gl_currency_api.convert_amount(ipd1.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',ipd1.promise_amount),0))open_amt '||
 'from '||
 'iex_promise_details ipd1,jtf_rs_resource_extns_vl jrev,ar_system_parameters asp,'||
 'ams_source_codes amsc,hz_cust_accounts hzca '||
 'where jrev.resource_id(+)=ipd1.resource_id '||
 'and amsc.source_code_id(+)=ipd1.campaign_sched_id '||
 'and ipd1.cust_account_id=hzca.cust_account_id and ipd1.org_id=asp.org_id ';


l_query:=l_query||l_where;
l_query:=l_query||l_group_by;

--call procedure to calculate pmt_cnt and pmt_amt

   calc_pmt_amt_cnt(p_org_id,p_date_from,p_date_to,p_currency,p_pro_state,p_pro_status,
                  p_group_by,p_group_by_mode,p_group_by_value_coll,p_group_by_value_sch);
-- end if;

FND_FILE.put_line( FND_FILE.LOG,'l_query_summ-->'||l_query);
ctx := DBMS_XMLQUERY.newContext(l_query);
 FND_FILE.put_line( FND_FILE.LOG,'7.5');
end if;

 DBMS_XMLQUERY.setRaiseNoRowsException(ctx,TRUE);

    -- Bind Mandatory Variables
    -- DBMS_XMLQUERY.setBindValue(ctx, 'p_date_from', p_date_from);
  --   DBMS_XMLQUERY.setBindValue(ctx, 'p_date_to', p_date_to);
   -- DBMS_XMLQUERY.setBindValue(ctx, 'p_currency', p_currency);
   --  DBMS_XMLQUERY.setBindValue(ctx, 'p_currency1', p_currency);
   --   DBMS_XMLQUERY.setBindValue(ctx, 'p_currency2', p_currency);
     --    DBMS_XMLQUERY.setBindValue(ctx, 'p_pro_status', p_pro_status);

  --get the result
    BEGIN
       l_result := DBMS_XMLQUERY.getXML(ctx);
	DBMS_XMLQUERY.closeContext(ctx);
	l_rows_processed := 1;

     EXCEPTION
     WHEN OTHERS THEN
        DBMS_XMLQUERY.getExceptionContent(ctx,l_errNo,l_errMsg);
	IF l_errNo = 1403 THEN
           l_rows_processed := 0;
	   --l_no_data_flag:=0;
        END IF;
        DBMS_XMLQUERY.closeContext(ctx);
     END;

    IF l_rows_processed <> 0 THEN
     FND_FILE.put_line( FND_FILE.LOG,'8') ;
     --get the length og the rowset header
         l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
     	 FND_FILE.put_line( FND_FILE.LOG,'9') ;
    ELSE
         l_resultOffset   := 0;
    END IF;

    select trunc(sysdate)
    into l_sysdate
    from dual;

      l_new_line := '
';
      FND_FILE.put_line( FND_FILE.LOG,'10') ;
      /* Prepare the tag for the report heading */
   l_xml_header     := '<?xml version="1.0" encoding="UTF-8"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<PROMRECONCILIATION>';
   l_xml_header     := l_xml_header ||l_new_line||'    <PARAMETERS>'||l_new_line;
   l_xml_header     := l_xml_header ||l_new_line||'        <P_DATE_FROM>'||p_date_from||'</P_DATE_FROM>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_DATE_TO>' ||p_date_to ||'</P_DATE_TO>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_CURRENCY>' ||p_currency||'</P_CURRENCY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_PRO_STATE>' ||l_pro_state ||'</P_PRO_STATE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_PRO_STATUS>' ||l_pro_status||'</P_PRO_STATUS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_REPORT_TYPE>' ||iex_utilities.get_lookup_meaning('IEX_REPORT_MODE',p_summ_det)||'</P_REPORT_TYPE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_GROUP_BY>' ||iex_utilities.get_lookup_meaning('IEX_REP_COLL_SCH',p_group_by)||'</P_GROUP_BY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_REPORT_LEVEL>' ||iex_utilities.get_lookup_meaning('IEX_REPORT_LEVEL',p_group_by_mode)||'</P_REPORT_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_COLLECTOR>' ||l_collector||'</P_COLLECTOR>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_CAMPAIGN>' ||l_campaign||'</P_CAMPAIGN>';
   l_xml_header     := l_xml_header ||l_new_line||'        <P_ORG_ID>' ||l_org_id||'</P_ORG_ID>';
   l_xml_header     := l_xml_header ||l_new_line||'        <DATA_FOUND>' ||l_rows_processed||'</DATA_FOUND>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CURR_DATE>' ||l_sysdate||'</CURR_DATE>';
   l_xml_header     := l_xml_header ||l_new_line||'    </PARAMETERS>';
   l_close_tag      := l_new_line||'</PROMRECONCILIATION>'||l_new_line;

   l_xml_header_length := dbms_lob.getlength(l_xml_header);
   tempResult:=l_xml_header;

    IF l_rows_processed <> 0 THEN
    --copy result set to tempResult
     dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
                l_xml_header_length,l_resultOffset);

    ELSE

      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
    END IF;

     FND_FILE.put_line( FND_FILE.LOG,'5.base_curr'||g_base_curr);
--append the close tag to tempResult
  dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
  --print to the o/p file
  print_clob(lob_loc => tempResult);
  FND_FILE.put_line( FND_FILE.LOG,'15--end') ;
  LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +end');

EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.put_line( FND_FILE.LOG,'err-->'||sqlerrm);
 LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || '-'||sqlerrm);
  END gen_xml_data;

--Procedure to calculate Payment count and Payment amount
Procedure calc_pmt_amt_cnt(p_org_id in number,
                           p_date_from in date,
		           p_date_to in date,
		           p_currency in varchar2,
		           p_pro_state in varchar2,
		           p_pro_status in varchar2,
                           p_group_by in varchar2,
		           p_group_by_mode in varchar2,
                           p_group_by_value_coll in varchar2 default null,
                           p_group_by_value_sch in varchar2 default null
			  		          )
is
l_temp_resource_id number;
l_temp_source_code_id number;
l_temp_pmt_count number;
l_temp_pmt_amount number;
l_ctr_enbl_flg varchar2(1);
l_curr varchar2(10) default null;
TYPE pmtcnt IS REF CURSOR;
pmtdet pmtcnt;
l_pmt_sum varchar2(10000);
l_resr_cnt number;
l_resr_qry varchar2(10000);
l_where varchar2(9000):='';
l_group_by varchar2(1000);
l_coll_rate varchar2(50);
l_api_name  CONSTANT VARCHAR2(30) := 'calc_pmt_amt_cnt';
l_resource_char varchar2(100);
 l_source_code_char varchar2(100);
 l_hash_value number;
begin
LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    FND_FILE.put_line( FND_FILE.LOG,'*****Start of pmt_amt_cnt procedure***********') ;


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


select NVL(FND_PROFILE.value('IEX_LEASE_ENABLED'), 'N')
into l_ctr_enbl_flg
from dual;

if l_ctr_enbl_flg='N' then
 FND_FILE.put_line( FND_FILE.LOG,'20') ;

l_where :=l_where||' and ipd1.contract_id is null';
else
l_where :=l_where||' and ipd1.contract_id is not null';
end if;

if p_org_id is not null then
   l_where :=l_where||' and ipd1.org_id='||p_org_id;
end if;


  if p_date_from is not null and p_date_to is not null then
  FND_FILE.put_line( FND_FILE.LOG,'21');
    l_where:=l_where||' and ipd1.promise_date between(to_date('''||p_date_from||''', ''DD-MON-RR'')) and (to_date('''||p_date_to||''',''DD-MON-RR''))';
  end if;

 l_pmt_sum:='select source_code_id,resource_id,pmt_count, pmt_amount from '||
                             '(select amsc.source_code_id,jrev.resource_id resource_id,count(unique arra.cash_receipt_id) pmt_count ,'||
                             'sum(decode(arra.cash_receipt_id, null,0,gl_currency_api.convert_amount(ipd1.currency_code,'''||p_currency||''',sysdate,'''||l_coll_rate||''',prdapplx.amount_applied)))pmt_amount '||
                            'FROM  IEX_PROMISE_DETAILS IPD1 , JTF_RS_RESOURCE_EXTNS_VL JREV , AMS_SOURCE_CODES AMSC , iex_prd_appl_xref PRDAPPLX , ar_receivable_applications  ARRA , hz_cust_accounts HZCA,ar_system_parameters asp '||
                            'WHERE  JREV.resource_id(+) = IPD1.resource_id '||
                             'AND AMSC.source_code_id(+) = IPD1.campaign_sched_id '||
                             'and IPD1.cust_account_id  = HZCA.cust_account_id and ipd1.org_id=asp.org_id '||
                             'and nvl(PRDAPPLX.reversed_flag,''N'') <> ''Y'' '||
                             'and IPD1.promise_detail_id =  PRDAPPLX.promise_detail_id (+) '||
                             'and PRDAPPLX.receivable_application_id =  ARRA.receivable_application_id(+) ';

  if p_pro_state is not null then
   l_where:=l_where||' and ipd1.state='''||p_pro_state||'''';
  end if;

  if p_pro_status is not null then
   l_where:=l_where||' and ipd1.status='''||p_pro_status||'''';
  end if;

 if p_group_by='COLLECTOR' then
   FND_FILE.put_line( FND_FILE.LOG,'23');
     if p_group_by_mode='GROUP' then
     FND_FILE.put_line( FND_FILE.LOG,'24');
     begin
       select count(distinct(resource_id))
       into l_resr_cnt
       from
       JTF_RS_RESOURCE_EXTNS
       where source_id in ( select distinct b.person_id
       from jtf_rs_rep_managers b, JTF_RS_RESOURCE_EXTNS a
       where b.manager_person_id = a.source_id
       and a.resource_id = p_group_by_value_coll);--100000937);

       if l_resr_cnt <> 0 then
       l_resr_qry:= '(select distinct resource_id '||
                    'from '||
                    'JTF_RS_RESOURCE_EXTNS '||
		    'where source_id in (select distinct b.person_id '||
                    'from jtf_rs_rep_managers b, JTF_RS_RESOURCE_EXTNS a '||
		    'where b.manager_person_id = a.source_id '||
		    'and a.resource_id = '||p_group_by_value_coll;

         l_where:=l_where||' and ipd1.resource_id in '|| l_resr_qry ;
	 l_where:=l_where||'))';
	 else
	  FND_FILE.put_line( FND_FILE.LOG,'This Collector can see only promises assigned to him');
          l_where:=l_where||' and ipd1.resource_id= '|| p_group_by_value_coll;
	end if;
	exception
	when others then
	   FND_FILE.put_line( FND_FILE.LOG,'***error in fetching resource count****'||sqlerrm);
	end;
       else
          FND_FILE.put_line( FND_FILE.LOG,'26');
	  l_where:=l_where||' and ipd1.resource_id= '|| p_group_by_value_coll;
       end if;
       end if;

        if  p_group_by='SCHEDULE' then
	   FND_FILE.put_line( FND_FILE.LOG,'27');
	  if  p_group_by_value_sch is not null then
	  FND_FILE.put_line( FND_FILE.LOG,'28');
	   l_where:=l_where||' and ipd1.campaign_sched_id ='||p_group_by_value_sch;
	   l_group_by:=' group by amsc.source_code_id,amsc.source_code,jrev.resource_id,jrev.resource_name)';
	  end if;
	  end if;
	   FND_FILE.put_line( FND_FILE.LOG,'28.5');
	   l_where:=l_where||' and (ipd1.campaign_sched_id in (Select source_code_id '||
 	                     'from  ams_source_codes '||
 	                      'where arc_source_code_for =''CAMP'') '||
                              'OR IPD1.campaign_sched_id is NULL)';


	 l_group_by:=' group by jrev.resource_id,jrev.resource_name,amsc.source_code_id,amsc.source_code)';

l_pmt_sum:=l_pmt_sum||l_where;
l_pmt_sum:=l_pmt_sum||l_group_by;

 FND_FILE.put_line( FND_FILE.LOG,'l_pmt_summ-->'||l_pmt_sum);

        open pmtdet for l_pmt_sum;
	loop
        fetch pmtdet into l_temp_source_code_id,l_temp_resource_id,l_temp_pmt_count,l_temp_pmt_amount;
	exit when pmtdet%notfound;
		IF l_temp_source_code_id IS NOT NULL AND
	          l_temp_resource_id IS NOT NULL THEN

	            l_resource_char:=to_char(l_temp_resource_id);
	             l_source_code_char:=to_char(l_temp_source_code_id);

	       elsif l_temp_source_code_id is not null and l_temp_resource_id is null then
		   l_resource_char:='';
	           l_source_code_char:=to_char(l_temp_source_code_id);
	      elsif l_temp_source_code_id is null and l_temp_resource_id is not null then
		   l_resource_char:=to_char(l_temp_resource_id);
		   l_source_code_char:='';
	      else
	           l_resource_char:='';
	           l_source_code_char:='';
	      end if;

	    l_hash_value := DBMS_UTILITY.get_hash_value(
						 l_resource_char||'@*?'||l_source_code_char,
						 1000,
						 25000);


	  l_pmt_cnt(l_hash_value):=l_temp_pmt_count;
          l_pmt_amt(l_hash_value):=l_temp_pmt_amount;
	  FND_FILE.put_line( FND_FILE.LOG,'in loop');
          FND_FILE.put_line( FND_FILE.LOG,l_pmt_cnt(l_hash_value));
          FND_FILE.put_line( FND_FILE.LOG,l_pmt_amt(l_hash_value));
       end loop;
	--end if;
       close pmtdet;
	FND_FILE.put_line( FND_FILE.LOG,'29');
	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
	exception
	when others then
	LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || '-'||sqlerrm);
	FND_FILE.put_line( FND_FILE.LOG,'err in proc-->'||sqlerrm);
end calc_pmt_amt_cnt;

function get_pmt_count(p_resource_id number,p_source_code_id in number) return number
 is
 l_resource_char varchar2(100);
 l_source_code_char varchar2(100);
 l_hash_value number;
 begin

  IF p_resource_id IS NOT NULL AND
     p_source_code_id IS NOT NULL THEN

      l_resource_char:=to_char(p_resource_id);
      l_source_code_char:=to_char(p_source_code_id);

  elsif p_source_code_id is not null and p_resource_id is null then
        l_resource_char:='';
      l_source_code_char:=to_char(p_source_code_id);
  elsif p_source_code_id is null and p_resource_id is not null then
        l_resource_char:=to_char(p_resource_id);
        l_source_code_char:='';
  else
       l_resource_char:='';
       l_source_code_char:='';
  end if;

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         l_resource_char||'@*?'||l_source_code_char,
                                         1000,
                                         25000);


  if l_pmt_cnt.exists(l_hash_value) then
 FND_FILE.put_line( FND_FILE.LOG,'30');
 return l_pmt_cnt(l_hash_value);
 else
 return 0;
 end if;
 end get_pmt_count;

 function get_pmt_amount(p_resource_id number,p_source_code_id in number) return number
 is
 l_resource_char varchar2(100);
 l_source_code_char varchar2(100);
 l_hash_value number;
 begin
 IF p_resource_id IS NOT NULL AND
     p_source_code_id IS NOT NULL THEN

      l_resource_char:=to_char(p_resource_id);
      l_source_code_char:=to_char(p_source_code_id);

  elsif p_source_code_id is not null and p_resource_id is null then
        l_resource_char:='';
      l_source_code_char:=to_char(p_source_code_id);
  elsif p_source_code_id is null and p_resource_id is not null then
        l_resource_char:=to_char(p_resource_id);
        l_source_code_char:='';
  else
       l_resource_char:='';
       l_source_code_char:='';
  end if;

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         l_resource_char||'@*?'||l_source_code_char,
                                         1000,
                                         25000);
 if l_pmt_amt.exists(l_hash_value) then
 FND_FILE.put_line( FND_FILE.LOG,'31');
 return l_pmt_amt(l_hash_value);
 else
 return 0;
 end if;
end get_pmt_amount;

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

end;

/
