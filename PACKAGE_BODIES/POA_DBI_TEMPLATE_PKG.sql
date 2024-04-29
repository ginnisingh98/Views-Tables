--------------------------------------------------------
--  DDL for Package Body POA_DBI_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_TEMPLATE_PKG" 
/* $Header: poadbitmplb.pls 120.3 2006/07/25 09:13:35 sdiwakar noship $ */

AS


FUNCTION get_paren_str(p_paren_count IN NUMBER,
		p_filter_where IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_group_and_sel_clause(
	p_join_tables IN poa_dbi_util_pkg.poa_dbi_join_tbl
	, p_use_alias IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION get_paren_str(p_paren_count IN NUMBER,
		p_filter_where IN VARCHAR2) RETURN VARCHAR2
IS
 l_paren_str	VARCHAR2 (10000);
BEGIN
    IF p_paren_count = 2
    THEN
      l_paren_str    := ' ) oset05 ' || p_filter_where || ') oset ';
    ELSIF p_paren_count = 3
    THEN
      l_paren_str    := ' ) ) ' || p_filter_where || ' ) oset ';
    ELSIF p_paren_count = 5
    THEN
      l_paren_str    := ' ) oset05) oset10) oset15) oset20 '
         || p_filter_where || ')oset ';
    ELSIF p_paren_count = 6
    THEN
      l_paren_str    := ' ) oset05) oset10) oset15) oset20) oset25 '
         || p_filter_where || ' )oset ';
    ELSIF p_paren_count = 7
    THEN
      l_paren_str    := ' ) oset05) oset10) oset13) oset15) oset20) '
         || p_filter_where || ' )oset ';
    END IF;

    return l_paren_str;
END get_paren_str;

  FUNCTION status_sql (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                          VARCHAR2 := 'Y'
  , p_paren_count               IN       NUMBER := 3
  , p_filter_where              IN       VARCHAR2 := NULL
  , p_generate_viewby           IN       VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_in_join_tbl := NULL)
    RETURN VARCHAR2
  IS
    l_query                  VARCHAR2 (10000);
    l_col_names              VARCHAR2 (10000);
    l_group_and_sel_clause   VARCHAR2 (10000);
    l_from_clause            VARCHAR2 (10000);
    l_full_where_clause           VARCHAR2 (10000);
    l_grpid_clause           VARCHAR2 (200);
    l_compute_prior          VARCHAR2 (1)     := 'N';
    l_compute_prev_prev      VARCHAR2 (1)     := 'N';
    l_paren_str              VARCHAR2 (2000);
    l_compute_opening_bal    VARCHAR2(1)     := 'N';
    l_inlist                 VARCHAR2 (300);
    l_inlist_bmap            NUMBER           := 0;
    l_total_col_names        VARCHAR2 (10000);
    l_viewby_rank_where      VARCHAR2 (10000);
    l_in_join_tables         VARCHAR2 (1000) := '';
    l_filter_where           VARCHAR2 (1000);
    l_join_tables	     VARCHAR2 (10000);
    l_col_calc_tbl	     poa_dbi_util_pkg.poa_dbi_col_calc_tbl;

  BEGIN

    IF (p_use_grpid = 'Y')
    THEN
      l_grpid_clause    := 'and fact.grp_id = decode(cal.period_type_id,1,14,16,13,32,11,64,7)';
    ELSIF (p_use_grpid = 'R')
    THEN
      	l_grpid_clause    := 'and fact.grp_id = decode(cal.period_type_id,1,0,16,1,32,3,64,7)';
    END IF;
   l_group_and_sel_clause    := get_group_and_sel_clause(p_join_tables, p_use_alias => 'Y');

    IF(p_in_join_tables is not null) then

      FOR i in 1 .. p_in_join_tables.COUNT
      LOOP
        l_in_join_tables := l_in_join_tables || ', ' ||  p_in_join_tables(i).table_name || ' ' || p_in_join_tables(i).table_alias;
      END LOOP;
    END IF;

    get_status_col_calc(  p_col_name
			, l_col_calc_tbl
			, l_inlist_bmap
			, l_compute_prior
			, l_compute_prev_prev
			, l_compute_opening_bal);

    l_col_names := '';

    FOR i IN 1 .. l_col_calc_tbl.COUNT
    LOOP
	l_col_names := l_col_names
		|| ', '
		|| l_col_calc_tbl(i).calc_begin
		|| l_col_calc_tbl(i).date_decode_begin
		|| l_col_calc_tbl(i).column_name
		|| l_col_calc_tbl(i).date_decode_end
		|| l_col_calc_tbl(i).calc_end
		|| ' '
		|| l_col_calc_tbl(i).alias_begin
		|| l_col_calc_tbl(i).alias_end
		|| fnd_global.newline;
    END LOOP;


    -- 0 (0 0 0) = neither XTD or XED
    -- 1 (0 0 1) = XED
    -- 2 (0 1 0) = XTD
    -- 3 (0 1 1) = both XTD and XED
    -- 4 (1 0 0) = YTD
    -- 5 (1 0 1) = YTD and XED
    -- 6 (1 1 0) = YTD and XTD)
    -- 7 (1 1 1) = YTD and XTD and XED

    l_inlist                  :=
          '('
       || CASE
            WHEN -- if one or more columns had XED
                 BITAND (l_inlist_bmap
                       , g_inlist_xed) = g_inlist_xed
              THEN -- alway append current
                       g_c_period_end_date
                    || CASE -- append prev date if needed
                         WHEN l_compute_prior = 'Y'
                           THEN ',' || g_p_period_end_date
                       END
          END
       || CASE -- when XED and (XTD or YTD) exist
            WHEN l_inlist_bmap IN (3, 5, 7)
              THEN ','
          END
       || CASE -- if one or more columns had XTD
            WHEN (   BITAND (l_inlist_bmap
                           , g_inlist_xtd) = g_inlist_xtd
                  OR BITAND (l_inlist_bmap
                           , g_inlist_ytd) = g_inlist_ytd)
              THEN -- alway append current
                       g_c_as_of_date
                    || CASE -- append prev date if needed
                         WHEN l_compute_prior = 'Y'
                           THEN ',' || g_p_as_of_date
                       END
          END
       || case
            when bitand(l_inlist_bmap, g_inlist_rlx) = g_inlist_rlx then
              g_c_period_end_date
              || case -- append prev date if needed
                   when l_compute_prior = 'Y' then
                     ',' || g_p_period_end_date
                   end
          end
       || case
            when bitand(l_inlist_bmap, g_inlist_bal) = g_inlist_bal then
              g_c_as_of_date_balance
              || case -- append prev date if needed
                   when l_compute_prior = 'Y' then
                     ',' || g_p_as_of_date_balance
                   end
              || case
                   when l_compute_opening_bal = 'Y' then
                     ',' || g_c_as_of_date_o_balance
                   end
          end
       || CASE
            WHEN l_compute_prev_prev = 'Y'
              THEN ', &PREV_PREV_DATE'
          END
       || ')';


    IF p_filter_where is not null
    THEN
   l_filter_where := ' where ' || p_filter_where;
    END IF;

   -- Determine how many closing parens we need
    l_paren_str := get_paren_str(p_paren_count,
		l_filter_where);


    if( bitand(l_inlist_bmap, g_inlist_rlx) = g_inlist_rlx) then
	l_join_tables := ', fii_time_structures cal '|| l_in_join_tables;
	l_full_where_clause := ' where fact.time_id = cal.time_id '
			|| 'and fact.period_type_id = cal.period_type_id '
			|| fnd_global.newline
			|| p_where_clause
			|| fnd_global.newline
       			|| 'and cal.report_date in '
    			|| l_inlist
	            -- &RLX_NESTED_PATTERN should be replaced with some
		    -- &BIS bind substitution when available from fii/bis team.
       			|| fnd_global.newline
			|| 'and bitand(cal.record_type_id, &RLX_NESTED_PATTERN) = '
			|| '&RLX_NESTED_PATTERN ';
    elsif( bitand(l_inlist_bmap, g_inlist_bal) = g_inlist_bal) then
	l_join_tables := '';
	l_full_where_clause := ' where fact.report_date in '
				|| l_inlist
       				|| p_where_clause;
   elsif( l_inlist_bmap = 0) then  --for status sqls with no as-of date or compare to
	l_join_tables := l_in_join_tables;
	if(p_where_clause is not null) then
		l_full_where_clause := ' where ' || p_where_clause;
	end if;
   else
	l_join_tables := ', fii_time_rpt_struct_v cal'
			|| fnd_global.newline
			|| l_in_join_tables;
	l_full_where_clause :=' where fact.time_id = cal.time_id '
       			|| p_where_clause
       			|| fnd_global.newline
			|| ' and cal.report_date in '
       			|| l_inlist
       			|| fnd_global.newline
			|| ' and bitand(cal.record_type_id, '
       			|| CASE -- if one or more columns = YTD then use nested pattern
            		WHEN BITAND (l_inlist_bmap, g_inlist_ytd) = g_inlist_ytd
              		THEN '&YTD_NESTED_PATTERN'
            		ELSE '&BIS_NESTED_PATTERN'
         		END
       			|| ') = cal.record_type_id ';
    end if;
      l_query := '(select '
        || l_group_and_sel_clause
        || l_col_names
        || fnd_global.newline||' from '
        || p_fact_name
        || ' fact'
        || l_join_tables
        || l_full_where_clause
        || l_grpid_clause
        || fnd_global.newline||' group by '
        || l_group_and_sel_clause
        || l_paren_str;



  IF(p_generate_viewby = 'Y')
  THEN
    l_viewby_rank_where :='';

    if(p_use_windowing <> 'P') then
	l_viewby_rank_where := l_viewby_rank_where ||
		',' || fnd_global.newline;
    end if;
    l_viewby_rank_where := l_viewby_rank_where ||
       get_viewby_rank_clause (
          p_join_tables       => p_join_tables
        , p_use_windowing     => p_use_windowing);
  END IF;

    l_query := l_query || l_viewby_rank_where;

    RETURN l_query;
  END status_sql;

FUNCTION get_group_and_sel_clause(
	p_join_tables IN poa_dbi_util_pkg.poa_dbi_join_tbl
	, p_use_alias IN VARCHAR2
) RETURN VARCHAR2
IS
   l_group_and_sel_clause    	VARCHAR2 (500);
   l_alias			VARCHAR2 (200);
BEGIN
    l_alias := '';
    if(p_use_alias = 'Y') then
	if(p_join_tables(1).inner_alias is not null) then
	    l_alias := p_join_tables(1).inner_alias || '.';
	else
	    l_alias   := 'fact.';
	end if;
    end if;

    l_group_and_sel_clause    := ' ' || l_alias || p_join_tables (1).fact_column;


    FOR i IN 2 .. p_join_tables.COUNT
    LOOP

       l_alias := '';
       if(p_use_alias = 'Y') then
	   if(p_join_tables(i).inner_alias is not null) then
	       l_alias := p_join_tables(i).inner_alias || '.';
	   else
	       l_alias   := 'fact.';
	   end if;
       end if;

 	l_group_and_sel_clause := l_group_and_sel_clause
				||', ' || l_alias
				|| p_join_tables(i).fact_column;
    END LOOP;

    return l_group_and_sel_clause;
END get_group_and_sel_clause;


PROCEDURE get_status_col_calc(
			  p_col_names IN poa_dbi_util_pkg.poa_dbi_col_tbl
			, x_col_calc_tbl OUT NOCOPY poa_dbi_util_pkg.poa_dbi_col_calc_tbl
			, x_inlist_bmap OUT NOCOPY NUMBER
			, x_compute_prior OUT NOCOPY VARCHAR2
			, x_compute_prev_prev OUT NOCOPY VARCHAR2
			, x_compute_opening_bal OUT NOCOPY VARCHAR2) IS

    l_col_calc 			poa_dbi_util_pkg.poa_dbi_col_calc_rec;
    l_date_decode_begin     	VARCHAR2 (1000);
    l_date_decode_end		VARCHAR2(1000);
    l_cur_date_clause 		VARCHAR2(500);
    l_prev_date_clause		VARCHAR2(500);
    l_o_bal_date_clause 	VARCHAR2(200);
    l_prev_prev_date_clause	VARCHAR2(200);
BEGIN
   x_col_calc_tbl := poa_dbi_util_pkg.POA_DBI_COL_CALC_TBL();

   x_inlist_bmap :=0;

    FOR i IN 1 .. p_col_names.COUNT
    LOOP
      IF p_col_names(i).to_date_type = 'XED'
      THEN
        l_cur_date_clause   := g_c_period_end_date || ',';
        l_prev_date_clause    := g_p_period_end_date || ',';
        x_inlist_bmap        := poa_dbi_util_pkg.bitor (x_inlist_bmap
                                                      , g_inlist_xed);
      ELSIF p_col_names(i).to_date_type in ('XTD','YTD') then
        l_cur_date_clause    := g_c_as_of_date || ',';
        l_prev_date_clause    := g_p_as_of_date || ',';
	l_prev_prev_date_clause := g_pp_date || ',';
	l_o_bal_date_clause := g_c_as_of_date_o_balance || ',';

        IF p_col_names(i).to_date_type = 'XTD'
        THEN
          x_inlist_bmap    := poa_dbi_util_pkg.bitor (x_inlist_bmap
                                                    , g_inlist_xtd);
        ELSE -- YTD
          x_inlist_bmap    := poa_dbi_util_pkg.bitor (x_inlist_bmap
                                                    , g_inlist_ytd);
        END IF;
      elsif p_col_names(i).to_date_type = 'RLX' then
        l_cur_date_clause   := g_c_period_end_date || ',';
        l_prev_date_clause   := g_p_period_end_date || ',';
        x_inlist_bmap    := poa_dbi_util_pkg.bitor (x_inlist_bmap
                                                   , g_inlist_rlx);
      elsif p_col_names(i).to_date_type = 'BAL' then
        l_cur_date_clause    := g_c_as_of_date_balance || ',';
        l_prev_date_clause    := g_p_as_of_date_balance || ',';
	l_o_bal_date_clause := g_c_as_of_date_o_balance || ',';
        x_inlist_bmap    := poa_dbi_util_pkg.bitor (x_inlist_bmap
                                                   , g_inlist_bal);
      elsif p_col_names(i).to_date_type = 'NA' then
       	  l_cur_date_clause    := '';
          l_prev_date_clause    := '';
      END IF;

	if (bitand(x_inlist_bmap, g_inlist_bal) = g_inlist_bal) then
		l_date_decode_begin := 'decode(fact.report_date, ';
		l_date_decode_end := ', null)';
	elsif (x_inlist_bmap = 0) then -- for query with no as-of date or perio
		l_date_decode_begin := '';
		l_date_decode_end := '';
	else
		l_date_decode_begin := 'decode(cal.report_date, ';
		l_date_decode_end := ', null)';
	end if;

      -- Regular current column
	l_col_calc.column_name := p_col_names(i).column_name;
	l_col_calc.alias_begin := 'c_' || p_col_names(i).column_alias;
	l_col_calc.alias_end := '';
	l_col_calc.calc_begin := 'sum(';
	l_col_calc.calc_end := ')';
	l_col_calc.date_decode_begin := l_date_decode_begin || l_cur_date_clause;
	l_col_calc.date_decode_end := l_date_decode_end;
	x_col_calc_tbl.extend();
	x_col_calc_tbl(x_col_calc_tbl.count) := l_col_calc;

      -- Prev column (based on prior_code)
      IF (p_col_names(i).prior_code <> poa_dbi_util_pkg.no_priors)
      THEN
        x_compute_prior    := 'Y';
	l_col_calc.column_name := p_col_names(i).column_name;
	l_col_calc.alias_begin := 'p_' || p_col_names(i).column_alias;
	l_col_calc.alias_end := '';
	l_col_calc.calc_begin := 'sum(';
	l_col_calc.calc_end := ')';
	l_col_calc.date_decode_begin := l_date_decode_begin || l_prev_date_clause;
	l_col_calc.date_decode_end := l_date_decode_end;

	x_col_calc_tbl.extend();
	x_col_calc_tbl(x_col_calc_tbl.count) := l_col_calc;

      END IF;

      -- Prev Prev column
      IF (p_col_names(i).prior_code = poa_dbi_util_pkg.prev_prev)
      THEN
        x_compute_prev_prev    := 'Y';
	l_col_calc.column_name := p_col_names(i).column_name;
	l_col_calc.alias_begin := 'p2_' || p_col_names(i).column_alias;
	l_col_calc.alias_end := '';
	l_col_calc.calc_begin := 'sum(';
	l_col_calc.calc_end := ')';
	l_col_calc.date_decode_begin := l_date_decode_begin
					  || l_prev_prev_date_clause;
	l_col_calc.date_decode_end := l_date_decode_end;

	x_col_calc_tbl.extend();
	x_col_calc_tbl(x_col_calc_tbl.count) := l_col_calc;

      END IF;
      -- Opening Balance Column
      if p_col_names(i).prior_code = poa_dbi_util_pkg.OPENING_PRIOR_CURR then
        x_compute_opening_bal := 'Y';
	l_col_calc.column_name := p_col_names(i).column_name;
	l_col_calc.alias_begin := 'o_' || p_col_names(i).column_alias;
	l_col_calc.alias_end := '';
	l_col_calc.calc_begin := 'sum(';
	l_col_calc.calc_end := ')';
	l_col_calc.date_decode_begin := l_date_decode_begin || l_o_bal_date_clause;
	l_col_calc.date_decode_end := l_date_decode_end;

	x_col_calc_tbl.extend();
	x_col_calc_tbl(x_col_calc_tbl.count) := l_col_calc;

      end if;
      -- If grand total is flagged, do current and prior grand totals
      IF (p_col_names(i).grand_total = 'Y')
      THEN
        -- grand total of current column
	l_col_calc.column_name := p_col_names(i).column_name;
	l_col_calc.alias_begin := 'c_' || p_col_names(i).column_alias;
	l_col_calc.alias_end := '_total';
	l_col_calc.calc_begin := 'sum(sum(';
	l_col_calc.calc_end := ')) over()';
	l_col_calc.date_decode_begin := l_date_decode_begin || l_cur_date_clause;
	l_col_calc.date_decode_end := l_date_decode_end;

	x_col_calc_tbl.extend();
	x_col_calc_tbl(x_col_calc_tbl.count) := l_col_calc;


        -- grand total of prev column (based on prior_code flagging)
        IF (   p_col_names(i).prior_code = poa_dbi_util_pkg.both_priors
            OR p_col_names(i).prior_code = poa_dbi_util_pkg.prev_prev
            OR p_col_names(i).prior_code = poa_dbi_util_pkg.OPENING_PRIOR_CURR )
        THEN
	   l_col_calc.column_name := p_col_names(i).column_name;
	   l_col_calc.alias_begin := 'p_' || p_col_names(i).column_alias;
	   l_col_calc.alias_end := '_total';
	   l_col_calc.calc_begin := 'sum(sum(';
	   l_col_calc.calc_end := ')) over()';
	   l_col_calc.date_decode_begin := l_date_decode_begin || l_prev_date_clause;
	   l_col_calc.date_decode_end := l_date_decode_end;

	   x_col_calc_tbl.extend();
	   x_col_calc_tbl(x_col_calc_tbl.count) := l_col_calc;

        END IF;

	-- grand total of prev prev col (based on prior_code)
        IF (p_col_names(i).prior_code = poa_dbi_util_pkg.prev_prev)
        THEN
	   l_col_calc.column_name := p_col_names(i).column_name;
	   l_col_calc.alias_begin := 'p2_' || p_col_names(i).column_alias;
	   l_col_calc.alias_end := '_total';
	   l_col_calc.calc_begin := 'sum(sum(';
	   l_col_calc.calc_end := ')) over()';
	   l_col_calc.date_decode_begin := l_date_decode_begin || l_prev_prev_date_clause;
	   l_col_calc.date_decode_end := l_date_decode_end;

	   x_col_calc_tbl.extend();
	   x_col_calc_tbl(x_col_calc_tbl.count) := l_col_calc;

        END IF;

      -- grand total Opening Balance Column
        IF (p_col_names(i).prior_code = poa_dbi_util_pkg.OPENING_PRIOR_CURR) then
	   l_col_calc.column_name := p_col_names(i).column_name;
	   l_col_calc.alias_begin := 'o_' || p_col_names(i).column_alias;
	   l_col_calc.alias_end := '_total';
	   l_col_calc.calc_begin := 'sum(sum(';
	   l_col_calc.calc_end := ')) over()';
	   l_col_calc.date_decode_begin := l_date_decode_begin || l_o_bal_date_clause;
	   l_col_calc.date_decode_end := l_date_decode_end;

	   x_col_calc_tbl.extend();
	   x_col_calc_tbl(x_col_calc_tbl.count) := l_col_calc;
       END IF;
      END IF;
   END LOOP;

END get_status_col_calc;


FUNCTION union_all_trend_sql(
    p_mv                     IN poa_dbi_util_pkg.poa_dbi_mv_tbl
  , p_comparison_type        IN VARCHAR2
  , p_filter_where           IN VARCHAR2 := NULL
  , p_diff_measures          in varchar2 := 'Y')
    RETURN VARCHAR2
IS
  l_inlist_bmap     NUMBER;
  l_col_list        poa_dbi_util_pkg.poa_dbi_col_list;
  l_col_names       VARCHAR2(10000);
  l_inner_col_names VARCHAR2(10000);
  l_union_sel       VARCHAR2(10000);
  l_query           VARCHAR2(30000);
  l_compute_opening_bal VARCHAR2(10);
  l_query_rec       poa_dbi_util_pkg.poa_dbi_union_query_rec;
  l_query_tbl       poa_dbi_util_pkg.poa_dbi_union_query_tbl;
  l_called_by_union VARCHAR2(1) ;
BEGIN
  l_called_by_union := 'Y' ;
  l_query_tbl := poa_dbi_util_pkg.poa_dbi_union_query_tbl();
  for m in 1 .. p_mv.count loop
    l_query_tbl.extend;
    l_query_tbl(l_query_tbl.count).in_union_sel := 'cal.name cal_name'
            || fnd_global.newline
            || ', cal.start_date cal_start_date'
            || fnd_global.newline;
  end loop;

   l_union_sel    :=    'cal_name'
            || fnd_global.newline
            || ', cal_start_date'
            || fnd_global.newline;


  for i in 1 ..p_mv.count loop -- main loop
    l_query_tbl(i).template_sql :=
            trend_sql (   p_mv(i).mv_xtd
                  , p_comparison_type
                  , p_mv(i).mv_name
                  , p_mv(i).mv_where
                  , p_mv(i).mv_col
                  , p_mv(i).use_grp_id
                  , p_mv(i).in_join_tbls
                  , p_mv(i).mv_hint
                  , p_called_by_union => l_called_by_union );

    l_col_list := poa_dbi_util_pkg.poa_dbi_col_list();

    get_trend_col_clauses(p_mv(i).mv_col
                , p_mv(i).mv_xtd
                , l_inlist_bmap
                , l_col_names
                , l_inner_col_names
                , l_compute_opening_bal
                , l_col_list);

    if(p_diff_measures = 'Y') then
      for j in 1 .. l_col_list.count loop
        for k in 1 .. p_mv.count loop
          if(k=i) then
            l_query_tbl(k).in_union_sel :=
            l_query_tbl(k).in_union_sel
            || ', '
            || l_col_list(j)
            || fnd_global.newline;
          else
            l_query_tbl(k).in_union_sel :=
              l_query_tbl(k).in_union_sel
              || ', 0 '
              || l_col_list(j)
              || fnd_global.newline;
          end if;
        end loop; -- k loop
        l_union_sel    :=     l_union_sel
                  || ', sum('
                  || l_col_list(j)
                  || ') '
                  || l_col_list(j)
                  || fnd_global.newline;
      end loop; -- j loop
    else
      for j in 1 .. l_col_list.count loop
        l_query_tbl(i).in_union_sel :=
        l_query_tbl(i).in_union_sel
        || ', '
        || l_col_list(j)
        || fnd_global.newline;
        if(i=1) then /*outer select clause needs to be built only once */
          l_union_sel    :=     l_union_sel
                    || ', sum('
                    || l_col_list(j)
                    || ') '
                    || l_col_list(j)
                    || fnd_global.newline;
        end if;
      end loop;
    end if;
  end loop ; -- i loop

 ---Begin Changes for spend trend graph
  l_query :=   case when p_mv(1).mv_xtd like 'RL%' then
                    poa_dbi_util_pkg.get_rolling_inline_view || ' select'         || fnd_global.newline
               else ' ( select'         || fnd_global.newline  end
 ---End Changes for spend trend graph
        ||  l_union_sel
        || 'from ('        || fnd_global.newline;

  FOR m IN 1 .. l_query_tbl.COUNT LOOP
    l_query := l_query
        || '(select'        || fnd_global.newline
        || l_query_tbl(m).in_union_sel
        || 'from '        || fnd_global.newline
        || replace(l_query_tbl(m).template_sql,'order by cal.start_date','')
        || fnd_global.newline;
    IF(m <> l_query_tbl.COUNT) THEN
        l_query := l_query || ') UNION ALL ' || fnd_global.newline;
    END IF;
  END LOOP;

  l_query := l_query
        || ')) group by cal_name, cal_start_date '
        || fnd_global.newline
        || ') uset '        || fnd_global.newline
        || 'order by cal_start_date'    || fnd_global.newline;

  return l_query;
END union_all_trend_sql;


function union_all_status_sql(
    p_mv                     in poa_dbi_util_pkg.poa_dbi_mv_tbl
  , p_join_tables            in poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing          in varchar2
  , p_paren_count            in number := 3
  , p_filter_where           in varchar2 := null
  , p_generate_viewby        in varchar2 := 'Y'
  , p_diff_measures          in varchar2 := 'Y'
)
return varchar2
is
  l_mv                   poa_dbi_util_pkg.poa_dbi_mv_tbl;
  l_col_calc             poa_dbi_util_pkg.poa_dbi_col_calc_tbl;
  l_inlist_bmap          number;
  l_compute_prior        varchar2(1);
  l_compute_prev_prev    varchar2(1);
  l_compute_opening_bal  varchar2(1);
  l_query_rec            poa_dbi_util_pkg.poa_dbi_union_query_rec;
  l_query_tbl            poa_dbi_util_pkg.poa_dbi_union_query_tbl;
  l_out_union_sel        varchar2(2000) := '';
  l_query                varchar2(20000) := '';
  l_sel_clause           varchar2(2000) := '';
  l_filter_where         varchar2(2000) := '';
  l_col_name             poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tables          poa_dbi_util_pkg.poa_dbi_join_tbl;
begin

  l_join_tables := poa_dbi_util_pkg.poa_dbi_join_tbl();
  l_query_tbl := poa_dbi_util_pkg.poa_dbi_union_query_tbl();

  for m in 1 .. p_mv.count loop
    l_query_tbl.extend;
    l_query_tbl(l_query_tbl.count).in_union_sel := '';
  end loop;

  for i in 1 ..p_mv.count loop -- main loop
    l_col_name := poa_dbi_util_pkg.poa_dbi_col_tbl();

    get_status_col_calc(p_mv(i).mv_col
            , l_col_calc
            , l_inlist_bmap
            , l_compute_prior
            , l_compute_prev_prev
            , l_compute_opening_bal);

    for j in 1 .. p_mv(i).mv_col.count loop  -- loop 1
      l_col_name.extend;
      l_col_name(l_col_name.count) := p_mv(i).mv_col(j);
      l_col_name(l_col_name.count).grand_total := 'N';
    end loop;  -- loop 1

    l_query_tbl(i).template_sql := status_sql(p_mv(i).mv_name
                , p_mv(i).mv_where
                , p_join_tables
                , 'N'
                , l_col_name
                , p_mv(i).use_grp_id
                , 3
                , p_filter_where => NULL
                , p_generate_viewby => 'N'
                , p_in_join_tables => p_mv(i).in_join_tbls);

    if(p_diff_measures = 'Y') then
      for k in 1 .. l_col_calc.count loop -- loop 2
        if(l_col_calc(k).alias_end = '_total') then
          null;
        else
          for l in 1 .. p_mv.count loop -- loop 3
            if ( l = i ) then -- compares the index to find out the current MV in main loop
              -- measure needs to be put down
              l_query_tbl(l).in_union_sel := l_query_tbl(l).in_union_sel
                || ', '
                || l_col_calc(k).alias_begin
                || fnd_global.newline;
            else -- measure needs to be forced to 0
              l_query_tbl(l).in_union_sel := l_query_tbl(l).in_union_sel
                || ', 0 '
                || l_col_calc(k).alias_begin
                || fnd_global.newline;
            end if;
          end loop; -- loop 3
        end if;

        l_out_union_sel := l_out_union_sel
          || ', '
          || l_col_calc(k).calc_begin
          || l_col_calc(k).alias_begin
          || l_col_calc(k).calc_end
          || ' '
          || l_col_calc(k).alias_begin
          || l_col_calc(k).alias_end
          || fnd_global.newline;

      end loop; -- loop 2
    else
      for k in 1 .. l_col_calc.count loop
        if(l_col_calc(k).alias_end = '_total') then
          null;
        else
          l_query_tbl(i).in_union_sel := l_query_tbl(i).in_union_sel
            || ', '
            || l_col_calc(k).alias_begin
            || fnd_global.newline;
        end if;

        if(i = 1) then
          /*need to calculate outer sel clause only once*/
          l_out_union_sel := l_out_union_sel
            || ', '
            || l_col_calc(k).calc_begin
            || l_col_calc(k).alias_begin
            || l_col_calc(k).calc_end
            || ' '
            || l_col_calc(k).alias_begin
            || l_col_calc(k).alias_end
            || fnd_global.newline;
        end if;
      end loop;
    end if;
  end loop; -- main loop

  l_sel_clause := get_group_and_sel_clause(p_join_tables, p_use_alias => 'N');

  if (p_filter_where is not null) then
    l_filter_where := ' where ' || p_filter_where;
  end if;

  l_query := 'select '
    || l_sel_clause
    || fnd_global.newline
    || l_out_union_sel
    || 'from ('         || fnd_global.newline;

  for m in 1 .. l_query_tbl.count loop
    l_query := l_query || 'select '
      || l_sel_clause      || fnd_global.newline
      || l_query_tbl(m).in_union_sel
      || 'from '          || fnd_global.newline
      || '(('
      || l_query_tbl(m).template_sql;

    if(m <> l_query_tbl.count) then
      l_query := l_query || ' UNION ALL '      || fnd_global.newline;
    end if;
  end loop;

  l_query := l_query
    || ') group by '
    || l_sel_clause        || fnd_global.newline
    || get_paren_str(p_paren_count, l_filter_where);

  if(p_generate_viewby = 'Y') then
    if(p_use_windowing <> 'P') then
       l_query := l_query ||
        ',' || fnd_global.newline;
    end if;
    l_query := l_query ||
    get_viewby_rank_clause (
          p_join_tables       => p_join_tables
        , p_use_windowing     => p_use_windowing);
  end if;

  return l_query;

end union_all_status_sql;


FUNCTION trend_sql (
    p_xtd                       IN       VARCHAR2
  , p_comparison_type           IN       VARCHAR2
  , p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                 IN       VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_in_join_tbl := NULL
  , p_fact_hint 		IN	 VARCHAR2 := null
  , p_called_by_union           IN       VARCHAR2 := 'N')
    RETURN VARCHAR2
  IS
    l_query               VARCHAR2 (10000);
    l_col_names           VARCHAR2 (4000);
    l_inner_col_names     VARCHAR2 (4000);
    l_col_alias           VARCHAR2 (4000);
    l_total_col_alias     VARCHAR2 (4000);
    l_view_by             VARCHAR2 (120);
    l_cal_clause          VARCHAR2 (1000);
    l_time_clause         VARCHAR2 (400);
    l_grpid_clause        VARCHAR2 (200);
    l_c_report_date_str   VARCHAR2 (1000);
    l_p_report_date_str   VARCHAR2 (1000);
    l_inlist_bmap         NUMBER           := 0;
    l_in_join_tables         VARCHAR2 (1000) := '';
    l_compute_opening_bal varchar2(1)     := 'N';
    l_outer_time_clause         VARCHAR2 (400);
    l_col_list		poa_dbi_util_pkg.poa_dbi_col_list;
  BEGIN

    IF(p_in_join_tables is not null) then

      FOR i in 1 .. p_in_join_tables.COUNT
      LOOP
        l_in_join_tables := l_in_join_tables || ' , ' ||  p_in_join_tables(i).table_name || ' ' || p_in_join_tables(i).table_alias;
      END LOOP;
    END IF;

	get_trend_col_clauses(p_col_name
				, p_xtd
  				, l_inlist_bmap
				, l_col_names
				, l_inner_col_names
				, l_compute_opening_bal
				, l_col_list /*not used by trend_sql*/);


    IF (    p_xtd IN ( 'WTD','DAY')
        AND p_comparison_type = 'Y')
    THEN
      l_time_clause    :=
        ' ((cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE) or (cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE)) ';
      l_outer_time_clause    :=
        ' and ((n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE) or (n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE)) ';
    ELSE
      if p_xtd like 'RL%' then
        l_time_clause := '1=1 ';
      else
        l_time_clause    := ' cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE ';
        l_outer_time_clause    := ' and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE ';
      end if;
    END IF;

    IF (    p_comparison_type = 'Y'
        AND p_xtd <> 'YTD')
    THEN
      -- Yearly
      l_cal_clause    :=
        CASE
          WHEN -- (XTD or YTD) only
                    (   BITAND (l_inlist_bmap
                              , g_inlist_xtd) = g_inlist_xtd
                     OR BITAND (l_inlist_bmap
                              , g_inlist_ytd) = g_inlist_ytd)
                AND NOT BITAND (l_inlist_bmap
                              , g_inlist_xed) = g_inlist_xed
            THEN -- (XTD or YTD) only
                 ' and n.report_date = (case when (cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE)
                                             then least(cal.end_date, &BIS_PREVIOUS_ASOF_DATE)
                                             else least(cal.end_date, &BIS_CURRENT_ASOF_DATE) end) '
          WHEN -- (XTD or YTD) and XED
                    (   BITAND (l_inlist_bmap
                              , g_inlist_xtd) = g_inlist_xtd
                     OR BITAND (l_inlist_bmap
                              , g_inlist_ytd) = g_inlist_ytd)
                AND BITAND (l_inlist_bmap
                          , g_inlist_xed) = g_inlist_xed
            THEN -- (XTD or YTD) and XED
                 ' and n.report_date in ( (case when (cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE)
                                               then least(cal.end_date, &BIS_PREVIOUS_ASOF_DATE)
                                               else least(cal.end_date, &BIS_CURRENT_ASOF_DATE) end)
                                        , &BIS_CURRENT_EFFECTIVE_END_DATE
                                        , &BIS_PREVIOUS_EFFECTIVE_END_DATE) '
          WHEN -- XED only
                    NOT (   BITAND (l_inlist_bmap
                                  , g_inlist_xtd) = g_inlist_xtd
                         OR BITAND (l_inlist_bmap
                                  , g_inlist_ytd) = g_inlist_ytd)
                AND BITAND (l_inlist_bmap
                          , g_inlist_xed) = g_inlist_xed
            THEN -- placeholder for XED only
                 ' and n.report_date = cal.end_date '
          when bitand(l_inlist_bmap,g_inlist_rlx) = g_inlist_rlx then
            ' and n.report_date = cal.report_date '
          when bitand(l_inlist_bmap,g_inlist_bal) = g_inlist_bal then
            ' '
        END;
    ELSE
      -- Sequential comparison type
      l_cal_clause    :=
        CASE
          WHEN -- (XTD or YTD) only
                    (   BITAND (l_inlist_bmap
                              , g_inlist_xtd) = g_inlist_xtd
                     OR BITAND (l_inlist_bmap
                              , g_inlist_ytd) = g_inlist_ytd)
                AND NOT BITAND (l_inlist_bmap
                              , g_inlist_xed) = g_inlist_xed
            THEN -- (XTD or YTD) only
                 ' and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE) , &BIS_PREVIOUS_ASOF_DATE)
                   and n.report_date between cal.start_date and cal.end_date '
          WHEN -- (XTD or YTD) and XED
                    (   BITAND (l_inlist_bmap
                              , g_inlist_xtd) = g_inlist_xtd
                     OR BITAND (l_inlist_bmap
                              , g_inlist_ytd) = g_inlist_ytd)
                AND BITAND (l_inlist_bmap
                          , g_inlist_xed) = g_inlist_xed
            THEN -- (XTD or YTD) and XED
                 ' and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE) , &BIS_PREVIOUS_ASOF_DATE, &BIS_CURRENT_EFFECTIVE_END_DATE)
                   and n.report_date between cal.start_date and cal.end_date '
          WHEN -- XED only
                    NOT (   BITAND (l_inlist_bmap
                                  , g_inlist_xtd) = g_inlist_xtd
                         OR BITAND (l_inlist_bmap
                                  , g_inlist_ytd) = g_inlist_ytd)
                AND BITAND (l_inlist_bmap
                          , g_inlist_xed) = g_inlist_xed
            THEN -- XED only
                 ' and n.report_date = cal.end_date '
          when bitand(l_inlist_bmap,g_inlist_rlx) = g_inlist_rlx then
            ' and n.report_date = cal.report_date '
          when bitand(l_inlist_bmap,g_inlist_bal) = g_inlist_bal then
            ' '
        END;
    END IF;

    IF (p_use_grpid = 'Y')
    THEN
      l_grpid_clause    := ' and fact.grp_id = decode(n.period_type_id,1,14,16,13,32,11,64,7)';
    ELSIF (p_use_grpid = 'R')
    THEN
      	l_grpid_clause    := 'and fact.grp_id = decode(n.period_type_id,1,0,16,1,32,3,64,7)';
    END IF;

    l_query    :=
       '(select n.start_date'
       || case when p_xtd like 'RL%' then ', n.ordinal ' end
       || '
       ' ||l_col_names || '
       from (select ' || p_fact_hint || ' '
       || case when p_xtd like 'RL%' then 'n.ordinal, ' end
       || 'n.start_date, n.report_date '
       || l_inner_col_names
       || ' from '
       || p_fact_name
       || ' fact,
'
       || case
            when p_xtd like 'RL%' then
              case
                when  (BITAND (l_inlist_bmap
                              , g_inlist_bal) = g_inlist_bal) then
                  '( select /*+ NO_MERGE */ cal.ordinal,cal.start_date, cal.report_date'
                  || ' from ' || poa_dbi_util_pkg.get_calendar_table(p_xtd,'Y',l_compute_opening_bal,p_called_by_union => p_called_by_union )
                  || ' cal
where '
                  || l_time_clause
                  || l_cal_clause
                  || ' ) n
where fact.report_date = least(n.report_date,&LAST_COLLECTION)
'
	      ELSE
                 '( select /*+ NO_MERGE */ cal.ordinal,n.time_id,n.record_type_id,n.period_type_id,n.report_date,cal.start_date,cal.end_date'
                  || ' from ' || poa_dbi_util_pkg.get_calendar_table(p_xtd, p_called_by_union => p_called_by_union)
                  || ' cal, fii_time_structures n
where '
                  || l_time_clause
                  || l_cal_clause
                        -- &RLX_NESTED_PATTERN should be replaced with
                        -- some &BIS bind substitution when available from fii/bis team.
                  || ' and bitand(n.record_type_id,&RLX_NESTED_PATTERN) = &RLX_NESTED_PATTERN ) n'
		 || l_in_join_tables
		 || '
where fact.time_id = n.time_id
and fact.period_type_id = n.period_type_id
'
              end
            else -- non RL%
              ' (select /*+ NO_MERGE */ n.time_id,n.record_type_id, n.period_type_id,n.report_date,cal.start_date,cal.end_date
       from '
              || poa_dbi_util_pkg.get_calendar_table (p_xtd, p_called_by_union => p_called_by_union)
              || ' cal, fii_time_rpt_struct_v n
where '
              || l_time_clause
              || l_cal_clause
              || ' and bitand(n.record_type_id, '
              || CASE -- if one or more columns = YTD then use nested pattern
                   WHEN BITAND (l_inlist_bmap, g_inlist_ytd) = g_inlist_ytd
                     THEN '&YTD_NESTED_PATTERN'
                   ELSE '&BIS_NESTED_PATTERN'
                 END
              || ') = n.record_type_id ) n
        '     || l_in_join_tables || '
where fact.time_id = n.time_id
'
          end
       || l_grpid_clause || '
'      || p_where_clause || '
group by '
       || case when p_xtd like 'RL%' then 'n.ordinal, ' end
       || ' n.start_date, n.report_date) i, '
       || poa_dbi_util_pkg.get_calendar_table(p_xtd,'Y',l_compute_opening_bal, p_called_by_union => p_called_by_union )
       || ' n where i.start_date (+) = n.start_date '
       || l_outer_time_clause
       || case when p_xtd like 'RL%' then 'and i.ordinal(+) = n.ordinal ' end
       || '
       group by '
       || case when p_xtd like 'RL%' then 'n.ordinal, ' end
       || 'n.start_date) iset, '
       || poa_dbi_util_pkg.get_calendar_table (p_xtd,'N','N', p_called_by_union => p_called_by_union )
       || ' cal '
       || '
where cal.start_date between '
       || case
            when p_xtd like 'RL%' then
              poa_dbi_util_pkg.get_report_start_date(p_xtd)
            else
              '&BIS_CURRENT_REPORT_START_DATE'
          end
       || ' and &BIS_CURRENT_ASOF_DATE
and cal.start_date = iset.start_date(+)'
       || case when p_xtd like 'RL%' then ' and cal.ordinal = iset.ordinal(+)' end
       || 	'
order by cal.start_date';
    RETURN l_query;

  END trend_sql;



PROCEDURE get_trend_col_clauses(
  				p_col_name	  IN  poa_dbi_util_pkg.poa_dbi_col_tbl
				, p_xtd 	  IN VARCHAR2
  				, x_inlist_bmap   OUT NOCOPY NUMBER
				, x_col_names	  OUT NOCOPY VARCHAR2
				, x_inner_col_names  OUT NOCOPY VARCHAR2
				, x_compute_opening_bal OUT NOCOPY VARCHAR2
				, x_col_list	  OUT NOCOPY poa_dbi_util_pkg.poa_dbi_col_list)
IS
    l_c_report_date_str   	VARCHAR2 (1000);
    l_p_report_date_str   	VARCHAR2 (1000);
    l_c_start_date   		VARCHAR2 (1000);
    l_p_start_date   		VARCHAR2 (1000);
    l_c_end_date   		VARCHAR2 (1000);
    l_p_end_date   		VARCHAR2 (1000);
    l_order_by			VARCHAR2 (50);
BEGIN
    x_col_list := poa_dbi_util_pkg.POA_DBI_COL_LIST();
    x_inlist_bmap := 0;
    IF p_col_name.FIRST IS NOT NULL
    THEN
      FOR i IN p_col_name.FIRST .. p_col_name.LAST
      LOOP
        IF p_col_name (i).to_date_type = 'XED'
        THEN
          l_c_report_date_str    := ' n.end_date ';
          l_p_report_date_str    := ' n.end_date ';
	  l_c_start_date 	 := '&BIS_CURRENT_REPORT_START_DATE';
	  l_c_end_date		 := '&BIS_CURRENT_EFFECTIVE_END_DATE';
	  l_p_start_date	 := '&BIS_PREVIOUS_REPORT_START_DATE';
	  l_p_end_date		 := '&BIS_PREVIOUS_EFFECTIVE_END_DATE';
	  l_order_by		 := 'n.start_date';
          x_inlist_bmap          := poa_dbi_util_pkg.bitor (x_inlist_bmap
                                                          , g_inlist_xed);
        elsif p_col_name(i).to_date_type = 'RLX' then
          l_c_report_date_str := ' n.end_date ';
          l_p_report_date_str := ' n.end_date ';
	  l_c_start_date      :=  poa_dbi_util_pkg.get_report_start_date(p_xtd);
	  l_c_end_date	      := '&BIS_CURRENT_EFFECTIVE_END_DATE and n.ordinal in (-1,2)';
	  l_p_start_date	 := poa_dbi_util_pkg.get_report_start_date(p_xtd,'Y');
	  l_p_end_date	      := '&BIS_PREVIOUS_EFFECTIVE_END_DATE and n.ordinal in (-1,1)';
	  l_order_by		 := 'n.ordinal, n.start_date';
          x_inlist_bmap       := poa_dbi_util_pkg.bitor( x_inlist_bmap
                                                       , g_inlist_rlx);
        elsif p_col_name(i).to_date_type = 'BAL' then
          l_c_report_date_str := ' n.end_date ';
          l_p_report_date_str := ' n.end_date ';
	  l_c_start_date      :=  poa_dbi_util_pkg.get_report_start_date(p_xtd);
	  l_c_end_date	      := '&BIS_CURRENT_EFFECTIVE_END_DATE and n.ordinal in (-1,2)';
	  l_p_start_date	 := poa_dbi_util_pkg.get_report_start_date(p_xtd,'Y');
	  l_p_end_date	      := '&BIS_PREVIOUS_EFFECTIVE_END_DATE and n.ordinal in (-1,1)';
	  l_order_by		 := 'n.start_date';
          x_inlist_bmap       := poa_dbi_util_pkg.bitor( x_inlist_bmap
                                                       , g_inlist_bal);
        ELSIF p_col_name(i).to_date_type = 'XTD' THEN
          l_c_report_date_str    := ' LEAST (n.end_date, &BIS_CURRENT_ASOF_DATE) ';
          l_p_report_date_str    := ' LEAST (n.end_date, &BIS_PREVIOUS_ASOF_DATE) ';
	  l_c_start_date 	 := '&BIS_CURRENT_REPORT_START_DATE';
	  l_c_end_date		 := '&BIS_CURRENT_ASOF_DATE';
	  l_p_start_date	 := '&BIS_PREVIOUS_REPORT_START_DATE';
	  l_p_end_date		 := '&BIS_PREVIOUS_ASOF_DATE';
	  l_order_by		 := 'n.start_date';
          x_inlist_bmap    := poa_dbi_util_pkg.bitor (x_inlist_bmap
                                                      , g_inlist_xtd);
        ELSIF p_col_name(i).to_date_type = 'YTD' THEN
          l_c_report_date_str    := ' LEAST (n.end_date, &BIS_CURRENT_ASOF_DATE) ';
          l_p_report_date_str    := ' LEAST (n.end_date, &BIS_PREVIOUS_ASOF_DATE) ';
	  l_c_start_date 	 := '&BIS_CURRENT_REPORT_START_DATE';
	  l_c_end_date		 := '&BIS_CURRENT_ASOF_DATE';
	  l_p_start_date	 := '&BIS_PREVIOUS_REPORT_START_DATE';
	  l_p_end_date		 := '&BIS_PREVIOUS_ASOF_DATE';
	  l_order_by		 := 'n.start_date';
          x_inlist_bmap    := poa_dbi_util_pkg.bitor (x_inlist_bmap
                                                      , g_inlist_ytd);
        END IF;

-- current column
        x_col_names :=
           x_col_names
           || ', sum(case when (n.start_date between '
           || l_c_start_date
	   || ' and '
	   || l_c_end_date
           || ' and i.report_date = '
           || l_c_report_date_str
           || ') then '
           || p_col_name (i).column_alias
           || ' else null end) c_'
           || p_col_name (i).column_alias
           || fnd_global.newline;
        x_inner_col_names :=
           x_inner_col_names
           || ', sum(' || p_col_name(i).column_name || ') ' || p_col_name(i).column_alias;

	x_col_list.extend();
	x_col_list(x_col_list.count) := 'c_' || p_col_name(i).column_alias;

	-- prior column, based on prior code flagging
        IF (p_col_name (i).prior_code <> poa_dbi_util_pkg.no_priors)
        THEN
          x_col_names :=
             x_col_names
             || ', lag(sum(case when (n.start_date between '
             || l_p_start_date
	     || ' and '
	     || l_p_end_date
             || ' and i.report_date = '
             || l_p_report_date_str
             || ' ) then '
             || p_col_name (i).column_alias
             || ' else null end), &LAG'
             || ') over (order by '
             || l_order_by
             || ') p_'
             || p_col_name (i).column_alias
             || '
';

	  x_col_list.extend();
	  x_col_list(x_col_list.count) := 'p_' || p_col_name(i).column_alias;
        END IF;

        -- Opening Balance Column
        if p_col_name(i).prior_code = poa_dbi_util_pkg.OPENING_PRIOR_CURR
          -- and p_col_name(i).to_date_type = 'BAL'
        then
          x_compute_opening_bal := 'Y';
          if( p_col_name(i).to_date_type = 'BAL')
          THEN
          x_col_names :=
                x_col_names
             || ', lag(sum('
             || p_col_name(i).column_alias
             || '), decode(&BIS_TIME_COMPARISON_TYPE,''YEARLY'',&LAG *2,1)) over (order by n.ordinal,n.start_date) o_'
             || p_col_name(i).column_alias
             || '
';
          ELSE
          x_col_names :=
                x_col_names
             || ', lag(sum('
             || p_col_name(i).column_alias
             || '), decode(&BIS_TIME_COMPARISON_TYPE,''YEARLY'',&LAG *2,1)) over (order by n.start_date) o_'
             || p_col_name(i).column_alias
             || '
';
          END IF;

	   x_col_list.extend();
	   x_col_list(x_col_list.count) := 'o_' || p_col_name(i).column_alias;
        end if;

        -- Grand total for current columns
        -- Note: RLX and BAL not supported here
	--UNION ALL queries also do not support grand totals
        IF (p_col_name (i).grand_total = 'Y')
        THEN
          x_col_names    :=
                x_col_names
             || ',
                           sum(sum('
             || p_col_name (i).column_alias
             || ')) over () c_'
             || p_col_name (i).column_alias
             || '_total
';

          -- Grand total for previous columns
          IF (p_col_name (i).prior_code = poa_dbi_util_pkg.both_priors)
          THEN
            x_col_names    :=
                  x_col_names
               || ',
          sum(lag(sum('
               || p_col_name (i).column_alias
               || '))) over () p_'
               || p_col_name (i).column_alias
               || '_total
';
          END IF;
        END IF;

      END LOOP;

    END IF;
END get_trend_col_clauses;



  FUNCTION dtl_status_sql (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                 IN       VARCHAR2 := 'Y'
  , p_paren_count               IN       NUMBER := 3
  , p_group_by                  IN       VARCHAR2
  , p_from_clause               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_from_clause            VARCHAR2 (10000);
    l_where_clause           VARCHAR2 (10000);
    l_group_and_sel_clause   VARCHAR2 (10000);
    l_query                  VARCHAR2 (10000);
    l_col_names              VARCHAR2 (10000);
  BEGIN
    FOR i IN 1 .. p_join_tables.COUNT
    LOOP
      l_group_and_sel_clause    :=
                        l_group_and_sel_clause || CASE
                          WHEN i > 1
                            THEN ', '
                        END || ' fact.' || p_join_tables (i).fact_column;
      l_from_clause             :=
         l_from_clause || CASE
           WHEN i > 1
             THEN ', '
         END || p_join_tables (i).table_name || ' ' || p_join_tables (i).table_alias;
      l_where_clause            :=
            l_where_clause
         || CASE
              WHEN i > 1
                THEN ' and '
            END
         || ' fact.'
         || p_join_tables (i).fact_column
         || '='
         || p_join_tables (i).table_alias
         || '.'
         || p_join_tables (i).column_name;

      IF (p_join_tables (i).dim_outer_join = 'Y')
      THEN
        l_where_clause    := l_where_clause || '(+)';
      END IF;

      IF (p_join_tables (i).additional_where_clause IS NOT NULL)
      THEN
        l_where_clause    := l_where_clause || ' and ' || p_join_tables (i).additional_where_clause;
      END IF;
    END LOOP;

    FOR i IN 1 .. p_col_name.COUNT
    LOOP
      l_col_names    :=
                      l_col_names || ', sum(fact.' || p_col_name (i).column_name || ' ) '
                      || p_col_name (i).column_alias;

      IF (p_col_name (i).grand_total = 'Y')
      THEN
        -- Sum of current column
        l_col_names    :=
              l_col_names
           || ', sum(sum(fact.'
           || p_col_name (i).column_name
           || ')) over () '
           || p_col_name (i).column_alias
           || '_total ';
      END IF;
    END LOOP;

    l_query    :=
          l_col_names
       || p_from_clause
       || l_from_clause
       || ' WHERE '
       || l_where_clause
       || p_where_clause
       || p_group_by
       || ') oset5 ))'
       || ' WHERE (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)'
       || ' ORDER BY rnk';
    RETURN l_query;
  END dtl_status_sql;

  FUNCTION dtl_status_sql2 (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                 IN       VARCHAR2 := 'Y'
  , p_filter_where              IN       VARCHAR2 := NULL
  , p_paren_count               IN       NUMBER := 3
  , p_group_by                  IN       VARCHAR2
  , p_from_clause               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_from_clause            VARCHAR2 (10000);
    l_where_clause           VARCHAR2 (10000);
    l_query                  VARCHAR2 (10000);
    l_col_names              VARCHAR2 (10000);

    l_from_clause1           VARCHAR2 (10000);
    l_where_clause1          VARCHAR2 (10000);

    l_filter_where           VARCHAR2(10000);

  BEGIN
    FOR i IN 1 .. p_join_tables.COUNT
    LOOP
      IF (p_join_tables (i).additional_where_clause IS NOT NULL)
      THEN
            l_from_clause1             :=
               l_from_clause1 || ','|| p_join_tables (i).table_name || ' ' || p_join_tables  (i).table_alias;

             l_where_clause1            :=
                  l_where_clause1
               ||  ' and '
               || ' fact.'
               || p_join_tables (i).fact_column
               || '='
               || p_join_tables (i).table_alias
               || '.'
               || p_join_tables (i).column_name;

            IF (p_join_tables (i).dim_outer_join = 'Y')
            THEN
              l_where_clause1    := l_where_clause1 || '(+)';
            END IF;

            IF (p_join_tables (i).additional_where_clause IS NOT NULL)
            THEN
              l_where_clause1    := l_where_clause1 || ' and ' || p_join_tables  (i).additional_where_clause;
            END IF;
      ELSE
            l_from_clause             :=
               l_from_clause || ', ' || p_join_tables (i).table_name || ' ' || p_join_tables (i).table_alias;
            l_where_clause            :=
                  l_where_clause
               || ' and '
               || ' fact.'
               || p_join_tables (i).fact_column
               || '='
               || p_join_tables (i).table_alias
               || '.'
               || p_join_tables (i).column_name;

            IF (p_join_tables (i).dim_outer_join = 'Y')
            THEN
              l_where_clause    := l_where_clause || '(+)';
            END IF;
      END IF; --  additional_where_clause
    END LOOP;

    FOR i IN 1 .. p_col_name.COUNT
    LOOP
      l_col_names    :=
                      l_col_names || ', sum(fact.' || p_col_name (i).column_name || ' ) '
                      || p_col_name (i).column_alias;

      IF (p_col_name (i).grand_total = 'Y')
      THEN
        -- Sum of current column
        l_col_names    :=
              l_col_names
           || ', sum(sum(fact.'
           || p_col_name (i).column_name
           || ')) over () '
           || p_col_name (i).column_alias
           || '_total ';
      END IF;
    END LOOP;

    IF (p_filter_where IS NOT NULL)
    THEN
       l_filter_where := ' WHERE ' || p_filter_where ;
    END IF;

    l_query    :=
          l_col_names
       || p_from_clause || l_from_clause1
       || ' WHERE 1 = 1'
       || p_where_clause || l_where_clause1
       || p_group_by
       || ') oset5 ) '|| l_filter_where || ' )'
       || ' WHERE (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1) ) fact '
       || l_from_clause
       || ' WHERE 1 = 1'
       || l_where_clause
       || ' ORDER BY rnk';
    RETURN l_query;
  END dtl_status_sql2;


  FUNCTION get_viewby_rank_clause (
    p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2)
    RETURN VARCHAR2 IS
   l_query                  varchar2(10000);
   l_from_clause            VARCHAR2 (10000);
   l_where_clause           VARCHAR2 (10000);
   l_last_from_alias varchar2(30);
   l_rownum_where varchar2(300);
   l_vo_max_fetch_size varchar2(100);
BEGIN
   l_query := '';

   IF(p_use_windowing = 'P') THEN

    /* Determine the l_rownum_where. If VO_MAX_FETCH_SIZE is null then dont filter any rows */
    select fnd_profile.value('VO_MAX_FETCH_SIZE')
    into l_vo_max_fetch_size
    from dual;

    if (l_vo_max_fetch_size is not null) then
      l_rownum_where := ' where rownum < '||l_vo_max_fetch_size||' + 1 ';
    else
      l_rownum_where := ' ';
    end if;

	l_query := l_query ||
	 ' where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1))'
	|| ' oset2 '||l_rownum_where||' ) oset, '
	|| fnd_global.newline;
   END IF;


   l_from_clause             := p_join_tables (1).table_name || ' ' || p_join_tables (1).table_alias;

    l_last_from_alias := p_join_tables(1).table_alias;

    l_where_clause            :=
          'oset.'
       || p_join_tables (1).fact_column
       || CASE WHEN p_join_tables(1).dim_outer_join = 'R' THEN '(+)' END
       || '='
       || p_join_tables (1).table_alias
       || '.'
       || p_join_tables (1).column_name;

    IF (p_join_tables (1).dim_outer_join = 'Y')
    THEN
      l_where_clause    := l_where_clause || '(+)';
    END IF;

    IF (p_join_tables (1).additional_where_clause IS NOT NULL)
    THEN
      l_where_clause    := l_where_clause || ' and ' || p_join_tables (1).additional_where_clause;
    END IF;

    FOR i IN 2 .. p_join_tables.COUNT
    LOOP
	if p_join_tables(i).table_alias <> l_last_from_alias then
	   l_last_from_alias := p_join_tables(i).table_alias;
           l_from_clause             :=
                        l_from_clause
			|| ', '
			|| p_join_tables (i).table_name
			|| ' '
                        || p_join_tables (i).table_alias;
         end if;
      l_where_clause            :=
            l_where_clause
         || ' and oset.'
         || p_join_tables (i).fact_column
	 || CASE WHEN p_join_tables(i).dim_outer_join = 'R' THEN '(+)' END
         || '='
         || p_join_tables (i).table_alias
         || '.'
         || p_join_tables (i).column_name;

      IF (p_join_tables (i).dim_outer_join = 'Y')
      THEN
        l_where_clause    := l_where_clause || '(+)';
      END IF;

      IF (p_join_tables (i).additional_where_clause IS NOT NULL)
      THEN
        l_where_clause    := l_where_clause || ' and ' || p_join_tables (i).additional_where_clause;
      END IF;

    END LOOP;


    l_query := l_query ||
       l_from_clause
       || '
where '
       || l_where_clause;

    IF (p_use_windowing = 'Y')    THEN
      l_query    := l_query || '
and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)';
    END IF;

    IF (p_use_windowing = 'Y' or p_use_windowing = 'P') THEN
	l_query := l_query || fnd_global.newline || 'ORDER BY rnk';
    ELSE
       l_query                   := l_query ||
		fnd_global.newline || '&ORDER_BY_CLAUSE nulls last';
    END IF;

    RETURN l_query;

END;

END poa_dbi_template_pkg;


/
