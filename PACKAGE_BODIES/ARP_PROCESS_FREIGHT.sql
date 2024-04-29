--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_FREIGHT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_FREIGHT" AS
/* $Header: ARTEFRTB.pls 120.6.12010000.1 2008/07/24 16:55:59 appldev ship $ */

pg_number_dummy number;
pg_date_dummy date;

/* Bug 3604027 */
pg_base_precision          fnd_currencies.precision%type;
pg_base_min_acc_unit       fnd_currencies.minimum_accountable_unit%type;
pg_trx_header_level_rounding ar_system_parameters.TRX_HEADER_LEVEL_ROUNDING%TYPE;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_frt_line_count                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks for the number for freight lines defined at the header/line     |
 |    level. Raises exception                                                |
 |       - if more than one freight line at line/header level                |
 |       - if freight is being defined at both line/header level             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_frt_rec                                               |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE check_frt_line_count(
  p_frt_rec               IN ra_customer_trx_lines%rowtype)
IS
  l_frt_count number;

BEGIN

   arp_util.debug('arp_process_freight.check_frt_line_count()+');

   SELECT count(*)
   INTO   l_frt_count
   FROM   ra_customer_trx_lines ctl
   WHERE  ctl.customer_trx_id = p_frt_rec.customer_trx_id
   AND    ctl.line_type = 'FREIGHT'
   AND    (
           (
              ctl.link_to_cust_trx_line_id is null   /* HEADER freight */
           )
           OR
           (
              ctl.link_to_cust_trx_line_id = p_frt_rec.link_to_cust_trx_line_id
                                                     /* freight for the same LINE */
           )
           OR
           (
              p_frt_rec.link_to_cust_trx_line_id is null
                                                     /* LINE freight exits, and */
                                                     /* trying to insert HEADER */
                                                     /* freight                 */
           )
          );

   IF (l_frt_count > 0)
   THEN
      fnd_message.set_name('AR', 'AR_RAXTRX-1699');
      app_exception.raise_exception;
   END IF;

   arp_util.debug('arp_process_freight.check_frt_line_count()-');

EXCEPTION
    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION:  arp_process_freight.check_frt_line_count()');

      arp_ctl_pkg.display_line_rec(p_frt_rec);

      RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_insert_freight                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates row that is going to be inserted into ra_customer_trx_lines  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_frt_rec                                               |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE validate_insert_freight(
  p_frt_rec               IN ra_customer_trx_lines%rowtype)
IS

BEGIN

   arp_util.debug('arp_process_freight.validate_insert_freight()+');

   -- check if freight is not defined at both header and line level
   --       if multiple freight lines are being defined at header
   --          or for each line
   arp_process_freight.check_frt_line_count(p_frt_rec);

   -- other possible checks
   --     over-application for CMs
   --     freight allowed flag on transaction type

   arp_util.debug('arp_process_freight.validate_insert_freight()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_freight.validate_insert_freight()');
     RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_update_freight                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validation for the freight line that is being updated                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_frt_rec                                               |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE validate_update_freight(
  p_frt_rec               IN ra_customer_trx_lines%rowtype)
IS

BEGIN

   arp_util.debug('arp_process_freight.validate_update_freight()+');

   arp_util.debug('arp_process_freight.validate_update_freight()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_freight.validate_update_freight()');
     RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_delete_freight                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validation for the freight line that is being deleted                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_customer_trx_id                                       |
 |                   p_customer_trx_line_id                                  |
 |                   p_complete_flag                                         |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE validate_delete_freight(
  p_customer_trx_id		IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id	IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_complete_flag		IN ra_customer_trx.complete_flag%type
)
IS

