--------------------------------------------------------
--  DDL for Package Body BIV_HS_PROB_AVOID_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_HS_PROB_AVOID_REPORT_PKG" AS
	-- $Header: bivhprob.pls 115.23 2004/01/23 04:55:17 vganeshk ship $ */
	-- Problem Avoidence Report
	-- global params
	g_err VARCHAR2(500);
	g_prod_id VARCHAR2(20);
	g_product_version VARCHAR2(20);
	g_component VARCHAR2(20);
	g_subcomponent VARCHAR2(20);
	g_platform VARCHAR2(20);
	g_created_period_type VARCHAR2(20);
	g_created_start VARCHAR2(20);
	g_created_end VARCHAR2(20);
	g_closed_period_type VARCHAR2(20);
	g_closed_start VARCHAR2(20);
	g_closed_end VARCHAR2(20);

	g_report_code VARCHAR2(30);

	g_query VARCHAR2(2300);
	g_select VARCHAR2(1000);
	g_table VARCHAR2(300);
	g_where VARCHAR2(1000);
	g_v_sp VARCHAR2(5) := biv_core_pkg.g_value_sep;
	g_p_sp VARCHAR2(5) := biv_core_pkg.g_param_sep;
	g_session_id NUMBER ;
  	g_debug_flag VARCHAR2(1) ;

        /*** 1/30/03 this procedure is not used anymore **/
	PROCEDURE get_params (p_param_str in VARCHAR2) IS
	BEGIN
            /****
		g_prod_id := biv_core_pkg.get_parameter_value(p_param_str,'P_PRD_ID');
		g_product_version := biv_core_pkg.get_parameter_value(p_param_str,'P_PRD_VER');
		g_component := biv_core_pkg.get_parameter_value(p_param_str,'P_COMP_ID');
		g_subcomponent := biv_core_pkg.get_parameter_value(p_param_str,'P_SUBCOMP_ID');
		g_platform := biv_core_pkg.get_parameter_value(p_param_str,'P_PLATFORM_ID');
		g_created_period_type := biv_core_pkg.get_parameter_value(p_param_str,'P_CR_TM_PRD');
		g_created_start := biv_core_pkg.get_parameter_value(p_param_str,'P_CR_ST');
		g_created_end := biv_core_pkg.get_parameter_value(p_param_str,'P_CR_END');
		g_closed_period_type := biv_core_pkg.get_parameter_value(p_param_str,'P_CL_TM_PRD');
		g_closed_start := biv_core_pkg.get_parameter_value(p_param_str,'P_CL_ST');
		g_closed_end := biv_core_pkg.get_parameter_value(p_param_str,'P_CL_END');
            ****/
            null;
	END get_params;

