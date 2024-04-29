--------------------------------------------------------
--  DDL for Package Body ARP_CTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CTL_PKG" AS
/* $Header: ARTICTLB.pls 120.31.12010000.9 2009/11/24 07:11:15 rvelidi ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_TEXT3_DUMMY  CONSTANT VARCHAR2(10) := '~!@';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

  /*---------------------------------------------------------------+
   |  Package global variables to hold the parsed update cursors.  |
   |  This allows the cursors to be reused without being reparsed. |
   +---------------------------------------------------------------*/

  pg_cursor1  integer := '';
  pg_cursor2  integer := '';

  /*-------------------------------------+
   |  WHO column values from FND_GLOBAL  |
   +-------------------------------------*/

  pg_user_id          number;
  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;

--{BUG#3339072
  TYPE ctlrec IS RECORD (
          customer_trx_line_id   DBMS_SQL.NUMBER_TABLE,
          customer_trx_id        DBMS_SQL.NUMBER_TABLE,
          created_by             DBMS_SQL.VARCHAR2_TABLE,
          creation_date          DBMS_SQL.DATE_TABLE,
          last_updated_by        DBMS_SQL.VARCHAR2_TABLE,
          last_update_date       DBMS_SQL.DATE_TABLE,
          last_update_login      DBMS_SQL.VARCHAR2_TABLE,
          line_number            DBMS_SQL.NUMBER_TABLE,
          line_type              DBMS_SQL.VARCHAR2_TABLE,
          set_of_books_id        DBMS_SQL.NUMBER_TABLE,
          accounting_rule_id     DBMS_SQL.NUMBER_TABLE,
          autorule_complete_flag DBMS_SQL.VARCHAR2_TABLE,
          last_period_to_credit  DBMS_SQL.NUMBER_TABLE,
          description            DBMS_SQL.VARCHAR2_TABLE,
          initial_customer_trx_line_id  DBMS_SQL.NUMBER_TABLE,
          inventory_item_id      DBMS_SQL.NUMBER_TABLE,
          item_exception_rate_id DBMS_SQL.NUMBER_TABLE,
          memo_line_id           DBMS_SQL.NUMBER_TABLE,
          reason_code            DBMS_SQL.VARCHAR2_TABLE,
          previous_customer_trx_id DBMS_SQL.NUMBER_TABLE,
          previous_customer_trx_line_id DBMS_SQL.NUMBER_TABLE,
          link_to_cust_trx_line_id  DBMS_SQL.NUMBER_TABLE,
          unit_standard_price     DBMS_SQL.NUMBER_TABLE,
          unit_selling_price      DBMS_SQL.NUMBER_TABLE,
          gross_unit_selling_price DBMS_SQL.NUMBER_TABLE,-- Bug 7389126 KALYAN
          gross_extended_amount   DBMS_SQL.NUMBER_TABLE, -- 6882394
          original_extended_amount DBMS_SQL.NUMBER_TABLE,-- 6882394
          original_revenue_amount  DBMS_SQL.NUMBER_TABLE,-- 6882394
          quantity_credited       DBMS_SQL.NUMBER_TABLE,
          quantity_invoiced       DBMS_SQL.NUMBER_TABLE,      -- Bug 6990227
          extended_amount         DBMS_SQL.NUMBER_TABLE,
          revenue_amount          DBMS_SQL.NUMBER_TABLE,
          sales_order             DBMS_SQL.VARCHAR2_TABLE,
          sales_order_date        DBMS_SQL.DATE_TABLE,
          sales_order_line        DBMS_SQL.VARCHAR2_TABLE,
          sales_order_revision    DBMS_SQL.NUMBER_TABLE,
          sales_order_source      DBMS_SQL.VARCHAR2_TABLE,
          tax_exemption_id        DBMS_SQL.NUMBER_TABLE,
          tax_precedence          DBMS_SQL.NUMBER_TABLE,
          tax_rate                DBMS_SQL.NUMBER_TABLE,
          uom_code                DBMS_SQL.VARCHAR2_TABLE,
          default_ussgl_transaction_code DBMS_SQL.VARCHAR2_TABLE,
          default_ussgl_trx_code_context DBMS_SQL.VARCHAR2_TABLE,
          sales_tax_id            DBMS_SQL.NUMBER_TABLE,
          location_segment_id     DBMS_SQL.NUMBER_TABLE,
          vat_tax_id              DBMS_SQL.NUMBER_TABLE,
          amount_includes_tax_flag    DBMS_SQL.VARCHAR2_TABLE,
          warehouse_id            DBMS_SQL.NUMBER_TABLE,
          taxable_amount          DBMS_SQL.NUMBER_TABLE,
          translated_description  DBMS_SQL.VARCHAR2_TABLE,
          org_id                  DBMS_SQL.NUMBER_TABLE,
          ship_to_customer_id     DBMS_SQL.NUMBER_TABLE,
          ship_to_address_id      DBMS_SQL.NUMBER_TABLE,
          ship_to_site_use_id     DBMS_SQL.NUMBER_TABLE,
          ship_to_contact_id      DBMS_SQL.NUMBER_TABLE,
	  tax_classification_code DBMS_SQL.VARCHAR2_TABLE,
          historical_flag         DBMS_SQL.VARCHAR2_TABLE,
          memo_line_type          DBMS_SQL.VARCHAR2_TABLE);
  --}
/*===========================================================================+
 | FUNCTION                                                                  |
 |    calculate_prorated_tax_amount                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function will prorate the tax across lines when the               |
 |    credit transaction is of type TAX ONLY			             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_mode                                                 |
 |                    p_tax_amount                                           |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 | RETURNS    : Number                                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-FEB-2008  Manohar Kolla V K  Created                               |
 |                                                                           |
 +===========================================================================*/

FUNCTION calculate_prorated_tax_amount (p_mode			IN varchar2,
                                        p_tax_amount		IN ra_customer_trx_lines.extended_amount%type,
					p_customer_trx_id	IN ra_customer_trx.customer_trx_id%type,
					p_customer_trx_line_id	IN ra_customer_trx_lines.customer_trx_line_id%type)
RETURN NUMBER
IS
l_tax_recoverable	ra_customer_trx_lines.tax_recoverable%type;
l_total_tax_recoverable ra_customer_trx_lines.tax_recoverable%type;
l_precision		FND_CURRENCIES.precision%type;
l_mau			FND_CURRENCIES.minimum_accountable_unit%type;
l_tax_amount		ra_customer_trx_lines.extended_amount%type;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.calculate_prorated_tax_amount()+');
    END IF;

   IF p_mode = 'INSERT_NO_LINE' then

	select sum(decode(ct.complete_flag , 'N', 0,
			  nvl(ctl.tax_recoverable,
        (select sum(ctl_tax.extended_amount) from ra_customer_trx_lines_all ctl_tax
        where ctl_tax.customer_trx_id = ctl.customer_trx_id
        and ctl_tax.link_to_cust_trx_line_id = ctl.customer_trx_line_id
        and ctl_tax.line_type = 'TAX')))) tax_recoverable
	INTO l_tax_recoverable
	from ra_customer_trx_lines_all orig_ctl,
	ra_customer_trx_lines_all ctl,
	ra_customer_trx_lines_all cm_ctl,
	ra_customer_trx_all ct
	where (ctl.customer_trx_line_id = orig_ctl.customer_trx_line_id
		   OR ( ctl.previous_customer_trx_line_id IS NOT NULL
		       AND ctl.previous_customer_trx_line_id = orig_ctl.customer_trx_line_id)
	      )
	and orig_ctl.customer_trx_id = cm_ctl.previous_customer_trx_id
	and orig_ctl.customer_trx_line_id = cm_ctl.previous_customer_trx_line_id
	and cm_ctl.customer_trx_id = p_customer_trx_id
	and cm_ctl.customer_trx_line_id = p_customer_trx_line_id
	and ctl.line_type = 'LINE'
	and ct.customer_trx_id = ctl.customer_trx_id
	group by orig_ctl.customer_trx_line_id, ctl.line_type;

	select sum(decode(ct.complete_flag , 'N', 0,
			  nvl(ctl.tax_recoverable, (select sum(ctl_tax.extended_amount) from ra_customer_trx_lines_all ctl_tax
        where ctl_tax.customer_trx_id = ctl.customer_trx_id
        and ctl_tax.link_to_cust_trx_line_id = ctl.customer_trx_line_id
        and ctl_tax.line_type = 'TAX')))) total_tax_recoverable
	INTO l_total_tax_recoverable
	from ra_customer_trx_lines_all orig_ctl,
	ra_customer_trx_lines_all ctl,
	ra_customer_trx_lines_all cm_ctl,
	ra_customer_trx_all ct
	where (ctl.customer_trx_line_id = orig_ctl.customer_trx_line_id
		   OR ( ctl.previous_customer_trx_line_id IS NOT NULL
		       AND ctl.previous_customer_trx_line_id = orig_ctl.customer_trx_line_id)
	      )
	and orig_ctl.customer_trx_id = cm_ctl.previous_customer_trx_id
	and orig_ctl.customer_trx_line_id = cm_ctl.previous_customer_trx_line_id
	and cm_ctl.customer_trx_id = p_customer_trx_id
	and ctl.line_type = 'LINE'
	and ct.customer_trx_id = ctl.customer_trx_id;

        if l_total_tax_recoverable = 0 then
		l_total_tax_recoverable := 1;
	end if;

	select
	      CUR.precision,
	      CUR.minimum_accountable_unit
	into  l_precision,
	      l_mau
	from RA_CUSTOMER_TRX          TRX,
	     FND_CURRENCIES           CUR
	where TRX.customer_trx_id = p_customer_trx_id
	and   TRX.invoice_currency_code = CUR.currency_code;

	l_tax_amount := p_tax_amount * (l_tax_recoverable / l_total_tax_recoverable);

		IF l_precision is not null
		THEN
		    l_tax_amount := round(l_tax_amount, l_precision);
		ELSE
		    l_tax_amount := (round(l_tax_amount / l_mau)
					    * l_mau);
		END IF;
   ELSE
	l_tax_amount := p_tax_amount;
   END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'l_tax_recoverable = ' || l_tax_recoverable);
       arp_util.debug(  'l_total_tax_recoverable = ' || l_total_tax_recoverable);
       arp_util.debug(  'l_tax_amount = ' || l_tax_amount);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.calculate_prorated_tax_amount()-');
    END IF;

RETURN l_tax_amount;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'EXCEPTION: arp_ctl_pkg.calculate_prorated_tax_amount');
       arp_util.debug(  '');
       arp_util.debug(  'p_customer_trx_id         = '||p_customer_trx_id);
       arp_util.debug(  'p_customer_trx_line_id    = '||p_customer_trx_line_id);
       arp_util.debug(  'p_tax_amount              = '||p_tax_amount);
       arp_util.debug(  'p_mode			   = '||p_mode);
    END IF;
    RAISE;

END calculate_prorated_tax_amount;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    bind_line_variables                                                    |
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
 |                    p_line_rec       - ra_customer_trx_lines record        |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |     Rel. 11 Changes:							     |
 |     ----------------							     |
 |     07-22-97   OSTEINME		added code to bind variables for     |
 |					three new database columns:          |
 |					  - gross_unit_selling_price         |
 |					  - gross_extended_amount            |
 |					  - amount_includes_tax_flag         |
 |                                                                           |
 |     08-20-97   KTANG                 bind variables for                   |
 |                                      global_attribute_category and        |
 |                                      global_attribute[1-20] for global    |
 |                                      descriptive flexfield                |
 |                                                                           |
 |     10-JAN-99  Saloni Shah           added warehouse_id for global tax    |
 |                                      engine changes                       |
 |     22-MAR-99  Debbie Jancis         added translated_description for     |
 |                                      MLS project.                         |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns                |
 |                              EXTENDED_ACCTD_AMOUNT, BR_REF_CUSTOMER_TRX_ID,  |
 |                              BR_REF_PAYMENT_SCHEDULE_ID and BR_ADJUSTMENT_ID |
 |                              into table handlers                             |
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added column wh_update_date    |
 | 					      into the table handlers. 	     |
 | 04-NOV-2005 MRAYMOND         4713671 - added ship_to and tax columns
 +===========================================================================*/


PROCEDURE bind_line_variables(p_update_cursor  IN integer,
                              p_line_rec   IN ra_customer_trx_lines%rowtype) IS

BEGIN

   arp_util.debug('arp_ctl_pkg.bind_line_variables()+');


  /*------------------+
   |  Dummy constants |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_text3_dummy',
                          AR_TEXT3_DUMMY);

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


  /*----------------------------------------------+
   |  Bind variables for all columns in the table |
   +----------------------------------------------*/


   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_line_id',
                          p_line_rec.customer_trx_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_id',
                          p_line_rec.customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':line_number',
                          p_line_rec.line_number);

   dbms_sql.bind_variable(p_update_cursor, ':line_type',
                          p_line_rec.line_type);

   dbms_sql.bind_variable(p_update_cursor, ':quantity_credited',
                          p_line_rec.quantity_credited);

   dbms_sql.bind_variable(p_update_cursor, ':quantity_invoiced',
                          p_line_rec.quantity_invoiced);

   dbms_sql.bind_variable(p_update_cursor, ':quantity_ordered',
                          p_line_rec.quantity_ordered);

   dbms_sql.bind_variable(p_update_cursor, ':unit_selling_price',
                          p_line_rec.unit_selling_price);

   dbms_sql.bind_variable(p_update_cursor, ':unit_standard_price',
                          p_line_rec.unit_standard_price);

   dbms_sql.bind_variable(p_update_cursor, ':revenue_amount',
                          p_line_rec.revenue_amount);

   dbms_sql.bind_variable(p_update_cursor, ':extended_amount',
                          p_line_rec.extended_amount);

   dbms_sql.bind_variable(p_update_cursor, ':memo_line_id',
                          p_line_rec.memo_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':inventory_item_id',
                          p_line_rec.inventory_item_id);

   dbms_sql.bind_variable(p_update_cursor, ':item_exception_rate_id',
                          p_line_rec.item_exception_rate_id);

   dbms_sql.bind_variable(p_update_cursor, ':description',
                          p_line_rec.description);

   dbms_sql.bind_variable(p_update_cursor, ':item_context',
                          p_line_rec.item_context);

   dbms_sql.bind_variable(p_update_cursor, ':initial_customer_trx_line_id',
                          p_line_rec.initial_customer_trx_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':link_to_cust_trx_line_id',
                          p_line_rec.link_to_cust_trx_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':previous_customer_trx_id',
                          p_line_rec.previous_customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':previous_customer_trx_line_id',
                          p_line_rec.previous_customer_trx_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':accounting_rule_duration',
                          p_line_rec.accounting_rule_duration);

   dbms_sql.bind_variable(p_update_cursor, ':accounting_rule_id',
                          p_line_rec.accounting_rule_id);

   dbms_sql.bind_variable(p_update_cursor, ':rule_start_date',
                          p_line_rec.rule_start_date);

   dbms_sql.bind_variable(p_update_cursor, ':autorule_complete_flag',
                          p_line_rec.autorule_complete_flag);

   dbms_sql.bind_variable(p_update_cursor, ':autorule_duration_processed',
                          p_line_rec.autorule_duration_processed);

   dbms_sql.bind_variable(p_update_cursor, ':reason_code',
                          p_line_rec.reason_code);

   dbms_sql.bind_variable(p_update_cursor, ':last_period_to_credit',
                          p_line_rec.last_period_to_credit);

   dbms_sql.bind_variable(p_update_cursor, ':sales_order',
                          p_line_rec.sales_order);

   dbms_sql.bind_variable(p_update_cursor, ':sales_order_date',
                          p_line_rec.sales_order_date);

   dbms_sql.bind_variable(p_update_cursor, ':sales_order_line',
                          p_line_rec.sales_order_line);

   dbms_sql.bind_variable(p_update_cursor, ':sales_order_revision',
                          p_line_rec.sales_order_revision);

   dbms_sql.bind_variable(p_update_cursor, ':sales_order_source',
                          p_line_rec.sales_order_source);

   dbms_sql.bind_variable(p_update_cursor, ':vat_tax_id',
                          p_line_rec.vat_tax_id);

   dbms_sql.bind_variable(p_update_cursor, ':tax_exempt_flag',
                          p_line_rec.tax_exempt_flag);

   dbms_sql.bind_variable(p_update_cursor, ':sales_tax_id',
                          p_line_rec.sales_tax_id);

   dbms_sql.bind_variable(p_update_cursor, ':location_segment_id',
                          p_line_rec.location_segment_id);

   dbms_sql.bind_variable(p_update_cursor, ':tax_exempt_number',
                          p_line_rec.tax_exempt_number);

   dbms_sql.bind_variable(p_update_cursor, ':tax_exempt_reason_code',
                          p_line_rec.tax_exempt_reason_code);

   dbms_sql.bind_variable(p_update_cursor, ':tax_vendor_return_code',
                          p_line_rec.tax_vendor_return_code);

   dbms_sql.bind_variable(p_update_cursor, ':taxable_flag',
                          p_line_rec.taxable_flag);

   dbms_sql.bind_variable(p_update_cursor, ':tax_exemption_id',
                          p_line_rec.tax_exemption_id);

   dbms_sql.bind_variable(p_update_cursor, ':tax_precedence',
                          p_line_rec.tax_precedence);

   dbms_sql.bind_variable(p_update_cursor, ':tax_rate',
                          p_line_rec.tax_rate);

   dbms_sql.bind_variable(p_update_cursor, ':uom_code',
                          p_line_rec.uom_code);

   dbms_sql.bind_variable(p_update_cursor, ':autotax',
                          p_line_rec.autotax);

   dbms_sql.bind_variable(p_update_cursor, ':movement_id',
                          p_line_rec.movement_id);

   dbms_sql.bind_variable(p_update_cursor, ':default_ussgl_transaction_code',
                          p_line_rec.default_ussgl_transaction_code);

   dbms_sql.bind_variable(p_update_cursor, ':default_ussgl_trx_code_context',
                          p_line_rec.default_ussgl_trx_code_context);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_context',
                          p_line_rec.interface_line_context);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute1',
                          p_line_rec.interface_line_attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute2',
                          p_line_rec.interface_line_attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute3',
                          p_line_rec.interface_line_attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute4',
                          p_line_rec.interface_line_attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute5',
                          p_line_rec.interface_line_attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute6',
                          p_line_rec.interface_line_attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute7',
                          p_line_rec.interface_line_attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute8',
                          p_line_rec.interface_line_attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute9',
                          p_line_rec.interface_line_attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute10',
                          p_line_rec.interface_line_attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute11',
                          p_line_rec.interface_line_attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute12',
                          p_line_rec.interface_line_attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute13',
                          p_line_rec.interface_line_attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute14',
                          p_line_rec.interface_line_attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':interface_line_attribute15',
                          p_line_rec.interface_line_attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_line_rec.attribute_category);

   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_line_rec.attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_line_rec.attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_line_rec.attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_line_rec.attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_line_rec.attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_line_rec.attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_line_rec.attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_line_rec.attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_line_rec.attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_line_rec.attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_line_rec.attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_line_rec.attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_line_rec.attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_line_rec.attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_line_rec.attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':created_by',
                          p_line_rec.created_by);

   dbms_sql.bind_variable(p_update_cursor, ':creation_date',
                          p_line_rec.creation_date);

   dbms_sql.bind_variable(p_update_cursor, ':last_updated_by',
                          p_line_rec.last_updated_by);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_date',
                          p_line_rec.last_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':program_application_id',
                          p_line_rec.program_application_id);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_login',
                          p_line_rec.last_update_login);

   dbms_sql.bind_variable(p_update_cursor, ':program_id',
                          p_line_rec.program_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_update_date',
                          p_line_rec.program_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':set_of_books_id',
                          p_line_rec.set_of_books_id);

   -- Rel. 11 Changes:

   dbms_sql.bind_variable(p_update_cursor, ':gross_unit_selling_price',
                          p_line_rec.gross_unit_selling_price);

   dbms_sql.bind_variable(p_update_cursor, ':gross_extended_amount',
                          p_line_rec.gross_extended_amount);

   dbms_sql.bind_variable(p_update_cursor, ':amount_includes_tax_flag',
                          p_line_rec.amount_includes_tax_flag);

   -- For global descriptive flexfield

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute_category',
                          p_line_rec.global_attribute_category);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute1',
                          p_line_rec.global_attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute2',
                          p_line_rec.global_attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute3',
                          p_line_rec.global_attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute4',
                          p_line_rec.global_attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute5',
                          p_line_rec.global_attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute6',
                          p_line_rec.global_attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute7',
                          p_line_rec.global_attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute8',
                          p_line_rec.global_attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute9',
                          p_line_rec.global_attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute10',
                          p_line_rec.global_attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute11',
                          p_line_rec.global_attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute12',
                          p_line_rec.global_attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute13',
                          p_line_rec.global_attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute14',
                          p_line_rec.global_attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute15',
                          p_line_rec.global_attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute16',
                          p_line_rec.global_attribute16);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute17',
                          p_line_rec.global_attribute17);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute18',
                          p_line_rec.global_attribute18);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute19',
                          p_line_rec.global_attribute19);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute20',
                          p_line_rec.global_attribute20);

/* added for global tax engine */
   dbms_sql.bind_variable(p_update_cursor, ':warehouse_id',
                          p_line_rec.warehouse_id);
   dbms_sql.bind_variable(p_update_cursor, ':translated_description',
                          p_line_rec.translated_description);

   /* Bug 853757 */
   dbms_sql.bind_variable(p_update_cursor, ':taxable_amount',
			  p_line_rec.taxable_amount);

   dbms_sql.bind_variable(p_update_cursor, ':extended_acctd_amount',
			  p_line_rec.extended_acctd_amount);

   dbms_sql.bind_variable(p_update_cursor, ':br_ref_customer_trx_id',
			  p_line_rec.br_ref_customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':br_ref_payment_schedule_id',
			  p_line_rec.br_ref_payment_schedule_id);

   dbms_sql.bind_variable(p_update_cursor, ':br_adjustment_id',
			  p_line_rec.br_adjustment_id);

   dbms_sql.bind_variable(p_update_cursor, ':wh_update_date',
			  p_line_rec.wh_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':payment_set_id',
			  p_line_rec.payment_set_id);
/* 4713671 */
   dbms_sql.bind_variable(p_update_cursor, ':ship_to_customer_id',
			  p_line_rec.ship_to_customer_id);

   dbms_sql.bind_variable(p_update_cursor, ':ship_to_site_use_id',
			  p_line_rec.ship_to_site_use_id);

   dbms_sql.bind_variable(p_update_cursor, ':ship_to_contact_id',
			  p_line_rec.ship_to_contact_id);

   dbms_sql.bind_variable(p_update_cursor, ':tax_classification_code',
			  p_line_rec.tax_classification_code);
