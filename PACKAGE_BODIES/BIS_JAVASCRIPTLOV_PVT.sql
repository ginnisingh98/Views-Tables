--------------------------------------------------------
--  DDL for Package Body BIS_JAVASCRIPTLOV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_JAVASCRIPTLOV_PVT" AS
/* $Header: BISVJLOB.pls 120.1 2006/04/10 07:55:50 psomesul noship $ */
--  +==========================================================================+
--  |     Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA       |
--  |                           All rights reserved.                           |
--  +==========================================================================+
--  | FILENAME                                                                 |
--  |    BISVJLOB.pls                                                          |
--  |                                                                          |
--  | DESCRIPTION                                                              |
--  |    Body of Javascript LOV                                                |
--  | NOTES                                                                    |
--  |                                                                          |
--  | HISTORY                                                                  |
--  |                                           			       |
--  |21-Mar-2001  mdamle  Created					       |
--  |24-APR-2003  sugopal Made changes so that bislovwn.jsp uses bind variables
--  |                     instead of literals by constructing the sql with a
--  |                     bind variable in getLOVSQL for bug#2917806
--  |20-AUG-2003  rchandra Enh 2972146 ; added the where clause to link the
--  |                     bis_indicators and bsc_sys_datasets_b thru datasetid
--  |                     in getLOVsql function for Measure type lovs
--  |16-MAR-2004  ankgoel Modified for bug# 3463573                            |
--  | 22-APR-2005 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects  |
--  | 10-APR-05 psomesul Bug#5140269 - PERFORMANCE ISSUE WITH TARGET OWNER     |
--  |              LOV IN PMF PAGES - replaced WF_ROLES with WF_ROLE_LOV_VL    |
--  +==========================================================================+


PROCEDURE showLOV (p_lov_type           in varchar2
		  ,p_form_name          in varchar2
		  ,p_param_field   	in varchar2
		  ,p_param_id_field   	in varchar2 default NULL
		  ,p_filter             in varchar2 default ''
		  ,p_parameter1   	in varchar2 default NULL
		  ,p_parameter2   	in varchar2 default NULL
		  ,p_parameter3   	in varchar2 default NULL
		  ,p_parameter4   	in varchar2 default NULL
		  ,p_parameter5   	in varchar2 default NULL
		  ,p_callback_function  in varchar2 default NULL) IS

   type c1_cur_type is ref cursor;
   c1                       c1_cur_type;
   l_id    		    varchar2(1000);
   l_value       	    varchar2(1000);
   l_lov_sql  		    varchar2(32000);
   l_callback_function      varchar2(1000);
BEGIN
   htp.htmlOpen;
   htp.headOpen;
   htp.title('Valid Values');

   if p_callback_function is null then
   	l_callback_function := '';
   else
   	l_callback_function := 'self.opener.'||p_callback_function||';';
   end if;

   -- javascript functions
   htp.print('<script language="JavaScript">');
   htp.print('function closeLovWindow(fp_value, fp_id) {
       self.opener.document.'||p_form_name||'.'||p_param_field||'.value = fp_value;
	   if (fp_id != "")
	   	  self.opener.document.'||p_form_name||'.'||p_param_id_field||'.value = fp_id; '||
	   l_callback_function||'
       parent.self.close()}');
   htp.print('</script>');

   htp.headClose;
   htp.bodyOpen;


   l_lov_sql := getLOVSQL(p_lov_type, p_filter, p_parameter1, p_parameter2, p_parameter3, p_parameter4, p_parameter5);

   open c1 for l_lov_sql;
   loop
      fetch c1 into l_id, l_value;
      exit when c1%notfound;

	  if (p_param_id_field is null) then
	        htp.print('<a href="javascript:closeLovWindow('||''''||replace(l_value, '''', '\''') ||''', '''')">');
	  else
		htp.print('<a href="javascript:closeLovWindow('||''''||replace(l_value, '''', '\''') ||''','||''''||l_id||''')">');
	  end if;
      htp.print(l_value);
      htp.print('</a>');
      htp.br;
   end loop;

   close c1;
   htp.bodyClose;
   htp.htmlClose;

END showLOV;

FUNCTION getLOVSQL (p_lov_type          in varchar2
		    ,p_filter           in varchar2 default ''
		    ,p_parameter1   	in varchar2 default NULL
		    ,p_parameter2   	in varchar2 default NULL
		    ,p_parameter3   	in varchar2 default NULL
		    ,p_parameter4   	in varchar2 default NULL
		    ,p_parameter5   	in varchar2 default NULL) return varchar IS

