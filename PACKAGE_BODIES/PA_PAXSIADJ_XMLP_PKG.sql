--------------------------------------------------------
--  DDL for Package Body PA_PAXSIADJ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXSIADJ_XMLP_PKG" AS
/* $Header: PAXSIADJB.pls 120.0 2008/01/02 12:17:55 krreddy noship $ */
  function BeforeReport return boolean is
  CURSOR C_GET_LEDGER_ID_CUR IS
  SELECT set_of_books_id
    FROM pa_implementations;
  CURSOR C_GET_LEDGER_DETAILS_CUR(p_ledger_id NUMBER) IS
  SELECT period_set_name
       , currency_code
    FROM gl_ledgers_public_v
   WHERE ledger_id = p_ledger_id;
  CURSOR C_GET_GL_PERIOD_START_DATE_CUR(p_period_set_name VARCHAR2, p_period_name VARCHAR2) IS
  SELECT start_date
    FROM gl_periods
   WHERE period_set_name = p_period_set_name
     AND period_name = p_period_name;
  CURSOR C_GET_GL_PERIOD_END_DATE_CUR(p_period_set_name VARCHAR2, p_period_name VARCHAR2) IS
  SELECT end_date
    FROM gl_periods
   WHERE period_set_name = p_period_set_name
     AND period_name = p_period_name;
begin
  /*SRW.USER_EXIT('FND SRWINIT');
  srw.user_exit('FND GETPROFILE
                 NAME="PA_DEBUG_MODE"
                 FIELD=":p_debug_mode"
                 PRINT_ERROR="N"');*/
  IF p_debug_mode = 'Y' THEN
--    srw.message(10,'Getting Ledger ID');
NULL;
  END IF;
  OPEN C_GET_LEDGER_ID_CUR;
  FETCH C_GET_LEDGER_ID_CUR INTO P_LEDGER_ID;
  CLOSE C_GET_LEDGER_ID_CUR;
  IF p_debug_mode = 'Y' THEN
--    srw.message(20,'Ledger ID : ' || :P_LEDGER_ID);
--    srw.message(30,'Getting Period Set Name and Currency Code');
NULL;
  END IF;
  OPEN C_GET_LEDGER_DETAILS_CUR(P_LEDGER_ID);
  FETCH C_GET_LEDGER_DETAILS_CUR INTO P_PERIOD_SET_NAME,P_CURRENCY_CODE;
  CLOSE C_GET_LEDGER_DETAILS_CUR;
  IF p_debug_mode = 'Y' THEN
--    srw.message(40,'Period Set Name : ' || :P_PERIOD_SET_NAME);
--    srw.message(50,'Currency Code : ' || :P_CURRENCY_CODE);
NULL;
  END IF;
  IF P_FROM_GL_PERIOD IS NOT NULL THEN
    IF p_debug_mode = 'Y' THEN
--      srw.message(60,'Getting Start Date of GL Period ' || :P_FROM_GL_PERIOD);
NULL;
    END IF;
    OPEN C_GET_GL_PERIOD_START_DATE_CUR(P_PERIOD_SET_NAME,P_FROM_GL_PERIOD);
    FETCH C_GET_GL_PERIOD_START_DATE_CUR INTO P_FROM_GL_DATE;
    CLOSE C_GET_GL_PERIOD_START_DATE_CUR;
    IF p_debug_mode = 'Y' THEN
--      srw.message(70,'Start Date : ' || :P_FROM_GL_DATE);
NULL;
    END IF;
  END IF;
  IF P_TO_GL_PERIOD IS NOT NULL THEN
    IF p_debug_mode = 'Y' THEN
--      srw.message(80,'Getting End Date of GL Period ' || :P_TO_GL_PERIOD);
NULL;
    END IF;
    OPEN C_GET_GL_PERIOD_END_DATE_CUR(P_PERIOD_SET_NAME,P_TO_GL_PERIOD);
    FETCH C_GET_GL_PERIOD_END_DATE_CUR INTO P_TO_GL_DATE;
    CLOSE C_GET_GL_PERIOD_END_DATE_CUR;
    IF p_debug_mode = 'Y' THEN