/* 4713671 end */
  dbms_sql.bind_variable(p_update_cursor, ':rule_end_date',
                          p_line_rec.rule_end_date);

   arp_util.debug('arp_ctl_pkg.bind_line_variables()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctl_pkg.bind_line_variables()');

        arp_util.debug('');
        arp_util.debug('-------- parameters for bind_line_variables() ------');

        arp_util.debug('p_update_cursor    = ' || p_update_cursor);
        arp_util.debug('');
        display_line_rec(p_line_rec);

        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_line_update_stmt 					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Copies the text of the dynamic SQL update statement into the           |
 |    out paramater. The update statement does not contain a where clause    |
 |    since this is the dynamic part that is added later.                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
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
 |    This statement only updates columns in the line record that do not     |
 |    contain the dummy values that indicate that they should not be changed.|
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |     Rel. 11 Changes:							     |
 |     ----------------							     |
 |     07-22-97   OSTEINME		added code to update three new       |
 |					database columns:                    |
 |					  - gross_unit_selling_price         |
 |					  - gross_extended_amount            |
 |					  - amount_includes_tax_flag         |
 |									     |
 |     08-20-97   KTANG                 update global_attribute_category and |
 |                                      global_attribute[1-20] for global    |
 |                                      descriptive flexfield                |
 |									     |
 |     10-JAN-99  Saloni Shah           added warehouse_id for global tax    |
 |				        engine changes                       |
 |     22-MAR-99  Debbie Jancis         added translated_description for MLS |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns                |
 |                              EXTENDED_ACCTD_AMOUNT, BR_REF_CUSTOMER_TRX_ID,  |
 |                              BR_REF_PAYMENT_SCHEDULE_ID and BR_ADJUSTMENT_ID |
 |                              into table handlers                             |
 |									     |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added column wh_update_date    |
 | 					      into the table handlers. 	     |
 | 04-NOV-2005 MRAYMOND         4713671 - coded ship to and classifctn fields
 +===========================================================================*/

PROCEDURE construct_line_update_stmt( update_text OUT NOCOPY varchar2) IS

BEGIN
   arp_util.debug('arp_ctl_pkg.construct_line_update_stmt()+');

   update_text :=
 'UPDATE ra_customer_trx_lines
   SET    customer_trx_line_id =
               DECODE(:customer_trx_line_id,
                      :ar_number_dummy, customer_trx_line_id,
                                        :customer_trx_line_id),
          customer_trx_id =
               DECODE(:customer_trx_id,
                      :ar_number_dummy, customer_trx_id,
                                        :customer_trx_id),
          line_number =
               DECODE(:line_number,
                      :ar_number_dummy, line_number,
                                        :line_number),
          line_type =
               DECODE(:line_type,
                      :ar_text_dummy,   line_type,
                                        :line_type),
          quantity_credited =
               DECODE(:quantity_credited,
                      :ar_number_dummy, quantity_credited,
                                        :quantity_credited),
          quantity_invoiced =
               DECODE(:quantity_invoiced,
                      :ar_number_dummy, quantity_invoiced,
                                        :quantity_invoiced),
          quantity_ordered =
               DECODE(:quantity_ordered,
                      :ar_number_dummy, quantity_ordered,
                                        :quantity_ordered),
          unit_selling_price =
               DECODE(:unit_selling_price,
                      :ar_number_dummy, unit_selling_price,
                                        :unit_selling_price),
          unit_standard_price =
               DECODE(:unit_standard_price,
                      :ar_number_dummy, unit_standard_price,
                                        :unit_standard_price),
          revenue_amount =
               DECODE(:revenue_amount,
                      :ar_number_dummy,
                         /* IF   the line type is LINE
                            AND  the extended_amount has changed
                            THEN compute the revenue_amount based on the
                                 percent of the old line amount was revenue:
                                 new_revenue_amount = new_extended_amount *
                                                      (old_revenue_amount /
                                                       old_extended_amount)
                            ELSE use the old revenue_amount */
                         DECODE(
                                 DECODE(
                                         :line_type,
                                         :ar_text_dummy, line_type,
                                                         :line_type
                                       ) ||
                                 DECODE(
                                        :extended_amount,
                                        :ar_number_dummy, ''Amount unchanged'',
                                                          null
                                       ),
                                ''LINE'',  arpcurr.CurrRound(
                                                   DECODE(extended_amount,
                                                          0, :extended_amount,
                                                             :extended_amount *
                                                             (
                                                               revenue_amount /
                                                               extended_amount
                                                             )
                                                         ),
                                                   :invoice_currency_code
                                                ),
                                          revenue_amount
                               ),
                         :revenue_amount),
          extended_amount =
               DECODE(:extended_amount,
                      :ar_number_dummy, extended_amount,
                                        :extended_amount),
          memo_line_id =
               DECODE(:memo_line_id,
                      :ar_number_dummy, memo_line_id,
                                        :memo_line_id),
          inventory_item_id =
               DECODE(:inventory_item_id,
                      :ar_number_dummy, inventory_item_id,
                                        :inventory_item_id),
          item_exception_rate_id =
               DECODE(:item_exception_rate_id,
                      :ar_number_dummy, item_exception_rate_id,
                                        :item_exception_rate_id),
          description =
               DECODE(:description,
                      :ar_text_dummy,   description,
                                        :description),
          item_context =
               DECODE(:item_context,
                      :ar_text_dummy,   item_context,
                                        :item_context),
          initial_customer_trx_line_id =
               DECODE(:initial_customer_trx_line_id,
                      :ar_number_dummy, initial_customer_trx_line_id,
                                        :initial_customer_trx_line_id),
          link_to_cust_trx_line_id =
               DECODE(:link_to_cust_trx_line_id,
                      :ar_number_dummy, link_to_cust_trx_line_id,
                                        :link_to_cust_trx_line_id),
          previous_customer_trx_id =
               DECODE(:previous_customer_trx_id,
                      :ar_number_dummy, previous_customer_trx_id,
                                        :previous_customer_trx_id),
          previous_customer_trx_line_id =
               DECODE(:previous_customer_trx_line_id,
                      :ar_number_dummy, previous_customer_trx_line_id,
                                        :previous_customer_trx_line_id),
          accounting_rule_duration =
               DECODE(:accounting_rule_duration,
                      :ar_number_dummy, accounting_rule_duration,
                                        :accounting_rule_duration),
          accounting_rule_id =
               DECODE(:accounting_rule_id,
                      :ar_number_dummy, accounting_rule_id,
                                        :accounting_rule_id),
          rule_start_date =
               DECODE(:rule_start_date,
                      :ar_date_dummy,   rule_start_date,
                                        :rule_start_date),
          autorule_complete_flag =
               DECODE(:autorule_complete_flag,
                      :ar_flag_dummy,   autorule_complete_flag,
                                        :autorule_complete_flag),
          autorule_duration_processed =
               DECODE(:autorule_duration_processed,
                      :ar_number_dummy, autorule_duration_processed,
                                        :autorule_duration_processed),
          reason_code =
               DECODE(:reason_code,
                      :ar_text_dummy,   reason_code,
                                        :reason_code),
          last_period_to_credit =
               DECODE(:last_period_to_credit,
                      :ar_number_dummy, last_period_to_credit,
                                        :last_period_to_credit),
          sales_order =
               DECODE(:sales_order,
                      :ar_text_dummy,   sales_order,
                                        :sales_order),
          sales_order_date =
               DECODE(:sales_order_date,
                      :ar_date_dummy,   sales_order_date,
                                        :sales_order_date),
          sales_order_line =
               DECODE(:sales_order_line,
                      :ar_text_dummy,   sales_order_line,
                                        :sales_order_line),
          sales_order_revision =
               DECODE(:sales_order_revision,
                      :ar_number_dummy, sales_order_revision,
                                        :sales_order_revision),
          sales_order_source =
               DECODE(:sales_order_source,
                      :ar_text_dummy,   sales_order_source,
                                        :sales_order_source),
          vat_tax_id =
               DECODE(:vat_tax_id,
                      :ar_number_dummy, vat_tax_id,
                                        :vat_tax_id),
          tax_exempt_flag =
               DECODE(:tax_exempt_flag,
                      :ar_flag_dummy,   tax_exempt_flag,
                                        :tax_exempt_flag),
          sales_tax_id =
               DECODE(:sales_tax_id,
                      :ar_number_dummy, sales_tax_id,
                                        :sales_tax_id),
          location_segment_id =
               DECODE(:location_segment_id,
                      :ar_number_dummy, location_segment_id,
                                        :location_segment_id),
          tax_exempt_number =
               DECODE(:tax_exempt_number,
                      :ar_text_dummy,   tax_exempt_number,
                                        :tax_exempt_number),
          tax_exempt_reason_code =
               DECODE(:tax_exempt_reason_code,
                      :ar_text_dummy,   tax_exempt_reason_code,
                                        :tax_exempt_reason_code),
          tax_vendor_return_code =
               DECODE(:tax_vendor_return_code,
                      :ar_text_dummy,   tax_vendor_return_code,
                                        :tax_vendor_return_code),
          taxable_flag =
               DECODE(:taxable_flag,
                      :ar_flag_dummy,   taxable_flag,
                                        :taxable_flag),
          tax_exemption_id =
               DECODE(:tax_exemption_id,
                      :ar_number_dummy, tax_exemption_id,
                                        :tax_exemption_id),
          tax_precedence =
               DECODE(:tax_precedence,
                      :ar_number_dummy, tax_precedence,
                                        :tax_precedence),
          tax_rate =
               DECODE(:tax_rate,
                      :ar_number_dummy, tax_rate,
                                        :tax_rate),
          uom_code =
               DECODE(:uom_code,
                      :ar_text3_dummy,   uom_code,
                                        :uom_code),
          autotax =
               DECODE(:autotax,
                      :ar_flag_dummy,   autotax,
                                        :autotax),
          movement_id =
               DECODE(:movement_id,
                      :ar_number_dummy, movement_id,
                                        :movement_id),
          default_ussgl_transaction_code =
               DECODE(:default_ussgl_transaction_code,
                      :ar_text_dummy,   default_ussgl_transaction_code,
                                        :default_ussgl_transaction_code),
          default_ussgl_trx_code_context =
               DECODE(:default_ussgl_trx_code_context,
                      :ar_text_dummy,   default_ussgl_trx_code_context,
                                        :default_ussgl_trx_code_context),
          interface_line_context =
               DECODE(:interface_line_context,
                      :ar_text_dummy,   interface_line_context,
                                        :interface_line_context),
          interface_line_attribute1 =
               DECODE(:interface_line_attribute1,
                      :ar_text_dummy,   interface_line_attribute1,
                                        :interface_line_attribute1),
          interface_line_attribute2 =
               DECODE(:interface_line_attribute2,
                      :ar_text_dummy,   interface_line_attribute2,
                                        :interface_line_attribute2),
          interface_line_attribute3 =
               DECODE(:interface_line_attribute3,
                      :ar_text_dummy,   interface_line_attribute3,
                                        :interface_line_attribute3),
          interface_line_attribute4 =
               DECODE(:interface_line_attribute4,
                      :ar_text_dummy,   interface_line_attribute4,
                                        :interface_line_attribute4),
          interface_line_attribute5 =
               DECODE(:interface_line_attribute5,
                      :ar_text_dummy,   interface_line_attribute5,
                                        :interface_line_attribute5),
          interface_line_attribute6 =
               DECODE(:interface_line_attribute6,
                      :ar_text_dummy,   interface_line_attribute6,
                                        :interface_line_attribute6),
          interface_line_attribute7 =
               DECODE(:interface_line_attribute7,
                      :ar_text_dummy,   interface_line_attribute7,
                                        :interface_line_attribute7),
          interface_line_attribute8 =
               DECODE(:interface_line_attribute8,
                      :ar_text_dummy,   interface_line_attribute8,
                                        :interface_line_attribute8),
          interface_line_attribute9 =
               DECODE(:interface_line_attribute9,
                      :ar_text_dummy,   interface_line_attribute9,
                                        :interface_line_attribute9),
          interface_line_attribute10 =
               DECODE(:interface_line_attribute10,
                      :ar_text_dummy,   interface_line_attribute10,
                                        :interface_line_attribute10),
          interface_line_attribute11 =
               DECODE(:interface_line_attribute11,
                      :ar_text_dummy,   interface_line_attribute11,
                                        :interface_line_attribute11),
          interface_line_attribute12 =
               DECODE(:interface_line_attribute12,
                      :ar_text_dummy,   interface_line_attribute12,
                                        :interface_line_attribute12),
          interface_line_attribute13 =
               DECODE(:interface_line_attribute13,
                      :ar_text_dummy,   interface_line_attribute13,
                                        :interface_line_attribute13),
          interface_line_attribute14 =
               DECODE(:interface_line_attribute14,
                      :ar_text_dummy,   interface_line_attribute14,
                                        :interface_line_attribute14),
          interface_line_attribute15 =
               DECODE(:interface_line_attribute15,
                      :ar_text_dummy,   interface_line_attribute15,
                                        :interface_line_attribute15),
          attribute_category =
               DECODE(:attribute_category,
                      :ar_text_dummy,   attribute_category,
                                        :attribute_category),
          attribute1 =
               DECODE(:attribute1,
                      :ar_text_dummy,   attribute1,
                                        :attribute1),
          attribute2 =
               DECODE(:attribute2,
                      :ar_text_dummy,   attribute2,
                                        :attribute2),
          attribute3 =
               DECODE(:attribute3,
                      :ar_text_dummy,   attribute3,
                                        :attribute3),
          attribute4 =
               DECODE(:attribute4,
                      :ar_text_dummy,   attribute4,
                                        :attribute4),
          attribute5 =
               DECODE(:attribute5,
                      :ar_text_dummy,   attribute5,
                                        :attribute5),
          attribute6 =
               DECODE(:attribute6,
                      :ar_text_dummy,   attribute6,
                                        :attribute6),
          attribute7 =
               DECODE(:attribute7,
                      :ar_text_dummy,   attribute7,
                                        :attribute7),
          attribute8 =
               DECODE(:attribute8,
                      :ar_text_dummy,   attribute8,
                                        :attribute8),
          attribute9 =
               DECODE(:attribute9,
                      :ar_text_dummy,   attribute9,
                                        :attribute9),
          attribute10 =
               DECODE(:attribute10,
                      :ar_text_dummy,   attribute10,
                                        :attribute10),
          attribute11 =
               DECODE(:attribute11,
                      :ar_text_dummy,   attribute11,
                                        :attribute11),
          attribute12 =
               DECODE(:attribute12,
                      :ar_text_dummy,   attribute12,
                                        :attribute12),
          attribute13 =
               DECODE(:attribute13,
                      :ar_text_dummy,   attribute13,
                                        :attribute13),
          attribute14 =
               DECODE(:attribute14,
                      :ar_text_dummy,   attribute14,
                                        :attribute14),
          attribute15 =
               DECODE(:attribute15,
                      :ar_text_dummy,   attribute15,
                                        :attribute15),
          global_attribute_category =
               DECODE(:global_attribute_category,
                      :ar_text_dummy,   global_attribute_category,
                                        :global_attribute_category),
          global_attribute1 =
               DECODE(:global_attribute1,
                      :ar_text_dummy,   global_attribute1,
                                        :global_attribute1),
          global_attribute2 =
               DECODE(:global_attribute2,
                      :ar_text_dummy,   global_attribute2,
                                        :global_attribute2),
          global_attribute3 =
               DECODE(:global_attribute3,
                      :ar_text_dummy,   global_attribute3,
                                        :global_attribute3),
          global_attribute4 =
               DECODE(:global_attribute4,
                      :ar_text_dummy,   global_attribute4,
                                        :global_attribute4),
          global_attribute5 =
               DECODE(:global_attribute5,
                      :ar_text_dummy,   global_attribute5,
                                        :global_attribute5),
          global_attribute6 =
               DECODE(:global_attribute6,
                      :ar_text_dummy,   global_attribute6,
                                        :global_attribute6),
          global_attribute7 =
               DECODE(:global_attribute7,
                      :ar_text_dummy,   global_attribute7,
                                        :global_attribute7),
          global_attribute8 =
               DECODE(:global_attribute8,
                      :ar_text_dummy,   global_attribute8,
                                        :global_attribute8),
          global_attribute9 =
               DECODE(:global_attribute9,
                      :ar_text_dummy,   global_attribute9,
                                        :global_attribute9),
          global_attribute10 =
               DECODE(:global_attribute10,
                      :ar_text_dummy,   global_attribute10,
                                        :global_attribute10),
          global_attribute11 =
               DECODE(:global_attribute11,
                      :ar_text_dummy,   global_attribute11,
                                        :global_attribute11),
          global_attribute12 =
               DECODE(:global_attribute12,
                      :ar_text_dummy,   global_attribute12,
                                        :global_attribute12),
          global_attribute13 =
               DECODE(:global_attribute13,
                      :ar_text_dummy,   global_attribute13,
                                        :global_attribute13),
          global_attribute14 =
               DECODE(:global_attribute14,
                      :ar_text_dummy,   global_attribute14,
                                        :global_attribute14),
          global_attribute15 =
               DECODE(:global_attribute15,
                      :ar_text_dummy,   global_attribute15,
                                        :global_attribute15),
          global_attribute16 =
               DECODE(:global_attribute16,
                      :ar_text_dummy,   global_attribute16,
                                        :global_attribute16),
          global_attribute17 =
               DECODE(:global_attribute17,
                      :ar_text_dummy,   global_attribute17,
                                        :global_attribute17),
          global_attribute18 =
               DECODE(:global_attribute18,
                      :ar_text_dummy,   global_attribute18,
                                        :global_attribute18),
          global_attribute19 =
               DECODE(:global_attribute19,
                      :ar_text_dummy,   global_attribute19,
                                        :global_attribute19),
          global_attribute20 =
               DECODE(:global_attribute20,
                      :ar_text_dummy,   global_attribute20,
                                        :global_attribute20),
          created_by =
               DECODE(:created_by,
                      :ar_number_dummy, created_by,
                                        :created_by),
          creation_date =
               DECODE(:creation_date,
                      :ar_date_dummy, creation_date,
                                        :creation_date),
          last_updated_by =
               DECODE(:last_updated_by,
                      :ar_number_dummy, :pg_user_id,
                                        :last_updated_by),
          last_update_date =
               DECODE(:last_update_date,
                      :ar_date_dummy, sysdate,
                                        :last_update_date),
          program_application_id =
               DECODE(:program_application_id,
                      :ar_number_dummy, program_application_id,
                                        :program_application_id),
          last_update_login =
               DECODE(:last_update_login,
                      :ar_number_dummy, nvl(:pg_conc_login_id,
                                            :pg_login_id),
                                        :last_update_login),
          program_id =
               DECODE(:program_id,
                      :ar_number_dummy, program_id,
                                        :program_id),
          program_update_date =
               DECODE(:program_update_date,
                      :ar_date_dummy, program_update_date,
                                        :program_update_date),
          set_of_books_id =
               DECODE(:set_of_books_id,
                      :ar_number_dummy, set_of_books_id,
                                        :set_of_books_id),
          gross_extended_amount =
               DECODE(:gross_extended_amount,
                      :ar_number_dummy, gross_extended_amount,
                                        :gross_extended_amount),
          gross_unit_selling_price =
               DECODE(:gross_unit_selling_price,
                      :ar_number_dummy, gross_unit_selling_price,
                                        :gross_unit_selling_price),
          warehouse_id =
	       DECODE(:warehouse_id,
		      :ar_number_dummy, warehouse_id,
					:warehouse_id),
          translated_description =
               DECODE(:translated_description,
                      :ar_text_dummy,  translated_description,
                                        :translated_description),
          /* Bug 853757 */
          taxable_amount =
               DECODE(:taxable_amount,
                      :ar_number_dummy, taxable_amount,
                                        :taxable_amount),

          amount_includes_tax_flag =
               DECODE(:amount_includes_tax_flag,
                      :ar_flag_dummy, amount_includes_tax_flag,
                                        :amount_includes_tax_flag),

          extended_acctd_amount =
               DECODE(:extended_acctd_amount,
                      :ar_number_dummy, extended_acctd_amount,
                                        :extended_acctd_amount),
          br_ref_customer_trx_id =
               DECODE(:br_ref_customer_trx_id,
                      :ar_number_dummy, br_ref_customer_trx_id,
                                        :br_ref_customer_trx_id),
          br_ref_payment_schedule_id =
               DECODE(:br_ref_payment_schedule_id,
                      :ar_number_dummy, br_ref_payment_schedule_id,
                                        :br_ref_payment_schedule_id),
          br_adjustment_id =
               DECODE(:br_adjustment_id,
                      :ar_number_dummy, br_adjustment_id,
                                        :br_adjustment_id) ,

          wh_update_date =
               DECODE(:wh_update_date,
                      :ar_date_dummy, wh_update_date,
                                        :wh_update_date)  ,

          payment_set_id =
               DECODE(:payment_set_id,
                      :ar_number_dummy, payment_set_id,
                                        :payment_set_id) ,
          ship_to_customer_id =
               DECODE(:ship_to_customer_id,
                      :ar_number_dummy, ship_to_customer_id,
                                        :ship_to_customer_id)  ,
          ship_to_site_use_id =
               DECODE(:ship_to_site_use_id,
                      :ar_number_dummy, ship_to_site_use_id,
                                        :ship_to_site_use_id)   ,
          ship_to_contact_id =
               DECODE(:ship_to_contact_id,
                      :ar_number_dummy, ship_to_contact_id,
                                        :ship_to_contact_id),
          tax_classification_code =
               DECODE(:tax_classification_code,
                      :ar_text_dummy, tax_classification_code,
                                        :tax_classification_code),
          rule_end_date =
               DECODE(:rule_end_date,
                      :ar_date_dummy,   rule_end_date,
                                        :rule_end_date) ';


   arp_util.debug('arp_ctl_pkg.construct_line_update_stmt()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctl_pkg.construct_line_update_stmt()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    generic_update                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure Updates records in ra_customer_trx_lines identified by  |
 |    the where clause that is passed in as a parameter. Only those columns  |
 |    in the line record parameter that do not contain the special dummy     |
 |    values are updated.                                                    |
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
 |		      p_update_cursor  - identifies the cursor to use 	     |
 |                    p_where_clause   - identifies which rows to update     |
 | 		      p_where1         - value to bind into where clause     |
 |                    p_line_type      - line_type of the line               |
 |                    p_currency_code  - the currency code of the invoice    |
 |		      p_line_rec        - contains the new line values       |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
			 p_where_clause      IN varchar2,
			 p_where1            IN number,
                         p_line_type         IN
                           ra_customer_trx_lines.line_type%type,
                         p_currency_code     IN
                           fnd_currencies.currency_code%type,
                         p_line_rec          IN ra_customer_trx_lines%rowtype)
                       IS

   l_count             number;
   l_update_statement  varchar2(32767);
   --{bug#3339072 MRC trx lines
   ctl_array           dbms_sql.number_table;
   --}

