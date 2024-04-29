--------------------------------------------------------
--  DDL for Package Body ARP_RW_ICR_REMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RW_ICR_REMIT_PKG" AS
/* $Header: ARICRRLB.pls 120.0.12010000.3 2009/04/29 14:55:07 mpsingh noship $ */
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_row   -  Update a row in the AR_ICR     table after checking for|
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row in AR_ICR     table after checking for     |
 |    uniqueness for items of the receipt                                    |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
  +===========================================================================*/


PROCEDURE update_row(
          P_REMIT_REFERENCE_ID      IN     ar_cash_remit_refs_all.REMIT_REFERENCE_ID%TYPE,
	  P_AUTOMATCH_SET_ID        IN     ar_cash_remit_refs_all.AUTOMATCH_SET_ID%TYPE,
	  P_CASH_RECEIPT_ID         IN     ar_cash_remit_refs_all.CASH_RECEIPT_ID%TYPE,
	  P_LINE_NUMBER             IN     ar_cash_remit_refs_all.LINE_NUMBER%TYPE,
	  P_REFERENCE_SOURCE        IN     ar_cash_remit_refs_all.REFERENCE_SOURCE%TYPE,
	  P_CUSTOMER_ID             IN     ar_cash_remit_refs_all.CUSTOMER_ID%TYPE,
	  P_CUSTOMER_NUMBER         IN     ar_cash_remit_refs_all.CUSTOMER_NUMBER%TYPE,
	  P_BANK_ACCOUNT_NUMBER     IN     ar_cash_remit_refs_all.BANK_ACCOUNT_NUMBER%TYPE,
	  P_TRANSIT_ROUTING_NUMBER  IN     ar_cash_remit_refs_all.TRANSIT_ROUTING_NUMBER%TYPE,
	  P_INVOICE_REFERENCE       IN     ar_cash_remit_refs_all.INVOICE_REFERENCE%TYPE,
	  P_MATCHING_REFERENCE_DATE     IN ar_cash_remit_refs_all.MATCHING_REFERENCE_DATE%TYPE,
	  P_RESOLVED_MATCHING_NUMBER    IN ar_cash_remit_refs_all.RESOLVED_MATCHING_NUMBER%TYPE,
	  --P_RESOLVED_MATCHING_INSTALLMENT IN ar_cash_remit_refs_all.RESOLVED_MATCHING_INSTALLMENT%TYPE,
	  P_RESOLVED_MATCHING_DATE        IN ar_cash_remit_refs_all.RESOLVED_MATCHING_DATE%TYPE,
	  P_INVOICE_CURRENCY_CODE         IN ar_cash_remit_refs_all.INVOICE_CURRENCY_CODE%TYPE,
	  P_AMOUNT_APPLIED                IN ar_cash_remit_refs_all.AMOUNT_APPLIED%TYPE,
	  P_AMOUNT_APPLIED_FROM           IN ar_cash_remit_refs_all.AMOUNT_APPLIED_FROM%TYPE,
	  P_TRANS_TO_RECEIPT_RATE         IN ar_cash_remit_refs_all.TRANS_TO_RECEIPT_RATE%TYPE,
	  P_INVOICE_STATUS                IN ar_cash_remit_refs_all.INVOICE_STATUS%TYPE,
	  P_MATCH_RESOLVED_USING          IN ar_cash_remit_refs_all.MATCH_RESOLVED_USING%TYPE,
	  P_CUSTOMER_TRX_ID               IN ar_cash_remit_refs_all.CUSTOMER_TRX_ID%TYPE,
	  P_PAYMENT_SCHEDULE_ID           IN ar_cash_remit_refs_all.PAYMENT_SCHEDULE_ID%TYPE,
	  P_CUSTOMER_REFERENCE            IN ar_cash_remit_refs_all.CUSTOMER_REFERENCE%TYPE,
	  P_AUTO_APPLIED                  IN ar_cash_remit_refs_all.AUTO_APPLIED%TYPE,
	  P_MANUALLY_APPLIED              IN ar_cash_remit_refs_all.MANUALLY_APPLIED%TYPE,
	  P_INSTALLMENT_NUMBER            IN ar_cash_remit_refs_all.INSTALLMENT_NUMBER%TYPE,
	  P_PROGRAM_APPLICATION_ID        IN ar_cash_remit_refs_all.PROGRAM_APPLICATION_ID%TYPE,
	  P_PROGRAM_ID                    IN ar_cash_remit_refs_all.PROGRAM_ID%TYPE,
	  P_PROGRAM_UPDATE_DATE           IN ar_cash_remit_refs_all.PROGRAM_UPDATE_DATE%TYPE,
	  P_REQUEST_ID                    IN ar_cash_remit_refs_all.REQUEST_ID%TYPE ) IS
