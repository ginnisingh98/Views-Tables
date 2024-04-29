--------------------------------------------------------
--  DDL for Package Body BIV_DBI_BAK_AGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_BAK_AGE_PKG" 
/* $Header: bivsrvrbagb.pls 120.0 2005/05/25 10:51:27 appldev noship $ */
as

  g_backlog_age_rep_func     varchar2(50) := 'BIV_DBI_BAK_AGE_TBL_REP';
  g_backlog_age_dbn_rep_func varchar2(50) := 'BIV_DBI_BAK_AGE_DBN_TBL_REP';

  g_backlog_detail_rep_func  varchar2(50) := 'BIV_DBI_BAK_DTL_REP';

  -- for balance
  g_c_aging_as_of_date_balance  constant varchar2(60) := '&AGE_CURRENT_ASOF_DATE';
  g_p_aging_as_of_date_balance  constant varchar2(60) := '&AGE_PREVIOUS_ASOF_DATE';
  g_inlist_bal            constant number        := 16; -- Bit 4
/*
-- Last refresh date checks
procedure set_last_collection
is
begin
   poa_dbi_template_pkg.g_c_as_of_date :=  'least(&BIS_CURRENT_ASOF_DATE,&LAST_COLLECTION)';
   poa_dbi_template_pkg.g_p_as_of_date :=  'least(&BIS_PREVIOUS_ASOF_DATE,&LAST_COLLECTION)';
end set_last_collection;

-- Last refresh date checks
procedure unset_last_collection
is
begin
   poa_dbi_template_pkg.g_c_as_of_date :=  '&BIS_CURRENT_ASOF_DATE';
   poa_dbi_template_pkg.g_p_as_of_date :=  '&BIS_PREVIOUS_ASOF_DATE';
end unset_last_collection;
*/


FUNCTION status_sql (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_filter_where              IN       VARCHAR2 := NULL
  , p_generate_viewby           IN       VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_in_join_tbl := NULL)
    RETURN VARCHAR2
  IS
    l_query                  VARCHAR2 (10000);
    l_col_names              VARCHAR2 (10000);
    l_group_and_sel_clause   VARCHAR2 (10000);
    l_from_clause            VARCHAR2 (10000);
    l_where_clause           VARCHAR2 (10000);
    l_c_calc_end_date        VARCHAR2 (70);
    l_p_calc_end_date        VARCHAR2 (70);
    l_inlist                 VARCHAR2 (300);
    l_inlist_bmap            NUMBER           := 0;
    l_viewby_rank_where      VARCHAR2 (1000);
    l_in_join_tables         VARCHAR2 (240) := '';
    l_filter_where           VARCHAR2 (1000);

  BEGIN
    l_group_and_sel_clause    := ' fact.' || p_join_tables (1).fact_column;

    FOR i IN 2 .. p_join_tables.COUNT
    LOOP
      l_group_and_sel_clause    := l_group_and_sel_clause || ', fact.' || p_join_tables (i).fact_column;
    END LOOP;

    IF(p_in_join_tables is not null) then

      FOR i in 1 .. p_in_join_tables.COUNT
      LOOP
        l_in_join_tables := l_in_join_tables || ', ' ||  p_in_join_tables(i).table_name || ' ' || p_in_join_tables(i).table_alias;
      END LOOP;

    END IF;

	-- Bind the end date variables to the BIV aging balance '&XXX' values
	l_c_calc_end_date    := g_c_aging_as_of_date_balance;
	l_p_calc_end_date    := g_p_aging_as_of_date_balance;
	l_inlist_bmap    := poa_dbi_util_pkg.bitor (l_inlist_bmap
	                                          , g_inlist_bal);

    FOR i IN 1 .. p_col_name.COUNT
    LOOP

      -- Regular current column
      l_col_names    :=
            l_col_names
         || ', sum(decode(fact.report_date, '
         || l_c_calc_end_date
         || ','
         || p_col_name (i).column_name
         || ', null)) c_'
         || p_col_name (i).column_alias
         || '
';

      -- Prev column (based on prior_code)
      IF (p_col_name (i).prior_code <> poa_dbi_util_pkg.no_priors)
      THEN
        l_col_names        :=
              l_col_names
           || ', sum(decode(fact.report_date, '
           || l_p_calc_end_date
           || ','
           || p_col_name (i).column_name
           || ', null)) p_'
           || p_col_name (i).column_alias
           || '
';
      END IF;

      -- If grand total is flagged, do current and prior grand totals
      IF (p_col_name (i).grand_total = 'Y')
      THEN
        -- Sum of current column
        l_col_names    :=
              l_col_names
           || ', sum(sum(decode(fact.report_date, '
           || l_c_calc_end_date
           || ', '
           || p_col_name (i).column_name
           || ', null))) over () c_'
           || p_col_name (i).column_alias
           || '_total
';

        -- Sum of prev column
        l_col_names    :=
                l_col_names
             || ', sum(sum(decode(fact.report_date, '
             || l_p_calc_end_date
             || ', '
             || p_col_name (i).column_name
             || ', null))) over () p_'
             || p_col_name (i).column_alias
             || '_total
