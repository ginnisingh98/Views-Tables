--------------------------------------------------------
--  DDL for Package Body OKL_LCKBX_CSH_APP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LCKBX_CSH_APP_PVT" AS
/* $Header: OKLRLBXB.pls 120.29.12010000.5 2009/06/02 10:43:41 racheruv ship $ */
-- Start of wraper code generated automatically by Debug code generator
   l_module                     VARCHAR2 (40)  := 'LEASE.RECEIVABLES.LOCKBOX';
   l_debug_enabled     CONSTANT VARCHAR2 (10)
                                           := okl_debug_pub.check_log_enabled;
   l_level_statement            NUMBER;
   --akrangan added for debug logging begin
   g_module                VARCHAR2 (255)
                                      := 'okl.am.plsql.okl_lckbx_csh_app_pvt';
   g_level_procedure   CONSTANT NUMBER         := fnd_log.level_procedure;
   g_level_exception   CONSTANT NUMBER         := fnd_log.level_exception;
   g_level_statement   CONSTANT NUMBER         := fnd_log.level_statement;
   -- akrangan added for debug feature start
   is_debug_exception_on        BOOLEAN
             := okl_debug_pub.check_log_on (g_module, g_level_exception);
   is_debug_procedure_on        BOOLEAN
             := okl_debug_pub.check_log_on (g_module, g_level_procedure);
   is_debug_statement_on        BOOLEAN
             := okl_debug_pub.check_log_on (g_module, g_level_statement);

   -- akrangan added for debug feature end
   --akrangan added for debug logging end

   -- End of wraper code generated automatically by Debug code generator
---------------------------------------------------------------------------
-- FURTURE ENHANCEMENTS
-- 1/ Include auto associate code checking when customer_number not specified
-- 2/ Org_id
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Function get_req_recs
---------------------------------------------------------------------------
   FUNCTION get_rec_count (req_id NUMBER)
      RETURN NUMBER IS
      trans_count   NUMBER DEFAULT NULL;
   BEGIN
      SELECT COUNT (*)
        INTO trans_count
        FROM ar_payments_interface_all
       WHERE transmission_request_id = req_id;

      RETURN trans_count;
   END get_rec_count;

   --asawanka added for llca start
   PROCEDURE log_debug (p_message IN VARCHAR2) IS
   BEGIN
      IF (is_debug_statement_on) THEN
         -- dbms_output.put_line('p_message =  '||p_message);
         okl_debug_pub.logmessage (p_message, l_level_statement, 'Y');
      END IF;
   END log_debug;

   --asawanka added for llca end
   FUNCTION valid_ar_reference (ar_inv_ref VARCHAR, p_org_id IN NUMBER)
      RETURN BOOLEAN IS
      inv_count   NUMBER DEFAULT NULL;
   BEGIN
      --asawanka modified for lla start
      --this function should return true if ar_inv_ref is a valid non okl ar invoice
      SELECT COUNT (*)
        INTO inv_count
        FROM ra_customer_trx_all
       WHERE trx_number = ar_inv_ref
         AND org_id = p_org_id
         AND interface_header_context <> 'OKL_CONTRACTS';

      --asawanka modified for lla end
      IF inv_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END valid_ar_reference;

   --asawanka modified for llca start
   --added function
   FUNCTION get_precision (
      p_currency_code   IN   VARCHAR2,
      p_trans_req_id    IN   NUMBER,
      p_record_type     IN   VARCHAR2,
      p_column_type     IN   VARCHAR2
   )
      RETURN NUMBER IS
      CURSOR c_get_format_flag (
         cp_trans_req_id   IN   NUMBER,
         cp_record_type    IN   VARCHAR2,
         cp_column_type    IN   VARCHAR2
      ) IS
         SELECT NVL (fld.amount_format_lookup_code, 'N')
           FROM ar_transmissions_all trans,
                ar_trans_record_formats rec,
                ar_trans_field_formats fld
          WHERE trans.transmission_request_id = cp_trans_req_id
            AND trans.requested_trans_format_id = rec.transmission_format_id
            AND rec.record_type_lookup_code = cp_record_type
            AND rec.record_format_id = fld.record_format_id
            AND fld.field_type_lookup_code = cp_column_type;

      CURSOR c_get_precision (cp_currency_code IN VARCHAR2) IS
         SELECT NVL (PRECISION, 0)
           FROM fnd_currencies_vl cur
          WHERE cur.currency_code = cp_currency_code;

      l_format_yn   VARCHAR2 (10) := 'N';
      l_precision   NUMBER;
   BEGIN
      OPEN c_get_format_flag (p_trans_req_id, p_record_type, p_column_type);

      FETCH c_get_format_flag
       INTO l_format_yn;

      CLOSE c_get_format_flag;

      IF l_format_yn = 'Y' THEN
         OPEN c_get_precision (p_currency_code);

         FETCH c_get_precision
          INTO l_precision;

         CLOSE c_get_precision;

         RETURN l_precision;
      ELSE
         RETURN 0;
      END IF;
   END get_precision;

   FUNCTION is_valid_reference ( p_reference_type    IN VARCHAR2,
                                 p_reference         IN VARCHAR2,
                                 p_currency_code     IN VARCHAR2,
                                 p_trans_req_id      IN NUMBER,
                                 p_org_id            IN NUMBER,
                                 p_index             IN NUMBER,
                                 p_record_type       IN VARCHAR2,
                                 p_column_type_to    IN VARCHAR2,
                                 p_column_type_from  IN VARCHAR2,
                                 p_customer_num      IN VARCHAR2,
                                 p_amount_to         IN NUMBER,
                                 p_amount_from       IN NUMBER,
                                 x_currency_code     OUT NOCOPY VARCHAR2,
                                 x_amount_to         OUT NOCOPY NUMBER,
                                 x_amount_from       OUT NOCOPY NUMBER,
                                 x_precision_to      OUT NOCOPY NUMBER,
                                 x_precision_from    OUT NOCOPY NUMBER)
   RETURN BOOLEAN
   IS

     CURSOR c_valid_arinv (cp_invoice_number VARCHAR2,
                           cp_org_id         NUMBER,
                           cp_customer_num   VARCHAR2,
                           cp_currency_code  VARCHAR2) IS
     SELECT INVOICE_CURRENCY_CODE
     FROM okl_rcpt_arinv_balances_uv
     WHERE invoice_number = cp_invoice_number
     --commented for bug 5391874
     --  AND customer_account_number = cp_customer_num
       AND org_id = cp_org_id
       and INVOICE_CURRENCY_CODE = nvl(cp_currency_code,INVOICE_CURRENCY_CODE)
       AND status = 'OP';

     CURSOR c_valid_consinv (cp_cons_invoice_number VARCHAR2,
                             cp_org_id              NUMBER,
                             cp_customer_num        VARCHAR2,
                             cp_currency_code       VARCHAR2) IS
     SELECT CURRENCY_CODE
     FROM okl_rcpt_consinv_balances_uv
     WHERE consolidated_invoice_number = cp_cons_invoice_number
     --commented for bug 5391874
   --    AND customer_account_number = cp_customer_num
       AND org_id = cp_org_id
       and CURRENCY_CODE = nvl(cp_currency_code,CURRENCY_CODE)
       AND status = 'OP';

     CURSOR c_valid_contract(cp_contract_number     VARCHAR2,
                             cp_org_id              NUMBER,
                             cp_customer_num        VARCHAR2,
                             cp_currency_code       VARCHAR2) IS
     SELECT CURRENCY_CODE
     -- FROM okl_rcpt_consinv_balances_uv -- incorrect view .. bug 7018894
     FROM okl_rcpt_cust_cont_balances_uv
     WHERE contract_number = cp_contract_number
     --commented for bug 5391874
  --     AND customer_account_number = cp_customer_num
       AND org_id = cp_org_id
       and CURRENCY_CODE = nvl(cp_currency_code,CURRENCY_CODE)
       AND status = 'OP';

     l_invoice_currency_code RA_CUSTOMER_TRX_ALL.INVOICE_CURRENCY_CODE%TYPE;
     l_precision      NUMBER;
     l_amount_to      NUMBER;
     l_amount_from    NUMBER;
   BEGIN
     --Log the input parameters
     log_debug('p_reference_type: ' || p_reference_type);
     log_debug('p_reference: ' || p_reference);
     log_debug('p_currency_code: ' || p_currency_code);
     log_debug('p_trans_req_id: ' || p_trans_req_id);
     log_debug('p_org_id: ' || p_org_id);
     log_debug('p_record_type: ' || p_record_type);
     log_debug('p_index: ' || p_index);
     log_debug('p_column_type_to: ' || p_column_type_to);
     log_debug('p_column_type_from: ' || p_column_type_from);
     log_debug('p_customer_num: ' || p_customer_num);
     log_debug('p_amount_to: ' || p_amount_to);
     log_debug('p_amount_from: ' || p_amount_from);

     --Check whether it is valid AR Invoice Number
     --If not valid return false
     IF p_reference_type = 'INVOICE' THEN
       OPEN c_valid_arinv(p_reference, p_org_id, p_customer_num, p_currency_code);
       FETCH c_valid_arinv INTO l_invoice_currency_code;
       IF c_valid_arinv%NOTFOUND THEN
        RETURN FALSE;
       END IF;
       CLOSE c_valid_arinv;
     --Check whether it is valid consolidated Invoice Number
     --If not valid return false
     ELSIF p_reference_type = 'CONS-INVOICE' THEN
       OPEN c_valid_consinv(p_reference, p_org_id, p_customer_num, p_currency_code);
       FETCH c_valid_consinv INTO l_invoice_currency_code;
       IF c_valid_consinv%NOTFOUND THEN
        RETURN FALSE;
       END IF;
       CLOSE c_valid_consinv;
     --Check whether it is valid contract Number
     --If not valid return false
     ELSIF p_reference_type = 'CONTRACT' THEN
       OPEN c_valid_contract(p_reference, p_org_id, p_customer_num, p_currency_code);
       FETCH c_valid_contract INTO l_invoice_currency_code;
       IF c_valid_contract%NOTFOUND THEN
        RETURN FALSE;
       END IF;
       CLOSE c_valid_contract;
     END IF;

     --Get new precision, new amount applied and new amount applied from
     --based on invoice/cons invoice/contract currency we got from above cursor

     x_currency_code := l_invoice_currency_code;

     l_precision :=    get_precision (l_invoice_currency_code,
                                      p_trans_req_id,
                                      p_record_type,
                                      p_column_type_to || ' ' || p_index);
     l_amount_to := ROUND (p_amount_to / POWER (10, l_precision), l_precision);
     x_precision_to := l_precision;
     x_amount_to := l_amount_to;

     l_precision :=    get_precision (l_invoice_currency_code,
                                      p_trans_req_id,
                                      p_record_type,
                                      p_column_type_from || ' ' || p_index);
     l_amount_from := ROUND (p_amount_from / POWER (10, l_precision), l_precision);
     x_precision_from := l_precision;
     x_amount_from := l_amount_from;

     RETURN TRUE;

   END is_valid_reference;

---------------------------------------------------------------------------
--FUNCTION  - To return whether we need to make Line level application/not
---------------------------------------------------------------------------
   FUNCTION get_line_level_app (p_arinv_id IN NUMBER, p_org_id IN NUMBER)
      RETURN VARCHAR2 AS
      CURSOR c_is_llevel_balance (p_inv_id NUMBER, p_org_id NUMBER) IS
         SELECT SUM (amount_due_remaining) due
           FROM ra_customer_trx_lines
          WHERE customer_trx_id = p_inv_id
            AND org_id = p_org_id
            AND line_type = 'LINE';

      CURSOR c_get_activity (p_inv_id NUMBER, p_org_id NUMBER) IS
         SELECT arpt_sql_func_util.get_activity_flag
                                                  (ct.customer_trx_id,
                                                   ctt.accounting_affect_flag,
                                                   ct.complete_flag,
                                                   ctt.TYPE,
                                                   ct.initial_customer_trx_id,
                                                   ct.previous_customer_trx_id
                                                  ) activity
           FROM ra_cust_trx_types ctt, ra_customer_trx ct
          WHERE ct.customer_trx_id = p_inv_id
            AND ct.org_id = p_org_id
            AND ct.cust_trx_type_id = ctt.cust_trx_type_id;

      l_return_flag     VARCHAR2 (1) DEFAULT 'Y';
      l_balance_exist   VARCHAR (1)  DEFAULT 'Y';
      l_due             NUMBER;
      l_activity        VARCHAR2 (1);
   BEGIN
      OPEN c_is_llevel_balance (p_arinv_id, p_org_id);

      FETCH c_is_llevel_balance
       INTO l_due;

      CLOSE c_is_llevel_balance;

      IF l_due IS NULL THEN
         l_balance_exist := 'N';
      END IF;

      IF l_balance_exist = 'N' THEN
         OPEN c_get_activity (p_arinv_id, p_org_id);

         FETCH c_get_activity
          INTO l_activity;

         CLOSE c_get_activity;

         IF l_activity = 'Y' THEN
            l_return_flag := 'N';
         END IF;
      END IF;

      RETURN l_return_flag;
   END;

---------------------------------------------------------------------------
-- PROCEDURE handle_auto_pay
---------------------------------------------------------------------------
   PROCEDURE handle_auto_pay (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_trans_req_id    IN              ar_payments_interface.transmission_request_id%TYPE
   ) IS
