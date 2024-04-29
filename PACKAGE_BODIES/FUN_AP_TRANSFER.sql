--------------------------------------------------------
--  DDL for Package Body FUN_AP_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_AP_TRANSFER" AS
/* $Header: FUN_AP_XFER_B.pls 120.24.12010000.10 2010/03/11 08:33:36 makansal ship $ */

    ap_acct_invalid EXCEPTION;


FUNCTION has_valid_conversion_rate (
    p_from_currency IN varchar2,
    p_to_currency   IN varchar2,
    p_exchange_type IN varchar2,
    p_exchange_date IN date) RETURN number
IS
    l_has_rate  number;
BEGIN
    IF (p_from_currency = p_to_currency) THEN
        RETURN 1;
    END IF;
    SELECT COUNT(conversion_rate) INTO l_has_rate
    FROM gl_daily_rates
    WHERE from_currency = p_from_currency AND
          to_currency = p_to_currency AND
          conversion_type = p_exchange_type AND
          conversion_date = p_exchange_date;

    IF (l_has_rate = 0) THEN
        RETURN 0;
    END IF;
    RETURN 1;
END has_valid_conversion_rate;


/*-----------------------------------------------------
 * FUNCTION lock_and_transfer
 * ----------------------------------------------------
 * Acquires lock and transfer one trx.
 *
 * Returns TRUE iff it can obtain lock, see a valid
 * status, and transfer the trx.
 * ---------------------------------------------------*/

FUNCTION lock_and_transfer (
    p_trx_id        IN number,
    p_batch_date    IN date,
    p_vendor_id     IN number,
    p_site_id       IN number,
    p_gl_date       IN date,
    p_currency      IN varchar2,
    p_exchg_rate    IN varchar2,
    p_source        IN varchar2,
    p_approval_date IN date,
    p_to_org_id     IN number,
    p_invoice_num   IN varchar2,
    p_from_org_id   IN NUMBER) RETURN boolean
IS
    l_status        varchar2(15);
    l_payable_ccid  number;
BEGIN
    IF (NOT lock_transaction(p_trx_id)) THEN
        RETURN FALSE;
    ELSE
        transfer_single(p_trx_id, p_batch_date, p_vendor_id,
                        p_site_id, p_currency, p_exchg_rate,
                        p_source, p_gl_date, p_approval_date,
                        p_to_org_id, p_invoice_num,p_from_org_id,
                        l_payable_ccid);

        update_status(p_trx_id);
    END IF;

    RETURN TRUE;
END lock_and_transfer;



/*-----------------------------------------------------
 * FUNCTION lock_transaction
 * ----------------------------------------------------
 * Lock the transaction, test if it's valid still.
 * ---------------------------------------------------*/

FUNCTION lock_transaction (
    p_trx_id        IN number) RETURN boolean
IS
    l_status    varchar2(15);
BEGIN
    SELECT status INTO l_status
    FROM fun_trx_headers
    WHERE trx_id = p_trx_id
    FOR UPDATE;

    IF (l_status = 'XFER_AR') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END lock_transaction;




/*-----------------------------------------------------
 * PROCEDURE update_status
 * ----------------------------------------------------
 * Returns the new status.
 * ---------------------------------------------------*/

PROCEDURE update_status (
    p_trx_id    IN number)
IS
    l_result        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
BEGIN
    fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_result,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => p_trx_id,
                         p_update_status_to => 'COMPLETE');

  -- Handle the API call return

        IF l_result = FND_API.G_RET_STS_ERROR   THEN

            raise FND_API.G_EXC_ERROR;
        END IF;


        IF l_result = FND_API.G_RET_STS_UNEXP_ERROR   THEN

            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


END update_status;





/*-----------------------------------------------------
 * PROCEDURE transfer_batch
 * ----------------------------------------------------
 * Transfer to AP interface in batch.
 * ---------------------------------------------------*/

PROCEDURE transfer_batch (
    errbuf          OUT NOCOPY varchar2,
    retcode         OUT NOCOPY number,
    p_org_id        IN number default null,
    p_le_id         IN number default null,
    p_period_low    IN varchar2 default null,
    p_period_high   IN varchar2 default null,
    p_run_payables_import IN varchar2 default 'N' )