';

      END IF;
    END LOOP;

    l_inlist :=
          '('
       || g_c_aging_as_of_date_balance
       || ',' || g_p_aging_as_of_date_balance
       || ')';


    IF p_filter_where is not null
    THEN
	   l_filter_where := ' where ' || p_filter_where;
    END IF;

    l_query                   :=
          '(select '
       || l_group_and_sel_clause
       || l_col_names
       || '
	   from '
       || p_fact_name
       || ' fact
		  where fact.report_date in  '
       || l_inlist
       || p_where_clause
       || '
	   group by '
       || l_group_and_sel_clause
       || ' ) ) ' || l_filter_where || ' ) oset ';

	IF(p_generate_viewby = 'Y')
	THEN
	 l_viewby_rank_where := ','||
	    poa_dbi_template_pkg.get_viewby_rank_clause (
	       p_join_tables       => p_join_tables
	     , p_use_windowing     => p_use_windowing);
	END IF;

    l_query := l_query || l_viewby_rank_where;

    RETURN l_query;

END status_sql;



FUNCTION get_calendar_table (p_xtd IN VARCHAR2)  return varchar2
IS
l_report_start_date date;
l_as_of_date        date;
BEGIN

   IF(p_xtd like 'RL%') THEN

    return '( select start_date, end_date, end_date report_date, to_char(end_date,''dd-Mon-yy'') name, ordinal from '
          || '( select distinct '
              || 'decode(t.current_ind, 2, &BIV_PREV_EFFEC_END_DATE'
                                  || ', 4, (&BIV_CURR_EFFEC_START_DATE - 1)'
                                  || ', &BIV_CURR_EFFEC_END_DATE)+(t.offset*&RLX_DAYS) '
                                  || '- &RLX_DAYS_TO_START start_date'
            || ', decode(t.current_ind, 2, &BIV_PREV_EFFEC_END_DATE'
                                  || ', 4, (&BIV_CURR_EFFEC_START_DATE - 1)'
                                  || ', &BIV_CURR_EFFEC_END_DATE)+(t.offset*&RLX_DAYS) end_date'
            || ', decode(&BIS_TIME_COMPARISON_TYPE,''SEQUENTIAL'',-1,decode(t.current_ind,4,0,2,1,2)) ordinal '
            || 'from biv_trend_rpt t '
            || 'where t.offset > &RLX_ROWS_OFFSET '
            || 'and current_ind = 1'
         || ' )'
       || ' )';
  ELSE

	l_as_of_date:=get_last_refresh_date('BIV_B_AGE_H_SUM_MV');
	l_report_start_date:= current_report_start_date(l_as_of_date,p_xtd);

    return   '( select start_date, end_date, end_date report_date,  name
                from ' || poa_dbi_util_pkg.get_calendar_table(p_xtd) || '
                where  start_date between to_date('''||l_report_start_date ||''', ''dd-mon-yyyy'') and &BIV_LAST_REFRESH_DATE )';

  END IF;
END get_calendar_table;



