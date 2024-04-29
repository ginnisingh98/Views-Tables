--------------------------------------------------------
--  DDL for Package Body AP_AUTO_DM_CREATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AUTO_DM_CREATION_PKG" AS
/* $Header: apcrtdmb.pls 120.16.12010000.7 2010/02/15 06:41:44 sbonala ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED   CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR        CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION    CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_UNEXPECTED   CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_EVENT        CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE    CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT    CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME        CONSTANT VARCHAR2(50) := 'AP.PLSQL.AP_AUTO_DM_CREATION_PKG.';
  G_LEVEL_LOG_DISABLED CONSTANT NUMBER := 99;
  --1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

  g_log_level           NUMBER;
  g_log_enabled         BOOLEAN;


/* Private Procedures/functions */

Procedure Get_receipt_info(
			p_rcv_txn_id		IN		NUMBER,
			p_rts_txn_id		IN		NUMBER,
			p_vendor_id		IN OUT NOCOPY	NUMBER,
			p_vendor_site_id	IN OUT NOCOPY	NUMBER,
			p_rcv_currency_code	IN OUT NOCOPY	VARCHAR2,
			p_po_shipment_id	IN OUT NOCOPY	NUMBER,
			p_po_dist_id            IN      	NUMBER,
			p_rcv_txn_date		IN OUT NOCOPY	DATE,
			p_rcv_rate		IN OUT NOCOPY	NUMBER,
			p_rcv_rate_date		IN OUT NOCOPY	DATE,
			p_rcv_rate_type		IN OUT NOCOPY   VARCHAR2,
			p_receipt_num		IN OUT NOCOPY	VARCHAR2,
			p_receipt_uom		IN OUT NOCOPY	VARCHAR2,
			p_po_pay_terms_id	IN OUT NOCOPY	NUMBER,
			p_quantity_billed	IN OUT NOCOPY	NUMBER,
			p_rts_txn_date		IN OUT NOCOPY	DATE,
			p_item_description	IN OUT NOCOPY   VARCHAR2,
			--Bug:2902340
			p_match_option          IN OUT NOCOPY  VARCHAR2,
			p_org_id		IN OUT NOCOPY   NUMBER,
			p_po_uom		IN OUT NOCOPY   VARCHAR2,
			p_po_ccid		IN OUT NOCOPY   NUMBER, --bugfix:5395955
			p_calling_sequence	IN	        VARCHAR2);

Procedure Get_vendor_info (
	  	p_vendor_id			IN	NUMBER,
		p_vendor_site_id		IN	NUMBER,
		p_pay_group_lookup_code		IN OUT NOCOPY	VARCHAR2,
		p_accts_pay_ccid		IN OUT NOCOPY	NUMBER,
		p_payment_priority		IN OUT NOCOPY	NUMBER,
		p_terms_date_basis		IN OUT NOCOPY  VARCHAR2,
		p_vendor_income_tax_region	IN OUT NOCOPY	VARCHAR2,
		p_type_1099			IN OUT NOCOPY	VARCHAR2,
		p_allow_awt_flag		IN OUT NOCOPY	VARCHAR2,
		p_awt_group_id			IN OUT NOCOPY	NUMBER,
		p_excl_freight_from_disc	IN OUT NOCOPY	VARCHAR2,
		p_payment_currency		IN OUT NOCOPY	VARCHAR2,
                p_auto_tax_calc_flag            IN OUT NOCOPY  VARCHAR2,  -- Bug 1971188
		p_calling_sequence		IN 	VARCHAR2,
                p_party_id                      IN OUT nocopy   NUMBER, --4552701, added party info
                p_party_site_id                 IN OUT nocopy   NUMBER);

Procedure  Create_Invoice_batch(
		p_receipt_num			IN	VARCHAR2,
		p_inv_curr			IN	VARCHAR2,
		p_inv_payment_curr		IN	VARCHAR2,
		p_rts_txn_date			IN 	DATE,
		p_user_id			IN	NUMBER,
		p_login_id			IN	NUMBER,
		p_batch_id			IN OUT NOCOPY	NUMBER,
		p_calling_sequence		IN	VARCHAR2);

Procedure  Create_Invoice_Header (
		p_vendor_site_id		IN	NUMBER,
		p_vendor_id			IN	NUMBER,
		p_receipt_num			IN	VARCHAR2,
		p_receipt_uom			IN	VARCHAR2,
		p_invoice_curr			IN 	VARCHAR2,
		p_inv_pay_curr			IN 	VARCHAR2,
		p_base_curr			IN	VARCHAR2,
		p_gl_date_from_rect_flag	IN 	VARCHAR2,
		p_set_of_books_id		IN 	NUMBER,
		p_quantity			IN	NUMBER,
		p_quantity_uom			IN	VARCHAR2,
		p_price				IN	NUMBER,
		p_quantity_billed		IN	NUMBER,
		p_batch_id			IN 	NUMBER,
		p_payment_method		IN 	VARCHAR2,
		p_pay_group			IN 	VARCHAR2,
		p_accts_pay_ccid		IN	NUMBER,
		p_excl_pay_flag			IN 	VARCHAR2,
		p_transaction_date		IN 	DATE,
		p_rts_txn_date			IN	DATE,
		p_rcv_rate			IN 	NUMBER,
		p_rcv_rate_date			IN 	DATE,
		p_rcv_rate_type			IN 	VARCHAR2,
		p_terms_date_basis		IN	VARCHAR2,
		p_terms_id			IN 	NUMBER,
		p_awt_group_id			IN	NUMBER,
		p_user_id			IN	NUMBER,
		p_login_id			IN	NUMBER,
		p_invoice_id			IN OUT NOCOPY	NUMBER,
		p_amount			IN OUT NOCOPY  NUMBER,
		p_terms_date			IN OUT NOCOPY	DATE,
		p_pay_curr_invoice_amount	IN OUT NOCOPY	NUMBER,
		p_pay_cross_rate		IN OUT NOCOPY	NUMBER,
                p_auto_tax_calc_flag            IN      VARCHAR2,
		p_calling_sequence		IN	VARCHAR2,
                p_PAYMENT_REASON_CODE           IN      VARCHAR2,
                p_BANK_CHARGE_BEARER            IN      VARCHAR2,
                p_DELIVERY_CHANNEL_CODE         IN      VARCHAR2,
                p_SETTLEMENT_PRIORITY           IN      VARCHAR2,
                p_external_bank_account_id      IN      NUMBER,
                p_le_id                         in      number,
                p_party_id                      in      number,
                p_party_site_id                 in      number,
                p_payment_reason_comments       in      varchar2,
                /* bug 5227816 */
                p_org_id                        IN      NUMBER,
                p_remit_to_supplier_name        IN      VARCHAR2,  --Start 7758980
                p_remit_to_supplier_id          IN      NUMBER  ,
                p_remit_to_supplier_site        IN      VARCHAR2,
                p_remit_to_supplier_site_id     IN      NUMBER  ,
                p_relationship_id               IN      NUMBER     --End 7758980
                ) ;

FUNCTION create_dm_tax (p_invoice_id       IN NUMBER,
			p_invoice_amount   IN NUMBER,
			p_error_code	   OUT NOCOPY VARCHAR2,
                         p_calling_sequence IN VARCHAR2) RETURN BOOLEAN;

/*-------------------------------------------------------------------------
Main Public Function : Create_DM
--------------------------------------------------------------------------

p_rcv_txn_id : The transaction_id for which the RTS is issued (should always
	       be the id of the RECEIVE transaction)
p_rts_txn_id : The transaction_id of the RETURN (RTS) Trasnaction itself
p_po_dist_id : If the Return is done against a delivery and the
	       po_distribution_id is known. If this is null, the quantity
	       will be prorated across the po distributions.
p_quantity   : The quantity returned. Please note that the quantity should be
	       in the same UOM as the Receive Transaction, because we are
	       matching against that transaction. The quantity should be
	       negative.
p_qty_uom    : The UOM the quantity is in.
p_unit_price : The price at which the goods are returned. This price will be
	       the same as the PO price but should be passed in terms of
	       x_qty_uom. The quantity and unit_price are used to get the
	       amount and these 2 should correspondto the same UOM. The unit
	       price should be positive.
p_user_id    : AOL User Id from the Form
p_login_id   : AOL Login Id from the form
p_calling_seq: The name of the module calling this function. Used for exception
	       handling


This procedure returns a Boolean value of TRUE when it completes sucessfully
and will return a value of FALSE when either a known exception or an unhandled
exception occurs. The Oracle error is stored on the message stack when an
unhandled exception occures. a meaningful error is stored when a known
exception occurs.
--------------------------------------------------------------------------*/

