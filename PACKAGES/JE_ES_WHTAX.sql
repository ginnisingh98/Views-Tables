--------------------------------------------------------
--  DDL for Package JE_ES_WHTAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_ES_WHTAX" AUTHID CURRENT_USER AS
/* $Header: jeeswhts.pls 120.6.12010000.2 2009/07/03 15:51:29 rshergil ship $ */
/*#
 * This contains public interfaces to insert and delete spanish
 * external withholding transactions
 * @rep:scope public
 * @rep:product JE
 * @rep:displayname Spanish Withholding Tax Open Interface
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JE_ES_WHT
 */

/* Used to display PL/SQL Stored Procedure messages (to output)   */

	PROCEDURE plsqlmsg (	msg 			VARCHAR2);

/* Used to display SQL*PLUS messages */

	PROCEDURE dbmsmsg	(	msg 			VARCHAR2);

/* Used to DELETE transactions from JE_ES_MODELO_190_ALL */

/* Delete EXTERNAL transactions */
/*#
 * Delete external withholding tax transactions from the interface table
 * @param p_legal_entity_name Legal Entity Name
 * @param p_fin_ind Record Source
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete External Withholding Tax Transactions
*/
	PROCEDURE del_trans_x (		-- p_org_name	  	VARCHAR2,-- Bug 5207771 org_id removed
					p_legal_entity_name	VARCHAR2,
					p_fin_ind		VARCHAR2);

/* Delete Oracle Payables Hard Copy transactions */
	PROCEDURE del_trans_s (	p_conc_req_id 		NUMBER,
				p_legal_entity_id 	NUMBER,
				p_org_id		NUMBER);

/* Delete Oracle Payables Magnetic transactions */
	PROCEDURE del_trans_m (	p_legal_entity_id 	NUMBER,
				p_org_id		NUMBER);


/* Used to INSERT transactions into JE_ES_MODELO_190_ALL */

/* Insert EXTERNAL PAID transactions */

 /*#
  * Insert external paid withholding tax transactions into the interface table
  * @param p_legal_entity_name Legal Entity Identifier
  * @param p_fin_ind Record Source
  * @param p_remun_type Remuneration type
  * @param p_vendor_nif Supplier taxpayer identifier
  * @param p_vendor_name Supplier name
  * @param p_date_paid Paid Date
  * @param p_net_amount Net amount
  * @param p_withholding_tax_amount Withholding tax amount
  * @param p_zip_electronic Postal code/country
  * @param p_num_children Number of children
  * @param p_sign Sign of net amount
  * @param p_tax_rate Tax rate
  * @param p_year_due Year withholding tax is due
  * @param p_sub_remun_type Subtype of remuneration
  * @param p_withholdable_amt_in_kind Withholdable amount in kind
  * @param p_withheld_amt_in_kind Withheld amount in kind
  * @param p_withheld_pymt_amt_in_kind Withheld amounts for payments in kind
  * @param p_earned_amounts Amounts earned in Ceuta or Melilla
  * @param p_contract_type Type of contract
  * @param p_birth_year Year of birth
  * @param p_disabled Disabled
  * @param p_family_situation Family situation
  * @param p_partner_fiscal_code Partner's fiscal code
  * @param p_descendant_lt_3 Descendants less than 3 years old
  * @param p_descendant_bt_3_16 Descendants less than 3 and 16 years old
  * @param p_descendant_bt_16_25 Descendants between 16 and 25 years old
  * @param p_disable_desc_bt_33_65 Disabled descendants between 33% and 65%
  * @param p_disable_desc_gt_65 Disabled descendants more than 65%
  * @param p_descendant_total Total number of descendants
  * @param p_deductions Deductions
  * @param p_expenses  Expenses
  * @param p_spouse_maintenance_amt Maintenance of spouse
  * @param p_children_maintenance_amt Maintenance of children
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Insert External Withholding Paid Transactions
  */
	PROCEDURE ins_trans (	p_legal_entity_name	IN VARCHAR2,
--				p_org_name		IN VARCHAR2, -- Bug 5207771 org_id removed
				p_fin_ind		IN VARCHAR2,
				p_remun_type 		IN VARCHAR2,
				p_vendor_nif		IN VARCHAR2,
				p_vendor_name		IN VARCHAR2,
				p_date_paid		IN VARCHAR2,
				p_net_amount		IN NUMBER,
				p_withholding_tax_amount	IN NUMBER,
				p_zip_electronic	IN VARCHAR2,
				p_num_children		IN NUMBER,
				p_sign			IN VARCHAR2,
				p_tax_rate		IN NUMBER,
				p_year_due		IN NUMBER,
  				p_sub_remun_type 	IN VARCHAR2,
  				p_withholdable_amt_in_kind   IN NUMBER,
  				p_withheld_amt_in_kind       IN NUMBER,
  				p_withheld_pymt_amt_in_kind  IN NUMBER,
  				p_earned_amounts             IN NUMBER,
  				p_contract_type              IN NUMBER,
  				p_birth_year                 IN NUMBER,
  				p_disabled                   IN NUMBER,
  				p_family_situation           IN NUMBER,
  				p_partner_fiscal_code        IN VARCHAR2,
  				p_descendant_lt_3            IN NUMBER,
  				p_descendant_bt_3_16         IN NUMBER,
  				p_descendant_bt_16_25        IN NUMBER,
  				p_disable_desc_bt_33_65      IN NUMBER,
  				p_disable_desc_gt_65         IN NUMBER,
  				p_descendant_total           IN NUMBER,
  				p_deductions                 IN NUMBER,
  				p_expenses                   IN NUMBER,
  				p_spouse_maintenance_amt     IN NUMBER,
  				p_children_maintenance_amt   IN NUMBER
				);

