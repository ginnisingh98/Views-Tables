--------------------------------------------------------
--  DDL for Package Body HZ_DQM_DIAGNOSTICS_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DQM_DIAGNOSTICS_XML" AS
/*$Header: ARHDXMLB.pls 120.4 2006/02/22 01:20:10 schitrap noship $ */

PROCEDURE DQM_SETUP_OVERVIEW_XML IS
   	qryCtx DBMS_XMLGEN.ctxHandle;
	--qCtx DBMS_XMLGEN.ctxHandle;
	queryCtx DBMS_XMLGEN.ctxHandle;
	q1Ctx DBMS_XMLGEN.ctxHandle;

   result CLOB;
   result1 CLOB;
   result2 CLOB;


     l_xml_header            varchar2(5000);
     l_xml_header_length     number;
	 l_result_length 		 number;
     l_xml_query             VARCHAR2(32767);
     l_new_line              VARCHAR2(1);
     l_close_tag             VARCHAR2(100);
     l_rows_processed        NUMBER;
     l_result                CLOB;
     l_attrib_result         CLOB;
     l_trans_result			 CLOB;
     l_mrule_result			 CLOB;
     l_resultOffset          number;
     l_trans_resultOffset          number;
     l_attrib_resultOffset          number;
	 l_mrule_resultOffset           number;
  	 l_clob_size   NUMBER;
     --l_offset      NUMBER;
	 l_offset      INTEGER;
     l_chunk_size  INTEGER;
     l_chunk       VARCHAR2(32767);
 	 l_time        NUMBER;
	 l_st_parties_size NUMBER;
	 l_st_psites_size NUMBER;
	 l_st_pcnts_size NUMBER;
	 l_st_pcnpts_size NUMBER;
	 l_total_size NUMBER;
	 l_total_parties NUMBER;
	 l_entity_cnt  NUMBER;
	 l_staged_cnt NUMBER;
	 l_sync_cnt NUMBER;
	 l_index_time NUMBER;
	 l_schedule_cnt NUMBER;

   l_status VARCHAR2(255);
   l_owner VARCHAR2(255);
   l_temp VARCHAR2(255);
   l_bloc_result BLOB;
	l_bloc_subset RAW(32767);
   l_new_length number;
   l_xml_query VARCHAR2(5000);