Function  Create_DM (
		p_rcv_txn_id		IN	NUMBER,
		p_rts_txn_id		IN	NUMBER,
		p_po_dist_id		IN	NUMBER,
		p_quantity		IN	NUMBER,
		p_qty_uom		IN	VARCHAR2,
		p_unit_price		IN	NUMBER,
	        p_user_id		IN	NUMBER,
		p_login_id		IN	NUMBER,
		p_calling_sequence	IN	VARCHAR2)
RETURN BOOLEAN IS

   l_vendor_id		rcv_transactions.vendor_id%TYPE;
   l_vendor_site_id	rcv_transactions.vendor_site_id%TYPE;
   l_rcv_currency_code	rcv_transactions.currency_code%TYPE;
   l_po_shipment_id	rcv_transactions.po_line_location_id%TYPE;
   l_rcv_txn_date	rcv_transactions.transaction_date%TYPE;
   l_rcv_rate		rcv_transactions.currency_conversion_rate%TYPE;
   l_rcv_rate_date	rcv_transactions.currency_conversion_date%TYPE;
   l_rcv_rate_type	rcv_transactions.currency_conversion_type%TYPE;
   l_receipt_num	rcv_shipment_headers.receipt_num%TYPE;
   l_receipt_uom	rcv_shipment_lines.unit_of_measure%TYPE;
   l_po_pay_terms_id	po_line_locations.terms_id%TYPE;
   l_set_of_books_id	ap_system_parameters.set_of_books_id%TYPE;
   l_base_currency_code ap_system_parameters.base_currency_code%TYPE;
   l_batch_control_flag ap_system_parameters.batch_control_flag%TYPE;
   l_gl_date_from_rect_flag ap_system_parameters.gl_date_from_receipt_flag%TYPE;
   l_pay_group_lookup_code po_vendor_sites.pay_group_lookup_code%TYPE;
   l_accts_pay_ccid	po_vendor_sites.accts_pay_code_combination_id%TYPE;

   --4552701, added the fields below
   l_payment_method_code	varchar2(30);
   l_exclusive_payment_flag varchar2(1);
   l_party_id           number;
   l_party_site_id      number;
   l_le_id              number;
   l_PAYMENT_REASON            varchar2(80);
   l_BANK_CHARGE_BEARER_DSP    varchar2(80);
   l_DELIVERY_CHANNEL          varchar2(80);
   l_SETTLEMENT_PRIORITY_DSP   varchar2(80);
   l_bank_account_num          varchar2(100);
   l_bank_account_name         varchar2(80);
   l_bank_branch_name          varchar2(360);
   l_bank_branch_num           varchar2(30);
   l_bank_name                 varchar2(360);
   l_bank_number               varchar2(30);
   l_PAYMENT_REASON_CODE       varchar2(30);
   l_BANK_CHARGE_BEARER        varchar2(30);
   l_DELIVERY_CHANNEL_CODE     varchar2(30);
   l_SETTLEMENT_PRIORITY       varchar2(30);
   l_IBY_PAYMENT_METHOD        varchar2(80);
   l_external_bank_account_id  number;

   --4874927
   l_payment_reason_comments   varchar2(240);

   l_payment_priority 	po_vendor_sites.payment_priority%TYPE;
   l_terms_date_basis 	po_vendor_sites.terms_date_basis%TYPE;
   l_vendor_income_tax_region po_vendor_sites.state%TYPE;
   l_type_1099		po_vendors.type_1099%TYPE;
   l_allow_awt_flag	po_vendor_sites.allow_awt_flag%TYPE;
   l_awt_group_id	po_vendor_sites.awt_group_id%TYPE;
   l_excl_freight_from_disc  po_vendor_sites.exclude_freight_from_discount%TYPE;
   l_payment_currency	po_vendor_sites.payment_currency_code%TYPE;

   l_inv_payment_curr	po_vendor_sites.payment_currency_code%TYPE;
   l_batch_id		ap_batches.batch_id%TYPE;
   l_rts_txn_date	rcv_transactions.transaction_date%TYPE;
   l_rcv_quantity_billed rcv_transactions.quantity_billed%TYPE;
   l_invoice_id		ap_invoices.invoice_id%TYPE;
   l_amount		ap_invoices.invoice_amount%TYPE;
   l_terms_date		DATE;
   l_pay_curr_invoice_amount ap_invoices.pay_curr_invoice_amount%TYPE;
   l_pay_cross_rate	ap_invoices.payment_cross_rate%TYPE;
   l_item_description	po_lines.item_description%TYPE;

   debug_info			VARCHAR2(2000);
   curr_calling_sequence	VARCHAR2(2000);
   l_po_dist_id                 NUMBER ; --Bug fix:1413339
   l_derive_type_rcv_curr       VARCHAR2(10); --Bug fix:1891850
   l_derive_type_payment_curr   VARCHAR2(10); --Bug fix:1891850
   --  Bug fix : 1971188 - definition of variables
   l_auto_tax_calc_flag_sys     ap_system_parameters.auto_tax_calc_flag%TYPE;
   l_auto_tax_calc_flag         ap_supplier_sites_all.auto_tax_calc_flag%TYPE;

   --Bug: 2902340
   l_match_option       po_line_locations.match_option%TYPE;
   l_invoice_exists     varchar2(1);

   --bug:4537655
   l_match_mode			VARCHAR2(25);
   l_org_id			NUMBER;
   l_po_uom			PO_LINES_ALL.UNIT_MEAS_LOOKUP_CODE%TYPE;
   l_dist_tab			AP_MATCHING_PKG.DIST_TAB_TYPE;
   l_error_code			VARCHAR2(4000);
   l_success			BOOLEAN;
   l_invoice_amount		AP_INVOICES_ALL.INVOICE_AMOUNT%TYPE;
   l_po_ccid			NUMBER; --bugfix:5395955
   l_remit_to_supplier_name     ap_invoices_all.remit_to_supplier_name%TYPE;  --Start 7758980
   l_remit_to_supplier_id       ap_invoices_all.remit_to_supplier_id%TYPE;
   l_remit_to_supplier_site     ap_invoices_all.remit_to_supplier_site%TYPE;
   l_remit_to_supplier_site_id  ap_invoices_all.remit_to_supplier_site_id%TYPE;
   l_relationship_id            ap_invoices_all.relationship_id%TYPE;
   l_remit_party_id             ap_invoices_all.party_id%TYPE;
   l_remit_party_site_id        ap_invoices_all.party_site_id%TYPE; --End 7758980

   --  Start 9267199
    l_default_pay_site_id   ap_supplier_sites.vendor_site_id%type;
    l_valid_pay_site_flag		VARCHAR2(1);
    l_api_name CONSTANT VARCHAR2(200) := 'Create_DM';
   --End 9267199

