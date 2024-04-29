--------------------------------------------------------
--  DDL for Package Body PO_INVOICES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INVOICES_SV1" AS
/* $Header: POXIVCRB.pls 120.9.12010000.4 2013/12/18 15:44:22 honwei ship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');

/* <CANCEL ASBN FPI START>, bug # 2569530 */
g_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_INVOICES_SV1.';
/* <CANCEL ASBN FPI END> */

/* <PAY ON USE FPI START> */
g_pkg_name CONSTANT VARCHAR2(50) := 'PO_INVOICES_SV1';
/* <PAY ON USE FPI END> */

/*================================================================

  PROCEDURE NAME: 	create_ap_invoices()

==================================================================*/
PROCEDURE  create_ap_invoices(X_transaction_source	 IN	 VARCHAR2,
			      X_commit_interval	         IN	 NUMBER,
			      X_shipment_header_id	 IN	 NUMBER,
			      X_aging_period		 IN      NUMBER,
			      X_include_timecard_correct IN      VARCHAR2)--Bug 17972946

 IS

   	X_progress   				VARCHAR2(4) := null;
        X_completion_code                       BOOLEAN;
   	X_receipt_completion_status	        BOOLEAN := TRUE;
   	X_bill_notice_compl_status	        BOOLEAN := TRUE;
    	X_receipt_event			        VARCHAR2(25) := 'RECEIVE';
        /*** this makes the API more generic, in future releases, we can use
	the same procedure to handle transactions for 'ACCEPT', 'DELIVER', etc.
	***/

	X_doc_sequence_value 	NUMBER;
	X_doc_sequence_id	NUMBER;
	X_db_sequence_name	VARCHAR2(50);
	X_sequential_numbering  VARCHAR2(2);
	X_invoice_id		NUMBER;
	X_set_of_books_id	NUMBER;
	X_invoice_date		DATE;


/* <PAY ON USE FPI> */
        l_consumption_comp_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


 BEGIN

     FND_MSG_PUB.initialize;

     /* Bug WDK - Removed profile PO_ASBN_INVOICE_INTERFACE */

     If (X_transaction_source IS NULL) THEN
     	X_progress := '010';
	X_receipt_completion_status :=
		po_invoices_sv2.create_receipt_invoices(X_commit_interval,
 		                                X_shipment_header_id,
					        X_receipt_event, X_aging_period,
 		                                X_include_timecard_correct);--Bug 17972946

     	X_progress := '020';

  	   X_bill_notice_compl_status :=
		PO_CREATE_ASBN_INVOICE.create_asbn_invoice (1,
		                                X_shipment_header_id);


/* <PAY ON USE FPI START> */
        PO_INVOICES_SV2.create_use_invoices(
            1.0,
            l_consumption_comp_status,
            x_commit_interval,
            x_aging_period);
/* <PAY ON USE FPI END> */

     ELSIF (X_transaction_source = 'ERS') THEN
     	X_progress := '030';
	X_receipt_completion_status :=
		po_invoices_sv2.create_receipt_invoices(X_commit_interval,
				        X_shipment_header_id,
					X_receipt_event,X_aging_period,
				        X_include_timecard_correct);--Bug 17972946

     ELSIF (X_transaction_source = 'ASBN') THEN
     	X_progress := '040';

  	   X_bill_notice_compl_status :=
		PO_CREATE_ASBN_INVOICE.create_asbn_invoice (1,
		                                X_shipment_header_id);

/* <PAY ON USE FPI START> */
      ELSIF (X_transaction_source = 'ERS_AND_USE') THEN
	X_receipt_completion_status :=
		PO_INVOICES_SV2.create_receipt_invoices(
                  X_commit_interval,
                  X_shipment_header_id,
                  X_receipt_event,
                  X_aging_period,
                  X_include_timecard_correct);--Bug 17972946

        PO_INVOICES_SV2.create_use_invoices(
            1.0,
            l_consumption_comp_status,
            x_commit_interval,
            x_aging_period);

      ELSIF (X_transaction_source = 'USE') THEN

        PO_INVOICES_SV2.create_use_invoices(
            1.0,
            l_consumption_comp_status,
            x_commit_interval,
            x_aging_period);

