--------------------------------------------------------
--  DDL for Package Body FUN_NET_ARAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_ARAP_PKG" AS
/* $Header: funnttxb.pls 120.65.12010000.36 2010/04/23 13:11:55 srampure ship $ */
--===========================FND_LOG.START=====================================
g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);
--===========================FND_LOG.END=======================================
	--Declare all required global variables
    TYPE batch_rec          IS RECORD
    (batch_id               fun_net_batches_all.batch_id%TYPE,
    agreement_id            fun_net_agreements_all.agreement_id%TYPE,
    currency                gl_ledgers.currency_code%TYPE);
    TYPE batch_table        IS TABLE OF batch_rec INDEX BY BINARY_INTEGER;
    SUBTYPE batch_details_rec IS fun_net_batches_all%ROWTYPE;
    g_batch_details         batch_details_rec;
    g_batch_list            batch_table;
    g_idx                   BINARY_INTEGER;
   -- TYPE txnCurType			IS REF CURSOR;
    TYPE pymt_sch_rec       IS RECORD
    (invoice_id             ap_invoices_all.invoice_id%TYPE,
    min_payment_num         ap_payment_schedules_all.payment_num%TYPE,
    max_payment_num         ap_payment_schedules_all.payment_num%TYPE);
    TYPE pymt_sch_tab		IS TABLE OF pymt_sch_rec INDEX BY BINARY_INTEGER;
    TYPE txnRecType IS RECORD
   (
    customer_trx_id 		ra_customer_trx.customer_trx_id%TYPE,
    exchange_rate           ra_customer_trx.exchange_rate%TYPE,
    amt_remaining 		    ar_payment_schedules.amount_due_remaining%TYPE,
    txn_amt                 fun_net_ar_txns.transaction_amt%TYPE,
    open_amt			    fun_net_ar_txns.open_amt%TYPE,
    txn_curr_open_amt       fun_net_ar_txns.txn_curr_open_amt%TYPE,
    txn_curr_amt            ra_customer_trx_lines.extended_amount%TYPE,
    txn_curr_net_amt        fun_net_ar_txns.txn_curr_net_amt%TYPE,
    net_amt                 fun_net_ar_txns.netted_amt%TYPE,
    invoice_currency_code   ra_customer_trx.invoice_currency_code%TYPE,
    payment_type_code 		ar_receipt_methods.payment_type_code%TYPE);
   TYPE txnTblType IS TABLE OF txnRecType INDEX BY BINARY_INTEGER;
   TYPE arReceiptRecType IS RECORD
   (
   currency_code                fun_net_batches.batch_currency%TYPE,
   exchange_rate_type           fun_net_batches.exchange_rate_type%TYPE,
   exchange_rate                ra_customer_trx.exchange_rate%TYPE,
   exchange_rate_date           ra_customer_trx.exchange_date%TYPE,
   amount                       fun_net_batches.total_netted_amt%TYPE,
   factor_discount_amount       fun_net_batches.total_netted_amt%TYPE,
   receipt_number               ar_cash_receipts.receipt_number%TYPE,
   receipt_date                 ar_cash_receipts.receipt_date%TYPE,
   gl_date                      ar_cash_receipts.receipt_date%TYPE,
   customer_id                  hz_cust_accounts.cust_account_id%TYPE,
   customer_site_use_id         hz_cust_site_uses.site_use_id%TYPE,
   remittance_bank_account_id   fun_net_agreements.bank_account_id%TYPE,
   remittance_bank_account_num  ce_bank_accounts.bank_account_num%TYPE,
   remittance_bank_account_name ce_bank_accounts.bank_account_name%TYPE ,
   receipt_method_id            ar_receipt_methods.receipt_method_id%TYPE,
   org_id                       fun_net_batches.org_id%TYPE
   );
    g_batch_id              fun_net_batches_all.batch_id%TYPE;
    g_net_currency_rule     fun_net_agreements_all.net_currency_rule_code%TYPE;
    g_net_order_rule        fun_net_agreements_all.net_order_rule_code%TYPE;
    g_net_balance_rule      fun_net_agreements_all.net_balance_rule_code%TYPE;
    g_net_currency          fun_net_agreements_all.net_currency_code%TYPE;
    g_bank_account_id       fun_net_agreements_all.bank_account_id%TYPE;
    g_agreement_id          fun_net_agreements_all.agreement_id%TYPE;
    g_agr_start_date        fun_net_agreements_all.agreement_start_date%TYPE;
    g_agr_end_date          fun_net_agreements_all.agreement_end_date%TYPE;
    g_func_currency         gl_ledgers.currency_code%TYPE;
    g_shikyu_rule           fun_net_agreements_all.shikyu_rule_code%TYPE;
    g_days_past_due         fun_net_agreements_all.days_past_due%TYPE;
    g_sel_past_due_flag     fun_net_agreements_all.sel_rec_past_due_txns_flag%TYPE;
    g_agreement_count       NUMBER;
    g_currency_count        NUMBER;
    g_user_id               NUMBER;
    g_login_id              NUMBER;
    g_today                 DATE;
    l_allow_disc_flag       VARCHAR2(1);   -- ER
    PROCEDURE get_functional_currency IS
        l_ledger_id         gl_ledgers.ledger_id%TYPE;
        l_ledger_name       gl_ledgers.name%TYPE;
    BEGIN
        MO_Utils.Get_Ledger_Info(
                    g_batch_details.org_id,
                    l_ledger_id,
                    l_ledger_name);
        SELECT currency_code
        INTO g_func_currency
        FROM gl_ledgers
        WHERE ledger_id = l_ledger_id;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END get_functional_currency;
   /* Derives Conv Amt . Returns the same amount if from and to are of the same currency, else returns the converted currency amount */
    FUNCTION Derive_Conv_Amt(p_batch_id NUMBER,p_trx_id NUMBER,p_amount NUMBER,ap_ar VARCHAR2)
    RETURN NUMBER
    IS
    l_exg_rate fun_net_batches_all.exchange_rate%TYPE;
    l_exg_rate_1 fun_net_batches_all.exchange_rate%TYPE;
    l_exchange_rate_type fun_net_batches_all.exchange_rate_type%TYPE;
    l_inv_currency      fnd_currencies.currency_code%TYPE;
    l_precision         fnd_currencies.precision%TYPE;
    l_batch_currency fun_net_batches_all.BATCH_CURRENCY%TYPE;
    l_settlement_date fun_net_batches_all.SETTLEMENT_DATE%TYPE;
    l_exchange_rate fun_net_batches_all.EXCHANGE_RATE%TYPE;
    l_org_id fun_net_batches_all.ORG_ID%TYPE;
    l_path              varchar2(100);
    BEGIN
        l_path      := g_path || 'Derive Converted Amount';
	IF ap_ar='AP' THEN
		   SELECT fc.currency_code,fc.precision
                        INTO l_inv_currency,l_precision
                        FROM ap_invoices_all api, fnd_currencies fc
                        WHERE api.invoice_id = p_trx_id
                        AND api.invoice_currency_code = fc.currency_code;
	ELSE
	          SELECT fc.currency_code,fc.precision
                        INTO l_inv_currency,l_precision
                        FROM ra_customer_trx_all rct, fnd_currencies fc
                        WHERE rct.customer_trx_id = p_trx_id
                        AND rct.invoice_currency_code = fc.currency_code;
	END IF;
	SELECT BATCH_CURRENCY,SETTLEMENT_DATE,EXCHANGE_RATE_TYPE,EXCHANGE_RATE,ORG_ID
	       INTO l_batch_currency,l_settlement_date,l_exchange_rate_type,l_exg_rate,l_org_id
	FROM FUN_NET_BATCHES_ALL
	WHERE batch_id=p_batch_id;
	IF l_exchange_rate_type = 'User' then
            l_exg_rate := l_exg_rate_1;
        ELSIF l_exchange_rate_type IS NULL THEN
             SELECT default_exchange_rate_type
               INTO l_exchange_rate_type
               FROM ap_system_parameters_all
              WHERE org_id = l_org_id;
        END IF;
        IF ((l_exchange_rate_type IS NOT NULL) AND (l_exchange_rate_type<>'User'))THEN
           IF gl_currency_api.rate_exists(
	   		l_batch_currency,	    -- From currency
			l_inv_currency,             -- To Currency
                        l_settlement_date,
                        l_exchange_rate_type) = 'Y' THEN
                 l_exg_rate := gl_currency_api.get_rate(
		 		  l_batch_currency, -- From currency
				  l_inv_currency,   -- To Currency
                                  l_settlement_date,
                                  l_exchange_rate_type);
            ELSIF(l_exchange_rate_type='User') THEN
		RETURN round(gl_currency_api.convert_closest_amount_sql(l_inv_currency,l_batch_currency,trunc(l_settlement_date),l_exchange_rate_type,l_exg_rate,p_amount,0),l_precision);
 	    ELSE
                RETURN null;
            END IF;
        END IF;
        RETURN round((p_amount * l_exg_rate),l_precision);
    EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
    END Derive_Conv_Amt;
	--This function will return the discount amount for a given invoice and amount
	FUNCTION get_ap_discount(p_batch_id NUMBER, p_invoice_id NUMBER, p_amt_to_net NUMBER, p_txn_due_date DATE) RETURN NUMBER IS
		TYPE amt_type IS TABLE OF fun_net_batches_all.total_netted_amt%TYPE INDEX BY BINARY_INTEGER;
	     TYPE tnxCurTyp IS REF CURSOR;
	     l_sql_stmt VARCHAR2(500);
	     l_applieddisc NUMBER;
	     pmt_rec tnxCurTyp;
	     l_pmtno amt_type;
	     l_amt_remaining amt_type;
	     l_amt_to_net NUMBER;
	     l_net_currency_rule_code VARCHAR2(100);
	     l_settlement_date DATE;
	     l_current_discount NUMBER;
	     l_currency_code                fun_net_batches.batch_currency%TYPE;
	     l_exchange_rate_type           fun_net_batches.exchange_rate_type%TYPE;
	     l_invoice_currency_code        AP_INVOICES_ALL.INVOICE_CURRENCY_CODE%TYPE;
	     l_path      VARCHAR2(100);
	    BEGIN
	    l_path := g_path||'get_ap_discount';
	    l_sql_stmt:='select PAYMENT_NUM,AMOUNT_REMAINING FROM ap_payment_schedules_all WHERE invoice_id=:v_invoice_id ';
	 l_applieddisc := 0;
	 l_amt_to_net := p_amt_to_net;
	    fun_net_util.Log_String(g_state_level,l_path,'l_amt_to_net :'|| l_amt_to_net);
	    SELECT FNA.net_currency_rule_code, FNB.batch_currency, FNB.exchange_rate_type, FNB.settlement_date
	    INTO l_net_currency_rule_code, l_currency_code, l_exchange_rate_type, l_settlement_date
	    FROM FUN_NET_BATCHES_ALL FNB,
	    FUN_NET_AGREEMENTS_ALL FNA
	    where
	    FNB.BATCH_ID = p_batch_id
	    AND FNB.AGREEMENT_ID = FNA.AGREEMENT_ID;
	   fun_net_util.Log_String(g_state_level,l_path,'l_net_currency_rule_code:'|| l_net_currency_rule_code);
	   IF(l_net_currency_rule_code = 'ACCOUNTING_CURRENCY') THEN
	    l_amt_to_net := Derive_Conv_Amt(p_batch_id, p_invoice_id, l_amt_to_net, 'AP');
	    fun_net_util.Log_String(g_state_level,l_path,'After conversion :'|| l_amt_to_net);
	   END IF;
	 OPEN pmt_rec FOR l_sql_stmt USING p_invoice_id;
	 FETCH pmt_rec BULK COLLECT INTO l_pmtno,l_amt_remaining;
	 FOR j IN 1..l_pmtno.COUNT
	 LOOP
	   fun_net_util.Log_String(g_state_level,l_path,'l_amt_to_net :'|| l_amt_to_net);
	   fun_net_util.Log_String(g_state_level,l_path,'l_amt_remaining('||j||') :'|| l_amt_remaining(j));
	  IF l_amt_remaining(j)>=l_amt_to_net THEN
	   l_applieddisc := AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Netted_Amt( p_invoice_id,l_pmtno(j),p_txn_due_date,l_amt_to_net) + l_applieddisc;
	   EXIT;
	  ELSE
	   l_current_discount := AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Pmt_Schedule( p_invoice_id,l_pmtno(j),p_txn_due_date);
	   l_applieddisc := l_current_discount + l_applieddisc;
	   l_amt_to_net := l_amt_to_net - (l_amt_remaining(j) - l_current_discount);
	  END IF;
	  fun_net_util.Log_String(g_state_level,l_path,'l_current_discount('||j||') :'|| l_current_discount);
	 END LOOP;
	 fun_net_util.Log_String(g_state_level,l_path,'l_applieddisc :'|| l_applieddisc);
	    IF(l_net_currency_rule_code = 'ACCOUNTING_CURRENCY' and l_applieddisc > 0) THEN
	    select INVOICE_CURRENCY_CODE
	    into l_invoice_currency_code
	    from AP_INVOICES_ALL
	    where INVOICE_ID = p_invoice_id;
	    l_applieddisc := gl_currency_api.convert_amount_sql(l_invoice_currency_code,
							       l_currency_code,
							       trunc(l_settlement_date),
							       l_exchange_rate_type,
							       l_applieddisc);
	    fun_net_util.Log_String(g_state_level,l_path,'Batch currency l_applieddisc :'|| l_applieddisc);
	   END IF;
		RETURN l_applieddisc;
	    EXCEPTION
		WHEN OTHERS THEN
		fun_net_util.Log_String(g_state_level,l_path,' Error......');
		    RETURN 0;
	    END get_ap_discount;
	--This function will return the discount amount for a given invoice and amount
	   FUNCTION get_ar_discount(p_batch_id NUMBER, p_cust_txn_id NUMBER, p_amt_to_net NUMBER, p_txn_due_date DATE) RETURN NUMBER IS
		TYPE amt_type IS TABLE OF fun_net_batches_all.total_netted_amt%TYPE INDEX BY BINARY_INTEGER;
	    TYPE tnxCurTyp IS REF CURSOR;
	    l_applieddisc NUMBER;
	    l_pmtno amt_type;
	    l_amt_remaining amt_type;
	    l_amt_to_net NUMBER;
	    l_sql_stmt VARCHAR2(150);
	    l_net_currency_rule_code VARCHAR2(100);
	    l_current_discount NUMBER;
	    pmt_rec tnxCurTyp;
		l_org_id NUMBER;
		l_settlement_date DATE;
	    l_currency_code                fun_net_batches.batch_currency%TYPE;
	    l_exchange_rate_type           fun_net_batches.exchange_rate_type%TYPE;
	    l_invoice_currency_code        RA_CUSTOMER_TRX_ALL.INVOICE_CURRENCY_CODE%TYPE;
	    l_path      VARCHAR2(100);
	    BEGIN
	    l_path := g_path||'get_ar_discount';
	    l_amt_to_net := p_amt_to_net;
	    fun_net_util.Log_String(g_state_level,l_path,' p_amt_to_net :: '||p_amt_to_net);
	    SELECT FNA.net_currency_rule_code, FNB.batch_currency, FNB.exchange_rate_type, FNB.settlement_date
	    INTO l_net_currency_rule_code, l_currency_code, l_exchange_rate_type, l_settlement_date
	    FROM FUN_NET_BATCHES_ALL FNB,
	    FUN_NET_AGREEMENTS_ALL FNA
	    where
	    FNB.BATCH_ID = p_batch_id
	    AND FNB.AGREEMENT_ID = FNA.AGREEMENT_ID;
	    fun_net_util.Log_String(g_state_level,l_path,'l_net_currency_rule_code:'|| l_net_currency_rule_code);
	    SELECT
	    DISTINCT ORG_ID INTO l_org_id
	    FROM FUN_NET_AR_TXNS_ALL
	    WHERE CUSTOMER_TRX_ID = p_cust_txn_id;
	    MO_GLOBAL.SET_POLICY_CONTEXT('S',l_org_id);
	   IF(l_net_currency_rule_code = 'ACCOUNTING_CURRENCY') THEN
	    l_amt_to_net := Derive_Conv_Amt(p_batch_id, p_cust_txn_id, l_amt_to_net, 'AR');
	    fun_net_util.Log_String(g_state_level,l_path,'After conversion :'|| l_amt_to_net);
	   END IF;
	   l_sql_stmt:='SELECT PAYMENT_SCHEDULE_ID,AMOUNT_DUE_REMAINING FROM ar_payment_schedules_all WHERE CUSTOMER_TRX_ID=:v_cst_trx_id';
	   l_applieddisc:=0;
	   OPEN pmt_rec FOR l_sql_stmt USING p_cust_txn_id;
	   FETCH pmt_rec BULK COLLECT INTO l_pmtno,l_amt_remaining;
	   FOR j IN 1..l_pmtno.COUNT
	   LOOP
	    fun_net_util.Log_String(g_state_level,l_path,'l_amt_to_net :'|| l_amt_to_net);
	    fun_net_util.Log_String(g_state_level,l_path,'l_amt_remaining('||j||') :'|| l_amt_remaining(j));
	    IF l_amt_remaining(j)>=l_amt_to_net THEN
	     l_applieddisc := ARP_DISCOUNTS_API.Get_Available_Disc_On_Inv(l_pmtno(j),p_txn_due_date,l_amt_to_net) + l_applieddisc;
	     EXIT;
	    ELSE
	     l_current_discount := ARP_DISCOUNTS_API.Get_Available_Disc_On_Inv(l_pmtno(j),p_txn_due_date,null);
	     l_applieddisc := l_current_discount + l_applieddisc;
	     l_amt_to_net := l_amt_to_net - (l_amt_remaining(j) - l_current_discount);
	    END IF;
	      fun_net_util.Log_String(g_state_level,l_path,'l_current_discount('||j||') :'|| l_current_discount);
	   END LOOP;
		  fun_net_util.Log_String(g_state_level,l_path,'l_applieddisc :'|| l_applieddisc);
	       IF(l_net_currency_rule_code = 'ACCOUNTING_CURRENCY' and l_applieddisc > 0) THEN
	    select INVOICE_CURRENCY_CODE
	    into l_invoice_currency_code
	    from RA_CUSTOMER_TRX_ALL
	    where CUSTOMER_TRX_ID = p_cust_txn_id;
	    l_applieddisc := gl_currency_api.convert_amount_sql(l_invoice_currency_code,
							       l_currency_code,
							       trunc(l_settlement_date),
							       l_exchange_rate_type,
							       l_applieddisc);
		END IF;
		fun_net_util.Log_String(g_state_level,l_path,'Batch currency l_applieddisc :'|| l_applieddisc);
		RETURN l_applieddisc;
	    EXCEPTION
		WHEN OTHERS THEN
		fun_net_util.Log_String(g_state_level,l_path,' Error......');
		    RETURN 0;
    END get_ar_discount;
    FUNCTION get_batch_details RETURN BOOLEAN IS
        CURSOR c_get_batch_details IS
            SELECT batch_id,
                    object_version_number,
                    agreement_id,
                    batch_name,
                    batch_number,
                    review_netting_batch_flag,
                    batch_currency,
                    batch_status_code,
                    total_netted_amt,
                    transaction_due_date,
                    settlement_date,
                    response_date,
                    exchange_rate_type,
                    exchange_rate,
                    gl_date,
                    org_id,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    attribute16,
                    attribute17,
                    attribute18,
                    attribute19,
                    attribute20,
                    checkrun_id
            FROM     fun_net_batches_all
            WHERE   batch_id = g_batch_id;
    BEGIN
        --Get all the batch details into global variables from the table fun_net_batches_all
        OPEN c_get_batch_details;
        FETCH c_get_batch_details
                INTO    g_batch_details.batch_id,
                    g_batch_details.object_version_number,
                    g_batch_details.agreement_id,
                    g_batch_details.batch_name,
                    g_batch_details.batch_number,
                    g_batch_details.review_netting_batch_flag,
                    g_batch_details.batch_currency,
                    g_batch_details.batch_status_code,
                    g_batch_details.total_netted_amt,
                    g_batch_details.transaction_due_date,
                    g_batch_details.settlement_date,
                    g_batch_details.response_date,
                    g_batch_details.exchange_rate_type,
                    g_batch_details.exchange_rate,
                    g_batch_details.gl_date,
                    g_batch_details.org_id,
                    g_batch_details.attribute_category,
                    g_batch_details.attribute1,
                    g_batch_details.attribute2,
                    g_batch_details.attribute3,
                    g_batch_details.attribute4,
                    g_batch_details.attribute5,
                    g_batch_details.attribute6,
                    g_batch_details.attribute7,
                    g_batch_details.attribute8,
                    g_batch_details.attribute9,
                    g_batch_details.attribute10,
                    g_batch_details.attribute11,
                    g_batch_details.attribute12,
                    g_batch_details.attribute13,
                    g_batch_details.attribute14,
                    g_batch_details.attribute15,
                    g_batch_details.attribute16,
                    g_batch_details.attribute17,
                    g_batch_details.attribute18,
                    g_batch_details.attribute19,
                    g_batch_details.attribute20,
		    g_batch_details.checkrun_id;
        IF c_get_batch_details%NOTFOUND THEN
            CLOSE c_get_batch_details;
            RETURN FALSE;
        ELSE
            CLOSE c_get_batch_details;
            g_batch_details.transaction_due_date := TRUNC(g_batch_details.transaction_due_date);
            RETURN TRUE;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF c_get_batch_details%ISOPEN THEN
                CLOSE c_get_batch_details;
            END IF;
            RETURN FALSE;
    END get_batch_details;
    FUNCTION get_agreement_details RETURN BOOLEAN IS
        CURSOR c_get_agreement_details IS
            SELECT 	net_currency_rule_code,
                net_order_rule_code,
                net_balance_rule_code,
                bank_account_id,
                net_currency_code,
                agreement_start_date,
                agreement_end_date,
		nvl(days_past_due,0),
                sel_rec_past_due_txns_flag
            FROM    fun_net_agreements
            WHERE   agreement_id = g_agreement_id;
    BEGIN