Begin

    curr_calling_sequence := p_calling_sequence ||' <- Create_DM';
    l_invoice_exists := 'N';

    /* STEP 1:
	Retreive all required information from rcv_transactions */

    debug_info := 'Retreive receipt information';

    --Bug fix:1413339
    IF(p_po_dist_id = 0) THEN
      l_po_dist_id := NULL;
    ELSE
      l_po_dist_id := p_po_dist_id;
    END IF;

    Get_receipt_info (	p_rcv_txn_id,
			p_rts_txn_id,
			l_vendor_id,
			l_vendor_site_id,
			l_rcv_currency_code,
			l_po_shipment_id,
			l_po_dist_id,  /* Bug fix:1712542 */
			l_rcv_txn_date,
			l_rcv_rate,
			l_rcv_rate_date,
			l_rcv_rate_type,
			l_receipt_num,
			l_receipt_uom,
			l_po_pay_terms_id,
			l_rcv_quantity_billed,
			l_rts_txn_date,
			l_item_description,
			l_match_option, --bug:2902340
			l_org_id,
			l_po_uom,
			l_po_ccid,  --bugfix:5395955
			curr_calling_sequence);

   If l_po_dist_id is NULL Then

      Begin
       Select 'Y'
         Into l_invoice_exists
         From ap_invoice_distributions aid,
              po_distributions pd,
              po_line_locations pll
        where aid.po_distribution_id = pd.po_distribution_id
          and pd.line_location_id = pll.line_location_id
          and pll.line_location_id = l_po_shipment_id
          and nvl(aid.rcv_transaction_id,-1) =
                   nvl(DECODE(l_match_option,'P',NULL,p_rcv_txn_id),-1)
          and rownum=1;
      EXCEPTION WHEN OTHERS THEN
         l_invoice_exists := 'N';
         return(FALSE);
      END;


   Else -- Perform this check only when l_po_dist_id is not NULL

     BEGIN

          SELECT 'Y'
            INTO l_invoice_exists
            FROM ap_invoice_distributions aid
           WHERE aid.po_distribution_id = p_po_dist_id
             AND nvl(aid.rcv_transaction_id,-1) =
                          nvl(DECODE(l_match_option,'P',NULL,p_rcv_txn_id),-1)
             AND rownum = 1;

     EXCEPTION WHEN OTHERS THEN
        l_invoice_exists := 'N';
        return(FALSE);
     END;
   End if;  -- l_po_dist_id is NULL


  --Bug: 2902340: added the IF condition
  If l_invoice_exists ='Y' Then

    /* STEP 2 :
	Retreive information from ap_system_parameters */

    debug_info := 'retrieve information from ap_system_parameters';

    SELECT
	set_of_books_id,
	base_currency_code,
	gl_date_from_receipt_flag,
        auto_tax_calc_flag  -- bug fix 1971188
    INTO
	l_set_of_books_id,
	l_base_currency_code,
	l_gl_date_from_rect_flag,
        l_auto_tax_calc_flag_sys
    FROM ap_system_parameters
    WHERE org_id = l_org_id ;

    --Bug :2024697
    --Shared Services - Profile_Options : Added the following code so as get the
    --value of invoice batch control flag from profile options instead
    --of payables options.
    BEGIN

      FND_PROFILE.GET('AP_USE_INV_BATCH_CONTROLS',l_batch_control_flag);

    EXCEPTION WHEN OTHERS THEN
      l_batch_control_flag := 'N';
    END ;

    --Introduced below code for bug#9267199 and commented in Create_invoice_header
    --procedure
    --Start of bug#9267199

    debug_info := 'Check if there is an alternate_pay_site';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;

    SELECT default_pay_site_id
    INTO   l_default_pay_site_id
    FROM   po_vendor_sites
    WHERE  vendor_site_id = l_vendor_site_id;

    if ( l_default_pay_site_id is not NULL ) then

    	Begin
		select 'Y'
                into l_valid_pay_site_flag
		from po_vendor_sites
		where vendor_site_id = l_default_pay_site_id
		  and pay_site_flag = 'Y'
		  and nvl(inactive_date, sysdate +1) > sysdate;
    	Exception
		WHEN NO_DATA_FOUND Then
			l_valid_pay_site_flag := 'N';
		END;
   	end if;

        --Modified y to Y for bug#9374448
	if ( l_default_pay_site_id is not NULL and l_valid_pay_site_flag = 'Y') then
		l_vendor_site_id := l_default_pay_site_id;
	else
    	  debug_info := 'no valid alternate paysite, check if valid pay site';

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           debug_info);
         END IF;

        Begin

		SELECT 'Y'
		INTO l_valid_pay_site_flag
		FROM po_vendor_sites
		WHERE vendor_site_id = l_vendor_site_id
	  	  AND pay_site_flag = 'Y'
	  	  AND nvl(inactive_date, sysdate +1) > sysdate;
        Exception
		WHEN NO_DATA_FOUND Then
		-- It is not a valid pay site , a user freindly error message
		-- is set on the stack.
			fnd_message.set_name('SQLAP','AP_NOT_VALID_PAY_SITE');
			app_exception.raise_exception;
    	   End;
	end if;

    --End of bug#9267199

    /*STEP 3:
	Retreive vendor related information */

    debug_info := 'Get vendor related information';


    Get_vendor_info (
	  	l_vendor_id,
		l_vendor_site_id,
		l_pay_group_lookup_code,
		l_accts_pay_ccid,
		l_payment_priority,
		l_terms_date_basis,
		l_vendor_income_tax_region,
		l_type_1099,
		l_allow_awt_flag,
		l_awt_group_id,
		l_excl_freight_from_disc,
		l_payment_currency,
                l_auto_tax_calc_flag,  -- Bug 1971188
		curr_calling_sequence,
                l_party_id,
                l_party_site_id);


    /*STEP 4:
	Obtain the invoice payment currency taking euro relations into
	consideration */


	--Bug fix:1891850
	--If the payment currency and invoice currency on the
	--supplier site is NULL, then we will create the debit memo
	--in the receipt currency, which is same as PO currency.
	IF( l_payment_currency IS NULL) THEN

    	   l_payment_currency := l_rcv_currency_code ;

        ELSE

	   SELECT NVL(fnd1.derive_type,'OTHER'),NVL(fnd2.derive_type,'OTHER')
	   INTO l_derive_type_rcv_curr,l_derive_type_payment_curr
	   FROM fnd_currencies fnd1,fnd_currencies fnd2
	   WHERE fnd1.currency_code = l_rcv_currency_code
	   AND fnd2.currency_code = l_payment_currency;

     	   IF( l_payment_currency <>l_rcv_currency_code ) AND
	      l_derive_type_rcv_curr IN ('EMU','EURO') AND
		  l_derive_type_payment_curr IN ('EMU','EURO') THEN
                NULL;
           ELSE
	        l_payment_currency := l_rcv_currency_code ;
           END IF;

        END IF;


	debug_info := 'get invoice payment currency';
        --Bug 3492081
        If (gl_currency_api.is_fixed_rate(l_payment_currency,
					l_rcv_currency_code,
					trunc(l_rts_txn_date)) = 'Y') then
		l_inv_payment_curr := l_payment_currency;
	Else
		l_inv_payment_curr := l_rcv_currency_code;
	End if;


        --4552701, get le and payment attributes

        ap_utilities_pkg.get_Invoice_LE(
          p_vendor_site_id => l_vendor_site_id,
          p_inv_liab_ccid  => l_accts_pay_ccid,
          p_org_id         => l_org_id,
          p_le_id          => l_le_id);

        -- Bug 7758980 Assinging values as part of Third Party Payments.
        IBY_EXT_PAYEE_RELSHIPS_PKG.default_Ext_Payee_Relationship (
            p_party_id => l_party_id,
            p_supplier_site_id =>  l_vendor_site_id,
            p_date => l_rts_txn_date,
            x_remit_party_id => l_remit_party_id,
            x_remit_supplier_site_id => l_remit_to_supplier_site_id,
            x_relationship_id => l_relationship_id
        );

        if (l_remit_party_id is not null ) then
         select vendor_id,vendor_name
           into l_remit_to_supplier_id,l_remit_to_supplier_name
           from ap_suppliers
          where party_id = l_remit_party_id;
        end if;

        if (l_remit_to_supplier_site_id is not null) then
         select party_site_id,vendor_site_code
           into l_remit_party_site_id,l_remit_to_supplier_site
           from ap_supplier_sites_all
          where vendor_site_id = l_remit_to_supplier_site_id;
        end if;  --End 7758980

        -- Bug 8774769: Added back NVL condition which was part of bug 8345877
	-- and overriden by 8593333 due to triple checkin enabling.

        ap_invoices_pkg.get_payment_attributes(
        p_le_id                     =>l_le_id,
        p_org_id                    =>l_org_id,
        p_payee_party_id            => nvl(l_remit_party_id, l_party_id), --Start 7758980
        p_payee_party_site_id       => nvl(l_remit_party_site_id, l_party_site_id),
        p_supplier_site_id          => nvl(l_remit_to_supplier_site_id, l_vendor_site_id),--End 7758980
        p_payment_currency          => l_inv_payment_curr,
        p_payment_amount            => 1, --just a dummy value since this isn't known here
        p_payment_function          =>'PAYABLES_DISB',
        p_pay_proc_trxn_type_code   =>'PAYABLES_DOC',

        p_PAYMENT_METHOD_CODE       => l_payment_method_code,
        p_PAYMENT_REASON_CODE       => l_payment_reason_code,
        p_BANK_CHARGE_BEARER        => l_bank_charge_bearer,
        p_DELIVERY_CHANNEL_CODE     => l_delivery_channel_code,
        p_SETTLEMENT_PRIORITY       => l_settlement_priority,
        p_PAY_ALONE                 => l_exclusive_payment_flag,
        p_external_bank_account_id  => l_external_bank_account_id,

        p_IBY_PAYMENT_METHOD        => l_IBY_PAYMENT_METHOD,
        p_PAYMENT_REASON            => l_PAYMENT_REASON,
        p_BANK_CHARGE_BEARER_DSP    => l_BANK_CHARGE_BEARER_DSP,
        p_DELIVERY_CHANNEL          => l_DELIVERY_CHANNEL,
        p_SETTLEMENT_PRIORITY_DSP   => l_SETTLEMENT_PRIORITY_DSP,
        p_bank_account_num          => l_bank_account_num,
        p_bank_account_name         => l_bank_account_name,
        p_bank_branch_name          => l_bank_branch_name,
        p_bank_branch_num           => l_bank_branch_num,
        p_bank_name                 => l_bank_name,
        p_bank_number               => l_bank_number,
        p_payment_reason_comments   => l_payment_reason_comments); --4874927


    /*STEP 4:
	If batch control is on create an Invoice batch */
        debug_info := 'Creating invoice batch';


        If (l_batch_control_flag = 'Y') Then

	    debug_info := 'creating invoice batch';

            Create_Invoice_batch(l_receipt_num,
			     l_rcv_currency_code,
			     l_inv_payment_curr,
			     l_rts_txn_date,
			     p_user_id,
			     p_login_id,
			     l_batch_id,
			     curr_calling_sequence);
	End if;

    /*STEP 4a:
      Validate automatic calculation of tax flag.  Bug fix 1971188
      If automatic tax calculation is active <> 'N'(None)
      must select value of the flag from vendor site info
      Following standar behavior. */

      IF l_auto_tax_calc_flag_sys = 'N' THEN
         l_auto_tax_calc_flag := 'N';
      END IF;


    /*STEP 5:
	Create the invoice header */

	debug_info := 'Creating Invoice Header';

	Create_Invoice_Header (
		p_vendor_site_id	=>l_vendor_site_id,
		p_vendor_id		=>l_vendor_id,
		p_receipt_num		=>l_receipt_num,
		p_receipt_uom		=>l_receipt_uom,
		p_invoice_curr		=>l_rcv_currency_code,
		p_inv_pay_curr		=>l_inv_payment_curr,
		p_base_curr		=>l_base_currency_code,
		p_gl_date_from_rect_flag =>l_gl_date_from_rect_flag,
		p_set_of_books_id	=>l_set_of_books_id,
		p_quantity		=>p_quantity,
		p_quantity_uom		=>p_qty_uom,
		p_price			=>p_unit_price,
		p_quantity_billed	=>l_rcv_quantity_billed,
		p_batch_id		=>l_batch_id,
		p_payment_method	=>l_payment_method_code,
		p_pay_group		=>l_pay_group_lookup_code,
		p_accts_pay_ccid	=>l_accts_pay_ccid,
		p_excl_pay_flag		=>l_exclusive_payment_flag,
		p_transaction_date	=>l_rcv_txn_date,
		p_rts_txn_date		=>l_rts_txn_date,
		p_rcv_rate		=>l_rcv_rate,
		p_rcv_rate_date		=>l_rcv_rate_date,
		p_rcv_rate_type		=>l_rcv_rate_type,
		p_terms_date_basis	=>l_terms_date_basis,
		p_terms_id		=>l_po_pay_terms_id,
		p_awt_group_id		=>l_awt_group_id,
		p_user_id		=>p_user_id,
		p_login_id		=>p_login_id,
		p_invoice_id		=>l_invoice_id, --out param
		p_amount		=>l_amount, --out param
		p_terms_date		=>l_terms_date, --out param
		p_pay_curr_invoice_amount => l_pay_curr_invoice_amount, --out
		p_pay_cross_rate	=>l_pay_cross_rate, --out
                p_auto_tax_calc_flag    =>l_auto_tax_calc_flag, --  Bug fix: 1971188
		p_calling_sequence	=>curr_calling_sequence,
                p_PAYMENT_REASON_CODE       => l_payment_reason_code, --4552701
                p_BANK_CHARGE_BEARER        => l_bank_charge_bearer,
                p_DELIVERY_CHANNEL_CODE     => l_delivery_channel_code,
                p_SETTLEMENT_PRIORITY       => l_settlement_priority,
                p_external_bank_account_id  => l_external_bank_account_id,
                p_le_id                     => l_le_id,
                p_party_id                  => l_party_id,
                p_party_site_id             => l_party_site_id,
                p_payment_reason_comments   => l_payment_reason_comments, --4874927
                p_org_id                    => l_org_id, /*bug 5227816*/
                p_remit_to_supplier_name    =>  l_remit_to_supplier_name,   --Start 7758980
                p_remit_to_supplier_id      =>  l_remit_to_supplier_id,
                p_remit_to_supplier_site    =>  l_remit_to_supplier_site,
                p_remit_to_supplier_site_id =>  l_remit_to_supplier_site_id,
                p_relationship_id           =>  l_relationship_id);      --End 7758980

    /* STEP 6 :
	Call the receipt matching package to create a matched distribution */

	debug_info := 'Creating matched invoice distribution';

        IF (l_po_dist_id IS NULL) THEN
	  l_match_mode := 'CR-PS';
        ELSE
	  l_match_mode := 'CR-PD';
          l_dist_tab(l_po_dist_id).po_distribution_id := l_po_dist_id;
	  l_dist_tab(l_po_dist_id).quantity_invoiced := p_quantity;
	  l_dist_tab(l_po_dist_id).unit_price := p_unit_price;
	  l_dist_tab(l_po_dist_id).amount := l_amount;
	  --bugfix:5395955
	  l_dist_tab(l_po_dist_id).dist_ccid := l_po_ccid;
	END IF;

        ap_rect_match_pkg.base_credit_rcv_match(
	   		    X_match_mode          => l_match_mode,
                            X_invoice_id          => l_invoice_id,
                            X_invoice_line_number => NULL,
                            X_Po_Line_Location_id => l_po_shipment_id,
                            X_rcv_transaction_id  => p_rcv_txn_id,
                            X_Dist_Tab            => l_dist_tab,
                            X_amount              => l_amount,
                            X_quantity            => p_quantity,
                            X_unit_price          => p_unit_price,
                            X_uom_lookup_code     => l_po_uom,
                            X_freight_cost_factor_id => NULL,
                            X_freight_amount      => NULL,
                            X_freight_description => NULL,
                            X_misc_cost_factor_id => NULL,
                            X_misc_amount         => NULL,
                            X_misc_description    => NULL,
                            X_retained_amount     => NULL,
                            X_calling_sequence    => curr_calling_sequence);


      /* STEP 7 :
        Call the create_dm_tax procedure to calculate tax on Debit Memo */

        debug_info := 'Calculating Tax on Debit Memo';

	l_success := create_dm_tax(l_invoice_id,
				   l_amount,
				   l_error_code,
				   curr_calling_sequence);

        --If Tax-Calculation Failed
        IF NOT(l_success) THEN

           debug_info := 'Call to EBTax api - Calculate Tax failed';

	   fnd_message.set_name('SQLAP',l_error_code);

           Return(FALSE);

        END IF;


       --Bugfix:2845989 , moved the call here from step 6 to step8
       --to be after the tax calculation.
       /* STEP 8 :
       Create the payment schedules for this invoice */

       debug_info := 'Recalculate pay curr inv amount ';

       SELECT invoice_amount
       INTO l_invoice_amount
       FROM ap_invoices
       WHERE invoice_id = l_invoice_id;

       /* Procced in re-calculation only when tax is calculated.
         where in the invoice amount would have changed.
       */

      IF (l_invoice_amount <> l_amount ) THEN

        IF (l_rcv_currency_code <> l_inv_payment_curr)  THEN
            l_pay_curr_invoice_amount := gl_currency_api.convert_amount(
                                               l_rcv_currency_code,
                                               l_inv_payment_curr,
                                               l_terms_date,
                                               'EMU FIXED',
                                               l_invoice_amount);

        END IF;

        l_amount := l_invoice_amount;
      END IF;


      debug_info := 'Creating payment schedules';
      ap_create_pay_scheds_pkg.ap_create_from_terms (
                       p_invoice_id            =>l_invoice_id,
                       p_terms_id              =>l_po_pay_terms_id,
                       p_last_updated_by       =>p_user_id,
                       p_created_by            =>p_user_id,
                       p_payment_priority      =>l_payment_priority,
                       p_batch_id              =>l_batch_id,
                       p_terms_date            =>l_terms_date,
                       p_invoice_amount        =>l_amount,
                       p_amount_for_discount   =>l_amount,
                       p_payment_method        =>l_payment_method_code, --4552701
                       p_invoice_currency      =>l_rcv_currency_code,
                       p_payment_currency      =>l_inv_payment_curr,
                       p_pay_curr_invoice_amount =>nvl(l_pay_curr_invoice_amount,l_amount),
                       p_payment_cross_rate    => nvl(l_pay_cross_rate,1),
                       p_calling_sequence      => curr_calling_sequence);

    END IF; /*If l_invoice_exists */

    -- no exceptions upto this point return true
    Return(TRUE);

