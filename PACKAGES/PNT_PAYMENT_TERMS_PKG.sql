--------------------------------------------------------
--  DDL for Package PNT_PAYMENT_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_PAYMENT_TERMS_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTPYTRS.pls 120.7 2007/05/31 06:33:31 lbala ship $

   tlinfo   PN_PAYMENT_TERMS_ALL%ROWTYPE;

   TYPE dist_rec IS RECORD(
    distribution_id    PN_DISTRIBUTIONS.distribution_id%TYPE,
    account_id         PN_DISTRIBUTIONS.account_id%TYPE,
    account_class      PN_DISTRIBUTIONS.account_class%TYPE,
    percentage         PN_DISTRIBUTIONS.percentage%TYPE,
    line_number        PN_DISTRIBUTIONS.line_number%TYPE,
    attribute_category PN_DISTRIBUTIONS.attribute_category%TYPE,
    attribute1         PN_DISTRIBUTIONS.attribute1%TYPE,
    attribute2         PN_DISTRIBUTIONS.attribute2%TYPE,
    attribute3         PN_DISTRIBUTIONS.attribute3%TYPE,
    attribute4         PN_DISTRIBUTIONS.attribute4%TYPE,
    attribute5         PN_DISTRIBUTIONS.attribute5%TYPE,
    attribute6         PN_DISTRIBUTIONS.attribute6%TYPE,
    attribute7         PN_DISTRIBUTIONS.attribute7%TYPE,
    attribute8         PN_DISTRIBUTIONS.attribute8%TYPE,
    attribute9         PN_DISTRIBUTIONS.attribute9%TYPE,
    attribute10        PN_DISTRIBUTIONS.attribute10%TYPE,
    attribute11        PN_DISTRIBUTIONS.attribute11%TYPE,
    attribute12        PN_DISTRIBUTIONS.attribute12%TYPE,
    attribute13        PN_DISTRIBUTIONS.attribute13%TYPE,
    attribute14        PN_DISTRIBUTIONS.attribute14%TYPE,
    attribute15        PN_DISTRIBUTIONS.attribute15%TYPE,
    term_template_id   PN_DISTRIBUTIONS.term_template_id%TYPE,
    org_id             PN_DISTRIBUTIONS.org_id%TYPE);

   TYPE dist_type IS
    TABLE OF dist_rec
    INDEX BY BINARY_INTEGER;

   hist_dist_tab  dist_type;

