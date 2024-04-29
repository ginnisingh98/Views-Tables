--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_FREIGHT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_FREIGHT_UTIL" AS
/* $Header: ARTEFR1B.pls 115.6 2003/10/10 14:28:17 mraymond ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

pg_number_dummy number;
pg_date_dummy date;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    default_freight_line                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to default values for a freight line                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_form_name                                             |
 |                   p_form_version                                          |
 |                   p_ct_id                                                 |
 |                   p_line_ctl_id                                           |
 |                   p_prev_ct_id                                            |
 |                   p_cust_trx_type_id                                      |
 |                   p_primary_salesrep_id                                   |
 |                   p_inventory_item_id                                     |
 |                   p_memo_line_id                                          |
 |                   p_currency_code                                         |
 |              OUT:                                                         |
 |                   p_line_prev_ctl_id                                      |
 |                   p_prev_ctl_id                                           |
 |                   p_amount                                                |
 |                   p_inv_line_number                                       |
 |                   p_inv_frt_ccid                                          |
 |                   p_inv_frt_amount                                        |
 |                   p_inv_frt_uncr_amount                                   |
 |                   p_ccid                                                  |
 |                   p_concat_segments                                       |
 |                   p_ussgl_code                                            |
 |                   p_ct_id                                                 |
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

PROCEDURE default_freight_line(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_line_ctl_id           IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_prev_ct_id            IN ra_customer_trx.customer_trx_id%type,
  p_cust_trx_type_id      IN ra_customer_trx.cust_trx_type_id%type,
  p_primary_salesrep_id   IN ra_customer_trx.cust_trx_type_id%type,
  p_inventory_item_id     IN ra_customer_trx_lines.inventory_item_id%type,
  p_memo_line_id          IN ra_customer_trx_lines.memo_line_id%type,
  p_currency_code         IN fnd_currencies.currency_code%type,
  p_line_prev_ctl_id  IN OUT NOCOPY ra_customer_trx_lines.customer_trx_line_id%type,
  p_prev_ctl_id          OUT NOCOPY ra_customer_trx_lines.customer_trx_line_id%type,
  p_amount               OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_inv_line_number      OUT NOCOPY ra_customer_trx_lines.line_number%type,
  p_inv_frt_ccid         OUT NOCOPY ra_customer_trx_lines.line_number%type,
  p_inv_frt_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_inv_frt_uncr_amount  OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_ccid                 OUT NOCOPY ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_concat_segments      OUT NOCOPY ra_cust_trx_line_gl_dist.concatenated_segments%type,
  p_ussgl_code           OUT NOCOPY ra_customer_trx.default_ussgl_transaction_code%type)
IS
  l_inv_ctl_id           ra_customer_trx_lines.customer_trx_line_id%type;
  l_inv_frt_ctl_id       ra_customer_trx_lines.customer_trx_line_id%type;
  l_inv_frt_ccid         ra_cust_trx_line_gl_dist.code_combination_id%type;
  l_inv_prev_ctl_id      ra_customer_trx_lines.customer_trx_line_id%type;
  l_inv_line_number      ra_customer_trx_lines.line_number%type;
  l_amount               ra_customer_trx_lines.extended_amount%type;
  l_line_ussgl_code      ra_customer_trx_lines.default_ussgl_transaction_code%type;
  l_header_ussgl_code    ra_customer_trx.default_ussgl_transaction_code%type;
  l_inventory_item_id    ra_customer_trx_lines.inventory_item_id%type := p_inventory_item_id;
  l_memo_line_id         ra_customer_trx_lines.memo_line_id%type := p_memo_line_id;
  l_warehouse_id         ra_customer_trx_lines.warehouse_id%type := '';

  l_inv_line_extended_amount   ra_customer_trx_lines.extended_amount%type;
  l_line_extended_amount       ra_customer_trx_lines.extended_amount%type;
  l_inv_frt_amount             ra_customer_trx_lines.extended_amount%type;
  l_inv_frt_uncr_amount        ra_customer_trx_lines.extended_amount%type;

  l_ccid               number;
  l_num_failed_rows    number;
  l_result             number;
  l_concat_segments    varchar2(2000);
  l_errorbuf           varchar2(200);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('get_default_fob: ' || 'arp_process_freight.default_freight_line()+');
  END IF;

   --
   -- get the line_id that the parent line is crediting, if one is not passed
   --
   IF (p_line_prev_ctl_id IS NULL
       AND
       p_line_ctl_id IS NOT NULL)
   THEN

       SELECT previous_customer_trx_line_id,
              inventory_item_id,
              memo_line_id,
              extended_amount,
              default_ussgl_transaction_code
       INTO   l_inv_prev_ctl_id,
              l_inventory_item_id,
              l_memo_line_id,
              l_line_extended_amount,
              l_line_ussgl_code
       FROM   ra_customer_trx_lines
       WHERE  customer_trx_id = p_ct_id
       AND    customer_trx_line_id = p_line_ctl_id;
  ELSE
      l_inv_prev_ctl_id := p_line_prev_ctl_id;
  END IF;

  IF (p_prev_ct_id IS NOT NULL)
  THEN

      --
      -- get credited freight line information
      --

      SELECT ctl_inv.ctl_line_line_number,
             ctl_inv.ctl_line_extended_amount,
             ctl_inv.customer_trx_line_id,
             ctl_inv.lgd_code_combination_id,
             ctl_inv.extended_amount,
             ctl_inv.ctl_frt_balance
      INTO   l_inv_line_number,
             l_inv_line_extended_amount,
             l_inv_frt_ctl_id,
             l_inv_frt_ccid,
             l_inv_frt_amount,
             l_inv_frt_uncr_amount
      FROM   RA_CUSTOMER_TRX_LINES_FRT_V ctl_inv
      WHERE  ctl_inv.customer_trx_id = p_prev_ct_id
      AND    nvl(ctl_inv.link_to_cust_trx_line_id, -10)
                       = nvl(l_inv_prev_ctl_id, -10);

  END IF;

  IF (l_inv_prev_ctl_id IS NOT NULL) THEN
   --points to the line credited so get the warehouse id
     select ctl.warehouse_id
     into   l_warehouse_id
     from   ra_customer_trx_lines ctl
     where ctl.customer_trx_line_id = l_inv_prev_ctl_id;
  END IF;

  IF (p_line_prev_ctl_id IS NULL)
  THEN p_line_prev_ctl_id := l_inv_prev_ctl_id;
  END IF;

  p_prev_ctl_id          := l_inv_frt_ctl_id;
  p_inv_line_number      := l_inv_line_number;
  p_inv_frt_amount       := l_inv_frt_amount;
  p_inv_frt_uncr_amount  := l_inv_frt_uncr_amount;
  p_inv_frt_ccid         := l_inv_frt_ccid;
  p_ussgl_code           := l_line_ussgl_code;

  BEGIN
      ARP_AUTO_ACCOUNTING.do_autoaccounting(
                                'G',
                                'FREIGHT',
                                p_ct_id,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                p_cust_trx_type_id,
                                p_primary_salesrep_id,
                                l_inventory_item_id,
                                l_memo_line_id,
                                l_warehouse_id,
                                l_ccid,
                                l_concat_segments,
                                l_num_failed_rows);


      p_ccid            := l_ccid;
      p_concat_segments := l_concat_segments;

   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       null;
     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


  IF ( l_memo_line_id IS NOT NULL)
  THEN

      SELECT unit_std_price
      INTO   l_amount
      FROM   ar_memo_lines
      WHERE  memo_line_id = l_memo_line_id;

  ELSIF (p_prev_ct_id IS NOT NULL)
  THEN

     IF (nvl(l_inv_line_extended_amount, 0) <> 0)
     THEN

         l_amount := arpcurr.CurrRound(
                         (nvl(l_line_extended_amount, 0) /
                              l_inv_line_extended_amount) * l_inv_frt_amount,
                          p_currency_code);

     END IF;
  END IF;

  p_amount := l_amount;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('get_default_fob: ' || 'arp_process_freight.default_freight_line()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_default_fob: ' || 'EXCEPTION : arp_process_freight.default_freight_line()');
       arp_util.debug('get_default_fob: ' || 'p_form_name             : '||p_form_name);
       arp_util.debug('get_default_fob: ' || 'p_form_version          : '||p_form_version);
       arp_util.debug('get_default_fob: ' || 'p_ct_id                 : '||p_ct_id);
       arp_util.debug('get_default_fob: ' || 'p_line_ctl_id           : '||p_line_ctl_id);
       arp_util.debug('get_default_fob: ' || 'p_prev_ct_id            : '||p_prev_ct_id);
       arp_util.debug('get_default_fob: ' || 'p_cust_trx_type_id      : '||p_cust_trx_type_id);
       arp_util.debug('get_default_fob: ' || 'p_primary_salesrep_id   : '||p_primary_salesrep_id);
       arp_util.debug('get_default_fob: ' || 'p_inventory_item_id     : '||p_inventory_item_id);
       arp_util.debug('get_default_fob: ' || 'p_memo_line_id          : '||p_memo_line_id);
       arp_util.debug('get_default_fob: ' || 'p_currency_code         : '||p_currency_code);
    END IF;
    RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_freight_type                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the level at which freight is defined for the    |
 |    transaction.                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : 'H' if header level freight                                  |
 |              'L' if line level freight                                    |
 |              ''  if freight is defined for the transaction                |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-OCT-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/


FUNCTION get_freight_type(
  p_customer_trx_id IN ra_customer_trx.customer_trx_id%type) RETURN varchar2
IS
  l_frt_type varchar2(1);
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('get_default_fob: ' || 'arp_process_freight.get_freight_type()+');
  END IF;

  SELECT decode(count(*),
           0, null,
           decode(max(link_to_cust_trx_line_id),
             null, 'H',
             'L'))
  INTO   l_frt_type
  FROM   ra_customer_trx_lines ctl
  WHERE  ctl.customer_trx_id = p_customer_trx_id
  AND    ctl.line_type = 'FREIGHT';

  return(l_frt_type);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('get_default_fob: ' || 'arp_process_freight.get_freight_type()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_default_fob: ' || 'EXCEPTION : arp_process_freight.get_freight_type()');
       arp_util.debug('get_default_fob: ' || 'p_customer_trx_id        : '||p_customer_trx_id);
    END IF;

    RAISE;
END get_freight_type;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_frt_lines                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to delete all freight lines for a transaction                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_form_name                                             |
 |                   p_form_version                                          |
 |                   p_trx_class                                             |
 |                   p_complete_flag                                         |
 |                   p_open_rec_flag                                         |
 |                   p_customer_trx_id                                       |
 |              OUT:                                                         |
 |                   None                                                    |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_frt_lines(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_complete_flag         IN varchar2,
  p_open_rec_flag         IN varchar2,
  p_customer_trx_id       IN ra_customer_trx.customer_trx_id%type)
IS

  CURSOR frt_lines(p_ct_id ra_customer_trx.customer_trx_id%type) IS
  SELECT customer_trx_line_id
  FROM   ra_customer_trx_lines
  WHERE  customer_trx_id = p_ct_id
  AND    line_type = 'FREIGHT';

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('get_default_fob: ' || 'arp_process_freight_util.delete_frt_lines()+');
   END IF;

   /*--------------------------------------------------------+
    | call the delete handler for each of the freight lines  |
    +--------------------------------------------------------*/
   FOR frt_line_rec IN frt_lines(p_customer_trx_id) LOOP

       arp_process_freight.delete_freight(
             p_form_name,
             p_form_version,
             p_trx_class,
             p_complete_flag,
             p_open_rec_flag,
             p_customer_trx_id,
             frt_line_rec.customer_trx_line_id);

   END LOOP;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('get_default_fob: ' || 'arp_process_freight_util.delete_frt_lines()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_default_fob: ' || 'EXCEPTION : arp_process_freight_util.delete_frt_lines');
       arp_util.debug('get_default_fob: ' || 'p_form_name            : '||p_form_name);
       arp_util.debug('get_default_fob: ' || 'p_form_version         : '||p_form_version);
       arp_util.debug('get_default_fob: ' || 'p_trx_class            : '||p_trx_class);
       arp_util.debug('get_default_fob: ' || 'p_complete_flag        : '||p_complete_flag);
       arp_util.debug('get_default_fob: ' || 'p_open_rec_flag        : '||p_open_rec_flag);
       arp_util.debug('get_default_fob: ' || 'p_customer_trx_id      : '||p_customer_trx_id);
    END IF;
    RAISE;