/* <PAY ON USE FPI END> */

     END IF;


     X_progress := '050';
     X_completion_code :=	X_receipt_completion_status 	AND
				X_bill_notice_compl_status;

     /** This will return TRUE if create_ap_invoices did not encounter any
	application errors. However, if one or more application errors is
	found during the execution of this program, X_completion_code will
	be FALSE. **/

/* <PAY ON USE FPI START> */
    IF (l_consumption_comp_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
/* <PAY ON USE FPI END> */

EXCEPTION
/* <PAY ON USE FPI START> */
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE;      /* Error has been printed. No need to print error here */
/* <PAY ON USE FPI END> */
WHEN others THEN
       	po_message_s.sql_error('create_ap_invoices', x_progress,sqlcode);
	RAISE;
END create_ap_invoices;


/*================================================================

  FUNCTION NAME:	get_vendor_related_info()

==================================================================*/

PROCEDURE get_vendor_related_info (X_vendor_id 	IN NUMBER,
		   X_default_pay_site_id	IN NUMBER,
                   X_pay_group_lookup_code      OUT NOCOPY VARCHAR2,
                   X_payment_method_lookup_code OUT NOCOPY VARCHAR2,
                   X_payment_priority           OUT NOCOPY VARCHAR2,
                   X_terms_date_basis           OUT NOCOPY VARCHAR2,
                   X_vendor_income_tax_region   OUT NOCOPY VARCHAR2,
                   X_type_1099                  OUT NOCOPY VARCHAR2,
		   X_awt_flag			OUT NOCOPY VARCHAR2,
		   X_awt_group_id		OUT NOCOPY NUMBER,
		   X_exclude_freight_from_disc	OUT NOCOPY VARCHAR2,
                   X_payment_currency_code      OUT NOCOPY VARCHAR2  -- BUG 612979
		  )

IS
	X_progress   			VARCHAR2(4) := null;
	x_txn_attributes_rec IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
	x_return_status VARCHAR2(3);
	x_msg_count NUMBER;
	x_msg_data VARCHAR2(2000);
	x_default_pmt_attrs_rec  IBY_DISBURSEMENT_COMP_PUB.Default_Pmt_Attrs_Rec_Type;
Begin
	X_progress	:= '010';

	/*** Obtain the following vendor, vendor_site related info. We would
	first lookup the values at the vendor-site first. If not found, then
	we would use the values specified at the vendor site. */

	SELECT	200 Application_ID, --this APs application ID
	        PO_MOAC_UTILS_PVT.Get_Current_Org_Id Payer_Org_Id,
	        pvds.party_id Payer_Party_Id,
	        pvss.party_site_id Payee_Party_Site_Id,
	        'PAYABLES_DOC' Pay_Proc_Trxn_Type_Code,
	        NVL(pvss.payment_currency_code, pvss.invoice_currency_code) Payment_Currency,
	        'PAYABLES_DISB' Payment_Function,
	        NVL(pvss.pay_group_lookup_code, pvds.pay_group_lookup_code),
		pvss.payment_priority,
		pvss.terms_date_basis,
		pvss.state vendor_income_tax_region,
		pvds.type_1099,
		pvss.allow_awt_flag,
		pvss.awt_group_id,
		pvss.exclude_freight_from_discount,
		NVL(pvss.payment_currency_code, pvss.invoice_currency_code)
	INTO	X_txn_attributes_rec.Application_Id,
	        X_txn_attributes_rec.Payer_Org_Id,
	        X_txn_attributes_rec.Payee_Party_Id,
	        X_txn_attributes_rec.Payee_Party_Site_Id,
	        x_txn_attributes_rec.Pay_Proc_Trxn_Type_Code,
	        x_txn_attributes_rec.Payment_Currency,
	        x_txn_attributes_rec.Payment_Function,
	        X_pay_group_lookup_code,
		X_payment_priority,
		X_terms_date_basis,
		X_vendor_income_tax_region,
		X_type_1099,
		X_awt_flag,
		X_awt_group_id,
		X_exclude_freight_from_disc,
		X_payment_currency_code
	FROM	po_vendors 	pvds,
		po_vendor_sites pvss
	WHERE	pvss.vendor_site_id = X_default_pay_site_id
	AND	pvss.vendor_id = pvds.vendor_id;

        /* Bug 4656555 - get legal_entity_id from base table
        SELECT  legal_entity_id
        INTO    x_txn_attributes_rec.Payer_Legal_Entity_Id
        FROM    hr_operating_units hou
        WHERE   hou.organization_id = X_txn_attributes_rec.Payer_Org_Id;
        */
        SELECT to_number(org_information2)
        INTO   x_txn_attributes_rec.Payer_Legal_Entity_Id
        FROM   hr_organization_information hoi,
               hr_all_organization_units_tl otl
        WHERE  hoi.organization_id =  X_txn_attributes_rec.Payer_Org_Id
        AND    hoi.organization_id = otl.organization_id
        AND    hoi.org_information_context = 'Operating Unit Information'
        AND    otl.language = userenv('LANG');

        IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payment_Attributes(
              p_api_version             =>  1.0
            , p_init_msg_list           =>  FND_API.G_FALSE
            , p_ignore_payee_pref       =>  'N'
            , p_trxn_attributes_rec     =>  x_txn_attributes_rec
            , x_return_status           =>  x_return_status
            , x_msg_count               =>  x_msg_count
            , x_msg_data                =>  x_msg_data
            , x_default_pmt_attrs_rec   =>  x_default_pmt_attrs_rec);

        X_payment_method_lookup_code := x_default_pmt_attrs_rec.Payment_Method.Payment_Method_Code;
EXCEPTION
WHEN others THEN
       	po_message_s.sql_error('get_vendor_related_info', x_progress,sqlcode);
	RAISE;
END get_vendor_related_info;


/*================================================================

  FUNCTION NAME:	get_ap_parameters()

==================================================================*/


PROCEDURE get_ap_parameters(	X_def_sets_of_books_id		OUT NOCOPY NUMBER,
				X_def_base_currency_code	OUT NOCOPY VARCHAR2,
				X_def_batch_control_flag	OUT NOCOPY VARCHAR2,
				X_def_exchange_rate_type	OUT NOCOPY VARCHAR2,
				X_def_multi_currency_flag	OUT NOCOPY VARCHAR2,
				X_def_gl_dat_fr_rec_flag	OUT NOCOPY VARCHAR2,
				X_def_dis_inv_less_tax_flag	OUT NOCOPY VARCHAR2,
				X_def_income_tax_region		OUT NOCOPY VARCHAR2,
				X_def_income_tax_region_flag	OUT NOCOPY VARCHAR2,
				X_def_vat_country_code		OUT NOCOPY VARCHAR2,
				X_def_transfer_desc_flex_flag	OUT NOCOPY VARCHAR2,
				X_def_org_id			OUT NOCOPY NUMBER,
/* bug# 908129 added the following parameter*/
                                X_def_awt_include_tax_amt       OUT NOCOPY VARCHAR2 )
IS

	X_progress	VARCHAR2(4)	:= NULL;


BEGIN

	IF (g_asn_debug = 'Y') THEN
   	asn_debug.put_line('Obtain AP System Options ... ');
	END IF;
	X_progress := '010';

	/* This select statement is used to obtain the AP_SYSTEM_PARAMETERS */

	SELECT		set_of_books_id,
			base_currency_code,
			NVL(batch_control_flag, 'N') batch_control_flag,
			default_exchange_rate_type,
			multi_currency_flag,
			gl_date_from_receipt_flag,
			disc_is_inv_less_tax_flag,							income_tax_region,
			income_tax_region_flag,
			transfer_desc_flex_flag,
			org_id,
                        awt_include_tax_amt
	INTO		X_def_sets_of_books_id,
			X_def_base_currency_code,
			X_def_batch_control_flag,
			X_def_exchange_rate_type,
			X_def_multi_currency_flag,
			X_def_gl_dat_fr_rec_flag,
			X_def_dis_inv_less_tax_flag,
			X_def_income_tax_region,
			X_def_income_tax_region_flag,
			X_def_transfer_desc_flex_flag,
			X_def_org_id,
                        X_def_awt_include_tax_amt
	FROM		ap_system_parameters;

	X_progress := '020';

	SELECT		vat_country_code
	INTO		X_def_vat_country_code
	FROM		financials_system_parameters;


EXCEPTION
WHEN others THEN
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Error in getting AP System Options ... ');
   END IF;
   po_message_s.sql_error('get_ap_parameters', x_progress,sqlcode);
   RAISE;
END get_ap_parameters;


/*================================================================

  PROCEDURE NAME: 	create_ap_batches()

==================================================================*/

-- Bug 4723269 : Added parameter p_org_id

PROCEDURE create_ap_batches(	X_batch_source  IN  VARCHAR2,
				X_currency_code IN  VARCHAR2,
				p_org_id        IN  NUMBER,
				X_batch_id      OUT NOCOPY NUMBER
			   )

IS

	X_progress 	VARCHAR2(3)  := NULL;
	X_tmp_batch_id  NUMBER;
	X_batch_name	ap_batches.batch_name%TYPE;

BEGIN
	IF (g_asn_debug = 'Y') THEN
   	asn_debug.put_line('Creating AP Invoice Batch ... ');
	END IF;

	X_progress := '010';
	/*** obtain the translated batch name ***/
	IF (X_batch_source = 'ERS') THEN
		fnd_message.set_name('PO', 'PO_INV_CR_ERS_BATCH_DESC');
	ELSIF (X_batch_source = 'ASBN') THEN
		fnd_message.set_name('PO', 'PO_INV_CR_ASBN_BATCH_DESC');
	END IF;

	X_progress := '020';
	IF (X_batch_source IN ('ERS', 'ASBN')) THEN
		X_batch_name := fnd_message.get;
	ELSE
		X_batch_name := X_batch_source;
	END IF;

	X_progress := '030';
	SELECT	ap_batches_s.nextval
	INTO	X_tmp_batch_id
	FROM    dual;

	-- Bug 4723269 : Populate org_id in ap_batches_all

	X_progress := '040';
	INSERT INTO	ap_batches_all
		( 	batch_id,
			batch_name,
			batch_date,
			invoice_currency_code,
			payment_currency_code,
			last_update_date,
			last_updated_by,
			last_update_login,
			creation_date,
			created_by,
			org_id
		)
	VALUES
		(	X_tmp_batch_id,
			X_batch_name || '/' || TO_CHAR(sysdate)
				|| '/' || TO_CHAR(X_tmp_batch_id),
			sysdate,
			X_currency_code,
			X_currency_code,
			sysdate,
			FND_GLOBAL.user_id,
			FND_GLOBAL.login_id,
			sysdate,
			FND_GLOBAL.user_id,
			p_org_id
		);

	X_batch_id := X_tmp_batch_id;

EXCEPTION
WHEN others THEN
	IF (g_asn_debug = 'Y') THEN
   	asn_debug.put_line('Error in creating AP Invoice Batch ... ');
	END IF;
       	po_message_s.sql_error('create_ap_batches', x_progress,sqlcode);
	RAISE;
END create_ap_batches;


/*================================================================

  PROCEDURE NAME: 	update_ap_batches()

==================================================================*/
PROCEDURE update_ap_batches( X_batch_id	 IN	NUMBER,
			X_invoice_count	 IN	NUMBER,
			X_invoice_total  IN	NUMBER)

IS
	X_progress   		VARCHAR2(3) := null;
BEGIN
	IF (g_asn_debug = 'Y') THEN
   	asn_debug.put_line('Updating current invoice batch ... ');
	END IF;

	X_progress := '010';

	/* Bug402317. gtummala. 2/13/97
         * We were not populating the control count or the control
         * control total originally. These need to be popluated
         * to be the same as the actual count and actual total.
         */

        -- Bug 4723269 : Changed ap_batches to ap_batches_all

	UPDATE 	ap_batches_all
	SET	actual_invoice_count 	= X_invoice_count,
		actual_invoice_total 	= X_invoice_total,
		control_invoice_count   = X_invoice_count,
		control_invoice_total   = X_invoice_total,
		last_updated_by 	= FND_GLOBAL.user_id,
		last_update_date 	= sysdate,
		last_update_login 	= FND_GLOBAL.login_id
	WHERE	batch_id = X_batch_id;

EXCEPTION
WHEN others THEN
	 IF (g_asn_debug = 'Y') THEN
   	 asn_debug.put_line('Error in Updating current invoice batch ... ');
	 END IF;
       	po_message_s.sql_error('update_ap_batches', x_progress,sqlcode);
	RAISE;
END update_ap_batches;



/*================================================================

  PROCEDURE NAME: 	create_invoice_header()

==================================================================*/


/* =====================================================================

   PROCEDURE	get_accounting_date_and_period

======================================================================== */

PROCEDURE  get_accounting_date_and_period(
			 X_def_gl_dat_fr_rec_flag        IN	VARCHAR2,
		         X_def_sets_of_books_id	         IN	NUMBER,
		         X_invoice_date		         IN 	DATE,
		         X_receipt_date		         IN	DATE,
			 X_batch_id			 IN	NUMBER,
			 X_transaction_type		 IN	VARCHAR2,
			 X_unique_id			 IN	NUMBER,
                         X_accounting_date               OUT NOCOPY    DATE,
                         X_period_name                   OUT NOCOPY    VARCHAR2,
			 X_curr_inv_process_flag	 IN OUT NOCOPY VARCHAR2 )

IS

	X_progress   		VARCHAR2(3) := null;
	X_temp_accounting_date	DATE;
	X_temp_period_name	gl_period_statuses.period_name%TYPE;

	CURSOR c_period IS
	SELECT		period_name
	FROM		gl_period_statuses gps
	WHERE		gps.application_id = 200   /*** Payables ***/
	AND		gps.set_of_books_id = X_def_sets_of_books_id
	AND		gps.adjustment_period_flag = 'N'
	AND		X_temp_accounting_date
	BETWEEN 	gps.start_date AND gps.end_date
	AND		gps.closing_status IN ('O', 'F');
			/*** period would be an OPEN or FUTURE one ***/

BEGIN
	x_progress := '010';

	IF (X_def_gl_dat_fr_rec_flag = 'I') THEN
		/*** GL Date = 'Invoice' ***/
		X_temp_accounting_date := X_invoice_date;
	ELSIF (X_def_gl_dat_fr_rec_flag = 'S') THEN
		/*** GL Date = 'System' ***/
		X_temp_accounting_date := sysdate;
	ELSIF (X_def_gl_dat_fr_rec_flag = 'N') THEN
		/*** GL Date = 'Receipt-Invoice' ***/
		X_temp_accounting_date := NVL(X_receipt_date, X_invoice_date);
	ELSIF (X_def_gl_dat_fr_rec_flag = 'Y') THEN
		/*** GL Date = 'Receipt-System ***/
		X_temp_accounting_date := NVL(X_receipt_date, sysdate);
	END IF;

        /* bug 657365, need to truncate the accounting date before we pass into the cursor
           to determine if period is open or not */

        x_temp_accounting_date := trunc(x_temp_accounting_date);

	/*** need some way to signal an error if accounting date is NULL ***/

	X_progress := '020';
	/*** Next find out the period name for the accounting date: ***/
	X_temp_period_name := NULL;
	OPEN  c_period;
	FETCH c_period INTO X_temp_period_name;
	CLOSE c_period;

	X_progress := '030';
	If (X_temp_period_name IS NULL) THEN
		/*** accounting date used does not fall into an open
		or future accounting period. ***/

		X_progress := '040';
		 IF (g_asn_debug = 'Y') THEN
   		 asn_debug.put_line('->Error: Invalid acctg date.');
		 END IF;

        	po_interface_errors_sv1.handle_interface_errors(
					       X_transaction_type,
					       'FATAL',
					       X_batch_id,
                                               X_unique_id,  -- header_id
                                               null,	     -- line_id
                                               'PO_INV_CR_INVALID_GL_PERIOD',
                                               'GL_PERIOD_STATUSES',
                                               'PERIOD_NAME',
                                               'GL_DATE',
                                               null, null, null, null, null,
                                               fnd_date.date_to_chardate(X_temp_accounting_date),
                                               null,null,null,null,null,
						X_curr_inv_process_flag);
	ELSE
	       X_progress := '050';
	       IF (g_asn_debug = 'Y') THEN
   	       asn_debug.put_line('Acctg Date = ' ||TO_CHAR(X_temp_accounting_date));
	       END IF;
	       X_accounting_date := X_temp_accounting_date;
	       X_period_name 	 := X_temp_period_name;
	END IF;


EXCEPTION
WHEN others THEN
	po_message_s.sql_error('get_accounting_date_and_period',
		x_progress, sqlcode);
	RAISE;
END get_accounting_date_and_period;


--
-- Cancel invoice line
--
/*==================================================================
  PROCEDURE NAME: cancel_asbn_invoices_line

  DESCRIPTION: 	Decide call which version of AP's API Ap_Cancel_Single_Invoice
		to cancel invoices in ASBN cancellation

  PARAMETERS:	p_invoice_id 		IN	NUMBER,

  DESIGN
  REFERENCES:

  CHANGE 	Created		21-AUGUST-02	DXIE
  HISTORY:

  13/06/2006   Modified the procedure and removed calls to
               cancel_asbn_invoices_line_new and
               cancel_asbn_invoices_line_old (Bug: 5257152)
=======================================================================*/

PROCEDURE cancel_asbn_invoices_line (
	p_invoice_id IN NUMBER)
IS

   l_gl_date		DATE;
   l_api_name 		CONSTANT VARCHAR2(30) := 'cancel_asbn_invoices_line';
   l_token VARCHAR2(1000);
   l_return_status BOOLEAN;
   l_message_name		FND_NEW_MESSAGES.message_name%TYPE;
   l_invoice_amount		AP_INVOICES.invoice_amount%TYPE;
   l_base_amount		AP_INVOICES.base_amount%TYPE;
   l_temp_cancelled_amount 	AP_INVOICES.temp_cancelled_amount%TYPE;
   l_cancelled_by 		AP_INVOICES.cancelled_by%TYPE;
   l_cancelled_amount 		AP_INVOICES.cancelled_amount%TYPE;
   l_cancelled_date 		AP_INVOICES.cancelled_date%TYPE;
   l_last_update_date 		AP_INVOICES.last_update_date%TYPE;
   l_original_prepayment_amount		NUMBER;
   l_pay_curr_invoice_amount 	AP_INVOICES.pay_curr_invoice_amount%TYPE;

BEGIN

     IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || l_api_name || '.begin','Inside CANCEL_ASBN_INVOICES_LINE procedure');
        END IF;
     END IF;


     SELECT  gl_date
     INTO    l_gl_date
     FROM    ap_invoices_all
     WHERE   invoice_id = p_invoice_id;

    IF (NOT AP_CANCEL_PKG.Ap_Cancel_Single_Invoice( --AP Call
                            P_invoice_id                =>  p_invoice_id,
                            P_last_updated_by           =>  1,
                            P_last_update_login         =>  1,
                            P_accounting_date           =>  l_gl_date,
                            P_message_name              =>  l_message_name,
                            P_invoice_amount            =>  l_invoice_amount,
                            P_base_amount               =>  l_base_amount,
                            P_temp_cancelled_amount     =>  l_temp_cancelled_amount,
                            P_cancelled_by              =>  l_cancelled_by,
                            P_cancelled_amount          =>  l_cancelled_amount,
                            P_cancelled_date            =>  l_cancelled_date,
                            P_last_update_date          =>  l_last_update_date,
                            P_original_prepayment_amount=>  l_original_prepayment_amount,
                            P_pay_curr_invoice_amount   =>  l_pay_curr_invoice_amount,
                            P_Token                     =>  l_token,
                            P_calling_sequence          =>  'rvtth.lpc'
                  )
        ) THEN
        IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('AP_CANCEL_PKG.Ap_Cancel_Single_Invoice returned FALSE');
          asn_debug.put_line('Token Value from AP API = ' || l_token);
        END IF;
     ELSE
        IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('AP_CANCEL_PKG.Ap_Cancel_Single_Invoice returned TRUE');
          asn_debug.put_line('Token Value from AP API = ' || l_token);
        END IF;
     END IF; --AP Call ends

     IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || l_api_name || '.begin', 'CANCEL_ASBN_INVOICES_LINE procedure Ends');
        END IF;
     END IF;

     EXCEPTION
       WHEN OTHERS THEN
        	IF (g_fnd_debug = 'Y') THEN
           	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
           	  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, g_log_head || l_api_name ||'.EXCEPTION', 'CANCEL_ASBN_INVOICES_LINE: Inside exception :'|| sqlcode);
           	END IF;
        	END IF;
  	      RAISE;  --Raise the Exception