PROCEDURE INSERT_ROW (
                       x_rowid                         IN OUT NOCOPY VARCHAR2,
                       x_payment_term_id               IN OUT NOCOPY NUMBER,
                       x_payment_purpose_code          IN     VARCHAR2,
                       x_payment_term_type_code        IN     VARCHAR2,
                       x_frequency_code                IN     VARCHAR2,
                       x_lease_id                      IN     NUMBER,
                       x_lease_change_id               IN     NUMBER,
                       x_start_date                    IN     DATE,
                       x_end_date                      IN     DATE,
                       x_vendor_id                     IN     NUMBER   DEFAULT NULL,
                       x_vendor_site_id                IN     NUMBER   DEFAULT NULL,
                       x_customer_id                   IN     NUMBER   DEFAULT NULL,
                       x_customer_site_use_id          IN     NUMBER   DEFAULT NULL,
                       x_target_date                   IN     DATE     DEFAULT NULL,
                       x_actual_amount                 IN     NUMBER,
                       x_estimated_amount              IN     NUMBER,
                       x_set_of_books_id               IN     NUMBER,
                       x_currency_code                 IN     VARCHAR2,
                       x_rate                          IN     NUMBER,
                       x_normalize                     IN     VARCHAR2 DEFAULT NULL,
                       x_location_id                   IN     NUMBER   DEFAULT NULL,
                       x_schedule_day                  IN     NUMBER   DEFAULT NULL,
                       x_cust_ship_site_id             IN     NUMBER   DEFAULT NULL,
                       x_ap_ar_term_id                 IN     NUMBER   DEFAULT NULL,
                       x_cust_trx_type_id              IN     NUMBER   DEFAULT NULL,
                       x_project_id                    IN     NUMBER   DEFAULT NULL,
                       x_task_id                       IN     NUMBER   DEFAULT NULL,
                       x_organization_id               IN     NUMBER   DEFAULT NULL,
                       x_expenditure_type              IN     VARCHAR2 DEFAULT NULL,
                       x_expenditure_item_date         IN     DATE     DEFAULT NULL,
                       x_tax_group_id                  IN     NUMBER   DEFAULT NULL,
                       x_tax_code_id                   IN     NUMBER   DEFAULT NULL,
                       x_tax_classification_code       IN     VARCHAR2 DEFAULT NULL,
                       x_tax_included                  IN     VARCHAR2 DEFAULT NULL,
                       x_distribution_set_id           IN     NUMBER   DEFAULT NULL,
                       x_inv_rule_id                   IN     NUMBER   DEFAULT NULL,
                       x_account_rule_id               IN     NUMBER   DEFAULT NULL,
                       x_salesrep_id                   IN     NUMBER   DEFAULT NULL,
                       x_approved_by                   IN     NUMBER   DEFAULT NULL,
                       x_status                        IN     VARCHAR2 DEFAULT NULL,
                       x_index_period_id               IN     NUMBER   DEFAULT NULL,
                       x_index_term_indicator          IN     VARCHAR2 DEFAULT NULL,
                       x_po_header_id                  IN     NUMBER   DEFAULT NULL,
                       x_cust_po_number                IN     VARCHAR2 DEFAULT NULL,
                       x_receipt_method_id             IN     NUMBER   DEFAULT NULL,
                       x_var_rent_inv_id               IN     NUMBER   DEFAULT NULL,
                       x_var_rent_type                 IN     VARCHAR2 DEFAULT NULL,
                       x_period_billrec_id             IN     NUMBER   DEFAULT NULL,
                       x_rec_agr_line_id               IN     NUMBER   DEFAULT NULL,
                       x_amount_type                   IN     VARCHAR2 DEFAULT NULL,
                       x_changed_flag                  IN     VARCHAR2 DEFAULT NULL,
                       x_term_template_id              IN     NUMBER   DEFAULT NULL,
                       x_attribute_category            IN     VARCHAR2 DEFAULT NULL,
                       x_attribute1                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute2                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute3                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute4                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute5                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute6                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute7                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute8                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute9                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute10                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute11                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute12                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute13                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute14                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute15                   IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute_category    IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute1            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute2            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute3            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute4            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute5            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute6            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute7            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute8            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute9            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute10           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute11           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute12           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute13           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute14           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute15           IN     VARCHAR2 DEFAULT NULL,
                       x_creation_date                 IN     DATE,
                       x_created_by                    IN     NUMBER,
                       x_last_update_date              IN     DATE,
                       x_last_updated_by               IN     NUMBER,
                       x_last_update_login             IN     NUMBER,
                       x_calling_form                  IN     VARCHAR2 DEFAULT 'PNTLEASE',
                       x_org_id                        IN     NUMBER,
                       x_lease_status                  IN     VARCHAR2 DEFAULT 'ACT',
                       x_recoverable_flag              IN     VARCHAR2 DEFAULT NULL,
                       x_area_type_code                IN     VARCHAR2 DEFAULT NULL,
                       x_area                          IN     NUMBER   DEFAULT NULL,
                       x_grouping_rule_id              IN     NUMBER   DEFAULT NULL,
                       x_term_altered_flag             IN     VARCHAR2 DEFAULT NULL,
                       x_source_code                   IN     VARCHAR2 DEFAULT NULL,
                       x_term_comments                 IN     VARCHAR2 DEFAULT NULL,
                       x_norm_start_date               IN     DATE     DEFAULT NULL,
                       x_parent_term_id                IN     NUMBER   DEFAULT NULL,
                       x_index_norm_flag               IN     VARCHAR2 DEFAULT NULL,
                       x_include_in_var_rent           IN     VARCHAR2 DEFAULT NULL,         --03-NOV-2003
                       x_recur_bb_calc_date            IN     DATE     DEFAULT NULL,
                       x_opex_agr_id                   IN     NUMBER   DEFAULT NULL,
                       x_opex_recon_id                 IN     NUMBER   DEFAULT NULL,
                       x_opex_type                     IN     VARCHAR2 DEFAULT NULL
                     );