END delete_frt_lines;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_default_fob
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to select the default fob_point.
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_form_name                                             |
 |                   p_form_version                                          |
 |                   p_trx_class                                             |
 |                   p_complete_flag                                         |
 |                   p_open_rec_flag                                         |
 |                   p_customer_trx_id                                       |
 |              OUT:                                                         |
 |                   None                                                    |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |	Use the following hierarchy to default fob:
 |	1) From Ship to site use
 |	2) From bill to site use
 |	3) From ship to customer
 |	4) From bill to customer
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |	9/4/1996	Harri Kaukovuo	Created
 +===========================================================================*/
PROCEDURE get_default_fob(
	  pn_SHIP_TO_SITE_USE_ID		IN NUMBER
	, pn_BILL_TO_SITE_USE_ID		IN NUMBER
	, pn_SHIP_TO_CUSTOMER_ID		IN NUMBER
	, pn_BILL_TO_CUSTOMER_ID		IN NUMBER
	, pc_fob_point				OUT NOCOPY VARCHAR2
	, pc_fob_point_name			OUT NOCOPY VARCHAR2) IS
lc_fob_point		ar_lookups.lookup_code%TYPE;
lc_fob_point_name	ar_lookups.meaning%TYPE;

BEGIN
  IF (pn_SHIP_TO_SITE_USE_ID IS NOT NULL)
  THEN
    begin
	SELECT    l.LOOKUP_CODE
       		, l.MEANING
  	INTO
		  lc_fob_point
		, lc_fob_point_name
  	FROM 	  AR_LOOKUPS L
	       	, HZ_CUST_SITE_USES site_uses
 	WHERE site_uses.SITE_USE_ID = pn_SHIP_TO_SITE_USE_ID
   	AND L.LOOKUP_TYPE = 'FOB'
   	AND L.LOOKUP_CODE = site_uses.FOB_POINT
   	AND L.ENABLED_FLAG = 'Y'
   	AND TRUNC(SYSDATE) BETWEEN L.START_DATE_ACTIVE
                          AND NVL(L.END_DATE_ACTIVE, TRUNC(SYSDATE));
    exception
      when no_data_found then
        null;
      when others then
        raise;
    end;

    -- Return immediately if FOB point was found
    IF (lc_fob_point IS NOT NULL)
    THEN
      pc_fob_point        := lc_fob_point;
      pc_fob_point_name   := lc_fob_point_name;
      RETURN;
    END IF;

  end if;

  -- ---------------------------------------------------------
  -- The one who seeks, will find the treasure ...
  -- Search with bill-to customer site
  -- ---------------------------------------------------------
  IF (pn_BILL_TO_SITE_USE_ID IS NOT NULL)
  THEN
    begin
        SELECT    l.LOOKUP_CODE
                , l.MEANING
        INTO
                  lc_fob_point
                , lc_fob_point_name
        FROM      AR_LOOKUPS L
                , HZ_CUST_SITE_USES site_uses
        WHERE site_uses.SITE_USE_ID = pn_BILL_TO_SITE_USE_ID
        AND L.LOOKUP_TYPE = 'FOB'
        AND L.LOOKUP_CODE = site_uses.FOB_POINT
        AND L.ENABLED_FLAG = 'Y'
        AND TRUNC(SYSDATE) BETWEEN L.START_DATE_ACTIVE
                          AND NVL(L.END_DATE_ACTIVE, TRUNC(SYSDATE));
    exception
      when no_data_found then
        null;
      when others then
        raise;
    end;

    -- Return immediately if FOB point was found
    IF (lc_fob_point IS NOT NULL)
    THEN
      pc_fob_point        := lc_fob_point;
      pc_fob_point_name   := lc_fob_point_name;
      RETURN;
    END IF;

  end if;


  -- ---------------------------------------------------------
  -- Search with ship to customer
  -- ---------------------------------------------------------
  IF (pn_SHIP_TO_CUSTOMER_ID IS NOT NULL)
  THEN
    begin
        /* modified for tca uptake */
        SELECT    l.LOOKUP_CODE
                , l.MEANING
        INTO
                  lc_fob_point
                , lc_fob_point_name
        FROM      AR_LOOKUPS L
                , hz_cust_accounts cust_acct
        WHERE cust_acct.cust_account_id = pn_SHIP_TO_CUSTOMER_ID
        AND L.LOOKUP_TYPE = 'FOB'
        AND L.LOOKUP_CODE = cust_acct.FOB_POINT
        AND L.ENABLED_FLAG = 'Y'
        AND TRUNC(SYSDATE) BETWEEN L.START_DATE_ACTIVE
                          AND NVL(L.END_DATE_ACTIVE, TRUNC(SYSDATE));
    exception
      when no_data_found then
        null;
      when others then
        raise;
    end;

    -- Return immediately if FOB point was found
    IF (lc_fob_point IS NOT NULL)
    THEN
      pc_fob_point        := lc_fob_point;
      pc_fob_point_name   := lc_fob_point_name;
      RETURN;
    END IF;

  end if;

  IF (pn_BILL_TO_CUSTOMER_ID IS NOT NULL)
  THEN
    begin
        SELECT    l.LOOKUP_CODE
                , l.MEANING
        INTO
                  lc_fob_point
                , lc_fob_point_name
        FROM      AR_LOOKUPS L
                , hz_cust_accounts cust_acct
        WHERE cust_acct.cust_account_id= pn_BILL_TO_CUSTOMER_ID
        AND L.LOOKUP_TYPE = 'FOB'
        AND L.LOOKUP_CODE = cust_acct.FOB_POINT
        AND L.ENABLED_FLAG = 'Y'
        AND TRUNC(SYSDATE) BETWEEN L.START_DATE_ACTIVE
                          AND NVL(L.END_DATE_ACTIVE, TRUNC(SYSDATE));
    exception
      when no_data_found then
        null;
      when others then
        raise;
    end;

    -- Return immediately if FOB point was found
    IF (lc_fob_point IS NOT NULL)
    THEN
      pc_fob_point        := lc_fob_point;
      pc_fob_point_name   := lc_fob_point_name;
      RETURN;
    END IF;

  end if;

  -- We return empty handed ...
  pc_fob_point        := '';
  pc_fob_point_name   := '';

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : arp_process_freight_util.get_default_fob');
       arp_util.debug('get_default_fob: ' || 'pn_SHIP_TO_SITE_USE_ID :'||to_char(pn_SHIP_TO_SITE_USE_ID));
       arp_util.debug('get_default_fob: ' || 'pn_BILL_TO_SITE_USE_ID :'||to_char(pn_BILL_TO_SITE_USE_ID));
       arp_util.debug('get_default_fob: ' || 'pn_SHIP_TO_CUSTOMER_ID :'||to_char(pn_SHIP_TO_CUSTOMER_ID));
       arp_util.debug('get_default_fob: ' || 'pn_BILL_TO_CUSTOMER_ID :'||to_char(pn_BILL_TO_CUSTOMER_ID));
    END IF;

    RAISE;

end get_default_fob;

END ARP_PROCESS_FREIGHT_UTIL;

/
