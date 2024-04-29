--------------------------------------------------------
--  DDL for Package Body ARP_CTLGD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CTLGD_PKG" AS
/* $Header: ARTILGDB.pls 120.15.12010000.5 2010/04/29 05:43:01 npanchak ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

  pg_msg_level_debug    binary_integer;

  /*---------------------------------------------------------------+
   |  Package global variables to hold the parsed update cursors.  |
   |  This allows the cursors to be reused without being reparsed. |
   +---------------------------------------------------------------*/

  pg_cursor1  integer := '';
  pg_cursor2  integer := '';
  pg_cursor3  integer := '';
  pg_cursor4  integer := '';

  /*-------------------------------------+
   |  WHO column values from FND_GLOBAL  |
   +-------------------------------------*/

  pg_user_id          number;
  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_dist_rec							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_dist_rec					     |
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
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_dist_rec( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype)
                        IS


BEGIN

   arp_util.debug('arp_ctlgd_pkg.display_dist_rec()+');

   arp_util.debug('************** Dump of ra_cust_trx_line_gl_dist record '||
                  '**************');

   arp_util.debug('cust_trx_line_gl_dist_id:  '
                                      || p_dist_rec.cust_trx_line_gl_dist_id);
   arp_util.debug('customer_trx_id:  '      || p_dist_rec.customer_trx_id);
   arp_util.debug('customer_trx_line_id: ' || p_dist_rec.customer_trx_line_id);
   arp_util.debug('cust_trx_line_salesrep_id:  '
                                      || p_dist_rec.cust_trx_line_salesrep_id);
   arp_util.debug('account_class:  '  || p_dist_rec.account_class);
   arp_util.debug('percent:  '        || p_dist_rec.percent);
   arp_util.debug('amount:  '         || p_dist_rec.amount);
   arp_util.debug('acctd_amount:  '   || p_dist_rec.acctd_amount);
   arp_util.debug('gl_date:  '        || p_dist_rec.gl_date);
   arp_util.debug('original_gl_date:  ' || p_dist_rec.original_gl_date);
   arp_util.debug('gl_posted_date:  '      || p_dist_rec.gl_posted_date);
   arp_util.debug('code_combination_id:  '  || p_dist_rec.code_combination_id);
   arp_util.debug('concatenated_segments:  '
                                          || p_dist_rec.concatenated_segments);
   arp_util.debug('collected_tax_ccid:  '  || p_dist_rec.collected_tax_ccid);
   arp_util.debug('collected_tax_concat_seg:  '
				  || p_dist_rec.collected_tax_concat_seg);
   arp_util.debug('comments:  '           || p_dist_rec.comments);
   arp_util.debug('account_set_flag:  '   || p_dist_rec.account_set_flag);
   arp_util.debug('latest_rec_flag:  '    || p_dist_rec.latest_rec_flag);
   arp_util.debug('rec_offset_flag:  '    || p_dist_rec.rec_offset_flag);
   arp_util.debug('ussgl_transaction_code:  '
                                      || p_dist_rec.ussgl_transaction_code);
   arp_util.debug('ussgl_transaction_code_context:  '
                                || p_dist_rec.ussgl_transaction_code_context);
   arp_util.debug('attribute_category:  ' || p_dist_rec.attribute_category);
   arp_util.debug('attribute1:  '         || p_dist_rec.attribute1);
   arp_util.debug('attribute2:  '         || p_dist_rec.attribute2);
   arp_util.debug('attribute3:  '         || p_dist_rec.attribute3);
   arp_util.debug('attribute4:  '         || p_dist_rec.attribute4);
   arp_util.debug('attribute5:  '         || p_dist_rec.attribute5);
   arp_util.debug('attribute6:  '         || p_dist_rec.attribute6);
   arp_util.debug('attribute7:  '         || p_dist_rec.attribute7);
   arp_util.debug('attribute8:  '         || p_dist_rec.attribute8);
   arp_util.debug('attribute9:  '         || p_dist_rec.attribute9);
   arp_util.debug('attribute10:  '        || p_dist_rec.attribute10);
   arp_util.debug('attribute11:  '        || p_dist_rec.attribute11);
   arp_util.debug('attribute12:  '        || p_dist_rec.attribute12);
   arp_util.debug('attribute13:  '        || p_dist_rec.attribute13);
   arp_util.debug('attribute14:  '        || p_dist_rec.attribute14);
   arp_util.debug('attribute15:  '        || p_dist_rec.attribute15);
   arp_util.debug('set_of_books_id:  '    || p_dist_rec.set_of_books_id);
   arp_util.debug('posting_control_id:  ' || p_dist_rec.posting_control_id);
   arp_util.debug('last_updated_by:  '    || p_dist_rec.last_updated_by);
   arp_util.debug('created_by:  '         || p_dist_rec.created_by);
   arp_util.debug('last_update_login:  '  || p_dist_rec.last_update_login);
   arp_util.debug('program_application_id:  '
                                        || p_dist_rec.program_application_id);
   arp_util.debug('program_id:  '       || p_dist_rec.program_id);
   arp_util.debug('rounding_correction_flag:'|| p_dist_rec.rounding_correction_flag);
   arp_util.debug('************** End ra_cust_trx_line_gl_dist record ' ||
                  '**************');

   arp_util.debug('arp_ctlgd_pkg.display_dist_rec()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.display_dist_rec()');
   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_dist_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_cust_trx_line_gl_dist_id			     |
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
 |     13-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_dist_p(  p_cust_trx_line_gl_dist_id IN
 		   ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type)
                   IS

   l_dist_rec   ra_cust_trx_line_gl_dist%rowtype;

BEGIN

   arp_util.debug('arp_ctlgd_pkg.display_dist_p()+');

   arp_ctlgd_pkg.fetch_p(l_dist_rec, p_cust_trx_line_gl_dist_id);

   arp_ctlgd_pkg.display_dist_rec(l_dist_rec);

   arp_util.debug('arp_ctlgd_pkg.display_dist_p()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.display_dist_p()');
   RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_dist_f_ctls_id						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_cust_trx_line_salesrep_id			     |
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
 |     13-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_dist_f_ctls_id(  p_cust_trx_line_salesrep_id IN
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type)
                   IS

   l_cust_trx_line_gl_dist_id
                       ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;

   CURSOR srep_cursor IS
          SELECT *
          FROM   ra_cust_trx_line_gl_dist
          WHERE  cust_trx_line_salesrep_id = p_cust_trx_line_salesrep_id
          ORDER BY cust_trx_line_gl_dist_id;


BEGIN

   arp_util.debug('arp_ctlgd_pkg.display_dist_f_ctls_id()+');

   arp_util.debug('=====================================================' ||
                  '==========================');
   arp_util.debug('========== ' ||
                  ' Dump of ra_cust_trx_line_gl_dist records for ctls: '||
		  to_char( p_cust_trx_line_salesrep_id ) || ' ' ||
                  '==========');

   FOR l_dist_rec IN srep_cursor LOOP
       arp_ctlgd_pkg.display_dist_p(l_dist_rec.cust_trx_line_gl_dist_id);
   END LOOP;

   arp_util.debug('====== End ' ||
                  'Dump of ra_cust_trx_line_gl_dist records for ctls: '||
		  to_char( p_cust_trx_line_salesrep_id ) || ' ' ||
                  '=======');
   arp_util.debug('=====================================================' ||
                  '==========================');

   arp_util.debug('arp_ctlgd_pkg.display_dist_f_ctls_id()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.display_dist_f_ctls_id()');
   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_dist_f_ct_id						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id					     |
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
 |     17-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_dist_f_ct_id( p_customer_trx_id IN
                                        ra_customer_trx.customer_trx_id%type)
                   IS

   l_cust_trx_line_gl_dist_id
                       ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;

   CURSOR srep_cursor IS
          SELECT *
          FROM   ra_cust_trx_line_gl_dist
          WHERE  customer_trx_id = p_customer_trx_id
          ORDER BY cust_trx_line_gl_dist_id;


BEGIN

   arp_util.debug('arp_ctlgd_pkg.display_dist_f_ct_id()+');

   arp_util.debug('=====================================================' ||
                  '==========================');
   arp_util.debug('========== ' ||
                  ' Dump of ra_cust_trx_line_gl_dist records for ctid: '||
		  to_char( p_customer_trx_id ) || ' ' ||
                  '==========');

   FOR l_dist_rec IN srep_cursor LOOP
       arp_ctlgd_pkg.display_dist_p(l_dist_rec.cust_trx_line_gl_dist_id);
   END LOOP;

   arp_util.debug('====== End ' ||
                  'Dump of ra_cust_trx_line_gl_dist records for ctid: '||
		  to_char( p_customer_trx_id ) || ' ' ||
                  '=======');
   arp_util.debug('=====================================================' ||
                  '==========================');

   arp_util.debug('arp_ctlgd_pkg.display_dist_f_ct_id()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.display_dist_f_ct_id()');
   RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_dist_f_ctl_id						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_line_id				     |
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
 |     04-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_dist_f_ctl_id( p_customer_trx_line_id IN
                               ra_customer_trx_lines.customer_trx_line_id%type)
                   IS

   l_cust_trx_line_gl_dist_id
                       ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;

   CURSOR dist_cursor IS
          SELECT *
          FROM   ra_cust_trx_line_gl_dist
          WHERE  customer_trx_line_id = p_customer_trx_line_id
          ORDER BY cust_trx_line_gl_dist_id;


BEGIN

   arp_util.debug('arp_ctlgd_pkg.display_dist_f_ctl_id()+');

   arp_util.debug('=====================================================' ||
                  '==========================');
   arp_util.debug('========== ' ||
                  ' Dump of ra_cust_trx_line_gl_dist records for ctlid: '||
		  to_char( p_customer_trx_line_id ) || ' ' ||
                  '==========');

   FOR l_dist_rec IN dist_cursor LOOP
       arp_ctlgd_pkg.display_dist_p(l_dist_rec.cust_trx_line_gl_dist_id);
   END LOOP;

   arp_util.debug('====== End ' ||
                  'Dump of ra_cust_trx_line_gl_dist records for ctlid: '||
		  to_char( p_customer_trx_line_id ) || ' ' ||
                  '=======');
   arp_util.debug('=====================================================' ||
                  '==========================');

   arp_util.debug('arp_ctlgd_pkg.display_dist_f_ctl_id()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.display_dist_f_ctl_id()');
   RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_number_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns the value of the AR_NUMBER DUMMY constant.      |
 |    									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : value of AR_NUMBER_DUMMY                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number IS

