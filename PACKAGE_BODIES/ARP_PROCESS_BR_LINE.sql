--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_BR_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_BR_LINE" AS
/* $Header: ARTEBRLB.pls 120.9 2005/08/10 23:15:35 hyu ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_line							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ra_customer_trx_lines for bills receivable       |
 |    transaction.			                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:   p_line_rec					     |
 |              OUT:  p_customer_trx_line_id				     |
 |          IN/ OUT:							     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      28-MAR-2000  Jani Rautiainen Created                                 |
 |                                                                           |
 +===========================================================================*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE insert_line(p_line_rec		IN OUT NOCOPY ra_customer_trx_lines%rowtype,
                      p_customer_trx_line_id    OUT NOCOPY    ra_customer_trx_lines.customer_trx_line_id%type) IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_br_line.insert_line()+');
  END IF;

  /*------------------------------------------------+
   |  All the validation and defaulting is done in  |
   |  the BR API, so none is done in the entity     |
   |  handler.                                      |
   +------------------------------------------------*/

  /*----------------------------------------------------------------+
   | Lock rows in other tables that reference this customer_trx_id  |
   +----------------------------------------------------------------*/
  arp_process_br_header.lock_transaction(p_line_rec.customer_trx_id);

  /*----------------------------------------------+
   |  Call the table handler to insert the line   |
   +----------------------------------------------*/

  arp_ctl_pkg.insert_p( p_line_rec,
                        p_customer_trx_line_id);

  /*----------------------------------------+
   |  BR has no Sales Credit, terms or tax  |
   +----------------------------------------*/

  /*------------------------------------------+
   |  Call MRC logic to create MRC rows       |
   +------------------------------------------*/
-- No longer required as arp_ctl_pkg.insert_p does insert the mrc customer_trx_lines
--   ARP_PROCESS_BR_LINE.insert_mrc_transaction_line(p_line_rec,
--                                                   p_customer_trx_line_id);

  /*---------------------------------------------------------------------------+
   |  All accounting is done in the accounting engine called by transaction    |
   |  history entity handler                                                   |
   +---------------------------------------------------------------------------*/

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_br_line.insert_line()-');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_br_line.insert_line()');
        END IF;
        arp_ctl_pkg.display_line_rec(p_line_rec);
        RAISE;

END insert_line;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_line			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a ra_customer_trx_lines record for Bills Receivable            |
 |    transaction lines.                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:   p_customer_trx_line_id 				     |
 |                    p_line_rec					     |
 |              OUT:                                                         |
 |           IN OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      28-MAR-2000  Jani Rautiainen Created                                 |
 |                                                                           |
 +===========================================================================*/


PROCEDURE update_line(p_customer_trx_line_id  IN     ra_customer_trx_lines.customer_trx_line_id%type,
                      p_line_rec              IN OUT NOCOPY ra_customer_trx_lines%rowtype) IS


BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_br_line.update_line()+');
  END IF;

  /*------------------------------------------------+
   |  All the validation and defaulting is done in  |
   |  the BR API, so none is done in the entity     |
   |  handler.                                      |
   +------------------------------------------------*/

  /*----------------------------------------------------------------+
   | Lock rows in other tables that reference this customer_trx_id  |
   +----------------------------------------------------------------*/

  arp_process_br_header.lock_transaction(p_line_rec.customer_trx_id);

  /*---------------------------------------------+
   |  Call the table handler to update the line  |
   +---------------------------------------------*/

  arp_ctl_pkg.update_p( p_line_rec,
                        p_customer_trx_line_id,
                        NULL);

  /*----------------------------------------+
   |  BR has no Sales Credit, terms or tax  |
   +----------------------------------------*/

  /*------------------------------------------+
   |  Call MRC logic to create MRC rows       |
   +------------------------------------------*/
-- No longer required as the procedure arp_ctl_pkg.update_p does the updation of mrc trx lines

--   ARP_PROCESS_BR_LINE.update_mrc_transaction_line(p_line_rec,
--                                                   p_customer_trx_line_id);

  /*---------------------------------------------------------------------------+
   |  All accounting is done in the accounting engine called by transaction    |
   |  history entity handler                                                   |
   +---------------------------------------------------------------------------*/

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_br_line.update_line()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_process_br_line.update_line()');
    END IF;
    arp_ctl_pkg.display_line_rec(p_line_rec);
    RAISE;

END update_line;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_line			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes records from ra_customer_trx_lines for Bills Receivable        |
 |    transaction lines                                                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:   p_customer_trx_line_id				     |
 |                    p_line_rec 					     |
 |              IN / OUT:                                                    |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      28-MAR-2000  Jani Rautiainen Created                                 |
 |                                                                           |
 +===========================================================================*/

PROCEDURE delete_line(p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%type,
                      p_customer_trx_id      IN ra_customer_trx.customer_trx_id%type) IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_br_line.delete_line()+');
  END IF;

  /*------------------------------------------------+
   |  All the validation and defaulting is done in  |
   |  the BR API, so none is done in the entity     |
   |  handler.                                      |
   +------------------------------------------------*/

  /*----------------------------------------------------------------+
   | Lock rows in other tables that reference this customer_trx_id  |
   +----------------------------------------------------------------*/
  arp_process_br_header.lock_transaction(p_customer_trx_id);

  /*-----------------------------------------------------+
   |  call the table-handler to delete the line record   |
   +-----------------------------------------------------*/

  arp_ctl_pkg.delete_p( p_customer_trx_line_id );

  /*----------------------------------------+
   |  BR has no Sales Credit, terms or tax  |
   +----------------------------------------*/

  /*------------------------------------------+
   |  Call MRC logic to create MRC rows       |
   +------------------------------------------*/
-- Should be removed as the arp_ctl_pkg.delete_p does the deletion of mrc lines
--   ARP_PROCESS_BR_LINE.delete_mrc_transaction_line(p_customer_trx_line_id);

  /*---------------------------------------------------------------------------+
   |  All accounting is done in the accounting engine called by transaction    |
   |  history entity handler                                                   |
   +---------------------------------------------------------------------------*/

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_br_line.delete_line()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_process_br_line.delete_line()');
       arp_util.debug('delete_line: ' || 'p_customer_trx_line_id      = ' || p_customer_trx_line_id);
    END IF;
    RAISE;

END delete_line;


END ARP_PROCESS_BR_LINE;

/
