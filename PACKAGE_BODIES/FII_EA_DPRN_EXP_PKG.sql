--------------------------------------------------------
--  DDL for Package Body FII_EA_DPRN_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_DPRN_EXP_PKG" AS
/* $Header: FIIEAMAJB.pls 120.3 2006/03/20 13:00:23 hpoddar noship $ */

-- ----------------------------------------------------------------------
--
-- GET_DPRN_EXP_MAJ: This procedure is called from Depreciation Expense
--                   by Major Category report. It is the main procedure
--                   that reads the report parameter values, builds the
--                   PMV sql and passes back to the calling PMV report.
--
-- ----------------------------------------------------------------------
PROCEDURE GET_DPRN_EXP_MAJ (p_page_parameter_tbl       IN  BIS_PMV_PAGE_PARAMETER_TBL,
                            get_dprn_exp_maj_sql       OUT NOCOPY VARCHAR2,
                            get_dprn_exp_maj_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) is

  l_trunc_sql                    VARCHAR2(100);
  l_sqlstmt                      VARCHAR2(2000);
  l_sqlstmt2                     VARCHAR2(5000);

  l_company_id                  fii_ea_util_pkg.g_company_id%TYPE;
  l_cost_center_id              fii_ea_util_pkg.g_cost_center_id%TYPE;
  l_fin_category_id             fii_ea_util_pkg.g_fin_category_id%TYPE;
  l_ledger_id                   fii_ea_util_pkg.g_ledger_id%TYPE;
  l_actual_bitand               fii_ea_util_pkg.g_actual_bitand%TYPE;
  l_fud1_id                     fii_ea_util_pkg.g_fud1_id%TYPE;
  l_fud2_id                     fii_ea_util_pkg.g_fud2_id%TYPE;
  l_asof_date                   fii_ea_util_pkg.g_as_of_date%TYPE;
  l_prev_asof_date              fii_ea_util_pkg.g_previous_asof_date%TYPE;
  l_curr                        fii_ea_util_pkg.g_currency%TYPE;

  l_fud1_where                  VARCHAR2(240);
  l_fud2_where                  VARCHAR2(240);
  l_asset_url                   VARCHAR2(240);
  l_minor_url                   VARCHAR2(240);

  l_maj_seg_name                VARCHAR2(30);

  Cursor C1 is select major_seg_name
               from fii_fa_cat_segments;

