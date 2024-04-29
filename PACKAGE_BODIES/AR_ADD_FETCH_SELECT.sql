--------------------------------------------------------
--  DDL for Package Body AR_ADD_FETCH_SELECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ADD_FETCH_SELECT" AS
/* $Header: ARXRWAFB.pls 120.12 2006/04/19 22:37:04 kmaheswa ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

-- Cursors for On Account, Open Transactions and Credit Memo Applications
c_on_acct       INTEGER;
c_open_trx      INTEGER;
c_cm_apps       INTEGER;

TYPE rectyp is RECORD (
   row_id                           ROWID,
   cash_receipt_id                  NUMBER,
   customer_trx_id                  NUMBER,
   cm_customer_trx_id               NUMBER,
   last_update_date                 DATE,
   last_updated_by                  NUMBER,
   creation_date                    DATE,
   created_by                       NUMBER,
   last_update_login                NUMBER,
   program_application_id           NUMBER,
   program_id                       NUMBER,
   program_update_date              DATE,
   request_id                       NUMBER,
   receipt_number                   VARCHAR2(100),
   applied_flag                     VARCHAR2(100),
   customer_id                      NUMBER,
   customer_name                    VARCHAR2(100),
   customer_number                  VARCHAR2(100),
   trx_number                       VARCHAR2(100),
   installment                      NUMBER,
   amount_applied                   NUMBER,
   amount_applied_from              NUMBER,
   trans_to_receipt_rate            NUMBER,
   discount                         NUMBER,
   discounts_earned                 NUMBER,
   discounts_unearned               NUMBER,
   discount_taken_earned            NUMBER,
   discount_taken_unearned          NUMBER,
   amount_due_remaining             NUMBER,
   due_date                         DATE,
   status                           VARCHAR2(100),
   term_id                          NUMBER,
   trx_class_name                   VARCHAR2(100),
   trx_class_code                   VARCHAR2(100),
   trx_type_name                    VARCHAR2(100),
   cust_trx_type_id                 NUMBER,
   trx_date                         DATE,
   location_name                    VARCHAR2(100),
   bill_to_site_use_id              NUMBER,
   days_late                        NUMBER,
   line_number                      NUMBER,
   customer_trx_line_id             NUMBER,
   apply_date                       DATE,
   gl_date                          DATE,
   gl_posted_date                   DATE,
   reversal_gl_date                 DATE,
   exchange_rate                    NUMBER,
   invoice_currency_code            VARCHAR2(15),
   amount_due_original              NUMBER,
   amount_in_dispute                NUMBER,
   amount_line_items_original       NUMBER,
   acctd_amount_due_remaining       NUMBER,
   acctd_amount_applied_to          NUMBER,
   acctd_amount_applied_from        NUMBER,
   exchange_gain_loss               NUMBER,
   discount_remaining               NUMBER,
   calc_discount_on_lines_flag      VARCHAR2(100),
   partial_discount_flag            VARCHAR2(100),
   allow_overapplication_flag       VARCHAR2(100),
   natural_application_only_flag    VARCHAR2(100),
   creation_sign                    VARCHAR2(100),
   applied_payment_schedule_id      NUMBER,
   ussgl_transaction_code           VARCHAR2(100),
   ussgl_transaction_code_context   VARCHAR2(100),
   purchase_order                   VARCHAR2(50),
   trx_doc_sequence_id              NUMBER,
   trx_doc_sequence_value           VARCHAR2(100),
   trx_batch_source_name            VARCHAR2(100),
   amount_adjusted                  NUMBER,
   amount_adjusted_pending          NUMBER,
   amount_line_items_remaining      NUMBER,
   freight_original                 NUMBER,
   freight_remaining                NUMBER,
   receivables_charges_remaining    NUMBER,
   tax_original                     NUMBER,
   tax_remaining                    NUMBER,
   selected_for_receipt_batch_id    NUMBER,
   receivable_application_id        NUMBER,
   attribute_category               VARCHAR2(50),
   attribute1                       VARCHAR2(150),
   attribute2                       VARCHAR2(150),
   attribute3                       VARCHAR2(150),
   attribute4                       VARCHAR2(150),
   attribute5                       VARCHAR2(150),
   attribute6                       VARCHAR2(150),
   attribute7                       VARCHAR2(150),
   attribute8                       VARCHAR2(150),
   attribute9                       VARCHAR2(150),
   attribute10                      VARCHAR2(150),
   attribute11                      VARCHAR2(150),
   attribute12                      VARCHAR2(150),
   attribute13                      VARCHAR2(150),
   attribute14                      VARCHAR2(150),
   attribute15                      VARCHAR2(150),
   trx_billing_number               VARCHAR2(30),
   global_attribute_category        VARCHAR2(50),
   global_attribute1                VARCHAR2(150),
   global_attribute2                VARCHAR2(150),
   global_attribute3                VARCHAR2(150),
   global_attribute4                VARCHAR2(150),
   global_attribute5                VARCHAR2(150),
   global_attribute6                VARCHAR2(150),
   global_attribute7                VARCHAR2(150),
   global_attribute8                VARCHAR2(150),
   global_attribute9                VARCHAR2(150),
   global_attribute10               VARCHAR2(150),
   global_attribute11               VARCHAR2(150),
   global_attribute12               VARCHAR2(150),
   global_attribute13               VARCHAR2(150),
   global_attribute14               VARCHAR2(150),
   global_attribute15               VARCHAR2(150),
   global_attribute16               VARCHAR2(150),
   global_attribute17               VARCHAR2(150),
   global_attribute18               VARCHAR2(150),
   global_attribute19               VARCHAR2(150),
   global_attribute20               VARCHAR2(150),
   transaction_category             VARCHAR2(150),
   trx_gl_date                      DATE,
   comments                      VARCHAR2(240), -- bug 2662270
   receivables_trx_id		    NUMBER,       --
   rec_activity_name		    VARCHAR2(50),  --
   application_ref_id		    NUMBER,         -- CM refunds
   application_ref_num		    VARCHAR2(30),  --
   application_ref_type		    VARCHAR2(30), --
   application_ref_type_meaning	    VARCHAR2(80)  --
);

open_trx_row    rectyp;
on_acct_row     rectyp;
cm_apps_row     rectyp;

l_app_gl_date_default VARCHAR2(30):= fnd_profile.value('AR_APPLICATION_GL_DATE_DEFAULT');


/*===========================================================================+
 | FUNCTION
 |      CHANGE_ORDER_BY
 |
 | DESCRIPTION
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  : IN:
 |
 |             OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |      25-AUG-97  Joan Zaman   Created.
 |
 +===========================================================================*/
FUNCTION CHANGE_ORDER_BY (p_order_by VARCHAR2 ) RETURN VARCHAR2 IS

l_order_by VARCHAR2(2000);

BEGIN

  l_order_by := p_order_by;

  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('cash_receipt_id'),	'2');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('customer_trx_id'),	'3');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('cm_customer_trx_id'),	'4');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('last_update_date'),	'5');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('last_updated_by'),	'6');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('creation_date'),	'7');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('created_by'),	'8');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('last_update_login'),	'9');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('program_application_id'),	'10');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('program_id'),	'11');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('program_update_date'),	'12');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('request_id'),	'13');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('receipt_number'),	'14');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('applied_flag'),	'15');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('customer_id'),	'16');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('customer_name'),	'17');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('customer_number'),	'18');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_number'),	'19');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('installment'),	'20');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_applied'),	'21');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_applied_from'),	'22');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trans_to_receipt_rate'),	'23');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('discount'),	'24');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('discounts_earned'),	'25');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('discounts_unearned'),	'26');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('discount_taken_earned'),	'27');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('discount_taken_unearned'),	'28');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_due_remaining'),	'29');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('due_date'),	'30');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('status'),	'31');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('term_id'),	'32');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_class_name'),	'33');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_class_code'),	'34');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_type_name'),	'35');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('cust_trx_type_id'),	'36');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_date'),	'37');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('location_name'),	'38');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('bill_to_site_use_id'),	'39');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('days_late'),	'40');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('line_number'),	'41');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('customer_trx_line_id'),	'42');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('apply_date'),	'43');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('gl_date'),	'44');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('gl_posted_date'),	'45');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('reversal_gl_date'),	'46');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('exchange_rate'),	'47');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('invoice_currency_code'),	'48');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_due_original'),	'49');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_in_dispute'),	'50');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_line_items_original'),	'51');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('acctd_amount_due_remaining'),	'52');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('acctd_amount_applied_to'),	'53');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('acctd_amount_applied_from'),	'54');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('exchange_gain_loss'),	'55');

/*  Bug2680500 Deleted
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_exch_rate_diff_base'),	'56');
*/

  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('discount_remaining'),	'56');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('calc_discount_on_lines_flag'),	'57');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('partial_discount_flag'),	'58');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('allow_overapplication_flag'),	'59');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('natural_application_only_flag'),	'60');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('creation_sign'),	'61');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('applied_payment_schedule_id'),	'62');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('ussgl_transaction_code'),	'63');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('ussgl_transaction_code_context'),	'64');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('purchase_order'),	'65');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_doc_sequence_id'),	'66');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_doc_sequence_value'),	'67');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_batch_source_name'),	'68');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_adjusted'),	'69');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_adjusted_pending'),	'70');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('amount_line_items_remaining'),	'71');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('freight_original'),	'72');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('freight_remaining'),	'73');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('receivables_charges_remaining'),	'74');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('tax_original'),	'75');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('tax_remaining'),	'76');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('selected_for_receipt_batch_id'),	'77');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('receivable_application_id'),	'78');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute_category'),	'79');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute1'),	'80');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute2'),	'81');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute3'),	'82');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute4'),	'83');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute5'),	'84');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute6'),	'85');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute7'),	'86');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute8'),	'87');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute9'),	'88');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute10'),	'89');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute11'),	'90');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute12'),	'91');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute13'),	'92');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute14'),	'93');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('attribute15'),	'94');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_billing_number'),	'95');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute_category'),	'96');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute1'),	'97');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute2'),	'98');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute3'),	'99');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute4'),	'100');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute5'),	'101');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute6'),	'102');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute7'),	'103');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute8'),	'104');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute9'),	'105');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute10'),	'106');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute11'),	'107');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute12'),	'108');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute13'),	'109');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute14'),	'110');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute15'),	'111');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute16'),	'112');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute17'),	'113');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute18'),	'114');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute19'),	'115');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('global_attribute20'),	'116');
  -- bug3098721
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('transaction_category'),	'117');
  L_ORDER_BY :=REPLACE(UPPER(L_ORDER_BY),	UPPER('trx_gl_date'),	'118');

  return (L_ORDER_BY);

END;

/*===========================================================================+
 | PROCEDURE
 |      ON_SELECT
 |
 | DESCRIPTION
 |
 |      This procedure opens and executes the appropriate cursor.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  : IN:
 |
 |             OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |      25-AUG-97  Joan Zaman   Created.
 |      08-JAN-98  Karen Murphy See list of changes at the package level.
 |      14-MAY-98  Guat Eng Tan Bug #655455. Added p_trx_bill_number_find
 |                              parameter to on_select procedure. Added
 |                              code to include the billing number restriction
 |                              when selecting for open invoices.
 |     24-Aug-01  H Yoshihara   Bug 1930411: add p_related_cust_flag
 |                              argument to ON_SELECT procedure.
 |
 +===========================================================================*/


PROCEDURE on_select (
                    p_select_type          VARCHAR2
                   ,p_apply_date           DATE
                   ,p_receipt_gl_date      DATE
                   ,p_customer_id          NUMBER
                   ,p_bill_to_site_use_id  NUMBER
                   ,p_receipt_currency     VARCHAR2
                   ,p_cm_customer_trx_id   NUMBER
                   ,p_trx_type_name_find   VARCHAR2
                   ,p_due_date_find        VARCHAR2
                   ,p_trx_date_find        VARCHAR2
                   ,p_amt_due_rem_find     VARCHAR2
                   ,p_trx_number_find      VARCHAR2
                   ,p_include_disputed     VARCHAR2
                   ,p_include_cross_curr   VARCHAR2
                   ,p_inv_class            VARCHAR2
                   ,p_chb_class            VARCHAR2
                   ,p_cm_class             VARCHAR2
                   ,p_dm_class             VARCHAR2
                   ,p_dep_class            VARCHAR2
                   ,p_status               VARCHAR2
                   ,p_order_by             VARCHAR2
                   ,p_trx_bill_number_find VARCHAR2
                   ,p_purchase_order_find  VARCHAR2 default NULL
                   ,p_transaction_category_find VARCHAR2 default NULL
                   ,p_br_class             VARCHAR2 default NULL /* 01-JUN-2000 J Rautiainen BR Implementation */
		   ,p_related_cust_flag    VARCHAR2 /* bug1930411 */
) IS

open_trx_lng            long;
on_acct_lng             long;
cm_apps_lng             long;

ignore                  number;

l_trx_number_find       VARCHAR2(100);
l_trx_bill_number_find  VARCHAR2(100);
l_trx_type_name_find    VARCHAR2(100);
l_due_date_find         VARCHAR2(200);
l_trx_date_find         VARCHAR2(200);
l_amt_due_rem_find      VARCHAR2(100);
l_purchase_order_find   VARCHAR2(200);
l_transaction_category_find VARCHAR2(200);

l_cm_cust_trx_where     VARCHAR2(100);    -- Added for bug1821585

