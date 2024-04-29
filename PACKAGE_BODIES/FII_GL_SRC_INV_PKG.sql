--------------------------------------------------------
--  DDL for Package Body FII_GL_SRC_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_SRC_INV_PKG" AS
/* $Header: FIIGLSRB.pls 120.46 2006/08/04 07:38:11 sajgeo noship $ */

PROCEDURE get_exp_source (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_source_sql out NOCOPY VARCHAR2, exp_source_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, fin_type IN VARCHAR2)
 IS
   sqlstmt                VARCHAR2(32000);
   sqlstmt2               VARCHAR2(500);
   l_cal_join             VARCHAR2(10000);
   l_rpt_struct_join      VARCHAR2(100);
   l_time_parameter       VARCHAR2(100);
   l_bitmask              NUMBER;
   l_ccc_join           VARCHAR2(500);
   l_lob_join           VARCHAR2(500);
   l_amount_col         VARCHAR2(500):= NULL;
   l_sign               VARCHAR2(1):=NULL;
   l_source_misc        VARCHAR2(50);


BEGIN

	fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.g_page_period_type := 'FII_TIME_ENT_PERIOD';
	fii_gl_util_pkg.get_bitmasks;
	fii_gl_util_pkg.g_fin_type := fin_type;
	fii_gl_util_pkg.get_mgr_pmv_sql;
	fii_gl_util_pkg.get_lob_pmv_sql;
	fii_gl_util_pkg.get_non_ag_cat_pmv_sql;
	fii_gl_util_pkg.get_ccc_pmv_sql;


  /* -------------------------------------------------------------------------
   * Check if we are looking at the current month.  If so, we need PTD amounts.
   * Otherwise, we need to find out the amounts for the whole month
   * -------------------------------------------------------------------------
  Commented for bug 5002688. Calculation of l_bitmask was already being done in util pkg. so, picking it from util now

  select nvl(to_char(min(ent_period_id)),fii_gl_util_pkg.g_month_id) into l_time_parameter
  from fii_time_ent_period
  where fii_gl_util_pkg.g_as_of_date between start_date and end_date;

  IF (fii_gl_util_pkg.g_month_id <> l_time_parameter) THEN
	l_bitmask := 256;
  ELSE
	l_bitmask := 23;
  END IF; */

  /************************************************************
   * FII_MEASURE1 = Source ID, not display in the report      *
   * FII_MEASURE4 = Manager ID, not display in the report     *
   * FII_MEASURE5 = Cost Center ID, not display in the report *
   * FII_MEASURE6 = Currency ID, not display in the report    *
   * FII_MEASURE7 = Category ID, not display in the report    *
   * FII_MEASURE8 = Month ID, not display in the report       *
   * FII_MEASURE3 = Source Name, display in the report        *
   * FII_MEASURE2 = Actual Amount                             *
   ************************************************************/

IF fii_gl_util_pkg.g_ccc_join IS NOT NULL THEN
 l_ccc_join :=
        REPLACE(fii_gl_util_pkg.g_ccc_join,'f.cost_center_org_id','m.company_cost_center_org_id');
END IF;

IF  fii_gl_util_pkg.g_lob_join IS NOT NULL THEN

l_lob_join :=
REPLACE(fii_gl_util_pkg.g_lob_join,'f.line_of_business_id','m.parent_lob_id');

END IF ;


IF fii_gl_util_pkg.g_fin_type <> 'R' THEN
 l_sign := '-';
END IF;

IF fii_gl_util_pkg.g_currency = 'FII_GLOBAL1' THEN
          l_amount_col := 'prim_amount_g';
ELSIF fii_gl_util_pkg.g_currency = 'FII_GLOBAL2' THEN
          l_amount_col := 'sec_amount_g';
ELSE
          l_amount_col :=  'prim_amount_g';
END IF;

l_source_misc :=
ltrim(rtrim(fnd_message.get_string('FII','FII_GL_SOURCE_MISC')));