-- Get all the agreement details like netting_currency_rule, netting_order_rule, --etc, into global variables from the table fun_net_agreements_all
        OPEN c_get_agreement_details;
        FETCH c_get_agreement_details
                    INTO g_net_currency_rule,
                        g_net_order_rule,
                        g_net_balance_rule,
                        g_bank_account_id,
                        g_net_currency,
                        g_agr_start_date,
                        g_agr_end_date,
                        g_days_past_due,
                        g_sel_past_due_flag;
        IF c_get_agreement_details%NOTFOUND THEN
            CLOSE c_get_agreement_details;
            RETURN FALSE;
        ELSE
            CLOSE c_get_agreement_details;
            IF g_agr_end_date IS NULL THEN
                g_agr_end_date := to_date('31/12/9999','DD/MM/YYYY');
            END IF;
            g_agr_start_date := TRUNC(g_agr_start_date);
            g_agr_end_date := TRUNC(g_agr_end_date);
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            IF c_get_agreement_details%ISOPEN THEN
                CLOSE c_get_agreement_details;
            END IF;
            RETURN FALSE;
    END get_agreement_details;
    FUNCTION update_batch_status(p_status VARCHAR2) RETURN BOOLEAN IS
        l_path      VARCHAR2(100);
    BEGIN
        l_path  := g_path || 'Update_Batch_Status';
		/* Check for mandatory parameters */
        IF  p_status IS NULL THEN
			RETURN FALSE;
        ELSE
           FUN_NET_BATCHES_PKG.Update_Row
            (x_batch_id => g_batch_id,
            x_batch_status_code => p_status);
        END IF;
        fun_net_util.Log_String(g_state_level,l_path,'Successfully updated batch status');
        RETURN TRUE;
	EXCEPTION
        WHEN NO_DATA_FOUND THEN
	       fun_net_util.Log_String(g_state_level,l_path,'EXCEPTION: No data found');
           RETURN FALSE;
        WHEN OTHERS THEN
	       fun_net_util.Log_String(g_state_level,l_path,'EXCEPTION: '||sqlerrm);
            RETURN FALSE;
    END update_batch_status;
    FUNCTION prepare_ar_transactions RETURN BOOLEAN IS
        l_trx_select_clause     VARCHAR2(2000);
        l_trx_from_clause       VARCHAR2(2000);
        l_trx_where_clause      VARCHAR2(3000);
        l_trx_group_by_clause   VARCHAR2(2000);
        l_trx_order_by_clause   VARCHAR2(2000);
        l_sql_stmt              VARCHAR2(6000);
        TYPE trxCurTyp          IS REF CURSOR;
        trx_cur                 trxCurTyp;
        l_currency_code         VARCHAR2(15);
        l_path                  VARCHAR2(100);
    BEGIN
        l_path      := g_path || 'Prepare_AR_Transactions';
        fun_net_util.Log_String(g_proc_level,l_path,'Preparing AR Transactions');
	SELECT ALLOW_DISC_FLAG into l_allow_disc_flag FROM FUN_NET_AGREEMENTS_all WHERE Agreement_id=g_agreement_id;   -- ER
	IF l_allow_disc_flag='N' THEN  						-- FOR NON ESD AGREEMENTS
			-- Build Select Clause --
			l_trx_select_clause :=
			    'SELECT	rct.customer_trx_id,
				fun_net_arap_pkg.Calculate_ar_trx_amt(rct.customer_trx_id) transaction_amount,
				sum(arps.amount_due_remaining) AS open_amount ' ;
       ELSE 									-- FOR ESD Enabled Agreements, Calculating OPEN_AMOUNT_AFTERDISC for ESD enabled Agreements
          		MO_GLOBAL.SET_POLICY_CONTEXT('S',g_batch_details.org_id);     -- chk pending where to put the MOAC call.
			l_trx_select_clause :=
			    'SELECT	rct.customer_trx_id,
				fun_net_arap_pkg.Calculate_ar_trx_amt(rct.customer_trx_id) transaction_amount,
				sum(arps.amount_due_remaining) AS open_amount,
				sum(arps.amount_due_remaining - ARP_DISCOUNTS_API.Get_Available_Disc_On_Inv(arps.PAYMENT_SCHEDULE_ID,:SETTLEMENT_DATE,NULL)) AS OPEN_AMOUNT_AFTERDISC';   -- ADDED FOR ESD ENABLED AGREEMENTS
       END IF;
       fun_net_util.Log_String(g_state_level,l_path,'SELECT : '||l_trx_select_clause);
	l_trx_from_clause :=
	    ' FROM ra_customer_trx_all rct,
		ar_payment_schedules_all arps,
		ra_cust_trx_types_all rctt,
		fun_net_customers_all fnc ';
	fun_net_util.Log_String(g_state_level,l_path,'FROM : '||l_trx_from_clause);
	-- Build the WHERE  clause --
	/* Only select the transactions where the due date is on or before the Tnx due date in the batch */
	/* Only select transactions where the tnx due date is between the start and end date of the agreement */
	/*  Select only completed AR Transactions */
	/* Past Due Transactions */
	/* Do not select transactions that have prepayments ie : Preparyment flag  = 'Y' */
	/* Disputed transactions should not be selected */
	/* Only select the transactions whose invoice types have been defined in the agreement */
	/* Do not select transactions where the payment type code = 'CREDIT CARD' */
	/* Do not select transactions that are already selected in another batch that is not in Status Complete */
	l_trx_where_clause :=
	    ' WHERE arps.customer_trx_id = rct.customer_trx_id
	     AND arps.status = ''OP''
	    AND rct.complete_flag = ''Y''
	    AND TRUNC(arps.due_date) BETWEEN trunc(:v_agr_start_date)
		    AND trunc(:v_agr_end_date)
	    AND	NVL(rct.prepayment_flag, ''N'') = ''N''
		AND rct.cust_trx_type_id = rctt.cust_trx_type_id
	    AND	NVL(arpt_sql_func_util.get_dispute_amount
			(rct.customer_trx_id,rctt.type,rctt.accounting_affect_flag),0) = 0
	    AND	arpt_sql_func_util.get_dispute_date
			(rct.customer_trx_id,rctt.type,rctt.accounting_affect_flag) IS NULL
	    AND	rct.bill_to_customer_id = fnc.cust_account_id
	    AND rct.bill_to_site_use_id = nvl(fnc.cust_site_use_id, rct.bill_to_site_use_id)
	    AND	fnc.agreement_id = :v_agreement_id1
	    AND	EXISTS
		(SELECT ''X''
		    FROM	fun_net_ar_trx_types_all fnar
		    WHERE fnar.cust_trx_type_id = rct.cust_trx_type_id
		    AND	fnar.agreement_id = :v_agreement_id2)
	    AND	 NOT EXISTS
		(SELECT ''X''
		FROM   ar_receipt_methods arm
		WHERE  arm.receipt_method_id = rct.receipt_method_id
		AND    arm.payment_type_code = ''CREDIT_CARD'')
	    AND	 NOT EXISTS
		(SELECT ''X''
		FROM  	fun_net_ar_txns_all fnar,
		    fun_net_batches_all fnba
		WHERE 	Fnar.customer_trx_id = rct.customer_trx_id
		AND 	fnar.batch_id = fnba.batch_id
		AND  	fnba.batch_status_code <> ''CANCELLED''
		AND  	fnba.batch_status_code <> ''COMPLETE''
		AND     fnba.batch_status_code <> ''REVERSED'')
	    AND fnc.org_id = :v_org_id1
	    AND rct.org_id = fnc.org_id
	    AND rctt.org_id = fnc.org_id
	    AND ((:v_sel_past_due_date1=''N'') OR (:v_sel_past_due_date2=''Y'' AND
						TRUNC(arps.due_date) + nvl(:v_days_past_due,0) < trunc(sysdate) ))
	    AND arps.org_id = fnc.org_id';
	   IF l_allow_disc_flag='N' THEN  					-- FOR NON ESD AGREEMENTS
	   	l_trx_where_clause := l_trx_where_clause ||  ' AND TRUNC(arps.due_date) <= trunc(:v_transaction_due_date)';
	   ELSE 								-- FOR ESD ENABLED AGREEMENTS, modified the where clause for selecting invoices which are elegible for discount
		l_trx_where_clause := l_trx_where_clause || ' AND ( arps.terms_sequence_number in (
                  select rtd.sequence_num
                  FROM ra_terms_lines_discounts rtd
                  where rtd.term_id = ARPS.TERM_ID
                  AND rtd.sequence_num = ARPS.TERMS_SEQUENCE_NUMBER
                  and (:v_transaction_due_date) <= ((arps.trx_date)+rtd.discount_days)) OR
                  (( (arps.due_date) <= (:v_transaction_due_date))))';
	   END IF;
	 fun_net_util.Log_String(g_state_level,l_path,'WHERE : '||l_trx_where_clause);
	/* Build the Group by clause */
	l_trx_group_by_clause :=
	    ' GROUP BY	rct.customer_trx_id,
		fnc.cust_priority ';
       IF g_net_order_rule = 'TRX_DATE' then
	    l_trx_group_by_clause := l_trx_group_by_clause ||
				     ',' ||
				     ' rct.trx_date ';
       END IF;
	/* l_trx_group_by_clause := l_trx_group_by_clause ||','||
	CASE g_net_order_rule
	    WHEN 'DUEDATE_OLD' THEN 'arps.due_date'
	    WHEN 'DUEDATE_RECENT' THEN 'arps.due_date'
	    WHEN 'AMOUNT_ASCENDING' THEN 'open_amount'
	    WHEN 'AMOUNT_DESCENDING' THEN 'open_amount'
	END; */
	fun_net_util.Log_String(g_state_level,l_path,'GROUP : '||l_trx_group_by_clause);
	/* Build the Order by clause */
	--Order by the Customer Priority  .If all the customers have the same priority =1,then use the netting order rule.
	l_trx_order_by_clause :=
	    ' ORDER BY fnc.cust_priority ';
	--Set the order by clause for netting order
	l_trx_order_by_clause := l_trx_order_by_clause ||','||
	CASE g_net_order_rule
	    WHEN 'DUEDATE_OLD' THEN 'min(arps.due_date) asc'
	    WHEN 'DUEDATE_RECENT' THEN 'min(arps.due_date) desc'
	    WHEN 'AMOUNT_ASCENDING' THEN 'sum(arps.amount_due_remaining) asc'
	    WHEN 'AMOUNT_DESCENDING' THEN 'sum(arps.amount_due_remaining) desc'
	    WHEN 'TRX_DATE' THEN  'rct.trx_date asc'
	END;
	fun_net_util.Log_String(g_state_level,l_path,'ORDER : '||l_trx_order_by_clause);
	/* Select the transactions with currency specified in the agreement if the netting currency rule is Single currency */
       fun_net_util.Log_String(g_state_level,l_path,'currency rule :'||g_net_currency_rule);
	IF g_net_currency_rule = 'SINGLE_CURRENCY' THEN
	    l_trx_where_clause  := l_trx_where_clause || ' AND RCT.INVOICE_CURRENCY_CODE = :v_currency' ;
	    fun_net_util.Log_String(g_state_level,l_path,'SELECT : '||l_trx_select_clause);
	    fun_net_util.Log_String(g_state_level,l_path,'FROM : '||l_trx_from_clause);
	    fun_net_util.Log_String(g_state_level,l_path,'WHERE : '||l_trx_where_clause);
	    fun_net_util.Log_String(g_state_level,l_path,'GROUP : '||l_trx_group_by_clause);
	    fun_net_util.Log_String(g_state_level,l_path,'ORDER : '||l_trx_order_by_clause);
	    l_sql_stmt := l_trx_select_clause || l_trx_from_clause || l_trx_where_clause || l_trx_group_by_clause || l_trx_order_by_clause ;
	    insert_transactions(l_sql_stmt , g_net_currency, 'AR');
	ELSIF g_net_currency_rule = 'ACCOUNTING_CURRENCY' THEN
	    --Select all the invoices irrespective of the currency code and call GL API to convert the amount from the invoice currency to the accounting currency
	       fun_net_util.Log_String(g_state_level,l_path,'g_batch_details.exchange_rate_type :' ||g_batch_details.exchange_rate_type);
	    IF l_allow_disc_flag='N' THEN          				-- FOR NON ESD AGREEMENTS
		 l_trx_select_clause :=
		    'SELECT	rct.customer_trx_id,
			fun_net_arap_pkg.Calculate_ar_trx_amt(rct.customer_trx_id) transaction_amount,
				 gl_currency_api.convert_closest_amount_sql(rct.invoice_currency_code,
								:batch_currency,
								trunc(:SETTLEMENT_DATE),
								:exchange_rate_type,
								:exchange_rate,
								sum(arps.amount_due_remaining),
								:max_roll_days) AS open_amount,
			sum(arps.amount_due_remaining) AS txn_curr_open_amt ' ;
	    ELSE								-- FOR ESD ENABLED AGREEMENTS,Calculating OPEN_AMOUNT_AFTERDISC for ESD enabled Agreements
	    	 l_trx_select_clause :=
		    'SELECT	rct.customer_trx_id,
			fun_net_arap_pkg.Calculate_ar_trx_amt(rct.customer_trx_id) transaction_amount,
				 gl_currency_api.convert_closest_amount_sql(rct.invoice_currency_code,
								:batch_currency,
								trunc(:SETTLEMENT_DATE),
								:exchange_rate_type,
								:exchange_rate,
								sum(arps.amount_due_remaining),
								:max_roll_days) AS open_amount,
			sum(arps.amount_due_remaining) AS txn_curr_open_amt,
			((gl_currency_api.convert_closest_amount_sql(rct.invoice_currency_code,:batch_currency,trunc(:SETTLEMENT_DATE),:exchange_rate_type,:exchange_rate,SUM(arps.amount_due_remaining),:max_roll_days))
              -(gl_currency_api.convert_closest_amount_sql(rct.invoice_currency_code,:batch_currency,trunc(:SETTLEMENT_DATE),:exchange_rate_type,:exchange_rate,
	      SUM(ARP_DISCOUNTS_API.Get_Available_Disc_On_Inv(arps.PAYMENT_SCHEDULE_ID,:SETTLEMENT_DATE,NULL)),:max_roll_days))) AS OPEN_AMOUNT_AFTERDISC,
			sum(arps.amount_due_remaining - ARP_DISCOUNTS_API.Get_Available_Disc_On_Inv(arps.PAYMENT_SCHEDULE_ID,:SETTLEMENT_DATE,NULL)) AS TXN_CURR_OPEN_AMOUNT_AFTERDISC';   -- ADDED FOR ESD ENABLED AGREEMENTS
	    END IF;
	    l_trx_group_by_clause := l_trx_group_by_clause ||
				     ',' ||
				     ' rct.invoice_currency_code ';
	    fun_net_util.Log_String(g_state_level,l_path,'SELECT : '||l_trx_select_clause);
	    fun_net_util.Log_String(g_state_level,l_path,'FROM : '||l_trx_from_clause);
	    fun_net_util.Log_String(g_state_level,l_path,'WHERE : '||l_trx_where_clause);
	    fun_net_util.Log_String(g_state_level,l_path,'GROUP : '||l_trx_group_by_clause);
	    fun_net_util.Log_String(g_state_level,l_path,'ORDER : '||l_trx_order_by_clause);
	    l_sql_stmt := l_trx_select_clause || l_trx_from_clause || l_trx_where_clause || l_trx_group_by_clause || l_trx_order_by_clause;
	    fun_net_util.Log_String(g_state_level,l_path,substr(l_sql_stmt,1,2000));
	    fun_net_util.Log_String(g_state_level,l_path,substr(l_sql_stmt,2001,2000));
	    insert_transactions(l_sql_stmt , g_func_currency, 'AR');
	ELSIF g_net_currency_rule = 'WITHIN_CURRENCY' THEN
	    l_sql_stmt := 'SELECT DISTINCT RCT.INVOICE_CURRENCY_CODE CURRENCY_CODE ' || l_trx_from_clause || l_trx_where_clause ;
	    --Select the currencies in a cursor
	    l_trx_where_clause := l_trx_where_clause  || ' AND RCT.INVOICE_CURRENCY_CODE = :v_currency ';
	    IF l_allow_disc_flag='N' THEN          				-- FOR NON ESD AGREEMENTS
		    OPEN trx_cur FOR l_sql_stmt USING 	g_agr_start_date,
							g_agr_end_date,
							g_agreement_id,
							g_agreement_id,
							g_batch_details.org_id,
							g_sel_past_due_flag,
							g_sel_past_due_flag,
							g_days_past_due,
							g_batch_details.transaction_due_date;
	   ELSE									-- FOR ESD ENABLED AGREEMENTS
		    OPEN trx_cur FOR l_sql_stmt USING 	g_agr_start_date,
							g_agr_end_date,
							g_agreement_id,
							g_agreement_id,
							g_batch_details.org_id,
							g_sel_past_due_flag,
							g_sel_past_due_flag,
							g_days_past_due,
							g_batch_details.transaction_due_date,
							g_batch_details.transaction_due_date;
          END IF;
	  LOOP
	    FETCH trx_cur INTO l_currency_code ;
		EXIT WHEN trx_cur%NOTFOUND;
		--Set the select where clause to select all transactions belonging to the cursor currency, as shown above in the first if condition.
		g_currency_count :=  g_currency_count + 1;
		fun_net_util.Log_String(g_state_level,l_path,'SELECT : '||l_trx_select_clause);
		fun_net_util.Log_String(g_state_level,l_path,'FROM : '||l_trx_from_clause);
		fun_net_util.Log_String(g_state_level,l_path,'WHERE : '||l_trx_where_clause);
		fun_net_util.Log_String(g_state_level,l_path,'GROUP : '||l_trx_group_by_clause);
		fun_net_util.Log_String(g_state_level,l_path,'ORDER : '||l_trx_order_by_clause);
		l_sql_stmt := l_trx_select_clause || l_trx_from_clause || l_trx_where_clause || l_trx_group_by_clause || l_trx_order_by_clause;
		insert_transactions (l_sql_stmt , l_currency_code, 'AR');
	    END LOOP;
	    CLOSE trx_cur;
	END IF; -- Currency
	RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            fun_net_util.Log_String(g_proc_level,l_path,'EXCEPTION : '||sqlerrm);
            RETURN FALSE;
    END prepare_ar_transactions;
    FUNCTION prepare_ap_transactions RETURN BOOLEAN IS
        l_inv_select_clause     VARCHAR2(2000);
        l_inv_from_clause       VARCHAR2(2000);
        l_inv_where_clause      VARCHAR2(2000);
        l_inv_group_by_clause   VARCHAR2(2000);
        l_inv_order_by_clause   VARCHAR2(2000);
        l_sql_stmt              VARCHAR2(4000);
        TYPE InvCurTyp IS REF CURSOR;
        inv_cur InvCurTyp;
        l_currency_code         VARCHAR2(15);
        l_path                  VARCHAR2(100);
    BEGIN
        l_path      := g_path || 'Prepare_AP_Transactions';
        fun_net_util.Log_String(g_proc_level,l_path,'Preparing AP Transactions');
	SELECT ALLOW_DISC_FLAG into l_allow_disc_flag FROM FUN_NET_AGREEMENTS_all WHERE Agreement_id=g_agreement_id;
		IF l_allow_disc_flag='N' THEN          				-- FOR NON ESD AGREEMENTS
			/* Build the select clause */
			l_inv_select_clause :=
			    -- Select all ap_invoices based on the batch id
				'SELECT
				    api.invoice_id,
				    api.invoice_amount AS transaction_amount,
				    SUM(aps.amount_remaining) AS open_amount,
				    min(aps.payment_num),
				    max(aps.payment_num) ';
		ELSE   								-- FOR ESD ENABLED AGREEMENTS, Calculating OPEN_AMOUNT_AFTERDISC for ESD enabled Agreements
			l_inv_select_clause :=
			    -- Select all ap_invoices based on the batch id
				'SELECT
				    api.invoice_id,
				    api.invoice_amount AS transaction_amount,
				    SUM(aps.amount_remaining) AS open_amount,
				    min(aps.payment_num),
				    max(aps.payment_num),
				    sum(aps.amount_remaining - AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Pmt_Schedule(api.invoice_id,aps.payment_num,:SETTLEMENT_DATE)) AS OPEN_AMOUNT_AFTERDISC';
		END IF;
			fun_net_util.Log_String(g_state_level,l_path,'SELECT : '||l_inv_select_clause);
			/* Build the from clause */
			l_inv_from_clause :=
				' FROM ap_invoices_all api,
				    fun_net_suppliers_all fns,
				    ap_payment_schedules_all aps';
			fun_net_util.Log_String(g_state_level,l_path,'FROM : '||l_inv_from_clause);
			/* Build where clause */
			/* Do not select invoices that are on hold */
			/* Select invoices that have been approved */
			/* Select the invoices whose invoice types have been defined in the agreement */
			/* Select only invoices where the transaction due date is on or before the Transaction Due date in the Batch */
			/* Select transactions where the transactions due deate is between the start and end dates of the agreement */
			/* Do not select invoices that are already selected in another batch where the batch status is not COMPLETE */
			IF l_allow_disc_flag='N' THEN          			-- FOR NON ESD Agreements
				l_inv_where_clause :=
					' WHERE api.invoice_id = aps.invoice_id
					AND	aps.hold_flag = ''N''
					AND	aps.payment_status_flag <> ''Y''
					AND ap_invoices_pkg.get_approval_status(api.invoice_id,
									api.invoice_amount,
									api.payment_status_flag,
									api.invoice_type_lookup_code) = ''APPROVED''
					AND (AP_INVOICES_PKG.Get_WFapproval_Status(api.invoice_id,api.org_id) = ''NOT REQUIRED'' OR
					AP_INVOICES_PKG.Get_WFapproval_Status(api.invoice_id,api.org_id)=''APPROVED'' OR
					AP_INVOICES_PKG.Get_WFapproval_Status(api.invoice_id,api.org_id)=''MANUALLY APPROVED'' OR
					AP_INVOICES_PKG.Get_WFapproval_Status(api.invoice_id,api.org_id)=''WFAPPROVED'')
					AND	fns.agreement_id = :v_agreement_id1
					AND	fns.supplier_id = api.vendor_id
					AND	NVL(fns.supplier_site_id, api.vendor_site_id)= api.vendor_site_id
					AND	EXISTS
					    (SELECT ''X''
					    FROM   fun_net_ap_inv_types_all fnai
					    WHERE fnai.invoice_type = api.invoice_type_lookup_code
					    AND    fnai.agreement_id = :v_agreement_id2)
					AND TRUNC(aps.due_date) <= TRUNC(:v_transaction_due_date)
					AND TRUNC(aps.due_date) BETWEEN TRUNC(:v_agr_start_date)
					       AND TRUNC(:v_agr_end_date)
					AND	 NOT EXISTS
					    (SELECT ''X''
					    FROM  	fun_net_ap_invs_all fnap,
						fun_net_batches_all fnba
					    WHERE fnap.invoice_id = api.invoice_id
					    AND   fnap.batch_id = fnba.batch_id
					    AND   fnba.batch_status_code <> ''CANCELLED''
					    AND   fnba.batch_status_code <> ''COMPLETE''
					    AND   fnba.batch_status_code <> ''REVERSED'')
					AND fns.org_id = :v_org_id
					AND api.org_id = fns.org_id
					AND aps.org_id = fns.org_id';
				ELSE   						-- FOR ESD Enabled Agreements, added logic for pullling invoices which are elegible for discount
					l_inv_where_clause :=
					' WHERE api.invoice_id = aps.invoice_id
					AND	aps.hold_flag = ''N''
					AND	aps.payment_status_flag <> ''Y''
					AND ap_invoices_pkg.get_approval_status(api.invoice_id,
									api.invoice_amount,
									api.payment_status_flag,
									api.invoice_type_lookup_code) = ''APPROVED''
					AND (AP_INVOICES_PKG.Get_WFapproval_Status(api.invoice_id,api.org_id) = ''NOT REQUIRED'' OR
					AP_INVOICES_PKG.Get_WFapproval_Status(api.invoice_id,api.org_id)=''APPROVED'' OR
					AP_INVOICES_PKG.Get_WFapproval_Status(api.invoice_id,api.org_id)=''MANUALLY APPROVED'' OR
					AP_INVOICES_PKG.Get_WFapproval_Status(api.invoice_id,api.org_id)=''WFAPPROVED'')
					AND	fns.agreement_id = :v_agreement_id1
					AND	fns.supplier_id = api.vendor_id
					AND	NVL(fns.supplier_site_id, api.vendor_site_id)= api.vendor_site_id
					AND	EXISTS
					    (SELECT ''X''
					    FROM   fun_net_ap_inv_types_all fnai
					    WHERE fnai.invoice_type = api.invoice_type_lookup_code
					   AND    fnai.agreement_id = :v_agreement_id2)
					   AND ( (TRUNC(aps.due_date) <= TRUNC(:v_transaction_due_date)) or (TRUNC(aps.discount_date) >= TRUNC(:v_transaction_due_date))
    or (TRUNC(aps.second_discount_date) >= TRUNC(:v_transaction_due_date)) or (TRUNC(aps.third_discount_date) >= TRUNC(:v_transaction_due_date)))
    					  AND TRUNC(aps.due_date) BETWEEN TRUNC(:v_agr_start_date)
					       AND TRUNC(:v_agr_end_date)
					AND	 NOT EXISTS
					    (SELECT ''X''
					    FROM  	fun_net_ap_invs_all fnap,
						fun_net_batches_all fnba
					    WHERE fnap.invoice_id = api.invoice_id
					    AND   fnap.batch_id = fnba.batch_id
					    AND   fnba.batch_status_code <> ''CANCELLED''
					    AND   fnba.batch_status_code <> ''COMPLETE''
					    AND   fnba.batch_status_code <> ''REVERSED'')
					AND fns.org_id = :v_org_id
					AND api.org_id = fns.org_id
					AND aps.org_id = fns.org_id';
				END IF;
			/* Check Shikyu rule code on the Agreement
			Y - "Yes" -  Only invoices lines that were matched to PO lines with the OSA flag checked are selected for Netting
			N - "No" -Only invoices lines that were matched to PO lines with the OSA flag not checked are selected for Netting
			D - "Disregard"- All AP invoices selected for Netting; no filtering, therefore will select everything, as if the profile is "Off"
			null value - if that scenario is met should be the same as disregard */
			IF g_shikyu_rule = 'Y' THEN
			    l_inv_where_clause  := l_inv_where_clause ||  ' AND  JMF_SHIKYU_GRP.Is_AP_Inv_Shikyu_Nettable_func(api.invoice_id) = ''Y'' ';
			ElSIF g_shikyu_rule = 'N' THEN
			 l_inv_where_clause  := l_inv_where_clause ||  ' AND  JMF_SHIKYU_GRP.Is_AP_Inv_Shikyu_Nettable_func(API.invoice_id) = ''N'' ';
			l_inv_where_clause := l_inv_where_clause ||  ' AND EXISTS ' || ' (SELECT apd.distribution_line_number '|| '  FROM   ap_invoice_distributions_all apd '|| 'WHERE apd.invoice_id = api.invoice_id '|| 'AND apd.po_distribution_id IS NOT NULL) ';
			END IF;
			fun_net_util.Log_String(g_state_level,l_path,'WHERE : '||l_inv_where_clause);
			/* Build the Group by Clause */
			l_inv_group_by_clause :=
				' GROUP BY	api.invoice_id,
				    api.invoice_amount,
				    fns.supplier_priority ';
		       IF g_net_order_rule = 'TRX_DATE' then
			    l_inv_group_by_clause := l_inv_group_by_clause ||','||
						     'api.invoice_date ';
		       END IF;
			/* l_inv_group_by_clause := l_inv_group_by_clause ||','||
			    CASE g_net_order_rule
				WHEN 'DUEDATE_OLD' THEN 'aps.due_date'
				WHEN 'DUEDATE_RECENT' THEN 'aps.due_date'
				WHEN 'AMOUNT_ASCENDING' THEN 'open_amount'
				WHEN 'AMOUNT_DESCENDING' THEN 'open_amount'
			    END; */
			fun_net_util.Log_String(g_state_level,l_path,'GROUP : '||l_inv_group_by_clause);
			/* Build the order by Clause . If the all the vendors priority  =1 , then use the netting order by rule */
			l_inv_order_by_clause :=
				' ORDER BY fns.supplier_priority,';
			l_inv_order_by_clause := l_inv_order_by_clause ||
			    CASE g_net_order_rule
				WHEN 'DUEDATE_OLD' THEN 'min(aps.due_date) asc'
				WHEN 'DUEDATE_RECENT' THEN 'min(aps.due_date) desc'
				WHEN 'AMOUNT_ASCENDING' THEN 'SUM(aps.amount_remaining) asc'
				WHEN 'AMOUNT_DESCENDING' THEN 'SUM(aps.amount_remaining) desc'
				WHEN 'TRX_DATE' THEN  'api.invoice_date asc'
			    END;
			fun_net_util.Log_String(g_state_level,l_path,'ORDER : '||l_inv_order_by_clause);
			fun_net_util.Log_String(g_state_level,l_path,'Net currency rule '||g_net_currency_rule);
			--Select only the transactions which have the currency code of the netting currency rule if the Netting currency rule = 'SINGLE_CURRENCY'
			IF g_net_currency_rule = 'SINGLE_CURRENCY' THEN
			    l_inv_where_clause := l_inv_where_clause ||  ' AND API.INVOICE_CURRENCY_CODE = :v_currency' ;
			    /* Build the entire select statement */
			    fun_net_util.Log_String(g_state_level,l_path,'SELECT : '||l_inv_select_clause);
			    fun_net_util.Log_String(g_state_level,l_path,'FROM : '||l_inv_from_clause);
			    fun_net_util.Log_String(g_state_level,l_path,'WHERE : '||l_inv_where_clause);
			    fun_net_util.Log_String(g_state_level,l_path,'GROUP : '||l_inv_group_by_clause);
			    fun_net_util.Log_String(g_state_level,l_path,'ORDER : '||l_inv_order_by_clause);
			    l_sql_stmt :=
				    l_inv_select_clause  || l_inv_from_clause || l_inv_where_clause || l_inv_group_by_clause || l_inv_order_by_clause ;
			    /* Call the procedure to insert AP netting transactions */
			    insert_transactions(l_sql_stmt , g_net_currency, 'AP');
			ELSIF g_net_currency_rule = 'ACCOUNTING_CURRENCY'  THEN
			   IF l_allow_disc_flag='N' THEN          		-- FOR NON ESD Agreements
				    --Select all the invoices irrespective of the currency code
				    l_inv_select_clause := 'SELECT
							       api.invoice_id,
							       api.invoice_amount as transaction_amount,
								nvl(api.exchange_rate,1),
								fc.precision,
								SUM(aps.amount_remaining),
						 gl_currency_api.convert_closest_amount_sql(api.invoice_currency_code,
										:batch_currency,
										trunc(:SETTLEMENT_DATE),
										:exchange_rate_type,
										:exchange_rate,
										SUM(aps.amount_remaining),
										:max_roll_days) AS open_amount,
								min(aps.payment_num),
								max(aps.payment_num) ';
			  ELSE							-- FOR ESD Enabled Agreements
			      	--Select all the invoices irrespective of the currency code
				    l_inv_select_clause := 'SELECT
							       api.invoice_id,
							       api.invoice_amount as transaction_amount,
								nvl(api.exchange_rate,1),
								fc.precision,
								SUM(aps.amount_remaining),
						 gl_currency_api.convert_closest_amount_sql(api.invoice_currency_code,
										:batch_currency,
										trunc(:SETTLEMENT_DATE),
										:exchange_rate_type,
										:exchange_rate,
										SUM(aps.amount_remaining),
										:max_roll_days) AS open_amount,
								min(aps.payment_num),
								max(aps.payment_num),
								((gl_currency_api.convert_closest_amount_sql(api.invoice_currency_code,:batch_currency,trunc(:SETTLEMENT_DATE),:exchange_rate_type,:exchange_rate,SUM(aps.amount_remaining),:max_roll_days))
								  -(gl_currency_api.convert_closest_amount_sql(api.invoice_currency_code,:batch_currency,trunc(:SETTLEMENT_DATE),:exchange_rate_type,:exchange_rate,
								  SUM(AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Pmt_Schedule(api.invoice_id,aps.payment_num,to_date(:SETTLEMENT_DATE))),:max_roll_days))) OPEN_AMOUNT_AFTERDISC,
								sum(aps.amount_remaining - AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Pmt_Schedule(api.invoice_id,aps.payment_num,:SETTLEMENT_DATE)) AS TXN_CURR_OPEN_AMOUNT_AFTERDISC';
			  END IF;
			    l_inv_from_clause := l_inv_from_clause || ', fnd_currencies fc ';
			    l_inv_where_clause := l_inv_where_clause || ' AND api.invoice_currency_code = fc.currency_code ';
			    l_inv_group_by_clause := ' GROUP BY api.invoice_id,
				    api.invoice_amount,
				    nvl(api.exchange_rate,1),
				    api.invoice_currency_code,
				    fc.precision,
				    fns.supplier_priority ';
			    /* Build the entire select statement */
			    fun_net_util.Log_String(g_state_level,l_path,'SELECT : '||l_inv_select_clause);
			    fun_net_util.Log_String(g_state_level,l_path,'FROM : '||l_inv_from_clause);
			    fun_net_util.Log_String(g_state_level,l_path,'WHERE : '||l_inv_where_clause);
			    fun_net_util.Log_String(g_state_level,l_path,'GROUP : '||l_inv_group_by_clause);
			    fun_net_util.Log_String(g_state_level,l_path,'ORDER : '||l_inv_order_by_clause);
			    l_sql_stmt := l_inv_select_clause || l_inv_from_clause || l_inv_where_clause || l_inv_group_by_clause || l_inv_order_by_clause ;
			    fun_net_util.Log_String(g_state_level,l_path,substr(l_sql_stmt,1,2000));
			    fun_net_util.Log_String(g_state_level,l_path,substr(l_sql_stmt,2001,2000));
			    insert_transactions(l_sql_stmt, g_func_currency, 'AP');
			ELSIF g_net_currency_rule = 'WITHIN_CURRENCY' THEN
			    l_sql_stmt := 'SELECT DISTINCT api.invoice_currency_code ' || l_inv_from_clause || l_inv_where_clause ;
			    l_inv_where_clause := l_inv_where_clause  || ' AND api.invoice_currency_code = :v_currency ';
			    --Select the currencies in a cursor
			    IF l_allow_disc_flag='N' THEN          		-- FOR NON ESD Agreements
				    OPEN inv_cur FOR l_sql_stmt USING g_agreement_id,
									g_agreement_id,
									g_batch_details.transaction_due_date,
									g_agr_start_date,
									g_agr_end_date,
									g_batch_details.org_id;
       			    ELSE 						-- FOR ESD Enabled Agreements
			    	    OPEN inv_cur FOR l_sql_stmt USING g_agreement_id,
									g_agreement_id,
									g_batch_details.transaction_due_date,
									g_batch_details.transaction_due_date,
									g_batch_details.transaction_due_date,
									g_batch_details.transaction_due_date,
									g_agr_start_date,
									g_agr_end_date,
									g_batch_details.org_id;
			    END IF;
			    LOOP
				FETCH inv_cur INTO l_currency_code ;
				EXIT WHEN inv_cur%NOTFOUND;
				g_currency_count := g_currency_count + 1;
				--Set the select where clause to select all transactions belonging to the cursor currency, as shown above in the first if condition.
				fun_net_util.Log_String(g_state_level,l_path,'SELECT : '||l_inv_select_clause);
				fun_net_util.Log_String(g_state_level,l_path,'FROM : '||l_inv_from_clause);
				fun_net_util.Log_String(g_state_level,l_path,'WHERE : '||l_inv_where_clause);
				fun_net_util.Log_String(g_state_level,l_path,'GROUP : '||l_inv_group_by_clause);
				fun_net_util.Log_String(g_state_level,l_path,'ORDER : '||l_inv_order_by_clause);
				l_sql_stmt := l_inv_select_clause || l_inv_from_clause || l_inv_where_clause || l_inv_group_by_clause || l_inv_order_by_clause ;
				insert_transactions(l_sql_stmt , l_currency_code, 'AP');
			    END LOOP;
			    CLOSE inv_cur;
			END IF ; -- Currency
			RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            fun_net_util.Log_String(g_proc_level,l_path,'EXCEPTION : '||sqlerrm);
            RETURN FALSE;
    END prepare_ap_transactions;