l_order_by              VARCHAR2(2000);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'on_select()+' );
  END IF;

  --
  -- Open Transactions:
  -- Returns all of the unapplied transations for a specified
  -- customer and selection criteria.
  --
  -- The select statement has been optimized to query with customer_id
  -- (class index has been disabled on purpose).
  -- CBO optimizations are done for best performance.
  --
  -- Bug 2113440 :
  -- 1) modify Hints for Indexes : replace ra_batch_sources_u1 with ra_batch_sources_u2
  --                               replace ra_terms_u1 with ra_terms_b_u1
  -- 2) use ra_terms_b instead of ra_terms

  open_trx_lng := '
  SELECT
  /*+
   FIRST_ROWS
   INDEX(ps_inv AR_PAYMENT_SCHEDULES_N6)
   INDEX(cust hz_cust_accounts_u1)
   INDEX(bs ra_batch_sources_u2)
   INDEX(ctt ra_cust_trx_types_u1)
   INDEX(rcr hz_cust_acct_relate_n1)
   INDEX(su hz_cust_site_uses_u1)
   INDEX(t ra_terms_b_u1)
   USE_NL(ps_inv)
   USE_NL(ct)
   USE_NL(ctt)
   USE_NL(cust)
   USE_NL(su)
   USE_NL(bs)
   USE_NL(t)
   USE_NL(ci)
   USE_NL(l_class)
   PUSH_SUBQ ORDERED */
    ps_inv.rowid                                row_id
  , -1                                          cash_receipt_id
  , ps_inv.customer_trx_id                      customer_trx_id
  , NULL                                        cm_customer_trx_id
  , ps_inv.last_update_date                     last_update_date
  , ps_inv.last_updated_by                      last_updated_by
  , ps_inv.creation_date                        creation_date
  , ps_inv.created_by                           created_by
  , ps_inv.last_update_login                    last_update_login
  , ps_inv.program_application_id               program_application_id
  , ps_inv.program_id                           program_id
  , ps_inv.program_update_date                  program_update_date
  , ps_inv.request_id                           request_id
  , NULL                                        receipt_number
  , ''n''                                       applied_flag
  , ps_inv.customer_id                          customer_id
  , substrb(party.party_name,1, 50)             customer_name
  , cust.account_number                         customer_number
  , ps_inv.trx_number                           trx_number
  , ps_inv.terms_sequence_number                installment
  , NULL                                        amount_applied
  , NULL     					amount_applied_from
  , NULL                   			trans_to_receipt_rate
  , NULL                                        discount
  , NULL 					discounts_earned
  , NULL 					discounts_unearned
  , ps_inv.discount_taken_earned 		discount_taken_earned
  , ps_inv.discount_taken_unearned 		discount_taken_unearned
  , ps_inv.amount_due_remaining                 amount_due_remaining
  , ps_inv.due_date                             due_date
  , ps_inv.status                               status
  , ps_inv.term_id                              term_id
  , l_class.meaning                             trx_class_name
  , ps_inv.class                                trx_class_code
  , ctt.name                                    trx_type_name
  , ctt.cust_trx_type_id                        cust_trx_type_id
  , ct.trx_date                                 trx_date
  , su.location                                 location_name
  , ps_inv.customer_site_use_id                 bill_to_site_use_id
  , NULL                                        days_late
  , NULL                                        line_number
  , NULL                                        customer_trx_line_id
  , :p_apply_date                               apply_date
  , arp_view_constants.get_default_gl_date(
    greatest(ps_inv.gl_date,
             :p_receipt_gl_date,
             DECODE(NVL(:l_app_gl_date_default, ''INV_REC_DT''),
                    ''INV_REC_SYS_DT'', sysdate,
                    ''INV_REC_DT'', ps_inv.gl_date,
                    ps_inv.gl_date)))           gl_date
  , NULL					gl_posted_date
  , NULL					reversal_gl_date
  , ps_inv.exchange_rate			exchange_rate
  , ps_inv.invoice_currency_code		invoice_currency_code
  , ps_inv.amount_due_original			amount_due_original
  , ps_inv.amount_in_dispute			amount_in_dispute
  , ps_inv.amount_line_items_original           amount_line_items_original
  , ps_inv.acctd_amount_due_remaining           acctd_amount_due_remaining
  , NULL                          		acctd_amount_applied_to
  , NULL                          		acctd_amount_applied_from
  , NULL    					exchange_gain_loss
  , ps_inv.discount_remaining                   discount_remaining
  , t.calc_discount_on_lines_flag               calc_discount_on_lines_flag
  , t.partial_discount_flag                     partial_discount_flag
  , ctt.allow_overapplication_flag              allow_overapplication_flag
  , ctt.natural_application_only_flag           natural_application_only_flag
  , ctt.creation_sign                           creation_sign
  , ps_inv.payment_schedule_id                  applied_payment_schedule_id
  , ct.default_ussgl_transaction_code           ussgl_transaction_code
  , ct.default_ussgl_trx_code_context           ussgl_transaction_code_context
  , ct.purchase_order    			purchase_order
  , ct.doc_sequence_id                          trx_doc_sequence_id
  , ct.doc_sequence_value                       trx_doc_sequence_value
  , bs.name                                     trx_batch_source_name
  , ps_inv.amount_adjusted                      amount_adjusted
  , ps_inv.amount_adjusted_pending              amount_adjusted_pending
  , ps_inv.amount_line_items_remaining          amount_line_items_remaining
  , ps_inv.freight_original                     freight_original
  , ps_inv.freight_remaining                    freight_remaining
  , ps_inv.receivables_charges_remaining        receivables_charges_remaining
  , ps_inv.tax_original                         tax_original
  , ps_inv.tax_remaining                        tax_remaining
  , ps_inv.selected_for_receipt_batch_id        selected_for_receipt_batch_id
  , NULL                                        receivable_application_id
  , NULL                                        attribute_category
  , NULL                                        attribute1
  , NULL                                        attribute2
  , NULL                                        attribute3
  , NULL                                        attribute4
  , NULL                                        attribute5
  , NULL                                        attribute6
  , NULL                                        attribute7
  , NULL                                        attribute8
  , NULL                                        attribute9
  , NULL                                        attribute10
  , NULL                                        attribute11
  , NULL                                        attribute12
  , NULL                                        attribute13
  , NULL                                        attribute14
  , NULL                                        attribute15
  , ci.cons_billing_number                      trx_billing_number
  , NULL      					global_attribute_CATEGORY
  , NULL      					global_attribute1
  , NULL      					global_attribute2
  , NULL      					global_attribute3
  , NULL      					global_attribute4
  , NULL      					global_attribute5
  , NULL      					global_attribute6
  , NULL      					global_attribute7
  , NULL      					global_attribute8
  , NULL      					global_attribute9
  , NULL      					global_attribute10
  , NULL      					global_attribute11
  , NULL      					global_attribute12
  , NULL     					global_attribute13
  , NULL      					global_attribute14
  , NULL      					global_attribute15
  , NULL      					global_attribute16
  , NULL      					global_attribute17
  , NULL      					global_attribute18
  , NULL      					global_attribute19
  , NULL      					global_attribute20
  , ctt.attribute10                             transaction_category -- ARTA
  , ps_inv.gl_date                              trx_gl_date
  FROM
    ar_payment_schedules        ps_inv
  , ra_customer_trx             ct
  , ra_cust_trx_types           ctt
  , hz_cust_accounts            cust
  , hz_parties			party
  , hz_cust_site_uses           su
  , ra_batch_sources            bs
  , ra_terms_b                  t
  , ar_cons_inv                 ci
  , ar_lookups                  l_class
  WHERE ps_inv.selected_for_receipt_batch_id IS NULL
  /* 08-JUL-2000 J Rautiainen BR Implementation */
  AND ps_inv.reserved_type  IS NULL
  AND ps_inv.reserved_value IS NULL
  AND ps_inv.class||''''                NOT IN(''GUAR'',''PMT'')
  AND ps_inv.class              = l_class.lookup_code
  AND l_class.lookup_type       = ''INV/CM''
  AND ps_inv.customer_trx_id    = ct.customer_trx_id
  AND ps_inv.customer_site_use_id = nvl(:p_bill_to_site_use_id, ps_inv.customer_site_use_id)
  AND ps_inv.status             = ''OP''
  AND bs.batch_source_id        = ct.batch_source_id
  AND ps_inv.cust_trx_type_id   = ctt.cust_trx_type_id
  AND ps_inv.customer_id        = cust.cust_account_id
  AND cust.party_id             = party.party_id
  AND ps_inv.customer_site_use_id= su.site_use_id
  AND ci.cons_inv_id(+)         = ps_inv.cons_inv_id
  -- Term id for credit memos is null
  AND ps_inv.term_id            = t.term_id(+)
  AND ps_inv.customer_id IN
         (SELECT rcr.RELATED_CUST_ACCOUNT_ID
          FROM   hz_cust_acct_relate RCR
          WHERE  RCR.CUST_ACCOUNT_ID = :p_customer_id
          AND    RCR.STATUS=''A''
          AND    RCR.BILL_TO_FLAG=''Y''
          -- bug1930411 add flag whether or not related customers are selected
          AND    :p_related_cust_flag = ''Y''
          UNION
          SELECT :p_customer_id
          FROM SYS.DUAL)
  AND ps_inv.invoice_currency_code =
                                     decode(:p_include_cross_curr,''Y'',
                                            ps_inv.invoice_currency_code
                                           ,:p_receipt_currency)
  AND ps_inv.status = NVL(:p_status,ps_inv.status)
  /* 01-JUN-2000 J Rautiainen BR Implementation
   * Added BR class */
  AND ps_inv.class NOT IN (nvl(:p_inv_class,''XX''),nvl(:p_chb_class,''XX''),
                           nvl(:p_dep_class,''XX''),nvl(:p_cm_class,''XX''),
                           nvl(:p_dm_class,''XX''), nvl(:p_br_class,''XX''))
  AND NVL(ps_inv.amount_in_dispute,0) =  DECODE ( :p_include_disputed
                                                , ''N'' , 0
                                                , NVL(ps_inv.amount_in_dispute,0) )
  ';

  --
  -- On Account Row:
  -- Returns single "On Account" row from payment schedules.  This is
  -- returned as the last row in Mass Apply and Preview.
  --
  on_acct_lng := '
  -- This select statement will get one row (On-Account)
  SELECT
    ps_inv.rowid                                row_id
  , -1                                          cash_receipt_id
  , ps_inv.customer_trx_id                      customer_trx_id
  , ps_inv.last_update_date                     last_update_date
  , ps_inv.last_updated_by                      last_updated_by
  , ps_inv.creation_date                        creation_date
  , ps_inv.created_by                           created_by
  , ps_inv.last_update_login                    last_update_login
  , ps_inv.program_application_id               program_application_id
  , ps_inv.program_id                           program_id
  , ps_inv.program_update_date                  program_update_date
  , ps_inv.request_id                           request_id
  , ''n''                                       applied_flag
  , -1                                          customer_id
  , ps_inv.trx_number                           trx_number
  , 0                                           discounts_earned
  , 0                                           discounts_unearned
  , 0						discount_taken_earned
  , 0						discount_taken_unearned
  , ps_inv.amount_due_remaining                 amount_due_remaining
  , ps_inv.status                               status
  , ps_inv.term_id                              term_id
  , -1                                          bill_to_site_use_id
  , arp_view_constants.get_apply_date           apply_date
  , arp_view_constants.get_default_gl_date(
     greatest(ps_inv.gl_date,
              :p_receipt_gl_date,
             DECODE(NVL(:l_app_gl_date_default, ''INV_REC_DT''),
                    ''INV_REC_SYS_DT'', sysdate,
                    ''INV_REC_DT'', ps_inv.gl_date,
                    ps_inv.gl_date)))           gl_date
  , :p_receipt_currency                         invoice_currency_code
  , ps_inv.amount_due_original                  amount_due_original
  , ps_inv.amount_in_dispute                    amount_in_dispute
  , ps_inv.amount_line_items_original           amount_line_items_original
  , ps_inv.discount_remaining                   discount_remaining
  , ps_inv.payment_schedule_id                  applied_payment_schedule_id
  FROM
    ar_payment_schedules                ps_inv
  WHERE
    ps_inv.payment_schedule_id  = -1
  ';

  --
  -- On Account Credit Memo Applications:
  -- Returns all of the existing applications for an On Account Credit Memo.
  -- These are viewed through the Transaction Workbench.
  --
/* Start of bug fix 1821585.
Dynamic query building:
If the user passes the customer_trx_id,then append the where clause with
this filter.Else, don't append.
If the cust_trx_id is provided, the index on it will be used by query,
thus improving the performance.
*/

IF p_cm_customer_trx_id IS NOT NULL THEN
    l_cm_cust_trx_where := 'AND ps_cm.customer_trx_id = :p_cm_customer_trx_id
';
ELSE
    l_cm_cust_trx_where := NULL;
END IF;

  --Fixed bug 767029 by adding hints USE_NL

  cm_apps_lng := '
  SELECT
  /*+
   INDEX(app AR_RECEIVABLE_APPLICATIONS_N8 AR_RECEIVABLE_APPLICATIONS_N2)
   INDEX(ps_inv ar_payment_schedules_u1 ar_payment_schedules_n2 ar_payment_schedules_n6)
   INDEX(ps_cm ar_payment_schedules_n2)
   INDEX(cust hz_cust_accounts_u1)
   INDEX(ct ra_customer_trx_u1)
   INDEX(bs ra_batch_sources_u2)
   INDEX(ctt ra_cust_trx_types_u1)
   INDEX(su hz_cust_site_uses_u1)
   INDEX(t ra_terms_u1)
   USE_NL(ps_cm)
   USE_NL(app)
   USE_NL(ps_inv)
   USE_NL(cust)
   USE_NL(ct)
   USE_NL(ctl)
   USE_NL(bs)
   USE_NL(su)
   USE_NL(ci)
   USE_NL(l_class)
   ORDERED PUSH_SUBQ */
    app.rowid                                   row_id
  , -2                                          cash_receipt_id
  , ps_inv.customer_trx_id                      customer_trx_id
  , ps_cm.customer_trx_id                       cm_customer_trx_id
  , app.last_update_date                        last_update_date
  , app.last_updated_by                         last_updated_by
  , app.creation_date                           creation_date
  , app.created_by                              created_by
  , app.last_update_login                       last_update_login
  , app.program_application_id                  program_application_id
  , app.program_id                              program_id
  , app.program_update_date                     program_update_date
  , app.request_id                              request_id
  , ps_cm.trx_number                            receipt_number
  , ''Y''                                       applied_flag
  , ps_inv.customer_id                          customer_id
  , substrb(party.party_name,1,50)              customer_name
  , cust.account_number                         customer_number
  , ps_inv.trx_number                           trx_number
  , DECODE(SIGN(ps_inv.payment_schedule_id),-1,NULL,ps_inv.terms_sequence_number)                				installment
  , app.amount_applied                          amount_applied
  , app.amount_applied				amount_applied_from
  , NULL                   			trans_to_receipt_rate
  , NULL                                        discount
  , NULL 					discounts_earned
  , NULL 					discounts_unearned
  , ps_inv.discount_taken_earned 		discount_taken_earned
  , ps_inv.discount_taken_unearned 		discount_taken_unearned
  , TO_NUMBER(DECODE(SIGN(ps_inv.payment_schedule_id),-1,NULL,ps_inv.amount_due_remaining))                 			amount_due_remaining
  , DECODE(SIGN(ps_inv.payment_schedule_id),-1,TO_DATE(NULL), ps_inv.due_date)                            			due_date
  , ps_inv.status                               status
  , ps_inv.term_id                              term_id
--  , l_class.meaning                             trx_class_name
  , DECODE(SIGN(ps_inv.payment_schedule_id),-1,NULL, arpt_sql_func_util.get_lookup_meaning(''INV/CM'', ps_inv.CLASS))		trx_class_name
  , ps_inv.class                                trx_class_code
  , ctt.name                                    trx_type_name
  , ctt.cust_trx_type_id                        cust_trx_type_id
  , ct.trx_date                                 trx_date
  , su.location                                 location_name
  , ct.bill_to_site_use_id                      bill_to_site_use_id
  , DECODE(SIGN(ps_inv.payment_schedule_id),-1,NULL,to_number(app.apply_date-TRUNC(ps_inv.due_date)))   			days_late
  , ctl.line_number                             line_number
  , ctl.customer_trx_line_id                    customer_trx_line_id
  , app.apply_date                              apply_date
  , app.gl_date                                 gl_date
  , app.gl_posted_date                          gl_posted_date
  , app.reversal_gl_date                        reversal_gl_date
  , ps_inv.exchange_rate                        exchange_rate
  , DECODE(SIGN(ps_inv.payment_schedule_id),-1,ps_cm.invoice_currency_code, ps_inv.invoice_currency_code)			invoice_currency_code
  , ps_inv.amount_due_original                  amount_due_original
  , ps_inv.amount_in_dispute                    amount_in_dispute
  , ps_inv.amount_line_items_original           amount_line_items_original
  , TO_NUMBER(DECODE(SIGN(ps_inv.payment_schedule_id),-1,NULL, ps_inv.acctd_amount_due_remaining))				acctd_amount_due_remaining
  , app.acctd_amount_applied_to        		acctd_amount_applied_to
  , app.acctd_amount_applied_from              	acctd_amount_applied_from
  , app.acctd_amount_applied_from
    - NVL(app.acctd_amount_applied_to,app.acctd_amount_applied_from)
                                                exchange_gain_loss
  , ps_inv.discount_remaining                   discount_remaining
  , t.calc_discount_on_lines_flag               calc_discount_on_lines_flag
  , t.partial_discount_flag                     partial_discount_flag
  , ctt.allow_overapplication_flag              allow_overapplication_flag
  , ctt.natural_application_only_flag           natural_application_only_flag
  , ctt.creation_sign                           creation_sign
  , ps_inv.payment_schedule_id                  applied_payment_schedule_id
  , app.ussgl_transaction_code                  ussgl_transaction_code
  , app.ussgl_transaction_code_context          ussgl_transaction_code_context
  , ct.purchase_order    			purchase_order
  , ct.doc_sequence_id                          trx_doc_sequence_id
  , ct.doc_sequence_value                       trx_doc_sequence_value
  , bs.name                                     trx_batch_source_name
  , ps_inv.amount_adjusted                      amount_adjusted
  , ps_inv.amount_adjusted_pending              amount_adjusted_pending
  , ps_inv.amount_line_items_remaining          amount_line_items_remaining
  , ps_inv.freight_original                     freight_original
  , ps_inv.freight_remaining                    freight_remaining
  , ps_inv.receivables_charges_remaining        receivables_charges_remaining
  , ps_inv.tax_original                         tax_original
  , ps_inv.tax_remaining                        tax_remaining
  , ps_inv.selected_for_receipt_batch_id        selected_for_receipt_batch_id
  , app.receivable_application_id               receivable_application_id
  , app.attribute_category                      attribute_category
  , app.attribute1                              attribute1
  , app.attribute2                              attribute2
  , app.attribute3                              attribute3
  , app.attribute4                              attribute4
  , app.attribute5                              attribute5
  , app.attribute6                              attribute6
  , app.attribute7                              attribute7
  , app.attribute8                              attribute8
  , app.attribute9                              attribute9
  , app.attribute10                             attribute10
  , app.attribute11                             attribute11
  , app.attribute12                             attribute12
  , app.attribute13                             attribute13
  , app.attribute14                             attribute14
  , app.attribute15                             attribute15
  , ci.cons_billing_number                      trx_billing_number
  , app.global_attribute_category 		global_attribute_CATEGORY
  , app.global_attribute1 			global_attribute1
  , app.global_attribute2 			global_attribute2
  , app.global_attribute3 			global_attribute3
  , app.global_attribute4 			global_attribute4
  , app.global_attribute5 			global_attribute5
  , app.global_attribute6 			global_attribute6
  , app.global_attribute7 			global_attribute7
  , app.global_attribute8 			global_attribute8
  , app.global_attribute9 			global_attribute9
  , app.global_attribute10 			global_attribute10
  , app.global_attribute11 			global_attribute11
  , app.global_attribute12 			global_attribute12
  , app.global_attribute13 			global_attribute13
  , app.global_attribute14 			global_attribute14
  , app.global_attribute15 			global_attribute15
  , app.global_attribute16 			global_attribute16
  , app.global_attribute17 			global_attribute17
  , app.global_attribute18 			global_attribute18
  , app.global_attribute19 			global_attribute19
  , app.global_attribute20 			global_attribute20
  , ctt.attribute10                             transaction_category -- ARTA
  , ps_cm.gl_date                               trx_gl_date
  , app.comments                               comments -- bug 2662270
  , app.receivables_trx_id			receivables_trx_id -- cm refunds
  , rt.name					rec_activity_name
  , app.application_ref_id			application_ref_id
  , app.application_ref_num			application_ref_num
  , app.application_ref_type			application_ref_type
  , arpt_sql_func_util.get_lookup_meaning(''APPLICATION_REF_TYPE'', app.application_ref_type) application_ref_type_meaning
  FROM
    ar_payment_schedules        ps_cm
  , ar_receivable_applications  app
  , ar_payment_schedules        ps_inv
  , hz_cust_accounts 		cust
  , hz_parties			party
  , ra_customer_trx             ct
  , ra_customer_trx_lines       ctl
  , ra_batch_sources            bs
  , ar_receivables_trx          rt
  , ra_cust_trx_types           ctt
  , hz_cust_site_uses           su
  , ar_cons_inv                 ci
--  , ar_lookups                  l_class
  , ra_terms                    t
  WHERE
      app.applied_payment_schedule_id = ps_inv.payment_schedule_id
  AND app.display               = ''Y''
  -- This means we only get CM applications. We use index :)
  AND app.customer_trx_id       > -1
  AND app.customer_trx_id       = ps_cm.customer_trx_id
  AND t.term_id(+)              = ps_inv.term_id
  AND ct.customer_trx_id(+)     = ps_inv.customer_trx_id
  AND bs.batch_source_id (+)    = ct.batch_source_id
  AND ctt.cust_trx_type_id(+)   = ps_inv.cust_trx_type_id
  AND cust.cust_account_id(+)   = ps_inv.customer_id
  AND cust.party_id 		= party.party_id(+)
  AND su.site_use_id(+)         = ct.bill_to_site_use_id
  AND ctl.customer_trx_line_id(+) = app.applied_customer_trx_line_id
--  AND ps_inv.class||''''        = l_class.lookup_code
--  AND l_class.lookup_type       = ''INV/CM''
  AND ci.cons_inv_id(+)         = ps_inv.cons_inv_id
  AND rt.receivables_trx_id(+)  = app.receivables_trx_id
  ' || l_cm_cust_trx_where ;

  l_order_by := p_order_by;

  IF l_order_by IS NOT NULL THEN
    l_order_by := ' ORDER BY ' || l_order_by ;
    l_order_by := CHANGE_ORDER_BY(l_order_by);
  END IF;

  ------------------------------------------------------------
  --
  -- Mass Applications
  --
  -- We are working with the Open Transactions and On Account
  -- cursors.  Open, parse and execute both cursors which
  -- will be used during fetching.
  --
  ------------------------------------------------------------
  IF p_select_type = 'MASSAPPLY' THEN

    --
    -- Before opening the cursor query, we need to incoroprate
    -- the query conditions (that were included in the Mass Apply
    -- window) in the cursor select.
    --
    -- The query conditions were passed to the procedure in the
    -- following variables.
    --

    l_trx_number_find := p_trx_number_find;
    l_trx_bill_number_find := p_trx_bill_number_find;
    l_trx_type_name_find := p_trx_type_name_find;
    l_due_date_find := p_due_date_find;
    l_trx_date_find := p_trx_date_find;
    l_amt_due_rem_find := p_amt_due_rem_find;
    l_purchase_order_find := p_purchase_order_find;
    l_transaction_category_find := p_transaction_category_find;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'p_trx_number_find =>'||p_trx_number_find );
       arp_standard.debug(   'p_trx_type_name_find =>'||p_trx_type_name_find );
       arp_standard.debug(   'p_due_date_find =>'||p_due_date_find );
       arp_standard.debug(   'p_trx_date_find =>'||p_trx_date_find );
       arp_standard.debug(   'p_amt_due_rem_find =>'||p_amt_due_rem_find);
    END IF;


    IF l_trx_number_find IS NOT NULL THEN
             IF  INSTR(l_trx_number_find,'#') = 0 THEN
    -- 11/09/2000 mramanat Bugfix 1477745. Find Criteria does not work properly
    -- in the Mass Apply Window for Trx Number.
                l_trx_number_find := ' # LIKE '||''''||l_trx_number_find||'''';
             END IF;

      l_trx_number_find := ' AND ' || l_trx_number_find;
      l_trx_number_find := REPLACE(l_trx_number_find,'#','ps_inv.trx_number');
    END IF;


    -- gtan temp
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'about to enter l_trx_bill_number_find ');
    END IF;

    IF l_trx_bill_number_find IS NOT NULL THEN
         IF  INSTR(l_trx_bill_number_find,'#') = 0 THEN
                 l_trx_bill_number_find := ' # BETWEEN '||''''||l_trx_bill_number_find||''''||' AND '||'''' ||l_trx_bill_number_find||'''';
         END IF;

      l_trx_bill_number_find := ' AND ' || l_trx_bill_number_find;
      l_trx_bill_number_find := REPLACE(l_trx_bill_number_find,'#','ci.cons_billing_number');
    END IF;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(  l_trx_bill_number_find);