BEGIN

   arp_util.debug('arp_process_freight.validate_delete_freight()+');

   IF (p_complete_flag = 'Y')
   THEN
      -- ensure that this is not the last line to be deleted
      arp_trx_validate.check_has_one_line(p_customer_trx_id);
   END IF;

   arp_util.debug('arp_process_freight.validate_delete_freight()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_freight.validate_delete_freight()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_flags                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets various change and status flags for the current record.           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_new_frt_rec                                           |
 |                   p_new_ccid                                              |
 |                   p_new_gl_date                                           |
 |              OUT:                                                         |
 |                   p_amount_changed_flag                                   |
 |                   p_ccid_changed_flag                                     |
 |                   p_gl_date_changed_flag                                  |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      12-JUL-95	Subash Chadalavada		Created              |
 |                                                                           |
 +===========================================================================*/
PROCEDURE set_flags(
  p_customer_trx_line_id    IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_new_frt_rec             IN ra_customer_trx_lines%rowtype,
  p_new_ccid                IN
                      ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_new_gl_date             IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_amount_changed_flag     OUT NOCOPY boolean,
  p_ccid_changed_flag       OUT NOCOPY boolean,
  p_gl_date_changed_flag    OUT NOCOPY boolean) IS

  l_old_frt_rec       ra_customer_trx_lines%rowtype;
  l_old_gl_date       ra_cust_trx_line_gl_dist.gl_date%type;
  l_old_ccid          ra_cust_trx_line_gl_dist.code_combination_id%type;

BEGIN
   arp_util.debug('arp_process_freight.set_flags()+');

   arp_ctl_pkg.fetch_p(l_old_frt_rec, p_customer_trx_line_id);

   IF ((p_new_frt_rec.extended_amount <> l_old_frt_rec.extended_amount)
       and
      (p_new_frt_rec.extended_amount <> pg_number_dummy))
   THEN
      p_amount_changed_flag := TRUE;
   else
      p_amount_changed_flag := FALSE;
   END IF;

   select max(code_combination_id),
          max(gl_date)
   into   l_old_ccid,
          l_old_gl_date
   from   ra_cust_trx_line_gl_dist
   where  customer_trx_line_id = p_customer_trx_line_id;

   IF (nvl(l_old_ccid, 0) <> nvl(p_new_ccid, 0)) THEN
      p_ccid_changed_flag := TRUE;
   else
      p_ccid_changed_flag := FALSE;
   END IF;

   IF ((nvl(l_old_gl_date, to_date('01-01-0001', 'DD-MM-YYYY')) <>
          nvl(p_new_gl_date, to_date('01-01-0001', 'DD-MM-YYYY')))
       AND
       (p_new_gl_date <> pg_date_dummy))
   THEN
      p_gl_date_changed_flag := TRUE;
   ELSE
      p_gl_date_changed_flag := FALSE;
   END IF;

   arp_util.debug('arp_process_freight.set_flags()-');

EXCEPTION
   WHEN OTHERS THEN
     arp_util.debug('arp_process_freight.set_flags()');
     arp_util.debug('customer_trx_line_id : '||
                     p_new_frt_rec.customer_trx_line_id);
     arp_util.debug('p_new_ccid           : '||p_new_ccid);
     arp_util.debug('p_new_gl_date        : '||p_new_gl_date);
     RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_freight                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a freight record into RA_CUSTOMER_TRX_LINES                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_trx_class                                            |
 |                    p_gl_date                                              |
 |                    p_frt_ccid                                             |
 |              OUT:                                                         |
 |                    p_customer_trx_line_id                                 |
 |                    p_status                                               |
 |          IN/ OUT:                                                         |
 |                    p_frt_rec                                              |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      12-JUL-95	Subash Chadalavada		Created              |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_freight(
  p_form_name			IN varchar2,
  p_form_version		IN number,
  p_frt_rec			IN OUT NOCOPY ra_customer_trx_lines%rowtype,
  p_trx_class			IN ra_cust_trx_types.type%type,
  p_gl_date			IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_frt_ccid			IN
                          ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_customer_trx_line_id	OUT NOCOPY
                          ra_customer_trx_lines.customer_trx_line_id%type,
  p_status                      OUT NOCOPY varchar2,
  p_run_autoacc_flag      IN varchar2  DEFAULT 'Y')

IS

  l_customer_trx_line_id	ra_customer_trx_lines.customer_trx_line_id%type;
  l_result			integer;
  l_ccid
			ra_cust_trx_line_gl_dist.code_combination_id%type;
  l_concat_segments		varchar2(200);
  l_num_failed_dist_rows	number;
  l_rows_processed		number;
  l_errorbuf			varchar2(200);

  /* bug 3604027 */
  l_error_message VARCHAR2(128) := '';
  l_dist_count NUMBER;

BEGIN

   arp_util.debug('arp_process_freight.insert_freight()+');

   p_status := 'OK';

   -- check form version to determine IF it is compatible with the
   -- entity handler.
   arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

   -- Lock rows in other tables that reference this customer_trx_id
   arp_trx_util.lock_transaction(p_frt_rec.customer_trx_id);

   --
   -- !!!! NEED TO CHECK FOR OVERAPPLICATION FOR CMS !!!!
   --

   -- do validation

   arp_process_freight.validate_insert_freight(p_frt_rec);

   /*--------------------+
    |  pre-insert logic  |
    +--------------------*/

   IF (p_trx_class = 'CM') THEN
       p_frt_rec.revenue_amount := p_frt_rec.extended_amount;
   END IF;

   -- call table handler
   ARP_CTL_PKG.insert_p(p_frt_rec, l_customer_trx_line_id);

   p_customer_trx_line_id := l_customer_trx_line_id;
   /*--------------------+
    | post-insert logic  |
    +--------------------*/
   -- call auto-accounting to insert the freight distribution

   IF ( p_run_autoacc_flag = 'Y' )
   THEN

         BEGIN
             arp_auto_accounting.do_autoaccounting(
                                      'I',
                                      'FREIGHT',
                                      p_frt_rec.customer_trx_id,
                                      l_customer_trx_line_id,
                                      null,
                                      null,
                                      p_gl_date,
                                      null,
                                      p_frt_rec.extended_amount,
                                      p_frt_ccid,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      l_ccid,
                                      l_concat_segments,
                                      l_num_failed_dist_rows);

             /* Bug 3604027 */
             IF  arp_rounding.correct_dist_rounding_errors(
                                        NULL,
                                        p_frt_rec.customer_trx_id ,
                                        l_customer_trx_line_id,
                                        l_dist_count,
                                        l_error_message ,
                                        pg_base_precision ,
                                        pg_base_min_acc_unit ,
                                        'ALL' ,
                                        NULL,
                                        'N' ,
                                        pg_trx_header_level_rounding ,
                                        'N',
                                        'N') = 0 -- FALSE
             THEN
                arp_util.debug('EXCEPTION:  Insert Freight');
                arp_util.debug(l_error_message);
                fnd_message.set_name('AR', 'AR_PLCRE_FHLR_CCID');
                APP_EXCEPTION.raise_exception;
             END IF;
         EXCEPTION
           WHEN arp_auto_accounting.no_ccid THEN
             p_status := 'ARP_AUTO_ACCOUNTING.NO_CCID';
           WHEN NO_DATA_FOUND THEN
             null;
           WHEN OTHERS THEN
             RAISE;
         END;

   END IF;

   --
   -- The payment schedule record will be updated in the post-commit logic
   --
   arp_util.debug('arp_process_freight.insert_freight()-');

EXCEPTION
   when OTHERS THEN
     -- display all relevent information
     arp_util.debug('EXCEPTION: arp_process_freight.insert_freight()');
     arp_util.debug('  p_form_name            : '||p_form_name );
     arp_util.debug('  p_form_version         : '||p_form_version);
     arp_util.debug('  p_trx_class            : '||p_trx_class);
     arp_util.debug('  p_gl_date              : '||p_gl_date);
     arp_util.debug('  p_frt_ccid             : '||p_frt_ccid);

     arp_ctl_pkg.display_line_rec(p_frt_rec);
     RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_freight                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates freight record in RA_CUSTOMER_TRX_LINES                        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_trx_class                                            |
 |                    p_gl_date                                              |
 |                    p_frt_ccid                                             |
 |                    p_complete_flag                                        |
 |                    p_open_rec_flag                                        |
 |              OUT:                                                         |
 |                    p_status                                               |
 |          IN/ OUT:                                                         |
 |                    p_frt_rec                                              |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      12-JUL-95       Subash Chadalavada              Created              |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_freight(
  p_form_name                   IN varchar2,
  p_form_version                IN number,
  p_customer_trx_id             IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id        IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_frt_rec                     IN OUT NOCOPY ra_customer_trx_lines%rowtype,
  p_trx_class                   IN ra_cust_trx_types.type%type,
  p_gl_date			IN
                        ra_cust_trx_line_gl_dist.gl_date%type,
  p_frt_ccid			IN
                        ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_complete_flag               IN varchar2,
  p_open_rec_flag               IN varchar2,
  p_status                      OUT NOCOPY varchar2)
IS

  l_amount_changed_flag         boolean;
  l_ccid_changed_flag           boolean;
  l_gl_date_changed_flag        boolean;

  /* bug 3604027 */
  l_error_message VARCHAR2(128) := '';
  l_dist_count NUMBER;


BEGIN
   arp_util.debug('arp_process_freight.update_freight()+');

   -- check form version to determine IF it is compatible with the
   -- entity handler.
   arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

   -- Lock rows in other tables that reference this customer_trx_id
   arp_trx_util.lock_transaction(p_customer_trx_id);

   --
   -- !!!! NEED TO CHECK FOR OVERAPPLICATION FOR CMs !!!!
   --
   IF (p_trx_class = 'CM') THEN
       -- validate for overapplication, sign
       -- populate revenue amounts
       IF (p_frt_rec.extended_amount <> pg_number_dummy)
       THEN
          p_frt_rec.revenue_amount := p_frt_rec.extended_amount;
       END IF;
   END IF;


   -- do validation

   arp_process_freight.validate_update_freight(p_frt_rec);

   /*--------------------+
    |  pre-update logic  |
    +--------------------*/
   -- none
   arp_process_freight.set_flags(p_customer_trx_line_id,
                                 p_frt_rec,
                                 p_frt_ccid,
                                 p_gl_date,
                                 l_amount_changed_flag,
                                 l_ccid_changed_flag,
                                 l_gl_date_changed_flag);

   -- call the table handler
   arp_ctl_pkg.update_p(p_frt_rec, p_customer_trx_line_id);

   /*--------------------+
    |  post-update logic |
    +--------------------*/
   IF ((l_amount_changed_flag  = TRUE)
       OR
       (l_ccid_changed_flag    = TRUE)
       OR
       (l_gl_date_changed_flag = TRUE))
   THEN
      IF p_trx_class in ('INV', 'DM')
      THEN
         -- update the distribution record
         arp_process_invoice.freight_post_update(
                                p_frt_rec,
                                p_gl_date,
                                p_frt_ccid,
                                p_status);
      ELSE
         -- call the credit memo module to update the distribution
         -- record and other CM tables
         arp_process_credit.freight_post_update(
                                p_frt_rec,
                                p_gl_date,
                                p_frt_ccid);
      END IF;

   END IF;
   /* Bug 3604027 */
   IF  arp_rounding.correct_dist_rounding_errors(
                                        NULL,
                                        p_frt_rec.customer_trx_id ,
                                        p_customer_trx_line_id,
                                        l_dist_count,
                                        l_error_message ,
                                        pg_base_precision ,
                                        pg_base_min_acc_unit ,
                                        'ALL' ,
                                        NULL,
                                        'N' ,
                                        pg_trx_header_level_rounding ,
                                        'N',
                                        'N') = 0 -- FALSE
   THEN
      arp_util.debug('EXCEPTION:  Update Freight');
      arp_util.debug(l_error_message);
      fnd_message.set_name('AR', 'AR_PLCRE_FHLR_CCID');
      APP_EXCEPTION.raise_exception;
   END IF;


   arp_util.debug('arp_process_freight.update_freight()-');


EXCEPTION
   WHEN OTHERS THEN
   -- display all relevent information
   arp_util.debug('EXCEPTION: arp_process_freight.update_freight()');
   arp_util.debug('p_form_name            : '||p_form_name );
   arp_util.debug('p_form_version         : '||p_form_version);
   arp_util.debug('p_frt_ccid             : '||p_frt_ccid);
   arp_util.debug('p_gl_date              : '||p_gl_date);
   arp_util.debug('p_trx_class            : '||p_trx_class);
   arp_util.debug('p_complete_flag        : '||p_complete_flag);
   arp_util.debug('p_open_rec_flag        : '||p_open_rec_flag);

   arp_ctl_pkg.display_line_p(p_frt_rec.customer_trx_line_id);

   RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_freight                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes freight record from RA_CUSTOMER_TRX_LINES                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_trx_class                                            |
 |                    p_complete_flag                                        |
 |                    p_open_rec_flag                                        |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      12-JUL-95       Subash Chadalavada              Created              |
 |                                                                           |
 +===========================================================================*/


PROCEDURE delete_freight(
  p_form_name                   IN varchar2,
  p_form_version                IN number,
  p_trx_class                   IN ra_cust_trx_types.type%type,
  p_complete_flag		IN varchar2,
  p_open_rec_flag		IN varchar2,
  p_customer_trx_id             IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id        IN ra_customer_trx_lines.customer_trx_line_id%type)
IS
  l_gt_one_line			BOOLEAN;

  /* bug 3604027 */
  l_error_message VARCHAR2(128) := '';
  l_dist_count NUMBER;

BEGIN

   arp_util.debug('arp_process_freight.delete_freight()+');

   --
   -- check form version to determine IF it is compatible with the
   -- entity handler.
   --
   arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

   -- Lock rows in other tables that reference this customer_trx_id
   arp_trx_util.lock_transaction(p_customer_trx_id);

   -- do validation
   arp_process_freight.validate_delete_freight(p_customer_trx_id,
                                               p_customer_trx_line_id,
                                               p_complete_flag);

   /*--------------------+
    |  pre-delete logic  |
    +--------------------*/

   -- delete the distribution record
   arp_ctlgd_pkg.delete_f_ctl_id(p_customer_trx_line_id, null, null);

   -- call the table handler
   arp_ctl_pkg.delete_p(p_customer_trx_line_id);

   /*--------------------+
    |  post-delete logic |
    +--------------------*/
   /* Bug 3604027 */
   IF  arp_rounding.correct_dist_rounding_errors(
                                        NULL,
                                        p_customer_trx_id ,
                                        p_customer_trx_line_id,
                                        l_dist_count,
                                        l_error_message ,
                                        pg_base_precision ,
                                        pg_base_min_acc_unit ,
                                        'ALL' ,
                                        NULL,
                                        'N' ,
                                        pg_trx_header_level_rounding ,
                                        'N',
                                        'N') = 0 -- FALSE
   THEN
      arp_util.debug('EXCEPTION:  Delete Freight');
      arp_util.debug(l_error_message);
      fnd_message.set_name('AR', 'AR_PLCRE_FHLR_CCID');
      APP_EXCEPTION.raise_exception;
   END IF;

   arp_util.debug('arp_process_freight.delete_freight()-');

EXCEPTION

  WHEN OTHERS THEN
     -- display all relevent information
     arp_util.debug('EXCEPTION: ARP_PROCESS_FREIGHT.delete_freight()');
     arp_util.debug('p_form_name            : '||p_form_name );
     arp_util.debug('p_form_version         : '||p_form_version);
     arp_util.debug('p_customer_trx_id      : '||p_customer_trx_id);
     arp_util.debug('p_customer_trx_line_id : '||p_customer_trx_line_id);
     arp_util.debug('p_trx_class            : '||p_trx_class);
     arp_util.debug('p_complete_flag        : '||p_complete_flag);

     arp_ctl_pkg.display_line_p(p_customer_trx_line_id);
     RAISE;
END;

PROCEDURE init IS
BEGIN
    pg_number_dummy       := arp_ctl_pkg.get_number_dummy;
    pg_date_dummy         := arp_ct_pkg.get_date_dummy;

    /* bug 3604027 */
    pg_base_precision    := arp_global.base_precision;
    pg_base_min_acc_unit := arp_global.base_min_acc_unit;
    pg_trx_header_level_rounding  := arp_global.sysparam.trx_header_level_rounding;
END init;

BEGIN
  init;
END ARP_PROCESS_FREIGHT;

/