/* Locks Payment Schedule lines */
    PROCEDURE lock_ap_pymt_schedules(
				p_batch_id  IN fun_net_batches.batch_id%TYPE,
                p_trx_due_date  IN fun_net_batches.transaction_due_date%TYPE,
    	        p_schd_tab	IN pymt_sch_tab,
                x_return_status OUT NOCOPY  VARCHAR2)
    IS
    l_checkrun_id ap_inv_selection_criteria_all.checkrun_id%TYPE;
    l_path      VARCHAR2(100);
    BEGIN
        l_path := g_path || 'lock_ap_pymt_schedules';
        fun_net_util.Log_String(g_state_level,l_path,'Start of locking');
      x_return_status := FND_API.G_TRUE;
        fun_net_util.Log_String(g_state_level,l_path,'p_schd_tab.count :'||p_schd_tab.count);
        fun_net_util.Log_String(g_state_level,l_path,'p_batch_id :'||p_batch_id);
      -- Check for Mandatory Parameters
	  	IF p_schd_tab.count = 0 OR p_batch_id IS NULL THEN
	  		x_return_status := FND_API.G_FALSE;
	  		RETURN;
	  	END IF;
		--AND TRUNC(due_date) <= NVL(p_trx_due_date,TRUNC(due_date))
        select checkrun_id
	INTO l_checkrun_id
	from FUN_NET_BATCHES_ALL
        WHERE batch_id = p_batch_id;
	-- Bug:8234111.
        -- Update AP Payment Schedules with the Checkrun id
        FOR i in 1..p_schd_tab.COUNT LOOP
	        UPDATE AP_PAYMENT_SCHEDULES aps
    	    SET checkrun_id = l_checkrun_id
       	    WHERE aps.invoice_id = p_schd_tab(i).invoice_id
            AND amount_remaining <> 0
	    AND ((get_esd_flag(g_batch_details.batch_id)='Y'  AND ( (TRUNC(aps.due_date) <= TRUNC(p_trx_due_date)) or (TRUNC(aps.discount_date) >= TRUNC(p_trx_due_date))
    or (TRUNC(aps.second_discount_date) >= TRUNC(p_trx_due_date)) or (TRUNC(aps.third_discount_date) >= TRUNC(p_trx_due_date))))
    OR (get_esd_flag(g_batch_details.batch_id)='N' AND TRUNC(due_date) <= NVL(p_trx_due_date,TRUNC(due_date))))
            AND aps.payment_num BETWEEN p_schd_tab(i).min_payment_num
                                    AND p_schd_tab(i).max_payment_num;
            fun_net_util.Log_String(g_state_level,l_path,'invoice_id :'||p_schd_tab(i).invoice_id);
            fun_net_util.Log_String(g_state_level,l_path,'Min_payment_number :'||p_schd_tab(i).min_payment_num);
            fun_net_util.Log_String(g_state_level,l_path,'Max_payment_number :'||p_schd_tab(i).max_payment_num);
        END LOOP;
        fun_net_util.Log_String(g_state_level,l_path,'Payment schedules updated');
    EXCEPTION
         WHEN OTHERS THEN
        fun_net_util.Log_String(g_state_level,l_path,'Failure in locking ap payment schedules');
            x_return_status := FND_API.G_FALSE;
    END lock_ap_pymt_schedules;
    PROCEDURE insert_transactions(p_inv_cur VARCHAR2,p_currency_code VARCHAR2, p_appln VARCHAR2) IS
        l_batch_exists  VARCHAR2(1);
        --l_inv_rank      NUMBER;
        TYPE InvCurTyp IS REF CURSOR;
        inv_rec InvCurTyp;
        TYPE amt_type IS TABLE OF fun_net_batches_all.total_netted_amt%TYPE INDEX BY BINARY_INTEGER;
        TYPE trx_type IS TABLE OF fun_net_ar_txns_all.customer_trx_id%TYPE INDEX BY BINARY_INTEGER;
        TYPE payment_num IS TABLE OF ap_payment_schedules_all.payment_num%TYPE INDEX BY BINARY_INTEGER;
        TYPE inv_rank IS TABLE OF fun_net_ap_invs_all.ap_txn_rank%TYPE INDEX BY BINARY_INTEGER;
        TYPE exchange_rate IS TABLE OF ap_invoices_all.exchange_rate%TYPE INDEX BY BINARY_INTEGER;
        TYPE precision_tab IS TABLE OF fnd_currencies.precision%TYPE INDEX BY BINARY_INTEGER;
        --l_invoice_id        fun_net_ap_invs_all.invoice_id%TYPE;
        --l_invoice_amt       fun_net_ap_invs_all.invoice_amt%TYPE;
        --l_open_amt          fun_net_ap_invs_all.open_amt%TYPE;
        --l_inv_curr_open_amt fun_net_ap_invs_all.inv_curr_open_amt%TYPE;
	l_OPEN_AMOUNT_AFTERDISC amt_type; -- FOR ESD Logic
	l_TC_OPEN_AMOUNT_AFTERDISC amt_type; -- FOR ESD Logic
        l_invoice_id        trx_type;
        l_invoice_amt       amt_type;
        l_open_amt          amt_type;
        l_inv_curr_open_amt amt_type;
        l_min_payment_num   payment_num;
        l_max_payment_num   payment_num;
        l_invoice_rank      inv_rank;
        l_exchange_rate     exchange_rate;
        l_precision         precision_tab;
        l_rank              NUMBER;
        l_pymt_sch_table    pymt_sch_tab;
        l_return_status     VARCHAR2(1);
        --l_customer_trx_id   fun_net_ar_txns_all.customer_trx_id%TYPE;
        --l_transaction_amt   fun_net_ar_txns_all.transaction_amt%TYPE;
        l_path              varchar2(100);
	l_checkrun_id ap_inv_selection_criteria_all.checkrun_id%TYPE;
    BEGIN
        l_path      := g_path || 'Insert_Transactions';
        fun_net_util.Log_String(g_state_level,l_path,substr(p_inv_cur,1,2000));
        fun_net_util.Log_String(g_state_level,l_path,substr(p_inv_cur,2001,2000));
        fun_net_util.Log_String(g_state_level,l_path,'Currency:'||p_currency_code);
        fun_net_util.Log_String(g_state_level,l_path,'Application:'||p_appln);
        fun_net_util.Log_String(g_state_level,l_path,'Currency rule: '||g_net_currency_rule);
        /* Check for mandatory parameters */
        IF p_inv_cur IS NULL OR p_currency_code IS NULL OR p_appln IS NULL THEN
            RETURN;
        END IF;
        fun_net_util.Log_String(g_state_level,l_path,'Agreement count:'||g_agreement_count);
        /* If this is the first agreement and the netting currency rule is as below then this will be the first group of tnxs to be parsed , need not create a batch as we can use the batch that already exists */
        IF g_agreement_count = 1 AND g_net_currency_rule IN ('SINGLE_CURRENCY','ACCOUNTING_CURRENCY') THEN
            fun_net_util.Log_String(g_state_level,l_path,'Setting currency code for first agreement');
            g_batch_list(g_idx).currency := p_currency_code;
        /* If the rule is 'NET WITHIN CURRENCY ' */
        ELSIF g_agreement_count = 1 AND g_net_currency_rule = 'WITHIN_CURRENCY' AND  g_currency_count =  1 THEN
            fun_net_util.Log_String(g_state_level,l_path,'Setting currency code for first currency and first agreement');
            g_batch_list(g_idx).currency := p_currency_code;
        ELSE    /* prow_count > 1 or if this is not the first agreement then */
            fun_net_util.Log_String(g_state_level,l_path,'Checking if batch already exists');
            IF NOT batch_exists(p_currency_code) THEN
                fun_net_util.Log_String(g_state_level,l_path,'Batch does not exist. Creating new batch');
                insert_batch_record(p_currency_code);
                g_idx := g_idx + 1;
                g_batch_list(g_idx).batch_id := g_batch_id;
                g_batch_list(g_idx).agreement_id := g_agreement_id;
                g_batch_list(g_idx).currency := p_currency_code;
            END IF;
        END IF ;
	select checkrun_id
	INTO l_checkrun_id
	from FUN_NET_BATCHES_ALL
	WHERE batch_id = g_batch_id;
	IF l_checkrun_id is NULL THEN
	        SELECT ap_inv_selection_criteria_s.nextval
		INTO l_checkrun_id
		FROM dual;
		fun_net_util.Log_String(g_state_level,l_path,'l_checkrun_id :'||l_checkrun_id);
		-- Update  Netting Batch with the Checkrun id
		UPDATE FUN_NET_BATCHES_ALL
		SET checkrun_id = l_checkrun_id
		WHERE batch_id = g_batch_id;
		fun_net_util.Log_String(g_state_level,l_path,'Batch updated');
	END IF;
        fun_net_util.Log_String(g_state_level,l_path,'Inserting invoices into Netting tables');
        l_rank := 0;
        IF  p_appln = 'AP' AND g_net_currency_rule IN ('SINGLE_CURRENCY', 'WITHIN_CURRENCY') THEN
            fun_net_util.Log_String(g_state_level,l_path,'Fetching the AP invoices');
             IF l_allow_disc_flag='Y' THEN	                                -- FOR ESD Enabled Agreements
	     	OPEN inv_rec FOR p_inv_cur USING g_batch_details.SETTLEMENT_DATE,
		                                g_agreement_id,
                                                g_agreement_id,
                                                g_batch_details.transaction_due_date,
						g_batch_details.transaction_due_date,
						g_batch_details.transaction_due_date,
						g_batch_details.transaction_due_date,
                                                g_agr_start_date,
                                                g_agr_end_date,
                                                g_batch_details.org_id,
                                                p_currency_code;
		fun_net_util.Log_String(g_state_level,l_path,'Fetching the AP invoices 1');
		FETCH inv_rec BULK COLLECT INTO l_invoice_id, l_invoice_amt, l_open_amt, l_min_payment_num,l_max_payment_num,l_OPEN_AMOUNT_AFTERDISC;
		fun_net_util.Log_String(g_state_level,l_path,'Fetching the AP invoices 2');
             ELSE                                                               -- FOR NON ESD Agreements
	      	OPEN inv_rec FOR p_inv_cur USING    g_agreement_id,
                                                g_agreement_id,
                                                g_batch_details.transaction_due_date,
                                                g_agr_start_date,
                                                g_agr_end_date,
                                                g_batch_details.org_id,
                                                p_currency_code;
		fun_net_util.Log_String(g_state_level,l_path,'Fetching the AP invoices 1');
		FETCH inv_rec BULK COLLECT INTO l_invoice_id, l_invoice_amt, l_open_amt, l_min_payment_num,l_max_payment_num;
		fun_net_util.Log_String(g_state_level,l_path,'Fetching the AP invoices 2');
             END IF;
            FOR i IN 1..l_invoice_id.COUNT
            LOOP
	    	fun_net_util.Log_String(g_state_level,l_path,'Fetching.........' || i);
                l_rank := l_rank + 1;
                l_invoice_rank(i) := l_rank;
                l_pymt_sch_table(i).invoice_id := l_invoice_id(i);
                l_pymt_sch_table(i).min_payment_num := l_min_payment_num(i);
                l_pymt_sch_table(i).max_payment_num := l_max_payment_num(i);
            END LOOP;
	    fun_net_util.Log_String(g_state_level,l_path,'Calling lock_ap_pymt_schedules for batch id:'||g_batch_id);
            lock_ap_pymt_schedules(
				p_batch_id  => g_batch_id,
              p_trx_due_date => g_batch_details.transaction_due_date,
    	        p_schd_tab	=> l_pymt_sch_table,
                x_return_status => l_return_status);
          IF l_allow_disc_flag='Y' THEN
            FORALL i IN 1..l_invoice_id.COUNT
            --LOOP
                    --FETCH inv_rec INTO  l_invoice_id,
                      --                  l_invoice_amt,
                        --                l_open_amt;
                    --EXIT WHEN inv_rec%NOTFOUND;
                    --l_inv_rank(i) := i;
                    --fun_net_util.Log_String(g_state_level,l_path,'Invoice ID:'||l_invoice_id);
		    --fun_net_util.Log_String(g_state_level,l_path,'Fetching the AP invoices batch _id=');
                    INSERT INTO fun_net_ap_invs_all
                                    (batch_id,
                                        invoice_id,
                                        object_version_number,
                                        ap_txn_rank,
                                        invoice_amt,
                                        open_amt,
                                        inv_curr_open_amt,
					open_amount_afterdisc,
					TXN_CURR_OPEN_AMOUNT_AFTERDISC,
                                        org_id,
                                        creation_date,
                                        created_by,
                                        last_update_date,
                                        last_updated_by,
                                        last_update_login)
                            VALUES
                                    (g_batch_id,
                                        l_invoice_id(i),
                                        1,
                                        l_invoice_rank(i),
                                        l_invoice_amt(i),
                                        l_open_amt(i),
                                        l_open_amt(i),
					l_OPEN_AMOUNT_AFTERDISC(i),
					l_OPEN_AMOUNT_AFTERDISC(i),
                                        g_batch_details.org_id,
                                        sysdate,
                                        g_user_id,
                                        sysdate,
                                        g_user_id,
                                        g_login_id);
				  CLOSE inv_rec;
			Else
			   FORALL i IN 1..l_invoice_id.COUNT
				INSERT INTO fun_net_ap_invs_all
                                    (batch_id,
                                        invoice_id,
                                        object_version_number,
                                        ap_txn_rank,
                                        invoice_amt,
                                        open_amt,
                                        inv_curr_open_amt,
                                        org_id,
                                        creation_date,
                                        created_by,
                                        last_update_date,
                                        last_updated_by,
                                        last_update_login)
                                 VALUES
                                    (g_batch_id,
                                        l_invoice_id(i),
                                        1,
                                        l_invoice_rank(i),
                                        l_invoice_amt(i),
                                        l_open_amt(i),
                                        l_open_amt(i),
                                        g_batch_details.org_id,
                                        sysdate,
                                        g_user_id,
                                        sysdate,
                                        g_user_id,
                                        g_login_id);
				CLOSE inv_rec;
			END IF;
                --END LOOP;
        ELSIF  p_appln = 'AP' AND g_net_currency_rule IN ('ACCOUNTING_CURRENCY') THEN
            fun_net_util.Log_String(g_state_level,l_path,'Fetching the AP Invoices');
	    IF l_allow_disc_flag='Y' THEN	                                -- FOR ESD Enabled Agreements
	        fun_net_util.Log_String(g_state_level,l_path,'Inside IF');
		fun_net_util.Log_String(g_state_level,l_path,'jst b4 cursor');
		    OPEN inv_rec FOR p_inv_cur USING
							p_currency_code,
							g_batch_details.SETTLEMENT_DATE,
							g_batch_details.exchange_rate_type,
							g_batch_details.exchange_rate,
							0,
							p_currency_code,
							g_batch_details.SETTLEMENT_DATE,
							g_batch_details.exchange_rate_type,
							g_batch_details.exchange_rate,
							0,
							p_currency_code,
							g_batch_details.SETTLEMENT_DATE,
							g_batch_details.exchange_rate_type,
							g_batch_details.exchange_rate,
							g_batch_details.SETTLEMENT_DATE,
							0,
							g_batch_details.SETTLEMENT_DATE,
							g_agreement_id,
							g_agreement_id,
						        g_batch_details.transaction_due_date,
							g_batch_details.transaction_due_date,
							g_batch_details.transaction_due_date,
							g_batch_details.transaction_due_date,
							g_agr_start_date,
							g_agr_end_date,
							g_batch_details.org_id;
		    fun_net_util.Log_String(g_state_level,l_path,'jst b4 cursor fetch');
		    FETCH inv_rec BULK COLLECT INTO l_invoice_id, l_invoice_amt, l_exchange_rate,l_precision,l_inv_curr_open_amt,l_open_amt, l_min_payment_num,l_max_payment_num,l_OPEN_AMOUNT_AFTERDISC,l_TC_OPEN_AMOUNT_AFTERDISC;
		    fun_net_util.Log_String(g_state_level,l_path,'jst after cursor fetch');
	    ELSE
		    OPEN inv_rec FOR p_inv_cur USING
							p_currency_code,
							g_batch_details.SETTLEMENT_DATE,
							g_batch_details.exchange_rate_type,
							g_batch_details.exchange_rate,
							0,
							g_agreement_id,
							g_agreement_id,
						        g_batch_details.transaction_due_date,
							g_agr_start_date,
							g_agr_end_date,
							g_batch_details.org_id;
		    fun_net_util.Log_String(g_state_level,l_path,'jst b4 cursor fetch');
		    FETCH inv_rec BULK COLLECT INTO l_invoice_id, l_invoice_amt, l_exchange_rate,l_precision,l_inv_curr_open_amt,l_open_amt, l_min_payment_num,l_max_payment_num;
		    fun_net_util.Log_String(g_state_level,l_path,'jst after cursor fetch');
	    END IF;
            FOR i IN 1..l_invoice_id.COUNT
            LOOP
                l_rank := l_rank + 1;
                l_invoice_rank(i) := l_rank ;
                l_pymt_sch_table(i).invoice_id := l_invoice_id(i);
                l_pymt_sch_table(i).min_payment_num := l_min_payment_num(i);
                l_pymt_sch_table(i).max_payment_num := l_max_payment_num(i);
            END LOOP;
            lock_ap_pymt_schedules(
				p_batch_id  => g_batch_id,
                p_trx_due_date => g_batch_details.transaction_due_date,
    	        p_schd_tab	=> l_pymt_sch_table,
                x_return_status => l_return_status);
            fun_net_util.Log_String(g_state_level,l_path,'Jst after pymt schedules');
	    IF l_allow_disc_flag='Y' THEN
	    		FORALL i IN 1..l_invoice_id.COUNT
			--LOOP
			    --FETCH inv_rec INTO  l_invoice_id,
			      --                  l_invoice_amt,
				--                l_open_amt,
				  --              l_inv_curr_open_amt;
			    --EXIT WHEN inv_rec%NOTFOUND;
			    --l_inv_rank := l_inv_rank + 1;
			    --fun_net_util.Log_String(g_state_level,l_path,'Invoice ID:'||l_invoice_id);
			    INSERT INTO fun_net_ap_invs_all
					    (batch_id,
						invoice_id,
						object_version_number,
						ap_txn_rank,
						invoice_amt,
						open_amt,
						inv_curr_open_amt,
						open_amount_afterdisc,
						TXN_CURR_OPEN_AMOUNT_AFTERDISC,
						org_id,
						creation_date,
						created_by,
						last_update_date,
						last_updated_by,
						last_update_login)
				    VALUES
					    (g_batch_id,
						l_invoice_id(i),
						1,
						l_invoice_rank(i),
						l_invoice_amt(i),
						l_open_amt(i),
						l_inv_curr_open_amt(i),
						l_OPEN_AMOUNT_AFTERDISC(i),
						l_TC_OPEN_AMOUNT_AFTERDISC(i),
						g_batch_details.org_id,
						sysdate,
						g_user_id,
						sysdate,
						g_user_id,
						g_login_id);
			--END LOOP;
		    CLOSE inv_rec;
	    ELSE
		      FORALL i IN 1..l_invoice_id.COUNT
			--LOOP
			    --FETCH inv_rec INTO  l_invoice_id,
			      --                  l_invoice_amt,
				--                l_open_amt,
				  --              l_inv_curr_open_amt;
			    --EXIT WHEN inv_rec%NOTFOUND;
			    --l_inv_rank := l_inv_rank + 1;
			    --fun_net_util.Log_String(g_state_level,l_path,'Invoice ID:'||l_invoice_id);
			    INSERT INTO fun_net_ap_invs_all
					    (batch_id,
						invoice_id,
						object_version_number,
						ap_txn_rank,
						invoice_amt,
						open_amt,
						inv_curr_open_amt,
						org_id,
						creation_date,
						created_by,
						last_update_date,
						last_updated_by,
						last_update_login)
				    VALUES
					    (g_batch_id,
						l_invoice_id(i),
						1,
						l_invoice_rank(i),
						l_invoice_amt(i),
						l_open_amt(i),
						l_inv_curr_open_amt(i),
						g_batch_details.org_id,
						sysdate,
						g_user_id,
						sysdate,
						g_user_id,
						g_login_id);
			--END LOOP;
		    CLOSE inv_rec;
	    END IF;
        ELSIF p_appln = 'AR' AND g_net_currency_rule IN ('SINGLE_CURRENCY', 'WITHIN_CURRENCY') THEN
            fun_net_util.Log_String(g_state_level,l_path,'Fetching the AR Transactions');
    		IF l_allow_disc_flag='Y' THEN					-- FOR ESD Enabled Agreements
		    fun_net_util.Log_String(g_state_level,l_path,'Iside IF');
			OPEN inv_rec FOR p_inv_cur USING  g_batch_details.transaction_due_date,
                                                g_agr_start_date,
                                                g_agr_end_date,
                                                g_agreement_id,
                                                g_agreement_id,
                                                g_batch_details.org_id,
						g_sel_past_due_flag,
                                                g_sel_past_due_flag,
                                                g_days_past_due,
						g_batch_details.transaction_due_date,
						g_batch_details.transaction_due_date,
                                                p_currency_code;
                         fun_net_util.Log_String(g_state_level,l_path,'Before Fetch');
			FETCH inv_rec BULK COLLECT INTO l_invoice_id, l_invoice_amt, l_open_amt,l_OPEN_AMOUNT_AFTERDISC;
			 fun_net_util.Log_String(g_state_level,l_path,'After Fetch');
		ELSE								-- FOR NON ESD Agreements
			OPEN inv_rec FOR p_inv_cur USING g_agr_start_date,
                                                g_agr_end_date,
                                                g_agreement_id,
                                                g_agreement_id,
                                                g_batch_details.org_id,
						g_sel_past_due_flag,
                                                g_sel_past_due_flag,
                                                g_days_past_due,
                                                g_batch_details.transaction_due_date,
						p_currency_code;
			FETCH inv_rec BULK COLLECT INTO l_invoice_id, l_invoice_amt, l_open_amt;
	        END IF;
            FOR i IN 1..l_invoice_id.COUNT
            LOOP
                l_rank := l_rank + 1;
                l_invoice_rank(i) := l_rank ;
            END LOOP;
                --LOOP
                    --FETCH inv_rec INTO  l_customer_trx_id,
                      --                  l_transaction_amt,
                        --                l_open_amt;
                    --EXIT WHEN inv_rec%NOTFOUND;
                    --l_inv_rank := l_inv_rank + 1;
                    --fun_net_util.Log_String(g_state_level,l_path,'Transaction ID:'||l_customer_trx_id);
		 IF l_allow_disc_flag='Y' THEN 					-- FOR ESD Enabled Agreements
		    fun_net_util.Log_String(g_state_level,l_path,'Before Inserting');
		    FORALL i IN 1..l_invoice_id.COUNT
                    INSERT INTO fun_net_ar_txns_all
                                    (batch_id,
                                    customer_trx_id,
                                    object_version_number,
                                    ar_txn_rank,
                                    transaction_amt,
                                    open_amt,
                                    txn_curr_open_amt,
				    open_amount_afterdisc,
				    TXN_CURR_OPEN_AMOUNT_AFTERDISC,
                                    org_id,
                                    creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login)
                            VALUES
                                    (g_batch_id,
                                    l_invoice_id(i),
                                    1,
                                    l_invoice_rank(i),
                                    l_invoice_amt(i),
                                    l_open_amt(i),
                                    l_open_amt(i),
				    l_OPEN_AMOUNT_AFTERDISC(i),
				    l_OPEN_AMOUNT_AFTERDISC(i),
                                    g_batch_details.org_id,
                                    sysdate,
                                    g_user_id,
                                    sysdate,
                                    g_user_id,
                                    g_login_id);
			   CLOSE inv_rec;
		ELSE								-- FOR Non ESD Agreements
		         FORALL i IN 1..l_invoice_id.COUNT
			 INSERT INTO fun_net_ar_txns_all
                                    (batch_id,
                                    customer_trx_id,
                                    object_version_number,
                                    ar_txn_rank,
                                    transaction_amt,
                                    open_amt,
                                    txn_curr_open_amt,
                                    org_id,
                                    creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login)
                            VALUES
                                    (g_batch_id,
                                    l_invoice_id(i),
                                    1,
                                    l_invoice_rank(i),
                                    l_invoice_amt(i),
                                    l_open_amt(i),
                                    l_open_amt(i),
                                    g_batch_details.org_id,
                                    sysdate,
                                    g_user_id,
                                    sysdate,
                                    g_user_id,
                                    g_login_id);
			    CLOSE inv_rec;
                END IF;
                --END LOOP;
        ELSIF p_appln = 'AR' AND g_net_currency_rule IN ('ACCOUNTING_CURRENCY') THEN
            fun_net_util.Log_String(g_state_level,l_path,'Fetching the AR Transactions');
	    IF l_allow_disc_flag='Y' THEN					-- FOR ESD Enabled Agreements
	    fun_net_util.Log_String(g_state_level,l_path,'B4 cursor Execution');
	    	OPEN inv_rec FOR p_inv_cur USING
                                 		p_currency_code,
                                 		g_batch_details.SETTLEMENT_DATE,
                                 		g_batch_details.exchange_rate_type,
						g_batch_details.exchange_rate,
						0,
						p_currency_code,
						g_batch_details.SETTLEMENT_DATE,
						g_batch_details.exchange_rate_type,
						g_batch_details.exchange_rate,
						0,
						p_currency_code,
						g_batch_details.SETTLEMENT_DATE,
						g_batch_details.exchange_rate_type,
						g_batch_details.exchange_rate,
						g_batch_details.SETTLEMENT_DATE,
						0,
						g_batch_details.SETTLEMENT_DATE,
                                                g_agr_start_date,
                                                g_agr_end_date,
                                                g_agreement_id,
                                                g_agreement_id,
                                                g_batch_details.org_id,
						g_sel_past_due_flag,
						g_sel_past_due_flag,
						g_days_past_due,
						g_batch_details.transaction_due_date,
						g_batch_details.transaction_due_date;
              fun_net_util.Log_String(g_state_level,l_path,'B4 cursor fetch');
		FETCH inv_rec BULK COLLECT INTO l_invoice_id, l_invoice_amt, l_open_amt,l_inv_curr_open_amt,l_OPEN_AMOUNT_AFTERDISC,l_TC_OPEN_AMOUNT_AFTERDISC;
	     fun_net_util.Log_String(g_state_level,l_path,'After cursor fetch');
	   ELSE									-- FOR NON ESD Agreements
	   	OPEN inv_rec FOR p_inv_cur USING
                                 		p_currency_code,
                                 		g_batch_details.SETTLEMENT_DATE,
                                 		g_batch_details.exchange_rate_type,
						g_batch_details.exchange_rate,
						0,
                                                g_agr_start_date,
                                                g_agr_end_date,
                                                g_agreement_id,
                                                g_agreement_id,
                                                g_batch_details.org_id,
						g_sel_past_due_flag,
						g_sel_past_due_flag,
						g_days_past_due,
						g_batch_details.transaction_due_date;
		FETCH inv_rec BULK COLLECT INTO l_invoice_id, l_invoice_amt, l_open_amt,l_inv_curr_open_amt;
	   END IF;
            FOR i IN 1..l_invoice_id.COUNT
            LOOP
                l_rank := l_rank + 1;
                l_invoice_rank(i) := l_rank;
            END LOOP;
