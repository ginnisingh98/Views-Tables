--------------------------------------------------------
--  DDL for Package Body ARP_SELECTION_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_SELECTION_CRITERIA_PKG" AS
/* $Header: ARBRSELB.pls 120.5 2005/10/30 03:49:01 appldev ship $ */

/*--------------------------------------------------------+
|  Dummy constants for use in update and lock operations |
+--------------------------------------------------------*/

AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');


/*-------------------------------------+
|  WHO column values from ARP_GLOBAL  |
+-------------------------------------*/

pg_request_id                 number;
pg_program_application_id     number;
pg_program_id                 number;
pg_program_update_date        date;
pg_last_updated_by            number;
pg_last_update_date           date;
pg_last_update_login          number;
pg_set_of_books_id            number;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_selection_rec						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_sel_rec				      	             |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_selection_rec( p_sel_rec 	IN 	ar_selection_criteria%rowtype )

IS

BEGIN

   	arp_util.debug('arp_selection_criteria_pkg.display_selection_rec()+');

   	arp_util.debug('************** Dump of ar_selection_criteria record **************');
   	arp_util.debug('selection_criteria_id: ' 	|| p_sel_rec.selection_criteria_id);
   	arp_util.debug('last_updated_by: '    		|| p_sel_rec.last_updated_by);
   	arp_util.debug('created_by: '         		|| p_sel_rec.created_by);
   	arp_util.debug('last_update_login: '  		|| p_sel_rec.last_update_login);
   	arp_util.debug('due_date_low: '       		|| p_sel_rec.due_date_low);
   	arp_util.debug('due_date_high: '      		|| p_sel_rec.due_date_high);
   	arp_util.debug('trx_date_low: '       		|| p_sel_rec.trx_date_low);
   	arp_util.debug('trx_date_high: '      		|| p_sel_rec.trx_date_high);
   	arp_util.debug('cust_trx_type_id: '   		|| p_sel_rec.cust_trx_type_id);
   	arp_util.debug('receipt_method_id: ' 		|| p_sel_rec.receipt_method_id);
   	arp_util.debug('bank_branch_id: '     		|| p_sel_rec.bank_branch_id);
   	arp_util.debug('trx_number_low: '    		|| p_sel_rec.trx_number_low);
   	arp_util.debug('trx_number_high: '    		|| p_sel_rec.trx_number_high);
   	arp_util.debug('customer_class_code: '    	|| p_sel_rec.customer_class_code);
   	arp_util.debug('customer_category_code: ' 	|| p_sel_rec.customer_category_code);
   	arp_util.debug('customer_id	: '      	|| p_sel_rec.customer_id);
   	arp_util.debug('site_use_id: '        		|| p_sel_rec.site_use_id);

   	arp_util.debug('************** End ar_selection_criteria record **************');

   	arp_util.debug('arp_selection_criteria_pkg.display_selection_rec()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_selection_criteria_pkg.display_selection_rec()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_selection    					             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Selects and displays the values of all columns except creation_date    |
 |    and last_update_date.						     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_sel_id					             |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_selection ( p_sel_id IN ar_selection_criteria.selection_criteria_id%TYPE)

IS

l_sel_rec ar_selection_criteria%rowtype;

BEGIN

   	arp_util.debug('arp_selection_criteria_pkg.display_selection()+');

   	ARP_SELECTION_CRITERIA_PKG.fetch_p(l_sel_rec, p_sel_id);

   	ARP_SELECTION_CRITERIA_PKG.display_selection_rec (l_sel_rec);

   	arp_util.debug('arp_selection_criteria_pkg.display_selection()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_selection_criteria_pkg.display_selection()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes all columns in the parameter selection      |
 |    record to the appropriate dummy value for its datatype.		     |
 |    									     |
 |    The dummy values are defined in the following package level constants: |
 |	AR_TEXT_DUMMY 							     |
 |	AR_NUMBER_DUMMY							     |
 |	AR_DATE_DUMMY							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    p_sel_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_sel_rec OUT NOCOPY ar_selection_criteria%rowtype) IS

BEGIN

    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.set_to_dummy()+');

    	p_sel_rec.selection_criteria_id  	:=  AR_NUMBER_DUMMY;
    	p_sel_rec.last_update_date 		:=  AR_DATE_DUMMY;
    	p_sel_rec.last_updated_by 		:=  AR_NUMBER_DUMMY;
    	p_sel_rec.creation_date 		:=  AR_DATE_DUMMY;
    	p_sel_rec.created_by 			:=  AR_NUMBER_DUMMY;
    	p_sel_rec.last_update_login 		:=  AR_NUMBER_DUMMY;
    	p_sel_rec.due_date_low 			:=  AR_DATE_DUMMY;
    	p_sel_rec.due_date_high 		:=  AR_DATE_DUMMY;
    	p_sel_rec.trx_date_low			:=  AR_DATE_DUMMY;
    	p_sel_rec.trx_date_high			:=  AR_DATE_DUMMY;
    	p_sel_rec.cust_trx_type_id		:=  AR_NUMBER_DUMMY;
    	p_sel_rec.receipt_method_id		:=  AR_NUMBER_DUMMY;
    	p_sel_rec.bank_branch_id		:=  AR_NUMBER_DUMMY;
    	p_sel_rec.trx_number_low		:=  AR_TEXT_DUMMY;
    	p_sel_rec.trx_number_high		:=  AR_TEXT_DUMMY;
    	p_sel_rec.customer_class_code    	:=  AR_TEXT_DUMMY;
    	p_sel_rec.customer_category_code 	:=  AR_TEXT_DUMMY;
    	p_sel_rec.customer_id			:=  AR_NUMBER_DUMMY;
    	p_sel_rec.site_use_id			:=  AR_NUMBER_DUMMY;

    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  ARP_SELECTION_CRITERIA_PKG.set_to_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ar_selection_criteria into a  |
 |    variable specified as a parameter based on the table's primary key,    |
 |    selection_criteria_id.                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_sel_id  - identifies the record to fetch	     |
 |              OUT:                                                         |
 |                    p_sel_rec	- contains the fetched record	             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_sel_rec  OUT NOCOPY 	ar_selection_criteria%rowtype				,
                   p_sel_id   IN 	ar_selection_criteria.selection_criteria_id%TYPE 	) IS