--      srw.message(90,'End Date : ' || :P_TO_GL_DATE);
NULL;
    END IF;
  END IF;
  IF FND_GLOBAL.APPLICATION_SHORT_NAME = 'GMS' THEN
    P_IS_GRANTS_INSTALLED := 'Y';
    P_GMS_WHERE := ' AND pa_gms_api.vert_is_award_within_range( '
                 || '       ei.expenditure_item_id '
                 || '      ,''' || P_FROM_AWARD_NUMBER || ''' '
                 || '      ,''' || P_TO_AWARD_NUMBER || ''' '
                 || '      ) = ''Y'' ';
 ELSE
 P_GMS_WHERE := ' ';
  END IF;
  IF  P_FROM_GL_ACCOUNT IS NOT NULL
  AND P_TO_GL_ACCOUNT IS NOT NULL THEN
    IF p_debug_mode = 'Y' THEN
--      srw.message(100,'Deriving where condition using account range');
NULL;
    END IF;
/*    srw.user_exit('FND FLEXSQL CODE="GL#"
                   NUM=":P_COA_ID"
                   APPL_SHORT_NAME="SQLGL"
                   OUTPUT=":P_ACC_WHERE"
                   TABLEALIAS="CC"
                   MODE="WHERE"
                   DISPLAY="ALL"
                   OPERATOR="BETWEEN"
                   OPERAND1=":P_FROM_GL_ACCOUNT"
                   OPERAND2=":P_TO_GL_ACCOUNT"');
		   */
    P_ACC_WHERE := ' AND ' || P_ACC_WHERE;
    IF p_debug_mode = 'Y' THEN
--      srw.message(110,'Where condition formed : ' || :P_ACC_WHERE);
NULL;
    END IF;
  END IF;
 /*If Adjustment Type is all adjustments then, no predicate is to be appended to the WHERE CLAUSE */
  IF P_ADJUSTMENT_TYPE = 'ALL' THEN
    P_INV_REV_ADJ_WHERE := ' ';
    P_RCV_REV_ADJ_WHERE := ' ';
    P_PAY_REV_ADJ_WHERE := ' ';
    P_INV_PA_ADJ_WHERE  := ' ';
    P_RCV_PA_ADJ_WHERE  := ' ';
    P_PAY_PA_ADJ_WHERE  := ' ';
  ELSIF P_ADJUSTMENT_TYPE = 'REV_ADJ' THEN
    P_INV_REV_ADJ_WHERE :=
                        ' AND ei.transaction_source IN (''AP VARIANCE'',''AP INVOICE'',''AP NRTAX'',''AP DISCOUNTS'',''AP ERV'''
                     || '                              ,''INTERCOMPANY_AP_INVOICES'',''INTERPROJECT_AP_INVOICES'',''AP EXPENSE'')'
                     || ' AND EXISTS (select NULL'
                     || '               from pa_cost_distribution_lines cdl1'
                     || '              where cdl1.expenditure_item_id = ei.expenditure_item_id'
                     || '                and cdl1.line_num = 1'
                     || '                and NVL(cdl1.reversed_flag,''N'') <> ''Y'')'
                     || ' AND ei.net_zero_adjustment_flag = ''N'''
                     || ' AND ei.transferred_from_exp_item_id IS NULL'
                     || ' AND EXISTS (select NULL'
                     || '               from pa_expenditure_items ei2'
                     || '              where (ei2.document_header_id, ei2.document_distribution_id) IN'
                     || '                    ( SELECT apdist2.invoice_id, apdist2.old_distribution_id'
                     || '                        from ap_invoice_distributions apdist1,'
                     || '                             ap_invoice_distributions apdist2 '
                     || '                       where ei.document_distribution_id = apdist1.invoice_distribution_id'
                     || '                         and NVL(apdist1.historical_flag,''N'') <> ''Y'''
                     || '                         and apdist1.reversal_flag = ''Y'''
                     || '                         and apdist1.parent_reversal_id = apdist2.invoice_distribution_id'
                     || '                         and apdist2.old_distribution_id IS NOT NULL)'
                     || '                and (   ei2.net_zero_adjustment_flag = ''Y'''
                     || '                    OR EXISTS ( SELECT NULL'
                     || '                                  FROM pa_cost_distribution_lines_all cdl2'
                     || '                                 WHERE cdl2.expenditure_item_id = ei2.expenditure_item_id'
                     || '                                   AND cdl2.line_num = 1'
                     || '                                   AND cdl2.reversed_flag = ''Y''))) ';
    P_RCV_REV_ADJ_WHERE :=
                        ' AND ei.transaction_source IN (''PO RECEIPT'',''PO RECEIPT NRTAX'''
                     || '                              ,''PO RECEIPT NRTAX PRICE ADJ'''
                     || '                              ,''PO RECEIPT PRICE ADJ'')'
                     || ' AND EXISTS (select NULL'
                     || '               from pa_cost_distribution_lines cdl1'
                     || '              where cdl1.expenditure_item_id = ei.expenditure_item_id'
                     || '                and cdl1.line_num = 1'
                     || '                and NVL(cdl1.reversed_flag,''N'') <> ''Y'')'
                     || ' AND ei.net_zero_adjustment_flag = ''N'''
                     || ' AND ei.transferred_from_exp_item_id IS NULL'
                     || ' AND EXISTS (select NULL'
                     || '               from pa_expenditure_items ei2'
                     || '              where (ei2.document_header_id, ei2.document_distribution_id) IN'
                     || '                    ( select rcv2.po_header_id, rcv2.transaction_id'
                     || '                        from rcv_transactions rcv1'
                     || '                           , rcv_transactions rcv2'
                     || '                       where rcv1.transaction_id = ei.document_distribution_id'
                     || '                         and rcv1.transaction_type in (''RETURN TO RECEIVING'',''RETURN TO VENDOR'',''CORRECT'')'
                     || '                         and rcv1.parent_transaction_id = rcv2.transaction_id)'
                     || '                and (   ei2.net_zero_adjustment_flag = ''Y'''
                     || '                    OR EXISTS ( SELECT NULL'
                     || '                                  FROM pa_cost_distribution_lines_all cdl2'
                     || '                                 WHERE cdl2.expenditure_item_id = ei2.expenditure_item_id'
                     || '                                   AND cdl2.line_num = 1'
                     || '                                   AND cdl2.reversed_flag = ''Y''))) ';
    P_PAY_REV_ADJ_WHERE := ' AND 1 = 2 ';
    P_INV_PA_ADJ_WHERE  := ' ';
    P_RCV_PA_ADJ_WHERE  := ' ';
    P_PAY_PA_ADJ_WHERE  := ' ';
  ELSIF P_ADJUSTMENT_TYPE = 'PA_ADJ' THEN
    P_INV_REV_ADJ_WHERE := ' ';
    P_RCV_REV_ADJ_WHERE := ' ';
    P_PAY_REV_ADJ_WHERE := ' ';
    P_INV_PA_ADJ_WHERE  := ' AND cdl.transfer_status_code <> ''V'' ';
    P_RCV_PA_ADJ_WHERE  := ' AND cdl.transfer_status_code <> ''V'' ';
    P_PAY_PA_ADJ_WHERE  := ' AND cdl.transfer_status_code <> ''V'' ';
  END IF;