--                LOOP
  --                  FETCH inv_rec INTO  l_customer_trx_id,
    --                                    l_transaction_amt,
      --                                  l_open_amt,
        --                                l_inv_curr_open_amt;
          --          EXIT WHEN inv_rec%NOTFOUND;
            --        l_inv_rank := l_inv_rank + 1;
              --      fun_net_util.Log_String(g_state_level,l_path,'Transaction ID:'||l_customer_trx_id);
	      IF l_allow_disc_flag='Y' THEN					-- FOR ESD Enabled Agreements
	      fun_net_util.Log_String(g_state_level,l_path,'Inside IF condition');
	      FORALL i IN 1..l_invoice_id.COUNT
	                 INSERT INTO fun_net_ar_txns_all
                                    (batch_id,
                                    customer_trx_id,
                                    object_version_number,
                                    ar_txn_rank,
                                    transaction_amt,
                                    open_amt,
                                    txn_curr_open_amt,
				    open_amount_afterdisc,
				    TXN_CURR_OPEN_AMOUNT_AFTERDISC,
                                    org_id,
                                    creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login)
                            VALUES
                                    (g_batch_id,
                                    l_invoice_id(i),
                                    1,
                                    l_invoice_rank(i),
                                    l_invoice_amt(i),
                                    l_open_amt(i),
                                    l_inv_curr_open_amt(i),
				    l_OPEN_AMOUNT_AFTERDISC(i),
				    l_TC_OPEN_AMOUNT_AFTERDISC(i),
                                    g_batch_details.org_id,
                                    sysdate,
                                    g_user_id,
                                    sysdate,
                                    g_user_id,
                                    g_login_id);
		   CLOSE inv_rec;
	      ELSE								-- FOR NON ESD Agreements
	         FORALL i IN 1..l_invoice_id.COUNT
                    INSERT INTO fun_net_ar_txns_all
                                    (batch_id,
                                    customer_trx_id,
                                    object_version_number,
                                    ar_txn_rank,
                                    transaction_amt,
                                    open_amt,
                                    txn_curr_open_amt,
                                    org_id,
                                    creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login)
                            VALUES
                                    (g_batch_id,
                                    l_invoice_id(i),
                                    1,
                                    l_invoice_rank(i),
                                    l_invoice_amt(i),
                                    l_open_amt(i),
                                    l_inv_curr_open_amt(i),
                                    g_batch_details.org_id,
                                    sysdate,
                                    g_user_id,
                                    sysdate,
                                    g_user_id,
                                    g_login_id);
		CLOSE inv_rec;
	      END IF;
                --END LOOP;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            fun_net_util.Log_String(g_proc_level,l_path,'EXCEPTION : '||sqlerrm);
            NULL;
    END insert_transactions;
    /* ------------------ ADDED NEWLY FOR ESD --------------------*/
    /* SCAN THE TABLE FOR EVERY TRANSACTION SELECTED AND COMPUTE THE ACTUAL NETTED AMOUNT
    AND UPDATE THE APPROPRIATE AP AND AR FUN TABLES WITH THE APPLIED DISCOUNT AMOUNT */
    PROCEDURE update_net_balances_esd(p_sql_stmt VARCHAR2,
                                    p_amt_to_net NUMBER,
                                    p_appln VARCHAR2) IS
        TYPE amt_type IS TABLE OF fun_net_batches_all.total_netted_amt%TYPE index by pls_integer;
        TYPE trx_type IS TABLE OF fun_net_ar_txns_all.customer_trx_id%TYPE;
	l_open_amt_afterdisc amt_type;
	l_tc_open_amt_afterdisc amt_type;
	l_applieddisc amt_type;
        l_open_amt          amt_type;
	l_pmtno 	 amt_type;
	l_amt_remaining  amt_type;
        l_exc_rate          NUMBER;
        l_net_amt           amt_type;
        l_trx_id            trx_type;
        l_inv_curr_open_amt amt_type;
        l_inv_curr_net_amt  amt_type;
        l_amt_to_net        fun_net_batches_all.total_netted_amt%TYPE;
        l_inv_currency      fnd_currencies.currency_code%TYPE;
        l_precision         fnd_currencies.precision%TYPE;
	l_sql_stmt Varchar2(150);
	l_net_amt_cur  NUMBER;
        TYPE tnxCurTyp IS REF CURSOR;
        tnx_rec tnxCurTyp;
	--TYPE tnxCurType IS REF CURSOR;
	pmt_rec tnxCurTyp;
        l_path              varchar2(100);
    BEGIN
        l_path      := g_path || 'Update_Net_Balances';
        /* Check for mandatory parameters */
        l_amt_to_net := p_amt_to_net;
        fun_net_util.Log_String(g_state_level,l_path,'Fetching the transactions');
        OPEN tnx_rec FOR p_sql_stmt USING g_batch_id;
        FETCH tnx_rec BULK COLLECT INTO l_open_amt ,l_trx_id, l_net_amt, l_inv_curr_open_amt, l_inv_curr_net_amt, l_open_amt_afterdisc,l_tc_open_amt_afterdisc;
        FOR i IN 1..l_trx_id.COUNT
        LOOP
            IF l_open_amt_afterdisc(i) < l_amt_to_net THEN  			-- IF THE TRANSACTION IS FULLY NETTED, THEN UPDATE THE DISCOUNT AMOUNT WITH THE FULLY DISCOUNT CALCULATED AT THE TIME OF BATCH CREATION
	        fun_net_util.Log_String(g_state_level,l_path,'Inside IF condition');
		--IF g_net_currency_rule = 'ACCOUNTING_CURRENCY' THEN
		       -- SELECT fc.currency_code,fc.precision
                       -- INTO l_inv_currency,l_precision
                      --  FROM ap_invoices_all api, fnd_currencies fc
                     --   WHERE api.invoice_id = l_trx_id(i)
                     --   AND api.invoice_currency_code = fc.currency_code;
			--l_net_amt_cur := l_open_amt_afterdisc(i) * Derive_Net_Exchg_Rate(g_func_currency,l_inv_currency);
			--l_net_amt_cur := ROUND(l_net_amt_cur,l_precision);
		--	l_net_amt(i) := l_net_amt_cur;
			--l_net_amt(i) := l_open_amt_afterdisc(i);
		--	l_applieddisc(i) := l_open_amt(i)-l_net_amt_cur;
			--l_applieddisc(i) := l_open_amt(i)-l_open_amt_afterdisc(i);
		--ELSE
		--	l_net_amt(i) := l_open_amt_afterdisc(i);
		--	l_applieddisc(i) := l_open_amt(i)-l_open_amt_afterdisc(i);
		--END IF;
               --
	       --l_inv_curr_net_amt(i) := l_inv_curr_open_amt(i);
	       --l_inv_curr_net_amt(i) :=l_tc_open_amt_afterdisc(i);
		 l_net_amt(i) := l_open_amt_afterdisc(i);
		 l_inv_curr_net_amt(i) :=l_tc_open_amt_afterdisc(i);
		 l_applieddisc(i) := l_open_amt(i)-l_net_amt(i);
            ELSE								-- IF THE TRANSACTION IS PARTIALLY NETTED, THEN UPDATE THE DISCOUNT AMOUNT WITH THE PRORATED DISCOUNT
	        fun_net_util.Log_String(g_state_level,l_path,'Inside ELSE condition');
	        l_net_amt(i) := l_amt_to_net;
		l_inv_curr_net_amt(i) := l_net_amt(i);
		IF g_net_currency_rule = 'ACCOUNTING_CURRENCY' THEN
			IF  p_appln = 'AP' THEN
				SELECT fc.currency_code,fc.precision
				INTO l_inv_currency,l_precision
				FROM ap_invoices_all api, fnd_currencies fc
				WHERE api.invoice_id = l_trx_id(i)
				AND api.invoice_currency_code = fc.currency_code;
			ELSE
				SELECT fc.currency_code,fc.precision
				INTO l_inv_currency,l_precision
				FROM ra_customer_trx_all rct, fnd_currencies fc
				WHERE rct.customer_trx_id = l_trx_id(i)
				AND rct.invoice_currency_code = fc.currency_code;
			END IF;
			l_amt_to_net :=	round(l_amt_to_net * Derive_Net_Exchg_Rate(g_func_currency,l_inv_currency),l_precision);
			l_inv_curr_net_amt(i) := l_amt_to_net;
		END IF;
		/* PRORATING THE DISCOUNT FOR PARTIALLY NETTED TRANSACTIONS IN AP/AR */
		IF  p_appln = 'AP' THEN
			l_sql_stmt:='select PAYMENT_NUM,AMOUNT_REMAINING FROM ap_payment_schedules_all WHERE invoice_id=:v_invoice_id ';
			l_applieddisc(i):=0;
			OPEN pmt_rec FOR l_sql_stmt USING l_trx_id(i);
			FETCH pmt_rec BULK COLLECT INTO l_pmtno,l_amt_remaining;
			FOR j IN 1..l_pmtno.COUNT
			LOOP
				IF l_amt_remaining(j)>=l_amt_to_net THEN
					-- chk this l_amt_to_net=
					l_applieddisc(i) := AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Netted_Amt(l_trx_id(i),l_pmtno(j),g_batch_details.settlement_date,l_amt_to_net) + l_applieddisc(i);
					--  should convert to batch currecny l_applieddisc(i)
					EXIT;
				ELSE
					 -- chk this l_amt_remaining(j)
					l_applieddisc(i) := AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Pmt_Schedule(l_trx_id(i),l_pmtno(j),g_batch_details.settlement_date) + l_applieddisc(i);
					--l_applieddisc(i) := AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Netted_Amt(l_trx_id(i),l_pmtno(j),g_batch_details.settlement_date,l_amt_remaining(j)) + l_applieddisc(i);
					--  should convert to batch currecny l_applieddisc(i)
					l_amt_to_net := l_amt_to_net - (l_amt_remaining(j) - l_applieddisc(i));
				END IF;
			END LOOP;
		ELSE
			fun_net_util.Log_String(g_state_level,l_path,'Inside ELSE condition');
			MO_GLOBAL.SET_POLICY_CONTEXT('S',g_batch_details.org_id);
			l_sql_stmt:='SELECT PAYMENT_SCHEDULE_ID,AMOUNT_DUE_REMAINING FROM ar_payment_schedules_all WHERE CUSTOMER_TRX_ID=:v_cst_trx_id';
			l_applieddisc(i):=0;
			OPEN pmt_rec FOR l_sql_stmt USING l_trx_id(i);
			FETCH pmt_rec BULK COLLECT INTO l_pmtno,l_amt_remaining;
			fun_net_util.Log_String(g_state_level,l_path,'l_pmtno.COUNT = ' || l_pmtno.COUNT);
			FOR j IN 1..l_pmtno.COUNT
			LOOP
			fun_net_util.Log_String(g_state_level,l_path,' Inside loop');
				IF l_amt_remaining(j)>=l_amt_to_net THEN
					l_applieddisc(i) := ARP_DISCOUNTS_API.Get_Available_Disc_On_Inv(l_pmtno(j),g_batch_details.settlement_date,l_amt_to_net) + l_applieddisc(i);
					fun_net_util.Log_String(g_state_level,l_path,' Inside logic to calculate partial discount');
					fun_net_util.Log_String(g_state_level,l_path,' l_pmtno(i) = ' || l_pmtno(j));
					fun_net_util.Log_String(g_state_level,l_path,' l_amt_to_net = ' || l_amt_to_net);
					fun_net_util.Log_String(g_state_level,l_path,' l_applieddisc(i)= 1' || l_applieddisc(i));
					EXIT;
				ELSE
				        l_applieddisc(i) := ARP_DISCOUNTS_API.Get_Available_Disc_On_Inv(l_pmtno(j),g_batch_details.settlement_date,NULL) + l_applieddisc(i);
					--l_applieddisc(i) := ARP_DISCOUNTS_API.Get_Available_Disc_On_Inv(l_pmtno(j),g_batch_details.settlement_date,l_amt_remaining(j)) + l_applieddisc(i);
					l_amt_to_net := l_amt_to_net - (l_amt_remaining(j) - l_applieddisc(i));
					fun_net_util.Log_String(g_state_level,l_path,' l_pmtno(i) = ' || l_pmtno(j));
					fun_net_util.Log_String(g_state_level,l_path,' l_amt_to_net = ' || l_amt_to_net);
					fun_net_util.Log_String(g_state_level,l_path,' l_applieddisc(i)= 1' || l_applieddisc(i));
				END IF;
					fun_net_util.Log_String(g_state_level,l_path,' l_amt_to_net = ' || l_amt_to_net);
					fun_net_util.Log_String(g_state_level,l_path,' l_applieddisc(i)= 1' || l_applieddisc(i));
					fun_net_util.Log_String(g_state_level,l_path,' l_applieddisc(i)= 1 ' || l_applieddisc(i));
			END LOOP;
		END IF;   -- PROTATING LOGIC FOR PARTIALLY NETTED TRANSACTIONS
		IF g_net_currency_rule = 'ACCOUNTING_CURRENCY' THEN
		     IF  p_appln = 'AP' THEN
				SELECT fc.currency_code,fc.precision
				INTO l_inv_currency,l_precision
				FROM ap_invoices_all api, fnd_currencies fc
				WHERE api.invoice_id = l_trx_id(i)
				AND api.invoice_currency_code = fc.currency_code;
			ELSE
				SELECT fc.currency_code,fc.precision
				INTO l_inv_currency,l_precision
				FROM ra_customer_trx_all rct, fnd_currencies fc
				WHERE rct.customer_trx_id = l_trx_id(i)
				AND rct.invoice_currency_code = fc.currency_code;
			END IF;
			l_applieddisc(i):=round(l_applieddisc(i) * Derive_Net_Exchg_Rate(l_inv_currency,g_func_currency),l_precision);   -- from ACC CUR t BATCH CUR
		END IF;
		--l_inv_curr_net_amt(i):=l_amt_to_net;
                /*IF g_net_currency_rule = 'ACCOUNTING_CURRENCY' THEN
                    IF  p_appln = 'AP' THEN
                        SELECT fc.currency_code,fc.precision
                        INTO l_inv_currency,l_precision
                        FROM ap_invoices_all api, fnd_currencies fc
                        WHERE api.invoice_id = l_trx_id(i)
                        AND api.invoice_currency_code = fc.currency_code;
			l_exc_rate :=  Derive_Net_Exchg_Rate(g_func_currency,l_inv_currency);
			fun_net_util.Log_String(g_state_level,l_path,'l_exc_rate:'||l_exc_rate);
			fun_net_util.Log_String(g_state_level,l_path,'l_amt_to_net:'||l_amt_to_net);
                        l_inv_curr_net_amt(i) := l_net_amt(i) * Derive_Net_Exchg_Rate(g_func_currency,l_inv_currency);
                        l_inv_curr_net_amt(i) := ROUND(l_inv_curr_net_amt(i),l_precision);
                    ELSIF p_appln = 'AR' THEN
                        SELECT fc.currency_code,fc.precision
                        INTO l_inv_currency,l_precision
                        FROM ra_customer_trx_all rct, fnd_currencies fc
                        WHERE rct.customer_trx_id = l_trx_id(i)
                        AND rct.invoice_currency_code = fc.currency_code;
                        l_inv_curr_net_amt(i) := l_net_amt(i) * Derive_Net_Exchg_Rate(g_func_currency,l_inv_currency);
                        l_inv_curr_net_amt(i) := ROUND(l_inv_curr_net_amt(i),l_precision);
                    END IF;
                ELSE
                    l_inv_curr_net_amt(i) := l_net_amt(i);
                END IF; */
            END IF;
            fun_net_util.Log_String(g_state_level,l_path,'trx_id :'||l_trx_id(i));
            fun_net_util.Log_String(g_state_level,l_path,'Netted Amount :'||l_net_amt(i));
            fun_net_util.Log_String(g_state_level,l_path,'Invoice currency Netted Amount :'||l_inv_curr_net_amt(i));
	    fun_net_util.Log_String(g_state_level,l_path,'l_applieddisc(i)= ' || l_applieddisc(i));
            l_amt_to_net := l_amt_to_net - l_open_amt_afterdisc(i);
            IF l_amt_to_net <= 0 THEN
                EXIT;
            END IF;
        END LOOP;
	-- UPDATING EITHER AP OR AR FUN TABLE WITH THE NETTED AMOUNT, INVOICE CURRENCY NETTED AMOUNT AND THE APPLIED DISCOUNT AMOUNT
        IF  p_appln = 'AP' THEN
            FORALL i IN 1..l_trx_id.COUNT
                UPDATE fun_net_ap_invs_all
                SET netted_amt = l_net_amt(i),
                    inv_curr_net_amt = l_inv_curr_net_amt(i),
		    applied_disc = l_applieddisc(i)
                WHERE batch_id  = g_batch_id
                AND  invoice_id = l_trx_id(i);
        ELSIF p_appln = 'AR' THEN
            FORALL i IN 1..l_trx_id.COUNT
                UPDATE fun_net_ar_txns_all
                SET netted_amt = l_net_amt(i),
                    txn_curr_net_amt = l_inv_curr_net_amt(i),
		    applied_disc = l_applieddisc(i)
                WHERE batch_id  = g_batch_id
                AND  customer_trx_id = l_trx_id(i);
        END IF;
        EXCEPTION
            WHEN OTHERS THEN
                fun_net_util.Log_String(g_state_level,l_path,sqlerrm);
    END update_net_balances_esd;
    PROCEDURE calculate_AP_AR_balances(p_amt_to_net OUT NOCOPY NUMBER,
                                    p_status_flag OUT NOCOPY VARCHAR2) IS
        l_ap_bal        fun_net_ap_invs_all.open_amt%TYPE;
        l_ar_bal        fun_net_ar_txns_all.open_amt%TYPE;
        l_amt_to_net    fun_net_batches_all.total_netted_amt%TYPE;
        l_status_flag   VARCHAR2(1);
        l_sql_stmt      VARCHAR2(2000);
        l_path          varchar2(100);
    BEGIN
        l_path      := g_path || 'Calculate_AP_AR_Balances';
        validate_AP_AR_balances(l_ar_bal, l_ap_bal, l_status_flag);
        IF l_status_flag = FND_API.G_TRUE THEN
            IF l_ap_bal >= l_ar_bal THEN
                fun_net_util.Log_String(g_state_level,l_path,'AP Balance > AR Balance');
        		l_amt_to_net := l_ar_bal;
                /* As the Ar Bal = Total Net amount , update the net amount for each AR tnx with the open balance of that tnx */
                UPDATE fun_net_ar_txns_all
                SET netted_amt = open_amt,
                    txn_curr_net_amt = txn_curr_open_amt
                WHERE batch_id = g_batch_id;
                /*Order the transactions by rank as the tnxs with a higher rank should be netted first */
                l_sql_stmt := 'SELECT open_amt,invoice_id,0,inv_curr_open_amt,0 FROM fun_net_ap_invs_all WHERE batch_id = :v_batch_id ORDER BY ap_txn_rank';
        		update_net_balances(l_sql_stmt,l_amt_to_net,'AP');
            ELSIF l_ar_bal > l_ap_bal THEN
                fun_net_util.Log_String(g_state_level,l_path,'AR Balance > AP Balance');
      	 		l_amt_to_net := l_ap_bal;
                /* As the AP Bal = Total Net amount , update the net amount for each AP tnx with the open balance of that tnx */
                UPDATE fun_net_ap_invs_all
                SET netted_amt = open_amt,
                    inv_curr_net_amt = inv_curr_open_amt
                WHERE batch_id = g_batch_id;
                l_sql_stmt := 'SELECT open_amt,customer_trx_id,0, txn_curr_open_amt,0 FROM fun_net_ar_txns_all WHERE batch_id = :v_batch_id ORDER BY ar_txn_rank';
                update_net_balances(l_sql_stmt,l_amt_to_net,'AR');
    		END IF;
            fun_net_util.Log_String(g_state_level,l_path,'Total Netted Amount :'||l_amt_to_net);
            /*UPDATE fun_net_batches_all
            SET total_netted_amt = l_amt_to_net
            WHERE batch_id = g_batch_id; */
            p_amt_to_net := l_amt_to_net;
            p_status_flag := FND_API.G_TRUE;
        ELSE
		  /*Unlock AP and AR Transactions that have been locked */
            fun_net_util.Log_String(g_state_level,l_path,'validation of ap and ar balances failed.Some transactions in AP and AR might have to be unlocked manually');
            p_status_flag := FND_API.G_FALSE;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND then
            fun_net_util.Log_String(g_proc_level,l_path,'EXCEPTION : '||sqlerrm);
            RETURN;
    END calculate_AP_AR_balances;
    /* ------------------ ADDED NEWLY FOR ESD --------------------*/
    /* PROCEDURE FOR CALCULATING THE SUM OF AP AND AR OPEN AMOUNT AFTER TAKING FULL DISCOUNT */
    PROCEDURE AP_AR_balances_with_approxdisc(p_ar_bal OUT NOCOPY NUMBER,
                                    p_ap_bal OUT NOCOPY NUMBER,
                                    p_status_flag OUT NOCOPY VARCHAR2) IS
        CURSOR c_get_ar_open_amount IS
        SELECT SUM (OPEN_AMOUNT_AFTERDISC)
        FROM fun_net_ar_txns_all
        WHERE batch_id = g_batch_id;
        CURSOR c_get_ap_open_amount IS
        SELECT SUM (OPEN_AMOUNT_AFTERDISC)
        FROM fun_net_ap_invs_all
        WHERE batch_id = g_batch_id;
        l_path              varchar2(100);
    BEGIN
        l_path      := g_path || 'Validate_AP_AR_Balances';
        p_status_flag := FND_API.G_TRUE;
        OPEN c_get_ar_open_amount;
        FETCH c_get_ar_open_amount INTO p_ar_bal;
        CLOSE c_get_ar_open_amount;
        OPEN c_get_ap_open_amount;
        FETCH c_get_ap_open_amount INTO p_ap_bal;
        CLOSE c_get_ap_open_amount;
        fun_net_util.Log_String(g_state_level,l_path,'AP open amount :'||p_ap_bal);
        fun_net_util.Log_String(g_state_level,l_path,'AR open amount :'||p_ar_bal);
        IF nvl(p_ap_bal,0) = 0 OR nvl(p_ar_bal,0) = 0 THEN
            p_status_flag := FND_API.G_FALSE;
	    FND_MESSAGE.SET_NAME('FUN','FUN_NET_NO_BALANCES');
            fun_net_util.Log_String(g_state_level,l_path,'EXCEPTION : AP or AR balance is zero');
            RETURN;
        END IF;
        fun_net_util.Log_String(g_state_level,l_path,'AP and AR balances validated');
    EXCEPTION
        WHEN OTHERS THEN
         fun_net_util.Log_String(g_proc_level,l_path,'EXCEPTION : '||sqlerrm);
    END AP_AR_balances_with_approxdisc;
    /* ------------------ ADDED NEWLY FOR ESD --------------------*/
    /* PROCEDURE FOR CALCULATING THE NETTED AMOUNT */
        PROCEDURE calculate_approx_netted_amount(p_amt_to_net OUT NOCOPY NUMBER,
                                    p_status_flag OUT NOCOPY VARCHAR2) IS
        l_ap_bal        fun_net_ap_invs_all.open_amt%TYPE;
        l_ar_bal        fun_net_ar_txns_all.open_amt%TYPE;
        l_amt_to_net    fun_net_batches_all.total_netted_amt%TYPE;
        l_status_flag   VARCHAR2(1);
        l_sql_stmt      VARCHAR2(2000);
        l_path          varchar2(100);
    BEGIN
        l_path      := g_path || 'calculate_approx_netted_amount';
        AP_AR_balances_with_approxdisc(l_ar_bal, l_ap_bal, l_status_flag);
        IF l_status_flag = FND_API.G_TRUE THEN
            IF l_ap_bal >= l_ar_bal THEN
                fun_net_util.Log_String(g_state_level,l_path,'AP Balance > AR Balance');
        	l_amt_to_net := l_ar_bal;
		UPDATE fun_net_ar_txns_all
		SET netted_amt = open_amount_afterdisc,
		    txn_curr_net_amt = txn_curr_open_amount_afterdisc,
		    applied_disc = open_amt - open_amount_afterdisc
		WHERE batch_id = g_batch_id;
                /*Order the transactions by rank as the tnxs with a higher rank should be netted first */
                l_sql_stmt := 'SELECT open_amt,invoice_id,0,inv_curr_open_amt,0,OPEN_AMOUNT_AFTERDISC,txn_curr_open_amount_afterdisc FROM fun_net_ap_invs_all WHERE batch_id = :v_batch_id ORDER BY ap_txn_rank';
        		update_net_balances_esd(l_sql_stmt,l_amt_to_net,'AP');
            ELSIF l_ar_bal > l_ap_bal THEN
                fun_net_util.Log_String(g_state_level,l_path,'AR Balance > AP Balance');
      	 		l_amt_to_net := l_ap_bal;
		UPDATE fun_net_ap_invs_all
                SET netted_amt = open_amount_afterdisc,
                    inv_curr_net_amt = txn_curr_open_amount_afterdisc,
		    applied_disc = open_amt - open_amount_afterdisc
                WHERE batch_id = g_batch_id;
                l_sql_stmt := 'SELECT open_amt,customer_trx_id,0, txn_curr_open_amt,0,OPEN_AMOUNT_AFTERDISC,txn_curr_open_amount_afterdisc FROM fun_net_ar_txns_all WHERE batch_id = :v_batch_id ORDER BY ar_txn_rank';
                update_net_balances_esd(l_sql_stmt,l_amt_to_net,'AR');
    		END IF;
            fun_net_util.Log_String(g_state_level,l_path,'Total Netted Amount :'||l_amt_to_net);
            p_amt_to_net := l_amt_to_net;
            p_status_flag := FND_API.G_TRUE;
        ELSE
		  /*Unlock AP and AR Transactions that have been locked */
            fun_net_util.Log_String(g_state_level,l_path,'validation of ap and ar balances failed.Some transactions in AP and AR might have to be unlocked manually');
            p_status_flag := FND_API.G_FALSE;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND then
            fun_net_util.Log_String(g_proc_level,l_path,'EXCEPTION : '||sqlerrm);
            RETURN;
    END calculate_approx_netted_amount;
    PROCEDURE validate_AP_AR_balances(p_ar_bal OUT NOCOPY NUMBER,
                                    p_ap_bal OUT NOCOPY NUMBER,
                                    p_status_flag OUT NOCOPY VARCHAR2) IS
        CURSOR c_get_ar_open_amount IS
        SELECT SUM (open_amt)
        FROM fun_net_ar_txns_all
        WHERE batch_id = g_batch_id;
        CURSOR c_get_ap_open_amount IS
        SELECT SUM (open_amt)
        FROM fun_net_ap_invs_all
        WHERE batch_id = g_batch_id;
        l_path              varchar2(100);
    BEGIN
        l_path      := g_path || 'Validate_AP_AR_Balances';
        p_status_flag := FND_API.G_TRUE;
        OPEN c_get_ar_open_amount;
        FETCH c_get_ar_open_amount INTO p_ar_bal;
        CLOSE c_get_ar_open_amount;
        OPEN c_get_ap_open_amount;
        FETCH c_get_ap_open_amount INTO p_ap_bal;
        CLOSE c_get_ap_open_amount;
        fun_net_util.Log_String(g_state_level,l_path,'AP open amount :'||p_ap_bal);
        fun_net_util.Log_String(g_state_level,l_path,'AR open amount :'||p_ar_bal);
        IF nvl(p_ap_bal,0) = 0 OR nvl(p_ar_bal,0) = 0 THEN
            /* Error out the Batch to say netting cannot continue and set the Batch to Error  and put message in the log*/
            --ERROR MESSAGE : 'Netting cannot be performed as the Outstanding balance is zero'
            /*UPDATE fun_net_batches_all
            SET batch_status_code = 'ERROR'
            WHERE batch_id = g_batch_id; */
            p_status_flag := FND_API.G_FALSE;
            /*IF NOT update_Batch_Status('ERROR') THEN
                p_status_flag := FND_API.G_FALSE;
            END IF; */
FND_MESSAGE.SET_NAME('FUN','FUN_NET_NO_BALANCES');
            fun_net_util.Log_String(g_state_level,l_path,'EXCEPTION : AP or AR balance is zero');
            RETURN;
        END IF;
        fun_net_util.Log_String(g_state_level,l_path,'AP and AR balances validated');
    EXCEPTION
        WHEN OTHERS THEN
         fun_net_util.Log_String(g_proc_level,l_path,'EXCEPTION : '||sqlerrm);
    END validate_AP_AR_balances;
    PROCEDURE insert_batch_record(p_currency_code VARCHAR2) IS
        l_batch_id      fun_net_batches_all.batch_id%TYPE;
        l_path    varchar2(200);
    BEGIN
        l_path := g_path||'insert_batch_record';
        /* Check for mandatory parameters and all values that are going to be inserted */
        SELECT fun_net_batches_s.NEXTVAL
        INTO g_batch_id
        FROM DUAL;
        INSERT INTO FUN_NET_BATCHES_ALL
                        (batch_id,
                        object_version_number,
                        agreement_id,
                        batch_name,
                        batch_number,
                        review_netting_batch_flag,
                        batch_currency,
                        batch_status_code,
                        total_netted_amt,
                        transaction_due_date,
                        settlement_date,
                        response_date,
                        exchange_rate_type,
                        exchange_rate,
                        gl_date,
                        org_id,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        attribute_category,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        attribute16,
                        attribute17,
                        attribute18,
                        attribute19,
                        attribute20)
                VALUES
                    (g_batch_id,
                        1,
                        g_agreement_id,
                        g_batch_details.batch_name,
                        g_batch_id,
                        g_batch_details.review_netting_batch_flag,
                        p_currency_code,
                        g_batch_details.batch_status_code,
                        g_batch_details.total_netted_amt,
                        g_batch_details.transaction_due_date,
                        g_batch_details.settlement_date,
                        g_batch_details.response_date,
                        g_batch_details.exchange_rate_type,
                        g_batch_details.exchange_rate,
                        g_batch_details.gl_date,
                        g_batch_details.org_id,
                        sysdate,
                        g_user_id,
                        sysdate,
                        g_user_id,
                        g_login_id,
                        g_batch_details.attribute_category,
                        g_batch_details.attribute1,
                        g_batch_details.attribute2,
                        g_batch_details.attribute3,
                        g_batch_details.attribute4,
                        g_batch_details.attribute5,
                        g_batch_details.attribute6,
                        g_batch_details.attribute7,
                        g_batch_details.attribute8,
                        g_batch_details.attribute9,
                        g_batch_details.attribute10,
                        g_batch_details.attribute11,
                        g_batch_details.attribute12,
                        g_batch_details.attribute13,
                        g_batch_details.attribute14,
                        g_batch_details.attribute15,
                        g_batch_details.attribute16,
                        g_batch_details.attribute17,
                        g_batch_details.attribute18,
                        g_batch_details.attribute19,
                        g_batch_details.attribute20);
    EXCEPTION
        WHEN OTHERS THEN
	fun_net_util.Log_String(g_state_level,l_path,'Insertion of batch_record failed.');
            NULL;
    END insert_batch_record;
    FUNCTION batch_exists(p_currency_code VARCHAR2) RETURN BOOLEAN IS
        l_path varchar2(200);
    BEGIN
        l_path := g_path||'batch_exists';
        /* Check for mandatory parameters */
        IF p_currency_code IS NULL THEN
            fun_net_util.Log_String(g_state_level,l_path,'Currency code is NULL');
            RETURN FALSE;
        END IF;
        /* Check if the Batch already exists for the given currency and agreement.
        AP and AR Transactions that have the same currency code and agreement will belong to
        the same batch  if the 'Netting within Currency' option is Selected. */
        FOR i IN 1..g_idx LOOP
            IF g_batch_list(i).agreement_id = g_agreement_id AND
                g_batch_list(i).currency = p_currency_code THEN
                fun_net_util.Log_String(g_state_level,l_path,'Agreement_id: '||g_batch_list(i).agreement_id);
                fun_net_util.Log_String(g_state_level,l_path,'Currency: '||g_batch_list(i).currency);
                g_batch_id := g_batch_list(i).batch_id;
                fun_net_util.Log_String(g_state_level,l_path,'Batch ID: '||g_batch_list(i).batch_id);
                RETURN TRUE;
            ELSE
                fun_net_util.Log_String(g_state_level,l_path,'Agreement_id: '||g_batch_list(i).agreement_id);
                fun_net_util.Log_String(g_state_level,l_path,'Currency: '||g_batch_list(i).currency);
            END IF;
        END LOOP;
        RETURN FALSE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END batch_exists;