procedure get_age_binds
( p_period_type      in varchar2
, p_comparison_type  in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
)
is

  l_lag				number;
  l_curr_pattern	number;
  l_prev_pattern    number;
  l_current_date	date;
  l_prior_date		date;
  l_current_start_date  date;
  last_refresh_date     date;
  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  select max(trunc(report_date))
  into l_current_date
  from biv_dbi_backlog_age_dates;

  if(p_comparison_type = 'S') then
		l_lag:= 1;
		case p_period_type
			when 'RLY' then
			 begin
				l_curr_pattern:= 16;
				l_prev_pattern:= 256;
                l_current_start_date:=FII_TIME_API.ryr_start(l_current_date);
				l_prior_date := l_current_date - 365;
			 end;

                        when 'YTD' then
                         begin
                                l_curr_pattern:= 131072;
                                l_prev_pattern:= 4194304;
                l_current_start_date:=FII_TIME_API.ryr_start(l_current_date);
                                l_prior_date := l_current_date - 365;
                         end;


			when 'RLQ' then
			 begin
				l_curr_pattern:= 8;
				l_prev_pattern:= 128;
                l_current_start_date:=FII_TIME_API.rqtr_start(l_current_date);
				l_prior_date := l_current_date - 90;
			 end;

                        when 'QTD' then
                         begin
                                l_curr_pattern:= 65536;
                                l_prev_pattern:= 2097152;
                l_current_start_date:=FII_TIME_API.rqtr_start(l_current_date);
                                l_prior_date := l_current_date - 90;
                         end;

			when 'RLM' then
			 begin
				l_curr_pattern:= 4;
				l_prev_pattern:= 64;
                l_current_start_date:=FII_TIME_API.rmth_start(l_current_date);
				l_prior_date := l_current_date - 30;
			 end;

                        when 'MTD' then
                         begin
                                l_curr_pattern:= 32768;
                                l_prev_pattern:= 1048576;
                l_current_start_date:=FII_TIME_API.rmth_start(l_current_date);
                                l_prior_date := l_current_date - 30;
                         end;

			when 'RLW' then
			 begin
				l_curr_pattern:= 2;
				l_prev_pattern:= 32;
                l_current_start_date:=FII_TIME_API.rwk_start(l_current_date);
				l_prior_date := l_current_date - 7;
			 end;

                        when 'WTD' then
                         begin
                                l_curr_pattern:= 16384;
                                l_prev_pattern:= 524288;
                l_current_start_date:=FII_TIME_API.rwk_start(l_current_date);
                                l_prior_date := l_current_date - 7;
                         end;

                        when 'DAY' then
                         begin
                                l_curr_pattern:= 8192;
                                l_prev_pattern:= 262144;
                l_current_start_date:=l_current_date;
                                l_prior_date := l_current_date - 1;
                         end;

		end case;
  else
  	  l_prior_date := add_months(l_current_date,-12);
      case p_period_type
           when 'RLY' then
		    begin
		         l_lag:= 1;
				 l_curr_pattern:= 16;
				 l_prev_pattern:= 4096;
                 l_current_start_date:=FII_TIME_API.ryr_start(l_current_date);
			end;

           when 'YTD' then
                    begin
                         l_lag:= 1;
                                 l_curr_pattern:= 131072;
                                 l_prev_pattern:= 134217728;
                 l_current_start_date:=FII_TIME_API.ryr_start(l_current_date);
                        end;


           when 'RLQ' then
   		    begin
				 l_lag:= 8;
				 l_curr_pattern:= 8;
				 l_prev_pattern:= 2048;
                 l_current_start_date:=FII_TIME_API.rqtr_start(l_current_date);
			end;

           when 'QTD' then
                    begin
                                 l_lag:= 8;
                                 l_curr_pattern:= 65536;
                                 l_prev_pattern:= 67108864;
                 l_current_start_date:=FII_TIME_API.rqtr_start(l_current_date);
                        end;

           when 'RLM' then
			begin
				 l_lag:= 12;
				 l_curr_pattern:= 4;
				 l_prev_pattern:= 1024;
                 l_current_start_date:=FII_TIME_API.rmth_start(l_current_date);
			end;

           when 'MTD' then
                        begin
                                 l_lag:= 12;
                                 l_curr_pattern:= 32768;
                                 l_prev_pattern:= 33554432;
                 l_current_start_date:=FII_TIME_API.rmth_start(l_current_date);
                        end;

           when 'RLW' then
			begin
				 l_lag:= 13;
				 l_curr_pattern:= 2;
				 l_prev_pattern:= 512;
                 l_current_start_date:=FII_TIME_API.rwk_start(l_current_date);
            end;

           when 'WTD' then
                        begin
                                 l_lag:= 13;
                                 l_curr_pattern:= 16384;
                                 l_prev_pattern:= 16777216;
                 l_current_start_date:=FII_TIME_API.rwk_start(l_current_date);
            end;

           when 'DAY' then
                        begin
                                 l_lag:= 7;
                                 l_curr_pattern:= 8192;
                                 l_prev_pattern:= 8388608;
                 l_current_start_date:=l_current_date;
            end;

      end case;
  end if;

  last_refresh_date := get_last_refresh_date('BIV_B_AGE_H_SUM_MV');

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

  l_custom_rec.attribute_name := '&BIV_AGE_LAG';
  l_custom_rec.attribute_value := l_lag;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := '&BIV_CURR_PATTERN';
  l_custom_rec.attribute_value := l_curr_pattern;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := '&BIV_PREV_PATTERN';
  l_custom_rec.attribute_value := l_prev_pattern;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := '&BIV_CURR_EFFEC_START_DATE';
  l_custom_rec.attribute_value := to_char(fnd_date.displayDT_to_date(l_current_start_date),'dd/mm/yyyy');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := '&BIV_CURR_EFFEC_END_DATE';
  l_custom_rec.attribute_value := to_char(fnd_date.displayDT_to_date(l_current_date),'dd/mm/yyyy');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := '&BIV_PREV_EFFEC_END_DATE';
  l_custom_rec.attribute_value := to_char(fnd_date.displayDT_to_date(l_prior_date),'dd/mm/yyyy');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

l_custom_rec.attribute_name := '&BIV_LAST_REFRESH_DATE';
  l_custom_rec.attribute_value := to_char(fnd_date.displayDT_to_date(last_refresh_date),'dd/mm/yyyy');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;


end get_age_binds;



FUNCTION trend_sql (
    p_xtd                       IN       VARCHAR2
  , p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl)
    RETURN VARCHAR2
IS
    l_query               VARCHAR2 (10000);
    l_col_names           VARCHAR2 (4000);
BEGIN


    FOR i IN 1 .. p_col_name.COUNT
    LOOP

      -- Regular current column
      l_col_names    :=
            l_col_names
         || ', sum(decode(Cur, ''Y'', '
         || p_col_name (i).column_name
         || ', null)) c_'
         || p_col_name (i).column_alias
         || '