BEGIN

    arp_util.debug('arp_ctgd_pkg.get_number_dummy()+');

    arp_util.debug('arp_ctgd_pkg.get_number_dummy()-');

    return(AR_NUMBER_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctgd_pkg.get_number_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    merge_dist_recs							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Merges the changed columns in p_new_dist_rec into the same columns     |
 |    p_old_dist_rec and puts the result into p_out_dist_rec. Columns that   |
 |    contain the dummy values are not changed.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_old_dist_rec 					     |
 |		      p_new_dist_rec 					     |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |		      p_out_dist_rec 					     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE merge_dist_recs(
                         p_old_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                         p_new_dist_rec IN
                                          ra_cust_trx_line_gl_dist%rowtype,
                         p_out_dist_rec IN OUT NOCOPY
                                          ra_cust_trx_line_gl_dist%rowtype
                         ) IS

BEGIN

    arp_util.debug('arp_ctls_pkg.merge_dist_recs()+');


    IF     ( p_new_dist_rec.cust_trx_line_gl_dist_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.cust_trx_line_gl_dist_id :=
                                       p_old_dist_rec.cust_trx_line_gl_dist_id;
    ELSE   p_out_dist_rec.cust_trx_line_gl_dist_id :=
                                       p_new_dist_rec.cust_trx_line_gl_dist_id;
    END IF;

    IF     ( p_new_dist_rec.customer_trx_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.customer_trx_id := p_old_dist_rec.customer_trx_id;
    ELSE   p_out_dist_rec.customer_trx_id := p_new_dist_rec.customer_trx_id;
    END IF;

    IF     ( p_new_dist_rec.customer_trx_line_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.customer_trx_line_id :=
                                           p_old_dist_rec.customer_trx_line_id;
    ELSE   p_out_dist_rec.customer_trx_line_id :=
                                           p_new_dist_rec.customer_trx_line_id;
    END IF;

    IF     ( p_new_dist_rec.cust_trx_line_salesrep_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.cust_trx_line_salesrep_id :=
                                      p_old_dist_rec.cust_trx_line_salesrep_id;
    ELSE   p_out_dist_rec.cust_trx_line_salesrep_id :=
                                      p_new_dist_rec.cust_trx_line_salesrep_id;
    END IF;

    IF     ( p_new_dist_rec.account_class = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.account_class := p_old_dist_rec.account_class;
    ELSE   p_out_dist_rec.account_class := p_new_dist_rec.account_class;
    END IF;

    IF     ( p_new_dist_rec.percent = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.percent := p_old_dist_rec.percent;
    ELSE   p_out_dist_rec.percent := p_new_dist_rec.percent;
    END IF;

    IF     ( p_new_dist_rec.amount = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.amount := p_old_dist_rec.amount;
    ELSE   p_out_dist_rec.amount := p_new_dist_rec.amount;
    END IF;

    IF     ( p_new_dist_rec.acctd_amount = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.acctd_amount := p_old_dist_rec.acctd_amount;
    ELSE   p_out_dist_rec.acctd_amount := p_new_dist_rec.acctd_amount;
    END IF;

    IF     ( p_new_dist_rec.gl_date = AR_DATE_DUMMY )
    THEN   p_out_dist_rec.gl_date := p_old_dist_rec.gl_date;
    ELSE   p_out_dist_rec.gl_date := p_new_dist_rec.gl_date;
    END IF;

    IF     ( p_new_dist_rec.original_gl_date = AR_DATE_DUMMY )
    THEN   p_out_dist_rec.original_gl_date := p_old_dist_rec.original_gl_date;
    ELSE   p_out_dist_rec.original_gl_date := p_new_dist_rec.original_gl_date;
    END IF;

    IF     ( p_new_dist_rec.gl_posted_date = AR_DATE_DUMMY )
    THEN   p_out_dist_rec.gl_posted_date := p_old_dist_rec.gl_posted_date;
    ELSE   p_out_dist_rec.gl_posted_date := p_new_dist_rec.gl_posted_date;
    END IF;

    IF     ( p_new_dist_rec.code_combination_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.code_combination_id :=
                                           p_old_dist_rec.code_combination_id;
    ELSE   p_out_dist_rec.code_combination_id :=
                                           p_new_dist_rec.code_combination_id;
    END IF;

    IF     ( p_new_dist_rec.concatenated_segments = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.concatenated_segments :=
                                          p_old_dist_rec.concatenated_segments;
    ELSE   p_out_dist_rec.concatenated_segments :=
                                          p_new_dist_rec.concatenated_segments;
    END IF;

    IF     ( p_new_dist_rec.collected_tax_ccid = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.collected_tax_ccid :=
                                           p_old_dist_rec.collected_tax_ccid;
    ELSE   p_out_dist_rec.collected_tax_ccid :=
                                           p_new_dist_rec.collected_tax_ccid;
    END IF;

    IF     ( p_new_dist_rec.collected_tax_concat_seg = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.collected_tax_concat_seg :=
                                          p_old_dist_rec.collected_tax_concat_seg;
    ELSE   p_out_dist_rec.collected_tax_concat_seg :=
                                          p_new_dist_rec.collected_tax_concat_seg;
    END IF;

    IF     ( p_new_dist_rec.comments = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.comments := p_old_dist_rec.comments;
    ELSE   p_out_dist_rec.comments := p_new_dist_rec.comments;
    END IF;

    IF     ( p_new_dist_rec.account_set_flag = AR_FLAG_DUMMY )
    THEN   p_out_dist_rec.account_set_flag := p_old_dist_rec.account_set_flag;
    ELSE   p_out_dist_rec.account_set_flag := p_new_dist_rec.account_set_flag;
    END IF;

    IF     ( p_new_dist_rec.latest_rec_flag = AR_FLAG_DUMMY )
    THEN   p_out_dist_rec.latest_rec_flag := p_old_dist_rec.latest_rec_flag;
    ELSE   p_out_dist_rec.latest_rec_flag := p_new_dist_rec.latest_rec_flag;
    END IF;

    /* bug 3598021 - 3630436  */
    IF     ( p_new_dist_rec.rec_offset_flag = AR_FLAG_DUMMY )
    THEN   p_out_dist_rec.rec_offset_flag := p_old_dist_rec.rec_offset_flag;
    ELSE   p_out_dist_rec.rec_offset_flag := p_new_dist_rec.rec_offset_flag;
    END IF;

    IF     ( p_new_dist_rec.rounding_correction_flag = AR_FLAG_DUMMY )
    THEN   p_out_dist_rec.rounding_correction_flag := p_old_dist_rec.rounding_correction_flag;
    ELSE   p_out_dist_rec.rounding_correction_flag := p_new_dist_rec.rounding_correction_flag;
    END IF;

    IF     ( p_new_dist_rec.ussgl_transaction_code = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.ussgl_transaction_code :=
                                         p_old_dist_rec.ussgl_transaction_code;
    ELSE   p_out_dist_rec.ussgl_transaction_code :=
                                         p_new_dist_rec.ussgl_transaction_code;
    END IF;

    IF     ( p_new_dist_rec.ussgl_transaction_code_context = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.ussgl_transaction_code_context :=
                                 p_old_dist_rec.ussgl_transaction_code_context;
    ELSE   p_out_dist_rec.ussgl_transaction_code_context :=
                                 p_new_dist_rec.ussgl_transaction_code_context;
    END IF;

    IF     ( p_new_dist_rec.attribute_category = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute_category :=
                                             p_old_dist_rec.attribute_category;
    ELSE   p_out_dist_rec.attribute_category :=
                                             p_new_dist_rec.attribute_category;
    END IF;

    IF     ( p_new_dist_rec.attribute1 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute1 := p_old_dist_rec.attribute1;
    ELSE   p_out_dist_rec.attribute1 := p_new_dist_rec.attribute1;
    END IF;

    IF     ( p_new_dist_rec.attribute2 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute2 := p_old_dist_rec.attribute2;
    ELSE   p_out_dist_rec.attribute2 := p_new_dist_rec.attribute2;
    END IF;

    IF     ( p_new_dist_rec.attribute3 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute3 := p_old_dist_rec.attribute3;
    ELSE   p_out_dist_rec.attribute3 := p_new_dist_rec.attribute3;
    END IF;

    IF     ( p_new_dist_rec.attribute4 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute4 := p_old_dist_rec.attribute4;
    ELSE   p_out_dist_rec.attribute4 := p_new_dist_rec.attribute4;
    END IF;

    IF     ( p_new_dist_rec.attribute5 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute5 := p_old_dist_rec.attribute5;
    ELSE   p_out_dist_rec.attribute5 := p_new_dist_rec.attribute5;
    END IF;

    IF     ( p_new_dist_rec.attribute6 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute6 := p_old_dist_rec.attribute6;
    ELSE   p_out_dist_rec.attribute6 := p_new_dist_rec.attribute6;
    END IF;

    IF     ( p_new_dist_rec.attribute7 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute7 := p_old_dist_rec.attribute7;
    ELSE   p_out_dist_rec.attribute7 := p_new_dist_rec.attribute7;
    END IF;

    IF     ( p_new_dist_rec.attribute8 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute8 := p_old_dist_rec.attribute8;
    ELSE   p_out_dist_rec.attribute8 := p_new_dist_rec.attribute8;
    END IF;

    IF     ( p_new_dist_rec.attribute9 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute9 := p_old_dist_rec.attribute9;
    ELSE   p_out_dist_rec.attribute9 := p_new_dist_rec.attribute9;
    END IF;

    IF     ( p_new_dist_rec.attribute10 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute10 := p_old_dist_rec.attribute10;
    ELSE   p_out_dist_rec.attribute10 := p_new_dist_rec.attribute10;
    END IF;

    IF     ( p_new_dist_rec.attribute11 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute11 := p_old_dist_rec.attribute11;
    ELSE   p_out_dist_rec.attribute11 := p_new_dist_rec.attribute11;
    END IF;

    IF     ( p_new_dist_rec.attribute12 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute12 := p_old_dist_rec.attribute12;
    ELSE   p_out_dist_rec.attribute12 := p_new_dist_rec.attribute12;
    END IF;

    IF     ( p_new_dist_rec.attribute13 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute13 := p_old_dist_rec.attribute13;
    ELSE   p_out_dist_rec.attribute13 := p_new_dist_rec.attribute13;
    END IF;

    IF     ( p_new_dist_rec.attribute14 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute14 := p_old_dist_rec.attribute14;
    ELSE   p_out_dist_rec.attribute14 := p_new_dist_rec.attribute14;
    END IF;

    IF     ( p_new_dist_rec.attribute15 = AR_TEXT_DUMMY )
    THEN   p_out_dist_rec.attribute15 := p_old_dist_rec.attribute15;
    ELSE   p_out_dist_rec.attribute15 := p_new_dist_rec.attribute15;
    END IF;

    IF     ( p_new_dist_rec.set_of_books_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.set_of_books_id := p_old_dist_rec.set_of_books_id;
    ELSE   p_out_dist_rec.set_of_books_id := p_new_dist_rec.set_of_books_id;
    END IF;

    IF     ( p_new_dist_rec.posting_control_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.posting_control_id :=
                                             p_old_dist_rec.posting_control_id;
    ELSE   p_out_dist_rec.posting_control_id :=
                                             p_new_dist_rec.posting_control_id;
    END IF;

    IF     ( p_new_dist_rec.last_update_date = AR_DATE_DUMMY )
    THEN   p_out_dist_rec.last_update_date := p_old_dist_rec.last_update_date;
    ELSE   p_out_dist_rec.last_update_date := p_new_dist_rec.last_update_date;
    END IF;

    IF     ( p_new_dist_rec.last_updated_by = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.last_updated_by := p_old_dist_rec.last_updated_by;
    ELSE   p_out_dist_rec.last_updated_by := p_new_dist_rec.last_updated_by;
    END IF;

    IF     ( p_new_dist_rec.creation_date = AR_DATE_DUMMY )
    THEN   p_out_dist_rec.creation_date := p_old_dist_rec.creation_date;
    ELSE   p_out_dist_rec.creation_date := p_new_dist_rec.creation_date;
    END IF;

    IF     ( p_new_dist_rec.created_by = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.created_by := p_old_dist_rec.created_by;
    ELSE   p_out_dist_rec.created_by := p_new_dist_rec.created_by;
    END IF;

    IF     ( p_new_dist_rec.last_update_login = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.last_update_login :=
                                              p_old_dist_rec.last_update_login;
    ELSE   p_out_dist_rec.last_update_login :=
                                              p_new_dist_rec.last_update_login;
    END IF;

    IF     ( p_new_dist_rec.program_application_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.program_application_id :=
                                         p_old_dist_rec.program_application_id;
    ELSE   p_out_dist_rec.program_application_id :=
                                         p_new_dist_rec.program_application_id;
    END IF;

    IF     ( p_new_dist_rec.program_id = AR_NUMBER_DUMMY )
    THEN   p_out_dist_rec.program_id := p_old_dist_rec.program_id;
    ELSE   p_out_dist_rec.program_id := p_new_dist_rec.program_id;
    END IF;

    IF     ( p_new_dist_rec.program_update_date = AR_DATE_DUMMY )
    THEN   p_out_dist_rec.program_update_date :=
                                            p_old_dist_rec.program_update_date;
    ELSE   p_out_dist_rec.program_update_date :=
                                            p_new_dist_rec.program_update_date;
    END IF;


    arp_util.debug('arp_ctls_pkg.merge_dist_recs()-');

EXCEPTION
  WHEN OTHERS THEN
      arp_util.debug('EXCEPTION:  merge_dist_recs.merge_dist_recs()');
      RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    bind_dist_variables                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Binds variables from the record variable to the bind variables         |
 |    in the dynamic SQL update statement.                                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_update_cursor  - ID of the update cursor             |
 |                    p_dist_rec       - ra_cust_trx_line_gl_dist record     |
 |		      p_exchange_rate					     |
 |		      p_currency_code					     |
 |		      p_precision					     |
 |		      p_mau						     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE bind_dist_variables(
                         p_update_cursor IN integer,
                         p_dist_rec      IN ra_cust_trx_line_gl_dist%rowtype,
                         p_exchange_rate IN ra_customer_trx.exchange_rate%type,
                         p_currency_code IN fnd_currencies.currency_code%type,
                         p_precision     IN fnd_currencies.precision%type,
                         p_mau           IN
                               fnd_currencies.minimum_accountable_unit%type)
          IS

BEGIN

   arp_util.debug('arp_ctlgd_pkg.bind_dist_variables()+');

  /*------------------+
   |  Dummy constants |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_flag_dummy',
                          AR_FLAG_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_number_dummy',
                          AR_NUMBER_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_date_dummy',
                          AR_DATE_DUMMY);

  /*------------------+
   |  WHO variables   |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':pg_user_id',
                          pg_user_id);

   dbms_sql.bind_variable(p_update_cursor, ':pg_login_id',
                          pg_login_id);

   dbms_sql.bind_variable(p_update_cursor, ':pg_conc_login_id',
                          pg_conc_login_id);

  /*----------------------------------------+
   |  Rounding and exchange rate variables  |
   +----------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate',
                          p_exchange_rate);

   dbms_sql.bind_variable(p_update_cursor, ':currency_code',
                          p_currency_code);

   dbms_sql.bind_variable(p_update_cursor, ':precision',
                          p_precision);

   dbms_sql.bind_variable(p_update_cursor, ':mau',
                          p_mau);

  /*----------------------------------------------+
   |  Bind variables for all columns in the table |
   +----------------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':cust_trx_line_salesrep_id',
                          p_dist_rec.cust_trx_line_salesrep_id);

   dbms_sql.bind_variable(p_update_cursor, ':cust_trx_line_gl_dist_id',
                          p_dist_rec.cust_trx_line_gl_dist_id);

   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_id',
                          p_dist_rec.customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_line_id',
                          p_dist_rec.customer_trx_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':cust_trx_line_salesrep_id',
                          p_dist_rec.cust_trx_line_salesrep_id);

   dbms_sql.bind_variable(p_update_cursor, ':account_class',
                          p_dist_rec.account_class);

   dbms_sql.bind_variable(p_update_cursor, ':percent',
                          p_dist_rec.percent);

   dbms_sql.bind_variable(p_update_cursor, ':amount',
                          p_dist_rec.amount);

   dbms_sql.bind_variable(p_update_cursor, ':acctd_amount',
                          p_dist_rec.acctd_amount);

   dbms_sql.bind_variable(p_update_cursor, ':gl_date',
                          p_dist_rec.gl_date);

   dbms_sql.bind_variable(p_update_cursor, ':original_gl_date',
                          p_dist_rec.original_gl_date);

   dbms_sql.bind_variable(p_update_cursor, ':gl_posted_date',
                          p_dist_rec.gl_posted_date);

   dbms_sql.bind_variable(p_update_cursor, ':code_combination_id',
                          p_dist_rec.code_combination_id);

   dbms_sql.bind_variable(p_update_cursor, ':concatenated_segments',
                          p_dist_rec.concatenated_segments);

   dbms_sql.bind_variable(p_update_cursor, ':collected_tax_ccid',
                          p_dist_rec.collected_tax_ccid);

   dbms_sql.bind_variable(p_update_cursor, ':collected_tax_concat_seg',
                          p_dist_rec.collected_tax_concat_seg);

   dbms_sql.bind_variable(p_update_cursor, ':comments',
                          p_dist_rec.comments);

   dbms_sql.bind_variable(p_update_cursor, ':account_set_flag',
                          p_dist_rec.account_set_flag);

   dbms_sql.bind_variable(p_update_cursor, ':latest_rec_flag',
                          p_dist_rec.latest_rec_flag);

  /* bug 3598021 - 3630436 */
   dbms_sql.bind_variable(p_update_cursor, ':rec_offset_flag',
                          p_dist_rec.rec_offset_flag);

   dbms_sql.bind_variable(p_update_cursor, ':rounding_correction_flag',
                          p_dist_rec.rounding_correction_flag);

   dbms_sql.bind_variable(p_update_cursor, ':ussgl_transaction_code',
                          p_dist_rec.ussgl_transaction_code);

   dbms_sql.bind_variable(p_update_cursor, ':ussgl_transaction_code_context',
                          p_dist_rec.ussgl_transaction_code_context);

   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_dist_rec.attribute_category);

   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_dist_rec.attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_dist_rec.attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_dist_rec.attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_dist_rec.attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_dist_rec.attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_dist_rec.attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_dist_rec.attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_dist_rec.attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_dist_rec.attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_dist_rec.attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_dist_rec.attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_dist_rec.attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_dist_rec.attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_dist_rec.attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_dist_rec.attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':set_of_books_id',
                          p_dist_rec.set_of_books_id);

   dbms_sql.bind_variable(p_update_cursor, ':posting_control_id',
                          p_dist_rec.posting_control_id);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_date',
                          p_dist_rec.last_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':last_updated_by',
                          p_dist_rec.last_updated_by);

   dbms_sql.bind_variable(p_update_cursor, ':creation_date',
                          p_dist_rec.creation_date);

   dbms_sql.bind_variable(p_update_cursor, ':created_by',
                          p_dist_rec.created_by);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_login',
                          p_dist_rec.last_update_login);

   dbms_sql.bind_variable(p_update_cursor, ':program_application_id',
                          p_dist_rec.program_application_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_id',
                          p_dist_rec.program_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_update_date',
                          p_dist_rec.program_update_date);
   dbms_sql.bind_variable(p_update_cursor, ':ccid_change_flag',
                          p_dist_rec.ccid_change_flag);  /* Bug 8788491 */

   arp_util.debug('arp_ctlgd_pkg.bind_dist_variables()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.bind_dist_variables()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_dist_update_stmt 					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Copies the text of the dynamic SQL update statement into the           |
 |    out NOCOPY paramater. The update statement does not contain a where clause    |
 |    since this is the dynamic part that is added later.                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arpcurr.functional_amount						     |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None.                                                  |
 |              OUT:                                                         |
 |                    update_text  - text of the update statement            |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |    This statement only updates columns in the dist record that do not     |
 |    contain the dummy values that indicate that they should not be changed.|
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE construct_dist_update_stmt( update_text OUT NOCOPY varchar2) IS

BEGIN
   arp_util.debug('arp_ctlgd_pkg.construct_dist_update_stmt()+');

   update_text :=
 'UPDATE ra_cust_trx_line_gl_dist
   SET    cust_trx_line_gl_dist_id =
               DECODE(:cust_trx_line_gl_dist_id,
                      :ar_number_dummy, cust_trx_line_gl_dist_id,
                                        :cust_trx_line_gl_dist_id),
          customer_trx_id =
               DECODE(:customer_trx_id,
                      :ar_number_dummy, customer_trx_id,
                                        :customer_trx_id),
          customer_trx_line_id =
               DECODE(:customer_trx_line_id,
                      :ar_number_dummy, customer_trx_line_id,
                                        :customer_trx_line_id),
          cust_trx_line_salesrep_id =
               DECODE(:cust_trx_line_salesrep_id,
                      :ar_number_dummy, cust_trx_line_salesrep_id,
                                        :cust_trx_line_salesrep_id),
          account_class =
               DECODE(:account_class,
                      :ar_text_dummy, account_class,
                                      :account_class),
          percent =
               DECODE(:percent,
                      :ar_number_dummy, percent,
                                        :percent),
          amount =
               DECODE(:amount,
                      :ar_number_dummy, amount,
                                        :amount),
          /* calculate the accounted amount only if
                - a new accounted amount has not ben passed in AND
                - the amount has changed.        */
          acctd_amount =
               DECODE(:acctd_amount,
                      :ar_number_dummy, decode(:amount,
                                               amount,           acctd_amount,
                                               :ar_number_dummy, acctd_amount,
                                               null,             null,
                                                arpcurr.functional_amount(
                                                          :amount,
 							  :currency_code,
							  :exchange_rate,
						          :precision,
 							  :mau)
                                              ),
                                        :acctd_amount),
          gl_date =
                      -- Only uodate the GL Date for Account Set = N
                      -- and Receivable records.
                      DECODE(
                               DECODE(:account_set_flag,
                                      :ar_flag_dummy, account_set_flag,
                                                      :account_set_flag) ||
                                  DECODE(:account_class,
                                         :ar_text_dummy, account_class,
                                                         :account_class),
                               ''YCHARGES'',  TO_DATE(NULL),
                               ''YFREIGHT'',  TO_DATE(NULL),
                               ''YREV'',      TO_DATE(NULL),
                               ''YSUSPENSE'', TO_DATE(NULL),
                               ''YTAX'',      TO_DATE(NULL),
                               ''YUNBILL'',   TO_DATE(NULL),
                               ''YUNEARN'',   TO_DATE(NULL),
                                            DECODE(:gl_date,
                                                   :ar_date_dummy, gl_date,
                                                   :gl_date)
                           ),
          original_gl_date =
                      -- Only uodate the GL Date for Account Set = N
                      -- and Receivable records.
                      DECODE(
                               DECODE(:account_set_flag,
                                      :ar_flag_dummy, account_set_flag,
                                                      :account_set_flag) ||
                                  DECODE(:account_class,
                                         :ar_text_dummy, account_class,
                                                         :account_class),
                               ''YCHARGES'',  TO_DATE(NULL),
                               ''YFREIGHT'',  TO_DATE(NULL),
                               ''YREV'',      TO_DATE(NULL),
                               ''YSUSPENSE'', TO_DATE(NULL),
                               ''YTAX'',      TO_DATE(NULL),
                               ''YUNBILL'',   TO_DATE(NULL),
                               ''YUNEARN'',   TO_DATE(NULL),
                                            DECODE(:original_gl_date,
                                                   :ar_date_dummy,
                                                              original_gl_date,
                                                           :original_gl_date)
                           ),
          gl_posted_date =
               DECODE(:gl_posted_date,
                      :ar_date_dummy, gl_posted_date,
                                      :gl_posted_date),
          code_combination_id =
               DECODE(:code_combination_id,
                      :ar_number_dummy, code_combination_id,
                                        :code_combination_id),
          concatenated_segments =
               DECODE(:concatenated_segments,
                      :ar_text_dummy, concatenated_segments,
                                      :concatenated_segments),
	  collected_tax_ccid =
               DECODE(:collected_tax_ccid,
                      :ar_number_dummy, collected_tax_ccid,
					:collected_tax_ccid),
	  collected_tax_concat_seg =
               DECODE(:collected_tax_concat_seg,
		      :ar_text_dummy, collected_tax_concat_seg,
				      :collected_tax_concat_seg),
          comments =
               DECODE(:comments,
                      :ar_text_dummy, comments,
                                      :comments),
          account_set_flag =
               DECODE(:account_set_flag,
                      :ar_flag_dummy, account_set_flag,
                                      :account_set_flag),
          latest_rec_flag =
               DECODE(:latest_rec_flag,
                      :ar_flag_dummy, latest_rec_flag,
                                      :latest_rec_flag),
          rec_offset_flag =
               DECODE(:rec_offset_flag,
                      :ar_flag_dummy, rec_offset_flag,
                                      :rec_offset_flag),
          rounding_correction_flag =
               DECODE(:rounding_correction_flag,
                      :ar_flag_dummy, rounding_correction_flag,
                                      :rounding_correction_flag),
          ussgl_transaction_code =
               DECODE(:ussgl_transaction_code,
                      :ar_text_dummy, ussgl_transaction_code,
                                      :ussgl_transaction_code),
          ussgl_transaction_code_context =
               DECODE(:ussgl_transaction_code_context,
                      :ar_text_dummy, ussgl_transaction_code_context,
                                      :ussgl_transaction_code_context),
          attribute_category =
               DECODE(:attribute_category,
                      :ar_text_dummy, attribute_category,
                                      :attribute_category),
          attribute1 =
               DECODE(:attribute1,
                      :ar_text_dummy, attribute1,
                                      :attribute1),
          attribute2 =
               DECODE(:attribute2,
                      :ar_text_dummy, attribute2,
                                      :attribute2),
          attribute3 =
               DECODE(:attribute3,
                      :ar_text_dummy, attribute3,
                                      :attribute3),
          attribute4 =
               DECODE(:attribute4,
                      :ar_text_dummy, attribute4,
                                      :attribute4),
          attribute5 =
               DECODE(:attribute5,
                      :ar_text_dummy, attribute5,
                                      :attribute5),
          attribute6 =
               DECODE(:attribute6,
                      :ar_text_dummy, attribute6,
                                      :attribute6),
          attribute7 =
               DECODE(:attribute7,
                      :ar_text_dummy, attribute7,
                                      :attribute7),
          attribute8 =
               DECODE(:attribute8,
                      :ar_text_dummy, attribute8,
                                      :attribute8),
          attribute9 =
               DECODE(:attribute9,
                      :ar_text_dummy, attribute9,
                                      :attribute9),
          attribute10 =
               DECODE(:attribute10,
                      :ar_text_dummy, attribute10,
                                      :attribute10),
          attribute11 =
               DECODE(:attribute11,
                      :ar_text_dummy, attribute11,
                                      :attribute11),
          attribute12 =
               DECODE(:attribute12,
                      :ar_text_dummy, attribute12,
                                      :attribute12),
          attribute13 =
               DECODE(:attribute13,
                      :ar_text_dummy, attribute13,
                                      :attribute13),
          attribute14 =
               DECODE(:attribute14,
                      :ar_text_dummy, attribute14,
                                      :attribute14),
          attribute15 =
               DECODE(:attribute15,
                      :ar_text_dummy, attribute15,
                                      :attribute15),
          set_of_books_id =
               DECODE(:set_of_books_id,
                      :ar_number_dummy, set_of_books_id,
                                        :set_of_books_id),
          posting_control_id =
               DECODE(:posting_control_id,
                      :ar_number_dummy, posting_control_id,
                                        :posting_control_id),
          last_update_date =
               DECODE(:last_update_date,
                      :ar_date_dummy, sysdate,
                                      :last_update_date),
          last_updated_by =
               DECODE(:last_updated_by,
                      :ar_number_dummy, :pg_user_id,
                                        :last_updated_by),
          creation_date =
               DECODE(:creation_date,
                      :ar_date_dummy, creation_date,
                                      :creation_date),
          created_by =
               DECODE(:created_by,
                      :ar_number_dummy, created_by,
                                        :created_by),
          last_update_login =
               DECODE(:last_update_login,
                      :ar_number_dummy, nvl(:pg_conc_login_id,
                                            :pg_login_id),
                                        :last_update_login),
          program_application_id =
               DECODE(:program_application_id,
                      :ar_number_dummy, program_application_id,
                                        :program_application_id),
          program_id =
               DECODE(:program_id,
                      :ar_number_dummy, program_id,
                                        :program_id),
          program_update_date =
               DECODE(:program_update_date,
                      :ar_date_dummy, program_update_date,
                                      :program_update_date),
          ccid_change_flag =
               DECODE(:ccid_change_flag,
                      :ar_flag_dummy, ccid_change_flag,
                                      :ccid_change_flag)'; /* Bug 8788491 */


   arp_util.debug('arp_ctlgd_pkg.construct_dist_update_stmt()-');

EXCEPTION
    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.construct_dist_update_stmt()');
      RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    generic_update                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure Updates records in ra_cust_trx_line_gl_dist  	     |
 |     identified by the where clause that is passed in as a parameter. Only |
 |     those columns in the dist record parameter that do not contain the    |
 |     special dummy values are updated. 				     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    dbms_sql.open_cursor 						     |
 |    dbms_sql.parse							     |
 |    dbms_sql.execute							     |
 |    dbms_sql.close_cursor						     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_update_cursor     - identifies the cursor to use     |
 |                    p_where_clause      - identifies which rows to update  |
 | 		      p_where1            - value to bind into where clause  |
 |		      p_account_set_flag  - value is used to restrict update |
 |		      p_account_class	  - value is used to restrict update |
 |		      p_exchange_rate					     |
 |		      p_currency_code					     |
 |		      p_precision					     |
 |		      p_mau						     |
 |		      p_dist_rec          - contains the new dist values     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
			 p_where_clause  IN varchar2,
			 p_where1        IN number,
			 p_account_set_flag  IN
                                ra_cust_trx_line_gl_dist.account_set_flag%type,
                         p_account_class IN
                                ra_cust_trx_line_gl_dist.account_class%type,
                         p_exchange_rate IN ra_customer_trx.exchange_rate%type,
                         p_currency_code IN fnd_currencies.currency_code%type,
                         p_precision     IN fnd_currencies.precision%type,
                         p_mau           IN
                                  fnd_currencies.minimum_accountable_unit%type,
                         p_dist_rec      IN ra_cust_trx_line_gl_dist%rowtype)
          IS

   l_count             number;
   l_update_statement  varchar2(25000);
   gl_dist_array   dbms_sql.number_table;   /* mrc */

BEGIN
   arp_util.debug('arp_ctlgd_pkg.generic_update()+');

  /*--------------------------------------------------------------+
   |  If this update statement has not already been parsed, 	  |
   |  construct the statement and parse it.			  |
   |  Otherwise, use the already parsed statement and rebind its  |
   |  variables.						  |
   +--------------------------------------------------------------*/

   IF (p_update_cursor IS NULL)
   THEN
         p_update_cursor := dbms_sql.open_cursor;

         /*---------------------------------+
          |  Construct the update statement |
          +---------------------------------*/

         arp_ctlgd_pkg.construct_dist_update_stmt(l_update_statement);

        l_update_statement := l_update_statement || p_where_clause;

         /*--------------------------------------------------------+
          | added on variables for bulk collect for mrc processing |
          +--------------------------------------------------------*/

          l_update_statement := l_update_statement ||
             ' RETURNING cust_trx_line_gl_dist_id INTO :gl_dist_key_value ';

         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/

         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);

   END IF;

   arp_ctlgd_pkg.bind_dist_variables(p_update_cursor,
                                     p_dist_rec,
                                     p_exchange_rate,
                                     p_currency_code,
                                     p_precision,
                                     p_mau);

  /*-----------------------------------------+
   |  Bind the variables in the where clause |
   +-----------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':where_1',
                          p_where1);

   dbms_sql.bind_variable(p_update_cursor, ':where_account_set_flag',
                          p_account_set_flag);

   dbms_sql.bind_variable(p_update_cursor, ':where_account_class',
                          p_account_class);

   /*-----------------------+
    | bind output variable  |
    +-----------------------*/
    dbms_sql.bind_array(p_update_cursor,':gl_dist_key_value',
                        gl_dist_array);

   l_count := dbms_sql.execute(p_update_cursor);

   arp_util.debug( to_char(l_count) || ' rows updated');

   /*------------------------------------------+
    | get RETURNING COLUMN into OUT NOCOPY bind array |
    +------------------------------------------*/

    dbms_sql.variable_value( p_update_cursor, ':gl_dist_key_value',
                             gl_dist_array);

   /*------------------------------------------------------------+
    |  Raise the NO_DATA_FOUND exception if no rows were updated |
    +------------------------------------------------------------*/

   IF (l_count = 0)
   THEN RAISE NO_DATA_FOUND;
   END IF;

   arp_standard.debug('before loop for MRC processing...');
   FOR I in gl_dist_array.FIRST .. gl_dist_array.LAST LOOP
       /*-----------------------------------------------------+
        | call mrc engine to update RA_CUST_TRX_LINES_GL_DIST |
        +-----------------------------------------------------*/
       arp_standard.debug('before calling maintain_mrc ');
       arp_standard.debug('gl dist array('||to_char(I) || ') = ' || to_char(gl_dist_array(I)));

       ar_mrc_engine.maintain_mrc_data(
                        p_event_mode       => 'UPDATE',
                        p_table_name       => 'RA_CUST_TRX_LINE_GL_DIST',
                        p_mode             => 'SINGLE',
                        p_key_value        => gl_dist_array(I));
   END LOOP;



   arp_util.debug('arp_ctlgd_pkg.generic_update()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.generic_update()');
        arp_util.debug(l_update_statement);
        arp_util.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes all columns in the parameter dist record    |
 |    to the appropriate dummy value for its datatype.			     |
 |    									     |
 |    The dummy values are defined in the following package level constants: |
 |	AR_TEXT_DUMMY 							     |
 | 	AR_FLAG_DUMMY							     |
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
 |                    p_dist_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_dist_rec OUT NOCOPY ra_cust_trx_line_gl_dist%rowtype) IS

BEGIN

    arp_util.debug('arp_lgd_pkg.set_to_dummy()+');

    p_dist_rec.cust_trx_line_gl_dist_id 	:= AR_NUMBER_DUMMY;
    p_dist_rec.customer_trx_id 			:= AR_NUMBER_DUMMY;
    p_dist_rec.customer_trx_line_id 		:= AR_NUMBER_DUMMY;
    p_dist_rec.cust_trx_line_salesrep_id 	:= AR_NUMBER_DUMMY;
    p_dist_rec.account_class 			:= AR_TEXT_DUMMY;
    p_dist_rec.percent 				:= AR_NUMBER_DUMMY;
    p_dist_rec.amount 				:= AR_NUMBER_DUMMY;
    p_dist_rec.acctd_amount 			:= AR_NUMBER_DUMMY;
    p_dist_rec.gl_date 				:= AR_DATE_DUMMY;
    p_dist_rec.original_gl_date 		:= AR_DATE_DUMMY;
    p_dist_rec.gl_posted_date 			:= AR_DATE_DUMMY;
    p_dist_rec.code_combination_id		:= AR_NUMBER_DUMMY;
    p_dist_rec.concatenated_segments 		:= AR_TEXT_DUMMY;
    p_dist_rec.collected_tax_ccid		:= AR_NUMBER_DUMMY;
    p_dist_rec.collected_tax_concat_seg		:= AR_TEXT_DUMMY;
    p_dist_rec.comments 			:= AR_TEXT_DUMMY;
    p_dist_rec.account_set_flag 		:= AR_FLAG_DUMMY;
    p_dist_rec.latest_rec_flag			:= AR_FLAG_DUMMY;
    p_dist_rec.rec_offset_flag                  := AR_FLAG_DUMMY;       /* bug 3598021 - 3630436 */
    p_dist_rec.ussgl_transaction_code 		:= AR_TEXT_DUMMY;
    p_dist_rec.ussgl_transaction_code_context 	:= AR_TEXT_DUMMY;
    p_dist_rec.attribute_category 		:= AR_TEXT_DUMMY;
    p_dist_rec.attribute1 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute2 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute3 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute4 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute5 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute6 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute7 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute8 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute9 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute10 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute11 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute12 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute13 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute14 			:= AR_TEXT_DUMMY;
    p_dist_rec.attribute15 			:= AR_TEXT_DUMMY;
    p_dist_rec.set_of_books_id			:= AR_NUMBER_DUMMY;
    p_dist_rec.posting_control_id 		:= AR_NUMBER_DUMMY;
    p_dist_rec.last_update_date 		:= AR_DATE_DUMMY;
    p_dist_rec.last_updated_by 			:= AR_NUMBER_DUMMY;
    p_dist_rec.creation_date 			:= AR_DATE_DUMMY;
    p_dist_rec.created_by 			:= AR_NUMBER_DUMMY;
    p_dist_rec.last_update_login 		:= AR_NUMBER_DUMMY;
    p_dist_rec.program_application_id 		:= AR_NUMBER_DUMMY;
    p_dist_rec.program_id 			:= AR_NUMBER_DUMMY;
    p_dist_rec.program_update_date 		:= AR_DATE_DUMMY;
    p_dist_rec.rounding_correction_flag         := AR_FLAG_DUMMY;

    arp_util.debug('arp_lgd_pkg.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_lgd_pkg.set_to_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_gl_dist row identified by    |
 |    p_cust_trx_line_gl_dist_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_cust_trx_line_gl_dist_id - identifies the row to lock  |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_cust_trx_line_gl_dist_id
                  IN ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type
                )
          IS

    l_cust_trx_line_gl_dist_id
                    ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;

BEGIN
    arp_util.debug('arp_ctlgd_pkg.lock_p()+');


    SELECT        cust_trx_line_gl_dist_id
    INTO          l_cust_trx_line_gl_dist_id
    FROM          ra_cust_trx_line_gl_dist
    WHERE         cust_trx_line_gl_dist_id = p_cust_trx_line_gl_dist_id
    FOR UPDATE OF cust_trx_line_gl_dist_id NOWAIT;

    arp_util.debug('arp_ctlgd_pkg.lock_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_ctlgd_pkg.lock_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_gl_dist rows identified by   |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_id     - identifies the rows to lock	     |
 |		    p_account_set_flag    - value is used to restrict lock   |
 |		    p_account_class	  - value is used to restrict lock   |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type)
          IS


    CURSOR lock_c IS
    SELECT        cust_trx_line_gl_dist_id
    FROM          ra_cust_trx_line_gl_dist
    WHERE         customer_trx_id  = p_customer_trx_id
    AND           account_set_flag = nvl(p_account_set_flag, account_set_flag)
    AND           account_class    = nvl(p_account_class, account_class)
    FOR UPDATE OF cust_trx_line_gl_dist_id NOWAIT;


BEGIN
    arp_util.debug('arp_ctlgd_pkg.lock_f_ct_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_ctlgd_pkg.lock_f_ct_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_ctlgd_pkg.lock_f_ct_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_gl_dist rows identified by   |
 |    p_customer_trx_line_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_line_id - identifies the rows to lock     |
 |		    p_account_set_flag     - value is used to restrict lock  |
 |		    p_account_class	   - value is used to restrict lock  |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ctl_id( p_customer_trx_line_id
                           IN ra_customer_trx_lines.customer_trx_line_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type)
          IS

    CURSOR lock_c IS
    SELECT        cust_trx_line_gl_dist_id
    FROM          ra_cust_trx_line_gl_dist
    WHERE         customer_trx_line_id = p_customer_trx_line_id
    AND           account_set_flag = nvl(p_account_set_flag, account_set_flag)
    AND           account_class    = nvl(p_account_class, account_class)
    FOR UPDATE OF cust_trx_line_gl_dist_id NOWAIT;

BEGIN
    arp_util.debug('arp_ctlgd_pkg.lock_f_ctl_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_ctlgd_pkg.lock_f_ctl_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_ctlgd_pkg.lock_f_ctl_id' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ctls_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_gl_dist rows identified by   |
 |    p_cust_trx_line_salesrep_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_cust_trx_line_salesrep_id - identifies the rows to lock  |
 |		  p_account_set_flag    - value is used to restrict lock     |
 |		  p_account_class       - value is used to restrict lock     |
 |              OUT:                                                         |
 |                None							     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ctls_id( p_cust_trx_line_salesrep_id
                   IN ra_cust_trx_line_gl_dist.cust_trx_line_salesrep_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type)
          IS

    CURSOR lock_c IS
    SELECT        cust_trx_line_gl_dist_id
    FROM          ra_cust_trx_line_gl_dist
    WHERE         cust_trx_line_salesrep_id = p_cust_trx_line_salesrep_id
    AND           account_set_flag = nvl(p_account_set_flag, account_set_flag)
    AND           account_class    = nvl(p_account_class, account_class)
    FOR UPDATE OF cust_trx_line_gl_dist_id NOWAIT;

BEGIN
    arp_util.debug('arp_ctlgd_pkg.lock_f_ctls_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_ctlgd_pkg.lock_f_ctls_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_ctlgd_pkg.lock_f_ctls_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_gl_dist row identified       |
 |    by the p_cust_trx_line_gl_dist_id parameter and populates the          |
 |    p_dist_rec parameter with the row that was locked.		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_cust_trx_line_gl_dist_id - identifies the row to lock  |
 |              OUT:                                                         |
 |                  p_dist_rec			- contains the locked row    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_dist_rec IN OUT NOCOPY ra_cust_trx_line_gl_dist%rowtype,
                        p_cust_trx_line_gl_dist_id IN
		ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type
) IS

BEGIN
    arp_util.debug('arp_ctlgd_pkg.lock_fetch_p()+');

    SELECT        *
    INTO          p_dist_rec
    FROM          ra_cust_trx_line_gl_dist
    WHERE         cust_trx_line_gl_dist_id = p_cust_trx_line_gl_dist_id
    FOR UPDATE OF cust_trx_line_gl_dist_id NOWAIT;

    arp_util.debug('arp_ctlgd_pkg.lock_fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_ctlgd_pkg.lock_fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_gl_dist row identified       |
 |    by the p_cust_trx_line_gl_dist_id parameter only if no columns in      |
 |    that row have changed from when they were first selected in the form.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_cust_trx_line_gl_dist_id - identifies the row to lock   |
 | 		   p_dist_rec    	- dist record for comparison	     |
 |                 p_ignore_who_flag    - directs system to ignore who cols  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |     29-JUN-95  Charlie Tomberg     Modified to use select for update      |
 |     13-OCT-95  Martin Johnson      Handle NO_DATA_FOUND exception         |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_p( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                          p_cust_trx_line_gl_dist_id IN
                  ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
                          p_ignore_who_flag BOOLEAN DEFAULT FALSE) IS

    l_new_dist_rec     ra_cust_trx_line_gl_dist%rowtype;
    l_temp_dist_rec    ra_cust_trx_line_gl_dist%rowtype;
    l_ignore_who_flag  varchar2(2);

BEGIN
    arp_util.debug('arp_ctlgd_pkg.lock_compare_p()+');

    IF     (p_ignore_who_flag = TRUE)
    THEN   l_ignore_who_flag := 'Y';
    ELSE   l_ignore_who_flag := 'N';
    END IF;

    SELECT *
    INTO   l_new_dist_rec
    FROM   ra_cust_trx_line_gl_dist ctlgd
    WHERE  cust_trx_line_gl_dist_id = p_cust_trx_line_gl_dist_id
    AND (
           NVL(ctlgd.cust_trx_line_gl_dist_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.cust_trx_line_gl_dist_id,
                        AR_NUMBER_DUMMY, ctlgd.cust_trx_line_gl_dist_id,
                                         p_dist_rec.cust_trx_line_gl_dist_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.customer_trx_id,
                        AR_NUMBER_DUMMY, ctlgd.customer_trx_id,
                                         p_dist_rec.customer_trx_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.customer_trx_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.customer_trx_line_id,
                        AR_NUMBER_DUMMY, ctlgd.customer_trx_line_id,
                                         p_dist_rec.customer_trx_line_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.cust_trx_line_salesrep_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.cust_trx_line_salesrep_id,
                        AR_NUMBER_DUMMY, ctlgd.cust_trx_line_salesrep_id,
                                         p_dist_rec.cust_trx_line_salesrep_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.account_class, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.account_class,
                        AR_TEXT_DUMMY, ctlgd.account_class,
                                         p_dist_rec.account_class),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.percent, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.percent,
                        AR_NUMBER_DUMMY, ctlgd.percent,
                                         p_dist_rec.percent),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.amount,
                        AR_NUMBER_DUMMY, ctlgd.amount,
                                         p_dist_rec.amount),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.acctd_amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.acctd_amount,
                        AR_NUMBER_DUMMY, ctlgd.acctd_amount,
                                         p_dist_rec.acctd_amount),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.gl_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.gl_date,
                        AR_DATE_DUMMY, ctlgd.gl_date,
                                         p_dist_rec.gl_date),
                        AR_DATE_DUMMY
              )
         AND
           NVL(ctlgd.original_gl_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.original_gl_date,
                        AR_DATE_DUMMY, ctlgd.original_gl_date,
                                         p_dist_rec.original_gl_date),
                        AR_DATE_DUMMY
              )
         AND
           NVL(ctlgd.gl_posted_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.gl_posted_date,
                        AR_DATE_DUMMY, ctlgd.gl_posted_date,
                                         p_dist_rec.gl_posted_date),
                        AR_DATE_DUMMY
              )
         AND
           NVL(ctlgd.code_combination_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.code_combination_id,
                        AR_NUMBER_DUMMY, ctlgd.code_combination_id,
                                         p_dist_rec.code_combination_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.concatenated_segments, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.concatenated_segments,
                        AR_TEXT_DUMMY, ctlgd.concatenated_segments,
                                         p_dist_rec.concatenated_segments),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.collected_tax_ccid, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.collected_tax_ccid,
                        AR_NUMBER_DUMMY, ctlgd.collected_tax_ccid,
                                         p_dist_rec.collected_tax_ccid),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.collected_tax_concat_seg, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.collected_tax_concat_seg,
                        AR_TEXT_DUMMY, ctlgd.collected_tax_concat_seg,
                                         p_dist_rec.collected_tax_concat_seg),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.comments, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.comments,
                        AR_TEXT_DUMMY, ctlgd.comments,
                                         p_dist_rec.comments),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.account_set_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.account_set_flag,
                        AR_FLAG_DUMMY, ctlgd.account_set_flag,
                                         p_dist_rec.account_set_flag),
                        AR_FLAG_DUMMY
              )
         AND
           NVL(ctlgd.latest_rec_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.latest_rec_flag,
                        AR_FLAG_DUMMY, ctlgd.latest_rec_flag,
                                         p_dist_rec.latest_rec_flag),
                        AR_FLAG_DUMMY
              )
         AND
           NVL(ctlgd.ussgl_transaction_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.ussgl_transaction_code,
                        AR_TEXT_DUMMY, ctlgd.ussgl_transaction_code,
                                         p_dist_rec.ussgl_transaction_code),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.ussgl_transaction_code_context, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.ussgl_transaction_code_context,
                        AR_TEXT_DUMMY, ctlgd.ussgl_transaction_code_context,
                                    p_dist_rec.ussgl_transaction_code_context),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute_category, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute_category,
                        AR_TEXT_DUMMY, ctlgd.attribute_category,
                                         p_dist_rec.attribute_category),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute1,
                        AR_TEXT_DUMMY, ctlgd.attribute1,
                                         p_dist_rec.attribute1),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute2,
                        AR_TEXT_DUMMY, ctlgd.attribute2,
                                         p_dist_rec.attribute2),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute3,
                        AR_TEXT_DUMMY, ctlgd.attribute3,
                                         p_dist_rec.attribute3),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute4,
                        AR_TEXT_DUMMY, ctlgd.attribute4,
                                         p_dist_rec.attribute4),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute5,
                        AR_TEXT_DUMMY, ctlgd.attribute5,
                                         p_dist_rec.attribute5),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute6,
                        AR_TEXT_DUMMY, ctlgd.attribute6,
                                         p_dist_rec.attribute6),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute7,
                        AR_TEXT_DUMMY, ctlgd.attribute7,
                                         p_dist_rec.attribute7),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute8,
                        AR_TEXT_DUMMY, ctlgd.attribute8,
                                         p_dist_rec.attribute8),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute9,
                        AR_TEXT_DUMMY, ctlgd.attribute9,
                                         p_dist_rec.attribute9),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute10,
                        AR_TEXT_DUMMY, ctlgd.attribute10,
                                         p_dist_rec.attribute10),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute11,
                        AR_TEXT_DUMMY, ctlgd.attribute11,
                                         p_dist_rec.attribute11),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute12,
                        AR_TEXT_DUMMY, ctlgd.attribute12,
                                         p_dist_rec.attribute12),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute13,
                        AR_TEXT_DUMMY, ctlgd.attribute13,
                                         p_dist_rec.attribute13),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute14,
                        AR_TEXT_DUMMY, ctlgd.attribute14,
                                         p_dist_rec.attribute14),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.attribute15,
                        AR_TEXT_DUMMY, ctlgd.attribute15,
                                         p_dist_rec.attribute15),
                        AR_TEXT_DUMMY
              )
         AND
           NVL(ctlgd.set_of_books_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.set_of_books_id,
                        AR_NUMBER_DUMMY, ctlgd.set_of_books_id,
                                         p_dist_rec.set_of_books_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.posting_control_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.posting_control_id,
                        AR_NUMBER_DUMMY, ctlgd.posting_control_id,
                                         p_dist_rec.posting_control_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.last_update_date, AR_DATE_DUMMY) =
            NVL(
                  DECODE(l_ignore_who_flag,
                         'Y',  NVL(ctlgd.last_update_date, AR_DATE_DUMMY),
                               DECODE(
                                       p_dist_rec.last_update_date,
                                       AR_DATE_DUMMY, ctlgd.last_update_date,
                                                   p_dist_rec.last_update_date
                                     )
                        ),
                  AR_DATE_DUMMY
               )
         AND
           NVL(ctlgd.last_updated_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',   NVL(ctlgd.last_updated_by, AR_NUMBER_DUMMY),
                               DECODE(
                                      p_dist_rec.last_updated_by,
                                      AR_NUMBER_DUMMY, ctlgd.last_updated_by,
                                                  p_dist_rec.last_updated_by
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.creation_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctlgd.creation_date, AR_DATE_DUMMY),
                              DECODE(
                                     p_dist_rec.creation_date,
                                     AR_DATE_DUMMY, ctlgd.creation_date,
                                                 p_dist_rec.creation_date
                                    )
                       ),
                 AR_DATE_DUMMY
              )
         AND
           NVL(ctlgd.created_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctlgd.created_by, AR_NUMBER_DUMMY),
                              DECODE(
                                       p_dist_rec.created_by,
                                       AR_NUMBER_DUMMY, ctlgd.created_by,
                                                      p_dist_rec.created_by
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.last_update_login, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctlgd.last_update_login, AR_NUMBER_DUMMY),
                              DECODE(
                                       p_dist_rec.last_update_login,
                                      AR_NUMBER_DUMMY, ctlgd.last_update_login,
                                                 p_dist_rec.last_update_login
                                    )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.program_application_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                      'Y',  NVL(ctlgd.program_application_id, AR_NUMBER_DUMMY),
                              DECODE(
                                  p_dist_rec.program_application_id,
                                 AR_NUMBER_DUMMY, ctlgd.program_application_id,
                                            p_dist_rec.program_application_id
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.program_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctlgd.program_id, AR_NUMBER_DUMMY),
                              DECODE(
                                      p_dist_rec.program_id,
                                      AR_NUMBER_DUMMY, ctlgd.program_id,
                                                       p_dist_rec.program_id
                                    )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctlgd.program_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctlgd.program_update_date, AR_DATE_DUMMY),
                              DECODE(
                                       p_dist_rec.program_update_date,
                                      AR_DATE_DUMMY, ctlgd.program_update_date,
                                                p_dist_rec.program_update_date
                                    )
                       ),
                 AR_DATE_DUMMY
              )
         AND
           NVL(ctlgd.ccid_change_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_dist_rec.ccid_change_flag,
                        AR_FLAG_DUMMY, ctlgd.ccid_change_flag,
                                         p_dist_rec.ccid_change_flag),
                        AR_FLAG_DUMMY
              )     /* Bug 8788491 */
       )
    FOR UPDATE OF cust_trx_line_gl_dist_id NOWAIT;

    arp_util.debug('arp_ctlgd_pkg.lock_compare_p()-');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

              arp_util.debug('');
              arp_util.debug('p_cust_trx_line_gl_dist_id  = ' ||
                              p_cust_trx_line_gl_dist_id );
              arp_util.debug('-------- new dist record --------');
              display_dist_rec( p_dist_rec );

              arp_util.debug('');

              arp_util.debug('-------- old dist record --------');

              fetch_p( l_temp_dist_rec,
                       p_cust_trx_line_gl_dist_id );

              display_dist_rec( l_temp_dist_rec );

              FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
              APP_EXCEPTION.Raise_Exception;


        WHEN OTHERS THEN
              arp_util.debug( 'EXCEPTION: arp_ctlgd_pkg.lock_compare_p' );

              arp_util.debug( SQLERRM );

              arp_util.debug('----- parameters for lock_compare_p -----');

              arp_util.debug('p_cust_trx_line_gl_dist_id  = ' ||
                             p_cust_trx_line_gl_dist_id );
              arp_util.debug('p_ignore_who_flag            =' ||
                      arp_trx_util.boolean_to_varchar2(p_ignore_who_flag));

              arp_util.debug('');
              arp_util.debug('-------- new dist record --------');
              display_dist_rec( p_dist_rec );

              arp_util.debug('');

              arp_util.debug('-------- old dist record --------');

              fetch_p( l_temp_dist_rec,
                       p_cust_trx_line_gl_dist_id );

              display_dist_rec( l_temp_dist_rec );

              RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_cover						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a dist record and                        |
 |    lockss a dist line.                                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cust_trx_line_gl_dist_id                             |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_cust_trx_line_salesrep_id                            |
 |                    p_account_class                                        |
 |                    p_percent                                              |
 |                    p_amount                                               |
 |                    p_acctd_amount                                         |
 |                    p_gl_date                                              |
 |                    p_original_gl_date                                     |
 |                    p_gl_posted_date                                       |
 |                    p_code_combination_id                                  |
 |                    p_concatenated_segments                                |
 |		      p_collected_tax_ccid				     |
 |		      p_collected_tax_concat_seg			     |
 |                    p_comments                                             |
 |                    p_account_set_flag                                     |
 |                    p_latest_rec_flag                                      |
 |                    p_ussgl_transaction_code                               |
 |                    p_ussgl_trx_code_context                               |
 |                    p_attribute_category                                   |
 |                    p_attribute1                                           |
 |                    p_attribute2                                           |
 |                    p_attribute3                                           |
 |                    p_attribute4                                           |
 |                    p_attribute5                                           |
 |                    p_attribute6                                           |
 |                    p_attribute7                                           |
 |                    p_attribute8                                           |
 |                    p_attribute9                                           |
 |                    p_attribute10                                          |
 |                    p_attribute11                                          |
 |                    p_attribute12                                          |
 |                    p_attribute13                                          |
 |                    p_attribute14                                          |
 |                    p_attribute15                                          |
 |                    p_posting_control_id                                   |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-OCT-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE lock_compare_cover(
           p_cust_trx_line_gl_dist_id       IN
             ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
           p_customer_trx_id                IN
             ra_cust_trx_line_gl_dist.customer_trx_id%type,
           p_customer_trx_line_id           IN
             ra_cust_trx_line_gl_dist.customer_trx_line_id %type,
           p_cust_trx_line_salesrep_id      IN
             ra_cust_trx_line_gl_dist.cust_trx_line_salesrep_id%type,
           p_account_class                  IN
             ra_cust_trx_line_gl_dist.account_class%type,
           p_percent                        IN
             ra_cust_trx_line_gl_dist.percent%type,
           p_amount                         IN
             ra_cust_trx_line_gl_dist.amount%type,
           p_gl_date                        IN
             ra_cust_trx_line_gl_dist.gl_date%type,
           p_original_gl_date               IN
             ra_cust_trx_line_gl_dist.original_gl_date%type,
           p_gl_posted_date                 IN
             ra_cust_trx_line_gl_dist.gl_posted_date%type,
           p_code_combination_id            IN
             ra_cust_trx_line_gl_dist.code_combination_id%type,
           p_concatenated_segments          IN
             ra_cust_trx_line_gl_dist.concatenated_segments%type,
           p_collected_tax_ccid             IN
             ra_cust_trx_line_gl_dist.collected_tax_ccid%type,
           p_collected_tax_concat_seg       IN
             ra_cust_trx_line_gl_dist.collected_tax_concat_seg%type,
           p_comments                       IN
             ra_cust_trx_line_gl_dist.comments%type,
           p_account_set_flag               IN
             ra_cust_trx_line_gl_dist.account_set_flag%type,
           p_latest_rec_flag                IN
             ra_cust_trx_line_gl_dist.latest_rec_flag%type,
           p_ussgl_transaction_code         IN
             ra_cust_trx_line_gl_dist.ussgl_transaction_code%type,
           p_ussgl_trx_code_context         IN
             ra_cust_trx_line_gl_dist.ussgl_transaction_code_context%type,
           p_attribute_category             IN
             ra_cust_trx_line_gl_dist.attribute_category%type,
           p_attribute1                     IN
             ra_cust_trx_line_gl_dist.attribute1%type,
           p_attribute2                     IN
             ra_cust_trx_line_gl_dist.attribute2%type,
           p_attribute3                     IN
             ra_cust_trx_line_gl_dist.attribute3%type,
           p_attribute4                     IN
             ra_cust_trx_line_gl_dist.attribute4%type,
           p_attribute5                     IN
             ra_cust_trx_line_gl_dist.attribute5%type,
           p_attribute6                     IN
             ra_cust_trx_line_gl_dist.attribute6%type,
           p_attribute7                     IN
             ra_cust_trx_line_gl_dist.attribute7%type,
           p_attribute8                     IN
             ra_cust_trx_line_gl_dist.attribute8%type,
           p_attribute9                     IN
             ra_cust_trx_line_gl_dist.attribute9%type,
           p_attribute10                    IN
             ra_cust_trx_line_gl_dist.attribute10%type,
           p_attribute11                    IN
             ra_cust_trx_line_gl_dist.attribute11%type,
           p_attribute12                    IN
             ra_cust_trx_line_gl_dist.attribute12%type,
           p_attribute13                    IN
             ra_cust_trx_line_gl_dist.attribute13%type,
           p_attribute14                    IN
             ra_cust_trx_line_gl_dist.attribute14%type,
           p_attribute15                    IN
             ra_cust_trx_line_gl_dist.attribute15%type,
           p_posting_control_id             IN
             ra_cust_trx_line_gl_dist.posting_control_id%type,
           p_ccid_change_flag               IN
             ra_cust_trx_line_gl_dist.ccid_change_flag%type ) /* Bug 8788491 */