/* This will be appended to the ORDER BY clause based on the "Sort Order" parameter */
  IF P_SORT_ORDER = 'AP' THEN
    P_ORDER_BY := ', Invoice_Number '
                || ', Invoice_Line_Num '
                || ', Invoice_Dist_Line_Num '
                || ', AP_PO_Number '
                || ', AP_PO_Line_Num '
                || ', AP_PO_Dist_Num ';
  ELSE
    P_ORDER_BY := ', PO_Number '
                || ', PO_Line_Num '
                || ', PO_Dist_Num '
                || ', Invoice_Number '
                || ', Invoice_Line_Num '
                || ', Invoice_Dist_Line_Num ';
  END IF;
  return (TRUE);
end;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION CF_COMPANY_NAMEFORMULA RETURN CHAR IS
    L_COMPANY_NAME VARCHAR2(30);
    CURSOR C_GET_COMPANY_NAME_CUR IS
      SELECT
        GL.NAME
      FROM
        GL_LEDGERS_PUBLIC_V GL,
        PA_IMPLEMENTATIONS IMP
      WHERE GL.LEDGER_ID = IMP.SET_OF_BOOKS_ID;
  BEGIN
    OPEN C_GET_COMPANY_NAME_CUR;
    FETCH C_GET_COMPANY_NAME_CUR
     INTO L_COMPANY_NAME;
    CLOSE C_GET_COMPANY_NAME_CUR;
    RETURN L_COMPANY_NAME;
  END CF_COMPANY_NAMEFORMULA;
  FUNCTION CF_NO_DATA_FOUNDFORMULA(CS_COUNT IN NUMBER) RETURN CHAR IS
    L_NO_DATA_FOUND VARCHAR2(80);
    CURSOR C_GET_NO_DATA_FOUND_MSG_CUR IS
      SELECT
        MEANING
      FROM
        PA_LOOKUPS
      WHERE LOOKUP_TYPE = 'MESSAGE'
        AND LOOKUP_CODE = 'NO_DATA_FOUND';
  BEGIN
    IF CS_COUNT = 0 THEN
      OPEN C_GET_NO_DATA_FOUND_MSG_CUR;
      FETCH C_GET_NO_DATA_FOUND_MSG_CUR
       INTO L_NO_DATA_FOUND;
      CLOSE C_GET_NO_DATA_FOUND_MSG_CUR;
    END IF;
    RETURN L_NO_DATA_FOUND;
  END CF_NO_DATA_FOUNDFORMULA;
  FUNCTION CF_AWARD_NUMBERFORMULA(TRANSACTION_ID IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN PA_GMS_API.VERT_GET_AWARD_NUMBER(P_EXPENDITURE_ITEM_ID => TRANSACTION_ID);
  END CF_AWARD_NUMBERFORMULA;
END PA_PAXSIADJ_XMLP_PKG;


/
