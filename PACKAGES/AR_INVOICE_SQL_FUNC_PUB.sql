--------------------------------------------------------
--  DDL for Package AR_INVOICE_SQL_FUNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INVOICE_SQL_FUNC_PUB" AUTHID CURRENT_USER AS
/*$Header: ARTPSQS.pls 115.6 99/10/11 16:15:56 porting sh $ */
 /*===========================================================================+
 | FUNCTION      get_description					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:           			                       	     |
 |                              	                                     |
 |              OUT: 							     |
 | RETURNS    : 							     |
 |                                                                           |
 | NOTES     : Function implemented is populate_mls_lexicals		     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      01-MAY-97  	Ashim K Dey      Created                             |
 +===========================================================================*/

FUNCTION get_description(p_customer_trx_line_id  IN NUMBER)
RETURN VARCHAR2;



/*===========================================================================+
 | FUNCTION        get_inv_tax_code_name
 |                                                                           |
 | DESCRIPTION                                                               |
 |                 This function is used for getting inv_tax_code_name
 |		                                                             |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  p_bill_to_site_use_id
 |		     p_bill_to_customer_id
 |		     p_tax_printing_option
 |		     p_printed_tax_name
 |		     p_tax_code
 |              OUT:                                                         |
 | RETURNS    : 							     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      02-MAY-97  	Ashim K Dey      Created                             |
 +===========================================================================*/

FUNCTION get_inv_tax_code_name(
	p_bill_to_site_use_id	IN NUMBER,
	p_bill_to_customer_id	IN NUMBER,
	p_tax_printing_option   IN VARCHAR2,
	p_printed_tax_name	IN VARCHAR2,
	p_tax_code 		IN VARCHAR2)
RETURN VARCHAR2;


/*=============================================================================
|| PRIVATE FUNCTION     get_com_total_activity
||
|| DESCRIPTION          Returns the commitment total activity
||
|| ARGUMENTS 		p_customer_trx_id
||			p_commit_parent_type
			p_init_cust_trx_id
||
|| RETURN
||
|| NOTE
||   This function simulates the report local function
||   commitments in RAXINV.rdf
||
||  MODIFICATION HISTORY
||      22-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_com_total_activity(
		p_customer_trx_id    IN NUMBER,
		p_trx_type 	     IN VARCHAR2,
		p_init_cust_trx_id   IN NUMBER)
return NUMBER ;


/*=============================================================================
|| PRIVATE FUNCTION     get_com_amt_uninvoiced
||
|| DESCRIPTION          Returns the commitment uninvoiced amount
||
|| ARGUMENTS 		p_init_cust_trx_id
||
|| RETURN   returns 0 if no data found; otherwise total uninvoiced amount
||	    for the transaction.
||
|| NOTE
||   This function simulates the cursor in report local function
||   "commitments" in RAXINV.rdf.
||   Here It is not checked whether Order entry is installed, becase
||   the table so_lines will always be present.
||
||  MODIFICATION HISTORY
||      22-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_com_amt_uninvoiced( p_init_cust_trx_id  IN NUMBER)
RETURN number  ;



FUNCTION get_com_balance(
		p_original_amount    IN NUMBER,
		p_trx_type 	     IN VARCHAR2,
		p_init_cust_trx_id   IN NUMBER)
RETURN NUMBER ;


/*=============================================================================
|| PRIVATE FUNCTION     get_commit_this_invoice
||
|| DESCRIPTION
||
|| ARGUMENTS 		p_customer_trx_id
||
|| RETURN  		commit_this_invoice
||
|| NOTE
||   This function simulates the query Q_Commitment_Adjustment in RAXINV.rdf.
||
||  MODIFICATION HISTORY
||      23-MAY-97  	Ashim K Dey      Created
=============================================================================*/
FUNCTION get_commit_this_invoice(p_customer_trx_id  IN NUMBER)
RETURN number ;


/*=============================================================================
|| PRIVATE PROCEDURE     update_customer_trx
||
|| DESCRIPTION          This procedure updates the ra_customer_trx table
||		   and sets the printing information.
||
|| ARGUMENTS
||              IN:     p_choice
||			p_customer_trx_id
||			p_trx_type
||			p_term_count
||			p_term_sequence_number
||			p_printing_count
||			p_printing_original_date
||
||              OUT:
||
|| FUNCTION CALL
||
|| RETURN
||
|| NOTE    This is a update  procedure. So pragma restriction should not be
||         imposed in its declaration.
||
||  MODIFICATION HISTORY
||      29-MAY-97  	Ashim K Dey      Created
=============================================================================*/

PROCEDURE update_customer_trx (
		p_choice	   	 IN VARCHAR2,
		p_customer_trx_id  	 IN NUMBER,
		p_trx_type	   	 IN VARCHAR2,
		p_term_count	   	 IN NUMBER,
		p_term_sequence_number   IN NUMBER,
		p_printing_count   	 IN NUMBER,
		p_printing_original_date IN DATE) ;

/*=============================================================================
|| PRIVATE PROCEDURE     get_taxyn
||
|| DESCRIPTION
||
|| ARGUMENTS
||              IN:     p_customer_trx_line_id
||
||              OUT:
||
|| FUNCTION CALL
||
|| RETURN
||
|| NOTE     For ease of translation ar_lookup table is referred for
||	    getting 'Yes' or 'No'
||
||  MODIFICATION HISTORY
||      29-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_taxyn ( p_customer_trx_line_id IN  NUMBER)
return VARCHAR2 ;


/*=============================================================================
|| PRIVATE FUNCTION     get_remit_to_given_bill_to
||
|| DESCRIPTION
||
||
|| ARGUMENTS
||
|| FUNCTION CALL
||
|| RETURN
||
|| NOTE
||
||  MODIFICATION HISTORY
||      29-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_remit_to_given_bill_to( p_bill_to_site_use_id in number )
return number ;


/*=============================================================================
|| PRIVATE FUNCTION     get_remit_address_id
||
|| DESCRIPTION          This function gets the remit_address_id
||
||
|| ARGUMENTS
||
|| FUNCTION CALL
||
|| RETURN
||
|| NOTE
||
||  MODIFICATION HISTORY
||      29-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_remit_address_id(
	p_remit_to_address_id		IN NUMBER,
	p_previous_customer_trx_id 	IN NUMBER,
	p_trx_type    	      		IN VARCHAR2,
	p_bill_to_site_use_id 		IN NUMBER)
return varchar2 ;


END AR_INVOICE_SQL_FUNC_PUB ;

 

/