IS

      l_dist_rec ra_cust_trx_line_gl_dist%rowtype;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_ctlgd_pkg.lock_compare_cover()+',
                     pg_msg_level_debug);
      END IF;

     /*------------------------------------------------+
      |  Populate the dist record group with           |
      |  the values passed in as parameters.           |
      +------------------------------------------------*/

      set_to_dummy(l_dist_rec);

      l_dist_rec.cust_trx_line_gl_dist_id       := p_cust_trx_line_gl_dist_id;
      l_dist_rec.customer_trx_id                := p_customer_trx_id;
      l_dist_rec.customer_trx_line_id           := p_customer_trx_line_id;
      l_dist_rec.cust_trx_line_salesrep_id      := p_cust_trx_line_salesrep_id;
      l_dist_rec.account_class                  := p_account_class;
      l_dist_rec.percent                        := p_percent;
      l_dist_rec.amount                         := p_amount;
      l_dist_rec.gl_date                        := p_gl_date;
      l_dist_rec.original_gl_date               := p_original_gl_date;
      l_dist_rec.gl_posted_date                 := p_gl_posted_date;
      l_dist_rec.code_combination_id            := p_code_combination_id;
      l_dist_rec.concatenated_segments          := p_concatenated_segments;
      l_dist_rec.collected_tax_ccid		:= p_collected_tax_ccid;
      l_dist_rec.collected_tax_concat_seg	:= p_collected_tax_concat_seg;
      l_dist_rec.comments                       := p_comments;
      l_dist_rec.account_set_flag               := p_account_set_flag;
      l_dist_rec.latest_rec_flag                := p_latest_rec_flag;
      l_dist_rec.ussgl_transaction_code         := p_ussgl_transaction_code;
      l_dist_rec.ussgl_transaction_code_context := p_ussgl_trx_code_context;
      l_dist_rec.attribute_category             := p_attribute_category;
      l_dist_rec.attribute1                     := p_attribute1;
      l_dist_rec.attribute2                     := p_attribute2;
      l_dist_rec.attribute3                     := p_attribute3;
      l_dist_rec.attribute4                     := p_attribute4;
      l_dist_rec.attribute5                     := p_attribute5;
      l_dist_rec.attribute6                     := p_attribute6;
      l_dist_rec.attribute7                     := p_attribute7;
      l_dist_rec.attribute8                     := p_attribute8;
      l_dist_rec.attribute9                     := p_attribute9;
      l_dist_rec.attribute10                    := p_attribute10;
      l_dist_rec.attribute11                    := p_attribute11;
      l_dist_rec.attribute12                    := p_attribute12;
      l_dist_rec.attribute13                    := p_attribute13;
      l_dist_rec.attribute14                    := p_attribute14;
      l_dist_rec.attribute15                    := p_attribute15;
      l_dist_rec.posting_control_id             := p_posting_control_id;
      l_dist_rec.ccid_change_flag               := p_ccid_change_flag; /* Bug 8788491 */

     /*----------------------------------------------+
      |  Call the standard dist table handler        |
      +----------------------------------------------*/

      lock_compare_p(
                      l_dist_rec,
                      p_cust_trx_line_gl_dist_id,
                      TRUE        -- ignore who columns
                    );

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_ctlgd_pkg.lock_compare_cover()-',
                     pg_msg_level_debug);
      END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.lock_compare_cover()',
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || '------- parameters for lock_compare_cove() ' ||
                   '---------',
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_cust_trx_line_gl_dist_id  = ' ||
                     p_cust_trx_line_gl_dist_id,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_customer_trx_id           = ' || p_customer_trx_id,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_customer_trx_line_id      = ' || p_customer_trx_line_id,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_cust_trx_line_salesrep_id = ' ||
                     p_cust_trx_line_salesrep_id,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_account_class             = ' || p_account_class,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_percent                   = ' || p_percent,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_amount                    = ' || p_amount,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_gl_date                   = ' || p_gl_date,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_gl_posted_date            = ' || p_gl_posted_date,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_original_gl_date          = ' || p_original_gl_date,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_code_combination_id       = ' || p_code_combination_id,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_concatenated_segments     = ' || p_concatenated_segments,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_collected_tax_ccid	= ' || p_collected_tax_ccid,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_collected_tax_concat_seg	= ' || p_collected_tax_concat_seg,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_comments                  = ' || p_comments,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_account_set_flag          = ' || p_account_set_flag,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_latest_rec_flag           = ' || p_latest_rec_flag,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_ussgl_transaction_code    = ' ||
                      p_ussgl_transaction_code,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_ussgl_trx_code_context    = ' ||
                      p_ussgl_trx_code_context,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute_category        = ' || p_attribute_category,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute1                = ' || p_attribute1,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute2                = ' || p_attribute2,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute3                = ' || p_attribute3,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute4                = ' || p_attribute4,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute5                = ' || p_attribute5,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute6                = ' || p_attribute6,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute7                = ' || p_attribute7,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute8                = ' || p_attribute8,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute9                = ' || p_attribute9,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute10               = ' || p_attribute10,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute11               = ' || p_attribute11,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute12               = ' || p_attribute12,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute13               = ' || p_attribute13,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute14               = ' || p_attribute14,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_attribute15               = ' || p_attribute15,
                   pg_msg_level_debug);
       arp_util.debug('lock_compare_cover: ' || 'p_posting_control_id        = ' || p_posting_control_id,
                   pg_msg_level_debug);
    END IF;

    RAISE;