/* Insert EXTERNAL APPROVED transactions */
 /*#
  * Insert external approved withholding tax transactions into the interface table
  * @param p_legal_entity_name Legal Entity Identifier
  * @param p_fin_ind Record Source
  * @param p_remun_type Remuneration type
  * @param p_vendor_nif Supplier taxpayer identifier
  * @param p_vendor_name Supplier name
  * @param p_gl_date General Ledger date
  * @param p_net_amount Net amount
  * @param p_withholding_tax_amount Withholding tax amount
  * @param p_zip_electronic Postal code/country
  * @param p_num_children Number of children
  * @param p_sign Sign of net amount
  * @param p_tax_rate Tax rate
  * @param p_year_due Year withholding tax is due
  * @param p_sub_remun_type Subtype of remuneration
  * @param p_withholdable_amt_in_kind Withholdable amount in kind
  * @param p_withheld_amt_in_kind Withheld amount in kind
  * @param p_withheld_pymt_amt_in_kind Withheld amounts for payments in kind
  * @param p_earned_amounts Amounts earned in Ceuta or Melilla
  * @param p_contract_type Type of contract
  * @param p_birth_year Year of birth
  * @param p_disabled Disabled
  * @param p_family_situation Family situation
  * @param p_partner_fiscal_code Partner's fiscal code
  * @param p_descendant_lt_3 Descendants less than 3 years old
  * @param p_descendant_bt_3_16 Descendants less than 3 and 16 years old
  * @param p_descendant_bt_16_25 Descendants between 16 and 25 years old
  * @param p_disable_desc_bt_33_65 Disabled descendants between 33% and 65%
  * @param p_disable_desc_gt_65 Disabled descendants more than 65%
  * @param p_descendant_total Total number of descendants
  * @param p_deductions Deductions
  * @param p_expenses  Expenses
  * @param p_spouse_maintenance_amt Maintenance of spouse
  * @param p_children_maintenance_amt Maintenance of children
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Insert External Withholding Approved Transactions
  */
	PROCEDURE ins_trans (	p_legal_entity_name	IN VARCHAR2,
--				p_org_name		IN VARCHAR2, -- Bug 5207771 org_id removed
				p_fin_ind		IN VARCHAR2,
				p_remun_type 		IN VARCHAR2,
				p_vendor_nif		IN VARCHAR2,
				p_vendor_name		IN VARCHAR2,
				p_gl_date		IN VARCHAR2,
				p_net_amount		IN NUMBER,
				p_withholding_tax_amount	IN NUMBER,
				p_zip_electronic	IN VARCHAR2,
				p_num_children		IN NUMBER,
				p_sign			IN VARCHAR2,
				p_tax_rate		IN NUMBER,
				p_year_due		IN NUMBER,
  				p_sub_remun_type 	IN VARCHAR2,
  				p_withholdable_amt_in_kind   IN NUMBER,
  				p_withheld_amt_in_kind       IN NUMBER,
  				p_withheld_pymt_amt_in_kind  IN NUMBER,
  				p_earned_amounts             IN NUMBER,
  				p_contract_type              IN NUMBER,
  				p_birth_year                 IN NUMBER,
  				p_disabled                   IN NUMBER,
  				p_family_situation           IN NUMBER,
  				p_partner_fiscal_code        IN VARCHAR2,
  				p_descendant_lt_3            IN NUMBER,
  				p_descendant_bt_3_16         IN NUMBER,
  				p_descendant_bt_16_25        IN NUMBER,
  				p_disable_desc_bt_33_65      IN NUMBER,
  				p_disable_desc_gt_65         IN NUMBER,
  				p_descendant_total           IN NUMBER,
  				p_deductions                 IN NUMBER,
  				p_expenses                   IN NUMBER,
  				p_spouse_maintenance_amt     IN NUMBER,
  				p_children_maintenance_amt   IN NUMBER
				);