';

      -- Prev column (based on prior_code)
      IF (p_col_name (i).prior_code <> poa_dbi_util_pkg.no_priors)
      THEN
        l_col_names        :=
              l_col_names
           || ', lag(sum(decode(Pri, ''Y'', '
           || p_col_name (i).column_name
           || ', null)), &BIV_AGE_LAG) over (order by cur, fact.REPORT_DATE) p_'
           || p_col_name (i).column_alias
           || '
';
      END IF;

    END LOOP;

-- changes included for bug 4133825
if (p_xtd in ('YTD','QTD','MTD','WTD'))
   then
    l_query                   :=
          '(select
          CASE when fact.report_date = &BIV_CURR_EFFEC_START_DATE then &BIV_CURR_EFFEC_END_DATE else fact.REPORT_DATE END report_date
          ' ||'
       , cur, pri '
       || l_col_names
       || '
	   from '
       || p_fact_name
       || ' fact ,
	   '
	   || '( '
	   || ' select trunc(report_date) report_date'
	   || ' , decode(bitand(record_type_id, &BIV_CURR_PATTERN), &BIV_CURR_PATTERN,''Y'',''N'') Cur '
	   || ' , decode(bitand(record_type_id, &BIV_PREV_PATTERN), &BIV_PREV_PATTERN,''Y'',''N'') Pri '
	   || ' from biv_dbi_backlog_age_dates '
	   || ' where '
	   || '    bitand(record_type_id, &BIV_CURR_PATTERN)= &BIV_CURR_PATTERN /* current */ '
	   || ' or bitand(record_type_id, &BIV_PREV_PATTERN)= &BIV_PREV_PATTERN /* prior */ '
	   || ' ) join_dates '
	   || '
	   where'
	   || ' fact.report_date = join_dates.report_date
	   '
       || p_where_clause
       || '
	   group by '
       || 'fact.REPORT_DATE, cur, pri '
       || ') iset '
	   || ',
	   '
	    || get_calendar_table(p_xtd) || 'cal
       '
	   ||'where iset.report_date BETWEEN cal.START_DATE AND cal.end_Date'
	   ||' GROUP BY cal.report_date )iset,'

	   || get_calendar_table(p_xtd)
       || ' cal
	   '
       || ' where cal.end_date = iset.report_date(+) '
       || ' order by cal.end_date';
else
 -- changes included for bug 4133825

    l_query                   :=
          '(select '
       || 'fact.REPORT_DATE , cur, pri '
       || l_col_names
       || '
	   from '
       || p_fact_name
       || ' fact ,
	   '
	   || '( '
	   || ' select trunc(report_date) report_date'
	   || ' , decode(bitand(record_type_id, &BIV_CURR_PATTERN), &BIV_CURR_PATTERN,''Y'',''N'') Cur '
	   || ' , decode(bitand(record_type_id, &BIV_PREV_PATTERN), &BIV_PREV_PATTERN,''Y'',''N'') Pri '
	   || ' from biv_dbi_backlog_age_dates '
	   || ' where '
	   || '    bitand(record_type_id, &BIV_CURR_PATTERN)= &BIV_CURR_PATTERN /* current */ '
	   || ' or bitand(record_type_id, &BIV_PREV_PATTERN)= &BIV_PREV_PATTERN /* prior */ '
	   || ' ) join_dates '
	   || '
	   where'
	   || ' fact.report_date = join_dates.report_date
	   '
       || p_where_clause
       || '
	   group by '
       || 'fact.REPORT_DATE, cur, pri '
	   || ') iset '
	   || ',
	   '
       || get_calendar_table(p_xtd)
       || ' cal
	   '
       || ' where cal.end_date = iset.report_date(+) '
       || ' order by cal.end_date';

end if;
    RETURN l_query;


END trend_sql;



procedure get_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
, p_distribution    in varchar2 := 'N'
)
is

  l_view_by          varchar2(200);
  l_view_by_col_name varchar2(200);
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_where_clause     varchar2(10000);
  l_mv               varchar2(10000);
  l_stmt             varchar2(32767);
  l_backlog_type     varchar2(100);

  l_bucket_rec       bis_bucket_pub.bis_bucket_rec_type;

  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_custom_output    bis_query_attributes_tbl;

  l_to_date_type      VARCHAR2 (3)  ;
  l_as_of_date        date;

begin

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'BACKLOG_AGE'
  , p_trend            => 'N'
  , x_view_by          => l_view_by
  , x_view_by_col_name => l_view_by_col_name
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );

  l_backlog_type := biv_dbi_tmpl_util.get_backlog_type(p_param);

  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'YTD';