END IF;

    -- gtan temp
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'about to leave l_trx_bill_number_find ');
    END IF;

    IF l_trx_type_name_find IS NOT NULL THEN
        IF  INSTR(l_trx_type_name_find,'#') = 0 THEN
            l_trx_type_name_find := ' # BETWEEN '||''''||l_trx_type_name_find||''''||' AND '||''''||l_trx_type_name_find||'''';
        END IF;

      l_trx_type_name_find := ' AND ' ||l_trx_type_name_find;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(  l_trx_type_name_find );
END IF;
      l_trx_type_name_find := REPLACE(l_trx_type_name_find,'#','ctt.name');
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(  l_trx_type_name_find );
END IF;
    END IF;

    IF l_due_date_find IS NOT NULL THEN
      l_due_date_find := ' AND ' ||l_due_date_find;
      l_due_date_find := REPLACE(l_due_date_find,'#','ps_inv.due_date');
    END IF;

    IF l_trx_date_find IS NOT NULL THEN
      l_trx_date_find :=  ' AND ' ||l_trx_date_find;
      l_trx_date_find := REPLACE(l_trx_date_find,'#','ct.trx_date');
    END IF;

    IF l_amt_due_rem_find IS NOT NULL THEN
         IF  INSTR(l_amt_due_rem_find,'#') = 0 THEN
            l_amt_due_rem_find := ' # BETWEEN '||''''||l_amt_due_rem_find||''''||' AND '||''''||l_amt_due_rem_find||'''';
        END IF;

      l_amt_due_rem_find :=  ' AND ' ||l_amt_due_rem_find;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  l_amt_due_rem_find);
 END IF;
      l_amt_due_rem_find := REPLACE(l_amt_due_rem_find,'#','ps_inv.amount_due_remaining');
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(  l_amt_due_rem_find);
END IF;
    END IF;

    -- ARTA Changes
    -- Bugfix 1572879. Find Criteria does not work properly in the Mass Apply Window for PO Number.
    IF l_purchase_order_find IS NOT NULL THEN
             IF  INSTR(l_purchase_order_find,'#') = 0 THEN
                l_purchase_order_find:= ' # LIKE '||''''||l_purchase_order_find||'''';
             END IF;
      l_purchase_order_find := 'AND '||l_purchase_order_find;
      l_purchase_order_find := REPLACE(l_purchase_order_find,'#','ct.purchase_order');
    END IF;

    IF l_transaction_category_find IS NOT NULL THEN
      l_transaction_category_find := 'AND '||l_transaction_category_find;
      l_transaction_category_find := REPLACE(l_transaction_category_find,'#',
                                             'ctt.attribute10');
    END IF;

    -- gtan temp
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'about to leave l_amt_due_rem_find ');
    END IF;
   -- ARTA Changes
   open_trx_lng := open_trx_lng  || l_trx_type_name_find
                                 || l_due_date_find
                                 || l_trx_date_find
                                 || l_amt_due_rem_find
                                 || l_trx_number_find
                                 || l_trx_bill_number_find
                                 || l_purchase_order_find
                                 || l_transaction_category_find
                                 || l_order_by;

    -- gtan temp
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'after open_trx_lng ');
    END IF;

    --
    -- Open, Parse and Execute the Open Transactions cursor.
    --

    c_open_trx := dbms_sql.open_cursor;

    -- gtan temp
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'after c_open_trx ');
    END IF;

    dbms_sql.parse(c_open_trx , open_trx_lng , dbms_sql.v7 );
    -- gtan temp
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'after parse c_open_trx ');
    END IF;

    dbms_sql.bind_variable(c_open_trx ,':p_apply_date' , p_apply_date );
    dbms_sql.bind_variable(c_open_trx ,':p_receipt_gl_date' , p_receipt_gl_date );
    dbms_sql.bind_variable(c_open_trx ,':l_app_gl_date_default' , l_app_gl_date_default );
    dbms_sql.bind_variable(c_open_trx ,':p_customer_id' , p_customer_id );
    dbms_sql.bind_variable(c_open_trx ,':p_bill_to_site_use_id' , p_bill_to_site_use_id );
    dbms_sql.bind_variable(c_open_trx ,':p_receipt_currency' , p_receipt_currency );
    dbms_sql.bind_variable(c_open_trx ,':p_inv_class', p_inv_class);
    dbms_sql.bind_variable(c_open_trx ,':p_chb_class', p_chb_class);
    dbms_sql.bind_variable(c_open_trx ,':p_dep_class', p_dep_class);
    dbms_sql.bind_variable(c_open_trx ,':p_cm_class', p_cm_class);
    dbms_sql.bind_variable(c_open_trx ,':p_dm_class', p_dm_class);
    /* 01-JUN-2000 J Rautiainen BR Implementation */
    dbms_sql.bind_variable(c_open_trx ,':p_br_class', p_br_class);
    dbms_sql.bind_variable(c_open_trx ,':p_include_disputed', p_include_disputed);
    dbms_sql.bind_variable(c_open_trx ,':p_include_cross_curr', p_include_cross_curr);
    dbms_sql.bind_variable(c_open_trx ,':p_status', p_status);
    -- bug1930411
    dbms_sql.bind_variable(c_open_trx ,':p_related_cust_flag', p_related_cust_flag);

    dbms_sql.define_column_rowid(c_open_trx,1,open_trx_row.row_id);
    dbms_sql.define_column(c_open_trx,2,open_trx_row.cash_receipt_id);
    dbms_sql.define_column(c_open_trx,3,open_trx_row.customer_trx_id);
    dbms_sql.define_column(c_open_trx,4,open_trx_row.cm_customer_trx_id);
    dbms_sql.define_column(c_open_trx,5,open_trx_row.last_update_date);
    dbms_sql.define_column(c_open_trx,6,open_trx_row.last_updated_by);
    dbms_sql.define_column(c_open_trx,7,open_trx_row.creation_date);
    dbms_sql.define_column(c_open_trx,8,open_trx_row.created_by);
    dbms_sql.define_column(c_open_trx,9,open_trx_row.last_update_login);
    dbms_sql.define_column(c_open_trx,10,open_trx_row.program_application_id);
    dbms_sql.define_column(c_open_trx,11,open_trx_row.program_id);
    dbms_sql.define_column(c_open_trx,12,open_trx_row.program_update_date);
    dbms_sql.define_column(c_open_trx,13,open_trx_row.request_id);
    dbms_sql.define_column(c_open_trx,14,open_trx_row.receipt_number,100);
    dbms_sql.define_column(c_open_trx,15,open_trx_row.applied_flag,100);
    dbms_sql.define_column(c_open_trx,16,open_trx_row.customer_id);
    dbms_sql.define_column(c_open_trx,17,open_trx_row.customer_name,100);
    dbms_sql.define_column(c_open_trx,18,open_trx_row.customer_number,100);
    dbms_sql.define_column(c_open_trx,19,open_trx_row.trx_number,100);
    dbms_sql.define_column(c_open_trx,20,open_trx_row.installment);
    dbms_sql.define_column(c_open_trx,21,open_trx_row.amount_applied);
    dbms_sql.define_column(c_open_trx,22,open_trx_row.amount_applied_from);
    dbms_sql.define_column(c_open_trx,23,open_trx_row.trans_to_receipt_rate);
    dbms_sql.define_column(c_open_trx,24,open_trx_row.discount);
    dbms_sql.define_column(c_open_trx,25,open_trx_row.discounts_earned);
    dbms_sql.define_column(c_open_trx,26,open_trx_row.discounts_unearned);
    dbms_sql.define_column(c_open_trx,27,open_trx_row.discount_taken_earned);
    dbms_sql.define_column(c_open_trx,28,open_trx_row.discount_taken_unearned);
    dbms_sql.define_column(c_open_trx,29,open_trx_row.amount_due_remaining);
    dbms_sql.define_column(c_open_trx,30,open_trx_row.due_date);
    dbms_sql.define_column(c_open_trx,31,open_trx_row.status,100);
    dbms_sql.define_column(c_open_trx,32,open_trx_row.term_id);
    dbms_sql.define_column(c_open_trx,33,open_trx_row.trx_class_name,100);
    dbms_sql.define_column(c_open_trx,34,open_trx_row.trx_class_code,100);
    dbms_sql.define_column(c_open_trx,35,open_trx_row.trx_type_name,100);
    dbms_sql.define_column(c_open_trx,36,open_trx_row.cust_trx_type_id);
    dbms_sql.define_column(c_open_trx,37,open_trx_row.trx_date);
    dbms_sql.define_column(c_open_trx,38,open_trx_row.location_name,100);
    dbms_sql.define_column(c_open_trx,39,open_trx_row.bill_to_site_use_id);
    dbms_sql.define_column(c_open_trx,40,open_trx_row.days_late);
    dbms_sql.define_column(c_open_trx,41,open_trx_row.line_number);
    dbms_sql.define_column(c_open_trx,42,open_trx_row.customer_trx_line_id);
    dbms_sql.define_column(c_open_trx,43,open_trx_row.apply_date);
    dbms_sql.define_column(c_open_trx,44,open_trx_row.gl_date);
    dbms_sql.define_column(c_open_trx,45,open_trx_row.gl_posted_date);
    dbms_sql.define_column(c_open_trx,46,open_trx_row.reversal_gl_date);
    dbms_sql.define_column(c_open_trx,47,open_trx_row.exchange_rate);
    dbms_sql.define_column(c_open_trx,48,open_trx_row.invoice_currency_code,15);
    dbms_sql.define_column(c_open_trx,49,open_trx_row.amount_due_original);
    dbms_sql.define_column(c_open_trx,50,open_trx_row.amount_in_dispute);
    dbms_sql.define_column(c_open_trx,51,open_trx_row.amount_line_items_original);
    dbms_sql.define_column(c_open_trx,52,open_trx_row.acctd_amount_due_remaining);
    dbms_sql.define_column(c_open_trx,53,open_trx_row.acctd_amount_applied_to);
    dbms_sql.define_column(c_open_trx,54,open_trx_row.acctd_amount_applied_from);
    dbms_sql.define_column(c_open_trx,55,open_trx_row.exchange_gain_loss);
    dbms_sql.define_column(c_open_trx,56,open_trx_row.discount_remaining);
    dbms_sql.define_column(c_open_trx,57,open_trx_row.calc_discount_on_lines_flag,100);
    dbms_sql.define_column(c_open_trx,58,open_trx_row.partial_discount_flag,100);
    dbms_sql.define_column(c_open_trx,59,open_trx_row.allow_overapplication_flag,100);
    dbms_sql.define_column(c_open_trx,60,open_trx_row.natural_application_only_flag,100);
    dbms_sql.define_column(c_open_trx,61,open_trx_row.creation_sign,100);
    dbms_sql.define_column(c_open_trx,62,open_trx_row.applied_payment_schedule_id);
    dbms_sql.define_column(c_open_trx,63,open_trx_row.ussgl_transaction_code,100);
    dbms_sql.define_column(c_open_trx,64,open_trx_row.ussgl_transaction_code_context,100);
    dbms_sql.define_column(c_open_trx,65,open_trx_row.purchase_order,50);
    dbms_sql.define_column(c_open_trx,66,open_trx_row.trx_doc_sequence_id);
    dbms_sql.define_column(c_open_trx,67,open_trx_row.trx_doc_sequence_value,100);
    dbms_sql.define_column(c_open_trx,68,open_trx_row.trx_batch_source_name,100);
    dbms_sql.define_column(c_open_trx,69,open_trx_row.amount_adjusted);
    dbms_sql.define_column(c_open_trx,70,open_trx_row.amount_adjusted_pending);
    dbms_sql.define_column(c_open_trx,71,open_trx_row.amount_line_items_remaining);
    dbms_sql.define_column(c_open_trx,72,open_trx_row.freight_original);
    dbms_sql.define_column(c_open_trx,73,open_trx_row.freight_remaining);
    dbms_sql.define_column(c_open_trx,74,open_trx_row.receivables_charges_remaining);
    dbms_sql.define_column(c_open_trx,75,open_trx_row.tax_original);
    dbms_sql.define_column(c_open_trx,76,open_trx_row.tax_remaining);
    dbms_sql.define_column(c_open_trx,77,open_trx_row.selected_for_receipt_batch_id);
    dbms_sql.define_column(c_open_trx,78,open_trx_row.receivable_application_id);
    dbms_sql.define_column(c_open_trx,79,open_trx_row.attribute_category,50);
    dbms_sql.define_column(c_open_trx,80,open_trx_row.attribute1,150);
    dbms_sql.define_column(c_open_trx,81,open_trx_row.attribute2,150);
    dbms_sql.define_column(c_open_trx,82,open_trx_row.attribute3,150);
    dbms_sql.define_column(c_open_trx,83,open_trx_row.attribute4,150);
    dbms_sql.define_column(c_open_trx,84,open_trx_row.attribute5,150);
    dbms_sql.define_column(c_open_trx,85,open_trx_row.attribute6,150);
    dbms_sql.define_column(c_open_trx,86,open_trx_row.attribute7,150);
    dbms_sql.define_column(c_open_trx,87,open_trx_row.attribute8,150);
    dbms_sql.define_column(c_open_trx,88,open_trx_row.attribute9,150);
    dbms_sql.define_column(c_open_trx,89,open_trx_row.attribute10,150);
    dbms_sql.define_column(c_open_trx,90,open_trx_row.attribute11,150);
    dbms_sql.define_column(c_open_trx,91,open_trx_row.attribute12,150);
    dbms_sql.define_column(c_open_trx,92,open_trx_row.attribute13,150);
    dbms_sql.define_column(c_open_trx,93,open_trx_row.attribute14,150);
    dbms_sql.define_column(c_open_trx,94,open_trx_row.attribute15,150);
    dbms_sql.define_column(c_open_trx,95,open_trx_row.trx_billing_number,30);
    dbms_sql.define_column(c_open_trx,96,open_trx_row.global_attribute_category,50);
    dbms_sql.define_column(c_open_trx,97,open_trx_row.global_attribute1,150);
    dbms_sql.define_column(c_open_trx,98,open_trx_row.global_attribute2,150);
    dbms_sql.define_column(c_open_trx,99,open_trx_row.global_attribute3,150);
    dbms_sql.define_column(c_open_trx,100,open_trx_row.global_attribute4,150);
    dbms_sql.define_column(c_open_trx,101,open_trx_row.global_attribute5,150);
    dbms_sql.define_column(c_open_trx,102,open_trx_row.global_attribute6,150);
    dbms_sql.define_column(c_open_trx,103,open_trx_row.global_attribute7,150);
    dbms_sql.define_column(c_open_trx,104,open_trx_row.global_attribute8,150);
    dbms_sql.define_column(c_open_trx,105,open_trx_row.global_attribute9,150);
    dbms_sql.define_column(c_open_trx,106,open_trx_row.global_attribute10,150);
    dbms_sql.define_column(c_open_trx,107,open_trx_row.global_attribute11,150);
    dbms_sql.define_column(c_open_trx,108,open_trx_row.global_attribute12,150);
    dbms_sql.define_column(c_open_trx,109,open_trx_row.global_attribute13,150);
    dbms_sql.define_column(c_open_trx,110,open_trx_row.global_attribute14,150);
    dbms_sql.define_column(c_open_trx,111,open_trx_row.global_attribute15,150);
    dbms_sql.define_column(c_open_trx,112,open_trx_row.global_attribute16,150);
    dbms_sql.define_column(c_open_trx,113,open_trx_row.global_attribute17,150);
    dbms_sql.define_column(c_open_trx,114,open_trx_row.global_attribute18,150);
    dbms_sql.define_column(c_open_trx,115,open_trx_row.global_attribute19,150);
    dbms_sql.define_column(c_open_trx,116,open_trx_row.global_attribute20,150);
    dbms_sql.define_column(c_open_trx,117,open_trx_row.transaction_category,150); -- AR TA change
    dbms_sql.define_column(c_open_trx,118,open_trx_row.trx_gl_date);

    ignore := dbms_sql.execute(c_open_trx);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'Open, Parsed and Executed c_open_trx' );
    END IF;

    --
    -- Open, Parse and Execute the On Account cursor.
    --
    on_acct_lng := on_acct_lng;

    c_on_acct := dbms_sql.open_cursor;

    dbms_sql.parse(c_on_acct , on_acct_lng , dbms_sql.v7 );

    dbms_sql.bind_variable(c_on_acct ,':p_receipt_gl_date' , p_receipt_gl_date );
    dbms_sql.bind_variable(c_on_acct ,':p_receipt_currency' , p_receipt_currency );


    dbms_sql.bind_variable(c_on_acct ,':l_app_gl_date_default' , l_app_gl_date_default );

    dbms_sql.define_column_rowid(c_on_acct,1,on_acct_row.row_id);
    dbms_sql.define_column(c_on_acct,2,on_acct_row.cash_receipt_id);
    dbms_sql.define_column(c_on_acct,3,on_acct_row.customer_trx_id);
    dbms_sql.define_column(c_on_acct,4,on_acct_row.last_update_date);
    dbms_sql.define_column(c_on_acct,5,on_acct_row.last_updated_by);
    dbms_sql.define_column(c_on_acct,6,on_acct_row.creation_date);
    dbms_sql.define_column(c_on_acct,7,on_acct_row.created_by);
    dbms_sql.define_column(c_on_acct,8,on_acct_row.last_update_login);
    dbms_sql.define_column(c_on_acct,9,on_acct_row.program_application_id);
    dbms_sql.define_column(c_on_acct,10,on_acct_row.program_id);
    dbms_sql.define_column(c_on_acct,11,on_acct_row.program_update_date);
    dbms_sql.define_column(c_on_acct,12,on_acct_row.request_id);
    dbms_sql.define_column(c_on_acct,13,on_acct_row.applied_flag,100);
    dbms_sql.define_column(c_on_acct,14,on_acct_row.customer_id);
    dbms_sql.define_column(c_on_acct,15,on_acct_row.trx_number,100);
    dbms_sql.define_column(c_on_acct,16,on_acct_row.discounts_earned);
    dbms_sql.define_column(c_on_acct,17,on_acct_row.discounts_unearned);
    dbms_sql.define_column(c_on_acct,18,on_acct_row.discount_taken_earned);
    dbms_sql.define_column(c_on_acct,19,on_acct_row.discount_taken_unearned);
    dbms_sql.define_column(c_on_acct,20,on_acct_row.amount_due_remaining);
    dbms_sql.define_column(c_on_acct,21,on_acct_row.status,100);
    dbms_sql.define_column(c_on_acct,22,on_acct_row.term_id);
    dbms_sql.define_column(c_on_acct,23,on_acct_row.bill_to_site_use_id);
    dbms_sql.define_column(c_on_acct,24,on_acct_row.apply_date);
    dbms_sql.define_column(c_on_acct,25,on_acct_row.gl_date);
    dbms_sql.define_column(c_on_acct,26,on_acct_row.invoice_currency_code,15);
    dbms_sql.define_column(c_on_acct,27,on_acct_row.amount_due_original);
    dbms_sql.define_column(c_on_acct,28,on_acct_row.amount_in_dispute);
    dbms_sql.define_column(c_on_acct,29,on_acct_row.amount_line_items_original);
    dbms_sql.define_column(c_on_acct,30,on_acct_row.discount_remaining);
    dbms_sql.define_column(c_on_acct,31,on_acct_row.applied_payment_schedule_id);

    ignore := dbms_sql.execute(c_on_acct);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'Open, Parsed and Executed c_on_acct' );
    END IF;

  -----------------------------------------------------
  --
  -- Credit Memo Applications
  --
  -- We are working with the Credit Memo Applications
  -- cursor.  Open, parse and execute the cursor which
  -- will be used during fetching.
  --
  -----------------------------------------------------
  ELSIF p_select_type = 'CM' THEN

    cm_apps_lng := cm_apps_lng || l_order_by;

    --
    -- Open, Parse and Execute the Credit Memo Applications cursor.
    --
    c_cm_apps := dbms_sql.open_cursor;

    dbms_sql.parse(c_cm_apps , cm_apps_lng , dbms_sql.v7 );
    IF p_cm_customer_trx_id IS NOT NULL THEN
        dbms_sql.bind_variable(c_cm_apps , ':p_cm_customer_trx_id' , p_cm_customer_trx_id);
    END IF;
    dbms_sql.define_column_rowid(c_cm_apps,1,cm_apps_row.row_id);
    dbms_sql.define_column(c_cm_apps,2,cm_apps_row.cash_receipt_id);
    dbms_sql.define_column(c_cm_apps,3,cm_apps_row.customer_trx_id);
    dbms_sql.define_column(c_cm_apps,4,cm_apps_row.cm_customer_trx_id);
    dbms_sql.define_column(c_cm_apps,5,cm_apps_row.last_update_date);
    dbms_sql.define_column(c_cm_apps,6,cm_apps_row.last_updated_by);
    dbms_sql.define_column(c_cm_apps,7,cm_apps_row.creation_date);
    dbms_sql.define_column(c_cm_apps,8,cm_apps_row.created_by);
    dbms_sql.define_column(c_cm_apps,9,cm_apps_row.last_update_login);
    dbms_sql.define_column(c_cm_apps,10,cm_apps_row.program_application_id);
    dbms_sql.define_column(c_cm_apps,11,cm_apps_row.program_id);
    dbms_sql.define_column(c_cm_apps,12,cm_apps_row.program_update_date);
    dbms_sql.define_column(c_cm_apps,13,cm_apps_row.request_id);
    dbms_sql.define_column(c_cm_apps,14,cm_apps_row.receipt_number,100);
    dbms_sql.define_column(c_cm_apps,15,cm_apps_row.applied_flag,100);
    dbms_sql.define_column(c_cm_apps,16,cm_apps_row.customer_id);
    dbms_sql.define_column(c_cm_apps,17,cm_apps_row.customer_name,100);
    dbms_sql.define_column(c_cm_apps,18,cm_apps_row.customer_number,100);
    dbms_sql.define_column(c_cm_apps,19,cm_apps_row.trx_number,100);
    dbms_sql.define_column(c_cm_apps,20,cm_apps_row.installment);
    dbms_sql.define_column(c_cm_apps,21,cm_apps_row.amount_applied);
    dbms_sql.define_column(c_cm_apps,22,cm_apps_row.amount_applied_from);
    dbms_sql.define_column(c_cm_apps,23,cm_apps_row.trans_to_receipt_rate);
    dbms_sql.define_column(c_cm_apps,24,cm_apps_row.discount);
    dbms_sql.define_column(c_cm_apps,25,cm_apps_row.discounts_earned);
    dbms_sql.define_column(c_cm_apps,26,cm_apps_row.discounts_unearned);
    dbms_sql.define_column(c_cm_apps,27,cm_apps_row.discount_taken_earned);
    dbms_sql.define_column(c_cm_apps,28,cm_apps_row.discount_taken_unearned);
    dbms_sql.define_column(c_cm_apps,29,cm_apps_row.amount_due_remaining);
    dbms_sql.define_column(c_cm_apps,30,cm_apps_row.due_date);
    dbms_sql.define_column(c_cm_apps,31,cm_apps_row.status,100);
    dbms_sql.define_column(c_cm_apps,32,cm_apps_row.term_id);
    dbms_sql.define_column(c_cm_apps,33,cm_apps_row.trx_class_name,100);
    dbms_sql.define_column(c_cm_apps,34,cm_apps_row.trx_class_code,100);
    dbms_sql.define_column(c_cm_apps,35,cm_apps_row.trx_type_name,100);
    dbms_sql.define_column(c_cm_apps,36,cm_apps_row.cust_trx_type_id);
    dbms_sql.define_column(c_cm_apps,37,cm_apps_row.trx_date);
    dbms_sql.define_column(c_cm_apps,38,cm_apps_row.location_name,100);
    dbms_sql.define_column(c_cm_apps,39,cm_apps_row.bill_to_site_use_id);
    dbms_sql.define_column(c_cm_apps,40,cm_apps_row.days_late);
    dbms_sql.define_column(c_cm_apps,41,cm_apps_row.line_number);
    dbms_sql.define_column(c_cm_apps,42,cm_apps_row.customer_trx_line_id);
    dbms_sql.define_column(c_cm_apps,43,cm_apps_row.apply_date);
    dbms_sql.define_column(c_cm_apps,44,cm_apps_row.gl_date);
    dbms_sql.define_column(c_cm_apps,45,cm_apps_row.gl_posted_date);
    dbms_sql.define_column(c_cm_apps,46,cm_apps_row.reversal_gl_date);
    dbms_sql.define_column(c_cm_apps,47,cm_apps_row.exchange_rate);
    dbms_sql.define_column(c_cm_apps,48,cm_apps_row.invoice_currency_code,15);
    dbms_sql.define_column(c_cm_apps,49,cm_apps_row.amount_due_original);
    dbms_sql.define_column(c_cm_apps,50,cm_apps_row.amount_in_dispute);
    dbms_sql.define_column(c_cm_apps,51,cm_apps_row.amount_line_items_original);
    dbms_sql.define_column(c_cm_apps,52,cm_apps_row.acctd_amount_due_remaining);
    dbms_sql.define_column(c_cm_apps,53,cm_apps_row.acctd_amount_applied_to);
    dbms_sql.define_column(c_cm_apps,54,cm_apps_row.acctd_amount_applied_from);
    dbms_sql.define_column(c_cm_apps,55,cm_apps_row.exchange_gain_loss);
    dbms_sql.define_column(c_cm_apps,56,cm_apps_row.discount_remaining);
    dbms_sql.define_column(c_cm_apps,57,cm_apps_row.calc_discount_on_lines_flag,100);
    dbms_sql.define_column(c_cm_apps,58,cm_apps_row.partial_discount_flag,100);
    dbms_sql.define_column(c_cm_apps,59,cm_apps_row.allow_overapplication_flag,100);
    dbms_sql.define_column(c_cm_apps,60,cm_apps_row.natural_application_only_flag,100);
    dbms_sql.define_column(c_cm_apps,61,cm_apps_row.creation_sign,100);
    dbms_sql.define_column(c_cm_apps,62,cm_apps_row.applied_payment_schedule_id);
    dbms_sql.define_column(c_cm_apps,63,cm_apps_row.ussgl_transaction_code,100);
    dbms_sql.define_column(c_cm_apps,64,cm_apps_row.ussgl_transaction_code_context,100);
    dbms_sql.define_column(c_cm_apps,65,cm_apps_row.purchase_order,50);
    dbms_sql.define_column(c_cm_apps,66,cm_apps_row.trx_doc_sequence_id);
    dbms_sql.define_column(c_cm_apps,67,cm_apps_row.trx_doc_sequence_value,100);
    dbms_sql.define_column(c_cm_apps,68,cm_apps_row.trx_batch_source_name,100);
    dbms_sql.define_column(c_cm_apps,69,cm_apps_row.amount_adjusted);
    dbms_sql.define_column(c_cm_apps,70,cm_apps_row.amount_adjusted_pending);
    dbms_sql.define_column(c_cm_apps,71,cm_apps_row.amount_line_items_remaining);
    dbms_sql.define_column(c_cm_apps,72,cm_apps_row.freight_original);
    dbms_sql.define_column(c_cm_apps,73,cm_apps_row.freight_remaining);
    dbms_sql.define_column(c_cm_apps,74,cm_apps_row.receivables_charges_remaining);
    dbms_sql.define_column(c_cm_apps,75,cm_apps_row.tax_original);
    dbms_sql.define_column(c_cm_apps,76,cm_apps_row.tax_remaining);
    dbms_sql.define_column(c_cm_apps,77,cm_apps_row.selected_for_receipt_batch_id);
    dbms_sql.define_column(c_cm_apps,78,cm_apps_row.receivable_application_id);
    dbms_sql.define_column(c_cm_apps,79,cm_apps_row.attribute_category,50);
    dbms_sql.define_column(c_cm_apps,80,cm_apps_row.attribute1,150);
    dbms_sql.define_column(c_cm_apps,81,cm_apps_row.attribute2,150);
    dbms_sql.define_column(c_cm_apps,82,cm_apps_row.attribute3,150);
    dbms_sql.define_column(c_cm_apps,83,cm_apps_row.attribute4,150);
    dbms_sql.define_column(c_cm_apps,84,cm_apps_row.attribute5,150);
    dbms_sql.define_column(c_cm_apps,85,cm_apps_row.attribute6,150);
    dbms_sql.define_column(c_cm_apps,86,cm_apps_row.attribute7,150);
    dbms_sql.define_column(c_cm_apps,87,cm_apps_row.attribute8,150);
    dbms_sql.define_column(c_cm_apps,88,cm_apps_row.attribute9,150);
    dbms_sql.define_column(c_cm_apps,89,cm_apps_row.attribute10,150);
    dbms_sql.define_column(c_cm_apps,90,cm_apps_row.attribute11,150);
    dbms_sql.define_column(c_cm_apps,91,cm_apps_row.attribute12,150);
    dbms_sql.define_column(c_cm_apps,92,cm_apps_row.attribute13,150);
    dbms_sql.define_column(c_cm_apps,93,cm_apps_row.attribute14,150);
    dbms_sql.define_column(c_cm_apps,94,cm_apps_row.attribute15,150);
    dbms_sql.define_column(c_cm_apps,95,cm_apps_row.trx_billing_number,30);
    dbms_sql.define_column(c_cm_apps,96,cm_apps_row.global_attribute_category,50);
    dbms_sql.define_column(c_cm_apps,97,cm_apps_row.global_attribute1,150);
    dbms_sql.define_column(c_cm_apps,98,cm_apps_row.global_attribute2,150);
    dbms_sql.define_column(c_cm_apps,99,cm_apps_row.global_attribute3,150);
    dbms_sql.define_column(c_cm_apps,100,cm_apps_row.global_attribute4,150);
    dbms_sql.define_column(c_cm_apps,101,cm_apps_row.global_attribute5,150);
    dbms_sql.define_column(c_cm_apps,102,cm_apps_row.global_attribute6,150);
    dbms_sql.define_column(c_cm_apps,103,cm_apps_row.global_attribute7,150);
    dbms_sql.define_column(c_cm_apps,104,cm_apps_row.global_attribute8,150);
    dbms_sql.define_column(c_cm_apps,105,cm_apps_row.global_attribute9,150);
    dbms_sql.define_column(c_cm_apps,106,cm_apps_row.global_attribute10,150);
    dbms_sql.define_column(c_cm_apps,107,cm_apps_row.global_attribute11,150);
    dbms_sql.define_column(c_cm_apps,108,cm_apps_row.global_attribute12,150);
    dbms_sql.define_column(c_cm_apps,109,cm_apps_row.global_attribute13,150);
    dbms_sql.define_column(c_cm_apps,110,cm_apps_row.global_attribute14,150);
    dbms_sql.define_column(c_cm_apps,111,cm_apps_row.global_attribute15,150);
    dbms_sql.define_column(c_cm_apps,112,cm_apps_row.global_attribute16,150);
    dbms_sql.define_column(c_cm_apps,113,cm_apps_row.global_attribute17,150);
    dbms_sql.define_column(c_cm_apps,114,cm_apps_row.global_attribute18,150);
    dbms_sql.define_column(c_cm_apps,115,cm_apps_row.global_attribute19,150);
    dbms_sql.define_column(c_cm_apps,116,cm_apps_row.global_attribute20,150);
    dbms_sql.define_column(c_cm_apps,117,cm_apps_row.transaction_category,150); -- AR TA change
    dbms_sql.define_column(c_cm_apps,118,cm_apps_row.trx_gl_date);
    dbms_sql.define_column(c_cm_apps,119,cm_apps_row.comments,240); -- bug 2662270
    /* columns 120 - 125 added for CM refunds */
    dbms_sql.define_column(c_cm_apps,120,cm_apps_row.receivables_trx_id);
    dbms_sql.define_column(c_cm_apps,121,cm_apps_row.rec_activity_name,50);
    dbms_sql.define_column(c_cm_apps,122,cm_apps_row.application_ref_id);
    dbms_sql.define_column(c_cm_apps,123,cm_apps_row.application_ref_num,30);
    dbms_sql.define_column(c_cm_apps,124,cm_apps_row.application_ref_type,30);
    dbms_sql.define_column(c_cm_apps,125,cm_apps_row.application_ref_type_meaning,80);
    ignore := dbms_sql.execute(c_cm_apps);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'Open, Parsed and Executed c_cm_apps' );
    END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'on_select()-' );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  SQLERRM);
      arp_standard.debug('EXCEPTION: ar_add_fetch_select.on_select');
   END IF;
   RAISE;