Exception
    WHEN OTHERS THEN

	If (SQLCODE <> -20001) Then
	    fnd_message.set_name('SQLAP','AP_DEBUG');
	    fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE',curr_calling_sequence);

	    fnd_message.set_token('PARAMETERS',
		' rcv_transaction_id = '||to_char(p_rcv_txn_id)
	      ||' po_dist_id = '||to_char(p_po_dist_id)
 	      ||' quantity = '||to_char(p_quantity)
	      ||' unit price = '||to_char(p_unit_price)
	      ||' user_id = '||to_char(p_user_id)
	      ||' login_id = '||to_char(p_login_id));

	    fnd_message.set_token('DEBUG_INFO',debug_info);
	End if;

	Return(FALSE);

End Create_DM;

/*--------------End of Main Function------------------------------*/

/* Private Procedure/functions */

/*-------------------------------------------------------------------------
GET_RECEIPT_INFO : Gets relevant information from rcv_transactions and
po_shipments
--------------------------------------------------------------------------*/
Procedure Get_receipt_info(
			p_rcv_txn_id		IN	NUMBER,
			p_rts_txn_id		IN	NUMBER,
			p_vendor_id		IN OUT NOCOPY	NUMBER,
			p_vendor_site_id	IN OUT NOCOPY	NUMBER,
			p_rcv_currency_code	IN OUT NOCOPY	VARCHAR2,
			p_po_shipment_id	IN OUT NOCOPY	NUMBER,
			p_po_dist_id		IN      NUMBER,/*Bug1712542*/
			p_rcv_txn_date		IN OUT NOCOPY	DATE,
			p_rcv_rate		IN OUT NOCOPY	NUMBER,
			p_rcv_rate_date		IN OUT NOCOPY	DATE,
			p_rcv_rate_type		IN OUT NOCOPY  VARCHAR2,
			p_receipt_num		IN OUT NOCOPY	VARCHAR2,
			p_receipt_uom		IN OUT NOCOPY	VARCHAR2,
			p_po_pay_terms_id	IN OUT NOCOPY	NUMBER,
			p_quantity_billed	IN OUT NOCOPY	NUMBER,
			p_rts_txn_date		IN OUT NOCOPY 	DATE,
			p_item_description	IN OUT NOCOPY	VARCHAR2,
			--Bugfix: 2902340
			p_match_option		IN OUT NOCOPY   VARCHAR2,
			p_org_id		IN OUT NOCOPY   NUMBER,
			p_po_uom		IN OUT NOCOPY   VARCHAR2,
			p_po_ccid		IN OUT NOCOPY   NUMBER,  --BUGFIX:5395955
			p_calling_sequence	IN	VARCHAR2) IS

    debug_info		VARCHAR2(2000);
    curr_calling_sequence	VARCHAR2(2000);
    l_errm		VARCHAR2(2000);