--     set_last_collection;
  ELSE
     l_to_date_type := 'BAL';
  END IF;


  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => case l_backlog_type
                                                 when 'ESCALATED' then 'escalated_count'
                                                 when 'UNOWNED' then 'unowned_count'
                                                 else 'backlog_count'
                                               end
                             , p_alias_name => 'backlog'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => case l_backlog_type
                                                 when 'ESCALATED' then 'total_escalated_age'
                                                 when 'UNOWNED' then 'total_unowned_age'
                                                 else 'total_backlog_age'
                                               end
                             , p_alias_name => 'backlog_age'
                             , p_to_date_type => l_to_date_type
                             );

  biv_dbi_tmpl_util.add_bucket_inner_query
  ( p_short_name   => 'BIV_DBI_BACKLOG_AGING'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => case l_backlog_type
                        when 'ESCALATED' then 'escalated_age'
                        when 'UNOWNED' then 'unowned_age'
                        else 'backlog_age'
                      end
  , p_alias_name   => 'age_bucket'
  , p_grand_total  => 'Y'
  , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
  , p_to_date_type => 'BAL'
  , x_bucket_rec   => l_bucket_rec
  );

  l_stmt := 'select
  ' ||
    biv_dbi_tmpl_util.get_view_by_col_name(l_view_by) || ' VIEWBY ' ||
    ', oset.' || l_view_by_col_name || ' VIEWBYID ' ||
    case
      when l_view_by = biv_dbi_tmpl_util.g_PRODUCT then
        ', v.description'
      else
        ', null'
    end
    || ' BIV_ATTRIBUTE5
/* Backlog Prior */
, nvl(oset.p_backlog,0) BIV_MEASURE1
/* Backlog Current */
, nvl(oset.c_backlog,0) BIV_MEASURE2
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog'
                               ,'oset.p_backlog'
                               ,'BIV_MEASURE4') ||
'
/* Average Age Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.p_backlog_age'
                             ,'oset.p_backlog'
                             ,'BIV_MEASURE5'
                             ,'N') ||
'
/* Average Age Current */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.c_backlog_age'
                             ,'oset.c_backlog'
                             ,'BIV_MEASURE6'
                             ,'N') ||
'
/* Average Age Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('oset.c_backlog_age'
                                                             ,'oset.c_backlog'
                                                             ,null
                                                             ,'N')
                               ,biv_dbi_tmpl_util.rate_column('oset.p_backlog_age'
                                                              ,'oset.p_backlog'
                                                              ,null
                                                              ,'N')
                               ,'BIV_MEASURE8'
                               ,'N') ||
'
/* Aging Buckets */
' || biv_dbi_tmpl_util.get_bucket_outer_query
     ( p_bucket_rec       => l_bucket_rec
     , p_column_name_base => 'oset.c_age_bucket'
     , p_alias_base       => 'BIV_MEASURE10'
     , p_total_flag       => 'N'
     , p_backlog_col      => case
                               when p_distribution = 'Y' then 'oset.c_backlog'
                               else null
                             end
     ) ||
'
/* GT Backlog Current */
, nvl(oset.c_backlog_total,0) BIV_MEASURE11
/* GT Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog_total'
                               ,'oset.p_backlog_total'
                               ,'BIV_MEASURE12') ||
'
/* GT Average Age Current */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.c_backlog_age_total'
                             ,'oset.c_backlog_total'
                             ,'BIV_MEASURE13'
                             ,'N') ||
'
/* GT Average Age Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('oset.c_backlog_age_total'
                                                             ,'oset.c_backlog_total'
                                                             ,null
                                                             ,'N')
                               ,biv_dbi_tmpl_util.rate_column('oset.p_backlog_age_total'
                                                             ,'oset.p_backlog_total'
                                                             ,null
                                                             ,'N')
                               ,'BIV_MEASURE14'
                               ,'N') ||
'
/* GT Aging Buckets */
' || biv_dbi_tmpl_util.get_bucket_outer_query
     ( p_bucket_rec       => l_bucket_rec
     , p_column_name_base => 'oset.c_age_bucket'
     , p_alias_base       => 'BIV_MEASURE15'
     , p_total_flag       => 'Y'
     , p_backlog_col      => case
                               when p_distribution = 'Y' then 'oset.c_backlog'
                               else null
                             end
     ) ||
'
, ' ||
biv_dbi_tmpl_util.get_category_drill_down(l_view_by, case
                                                       when p_distribution = 'N' then
                                                         g_backlog_age_rep_func
                                                       else
                                                         g_backlog_age_dbn_rep_func
                                                     end) ||
  biv_dbi_tmpl_util.drill_detail( g_backlog_detail_rep_func
                                , 0
                                , null
                                , 'BIV_ATTRIBUTE6') ||
  case
    when p_distribution = 'N' then
      biv_dbi_tmpl_util.bucket_detail_drill( g_backlog_detail_rep_func
                                           , l_bucket_rec
                                           , 'BIV_ATTRIBUTE7' )
    else
      null
    end ||
