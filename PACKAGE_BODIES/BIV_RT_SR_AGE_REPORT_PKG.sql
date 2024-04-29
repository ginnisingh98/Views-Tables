--------------------------------------------------------
--  DDL for Package Body BIV_RT_SR_AGE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_RT_SR_AGE_REPORT_PKG" AS
	/* $Header: bivrblab.pls 115.15 2004/01/23 04:55:41 vganeshk ship $ */
	-- Service Request Backlog Age Report
	-- profile option
	g_err VARCHAR2(500);

	g_sev_1 NUMBER;
	g_sev_2 NUMBER;
	g_sev_3 NUMBER;
	g_sev_4 NUMBER;
	g_sev_5 NUMBER;

	-- global params
    g_agrp VARCHAR2(20);
    g_ogrp VARCHAR2(20);
	g_party_id VARCHAR2(20);
    g_cntr_id VARCHAR2(20);
	g_prod_id VARCHAR2(20);
    g_manager VARCHAR2(20);
	g_esc_level VARCHAR2(20);

	g_report_code VARCHAR2(30);
	g_extra_param VARCHAR2(1000);

	g_query VARCHAR2(5000);
	g_select VARCHAR2(3000);
	g_table VARCHAR2(1000);
	g_where VARCHAR2(1000);
	g_v_sp VARCHAR2(5) := biv_core_pkg.g_value_sep;
	g_p_sp VARCHAR2(5) := biv_core_pkg.g_param_sep;
	g_session_id NUMBER ;
	g_debug_flag VARCHAR2(1) := nvl(fnd_profile.value('BIV:DEBUG'),'N');

	PROCEDURE load_sr_backlog_age_report(p_param_str IN VARCHAR2 /*DEFAULT NULL*/) IS
		l_cur_id  PLS_INTEGER;
		l_return_num PLS_INTEGER := 0;
		l_total_label VARCHAR2(10);
      x_where_clause varchar2(2000);
	BEGIN
		biv_core_pkg.clean_dcf_table('BIV_TMP_HS2');
	g_session_id := biv_core_pkg.get_session_id;
		-- set profile options
		if g_debug_flag = 'Y' then
		   biv_core_pkg.biv_debug('Param Str:'||p_param_str,
                               g_report_code);
		end if;
		g_sev_1 := fnd_profile.value('BIV:INC_SEVERITY_1');
		g_sev_2 := fnd_profile.value('BIV:INC_SEVERITY_2');
		g_sev_3 := fnd_profile.value('BIV:INC_SEVERITY_3');
		g_sev_4 := fnd_profile.value('BIV:INC_SEVERITY_4');
		g_sev_5 := fnd_profile.value('BIV:INC_SEVERITY_5');

        if g_sev_1 is null then g_sev_1 := 0; end if;
        if g_sev_2 is null then g_sev_2 := 0; end if;
        if g_sev_3 is null then g_sev_3 := 0; end if;
        if g_sev_4 is null then g_sev_4 := 0; end if;
        if g_sev_5 is null then g_sev_5 := 0; end if;

		-- set params
		g_agrp := biv_core_pkg.get_parameter_value(p_param_str,'P_AGRP');
		g_ogrp := biv_core_pkg.get_parameter_value(p_param_str,'P_OGRP');
		g_party_id := biv_core_pkg.get_parameter_value(p_param_str,'P_CUST_ID');
		g_cntr_id := biv_core_pkg.get_parameter_value(p_param_str,'P_CNTR_ID');
		g_prod_id := biv_core_pkg.get_parameter_value(p_param_str,'P_PRD_ID');
		g_manager := biv_core_pkg.get_parameter_value(p_param_str,'P_MGR_ID');
		g_esc_level := biv_core_pkg.get_parameter_value(p_param_str,'P_ESC_LVL');

		-- set report code
		g_report_code            := 'BIV_RT_SR_AGE_REPORT';
                biv_core_pkg.g_report_id := 'BIV_RT_SR_AGE_REPORT';

		-- set extra URL
		g_extra_param := get_extra_param;

		-- build query
      biv_core_pkg.get_report_parameters(p_param_str);
		g_select := get_select;
		g_table := get_table;
      biv_core_pkg.get_where_clause(g_table,x_where_clause);
		g_where := x_where_clause || get_where;

		g_query := g_select || ' '||  g_table || ' '||  g_where;
		g_query := g_query || ' group by ins.name, sr.incident_status_id order by ins.name ';

		if g_debug_flag = 'Y' then
			biv_core_pkg.biv_debug(g_query,g_report_code);
			biv_core_pkg.biv_debug('session_id:'||
                                    to_char(g_session_id),g_report_code);
			commit;
		end if;

		l_cur_id := DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(l_cur_id,g_query,DBMS_SQL.NATIVE);
        biv_core_pkg.bind_all_variables(l_cur_id);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':session_id',g_session_id);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_1_a',g_sev_1);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_2_a',g_sev_2);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_3_a',g_sev_3);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_4_a',g_sev_4);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_5_a',g_sev_5);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_1_b',g_sev_1);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_2_b',g_sev_2);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_3_b',g_sev_3);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_4_b',g_sev_4);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_5_b',g_sev_5);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_1_c',g_sev_1);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_2_c',g_sev_2);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_3_c',g_sev_3);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_4_c',g_sev_4);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_sev_5_c',g_sev_5);
        DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_report_code',g_report_code);
		l_return_num := DBMS_SQL.EXECUTE(l_cur_id);
		DBMS_SQL.CLOSE_CURSOR(l_cur_id);
                commit;

		-- update the average, URL
                if (g_debug_flag = 'Y') then
                   biv_core_pkg.biv_debug('Updating Hyperlinks',g_report_code);
                end if;
		UPDATE biv_tmp_hs2
			SET col3 = 'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_STS_ID'||g_v_sp||col3||g_p_sp||'P_SEV'||g_v_sp||g_sev_1||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
			col7 = 'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_STS_ID'||g_v_sp||col7||g_p_sp||'P_SEV'||g_v_sp||g_sev_2||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
			col11 = 'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_STS_ID'||g_v_sp||col11||g_p_sp||'P_SEV'||g_v_sp||g_sev_3||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
			col15 = 'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_STS_ID'||g_v_sp||col15||g_p_sp||'P_SEV'||g_v_sp||g_sev_4||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
			col19 = 'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_STS_ID'||g_v_sp||col19||g_p_sp||'P_SEV'||g_v_sp||g_sev_5||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
			col6 = decode(col4,0,0,round(col6/col4)),
			col10 = decode(col8,0,0,round(col10/col8)),
			col14 = decode(col12,0,0,round(col14/col12)),
			col18 = decode(col16,0,0,round(col18/col16)),
			col22 = decode(col20,0,0,round(col22/col20)),
                        rowno = 1
		where session_id = biv_core_pkg.get_session_id;
             commit;

		select attribute_label_long INTO l_total_label
        from ak_attributes_vl
        where attribute_code = 'P_SR_SEV_RPT_6'
        and attribute_application_id = 862;

                if (g_debug_flag = 'Y') then
                   biv_core_pkg.biv_debug('Adding Total Row',g_report_code);
                end if;
		-- insert the total row
		INSERT INTO biv_tmp_hs2 (report_code,session_id,col2,
												col3,col4,col6,
												col7,col8,col10,
												col11,col12,col14,
												col15,col16,col18,
												col19,col20,col22,col24,rowno)
		select g_report_code,g_session_id,l_total_label,
		'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_SEV'||g_v_sp||g_sev_1||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
		nvl(sum(col4),0),
		'',
		'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_SEV'||g_v_sp||g_sev_2||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
		nvl(sum(col8),0),
		'',
		'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_SEV'||g_v_sp||g_sev_3||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
		nvl(sum(col12),0),
		'',
		'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_SEV'||g_v_sp||g_sev_4||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
		nvl(sum(col16),0),
		'',
		'BIV_SERVICE_REQUEST'||g_p_sp||'jtfBinId'||g_v_sp||'BIV_SERVICE_REQUEST'||g_p_sp||'P_SEV'||g_v_sp||g_sev_5||g_p_sp||'P_BLOG'||g_v_sp||'Y'||g_extra_param,
		nvl(sum(col20),0),
		'',
		'',2 FROM biv_tmp_hs2
		where session_id = biv_core_pkg.get_session_id
		;

                commit;
                if (g_debug_flag = 'Y') then
                   biv_core_pkg.biv_debug('End of report',g_report_code);
                end if;
		EXCEPTION
		WHEN OTHERS THEN
                  rollback;
                  if (g_debug_flag = 'Y') then
	             g_err := 'Err in BIV_RT_SR_AGE_REPORT_PKG.' ||
                              'load_sr_backlog_age_report:' ||
                              substr(sqlerrm,1,500);
		     biv_core_pkg.biv_debug(g_err,g_report_code);
                 end if;

	END load_sr_backlog_age_report;


	-- build the select statement
	FUNCTION  get_select RETURN VARCHAR2 IS
		l_select_stmt varchar2(3000);
	BEGIN
		l_select_stmt := '
			INSERT INTO biv_tmp_hs2 (report_code,session_id,col2,
													col3,col4,col6,
													col7,col8,col10,
													col11,col12,col14,
													col15,col16,col18,
													col19,col20,col22,col24)
			select :g_report_code ,:session_id,ins.name,
			sr.incident_status_id,
			sum(decode(sr.incident_severity_id,:g_sev_1_a,1,0)),
			sum(decode(sr.incident_severity_id,:g_sev_1_b,sysdate-sr.incident_date,0)),
			sr.incident_status_id,
		   sum(decode(sr.incident_severity_id,:g_sev_2_a,1,0)),
			sum(decode(sr.incident_severity_id,:g_sev_2_b,sysdate-sr.incident_date,0)),
			sr.incident_status_id,
		   sum(decode(sr.incident_severity_id,:g_sev_3_a,1,0)),
			sum(decode(sr.incident_severity_id,:g_sev_3_b,sysdate-sr.incident_date,0)),
			sr.incident_status_id,
		   sum(decode(sr.incident_severity_id,:g_sev_4_a,1,0)),
			sum(decode(sr.incident_severity_id,:g_sev_4_b,sysdate-sr.incident_date,0)),
			sr.incident_status_id,
		   sum(decode(sr.incident_severity_id,:g_sev_5_a,1,0)),
			sum(decode(sr.incident_severity_id,:g_sev_5_b,sysdate-sr.incident_date,0)),
		   (sum(decode(sr.incident_severity_id,:g_sev_1_c,1,0))+
		    sum(decode(sr.incident_severity_id,:g_sev_2_c,1,0))+
		    sum(decode(sr.incident_severity_id,:g_sev_3_c,1,0))+
		    sum(decode(sr.incident_severity_id,:g_sev_4_c,1,0))+
		    sum(decode(sr.incident_severity_id,:g_sev_5_c,1,0)))
	    	';
		return l_select_stmt;
	END get_select;

	-- build the table stmt
	FUNCTION get_table RETURN VARCHAR2 IS
		l_table_str VARCHAR2(300);
	BEGIN
                -- Change for Bug 3386946
		l_table_str := ' from cs_incidents_b_sec sr, cs_incident_statuses_vl ins ';
