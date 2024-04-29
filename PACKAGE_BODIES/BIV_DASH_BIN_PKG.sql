--------------------------------------------------------
--  DDL for Package Body BIV_DASH_BIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DASH_BIN_PKG" AS
	-- $Header: bivdsbnb.pls 115.26 2004/01/23 04:53:11 vganeshk ship $ */
	-- This package is used to render the picasso BIN in dashboard
	-- all procedure are called by seeded AK_REGION via JTF

	g_err VARCHAR2(500);
	g_v_sp VARCHAR2(5) := biv_core_pkg.g_value_sep;
	g_p_sp VARCHAR2(5) := biv_core_pkg.g_param_sep;
	g_session_id NUMBER := biv_core_pkg.get_session_id;
  	g_debug_flag VARCHAR2(1) := nvl(fnd_profile.value('BIV:DEBUG'),'N');
        g_esc_frm_lst varchar2(500);
        g_esc_whr_cls varchar2(2000);
        g_esc_sel_stt varchar2(2000);

    -- Service Request Bin
	PROCEDURE load_sr_bin(p_param_str IN VARCHAR2 /*DEFAULT NULL*/) IS
		l_index NUMBER := 1;
		x_where_clause varchar2(1000);
		l_query VARCHAR2(3000);
		l_select VARCHAR2(500);
		l_table VARCHAR2(500);
		l_where VARCHAR2(1000);
		l_cur_id  PLS_INTEGER;
		l_return_num PLS_INTEGER := 0;
   -- Variables l_total and l_totalurl, l_url added for enh 2914005
                l_total VARCHAR(500);
                l_totalurl VARCHAR(3000);
                l_url VARCHAR(3000);

    	l_ogrp VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_OGRP');
    	l_agrp VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_AGRP');
    	l_mgr_id VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_MGR_ID');
	BEGIN
		biv_core_pkg.g_report_id := 'BIV_DASH_SR_BIN';
		biv_core_pkg.clean_dcf_table('BIV_TMP_BIN');
	        g_session_id := biv_core_pkg.get_session_id;
		biv_core_pkg.get_report_parameters(p_param_str);

  		l_select := 'INSERT INTO biv_tmp_bin (report_code, session_id, col2, col3, col4) ';
  		l_select := l_select || 'SELECT :report_id,:session_id,stat.name, ';
  		l_select := l_select || '''BIV_SERVICE_REQUEST';

                /* Parameters being added to l_url rather than l_select to accomadate
                   enhancement 2914005
                */
		if l_ogrp is not null then
			l_url := l_url || g_p_sp || 'P_OGRP' || g_v_sp || l_ogrp;
		end if;
		if l_agrp is not null then
		        l_url := l_url || g_p_sp || 'P_AGRP' || g_v_sp || l_agrp;
		end if;
		if l_mgr_id is not null then
	                l_url := l_url || g_p_sp || 'P_MGR_ID' || g_v_sp || l_mgr_id;
		end if;

                l_select := l_select || l_url || g_p_sp || 'P_STS_ID' || g_v_sp;
                l_select := l_select || '''||stat.incident_status_id||''' || g_p_sp || '''';
                l_select := l_select || ',count(sr.incident_id) ';
                -- Change for Bug 3386946
                l_table := ' FROM cs_incidents_b_sec sr, cs_incident_statuses_vl stat ';
		biv_core_pkg.get_where_clause(l_table,x_where_clause);
		l_where := x_where_clause || '
				and sr.incident_status_id = stat.incident_status_id
				and stat.incident_subtype = ''INC''
				and nvl(stat.close_flag,''N'') != ''Y''
				GROUP BY stat.incident_status_id,stat.name,stat.description
			';
		l_query := l_select  || ' ' || l_table || ' ' || l_where;

		if g_debug_flag = 'Y' then
			biv_core_pkg.biv_debug(l_query,biv_core_pkg.g_report_id);
			commit;
		end if;

		l_cur_id := DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(l_cur_id,l_query,DBMS_SQL.NATIVE);
		biv_core_pkg.bind_all_variables(l_cur_id);
		DBMS_SQL.BIND_VARIABLE(l_cur_id,':report_id',biv_core_pkg.g_report_id);
		DBMS_SQL.BIND_VARIABLE(l_cur_id,':session_id',biv_core_pkg.get_session_id);
		l_return_num := DBMS_SQL.EXECUTE(l_cur_id);
		DBMS_SQL.CLOSE_CURSOR(l_cur_id);

                -- Change for enh 2914005 starts
                if l_return_num > 0 then
                  l_total := biv_core_pkg.get_lookup_meaning('TOTAL');
                  l_totalurl := 'BIV_SERVICE_REQUEST' || l_url;
                  l_totalurl := l_totalurl || g_p_sp || 'P_PREVR' || g_v_sp;
                  l_totalurl := l_totalurl || biv_core_pkg.g_report_id;
                  l_totalurl := l_totalurl || g_p_sp || 'P_TOTAL' || g_v_sp;
                  l_totalurl := l_totalurl || 'Y';
                  insert into biv_tmp_bin (report_code,session_id,col2,col4,col3) select biv_core_pkg.g_report_id,biv_core_pkg.get_session_id,
                                         l_total,decode(sum(col4),null,0,sum(col4)),l_totalurl from biv_tmp_bin;
                end if;
	        -- Change for enh 2914005 ends
		EXCEPTION
		WHEN OTHERS THEN
                   if (g_debug_flag = 'Y') then
			g_err := 'Err in BIV_DASH_BIN_PKG.load_sr_bin:' ||
						substr(sqlerrm,1,500);
			biv_core_pkg.biv_debug(g_err,biv_core_pkg.g_report_id);
                   end if;
	END load_sr_bin;

    -- Service Request Summary Report - Monitor
  PROCEDURE load_sr_sum_report(p_param_str IN VARCHAR2 /*DEFAULT NULL*/) IS
   l_report_code VARCHAR2(30) := 'BIV_RT_SR_SUM_MONITOR';
	x_where_clause varchar2(1000);
	l_query VARCHAR2(3000);
	l_select VARCHAR2(1000);
	l_table VARCHAR2(500);
	l_where VARCHAR2(1000);
	l_cur_id  PLS_INTEGER;
	l_return_num PLS_INTEGER := 0;
	l_url_param VARCHAR2(50);
  	l_ogrp VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_OGRP');
 	l_agrp VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_AGRP');
 	l_mgr_id VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_MGR_ID');
        l_ttl_recs number;
        l_ttl_meaning fnd_lookups.meaning % type :=
                          biv_core_pkg.get_lookup_meaning('TOTAL');
        l_param_str biv_tmp_rt1.col1 % type;
 BEGIN
        biv_core_pkg.g_report_id := l_report_code;
	biv_core_pkg.clean_dcf_table('BIV_TMP_RT1');
	g_session_id := biv_core_pkg.get_session_id;
        if (g_debug_flag = 'Y') then
            biv_core_pkg.biv_debug('Start of Report, Params:'||
                                   p_param_str,biv_core_pkg.g_report_id);
        end if;
	biv_core_pkg.get_report_parameters(p_param_str);

	-- build extra params
	l_url_param := g_p_sp;
	if l_ogrp is not null then
		l_url_param := l_url_param || 'P_OGRP' || g_v_sp || l_ogrp || g_p_sp;
	end if;
	if l_agrp is not null then
		l_url_param := l_url_param || 'P_AGRP' || g_v_sp || l_agrp || g_p_sp;
	end if;
	if l_mgr_id is not null then
		l_url_param := l_url_param || 'P_MGR_ID' || g_v_sp || l_mgr_id || g_p_sp;
	end if;

	l_select := 'INSERT INTO biv_tmp_rt1(report_code,session_id,col2, col3, col4, ';
	l_select := l_select || 'col5, col6, col7, col8,col20) ';
	l_select := l_select || 'SELECT :l_report_code,:x_session_id,stat.name, ';
	l_select := l_select || '''BIV_RT_SR_SEV' || g_p_sp || 'jtfBinId';
	l_select := l_select || g_v_sp || 'BIV_RT_SR_SEV' || g_p_sp;
	l_select := l_select || 'P_CHNL' || g_v_sp || 'WEB' || g_p_sp;
	l_select := l_select || 'P_STS_ID' || g_v_sp || '''||';
	l_select := l_select || 'stat.incident_status_id||'''||l_url_param||''', ';
	l_select := l_select || 'sum(decode(upper(sr.sr_creation_channel),''WEB'',1,0)), ';
	l_select := l_select || '''BIV_RT_SR_SEV' || g_p_sp || 'jtfBinId';
	l_select := l_select || g_v_sp || 'BIV_RT_SR_SEV' || g_p_sp;
	l_select := l_select || 'P_CHNL' || g_v_sp || 'PHONE' || g_p_sp;
	l_select := l_select || 'P_STS_ID' || g_v_sp || '''||';
	l_select := l_select || 'stat.incident_status_id||'''||l_url_param||''', ';
	l_select := l_select || 'sum(decode(upper(sr.sr_creation_channel),''PHONE'',1,0)), ';
	l_select := l_select || '''BIV_RT_SR_SEV' || g_p_sp || 'jtfBinId';
	l_select := l_select || g_v_sp || 'BIV_RT_SR_SEV' || g_p_sp;
	l_select := l_select || 'P_ESC_SR' || g_v_sp || 'Y' || g_p_sp;
	l_select := l_select || 'P_STS_ID' || g_v_sp || '''||';
	l_select := l_select || 'stat.incident_status_id||'''||l_url_param||''', ';
	l_select := l_select || 'biv_dash_bin_pkg.get_esc_sr_backlog(1,stat.incident_status_id) ,''INDV_ROW''';


	l_table := 'FROM cs_incident_statuses_vl stat, cs_incidents_vl_sec sr ';

	biv_core_pkg.get_where_clause(l_table,x_where_clause);
        -- table and where clause to get escalated SR count.
        -- this will be used in get_esc_sr_backlog
        -- Change for Bug 3386946
        g_esc_frm_lst := ' from cs_incidents_b_sec sr,
                                jtf_task_references_b ref,
                                jtf_tasks_b task ';
	biv_core_pkg.get_where_clause(g_esc_frm_lst,g_esc_whr_cls);
        g_esc_whr_cls := g_esc_whr_cls || '
                         and sr.incident_id = ref.object_id
                         and ref.task_id      = task.task_id
                         and ref.object_type_code = ''SR''
                         and ref.reference_code   = ''ESC''
                         and task.task_type_id     = 22
                         and task.escalation_level is not null
                         and sr.incident_status_id = :p_status ';
        g_esc_sel_stt := 'select count(sr.incident_id)
                         ' || g_esc_frm_lst || g_esc_whr_cls;
        if (g_debug_flag = 'Y') then
           biv_core_pkg.biv_debug('statement for escalated SR',
                                                biv_core_pkg.g_report_id);
           biv_core_pkg.biv_debug(g_esc_sel_stt,biv_core_pkg.g_report_id);
        end if;

	l_where := x_where_clause || ' ' || '
			and nvl(stat.close_flag,''N'') != ''Y''
			and stat.incident_subtype = ''INC''
			and sr.incident_status_id = stat.incident_status_id
		GROUP BY stat.incident_status_id,stat.name,stat.description
		';

	l_query := l_select || ' ' || l_table || ' '|| l_where;

	if g_debug_flag = 'Y' then
		biv_core_pkg.biv_debug(l_query,l_report_code);
		commit;
	end if;

	l_cur_id := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_cur_id,l_query,DBMS_SQL.NATIVE);
	biv_core_pkg.bind_all_variables(l_cur_id);
   DBMS_SQL.BIND_VARIABLE(l_cur_id,':l_report_code',l_report_code);
   DBMS_SQL.BIND_VARIABLE(l_cur_id,':x_session_id' ,g_session_id);
	l_return_num := DBMS_SQL.EXECUTE(l_cur_id);
	DBMS_SQL.CLOSE_CURSOR(l_cur_id);
        --
        -- Add total Row
        --
        select count(*) into l_ttl_recs
          from biv_tmp_rt1
         where report_code = l_report_code
           and session_id = g_session_id;
        if (g_debug_flag = 'Y') then
           biv_core_pkg.biv_debug('Total Records:' || to_char(l_ttl_recs),
                                  l_report_code);
        end if;
        if (l_ttl_recs > 1 /*and l_ttl_recs < biv_core_pkg.g_disp*/) then
           l_param_str := 'BIV_RT_SR_SEV' || g_p_sp || 'jtfBinId' ||
                       g_v_sp || 'BIV_RT_SR_SEV' || g_p_sp || l_url_param ||
                       'P_BLOG' || g_v_sp || 'Y' || g_p_sp;
           if (g_debug_flag = 'Y') then
              biv_core_pkg.biv_debug('going to insert total row',
                                                              l_report_code);
           end if;
           insert into biv_tmp_rt1 (report_code,session_id,
                                    col2,col4,col6,col8,col20,
                                    col3, col5, col7)
           select l_report_code, g_session_id, l_ttl_meaning, sum(col4),
                  sum(col6), sum(col8), 'TTL_ROW',
                  l_param_str || 'P_CHNL' || g_v_sp || 'WEB',
                  l_param_str || 'P_CHNL' || g_v_sp || 'PHONE',
                  l_param_str || 'P_ESC_SR' || g_v_sp || 'Y'
             from biv_tmp_rt1
            where report_code = l_report_code
              and session_id = g_session_id;
        end if;
        --
        --
        if (g_debug_flag = 'Y') then
           biv_core_pkg.biv_debug('End of Report',l_report_code);
        end if;

		EXCEPTION
		WHEN OTHERS THEN
                  if (g_debug_flag = 'Y') then
			g_err := 'Err in BIV_DASH_BIN_PKG.load_sr_bin:' ||
						substr(sqlerrm,1,500);
			biv_core_pkg.biv_debug(g_err,l_report_code);
                  end if;

  END load_sr_sum_report;

    -- Service Request Severity Report
  PROCEDURE load_sr_sev_report(p_param_str IN VARCHAR2 /*DEFAULT NULL*/) IS
	x_where_clause varchar2(1000);
	l_query VARCHAR2(3000);
	l_select VARCHAR2(1000);
	l_table VARCHAR2(500);
	l_where VARCHAR2(1000);
	l_cur_id  PLS_INTEGER;
	l_return_num PLS_INTEGER := 0;
    l_report_code VARCHAR2(30) := 'BIV_RT_SR_SEV';
    l_channel VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_CHNL');
    l_status VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_STS_ID');
    l_esc VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_ESC_SR');
	 l_url_param VARCHAR2(50);
  	 l_ogrp VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_OGRP');
 	 l_agrp VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_AGRP');
 	 l_mgr_id VARCHAR2(20) := biv_core_pkg.get_parameter_value(p_param_str,'P_MGR_ID');
  BEGIN
        biv_core_pkg.g_report_id := l_report_code;
	biv_core_pkg.clean_dcf_table('BIV_TMP_RT1');
	g_session_id := biv_core_pkg.get_session_id;
        if (g_debug_flag = 'Y') then
           biv_core_pkg.biv_debug('Start of Report, Params:'||
                            p_param_str,biv_core_pkg.g_report_id);
        end if;
	biv_core_pkg.get_report_parameters(p_param_str);

	-- build extra params
	l_url_param := g_p_sp;
	if l_ogrp is not null then
		l_url_param := l_url_param || 'P_OGRP' || g_v_sp || l_ogrp || g_p_sp;
	end if;
	if l_agrp is not null then
		l_url_param := l_url_param || 'P_AGRP' || g_v_sp || l_agrp || g_p_sp;
	end if;
	if l_mgr_id is not null then
		l_url_param := l_url_param || 'P_MGR_ID' || g_v_sp || l_mgr_id || g_p_sp;
	end if;
        l_url_param := l_url_param || 'P_BLOG' || g_v_sp || 'Y' || g_p_sp;

    If ( l_esc is not NULL ) then
        l_select := l_select || 'INSERT INTO biv_tmp_rt1(report_code,session_id,col2,col3,col4,col5,col6) ';
        l_select := l_select || 'select :l_report_code,:g_session_id,c.NAME, ';
        l_select := l_select || '''BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp;
        l_select := l_select || 'BIV_SERVICE_REQUEST';
        l_select := l_select || g_p_sp||'P_ESC_SR'||g_v_sp||'Y'||g_p_sp||'P_STS_ID'||g_v_sp;
        l_select := l_select || l_status||g_p_sp||'P_SEV'||g_v_sp||'''||c.incident_severity_id||'''||l_url_param||''', ';
        l_select := l_select || ' count(sr.incident_id),';
        l_select := l_select || '''BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp;
        l_select := l_select || 'BIV_SERVICE_REQUEST';
        l_select := l_select || g_p_sp||'P_ESC_SR'||g_v_sp||'Y'||g_p_sp||'P_STS_ID'||g_v_sp;
        l_select := l_select || l_status||g_p_sp||'P_SEV'||g_v_sp||'''||c.incident_severity_id||'''||l_url_param||''', ';
        l_select := l_select || 'BIV_DASH_BIN_PKG.get_hours(min(sr.incident_date)) ';

        -- Change for Bug 3386946
        l_table := l_table || ' from cs_incidents_vl_sec sr, ';
        l_table := l_table || ' cs_incident_statuses_b stat, ';
        l_table := l_table || ' cs_incident_severities_vl c, ';
        l_table := l_table || ' jtf_task_references_b r, ';
        l_table := l_table || ' jtf_tasks_b task ';

		  biv_core_pkg.get_where_clause(l_table,x_where_clause);

	     l_where := x_where_clause || ' and sr.incident_status_id = stat.incident_status_id ';
        l_where := l_where || ' and sr.incident_severity_id = c.incident_severity_id ';
        --already coming from core pkg
        --l_where := l_where || ' and nvl(b.close_flag,''N'') != ''Y'' ';
        if (l_status is not null) then
           l_where := l_where || ' and sr.incident_status_id = '||l_status||' ';
        end if;
        l_where := l_where || ' and sr.incident_id = r.object_id ';
        l_where := l_where || ' and r.task_id      = task.task_id ';
        l_where := l_where || ' and r.object_type_code = ''SR'' ';
        l_where := l_where || ' and r.reference_code   = ''ESC'' ';
        l_where := l_where || ' and task.task_type_id     = 22 ';
        l_where := l_where || ' group by c.NAME,c.incident_severity_id ';
    else
        l_select := l_select || 'INSERT INTO biv_tmp_rt1(report_code,session_id,col2,col3,col4,col5,col6) ';
        l_select := l_select || 'select :l_report_code,:g_session_id,c.NAME, ';
        l_select := l_select || '''BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp;
        l_select := l_select || 'BIV_SERVICE_REQUEST';
        l_select := l_select || g_p_sp||'P_CHNL'||g_v_sp||l_channel||g_p_sp||'P_STS_ID'||g_v_sp;
        l_select := l_select || l_status||g_p_sp||'P_SEV'||g_v_sp||'''||c.incident_severity_id||'''||l_url_param||''', ';
        l_select := l_select || ' count(sr.incident_id), ';
        l_select := l_select || '''BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp;
        l_select := l_select || 'BIV_SERVICE_REQUEST';
        l_select := l_select || g_p_sp||'P_CHNL'||g_v_sp||l_channel||g_p_sp||'P_STS_ID'||g_v_sp;
        l_select := l_select || l_status||g_p_sp||'P_SEV'||g_v_sp||'''||c.incident_severity_id||'''||l_url_param||''', ';
        l_select := l_select || 'BIV_DASH_BIN_PKG.get_hours(min(sr.incident_date)) ';

        -- Change for Bug 3386946
        l_table := l_table || ' from cs_incidents_vl_sec sr, ';
       -- l_table := l_table || ' cs_incident_statuses_b b, ';
        l_table := l_table || ' cs_incident_severities_vl c ';

		  biv_core_pkg.get_where_clause(l_table,x_where_clause);

	--     l_where := x_where_clause || ' and sr.incident_status_id = b.incident_status_id ';
        l_where := x_where_clause;
        l_where := l_where || ' and sr.incident_severity_id = c.incident_severity_id ';