'
from
( select * from ( ' || status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'N'
        , p_col_name             => l_col_tbl
        , p_filter_where         => '(c_backlog > 0 or p_backlog > 0)'
        , p_generate_viewby      => 'Y'
        );
--  unset_last_collection;

  biv_dbi_tmpl_util.override_order_by(l_view_by, p_param, l_stmt);

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  biv_dbi_tmpl_util.bind_age_dates
	( p_param => p_param
	, p_current_name => '&AGE_CURRENT_ASOF_DATE' -- these will be the text you actually use in your sql	stmt.
	, p_prior_name => '&AGE_PREVIOUS_ASOF_DATE'   --
	, p_custom_output => l_custom_output );


  x_custom_output := l_custom_output;

end get_tbl_sql;


procedure get_dbn_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is
begin
  get_tbl_sql
  ( p_param         => p_param
  , x_custom_sql    => x_custom_sql
  , x_custom_output => x_custom_output
  , p_distribution  => 'Y'
  );
end get_dbn_tbl_sql;



procedure get_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
, p_distribution    in varchar2 := 'N'
)
is

  l_view_by          varchar2(200);
  l_view_by_col_name varchar2(200);
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_where_clause     varchar2(10000);
  l_mv               varchar2(10000);
  l_stmt             varchar2(32767);
  l_backlog_type     varchar2(100);
  l_bucket_rec       bis_bucket_pub.bis_bucket_rec_type;
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_custom_output    bis_query_attributes_tbl;

  l_to_date_type      VARCHAR2 (3)  ;
  l_as_of_date        date;

  l_temp_xtd              varchar2(200);  -- RAVI Temp Sol
begin

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'BACKLOG_AGE'
  , p_trend            => 'Y'
  , x_view_by          => l_view_by
  , x_view_by_col_name => l_view_by_col_name
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
 );

  l_backlog_type := biv_dbi_tmpl_util.get_backlog_type(p_param);

  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'YTD';
--     set_last_collection;
  ELSE
     l_to_date_type := 'BAL';
  END IF;

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => case l_backlog_type
                                                 when 'ESCALATED' then 'escalated_count'
                                                 when 'UNOWNED' then 'unowned_count'
                                                 else 'backlog_count'
                                               end
                             , p_alias_name => 'backlog'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total  => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => case l_backlog_type
                                                 when 'ESCALATED' then 'total_escalated_age'
                                                 when 'UNOWNED' then 'total_unowned_age'
                                                 else 'total_backlog_age'
                                               end
                             , p_alias_name => 'backlog_age'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total  => 'N'
                             );

  biv_dbi_tmpl_util.add_bucket_inner_query
  ( p_short_name   => 'BIV_DBI_BACKLOG_AGING'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => case l_backlog_type
                        when 'ESCALATED' then 'escalated_age'
                        when 'UNOWNED' then 'unowned_age'
                        else 'backlog_age'
                      end
  , p_alias_name   => 'age_bucket'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
  , p_to_date_type => 'BAL'
  , x_bucket_rec   => l_bucket_rec
  );

  l_stmt := 'select
  cal.name VIEWBY
/* Backlog Prior */
, nvl(iset.p_backlog,0) BIV_MEASURE1
/* Backlog Current */
, nvl(iset.c_backlog,0) BIV_MEASURE2
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('iset.c_backlog'
                               ,'iset.p_backlog'
                               ,'BIV_MEASURE4') ||
'
/* Average Age Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('iset.p_backlog_age'
                             ,'iset.p_backlog'
                             ,'BIV_MEASURE5'
                             ,'N') ||
'
/* Average Age Current */
, ' ||
biv_dbi_tmpl_util.rate_column('iset.c_backlog_age'
                             ,'iset.c_backlog'
                             ,'BIV_MEASURE6'
                             ,'N') ||
'
/* Average Age Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('iset.c_backlog_age'
                                                             ,'iset.c_backlog'
                                                             ,null
                                                             ,'N')
                               ,biv_dbi_tmpl_util.rate_column('iset.p_backlog_age'
                                                             ,'iset.p_backlog'
                                                             ,null
                                                             ,'N')
                               ,'BIV_MEASURE8'
                               ,'N') ||
'
/* Aging Buckets */
' || biv_dbi_tmpl_util.get_bucket_outer_query
     ( p_bucket_rec       => l_bucket_rec
     , p_column_name_base => 'iset.c_age_bucket'
     , p_alias_base       => 'BIV_MEASURE10'
     , p_total_flag       => 'N'
     , p_backlog_col      => case
                               when p_distribution = 'Y' then 'iset.c_backlog'
                               else null
                             end
     )

  || ', NULL BIV_DYNAMIC_URL1, NULL BIV_DYNAMIC_URL2';