END cancel_asbn_invoices_line;


--
-- Cancel invoice in case of ASBN
-- Call the AP package to cancel the single invoice.
--
/*==================================================================
  PROCEDURE NAME:	cancel_asbn_invoices

  DESCRIPTION: 	Calls AP's API Ap_Cancel_Single_Invoice to cancel invoices
		in ASBN cancellation

  PARAMETERS:	p_invoice_num	 IN	 VARCHAR2,
		p_vendor_id	 IN	 NUMBER

  DESIGN
  REFERENCES:

  CHANGE 	Created		21-AUGUST-02	DXIE
  HISTORY:
=======================================================================*/

PROCEDURE cancel_asbn_invoices (
	p_invoice_num	IN	VARCHAR2,
	p_vendor_id	IN	NUMBER,
	p_org_id        IN      NUMBER )  -- Bug 9008159

IS
   l_invoice_id NUMBER := NULL;

   CURSOR l_invoice_id_csr IS
	select 	invoice_id
	from 	AP_INVOICES_ALL
	where 	invoice_num = p_invoice_num
	and	vendor_id = p_vendor_id
	and     org_id = p_org_id;  -- Bug 9008159;

   l_api_name 	CONSTANT VARCHAR2(30) := 'cancel_asbn_invoices';

BEGIN

   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || l_api_name || '.begin','Inside CANCEL_ASBN_INVOICES procedure');
      END IF;
   END IF;
   -- Get invoice_id and call AP package to cancel invoice
   if (p_invoice_num is not null) then
      OPEN l_invoice_id_csr;
      LOOP
        FETCH l_invoice_id_csr INTO l_invoice_id;
        EXIT WHEN l_invoice_id_csr%NOTFOUND;

        if (l_invoice_id is not null) then
	   IF (g_fnd_debug = 'Y') THEN
   	   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
   	     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || l_api_name || '.begin', 'Call CANCEL_ASBN_INVOICES_LINE procedure');
   	     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || l_api_name ,  'Call CANCEL_ASBN_INVOICES_LINE with invoice_id: '|| l_invoice_id);
   	   END IF;
	   END IF;
           cancel_asbn_invoices_line(l_invoice_id);
        end if;

      END LOOP;
      CLOSE l_invoice_id_csr;
   end if;

   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || l_api_name || '.begin', 'CANCEL_ASBN_INVOICES procedure Ends');
      END IF;
   END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF (g_fnd_debug = 'Y') THEN
   		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
   		  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, g_log_head || l_api_name ||'.EXCEPTION', 'CANCEL_ASBN_INVOICES: Inside exception :'|| sqlcode);
   		END IF;
		END IF;
		raise;

