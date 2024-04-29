--------------------------------------------------------
--  DDL for Package Body AR_REFUNDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_REFUNDS_PVT" AS
/* $Header: ARXVREFB.pls 120.3.12010000.11 2009/11/19 06:32:09 rvelidi ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

  g_source              VARCHAR2(30);
  PG_DEBUG 		VARCHAR2(1);

/*========================================================================
 | Local Functions and Procedures
 *=======================================================================*/

PROCEDURE debug (p_string VARCHAR2) IS

BEGIN

    IF (g_source = 'AUTOINVOICE') THEN
      fnd_file.put_line
      ( which => fnd_file.log,
        buff  => p_string );
    ELSE
      arp_standard.debug(p_string);
    END IF;

END debug;

/*========================================================================
 | PUBLIC PROCEDURES AND FUNCTIONS
 *=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE Create_Refund
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure creates a refund payment in Oracle Payments
 |	via AP interface tables and APIs
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date        Author   Description of Changes
 | 06-DEC-2005 JBECKETT Created
 |
 *=======================================================================*/
PROCEDURE create_refund(
                 p_receivable_application_id    IN  ar_receivable_applications.receivable_application_id%TYPE
		,p_amount			IN  NUMBER
		,p_currency_code		IN  fnd_currencies.currency_code%TYPE
		,p_exchange_rate		IN  NUMBER
		,p_exchange_rate_type		IN  ar_cash_receipts.exchange_rate_type%TYPE
		,p_exchange_date		IN  DATE
		,p_description			IN  VARCHAR2
          	,p_pay_group_lookup_code	IN  FND_LOOKUPS.lookup_code%TYPE
          	,p_pay_alone_flag		IN  VARCHAR2
		,p_org_id			IN  ar_cash_receipts.org_id%TYPE
	  	,p_legal_entity_id        	IN  ar_cash_receipts.legal_entity_id%TYPE
          	,p_payment_method_code		IN  ap_invoices.payment_method_code%TYPE
          	,p_payment_reason_code		IN  ap_invoices.payment_reason_code%TYPE
          	,p_payment_reason_comments	IN  ap_invoices.payment_reason_comments%TYPE
          	,p_delivery_channel_code	IN  ap_invoices.delivery_channel_code%TYPE
          	,p_remittance_message1		IN  ap_invoices.remittance_message1%TYPE
          	,p_remittance_message2		IN  ap_invoices.remittance_message2%TYPE
          	,p_remittance_message3		IN  ap_invoices.remittance_message3%TYPE
          	,p_party_id			IN  hz_parties.party_id%TYPE
          	,p_party_site_id		IN  hz_party_sites.party_site_id%TYPE
		,p_bank_account_id		IN  ar_cash_receipts.customer_bank_account_id%TYPE
		,p_called_from			IN  VARCHAR2
		,x_invoice_id			OUT NOCOPY ap_invoices.invoice_id%TYPE
		,x_return_status		OUT NOCOPY VARCHAR2
		,x_msg_count			OUT NOCOPY NUMBER
		,x_msg_data			OUT NOCOPY VARCHAR2
		,p_invoice_date			IN  ap_invoices.invoice_date%TYPE DEFAULT NULL -- Bug 7242125
		------------------------------- Bug7525965 Changes Start Here ------------------------------
		,p_payment_priority		IN  ap_invoices_interface.PAYMENT_PRIORITY%TYPE DEFAULT NULL
		,p_terms_id			IN  ap_invoices_interface.TERMS_ID%TYPE DEFAULT NULL
		------------------------------- Bug7525965 Changes End Here --------------------------------
		,p_gl_date			IN  DATE DEFAULT NULL)  --Bug8283120
IS
  l_External_Payee_Tab IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Tab_Type;
  l_Ext_Payee_ID_Tab IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_ID_Tab_Type;
  l_Ext_Payee_Create_Tab IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Tab_Type;
  l_payee_return_status VARCHAR2(1);
  l_rowid		VARCHAR2(100);
  l_line_rowid		VARCHAR2(100);
  l_invoice_interface_id		NUMBER;
  l_invoice_line_interface_id		NUMBER;
  l_rejection_list      AP_IMPORT_INVOICES_PKG.rejection_tab_type;
  l_app_rec  ar_receivable_applications%ROWTYPE;
  l_activity_ccid      gl_code_combinations.code_combination_id%TYPE;
  l_goods_received_date DATE DEFAULT NULL ;
  l_invoice_received_date DATE DEFAULT NULL ;
  l_terms_date_basis   VARCHAR2(100);

