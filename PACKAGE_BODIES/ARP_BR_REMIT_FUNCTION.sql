--------------------------------------------------------
--  DDL for Package Body ARP_BR_REMIT_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_BR_REMIT_FUNCTION" AS
/* $Header: ARBRRMFB.pls 115.8 2003/10/10 14:23:01 mraymond ship $*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION GET_AMOUNT (p_trh_id IN ar_transaction_history.transaction_history_id%TYPE,
		     p_status IN ar_transaction_history.status%TYPE,
		     p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE) RETURN NUMBER IS

l_field  varchar2(30);
l_amount NUMBER;

CURSOR dist_amount(p2_status IN ar_distributions.source_type%TYPE) is
select amount_dr
from ar_distributions
where source_id=p_trh_id
and   source_table='TH'
and   source_type=p2_status;

CURSOR app_amount is
select amount_applied
from ar_receivable_applications
where applied_customer_trx_id=p_customer_trx_id
and   status='APP'
and   link_to_trx_hist_id=p_trh_id;

BEGIN

IF (p_status='REMITTED') THEN
	OPEN dist_amount('REMITTANCE');
	FETCH dist_amount INTO l_amount;
	CLOSE dist_amount;
ELSIF (p_status='FACTORED') THEN
	OPEN dist_amount('FACTOR');
	FETCH dist_amount INTO l_amount;
	CLOSE dist_amount;
ELSIF (p_status='CLOSED') THEN
	OPEN app_amount;
	FETCH app_amount INTO l_amount;
	CLOSE app_amount;
ELSE
   l_field := 'P_STATUS';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','GET_AMOUNT');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

RETURN l_amount;

EXCEPTION
 WHEN OTHERS then
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_FUNCTION.GET_AMOUNT');
   END IF;

   IF dist_amount%ISOPEN THEN
      CLOSE dist_amount;
   END IF;

   IF app_amount%ISOPEN THEN
      CLOSE app_amount;
   END IF;

   RAISE;

END GET_AMOUNT;



FUNCTION GET_ACCTD_AMOUNT (p_trh_id IN ar_transaction_history.transaction_history_id%TYPE,
		           p_status IN ar_transaction_history.status%TYPE,
		           p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE) RETURN NUMBER IS

l_field  varchar2(30);
l_amount NUMBER;

CURSOR dist_amount(p2_status IN ar_distributions.source_type%TYPE) is
select acctd_amount_dr
from ar_distributions
where source_id=p_trh_id
and   source_table='TH'
and   source_type=p2_status;

CURSOR app_amount is
select amount_applied_from
from ar_receivable_applications
where applied_customer_trx_id=p_customer_trx_id
and   status='APP'
and   link_to_trx_hist_id=p_trh_id;

BEGIN

IF (p_status='REMITTED') THEN
	OPEN dist_amount('REMITTANCE');
	FETCH dist_amount INTO l_amount;
	CLOSE dist_amount;
ELSIF (p_status='FACTORED') THEN
	OPEN dist_amount('FACTOR');
	FETCH dist_amount INTO l_amount;
	CLOSE dist_amount;
ELSIF (p_status='CLOSED') THEN
	OPEN app_amount;
	FETCH app_amount INTO l_amount;
	CLOSE app_amount;
ELSE
   l_field := 'P_STATUS';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','GET_ACCTD_AMOUNT');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

RETURN l_amount;

EXCEPTION
 WHEN OTHERS then
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_FUNCTION.GET_ACCTD_AMOUNT');
   END IF;

   IF dist_amount%ISOPEN THEN
      CLOSE dist_amount;
   END IF;

   IF app_amount%ISOPEN THEN
      CLOSE app_amount;
   END IF;

   RAISE;

END GET_ACCTD_AMOUNT;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    revision                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the revision number of this package.             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | RETURNS    : Revision number of this package                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      10 JAN 2001 John HALL           Created                              |
 +===========================================================================*/
FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 115.8 $';
END revision;
--



END  ARP_BR_REMIT_FUNCTION;
--

/