--changes included for bug 4133825
IF(l_xtd IN ('WTD','MTD','QTD','YTD')) then
l_stmt:= l_stmt || '
FROM (
	SELECT cal.report_date,
		sum(c_backlog) c_backlog,
		sum(p_backlog) p_backlog,
		sum(c_backlog_age) c_backlog_age,
		sum(p_backlog_age) p_backlog_age,
		sum(c_age_bucket_b1) c_age_bucket_b1,
		sum(c_age_bucket_b2) c_age_bucket_b2,
		sum(c_age_bucket_b3) c_age_bucket_b3,
		sum(c_age_bucket_b4) c_age_bucket_b4,
		sum(c_age_bucket_b5) c_age_bucket_b5
		';
end if;
--changes included for bug 4133825

l_stmt := l_stmt || '
from
  ' || trend_sql
        ( p_xtd => l_xtd
		, p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_col_name             => l_col_tbl
        );
--  unset_last_collection;

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.get_trace_file_name;

  x_custom_sql      := l_stmt;

 -- RAVI Temp SOlution
   case l_xtd
       when  'YTD' THEN l_temp_xtd := 'RLY';
       when  'QTD' THEN l_temp_xtd := 'RLQ';
       when  'MTD' THEN l_temp_xtd := 'RLM';
       when  'WTD' THEN l_temp_xtd := 'RLW';
       when  'DAY' THEN l_temp_xtd := 'DAY';
       else l_temp_xtd := l_xtd;
   end case;


  poa_dbi_util_pkg.get_custom_trend_binds
  ( x_custom_output     => l_custom_output
  , p_xtd               => l_xtd
  , p_comparison_type   => l_comparison_type
  );

  -- Gets Lag, Curr and Prev patterns and dates for current rolling calendar
  get_age_binds
  (   p_period_type => l_temp_xtd
    , p_comparison_type   => l_comparison_type
	, p_custom_output => l_custom_output
  );

  x_custom_output := l_custom_output;

end get_trd_sql;



procedure get_dbn_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is
begin
  get_trd_sql
  ( p_param         => p_param
  , x_custom_sql    => x_custom_sql
  , x_custom_output => x_custom_output
  , p_distribution  => 'Y'
  );
end get_dbn_trd_sql;



procedure get_detail_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)as

  l_where_clause varchar2(10000);
  l_xtd              varchar2(200);
  l_mv           varchar2(10000);
  l_join_from    varchar2(10000);
  l_join_where   varchar2(10000);
  l_order_by     varchar2(100);
  l_backlog_type varchar2(100);

  l_join_tbl      poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_custom_output bis_query_attributes_tbl;

  l_drill_url varchar2(500);
  l_sr_id     varchar2(100);

  l_to_date_type      VARCHAR2 (3)  ;
  l_as_of_date        date;

begin

  biv_dbi_tmpl_util.get_detail_page_function( l_drill_url, l_sr_id );

  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'BACKLOG_DETAIL'
  , x_where_clause     => l_where_clause
  , x_xtd              => l_xtd
  , x_mv               => l_mv
  , x_join_from        => l_join_from
  , x_join_where       => l_join_where
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );

  if l_where_clause like '%<replace this>%' then
    l_where_clause := replace(l_where_clause,'fact.<replace this> in (&'||biv_dbi_tmpl_util.g_AGING||')'
                                            ,'(&RANGE_LOW is null or fact.age >= &RANGE_LOW) and (&RANGE_HIGH is null or fact.age < &RANGE_HIGH)');

    biv_dbi_tmpl_util.bind_low_high
    ( p_param
    , 'BIV_DBI_BACKLOG_AGING'
    , '&RANGE_LOW'
    , '&RANGE_HIGH'
    , l_custom_output );

  end if;

  l_backlog_type := biv_dbi_tmpl_util.get_backlog_type(p_param);

  if l_backlog_type = 'ESCALATED' then
    l_where_clause := l_where_clause || ' and fact.escalated_date is not null';
  elsif l_backlog_type = 'UNOWNED' then
    l_where_clause := l_where_clause || ' and fact.unowned_date is not null';
  end if;

  l_order_by := biv_dbi_tmpl_util.get_order_by(p_param);
  if l_order_by like '% DESC%' then
    if l_order_by like '%BIV_MEASURE12%' then
      l_order_by := 'fact.incident_date desc, fact.incident_id desc';
    else
      l_order_by := 'fact.age desc, fact.incident_id desc';
    end if;
  else
    if l_order_by like '%BIV_MEASURE12%' then
      l_order_by := 'fact.incident_date asc, fact.incident_id asc';
    else
      l_order_by := 'fact.age asc, fact.incident_id asc';
    end if;
  end if;

  x_custom_sql := '
select
  i.incident_number biv_measure1
, rt.value biv_measure2 -- request_type
, pr.value biv_measure3 -- product
, pr.description biv_measure4
, cu.value biv_measure5 -- customer
, sv.value biv_measure6 -- severity
, ag.value biv_measure7 -- assignment_group
, st.value biv_measure8 -- status
, decode(fact.escalated_date,null,&NO,&YES) biv_measure9
, decode(fact.unowned_date,null,&NO,&YES) biv_measure10
, fact.age biv_measure11
, fnd_date.date_to_displaydate(fact.incident_date) biv_measure12' ||
  case
    when l_drill_url is not null then
'
, ''pFunctionName=' || l_drill_url || '&' || l_sr_id || '=''||fact.incident_id biv_attribute1'
    else
'
, null biv_attribute1'
  end ||