END lock_compare_cover;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ra_cust_trx_line_gl_dist      |
 |    into a variable specified as a parameter based on the table's primary  |
 |    key, cust_trx_line_gl_dist_id					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_cust_trx_line_gl_dist_id - identifies the record to fetch  |
 |              OUT:                                                         |
 |                    p_dist_rec  - contains the fetched record	     	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_dist_rec         OUT NOCOPY ra_cust_trx_line_gl_dist%rowtype,
                   p_cust_trx_line_gl_dist_id IN
                     ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type)
          IS

BEGIN
    arp_util.debug('arp_ctlgd_pkg.fetch_p()+');

    SELECT *
    INTO   p_dist_rec
    FROM   ra_cust_trx_line_gl_dist
    WHERE  cust_trx_line_gl_dist_id = p_cust_trx_line_gl_dist_id;

    arp_util.debug('arp_ctlgd_pkg.fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_ctlgd_pkg.fetch_p' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_cust_trx_line_gl_dist row identified     |
 |    by the p_cust_trx_line_gl_dist_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_cust_trx_line_gl_dist_id  - identifies the rows to delete  |
 |              OUT:                                                         |
 |              None						             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |     14-Aug-02  Debbie Jancis       Modified for MRC trigger replacement   |
 |				      added processing calls for delete from |
 |				      ra_cust_trx_lines_gl_dist              |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_cust_trx_line_gl_dist_id
                IN ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type)
       IS