PROCEDURE LOCK_ROW (
                       x_payment_term_id               IN     NUMBER,
                       x_payment_purpose_code          IN     VARCHAR2,
                       x_payment_term_type_code        IN     VARCHAR2,
                       x_frequency_code                IN     VARCHAR2,
                       x_lease_id                      IN     NUMBER,
                       x_lease_change_id               IN     NUMBER,
                       x_start_date                    IN     DATE,
                       x_end_date                      IN     DATE,
                       x_vendor_id                     IN     NUMBER   DEFAULT NULL,
                       x_vendor_site_id                IN     NUMBER   DEFAULT NULL,
                       x_customer_id                   IN     NUMBER   DEFAULT NULL,
                       x_customer_site_use_id          IN     NUMBER   DEFAULT NULL,
                       x_target_date                   IN     DATE,
                       x_actual_amount                 IN     NUMBER,
                       x_estimated_amount              IN     NUMBER,
                       x_set_of_books_id               IN     NUMBER,
                       x_currency_code                 IN     VARCHAR2,
                       x_rate                          IN     NUMBER,
                       x_normalize                     IN     VARCHAR2 DEFAULT NULL,
                       x_location_id                   IN     NUMBER   DEFAULT NULL,
                       x_schedule_day                  IN     NUMBER   DEFAULT NULL,
                       x_cust_ship_site_id             IN     NUMBER   DEFAULT NULL,
                       x_ap_ar_term_id                 IN     NUMBER   DEFAULT NULL,
                       x_cust_trx_type_id              IN     NUMBER   DEFAULT NULL,
                       x_project_id                    IN     NUMBER   DEFAULT NULL,
                       x_task_id                       IN     NUMBER   DEFAULT NULL,
                       x_organization_id               IN     NUMBER   DEFAULT NULL,
                       x_expenditure_type              IN     VARCHAR2 DEFAULT NULL,
                       x_expenditure_item_date         IN     DATE     DEFAULT NULL,
                       x_tax_group_id                  IN     NUMBER   DEFAULT NULL,
                       x_tax_code_id                   IN     NUMBER   DEFAULT NULL,
                       x_tax_classification_code       IN     VARCHAR2 DEFAULT NULL,
                       x_tax_included                  IN     VARCHAR2 DEFAULT NULL,
                       x_distribution_set_id           IN     NUMBER   DEFAULT NULL,
                       x_inv_rule_id                   IN     NUMBER   DEFAULT NULL,
                       x_account_rule_id               IN     NUMBER   DEFAULT NULL,
                       x_salesrep_id                   IN     NUMBER   DEFAULT NULL,
                       x_approved_by                   IN     NUMBER   DEFAULT NULL,
                       x_status                        IN     VARCHAR2 DEFAULT NULL,
                       x_index_period_id               IN     NUMBER   DEFAULT NULL,
                       x_index_term_indicator          IN     VARCHAR2 DEFAULT NULL,
                       x_po_header_id                  IN     NUMBER   DEFAULT NULL,
                       x_cust_po_number                IN     VARCHAR2 DEFAULT NULL,
                       x_receipt_method_id             IN     NUMBER   DEFAULT NULL,
                       x_var_rent_inv_id               IN     NUMBER   DEFAULT NULL,
                       x_var_rent_type                 IN     VARCHAR2 DEFAULT NULL,
                       x_changed_flag                  IN     VARCHAR2 DEFAULT NULL,
                       x_attribute_category            IN     VARCHAR2 DEFAULT NULL,
                       x_attribute1                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute2                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute3                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute4                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute5                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute6                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute7                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute8                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute9                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute10                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute11                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute12                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute13                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute14                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute15                   IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute_category    IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute1            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute2            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute3            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute4            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute5            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute6            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute7            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute8            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute9            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute10           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute11           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute12           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute13           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute14           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute15           IN     VARCHAR2 DEFAULT NULL,
                       x_recoverable_flag              IN     VARCHAR2,
                       x_area_type_code                IN     VARCHAR2,
                       x_area                          IN     NUMBER,
                       x_grouping_rule_id              IN     NUMBER   DEFAULT NULL,
                       x_term_comments                 IN     VARCHAR2 DEFAULT NULL,
                       x_term_template_id              IN     NUMBER   DEFAULT NULL,
                       x_include_in_var_rent           IN     VARCHAR2 DEFAULT NULL,         --03-NOV-2003
                       x_recur_bb_calc_date            IN     DATE     DEFAULT NULL,
                       x_opex_agr_id                   IN     NUMBER   DEFAULT NULL,
                       x_opex_recon_id                 IN     NUMBER   DEFAULT NULL,
                       x_opex_type                     IN     VARCHAR2 DEFAULT NULL
                     );