BEGIN
   arp_util.debug('arp_ctl_pkg.generic_update()+');

  /*--------------------------------------------------------------+
   |  If this update statement has not already been parsed, 	  |
   |  construct the statement and parse it.			  |
   |  Otherwise, use the already parsed statement and rebind its  |
   |  variables.						  |
   +--------------------------------------------------------------*/

   IF (p_update_cursor is null)
   THEN

         p_update_cursor := dbms_sql.open_cursor;

         /*---------------------------------+
          |  Construct the update statement |
          +---------------------------------*/

         arp_ctl_pkg.construct_line_update_stmt(l_update_statement);

         l_update_statement := l_update_statement || p_where_clause ||
            --{BUG#3339072 MRC trx line
            ' RETURNING :customer_trx_line_id INTO :ctl_value ';
            --}

         arp_util.debug('Update statement:');
         arp_util.debug('');
         arp_util.debug(l_update_statement);
         arp_util.debug('');

         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/

         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);

   END IF;

   arp_ctl_pkg.bind_line_variables(p_update_cursor, p_line_rec);

  /*-----------------------------------------+
   |  Bind the variables in the where clause |
   +-----------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':where_1',
                          p_where1);

   dbms_sql.bind_variable(p_update_cursor, ':where_line_type',
                          p_line_type);

   dbms_sql.bind_variable(p_update_cursor, ':invoice_currency_code',
                          p_currency_code);

   --{BUG#3339072
   dbms_sql.bind_array(p_update_cursor, ':ctl_value',
                          ctl_array);
   --}

   l_count := dbms_sql.execute(p_update_cursor);

   arp_util.debug( to_char(l_count) || ' rows updated');

   --{BUG#3339072
   dbms_sql.variable_value(p_update_cursor, ':ctl_value',
                           ctl_array);
   --}

   /*------------------------------------------------------------+
    |  Raise the NO_DATA_FOUND exception if no rows were updated |
    +------------------------------------------------------------*/

   IF         (l_count = 0)
   THEN RAISE NO_DATA_FOUND;
   END IF;

   arp_util.debug('arp_ctl_pkg.generic_update()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctl_pkg.generic_update()');
        arp_util.debug(l_update_statement);
        arp_util.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));

        arp_util.debug('');
        arp_util.debug('-------- parameters for generic_update() ------');
        arp_util.debug('p_update_cursor    = ' || p_update_cursor);
        arp_util.debug('p_where_clause     = ' || p_where_clause);
        arp_util.debug('p_where1           = ' || p_where1);
        arp_util.debug('p_line_type        = ' || p_line_type);
        arp_util.debug('p_currency_code    = ' || p_currency_code);
        display_line_rec(p_line_rec);

        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes all columns in the parameter line record    |
 |    to the appropriate dummy value for its datatype.			     |
 |    									     |
 |    The dummy values are defined in the following package level constants: |
 |	AR_TEXT_DUMMY 							     |
 |	AR_TEXT3_DUMMY 							     |
 |	AR_FLAG_DUMMY							     |
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
 |                    p_line_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |     Rel. 11 Changes:							     |
 |     ----------------							     |
 |     07-22-97   OSTEINME		added code to dummify three new      |
 |					database columns:                    |
 |					  - gross_unit_selling_price         |
 |					  - gross_extended_amount            |
 |					  - amount_includes_tax_flag         |
 |                                                                           |
 |     08-20-97   KTANG                 dummify global_attribute_category and|
 |                                      global_attribute[1-20] for global    |
 |                                      descriptive flexfield                |
 |                                                                           |
 |                                                                           |
 |     10-JAN-99  Saloni Shah           added warehouse_id for global tax    |
 |                                      engine changes                       |
 |     22-MAR-99  Debbie Jancis         added translated_description for MLS |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns                |
 |                              EXTENDED_ACCTD_AMOUNT, BR_REF_CUSTOMER_TRX_ID,  |
 |                              BR_REF_PAYMENT_SCHEDULE_ID and BR_ADJUSTMENT_ID |
 |                              into table handlers                             |
 |									     |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added column wh_update_date    |
 | 					      into the table handlers. 	     |
 +===========================================================================*/


PROCEDURE set_to_dummy( p_line_rec OUT NOCOPY ra_customer_trx_lines%rowtype) IS

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_ctl_pkg.set_to_dummy()+');
    END IF;

    p_line_rec.customer_trx_line_id 		:= AR_NUMBER_DUMMY;
    p_line_rec.customer_trx_id 			:= AR_NUMBER_DUMMY;
    p_line_rec.line_number			:= AR_NUMBER_DUMMY;
    p_line_rec.line_type			:= AR_TEXT_DUMMY;
    p_line_rec.quantity_credited		:= AR_NUMBER_DUMMY;
    p_line_rec.quantity_invoiced		:= AR_NUMBER_DUMMY;
    p_line_rec.quantity_ordered			:= AR_NUMBER_DUMMY;
    p_line_rec.unit_selling_price		:= AR_NUMBER_DUMMY;
    p_line_rec.unit_standard_price		:= AR_NUMBER_DUMMY;
    p_line_rec.revenue_amount			:= AR_NUMBER_DUMMY;
    p_line_rec.extended_amount			:= AR_NUMBER_DUMMY;
    p_line_rec.memo_line_id			:= AR_NUMBER_DUMMY;
    p_line_rec.inventory_item_id		:= AR_NUMBER_DUMMY;
    p_line_rec.item_exception_rate_id		:= AR_NUMBER_DUMMY;
    p_line_rec.description			:= AR_TEXT_DUMMY;
    p_line_rec.item_context			:= AR_TEXT_DUMMY;
    p_line_rec.initial_customer_trx_line_id	:= AR_NUMBER_DUMMY;
    p_line_rec.link_to_cust_trx_line_id		:= AR_NUMBER_DUMMY;
    p_line_rec.previous_customer_trx_id		:= AR_NUMBER_DUMMY;
    p_line_rec.previous_customer_trx_line_id	:= AR_NUMBER_DUMMY;
    p_line_rec.accounting_rule_duration		:= AR_NUMBER_DUMMY;
    p_line_rec.accounting_rule_id		:= AR_NUMBER_DUMMY;
    p_line_rec.rule_start_date			:= AR_DATE_DUMMY;
    p_line_rec.autorule_complete_flag		:= AR_FLAG_DUMMY;
    p_line_rec.autorule_duration_processed	:= AR_NUMBER_DUMMY;
    p_line_rec.reason_code			:= AR_TEXT_DUMMY;
    p_line_rec.last_period_to_credit		:= AR_NUMBER_DUMMY;
    p_line_rec.sales_order			:= AR_TEXT_DUMMY;
    p_line_rec.sales_order_date			:= AR_DATE_DUMMY;
    p_line_rec.sales_order_line			:= AR_TEXT_DUMMY;
    p_line_rec.sales_order_revision		:= AR_NUMBER_DUMMY;
    p_line_rec.sales_order_source		:= AR_TEXT_DUMMY;
    p_line_rec.vat_tax_id			:= AR_NUMBER_DUMMY;
    p_line_rec.tax_exempt_flag			:= AR_FLAG_DUMMY;
    p_line_rec.sales_tax_id			:= AR_NUMBER_DUMMY;
    p_line_rec.location_segment_id		:= AR_NUMBER_DUMMY;
    p_line_rec.tax_exempt_number		:= AR_TEXT_DUMMY;
    p_line_rec.tax_exempt_reason_code		:= AR_TEXT_DUMMY;
    p_line_rec.tax_vendor_return_code		:= AR_TEXT_DUMMY;
    p_line_rec.taxable_flag			:= AR_FLAG_DUMMY;
    p_line_rec.tax_exemption_id			:= AR_NUMBER_DUMMY;
    p_line_rec.tax_precedence			:= AR_NUMBER_DUMMY;
    p_line_rec.tax_rate				:= AR_NUMBER_DUMMY;
    p_line_rec.uom_code				:= AR_TEXT3_DUMMY;
    p_line_rec.autotax				:= AR_FLAG_DUMMY;
    p_line_rec.movement_id			:= AR_NUMBER_DUMMY;
    p_line_rec.default_ussgl_transaction_code	:= AR_TEXT_DUMMY;
    p_line_rec.default_ussgl_trx_code_context	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_context		:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute1	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute2	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute3	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute4	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute5	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute6	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute7	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute8	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute9	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute10	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute11	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute12	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute13	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute14	:= AR_TEXT_DUMMY;
    p_line_rec.interface_line_attribute15	:= AR_TEXT_DUMMY;
    p_line_rec.attribute_category		:= AR_TEXT_DUMMY;
    p_line_rec.attribute1			:= AR_TEXT_DUMMY;
    p_line_rec.attribute2			:= AR_TEXT_DUMMY;
    p_line_rec.attribute3			:= AR_TEXT_DUMMY;
    p_line_rec.attribute4			:= AR_TEXT_DUMMY;
    p_line_rec.attribute5			:= AR_TEXT_DUMMY;
    p_line_rec.attribute6			:= AR_TEXT_DUMMY;
    p_line_rec.attribute7			:= AR_TEXT_DUMMY;
    p_line_rec.attribute8			:= AR_TEXT_DUMMY;
    p_line_rec.attribute9			:= AR_TEXT_DUMMY;
    p_line_rec.attribute10			:= AR_TEXT_DUMMY;
    p_line_rec.attribute11			:= AR_TEXT_DUMMY;
    p_line_rec.attribute12			:= AR_TEXT_DUMMY;
    p_line_rec.attribute13			:= AR_TEXT_DUMMY;
    p_line_rec.attribute14			:= AR_TEXT_DUMMY;
    p_line_rec.attribute15			:= AR_TEXT_DUMMY;
    p_line_rec.global_attribute_category        := AR_TEXT_DUMMY;
    p_line_rec.global_attribute1                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute2                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute3                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute4                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute5                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute6                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute7                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute8                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute9                := AR_TEXT_DUMMY;
    p_line_rec.global_attribute10               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute11               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute12               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute13               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute14               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute15               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute16               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute17               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute18               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute19               := AR_TEXT_DUMMY;
    p_line_rec.global_attribute20               := AR_TEXT_DUMMY;
    p_line_rec.created_by			:= AR_NUMBER_DUMMY;
    p_line_rec.creation_date			:= AR_DATE_DUMMY;
    p_line_rec.last_updated_by			:= AR_NUMBER_DUMMY;
    p_line_rec.last_update_date			:= AR_DATE_DUMMY;
    p_line_rec.program_application_id		:= AR_NUMBER_DUMMY;
    p_line_rec.last_update_login		:= AR_NUMBER_DUMMY;
    p_line_rec.program_id			:= AR_NUMBER_DUMMY;
    p_line_rec.program_update_date		:= AR_DATE_DUMMY;
    p_line_rec.set_of_books_id			:= AR_NUMBER_DUMMY;
    p_line_rec.payment_set_id 		        := AR_NUMBER_DUMMY;

    -- Rel. 11 Changes:

    p_line_rec.gross_unit_selling_price		:= AR_NUMBER_DUMMY;
    p_line_rec.gross_extended_amount		:= AR_NUMBER_DUMMY;
    p_line_rec.amount_includes_tax_flag		:= AR_FLAG_DUMMY;

    -- Rel 11.5 Changes (for global tax engine)
    p_line_rec.warehouse_id			:= AR_NUMBER_DUMMY;
    p_line_rec.translated_description           := AR_TEXT_DUMMY;

    /* Bug 853757 */
    p_line_rec.taxable_amount			:= AR_NUMBER_DUMMY;

    p_line_rec.extended_acctd_amount            := AR_NUMBER_DUMMY;
    p_line_rec.br_ref_customer_trx_id           := AR_NUMBER_DUMMY;
    p_line_rec.br_ref_payment_schedule_id       := AR_NUMBER_DUMMY;
    p_line_rec.br_adjustment_id                 := AR_NUMBER_DUMMY;
    p_line_rec.wh_update_date			:= AR_DATE_DUMMY;

    /* 4713671 */
    p_line_rec.ship_to_customer_id              := AR_NUMBER_DUMMY;
    p_line_rec.ship_to_site_use_id              := AR_NUMBER_DUMMY;
    p_line_rec.ship_to_contact_id               := AR_NUMBER_DUMMY;
    p_line_rec.tax_classification_code          := AR_TEXT_DUMMY;

   p_line_rec.rule_end_date                     := AR_DATE_DUMMY;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_ctl_pkg.set_to_dummy()-');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_ctl_pkg.set_to_dummy()');
        END IF;
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ra_customer_trx_lines into a  |
 |    variable specified as a parameter based on the table's primary key,    |
 |    customer_trx__line_id. 						     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug        	                                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id - identifies the record to fetch|
 |              OUT:                                                         |
 |                    p_line_rec	     - contains the fetched record   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_line_rec         OUT NOCOPY ra_customer_trx_lines%rowtype,
                   p_customer_trx_line_id  IN
                             ra_customer_trx_lines.customer_trx_line_id%type )
          IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.fetch_p()+');
    END IF;

    SELECT *
    INTO   p_line_rec
    FROM   ra_customer_trx_lines
    WHERE  customer_trx_line_id = p_customer_trx_line_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.fetch_p()-');
    END IF;

    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(   'EXCEPTION: arp_ctl_pkg.fetch_p' );
           arp_util.debug(  '');
           arp_util.debug(  '-------- parameters for fetch_p() ------');
           arp_util.debug(  'p_customer_trx_line_id  = ' || p_customer_trx_line_id);
        END IF;

        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_customer_trx_lines row identified by the   |
 |    p_customer_trx_line_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id	- identifies the row to lock |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_customer_trx_line_id  IN
                            ra_customer_trx_lines.customer_trx_line_id%type )
          IS

    l_customer_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%type;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.lock_p()+');
    END IF;


    SELECT        customer_trx_line_id
    INTO          l_customer_trx_line_id
    FROM          ra_customer_trx_lines
    WHERE         customer_trx_line_id = p_customer_trx_line_id
    FOR UPDATE OF customer_trx_line_id NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.lock_p()-');
    END IF;

    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_util.debug(   'EXCEPTION: arp_ctl_pkg.lock_p' );
               arp_util.debug(  '');
               arp_util.debug(  '-------- parameters for lock_p() ------');
               arp_util.debug(  'p_customer_trx_line_id  = ' ||
                           p_customer_trx_line_id);
            END IF;

            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_customer_trx_lines rows identified by the  |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the rows to lock	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ct_id( p_customer_trx_id  IN
                            ra_customer_trx.customer_trx_id%type )
          IS

    CURSOR LOCK_C IS
    SELECT        'lock'
    FROM          ra_customer_trx_lines
    WHERE         customer_trx_id = p_customer_trx_id
    FOR UPDATE OF customer_trx_line_id NOWAIT;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.lock_f_ct_id()+');
    END IF;

    OPEN lock_c;
    CLOSE lock_c;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.lock_f_ct_id()-');
    END IF;

    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_util.debug(   'EXCEPTION: arp_ctl_pkg.lock_f_ct_id' );
               arp_util.debug(  '');
               arp_util.debug(  '-------- parameters for lock_f_ct_id() ------');
               arp_util.debug(  'p_customer_trx_id  = ' ||
                           p_customer_trx_id);
            END IF;

            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_customer_trx_lines row identified by the   |
 |    p_ra_customer_trx_line_id parameter and populates the 		     |
 |    p_line_rec parameter with the row that was locked			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id	- identifies the row to lock |
 |              OUT:                                                         |
 |                    p_line_rec		- contains the locked row    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_line_rec        IN OUT NOCOPY ra_customer_trx_lines%rowtype,
                        p_customer_trx_line_id IN
                          ra_customer_trx_lines.customer_trx_line_id%type ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.lock_fetch_p()+');
    END IF;

    SELECT        *
    INTO          p_line_rec
    FROM          ra_customer_trx_lines
    WHERE         customer_trx_line_id = p_customer_trx_line_id
    FOR UPDATE OF customer_trx_line_id NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.lock_fetch_p()-');
    END IF;

    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(   'EXCEPTION: arp_ctl_pkg.lock_fetch_p' );
               arp_util.debug(  '');
               arp_util.debug(  '-------- parameters for lock_fetch_p() ------');
               arp_util.debug(  'p_customer_trx_line_id  = ' ||
                           p_customer_trx_line_id);
            END IF;
            display_line_rec(p_line_rec);

            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_customer_trx_lines row identified by the   |
 |    p_customer_trx_line_id parameter only if no columns in that row have   |
 |    changed from when they were first selected in the form.		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id	- identifies the row to lock |
 | 		      p_line_rec	    	- line record for comparison |
 |                    p_ignore_who_flag  - directs system to ignore who cols |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |     29-JUN-95  Charlie Tomberg     Modified to use select for update      |
 |     04-DEC-95  Martin Johnson      Handle NO_DATA_FOUND exception         |
 |                                                                           |
 |     Rel. 11 Changes:							     |
 |     ----------------							     |
 |     07-22-97   OSTEINME		added code to handle three new       |
 |					database columns:                    |
 |					  - gross_unit_selling_price         |
 |					  - gross_extended_amount            |
 |					  - amount_includes_tax_flag         |
 |                                                                           |
 |     08-20-97   KTANG                 handle global_attribute_category and |
 |                                      global_attribute[1-20] for global    |
 |                                      descriptive flexfield                |
 |                                                                           |
 |     10-JAN-99  Saloni Shah           added warehouse_id for global tax    |
 |                                      engine change                        |
 |     22-MAR-99  Debbie Jancis         added translated_description for MLS |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns                |
 |                              EXTENDED_ACCTD_AMOUNT, BR_REF_CUSTOMER_TRX_ID,  |
 |                              BR_REF_PAYMENT_SCHEDULE_ID and BR_ADJUSTMENT_ID |
 |                              into table handlers                             |
 |									     |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added column wh_update_date    |
 | 					      into the table handlers. 	     |
 +===========================================================================*/