BEGIN


   arp_util.debug('arp_ctlgd_pkg.delete_p()+');

   DELETE FROM ra_cust_trx_line_gl_dist
   WHERE       cust_trx_line_gl_dist_id = p_cust_trx_line_gl_dist_id;

   IF   ( SQL%ROWCOUNT = 0 )
   THEN    arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.delete_p()');
           RAISE NO_DATA_FOUND;
   END IF;

   /* call mrc api to delete */
   arp_standard.debug('calling mrc engine for insertion of gl dist data');
   ar_mrc_engine.maintain_mrc_data(
                p_event_mode        => 'DELETE',
                p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                p_mode              => 'SINGLE',
                p_key_value         => p_cust_trx_line_gl_dist_id);


   arp_util.debug('arp_ctlgd_pkg.delete_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.delete_p()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_cust_trx_line_gl_dist rows identified    |
 |    by the p_customer_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |           	    p_customer_trx_id  - identifies the rows to delete       |
 |		    p_account_set_flag - value is used to restrict delete    |
 |		    p_account_class    - value is used to restrict delete    |
 |              OUT:                                                         |
 |                    None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |     14-Aug-02  Debbie Jancis       Modified for MRC trigger replacement   |
 |                                    added processing calls for delete from |
 |                                    ra_cust_trx_lines_gl_dist              |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ct_id( p_customer_trx_id
                         IN ra_customer_trx.customer_trx_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type)
       IS

l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

   arp_util.debug('arp_ctlgd_pkg.delete_f_ct_id()+');

   DELETE FROM ra_cust_trx_line_gl_dist
   WHERE  customer_trx_id  = p_customer_trx_id
   AND    account_set_flag = nvl(p_account_set_flag, account_set_flag)
   AND    account_class    = nvl(p_account_class, account_class);

   arp_standard.debug('calling mrc engine for insertion of gl dist data');
   ar_mrc_engine.maintain_mrc_data(
                    p_event_mode        => 'DELETE',
                    p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                    p_mode              => 'BATCH',
                    p_key_value_list    => l_gl_dist_key_value_list);


   arp_util.debug('arp_ctlgd_pkg.delete_f_ct_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.delete_f_ct_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_cust_trx_line_gl_dist rows identified    |
 |    by the p_customer_trx_line_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |        	    p_customer_trx_line_id  - identifies the rows to delete  |
 |		    p_account_set_flag - value is used to restrict delete    |
 |		    p_account_class    - value is used to restrict delete    |
 |              OUT:                                                         |
 |                  None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |     14-Aug-02  Debbie Jancis       Modified for MRC trigger replacement   |
 |                                    added processing calls for delete from |
 |                                    ra_cust_trx_lines_gl_dist              |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ctl_id( p_customer_trx_line_id
                         IN ra_customer_trx_lines.customer_trx_line_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type)
       IS

l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN


   arp_util.debug('arp_ctlgd_pkg.delete_f_ctl_id()+');

   DELETE FROM ra_cust_trx_line_gl_dist
   WHERE  customer_trx_line_id = p_customer_trx_line_id
   AND    account_set_flag     = nvl(p_account_set_flag, account_set_flag)
   AND    account_class        = nvl(p_account_class, account_class)
   RETURNING cust_trx_line_gl_dist_id
   BULK COLLECT INTO l_gl_dist_key_value_list;

   arp_standard.debug('calling mrc engine for insertion of gl dist data');
   ar_mrc_engine.maintain_mrc_data(
                    p_event_mode        => 'DELETE',
                    p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                    p_mode              => 'BATCH',
                    p_key_value_list    => l_gl_dist_key_value_list);

   arp_util.debug('arp_ctlgd_pkg.delete_f_ctl_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.delete_f_ctl_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ctls_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_cust_trx_line_gl_dist rows identified    |
 |    by the p_cust_trx_line_salesrep_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |        	    p_cust_trx_line_salesrep - identifies the rows to delete |
 |		    p_account_set_flag - value is used to restrict delete    |
 |		    p_account_class    - value is used to restrict delete    |
 |              OUT:                                                         |
 |                  None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |     14-Aug-02  Debbie Jancis       Modified for MRC trigger replacement   |
 |                                    added processing calls for delete from |
 |                                    ra_cust_trx_lines_gl_dist              |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ctls_id( p_cust_trx_line_salesrep_id
                  IN ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                         p_account_set_flag
                            IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                         p_account_class
                               IN ra_cust_trx_line_gl_dist.account_class%type)
       IS

l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

   arp_util.debug('arp_ctlgd_pkg.delete_f_ctls_id()+');

   DELETE FROM ra_cust_trx_line_gl_dist
   WHERE  cust_trx_line_salesrep_id = p_cust_trx_line_salesrep_id
   AND    account_set_flag          = nvl(p_account_set_flag, account_set_flag)
   AND    account_class             = nvl(p_account_class, account_class)
   RETURNING cust_trx_line_gl_dist_id
   BULK COLLECT INTO l_gl_dist_key_value_list;

   arp_standard.debug('calling mrc engine for insertion of gl dist data');
   ar_mrc_engine.maintain_mrc_data(
                    p_event_mode        => 'DELETE',
                    p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                    p_mode              => 'BATCH',
                    p_key_value_list    => l_gl_dist_key_value_list);


   arp_util.debug('arp_ctlgd_pkg.delete_f_ctls_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.delete_f_ctls_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_ltctl_id_type                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_cust_trx_line_gl_dist rows corresponding |
 |    to the child lines (incl. header freight line) identified by           |
 |    p_customer_trx_id, p_link_to_cust_trx_line_id and p_line_type          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_id          - identifies the transaction  |
 |                  p_link_to_cust_trx_line_id - identifies the parent line  |
 |                  p_line_type                - identifies the parent line  |
 |                                               type                        |
 |                  p_account_set_flag - value is used to restrict delete    |
 |                  p_account_class    - value is used to restrict delete    |
 |              OUT:                                                         |
 |                  None                                                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-SEP-95  Subash Chadalavada  Created                                |
 |     14-Aug-02  Debbie Jancis       Modified for MRC trigger replacement   |
 |                                    added processing calls for delete from |
 |                                    ra_cust_trx_lines_gl_dist              |
 +===========================================================================*/

PROCEDURE delete_f_ct_ltctl_id_type(
             p_customer_trx_id          IN
                            ra_customer_trx.customer_trx_id%type,
             p_link_to_cust_trx_line_id IN
                            ra_customer_trx_lines.link_to_cust_trx_line_id%type,
             p_line_type                IN
                            ra_customer_trx_lines.line_type%type,
             p_account_set_flag         IN
                            ra_cust_trx_line_gl_dist.account_set_flag%type,
             p_account_class            IN
                            ra_cust_trx_line_gl_dist.account_class%type)
IS

BEGIN

   arp_util.debug('arp_ctlgd_pkg.delete_f_ct_ltctl_id_type()+');

   DELETE FROM ra_cust_trx_line_gl_dist
   WHERE  customer_trx_id  = p_customer_trx_id
   AND    customer_trx_line_id in
                 ( SELECT customer_trx_line_id
                   FROM   ra_customer_trx_lines
                   WHERE  customer_trx_id = p_customer_trx_id
                   AND    decode(p_link_to_cust_trx_line_id,
                            null, -99,
                            link_to_cust_trx_line_id) =
                                   nvl(p_link_to_cust_trx_line_id, -99)
                   AND    line_type = nvl(p_line_type, line_type)
                 )
   AND   account_set_flag     = nvl(p_account_set_flag, account_set_flag)
   AND   account_class        = nvl(p_account_class, account_class);

   arp_util.debug('arp_ctlgd_pkg.delete_f_ct_ltctl_id_type()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.delete_f_ct_ltctl_id_type()');

        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_gl_dist row identified     |
 |    by the p_cust_trx_line_gl_dist_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_cust_trx_line_gl_dist_id - identifies the row to update   |
 |               p_dist_rec                 - contains the new column values |
 |		 p_exchange_rate					     |
 |		 p_currency_code					     |
 |		 p_precision						     |
 |		 p_mau							     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_dist_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                    p_cust_trx_line_gl_dist_id  IN
                     ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
                    p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                       DEFAULT 1,
                    p_currency_code IN fnd_currencies.currency_code%type
                                       DEFAULT null,
                    p_precision     IN fnd_currencies.precision%type
                                       DEFAULT null,
                    p_mau           IN
                                 fnd_currencies.minimum_accountable_unit%type
                                       DEFAULT null)
          IS

   l_where varchar2(500);

BEGIN

   arp_util.debug('arp_ctlgd_pkg.update_p()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   l_where := ' WHERE cust_trx_line_gl_dist_id = :where_1 ' ||
            'AND  account_set_flag = nvl(:where_account_set_flag, '||
                                        'account_set_flag) ' ||
            'AND  account_class    = nvl(:where_account_class, account_class)';


   arp_ctlgd_pkg.generic_update(  pg_cursor1,
                                  l_where,
                                  p_cust_trx_line_gl_dist_id,
 				  null,
				  null,
                                  p_exchange_rate,
                                  p_currency_code,
                                  p_precision,
                                  p_mau,
                                  p_dist_rec);

   arp_util.debug('arp_ctlgd_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.update_p()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_gl_dist rows identified    |
 |    by the p_customer_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_id	    - identifies the rows to update  |
 |               p_dist_rec                 - contains the new column values |
 |	         p_account_set_flag - value is used to restrict update       |
 |		 p_account_class    - value is used to restrict update       |
 |  	         p_exchange_rate					     |
 |		 p_currency_code					     |
 |		 p_precision						     |
 |		 p_mau							     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_dist_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ct_id( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                    p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type,
                    p_account_set_flag
                         IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                    p_account_class
                         IN ra_cust_trx_line_gl_dist.account_class%type,
                    p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                       DEFAULT 1,
                    p_currency_code IN fnd_currencies.currency_code%type
                                       DEFAULT null,
                    p_precision     IN fnd_currencies.precision%type
                                       DEFAULT null,
                    p_mau           IN
                                 fnd_currencies.minimum_accountable_unit%type
                                       DEFAULT null)
          IS

   l_where varchar2(500);

BEGIN

   arp_util.debug('arp_ctlgd_pkg.update_f_ct_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   l_where := ' WHERE customer_trx_id = :where_1 ' ||
            'AND  account_set_flag = nvl(:where_account_set_flag, '||
                                        'account_set_flag) ' ||
            'AND  account_class    = nvl(:where_account_class, account_class)';

   arp_ctlgd_pkg.generic_update(  pg_cursor2,
                                  l_where,
                                  p_customer_trx_id,
                                  p_account_set_flag,
                                  p_account_class,
                                  p_exchange_rate,
                                  p_currency_code,
                                  p_precision,
                                  p_mau,
                                  p_dist_rec);

   arp_util.debug('arp_ctlgd_pkg.update_f_ct_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.update_f_ct_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_gl_dist rows identified    |
 |    by the p_customer_trx_line_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_line_id	    - identifies the rows to update  |
 |               p_dist_rec                 - contains the new column values |
 |		 p_account_set_flag       - value is used to restrict update |
 |		 p_account_class          - value is used to restrict update |
 |  	         p_exchange_rate					     |
 |		 p_currency_code					     |
 |		 p_precision						     |
 |		 p_mau							     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_dist_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ctl_id( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                           p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                         p_account_set_flag
                            IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                         p_account_class
                              IN ra_cust_trx_line_gl_dist.account_class%type,
                         p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                            DEFAULT 1,
                         p_currency_code IN fnd_currencies.currency_code%type
                                            DEFAULT null,
                         p_precision     IN fnd_currencies.precision%type
                                            DEFAULT null,
                         p_mau           IN
                                 fnd_currencies.minimum_accountable_unit%type
                                            DEFAULT null)
          IS

   l_where varchar2(500);

BEGIN

   arp_util.debug('arp_ctlgd_pkg.update_f_ctl_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   l_where := ' WHERE customer_trx_line_id = :where_1 ' ||
          'AND  account_set_flag = nvl(:where_account_set_flag, '||
                                      'account_set_flag) ' ||
          'AND  account_class    = nvl(:where_account_class, account_class)';


   arp_ctlgd_pkg.generic_update(  pg_cursor3,
   			          l_where,
                                  p_customer_trx_line_id,
                                  p_account_set_flag,
                                  p_account_class,
                                  p_exchange_rate,
                                  p_currency_code,
                                  p_precision,
                                  p_mau,
                                  p_dist_rec);

   arp_util.debug('arp_ctlgd_pkg.update_f_ctl_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.update_f_ctl_id()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ctls_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_gl_dist rows identified    |
 |    by the p_cust_trx_line_salesrep_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_cust_trx_line_salesrep_id - identifies the rows to update |
 |               p_dist_rec                 - contains the new column values |
 |		 p_account_set_flag       - value is used to restrict update |
 |		 p_account_class          - value is used to restrict update |
 |  	         p_exchange_rate					     |
 |		 p_currency_code					     |
 |		 p_precision						     |
 |		 p_mau							     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_dist_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ctls_id( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                         p_cust_trx_line_salesrep_id  IN
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                         p_account_set_flag
                            IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                         p_account_class
                               IN ra_cust_trx_line_gl_dist.account_class%type,
                         p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                            DEFAULT 1,
                         p_currency_code IN fnd_currencies.currency_code%type
                                            DEFAULT null,
                         p_precision     IN fnd_currencies.precision%type
                                            DEFAULT null,
                         p_mau           IN
                                 fnd_currencies.minimum_accountable_unit%type
                                            DEFAULT null)
          IS

   l_where varchar2(500);

BEGIN

   arp_util.debug('arp_ctlgd_pkg.update_f_ctls_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   l_where := ' WHERE cust_trx_line_salesrep_id = :where_1 ' ||
         'AND  account_set_flag = nvl(:where_account_set_flag, '||
                                     'account_set_flag) ' ||
         'AND  account_class    = nvl(:where_account_class, account_class)';

   arp_ctlgd_pkg.generic_update( pg_cursor4,
			         l_where,
                                 p_cust_trx_line_salesrep_id,
                                 p_account_set_flag,
                                 p_account_class,
                                 p_exchange_rate,
                                 p_currency_code,
                                 p_precision,
                                 p_mau,
                                 p_dist_rec);

   arp_util.debug('arp_ctlgd_pkg.update_f_ctls_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.update_f_ctls_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_acctd_amount                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |    Updates ra_cust_trx_line_gl_dist.acctd_amount for rows identified by   |
 |    the p_customer_trx_id parameter.                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_customer_trx_id     - required                           |
 |                p_base_curr_code      - required                           |
 |                p_exchange_rate       - required                           |
 |                p_base_precision      - optional                           |
 |                p_base_min_acc_unit   - optional                           |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     If p_base_precision and p_base_min_acc_unit are null,                 |
 |     arpcurr.functional_amount figures out NOCOPY what they are.    	             |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-JUL-95  Martin Johnson      Created                                |
 |     14-Aug-02  Debbie Jancis       Modified for MRC trigger replacement   |
 |				      added calls for processing updates to  |
 |				      ra_cust_trx_line_gl_dist.              |
 |     31-AUG-04  M Raymond           Added IF condition to only do MRC
 |                                    update if rows were updated in primary
 +===========================================================================*/

PROCEDURE update_acctd_amount(p_customer_trx_id IN number,
                              p_base_curr_code IN
                                fnd_currencies.currency_code%type,
                              p_exchange_rate IN
                                ra_customer_trx.exchange_rate%type,
                              p_base_precision IN
                                fnd_currencies.precision%type
                                default null,
                              p_base_min_acc_unit IN
                                fnd_currencies.minimum_accountable_unit%type
                                default null)
           IS
l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

   arp_util.debug('arp_ctlgd_pkg.update_acctd_amount()+');

   update ra_cust_trx_line_gl_dist
      set last_updated_by   = pg_user_id,
          last_update_date  = sysdate,
          last_update_login = pg_login_id,
          acctd_amount      = arpcurr.functional_amount(
                                                        amount,
                                                        p_base_curr_code,
                                                        p_exchange_rate,
                                                        p_base_precision,
                                                        p_base_min_acc_unit)
    where customer_trx_id = p_customer_trx_id
      and account_set_flag = 'N'
      and account_class <> 'REC';

    /* Bug 3858542 - Added IF condition to prevent failures in
       MRC code when no rows will be updated */
    IF (SQL%ROWCOUNT > 0 )
    THEN
       arp_standard.debug('calling mrc engine for update of gl dist data');
       ar_mrc_engine.maintain_mrc_data(
                    p_event_mode        => 'UPDATE',
                    p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                    p_mode              => 'BATCH',
                    p_key_value_list    => l_gl_dist_key_value_list);
    END IF;

   arp_util.debug('arp_ctlgd_pkg.update_acctd_amount()-');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        arp_util.debug('arp_ctlgd_pkg.update_acctd_amount()-');
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.update_acctd_amount()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_amount_f_ctl_id                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |    Updates ra_cust_trx_line_gl_dist amount columns for rows identified by |
 |    the p_customer_trx_id parameter.                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_customer_trx_id     - required                           |
 |		  p_line_amount		- required			     |
 |                p_base_curr_code      - required                           |
 |                p_exchange_rate       - required                           |
 |                p_base_precision      - optional                           |
 |                p_base_min_acc_unit   - optional                           |
 |		  p_foreign_currency    - required			     |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     If p_base_precision and p_base_min_acc_unit are null,                 |
 |     arpcurr.functional_amount figures out NOCOPY what they are. 	             |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUL-95  Martin Johnson      Created                                |
 |     14-Aug-02  Debbie Jancis       Modified for MRC trigger replacement   |
 |                                    added calls for processing updates to  |
 |                                    ra_cust_trx_line_gl_dist.              |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_amount_f_ctl_id(p_customer_trx_line_id IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                              p_line_amount IN
                                ra_customer_trx_lines.extended_amount%type,
                              p_foreign_currency_code IN
				fnd_currencies.currency_code%type,
                              p_base_curr_code IN
                                fnd_currencies.currency_code%type,
                              p_exchange_rate IN
                                ra_customer_trx.exchange_rate%type,
                              p_base_precision IN
                                fnd_currencies.precision%type
                                default null,
                              p_base_min_acc_unit IN
                                fnd_currencies.minimum_accountable_unit%type
                                default null)
           IS
l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

   arp_util.debug('arp_ctlgd_pkg.update_amount_f_ctl_id()+');

   UPDATE ra_cust_trx_line_gl_dist
      SET last_updated_by   = pg_user_id,
          last_update_date  = sysdate,
          last_update_login = pg_login_id,
          amount            = arpcurr.CurrRound(
                                                 p_line_amount *
                                                 ( percent / 100 ),
                                                 p_foreign_currency_code
                                               ),
          acctd_amount      = arpcurr.functional_amount(
                                      arpcurr.CurrRound(
                                                           p_line_amount *
                                                          ( percent / 100 ),
							p_foreign_currency_code
                                                       ),
                                                        p_base_curr_code,
                                                        p_exchange_rate,
                                                        p_base_precision,
                                                        p_base_min_acc_unit)
    WHERE customer_trx_line_id  = p_customer_trx_line_id
      AND account_set_flag      = 'N'
    RETURNING cust_trx_line_gl_dist_id
    BULK COLLECT INTO l_gl_dist_key_value_list;
   IF (SQL%ROWCOUNT > 0 ) then
   /* Used arp_global.request_id for bug3620556 */
       IF arp_global.request_id is NULL then
       arp_standard.debug('calling mrc engine for update of gl dist data');
       ar_mrc_engine.maintain_mrc_data(
                    p_event_mode        => 'UPDATE',
                    p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                    p_mode              => 'BATCH',
                    p_key_value_list    => l_gl_dist_key_value_list);
        END IF;
    END IF;
   arp_util.debug('arp_ctlgd_pkg.update_amount_f_ctl_id()-');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        arp_util.debug('arp_ctlgd_pkg.update_amount_f_ctl_id()-');
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.update_amount_f_ctl_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ra_cust_trx_line_gl_dists that       |
 |    contains the column values specified in the p_dist_rec parameter.      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arpcurr.functional_amount						     |
 |    arp_util.debug                                                         |
 |    arp_global.set_of_books_id					     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_dist_rec            - contains the new column values |
 |              OUT:                                                         |
 |                    p_cust_trx_line_gl_dist_id - unique ID of the new row  |
 |		      p_exchange_rate					     |
 |		      p_currency_code					     |
 |		      p_precision					     |
 |		      p_mau						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-JUN-95  Charlie Tomberg     Created                                |
 |     10-OCT-95  Martin Johnson      Always populate posting_control_id     |
 |                                      with -3.                             |
 |                                    Populate latest_rec_flag with 'Y'      |
 |                                      if account_class is REC, otherwise   |
 |                                      populate with null.                  |
 |     14-Aug-02  Debbie Jancis       Modified for MRC trigger replacement   |
 |                                    added calls for processing inserts to  |
 |                                    ra_cust_trx_line_gl_dist.              |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_p(
             p_dist_rec          IN ra_cust_trx_line_gl_dist%rowtype,
             p_cust_trx_line_gl_dist_id
                  OUT NOCOPY ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
             p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                DEFAULT 1,
             p_currency_code IN fnd_currencies.currency_code%type
                                DEFAULT null,
             p_precision     IN fnd_currencies.precision%type
                                DEFAULT null,
             p_mau           IN fnd_currencies.minimum_accountable_unit%type
                                DEFAULT null
                  ) IS


    l_cust_trx_line_gl_dist_id
                    ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;


BEGIN

    arp_util.debug('arp_ctlgd_pkg.insert_p()+');

    p_cust_trx_line_gl_dist_id := '';

    /*---------------------------*
     | Get the unique identifier |
     *---------------------------*/

        SELECT RA_CUST_TRX_LINE_GL_DIST_S.NEXTVAL
        INTO   l_cust_trx_line_gl_dist_id
        FROM   DUAL;


    /*-------------------*
     | Insert the record |
     *-------------------*/

     INSERT INTO ra_cust_trx_line_gl_dist
       (
          cust_trx_line_gl_dist_id,
          customer_trx_id,
          customer_trx_line_id,
          cust_trx_line_salesrep_id,
          account_class,
          percent,
          amount,
          acctd_amount,
          gl_date,
          original_gl_date,
          gl_posted_date,
          code_combination_id,
          concatenated_segments,
	  collected_tax_ccid,
	  collected_tax_concat_seg,
          comments,
          account_set_flag,
          latest_rec_flag,
          rec_offset_flag,
          ussgl_transaction_code,
          ussgl_transaction_code_context,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          set_of_books_id,
          posting_control_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          org_id,
          rounding_correction_flag,
          ccid_change_flag          /* Bug 8788491 */
       )
       VALUES
       (
          l_cust_trx_line_gl_dist_id,
          p_dist_rec.customer_trx_id,
          p_dist_rec.customer_trx_line_id,
          p_dist_rec.cust_trx_line_salesrep_id,
          p_dist_rec.account_class,
          p_dist_rec.percent,
          p_dist_rec.amount,
          nvl(
                p_dist_rec.acctd_amount,
                decode(p_dist_rec.amount,
                       null, to_number(null),
                             arpcurr.functional_amount(
                                                         p_dist_rec.amount,
 				     		         p_currency_code,
			  		                 p_exchange_rate,
					                 p_precision,
 					                 p_mau
                                                      )
                      )
             ),
          p_dist_rec.gl_date,
          p_dist_rec.original_gl_date,
          p_dist_rec.gl_posted_date,
          p_dist_rec.code_combination_id,
          p_dist_rec.concatenated_segments,
          p_dist_rec.collected_tax_ccid,
          p_dist_rec.collected_tax_concat_seg,
          p_dist_rec.comments,
          p_dist_rec.account_set_flag,
          decode(p_dist_rec.account_class,
                 'REC', 'Y',
                        null),
          p_dist_rec.rec_offset_flag,
          p_dist_rec.ussgl_transaction_code,
          p_dist_rec.ussgl_transaction_code_context,
          p_dist_rec.attribute_category,
          p_dist_rec.attribute1,
          p_dist_rec.attribute2,
          p_dist_rec.attribute3,
          p_dist_rec.attribute4,
          p_dist_rec.attribute5,
          p_dist_rec.attribute6,
          p_dist_rec.attribute7,
          p_dist_rec.attribute8,
          p_dist_rec.attribute9,
          p_dist_rec.attribute10,
          p_dist_rec.attribute11,
          p_dist_rec.attribute12,
          p_dist_rec.attribute13,
          p_dist_rec.attribute14,
          p_dist_rec.attribute15,
          arp_global.set_of_books_id,	/* set_of_books_id */
          -3,                           /* posting_control_id */
          sysdate,			/*last_update_date */
          pg_user_id,			/* last_updated_by */
          sysdate, 			/* creation_date */
          pg_user_id,			/* created_by */
          nvl(pg_conc_login_id,
              pg_login_id),		/* last_update_login */
          pg_prog_appl_id,		/* program_application_id */
          pg_conc_program_id,		/* program_id */
          sysdate,			/* program_update_date */
          arp_standard.sysparm.org_id, /* SSA changes anuj */
          p_dist_rec.rounding_correction_flag,
          p_dist_rec.ccid_change_flag   /* Bug 8788491 */
       );

   p_cust_trx_line_gl_dist_id := l_cust_trx_line_gl_dist_id;

   arp_standard.debug('calling mrc engine for INSERT of gl dist data');
   ar_mrc_engine.maintain_mrc_data(
                    p_event_mode        => 'INSERT',
                    p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                    p_mode              => 'SINGLE',
                    p_key_value         => p_cust_trx_line_gl_dist_id);

   arp_util.debug('arp_ctlgd_pkg.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.insert_p()');
	RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_summary                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Selects the total revenue percent and amount for a given transaction   |
 |    or line. This procedure is used by the forms running totals mechanism. |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_cust_trx_line_salesrep_id                            |
 |                    p_mode - the code of the alt. region displayed         |
 |                    p_account_set_flag                                     |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    p_amt_total                                            |
 |                    p_amt_total_rtot_db                                    |
 |                    p_pct_total                                            |
 |                    p_pct_total_rtot_db                                    |
 |                    p_pct_rev_total                                        |
 |                    p_pct_rev_total_rtot_db                                |
 |                    p_pct_offset_total                                     |
 |                    p_pct_offset_total_rtot_db                             |
 |                    p_pct_suspense_total                                   |
 |                    p_pct_suspense_total_rtot_db                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-OCT-95  Martin Johnson      Created                                |
 |     20-OCT-95  Martin Johnson      Added parameters:                      |
 |                                      p_account_set_flag                   |
 |                                      p_pct_rev_total                      |
 |                                      p_pct_rev_total_rtot_db              |
 |                                      p_pct_offset_total                   |
 |                                      p_pct_offset_total_rtot_db           |
 |                                      p_pct_suspense_total                 |
 |                                      p_pct_suspense_total_rtot_db         |
 |                                                                           |
 +===========================================================================*/

PROCEDURE select_summary(
                         p_customer_trx_id             IN      number,
                         p_customer_trx_line_id        IN      number,
                         p_cust_trx_line_salesrep_id   IN      number,
                         p_mode                        IN      varchar2,
                         p_account_set_flag            IN      varchar2,
                         p_amt_total                   IN OUT NOCOPY  number,
                         p_amt_total_rtot_db           IN OUT NOCOPY  number,
                         p_pct_total                   IN OUT NOCOPY  number,
                         p_pct_total_rtot_db           IN OUT NOCOPY  number,
                         p_pct_rev_total               IN OUT NOCOPY  number,
                         p_pct_rev_total_rtot_db       IN OUT NOCOPY  number,
                         p_pct_offset_total            IN OUT NOCOPY  number,
                         p_pct_offset_total_rtot_db    IN OUT NOCOPY  number,
                         p_pct_suspense_total          IN OUT NOCOPY  number,
                         p_pct_suspense_total_rtot_db  IN OUT NOCOPY  number ) IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_ctlgd_pkg.select_summary()+');
  END IF;

  SELECT NVL( SUM( NVL(amount, 0) ), 0),
         NVL( SUM( NVL(amount, 0) ), 0),
         NVL( SUM( NVL(percent, 0) ), 0),
         NVL( SUM( NVL(percent, 0) ), 0),
         NVL( SUM( DECODE(account_class,
                          'REV', NVL(percent, 0),
                          0) ), 0),
         NVL( SUM( DECODE(account_class,
                          'REV', NVL(percent, 0),
                          0) ), 0),
         NVL( SUM( DECODE(account_class,
                          'UNEARN', NVL(percent, 0),
                          'UNBILL', NVL(percent, 0),
                          0) ), 0),
         NVL( SUM( DECODE(account_class,
                          'UNEARN', NVL(percent, 0),
                          'UNBILL', NVL(percent, 0),
                          0) ), 0),
         NVL( SUM( DECODE(account_class,
                          'SUSPENSE', NVL(percent, 0),
                          0) ), 0),
         NVL( SUM( DECODE(account_class,
                          'SUSPENSE', NVL(percent, 0),
                          0) ), 0)
  INTO   p_amt_total,
         p_amt_total_rtot_db,
         p_pct_total,
         p_pct_total_rtot_db,
         p_pct_rev_total,
         p_pct_rev_total_rtot_db,
         p_pct_offset_total,
         p_pct_offset_total_rtot_db,
         p_pct_suspense_total,
         p_pct_suspense_total_rtot_db
  FROM   ra_cust_trx_line_gl_dist
  WHERE  customer_trx_id = p_customer_trx_id
    AND  customer_trx_line_id =
         DECODE(p_mode,
                'TACC_ACC_ASSGN_SREP', customer_trx_line_id,
                'TACC_ACC_SETS_SREP', customer_trx_line_id,
                p_customer_trx_line_id )
    AND  NVL( cust_trx_line_salesrep_id, -10) =
         DECODE(p_mode,
                'TACC_ACC_ASSGN_SREP', p_cust_trx_line_salesrep_id,
                'TACC_ACC_SETS_SREP', p_cust_trx_line_salesrep_id,
                NVL( cust_trx_line_salesrep_id, -10) )
    AND  account_set_flag = p_account_set_flag;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_ctlgd_pkg.select_summary()-');
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION:  arp_ctlgd_pkg.select_summary()');
   END IF;
   RAISE;

END select_summary;

  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/

BEGIN

  pg_user_id          := fnd_global.user_id;
  pg_conc_login_id    := fnd_global.conc_login_id;
  pg_login_id         := fnd_global.login_id;
  pg_prog_appl_id     := fnd_global.prog_appl_id;
  pg_conc_program_id  := fnd_global.conc_program_id;

  pg_msg_level_debug   := arp_global.MSG_LEVEL_DEBUG;

END ARP_CTLGD_PKG;

/