PROCEDURE validate_exch_rate (p_status_flag OUT NOCOPY VARCHAR2) IS
 CURSOR trx_curr_cur IS
   SELECT INVOICE_CURRENCY_CODE
   FROM  ap_invoices_all api, fun_net_ap_invs_all fnapi
   WHERE  api.invoice_id = fnapi.invoice_id
  AND   fnapi.batch_id = g_batch_id
 UNION
 SELECT INVOICE_CURRENCY_CODE
  FROM  ra_customer_trx_all rct, fun_net_ar_txns_all fnart
 WHERE  rct.customer_trx_id = fnart.customer_trx_id
   AND   fnart.batch_id = g_batch_id;
 l_count NUMBER;
 l_exc_rate NUMBER;
 l_conv_rate fun_net_batches_all.exchange_rate_type%TYPE;
 l_path   VARCHAR2(100);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 BEGIN
 l_path  := g_path || 'validate_exch_rate';
 l_count := 0;
 p_status_flag := FND_API.G_TRUE;
 SELECT USER_CONVERSION_TYPE
   INTO l_conv_rate
   FROM   GL_DAILY_CONVERSION_TYPES
   WHERE CONVERSION_TYPE = g_batch_details.exchange_rate_type;
        fun_net_util.Log_String(g_state_level,l_path,'l_conv_rate:'||l_conv_rate);
        fun_net_util.Log_String(g_state_level,l_path,' p_status_flag :'
                   || p_status_flag);
    For trx_curr_rec in trx_curr_cur
    LOOP
        fun_net_util.Log_String(g_state_level,l_path,'g_func_currency: '
                 ||g_func_currency);
        fun_net_util.Log_String(g_state_level,l_path,
        'trx_curr_REC.invoice_currency_code: '||trx_curr_REC.invoice_currency_code);
         l_exc_rate :=  Derive_Net_Exchg_Rate(g_func_currency,trx_curr_REC.invoice_currency_code);
        fun_net_util.Log_String(g_state_level,l_path,'l_exc_rate :'||l_exc_rate);
        fun_net_util.Log_String(g_state_level,l_path,'l_count :'||l_count);
        IF l_exc_rate IS NULL and l_count = 0 THEN
                fun_net_util.Log_String(g_state_level,l_path,'Inside if ');
                FND_MESSAGE.SET_NAME('FUN','FUN_NET_EX_RATE_NOT_DEFINED');
                FND_MESSAGE.SET_TOKEN('RATE_TYPE', l_conv_rate);
                l_msg_data :=  FND_MESSAGE.get;
               fnd_file.put_line(fnd_file.log,l_msg_data);
                fnd_file.put_line(fnd_file.log, '   '||
                        trx_curr_REC.invoice_currency_code || ' -> ' || g_func_currency );
                l_count := 2;
        ELSIF l_exc_rate IS NULL AND l_count = 2 THEN
                fun_net_util.Log_String(g_state_level,l_path,'Inside esle if');
                fnd_file.put_line(fnd_file.log, '   '||
                        trx_curr_REC.invoice_currency_code || ' -> ' || g_func_currency );
        END IF;
        IF l_exc_rate is NULL THEN
                p_status_flag := FND_API.G_FALSE;
        END IF;
    END LOOP;
                fun_net_util.Log_String(g_state_level,l_path,' p_status_flag :'
                        || p_status_flag);
END validate_exch_rate;
    PROCEDURE update_net_balances(p_sql_stmt VARCHAR2,
                                    p_amt_to_net NUMBER,
                                    p_appln VARCHAR2) IS
        TYPE amt_type IS TABLE OF fun_net_batches_all.total_netted_amt%TYPE;
        TYPE trx_type IS TABLE OF fun_net_ar_txns_all.customer_trx_id%TYPE;
        l_open_amt          amt_type;
        l_exc_rate          NUMBER;
        l_net_amt           amt_type;
        l_trx_id            trx_type;
        l_inv_curr_open_amt amt_type;
        l_inv_curr_net_amt  amt_type;
        l_amt_to_net        fun_net_batches_all.total_netted_amt%TYPE;
        l_inv_currency      fnd_currencies.currency_code%TYPE;
        l_precision         fnd_currencies.precision%TYPE;
        TYPE tnxCurTyp IS REF CURSOR;
        tnx_rec tnxCurTyp;
        l_path              varchar2(100);
    BEGIN
        l_path      := g_path || 'Update_Net_Balances';
        /* Check for mandatory parameters*/
        l_amt_to_net := p_amt_to_net;
        fun_net_util.Log_String(g_state_level,l_path,'Fetching the transactions');
        OPEN tnx_rec FOR p_sql_stmt USING g_batch_id;
        FETCH tnx_rec BULK COLLECT INTO l_open_amt ,l_trx_id, l_net_amt, l_inv_curr_open_amt, l_inv_curr_net_amt;
        /* Scan the table for every tnx selected and compute the net amount .
         Example :if the Total Net amount = 950
        Tot_Net_Amount = 950
        Rank Tnx Open Amount   Net Amount
        1	1001   400                    400
        2	1002   500                   500
        3	1003   600		 50 */
        FOR i IN 1..l_trx_id.COUNT
        LOOP
            IF l_open_amt(i) < l_amt_to_net THEN
                l_net_amt(i) := l_open_amt(i);
                l_inv_curr_net_amt(i) := l_inv_curr_open_amt(i);
            ELSE
                l_net_amt(i) := l_amt_to_net;
                IF g_net_currency_rule = 'ACCOUNTING_CURRENCY' THEN
                    IF  p_appln = 'AP' THEN
                        SELECT fc.currency_code,fc.precision
                        INTO l_inv_currency,l_precision
                        FROM ap_invoices_all api, fnd_currencies fc
                        WHERE api.invoice_id = l_trx_id(i)
                        AND api.invoice_currency_code = fc.currency_code;
  l_exc_rate :=  Derive_Net_Exchg_Rate(g_func_currency,l_inv_currency);
fun_net_util.Log_String(g_state_level,l_path,'l_exc_rate:'||l_exc_rate);
fun_net_util.Log_String(g_state_level,l_path,'l_amt_to_net:'||l_amt_to_net);
                        l_inv_curr_net_amt(i) := l_amt_to_net * Derive_Net_Exchg_Rate(g_func_currency,l_inv_currency);
                        l_inv_curr_net_amt(i) := ROUND(l_inv_curr_net_amt(i),l_precision);
                    ELSIF p_appln = 'AR' THEN
                        SELECT fc.currency_code,fc.precision
                        INTO l_inv_currency,l_precision
                        FROM ra_customer_trx_all rct, fnd_currencies fc
                        WHERE rct.customer_trx_id = l_trx_id(i)
                        AND rct.invoice_currency_code = fc.currency_code;
                        l_inv_curr_net_amt(i) := l_amt_to_net * Derive_Net_Exchg_Rate(g_func_currency,l_inv_currency);
                        l_inv_curr_net_amt(i) := ROUND(l_inv_curr_net_amt(i),l_precision);
                    END IF;
                ELSE
                    l_inv_curr_net_amt(i) := l_net_amt(i);
                END IF;
            END IF;
            fun_net_util.Log_String(g_state_level,l_path,'trx_id :'||l_trx_id(i));
            fun_net_util.Log_String(g_state_level,l_path,'Netted Amount :'||l_net_amt(i));
            fun_net_util.Log_String(g_state_level,l_path,'Invoice currency Netted Amount :'||l_inv_curr_net_amt(i));
            l_amt_to_net := l_amt_to_net - l_open_amt(i);
            IF l_amt_to_net <= 0 THEN
                EXIT;
            END IF;
        END LOOP;
        IF  p_appln = 'AP' THEN
            FORALL i IN 1..l_trx_id.COUNT
                UPDATE fun_net_ap_invs_all
                SET netted_amt = l_net_amt(i),
                    inv_curr_net_amt = l_inv_curr_net_amt(i)
                WHERE batch_id  = g_batch_id
                AND  invoice_id = l_trx_id(i);
        ELSIF p_appln = 'AR' THEN
            FORALL i IN 1..l_trx_id.COUNT
                UPDATE fun_net_ar_txns_all
                SET netted_amt = l_net_amt(i),
                    txn_curr_net_amt = l_inv_curr_net_amt(i)
                WHERE batch_id  = g_batch_id
                AND  customer_trx_id = l_trx_id(i);
        END IF;
        EXCEPTION
            WHEN OTHERS THEN
                fun_net_util.Log_String(g_state_level,l_path,sqlerrm);
    END update_net_balances;
    PROCEDURE Update_Net_Amounts(p_batch_id NUMBER, p_amt_to_net NUMBER, p_appln VARCHAR2) IS
    BEGIN
      NULL;
    END Update_Net_Amounts;
    FUNCTION calculate_ar_trx_amt(
		p_customer_trx_id NUMBER)
	RETURN NUMBER
	IS
        l_total_amount  ra_cust_trx_line_gl_dist.amount%TYPE;
    BEGIN
        SELECT sum(amount)
        INTO l_total_amount
        from ra_cust_trx_line_gl_dist dist,
            ra_customer_trx_lines_all lines
        Where  lines.customer_trx_id = p_customer_trx_id
        And lines.customer_trx_line_id = dist.customer_trx_line_id
        And dist.account_class <> 'REC';
        RETURN l_total_amount;
	EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END calculate_ar_trx_amt;
    PROCEDURE create_net_batch(
            -- ***** Standard API Parameters *****
            p_init_msg_list IN VARCHAR2 := FND_API.G_TRUE,
            p_commit        IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id      IN NUMBER) IS
        -- ***** local variables *****
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_path 	                VARCHAR2(100);
        l_amt_to_net            fun_net_batches_all.total_netted_amt%TYPE;
        l_status_flag           VARCHAR2(1);
         batch_status_flag   BOOLEAN;
        CURSOR c_agreement_cur IS
            SELECT agreement_id,
                net_currency_rule_code,
                net_order_rule_code,
                net_balance_rule_code,
                bank_account_id,
                net_currency_code,
                agreement_start_date,
                agreement_end_date,
                shikyu_rule_code,
		days_past_due,
                sel_rec_past_due_txns_flag
            FROM fun_net_agreements
            WHERE org_id = g_batch_details.org_id
            AND TRUNC(agreement_start_date) <= TRUNC(g_batch_details.settlement_date)
            AND TRUNC(nvl(agreement_end_date,sysdate)) >= TRUNC(sysdate)
            AND agreement_id = nvl(g_agreement_id,agreement_id);
    BEGIN
        l_path  := g_path||'Create_Net_Batch';
        fun_net_util.Log_String(g_event_level,l_path,'Creating Netting batches');
        x_msg_count				:=	NULL;
        x_msg_data				:=	NULL;
        g_user_id               := fnd_global.user_id;
        g_login_id              := fnd_global.login_id;
        -- ****   Standard start of API savepoint  ****
        SAVEPOINT create_net_batch_SP;
        -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        -- ****  Initialize return status to SUCCESS   *****
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/
        /* Check for mandatory parameters */
        IF p_batch_id IS NULL THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        g_batch_id := p_batch_id;
        --Call the procedure to get the batch details
        fun_net_util.Log_String(g_state_level,l_path,'Fetching batch details');
        IF NOT get_batch_details THEN
            fun_net_util.Log_String(g_state_level,l_path,'Error in Fetching batch details');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        --If the call is successful then call the procedure to update batch status
        IF NOT update_batch_status('RUNNING') THEN
            fun_net_util.Log_String(g_state_level,l_path,'Error in updating batch status');
            RAISE FND_API.G_EXC_ERROR;
        END IF; -- Return Code
        --If the call is successful then call the procedure to get all agreement details. If agreement id is null , then loop through each agreement and select tnx for every agreement.
        -- If the call is successful then get the agreement details and select transactions for every agreement
        fun_net_util.Log_String(g_state_level,l_path,'Before processing the agreements');
        get_functional_currency;
        g_agreement_id := g_batch_details.agreement_id;
        g_agreement_count := 0;
        g_currency_count := 0;
        FOR agr_rec IN c_agreement_cur
        LOOP
            /* Reset the global varaibles for every agreement */
            fun_net_util.Log_String(g_state_level,l_path,'Agreement_id:'||agr_rec.agreement_id);
            g_agreement_id := agr_rec.agreement_id;
            g_net_currency_rule := agr_rec.net_currency_rule_code;
            g_net_order_rule := agr_rec.net_order_rule_code;
            g_net_balance_rule := agr_rec.net_balance_rule_code;
            g_shikyu_rule := nvl(agr_rec.shikyu_rule_code,'D');
            g_bank_account_id := agr_rec.bank_account_id;
            g_net_currency := agr_rec.net_currency_code;
            g_agr_start_date := agr_rec.agreement_start_date;
            g_agr_end_date := agr_rec.agreement_end_date;
	    g_days_past_due := nvl(agr_rec.days_past_due,0);
            g_sel_past_due_flag := agr_rec.sel_rec_past_due_txns_flag;
            IF g_agr_end_date IS NULL THEN
                g_agr_end_date := to_date('31-12-9999','DD-MM-YYYY');
            END IF;
            /*If this is the first agreement then assign the current batch id to the Batch id Table */
            g_agreement_count := g_agreement_count + 1;
            IF g_agreement_count = 1 THEN
                g_idx := 1;
                g_batch_list(g_idx).batch_id := g_batch_id;
                g_batch_list(g_idx).agreement_id := g_agreement_id;
            END IF;
            /*IF NOT get_agreement_details THEN
                RAISE G_EXC_ERROR;
            END IF;*/
            --g_currency_count := 0;
            --If the call is successful then call the procedure to select all customer transactions	--and insert them into the customer transactions table
            IF NOT prepare_ar_transactions THEN
                fun_net_util.Log_String(g_state_level,l_path,'Error in prepare AR Transactions');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            --If the call is successful then call the procedure to select all supplier transactions and insert them into the supplier invoices table.
            IF NOT prepare_ap_transactions THEN
                fun_net_util.Log_String(g_state_level,l_path,'Error in prepare AP transactions');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END LOOP;
        fun_net_util.Log_String(g_state_level,l_path,'Processing the batches');
        FOR i IN 1..g_idx
        LOOP
            g_batch_id := g_batch_list(i).batch_id;
            IF NOT get_batch_details THEN
                fun_net_util.Log_String(g_state_level,l_path,'Error in Fetching batch details');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            g_agreement_id := g_batch_list(i).agreement_id;
            IF NOT get_agreement_details THEN
                fun_net_util.Log_String(g_state_level,l_path,'Error in Fetching agreement details');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            fun_net_util.Log_String(g_state_level,l_path,'Batch ID:'||g_batch_id);
	     -- verify currency rates
	      validate_exch_rate(l_return_status);
	    IF  l_return_status = FND_API.G_FALSE THEN
		    fun_net_util.Log_String(g_event_level,l_path, 'validate_exch_rate returns false');
         	    RAISE FND_API.G_EXC_ERROR;
	     END IF;
	     IF l_allow_disc_flag='N' THEN          		-- FOR NON ESD Agreements
             	calculate_AP_AR_balances(l_amt_to_net,l_status_flag);
	     ELSE						-- FOR ESD Enabled Agreements
	        calculate_approx_netted_amount(l_amt_to_net,l_status_flag);
	     END IF;
            /* Set the status of the Batch to Selected */
            IF l_status_flag = FND_API.G_TRUE THEN
                UPDATE fun_net_batches_all
                SET batch_status_code = 'SELECTED',
                    batch_currency = g_batch_list(i).currency,
                    agreement_id = g_batch_list(i).agreement_id,
                    total_netted_amt = l_amt_to_net
                WHERE batch_id = g_batch_id;
                g_batch_details.batch_status_code := 'SELECTED';
            ELSE
                UPDATE fun_net_batches_all
                SET batch_status_code = 'ERROR',
                    batch_currency = g_batch_list(i).currency,
                    agreement_id = g_batch_list(i).agreement_id,
                    total_netted_amt = l_amt_to_net
                WHERE batch_id = g_batch_id;
                g_batch_details.batch_status_code := 'ERROR';
            END IF;
            /* IF NOT update_batch_status('SELECTED') THEN
                fun_net_util.Log_String(g_state_level,l_path,'Error in updating batch status to SELECTED');
                NULL;
            END IF; */
            /* Check if Auto submission is on If not call the Submit API process*/
            /* VDOBREV: Bug 5003118 IF g_batch_details.review_netting_batch_flag = 'N' */
            IF g_batch_details.review_netting_batch_flag = 'Y'
            AND g_batch_details.batch_status_code = 'SELECTED' THEN
                fun_net_util.Log_String(g_state_level,l_path,'Submitting Netting Batch');
                 submit_net_batch (
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit        => FND_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_batch_id      => g_batch_id);
            END IF;
        END LOOP;
        -- Standard check of p_commit.
        fun_net_util.Log_String(g_state_level,l_path,'p_commit :'|| p_commit);
        IF FND_API.To_Boolean( p_commit ) THEN
                fun_net_util.Log_String(g_state_level,l_path,'Saving the batches');
            COMMIT WORK;
        END IF;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            fun_net_util.Log_String(g_state_level,l_path,'netting batch creation failed');
            ROLLBACK TO create_net_batch_SP;
             batch_status_flag :=  update_batch_status('ERROR');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
			COMMIT WORK;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            fun_net_util.Log_String(g_state_level,l_path,'netting batch creation failed');
            ROLLBACK TO create_net_batch_SP;
            batch_status_flag :=  update_batch_status('ERROR');
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
			COMMIT WORK;
        WHEN OTHERS THEN
            fun_net_util.Log_String(g_state_level,l_path,'netting batch creation failed');
            ROLLBACK TO Create_Net_Batch_SP;
             batch_status_flag :=  update_batch_status('ERROR');
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                --FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Add_Exc_Msg( 'FUN_ARAP_NET_PKG', 'create_net_batch');
            END IF;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
			COMMIT WORK;
    END create_net_batch;
PROCEDURE Validate_multi_currency_flag IS
l_count number(3);
l_flag varchar2(3);
l_batch_currency fun_net_batches_all.batch_currency%type;
BEGIN
      l_count:=0;
      l_flag := 'N';
      if(g_net_currency_rule<>'ACCOUNTING_CURRENCY') then
	   if(g_net_currency_rule='SINGLE_CURRENCY') then
             begin
	        select batch_currency into l_batch_currency
        	from fun_net_batches_all
	        where batch_id = g_batch_id;
             exception
                when others then
                   RAISE FND_API.G_EXC_ERROR;
             end;
            if l_batch_currency<> g_func_currency then
             l_count:=1;
            end if;
          elsif (g_net_currency_rule = 'WITHIN_CURRENCY') then
	          SELECT count (DISTINCT rac.invoice_currency_code)
                  into   l_count
	          FROM   ra_customer_trx_all rac,fun_net_ar_txns_all fnar
        	  WHERE  rac.customer_trx_id = fnar.customer_trx_id
	          AND    fnar.batch_id =   g_batch_id
        	  AND    rac.invoice_currency_code <> g_func_currency;
          end if;
        if( l_count > 0 ) then
	      begin
                select cba.receipt_multi_currency_flag
              	into l_flag
		from ce_bank_accounts cba, ce_bank_acct_uses_ALL ba,ar_receipt_classes rc,
		ar_receipt_methods rm,ar_receipt_method_accounts_ALL rma
		where rc.creation_method_code = 'NETTING'
		and rc.receipt_class_id = rm.receipt_class_id
		and ba.bank_account_id = cba.bank_account_id
		and rm.receipt_method_id = rma.receipt_method_id
		and rma.remit_bank_acct_use_id = ba.bank_acct_use_id;
              exception
                when others then
                  RAISE FND_API.G_EXC_ERROR;
              end;
              if ( l_flag <>'Y' ) then
                  FND_MESSAGE.SET_NAME('FUN','FUN_NET_MULTI_CUR_FLAG_ERR');
                  RAISE FND_API.G_EXC_ERROR;
              end if;
         end if;
      END IF;
END Validate_multi_currency_flag;
/*************************************************************************
| Procedure : Perform_common_tasks.                                      |
| Sets the Agreement Status to 'N' and also unlocks AP Payment Schdedules|
| Called when the settlement process is committed or when an Exception is|
| raised                                                                 |
**************************************************************************/
 PROCEDURE perform_common_tasks
 IS
	l_return_status VARCHAR2(1);
 BEGIN
  	   unlock_ap_pymt_schedules(
			  p_batch_id 	 	=> g_batch_id,
    	  		x_return_status 	=>  l_return_status);
		 -- Update Agreement Status
		 	 	Set_Agreement_Status(
	 			x_agreement_id => g_batch_details.agreement_id,
	 			x_batch_id  => g_batch_id,
            			x_mode		=> 'UNSET',
				x_return_status => l_return_status);
			-- Unlock AP and AR Transactions
            -- AR Transactions will be unlocked automatically when a COMMIT is
            -- issued.
    EXCEPTION
     WHEN OTHERS THEN
       null;
 	END perform_common_tasks;
    PROCEDURE submit_net_batch (
            -- ***** Standard API Parameters *****
            p_init_msg_list     IN VARCHAR2 := FND_API.G_TRUE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id          IN  NUMBER) IS
        l_ap_bal            fun_net_ap_invs_all.open_amt%TYPE;
        l_ar_bal            fun_net_ar_txns_all.open_amt%TYPE;
        l_status_flag       VARCHAR2(1);
        l_TP_approver       fun_net_agreements_all.approver_name%TYPE;
        l_return_status     VARCHAR2(1);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(2000);
        l_batch_status      fun_net_batches_all.settlement_date%TYPE;
        l_Request_id        fnd_concurrent_requests.request_id%TYPE;
        l_batch_status_flag   BOOLEAN;
	VALIDATE_SETTLEMENT_DATE_FAIL    EXCEPTION;
        CURSOR c_TP_approver IS
        SELECT approver_name
        FROM FUN_NET_AGREEMENTS
        WHERE agreement_id = g_agreement_id;
        l_path      VARCHAR2(100);
    BEGIN
        l_path := g_path||'submit_net_batch';
        fun_net_util.Log_String(g_state_level,l_path,'Start submit batch');
        /* Intialize standard API parameters */
        /* Intialize message list */
        x_msg_count				:=	NULL;
        x_msg_data				:=	NULL;
        -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        -- ****  Initialize return status to SUCCESS   *****
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        /* Create Save point */
        SAVEPOINT submit_net_batch_SP;
        /* Validate Mandatory parameters */
        /* Get Batch Details for the given batch id*/
        IF p_batch_id  IS NULL THEN
  fun_net_util.Log_String(g_state_level,l_path,'Batch id passed to submit netting batch procedure is null');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        g_batch_id := p_batch_id;
        IF NOT get_batch_details THEN
 fun_net_util.Log_String(g_state_level,l_path,'Unable to get batch details for the netting batch with batch id :'||g_batch_id);
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        fun_net_util.Log_String(g_state_level,l_path,'Validating batch');
        /* Compares Final AP and AR Balances. Need to check the balance as the batch might have been modified by  the user  */
        g_agreement_id := g_batch_details.agreement_id;
        IF NOT get_agreement_details THEN
               fun_net_util.Log_String(g_event_level,l_path,
				      'Error getting Agreement details');
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        Validate_multi_currency_flag;
        SELECT ALLOW_DISC_FLAG into l_allow_disc_flag FROM FUN_NET_AGREEMENTS_all WHERE Agreement_id=g_agreement_id;  -- ADDED FOR ESD
        IF l_allow_disc_flag='Y' THEN     -- ADDED FOR ESD
		-- calculate_approx_netted_amount
		AP_AR_balances_with_approxdisc(l_ar_bal, l_ap_bal, l_status_flag);
        ELSE
		Validate_AP_AR_balances(l_ar_bal,l_ap_bal,l_status_flag);
 	END IF;
       -- Check for negative AP or AR balances
       IF l_ar_bal < 0 or l_ap_bal < 0 THEN
         FND_MESSAGE.SET_NAME('FUN','FUN_NET_BATCH_NEG_AP_AR_BAL');
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF g_net_balance_rule='NET_PAYABLES' and  l_ar_bal > l_ap_bal THEN
          FND_MESSAGE.SET_NAME('FUN','FUN_NET_AR_BAL_LESS_THAN_AP');
          RAISE FND_API.G_EXC_ERROR;
       END IF;
        IF l_status_flag = FND_API.G_TRUE then
	 SELECT ALLOW_DISC_FLAG                                          -- ADDED FOR ESD BY SRAMPURE
          INTO l_allow_disc_flag
          FROM FUN_NET_AGREEMENTS_all
          WHERE Agreement_id = g_agreement_id;
          IF l_allow_disc_flag = 'Y' AND TRUNC(g_batch_details.settlement_date) < TRUNC(SYSDATE) THEN
            fun_net_util.Log_String(g_event_level,l_path,
          'Error Validating settlement date for ESD batch');
             RAISE VALIDATE_SETTLEMENT_DATE_FAIL;
          END IF;
        /*Check for Trading Partner Approval and set status to Submitted if TP approval is required*/
            IF g_batch_details.settlement_date < TRUNC(SYSDATE) THEN
                fun_net_util.Log_String(g_state_level,l_path,'Setting status to SUSPENDED');
                UPDATE fun_net_batches
                SET batch_status_code = 'SUSPENDED'
                WHERE batch_id = g_batch_id;
                g_batch_details.batch_status_code := 'SUSPENDED';
            ELSE
                OPEN c_TP_approver;
                FETCH c_TP_approver INTO l_TP_approver;
                CLOSE c_TP_APPROVER;
                IF l_TP_approver IS NOT NULL THEN
                    IF g_batch_details.batch_status_code IN ( 'SELECTED','REJECTED','ERROR' ) THEN
                        fun_net_util.Log_String(g_state_level,l_path,'Setting status to SUBMITTED');
                        UPDATE fun_net_batches
                        SET batch_status_code = 'SUBMITTED'
                        WHERE batch_id = g_batch_id;
                        g_batch_details.batch_status_code := 'SUBMITTED';
                        fun_net_util.Log_String(g_state_level,l_path,'Raising WF business event');
                        fun_net_approval_wf.raise_approval_event(g_batch_id);
                    END IF;
                ELSIF g_batch_details.batch_status_code IN('SELECTED','ERROR') THEN   /* TP Approval is not necessary */
                /* If TP approval is not necessary call Netting Settlement Date API  */
                    /*l_batch_status := validate_netting_dates(
                        p_init_msg_list     => FND_API.G_FALSE,
                        p_commit            => FND_API.G_FALSE,
                        x_return_status     => l_return_status,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data,
                        p_batch_id          => g_batch_id,
                        p_net_settle_date   => g_batch_details.settlement_date,
                        p_response_date     => NULL);
                    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        g_batch_details.batch_status_code := l_batch_status;
                    END IF; */
                    UPDATE fun_net_batches
                    SET batch_status_code = 'APPROVED'
                    WHERE batch_id = g_batch_id;
                    fun_net_util.Log_String(g_state_level,l_path,'Setting status to APPROVED');
                    g_batch_details.batch_status_code := 'APPROVED';
                END IF;
            END IF;
        ELSE
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF g_batch_details.batch_status_code = 'APPROVED' then
            UPDATE fun_net_batches
            SET batch_status_code = 'CLEARING'
            WHERE batch_id = g_batch_id;
            fun_net_util.Log_String(g_state_level,l_path,'Setting status to CLEARING');
            --settle_net_batch(g_batch_id);
            COMMIT;
            l_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'FUN'
                                                         , 'FUNNTSTB'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , g_batch_id
                                                         );
            fun_net_util.Log_String(g_state_level,l_path,'Settle batch request:'||l_request_id);
        END IF;
        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO submit_net_batch_SP;
      	    l_batch_status_flag := update_batch_status('ERROR');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO submit_net_batch_SP;
      	    l_batch_status_flag := update_batch_status('ERROR');
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
	 WHEN VALIDATE_SETTLEMENT_DATE_FAIL THEN                                -- ADDED FOR ESD BY SRAMPURE
            ROLLBACK TO submit_net_batch_SP;
            l_batch_status_flag := update_batch_status('CANCELLED');
            perform_common_tasks;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
        WHEN OTHERS THEN
            ROLLBACK TO submit_Net_Batch_SP;
      	    l_batch_status_flag := update_batch_status('ERROR');
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                --FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Add_Exc_Msg( 'FUN_ARAP_NET_PKG', 'submit_net_batch');
            END IF;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
    END submit_net_batch;
    FUNCTION Validate_Netting_Dates(
            -- ***** Standard API Parameters *****
            p_init_msg_list     IN VARCHAR2 := FND_API.G_TRUE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id          IN NUMBER,
            p_net_settle_date   IN DATE,
            p_response_date     IN DATE) RETURN VARCHAR2 IS
        l_non_response_action   fun_net_agreements_all.non_response_action_code%TYPE;