IS
    l_trx_id        number;
    l_batch_date    date;
    l_currency      varchar2(15);
    l_ledger_currency  varchar2(15);
    l_period_status varchar2(1);
    l_gl_date       date;
    l_approval_date date;
    l_invoice_num   varchar2(50);
    l_from_le_id    number;
    l_to_le_id      number;
    l_from_org_id   number;
    l_to_org_id     number;
    l_recipient_id  number;
    l_initiator_id  number;

    l_vendor_id     number;
    l_site_id       number;
    l_payable_ccid  number;
    l_rowcount      number := 0;
    l_error         number := 0;
    x_msg_data      varchar2(1000);
    l_parameter_list WF_PARAMETER_LIST_T :=wf_parameter_list_t();
    l_event_key     varchar2(240);
    l_init_sysdate  date;
    l_source        varchar2(100) := 'GLOBAL_INTERCOMPANY';
    l_request_id    number;
    l_conv_type     fun_trx_batches.exchange_rate_type%TYPE;
    l_counter	    number;
    l_trx_num       varchar2(15);
    l_batch_num     varchar2(20);
    l_org_name      varchar2(240);
    l_le_name       varchar2(240);
    l_date_low	    date;
    l_date_high     date;
    Request_Submission_Failure   EXCEPTION;
    is_data_transferred varchar2(1);
    l_run_payables_import varchar2(3);


     TYPE  ORG_ID_TAB_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     org_id_table ORG_ID_TAB_TYPE;
     l_previous_org_id   number;
--Bug: 9094846.
    CURSOR c_trx IS
        SELECT h.trx_id,
	       h.trx_number,
	       b.batch_number,
               b.batch_date,
               b.currency_code,
               b.exchange_rate_type,
	       ledgers.currency_code,
               ps.closing_status,
               b.gl_date,
               h.approval_date,
               h.ar_invoice_number,
               b.from_le_id,
               h.to_le_id ,
               fun_tca_pkg.get_ou_id(h.initiator_id) from_org_id,
               NVL(p_org_id, fun_tca_pkg.get_ou_id(h.recipient_id)) to_org_id,
               b.initiator_id,
               h.recipient_id
        FROM fun_trx_batches b,
             fun_trx_headers h,
             gl_period_statuses ps,
	     gl_ledgers ledgers
        WHERE b.batch_id = h.batch_id AND
              ps.ledger_id = h.to_ledger_id AND
              ps.application_id = 200 AND
              ledgers.ledger_id = h.to_ledger_id AND
              b.gl_date BETWEEN ps.start_date AND ps.end_date AND
              b.gl_date BETWEEN nvl(l_date_low, b.gl_date)
                             AND nvl(l_date_high, b.gl_date) AND
	      ps.adjustment_period_flag <> 'Y' AND
              h.to_le_id = NVL(p_le_id, h.to_le_id) AND
              NVL(p_org_id, 1) = NVL2(p_org_id,
                                 fun_tca_pkg.get_ou_id(h.recipient_id),1) AND
              h.status = 'XFER_AR' AND
              h.ar_invoice_number IS NOT NULL
        ORDER BY to_org_id; -- Order By added to be able to set
                            -- Org Context when submitting AP Import