l_lov_sql 	varchar2(32000);
l_where_clause  varchar2(32000);
l_temp    	varchar2(1000);
l_temp1    	varchar2(1000);

l_table_name varchar2(1000);
l_id_name varchar2(1000);
l_value_name varchar2(1000);
l_time_level varchar2(1000);
l_return_status varchar2(1000);
l_msg_count varchar2(1000);
l_msg_data varchar2(32000);
-- 2359096
  CURSOR c_source( cp_dim_level_short_name IN VARCHAR2) IS
    SELECT source
    FROM  bis_levels WHERE short_name = cp_dim_level_short_name ;

  l_source bis_levels.source%TYPE;
--2359096
  l_meas_src  VARCHAR2(10) := 'PMF';
BEGIN
	-- Add your SQL here
	-- Add your LOV Type constants in the Package Specification
	-- p_filter can be used as the initial filter
	-- p_parameter1...p_parameter5 can be used in your where clause for additional filtering if necessary

	if (p_lov_type = G_PERF_MEAS_S_LOV) or (p_lov_type = G_PERF_MEAS_R_LOV) then

		l_lov_sql := 'select measure_id, measure_name from bisfv_performance_measures  perfMeasuresList, BSC_SYS_DATASETS_B ds WHERE perfMeasuresList.dataset_id = ds.dataset_id AND perfMeasuresList.Obsolete = ''F'' AND ds.source = '||'''' || l_meas_src ||'''';
		if p_lov_type = G_PERF_MEAS_S_LOV then
			if p_parameter1 is not null then
				l_where_clause := bis_utilities_pvt.perf_measure_where_clause(p_parameter1);
			end if;
			if l_where_clause is null then
				l_lov_sql := l_lov_sql || ' AND upper(measure_name) like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
			else
				l_lov_sql := l_lov_sql || ' AND ' || l_where_clause || ' and upper(measure_name) like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
			end if;
		else
			l_lov_sql := l_lov_sql || ' AND upper(measure_name) like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
		end if;
		l_lov_sql := l_lov_sql || ' order by measure_name ';

	end if;

	if (p_lov_type = G_TARGET_LEVEL_S_LOV) or (p_lov_type = G_TARGET_LEVEL_R_LOV)then
		l_temp := ' nvl(dimension1_level_name, '''') ||
					decode(nvl(dimension2_level_name, ''''), '''', '''', '';''||dimension2_level_name) ||
					decode(nvl(dimension3_level_name, ''''), '''', '''', '';''||dimension3_level_name) ||
					decode(nvl(dimension4_level_name, ''''), '''', '''', '';''||dimension4_level_name) ||
					decode(nvl(dimension5_level_name, ''''), '''', '''', '';''||dimension5_level_name) ||
					decode(nvl(dimension6_level_name, ''''), '''', '''', '';''||dimension6_level_name) ||
					decode(nvl(dimension7_level_name, ''''), '''', '''', '';''||dimension7_level_name) ';



		l_temp1 := ' nvl(upper(dimension1_level_name), '''') ||
					decode(nvl(upper(dimension2_level_name), ''''), '''', '''', '';''||upper(dimension2_level_name)) ||
					decode(nvl(upper(dimension3_level_name), ''''), '''', '''', '';''||upper(dimension3_level_name)) ||
					decode(nvl(upper(dimension4_level_name), ''''), '''', '''', '';''||upper(dimension4_level_name)) ||
					decode(nvl(upper(dimension5_level_name), ''''), '''', '''', '';''||upper(dimension5_level_name)) ||
					decode(nvl(upper(dimension6_level_name), ''''), '''', '''', '';''||upper(dimension6_level_name)) ||
					decode(nvl(upper(dimension7_level_name), ''''), '''', '''', '';''||upper(dimension7_level_name)) ';

		/*l_temp1 := ' nvl(upper(dimension1_level_name), '''') ||
					nvl(upper(dimension2_level_name), '''') ||
					nvl(upper(dimension3_level_name), '''') ||
					nvl(upper(dimension4_level_name), '''') ||
					nvl(upper(dimension5_level_name), '''') ||
					nvl(upper(dimension6_level_name), '''') ||
					nvl(upper(dimension7_level_name), '''') ';*/

		l_lov_sql := 'select target_level_id || ''+'' || dimension1_level_id || ''+'' || dimension2_level_id || ''+'' || dimension3_level_id
		              || ''+'' || dimension4_level_id || ''+'' || dimension5_level_id || ''+'' || dimension6_level_id || ''+'' || dimension7_level_id, '
			      || l_temp || '
			     from bisfv_target_levels ';

	     	l_lov_sql := l_lov_sql || ' where ';

	     	if p_parameter2 is not null then
	          l_lov_sql := l_lov_sql || ' measure_id='||p_parameter2 || ' and ';
		end if;

		/* p_lov_type = G_TARGET_LEVEL_S_LOV is no more used after bug #3448500 */
	     	if p_lov_type = G_TARGET_LEVEL_S_LOV then
			if p_parameter1 is not null then
				l_where_clause := bis_utilities_pvt.target_level_where_clause(p_parameter1);
			end if;

			if l_where_clause is null then
				l_lov_sql := l_lov_sql  || l_temp1 || ' like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
			else
				l_lov_sql := l_lov_sql  || l_where_clause || ' and ' || l_temp1 || ' like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
			end if;
		else
			l_lov_sql := l_lov_sql || l_temp1 || ' like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
		end if;
		--if p_parameter2 is not null then
	        --  l_lov_sql := l_lov_sql || ' and measure_id='||p_parameter2;
		--end if;
		l_lov_sql := l_lov_sql || ' order by dimension1_level_name, dimension2_level_name, dimension3_level_name, dimension4_level_name,
							dimension5_level_name, dimension6_level_name, dimension7_level_name ';
	end if;


        IF (p_lov_type = G_OWNERS_LOV) THEN
           l_lov_sql := 'SELECT name, display_name FROM WF_ROLE_LOV_VL ';
           l_lov_sql := l_lov_sql || ' WHERE upper(display_name) like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
           l_lov_sql := l_lov_sql || ' ORDER BY display_name ';
        END IF;

	if (p_lov_type = G_RESPS_LOV) then
		l_lov_sql := 	' select responsibility_id, responsibility_name ' ||
				' from fnd_responsibility_vl where upper(responsibility_name) like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
                l_lov_sql := l_lov_sql || ' ORDER BY responsibility_name ';
	end if;

	-- for Time LOV
    if (p_lov_type = 'TIME') then

        if p_parameter1 is not null then

          BIS_PMF_GET_DIMLEVELS_PVT.GET_DIMLEVEL_SELECT_STRING
          (p_DimLevelName => p_parameter1
          ,x_Select_String => l_lov_sql
          ,x_table_name => l_table_name
          ,x_id_name => l_id_name
          ,x_value_name => l_value_name
          ,x_time_level => l_time_level
          ,x_return_status => l_return_status
          ,x_msg_count => l_msg_count
          ,x_msg_data => l_msg_data);


        end if;

        if p_parameter1 is not null and p_parameter2 is not null and p_parameter3 is not null and l_lov_sql is not null then
/* 2359096
			bis_utilities_pub.retrieve_Time_where_clause
            (p_time_dim_level_short_name =>p_parameter1
            ,p_org_dim_level_short_name=>p_parameter2
            ,p_org_id=>p_parameter3
            ,x_where_clause=>l_where_clause);
2359096 */
--2359096

   OPEN c_source( cp_dim_level_short_name => p_parameter1);
   FETCH c_source INTO l_source;
   CLOSE c_source;

   bis_utilities_pub.get_Time_where_clause(
                         p_dim_level_short_name       => p_parameter1
                        ,p_parent_level_short_name    => p_parameter2
                        ,p_parent_level_id            => p_parameter3
                        ,p_source                     => l_source
                        ,x_where_clause               => l_where_clause
                        ,x_return_status              => l_return_status
                        ,x_err_count                  => l_msg_count
                        ,x_errorMessage               => l_msg_data
                        );
--2359096

            if (l_where_clause is null) or (l_where_clause='""') then
              l_lov_sql := l_lov_sql || ' where  upper(' || l_value_name || ') like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
            else
              l_lov_sql := l_lov_sql || ' where '|| l_where_clause || ' and upper(' || l_value_name || ') like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
            end if;

       -- end if;
        else
           if l_lov_sql is not null then
              l_lov_sql := l_lov_sql || ' where  upper(' || l_value_name || ') like ' || 'replace('|| ':1' || ',' || '''''''''' || ',' || '''''''''''''' || ') ';
           end if;
        end if;
    end if;


	return l_lov_sql;

END getLOVSQL;

END BIS_JAVASCRIPTLOV_PVT;

/