BEGIN
qryCtx := dbms_xmlgen.newContext('select operation, number_of_workers,
decode(step,''STEP1'',''ORGANIZATION'',''STEP2'',''PERSON'',''STEP3'',''ALL OTHER PARTY TYPES'',''STEP4'',''CONTACTS'',''STEP5'',''PARTY SITES'',''STEP6'',''CONTACT POINTS'',step) steps,
worker_number,
to_char(start_time,''DD-MON-YY HH24:MI:SS'') start_time, to_char(end_time,''DD-MON-YY HH24:MI:SS'') end_time from hz_dqm_stage_log
where operation in (''STAGE_NEW_TRANSFORMATIONS'',''STAGE_ALL_DATA'',''CREATE_INDEXES'')
group by operation,step,worker_number,number_of_workers,start_time,end_time');

q1Ctx := dbms_xmlgen.newcontext('select vl.match_rule_id,vl.rule_name,vl.active_flag,nvl(vl.match_rule_type,''SINGLE'') match_rule_type,
ar.meaning rule_purpose, nvl(vl.automerge_flag,''N'') automerge_flag from hz_match_rules_vl vl, ar_lookups ar
where ar.lookup_type=''HZ_DQM_MATCH_RULE_PURPOSE'' and ar.lookup_code=vl.rule_purpose order by vl.creation_date');

queryCtx := dbms_xmlgen.newcontext('select attr.attribute_id,attr.attribute_name,attr.entity_name,attr.user_defined_attribute_name,
attr.custom_attribute_procedure,attr.source_table, nvl(attr.denorm_flag,''N'') denorm_flag,
trn.function_id, trn.transformation_name,trn.procedure_name,trn.staged_attribute_column,trn.staged_attribute_table,
nvl(trn.staged_flag,''N'') staged_flag,nvl(trn.active_flag,''Y'') active_flag,nvl(trn.index_required_flag,''Y'') index_required_flag,
nvl(trn.primary_flag,''Y'') primary_flag
from HZ_TRANS_ATTRIBUTES_VL attr,hz_trans_functions_vl trn
where attr.attribute_id =trn.attribute_id
group by attr.attribute_id,attr.attribute_name,attr.entity_name,attr.user_defined_attribute_name,
attr.custom_attribute_procedure,attr.source_table, attr.denorm_flag,
trn.function_id, trn.transformation_name,trn.procedure_name,trn.staged_attribute_column,trn.staged_attribute_table,
trn.staged_flag,trn.active_flag,trn.index_required_flag,trn.primary_flag
order by attribute_id asc');

select (max(end_time)-min(start_time)) into l_time from hz_dqm_stage_log
where operation='STAGE_ALL_DATA';

select (max(end_time)-min(start_time)) into l_index_time from hz_dqm_stage_log where operation = 'CREATE_INDEXES'
order by start_time;


  -- set the row header to be EMPLOYEE
  DBMS_XMLGEN.setRowTag(qryCtx, 'DQM Stage From LOG');
  --DBMS_XMLGEN.setRowTag(qCtx, 'DQM Transformations');
  DBMS_XMLGEN.setRowTag(queryCtx, 'DQM Transformation Attributes');
  DBMS_XMLGEN.setRowTag(q1Ctx, 'Match Rules');

  -- now get the result
    l_result := DBMS_XMLGEN.getXML(qryCtx);
    --l_trans_result := DBMS_XMLGEN.getXML(qCtx);
    l_attrib_result := DBMS_XMLGEN.getXML(queryCtx);
	l_mrule_result := DBMS_XMLGEN.getXML(q1Ctx);

    l_new_line := '
';
    l_xml_header     := '<?xml version="1.0" encoding="UTF-8"?>';
                l_xml_header     := l_xml_header ||l_new_line||'<HZTESTXML>';
                l_xml_header     := l_xml_header ||l_new_line||'<TOTAL_TIME>'||l_time||'</TOTAL_TIME>';
	 l_st_parties_size := GET_TABLE_SIZE('HZ_STAGED_PARTIES');
	 l_st_psites_size := GET_TABLE_SIZE('HZ_STAGED_PARTY_SITES');
	 l_st_pcnts_size := GET_TABLE_SIZE('HZ_STAGED_CONTACTS');
	 l_st_pcnpts_size := GET_TABLE_SIZE('HZ_STAGED_CONTACT_POINTS');
	 l_total_size := l_st_parties_size+l_st_psites_size+l_st_pcnts_size+l_st_pcnpts_size;
                l_xml_header     := l_xml_header ||l_new_line||'<STAGING_DISC_SPACE>'||l_total_size||'</STAGING_DISC_SPACE>';

     select count(party_id) into l_entity_cnt from hz_parties where party_type = 'ORGANIZATION';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_ORGS>'||to_char(l_entity_cnt)||'</PARTY_ORGS>';
     select count(party_id) into l_staged_cnt from hz_staged_parties where TX36 = 'ORGANIZATION ';
                l_xml_header     := l_xml_header ||l_new_line||'<ORG_PARTIES_IN_STAGE>'||to_char(l_staged_cnt)||'</ORG_PARTIES_IN_STAGE>';
	select count(distinct(party_id)) into l_sync_cnt from hz_dqm_sync_interface where entity='PARTY'
	and party_id in (select party_id from hz_parties where party_type = 'ORGANIZATION' );
                l_xml_header     := l_xml_header ||l_new_line||'<ORG_PARTIES_TO_STAGE>'||to_char(l_sync_cnt)||'</ORG_PARTIES_TO_STAGE>';

  	 select count(party_id) into l_entity_cnt from hz_parties where party_type = 'PERSON';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_PERS>'||to_char(l_entity_cnt)||'</PARTY_PERS>';
     select count(party_id) into l_staged_cnt from hz_staged_parties where TX36 = 'PERSON ' ;
                l_xml_header     := l_xml_header ||l_new_line||'<PER_PARTIES_IN_STAGE>'||to_char(l_staged_cnt)||'</PER_PARTIES_IN_STAGE>';
	select count(distinct(party_id)) into l_sync_cnt from hz_dqm_sync_interface where entity='PARTY'
	and party_id in (select party_id from hz_parties where party_type = 'PERSON');
                l_xml_header     := l_xml_header ||l_new_line||'<PER_PARTIES_TO_STAGE>'||to_char(l_sync_cnt)||'</PER_PARTIES_TO_STAGE>';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_STAGE_DISK_SPACE>'||to_char(l_st_parties_size)||'</PARTY_STAGE_DISK_SPACE>';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_DISK_SPACE>'||GET_TABLE_SIZE('HZ_PARTIES')||'</PARTY_DISK_SPACE>';

  	 select count(party_id) into l_entity_cnt from hz_parties where party_type in ('ORGANIZATION','PERSON');
                l_xml_header     := l_xml_header ||l_new_line||'<TOTAL_PARTIES_IN_TCA>'||to_char(l_entity_cnt)||'</TOTAL_PARTIES_IN_TCA>';
  	 select count(party_id) into l_staged_cnt from hz_staged_parties where TX36 in ('ORGANIZATION ','PERSON ');
                l_xml_header     := l_xml_header ||l_new_line||'<TOTAL_PARTIES_IN_STAGE>'||to_char(l_staged_cnt)||'</TOTAL_PARTIES_IN_STAGE>';
	select count(distinct(party_id)) into l_sync_cnt from hz_dqm_sync_interface where entity='PARTY'
	and party_id in (select party_id from hz_parties where party_type in ('ORGANIZATION','PERSON'));
                l_xml_header     := l_xml_header ||l_new_line||'<TOTAL_PARTIES_TO_SYNC>'||to_char(l_sync_cnt)||'</TOTAL_PARTIES_TO_SYNC>';

     select count(party_site_id) into l_entity_cnt from hz_party_sites where party_id in
	 (select party_id from hz_parties where party_type in ('ORGANIZATION','PERSON'));
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_SITE_ENTITY>'||to_char(l_entity_cnt)||'</PARTY_SITE_ENTITY>';
     select count(party_site_id) into l_staged_cnt from hz_staged_party_sites where org_contact_id IS NULL and party_id in
     (select party_id from hz_staged_parties where TX36 in ('ORGANIZATION ','PERSON ')) ;
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_SITES_IN_STAGE>'||to_char(l_staged_cnt)||'</PARTY_SITES_IN_STAGE>';
	select count(distinct(party_id)) into l_sync_cnt from hz_dqm_sync_interface where entity='PARTY_SITES'
	and party_id in (select party_id from hz_parties where party_type in ('ORGANIZATION','PERSON'));
                l_xml_header     := l_xml_header ||l_new_line||'<PSITES_TO_SYNC>'||to_char(l_sync_cnt)||'</PSITES_TO_SYNC>';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_SITE_STAGE_DISK_SPACE>'||to_char(l_st_psites_size)||'</PARTY_SITE_STAGE_DISK_SPACE>';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_SITE_DISK_SPACE>'||GET_TABLE_SIZE('HZ_PARTY_SITES')||'</PARTY_SITE_DISK_SPACE>';

	select count(*) into l_entity_cnt from hz_org_contacts where party_relationship_id in
	(select relationship_id from hz_relationships where subject_table_name='HZ_PARTIES'
		and object_table_name='HZ_PARTIES' and subject_type in ('ORGANIZATION','PERSON')
		and object_type in ('ORGANIZATION','PERSON'));
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_CONTACTS>'||to_char(l_entity_cnt)||'</PARTY_CONTACTS>';

	select count(*) into l_staged_cnt from hz_staged_contacts where org_contact_id in
	(select org_contact_id  from hz_org_contacts where party_relationship_id in
	(select relationship_id from hz_relationships where subject_table_name='HZ_PARTIES'
		and object_table_name='HZ_PARTIES' and subject_type in ('ORGANIZATION','PERSON')
		and object_type in ('ORGANIZATION','PERSON')));

                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_CONTACTS_IN_STAGE>'||to_char(l_staged_cnt)||'</PARTY_CONTACTS_IN_STAGE>';
	select count(distinct(party_id)) into l_sync_cnt from hz_dqm_sync_interface where entity='CONTACTS'
	and party_id in (select party_id from hz_parties where party_type in ('ORGANIZATION','PERSON'));
                l_xml_header     := l_xml_header ||l_new_line||'<PCONTACTS_TO_SYNC>'||to_char(l_sync_cnt)||'</PCONTACTS_TO_SYNC>';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_CONTACTS_STAGE_DISK_SPACE>'||to_char(l_st_pcnts_size)||'</PARTY_CONTACTS_STAGE_DISK_SPACE>';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_CONTACTS_DISK_SPACE>'||GET_TABLE_SIZE('HZ_ORG_CONTACTS')||'</PARTY_CONTACTS_DISK_SPACE>';

 	select count(contact_point_id) into l_entity_cnt from hz_contact_points where owner_table_name in ('HZ_PARTIES','HZ_PARTY_SITES');
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_CONTACT_POINT>'||to_char(l_entity_cnt)||'</PARTY_CONTACT_POINT>';

	select count(contact_point_id) into l_staged_cnt from hz_staged_contact_points where contact_point_id in
    (select contact_point_id  from hz_contact_points where owner_table_name in ('HZ_PARTIES','HZ_PARTY_SITES'));
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_CNTPTS_IN_STAGE>'||to_char(l_staged_cnt)||'</PARTY_CNTPTS_IN_STAGE>';
	select count(distinct(party_id)) into l_sync_cnt from hz_dqm_sync_interface where entity='CONTACT_POINTS'
	and party_id in (select party_id from hz_parties where party_type in ('ORGANIZATION','PERSON'));
                l_xml_header     := l_xml_header ||l_new_line||'<CNTPNTS_TO_SYNC>'||to_char(l_sync_cnt)||'</CNTPNTS_TO_SYNC>';
                l_xml_header     := l_xml_header ||l_new_line||'<PARTY_CNTPNTS_STAGE_DISK_SPACE>'||to_char(l_st_pcnpts_size)||'</PARTY_CNTPNTS_STAGE_DISK_SPACE>';
				l_xml_header := l_xml_header || l_new_line||'<PARTY_CNTPNTS_DISK_SPACE>'||to_char(GET_TABLE_SIZE('HZ_CONTACT_POINTS'))||'</PARTY_CNTPNTS_DISK_SPACE>';
				l_xml_header     := l_xml_header ||l_new_line||'<TOTAL_INDEX_TIME>'||l_index_time||'</TOTAL_INDEX_TIME>';

    select count(*) into l_schedule_cnt from fnd_concurrent_requests where concurrent_program_id=44464
	and phase_code='P';

	if(l_schedule_cnt>0) then
		l_xml_header     := l_xml_header ||l_new_line||'<SCHEDULED_SYNC>Yes</SCHEDULED_SYNC>';
	else
		l_xml_header     := l_xml_header ||l_new_line||'<SCHEDULED_SYNC>No</SCHEDULED_SYNC>';
	end if;

        l_xml_header_length := length(l_xml_header);
           dbms_lob.createtemporary(result,FALSE,DBMS_LOB.CALL);
           dbms_lob.open(result,dbms_lob.lob_readwrite);
           dbms_lob.writeAppend(result, length(l_xml_header), l_xml_header);
		--dbms_lob.write(result,l_xml_header_length,1,l_xml_header);

   --DQM STAGING LOG INFORMATION

   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
       		l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
  		    l_result_length := dbms_lob.getlength(result);
            dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
                         l_result_length,l_resultOffset);
   		END IF;


	-- DQM ATTRIBUTE DETAILS

   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(queryCtx);
   		IF l_rows_processed <> 0 THEN
	   			l_result_length := dbms_lob.getlength(result);
       			l_attrib_resultOffset   := DBMS_LOB.INSTR(l_attrib_result ,'>');
            	dbms_lob.copy(result,l_attrib_result,dbms_lob.getlength(l_attrib_result)-l_attrib_resultOffset,
           				 l_result_length,l_attrib_resultOffset);
        END IF;

	-- DQM MATCH RULES DETAILS

   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(q1Ctx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_mrule_resultOffset   := DBMS_LOB.INSTR(l_mrule_result ,'>');
           		dbms_lob.copy(result,l_mrule_result,dbms_lob.getlength(l_mrule_result)-l_mrule_resultOffset,
           				 l_result_length,l_mrule_resultOffset);
 	 	END IF;

 	--Time for each operation in Staging Log Table

	qryCtx := dbms_xmlgen.newContext('select operation,to_char(max(end_time)-min(start_time)) time_diff from hz_dqm_stage_log
								  where (start_time is not null OR end_time is not null)
								  and operation = ''STAGE_NEW_TRANSFORMATIONS'' group by operation ');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Time for STAGE_NEW_TRANSFORMATIONS in Staging Log Table');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;


 	qryCtx := dbms_xmlgen.newContext('select operation,to_char(max(end_time)-min(start_time)) time_diff from hz_dqm_stage_log
								  where (start_time is not null OR end_time is not null)
								  and operation = ''STAGE_ALL_DATA'' group by operation ');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Time for STAGE_ALL_DATA in Staging Log Table');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;

	qryCtx := dbms_xmlgen.newContext('select operation,to_char(max(end_time)-min(start_time)) time_diff from hz_dqm_stage_log
								  where (start_time is not null OR end_time is not null)
								  and operation = ''CREATE_INDEXES'' group by operation ');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Time for CREATE_INDEXES in Staging Log Table');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;


/*	INDEX DETAILS */

	qryCtx := dbms_xmlgen.newContext('select ''CREATE INTERMEDIA INDEXES'', step table_name from hz_dqm_stage_log where operation = ''CREATE_INDEXES'' order by step asc');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Time to build intermedia index by entity');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;

/*
	qryCtx := dbms_xmlgen.newContext(' select ind.index_name,ind.table_name,ind.status,ind.index_type, substr(ind.parameters,instr(ind.parameters,''memory'')+6) memory, '||
					' (st.end_time-st.start_time) total_time,a.pnd_syncs,b.index_errors from sys.all_indexes ind, hz_dqm_stage_log st, '||
					' (select ''HZ_STAGE_PARTIES_T1'' index_name, count(*) pnd_syncs from ctxsys.ctx_pending where PND_INDEX_OWNER=''AR'' and PND_INDEX_NAME like ''HZ_STAGE_PARTIES_T1'' '||
					' union select ''HZ_STAGE_PARTY_SITES_T1'' index_name, count(*) pnd_syncs from ctxsys.ctx_pending where PND_INDEX_OWNER=''AR'' and PND_INDEX_NAME like ''HZ_STAGE_PARTY_SITES_T1'' '||
					' union select ''HZ_STAGE_CONTACT_T1'' index_name, count(*) pnd_syncs from ctxsys.ctx_pending where PND_INDEX_OWNER=''AR'' and PND_INDEX_NAME like ''HZ_STAGE_CONTACT_T1'' '||
					' union select ''HZ_STAGE_CPT_T1'' index_name, count(*) pnd_syncs from ctxsys.ctx_pending where PND_INDEX_OWNER=''AR'' and PND_INDEX_NAME like ''HZ_STAGE_CPT_T1'' '||
					' ) a, (select ''HZ_STAGE_PARTIES_T1'' index_name, count(*) index_errors from ctxsys.ctx_index_errors where err_index_name like ''HZ_STAGE_PARTIES_T1'' '||
					' union select ''HZ_STAGE_PARTY_SITES_T1'' index_name, count(*) index_errors from ctxsys.ctx_index_errors where err_index_name like ''HZ_STAGE_PARTY_SITES_T1'' '||
					' union select ''HZ_STAGE_CONTACT_T1'' index_name, count(*) index_errors from ctxsys.ctx_index_errors where err_index_name like ''HZ_STAGE_CONTACT_T1'' '||
					' union select ''HZ_STAGE_CPT_T1'' index_name, count(*) index_errors from ctxsys.ctx_index_errors where err_index_name like ''HZ_STAGE_CPT_T1'' '||
					' ) b where ind.index_name like ''HZ_STAGE%T1'' '||
					' and ind.table_name in(''HZ_STAGED_PARTIES'',''HZ_STAGED_PARTY_SITES'',''HZ_STAGED_CONTACTS'',''HZ_STAGED_CONTACT_POINTS'') '||
					' and st.operation=''CREATE_INDEXES'' and st.step in (''HZ_PARTIES'',''HZ_PARTY_SITES'',''HZ_ORG_CONTACTS'',''HZ_CONTACT_POINTS'') '||
					' and (decode(ind.table_name,''HZ_STAGED_PARTIES'',''HZ_PARTIES'') = st.step '||
    				' OR decode(ind.table_name,''HZ_STAGED_PARTY_SITES'',''HZ_PARTY_SITES'') = st.step '||
    				' OR decode(ind.table_name,''HZ_STAGED_CONTACTS'',''HZ_ORG_CONTACTS'') = st.step '||
    				' OR decode(ind.table_name,''HZ_STAGED_CONTACT_POINTS'',''HZ_CONTACT_POINTS'') = st.step) '||
					' and a.index_name = b.index_name '||
					' and a.index_name = ind.index_name ');    */

	qryCtx := dbms_xmlgen.newContext(' SELECT I.INDEX_NAME, I.table_name, I.status, I.index_type, substr(I.parameters, instr(I.parameters, ''memory'')+6) memory, '||
	' (st.end_time-st.start_time) total_time, NVL(P.PND_CNT,0) pnd_syncs, NVL(E.ERR_CNT,0) index_errors '||
	' FROM  DBA_INDEXES I, '||
 	' (SELECT   u.name pnd_index_owner , i.idx_name pnd_index_name, COUNT(*) PND_CNT '||
    ' from ctxsys.dr$pending dr,ctxsys.dr$index i, sys.user$ u '||
    ' where I.idx_owner# = u.user# and dr.pnd_pid = 0 and dr.pnd_cid = I.idx_id '||
    ' GROUP BY u.name, i.idx_name ) P, '||
    ' (SELECT  err_index_owner, err_index_name, COUNT(*) ERR_CNT '||
    ' FROM CTXSYS.CTX_INDEX_ERRORS '||
    ' GROUP BY err_index_owner,err_index_name ) E, '||
  	' hz_dqm_stage_log st '||
	' WHERE I.INDEX_NAME IN (''HZ_STAGE_PARTIES_T1'',''HZ_STAGE_PARTY_SITES_T1'', '||
    ' ''HZ_STAGE_CONTACT_T1'',''HZ_STAGE_CPT_T1'') '||
	' AND   I.INDEX_NAME = P.pnd_index_name(+) '||
	' AND   I.OWNER = P.pnd_index_owner(+) '||
	' AND   I.INDEX_NAME = E.err_index_name(+) '||
	' AND   I.OWNER = E.err_index_owner(+) '||
	' AND   st.operation=''CREATE_INDEXES'' '||
	' AND (decode(I.table_name, ''HZ_STAGED_PARTIES'', ''HZ_PARTIES'') =  st.step '||
    ' OR decode(I.table_name, ''HZ_STAGED_PARTY_SITES'', ''HZ_PARTY_SITES'' ) = st.step '||
    ' OR decode(I.table_name, ''HZ_STAGED_CONTACTS'', ''HZ_ORG_CONTACTS'') = st.step '||
    ' OR decode(I.table_name, ''HZ_STAGED_CONTACT_POINTS'', ''HZ_CONTACT_POINTS'') =  st.step) ');

  	DBMS_XMLGEN.setRowTag(qryCtx, 'Intermedia index details');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;


	qryCtx := dbms_xmlgen.newContext('select * from ctxsys.ctx_pending where PND_INDEX_OWNER=''AR'' and PND_INDEX_NAME like ''HZ%STAGE%T1''');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Pending Syncs on Intermedia Index');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;


	qryCtx := dbms_xmlgen.newContext('select * from ctxsys.ctx_index_errors where err_index_name like ''HZ%STAGE%T1''');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Number of records with errors');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;

	if(fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner)) then
		qryCtx := dbms_xmlgen.newContext('select * from sys.dba_ind_columns where table_owner=''AR'' and table_name in(''HZ_STAGED_PARTIES'',''HZ_STAGED_PARTY_SITES'',''HZ_STAGED_CONTACTS'',''HZ_STAGED_CONTACT_POINTS'') ');
  		DBMS_XMLGEN.setRowTag(qryCtx, 'Bulk Indexes');
  		l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;
	end if;

	--DQM SYNCHRONIZATION PROGRAM DETAILS

	qryCtx := dbms_xmlgen.newContext('select ''HZ_DQM_ENABLE_REALTIME_SYNC'' sync_profile, meaning sync_type from ar_lookups where lookup_type =  ''HZ_DQM_SYNC_VALUES'' and
									lookup_code in (select nvl(FND_PROFILE.VALUE(''HZ_DQM_ENABLE_REALTIME_SYNC''),''Y'') from dual)');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Sync type from profile');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;


    qryCtx := dbms_xmlgen.newContext('select COMPONENT_STATUS,COMPONENT_STATUS_INFO from FND_SVC_COMPONENTS SC where SC.COMPONENT_TYPE = ''WF_AGENT_LISTENER'' and component_name = ''Workflow Deferred Agent Listener''');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Workflow Agent Listener Status');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;


	qryCtx := dbms_xmlgen.newContext('select ''PARTY'' entity,''Processing'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''PARTY'' and staged_flag=''P'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''PARTY'' entity,''Pending'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''PARTY'' and staged_flag=''N'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''PARTY'' entity,''Staged but not Indexed'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''PARTY'' and staged_flag=''Y'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''PARTY'' entity,''Error'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''PARTY'' and staged_flag=''E'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''PARTY_SITES'' entity,''Processing'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''PARTY_SITES'' and staged_flag=''P'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''PARTY_SITES'' entity,''Pending'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''PARTY_SITES'' and staged_flag=''N'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''PARTY_SITES'' entity,''Staged but not Indexed'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''PARTY_SITES'' and staged_flag=''Y'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''PARTY_SITES'' entity,''Error'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''PARTY_SITES'' and staged_flag=''E'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''CONTACTS'' entity,''Processing'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''CONTACTS'' and staged_flag=''P'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''CONTACTS'' entity,''Pending'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''CONTACTS'' and staged_flag=''N'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''CONTACTS'' entity,''Staged but not Indexed'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''CONTACTS'' and staged_flag=''Y'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''CONTACTS'' entity,''Error'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''CONTACTS'' and staged_flag=''E'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''CONTACT_POINTS'' entity,''Processing'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''CONTACT_POINTS'' and staged_flag=''P'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''CONTACT_POINTS'' entity,''Pending'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''CONTACT_POINTS'' and staged_flag=''N'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''CONTACT_POINTS'' entity,''Staged but not Indexed'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''CONTACT_POINTS'' and staged_flag=''Y'' group by entity,staged_flag '||
		 ' UNION '||
		 ' select ''CONTACT_POINTS'' entity,''Error'' stage_status, nvl(sum(count(1)),0) SYNC_COUNT from hz_dqm_sync_interface '||
		 ' where entity=''CONTACT_POINTS'' and staged_flag=''E'' group by entity,staged_flag ');
	 DBMS_XMLGEN.setRowTag(qryCtx, 'Interface table Data');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;

	qryCtx := dbms_xmlgen.newContext('select party_id,record_id,entity,decode(operation,''U'',''Update'',''C'',''Create'',operation) operation,''Error'' staged_flag ,org_contact_id,party_site_id,error_data
										from hz_dqm_sync_interface where staged_flag=''E''
										group by entity,entity,operation,party_id,record_id,staged_flag,org_contact_id,party_site_id,error_data ');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Sync Interface table Errors per Entity');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;


	qryCtx := dbms_xmlgen.newContext('select request_id,last_update_date,request_date, phase_code,status_code,to_char(requested_start_date,''DD-MON-YY HH24:MI:SS'') requested_start_date,concurrent_program_id
								from FND_CONCURRENT_REQUESTS where status_code=''Q'' and phase_code=''P'' and program_application_id=222
								and concurrent_program_id in(select concurrent_program_id from fnd_concurrent_programs where concurrent_program_name=''ARHDQSYN'')');
  	DBMS_XMLGEN.setRowTag(qryCtx, 'Sync program Schedule');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;


	qryCtx := dbms_xmlgen.newContext('select a.profile_option_id, b.user_profile_option_name,b.description,a.profile_option_value,
						a.level_id,a.level_context,a.last_update_date, a.last_updated_by from
						(select val.application_id, val.profile_option_id,''SITE'' level_id, null level_context,
						 val.last_update_date,val.last_updated_by, val.profile_option_value
						from fnd_profile_option_values val where val.level_id=10001
					UNION
						select val.application_id, val.profile_option_id,''Application'' level_id, appl.application_name level_context,
 						val.last_update_date,val.last_updated_by, val.profile_option_value
						from fnd_profile_option_values val,fnd_application_tl appl
						where appl.application_id = val.level_value and appl.language=''US'' and val.level_id=10002
					UNION
						select val.application_id, val.profile_option_id,''Responsibility'' level_id, resp.responsibility_name level_context,
						val.last_update_date,val.last_updated_by, val.profile_option_value
						from fnd_profile_option_values val,fnd_responsibility_tl resp
						where resp.responsibility_id = val.level_value and resp.language=''US'' and val.level_id=10003
					UNION
						select val.application_id, val.profile_option_id,''User'' level_id, usr.user_name level_context,
 						val.last_update_date,val.last_updated_by, val.profile_option_value
						from fnd_profile_option_values val,fnd_user usr
						where usr.user_id = val.level_value and val.level_id=10004
					UNION
						select val.application_id, val.profile_option_id,decode(val.level_id,10005,''Server'',10006,''Organization'') level_id,
						null level_context,val.last_update_date,val.last_updated_by, val.profile_option_value
						from fnd_profile_option_values val where val.level_id in (10005,10006)) a,
					(select tl.user_profile_option_name,op.profile_option_id,tl.description
					from fnd_profile_options op,fnd_profile_options_tl tl
					where tl.profile_option_name = op.profile_option_name
					and tl.language = ''US'' and op.profile_option_id in
			  		(select profile_option_id from Fnd_Profile_Cat_Options where category_name in
			 		(''HZ_DQM_DEPLOYMENT'',''HZ_DL_DEPLOYMENT'',''HZ_DL_IMPORT_SETUP'',''HZ_DL_MAPPING_SETUP'',''HZ_DL_SETUP''))) b
					where a.profile_option_id=b.profile_option_id	order by a.profile_option_id asc ');

  	DBMS_XMLGEN.setRowTag(qryCtx, 'DQM Profiles');
  	l_result := DBMS_XMLGEN.getXML(qryCtx);
   		l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
   		IF l_rows_processed <> 0 THEN
	   		    l_result_length := dbms_lob.getlength(result);
       			l_resultOffset   := DBMS_LOB.INSTR(l_result ,'>');
           		dbms_lob.copy(result,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
           				 l_result_length,l_resultOffset);
 	 	END IF;



        l_close_tag      := l_new_line||'</HZTESTXML>'||l_new_line;
		dbms_lob.writeAppend(result, length(l_close_tag), l_close_tag);


      fnd_file.put_line (
      which => fnd_file.log,
      buff  => 'DQM Setup Snapshot XML');

  -- get length of internal lob and open the dest. file.
  l_clob_size := dbms_lob.getlength(result);

  IF (l_clob_size = 0) THEN
      fnd_file.put_line (
      which => fnd_file.log,
      buff  => 'CLOB is empty');
    RETURN;
  END IF;

  l_offset     := 1;
  l_chunk_size := 3000;

      fnd_file.put_line (
      which => fnd_file.log,
      buff  => 'Unloading... '  || l_clob_size);

  WHILE (l_clob_size > 0) LOOP

      fnd_file.put_line (
      which => fnd_file.log,
      buff  => 'Off Set: ' || l_offset);

    l_chunk := dbms_lob.substr (result, l_chunk_size, l_offset);

    fnd_file.put_line (
      which => fnd_file.log,
      buff  => l_chunk);

   fnd_file.put(
      which => fnd_file.output,
      buff  => l_chunk);

			l_bloc_subset := UTL_RAW.CAST_TO_RAW (l_chunk);
			l_new_length := UTL_RAW.LENGTH(l_bloc_subset);

           dbms_lob.createtemporary(l_bloc_result,FALSE,DBMS_LOB.CALL);
           dbms_lob.open(l_bloc_result,dbms_lob.lob_readwrite);
		   dbms_lob.write(l_bloc_result,l_new_length,l_offset,l_bloc_subset);

    l_clob_size := l_clob_size - l_chunk_size;
    l_offset := l_offset + l_chunk_size;

  END LOOP;

  --close context
  DBMS_XMLGEN.closeContext(qryCtx);
  --DBMS_XMLGEN.closeContext(qCtx);
  DBMS_XMLGEN.closeContext(queryCtx);
  DBMS_XMLGEN.closeContext(q1Ctx);
END DQM_SETUP_OVERVIEW_XML;


FUNCTION GET_TABLE_SIZE(p_table_name VARCHAR2) RETURN  NUMBER IS
   l_status VARCHAR2(255);
   l_owner1 VARCHAR2(255);
   l_temp VARCHAR2(255);
	l_size NUMBER;

   CURSOR c_number_of_blocks(t_name varchar2, l_own1 varchar2) is
                  SELECT blocks - empty_blocks
                  FROM sys.dba_tables
                  WHERE table_name = t_name and owner = l_own1;
   CURSOR  c_db_block_size is  SELECT value
                  FROM v$parameter
                  WHERE name = 'db_block_size' ;
   l_db_block_size NUMBER;
   l_number_of_blocks NUMBER;

   BEGIN
      IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner1)) THEN
         OPEN c_number_of_blocks(p_table_name,l_owner1);
         FETCH c_number_of_blocks into l_number_of_blocks;
         CLOSE c_number_of_blocks;
         OPEN c_db_block_size;
         FETCH c_db_block_size into l_db_block_size;
         CLOSE c_db_block_size;
     END IF;
     l_size := (l_number_of_blocks * l_db_block_size) / 1000000;
     RETURN  l_size;
    EXCEPTION
      WHEN OTHERS THEN
      RETURN 0;
END GET_TABLE_SIZE;


PROCEDURE GENERATE_XML(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, whichXml varchar2) IS
BEGIN
if(whichxml='SETUP') then
	DQM_SETUP_OVERVIEW_XML();
end if;
EXCEPTION
 WHEN OTHERS THEN
  Raise;
END GENERATE_XML;

END HZ_DQM_DIAGNOSTICS_XML;

/