l_path varchar2(200);
        CURSOR c_non_response_action IS
        SELECT non_response_action_code
        FROM FUN_NET_AGREEMENTS
        WHERE agreement_id = g_agreement_id;
    BEGIN
        l_path := g_path||'batch_exists';
        /* Initialize standard API parameters */
        x_msg_count				:=	NULL;
        x_msg_data				:=	NULL;
        -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        -- ****  Initialize return status to SUCCESS   *****
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        /* Create Save point */
        SAVEPOINT validate_netting_dates_SP;
        /* Validate Mandatory parameters */
        /* Get Batch Details for the given batch id*/
        IF p_batch_id IS NULL OR (p_net_settle_date IS NULL AND p_response_date IS NULL) THEN
            fun_net_util.Log_String(g_state_level,l_path,'One of the mandatory arguments passed to the validate_netting_dates procedure is null');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        g_batch_id := p_batch_id;
        /* Validate NSD with the date of
        when the Netting Batch is changed from Submitted to Approved.
        This will be called by workflow when the TP approves a batch
        and also by the Submit Netting Batch API when TP approval is not required .*/
        IF p_net_settle_date IS NOT NULL THEN
            IF TRUNC(p_net_settle_date) < TRUNC(SYSDATE) THEN
  fun_net_util.Log_String(g_state_level,l_path,'The netting batch with batch_id:'||g_batch_id||'has gone past the netting settlement date');
                --Error ' Batch has gone past the Netting Settlement Date';
                IF NOT Update_batch_status('SUSPENDED') THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSE
                    RETURN 'SUSPENDED';
                END IF;
            ELSE
                IF NOT update_batch_status ('APPROVED') THEN
  fun_net_util.Log_String(g_state_level,l_path,'Unable to update the batch status to approved');
                    RAISE FND_API.G_EXC_ERROR;
                ELSE
                    RETURN 'APPROVED';
                END IF;
            END IF;
        END IF;
        /* Check for the ' No response' action when there is no response
        to the notification and set status accordingly.
        This will  be called by workflow */
        IF p_response_date IS NOT NULL THEN
            OPEN c_non_response_action;
            FETCH c_non_response_action INTO l_non_response_action;
            CLOSE c_non_response_action;
            IF l_non_response_action IS NULL THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF TRUNC(p_response_date) < TRUNC(SYSDATE) THEN
                IF  l_non_response_action = 'APPROVE' then
                    IF NOT Update_batch_status('APPROVED') THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    RETURN 'APPROVED';
                ELSIF l_non_response_action = 'REJECT' THEN
                    IF NOT Update_batch_status('REJECTED') THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    RETURN 'REJECTED';
                END IF;
            END IF;
        END IF;
        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
    EXCEPTION
    /* Handle standard exceptions */
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO validate_netting_dates_SP;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO validate_netting_dates_SP;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
        WHEN OTHERS THEN
            ROLLBACK TO validate_netting_dates_SP;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                --FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Add_Exc_Msg( 'FUN_ARAP_NET_PKG', 'validate_netting_dates');
            END IF;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
    END Validate_Netting_Dates;
    PROCEDURE Set_Agreement_Status(
            x_batch_id  IN fun_net_batches.batch_id%TYPE,
            x_agreement_id IN fun_net_agreements.agreement_id%TYPE,
            x_mode	    IN  VARCHAR2,
	    x_return_status OUT NOCOPY VARCHAR2)
    IS
    	l_agreement_id	fun_net_agreements.agreement_id%TYPE;
    BEGIN
        x_return_status := FND_API.G_TRUE;
    	IF x_agreement_id IS NOT NULL THEN
    		SELECT 	agreement_id
    		INTO 	l_agreement_id
		FROM 	fun_net_batches
    		WHERE 	agreement_id = x_agreement_id
    		AND 	batch_id <> x_batch_id
    		AND 	batch_status_code IN ('RUNNING',
    	 			  'SELECTED',
    				  'SUBMITTED',
    				  'REVERSING',
    				  'CLEARING');
    	ELSE
		x_return_status := FND_API.G_FALSE;
	END IF;
    EXCEPTION
    	WHEN TOO_MANY_ROWS THEN
			null;
    	WHEN NO_DATA_FOUND THEN
    	   IF x_mode  = 'SET' THEN
                FUN_NET_AGREEMENTS_PKG.Update_Row(
                x_agreement_id => x_agreement_id,
                x_in_process_flag => 'Y');
           ELSIF x_mode = 'UNSET' THEN
                FUN_NET_AGREEMENTS_PKG.Update_Row(
                 x_agreement_id => x_agreement_id,
                 x_in_process_flag => 'N');
           END IF;
	WHEN OTHERS THEN
    		x_return_status := FND_API.G_FALSE;
    END Set_Agreement_Status;
/* Derive Bank Account Information.  Find the Bank Account Use Id
   from the Bank Account Id.  Netting Bank is stored in the agreement details */
    PROCEDURE Get_Netting_Bank_Details(
             p_bank_acct_use_id OUT  NOCOPY NUMBER,
       	     p_bank_acct_name OUT NOCOPY VARCHAR2,
             p_bank_acct_num OUT NOCOPY ce_bank_accounts.bank_account_num%TYPE,
             p_le_id OUT NOCOPY NUMBER,
             p_bank_num OUT NOCOPY VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2)
    IS
    BEGIN
        p_return_status := FND_API.G_TRUE;
	   SELECT bank_acct_use_id ,
	         ac.bank_account_name,
		 ac.bank_account_num,
		 ac.account_owner_org_id,
		 ba.bank_number
	   INTO  p_bank_acct_use_id,
        	 p_bank_acct_name,
            	 p_bank_acct_num,
            	 p_le_id,
            	 p_bank_num
       FROM   ce_bank_acct_uses ac_use,
    	      ce_bank_accounts ac,
	      ce_banks_v ba
       WHERE  ac.bank_account_id = g_bank_account_id
       AND    ac.bank_account_id = ac_use.bank_account_id
       AND    ac_use.org_id = g_batch_details.org_id
       AND    ba.bank_party_id = ac.bank_id;
    EXCEPTION
    WHEN OTHERS THEN
        p_return_status := FND_API.G_FALSE;
    END Get_Netting_Bank_Details;
/* Get the Customer Details to Create Receipt . If there is more than
   one customer with the same priority then select the customer with
   minimum customer id */
    PROCEDURE Get_Customer_Details (p_cust_acct_id OUT NOCOPY  NUMBER,
                                    p_cust_site_use_id OUT NOCOPY NUMBER,
                                    p_return_status OUT NOCOPY VARCHAR2)
    IS
    BEGIN
            p_return_status := FND_API.G_TRUE;
        	/* Select First Customer Account on Receipt */
            SELECT min(cust_account_id)
            INTO p_cust_acct_id
            FROM   fun_net_customers ca
            WHERE  ca.agreement_id = g_agreement_id
            AND cust_priority = 1;
	   -- Bug 6982905. added AND u.org_id = fc.org_id to the query
           --Bug: 9643764.
	      SELECT u.site_use_id
	      INTO p_cust_site_use_id
	      FROM fun_net_customers_all fc,
		   hz_cust_acct_sites_all s,
		   hz_cust_site_uses_all u
	      WHERE fc.agreement_id = g_agreement_id
	       AND fc.cust_account_id = p_cust_acct_id
	       AND fc.cust_account_id = s.cust_account_id
	       AND s.cust_acct_site_id = u.cust_acct_site_id
	       AND ((u.site_use_id = fc.cust_site_use_id AND (u.primary_flag='Y'
							      OR (1 = (
								       SELECT count(*)
								       FROM fun_net_customers_all fc1
								       WHERE fc1.agreement_id = fc.agreement_id
								       AND fc1.cust_site_use_id is not null
								       AND fc1.cust_account_id = p_cust_acct_id
								       )
								   AND u.primary_flag <> 'Y'
								  ))
			AND u.site_use_code='BILL_TO')
		    OR ( u.site_use_code = 'BILL_TO' AND u.primary_flag = 'Y'
			   AND fc.cust_site_use_id IS NULL)
		   )
               AND u.org_id = fc.org_id ;

    EXCEPTION
    WHEN OTHERS THEN
        p_return_status := FND_API.G_FALSE;
    END Get_Customer_Details;
/* Unlocks Payment Schedule lines */
    PROCEDURE unlock_ap_pymt_schedules(
		p_batch_id		IN fun_net_batches.batch_id%TYPE,
                x_return_status OUT NOCOPY  VARCHAR2)
    IS
     PRAGMA AUTONOMOUS_TRANSACTION;
     l_checkrun_id ap_inv_selection_criteria_all.checkrun_id%TYPE;
     l_path                  varchar2(200);
     l_org_id     NUMBER(15);
    BEGIN
        x_return_status := FND_API.G_TRUE;
        l_path := g_path||'unlock_payment_schedules';
      -- Check for Mandatory Parameters
        IF p_batch_id IS NULL THEN
	   		x_return_status := FND_API.G_FALSE;
	END IF;
      -- Select the checkrun ID for the
      -- Netting Batch
         SELECT checkrun_id , org_id
           INTO l_checkrun_id , l_org_id
           FROM fun_net_batches_all
          WHERE batch_id = p_batch_id ;
        UPDATE AP_PAYMENT_SCHEDULES_ALL
        SET checkrun_id = NULL
        WHERE checkrun_id =l_checkrun_id
         AND  org_id = l_org_id;
        IF SQL%FOUND THEN
            COMMIT;
        ELSIF SQL%NOTFOUND THEN
            ROLLBACK;
            RETURN;
        END IF;
        UPDATE FUN_NET_BATCHES_ALL
        SET checkrun_id = NULL
        WHERE batch_id = p_batch_id ;
        IF SQL%FOUND THEN
            COMMIT;
        ELSE
            ROLLBACK;
            x_return_status := FND_API.G_FALSE;
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
fun_net_util.Log_String(g_state_level,l_path,'error while unlocking payment schedules');
      x_return_status := FND_API.G_FALSE;
    END unlock_ap_pymt_schedules;
/* Derives Netting Exchange Rate . Returns 1 if the from and the to
   currency are the same . If the Rate type = 'User' then derives the
   rate from fun_net_batches table */
    FUNCTION Derive_Net_Exchg_Rate(x_from_currency IN VARCHAR2,
                                    x_to_currency IN VARCHAR2)
    RETURN NUMBER
    IS
    x_exchange_rate fun_net_batches_all.exchange_rate%TYPE;
    l_exchange_rate_type fun_net_batches_all.exchange_rate_type%TYPE;
        l_path              varchar2(100);
    BEGIN
        l_path      := g_path || 'Derive net exchange';
        IF x_from_currency = x_to_currency THEN
            x_exchange_rate := 1.0;
            RETURN x_exchange_rate;
        END IF;
fun_net_util.Log_String(g_state_level,l_path,'x_from_currency:'||x_from_currency);
fun_net_util.Log_String(g_state_level,l_path,'x_to_currency:'||x_to_currency);
fun_net_util.Log_String(g_state_level,l_path,g_batch_details.exchange_rate_type);
        IF g_batch_details.exchange_rate_type = 'User' then
            x_exchange_rate := (1/g_batch_details.exchange_rate);
            Return x_exchange_rate;
        ELSIF g_batch_details.exchange_rate_type IS NOT NULL THEN
            l_exchange_rate_type :=  g_batch_details.exchange_rate_type;
        ELSE
             SELECT default_exchange_rate_type
               INTO l_exchange_rate_type
               FROM ap_system_parameters_all
              WHERE org_id = g_batch_details.org_id;
        END IF;
        IF l_exchange_rate_type IS NOT NULL THEN
           IF gl_currency_api.rate_exists(
			x_from_currency,
                        x_to_currency,
                        g_batch_details.settlement_date,
                        g_batch_details.exchange_rate_type) = 'Y' THEN
                 x_exchange_rate := gl_currency_api.get_rate(
				  x_from_currency,
                                  x_to_currency,
                                  g_batch_details.settlement_date,
                                  g_batch_details.exchange_rate_type);
            ELSE
                RETURN null;
            END IF;
        END IF;
        RETURN x_exchange_rate;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
    END Derive_Net_Exchg_Rate;
    PROCEDURE Validate_Settlement_Period(
	x_appln_id       IN fnd_application.application_id%TYPE,
	x_period_name    OUT NOCOPY VARCHAR2,
        x_return_status  OUT NOCOPY VARCHAR2,
	x_return_msg	  OUT NOCOPY VARCHAR2)
    IS
	l_ledger_id		gl_ledgers.ledger_id%TYPE;
	x_closing_status	gl_period_statuses.closing_status%TYPE;
	x_period_year		gl_period_statuses.period_year%TYPE;
    	x_period_num		gl_period_statuses.period_num%TYPE;
    	x_period_type		gl_period_statuses.period_type%TYPE;
        l_path                  varchar2(200);
	BEGIN
        l_path := g_path||'validate_settlement_period';
      /* Check if GL Period is open*/
         x_return_status := FND_API.G_TRUE;
		 SELECT set_of_books_id
    	 	 INTO l_ledger_id
		 FROM hr_operating_units
		 WHERE organization_id = g_batch_details.org_id;
		GL_PERIOD_STATUSES_PKG.get_period_by_date(
		   x_appln_id,
		   l_ledger_id,
		  nvl(g_batch_details.gl_date,g_batch_details.settlement_date),
		  x_period_name,
		  x_closing_status,
 	          x_period_year,
		  x_period_num,
	          x_period_type);
		IF (x_period_name IS NULL and x_closing_status IS NULL) OR
		   x_closing_status not in ('O','F') THEN
			x_return_status := FND_API.G_FALSE;
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
            fun_net_util.Log_String(g_state_level,l_path,'The GL period for the settlement of netting batch is closed or not yet opened ');
		x_return_status := FND_API.G_FALSE;
	END Validate_Settlement_Period;
/* Creates AP Check per vendor / vendor site / currency . Also creates
   invoice payments for each AP Check */
    PROCEDURE settle_ap_invs(
        p_bank_acct_use_id IN ce_bank_acct_uses_all.bank_acct_use_id%TYPE,
        p_bank_acct_name   	IN ce_bank_accounts.bank_account_name%TYPE,
        p_bank_acct_num    	IN ce_bank_accounts.bank_account_num%TYPE,
        p_le_id			IN xle_entity_profiles.legal_entity_id%TYPE,
        p_bank_num         	IN ce_banks_v.bank_number%TYPE,
        x_return_status    	OUT NOCOPY VARCHAR2)
    IS
     l_vendor_name       po_vendors.vendor_name%TYPE;
     l_vendor_site_code  po_vendor_sites_all.vendor_site_code%TYPE;
     l_check_id          ap_checks.check_id%TYPE;
     l_old_invoice	 ap_invoices.invoice_id%TYPE;
     amt_remaining	 ap_payment_schedules.amount_remaining%TYPE;
     l_bank_num          ce_banks_v.bank_number%TYPE;
     -- Bug: 8537760
     l_amt_to_net        fun_net_ap_invs.netted_amt%TYPE;
     l_applieddisc       NUMBER;
     l_return_status 	 VARCHAR2(1);
     m integer;
     l_path		VARCHAR2(100);
     l_gl_date          date;  -- Bug: 7639863
  TYPE vendor_type IS TABLE OF po_vendors.vendor_id%TYPE INDEX BY BINARY_INTEGER;
     TYPE vendor_site_type  IS TABLE OF po_vendor_sites_all.vendor_site_id%TYPE INDEX BY BINARY_INTEGER;
     TYPE currency_type     IS TABLE OF fnd_currencies.currency_code%TYPE INDEX BY BINARY_INTEGER;
     TYPE ap_check_amt_type IS TABLE OF ap_checks.amount%TYPE INDEX BY BINARY_INTEGER;
     TYPE ap_invoice_type   IS TABLE OF ap_invoices.invoice_id%TYPE INDEX BY BINARY_INTEGER;
     TYPE party_type  IS TABLE OF ap_invoices_all.party_id%TYPE INDEX BY BINARY_INTEGER;
     TYPE party_site_type  IS TABLE OF ap_invoices_all.party_site_id%TYPE INDEX BY BINARY_INTEGER;
     ap_check_amt_list        ap_check_amt_type;
     ap_check_base_amt_list   ap_check_amt_type;
     vendor_list          vendor_type;
     vendor_site_list     vendor_site_type;
     currency_list        currency_type;
     amtDueTab  	 ap_check_amt_type;
     ap_invoice         ap_invoice_type;
     party_list          party_type;
     party_site_list     party_site_type;
     ap_payment_info_tab 	AP_PAYMENT_PUBLIC_PKG.Invoice_Payment_Info_Tab;
     ap_check_rec 		ap_checks_all%ROWTYPE;
     p_schd_tab			pymt_sch_tab;
    BEGIN
	 -- Group Invoices by Vendor , Vendor Site and Payment Currency .
	     x_return_status := FND_API.G_TRUE;
             BEGIN
             l_path := g_path || 'Settle AP Transactions';
       fun_net_util.Log_String(g_event_level,l_path,'Group AP Invoices');
            	SELECT
		 sum(finv.inv_curr_net_amt) AS pymt_amt,
         --        sum(finv.netted_amt) AS base_pymt_amt,
                        inv.vendor_id,
                        inv.vendor_site_id,
                        inv.party_id,
                        inv.party_site_id,
                        inv.payment_currency_code
                BULK COLLECT INTO ap_check_amt_list,
          --                        ap_check_base_amt_list,
                                  vendor_list,
                                  vendor_site_list,
                                  party_list,
                                  party_site_list,
                                  currency_list
                FROM	fun_net_ap_invs finv,
                    	ap_invoices inv
            	WHERE   inv.invoice_id = finv.invoice_id
                AND 	finv.batch_id = g_batch_details.batch_id
                AND     finv.inv_curr_net_amt <> 0
            	GROUP BY vendor_id,
			 vendor_site_id,
			 party_id,
			 party_site_id,
			 inv.payment_currency_code;
              EXCEPTION
                WHEN OTHERS THEN
       fun_net_util.Log_String(g_event_level,l_path,sqlcode || sqlerrm);
                    RAISE FND_API.G_EXC_ERROR;
              END;
      fun_net_util.Log_String(g_event_level,l_path,'Processing Txns by Vendor'||
                                 vendor_list.count);
                FOR i IN  1..vendor_list.count
                LOOP
      fun_net_util.Log_String(g_event_level,l_path,'vendor_id'|| vendor_list(i));
            	/* Get Vendor Name and Vendor Site Name */
      	 ap_check_rec.VENDOR_NAME	:= PO_VENDORS_SV.get_vendor_name_func(
			 		vendor_list(i));
     fun_net_util.Log_String(g_event_level,l_path,'vendor_site_id'||vendor_site_list(i));
        PO_VENDOR_SITES_SV.get_vendor_site_name(
					vendor_site_list(i),
					ap_check_rec.vendor_site_code);
               ap_check_rec.vendor_id  	:= vendor_list(i);
               ap_check_rec.vendor_site_id  := vendor_site_list(i);
                /* Get Check Number from Sequence */
               SELECT fun.fun_net_ap_checks_s.nextval
               INTO ap_check_rec.check_number
               FROM DUAL;
                ap_check_rec.CHECK_DATE	:=  g_batch_details.settlement_date;
		l_gl_date := nvl(g_batch_details.gl_date, g_batch_details.settlement_date); /* 7639863  */
               IF currency_list(i) = g_func_currency THEN
                   ap_check_rec.exchange_rate := 1.0;
               ELSE
        --           ap_check_rec.BASE_AMOUNT     :=  ap_check_base_amt_list(i);
                   ap_check_rec.exchange_rate   :=  Derive_Net_Exchg_rate(
	                                 		currency_list(i),
                                                    g_func_currency);
                     ap_check_rec.BASE_AMOUNT := ap_check_amt_list(i)*ap_check_rec.exchange_rate;
              END IF;
        ap_check_rec.exchange_rate_type	:=  g_batch_details.exchange_rate_type;
        ap_check_rec.EXCHANGE_DATE	:= g_batch_details.settlement_date;
        ap_check_rec.currency_code 	:= currency_list(i);
     --   ap_check_rec.amount  		:= (ap_check_amt_list(i)/ap_check_rec.exchange_rate);
fun_net_util.Log_String(g_event_level,l_path,'ap_check_amt_list(i) :'|| ap_check_amt_list(i));
      ap_check_rec.amount      := ap_check_amt_list(i);
   --      ap_check_rec.BASE_AMOUNT	 :=  ap_check_amt_list(i) ;
        --ap_check_rec.cleared_amount := ap_check_rec.amount;
        --ap_check_rec.cleared_date := ap_check_rec.check_date;
 	ap_check_rec.CHECKRUN_ID	 := g_batch_details.checkrun_id;
 	ap_check_rec.CE_BANK_ACCT_USE_ID:= p_bank_acct_use_id;
     	ap_check_rec.BANK_ACCOUNT_ID	:=  g_bank_account_id;
 	ap_check_rec.BANK_ACCOUNT_NAME	:= p_bank_acct_name;
	 ap_check_rec.party_id := party_list(i);
     ap_check_rec.party_site_id := party_site_list(i);
	ap_check_rec.LAST_UPDATED_BY 	:=  fnd_global.user_id;
	ap_check_rec.LAST_UPDATE_DATE	:= sysdate;
	ap_check_rec.CREATED_BY 	:= fnd_global.user_id;
	ap_check_rec.CREATION_DATE	:= sysdate;
 	ap_check_rec.LAST_UPDATE_LOGIN	:= fnd_global.login_id;
  	ap_check_rec.PAYMENT_TYPE_FLAG	:= 'N';
  	ap_check_rec.PAYMENT_METHOD_LOOKUP_CODE := 'N';
	ap_check_rec.ORG_ID		:= g_batch_details.org_id;
        ap_check_rec.LEGAL_ENTITY_ID 	:= p_le_id;
        ap_check_rec.CHECKRUN_NAME  := g_batch_details.batch_number;
/* Selects invoices per vendor. Amt to be paid reflects the total amount to to be paid per invoice. Calculate the amt to be paid per installment */
       fun_net_util.Log_String(g_event_level,
                               l_path,
                    ' checkrun_id :'||g_batch_details.checkrun_id  ||
                    ' batch_id :'||g_batch_details.batch_id ||
                    ' currency :' || currency_list(i) );
	BEGIN
                 SELECT
          	        inv.invoice_id         AS invoice_id,
          	        apps.payment_num       AS payment_num,
                        finv.inv_curr_net_amt  AS pymt_amt,
			gl_currency_api.convert_amount_sql(
				inv.invoice_currency_code,
				g_batch_details.batch_currency,
				g_batch_details.settlement_date,
				g_batch_details.exchange_rate_type,
				NVL(finv.APPLIED_DISC,0)) As Discount_Taken
			--NVL(finv.APPLIED_DISC,0) As Discount_Taken    -- ER
			--Amt in Payment Currency = Invoice Currency
                 BULK COLLECT INTO
	                 ap_payment_info_tab
	             FROM
                       	 ap_invoices inv,
            	         fun_net_ap_invs finv,
                         ap_payment_schedules apps
                 WHERE   finv.invoice_id  = inv.invoice_id
                 AND     apps.invoice_id = inv.invoice_id
                 AND     apps.checkrun_id = g_batch_details.checkrun_id
            	 AND   	 finv.batch_id = g_batch_details.batch_id
                 AND     inv.vendor_id = vendor_list(i)
                 AND     inv.vendor_site_id = vendor_site_list(i)
                 AND     inv.invoice_currency_code = currency_list(i)
                 AND     finv.inv_curr_net_amt <> 0
		 ORDER BY inv.invoice_id,apps.payment_num;
	EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_ERROR;
	END;
        m := 0;
        IF (ap_invoice.EXISTS(1)) THEN
               ap_invoice.DELETE;
         END IF;
         /* Calculate the  Amount to be netted per Payment Schedule  */
	 --Bug: 8359081
         SELECT amount_remaining
         BULK COLLECT INTO amtDueTab
         FROM
	         ap_invoices inv,
                 fun_net_ap_invs finv,
                 ap_payment_schedules apps
         WHERE   finv.invoice_id  = inv.invoice_id
                 AND     apps.invoice_id = inv.invoice_id
                 AND     apps.checkrun_id = g_batch_details.checkrun_id
            	 AND   	 finv.batch_id = g_batch_details.batch_id
                 AND     inv.vendor_id = vendor_list(i)
                 AND     inv.vendor_site_id = vendor_site_list(i)
                 AND     inv.invoice_currency_code = currency_list(i)
                 AND     finv.inv_curr_net_amt <> 0
	 ORDER BY inv.invoice_id,apps.payment_num;
         l_old_invoice := 0;
       fun_net_util.Log_String(g_event_level,
			       l_path
		               ,'Calculating Amt to be paid by Schedule');
       fun_net_util.Log_String(g_event_level,
                               l_path
                               ,'ap_payment_info_tab.count:'||
                                ap_payment_info_tab.count);
         FOR j in 1..ap_payment_info_tab.count
         LOOP
          fun_net_util.Log_String(g_event_level,
                                  l_path,
                                  'j' || j);
          fun_net_util.Log_String(
			     g_event_level,
                             l_path,
                            'invoice_id' || ap_payment_info_tab(j).invoice_id);
          fun_net_util.Log_String(
		 g_event_level,
                 l_path,
                 'payment num' || ap_payment_info_tab(j).payment_schedule_num);
         fun_net_util.Log_String(g_event_level,
                    l_path,
                    'Amt to Pay' || ap_payment_info_tab(j).amount_to_pay);
         fun_net_util.Log_String(g_event_level,
                      l_path,
                      'Amt Remaining' ||amt_remaining);
            IF ap_payment_info_tab(j).invoice_id <> l_old_invoice THEN
	    -- Bug: 8537760
	          l_amt_to_net := ap_payment_info_tab(j).amount_to_pay;
                  amt_remaining := ap_payment_info_tab(j).amount_to_pay;
	    	      m:= m + 1;
	    	      ap_invoice(m) :=  ap_payment_info_tab(j).invoice_id;
            END IF;
	   IF amt_remaining < 0 THEN
	      IF amtDueTab(j) >= amt_remaining THEN
    	       	    ap_payment_info_tab(j).amount_to_pay := amtDueTab(j);
                    amt_remaining  := amt_remaining - amtDuetab(j);
              ELSE
       	 	        ap_payment_info_tab(j).amount_to_pay := amt_remaining;
       	 	        amt_remaining := 0;
	       END IF;
	   ELSE -- Amounts are positive
               IF amt_remaining >= amtDueTab(j) THEN
    	            	ap_payment_info_tab(j).amount_to_pay := amtDueTab(j);
                        amt_remaining  := amt_remaining - amtDueTab(j);
               ELSE
       	                ap_payment_info_tab(j).amount_to_pay := amt_remaining;
	       	        amt_remaining := 0 ;
               END IF;
	    END IF; -- Negative Amounts
            l_old_invoice :=  ap_payment_info_tab(j).invoice_id;
            fun_net_util.Log_String(g_event_level,
                    l_path,
                    'Calc Amt to Pay' || ap_payment_info_tab(j).amount_to_pay);
	  -- Bug: 8537760
	  ap_payment_info_tab(j).Discount_Taken := 0;
	  --Bug: 8548026
          IF( get_esd_flag(g_batch_details.batch_id)='Y' AND ap_payment_info_tab(j).amount_to_pay <> 0) THEN
	          l_applieddisc := 0;
		  IF (l_amt_to_net >0 AND amtDuetab(j) >= l_amt_to_net) OR (l_amt_to_net < 0 AND amtDuetab(j) <= l_amt_to_net) THEN
		   l_applieddisc := AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Netted_Amt( ap_payment_info_tab(j).invoice_id,ap_payment_info_tab(j).payment_schedule_num,g_batch_details.settlement_date,l_amt_to_net);
		   --Bug: 8543043.
		   ap_payment_info_tab(j).amount_to_pay := l_amt_to_net;
		  ELSE
		   l_applieddisc := AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Pmt_Schedule( ap_payment_info_tab(j).invoice_id,ap_payment_info_tab(j).payment_schedule_num,g_batch_details.settlement_date);
		   l_amt_to_net := l_amt_to_net - (amtDuetab(j) - l_applieddisc);
		   ap_payment_info_tab(j).amount_to_pay := ap_payment_info_tab(j).amount_to_pay - l_applieddisc;
		  END IF;
		  ap_payment_info_tab(j).Discount_Taken := l_applieddisc;
	  END IF;
         END LOOP;
             /* Call Payment API to create Check and Invoice Payments */
          AP_PAYMENT_PUBLIC_PKG.Create_Netting_Payment(
	        P_Check_Rec    			 => ap_check_rec,
            	P_Invoice_Payment_Info_Tab	 => ap_payment_info_tab,
	        P_Check_ID 			 => l_check_id,
		P_Curr_Calling_Sequence    => 'Netting Settlement Process',
		p_gl_date                  => l_gl_date) ; /* p_gl_date Added for bug#7639863 */
            fun_net_util.Log_String(g_event_level,
                    l_path,
                    'Check ID :'||l_check_id );
             IF  l_check_id is null THEN
                x_return_status := FND_API.G_FALSE;
                RETURN;
             END IF;
             	/* Update FUN_NET_AP_INVS all with the check Id */
            	BEGIN
            	   FORALL k IN ap_invoice.FIRST..ap_invoice.LAST
             		UPDATE FUN_NET_AP_INVS
             		SET check_id = l_check_id
             		WHERE batch_id = g_batch_id
			AND inv_curr_net_amt <> 0
                    AND invoice_id = ap_invoice(k);
             	END;
           END LOOP;
	EXCEPTION
	  WHEN OTHERS THEN
	  	x_return_status := FND_API.G_FALSE;
		RETURN;
	END;
/* Calculates the Total Open Amount for an AR Transaction based on the
   Due date of the batch */
FUNCTION Calculate_AR_Txn_Open_Amt(
	p_customer_trx_id 	IN ra_customer_trx.customer_trx_id%TYPE,
	p_inv_currency_code	 IN ra_customer_trx.invoice_currency_code%TYPE,
	p_exchange_rate 	IN ra_customer_trx.exchange_rate%TYPE)
	RETURN NUMBER
	IS
	l_amount ar_payment_schedules.amount_due_remaining%TYPE;
	BEGIN
		SELECT SUM(decode(p_inv_currency_code,
				  g_batch_details.batch_currency,
	 		 	  amount_due_remaining,
				  p_exchange_rate * amount_due_remaining))
		INTO l_amount
        FROM AR_PAYMENT_SCHEDULES
        WHERE  due_date <= g_batch_details.transaction_due_date
        AND  status = 'OP'
        AND customer_trx_id = p_customer_trx_id;
        RETURN l_amount;
	EXCEPTION
		WHEN OTHERS THEN
		RETURN null;
	END;
	/* Selects all the AR Transactions that need to be locked */
