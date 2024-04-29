--------------------------------------------------------
--  DDL for Package Body ARP_TEST_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TEST_TAX" as
/* $Header: ARTSTTXB.pls 115.6 2003/10/10 14:29:28 mraymond ship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |    update_header                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Recalculates tax for the given transaction, returning true if          |
 |    the new tax amount is the same as the old tax amount.                  |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Nov-95  Nigel Smith         Created                                |
 |                                                                           |
 +===========================================================================*/

 PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

function update_header( p_customer_trx_id IN number, p_msg out NOCOPY varchar2 ) return BOOLEAN IS

   l_old_trx_rec	 ra_customer_trx%rowtype;
   l_some_trx_rec        ra_customer_trx%rowtype;
   l_some_trx_id         ra_customer_trx.customer_trx_id%type;
   l_some_commitment_rec arp_process_commitment.commitment_rec_type;
   l_some_result         BOOLEAN;

   l_some_gl_date        ra_cust_trx_line_gl_dist.gl_date%type;
   l_some_trx_amount     ra_cust_trx_line_gl_dist.amount%type;
   l_some_ictli          ra_customer_trx_lines.initial_customer_trx_line_id%type;
   l_some_in_use_before  varchar2(1);
   l_some_in_use_after   varchar2(1);

   l_old_tax_amount	  number;
   l_new_tax_amount       number;
   l_old_tax_lines	  number;
   l_new_tax_lines	  number;
   l_min_cust_trx_line_id number;
   l_max_cust_trx_line_id number;
   l_some_dispute_amt 	  number := NULL;
   l_some_dispute_date 	  date := NULL;
   l_status 		  varchar2(100);
   l_msg 		  varchar2(2000);

begin

  arp_ct_pkg.set_to_dummy(l_some_trx_rec);
  l_some_trx_id := p_customer_trx_id;

  select sum(extended_amount), count(l.customer_trx_line_id), max(l.customer_trx_line_id)
  into   l_old_tax_amount, l_old_tax_lines, l_max_cust_trx_line_id
  from   ra_customer_trx_lines l
  where  l.customer_trx_id = l_some_trx_id
    and  line_type = 'TAX'
    and  l.autotax = 'Y'
    and  l.customer_trx_id = p_customer_trx_id
    and  l.customer_trx_line_id in ( select customer_trx_line_id from ra_cust_trx_line_gl_dist
				     where customer_trx_line_id = l.customer_trx_line_id );



  arp_ct_pkg.fetch_p(l_old_trx_rec, l_some_trx_id);

  arp_test_tax.test_description := l_old_trx_rec.trx_number;

  arp_process_header.update_header(
				'TEST',
				1,
				l_some_trx_rec,
				l_some_trx_id,
                                l_some_trx_amount,
				'INV',
				l_some_gl_date,
                                l_some_ictli,
				l_some_commitment_rec,
				'Y',
				l_some_in_use_before,
				TRUE,
				FALSE,
				l_some_dispute_amt,
				l_some_dispute_date,
			        l_status );

  /*------------------------------------------------+
   |  Verify if tax 'soft error' was raised.        |
   +------------------------------------------------*/
  IF ( nvl(l_status,'IGNORE') = 'AR_TAX_EXCEPTION' ) THEN
    fnd_message.retrieve( l_msg );
    p_msg := NVL( l_msg, sqlerrm );
    return(FALSE);
  END IF;

  /*------------------------------------------------+
   |  Verify that all columns were updated properly |
   +------------------------------------------------*/

  select sum(extended_amount), count(l.customer_trx_line_id), min(l.customer_trx_line_id)
  into   l_new_tax_amount, l_new_tax_lines, l_min_cust_trx_line_id
  from   ra_customer_trx_lines l
  where  l.customer_trx_id = l_some_trx_id
    and  l.line_type = 'TAX'
    and  l.autotax = 'Y'
    and  l.customer_trx_id = p_customer_trx_id
    and  l.customer_trx_line_id in ( select customer_trx_line_id from ra_cust_trx_line_gl_dist
				     where customer_trx_line_id = l.customer_trx_line_id );

  IF NVL(l_new_tax_amount,-1) = NVL(l_old_tax_amount,-1) AND
     NVL(l_new_tax_lines,-1) =  NVL(l_old_tax_lines,-1)  AND
     NVL(l_min_cust_trx_line_id,-1) > NVL(l_max_cust_trx_line_id,-2)
  THEN
     /*--------------------------------------------------------------------------+
      |  Check Autoaccounting for for all tax lines associated with this invoice |
      +--------------------------------------------------------------------------*/
     l_some_result := check_dist( l_some_trx_id );
     l_some_result := TRUE; /* Not Checked for JAN CD Release */
  ELSE
     p_msg := 'Amounts(' || l_old_tax_amount ||','||l_new_tax_amount||') ' ||
	      'Tax Lines( ' || l_old_tax_lines || ','||l_new_tax_lines||') ' ||
	      'Line IDs( ' || l_max_cust_trx_line_id || ', ' || l_min_cust_trx_line_id || ' )' ;
     l_some_result := FALSE;
  END IF;
  return( l_some_result );


exception
   when others
   then
          fnd_message.retrieve( l_msg );
	  p_msg := NVL( l_msg, sqlerrm );
    	  return(false);


END update_header;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    update_all_headers                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calls update_header for every transaction that has                     |
 |    One and only invoice automatically generated tax line per invoice line |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_ct_pkg.fetch_p                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Nov-95  Nigel Smith         Created                                |
 |     10-Mar-01  Debbie Jancis       modified for tca uptake.  Removed all  |
 |			              references of ar/ra customer tables    |
 |				      and replaced with hz counterparts.     |
 +===========================================================================*/