END cancel_asbn_invoices;
/* <CANCEL ASBN FPI END> */

/* <PAY ON USE FPI START> */
PROCEDURE submit_invoice_import (
	x_return_status	OUT NOCOPY VARCHAR2,
	p_source        IN      VARCHAR2,
	p_group_id      IN      VARCHAR2,
	p_batch_name    IN      VARCHAR2,
	p_user_id       IN      NUMBER,
	p_login_id      IN      NUMBER,
	x_request_id	OUT NOCOPY NUMBER)
IS
    l_api_name VARCHAR2(50) := 'submit_invoice_import';
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_request_id := fnd_request.submit_request(
        'SQLAP',
        'APXIIMPT',
        NULL,
        NULL,
        FALSE,
        NULL,           -- Bug 4911166 : Passing Operating unit parameter
        p_source,
        p_group_id,
        p_batch_name,
        null,           -- hold name
        null,           -- hold reason
        null,           -- gl date
        'N',            -- purge flag
        'N',            -- trace switch
        'N',            -- debug switch
        'N',            -- summary flag
        TO_CHAR(1000),  -- commit batch size
        TO_CHAR(p_user_id), -- user_id
        TO_CHAR(p_login_id), -- login_id
        fnd_global.local_chr(0),NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,

        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,

        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL);

EXCEPTION
    WHEN OTHERS THEN
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('Error in submit invoice import.');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
END submit_invoice_import;

PROCEDURE delete_interface_records(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_group_id          IN VARCHAR2)
IS
    l_api_name VARCHAR2(50) := 'delete_interface_records';
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM ap_invoice_lines_interface aili
    WHERE EXISTS (SELECT 1
                  FROM   ap_invoices_interface aii
                  WHERE  aii.invoice_id = aili.invoice_id
                  AND    aii.group_id = p_group_id);

    DELETE FROM ap_invoices_interface aii
    WHERE       aii.group_id = p_group_id;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
END delete_interface_records;

/* <PAY ON USE FPI END> */

END PO_INVOICES_SV1;

/
