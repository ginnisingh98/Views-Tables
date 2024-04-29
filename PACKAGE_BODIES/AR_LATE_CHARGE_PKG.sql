--------------------------------------------------------
--  DDL for Package Body AR_LATE_CHARGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_LATE_CHARGE_PKG" AS
/* $Header: ARLCDOCB.pls 120.13.12010000.8 2009/04/09 13:16:14 pbapna ship $ */

  g_bulk_fetch_rows                NUMBER := 10000;
  g_func_curr                      VARCHAR2(15);
  g_interest_batch_id              NUMBER;
  g_object_version_number          NUMBER;
  g_org_id                         NUMBER;
  g_BATCH_SOURCE_ID                NUMBER;
  g_int_cal_date                   DATE;

  PG_DEBUG                         VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  -----------
  -- Invoice:
  -----------
  iv_INTEREST_HEADER_ID            DBMS_SQL.NUMBER_TABLE;
  iv_CURRENCY_CODE                 DBMS_SQL.VARCHAR2_TABLE;
  iv_HEADER_TYPE                   DBMS_SQL.VARCHAR2_TABLE;
  iv_cust_trx_type_id              DBMS_SQL.NUMBER_TABLE;
  iv_CUSTOMER_ID                   DBMS_SQL.NUMBER_TABLE;
  iv_CUSTOMER_SITE_USE_ID          DBMS_SQL.NUMBER_TABLE;
  iv_LATE_CHARGE_TERM_ID           DBMS_SQL.NUMBER_TABLE;
  iv_EXCHANGE_RATE_TYPE            DBMS_SQL.VARCHAR2_TABLE;
  iv_EXCHANGE_RATE                 DBMS_SQL.NUMBER_TABLE;
  iv_PAYMENT_SCHEDULE_ID           DBMS_SQL.NUMBER_TABLE;
  iv_org_id                        DBMS_SQL.NUMBER_TABLE;
  iv_legal_entity_id               DBMS_SQL.NUMBER_TABLE;
  iv_interest_line_id              DBMS_SQL.NUMBER_TABLE;
  iv_LATE_CHARGE_CALCULATION_TRX   DBMS_SQL.VARCHAR2_TABLE;
  iv_DAYS_OF_INTEREST              DBMS_SQL.NUMBER_TABLE;
  iv_DAYS_OVERDUE_LATE             DBMS_SQL.NUMBER_TABLE;
  iv_DAILY_INTEREST_CHARGE         DBMS_SQL.NUMBER_TABLE;
  iv_INTEREST_CHARGED              DBMS_SQL.NUMBER_TABLE;
  iv_type                          DBMS_SQL.VARCHAR2_TABLE;
  iv_salesrep_required_flag        DBMS_SQL.VARCHAR2_TABLE;
  iv_salesrep_id                   DBMS_SQL.NUMBER_TABLE;
  iv_salesrep_number               DBMS_SQL.VARCHAR2_TABLE;
  iv_GL_ID_REC                     DBMS_SQL.NUMBER_TABLE;
  iv_GL_ID_REV                     DBMS_SQL.NUMBER_TABLE;
  iv_cpt                           NUMBER := 0;
  iv_salesrep_set                  VARCHAR2(1) := 'N';
  iv_sales_credit_name             VARCHAR2(200);
  iv_sales_credit_id               NUMBER;
  iv_original_trx_id               DBMS_SQL.NUMBER_TABLE;
  iv_original_trx_class            DBMS_SQL.VARCHAR2_TABLE;
  iv_DUE_DATE                      DBMS_SQL.DATE_TABLE;
  iv_OUTSTANDING_AMOUNT            DBMS_SQL.NUMBER_TABLE;
  iv_PAYMENT_DATE                  DBMS_SQL.DATE_TABLE;
  iv_LAST_CHARGE_DATE              DBMS_SQL.DATE_TABLE;
  iv_INTEREST_RATE                 DBMS_SQL.NUMBER_TABLE;

  --------
  -- invoice api
  --------
  iv_trx_header_tbl                ar_invoice_api_pub.trx_header_tbl_type;
  iv_trx_lines_tbl                 ar_invoice_api_pub.trx_line_tbl_type;
  iv_trx_dist_tbl                  ar_invoice_api_pub.trx_dist_tbl_type;
  iv_trx_salescredits_tbl          ar_invoice_api_pub.trx_salescredits_tbl_type;
  iv_batch_source_rec              ar_invoice_api_pub.batch_source_rec_type;
  iv_create_flag                   VARCHAR2(1) := 'N';
  iv_header_cpt                    NUMBER := 0;
  iv_line_cpt                      NUMBER := 0;
  iv_dist_cpt                      NUMBER := 0;
  iv_salescredits_cpt              NUMBER := 0;
  iv_curr_header_id                NUMBER := 0;
  iv_line_num                      NUMBER := 0;



  -------------
  -- Recycle
  -------------
  nl_trx_header_tbl                ar_invoice_api_pub.trx_header_tbl_type;
  nl_trx_lines_tbl                 ar_invoice_api_pub.trx_line_tbl_type;
  nl_trx_dist_tbl                  ar_invoice_api_pub.trx_dist_tbl_type;
  nl_trx_salescredits_tbl          ar_invoice_api_pub.trx_salescredits_tbl_type;
  nl_batch_source_rec              ar_invoice_api_pub.batch_source_rec_type;
  nl_INTEREST_HEADER_ID            DBMS_SQL.NUMBER_TABLE;
  nl_CURRENCY_CODE                 DBMS_SQL.VARCHAR2_TABLE;
  nl_HEADER_TYPE                   DBMS_SQL.VARCHAR2_TABLE;
  nl_cust_trx_type_id              DBMS_SQL.NUMBER_TABLE;
  nl_CUSTOMER_ID                   DBMS_SQL.NUMBER_TABLE;
  nl_CUSTOMER_SITE_USE_ID          DBMS_SQL.NUMBER_TABLE;
  nl_LATE_CHARGE_TERM_ID           DBMS_SQL.NUMBER_TABLE;
  nl_EXCHANGE_RATE_TYPE            DBMS_SQL.VARCHAR2_TABLE;
  nl_EXCHANGE_RATE                 DBMS_SQL.NUMBER_TABLE;
  nl_PAYMENT_SCHEDULE_ID           DBMS_SQL.NUMBER_TABLE;
  nl_org_id                        DBMS_SQL.NUMBER_TABLE;
  nl_legal_entity_id               DBMS_SQL.NUMBER_TABLE;
  nl_interest_line_id              DBMS_SQL.NUMBER_TABLE;
  nl_LATE_CHARGE_CALCULATION_TRX   DBMS_SQL.VARCHAR2_TABLE;
  nl_DAYS_OF_INTEREST              DBMS_SQL.NUMBER_TABLE;
  nl_DAYS_OVERDUE_LATE             DBMS_SQL.NUMBER_TABLE;
  nl_DAILY_INTEREST_CHARGE         DBMS_SQL.NUMBER_TABLE;
  nl_INTEREST_CHARGED              DBMS_SQL.NUMBER_TABLE;
  nl_type                          DBMS_SQL.VARCHAR2_TABLE;
  nl_salesrep_required_flag        DBMS_SQL.VARCHAR2_TABLE;
  nl_salesrep_id                   DBMS_SQL.NUMBER_TABLE;
  nl_salesrep_number               DBMS_SQL.VARCHAR2_TABLE;
  nl_GL_ID_REC                     DBMS_SQL.NUMBER_TABLE;
  nl_GL_ID_REV                     DBMS_SQL.NUMBER_TABLE;
  nl_original_trx_id               DBMS_SQL.NUMBER_TABLE;
  nl_original_trx_class            DBMS_SQL.VARCHAR2_TABLE;
  nl_DUE_DATE                      DBMS_SQL.DATE_TABLE;
  nl_OUTSTANDING_AMOUNT            DBMS_SQL.NUMBER_TABLE;
  nl_PAYMENT_DATE                  DBMS_SQL.DATE_TABLE;
  nl_LAST_CHARGE_DATE              DBMS_SQL.DATE_TABLE;
  nl_INTEREST_RATE                 DBMS_SQL.NUMBER_TABLE;



  PROCEDURE log(
    message       IN VARCHAR2,
    newline       IN BOOLEAN DEFAULT TRUE) IS
  BEGIN
    IF message = 'NEWLINE' THEN
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
    ELSIF (newline) THEN
      FND_FILE.put_line(fnd_file.log,message);
    ELSE
      FND_FILE.put(fnd_file.log,message);
    END IF;
    IF  PG_DEBUG = 'Y' THEN
       ARP_STANDARD.DEBUG(message);
    END IF;
  END log;



  PROCEDURE out(
    message      IN      VARCHAR2,
    newline      IN      BOOLEAN DEFAULT TRUE) IS
  BEGIN
    IF message = 'NEWLINE' THEN
     FND_FILE.NEW_LINE(FND_FILE.output, 1);
    ELSIF (newline) THEN
      FND_FILE.put_line(fnd_file.output,message);
    ELSE
      FND_FILE.put(fnd_file.output,message);
    END IF;
  END out;



  PROCEDURE outandlog(
    message      IN      VARCHAR2,
    newline      IN      BOOLEAN DEFAULT TRUE) IS
  BEGIN
    out(message, newline);
    log(message, newline);
  END outandlog;




  FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2 IS
    l_msg_data VARCHAR2(2000);
  BEGIN
    FND_MSG_PUB.Reset;

    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
    END LOOP;
    IF (SQLERRM IS NOT NULL) THEN
      l_msg_data := l_msg_data || SQLERRM;
    END IF;
    log(l_msg_data);
    RETURN l_msg_data;
  END logerror;






FUNCTION get_lookup_desc (p_lookup_type  IN VARCHAR2,
                          p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2 IS
l_description   VARCHAR2(240);
l_hash_value    NUMBER;
BEGIN
  IF p_lookup_code IS NOT NULL AND
     p_lookup_type IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         p_lookup_type||'@*?'||p_lookup_code,
                                         1000,
                                         25000);

    IF pg_ar_lookups_desc_rec.EXISTS(l_hash_value) THEN
        l_description := pg_ar_lookups_desc_rec(l_hash_value);
    ELSE

     SELECT description
       INTO l_description
       FROM ar_lookups
      WHERE lookup_type = p_lookup_type
        AND lookup_code = p_lookup_code ;

     pg_ar_lookups_desc_rec(l_hash_value) := l_description;

    END IF;

  END IF;

  return(l_description);

EXCEPTION
 WHEN no_data_found  THEN
  return( p_lookup_code);
 WHEN OTHERS THEN
  raise;
END;




FUNCTION phrase
(p_type                        IN VARCHAR2,
 p_class                       IN VARCHAR2,
 p_trx_number                  IN VARCHAR2,
 p_receipt_number              IN VARCHAR2,
 p_due_date                    IN DATE,
 p_outstanding_amt             IN NUMBER,
 p_payment_date                IN DATE,
 p_days_overdue_late           IN NUMBER,
 p_last_charge_date            IN DATE,
 p_interest_rate               IN NUMBER,
 p_calculate_interest_to_date  IN DATE)
RETURN VARCHAR2
IS
l_doc_num     VARCHAR2(30);
l_text        VARCHAR2(240);
BEGIN
--log( message  => 'Phrase +');
IF p_class = 'RECEIPT' THEN
  l_doc_num     := p_receipt_number;
ELSE
  l_doc_num     := p_trx_number;
END IF;
/*Bug 7441039 used correct lookup type for Late charge type and late charge line type
  Wrong name were used earlier.*/
IF    p_type = 'LATE' THEN
  l_text := SUBSTRB(
 get_lookup_desc('AR_LATE_CHARGE_TYPE_DESCR'      ,'LATE')      ||' '||l_doc_num          ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DUEDATE')   ||' '||p_due_date         ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','LATEPAYAMT')||' '||p_outstanding_amt  ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','PAYDATE')   ||' '||p_payment_date     ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DAYSLATE')  ||' '||p_days_overdue_late||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','INTRATE')   ||' '||p_interest_rate    ||'%',1,240);
ELSIF p_type = 'OVERDUE' THEN
  IF p_last_charge_date IS NULL	THEN
  l_text := SUBSTRB(
 get_lookup_desc('AR_LATE_CHARGE_TYPE_DESCR'      ,'OVERDUE')      ||' '||l_doc_num          ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DUEDATE')      ||' '||p_due_date         ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','OVERDUEAMT')   ||' '||p_outstanding_amt  ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','CALCINTTODATE')||' '||p_calculate_interest_to_date||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DAYSOVERDUE')  ||' '||p_days_overdue_late||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','INTRATE')      ||' '||p_interest_rate    ||'%',1,240);
  ELSE
  l_text := SUBSTRB(
 get_lookup_desc('AR_LATE_CHARGE_TYPE_DESCR'      ,'OVERDUE')       ||' '||l_doc_num          ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DUEDATE')       ||' '||p_due_date         ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','OVERDUEAMT')    ||' '||p_outstanding_amt  ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','CALCINTTODATE') ||' '||p_calculate_interest_to_date||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','LASTCHARGEDATE')||' '||p_last_charge_date ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DAYSOVERDUE')   ||' '||p_days_overdue_late||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','INTRATE')       ||' '||p_interest_rate ||'%',1,240);
  END IF;
ELSIF p_type = 'CREDIT' THEN
  IF p_last_charge_date IS NULL THEN
   l_text := SUBSTRB(
 get_lookup_desc('AR_LATE_CHARGE_TYPE_DESCR'      ,'CREDIT')       ||' '||l_doc_num                    ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DUEDATE')      ||' '||p_due_date                   ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','OVERDUEAMT')   ||' '||p_outstanding_amt            ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','CALCINTTODATE')||' '||p_calculate_interest_to_date ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DAYSOVERDUE')  ||' '||p_days_overdue_late          ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','INTRATE')      ||' '||p_interest_rate ||'%' ,1,240);
  ELSE
   l_text := SUBSTRB(
 get_lookup_desc('AR_LATE_CHARGE_TYPE_DESCR'      ,'CREDIT')        ||' '||l_doc_num                   ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DUEDATE')       ||' '||p_due_date                  ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','OVERDUEAMT')    ||' '||p_outstanding_amt           ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','CALCINTTODATE') ||' '||p_calculate_interest_to_date||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','LASTCHARGEDATE')||' '||p_last_charge_date          ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','DAYSOVERDUE')   ||' '||p_days_overdue_late         ||';'||
 get_lookup_desc('AR_LATE_CHARGE_LINE_DESCR','INTRATE')       ||' '||p_interest_rate ||'%',1,240);
  END IF;
ELSIF p_type = 'AVERAGE_DAILY_BALANCE' THEN
   l_text := get_lookup_desc('AR_LATE_CHARGE_TYPE_DESCR'      ,'AVERAGE_DAILY_BALANCE');
ELSIF p_type = 'PENALTY' THEN
   l_text := get_lookup_desc('AR_LATE_CHARGE_TYPE_DESCR'      ,'PENALTY');
ELSE
   l_text := get_lookup_desc('AR_LATE_CHARGE_TYPE_DESCR'      ,'DESC_NOT_SET');
END IF;
--log( message  => 'Phrase -');
RETURN (l_text);
END;







PROCEDURE INSERT_HDR IS
 i  NUMBER;
BEGIN
  log( message  => 'INSERT_HEADER +');
  FOR i IN iv_trx_header_tbl.FIRST .. iv_trx_header_tbl.LAST LOOP
    INSERT INTO ar_inv_api_headers_gt (
            trx_header_id                   ,
            trx_date                        ,
            trx_currency                    ,
            trx_class                       ,
            cust_trx_type_id                ,
	    gl_date			    ,
            bill_to_customer_id             ,
            bill_to_site_use_id             ,
            term_id                         ,
            exchange_rate_type              ,
            exchange_date                   ,
            exchange_rate                   ,
	    comments	                    )
     VALUES
     (iv_trx_header_tbl(i).trx_header_id,
      iv_trx_header_tbl(i).trx_date     ,
      iv_trx_header_tbl(i).trx_currency ,
      iv_trx_header_tbl(i).trx_class    ,
      iv_trx_header_tbl(i).cust_trx_type_id,
      iv_trx_header_tbl(i).gl_date	    ,
      iv_trx_header_tbl(i).bill_to_customer_id,
      iv_trx_header_tbl(i).bill_to_site_use_id,
      iv_trx_header_tbl(i).term_id      ,
      iv_trx_header_tbl(i).exchange_rate_type,
      iv_trx_header_tbl(i).exchange_date,
      iv_trx_header_tbl(i).exchange_rate,
      iv_trx_header_tbl(i).comments);
  END LOOP;
  log( message  => 'INSERT_HEADER -');
END;


PROCEDURE INSERT_LINE IS
 i  NUMBER;
