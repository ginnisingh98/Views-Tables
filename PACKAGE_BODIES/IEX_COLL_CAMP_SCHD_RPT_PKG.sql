--------------------------------------------------------
--  DDL for Package Body IEX_COLL_CAMP_SCHD_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_COLL_CAMP_SCHD_RPT_PKG" AS
/* $Header: iexccsrb.pls 120.0.12010000.8 2009/08/18 14:59:43 barathsr noship $ */
  G_PKG_NAME VARCHAR2(100)         :='iex_coll_camp_schd_rpt_pkg';
  G_LOG_ENABLED                   varchar2(5);
  G_MSG_LEVEL                     NUMBER;

--  l_api_name CONSTANT VARCHAR2(50) := 'Collector Campaign Schedule Report';
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
PROCEDURE gen_xml_data_collcamp
  (
    ERRBUF OUT NOCOPY  VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    p_date_from                 IN DATE,
    p_date_to                   IN DATE,
    p_coll_camp_typ             IN VARCHAR2,
    p_campaign                  IN VARCHAR2,
    p_collector                 IN VARCHAR2,
    p_report_level              IN VARCHAR2,
    p_outcome                   IN VARCHAR2,
    p_result                    IN VARCHAR2,
    p_reason                    IN VARCHAR2)
                                IS
  l_api_name CONSTANT VARCHAR2(50) := 'gen_xml_data_collcamp';
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
TYPE ref_cur
IS
  REF
  CURSOR;
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
    l_query_dtl      VARCHAR2(11000);
    l_query          VARCHAR2(11000);
    l_org_id         VARCHAR2(10);
    l_coll_camp_typ varchar2(20);
    l_out_code varchar2(100);
    l_resl_code varchar2(100);
    l_res_code varchar2(100);
    l_collector varchar2(200);
    l_campaign varchar2(200);
    l_sysdate date;
  BEGIN
  LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
     FND_FILE.put_line( FND_FILE.LOG,'Begin procedure');

     if p_date_from is not null and p_date_to is not null then
      l_where:=l_where||'and trunc(jii.creation_date) >=to_date('''||p_date_from||''',''DD-MON-RRRR'') ';
      l_where:=l_where||'and trunc(jii.creation_date) <=to_date('''||p_date_to||''',''DD-MON-RRRR'')+1 ';
    end if;

      IF (p_coll_camp_typ='COLLECTOR' OR p_coll_camp_typ='CAMPAIGN') THEN
      FND_FILE.put_line( FND_FILE.LOG,'4.5');
      if p_collector is not null then
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
          );
      IF l_res_cnt <> 0 THEN
        l_res_qry  := '(select distinct resource_id '||
	'from '|| 'JTF_RS_RESOURCE_EXTNS '||
	'where source_id in (select distinct b.person_id '||
	'from jtf_rs_rep_managers b, JTF_RS_RESOURCE_EXTNS a '||
	'where b.manager_person_id = a.source_id '|| 'and a.resource_id = '||p_collector;
        l_where    :=l_where||' and jii.resource_id in '|| l_res_qry ;
        l_where    :=l_where||'))';
      ELSE
        FND_FILE.put_line( FND_FILE.LOG,'This Collector can see only promises assigned to him');
        l_where:=l_where||' and jii.resource_id= '|| p_collector;
      END IF;
    ELSE
      FND_FILE.put_line( FND_FILE.LOG,'4.6');
      l_where:=l_where||' and jii.resource_id= '|| p_collector;
    END IF;
    end if;
  END IF;

  IF p_campaign IS NOT NULL THEN
    FND_FILE.put_line( FND_FILE.LOG,'6');
    l_where:=l_where||' and jii.source_code_id ='||p_campaign;
    else
	   l_where:=l_where||' and (jii.source_code_id in (Select source_code_id '||
 	                     'from  ams_source_codes '||
			     'where arc_source_code_for =''CAMP'') '||
 	                     'OR jii.source_code_id is NULL)';

  END IF;

  if p_outcome is not null then
    l_where:=l_where||' and jii.outcome_id='||p_outcome;
    select outcome_code
    into l_out_code
    from jtf_ih_outcomes_vl
    where outcome_id=p_outcome;
  else
    l_out_code:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  end if;

  if p_result is not null then
    l_where:=l_where||' and jii.result_id='||p_result;
    select result_code
    into l_resl_code
    from jtf_ih_results_vl
    where result_id=p_result;
  else
    l_resl_code:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  end if;

  if p_reason is not null then
    l_where:=l_where||' and jii.reason_id='||p_reason;
    select reason_code
    into l_res_code
    from jtf_ih_reasons_vl
    where reason_id=p_reason;
  else
    l_res_code:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  end if;

  /* l_where:=l_where||' and (ipd.campaign_sched_id in (Select source_code_id '||
  'from  ams_source_codes '||
  'where arc_source_code_for =''CAMP'') '||
  'OR IPD.campaign_sched_id is NULL)'; */
  --end of get filters
  --group_by
  IF p_coll_camp_typ='COLLECTOR' THEN
    l_coll_camp_typ:='Collector';
    l_group_by     := ' group by jrrev.source_name, amsc.source_code,'|| 'jiov.outcome_code, jires.result_code,jirea.reason_code';
  ELSE
    l_coll_camp_typ:='Campaign';
    l_group_by:=' group by  amsc.source_code,jrrev.source_name,'|| 'jiov.outcome_code, jires.result_code,jirea.reason_code';
  END IF;
  l_query:='select jrrev.source_name Collector,amsc.source_code Campaign,jiov.outcome_code Outcome,'|| 'jires.result_code Result,jirea.reason_code Reason , count(*) Count '||
            'from '||
	    'jtf_ih_interactions jii,jtf_rs_resource_extns jrrev,'|| 'jtf_ih_outcomes_vl jiov,jtf_ih_results_vl jires,jtf_ih_reasons_vl jirea,ams_source_codes amsc '||
	    'where jii.resource_id= jrrev.resource_id(+) '||
	    'and jii.outcome_id= jiov.outcome_id(+) '||
	    'and jii.result_id= jires.result_id(+) '||
	    'and jii.reason_id= jirea.reason_id(+) '||
	    'and jii.source_code= amsc.source_code(+) ';

  l_query:=l_query||l_where;
  l_query:=l_query||l_group_by;
  FND_FILE.put_line( FND_FILE.LOG,'qry-->'||l_query);
  LogMessage(FND_LOG.LEVEL_STATEMENT, 'query: ' || l_query);
  ctx := DBMS_XMLQUERY.newContext(l_query);
  DBMS_XMLQUERY.setRaiseNoRowsException(ctx,TRUE);
  -- Bind Mandatory Variables
  --DBMS_XMLQUERY.setBindValue(ctx, 'p_date_from', p_date_from);
  --DBMS_XMLQUERY.setBindValue(ctx, 'p_date_to', p_date_to);
  --   DBMS_XMLQUERY.setBindValue(ctx, 'p_pro_state', p_pro_state);
  --    DBMS_XMLQUERY.setBindValue(ctx, 'p_pro_status', p_pro_status);
  --get the result
  BEGIN
    l_result := DBMS_XMLQUERY.getXML(ctx);
    DBMS_XMLQUERY.closeContext(ctx);
    l_rows_processed := 1;
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_XMLQUERY.getExceptionContent(ctx,l_errNo,l_errMsg);
    IF l_errNo          = 1403 THEN
      l_rows_processed := 0;
      --l_no_data_flag:=0;
    END IF;
    DBMS_XMLQUERY.closeContext(ctx);
  END;
  IF l_rows_processed <> 0 THEN
    FND_FILE.put_line( FND_FILE.LOG,'8') ;
    --get the length og the rowset header
    l_resultOffset := DBMS_LOB.INSTR(l_result,'>');
    FND_FILE.put_line( FND_FILE.LOG,'9') ;
  ELSE
    l_resultOffset := 0;
  END IF;

  if p_collector is not null then
    select source_name
    into l_collector
    from jtf_rs_resource_extns
    where resource_id=p_collector;
  else
     l_collector:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  end if;

  if p_campaign is not null then
    select source_code
    into l_campaign
    from ams_source_codes
    where source_code_id=p_campaign;
  else
    l_campaign:=iex_utilities.get_lookup_meaning('IEX_ALL_TYPE','ALL');
  end if;

  select sysdate
  into l_sysdate
  from dual;

  l_new_line := '
';
  FND_FILE.put_line( FND_FILE.LOG,'10') ;
  /* Prepare the tag for the report heading */
  l_xml_header      := '<?xml version="1.0" encoding="UTF-8"?>';
  l_xml_header      := l_xml_header ||l_new_line||'<COLLCAMP>';
  l_xml_header      := l_xml_header ||l_new_line||'    <PARAMETERS>'||l_new_line;
  l_xml_header      := l_xml_header ||l_new_line||'        <P_DATE_FROM>'||p_date_from||'</P_DATE_FROM>';
  l_xml_header      := l_xml_header ||l_new_line||'        <P_DATE_TO>' ||p_date_to ||'</P_DATE_TO>';
  l_xml_header      := l_xml_header ||l_new_line||'        <P_TYPE>' ||l_coll_camp_typ||'</P_TYPE>';
  l_xml_header      := l_xml_header ||l_new_line||'        <P_CAMPAIGN>' ||l_campaign ||'</P_CAMPAIGN>';
  l_xml_header      := l_xml_header ||l_new_line||'        <P_COLLECTOR>' ||l_collector||'</P_COLLECTOR>';
  l_xml_header      := l_xml_header ||l_new_line||'        <P_REPORT_LEVEL>' ||iex_utilities.get_lookup_meaning('IEX_REPORT_LEVEL',p_report_level)||'</P_REPORT_LEVEL>';
  l_xml_header      := l_xml_header ||l_new_line||'        <P_OUTCOME>' ||l_out_code||'</P_OUTCOME>';
  l_xml_header      := l_xml_header ||l_new_line||'        <P_RESULT>' ||l_resl_code||'</P_RESULT>';
  l_xml_header      := l_xml_header ||l_new_line||'        <P_REASON>' ||l_res_code||'</P_REASON>';
--  IF l_rows_processed=0 THEN
    l_xml_header    := l_xml_header ||l_new_line||' <DATA_FOUND>' ||l_rows_processed||'</DATA_FOUND>';
--  END IF;
l_xml_header    := l_xml_header ||l_new_line||' <CURR_DATE>' ||l_sysdate||'</CURR_DATE>';
  l_xml_header        := l_xml_header ||l_new_line||'    </PARAMETERS>';
  l_close_tag         := l_new_line||'</COLLCAMP>'||l_new_line;
  l_xml_header_length := dbms_lob.getlength(l_xml_header);
  tempResult          :=l_xml_header;
  IF l_rows_processed <> 0 THEN
    --copy result set to tempResult
    dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset, l_xml_header_length,l_resultOffset);
  ELSE
    dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
    dbms_lob.writeAppend(tempResult, LENGTH(l_xml_header), l_xml_header);
  END IF;
  --append the close tag to tempResult
  dbms_lob.writeAppend(tempResult, LENGTH(l_close_tag), l_close_tag);
  --print to the o/p file
  print_clob(lob_loc => tempResult);
  FND_FILE.put_line( FND_FILE.LOG,'15--end') ;
  LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || '-end');
EXCEPTION
WHEN OTHERS THEN
  --dbms_output.put_line('err'||sqlerrm);
  LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || ' -');
END gen_xml_data_collcamp;

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