--==============================================================================
-- Problem Avoidence Report
--==============================================================================
	PROCEDURE load_prob_avoid_rpt(p_param_str IN VARCHAR2 /*DEFAULT NULL*/) IS
		l_cur_id  PLS_INTEGER;
		l_return_num PLS_INTEGER := 0;
		l_start_date DATE;
		l_end_date DATE;
                l_ttl_recs number;
                l_session_id number := biv_core_pkg.get_session_id;
                l_ttl_meaning fnd_lookups.meaning % type :=
                                biv_core_pkg.get_lookup_meaning('TOTAL');
                l_param_for_drill varchar2(600);
	BEGIN
  	g_debug_flag := nvl(fnd_profile.value('BIV:DEBUG'),'N');
	g_session_id := biv_core_pkg.get_session_id;
	   biv_core_pkg.g_report_type := 'HS';
		biv_core_pkg.clean_dcf_table('BIV_TMP_HS1');
		-- report code
		g_report_code := 'BIV_HS_PROB_AVOID';
		-- get all param
		--get_params(p_param_str);
                biv_core_pkg.get_report_parameters(p_param_str);

		g_select := get_prob_avoid_rpt_select;
		g_table := get_prob_avoid_rpt_table;
                biv_core_pkg.get_where_clause(g_table,g_where);
		g_where := g_where || get_prob_avoid_rpt_where;

		g_query := g_select || g_table || g_where;

		if g_debug_flag = 'Y' then
		   biv_core_pkg.biv_debug('Parameter: '||p_param_str,
                                          g_report_code);
		   biv_core_pkg.biv_debug(g_query,g_report_code);
            	   commit;
		end if;

		l_cur_id := DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(l_cur_id,g_query,DBMS_SQL.NATIVE);
		DBMS_SQL.BIND_VARIABLE(l_cur_id,':g_report_code',g_report_code);

		-- sessionid also written to biv_debug
                if (g_debug_flag = 'Y') then
	           biv_core_pkg.biv_debug('SessionId: '||g_session_id,
                                          g_report_code);
                end if;

		DBMS_SQL.BIND_VARIABLE(l_cur_id,':session_id',g_session_id);
                biv_core_pkg.bind_all_variables(l_cur_id);
                dbms_sql.bind_variable(l_cur_id, ':session_id', l_session_id);
		l_return_num := DBMS_SQL.EXECUTE(l_cur_id);

		-- update the total percentage column
		g_query := 'UPDATE biv_tmp_hs1
						SET col12 =
						round((100*col12/(select sum(col10)
												from biv_tmp_hs1 b
												where b.report_code = ''BIV_HS_PROB_AVOID''
												and b.session_id =
												biv_core_pkg.get_session_id
												)),2)
						WHERE report_code = ''BIV_HS_PROB_AVOID'' and
						session_id = :session_id ';
		DBMS_SQL.PARSE(l_cur_id,g_query,DBMS_SQL.NATIVE);
		DBMS_SQL.BIND_VARIABLE(l_cur_id,':session_id',biv_core_pkg.get_session_id);
		l_return_num := DBMS_SQL.EXECUTE(l_cur_id);
		DBMS_SQL.CLOSE_CURSOR(l_cur_id);

      -- UPDATE COMP SUBCOMP DESC
      execute immediate '
      UPDATE biv_tmp_hs1
      set col6 = (select description from mtl_system_items_vl
                  where inventory_item_id = to_number(col6) and rownum = 1)
		WHERE report_code = ''BIV_HS_PROB_AVOID'' and
            session_id = :session_id and
            col6 is not null ' using biv_core_pkg.get_session_id;

      execute immediate '
      UPDATE biv_tmp_hs1
      set col8 = (select description from mtl_system_items_vl
                  where inventory_item_id = to_number(col8) and rownum = 1),
          col14 = 1
		WHERE report_code = ''BIV_HS_PROB_AVOID'' and
            session_id = :session_id and
            col8 is not null ' using biv_core_pkg.get_session_id;

      -- update drilldown link
      l_param_for_drill := 'BIV_HS_PROB_AVOID_RES' ||
                           biv_core_pkg.g_param_sep ||
                           biv_core_pkg.reconstruct_param_str;
      update biv_tmp_hs1
         set col9 = l_param_for_drill || 'P_PRD_ID' ||
                    biv_core_pkg.g_value_sep || nvl(col2,biv_core_pkg.g_null) ||
                    biv_core_pkg.g_param_sep || 'P_COMP_ID' ||
                    biv_core_pkg.g_value_sep || nvl(col5,biv_core_pkg.g_null) ||
                    biv_core_pkg.g_param_sep || 'P_SUBCOMP_ID' ||
                    biv_core_pkg.g_value_sep || nvl(col7,biv_core_pkg.g_null) ||
                    biv_core_pkg.g_param_sep
       where session_id = g_session_id
         and report_code = 'BIV_HS_PROB_AVOID';
      -- update drilldown link complete
      --- Add total Row
      select count(*) into l_ttl_recs
        from biv_tmp_hs1
       WHERE report_code = 'BIV_HS_PROB_AVOID' and
            session_id = biv_core_pkg.get_session_id;
      if (l_ttl_recs > 1 /*and l_ttl_recs < biv_core_pkg.g_disp*/ ) then
         if (g_debug_flag = 'Y') then
            biv_core_pkg.biv_debug('Inserting Total Row','BIV_HS_PROB_AVOID');
         end if;
         l_param_for_drill := 'BIV_HS_PROB_AVOID_RES' ||
                              biv_core_pkg.g_param_sep ||
                              biv_core_pkg.reconstruct_param_str;
         insert into biv_tmp_hs1(report_code, session_id, rowno, col2, col10,
                                 col14, col9)
           select 'BIV_HS_PROB_AVOID', l_session_id, max(rowno)+1,
                  l_ttl_meaning,sum(col10),2, l_param_for_drill
             from biv_tmp_hs1
            where report_code = 'BIV_HS_PROB_AVOID'
              and session_id = l_session_id;
      end if;
		EXCEPTION
		WHEN OTHERS THEN
                  if (g_debug_flag = 'Y') then
		     g_err := 'Err in BIV_HS_PROB_AVOID_REPORT_PKG. ' ||
                              'load_prob_avoid_rpt:' || substr(sqlerrm,1,500);
		     biv_core_pkg.biv_debug(g_err,'BIV_HS_PROB_AVOID');
                  end if;

	END load_prob_avoid_rpt;

	-- get select
	FUNCTION  get_prob_avoid_rpt_select RETURN VARCHAR2 IS
		l_select_stmt varchar2(1000);
           l_na_desc fnd_lookups.meaning%type :=
                             biv_core_pkg.get_lookup_meaning('NA');
	BEGIN
		l_select_stmt := 'INSERT INTO biv_tmp_hs1 (report_code, session_id,col2, ';
		l_select_stmt := l_select_stmt || 'col4,col6,col8,col10,col12,col5,col7) ';
		l_select_stmt := l_select_stmt || 'SELECT :g_report_code,  :session_id,';
		l_select_stmt := l_select_stmt || 'sr.inventory_item_id prod_id, ';
		l_select_stmt := l_select_stmt || 'substr(nvl(inv1.description,''' || l_na_desc || '''),1,50) product, ';
		l_select_stmt := l_select_stmt || 'sr.inv_component_id component, ';
		l_select_stmt := l_select_stmt || 'sr.inv_subcomponent_id subcomponent, ';

		l_select_stmt := l_select_stmt || '
			count(distinct sr.incident_id),
			count(distinct sr.incident_id),
                        sr.inv_component_id, sr.inv_subcomponent_id ';
		return l_select_stmt;
	END get_prob_avoid_rpt_select;

	-- get table
	FUNCTION  get_prob_avoid_rpt_table RETURN VARCHAR2 IS
		l_table_stmt varchar2(500);
	BEGIN
                -- Change for Bug 3386946
		l_table_stmt := '
		FROM
			cs_incidents_b_sec sr,
			mtl_system_items_vl  inv1
		';
		return l_table_stmt;
	END get_prob_avoid_rpt_table;

	-- get where
	FUNCTION  get_prob_avoid_rpt_where RETURN VARCHAR2 IS
		l_where_stmt varchar2(1000);
	BEGIN
	-- put outter join on inv* columns when testing
	-- there are many null column in inv*
		l_where_stmt := '
		and inv1.organization_id (+)= fnd_profile.value(''CS_INV_VALIDATION_ORG'')
			and sr.inventory_item_id = inv1.inventory_item_id(+)  ';



		l_where_stmt := l_where_stmt || '
		GROUP BY
			sr.inventory_item_id,
			inv1.description,
			sr.inv_component_id,
			sr.inv_subcomponent_id ';

		if g_platform is not null then
			l_where_stmt := l_where_stmt || '
			 ,sr.platform_id
			';
		end if;

		return l_where_stmt;
	END get_prob_avoid_rpt_where;


--==============================================================================
-- Problem Avoidance Resolution Report
--==============================================================================
	PROCEDURE load_prob_avoid_res_rpt(p_param_str IN VARCHAR2 /*DEFAULT NULL*/) IS
		l_cur_id  PLS_INTEGER;
		l_return_num PLS_INTEGER := 0;
		l_start_date DATE;
		l_end_date DATE;
                l_new_param_str varchar2(500);
	BEGIN
  	g_debug_flag := nvl(fnd_profile.value('BIV:DEBUG'),'N');
	g_session_id := biv_core_pkg.get_session_id;
		biv_core_pkg.g_report_type := 'HS';
		biv_core_pkg.clean_dcf_table('BIV_TMP_HS1');
		-- report code
		g_report_code := 'BIV_HS_PROB_AVOID_RES';
		-- get all param
		--get_params(p_param_str);
                biv_core_pkg.get_report_parameters(p_param_str);

		g_select := get_prob_avoid_res_rpt_select;
		g_table := get_prob_avoid_res_rpt_table;
                biv_core_pkg.get_where_clause(g_table,g_where);
		g_where := g_where || get_prob_avoid_res_rpt_where;

		g_query := g_select || g_table || g_where;

		if g_debug_flag = 'Y' then
		        biv_core_pkg.biv_debug('Parameter: '||p_param_str,
                                               g_report_code);
			biv_core_pkg.biv_debug(g_query,g_report_code);
			commit;
		end if;

		l_cur_id := DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(l_cur_id,g_query,DBMS_SQL.NATIVE);
		DBMS_SQL.BIND_VARIABLE(l_cur_id,':report_code',g_report_code);
		DBMS_SQL.BIND_VARIABLE(l_cur_id,':session_id',g_session_id);

                biv_core_pkg.bind_all_variables(l_cur_id);
		l_return_num := DBMS_SQL.EXECUTE(l_cur_id);

		-- update the total percentage column
		g_query := 'UPDATE biv_tmp_hs1
						SET col4 =
						round((100*col4/(select sum(b.col2)
												from biv_tmp_hs1 b
												where b.report_code = ''BIV_HS_PROB_AVOID_RES''
												and b.session_id =
												biv_core_pkg.get_session_id
												)),2)
						WHERE report_code = ''BIV_HS_PROB_AVOID_RES'' and
						session_id = :session_id ';
		DBMS_SQL.PARSE(l_cur_id,g_query,DBMS_SQL.NATIVE);
		DBMS_SQL.BIND_VARIABLE(l_cur_id,':session_id',biv_core_pkg.get_session_id);
		l_return_num := DBMS_SQL.EXECUTE(l_cur_id);
		DBMS_SQL.CLOSE_CURSOR(l_cur_id);

                l_new_param_str := 'BIV_SERVICE_REQUEST' ||
                                   biv_core_pkg.g_param_sep ||
                                   biv_core_pkg.reconstruct_param_str;
                update biv_tmp_hs1
                  set col1 = l_new_param_str || 'P_RESL_CODE' ||
                             biv_core_pkg.g_value_sep ||
                             nvl(col5,biv_core_pkg.g_null) ||
                             biv_core_pkg.g_param_sep
                 where report_code = 'BIV_HS_PROB_AVOID_RES'
                   and session_id = g_session_id;
		EXCEPTION
		WHEN OTHERS THEN
                   if (g_debug_flag = 'Y') then
		      g_err := 'Err in BIV_HS_PROB_AVOID_REPORT_PKG.' ||
                            'load_prob_avoid_res_rpt:' || substr(sqlerrm,1,500);
		      biv_core_pkg.biv_debug(g_err,'BIV_HS_PROB_AVOID_RES');
                   end if;

	END load_prob_avoid_res_rpt;

	-- get select
	FUNCTION  get_prob_avoid_res_rpt_select RETURN VARCHAR2 IS
		l_select_stmt varchar2(1000);
	BEGIN
		l_select_stmt := 'INSERT INTO biv_tmp_hs1 (report_code,session_id,col2, ';
		l_select_stmt := l_select_stmt || 'col4,col5,col6) ';
		l_select_stmt := l_select_stmt || 'SELECT :report_code,:session_id, ';

		l_select_stmt := l_select_stmt || '
			count(sr.incident_id),
			count(sr.incident_id),sr.resolution_code,clr.meaning ';
		return l_select_stmt;
	END get_prob_avoid_res_rpt_select;

	-- get table
	FUNCTION  get_prob_avoid_res_rpt_table RETURN VARCHAR2 IS
		l_table_stmt varchar2(100);
	BEGIN
                -- Change for Bug 3386946
		l_table_stmt := '
		FROM
			cs_incidents_b_sec sr,
			cs_lookups clr	';
		return l_table_stmt;
	END get_prob_avoid_res_rpt_table;

	-- get where
	FUNCTION  get_prob_avoid_res_rpt_where RETURN VARCHAR2 IS
		l_where_stmt varchar2(1000);
	BEGIN
		l_where_stmt := '
		and
			sr.resolution_code = clr.lookup_code (+) and
			clr.lookup_type (+) = ''REQUEST_RESOLUTION_CODE'' ';
		l_where_stmt := l_where_stmt || '
		GROUP BY sr.resolution_code,
				clr.meaning ';


		return l_where_stmt;
	END get_prob_avoid_res_rpt_where;
END BIV_HS_PROB_AVOID_REPORT_PKG;

/