BEGIN
    l_error:=1;
    retcode := 0;
    l_counter :=0;
    l_date_low := TRUNC(fnd_date.canonical_to_date(p_period_low));
    l_date_high:= TRUNC(fnd_date.canonical_to_date(p_period_high));
    is_data_transferred:= 'N';
    IF p_run_payables_import = 'Y' THEN
       l_run_payables_import := 'Yes';
    ELSE
       l_run_payables_import :='No';
    END IF;

    select sysdate into l_init_sysdate from dual;

    l_request_id := fnd_global.conc_request_id;

    IF (p_org_id is not null) THEN
        select hr.name into l_org_name from hr_operating_units hr
        where hr.organization_id = p_org_id;
    END IF;

    IF (p_le_id is not null) THEN
        select xle.name into l_le_name from xle_entity_profiles xle
        where xle.legal_entity_id = p_le_id;
    END IF;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '                   Transfer Intercompany Transactions to Payables Report        Date:'||to_char(sysdate,'DD-MON-YYYY HH:MM'));
   FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'        Operating Unit: ' || l_org_name);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'          Legal Entity: ' || l_le_name );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'          GL Date From: ' || to_char(l_date_low, 'DD-MON-YYYY'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'            GL Date To: ' || to_char(l_date_high,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Submit Payables Import: ' || l_run_payables_import);
   FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Batch Number        Transaction Number  Transfer Status' );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'------------        ------------------  ----------------');


    l_previous_org_id := 0;
    OPEN c_trx;
    LOOP
        FETCH c_trx INTO l_trx_id,
			 l_trx_num,
			 l_batch_num,
                         l_batch_date,
                         l_currency,
                         l_conv_type,
			 l_ledger_currency,
                         l_period_status,
                         l_gl_date,
                         l_approval_date,
                         l_invoice_num,
                         l_from_le_id,
                         l_to_le_id,
                         l_from_org_id,
                         l_to_org_id,
                         l_initiator_id,
                         l_recipient_id;

        exit when c_trx%NOTFOUND;
	l_counter := l_counter+1;

        IF (NOT fun_trading_relation.get_supplier(
                    'INTERCOMPANY',
                    l_from_le_id,
                    l_to_le_id,
                    l_from_org_id,
                    l_to_org_id,
                    l_initiator_id,
                    l_recipient_id,
                    l_batch_date,
                    x_msg_data,
                    l_vendor_id,
                    l_site_id))  THEN

           l_error := 2;
	   fnd_message.set_name('FUN','FUN_XFER_AP_INVALID_RELATION');

        END IF;

        IF (l_period_status NOT IN ('O', 'F')) THEN
                l_error := 2;
		fnd_message.set_name('FUN', 'FUN_XFER_AP_PERIOD');
        END IF;

        IF (l_to_org_id IS NULL) THEN
                l_error := 2;
		fnd_message.set_name('FUN', 'FUN_XFER_AP_TO_ORG_ID_NULL');
        END IF;

        IF (has_valid_conversion_rate(l_currency,l_ledger_currency,l_conv_type,l_gl_date)=0) THEN
                l_error := 2;
                fnd_message.set_name('FUN', 'FUN_CONV_RATE_NOT_FOUND');
        END IF;

        IF (l_error = 1) THEN
            -- Lock record
            SELECT trx_id INTO l_trx_id
            FROM fun_trx_headers
            WHERE trx_id = l_trx_id
            FOR UPDATE;

            BEGIN
                transfer_single(l_trx_id, l_batch_date, l_vendor_id,
                                l_site_id, l_currency, l_conv_type,
                                l_source, l_gl_date, l_approval_date,
                                l_to_org_id, l_invoice_num, l_from_org_id,
                                l_payable_ccid);


                update_status(l_trx_id);

                IF  l_previous_org_id <> l_to_org_id THEN
                    ORG_ID_TABLE(org_id_table.count+1) := l_to_org_id;
                    l_previous_org_id := l_to_org_id;
                END IF;

		fnd_message.set_name('FUN','FUN_XFER_SUCCESS');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(l_batch_num, 1,20),20)||rpad(substr(l_trx_num,1,15),20)||fnd_message.get);
		is_data_transferred:='Y';
            EXCEPTION
                WHEN OTHERS THEN
                  fnd_file.put_line(fnd_file.log,'Error :'||SQLERRM);


            END;
	ELSIF (l_error = 2) THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(l_batch_num,1,20),20)||rpad(substr(l_trx_num,1,15),20)||fnd_message.get);
        END IF;

      l_error := 1;

    END LOOP;
    CLOSE c_trx;
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
    IF (l_counter = 0) THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                   *****No Data Found*****');
    ELSE
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                   *****End Of Report*****');
    END IF;

    COMMIT;

  --   RAISE oracle.apps.fun.batch.ap.transfer;
  WF_EVENT.AddParameterToList(p_name=>'INIT_SYS_DATE',
                                            p_value=>TO_CHAR(l_init_sysdate),
                                            p_parameterlist =>l_parameter_list
                        );
  WF_EVENT.AddParameterToList(p_name=>'SOURCE',
                                            p_value=>l_source,
                                            p_parameterlist =>l_parameter_list
                        );
  l_event_key:=FUN_INITIATOR_WF_PKG.GENERATE_KEY(p_batch_id=>l_request_id,
                                                               p_trx_id => 0
                                                              );

  WF_EVENT.RAISE(p_event_name =>'oracle.apps.fun.batch.ap.transfer',
                                              p_event_key  =>l_event_key,
                                              p_parameters=>l_parameter_list);

  IF p_run_payables_import='Y'  and is_data_transferred='Y' AND
     org_id_table.count > 0
  THEN
      FOR I in  org_id_table.First .. org_id_table.last
      LOOP
          FND_REQUEST.set_org_id(org_id_table(I));
          l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                  application => 'SQLAP',
                  program =>'APXIIMPT',
                  description => null,
                  start_time => null,
                  sub_request=> FALSE,
                  argument1 => org_id_table(I),
                  argument2 =>'GLOBAL_INTERCOMPANY',
                  argument3 =>null,
                  argument4 =>null);

          IF l_request_id <> 0 THEN
             fnd_file.put_line(fnd_file.log,'Submitted the Payables Import Program. Request id: ' || l_request_id || ' for Org Id ' || org_id_table(I));
             commit;
          ELSE
              RAISE Request_Submission_Failure;
          END IF;
      END LOOP;
  END IF;


  l_parameter_list.delete();