sqlstmt :=
'
SELECT
FII_MEASURE1,
:MGR_ID FII_MEASURE4,
:CCC_ID FII_MEASURE5,
:CURRENCY FII_MEASURE6,
:FIN_ID FII_MEASURE7,
:MONTH_ID FII_MEASURE8,
FII_MEASURE3,
SUM(FII_MEASURE2) FII_MEASURE2,
:LOB_ID     FII_ATTRIBUTE2,
CASE WHEN je_source_name = ''Payables'' AND :FIN_TYPE = ''OE''
     THEN ''pFunctionName=FII_GL_INV_EXP_DET_R&pParamIds=Y'' ELSE
CASE WHEN je_source_name = ''Payables'' AND :FIN_TYPE = ''CGS''
     THEN ''pFunctionName=FII_GL_INV_COR_DET_R&pParamIds=Y'' ELSE
CASE WHEN je_source_name = ''Receivables'' AND FII_MEASURE3 <>
        '''||'''||user_je_source_name||'' ''||'''||l_source_misc||'''||'''||'''
        AND :FIN_TYPE = ''R''
     THEN ''pFunctionName=FII_GL_INV_REV_DET_R&pParamIds=Y''
ELSE
      ''''
end
end
end  FII_URL
FROM (
        SELECT
        f.je_source FII_MEASURE1,
        DECODE(src.je_source_name, ''Receivables'', DECODE(f.je_category,
         ''Misc Receipts'', '''||'''||src.user_je_source_name||'' ''
||'''||l_source_misc||'''||'''||''',
        src.user_je_source_name), src.user_je_source_name)  FII_MEASURE3,
        SUM('||l_sign||l_amount_col||') FII_MEASURE2,
        src.je_source_name je_source_name,
        src.user_je_source_name user_je_source_name
    FROM      fii_gl_je_summary_b   f,
          fii_com_cc_mappings     m,
          fii_fin_cat_mappings    c,
          fii_time_rpt_struct   cal,
          gl_je_sources_tl    src,
          fii_cc_mgr_hierarchies h
          '||fii_gl_util_pkg.g_lob_from_clause||'
     WHERE f.company_id      = m.company_id
        AND   f.cost_center_id  = m.cost_center_id
        AND   m.valid_mgr_flag  = ''Y''
        AND   c.child_fin_cat_id = f.fin_category_id
        AND   src.je_source_name = f.je_source
        AND   h.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
        AND   h.emp_id = m.manager_id
        AND   f.period_type_id       = cal.period_type_id
        AND   cal.time_id            = f.time_id
        AND   cal.report_date        = to_date(:P_AS_OF, ''DD-MM-YYYY'')
        AND   BITAND(cal.record_type_id, :BITMASK)= cal.record_type_id
        '||l_ccc_join||l_lob_join||'
        AND   src.language = userenv(''LANG'')
        AND   f.company_id      = m.company_id
        AND   f.cost_center_id  = m.cost_center_id
        AND   c.child_fin_cat_id = f.fin_category_id
        AND   c.parent_fin_cat_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM
     GROUP BY f.je_source, src.user_je_source_name,
                src.je_source_name,f.je_category)
   GROUP BY FII_MEASURE1, FII_MEASURE3, je_source_name,user_je_source_name    ';



/*
  sqlstmt :=
'     select f.je_source FII_MEASURE1,
            :MGR_ID FII_MEASURE4,
            :CCC_ID FII_MEASURE5,
            :CURRENCY FII_MEASURE6,
            :FIN_ID FII_MEASURE7,
            :MONTH_ID FII_MEASURE8,
            src.user_je_source_name FII_MEASURE3,
            sum(f.actual_g) FII_MEASURE2,
	    :LOB_ID	FII_ATTRIBUTE2,
            case when src.je_source_name = ''Payables'' and :FIN_TYPE = ''OE''
	           then ''pFunctionName=FII_GL_INV_EXP_DET_R&pParamIds=Y'' else
            case when src.je_source_name = ''Payables'' and :FIN_TYPE = ''CGS''
               then ''pFunctionName=FII_GL_INV_COR_DET_R&pParamIds=Y'' else
            case when src.je_source_name = ''Receivables'' and :FIN_TYPE = ''R''
	           then ''pFunctionName=FII_GL_INV_REV_DET_R&pParamIds=Y''
                 else
                 ''''
            end
            end
            end  FII_URL
     from fii_gl_base_v'|| fii_gl_util_pkg.g_global_curr_view ||'  f,
          fii_time_rpt_struct	cal,
	  gl_je_sources_tl    src,
	  fii_cc_mgr_hierarchies h
	  '||fii_gl_util_pkg.g_non_ag_cat_from_clause||fii_gl_util_pkg.g_lob_from_clause||'
     where src.je_source_name = f.je_source
	and h.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
        and h.emp_id = f.manager_id
     	and   f.period_type_id       = cal.period_type_id
     	and   cal.time_id            = f.time_id
     	and   cal.report_date        = to_date(:P_AS_OF, ''DD-MM-YYYY'')
     	and   bitand(cal.record_type_id, :BITMASK)= cal.record_type_id
     	'||fii_gl_util_pkg.g_non_ag_cat_join||fii_gl_util_pkg.g_ccc_join||fii_gl_util_pkg.g_lob_join||'
     	and   src.language = userenv(''LANG'')
     group by f.je_source, src.user_je_source_name, src.je_source_name';