BEGIN
    arp_util.debug('ARP_SELECTION_CRITERIA_PKG.fetch_p()+');

    	SELECT *
    	INTO   p_sel_rec
    	FROM   ar_selection_criteria
    	WHERE  selection_criteria_id = p_sel_id;

    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.fetch_p()-');

EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug('EXCEPTION: ARP_SELECTION_CRITERIA_PKG.fetch_p' );
            RAISE;
END;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_selection_criteria row identified by the   |
 |    p_selection_criteria_id parameter.			 	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_sel_id	- identifies the row to lock 		     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_sel_id    IN ar_selection_criteria.selection_criteria_id%TYPE )

IS

l_sel_id            ar_selection_criteria.selection_criteria_id%TYPE;

BEGIN
    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.lock_p()+');

	SELECT        selection_criteria_id
    	INTO          l_sel_id
    	FROM          ar_selection_criteria
    	WHERE         selection_criteria_id = p_sel_id
    	FOR UPDATE OF selection_criteria_id NOWAIT;

    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.lock_p()-');

EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: ARP_SELECTION_CRITERIA_PKG.lock_p' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_selection_criteria row identified by the   |
 |    p_sel_id parameter and populates the p_sel_rec parameter 		     |
 |    with the row that was locked.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_sel_id  - identifies the row to lock   		     |
 |              OUT:                                                         |
 |                    p_sel_rec	- contains the locked row	             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_sel_rec IN OUT NOCOPY ar_selection_criteria%rowtype				,
                        p_sel_id  IN     ar_selection_criteria.selection_criteria_id%TYPE 	)
IS

BEGIN
    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.lock_fetch_p()+');

    	SELECT 	*
    	INTO   	p_sel_rec
    	FROM   	ar_selection_criteria
    	WHERE  	selection_criteria_id = p_sel_id
    	FOR UPDATE OF selection_criteria_id NOWAIT;

    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.lock_fetch_p()-');

EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: ARP_SELECTION_CRITERIA_PKG.lock_fetch_p' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_selection_criteria row identified by the   |
 |    p_sel_id parameter only if no columns in that row have                 |
 |    changed from when they were first selected in the form		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_sel_id	- identifies the row to lock 		     |
 | 		      p_sel_rec	- selection record for comparison	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_p( p_sel_rec 	IN ar_selection_criteria%rowtype			,
                          p_sel_id  	IN ar_selection_criteria.selection_criteria_id%TYPE 	)