BEGIN
  log( message  => 'INSERT_LINE +');
  FOR i IN iv_trx_lines_tbl.FIRST..iv_trx_lines_tbl.LAST LOOP
    INSERT INTO ar_inv_api_lines_gt(
      trx_header_id           ,
      trx_line_id             ,
      LINE_NUMBER             ,
      DESCRIPTION             ,
      QUANTITY_ORDERED        ,
      QUANTITY_INVOICED       ,
      UNIT_STANDARD_PRICE     ,
      UNIT_SELLING_PRICE      ,
      LINE_TYPE	              ,
      AMOUNT	              )
   VALUES
   (iv_trx_lines_tbl(i).trx_header_id,
    iv_trx_lines_tbl(i).trx_line_id  ,
    iv_trx_lines_tbl(i).LINE_NUMBER  ,
    iv_trx_lines_tbl(i).DESCRIPTION  ,
    iv_trx_lines_tbl(i).QUANTITY_ORDERED,
    iv_trx_lines_tbl(i).QUANTITY_INVOICED,
    iv_trx_lines_tbl(i).UNIT_STANDARD_PRICE,
    iv_trx_lines_tbl(i).UNIT_SELLING_PRICE,
    iv_trx_lines_tbl(i).LINE_TYPE	    ,
    iv_trx_lines_tbl(i).AMOUNT);
  END LOOP;
  log( message  => 'INSERT_LINE -');
END;



PROCEDURE INSERT_DIST IS
  I  NUMBER;
BEGIN
  log( message  => 'INSERT_DIST +');
  FOR i IN iv_trx_dist_tbl.FIRST..iv_trx_dist_tbl.LAST LOOP
    INSERT INTO ar_inv_api_dist_gt(
        trx_dist_id             ,
	trx_header_id		,
        trx_LINE_ID	        ,
        ACCOUNT_CLASS	        ,
        PERCENT	                ,
        CODE_COMBINATION_ID	)
     VALUES (
      iv_trx_dist_tbl(i).trx_dist_id,
      iv_trx_dist_tbl(i).trx_header_id,
      iv_trx_dist_tbl(i).trx_LINE_ID  ,
      iv_trx_dist_tbl(i).ACCOUNT_CLASS,
      iv_trx_dist_tbl(i).PERCENT	,
      iv_trx_dist_tbl(i).CODE_COMBINATION_ID);
   END LOOP;
  log( message  => 'INSERT_DIST -');
END;





PROCEDURE empty_var_iv IS
BEGIN
  log( message  => 'empty_var_iv +');
  iv_INTEREST_HEADER_ID            := nl_INTEREST_HEADER_ID;
  iv_CURRENCY_CODE                 := nl_CURRENCY_CODE;
  iv_HEADER_TYPE                   := nl_HEADER_TYPE;
  iv_cust_trx_type_id              := nl_cust_trx_type_id;
  iv_CUSTOMER_ID                   := nl_CUSTOMER_ID;
  iv_CUSTOMER_SITE_USE_ID          := nl_CUSTOMER_SITE_USE_ID;
  iv_LATE_CHARGE_TERM_ID           := nl_LATE_CHARGE_TERM_ID;
  iv_EXCHANGE_RATE_TYPE            := nl_EXCHANGE_RATE_TYPE;
  iv_EXCHANGE_RATE                 := nl_EXCHANGE_RATE;
  iv_PAYMENT_SCHEDULE_ID           := nl_PAYMENT_SCHEDULE_ID;
  iv_org_id                        := nl_org_id;
  iv_legal_entity_id               := nl_legal_entity_id;
  iv_interest_line_id              := nl_interest_line_id;
  iv_LATE_CHARGE_CALCULATION_TRX   := nl_LATE_CHARGE_CALCULATION_TRX;
  iv_DAYS_OF_INTEREST              := nl_DAYS_OF_INTEREST;
  iv_DAYS_OVERDUE_LATE             := nl_DAYS_OVERDUE_LATE;
  iv_DAILY_INTEREST_CHARGE         := nl_DAILY_INTEREST_CHARGE;
  iv_PAYMENT_SCHEDULE_ID           := nl_PAYMENT_SCHEDULE_ID;
  iv_INTEREST_CHARGED              := nl_INTEREST_CHARGED;
  iv_type                          := nl_type;
  iv_salesrep_required_flag        := nl_salesrep_required_flag;
  iv_salesrep_id                   := nl_salesrep_id;
  iv_salesrep_number               := nl_salesrep_number;
  iv_GL_ID_REC                     := nl_GL_ID_REC;
  iv_GL_ID_REV                     := nl_gl_id_rev;
  iv_cpt                           := 0;
  iv_salesrep_set                  := 'N';
  iv_sales_credit_name             := NULL;
  iv_sales_credit_id               := NULL;
  iv_original_trx_id               := nl_original_trx_id;
  iv_original_trx_class            := nl_original_trx_class;
  iv_DUE_DATE                      := nl_DUE_DATE;
  iv_OUTSTANDING_AMOUNT            := nl_OUTSTANDING_AMOUNT;
  iv_PAYMENT_DATE                  := nl_PAYMENT_DATE;
  iv_LAST_CHARGE_DATE              := nl_LAST_CHARGE_DATE;
  iv_INTEREST_RATE                 := nl_INTEREST_RATE;
  log( message  => 'empty_var_iv -');
END;





----------------------
-- Feed inv to Inv api
----------------------
PROCEDURE inv_to_inv_api_interface
(p_gl_date      IN DATE,
 p_cal_int_date IN DATE,
 p_batch_id     IN NUMBER)
IS
  CURSOR c_trx(p_trx_id  IN NUMBER) IS
  SELECT trx_number
    FROM ra_customer_trx
   WHERE customer_trx_id = p_trx_id;

  CURSOR c_recp(p_recp_id  IN NUMBER) IS
  SELECT receipt_number
    FROM ar_cash_receipts
   WHERE cash_receipt_id = p_recp_id;

  l_curr_recp_id        NUMBER := -9;
  l_recp_num            VARCHAR2(30);
  l_curr_trx_id         NUMBER := -9;
  l_trx_num             VARCHAR2(30);

BEGIN
  outandlog( message  => 'inv_to_inv_api_interface +');
  outandlog( message  => '  p_gl_date      :'||p_gl_date);
  outandlog( message  => '  p_cal_int_date :'||p_cal_int_date);
  outandlog( message  => '  p_batch_id     :'||p_batch_id);

  iv_header_cpt       := iv_trx_header_tbl.COUNT;
  iv_line_cpt         := iv_trx_lines_tbl.COUNT;
  iv_dist_cpt         := iv_trx_dist_tbl.COUNT;
  iv_salescredits_cpt := iv_trx_salescredits_tbl.COUNT;
  iv_line_num         := 0;

  FOR i IN iv_interest_line_id.FIRST .. iv_interest_line_id.LAST LOOP


    IF iv_curr_header_id  <> iv_INTEREST_HEADER_ID(i) THEN
      --
      -- Invoice Header
      --
      iv_curr_header_id := iv_INTEREST_HEADER_ID(i);
      iv_header_cpt := iv_header_cpt + 1;
      iv_trx_header_tbl(iv_header_cpt).trx_header_id           := iv_INTEREST_HEADER_ID(i);
      iv_trx_header_tbl(iv_header_cpt).interest_header_id      := iv_INTEREST_HEADER_ID(i);
      iv_trx_header_tbl(iv_header_cpt).trx_date                := p_cal_int_date;
      iv_trx_header_tbl(iv_header_cpt).trx_currency            := iv_CURRENCY_CODE(i);
      iv_trx_header_tbl(iv_header_cpt).trx_class               := iv_header_type(i);
      iv_trx_header_tbl(iv_header_cpt).cust_trx_type_id        := iv_cust_trx_type_id(i);
      iv_trx_header_tbl(iv_header_cpt).gl_date	               := p_gl_date;
      iv_trx_header_tbl(iv_header_cpt).bill_to_customer_id     := iv_CUSTOMER_ID(i);
      iv_trx_header_tbl(iv_header_cpt).bill_to_site_use_id     := iv_CUSTOMER_SITE_USE_ID(i);
      iv_trx_header_tbl(iv_header_cpt).term_id                 := iv_LATE_CHARGE_TERM_ID(i);
      iv_trx_header_tbl(iv_header_cpt).org_id                  := iv_org_ID(i);
      iv_trx_header_tbl(iv_header_cpt).legal_entity_id         := iv_legal_entity_ID(i);
      iv_trx_header_tbl(iv_header_cpt).late_charges_assessed   := 'Y';
      /*8266696*/
      IF(iv_salesrep_required_flag(i) = 'Y') THEN
      iv_trx_header_tbl(iv_header_cpt).primary_salesrep_id     := iv_salesrep_id(i) ;
      ELSE
       iv_trx_header_tbl(iv_header_cpt).primary_salesrep_id    := NULL;
      END IF;


      IF iv_CURRENCY_CODE(i) <> g_func_curr THEN
        iv_trx_header_tbl(iv_header_cpt).exchange_rate_type      := iv_EXCHANGE_RATE_TYPE(i);
        iv_trx_header_tbl(iv_header_cpt).exchange_date           := p_cal_int_date;
        iv_trx_header_tbl(iv_header_cpt).exchange_rate           := iv_EXCHANGE_RATE(i);
      END IF;

      iv_trx_header_tbl(iv_header_cpt).comments	               := 'Late Charge interest invoice import';
      iv_trx_header_tbl(iv_header_cpt).internal_notes	       := NULL;
      iv_trx_header_tbl(iv_header_cpt).finance_charges	       := NULL;


/*
      IF iv_header_type(i) = 'INV' THEN
        iv_trx_header_tbl(iv_header_cpt).interface_header_context   := 'Interest Invoice';
      ELSE
        iv_trx_header_tbl(iv_header_cpt).interface_header_context   := 'Debit memo Charge';
      END IF;
      iv_trx_header_tbl(iv_header_cpt).interface_header_attribute1:= p_batch_id;
                                         -- interest batch id
      iv_trx_header_tbl(iv_header_cpt).interface_header_attribute2:= iv_INTEREST_HEADER_ID(i);
                                         -- interest header id
      iv_trx_header_tbl(iv_header_cpt).interface_header_attribute3:= iv_PAYMENT_SCHEDULE_ID(i);
                                         -- payment schedule id
      iv_trx_header_tbl(iv_header_cpt).interface_header_attribute4:= 0;
                                       -- line number 0 for header
      iv_trx_header_tbl(iv_header_cpt).interface_header_attribute5:= NULL;
*/


      iv_trx_header_tbl(iv_header_cpt).org_id                 :=   iv_org_id(i);
      iv_trx_header_tbl(iv_header_cpt).legal_entity_id        :=   iv_legal_entity_id(i);
      --
      -- Receivables distribution
      --
      iv_dist_cpt  := iv_dist_cpt + 1;
      iv_trx_dist_tbl(iv_dist_cpt).trx_dist_id    := iv_INTEREST_HEADER_ID(i);
      iv_trx_dist_tbl(iv_dist_cpt).trx_header_id  := iv_INTEREST_HEADER_ID(i);
      iv_trx_dist_tbl(iv_dist_cpt).trx_LINE_ID    := NULL;
      iv_trx_dist_tbl(iv_dist_cpt).ACCOUNT_CLASS  := 'REC';
      iv_trx_dist_tbl(iv_dist_cpt).PERCENT	  := 100;
      iv_trx_dist_tbl(iv_dist_cpt).CODE_COMBINATION_ID := iv_GL_ID_REC(i);
      iv_trx_dist_tbl(iv_dist_cpt).COMMENTS	  := NULL;
    END IF;


   --
   -- invoice line
   --
   iv_line_cpt := iv_line_cpt + 1;
   iv_line_num := iv_line_num + 1;

   iv_trx_lines_tbl(iv_line_cpt).trx_header_id          := iv_INTEREST_HEADER_ID(i);
   iv_trx_lines_tbl(iv_line_cpt).trx_line_id            := iv_interest_line_id(i);
   iv_trx_lines_tbl(iv_line_cpt).interest_line_id       := iv_interest_line_id(i);
   iv_trx_lines_tbl(iv_line_cpt).link_to_trx_line_id    := NULL;
   iv_trx_lines_tbl(iv_line_cpt).LINE_NUMBER	        := iv_line_num;
   iv_trx_lines_tbl(iv_line_cpt).REASON_CODE	        := NULL;
   iv_trx_lines_tbl(iv_line_cpt).INVENTORY_ITEM_ID      := NULL;
   iv_trx_lines_tbl(iv_line_cpt).QUANTITY_ORDERED	:= iv_DAYS_OF_INTEREST(i);
   iv_trx_lines_tbl(iv_line_cpt).QUANTITY_INVOICED      := iv_DAYS_OF_INTEREST(i);
   iv_trx_lines_tbl(iv_line_cpt).UNIT_STANDARD_PRICE	:= iv_DAILY_INTEREST_CHARGE(i);
   iv_trx_lines_tbl(iv_line_cpt).UNIT_SELLING_PRICE     := iv_DAILY_INTEREST_CHARGE(i);
   iv_trx_lines_tbl(iv_line_cpt).LINE_TYPE	        := 'LINE';

   IF iv_GL_ID_REV(i) IS NOT NULL AND iv_GL_ID_REC(i) <> 0 THEN
     --
     -- Revenue distribution
     --
     iv_dist_cpt  := iv_dist_cpt + 1;
     iv_trx_dist_tbl(iv_dist_cpt).trx_dist_id    := iv_INTEREST_LINE_ID(i);
     iv_trx_dist_tbl(iv_dist_cpt).trx_header_id  := iv_INTEREST_HEADER_ID(i);
     iv_trx_dist_tbl(iv_dist_cpt).trx_LINE_ID    := iv_INTEREST_LINE_ID(i);
     iv_trx_dist_tbl(iv_dist_cpt).ACCOUNT_CLASS  := 'REV';
     iv_trx_dist_tbl(iv_dist_cpt).PERCENT	     := 100;
     iv_trx_dist_tbl(iv_dist_cpt).CODE_COMBINATION_ID := iv_GL_ID_REV(i);
     iv_trx_dist_tbl(iv_dist_cpt).COMMENTS	     := NULL;
   END IF;

   IF iv_original_trx_class(i) = 'RECEIPT' THEN
     IF l_curr_recp_id <> iv_original_trx_id(i) THEN
       OPEN c_recp(p_recp_id  => iv_original_trx_id(i));
       FETCH c_recp INTO l_recp_num;
       CLOSE c_recp;
       l_curr_recp_id := iv_original_trx_id(i);
     END IF;
   ELSE
     IF l_curr_trx_id <> iv_original_trx_id(i) THEN
       OPEN c_trx(p_trx_id  => iv_original_trx_id(i));
       FETCH c_trx INTO l_trx_num;
       CLOSE c_trx;
       l_curr_trx_id := iv_original_trx_id(i);
     END IF;
   END IF;

   iv_trx_lines_tbl(iv_line_cpt).DESCRIPTION  :=
    phrase
        (p_type              =>   iv_type(i),
         p_class             =>   iv_original_trx_class(i),
         p_trx_number        =>   l_trx_num,
         p_receipt_number    =>   l_recp_num,
         p_due_date          =>   iv_due_date(i),
         p_outstanding_amt   =>   iv_outstanding_amount(i),
         p_payment_date      =>   iv_payment_date(i),
         p_days_overdue_late =>   iv_days_overdue_late(i),
         p_last_charge_date  =>   iv_last_charge_date(i),
         p_interest_rate     =>   iv_interest_rate(i),
         p_calculate_interest_to_date  => p_cal_int_date);

/* Can be usefull to match 11i autoinv
   IF iv_header_type(i) = 'INV' THEN
     iv_trx_lines_tbl(iv_line_cpt).INTERFACE_LINE_CONTEXT	:= 'Interest Invoice';
   ELSE
     iv_trx_lines_tbl(iv_line_cpt).INTERFACE_LINE_CONTEXT	:= 'Debit Memo Charge';
   END IF;
   iv_trx_lines_tbl(iv_line_cpt).interface_line_attribute1:= p_batch_id;
                 -- interest batch id
   iv_trx_lines_tbl(iv_line_cpt).interface_line_attribute2:= iv_INTEREST_HEADER_ID(i);
                 -- interest header id
   iv_trx_lines_tbl(iv_line_cpt).interface_line_attribute3:= iv_PAYMENT_SCHEDULE_ID(i);
                 -- payment schedule id
   iv_trx_lines_tbl(iv_line_cpt).interface_line_attribute4:= iv_line_num;
                -- line number 0 for header
   iv_trx_lines_tbl(iv_line_cpt).interface_line_attribute5:= NULL;
*/

 /*To DO revert after testing done* BUG830281/

 /*  iv_trx_lines_tbl(iv_line_cpt).AMOUNT	                := iv_INTEREST_CHARGED(i);*/

  /*Bug 8302813*/
  iv_trx_lines_tbl(iv_line_cpt).AMOUNT	 := NULL;

 /* iv_trx_lines_tbl(iv_line_cpt).AMOUNT	 := (iv_DAYS_OF_INTEREST(i)) * (iv_DAILY_INTEREST_CHARGE(i));*/

   iv_trx_lines_tbl(iv_line_cpt).UOM_CODE	        := 'EA';