END on_select;

/*===========================================================================+
 | FUNCTION
 |      ON_FETCH
 |
 | DESCRIPTION
 |      This function selects a single row from the cursor
 |      and returns the record values to the form.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  : IN:
 |
 |             OUT:
 |
 | RETURNS    :         TRUE if a record has been selected
 |                      FALSE if a record has not been selected
 | NOTES
 |
 | MODIFICATION HISTORY
 |      25-AUG-97  Joan Zaman   Created.
 |      08-JAN-98  Karen Murphy See list of changes at the package level.
 |
 +===========================================================================*/

function on_fetch (
   p_select_type                  IN  VARCHAR2,
   row_id                         OUT NOCOPY VARCHAR2,
   cash_receipt_id                OUT NOCOPY NUMBER,
   customer_trx_id                OUT NOCOPY NUMBER,
   cm_customer_trx_id             OUT NOCOPY NUMBER,
   last_update_date               OUT NOCOPY DATE,
   last_updated_by                OUT NOCOPY NUMBER,
   creation_date                  OUT NOCOPY DATE,
   created_by                     OUT NOCOPY NUMBER,
   last_update_login              OUT NOCOPY NUMBER,
   program_application_id         OUT NOCOPY NUMBER,
   program_id                     OUT NOCOPY NUMBER,
   program_update_date            OUT NOCOPY DATE,
   request_id                     OUT NOCOPY NUMBER,
   receipt_number                 OUT NOCOPY VARCHAR2,
   applied_flag                   OUT NOCOPY VARCHAR2,
   customer_id                    OUT NOCOPY NUMBER,
   customer_name                  OUT NOCOPY VARCHAR2,
   customer_number                OUT NOCOPY VARCHAR2,
   trx_number                     OUT NOCOPY VARCHAR2,
   installment                    OUT NOCOPY NUMBER,
   amount_applied                 OUT NOCOPY NUMBER,
   amount_applied_from            OUT NOCOPY NUMBER,
   trans_to_receipt_rate	  OUT NOCOPY NUMBER,
   discount                       OUT NOCOPY NUMBER,
   discounts_earned               OUT NOCOPY NUMBER,
   discounts_unearned             OUT NOCOPY NUMBER,
   discount_taken_earned          OUT NOCOPY NUMBER,
   discount_taken_unearned        OUT NOCOPY NUMBER,
   amount_due_remaining           OUT NOCOPY NUMBER,
   due_date                       OUT NOCOPY DATE,
   status                         OUT NOCOPY VARCHAR2,
   term_id                        OUT NOCOPY NUMBER,
   trx_class_name                 OUT NOCOPY VARCHAR2,
   trx_class_code                 OUT NOCOPY VARCHAR2,
   trx_type_name                  OUT NOCOPY VARCHAR2,
   cust_trx_type_id               OUT NOCOPY NUMBER,
   trx_date                       OUT NOCOPY DATE,
   location_name                  OUT NOCOPY VARCHAR2,
   bill_to_site_use_id            OUT NOCOPY NUMBER,
   days_late                      OUT NOCOPY NUMBER,
   line_number                    OUT NOCOPY NUMBER,
   customer_trx_line_id           OUT NOCOPY NUMBER,
   apply_date                     OUT NOCOPY DATE,
   gl_date                        OUT NOCOPY DATE,
   gl_posted_date                 OUT NOCOPY DATE,
   reversal_gl_date               OUT NOCOPY DATE,
   exchange_rate                  OUT NOCOPY NUMBER,
   invoice_currency_code          OUT NOCOPY VARCHAR2,
   amount_due_original            OUT NOCOPY NUMBER,
   amount_in_dispute              OUT NOCOPY NUMBER,
   amount_line_items_original     OUT NOCOPY NUMBER,
   acctd_amount_due_remaining     OUT NOCOPY NUMBER,
   acctd_amount_applied_to        OUT NOCOPY NUMBER,
   acctd_amount_applied_from      OUT NOCOPY NUMBER,
   exchange_gain_loss             OUT NOCOPY NUMBER,
   discount_remaining             OUT NOCOPY NUMBER,
   calc_discount_on_lines_flag    OUT NOCOPY VARCHAR2,
   partial_discount_flag          OUT NOCOPY VARCHAR2,
   allow_overapplication_flag     OUT NOCOPY VARCHAR2,
   natural_application_only_flag  OUT NOCOPY VARCHAR2,
   creation_sign                  OUT NOCOPY VARCHAR2,
   applied_payment_schedule_id    OUT NOCOPY NUMBER,
   ussgl_transaction_code         OUT NOCOPY VARCHAR2,
   ussgl_transaction_code_context OUT NOCOPY VARCHAR2,
   purchase_order                 OUT NOCOPY VARCHAR2,
   trx_doc_sequence_id            OUT NOCOPY NUMBER,
   trx_doc_sequence_value         OUT NOCOPY VARCHAR2,
   trx_batch_source_name          OUT NOCOPY VARCHAR2,
   amount_adjusted                OUT NOCOPY NUMBER,
   amount_adjusted_pending        OUT NOCOPY NUMBER,
   amount_line_items_remaining    OUT NOCOPY NUMBER,
   freight_original               OUT NOCOPY NUMBER,
   freight_remaining              OUT NOCOPY NUMBER,
   receivables_charges_remaining  OUT NOCOPY NUMBER,
   tax_original                   OUT NOCOPY NUMBER,
   tax_remaining                  OUT NOCOPY NUMBER,
   selected_for_receipt_batch_id  OUT NOCOPY NUMBER,
   receivable_application_id      OUT NOCOPY NUMBER,
   attribute_category             OUT NOCOPY VARCHAR2,
   attribute1                     OUT NOCOPY VARCHAR2,
   attribute2                     OUT NOCOPY VARCHAR2,
   attribute3                     OUT NOCOPY VARCHAR2,
   attribute4                     OUT NOCOPY VARCHAR2,
   attribute5                     OUT NOCOPY VARCHAR2,
   attribute6                     OUT NOCOPY VARCHAR2,
   attribute7                     OUT NOCOPY VARCHAR2,
   attribute8                     OUT NOCOPY VARCHAR2,
   attribute9                     OUT NOCOPY VARCHAR2,
   attribute10                    OUT NOCOPY VARCHAR2,
   attribute11                    OUT NOCOPY VARCHAR2,
   attribute12                    OUT NOCOPY VARCHAR2,
   attribute13                    OUT NOCOPY VARCHAR2,
   attribute14                    OUT NOCOPY VARCHAR2,
   attribute15                    OUT NOCOPY VARCHAR2,
   trx_billing_number             OUT NOCOPY VARCHAR2,
   global_attribute_category      OUT NOCOPY VARCHAR2,
   global_attribute1              OUT NOCOPY VARCHAR2,
   global_attribute2              OUT NOCOPY VARCHAR2,
   global_attribute3              OUT NOCOPY VARCHAR2,
   global_attribute4              OUT NOCOPY VARCHAR2,
   global_attribute5              OUT NOCOPY VARCHAR2,
   global_attribute6              OUT NOCOPY VARCHAR2,
   global_attribute7              OUT NOCOPY VARCHAR2,
   global_attribute8              OUT NOCOPY VARCHAR2,
   global_attribute9              OUT NOCOPY VARCHAR2,
   global_attribute10             OUT NOCOPY VARCHAR2,
   global_attribute11             OUT NOCOPY VARCHAR2,
   global_attribute12             OUT NOCOPY VARCHAR2,
   global_attribute13             OUT NOCOPY VARCHAR2,
   global_attribute14             OUT NOCOPY VARCHAR2,
   global_attribute15             OUT NOCOPY VARCHAR2,
   global_attribute16             OUT NOCOPY VARCHAR2,
   global_attribute17             OUT NOCOPY VARCHAR2,
   global_attribute18             OUT NOCOPY VARCHAR2,
   global_attribute19             OUT NOCOPY VARCHAR2,
   global_attribute20             OUT NOCOPY VARCHAR2,
--   purchase_order                 OUT NOCOPY VARCHAR2,
   transaction_category           OUT NOCOPY VARCHAR2,
   trx_gl_date                    OUT NOCOPY DATE,
   comments                    OUT NOCOPY VARCHAR2, --- bug 2662270
   receivables_trx_id		  OUT NOCOPY NUMBER,
   rec_activity_name		  OUT NOCOPY VARCHAR,
   application_ref_id		  OUT NOCOPY NUMBER,
   application_ref_num		  OUT NOCOPY VARCHAR2,
   application_ref_type		  OUT NOCOPY VARCHAR2,
   application_ref_type_meaning   OUT NOCOPY VARCHAR2
                                          ) return BOOLEAN IS

