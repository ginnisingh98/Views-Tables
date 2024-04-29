--------------------------------------------------------
--  DDL for Package Body AR_INVOICE_SQL_FUNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INVOICE_SQL_FUNC_PUB" AS
/*$Header: ARTPSQBS.pls 120.2 2005/06/04 04:25:32 mraymond ship $*/
 pg_reference_column VARCHAR2(240);

/*===========================================================================+
 | FUNCTION      get_description					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                This function is used for multi-lingual support installs.  |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:     p_customer_trx_line_id   		             |
 |                              	                                     |
 |              OUT:  							     |
 | RETURNS    : 							     |
 |                                                                           |
 | NOTES     :  Called by lines view  					     |
 |		Function implemented is part of populate_mls_lexicals, which |
 |		is split into 2 functions get_description and 		     |
 |		get_alt_description due to 2 return values.		     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      01-MAY-97  	Ashim K Dey      Created                             |
 |	30-JUL-98	Victoria Smith	 This is now just a dummy/cover      |
 |					 function that always returns null   |
 |				         since single language installations |
 |					 have no translated descriptions     |
 |      05-JAN-99       Victoria Smith   modified to pick up translated_     |
 | 					 description			     |
 |      08-APR-04       Naruhiko Yanagita expanded the length of             |
 |                                        l_description from 240 to 1000.    |
 +===========================================================================*/

FUNCTION get_description (p_customer_trx_line_id  IN NUMBER)
RETURN VARCHAR2 IS

l_description varchar2(1000);

BEGIN

  select translated_description
    into l_description
    from ra_customer_trx_lines
   where customer_trx_line_id = p_customer_trx_line_id;

  return(l_description);

END get_description;

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
 | NOTES      This function is used in view  ar_invoice_tax_summary_v        |
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
RETURN VARCHAR2 IS

l_tax_printing_option 	VARCHAR2(30);

BEGIN
	IF ( p_bill_to_site_use_id IS NULL
	   AND p_bill_to_customer_id IS NULL
	   AND p_tax_printing_option IS NULL)

	THEN

	   RETURN(null) ;

	END IF ;

	SELECT nvl( cp_site.tax_printing_option,
        	 nvl(cp_cust.tax_printing_option,p_tax_printing_option) )
	INTO   l_tax_printing_option
	FROM   hz_customer_profiles 	cp_site,
       	       hz_customer_profiles 	cp_cust,
       	       hz_cust_site_uses       	site
	WHERE  cp_site.site_use_id(+) = site.site_use_id
	AND    site.site_use_id       = p_bill_to_site_use_id
	AND    cp_cust.cust_account_id = p_bill_to_customer_id
	AND    cp_cust.site_use_id    is null;

	IF  ( l_tax_printing_option IS NULL
             OR l_tax_printing_option = 'RECAP_BY_NAME')

	THEN

	     RETURN(p_printed_tax_name) ;

	ELSE

	     RETURN(p_tax_code) ;

	END IF ;

EXCEPTION WHEN NO_DATA_FOUND THEN

	l_tax_printing_option := p_tax_printing_option;

		IF  ( l_tax_printing_option IS NULL
                    OR l_tax_printing_option = 'RECAP_BY_NAME')

		THEN

	     	    RETURN(p_printed_tax_name) ;

		ELSE

	     	    RETURN(p_tax_code) ;
		END IF ;

END get_inv_tax_code_name;

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
RETURN NUMBER IS

commit_adjustments        number := 0;
commit_total_activity     number := 0;
commit_this_invoice	  number := 0;