--
l_icr_rec   ar_interim_cash_receipts%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_remit_pkg.update_row()+' );
    END IF;

     UPDATE AR_CASH_REMIT_REFS_ALL
     SET
       REMIT_REFERENCE_ID = P_REMIT_REFERENCE_ID,
       AUTOMATCH_SET_ID   = P_AUTOMATCH_SET_ID,
       CASH_RECEIPT_ID    = P_CASH_RECEIPT_ID,
       LINE_NUMBER        = P_LINE_NUMBER,
       REFERENCE_SOURCE   = P_REFERENCE_SOURCE,
       CUSTOMER_ID        = P_CUSTOMER_ID,
       CUSTOMER_NUMBER    = P_CUSTOMER_NUMBER,
       BANK_ACCOUNT_NUMBER = P_BANK_ACCOUNT_NUMBER,
       TRANSIT_ROUTING_NUMBER = P_TRANSIT_ROUTING_NUMBER,
       INVOICE_REFERENCE   = P_INVOICE_REFERENCE,
       MATCHING_REFERENCE_DATE  = P_MATCHING_REFERENCE_DATE,
       RESOLVED_MATCHING_NUMBER = P_RESOLVED_MATCHING_NUMBER,
       --RESOLVED_MATCHING_INSTALLMENT = P_RESOLVED_MATCHING_INSTALLMENT,
       RESOLVED_MATCHING_DATE  = P_RESOLVED_MATCHING_DATE,
       INVOICE_CURRENCY_CODE   = P_INVOICE_CURRENCY_CODE,
       AMOUNT_APPLIED       = P_AMOUNT_APPLIED,
       AMOUNT_APPLIED_FROM  = P_AMOUNT_APPLIED_FROM,
       TRANS_TO_RECEIPT_RATE = P_TRANS_TO_RECEIPT_RATE,
       INVOICE_STATUS        = P_INVOICE_STATUS,
       MATCH_RESOLVED_USING = P_MATCH_RESOLVED_USING,
       CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID,
       PAYMENT_SCHEDULE_ID = P_PAYMENT_SCHEDULE_ID,
       CUSTOMER_REFERENCE = P_CUSTOMER_REFERENCE,
       AUTO_APPLIED = P_AUTO_APPLIED,
       MANUALLY_APPLIED = P_MANUALLY_APPLIED,
       INSTALLMENT_NUMBER = P_INSTALLMENT_NUMBER,
       LAST_UPDATED_BY = arp_global.last_updated_by,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATE_LOGIN = arp_global.last_update_login,
       PROGRAM_APPLICATION_ID = P_PROGRAM_APPLICATION_ID,
       PROGRAM_ID = P_PROGRAM_ID,
       PROGRAM_UPDATE_DATE = P_PROGRAM_UPDATE_DATE,
       REQUEST_ID = P_REQUEST_ID
    WHERE  REMIT_REFERENCE_ID = P_REMIT_REFERENCE_ID;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_remit_pkg.update_row(-)' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(  'EXCEPTION: arp_rw_icr_pkg.update_row' );
             END IF;
             RAISE;
END update_row;
--

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_row   -  Inserts a row into the AR_CASH_REMIT_REFS_ALL table    |
 |                                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY -  	     	     |
 +===========================================================================*/