'
from
  ( select
      fact.*
    , rank() over(order by ' || l_order_by || ') -1 rnk
    from
      ' || l_mv || ' fact
    where
        fact.backlog_date_to = to_date(''31-12-4712'',''DD-MM-YYYY'')
' || l_where_clause || '
  ) fact
' || l_join_from || '
, cs_incidents_all_b i
where
    1=1
and fact.incident_id = i.incident_id' || l_join_where || '
and (fact.rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
&ORDER_BY_CLAUSE
'
--|| biv_dbi_tmpl_util.dump_parameters(p_param)
;

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => biv_dbi_tmpl_util.get_balance_fact(null)
  , p_xtd           => l_xtd
  );

  biv_dbi_tmpl_util.bind_age_dates
  ( p_param => p_param
  , p_current_name => '&AGE_CURRENT_ASOF_DATE' -- these will be the text you actually use in your sql	stmt.
  , p_prior_name => '&AGE_PREVIOUS_ASOF_DATE'   --
  , p_custom_output => l_custom_output );


  biv_dbi_tmpl_util.bind_yes_no
  ( '&YES'
  , '&NO'
  , l_custom_output );

  x_custom_output := l_custom_output;

end get_detail_sql;

FUNCTION get_last_refresh_date
(p_object_name IN varchar2
)

RETURN varchar2
IS
last_refresh_date date;

BEGIN
    select last_update_date into last_refresh_date
	from bis_refresh_log
	where object_name = p_object_name and status='SUCCESS'
	and last_update_date =( select max(last_update_date)
                            from bis_refresh_log
                            where object_name= p_object_name and  status='SUCCESS' );

 return last_refresh_date;

END get_last_refresh_date;

FUNCTION current_report_start_date (
    as_of_date			IN	 DATE
  , period_type 		IN	 VARCHAR2)
    RETURN DATE
  IS
    l_date		DATE;
    l_curr_year 	NUMBER;
    l_curr_qtr		NUMBER;
    l_curr_period	NUMBER;
    l_week_start_date	DATE;
  BEGIN
    IF (period_type = 'YTD')
    THEN
      SELECT SEQUENCE
	INTO l_curr_year
	FROM fii_time_ent_year
       WHERE as_of_date BETWEEN start_date AND end_date;

      SELECT start_date
	INTO l_date
	FROM fii_time_ent_year
       WHERE SEQUENCE = l_curr_year - 3;
    END IF;

    IF (period_type = 'QTD')
    THEN
      SELECT SEQUENCE
	   , ent_year_id
	INTO l_curr_qtr
	   , l_curr_year
	FROM fii_time_ent_qtr
       WHERE as_of_date BETWEEN start_date AND end_date;

      IF (l_curr_qtr = 4)
      THEN
	l_date	  := fii_time_api.ent_cyr_start (as_of_date);
      ELSE
	SELECT start_date
	  INTO l_date
	  FROM fii_time_ent_qtr
	 WHERE SEQUENCE = l_curr_qtr + 1
	   AND ent_year_id = l_curr_year - 2;
      END IF;
    END IF;

    IF (period_type = 'MTD')
    THEN
      SELECT p.SEQUENCE
	   , q.ent_year_id
	INTO l_curr_period
	   , l_curr_year
	FROM fii_time_ent_period p
	   , fii_time_ent_qtr q
       WHERE p.ent_qtr_id = q.ent_qtr_id
	 AND as_of_date BETWEEN p.start_date AND p.end_date;

      SELECT start_date
	INTO l_date
	FROM (SELECT   p.start_date
		  FROM fii_time_ent_period p
		     , fii_time_ent_qtr q
		 WHERE p.ent_qtr_id = q.ent_qtr_id
		   AND (   (	p.SEQUENCE = l_curr_period + 1
			    AND q.ent_year_id = l_curr_year - 1)
			OR (	p.SEQUENCE = 1
			    AND q.ent_year_id = l_curr_year))
	      ORDER BY p.start_date)
       WHERE ROWNUM <= 1;
/* select p.start_date
   into l_date
   from fii_time_ent_period p, fii_time_ent_qtr q
   where p.ent_qtr_id=q.ent_qtr_id
   and p.sequence=l_curr_period+1  -- temp fix for 12 points on graph else 13 points  brrao modified
   and q.ent_year_id=l_curr_year-1;
*/
    END IF;

    IF (period_type = 'WTD')
    THEN
      SELECT start_date
	INTO l_week_start_date
	FROM fii_time_week
       WHERE as_of_date BETWEEN start_date AND end_date;

      SELECT start_date
	INTO l_date
	FROM fii_time_week
       WHERE start_date = l_week_start_date - 7 * 12;
    END IF;

IF (period_type = 'DAY')
    THEN

   SELECT start_date
	INTO l_date
	FROM fii_time_day
       WHERE start_date = as_of_date - 6;
END IF;

    RETURN l_date;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN bis_common_parameters.get_global_start_date;
  END current_report_start_date;


end biv_dbi_bak_age_pkg;

/