/********** 5/13/02 these two are added automatically by get_where_clause
            call.
        l_where := l_where || ' and nvl(b.close_flag,''N'') != ''Y'' ';
        l_where := l_where || ' and UPPER(sr.sr_creation_channel) = UPPER('''||l_channel||''') ';
        l_where := l_where || ' and sr.incident_status_id = '||l_status||' ';
*********************************************************/
        l_where := l_where || ' group by c.NAME,c.incident_severity_id ';
    end if;

	l_query := l_select || ' ' || l_table || ' '|| l_where;

	if g_debug_flag = 'Y' then
		biv_core_pkg.biv_debug(l_query,l_report_code);
		commit;
	end if;

	l_cur_id := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_cur_id,l_query,DBMS_SQL.NATIVE);
	biv_core_pkg.bind_all_variables(l_cur_id);
   DBMS_SQL.BIND_VARIABLE(l_cur_id,':l_report_code',l_report_code);
   DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_session_id',g_session_id);
	l_return_num := DBMS_SQL.EXECUTE(l_cur_id);
	DBMS_SQL.CLOSE_CURSOR(l_cur_id);
        if (g_debug_flag = 'Y') then
           biv_core_pkg.biv_debug('End of Report, Params:',
                                biv_core_pkg.g_report_id);
        end if;

		EXCEPTION
		WHEN OTHERS THEN
                   if (g_debug_flag = 'Y') then
			g_err := 'Err in BIV_DASH_BIN_PKG.load_srsev_report:' ||
						substr(sqlerrm,1,500);
			biv_core_pkg.biv_debug(g_err,l_report_code);
                   end if;

  END load_sr_sev_report;

    -- Get the Service Severity Report Label
  FUNCTION get_sr_sev_report_name(p_param_str IN VARCHAR2 /*DEFAULT NULL*/) RETURN VARCHAR2 IS
    l_report_name VARCHAR2(100);
    l_tmp VARCHAR2(100);
    l_report_code VARCHAR2(30) := 'BIV_DASH_SR_SEV_REPORT';
    l_channel VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_CHNL');
    l_status VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_STS_ID');
    l_esc VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_ESC_LVL');
  BEGIN
    -- get the first word in the report name
    select attribute_label_long into l_report_name
    from ak_attributes_vl
    where attribute_code = 'P_SR_SEV_RPT_1';

    -- getting the second word
    if l_channel = 'WEB' then
        select attribute_label_long into l_tmp
        from ak_attributes_vl
        where attribute_code = 'P_SR_SEV_RPT_3';
    elsif l_channel = 'PHONE' then
        select attribute_label_long into l_tmp
        from ak_attributes_vl
        where attribute_code = 'P_SR_SEV_RPT_4';
    else
        select attribute_label_long into l_tmp
        from ak_attributes_vl
        where attribute_code = 'P_SR_SEV_RPT_5';
    end if;
    l_report_name := l_report_name || ' ' || l_tmp;

    -- get the third part
    select attribute_label_long into l_tmp
    from ak_attributes_vl
    where attribute_code = 'P_SR_SEV_RPT_2';
    l_report_name := l_report_name || ' ' || l_tmp;

    -- get the last part
    SELECT name INTO l_tmp
    FROM cs_incident_statuses_vl
    WHERE incident_status_id = to_number(l_status);

    l_report_name := l_report_name || ' : ' || l_tmp;

    return l_report_name;
  END get_sr_sev_report_name;

    -- Get the Service Severity Report Label
  FUNCTION get_sr_sev_column_label(p_param_str IN VARCHAR2 /*DEFAULT NULL*/) RETURN VARCHAR2 IS
    l_label VARCHAR2(100);
    l_tmp VARCHAR2(100);
    l_report_code VARCHAR2(30) := 'BIV_DASH_SR_SEV_REPORT';
    l_channel VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_CHNL');
    l_status VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_STS_ID');
    l_esc VARCHAR2(30) := biv_core_pkg.get_parameter_value(p_param_str,'P_ESC_LVL');
  BEGIN
    -- get the first word in the report name
    select attribute_label_long into l_label
    from ak_attributes_vl
    where attribute_code = 'P_SR_SEV_RPT_6';

    -- getting the second word
    if l_channel = 'WEB' then
        select attribute_label_long into l_tmp
        from ak_attributes_vl
        where attribute_code = 'P_SR_SEV_RPT_3';
    elsif l_channel = 'PHONE' then
        select attribute_label_long into l_tmp
        from ak_attributes_vl
        where attribute_code = 'P_SR_SEV_RPT_4';
    else
        select attribute_label_long into l_tmp
        from ak_attributes_vl
        where attribute_code = 'P_SR_SEV_RPT_5';
    end if;
    l_label := l_label || ' ' || l_tmp;

    -- get the third part
    select attribute_label_long into l_tmp
    from ak_attributes_vl
    where attribute_code = 'P_SR_SEV_RPT_7';
    l_label := l_label || ' ' || l_tmp;

    -- get the fourth part
    SELECT name INTO l_tmp
    FROM cs_incident_statuses_vl
    WHERE incident_status_id = to_number(l_status);

    l_label := l_label || ' ' || l_tmp;

    -- get the last part
    select attribute_label_long into l_tmp
    from ak_attributes_vl
    where attribute_code = 'P_SR_SEV_RPT_8';
    l_label := l_label || ' ' || l_tmp;

    return l_label;
  END get_sr_sev_column_label;

  -----------------------------------------------------
  function  get_esc_sr_backlog(p_owner number, p_status number) return number is
    x_val number;
    l_cur number;
    l_dummy number;
  begin
    /*
    select count(ina.incident_id) into x_val
    FROM
        cs_incidents_all_b ina,
        jtf_task_references_b r, jtf_tasks_b t
    WHERE ina.incident_id = r.object_id
          and r.task_id      = t.task_id
          and r.object_type_code = 'SR'
          and r.reference_code   = 'ESC'
          and t.task_type_id     = 22
          and t.escalation_level is not null
          and ina.incident_status_id = p_status;
    */
   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,g_esc_sel_stt,dbms_sql.native);
   biv_core_pkg.bind_all_variables(l_cur);
   dbms_sql.bind_variable(l_cur,':p_status', p_status);
   dbms_sql.define_column(l_cur,1,x_val);
   l_dummy := dbms_sql.execute(l_cur);
   IF dbms_sql.fetch_rows(l_cur) > 0 then
     dbms_sql.column_value(l_cur, 1, x_val);
   else x_val := 0;
   dbms_sql.close_cursor(l_cur);
   end if;
    return(x_val);
    exception
      when others then
        return 0;
  end get_esc_sr_backlog;

  ------------------------------
  -- return Y if a SR is escalated
  -- return N if not
  ------------------------------
  function check_esc (p_sr_id number) return varchar2 is
    x_esc_flag VARCHAR2(1);
  begin

    select decode(count(*),0,'N','Y') into x_esc_flag
    from jtf_task_references_b r,jtf_tasks_b t
    where r.OBJECT_ID = p_sr_id
    and r.object_type_code = 'SR'
    and r.reference_code   = 'ESC'
    and r.task_id          = t.task_id
    and t.task_type_id     = 22;

    return x_esc_flag;
  end check_esc;

  ------------------------------
  -- convert number of days to HH:MM:SS
  ------------------------------
  function get_hours (p_day Date) return varchar2 is
    x_date_str VARCHAR2(100);
    l_total_hours NUMBER;
    l_tmp NUMBER;
  begin
    -- convert number of days to hours
    l_total_hours :=  (sysdate-p_day)*24;

    x_date_str := trunc(l_total_hours) || ':';

    -- get mins
    l_tmp := (l_total_hours - trunc(l_total_hours)) * 60;
    if (trunc(l_tmp) < 10) then
        x_date_str := x_date_str || '0' || trunc(l_tmp) || ':';
    else
        x_date_str := x_date_str || trunc(l_tmp) || ':';
    end if;

    -- get sec
    l_tmp := (l_tmp - trunc(l_tmp)) * 60;

    if (trunc(l_tmp) < 10) then
        x_date_str := x_date_str || '0' || trunc(l_tmp);
    else
        x_date_str := x_date_str || trunc(l_tmp);
    end if;

    return x_date_str;
  end get_hours;
END;

/
