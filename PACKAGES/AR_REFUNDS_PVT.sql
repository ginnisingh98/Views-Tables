--------------------------------------------------------
--  DDL for Package AR_REFUNDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_REFUNDS_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXVREFS.pls 120.2.12010000.5 2009/02/26 06:50:24 npanchak ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
  G_PKG_NAME           CONSTANT VARCHAR2(30):= 'AR_REFUNDS_PVT';

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE Create_Refund
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure creates a refund payment in Oracle Payments
 |	via AP interface tables and APIs
 |
 |
 | PSEUDO CODE/LOGIC
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
		,p_gl_date			IN  DATE DEFAULT NULL);  --Bug8283120

/*========================================================================
 | PUBLIC PROCEDURE Cancel_Refund
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure cancels a refund payment in Oracle Payments
 |	via AP interface tables and APIs
 |
 |
 | PSEUDO CODE/LOGIC
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
		,x_msg_data		OUT NOCOPY VARCHAR2);

END AR_REFUNDS_PVT;

/