---------------------------
-- DECLARE Local Variables
---------------------------
      l_lockbox_run_already           VARCHAR (1)                DEFAULT NULL;
      --asawanka modified for lla start
      -- removed default assignement to mo_global.current_org_id as current org id might not be set from AR side
      -- we need to take org_id from  interface records instead
      l_org_id                        ar_payments_interface_all.org_id%TYPE;
      --asawanka modified for lla end
      l_status               CONSTANT ar_payments_interface_all.status%TYPE
                                                       := 'AR_PLB_NEW_RECORD';
      l_trans_req_id                  ar_payments_interface_all.transmission_request_id%TYPE
                                                                 DEFAULT NULL;
      l_transmission_id               ar_payments_interface_all.transmission_id%TYPE
                                                                 DEFAULT NULL;
      l_transmission_record_id        ar_payments_interface_all.transmission_record_id%TYPE
                                                                 DEFAULT NULL;
      l_last_transmission_record_id   ar_payments_interface_all.transmission_record_id%TYPE
                                                                 DEFAULT NULL;
      l_overflow_sequence             ar_payments_interface_all.overflow_sequence%TYPE
                                                                 DEFAULT NULL;
      l_lockbox_number                ar_payments_interface_all.lockbox_number%TYPE
                                                                 DEFAULT NULL;
      l_batch_name                    ar_payments_interface_all.batch_name%TYPE
                                                                 DEFAULT NULL;
      l_transmission_format_id        ar_transmission_formats.transmission_format_id%TYPE
                                                                 DEFAULT NULL;
      l_record_identifier             ar_trans_record_formats.record_identifier%TYPE
                                                                 DEFAULT NULL;
      l_record_type_lookup_code       ar_trans_record_formats.record_type_lookup_code%TYPE
                                                                 DEFAULT NULL;
      l_overflow_rec_indicator        ar_trans_field_formats.overflow_rec_indicator%TYPE
                                                                 DEFAULT NULL;
      l_transmission_hdr              ar_trans_record_formats.record_identifier%TYPE
                                                                 DEFAULT NULL;
      l_transmission_trl              ar_trans_record_formats.record_identifier%TYPE
                                                                 DEFAULT NULL;
      l_payment                       ar_trans_record_formats.record_identifier%TYPE
                                                                 DEFAULT NULL;
      l_overflow                      ar_trans_record_formats.record_identifier%TYPE
                                                                 DEFAULT NULL;
      l_service                       ar_trans_record_formats.record_identifier%TYPE
                                                                 DEFAULT NULL;
      l_customer_number               ar_payments_interface_all.customer_number%TYPE
                                                                 DEFAULT NULL;
      l_remittance_amount             ar_payments_interface_all.remittance_amount%TYPE
                                                                 DEFAULT NULL;
      l_currency_code                 ar_payments_interface_all.currency_code%TYPE
                                                                 DEFAULT NULL;
      l_item_number                   ar_payments_interface_all.item_number%TYPE
                                                                 DEFAULT NULL;
      l_inv_ref                       ar_payments_interface_all.invoice1%TYPE
                                                                 DEFAULT NULL;
      l_invoice                       ar_payments_interface_all.invoice1%TYPE
                                                                 DEFAULT NULL;
      l_amt_appl                      ar_payments_interface_all.amount_applied1%TYPE
                                                                 DEFAULT NULL;
      l_amount_applied                ar_payments_interface_all.amount_applied1%TYPE
                                                                 DEFAULT NULL;
      l_check_number                  ar_payments_interface_all.check_number%TYPE
                                                                 DEFAULT NULL;
      l_receipt_date                  ar_payments_interface_all.receipt_date%TYPE
                                                                 DEFAULT NULL;
      l_transit_routing_number        ar_payments_interface_all.transit_routing_number%TYPE
                                                                 DEFAULT NULL;
      l_account                       ar_payments_interface_all.ACCOUNT%TYPE
                                                                 DEFAULT NULL;
      l_invoice1                      ar_payments_interface_all.invoice1%TYPE
                                                                 DEFAULT NULL;
      l_invoice2                      ar_payments_interface_all.invoice2%TYPE
                                                                 DEFAULT NULL;
      l_invoice3                      ar_payments_interface_all.invoice3%TYPE
                                                                 DEFAULT NULL;
      l_invoice4                      ar_payments_interface_all.invoice4%TYPE
                                                                 DEFAULT NULL;
      l_invoice5                      ar_payments_interface_all.invoice5%TYPE
                                                                 DEFAULT NULL;
      l_invoice6                      ar_payments_interface_all.invoice6%TYPE
                                                                 DEFAULT NULL;
      l_invoice7                      ar_payments_interface_all.invoice7%TYPE
                                                                 DEFAULT NULL;
      l_invoice8                      ar_payments_interface_all.invoice8%TYPE
                                                                 DEFAULT NULL;
      l_new_invoice1                  ar_payments_interface_all.invoice1%TYPE
                                                                 DEFAULT NULL;
      l_new_invoice2                  ar_payments_interface_all.invoice2%TYPE
                                                                 DEFAULT NULL;
      l_new_invoice3                  ar_payments_interface_all.invoice3%TYPE
                                                                 DEFAULT NULL;
      l_new_invoice4                  ar_payments_interface_all.invoice4%TYPE
                                                                 DEFAULT NULL;
      l_new_invoice5                  ar_payments_interface_all.invoice5%TYPE
                                                                 DEFAULT NULL;
      l_new_invoice6                  ar_payments_interface_all.invoice6%TYPE
                                                                 DEFAULT NULL;
      l_new_invoice7                  ar_payments_interface_all.invoice7%TYPE
                                                                 DEFAULT NULL;
      l_new_invoice8                  ar_payments_interface_all.invoice8%TYPE
                                                                 DEFAULT NULL;

      -- varao - Bug#5075248 - Modified - Start
      -- Datatype matched with the new column from which amount is queried from
      l_amount_applied1               ar_payments_interface_all.tmp_amt_applied1%TYPE
                                                                 DEFAULT NULL;
      l_amount_applied2               ar_payments_interface_all.tmp_amt_applied2%TYPE
                                                                 DEFAULT NULL;
      l_amount_applied3               ar_payments_interface_all.tmp_amt_applied3%TYPE
                                                                 DEFAULT NULL;
      l_amount_applied4               ar_payments_interface_all.tmp_amt_applied4%TYPE
                                                                 DEFAULT NULL;
      l_amount_applied5               ar_payments_interface_all.tmp_amt_applied5%TYPE
                                                                 DEFAULT NULL;
      l_amount_applied6               ar_payments_interface_all.tmp_amt_applied6%TYPE
                                                                 DEFAULT NULL;
      l_amount_applied7               ar_payments_interface_all.tmp_amt_applied7%TYPE
                                                                 DEFAULT NULL;
      l_amount_applied8               ar_payments_interface_all.tmp_amt_applied8%TYPE
                                                                 DEFAULT NULL;
      l_amount_app_from1             ar_payments_interface_all.tmp_amt_applied_from1%TYPE DEFAULT NULL;
      l_amount_app_from2             ar_payments_interface_all.tmp_amt_applied_from2%TYPE DEFAULT NULL;
      l_amount_app_from3             ar_payments_interface_all.tmp_amt_applied_from3%TYPE DEFAULT NULL;
      l_amount_app_from4             ar_payments_interface_all.tmp_amt_applied_from4%TYPE DEFAULT NULL;
      l_amount_app_from5             ar_payments_interface_all.tmp_amt_applied_from5%TYPE DEFAULT NULL;
      l_amount_app_from6             ar_payments_interface_all.tmp_amt_applied_from6%TYPE DEFAULT NULL;
      l_amount_app_from7             ar_payments_interface_all.tmp_amt_applied_from7%TYPE DEFAULT NULL;
      l_amount_app_from8             ar_payments_interface_all.tmp_amt_applied_from8%TYPE DEFAULT NULL;
      l_trans_to_receipt_rate1       ar_payments_interface_all.trans_to_receipt_rate1%TYPE DEFAULT NULL;
      l_trans_to_receipt_rate2       ar_payments_interface_all.trans_to_receipt_rate2%TYPE DEFAULT NULL;
      l_trans_to_receipt_rate3       ar_payments_interface_all.trans_to_receipt_rate3%TYPE DEFAULT NULL;
      l_trans_to_receipt_rate4       ar_payments_interface_all.trans_to_receipt_rate4%TYPE DEFAULT NULL;
      l_trans_to_receipt_rate5       ar_payments_interface_all.trans_to_receipt_rate5%TYPE DEFAULT NULL;
      l_trans_to_receipt_rate6       ar_payments_interface_all.trans_to_receipt_rate6%TYPE DEFAULT NULL;
      l_trans_to_receipt_rate7       ar_payments_interface_all.trans_to_receipt_rate7%TYPE DEFAULT NULL;
      l_trans_to_receipt_rate8       ar_payments_interface_all.trans_to_receipt_rate8%TYPE DEFAULT NULL;

      l_returned_curr_code           ar_payments_interface_all.currency_code%TYPE DEFAULT NULL;
      l_returned_amount_to           ar_payments_interface_all.tmp_amt_applied1%TYPE DEFAULT NULL;
      l_returned_amount_from         ar_payments_interface_all.tmp_amt_applied_from1%TYPE DEFAULT NULL;
      l_returned_precision_to        NUMBER;
	  l_returned_precision_from      NUMBER;
      l_tmp_amount_applied           ar_payments_interface_all.tmp_amt_applied1%TYPE DEFAULT NULL;
	  l_tmp_amount_app_from          ar_payments_interface_all.tmp_amt_applied_from1%TYPE DEFAULT NULL;
	  l_tmp_currency_code            ar_payments_interface_all.currency_code%TYPE DEFAULT NULL;

      -- varao - Bug#5075248 - Modified - End
      l_new_amount_applied1           ar_payments_interface_all.amount_applied1%TYPE
                                                                 DEFAULT NULL;
      l_new_amount_applied2           ar_payments_interface_all.amount_applied2%TYPE
                                                                 DEFAULT NULL;
      l_new_amount_applied3           ar_payments_interface_all.amount_applied3%TYPE
                                                                 DEFAULT NULL;
      l_new_amount_applied4           ar_payments_interface_all.amount_applied4%TYPE
                                                                 DEFAULT NULL;
      l_new_amount_applied5           ar_payments_interface_all.amount_applied5%TYPE
                                                                 DEFAULT NULL;
      l_new_amount_applied6           ar_payments_interface_all.amount_applied6%TYPE
                                                                 DEFAULT NULL;
      l_new_amount_applied7           ar_payments_interface_all.amount_applied7%TYPE
                                                                 DEFAULT NULL;
      l_new_amount_applied8           ar_payments_interface_all.amount_applied8%TYPE
                                                                 DEFAULT NULL;

      l_new_amount_applied_from1      ar_payments_interface_all.amount_applied_from1%TYPE DEFAULT NULL;
      l_new_amount_applied_from2      ar_payments_interface_all.amount_applied_from2%TYPE DEFAULT NULL;
      l_new_amount_applied_from3      ar_payments_interface_all.amount_applied_from3%TYPE DEFAULT NULL;
      l_new_amount_applied_from4      ar_payments_interface_all.amount_applied_from4%TYPE DEFAULT NULL;
      l_new_amount_applied_from5      ar_payments_interface_all.amount_applied_from5%TYPE DEFAULT NULL;
      l_new_amount_applied_from6      ar_payments_interface_all.amount_applied_from6%TYPE DEFAULT NULL;
      l_new_amount_applied_from7      ar_payments_interface_all.amount_applied_from7%TYPE DEFAULT NULL;
      l_new_amount_applied_from8      ar_payments_interface_all.amount_applied_from8%TYPE DEFAULT NULL;

      l_currency_code1                ar_payments_interface_all.INVOICE_CURRENCY_CODE1%TYPE DEFAULT NULL;
      l_currency_code2                ar_payments_interface_all.INVOICE_CURRENCY_CODE2%TYPE DEFAULT NULL;
      l_currency_code3                ar_payments_interface_all.INVOICE_CURRENCY_CODE3%TYPE DEFAULT NULL;
      l_currency_code4                ar_payments_interface_all.INVOICE_CURRENCY_CODE4%TYPE DEFAULT NULL;
      l_currency_code5                ar_payments_interface_all.INVOICE_CURRENCY_CODE5%TYPE DEFAULT NULL;
      l_currency_code6                ar_payments_interface_all.INVOICE_CURRENCY_CODE6%TYPE DEFAULT NULL;
      l_currency_code7                ar_payments_interface_all.INVOICE_CURRENCY_CODE7%TYPE DEFAULT NULL;
      l_currency_code8                ar_payments_interface_all.INVOICE_CURRENCY_CODE8%TYPE DEFAULT NULL;

      l_new_currency_code1            ar_payments_interface_all.INVOICE_CURRENCY_CODE1%TYPE DEFAULT NULL;
      l_new_currency_code2            ar_payments_interface_all.INVOICE_CURRENCY_CODE2%TYPE DEFAULT NULL;
      l_new_currency_code3            ar_payments_interface_all.INVOICE_CURRENCY_CODE3%TYPE DEFAULT NULL;
      l_new_currency_code4            ar_payments_interface_all.INVOICE_CURRENCY_CODE4%TYPE DEFAULT NULL;
      l_new_currency_code5            ar_payments_interface_all.INVOICE_CURRENCY_CODE5%TYPE DEFAULT NULL;
      l_new_currency_code6            ar_payments_interface_all.INVOICE_CURRENCY_CODE6%TYPE DEFAULT NULL;
      l_new_currency_code7            ar_payments_interface_all.INVOICE_CURRENCY_CODE7%TYPE DEFAULT NULL;
      l_new_currency_code8            ar_payments_interface_all.INVOICE_CURRENCY_CODE8%TYPE DEFAULT NULL;

      l_new_trans_to_rct_rate1        ar_payments_interface_all.TRANS_TO_RECEIPT_RATE1%TYPE DEFAULT NULL;
      l_new_trans_to_rct_rate2        ar_payments_interface_all.TRANS_TO_RECEIPT_RATE2%TYPE DEFAULT NULL;
      l_new_trans_to_rct_rate3        ar_payments_interface_all.TRANS_TO_RECEIPT_RATE3%TYPE DEFAULT NULL;
      l_new_trans_to_rct_rate4        ar_payments_interface_all.TRANS_TO_RECEIPT_RATE4%TYPE DEFAULT NULL;
      l_new_trans_to_rct_rate5        ar_payments_interface_all.TRANS_TO_RECEIPT_RATE5%TYPE DEFAULT NULL;
      l_new_trans_to_rct_rate6        ar_payments_interface_all.TRANS_TO_RECEIPT_RATE6%TYPE DEFAULT NULL;
      l_new_trans_to_rct_rate7        ar_payments_interface_all.TRANS_TO_RECEIPT_RATE7%TYPE DEFAULT NULL;
      l_new_trans_to_rct_rate8        ar_payments_interface_all.TRANS_TO_RECEIPT_RATE8%TYPE DEFAULT NULL;


      l_tolerance                     okl_cash_allctn_rls.amount_tolerance_percent%TYPE
                                                                 DEFAULT NULL;
      l_days_past_quote_valid         okl_cash_allctn_rls.days_past_quote_valid_toleranc%TYPE
                                                                 DEFAULT NULL;
      l_quote_id                      okl_trx_quotes_v.ID%TYPE   DEFAULT NULL;
      l_quote_amount                  okl_txl_quote_lines_v.amount%TYPE
                                                                 DEFAULT NULL;
      l_quote_number                  okl_trx_quotes_v.quote_number%TYPE
                                                                 DEFAULT NULL;
      l_quote_date_effective_to       okl_trx_quotes_v.date_effective_to%TYPE
                                                                 DEFAULT NULL;
      l_party_id                      okx_customer_accounts_v.party_id%TYPE
                                                                 DEFAULT NULL;
      l_err_msg                       VARCHAR2 (2000);
      l_valid_ar_reference            VARCHAR2 (1);
      l_no_match_indicator            NUMBER                             := 0;
                                               -- refer to bug number 3783202
      i                               NUMBER                     DEFAULT NULL;
      j                               NUMBER                     DEFAULT NULL;
      k                               NUMBER                     DEFAULT NULL;
      seq_num                         NUMBER                     DEFAULT NULL;
      l_trans_rec_count               NUMBER                     DEFAULT NULL;
      l_api_version                   NUMBER                           := 1.0;
      l_init_msg_list                 VARCHAR2 (1)         := okc_api.g_false;
      l_return_status                 VARCHAR2 (1);
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
      --asawanka modified for llaca start
      l_hdr_idx                       NUMBER;
      l_inv_indx                      NUMBER;
      l_line_indx                     NUMBER;
      l_transmission_rec_id_of        NUMBER;
      l_amt1_prec                     NUMBER;
      l_amt2_prec                     NUMBER;
      l_amt3_prec                     NUMBER;
      l_amt4_prec                     NUMBER;
      l_amt5_prec                     NUMBER;
      l_amt6_prec                     NUMBER;
      l_amt7_prec                     NUMBER;
      l_amt8_prec                     NUMBER;
      l_amt_from1_prec               NUMBER;
      l_amt_from2_prec               NUMBER;
      l_amt_from3_prec               NUMBER;
      l_amt_from4_prec               NUMBER;
      l_amt_from5_prec               NUMBER;
      l_amt_from6_prec               NUMBER;
      l_amt_from7_prec               NUMBER;
      l_amt_from8_prec               NUMBER;
      l_prec_to_use                  NUMBER;
      l_prec_to_use_from             NUMBER;
      l_ovf_ind                       VARCHAR2 (3);
      --START: Fixed as part of bug 6780241 by nikshah
      l_amount_in_inv_curr           NUMBER;
      l_amount_in_rct_curr           NUMBER;
      --END: Fixed as part of bug 6780241 by nikshah

--asawanka modified for llaca end
-- l_zero_receipt                      EXCEPTION;
-- l_zero_invoice                      EXCEPTION;
-- l_no_cash_rule                      EXCEPTION;
-- l_del_int                   EXCEPTION;
------------------------------
-- DECLARE Record/Table Types
------------------------------
-- Internal Trans
      TYPE l_orig_rcpt_rec_type IS RECORD (
         invoice_number   ar_payments_interface_all.invoice1%TYPE
                                                                 DEFAULT NULL,
         amount_applied   ar_payments_interface_all.amount_applied1%TYPE
                                                                 DEFAULT NULL,
         amount_applied_from   ar_payments_interface_all.AMOUNT_APPLIED_FROM1%TYPE
                                                                 DEFAULT NULL,
         trans_to_receipt_rate   ar_payments_interface_all.TRANS_TO_RECEIPT_RATE1%TYPE
                                                                 DEFAULT NULL,
         currency_code    ar_payments_interface_all.currency_code%TYPE
                                                                 DEFAULT NULL
      );

      TYPE l_orig_rcpt_tbl_type IS TABLE OF l_orig_rcpt_rec_type
         INDEX BY BINARY_INTEGER;

      l_orig_rcpt_tbl                 l_orig_rcpt_tbl_type;
      l_no_mtch_rcpt_tbl              l_orig_rcpt_tbl_type;
      l_initialize_table              l_orig_rcpt_tbl_type;
      l_qtev_rec                      okl_qte_pvt.qtev_rec_type;
      x_qtev_rec                      okl_qte_pvt.qtev_rec_type;
      -- Begin - Changes for CAR API structure change
      l_onacc_amount                  NUMBER                              := 0;
      l_unapply_amount                NUMBER                              := 0;
      l_onacc_unapp_exist             VARCHAR2 (1)                      := 'N';

-- End - Changes for CAR API structure change
-------------------
-- DECLARE Cursors
-------------------
-- get customer number if not known
--asawanka modified for llca start
-- modified query to get rid of obsolete view
      CURSOR c_get_cust_via_micr (
         cp_transit_routing_number   IN   VARCHAR2,
         cp_account                  IN   VARCHAR2
      ) IS
         SELECT hca.account_number
           FROM iby_ext_bank_accounts_v a,
                iby_ext_bank_accounts b,
                iby_pmt_instr_uses_all ipiua,
                iby_external_payers_all iepa,
                hz_cust_accounts hca
          WHERE a.ext_bank_account_id = b.ext_bank_account_id
            AND ipiua.instrument_id = a.ext_bank_account_id
            AND ipiua.ext_pmt_party_id = iepa.ext_payer_id
            AND ipiua.payment_flow = 'FUNDS_CAPTURE'
            AND iepa.cust_account_id = hca.cust_account_id
            AND a.bank_number = cp_transit_routing_number
            AND b.bank_account_num = cp_account;

      --asawanka modified for llca end
      --------
      -- get tranmission format record identifiers
      CURSOR c_get_trans_fmt (cp_trans_req_id IN NUMBER) IS
         SELECT   b.record_identifier,
                  b.record_type_lookup_code,
                  b.transmission_format_id
             FROM ar_transmissions_all a, ar_trans_record_formats b
            WHERE a.requested_trans_format_id = b.transmission_format_id
              AND a.transmission_request_id = cp_trans_req_id
         ORDER BY b.record_identifier;

      ----------
      -- get overflow indicator
      CURSOR c_get_ovr_flw_indicator (cp_trans_frmt_id IN NUMBER) IS
         SELECT overflow_rec_indicator
           FROM ar_trans_field_formats
          WHERE transmission_format_id = cp_trans_frmt_id
            AND overflow_rec_indicator IS NOT NULL;

      ----------
      -- varao - Bug#5075248 - Modified - Start
      -- Changing the column to query for the amounts to be applied against invoices to TMP_AMT_APPLIED columns instead
      --  of the AMOUNT_APPLIED   columns
      -- get lockbox payment records
      CURSOR c_get_pmt_recs (cp_trans_req_id IN NUMBER, cp_rec_type IN VARCHAR) IS
         SELECT   transmission_record_id,
                  transmission_id,
                  lockbox_number,
                  batch_name,
                  remittance_amount,
                  NVL (receipt_date, SYSDATE),
                  item_number,
                  currency_code,
                  customer_number,
                  check_number,
                  transit_routing_number,
                  ACCOUNT,
                  TRIM (invoice1),
                  TRIM (invoice2),
                  TRIM (invoice3),
                  TRIM (invoice4),
                  TRIM (invoice5),
                  TRIM (invoice6),
                  TRIM (invoice7),
                  TRIM (invoice8),
                  tmp_amt_applied1,
                  tmp_amt_applied2,
                  tmp_amt_applied3,
                  tmp_amt_applied4,
                  tmp_amt_applied5,
                  tmp_amt_applied6,
                  tmp_amt_applied7,
                  tmp_amt_applied8,
                  TMP_AMT_APPLIED_FROM1,
                  TMP_AMT_APPLIED_FROM2,
                  TMP_AMT_APPLIED_FROM3,
                  TMP_AMT_APPLIED_FROM4,
                  TMP_AMT_APPLIED_FROM5,
                  TMP_AMT_APPLIED_FROM6,
                  TMP_AMT_APPLIED_FROM7,
                  TMP_AMT_APPLIED_FROM8,
                  TRANS_TO_RECEIPT_RATE1,
                  TRANS_TO_RECEIPT_RATE2,
                  TRANS_TO_RECEIPT_RATE3,
                  TRANS_TO_RECEIPT_RATE4,
                  TRANS_TO_RECEIPT_RATE5,
                  TRANS_TO_RECEIPT_RATE6,
                  TRANS_TO_RECEIPT_RATE7,
                  TRANS_TO_RECEIPT_RATE8,
                  INVOICE_CURRENCY_CODE1,
                  INVOICE_CURRENCY_CODE2,
                  INVOICE_CURRENCY_CODE3,
                  INVOICE_CURRENCY_CODE4,
                  INVOICE_CURRENCY_CODE5,
                  INVOICE_CURRENCY_CODE6,
                  INVOICE_CURRENCY_CODE7,
                  INVOICE_CURRENCY_CODE8,
/*                  tmp_amt_applied_from1,
                  tmp_amt_applied_from2,
                  tmp_amt_applied_from3,
                  tmp_amt_applied_from4,
                  tmp_amt_applied_from5,
                  tmp_amt_applied_from6,
                  tmp_amt_applied_from7,
                  tmp_amt_applied_from8,
                  TMP_TRANS_TO_RCPT_RATE1,
                  TMP_TRANS_TO_RCPT_RATE2,
                  TMP_TRANS_TO_RCPT_RATE3,
                  TMP_TRANS_TO_RCPT_RATE4,
                  TMP_TRANS_TO_RCPT_RATE5,
                  TMP_TRANS_TO_RCPT_RATE6,
                  TMP_TRANS_TO_RCPT_RATE7,
                  TMP_TRANS_TO_RCPT_RATE8,
                  TMP_INV_CURRENCY_CODE1,
                  TMP_INV_CURRENCY_CODE2,
                  TMP_INV_CURRENCY_CODE3,
                  TMP_INV_CURRENCY_CODE4,
                  TMP_INV_CURRENCY_CODE5,
                  TMP_INV_CURRENCY_CODE6,
                  TMP_INV_CURRENCY_CODE7,
                  TMP_INV_CURRENCY_CODE8, */
                  org_id
             FROM ar_payments_interface_all
            WHERE transmission_request_id = cp_trans_req_id
              AND record_type = cp_rec_type
         ORDER BY item_number;

      ----------
      -- Changing the column to query for the amounts to be applied against invoices to TMP_AMT_APPLIED columns instead
      --  of the AMOUNT_APPLIED   columns
      -- get lockbox overflow records
      CURSOR c_get_ovrflw_recs (
         cp_trans_req_id   IN   NUMBER,
         cp_rec_type       IN   VARCHAR,
         cp_item_number    IN   NUMBER,
         cp_batch_name     IN   VARCHAR2
      ) IS
         SELECT   transmission_record_id,
                  --            currency_code, we will fetch currecny code from payment record only
                  TRIM (invoice1),
                  TRIM (invoice2),
                  TRIM (invoice3),
                  TRIM (invoice4),
                  TRIM (invoice5),
                  TRIM (invoice6),
                  TRIM (invoice7),
                  TRIM (invoice8),
                  tmp_amt_applied1,
                  tmp_amt_applied2,
                  tmp_amt_applied3,
                  tmp_amt_applied4,
                  tmp_amt_applied5,
                  tmp_amt_applied6,
                  tmp_amt_applied7,
                  tmp_amt_applied8,
                  TMP_AMT_APPLIED_FROM1,
                  TMP_AMT_APPLIED_FROM2,
                  TMP_AMT_APPLIED_FROM3,
                  TMP_AMT_APPLIED_FROM4,
                  TMP_AMT_APPLIED_FROM5,
                  TMP_AMT_APPLIED_FROM6,
                  TMP_AMT_APPLIED_FROM7,
                  TMP_AMT_APPLIED_FROM8,
                  TRANS_TO_RECEIPT_RATE1,
                  TRANS_TO_RECEIPT_RATE2,
                  TRANS_TO_RECEIPT_RATE3,
                  TRANS_TO_RECEIPT_RATE4,
                  TRANS_TO_RECEIPT_RATE5,
                  TRANS_TO_RECEIPT_RATE6,
                  TRANS_TO_RECEIPT_RATE7,
                  TRANS_TO_RECEIPT_RATE8,
                  INVOICE_CURRENCY_CODE1,
                  INVOICE_CURRENCY_CODE2,
                  INVOICE_CURRENCY_CODE3,
                  INVOICE_CURRENCY_CODE4,
                  INVOICE_CURRENCY_CODE5,
                  INVOICE_CURRENCY_CODE6,
                  INVOICE_CURRENCY_CODE7,
                  INVOICE_CURRENCY_CODE8