Begin

    curr_calling_sequence := p_calling_sequence ||' <- Get_receipt_Info';


    debug_info := 'get required information from RECEIVE transaction';

    SELECT
	rtxn.vendor_id,
	rtxn.vendor_site_id,
	rtxn.currency_code,
	rtxn.po_line_location_id,
	rtxn.transaction_date,
	decode (rtxn.currency_conversion_type, null, null,
			rtxn.currency_conversion_rate),
	rtxn.currency_conversion_date,
	rtxn.currency_conversion_type,
	rsh.receipt_num,
	rsl.unit_of_measure,
	nvl( nvl(pll.terms_id,ph.terms_id),pvs.terms_id),
	/* Bug fix: 1413309 added the pll.quantity_billed to the clause */
	nvl(rtxn.quantity_billed,nvl(pll.quantity_billed,0)),
	pl.item_description,
	pll.match_option,
	pll.org_id,
        pl.unit_meas_lookup_code
    INTO
	p_vendor_id,
	p_vendor_site_id,
	p_rcv_currency_code,
	p_po_shipment_id,
	p_rcv_txn_date,
	p_rcv_rate,
	p_rcv_rate_date,
	p_rcv_rate_type,
	p_receipt_num,
	p_receipt_uom,
	p_po_pay_terms_id,
	p_quantity_billed,
	p_item_description,
	p_match_option, --bug2902340
	p_org_id,
	p_po_uom
    FROM
	rcv_transactions rtxn,
	rcv_shipment_headers rsh,
	rcv_shipment_lines  rsl,
	po_headers ph,
	po_line_locations pll,
	po_lines pl,
	po_vendor_sites pvs
    WHERE rtxn.transaction_id = p_rcv_txn_id and
	  rtxn.shipment_line_id = rsl.shipment_line_id and
	  rsl.shipment_header_id = rsh.shipment_header_id and
	  rtxn.po_line_location_id = pll.line_location_id and
	  pll.po_line_id = pl.po_line_id and
	  pl.po_header_id = ph.po_header_id and
	  rtxn.vendor_site_id = pvs.vendor_site_id and
	  --Bug fix:2662505 Consigned Inventory for Supplier Project Impact
	  --Debit memo should not be created for RTS done on the receipt
	  --of a shipment,which has the consigned_flag set to Y.
	  nvl(pll.consigned_flag,'N') <> 'Y';

    debug_info := 'Select information from RTS transaction';


    SELECT transaction_date
    INTO p_rts_txn_date
    FROM rcv_transactions
    WHERE transaction_id = p_rts_txn_id;

    --Bugfix:5395955
    IF (p_po_dist_id IS NOT NULL) THEN
       SELECT code_combination_id
       INTO p_po_ccid
       FROM po_distributions_ap_v
       WHERE po_distribution_id = p_po_dist_id;
    END IF;

Exception
    WHEN OTHERS THEN
	If (SQLCODE <> -20001) Then
	    fnd_message.set_name('SQLAP','AP_DEBUG');
	    fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE',curr_calling_sequence);
	    fnd_message.set_token('PARAMETERS',
		' rcv_transaction_id = '||to_char(p_rcv_txn_id));
	    fnd_message.set_token('DEBUG_INFO',debug_info);
	End if;
	app_exception.raise_exception;

End Get_Receipt_Info;

/*-------------------------------------------------------------------------
GET_VENDOR_INFO : Get vendor and vendor site related information. Look for
value in the vendor site first and if null else get value from po_vendors
--------------------------------------------------------------------------*/
Procedure Get_vendor_info (
	  	p_vendor_id			IN	NUMBER,
		p_vendor_site_id		IN	NUMBER,
		p_pay_group_lookup_code		IN OUT NOCOPY	VARCHAR2,
		p_accts_pay_ccid		IN OUT NOCOPY	NUMBER,
		p_payment_priority		IN OUT NOCOPY	NUMBER,
		p_terms_date_basis		IN OUT NOCOPY  VARCHAR2,
		p_vendor_income_tax_region	IN OUT NOCOPY	VARCHAR2,
		p_type_1099			IN OUT NOCOPY	VARCHAR2,
		p_allow_awt_flag		IN OUT NOCOPY	VARCHAR2,
		p_awt_group_id			IN OUT NOCOPY	NUMBER,
		p_excl_freight_from_disc	IN OUT NOCOPY	VARCHAR2,
		p_payment_currency		IN OUT NOCOPY	VARCHAR2,
                p_auto_tax_calc_flag            IN OUT NOCOPY  VARCHAR2, -- Bug 1971188
		p_calling_sequence			VARCHAR2,
                p_party_id                      IN OUT nocopy  NUMBER, --4552701, added party info
                p_party_site_id                 IN OUT nocopy  NUMBER) IS

curr_calling_sequence		VARCHAR2(2000);
debug_info 			VARCHAR2(2000);
l_default_pay_site_id           NUMBER;

Begin

    curr_calling_sequence:= 'p_calling_sequence '||' <- Get_vendor_Info';
    debug_info := 'Get vendor information';

    /* Bug 2226808 select the payment information based on the Alternative (default)
       Payment site if it exists, otherwise, select the information based on the
       Purchasing site.
       Add the following SELECT and use l_default_pay_site_id in the WHERE for the
       second SELECT instead of p_vendor_sit_id */

   --Commented below stmt for bug#9267199
   /* SELECT  NVL(pvs.default_pay_site_id,pvs.vendor_site_id)
      INTO  l_default_pay_site_id
      FROM  po_vendor_sites pvs
     WHERE  vendor_site_id = p_vendor_site_id; */

    SELECT
	nvl(pvs.pay_group_lookup_code, pv.pay_group_lookup_code),
	pvs.accts_pay_code_combination_id,
	pvs.payment_priority,
	pvs.terms_date_basis,
	pvs.state,
	pv.type_1099,
	pvs.allow_awt_flag,
	pvs.awt_group_id,
	pvs.exclude_freight_from_discount,
	nvl(pvs.payment_currency_code, pvs.invoice_currency_code),
        pvs.auto_tax_calc_flag,  -- Bug fix 1971188
        pv.party_id,
        pvs.party_site_id
    INTO
	p_pay_group_lookup_code,
	p_accts_pay_ccid,
	p_payment_priority,
	p_terms_date_basis,
	p_vendor_income_tax_region,
	p_type_1099,
	p_allow_awt_flag,
	p_awt_group_id,
	p_excl_freight_from_disc,
	p_payment_currency,
        p_auto_tax_calc_flag,
        p_party_id,
        p_party_site_id
    FROM po_vendors pv,
	 ap_supplier_sites pvs
    WHERE pvs.vendor_site_id = p_vendor_site_id  --l_default_pay_site_id modified for bug#9267199
       and    pv.vendor_id = pvs.vendor_id;