ignore          number;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'on_fetch()+' );
  END IF;

  ------------------------------------------------------------
  --
  -- Mass Applications
  --
  -- We are working with the Open Transactions and On Account
  -- cursors.  We want to loop through the Open Transactions
  -- cursor, once all of the records have been fetched,
  -- close the cursor and fetch the single On Account row.
  --
  ------------------------------------------------------------
  IF dbms_sql.is_open(c_open_trx) THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'Open Trx Cursor is OPEN' );
    END IF;
    IF dbms_sql.fetch_rows(c_open_trx) > 0 THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'And we have fetched a record from Open Trx' );
      END IF;
      dbms_sql.column_value_rowid(c_open_trx,1,open_trx_row.row_id);
      dbms_sql.column_value(c_open_trx,2,open_trx_row.cash_receipt_id);
      dbms_sql.column_value(c_open_trx,3,open_trx_row.customer_trx_id);
      dbms_sql.column_value(c_open_trx,4,open_trx_row.cm_customer_trx_id);
      dbms_sql.column_value(c_open_trx,5,open_trx_row.last_update_date);
      dbms_sql.column_value(c_open_trx,6,open_trx_row.last_updated_by);
      dbms_sql.column_value(c_open_trx,7,open_trx_row.creation_date);
      dbms_sql.column_value(c_open_trx,8,open_trx_row.created_by);
      dbms_sql.column_value(c_open_trx,9,open_trx_row.last_update_login);
      dbms_sql.column_value(c_open_trx,10,open_trx_row.program_application_id);
      dbms_sql.column_value(c_open_trx,11,open_trx_row.program_id);
      dbms_sql.column_value(c_open_trx,12,open_trx_row.program_update_date);
      dbms_sql.column_value(c_open_trx,13,open_trx_row.request_id);
      dbms_sql.column_value(c_open_trx,14,open_trx_row.receipt_number);
      dbms_sql.column_value(c_open_trx,15,open_trx_row.applied_flag);
      dbms_sql.column_value(c_open_trx,16,open_trx_row.customer_id);
      dbms_sql.column_value(c_open_trx,17,open_trx_row.customer_name);
      dbms_sql.column_value(c_open_trx,18,open_trx_row.customer_number);
      dbms_sql.column_value(c_open_trx,19,open_trx_row.trx_number);
      dbms_sql.column_value(c_open_trx,20,open_trx_row.installment);
      dbms_sql.column_value(c_open_trx,21,open_trx_row.amount_applied);
      dbms_sql.column_value(c_open_trx,22,open_trx_row.amount_applied_from);
      dbms_sql.column_value(c_open_trx,23,open_trx_row.trans_to_receipt_rate);
      dbms_sql.column_value(c_open_trx,24,open_trx_row.discount);
      dbms_sql.column_value(c_open_trx,25,open_trx_row.discounts_earned);
      dbms_sql.column_value(c_open_trx,26,open_trx_row.discounts_unearned);
      dbms_sql.column_value(c_open_trx,27,open_trx_row.discount_taken_earned);
      dbms_sql.column_value(c_open_trx,28,open_trx_row.discount_taken_unearned);
      dbms_sql.column_value(c_open_trx,29,open_trx_row.amount_due_remaining);
      dbms_sql.column_value(c_open_trx,30,open_trx_row.due_date);
      dbms_sql.column_value(c_open_trx,31,open_trx_row.status);
      dbms_sql.column_value(c_open_trx,32,open_trx_row.term_id);
      dbms_sql.column_value(c_open_trx,33,open_trx_row.trx_class_name);
      dbms_sql.column_value(c_open_trx,34,open_trx_row.trx_class_code);
      dbms_sql.column_value(c_open_trx,35,open_trx_row.trx_type_name);
      dbms_sql.column_value(c_open_trx,36,open_trx_row.cust_trx_type_id);
      dbms_sql.column_value(c_open_trx,37,open_trx_row.trx_date);
      dbms_sql.column_value(c_open_trx,38,open_trx_row.location_name);
      dbms_sql.column_value(c_open_trx,39,open_trx_row.bill_to_site_use_id);
      dbms_sql.column_value(c_open_trx,40,open_trx_row.days_late);
      dbms_sql.column_value(c_open_trx,41,open_trx_row.line_number);
      dbms_sql.column_value(c_open_trx,42,open_trx_row.customer_trx_line_id);
      dbms_sql.column_value(c_open_trx,43,open_trx_row.apply_date);
      dbms_sql.column_value(c_open_trx,44,open_trx_row.gl_date);
      dbms_sql.column_value(c_open_trx,45,open_trx_row.gl_posted_date);
      dbms_sql.column_value(c_open_trx,46,open_trx_row.reversal_gl_date);
      dbms_sql.column_value(c_open_trx,47,open_trx_row.exchange_rate);
      dbms_sql.column_value(c_open_trx,48,open_trx_row.invoice_currency_code);
      dbms_sql.column_value(c_open_trx,49,open_trx_row.amount_due_original);
      dbms_sql.column_value(c_open_trx,50,open_trx_row.amount_in_dispute);
      dbms_sql.column_value(c_open_trx,51,open_trx_row.amount_line_items_original);
      dbms_sql.column_value(c_open_trx,52,open_trx_row.acctd_amount_due_remaining);
      dbms_sql.column_value(c_open_trx,53,open_trx_row.acctd_amount_applied_to);
      dbms_sql.column_value(c_open_trx,54,open_trx_row.acctd_amount_applied_from);
      dbms_sql.column_value(c_open_trx,55,open_trx_row.exchange_gain_loss);
      dbms_sql.column_value(c_open_trx,56,open_trx_row.discount_remaining);
      dbms_sql.column_value(c_open_trx,57,open_trx_row.calc_discount_on_lines_flag);
      dbms_sql.column_value(c_open_trx,58,open_trx_row.partial_discount_flag);
      dbms_sql.column_value(c_open_trx,59,open_trx_row.allow_overapplication_flag);
      dbms_sql.column_value(c_open_trx,60,open_trx_row.natural_application_only_flag);
      dbms_sql.column_value(c_open_trx,61,open_trx_row.creation_sign);
      dbms_sql.column_value(c_open_trx,62,open_trx_row.applied_payment_schedule_id);
      dbms_sql.column_value(c_open_trx,63,open_trx_row.ussgl_transaction_code);
      dbms_sql.column_value(c_open_trx,64,open_trx_row.ussgl_transaction_code_context);
      dbms_sql.column_value(c_open_trx,65,open_trx_row.purchase_order);
      dbms_sql.column_value(c_open_trx,66,open_trx_row.trx_doc_sequence_id);
      dbms_sql.column_value(c_open_trx,67,open_trx_row.trx_doc_sequence_value);
      dbms_sql.column_value(c_open_trx,68,open_trx_row.trx_batch_source_name);
      dbms_sql.column_value(c_open_trx,69,open_trx_row.amount_adjusted);
      dbms_sql.column_value(c_open_trx,70,open_trx_row.amount_adjusted_pending);
      dbms_sql.column_value(c_open_trx,71,open_trx_row.amount_line_items_remaining);
      dbms_sql.column_value(c_open_trx,72,open_trx_row.freight_original);
      dbms_sql.column_value(c_open_trx,73,open_trx_row.freight_remaining);
      dbms_sql.column_value(c_open_trx,74,open_trx_row.receivables_charges_remaining);
      dbms_sql.column_value(c_open_trx,75,open_trx_row.tax_original);
      dbms_sql.column_value(c_open_trx,76,open_trx_row.tax_remaining);
      dbms_sql.column_value(c_open_trx,77,open_trx_row.selected_for_receipt_batch_id);
      dbms_sql.column_value(c_open_trx,78,open_trx_row.receivable_application_id);
      dbms_sql.column_value(c_open_trx,79,open_trx_row.attribute_category);
      dbms_sql.column_value(c_open_trx,80,open_trx_row.attribute1);
      dbms_sql.column_value(c_open_trx,81,open_trx_row.attribute2);
      dbms_sql.column_value(c_open_trx,82,open_trx_row.attribute3);
      dbms_sql.column_value(c_open_trx,83,open_trx_row.attribute4);
      dbms_sql.column_value(c_open_trx,84,open_trx_row.attribute5);
      dbms_sql.column_value(c_open_trx,85,open_trx_row.attribute6);
      dbms_sql.column_value(c_open_trx,86,open_trx_row.attribute7);
      dbms_sql.column_value(c_open_trx,87,open_trx_row.attribute8);
      dbms_sql.column_value(c_open_trx,88,open_trx_row.attribute9);
      dbms_sql.column_value(c_open_trx,89,open_trx_row.attribute10);
      dbms_sql.column_value(c_open_trx,90,open_trx_row.attribute11);
      dbms_sql.column_value(c_open_trx,91,open_trx_row.attribute12);
      dbms_sql.column_value(c_open_trx,92,open_trx_row.attribute13);
      dbms_sql.column_value(c_open_trx,93,open_trx_row.attribute14);
      dbms_sql.column_value(c_open_trx,94,open_trx_row.attribute15);
      dbms_sql.column_value(c_open_trx,95,open_trx_row.trx_billing_number);
      dbms_sql.column_value(c_open_trx,96,open_trx_row.global_attribute_category);
      dbms_sql.column_value(c_open_trx,97,open_trx_row.global_attribute1);
      dbms_sql.column_value(c_open_trx,98,open_trx_row.global_attribute2);
      dbms_sql.column_value(c_open_trx,99,open_trx_row.global_attribute3);
      dbms_sql.column_value(c_open_trx,100,open_trx_row.global_attribute4);
      dbms_sql.column_value(c_open_trx,101,open_trx_row.global_attribute5);
      dbms_sql.column_value(c_open_trx,102,open_trx_row.global_attribute6);
      dbms_sql.column_value(c_open_trx,103,open_trx_row.global_attribute7);
      dbms_sql.column_value(c_open_trx,104,open_trx_row.global_attribute8);
      dbms_sql.column_value(c_open_trx,105,open_trx_row.global_attribute9);
      dbms_sql.column_value(c_open_trx,106,open_trx_row.global_attribute10);
      dbms_sql.column_value(c_open_trx,107,open_trx_row.global_attribute11);
      dbms_sql.column_value(c_open_trx,108,open_trx_row.global_attribute12);
      dbms_sql.column_value(c_open_trx,109,open_trx_row.global_attribute13);
      dbms_sql.column_value(c_open_trx,110,open_trx_row.global_attribute14);
      dbms_sql.column_value(c_open_trx,111,open_trx_row.global_attribute15);
      dbms_sql.column_value(c_open_trx,112,open_trx_row.global_attribute16);
      dbms_sql.column_value(c_open_trx,113,open_trx_row.global_attribute17);
      dbms_sql.column_value(c_open_trx,114,open_trx_row.global_attribute18);
      dbms_sql.column_value(c_open_trx,115,open_trx_row.global_attribute19);
      dbms_sql.column_value(c_open_trx,116,open_trx_row.global_attribute20);
      dbms_sql.column_value(c_open_trx,117,open_trx_row.transaction_category); -- ARTA Changes
      dbms_sql.column_value(c_open_trx,118,open_trx_row.trx_gl_date);


      row_id                    :=open_trx_row.row_id;
      cash_receipt_id           :=open_trx_row.cash_receipt_id;
      customer_trx_id           :=open_trx_row.customer_trx_id;
      cm_customer_trx_id        :=open_trx_row.cm_customer_trx_id;
      last_update_date          :=open_trx_row.last_update_date;
      last_updated_by           :=open_trx_row.last_updated_by;
      creation_date             :=open_trx_row.creation_date;
      created_by                :=open_trx_row.created_by;
      last_update_login         :=open_trx_row.last_update_login;
      program_application_id    :=open_trx_row.program_application_id;
      program_id                :=open_trx_row.program_id;
      program_update_date       :=open_trx_row.program_update_date;
      request_id                :=open_trx_row.request_id;
      receipt_number            :=open_trx_row.receipt_number;
      applied_flag              :=open_trx_row.applied_flag;
      customer_id               :=open_trx_row.customer_id;
      customer_name             :=open_trx_row.customer_name;
      customer_number           :=open_trx_row.customer_number;
      trx_number                :=open_trx_row.trx_number;
      installment               :=open_trx_row.installment;
      amount_applied            :=open_trx_row.amount_applied;
      amount_applied_from       :=open_trx_row.amount_applied_from;
      trans_to_receipt_rate     :=open_trx_row.trans_to_receipt_rate;
      discount                  :=open_trx_row.discount;
      discounts_earned          :=open_trx_row.discounts_earned;
      discounts_unearned        :=open_trx_row.discounts_unearned;
      discount_taken_earned     :=open_trx_row.discount_taken_earned;
      discount_taken_unearned   :=open_trx_row.discount_taken_unearned;
      amount_due_remaining      :=open_trx_row.amount_due_remaining;
      due_date                  :=open_trx_row.due_date;
      status                    :=open_trx_row.status;
      term_id                   :=open_trx_row.term_id;
      trx_class_name            :=open_trx_row.trx_class_name;
      trx_class_code            :=open_trx_row.trx_class_code;
      trx_type_name             :=open_trx_row.trx_type_name;
      cust_trx_type_id          :=open_trx_row.cust_trx_type_id;
      trx_date                  :=open_trx_row.trx_date;
      location_name             :=open_trx_row.location_name;
      bill_to_site_use_id       :=open_trx_row.bill_to_site_use_id;
      days_late                 :=open_trx_row.days_late;
      line_number               :=open_trx_row.line_number;
      customer_trx_line_id      :=open_trx_row.customer_trx_line_id;
      apply_date                :=open_trx_row.apply_date;
      gl_date                   :=open_trx_row.gl_date;
      gl_posted_date            :=open_trx_row.gl_posted_date;
      reversal_gl_date          :=open_trx_row.reversal_gl_date;
      exchange_rate             :=open_trx_row.exchange_rate;
      invoice_currency_code     :=open_trx_row.invoice_currency_code;
      amount_due_original       :=open_trx_row.amount_due_original;
      amount_in_dispute         :=open_trx_row.amount_in_dispute;
      amount_line_items_original:=open_trx_row.amount_line_items_original;
      acctd_amount_due_remaining:=open_trx_row.acctd_amount_due_remaining;
      acctd_amount_applied_to   :=open_trx_row.acctd_amount_applied_to;
      acctd_amount_applied_from :=open_trx_row.acctd_amount_applied_from;
      exchange_gain_loss        :=open_trx_row.exchange_gain_loss;
      discount_remaining        :=open_trx_row.discount_remaining;
      calc_discount_on_lines_flag:=open_trx_row.calc_discount_on_lines_flag;
      partial_discount_flag     :=open_trx_row.partial_discount_flag;
      allow_overapplication_flag:=open_trx_row.allow_overapplication_flag;
      natural_application_only_flag:=open_trx_row.natural_application_only_flag;
      creation_sign             :=open_trx_row.creation_sign;
      applied_payment_schedule_id:=open_trx_row.applied_payment_schedule_id;
      ussgl_transaction_code    :=open_trx_row.ussgl_transaction_code;
      ussgl_transaction_code_context:=open_trx_row.ussgl_transaction_code_context;
      purchase_order		:=open_trx_row.purchase_order;
      trx_doc_sequence_id       :=open_trx_row.trx_doc_sequence_id;
      trx_doc_sequence_value    :=open_trx_row.trx_doc_sequence_value;
      trx_batch_source_name     :=open_trx_row.trx_batch_source_name;
      amount_adjusted           :=open_trx_row.amount_adjusted;
      amount_adjusted_pending   :=open_trx_row.amount_adjusted_pending;
      amount_line_items_remaining:=open_trx_row.amount_line_items_remaining;
      freight_original          :=open_trx_row.freight_original;
      freight_remaining         :=open_trx_row.freight_remaining;
      receivables_charges_remaining:=open_trx_row.receivables_charges_remaining;
      tax_original              :=open_trx_row.tax_original;
      tax_remaining             :=open_trx_row.tax_remaining;
      selected_for_receipt_batch_id:=open_trx_row.selected_for_receipt_batch_id;
      receivable_application_id :=open_trx_row.receivable_application_id;
      attribute_category        :=open_trx_row.attribute_category;
      attribute1                :=open_trx_row.attribute1;
      attribute2                :=open_trx_row.attribute2;
      attribute3                :=open_trx_row.attribute3;
      attribute4                :=open_trx_row.attribute4;
      attribute5                :=open_trx_row.attribute5;
      attribute6                :=open_trx_row.attribute6;
      attribute7                :=open_trx_row.attribute7;
      attribute8                :=open_trx_row.attribute8;
      attribute9                :=open_trx_row.attribute9;
      attribute10               :=open_trx_row.attribute10;
      attribute11               :=open_trx_row.attribute11;
      attribute12               :=open_trx_row.attribute12;
      attribute13               :=open_trx_row.attribute13;
      attribute14               :=open_trx_row.attribute14;
      attribute15               :=open_trx_row.attribute15;
      trx_billing_number        :=open_trx_row.trx_billing_number;
      global_attribute_category :=open_trx_row.global_attribute_category;
      global_attribute1         :=open_trx_row.global_attribute1;
      global_attribute2         :=open_trx_row.global_attribute2;
      global_attribute3         :=open_trx_row.global_attribute3;
      global_attribute4         :=open_trx_row.global_attribute4;
      global_attribute5         :=open_trx_row.global_attribute5;
      global_attribute6         :=open_trx_row.global_attribute6;
      global_attribute7         :=open_trx_row.global_attribute7;
      global_attribute8         :=open_trx_row.global_attribute8;
      global_attribute9         :=open_trx_row.global_attribute9;
      global_attribute10        :=open_trx_row.global_attribute10;
      global_attribute11        :=open_trx_row.global_attribute11;
      global_attribute12        :=open_trx_row.global_attribute12;
      global_attribute13        :=open_trx_row.global_attribute13;
      global_attribute14        :=open_trx_row.global_attribute14;
      global_attribute15        :=open_trx_row.global_attribute15;
      global_attribute16        :=open_trx_row.global_attribute16;
      global_attribute17        :=open_trx_row.global_attribute17;
      global_attribute18        :=open_trx_row.global_attribute18;
      global_attribute19        :=open_trx_row.global_attribute19;
      global_attribute20        :=open_trx_row.global_attribute20;
      -- ARTA Changes
      transaction_category      :=open_trx_row.transaction_category;
      trx_gl_date               :=open_trx_row.trx_gl_date;

      return(TRUE);

    ELSE

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'Open Trx has no more records so we will close it' );
      END IF;
      dbms_sql.close_cursor(c_open_trx);

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'But On Acct is open' );
      END IF;
      ignore := dbms_sql.fetch_rows(c_on_acct);

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'On Acct cursor has a record' );
      END IF;
      dbms_sql.column_value_rowid(c_on_acct,1,on_acct_row.row_id);
      dbms_sql.column_value(c_on_acct,2,on_acct_row.cash_receipt_id);
      dbms_sql.column_value(c_on_acct,3,on_acct_row.customer_trx_id);
      dbms_sql.column_value(c_on_acct,4,on_acct_row.last_update_date);
      dbms_sql.column_value(c_on_acct,5,on_acct_row.last_updated_by);
      dbms_sql.column_value(c_on_acct,6,on_acct_row.creation_date);
      dbms_sql.column_value(c_on_acct,7,on_acct_row.created_by);
      dbms_sql.column_value(c_on_acct,8,on_acct_row.last_update_login);
      dbms_sql.column_value(c_on_acct,9,on_acct_row.program_application_id);
      dbms_sql.column_value(c_on_acct,10,on_acct_row.program_id);
      dbms_sql.column_value(c_on_acct,11,on_acct_row.program_update_date);
      dbms_sql.column_value(c_on_acct,12,on_acct_row.request_id);
      dbms_sql.column_value(c_on_acct,13,on_acct_row.applied_flag);
      dbms_sql.column_value(c_on_acct,14,on_acct_row.customer_id);
      dbms_sql.column_value(c_on_acct,15,on_acct_row.trx_number);
      dbms_sql.column_value(c_on_acct,16,on_acct_row.discounts_earned);
      dbms_sql.column_value(c_on_acct,17,on_acct_row.discounts_unearned);
      dbms_sql.column_value(c_on_acct,18,on_acct_row.discount_taken_earned);
      dbms_sql.column_value(c_on_acct,19,on_acct_row.discount_taken_unearned);
      dbms_sql.column_value(c_on_acct,20,on_acct_row.amount_due_remaining);
      dbms_sql.column_value(c_on_acct,21,on_acct_row.status);
      dbms_sql.column_value(c_on_acct,22,on_acct_row.term_id);
      dbms_sql.column_value(c_on_acct,23,on_acct_row.bill_to_site_use_id);
      dbms_sql.column_value(c_on_acct,24,on_acct_row.apply_date);
      dbms_sql.column_value(c_on_acct,25,on_acct_row.gl_date);
      dbms_sql.column_value(c_on_acct,26,on_acct_row.invoice_currency_code);
      dbms_sql.column_value(c_on_acct,27,on_acct_row.amount_due_original);
      dbms_sql.column_value(c_on_acct,28,on_acct_row.amount_in_dispute);
      dbms_sql.column_value(c_on_acct,29,on_acct_row.amount_line_items_original);
      dbms_sql.column_value(c_on_acct,30,on_acct_row.discount_remaining);
      dbms_sql.column_value(c_on_acct,31,on_acct_row.applied_payment_schedule_id);

      row_id      	        := on_acct_row.row_id;
      cash_receipt_id           := on_acct_row.cash_receipt_id;
      customer_trx_id   	:= on_acct_row.customer_trx_id;
      last_update_date          := on_acct_row.last_update_date;
      last_updated_by           := on_acct_row.last_updated_by;
      creation_date             := on_acct_row.creation_date;
      created_by        	:= on_acct_row.created_by;
      last_update_login 	:= on_acct_row.last_update_login;
      program_application_id	:= on_acct_row.program_application_id;
      program_id                := on_acct_row.program_id;
      program_update_date       := on_acct_row.program_update_date;
      request_id                := on_acct_row.request_id;
      applied_flag              := on_acct_row.applied_flag;
      customer_id               := on_acct_row.customer_id;
      trx_number        	:= on_acct_row.trx_number;
      discounts_earned          := on_acct_row.discounts_earned;
      discounts_unearned        := on_acct_row.discounts_unearned;
      discount_taken_earned     := on_acct_row.discount_taken_earned;
      discount_taken_unearned   := on_acct_row.discount_taken_unearned;
      amount_due_remaining      := on_acct_row.amount_due_remaining;
      status                    := on_acct_row.status;
      term_id                   := on_acct_row.term_id;
      bill_to_site_use_id       := on_acct_row.bill_to_site_use_id;
      apply_date                := on_acct_row.apply_date;
      gl_date                   := on_acct_row.gl_date;
      invoice_currency_code     := on_acct_row.invoice_currency_code;
      amount_due_original       := on_acct_row.amount_due_original;
      amount_in_dispute         := on_acct_row.amount_in_dispute;
      amount_line_items_original:= on_acct_row.amount_line_items_original;
      discount_remaining    	:= on_acct_row.discount_remaining;
      applied_payment_schedule_id:= on_acct_row.applied_payment_schedule_id;
      -- ARTA Changes
      purchase_order            := NULL;
      transaction_category      := NULL;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'Close On Acct Cursor' );
      END IF;
      dbms_sql.close_cursor(c_on_acct);
      return(TRUE);

    END IF;

  -----------------------------------------------------
  --
  -- Credit Memo Applications
  --
  -- We are working with the Credit Memo Applications
  -- cursor.  Loop through the cursor until all
  -- records have been returned.
  --
  -----------------------------------------------------
  ELSIF dbms_sql.is_open(c_cm_apps) THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'CM Apps cursor is OPEN' );
    END IF;
    IF dbms_sql.fetch_rows(c_cm_apps) > 0 THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'And we have fetched a record from CM Apps' );
      END IF;
      dbms_sql.column_value_rowid(c_cm_apps,1,cm_apps_row.row_id);
      dbms_sql.column_value(c_cm_apps,2,cm_apps_row.cash_receipt_id);
      dbms_sql.column_value(c_cm_apps,3,cm_apps_row.customer_trx_id);
      dbms_sql.column_value(c_cm_apps,4,cm_apps_row.cm_customer_trx_id);
      dbms_sql.column_value(c_cm_apps,5,cm_apps_row.last_update_date);
      dbms_sql.column_value(c_cm_apps,6,cm_apps_row.last_updated_by);
      dbms_sql.column_value(c_cm_apps,7,cm_apps_row.creation_date);
      dbms_sql.column_value(c_cm_apps,8,cm_apps_row.created_by);
      dbms_sql.column_value(c_cm_apps,9,cm_apps_row.last_update_login);
      dbms_sql.column_value(c_cm_apps,10,cm_apps_row.program_application_id);
      dbms_sql.column_value(c_cm_apps,11,cm_apps_row.program_id);
      dbms_sql.column_value(c_cm_apps,12,cm_apps_row.program_update_date);
      dbms_sql.column_value(c_cm_apps,13,cm_apps_row.request_id);
      dbms_sql.column_value(c_cm_apps,14,cm_apps_row.receipt_number);
      dbms_sql.column_value(c_cm_apps,15,cm_apps_row.applied_flag);
      dbms_sql.column_value(c_cm_apps,16,cm_apps_row.customer_id);
      dbms_sql.column_value(c_cm_apps,17,cm_apps_row.customer_name);
      dbms_sql.column_value(c_cm_apps,18,cm_apps_row.customer_number);
      dbms_sql.column_value(c_cm_apps,19,cm_apps_row.trx_number);
      dbms_sql.column_value(c_cm_apps,20,cm_apps_row.installment);
      dbms_sql.column_value(c_cm_apps,21,cm_apps_row.amount_applied);
      dbms_sql.column_value(c_cm_apps,22,cm_apps_row.amount_applied_from);
      dbms_sql.column_value(c_cm_apps,23,cm_apps_row.trans_to_receipt_rate);
      dbms_sql.column_value(c_cm_apps,24,cm_apps_row.discount);
      dbms_sql.column_value(c_cm_apps,25,cm_apps_row.discounts_earned);
      dbms_sql.column_value(c_cm_apps,26,cm_apps_row.discounts_unearned);
      dbms_sql.column_value(c_cm_apps,27,cm_apps_row.discount_taken_earned);
      dbms_sql.column_value(c_cm_apps,28,cm_apps_row.discount_taken_unearned);
      dbms_sql.column_value(c_cm_apps,29,cm_apps_row.amount_due_remaining);
      dbms_sql.column_value(c_cm_apps,30,cm_apps_row.due_date);
      dbms_sql.column_value(c_cm_apps,31,cm_apps_row.status);
      dbms_sql.column_value(c_cm_apps,32,cm_apps_row.term_id);
      dbms_sql.column_value(c_cm_apps,33,cm_apps_row.trx_class_name);
      dbms_sql.column_value(c_cm_apps,34,cm_apps_row.trx_class_code);
      dbms_sql.column_value(c_cm_apps,35,cm_apps_row.trx_type_name);
      dbms_sql.column_value(c_cm_apps,36,cm_apps_row.cust_trx_type_id);
      dbms_sql.column_value(c_cm_apps,37,cm_apps_row.trx_date);
      dbms_sql.column_value(c_cm_apps,38,cm_apps_row.location_name);
      dbms_sql.column_value(c_cm_apps,39,cm_apps_row.bill_to_site_use_id);
      dbms_sql.column_value(c_cm_apps,40,cm_apps_row.days_late);
      dbms_sql.column_value(c_cm_apps,41,cm_apps_row.line_number);
      dbms_sql.column_value(c_cm_apps,42,cm_apps_row.customer_trx_line_id);
      dbms_sql.column_value(c_cm_apps,43,cm_apps_row.apply_date);
      dbms_sql.column_value(c_cm_apps,44,cm_apps_row.gl_date);
      dbms_sql.column_value(c_cm_apps,45,cm_apps_row.gl_posted_date);
      dbms_sql.column_value(c_cm_apps,46,cm_apps_row.reversal_gl_date);
      dbms_sql.column_value(c_cm_apps,47,cm_apps_row.exchange_rate);
      dbms_sql.column_value(c_cm_apps,48,cm_apps_row.invoice_currency_code);
      dbms_sql.column_value(c_cm_apps,49,cm_apps_row.amount_due_original);
      dbms_sql.column_value(c_cm_apps,50,cm_apps_row.amount_in_dispute);
      dbms_sql.column_value(c_cm_apps,51,cm_apps_row.amount_line_items_original);
      dbms_sql.column_value(c_cm_apps,52,cm_apps_row.acctd_amount_due_remaining);
      dbms_sql.column_value(c_cm_apps,53,cm_apps_row.acctd_amount_applied_to);
      dbms_sql.column_value(c_cm_apps,54,cm_apps_row.acctd_amount_applied_from);
      dbms_sql.column_value(c_cm_apps,55,cm_apps_row.exchange_gain_loss);
      dbms_sql.column_value(c_cm_apps,56,cm_apps_row.discount_remaining);
      dbms_sql.column_value(c_cm_apps,57,cm_apps_row.calc_discount_on_lines_flag);
      dbms_sql.column_value(c_cm_apps,58,cm_apps_row.partial_discount_flag);
      dbms_sql.column_value(c_cm_apps,59,cm_apps_row.allow_overapplication_flag);
      dbms_sql.column_value(c_cm_apps,60,cm_apps_row.natural_application_only_flag);
      dbms_sql.column_value(c_cm_apps,61,cm_apps_row.creation_sign);
      dbms_sql.column_value(c_cm_apps,62,cm_apps_row.applied_payment_schedule_id);
      dbms_sql.column_value(c_cm_apps,63,cm_apps_row.ussgl_transaction_code);
      dbms_sql.column_value(c_cm_apps,64,cm_apps_row.ussgl_transaction_code_context);
      dbms_sql.column_value(c_cm_apps,65,cm_apps_row.purchase_order);
      dbms_sql.column_value(c_cm_apps,66,cm_apps_row.trx_doc_sequence_id);
      dbms_sql.column_value(c_cm_apps,67,cm_apps_row.trx_doc_sequence_value);
      dbms_sql.column_value(c_cm_apps,68,cm_apps_row.trx_batch_source_name);
      dbms_sql.column_value(c_cm_apps,69,cm_apps_row.amount_adjusted);
      dbms_sql.column_value(c_cm_apps,70,cm_apps_row.amount_adjusted_pending);
      dbms_sql.column_value(c_cm_apps,71,cm_apps_row.amount_line_items_remaining);
      dbms_sql.column_value(c_cm_apps,72,cm_apps_row.freight_original);
      dbms_sql.column_value(c_cm_apps,73,cm_apps_row.freight_remaining);
      dbms_sql.column_value(c_cm_apps,74,cm_apps_row.receivables_charges_remaining);
      dbms_sql.column_value(c_cm_apps,75,cm_apps_row.tax_original);
      dbms_sql.column_value(c_cm_apps,76,cm_apps_row.tax_remaining);
      dbms_sql.column_value(c_cm_apps,77,cm_apps_row.selected_for_receipt_batch_id);
      dbms_sql.column_value(c_cm_apps,78,cm_apps_row.receivable_application_id);
      dbms_sql.column_value(c_cm_apps,79,cm_apps_row.attribute_category);
      dbms_sql.column_value(c_cm_apps,80,cm_apps_row.attribute1);
      dbms_sql.column_value(c_cm_apps,81,cm_apps_row.attribute2);
      dbms_sql.column_value(c_cm_apps,82,cm_apps_row.attribute3);
      dbms_sql.column_value(c_cm_apps,83,cm_apps_row.attribute4);
      dbms_sql.column_value(c_cm_apps,84,cm_apps_row.attribute5);
      dbms_sql.column_value(c_cm_apps,85,cm_apps_row.attribute6);
      dbms_sql.column_value(c_cm_apps,86,cm_apps_row.attribute7);
      dbms_sql.column_value(c_cm_apps,87,cm_apps_row.attribute8);
      dbms_sql.column_value(c_cm_apps,88,cm_apps_row.attribute9);
      dbms_sql.column_value(c_cm_apps,89,cm_apps_row.attribute10);
      dbms_sql.column_value(c_cm_apps,90,cm_apps_row.attribute11);
      dbms_sql.column_value(c_cm_apps,91,cm_apps_row.attribute12);
      dbms_sql.column_value(c_cm_apps,92,cm_apps_row.attribute13);
      dbms_sql.column_value(c_cm_apps,93,cm_apps_row.attribute14);
      dbms_sql.column_value(c_cm_apps,94,cm_apps_row.attribute15);
      dbms_sql.column_value(c_cm_apps,95,cm_apps_row.trx_billing_number);
      dbms_sql.column_value(c_cm_apps,96,cm_apps_row.global_attribute_category);
      dbms_sql.column_value(c_cm_apps,97,cm_apps_row.global_attribute1);
      dbms_sql.column_value(c_cm_apps,98,cm_apps_row.global_attribute2);
      dbms_sql.column_value(c_cm_apps,99,cm_apps_row.global_attribute3);
      dbms_sql.column_value(c_cm_apps,100,cm_apps_row.global_attribute4);
      dbms_sql.column_value(c_cm_apps,101,cm_apps_row.global_attribute5);
      dbms_sql.column_value(c_cm_apps,102,cm_apps_row.global_attribute6);
      dbms_sql.column_value(c_cm_apps,103,cm_apps_row.global_attribute7);
      dbms_sql.column_value(c_cm_apps,104,cm_apps_row.global_attribute8);
      dbms_sql.column_value(c_cm_apps,105,cm_apps_row.global_attribute9);
      dbms_sql.column_value(c_cm_apps,106,cm_apps_row.global_attribute10);
      dbms_sql.column_value(c_cm_apps,107,cm_apps_row.global_attribute11);
      dbms_sql.column_value(c_cm_apps,108,cm_apps_row.global_attribute12);
      dbms_sql.column_value(c_cm_apps,109,cm_apps_row.global_attribute13);
      dbms_sql.column_value(c_cm_apps,110,cm_apps_row.global_attribute14);
      dbms_sql.column_value(c_cm_apps,111,cm_apps_row.global_attribute15);
      dbms_sql.column_value(c_cm_apps,112,cm_apps_row.global_attribute16);
      dbms_sql.column_value(c_cm_apps,113,cm_apps_row.global_attribute17);
      dbms_sql.column_value(c_cm_apps,114,cm_apps_row.global_attribute18);
      dbms_sql.column_value(c_cm_apps,115,cm_apps_row.global_attribute19);
      dbms_sql.column_value(c_cm_apps,116,cm_apps_row.global_attribute20);
      dbms_sql.column_value(c_cm_apps,117,cm_apps_row.transaction_category); -- ARTA Changes
      dbms_sql.column_value(c_cm_apps,118,cm_apps_row.trx_gl_date);
      dbms_sql.column_value(c_cm_apps,119,cm_apps_row.comments); -- bug 2662270
      /* cols 120-125 added for CM refunds */
      dbms_sql.column_value(c_cm_apps,120,cm_apps_row.receivables_trx_id);
      dbms_sql.column_value(c_cm_apps,121,cm_apps_row.rec_activity_name);
      dbms_sql.column_value(c_cm_apps,122,cm_apps_row.application_ref_id);
      dbms_sql.column_value(c_cm_apps,123,cm_apps_row.application_ref_num);
      dbms_sql.column_value(c_cm_apps,124,cm_apps_row.application_ref_type);
      dbms_sql.column_value(c_cm_apps,125,cm_apps_row.application_ref_type_meaning);

      row_id                    :=cm_apps_row.row_id;
      cash_receipt_id           :=cm_apps_row.cash_receipt_id;
      customer_trx_id           :=cm_apps_row.customer_trx_id;
      cm_customer_trx_id        :=cm_apps_row.cm_customer_trx_id;
      last_update_date          :=cm_apps_row.last_update_date;
      last_updated_by           :=cm_apps_row.last_updated_by;
      creation_date             :=cm_apps_row.creation_date;
      created_by                :=cm_apps_row.created_by;
      last_update_login         :=cm_apps_row.last_update_login;
      program_application_id    :=cm_apps_row.program_application_id;
      program_id                :=cm_apps_row.program_id;
      program_update_date       :=cm_apps_row.program_update_date;
      request_id                :=cm_apps_row.request_id;
      receipt_number            :=cm_apps_row.receipt_number;
      applied_flag              :=cm_apps_row.applied_flag;
      customer_id               :=cm_apps_row.customer_id;
      customer_name             :=cm_apps_row.customer_name;
      customer_number           :=cm_apps_row.customer_number;
      trx_number                :=cm_apps_row.trx_number;
      installment               :=cm_apps_row.installment;
      amount_applied            :=cm_apps_row.amount_applied;
      amount_applied_from	:=cm_apps_row.amount_applied_from;
      trans_to_receipt_rate     :=cm_apps_row.trans_to_receipt_rate;
      discount                  :=cm_apps_row.discount;
      discounts_earned          :=cm_apps_row.discounts_earned;
      discounts_unearned        :=cm_apps_row.discounts_unearned;
      discount_taken_earned     :=cm_apps_row.discount_taken_earned;
      discount_taken_unearned   :=cm_apps_row.discount_taken_unearned;
      amount_due_remaining      :=cm_apps_row.amount_due_remaining;
      due_date                  :=cm_apps_row.due_date;
      status                    :=cm_apps_row.status;
      term_id                   :=cm_apps_row.term_id;
      trx_class_name            :=cm_apps_row.trx_class_name;
      trx_class_code            :=cm_apps_row.trx_class_code;
      trx_type_name             :=cm_apps_row.trx_type_name;
      cust_trx_type_id          :=cm_apps_row.cust_trx_type_id;
      trx_date                  :=cm_apps_row.trx_date;
      location_name             :=cm_apps_row.location_name;
      bill_to_site_use_id       :=cm_apps_row.bill_to_site_use_id;
      days_late                 :=cm_apps_row.days_late;
      line_number               :=cm_apps_row.line_number;
      customer_trx_line_id      :=cm_apps_row.customer_trx_line_id;
      apply_date                :=cm_apps_row.apply_date;
      gl_date                   :=cm_apps_row.gl_date;
      gl_posted_date            :=cm_apps_row.gl_posted_date;
      reversal_gl_date          :=cm_apps_row.reversal_gl_date;
      exchange_rate             :=cm_apps_row.exchange_rate;
      invoice_currency_code     :=cm_apps_row.invoice_currency_code;
      amount_due_original       :=cm_apps_row.amount_due_original;
      amount_in_dispute         :=cm_apps_row.amount_in_dispute;
      amount_line_items_original:=cm_apps_row.amount_line_items_original;
      acctd_amount_due_remaining:=cm_apps_row.acctd_amount_due_remaining;
      acctd_amount_applied_to   :=cm_apps_row.acctd_amount_applied_to;
      acctd_amount_applied_from :=cm_apps_row.acctd_amount_applied_from;
      exchange_gain_loss        :=cm_apps_row.exchange_gain_loss;
      discount_remaining        :=cm_apps_row.discount_remaining;
      calc_discount_on_lines_flag:=cm_apps_row.calc_discount_on_lines_flag;
      partial_discount_flag     :=cm_apps_row.partial_discount_flag;
      allow_overapplication_flag:=cm_apps_row.allow_overapplication_flag;
      natural_application_only_flag:=cm_apps_row.natural_application_only_flag;
      creation_sign             :=cm_apps_row.creation_sign;
      applied_payment_schedule_id:=cm_apps_row.applied_payment_schedule_id;
      ussgl_transaction_code    :=cm_apps_row.ussgl_transaction_code;
      ussgl_transaction_code_context:=cm_apps_row.ussgl_transaction_code_context;
      purchase_order		:=cm_apps_row.purchase_order;
      trx_doc_sequence_id       :=cm_apps_row.trx_doc_sequence_id;
      trx_doc_sequence_value    :=cm_apps_row.trx_doc_sequence_value;
      trx_batch_source_name     :=cm_apps_row.trx_batch_source_name;
      amount_adjusted           :=cm_apps_row.amount_adjusted;
      amount_adjusted_pending   :=cm_apps_row.amount_adjusted_pending;
      amount_line_items_remaining:=cm_apps_row.amount_line_items_remaining;
      freight_original          :=cm_apps_row.freight_original;
      freight_remaining         :=cm_apps_row.freight_remaining;
      receivables_charges_remaining:=cm_apps_row.receivables_charges_remaining;
      tax_original              :=cm_apps_row.tax_original;
      tax_remaining             :=cm_apps_row.tax_remaining;
      selected_for_receipt_batch_id:=cm_apps_row.selected_for_receipt_batch_id;
      receivable_application_id :=cm_apps_row.receivable_application_id;
      attribute_category        :=cm_apps_row.attribute_category;
      attribute1                :=cm_apps_row.attribute1;
      attribute2                :=cm_apps_row.attribute2;
      attribute3                :=cm_apps_row.attribute3;
      attribute4                :=cm_apps_row.attribute4;
      attribute5                :=cm_apps_row.attribute5;
      attribute6                :=cm_apps_row.attribute6;
      attribute7                :=cm_apps_row.attribute7;
      attribute8                :=cm_apps_row.attribute8;
      attribute9                :=cm_apps_row.attribute9;
      attribute10               :=cm_apps_row.attribute10;
      attribute11               :=cm_apps_row.attribute11;
      attribute12               :=cm_apps_row.attribute12;
      attribute13               :=cm_apps_row.attribute13;
      attribute14               :=cm_apps_row.attribute14;
      attribute15               :=cm_apps_row.attribute15;
      trx_billing_number        :=cm_apps_row.trx_billing_number;
      global_attribute_category :=cm_apps_row.global_attribute_category;
      global_attribute1         :=cm_apps_row.global_attribute1;
      global_attribute2         :=cm_apps_row.global_attribute2;
      global_attribute3         :=cm_apps_row.global_attribute3;
      global_attribute4         :=cm_apps_row.global_attribute4;
      global_attribute5         :=cm_apps_row.global_attribute5;
      global_attribute6         :=cm_apps_row.global_attribute6;
      global_attribute7         :=cm_apps_row.global_attribute7;
      global_attribute8         :=cm_apps_row.global_attribute8;
      global_attribute9         :=cm_apps_row.global_attribute9;
      global_attribute10        :=cm_apps_row.global_attribute10;
      global_attribute11        :=cm_apps_row.global_attribute11;
      global_attribute12        :=cm_apps_row.global_attribute12;
      global_attribute13        :=cm_apps_row.global_attribute13;
      global_attribute14        :=cm_apps_row.global_attribute14;
      global_attribute15        :=cm_apps_row.global_attribute15;
      global_attribute16        :=cm_apps_row.global_attribute16;
      global_attribute17        :=cm_apps_row.global_attribute17;
      global_attribute18        :=cm_apps_row.global_attribute18;
      global_attribute19        :=cm_apps_row.global_attribute19;
      global_attribute20        :=cm_apps_row.global_attribute20;
      -- ARTA Changes
      transaction_category      := NULL;
      trx_gl_date               :=cm_apps_row.trx_gl_date;
      comments               :=cm_apps_row.comments;  -- bug 2662270
      receivables_trx_id	:=cm_apps_row.receivables_trx_id;   --
      rec_activity_name		:=cm_apps_row.rec_activity_name;   --
      application_ref_id	:=cm_apps_row.application_ref_id; -- CM refunds
      application_ref_num	:=cm_apps_row.application_ref_num; --
      application_ref_type	:=cm_apps_row.application_ref_type; --
      application_ref_type_meaning :=cm_apps_row.application_ref_type_meaning; --

      return(TRUE);

    ELSE

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'CM Apps has no more records so we will close it' );
      END IF;
      dbms_sql.close_cursor(c_cm_apps);
      return(FALSE);

    END IF;

  ELSE

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'Nothing to do!' );
    END IF;
    return(FALSE);

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'on_fetch()-' );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: ar_add_fetch_select.on_fetch');
   END IF;
   RAISE;

END on_fetch;

END ar_add_fetch_select;

/