EXCEPTION

 WHEN Request_Submission_Failure THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in submitting Payables Import Process');
    retcode :=2;
 WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error:' || sqlcode || sqlerrm);
    retcode := 2;

END transfer_batch;


/*-----------------------------------------------------
 * PROCEDURE transfer_single
 * ----------------------------------------------------
 * Transfer a single transaction to AP interface.
 * It assumes that the caller has a lock on the
 * transaction, and the caller will do the commit.
 * ---------------------------------------------------*/

PROCEDURE transfer_single (
    p_trx_id            IN number,
    p_batch_date        IN date,
    p_vendor_id         IN number,
    p_vendor_site_id    IN number,
    p_currency          IN varchar2,
    p_conv_type         IN varchar2,
    p_source            IN varchar2,
    p_gl_date           IN date,
    p_approval_date     IN date,
    p_org_id            IN number,
    p_invoice_num       IN varchar2,
    p_from_org_id       IN NUMBER,
    p_payables_ccid     OUT NOCOPY number)
IS
    l_acct_valid    varchar2(1);
    l_desc          varchar2(250);
    l_desc_header_level varchar2(250);  -- Bug No : 7652608
    l_invoice_id    number;
    l_inv_line_id   number;
    l_l_amount_cr   number;
    l_l_amount_dr   number;
    l_d_amount_cr   number;
    l_d_amount_dr   number;
    l_amount        number;
    l_ccid          number;
    l_dist_id       number;
    l_line_type     varchar2(15);
    l_dist_type     varchar2(15);

    l_parameter_list WF_PARAMETER_LIST_T :=wf_parameter_list_t();
    l_event_key    VARCHAR2(240);

    CURSOR c_dist IS
        SELECT NVL(d.amount_cr,0), NVL(d.amount_dr,0), d.ccid,
               d.dist_type_flag, NVL(t.reci_amount_cr,0), NVL(t.reci_amount_dr,0),
               d.dist_id, t.line_type_flag, d.description  -- Bug No : 7122846
        FROM fun_dist_lines d,
             fun_trx_lines t
        WHERE t.trx_id = p_trx_id AND
              d.line_id = t.line_id AND
              d.party_type_flag = 'R';

    -- Bug # 8238770, Changed the cusor defination to
	--fetch the default payment method from IBY_EXTERNAL_PAYEES_ALL
	CURSOR c_get_site_dtls (p_vendor_id NUMBER,
                            p_vendor_site_id NUMBER,
							p_org_id NUMBER)
    IS
    SELECT pmtmthdassignmentseo.payment_method_code
	FROM   iby_payment_methods_vl pmthds,
       iby_ext_party_pmt_mthds pmtmthdassignmentseo
	WHERE  pmthds.payment_method_code = pmtmthdassignmentseo.payment_method_code (+)
       AND pmtmthdassignmentseo.payment_flow = 'DISBURSEMENTS'
       AND Nvl(pmthds.inactive_date,Trunc(SYSDATE + 1)) > Trunc(SYSDATE)
       AND pmtmthdassignmentseo.payment_function = 'PAYABLES_DISB'
       AND pmtmthdassignmentseo.primary_flag = 'Y'
       AND pmtmthdassignmentseo.ext_pmt_party_id = (SELECT pmt.ext_payee_id
                                                    FROM   iby_external_payees_all pmt,
                                                           ap_suppliers supp,
                                                           ap_supplier_sites_all site
                                                    WHERE  pmt.payee_party_id = supp.party_id
                                                           AND pmt.party_site_id = site.party_site_id
                                                           AND pmt.org_id = site.org_id
                                                           AND pmt.supplier_site_id = site.vendor_site_id
                                                           AND supp.vendor_id = site.vendor_id
                                                           AND site.vendor_site_id = p_vendor_site_id
                                                           AND site.vendor_id = p_vendor_id
                                                           AND site.org_id = p_org_id);

    -- For intercompany transactions, as per the current datamodel
    -- each AR Intercompany invoice will have 1 line
    -- ie 1 row in ra_customer_trx and ra_customer_trx_lines
	-- Bug 9463299: Added clause AND    artrx.INTERFACE_HEADER_CONTEXT = 'INTERNAL_ALLOCATIONS'
    CURSOR c_get_etax_info (p_trx_id NUMBER,
			    p_invoice_num  VARCHAR2,
                            p_from_org_id  NUMBER)
    IS
    SELECT zx.application_id,
           zx.entity_code,
           zx.event_class_code,
           zx.trx_id,
           zx.trx_line_id,
           zx.trx_level_type
    FROM   zx_lines_det_factors zx,
           ra_customer_trx_all artrx
    WHERE  zx.trx_id         = artrx.customer_trx_id
    AND    zx.application_id =  222
    AND    zx.entity_code    = 'TRANSACTIONS'
	AND    artrx.INTERFACE_HEADER_CONTEXT = 'INTERNAL_ALLOCATIONS'
    AND    artrx.trx_number  = p_invoice_num
    AND    artrx.org_id      = p_from_org_id
    AND    artrx.INTERFACE_HEADER_ATTRIBUTE2 = TO_CHAR(p_trx_id);  -- bug no : 7718598