/*
   -- Sales rep not required
   --
   -- Sales Credit
   --
   IF iv_salesrep_required_flag(i) = 'Y' OR iv_salesrep_id(i) IS NOT NULL THEN
     iv_salesrep_set       := 'Y';
   ELSE
     iv_salesrep_set       := 'N';
   END IF;

   IF iv_salesrep_set = 'Y' AND iv_salesrep_id(i) IS NULL THEN
     iv_salesrep_id(i)     := -3;
     iv_salesrep_number(i) := '-3';
   END IF;
*/


   IF iv_salesrep_required_flag(i) = 'Y' THEN
     iv_salesrep_id(i)     := -3;
     iv_salesrep_number(i) := '-3';
     iv_salesrep_set       := 'Y';
   END IF;

   IF iv_salesrep_set = 'Y' THEN
      SELECT ssct.name,
            ssct.sales_credit_type_id
       INTO iv_sales_credit_name,
            iv_sales_credit_id
       FROM so_sales_credit_types ssct,
            ra_salesreps ras
      WHERE ras.salesrep_id =  iv_salesrep_id(i)
        AND ras.sales_credit_type_id = ssct.sales_credit_type_id;

      iv_salescredits_cpt  := iv_salescredits_cpt + 1;
      iv_trx_salescredits_tbl(iv_salescredits_cpt).TRX_salescredit_ID        := iv_interest_line_id(i);
      iv_trx_salescredits_tbl(iv_salescredits_cpt).TRX_LINE_ID               := iv_interest_line_id(i);
      iv_trx_salescredits_tbl(iv_salescredits_cpt).SALESREP_ID               := iv_salesrep_id(i);
      iv_trx_salescredits_tbl(iv_salescredits_cpt).SALESREP_NUMBER           := iv_salesrep_number(i);
      iv_trx_salescredits_tbl(iv_salescredits_cpt).SALES_CREDIT_TYPE_NAME    := iv_sales_credit_name;
      iv_trx_salescredits_tbl(iv_salescredits_cpt).SALES_CREDIT_TYPE_ID      := iv_sales_credit_id;
      iv_trx_salescredits_tbl(iv_salescredits_cpt).SALESCREDIT_PERCENT_SPLIT := 100;
   END IF;

   END LOOP;

   IF iv_create_flag = 'N' THEN
     iv_create_flag := 'Y';
   END IF;


   UPDATE ar_late_charge_doc_gt
      SET execution_status = 'R'  --Ready
    WHERE interest_header_id = iv_curr_header_id;

  log( message  => 'The interest header with the interest_header_id:'||iv_curr_header_id||' is ready for process');

   empty_var_iv;

  outandlog( message  => '   iv_curr_header_id :'||iv_curr_header_id);
  outandlog( message  => 'inv_to_inv_api_interface -');
END;









----------------------------
-- Execute Inv API
----------------------------
PROCEDURE call_invoice_api
( x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2)
IS
  CURSOR c_line IS
  SELECT TRX_LINE_ID          ,
         ERROR_MESSAGE||':'||INVALID_VALUE
    FROM ar_trx_errors_gt
   WHERE TRX_LINE_ID IS NOT NULL
   ORDER BY TRX_HEADER_ID, TRX_LINE_ID;


  CURSOR c_hdr IS
  SELECT TRX_HEADER_ID          ,
         ERROR_MESSAGE||':'||INVALID_VALUE
    FROM ar_trx_errors_gt
   WHERE TRX_LINE_ID IS NULL
   ORDER BY TRX_HEADER_ID;

  CURSOR c_nb_inv_in_err IS
  SELECT count(TRX_HEADER_ID)
    FROM ar_trx_errors_gt
   GROUP BY TRX_HEADER_ID;


  CURSOR c_s IS
  SELECT a.interest_line_id,
         --{HYU update late_charge_Date
         a.payment_schedule_id
         --}
    FROM ar_late_charge_doc_gt a
   WHERE a.interest_batch_id = g_interest_batch_id
     AND a.execution_status  = 'R'
     AND NOT EXISTS
     (SELECT NULL
        FROM ar_late_charge_doc_gt b
       WHERE b.interest_header_id = a.interest_header_id
         AND b.interest_batch_id  = g_interest_batch_id
         AND b.execution_status   = 'E');

   l_sucess_line_id   DBMS_SQL.NUMBER_TABLE;
   l_success_ps_id    DBMS_SQL.NUMBER_TABLE;

   l_trx_header_id    DBMS_SQL.NUMBER_TABLE;
   l_trx_line_id      DBMS_SQL.NUMBER_TABLE;
   l_err_text         DBMS_SQL.VARCHAR2_TABLE;
   l_err_line_text    DBMS_SQL.VARCHAR2_TABLE;

   l_curr_hdr_id      NUMBER := 0;
   l_curr_line_id     NUMBER := 0;

   l_header_upg       DBMS_SQL.NUMBER_TABLE;
   l_header_text      DBMS_SQL.VARCHAR2_TABLE;
   hcpt               NUMBER := 0;

   l_line_upg         DBMS_SQL.NUMBER_TABLE;
   l_line_text        DBMS_SQL.VARCHAR2_TABLE;
   lcpt               NUMBER := 0;
   l_text             VARCHAR2(32000);
   i                  NUMBER;


   l_stop             VARCHAR2(1) := 'N';
BEGIN
  outandlog( message  => 'call_invoice_api +');

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- Execution of the invoice api
  --
   AR_INVOICE_API_PUB.create_invoice(
             p_api_version           => 1.0,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_batch_source_rec      => iv_batch_source_rec,
             p_trx_header_tbl        => iv_trx_header_tbl,
             p_trx_lines_tbl         => iv_trx_lines_tbl,
             p_trx_dist_tbl          => iv_trx_dist_tbl,
             p_trx_salescredits_tbl  => iv_trx_salescredits_tbl);


   IF PG_DEBUG = 'Y' THEN
       INSERT_HDR;

       INSERT_LINE;

       INSERT_DIST;
   END IF;

   --
   -- Note Invoice API only return status <> FND_API.G_RET_STS_SUCCESS
   -- if none standard errors are found
   --
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE fnd_api.g_exc_error;
   END IF;

   --
   -- Error at header
   --
   OPEN c_hdr;
   FETCH c_hdr BULK COLLECT INTO
     l_trx_header_id,
     l_err_text     ;
   CLOSE c_hdr;

   --
   -- Invoice api caller will return error is functional setup incorrect
   --
   IF l_trx_header_id.COUNT > 0 THEN
     x_return_status := fnd_api.g_ret_sts_error;
     x_msg_count     := 0;

     FOR i IN 1..l_trx_header_id.COUNT LOOP

     IF l_trx_header_id(i) <> l_curr_hdr_id  THEN
       IF l_curr_hdr_id <> 0 THEN
          hcpt   := hcpt + 1;
          l_header_upg(hcpt) := l_curr_hdr_id;
          l_header_text(hcpt):= SUBSTRB(l_text,1,2000);
          x_msg_count := x_msg_count + 1;
       END IF;

       l_curr_hdr_id := l_trx_header_id(i);
       l_text        := NULL;
     END IF;

     l_text := SUBSTRB(l_text||l_err_text(i)||';',1,2000);
     log('Header error interest_header_id:'||l_trx_header_id(i)||':'||l_text);

     IF i = l_trx_header_id.LAST AND l_text IS NOT NULL THEN
        hcpt   := hcpt + 1;
        l_header_upg(hcpt) := l_curr_hdr_id;
        l_header_text(hcpt):= SUBSTRB(l_text,1,2000);
        x_msg_count := x_msg_count + 1;
     END IF;

     END LOOP;

  END IF;


  IF l_header_upg.COUNT > 0 THEN

   FORALL i IN l_header_upg.FIRST..l_header_upg.LAST
   UPDATE ar_late_charge_doc_gt
      SET execution_status = 'E',
          hdr_err_msg      = l_header_text(i)
    WHERE interest_header_id = l_header_upg(i)
      AND interest_batch_id  = g_interest_batch_id;

   FORALL i IN l_header_upg.FIRST..l_header_upg.LAST
   UPDATE ar_interest_headers
      SET process_status   = 'E',
          process_message  = l_header_text(i)
    WHERE interest_header_id = l_header_upg(i)
      AND interest_batch_id  = g_interest_batch_id;
  END IF;

   --
   -- Error at line
   --
   OPEN c_line;
   FETCH c_line BULK COLLECT INTO
     l_trx_line_id  ,
     l_err_line_text;
   CLOSE c_line;

   --
   -- Invoice api caller will return error is functional setup incorrect
   --
   IF l_trx_line_id.COUNT > 0 THEN
     x_return_status := fnd_api.g_ret_sts_error;

     FOR i IN 1..l_trx_line_id.COUNT LOOP

     IF l_trx_line_id(i) <> l_curr_line_id  THEN
        IF l_curr_line_id <> 0 THEN
          lcpt   := lcpt + 1;
          l_line_upg(lcpt) := l_curr_line_id;
          l_line_text(lcpt):= SUBSTRB(l_text,1,2000);
        END IF;

        l_curr_line_id := l_trx_line_id(i);
        l_text         := NULL;
     END IF;

     l_text := SUBSTRB(l_text||l_err_line_text(i)||';',1,2000);
     log('Line error interest_line_id:'||l_trx_line_id(i)||':'||l_text);

     IF i = l_trx_line_id.LAST AND l_text IS NOT NULL THEN
       lcpt   := lcpt + 1;
       l_line_upg(lcpt) := l_curr_line_id;
       l_line_text(lcpt):= SUBSTRB(l_text,1,2000);
     END IF;

     END LOOP;
   END IF;

   IF l_line_upg.COUNT >0 THEN

    FORALL i IN l_line_upg.FIRST..l_line_upg.LAST
    UPDATE ar_late_charge_doc_gt
      SET execution_status = 'E',
          line_err_msg      = l_line_text(i)
     WHERE interest_line_id = l_line_upg(i);


    FORALL i IN l_line_upg.FIRST..l_line_upg.LAST
    UPDATE ar_interest_lines
      SET process_status = 'E',
          process_message= l_line_text(i)
     WHERE interest_line_id   = l_line_upg(i);
   END IF;

   OPEN c_s;
   FETCH c_s BULK COLLECT INTO l_sucess_line_id,l_success_ps_id;
   CLOSE c_s;

   IF l_sucess_line_id.COUNT > 0 THEN
     FORALL i IN l_sucess_line_id.FIRST..l_sucess_line_id.LAST
     UPDATE ar_late_charge_doc_gt
        SET execution_status  = 'S'
      WHERE execution_status  = 'R'
      AND interest_batch_id = g_interest_batch_id
      AND interest_line_id  = l_sucess_line_id(i);


    log(message  => 'Updating ar_payment_schedules late_charge_date for invoice and DM');

     FORALL i IN l_success_ps_id.FIRST..l_success_ps_id.LAST
     UPDATE ar_payment_schedules
        SET last_charge_date = g_int_cal_date
      WHERE payment_schedule_id  = l_success_ps_id(i);

   END IF;

   --
   -- empty_var_iv_api
   --
   iv_trx_header_tbl                := nl_trx_header_tbl;
   iv_trx_lines_tbl                 := nl_trx_lines_tbl;
   iv_trx_dist_tbl                  := nl_trx_dist_tbl;
   iv_trx_salescredits_tbl          := nl_trx_salescredits_tbl;
   iv_create_flag                   := 'N';
   iv_header_cpt                    := 0;
   iv_line_cpt                      := 0;
   iv_dist_cpt                      := 0;
   iv_salescredits_cpt              := 0;
   iv_curr_header_id                := 0;
   iv_line_num                      := 0;
   iv_create_flag                   := 'N';


   IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_msg_data := 'Error are set back in the ar_interest_headers and lines table,
please retrieve from table with the interest_batch_id:'||g_interest_batch_id;
   END IF;

   --
   -- All errors at lines - return number of header in error
   --
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
     OPEN c_nb_inv_in_err;
     FETCH c_nb_inv_in_err INTO x_msg_count;
     CLOSE c_nb_inv_in_err;
   END IF;


  outandlog( message  => 'call_invoice_api -');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --
    -- Error from invoice api directly out
    --
    FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data );

    outandlog( message  => x_msg_data);

  WHEN OTHERS THEN

     outandlog( message  => 'EXCEPTION OTHERS in call_invoice_api:'||SQLERRM);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
      outandlog( message  => ' EXCEPTION OTHERS call_invoice_api :'||SQLERRM);

END;










--------------------------
-- Interest Invoice Cursor
--------------------------
PROCEDURE get_the_row_to_process
(x_exec_status            OUT NOCOPY VARCHAR2,
 p_worker_num             IN NUMBER DEFAULT NULL)
IS
  CURSOR csp IS
  SELECT LATE_CHARGE_DM_TYPE_ID,
         LATE_CHARGE_INV_TYPE_ID,
         ALLOW_LATE_CHARGES,
         PENALTY_REC_TRX_ID,
         FINCHRG_RECEIVABLES_TRX_ID
   FROM  ar_system_parameters;
  l_sp   csp%ROWTYPE;

  CURSOR c IS
  SELECT NULL
    FROM ar_late_charge_doc_gt
   WHERE interest_batch_id = g_interest_batch_id
     AND header_type IN ('INV','DM')
     AND NVL(p_worker_num,-9) = NVL(worker_num, -9)
     AND execution_status = 'I';
  lf   VARCHAR2(1);
BEGIN
  log( message  => 'get_the_row_to_process +');
  OPEN csp;
  FETCH csp INTO l_sp;
  CLOSE csp;
  INSERT INTO ar_late_charge_doc_gt
   (interest_header_id      ,
    CURRENCY_CODE           ,
    HEADER_TYPE             ,
    cust_trx_type_id        ,
    CUSTOMER_ID             ,
    CUSTOMER_SITE_USE_ID    ,
    LATE_CHARGE_TERM_ID     ,
    EXCHANGE_RATE_TYPE      ,
    EXCHANGE_RATE           ,
    org_id                  ,
    legal_entity_id         ,
    LATE_CHARGE_CALCULATION_TRX,
    interest_line_id        ,
    DAYS_OF_INTEREST        ,
    DAYS_OVERDUE_LATE       ,
    DAILY_INTEREST_CHARGE   ,
    PAYMENT_SCHEDULE_ID     ,
    INTEREST_CHARGED        ,
    type                    ,
    salesrep_required_flag  ,
    salesrep_id             ,
    salesrep_number         ,
    GL_ID_REC               ,
    execution_status        ,
    interest_batch_id       ,
    original_trx_id         ,
    original_trx_class      ,
    DUE_DATE                ,
    OUTSTANDING_AMOUNT      ,
    PAYMENT_DATE            ,
    LAST_CHARGE_DATE        ,
    INTEREST_RATE           ,
    gl_id_rev              ,
	worker_num )
    SELECT h.INTEREST_HEADER_ID,
           h.CURRENCY_CODE,
           h.HEADER_TYPE,
--{
--           h.cust_trx_type_id,
           DECODE(h.HEADER_TYPE,'INV',l_sp.LATE_CHARGE_INV_TYPE_ID,l_sp.LATE_CHARGE_DM_TYPE_ID),
--}
           h.CUSTOMER_ID,
           h.CUSTOMER_SITE_USE_ID,
           h.LATE_CHARGE_TERM_ID,
           h.EXCHANGE_RATE_TYPE,
           h.EXCHANGE_RATE,
           h.org_id,
           h.legal_entity_id,
           h.LATE_CHARGE_CALCULATION_TRX,
           l.interest_line_id,
           l.DAYS_OF_INTEREST,
           l.DAYS_OVERDUE_LATE,
           l.DAILY_INTEREST_CHARGE,
           l.PAYMENT_SCHEDULE_ID,
           l.INTEREST_CHARGED,
           l.type,
           sp.salesrep_required_flag,
           -3,
           '-3',
           tty.GL_ID_REC,
           'I',
           g_interest_batch_id,
           l.original_trx_id,
           l.original_trx_class,
           l.DUE_DATE          ,
           l.OUTSTANDING_AMOUNT,
           l.PAYMENT_DATE      ,
           l.LAST_CHARGE_DATE  ,
           l.INTEREST_RATE ,
           tty.GL_ID_REV,
           p_worker_num
      FROM ar_interest_headers   h,
           ar_interest_lines     l,
           ar_system_parameters  sp,
           ra_cust_trx_types     tty
     WHERE h.interest_batch_id  = g_interest_batch_id
       AND h.INTEREST_HEADER_ID = l.INTEREST_HEADER_ID
       AND tty.cust_trx_type_id(+) = h.cust_trx_type_id
       AND h.HEADER_TYPE        IN ('INV','DM')
       AND h.display_flag      = 'Y' --HYU CDI only document generating the Late Charge s Doc
       AND NVL(l.interest_charged,0)   <> 0
       AND DECODE(p_worker_num,NULL,NVL(h.worker_num,-9),p_worker_num)=NVL(h.worker_num,-9)
       AND h.PROCESS_STATUS  = 'N'
     ORDER BY h.INTEREST_HEADER_ID,
              l.interest_line_id;