/*PROCEDURE Lock_AR_Txn(
		txnCur 		  IN OUT NOCOPY  txnCurType,
	 	 x_return_status OUT NOCOPY VARCHAR2)
IS
	BEGIN
		x_return_status := FND_API.G_TRUE;
		OPEN txnCur FOR
		SELECT  trx.invoice_currency_code AS invoice_currency_code,
           	    trx.customer_trx_id AS customer_trx_id,
	            trx.trx_number AS trx_number,
	      	    trx_line.customer_trx_line_id AS customer_trx_line_id,
     	        trx_line.line_number AS line_number,
     	        ftxn.transaction_amt AS txn_amt,
     	        trx_line.extended_amount AS line_amt,
                ARPS.payment_schedule_id AS pymt_schedule_id,
                ARPS.amount_due_remaining AS amt_remaining,
                ftxn.netted_amt AS net_amt,
                ftxn.open_amt	AS open_amt,
                Derive_net_exchg_rate(trx.invoice_currency_code,
                      g_func_currency) trans_receipt_rate,
                Derive_net_exchg_rate(g_func_currency,
                      trx.invoice_currency_code) receipt_trans_rate,
                arm.name AS receipt_name,
		arm.payment_type_code AS payment_type_code
        FROM 	FUN_NET_AR_TXNS ftxn,
       		    RA_CUSTOMER_TRX trx,
                RA_CUSTOMER_TRX_LINES trx_line,
    	      	AR_PAYMENT_SCHEDULES ARPS,
    	      	AR_RECEIPT_METHODS arm
    	WHERE	ftxn.customer_trx_id = trx.customer_trx_id
    	AND     trx.customer_trx_id = trx_line.customer_trx_id
        AND     ARPS.customer_Trx_id = trx.customer_Trx_id
        AND	    ARPS.DUE_DATE <= g_batch_details.TRANSACTION_DUE_DATE
    	AND     ARPS.status = 'OP'
      	AND     ftxn.batch_id = g_batch_details.batch_id
      	AND	    arm.receipt_method_id = trx.receipt_method_id
      	ORDER BY ftxn.customer_trx_id;
	--	FOR UPDATE of ftxn.batch_id, trx.customer_trx_id,trx_line.customer_trx_id;
--        arps.payment_schedule_id;
	EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_FALSE;
	END;
*/
	/* Validates the following
	   The current Invoice Amount and the Open Amount against the Amount
           stored in the netting tables.
	   not be CREDIT CARD*/
PROCEDURE Validate_AR_Txns(
      	txnTable	OUT NOCOPY TxnTblType,
	x_return_status OUT NOCOPY VARCHAR2
	)
IS
   	l_old_invoice	ra_customer_trx.customer_trx_id%TYPE;
        l_inv_amt	ra_customer_trx_lines.extended_amount%TYPE;
	l_path		VARCHAR2(100);
	round_diff      ra_customer_trx_lines.extended_amount%TYPE;
	l_count_test  number;
	BEGIN
		x_return_status := FND_API.G_TRUE;
 	l_path := g_path || 'Validate AR Transactions';
       fun_net_util.Log_String(g_event_level,l_path,
				'Validating AR Transactions');
       IF get_esd_flag(g_batch_details.batch_id)='Y' THEN
		--Bug: 8537579. Added 'ftxn.ar_txn_rank' in order by and group by.
		SELECT      trx.customer_trx_id AS customer_trx_id,
				trx.exchange_rate AS inv_exchange_rate,
			sum(ARPS.amount_due_remaining) AS amt_remaining,
			ftxn.transaction_amt AS txn_amount,
			ftxn.open_amt AS open_amt,
			ftxn.txn_curr_open_amt AS txn_curr_open_amt,
			0   AS txn_curr_amt,
			ftxn.txn_curr_net_amt AS txn_curr_net_amt,
			ftxn.netted_amt AS net_amt,
			trx.invoice_currency_code AS invoice_currency_code,
				arm.payment_type_code AS payment_type_code
		BULK COLLECT INTO txnTable
		FROM 	FUN_NET_AR_TXNS ftxn,
			RA_CUSTOMER_TRX trx,
			AR_PAYMENT_SCHEDULES ARPS,
			AR_RECEIPT_METHODS arm,
			RA_CUST_TRX_TYPES ctype
		WHERE	ftxn.customer_trx_id = trx.customer_trx_id
		AND     ARPS.customer_Trx_id = trx.customer_Trx_id
		--AND     ARPS.DUE_DATE <= g_batch_details.TRANSACTION_DUE_DATE
		AND ( arps.terms_sequence_number in (
			 select rtd.sequence_num
			  FROM ra_terms_lines_discounts rtd
			  where rtd.term_id = ARPS.TERM_ID
			  AND rtd.sequence_num = ARPS.TERMS_SEQUENCE_NUMBER
			  and (g_batch_details.TRANSACTION_DUE_DATE) <= ((arps.trx_date)+rtd.discount_days)) OR
			  (((arps.due_date)<=(g_batch_details.TRANSACTION_DUE_DATE))))
		AND     ARPS.DUE_DATE between g_agr_start_date and g_agr_end_date
		AND ((g_sel_past_due_flag='N') OR (g_sel_past_due_flag='Y' AND TRUNC(arps.due_date) + nvl(g_days_past_due,0) < trunc(sysdate) ))    -- Added for Bug No : 8497191
		AND     ARPS.status = 'OP'
		AND     ftxn.batch_id = g_batch_details.batch_id
		AND	arm.receipt_method_id (+) = trx.receipt_method_id
		AND     ctype.cust_trx_type_id = trx.cust_trx_type_id
		and     trx.org_id = ftxn.org_id
		and     trx.org_id = arps.org_id
		and     trx.org_id = ctype.org_id
		GROUP BY trx.customer_trx_id,
			trx.exchange_rate,
			ftxn.transaction_amt,
			ftxn.open_amt,
			ftxn.netted_amt,
			ftxn.txn_curr_open_amt,
			ftxn.txn_curr_net_amt,
			trx.invoice_currency_code,
			arm.payment_type_code,
			ctype.type,
                        ftxn.ar_txn_rank
	       ORDER BY ctype.type, ftxn.ar_txn_rank;
	  ELSE
	  	SELECT      trx.customer_trx_id AS customer_trx_id,
				trx.exchange_rate AS inv_exchange_rate,
			sum(ARPS.amount_due_remaining) AS amt_remaining,
			ftxn.transaction_amt AS txn_amount,
			ftxn.open_amt AS open_amt,
			ftxn.txn_curr_open_amt AS txn_curr_open_amt,
			0   AS txn_curr_amt,
			ftxn.txn_curr_net_amt AS txn_curr_net_amt,
			ftxn.netted_amt AS net_amt,
			trx.invoice_currency_code AS invoice_currency_code,
				arm.payment_type_code AS payment_type_code
		BULK COLLECT INTO txnTable
		FROM 	FUN_NET_AR_TXNS ftxn,
			RA_CUSTOMER_TRX trx,
			AR_PAYMENT_SCHEDULES ARPS,
			AR_RECEIPT_METHODS arm,
			RA_CUST_TRX_TYPES ctype
		WHERE	ftxn.customer_trx_id = trx.customer_trx_id
		AND     ARPS.customer_Trx_id = trx.customer_Trx_id
		AND     ARPS.DUE_DATE <= g_batch_details.TRANSACTION_DUE_DATE
		AND     ARPS.DUE_DATE between g_agr_start_date and g_agr_end_date
		AND     ARPS.status = 'OP'
		AND     ftxn.batch_id = g_batch_details.batch_id
		AND	arm.receipt_method_id (+) = trx.receipt_method_id
		AND     ctype.cust_trx_type_id = trx.cust_trx_type_id
		and     trx.org_id = ftxn.org_id
		and     trx.org_id = arps.org_id
		and     trx.org_id = ctype.org_id
		GROUP BY trx.customer_trx_id,
			trx.exchange_rate,
			ftxn.transaction_amt,
			ftxn.open_amt,
			ftxn.netted_amt,
			ftxn.txn_curr_open_amt,
			ftxn.txn_curr_net_amt,
			trx.invoice_currency_code,
			arm.payment_type_code,
			ctype.type,
                        ftxn.ar_txn_rank
	       ORDER BY ctype.type, ftxn.ar_txn_rank;
	  END IF;
       fun_net_util.Log_String(g_event_level,l_path,'Validating AR Transactions');
           IF txnTable.EXISTS(1) THEN
	       fun_net_util.Log_String(g_event_level,l_path,
	    	'record count   '||txnTable.COUNT);
           FOR i in txnTable.FIRST..txnTable.LAST
           LOOP
        fun_net_util.Log_String(g_event_level,l_path,
			'Txn CurrOpen Amt fail22 ' || txnTable(i).txn_curr_open_amt);
           fun_net_util.Log_String(g_event_level,l_path,
				'Amt Remaining fail22 ' || txnTable(i).amt_remaining);
           fun_net_util.Log_String(g_event_level,l_path,
			'Txn Due Date' || g_batch_details.TRANSACTION_DUE_DATE);
           fun_net_util.Log_String(g_event_level,l_path,
			'Agreement Start Date' || g_agr_start_date);
           fun_net_util.Log_String(g_event_level,l_path,
			'Agreement End Date' || g_agr_end_date);
           fun_net_util.Log_String(g_event_level,l_path,
				'i' || i);
           fun_net_util.Log_String(g_event_level,l_path,
			'Customer Trx Id ' || txnTable(i).customer_trx_id);
       -- Check if the Open Amount in the Netting tables are
	   -- different to the Open Amounts in Payment Schedules
            txnTable(i).txn_curr_amt := calculate_ar_trx_amt
				(txnTable(i).customer_trx_id);
 	    l_inv_amt := fun_net_util.round_currency(
		txnTable(i).txn_curr_amt * nvl(txnTable(i).exchange_rate,1),
	        g_func_currency);
           fun_net_util.Log_String(g_event_level,l_path,
				'Txn Curr Amt' || txnTable(i).txn_curr_amt);
           fun_net_util.Log_String(g_event_level,l_path,
				'Net Txn Amt ' || txnTable(i).txn_amt);
	   fun_net_util.Log_String(g_event_level,l_path,
			        'Txn base amt' || l_inv_amt);
           fun_net_util.Log_String(g_event_level,l_path,
			'Txn CurrOpen Amt' || txnTable(i).txn_curr_open_amt);
           fun_net_util.Log_String(g_event_level,l_path,
				'Amt Remaining' || txnTable(i).amt_remaining);
           fun_net_util.Log_String(g_event_level,l_path,
			'Payment Type' || txnTable(i).payment_type_code);
   -- Check if the Invoice Amount in the Netting table is different
   -- to the Invoice amount in the transaction
               round_diff := txnTable(i).txn_amt - l_inv_amt ;
-- compare the transaction amounts in transaction currecy between the fun tables and the transaction tables.
--	            IF txnTable(i).txn_amt <> l_inv_amt THEN  Commented for bug 5326485
	            IF txnTable(i).txn_curr_amt <> txnTable(i).txn_amt THEN
		    	IF abs(round_diff) > 0.01 THEN
    		   		 x_return_status :=	FND_API.G_FALSE;
                       		 EXIT;
    	    	   	 END IF;
		    END IF;
-- Compare the open amounts in transaction currency between the fun tables and the payment schedules tables.
		   IF (txnTable(i).txn_curr_open_amt
                         <> txnTable(i).amt_remaining) THEN
             fun_net_util.Log_String(g_event_level,l_path,'fails in comparison 2');
              fun_net_util.Log_String(g_event_level,l_path,
			'Txn CurrOpen Amt fail2 ' || txnTable(i).txn_curr_open_amt);
           fun_net_util.Log_String(g_event_level,l_path,
				'Amt Remaining fail2 ' || txnTable(i).amt_remaining);
		   x_return_status :=	FND_API.G_FALSE;
                       EXIT;
   		   END IF;
            -- If the Payment Type = CREDIT CARD  then raise error
		     IF txnTable(i).payment_type_code = 'CREDIT_CARD' THEN
    				x_return_status := FND_API.G_FALSE;
	                EXIT;
		        END IF;
		END LOOP;
	 ELSE
		x_return_status := FND_API.G_FALSE;
	END IF;
	EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_FALSE;
	END Validate_AR_Txns;
PROCEDURE create_cash_receipt(
         pARReceiptRec  IN arReceiptRecType,
         x_cash_receipt_id OUT NOCOPY ar_cash_receipts.cash_receipt_id%TYPE,
         x_return_status OUT NOCOPY VARCHAR2,
         x_msg_data OUT NOCOPY VARCHAR2,
         x_msg_count OUT NOCOPY NUMBER)
IS
	l_path	VARCHAR2(100);
BEGIN
		l_path := g_path || 'Creat Cash Receipt';
		fun_net_util.log_string(g_event_level,l_path
					,'Create Cash Receipt');
	     -- Call AR API Create Cash Receipt per Batch --
		fun_net_util.log_string(g_event_level,l_path,'receipt currency:'||pARReceiptRec.currency_code);
fun_net_util.log_string(g_event_level,l_path,'exchange rate:'||pARReceiptRec.exchange_rate);
fun_net_util.log_string(g_event_level,l_path,'amount:'||pARReceiptRec.amount);
         	AR_RECEIPT_API_PUB.Create_cash(
	           -- Standard API parameters.
                 p_api_version      => 1.0,
                 p_init_msg_list    => FND_API.G_TRUE,
                 p_commit           => FND_API.G_FALSE,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
	            -- Receipt info. Parameters
                 p_currency_code           => pARReceiptRec.currency_code,
                 p_exchange_rate_type      => pARReceiptRec.exchange_rate_type,
                 p_exchange_rate           => pARReceiptRec.exchange_rate,
                 p_exchange_rate_date      => pARReceiptRec.exchange_rate_date,
                 p_amount                  => pARReceiptRec.amount,
                 p_factor_discount_amount  => pARReceiptRec.factor_discount_amount ,
                 p_receipt_number          => pARReceiptRec.receipt_number,
                 p_receipt_date            => pARReceiptRec.receipt_date,
                 p_gl_date                 => pARReceiptRec.gl_date,
                 p_customer_id             => pARReceiptRec.customer_id,
                 p_customer_site_use_id    => pARReceiptRec.customer_site_use_id,
                 p_remittance_bank_account_id  => pARReceiptRec.remittance_bank_account_id,
                 p_remittance_bank_account_num => pARReceiptRec.remittance_bank_account_num,
                 p_remittance_bank_account_name => pARReceiptRec.remittance_bank_account_name,
            	 p_receipt_method_id        	=> pARReceiptRec.receipt_method_id,
                 p_org_id                       => pARReceiptRec.org_id,
                 p_customer_receipt_reference  => g_batch_details.batch_number,
	       --   ** OUT NOCOPY variables
                  p_cr_id                      => x_cash_receipt_id);
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		fun_net_util.log_string(g_event_level,l_path
					,'Cash receipt creation failed either because AR_RECEIPT_API_PUB. Creat_cash failed or there is no receipt class associated ');
FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
 	IF x_msg_count > 1 THEN
                FOR x IN 1..x_msg_count LOOP
                  x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
 fun_net_util.Log_String(g_unexp_level,l_path,'Error message:' ||x_msg_data);
  END LOOP;
        END IF;
                    x_return_status := FND_API.G_FALSE;
                    RETURN;
                  END IF;
 	EXCEPTION
 		WHEN OTHERS THEN
 			x_return_status := FND_API.G_FALSE;
 	END create_cash_receipt;
/*PROCEDURE apply2_cash_receipt
    (txnTable IN txnTblType,
     p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE,
     x_return_status OUT NOCOPY VARCHAR2)
IS
    l_applied_amt       ra_customer_trx_lines.extended_amount%TYPE;
    l_open_amt          ra_customer_trx_lines.extended_amount%TYPE;
    l_line_amt          ra_customer_trx_lines.extended_amount%TYPE;
    current_amt_due     AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
    l_applied_from		ra_customer_trx_lines.extended_amount%TYPE;
    l_exchange_rate     ra_customer_trx_lines.extended_amount%TYPE;
    l_return_status     VARCHAR2(1);
    l_exchange_rate_type varchar2(20);
    l_exchange_rate_date     fun_net_batches.settlement_date%TYPE;
    	l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
CURSOR apply_trx_cur(p_cust_trx_id IN NUMBER)
 IS
    SELECT trx_line.customer_trx_line_id AS cust_trx_line_id,
           trx_line.extended_amount AS extended_amount,
           ps.payment_schedule_id AS pymt_schedule_id
     FROM  fun_net_ar_txns ftxn,
           ra_customer_trx_lines trx_line,
           ar_payment_schedules ps
    WHERE  ftxn.batch_id = g_batch_details.batch_id
    AND    ftxn.customer_trx_id = p_cust_trx_id
    AND   trx_line.customer_trx_id = ftxn.customer_trx_id
    AND   trx_line.line_type = 'LINE'
    AND   ps.customer_trx_id = trx_line.customer_trx_id
    AND   ps.due_date <= g_batch_details.transaction_due_date
    AND   ps.due_date between g_agr_start_date and g_agr_end_date
    AND   ps.status = 'OP';
BEGIN
     FOR i in txnTable.FIRST..txnTable.LAST
     LOOP
     --Check if Amount due remaining has changed since it was validated ,as txns
     --are not locked. If so raise an error
        SELECT SUM(amount_due_remaining)
        INTO   current_amt_due
        FROM  ar_payment_schedules ps
        WHERE customer_trx_id = txnTable(i).customer_Trx_id
        AND   due_date <= g_batch_details.TRANSACTION_DUE_DATE
	AND   due_date between g_agr_start_date and g_agr_end_date
    	AND   ps.status = 'OP';
    	l_open_amt := txnTable(i).txn_curr_open_amt;
    	IF l_open_amt <> current_amt_due THEN
    	       x_return_status := FND_API.G_FALSE;
    	       EXIT;
        END IF;
        FOR apply_rec in apply_trx_cur(txnTable(i).customer_trx_id)
        LOOP
            AND tl.sequence_num(+) = ps.terms_sequence_number
            AND t.term_id(+) = tl.term_id;
    /* Amount to be applied per line- Calculate percentage of contribution based
       on the Netting AMount and Line AMount */
/*        l_applied_amt := (l_line_amt / txnTable(i).amt_remaining)
                          * txnTable(i).txn_curr_net_amt; */
    /* When the Invoice Currency = Receipt Currency do not provide values for
          exchange rate and the Applied From amounts */
     /* IF  txnTable(i).invoice_currency_code = g_func_currency THEN
        l_exchange_rate := null;
        l_applied_from := null;
     ELSE
        l_exchange_rate := Derive_Net_Exchg_Rate(
                            txnTable(i).invoice_currency_code,
                            g_func_currency);
        l_applied_from := l_applied_amt * l_exchange_rate;
     END IF;
      AR_RECEIPT_API_PUB.Apply(
    -- Standard API parameters.
            p_api_version                 => 1.0,
            p_init_msg_list               => FND_API.G_FALSE,
            p_commit                      => FND_API.G_FALSE,
            p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
            x_return_status               => l_return_status,
            x_msg_count                   => l_msg_count,
            x_msg_data                    => l_msg_data,
  --  Receipt application parameters.
            p_cash_receipt_id             => p_cash_receipt_id,
            p_customer_trx_id             => txnTable(i).customer_trx_id,
            p_applied_payment_schedule_id => apply_rec.pymt_schedule_id,
  -- this is the amount to be applied in the transaction currency
            p_amount_applied              =>  l_applied_amt,
  -- this the amount to be applied in the receipt currency
            p_amount_applied_from         => l_applied_from,
            p_trans_to_receipt_rate       =>  l_exchange_rate,
            p_discount                     => 0,
            p_apply_date                   => g_batch_details.settlement_date,
            p_apply_gl_date                => g_batch_details.gl_date,
            p_customer_trx_line_id         => apply_rec.cust_trx_line_id,
            p_org_id                       => g_batch_details.org_id
         );
        dbms_output.put_line('Apply' || l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_FALSE;
            RETURN;
        END IF;
     END LOOP;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_FALSE;
END apply2_cash_receipt; 	 */
PROCEDURE apply_cash_receipt
    (txnTable IN txnTblType,
     p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE,
     x_return_status OUT NOCOPY VARCHAR2)
IS
    l_applied_amt       ra_customer_trx_lines.extended_amount%TYPE;
    l_applied_line_amt  ra_customer_trx_lines.extended_amount%TYPE;
    l_tax_amount        ra_customer_trx_lines.extended_amount%TYPE;
    l_open_amt          ra_customer_trx_lines.extended_amount%TYPE;
    l_running_amt       ra_customer_trx_lines.extended_amount%TYPE;
    current_amt_due     AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
    l_applied_from	ra_customer_trx_lines.extended_amount%TYPE;
    l_exchange_rate     fun_net_batches_all.exchange_rate%TYPE;
    l_original_amt      ra_customer_trx_lines.extended_amount%TYPE;
    l_trans_to_func_rate   fun_net_batches_all.exchange_rate%TYPE;
    l_func_to_trans_rate   fun_net_batches_all.exchange_rate%TYPE;
    l_return_status     VARCHAR2(1);
    l_exchange_rate_type varchar2(20);
    l_exchange_rate_date fun_net_batches.settlement_date%TYPE;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_path		 VARCHAR2(100);
    l_receipt_currecycode VARCHAR2(10); --  bug 52380292
    llca_def_trx_lines_tbl   AR_RECEIPT_API_PUB.llca_trx_lines_tbl_type ;
    l_precision  NUMBER;
    l_running_amount1 NUMBER;
    l_freight_amount NUMBER;
    l_discount_amount NUMBER;
    pymt_schedule_count NUMBER;
     l_class  VARCHAR2(5); --6179308
     l_line_or_header NUMBER; --7639693
CURSOR apply_trx_cur(p_cust_trx_id IN NUMBER)
 IS
    SELECT ps.payment_schedule_id AS pymt_schedule_id,
	   ps.amount_due_remaining AS amt_due_remain
    FROM  ar_payment_schedules ps
    WHERE  ps.customer_trx_id = p_cust_trx_id
    AND ( ( get_esd_flag(g_batch_details.batch_id)='Y' AND ps.terms_sequence_number in (
                  select rtd.sequence_num
                  FROM ra_terms_lines_discounts rtd
                  where rtd.term_id = ps.TERM_ID
                  AND rtd.sequence_num = ps.TERMS_SEQUENCE_NUMBER
                  and (g_batch_details.TRANSACTION_DUE_DATE) <= ((ps.trx_date)+rtd.discount_days)) OR
                  (( (ps.due_date) <= (g_batch_details.TRANSACTION_DUE_DATE))))
	  OR (get_esd_flag(g_batch_details.batch_id)='N' AND (ps.due_date)<=(g_batch_details.TRANSACTION_DUE_DATE)))
    AND    trunc(ps.due_date) between trunc(g_agr_start_date) and trunc(g_agr_end_date)
    AND    ps.status = 'OP';
--AND    trunc(ps.due_date) <= trunc(g_batch_details.transaction_due_date)
CURSOR apply_trx_line_cur(p_cust_trx_id IN NUMBER)
 IS
 SELECT trx_line.customer_trx_line_id AS cust_trx_line_id,
           trx_line.extended_amount AS extended_amount,
           trx_line.line_type AS line_type,
           trx_line.amount_due_remaining AS line_am_due_remaining
 FROM  ra_customer_trx_lines trx_line
 WHERE  trx_line.customer_trx_id = p_cust_trx_id
 AND    trx_line.line_type IN ('LINE');
BEGIN
    l_path := g_path || 'Apply Cash Receipt';
    fun_net_util.Log_String(g_event_level,
			    l_path,
			    'Applying Transactions');
-- Bug 52380292
	select currency_code into l_receipt_currecycode
	from ar_cash_receipts
	where cash_receipt_id = p_cash_receipt_id;
  FOR i in txnTable.FIRST..txnTable.LAST
     LOOP
     --Check if Amount due remaining has changed since it was validated ,
     -- as txns are not locked. If so raise an error
      IF get_esd_flag(g_batch_details.batch_id)='Y' THEN
        SELECT SUM(amount_due_remaining)
        INTO   current_amt_due
        FROM  ar_payment_schedules_all ps
        WHERE customer_trx_id = txnTable(i).customer_Trx_id
	AND   due_date between g_agr_start_date and g_agr_end_date
    	AND   ps.status = 'OP'
	AND ( ps.terms_sequence_number in (
                  select rtd.sequence_num
                  FROM ra_terms_lines_discounts rtd
                  where rtd.term_id = ps.TERM_ID
                  AND rtd.sequence_num = ps.TERMS_SEQUENCE_NUMBER
                  and (g_batch_details.TRANSACTION_DUE_DATE) <= ((ps.trx_date)+rtd.discount_days)) OR
                  (( (ps.due_date) <= (g_batch_details.TRANSACTION_DUE_DATE))))
	AND ((g_sel_past_due_flag='N') OR (g_sel_past_due_flag='Y' AND TRUNC(ps.due_date) + nvl(g_days_past_due,0) < trunc(sysdate) ));    -- Added for Bug No : 8497191
      ELSE
        SELECT SUM(amount_due_remaining)
        INTO   current_amt_due
        FROM  ar_payment_schedules_all ps
        WHERE customer_trx_id = txnTable(i).customer_Trx_id
	AND   due_date between g_agr_start_date and g_agr_end_date
    	AND   ps.status = 'OP'
	AND   due_date <= g_batch_details.TRANSACTION_DUE_DATE;
      END IF;
        SELECT sum(APS.amount_due_original)
        INTO l_original_amt
        FROM AR_PAYMENT_SCHEDULES  APS
        WHERE APS.customer_Trx_id = txnTable(i).customer_Trx_id;
    	l_open_amt := txnTable(i).txn_curr_open_amt;
    	IF l_open_amt <> current_amt_due THEN
    	       x_return_status := FND_API.G_FALSE;
    	       EXIT;
        END IF;
-- Exchange rate related logic for Bug  	5463394
        IF  txnTable(i).invoice_currency_code <> g_func_currency THEN
          IF g_net_currency_rule='ACCOUNTING_CURRENCY' THEN
            l_func_to_trans_rate:=Derive_Net_Exchg_Rate(g_func_currency,txnTable(i).invoice_currency_code);
            l_trans_to_func_rate:=Derive_Net_Exchg_Rate(txnTable(i).invoice_currency_code,g_func_currency);
          ELSE l_trans_to_func_rate := 1;
               l_func_to_trans_rate := 1;
          END IF;
        ELSE l_trans_to_func_rate :=1;
             l_func_to_trans_rate :=1;
        END IF;
fun_net_util.Log_String(g_state_level,l_path,'l_trans_to_func_rate:'||l_trans_to_func_rate);
fun_net_util.Log_String(g_state_level,l_path,'l_func_to_trans_rate:'||l_func_to_trans_rate);
   -- get the prcesion of the trx currency
   SELECT fc.precision
     INTO l_precision
     FROM fnd_currencies fc
    WHERE fc.currency_code = txnTable(i).invoice_currency_code;
  fun_net_util.Log_String(g_event_level,l_path
                ,'l_precision:' ||l_precision);
