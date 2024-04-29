--------------------------------------------------------
--  DDL for Package Body AR_REFUNDS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_REFUNDS_GRP" AS
/* $Header: ARXGREFB.pls 120.0.12010000.2 2010/02/17 07:03:12 npanchak ship $ */

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
 | PUBLIC PROCEDURE subscribeto_invoice_event
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure calls activity_unapplication for receipt or credit memo
 |      - for use by AP when a payment request is cancelled outside AR
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
 | 06-JAN-2006 JBECKETT Created
 |
 *=======================================================================*/
PROCEDURE subscribeto_invoice_event(
		 p_event_type			IN  VARCHAR2
		,p_invoice_id			IN  NUMBER
		,p_return_status		OUT NOCOPY VARCHAR2
		,p_msg_count			OUT NOCOPY NUMBER
		,p_msg_data			OUT NOCOPY VARCHAR2)
IS

  l_receivable_application_id	ar_receivable_applications.receivable_application_id%TYPE;
  l_cash_receipt_id		ar_cash_receipts.cash_receipt_id%TYPE;
  l_customer_trx_id		ra_customer_trx.customer_trx_id%TYPE;
  l_org_id			ar_cash_receipts.org_id%TYPE;

BEGIN

  debug('ar_refunds_grp.subscribeto_invoice_event()+');

  BEGIN
    SELECT ra.receivable_application_id,
	   ra.cash_receipt_id,
           ra.customer_trx_id,
           ra.org_id
    INTO   l_receivable_application_id,
	   l_cash_receipt_id,
	   l_customer_trx_id,
	   l_org_id
    FROM   ar_receivable_applications_all ra, ap_invoices_v i
    WHERE  ra.application_ref_id = p_invoice_id
    AND    i.invoice_id = p_invoice_id
    AND    TO_NUMBER(i.reference_key1) = ra.receivable_application_id
    AND    ra.application_ref_type = 'AP_REFUND_REQUEST'
    AND    ra.display = 'Y';
  EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.set_name('AR','AR_REF_MISSING_REFUND_APP');
		FND_MSG_PUB.Add;
           	p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => p_msg_count,
                            p_data    => p_msg_data);
		RETURN;
  END;
  IF l_cash_receipt_id IS NOT NULL THEN
	ar_receipt_api_pub.activity_unapplication    (
      		p_api_version                  =>  1.0,
      		p_init_msg_list                =>  FND_API.G_TRUE,
      		x_return_status                =>  p_return_status,
      		x_msg_count                    =>  p_msg_count,
      		x_msg_data                     =>  p_msg_data,
      		p_receivable_application_id    =>  l_receivable_application_id,
      		p_reversal_gl_date             =>  null,
      		p_called_from		       => 'AR_REFUNDS_GRP',
		p_org_id		       =>  l_org_id);
  ELSIF l_customer_trx_id IS NOT NULL THEN
	ar_cm_application_pub.activity_unapplication    (
      		p_api_version                  =>  1.0,
      		p_init_msg_list                =>  FND_API.G_TRUE,
      		x_return_status                =>  p_return_status,
      		x_msg_count                    =>  p_msg_count,
      		x_msg_data                     =>  p_msg_data,
      		p_receivable_application_id    =>  l_receivable_application_id,
      		p_reversal_gl_date             =>  null,
      		p_called_from		       => 'AR_REFUNDS_GRP',
		p_org_id		       =>  l_org_id);
  END IF;


  debug('ar_refunds_grp.subscribeto_invoice_event()-');
EXCEPTION

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: AR_REFUNDS_GRP.subscribeto_invoice_event()'||sqlerrm);
     END IF;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END subscribeto_invoice_event;

END AR_REFUNDS_GRP;

/