BEGIN

      IF p_trx_type = 'DEP'

      THEN
           /*-------------------------------------------+
            | If the commitment type is for a DEPOSIT   |
            +-------------------------------------------*/

           SELECT NVL(SUM(adj.amount),0)
             INTO commit_adjustments
             FROM ra_customer_trx 		trx,
                  ra_cust_trx_types 		type,
                  ar_adjustments 		adj
            WHERE trx.cust_trx_type_id 		= type.cust_trx_type_id
              AND type.type in ('INV', 'CM')
              AND trx.complete_flag		='Y'
              AND trx.initial_customer_trx_id 	= p_init_cust_trx_id
              AND adj.customer_trx_id 	= DECODE(type.type,
                               'INV', trx.customer_trx_id,
                               'CM', trx.previous_customer_trx_id)
              AND NVL(adj.subsequent_trx_id,-111) = DECODE(type.type,
                               'INV',-111,
				'CM',trx.customer_trx_id)
              AND adj.adjustment_type 		= 'C';

           SELECT NVL(SUM(line.extended_amount),0)
           INTO   commit_total_activity
           FROM   ra_customer_trx trx,
                  ra_cust_trx_types type,
                  ra_customer_trx_lines line
           WHERE  trx.cust_trx_type_id = type.cust_trx_type_id
             AND  trx.customer_trx_id = line.customer_trx_id
             AND    type.type = 'CM'
             AND    trx.complete_flag = 'Y'
             AND    trx.previous_customer_trx_id = p_init_cust_trx_id;

      ELSIF p_trx_type = 'GUAR'

      THEN

           /*----------------------------------------------------------+
            | If the commitment type is for a GUARANTEE                |
            +----------------------------------------------------------*/

           SELECT -1 * (NVL(SUM(amount_line_items_original), 0) -
                        NVL(SUM(amount_line_items_remaining), 0))
           INTO   commit_total_activity
           FROM   ar_payment_schedules
           WHERE  customer_trx_id = p_init_cust_trx_id;

     ELSE commit_total_activity := 0;

     END IF;

           /*----------------------------------------------------------+
            | commit_total_activity is including commit_this amount    |
            +----------------------------------------------------------*/

     commit_total_activity := commit_total_activity+commit_adjustments;

           /*----------------------------------------------------------+
            | Now get commit_this_invoice and substract from  total    |
	    | activity   					       |
            +----------------------------------------------------------*/

     SELECT SUM(Amount)
     INTO commit_this_invoice
     FROM ar_adjustments
     WHERE adjustment_type = 'C'
	   AND ( ((customer_trx_id = p_customer_trx_id )
		 	AND (subsequent_trx_id is null))
      		  OR  subsequent_trx_id = p_customer_trx_id);

     commit_total_activity := commit_total_activity -
				nvl(commit_this_invoice,0) ;

     return( commit_total_activity ) ;

END get_com_total_activity ;

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
||   Here It is not checked whether Order entry is installed, because
||   the table so_lines will always be present.
||
||  MODIFICATION HISTORY
||      22-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_com_amt_uninvoiced(
		p_init_cust_trx_id  IN NUMBER)
RETURN NUMBER IS

BEGIN

	RETURN(NVL(OE_Payments_Util.Get_Uninvoiced_Commitment_Bal(p_init_cust_trx_id), 0));

END get_com_amt_uninvoiced ;

/*=============================================================================
|| PRIVATE FUNCTION     get_commit_this_invoice
||
|| DESCRIPTION          This function returns amount for this invoice
||
|| ARGUMENTS 		p_customer_trx_id
||
|| NOTE
||   This function simulates the query Q_Commitment_Adjustment in RAXINV.rdf.
||
||  MODIFICATION HISTORY
||      23-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_commit_this_invoice(p_customer_trx_id  IN NUMBER)
RETURN number IS

commit_this_invoice  number := 0 ;

BEGIN

	SELECT SUM(Amount)
	INTO   commit_this_invoice
	FROM   ar_adjustments
	WHERE  adjustment_type = 'C'
	       AND  ( ((customer_trx_id = p_customer_trx_id )
			   AND (subsequent_trx_id is null))
      		       OR  subsequent_trx_id = p_customer_trx_id) ;

	return( commit_this_invoice ) ;

END get_commit_this_invoice ;

/*=============================================================================
|| PRIVATE FUNCTION     get_com_balance
||
|| DESCRIPTION          Returns the commitment balance
||
|| ARGUMENTS 		p_customer_trx_id
||			p_commit_parent_type
||			p_init_cust_trx_id
||
|| NOTE
||   This function simulates the report local function
||   commitments in RAXINV.rdf
||
||  MODIFICATION HISTORY
||      22-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_com_balance(
		p_original_amount    IN NUMBER,
		p_trx_type 	     IN VARCHAR2,
		p_init_cust_trx_id   IN NUMBER)
RETURN NUMBER IS

	commit_adjustments        number := 0;
   	commit_total_activity     number := 0;
	commit_this_invoice	  number := 0;
	commit_balance	  	  number := 0;

BEGIN

      IF p_trx_type = 'DEP'

      THEN
           /*-------------------------------------------+
            | If the commitment type is for a DEPOSIT   |
            +-------------------------------------------*/

           SELECT NVL(SUM(adj.amount),0)
             INTO commit_adjustments
             FROM ra_customer_trx 		trx,
                  ra_cust_trx_types 		type,
                  ar_adjustments 		adj
            WHERE trx.cust_trx_type_id 		= type.cust_trx_type_id
              AND type.type in ('INV', 'CM')
              AND trx.complete_flag		='Y'
              AND trx.initial_customer_trx_id 	= p_init_cust_trx_id
              AND adj.customer_trx_id 	= DECODE(type.type,
                               'INV', trx.customer_trx_id,
                               'CM', trx.previous_customer_trx_id)
              AND NVL(adj.subsequent_trx_id,-111) = DECODE(type.type,
                               'INV',-111,
				'CM',trx.customer_trx_id)
              AND adj.adjustment_type 		= 'C';

           SELECT NVL(SUM(line.extended_amount),0)
           INTO   commit_total_activity
           FROM   ra_customer_trx trx,
                  ra_cust_trx_types type,
                  ra_customer_trx_lines line
           WHERE  trx.cust_trx_type_id = type.cust_trx_type_id
             AND  trx.customer_trx_id = line.customer_trx_id
             AND    type.type = 'CM'
             AND    trx.complete_flag = 'Y'
             AND    trx.previous_customer_trx_id = p_init_cust_trx_id;

      ELSIF p_trx_type = 'GUAR'

      THEN

           /*----------------------------------------------------------+
            | If the commitment type is for a GUARANTEE                |
            +----------------------------------------------------------*/

           SELECT -1 * (NVL(SUM(amount_line_items_original), 0) -
                        NVL(SUM(amount_line_items_remaining), 0))
           INTO   commit_total_activity
           FROM   ar_payment_schedules
           WHERE  customer_trx_id = p_init_cust_trx_id;

     ELSE commit_total_activity := 0;

     END IF;

           /*----------------------------------------------------------+
            | commit_total_activity is including commit_this amount    |
            +----------------------------------------------------------*/

     commit_total_activity := commit_total_activity+commit_adjustments;

           /*----------------------------------------------------------+
            | Now add this negetive total_activity with original_amount|
	    | to get the commit_balance				       |
            +----------------------------------------------------------*/

     commit_balance := commit_total_activity + p_original_amount ;

     return( commit_balance ) ;