---Bug: 9094846


    l_payment_method_lookup_code   VARCHAR2(30);
    l_application_id               zx_lines_det_factors.application_id%TYPE;
    l_entity_code                  zx_lines_det_factors.entity_code%TYPE;
    l_event_class_code             zx_lines_det_factors.event_class_code%TYPE;
    l_trx_id                       zx_lines_det_factors.trx_id%TYPE;
    l_trx_line_id                  zx_lines_det_factors.trx_line_id%TYPE;
    l_trx_level_type               zx_lines_det_factors.trx_level_type%TYPE;

BEGIN

    -- Get etax info for AP to be able to calculate tax
    OPEN c_get_etax_info( p_trx_id, p_invoice_num, p_from_org_id);
    FETCH c_get_etax_info INTO l_application_id,
           l_entity_code,
           l_event_class_code,
           l_trx_id,
           l_trx_line_id,
           l_trx_level_type;
    CLOSE c_get_etax_info;

    OPEN  c_get_site_dtls ( p_vendor_id         ,
                            p_vendor_site_id,
							p_org_id);
    FETCH c_get_site_dtls INTO l_payment_method_lookup_code;
    CLOSE c_get_site_dtls;

    l_payment_method_lookup_code := Nvl(l_payment_method_lookup_code,
                                        'CHECK');

    OPEN c_dist;

    SELECT ap_invoices_interface_s.nextval INTO l_invoice_id
    FROM dual;

    LOOP
        FETCH c_dist INTO l_d_amount_cr, l_d_amount_dr, l_ccid,
                          l_dist_type, l_l_amount_cr, l_l_amount_dr,
                          l_dist_id, l_line_type, l_desc;
        EXIT WHEN c_dist%NOTFOUND;

        IF (l_dist_type = 'P') THEN