/*                  tmp_amt_applied_from1,
                  tmp_amt_applied_from2,
                  tmp_amt_applied_from3,
                  tmp_amt_applied_from4,
                  tmp_amt_applied_from5,
                  tmp_amt_applied_from6,
                  tmp_amt_applied_from7,
                  tmp_amt_applied_from8,
                  TMP_TRANS_TO_RCPT_RATE1,
                  TMP_TRANS_TO_RCPT_RATE2,
                  TMP_TRANS_TO_RCPT_RATE3,
                  TMP_TRANS_TO_RCPT_RATE4,
                  TMP_TRANS_TO_RCPT_RATE5,
                  TMP_TRANS_TO_RCPT_RATE6,
                  TMP_TRANS_TO_RCPT_RATE7,
                  TMP_TRANS_TO_RCPT_RATE8,
                  TMP_INV_CURRENCY_CODE1,
                  TMP_INV_CURRENCY_CODE2,
                  TMP_INV_CURRENCY_CODE3,
                  TMP_INV_CURRENCY_CODE4,
                  TMP_INV_CURRENCY_CODE5,
                  TMP_INV_CURRENCY_CODE6,
                  TMP_INV_CURRENCY_CODE7,
                  TMP_INV_CURRENCY_CODE8*/
             FROM ar_payments_interface_all
            WHERE transmission_request_id = cp_trans_req_id
              AND record_type = cp_rec_type
              AND item_number = cp_item_number
              AND overflow_sequence IS NOT NULL
              AND (batch_name IS NULL OR batch_name = cp_batch_name
                  )                                        --Fixed bug 6033325
         ORDER BY overflow_sequence;

      -- varao - Bug#5075248 - Modified - End
      ----------
      -- get NEW lockbox overflow records
      CURSOR c_get_ovrflw_recs_new (
         cp_trans_req_id   IN   NUMBER,
         cp_rec_type       IN   VARCHAR,
         cp_item_number    IN   NUMBER,
         cp_batch_name     IN   VARCHAR2
      ) IS
         SELECT   transmission_record_id
             FROM ar_payments_interface_all
            WHERE transmission_request_id = cp_trans_req_id
              AND record_type = cp_rec_type
              AND item_number = cp_item_number
              AND overflow_sequence IS NULL
              AND (batch_name IS NULL OR batch_name = cp_batch_name
                  )                                        --Fixed bug 6033325
         ORDER BY transmission_record_id;

      ----------
      -- get transmission count
      CURSOR c_get_trans_rec_count (cp_trans_req_id IN NUMBER) IS
                                             -- , cp_rec_type IN VARCHAR2 ) IS
         SELECT COUNT (*)
           FROM ar_payments_interface_all
          WHERE transmission_request_id = cp_trans_req_id;

      --AND      record_type <> cp_rec_type;
      ----------
      -- get cash applic rules
      --asawanka modified for llca start
      -- added org_id parameter to filter by org_id. Also added default_rule filter as we want default rule
      -- set for that org
      CURSOR c_cash_applic_rules (cp_org_id IN NUMBER) IS
         SELECT days_past_quote_valid_toleranc,
                amount_tolerance_percent
           FROM okl_cash_allctn_rls
          WHERE default_rule = 'YES' AND org_id = cp_org_id;

      --asawanka modified for llca end
      ----------
      --asawanka modified for llca start
      --Instead oh checkin. OKL_EXT_CSH_RCPTS_B table ,which is obsolete,
      -- we will check if

      -- check to see if lock box already has line level data for the invocie in theis transmission
      CURSOR c_lckbx_status (
         cp_transmission_request_id   IN   NUMBER,
         cp_transmission_record_id    IN   VARCHAR2,
         cp_invoice_number            IN   VARCHAR2
      ) IS
         SELECT 'Y'
           FROM ar_pmts_interface_line_details
          WHERE transmission_request_id = cp_transmission_request_id
            AND transmission_record_id = cp_transmission_record_id
            AND invoice_number = cp_invoice_number;

            --asawanka modified for llca end
            ----------
            /*
        -- get termination quote
        CURSOR  c_check_termination (cp_cust_id IN NUMBER,
                                     cp_rcpt_date IN DATE,
                                     cp_date_tol IN NUMBER)IS
        SELECT  tq.id quote_id,
                tq.date_effective_to,
                SUM(NVL(tl.amount,0)) quote_amount
        FROM    okc_k_party_roles_v pr,
                okl_quote_parties_v qp,
                okl_trx_quotes_v tq,
                okl_txl_quote_lines_v tl
        WHERE   pr.jtot_object1_code = 'OKX_PARTY'
        AND     pr.object1_id2  = '#'
        AND     pr.object1_id1 = cp_cust_id
        AND     qp.cpl_id  = pr.id
        AND     qp.qpt_code  = 'RECIPIENT'
        AND     tq.id   = qp.qte_id
        AND     TRUNC(cp_rcpt_date) BETWEEN TRUNC (tq.date_effective_from)
        AND     TRUNC(NVL((tq.date_effective_to + cp_date_tol), SYSDATE))
        AND     tl.qte_id  = tq.id
        AND     NVL(tq.accepted_yn,'N') = 'N' and tq.qtp_code like 'TER%'
        AND     NVL(tq.payment_received_yn,'N') = 'N'
        AND     NVL(tq.preproceeds_yn,'N') = 'N'
        GROUP   BY pr.object1_id1, tq.id, tq.date_effective_to;
      */
            ----------
            -- get termination quote
      CURSOR c_check_termination (
         cp_cust_id        IN   NUMBER,
         cp_rcpt_date      IN   DATE,
         cp_date_tol       IN   NUMBER,
         cp_quote_number   IN   VARCHAR2
      ) IS
         SELECT   tq.ID quote_id,
                  tq.date_effective_to,
                  tq.quote_number,
                  SUM (NVL (tl.amount, 0)) quote_amount
             FROM okc_k_party_roles_v pr,
                  okl_quote_parties_v qp,
                  okl_trx_quotes_v tq,
                  okl_txl_quote_lines_v tl
            WHERE pr.jtot_object1_code = 'OKX_PARTY'
              AND pr.object1_id2 = '#'
              AND pr.object1_id1 = cp_cust_id
              AND qp.cpl_id = pr.ID
              AND qp.qpt_code = 'RECIPIENT'
              AND tq.ID = qp.qte_id
              AND TRUNC (cp_rcpt_date) BETWEEN TRUNC (tq.date_effective_from)
                                           AND TRUNC
                                                 (NVL
                                                     ((  tq.date_effective_to
                                                       + cp_date_tol
                                                      ),
                                                      SYSDATE
                                                     )
                                                 )
              AND tl.qte_id = tq.ID
              AND NVL (tq.accepted_yn, 'N') = 'N'
              AND tq.qtp_code LIKE 'TER%'
              AND NVL (tq.payment_received_yn, 'N') = 'N'
              AND NVL (tq.preproceeds_yn, 'N') = 'N'
              AND TO_CHAR (tq.quote_number) = cp_quote_number
              AND tq.qst_code IN ('APPROVED')
              AND tl.qlt_code NOT IN ('AMCFIA')
              AND qtp_code NOT IN
                     ('TER_ROLL_PURCHASE', 'TER_ROLL_WO_PURCHASE')
                                                          -- Added Bug 3953303
         GROUP BY pr.object1_id1, tq.ID, tq.date_effective_to,
                  tq.quote_number;

      ----------
      -- get party id for checking termination quote
      CURSOR c_get_party_id (cp_cust_num IN NUMBER) IS
         SELECT party_id
           FROM okx_customer_accounts_v
          WHERE description = TO_CHAR (cp_cust_num);

      ----------
      l_linelevel_app                 VARCHAR2 (1)                 DEFAULT 'Y';
      -- akrangan added for debug feature start
      l_module_name                   VARCHAR2 (500)
                                         := g_module || 'handle_auto_pay';
   -- akrangan added for debug feature end
   BEGIN
      --asawanka modified for llca start
      -- commenting out as it is now moved below inside loop
      /*
        OPEN c_Cash_apPlic_Rules;
        FETCH c_Cash_apPlic_Rules INTO l_Days_Past_Quote_Valid,l_Tolerance;
        CLOSE c_Cash_apPlic_Rules;
        */
      IF (l_debug_enabled = 'Y') THEN
         l_level_statement := fnd_log.level_statement;
         is_debug_statement_on :=
                     okl_debug_pub.check_log_on (l_module, l_level_statement);
      END IF;

      log_debug
         ('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
         );
      log_debug
         (   ' okl_lckbx_csh_app_pvt.handle_auto_pay start. Parameter p_trans_req_id = '
          || p_trans_req_id
         );
      --asawanka modified for llca end
      l_trans_req_id := p_trans_req_id;
      -- get transmission record format for this lock box.
      log_debug ('Fetching Transmission format Identifiers');

      OPEN c_get_trans_fmt (l_trans_req_id);

      LOOP
         FETCH c_get_trans_fmt
          INTO l_record_identifier,
               l_record_type_lookup_code,
               l_transmission_format_id;

         EXIT WHEN c_get_trans_fmt%NOTFOUND;

         IF l_record_type_lookup_code = 'TRANS HDR' THEN
            l_transmission_hdr := l_record_identifier;
         ELSIF l_record_type_lookup_code = 'TRANS TRL' THEN
            l_transmission_trl := l_record_identifier;
         ELSIF l_record_type_lookup_code = 'PAYMENT' THEN
            l_payment := l_record_identifier;
         ELSIF l_record_type_lookup_code = 'OVRFLW PAYMENT' THEN
            l_overflow := l_record_identifier;
         ELSIF l_record_type_lookup_code = 'SERVICE HDR' THEN
            l_service := l_record_identifier;
         END IF;
      END LOOP;

      CLOSE c_get_trans_fmt;

      OPEN c_get_ovr_flw_indicator (l_transmission_format_id);

      FETCH c_get_ovr_flw_indicator
       INTO l_overflow_rec_indicator;

      CLOSE c_get_ovr_flw_indicator;

      -- got what we need - lets start processing.
      -- get payment and related over flow records in lockbox.
      log_debug ('Fetching Payment Records');

      OPEN c_get_pmt_recs (l_trans_req_id, l_payment);

      LOOP                -- (1) Payments through each record of type Payment.
         FETCH c_get_pmt_recs
          INTO l_transmission_record_id,
               l_transmission_id,
               l_lockbox_number,
               l_batch_name,
               l_remittance_amount,
               l_receipt_date,
               l_item_number,
               l_currency_code,
               l_customer_number,
               l_check_number,
               l_transit_routing_number,            -- Used for MICR customers
               l_account,                           -- Used for MICR customers
               l_invoice1,
               l_invoice2,
               l_invoice3,
               l_invoice4,
               l_invoice5,
               l_invoice6,
               l_invoice7,
               l_invoice8,
               l_amount_applied1,
               l_amount_applied2,
               l_amount_applied3,
               l_amount_applied4,
               l_amount_applied5,
               l_amount_applied6,
               l_amount_applied7,
               l_amount_applied8,
               l_amount_app_from1,
               l_amount_app_from2,
               l_amount_app_from3,
               l_amount_app_from4,
               l_amount_app_from5,
               l_amount_app_from6,
               l_amount_app_from7,
               l_amount_app_from8,
               l_trans_to_receipt_rate1,
               l_trans_to_receipt_rate2,
               l_trans_to_receipt_rate3,
               l_trans_to_receipt_rate4,
               l_trans_to_receipt_rate5,
               l_trans_to_receipt_rate6,
               l_trans_to_receipt_rate7,
               l_trans_to_receipt_rate8,
               l_currency_code1,
               l_currency_code2,
               l_currency_code3,
               l_currency_code4,
               l_currency_code5,
               l_currency_code6,
               l_currency_code7,
               l_currency_code8,
               l_org_id;

         EXIT WHEN c_get_pmt_recs%NOTFOUND;
         log_debug (' ');
         log_debug (   'Processiong payment record. Tranmission Record Id =  '
                    || l_transmission_record_id
                   );

         --asawanka modified for llca start
         -- moved from above to here as we need to pass org id to get default rule
         OPEN c_cash_applic_rules (l_org_id);

         FETCH c_cash_applic_rules
          INTO l_days_past_quote_valid,
               l_tolerance;

         CLOSE c_cash_applic_rules;

         --asawanka modified for llca end
         -- Check for customer number.
         IF l_customer_number IS NULL THEN                -- check MICR Number
            log_debug
               ('Customer Number not specified. Trying to find out from transit routing number and  bank account '
               );

            IF l_transit_routing_number IS NOT NULL AND l_account IS NOT NULL THEN
               -- this piece of code is not correct. cursor c_get_cust_via_micr needs to be modified
               -- to fetch correct customer number from micr
               OPEN c_get_cust_via_micr (l_transit_routing_number, l_account);

               FETCH c_get_cust_via_micr
                INTO l_customer_number;

               CLOSE c_get_cust_via_micr;
            ELSE
-- next payment record as we have no customer_number  ( see enhancements up top )
               log_debug ('Not able to identify customer number');
               EXIT;           -- LOOP (1) move on to next payment record ...
            END IF;
         END IF;

         log_debug ('Customer Number = ' || l_customer_number);
         log_debug ('Fetching precisions for amount columns');
         --asawanka modified for llca start
         -- fetch format precision for amounts in interface table for the receipt currency
         -- Used for search rules, receipt mismatch and termination quote where cross currency
         -- application is blocked and for no reference matched also
         l_amt1_prec := get_precision (NVL(l_currency_code1,l_currency_code),p_trans_req_id,'PAYMENT','AMT APP 1');
         l_amt2_prec := get_precision (NVL(l_currency_code2,l_currency_code),p_trans_req_id,'PAYMENT','AMT APP 2');
         l_amt3_prec := get_precision (NVL(l_currency_code3,l_currency_code),p_trans_req_id,'PAYMENT','AMT APP 3');
         l_amt4_prec := get_precision (NVL(l_currency_code4,l_currency_code),p_trans_req_id,'PAYMENT','AMT APP 4');
         l_amt5_prec := get_precision (NVL(l_currency_code5,l_currency_code),p_trans_req_id,'PAYMENT','AMT APP 5');
         l_amt6_prec := get_precision (NVL(l_currency_code6,l_currency_code),p_trans_req_id,'PAYMENT','AMT APP 6');
         l_amt7_prec := get_precision (NVL(l_currency_code7,l_currency_code),p_trans_req_id,'PAYMENT','AMT APP 7');
         l_amt8_prec := get_precision (NVL(l_currency_code8,l_currency_code),p_trans_req_id,'PAYMENT','AMT APP 8');
         --asawanka modified for llca end

         -- process payment record invoice(s)
         -- new overflow rec for each payment rec inv ref
         -- update payment record once and for all.
         i := 1;
         j := 1;
         -- initialize all pl/sql tables used by this process
         l_orig_rcpt_tbl := l_initialize_table;
         l_no_mtch_rcpt_tbl := l_initialize_table;
         l_okl_rcpt_tbl := l_okl_init_tbl;
         l_orig_rcpt_tbl (i).invoice_number := l_invoice1;
         l_orig_rcpt_tbl (i).amount_applied :=
              ROUND (l_amount_applied1 / POWER (10, l_amt1_prec), l_amt1_prec);
         l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from1/power(10,l_amt_from1_prec),l_amt_from1_prec);
         l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate1;
         l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
         l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
         l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
         l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

         i := i + 1;
         j := j + 1;
         l_orig_rcpt_tbl (i).invoice_number := l_invoice2;
         l_orig_rcpt_tbl (i).amount_applied :=
              ROUND (l_amount_applied2 / POWER (10, l_amt2_prec), l_amt2_prec);
         l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from2/power(10,l_amt_from2_prec),l_amt_from2_prec);
         l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate2;
         l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
         l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
         l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
         l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

         i := i + 1;
         j := j + 1;
         l_orig_rcpt_tbl (i).invoice_number := l_invoice3;
         l_orig_rcpt_tbl (i).amount_applied :=
              ROUND (l_amount_applied3 / POWER (10, l_amt3_prec), l_amt3_prec);
         l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from3/power(10,l_amt_from3_prec),l_amt_from3_prec);
         l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate3;
         l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
         l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
         l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
         l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

         i := i + 1;
         j := j + 1;
         l_orig_rcpt_tbl (i).invoice_number := l_invoice4;
         l_orig_rcpt_tbl (i).amount_applied :=
              ROUND (l_amount_applied4 / POWER (10, l_amt4_prec), l_amt4_prec);
         l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from4/power(10,l_amt_from4_prec),l_amt_from4_prec);
         l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate4;
         l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
         l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
         l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
         l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

         i := i + 1;
         j := j + 1;
         l_orig_rcpt_tbl (i).invoice_number := l_invoice5;
         l_orig_rcpt_tbl (i).amount_applied :=
              ROUND (l_amount_applied5 / POWER (10, l_amt5_prec), l_amt5_prec);
         l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from5/power(10,l_amt_from5_prec),l_amt_from5_prec);
         l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate5;
         l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
         l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
         l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
         l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

         i := i + 1;
         j := j + 1;
         l_orig_rcpt_tbl (i).invoice_number := l_invoice6;
         l_orig_rcpt_tbl (i).amount_applied :=
              ROUND (l_amount_applied6 / POWER (10, l_amt6_prec), l_amt6_prec);
         l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from6/power(10,l_amt_from6_prec),l_amt_from6_prec);
         l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate6;
         l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
         l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
         l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
         l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

         i := i + 1;
         j := j + 1;
         l_orig_rcpt_tbl (i).invoice_number := l_invoice7;
         l_orig_rcpt_tbl (i).amount_applied :=
              ROUND (l_amount_applied7 / POWER (10, l_amt7_prec), l_amt7_prec);
         l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from7/power(10,l_amt_from7_prec),l_amt_from7_prec);
         l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate7;
         l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
         l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
         l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
         l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

         i := i + 1;
         j := j + 1;
         l_orig_rcpt_tbl (i).invoice_number := l_invoice8;
         l_orig_rcpt_tbl (i).amount_applied :=
              ROUND (l_amount_applied8 / POWER (10, l_amt8_prec), l_amt8_prec);
         l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from8/power(10,l_amt_from8_prec),l_amt_from8_prec);
         l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate8;
         l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
         l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
         l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
         l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

         i := 1;                                               -- first record
         j := 1;
         log_debug ('Processing invoice references in this payment record...');

         LOOP
             -- (2) Loop through all payment record invoice/payment references
            l_okl_rcpt_tbl := l_okl_init_tbl;
			select decode(i,1,l_amount_applied1,2,l_amount_applied2,
					      3, l_amount_applied3,4,l_amount_applied4,
					      5,l_amount_applied5,6,l_amount_applied6,
						  7,l_amount_applied7,8,l_amount_applied8),
				   decode(i,1,l_amount_app_from1,2,l_amount_app_from2,
					      3, l_amount_app_from3,4,l_amount_app_from4,
					      5,l_amount_app_from5,6,l_amount_app_from6,
						  7,l_amount_app_from7,8,l_amount_app_from8),
				   decode(i,1,l_currency_code1,2,l_currency_code2,
					      3,l_currency_code3,4,l_currency_code4,
					      5,l_currency_code5,6,l_currency_code6,
						  7,l_currency_code7,8,l_currency_code8)
             into l_tmp_amount_applied, l_tmp_amount_app_from, l_tmp_currency_code
             from dual;


        IF l_orig_rcpt_tbl(i).invoice_number IS NOT NULL AND ( l_tmp_amount_applied IS NOT NULL OR l_tmp_amount_app_from IS NOT NULL)
            AND  ( l_tmp_amount_applied <> 0 OR l_tmp_amount_app_from <> 0 ) THEN
           log_debug('Invoice Reference = '||l_orig_rcpt_tbl(i).invoice_number);
           log_debug('Amount to apply to = '|| l_tmp_amount_applied);
           log_debug('Amount to apply from = '|| l_tmp_amount_app_from);
           log_debug('Transaction to Receipt Rate= '|| l_orig_rcpt_tbl(i).trans_to_receipt_rate);