--INSERT INTO hy_late_charge_doc_gt select * from ar_late_charge_doc_gt;

  OPEN c;
  FETCH c INTO lf;
  IF c%FOUND THEN
    x_exec_status := 'Y';
  ELSE
    x_exec_status := 'N';
  END IF;
  CLOSE c;
  log( message  => '   Find row to process :'||x_exec_status);
  log( message  => 'get_the_row_to_process -');
END;


PROCEDURE get_nb_row_ready
(x_nb_row_ready    OUT NOCOPY NUMBER)
IS
 CURSOR c IS
 SELECT COUNT(*)
   FROM ar_late_charge_doc_gt
  WHERE execution_status = 'R'
    AND interest_batch_id = g_interest_batch_id;
BEGIN
 log( message  => 'get_nb_row_ready +');
 OPEN c;
 FETCH c INTO x_nb_row_ready;
 IF c%NOTFOUND THEN
   x_nb_row_ready := 0;
 END IF;
 CLOSE c;
 log( message  => '  x_nb_row_ready :'||x_nb_row_ready);
 log( message  => 'get_nb_row_ready -');
END;


PROCEDURE get_list_headers
(x_list        OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
 x_nb_list     OUT NOCOPY NUMBER,
 p_worker_num  IN  NUMBER DEFAULT NULL)
IS
 CURSOR nb_headers IS
  SELECT DISTINCT interest_header_id
    FROM ar_late_charge_doc_gt
   WHERE execution_status = 'I'
     AND interest_batch_id = g_interest_batch_id
     AND NVL(p_worker_num,-9) = NVL(worker_num,-9)
     AND header_type IN ('INV','DM');
BEGIN
 log( message  => 'get_list_headers +');
  OPEN nb_headers;
  FETCH nb_headers BULK COLLECT INTO x_list;
  CLOSE nb_headers;
  x_nb_list  := x_list.COUNT;
 log( message  => '  x_nb_list :'||x_nb_list);
 log( message  => 'get_list_headers -');
END;


PROCEDURE get_read_a_header
(p_header_id   IN NUMBER,
 p_exec_status IN VARCHAR2 DEFAULT 'I',
 p_clear_iv    IN VARCHAR2 DEFAULT 'Y',
 x_nb_row      OUT NOCOPY  NUMBER)
IS
 CURSOR get_read_a_header IS
  SELECT
    interest_header_id      ,
    CURRENCY_CODE           ,
    HEADER_TYPE             ,
    cust_trx_type_id        ,
    CUSTOMER_ID             ,
    CUSTOMER_SITE_USE_ID    ,
    LATE_CHARGE_TERM_ID     ,
    EXCHANGE_RATE_TYPE      ,
    EXCHANGE_RATE           ,
    org_id                  ,
    legal_entity_id         ,
    LATE_CHARGE_CALCULATION_TRX,
    interest_line_id        ,
    DAYS_OF_INTEREST        ,
    DAYS_OVERDUE_LATE       ,
    DAILY_INTEREST_CHARGE   ,
    PAYMENT_SCHEDULE_ID     ,
    INTEREST_CHARGED        ,
    type                    ,
    salesrep_required_flag  ,
    salesrep_id             ,
    salesrep_number         ,
    GL_ID_REC               ,
    original_trx_id         ,
    original_trx_class      ,
    DUE_DATE          ,
    OUTSTANDING_AMOUNT,
    PAYMENT_DATE      ,
    LAST_CHARGE_DATE  ,
    INTEREST_RATE ,
    gl_id_rev
   FROM ar_late_charge_doc_gt
  WHERE interest_header_id  = p_header_id
    AND interest_batch_id   = g_interest_batch_id
    AND execution_status    = p_exec_status
    AND header_type IN ('INV','DM');
BEGIN
 log( message  => 'get_read_a_header +');
 log( message  => '  p_header_id :'||p_header_id);
  IF p_clear_iv = 'Y' THEN
    empty_var_iv;
  END IF;

  OPEN get_read_a_header;
  FETCH get_read_a_header BULK COLLECT INTO
           iv_INTEREST_HEADER_ID,
           iv_CURRENCY_CODE,
           iv_HEADER_TYPE,
           iv_cust_trx_type_id,
           iv_CUSTOMER_ID,
           iv_CUSTOMER_SITE_USE_ID,
           iv_LATE_CHARGE_TERM_ID,
           iv_EXCHANGE_RATE_TYPE,
           iv_EXCHANGE_RATE,
           iv_org_id,
           iv_legal_entity_id,
           iv_LATE_CHARGE_CALCULATION_TRX,
           iv_interest_line_id,
           iv_DAYS_OF_INTEREST,
           iv_DAYS_OVERDUE_LATE,
           iv_DAILY_INTEREST_CHARGE,
           iv_PAYMENT_SCHEDULE_ID,
           iv_INTEREST_CHARGED,
           iv_type,
           iv_salesrep_required_flag,
           iv_salesrep_id,
           iv_salesrep_number,
           iv_GL_ID_REC,
           iv_original_trx_id,
           iv_original_trx_class,
           iv_DUE_DATE          ,
           iv_OUTSTANDING_AMOUNT,
           iv_PAYMENT_DATE      ,
           iv_LAST_CHARGE_DATE  ,
           iv_INTEREST_RATE ,
	       iv_gl_id_rev;
  CLOSE get_read_a_header;
  x_nb_row  := iv_INTEREST_HEADER_ID.COUNT;
 log( message  => '  x_nb_row :'||x_nb_row);
 log( message  => 'get_read_a_header -');
END;





PROCEDURE create_charge_inv_dm
( p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER,
  p_worker_num            IN NUMBER   DEFAULT NULL,
  p_gl_date               IN DATE     DEFAULT NULL,
  p_cal_int_date          IN DATE     DEFAULT NULL,
  p_api_bulk_size         IN NUMBER   DEFAULT NULL,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2)
IS
  CURSOR c_gl_date IS
  SELECT gl_date,
         calculate_interest_to_date
    FROM ar_interest_batches
   WHERE interest_batch_id = g_interest_batch_id;

  l_current_trx_id      NUMBER := -9;
  l_return_status       VARCHAR2(10);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_bulk_size           NUMBER;
  s_gl_date             date;
  s_cal_int_date        date;
  l_inv_meaning         VARCHAR2(80);
  l_dm_meaning          VARCHAR2(80);
  l_last_fetch          BOOLEAN := FALSE;
  j                     NUMBER := 0;
  l_list_header_id_tab  DBMS_SQL.NUMBER_TABLE;
  l_nb_headers          NUMBER;
  l_nb_row_ready        NUMBER;
  l_exec_status         VARCHAR2(1) := 'Y';
  L_NB_OF_DOC           NUMBER;
  l_list_header_in_error DBMS_SQL.NUMBER_TABLE;
BEGIN
  outandlog( message  => 'create_charge_inv_dm +');
  outandlog( message  => '  p_batch_source_id  :'||p_batch_source_id);
  outandlog( message  => '  p_batch_id         :'||p_batch_id);
  outandlog( message  => '  p_worker_num       :'||p_worker_num);
  outandlog( message  => '  p_gl_date          :'||p_gl_date );
  outandlog( message  => '  p_cal_int_date     :'||p_cal_int_date );
  outandlog( message  => '  p_api_bulk_size    :'||p_api_bulk_size );

  g_interest_batch_id := p_batch_id;
  arp_standard.debug('g_interest_batch_id:'||g_interest_batch_id);


  l_inv_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('AR_LATE_CHARGE_TYPE', 'INV');
  l_dm_meaning  := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('AR_LATE_CHARGE_TYPE', 'DM');

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_msg_count       := 0;

  IF p_api_bulk_size IS NULL OR p_api_bulk_size = 0 THEN
    l_bulk_size  := g_bulk_fetch_rows;
  ELSE
    l_bulk_size  := p_api_bulk_size;
  END IF;


  IF p_gl_date IS NULL OR p_cal_int_date IS NULL THEN
    OPEN c_gl_date;
    FETCH c_gl_date INTO s_gl_date,
                         s_cal_int_date;
    IF c_gl_date%NOTFOUND OR s_gl_date IS NULL THEN
      arp_standard.debug('  Late Charge Batch GL date and calculate interest date is required');
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'GL_DATE' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF c_gl_date%NOTFOUND OR s_cal_int_date IS NULL THEN
      arp_standard.debug('  Late Charge Batch calculate interest date is required');
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'calculate_interest_to_date' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_gl_date;
  ELSE
    s_gl_date      := p_gl_date;
    s_cal_int_date := p_cal_int_date;
  END IF;

  g_int_cal_date  := s_cal_int_date;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  iv_batch_source_rec.batch_source_id :=  p_batch_source_id;
  iv_batch_source_rec.default_date    :=  s_gl_date;


  --Get all rows to process
  get_the_row_to_process(x_exec_status  => l_exec_status,
                         p_worker_num   => p_worker_num);
  outandlog('l_exec_status:'||l_exec_status);


  IF l_exec_status = 'Y' THEN

      -- Num documents
      get_list_headers(x_list        => l_list_header_id_tab,
                       x_nb_list     => l_nb_headers,
					   p_worker_num  => p_worker_num);

      outandlog('l_nb_headers:'||l_nb_headers);


      IF l_nb_headers  > 0 THEN

          FOR i IN l_list_header_id_tab.FIRST.. l_list_header_id_tab.LAST LOOP

            -- call structure
            get_read_a_header(p_header_id   => l_list_header_id_tab(i),
                              p_exec_status => 'I',
                              p_clear_iv    => 'Y',
                              x_nb_row      => l_nb_of_doc);


            --Put in invoice api interface
            IF l_nb_of_doc > 0 THEN
                inv_to_inv_api_interface(p_gl_date      => s_gl_date,
                                         p_cal_int_date => s_cal_int_date,
                                         p_batch_id     => g_interest_batch_id);
            END IF;

            --Execute API if required
            get_nb_row_ready(x_nb_row_ready => l_nb_row_ready);


            IF l_nb_row_ready >= l_bulk_size THEN

                arp_standard.debug('l_nb_row_ready:'||l_nb_row_ready);
                call_invoice_api(x_return_status => l_return_status,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    IF x_msg_count IS NULL THEN
                       x_msg_count := l_msg_count;
                    ELSE
                       x_msg_count := x_msg_count + l_msg_count;
                    END IF;
                    x_msg_data    := l_msg_data;
                END IF;

            END IF;

        END LOOP;

        outandlog('iv_create_flag:'||iv_create_flag);


        IF iv_create_flag = 'Y' THEN
           call_invoice_api(x_return_status => l_return_status,
                            x_msg_count     => l_msg_count,
                            x_msg_data      => l_msg_data);

           IF l_return_status <> fnd_api.g_ret_sts_success THEN

              IF x_msg_count IS NULL THEN
                 x_msg_count := l_msg_count;
              ELSE
                 x_msg_count := x_msg_count + l_msg_count;
              END IF;

              x_msg_data    := l_msg_data;

           END IF;

        END IF;

     END IF;

    log( message  => '  update ar_interest_headers for successfull headers');

    UPDATE ar_interest_headers SET
           process_status  = 'S',
           process_message = NULL
     WHERE interest_batch_id = g_interest_batch_id
       AND process_status  = 'N'
       AND display_flag    = 'Y' --HYU CDI only document generating the Late Charge s Doc
       AND DECODE(p_worker_num,NULL,NVL(worker_num,-9),p_worker_num)=NVL(worker_num,-9)
       AND interest_header_id IN
           (SELECT MAX(interest_header_id)
              FROM ar_late_charge_doc_gt
             WHERE interest_batch_id = g_interest_batch_id
               AND execution_status  = 'S'
               AND NVL(p_worker_num,-9)= NVL(worker_num,-9)
               AND header_type IN ('INV','DM')
             GROUP BY interest_header_id);

    log( message  => '  update ar_interest_headers for error headers');
    UPDATE ar_interest_headers SET
           process_status  = 'E'
     WHERE interest_batch_id = g_interest_batch_id
       AND process_status  = 'N'
       AND display_flag    = 'Y' --HYU CDI only document generating the Late Charge s Doc
       AND DECODE(p_worker_num,NULL,NVL(worker_num,-9),p_worker_num)   = NVL(worker_num,-9)
       AND header_type IN ('INV','DM')
	 RETURN interest_batch_id BULK COLLECT INTO l_list_header_in_error;

	 log( message  => '  update ar_payment_schedule for successfull headers');
    UPDATE ar_payment_schedules
      SET last_charge_date = g_int_cal_date
     WHERE payment_schedule_id IN
     (SELECT l.PAYMENT_SCHEDULE_ID
        FROM ar_interest_headers h,
             ar_interest_lines   l
       WHERE h.interest_batch_id  = g_interest_batch_id
         AND h.process_status     = 'S'
         AND h.display_flag       = 'Y' --HYU CDI only document generating the Late Charge s Doc
         AND DECODE(p_worker_num,NULL,NVL(h.worker_num,-9),p_worker_num)=NVL(h.worker_num,-9)
         AND h.interest_header_id = l.interest_header_id
         AND h.header_type IN ('INV','DM'));

  END IF;

  outandlog( message  => 'create_charge_inv_dm -');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data );

    outandlog( message  => x_msg_data);

  WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('AR','HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.Set_Token('ERROR',SQLERRM);
    fnd_msg_pub.add;
    FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data );
    outandlog( message  => x_msg_data);
END;




PROCEDURE insert_adj_process
(x_nb_adj                 OUT NOCOPY NUMBER,
 p_worker_num             IN  NUMBER DEFAULT NULL)
IS
  CURSOR csp IS
  SELECT LATE_CHARGE_DM_TYPE_ID,
         LATE_CHARGE_INV_TYPE_ID,
         ALLOW_LATE_CHARGES,
         PENALTY_REC_TRX_ID,
         FINCHRG_RECEIVABLES_TRX_ID
   FROM  ar_system_parameters;
  l_sp   csp%ROWTYPE;

 CURSOR c IS
 SELECT COUNT(*) FROM ar_late_charge_doc_gt
 WHERE interest_batch_id = g_interest_batch_id
   AND NVL(p_worker_num,-9) = NVL(p_worker_num,worker_num)
   AND execution_status  = 'I'
   AND header_type       = 'ADJ';
BEGIN
  log( message  => 'insert_adj_process +');
  OPEN csp;
  FETCH csp INTO l_sp;
  CLOSE csp;

  INSERT INTO ar_late_charge_doc_gt
      (  INTEREST_CHARGED,
         PAYMENT_SCHEDULE_ID,
         TYPE,
         ORIGINAL_TRX_ID,
         INTEREST_HEADER_ID,
         INTEREST_LINE_ID,
         receivables_trx_id,
         receivables_trx_name,
         interest_batch_id,
         execution_status,
         header_type,
		 worker_num)
  SELECT l.INTEREST_CHARGED,
         l.PAYMENT_SCHEDULE_ID,
         l.TYPE,
         l.ORIGINAL_TRX_ID,
         l.INTEREST_HEADER_ID,
         l.INTEREST_LINE_ID,
--{
         DECODE(l.type,'PENALTY',l_sp.PENALTY_REC_TRX_ID,l_sp.FINCHRG_RECEIVABLES_TRX_ID),
--         rtrx.receivables_trx_id,
--}
         rtrx.name,
         g_interest_batch_id,
         'I',
         header_type,
         p_worker_num
    FROM ar_interest_lines     l,
         ar_interest_headers   h,
         ar_interest_batches   b,
         ar_receivables_trx    rtrx,
         ar_payment_schedules  psch
   WHERE b.interest_batch_id         = g_interest_batch_id
     AND h.interest_batch_id         = b.interest_batch_id
     AND l.INTEREST_HEADER_ID        = h.INTEREST_HEADER_ID
     AND h.HEADER_TYPE               = 'ADJ'
     AND h.display_flag              = 'Y'   --HYU CDI Only adjustment generatable documents need to be considered
     AND rtrx.receivables_trx_id(+)  = l.receivables_trx_id
     AND psch.payment_schedule_id(+) = l.PAYMENT_SCHEDULE_ID
     AND psch.customer_trx_id(+)     = l.ORIGINAL_TRX_ID
     AND NVL(l.INTEREST_CHARGED,0)  <> 0
     AND l.PROCESS_STATUS           = 'N'
	 AND DECODE(p_worker_num,NULL,NVL(h.worker_num,-9),p_worker_num) =NVL(h.worker_num,-9);
 OPEN c;
 FETCH c INTO x_nb_adj;
 CLOSE c;
  log( message  => '    x_nb_adj :'||x_nb_adj);
  log( message  => 'insert_adj_process -');
