--------------------------------------------------------
--  DDL for Package Body POA_DBI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_UTIL_PKG" AS
/* $Header: poadbiutilb.pls 120.4 2006/09/04 13:21:53 sriswami noship $ */

 g_employee_id NUMBER := -1;

/* used by get_bucket_outer_query */
function get_bucket_clause
( p_col_num in number
, p_col_name	     in varchar2
, p_alias_name       in varchar2
, p_prefix	     in varchar2
, p_suffix	     in varchar2
, p_total_flag       in varchar2
)return varchar2;

/* used by get_bucket_drill_url */
function get_bucket_url_clause
( p_col_num 	in number
, p_alias_name 		in varchar2
, p_prefix		in varchar2
, p_suffix		in varchar2
, p_add_bucket_num	in varchar2
)
return varchar2;

FUNCTION get_filter_where(p_cols in  POA_DBI_FILTER_TBL)
	return VARCHAR2 IS
	l_where VARCHAR2(1000);

BEGIN
  l_where := 'coalesce(';
  for i in 1..p_cols.COUNT LOOP
     if(i <> 1) then
	l_where := l_where || ',';
     end if;
     l_where := l_where || '
	decode(' || p_cols(i) || ',0,null,' || p_cols(i) || ')';
  END LOOP;

  l_where := l_where || ' ) is not null ';

  return l_where;
END;

FUNCTION get_filter_where (p_cols in  POA_DBI_FLEX_FILTER_TBL)
    return VARCHAR2 IS
    l_where VARCHAR2(1000);

BEGIN
    l_where := 'coalesce (';

    FOR i IN 1..p_cols.COUNT LOOP

        IF(i <> 1) THEN
            l_where := l_where || ',';
        END IF;

        IF (p_cols(i).modifier IS NULL) THEN

            -- No modifier
            l_where := l_where || '
                ' || p_cols(i).measure_name;

        ELSIF (p_cols(i).modifier = 'DECODE_0') THEN

            -- Decode 0's as NULLs
            l_where := l_where || '
                decode(' || p_cols(i).measure_name || ', 0, null,' ||
                       p_cols(i).measure_name || ')';
        END IF;

    END LOOP;

    l_where := l_where || ' ) is not null ';

    RETURN l_where;

END get_filter_where;

FUNCTION get_calendar_table
( period_type        in varchar2
, p_include_prior    in varchar2 := 'Y'
, p_include_opening  in varchar2 := 'N'
, p_called_by_union  in varchar2 := 'N'
) RETURN VARCHAR2 IS

l_table_name VARCHAR2(5000);

BEGIN
IF period_type like 'RL%'
THEN
--Begin Changes of spend trend graph
 IF NVL(p_called_by_union,'N') = 'Y'
 THEN
 RETURN  '( select start_date, end_date, end_date report_date, to_char(end_date,''dd-Mon-yy'') name, ordinal from rolling_cal where 1=1 ' ||
                case
                when p_include_prior = 'Y' and
                      p_include_opening = 'Y' then
                   ''
                 when p_include_prior = 'Y' then
                   --'and current_ind in (1,2)'
                   '   and ( bitand(current_ind_sum,1) = 1 OR
                         bitand(current_ind_sum,2) = 2) '
                 when p_include_opening = 'Y' then
                   ---'and current_ind in (1,4)'
                   '   and ( bitand(current_ind_sum,1) = 1 OR
                         bitand(current_ind_sum,4) = 4)'
                 else
                   'and bitand(current_ind_sum,1) = 1'
               end
              || ')' ;
  ELSE
--End Changes of spend trend graph
  return '( select start_date, end_date, end_date report_date, to_char(end_date,''dd-Mon-yy'') name, ordinal from '
          || '( select distinct '
              || 'decode(t.current_ind, 2, &BIS_PREVIOUS_EFFECTIVE_END_DATE'
                                  || ', 4, (&BIS_CURRENT_EFFECTIVE_START_DATE - 1)'
                                  || ', &BIS_CURRENT_EFFECTIVE_END_DATE)+(t.offset*&RLX_DAYS) '
                                  || '- &RLX_DAYS_TO_START start_date'
            || ', decode(t.current_ind, 2, &BIS_PREVIOUS_EFFECTIVE_END_DATE'
                                  || ', 4, (&BIS_CURRENT_EFFECTIVE_START_DATE - 1)'
                                  || ', &BIS_CURRENT_EFFECTIVE_END_DATE)+(t.offset*&RLX_DAYS) end_date'
            || ', decode(&BIS_TIME_COMPARISON_TYPE,''SEQUENTIAL'',-1,decode(t.current_ind,4,0,2,1,2)) ordinal '
            || 'from biv_trend_rpt t '
            || 'where t.offset > &RLX_ROWS_OFFSET '
            || case
                 when p_include_prior = 'Y' and
                      p_include_opening = 'Y' then
                   ''
                 when p_include_prior = 'Y' then
                   'and current_ind in (1,2)'
                 when p_include_opening = 'Y' then
                   'and current_ind in (1,4)'
                 else
                   'and current_ind = 1'
               end
         || ' )'
       || ' )';
  END IF ;---p_called_by_union
END IF ; --Rolling Periods

 if(period_type = 'YTD') then
    l_table_name := 'fii_time_ent_year';
  elsif(period_type = 'QTD') then
    l_table_name := 'fii_time_ent_qtr';
  elsif(period_type = 'MTD') then
    l_table_name := 'fii_time_ent_period';
  elsif(period_type = 'WTD') then
    l_table_name := 'fii_time_week';
  elsif(period_type = 'DAY') then
    l_table_name := '(select fnd_date.date_to_displaydate(report_date) name, t.report_date start_date, t.report_date end_date from fii_time_day t)';
  end if;