BEGIN

  debug('ar_refund_pvt.create_refund()+');
  g_source := p_called_from;

  -- bug90321132

 select
 ra.code_combination_id
 INTO   l_activity_ccid
 from ar_receivable_applications ra
 where ra.status='ACTIVITY'
 and ra.display = 'Y'
 AND ra.receivable_application_id = p_receivable_application_id;

  /* Create a payee record if one does not exist..*/
  l_External_Payee_Tab(0).Payee_Party_Id := p_party_id;
  l_External_Payee_Tab(0).Payee_Party_Site_Id := p_party_site_id;
  l_External_Payee_Tab(0).Payer_Org_Id := p_org_id;
  l_External_Payee_Tab(0).Payer_Org_Type := 'OPERATING_UNIT';
  l_External_Payee_Tab(0).Payment_Function := 'AR_CUSTOMER_REFUNDS';
  l_External_Payee_Tab(0).Exclusive_Pay_Flag := p_pay_alone_flag;
  l_External_Payee_Tab(0).Default_pmt_method := p_payment_method_code;
  l_External_Payee_Tab(0).Delivery_Channel := p_delivery_channel_code;

  /* Bug 8303937 */
  IF p_party_site_id IS NULL  THEN
	l_External_Payee_Tab(0).Payer_Org_Id := NULL;
	l_External_Payee_Tab(0).Payer_Org_Type := NULL;
  END IF;

  debug('Calling IBY_DISBURSEMENT_SETUP_PUB.create_external_payee..');
  IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee (
             p_api_version           => 1.0,
             p_init_msg_list         => FND_API.G_FALSE,
             p_ext_payee_tab         => l_External_Payee_Tab,
             x_return_status         => l_payee_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             x_ext_payee_id_tab      => l_Ext_Payee_ID_Tab,
             x_ext_payee_status_tab  => l_Ext_Payee_Create_Tab);
  IF (l_payee_return_status <> FND_API.g_ret_sts_success  OR
      l_ext_payee_create_tab(0).payee_creation_status = 'E') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      debug('Error found creating an external payee');
      debug('Payee creation status : '||l_ext_payee_create_tab(0).payee_creation_status);
      debug('Payee creation error : '||l_ext_payee_create_tab(0).payee_creation_msg);
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* First populate AP interface table..*/
  debug('Calling AP_INVOICES_INTERFACE_PKG.INSERT_ROW..');

  SELECT ap_invoices_interface_s.NEXTVAL
  INTO   l_invoice_interface_id
  FROM   DUAL;

  SELECT ap_invoice_lines_interface_s.NEXTVAL
  INTO   l_invoice_line_interface_id
  FROM   DUAL;

  -- bug 8764872

 SELECT  terms_date_basis
  INTO l_terms_date_basis
  FROM ap_product_setup;

 if l_terms_date_basis = 'Goods Received'

then
l_goods_received_date := p_invoice_date;

end if;

if l_terms_date_basis = 'Invoice Received'

then
l_invoice_received_date := p_invoice_date;