IS

l_new_sel_rec  ar_selection_criteria%rowtype;

BEGIN
    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.lock_compare_p()+');

    	SELECT        *
    	INTO          l_new_sel_rec
    	FROM          ar_selection_criteria tsel
    	WHERE         tsel.selection_criteria_id = p_sel_id
    	AND NOT

	(

	  NVL (tsel.selection_criteria_id, AR_NUMBER_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.selection_criteria_id,
			AR_NUMBER_DUMMY, tsel.selection_criteria_id,
					 p_sel_rec.selection_criteria_id ),
		AR_NUMBER_DUMMY
	      )
	OR
	  NVL (trunc(tsel.due_date_low), AR_DATE_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.due_date_low,
			AR_DATE_DUMMY,  trunc(tsel.due_date_low),
					p_sel_rec.due_date_low ),
		AR_DATE_DUMMY
	      )
	OR
	  NVL (trunc(tsel.due_date_high), AR_DATE_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.due_date_high,
			AR_DATE_DUMMY,  trunc(tsel.due_date_high),
					p_sel_rec.due_date_high ),
		AR_DATE_DUMMY
	      )
	OR
	  NVL (trunc(tsel.trx_date_low), AR_DATE_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.trx_date_low,
			AR_DATE_DUMMY,  trunc(tsel.trx_date_low),
					p_sel_rec.trx_date_low ),
		AR_DATE_DUMMY
	      )
	OR
          NVL (trunc(tsel.trx_date_high), AR_DATE_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.trx_date_high,
			AR_DATE_DUMMY,  trunc(tsel.trx_date_high),
					p_sel_rec.trx_date_high ),
		AR_DATE_DUMMY
	      )
	OR
	  NVL (tsel.cust_trx_type_id, AR_NUMBER_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.cust_trx_type_id,
			AR_NUMBER_DUMMY, tsel.cust_trx_type_id,
					 p_sel_rec.cust_trx_type_id ),
		AR_NUMBER_DUMMY
	      )
	OR
	  NVL (tsel.receipt_method_id, AR_NUMBER_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.receipt_method_id,
			AR_NUMBER_DUMMY, tsel.receipt_method_id,
					 p_sel_rec.receipt_method_id ),
		AR_NUMBER_DUMMY
	      )
	OR
	  NVL (tsel.bank_branch_id, AR_NUMBER_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.bank_branch_id,
			AR_NUMBER_DUMMY, tsel.bank_branch_id,
					 p_sel_rec.bank_branch_id ),
 		AR_NUMBER_DUMMY
	      )
	OR
	  NVL (tsel.trx_number_low, AR_TEXT_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.trx_number_low,
			AR_TEXT_DUMMY, 	tsel.trx_number_low,
					p_sel_rec.trx_number_low ),
 		AR_TEXT_DUMMY
	      )
	OR
	  NVL (tsel.trx_number_high, AR_TEXT_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.trx_number_high,
			AR_TEXT_DUMMY, 	tsel.trx_number_high,
					p_sel_rec.trx_number_high ),
 		AR_TEXT_DUMMY
	      )
	OR
	  NVL (tsel.customer_class_code, AR_TEXT_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.customer_class_code,
			AR_TEXT_DUMMY, 	tsel.customer_class_code,
				 	p_sel_rec.customer_class_code ),
		AR_TEXT_DUMMY
	      )
	OR
	  NVL (tsel.customer_category_code, AR_TEXT_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.customer_category_code,
			AR_TEXT_DUMMY, tsel.customer_category_code,
			               p_sel_rec.customer_category_code ),
		AR_TEXT_DUMMY
	      )
	OR
	  NVL (tsel.customer_id, AR_NUMBER_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.customer_id,
			AR_NUMBER_DUMMY, tsel.customer_id,
			                 p_sel_rec.customer_id ),
		AR_NUMBER_DUMMY
	      )
	OR
	  NVL (tsel.site_use_id, AR_NUMBER_DUMMY) <>
	  NVL (
		DECODE( p_sel_rec.site_use_id,
			AR_NUMBER_DUMMY, tsel.site_use_id,
                   		  	 p_sel_rec.site_use_id ),
		AR_NUMBER_DUMMY
	      )

	OR
          NVL (tsel.last_update_date, AR_DATE_DUMMY) <>
          NVL (
                 DECODE(p_sel_rec.last_update_date,
                        AR_DATE_DUMMY, tsel.last_update_date,
                                       p_sel_rec.last_update_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tsel.last_updated_by, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_sel_rec.last_updated_by,
                        AR_NUMBER_DUMMY, tsel.last_updated_by,
                                         p_sel_rec.last_updated_by),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tsel.creation_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_sel_rec.creation_date,
                        AR_DATE_DUMMY, tsel.creation_date,
                                       p_sel_rec.creation_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tsel.created_by, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_sel_rec.created_by,
                        AR_NUMBER_DUMMY, tsel.created_by,
                                         p_sel_rec.created_by),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tsel.last_update_login, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_sel_rec.last_update_login,
                        AR_NUMBER_DUMMY, tsel.last_update_login,
                                         p_sel_rec.last_update_login),
                 AR_NUMBER_DUMMY
              )

         )
    	FOR UPDATE OF selection_criteria_id NOWAIT;

    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.lock_compare_p()-');

EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: ARP_SELECTION_CRITERIA_PKG.lock_compare_p' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_cover                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Cover for calling the selection criteria table handler lock_compare_p  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_form_name                                          |
 |                      p_form_version                                       |
 |                 	p_selection_criteria_id                              |
 |		   	p_due_date_low					     |
 |			p_due_date_high				  	     |
 |			p_trx_date_low					     |
 |			p_trx_date_high					     |
 |			p_cust_trx_type_id				     |
 |			p_receipt_method_id				     |
 |			p_bank_branch_id			  	     |
 |			p_trx_number_low				     |
 |			p_trx_number_high				     |
 |			p_customer_class_code				     |
 |			p_customer_category_code		  	     |
 |			p_customer_id					     |
 |			p_site_use_id					     |
 |                    			                                     |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN  OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |									     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_cover(
  	p_form_name              	IN  varchar2						,
  	p_form_version           	IN  number						,
  	p_selection_criteria_id		IN  ar_selection_criteria.selection_criteria_id%TYPE	,
  	p_due_date_low			IN  ar_selection_criteria.due_date_low%TYPE		,
  	p_due_date_high			IN  ar_selection_criteria.due_date_high%TYPE		,
  	p_trx_date_low			IN  ar_selection_criteria.trx_date_low%TYPE		,
  	p_trx_date_high			IN  ar_selection_criteria.trx_date_high%TYPE		,
  	p_cust_trx_type_id		IN  ar_selection_criteria.cust_trx_type_id%TYPE		,
  	p_receipt_method_id		IN  ar_selection_criteria.receipt_method_id%TYPE	,
  	p_bank_branch_id		IN  ar_selection_criteria.bank_branch_id%TYPE		,
  	p_trx_number_low		IN  ar_selection_criteria.trx_number_low%TYPE		,
  	p_trx_number_high		IN  ar_selection_criteria.trx_number_high%TYPE		,
  	p_customer_class_code		IN  ar_selection_criteria.customer_class_code%TYPE	,
  	p_customer_category_code	IN  ar_selection_criteria.customer_category_code%TYPE	,
  	p_customer_id			IN  ar_selection_criteria.customer_id%TYPE		,
  	p_site_use_id			IN  ar_selection_criteria.site_use_id%TYPE		)

IS

l_sel_rec        		    ar_selection_criteria%rowtype;