RETURN  l_table_name ;

END get_calendar_table ;


FUNCTION get_nested_pattern(period_type IN varchar2)
         return number
IS

  l_pattern number;

BEGIN

    if(period_type = 'RLY') then
      l_pattern := 8192;
    elsif(period_type = 'RLQ') then
      l_pattern := 4096;
    elsif(period_type = 'RLM') then
      l_pattern := 2048;
    elsif(period_type = 'RLW') then
      l_pattern := 1024;
    elsif(period_type = 'YTD') then
      l_pattern := 119;
    elsif(period_type = 'QTD') then
      l_pattern := 55;
    elsif(period_type = 'MTD') then
      l_pattern := 23;
    elsif(period_type = 'WTD') then
      l_pattern := 11;
    elsif(period_type = 'DAY') then
      l_pattern := 1;  end if;

  return l_pattern;

END get_nested_pattern;

FUNCTION get_nested_period_type_id(period_type IN varchar2)
         return number
IS

  l_period_type_id number;

BEGIN

  if(period_type = 'YTD') then
    l_period_type_id := 64;
  elsif(period_type = 'QTD') then
    l_period_type_id := 32;
  elsif(period_type = 'MTD') then
    l_period_type_id := 16;
  elsif(period_type = 'WTD') then
    l_period_type_id := 1;
  end if;

  return l_period_type_id;

END get_nested_period_type_id;