*/


     fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_source_sql, exp_source_output);

END get_exp_source;

PROCEDURE get_rev_src (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_src_sql out NOCOPY VARCHAR2, rev_src_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(1);
BEGIN
    l_fin_type := 'R';
    fii_gl_src_inv_pkg.get_exp_source(p_page_parameter_tbl, rev_src_sql, rev_src_output, l_fin_type );

END get_rev_src;

PROCEDURE get_exp_src (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_src_sql out NOCOPY VARCHAR2, exp_src_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(2);
BEGIN
    l_fin_type := 'OE';
    fii_gl_src_inv_pkg.get_exp_source(p_page_parameter_tbl, exp_src_sql, exp_src_output, l_fin_type );

END get_exp_src;

PROCEDURE get_cogs_src (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cogs_src_sql out NOCOPY VARCHAR2,cogs_src_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(3);
BEGIN
    l_fin_type := 'CGS';
    fii_gl_src_inv_pkg.get_exp_source(p_page_parameter_tbl, cogs_src_sql, cogs_src_output, l_fin_type );

END get_cogs_src;

PROCEDURE get_inv_exp_det (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
inv_exp_det_sql out NOCOPY VARCHAR2, inv_exp_det_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
  inv_exp_det_rec	 BIS_QUERY_ATTRIBUTES;
  sqlstmt                VARCHAR2(32000);
  l_ccc_join		 VARCHAR2(500) := NULL;
  l_lob_join		 VARCHAR2(500) := NULL;
  l_from_clause		 VARCHAR2(100);
  l_hint		 VARCHAR2(100) := NULL;
  l_prim_sec		 VARCHAR2(30);


BEGIN
	fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.g_page_period_type := 'FII_TIME_ENT_PERIOD';
	fii_gl_util_pkg.get_bitmasks;
	IF ((fii_gl_util_pkg.g_ccc_id IS NOT NULL) AND (fii_gl_util_pkg.g_ccc_id <> -999)) THEN
   	    IF (fii_gl_util_pkg.ccc_within_mgr_lob(fii_gl_util_pkg.g_ccc_id, fii_gl_util_pkg.g_lob_id, fii_gl_util_pkg.g_mgr_id) = 'Y') THEN
     		 l_ccc_join := ' and com.company_cost_center_org_id = &ORGANIZATION+HRI_CL_ORGCC
				 and com.company_id = f.company_id
				 and com.cost_center_id = f.cost_center_id ';
		l_from_clause := ', fii_com_cc_mappings com';
   	    ELSE
	         l_ccc_join := ' and 1 = 2 ';
    	    END IF;
	ELSIF (fii_gl_util_pkg.g_lob_id IS NOT NULL) AND (fii_gl_util_pkg.g_lob_is_top_node <> 'Y') THEN


      		l_lob_join := ' and lob.parent_lob_id = :LOB_ID
				and lob.child_lob_id = com.parent_lob_id
				and com.company_id = f.company_id
				and com.cost_center_id = f.cost_center_id
				and mgr.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
				and mgr.emp_id = com.parent_manager_id';
		l_from_clause := ', fii_com_cc_mappings com ,
				    fii_lob_hierarchies lob,
				    fii_cc_mgr_hierarchies mgr';
		l_hint := '/*+leading(lob) */';
	ELSIF (fii_gl_util_pkg.g_lob_id IS NULL) OR (fii_gl_util_pkg.g_lob_is_top_node = 'Y') THEN


		l_lob_join := ' and com.company_id = f.company_id
				and com.cost_center_id = f.cost_center_id
				and mgr.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
				and mgr.emp_id = com.parent_manager_id';
		l_from_clause := ', fii_com_cc_mappings com,
				    fii_cc_mgr_hierarchies mgr';
		l_hint := '/*+ leading(mgr) index(fi, fii_fin_cat_mappings_n1) */';

	END IF;

	IF fii_gl_util_pkg.g_global_curr_view = '1' THEN
		l_prim_sec := 'prim_amount_g';
	ELSE
		l_prim_sec := 'sec_amount_g';
	END IF;

/* As bug fix for 3597165, changed hint to use fii_fin_cat_mappings_n1 (instead of fii_fin_cat_mappings_n3) and moved group by in the inner sql */

  /*******************************************************
   * FII_MEASURE1 = Invoice #                            *
   * FII_MEASURE2 = Invoice Date                         *
   * FII_MEASURE3 = Invoice Description                  *
   * FII_MEASURE4 = Supplier                             *
   * FII_MEASURE5 = Actual Amount                        *
   *******************************************************/


sqlstmt := '
	SELECT  inline.invoice_num      FII_MEASURE1,
		inline.invoice_date     FII_MEASURE2,
		ai.description          FII_MEASURE3,
		pov.vendor_name         FII_MEASURE4,
		inline.actual_g	        FII_MEASURE5,
		inline.gt_actual_g      FII_ATTRIBUTE1
		FROM	po_vendors               pov,
			ap_invoices_all          ai,
		      (	SELECT	F.invoice_num  invoice_num,
				F.invoice_date invoice_date,
				F.supplier_id  supplier_id,
				F.invoice_id   invoice_id,
				SUM('||l_prim_sec||') actual_g,
				SUM(SUM('||l_prim_sec||')) OVER() gt_actual_g
			FROM	FII_AP_INV_B  F,
                                FII_Fin_Cat_Mappings FI,
                                FII_Fin_Item_Hierarchies HIER,
                                GL_Import_References GIR,
                                FII_GL_Processed_Header_IDS PH
                                ' || l_from_clause || '
                        WHERE HIER.Parent_Fin_Cat_ID = &FINANCIAL ITEM+GL_FII_FIN_ITEM
                        AND   HIER.Child_Fin_Cat_ID = FI.Parent_Fin_Cat_ID
                        and     f.account_date between to_date(:P_DET_START, ''DD-MM-YYYY'') and to_date(:P_DET_END, ''DD-MM-YYYY'')
                        AND   FI.Child_Fin_Cat_ID = F.Fin_Category_ID
                              ' || l_lob_join || l_ccc_join || '
                        AND   F.GL_SL_Link_ID = GIR.Gl_SL_Link_ID
                        AND   F.GL_SL_Link_Table = GIR.GL_SL_Link_Table
                        AND   GIR.JE_Header_ID = PH.JE_Header_ID
                        GROUP BY F.invoice_num, F.invoice_id, F.supplier_id, F.invoice_date ) inline
WHERE inline.supplier_id=pov.vendor_id
AND   inline.invoice_id=ai.invoice_id';



   fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, inv_exp_det_sql, inv_exp_det_output);

END get_inv_exp_det;

PROCEDURE get_inv_rev_det (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
inv_rev_det_sql out NOCOPY VARCHAR2, inv_rev_det_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  sqlstmt                VARCHAR2(32000);
  l_ccc_join		 VARCHAR2(500) := NULL;
  l_lob_join		 VARCHAR2(500) := NULL;
  l_from_clause 	 VARCHAR2(100) := NULL;
  l_hint		 VARCHAR2(100) := NULL;

BEGIN

	fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.g_page_period_type := 'FII_TIME_ENT_PERIOD';
	fii_gl_util_pkg.get_bitmasks;
	IF ((fii_gl_util_pkg.g_ccc_id IS NOT NULL) AND (fii_gl_util_pkg.g_ccc_id <> -999)) THEN
   	    IF (fii_gl_util_pkg.ccc_within_mgr_lob(fii_gl_util_pkg.g_ccc_id, fii_gl_util_pkg.g_lob_id, fii_gl_util_pkg.g_mgr_id) = 'Y') THEN
     		 l_ccc_join := ' and com.company_cost_center_org_id = &ORGANIZATION+HRI_CL_ORGCC
				 and com.company_id = f.company_id
				 and com.cost_center_id = f.cost_center_id ';
		l_from_clause := ', fii_com_cc_mappings com';
   	    ELSE
	         l_ccc_join := ' and 1 = 2 ';
    	    END IF;
	ELSIF (fii_gl_util_pkg.g_lob_id IS NOT NULL) AND (fii_gl_util_pkg.g_lob_is_top_node <> 'Y') THEN
      		l_lob_join := ' and lob.parent_lob_id = :LOB_ID
				and lob.child_lob_id  = com.parent_lob_id
				and com.company_id = f.company_id
				and com.cost_center_id = f.cost_center_id
				and mgr.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
				and mgr.emp_id = com.parent_manager_id';
		l_from_clause := ', fii_com_cc_mappings com,
				    fii_lob_hierarchies lob,
				    fii_cc_mgr_hierarchies mgr';
		l_hint := '/*+leading(lob) */';
	ELSIF (fii_gl_util_pkg.g_lob_id IS NULL) OR (fii_gl_util_pkg.g_lob_is_top_node = 'Y') THEN
		l_lob_join := ' and com.company_id = f.company_id
				and com.cost_center_id = f.cost_center_id
				and mgr.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
				and mgr.emp_id = com.parent_manager_id';
		l_from_clause := ', fii_com_cc_mappings com,
				    fii_cc_mgr_hierarchies mgr';
		l_hint := '/*+ leading(mgr) index(cat, fii_fin_cat_mappings_n1) */';

	END IF;

/* As bug fix for 3597183, changed hint to use fii_fin_cat_mappings_n1 (instead of fii_fin_cat_mappings_n3) and moved group by in the inner sql */
  /*******************************************************
   * FII_MEASURE1 = Cost Center                          *
   * FII_MEASURE2 = Acct                                 *
   * FII_MEASURE3 = Account Name                         *
   * FII_MEASURE4 = Customer                             *
   * FII_MEASURE5 = Invoice Number                       *
   * FII_MEASURE6 = Invoice Date                         *
   * FII_MEASURE7 = Amount                               *
   *******************************************************/

  sqlstmt := '
               select  fnd1.flex_value                  FII_MEASURE1,
                      inline.fin_category_id            FII_MEASURE2,
                      fnd.description                   FII_MEASURE3,
                      cust.party_name                   FII_MEASURE4,
                      inline.invoice_number             FII_MEASURE5,
                      inline.invoice_date		FII_MEASURE6,
                      inline.sum_actual_g		FII_MEASURE7,
		      inline.gt_actual_g		FII_ATTRIBUTE1
              from    hz_parties               cust,
		      fnd_flex_values_tl       fnd,
                      fnd_flex_values       fnd1,

		      (select '||l_hint||'
				f.cost_center_id 	cost_center_id,
				f.fin_category_id 	fin_category_id,
				f.invoice_number 	invoice_number,
				to_char(f.invoice_date,''DD-MON-YYYY'')     invoice_date,
				sum(f.actual_g)				sum_actual_g,
				sum(sum(f.actual_g)) over()		gt_actual_g,
 				f.bill_to_party_id	bill_to_party_id
			from	fii_ar_revenue_b_v'||fii_gl_util_pkg.g_global_curr_view||'      f,
                      			fii_fin_cat_mappings cat,
		      			fii_fin_item_hierarchies hier'||l_from_clause||'
              		where   f.posted_flag     = ''Y'''||l_ccc_join||l_lob_join||'
				and     f.gl_date between to_date(:P_DET_START, ''DD-MM-YYYY'') and to_date(:P_DET_END, ''DD-MM-YYYY'')
	 			and     hier.parent_fin_cat_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM
	    			and     hier.child_fin_cat_id = cat.parent_fin_cat_id
 				and     cat.child_fin_cat_id            = f.fin_category_id
			group by	f.invoice_date,
					f.bill_to_party_id,
					f.cost_center_id,
					f.fin_category_id,
					f.invoice_number) inline

	      where   cust.party_id	 = inline.bill_to_party_id
              and     fnd1.flex_value_id = inline.cost_center_id
              and     fnd.flex_value_id  = inline.fin_category_id
              and     fnd.language = userenv(''Lang'')';


	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, inv_rev_det_sql, inv_rev_det_output);


END get_inv_rev_det;

 PROCEDURE fii_drill_across(pSource IN varchar2,
                           pCategory IN varchar2, pCostCenter IN varchar2, pMonth IN varchar2,
                           pCurrency IN varchar2, pManager IN varchar2, pAsOfDateValue IN varchar2, pLOB IN varchar2) IS

  l_FunctionName varchar2(100);
  l_fin_leaf_node varchar2(1);

BEGIN

if pSource = 'Payables' then

  select FunctionName into l_FunctionName from
  (select 'FII_GL_INV_EXP_DET_R' FunctionName
  from fii_fin_item_hierarchies cat
  where cat.parent_fin_cat_id in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = 'OE' and TOP_NODE_FLAG = 'Y')
  and cat.child_fin_cat_id=pCategory
  union all
  select 'FII_GL_INV_COR_DET_R' FunctionName
  from fii_fin_item_hierarchies cat
  where cat.parent_fin_cat_id in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = 'CGS' and TOP_NODE_FLAG = 'Y')
  and cat.child_fin_cat_id=pCategory);

  bisviewer_pub.showreport(pURLString => 'pFunctionName='||l_FunctionName||'&FII_DIM2='||pCategory||'&FII_DIM7='||
  pCostCenter||'&FII_DIM9='||pMonth||'&FII_MEASURE9='||pLOB||'&FII_DIM8='||pCurrency||'&FII_DIM1='||pManager||'&pParamIds=Y',
                           pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                           pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                           pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));

elsif pSource = 'Receivables' then

  bisviewer_pub.showreport(pURLString => 'pFunctionName=FII_GL_INV_REV_DET_R&FII_DIM2='||pCategory||'&FII_DIM7='||
  pCostCenter||'&FII_DIM9='||pMonth||'&FII_MEASURE9='||pLOB||'&FII_DIM8='||pCurrency||'&FII_DIM1='||pManager||'&pParamIds=Y',
                           pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                           pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                           pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));

elsif (pSource = 'FII_GL_EXP_CAT3' OR pSource = 'FII_GL_REV_CAT3' OR pSource = 'FII_GL_COG_CAT3')then

  SELECT DISTINCT next_level_is_leaf
  INTO  l_fin_leaf_node
  FROM fii_fin_item_hierarchies
  WHERE next_level_fin_cat_id = pCategory
  and parent_fin_cat_id = next_level_fin_cat_id
  and child_fin_cat_id = next_level_fin_cat_id;

    IF l_fin_leaf_node = 'Y' THEN
    select FunctionName into l_FunctionName from
    (select 'FII_GL_INV_EXP_R' FunctionName
    from fii_fin_item_hierarchies cat
    where cat.parent_fin_cat_id in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = 'OE' and TOP_NODE_FLAG = 'Y')
    and cat.child_fin_cat_id=pCategory
    union all
    select 'FII_GL_INV_REV_R' FunctionName
    from fii_fin_item_hierarchies cat
    where cat.parent_fin_cat_id in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = 'R' and TOP_NODE_FLAG = 'Y')
    and cat.child_fin_cat_id=pCategory
    union all
    select 'FII_GL_INV_COR_R' FunctionName
    from fii_fin_item_hierarchies cat
    where cat.parent_fin_cat_id in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = 'CGS' and TOP_NODE_FLAG = 'Y')
    and cat.child_fin_cat_id=pCategory);

    bisviewer_pub.showreport(pURLString => 'pFunctionName='||l_FunctionName||'&FII_DIM2='||pCategory||'&FII_DIM8='||
    pCostCenter||'&FII_DIM9='||pMonth||'&FII_DIM7='||pCurrency||'&FII_DIM1='||pManager||'&FII_MEASURE9='||pLOB||'&AS_OF_DATE='||pAsOfDateValue||
    '&pParamIds=Y',
                               pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                               pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                               pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));

  else
    bisviewer_pub.showreport(pURLString => 'pFunctionName=FII_GL_EXP_CAT3&FII_DIM9='||pLOB||'&VIEW_BY=VIEW_BY&FII_DIM7='||
    pCategory||'&FII_DIM10='||pCostCenter||'&FII_DIM3='||pMonth||'&FII_DIM8='||pCurrency||'&FII_DIM1='||
    pManager||'&AS_OF_DATE='||pAsOfDateValue||'&pParamIds=Y',
                             pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                             pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                             pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));

  end if;

else

   select FunctionName into l_FunctionName from
   (select 'FII_GL_INV_EXP_R' FunctionName
   from fii_fin_item_hierarchies cat
   where cat.parent_fin_cat_id in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = 'OE' and TOP_NODE_FLAG = 'Y')
   and cat.child_fin_cat_id=pCategory
   union all
   select 'FII_GL_INV_REV_R' FunctionName
   from fii_fin_item_hierarchies cat
   where cat.parent_fin_cat_id in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = 'R' and TOP_NODE_FLAG = 'Y')
   and cat.child_fin_cat_id=pCategory
   union all
   select 'FII_GL_INV_COR_R' FunctionName
   from fii_fin_item_hierarchies cat
   where cat.parent_fin_cat_id in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = 'CGS' and TOP_NODE_FLAG = 'Y')
   and cat.child_fin_cat_id=pCategory);

  bisviewer_pub.showreport(pURLString => 'pFunctionName='||l_FunctionName||'&FII_DIM2='||pCategory||'&FII_DIM8='||
  pCostCenter||'&FII_DIM9='||pMonth||'&FII_DIM7='||pCurrency||'&FII_DIM1='||pManager||'&FII_MEASURE9='||pLOB||'&AS_OF_DATE='||pAsOfDateValue||
  '&pParamIds=Y',
                           pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                           pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                           pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));

end if;

END;

END fii_gl_src_inv_pkg;

/