end if;

  AP_INVOICES_INTERFACE_PKG.INSERT_ROW (
          X_ROWID                        => l_rowid ,
          X_INVOICE_ID                   => l_invoice_interface_id,
          X_INVOICE_NUM                  => l_invoice_interface_id,
          X_INVOICE_TYPE_LOOKUP_CODE     => 'PAYMENT REQUEST',
          X_INVOICE_DATE                 => p_invoice_date,
          X_PO_NUMBER                    => NULL,
          X_VENDOR_ID                    => NULL,
          X_VENDOR_SITE_ID               => NULL,
          X_INVOICE_AMOUNT               => p_amount,
          X_INVOICE_CURRENCY_CODE        => p_currency_code,
          X_PAYMENT_CURRENCY_CODE        => p_currency_code,
          X_PAYMENT_CROSS_RATE           => NULL,
          X_PAYMENT_CROSS_RATE_TYPE      => NULL,
          X_PAYMENT_CROSS_RATE_DATE      => NULL,
          X_EXCHANGE_RATE                => p_exchange_rate,
          X_EXCHANGE_RATE_TYPE           => p_exchange_rate_type,
          X_EXCHANGE_DATE                => p_exchange_date,
          X_TERMS_ID                     => p_terms_id,	   --Bug7525965
          X_DESCRIPTION                  => p_description, --rct comments
          X_AWT_GROUP_ID                 => NULL,
          X_AMT_APPLICABLE_TO_DISCOUNT   => NULL,
          X_ATTRIBUTE_CATEGORY           => NULL,
          X_ATTRIBUTE1                   => NULL,
          X_ATTRIBUTE2                   => NULL,
          X_ATTRIBUTE3                   => NULL,
          X_ATTRIBUTE4                   => NULL,
          X_ATTRIBUTE5                   => NULL,
          X_ATTRIBUTE6                   => NULL,
          X_ATTRIBUTE7                   => NULL,
          X_ATTRIBUTE8                   => NULL,
          X_ATTRIBUTE9                   => NULL,
          X_ATTRIBUTE10                  => NULL,
          X_ATTRIBUTE11                  => NULL,
          X_ATTRIBUTE12                  => NULL,
          X_ATTRIBUTE13                  => NULL,
          X_ATTRIBUTE14                  => NULL,
          X_ATTRIBUTE15                  => NULL,
          X_GLOBAL_ATTRIBUTE_CATEGORY    => NULL,
          X_GLOBAL_ATTRIBUTE1            => NULL,
          X_GLOBAL_ATTRIBUTE2            => NULL,
          X_GLOBAL_ATTRIBUTE3            => NULL,
          X_GLOBAL_ATTRIBUTE4            => NULL,
          X_GLOBAL_ATTRIBUTE5            => NULL,
          X_GLOBAL_ATTRIBUTE6            => NULL,
          X_GLOBAL_ATTRIBUTE7            => NULL,
          X_GLOBAL_ATTRIBUTE8            => NULL,
          X_GLOBAL_ATTRIBUTE9            => NULL,
          X_GLOBAL_ATTRIBUTE10           => NULL,
          X_GLOBAL_ATTRIBUTE11           => NULL,
          X_GLOBAL_ATTRIBUTE12           => NULL,
          X_GLOBAL_ATTRIBUTE13           => NULL,
          X_GLOBAL_ATTRIBUTE14           => NULL,
          X_GLOBAL_ATTRIBUTE15           => NULL,
          X_GLOBAL_ATTRIBUTE16           => NULL,
          X_GLOBAL_ATTRIBUTE17           => NULL,
          X_GLOBAL_ATTRIBUTE18           => NULL,
          X_GLOBAL_ATTRIBUTE19           => NULL,
          X_GLOBAL_ATTRIBUTE20           => NULL,
          X_STATUS                       => NULL,
          X_SOURCE                       => 'Receivables',
          X_GROUP_ID                     => NULL,
          X_WORKFLOW_FLAG                => NULL,
          X_DOC_CATEGORY_CODE            => NULL,
          X_VOUCHER_NUM                  => NULL,
          X_PAY_GROUP_LOOKUP_CODE        => p_pay_group_lookup_code,
          X_GOODS_RECEIVED_DATE          => l_goods_received_date,  -- bug 8764872
          X_INVOICE_RECEIVED_DATE        => l_invoice_received_date,
          X_GL_DATE                      => p_gl_date,	--Bug8283120
          X_ACCTS_PAY_CCID               => NULL,
          X_EXCLUSIVE_PAYMENT_FLAG       => p_pay_alone_flag,
          X_INVOICE_INCLUDES_PREPAY_FLAG => NULL,
          X_PREPAY_NUM                   => NULL,
          X_PREPAY_APPLY_AMOUNT          => NULL,
          X_PREPAY_GL_DATE               => NULL,
          X_CREATION_DATE                => SYSDATE,
          X_CREATED_BY                   => fnd_global.user_id,
          X_LAST_UPDATE_DATE             => SYSDATE,
          X_LAST_UPDATED_BY              => fnd_global.user_id,
          X_LAST_UPDATE_LOGIN            => fnd_global.login_id,
          X_ORG_ID                       => p_org_id,
          X_TERMS_DATE                   => NULL,
          X_REQUESTER_ID                 => NULL,
	  X_CONTROL_AMOUNT  		 => NULL,
	  X_LEGAL_ENTITY_ID		 => p_legal_entity_id,
          x_PAYMENT_METHOD_CODE          => p_payment_method_code ,
          x_PAYMENT_REASON_CODE          => p_payment_reason_code ,
          X_PAYMENT_REASON_COMMENTS      => p_payment_reason_comments,
          x_DELIVERY_CHANNEL_CODE        => p_delivery_channel_code ,
          x_remittance_message1          => p_remittance_message1 ,
          x_remittance_message2          => p_remittance_message2,
          x_remittance_message3          => p_remittance_message3,
          X_APPLICATION_ID               => 222,
          X_PRODUCT_TABLE                => 'AR_RECEIVABLE_APPLICATIONS_ALL',
          X_REFERENCE_KEY1               => p_receivable_application_id,
          X_REFERENCE_KEY2               => 'AR_RECEIVABLE_APPLICATIONS_ALL',
          X_REFERENCE_KEY3               => NULL,
          X_REFERENCE_KEY4               => NULL,
          X_REFERENCE_KEY5               => NULL,
          X_PARTY_ID                     => p_party_id,
          X_PARTY_SITE_ID                => p_party_site_id,
          X_PAY_PROC_TRXN_TYPE_CODE      => NULL,
          X_PAYMENT_FUNCTION             => 'AR_CUSTOMER_REFUNDS',
          X_PAYMENT_PRIORITY             => p_payment_priority,  -- Bug7525965
          x_external_bank_account_id     => p_bank_account_id
  );

  /* Next populate AP lines interface table..*/
  debug('Calling AP_INVOICES_LINES_INTERFACE_PKG.INSERT_ROW..');

  AP_INVOICE_LINES_INTERFACE_PKG.INSERT_ROW(
          X_ROWID                        => l_line_rowid,
          X_INVOICE_ID                   => l_invoice_interface_id,
          X_INVOICE_LINE_ID              => l_invoice_line_interface_id,
          X_LINE_NUMBER                  => 1,
          X_LINE_TYPE_LOOKUP_CODE        => 'ITEM',
          X_LINE_GROUP_NUMBER            => NULL,
          X_AMOUNT                       => p_amount,
          X_ACCOUNTING_DATE              => NULL,
          X_DESCRIPTION                  => p_description,
          X_PRORATE_ACROSS_FLAG          => NULL,
          X_TAX_CODE                     => NULL,
          X_TAX_CODE_ID                  => NULL,
          X_FINAL_MATCH_FLAG             => NULL,
          X_PO_HEADER_ID                 => NULL,
          X_PO_LINE_ID                   => NULL,
          X_PO_LINE_LOCATION_ID          => NULL,
          X_PO_DISTRIBUTION_ID           => NULL,
          X_UNIT_OF_MEAS_LOOKUP_CODE     => NULL,
          X_INVENTORY_ITEM_ID            => NULL,
          X_QUANTITY_INVOICED            => NULL,
          X_UNIT_PRICE                   => NULL,
          X_DISTRIBUTION_SET_ID          => NULL,
          X_DIST_CODE_CONCATENATED       => NULL,
          X_DIST_CODE_COMBINATION_ID     => l_activity_ccid,
          X_AWT_GROUP_ID                 => NULL,
          X_ATTRIBUTE_CATEGORY           => NULL,
          X_ATTRIBUTE1                   => NULL,
          X_ATTRIBUTE2                   => NULL,
          X_ATTRIBUTE3                   => NULL,
          X_ATTRIBUTE4                   => NULL,
          X_ATTRIBUTE5                   => NULL,
          X_ATTRIBUTE6                   => NULL,
          X_ATTRIBUTE7                   => NULL,
          X_ATTRIBUTE8                   => NULL,
          X_ATTRIBUTE9                   => NULL,
          X_ATTRIBUTE10                  => NULL,
          X_ATTRIBUTE11                  => NULL,
          X_ATTRIBUTE12                  => NULL,
          X_ATTRIBUTE13                  => NULL,
          X_ATTRIBUTE14                  => NULL,
          X_ATTRIBUTE15                  => NULL,
          X_GLOBAL_ATTRIBUTE_CATEGORY    => NULL,
          X_GLOBAL_ATTRIBUTE1            => NULL,
          X_GLOBAL_ATTRIBUTE2            => NULL,
          X_GLOBAL_ATTRIBUTE3            => NULL,
          X_GLOBAL_ATTRIBUTE4            => NULL,
          X_GLOBAL_ATTRIBUTE5            => NULL,
          X_GLOBAL_ATTRIBUTE6            => NULL,
          X_GLOBAL_ATTRIBUTE7            => NULL,
          X_GLOBAL_ATTRIBUTE8            => NULL,
          X_GLOBAL_ATTRIBUTE9            => NULL,
          X_GLOBAL_ATTRIBUTE10           => NULL,
          X_GLOBAL_ATTRIBUTE11           => NULL,
          X_GLOBAL_ATTRIBUTE12           => NULL,
          X_GLOBAL_ATTRIBUTE13           => NULL,
          X_GLOBAL_ATTRIBUTE14           => NULL,
          X_GLOBAL_ATTRIBUTE15           => NULL,
          X_GLOBAL_ATTRIBUTE16           => NULL,
          X_GLOBAL_ATTRIBUTE17           => NULL,
          X_GLOBAL_ATTRIBUTE18           => NULL,
          X_GLOBAL_ATTRIBUTE19           => NULL,
          X_GLOBAL_ATTRIBUTE20           => NULL,
          X_PO_RELEASE_ID                => NULL,
          X_BALANCING_SEGMENT            => NULL,
          X_COST_CENTER_SEGMENT          => NULL,
          X_ACCOUNT_SEGMENT              => NULL,
          X_PROJECT_ID                   => NULL,
          X_TASK_ID                      => NULL,
          X_EXPENDITURE_TYPE             => NULL,
          X_EXPENDITURE_ITEM_DATE        => NULL,
          X_EXPENDITURE_ORGANIZATION_ID  => NULL,
          X_PROJECT_ACCOUNTING_CONTEXT   => NULL,
          X_PA_ADDITION_FLAG             => NULL,
          X_PA_QUANTITY                  => NULL,
          X_STAT_AMOUNT                  => NULL,
          X_TYPE_1099                    => NULL,
          X_INCOME_TAX_REGION            => NULL,
          X_ASSETS_TRACKING_FLAG         => NULL,
          X_PRICE_CORRECTION_FLAG        => NULL,
          X_RECEIPT_NUMBER               => NULL,
          X_MATCH_OPTION                 => NULL,
          X_RCV_TRANSACTION_ID           => NULL,
          X_CREATION_DATE                => SYSDATE,
          X_CREATED_BY                   => FND_GLOBAL.USER_ID,
          X_LAST_UPDATE_DATE             => SYSDATE,
          X_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID,
          X_LAST_UPDATE_LOGIN            => FND_GLOBAL.LOGIN_ID,
          X_ORG_ID                       => p_org_id,
          X_Calling_Sequence             => g_pkg_name||'.create_refund'
  );

  /* Finally calling AP submit payment logic ..*/
  debug('Calling AP_IMPORT_INVOICES_PKG.SUBMIT_PAYMENT_REQUEST..');

  AP_IMPORT_INVOICES_PKG.SUBMIT_PAYMENT_REQUEST(
        p_api_version		=> 1.0,
 	p_invoice_interface_id  => l_invoice_interface_id,
	p_budget_control        => 'N',
	p_needs_invoice_approval=> 'Y',  -- 'N' for testing, 'Y' for production
	p_invoice_id            => x_invoice_id,
	x_return_status         => x_return_status,
	x_msg_count 		=> x_msg_count,
	x_msg_data		=> x_msg_data,
	x_rejection_list 	=> l_rejection_list,
        p_calling_sequence      => g_pkg_name||'.create_refund',
	p_commit		=> 'N');

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	x_msg_count	:= 0;
     FOR i in l_rejection_list.FIRST .. l_rejection_list.LAST LOOP
        debug(i||' Errors found interfacing data to AP ...');
	debug(l_rejection_list(i).reject_lookup_code);
	x_msg_count	:= x_msg_count + 1;
        FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
        FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,l_rejection_list(i).reject_lookup_code );
        FND_MSG_PUB.ADD;
     END LOOP;
     RETURN;