PROCEDURE insert_row(
	  P_REMIT_REFERENCE_ID      IN     ar_cash_remit_refs_all.REMIT_REFERENCE_ID%TYPE,
	  P_AUTOMATCH_SET_ID        IN     ar_cash_remit_refs_all.AUTOMATCH_SET_ID%TYPE,
	  P_CASH_RECEIPT_ID         IN     ar_cash_remit_refs_all.CASH_RECEIPT_ID%TYPE,
	  P_LINE_NUMBER             IN     ar_cash_remit_refs_all.LINE_NUMBER%TYPE,
	  P_REFERENCE_SOURCE        IN     ar_cash_remit_refs_all.REFERENCE_SOURCE%TYPE,
	  P_CUSTOMER_ID             IN     ar_cash_remit_refs_all.CUSTOMER_ID%TYPE,
	  P_CUSTOMER_NUMBER         IN     ar_cash_remit_refs_all.CUSTOMER_NUMBER%TYPE,
	  P_BANK_ACCOUNT_NUMBER     IN     ar_cash_remit_refs_all.BANK_ACCOUNT_NUMBER%TYPE,
	  P_TRANSIT_ROUTING_NUMBER  IN     ar_cash_remit_refs_all.TRANSIT_ROUTING_NUMBER%TYPE,
	  P_INVOICE_REFERENCE       IN     ar_cash_remit_refs_all.INVOICE_REFERENCE%TYPE,
	  P_MATCHING_REFERENCE_DATE     IN ar_cash_remit_refs_all.MATCHING_REFERENCE_DATE%TYPE,
	  P_RESOLVED_MATCHING_NUMBER    IN ar_cash_remit_refs_all.RESOLVED_MATCHING_NUMBER%TYPE,
	 -- P_RESOLVED_MATCHING_INSTALLMENT IN ar_cash_remit_refs_all.RESOLVED_MATCHING_INSTALLMENT%TYPE,
	  P_RESOLVED_MATCHING_DATE        IN ar_cash_remit_refs_all.RESOLVED_MATCHING_DATE%TYPE,
	  P_INVOICE_CURRENCY_CODE         IN ar_cash_remit_refs_all.INVOICE_CURRENCY_CODE%TYPE,
	  P_AMOUNT_APPLIED                IN ar_cash_remit_refs_all.AMOUNT_APPLIED%TYPE,
	  P_AMOUNT_APPLIED_FROM           IN ar_cash_remit_refs_all.AMOUNT_APPLIED_FROM%TYPE,
	  P_TRANS_TO_RECEIPT_RATE         IN ar_cash_remit_refs_all.TRANS_TO_RECEIPT_RATE%TYPE,
	  P_INVOICE_STATUS                IN ar_cash_remit_refs_all.INVOICE_STATUS%TYPE,
	  P_MATCH_RESOLVED_USING          IN ar_cash_remit_refs_all.MATCH_RESOLVED_USING%TYPE,
	  P_CUSTOMER_TRX_ID               IN ar_cash_remit_refs_all.CUSTOMER_TRX_ID%TYPE,
	  P_PAYMENT_SCHEDULE_ID           IN ar_cash_remit_refs_all.PAYMENT_SCHEDULE_ID%TYPE,
	  P_CUSTOMER_REFERENCE            IN ar_cash_remit_refs_all.CUSTOMER_REFERENCE%TYPE,
	  P_AUTO_APPLIED                  IN ar_cash_remit_refs_all.AUTO_APPLIED%TYPE,
	  P_MANUALLY_APPLIED              IN ar_cash_remit_refs_all.MANUALLY_APPLIED%TYPE,
	  P_INSTALLMENT_NUMBER            IN ar_cash_remit_refs_all.INSTALLMENT_NUMBER%TYPE,
	  P_PROGRAM_APPLICATION_ID        IN ar_cash_remit_refs_all.PROGRAM_APPLICATION_ID%TYPE,
	  P_PROGRAM_ID                    IN ar_cash_remit_refs_all.PROGRAM_ID%TYPE,
	  P_PROGRAM_UPDATE_DATE           IN ar_cash_remit_refs_all.PROGRAM_UPDATE_DATE%TYPE,
	  P_REQUEST_ID                    IN ar_cash_remit_refs_all.REQUEST_ID%TYPE,
	  P_BATCH_ID			  IN NUMBER DEFAULT NULL) IS