PROCEDURE UPDATE_ROW (
                       x_payment_term_id               IN     NUMBER,
                       x_payment_purpose_code          IN     VARCHAR2,
                       x_payment_term_type_code        IN     VARCHAR2,
                       x_frequency_code                IN     VARCHAR2,
                       x_lease_id                      IN     NUMBER,
                       x_lease_change_id               IN     NUMBER,
                       x_start_date                    IN     DATE,
                       x_end_date                      IN     DATE,
                       x_vendor_id                     IN     NUMBER   DEFAULT NULL,
                       x_vendor_site_id                IN     NUMBER   DEFAULT NULL,
                       x_customer_id                   IN     NUMBER   DEFAULT NULL,
                       x_customer_site_use_id          IN     NUMBER   DEFAULT NULL,
                       x_target_date                   IN     DATE,
                       x_actual_amount                 IN     NUMBER,
                       x_estimated_amount              IN     NUMBER,
                       x_set_of_books_id               IN     NUMBER,
                       x_currency_code                 IN     VARCHAR2,
                       x_rate                          IN     NUMBER,
                       x_normalize                     IN     VARCHAR2 DEFAULT NULL,
                       x_location_id                   IN     NUMBER   DEFAULT NULL,
                       x_schedule_day                  IN     NUMBER   DEFAULT NULL,
                       x_cust_ship_site_id             IN     NUMBER   DEFAULT NULL,
                       x_ap_ar_term_id                 IN     NUMBER   DEFAULT NULL,
                       x_cust_trx_type_id              IN     NUMBER   DEFAULT NULL,
                       x_project_id                    IN     NUMBER   DEFAULT NULL,
                       x_task_id                       IN     NUMBER   DEFAULT NULL,
                       x_organization_id               IN     NUMBER   DEFAULT NULL,
                       x_expenditure_type              IN     VARCHAR2 DEFAULT NULL,
                       x_expenditure_item_date         IN     DATE     DEFAULT NULL,
                       x_tax_group_id                  IN     NUMBER   DEFAULT NULL,
                       x_tax_code_id                   IN     NUMBER   DEFAULT NULL,
                       x_tax_classification_code       IN     VARCHAR2 DEFAULT NULL,
                       x_tax_included                  IN     VARCHAR2 DEFAULT NULL,
                       x_distribution_set_id           IN     NUMBER   DEFAULT NULL,
                       x_inv_rule_id                   IN     NUMBER   DEFAULT NULL,
                       x_account_rule_id               IN     NUMBER   DEFAULT NULL,
                       x_salesrep_id                   IN     NUMBER   DEFAULT NULL,
                       x_approved_by                   IN     NUMBER   DEFAULT NULL,
                       x_status                        IN     VARCHAR2 DEFAULT NULL,
                       x_index_period_id               IN     NUMBER   DEFAULT NULL,
                       x_index_term_indicator          IN     VARCHAR2 DEFAULT NULL,
                       x_po_header_id                  IN     NUMBER   DEFAULT NULL,
                       x_cust_po_number                IN     VARCHAR2 DEFAULT NULL,
                       x_receipt_method_id             IN     NUMBER   DEFAULT NULL,
                       x_var_rent_inv_id               IN     NUMBER   DEFAULT NULL,
                       x_var_rent_type                 IN     VARCHAR2 DEFAULT NULL,
                       x_changed_flag                  IN     VARCHAR2 DEFAULT NULL,
                       x_attribute_category            IN     VARCHAR2 DEFAULT NULL,
                       x_attribute1                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute2                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute3                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute4                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute5                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute6                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute7                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute8                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute9                    IN     VARCHAR2 DEFAULT NULL,
                       x_attribute10                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute11                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute12                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute13                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute14                   IN     VARCHAR2 DEFAULT NULL,
                       x_attribute15                   IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute_category    IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute1            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute2            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute3            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute4            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute5            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute6            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute7            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute8            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute9            IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute10           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute11           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute12           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute13           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute14           IN     VARCHAR2 DEFAULT NULL,
                       x_project_attribute15           IN     VARCHAR2 DEFAULT NULL,
                       x_last_update_date              IN     DATE,
                       x_last_updated_by               IN     NUMBER,
                       x_last_update_login             IN     NUMBER,
                       x_recoverable_flag              IN     VARCHAR2,
                       x_area_type_code                IN     VARCHAR2,
                       x_area                          IN     NUMBER,
                       x_grouping_rule_id              IN     NUMBER   DEFAULT NULL,
                       x_term_altered_flag             IN     VARCHAR2 DEFAULT NULL,
                       x_source_code                   IN     VARCHAR2 DEFAULT NULL,
                       x_term_comments                 IN     VARCHAR2 DEFAULT NULL,
                       x_term_template_id              IN     NUMBER   DEFAULT NULL,
                       x_include_in_var_rent           IN     VARCHAR2 DEFAULT NULL,
                       x_recur_bb_calc_date            IN     DATE     DEFAULT NULL,
                       x_opex_agr_id                   IN     NUMBER   DEFAULT NULL,
                       x_opex_recon_id                 IN     NUMBER   DEFAULT NULL,
                       x_opex_type                     IN     VARCHAR2 DEFAULT NULL
                     );