BEGIN

  -- reset the global variables
  fii_ea_util_pkg.reset_globals;

  -- read the paramaters and populate the global variables
  fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);

  -- copy values to local variables
  l_company_id := fii_ea_util_pkg.g_company_id;
  l_cost_center_id := fii_ea_util_pkg.g_cost_center_id;
  l_fin_category_id := fii_ea_util_pkg.g_fin_category_id;
  l_actual_bitand := fii_ea_util_pkg.g_actual_bitand;
  l_asof_date := fii_ea_util_pkg.g_as_of_date;
  l_prev_asof_date := fii_ea_util_pkg.g_previous_asof_date;
  l_ledger_id := fii_ea_util_pkg.g_ledger_id;
  l_fud1_id := fii_ea_util_pkg.g_fud1_id;
  l_fud2_id := fii_ea_util_pkg.g_fud2_id;

  -- Company Id will always be passed
  -- Cost Center Id will always be passed
  -- Financial Category Id will always be passed
  -- Ledger Id will always be passed

  -- fud1 may be either All or specific
  -- We need to build the where clause this way
  -- instead of calling fii_ea_util_pkg.get_fud1_for_detail
  -- so that it can also be used for the insert SQL below
  if (l_fud1_id IS NOT NULL AND l_fud1_id <> 'All') THEN
    l_fud1_where := ' and f.user_dim1_id = :l_fud1_id';
  else
    l_fud1_where := '';
  end if;

  --fud2 may be either All or specific
  -- We need to build the where clause this way
  -- instead of calling fii_ea_util_pkg.get_fud2_for_detail
  -- so that it can also be used for the insert SQL below
  if (l_fud2_id IS NOT NULL AND l_fud2_id <> 'All') THEN
    l_fud2_where := ' and f.user_dim2_id = :l_fud2_id';
  else
    l_fud2_where := '';
  end if;

  -- get the flex segment column name used for the Major Category segment
  -- This value determines which column is being used in fa_categories to store Major Category
  open C1;
  fetch C1 into l_maj_seg_name;
  close C1;

  -- Cleanup the global temp table.
  -- We need to do this b'cause every time the user picks selects a report parameter
  -- this package is run and will create/insert new rows in the global temp

  l_trunc_sql := 'delete from FII_EA_MAJ_CAT_GT';
  execute immediate l_trunc_sql;


  -- Prepare the stmnt to populate the global temp table
  -- This stamtement will store all major categories and the count of its minor categories
  -- for the passed in parameters. This is needed to determine the drill down report
  l_sqlstmt :=  'Insert into FII_EA_MAJ_CAT_GT( asset_cat_major_id,
                                                minor_count )
               ( select distinct f.asset_cat_major_id,
                        count(f.asset_cat_minor_id)
                 from  fii_fa_exp_mv f,
                       fii_time_structures cal
                 where f.time_id = cal.time_id
                 and   cal.period_type_id = f.period_type_id
                 and cal.report_date in ( :ASOF_DATE, :PREVIOUS_ASOF_DATE)
                 and   bitand(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
                 and   f.ledger_id = :LEDGER_ID
                 and   f.company_id = :COMPANY_ID
                 and   f.cost_center_id = :COST_CENTER_ID
                 and   f.natural_account_id = :FIN_CATEGORY_ID
                 '||l_fud1_where||' '||l_fud2_where||
                 ' group by f.asset_cat_major_id )';

  IF (l_fud2_id IS NOT NULL AND l_fud2_id <> 'All' AND l_fud1_id IS NOT NULL AND l_fud1_id <> 'All') THEN
	EXECUTE IMMEDIATE l_sqlstmt using l_asof_date,l_prev_asof_date,l_actual_bitand,l_actual_bitand,l_ledger_id,l_company_id,l_cost_center_id,l_fin_category_id,l_fud1_id, l_fud2_id;
  ELSIF l_fud1_id IS NOT NULL AND l_fud1_id <> 'All' THEN
	EXECUTE IMMEDIATE l_sqlstmt using l_asof_date,l_prev_asof_date,l_actual_bitand,l_actual_bitand,l_ledger_id,l_company_id,l_cost_center_id,l_fin_category_id,l_fud1_id;
  ELSIF l_fud2_id IS NOT NULL AND l_fud2_id <> 'All' THEN
	EXECUTE IMMEDIATE l_sqlstmt using l_asof_date,l_prev_asof_date,l_actual_bitand,l_actual_bitand,l_ledger_id,l_company_id,l_cost_center_id,l_fin_category_id,l_fud2_id;
  ELSE EXECUTE IMMEDIATE l_sqlstmt using l_asof_date,l_prev_asof_date,l_actual_bitand,l_actual_bitand,l_ledger_id,l_company_id,l_cost_center_id,l_fin_category_id;
  END IF;

  -- reinitialize to use the API whereclause
  l_fud1_where := replace(fii_ea_util_pkg.get_fud1_for_detail, 'fud1_id', 'user_dim1_id');
  l_fud2_where := replace(fii_ea_util_pkg.get_fud2_for_detail, 'fud2_id', 'user_dim2_id');

  l_asset_url := 'pFunctionName=FII_EA_DPRN_EXP_LIST&pParamIds=Y&FII_EA_ASSET_CAT_MAJOR=FII_EA_ASSET_CAT_MAJ_ID';
  l_minor_url := 'pFunctionName=FII_EA_DPRN_EXP_MIN&pParamIds=Y&FII_EA_ASSET_CAT_MAJOR=FII_EA_ASSET_CAT_MAJ_ID';

  -- The following is the main SQL that will be passed back to the PMV report
  -- Note that it joins with the global temp table FII_EA_MAJ_CAT_GT that is populated earlier
  -- Since this report now joins/looks at fa_categories table, we dont have to worry about
  -- what value set type ( table based/dependant/independant ) is being used for the kff setups.
  -- The fa_categories stores the value in the corresponding segment column
  -- that is setup for the major segment valueset

  l_sqlstmt2 := ' select maj.fii_ea_major_cat FII_EA_ASSET_CAT_MAJOR,
                         maj.fii_ea_major_cat_id FII_EA_ASSET_CAT_MAJ_ID,
                         decode(gtemp.minor_count, 0, '''||l_asset_url||''', '''||l_minor_url||''')  FII_EA_ASSET_CAT_MAJOR_DRILL,
                         maj.fii_xtd_amount FII_EA_XTD,
                         maj.fii_xtd_prior_amount FII_EA_PRIOR_XTD,
                         ( ((maj.fii_xtd_amount - maj.fii_xtd_prior_amount ) /
                            DECODE(maj.fii_xtd_prior_amount, 0, to_number(null), maj.fii_xtd_prior_amount)) *100) FII_EA_CHANGE,
                         sum(maj.fii_xtd_amount) over() FII_EA_GT_XTD,
                         sum(maj.fii_xtd_prior_amount) over() FII_EA_GT_PRIOR_XTD,
                         ( ( (sum(maj.fii_xtd_amount) over() - sum(maj.fii_xtd_prior_amount) over()) /
                         decode ( (sum(maj.fii_xtd_prior_amount) over()), 0, to_number(null),
                                  (sum(maj.fii_xtd_prior_amount) over()) )) * 100 ) FII_EA_GT_CHANGE
                  from   ( select f.asset_cat_major_id FII_EA_MAJOR_CAT_ID,
                                  cat.'||l_maj_seg_name||' FII_EA_MAJOR_CAT,
                                  SUM(CASE WHEN cal.report_date = :ASOF_DATE
                                           THEN tot_amount_t ELSE to_number(null) END)  FII_XTD_AMOUNT,
                                  SUM(CASE WHEN cal.report_date = :PREVIOUS_ASOF_DATE
                                           THEN tot_amount_t ELSE to_number(null) END)  FII_XTD_PRIOR_AMOUNT
                           from  fa_categories cat,
                                 fii_fa_exp_mv f,
                                 fii_time_structures cal
                           where f.time_id = cal.time_id
                           and   cal.period_type_id = f.period_type_id
                           and   cal.report_date in (:ASOF_DATE, :PREVIOUS_ASOF_DATE)
                           and   f.asset_cat_id = cat.category_id
                           and   bitand(cal.record_type_id, :ACTUAL_BITAND ) = :ACTUAL_BITAND
                           and   f.company_id = &FII_COMPANIES+FII_COMPANIES
                           and   f.ledger_id = &FII_LEDGER+FII_LEDGER
                           and   f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC
                           and   f.natural_account_id =  &FINANCIAL ITEM+GL_FII_FIN_ITEM '||
                                 l_fud1_where||' '||l_fud2_where||
                           ' group by f.asset_cat_major_id, cat.'||l_maj_seg_name||' ) maj,
                           FII_EA_MAJ_CAT_GT gtemp
                  where   gtemp.asset_cat_major_id = maj.fii_ea_major_cat_id
                  order by maj.fii_xtd_amount DESC ';

  fii_ea_util_pkg.bind_variable(l_sqlstmt2, p_page_parameter_tbl, get_dprn_exp_maj_sql, get_dprn_exp_maj_output);

end GET_DPRN_EXP_MAJ;



PROCEDURE GET_DPRN_EXP_MIN( p_page_parameter_tbl    IN            BIS_PMV_PAGE_PARAMETER_TBL,
                            get_dprn_exp_min_sql       OUT NOCOPY VARCHAR2,
                            get_dprn_exp_min_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) is

  l_sqlstmt                     VARCHAR2(5000);

  l_asset_cat_maj_id            fii_ea_util_pkg.g_maj_cat_id%TYPE;

  l_fud1_where                  VARCHAR2(1000);
  l_fud2_where                  VARCHAR2(1000);
  l_asset_url                   VARCHAR2(240);

  l_min_seg_name                VARCHAR2(30);

  Cursor C1 is select minor_seg_name
               from fii_fa_cat_segments;

BEGIN

  -- reset the global variables
  fii_ea_util_pkg.reset_globals;

  -- read the paramaters and populate the global variables
  fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);

  -- Company Id will always be passed
  -- Cost Center Id will always be passed
  -- Financial Category Id will always be passed
  -- Ledger Id will always be passed
  -- Asset Category Major Id will always be passed

  -- copy values to local variables
  l_asset_cat_maj_id:= fii_ea_util_pkg.g_maj_cat_id;
  l_fud1_where := replace(fii_ea_util_pkg.get_fud1_for_detail, 'fud1_id', 'user_dim1_id');
  l_fud2_where := replace(fii_ea_util_pkg.get_fud2_for_detail, 'fud2_id', 'user_dim2_id');

  -- get the flex segment column name used for the Minor Category segment
  -- This value determines which column is being used in fa_categories to store Minor Category
  open C1;
  fetch C1 into l_min_seg_name;
  close C1;

  l_asset_url := 'pFunctionName=FII_EA_DPRN_EXP_LIST&pParamIds=Y&FII_EA_ASSET_CAT_MINOR=FII_EA_ASSET_CAT_MIN_ID';

  -- The following is the main SQL that will be passed back to the PMV report
  -- Since this report now joins/looks at fa_categories table, we dont have to worry about
  -- what value set type ( table based/dependant/independant ) is being used for the kff setups.
  -- The fa_categories stores the value in the corresponding segment column
  -- that is setup for the major segment valueset

  l_sqlstmt := ' select min.fii_ea_minor_cat FII_EA_ASSET_CAT_MINOR,
                        min.fii_ea_minor_cat_id FII_EA_ASSET_CAT_MIN_ID,
                        '''||l_asset_url||'''  FII_EA_ASSET_CAT_MINOR_DRILL,
                        min.fii_xtd_amount FII_EA_XTD,
                        min.fii_xtd_prior_amount FII_EA_PRIOR_XTD,
                        ( ((min.fii_xtd_amount - min.fii_xtd_prior_amount ) /
                            DECODE(min.fii_xtd_prior_amount, 0, to_number(null),
                                   min.fii_xtd_prior_amount)) *100) FII_EA_CHANGE,
                        sum(min.fii_xtd_amount) over() FII_EA_GT_XTD,
                        sum(min.fii_xtd_prior_amount) over() FII_EA_GT_PRIOR_XTD,
                        (( (sum(min.fii_xtd_amount) over() - sum(min.fii_xtd_prior_amount) over()) /
                          decode ( (sum(min.fii_xtd_prior_amount) over()), 0, to_number(null),
                                  (sum(min.fii_xtd_prior_amount) over()) )) * 100 ) FII_EA_GT_CHANGE
                 from  ( select f.asset_cat_minor_id FII_EA_MINOR_CAT_ID,
                                 cat.'||l_min_seg_name||' FII_EA_MINOR_CAT,
                                 SUM(CASE WHEN cal.report_date = :ASOF_DATE
                                          THEN tot_amount_t ELSE to_number(null) END)   FII_XTD_AMOUNT,
                                 SUM(CASE WHEN cal.report_date = :PREVIOUS_ASOF_DATE
                                          THEN tot_amount_t ELSE to_number(null) END)   FII_XTD_PRIOR_AMOUNT
                          from  fa_categories cat,
                                fii_fa_exp_mv f,
                                fii_time_structures cal
                          where f.time_id = cal.time_id
                          and   cal.period_type_id = f.period_type_id
                          and   cal.report_date in (:ASOF_DATE, :PREVIOUS_ASOF_DATE)
                          and   f.asset_cat_id = cat.category_id
                          and   bitand(cal.record_type_id, :ACTUAL_BITAND ) = :ACTUAL_BITAND
                          and   f.company_id = &FII_COMPANIES+FII_COMPANIES
                          and   f.ledger_id = &FII_LEDGER+FII_LEDGER
                          and   f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC
                          and   f.natural_account_id =  &FINANCIAL ITEM+GL_FII_FIN_ITEM
                          and   f.asset_cat_major_id = &FII_ASSET_CATEGORIES+FII_ASSET_CAT_MAJOR '
                          ||l_fud1_where||' '||l_fud2_where||
                          ' group by f.asset_cat_minor_id, cat.'||l_min_seg_name||' ) min
                  order by min.fii_xtd_amount DESC ';

  fii_ea_util_pkg.bind_variable(l_sqlstmt, p_page_parameter_tbl, get_dprn_exp_min_sql, get_dprn_exp_min_output);

END GET_DPRN_EXP_MIN;



PROCEDURE GET_DPRN_EXP_LIST( p_page_parameter_tbl    IN              BIS_PMV_PAGE_PARAMETER_TBL,
                             get_dprn_exp_list_sql       OUT NOCOPY VARCHAR2,
                             get_dprn_exp_list_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqlstmt                     VARCHAR2(5000);

  l_cat_maj_id                  fii_ea_util_pkg.g_maj_cat_id%TYPE;
  l_cat_min_id                  fii_ea_util_pkg.g_maj_cat_id%TYPE;

  l_fud1_where                  VARCHAR2(240);
  l_fud2_where                  VARCHAR2(240);
  l_cat_min_where               VARCHAR2(100);
  l_asset_url                   VARCHAR2(240);
  l_period_type                 fii_ea_util_pkg.g_page_period_type%TYPE;

BEGIN

   -- reset the global variables
  fii_ea_util_pkg.reset_globals;

  -- read the paramaters and populate the global variables
  fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);

  -- copy values to local variables
  l_cat_maj_id:= fii_ea_util_pkg.g_maj_cat_id;
  l_cat_min_id:= fii_ea_util_pkg.g_min_cat_id;
  l_fud1_where := replace(fii_ea_util_pkg.get_fud1_for_detail, 'fud1_id', 'user_dim1_id');
  l_fud2_where := replace(fii_ea_util_pkg.get_fud2_for_detail, 'fud2_id', 'user_dim2_id');

  -- Min cat may be All or Specific
  if ( l_cat_min_id IS NOT NULL  AND l_cat_min_id <> 'All') then
    l_cat_min_where := 'and f.asset_cat_minor_id = :MIN_CAT_ID';
  else
    l_cat_min_where := '';
  end if;

  l_asset_url := 'pFunctionName=FII_EA_IA_DRILL&AssetId=FII_EA_ASSET_ID&AssetNumber=FII_EA_ASSET_NUM&addBreadCrumb=Y&retainAM=Y';

  l_sqlstmt := ' select av.asset_number     FII_EA_ASSET_NUM,
                        av.asset_id FII_EA_ASSET_ID,
                        '''||l_asset_url||'''  FII_EA_ASSET_DRILL,
                        sum(av.xtd) FII_EA_XTD,
                        sum(av.prior_xtd) FII_EA_PRIOR_XTD,
                        ( ((sum(av.xtd) - sum(av.prior_xtd))/
                           DECODE ( sum(av.prior_xtd), 0, to_number(null), sum(av.prior_xtd))) *100) FII_EA_CHANGE,
                        av.description  FII_EA_ASSET_DESCR,
                         sum(SUM(av.xtd)) over() FII_EA_GT_XTD,
                         sum(SUM(av.prior_xtd)) over() FII_EA_GT_PRIOR_XTD,
                         ( ( sum(SUM(av.xtd)) over() - sum(SUM(av.prior_xtd)) over() )/
                         ( decode( (sum(SUM(av.prior_xtd)) over()), 0, to_number(null),
                                   (sum(SUM(av.prior_xtd)) over() ) )) ) *100 FII_EA_GT_CHANGE
                  from  ( select f.asset_id,
                                 f.asset_number,
                                 a.description,
                                 amount_t xtd,
                                 to_number(null)     prior_xtd
                          from  fa_additions_tl a,
                                fii_fa_exp_f f
                           where f.account_date between :CURR_PERIOD_START AND :ASOF_DATE
                          and   f.asset_id = a.asset_id
                          and   a.language = userenv(''LANG'')
                          and   f.company_id = &FII_COMPANIES+FII_COMPANIES
                          and   f.ledger_id = &FII_LEDGER+FII_LEDGER
                          and   f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC
                          and   f.natural_account_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM
                          and   f.asset_cat_major_id = &FII_ASSET_CATEGORIES+FII_ASSET_CAT_MAJOR '
                          ||l_cat_min_where||' '||l_fud1_where||' '||l_fud2_where||
                          ' UNION ALL
                          select f.asset_id,
                                 f.asset_number,
                                 a.description,
                                 to_number(null),
                                 amount_t
                          from  fa_additions_tl a,
                                fii_fa_exp_f f
                          where f.account_date between :PRIOR_PERIOD_START AND :PRIOR_PERIOD_END
                          and   f.asset_id = a.asset_id
                          and   a.language = userenv(''LANG'')
                          and   f.company_id = &FII_COMPANIES+FII_COMPANIES
                          and   f.ledger_id = &FII_LEDGER+FII_LEDGER
                          and   f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC
                          and   f.natural_account_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM
                          and   f.asset_cat_major_id = &FII_ASSET_CATEGORIES+FII_ASSET_CAT_MAJOR '
                          ||l_cat_min_where||' '||l_fud1_where||' '||l_fud2_where||
                           ' ) av
                  group by av.asset_id,
                           av.asset_number,
                           av.description,
                           '''||l_asset_url||'''
                  order by 4 DESC ';

  fii_ea_util_pkg.bind_variable(l_sqlstmt, p_page_parameter_tbl, get_dprn_exp_list_sql, get_dprn_exp_list_output);

END GET_DPRN_EXP_LIST;


END FII_EA_DPRN_EXP_PKG;

/