--
l_rr_id    NUMBER;
l_line_num NUMBER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_remit_pkg.insert_row()+' );
    END IF;

      SELECT AR_CASH_REMIT_REFS_S.nextval
      INTO   l_rr_id
      FROM   dual;
      --



      INSERT INTO AR_CASH_REMIT_REFS_ALL (
       REMIT_REFERENCE_ID,
       AUTOMATCH_SET_ID,
       CASH_RECEIPT_ID,
       RECEIPT_REFERENCE_STATUS,
       LINE_NUMBER,
       REFERENCE_SOURCE,
       CUSTOMER_ID,
       CUSTOMER_NUMBER,
       BANK_ACCOUNT_NUMBER,
       TRANSIT_ROUTING_NUMBER,
       INVOICE_REFERENCE,
       MATCHING_REFERENCE_DATE,
       RESOLVED_MATCHING_NUMBER,
       --RESOLVED_MATCHING_INSTALLMENT,
       RESOLVED_MATCHING_DATE,
       INVOICE_CURRENCY_CODE,
       AMOUNT_APPLIED,
       AMOUNT_APPLIED_FROM,
       TRANS_TO_RECEIPT_RATE,
       INVOICE_STATUS,
       MATCH_RESOLVED_USING,
       ORG_ID,
       CUSTOMER_TRX_ID,
       PAYMENT_SCHEDULE_ID,
       CUSTOMER_REFERENCE,
       AUTO_APPLIED,
       MANUALLY_APPLIED,
       INSTALLMENT_NUMBER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       REQUEST_ID,
       BATCH_ID
      )
      VALUES
      (
	l_rr_id,
	P_AUTOMATCH_SET_ID,
	P_CASH_RECEIPT_ID,
	'AR_AM_NEW',
	P_LINE_NUMBER,
	P_REFERENCE_SOURCE,
	P_CUSTOMER_ID,
	P_CUSTOMER_NUMBER,
	P_BANK_ACCOUNT_NUMBER,
	P_TRANSIT_ROUTING_NUMBER,
	P_INVOICE_REFERENCE,
	P_MATCHING_REFERENCE_DATE,
	'NULL', -- P_RESOLVED_MATCHING_NUMBER,
	--P_RESOLVED_MATCHING_INSTALLMENT,
	P_RESOLVED_MATCHING_DATE,
	P_INVOICE_CURRENCY_CODE,
	P_AMOUNT_APPLIED,
	P_AMOUNT_APPLIED_FROM,
	P_TRANS_TO_RECEIPT_RATE,
	P_INVOICE_STATUS,
	P_MATCH_RESOLVED_USING,
	arp_standard.sysparm.org_id,
	P_CUSTOMER_TRX_ID,
	P_PAYMENT_SCHEDULE_ID,
	P_CUSTOMER_REFERENCE,
	P_AUTO_APPLIED,
	P_MANUALLY_APPLIED,
	P_INSTALLMENT_NUMBER,
	arp_global.last_updated_by,
	sysdate,
	arp_global.last_updated_by,
	sysdate,
	arp_global.last_update_login,
	P_PROGRAM_APPLICATION_ID,
	P_PROGRAM_ID,
	P_PROGRAM_UPDATE_DATE,
	P_REQUEST_ID,
	P_BATCH_ID
      );


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_remit_pkg.insert_row(-)' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(  'EXCEPTION: arp_rw_icr_remit_pkg.insert_row' );
             END IF;
             RAISE;
END insert_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_row   -  Deletes a row from the AR_CASH_REMIT_REFS_ALL table    |
 |  									     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row from AR_CASH_REMIT_REFS_ALL.	             |
 |   									     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee               |
  +===========================================================================*/