END IF;

  /* Need to update the newly created application with the
             refund invoice id.. */
  IF NVL(p_called_from,'ARXRWAPP') <> 'TEST' THEN
     arp_app_pkg.fetch_p(p_receivable_application_id,l_app_rec);
     l_app_rec.application_ref_id := x_invoice_id;
     l_app_rec.application_ref_num := x_invoice_id;
     arp_app_pkg.update_p(l_app_rec);
  END IF;

  debug('ar_refund_pvt.create_refund()-');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: AR_REFUNDS_PVT.Create_refund()'||sqlerrm);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: AR_REFUNDS_PVT.Create_refund()'||sqlerrm);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END create_refund;

/*========================================================================
 | PUBLIC PROCEDURE Cancel_Refund
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure cancels a refund payment in Oracle Payments
 |	via AP interface tables and APIs
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date        Author   Description of Changes
 | 06-DEC-2005 JBECKETT Created
 |
 *=======================================================================*/
PROCEDURE cancel_refund(
		 p_application_ref_id	IN  ar_receivable_applications.application_ref_id%TYPE
		,p_gl_date		IN  DATE
                ,x_return_status	OUT NOCOPY VARCHAR2
		,x_msg_count		OUT NOCOPY NUMBER
		,x_msg_data		OUT NOCOPY VARCHAR2)
