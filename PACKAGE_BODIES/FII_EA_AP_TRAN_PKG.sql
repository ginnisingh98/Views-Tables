--------------------------------------------------------
--  DDL for Package Body FII_EA_AP_TRAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_AP_TRAN_PKG" AS
/* $Header: FIIEAAPTB.pls 120.6 2006/06/16 19:38:13 shanley noship $ */


PROCEDURE GET_AP_TRAN
      (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       ap_tran_sql out NOCOPY VARCHAR2,
       ap_tran_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS

       -- declaration section
       sqlstmt                         VARCHAR2(15000);
       l_as_of_date                    DATE;
       l_page_period_type              VARCHAR2(100);
       l_ledger_id                     VARCHAR2(30);
       l_fud1_where                    VARCHAR2(200);
       l_fud2_where                    VARCHAR2(200);

       l_msg1                          VARCHAR2(100);
-- Commented following variable as part of enhancement 4456983
--     l_pay_op_imp_flag               VARCHAR2(1);
       l_sysdate	               VARCHAR2(30);
BEGIN


fii_ea_util_pkg.reset_globals;
fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);
l_as_of_date := fii_ea_util_pkg.g_as_of_date;
l_page_period_type := fii_ea_util_pkg.g_page_period_type;
l_ledger_id := fii_ea_util_pkg.g_ledger_id;
l_fud1_where := replace(fii_ea_util_pkg.get_fud1_for_detail, 'fud1_id', 'user_dim1_id');
l_fud2_where := replace(fii_ea_util_pkg.get_fud2_for_detail, 'fud2_id', 'user_dim2_id');

-- Enhancement 4456983.
-- Commented following code line to make FII_EA_INV_DTL_DRILL, independent of DBI-AP implementation.
-- l_pay_op_imp_flag := NVL(FND_PROFILE.value('FII_AP_DBI_IMP'), 'N');

/*Get the Chart of Accounts ID to join to FII_GL_CCID_DIMENSIONS in PMV sql.
  Get Period Set Name & Accounted Period Type to use index on Period Set Name in GL_JE_LINES*/
SELECT Chart_Of_Accounts_ID, Period_Set_Name, Accounted_Period_Type
INTO fii_ea_util_pkg.g_coaid, fii_ea_util_pkg.g_period_set_name, fii_ea_util_pkg.g_accounted_period_type
FROM GL_Sets_Of_Books
WHERE Set_Of_Books_ID = l_ledger_id;

l_msg1 := fnd_message.get_string('FII', 'FII_EA_MULTIPLE');

/*This report drills from gl so only pick up payables lines picked up in gl base mvs.
  To link ap to gl:
  (1) find subset of CCID dimensions in FII_GL_CCID_DIMENSIONS,
  (2) pick up gl lines with one of the CCID dimensions in GL_JE_LINES,
  (3) pick up only processed headers in FII_GL_PROCESSED_HEADER_IDS,
  (4) pick up only payables headers in GL_JE_HEADERS (filter on GL effective date, not AP account date),
  (5) link GL lines to AP lines in AP_AE_LINES_ALL,
  (6) link AP lines to FII_AP_INV_B.
*/


-- To pass SYSDATE in Drill URL - FII_EA_INV_DTL_DRILL,
-- we need to get SYSDATE into local variable as a string

	SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY')
          INTO l_sysdate
	  FROM dual;

sqlstmt := '
SELECT FII_EA_INV_NUM FII_EA_INV_NUM,
       FII_EA_TRAN_CURRENCY FII_EA_TRAN_CURRENCY,
       FII_EA_TRAN_AMT FII_EA_TRAN_AMT,
       FII_EA_FUNCTIONAL_AMOUNT FII_EA_FUNCTIONAL_AMOUNT,
       FII_EA_INV_DATE FII_EA_INV_DATE,
       FII_EA_INV_TYPE FII_EA_INV_TYPE,
       FII_EA_EXP_REPORT_NUM FII_EA_EXP_REPORT_NUM,
       FII_EA_PO_NUM FII_EA_PO_NUM,
       FII_EA_INV_DTL_DRILL FII_EA_INV_DTL_DRILL,
       FII_EA_EXP_REPORT_NUM_DRILL FII_EA_EXP_REPORT_NUM_DRILL,
       FII_EA_PO_NUM_DRILL FII_EA_PO_NUM_DRILL,
       FII_EA_GT_FUNC_AMT FII_EA_GT_FUNC_AMT