END get_com_balance ;

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
		p_term_count	    	 IN NUMBER,
		p_term_sequence_number   IN NUMBER,
		p_printing_count   	 IN NUMBER,
		p_printing_original_date IN DATE)  IS
BEGIN

   IF
	p_choice <> 'ADJ'

   THEN

     /* 4188835 - freeze for tax if printing columns updated */
     IF NVL(p_printing_count, 0) = 0
     THEN
        /* This is the first run for this one -- freeze it */
        arp_etax_util.global_document_update(p_customer_trx_id,
                                             null,
                                             'PRINT');
     END IF;

	UPDATE ra_customer_trx
	SET printing_pending =
	      decode (p_trx_type, 'CM', 'N',
	        decode (p_term_count,
		    greatest(nvl(last_printed_sequence_num,0),
                                      p_term_sequence_number), 'N',
                                                         NULL, 'N',
                                                            1, 'N',
                                                            0, 'N',
                                                                'Y')),
      	   printing_count          = decode(p_printing_count,
					      NULL, 0,
                                                   p_printing_count) + 1,
           printing_last_printed  = SYSDATE,
           printing_original_date = decode(p_printing_count, 0, SYSDATE,
                                      p_printing_original_date),
           last_printed_sequence_num =
        		decode(p_term_count,NULL,NULL,
               		     greatest(nvl(last_printed_sequence_num,0),
               				p_term_sequence_number))
  	WHERE customer_trx_id = p_customer_trx_id;

   END IF ;
END update_customer_trx ;