/* Insert Oracle Payables transactions */

	PROCEDURE ins_trans (	legal_entity_id		NUMBER,
				org_id			NUMBER,
				conc_req_id		NUMBER,
				remun_type 		VARCHAR2,
				sub_remun_type 		VARCHAR2,
				vendor_nif 		VARCHAR2,
				vendor_name 		VARCHAR2,
				invoice_id		NUMBER,
				invoice_num		VARCHAR2,
				inv_doc_seq_num		VARCHAR2,
				invoice_date		VARCHAR2,
				gl_date 		VARCHAR2,
				invoice_payment_id	NUMBER,
				date_paid 		VARCHAR2,
				net_amount 		NUMBER,
				withholding_tax_amount 	NUMBER,
				zip_electronic 		VARCHAR2,
				zip_legal		VARCHAR2,
				city_legal		VARCHAR2,
				num_children 		NUMBER,
				sign 			VARCHAR2,
				tax_rate 		NUMBER,
				tax_name 		VARCHAR2,
				year_due 		NUMBER
				);

 FUNCTION get_payments_count(	l_invoice_id IN NUMBER,
				l_legal_entity_id IN NUMBER default null,
				l_org_id IN NUMBER default null) RETURN NUMBER;
 FUNCTION get_amount_withheld(	l_invoice_id IN NUMBER,
				l_org_id IN NUMBER default null,
				l_legal_entity_id IN NUMBER default null) RETURN NUMBER;
 FUNCTION get_prepaid_amount(	l_invoice_id IN NUMBER,
				l_org_id IN NUMBER default null,
				l_legal_entity_id IN NUMBER default null) RETURN NUMBER;
 FUNCTION get_awt_net_total(	l_invoice_id IN NUMBER,
				l_legal_entity_id IN NUMBER default null,
				l_org_id IN NUMBER default null,
				l_accounting_date IN DATE) RETURN NUMBER;

 PRAGMA RESTRICT_REFERENCES(get_payments_count, WNDS, WNPS, RNPS);
 PRAGMA RESTRICT_REFERENCES(get_prepaid_amount, WNDS, WNPS, RNPS);
 PRAGMA RESTRICT_REFERENCES(get_amount_withheld, WNDS, WNPS, RNPS);
 PRAGMA RESTRICT_REFERENCES(get_awt_net_total, WNDS, WNPS, RNPS);

/* Used to gather transactions */

	PROCEDURE get_data (	ERRBUF		OUT NOCOPY VARCHAR2,
				RETCODE		OUT NOCOPY NUMBER,
				p_pay_inv_sel		VARCHAR2,
				p_summary		VARCHAR2,
				p_date_from		VARCHAR2,
				p_date_to		VARCHAR2,
				p_vendor_id		NUMBER default null,
				p_conc_req_id		NUMBER default null,
				p_hard_copy		VARCHAR2 default null,
				p_wht_tax_type          VARCHAR2,
				p_legal_entity_id	NUMBER default null,
				p_org_id		NUMBER default null,
                                p_rep_site_ou           NUMBER);
END je_es_whtax;

/
