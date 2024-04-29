--------------------------------------------------------
--  DDL for Package ARP_PS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PS_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARCUPSS.pls 120.8.12010000.3 2010/06/16 22:00:05 rravikir ship $*/
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_reverse_actions                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure performs all actions to modify the passed in            |
 |    user defined application record and prepares to update payment schedule|
 |    table                                                                  |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_app_rec - Application Record structure                 |
 |                  p_module_name _ Name of module that called this procedure|
 |                  p_module_version - Version of module that called this    |
 |                                     procedure                             |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_reverse_actions(
                p_app_rec         IN arp_global.app_rec_type,
                p_module_name     IN VARCHAR2,
                p_module_version  IN VARCHAR2);
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_receipt_related_columns                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the receipt related rows of a payment schedule|
 |      The passed in PS ID is assumed to belong to a receipt. The procedure |
 |      sets the gl_date and gl_date_closed and amount applied. The procedure|
 |      should be called whenever a receipt is applied to an invoice.        |
 |      The procedure also return the acctd_amount_applied to populate the   |
 |      acctd_amount_applied_from column during AR_RA row insertion          |
 |                                                                           |
 | PARAMETERS :                                                              |
 |         IN : p_payment_schedule_id - payment_schedule_id of payment       |
 |              schedule                                                     |
 |              p_gldate - GL date of the receipt                            |
 |              p_apply_date - Apply Date of the receipt                     |
 |              p_amount_applied - Amount of the receipt applied to the      |
 |                                 invoice.                                  |
 |              p_module_name - Name of module that called this routine      |
 |              p_module_version - Version of module that called this routine|
 |              p_maturity_date - PS.due_date for receipt.
 |        OUT NOCOPY : p_acctd_amount_applied_out - Accounted amount applied used to|
 |                         populate acctd_amount_applied_from in AR_RA table |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_receipt_related_columns(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied IN ar_payment_schedules.amount_applied%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_applied  OUT NOCOPY
                 ar_receivable_applications.acctd_amount_applied_from%TYPE,
                p_ps_rec IN ar_payment_schedules%ROWTYPE,
                p_maturity_date IN ar_payment_schedules.due_date%TYPE DEFAULT NULL,
				p_applied_ps_class IN ar_payment_schedules.class%TYPE DEFAULT NULL); -- For Bug 6924942