Exception
    WHEN OTHERS THEN
	If (SQLCODE <> -20001) Then
	    fnd_message.set_name('SQLAP','AP_DEBUG');
	    fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE',curr_calling_sequence);
	    fnd_message.set_token('PARAMETERS',
		' vendor_site_id = '||to_char(p_vendor_site_id));
	    fnd_message.set_token('DEBUG_INFO',debug_info);
	End if;
	app_exception.raise_exception;

End Get_Vendor_info;

/*--------------------------------------------------------------------------
CREATE_INVOICE_BATCH : Creates an invoice batch . The batch_name is
derived from concatinating the receipt number with a database sequence
---------------------------------------------------------------------------*/
Procedure  Create_Invoice_batch(
		p_receipt_num			IN	VARCHAR2,
		p_inv_curr			IN	VARCHAR2,
		p_inv_payment_curr		IN	VARCHAR2,
		p_rts_txn_date			IN 	DATE,
		p_user_id			IN	NUMBER,
		p_login_id			IN	NUMBER,
		p_batch_id			IN OUT NOCOPY  NUMBER,
		p_calling_sequence		IN	VARCHAR2) IS

debug_info		VARCHAR2(2000);
curr_calling_sequence	VARCHAR2(2000);
l_invoice_exists	VARCHAR2(1) := 'N'; --Bug fix:1858452

Begin
    curr_calling_sequence := p_calling_sequence ||' <- Create_Invoice_batch';

    debug_info := 'Insert into ap_batches';

    SELECT ap_batches_s.nextval INTO p_batch_id FROM dual;

    --Bug fix:1858452
    --Note: When matched to a PO , po_distribution_id is not populated
    --in rcv_transactions, hence need to join using po_header_id...

    /* For bug 2902340
    Commented the following and added the same before calling all invoice
     creation procedures.
    BEGIN

      SELECT 'Y'
      INTO l_invoice_exists
      FROM ap_invoice_distributions aid,
         rcv_shipment_headers rsh,
         rcv_transactions rct,
	 po_distributions pod
      WHERE aid.po_distribution_id = pod.po_distribution_id
      AND pod.line_location_id = rct.po_line_location_id
      AND rsh.shipment_header_id = rct.shipment_header_id
      AND rsh.receipt_num = p_receipt_num
      AND rownum = 1;

    EXCEPTION WHEN OTHERS THEN

      l_invoice_exists := 'N';

    END;


    IF(l_invoice_exists = 'Y') THEN */

       INSERT INTO ap_batches_all (
		batch_id,
		batch_name,
		batch_date,
		invoice_currency_code,
		payment_currency_code,
		invoice_type_lookup_code,
		last_updated_by,
		last_update_date,
		created_by,
		creation_date,
		last_update_login)
       VALUES (
		p_batch_id,
		p_receipt_num||'-'||ap_batches_s1.nextval,
		trunc(p_rts_txn_date),   --Bug 3492081
		p_inv_curr,
		p_inv_payment_curr,
		'DEBIT',
		p_user_id,
		sysdate,
		p_user_id,
		sysdate,
		p_login_id);

   --   END IF;

Exception
    WHEN OTHERS THEN
	If (SQLCODE <> -20001) Then
	    fnd_message.set_name('SQLAP','AP_DEBUG');
	    fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE',curr_calling_sequence);
	    fnd_message.set_token('PARAMETERS',
		' receipt_num = '||p_receipt_num
	       ||'p_inv_curr = '||p_inv_curr
	       ||'p_inv_payment_curr = '||p_inv_payment_curr);
	    fnd_message.set_token('DEBUG_INFO',debug_info);
	End if;
	app_exception.raise_exception;
End Create_Invoice_Batch;


Procedure Create_Invoice_Header (
		p_vendor_site_id		IN NUMBER,
		p_vendor_id			IN	NUMBER,
		p_receipt_num			IN	VARCHAR2,
		p_receipt_uom			IN	VARCHAR2,
		p_invoice_curr			IN 	VARCHAR2,
		p_inv_pay_curr			IN 	VARCHAR2,
		p_base_curr			IN	VARCHAR2,
		p_gl_date_from_rect_flag	IN 	VARCHAR2,
		p_set_of_books_id		IN 	NUMBER,
		p_quantity			IN 	NUMBER,
		p_quantity_uom			IN	VARCHAR2,
		p_price				IN	NUMBER,
		p_quantity_billed		IN	NUMBER,
		p_batch_id			IN 	NUMBER,
		p_payment_method		IN 	VARCHAR2,
		p_pay_group			IN 	VARCHAR2,
		p_accts_pay_ccid		IN	NUMBER,
		p_excl_pay_flag			IN 	VARCHAR2,
		p_transaction_date		IN 	DATE,
		p_rts_txn_date			IN 	DATE,
		p_rcv_rate			IN 	NUMBER,
		p_rcv_rate_date			IN 	DATE,
		p_rcv_rate_type			IN 	VARCHAR2,
		p_terms_date_basis		IN	VARCHAR2,
		p_terms_id			IN 	NUMBER,
		p_awt_group_id			IN	NUMBER,
		p_user_id			IN	NUMBER,
		p_login_id			IN	NUMBER,
		p_invoice_id			IN OUT NOCOPY	NUMBER,
		p_amount			IN OUT NOCOPY  NUMBER,
		p_terms_date			IN OUT NOCOPY	DATE,
		p_pay_curr_invoice_amount	IN OUT NOCOPY	NUMBER,
		p_pay_cross_rate		IN OUT NOCOPY	NUMBER,
                p_auto_tax_calc_flag            IN      VARCHAR2, -- Bug fix: 1971188
		p_calling_sequence		IN	VARCHAR2,
                p_PAYMENT_REASON_CODE           IN      VARCHAR2,
                p_BANK_CHARGE_BEARER            IN      VARCHAR2,
                p_DELIVERY_CHANNEL_CODE         IN      VARCHAR2,
                p_SETTLEMENT_PRIORITY           IN      VARCHAR2,
                p_external_bank_account_id      IN      NUMBER,
                p_le_id                         IN      NUMBER,
                p_party_id                      IN      NUMBER,
                p_party_site_id                 IN      NUMBER,
                p_payment_reason_comments       IN      VARCHAR2,  --4874927
                 /* bug 5227816 */
                p_org_id                        IN      NUMBER,
                p_remit_to_supplier_name        IN      VARCHAR2,  --Start 7758980
                p_remit_to_supplier_id          IN      NUMBER  ,
                p_remit_to_supplier_site        IN      VARCHAR2,
                p_remit_to_supplier_site_id     IN      NUMBER  ,
                p_relationship_id               IN      NUMBER     --End 7758980
                ) IS
   l_gl_period			VARCHAR2(15);
   l_gl_date			DATE;
   l_inv_gl_date		DATE;
   l_invoice_num		ap_invoices.invoice_num%TYPE;
   l_terms_date			DATE;
   l_inv_desc			ap_invoices.description%TYPE;
   l_seq_num_profile		VARCHAR2(25);
   l_db_seq_name		fnd_document_sequences.db_sequence_name%TYPE;
   l_db_seq_id			fnd_document_sequences.doc_sequence_id%TYPE;
   l_doc_seq_value		NUMBER;
   l_invoice_amount		ap_invoices.invoice_amount%TYPE;
   l_pay_cross_rate		ap_invoices.payment_cross_rate%TYPE;
   l_pay_curr_invoice_amount	ap_invoices.pay_curr_invoice_amount%TYPE;
   l_pay_cross_rate_type	ap_invoices.payment_cross_rate_type%TYPE;
   l_pay_cross_rate_date	DATE;
   l_valid_pay_site		VARCHAR2(25);
   l_inv_base_amt		ap_invoices.base_amount%TYPE;
   l_invoice_id			ap_invoices.invoice_id%TYPE;
   l_alter_pay_site_id  NUMBER;
   --Modified for bug#9267199
   l_vendor_site_id		ap_supplier_Sites.vendor_site_id%type := p_vendor_site_id;
   l_rts_txn_le_date            DATE;   --Bug 3492081
   curr_calling_sequence	VARCHAR2(2000);
   debug_info			VARCHAR2(2000);

   l_inv_le_date                DATE;
   l_sys_le_date                DATE;

   l_org_id                     ap_invoices.org_id%TYPE;
   l_api_name CONSTANT VARCHAR2(200) := 'Create_Invoice_Header';