-- invoke okl standard cash application rules
----------------------------------------------------------------------
-- check to see if given invoice reference maps to a valid non okl ar invoice.
-- if so then this reference should be left in lockbox ...
-- bug ref: 3068497
               IF valid_ar_reference (l_orig_rcpt_tbl (i).invoice_number,
                                      l_org_id
                                     ) THEN
                  l_valid_ar_reference := 'Y';
               ELSE
                  l_valid_ar_reference := 'N';
               END IF;

----------------------------------------------------------------------
--asawanka modified for llca start
--  check if line level data exists for this invoice
               l_lockbox_run_already := 'N';

               OPEN c_lckbx_status (l_trans_req_id,
                                    l_transmission_record_id,
                                    l_orig_rcpt_tbl (i).invoice_number
                                   );

               FETCH c_lckbx_status
                INTO l_lockbox_run_already;

               CLOSE c_lckbx_status;

               --asawanka modified for llca start
               -- if line level data already exists for this invoice then do not do any processing for this invoice
               IF l_lockbox_run_already = 'N' THEN
                  log_debug
                     ('No line level data for invoice reference. Further processing invoice reference'
                     );

                  --changed api calls.
                  IF l_valid_ar_reference = 'N' THEN
                     log_debug
                        ('Invoice reference is not valid non OKL AR invoice Number.'
                        );
                     log_debug
                        ('Trying to match Invocie Reference to OKL related AR invoice. ( Post R12 OKL Invoice)'
                        );
                     log_debug
                        ('Calling okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv with parameters: '
                        );
                     log_debug ('p_customer_num = ' || l_customer_number);
                     log_debug (   'p_arinv_number = '
                                || l_orig_rcpt_tbl (i).invoice_number
                               );
                     log_debug ('p_currency_code = ' || l_currency_code);
                     log_debug (   'p_rcpt_amount = '
                                || l_orig_rcpt_tbl (i).amount_applied
                               );
                     log_debug('p_inv_to_rct_rate = '|| l_orig_rcpt_tbl(i).trans_to_receipt_rate);
                     log_debug('p_receipt_date = ' || l_receipt_date);
                     log_debug ('p_org_id = ' || l_org_id);

                     IF is_valid_reference('INVOICE',
						                   l_orig_rcpt_tbl (i).invoice_number,
                                           l_currency_code1,
                                           l_trans_req_id,
                                           l_org_id,
                                           i,
                                           'PAYMENT',
                                           'AMT APP',
                                           'AMT APP FROM',
                                           l_customer_number,
                                           l_tmp_amount_applied,
                                           l_tmp_amount_app_from,
                                           l_returned_curr_code,
                                           l_returned_amount_to,
                                           l_returned_amount_from,
                                           l_returned_precision_to,
			       						   l_returned_precision_from)
					  THEN
                        l_orig_rcpt_tbl (i).amount_applied := l_returned_amount_to;
                        l_orig_rcpt_tbl (i).amount_applied_from := l_returned_amount_from;
                        log_debug('p_amount_app_to = '|| l_orig_rcpt_tbl(i).amount_applied);
                        log_debug('p_amount_app_from = '|| l_orig_rcpt_tbl(i).amount_applied_from);
                        log_debug('invoice currency = '|| l_returned_curr_code);
                        --Check if reference number matches any okl related AR invoices(Post R12 okl invoices)
                        okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv
                         (p_api_version         => l_api_version,
                          p_init_msg_list       => l_init_msg_list,
                          x_return_status       => l_return_status,
                          x_msg_count           => l_msg_count,
                          x_msg_data            => l_msg_data,
                          -- changed for bug 5391874
                          -- p_customer_num        => l_customer_number,
                          p_customer_num        => null,
                          p_arinv_number        => l_orig_rcpt_tbl (i).invoice_number,
                          p_currency_code       => l_currency_code,
--                          p_rcpt_amount         => l_orig_rcpt_tbl (i).amount_applied,
                          p_amount_app_to   => l_orig_rcpt_tbl(i).amount_applied,
                          p_amount_app_from   => l_orig_rcpt_tbl(i).amount_applied_from,
                          p_inv_to_rct_rate   => l_orig_rcpt_tbl(i).trans_to_receipt_rate,
                          p_receipt_date   => l_receipt_date,
                          p_org_id              => l_org_id,
                          x_appl_tbl            => l_okl_rcpt_tbl,
                          x_onacc_amount        => l_onacc_amount,
                          x_unapply_amount      => l_unapply_amount
                         );
                        log_debug
                        (   'okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv return status = '
                         || l_return_status
                        );
                        log_debug
                        (   'Number of invoices identified for application purpose = '
                         || l_okl_rcpt_tbl.COUNT
                        );

                        IF (l_onacc_amount > 0) OR (l_unapply_amount > 0) THEN
                          l_onacc_unapp_exist := 'Y';
                        ELSE
                          l_onacc_unapp_exist := 'N';
                        END IF;

                        log_debug (   ' On-Account / Unapplied amount exists : '
                                || l_onacc_unapp_exist
                               );
                      END IF;
                  END IF;

                  IF     l_okl_rcpt_tbl.COUNT = 0
                     AND l_valid_ar_reference = 'N'
                     AND l_onacc_unapp_exist = 'N' THEN
                     log_debug
                        ('Invoice Reference did not match to any OKL relate AR Invoice Number'
                        );
                     log_debug
                        ('Trying to match Invocie Reference to OKL Consolidated invoice. ( Pre R12 OKL Invoice)'
                        );
                     log_debug
                        ('Calling okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv with parameters: '
                        );
                     log_debug ('p_customer_num = ' || l_customer_number);
                     log_debug (   'p_cons_inv = '
                                || l_orig_rcpt_tbl (i).invoice_number
                               );
                     log_debug ('p_currency_code = ' || l_currency_code);
                     log_debug (   'p_rcpt_amount = '
                                || l_orig_rcpt_tbl (i).amount_applied
                               );
                     log_debug('p_amount_app_to = '|| l_orig_rcpt_tbl(i).amount_applied);
                     log_debug('p_amount_app_from = '|| l_orig_rcpt_tbl(i).amount_applied_from);
                     log_debug('p_inv_to_rct_rate = '|| l_orig_rcpt_tbl(i).trans_to_receipt_rate);
                     log_debug('p_receipt_date = ' || l_receipt_date);
                     log_debug ('p_org_id = ' || l_org_id);
                     IF is_valid_reference('CONS-INVOICE',
						                   l_orig_rcpt_tbl (i).invoice_number,
                                           l_currency_code1,
                                           l_trans_req_id,
                                           l_org_id,
                                           i,
                                           'PAYMENT',
                                           'AMT APP',
                                           'AMT APP FROM',
                                           l_customer_number,
                                           l_tmp_amount_applied,
                                           l_tmp_amount_app_from,
                                           l_returned_curr_code,
                                           l_returned_amount_to,
                                           l_returned_amount_from,
                                           l_returned_precision_to,
			       						   l_returned_precision_from)
					  THEN
                        l_orig_rcpt_tbl (i).amount_applied := l_returned_amount_to;
                        l_orig_rcpt_tbl (i).amount_applied_from := l_returned_amount_from;
                        log_debug('p_amount_app_to = '|| l_orig_rcpt_tbl(i).amount_applied);
                        log_debug('p_amount_app_from = '|| l_orig_rcpt_tbl(i).amount_applied_from);
                        log_debug('invoice currency = '|| l_returned_curr_code);
                        --Check if reference number matches any okl consolidated invoices (PRE R12 okl invoices)
                        okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv
                          (p_api_version         => l_api_version,
                           p_init_msg_list       => l_init_msg_list,
                           x_return_status       => l_return_status,
                           x_msg_count           => l_msg_count,
                           x_msg_data            => l_msg_data,
                           -- changed for bug 5391874
                          -- p_customer_num        => l_customer_number,
                          p_customer_num        => null,
                           p_cons_inv            => l_orig_rcpt_tbl (i).invoice_number,
                           p_currency_code       => l_currency_code,
--                           p_rcpt_amount         => l_orig_rcpt_tbl (i).amount_applied,
                          p_amount_app_to   => l_orig_rcpt_tbl(i).amount_applied,
                          p_amount_app_from   => l_orig_rcpt_tbl(i).amount_applied_from,
                          p_inv_to_rct_rate   => l_orig_rcpt_tbl(i).trans_to_receipt_rate,
                          p_receipt_date   => l_receipt_date,
                           p_org_id              => l_org_id,
                           x_appl_tbl            => l_okl_rcpt_tbl,
                           x_onacc_amount        => l_onacc_amount,
                           x_unapply_amount      => l_unapply_amount
                          );
                     log_debug
                        (   'okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv return status = '
                         || l_return_status
                        );
                     log_debug
                        (   'Number of invoices identified for application purpose = '
                         || l_okl_rcpt_tbl.COUNT
                        );

                     IF (l_onacc_amount > 0) OR (l_unapply_amount > 0) THEN
                        l_onacc_unapp_exist := 'Y';
                     ELSE
                        l_onacc_unapp_exist := 'N';
                     END IF;

                     log_debug (   ' On-Account / Unapplied amount exists : '
                                || l_onacc_unapp_exist
                               );
                    END IF;
                  END IF;

                  IF     l_okl_rcpt_tbl.COUNT = 0
                     AND l_valid_ar_reference = 'N'
                     AND l_onacc_unapp_exist = 'N' THEN
                     log_debug
                        ('Invoice Reference did not match to any OKL Consolidated Invoice Number'
                        );
                     log_debug
                        ('Trying to match Invocie Reference to OKL Contract Number.'
                        );
                     log_debug
                        ('Calling okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract with parameters: '
                        );
                     log_debug ('p_customer_num = ' || l_customer_number);
                     log_debug (   'p_contract_num = '
                                || l_orig_rcpt_tbl (i).invoice_number
                               );
                     log_debug ('p_currency_code = ' || l_currency_code);
                     log_debug (   'p_rcpt_amount = '
                                || l_orig_rcpt_tbl (i).amount_applied
                               );
                     log_debug('p_amount_app_to = '|| l_orig_rcpt_tbl(i).amount_applied);
                     log_debug('p_amount_app_from = '|| l_orig_rcpt_tbl(i).amount_applied_from);
                     log_debug('p_inv_to_rct_rate = '|| l_orig_rcpt_tbl(i).trans_to_receipt_rate);
                     log_debug('p_receipt_date = ' || l_receipt_date);
                     log_debug ('p_org_id = ' || l_org_id);
                     IF is_valid_reference('CONTRACT',
						                   l_orig_rcpt_tbl (i).invoice_number,
                                           l_currency_code, -- bug 7018894. from l_currency_code1
                                           l_trans_req_id,
                                           l_org_id,
                                           i,
                                           'PAYMENT',
                                           'AMT APP',
                                           'AMT APP FROM',
                                           l_customer_number,
                                           l_tmp_amount_applied,
                                           l_tmp_amount_app_from,
                                           l_returned_curr_code,
                                           l_returned_amount_to,
                                           l_returned_amount_from,
                                           l_returned_precision_to,
			       						   l_returned_precision_from)
					  THEN
                        l_orig_rcpt_tbl (i).amount_applied := l_returned_amount_to;
                        l_orig_rcpt_tbl (i).amount_applied_from := l_returned_amount_from;
                        log_debug('p_amount_app_to = '|| l_orig_rcpt_tbl(i).amount_applied);
                        log_debug('p_amount_app_from = '|| l_orig_rcpt_tbl(i).amount_applied_from);
                        log_debug('invoice currency = '|| l_returned_curr_code);
                        --Check if reference number matches any okl contracts
                        okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract
                         (p_api_version         => l_api_version,
                          p_init_msg_list       => l_init_msg_list,
                          x_return_status       => l_return_status,
                          x_msg_count           => l_msg_count,
                          x_msg_data            => l_msg_data,
                          -- changed for bug 5391874
                          -- p_customer_num        => l_customer_number,
                          p_customer_num        => null,
                          p_contract_num        => l_orig_rcpt_tbl (i).invoice_number,
                          p_currency_code       => l_currency_code,
--                          p_rcpt_amount         => l_orig_rcpt_tbl (i).amount_applied,
                          p_amount_app_to   => l_orig_rcpt_tbl(i).amount_applied,
                          p_amount_app_from   => l_orig_rcpt_tbl(i).amount_applied_from,
                          p_inv_to_rct_rate   => l_orig_rcpt_tbl(i).trans_to_receipt_rate,
                          p_receipt_date   => l_receipt_date,
                          p_org_id              => l_org_id,
                          x_appl_tbl            => l_okl_rcpt_tbl,
                          x_onacc_amount        => l_onacc_amount,
                          x_unapply_amount      => l_unapply_amount
                         );
                     log_debug
                        (   'okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract return status = '
                         || l_return_status
                        );
                     log_debug
                        (   'Number of invoices identified for application purpose = '
                         || l_okl_rcpt_tbl.COUNT
                        );

                     IF (l_onacc_amount > 0) OR (l_unapply_amount > 0) THEN
                        l_onacc_unapp_exist := 'Y';
                     ELSE
                        l_onacc_unapp_exist := 'N';
                     END IF;

                     log_debug (   ' On-Account / Unapplied amount exists : '
                                || l_onacc_unapp_exist
                               );
				    END IF;
                  END IF;

                  --asawanka modified  for llca end
                  IF     l_okl_rcpt_tbl.COUNT = 0
                     AND l_valid_ar_reference = 'N'
                     AND l_onacc_unapp_exist = 'N' THEN
                     -- lets use some combination rules.
                     log_debug
                        ('Invoice Reference did not match to any OKL Contract Number'
                        );
                     log_debug ('Trying to use Search Rules');
                     log_debug
                        ('Calling okl_combi_cash_app_rls_pvt.handle_combi_pay with parameters: '
                        );
                     log_debug ('p_customer_number = ' || l_customer_number);
                     log_debug (   'p_rcpt_amount = '
                                || l_orig_rcpt_tbl (i).amount_applied
                               );
                     log_debug ('p_org_id = ' || l_org_id);

                     IF l_tmp_currency_code IS NULL OR l_tmp_currency_code = l_currency_code
                     THEN

                        okl_combi_cash_app_rls_pvt.handle_combi_pay
                          (p_api_version          => l_api_version,
                           p_init_msg_list        => l_init_msg_list,
                           x_return_status        => l_return_status,
                           x_msg_count            => l_msg_count,
                           x_msg_data             => l_msg_data,
                           p_customer_number      => l_customer_number,
                           p_rcpt_amount          => l_orig_rcpt_tbl (i).amount_applied,
--                           p_receipt_date         => l_receipt_date,
                           p_org_id               => l_org_id,
                           p_currency_code        => l_currency_code,
                           x_appl_tbl             => l_okl_rcpt_tbl
                          );
                     log_debug
                        (   'okl_auto_cash_appl_rules_pvt.handle_combi_pay return status = '
                         || l_return_status
                        );
                     log_debug
                        (   'Number of invoices identified for application purpose = '
                         || l_okl_rcpt_tbl.COUNT
                        );
                    END IF;
                  END IF;

                  IF     l_okl_rcpt_tbl.COUNT = 0
                     --asawanka modified llca start
                     --commenting out l_lockbox_run_already condition as it is no longer required
                     -- AND l_lockbox_run_already = NULL
                     --asawanka modified  for llca end
                     AND l_valid_ar_reference = 'N'
                     AND l_onacc_unapp_exist = 'N' THEN
                     -- still no match, lets apply to customers oldest/newest invoice(s)
                     log_debug ('Search Rules failed.');
                     log_debug ('Trying to use Receipt Mismatch Rules');
                     log_debug
                        ('Calling okl_auto_cash_appl_rules_pvt.receipt_mismatch with parameters: '
                        );
                     log_debug ('p_customer_num = ' || l_customer_number);
                     log_debug ('p_currency_code = ' || l_currency_code);
                     log_debug (   'p_rcpt_amount = '
                                || l_orig_rcpt_tbl (i).amount_applied
                               );
                     log_debug ('p_org_id = ' || l_org_id);
                     --asawanka modified for llca start
                     --changed api call
                     IF l_tmp_currency_code IS NULL OR l_tmp_currency_code = l_currency_code
                     THEN
                        okl_auto_cash_appl_rules_pvt.receipt_mismatch
                          (p_api_version        => l_api_version,
                           p_init_msg_list      => l_init_msg_list,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           p_customer_num       => l_customer_number,
                           p_currency_code      => l_currency_code,
                           p_rcpt_amount        => l_orig_rcpt_tbl (i).amount_applied,
                           p_org_id             => l_org_id,
                           p_receipt_date       => l_receipt_date,
                           x_appl_tbl           => l_okl_rcpt_tbl,
                           x_onacc_amount       => l_onacc_amount
                          );
                     --asawanka modified for llca end
                     log_debug
                        (   'okl_auto_cash_appl_rules_pvt.receipt_mismatch return status = '
                         || l_return_status
                        );
                     log_debug
                        (   'Number of invoices identified for application purpose = '
                         || l_okl_rcpt_tbl.COUNT
                        );

                     IF (l_onacc_amount > 0) THEN
                        l_onacc_unapp_exist := 'Y';
                     ELSE
                        l_onacc_unapp_exist := 'N';
                     END IF;

                     log_debug (   ' On-Account amount exists : '
                                || l_onacc_unapp_exist
                               );
                    END IF;
                  END IF;

                  IF     l_okl_rcpt_tbl.COUNT = 0
                     AND l_customer_number IS NOT NULL
                     AND l_onacc_unapp_exist = 'N' THEN
                     -- nothing found for receipt reference, retain invoice ref...
                     log_debug
                        ('Nothing found for Invoice Reference. Retaining Invoice Refence in interface table.'
                        );
                     l_no_mtch_rcpt_tbl (j).invoice_number :=
                                            l_orig_rcpt_tbl (i).invoice_number;
                     l_no_mtch_rcpt_tbl (j).amount_applied :=
                                            l_orig_rcpt_tbl (i).amount_applied;
                     j := j + 1;

                     -- ...and check for termination quotes
                     IF l_valid_ar_reference = 'N' THEN
                        log_debug
                           ('Checking if invoice reference matches any Approved termination quote number'
                           );

                        OPEN c_get_party_id (l_customer_number);

                        FETCH c_get_party_id
                         INTO l_party_id;

                        CLOSE c_get_party_id;

                        IF l_party_id IS NOT NULL THEN
                           OPEN c_check_termination
                                           (l_party_id,
                                            l_receipt_date,
                                            l_days_past_quote_valid,
                                            l_orig_rcpt_tbl (i).invoice_number
                                           );

                           LOOP
                              FETCH c_check_termination
                               INTO l_quote_id,
                                    l_quote_date_effective_to,
                                    l_quote_number,
                                    l_quote_amount;

                              EXIT WHEN c_check_termination%NOTFOUND;
                              log_debug
                                 ('Invoice Reference matches Termination Quote Number. Checking if amount to appply matches Termination Quote Amount'
                                 );

                              IF l_quote_amount =
                                            l_orig_rcpt_tbl (i).amount_applied THEN
                                 l_qtev_rec.ID := l_quote_id;
                                 l_qtev_rec.payment_received_yn := 'Y';
                                 l_qtev_rec.date_payment_received :=
                                                               l_receipt_date;
                                 l_qtev_rec.date_effective_to :=
                                                    l_quote_date_effective_to;
                                 l_qtev_rec.accepted_yn := 'Y';
                                 l_qtev_rec.preproceeds_yn := 'N';
                                 log_debug
                                    ('Amount matches. Calling api okl_am_termnt_quote_pub.terminate_quote with parameters:'
                                    );
                                 log_debug ('p_term_rec.id = '
                                            || l_qtev_rec.ID
                                           );
                                 log_debug
                                       (   'p_term_rec.payment_received_yn = '
                                        || l_qtev_rec.payment_received_yn
                                       );
                                 log_debug
                                     (   'p_term_rec.date_payment_received = '
                                      || l_qtev_rec.date_payment_received
                                     );
                                 log_debug
                                         (   'p_term_rec.date_effective_to = '
                                          || l_qtev_rec.accepted_yn
                                         );
                                 log_debug (   'p_term_rec.accepted_yn = '
                                            || l_qtev_rec.accepted_yn
                                           );
                                 log_debug (   'p_term_rec.preproceeds_yn = '
                                            || l_qtev_rec.preproceeds_yn
                                           );

                                 IF (is_debug_statement_on) THEN
                                    okl_debug_pub.log_debug
                                       (g_level_statement,
                                        l_module_name,
                                        'before okl_am_termnt_quote_pub.terminate_quote '
                                       );
                                    okl_debug_pub.log_debug
                                                       (g_level_statement,
                                                        l_module_name,
                                                           'l_return_status: '
                                                        || l_return_status
                                                       );
                                 END IF;

                                 okl_am_termnt_quote_pub.terminate_quote
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_term_rec           => l_qtev_rec,
                                           x_term_rec           => x_qtev_rec,
                                           x_err_msg            => l_err_msg
                                          );
                                 log_debug
                                    (   'okl_am_termnt_quote_pub.terminate_quote return status = '
                                     || l_return_status
                                    );

                                 IF (is_debug_statement_on) THEN
                                    okl_debug_pub.log_debug
                                       (g_level_statement,
                                        l_module_name,
                                        'After okl_am_termnt_quote_pub.terminate_quote '
                                       );
                                    okl_debug_pub.log_debug
                                                       (g_level_statement,
                                                        l_module_name,
                                                           'l_return_status: '
                                                        || l_return_status
                                                       );
                                 END IF;

                                 EXIT;
                              END IF;
                           END LOOP;

                           CLOSE c_check_termination;
                        END IF;
                     END IF;
                  ELSIF l_okl_rcpt_tbl.COUNT > 0 THEN
                     -- we found some invoices to apply
                     log_debug
                        ('Invoice Appliactions identified. Processing Further...'
                        );
                     k := l_okl_rcpt_tbl.FIRST;

                     LOOP
                      -- (3) Loop through all new invoice(s)/invoice amount(s)
                        l_hdr_idx := k;
                        l_amt1_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP 1');
                        l_amt_from1_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP FROM 1');
                        l_new_invoice1 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                        l_new_amount_applied1 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                           * POWER (10, l_amt1_prec);
                        l_new_amount_applied_from1 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                           * POWER (10, l_amt_from1_prec);
                        l_new_currency_code1 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                        l_new_trans_to_rct_rate1 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                        k := k + 1;
                        l_amt2_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP 2');
                        l_amt_from2_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP FROM 2');
                        l_new_invoice2 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                        l_new_amount_applied2 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                           * POWER (10, l_amt2_prec);
                        l_new_amount_applied_from2 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                           * POWER (10, l_amt_from2_prec);
                        l_new_currency_code2 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                        l_new_trans_to_rct_rate2 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                        k := k + 1;
                        l_amt3_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP 3');
                        l_amt_from3_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP FROM 3');
                        l_new_invoice3 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                        l_new_amount_applied3 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                           * POWER (10, l_amt3_prec);
                        l_new_amount_applied_from3 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                           * POWER (10, l_amt_from3_prec);
                        l_new_currency_code3 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                        l_new_trans_to_rct_rate3 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                        k := k + 1;
                        l_amt4_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP 4');
                        l_amt_from4_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP FROM 4');
                        l_new_invoice4 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                        l_new_amount_applied4 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                           * POWER (10, l_amt4_prec);
                        l_new_amount_applied_from4 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                           * POWER (10, l_amt_from4_prec);
                        l_new_currency_code4 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                        l_new_trans_to_rct_rate4 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                        k := k + 1;
                        l_amt5_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP 5');
                        l_amt_from5_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP FROM 5');
                        l_new_invoice5 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                        l_new_amount_applied5 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                           * POWER (10, l_amt5_prec);
                        l_new_amount_applied_from5 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                           * POWER (10, l_amt_from5_prec);
                        l_new_currency_code5 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                        l_new_trans_to_rct_rate5 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                        k := k + 1;
                        l_amt6_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP 6');
                        l_amt_from6_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP FROM 6');
                        l_new_invoice6 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                        l_new_amount_applied6 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                           * POWER (10, l_amt6_prec);
                        l_new_amount_applied_from6 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                           * POWER (10, l_amt_from6_prec);
                        l_new_currency_code6 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                        l_new_trans_to_rct_rate6 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                        k := k + 1;
                        l_amt7_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP 7');
                        l_amt_from7_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP FROM 7');
                        l_new_invoice7 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                        l_new_amount_applied7 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                           * POWER (10, l_amt7_prec);
                        l_new_amount_applied_from7 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                           * POWER (10, l_amt_from7_prec);
                        l_new_currency_code7 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                        l_new_trans_to_rct_rate7 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                        k := k + 1;
                        l_amt8_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP 8');
                        l_amt_from8_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'PAYMENT','AMT APP FROM 8');
                        l_new_invoice8 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                        l_new_amount_applied8 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                           * POWER (10, l_amt8_prec);
                        l_new_amount_applied_from8 :=
                             l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                           * POWER (10, l_amt_from8_prec);
                        l_new_currency_code8 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                        l_new_trans_to_rct_rate8 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                        SELECT ar_payments_interface_s.NEXTVAL
                          INTO l_transmission_rec_id_of
                          FROM DUAL;

                        log_debug
                           ('Inserting overflow record with application information for the current payment record'
                           );
                        log_debug
                           (   'Transmission Record Id of new overflow record = '
                            || l_transmission_rec_id_of
                           );

                        INSERT INTO ar_payments_interface_all
                                    (transmission_record_id,
                                     item_number,
                                     record_type,
                                     status,
                                     transmission_id,
                                     transmission_request_id,
                                     lockbox_number,
                                     batch_name,
                                     invoice1,
                                     amount_applied1,
                                     amount_applied_from1,
                                     invoice_currency_code1,
                                     trans_to_receipt_rate1,
                                     invoice2,
                                     amount_applied2,
                                     amount_applied_from2,
                                     invoice_currency_code2,
                                     trans_to_receipt_rate2,
                                     invoice3,
                                     amount_applied3,
                                     amount_applied_from3,
                                     invoice_currency_code3,
                                     trans_to_receipt_rate3,
                                     invoice4,
                                     amount_applied4,
                                     amount_applied_from4,
                                     invoice_currency_code4,
                                     trans_to_receipt_rate4,
                                     invoice5,
                                     amount_applied5,
                                     amount_applied_from5,
                                     invoice_currency_code5,
                                     trans_to_receipt_rate5,
                                     invoice6,
                                     amount_applied6,
                                     amount_applied_from6,
                                     invoice_currency_code6,
                                     trans_to_receipt_rate6,
                                     invoice7,
                                     amount_applied7,
                                     amount_applied_from7,
                                     invoice_currency_code7,
                                     trans_to_receipt_rate7,
                                     invoice8,
                                     amount_applied8,
                                     amount_applied_from8,
                                     invoice_currency_code8,
                                     trans_to_receipt_rate8,
                                     org_id,
                                     creation_date,
                                     last_update_date
                                    )
                             VALUES (l_transmission_rec_id_of,
                                     l_item_number,
                                     l_overflow,
                                     l_status,
                                     l_transmission_id,
                                     l_trans_req_id,
                                     l_lockbox_number,
                                     l_batch_name,
                                     l_new_invoice1,
                                     l_new_amount_applied1,
                                     l_new_amount_applied_from1,
                                     l_new_currency_code1,
                                     l_new_trans_to_rct_rate1,
                                     l_new_invoice2,
                                     l_new_amount_applied2,
                                     l_new_amount_applied_from2,
                                     l_new_currency_code2,
                                     l_new_trans_to_rct_rate2,
                                     l_new_invoice3,
                                     l_new_amount_applied3,
                                     l_new_amount_applied_from3,
                                     l_new_currency_code3,
                                     l_new_trans_to_rct_rate3,
                                     l_new_invoice4,
                                     l_new_amount_applied4,
                                     l_new_amount_applied_from4,
                                     l_new_currency_code4,
                                     l_new_trans_to_rct_rate4,
                                     l_new_invoice5,
                                     l_new_amount_applied5,
                                     l_new_amount_applied_from5,
                                     l_new_currency_code5,
                                     l_new_trans_to_rct_rate5,
                                     l_new_invoice6,
                                     l_new_amount_applied6,
                                     l_new_amount_applied_from6,
                                     l_new_currency_code6,
                                     l_new_trans_to_rct_rate6,
                                     l_new_invoice7,
                                     l_new_amount_applied7,
                                     l_new_amount_applied_from7,
                                     l_new_currency_code7,
                                     l_new_trans_to_rct_rate7,
                                     l_new_invoice8,
                                     l_new_amount_applied8,
                                     l_new_amount_applied_from8,
                                     l_new_currency_code8,
                                     l_new_trans_to_rct_rate8,
                                     l_org_id,
                                     SYSDATE,
                                     TRUNC (SYSDATE)
                                    );

                        /*************************************************************************************
                          insert line level details in AR  table here
                        *************************************************************************************/
                        log_debug
                           ('Processing line level application data for currently inserted overflow record'
                           );

                        FOR l_inv_indx IN l_hdr_idx .. k
                        LOOP
                           IF l_okl_rcpt_tbl (l_inv_indx).inv_hdr_rec.invoice_number IS NOT NULL THEN
                              l_linelevel_app :=
                                 get_line_level_app
                                    (l_okl_rcpt_tbl (l_inv_indx).inv_hdr_rec.invoice_id,
                                     l_org_id
                                    );

                              IF l_linelevel_app = 'Y' THEN
                                 /*  -- first, delete any existing line level application data
                                   DELETE AR_PMTS_INTERFACE_LINE_DETAILS
                                   WHERE transmission_req_id = l_trans_req_id
                                   AND  transmission_record_id  = l_transmission_record_id
                                   AND  invoice_number = l_okl_rcpt_tbl(l_inv_indx).inv_hdr_rec.invoice_number;*/-- now create line level application data
                                 IF l_okl_rcpt_tbl (l_inv_indx).inv_lines_tbl.COUNT >
                                                                            0 THEN
                                    log_debug
                                       (   'Inserting line level application data for Invoice Number = '
                                        || l_okl_rcpt_tbl (l_inv_indx).inv_hdr_rec.invoice_number
                                       );

                                    FOR l_line_indx IN
                                       l_okl_rcpt_tbl (l_inv_indx).inv_lines_tbl.FIRST .. l_okl_rcpt_tbl
                                                                                            (l_inv_indx
                                                                                            ).inv_lines_tbl.LAST
                                    LOOP
                                       --START: Fixed as part of bug 6780241 by nikshah
                                       if (l_currency_code = l_okl_rcpt_tbl(l_inv_indx).inv_hdr_rec.invoice_currency_code) then
                                         l_amount_in_inv_curr :=l_okl_rcpt_tbl(l_inv_indx).inv_lines_tbl(l_line_indx).amount_applied;
                                         l_amount_in_rct_curr := null;
                                       else
                                         l_amount_in_inv_curr := null;
                                         l_amount_in_rct_curr := l_okl_rcpt_tbl(l_inv_indx).inv_lines_tbl(l_line_indx).amount_applied;
                                       end if;

                                       INSERT INTO ar_pmts_interface_line_details
                                                   (status,
                                                    transmission_request_id,
                                                    transmission_record_id,
                                                    invoice_number,
                                                    apply_to,
                                                    allocated_receipt_amount,
                                                    amount_applied
                                                   )
                                            VALUES ('AR_PLB_NEW_RECORD',
                                                    l_trans_req_id,
                                                    l_transmission_rec_id_of,
                                                    l_okl_rcpt_tbl (l_inv_indx).inv_hdr_rec.invoice_number,
                                                    l_okl_rcpt_tbl (l_inv_indx).inv_lines_tbl
                                                                  (l_line_indx).invoice_line_number,
                                                    l_amount_in_inv_curr,
                                                    l_amount_in_rct_curr
                                                   );
                                       --END: Fixed as part of bug 6780241 by nikshah
                                    END LOOP;
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;

                        EXIT WHEN k = (l_okl_rcpt_tbl.LAST);
                                 -- records should always be in mutiples of 8.
                        k := k + 1;
                     --                                      k := k + 1;
                     --                      EXIT WHEN k = (l_okl_rcpt_tbl.LAST + 1);                -- records should always be in mutiples of 8.
                     END LOOP;
               -- (3) end looping through all new invoice(s)/invoice amount(s)
                  ELSE
                     log_debug
                        ('Invoice Reference matches valid non okl AR Invoice Number. Skipping the invoice reference'
                        );
                  END IF;
               ELSE
                  --lock box run already so retain the invoice reference
                  log_debug
                     ('Line Level data already exists for this invoice reference. Skipping the invoice reference'
                     );
                  l_prec_to_use := 0;
                  l_prec_to_use_from := 0;

                  IF i = 1 THEN
                     l_prec_to_use := l_amt1_prec;
                     l_prec_to_use_from := l_amt_from1_prec;
                  ELSIF i = 2 THEN
                     l_prec_to_use := l_amt2_prec;
                     l_prec_to_use_from := l_amt_from2_prec;
                  ELSIF i = 3 THEN
                     l_prec_to_use := l_amt3_prec;
                     l_prec_to_use_from := l_amt_from3_prec;
                  ELSIF i = 4 THEN
                     l_prec_to_use := l_amt4_prec;
                     l_prec_to_use_from := l_amt_from4_prec;
                  ELSIF i = 5 THEN
                     l_prec_to_use := l_amt5_prec;
                     l_prec_to_use_from := l_amt_from5_prec;
                  ELSIF i = 6 THEN
                     l_prec_to_use := l_amt6_prec;
                     l_prec_to_use_from := l_amt_from6_prec;
                  ELSIF i = 7 THEN
                     l_prec_to_use := l_amt7_prec;
                     l_prec_to_use_from := l_amt_from7_prec;
                  ELSIF i = 8 THEN
                     l_prec_to_use := l_amt8_prec;
                     l_prec_to_use_from := l_amt_from8_prec;
                  END IF;

                  l_no_mtch_rcpt_tbl (j).invoice_number :=
                                            l_orig_rcpt_tbl (i).invoice_number;
                  l_no_mtch_rcpt_tbl (j).amount_applied :=
                       l_orig_rcpt_tbl (i).amount_applied
                     * POWER (10, l_prec_to_use);
                  l_no_mtch_rcpt_tbl(j).amount_applied_from := l_orig_rcpt_tbl(i).amount_applied_from * power(10,l_prec_to_use_from);
                  l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate :=  l_orig_rcpt_tbl(i).trans_to_receipt_rate;
                  j := j + 1;
               END IF;                                 -- lock box run already

               EXIT WHEN i = 8;
      -- move to next payment record if all 8 invoice references are processed
               i := i + 1;
                      -- move to next invoice reference in this payment record
            ELSE                                 -- no invoice reference found
               IF     l_orig_rcpt_tbl (i).invoice_number IS NOT NULL
                  AND l_orig_rcpt_tbl (i).amount_applied IS NOT NULL THEN
                  log_debug
                     ('Invoice Reference exists but amount to apply is zero after considering precision. Keeping Invoice reference.'
                     );
                  l_prec_to_use := 0;
                  l_prec_to_use_from := 0;

                  IF i = 1 THEN
                     l_prec_to_use := l_amt1_prec;
                     l_prec_to_use_from := l_amt_from1_prec;
                  ELSIF i = 2 THEN
                     l_prec_to_use := l_amt2_prec;
                     l_prec_to_use_from := l_amt_from2_prec;
                  ELSIF i = 3 THEN
                     l_prec_to_use := l_amt3_prec;
                     l_prec_to_use_from := l_amt_from3_prec;
                  ELSIF i = 4 THEN
                     l_prec_to_use := l_amt4_prec;
                     l_prec_to_use_from := l_amt_from4_prec;
                  ELSIF i = 5 THEN
                     l_prec_to_use := l_amt5_prec;
                     l_prec_to_use_from := l_amt_from5_prec;
                  ELSIF i = 6 THEN
                     l_prec_to_use := l_amt6_prec;
                     l_prec_to_use_from := l_amt_from6_prec;
                  ELSIF i = 7 THEN
                     l_prec_to_use := l_amt7_prec;
                     l_prec_to_use_from := l_amt_from7_prec;
                  ELSIF i = 8 THEN
                     l_prec_to_use := l_amt8_prec;
                     l_prec_to_use_from := l_amt_from8_prec;
                  END IF;

                  l_no_mtch_rcpt_tbl (j).invoice_number :=
                                            l_orig_rcpt_tbl (i).invoice_number;
                  l_no_mtch_rcpt_tbl (j).amount_applied :=
                       l_orig_rcpt_tbl (i).amount_applied
                     * POWER (10, l_prec_to_use);
                  l_no_mtch_rcpt_tbl(j).amount_applied_from := l_orig_rcpt_tbl(i).amount_applied_from * power(10,l_prec_to_use_from);
                  l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate :=  l_orig_rcpt_tbl(i).trans_to_receipt_rate;
                  j := j + 1;
               END IF;

               EXIT WHEN i = 8;
      -- move to next payment record if all 8 invoice references are processed
               i := i + 1;
                      -- move to next invoice reference in this payment record
            END IF;
         END LOOP;