--		l_table_str := l_table_str || ' cs_lookups clp, hz_parties p, ';
--		l_table_str := l_table_str || ' cs_incident_severities_b insv, ';
--		l_table_str := l_table_str || ' JTF_RS_EMP_DTLS_VL OWN ';
		return l_table_str;
	END get_table;

	-- build where clause
	FUNCTION get_where RETURN VARCHAR2 IS
		l_where_str VARCHAR2(1000);
	BEGIN
		l_where_str := ' ';
	--	l_where_str := l_where_str || ' and sr.problem_code = clp.lookup_code (+) ';
	--	l_where_str := l_where_str || ' and clp.lookup_type(+) = ''REQUEST_PROBLEM_CODE'' ';
		l_where_str := l_where_str || ' and sr.incident_status_id = ins.incident_status_id ';
	--	l_where_str := l_where_str || ' and sr.customer_id = p.party_id(+) ';
	--	l_where_str := l_where_str || ' and sr.incident_owner_id = OWN.RESOURCE_ID (+) ';
	--	l_where_str := l_where_str || ' and sr.incident_severity_id = insv.incident_severity_id ';
		l_where_str := l_where_str || ' and sr.incident_status_id = ins.incident_status_id ';
		l_where_str := l_where_str || ' and nvl(ins.close_flag,''N'') != ''Y'' ';
		return l_where_str;
	END get_where;

	-- build the extra URL
	FUNCTION get_extra_param RETURN VARCHAR2 IS
		l_extra_url VARCHAR2(100);
	BEGIN
		l_extra_url := g_p_sp;
		if g_agrp is not null then
			l_extra_url := l_extra_url||'P_AGRP'||g_v_sp||g_agrp||g_p_sp;
		end if;
		if g_ogrp is not null then
			l_extra_url := l_extra_url||'P_OGRP'||g_v_sp||g_ogrp||g_p_sp;
		end if;
		if g_cntr_id is not null then
			l_extra_url := l_extra_url||'P_CNTR_ID'||g_v_sp||g_cntr_id||g_p_sp;
		end if;
		if g_manager is not null then
			l_extra_url := l_extra_url||'P_MGR_ID'||g_v_sp||g_manager||g_p_sp;
		end if;
		if g_party_id is not null then
                        -- Change for Bug 3044558
			l_extra_url := l_extra_url || 'P_CUST_ID'||g_v_sp||g_party_id||g_p_sp;
		end if;
		if g_prod_id is not null then
			l_extra_url := l_extra_url||'P_PRD_ID'||g_v_sp||g_prod_id||g_p_sp;
		end if;
		if g_esc_level is not null then
			l_extra_url := l_extra_url||'P_ESC_LVL'||g_v_sp||g_esc_level||g_p_sp;
		end if;
		return l_extra_url;
	END get_extra_param;


	-- Get Column Label
	FUNCTION get_sr_blog_col_1_label(p_param_str IN VARCHAR2 /*DEFAULT NULL*/)
		RETURN VARCHAR2 IS
    	l_label_1 VARCHAR2(20);
    	l_label_2 VARCHAR2(20);
	BEGIN
		-- get severity type
		SELECT a.name INTO l_label_1
		FROM cs_incident_severities_vl a
		WHERE a.incident_severity_id = fnd_profile.value('BIV:INC_SEVERITY_1');

		-- get "Severity"
		SELECT attribute_label_long INTO l_label_2
		FROM ak_attributes_vl
		WHERE attribute_application_id = 862
		AND attribute_code = 'P_DASH_SR_VIEW_11';

		return l_label_2 || ' ' || l_label_1;
	END get_sr_blog_col_1_label;

	FUNCTION get_sr_blog_col_2_label(p_param_str IN VARCHAR2 /*DEFAULT NULL*/)
		RETURN VARCHAR2 IS
    	l_label_1 VARCHAR2(20);
    	l_label_2 VARCHAR2(20);
	BEGIN
		-- get severity type
		SELECT a.name INTO l_label_1
		FROM cs_incident_severities_vl a
		WHERE a.incident_severity_id = fnd_profile.value('BIV:INC_SEVERITY_2');

		-- get "Severity"
		SELECT attribute_label_long INTO l_label_2
		FROM ak_attributes_vl
		WHERE attribute_application_id = 862
		AND attribute_code = 'P_DASH_SR_VIEW_11';

		return l_label_2 || ' ' || l_label_1;
	END get_sr_blog_col_2_label;

	FUNCTION get_sr_blog_col_3_label(p_param_str IN VARCHAR2 /*DEFAULT NULL*/)
		RETURN VARCHAR2 IS
    	l_label_1 VARCHAR2(20);
    	l_label_2 VARCHAR2(20);
	BEGIN
		-- get severity type
		SELECT a.name INTO l_label_1
		FROM cs_incident_severities_vl a
		WHERE a.incident_severity_id = fnd_profile.value('BIV:INC_SEVERITY_3');

		-- get "Severity"
		SELECT attribute_label_long INTO l_label_2
		FROM ak_attributes_vl
		WHERE attribute_application_id = 862
		AND attribute_code = 'P_DASH_SR_VIEW_11';

		return l_label_2 || ' ' || l_label_1;
	END get_sr_blog_col_3_label;

	FUNCTION get_sr_blog_col_4_label(p_param_str IN VARCHAR2 /*DEFAULT NULL*/)
		RETURN VARCHAR2 IS
    	l_label_1 VARCHAR2(20);
    	l_label_2 VARCHAR2(20);
	BEGIN
		-- get severity type
		SELECT a.name INTO l_label_1
		FROM cs_incident_severities_vl a
		WHERE a.incident_severity_id = fnd_profile.value('BIV:INC_SEVERITY_4');

		-- get "Severity"
		SELECT attribute_label_long INTO l_label_2
		FROM ak_attributes_vl
		WHERE attribute_application_id = 862
		AND attribute_code = 'P_DASH_SR_VIEW_11';

		return l_label_2 || ' ' || l_label_1;
	END get_sr_blog_col_4_label;

	FUNCTION get_sr_blog_col_5_label(p_param_str IN VARCHAR2 /*DEFAULT NULL*/)
		RETURN VARCHAR2 IS
    	l_label_1 VARCHAR2(20);
    	l_label_2 VARCHAR2(20);
	BEGIN
		-- get severity type
		SELECT a.name INTO l_label_1
		FROM cs_incident_severities_vl a
		WHERE a.incident_severity_id = fnd_profile.value('BIV:INC_SEVERITY_5');

		-- get "Severity"
		SELECT attribute_label_long INTO l_label_2
		FROM ak_attributes_vl
		WHERE attribute_application_id = 862
		AND attribute_code = 'P_DASH_SR_VIEW_11';

		return l_label_2 || ' ' || l_label_1;
	END get_sr_blog_col_5_label;


END BIV_RT_SR_AGE_REPORT_PKG;

/