Begin

    curr_calling_sequence := p_calling_sequence || '<- Create_Invoice_Header';

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
        curr_calling_sequence);
    END IF;

  --Commented for bug#9267199 and introduced in Create_DM procedure
  --Start of 9267199

  /*    debug_info := 'Check if there is an alternate_pay_site';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    SELECT default_pay_site_id
    INTO   l_alter_pay_site_id
    FROM   po_vendor_sites
    WHERE  vendor_site_id = p_vendor_site_id;

    if ( l_alter_pay_site_id is not NULL ) then

    	Begin
		select 'y'
                into l_valid_pay_site
		from po_vendor_sites
		where vendor_site_id = l_alter_pay_site_id
		  and pay_site_flag = 'Y'
		  and nvl(inactive_date, sysdate +1) > sysdate;
    	Exception
		WHEN NO_DATA_FOUND Then
			l_valid_pay_site := 'n';
		END;
   	end if;

	if ( l_alter_pay_site_id is not NULL and l_valid_pay_site = 'y') then
		l_vendor_site_id := l_alter_pay_site_id;
	else
    	-- Step a2 :
    	------------
		debug_info := 'no valid alternate paysite, check if valid pay site';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    	   Begin

		SELECT 'y'
		INTO l_valid_pay_site
		FROM po_vendor_sites
		WHERE vendor_site_id = p_vendor_site_id
	  	  AND pay_site_flag = 'Y'
	  	  AND nvl(inactive_date, sysdate +1) > sysdate;
    	   Exception
		WHEN NO_DATA_FOUND Then
		-- It is not a valid pay site , a user freindly error message
		-- is set on the stack.
			fnd_message.set_name('SQLAP','AP_NOT_VALID_PAY_SITE');
			app_exception.raise_exception;
    	   End;

	   if ( l_valid_pay_site = 'y') then
			l_vendor_site_id := p_vendor_site_id;
	   end if;

	end if; */

  --End of 9267199

    -- Step b :
    ------------
    debug_info := 'Check if quantity is negative';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    If (p_quantity > 0) Then
	fnd_message.set_name('SQLAP','AP_QUANTITY_POSITIVE');
	app_exception.raise_exception;
    End if;

    -- step c :
    ------------
    debug_info := 'check if quantity_uom is same as receipt uom';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    If (p_receipt_uom <> p_quantity_uom) then
	fnd_message.set_name('SQLAP','AP_QUANTITY_UOM_INCORRECT');
	app_exception.raise_exception;
    End if;

    -- Step d :
    -------------
    debug_info := 'check if quantity billed will be negative';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;

    If (p_quantity_billed + p_quantity) < 0 Then
	fnd_message.set_name ('SQLAP','AP_QUANTITY_BILLED_NEGATIVE');
	app_exception.raise_exception;
    End if;

    -- Step e :
    --------------
    debug_info := 'Determine Invoice number';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;

    -- Bug 1330397
    -- Added a hyphen for the invoice number between receipt_num and the sequence

    SELECT p_receipt_num||'-'||AP_INVOICES_S1.nextval
    INTO l_invoice_num
    FROM dual;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        'Invoice Number := '||l_invoice_num);
    END IF;


    -- Step f :
    --------------
    /* Bug 5227816. Commented out the following line */
    --Bug 3492081 changed step to use l_rts_txn_le_date
    --l_org_id :=  nvl(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99);

    --
    -- Bug 5233473: As discussed with Jayanta, we will not pass the truncated
    -- date to the LE Timezone conversion API. We will pass the date with the
    -- time component to the LE API for invoice date case and the system date
    -- case.
    --

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        'Operating Unit := '||to_char(p_org_id));
    END IF;


    --Call conversion api, setting l_ rts_txn_le_date
    l_rts_txn_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => p_rts_txn_date
                         ,p_ou_id         => p_org_id);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        'RTS GL Date := '||to_char(l_rts_txn_le_date,'DD-MON-RR HH:MI:SS'));
    END IF;

    --Bug 3716946
    --Call conversion api, setting l_inv_le_date
    l_inv_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => p_rts_txn_date
                         ,p_ou_id         => p_org_id);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        'Invoice LE GL Date := '||to_char(l_inv_le_date,'DD-MON-RR HH:MI:SS'));
    END IF;


    --Call conversion api, setting l_inv_le_date
    l_sys_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => sysdate
                         ,p_ou_id         => p_org_id);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        'System LE GL Date := '||to_char(l_sys_le_date,'DD-MON-RR HH:MI:SS'));
    END IF;


    /* The gl_date id determined from the flag gl_date_from_receipt_flag
       If the flag = 'I' -- take Invoice_date
                   = 'S' -- take System date
                   = 'N' -- take nvl(receipt_date, invoice_date)
                   = 'Y' -- take nvl(receipt_date, sysdate)
       Note here that the Invoice date is no longer the same as the receipt_date,
       i.e. the RETURN tranasaction_date , so case I and N are no longer the same */

    debug_info := 'Determine invoice gl_date ';

    If (p_gl_date_from_rect_flag = 'I') Then
        l_inv_gl_date := l_inv_le_date;
    Elsif (p_gl_date_from_rect_flag = 'N') Then
        l_inv_gl_date := nvl(l_rts_txn_le_date, l_inv_le_date);
    Elsif (p_gl_date_from_rect_flag = 'S') Then
        l_inv_gl_date := l_sys_le_date;   --bug2213220
    Elsif (p_gl_date_from_rect_flag = 'Y') then
        l_inv_gl_date := nvl(l_rts_txn_le_date, l_sys_le_date);  --Bug2213220
    End if;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        'Invoice GL Date := '||to_char(l_inv_gl_date,'DD-MON-RR HH:MI:SS'));
    END IF;


    debug_info := 'Check if the date falls in a open or future period';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    l_gl_period := ap_utilities_pkg.get_current_gl_date(l_inv_gl_date);

    If (l_gl_period is null) then
	ap_utilities_pkg.get_open_gl_date(
				l_inv_gl_date,
				l_gl_period,
				l_gl_date);
	l_inv_gl_date := l_gl_date;
        If (l_inv_gl_date is null) Then
	    fnd_message.set_name('SQLAP','AP_NO_OPEN_PERIOD');
	    app_exception.raise_exception;
	End if;
    End if;

    -- Step g :
    --------------
    debug_info := 'Determine terms_date';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    --Bug 3492081 added trunc to date variables.

    If (p_terms_date_basis = 'Current') Then
	l_terms_date := trunc(sysdate);
    Elsif (p_terms_date_basis = 'Goods Received') Then
	l_terms_date := trunc(p_rts_txn_date); -- coz good_received_date is rts_date
    Elsif (p_terms_date_basis = 'Invoice Received') Then
	l_terms_date := trunc(sysdate); -- coz invoice_received_date = sysdate
    -- Bug 1413331
    -- Added condition to check p_terms_date_basis = 'Invoice'
    Elsif (p_terms_date_basis = 'Invoice') Then
        l_terms_date := trunc(p_rts_txn_date); -- because invoice date is rts_date
    End if;

    -- Step h :
    ---------------
    debug_info := 'Set Invoice description';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    fnd_message.set_name('SQLAP','AP_AUTO_DM_DESCRIPTION');
    l_inv_desc := fnd_message.get;

    -- Step i :
    ---------------
    debug_info := 'Assigning document sequence ';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    -- check if sequential numbering is on
    fnd_profile.get('UNIQUE:SEQ_NUMBERS',l_seq_num_profile);

    If (l_seq_num_profile IN ('P','A')) Then
        -- check if a sequence is assigned to DBM INV category
	debug_info := 'checking sequence for DBM INV';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


	Begin
       --Bug 3492081
            SELECT SEQ.db_sequence_name,
	           SEQ.doc_sequence_id
            INTO   l_db_seq_name,
	           l_db_seq_id
            FROM fnd_document_sequences SEQ,
	         fnd_doc_sequence_assignments SA
            WHERE SEQ.doc_sequence_id = SA.doc_sequence_id
             AND  SA.application_id = 200
             AND  SA.category_code = 'DBM INV'
           --AND  SA.method_code = 'A' --commented for bug#8593333
	     AND  nvl(SA.method_code,'A') = 'A' --added for bug#8593333
             AND  SA.set_of_books_id = p_set_of_books_id
             AND  trunc(p_rts_txn_date) between
			SA.start_date and nvl(SA.end_date, trunc(p_rts_txn_date));
        Exception
	     WHEN NO_DATA_FOUND Then
		l_db_seq_name := null;
		l_db_seq_id := null;
        End;

	If (l_db_seq_id IS NOT NULL ) Then   --Bug 5947765
	    -- get sequence value
	    debug_info := 'Obtain next sequence value';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              debug_info);
            END IF;

            Begin
           --Bug 3492081
	        l_doc_seq_value := fnd_seqnum.get_next_sequence (
					200,
					'DBM INV',
					p_set_of_books_id,
	 				'A',
					trunc(p_rts_txn_date),
					l_db_seq_name,
					l_db_seq_id);
	    Exception
		WHEN OTHERS THEN
		    l_doc_seq_value := null;
	    End;
	Else
	   l_doc_seq_value := null;
        End if;

	If (l_seq_num_profile = 'A' and l_doc_seq_value IS null) then
	    fnd_message.set_name('SQLAP','AP_CANNOT_ASSIGN_DOC_SEQ');
	    app_exception.raise_exception;
 	End if;

    End if;

    -- Step j :
    --------------
    debug_info := 'Calculate invoice_amount';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    l_invoice_amount := ap_utilities_pkg.ap_round_currency ((p_quantity * p_price),
					p_invoice_curr);

    l_inv_base_amt := ap_utilities_pkg.ap_round_currency(
				nvl((l_invoice_amount * p_rcv_rate),0),
					p_base_curr);

    -- Step k :
    --------------
    debug_info := 'Assigning cross currency payment values';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


     -- Bug 3492081

    -- invoice curr and pay curr will be different only if they are euro currencies
    If (p_invoice_curr <> p_inv_pay_curr) Then
	l_pay_cross_rate := gl_currency_api.get_rate(
					p_invoice_curr,
					p_inv_pay_curr,
					trunc(p_rts_txn_date),
					'EMU FIXED');
 	l_pay_curr_invoice_amount := gl_currency_api.convert_amount(
					p_invoice_curr,
					p_inv_pay_curr,
					trunc(p_rts_txn_date),
					'EMU FIXED',
					l_invoice_amount);
	l_pay_cross_rate_type := 'EMU FIXED';

        --  Bug fixed 1998904
        --  moving population of l_pay_cross_rate_date out of the condition
        --  populating allways
	--  l_pay_cross_rate_date :=p_rts_txn_date;

    End if;

    l_pay_cross_rate_date := trunc(p_rts_txn_date);
    -- Step l :
    -------------
    debug_info := 'Get invoice_id';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;


    SELECT ap_invoices_s.nextval INTO l_invoice_id FROM dual;

    debug_info := 'Inserting row in ap_invoices';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;

    INSERT INTO ap_invoices_all (
	org_id,
	invoice_id,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	vendor_id,
	invoice_num,
	set_of_books_id,
	invoice_currency_code,
	payment_currency_code,
	payment_cross_rate,
	invoice_amount,
	vendor_site_id,
	invoice_date,
	source,
	invoice_type_lookup_code,
	description,
	batch_id,
	amount_applicable_to_discount,
	terms_id,
	terms_date,
	payment_method_code,
	pay_group_lookup_code,
	accts_pay_code_combination_id,
	payment_status_flag,
	base_amount,
	exclusive_payment_flag,
	goods_received_date,
	invoice_received_date,
	approved_amount,
	exchange_rate,
	exchange_rate_type,
	exchange_date,
	doc_sequence_id,
	doc_sequence_value,
	doc_category_code,
	payment_cross_rate_type,
	payment_cross_rate_date,
	pay_curr_invoice_amount,
	awt_flag,
	awt_group_id,
	gl_date,
        approval_ready_flag, -- Bug 2345472
        wfapproval_status,   -- Bug 2345472
        auto_tax_calc_flag,  -- Bug fix : 1971188.
        PAYMENT_REASON_CODE,
        BANK_CHARGE_BEARER,
        DELIVERY_CHANNEL_CODE,
        SETTLEMENT_PRIORITY,
        external_bank_account_id,
        legal_entity_id,
        party_id,
        party_site_id,
        payment_reason_comments, --4874927
        remit_to_supplier_name, --Start 7758980
        remit_to_supplier_id,
        remit_to_supplier_site,
        remit_to_supplier_site_id,
        relationship_id )       --End 7758980
   VALUES (
	p_org_id,
	l_invoice_id,
	sysdate,
	p_user_id,
	sysdate,
	p_user_id,
	p_login_id,
	p_vendor_id,
	l_invoice_num,
	p_set_of_books_id,
	p_invoice_curr,
	p_inv_pay_curr,
	nvl(l_pay_cross_rate,1),
	l_invoice_amount,
	l_vendor_site_id,
	trunc(p_rts_txn_date),  --Bug 3492081
	'RTS',
	'DEBIT',
	l_inv_desc,
	p_batch_id,
	l_invoice_amount,
	p_terms_id,
	l_terms_date,
	p_payment_method,
	p_pay_group,
	p_accts_pay_ccid,
	'N',
	l_inv_base_amt,
        --Bug 5583430. For a debit memo, the pay alone flag should be set to 'N'
        --and not being populated based on supplier site.
        --p_excl_pay_flag,
        'N',
	p_rts_txn_date,
	sysdate,
	0,
	p_rcv_rate,
	p_rcv_rate_type,
	p_rcv_rate_date,
	l_db_seq_id,
	l_doc_seq_value,
	'DBM INV',
	l_pay_cross_rate_type,
	l_pay_cross_rate_date,
	l_pay_curr_invoice_amount,
	'N',
	p_awt_group_id,
	l_inv_gl_date,
        'Y', --Bug 2345472
        'NOT REQUIRED', --Bug 2345472
        p_auto_tax_calc_flag,
        p_PAYMENT_REASON_CODE,
        p_BANK_CHARGE_BEARER,
        p_DELIVERY_CHANNEL_CODE,
        p_SETTLEMENT_PRIORITY,
        p_external_bank_account_id,
        p_le_id,
        p_party_id,
        p_party_site_id,
        p_payment_reason_comments, --4874927
        p_remit_to_supplier_name, --Start 7758980
        p_remit_to_supplier_id,
        p_remit_to_supplier_site,
        p_remit_to_supplier_site_id,
        p_relationship_id );      --End 7758980

    --Step m :
    ------------
    debug_info := 'Set all OUT parameters';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        debug_info);
    END IF;

    p_invoice_id := l_invoice_id;
    p_amount := l_invoice_amount;
    p_terms_date := l_terms_date;
    p_pay_curr_invoice_amount := l_pay_curr_invoice_amount;
    p_pay_cross_rate := l_pay_cross_rate;