-- (2) -- end processing payment record. use context of payment rec to process ovrflw rec.

         log_debug ('All invoice references in payment record processed. ');
         log_debug
            ('Nulling out invoice references which were matched successfully and retaining those which did not match at all'
            );
         j := 1;

         -- need to keep references that returned nothing and
         -- need to null out invoice references for which we found match
         UPDATE ar_payments_interface_all
            SET invoice1 = l_no_mtch_rcpt_tbl (j).invoice_number,
                amount_applied1 = l_no_mtch_rcpt_tbl (j).amount_applied,
                resolved_matching_number1 =
                                         l_no_mtch_rcpt_tbl (j).invoice_number,
                amount_applied_from1 = l_no_mtch_rcpt_tbl(j).amount_applied_from,
                trans_to_receipt_rate1 = l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate,
                invoice2 = l_no_mtch_rcpt_tbl (j + 1).invoice_number,
                amount_applied2 = l_no_mtch_rcpt_tbl (j + 1).amount_applied,
                resolved_matching_number2 =
                                     l_no_mtch_rcpt_tbl (j + 1).invoice_number,
                amount_applied_from2 = l_no_mtch_rcpt_tbl(j + 1).amount_applied_from,
                trans_to_receipt_rate2 = l_no_mtch_rcpt_tbl(j + 1).trans_to_receipt_rate,
                invoice3 = l_no_mtch_rcpt_tbl (j + 2).invoice_number,
                amount_applied3 = l_no_mtch_rcpt_tbl (j + 2).amount_applied,
                resolved_matching_number3 =
                                     l_no_mtch_rcpt_tbl (j + 2).invoice_number,
                amount_applied_from3 = l_no_mtch_rcpt_tbl(j + 2).amount_applied_from,
                trans_to_receipt_rate3 = l_no_mtch_rcpt_tbl(j + 2).trans_to_receipt_rate,
                invoice4 = l_no_mtch_rcpt_tbl (j + 3).invoice_number,
                amount_applied4 = l_no_mtch_rcpt_tbl (j + 3).amount_applied,
                resolved_matching_number4 =
                                     l_no_mtch_rcpt_tbl (j + 3).invoice_number,
                amount_applied_from4 = l_no_mtch_rcpt_tbl(j + 3).amount_applied_from,
                trans_to_receipt_rate4 = l_no_mtch_rcpt_tbl(j + 3).trans_to_receipt_rate,
                invoice5 = l_no_mtch_rcpt_tbl (j + 4).invoice_number,
                amount_applied5 = l_no_mtch_rcpt_tbl (j + 4).amount_applied,
                resolved_matching_number5 =
                                     l_no_mtch_rcpt_tbl (j + 4).invoice_number,
                amount_applied_from5 = l_no_mtch_rcpt_tbl(j + 4).amount_applied_from,
                trans_to_receipt_rate5 = l_no_mtch_rcpt_tbl(j + 4).trans_to_receipt_rate,
                invoice6 = l_no_mtch_rcpt_tbl (j + 5).invoice_number,
                amount_applied6 = l_no_mtch_rcpt_tbl (j + 5).amount_applied,
                resolved_matching_number6 =
                                     l_no_mtch_rcpt_tbl (j + 5).invoice_number,
                amount_applied_from6 = l_no_mtch_rcpt_tbl(j + 5).amount_applied_from,
                trans_to_receipt_rate6 = l_no_mtch_rcpt_tbl(j + 5).trans_to_receipt_rate,
                invoice7 = l_no_mtch_rcpt_tbl (j + 6).invoice_number,
                amount_applied7 = l_no_mtch_rcpt_tbl (j + 6).amount_applied,
                resolved_matching_number7 =
                                     l_no_mtch_rcpt_tbl (j + 6).invoice_number,
                amount_applied_from7 = l_no_mtch_rcpt_tbl(j + 6).amount_applied_from,
                trans_to_receipt_rate7 = l_no_mtch_rcpt_tbl(j + 6).trans_to_receipt_rate,
                invoice8 = l_no_mtch_rcpt_tbl (j + 7).invoice_number,
                amount_applied8 = l_no_mtch_rcpt_tbl (j + 7).amount_applied,
                resolved_matching_number8 =
                                     l_no_mtch_rcpt_tbl (j + 7).invoice_number,
                amount_applied_from8 = l_no_mtch_rcpt_tbl(j + 7).amount_applied_from,
                trans_to_receipt_rate8 = l_no_mtch_rcpt_tbl(j + 7).trans_to_receipt_rate
          WHERE transmission_record_id = l_transmission_record_id;

         -- now retrieve all overflow records for
         -- payment in question.
         log_debug
             ('Processing all overflow records for the current payment record');
         OPEN c_get_ovrflw_recs (l_trans_req_id,
                                 l_overflow,
                                 l_item_number,
                                 l_batch_name
                                );

         LOOP                        -- (2)         loop through overflow recs
            FETCH c_get_ovrflw_recs
             INTO l_transmission_record_id,
                  -- l_currency_code, -- use currency from payment record. currency in overflow record may not be present
                  l_invoice1,
                  l_invoice2,
                  l_invoice3,
                  l_invoice4,
                  l_invoice5,
                  l_invoice6,
                  l_invoice7,
                  l_invoice8,
                  l_amount_applied1,
                  l_amount_applied2,
                  l_amount_applied3,
                  l_amount_applied4,
                  l_amount_applied5,
                  l_amount_applied6,
                  l_amount_applied7,
                  l_amount_applied8,
                  l_amount_app_from1,
                  l_amount_app_from2,
                  l_amount_app_from3,
                  l_amount_app_from4,
                  l_amount_app_from5,
                  l_amount_app_from6,
                  l_amount_app_from7,
                  l_amount_app_from8,
                  l_trans_to_receipt_rate1,
                  l_trans_to_receipt_rate2,
                  l_trans_to_receipt_rate3,
                  l_trans_to_receipt_rate4,
                  l_trans_to_receipt_rate5,
                  l_trans_to_receipt_rate6,
                  l_trans_to_receipt_rate7,
                  l_trans_to_receipt_rate8,
				  l_currency_code1,
				  l_currency_code2,
				  l_currency_code3,
				  l_currency_code4,
				  l_currency_code5,
				  l_currency_code6,
				  l_currency_code7,
				  l_currency_code8;

            EXIT WHEN c_get_ovrflw_recs%NOTFOUND;
            log_debug ('Fetching precisions for amount columns');
            --asawanka modified for llca start
            -- fetch format precision for amounts in interface table for the receipt currency

            l_amt1_prec := get_precision (NVL(l_currency_code1,l_currency_code),p_trans_req_id,'OVRFLW PAYMENT','AMT APP 1');
            l_amt2_prec := get_precision (NVL(l_currency_code2,l_currency_code),p_trans_req_id,'OVRFLW PAYMENT','AMT APP 2');
            l_amt3_prec := get_precision (NVL(l_currency_code3,l_currency_code),p_trans_req_id,'OVRFLW PAYMENT','AMT APP 3');
            l_amt4_prec := get_precision (NVL(l_currency_code4,l_currency_code),p_trans_req_id,'OVRFLW PAYMENT','AMT APP 4');
            l_amt5_prec := get_precision (NVL(l_currency_code5,l_currency_code),p_trans_req_id,'OVRFLW PAYMENT','AMT APP 5');
            l_amt6_prec := get_precision (NVL(l_currency_code6,l_currency_code),p_trans_req_id,'OVRFLW PAYMENT','AMT APP 6');
            l_amt7_prec := get_precision (NVL(l_currency_code7,l_currency_code),p_trans_req_id,'OVRFLW PAYMENT','AMT APP 7');
            l_amt8_prec := get_precision (NVL(l_currency_code8,l_currency_code),p_trans_req_id,'OVRFLW PAYMENT','AMT APP 8');

            --asawanka modified for llca end

            -- process overflow record invoice(s)
            -- new overflow record(s) for each payment record invoice reference
            -- update payment record once and for all.
            i := 1;
            j := 1;
            -- initialize all pl/sql tables used by this process
            l_orig_rcpt_tbl := l_initialize_table;
            l_no_mtch_rcpt_tbl := l_initialize_table;
            l_okl_rcpt_tbl := l_okl_init_tbl;

            l_orig_rcpt_tbl (i).invoice_number := l_invoice1;
            l_orig_rcpt_tbl (i).amount_applied :=
               ROUND (l_amount_applied1 / POWER (10, l_amt1_prec),
                      l_amt1_prec);
            l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from1/power(10,l_amt_from1_prec),l_amt_from1_prec);
            l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate1;
            l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
            l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
            l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
            l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

            i := i + 1;
            j := j + 1;
            l_orig_rcpt_tbl (i).invoice_number := l_invoice2;
            l_orig_rcpt_tbl (i).amount_applied :=
               ROUND (l_amount_applied2 / POWER (10, l_amt2_prec),
                      l_amt2_prec);
            l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from2/power(10,l_amt_from2_prec),l_amt_from2_prec);
            l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate2;
            l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
            l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
            l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
            l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

            i := i + 1;
            j := j + 1;
            l_orig_rcpt_tbl (i).invoice_number := l_invoice3;
            l_orig_rcpt_tbl (i).amount_applied :=
               ROUND (l_amount_applied3 / POWER (10, l_amt3_prec),
                      l_amt3_prec);
            l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from3/power(10,l_amt_from3_prec),l_amt_from3_prec);
            l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate3;
            l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
            l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
            l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
            l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

            i := i + 1;
            j := j + 1;
            l_orig_rcpt_tbl (i).invoice_number := l_invoice4;
            l_orig_rcpt_tbl (i).amount_applied :=
               ROUND (l_amount_applied4 / POWER (10, l_amt4_prec),
                      l_amt4_prec);
            l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from4/power(10,l_amt_from4_prec),l_amt_from4_prec);
            l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate4;
            l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
            l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
            l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
            l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

            i := i + 1;
            j := j + 1;
            l_orig_rcpt_tbl (i).invoice_number := l_invoice5;
            l_orig_rcpt_tbl (i).amount_applied :=
               ROUND (l_amount_applied5 / POWER (10, l_amt5_prec),
                      l_amt5_prec);
            l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from5/power(10,l_amt_from5_prec),l_amt_from5_prec);
            l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate5;
            l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
            l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
            l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
            l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

            i := i + 1;
            j := j + 1;
            l_orig_rcpt_tbl (i).invoice_number := l_invoice6;
            l_orig_rcpt_tbl (i).amount_applied :=
               ROUND (l_amount_applied6 / POWER (10, l_amt6_prec),
                      l_amt6_prec);
            l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from6/power(10,l_amt_from6_prec),l_amt_from6_prec);
            l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate6;
            l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
            l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
            l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
            l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

            i := i + 1;
            j := j + 1;
            l_orig_rcpt_tbl (i).invoice_number := l_invoice7;
            l_orig_rcpt_tbl (i).amount_applied :=
               ROUND (l_amount_applied7 / POWER (10, l_amt7_prec),
                      l_amt7_prec);
            l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from7/power(10,l_amt_from7_prec),l_amt_from7_prec);
            l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate7;
            l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
            l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
            l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
            l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

            i := i + 1;
            j := j + 1;
            l_orig_rcpt_tbl (i).invoice_number := l_invoice8;
            l_orig_rcpt_tbl (i).amount_applied :=
               ROUND (l_amount_applied8 / POWER (10, l_amt8_prec),
                      l_amt8_prec);
            l_orig_rcpt_tbl(i).amount_applied_from := round(l_amount_app_from8/power(10,l_amt_from8_prec),l_amt_from8_prec);
            l_orig_rcpt_tbl(i).trans_to_receipt_rate := l_trans_to_receipt_rate8;
            l_no_mtch_rcpt_tbl (j).invoice_number := NULL;
            l_no_mtch_rcpt_tbl (j).amount_applied := NULL;
            l_no_mtch_rcpt_tbl(j).amount_applied_from := NULL;
            l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate := NULL;

            i := 1;
            j := 1;
            log_debug
               (   'Processing invoice references in this overflow record. Transmission record id = '
                || l_transmission_record_id
               );

            LOOP
            -- (3) Loop through all overflow record invoice/payment references
               l_okl_rcpt_tbl := l_okl_init_tbl;

  			   select decode(i,1,l_amount_applied1,2,l_amount_applied2,
      				         3, l_amount_applied3,4,l_amount_applied4,
   					         5,l_amount_applied5,6,l_amount_applied6,
							 7,l_amount_applied7,8,l_amount_applied8),
  					  decode(i,1,l_amount_app_from1,2,l_amount_app_from2,
					         3, l_amount_app_from3,4,l_amount_app_from4,
					         5,l_amount_app_from5,6,l_amount_app_from6,
							 7,l_amount_app_from7,8,l_amount_app_from8),
  				      decode(i,1,l_currency_code1,2,l_currency_code2,
					         3,l_currency_code3,4,l_currency_code4,
					         5,l_currency_code5,6,l_currency_code6,
						     7,l_currency_code7,8,l_currency_code8)
               into l_tmp_amount_applied, l_tmp_amount_app_from, l_tmp_currency_code
               from dual;

               IF     l_orig_rcpt_tbl (i).invoice_number IS NOT NULL
                  AND ( l_tmp_amount_applied IS NOT NULL OR l_tmp_amount_app_from IS NOT NULL)
                  AND  ( l_tmp_amount_applied <> 0 OR l_tmp_amount_app_from <> 0 ) THEN
                  log_debug (   'Invoice Reference = '
                             || l_orig_rcpt_tbl (i).invoice_number
                            );
                  log_debug (   'Amount to apply = '
                             || l_tmp_amount_applied
                            );
                  log_debug (   'Amount to apply from = '
                             || l_tmp_amount_app_from
                            );
                  log_debug (   'Trans to receipt rate = '
                             || l_orig_rcpt_tbl (i).trans_to_receipt_rate
                            );