PROCEDURE delete_row(
             p_rr_id IN ar_cash_remit_refs_all.remit_reference_id%TYPE
            ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_remit_pkg.delete_row()+' );
    END IF;
    --
        IF ( p_rr_id is NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;

    DELETE FROM ar_cash_remit_refs_all
    WHERE remit_reference_id = p_rr_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_remit_pkg.delete_row(-)' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('delete_row: ' ||
                   'EXCEPTION: arp_rw_icr_remit_pkg.delete_row' );
              END IF;
        RAISE;
END delete_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_row     -  Lock a row in the AR_CASH_REMIT_REFS_ALL     table     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee               |
 +===========================================================================*/
PROCEDURE lock_row(
          P_REMIT_REFERENCE_ID      IN     ar_cash_remit_refs_all.REMIT_REFERENCE_ID%TYPE,
	  P_AUTOMATCH_SET_ID        IN     ar_cash_remit_refs_all.AUTOMATCH_SET_ID%TYPE,
	  P_CASH_RECEIPT_ID         IN     ar_cash_remit_refs_all.CASH_RECEIPT_ID%TYPE,
	  P_LINE_NUMBER             IN     ar_cash_remit_refs_all.LINE_NUMBER%TYPE,
	  P_REFERENCE_SOURCE        IN     ar_cash_remit_refs_all.REFERENCE_SOURCE%TYPE,
	  P_CUSTOMER_ID             IN     ar_cash_remit_refs_all.CUSTOMER_ID%TYPE,
	  P_CUSTOMER_NUMBER         IN     ar_cash_remit_refs_all.CUSTOMER_NUMBER%TYPE,
	  P_BANK_ACCOUNT_NUMBER     IN     ar_cash_remit_refs_all.BANK_ACCOUNT_NUMBER%TYPE,
	  P_TRANSIT_ROUTING_NUMBER  IN     ar_cash_remit_refs_all.TRANSIT_ROUTING_NUMBER%TYPE,
	  P_INVOICE_REFERENCE       IN     ar_cash_remit_refs_all.INVOICE_REFERENCE%TYPE,
	  P_MATCHING_REFERENCE_DATE     IN ar_cash_remit_refs_all.MATCHING_REFERENCE_DATE%TYPE,
	  P_RESOLVED_MATCHING_NUMBER    IN ar_cash_remit_refs_all.RESOLVED_MATCHING_NUMBER%TYPE,
	  --P_RESOLVED_MATCHING_INSTALLMENT IN ar_cash_remit_refs_all.RESOLVED_MATCHING_INSTALLMENT%TYPE,
	  P_RESOLVED_MATCHING_DATE        IN ar_cash_remit_refs_all.RESOLVED_MATCHING_DATE%TYPE,
	  P_INVOICE_CURRENCY_CODE         IN ar_cash_remit_refs_all.INVOICE_CURRENCY_CODE%TYPE,
	  P_AMOUNT_APPLIED                IN ar_cash_remit_refs_all.AMOUNT_APPLIED%TYPE,
	  P_AMOUNT_APPLIED_FROM           IN ar_cash_remit_refs_all.AMOUNT_APPLIED_FROM%TYPE,
	  P_TRANS_TO_RECEIPT_RATE         IN ar_cash_remit_refs_all.TRANS_TO_RECEIPT_RATE%TYPE,
	  P_INVOICE_STATUS                IN ar_cash_remit_refs_all.INVOICE_STATUS%TYPE,
	  P_MATCH_RESOLVED_USING          IN ar_cash_remit_refs_all.MATCH_RESOLVED_USING%TYPE,
	  P_CUSTOMER_TRX_ID               IN ar_cash_remit_refs_all.CUSTOMER_TRX_ID%TYPE,
	  P_PAYMENT_SCHEDULE_ID           IN ar_cash_remit_refs_all.PAYMENT_SCHEDULE_ID%TYPE,
	  P_CUSTOMER_REFERENCE            IN ar_cash_remit_refs_all.CUSTOMER_REFERENCE%TYPE,
	  P_AUTO_APPLIED                  IN ar_cash_remit_refs_all.AUTO_APPLIED%TYPE,
	  P_MANUALLY_APPLIED              IN ar_cash_remit_refs_all.MANUALLY_APPLIED%TYPE,
	  P_INSTALLMENT_NUMBER            IN ar_cash_remit_refs_all.INSTALLMENT_NUMBER%TYPE,
	  P_PROGRAM_APPLICATION_ID        IN ar_cash_remit_refs_all.PROGRAM_APPLICATION_ID%TYPE,
	  P_PROGRAM_ID                    IN ar_cash_remit_refs_all.PROGRAM_ID%TYPE,
	  P_PROGRAM_UPDATE_DATE           IN ar_cash_remit_refs_all.PROGRAM_UPDATE_DATE%TYPE,
	  P_REQUEST_ID                    IN ar_cash_remit_refs_all.REQUEST_ID%TYPE
	  ) IS
    CURSOR C IS
	SELECT *
	FROM ar_cash_remit_refs_all
	WHERE remit_reference_id = P_REMIT_REFERENCE_ID
	FOR UPDATE of REMIT_REFERENCE_ID NOWAIT;
    Recinfo C%ROWTYPE;
--
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('lock_row: ' ||  'Made it to lock row' );
    END IF;

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
	CLOSE C;
	FND_MESSAGE.Set_Name( 'FND', 'FORM_RECORD_DELETED');
	APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if(
                (recinfo.remit_reference_id = p_remit_reference_id )
	    and	(recinfo.invoice_reference = p_invoice_reference)
            and	(recinfo.amount_applied = p_amount_applied)
	    and	((recinfo.matching_reference_date = p_matching_reference_date)
		  or  ((recinfo.matching_reference_date is null)
		    and	(p_matching_reference_date is null)))
            and	((recinfo.invoice_currency_code = p_invoice_currency_code)
		  or  ((recinfo.invoice_currency_code is null)
		    and	(p_invoice_currency_code is null)))
	    and	((recinfo.amount_applied_from = p_amount_applied_from)
		  or  ((recinfo.amount_applied_from is null)
		    and	(p_amount_applied_from is null)))
            and	((recinfo.trans_to_receipt_rate = p_trans_to_receipt_rate)
		  or  ((recinfo.trans_to_receipt_rate is null)
		    and	(p_trans_to_receipt_rate is null)))
            and	((recinfo.customer_reference = p_customer_reference)
		  or  ((recinfo.customer_reference is null)
		    and	(p_customer_reference is null)))
	    and	((recinfo.installment_number = p_installment_number)
		  or  ((recinfo.installment_number is null)
		    and	(p_installment_number is null)))
    ) then
        return;
    else
	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
 	APP_EXCEPTION.Raise_Exception;
    end if;
END lock_row;
--
END ARP_RW_ICR_REMIT_PKG;

/