PROCEDURE DELETE_ROW (
                       x_payment_term_id               IN     NUMBER
                     );

PROCEDURE CHECK_PAYMENT_AMOUNTS
                     (
                       x_return_status                 IN OUT NOCOPY VARCHAR2
                      ,x_actual_amount                 IN     NUMBER
                      ,x_estimated_amount              IN     NUMBER
                     );

PROCEDURE UPDATE_VENDOR_AND_CUST
                    (
                       x_payment_term_id               IN     NUMBER
                      ,x_vendor_id                     IN     NUMBER
                      ,x_vendor_site_id                IN     NUMBER
                      ,x_last_update_date              IN     DATE
                      ,x_last_updated_by               IN     NUMBER
                      ,x_last_update_login             IN     NUMBER
                      ,x_customer_id                   IN     NUMBER
                      ,x_customer_site_use_id          IN     NUMBER
                      ,x_cust_ship_site_id             IN     NUMBER
                                         );


PROCEDURE CHECK_APPROVED_SCHEDULE_EXISTS (
                       x_return_status                 IN OUT NOCOPY VARCHAR2
                      ,x_lease_id                      IN     NUMBER
                      ,x_start_date                    IN     DATE
                      ,x_end_date                      IN     DATE
                      ,x_schedule_day                  IN     NUMBER
                     );

PROCEDURE create_hist_corr_upd(p_term_id       IN NUMBER,
                               p_dist_changed  IN NUMBER,
                               p_hist_dist_tab IN dist_type,
                               p_change_mode   IN VARCHAR2,
                               p_eff_str_dt    IN DATE,
                               p_eff_end_dt    IN DATE);

FUNCTION return_agreement_number( p_payment_term_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_source_module_type( p_payment_term_id IN NUMBER ) RETURN VARCHAR2;

PROCEDURE MODIFY_ROW ( x_payment_term_id IN NUMBER
                      ,x_var_rent_inv_id IN NUMBER
                      ,x_changed_flag    IN VARCHAR2 );

END pnt_payment_terms_pkg;

/