-- invoke okl standard cash application rules
----------------------------------------------------------------------
-- check to see if given invoice reference maps to a valid non okl ar invoice.
-- if so then this reference should be left in lockbox ...
-- bug ref: 3068497
                  IF valid_ar_reference (l_orig_rcpt_tbl (i).invoice_number,
                                         l_org_id
                                        ) THEN
                     l_valid_ar_reference := 'Y';
                  ELSE
                     l_valid_ar_reference := 'N';
                  END IF;

----------------------------------------------------------------------
            --asawanka modified for llca start
            --  check if line level data exists for this inv ref
                  l_lockbox_run_already := 'N';

                  OPEN c_lckbx_status (l_trans_req_id,
                                       l_transmission_record_id,
                                       l_orig_rcpt_tbl (i).invoice_number
                                      );

                  FETCH c_lckbx_status
                   INTO l_lockbox_run_already;

                  CLOSE c_lckbx_status;

                  -- Start of wraper code generated automatically by Debug code generator for okl_auto_cash_appl_rules_pvt.auto_cash_app
                  IF (l_debug_enabled = 'Y') THEN
                     l_level_statement := fnd_log.level_procedure;
                     is_debug_statement_on :=
                        okl_debug_pub.check_log_on (l_module,
                                                    l_level_statement
                                                   );
                  END IF;

                  --asawanka modified for llca start
                  -- if line level data already exists for this invoice then do not do any processing for this invoice
                  IF l_lockbox_run_already = 'N' THEN
                     log_debug
                        ('No line level data for invoice reference. Further processing invoice reference'
                        );

                     --asawanka modified for llca start
                     --changed api calls.
                     IF l_valid_ar_reference = 'N' THEN
                        log_debug
                           ('Invoice reference is not valid non OKL AR invoice Number.'
                           );
                        log_debug
                           ('Trying to match Invocie Reference to OKL related AR invoice. ( Post R12 OKL Invoice)'
                           );
                        log_debug
                           ('Calling okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv with parameters: '
                           );
                        log_debug ('p_customer_num = ' || l_customer_number);
                        log_debug (   'p_arinv_number = '
                                   || l_orig_rcpt_tbl (i).invoice_number
                                  );
                        log_debug ('p_currency_code = ' || l_currency_code);
                        log_debug (   'amount applied = '
                                   || l_orig_rcpt_tbl (i).amount_applied
                                  );
                        log_debug (   'amount applied from = '
                                   || l_orig_rcpt_tbl (i).amount_applied_from
                                  );
                        log_debug (   'trans to receipt rate = '
                                   || l_orig_rcpt_tbl (i).trans_to_receipt_rate
                                  );
                        log_debug ('p_org_id = ' || l_org_id);

                        IF is_valid_reference('INVOICE',
						                      l_orig_rcpt_tbl (i).invoice_number,
                                              l_currency_code1,
                                              l_trans_req_id,
                                              l_org_id,
                                              i,
                                              'OVRFLW PAYMENT',
                                              'AMT APP',
                                              'AMT APP FROM',
                                              l_customer_number,
                                              l_tmp_amount_applied,
                                              l_tmp_amount_app_from,
                                              l_returned_curr_code,
                                              l_returned_amount_to,
                                              l_returned_amount_from,
                                              l_returned_precision_to,
			       						      l_returned_precision_from)
   					     THEN
                           l_orig_rcpt_tbl (i).amount_applied := l_returned_amount_to;
                           l_orig_rcpt_tbl (i).amount_applied_from := l_returned_amount_from;
                           log_debug('p_amount_app_to = '|| l_orig_rcpt_tbl(i).amount_applied);
                           log_debug('p_amount_app_from = '|| l_orig_rcpt_tbl(i).amount_applied_from);
                           log_debug('invoice currency = '|| l_returned_curr_code);
                           --Check if reference number matches any okl related AR invoices(Post R12 okl invoices)
                           okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv
                              (p_api_version         => l_api_version,
                               p_init_msg_list       => l_init_msg_list,
                               x_return_status       => l_return_status,
                               x_msg_count           => l_msg_count,
                               x_msg_data            => l_msg_data,
                               -- changed for bug 5391874
                               -- p_customer_num        => l_customer_number,
                               p_customer_num        => null,
                               p_arinv_number        => l_orig_rcpt_tbl (i).invoice_number,
                               p_currency_code       => l_currency_code,
   --                            p_rcpt_amount         => l_orig_rcpt_tbl (i).amount_applied,
                               p_amount_app_to   => l_orig_rcpt_tbl(i).amount_applied,
                               p_amount_app_from   => l_orig_rcpt_tbl(i).amount_applied_from,
                               p_inv_to_rct_rate   => l_orig_rcpt_tbl(i).trans_to_receipt_rate,
                               p_receipt_date   => l_receipt_date,
                               p_org_id              => l_org_id,
                               x_appl_tbl            => l_okl_rcpt_tbl,
                               x_onacc_amount        => l_onacc_amount,
                               x_unapply_amount      => l_unapply_amount
                              );
                           log_debug
                              (   'okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv return status = '
                               || l_return_status
                              );
                           log_debug
                              (   'Number of invoices identified for application purpose = '
                               || l_okl_rcpt_tbl.COUNT
                              );

                           IF (l_onacc_amount > 0) OR (l_unapply_amount > 0) THEN
                              l_onacc_unapp_exist := 'Y';
                           ELSE
                              l_onacc_unapp_exist := 'N';
                           END IF;

                           log_debug
                                   (   ' On-Account / Unapplied amount exists : '
                                 || l_onacc_unapp_exist
                                );
                       END IF;
                     END IF;

                     IF     l_okl_rcpt_tbl.COUNT = 0
                        AND l_valid_ar_reference = 'N'
                        AND l_onacc_unapp_exist = 'N' THEN
                        log_debug
                           ('Invoice Reference did not match to any OKL relate AR Invoice Number'
                           );
                        log_debug
                           ('Trying to match Invocie Reference to OKL Consolidated invoice. ( Pre R12 OKL Invoice)'
                           );
                        log_debug
                           ('Calling okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv with parameters: '
                           );
                        log_debug ('p_customer_num = ' || l_customer_number);
                        log_debug (   'p_cons_inv = '
                                   || l_orig_rcpt_tbl (i).invoice_number
                                  );
                        log_debug ('p_currency_code = ' || l_currency_code);
                        log_debug (   'amount applied = '
                                   || l_orig_rcpt_tbl (i).amount_applied
                                  );
                        log_debug (   'amount applied from = '
                                   || l_orig_rcpt_tbl (i).amount_applied_from
                                  );
                        log_debug (   'trans to receipt rate = '
                                   || l_orig_rcpt_tbl (i).trans_to_receipt_rate
                                  );
                        log_debug ('p_org_id = ' || l_org_id);
                        IF is_valid_reference('CONS-INVOICE',
						                      l_orig_rcpt_tbl (i).invoice_number,
                                              l_currency_code1,
                                              l_trans_req_id,
                                              l_org_id,
                                              i,
                                              'OVRFLW PAYMENT',
                                              'AMT APP',
                                              'AMT APP FROM',
                                              l_customer_number,
                                              l_tmp_amount_applied,
                                              l_tmp_amount_app_from,
                                              l_returned_curr_code,
                                              l_returned_amount_to,
                                              l_returned_amount_from,
                                              l_returned_precision_to,
			       						      l_returned_precision_from)
   					     THEN
                           l_orig_rcpt_tbl (i).amount_applied := l_returned_amount_to;
                           l_orig_rcpt_tbl (i).amount_applied_from := l_returned_amount_from;
                           log_debug('p_amount_app_to = '|| l_orig_rcpt_tbl(i).amount_applied);
                           log_debug('p_amount_app_from = '|| l_orig_rcpt_tbl(i).amount_applied_from);
                           log_debug('invoice currency = '|| l_returned_curr_code);
                        --Check if reference number matches any okl consolidated invoices (PRE R12 okl invoices)
                        okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv
                           (p_api_version         => l_api_version,
                            p_init_msg_list       => l_init_msg_list,
                            x_return_status       => l_return_status,
                            x_msg_count           => l_msg_count,
                            x_msg_data            => l_msg_data,
                            -- changed for bug 5391874
                            -- p_customer_num        => l_customer_number,
                            p_customer_num        => null,
                            p_cons_inv            => l_orig_rcpt_tbl (i).invoice_number,
                            p_currency_code       => l_currency_code,
--                            p_rcpt_amount         => l_orig_rcpt_tbl (i).amount_applied,
                          p_amount_app_to   => l_orig_rcpt_tbl(i).amount_applied,
                          p_amount_app_from   => l_orig_rcpt_tbl(i).amount_applied_from,
                          p_inv_to_rct_rate   => l_orig_rcpt_tbl(i).trans_to_receipt_rate,
                          p_receipt_date   => l_receipt_date,
                            p_org_id              => l_org_id,
                            x_appl_tbl            => l_okl_rcpt_tbl,
                            x_onacc_amount        => l_onacc_amount,
                            x_unapply_amount      => l_unapply_amount
                           );
                        log_debug
                           (   'okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv return status = '
                            || l_return_status
                           );
                        log_debug
                           (   'Number of invoices identified for application purpose = '
                            || l_okl_rcpt_tbl.COUNT
                           );

                        IF (l_onacc_amount > 0) OR (l_unapply_amount > 0) THEN
                           l_onacc_unapp_exist := 'Y';
                        ELSE
                           l_onacc_unapp_exist := 'N';
                        END IF;

                        log_debug
                                (   ' On-Account / Unapplied amount exists : '
                                 || l_onacc_unapp_exist
                                );
                       END IF;
                     END IF;

                     IF     l_okl_rcpt_tbl.COUNT = 0
                        AND l_valid_ar_reference = 'N'
                        AND l_onacc_unapp_exist = 'N' THEN
                        log_debug
                           ('Invoice Reference did not match to any OKL Consolidated Invoice Number'
                           );
                        log_debug
                           ('Trying to match Invocie Reference to OKL Contract Number.'
                           );
                        log_debug
                           ('Calling okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract with parameters: '
                           );
                        log_debug ('p_customer_num = ' || l_customer_number);
                        log_debug (   'p_contract_num = '
                                   || l_orig_rcpt_tbl (i).invoice_number
                                  );
                        log_debug ('p_currency_code = ' || l_currency_code);
                        log_debug (   'amount applied = '
                                   || l_orig_rcpt_tbl (i).amount_applied
                                  );
                        log_debug (   'amount applied from = '
                                   || l_orig_rcpt_tbl (i).amount_applied_from
                                  );
                        log_debug (   'trans to receipt rate = '
                                   || l_orig_rcpt_tbl (i).trans_to_receipt_rate
                                  );
                        log_debug ('p_org_id = ' || l_org_id);
                        IF is_valid_reference('CONTRACT',
						                      l_orig_rcpt_tbl (i).invoice_number,
                                              l_currency_code1,
                                              l_trans_req_id,
                                              l_org_id,
                                              i,
                                              'OVRFLW PAYMENT',
                                              'AMT APP',
                                              'AMT APP FROM',
                                              l_customer_number,
                                              l_tmp_amount_applied,
                                              l_tmp_amount_app_from,
                                              l_returned_curr_code,
                                              l_returned_amount_to,
                                              l_returned_amount_from,
                                              l_returned_precision_to,
			       						      l_returned_precision_from)
   					     THEN
                           l_orig_rcpt_tbl (i).amount_applied := l_returned_amount_to;
                           l_orig_rcpt_tbl (i).amount_applied_from := l_returned_amount_from;
                           log_debug('p_amount_app_to = '|| l_orig_rcpt_tbl(i).amount_applied);
                           log_debug('p_amount_app_from = '|| l_orig_rcpt_tbl(i).amount_applied_from);
                           log_debug('invoice currency = '|| l_returned_curr_code);
                        --Check if reference number matches any okl contracts
                        okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract
                           (p_api_version         => l_api_version,
                            p_init_msg_list       => l_init_msg_list,
                            x_return_status       => l_return_status,
                            x_msg_count           => l_msg_count,
                            x_msg_data            => l_msg_data,
                            -- changed for bug 5391874
                               -- p_customer_num        => l_customer_number,
                               p_customer_num        => null,
                            p_contract_num        => l_orig_rcpt_tbl (i).invoice_number,
                            p_currency_code       => l_currency_code,
--                            p_rcpt_amount         => l_orig_rcpt_tbl (i).amount_applied,
                          p_amount_app_to   => l_orig_rcpt_tbl(i).amount_applied,
                          p_amount_app_from   => l_orig_rcpt_tbl(i).amount_applied_from,
                          p_inv_to_rct_rate   => l_orig_rcpt_tbl(i).trans_to_receipt_rate,
                          p_receipt_date   => l_receipt_date,
                            p_org_id              => l_org_id,
                            x_appl_tbl            => l_okl_rcpt_tbl,
                            x_onacc_amount        => l_onacc_amount,
                            x_unapply_amount      => l_unapply_amount
                           );
                        log_debug
                           (   'okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract return status = '
                            || l_return_status
                           );
                        log_debug
                           (   'Number of invoices identified for application purpose = '
                            || l_okl_rcpt_tbl.COUNT
                           );

                        IF (l_onacc_amount > 0) OR (l_unapply_amount > 0) THEN
                           l_onacc_unapp_exist := 'Y';
                        ELSE
                           l_onacc_unapp_exist := 'N';
                        END IF;

                        log_debug
                                (   ' On-Account / Unapplied amount exists : '
                                 || l_onacc_unapp_exist
                                );
                       END IF;
                     END IF;

                     --asawanka modified  for llca end
                     IF     l_okl_rcpt_tbl.COUNT = 0
                        AND l_valid_ar_reference = 'N'
                        AND l_onacc_unapp_exist = 'N' THEN
                        -- lets use some combination rules.
                        log_debug
                           ('Invoice Reference did not match to any OKL Contract Number'
                           );
                        log_debug ('Trying to use Search Rules');
                        log_debug
                           ('Calling okl_combi_cash_app_rls_pvt.handle_combi_pay with parameters: '
                           );
                        log_debug ('p_customer_number = ' || l_customer_number);
                        log_debug (   'p_rcpt_amount = '
                                   || l_orig_rcpt_tbl (i).amount_applied
                                  );
                        log_debug ('p_org_id = ' || l_org_id);
                        IF l_tmp_currency_code IS NULL OR l_tmp_currency_code = l_currency_code
						THEN
                           okl_combi_cash_app_rls_pvt.handle_combi_pay
                           (p_api_version          => l_api_version,
                            p_init_msg_list        => l_init_msg_list,
                            x_return_status        => l_return_status,
                            x_msg_count            => l_msg_count,
                            x_msg_data             => l_msg_data,
                            p_customer_number      => l_customer_number,
                            p_rcpt_amount          => l_orig_rcpt_tbl (i).amount_applied,
--                            p_receipt_date         => l_receipt_date,
                            p_org_id               => l_org_id,
                            p_currency_code        => l_currency_code,
                            x_appl_tbl             => l_okl_rcpt_tbl
                           );
                        log_debug
                           (   'okl_auto_cash_appl_rules_pvt.handle_combi_pay return status = '
                            || l_return_status
                           );
                        log_debug
                           (   'Number of invoices identified for application purpose = '
                            || l_okl_rcpt_tbl.COUNT
                           );
                       END IF;
                     END IF;

                     IF     l_okl_rcpt_tbl.COUNT = 0
                        --asawanka modified llca start
                        --commenting out l_lockbox_run_already condition as it is no longer required
                        -- AND l_lockbox_run_already = NULL
                        --asawanka modified  for llca end
                        AND l_valid_ar_reference = 'N'
                        AND l_onacc_unapp_exist = 'N' THEN
                        -- still no match, lets apply to customers oldest/newest invoice(s)
                        log_debug ('Search Rules failed.');
                        log_debug ('Trying to use Receipt Mismatch Rules');
                        log_debug
                           ('Calling okl_auto_cash_appl_rules_pvt.receipt_mismatch with parameters: '
                           );
                        log_debug ('p_customer_num = ' || l_customer_number);
                        log_debug ('p_currency_code = ' || l_currency_code);
                        log_debug (   'p_rcpt_amount = '
                                   || l_orig_rcpt_tbl (i).amount_applied
                                  );
                        log_debug ('p_org_id = ' || l_org_id);
                        --asawanka modified for llca start
                        --changed api call
                        IF l_tmp_currency_code IS NULL OR l_tmp_currency_code = l_currency_code
						THEN
                        okl_auto_cash_appl_rules_pvt.receipt_mismatch
                           (p_api_version        => l_api_version,
                            p_init_msg_list      => l_init_msg_list,
                            x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data,
                            p_customer_num       => l_customer_number,
                            p_currency_code      => l_currency_code,
                            p_rcpt_amount        => l_orig_rcpt_tbl (i).amount_applied,
                            p_org_id             => l_org_id,
                            p_receipt_date       => l_receipt_date,
                            x_appl_tbl           => l_okl_rcpt_tbl,
                            x_onacc_amount       => l_onacc_amount
                           );
                        --asawanka modified for llca end
                        log_debug
                           (   'okl_auto_cash_appl_rules_pvt.receipt_mismatch return status = '
                            || l_return_status
                           );
                        log_debug
                           (   'Number of invoices identified for application purpose = '
                            || l_okl_rcpt_tbl.COUNT
                           );

                        IF (l_onacc_amount > 0) THEN
                           l_onacc_unapp_exist := 'Y';
                        ELSE
                           l_onacc_unapp_exist := 'N';
                        END IF;

                        log_debug
                                (   ' On-Account / Unapplied amount exists : '
                                 || l_onacc_unapp_exist
                                );
                       END IF;
                     END IF;

                     IF     l_okl_rcpt_tbl.COUNT = 0
                        AND l_customer_number IS NOT NULL
                        AND l_onacc_unapp_exist = 'N' THEN
                        -- nothing found for receipt reference, retain invoice ref...
                        log_debug
                           ('Nothing found for Invoice Reference. Retaining Invoice Refence in interface table.'
                           );
                        l_no_mtch_rcpt_tbl (j).invoice_number :=
                                            l_orig_rcpt_tbl (i).invoice_number;
                        l_no_mtch_rcpt_tbl (j).amount_applied :=
                                            l_orig_rcpt_tbl (i).amount_applied;
                        j := j + 1;

                        -- ...and check for termination quotes
                        IF l_valid_ar_reference = 'N' THEN
                           log_debug
                              ('Checking if invoice reference matches any Approved termination quote number'
                              );

                           OPEN c_get_party_id (l_customer_number);

                           FETCH c_get_party_id
                            INTO l_party_id;

                           CLOSE c_get_party_id;

                           IF l_party_id IS NOT NULL THEN
                              OPEN c_check_termination
                                           (l_party_id,
                                            l_receipt_date,
                                            l_days_past_quote_valid,
                                            l_orig_rcpt_tbl (i).invoice_number
                                           );

                              LOOP
                                 FETCH c_check_termination
                                  INTO l_quote_id,
                                       l_quote_date_effective_to,
                                       l_quote_number,
                                       l_quote_amount;

                                 EXIT WHEN c_check_termination%NOTFOUND;
                                 log_debug
                                    ('Invoice Reference matches Termination Quote Number. Checking if amount to appply matches Termination Quote Amount'
                                    );

                                 IF l_quote_amount =
                                            l_orig_rcpt_tbl (i).amount_applied THEN
                                    l_qtev_rec.ID := l_quote_id;
                                    l_qtev_rec.payment_received_yn := 'Y';
                                    l_qtev_rec.date_payment_received :=
                                                               l_receipt_date;
                                    l_qtev_rec.date_effective_to :=
                                                    l_quote_date_effective_to;
                                    l_qtev_rec.accepted_yn := 'Y';
                                    l_qtev_rec.preproceeds_yn := 'N';
                                    log_debug
                                       ('Amount matches. Calling api okl_am_termnt_quote_pub.terminate_quote with parameters:'
                                       );
                                    log_debug (   'p_term_rec.id = '
                                               || l_qtev_rec.ID
                                              );
                                    log_debug
                                       (   'p_term_rec.payment_received_yn = '
                                        || l_qtev_rec.payment_received_yn
                                       );
                                    log_debug
                                       (   'p_term_rec.date_payment_received = '
                                        || l_qtev_rec.date_payment_received
                                       );
                                    log_debug
                                         (   'p_term_rec.date_effective_to = '
                                          || l_qtev_rec.accepted_yn
                                         );
                                    log_debug (   'p_term_rec.accepted_yn = '
                                               || l_qtev_rec.accepted_yn
                                              );
                                    log_debug
                                            (   'p_term_rec.preproceeds_yn = '
                                             || l_qtev_rec.preproceeds_yn
                                            );
                                    okl_am_termnt_quote_pub.terminate_quote
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_term_rec           => l_qtev_rec,
                                           x_term_rec           => x_qtev_rec,
                                           x_err_msg            => l_err_msg
                                          );
                                    log_debug
                                       (   'okl_am_termnt_quote_pub.terminate_quote return status = '
                                        || l_return_status
                                       );
                                    EXIT;
                                 END IF;
                              END LOOP;

                              CLOSE c_check_termination;
                           END IF;
                        END IF;
                     ELSIF l_okl_rcpt_tbl.COUNT > 0 THEN
                        -- we found some invoices to apply
                        log_debug
                           ('Invoice Appliactions identified. Processing Further...'
                           );
                        k := l_okl_rcpt_tbl.FIRST;

                        LOOP
                      -- (3) Loop through all new invoice(s)/invoice amount(s)
                           l_hdr_idx := k;
                           l_amt1_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP 1');
                           l_amt_from1_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP FROM 1');
                           l_new_invoice1 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                           l_new_amount_applied1 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                              * POWER (10, l_amt1_prec);
                           l_new_amount_applied_from1 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                              * POWER (10, l_amt_from1_prec);
                           l_new_currency_code1 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                           l_new_trans_to_rct_rate1 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                           k := k + 1;
                           l_amt2_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP 2');
                           l_amt_from2_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP FROM 2');
                           l_new_invoice2 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                           l_new_amount_applied2 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                              * POWER (10, l_amt2_prec);
                           l_new_amount_applied_from2 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                              * POWER (10, l_amt_from2_prec);
                           l_new_currency_code2 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                           l_new_trans_to_rct_rate2 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                           k := k + 1;
                           l_amt3_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP 3');
                           l_amt_from3_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP FROM 3');
                           l_new_invoice3 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                           l_new_amount_applied3 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                              * POWER (10, l_amt3_prec);
                           l_new_amount_applied_from3 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                              * POWER (10, l_amt_from3_prec);
                           l_new_currency_code3 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                           l_new_trans_to_rct_rate3 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                           k := k + 1;
                           l_amt4_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP 4');
                           l_amt_from4_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP FROM 4');
                           l_new_invoice4 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                           l_new_amount_applied4 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                              * POWER (10, l_amt4_prec);
                           l_new_amount_applied_from4 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                              * POWER (10, l_amt_from4_prec);
                           l_new_currency_code4 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                           l_new_trans_to_rct_rate4 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                           k := k + 1;
                           l_amt5_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP 5');
                           l_amt_from5_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP FROM 5');
                           l_new_invoice5 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                           l_new_amount_applied5 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                              * POWER (10, l_amt5_prec);
                           l_new_amount_applied_from5 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                              * POWER (10, l_amt_from5_prec);
                           l_new_currency_code5 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                           l_new_trans_to_rct_rate5 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                           k := k + 1;
                           l_amt6_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP 6');
                           l_amt_from6_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP FROM 6');
                           l_new_invoice6 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                           l_new_amount_applied6 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                              * POWER (10, l_amt6_prec);
                           l_new_amount_applied_from6 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                              * POWER (10, l_amt_from6_prec);
                           l_new_currency_code6 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                           l_new_trans_to_rct_rate6 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                           k := k + 1;
                           l_amt7_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP 7');
                           l_amt_from7_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP FROM 7');
                           l_new_invoice7 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                           l_new_amount_applied7 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                              * POWER (10, l_amt7_prec);
                           l_new_amount_applied_from7 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                              * POWER (10, l_amt_from7_prec);
                           l_new_currency_code7 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                           l_new_trans_to_rct_rate7 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                           k := k + 1;
                           l_amt8_prec := get_precision (l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP 8');
                           l_amt_from8_prec := get_precision(l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code,p_trans_req_id,'OVRFLW PAYMENT','AMT APP FROM 8');
                           l_new_invoice8 :=
                                 l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_number;
                           l_new_amount_applied8 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied
                              * POWER (10, l_amt8_prec);
                           l_new_amount_applied_from8 :=
                                l_okl_rcpt_tbl (k).inv_hdr_rec.amount_applied_from
                              * POWER (10, l_amt_from8_prec);
                           l_new_currency_code8 := l_okl_rcpt_tbl (k).inv_hdr_rec.invoice_currency_code;
                           l_new_trans_to_rct_rate8 := l_okl_rcpt_tbl (k).inv_hdr_rec.trans_to_receipt_rate;

                           -- create new overflow records
                           SELECT ar_payments_interface_s.NEXTVAL
                             INTO l_transmission_rec_id_of
                             FROM DUAL;

                           log_debug
                              ('Inserting overflow record with application information for the current payment record'
                              );
                           log_debug
                              (   'Transmission Record Id of new overflow record = '
                               || l_transmission_rec_id_of
                              );

                           INSERT INTO ar_payments_interface_all
                                       (transmission_record_id,
                                        item_number,
                                        record_type,
                                        status,
                                        transmission_id,
                                        transmission_request_id,
                                        lockbox_number,
                                        batch_name,
                                        invoice1,
                                        amount_applied1,
                                        amount_applied_from1,
                                        invoice_currency_code1,
                                        trans_to_receipt_rate1,
                                        invoice2,
                                        amount_applied2,
                                        amount_applied_from2,
                                        invoice_currency_code2,
                                        trans_to_receipt_rate2,
                                        invoice3,
                                        amount_applied3,
                                        amount_applied_from3,
                                        invoice_currency_code3,
                                        trans_to_receipt_rate3,
                                        invoice4,
                                        amount_applied4,
                                        amount_applied_from4,
                                        invoice_currency_code4,
                                        trans_to_receipt_rate4,
                                        invoice5,
                                        amount_applied5,
                                        amount_applied_from5,
                                        invoice_currency_code5,
                                        trans_to_receipt_rate5,
                                        invoice6,
                                        amount_applied6,
                                        amount_applied_from6,
                                        invoice_currency_code6,
                                        trans_to_receipt_rate6,
                                        invoice7,
                                        amount_applied7,
                                        amount_applied_from7,
                                        invoice_currency_code7,
                                        trans_to_receipt_rate7,
                                        invoice8,
                                        amount_applied8,
                                        amount_applied_from8,
                                        invoice_currency_code8,
                                        trans_to_receipt_rate8,
                                        org_id,
                                        creation_date,
                                        last_update_date
                                       )
                                VALUES (l_transmission_rec_id_of,
                                        l_item_number,
                                        l_overflow,
                                        l_status,
                                        l_transmission_id,
                                        l_trans_req_id,
                                        l_lockbox_number,
                                        l_batch_name,
                                        l_new_invoice1,
                                        l_new_amount_applied1,
                                        l_new_amount_applied_from1,
                                        l_new_currency_code1,
                                        l_new_trans_to_rct_rate1,
                                        l_new_invoice2,
                                        l_new_amount_applied2,
                                        l_new_amount_applied_from2,
                                        l_new_currency_code2,
                                        l_new_trans_to_rct_rate2,
                                        l_new_invoice3,
                                        l_new_amount_applied3,
                                        l_new_amount_applied_from3,
                                        l_new_currency_code3,
                                        l_new_trans_to_rct_rate3,
                                        l_new_invoice4,
                                        l_new_amount_applied4,
                                        l_new_amount_applied_from4,
                                        l_new_currency_code4,
                                        l_new_trans_to_rct_rate4,
                                        l_new_invoice5,
                                        l_new_amount_applied5,
                                        l_new_amount_applied_from5,
                                        l_new_currency_code5,
                                        l_new_trans_to_rct_rate5,
                                        l_new_invoice6,
                                        l_new_amount_applied6,
                                        l_new_amount_applied_from6,
                                        l_new_currency_code6,
                                        l_new_trans_to_rct_rate6,
                                        l_new_invoice7,
                                        l_new_amount_applied7,
                                        l_new_amount_applied_from7,
                                        l_new_currency_code7,
                                        l_new_trans_to_rct_rate7,
                                        l_new_invoice8,
                                        l_new_amount_applied8,
                                        l_new_amount_applied_from8,
                                        l_new_currency_code8,
                                        l_new_trans_to_rct_rate8,
                                        l_org_id,
                                        SYSDATE,
                                        TRUNC (SYSDATE)
                                       );

                           /*************************************************************************************
                             insert line level details in AR  table here
                           *************************************************************************************/
                           log_debug
                              ('Processing line level application data for currently inserted overflow record'
                              );
                           FOR l_inv_indx IN l_hdr_idx .. k
                           LOOP
                              IF l_okl_rcpt_tbl (l_inv_indx).inv_hdr_rec.invoice_number IS NOT NULL THEN
                                 l_linelevel_app :=
                                    get_line_level_app
                                       (l_okl_rcpt_tbl (l_inv_indx).inv_hdr_rec.invoice_id,
                                        l_org_id
                                       );

                                 IF l_linelevel_app = 'Y' THEN
                                    /*   -- first, delete any existing line level application data
                                       DELETE AR_PMTS_INTERFACE_LINE_DETAILS
                                       WHERE transmission_req_id = l_trans_req_id
                                       AND  transmission_record_id  = l_transmission_record_id
                                       AND  invoice_number = l_okl_rcpt_tbl(l_inv_indx).inv_hdr_rec.invoice_number;*/-- now create line level application data
                                    IF l_okl_rcpt_tbl (l_inv_indx).inv_lines_tbl.COUNT >
                                                                            0 THEN
                                       log_debug
                                          (   'Inserting line level application data for Invoice Number = '
                                           || l_okl_rcpt_tbl (l_inv_indx).inv_hdr_rec.invoice_number
                                          );

                                       FOR l_line_indx IN
                                          l_okl_rcpt_tbl (l_inv_indx).inv_lines_tbl.FIRST .. l_okl_rcpt_tbl
                                                                                               (l_inv_indx
                                                                                               ).inv_lines_tbl.LAST
                                       LOOP
                                         --START: Fixed as part of bug 6780241 by nikshah
                                           if (l_currency_code = l_okl_rcpt_tbl (l_inv_indx).inv_hdr_rec.invoice_currency_code) then
                                             l_amount_in_inv_curr :=l_okl_rcpt_tbl (l_inv_indx).inv_lines_tbl
                                                                    (l_line_indx).amount_applied;
                                             l_amount_in_rct_curr := null;
                                           else
                                             l_amount_in_inv_curr := null;
                                             l_amount_in_rct_curr := l_okl_rcpt_tbl (l_inv_indx).inv_lines_tbl
                                                                    (l_line_indx).amount_applied;
                                           end if;
                                          INSERT INTO ar_pmts_interface_line_details
                                                      (status,
                                                       transmission_request_id,
                                                       transmission_record_id,
                                                       invoice_number,
                                                       apply_to,
                                                       allocated_receipt_amount,
                                                       amount_applied
                                                      )
                                               VALUES ('AR_PLB_NEW_RECORD',
                                                       l_trans_req_id,
                                                       l_transmission_rec_id_of,
                                                       l_okl_rcpt_tbl
                                                                   (l_inv_indx).inv_hdr_rec.invoice_number,
                                                       l_okl_rcpt_tbl
                                                                   (l_inv_indx).inv_lines_tbl
                                                                  (l_line_indx).invoice_line_number,
                                                       l_amount_in_inv_curr,
                                                       l_amount_in_rct_curr
                                                      );
                                       --END: Fixed as part of bug 6780241 by nikshah
                                         END LOOP;
                                    END IF;
                                 END IF;
                              END IF;
                           END LOOP;

                           EXIT WHEN k = (l_okl_rcpt_tbl.LAST);
                                 -- records should always be in mutiples of 8.
                           k := k + 1;
                        --                                              k := k + 1;
                        --                              EXIT WHEN k = (l_okl_rcpt_tbl.LAST + 1);                -- records should always be in mutiples of 8.
                        END LOOP;
               -- (4) end looping through all new invoice(s)/invoice amount(s)
                     ELSE
                        log_debug
                           ('Invoice Reference matches valid non okl AR Invoice Number. Skipping the invoice reference'
                           );
                     END IF;
                  ELSE
                     -- lockbox already null.  so keep invoice ref.
                     log_debug
                        ('Line Level data already exists for this invoice reference. Skipping the invoice reference'
                        );
                     l_prec_to_use := 0;
                     l_prec_to_use_from := 0;

                     IF i = 1 THEN
                        l_prec_to_use := l_amt1_prec;
                        l_prec_to_use_from := l_amt_from1_prec;
                     ELSIF i = 2 THEN
                        l_prec_to_use := l_amt2_prec;
                        l_prec_to_use_from := l_amt_from2_prec;
                     ELSIF i = 3 THEN
                        l_prec_to_use := l_amt3_prec;
                        l_prec_to_use_from := l_amt_from3_prec;
                     ELSIF i = 4 THEN
                        l_prec_to_use := l_amt4_prec;
                        l_prec_to_use_from := l_amt_from4_prec;
                     ELSIF i = 5 THEN
                        l_prec_to_use := l_amt5_prec;
                        l_prec_to_use_from := l_amt_from5_prec;
                     ELSIF i = 6 THEN
                        l_prec_to_use := l_amt6_prec;
                        l_prec_to_use_from := l_amt_from6_prec;
                     ELSIF i = 7 THEN
                        l_prec_to_use := l_amt7_prec;
                        l_prec_to_use_from := l_amt_from7_prec;
                     ELSIF i = 8 THEN
                        l_prec_to_use := l_amt8_prec;
                        l_prec_to_use_from := l_amt_from8_prec;
                     END IF;

                     l_no_mtch_rcpt_tbl (j).invoice_number :=
                                            l_orig_rcpt_tbl (i).invoice_number;
                     l_no_mtch_rcpt_tbl (j).amount_applied :=
                          l_orig_rcpt_tbl (i).amount_applied
                        * POWER (10, l_prec_to_use);
                     l_no_mtch_rcpt_tbl(j).amount_applied_from := l_orig_rcpt_tbl(i).amount_applied_from * power(10,l_prec_to_use_from);
                     l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate :=  l_orig_rcpt_tbl(i).trans_to_receipt_rate;
                     j := j + 1;
                  END IF;

                  EXIT WHEN i = 8;
-- all 8 invoice references were processed in this overflow record, so move to nxt overflow rec
                  i := i + 1;
            -- invoice ref processed. move to nxt inv ref in this overflow rec
               ELSE                                          -- no invoice ref
                  IF     l_orig_rcpt_tbl (i).invoice_number IS NOT NULL
                     AND l_orig_rcpt_tbl (i).amount_applied IS NOT NULL THEN
                     log_debug
                        ('Invoice Reference exists but amount to apply is zero after considering precision. Keeping Invoice reference.'
                        );
                     l_prec_to_use := 0;
                     l_prec_to_use_from := 0;

                     IF i = 1 THEN
                        l_prec_to_use := l_amt1_prec;
                        l_prec_to_use_from := l_amt_from1_prec;
                     ELSIF i = 2 THEN
                        l_prec_to_use := l_amt2_prec;
                        l_prec_to_use_from := l_amt_from2_prec;
                     ELSIF i = 3 THEN
                        l_prec_to_use := l_amt3_prec;
                        l_prec_to_use_from := l_amt_from3_prec;
                     ELSIF i = 4 THEN
                        l_prec_to_use := l_amt4_prec;
                        l_prec_to_use_from := l_amt_from4_prec;
                     ELSIF i = 5 THEN
                        l_prec_to_use := l_amt5_prec;
                        l_prec_to_use_from := l_amt_from5_prec;
                     ELSIF i = 6 THEN
                        l_prec_to_use := l_amt6_prec;
                        l_prec_to_use_from := l_amt_from6_prec;
                     ELSIF i = 7 THEN
                        l_prec_to_use := l_amt7_prec;
                        l_prec_to_use_from := l_amt_from7_prec;
                     ELSIF i = 8 THEN
                        l_prec_to_use := l_amt8_prec;
                        l_prec_to_use_from := l_amt_from8_prec;
                     END IF;

                     l_no_mtch_rcpt_tbl (j).invoice_number :=
                                            l_orig_rcpt_tbl (i).invoice_number;
                     l_no_mtch_rcpt_tbl (j).amount_applied :=
                          l_orig_rcpt_tbl (i).amount_applied
                        * POWER (10, l_prec_to_use);
                     l_no_mtch_rcpt_tbl(j).amount_applied_from := l_orig_rcpt_tbl(i).amount_applied_from * power(10,l_prec_to_use_from);
                     l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate :=  l_orig_rcpt_tbl(i).trans_to_receipt_rate;
                     j := j + 1;
                  END IF;

                  EXIT WHEN i = 8;
-- all 8 invoice references were processed in this overflow record, so move to nxt overflow rec
                  i := i + 1;
            -- invoice ref processed. move to nxt inv ref in this overflow rec
               END IF;
            END LOOP;                                                   -- (3)

            -- delete/modify original overflow recs using l_transmission_record_id
            log_debug ('All invoice references in overflow record processed. ');
            j := 1;

            -- if all 8 inv refs in this overflow rec matched then delete this over flow rec
            IF     l_no_mtch_rcpt_tbl (j).invoice_number IS NULL
               AND (l_no_mtch_rcpt_tbl (j).amount_applied IS NULL OR l_no_mtch_rcpt_tbl (j).amount_applied_from IS NULL)
               AND l_no_mtch_rcpt_tbl (j + 1).invoice_number IS NULL
               AND (l_no_mtch_rcpt_tbl (j + 1).amount_applied IS NULL OR l_no_mtch_rcpt_tbl (j+1).amount_applied_from IS NULL)
               AND l_no_mtch_rcpt_tbl (j + 2).invoice_number IS NULL
               AND (l_no_mtch_rcpt_tbl (j + 2).amount_applied IS NULL OR l_no_mtch_rcpt_tbl (j+2).amount_applied_from IS NULL)
               AND l_no_mtch_rcpt_tbl (j + 3).invoice_number IS NULL
               AND (l_no_mtch_rcpt_tbl (j + 3).amount_applied IS NULL OR l_no_mtch_rcpt_tbl (j+3).amount_applied_from IS NULL)
               AND l_no_mtch_rcpt_tbl (j + 4).invoice_number IS NULL
               AND (l_no_mtch_rcpt_tbl (j + 4).amount_applied IS NULL OR l_no_mtch_rcpt_tbl (j+4).amount_applied_from IS NULL)
               AND l_no_mtch_rcpt_tbl (j + 5).invoice_number IS NULL
               AND (l_no_mtch_rcpt_tbl (j + 5).amount_applied IS NULL OR l_no_mtch_rcpt_tbl (j+5).amount_applied_from IS NULL)
               AND l_no_mtch_rcpt_tbl (j + 6).invoice_number IS NULL
               AND (l_no_mtch_rcpt_tbl (j + 6).amount_applied IS NULL OR l_no_mtch_rcpt_tbl (j+6).amount_applied_from IS NULL)
               AND l_no_mtch_rcpt_tbl (j + 7).invoice_number IS NULL
               AND (l_no_mtch_rcpt_tbl (j + 7).amount_applied IS NULL OR l_no_mtch_rcpt_tbl (j+7).amount_applied_from IS NULL)
			   THEN
               log_debug
                  ('All invoice references in this overflow record matched.Deleting this over flow record.'
                  );

               DELETE FROM ar_payments_interface_all
                                           -- no need to keep old overflow rec
                     WHERE transmission_record_id = l_transmission_record_id;
            END IF;

            -- if some of the 8 inv refs matched then
            -- keep the non matched inv refs and update resolved_match_numbers for them
            -- null out the matched inv refs
            IF    l_no_mtch_rcpt_tbl (j).invoice_number IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j).amount_applied IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j).amount_applied_from IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 1).invoice_number IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 1).amount_applied IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 1).amount_applied_from IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 2).invoice_number IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 2).amount_applied IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 2).amount_applied_from IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 3).invoice_number IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 3).amount_applied IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 3).amount_applied_from IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 4).invoice_number IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 4).amount_applied IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 4).amount_applied_from IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 5).invoice_number IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 5).amount_applied IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 5).amount_applied_from IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 6).invoice_number IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 6).amount_applied IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 6).amount_applied_from IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 7).invoice_number IS NOT NULL
               OR l_no_mtch_rcpt_tbl (j + 7).amount_applied IS NOT NULL
			   OR l_no_mtch_rcpt_tbl (j + 7).amount_applied_from IS NOT NULL THEN
               --           l_no_match_indicator = 1 THEN
               -- some reference did not evaluate to anything,
               -- but we need to keep them nonetheless ...
               log_debug
                  ('Nulling out invoice references which were matched successfully and retaining those which did not match at all'
                  );

               UPDATE ar_payments_interface_all
                  SET overflow_sequence =
                                NULL
                                    -- we'll take care of this later.see below
                                    ,
                      overflow_indicator =
                                NULL
                                    -- we'll take care of this later.see below
                                    ,
                      invoice1 = l_no_mtch_rcpt_tbl (j).invoice_number,
                      amount_applied1 = l_no_mtch_rcpt_tbl (j).amount_applied,
                      resolved_matching_number1 =
                                         l_no_mtch_rcpt_tbl (j).invoice_number,
                      amount_applied_from1 = l_no_mtch_rcpt_tbl(j).amount_applied_from,
                      trans_to_receipt_rate1 = l_no_mtch_rcpt_tbl(j).trans_to_receipt_rate,
                      invoice2 = l_no_mtch_rcpt_tbl (j + 1).invoice_number,
                      amount_applied2 =
                                     l_no_mtch_rcpt_tbl (j + 1).amount_applied,
                      resolved_matching_number2 =
                                     l_no_mtch_rcpt_tbl (j + 1).invoice_number,
                      amount_applied_from2 = l_no_mtch_rcpt_tbl(j+1).amount_applied_from,
                      trans_to_receipt_rate2 = l_no_mtch_rcpt_tbl(j+1).trans_to_receipt_rate,
                      invoice3 = l_no_mtch_rcpt_tbl (j + 2).invoice_number,
                      amount_applied3 =
                                     l_no_mtch_rcpt_tbl (j + 2).amount_applied,
                      resolved_matching_number3 =
                                     l_no_mtch_rcpt_tbl (j + 2).invoice_number,
                      amount_applied_from3 = l_no_mtch_rcpt_tbl(j + 2).amount_applied_from,
                      trans_to_receipt_rate3 = l_no_mtch_rcpt_tbl(j + 2).trans_to_receipt_rate,
                      invoice4 = l_no_mtch_rcpt_tbl (j + 3).invoice_number,
                      amount_applied4 =
                                     l_no_mtch_rcpt_tbl (j + 3).amount_applied,
                      resolved_matching_number4 =
                                     l_no_mtch_rcpt_tbl (j + 3).invoice_number,
                      amount_applied_from4 = l_no_mtch_rcpt_tbl(j + 3).amount_applied_from,
                      trans_to_receipt_rate4 = l_no_mtch_rcpt_tbl(j + 3).trans_to_receipt_rate,
                      invoice5 = l_no_mtch_rcpt_tbl (j + 4).invoice_number,
                      amount_applied5 =
                                     l_no_mtch_rcpt_tbl (j + 4).amount_applied,
                      resolved_matching_number5 =
                                     l_no_mtch_rcpt_tbl (j + 4).invoice_number,
                      amount_applied_from5 = l_no_mtch_rcpt_tbl(j + 4).amount_applied_from,
                      trans_to_receipt_rate5 = l_no_mtch_rcpt_tbl(j + 4).trans_to_receipt_rate,
                      invoice6 = l_no_mtch_rcpt_tbl (j + 5).invoice_number,
                      amount_applied6 =
                                     l_no_mtch_rcpt_tbl (j + 5).amount_applied,
                      resolved_matching_number6 =
                                     l_no_mtch_rcpt_tbl (j + 5).invoice_number,
                      amount_applied_from6 = l_no_mtch_rcpt_tbl(j + 5).amount_applied_from,
                      trans_to_receipt_rate6 = l_no_mtch_rcpt_tbl(j + 5).trans_to_receipt_rate,
                      invoice7 = l_no_mtch_rcpt_tbl (j + 6).invoice_number,
                      amount_applied7 =
                                     l_no_mtch_rcpt_tbl (j + 6).amount_applied,
                      resolved_matching_number7 =
                                     l_no_mtch_rcpt_tbl (j + 6).invoice_number,
                      amount_applied_from7 = l_no_mtch_rcpt_tbl(j + 6).amount_applied_from,
                      trans_to_receipt_rate7 = l_no_mtch_rcpt_tbl(j + 6).trans_to_receipt_rate,
                      invoice8 = l_no_mtch_rcpt_tbl (j + 7).invoice_number,
                      amount_applied8 =
                                     l_no_mtch_rcpt_tbl (j + 7).amount_applied,
                      resolved_matching_number8 =
                                     l_no_mtch_rcpt_tbl (j + 7).invoice_number,
                      amount_applied_from8 = l_no_mtch_rcpt_tbl(j + 7).amount_applied_from,
                      trans_to_receipt_rate8 = l_no_mtch_rcpt_tbl(j + 7).trans_to_receipt_rate
                WHERE transmission_record_id = l_transmission_record_id;
            END IF;
         END LOOP;                      --(2)   end loop through overflow recs

         CLOSE c_get_ovrflw_recs;

         -- still in context of original payment ...
         -- update sequence numbers and overflow indicators here.
         -- at this stage all the oveflow recs for this payment will have overfow_seq aand overflow indicator as null
         OPEN c_get_ovrflw_recs_new (l_trans_req_id,
                                     l_overflow,
                                     l_item_number,
                                     l_batch_name
                                    );

         seq_num := 1;

         LOOP                               -- (2)  loop through overflow recs
            FETCH c_get_ovrflw_recs_new
             INTO l_transmission_record_id;

            EXIT WHEN c_get_ovrflw_recs_new%NOTFOUND;

            UPDATE ar_payments_interface_all
               SET overflow_sequence = seq_num,
                   overflow_indicator = l_overflow_rec_indicator
             WHERE transmission_record_id = l_transmission_record_id;

            seq_num := seq_num + 1;
            l_last_transmission_record_id := l_transmission_record_id;
         END LOOP;

         -- set overflow indicator on last overflow record
         IF l_overflow_rec_indicator = '0' THEN
            l_ovf_ind := '1';
         ELSE
            l_ovf_ind := '0';
         END IF;

         UPDATE ar_payments_interface_all
            SET overflow_indicator = l_ovf_ind
          WHERE transmission_record_id = l_last_transmission_record_id;

         CLOSE c_get_ovrflw_recs_new;

         log_debug ('All overflow records processed.');
      END LOOP;                                                         -- (1)

      CLOSE c_get_pmt_recs;

      -- tidy up
      -- UPDATE transmission total record count, both header and trailer.
      -- update transmission records in lock box.
      log_debug ('All payment records processed.');
      l_trans_rec_count := get_rec_count (l_trans_req_id);

      UPDATE ar_payments_interface_all
         SET transmission_record_count = l_trans_rec_count
       WHERE transmission_request_id = l_trans_req_id
         AND record_type IN (l_transmission_hdr, l_transmission_trl);

      x_return_status := okl_api.g_ret_sts_success;
      log_debug (' okl_lckbx_csh_app_pvt.handle_auto_pay end.');
      log_debug
         ('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
         );
   EXCEPTION
        /*
          WHEN Okl_Api.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count ;
            l_msg_data := 'something wrong';
            x_msg_data := l_msg_data ;
      */
      WHEN OTHERS THEN
         x_return_status := okl_api.g_ret_sts_unexp_error;
         x_msg_count := l_msg_count;
         x_msg_data := l_msg_data;
   END handle_auto_pay;
END okl_lckbx_csh_app_pvt;

/