FUNCTION get_sec_profile RETURN NUMBER
IS
BEGIN
---Begin MOAC change
---Call to fnd_profile is made conditionally.
--  IF NVL(g_sec_profile_id,-1) = -1
--  THEN
--    g_sec_profile_id  := nvl(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'), -1);
--  END IF ;
---End MOAC change

  RETURN nvl(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'), -1) ;
END get_sec_profile;


Function get_fnd_user_profile RETURN NUMBER
IS

 l_fnd_user_profile NUMBER;

BEGIN

 l_fnd_user_profile := fnd_global.user_id;

 return l_fnd_user_profile;

END get_fnd_user_profile;

Function get_fnd_employee_profile RETURN NUMBER
IS
BEGIN
  return fnd_global.employee_id;
END get_fnd_employee_profile;


FUNCTION bitor(x in number,y in number) return number
AS

BEGIN

    return x + y - bitand(x,y);

END bitor;

PROCEDURE refresh (p_mv_name  IN  VARCHAR2)
IS

   l_parallel_degree NUMBER := 0;

BEGIN

   l_parallel_degree := bis_common_parameters.GET_DEGREE_OF_PARALLELISM();
   IF (l_parallel_degree  = 1) THEN
       l_parallel_degree := 0;
   END IF;

   POA_LOG.debug_line('Refreshing : '|| p_mv_name);

   DBMS_MVIEW.REFRESH(list   => p_mv_name,
                      method => '?',
                      parallelism => l_parallel_degree);
EXCEPTION
    when others then
        raise;
END;

PROCEDURE get_parameter_values(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                               p_dim_map in out NOCOPY poa_dbi_dim_map,
                               p_view_by out NOCOPY VARCHAR2,
                               p_comparison_type out NOCOPY VARCHAR2,
                               p_xtd out NOCOPY VARCHAR2,
                               p_as_of_date out NOCOPY DATE,
                               p_prev_as_of_date out NOCOPY DATE,
                               p_cur_suffix out NOCOPY VARCHAR2,
                               p_nested_pattern out NOCOPY NUMBER,
                               p_dim_bmap in out NOCOPY NUMBER)
IS

  l_currency varchar2(30);
  l_period_type varchar2(30);

BEGIN

  for i in 1..p_param.COUNT LOOP
    if( p_param(i).parameter_name= 'VIEW_BY') then
      p_view_by := p_param(i).parameter_value;
    end if;
    if(p_param(i).parameter_name = 'PERIOD_TYPE') then
      l_period_type := p_param(i).parameter_value;
    end if;
    if(p_param(i).parameter_name = 'TIME_COMPARISON_TYPE') then
       if(p_param(i).parameter_value = 'YEARLY') then
         p_comparison_type := 'Y';
       else
         p_comparison_type := 'S';
       end if;
    end if;
    if(p_param(i).parameter_name = 'AS_OF_DATE') then
      p_as_of_date := to_date(p_param(i).parameter_value, 'DD-MM-YYYY');
    end if;
    if(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
      l_currency := p_param(i).parameter_id;
    end if;

    if(p_dim_map.exists(p_param(i).parameter_name)) then
      if(p_param(i).parameter_id = '''''' or p_param(i).parameter_id is null or p_param(i).parameter_id = '' or  p_param(i).parameter_id = 'All') then
        p_dim_map(p_param(i).parameter_name).value := 'All';
      else
        p_dim_map(p_param(i).parameter_name).value := 'Val';
      end if;
      if(p_param(i).parameter_id is not null and p_param(i).parameter_id <> '''''') then
        p_dim_bmap := bitor(p_dim_bmap, p_dim_map(p_param(i).parameter_name).bmap);
      end if;
    end if;
  END LOOP;

  if(p_dim_map.exists(p_view_by)) then
    p_dim_bmap := bitor(p_dim_bmap,p_dim_map(p_view_by).bmap);
  end if;

   if l_period_type = 'FII_ROLLING_WEEK' then
     p_xtd := 'RLW';
   elsif l_period_type = 'FII_ROLLING_MONTH' then
     p_xtd := 'RLM';
   elsif l_period_type = 'FII_ROLLING_QTR' then
     p_xtd := 'RLQ';
   elsif l_period_type = 'FII_ROLLING_YEAR' then
     p_xtd := 'RLY';
   elsif l_period_type = 'FII_TIME_ENT_YEAR' then
     p_xtd := 'YTD';
   elsif l_period_type = 'FII_TIME_ENT_QTR' then
     p_xtd := 'QTD';
   elsif l_period_type = 'FII_TIME_ENT_PERIOD' then
     p_xtd := 'MTD';
   elsif l_period_type = 'FII_TIME_DAY' then
     p_xtd := 'DAY';
   else
     p_xtd := 'WTD';
   end if;

  if(p_as_of_date is null) then p_as_of_date := sysdate; end if;
  p_prev_as_of_date := poa_dbi_calendar_pkg.previous_period_asof_date(p_as_of_date, p_xtd, p_comparison_type);
  p_nested_pattern := poa_dbi_util_pkg.get_nested_pattern(p_xtd);

  if(p_comparison_type is null) then p_comparison_type := 'S'; end if;

  if(l_currency = '''FII_GLOBAL1''') then
    p_cur_suffix := 'g';
--Added by Arun.R for secondary global currency chanegs for OKI
  elsif(l_currency = '''FII_GLOBAL2''') then
    p_cur_suffix := 'sg';
--Added by Ashok for Annualization for OKI
  elsif (l_currency = '''FII_GLOBAL3''') then
		p_cur_suffix := 'a';
  elsif(l_currency is not null) then
    p_cur_suffix := 'b';
  end if;

  if(p_cur_suffix is null) then p_cur_suffix := 'g'; end if;

EXCEPTION
  WHEN OTHERS THEN
   POA_LOG.debug_line('refresh_manual_dist mvs ' || Sqlerrm || sqlcode || sysdate);
   raise;

END get_parameter_values;

PROCEDURE get_drill_param_values(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                               p_dim_map in out nocopy poa_dbi_dim_map,
                               p_cur_suffix out NOCOPY VARCHAR2)

IS

  l_currency varchar2(30);

BEGIN

  for i in 1..p_param.COUNT LOOP

  if(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
     l_currency := p_param(i).parameter_id;
  end if;

  if(p_dim_map.exists(p_param(i).parameter_name)) then
        if(p_param(i).parameter_id = '''''' or p_param(i).parameter_id is null or p_param(i).parameter_id = '' or  p_param(i).parameter_id = 'All') then
           p_dim_map(p_param(i).parameter_name).value := 'All';
         else
          p_dim_map(p_param(i).parameter_name).value := 'Val';
         end if;
  end if;
  END LOOP;

  if(l_currency = '''FII_GLOBAL1''') then
    p_cur_suffix := 'g';
  elsif(l_currency = '''FII_GLOBAL2''') then
    p_cur_suffix := 'sg';
  elsif(l_currency is not null) then
    p_cur_suffix := 'b';
  end if;

  if(p_cur_suffix is null) then p_cur_suffix := 'g'; end if;

EXCEPTION
  WHEN OTHERS THEN
   POA_LOG.debug_line('refresh_manual_dist mvs ' || Sqlerrm || sqlcode || sysdate);
   raise;

END get_drill_param_values;


FUNCTION get_where_clauses(p_dim_map poa_dbi_dim_map, p_trend IN VARCHAR2) RETURN VARCHAR2
IS

  l_where_clause VARCHAR2(4000);
  i VARCHAR2(100);

BEGIN

   i := p_dim_map.FIRST;  -- get subscript of first element
   WHILE i IS NOT NULL LOOP
      if(p_dim_map(i).generate_where_clause = 'Y') then
         if(p_dim_map(i).value = 'All') then
            null;
         else
            l_where_clause := l_where_clause ||
            ' and fact.'|| p_dim_map(i).col_name || ' in (&' || i || ') ';
         end if;
      end if;
       i := p_dim_map.NEXT(i);
    END LOOP;
    return l_where_clause;

END get_where_clauses;

/* pass in the bucket set short name in p_short_name. This procedure queries
up that bucket set and adds columns to p_col_tbl for each bucket range
defined--by calling add_column.  Returns the x_bucket_rec so that it
can be used for the outer bucket query
*/
procedure add_bucket_columns
(p_short_name   in varchar2
, p_col_tbl      in out nocopy poa_DBI_UTIL_PKG.poa_dbi_col_tbl
, p_col_name     in varchar2
, p_alias_name   in varchar2
, x_bucket_rec   out nocopy bis_bucket_pub.bis_bucket_rec_type
, p_grand_total  in varchar2 := 'Y'
, p_prior_code   in varchar2 := BOTH_PRIORS
, p_to_date_type in varchar2 := 'XTD'
)
is
  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_return_status varchar2(3);
  l_error_tbl bis_utilities_pub.error_tbl_type;
begin
  bis_bucket_pub.retrieve_bis_bucket
  ( p_short_name     => p_short_name
  , x_bis_bucket_rec => l_bucket_rec
  , x_return_status  => l_return_status
  , x_error_tbl      => l_error_tbl
  );
  if l_return_status = 'S' then
    if l_bucket_rec.range1_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b1'
      , p_alias_name => p_alias_name || '_b1'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range2_name is not null then
     poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b2'
      , p_alias_name => p_alias_name || '_b2'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range3_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b3'
      , p_alias_name => p_alias_name || '_b3'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range4_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b4'
      , p_alias_name => p_alias_name || '_b4'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range5_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b5'
      , p_alias_name => p_alias_name || '_b5'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range6_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b6'
      , p_alias_name => p_alias_name || '_b6'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range7_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b7'
      , p_alias_name => p_alias_name || '_b7'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range8_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b8'
      , p_alias_name => p_alias_name || '_b8'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range9_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b9'
      , p_alias_name => p_alias_name || '_b9'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range10_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b10'
      , p_alias_name => p_alias_name || '_b10'
      , p_grand_total => p_grand_total
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
  end if;
  x_bucket_rec := l_bucket_rec;
end add_bucket_columns;

function get_bucket_url_clause
( p_col_num 	in number
, p_alias_name		in varchar2
, p_prefix		in varchar2
, p_suffix		in varchar2
, p_add_bucket_num	in varchar2
)
return varchar2
is
begin
  return  ', ' || p_prefix ||
	       case p_add_bucket_num
		when 'Y' then p_col_num
		end || p_suffix || ' ' ||
		p_alias_name || '_B' || p_col_num;

end get_bucket_url_clause;


function get_bucket_clause
( p_col_num in number
, p_col_name in varchar2
, p_alias_name       in varchar2
, p_prefix	     in varchar2
, p_suffix	     in varchar2
, p_total_flag       in varchar2
)
return varchar2
is
begin
  return  ', ' || p_prefix || p_col_name || '_b'
	    || p_col_num ||
			case p_total_flag
		 	  when 'Y' then '_total'
			end || p_suffix || ' ' ||
			p_alias_name || '_B' || p_col_num;

end get_bucket_clause;

/*
p_bucket_rec = the bucket rec returned from add_bucket_columns
p_col_name = similar to 'oset.c_age_bucket' => you have columns
			such as oset.c_age_bucket_b1, oset.c_age_bucket_b2...
p_alias_name = similar to 'BIV_MEASURE10' => you want to alias
			BIV_MEASURE10_B1, BIV_MEASURE10_B2, etc..
*/
function get_bucket_outer_query
( p_bucket_rec       in bis_bucket_pub.bis_bucket_rec_type
, p_col_name in varchar2
, p_alias_name       in varchar2
, p_prefix	     in varchar2
, p_suffix	     in varchar2
, p_total_flag       in varchar2 default 'N'
)
return varchar2
is
  l_query varchar2(10000);
begin
  if p_bucket_rec.range1_name is not null then
	l_query := get_bucket_clause(1, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  if p_bucket_rec.range2_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(2, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  if p_bucket_rec.range3_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(3, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);

  end if;
  if p_bucket_rec.range4_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(4, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  if p_bucket_rec.range5_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(5, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  if p_bucket_rec.range6_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(6, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  if p_bucket_rec.range7_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(7, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  if p_bucket_rec.range8_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(8, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  if p_bucket_rec.range9_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(9, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  if p_bucket_rec.range10_name is not null then
  	l_query := l_query || fnd_global.newline ||
		     get_bucket_clause(10, p_col_name, p_alias_name,
			p_prefix, p_suffix, p_total_flag);
  end if;
  return l_query;
end get_bucket_outer_query;

/*****************************************************************
get_bucket_drill_url
----------------------------------------------------------------
p_bucket_rec = the bucket rec returned from add_bucket_columns
p_alias_name = similar to 'POA_ATTRRIBUTE10'

Returns:
p_prefix || bucket_num || p_suffix || ' ' || p_alias_name || bucket_num
for each bucket defined in p_bucket rec.

Useful when you have buckets with drills to other reports that need to preserve the context of the bucket you drilled on like.

If you pass p_add_bucket_num = 'N', then the bucket number is NOT concatenated into the url, so return value is:
p_prefix || p_suffix || ' ' || p_alias_name || bucket_num

***************************************************************************/
function get_bucket_drill_url
( p_bucket_rec       in bis_bucket_pub.bis_bucket_rec_type
, p_alias_name       in varchar2
, p_prefix	     in varchar2
, p_suffix	     in varchar2
, p_add_bucket_num   in varchar2
)
return varchar2
is
  l_query varchar2(10000);
begin
  if p_bucket_rec.range1_name is not null then
	l_query := get_bucket_url_clause(1, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range2_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(2, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range3_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(3, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range4_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(4, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range5_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(5, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range6_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(6, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range7_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(7, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range8_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(8, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range9_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(9, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  if p_bucket_rec.range10_name is not null then
	l_query := l_query || fnd_global.newline ||
		     get_bucket_url_clause(10, p_alias_name, p_prefix,
			p_suffix, p_add_bucket_num);
  end if;
  return l_query;
end get_bucket_drill_url;


/* possible values for to_date_type:
XTD = period to date
XED = period to end of period (i.e. entire period)
YTD = year to date
ITD = inception to date

Most cases in DBI will use the default XTD.
*/
PROCEDURE add_column(p_col_tbl IN OUT nocopy poa_dbi_col_tbl,
                     p_col_name IN VARCHAR2,
                     p_alias_name IN VARCHAR2,
                     p_grand_total IN VARCHAR2 := 'Y',
                     p_prior_code IN NUMBER := BOTH_PRIORS,
                     p_to_date_type IN VARCHAR2 := 'XTD')
IS

  l_col_rec poa_dbi_col_rec;

BEGIN

    l_col_rec.column_name := p_col_name;
    l_col_rec.column_alias := p_alias_name;
    l_col_rec.grand_total := p_grand_total;
    l_col_rec.prior_code := p_prior_code;
    l_col_rec.to_date_type := p_to_date_type;

    p_col_tbl.extend;
    p_col_tbl(p_col_tbl.count) := l_col_rec;

END add_column;

FUNCTION change_clause(cur_col IN VARCHAR2, prior_col IN VARCHAR2, change_type IN VARCHAR2 := 'NP')
RETURN VARCHAR2
IS

BEGIN
    if(change_type = 'NP')then
        return '(((nvl(' || cur_col || ',0) - ' || prior_col ||
               ')/abs(decode(' || prior_col ||  ',0,null,'
               || prior_col
               || '))) * 100)';
    end if;

    return '(' || cur_col || ' - ' || prior_col || ')';
END change_clause;

FUNCTION rate_clause(numerator IN VARCHAR2, denominator IN VARCHAR2, rate_type IN VARCHAR2 := 'P')
RETURN VARCHAR2
IS
BEGIN
        -- if rate is a ratio
        if(rate_type = 'NP') then
      return '(' || numerator || '/decode(' || denominator || ',0,null,'
             || denominator || '))';
        end if;

        -- if rate is a percent
        return '((nvl(' || numerator || ',0)/decode(' || denominator || ',0,null,'
        || denominator || '))*100)';
END rate_clause;

FUNCTION get_commodity_sec_where(p_commodity_value VARCHAR2,
                                 p_trend IN VARCHAR2 :='N') return VARCHAR2
IS

  l_sec_where_clause VARCHAR2(1000):=null;

BEGIN

    if (p_commodity_value is null or
        p_commodity_value = '' or
        p_commodity_value = '''''' or
        p_commodity_value = 'All') then

       l_sec_where_clause :=
      ' fact.commodity_id in (select commodity_id
  				from 	po_commodity_grants sec,
					fnd_menus menu
				  where sec.person_id = &FND_EMPLOYEE_ID and
					  menu.menu_name = ''PO_COMMODITY_MANAGER'' and
					  sec.menu_id = menu.menu_id)';
    end if;
    return l_sec_where_clause;

END get_commodity_sec_where;

FUNCTION get_in_commodity_sec_where(p_commodity_value VARCHAR2,
        p_trend IN VARCHAR2 :='N') return VARCHAR2 IS
l_in_sec_where_clause VARCHAR2(1000):=null;
BEGIN
        if(p_commodity_value is null or
           p_commodity_value = '' or
           p_commodity_value='''''' or
           p_commodity_value = 'All') then

           /*     l_in_sec_where_clause :=
                ' and fact.commodity_id = sec.commodity_id
                  and u.user_id = &FND_USER_ID
                  and sec.person_id = u.employee_id
                  and f.function_name =''POA_DBI_COMMODITY_RPTS_VIEW''
                  and poa_me.function_id = f.function_id
                  and sec.menu_id = poa_me.menu_id ';  */
           /* Added on 18-Jul-2005 -- As per Recommendation by Performance Team */
               l_in_sec_where_clause := '
                  and fact.commodity_id in
		  (select sec.commodity_id
		   from   po_commodity_grants sec,
			  fnd_menus menu
		   where sec.person_id = &FND_EMPLOYEE_ID
                   and  menu.menu_name = ''PO_COMMODITY_MANAGER''
                   and  sec.menu_id = menu.menu_id) ';


         end if;
        return l_in_sec_where_clause;
end;

FUNCTION get_ou_sec_where(p_ou_value VARCHAR2, p_ou_fact_col VARCHAR2,
                          p_trend IN VARCHAR2 :='N') return VARCHAR2
IS

  l_sec_where_clause VARCHAR2(1000) := null;

BEGIN

     if (p_ou_value is null or
         p_ou_value = '' or
         p_ou_value = '''''' or
         p_ou_value = 'All') then

      l_sec_where_clause :=
            ' fact.' || p_ou_fact_col || ' in
            (select orgl.organization_id
             from per_organization_list orgl,
                  hr_organization_information orgi
             where orgi.org_information1 = ''OPERATING_UNIT''
             and orgl.organization_id = orgi.organization_id
             and orgl.security_profile_id = &SEC_ID ) ';
    end if;
    return l_sec_where_clause;

END get_ou_sec_where;

FUNCTION get_in_ou_sec_where(p_ou_value VARCHAR2, p_ou_fact_col VARCHAR2,
        p_use_bind IN VARCHAR2 :='Y') return VARCHAR2 IS
l_in_sec_where_clause VARCHAR2(1000) := null;
BEGIN
          IF(p_ou_value is null or
           p_ou_value = '' or
           p_ou_value = '''''' or
           p_ou_value = 'All') THEN
           --Begin MOAC changes
           IF poa_dbi_util_pkg.get_sec_profile <> -1 THEN
           --End MOAC changes
               /*     l_in_sec_where_clause :=
                          ' and fact.' || p_ou_fact_col || ' = orgl.organization_id
                             and orgl.security_profile_id = ';  */
                 l_in_sec_where_clause := '
                 and exists (select 1
		             from   per_organization_list orgl
		             where  fact.org_id = orgl.organization_id
                   and  orgl.security_profile_id = ';

                if(p_use_bind = 'Y') then
			l_in_sec_where_clause := l_in_sec_where_clause || '&SEC_ID ' || ')';
		else
			l_in_sec_where_clause := l_in_sec_where_clause || poa_dbi_util_pkg.get_sec_profile || ')';
		end if;
           --Begin MOAC changes
           ELSE
              IF (p_use_bind = 'Y') THEN
                  l_in_sec_where_clause := ' and fact.org_id = ' ||'&ORG_ID ';
              ELSE
                  l_in_sec_where_clause := ' and fact.org_id = ' || poa_dbi_util_pkg.get_ou_org_id ;
              END IF ;
           END IF ; ---poa_dbi_util_pkg.get_sec_profile <> -1
           --End MOAC changes
        end if;
        return l_in_sec_where_clause;

END;

FUNCTION get_in_supplier_sec_where(p_supplier_value VARCHAR2) return VARCHAR2 IS
l_in_sec_where_clause VARCHAR2(1000) := null;
BEGIN
          if(p_supplier_value is null or
           p_supplier_value = '' or
           p_supplier_value = '''''' or
           p_supplier_value = 'All') then

                l_in_sec_where_clause :=
                        ' and exists(select 1 from ak_web_user_sec_attr_values
isp, fnd_application appl
                         where
			  isp.web_user_id = &FND_USER_ID
			  and isp.number_value = fact.supplier_id
                          and isp.attribute_application_id = appl.application_id
                          and appl.application_short_name = ''POS'') ';

        end if;
        return l_in_sec_where_clause;

END get_in_supplier_sec_where;


PROCEDURE get_custom_trend_binds
( p_xtd             in varchar2
, p_comparison_type in varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
, p_opening_balance in varchar2 := 'N'
)
IS

  l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN
  if x_custom_output is null then
    x_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  if p_xtd not like 'RL%' then
  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;

  if(p_xtd = 'YTD') then
    l_custom_rec.attribute_value := 'TIME+FII_TIME_ENT_YEAR';
  elsif(p_xtd = 'QTD') then
    l_custom_rec.attribute_value := 'TIME+FII_TIME_ENT_QTR';
  elsif(p_xtd = 'MTD') then
    l_custom_rec.attribute_value := 'TIME+FII_TIME_ENT_PERIOD';
  elsif(p_xtd = 'WTD') then
    l_custom_rec.attribute_value := 'TIME+FII_TIME_WEEK';
  elsif(p_xtd = 'DAY') then
    l_custom_rec.attribute_value := 'TIME+FII_TIME_DAY';
  else
    l_custom_rec.attribute_value := 'TIME+FII_TIME_WEEK';
  end if;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;
  l_custom_rec.attribute_name := '&SPAN';
   if(p_xtd = 'YTD') then
    l_custom_rec.attribute_value := 365;
  elsif(p_xtd = 'QTD') then
    l_custom_rec.attribute_value := 90;
  elsif(p_xtd = 'MTD') then
    l_custom_rec.attribute_value := 30;
  elsif(p_xtd = 'WTD') then
    l_custom_rec.attribute_value := 7;
  elsif(p_xtd = 'DAY') then
    l_custom_rec.attribute_value := 1;
  else
    l_custom_rec.attribute_value := 7;
  end if;

  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;
  end if;

  l_custom_rec.attribute_name := '&LAG';
  l_custom_rec.attribute_value := get_trend_lag(p_xtd, p_comparison_type);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  l_custom_rec.attribute_name := '&SEC_ID';
  l_custom_rec.attribute_value := poa_dbi_util_pkg.get_sec_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  l_custom_rec.attribute_name := '&FND_USER_ID';
  l_custom_rec.attribute_value := poa_dbi_util_pkg.get_fnd_user_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  l_custom_rec.attribute_name := '&FND_EMPLOYEE_ID';
  l_custom_rec.attribute_value := poa_dbi_util_pkg.get_fnd_employee_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  ---Begin MOAC changes
  l_custom_rec.attribute_name := '&ORG_ID';
  l_custom_rec.attribute_value := poa_dbi_util_pkg.get_ou_org_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;
  ---End  MOAC changes

  if p_xtd like 'RL%' then
    l_custom_rec.attribute_name := '&RLX_RSD_OFFSET';
    -- the bind variable calculates the offset from the as of date
    -- (current or prior) to the start of the first rolling period
    -- this emulates &BIS_CURRENT_REPORT_START_DATE for XTD periods
    l_custom_rec.attribute_value := case p_xtd
                                      when 'RLW' then (7*13)-1
                                      when 'RLM' then (30*12)-1
                                      when 'RLQ' then
                                        case p_comparison_type
                                          when 'S' then (90*8)-1
                                          else (90*4)-1
                                        end
                                      when 'RLY' then (365*4)-1
                                      else 0
                                    end;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    l_custom_rec.attribute_name := '&RLX_ROWS_OFFSET';
    -- this bind variable calculates the offset for the number
    -- of rows the the in-line view for needs to return
    l_custom_rec.attribute_value := case p_xtd
                                      when 'RLW' then -13
                                      when 'RLM' then -12
                                      when 'RLQ' then
                                        case p_comparison_type
                                          when 'S' then -8
                                          else -4
                                        end
                                      when 'RLY' then -4
                                    end;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    l_custom_rec.attribute_name := '&RLX_DAYS';
    -- this bind variable returns the number of days in a rolling period
    l_custom_rec.attribute_value := case p_xtd
                                      when 'RLW' then 7
                                      when 'RLM' then 30
                                      when 'RLQ' then 90
                                      when 'RLY' then 365
                                    end;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    l_custom_rec.attribute_name := '&RLX_DAYS_TO_START';
    -- this bind variable returns the number of days back to the start of
    -- rolling period for the end of the period (&RLX_DAYS -1)
    l_custom_rec.attribute_value := case p_xtd
                                      when 'RLW' then 6
                                      when 'RLM' then 29
                                      when 'RLQ' then 89
                                      when 'RLY' then 364
                                    end;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

  end if;

END get_custom_trend_binds;

PROCEDURE get_custom_status_binds(x_custom_output IN OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

   l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN

  if x_custom_output is null then
    x_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  l_custom_rec.attribute_name := '&SEC_ID';
  l_custom_rec.attribute_value := poa_dbi_util_pkg.get_sec_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  l_custom_rec.attribute_name := '&FND_USER_ID';
  l_custom_rec.attribute_value := poa_dbi_util_pkg.get_fnd_user_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  l_custom_rec.attribute_name := '&FND_EMPLOYEE_ID';
  l_custom_rec.attribute_value := poa_dbi_util_pkg.get_fnd_employee_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  ---Begin MOAC changes
  l_custom_rec.attribute_name := '&ORG_ID';
  l_custom_rec.attribute_value := poa_dbi_util_pkg.get_ou_org_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;
  ---End  MOAC changes

END get_custom_status_binds;


FUNCTION get_trend_lag(p_xtd IN varchar2,  p_comparison_type IN varchar2)
         return number
IS

BEGIN

  if(p_comparison_type = 'S') then
    return 1;
  else
    return case p_xtd
             when 'YTD' then 1
             when 'QTD' then 4
             when 'MTD' then 12
             when 'WTD' then 13
             when 'DAY' then 7
             when 'RLY' then 4
             when 'RLQ' then 4
             when 'RLM' then 12
             when 'RLW' then 13
           end;
  end if;

END get_trend_lag;

FUNCTION get_report_start_date
( p_period_type      in varchar2
, p_prior            in varchar2 := 'N'
)
return varchar2
IS

  l_cur_prior varchar2(40) := '&BIS_CURRENT_EFFECTIVE_END_DATE';

BEGIN

  if p_prior = 'Y' then
    l_cur_prior := '&BIS_PREVIOUS_EFFECTIVE_END_DATE';
  end if;

  return l_cur_prior || ' - &RLX_RSD_OFFSET';

END get_report_start_date;

PROCEDURE get_custom_balance_binds
( p_custom_output in out nocopy bis_query_attributes_tbl
, p_balance_fact  in varchar2
, p_xtd           in varchar2  := null
)
IS

  l_custom_rec bis_query_attributes;

BEGIN

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;
  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

  l_custom_rec.attribute_name := '&LAST_COLLECTION';
  l_custom_rec.attribute_value := to_char(fnd_date.displayDT_to_date(bis_collection_utilities.get_last_refresh_period(upper(p_balance_fact))),'dd/mm/yyyy');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  -- Balance report in XTD Model
  IF(p_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
    l_custom_rec.attribute_name                := '&YTD_NESTED_PATTERN';
    l_custom_rec.attribute_value               := 1143;
    l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.integer_bind;
    p_custom_output.extend;
    p_custom_output(p_custom_output.count) := l_custom_rec;
  END IF;


END get_custom_balance_binds;

PROCEDURE get_custom_rolling_binds
( p_custom_output in out nocopy bis_query_attributes_tbl
, p_xtd in varchar2
)
IS

  l_custom_rec bis_query_attributes;

BEGIN

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

  l_custom_rec.attribute_name := '&RLX_NESTED_PATTERN';
  l_custom_rec.attribute_value := case p_xtd
                                    when 'RLW' then 1024
                                    when 'RLM' then 2048
                                    when 'RLQ' then 4096
                                    when 'RLY' then 8192
                                  end;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

END get_custom_rolling_binds;

procedure bind_low_high
( p_param         in bis_pmv_page_parameter_tbl
, p_short_name    in varchar2
, p_dim_level	  in varchar2
, p_low           in varchar2
, p_high          in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
)
is

  l_range_low number;
  l_range_high number;

  l_range_id number;
  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_return_status varchar2(3);
  l_error_tbl bis_utilities_pub.error_tbl_type;

  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  for i in 1..p_param.count loop
    if p_param(i).parameter_name = p_dim_level then
      l_range_id :=  replace(p_param(i).parameter_id,'''',null);
    end if;
  end loop;

  if l_range_id is null then
    return;
  end if;

  bis_bucket_pub.retrieve_bis_bucket
  ( p_short_name     => p_short_name
  , x_bis_bucket_rec => l_bucket_rec
  , x_return_status  => l_return_status
  , x_error_tbl      => l_error_tbl
  );

  if l_return_status = 'S' then

    if l_range_id = 1 then
      l_range_low := l_bucket_rec.range1_low;
      l_range_high := l_bucket_rec.range1_high;
    elsif l_range_id = 2 then
      l_range_low := l_bucket_rec.range2_low;
      l_range_high := l_bucket_rec.range2_high;
    elsif l_range_id = 3 then
      l_range_low := l_bucket_rec.range3_low;
      l_range_high := l_bucket_rec.range3_high;
    elsif l_range_id = 4 then
      l_range_low := l_bucket_rec.range4_low;
      l_range_high := l_bucket_rec.range4_high;
    elsif l_range_id = 5 then
      l_range_low := l_bucket_rec.range5_low;
      l_range_high := l_bucket_rec.range5_high;
    elsif l_range_id = 6 then
      l_range_low := l_bucket_rec.range6_low;
      l_range_high := l_bucket_rec.range6_high;
    elsif l_range_id = 7 then
      l_range_low := l_bucket_rec.range7_low;
      l_range_high := l_bucket_rec.range7_high;
    elsif l_range_id = 8 then
      l_range_low := l_bucket_rec.range8_low;
      l_range_high := l_bucket_rec.range8_high;
    elsif l_range_id = 9 then
      l_range_low := l_bucket_rec.range9_low;
      l_range_high := l_bucket_rec.range9_high;
    elsif l_range_id = 10 then
      l_range_low := l_bucket_rec.range10_low;
      l_range_high := l_bucket_rec.range10_high;
    end if;
  end if;

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  l_custom_rec.attribute_name := p_low;
  l_custom_rec.attribute_value := l_range_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := p_high;
  l_custom_rec.attribute_value := l_range_high;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

end bind_low_high;

PROCEDURE get_custom_day_binds(p_custom_output IN OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
                               p_as_of_date    IN DATE,
                               p_comparison_type IN VARCHAR2)
IS
   l_custom_rec BIS_QUERY_ATTRIBUTES;
   l_prev_as_of_date DATE;

BEGIN

  RETURN ;

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  IF(p_comparison_type = 'S') THEN
     l_prev_as_of_date := p_as_of_date - 1;
  ELSIF (p_comparison_type = 'Y') THEN
     l_prev_as_of_date := FII_TIME_API.ent_sd_lyr_end(p_as_of_date);
  ELSIF (p_comparison_type = 'W') THEN
     l_prev_as_of_date := p_as_of_date-7;
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  l_custom_rec.attribute_name := '&BIS_CURRENT_REPORT_START_DATE';
  l_custom_rec.attribute_value := to_char(p_as_of_date-6,'dd/mm/yyyy');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  p_custom_output.EXTEND;
  p_custom_output(p_custom_output.COUNT) := l_custom_rec;

  l_custom_rec.attribute_name := '&BIS_PREVIOUS_REPORT_START_DATE';
  l_custom_rec.attribute_value := to_char(l_prev_as_of_date-6,'dd/mm/yyyy');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  p_custom_output.EXTEND;
  p_custom_output(p_custom_output.COUNT) := l_custom_rec;

  l_custom_rec.attribute_name := '&BIS_CURRENT_EFFECTIVE_END_DATE';
  l_custom_rec.attribute_value := to_char(p_as_of_date,'dd/mm/yyyy');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  p_custom_output.EXTEND;
  p_custom_output(p_custom_output.COUNT) := l_custom_rec;

  l_custom_rec.attribute_name := '&BIS_PREVIOUS_EFFECTIVE_END_DATE';
  l_custom_rec.attribute_value := to_char(l_prev_as_of_date,'dd/mm/yyyy');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  p_custom_output.EXTEND;
  p_custom_output(p_custom_output.COUNT) := l_custom_rec;

END get_custom_day_binds;


---Begin MOAC changes

FUNCTION get_ou_org_id RETURN NUMBER
IS
BEGIN
--  IF NVL(g_org_id , -1) = -1
--  THEN
--     g_org_id := NVL(fnd_profile.value('ORG_ID'), -1);
--  END IF ;
  RETURN  NVL(fnd_profile.value('ORG_ID'), -1);
END get_ou_org_id;

---End MOAC changes

---Begin Changes for spend trend graph
FUNCTION get_rolling_inline_view
return varchar2
IS

BEGIN
    return ' ( with rolling_cal as ( select start_date, end_date, end_date report_date, to_char(end_date,''dd-Mon-yy'') name, ordinal, current_ind_sum from '
          || '( select '
              || 'decode(t.current_ind, 2, &BIS_PREVIOUS_EFFECTIVE_END_DATE'
                                  || ', 4, (&BIS_CURRENT_EFFECTIVE_START_DATE - 1)'
                                  || ', &BIS_CURRENT_EFFECTIVE_END_DATE)+(t.offset*&RLX_DAYS) '
                                  || '- &RLX_DAYS_TO_START start_date'
            || ', decode(t.current_ind, 2, &BIS_PREVIOUS_EFFECTIVE_END_DATE'
                                  || ', 4, (&BIS_CURRENT_EFFECTIVE_START_DATE - 1)'
                                  || ', &BIS_CURRENT_EFFECTIVE_END_DATE)+(t.offset*&RLX_DAYS) end_date'
            || ', decode(&BIS_TIME_COMPARISON_TYPE,''SEQUENTIAL'',-1,decode(t.current_ind,4,0,2,1,2)) ordinal , SUM(current_ind) current_ind_sum  '
            || 'from biv_trend_rpt t '
            || 'where t.offset > &RLX_ROWS_OFFSET '
            || 'group by decode(t.current_ind, 2, &BIS_PREVIOUS_EFFECTIVE_END_DATE'
                                  || ', 4, (&BIS_CURRENT_EFFECTIVE_START_DATE - 1)'
                                  || ', &BIS_CURRENT_EFFECTIVE_END_DATE)+(t.offset*&RLX_DAYS) '
                                  || '- &RLX_DAYS_TO_START '
            || ', decode(t.current_ind, 2, &BIS_PREVIOUS_EFFECTIVE_END_DATE'
                                  || ', 4, (&BIS_CURRENT_EFFECTIVE_START_DATE - 1)'
                                  || ', &BIS_CURRENT_EFFECTIVE_END_DATE)+(t.offset*&RLX_DAYS) '
            || ', decode(&BIS_TIME_COMPARISON_TYPE,''SEQUENTIAL'',-1,decode(t.current_ind,4,0,2,1,2))  '
         || ' )'
         || ' )';

END get_rolling_inline_view ;

---End  Changes for spend trend graph


END poa_dbi_util_pkg;

/