/*=============================================================================
|| PRIVATE FUNCTION     get_taxyn
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
return VARCHAR2 IS

CURSOR  sel_taxyn( line_id in number ) IS
        SELECT 'x' from dual where exists
         ( SELECT 'x'
           FROM   ra_customer_trx_lines l
           WHERE  l.link_to_cust_trx_line_id = line_id
           AND    l.line_type = 'TAX'
           AND    l.extended_amount <> 0 );

l_taxyn		varchar2(80);
dummy 		varchar2(2);

BEGIN

   OPEN sel_taxyn( p_customer_trx_line_id );
   FETCH sel_taxyn into dummy;
   IF sel_taxyn%FOUND

   THEN

	SELECT meaning
	INTO   l_taxyn
	FROM   ar_lookups
	WHERE  lookup_type = 'YES/NO'
        AND    lookup_code = 'Y' ;

   ELSE

        SELECT meaning
	INTO   l_taxyn
	FROM   ar_lookups
	WHERE  lookup_type = 'YES/NO'
        AND    lookup_code = 'N' ;

   END IF;

   CLOSE sel_taxyn;
   return(l_taxyn);

END get_taxyn ;

/*=============================================================================
|| PRIVATE FUNCTION     get_remit_to_given_bill_to
||
|| DESCRIPTION          This function implements the report local function
||			get_remit_to_given_bill_to in RAXINV.rdf
||
||
|| ARGUMENTS 		p_bill_to_site_use_id
||
|| FUNCTION CALL
||
|| RETURN  		remit_address_id
||
|| NOTE
||
||  MODIFICATION HISTORY
||      29-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_remit_to_given_bill_to( p_bill_to_site_use_id in number )
RETURN NUMBER IS

CURSOR  remit_derive( inv_country 	IN varchar2,
                      inv_state 	IN varchar2 ,
                      inv_postal_code 	IN varchar2) IS

SELECT rt.address_id
  FROM hz_cust_acct_sites acct_site,
       hz_party_sites party_site,
       hz_locations loc,
       ra_remit_tos 	rt
 WHERE acct_site.cust_acct_site_id = rt.address_id
   AND acct_site.party_site_id = party_site.party_site_id
   AND loc.location_id = party_site.location_id
   AND nvl(rt.status,'A') = 'A'
   AND nvl(acct_site.status, 'A') = 'A'
   AND (nvl(rt.state, inv_state)= inv_state
        OR
        (inv_state IS NULL AND
         rt.state  IS NULL))
   AND ((inv_postal_code between
                rt.postal_code_low and rt.postal_code_high)
        OR
        (rt.postal_code_high IS NULL and rt.postal_code_low IS NULL))
   AND rt.country = inv_country
ORDER BY rt.postal_code_low,
         rt.postal_code_high,
         rt.state,
         loc.address1,
         loc.address2;



CURSOR  address( bill_site_use_id IN number ) is
        SELECT loc.state,
               loc.country,
               loc.postal_code
        FROM hz_cust_acct_sites acct_site,
             hz_party_sites party_site,
             hz_locations loc,
             hz_cust_site_uses site_uses
        WHERE acct_site.cust_acct_site_id  = site_uses.cust_acct_site_id
        AND   site_uses.site_use_id = bill_site_use_id
        and   acct_site.party_site_id = party_site.party_site_id
        and   loc.location_id = party_site.location_id;

        inv_state 		VARCHAR2(60);
        inv_country 		VARCHAR2(60);
        inv_postal_code 	VARCHAR2(60);
        remit_address_id 	NUMBER;
        d 			varchar2(240);

BEGIN

    OPEN address( p_bill_to_site_use_id );
    FETCH address into inv_state,
                       inv_country,
                       inv_postal_code;


    IF address%NOTFOUND

    THEN

       /* No Default Remit to Address can be found, use the default */

       inv_state := 'DEFAULT';
       inv_country := 'DEFAULT';
       inv_postal_code := null;

    END IF;

    CLOSE address;

    OPEN remit_derive( inv_country, inv_state, inv_postal_code );
    FETCH remit_derive into remit_address_id;


    IF remit_derive%NOTFOUND

    THEN

       CLOSE remit_derive;
       OPEN remit_derive( 'DEFAULT', inv_state, inv_postal_code );
       FETCH remit_derive into remit_address_id;

       IF remit_derive%NOTFOUND

       THEN

          CLOSE remit_derive;
          OPEN remit_derive( 'DEFAULT', inv_state, '' );
          FETCH remit_derive into remit_address_id;

          IF remit_derive%notfound

          THEN

             CLOSE remit_derive;
             OPEN remit_derive( 'DEFAULT', 'DEFAULT', '' );
             FETCH remit_derive into remit_address_id;

          END IF;

       END IF;

   END IF;

   CLOSE remit_derive;
   RETURN( remit_address_id );

END get_remit_to_given_bill_to;


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
|| NOTE			THis function implements REMIT_TO_CONTROL_IDformula
||                      of RAXINV.rdf
||
||  MODIFICATION HISTORY
||      29-MAY-97  	Ashim K Dey      Created
=============================================================================*/

FUNCTION get_remit_address_id(
  	p_remit_to_address_id 		IN NUMBER,
  	p_previous_customer_trx_id 	IN NUMBER,
  	p_trx_type    	      		IN VARCHAR2,
	p_bill_to_site_use_id 		IN NUMBER )
RETURN VARCHAR2 IS

l_remit_to_address_id 	number;

BEGIN

  l_remit_to_address_id := p_remit_to_address_id;

  IF
	( (l_remit_to_address_id IS NULL) AND
       	  (p_trx_type = 'CM') AND
       	  (p_previous_customer_trx_id IS NOT NULL)
     	)

  THEN
    /* ra_customer_trx.remit_to_address_id is not populated
     for CM, need to get it from the invoice. */

    SELECT remit_to_address_id
    INTO   l_remit_to_address_id
    FROM   ra_customer_trx
    WHERE   customer_trx_id = p_previous_customer_trx_id;

  END IF;

  IF

	l_remit_to_address_id IS NULL

  THEN
  	RETURN(
     		AR_INVOICE_SQL_FUNC_PUB.get_remit_to_given_bill_to(
				p_bill_to_site_use_id )
	       ) ;
  ELSE

	RETURN(l_remit_to_address_id );

  END IF;

END get_remit_address_id;

END AR_INVOICE_SQL_FUNC_PUB ;

/