BEGIN
    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.lock_compare_cover()+');

    	ARP_SELECTION_CRITERIA_PKG.set_to_dummy(l_sel_rec);

   	l_sel_rec.selection_criteria_id     	:= 	p_selection_criteria_id		;
    	l_sel_rec.due_date_low			:= 	p_due_date_low			;
    	l_sel_rec.due_date_high			:= 	p_due_date_high			;
    	l_sel_rec.trx_date_low			:= 	p_trx_date_low			;
    	l_sel_rec.trx_date_high			:= 	p_trx_date_high			;
    	l_sel_rec.cust_trx_type_id		:= 	p_cust_trx_type_id		;
    	l_sel_rec.receipt_method_id		:= 	p_receipt_method_id		;
    	l_sel_rec.bank_branch_id		:= 	p_bank_branch_id		;
    	l_sel_rec.trx_number_low		:= 	p_trx_number_low		;
    	l_sel_rec.trx_number_high		:= 	p_trx_number_high		;
    	l_sel_rec.customer_class_code		:= 	p_customer_class_code		;
    	l_sel_rec.customer_category_code	:= 	p_customer_category_code	;
    	l_sel_rec.customer_id			:= 	p_customer_id			;
    	l_sel_rec.site_use_id			:= 	p_site_use_id			;

    	ARP_SELECTION_CRITERIA_PKG.lock_compare_p(l_sel_rec, p_selection_criteria_id);

    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.lock_compare_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : ARP_SELECTION_CRITERIA_PKG.lock_compare_cover');

   arp_util.debug('************** Dump of ar_selection_criteria record **************');
   arp_util.debug('p_selection_criteria_id: ' 	|| p_selection_criteria_id);
   arp_util.debug('p_due_date_low: '          	|| p_due_date_low);
   arp_util.debug('p_due_date_high: '         	|| p_due_date_high);
   arp_util.debug('p_trx_date_low: '          	|| p_trx_date_low);
   arp_util.debug('p_trx_date_high: '         	|| p_trx_date_high);
   arp_util.debug('p_cust_trx_type_id: '      	|| p_cust_trx_type_id);
   arp_util.debug('p_receipt_method_id: '     	|| p_receipt_method_id);
   arp_util.debug('p_bank_branch_id: '        	|| p_bank_branch_id);
   arp_util.debug('p_trx_number_low: '        	|| p_trx_number_low);
   arp_util.debug('p_trx_number_high: '       	|| p_trx_number_high);
   arp_util.debug('p_customer_class_code: '    	|| p_customer_class_code);
   arp_util.debug('p_customer_category_code: ' 	|| p_customer_category_code);
   arp_util.debug('p_customer_id	: '     || p_customer_id);
   arp_util.debug('p_site_use_id: '           	|| p_site_use_id);

   arp_util.debug('************** End ar_selection_criteria record **************');


    RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_selection_criteria row identified by the |
 |    p_sel_id parameter.						     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_sel_id - identifies the row to delete 		     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_sel_id  IN ar_selection_criteria.selection_criteria_id%TYPE) IS

BEGIN

   	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.delete_p()+');

   	DELETE FROM 	ar_selection_criteria
   	WHERE		selection_criteria_id = p_sel_id;

   	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.delete_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  ARP_SELECTION_CRITERIA_PKG.delete_p()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_selection_criteria row identified by the |
 |    p_sel_id parameter.				     		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_sel_id 	      - identifies the row to update 	     |
 |                    p_sel_rec       - contains the new column values       |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_sel_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Tien Tran     Created                                    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_sel_rec IN ar_selection_criteria%rowtype,
                    p_sel_id  IN ar_selection_criteria.selection_criteria_id%TYPE) IS


BEGIN

   	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.update_p()+');

   	UPDATE AR_SELECTION_CRITERIA SET

		due_date_low	=
			DECODE( p_sel_rec.due_date_low,
				AR_DATE_DUMMY, due_date_low,
					       p_sel_rec.due_date_low ),

		due_date_high	=
			DECODE( p_sel_rec.due_date_high,
				AR_DATE_DUMMY,  due_date_high,
						p_sel_rec.due_date_high ),

		trx_date_low	=
			DECODE( p_sel_rec.trx_date_low,
				AR_DATE_DUMMY,  trx_date_low,
						p_sel_rec.trx_date_low ),

		trx_date_high	=
			DECODE( p_sel_rec.trx_date_high,
				AR_DATE_DUMMY,  trx_date_high,
						p_sel_rec.trx_date_high ),

		cust_trx_type_id =
			DECODE( p_sel_rec.cust_trx_type_id,
				AR_NUMBER_DUMMY, cust_trx_type_id,
						 p_sel_rec.cust_trx_type_id ),

		receipt_method_id =
			DECODE( p_sel_rec.receipt_method_id,
				AR_NUMBER_DUMMY, receipt_method_id,
						 p_sel_rec.receipt_method_id ),

		bank_branch_id =
			DECODE( p_sel_rec.bank_branch_id,
				AR_NUMBER_DUMMY, bank_branch_id,
						 p_sel_rec.bank_branch_id ),

		trx_number_low	=
			DECODE( p_sel_rec.trx_number_low,
				AR_TEXT_DUMMY,  trx_number_low,
	 					p_sel_rec.trx_number_low ),

		trx_number_high	=
			DECODE( p_sel_rec.trx_number_high,
				AR_TEXT_DUMMY,  trx_number_high,
						p_sel_rec.trx_number_high ),

		customer_class_code	=
			DECODE( p_sel_rec.customer_class_code,
				AR_TEXT_DUMMY,  customer_class_code,
						p_sel_rec.customer_class_code ),

		customer_category_code	=
			DECODE( p_sel_rec.customer_category_code,
				AR_TEXT_DUMMY,  customer_category_code,
						p_sel_rec.customer_category_code ),

		customer_id =
			DECODE( p_sel_rec.customer_id,
				AR_NUMBER_DUMMY, customer_id,
			  			 p_sel_rec.customer_id ),

		site_use_id =
			DECODE( p_sel_rec.site_use_id,
				AR_NUMBER_DUMMY, site_use_id,
						 p_sel_rec.site_use_id ),

  		last_update_login = pg_last_update_login,
                last_update_date  = pg_last_update_date,
                last_updated_by   = pg_last_updated_by

   	WHERE selection_criteria_id = p_sel_id;


   	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.update_p()-');


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  ARP_SELECTION_CRITERIA_PKG.update_p()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ar_selection_criteria that contains  |
 |    the column values specified in the p_sel_rec parameter. 		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug   							     |
 |    arp_global.set_of_books_id					     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_sel_rec       - contains the new column values       |
 |              OUT:                                                         |
 |                    p_sel_id	      - unique ID of the new row             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_p( p_sel_rec  IN  ar_selection_criteria%rowtype			,
                    p_sel_id   OUT NOCOPY ar_selection_criteria.selection_criteria_id%TYPE     )