--
-- deleted 'DEFAULT NULL' for p_ps_rec Rowtype attribute -bug460979 for Oracle8
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_invoice_related_columns   (original)                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the invoice related rows of a payment schedule|
 |      The passed in PS ID is assumed to belong to a invoice. The procedure |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever a receipt is applied to an       |
 |      invoice. The procedure also returns the acctd_amount_applied,        |
 |      acctd_earned_discount_taken, acctd_unearned_discount_taken columns,  |
 |      line_applied, tax_applied, freight_applied, charges_applied columns  |
 |      to populate the RA columns during AR_RA row insertion                |
 |      insertion          						     |
 |
 |       NOTE:  This version will not call etax ever.  Use overloaded
 |        version if etax call for discounts is required
 | PARAMETERS :                                                              |
 |    IN : p_app_type            - Indicates the type of application         |
 |                                 Valid values are CASH for receipt         |
 |                                 application and CM fro credit memo appln. |
 |         p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_amount_applied      - Amount of the receipt applied to the      |
 |                                 invoice                                   |
 |         p_discount_taken_earned   - Earned discount taken(NULL if CM      |
 |                                     appln                                 |
 |         p_discount_taken_unearned - Unearned discount taken(NULL if CM    |
 |                                     appln                                 |
 |         p_ps_rec                  - Payment Schedule record, If this field|
 |                                     is not null, the PS record is not     |
 |                                     fetched using p_ps_id. This PS record |
 |                                     is used                               |
 |   OUT NOCOPY : p_acctd_amount_applied     - Accounted amount applied used to     |
 |                                      populate acctd_amount_applied_from in|
 |                                      AR_RA table                          |
 |         p_acctd_discount_taken_earned - Accounted discount taken earned to|
 |                                      populate acctd_discount_taken_earned |
 |                                      AR_RA table. This field is not       |
 |                                      populated if application is of type  |
 |                                      CM. It is NULL is app. type is CM.   |
 |         p_acctd_disc_taken_unearned - Accounted discount taken unearned to|
 |                                      populate acctd_discount_taken_uneard |
 |                                      AR_RA table. This field is not       |
 |                                      populated if application is of type  |
 |                                      CM. It is NULL is app. type is CM.   |
 |         p_tax_applied              - Part of the applied amount applied to|
 |                                      tax                                  |
 |         p_freight_applied          - Part of the applied amount applied to|
 |                                      freight                              |
 |         p_line_applied             - Part of the applied amount applied to|
 |                                      lines                                |
 |         p_charges_applied          - Part of the applied amount applied to|
 |                                      receivable charges                   |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 |   29-AUG-05   M Raymond          4566510 - Changed p_line_ediscounted,
 |                                    p_line_uediscounted, p_tax_ediscounted,
 |                                    and p_tax_uediscounted to IN OUT NOCOPY
 |                                    so I can pass in discounts when
 |                                    already prorated by etax.
 |   19-DEC-06   M Raymond          5677984 - adding overloaded version of this
 |                                    procedure (see definition below)
 +===========================================================================*/
PROCEDURE update_invoice_related_columns(
                p_app_type  IN VARCHAR2,
                p_ps_id     IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied          IN ar_payment_schedules.amount_applied%TYPE,
                p_discount_taken_earned   IN ar_payment_schedules.discount_taken_earned%TYPE,
                p_discount_taken_unearned IN ar_payment_schedules.discount_taken_unearned%TYPE,
                p_apply_date              IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date                 IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_applied    OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_acctd_earned_discount_taken OUT NOCOPY ar_receivable_applications.earned_discount_taken%TYPE,
                p_acctd_unearned_disc_taken   OUT NOCOPY ar_receivable_applications.acctd_unearned_discount_taken%TYPE,
                p_line_applied     OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_applied      OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_applied  OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_applied  OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_line_ediscounted IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_ediscounted  IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_ediscounted  OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_ediscounted  OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_line_uediscounted   IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_uediscounted    IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_uediscounted OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_uediscounted OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_rule_set_id          OUT NOCOPY number,
                p_ps_rec               IN  ar_payment_schedules%ROWTYPE);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_invoice_related_columns (overloaded)                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure is a wrapper for the original one of same name
 |      with two additional parameters.  This allows us to control
 |      use of etax calls inside this routine and mask the out parameter
 |      for receivable_application_id from calls that do not require it.
 |      You should use this signature for receipt applications.  Others
 |      may not require or need the etax call functionality.
 |                                                                           |
 | PARAMETERS :                                                              |
 |    IN : p_app_type            - Indicates the type of application         |
 |                                 Valid values are CASH for receipt         |
 |                                 application and CM fro credit memo appln. |
 |         p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_amount_applied      - Amount of the receipt applied to the      |
 |                                 invoice                                   |
 |         p_discount_taken_earned   - Earned discount taken(NULL if CM      |
 |                                     appln                                 |
 |         p_discount_taken_unearned - Unearned discount taken(NULL if CM    |
 |                                     appln                                 |
 |         p_ps_rec                  - Payment Schedule record, If this field|
 |                                     is not null, the PS record is not     |
 |                                     fetched using p_ps_id. This PS record |
 |                                     is used                               |
 |         p_cash_receipt_id          - CR ID (if null, do not call etax)
 |
 |   OUT NOCOPY : p_acctd_amount_applied     - Accounted amount applied used to     |
 |                                      populate acctd_amount_applied_from in|
 |                                      AR_RA table                          |
 |         p_acctd_discount_taken_earned - Accounted discount taken earned to|
 |                                      populate acctd_discount_taken_earned |
 |                                      AR_RA table. This field is not       |
 |                                      populated if application is of type  |
 |                                      CM. It is NULL is app. type is CM.   |
 |         p_acctd_disc_taken_unearned - Accounted discount taken unearned to|
 |                                      populate acctd_discount_taken_uneard |
 |                                      AR_RA table. This field is not       |
 |                                      populated if application is of type  |
 |                                      CM. It is NULL is app. type is CM.   |
 |         p_tax_applied              - Part of the applied amount applied to|
 |                                      tax                                  |
 |         p_freight_applied          - Part of the applied amount applied to|
 |                                      freight                              |
 |         p_line_applied             - Part of the applied amount applied to|
 |                                      lines                                |
 |         p_charges_applied          - Part of the applied amount applied to|
 |                                      receivable charges
 |         p_ra_app_id                - receivable app ID returned from etax
 |                                      logic.
 |         p_gt_id                    - ID related to SLA accounting data.
 |
 | HISTORY - Created By - mraymond - 12/19/2006                         |
 |                                                                           |
 |   19-DEC-06   M Raymond          5677984 - adding parameters for
 |                                    cash_receipt_id, ra_app_id, and gt_id
 |                                    to update_invoice_related_columns
 |                                    to facilitate etax disc proration.
 +===========================================================================*/
PROCEDURE update_invoice_related_columns(
                p_app_type  IN VARCHAR2,
                p_ps_id     IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied          IN ar_payment_schedules.amount_applied%TYPE,
                p_discount_taken_earned   IN ar_payment_schedules.discount_taken_earned%TYPE,
                p_discount_taken_unearned IN ar_payment_schedules.discount_taken_unearned%TYPE,
                p_apply_date              IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date                 IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_applied    OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_acctd_earned_discount_taken OUT NOCOPY ar_receivable_applications.earned_discount_taken%TYPE,
                p_acctd_unearned_disc_taken   OUT NOCOPY ar_receivable_applications.acctd_unearned_discount_taken%TYPE,
                p_line_applied     OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_applied      OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_applied  OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_applied  OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_line_ediscounted IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_ediscounted  IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_ediscounted  OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_ediscounted  OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_line_uediscounted   IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_uediscounted    IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_uediscounted OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_uediscounted OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_rule_set_id          OUT NOCOPY number,
                p_ps_rec               IN  ar_payment_schedules%ROWTYPE,
                p_cash_receipt_id      IN ar_receivable_applications_all.cash_receipt_id%TYPE,
                p_ra_app_id            OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
                p_gt_id                OUT NOCOPY NUMBER);


--
-- deleted 'DEFAULT NULL' for p_ps_rec Rowtype attribute -bug460979 for Oracle8

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_cm_related_columns                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the CM      related rows of a payment schedule|
 |      The passed in PS ID is assumed to belong to a CM. The procedure      |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever a receipt is applied to an       |
 |      invoice.                                                             |
 |                                                                           |
 | PARAMETERS :                                                              |
 |    IN : p_payment_schedule_id - payment_schedule_id of Credir Memo        |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_amount_applied      - Amount of the CM      applied to the      |
 |                                 invoice                                   |
 |         p_ps_rec              - Payment Schedule record, If this field    |
 |                                 is not null, the PS record is not         |
 |                                 fetched using p_ps_id. This PS record     |
 |                                 is used                                   |
 |         p_update_credit_flag  - For CM refunds, to indicate if amount     |
 |				   credited should be updated                |
 |   OUT NOCOPY : p_acctd_amount_applied  - Accounted amount applied used to        |
 |                                   populate acctd_amount_applied_from in   |
 |                                   AR_RA table                             |
 |         p_tax_applied           - Part of the applied amount applied to   |
 |                                   tax, This field will populate           |
 |                                   TAX_REMAINING in RA table               |
 |         p_freight_applied       - Part of the applied amount applied to   |
 |                                   freight, This field will populate       |
 |                                   FREIGHT_REMAINING in RA table           |
 |         p_line_applied          - Part of the applied amount applied to   |
 |                                   lines, This field will populate         |
 |                                   LINE_REMAINING in RA table              |
 |         p_charges_applied       - Part of the applied amount applied to   |
 |                                   receivable charges, This field will     |
 |                                   populate CHARGES_REMAINING in RA        |
 |                                   table                                   |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_cm_related_columns(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied IN ar_payment_schedules.amount_applied%TYPE,
                p_line_applied IN ar_receivable_applications.line_applied%TYPE,
                p_tax_applied IN ar_receivable_applications.tax_applied%TYPE,
                p_freight_applied IN
                            ar_receivable_applications.freight_applied%TYPE,
                p_charges_applied  IN
                   ar_receivable_applications.receivables_charges_applied%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_applied  OUT NOCOPY
                        ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_ps_rec IN ar_payment_schedules%ROWTYPE,
		p_update_credit_flag IN VARCHAR2 DEFAULT NULL );
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_adj_related_columns                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the Adjustments related rows of a PS record   |
 |      The passed in PS ID is assumed to belong to an adjustment. Procedure |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever an invoice is adjusted.          |
 |                                                                           |
 | PARAMETERS :                                                              |
 |   IN :  p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_tax_adjusted        - Part of the adjusted amount to be applied |
 |                                 to tax                                    |
 |         p_freight_applied     - Part of the adjusted amount to be applied |
 |                                 to freight                                |
 |         p_line_applied        - Part of the adjusted amount to be applied |
 |                                 to lines                                  |
 |         p_charges_applied     - Part of the adjusted amount to be applied |
 |                                 to receivable charges                     |
 |         p_amount_adjusted_pending - Amount adjsuted pending if any.       |
 |                                                                           |
 | NOTES - At present this is an overloaded procedure                        |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_adj_related_columns(
                p_ps_id            IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_line_adjusted    IN ar_receivable_applications.line_applied%TYPE,
                p_tax_adjusted     IN ar_receivable_applications.tax_applied%TYPE,
                p_freight_adjusted IN ar_receivable_applications.freight_applied%TYPE,
                p_charges_adjusted IN ar_receivable_applications.receivables_charges_applied%TYPE,
                p_amount_adjusted_pending IN ar_payment_schedules.amount_adjusted_pending%TYPE,
                p_apply_date       IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date          IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_adjusted  OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_ps_rec           IN  OUT NOCOPY ar_payment_schedules%ROWTYPE);

-- deleted 'DEFAULT NULL' for p_ps_rec Rowtype attribute -bug460979 for Oracle8
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_adj_related_columns                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the Adjustments related rows of a PS record   |
 |      The passed in PS ID is assumed to belong to an adjustment. Procedure |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever an invoice is adjusted.          |
 |      In case of an invoice adjustment, the procedure also calculates the  |
 |      line_adjusted, tax_adjusted, charges_adjusted and freight_adjusted   |
 |      amounts.                                                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |   IN :  p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_type                - Adjustment type - valid values are        |
 |                                 'INVOICE', 'FREIGHT', 'TAX', 'LINE',      |
 |                                 'CHARGES', NULL(In case of pendings only) |
 |                                 There is no explicit check to make sure   |
 |                                 that the type value is one of the above   |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_amount_adjusted     - Amount adjusted if type is not 'INVOICE'  |
 |         p_amount_adjusted_pending - Amount adjusted pending if any.       |
 |   IN :  p_line_adjusted       - Line adjusted - In case of INVOICE adj.   |
 |         p_tax_adjusted        - Tax  adjusted - In case of INVOICE adj.   |
 |         p_charges_adjusted    - charges adjusted - In case of INVOICE adj.|
 |         p_freight_adjusted    - freight adjusted - In case of INVOICE adj.|
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION						     |
 |        arp_util.calc_acctd_amount and arp_util.debug                      |
 |        arp_ps_pkg.fetch_p and arp_ps_pkg.update_p                         |
 |                                                                           |
 | NOTES - At present this is an overloaded procedure                        |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 | 02/03/2000   Saloni Shah     Modified parameter p_freight_adjusted to be  |
 |				IN OUT NOCOPY in update_adj_related_columns         |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_adj_related_columns(
                p_ps_id           IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_type            IN ar_adjustments.type%TYPE,
                p_amount_adjusted IN ar_payment_schedules.amount_adjusted%TYPE,
                p_amount_adjusted_pending IN ar_payment_schedules.amount_adjusted_pending%TYPE,
                p_line_adjusted    IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_adjusted     IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_adjusted IN OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_adjusted IN OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_apply_date       IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date          IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_adjusted OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_ps_rec           IN OUT NOCOPY ar_payment_schedules%ROWTYPE);
--
-- deleted 'DEFAULT NULL' for p_ps_rec Rowtype attribute -bug460979 for Oracle8

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Get gl_date_closed and actual_date_closed                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Determines gl_date_closed and actual_date_closed for a payment       |
 |      schedule. For each of the two, it returns the greatest date from     |
 |      ar_receivable_applications, ar_adjustments, and the input current    |
 |      date. If it finds no values for a date, a null string is returned.   |
 |                                                                           |
 |      NOTE: This function does not correctly handle applications for future|
 |      items or future cash receipts. If an application or adjustment that  |
 |      closes an item has gl_date/apply_date less than the item's           |
 |      gl_date/trx_date or the cash receipt's gl_date/deposit_date, then the|
 |      gl_date_closed/actual_date_closed should be the greatest dates - the |
 |      ones from the item or cash receipt. The dates returned by armclps    |
 |      will be less than the correct ones because this function selects     |
 |      only from ar_receivable_applications, ar_adjustments and the input   |
 |      "current" dates.
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS : p_payment_schedule_id - payment_schedule_id of payment       |
 |              schedule                                                     |
 |              p_gl_reversal_date - gl_date of current uncommitted          |
 |                                   transaction                             |
 |              p_reversal_date - apply date of current uncommitted xtion    |
 |              p_gl_date_closed - greatest of ar_adjustments.gl_date,       |
 |                                ar_receivable_applications.gl_date, and    |
 |                                current_gl_date.                           |
 |              p_actual_date_closed - (output) greatest of                  |
 |                                   ar_adjustments.apply_date,              |
 |                                   ar_receivable_applications.apply_date,  |
 |                                   and current_apply_date.                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_closed_dates( p_ps_id 		IN NUMBER,
                           p_gl_reversal_date 	IN DATE,
                           p_reversal_date 	IN DATE,
                           p_gl_date_closed 	OUT NOCOPY DATE,
                           p_actual_date_closed OUT NOCOPY DATE ,
                           p_app_type 		IN CHAR );

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    populate_closed_dates                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure takes in a payment schedule record structure, gl_date |
 |      apply_date, application type and populates the payment schedule      |
 |      record structure with gl_date_closed and   actual_date_closed        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |    IN : p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_app_type            - Application Type - 'CASH', 'CM', 'INV'    |
 |                                 'ADJ'                                     |
 | IN/OUT: p_ps_rec               - Payment Schedule record                  |
 |                                 PS id to be populated in input PS record  |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION                                              |
 |        get_closed_dates - This procedure is in this package               |
 |                                                                           |
 | NOTES - Expectes PS id to be populated in input PS record                 |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 | 16-APR-98 GJWANG       Bug Fix: 653643 declare this as public procedure   |
 |                                                                           |
 +===========================================================================*/
PROCEDURE populate_closed_dates(
              p_gl_date IN ar_payment_schedules.gl_date%TYPE,
              p_apply_date IN ar_payment_schedules.gl_date%TYPE,
              p_app_type  IN VARCHAR2,
              p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE );


END ARP_PS_UTIL;

/