PROCEDURE lock_compare_p( p_line_rec          IN ra_customer_trx_lines%rowtype,
                          p_customer_trx_line_id  IN
                            ra_customer_trx_lines.customer_trx_line_id%type,
                          p_ignore_who_flag BOOLEAN DEFAULT FALSE )  IS

    l_new_line_rec  ra_customer_trx_lines%rowtype;
    l_temp_line_rec ra_customer_trx_lines%rowtype;
    l_ignore_who_flag varchar2(2);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.lock_compare_p()+');
    END IF;

    IF     (p_ignore_who_flag = TRUE)
    THEN   l_ignore_who_flag := 'Y';
    ELSE   l_ignore_who_flag := 'N';
    END IF;

    SELECT   *
    INTO     l_new_line_rec
    FROM     ra_customer_trx_lines ctl
    WHERE    ctl.customer_trx_line_id = p_customer_trx_line_id
    AND
       (
           NVL(ctl.customer_trx_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.customer_trx_line_id,
                        AR_NUMBER_DUMMY, ctl.customer_trx_line_id,
                                         p_line_rec.customer_trx_line_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.customer_trx_id,
                        AR_NUMBER_DUMMY, ctl.customer_trx_id,
                                         p_line_rec.customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.line_number, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.line_number,
                        AR_NUMBER_DUMMY, ctl.line_number,
                                         p_line_rec.line_number),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.line_type, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.line_type,
                        AR_TEXT_DUMMY, ctl.line_type,
                                         p_line_rec.line_type),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(substr(ctl.quantity_credited,1,37), AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.quantity_credited,
                        AR_NUMBER_DUMMY, substr(ctl.quantity_credited,1,37),
                                         substr(p_line_rec.quantity_credited,1,37)),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.quantity_invoiced, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.quantity_invoiced,
                        AR_NUMBER_DUMMY, ctl.quantity_invoiced,
                                         p_line_rec.quantity_invoiced),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.quantity_ordered, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.quantity_ordered,
                        AR_NUMBER_DUMMY, ctl.quantity_ordered,
                                         p_line_rec.quantity_ordered),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.unit_selling_price, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.unit_selling_price,
                        AR_NUMBER_DUMMY, ctl.unit_selling_price,
                                         p_line_rec.unit_selling_price),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.unit_standard_price, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.unit_standard_price,
                        AR_NUMBER_DUMMY, ctl.unit_standard_price,
                                         p_line_rec.unit_standard_price),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.revenue_amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.revenue_amount,
                        AR_NUMBER_DUMMY, ctl.revenue_amount,
                                         p_line_rec.revenue_amount),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.extended_amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.extended_amount,
                        AR_NUMBER_DUMMY, ctl.extended_amount,
                                         p_line_rec.extended_amount),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.memo_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.memo_line_id,
                        AR_NUMBER_DUMMY, ctl.memo_line_id,
                                         p_line_rec.memo_line_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.inventory_item_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.inventory_item_id,
                        AR_NUMBER_DUMMY, ctl.inventory_item_id,
                                         p_line_rec.inventory_item_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.item_exception_rate_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.item_exception_rate_id,
                        AR_NUMBER_DUMMY, ctl.item_exception_rate_id,
                                         p_line_rec.item_exception_rate_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.description, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.description,
                        AR_TEXT_DUMMY, ctl.description,
                                         p_line_rec.description),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.item_context, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.item_context,
                        AR_TEXT_DUMMY, ctl.item_context,
                                         p_line_rec.item_context),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.initial_customer_trx_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.initial_customer_trx_line_id,
                        AR_NUMBER_DUMMY, ctl.initial_customer_trx_line_id,
                                      p_line_rec.initial_customer_trx_line_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.link_to_cust_trx_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.link_to_cust_trx_line_id,
                        AR_NUMBER_DUMMY, ctl.link_to_cust_trx_line_id,
                                         p_line_rec.link_to_cust_trx_line_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.previous_customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.previous_customer_trx_id,
                        AR_NUMBER_DUMMY, ctl.previous_customer_trx_id,
                                         p_line_rec.previous_customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.previous_customer_trx_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.previous_customer_trx_line_id,
                        AR_NUMBER_DUMMY, ctl.previous_customer_trx_line_id,
                                     p_line_rec.previous_customer_trx_line_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.accounting_rule_duration, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.accounting_rule_duration,
                        AR_NUMBER_DUMMY, ctl.accounting_rule_duration,
                                         p_line_rec.accounting_rule_duration),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.accounting_rule_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.accounting_rule_id,
                        AR_NUMBER_DUMMY, ctl.accounting_rule_id,
                                         p_line_rec.accounting_rule_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.rule_start_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_line_rec.rule_start_date,
                        AR_DATE_DUMMY, ctl.rule_start_date,
                                         p_line_rec.rule_start_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(ctl.autorule_complete_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_line_rec.autorule_complete_flag,
                        AR_FLAG_DUMMY, ctl.autorule_complete_flag,
                                         p_line_rec.autorule_complete_flag),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(ctl.autorule_duration_processed, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.autorule_duration_processed,
                        AR_NUMBER_DUMMY, ctl.autorule_duration_processed,
                                      p_line_rec.autorule_duration_processed),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.reason_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.reason_code,
                        AR_TEXT_DUMMY, ctl.reason_code,
                                         p_line_rec.reason_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.warehouse_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.warehouse_id,
			AR_NUMBER_DUMMY, ctl.warehouse_id,
					 p_line_rec.warehouse_id),
                 AR_NUMBER_DUMMY
             )
         AND
           NVL(ctl.translated_description, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.translated_description,
                        AR_TEXT_DUMMY, ctl.translated_description,
                                         p_line_rec.translated_description),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.last_period_to_credit, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.last_period_to_credit,
                        AR_NUMBER_DUMMY, ctl.last_period_to_credit,
                                         p_line_rec.last_period_to_credit),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.sales_order, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.sales_order,
                        AR_TEXT_DUMMY, ctl.sales_order,
                                         p_line_rec.sales_order),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.sales_order_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_line_rec.sales_order_date,
                        AR_DATE_DUMMY, ctl.sales_order_date,
                                         p_line_rec.sales_order_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(ctl.sales_order_line, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.sales_order_line,
                        AR_TEXT_DUMMY, ctl.sales_order_line,
                                       p_line_rec.sales_order_line),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.sales_order_revision, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.sales_order_revision,
                        AR_NUMBER_DUMMY, ctl.sales_order_revision,
                                         p_line_rec.sales_order_revision),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.sales_order_source, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.sales_order_source,
                        AR_TEXT_DUMMY, ctl.sales_order_source,
                                         p_line_rec.sales_order_source),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.vat_tax_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.vat_tax_id,
                        AR_NUMBER_DUMMY, ctl.vat_tax_id,
                                         p_line_rec.vat_tax_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.tax_exempt_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_line_rec.tax_exempt_flag,
                        AR_FLAG_DUMMY, ctl.tax_exempt_flag,
                                         p_line_rec.tax_exempt_flag),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(ctl.sales_tax_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.sales_tax_id,
                        AR_NUMBER_DUMMY, ctl.sales_tax_id,
                                         p_line_rec.sales_tax_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.location_segment_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.location_segment_id,
                        AR_NUMBER_DUMMY, ctl.location_segment_id,
                                         p_line_rec.location_segment_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.tax_exempt_number, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.tax_exempt_number,
                        AR_TEXT_DUMMY, ctl.tax_exempt_number,
                                         p_line_rec.tax_exempt_number),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.tax_exempt_reason_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.tax_exempt_reason_code,
                        AR_TEXT_DUMMY, ctl.tax_exempt_reason_code,
                                         p_line_rec.tax_exempt_reason_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.tax_vendor_return_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.tax_vendor_return_code,
                        AR_TEXT_DUMMY, ctl.tax_vendor_return_code,
                                         p_line_rec.tax_vendor_return_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.taxable_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_line_rec.taxable_flag,
                        AR_FLAG_DUMMY, ctl.taxable_flag,
                                         p_line_rec.taxable_flag),
                 AR_FLAG_DUMMY
              )
       )
     AND
       (
           NVL(ctl.tax_exemption_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.tax_exemption_id,
                        AR_NUMBER_DUMMY, ctl.tax_exemption_id,
                                         p_line_rec.tax_exemption_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.tax_precedence, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.tax_precedence,
                        AR_NUMBER_DUMMY, ctl.tax_precedence,
                                         p_line_rec.tax_precedence),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.tax_rate, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.tax_rate,
                        AR_NUMBER_DUMMY, ctl.tax_rate,
                                         p_line_rec.tax_rate),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.uom_code, AR_TEXT3_DUMMY) =
           NVL(
                 DECODE(p_line_rec.uom_code,
                        AR_TEXT3_DUMMY, ctl.uom_code,
                                         p_line_rec.uom_code),
                 AR_TEXT3_DUMMY
              )
         AND
           NVL(ctl.autotax, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_line_rec.autotax,
                        AR_FLAG_DUMMY, ctl.autotax,
                                         p_line_rec.autotax),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(ctl.movement_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.movement_id,
                        AR_NUMBER_DUMMY, ctl.movement_id,
                                         p_line_rec.movement_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.default_ussgl_transaction_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.default_ussgl_transaction_code,
                        AR_TEXT_DUMMY, ctl.default_ussgl_transaction_code,
                                    p_line_rec.default_ussgl_transaction_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.default_ussgl_trx_code_context, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.default_ussgl_trx_code_context,
                        AR_TEXT_DUMMY, ctl.default_ussgl_trx_code_context,
                                   p_line_rec.default_ussgl_trx_code_context),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_context, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_context,
                        AR_TEXT_DUMMY, ctl.interface_line_context,
                                         p_line_rec.interface_line_context),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute1,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute1,
                                         p_line_rec.interface_line_attribute1),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute2,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute2,
                                         p_line_rec.interface_line_attribute2),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute3,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute3,
                                         p_line_rec.interface_line_attribute3),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute4,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute4,
                                         p_line_rec.interface_line_attribute4),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute5,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute5,
                                         p_line_rec.interface_line_attribute5),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute6,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute6,
                                         p_line_rec.interface_line_attribute6),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute7,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute7,
                                         p_line_rec.interface_line_attribute7),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute8,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute8,
                                         p_line_rec.interface_line_attribute8),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute9,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute9,
                                         p_line_rec.interface_line_attribute9),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute10,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute10,
                                        p_line_rec.interface_line_attribute10),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute11,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute11,
                                        p_line_rec.interface_line_attribute11),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute12,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute12,
                                        p_line_rec.interface_line_attribute12),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute13,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute13,
                                        p_line_rec.interface_line_attribute13),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute14,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute14,
                                        p_line_rec.interface_line_attribute14),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.interface_line_attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.interface_line_attribute15,
                        AR_TEXT_DUMMY, ctl.interface_line_attribute15,
                                        p_line_rec.interface_line_attribute15),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute_category, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute_category,
                        AR_TEXT_DUMMY, ctl.attribute_category,
                                         p_line_rec.attribute_category),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute1,
                        AR_TEXT_DUMMY, ctl.attribute1,
                                         p_line_rec.attribute1),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute2,
                        AR_TEXT_DUMMY, ctl.attribute2,
                                         p_line_rec.attribute2),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute3,
                        AR_TEXT_DUMMY, ctl.attribute3,
                                         p_line_rec.attribute3),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute4,
                        AR_TEXT_DUMMY, ctl.attribute4,
                                         p_line_rec.attribute4),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute5,
                        AR_TEXT_DUMMY, ctl.attribute5,
                                         p_line_rec.attribute5),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute6,
                        AR_TEXT_DUMMY, ctl.attribute6,
                                         p_line_rec.attribute6),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute7,
                        AR_TEXT_DUMMY, ctl.attribute7,
                                         p_line_rec.attribute7),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute8,
                        AR_TEXT_DUMMY, ctl.attribute8,
                                         p_line_rec.attribute8),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute9,
                        AR_TEXT_DUMMY, ctl.attribute9,
                                         p_line_rec.attribute9),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute10,
                        AR_TEXT_DUMMY, ctl.attribute10,
                                         p_line_rec.attribute10),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute11,
                        AR_TEXT_DUMMY, ctl.attribute11,
                                         p_line_rec.attribute11),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute12,
                        AR_TEXT_DUMMY, ctl.attribute12,
                                         p_line_rec.attribute12),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute13,
                        AR_TEXT_DUMMY, ctl.attribute13,
                                         p_line_rec.attribute13),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute14,
                        AR_TEXT_DUMMY, ctl.attribute14,
                                         p_line_rec.attribute14),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.attribute15,
                        AR_TEXT_DUMMY, ctl.attribute15,
                                         p_line_rec.attribute15),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute_category, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute_category,
                        AR_TEXT_DUMMY, ctl.global_attribute_category,
                                         p_line_rec.global_attribute_category),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute1,
                        AR_TEXT_DUMMY, ctl.global_attribute1,
                                         p_line_rec.global_attribute1),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute2,
                        AR_TEXT_DUMMY, ctl.global_attribute2,
                                         p_line_rec.global_attribute2),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute3,
                        AR_TEXT_DUMMY, ctl.global_attribute3,
                                         p_line_rec.global_attribute3),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute4,
                        AR_TEXT_DUMMY, ctl.global_attribute4,
                                         p_line_rec.global_attribute4),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute5,
                        AR_TEXT_DUMMY, ctl.global_attribute5,
                                         p_line_rec.global_attribute5),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute6,
                        AR_TEXT_DUMMY, ctl.global_attribute6,
                                         p_line_rec.global_attribute6),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute7,
                        AR_TEXT_DUMMY, ctl.global_attribute7,
                                         p_line_rec.global_attribute7),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute8,
                        AR_TEXT_DUMMY, ctl.global_attribute8,
                                         p_line_rec.global_attribute8),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute9,
                        AR_TEXT_DUMMY, ctl.global_attribute9,
                                         p_line_rec.global_attribute9),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute10,
                        AR_TEXT_DUMMY, ctl.global_attribute10,
                                         p_line_rec.global_attribute10),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute11,
                        AR_TEXT_DUMMY, ctl.global_attribute11,
                                         p_line_rec.global_attribute11),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute12,
                        AR_TEXT_DUMMY, ctl.global_attribute12,
                                         p_line_rec.global_attribute12),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute13,
                        AR_TEXT_DUMMY, ctl.global_attribute13,
                                         p_line_rec.global_attribute13),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute14,
                        AR_TEXT_DUMMY, ctl.global_attribute14,
                                         p_line_rec.global_attribute14),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute15,
                        AR_TEXT_DUMMY, ctl.global_attribute15,
                                         p_line_rec.global_attribute15),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute16, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute16,
                        AR_TEXT_DUMMY, ctl.global_attribute16,
                                         p_line_rec.global_attribute16),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute17, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute17,
                        AR_TEXT_DUMMY, ctl.global_attribute17,
                                         p_line_rec.global_attribute17),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute18, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute18,
                        AR_TEXT_DUMMY, ctl.global_attribute18,
                                         p_line_rec.global_attribute18),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute19, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute19,
                        AR_TEXT_DUMMY, ctl.global_attribute19,
                                         p_line_rec.global_attribute19),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.global_attribute20, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.global_attribute20,
                        AR_TEXT_DUMMY, ctl.global_attribute20,
                                         p_line_rec.global_attribute20),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(ctl.last_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctl.last_update_date, AR_DATE_DUMMY),
                              DECODE(
                                      p_line_rec.last_update_date,
                                      AR_DATE_DUMMY, ctl.last_update_date,
                                                  p_line_rec.last_update_date
                                    )
                       ),
                 AR_DATE_DUMMY
              )
         AND
           NVL(ctl.last_updated_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',   NVL(ctl.last_updated_by, AR_NUMBER_DUMMY),
                               DECODE(
                                      p_line_rec.last_updated_by,
                                      AR_NUMBER_DUMMY, ctl.last_updated_by,
                                                  p_line_rec.last_updated_by
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.creation_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctl.creation_date, AR_DATE_DUMMY),
                              DECODE(
                                     p_line_rec.creation_date,
                                     AR_DATE_DUMMY, ctl.creation_date,
                                                 p_line_rec.creation_date
                                    )
                       ),
                 AR_DATE_DUMMY
              )
         AND
           NVL(ctl.created_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctl.created_by, AR_NUMBER_DUMMY),
                              DECODE(
                                       p_line_rec.created_by,
                                       AR_NUMBER_DUMMY, ctl.created_by,
                                                      p_line_rec.created_by
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.last_update_login, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctl.last_update_login, AR_NUMBER_DUMMY),
                              DECODE(
                                       p_line_rec.last_update_login,
                                       AR_NUMBER_DUMMY, ctl.last_update_login,
                                                 p_line_rec.last_update_login
                                    )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.program_application_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctl.program_application_id, AR_NUMBER_DUMMY),
                              DECODE(
                                  p_line_rec.program_application_id,
                                  AR_NUMBER_DUMMY, ctl.program_application_id,
                                            p_line_rec.program_application_id
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.program_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctl.program_id, AR_NUMBER_DUMMY),
                              DECODE(
                                      p_line_rec.program_id,
                                      AR_NUMBER_DUMMY, ctl.program_id,
                                                       p_line_rec.program_id
                                    )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.program_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(ctl.program_update_date, AR_DATE_DUMMY),
                              DECODE(
                                       p_line_rec.program_update_date,
                                       AR_DATE_DUMMY, ctl.program_update_date,
                                                p_line_rec.program_update_date
                                    )
                       ),
                 AR_DATE_DUMMY
              )
         AND
           NVL(ctl.set_of_books_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.set_of_books_id,
                        AR_NUMBER_DUMMY, ctl.set_of_books_id,
                                         p_line_rec.set_of_books_id),
                 AR_NUMBER_DUMMY
              )
         /* Rel. 11 Changes: 					*/
         AND
           NVL(ctl.gross_extended_amount, NVL(ctl.extended_amount,
						AR_NUMBER_DUMMY)) =
           NVL(
                 DECODE(p_line_rec.gross_extended_amount,
                        AR_NUMBER_DUMMY,
				NVL(ctl.gross_extended_amount,
					ctl.extended_amount),
                                p_line_rec.gross_extended_amount),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.gross_unit_selling_price, NVL(ctl.unit_selling_price,
					AR_NUMBER_DUMMY)) =
           NVL(
                 DECODE(p_line_rec.gross_unit_selling_price,
                        AR_NUMBER_DUMMY,
				NVL(ctl.gross_unit_selling_price,
					ctl.unit_selling_price),
                                p_line_rec.gross_unit_selling_price),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(ctl.amount_includes_tax_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_line_rec.amount_includes_tax_flag,
                        AR_FLAG_DUMMY, ctl.amount_includes_tax_flag,
                                         p_line_rec.amount_includes_tax_flag),
                 AR_FLAG_DUMMY
              )
	 /* Bug 853757 */
	 AND
           NVL(ctl.taxable_amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.taxable_amount,
			AR_NUMBER_DUMMY, ctl.taxable_amount,
					 p_line_rec.taxable_amount),
		 AR_NUMBER_DUMMY
	      )
	 AND
           NVL(ctl.extended_acctd_amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.extended_acctd_amount,
			AR_NUMBER_DUMMY, ctl.extended_acctd_amount,
					 p_line_rec.extended_acctd_amount),
		 AR_NUMBER_DUMMY
	      )
	 AND
           NVL(ctl.br_ref_customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.br_ref_customer_trx_id,
			AR_NUMBER_DUMMY, ctl.br_ref_customer_trx_id,
					 p_line_rec.br_ref_customer_trx_id),
		 AR_NUMBER_DUMMY
	      )
	 AND
           NVL(ctl.br_ref_payment_schedule_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.br_ref_payment_schedule_id,
			AR_NUMBER_DUMMY, ctl.br_ref_payment_schedule_id,
					 p_line_rec.br_ref_payment_schedule_id),
		 AR_NUMBER_DUMMY
	      )
	 AND
           NVL(ctl.br_adjustment_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.br_adjustment_id,
			AR_NUMBER_DUMMY, ctl.br_adjustment_id,
					 p_line_rec.br_adjustment_id),
		 AR_NUMBER_DUMMY
	      )
	 AND
           NVL(ctl.wh_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_line_rec.wh_update_date,
			AR_DATE_DUMMY, ctl.wh_update_date,
					 p_line_rec.wh_update_date),
		 AR_DATE_DUMMY
	      )
	 AND
           NVL(ctl.rule_end_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_line_rec.rule_end_date,
			AR_DATE_DUMMY, ctl.rule_end_date,
					 p_line_rec.rule_end_date),
		 AR_DATE_DUMMY
	      )
         /* 4713671 */
	 AND
           NVL(ctl.ship_to_customer_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.ship_to_customer_id,
			AR_NUMBER_DUMMY, ctl.ship_to_customer_id,
					 p_line_rec.ship_to_customer_id),
		 AR_NUMBER_DUMMY
	      )
	 AND
           NVL(ctl.ship_to_site_use_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.ship_to_site_use_id,
			AR_NUMBER_DUMMY, ctl.ship_to_site_use_id,
					 p_line_rec.ship_to_site_use_id),
		 AR_NUMBER_DUMMY
	      )
	 AND
           NVL(ctl.ship_to_contact_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_line_rec.ship_to_contact_id,
			AR_NUMBER_DUMMY, ctl.ship_to_contact_id,
					 p_line_rec.ship_to_contact_id),
		 AR_NUMBER_DUMMY
	      )
	 AND
           NVL(ctl.tax_classification_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_line_rec.tax_classification_code,
			AR_TEXT_DUMMY, ctl.tax_classification_code,
					 p_line_rec.tax_classification_code),
		 AR_TEXT_DUMMY
	      )
       )
       FOR UPDATE OF customer_trx_line_id NOWAIT;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.lock_compare_p()-');
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(  '');
                 arp_util.debug(  'p_customer_trx_line_id  = ' ||
                              p_customer_trx_line_id );
                 arp_util.debug(  '-------- new line record --------');
              END IF;
              display_line_rec( p_line_rec );

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(  '');
                 arp_util.debug(  '-------- old line record --------');
              END IF;

              fetch_p( l_temp_line_rec,
                       p_customer_trx_line_id );

              display_line_rec( l_temp_line_rec );

              FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
              APP_EXCEPTION.Raise_Exception;

        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(   'EXCEPTION: arp_ctl_pkg.lock_compare_p' );
               arp_util.debug(  '');
               arp_util.debug(  '-------- parameters for lock_compare_p() ------');
               arp_util.debug(  'p_customer_trx_line_id  = ' ||
                           p_customer_trx_line_id);
               arp_util.debug(  'p_ignore_who_flag       = ' ||
                         arp_trx_util.boolean_to_varchar2(p_ignore_who_flag));
            END IF;
            display_line_rec(p_line_rec);


            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_customer_trx_lines row identified by the |
 |    p_customer_trx_line_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id  - identifies the row to delete |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_customer_trx_line_id  IN
                          ra_customer_trx_lines.customer_trx_line_id%type)
       IS


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.delete_p()+');
      arp_util.debug(  'deleting ctlid: ' || p_customer_trx_line_id);
   END IF;

   DELETE FROM ra_customer_trx_lines
   WHERE       customer_trx_line_id = p_customer_trx_line_id;

   IF ( SQL%ROWCOUNT = 0 )
   THEN     arp_util.debug('EXCEPTION:  arp_ctl_pkg.delete_p()');
            RAISE NO_DATA_FOUND;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.delete_p()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.delete_p()');
           arp_util.debug(  '');
           arp_util.debug(  '-------- parameters for delete_p() ------');
           arp_util.debug(  'p_customer_trx_line_id  = ' ||
                       p_customer_trx_line_id);
        END IF;

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_customer_trx_lines rows identified by    |
 |    the p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id  - identifies the rows to delete     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ct_id( p_customer_trx_id  IN
                                ra_customer_trx.customer_trx_id%type)
       IS

BEGIN


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.delete_f_ct_id()+');
   END IF;

   DELETE FROM ra_customer_trx_lines
   WHERE       customer_trx_id = p_customer_trx_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.delete_f_ct_id()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.delete_f_ct_id()');
           arp_util.debug(  '');
           arp_util.debug(  '-------- parameters for delete_f_ct_id() ------');
           arp_util.debug(  'p_customer_trx_id  = ' ||
                       p_customer_trx_id);
        END IF;

	RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ltctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the child ra_customer_trx_lines rows identified |
 |    by the p_link_to_cust_trx_line_id	parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_link_to_cust_trx_line_id  - identifies the rows to delete |
 |              OUT:                                                         |
 |               None							     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ltctl_id( p_link_to_cust_trx_line_id	IN
                          ra_customer_trx_lines.link_to_cust_trx_line_id%type)
       IS

BEGIN


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.delete_f_ltctl_id()+');
   END IF;

   DELETE FROM ra_customer_trx_lines
   WHERE       link_to_cust_trx_line_id = p_link_to_cust_trx_line_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.delete_f_ltctl_id()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.delete_f_ltctl_id()');
           arp_util.debug(  '');
           arp_util.debug(  '-------- parameters for delete_f_ltctl_id() ------');
           arp_util.debug(  'p_link_to_cust_trx_line_id = ' ||
                       p_link_to_cust_trx_line_id);
        END IF;

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_ltctl_id_type                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the child ra_customer_trx_lines rows identified |
 |    by the p_customer_trx_id, p_link_to_cust_trx_line_id and p_line_type   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_id           - identifies the transaction    |
 |               p_link_to_cust_trx_line_id  - identifies the parent line    |
 |               p_line_type                 - identifies the parent line    |
 |                                             type                          |
 |              OUT:                                                         |
 |               None                                                        |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-SEP-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ct_ltctl_id_type(
               p_customer_trx_id           IN
                          ra_customer_trx.customer_trx_id%type,
               p_link_to_cust_trx_line_id  IN
                          ra_customer_trx_lines.link_to_cust_trx_line_id%type,
               p_line_type                 IN
                          ra_customer_trx_lines.line_type%type DEFAULT NULL)
IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.delete_f_ct_ltctl_id_type()+');
   END IF;

   DELETE FROM ra_customer_trx_lines
   WHERE  customer_trx_id = p_customer_trx_id
   AND    decode(p_link_to_cust_trx_line_id,
            null, -99,
            customer_trx_line_id)  = nvl(p_link_to_cust_trx_line_id, -99)
   AND    line_type = nvl(p_line_type, line_type);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.delete_f_ct_ltctl_id_type()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.delete_f_ct_ltctl_id_type()');
           arp_util.debug(  '');
           arp_util.debug(  '---- parameters for delete_f_ct_ltctl_id_type() -----');
           arp_util.debug(  'p_customer_trx_id          = ' || p_customer_trx_id);
           arp_util.debug(  'p_link_to_cust_trx_line_id = ' ||
                                                 p_link_to_cust_trx_line_id);
           arp_util.debug(  'p_line_type                = ' || p_line_type);
        END IF;

        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_customer_trx_lines row identified by the |
 |    p_customer_trx_line_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id  - identifies the row to update |
 |                    p_line_rec            - contains the new column values |
 |                    p_currency_code         - transaction's currency code  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_line_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_line_rec IN ra_customer_trx_lines%rowtype,
                    p_customer_trx_line_id IN
                           ra_customer_trx_lines.customer_trx_line_id%type,
                    p_currency_code        IN fnd_currencies.currency_code%type
                                              DEFAULT NULL ) IS

   l_currency_code fnd_currencies.currency_code%type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.update_p()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));
   END IF;

  /*---------------------------------------------------------------+
   |  Get the transaction's currency code if it was not passed in  |
   +---------------------------------------------------------------*/

   IF (p_currency_code IS NULL)
   THEN
          SELECT ct.invoice_currency_code
          INTO   l_currency_code
          FROM   ra_customer_trx ct,
                 ra_customer_trx_lines ctl
          WHERE  ct.customer_trx_id       = ctl.customer_trx_id
          AND    ctl.customer_trx_line_id = p_customer_trx_line_id;
   ELSE   l_currency_code := p_currency_code;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'using currency code: ' || l_currency_code );
   END IF;

   arp_ctl_pkg.generic_update(  pg_cursor1,
			       ' WHERE customer_trx_line_id = :where_1 ' ||
                               ' AND :where_line_type is null',
                               p_customer_trx_line_id,
                               null,
                               l_currency_code,
                               p_line_rec);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));
   END IF;


EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.update_p()');
           arp_util.debug(  '');
           arp_util.debug(  '-------- parameters for update_p() ------');
           arp_util.debug(  'p_customer_trx_line_id  = ' ||
                       p_customer_trx_line_id);
           arp_util.debug(  'p_currency_code         = ' || p_currency_code);
        END IF;
        display_line_rec(p_line_rec);

        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_customer_trx_lines rows identified by the|
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id     - identifies the rows to update  |
 |                    p_line_rec            - contains the new column values |
 |                    p_line_type         - value is used to restrict update |
 |                    p_currency_code         - transaction's currency code  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_line_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ct_id( p_line_rec IN ra_customer_trx_lines%rowtype,
                          p_customer_trx_id  IN
                                ra_customer_trx_lines.customer_trx_id%type,
                          p_line_type IN
                            ra_customer_trx_lines.line_type%type default null,
                          p_currency_code IN fnd_currencies.currency_code%type
                                             DEFAULT NULL)  IS

   l_where varchar2(500);
   l_currency_code fnd_currencies.currency_code%type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.update_f_ct_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));
   END IF;



  /*---------------------------------------------------------------+
   |  Get the transaction's currency code if it was not passed in  |
   +---------------------------------------------------------------*/

   IF (p_currency_code IS NULL)
   THEN
          SELECT ct.invoice_currency_code
          INTO   l_currency_code
          FROM   ra_customer_trx ct
          WHERE  ct.customer_trx_id = p_customer_trx_id;
   ELSE   l_currency_code := p_currency_code;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'using currency code: ' || l_currency_code );
   END IF;


   l_where := ' WHERE customer_trx_id = :where_1 ' ||
            'AND  line_type = nvl(:where_line_type, line_type)';

   arp_ctl_pkg.generic_update( pg_cursor2,
			       l_where,
                               p_customer_trx_id,
                               p_line_type,
                               l_currency_code,
                               p_line_rec);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.update_f_ct_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));
   END IF;


EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.update_f_ct_id()');
           arp_util.debug(  '');
           arp_util.debug(  '-------- parameters for update_f_ct_id() ------');
           arp_util.debug(  'p_customer_trx_id  = ' ||
                       p_customer_trx_id);
           arp_util.debug(  'p_line_type        = ' || p_line_type);
           arp_util.debug(  'p_currency_code    = ' || p_currency_code);
        END IF;
        display_line_rec(p_line_rec);

        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_amount_f_ctl_id                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the amounts in a record in ra_customer_trx_lines|
 |    The columns affected are: extended_amount, unit_selling_price,         |
 |    gross_extended_amount, and gross_unit_selling_price.                   |
 |    These are adjustments made for inclusive tax amounts.                  |
 |    This function is used when the amounts are gross of inclusive tax.     |
 |    Regular invoice lines should use this. Applied credit memo lines       |
 |    should use the function update_cm_amount_f_ctl_id.                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS : IN : p_customer_trx_line_id                                   |
 |                  p_inclusive_amt        --- Inclusive tax amount          |
 |             OUT: p_new_extended_amt     --- New net price                 |
 |                  p_new_unit_selling_price --- New unit selling price      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | HISTORY                                                                   |
 |    18-Aug-97   Kenichi Mizuta    Created.                                 |
 |    14-FEB-03   M Raymond         Bug 2772387 - preventing ORA-1476 errors
 |                                  when quantity invoiced is zero and
 |                                  tax compounding is in use.
 |    20-FEB-2003 NIPATEL           Bug 2772387 - Per PM inputs, will not
 |                                  adjutst Unit Selling Price when quantity is
 |                                  zero in update_amount_f_ctl_id
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_amount_f_ctl_id(
		p_customer_trx_line_id	IN Number,
		p_inclusive_amt		IN Number,
		p_new_extended_amt	OUT NOCOPY Number,
		p_new_unit_selling_price OUT NOCOPY Number,
		p_precision		IN Number,
		p_min_acct_unit		IN Number) IS
cursor c is select
	quantity_invoiced,
	quantity_credited,
	extended_amount,
	unit_selling_price,
	gross_extended_amount,
	gross_unit_selling_price,
	revenue_amount
		from
	ra_customer_trx_lines
		where
	customer_trx_line_id = p_customer_trx_line_id for update;
crow	c%rowtype;
l_extended_amount	ra_customer_trx_lines.extended_amount%type;
l_unit_selling_price	ra_customer_trx_lines.unit_selling_price%type;
l_gross_extended_amount		ra_customer_trx_lines.gross_extended_amount%type;
l_gross_unit_selling_price	ra_customer_trx_lines.gross_unit_selling_price%type;
l_revenue_amount	ra_customer_trx_lines.revenue_amount%type;
l_old_inclusive_amt	ra_customer_trx_lines.extended_amount%type;
l_qty                   ra_customer_trx_lines.quantity_invoiced%type;
begin
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  'arp_ctl_pkg.update_amount_f_ctl_id('
				|| to_char(p_customer_trx_line_id) || ','
				|| to_char(p_inclusive_amt)
				||')+');
	END IF;

	begin
		open c;
		fetch c into crow;

		-- On insert old inclusive should be 0, since gross amount should be null.
		l_old_inclusive_amt := nvl(crow.gross_extended_amount, crow.extended_amount) - crow.extended_amount;
                l_extended_amount := nvl(crow.gross_extended_amount, crow.extended_amount) - p_inclusive_amt;

               /*  Bugfix 2772387: do not adjust the unit selling proce when quantity is zero */

                l_qty := nvl(crow.quantity_invoiced, crow.quantity_credited);

                if (l_qty = 0 OR l_qty is NULL)then

                  l_unit_selling_price := crow.unit_selling_price;

                elsif (p_min_acct_unit is NULL) then
                  l_unit_selling_price :=
                                round(l_extended_amount/
                                        l_qty,
                                        p_precision+2);
                else
                  l_unit_selling_price :=
                                round(l_extended_amount/
                                        l_qty
                                        /p_min_acct_unit/100)
                                        *100*p_min_acct_unit;
                end if;


		l_gross_extended_amount :=
			nvl(crow.gross_extended_amount, crow.extended_amount);
		l_gross_unit_selling_price :=
			nvl(crow.gross_unit_selling_price, crow.unit_selling_price);
		l_revenue_amount := crow.revenue_amount +
                   l_old_inclusive_amt - p_inclusive_amt;

                /* 5487466 - if inclusive tax to be removed, clear
                   gross_ columns */
                IF (p_inclusive_amt = 0)
                THEN
                   l_gross_extended_amount := NULL;
                   l_gross_unit_selling_price := NULL;
                END IF;

		update ra_customer_trx_lines
			set
		extended_amount = l_extended_amount,
		unit_selling_price = l_unit_selling_price,
		gross_extended_amount = l_gross_extended_amount,
		gross_unit_selling_price = l_gross_unit_selling_price,
		revenue_amount = l_revenue_amount
			where current of c;


		close c;
	end;

	p_new_extended_amt := l_extended_amount;
	p_new_unit_selling_price := l_unit_selling_price;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  'arp_ctl_pkg.update_amount_f_ctl_id('
				|| to_char(l_extended_amount) || ','
				|| to_char(l_unit_selling_price)
				||')-');
	END IF;
exception
when others then
  if c%isopen then
    close c;
  end if;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug(  'arp_ctl_pkg.update_amount_f_ctl_id(EXCEPTION)-');
  END IF;
  raise;
end update_amount_f_ctl_id;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_cm_amount_f_ctl_id                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the amounts in a record in ra_customer_trx_lines|
 |    The columns affected are: extended_amount, unit_selling_price,         |
 |    gross_extended_amount, and gross_unit_selling_price.                   |
 |    These are adjustments made for inclusive tax amounts.                  |
 |    This function is used when the amounts are net of inclusive tax.       |
 |    Applied credit memo lines - use this function.                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS : IN : p_customer_trx_line_id                                   |
 |                  p_inclusive_amt        --- Inclusive tax amount          |
 |             OUT: p_new_gross_extended_amt     --- New gross price         |
 |                  p_new_gross_unit_selling_price --- New gross selling pric|
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | HISTORY                                                                   |
 |    18-Aug-97   Kenichi Mizuta    Created.                                 |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_cm_amount_f_ctl_id(
	p_customer_trx_line_id IN Number,
	p_inclusive_amount IN Number,
	p_new_gross_extended_amount OUT NOCOPY Number,
	p_new_gross_unit_selling_price OUT NOCOPY Number,
	p_precision IN Number,
	p_min_acct_unit IN Number) IS
cursor c is select
	cm.quantity_credited quantity_credited,
	cm.quantity_invoiced quantity_invoiced,
	cm.extended_amount extended_amount,
	cm.unit_selling_price unit_selling_price,
	cm.gross_extended_amount gross_extended_amount,
	cm.gross_unit_selling_price gross_unit_selling_price,
	cm.previous_customer_trx_line_id previous_customer_trx_line_id
		from
	ra_customer_trx_lines cm
		where
	customer_trx_line_id = p_customer_trx_line_id for update;
cursor cinv(p_line_id IN number) is select
	inv.gross_unit_selling_price gross_unit_selling_price
		from
	ra_customer_trx_lines inv
		where
	customer_trx_line_id = p_line_id;

crow	c%rowtype;
l_extended_amount	ra_customer_trx_lines.extended_amount%type;
l_unit_selling_price	ra_customer_trx_lines.unit_selling_price%type;
l_gross_extended_amount		ra_customer_trx_lines.gross_extended_amount%type;
l_gross_unit_selling_price	ra_customer_trx_lines.gross_unit_selling_price%type;
l_revenue_amount	ra_customer_trx_lines.revenue_amount%type;
l_old_inclusive_amt	ra_customer_trx_lines.extended_amount%type;
begin
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id('
				|| to_char(p_customer_trx_line_id) || ','
				|| to_char(p_inclusive_amount)
				||')+');
	END IF;

	begin
		open c;
		fetch c into crow;

		l_extended_amount := crow.extended_amount;
		if ( p_inclusive_amount is null ) OR
                   ( p_inclusive_amount = 0 )
                then
		  IF PG_DEBUG in ('Y', 'C') THEN
		     arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id: '||
				'No Inclusive Tax Amounts');
		  END IF;

		  l_gross_extended_amount := null;
		  l_gross_unit_selling_price := null;
		else
		  IF PG_DEBUG in ('Y', 'C') THEN
		     arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id: '||
				'Inclusive Amount = '||to_char(p_inclusive_amount));
		     arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id: '||
				'Quantity = '||nvl(to_char(crow.quantity_credited), 'NULL'));
		     arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id: '||
				'Precision = '||nvl(to_char(p_precision), 'NULL'));
		     arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id: '||
				'MAU = '||nvl(to_char(p_min_acct_unit), 'NULL'));
		  END IF;

		  l_gross_extended_amount := crow.extended_amount + p_inclusive_amount;
		  if ( crow.quantity_credited = 0 ) then
		  begin
			open cinv(crow.previous_customer_trx_line_id);
			fetch cinv into l_gross_unit_selling_price;
			close cinv;
		  exception
		  when others then
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug(  'EXCPETION: Unable to fetch original invoice');
			END IF;
			raise;
		  end;
		  elsif ( crow.unit_selling_price is null ) then
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id: NO unit selling price');
			END IF;
			l_gross_unit_selling_price := null;
		  elsif (p_min_acct_unit is null) then
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id: Rounding to precision');
			END IF;
			l_gross_unit_selling_price :=
				round(l_gross_extended_amount / crow.quantity_credited, p_precision+2);
		  else
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id: Rounding to MAU');
			END IF;
			l_gross_unit_selling_price :=
				round(l_gross_extended_amount / crow.quantity_credited / p_min_acct_unit / 100)
					* 100 * p_min_acct_unit;
		  end if;
		end if;

		update ra_customer_trx_lines
			set
		gross_extended_amount = l_gross_extended_amount,
		gross_unit_selling_price = l_gross_unit_selling_price
			where current of c;

		close c;
	end;

	p_new_gross_extended_amount := l_gross_extended_amount;
	p_new_gross_unit_selling_price := l_gross_unit_selling_price;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id('
				|| to_char(l_gross_extended_amount) || ','
				|| to_char(l_gross_unit_selling_price)
				||')-');
	END IF;

exception
when others then
  if c%isopen then
    close c;
  end if;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug(  'arp_ctl_pkg.update_cm_amount_f_ctl_id(EXCEPTION)-');
  END IF;
  raise;
end update_cm_amount_f_ctl_id;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ra_customer_trx_lines that contains  |
 |    the column values specified in the p_trx_rec parameter. 		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_global.set_of_books_id					     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_line_rec            - contains the new column values |
 |              OUT:                                                         |
 |                    p_customer_trx_line_id    - unique ID of the new row   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |     Rel. 11 Changes:							     |
 |     ----------------							     |
 |     07-22-97   OSTEINME		added code to handle three new       |
 |					database columns:                    |
 |					  - gross_unit_selling_price         |
 |					  - gross_extended_amount            |
 |					  - amount_includes_tax_flag         |
 |                                                                           |
 |     08-20-97   KTANG                 handle global_attribute_category and |
 |                                      global_attribute[1-20] for global    |
 |                                      descriptive flexfield                |
 |                                                                           |
 |                                                                           |
 |     10-JAN-99 Saloni Shah            added warehouse_id for global tax    |
 |                                      engine change                        |
 |     17-MAR-99 Debbie Jancis          added translated description for     |
 |                                      MLS changes                          |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              EXTENDED_ACCTD_AMOUNT,BR_REF_CUSTOMER_TRX_ID,|
 |                              BR_REF_PAYMENT_SCHEDULE_ID, BR_ADJUSTMENT_ID |
 |                              into table handlers                          |
 |									     |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added column wh_update_date    |
 | 					      into the table handlers. 	     |
 | 07-Apr-2005 Debbie Sue Jancis ETAX:  Added SHIP_TO Id columns to support  |
 |                               ship to at the line level. Also added       |
 |                               tax_Code                                    |
 | 23-Dec-2005 Gyanajyothi      Added Rule End date for Daily Rate Rule types
 |                              commented the changes for Bug 4410461
 +===========================================================================*/