procedure update_all_headers( p_tax_line_count in number default NULL ) IS

cursor c_trx is
select t.customer_trx_id,
	        t.trx_number,
		t.trx_date,
		count( tax.customer_trx_line_id) count_tax
from   ra_customer_trx t,
       ra_cust_trx_types y,
       ra_customer_trx p,
       ra_customer_trx_lines l,
       ra_customer_trx_lines tax,
       ar_vat_tax            vat,
       hz_cust_acct_sites    sa,
       hz_cust_site_uses          sus
where  t.customer_trx_id = l.customer_trx_id
and    tax.link_to_cust_trx_line_id = l.customer_trx_line_id
and    tax.vat_tax_id = vat.vat_tax_id(+)
and    t.previous_customer_trx_id = p.customer_trx_id(+)
and    t.cust_trx_type_id = y.cust_trx_type_id
and    nvl( t.ship_to_site_use_id, t.bill_to_site_use_id) = sus.site_use_id
and    sa.cust_acct_site_id = sus.cust_acct_site_id
and    t.customer_trx_id not in ( select customer_trx_id from ra_customer_trx_lines where line_type = 'TAX'
				  and nvl(autotax,'N') = 'N' and customer_trx_id = t.customer_trx_id )
group by t.customer_trx_id, t.trx_number, t.trx_date
order by t.trx_number;

l_trx_id NUMBER;
l_pass   BOOLEAN;
timecost varchar2(30);
starttime    date;
msg varchar2(2000);
row number := 0;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('update_all_headers: ' ||  'arp_test_tax - ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI') );
  END IF;
    FOR hdr in c_trx
    LOOP
      row := row +1;

      EXIT WHEN  row > p_tax_line_count;

      starttime := sysdate;
      l_pass := update_header( hdr.customer_trx_id, msg );
      timecost := null;

      IF l_pass
      THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('update_all_headers: ' ||  'arp_test_tax - ' || rpad(hdr.trx_number||'-'||hdr.count_tax,30, '.') || ' ' || 'Pass ' || to_char(sysdate, 'HH24:MI:SS') );
  END IF;
      ELSE
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('update_all_headers: ' ||  'arp_test_tax - ' || rpad(hdr.trx_number||'-'||hdr.count_tax,30, '.') || ' ' || 'Fail ' ||
				 to_char(sysdate, 'HH24:MI:SS') || ' ' || substr(msg,1,100) );
      END IF;
      END IF;

    END LOOP;
END update_all_headers;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_dist                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Check accouting for tax, will return FALSE if any of the accounting    |
 |    is incorrect for a given transaction.                                  |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Nov-95  Nigel Smith         Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION check_dist( p_customer_trx_id IN NUMBER ) RETURN BOOLEAN IS

l_pass BOOLEAN := TRUE;

cursor c_tax( p_customer_trx_id IN NUMBER ) IS

       /* Search for any tax lines where the tax accounting is not
	  equal to the invoice amounts */

       SELECT l.customer_trx_line_id   customer_trx_line_id,
              l.extended_amount	       extended_amount,
	      sum(d.amount)            amount,
	      sum(d.acctd_amount)      acctd_amount,
	      sum(decode( t.invoice_currency_code, 'USD', 1, t.exchange_rate )*l.extended_amount )
				       trx_acctd_amount,
	      sum(d.percent)           percent,
	      t.invoice_currency_code  invoice_currency_code
        FROM  ra_customer_trx_lines l,
	      ra_cust_trx_line_gl_dist d,
              ra_customer_trx t
       WHERE  l.customer_trx_line_id = d.customer_trx_line_id
         AND  l.customer_trx_id = p_customer_trx_id
         AND  l.customer_trx_id = t.customer_trx_id
         AND  d.account_class = 'TAX'
         AND  d.acctd_amount IS NOT NULL
         AND  d.amount IS NOT NULL
    GROUP BY  l.customer_trx_id, t.invoice_currency_code, t.exchange_rate, l.customer_trx_line_id, l.extended_amount
      HAVING  sum(d.amount) <> l.extended_amount
          OR  round(sum(d.acctd_amount)) <>
		round(decode( t.invoice_currency_code, 'USD', 1, t.exchange_rate )*l.extended_amount)

     UNION

     /* Search for any tax accounting, where the tax accounting is without
        a parent tax line within this transaction.
     */

     SELECT   d.customer_trx_line_id    customer_trx_line_id,
	      to_number(null)		extended_amount,
	      sum(d.amount)		amount,
	      sum(d.acctd_amount)	acctd_amount,
	      to_number(NULL)		trx_acctd_amount,
	      sum(d.percent)		percent,
	      to_char(NULL)             invoice_currency_code
     FROM     ra_cust_trx_line_gl_dist d
     WHERE    d.customer_trx_id = p_customer_trx_id
     AND      d.account_set_flag = 'N'
     AND      not exists ( select 'x' from ra_customer_trx_lines l
			   where l.customer_trx_id = d.customer_trx_id )
     GROUP BY d.customer_trx_line_id, d.customer_trx_id;


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( 'arp_test_tax.check_dist( ' || p_customer_trx_id || ' )+');
   END IF;

   FOR t in c_tax(p_customer_trx_id)
   LOOP
      l_pass := FALSE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('check_dist: ' ||        t.invoice_currency_code || ' ' ||
			    t.customer_trx_line_id || ' ' ||
			    t.extended_amount || ' ' ||
			    t.amount || ' ' ||
			    t.acctd_amount || ' ' ||
			    t.trx_acctd_amount || ' ' ||
			    t.percent || '%' );
      END IF;
      EXIT WHEN NOT l_pass;
   END LOOP;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( 'arp_test_tax.check_dist()-');
   END IF;

   return(l_pass);

END check_dist;

END arp_test_tax;

/