IS
    l_sel_id    ar_selection_criteria.selection_criteria_id%TYPE;

BEGIN

    	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.insert_p()+');

    	p_sel_id := '';

    	/*---------------------------*
     	| Get the unique identifier |
     	*---------------------------*/

    	SELECT 	AR_SELECTION_CRITERIA_S.NEXTVAL
    	INTO   	l_sel_id
    	FROM   	DUAL;

     	/*-------------------*
     	| Insert the record |
     	*-------------------*/

   	INSERT INTO ar_selection_criteria
               (
                 selection_criteria_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 due_date_low,
		 due_date_high,
		 trx_date_low,
		 trx_date_high,
		 cust_trx_type_id,
		 receipt_method_id,
		 bank_branch_id,
		 trx_number_low,
		 trx_number_high,
		 customer_class_code,
		 customer_category_code,
		 customer_id,
		 site_use_id
               )
             VALUES
               (
                 l_sel_id,				/* selection_criteria_id 	*/
                 sysdate,				/* last_update_date 		*/
                 arp_standard.profile.user_id,		/* last_updated_by 		*/
                 sysdate,				/* creation_date 		*/
                 arp_standard.profile.user_id,		/* created_by 			*/
		 NVL( arp_standard.profile.last_update_login,p_sel_rec.last_update_login ),   /* last_update_login */
                 p_sel_rec.due_date_low,
                 p_sel_rec.due_date_high,
                 p_sel_rec.trx_date_low,
                 p_sel_rec.trx_date_high,
                 p_sel_rec.cust_trx_type_id,
                 p_sel_rec.receipt_method_id,
                 p_sel_rec.bank_branch_id,
                 p_sel_rec.trx_number_low,
                 p_sel_rec.trx_number_high,
                 p_sel_rec.customer_class_code,
                 p_sel_rec.customer_category_code,
                 p_sel_rec.customer_id,
                 p_sel_rec.site_use_id

               );

   	p_sel_id := l_sel_id;

   	arp_util.debug('ARP_SELECTION_CRITERIA_PKG.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  ARP_SELECTION_CRITERIA_PKG.insert_p()');
	RAISE;
END;


  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/

BEGIN

  	pg_request_id             :=  arp_global.request_id;
  	pg_program_application_id :=  arp_global.program_application_id;
  	pg_program_id             :=  arp_global.program_id;
  	pg_program_update_date    :=  arp_global.program_update_date;
  	pg_last_updated_by        :=  arp_global.last_updated_by;
  	pg_last_update_date       :=  arp_global.last_update_date;
  	pg_last_update_login      :=  arp_global.last_update_login;
  	pg_set_of_books_id        :=  arp_global.set_of_books_id;



END ARP_SELECTION_CRITERIA_PKG;

/