FROM(
SELECT F.Invoice_Num FII_EA_INV_NUM,
       F.Trans_Currency_Code FII_EA_TRAN_CURRENCY,
       SUM(F.Amount_T) FII_EA_TRAN_AMT,
       SUM(F.Amount_B) FII_EA_FUNCTIONAL_AMOUNT,
       F.Invoice_Date FII_EA_INV_DATE,
       F.Invoice_Type FII_EA_INV_TYPE,
       DECODE(F.Exp_Report_Header_ID, NULL, NULL, -1, ''' || l_msg1 || ''' ,F.Invoice_Num) FII_EA_EXP_REPORT_NUM,
       DECODE(MIN(F.PO_Distribution_ID), NULL, NULL,
              DECODE(COUNT(DISTINCT F.PO_Header_ID || ''.'' || F.PO_Release_ID),
                     0, NULL, 1, MIN(F.PO_Num), ''' || l_msg1 || ''')) FII_EA_PO_NUM,
       ''AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_EA_AP_INV_DTL&FII_INVOICE='' || F.Invoice_Num || ''&FII_INVOICE_ID='' || F.Invoice_ID || ''&FII_OPERATING_UNITS='' || F.Org_ID || ''&POA_SUPPLIERS='' || F.Supplier_ID || ''&pParamIds=Y''
		FII_EA_INV_DTL_DRILL,
       DECODE(F.Exp_Report_Header_ID, NULL, NULL, -1, NULL,
       ''pFunctionName=FII_IEXPENSES_DRILL&dbiReportHeaderId='' || F.Exp_Report_Header_ID ||
       ''&dbiInvoiceId='' || F.Invoice_ID) FII_EA_EXP_REPORT_NUM_DRILL,
       DECODE(MIN(F.PO_Distribution_ID), NULL, NULL,
              DECODE(COUNT(DISTINCT F.PO_Header_ID || ''.'' || F.PO_Release_ID), 0, NULL, 1,
                     ''pFunctionName=FII_EA_POA_DRILL&PoHeaderId='' || MIN(F.PO_Header_ID) ||
                     ''&PoReleaseId='' || MIN(F.PO_Release_ID) || ''&addBreadCrumb=Y&retainAM=Y'',
                     NULL)) FII_EA_PO_NUM_DRILL,
       SUM(SUM(F.Amount_B)) OVER () FII_EA_GT_FUNC_AMT,
      (rank() over (ORDER BY SUM(F.Amount_B) DESC, F.Invoice_Num ASC, F.Invoice_ID ASC)) - 1 rnk
FROM  FII_AP_INV_B F,
      GL_Import_References GIR,
      FII_GL_Processed_Header_IDS PH,
      GL_JE_Lines JL
WHERE F.GL_SL_Link_ID = GIR.GL_SL_Link_ID
AND   F.GL_SL_Link_Table = GIR.GL_SL_LINK_TABLE
AND   GIR.JE_Header_ID = PH.JE_Header_ID
AND   PH.JE_Header_ID = JL.JE_Header_ID
AND   GIR.JE_Line_Num = JL.JE_Line_Num
AND   GIR.gl_sl_link_table IN (''XLAJEL'', ''APECL'')
AND   F.Company_ID = &FII_COMPANIES+FII_COMPANIES
AND   F.Cost_Center_ID = &ORGANIZATION+HRI_CL_ORGCC
AND   F.Fin_Category_ID = &FINANCIAL ITEM+GL_FII_FIN_ITEM
AND   F.Ledger_ID = &FII_LEDGER+FII_LEDGER
' || l_fud1_where || '
' || l_fud2_where || '
AND   JL.Effective_Date BETWEEN :CURR_PERIOD_START AND :ASOF_DATE
GROUP BY F.Invoice_Num,
         F.Invoice_ID,
         F.Supplier_ID,
         F.Org_ID,
         F.Trans_Currency_Code,
         F.Invoice_Date,
         F.Invoice_Type,
         F.Exp_Report_Header_ID
)
WHERE (RNK between &START_INDEX and &END_INDEX or &END_INDEX = -1)
ORDER BY RNK';


FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt => sqlstmt,
        p_page_parameter_tbl => p_page_parameter_tbl,
        p_sql_output => ap_tran_sql,
        p_bind_output_table => ap_tran_output);


END GET_AP_TRAN;


END FII_EA_AP_TRAN_PKG;

/