END;


PROCEDURE create_charge_adj
( p_batch_id              IN NUMBER,
  p_worker_num            IN NUMBER   DEFAULT NULL,
  p_gl_date               IN DATE     DEFAULT NULL,
  p_cal_int_date          IN DATE     DEFAULT NULL,
  p_api_bulk_size         IN NUMBER   DEFAULT NULL,
  x_num_adj_created      OUT NOCOPY  NUMBER,
  x_num_adj_error        OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2)
IS
  CURSOR c_gl_date IS
  SELECT gl_date,
         calculate_interest_to_date
    FROM ar_interest_batches
   WHERE interest_batch_id = g_interest_batch_id;

  CURSOR cadj IS
  SELECT INTEREST_CHARGED,
         PAYMENT_SCHEDULE_ID,
         TYPE,
         ORIGINAL_TRX_ID,
         INTEREST_HEADER_ID,
         INTEREST_LINE_ID,
         receivables_trx_id,
         receivables_trx_name,
         g_interest_batch_id,
         worker_num
    FROM ar_late_charge_doc_gt
   WHERE interest_batch_id  = g_interest_batch_id
     AND header_type        = 'ADJ'
     AND execution_status   = 'I'
	 AND NVL(p_worker_num,-9) = NVL(worker_num,-9);


  l_interest_charged         DBMS_SQL.NUMBER_TABLE;
  l_payment_schedule_id      DBMS_SQL.NUMBER_TABLE;
  l_type                     DBMS_SQL.VARCHAR2_TABLE;
  l_original_trx_id          DBMS_SQL.NUMBER_TABLE;
  l_interest_header_id       DBMS_SQL.NUMBER_TABLE;
  l_interest_line_id         DBMS_SQL.NUMBER_TABLE;
  l_rec_trx_id               DBMS_SQL.NUMBER_TABLE;
  l_rec_name                 DBMS_SQL.VARCHAR2_TABLE;
  l_interest_batch_id        DBMS_SQL.NUMBER_TABLE;
  l_worker_num               DBMS_SQL.NUMBER_TABLE;
  l_process_status           DBMS_SQL.VARCHAR2_TABLE;
  l_process_msg              DBMS_SQL.VARCHAR2_TABLE;
  l_error_line_id            DBMS_SQL.NUMBER_TABLE;

  --For late_charge_date on payment schedules
  l_adjusted_ps              DBMS_SQL.NUMBER_TABLE;
  l_adjusted_ps_cnt          NUMBER := 0;

  l_last_fetch               BOOLEAN := FALSE;
  l_adj_meaning              VARCHAR2(80);
  s_gl_date                  DATE;
  s_cal_int_date             DATE;

  l_null_char                DBMS_SQL.VARCHAR2_TABLE;
  l_null_num                 DBMS_SQL.NUMBER_TABLE;
  l_null_date                DBMS_SQL.DATE_TABLE;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(10);
  l_adj_rec                  ar_adjustments%ROWTYPE;
  l_new_adjust_number        VARCHAR2(20);
  l_new_adjust_id            NUMBER;
  l_bulk_size                NUMBER;
  i                          NUMBER;
  j                          NUMBER := 0;
  err_cpt                    NUMBER := 0;
  x_nb_adj                   NUMBER;
  ll_msg_data                VARCHAR2(2000);
  cnt                        NUMBER;
  no_adj_to_process          EXCEPTION;
BEGIN
  outandlog( message  => 'create_charge_adj +');

  g_interest_batch_id := p_batch_id;
  arp_standard.debug('g_interest_batch_id:'||g_interest_batch_id);

  l_adj_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('AR_LATE_CHARGE_TYPE', 'ADJ');

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_msg_count       := 0;
  x_num_adj_created := 0;
  x_num_adj_error   := 0;


  insert_adj_process(x_nb_adj,p_worker_num);

  IF x_nb_adj = 0 THEN
    RAISE no_adj_to_process;
  END IF;

  IF p_api_bulk_size IS NULL OR p_api_bulk_size = 0 THEN
    l_bulk_size  := g_bulk_fetch_rows;
  ELSE
    l_bulk_size  := p_api_bulk_size;
  END IF;


  IF p_gl_date IS NULL OR p_cal_int_date IS NULL THEN
    OPEN c_gl_date;
    FETCH c_gl_date INTO s_gl_date,
                         s_cal_int_date;
    IF c_gl_date%NOTFOUND OR s_gl_date IS NULL THEN
      arp_standard.debug('  Late Charge Batch GL date and calculate interest date is required');
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'GL_DATE' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF c_gl_date%NOTFOUND OR s_cal_int_date IS NULL THEN
      arp_standard.debug('  Late Charge Batch calculate interest date is required');
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'calculate_interest_to_date' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_gl_date;
  ELSE
    s_gl_date      := p_gl_date;
    s_cal_int_date := p_cal_int_date;
  END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  OPEN cadj;
  LOOP
    FETCH cadj BULK COLLECT INTO
     l_interest_charged         ,
     l_payment_schedule_id      ,
     l_type                     ,
     l_original_trx_id          ,
     l_interest_header_id       ,
     l_interest_line_id         ,
     l_rec_trx_id               ,
     l_rec_name                 ,
     l_interest_batch_id        ,
     l_worker_num
     LIMIT l_bulk_size;

    IF cadj%NOTFOUND THEN
      l_last_fetch := TRUE;
    END IF;

    IF (l_original_trx_id.COUNT = 0) AND (l_last_fetch) THEN
      EXIT;
    END IF;

    j  := j + 1;
    log(' loop interation in create_adj num '||j);

    FOR i IN l_interest_line_id.FIRST .. l_interest_line_id.LAST LOOP


       l_adj_rec.payment_schedule_id := l_payment_schedule_id(i);
       l_adj_rec.apply_date          := s_cal_int_date;
       l_adj_rec.gl_date             := s_gl_date;
       l_adj_rec.receivables_trx_id  := l_rec_trx_id(i);
       l_adj_rec.created_from        := 'LATE_CHARGE_BATCH';
       l_adj_rec.adjustment_type     := 'A';
       l_adj_rec.type                := 'CHARGES';
       l_adj_rec.interest_header_id  := l_interest_header_id(i);
       l_adj_rec.interest_line_id    := l_interest_line_id(i);
       l_adj_rec.amount              := l_interest_charged(i);


     -- Call Adjustment api:
      log('Calling ar_adjust_pub.Create_Adjustment for interest_line_id : '||l_interest_line_id(i));


      ar_adjust_pub.Create_Adjustment (
          p_api_name          => 'AR_ADJUST_PUB',
          p_api_version       => 1.0,
          p_msg_count         => l_msg_count,
          p_msg_data          => l_msg_data,
          p_return_status     => l_return_status,
          p_adj_rec           => l_adj_rec,
          p_new_adjust_number => l_new_adjust_number,
          p_new_adjust_id     => l_new_adjust_id);


      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN


         l_process_status(i)  := 'E';
         x_num_adj_error            := x_num_adj_error + 1;

         IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
           x_return_status      := l_return_status;
           x_msg_data           := l_msg_data;
           x_msg_count          := l_msg_count;
         END IF;

         log('The adjustment creation fails customer_trx_id : '||l_rec_trx_id(i)||'
           payment_schedule_id : '||l_payment_schedule_id(i));

         IF l_msg_count > 1 THEN
            ll_msg_data := NULL;
            FOR cnt IN 1..l_msg_count LOOP
                ll_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                                               FND_API.G_FALSE);
                log(' error text : '|| ll_msg_data);
                l_msg_data := SUBSTRB(l_msg_data||ll_msg_data,1,2000);
            END LOOP;
         END IF;

         l_process_msg(i)     := SUBSTRB(l_msg_data,1,2000);

      ELSE

         l_process_status(i)  := 'S';
         l_process_msg(i)     := 'Adjustment_id:'||l_new_adjust_id;
         x_num_adj_created  := x_num_adj_created + 1;

         --Update Payment_Schedule Late_Charge_Date
         l_adjusted_ps_cnt := l_adjusted_ps_cnt + 1;
         l_adjusted_ps(l_adjusted_ps_cnt) := l_payment_schedule_id(i);

         outandlog('The adjustment creation succes customer_trx_id : '||l_rec_trx_id(i)||'
           payment_schedule_id : '||l_payment_schedule_id(i)||'
           with the adjustment number : '|| l_new_adjust_number);

      END IF;

    END LOOP;

    --Update Payment_Schedule Late_Charge_Date HYU
    IF l_adjusted_ps.COUNT > 0 THEN
      log( message  => 'Updating ar_payment_schedules late_charge_date for adjustments');

      FORALL i IN l_adjusted_ps.FIRST .. l_adjusted_ps.LAST
      UPDATE ar_payment_schedules
         SET last_charge_date = s_cal_int_date
       WHERE payment_schedule_id  = l_adjusted_ps(i);

     l_adjusted_ps_cnt := 0;
     l_adjusted_ps     := l_null_num;
    END IF;
    --}

    IF l_interest_line_id.COUNT > 0 THEN
      FORALL i IN l_interest_line_id.FIRST .. l_interest_line_id.LAST
      UPDATE ar_late_charge_doc_gt
         SET execution_status = l_process_status(i),
             LINE_ERR_MSG     = l_process_msg(i)
       WHERE interest_line_id  = l_interest_line_id(i)
         AND interest_batch_id = g_interest_batch_id;

      log( message  => 'Updating ar_interest_lines process_status for adjustment');

      FORALL i IN l_interest_line_id.FIRST .. l_interest_line_id.LAST
      UPDATE ar_interest_lines
         SET PROCESS_STATUS   = l_process_status(i),
             PROCESS_MESSAGE  = l_process_msg(i)
       WHERE interest_line_id  = l_interest_line_id(i);
     END IF;

     l_interest_charged      := l_null_num;
     l_payment_schedule_id   := l_null_num;
     l_type                  := l_null_char;
     l_original_trx_id       := l_null_num;
     l_interest_header_id    := l_null_num;
     l_interest_line_id      := l_null_num;
     l_rec_trx_id            := l_null_num;
     l_rec_name              := l_null_char;
     l_interest_batch_id     := l_null_num;
     l_worker_num            := l_null_num;
     l_process_status        := l_null_char;
     l_process_msg           := l_null_char;


     COMMIT;

  END LOOP;
  CLOSE cadj;


  log( message  => 'Updating ar_interest_headers for adjustment in Error');

  UPDATE ar_interest_headers a
     SET a.process_status = 'E'
   WHERE a.interest_batch_id    = g_interest_batch_id
     AND DECODE(p_worker_num,NULL,NVL(a.worker_num,-9),p_worker_num)=NVL(a.worker_num,-9)
     AND a.header_type          = 'ADJ'
     AND a.display_flag         = 'Y' --HYU CDI only document generating the Late Charge s Doc
     AND EXISTS
     (SELECT NULL
        FROM ar_interest_lines b
       WHERE b.interest_header_id = a.interest_header_id
         AND b.process_status     = 'E');

  log( message  => 'Updating ar_interest_headers for adjustment in Success');
  UPDATE ar_interest_headers a
     SET a.process_status = 'S',
         a.process_message= NULL
   WHERE a.interest_batch_id = g_interest_batch_id
     AND a.header_type       = 'ADJ'
     AND a.process_status    = 'N'
     AND a.display_flag      = 'Y' --HYU CDI only document generating the Late Charge s Doc
     AND DECODE(p_worker_num,NULL,NVL(a.worker_num,-9),p_worker_num)=NVL(a.worker_num,-9);


--{Update the last_accrue_date for customer account site uses
  log( message  => 'Updating hz_cust_site_uses for adjustment in Success');
   UPDATE hz_cust_site_uses
      SET LAST_ACCRUE_CHARGE_DATE = s_cal_int_date
    WHERE SITE_USE_ID  IN
  (SELECT DISTINCT customer_site_use_id
     FROM ar_interest_headers h
    WHERE h.process_status     = 'S'
      AND h.interest_batch_id  = g_interest_batch_id
      AND h.header_type        = 'ADJ'
      AND h.display_flag       = 'Y' --HYU CDI only document generating the Late Charge s Doc
      AND DECODE(p_worker_num,NULL,NVL(h.worker_num,-9),p_worker_num)=NVL(h.worker_num,-9));
--}
  outandlog( message  => 'create_charge_adj -');

EXCEPTION
  WHEN  no_adj_to_process THEN
    NULL;
  WHEN  FND_API.G_EXC_ERROR THEN
      IF cadj%ISOPEN THEN CLOSE cadj; END IF;
      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
      outandlog( message  => ' EXCEPTION FND_API.G_EXC_ERROR create_charge_adj :'||x_msg_data);

  WHEN OTHERS THEN
      IF cadj%ISOPEN THEN CLOSE cadj; END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
      outandlog( message  => ' EXCEPTION OTHERS create_charge_adj :'||SQLERRM);
END;