-- End of Exchange related logic for bug 	5463394
-- amount to be applied per installment
        l_running_amt := txnTable(i).txn_curr_net_amt;
 	FOR apply_rec in apply_trx_cur(txnTable(i).customer_trx_id)     -- TO GET THE PAYMENT SCHEDULE COUNT FOR CALLING APPLY/APPLY IN DETAIL ACCORDINGLY
	 LOOP
	 	pymt_schedule_count:=pymt_schedule_count+1;
	END LOOP;
	 FOR apply_rec in apply_trx_cur(txnTable(i).customer_trx_id)
	 LOOP
         fun_net_util.Log_String(g_event_level,l_path,'Payment Schedule id' || apply_rec.pymt_schedule_id);
         fun_net_util.Log_String(g_event_level,l_path,'Running Amount' || l_running_amt);
         fun_net_util.Log_String(g_event_level,l_path,'Curr Net Amt' || txnTable(i).txn_curr_net_amt);
         fun_net_util.Log_String(g_event_level,l_path,'Customer Trx id' || txnTable(i).customer_trx_id);
         fun_net_util.Log_String(g_event_level,l_path,'apply_rec.amt_due_remain:'|| apply_rec.amt_due_remain);
         fun_net_util.Log_String(g_event_level,l_path,'l_running_amt*l_func_to_trans_rate:'|| l_running_amt*l_func_to_trans_rate);
        -- Calculate Amount to be applied per Payment Schedule
        IF l_running_amt = 0 THEN
            EXIT;
        END IF;
        IF l_running_amt < 0 AND apply_rec.amt_due_remain < 0 THEN
           IF (l_running_amt) <= apply_rec.amt_due_remain THEN
                l_applied_amt := apply_rec.amt_due_remain;
                l_running_amt := (l_running_amt) - (apply_rec.amt_due_remain);
           ELSE
                l_applied_amt := (l_running_amt) ;
                l_running_amt := 0;
           END IF;
        ELSIF l_running_amt > 0 AND apply_rec.amt_due_remain > 0 THEN
            IF (l_running_amt)  >= (apply_rec.amt_due_remain) THEN
                l_applied_amt := (apply_rec.amt_due_remain);
                l_running_amt := l_running_amt - (apply_rec.amt_due_remain);
            ELSE
                    l_applied_amt := l_running_amt;
                    l_running_amt := 0;
            END IF;
        END IF;
    /* When the Invoice Currency = Receipt Currency do not provide values for
          exchange rate and the Applied From amounts */
    /* When the Invoice Currency = Receipt Currency do not provide values for
          exchange rate and the Applied From amounts */
       IF  txnTable(i).invoice_currency_code = g_func_currency THEN
          l_exchange_rate := null;
          l_applied_from  := null;
       ELSE
     	  IF txnTable(i).invoice_currency_code <> l_receipt_currecycode THEN   -- Bug 52380292
             l_exchange_rate := Derive_Net_Exchg_Rate(txnTable(i).invoice_currency_code,g_func_currency);
  	     l_applied_from := round((l_applied_amt * l_exchange_rate),l_precision) ;
    	  ELSE
		l_exchange_rate := null;
	        l_applied_from  := null;
    	  END IF;
       END IF;
        fun_net_util.Log_String(g_event_level,l_path,'exchange rate:'||l_exchange_rate);
        fun_net_util.Log_String(g_event_level,l_path,'amount applied:'||l_applied_amt);
        fun_net_util.Log_String(g_event_level,l_path,'applied from'||l_applied_from);
	IF get_esd_flag(g_batch_details.batch_id)='Y' THEN
		-- ADDED FOR ESD
	     BEGIN
		SELECT Nvl(APPLIED_DISC,0) INTO l_discount_amount
		 FROM FUN_NET_AR_TXNS_ALL
		 WHERE batch_id=g_batch_details.batch_id
			AND CUSTOMER_TRX_ID=txnTable(i).customer_trx_id;
                l_discount_amount:=round(l_discount_amount * Derive_Net_Exchg_Rate(txnTable(i).invoice_currency_code,g_func_currency), l_precision);	-- converting the discount amount to invoice currecny.
		SELECT  trx_line.customer_trx_line_id AS cust_trx_line_id,
                 trx_line.line_number  AS line_number,'','',
                round(((((nvl(trx_line.amount_due_remaining,trx_line.extended_amount)/current_amt_due)*l_applied_amt)  +
                ( select nvl((sum( nvl(trx_line_tax.amount_due_remaining,trx_line_tax.extended_amount) )/current_amt_due)*l_applied_amt,0)
                  FROM ra_customer_trx_lines trx_line_tax
                  WHERE trx_line_tax.link_to_cust_trx_line_id = trx_line.customer_trx_line_id
                  AND trx_line_tax.customer_trx_id = trx_line.customer_trx_id
                  AND trx_line_tax.line_type IN ('TAX') ))),l_precision) AS amount_applied,'',
		  round(nvl(((nvl(trx_line.amount_due_remaining,trx_line.extended_amount)/current_amt_due)*l_discount_amount),0),l_precision) AS line_discount,
		  '','','','','','','','','','','','','','','','',''
             BULK COLLECT INTO llca_def_trx_lines_tbl
                 FROM   ra_customer_trx_lines trx_line
                 WHERE  trx_line.customer_trx_id = txnTable(i).customer_trx_id
                 AND    trx_line.line_type IN ('LINE')
                 AND    nvl(trx_line.amount_due_remaining,trx_line.extended_amount) <> 0 ;
            EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_ERROR;
	        END;
	ELSE
	    BEGIN
	      SELECT  trx_line.customer_trx_line_id AS cust_trx_line_id,
                 trx_line.line_number  AS line_number,'','',
                round(((((nvl(trx_line.amount_due_remaining,trx_line.extended_amount)/current_amt_due)*l_applied_amt)  +
                ( select nvl((sum( nvl(trx_line_tax.amount_due_remaining,trx_line_tax.extended_amount) )/current_amt_due)*l_applied_amt,0)
                  FROM ra_customer_trx_lines trx_line_tax
                  WHERE trx_line_tax.link_to_cust_trx_line_id = trx_line.customer_trx_line_id
                  AND trx_line_tax.customer_trx_id = trx_line.customer_trx_id
                  AND trx_line_tax.line_type IN ('TAX') ))),l_precision) AS amount_applied,'','','','','','','','','','','','','','','','','','',''
             BULK COLLECT INTO llca_def_trx_lines_tbl
                 FROM   ra_customer_trx_lines trx_line
                 WHERE  trx_line.customer_trx_id = txnTable(i).customer_trx_id
                 AND    trx_line.line_type IN ('LINE')
                 AND    nvl(trx_line.amount_due_remaining,trx_line.extended_amount) <> 0 ;
            EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_API.G_EXC_ERROR;
	        END;
	END IF;
      -- get the freight amount
          SELECT round(SUM((nvl(trx_line.amount_due_remaining,trx_line.extended_amount)
                   /current_amt_due)*l_applied_amt),l_precision)
            INTO l_freight_amount
            FROM ra_customer_trx_lines trx_line
           WHERE trx_line.customer_trx_id = txnTable(i).customer_trx_id
             AND trx_line.line_type IN ('FREIGHT')
             AND nvl(trx_line.amount_due_remaining,trx_line.extended_amount) <> 0 ;
     fun_net_util.Log_String(g_event_level,l_path
                ,' l_freight_amount : ' || l_freight_amount);
   -- Prorate the amounts for each line
/*
    l_applied_amt := round(l_applied_amt,l_precision);
    l_running_amount1 :=  l_applied_amt ;
    FOR i in llca_def_trx_lines_tbl.FIRST..llca_def_trx_lines_tbl.LAST LOOP
     fun_net_util.Log_String(g_event_level,l_path
                ,'l_running_amount1:' ||l_running_amount1);
  fun_net_util.Log_String(g_event_level,l_path
                ,'lllca_def_trx_lines_tbl(i).amount_applied:' ||llca_def_trx_lines_tbl(i).amount_applied);
     IF  l_running_amount1  < llca_def_trx_lines_tbl(i).amount_applied THEN
       llca_def_trx_lines_tbl(i).amount_applied := l_running_amount1 ;
     ELSE
       l_running_amount1  := l_running_amount1 - llca_def_trx_lines_tbl(i).amount_applied;
     END IF;
   END LOOP;
*/ -- Commented this for issue  no : 7368248
       fun_net_util.Log_String(g_event_level,l_path,'Before calling select for count');
	SELECT count(*) into l_line_or_header
	FROM ra_batch_sources bs, ra_customer_trx ct
	WHERE ct.customer_trx_id = txnTable(i).customer_trx_id AND
	ct.batch_Source_id = bs.batch_source_id AND
	NVL(gen_line_level_bal_flag,'Y') = 'Y';
	fun_net_util.Log_String(g_event_level,l_path,'After calling select for count l_line_or_header = ' || l_line_or_header);
	Select distinct Class into l_class  from ar_payment_schedules_all where customer_trx_id = txnTable(i).customer_trx_id;
IF  l_line_or_header >= 1 and pymt_schedule_count=1 and (l_class = 'INV' OR l_class = 'DM')THEN
--6179308.  Call Apply_In_Detail for invoices and Debitmemo, otherwise call Apply API.
   	  fun_net_util.Log_String(g_event_level,l_path,'Inside main iF');
	  fun_net_util.Log_String(g_event_level,l_path,'Calling APPLY IN DETAIL');
	   AR_RECEIPT_API_PUB.Apply_In_Detail(
	   -- Standard API parameters.
           p_api_version                 => 1.0,
           p_init_msg_list               => FND_API.G_FALSE,
           p_commit                      => FND_API.G_FALSE,
           p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
           x_return_status               => l_return_status,
           x_msg_count                   => l_msg_count,
           x_msg_data                    => l_msg_data,
  --  Receipt application parameters.
           p_cash_receipt_id             => p_cash_receipt_id,
           p_customer_trx_id             => txnTable(i).customer_trx_id,
           p_applied_payment_schedule_id => apply_rec.pymt_schedule_id,
           p_llca_type                   => 'L',
           p_llca_trx_lines_tbl          =>  llca_def_trx_lines_tbl,
           p_trans_to_receipt_rate       =>  l_exchange_rate,
           p_freight_amount              => l_freight_amount,
           p_discount                    => 0,
           p_apply_date                  => g_batch_details.settlement_date,
           p_apply_gl_date               => g_batch_details.gl_date,
           p_org_id                      => g_batch_details.org_id
         );
ELSE
  	fun_net_util.Log_String(g_event_level,l_path,'Inside Else jst before calling Apply');
	fun_net_util.Log_String(g_event_level,l_path,'p_cash_receipt_id = ' || p_cash_receipt_id );
	fun_net_util.Log_String(g_event_level,l_path,'txnTable(i).customer_trx_id =  ' || txnTable(i).customer_trx_id );
         fun_net_util.Log_String(g_event_level,l_path,'Calling APPLY');
	 Ar_receipt_api_pub.apply(
	  p_api_version => 1.0,
	  p_init_msg_list => FND_API.G_TRUE,
	  p_cash_receipt_id             => p_cash_receipt_id,
	  p_customer_trx_id             => txnTable(i).customer_trx_id,
          p_applied_payment_schedule_id => apply_rec.pymt_schedule_id,
	  x_return_status => l_return_status,
	  x_msg_count => l_msg_count,
	  x_msg_data => l_msg_data
	);
END IF;
       fun_net_util.Log_String(g_event_level,l_path,'After Calling APPLY/APPLY IN DETAIL');
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         FND_MSG_PUB.Count_And_Get (
                    p_count    =>  l_msg_count,
                    p_data     =>  l_msg_data );
        fun_net_util.Log_String(g_event_level,l_path
		,'apply cash receipt package after       AR_RECEIPT_API_PUB.Apply:' ||l_msg_data);
			IF l_msg_count > 1 THEN
                FOR x IN 1..l_msg_count LOOP
                  l_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  fun_net_util.Log_String(g_event_level,l_path
			,'apply cash receipt package Error message  AR_RECEIPT_API_PUB.Apply' ||l_msg_data||'  '||'  '||x);
                END LOOP;
             END IF;
            x_return_status := FND_API.G_FALSE;
            RETURN;
        END IF;
     END LOOP;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_FALSE;
END apply_cash_receipt;
/******************************************************************************
|PROCEDURE settle_ar_txns :   Settles AR Transactions for the given batch     |
|                                                                             |
|  Calls : Get_Customer_Details                                               |
|        : create_cash_receipt                                                |
|        : apply_cash_receipt                                                 |
*******************************************************************************/
PROCEDURE settle_ar_txns(
	      txnTable         IN  txnTblType,
	      p_bank_acct_name IN ce_bank_accounts.bank_account_name%TYPE,
              p_bank_acct_num  IN ce_bank_accounts.bank_account_num%TYPE,
              p_bank_acct_use_id IN ce_bank_acct_uses_all.bank_acct_use_id%TYPE,
              x_return_status  OUT NOCOPY VARCHAR2,
              x_msg_data        OUT  NOCOPY VARCHAR2,
              x_msg_count       OUT NOCOPY NUMBER)
	IS
	l_receipt_method_id ar_receipt_methods.receipt_method_id%TYPE;
        l_cash_receipt_id   ar_cash_receipts_all.cash_receipt_id%TYPE;
        l_cust_acct_id      hz_cust_accounts.cust_account_id%TYPE;
        l_cust_site_use_id	hz_cust_site_uses.site_use_id%TYPE;
        arReceiptRec        arReceiptRecType;
	l_bank_acct_used         NUMBER;
	l_return_status		VARCHAR2(1);
	l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(2000);
        l_path              VARCHAR2(100);
	BEGIN
	       -- Get Customer Details for the AR Receipt --
               l_path := g_path || 'Settle_AR_Transactions';
        	Get_Customer_Details (p_cust_acct_id 	 => l_cust_acct_id,
                                  p_cust_site_use_id => l_cust_site_use_id,
                                  p_return_status 	 => l_return_status
                                  );
            IF l_return_status = FND_API.G_FALSE then
                fun_net_util.Log_String(g_event_level,
				        l_path
					,'No Customer Details');
                FND_MESSAGE.SET_NAME('FUN','FUN_NET_NO_CUST_DETAILS');
                x_return_status := FND_API.G_FALSE;
                RETURN;
	    ELSE
                fun_net_util.Log_String(g_event_level,
				        l_path
					,'Customer Details Success');
            END IF;
             -- Get the Seeded Receipt Method Id for Netting --
	     -- Bug 5967665, Changed the where clause to WHERE receipt_method_id= -1
             BEGIN
              	SELECT receipt_method_id
                INTO l_receipt_method_id
            	FROM ar_receipt_methods
            	WHERE receipt_method_id= -1;
             EXCEPTION
             WHEN OTHERS THEN
                fun_net_util.Log_String(g_event_level,
				        l_path
					,'Receipt Method not found');
                 FND_MESSAGE.SET_NAME('FUN','FUN_NET_NO_RECEIPT_METHOD');
                x_return_status := FND_API.G_FALSE;
                RETURN;
             END;
            BEGIN
                SELECT remit_bank_acct_use_id
                INTO l_bank_acct_used
                FROM ar_receipt_method_accounts_all
                WHERE receipt_method_id = l_receipt_method_id
                and org_id =g_batch_details.org_id
                and remit_bank_acct_use_id= p_bank_acct_use_id;
             EXCEPTION
             WHEN OTHERS THEN
                fun_net_util.Log_String(g_event_level,
                                        l_path
                                        ,'Agreement Bank Account not associated to Receipt Method AP/AR Netting ');
                 FND_MESSAGE.SET_NAME('FUN','FUN_NET_AR_BANK_ACCT_MISSING');
                x_return_status := FND_API.G_FALSE;
                RETURN;
             END;
             -- Set all inputs to create cash receipt --
           arReceiptRec.currency_code       := g_batch_details.batch_currency;
           arReceiptRec.amount              := g_batch_details.total_netted_amt;
           arReceiptRec.factor_discount_amount := 0;  -- need to pass the discount amount here
           arReceiptRec.receipt_number      :=  g_batch_details.batch_number;
           arReceiptRec.receipt_date        := g_batch_details.settlement_date;
           arReceiptRec.gl_date             := g_batch_details.gl_date;
           arReceiptRec.customer_id         := l_cust_acct_id;
           arReceiptRec.customer_site_use_id :=  l_cust_site_use_id;
           arReceiptRec.remittance_bank_account_id :=  p_bank_acct_use_id;
           arReceiptRec.remittance_bank_account_num :=  p_bank_acct_num;
           arReceiptRec.remittance_bank_account_name:= p_bank_acct_name;
           arReceiptRec.receipt_method_id          :=  l_receipt_method_id;
           arReceiptRec.org_id                     :=  g_batch_details.org_id;
           IF g_batch_details.batch_currency  = g_func_currency THEN
                arReceiptRec.exchange_rate := null;
                arReceiptRec.exchange_rate_type := null;
                arReceiptRec.exchange_rate_date := null;
            ELSE
	            IF  g_batch_details.exchange_rate_type = 'User' THEN  -- Bug 52380292
	            /*
                	arReceiptRec.exchange_rate := Derive_Net_Exchg_Rate(
                                    g_batch_details.batch_currency,
                                    g_func_currency); */
                   arReceiptRec.exchange_rate  := g_batch_details.exchange_rate;
                END IF;
                arReceiptRec.exchange_rate_type := g_batch_details.exchange_rate_type;
                arReceiptRec.exchange_rate_date := g_batch_details.settlement_date;
           END IF;
            -- Call to create Cash Receipt --
               create_cash_receipt( pARReceiptRec => arReceiptRec,
                                     x_cash_receipt_id => l_cash_receipt_id,
                                     x_return_status => x_return_status,
                                     x_msg_data => x_msg_data,
                                     x_msg_count => x_msg_count);
				 fun_net_util.Log_String(g_event_level,
		        		l_path
						,'After Create Cash Receipt');
               fun_net_util.Log_String(g_event_level,
		        l_path
				,x_msg_data|| ' with message ' || x_msg_count);
                IF x_return_status = FND_API.G_FALSE THEN
                fun_net_util.Log_String(g_event_level,
				        l_path
					,'Cash Receipt Creation Failed');
                FND_MESSAGE.SET_NAME('FUN','FUN_NET_CASH_RECEIPT_FAIL');
                    RETURN;
		ELSE
                fun_net_util.Log_String(g_event_level,
				        l_path
					,'Cash Receipt Creation Success');
                END IF;
        --       Apply Receipt to the AR Transactions in the Batch --
                apply_cash_receipt
                (txnTable           => txnTable,
                 p_cash_receipt_id => l_cash_receipt_id,
                 x_return_status => x_return_status);
                 IF x_return_status = FND_API.G_FALSE THEN
                 FND_MESSAGE.SET_NAME('FUN','FUN_NET_APPLY_RECEIPT_FAIL');
                    RETURN;
                 END IF;
        --      Update AR Transactions in the Batch with the Cash Receipt Id --
		      IF l_cash_receipt_id IS NOT NULL THEN
		          BEGIN
		              UPDATE fun_net_ar_txns
		              SET cash_receipt_id = l_cash_receipt_id
		              WHERE
		              batch_id = g_batch_id;
                   EXCEPTION
                   WHEN OTHERS THEN
                         fun_net_util.Log_String(g_event_level,
				        l_path
			,'Failed to associate AR transactions in the batch with cash receipt');
                   x_return_status := FND_API.G_FALSE;
                   END;
            END IF;
EXCEPTION
    WHEN OTHERS THEN
         fun_net_util.Log_String(g_event_level,
				        l_path
					,'Unknown error in settle_ar_txns procedure');
        x_return_status := FND_API.G_FALSE;
END settle_ar_txns;
/***************************************************************************
|PROCEDURE apply_cash_receipt : Applies a Receipt to AR transactions in the|
|Batch . Applies at Line level based on perecent contribution per line     |
|                                                                          |
|Calls : AR_RECEIPT_API_PUB.Apply                                          |
***************************************************************************/
FUNCTION default_batch_details
    RETURN VARCHAR2
    IS
    BEGIN
        IF g_batch_details.gl_date IS NULL THEN
            g_batch_details.gl_date := g_batch_details.settlement_date;
        END IF;
        IF g_batch_details.exchange_rate_type IS NULL THEN
            g_batch_details.exchange_rate_type := 'Corporate';
        END IF;
        RETURN FND_API.G_TRUE;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END default_batch_details;
PROCEDURE settle_net_batch (
            -- ***** Standard API Parameters *****
            p_init_msg_list     IN VARCHAR2 := FND_API.G_TRUE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id          IN  NUMBER) IS
        l_schd_tab		    pymt_sch_tab;
        l_status_flag       VARCHAR2(1);
        l_return_status     VARCHAR2(1);
        l_batch_status      fun_net_batches_all.settlement_date%TYPE;
        l_bank_acct_use_id  ce_bank_acct_uses_all.bank_acct_use_id%TYPE;
     	l_bank_acct_name    ce_bank_accounts.bank_account_name%TYPE;
        l_bank_acct_num     ce_bank_accounts.bank_account_num%TYPE;
        l_le_id             xle_entity_profiles.legal_entity_id%TYPE;
        l_bank_num          ce_banks_v.bank_number%TYPE;
        batch_status_flag   BOOLEAN;
        l_msg_data			VARCHAR2(1000);
        l_msg_count         NUMBER;
  --      txnCur				txnCurType;
        l_period_name       gl_period_statuses.period_name%TYPE;
        txnTable	    txnTblType;
	l_path 		    VARCHAR2(100);
        VALIDATE_AR_TXN_FAIL    EXCEPTION;
        l_request_id        NUMBER;
        l_amt_to_net        NUMBER;
        BEGIN
       l_path  := g_path||'Settle_Net_Batch';
       fun_net_util.Log_String(g_event_level,l_path,'Settling Netting batches');
         /* Intialize standard API parameters */
            /* Intialize message list */
            x_msg_count                             :=      NULL;
            x_msg_data                              :=      NULL;
        -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****
            IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
            END IF;
            -- ****  Initialize return status to SUCCESS   *****
             x_return_status := FND_API.G_RET_STS_SUCCESS;
            /* Create Save point */
            SAVEPOINT settle_net_batch_SP;
            /* Get Batch Details for the given batch id*/
            IF p_batch_id  IS NULL THEN
               fun_net_util.Log_String(
				 g_event_level
				,l_path,'Batch Id is null');
                FND_MESSAGE.SET_NAME('FUN','FUN_NET_UNEXPECTED_ERROR');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
	    g_batch_id := p_batch_id;
            IF NOT get_batch_details THEN
               fun_net_util.Log_String(g_event_level,l_path,
				      'Error getting Batch details');
                FND_MESSAGE.SET_NAME('FUN','FUN_NET_UNEXPECTED_ERROR');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
	   g_agreement_id := g_batch_details.agreement_id;
	   IF NOT get_agreement_details THEN
               fun_net_util.Log_String(g_event_level,l_path,
				      'Error getting Agreement details');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        IF g_batch_details.batch_status_code NOT IN ( 'CLEARING',
                                           'SUBMITTED') THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Batch Status is not CLEARING');
             FND_MESSAGE.SET_NAME('FUN','FUN_NET_BATCH_STATUS_ERROR');
             RAISE FND_API.G_EXC_ERROR;
         END IF;
            /* Get Functional Currency */
            get_functional_currency;
     /* Default Batch Details */
       IF default_batch_details = FND_API.G_FALSE THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error defaulting Batch Details');
            FND_MESSAGE.SET_NAME('FUN','FUN_NET_UNEXPECTED_ERROR');
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     -- Calculate Netting balances
      fun_net_util.Log_String(g_event_level,l_path,'Before Selecting' || g_agreement_id);
       SELECT ALLOW_DISC_FLAG into l_allow_disc_flag FROM FUN_NET_AGREEMENTS_all WHERE Agreement_id=g_agreement_id;  -- ADDED FOR ESD
        IF l_allow_disc_flag='Y' THEN     -- ADDED FOR ESD
		calculate_approx_netted_amount(l_amt_to_net,l_status_flag);
	ELSE
		calculate_AP_AR_balances(l_amt_to_net,l_status_flag);
	END IF;
	fun_net_util.Log_String(g_event_level,l_path,'Before Selecting' || l_allow_disc_flag);
	IF l_status_flag = FND_API.G_FALSE THEN
        	RAISE FND_API.G_EXC_ERROR;
	END IF;
        /* Validate AR Transactions to check if they have changed */
		Validate_AR_Txns(
	 	txnTable    => txnTable,
                x_return_status => l_return_status
                );
		IF l_return_status = FND_API.G_FALSE THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error Validating AR Transactions');
              FND_MESSAGE.SET_NAME('FUN','FUN_NET_VAL_AR_TXN_FAIL');
		    RAISE VALIDATE_AR_TXN_FAIL;
		END IF;
	 /* Validate GL Period - AP */
            Validate_Settlement_Period(
		   x_appln_id 		=> 200,
		   x_period_name    => l_period_name,
		   x_return_status	=> l_return_status ,
    		   x_return_msg		=> l_msg_data);
	    IF l_return_status = FND_API.G_FALSE THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error Validating AP Period');
            FND_MESSAGE.SET_NAME('FUN','FUN_NET_AP_PERIOD_FAIL');
            FND_MESSAGE.SET_TOKEN('SETTLE_DATE',
                g_batch_details.settlement_date,FALSE);
		 	RAISE FND_API.G_EXC_ERROR;
	    END IF;
	/* Validate GL Period - AR */
           Validate_Settlement_Period
			(x_appln_id 		=> 222,
			     x_period_name   => l_period_name,
		         x_return_status	=> l_return_status ,
    		  	 x_return_msg		=> l_msg_data);
	    IF l_return_status = FND_API.G_FALSE THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error Validating AR Period');
              FND_MESSAGE.SET_NAME('FUN','FUN_NET_AR_PERIOD_FAIL');
              FND_MESSAGE.SET_TOKEN('SETTLE_DATE',
                g_batch_details.settlement_date,FALSE);
			 	RAISE FND_API.G_EXC_ERROR;
	     END IF;
             Validate_Settlement_Period
		     (x_appln_id     => 101,
		     x_period_name   => l_period_name,
		     x_return_status => l_return_status ,
    		     x_return_msg    => l_msg_data);
	 IF l_return_status = FND_API.G_FALSE THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error Validating GL Period');
		   FND_MESSAGE.SET_NAME('FUN','FUN_NET_GL_PERIOD_FAIL');
		   FND_MESSAGE.SET_TOKEN('SETTLE_DATE',
                g_batch_details.settlement_date,FALSE);
			 	RAISE FND_API.G_EXC_ERROR;
	 END IF;
            /* Get Netting Bank Account Information */
             Get_Netting_Bank_Details(l_bank_acct_use_id,
                                      l_bank_acct_name,
                                      l_bank_acct_num,
                                      l_le_id,
                                      l_bank_num,
                                      l_return_status);
            IF l_return_status = FND_API.G_FALSE THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error in Getting Netting Bank Details');
                 FND_MESSAGE.SET_NAME('FUN','FUN_NET_NO_BANK_DETAILS');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            --------------------------------------------------------------------
           /******************** Settle AP Transactions ***********************/
           --------------------------------------------------------------------
	fun_net_util.Log_String(g_event_level,l_path,'Before Settling ap invoices');
        settle_ap_invs(p_bank_acct_use_id => l_bank_acct_use_id,
                           p_bank_acct_name   => l_bank_acct_name,
                           p_bank_acct_num    => l_bank_acct_num,
                           p_le_id			  => l_le_id,
                           p_bank_num         => l_bank_num,
			   x_return_status    => l_return_status);
	fun_net_util.Log_String(g_event_level,l_path,'AP invoices settled successfully');
 		    IF l_return_status = FND_API.G_FALSE THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error in Settling AP Invoices');
--                 FND_MESSAGE.SET_NAME('FUN','FUN_NET_AP_SETTLE_FAIL');
	 		    RAISE FND_API.G_EXC_ERROR;
	 		END IF;
          /* -----------------------------------------------------------------*/
          /***********************  SETTLE AR TRANSACTIONS *******************/
          -------------------------------------------------------------------*/
	    fun_net_util.Log_String(g_event_level,l_path,'Before Settling AR TRX');
               settle_ar_txns( txnTable 	     => txnTable,
			    p_bank_acct_name => l_bank_acct_name,
                           p_bank_acct_num  => l_bank_acct_num,
                           p_bank_acct_use_id => l_bank_acct_use_id,
			    x_return_status  => l_return_status,
                x_msg_data  => l_msg_data,
                x_msg_count => l_msg_count);
           fun_net_util.Log_String(g_event_level,l_path,'AR TRX Settlement successful');
            IF l_return_status = FND_API.G_FALSE THEN
             --   x_msg_count := l_msg_count;
             --   x_msg_data := l_msg_data;
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error in Settling AR Transactions');
         --       FND_MESSAGE.SET_NAME('FUN','FUN_NET_AR_SETTLE_FAIL');
	 		    RAISE FND_API.G_EXC_ERROR;
	 		END IF;
	-- Update Batch Status to Complete
         IF NOT update_batch_status('COMPLETE') THEN
             fun_net_util.Log_String(g_event_level,l_path,
				      'Error in Setting Status to Complete');
                FND_MESSAGE.SET_NAME('FUN','FUN_NET_UNEXPECTED_ERROR');
			  	RAISE FND_API.G_EXC_ERROR;
         ELSE
          -- Submit the Data Extract report
            l_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'FUN'
                                                       , 'FUNNTDEX'
                                                       , null
                                                       , null
                                                       , FALSE
                                                       , g_batch_id
                                                         );
            fun_net_util.Log_String(g_state_level,l_path,
                            'Data Extract request: '||l_request_id);
	 END IF;
	 -- Standard check of p_commit.
    	      IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        	 END IF;
	  -- Call Procedure to perform common tasks after committing
          -- Example : Unlocking txns , setting Agreement Status
              perform_common_tasks;
        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO settle_net_batch_SP;
             batch_status_flag :=  update_batch_status('ERROR');
              --perform_common_tasks;
             x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	     ROLLBACK TO settle_net_batch_SP;
	    batch_status_flag := update_batch_status('ERROR');
            --perform_common_tasks;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
       WHEN VALIDATE_AR_TXN_FAIL THEN
            ROLLBACK TO settle_Net_Batch_SP;
            batch_status_flag := update_batch_status('CANCELLED');
            perform_common_tasks; -- Bug 5608043
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
        WHEN OTHERS THEN
          ROLLBACK TO settle_Net_Batch_SP;
   	  batch_status_flag := update_batch_status('ERROR');
    --      perform_common_tasks;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg( 'FUN_ARAP_NET_PKG', 'settle_net_batch');
          END IF;
          FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
    END settle_net_batch;
        -- This method will return the all_disc_flag
    FUNCTION get_esd_flag(p_batch_id NUMBER) RETURN VARCHAR2 IS
    l_allow_disc_flag varchar2(3);
    BEGIN
     SELECT distinct allow_disc_flag
     INTO l_allow_disc_flag
     FROM fun_net_batches_all fnb,
     fun_net_agreements_all fna
     WHERE fnb.batch_id = p_batch_id
     and  fna.agreement_id = fnb.agreement_id;
     RETURN l_allow_disc_flag;
     EXCEPTION
            WHEN OTHERS THEN
                RETURN 'N';
    END get_esd_flag;
BEGIN
    g_today := TRUNC(sysdate);
 --===========================FND_LOG.START=====================================
    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        :=    'FUN.PLSQL.funnttxb.FUN_NET_ARAP_PKG.';
--===========================FND_LOG.END=======================================
END FUN_NET_ARAP_PKG;

/