/* to do
            fun_trx_pvt.is_payable_acct_valid(l_acct_valid, l_ccid);
            IF (l_acct_valid <> fnd_api.g_ret_sts_success) THEN
                RAISE ap_acct_invalid;
            END IF;
*/

            -- Amounts Transferred to AP should be
            -- Reci Trx Amount: 1000 Cr,  AP Amount: 1000
            -- Reci Trx Amount: -1000 Cr, AP Amount: -1000
            -- Reci Trx Amount: 1000 Dr,  AP Amount: -1000
            -- Reci Trx Amount: -1000 Dr, AP Amount: 1000

            IF l_l_amount_cr <> 0
            THEN
                 l_amount := l_l_amount_cr;

            ELSIF l_l_amount_dr <> 0
            THEN
                 l_amount := l_l_amount_dr * (-1);
            END IF;
            -- Bug: 7652608
            select description
		INTO l_desc_header_level
		from fun_trx_headers
		where trx_id=p_trx_id;

            INSERT INTO ap_invoices_interface (
                invoice_id, invoice_num, invoice_date,
                vendor_id, vendor_site_id, invoice_amount,
                invoice_currency_code, exchange_rate_type, exchange_date,
                description,
                source, group_id,
                goods_received_date, invoice_received_date,
                gl_date, accts_pay_code_combination_id, org_id,
                payment_method_lookup_code,
                payment_method_code,
                calc_tax_during_import_flag ,
                add_tax_to_inv_amt_flag)
            VALUES (
                l_invoice_id, p_invoice_num, p_batch_date,
                p_vendor_id, p_vendor_site_id, l_amount,
                p_currency, p_conv_type, p_batch_date,
                l_desc_header_level,   -- Bug No : 7652608
                p_source, p_trx_id,
                p_batch_date, Nvl(p_approval_date, TRUNC(SYSDATE)),
                p_gl_date, l_ccid, p_org_id,
                l_payment_method_lookup_code,
                l_payment_method_lookup_code,
                'Y',
                'Y');

        ELSIF (l_dist_type = 'L') THEN
            -- Amounts Transferred to AP should be
            -- Reci Dst Amount: 1000 Dr,  AP Amount: 1000
            -- Reci Dst Amount: -1000 Dr, AP Amount: -1000
            -- Reci Dst Amount: 1000 Cr,  AP Amount: -1000
            -- Reci Dst Amount: -1000 Cr, AP Amount: 1000

            IF l_d_amount_dr <> 0
            THEN
                 l_amount := l_d_amount_dr;

            ELSIF l_d_amount_cr <> 0
            THEN
                 l_amount := l_d_amount_cr * (-1);
            END IF;

            SELECT ap_invoice_lines_interface_s.nextval into l_inv_line_id
            FROM dual;

            INSERT INTO ap_invoice_lines_interface (
                invoice_id, invoice_line_id, line_number,
                line_type_lookup_code, amount, accounting_date,
                description, dist_code_combination_id, org_id,
                source_application_id,
                source_entity_code,
                source_event_class_code,
                source_trx_id,
                source_trx_level_type,
                source_line_id )
            VALUES (
                l_invoice_id, l_inv_line_id, l_dist_id,
                'ITEM', l_amount, p_gl_date,
                l_desc, l_ccid, p_org_id,
                l_application_id, -- added for etax changes
                l_entity_code,  -- added for etax changes
                'INTERCOMPANY_TRX',   -- added for etax changes
                l_trx_id,  -- added for etax changes
                'LINE' ,    -- added for etax changes
                l_trx_line_id);
        END IF;

    END LOOP;

    WF_EVENT.AddParameterToList(p_name=>'INVOICE_ID',
                                            p_value=>TO_CHAR(l_invoice_id),
                                            p_parameterlist =>l_parameter_list
                        );

    WF_EVENT.AddParameterToList(p_name=>'TRX_ID',
                                            p_value=>TO_CHAR(p_trx_id),
                                            p_parameterlist =>l_parameter_list
                        );

   l_event_key:=FUN_INITIATOR_WF_PKG.GENERATE_KEY(p_batch_id=>l_invoice_id,
                                                               p_trx_id => 0
                                                              );

   WF_EVENT.RAISE(p_event_name =>'oracle.apps.fun.single.ap.transfer',
                                              p_event_key  =>l_event_key,
                                              p_parameters=>l_parameter_list);

   l_parameter_list.delete();

EXCEPTION
 When others then
  raise;

END transfer_single;



END;


/