IS
  l_message_name		fnd_new_messages.message_name%TYPE;
  l_refund_amount		NUMBER;
  l_acctd_refund_amount		NUMBER;
  l_temp_cancelled_amount	NUMBER;
  l_cancelled_by		NUMBER;
  l_cancelled_amount		NUMBER;
  l_cancelled_date		DATE;
  l_last_update_date		DATE;
  l_orig_ppay_amount		NUMBER;
  l_pay_curr_amount		NUMBER;
  l_token			VARCHAR2(100);

BEGIN

  debug('ar_refund_pvt.cancel_refund()+');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF NOT AP_CANCEL_PKG.Ap_Cancel_Single_Invoice(
                  P_invoice_id			=> p_application_ref_id
    		, P_last_updated_by		=> fnd_global.user_id
             	, P_last_update_login		=> fnd_global.login_id
             	, P_accounting_date		=> NULL
             	, P_message_name		=> l_message_name
             	, P_invoice_amount		=> l_refund_amount
              	, P_base_amount			=> l_acctd_refund_amount
             	, P_temp_cancelled_amount	=> l_temp_cancelled_amount
              	, P_cancelled_by		=> l_cancelled_by
               	, P_cancelled_amount		=> l_cancelled_amount
            	, P_cancelled_date		=> l_cancelled_date
             	, P_last_update_date		=> l_last_update_date
             	, P_original_prepayment_amount	=> l_orig_ppay_amount
            	, P_pay_curr_invoice_amount	=> l_pay_curr_amount
              	, P_Token			=> l_token
              	, P_calling_sequence		=> 'ar_refund_pvt.cancel_refund'
		) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_message_name IS NOT NULL THEN
         FND_MESSAGE.SET_NAME ('AP',l_message_name);
         FND_MSG_PUB.Add;
      END IF;
      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','CANCEL_REFUND : '||l_token);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data);

      debug('Error returned from ap_cancel_single_invoice: '||l_message_name||' '||l_token);
  END IF;

  debug('ar_refund_pvt.cancel_refund()-');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: AR_REFUNDS_PVT.Cancel_refund()'||sqlerrm);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: AR_REFUNDS_PVT.Cancel_refund()'||sqlerrm);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END cancel_refund;

/*========================================================================
 | INITIALIZATION SECTION
 |
 | DESCRIPTION
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date        Author   Description of Changes
 | 06-DEC-2005 JBECKETT Created
 |
 *=======================================================================*/
BEGIN

  pg_debug := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');


EXCEPTION
  WHEN NO_DATA_FOUND THEN
     arp_standard.debug('EXCEPTION: AR_REFUNDS_PVT.INITIALIZE()');
     RAISE;

  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: AR_REFUNDS_PVT.INITIALIZE()');
     RAISE;

END AR_REFUNDS_PVT;

/