Exception
   WHEN OTHERS THEN
	If (SQLCODE <> -20001) Then
	    fnd_message.set_name('SQLAP','AP_DEBUG');
	    fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE',curr_calling_sequence);
	    fnd_message.set_token('PARAMETERS',
		' p_vendor_site_id = '||to_char(p_vendor_site_id)
	      ||' p_vendor_id = '||to_char(p_vendor_id)
	      ||' p_invoice_curr = '||p_invoice_curr
	      ||' p_inv_pay_curr = '||p_inv_pay_curr
	      ||' p_base_curr = '||p_base_curr
	      ||' p_gl_date_from_rect_flag = '||p_gl_date_from_rect_flag
	      ||' p_set_of_books_id = '||to_char(p_set_of_books_id)
	      ||' p_quantity = '||to_char(p_quantity)
	      ||' p_price = '||to_char(p_price)
	      ||' p_quantity_billed = '||to_char(p_quantity_billed));
	    fnd_message.set_token('DEBUG_INFO',debug_info);
	End if;
	app_exception.raise_exception;
End Create_Invoice_Header;

/*--------------------------------------------------------------------------
CREATE_DM_TAX : Creates tax on debit memo. Procedure calls tax engine
                and if tax lines are created then updates invoice_amount
                appropriately.
---------------------------------------------------------------------------*/
FUNCTION create_dm_tax (p_invoice_id IN NUMBER,
			p_invoice_amount IN NUMBER,
			p_error_code	 OUT NOCOPY VARCHAR2,
                        p_calling_sequence IN VARCHAR2) RETURN BOOLEAN IS


l_lines_total          ap_invoice_lines_all.amount%type;
l_lines_total_base_amount ap_invoice_lines_all.base_amount%type;
l_calling_sequence     varchar2(2000);
l_success	       boolean;

BEGIN

   l_calling_sequence := p_calling_sequence ||' <- Create_dm_Tax';

   --Bug:4537655
   l_success := ap_etax_pkg.calling_etax(
			p_invoice_id => p_invoice_id,
			p_calling_mode => 'CALCULATE',
                        p_all_error_messages => 'N',
                        p_error_code =>  p_error_code,
                        p_calling_sequence => l_calling_sequence);


   IF (l_success) THEN

     SELECT nvl(sum(amount),0),nvl(sum(base_amount),0)
     INTO   l_lines_total,l_lines_total_base_amount
     FROM   ap_invoice_lines_all
     WHERE  invoice_id = p_invoice_id;

     IF (l_lines_total <> p_invoice_amount and nvl(l_lines_total,0) <> 0) THEN

        UPDATE ap_invoices
        SET    invoice_amount = l_lines_total,
               base_amount = l_lines_total_base_amount
        WHERE  invoice_id = p_invoice_id;

     END IF;

   END IF;

   RETURN(l_success);
END create_dm_tax;

END AP_AUTO_DM_CREATION_PKG;


/