PROCEDURE write_exec_report
IS

  CURSOR nb_of_inv IS
  SELECT count(*)         nb,
         execution_status status
    FROM (select interest_header_id    interest_header_id,
                 MIN(execution_status) execution_status
            FROM ar_late_charge_doc_gt
           WHERE interest_batch_id = g_interest_batch_id
             AND header_type       = 'INV'
             AND execution_status IN ('E','S')
           GROUP BY interest_header_id)  b
   GROUP BY execution_status;


  CURSOR nb_of_dm IS
  SELECT count(*)         nb,
         execution_status status
    FROM (select interest_header_id    interest_header_id,
                 MIN(execution_status) execution_status
            FROM ar_late_charge_doc_gt
           WHERE interest_batch_id = g_interest_batch_id
             AND header_type       = 'DM'
             AND execution_status IN ('E','S')
           GROUP BY interest_header_id)  b
   GROUP BY execution_status;


  CURSOR nb_of_adjustment IS
  SELECT count(*)         nb,
         execution_status status
    FROM ar_late_charge_doc_gt
   WHERE interest_batch_id = g_interest_batch_id
     AND header_type       = 'ADJ'
   GROUP BY execution_status;
  l_count         DBMS_SQL.NUMBER_TABLE;
  l_status        DBMS_SQL.VARCHAR2_TABLE;
  l_clr_count     DBMS_SQL.NUMBER_TABLE;
  l_clr_status    DBMS_SQL.VARCHAR2_TABLE;
  l_batch_status  VARCHAR2(1) := 'S';

  PROCEDURE set_batch_status
  (p_status       IN         VARCHAR2,
   x_batch_status OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   IF    p_status = 'E' THEN
      l_batch_status := 'E';
   ELSIF p_status = 'I' THEN
      IF l_batch_status = 'S' THEN
         l_batch_status := NULL;
      END IF;
   END IF;
  END;

BEGIN
  log('write_exec_report  +');
  outandlog('The submission for late charges creation:');
  outandlog('  interest_batch_id:'||g_interest_batch_id);

  OPEN nb_of_adjustment;
  FETCH nb_of_adjustment BULK COLLECT INTO
    l_count ,
    l_status;
  CLOSE nb_of_adjustment;

  IF l_status.COUNT > 0 THEN
  FOR i IN l_status.FIRST..l_status.LAST LOOP
    IF     l_status(i) = 'S' THEN
       outandlog('  Number of adjustment successfully created:'|| l_count(i));
    ELSIF  l_status(i) = 'E' THEN
       outandlog('  Number of adjustment in error:'|| l_count(i));
    ELSE
       outandlog('  Number of adjustment in status '|| l_status(i) ||':' || l_count(i));
    END IF;
    set_batch_status(l_status(i),l_batch_status);
  END LOOP;
  l_count      := l_clr_count;
  l_status     := l_clr_status;
  END IF;

  OPEN nb_of_inv;
  FETCH nb_of_inv BULK COLLECT INTO
    l_count ,
    l_status;
  CLOSE nb_of_inv;

  IF l_status.COUNT > 0 THEN
  FOR i IN l_status.FIRST..l_status.LAST LOOP
    IF     l_status(i) = 'S' THEN
       outandlog('  Number of invoice successfully created:'|| l_count(i));
    ELSIF  l_status(i) = 'E' THEN
       outandlog('  Number of invoice in error:'|| l_count(i));
    ELSE
       outandlog('  Number of invoice in status '|| l_status(i) ||':' || l_count(i));
    END IF;
    set_batch_status(l_status(i),l_batch_status);
  END LOOP;
  l_count      := l_clr_count;
  l_status     := l_clr_status;
  END IF;

  OPEN nb_of_dm;
  FETCH nb_of_dm BULK COLLECT INTO
    l_count ,
    l_status;
  CLOSE nb_of_dm;

  IF l_status.COUNT > 0 THEN
  FOR i IN l_status.FIRST..l_status.LAST LOOP
    IF     l_status(i) = 'S' THEN
       outandlog('  Number of invoice successfully created:'|| l_count(i));
    ELSIF  l_status(i) = 'E' THEN
       outandlog('  Number of invoice in error:'|| l_count(i));
    ELSIF  l_status(i) = 'I' THEN
       outandlog('  Number of invoice not executed:'|| l_count(i));
    ELSE
       outandlog('  Number of invoice in status '|| l_status(i) ||':' || l_count(i));
    END IF;
    set_batch_status(l_status(i),l_batch_status);
  END LOOP;
  END IF;
  log('write_exec_report  -');
END;


PROCEDURE create_late_charge_child
 (errbuf                  OUT NOCOPY   VARCHAR2,
  retcode                 OUT NOCOPY   VARCHAR2,
  p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER,
  p_gl_date               IN DATE,
  p_cal_int_date          IN DATE,
  p_api_bulk_size         IN NUMBER)
IS
  x_num_adj_created         NUMBER;
  x_num_adj_error           NUMBER;
  x_return_status           VARCHAR2(10);
  x_msg_count               NUMBER;
  x_msg_data                VARCHAR2(2000);

  CURSOR c_err IS
  SELECT NULL
    FROM ar_interest_headers
  WHERE interest_batch_id = g_interest_batch_id
    AND process_status  = 'E'
    AND display_flag    = 'Y' --HYU CDI only document generating the Late Charge s Doc
    AND header_type IN ('INV','DM');
  l_err_found    VARCHAR2(1);

  CURSOR c_one_doc_success IS
  SELECT NULL
    FROM ar_interest_headers
  WHERE interest_batch_id = g_interest_batch_id
    AND process_status  = 'S'
    AND display_flag    = 'Y';  -- Document generating a Late Charges Document

  l_success_found        VARCHAR2(1);

BEGIN
  log('create_late_charge  +');

  DELETE FROM ar_late_charge_doc_gt;

  UPDATE ar_interest_headers a
     SET a.process_message  = ''
   WHERE a.interest_batch_id = p_batch_id
     AND a.display_flag      = 'Y'; --HYU CDI only document generating the Late Charge s Doc

  UPDATE ar_interest_lines a
     SET a.process_message  = ''
   WHERE a.interest_header_id IN
    (SELECT interest_header_id
	   FROM ar_interest_headers
	  WHERE interest_batch_id = p_batch_id
        AND display_flag      = 'Y'); --HYU CDI only document generating the Late Charge s Doc




  retcode := 0;
  outandlog( message  =>'create_late_charge per site for the batch:'||p_batch_id );
  outandlog( message  =>'  Starting at ' || to_char(SYSDATE, 'HH24:MI:SS') );
  outandlog( message  =>'  p_cal_int_date         :'||p_cal_int_date);
  outandlog( message  =>'  p_cal_int_date         :'||p_cal_int_date);
  outandlog( message  =>'  p_api_bulk_size        :'||p_api_bulk_size);

  x_return_status := fnd_api.g_ret_sts_success;
  log('1 create_charge_adj...');

  create_charge_adj
   (p_batch_id         => p_batch_id,
    p_gl_date          => p_gl_date,
    p_cal_int_date     => p_cal_int_date,
    p_api_bulk_size    => p_api_bulk_size,
    x_num_adj_created  => x_num_adj_created,
    x_num_adj_error    => x_num_adj_error,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
     retcode := 1;
     errbuf  := 'Some Charge Adjustments have failed,
please verify the data in ar_interest_headers and lines tables with the batch_id :'||g_interest_batch_id;
     log(errbuf);
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   log('2 create_charge_inv_dm...');
   create_charge_inv_dm
   (p_batch_source_id => p_batch_source_id,
    p_batch_id        => p_batch_id,
    p_gl_date         => p_gl_date,
    p_cal_int_date    => p_cal_int_date,
    p_api_bulk_size   => p_api_bulk_size,
    x_return_status   => x_return_status,
    x_msg_count       => x_msg_count,
    x_msg_data        => x_msg_data);


  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    retcode := 1;
    errbuf  := 'Some Charge invoice, debit memo have failed
please verify the data in ar_interest_headers and lines tables with the batch_id :'||g_interest_batch_id;
    log(errbuf);
  ELSE
    OPEN c_err;
    FETCH c_err INTO l_err_found;
    IF c_err%FOUND THEN
    retcode := 1;
    errbuf  := 'Some Charge invoice, debit memo have failed
please verify the data in ar_interest_headers and lines tables with the batch_id :'||g_interest_batch_id;
    log(errbuf);
    END IF;
    CLOSE c_err;

    --{ HYU CDI included in the calculation
    OPEN c_one_doc_success;
    FETCH c_one_doc_success INTO l_success_found;
    IF  c_one_doc_success%FOUND THEN
    --{ HYU CDI included in calculation without generating the late charges document
    UPDATE ar_payment_schedules
      SET last_charge_date = g_int_cal_date
     WHERE payment_schedule_id IN
     (SELECT l.PAYMENT_SCHEDULE_ID
        FROM ar_interest_headers h,
             ar_interest_lines   l
       WHERE h.interest_batch_id  = g_interest_batch_id
         AND h.display_flag       = 'N' -- Document included in Late Charges Calculation
         AND h.process_status     = 'N'
         AND h.interest_header_id = l.interest_header_id);

    UPDATE ar_interest_headers
       SET process_status = 'S'
     WHERE interest_batch_id  = g_interest_batch_id
       AND display_flag       = 'N' -- Document included in Late Charges Calculation
       AND process_status     = 'N';
    --}
    END IF;
    CLOSE c_one_doc_success;


  END IF;

  IF retcode = 1 THEN
    errbuf  := errbuf||'-Please check the log file for detail';
  END IF;

  write_exec_report;

  FND_FILE.close;
EXCEPTION
  WHEN fnd_Api.g_exc_error THEN
      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
    retcode := 1;
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('Batch en error ' || x_msg_data);
    errbuf := errbuf || logerror || x_msg_data;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;

  WHEN OTHERS THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('SQL Error ' || SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror || SQLERRM;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
END;


PROCEDURE submit_late_charge_child
(p_batch_id              IN  NUMBER,
 p_batch_source_id       IN  NUMBER,
 p_gl_date               IN  DATE,
 p_cal_int_date          IN  DATE,
 p_api_bulk_size         IN  NUMBER,
 x_out_request_id        OUT NOCOPY NUMBER)
IS
 lc_sub_pb    EXCEPTION;
BEGIN
  FND_REQUEST.SET_ORG_ID(g_org_id);
  x_out_request_id := FND_REQUEST.SUBMIT_REQUEST(
                         application=>'AR',
                         program    =>'ARLCPS',
                         sub_request=>FALSE,
                         argument1  => p_batch_source_id,
                         argument2  => p_batch_id,
                         argument3  => p_gl_date,
                         argument4  => p_cal_int_date,
                         argument5  => p_api_bulk_size );
  IF x_out_request_id <> 0 THEN
     INSERT INTO ar_submission_ctrl_gt
     (worker_id         , --p_batch_source_id
      batch_id          , --
      script_name       , --script_name
      status            , --
      order_num         , --order helper number
      request_id        , --request_id
      table_name        ) --table_name
      VALUES
     (p_batch_source_id,
      NULL,
      'ARLCPS',
      'SUBMITTED',
      1,
      x_out_request_id,
      'ARLC');
     COMMIT;
  ELSE
     RAISE lc_sub_pb;
  END IF;
EXCEPTION
  WHEN lc_sub_pb THEN
     log(logerror(SQLERRM));
  WHEN OTHERS THEN
     log(logerror(SQLERRM));
END;


PROCEDURE wait_for_end_subreq(
 p_interval       IN  NUMBER   DEFAULT 60
,p_max_wait       IN  NUMBER   DEFAULT 180
,p_sub_name       IN  VARCHAR2)
IS
  CURSOR reqs IS
  SELECT request_id
    FROM ar_submission_ctrl_gt
   WHERE status      <> 'COMPLETE'
     AND script_name = p_sub_name;
  l_req_id      NUMBER;
  l_phase       VARCHAR2(50);
  l_status      VARCHAR2(50);
  l_dev_phase   VARCHAR2(50);
  l_dev_status  VARCHAR2(50);
  l_message     VARCHAR2(2000);
  l_complete    BOOLEAN;
  done          EXCEPTION;
BEGIN
  log('wait_for_end_subreq :'|| p_sub_name ||' to finish');
  LOOP
    OPEN reqs;
    LOOP
      FETCH reqs INTO l_req_id;
      EXIT WHEN reqs%NOTFOUND;

      FND_REQUEST.SET_ORG_ID(g_org_id);
      l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
		       request_id=>l_req_id,
		       interval=>p_interval,
		       max_wait=>p_max_wait,
		       phase=>l_phase,
		       status=>l_status,
		       dev_phase=>l_dev_phase,
		       dev_status=>l_dev_status,
		       message=>l_message);
       IF l_dev_phase = 'COMPLETE' THEN
        UPDATE ar_submission_ctrl_gt
           SET status = 'COMPLETE'
         WHERE request_id = l_req_id;
       END IF;
    END LOOP;
    CLOSE reqs;

    OPEN reqs;
    FETCH reqs INTO l_req_id;
    IF reqs%NOTFOUND THEN
      RAISE done;
    END IF;
    CLOSE reqs;
  END LOOP;
EXCEPTION
  WHEN done THEN
    IF reqs%ISOPEN THEN
       CLOSE reqs;
    END IF;
  WHEN OTHERS THEN
    IF reqs%ISOPEN THEN
       CLOSE reqs;
    END IF;
    RAISE;
END;

PROCEDURE get_status_for_sub_process
(p_sub_name     IN VARCHAR2,
 x_status      OUT NOCOPY VARCHAR2)
IS
  CURSOR reqs IS
  SELECT request_id
    FROM ar_submission_ctrl_gt
   WHERE status      = 'COMPLETE'
     AND script_name = p_sub_name;
  l_req_id    NUMBER;
  lbool       BOOLEAN;
  lphase      VARCHAR2(80);
  lstatus     VARCHAR2(80);
  dphase      VARCHAR2(30);
  dstatus     VARCHAR2(30);
  lmessage    VARCHAR2(240);
  PROCEDURE set_status
  (p_status  IN            VARCHAR2,
   x_status  IN OUT NOCOPY VARCHAR2) IS
  BEGIN
    IF x_status = 'E' THEN
      RETURN;
    ELSE
      IF     p_status <> 'NORMAL' THEN
        x_status := 'E';
      END IF;
    END IF;
  END;
BEGIN
  x_status  := 'S';
  OPEN reqs;
  LOOP
    FETCH reqs INTO l_req_id;
    EXIT WHEN reqs%NOTFOUND;
    lbool := FND_CONCURRENT.GET_REQUEST_STATUS
             (request_id    => l_req_id,
              phase         => lphase,
              status        => lstatus,
              dev_phase     => dphase,
              dev_status    => dstatus,
              message       => lmessage);
    IF lbool THEN
       set_status(dstatus,x_status);
    END IF;
  END LOOP;
  CLOSE reqs;
END;


PROCEDURE create_late_charge
 (errbuf                  OUT NOCOPY   VARCHAR2,
  retcode                 OUT NOCOPY   VARCHAR2,
  p_max_workers           IN NUMBER   DEFAULT 4,
  p_interval              IN NUMBER   DEFAULT 60,
  p_max_wait              IN NUMBER   DEFAULT 180,
  p_api_bulk_size         IN NUMBER   DEFAULT 1000,
  p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER )
IS
  CURSOR c IS
  SELECT transferred_status,
         object_version_number,
         CALCULATE_INTEREST_TO_DATE,
         BATCH_STATUS,
         GL_DATE
    FROM ar_interest_batches
   WHERE interest_batch_id = g_interest_batch_id;

  l_transferred_status            VARCHAR2(1);
  x_object_version_number       NUMBER;
  l_CALCULATE_INTEREST_TO_DATE  DATE;
  l_BATCH_STATUS                VARCHAR2(30);
  l_GL_DATE                     DATE;

  CURSOR c_site IS
  SELECT DISTINCT customer_site_use_id
    FROM ar_interest_headers
   WHERE interest_batch_id = g_interest_batch_id
     AND process_status    = 'N';

  CURSOR c_batch_source IS
  SELECT NULL
    FROM ra_batch_sources
   WHERE BATCH_SOURCE_ID = p_batch_source_id;

  CURSOR c_err IS
  SELECT NULL
    FROM ar_interest_headers
   WHERE interest_batch_id = g_interest_batch_id;

  l_err                     VARCHAR2(1);
  l_test                    VARCHAR2(1);
  l_customer_site_use_id    DBMS_SQL.NUMBER_TABLE;
  x_num_adj_created         NUMBER;
  x_num_adj_error           NUMBER;
  x_return_status           VARCHAR2(10);
  x_msg_count               NUMBER;
  x_msg_data                VARCHAR2(2000);
  l_request_id              NUMBER;
  l_exec_srs                VARCHAR2(1) := 'N';
BEGIN
  log('create_late_charge  +');

  retcode := 0;
  g_interest_batch_id := p_batch_id;

  outandlog( message  =>'create_late_charge for the batch:'||p_batch_id );
  outandlog( message  =>'  Starting at ' || to_char(SYSDATE, 'HH24:MI:SS') );

  x_return_status := fnd_api.g_ret_sts_success;

  IF   p_batch_source_id  IS NULL THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_source_id' );
     FND_MSG_PUB.ADD;
     x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
  ELSE
     OPEN c_batch_source;
     FETCH c_batch_source INTO l_test;
     IF c_batch_source%NOTFOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
        FND_MESSAGE.SET_TOKEN( 'FK', 'batch_source_id' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_source_id' );
        FND_MESSAGE.SET_TOKEN( 'TABLE', 'ra_batch_sources');
        FND_MSG_PUB.ADD;
        x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
     END IF;
     CLOSE c_batch_source;
  END IF;

  OPEN c;
  FETCH c INTO l_transferred_status,
               x_object_version_number,
               l_CALCULATE_INTEREST_TO_DATE,
               l_BATCH_STATUS,
               l_GL_DATE;
  IF    c%NOTFOUND THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
      FND_MESSAGE.SET_TOKEN( 'FK', 'batch_id' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_id' );
      FND_MESSAGE.SET_TOKEN( 'TABLE', 'ar_interest_batches');
      FND_MSG_PUB.ADD;
      x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch not found with the interest_batch_id :'||p_batch_id);
  ELSE
    IF l_BATCH_STATUS  <> 'F' OR l_BATCH_STATUS IS NULL THEN
      fnd_message.set_name('AR', 'AR_ONLY_VALUE_ALLOWED');
      fnd_message.set_token('COLUMN', 'BATCH_STATUS');
      fnd_message.set_token('VALUES', 'F');
      fnd_msg_pub.add;
      retcode := 2;
      x_return_status := fnd_api.g_ret_sts_error;
      outandlog('Interest Batch batch_status should be Final to import interest_batch_id :'||p_batch_id);
    END IF;
    IF l_CALCULATE_INTEREST_TO_DATE IS NULL THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'CALCULATE_INTEREST_TO_DATE' );
      FND_MSG_PUB.ADD;
      x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch calculation interest to date is mandatory interest_batch_id :'||p_batch_id);
    END IF;
    IF l_GL_DATE IS NULL THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'GL_DATE' );
      FND_MSG_PUB.ADD;
      x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch GL date is mandatory interest_batch_id :'||p_batch_id);
    END IF;
    IF l_transferred_status = 'S' THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      FND_MESSAGE.SET_TOKEN( 'STATUS', l_transferred_status );
      fnd_msg_pub.add;
      retcode := 1;
      x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch already successfully transferred interest_batch_id :'||p_batch_id);
    ELSIF l_transferred_status = 'E' THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      FND_MESSAGE.SET_TOKEN( 'STATUS', l_transferred_status );
      fnd_msg_pub.add;
      retcode := 1;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch is in Error, please fix it before submitting interest_batch_id :'||p_batch_id);
    ELSIF l_transferred_status = 'P' THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      FND_MESSAGE.SET_TOKEN( 'STATUS', l_transferred_status );
      fnd_msg_pub.add;
      retcode := 1;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch is in process, can not resubmit interest_batch_id :'||p_batch_id);
    ELSIF l_transferred_status = 'N' THEN
      outandlog('Processing the batch  interest_batch_id :'||p_batch_id);
    ELSIF l_transferred_status IS NOT NULL THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      FND_MESSAGE.SET_TOKEN( 'STATUS', l_transferred_status);
      fnd_msg_pub.add;
      fnd_message.set_name('AR', 'AR_ONLY_VALUES_ALLOWED');
      fnd_message.set_token('COLUMN', 'TRANSFERRED_STATUS');
      fnd_message.set_token('VALUES', 'P,E,N,S');
      fnd_msg_pub.add;
      retcode := 2;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch transferred flag should be in (NULL,S,E) no other value permitted  interest_batch_id :'||p_batch_id);
    END IF;
  END IF;
  CLOSE c;

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_Api.g_exc_unexpected_error;
  END IF;

  log('Updating the batch status to Pending to start the process...');
  AR_INTEREST_BATCHES_PKG.update_batch
   (p_init_msg_list              => 'T',
    P_INTEREST_BATCH_ID          => g_interest_batch_id,
    P_BATCH_STATUS               => 'F',
    P_TRANSFERRED_status         => 'P',
    p_updated_by_program         => 'ARLCSM',
    x_OBJECT_VERSION_NUMBER      => x_object_version_number,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_Api.g_exc_error;
  END IF;

  OPEN c_site;
  FETCH c_site BULK COLLECT INTO l_customer_site_use_id;
  CLOSE c_site;


  IF l_customer_site_use_id.COUNT <> 0 THEN
  FOR i IN l_customer_site_use_id.FIRST..l_customer_site_use_id.LAST LOOP
    --submission of late charge per site use
    submit_late_charge_child
    (p_batch_id              => p_batch_id,
     p_batch_source_id       => p_batch_source_id,
     p_gl_date               => l_GL_DATE,
     p_cal_int_date          => l_CALCULATE_INTEREST_TO_DATE,
     p_api_bulk_size         => p_api_bulk_size,
     x_out_request_id        => l_request_id);
  END LOOP;

  wait_for_end_subreq(
    p_interval       => p_interval
   ,p_max_wait       => p_max_wait
   ,p_sub_name       => 'ARLCPS' );
  END IF;

  log( message  => 'Updating interest batch status to :'||l_batch_status||' for batch_id :'||g_interest_batch_id);

  get_status_for_sub_process
  (p_sub_name     => 'ARLCPS',
   x_status       => l_transferred_status);

--  UPDATE ar_interest_batches
--     SET TRANSFERRED_STATUS  = l_transferred_status,
--         object_version_number = x_object_version_number + 1
--   WHERE interest_batch_id = g_interest_batch_id;

  OPEN c_err;
  FETCH c_err INTO l_err;
  IF c_err%NOTFOUND THEN
    AR_INTEREST_BATCHES_PKG.update_batch
    (p_init_msg_list              => 'T',
     P_INTEREST_BATCH_ID          => g_interest_batch_id,
     P_BATCH_STATUS               => 'F',
     P_TRANSFERRED_STATUS         => l_transferred_status,
     p_updated_by_program         => 'ARLCSM',
     x_OBJECT_VERSION_NUMBER      => x_object_version_number,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);
  ELSE
    AR_INTEREST_BATCHES_PKG.update_batch
    (p_init_msg_list              => 'T',
     P_INTEREST_BATCH_ID          => g_interest_batch_id,
     P_BATCH_STATUS               => 'F',
     P_TRANSFERRED_STATUS         => 'E',
     p_updated_by_program         => 'ARLCSM',
     x_OBJECT_VERSION_NUMBER      => x_object_version_number,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);
     log('Some documents are in error in in the batch :'||g_interest_batch_id);
     errbuf   := 'Some documents are in error in in the batch :'||g_interest_batch_id;
     retcode  := 1;
  END IF;

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_Api.g_exc_error;
  END IF;

  outandlog( message  =>'  End at ' || to_char(SYSDATE, 'HH24:MI:SS') );
  outandlog( message  =>'End create_late_charge for the batch:'||p_batch_id||' Please check log files' );
EXCEPTION
  WHEN fnd_Api.g_exc_unexpected_error THEN
      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);

    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('Batch en error ' || x_msg_data);
    errbuf := errbuf || logerror || x_msg_data;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
  WHEN fnd_Api.g_exc_error THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('Batch en error ' || x_msg_data);
    errbuf := errbuf || logerror || x_msg_data;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;

  WHEN OTHERS THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('SQL Error ' || SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror || SQLERRM;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
END;


PROCEDURE create_late_charge_per_worker
( errbuf                  OUT NOCOPY   VARCHAR2,
  retcode                 OUT NOCOPY   VARCHAR2,
  p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER,
  p_worker_num            IN NUMBER,
  p_gl_date               IN DATE,
  p_cal_int_date          IN DATE,
  p_api_bulk_size         IN NUMBER)
IS
  x_num_adj_created         NUMBER;
  x_num_adj_error           NUMBER;
  x_return_status           VARCHAR2(10);
  x_msg_count               NUMBER;
  x_msg_data                VARCHAR2(2000);
  CURSOR c_err IS
  SELECT NULL
    FROM ar_interest_headers
  WHERE interest_batch_id = g_interest_batch_id
    AND process_status  = 'E'
    AND display_flag    = 'Y'  -- Document generating a Late Charges Document
    AND p_worker_num    = worker_num
    AND header_type IN ('INV','DM');

  CURSOR c_one_doc_success IS
  SELECT 'Y'
    FROM ar_interest_headers
  WHERE interest_batch_id = g_interest_batch_id
    AND process_status  = 'S'
    AND display_flag    = 'Y'  -- Document generating a Late Charges Document
    AND p_worker_num    = worker_num;

  CURSOR c_dm_exist IS
  SELECT 'Y'
    FROM ar_interest_headers
  WHERE interest_batch_id = g_interest_batch_id
    AND process_status  = 'N'
    AND display_flag    = 'N'; -- Document included in the calculation without generating late charges

  l_dm_exist         VARCHAR2(1);
  l_err_found        VARCHAR2(1);
  l_success_found    VARCHAR2(1);
BEGIN
  log('create_late_charge_per_worker  +');
  outandlog( message  =>'create_late_charge per worker for the batch:'||p_batch_id );
  outandlog( message  =>'  Starting at ' || to_char(SYSDATE, 'HH24:MI:SS') );
  outandlog( message  =>'  p_worker_num           :'||p_worker_num);
  outandlog( message  =>'  p_batch_source_id      :'||p_batch_source_id);
  outandlog( message  =>'  p_cal_int_date         :'||p_cal_int_date);
  outandlog( message  =>'  p_gl_date              :'||p_gl_date);
  outandlog( message  =>'  p_api_bulk_size        :'||p_api_bulk_size);


  DELETE FROM ar_late_charge_doc_gt;

  UPDATE ar_interest_headers a
     SET a.process_message   = ''
   WHERE a.interest_batch_id = p_batch_id
     AND a.worker_num        = p_worker_num
     AND a.display_flag      = 'Y';  -- Document generating a Late Charges Document
                                     -- no need to include Credit Debit items
                                     -- as no error messages will be tied to such an item
  UPDATE ar_interest_lines a
     SET a.process_message  = ''
   WHERE a.interest_header_id IN
    (SELECT interest_header_id
	   FROM ar_interest_headers
	  WHERE interest_batch_id = p_batch_id
	    AND display_flag      = 'Y' -- Document generating a Late Charges Document
        AND worker_num        = p_worker_num);

  retcode         := 0;
  x_return_status := fnd_api.g_ret_sts_success;
  log('1 create_charge_adj...');

  create_charge_adj
   (p_batch_id         => p_batch_id,
    p_worker_num       => p_worker_num,
    p_gl_date          => p_gl_date,
    p_cal_int_date     => p_cal_int_date,
    p_api_bulk_size    => p_api_bulk_size,
    x_num_adj_created  => x_num_adj_created,
    x_num_adj_error    => x_num_adj_error,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
     retcode := 1;
     errbuf  := SUBSTRB('Some Charge Adjustments have failed,
please verify the data in ar_interest_headers and lines tables with the batch_id :'||g_interest_batch_id,1,239);
     log(errbuf);
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   log('2 create_charge_inv_dm...');
   create_charge_inv_dm
   (p_batch_source_id => p_batch_source_id,
    p_batch_id        => p_batch_id,
    p_worker_num      => p_worker_num,
    p_gl_date         => p_gl_date,
    p_cal_int_date    => p_cal_int_date,
    p_api_bulk_size   => p_api_bulk_size,
    x_return_status   => x_return_status,
    x_msg_count       => x_msg_count,
    x_msg_data        => x_msg_data);


  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    retcode := 1;
    errbuf  := SUBSTRB('Some Charge invoice, debit memo have failed
please verify the data in ar_interest_headers and lines tables with the batch_id :'||g_interest_batch_id,1,239);
    log(errbuf);
  ELSE
    OPEN c_err;
    FETCH c_err INTO l_err_found;
    IF c_err%FOUND THEN
    retcode := 1;
    errbuf  := SUBSTRB('Some Charge invoice, debit memo have failed
please verify the data in ar_interest_headers and lines tables with the batch_id :'||g_interest_batch_id,1,239);
    log(errbuf);
    END IF;
    CLOSE c_err;

    --{ HYU CDI included in the calculation
    OPEN c_one_doc_success;
    FETCH c_one_doc_success INTO l_success_found;
    IF  c_one_doc_success%NOTFOUND THEN
       l_success_found := 'N';
       l_dm_exist      := 'N';
    END IF;
    CLOSE c_one_doc_success;

    IF l_success_found = 'Y' THEN
      OPEN c_dm_exist;
      FETCH c_dm_exist INTO l_dm_exist;
      IF c_dm_exist%NOTFOUND THEN
        l_dm_exist := 'N';
      END IF;
      CLOSE c_dm_exist;
    END IF;

    log('l_success_found: '||l_success_found);
    log('l_dm_exist     : '||l_dm_exist);

    IF  l_dm_exist = 'Y' THEN
      --{ HYU CDI included in calculation without generating the late charges document
      UPDATE ar_payment_schedules
         SET last_charge_date = g_int_cal_date
       WHERE payment_schedule_id IN
        (SELECT l.PAYMENT_SCHEDULE_ID
           FROM ar_interest_headers h,
                ar_interest_lines   l
          WHERE h.interest_batch_id  = g_interest_batch_id
            AND h.display_flag       = 'N' -- Document included in Late Charges Calculation
            AND h.process_status     = 'N'
            AND h.interest_header_id = l.interest_header_id);

      UPDATE ar_interest_headers
         SET process_status = 'S'
       WHERE interest_batch_id  = g_interest_batch_id
         AND display_flag       = 'N' -- Document included in Late Charges Calculation
         AND process_status     = 'N';
        --}
    END IF;

  END IF;

  IF retcode = 0 THEN
    COMMIT;
  END IF;

  write_exec_report;


  FND_FILE.close;
EXCEPTION
  WHEN fnd_Api.g_exc_error THEN
      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
    retcode := 1;
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('Batch en error ' || x_msg_data);
    errbuf := errbuf || logerror || x_msg_data;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;

  WHEN OTHERS THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('SQL Error ' || SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror || SQLERRM;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
END;




PROCEDURE ordonancer_per_worker
( p_worker_num            IN NUMBER,
  p_request_id            IN NUMBER)
IS
  CURSOR c IS
  SELECT MAX(b.request_id)  request_id,
         b.interest_batch_id,
         b.org_id,
         b.gl_date,
         b.calculate_interest_to_date,
         s.late_charge_batch_source_id,
         lg.currency_code
    FROM ar_interest_batches_all   b,
         ar_interest_headers_all   h,
         ar_system_parameters_all  s,
         gl_ledgers                lg
   WHERE b.request_id        = p_request_id
     AND b.org_id            = s.org_id
     AND b.interest_batch_id = h.interest_batch_id
     AND h.worker_num        = p_worker_num
     AND h.display_flag      = 'Y' --HYU CDI only document generating the Late Charge s Doc
     AND lg.ledger_id        = s.set_of_books_id
   GROUP BY
         b.interest_batch_id,
         b.org_id,
         b.gl_date,
         b.calculate_interest_to_date,
         s.late_charge_batch_source_id,
         lg.currency_code;

--{Check if the interest batch has some INV or DM before requiring the batch_source_id
  CURSOR ht(p_request_id IN NUMBER, p_worker_num IN NUMBER) IS
  SELECT NULL
    FROM ar_interest_headers_all
   WHERE request_id  = p_request_id
     AND worker_num  = p_worker_num
     AND display_flag  = 'Y' --HYU CDI only document generating the Late Charge s Doc
     AND header_type IN ('INV','DM');
--}
  l_test                         VARCHAR2(1);
  l_request_id                   NUMBER;
  l_interest_batch_id            NUMBER;
  l_org_id                       NUMBER;
  l_gl_date                      DATE;
  l_cal_int_date                 DATE;
  l_batch_source_id              NUMBER;
  l_currency_code                VARCHAR2(30);
  l_stop                         VARCHAR2(1) := 'N';
  x_num_adj_created              NUMBER;
  x_num_adj_error                NUMBER;
  x_return_status                VARCHAR2(10);
  x_msg_count                    NUMBER;
  x_msg_data                     VARCHAR2(2000);
  i                              NUMBER := 0;
  errbuf                         VARCHAR2(240);
  retcode                        VARCHAR2(30);

BEGIN
log('ordonancer_per_worker +');
log('   ordonancer_per_worker executing for worker_num:'||p_worker_num);
log('   ordonancer_per_worker executing for request_id:'||p_request_id);

IF  p_worker_num IS NULL OR p_request_id IS NULL THEN
   log('The arguments p_worker_num and p_request_id are both required');
ELSE
  OPEN c;
  LOOP
     FETCH c INTO
       l_request_id                 ,
       l_interest_batch_id          ,
       l_org_id                     ,
       l_gl_date                    ,
       l_cal_int_date               ,
       l_batch_source_id            ,
       l_currency_code;
     EXIT WHEN c%NOTFOUND;
     l_stop := 'N';
     IF l_interest_batch_id IS NULL THEN
        log('no interest batch no found with the id:'||l_interest_batch_id);
        l_stop := 'Y';
     END IF;
     IF l_batch_source_id IS NULL THEN
        OPEN ht(p_worker_num, p_worker_num);
        IF ht%FOUND THEN
          log('no late batch charge batch source defined for the org_id:'||l_org_id);
          l_stop := 'Y';
        END IF;
        CLOSE ht;
     END IF;
	 IF l_gl_date IS NULL OR l_cal_int_date IS NULL THEN
        log('no calculate interest to date or GL date for the interest batch id:'||l_interest_batch_id);
        l_stop := 'Y';
     END IF;
	 IF l_currency_code IS NULL THEN
        log(' Issue with base currency for the org_id:'||l_org_id);
        l_stop := 'Y';
     END IF;
     IF l_stop = 'N' THEN
        log('ordonancer_per_worker executing the loop for :');
        log('    for org_id:'||l_org_id);
        log('    for currecny code :'||l_currency_code);
        log('    for interest_batch_id :'||l_interest_batch_id);
        log('    for batch_source_id :'||l_batch_source_id);
        log('    for responsibility :'||fnd_global.resp_id);
        log('    for user :'||fnd_global.user_id);
        log('    for application :'||fnd_global.resp_appl_id);

        --set org context
        mo_global.init('AR');
        mo_global.set_policy_context('S',l_org_id);
        fnd_global.APPS_INITIALIZE(
                 user_id      => fnd_global.user_id,
                 resp_id      => fnd_global.resp_id,
                 resp_appl_id => fnd_global.resp_appl_id);

        g_func_curr          := l_currency_code;
        g_interest_batch_id  := l_interest_batch_id;
        g_org_id             := l_org_id;
        g_BATCH_SOURCE_ID    := l_batch_source_id;

        fnd_msg_pub.initialize;

        log('Calling create_late_charge_per_worker +');

        create_late_charge_per_worker
        ( errbuf                  => errbuf,
          retcode                 => retcode,
          p_batch_source_id       => l_batch_source_id,
          p_batch_id              => l_interest_batch_id,
          p_worker_num            => p_worker_num,
          p_gl_date               => l_gl_date,
          p_cal_int_date          => l_cal_int_date,
          p_api_bulk_size         => 9000);

        log('Calling create_late_charge_per_worker -');
        --{Message Stack
        IF   retcode   <> '0' THEN
          fnd_msg_pub.count_and_get(
            p_encoded                    => fnd_api.g_false,
            p_count                      => x_msg_count,
            p_data                       => x_msg_data);
          IF x_msg_count > 1 THEN
            i  := 0;
            LOOP
              IF i < x_msg_count THEN
                 i := i + 1 ;
                 x_msg_data :=FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
                 log(x_msg_data);
              ELSE
                 EXIT;
              END IF;
            END LOOP;
          ELSIF  x_msg_count = 1 THEN
             log(x_msg_data);
          END IF;
        END IF;
        --}
        COMMIT;
        log('End of ordonancer_per_worker executing the cuuernt loop.');
      END IF;  -- End of l_stop = N

   END LOOP;
   CLOSE c;
END IF;
log('ordonancer_per_worker -');
END ordonancer_per_worker;

--{HYU Implemetation per worker
PROCEDURE prepare_header_for_worker
(p_interest_batch_id    IN NUMBER,
 p_max_workers          IN NUMBER,
 x_worker_list          OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
 x_nb_doc_list          OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
 x_return_status        OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT worker_num,
         COUNT(interest_header_id)
    FROM ar_interest_headers
   WHERE interest_batch_id = p_interest_batch_id
     AND process_status    = 'N'
     AND display_flag      = 'Y' --HYU CDI only document generating the Late Charge s Doc
   GROUP BY worker_num;
  i           NUMBER;
  worker_cpt  NUMBER;
BEGIN
 log('prepare_header_for_worker +');
 log('    p_interest_batch_id   '||p_interest_batch_id);
 log('    p_max_workers         '||p_max_workers);
  x_return_status  := fnd_api.g_ret_sts_success;
  IF p_interest_batch_id IS NULL THEN
     log('p_interest_batch_id required        ');
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'interest_batch_id' );
     FND_MSG_PUB.ADD;
     x_return_status := fnd_Api.G_RET_STS_ERROR;
  END IF;

  IF NOT(p_max_workers > 0) THEN
     log('p_max_worker should be greater than 0');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_NB_WORKER_GREATER_ZERO' );
     FND_MSG_PUB.ADD;
     x_return_status := fnd_Api.G_RET_STS_ERROR;
  END IF;

  IF x_return_status  = fnd_api.g_ret_sts_success THEN

     log('updating worker_num');
--{HYU CDI this update statement includes Credit Item
     UPDATE ar_interest_headers
        SET worker_num = mod(rownum, p_max_workers) + 1
      WHERE interest_batch_id = p_interest_batch_id
        AND process_status    = 'N'
        AND display_flag      = 'Y'; --HYU CDI only document generating the Late Charge s Doc
--}
     log('open cursor c');
     OPEN c;
     FETCH c BULK COLLECT INTO
        x_worker_list,
        x_nb_doc_list;
     CLOSE c;

     worker_cpt  := x_worker_list.COUNT;

     log('worker_cpt :'||   worker_cpt);
     IF NOT (worker_cpt > 0) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'AR_NO_HEADER_TO_PROCESS' );
        FND_MSG_PUB.ADD;
        x_return_status := fnd_Api.G_RET_STS_ERROR;
     END IF;
  END IF;
 log('prepare_header_for_worker -');
EXCEPTION
  WHEN OTHERS THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('SQL Error in prepare_header_for_worker' || SQLERRM);
    x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
END;



PROCEDURE create_late_charge_by_worker
 (errbuf                  OUT NOCOPY   VARCHAR2,
  retcode                 OUT NOCOPY   VARCHAR2,
  p_max_workers           IN NUMBER   DEFAULT 4,
  p_interval              IN NUMBER   DEFAULT 60,
  p_max_wait              IN NUMBER   DEFAULT 180,
  p_api_bulk_size         IN NUMBER   DEFAULT 9000,
  p_batch_source_id       IN NUMBER,
  p_batch_id              IN NUMBER )
IS
  CURSOR c IS
  SELECT transferred_status,
         object_version_number,
         CALCULATE_INTEREST_TO_DATE,
         BATCH_STATUS,
         GL_DATE
    FROM ar_interest_batches
   WHERE interest_batch_id = g_interest_batch_id;

  l_transferred_status          VARCHAR2(1);
  x_object_version_number       NUMBER;
  l_CALCULATE_INTEREST_TO_DATE  DATE;
  l_BATCH_STATUS                VARCHAR2(30);
  l_GL_DATE                     DATE;

  CURSOR c_hdr IS
  SELECT interest_header_id
    FROM ar_interest_headers
   WHERE interest_batch_id = g_interest_batch_id
     AND process_status    = 'N';

  l_ihid                        NUMBER;
  l_empty_batch                 BOOLEAN := FALSE;

  CURSOR c_batch_source IS
  SELECT NULL
    FROM ra_batch_sources
   WHERE BATCH_SOURCE_ID = p_batch_source_id;

  CURSOR c_err IS
  SELECT NULL
    FROM ar_interest_headers
   WHERE interest_batch_id = g_interest_batch_id
     AND process_status   <> 'S';

  l_err                     VARCHAR2(1);
  l_test                    VARCHAR2(1);
  l_customer_site_use_id    DBMS_SQL.NUMBER_TABLE;
  x_num_adj_created         NUMBER;
  x_num_adj_error           NUMBER;
  x_return_status           VARCHAR2(10);
  x_msg_count               NUMBER;
  x_msg_data                VARCHAR2(2000);
  l_request_id              NUMBER;
  l_exec_srs                VARCHAR2(1) := 'N';
  l_need_wait               VARCHAR2(1) := 'N';
  x_worker_list             DBMS_SQL.NUMBER_TABLE;
  x_nb_doc_list             DBMS_SQL.NUMBER_TABLE;

  nothing_to_process        EXCEPTION;
BEGIN
  log('create_late_charge_by_worker  +');

   retcode := 0;
   g_interest_batch_id := p_batch_id;


   outandlog( message  =>'create_late_charge for the batch:'||p_batch_id );
   outandlog( message  =>'  Starting at      '|| to_char(SYSDATE, 'HH24:MI:SS') );
   outandlog( message  =>'  p_max_workers    '|| p_max_workers);
   outandlog( message  =>'  p_interval       '|| p_interval);
   outandlog( message  =>'  p_max_wait       '|| p_max_wait);
   outandlog( message  =>'  p_api_bulk_size  '|| p_api_bulk_size);
   outandlog( message  =>'  p_batch_source_id'|| p_batch_source_id);
   outandlog( message  =>'  p_batch_id       '|| p_batch_id);



   x_return_status := fnd_api.g_ret_sts_success;

   IF   p_batch_source_id  IS NULL THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_source_id' );
     FND_MSG_PUB.ADD;
     retcode := 2;
     x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
   ELSE
     OPEN c_batch_source;
     FETCH c_batch_source INTO l_test;
     IF c_batch_source%NOTFOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
        FND_MESSAGE.SET_TOKEN( 'FK', 'batch_source_id' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_source_id' );
        FND_MESSAGE.SET_TOKEN( 'TABLE', 'ra_batch_sources');
        FND_MSG_PUB.ADD;
        x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
     CLOSE c_batch_source;
   END IF;

  OPEN c;
  FETCH c INTO l_transferred_status,
               x_object_version_number,
               l_CALCULATE_INTEREST_TO_DATE,
               l_BATCH_STATUS,
               l_GL_DATE;
  IF    c%NOTFOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
        FND_MESSAGE.SET_TOKEN( 'FK', 'batch_id' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN',p_batch_id );
        FND_MESSAGE.SET_TOKEN( 'TABLE', 'ar_interest_batches' );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      retcode := 2;
      x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch not found with the interest_batch_id :'||p_batch_id);
  ELSE
    IF l_BATCH_STATUS  <> 'F' OR l_BATCH_STATUS IS NULL THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      fnd_message.set_token('STATE', l_BATCH_STATUS);
      fnd_msg_pub.add;
      retcode := 2;
      x_return_status := fnd_api.g_ret_sts_error;
      outandlog('Interest Batch batch_status should be Final to import interest_batch_id :'||p_batch_id);
    END IF;
    IF l_CALCULATE_INTEREST_TO_DATE IS NULL THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'CALCULATE_INTEREST_TO_DATE' );
      FND_MSG_PUB.ADD;
      x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch calculation interest to date is mandatory interest_batch_id :'||p_batch_id);
    END IF;
    IF l_GL_DATE IS NULL THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'GL_DATE' );
      FND_MSG_PUB.ADD;
      x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch GL date is mandatory interest_batch_id :'||p_batch_id);
    END IF;
    IF l_transferred_status = 'S' THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      fnd_message.set_token('STATE', l_BATCH_STATUS);
      fnd_msg_pub.add;
      retcode := 1;
      x_return_status := fnd_Api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch already successfully transferred interest_batch_id :'||p_batch_id);
    ELSIF l_transferred_status = 'E' THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      fnd_message.set_token('STATE', l_BATCH_STATUS);
      fnd_msg_pub.add;
      retcode := 1;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch is in Error, please fix it before submitting interest_batch_id :'||p_batch_id);
    ELSIF l_transferred_status = 'P' THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      fnd_message.set_token('STATE', l_BATCH_STATUS);
      fnd_msg_pub.add;
      retcode := 1;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch is in process, can not resubmit interest_batch_id :'||p_batch_id);
    ELSIF l_transferred_status = 'N' THEN
      outandlog('Processing the batch  interest_batch_id :'||p_batch_id);
    ELSIF l_transferred_status IS NOT NULL THEN
      fnd_message.set_name('AR', 'AR_INT_BATCH_STATUS');
      fnd_message.set_token('STATE', l_BATCH_STATUS);
      fnd_msg_pub.add;
      retcode := 2;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      outandlog('Interest Batch transferred flag should be in (NULL,S,E) no other value permitted  interest_batch_id :'||p_batch_id);
    END IF;
  END IF;
  CLOSE c;

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_Api.g_exc_unexpected_error;
  END IF;

  OPEN  c_hdr;
  FETCH c_hdr INTO l_ihid;
  IF c_hdr%NOTFOUND THEN
     l_empty_batch := TRUE;
  END IF;
  CLOSE c_hdr;
  IF l_empty_batch THEN
     RAISE nothing_to_process;
  END IF;


  -- Set the new worker_num on interest headers
  prepare_header_for_worker
   (p_interest_batch_id    => g_interest_batch_id,
    p_max_workers          => p_max_workers,
    x_worker_list          => x_worker_list,
    x_nb_doc_list          => x_nb_doc_list,
    x_return_status        => x_return_status);


  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    retcode := 2;
    RAISE fnd_Api.g_exc_unexpected_error;
  END IF;

  log('Updating the batch status to Pending to start the process...');
  AR_INTEREST_BATCHES_PKG.update_batch
   (p_init_msg_list              => 'T',
    P_INTEREST_BATCH_ID          => g_interest_batch_id,
    P_BATCH_STATUS               => 'F',
    P_TRANSFERRED_STATUS         => 'P',
    p_updated_by_program         => 'ARLCSM',
    x_OBJECT_VERSION_NUMBER      => x_object_version_number,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_Api.g_exc_error;
  END IF;

  FOR i IN x_worker_list.FIRST..x_worker_list.LAST LOOP
      submit_late_charge_worker
      (p_batch_id              => p_batch_id,
       p_batch_source_id       => p_batch_source_id,
       p_gl_date               => l_GL_DATE,
       p_cal_int_date          => l_CALCULATE_INTEREST_TO_DATE,
       p_api_bulk_size         => p_api_bulk_size,
       p_worker_num            => x_worker_list(i),
       x_out_request_id        => l_request_id);
      IF  l_need_wait = 'N' AND  l_request_id > 0 THEN
          l_need_wait := 'Y';
      END IF;
  END LOOP;

  IF l_need_wait = 'Y' THEN
    wait_for_end_subreq(
      p_interval       => p_interval
     ,p_max_wait       => p_max_wait
     ,p_sub_name       => 'ARLCPW' );
  END IF;

  log( message  => 'Updating interest batch status to :'||l_batch_status||' for batch_id :'||g_interest_batch_id);

  get_status_for_sub_process
  (p_sub_name     => 'ARLCPW',
   x_status       => l_transferred_status);

--  UPDATE ar_interest_batches
--     SET TRANSFERRED_status  = l_transferred_status,
--         object_version_number = x_object_version_number + 1
--   WHERE interest_batch_id = g_interest_batch_id;

  OPEN c_err;
  FETCH c_err INTO l_err;
  IF c_err%NOTFOUND THEN
    AR_INTEREST_BATCHES_PKG.update_batch
    (p_init_msg_list              => 'T',
     P_INTEREST_BATCH_ID          => g_interest_batch_id,
     P_BATCH_STATUS               => 'F',
     P_TRANSFERRED_status         => l_transferred_status,
     p_updated_by_program         => 'ARLCSM',
     x_OBJECT_VERSION_NUMBER      => x_object_version_number,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);
  ELSE
    AR_INTEREST_BATCHES_PKG.update_batch
    (p_init_msg_list              => 'T',
     P_INTEREST_BATCH_ID          => g_interest_batch_id,
     P_BATCH_STATUS               => 'F',
     P_TRANSFERRED_status         => 'E',
     p_updated_by_program         => 'ARLCSM',
     x_OBJECT_VERSION_NUMBER      => x_object_version_number,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);
     log('Some documents are in error in in the batch :'||g_interest_batch_id);
     errbuf   := 'Some documents are in error in in the batch :'||g_interest_batch_id;
     retcode  := 1;
  END IF;

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_Api.g_exc_error;
  END IF;

  outandlog( message  =>'  End at ' || to_char(SYSDATE, 'HH24:MI:SS') );
  outandlog( message  =>'End create_late_charge_by_worker for the batch:'||p_batch_id||' Please check log files' );
EXCEPTION
  WHEN nothing_to_process THEN
    outandlog( message  =>'  Empty batch' );
    AR_INTEREST_BATCHES_PKG.update_batch
    (p_init_msg_list              => 'T',
     P_INTEREST_BATCH_ID          => g_interest_batch_id,
     P_BATCH_STATUS               => 'F',
     P_TRANSFERRED_status         => 'S',
     p_updated_by_program         => 'ARLCSM',
     x_OBJECT_VERSION_NUMBER      => x_object_version_number,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      retcode := 2;
      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);

      outandlog('Error:  ' || FND_MESSAGE.GET);
      log('Batch en error ' || x_msg_data);
      errbuf := errbuf || logerror || x_msg_data;
      outandlog('Aborting concurrent program execution');
    END IF;

    FND_FILE.close;

  WHEN fnd_Api.g_exc_unexpected_error THEN
      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);

    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('Batch en error ' || x_msg_data);
    errbuf := errbuf || logerror || x_msg_data;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
  WHEN fnd_Api.g_exc_error THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('Batch en error ' || x_msg_data);
    errbuf := errbuf || logerror || x_msg_data;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;

  WHEN OTHERS THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('SQL Error ' || SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror || SQLERRM;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
END;

PROCEDURE submit_late_charge_worker
(p_batch_id              IN  NUMBER,
 p_batch_source_id       IN  NUMBER,
 p_gl_date               IN  DATE,
 p_cal_int_date          IN  DATE,
 p_api_bulk_size         IN  NUMBER,
 p_worker_num            IN  NUMBER,
 x_out_request_id        OUT NOCOPY NUMBER)
IS
 lc_sub_pb    EXCEPTION;
BEGIN

  FND_REQUEST.SET_ORG_ID(g_org_id);
  x_out_request_id := FND_REQUEST.SUBMIT_REQUEST(
                         application=>'AR',
                         program    =>'ARLCPW',
                         sub_request=>FALSE,
                         argument1  => p_batch_source_id,
                         argument2  => p_batch_id,
                         argument3  => p_worker_num,
                         argument4  => p_gl_date,
                         argument5  => p_cal_int_date,
						 argument6  => p_api_bulk_size );
  IF x_out_request_id <> 0 THEN
     INSERT INTO ar_submission_ctrl_gt
     (worker_id         , --p_batch_source_id
      batch_id          , --
      script_name       , --script_name
      status            , --
      order_num         , --order helper number
      request_id        , --request_id
      table_name        ) --table_name
      VALUES
     (p_batch_source_id,
      NULL,
      'ARLCPW',
      'SUBMITTED',
      1,
      x_out_request_id,
      'ARLC');
     COMMIT;
  ELSE
     RAISE lc_sub_pb;
  END IF;
EXCEPTION
  WHEN lc_sub_pb THEN
     log(logerror(SQLERRM));
  WHEN OTHERS THEN
     log(logerror(SQLERRM));
END;

--}

PROCEDURE init IS
CURSOR c_initial IS
  SELECT lg.currency_code,
         sysp.org_id,
         sysp.LATE_CHARGE_BATCH_SOURCE_ID
    FROM ar_system_parameters sysp,
         gl_ledgers           lg
   WHERE lg.ledger_id = sysp.set_of_books_id;
BEGIN

  OPEN c_initial;
  FETCH c_initial INTO
      g_func_curr, g_org_id, g_BATCH_SOURCE_ID;
   IF c_initial%NOTFOUND THEN
     RAISE NO_DATA_FOUND;
   END IF;
  CLOSE c_initial;
END;


BEGIN

   init;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   log('No system parameter!!!');
   RAISE;

END;

/