PROCEDURE insert_p(
                    p_line_rec              IN  ra_customer_trx_lines%rowtype,
                    p_customer_trx_line_id OUT NOCOPY
                               ra_customer_trx_lines.customer_trx_line_id%type
                  ) IS


    l_customer_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%type;
    l_revenue_amount        ra_customer_trx_lines.revenue_amount%TYPE;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.insert_p()+');
    END IF;

    p_customer_trx_line_id := '';

    /*---------------------------*
     | Get the unique identifier |
     *---------------------------*/
	/* Bug 4410461 FP for 4340099: Added the If Condition below */
        IF p_line_rec.customer_trx_line_id is null THEN
        SELECT RA_CUSTOMER_TRX_LINES_S.NEXTVAL
        INTO   l_customer_trx_line_id
        FROM   DUAL;
        ELSE   l_customer_trx_line_id := p_line_rec.customer_trx_line_id ;
        END IF ;


    /*-------------------*
     | Insert the record |
     *-------------------*/


   l_revenue_amount := p_line_rec.revenue_amount;
   IF p_line_rec.revenue_amount is NULL
   THEN
      IF p_line_rec.line_type not in ( 'CHARGES', 'TAX' )
      THEN
         l_revenue_amount := p_line_rec.extended_amount;
      END IF;
   END IF;


   INSERT INTO ra_customer_trx_lines
    (
      customer_trx_line_id,
      customer_trx_id,
      line_number,
      line_type,
      quantity_credited,
      quantity_invoiced,
      quantity_ordered,
      unit_selling_price,
      unit_standard_price,
      revenue_amount,
      extended_amount,
      memo_line_id,
      inventory_item_id,
      item_exception_rate_id,
      description,
      item_context,
      initial_customer_trx_line_id,
      link_to_cust_trx_line_id,
      previous_customer_trx_id,
      previous_customer_trx_line_id,
      accounting_rule_duration,
      accounting_rule_id,
      rule_start_date,
      autorule_complete_flag,
      autorule_duration_processed,
      reason_code,
      last_period_to_credit,
      sales_order,
      sales_order_date,
      sales_order_line,
      sales_order_revision,
      sales_order_source,
      vat_tax_id,
      tax_exempt_flag,
      sales_tax_id,
      location_segment_id,
      tax_exempt_number,
      tax_exempt_reason_code,
      tax_vendor_return_code,
      taxable_flag,
      tax_exemption_id,
      tax_precedence,
      tax_rate,
      uom_code,
      autotax,
      movement_id,
      default_ussgl_transaction_code,
      default_ussgl_trx_code_context,
      interface_line_context,
      interface_line_attribute1,
      interface_line_attribute2,
      interface_line_attribute3,
      interface_line_attribute4,
      interface_line_attribute5,
      interface_line_attribute6,
      interface_line_attribute7,
      interface_line_attribute8,
      interface_line_attribute9,
      interface_line_attribute10,
      interface_line_attribute11,
      interface_line_attribute12,
      interface_line_attribute13,
      interface_line_attribute14,
      interface_line_attribute15,
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
      global_attribute_category,
      global_attribute1,
      global_attribute2,
      global_attribute3,
      global_attribute4,
      global_attribute5,
      global_attribute6,
      global_attribute7,
      global_attribute8,
      global_attribute9,
      global_attribute10,
      global_attribute11,
      global_attribute12,
      global_attribute13,
      global_attribute14,
      global_attribute15,
      global_attribute16,
      global_attribute17,
      global_attribute18,
      global_attribute19,
      global_attribute20,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      program_application_id,
      last_update_login,
      program_id,
      program_update_date,
      set_of_books_id,
      gross_unit_selling_price,
      gross_extended_amount,
      amount_includes_tax_flag,
      warehouse_id,
      translated_description,
      taxable_amount, /* Bug 853757 */
      request_id,
      extended_acctd_amount,
      br_ref_customer_trx_id,
      br_ref_payment_schedule_id,
      br_adjustment_id,
      wh_update_date,
      payment_set_id,
      org_id,
      ship_to_customer_id,
      ship_to_site_use_id,
      ship_to_contact_id,
      tax_classification_code,
      historical_flag,
      rule_end_date
    )
   VALUES
    (
      l_customer_trx_line_id,
      p_line_rec.customer_trx_id,
      p_line_rec.line_number,
      p_line_rec.line_type,
      p_line_rec.quantity_credited,
      p_line_rec.quantity_invoiced,
      p_line_rec.quantity_ordered,
      p_line_rec.unit_selling_price,
      p_line_rec.unit_standard_price,
      l_revenue_amount,
      p_line_rec.extended_amount,
      p_line_rec.memo_line_id,
      p_line_rec.inventory_item_id,
      p_line_rec.item_exception_rate_id,
      p_line_rec.description,
      p_line_rec.item_context,
      p_line_rec.initial_customer_trx_line_id,
      p_line_rec.link_to_cust_trx_line_id,
      p_line_rec.previous_customer_trx_id,
      p_line_rec.previous_customer_trx_line_id,
      p_line_rec.accounting_rule_duration,
      p_line_rec.accounting_rule_id,
      p_line_rec.rule_start_date,
      p_line_rec.autorule_complete_flag,
      p_line_rec.autorule_duration_processed,
      p_line_rec.reason_code,
      p_line_rec.last_period_to_credit,
      p_line_rec.sales_order,
      p_line_rec.sales_order_date,
      p_line_rec.sales_order_line,
      p_line_rec.sales_order_revision,
      p_line_rec.sales_order_source,
      p_line_rec.vat_tax_id,
      p_line_rec.tax_exempt_flag,
      p_line_rec.sales_tax_id,
      p_line_rec.location_segment_id,
      p_line_rec.tax_exempt_number,
      p_line_rec.tax_exempt_reason_code,
      p_line_rec.tax_vendor_return_code,
      p_line_rec.taxable_flag,
      p_line_rec.tax_exemption_id,
      p_line_rec.tax_precedence,
      p_line_rec.tax_rate,
      p_line_rec.uom_code,
      p_line_rec.autotax,
      p_line_rec.movement_id,
      p_line_rec.default_ussgl_transaction_code,
      p_line_rec.default_ussgl_trx_code_context,
      p_line_rec.interface_line_context,
      p_line_rec.interface_line_attribute1,
      p_line_rec.interface_line_attribute2,
      p_line_rec.interface_line_attribute3,
      p_line_rec.interface_line_attribute4,
      p_line_rec.interface_line_attribute5,
      p_line_rec.interface_line_attribute6,
      p_line_rec.interface_line_attribute7,
      p_line_rec.interface_line_attribute8,
      p_line_rec.interface_line_attribute9,
      p_line_rec.interface_line_attribute10,
      p_line_rec.interface_line_attribute11,
      p_line_rec.interface_line_attribute12,
      p_line_rec.interface_line_attribute13,
      p_line_rec.interface_line_attribute14,
      p_line_rec.interface_line_attribute15,
      p_line_rec.attribute_category,
      p_line_rec.attribute1,
      p_line_rec.attribute2,
      p_line_rec.attribute3,
      p_line_rec.attribute4,
      p_line_rec.attribute5,
      p_line_rec.attribute6,
      p_line_rec.attribute7,
      p_line_rec.attribute8,
      p_line_rec.attribute9,
      p_line_rec.attribute10,
      p_line_rec.attribute11,
      p_line_rec.attribute12,
      p_line_rec.attribute13,
      p_line_rec.attribute14,
      p_line_rec.attribute15,
      p_line_rec.global_attribute_category,
      p_line_rec.global_attribute1,
      p_line_rec.global_attribute2,
      p_line_rec.global_attribute3,
      p_line_rec.global_attribute4,
      p_line_rec.global_attribute5,
      p_line_rec.global_attribute6,
      p_line_rec.global_attribute7,
      p_line_rec.global_attribute8,
      p_line_rec.global_attribute9,
      p_line_rec.global_attribute10,
      p_line_rec.global_attribute11,
      p_line_rec.global_attribute12,
      p_line_rec.global_attribute13,
      p_line_rec.global_attribute14,
      p_line_rec.global_attribute15,
      p_line_rec.global_attribute16,
      p_line_rec.global_attribute17,
      p_line_rec.global_attribute18,
      p_line_rec.global_attribute19,
      p_line_rec.global_attribute20,
      pg_user_id,			/* created_by */
      sysdate,                          /* creation_date */
      pg_user_id,			/* last_updated_by */
      sysdate,				/* last_update_date */
      pg_prog_appl_id,			/* program_application_id */
      nvl(pg_conc_login_id,
          pg_login_id),			/* last_update_login */
      pg_conc_program_id,		/* program_id */
      sysdate,				/* program_update_date */
      arp_global.set_of_books_id,	/* set_of_books_id */
      p_line_rec.gross_unit_selling_price,
      p_line_rec.gross_extended_amount,
      p_line_rec.amount_includes_tax_flag,
      p_line_rec.warehouse_id,
      p_line_rec.translated_description,
      p_line_rec.taxable_amount,
      p_line_rec.request_id,
      p_line_rec.extended_acctd_amount,
      p_line_rec.br_ref_customer_trx_id,
      p_line_rec.br_ref_payment_schedule_id,
      p_line_rec.br_adjustment_id,
      p_line_rec.wh_update_date,
      p_line_rec.payment_set_id,
      arp_standard.sysparm.org_id, /* SSA changes */
      p_line_rec.ship_to_customer_id,
      p_line_rec.ship_to_site_use_id,
      p_line_rec.ship_to_contact_id,
      p_line_rec.tax_classification_code,
      nvl(p_line_rec.historical_flag, 'N'),
      p_line_rec.rule_end_date
    );

   p_customer_trx_line_id          := l_customer_trx_line_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'after insert: amount_includes_tax_flag = ' ||
                     p_line_rec.amount_includes_tax_flag);
       arp_util.debug(  'after insert: gross_extended_amount = ' ||
                     p_line_rec.gross_extended_amount);
       arp_util.debug(  'after insert: gross_unit_selling_price = ' ||
                     p_line_rec.gross_unit_selling_price);
      arp_util.debug(  'arp_ctl_pkg.insert_p()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.insert_p()');
           arp_util.debug(  '');
           arp_util.debug(  '-------- parameters for insert_p() ------');
        END IF;
        display_line_rec(p_line_rec);

	RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_line_rec                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and            |
 |    last_update_date.                                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_line_rec                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Subash C            Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE display_line_rec(
            p_line_rec IN ra_customer_trx_lines%rowtype) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.display_line_rec()+');
   END IF;

   arp_ctl_private_pkg.display_line_rec(p_line_rec);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.display_line_rec()-');
   END IF;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_line_p                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and            |
 |    last_update_date.                                                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_customer_trx_line_id                              |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Subash C            Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE display_line_p(
            p_customer_trx_line_id IN
                   ra_customer_trx_lines.customer_trx_line_id%type) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.display_line_p()+');
   END IF;

   arp_ctl_private_pkg.display_line_p(p_customer_trx_line_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.display_line_p()-');
   END IF;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_line_f_lctl_id						     |
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
 |		      p_link_to_cust_trx_line_id			     |
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
 |     03-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_line_f_lctl_id(  p_link_to_cust_trx_line_id IN
                         ra_customer_trx_lines.link_to_cust_trx_line_id%type)
                   IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.display_line_f_lctl_id()+');
   END IF;

   arp_ctl_private_pkg.display_line_f_lctl_id( p_link_to_cust_trx_line_id );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.display_line_f_lctl_id()-');
   END IF;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_line_f_ct_id						     |
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
 |     08-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_line_f_ct_id(  p_customer_trx_id IN
                                        ra_customer_trx.customer_trx_id%type )
                   IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.display_line_f_ct_id()+');
   END IF;

   arp_ctl_private_pkg.display_line_f_ct_id( p_customer_trx_id );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_ctl_pkg.display_line_f_ct_id()-');
   END IF;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    merge_line_recs							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Merges the changed columns in p_new_line_rec into the same columns     |
 |    p_old_line_rec and puts the result into p_out_line_rec. Columns that   |
 |    contain the dummy values are not changed.				     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_old_line_rec 					     |
 |		      p_new_line_rec 					     |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |		      p_out_line_rec 					     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |     Rel. 11 Changes:							     |
 |     ----------------							     |
 |     07-22-97   OSTEINME		added code to handle three new       |
 |					database columns:                    |
 |					  - gross_unit_selling_price         |
 |					  - gross_extended_amount            |
 |					  - amount_includes_tax_flag         |
 |                                                                           |
 |     08-20-97   KTANG                 handle global_attribute_category and |
 |                                      global_attribute[1-20] for global    |
 |                                      descriptive flexfield                |
 |                                                                           |
 |     10-JAN-99  Saloni Shah           added code for warehouse_id          |
 |                                      for global tax engine change         |
 |                                                                           |
 |     22-MAR-99  Debbie Jancis         added translated_description for MLS |
 |                                                                           |
 |     20-MAR-2000  J Rautiainen        Added BR project related columns     |
 |                                      EXTENDED_ACCTD_AMOUNT,               |
 |                                      BR_REF_CUSTOMER_TRX_ID,              |
 |                                      BR_REF_PAYMENT_SCHEDULE_ID and       |
 |                                      BR_ADJUSTMENT_ID                     |
 |                                      into table handlers                  |
 |									     |
 |    31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added column           |
 |                                      wh_update_date into the table        |
 | 				        handlers. 	                     |
 |    20-APR-2005 Debbie Jancis         ETax:  added ship to id columns to   |
 |                                      support ship to at the line level    |
 +===========================================================================*/

PROCEDURE merge_line_recs(
                         p_old_line_rec IN ra_customer_trx_lines%rowtype,
                         p_new_line_rec IN
                                          ra_customer_trx_lines%rowtype,
                         p_out_line_rec IN OUT NOCOPY
                                          ra_customer_trx_lines%rowtype)
                          IS

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.merge_line_recs()+');
    END IF;

    IF     (p_new_line_rec.customer_trx_line_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.customer_trx_line_id :=
                                          p_old_line_rec.customer_trx_line_id;
    ELSE   p_out_line_rec.customer_trx_line_id :=
                                          p_new_line_rec.customer_trx_line_id;
    END IF;

    IF     (p_new_line_rec.customer_trx_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.customer_trx_id := p_old_line_rec.customer_trx_id;
    ELSE   p_out_line_rec.customer_trx_id := p_new_line_rec.customer_trx_id;
    END IF;

    IF     (p_new_line_rec.line_number = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.line_number := p_old_line_rec.line_number;
    ELSE   p_out_line_rec.line_number := p_new_line_rec.line_number;
    END IF;

    IF     (p_new_line_rec.line_type = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.line_type := p_old_line_rec.line_type;
    ELSE   p_out_line_rec.line_type := p_new_line_rec.line_type;
    END IF;

    IF     (p_new_line_rec.quantity_credited = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.quantity_credited :=
                                            p_old_line_rec.quantity_credited;
    ELSE   p_out_line_rec.quantity_credited :=
                                            p_new_line_rec.quantity_credited;
    END IF;

    IF     (p_new_line_rec.quantity_invoiced = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.quantity_invoiced :=
                                            p_old_line_rec.quantity_invoiced;
    ELSE   p_out_line_rec.quantity_invoiced :=
                                            p_new_line_rec.quantity_invoiced;
    END IF;

    IF     (p_new_line_rec.quantity_ordered = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.quantity_ordered := p_old_line_rec.quantity_ordered;
    ELSE   p_out_line_rec.quantity_ordered := p_new_line_rec.quantity_ordered;
    END IF;

    IF     (p_new_line_rec.unit_selling_price = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.unit_selling_price :=
                                             p_old_line_rec.unit_selling_price;
    ELSE   p_out_line_rec.unit_selling_price :=
                                             p_new_line_rec.unit_selling_price;
    END IF;

    IF     (p_new_line_rec.unit_standard_price = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.unit_standard_price :=
                                            p_old_line_rec.unit_standard_price;
    ELSE   p_out_line_rec.unit_standard_price :=
                                            p_new_line_rec.unit_standard_price;
    END IF;

    IF     (p_new_line_rec.revenue_amount = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.revenue_amount := p_old_line_rec.revenue_amount;
    ELSE   p_out_line_rec.revenue_amount := p_new_line_rec.revenue_amount;
    END IF;

    IF     (p_new_line_rec.extended_amount = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.extended_amount := p_old_line_rec.extended_amount;
    ELSE   p_out_line_rec.extended_amount := p_new_line_rec.extended_amount;
    END IF;

    IF     (p_new_line_rec.memo_line_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.memo_line_id := p_old_line_rec.memo_line_id;
    ELSE   p_out_line_rec.memo_line_id := p_new_line_rec.memo_line_id;
    END IF;

    IF     (p_new_line_rec.inventory_item_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.inventory_item_id :=
                                            p_old_line_rec.inventory_item_id;
    ELSE   p_out_line_rec.inventory_item_id :=
                                            p_new_line_rec.inventory_item_id;
    END IF;

    IF     (p_new_line_rec.item_exception_rate_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.item_exception_rate_id :=
                                         p_old_line_rec.item_exception_rate_id;
    ELSE   p_out_line_rec.item_exception_rate_id :=
                                         p_new_line_rec.item_exception_rate_id;
    END IF;

    IF     (p_new_line_rec.description = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.description := p_old_line_rec.description;
    ELSE   p_out_line_rec.description := p_new_line_rec.description;
    END IF;

    IF     (p_new_line_rec.item_context = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.item_context := p_old_line_rec.item_context;
    ELSE   p_out_line_rec.item_context := p_new_line_rec.item_context;
    END IF;

    IF     (p_new_line_rec.initial_customer_trx_line_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.initial_customer_trx_line_id :=
                                   p_old_line_rec.initial_customer_trx_line_id;
    ELSE   p_out_line_rec.initial_customer_trx_line_id :=
                                   p_new_line_rec.initial_customer_trx_line_id;
    END IF;

    IF     (p_new_line_rec.link_to_cust_trx_line_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.link_to_cust_trx_line_id :=
                                   p_old_line_rec.link_to_cust_trx_line_id;
    ELSE   p_out_line_rec.link_to_cust_trx_line_id :=
                                   p_new_line_rec.link_to_cust_trx_line_id;
    END IF;

    IF     (p_new_line_rec.previous_customer_trx_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.previous_customer_trx_id :=
                                   p_old_line_rec.previous_customer_trx_id;
    ELSE   p_out_line_rec.previous_customer_trx_id :=
                                   p_new_line_rec.previous_customer_trx_id;
    END IF;

    IF     (p_new_line_rec.previous_customer_trx_line_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.previous_customer_trx_line_id :=
                                  p_old_line_rec.previous_customer_trx_line_id;
    ELSE   p_out_line_rec.previous_customer_trx_line_id :=
                                  p_new_line_rec.previous_customer_trx_line_id;
    END IF;

    IF     (p_new_line_rec.accounting_rule_duration = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.accounting_rule_duration :=
                                  p_old_line_rec.accounting_rule_duration;
    ELSE   p_out_line_rec.accounting_rule_duration :=
                                  p_new_line_rec.accounting_rule_duration;
    END IF;

    IF     (p_new_line_rec.accounting_rule_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.accounting_rule_id :=
                                  p_old_line_rec.accounting_rule_id;
    ELSE   p_out_line_rec.accounting_rule_id :=
                                  p_new_line_rec.accounting_rule_id;
    END IF;

    IF     (p_new_line_rec.rule_start_date = AR_DATE_DUMMY)
    THEN   p_out_line_rec.rule_start_date := p_old_line_rec.rule_start_date;
    ELSE   p_out_line_rec.rule_start_date := p_new_line_rec.rule_start_date;
    END IF;

    IF     (p_new_line_rec.autorule_complete_flag = AR_FLAG_DUMMY)
    THEN   p_out_line_rec.autorule_complete_flag :=
                                        p_old_line_rec.autorule_complete_flag;
    ELSE   p_out_line_rec.autorule_complete_flag :=
                                        p_new_line_rec.autorule_complete_flag;
    END IF;

    IF     (p_new_line_rec.autorule_duration_processed = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.autorule_duration_processed :=
                                   p_old_line_rec.autorule_duration_processed;
    ELSE   p_out_line_rec.autorule_duration_processed :=
                                   p_new_line_rec.autorule_duration_processed;
    END IF;

    IF     (p_new_line_rec.reason_code = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.reason_code := p_old_line_rec.reason_code;
    ELSE   p_out_line_rec.reason_code := p_new_line_rec.reason_code;
    END IF;

    IF     (p_new_line_rec.last_period_to_credit = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.last_period_to_credit :=
                                          p_old_line_rec.last_period_to_credit;
    ELSE   p_out_line_rec.last_period_to_credit :=
                                          p_new_line_rec.last_period_to_credit;
    END IF;

    IF     (p_new_line_rec.warehouse_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.warehouse_id :=
                                          p_old_line_rec.warehouse_id;
    ELSE   p_out_line_rec.warehouse_id :=
                                          p_new_line_rec.warehouse_id;
    END IF;

    IF     (p_new_line_rec.translated_description= AR_TEXT_DUMMY)
    THEN   p_out_line_rec.translated_description :=
                                          p_old_line_rec.translated_description;
    ELSE   p_out_line_rec.translated_description :=
                                          p_new_line_rec.translated_description;
    END IF;

    IF     (p_new_line_rec.sales_order = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.sales_order := p_old_line_rec.sales_order;
    ELSE   p_out_line_rec.sales_order := p_new_line_rec.sales_order;
    END IF;

    IF     (p_new_line_rec.sales_order_date = AR_DATE_DUMMY)
    THEN   p_out_line_rec.sales_order_date := p_old_line_rec.sales_order_date;
    ELSE   p_out_line_rec.sales_order_date := p_new_line_rec.sales_order_date;
    END IF;

    IF     (p_new_line_rec.sales_order_line = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.sales_order_line := p_old_line_rec.sales_order_line;
    ELSE   p_out_line_rec.sales_order_line := p_new_line_rec.sales_order_line;
    END IF;

    IF     (p_new_line_rec.sales_order_revision = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.sales_order_revision :=
                                           p_old_line_rec.sales_order_revision;
    ELSE   p_out_line_rec.sales_order_revision :=
                                           p_new_line_rec.sales_order_revision;
    END IF;

    IF     (p_new_line_rec.sales_order_source = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.sales_order_source :=
                                             p_old_line_rec.sales_order_source;
    ELSE   p_out_line_rec.sales_order_source :=
                                             p_new_line_rec.sales_order_source;
    END IF;

    IF     (p_new_line_rec.vat_tax_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.vat_tax_id := p_old_line_rec.vat_tax_id;
    ELSE   p_out_line_rec.vat_tax_id := p_new_line_rec.vat_tax_id;
    END IF;

    IF     (p_new_line_rec.tax_exempt_flag = AR_FLAG_DUMMY)
    THEN   p_out_line_rec.tax_exempt_flag := p_old_line_rec.tax_exempt_flag;
    ELSE   p_out_line_rec.tax_exempt_flag := p_new_line_rec.tax_exempt_flag;
    END IF;

    IF     (p_new_line_rec.sales_tax_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.sales_tax_id := p_old_line_rec.sales_tax_id;
    ELSE   p_out_line_rec.sales_tax_id := p_new_line_rec.sales_tax_id;
    END IF;

    IF     (p_new_line_rec.location_segment_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.location_segment_id :=
                                            p_old_line_rec.location_segment_id;
    ELSE   p_out_line_rec.location_segment_id :=
                                            p_new_line_rec.location_segment_id;
    END IF;

    IF     (p_new_line_rec.tax_exempt_number = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.tax_exempt_number :=
                                             p_old_line_rec.tax_exempt_number;
    ELSE   p_out_line_rec.tax_exempt_number :=
                                             p_new_line_rec.tax_exempt_number;
    END IF;

    IF     (p_new_line_rec.tax_exempt_reason_code = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.tax_exempt_reason_code :=
                                         p_old_line_rec.tax_exempt_reason_code;
    ELSE   p_out_line_rec.tax_exempt_reason_code :=
                                         p_new_line_rec.tax_exempt_reason_code;
    END IF;

    IF     (p_new_line_rec.tax_vendor_return_code = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.tax_vendor_return_code :=
                                        p_old_line_rec.tax_vendor_return_code;
    ELSE   p_out_line_rec.tax_vendor_return_code :=
                                        p_new_line_rec.tax_vendor_return_code;
    END IF;

    IF     (p_new_line_rec.taxable_flag = AR_FLAG_DUMMY)
    THEN   p_out_line_rec.taxable_flag := p_old_line_rec.taxable_flag;
    ELSE   p_out_line_rec.taxable_flag := p_new_line_rec.taxable_flag;
    END IF;

    IF     (p_new_line_rec.tax_exemption_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.tax_exemption_id := p_old_line_rec.tax_exemption_id;
    ELSE   p_out_line_rec.tax_exemption_id := p_new_line_rec.tax_exemption_id;
    END IF;

    IF     (p_new_line_rec.tax_precedence = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.tax_precedence := p_old_line_rec.tax_precedence;
    ELSE   p_out_line_rec.tax_precedence := p_new_line_rec.tax_precedence;
    END IF;

    IF     (p_new_line_rec.tax_rate = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.tax_rate := p_old_line_rec.tax_rate;
    ELSE   p_out_line_rec.tax_rate := p_new_line_rec.tax_rate;
    END IF;

    IF     (p_new_line_rec.uom_code = AR_TEXT3_DUMMY)
    THEN   p_out_line_rec.uom_code := p_old_line_rec.uom_code;
    ELSE   p_out_line_rec.uom_code := p_new_line_rec.uom_code;
    END IF;

    IF     (p_new_line_rec.autotax = AR_FLAG_DUMMY)
    THEN   p_out_line_rec.autotax := p_old_line_rec.autotax;
    ELSE   p_out_line_rec.autotax := p_new_line_rec.autotax;
    END IF;

    IF     (p_new_line_rec.movement_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.movement_id := p_old_line_rec.movement_id;
    ELSE   p_out_line_rec.movement_id := p_new_line_rec.movement_id;
    END IF;

    IF     (p_new_line_rec.default_ussgl_transaction_code = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.default_ussgl_transaction_code :=
                                p_old_line_rec.default_ussgl_transaction_code;
    ELSE   p_out_line_rec.default_ussgl_transaction_code :=
                                p_new_line_rec.default_ussgl_transaction_code;
    END IF;

    IF     (p_new_line_rec.default_ussgl_trx_code_context = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.default_ussgl_trx_code_context :=
                       p_old_line_rec.default_ussgl_trx_code_context;
    ELSE   p_out_line_rec.default_ussgl_trx_code_context :=
                       p_new_line_rec.default_ussgl_trx_code_context;
    END IF;

    IF     (p_new_line_rec.interface_line_context = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_context :=
                       p_old_line_rec.interface_line_context;
    ELSE   p_out_line_rec.interface_line_context :=
                       p_new_line_rec.interface_line_context;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute1 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute1 :=
                       p_old_line_rec.interface_line_attribute1;
    ELSE   p_out_line_rec.interface_line_attribute1 :=
                       p_new_line_rec.interface_line_attribute1;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute2 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute2 :=
                       p_old_line_rec.interface_line_attribute2;
    ELSE   p_out_line_rec.interface_line_attribute2 :=
                       p_new_line_rec.interface_line_attribute2;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute3 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute3 :=
                       p_old_line_rec.interface_line_attribute3;
    ELSE   p_out_line_rec.interface_line_attribute3 :=
                       p_new_line_rec.interface_line_attribute3;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute4 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute4 :=
                       p_old_line_rec.interface_line_attribute4;
    ELSE   p_out_line_rec.interface_line_attribute4 :=
                       p_new_line_rec.interface_line_attribute4;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute5 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute5 :=
                       p_old_line_rec.interface_line_attribute5;
    ELSE   p_out_line_rec.interface_line_attribute5 :=
                       p_new_line_rec.interface_line_attribute5;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute6 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute6 :=
                       p_old_line_rec.interface_line_attribute6;
    ELSE   p_out_line_rec.interface_line_attribute6 :=
                       p_new_line_rec.interface_line_attribute6;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute7 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute7 :=
                       p_old_line_rec.interface_line_attribute7;
    ELSE   p_out_line_rec.interface_line_attribute7 :=
                       p_new_line_rec.interface_line_attribute7;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute8 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute8 :=
                       p_old_line_rec.interface_line_attribute8;
    ELSE   p_out_line_rec.interface_line_attribute8 :=
                       p_new_line_rec.interface_line_attribute8;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute9 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute9 :=
                       p_old_line_rec.interface_line_attribute9;
    ELSE   p_out_line_rec.interface_line_attribute9 :=
                       p_new_line_rec.interface_line_attribute9;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute10 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute10 :=
                       p_old_line_rec.interface_line_attribute10;
    ELSE   p_out_line_rec.interface_line_attribute10 :=
                       p_new_line_rec.interface_line_attribute10;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute11 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute11 :=
                       p_old_line_rec.interface_line_attribute11;
    ELSE   p_out_line_rec.interface_line_attribute11 :=
                       p_new_line_rec.interface_line_attribute11;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute12 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute12 :=
                       p_old_line_rec.interface_line_attribute12;
    ELSE   p_out_line_rec.interface_line_attribute12 :=
                       p_new_line_rec.interface_line_attribute12;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute13 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute13 :=
                       p_old_line_rec.interface_line_attribute13;
    ELSE   p_out_line_rec.interface_line_attribute13 :=
                       p_new_line_rec.interface_line_attribute13;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute14 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute14 :=
                       p_old_line_rec.interface_line_attribute14;
    ELSE   p_out_line_rec.interface_line_attribute14 :=
                       p_new_line_rec.interface_line_attribute14;
    END IF;

    IF     (p_new_line_rec.interface_line_attribute15 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.interface_line_attribute15 :=
                       p_old_line_rec.interface_line_attribute15;
    ELSE   p_out_line_rec.interface_line_attribute15 :=
                       p_new_line_rec.interface_line_attribute15;
    END IF;

    IF     (p_new_line_rec.attribute_category = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute_category :=
                       p_old_line_rec.attribute_category;
    ELSE   p_out_line_rec.attribute_category :=
                       p_new_line_rec.attribute_category;
    END IF;

    IF     (p_new_line_rec.attribute1 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute1 := p_old_line_rec.attribute1;
    ELSE   p_out_line_rec.attribute1 := p_new_line_rec.attribute1;
    END IF;

    IF     (p_new_line_rec.attribute2 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute2 := p_old_line_rec.attribute2;
    ELSE   p_out_line_rec.attribute2 := p_new_line_rec.attribute2;
    END IF;

    IF     (p_new_line_rec.attribute3 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute3 := p_old_line_rec.attribute3;
    ELSE   p_out_line_rec.attribute3 := p_new_line_rec.attribute3;
    END IF;

    IF     (p_new_line_rec.attribute4 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute4 := p_old_line_rec.attribute4;
    ELSE   p_out_line_rec.attribute4 := p_new_line_rec.attribute4;
    END IF;

    IF     (p_new_line_rec.attribute5 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute5 := p_old_line_rec.attribute5;
    ELSE   p_out_line_rec.attribute5 := p_new_line_rec.attribute5;
    END IF;

    IF     (p_new_line_rec.attribute6 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute6 := p_old_line_rec.attribute6;
    ELSE   p_out_line_rec.attribute6 := p_new_line_rec.attribute6;
    END IF;

    IF     (p_new_line_rec.attribute7 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute7 := p_old_line_rec.attribute7;
    ELSE   p_out_line_rec.attribute7 := p_new_line_rec.attribute7;
    END IF;

    IF     (p_new_line_rec.attribute8 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute8 := p_old_line_rec.attribute8;
    ELSE   p_out_line_rec.attribute8 := p_new_line_rec.attribute8;
    END IF;

    IF     (p_new_line_rec.attribute9 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute9 := p_old_line_rec.attribute9;
    ELSE   p_out_line_rec.attribute9 := p_new_line_rec.attribute9;
    END IF;

    IF     (p_new_line_rec.attribute10 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute10 := p_old_line_rec.attribute10;
    ELSE   p_out_line_rec.attribute10 := p_new_line_rec.attribute10;
    END IF;

    IF     (p_new_line_rec.attribute11 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute11 := p_old_line_rec.attribute11;
    ELSE   p_out_line_rec.attribute11 := p_new_line_rec.attribute11;
    END IF;

    IF     (p_new_line_rec.attribute12 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute12 := p_old_line_rec.attribute12;
    ELSE   p_out_line_rec.attribute12 := p_new_line_rec.attribute12;
    END IF;

    IF     (p_new_line_rec.attribute13 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute13 := p_old_line_rec.attribute13;
    ELSE   p_out_line_rec.attribute13 := p_new_line_rec.attribute13;
    END IF;

    IF     (p_new_line_rec.attribute14 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute14 := p_old_line_rec.attribute14;
    ELSE   p_out_line_rec.attribute14 := p_new_line_rec.attribute14;
    END IF;

    IF     (p_new_line_rec.attribute15 = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.attribute15 := p_old_line_rec.attribute15;
    ELSE   p_out_line_rec.attribute15 := p_new_line_rec.attribute15;
    END IF;

    IF     (p_new_line_rec.global_attribute_category = AR_TEXT_DUMMY)
    THEN   p_out_line_rec.global_attribute_category :=
                       p_old_line_rec.global_attribute_category;
    ELSE   p_out_line_rec.global_attribute_category :=
                       p_new_line_rec.global_attribute_category;
    END IF;

    IF    (p_new_line_rec.global_attribute1 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute1 := p_old_line_rec.global_attribute1;
    ELSE  p_out_line_rec.global_attribute1 := p_new_line_rec.global_attribute1;
    END IF;

    IF    (p_new_line_rec.global_attribute2 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute2 := p_old_line_rec.global_attribute2;
    ELSE  p_out_line_rec.global_attribute2 := p_new_line_rec.global_attribute2;
    END IF;

    IF    (p_new_line_rec.global_attribute3 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute3 := p_old_line_rec.global_attribute3;
    ELSE  p_out_line_rec.global_attribute3 := p_new_line_rec.global_attribute3;
    END IF;

    IF    (p_new_line_rec.global_attribute4 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute4 := p_old_line_rec.global_attribute4;
    ELSE  p_out_line_rec.global_attribute4 := p_new_line_rec.global_attribute4;
    END IF;

    IF    (p_new_line_rec.global_attribute5 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute5 := p_old_line_rec.global_attribute5;
    ELSE  p_out_line_rec.global_attribute5 := p_new_line_rec.global_attribute5;
    END IF;

    IF    (p_new_line_rec.global_attribute6 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute6 := p_old_line_rec.global_attribute6;
    ELSE  p_out_line_rec.global_attribute6 := p_new_line_rec.global_attribute6;
    END IF;

    IF    (p_new_line_rec.global_attribute7 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute7 := p_old_line_rec.global_attribute7;
    ELSE  p_out_line_rec.global_attribute7 := p_new_line_rec.global_attribute7;
    END IF;

    IF    (p_new_line_rec.global_attribute8 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute8 := p_old_line_rec.global_attribute8;
    ELSE  p_out_line_rec.global_attribute8 := p_new_line_rec.global_attribute8;
    END IF;

    IF    (p_new_line_rec.global_attribute9 = AR_TEXT_DUMMY)
    THEN  p_out_line_rec.global_attribute9 := p_old_line_rec.global_attribute9;
    ELSE  p_out_line_rec.global_attribute9 := p_new_line_rec.global_attribute9;
    END IF;

    IF   (p_new_line_rec.global_attribute10 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute10 := p_old_line_rec.global_attribute10;
    ELSE p_out_line_rec.global_attribute10 := p_new_line_rec.global_attribute10;
    END IF;

    IF   (p_new_line_rec.global_attribute11 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute11 := p_old_line_rec.global_attribute11;
    ELSE p_out_line_rec.global_attribute11 := p_new_line_rec.global_attribute11;
    END IF;

    IF   (p_new_line_rec.global_attribute12 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute12 := p_old_line_rec.global_attribute12;
    ELSE p_out_line_rec.global_attribute12 := p_new_line_rec.global_attribute12;
    END IF;

    IF   (p_new_line_rec.global_attribute13 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute13 := p_old_line_rec.global_attribute13;
    ELSE p_out_line_rec.global_attribute13 := p_new_line_rec.global_attribute13;
    END IF;

    IF   (p_new_line_rec.global_attribute14 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute14 := p_old_line_rec.global_attribute14;
    ELSE p_out_line_rec.global_attribute14 := p_new_line_rec.global_attribute14;
    END IF;

    IF   (p_new_line_rec.global_attribute15 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute15 := p_old_line_rec.global_attribute15;
    ELSE p_out_line_rec.global_attribute15 := p_new_line_rec.global_attribute15;
    END IF;

    IF   (p_new_line_rec.global_attribute16 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute16 := p_old_line_rec.global_attribute16;
    ELSE p_out_line_rec.global_attribute16 := p_new_line_rec.global_attribute16;    END IF;

    IF   (p_new_line_rec.global_attribute17 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute17 := p_old_line_rec.global_attribute17;
    ELSE p_out_line_rec.global_attribute17 := p_new_line_rec.global_attribute17;
    END IF;

    IF   (p_new_line_rec.global_attribute18 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute18 := p_old_line_rec.global_attribute18;
    ELSE p_out_line_rec.global_attribute18 := p_new_line_rec.global_attribute18;
    END IF;

    IF   (p_new_line_rec.global_attribute19 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute19 := p_old_line_rec.global_attribute19;
    ELSE p_out_line_rec.global_attribute19 := p_new_line_rec.global_attribute19;
    END IF;

    IF   (p_new_line_rec.global_attribute20 = AR_TEXT_DUMMY)
    THEN p_out_line_rec.global_attribute20 := p_old_line_rec.global_attribute20;
    ELSE p_out_line_rec.global_attribute20 := p_new_line_rec.global_attribute20;
    END IF;

    IF     (p_new_line_rec.created_by = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.created_by := p_old_line_rec.created_by;
    ELSE   p_out_line_rec.created_by := p_new_line_rec.created_by;
    END IF;

    IF     (p_new_line_rec.creation_date = AR_DATE_DUMMY)
    THEN   p_out_line_rec.creation_date := p_old_line_rec.creation_date;
    ELSE   p_out_line_rec.creation_date := p_new_line_rec.creation_date;
    END IF;

    IF     (p_new_line_rec.last_updated_by = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.last_updated_by := p_old_line_rec.last_updated_by;
    ELSE   p_out_line_rec.last_updated_by := p_new_line_rec.last_updated_by;
    END IF;

    IF     (p_new_line_rec.last_update_date = AR_DATE_DUMMY)
    THEN   p_out_line_rec.last_update_date := p_old_line_rec.last_update_date;
    ELSE   p_out_line_rec.last_update_date := p_new_line_rec.last_update_date;
    END IF;

    IF     (p_new_line_rec.program_application_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.program_application_id :=
                       p_old_line_rec.program_application_id;
    ELSE   p_out_line_rec.program_application_id :=
                       p_new_line_rec.program_application_id;
    END IF;

    IF     (p_new_line_rec.last_update_login = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.last_update_login :=
                       p_old_line_rec.last_update_login;
    ELSE   p_out_line_rec.last_update_login :=
                       p_new_line_rec.last_update_login;
    END IF;

    IF     (p_new_line_rec.program_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.program_id := p_old_line_rec.program_id;
    ELSE   p_out_line_rec.program_id := p_new_line_rec.program_id;
    END IF;

    IF     (p_new_line_rec.program_update_date = AR_DATE_DUMMY)
    THEN   p_out_line_rec.program_update_date :=
                       p_old_line_rec.program_update_date;
    ELSE   p_out_line_rec.program_update_date :=
                       p_new_line_rec.program_update_date;
    END IF;

    IF     (p_new_line_rec.set_of_books_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.set_of_books_id := p_old_line_rec.set_of_books_id;
    ELSE   p_out_line_rec.set_of_books_id := p_new_line_rec.set_of_books_id;
    END IF;

    -- Rel. 11 Changes:

    IF     (p_new_line_rec.gross_unit_selling_price = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.gross_unit_selling_price :=
		p_old_line_rec.gross_unit_selling_price;
    ELSE   p_out_line_rec.gross_unit_selling_price :=
		p_new_line_rec.gross_unit_selling_price;
    END IF;

    IF     (p_new_line_rec.gross_extended_amount = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.gross_extended_amount :=
		p_old_line_rec.gross_extended_amount;
    ELSE   p_out_line_rec.gross_extended_amount :=
		p_new_line_rec.gross_extended_amount;
    END IF;

    IF     (p_new_line_rec.amount_includes_tax_flag = AR_FLAG_DUMMY)
    THEN   p_out_line_rec.amount_includes_tax_flag :=
			p_old_line_rec.amount_includes_tax_flag;
    ELSE   p_out_line_rec.amount_includes_tax_flag :=
			p_new_line_rec.amount_includes_tax_flag;
    END IF;

    /* Bug 853757 */
    IF     (p_new_line_rec.taxable_amount = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.taxable_amount :=
                p_old_line_rec.taxable_amount;
    ELSE   p_out_line_rec.taxable_amount :=
                p_new_line_rec.taxable_amount;
    END IF;

    IF     (p_new_line_rec.extended_acctd_amount = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.extended_acctd_amount :=
                p_old_line_rec.extended_acctd_amount;
    ELSE   p_out_line_rec.extended_acctd_amount :=
                p_new_line_rec.extended_acctd_amount;
    END IF;

    IF     (p_new_line_rec.br_ref_customer_trx_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.br_ref_customer_trx_id :=
                p_old_line_rec.br_ref_customer_trx_id;
    ELSE   p_out_line_rec.br_ref_customer_trx_id :=
                p_new_line_rec.br_ref_customer_trx_id;
    END IF;

    IF     (p_new_line_rec.br_ref_payment_schedule_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.br_ref_payment_schedule_id :=
                p_old_line_rec.br_ref_payment_schedule_id;
    ELSE   p_out_line_rec.br_ref_payment_schedule_id :=
                p_new_line_rec.br_ref_payment_schedule_id;
    END IF;

    IF     (p_new_line_rec.br_adjustment_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.br_adjustment_id :=
                p_old_line_rec.br_adjustment_id;
    ELSE   p_out_line_rec.br_adjustment_id :=
                p_new_line_rec.br_adjustment_id;
    END IF;

    IF     (p_new_line_rec.wh_update_date = AR_DATE_DUMMY)
    THEN   p_out_line_rec.wh_update_date :=
                p_old_line_rec.wh_update_date;
    ELSE   p_out_line_rec.wh_update_date :=
                p_new_line_rec.wh_update_date;
    END IF;

    IF     (p_new_line_rec.payment_set_id = AR_NUMBER_DUMMY)
    THEN   p_out_line_rec.payment_set_id := p_old_line_rec.payment_set_id;
    ELSE   p_out_line_rec.payment_set_id := p_new_line_rec.payment_set_id;
    END IF;

    /*  ETax - to support ship to at line level information */
    IF (p_new_line_rec.ship_to_customer_id = AR_NUMBER_DUMMY) THEN
       p_out_line_rec.ship_to_customer_id := p_old_line_rec.ship_to_customer_id;
    ELSE
       p_out_line_rec.ship_to_customer_id := p_new_line_rec.ship_to_customer_id;
    END IF;


    IF (p_new_line_rec.ship_to_site_use_id = AR_NUMBER_DUMMY) THEN
       p_out_line_rec.ship_to_site_use_id := p_old_line_rec.ship_to_site_use_id;
    ELSE
       p_out_line_rec.ship_to_site_use_id := p_new_line_rec.ship_to_site_use_id;    END IF;

    IF (p_new_line_rec.ship_to_contact_id = AR_NUMBER_DUMMY) THEN
       p_out_line_rec.ship_to_contact_id := p_old_line_rec.ship_to_contact_id;
    ELSE
       p_out_line_rec.ship_to_contact_id := p_new_line_rec.ship_to_contact_id;
    END IF;

    IF (p_new_line_rec.tax_classification_code = AR_TEXT_DUMMY) THEN
       p_out_line_rec.tax_classification_code :=
                 p_old_line_rec.tax_classification_code;
    ELSE
       p_out_line_rec.tax_classification_code :=
                 p_new_line_rec.tax_classification_code;
    END IF;
    IF     (p_new_line_rec.rule_end_date = AR_DATE_DUMMY)
    THEN   p_out_line_rec.rule_end_date := p_old_line_rec.rule_end_date;
    ELSE   p_out_line_rec.rule_end_date := p_new_line_rec.rule_end_date;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.merge_line_recs()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.merge_line_recs()');
         arp_util.debug(  '');
         arp_util.debug(  '-------- parameters for merge_line_recs() ------');
         arp_util.debug(  '  ---- old line record ----');
      END IF;
      display_line_rec(p_old_line_rec);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug(  '');
         arp_util.debug(  '  ---- new line record ----');
      END IF;
      display_line_rec(p_new_line_rec);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug(  '');
         arp_util.debug(  '  ---- merged line record ----');
      END IF;
      display_line_rec(p_out_line_rec);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug(  '');
      END IF;

      RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    insert_line_f_cm_ct_ctl_id                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure creates credit memo lines for the specified line type   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None                                                   |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-AUG-95  Subash Chadalavada  Created                                |
 |                                                                           |
 |     Rel. 11 Changes:							     |
 |     ----------------							     |
 |     07-22-97   OSTEINME		added code to handle three new       |
 |					database columns:                    |
 |					  - gross_unit_selling_price         |
 |					  - gross_extended_amount            |
 |					  - amount_includes_tax_flag         |
 |     08-20-97	  OSTEINME		changed procedure to populate        |
 |					created credit memo lines with       |
 |					amount_includes_tax_flag copied from |
 |					invoice line			     |
 |
 |                                                                           |
 |     10-JAN-99  Saloni Shah           added warehouse_id for global tax    |
 |                                      engine changes.                      |
 |     08-Apr-03  Veena Rao             Bug 2859668. Added field trans-      |
 |                                      lated_description.                   |
 |     26-Dec-03  Surendra Rajan        Bug-3335466 Replace the zero amount  |
 |                                      with 1 through decode in the Quantity|
 |                                      calculationugh decode in the Quantity|
 |     17-Feb-04  Surendra Rajan        Bug-3449586 commented the amount     |
 |                                      checking to correct the rounding     |
 |                                      errors.Ref. bug-3409173              |
 |     13-JUN-05  Jon Beckett		R12 eTax uptake - included ship to   |
 |					columns and tax classification code  |
 |     16-AUG-05  Jon Beckett		R12 eTax uptake - added p_tax_amount |
 |					to set mode for line_det_factors     |
 |     04-Jan-06  Surendra Rajan        Bug 3658284 : Added the code to impl-|
 |                                      -ement the line level rounding logic.|
 +===========================================================================*/
PROCEDURE insert_line_f_cm_ct_ctl_id(
  p_customer_trx_id         IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id    IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_prev_customer_trx_id    IN ra_customer_trx.customer_trx_id%type,
  p_line_type               IN ra_customer_trx_lines.line_type%type,
  p_line_percent            IN number,
  p_uncredited_amount       IN ra_customer_trx_lines.extended_amount%type,
  p_credit_amount           IN ra_customer_trx_lines.extended_amount%type,
  p_currency_code           IN fnd_currencies.currency_code%type,
  p_tax_amount              IN ra_customer_trx_lines.extended_amount%type)
IS
  l_rows_inserted           number;
--{BUG#3339072
l_trx_line_array  ctlrec;
i NUMBER;
--}
l_mode		  VARCHAR2(30);
/* Bug-3658284 */
l_amt_run_total         Number ;
l_amt_prev_run_total    Number ;
l_rev_run_total         Number ;
l_rev_prev_run_total    Number ;
/* Bug Number 6790882 */
l_total_tax_prorate	ra_customer_trx_lines.extended_amount%type := 0;
l_tax_amount		ra_customer_trx_lines.extended_amount%type;
l_quantity_invoiced     Number ;
l_round                 Number ;

--bug 9125212
cursor c1(c_prev_customer_trx_line_id number) is
 	 select quantity_invoiced
 	 FROM ra_customer_trx_lines
 	 WHERE customer_trx_line_id=c_prev_customer_trx_line_id;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'arp_ctl_pkg.insert_line_f_cm_ct_ctl_id()+');
           -- MVKOLLA - Bug7113653 Added following debug messages
           arp_util.debug('-- Added below messages for bug7113653');
           arp_util.debug('p_customer_trx_id         '||p_customer_trx_id);
           arp_util.debug('p_customer_trx_line_id    '||p_customer_trx_line_id);
           arp_util.debug('p_prev_customer_trx_id    '||p_prev_customer_trx_id);
           arp_util.debug('p_line_type               '||p_line_type);
           arp_util.debug('p_line_percent            '||p_line_percent);
           arp_util.debug('p_uncredited_amount       '||p_uncredited_amount);
           arp_util.debug('p_credit_amount           '||p_credit_amount);
           arp_util.debug('p_currency_code           '||p_currency_code);
           arp_util.debug('p_tax_amount              '||p_tax_amount);
    END IF;

    --{BUG#3339072
    SELECT ra_customer_trx_lines_s.nextval,
           p_customer_trx_id,
           pg_user_id,                     /* created_by */
           sysdate,                        /* creation_date */
           pg_user_id,                     /* last_updated_by */
           sysdate,                        /* last_update_date */
           nvl(pg_conc_login_id,
                 pg_login_id),             /* last_update_login */
           inv_ctl.line_number,
           decode(nra.line_type,
                  'CB', 'LINE',
                  nra.line_type),          /* line_type */
           inv_ctl.set_of_books_id,
           inv_ctl.accounting_rule_id,
           decode(inv_ctl.accounting_rule_id,
             NULL, decode(inv_ctl.line_type,
                     'TAX', 'Y',
                     'FREIGHT', 'Y',
                     ''),
             'N'),                         /* autorule_complete_flag */
           decode(inv_ctl.line_type,
             'TAX', '',
             'FREIGHT', '',
             decode(cm_ct.credit_method_for_rules,
               'UNIT', inv_ctl.accounting_rule_duration,
               '')),                       /* accounting_rule_duration */
           inv_ctl.description,
           inv_ctl.initial_customer_trx_line_id,
           inv_ctl.inventory_item_id,
           inv_ctl.item_exception_rate_id,
           inv_ctl.memo_line_id,
           cm_ct.reason_code,
           inv_ctl.customer_trx_id,
           inv_ctl.customer_trx_line_id,
           cm_ctl.customer_trx_line_id,
           inv_ctl.unit_standard_price,
           inv_ctl.unit_selling_price,
           inv_ctl.gross_unit_selling_price,  -- Bug 7389126 KALYAN
           inv_ctl.gross_extended_amount,     -- 6882394
           inv_ctl.extended_amount,           -- 6882394 (original)
           inv_ctl.revenue_amount,            -- 6882394 (original)
           decode(inv_ctl.line_type,
             'TAX', '',
             'FREIGHT', '',
 /* Bug3658284            arpcurr.CurrRound( */
             /* Bug-3335466 - Replace the zero amount with 1 */
                              ( decode(nra.net_amount,0,1,nra.net_amount) /
                                decode(p_uncredited_amount,
                                  0, 1,
                                  p_uncredited_amount
                                ) *
                                /* Bug 852633: revert changes for bug 583790 */
                                decode(p_credit_amount, 0, decode(nvl(p_line_percent, 0), 0, 0, -1), p_credit_amount)
                              )
 /* Bug3658284  , p_currency_code) */
                            * inv_ctl.quantity_invoiced /
                            decode(inv_ctl.extended_amount, 0, 1,
                                   inv_ctl.extended_amount) *
                            decode(inv_ctl.line_type,
                              'CHARGES', '',
                              1
                            )
             ),             /* quantity */
             inv_ctl.quantity_invoiced,         -- Bug 6990227
 /* Bug3658284          arpcurr.CurrRound( */
                              ( nra.net_amount /
                                decode(p_uncredited_amount,
                                       0, 1,
                                       p_uncredited_amount
                                      ) *
                                /* Bug 852633: revert changes for bug 583790 */
                                decode(p_credit_amount, 0, decode(nvl(p_line_percent, 0), 0, 0, -1),
                                       p_credit_amount)
                              )
 /* Bug3658284  , p_currency_code) */
                            ,             /* extended_amount */
           decode(inv_ctl.line_type,
             'TAX', '',
             'FREIGHT', '',
 /* Bug3658284    arpcurr.CurrRound( */
                              ( nra.net_amount /
                                decode(p_uncredited_amount,
                                       0, 1,
                                       p_uncredited_amount
                                      ) *
                                /* Bug 852633: revert changes for bug 583790 */
                                decode(p_credit_amount, 0, decode(nvl(p_line_percent, 0), 0, 0, -1), p_credit_amount)
                              ) *
                              ( nvl(inv_ctl.revenue_amount,
                                     inv_ctl.extended_amount) /
                                decode(inv_ctl.extended_amount,
                                       0, 1,
                                       inv_ctl.extended_amount)
                              )
  /* Bug3658284   , p_currency_code)  */
                           * decode(inv_ctl.line_type,
                                    'CHARGES', '',
                                    1)
             ),               /* revenue_amount */
           decode(inv_ctl.line_type,
             'TAX', '',
             'FREIGHT', '',
             inv_ctl.sales_order),
           decode(inv_ctl.line_type,
             'TAX', null,
             'FREIGHT', null,
             inv_ctl.sales_order_date),
           decode(inv_ctl.line_type,
             'TAX', '',
             'FREIGHT', '',
             inv_ctl.sales_order_line),
           decode(inv_ctl.line_type,
             'TAX', '',
             'FREIGHT', '',
             inv_ctl.sales_order_revision),
           decode(inv_ctl.line_type,
             'TAX', '',
             'FREIGHT', '',
             inv_ctl.sales_order_source),
           inv_ctl.tax_exemption_id,
           inv_ctl.tax_precedence,
           inv_ctl.tax_rate,
           inv_ctl.uom_code,
           cm_ct.default_ussgl_transaction_code,
           cm_ct.default_ussgl_trx_code_context,
           inv_ctl.sales_tax_id,
           inv_ctl.location_segment_id,
           inv_ctl.vat_tax_id,
	   inv_ctl.amount_includes_tax_flag,
           inv_ctl.warehouse_id,
        --Fix for bug 1161592
           cm_ctl.extended_amount /* Taxable_amount */
          , inv_ctl.translated_description
          ,cm_ct.org_id /* SSA changes anuj */
          /* R12 eTax uptake - ship to and tax columns needed */
          ,inv_ctl.ship_to_customer_id
          ,inv_ctl.ship_to_address_id
          ,inv_ctl.ship_to_site_use_id
          ,inv_ctl.ship_to_contact_id
          ,inv_ctl.tax_classification_code
          /* NULL=Y N=not historical, calc tax */
          /* N - New CM line is created */
          ,NVL(inv_ctl.historical_flag,'N')
          ,inv_ctl_memo.line_type
      BULK COLLECT INTO
          l_trx_line_array.customer_trx_line_id,
          l_trx_line_array.customer_trx_id,
          l_trx_line_array.created_by,
          l_trx_line_array.creation_date,
          l_trx_line_array.last_updated_by,
          l_trx_line_array.last_update_date,
          l_trx_line_array.last_update_login,
          l_trx_line_array.line_number,
          l_trx_line_array.line_type,
          l_trx_line_array.set_of_books_id,
          l_trx_line_array.accounting_rule_id,
          l_trx_line_array.autorule_complete_flag,
          l_trx_line_array.last_period_to_credit,
          l_trx_line_array.description,
          l_trx_line_array.initial_customer_trx_line_id,
          l_trx_line_array.inventory_item_id,
          l_trx_line_array.item_exception_rate_id,
          l_trx_line_array.memo_line_id,
          l_trx_line_array.reason_code,
          l_trx_line_array.previous_customer_trx_id,
          l_trx_line_array.previous_customer_trx_line_id,
          l_trx_line_array.link_to_cust_trx_line_id,
          l_trx_line_array.unit_standard_price,
          l_trx_line_array.unit_selling_price,
          l_trx_line_array.gross_unit_selling_price, -- Bug 7389126 KALYAN
          l_trx_line_array.gross_extended_amount,    -- 6882394
          l_trx_line_array.original_extended_amount, -- 6882394
          l_trx_line_array.original_revenue_amount,  -- 6882394
          l_trx_line_array.quantity_credited,
          l_trx_line_array.quantity_invoiced,   -- Bug 6990227.
          l_trx_line_array.extended_amount,
          l_trx_line_array.revenue_amount,
          l_trx_line_array.sales_order,
          l_trx_line_array.sales_order_date,
          l_trx_line_array.sales_order_line,
          l_trx_line_array.sales_order_revision,
          l_trx_line_array.sales_order_source,
          l_trx_line_array.tax_exemption_id,
          l_trx_line_array.tax_precedence,
          l_trx_line_array.tax_rate,
          l_trx_line_array.uom_code,
          l_trx_line_array.default_ussgl_transaction_code,
          l_trx_line_array.default_ussgl_trx_code_context,
          l_trx_line_array.sales_tax_id,
          l_trx_line_array.location_segment_id,
          l_trx_line_array.vat_tax_id,
	  l_trx_line_array.amount_includes_tax_flag,
          l_trx_line_array.warehouse_id,
          l_trx_line_array.taxable_amount,
          l_trx_line_array.translated_description,
          l_trx_line_array.org_id,
          l_trx_line_array.ship_to_customer_id,
          l_trx_line_array.ship_to_address_id,
          l_trx_line_array.ship_to_site_use_id,
          l_trx_line_array.ship_to_contact_id,
          l_trx_line_array.tax_classification_code,
          l_trx_line_array.historical_flag,
          l_trx_line_array.memo_line_type
          --}
    FROM   ra_customer_trx_lines inv_ctl,
           ra_customer_trx_lines cm_ctl,
           ra_customer_trx       cm_ct,
           ar_net_revenue_amount nra,
           ar_memo_lines_b       inv_ctl_memo
    WHERE  cm_ct.customer_trx_id    = p_customer_trx_id
      AND  inv_ctl.customer_trx_id  = cm_ct.previous_customer_trx_id
      AND  nra.customer_trx_id      = p_prev_customer_trx_id
      AND  nra.customer_trx_line_id = inv_ctl.customer_trx_line_id
      AND  nra.line_type            = inv_ctl.line_type
      AND  p_customer_trx_id        = cm_ctl.customer_trx_id(+)
      AND  nvl(p_customer_trx_line_id,
               -99)                 = decode(p_customer_trx_line_id,
                                      null, -99,
                                      cm_ctl.customer_trx_line_id)
      AND  inv_ctl.link_to_cust_trx_line_id =
                                      cm_ctl.previous_customer_trx_line_id(+)
      AND  decode(nra.line_type, 'CB', 'LINE',
                                 'CHARGES', 'LINE',
                                nra.line_type) = p_line_type
      AND  inv_ctl.memo_line_id = inv_ctl_memo.memo_line_id (+);


   l_rows_inserted := l_trx_line_array.customer_trx_line_id.COUNT;

/* Bug-3658284 -Start */
   IF (l_trx_line_array.customer_trx_line_id.COUNT = 0) Then
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug(  'arp_ctl_pkg.insert_line_f_cm_ct_ctl_id : '||' 0 row  Fetch ');
      END IF;

   ELSE /*-- Bug 5098922 ---*/

   FOR i IN l_trx_line_array.customer_trx_line_id.FIRST ..
            l_trx_line_array.customer_trx_line_id.LAST
   LOOP

      /*-------------------------------------------------------------------------+
       | Maintain running total amounts for Revenue amounts and accounted amounts|
       +-------------------------------------------------------------------------*/
          l_amt_run_total          := Nvl(l_amt_run_total,0)
                                       + l_trx_line_array.extended_amount(i);

      /*-------------------------------------------------------------------------------+
       | Adjusting the rounding amount in the next line amount - revenue for cm line   |
       | Eg. Line 1   -> 10 * 10/100  = 1 (rounded amount)                             |
       |     Line 2   -> 20 * 10/100  = 2 (rounded amount)                             |
       |               ->  2  - Line 1 (rounded amount) -> 2 - 1 -> 1                  |
       |     Line ...                                                                  |
       +-------------------------------------------------------------------------------+ */
          l_trx_line_array.extended_amount(i) := arpcurr.CurrRound(l_amt_run_total
                             ,p_currency_code) -Nvl(l_amt_prev_run_total,0);
      /*------------------------------------------------------------------------------+
       | Running total for previous line amount - Revenue in currency                 |
       +------------------------------------------------------------------------------*/
          l_amt_prev_run_total := Nvl(l_amt_prev_run_total,0)
                                          + l_trx_line_array.extended_amount(i);

        If l_trx_line_array.line_type(i) = 'LINE' then

           l_rev_run_total                    := Nvl(l_rev_run_total,0)
                                                + l_trx_line_array.revenue_amount(i);
           l_trx_line_array.revenue_amount(i) := arpcurr.CurrRound(l_rev_run_total
                                      ,p_currency_code) -Nvl(l_rev_prev_run_total,0);
           l_rev_prev_run_total               := Nvl(l_rev_prev_run_total,0)
                                                + l_trx_line_array.revenue_amount(i);

          /* 6882394 - Handle inclusive tax if it exists and if tax is
              being credited at this time.  */
          IF l_trx_line_array.gross_extended_amount(i) IS NOT NULL AND
             p_tax_amount IS NOT NULL
          THEN
             IF PG_DEBUG = 'Y'
             THEN
                 arp_util.debug('Inclusive tax, adjusting extended/revenue amounts');
                 arp_util.debug('customer_trx_line_id = ' ||
                     l_trx_line_array.customer_trx_line_id(i));
                 arp_util.debug('  original extended_amount = ' ||
                     l_trx_line_array.extended_amount(i));
                 arp_util.debug('  original revenue_amount = ' ||
                     l_trx_line_array.revenue_amount(i));
             END IF;

             l_trx_line_array.extended_amount(i) :=
                arpcurr.currround(
                  l_trx_line_array.gross_extended_amount(i) *
                      (l_trx_line_array.extended_amount(i) /
                       l_trx_line_array.original_extended_amount(i)), p_currency_code);

             l_trx_line_array.revenue_amount(i) :=
                arpcurr.currround(
                  l_trx_line_array.gross_extended_amount(i) *
                      (l_trx_line_array.revenue_amount(i) /
                       l_trx_line_array.original_revenue_amount(i)), p_currency_code);

             IF PG_DEBUG = 'Y'
             THEN
                 arp_util.debug('  new extended_amount = ' ||
                     l_trx_line_array.extended_amount(i));
                 arp_util.debug('  new revenue_amount = ' ||
                     l_trx_line_array.revenue_amount(i));
             END IF;

          END IF;

/*-----------------------------------------------------------------------------------+
| Bug 6990227 : For 100% Credit Allocation, Invoice Quantity is copied to CM Quantity
+------------------------------------------------------------------------------------*/
           If p_line_percent = 100 then
             l_trx_line_array.quantity_credited(i) :=(-1) *
l_trx_line_array.quantity_invoiced(i);
           Else
          /*---------------------------------------------------------------+
           | Quantity_credited * Unit price is equal to extended_amount    |
           +---------------------------------------------------------------*/
           If Nvl(l_trx_line_array.unit_Selling_price(i),0) <> 0 then
             -- bug 9125212
           open c1(l_trx_line_array.previous_customer_trx_line_id(i));
           fetch c1 into l_quantity_invoiced ;
 	               close c1;
 	                         -- The below logic is used to round off the Quantity_credited upto the
 	                         -- decimal place for which the original inovice's quantity_invoiced was entered
 	                         -- Bug 7389126 KALYAN
	        l_round := (length(l_quantity_invoiced)-length(round(l_quantity_invoiced,0)))-1 ;
		if(l_round < 2 ) then
		l_round := 2;
		end if;

               If Nvl(l_trx_line_array.gross_unit_Selling_price(i),0) <> 0 then
                 l_trx_line_array.quantity_credited(i):= round( (l_trx_line_array.extended_amount(i) /l_trx_line_array.gross_unit_Selling_price(i) ),
                 l_round);
               Else
                 l_trx_line_array.quantity_credited(i):= round( (l_trx_line_array.extended_amount(i) /l_trx_line_array.unit_Selling_price(i) ),
                 l_round);
               End If;
           End If;
        End if;
      End if;
   End Loop;

 END IF;  /* -- Bug 5098922 ---*/
/* Bug-3658284 - End  */
-- MVKOLLA - Added following debug messages as part of bug7113653
    IF PG_DEBUG in ('Y', 'C') THEN
        i := l_trx_line_array.customer_trx_line_id.FIRST;
        WHILE l_trx_line_array.customer_trx_line_id.EXISTS(i) LOOP
           arp_util.debug('l_trx_line_array.customer_trx_line_id(i)    '||l_trx_line_array.customer_trx_line_id(i));
           arp_util.debug('l_trx_line_array.previous_customer_trx_line_id(i)    '||l_trx_line_array.previous_customer_trx_line_id(i));
           arp_util.debug('l_trx_line_array.extended_amount(i)    '||l_trx_line_array.extended_amount(i));
           arp_util.debug('l_trx_line_array.revenue_amount(i)              '||l_trx_line_array.revenue_amount(i));
          i := l_trx_line_array.customer_trx_line_id.NEXT(i);
        END LOOP;
    END IF;

  --{BUG#3339072
  IF l_rows_inserted <> 0 THEN
    FORALL indx IN l_trx_line_array.customer_trx_line_id.FIRST ..
                   l_trx_line_array.customer_trx_line_id.LAST
    INSERT INTO ra_customer_trx_lines
       (  customer_trx_line_id,
          customer_trx_id,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          line_number,
          line_type,
          set_of_books_id,
          accounting_rule_id,
          autorule_complete_flag,
          last_period_to_credit,
          description,
          initial_customer_trx_line_id,
          inventory_item_id,
          item_exception_rate_id,
          memo_line_id,
          reason_code,
          previous_customer_trx_id,
          previous_customer_trx_line_id,
          link_to_cust_trx_line_id,
          unit_standard_price,
          unit_selling_price,
          gross_unit_selling_price,  -- Bug 7389126 KALYAN
          quantity_credited,
          extended_amount,
          revenue_amount,
          sales_order,
          sales_order_date,
          sales_order_line,
          sales_order_revision,
          sales_order_source,
          tax_exemption_id,
          tax_precedence,
          tax_rate,
          uom_code,
          default_ussgl_transaction_code,
          default_ussgl_trx_code_context,
          sales_tax_id,
          location_segment_id,
          vat_tax_id,
          amount_includes_tax_flag,
          warehouse_id,
          taxable_amount,
          translated_description
          ,org_id
          ,ship_to_customer_id
          ,ship_to_address_id
          ,ship_to_site_use_id
          ,ship_to_contact_id
          ,tax_classification_code
          ,historical_flag
       ) VALUES
       (  l_trx_line_array.customer_trx_line_id(indx),
          l_trx_line_array.customer_trx_id(indx),
          l_trx_line_array.created_by(indx),
          l_trx_line_array.creation_date(indx),
          l_trx_line_array.last_updated_by(indx),
          l_trx_line_array.last_update_date(indx),
          l_trx_line_array.last_update_login(indx),
          l_trx_line_array.line_number(indx),
          l_trx_line_array.line_type(indx),
          l_trx_line_array.set_of_books_id(indx),
          l_trx_line_array.accounting_rule_id(indx),
          l_trx_line_array.autorule_complete_flag(indx),
          l_trx_line_array.last_period_to_credit(indx),
          l_trx_line_array.description(indx),
          l_trx_line_array.initial_customer_trx_line_id(indx),
          l_trx_line_array.inventory_item_id(indx),
          l_trx_line_array.item_exception_rate_id(indx),
          l_trx_line_array.memo_line_id(indx),
          l_trx_line_array.reason_code(indx),
          l_trx_line_array.previous_customer_trx_id(indx),
          l_trx_line_array.previous_customer_trx_line_id(indx),
          l_trx_line_array.link_to_cust_trx_line_id(indx),
          l_trx_line_array.unit_standard_price(indx),
          l_trx_line_array.unit_selling_price(indx),
          l_trx_line_array.gross_unit_selling_price(indx), -- Bug 7389126 KALYAN
          l_trx_line_array.quantity_credited(indx),
          l_trx_line_array.extended_amount(indx),
          l_trx_line_array.revenue_amount(indx),
          l_trx_line_array.sales_order(indx),
          l_trx_line_array.sales_order_date(indx),
          l_trx_line_array.sales_order_line(indx),
          l_trx_line_array.sales_order_revision(indx),
          l_trx_line_array.sales_order_source(indx),
          l_trx_line_array.tax_exemption_id(indx),
          l_trx_line_array.tax_precedence(indx),
          l_trx_line_array.tax_rate(indx),
          l_trx_line_array.uom_code(indx),
          l_trx_line_array.default_ussgl_transaction_code(indx),
          l_trx_line_array.default_ussgl_trx_code_context(indx),
          l_trx_line_array.sales_tax_id(indx),
          l_trx_line_array.location_segment_id(indx),
          l_trx_line_array.vat_tax_id(indx),
	  l_trx_line_array.amount_includes_tax_flag(indx),
          l_trx_line_array.warehouse_id(indx),
          l_trx_line_array.taxable_amount(indx),
          l_trx_line_array.translated_description(indx),
          l_trx_line_array.org_id(indx),
          l_trx_line_array.ship_to_customer_id(indx),
          l_trx_line_array.ship_to_address_id(indx),
          l_trx_line_array.ship_to_site_use_id(indx),
          l_trx_line_array.ship_to_contact_id(indx),
	  l_trx_line_array.tax_classification_code(indx),
          l_trx_line_array.historical_flag(indx));

        i := l_trx_line_array.customer_trx_line_id.FIRST;
        WHILE l_trx_line_array.customer_trx_line_id.EXISTS(i) LOOP
        /* R12 eTax uptake */

   /* 5402228 - clarified use of tax for line-only scenarios.  There are
      two to be concerned with.  They are:

      1) inv or cm with memo_line of type TAX -
             INSERT_NO_TAX       - LINE_INFO_TAX_ONLY
      2) inv or cm with no tax at all
             INSERT_NO_TAX_EVER  - RECORD_WITH_NO_TAX
   */

        IF p_line_type = 'LINE' THEN
           IF p_tax_amount IS NULL THEN  --bug6778519
              IF NVL(l_trx_line_array.memo_line_type(i), 'XXX') = 'TAX'
              THEN
                 l_mode := 'INSERT_NO_TAX';
              ELSE
                 l_mode := 'INSERT_NO_TAX_EVER';
              END IF;
           ELSIF NVL(p_credit_amount,0) = 0 THEN
              l_mode := 'INSERT_NO_LINE';
           ELSE
              l_mode := 'INSERT';
           END IF;

/* Bug Number 6790882 */

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'i = ' || i);
       arp_util.debug(  'l_rows_inserted = ' || l_rows_inserted);
       arp_util.debug(  'l_mode = ' || l_mode);
    END IF;

     IF l_mode = 'INSERT_NO_LINE' THEN
	IF i = l_rows_inserted THEN
		l_tax_amount := p_tax_amount - l_total_tax_prorate;
	ELSE
		l_tax_amount := calculate_prorated_tax_amount(
                     	            p_mode => l_mode,
				    p_tax_amount => p_tax_amount,
				    p_customer_trx_id => p_customer_trx_id,
				    p_customer_trx_line_id =>
                                      l_trx_line_array.customer_trx_line_id(i));

		l_total_tax_prorate := l_total_tax_prorate + l_tax_amount;
	END IF;
     ELSE
        l_tax_amount := p_tax_amount;
     END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'l_total_tax_prorate = ' || l_total_tax_prorate);
       arp_util.debug(  'l_tax_amount = ' || l_tax_amount);
    END IF;

           ARP_ETAX_SERVICES_PKG.line_det_factors(
               p_customer_trx_line_id => l_trx_line_array.customer_trx_line_id(i),
               p_customer_trx_id => p_customer_trx_id,
               p_mode => l_mode,
	       p_tax_amount => l_tax_amount) ;
        END IF;

          i := l_trx_line_array.customer_trx_line_id.NEXT(i);
        END LOOP;

     END IF;
     --}


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.insert_line_f_cm_ct_ctl_id : '||
                   to_char(l_rows_inserted)||' rows inserted');
    END IF;

/* Bug 3658284 - Remove the entire rounding update statement */

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.insert_line_f_cm_ct_ctl_id()-');
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return;
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'EXCEPTION: arp_ctl_pkg.insert_line_f_cm_ct_ctl_id');
       arp_util.debug(  '');
       arp_util.debug(  'p_customer_trx_id         = '||p_customer_trx_id);
       arp_util.debug(  'p_customer_trx_line_id    = '||p_customer_trx_line_id);
       arp_util.debug(  'p_prev_customer_trx_id    = '||p_prev_customer_trx_id);
       arp_util.debug(  'p_line_type               = '||p_line_type);
       arp_util.debug(  'p_uncredited_amount       = '||p_uncredited_amount);
       arp_util.debug(  'p_credit_amount           = '||p_credit_amount);
       arp_util.debug(  'p_currency_code           = '||p_currency_code);
    END IF;
    RAISE;

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    update_line_f_cm_ctl_id                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates credit memo lines for the specified line type   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None                                                   |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-AUG-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_line_f_cm_ctl_id(
  p_customer_trx_id         IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id    IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_prev_customer_trx_id    IN ra_customer_trx.customer_trx_id%type,
  p_line_type               IN ra_customer_trx_lines.line_type%type,
  p_uncredited_amount       IN ra_customer_trx_lines.extended_amount%type,
  p_credit_amount           IN ra_customer_trx_lines.extended_amount%type,
  p_currency_code           IN fnd_currencies.currency_code%type)
IS
  l_rows_updated           number;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.update_line_f_cm_ctl_id()+');
    END IF;

    UPDATE ra_customer_trx_lines ctl
    SET    extended_amount =
              (SELECT ( (nra.net_amount  -
                         decode(cm_ct.complete_flag,
                           'Y', nvl(ctl.extended_amount, 0),
                           0)) /
                         decode(p_uncredited_amount,
                           0, 1,
                           p_uncredited_amount
                           ) * nvl(p_credit_amount, 0)
                      ) /* extended_amount */
               FROM   ar_net_revenue_amount nra,
                      ra_customer_trx cm_ct
               WHERE  nra.customer_trx_id = p_prev_customer_trx_id
               AND    nra.customer_trx_line_id =
                           ctl.previous_customer_trx_line_id
               AND    cm_ct.customer_trx_id = p_customer_trx_id)
    WHERE  ctl.customer_trx_id = p_customer_trx_id
    AND    ctl.link_to_cust_trx_line_id = p_customer_trx_line_id
    AND    ctl.line_type = p_line_type;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.update_line_f_cm_ctl_id : '||
                   'Extended Amount :'|| SQL%ROWCOUNT||' rows updated');
    END IF;

    UPDATE ra_customer_trx_lines ctl
    SET    extended_amount = arpcurr.CurrRound (extended_amount,
                                                p_currency_code)
    WHERE  ctl.customer_trx_id = p_customer_trx_id
    AND    ctl.link_to_cust_trx_line_id = p_customer_trx_line_id
    AND    ctl.line_type = p_line_type;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.update_line_f_cm_ctl_id : '||
                   'Currency Rounding :'|| SQL%ROWCOUNT||' rows updated');
    END IF;

   /*----------------------------+
    |  correct rounding errors   |
    +----------------------------*/

    IF (SQL%ROWCOUNT > 0)
    THEN
        UPDATE ra_customer_trx_lines l
        SET extended_amount =
               (SELECT l.extended_amount +
                        (p_credit_amount - sum(l2.extended_amount))
                FROM   ra_customer_trx_lines l2
                WHERE  l2.customer_trx_id = l.customer_trx_id
                AND    l2.link_to_cust_trx_line_id = p_customer_trx_line_id
                AND    l2.line_type = p_line_type)
        WHERE l.customer_trx_id      = p_customer_trx_id
        AND   l.line_type            = p_line_type
        AND   l.customer_trx_line_id =
                   (SELECT min(customer_trx_line_id)
                    FROM   ra_customer_trx_lines l3
                    WHERE  l3.customer_trx_id = p_customer_trx_id
                    AND    l3.link_to_cust_trx_line_id = p_customer_trx_line_id
                    AND    l3.line_type       = p_line_type
                    AND    l3.extended_amount <> 0
                    HAVING SUM(l3.extended_amount) <> p_credit_amount);

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_ctl_pkg.update_line_f_cm_ctl_id()-');
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return;
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'EXCEPTION: arp_ctl_pkg.update_line_f_cm_ctl_id');
       arp_util.debug(  '');
       arp_util.debug(  'p_customer_trx_id         = '||p_customer_trx_id);
       arp_util.debug(  'p_customer_trx_line_id    = '||p_customer_trx_line_id);
       arp_util.debug(  'p_prev_customer_trx_id    = '||p_prev_customer_trx_id);
       arp_util.debug(  'p_line_type               = '||p_line_type);
       arp_util.debug(  'p_uncredited_amount       = '||p_uncredited_amount);
       arp_util.debug(  'p_credit_amount           = '||p_credit_amount);
       arp_util.debug(  'p_currency_code           = '||p_currency_code);
    END IF;
    RAISE;

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_text_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the value of the AR_TEXT_DUMMY constant.         |
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
 | RETURNS    : value of AR_TEXT_DUMMY                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_text_dummy(p_null IN NUMBER DEFAULT null) RETURN varchar2 IS

BEGIN

---    arp_util.debug('arp_ctl_pkg.get_text_dummy()+');

---    arp_util.debug('arp_ctl_pkg.get_text_dummy()-');

    return(AR_TEXT_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.get_text_dummy()');
        END IF;
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_number_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the value of the AR_NUMBER DUMMY constant.       |
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
 |     09-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number IS

BEGIN

---    arp_util.debug('arp_ctl_pkg.get_number_dummy()+');

---   arp_util.debug('arp_ctl_pkg.get_number_dummy()-');

    return(AR_NUMBER_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_ctl_pkg.get_number_dummy()');
        END IF;
        RAISE;

END;

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


END ARP_CTL_PKG;

/
