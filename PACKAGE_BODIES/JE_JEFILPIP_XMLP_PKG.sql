--------------------------------------------------------
--  DDL for Package Body JE_JEFILPIP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_JEFILPIP_XMLP_PKG" AS
/* $Header: JEFILPIPB.pls 120.1 2007/12/25 16:52:45 dwkrishn noship $ */
FUNCTION SQL_PAYMENT_GROUP_1 RETURN BOOLEAN IS
BEGIN
  IF P_PAYMENT_GROUP IS NOT NULL THEN
     IF SUBSTR(P_GROUP_FIELD,1,1)='T' THEN
--        SRW.REFERENCE(:C_COAI);
  /*      SRW.USER_EXIT('FND FLEXSQL
          CODE="GL#"
          NUM=":C_COAI"
          APPL_SHORT_NAME="SQLGL"
          OUTPUT=":SQL_PAYMENT_GROUP"
          MODE="WHERE"
          DISPLAY="GL_ACCOUNT"
          TABLEALIAS="GCC"
          OPERATOR="="
          OPERAND1=":P_PAYMENT_GROUP"');*/
        SQL_PAYMENT_GROUP:='AND '||SQL_PAYMENT_GROUP;
     ELSE
         SQL_PAYMENT_GROUP:=
           'AND I.PAY_GROUP_LOOKUP_CODE='''||P_PAYMENT_GROUP||'''';
     END IF;
  END IF;
  RETURN(TRUE);
END;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('0'
                   ,'The current time is ' || SYSDATE)*/NULL;
      END IF;
      BEGIN
        SELECT
          GSOB.CHART_OF_ACCOUNTS_ID,
          GSOB.SET_OF_BOOKS_ID,
          C.PRECISION,
          C.CURRENCY_CODE
        INTO C_COAI,C_SOB,C_PRECISION,C_FUNCT_CURR
        FROM
          AP_SYSTEM_PARAMETERS ASP,
          GL_SETS_OF_BOOKS GSOB,
          FND_CURRENCIES_VL C
        WHERE ASP.SET_OF_BOOKS_ID = GSOB.SET_OF_BOOKS_ID
          AND ASP.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE INIT_FAILURE;
      END;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After select coai')*/NULL;
      END IF;
      IF (NLS_PARAMETERS = FALSE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After select nls parameters.')*/NULL;
      END IF;
      IF (SQL_PAYMENT_GROUP_1 = FALSE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After sql_payment_group')*/NULL;
      END IF;
      IF (SQL_CURRENCY = FALSE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After sql_currency')*/NULL;
      END IF;
      IF (SQL_VENDOR = FALSE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After sql_vendor')*/NULL;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After sql_only_past')*/NULL;
      END IF;
      IF (SQL_DISTRIBUTIONS_1 = FALSE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After sql_distributions')*/NULL;
      END IF;
      IF (SQL_PAYMENTS = FALSE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After sql_payments')*/NULL;
        /*SRW.BREAK*/NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_INV_OPEN_AMOUNTFORMULA(C_INV_GROSS_AMOUNT IN NUMBER
                                   ,C_INV_PAY_AMOUNT0 IN NUMBER
                                   ,C_INV_DISCOUNT_TAKEN0 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN ((C_INV_GROSS_AMOUNT - C_INV_PAY_AMOUNT0 - NVL((-1) * CP_INVPP_OPEN_AMOUNT
              ,0) - C_INV_DISCOUNT_TAKEN0));
  END C_INV_OPEN_AMOUNTFORMULA;

  FUNCTION C_INV_OPEN_BASEFORMULA(C_INV_OPEN_AMOUNT IN NUMBER
                                 ,EXCHANGE_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN ROUND((C_INV_OPEN_AMOUNT * EXCHANGE_RATE)
                ,C_PRECISION);
  END C_INV_OPEN_BASEFORMULA;

  FUNCTION C_CUR_OPEN_AMOUNTFORMULA(C_CUR_GROSS_AMOUNT IN NUMBER
                                   ,C_CUR_PAY_AMOUNT IN NUMBER
                                   ,C_CUR_DISCOUNT_TAKEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_CUR_GROSS_AMOUNT - C_CUR_PAY_AMOUNT - C_CUR_DISCOUNT_TAKEN);
  END C_CUR_OPEN_AMOUNTFORMULA;

  FUNCTION C_CUR_OPEN_BASEFORMULA(C_CUR_OPEN_AMOUNT IN NUMBER
                                 ,EXCHANGE_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_CUR_OPEN_AMOUNT * EXCHANGE_RATE);
  END C_CUR_OPEN_BASEFORMULA;

  FUNCTION C_GRP_OPEN_BASEFORMULA(C_GRP_GROSS_BASE IN NUMBER
                                 ,C_GRP_PAY_BASE IN NUMBER
                                 ,C_GRP_DISCOUNT_TAKEN_BASE IN NUMBER
                                 ,C_GRP_GAINLOSS IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_GRP_GROSS_BASE - C_GRP_PAY_BASE - C_GRP_DISCOUNT_TAKEN_BASE + C_GRP_GAINLOSS);
  END C_GRP_OPEN_BASEFORMULA;

  FUNCTION C_VEN_OPEN_AMOUNTFORMULA(C_VEN_GROSS_AMOUNT IN NUMBER
                                   ,C_VEN_PAY_AMOUNT IN NUMBER
                                   ,C_VEN_DISCOUNT_TAKEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_VEN_GROSS_AMOUNT - C_VEN_PAY_AMOUNT - C_VEN_DISCOUNT_TAKEN);
  END C_VEN_OPEN_AMOUNTFORMULA;

  FUNCTION C_VEN_OPEN_BASEFORMULA(C_VEN_OPEN_AMOUNT IN NUMBER
                                 ,EXCHANGE_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_VEN_OPEN_AMOUNT * EXCHANGE_RATE);
  END C_VEN_OPEN_BASEFORMULA;

  FUNCTION C_RPT_OPEN_BASEFORMULA(C_RPT_INV_BASE IN NUMBER
                                 ,C_RPT_PAY_BASE IN NUMBER
                                 ,C_RPT_DISCOUNT_TAKEN_BASE IN NUMBER
                                 ,C_RPT_GAINLOSS IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_RPT_INV_BASE - C_RPT_PAY_BASE - C_RPT_DISCOUNT_TAKEN_BASE + C_RPT_GAINLOSS);
  END C_RPT_OPEN_BASEFORMULA;

  FUNCTION C_VENDOR_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      APU2 PO_VENDORS.VENDOR_NAME%TYPE;
    BEGIN
      SELECT
        SEGMENT1 || '  ' || VENDOR_NAME
      INTO APU2
      FROM
        PO_VENDORS
      WHERE VENDOR_ID = NVL(P_VENDOR_ID
         ,-1);
      RETURN (APU2);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (C_ALL);
    END;
    RETURN NULL;
  END C_VENDOR_NAMEFORMULA;

  FUNCTION C_FLEXPROMPTFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_GROUP VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO L_GROUP
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'JEFI_LPIP_GROUP'
        AND LOOKUP_CODE = P_GROUP_FIELD;
      RETURN (L_GROUP);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('');
    END;
    RETURN NULL;
  END C_FLEXPROMPTFORMULA;

  FUNCTION C_SOB_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      APU VARCHAR2(40);
    BEGIN
      SELECT
        GSOB.NAME
      INTO APU
      FROM
        GL_SETS_OF_BOOKS GSOB,
        AP_SYSTEM_PARAMETERS SP
      WHERE GSOB.SET_OF_BOOKS_ID = SP.SET_OF_BOOKS_ID;
      RETURN (APU);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('*ERROR*');
    END;
    RETURN NULL;
  END C_SOB_NAMEFORMULA;

  FUNCTION SQL_CURRENCY RETURN BOOLEAN IS
  BEGIN
    IF P_INVOICE_CURRENCY IS NOT NULL THEN
      SQL_INVOICE_CURRENCY := 'and i.invoice_currency_code=''' || P_INVOICE_CURRENCY || '''';
    ELSE
      SQL_INVOICE_CURRENCY := ' ';
    END IF;
    RETURN (TRUE);
  END SQL_CURRENCY;

  FUNCTION SQL_VENDOR RETURN BOOLEAN IS
  BEGIN
    IF P_VENDOR_ID IS NOT NULL THEN
      SQL_VENDOR_ID := 'and i.vendor_id=' || TO_CHAR(P_VENDOR_ID);
    ELSE
       SQL_VENDOR_ID := ' ';
    END IF;
    RETURN (TRUE);
  END SQL_VENDOR;

  FUNCTION SQL_DISTRIBUTIONS_1 RETURN BOOLEAN IS
    ENCUMBRANCE_FLAG VARCHAR2(1);
  BEGIN
    SELECT
      PURCH_ENCUMBRANCE_FLAG
    INTO ENCUMBRANCE_FLAG
    FROM
      FINANCIALS_SYSTEM_PARAMETERS;
    IF P_MATCH_STATUS_FLAG = 'A' THEN
      SQL_DISTRIBUTIONS := 'and not exists' || '((select aid1.invoice_id from ap_invoice_distributions aid1' || '  where aid1.invoice_id = id.invoice_id';
      IF NVL(ENCUMBRANCE_FLAG,'N') = 'Y' THEN
        SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || '  and   nvl(aid1.match_status_flag,''N'') <> ''A'') ';
      END IF;
      IF NVL(ENCUMBRANCE_FLAG
         ,'N') = 'N' THEN
        SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || '  AND   nvl(aid1.match_status_flag,''N'') not in (''A'', ''T'')) ';
      END IF;
      SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || '  UNION' || ' (select aih1.invoice_id from ap_holds aih1' || '  where aih1.invoice_id = id.invoice_id'
      || '  and aih1.release_lookup_code is null))' || 'and exists' || '(select null from ap_invoice_distributions aid2' || ' where aid2.invoice_id = id.invoice_id)';
    END IF;
    IF P_MATCH_STATUS_FLAG = 'N' THEN
      SQL_DISTRIBUTIONS := 'and exists' || '((select aid2.invoice_id from ap_invoice_distributions aid2' || '  where aid2.invoice_id = id.invoice_id';
      IF NVL(ENCUMBRANCE_FLAG,'N') = 'Y' THEN
        SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || '  and   nvl(aid2.match_status_flag,''N'') <> ''A'')';
      END IF;
      IF NVL(ENCUMBRANCE_FLAG
         ,'N') = 'N' THEN
        SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || '  AND   nvl(aid2.match_status_flag,''N'') not in (''A'', ''T'')) ';
      END IF;
      SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || '  UNION' || ' (select aih2.invoice_id from ap_holds aih2' || '  where aih2.invoice_id = id.invoice_id' || '  and aih2.release_lookup_code is null))';
    END IF;
    IF P_INV_POSTED_FLAG IS NOT NULL THEN
      SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || 'and nvl(ach1.gl_transfer_status_code,''N'')=''' || P_INV_POSTED_FLAG || ''' ';
    END IF;
    IF P_CUT_DATE IS NOT NULL THEN
      SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || 'and trunc(nvl(id.accounting_date,sysdate))<=''' || TO_CHAR(P_CUT_DATE) || ''' ';
    END IF;
    IF P_INVOICE_PERIOD IS NOT NULL THEN
      SQL_DISTRIBUTIONS := SQL_DISTRIBUTIONS || 'and id.period_name=''' || P_INVOICE_PERIOD || '''';
    ELSE
      SQL_DISTRIBUTIONS :=' ';
    END IF;
    RETURN (TRUE);
  END SQL_DISTRIBUTIONS_1;

  FUNCTION SQL_PAYMENTS RETURN BOOLEAN IS
    L_START_DATE DATE;
    L_CLEARING VARCHAR2(30);
    L_SQL_PAY2_SUB VARCHAR2(1000);
  BEGIN
    IF P_CUT_DATE IS NULL THEN
      CP_CUT_DATE := SYSDATE;
    END IF;
    SQL_PAYMENTS1 := ' ';
    SQL_PAYMENTS2 := ' ';
    SQL_PAYMENTS3 := ' ';
    SQL_PAYMENTS_FDP := ' ';
    IF P_ONLY_OPEN_INVOICES = 'N' AND P_ONLY_PAID_INVOICES = 'N' THEN
      P_ONLY_OPEN_INVOICES := 'Y';
    END IF;
    IF P_PAYMENT_PERIOD IS NOT NULL THEN
      SQL_PAYMENTS2 := SQL_PAYMENTS2 || 'and ip.period_name=''' || P_PAYMENT_PERIOD || ''' ';
      CP_ONLY_PAID_INVOICES := 'Y';
      P_ONLY_OPEN_INVOICES := 'N';
    END IF;
    IF P_CHECK_VOUCHER IS NOT NULL THEN
      SQL_PAYMENTS2 := SQL_PAYMENTS2 || 'and c.doc_sequence_value=''' || P_CHECK_VOUCHER || ''' ';
      CP_ONLY_PAID_INVOICES := 'Y';
      P_ONLY_OPEN_INVOICES := 'N';
    END IF;
    IF P_CHECKRUN_NAME IS NOT NULL THEN
      SQL_PAYMENTS2 := SQL_PAYMENTS2 || 'and c.checkrun_name=''' || P_CHECKRUN_NAME || ''' ';
      CP_ONLY_PAID_INVOICES := 'Y';
      P_ONLY_OPEN_INVOICES := 'N';
    END IF;
    L_SQL_PAY2_SUB := SQL_PAYMENTS2;
    SELECT
      NVL(WHEN_TO_ACCOUNT_PMT
         ,'X')
    INTO L_CLEARING
    FROM
      AP_SYSTEM_PARAMETERS;
    IF L_CLEARING = 'CLEARING ONLY' THEN
      SQL_PAYMENTS2 := SQL_PAYMENTS2 || 'and trunc(c.cleared_date)<=''' || TO_CHAR(P_CUT_DATE) || ''' ';
    ELSE
      IF P_CONFIRMED = 'N' THEN
        SQL_PAYMENTS2 := SQL_PAYMENTS2 || 'and (trunc(c.cleared_date)>''' || TO_CHAR(P_CUT_DATE) || ''' or c.cleared_date is null) ';
      ELSIF P_CONFIRMED = 'Y' THEN
        SQL_PAYMENTS2 := SQL_PAYMENTS2 || 'and trunc(c.cleared_date)<=''' || TO_CHAR(P_CUT_DATE) || ''' ';
      ELSIF P_CONFIRMED IS NULL THEN
        SQL_PAYMENTS2 := SQL_PAYMENTS2 || 'and (trunc(ip.accounting_date)<=''' || TO_CHAR(P_CUT_DATE) || ''' or to_char(ip.accounting_date,''DD-MM-YYYY'')=''31-12-2099'') ';
      END IF;
    END IF;
    IF P_PAY_POSTED_FLAG IS NOT NULL THEN
      SQL_PAYMENTS2 := SQL_PAYMENTS2 || 'and nvl(ach.gl_transfer_status_code,''N'')=''' || P_PAY_POSTED_FLAG || ''' ';
    END IF;
    IF P_ONLY_PAID_INVOICES = 'Y' AND P_ONLY_OPEN_INVOICES = 'N' THEN
      SQL_PAYMENTS1 := SQL_PAYMENTS1 || 'and exists (select null from ap_invoice_payments ip, ap_checks c  where i.invoice_id=ip.invoice_id and ip.check_id=c.check_id and c.void_date is null ' || SQL_PAYMENTS2 || ')';
      SQL_PAYMENTS3 := SQL_PAYMENTS3 || 'and exists (select null from ap_invoice_payments ip, ap_checks c, xla_transaction_entities aae, xla_ae_headers ach, xla_events xev ' || ' where ps.invoice_id=ip.invoice_id and
      ps.payment_num=ip.payment_num and ' || ' c.check_id = aae.source_id_int_1(+) and aae.ENTITY_CODE = ''AP_PAYMENTS'' and aae.ENTITY_ID = ach.ENTITY_ID and ' || ' xev.ENTITY_ID = aae.ENTITY_ID and xev.EVENT_TYPE_CODE
      in (''PAYMENT CREATED'', ''PAYMENT CLEARED'', ''REFUND RECORDED'') and ' || ' ip.check_id=c.check_id and c.void_date is null ' || SQL_PAYMENTS2 || ')';
    END IF;
    IF P_ONLY_OPEN_INVOICES = 'Y' AND P_ONLY_PAID_INVOICES = 'Y' THEN
      SELECT
        TRUNC(START_DATE)
      INTO L_START_DATE
      FROM
        GL_PERIOD_STATUSES
      WHERE APPLICATION_ID = 200
        AND NVL(ADJUSTMENT_PERIOD_FLAG
         ,'N') = 'N'
        AND TRUNC(P_CUT_DATE) between START_DATE
        AND END_DATE
        AND SET_OF_BOOKS_ID = C_SOB;
      SQL_PAYMENTS1 := SQL_PAYMENTS1 || 'and (exists (' || 'select null from ap_payment_schedules ps where ps.invoice_id=i.invoice_id ' || 'and (nvl(ps.amount_remaining,0)<>0 or ' || 'not exists
      (select null from ap_invoice_payments ip, ap_checks c, xla_transaction_entities aae, xla_ae_headers ach, xla_events xev ' || 'where ip.invoice_id=i.invoice_id and ps.payment_num=ip.payment_num and ip.check_id=c.check_id and
      c.void_date is null ' || 'and c.check_id = aae.source_id_int_1(+) and aae.ENTITY_CODE = ''AP_PAYMENTS'' and aae.ENTITY_ID = ach.ENTITY_ID ' || 'and xev.ENTITY_ID = aae.ENTITY_ID and xev.EVENT_TYPE_CODE in
      (''PAYMENT CREATED'', ''PAYMENT CLEARED'', ''REFUND RECORDED'') ' || SQL_PAYMENTS2 || ')))' || 'or exists (select null from ap_invoice_payments ip, ap_checks c ' || '           where i.invoice_id=ip.invoice_id
      and ip.check_id=c.check_id and c.void_date is null ' || '             and trunc(ip.accounting_date) >=''' || TO_CHAR(L_START_DATE) || '''' || '             and trunc(ip.accounting_date) <=''' || TO_CHAR(P_CUT_DATE) || '''))';

      SQL_PAYMENTS3 := SQL_PAYMENTS3 || 'and ( nvl(ps.amount_remaining,0)<>0 or ' || '(not exists (select null from ap_invoice_payments ip, ap_checks c, xla_transaction_entities aae, xla_ae_headers ach, xla_events xev ' || 'where
      ip.invoice_id=ps.invoice_id and ps.payment_num=ip.payment_num and ip.check_id=c.check_id and c.void_date is null ' || 'and c.check_id = aae.source_id_int_1(+) and aae.ENTITY_CODE = ''AP_PAYMENTS'' and
      aae.ENTITY_ID = ach.ENTITY_ID ' || 'and xev.ENTITY_ID = aae.ENTITY_ID and xev.EVENT_TYPE_CODE in (''PAYMENT CREATED'', ''PAYMENT CLEARED'', ''REFUND RECORDED'') ' || SQL_PAYMENTS2 || ') AND ' || 'not exists
      (select null from ap_invoice_distributions id, ap_invoice_distributions ppd, ap_invoices pp' || ', ap_payment_schedules ppps, ap_invoice_payments ppip, ap_checks c ' || 'where id.invoice_id = ps.invoice_id
      and id.line_type_lookup_code = ''PREPAY''
      and id.PREPAY_DISTRIBUTION_ID = ppd.INVOICE_DISTRIBUTION_ID ' || 'and ppd.invoice_id = pp.invoice_id and pp.invoice_type_lookup_code = ''PREPAYMENT'' and pp.invoice_id = ppip.invoice_id ' || 'and ppps.invoice_id = pp.invoice_id and
      ppps.payment_num = ppip.payment_num and ppip.check_id = c.check_id ' || 'and c.void_date is null ' || L_SQL_PAY2_SUB || ') ) ' || 'or exists (select null from ap_invoice_payments ip, ap_checks c ' || '           where
      ps.invoice_id=ip.invoice_id and ip.check_id=c.check_id and c.void_date is null and ps.payment_num=ip.payment_num ' || '             and trunc(ip.accounting_date) >=''' || TO_CHAR(L_START_DATE) || '''' || '
      and trunc(ip.accounting_date) <=''' || TO_CHAR(P_CUT_DATE) || ''') ' || 'or exists (select null from ap_invoice_distributions id, ap_invoice_distributions ppd, ap_invoices pp' || ', ap_payment_schedules ppps,
      ap_invoice_payments ppip, ap_checks c ' || 'where id.invoice_id = ps.invoice_id and id.line_type_lookup_code = ''PREPAY'' and id.PREPAY_DISTRIBUTION_ID = ppd.INVOICE_DISTRIBUTION_ID ' || 'and ppd.invoice_id = pp.invoice_id
      and pp.invoice_type_lookup_code = ''PREPAYMENT'' and pp.invoice_id = ppip.invoice_id ' || 'and ppps.invoice_id = pp.invoice_id and ppps.payment_num = ppip.payment_num and ppip.check_id = c.check_id ' || 'and c.void_date is null
      and trunc(id.accounting_date) >=''' || TO_CHAR(L_START_DATE) || '''' || '                        and trunc(id.accounting_date) <=''' || TO_CHAR(P_CUT_DATE) || ''')) ';

      SQL_PAYMENTS_FDP := SQL_PAYMENTS_FDP || 'and ( nvl(ps.amount_remaining,0)<>0 or ' || '(not exists (select null from ap_invoice_payments ip, ap_checks c, xla_transaction_entities aae,
      xla_ae_headers ach, xla_events xev ' || 'where ip.invoice_id=ps.invoice_id and ps.payment_num=ip.payment_num and ip.check_id=c.check_id and c.void_date is null ' || 'and c.check_id = aae.source_id_int_1(+)
      and aae.ENTITY_CODE = ''AP_PAYMENTS'' and aae.ENTITY_ID = ach.ENTITY_ID ' || 'and xev.ENTITY_ID = aae.ENTITY_ID and xev.EVENT_TYPE_CODE in (''PAYMENT CREATED'', ''PAYMENT CLEARED'', ''REFUND RECORDED'') ' ||
      SQL_PAYMENTS2 || ') AND ' || 'not exists (select null from ap_invoice_distributions id, ap_invoice_distributions ppd, ap_invoices pp' || ', ap_payment_schedules ppps, ap_invoice_payments ppip, ap_checks c ' ||
      'where id.invoice_id = ps.invoice_id and id.line_type_lookup_code = ''PREPAY'' and id.PREPAY_DISTRIBUTION_ID = ppd.INVOICE_DISTRIBUTION_ID ' || 'and ppd.invoice_id = pp.invoice_id and pp.invoice_type_lookup_code = ''PREPAYMENT''
      and pp.invoice_id = ppip.invoice_id ' || 'and ppps.invoice_id = pp.invoice_id and ppps.payment_num = ppip.payment_num and ppip.check_id = c.check_id ' || 'and c.void_date is null ' || L_SQL_PAY2_SUB || ')) ' ||
      'or exists (select null from ap_invoice_payments ip, ap_checks c ' || '           where ps.invoice_id=ip.invoice_id and ip.check_id=c.check_id and c.void_date is null and ps.payment_num=ip.payment_num ' || '
      and trunc(ip.accounting_date) <=''' || TO_CHAR(P_CUT_DATE) || '''' || '             and c.future_pay_due_date is not null ' || '             and c.status_lookup_code = ''ISSUED'')) ';

    END IF;
    IF P_ONLY_OPEN_INVOICES = 'Y' AND P_ONLY_PAID_INVOICES = 'N' THEN
      SQL_PAYMENTS1 := SQL_PAYMENTS1 || 'and (exists (' || 'select null from ap_payment_schedules ps where ps.invoice_id=i.invoice_id ' || 'and (nvl(ps.amount_remaining,0)<>0 or ' ||
      'not exists (select null from ap_invoice_payments ip, ap_checks c, xla_transaction_entities aae, xla_ae_headers ach, xla_events xev ' || 'where ip.invoice_id=i.invoice_id and
      ps.payment_num=ip.payment_num and ip.check_id=c.check_id and c.void_date is null ' || 'and c.check_id = aae.source_id_int_1(+) and aae.ENTITY_CODE = ''AP_PAYMENTS'' and
      aae.ENTITY_ID = ach.ENTITY_ID ' || 'and xev.ENTITY_ID = aae.ENTITY_ID and xev.EVENT_TYPE_CODE in (''PAYMENT CREATED'', ''PAYMENT CLEARED'', ''REFUND RECORDED'') ' || SQL_PAYMENTS2 || '))))';

      SQL_PAYMENTS3 := SQL_PAYMENTS3 || 'and ( nvl(ps.amount_remaining,0)<>0 or ' || '(not exists (select null from ap_invoice_payments ip, ap_checks c, xla_transaction_entities aae, xla_ae_headers ach,
      xla_events xev ' || 'where ip.invoice_id=ps.invoice_id and ps.payment_num=ip.payment_num and ip.check_id=c.check_id and c.void_date is null ' || 'and c.check_id = aae.source_id_int_1(+) and
      aae.ENTITY_CODE = ''AP_PAYMENTS'' and aae.ENTITY_ID = ach.ENTITY_ID ' || 'and xev.ENTITY_ID = aae.ENTITY_ID and xev.EVENT_TYPE_CODE in (''PAYMENT CREATED'', ''PAYMENT CLEARED'', ''REFUND RECORDED'') ' || SQL_PAYMENTS2
      || ') AND ' || ' not exists (select null from ap_invoice_distributions id, ap_invoice_distributions ppd, ap_invoices pp' || ', ap_payment_schedules ppps, ap_invoice_payments ppip, ap_checks c ' || 'where id.invoice_id = ps.invoice_id
      and id.line_type_lookup_code = ''PREPAY'' and id.PREPAY_DISTRIBUTION_ID = ppd.INVOICE_DISTRIBUTION_ID ' || 'and ppd.invoice_id = pp.invoice_id and pp.invoice_type_lookup_code = ''PREPAYMENT'' and pp.invoice_id = ppip.invoice_id ' ||
      'and ppps.invoice_id = pp.invoice_id and ppps.payment_num = ppip.payment_num and ppip.check_id = c.check_id ' || 'and c.void_date is null ' || L_SQL_PAY2_SUB || ')) )';

    END IF;
    IF (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE(102
                 ,'SQL Payments 2 sub: ' || L_SQL_PAY2_SUB)*/NULL;
      /*SRW.MESSAGE(103
                 ,'SQL Payments 2: ' || SQL_PAYMENTS2)*/NULL;
      /*SRW.MESSAGE(100
                 ,'--------------------')*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,1
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,251
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,501
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,751
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,1001
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,1251
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,1501
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,1751
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,2001
                       ,250))*/NULL;
      /*SRW.MESSAGE(104
                 ,'SQL Payments 3: ' || SUBSTR(SQL_PAYMENTS3
                       ,2251
                       ,250))*/NULL;
      /*SRW.MESSAGE(100
                 ,'--------------------')*/NULL;
      /*SRW.MESSAGE(106
                 ,'SQL Payments FDP: ' || SUBSTR(SQL_PAYMENTS_FDP
                       ,1
                       ,250))*/NULL;
      /*SRW.MESSAGE(106
                 ,'SQL Payments FDP: ' || SUBSTR(SQL_PAYMENTS_FDP
                       ,251
                       ,250))*/NULL;
      /*SRW.MESSAGE(106
                 ,'SQL Payments FDP: ' || SUBSTR(SQL_PAYMENTS_FDP
                       ,501
                       ,250))*/NULL;
      /*SRW.MESSAGE(106
                 ,'SQL Payments FDP: ' || SUBSTR(SQL_PAYMENTS_FDP
                       ,751
                       ,250))*/NULL;
      /*SRW.MESSAGE(106
                 ,'SQL Payments FDP: ' || SUBSTR(SQL_PAYMENTS_FDP
                       ,1001
                       ,250))*/NULL;
      /*SRW.MESSAGE(106
                 ,'SQL Payments FDP: ' || SUBSTR(SQL_PAYMENTS_FDP
                       ,1251
                       ,250))*/NULL;
      /*SRW.MESSAGE(106
                 ,'SQL Payments FDP: ' || SUBSTR(SQL_PAYMENTS_FDP
                       ,1501
                       ,250))*/NULL;
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (FALSE);
  END SQL_PAYMENTS;

  FUNCTION C_BAL_FACTORFORMULA(DIST_BASE_AMOUNT IN NUMBER
                              ,P_INVOICE_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      DIST_TOTAL NUMBER;
    BEGIN
      IF (DIST_BASE_AMOUNT IS NOT NULL) THEN
        BEGIN
          SELECT
            SUM(NVL(BASE_AMOUNT
                   ,AMOUNT))
          INTO DIST_TOTAL
          FROM
            AP_INVOICE_DISTRIBUTIONS
          WHERE INVOICE_ID = P_INVOICE_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            DIST_TOTAL := DIST_BASE_AMOUNT;
        END;
        IF (DIST_TOTAL <> 0) THEN
          RETURN (DIST_BASE_AMOUNT / DIST_TOTAL);
        ELSE
          RETURN (1);
        END IF;
      ELSE
        RETURN (1);
      END IF;
    END;
    RETURN NULL;
  END C_BAL_FACTORFORMULA;

  FUNCTION C_INV_GROSS_BASEFORMULA(CANCELLED_DATE IN DATE
                                  ,C_INV_GROSS_BASE0 IN NUMBER
                                  ,CANCELLED_AMOUNT IN NUMBER
                                  ,EXCHANGE_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(CANCELLED_DATE
       ,P_CUT_DATE) > P_CUT_DATE THEN
      RETURN (C_INV_GROSS_BASE0 + ROUND(CANCELLED_AMOUNT * EXCHANGE_RATE
                  ,C_PRECISION));
    ELSE
      RETURN (C_INV_GROSS_BASE0);
    END IF;
    RETURN NULL;
  END C_INV_GROSS_BASEFORMULA;

  FUNCTION C_INV_GROSS_AMOUNTFORMULA(CANCELLED_DATE IN DATE
                                    ,C_INV_GROSS_AMOUNT1 IN NUMBER
                                    ,CANCELLED_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(CANCELLED_DATE
       ,P_CUT_DATE) > P_CUT_DATE THEN
      RETURN (C_INV_GROSS_AMOUNT1 + CANCELLED_AMOUNT);
    ELSE
      RETURN (C_INV_GROSS_AMOUNT1);
    END IF;
    RETURN NULL;
  END C_INV_GROSS_AMOUNTFORMULA;

  FUNCTION C_INV_PAY_BASEFORMULA(P_INVOICE_ID IN NUMBER
                                ,C_INV_PAY_BASE0 IN NUMBER) RETURN NUMBER IS
    L_PREPAY_AMT NUMBER := 0;
    L_CLEARING VARCHAR2(40);
    L_START_DATE DATE;
  BEGIN
    SELECT
      TRUNC(START_DATE)
    INTO L_START_DATE
    FROM
      GL_PERIOD_STATUSES
    WHERE APPLICATION_ID = 200
      AND NVL(ADJUSTMENT_PERIOD_FLAG
       ,'N') = 'N'
      AND TRUNC(P_CUT_DATE) between START_DATE
      AND END_DATE
      AND SET_OF_BOOKS_ID = C_SOB;
    SELECT
      SUM(PREPAY_AMT),
      SUM(INVPP_OPEN_AMOUNT),
      MAX(INVPP_GL_DATE)
    INTO L_PREPAY_AMT,CP_INVPP_OPEN_AMOUNT,CP_INVPP_GL_DATE
    FROM
      (   SELECT
          SUM(NVL(ID.BASE_AMOUNT
                 ,ID.AMOUNT)) PREPAY_AMT,
          SUM(ID.AMOUNT) INVPP_OPEN_AMOUNT,
          MAX(ID.ACCOUNTING_DATE) INVPP_GL_DATE
        FROM
          AP_INVOICE_DISTRIBUTIONS_ALL ID,
          AP_INVOICE_DISTRIBUTIONS_ALL PPD,
          AP_INVOICES_ALL PP
        WHERE ID.INVOICE_ID = P_INVOICE_ID
          AND ( ( ID.LINE_TYPE_LOOKUP_CODE = 'PREPAY'
          AND ID.PREPAY_DISTRIBUTION_ID = PPD.INVOICE_DISTRIBUTION_ID ) )
          AND PPD.INVOICE_ID = PP.INVOICE_ID
          AND PP.INVOICE_TYPE_LOOKUP_CODE = 'PREPAYMENT'
          AND TRUNC(ID.ACCOUNTING_DATE) between L_START_DATE
          AND P_CUT_DATE
        UNION
        SELECT
          SUM(NVL(ID.BASE_AMOUNT
                 ,ID.AMOUNT)) PREPAY_AMT,
          SUM(ID.AMOUNT) INVPP_OPEN_AMOUNT,
          MAX(ID.ACCOUNTING_DATE) INVPP_GL_DATE
        FROM
          AP_INVOICE_DISTRIBUTIONS_ALL ID,
          AP_INVOICE_DISTRIBUTIONS_ALL PPD,
          AP_INVOICE_DISTRIBUTIONS_ALL AID,
          AP_INVOICES_ALL PP
        WHERE ID.INVOICE_ID = P_INVOICE_ID
          AND ID.LINE_TYPE_LOOKUP_CODE = 'TAX'
          AND AID.LINE_TYPE_LOOKUP_CODE = 'PREPAY'
          AND ID.PREPAY_TAX_PARENT_ID = AID.INVOICE_DISTRIBUTION_ID
          AND AID.PREPAY_DISTRIBUTION_ID = PPD.INVOICE_DISTRIBUTION_ID
          AND PPD.INVOICE_ID = PP.INVOICE_ID
          AND PP.INVOICE_TYPE_LOOKUP_CODE = 'PREPAYMENT'
          AND TRUNC(ID.ACCOUNTING_DATE) between L_START_DATE
          AND P_CUT_DATE );
    RETURN (NVL(C_INV_PAY_BASE0
              ,0) - NVL(L_PREPAY_AMT
              ,0));
  EXCEPTION
    WHEN OTHERS THEN
      CP_INVPP_GL_DATE := TO_DATE('1952/01/01'
                                 ,'YYYY/MM/DD');
      RETURN (C_INV_PAY_BASE0);
  END C_INV_PAY_BASEFORMULA;

  FUNCTION C_INV_GAINLOSSFORMULA(C_INV_GAINLOSS0 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_INV_GAINLOSS0);
  END C_INV_GAINLOSSFORMULA;

  FUNCTION C_INV_DISCOUNT_TAKEN_BASEFORMU(C_INV_DISC_TAKEN_BASE0 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_INV_DISC_TAKEN_BASE0);
  END C_INV_DISCOUNT_TAKEN_BASEFORMU;

  FUNCTION C_INV_DISCOUNT_AVAILABLEFORMUL(C_INV_DISC_AVAIL0 IN NUMBER
                                         ,C_BAL_FACTOR IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_INV_DISC_AVAIL0 * C_BAL_FACTOR);
  END C_INV_DISCOUNT_AVAILABLEFORMUL;

  FUNCTION NLS_PARAMETERS RETURN BOOLEAN IS
    L_SUMMARY VARCHAR2(80);
    L_YES VARCHAR2(80);
    L_NO VARCHAR2(80);
    L_ALL VARCHAR2(80);
    L_APPROVAL_STATUS VARCHAR2(80);
  BEGIN
    SELECT
      MEANING
    INTO L_SUMMARY
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'JEFI_LPIP_SUMMARY_LEVEL'
      AND LOOKUP_CODE = P_SUMMARY_LEVEL;
    C_SUMMARY_LEVEL := L_SUMMARY;
    SELECT
      MEANING
    INTO L_APPROVAL_STATUS
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'JEFI_LPIP_APPROVAL_STATUS'
      AND LOOKUP_CODE = NVL(P_MATCH_STATUS_FLAG
       ,'*');
    C_APPROVAL_STATUS := L_APPROVAL_STATUS;
    SELECT
      MEANING
    INTO L_YES
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO_ALL'
      AND LOOKUP_CODE = 'Y';
    C_YES := L_YES;
    SELECT
      MEANING
    INTO L_NO
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO_ALL'
      AND LOOKUP_CODE = 'N';
    C_NO := L_NO;
    SELECT
      MEANING
    INTO L_ALL
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO_ALL'
      AND LOOKUP_CODE = 'A';
    C_ALL := L_ALL;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (FALSE);
  END NLS_PARAMETERS;

  FUNCTION C_APPROVE_FLAGFORMULA(P_INVOICE_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      A_FLAG FND_LOOKUPS.MEANING%TYPE;
      A_COUNT NUMBER;
    BEGIN
      A_FLAG := C_NO;
      A_COUNT := 0;
      SELECT
        count(*)
      INTO A_COUNT
      FROM
        AP_INVOICE_DISTRIBUTIONS AID
      WHERE AID.INVOICE_ID = P_INVOICE_ID
        AND NVL(AID.MATCH_STATUS_FLAG
         ,'N') <> 'A';
      IF (A_COUNT = 0) THEN
        A_FLAG := C_YES;
      END IF;
      A_COUNT := 0;
      SELECT
        count(*)
      INTO A_COUNT
      FROM
        AP_HOLDS AIH
      WHERE AIH.INVOICE_ID = P_INVOICE_ID
        AND AIH.RELEASE_LOOKUP_CODE is null;
      IF (A_COUNT <> 0) THEN
        A_FLAG := C_NO;
      END IF;
      RETURN (A_FLAG);
    END;
    RETURN NULL;
  END C_APPROVE_FLAGFORMULA;

  FUNCTION CF_CUT_DATEFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(P_CUT_DATE));
  END CF_CUT_DATEFORMULA;

  FUNCTION CF_SYSDATEFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDT(SYSDATE));
  END CF_SYSDATEFORMULA;

  FUNCTION CF_C_INV_DISCOUNT_DATEFORMULA(C_INV_DISCOUNT_DATE IN DATE) RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(C_INV_DISCOUNT_DATE));
  END CF_C_INV_DISCOUNT_DATEFORMULA;

  FUNCTION CF_INV_CHECK_GL_DATEFORMULA(C_INV_CHECK_GL_DATE IN DATE) RETURN CHAR IS
  BEGIN
    IF NVL(C_INV_CHECK_GL_DATE,TO_DATE('1952/01/01','YYYY/MM/DD')) < NVL(CP_INVPP_GL_DATE,TO_DATE('1952/01/01','YYYY/MM/DD')) THEN
      RETURN (FND_DATE.DATE_TO_CHARDATE(CP_INVPP_GL_DATE));
    ELSE
      RETURN (FND_DATE.DATE_TO_CHARDATE(C_INV_CHECK_GL_DATE));
    END IF;
  END CF_INV_CHECK_GL_DATEFORMULA;

  FUNCTION C_SCH_OPEN_AMOUNTFORMULA(GROSS_AMOUNT IN NUMBER
                                   ,C_SCH_PAY_AMOUNT IN NUMBER
                                   ,C_SCH_DISCOUNT_TAKEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (GROSS_AMOUNT - C_SCH_PAY_AMOUNT - C_SCH_DISCOUNT_TAKEN);
  END C_SCH_OPEN_AMOUNTFORMULA;

  FUNCTION C_SCH_OPEN_BASEFORMULA(C_SCH_OPEN_AMOUNT IN NUMBER
                                 ,EXCHANGE_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_SCH_OPEN_AMOUNT * EXCHANGE_RATE);
  END C_SCH_OPEN_BASEFORMULA;

  FUNCTION CP_INV_PAY_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_INV_PAY_AMOUNT;
  END CP_INV_PAY_AMOUNT_P;

  FUNCTION CP_INVPP_OPEN_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_INVPP_OPEN_AMOUNT;
  END CP_INVPP_OPEN_AMOUNT_P;

  FUNCTION CP_INVPP_GL_DATE_P RETURN DATE IS
  BEGIN
    RETURN CP_INVPP_GL_DATE;
  END CP_INVPP_GL_DATE_P;

  FUNCTION C_FLEXDATA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_FLEXDATA;
  END C_FLEXDATA_P;

  FUNCTION SQL_PAYMENT_GROUP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SQL_PAYMENT_GROUP;
  END SQL_PAYMENT_GROUP_P;

  FUNCTION SQL_INVOICE_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SQL_INVOICE_CURRENCY;
  END SQL_INVOICE_CURRENCY_P;

  FUNCTION SQL_VENDOR_ID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SQL_VENDOR_ID;
  END SQL_VENDOR_ID_P;

  FUNCTION SQL_DISTRIBUTIONS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SQL_DISTRIBUTIONS;
  END SQL_DISTRIBUTIONS_P;

  FUNCTION SQL_PAYMENTS2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SQL_PAYMENTS2;
  END SQL_PAYMENTS2_P;

  FUNCTION SQL_PAYMENTS3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SQL_PAYMENTS3;
  END SQL_PAYMENTS3_P;

  FUNCTION C_COAI_P RETURN NUMBER IS
  BEGIN
    RETURN C_COAI;
  END C_COAI_P;

  FUNCTION SQL_PAYMENTS1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SQL_PAYMENTS1;
  END SQL_PAYMENTS1_P;

  FUNCTION C_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TITLE;
  END C_TITLE_P;

  FUNCTION C_SUMMARY_LEVEL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SUMMARY_LEVEL;
  END C_SUMMARY_LEVEL_P;

  FUNCTION C_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_YES;
  END C_YES_P;

  FUNCTION C_APPROVAL_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_APPROVAL_STATUS;
  END C_APPROVAL_STATUS_P;

  FUNCTION C_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NO;
  END C_NO_P;

  FUNCTION C_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ALL;
  END C_ALL_P;

  FUNCTION C_SOB_P RETURN NUMBER IS
  BEGIN
    RETURN C_SOB;
  END C_SOB_P;

  FUNCTION C_HOLD_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_HOLD_FLAG;
  END C_HOLD_FLAG_P;

  FUNCTION C_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN C_PRECISION;
  END C_PRECISION_P;

  FUNCTION C_FUNCT_CURR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_FUNCT_CURR;
  END C_FUNCT_CURR_P;

  FUNCTION SQL_PAYMENTS_FDP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SQL_PAYMENTS_FDP;
  END SQL_PAYMENTS_FDP_P;

END JE_JEFILPIP_XMLP_PKG;




/
