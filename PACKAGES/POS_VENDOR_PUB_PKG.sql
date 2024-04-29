--------------------------------------------------------
--  DDL for Package POS_VENDOR_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_VENDOR_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: POSVNDRS.pls 120.11.12010000.10 2011/10/28 13:23:00 ashgup ship $ */
/*#
 * This package provides APIs to create Supplier,
 * Supplier Site and Supplier Contact records.
 * @rep:scope public
 * @rep:product POS
 * @rep:lifecycle active
 * @rep:displayname Supplier APIs
 * @rep:category BUSINESS_ENTITY AP_SUPPLIER
 */

--
-- Begin Supplier Hub: Data Publication
--
-- Throughout this package spec, standard annotations are added for
-- most public APIs so end users can discover them in Integration
-- Repository.  Mon Aug 31 09:29:44 PDT 2009 bso R12.1.2
--
-- End Supplier Hub: Data Publication
--

/*#
 * This procedure creates a Supplier record in Payables,
 * TCA (Trading Community Architecture), Banking and Tax tables
 * with the input supplier information.
 * If p_vendor_rec.party_id is a valid TCA Party ID then it will be
 * treated as an existing Party to be enabled as a Supplier.
 * Otherwise a new TCA Party record will be created.
 * Upon successful validation this procedure posts the record(s) but
 * does not perform database commit.
 * @param p_vendor_rec Supplier info to be created.  For more information, refer to AP_VENDOR_PUB_PKG.R_VENDOR_REC_TYPE.
 * @param x_return_status Standard API return status
 * @param x_msg_count Standard API message count
 * @param x_msg_data Standard API message data
 * @param x_vendor_id The created Supplier Identifier
 * @param x_party_id The created or existing TCA Party Identifier
 * @rep:displayname Create Supplier
 */
PROCEDURE Create_Vendor
( p_vendor_rec     IN  AP_VENDOR_PUB_PKG.r_vendor_rec_type,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_vendor_id      OUT NOCOPY NUMBER,
  x_party_id       OUT NOCOPY NUMBER
);

-- Notes: This API will not update any TCA tables. It updates vendor info only.
--        This is because the procedure calls the corresponding procedure in
--        AP_VENDOR_PUB_PKG which does not update TCA tables.
/*#
 * This procedure updates a Supplier record in Payables.  Notice
 * the corresponding TCA Party record will not be updated.
 * Upon successful validation this procedure updates the record but
 * does not perform database commit.
 * @param p_vendor_rec Supplier info to be updated.  For more information, refer to AP_VENDOR_PUB_PKG.R_VENDOR_REC_TYPE.
 * @param x_return_status Standard API return status
 * @param x_msg_count Standard API message count
 * @param x_msg_data Standard API message data
 * @rep:displayname Update Supplier
 */
PROCEDURE Update_Vendor
( p_vendor_rec      IN  AP_VENDOR_PUB_PKG.r_vendor_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2
);

-- Notes:
--   p_mode: Indicates whether the calling code is in insert or update mode.
--           (I, U)
--
--   p_party_valid:  Indicates how valid the calling program's party_id was
--                   (V, N, F) Valid, Null or False

/*#
 * This procedure validates a Supplier record in Payables and TCA.
 * If Supplier record is not valid the reason will be returned in the
 * standard API output message.  In addition the party valid output
 * indicates whether the TCA Party record is valid or not.
 * @param p_vendor_rec Supplier info to be validated.  For more information, refer to AP_VENDOR_PUB_PKG.R_VENDOR_REC_TYPE.
 * @param p_mode Indicates the calling mode I = Insert, U = Update
 * @param x_return_status Standard API return status
 * @param x_msg_count Standard API message count
 * @param x_msg_data Standard API message data
 * @param x_party_valid V = valid TCA Party, F = invalid, N = not found
 * @rep:displayname Validate Supplier
 */
PROCEDURE Validate_Vendor
( p_vendor_rec     IN  OUT NOCOPY AP_VENDOR_PUB_PKG.r_vendor_rec_type,
  p_mode           IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_party_valid    OUT NOCOPY VARCHAR2
);


/*#
 * This procedure creates a Supplier Site record in Payables and TCA
 * (Trading Community Architecture) with the input supplier site information.
 * If p_vendor_site_rec.party_site_id and p_vendor_site_rec.location_id are
 * valid Party Site ID and Location ID then they will be
 * treated as an existing Party Site to be enabled as a Supplier Site.
 * Otherwise a new TCA Party Site record will be created.
 * Upon successful validation this procedure posts the record(s) but
 * does not perform database commit.
 * @param p_vendor_site_rec Supplier Site info to be created.  For more information, refer to AP_VENDOR_PUB_PKG.R_VENDOR_SITE_REC_TYPE.
 * @param x_return_status Standard API return status
 * @param x_msg_count Standard API message count
 * @param x_msg_data Standard API message data
 * @param x_vendor_site_id The created Supplier Site Identifier
 * @param x_party_site_id The created or existing TCA Party Site Identifier
 * @param x_location_id The created or existing TCA Location Identifier
 * @rep:displayname Create Supplier Site
 */
PROCEDURE Create_Vendor_Site
( p_vendor_site_rec IN  AP_VENDOR_PUB_PKG.r_vendor_site_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,
  x_vendor_site_id  OUT NOCOPY NUMBER,
  x_party_site_id   OUT NOCOPY NUMBER,
  x_location_id     OUT NOCOPY NUMBER
);

--  Notes: This API will not update any TCA records.
--         It will only update vendor site info.
--         This is because the procedure calls the corresponding procedure in
--         AP_VENDOR_PUB_PKG which does not update TCA tables.
--
/*#
 * This procedure updates a Supplier Site record in Payables.  Notice
 * the corresponding TCA Party Site record will not be updated.
 * Upon successful validation this procedure updates the record but
 * does not perform database commit.
 * @param p_vendor_site_rec Supplier Site info to be updated.  For more information, refer to AP_VENDOR_PUB_PKG.R_VENDOR_SITE_REC_TYPE.
 * @param x_return_status Standard API return status
 * @param x_msg_count Standard API message count
 * @param x_msg_data Standard API message data
 * @rep:displayname Update Supplier Site
 */
PROCEDURE Update_Vendor_Site
( p_vendor_site_rec IN  AP_VENDOR_PUB_PKG.r_vendor_site_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2
  );

-- Notes:
--   p_mode: Indicates whether the calling code is in insert or update mode.
--           (I, U)
--
--   x_party_site_valid: Indicates how valid the calling program's party_site_id was
--                   (V, N, F) Valid, Null or False

/*#
 * This procedure validates a Supplier Site record in Payables and TCA.
 * If Supplier Site record is not valid the reason will be returned in the
 * standard API output message.  In addition the party site valid output
 * indicates whether the TCA Party Site record is valid or not.
 * @param p_vendor_site_rec Supplier Site info to be validated.  For more information, refer to AP_VENDOR_PUB_PKG.R_VENDOR_SITE_REC_TYPE.
 * @param p_mode Indicates the calling mode I = Insert, U = Update
 * @param x_return_status Standard API return status
 * @param x_msg_count Standard API message count
 * @param x_msg_data Standard API message data
 * @param x_party_site_valid V = valid TCA Party Site, F = invalid, N = not found
 * @param x_location_valid V = valid TCA Location, F = invalid, N = not found
 * @rep:displayname Validate Supplier Site
 */
PROCEDURE Validate_Vendor_Site
( p_vendor_site_rec   IN  OUT NOCOPY AP_VENDOR_PUB_PKG.r_vendor_site_rec_type,
  p_mode              IN  VARCHAR2,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,
  x_party_site_valid  OUT NOCOPY VARCHAR2,
  x_location_valid    OUT NOCOPY VARCHAR2
);

/*#
 * This procedure creates a Supplier Site Contact record in Payables and TCA
 * (Trading Community Architecture) with the input supplier site contact information.
 * Upon successful validation this procedure posts the record(s) but
 * does not perform database commit.
 * @param p_vendor_contact_rec Supplier Site Contact info to be created.  For more information, refer to AP_VENDOR_PUB_PKG.R_VENDOR_CONTACT_REC_TYPE.
 * @param x_return_status Standard API return status
 * @param x_msg_count Standard API message count
 * @param x_msg_data Standard API message data
 * @param x_vendor_contact_id The created Supplier Site Contact Identifier
 * @param x_per_party_id The created or existing TCA Person Party Identifier
 * @param x_rel_party_id The created or existing TCA Relationship Party Identifier
 * @param x_rel_id The created or existing TCA Relationship Identifier
 * @param x_org_contact_id The created or existing TCA Organization Contact Identifier
 * @param x_party_site_id The created or existing TCA Party Site Identifier
 * @rep:displayname Create Supplier Site Contact
 */
PROCEDURE Create_Vendor_Contact
( p_vendor_contact_rec  IN  ap_vendor_pub_pkg.r_vendor_contact_rec_type,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_vendor_contact_id   OUT NOCOPY NUMBER,
  x_per_party_id        OUT NOCOPY NUMBER,
  x_rel_party_id        OUT NOCOPY NUMBER,
  x_rel_id              OUT NOCOPY NUMBER,
  x_org_contact_id      OUT NOCOPY NUMBER,
  x_party_site_id       OUT NOCOPY NUMBER
);

PROCEDURE Create_Vendor
(
  p_vendor_id                       IN  NUMBER   DEFAULT NULL,
  p_segment1                        IN  VARCHAR2 DEFAULT NULL,
  p_vendor_name                     IN  VARCHAR2 DEFAULT NULL,
  p_vendor_name_alt                 IN  VARCHAR2 DEFAULT NULL,
  p_summary_flag                    IN  VARCHAR2 DEFAULT NULL,
  p_enabled_flag                    IN  VARCHAR2 DEFAULT NULL,
  p_segment2                        IN  VARCHAR2 DEFAULT NULL,
  p_segment3                        IN  VARCHAR2 DEFAULT NULL,
  p_segment4                        IN  VARCHAR2 DEFAULT NULL,
  p_segment5                        IN  VARCHAR2 DEFAULT NULL,
  p_employee_id                     IN  NUMBER   DEFAULT NULL,
  p_vendor_type_lookup_code         IN  VARCHAR2 DEFAULT NULL,
  p_customer_num                    IN  VARCHAR2 DEFAULT NULL,
  p_one_time_flag                   IN  VARCHAR2 DEFAULT NULL,
  p_parent_vendor_id                IN  NUMBER   DEFAULT NULL,
  p_min_order_amount                IN  NUMBER   DEFAULT NULL,
  p_terms_id                        IN  NUMBER   DEFAULT NULL,
  p_set_of_books_id                 IN  NUMBER   DEFAULT NULL,
  p_always_take_disc_flag           IN  VARCHAR2 DEFAULT NULL,
  p_pay_date_basis_lookup_code      IN  VARCHAR2 DEFAULT NULL,
  p_pay_group_lookup_code           IN  VARCHAR2 DEFAULT NULL,
  p_payment_priority                IN  NUMBER   DEFAULT NULL,
  p_invoice_currency_code           IN  VARCHAR2 DEFAULT NULL,
  p_payment_currency_code           IN  VARCHAR2 DEFAULT NULL,
  p_invoice_amount_limit            IN  NUMBER   DEFAULT NULL,
  p_hold_all_payments_flag          IN  VARCHAR2 DEFAULT NULL,
  p_hold_future_payments_flag       IN  VARCHAR2 DEFAULT NULL,
  p_hold_reason                     IN  VARCHAR2 DEFAULT NULL,
  p_type_1099                       IN  VARCHAR2 DEFAULT NULL,
  p_withhold_status_lookup_code     IN  VARCHAR2 DEFAULT NULL,
  p_withholding_start_date          IN  DATE     DEFAULT NULL,
  p_org_type_lookup_code            IN  VARCHAR2 DEFAULT NULL,
  p_start_date_active               IN  DATE     DEFAULT NULL,
  p_end_date_active                 IN  DATE     DEFAULT NULL,
  p_minority_group_lookup_code      IN  VARCHAR2 DEFAULT NULL,
  p_women_owned_flag                IN  VARCHAR2 DEFAULT NULL,
  p_small_business_flag             IN  VARCHAR2 DEFAULT NULL,
  p_hold_flag                       IN  VARCHAR2 DEFAULT NULL,
  p_purchasing_hold_reason          IN  VARCHAR2 DEFAULT NULL,
  p_hold_by                         IN  NUMBER   DEFAULT NULL,
  p_hold_date                       IN  DATE     DEFAULT NULL,
  p_terms_date_basis                IN  VARCHAR2 DEFAULT NULL,
  p_inspection_required_flag        IN  VARCHAR2 DEFAULT NULL,
  p_receipt_required_flag           IN  VARCHAR2 DEFAULT NULL,
  p_qty_rcv_tolerance               IN  NUMBER   DEFAULT NULL,
  p_qty_rcv_exception_code          IN  VARCHAR2 DEFAULT NULL,
  p_enforce_ship_to_loc_code        IN  VARCHAR2 DEFAULT NULL,
  p_days_early_receipt_allowed      IN  NUMBER   DEFAULT NULL,
  p_days_late_receipt_allowed       IN  NUMBER   DEFAULT NULL,
  p_receipt_days_exception_code     IN  VARCHAR2 DEFAULT NULL,
  p_receiving_routing_id            IN  NUMBER   DEFAULT NULL,
  p_allow_substi_receipts_flag      IN  VARCHAR2 DEFAULT NULL,
  p_allow_unorder_receipts_flag     IN  VARCHAR2 DEFAULT NULL,
  p_hold_unmatched_invoices_flag    IN  VARCHAR2 DEFAULT NULL,
  p_tax_verification_date           IN  DATE     DEFAULT NULL,
  p_name_control                    IN  VARCHAR2 DEFAULT NULL,
  p_state_reportable_flag           IN  VARCHAR2 DEFAULT NULL,
  p_federal_reportable_flag         IN  VARCHAR2 DEFAULT NULL,
  p_attribute_category              IN  VARCHAR2 DEFAULT NULL,
  p_attribute1                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute2                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute3                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute4                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute5                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute6                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute7                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute8                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute9                      IN  VARCHAR2 DEFAULT NULL,
  p_attribute10                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute11                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute12                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute13                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute14                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute15                     IN  VARCHAR2 DEFAULT NULL,
  p_auto_calculate_interest_flag    IN  VARCHAR2 DEFAULT NULL,
  p_validation_number               IN  NUMBER   DEFAULT NULL,
  p_exclude_freight_from_discnt     IN  VARCHAR2 DEFAULT NULL,
  p_tax_reporting_name              IN  VARCHAR2 DEFAULT NULL,
  p_check_digits                    IN  VARCHAR2 DEFAULT NULL,
  p_allow_awt_flag                  IN  VARCHAR2 DEFAULT NULL,
  p_awt_group_id                    IN  NUMBER   DEFAULT NULL,
  p_pay_awt_group_id                    IN  NUMBER   DEFAULT NULL,
  p_awt_group_name                  IN  VARCHAR2 DEFAULT NULL,
  p_pay_awt_group_name                  IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute1               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute2               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute3               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute4               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute5               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute6               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute7               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute8               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute9               IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute10              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute11              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute12              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute13              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute14              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute15              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute16              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute17              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute18              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute19              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute20              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute_category       IN  VARCHAR2 DEFAULT NULL,
  p_bank_charge_bearer              IN  VARCHAR2 DEFAULT NULL,
  p_bank_branch_type                IN  VARCHAR2 DEFAULT NULL,
  p_match_option                    IN  VARCHAR2 DEFAULT NULL,
  p_create_debit_memo_flag          IN  VARCHAR2 DEFAULT NULL,
  p_party_id                        IN  NUMBER   DEFAULT NULL,
  p_parent_party_id                 IN  NUMBER   DEFAULT NULL,
  p_jgzz_fiscal_code                IN  VARCHAR2 DEFAULT NULL,
  p_sic_code                        IN  VARCHAR2 DEFAULT NULL,
  p_tax_reference                   IN  VARCHAR2 DEFAULT NULL,
  p_inventory_organization_id       IN  NUMBER   DEFAULT NULL,
  p_terms_name                      IN  VARCHAR2 DEFAULT NULL,
  p_default_terms_id                IN  NUMBER   DEFAULT NULL,
  p_ni_number                       IN  VARCHAR2 DEFAULT NULL,
  x_return_status  		    OUT NOCOPY VARCHAR2,
  x_error_msg      		    OUT NOCOPY VARCHAR2,
  x_vendor_id     		    OUT NOCOPY NUMBER,
  x_party_id      		    OUT NOCOPY NUMBER
  );

-- Notes: This API will not update any TCA tables. It updates vendor info only.
--        This is because the procedure calls the corresponding procedure in
--        AP_VENDOR_PUB_PKG which does not update TCA tables.
PROCEDURE Update_Vendor
(
  p_vendor_id                       IN  NUMBER   ,
  p_segment1                        IN  VARCHAR2 ,
  p_vendor_name                     IN  VARCHAR2 ,
  p_vendor_name_alt                 IN  VARCHAR2 ,
  p_summary_flag                    IN  VARCHAR2 ,
  p_enabled_flag                    IN  VARCHAR2 ,
  p_segment2                        IN  VARCHAR2 ,
  p_segment3                        IN  VARCHAR2 ,
  p_segment4                        IN  VARCHAR2 ,
  p_segment5                        IN  VARCHAR2 ,
  p_employee_id                     IN  NUMBER   ,
  p_vendor_type_lookup_code         IN  VARCHAR2 ,
  p_customer_num                    IN  VARCHAR2 ,
  p_one_time_flag                   IN  VARCHAR2 ,
  p_parent_vendor_id                IN  NUMBER   ,
  p_min_order_amount                IN  NUMBER   ,
  p_terms_id                        IN  NUMBER   ,
  p_set_of_books_id                 IN  NUMBER   ,
  p_always_take_disc_flag           IN  VARCHAR2 ,
  p_pay_date_basis_lookup_code      IN  VARCHAR2 ,
  p_pay_group_lookup_code           IN  VARCHAR2 ,
  p_payment_priority                IN  NUMBER   ,
  p_invoice_currency_code           IN  VARCHAR2 ,
  p_payment_currency_code           IN  VARCHAR2 ,
  p_invoice_amount_limit            IN  NUMBER   ,
  p_hold_all_payments_flag          IN  VARCHAR2 ,
  p_hold_future_payments_flag       IN  VARCHAR2 ,
  p_hold_reason                     IN  VARCHAR2 ,
  p_type_1099                       IN  VARCHAR2 ,
  p_withhold_status_lookup_code     IN  VARCHAR2 ,
  p_withholding_start_date          IN  DATE     ,
  p_org_type_lookup_code            IN  VARCHAR2 ,
  p_start_date_active               IN  DATE     ,
  p_end_date_active                 IN  DATE     ,
  p_minority_group_lookup_code      IN  VARCHAR2 ,
  p_women_owned_flag                IN  VARCHAR2 ,
  p_small_business_flag             IN  VARCHAR2 ,
  p_hold_flag                       IN  VARCHAR2 ,
  p_purchasing_hold_reason          IN  VARCHAR2 ,
  p_hold_by                         IN  NUMBER   ,
  p_hold_date                       IN  DATE     ,
  p_terms_date_basis                IN  VARCHAR2 ,
  p_inspection_required_flag        IN  VARCHAR2 ,
  p_receipt_required_flag           IN  VARCHAR2 ,
  p_qty_rcv_tolerance               IN  NUMBER   ,
  p_qty_rcv_exception_code          IN  VARCHAR2 ,
  p_enforce_ship_to_loc_code        IN  VARCHAR2 ,
  p_days_early_receipt_allowed      IN  NUMBER   ,
  p_days_late_receipt_allowed       IN  NUMBER   ,
  p_receipt_days_exception_code     IN  VARCHAR2 ,
  p_receiving_routing_id            IN  NUMBER   ,
  p_allow_substi_receipts_flag      IN  VARCHAR2 ,
  p_allow_unorder_receipts_flag     IN  VARCHAR2 ,
  p_hold_unmatched_invoices_flag    IN  VARCHAR2 ,
  p_tax_verification_date           IN  DATE     ,
  p_name_control                    IN  VARCHAR2 ,
  p_state_reportable_flag           IN  VARCHAR2 ,
  p_federal_reportable_flag         IN  VARCHAR2 ,
  p_attribute_category              IN  VARCHAR2 ,
  p_attribute1                      IN  VARCHAR2 ,
  p_attribute2                      IN  VARCHAR2 ,
  p_attribute3                      IN  VARCHAR2 ,
  p_attribute4                      IN  VARCHAR2 ,
  p_attribute5                      IN  VARCHAR2 ,
  p_attribute6                      IN  VARCHAR2 ,
  p_attribute7                      IN  VARCHAR2 ,
  p_attribute8                      IN  VARCHAR2 ,
  p_attribute9                      IN  VARCHAR2 ,
  p_attribute10                     IN  VARCHAR2 ,
  p_attribute11                     IN  VARCHAR2 ,
  p_attribute12                     IN  VARCHAR2 ,
  p_attribute13                     IN  VARCHAR2 ,
  p_attribute14                     IN  VARCHAR2 ,
  p_attribute15                     IN  VARCHAR2 ,
  p_auto_calculate_interest_flag    IN  VARCHAR2 ,
  p_validation_number               IN  NUMBER   ,
  p_exclude_freight_from_discnt     IN  VARCHAR2 ,
  p_tax_reporting_name              IN  VARCHAR2 ,
  p_check_digits                    IN  VARCHAR2 ,
  p_allow_awt_flag                  IN  VARCHAR2 ,
  p_awt_group_id                    IN  NUMBER   ,
  p_pay_awt_group_id                    IN  NUMBER   ,
  p_awt_group_name                  IN  VARCHAR2 ,
  p_pay_awt_group_name                  IN  VARCHAR2 ,
  p_global_attribute1               IN  VARCHAR2 ,
  p_global_attribute2               IN  VARCHAR2 ,
  p_global_attribute3               IN  VARCHAR2 ,
  p_global_attribute4               IN  VARCHAR2 ,
  p_global_attribute5               IN  VARCHAR2 ,
  p_global_attribute6               IN  VARCHAR2 ,
  p_global_attribute7               IN  VARCHAR2 ,
  p_global_attribute8               IN  VARCHAR2 ,
  p_global_attribute9               IN  VARCHAR2 ,
  p_global_attribute10              IN  VARCHAR2 ,
  p_global_attribute11              IN  VARCHAR2 ,
  p_global_attribute12              IN  VARCHAR2 ,
  p_global_attribute13              IN  VARCHAR2 ,
  p_global_attribute14              IN  VARCHAR2 ,
  p_global_attribute15              IN  VARCHAR2 ,
  p_global_attribute16              IN  VARCHAR2 ,
  p_global_attribute17              IN  VARCHAR2 ,
  p_global_attribute18              IN  VARCHAR2 ,
  p_global_attribute19              IN  VARCHAR2 ,
  p_global_attribute20              IN  VARCHAR2 ,
  p_global_attribute_category       IN  VARCHAR2 ,
  p_bank_charge_bearer              IN  VARCHAR2 ,
  p_bank_branch_type                IN  VARCHAR2 ,
  p_match_option                    IN  VARCHAR2 ,
  p_create_debit_memo_flag          IN  VARCHAR2 ,
  p_party_id                        IN  NUMBER   ,
  p_parent_party_id                 IN  NUMBER   ,
  p_jgzz_fiscal_code                IN  VARCHAR2 ,
  p_sic_code                        IN  VARCHAR2 ,
  p_tax_reference                   IN  VARCHAR2 ,
  p_inventory_organization_id       IN  NUMBER   ,
  p_terms_name                      IN  VARCHAR2 ,
  p_default_terms_id                IN  NUMBER   ,
  p_ni_number                       IN  VARCHAR2 ,
  p_last_update_date                IN  DATE DEFAULT NULL,
  x_return_status   		    OUT NOCOPY VARCHAR2,
  x_error_msg       		    OUT NOCOPY VARCHAR2
);

-- Notes:
--   p_mode: Indicates whether the calling code is in insert or update mode.
--           (I, U)
--
--   p_party_valid:  Indicates how valid the calling program's party_id was
--                   (V, N, F) Valid, Null or False

PROCEDURE Validate_Vendor
(
  p_vendor_id                       IN  NUMBER   ,
  p_segment1                        IN  VARCHAR2 ,
  p_vendor_name                     IN  VARCHAR2 ,
  p_vendor_name_alt                 IN  VARCHAR2 ,
  p_summary_flag                    IN  VARCHAR2 ,
  p_enabled_flag                    IN  VARCHAR2 ,
  p_segment2                        IN  VARCHAR2 ,
  p_segment3                        IN  VARCHAR2 ,
  p_segment4                        IN  VARCHAR2 ,
  p_segment5                        IN  VARCHAR2 ,
  p_employee_id                     IN  NUMBER   ,
  p_vendor_type_lookup_code         IN  VARCHAR2 ,
  p_customer_num                    IN  VARCHAR2 ,
  p_one_time_flag                   IN  VARCHAR2 ,
  p_parent_vendor_id                IN  NUMBER   ,
  p_min_order_amount                IN  NUMBER   ,
  p_terms_id                        IN  NUMBER   ,
  p_set_of_books_id                 IN  NUMBER   ,
  p_always_take_disc_flag           IN  VARCHAR2 ,
  p_pay_date_basis_lookup_code      IN  VARCHAR2 ,
  p_pay_group_lookup_code           IN  VARCHAR2 ,
  p_payment_priority                IN  NUMBER   ,
  p_invoice_currency_code           IN  VARCHAR2 ,
  p_payment_currency_code           IN  VARCHAR2 ,
  p_invoice_amount_limit            IN  NUMBER   ,
  p_hold_all_payments_flag          IN  VARCHAR2 ,
  p_hold_future_payments_flag       IN  VARCHAR2 ,
  p_hold_reason                     IN  VARCHAR2 ,
  p_type_1099                       IN  VARCHAR2 ,
  p_withhold_status_lookup_code     IN  VARCHAR2 ,
  p_withholding_start_date          IN  DATE     ,
  p_org_type_lookup_code            IN  VARCHAR2 ,
  p_start_date_active               IN  DATE     ,
  p_end_date_active                 IN  DATE     ,
  p_minority_group_lookup_code      IN  VARCHAR2 ,
  p_women_owned_flag                IN  VARCHAR2 ,
  p_small_business_flag             IN  VARCHAR2 ,
  p_hold_flag                       IN  VARCHAR2 ,
  p_purchasing_hold_reason          IN  VARCHAR2 ,
  p_hold_by                         IN  NUMBER   ,
  p_hold_date                       IN  DATE     ,
  p_terms_date_basis                IN  VARCHAR2 ,
  p_inspection_required_flag        IN  VARCHAR2 ,
  p_receipt_required_flag           IN  VARCHAR2 ,
  p_qty_rcv_tolerance               IN  NUMBER   ,
  p_qty_rcv_exception_code          IN  VARCHAR2 ,
  p_enforce_ship_to_loc_code        IN  VARCHAR2 ,
  p_days_early_receipt_allowed      IN  NUMBER   ,
  p_days_late_receipt_allowed       IN  NUMBER   ,
  p_receipt_days_exception_code     IN  VARCHAR2 ,
  p_receiving_routing_id            IN  NUMBER   ,
  p_allow_substi_receipts_flag      IN  VARCHAR2 ,
  p_allow_unorder_receipts_flag     IN  VARCHAR2 ,
  p_hold_unmatched_invoices_flag    IN  VARCHAR2 ,
  p_tax_verification_date           IN  DATE     ,
  p_name_control                    IN  VARCHAR2 ,
  p_state_reportable_flag           IN  VARCHAR2 ,
  p_federal_reportable_flag         IN  VARCHAR2 ,
  p_attribute_category              IN  VARCHAR2 ,
  p_attribute1                      IN  VARCHAR2 ,
  p_attribute2                      IN  VARCHAR2 ,
  p_attribute3                      IN  VARCHAR2 ,
  p_attribute4                      IN  VARCHAR2 ,
  p_attribute5                      IN  VARCHAR2 ,
  p_attribute6                      IN  VARCHAR2 ,
  p_attribute7                      IN  VARCHAR2 ,
  p_attribute8                      IN  VARCHAR2 ,
  p_attribute9                      IN  VARCHAR2 ,
  p_attribute10                     IN  VARCHAR2 ,
  p_attribute11                     IN  VARCHAR2 ,
  p_attribute12                     IN  VARCHAR2 ,
  p_attribute13                     IN  VARCHAR2 ,
  p_attribute14                     IN  VARCHAR2 ,
  p_attribute15                     IN  VARCHAR2 ,
  p_auto_calculate_interest_flag    IN  VARCHAR2 ,
  p_validation_number               IN  NUMBER   ,
  p_exclude_freight_from_discnt     IN  VARCHAR2 ,
  p_tax_reporting_name              IN  VARCHAR2 ,
  p_check_digits                    IN  VARCHAR2 ,
  p_allow_awt_flag                  IN  VARCHAR2 ,
  p_awt_group_id                    IN  NUMBER   ,
  p_pay_awt_group_id                    IN  NUMBER   ,
  p_awt_group_name                  IN  VARCHAR2 ,
  p_pay_awt_group_name                  IN  VARCHAR2 ,
  p_global_attribute1               IN  VARCHAR2 ,
  p_global_attribute2               IN  VARCHAR2 ,
  p_global_attribute3               IN  VARCHAR2 ,
  p_global_attribute4               IN  VARCHAR2 ,
  p_global_attribute5               IN  VARCHAR2 ,
  p_global_attribute6               IN  VARCHAR2 ,
  p_global_attribute7               IN  VARCHAR2 ,
  p_global_attribute8               IN  VARCHAR2 ,
  p_global_attribute9               IN  VARCHAR2 ,
  p_global_attribute10              IN  VARCHAR2 ,
  p_global_attribute11              IN  VARCHAR2 ,
  p_global_attribute12              IN  VARCHAR2 ,
  p_global_attribute13              IN  VARCHAR2 ,
  p_global_attribute14              IN  VARCHAR2 ,
  p_global_attribute15              IN  VARCHAR2 ,
  p_global_attribute16              IN  VARCHAR2 ,
  p_global_attribute17              IN  VARCHAR2 ,
  p_global_attribute18              IN  VARCHAR2 ,
  p_global_attribute19              IN  VARCHAR2 ,
  p_global_attribute20              IN  VARCHAR2 ,
  p_global_attribute_category       IN  VARCHAR2 ,
  p_bank_charge_bearer              IN  VARCHAR2 ,
  p_bank_branch_type                IN  VARCHAR2 ,
  p_match_option                    IN  VARCHAR2 ,
  p_create_debit_memo_flag          IN  VARCHAR2 ,
  p_party_id                        IN  NUMBER   ,
  p_parent_party_id                 IN  NUMBER   ,
  p_jgzz_fiscal_code                IN  VARCHAR2 ,
  p_sic_code                        IN  VARCHAR2 ,
  p_tax_reference                   IN  VARCHAR2 ,
  p_inventory_organization_id       IN  NUMBER   ,
  p_terms_name                      IN  VARCHAR2 ,
  p_default_terms_id                IN  NUMBER   ,
  p_ni_number                       IN  VARCHAR2 ,
  p_mode           		    IN  VARCHAR2,
  x_return_status  		    OUT NOCOPY VARCHAR2,
  x_error_msg      		    OUT NOCOPY VARCHAR2,
  x_party_valid    		    OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Vendor_Site
(
  p_area_code                      IN  VARCHAR2 DEFAULT NULL,
  p_phone                          IN  VARCHAR2 DEFAULT NULL,
  p_customer_num                   IN  VARCHAR2 DEFAULT NULL,
  p_ship_to_location_id            IN  NUMBER   DEFAULT NULL,
  p_bill_to_location_id            IN  NUMBER   DEFAULT NULL,
  p_ship_via_lookup_code           IN  VARCHAR2 DEFAULT NULL,
  p_freight_terms_lookup_code      IN  VARCHAR2 DEFAULT NULL,
  p_fob_lookup_code                IN  VARCHAR2 DEFAULT NULL,
  p_inactive_date                  IN  DATE     DEFAULT NULL,
  p_fax                            IN  VARCHAR2 DEFAULT NULL,
  p_fax_area_code                  IN  VARCHAR2 DEFAULT NULL,
  p_telex                          IN  VARCHAR2 DEFAULT NULL,
  p_terms_date_basis               IN  VARCHAR2 DEFAULT NULL,
  p_distribution_set_id            IN  NUMBER   DEFAULT NULL,
  p_accts_pay_code_combo_id        IN  NUMBER   DEFAULT NULL,
  p_prepay_code_combination_id     IN  NUMBER   DEFAULT NULL,
  p_pay_group_lookup_code          IN  VARCHAR2 DEFAULT NULL,
  p_payment_method_lookup_code     IN  VARCHAR2 DEFAULT NULL,
  p_payment_priority               IN  NUMBER   DEFAULT NULL,
  p_terms_id                       IN  NUMBER   DEFAULT NULL,
  p_invoice_amount_limit           IN  NUMBER   DEFAULT NULL,
  p_pay_date_basis_lookup_code     IN  VARCHAR2 DEFAULT NULL,
  p_always_take_disc_flag          IN  VARCHAR2 DEFAULT NULL,
  p_invoice_currency_code          IN  VARCHAR2 DEFAULT NULL,
  p_payment_currency_code          IN  VARCHAR2 DEFAULT NULL,
  p_vendor_site_id                 IN  NUMBER   DEFAULT NULL,
  p_last_update_date               IN  DATE     DEFAULT NULL,
  p_last_updated_by                IN  NUMBER   DEFAULT NULL,
  p_vendor_id                      IN  NUMBER   DEFAULT NULL,
  p_vendor_site_code               IN  VARCHAR2 DEFAULT NULL,
  p_vendor_site_code_alt           IN  VARCHAR2 DEFAULT NULL,
  p_purchasing_site_flag           IN  VARCHAR2 DEFAULT NULL,
  p_rfq_only_site_flag             IN  VARCHAR2 DEFAULT NULL,
  p_pay_site_flag                  IN  VARCHAR2 DEFAULT NULL,
  p_attention_ar_flag              IN  VARCHAR2 DEFAULT NULL,
  p_hold_all_payments_flag         IN  VARCHAR2 DEFAULT NULL,
  p_hold_future_payments_flag      IN  VARCHAR2 DEFAULT NULL,
  p_hold_reason                    IN  VARCHAR2 DEFAULT NULL,
  p_hold_unmatched_invoices_flag   IN  VARCHAR2 DEFAULT NULL,
  p_tax_reporting_site_flag        IN  VARCHAR2 DEFAULT NULL,
  p_attribute_category             IN  VARCHAR2 DEFAULT NULL,
  p_attribute1                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute2                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute3                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute4                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute5                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute6                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute7                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute8                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute9                     IN  VARCHAR2 DEFAULT NULL,
  p_attribute10                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute11                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute12                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute13                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute14                    IN  VARCHAR2 DEFAULT NULL,
  p_attribute15                    IN  VARCHAR2 DEFAULT NULL,
  p_validation_number              IN  NUMBER   DEFAULT NULL,
  p_exclude_freight_from_discnt    IN  VARCHAR2 DEFAULT NULL,
  p_bank_charge_bearer             IN  VARCHAR2 DEFAULT NULL,
  p_org_id                         IN  NUMBER   DEFAULT NULL,
  p_check_digits                   IN  VARCHAR2 DEFAULT NULL,
  p_allow_awt_flag                 IN  VARCHAR2 DEFAULT NULL,
  p_awt_group_id                   IN  NUMBER   DEFAULT NULL,
  p_pay_awt_group_id                   IN  NUMBER   DEFAULT NULL,
  p_default_pay_site_id            IN  NUMBER   DEFAULT NULL,
  p_pay_on_code                    IN  VARCHAR2 DEFAULT NULL,
  p_pay_on_receipt_summary_code    IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute_category      IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute1              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute2              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute3              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute4              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute5              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute6              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute7              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute8              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute9              IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute10             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute11             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute12             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute13             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute14             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute15             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute16             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute17             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute18             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute19             IN  VARCHAR2 DEFAULT NULL,
  p_global_attribute20             IN  VARCHAR2 DEFAULT NULL,
  p_tp_header_id                   IN  NUMBER   DEFAULT NULL,
  p_edi_id_number                  IN  VARCHAR2 DEFAULT NULL,
  p_ece_tp_location_code           IN  VARCHAR2 DEFAULT NULL,
  p_pcard_site_flag                IN  VARCHAR2 DEFAULT NULL,
  p_match_option                   IN  VARCHAR2 DEFAULT NULL,
  p_country_of_origin_code         IN  VARCHAR2 DEFAULT NULL,
  p_future_dated_payment_ccid      IN  NUMBER   DEFAULT NULL,
  p_create_debit_memo_flag         IN  VARCHAR2 DEFAULT NULL,
  p_supplier_notif_method          IN  VARCHAR2 DEFAULT NULL,
  p_email_address                  IN  VARCHAR2 DEFAULT NULL,
  p_primary_pay_site_flag          IN  VARCHAR2 DEFAULT NULL,
  p_shipping_control               IN  VARCHAR2 DEFAULT NULL,
  p_selling_company_identifier     IN  VARCHAR2 DEFAULT NULL,
  p_gapless_inv_num_flag           IN  VARCHAR2 DEFAULT NULL,
  p_location_id                    IN  NUMBER   DEFAULT NULL,
  p_party_site_id                  IN  NUMBER   DEFAULT NULL,
  p_org_name                       IN  VARCHAR2 DEFAULT NULL,
  p_duns_number                    IN  VARCHAR2 DEFAULT NULL,
  p_address_style                  IN  VARCHAR2 DEFAULT NULL,
  p_language                       IN  VARCHAR2 DEFAULT NULL,
  p_province                       IN  VARCHAR2 DEFAULT NULL,
  p_country                        IN  VARCHAR2 DEFAULT NULL,
  p_address_line1                  IN  VARCHAR2             ,
  p_address_line2                  IN  VARCHAR2 DEFAULT NULL,
  p_address_line3                  IN  VARCHAR2 DEFAULT NULL,
  p_address_line4                  IN  VARCHAR2 DEFAULT NULL,
  p_address_lines_alt              IN  VARCHAR2 DEFAULT NULL,
  p_county                         IN  VARCHAR2 DEFAULT NULL,
  p_city                           IN  VARCHAR2 DEFAULT NULL,
  p_state                          IN  VARCHAR2 DEFAULT NULL,
  p_zip                            IN  VARCHAR2 DEFAULT NULL,
  p_terms_name                     IN  VARCHAR2 DEFAULT NULL,
  p_default_terms_id               IN  NUMBER   DEFAULT NULL,
  p_awt_group_name                 IN  VARCHAR2 DEFAULT NULL,
  p_pay_awt_group_name                 IN  VARCHAR2 DEFAULT NULL,
  p_distribution_set_name          IN  VARCHAR2 DEFAULT NULL,
  p_ship_to_location_code          IN  VARCHAR2 DEFAULT NULL,
  p_bill_to_location_code          IN  VARCHAR2 DEFAULT NULL,
  p_default_dist_set_id            IN  NUMBER   DEFAULT NULL,
  p_default_ship_to_loc_id         IN  NUMBER   DEFAULT NULL,
  p_default_bill_to_loc_id         IN  NUMBER   DEFAULT NULL,
  p_tolerance_id                   IN  NUMBER   DEFAULT NULL,
  p_tolerance_name                 IN  VARCHAR2 DEFAULT NULL,
  p_retainage_rate                 IN  NUMBER   DEFAULT NULL,
  p_service_tolerance_id           IN  NUMBER   DEFAULT NULL,
  x_return_status   		   OUT NOCOPY VARCHAR2,
  x_error_msg       		   OUT NOCOPY VARCHAR2,
  x_vendor_site_id  		   OUT NOCOPY NUMBER,
  x_party_site_id   		   OUT NOCOPY NUMBER,
  x_location_id     		   OUT NOCOPY NUMBER
);

--  Notes: This API will not update any TCA records.
--         It will only update vendor site info.
--         This is because the procedure calls the corresponding procedure in
--         AP_VENDOR_PUB_PKG which does not update TCA tables.
--
PROCEDURE Update_Vendor_Site
(
  p_area_code                      IN  VARCHAR2 ,
  p_phone                          IN  VARCHAR2 ,
  p_customer_num                   IN  VARCHAR2 ,
  p_ship_to_location_id            IN  NUMBER   ,
  p_bill_to_location_id            IN  NUMBER   ,
  p_ship_via_lookup_code           IN  VARCHAR2 ,
  p_freight_terms_lookup_code      IN  VARCHAR2 ,
  p_fob_lookup_code                IN  VARCHAR2 ,
  p_inactive_date                  IN  DATE     ,
  p_fax                            IN  VARCHAR2 ,
  p_fax_area_code                  IN  VARCHAR2 ,
  p_telex                          IN  VARCHAR2 ,
  p_terms_date_basis               IN  VARCHAR2 ,
  p_distribution_set_id            IN  NUMBER   ,
  p_accts_pay_code_combo_id        IN  NUMBER   ,
  p_prepay_code_combination_id     IN  NUMBER   ,
  p_pay_group_lookup_code          IN  VARCHAR2 ,
  p_payment_priority               IN  NUMBER   ,
  p_terms_id                       IN  NUMBER   ,
  p_invoice_amount_limit           IN  NUMBER   ,
  p_pay_date_basis_lookup_code     IN  VARCHAR2 ,
  p_always_take_disc_flag          IN  VARCHAR2 ,
  p_invoice_currency_code          IN  VARCHAR2 ,
  p_payment_currency_code          IN  VARCHAR2 ,
  p_vendor_site_id                 IN  NUMBER   ,
  p_last_update_date               IN  DATE     ,
  p_last_updated_by                IN  NUMBER   ,
  p_vendor_id                      IN  NUMBER   ,
  p_vendor_site_code               IN  VARCHAR2 ,
  p_vendor_site_code_alt           IN  VARCHAR2 ,
  p_purchasing_site_flag           IN  VARCHAR2 ,
  p_rfq_only_site_flag             IN  VARCHAR2 ,
  p_pay_site_flag                  IN  VARCHAR2 ,
  p_attention_ar_flag              IN  VARCHAR2 ,
  p_hold_all_payments_flag         IN  VARCHAR2 ,
  p_hold_future_payments_flag      IN  VARCHAR2 ,
  p_hold_reason                    IN  VARCHAR2 ,
  p_hold_unmatched_invoices_flag   IN  VARCHAR2 ,
  p_tax_reporting_site_flag        IN  VARCHAR2 ,
  p_attribute_category             IN  VARCHAR2 ,
  p_attribute1                     IN  VARCHAR2 ,
  p_attribute2                     IN  VARCHAR2 ,
  p_attribute3                     IN  VARCHAR2 ,
  p_attribute4                     IN  VARCHAR2 ,
  p_attribute5                     IN  VARCHAR2 ,
  p_attribute6                     IN  VARCHAR2 ,
  p_attribute7                     IN  VARCHAR2 ,
  p_attribute8                     IN  VARCHAR2 ,
  p_attribute9                     IN  VARCHAR2 ,
  p_attribute10                    IN  VARCHAR2 ,
  p_attribute11                    IN  VARCHAR2 ,
  p_attribute12                    IN  VARCHAR2 ,
  p_attribute13                    IN  VARCHAR2 ,
  p_attribute14                    IN  VARCHAR2 ,
  p_attribute15                    IN  VARCHAR2 ,
  p_validation_number              IN  NUMBER   ,
  p_exclude_freight_from_discnt    IN  VARCHAR2 ,
  p_bank_charge_bearer             IN  VARCHAR2 ,
  p_org_id                         IN  NUMBER   ,
  p_check_digits                   IN  VARCHAR2 ,
  p_allow_awt_flag                 IN  VARCHAR2 ,
  p_awt_group_id                   IN  NUMBER   ,
  p_pay_awt_group_id                   IN  NUMBER   ,
  p_default_pay_site_id            IN  NUMBER   ,
  p_pay_on_code                    IN  VARCHAR2 ,
  p_pay_on_receipt_summary_code    IN  VARCHAR2 ,
  p_global_attribute_category      IN  VARCHAR2 ,
  p_global_attribute1              IN  VARCHAR2 ,
  p_global_attribute2              IN  VARCHAR2 ,
  p_global_attribute3              IN  VARCHAR2 ,
  p_global_attribute4              IN  VARCHAR2 ,
  p_global_attribute5              IN  VARCHAR2 ,
  p_global_attribute6              IN  VARCHAR2 ,
  p_global_attribute7              IN  VARCHAR2 ,
  p_global_attribute8              IN  VARCHAR2 ,
  p_global_attribute9              IN  VARCHAR2 ,
  p_global_attribute10             IN  VARCHAR2 ,
  p_global_attribute11             IN  VARCHAR2 ,
  p_global_attribute12             IN  VARCHAR2 ,
  p_global_attribute13             IN  VARCHAR2 ,
  p_global_attribute14             IN  VARCHAR2 ,
  p_global_attribute15             IN  VARCHAR2 ,
  p_global_attribute16             IN  VARCHAR2 ,
  p_global_attribute17             IN  VARCHAR2 ,
  p_global_attribute18             IN  VARCHAR2 ,
  p_global_attribute19             IN  VARCHAR2 ,
  p_global_attribute20             IN  VARCHAR2 ,
  p_tp_header_id                   IN  NUMBER   ,
  p_edi_id_number                  IN  VARCHAR2 ,
  p_ece_tp_location_code           IN  VARCHAR2 ,
  p_pcard_site_flag                IN  VARCHAR2 ,
  p_match_option                   IN  VARCHAR2 ,
  p_country_of_origin_code         IN  VARCHAR2 ,
  p_future_dated_payment_ccid      IN  NUMBER   ,
  p_create_debit_memo_flag         IN  VARCHAR2 ,
  p_supplier_notif_method          IN  VARCHAR2 ,
  p_email_address                  IN  VARCHAR2 ,
  p_primary_pay_site_flag          IN  VARCHAR2 ,
  p_shipping_control               IN  VARCHAR2 ,
  p_selling_company_identifier     IN  VARCHAR2 ,
  p_gapless_inv_num_flag           IN  VARCHAR2 ,
  p_location_id                    IN  NUMBER   ,
  p_party_site_id                  IN  NUMBER   ,
  p_org_name                       IN  VARCHAR2 ,
  p_duns_number                    IN  VARCHAR2 ,
  p_address_style                  IN  VARCHAR2 ,
  p_language                       IN  VARCHAR2 ,
  p_province                       IN  VARCHAR2 ,
  p_country                        IN  VARCHAR2 ,
  p_address_line1                  IN  VARCHAR2 ,
  p_address_line2                  IN  VARCHAR2 ,
  p_address_line3                  IN  VARCHAR2 ,
  p_address_line4                  IN  VARCHAR2 ,
  p_address_lines_alt              IN  VARCHAR2 ,
  p_county                         IN  VARCHAR2 ,
  p_city                           IN  VARCHAR2 ,
  p_state                          IN  VARCHAR2 ,
  p_zip                            IN  VARCHAR2 ,
  p_terms_name                     IN  VARCHAR2 ,
  p_default_terms_id               IN  NUMBER   ,
  p_awt_group_name                 IN  VARCHAR2 ,
  p_pay_awt_group_name                 IN  VARCHAR2 ,
  p_distribution_set_name          IN  VARCHAR2 ,
  p_ship_to_location_code          IN  VARCHAR2 ,
  p_bill_to_location_code          IN  VARCHAR2 ,
  p_default_dist_set_id            IN  NUMBER   ,
  p_default_ship_to_loc_id         IN  NUMBER   ,
  p_default_bill_to_loc_id         IN  NUMBER   ,
  p_tolerance_id                   IN  NUMBER   ,
  p_tolerance_name                 IN  VARCHAR2 ,
  p_retainage_rate                 IN  NUMBER   ,
  p_service_tolerance_id           IN  NUMBER   ,
  p_ship_network_loc_id        IN  NUMBER   ,
  x_return_status                  OUT NOCOPY VARCHAR2,
  x_error_msg                      OUT NOCOPY VARCHAR2
  );

-- Notes:
--   p_mode: Indicates whether the calling code is in insert or update mode.
--           (I, U)
--
--   x_party_site_valid: Indicates how valid the calling program's party_site_id was
--                   (V, N, F) Valid, Null or False

PROCEDURE Validate_Vendor_Site
(
  p_area_code                      IN  VARCHAR2 ,
  p_phone                          IN  VARCHAR2 ,
  p_customer_num                   IN  VARCHAR2 ,
  p_ship_to_location_id            IN  NUMBER   ,
  p_bill_to_location_id            IN  NUMBER   ,
  p_ship_via_lookup_code           IN  VARCHAR2 ,
  p_freight_terms_lookup_code      IN  VARCHAR2 ,
  p_fob_lookup_code                IN  VARCHAR2 ,
  p_inactive_date                  IN  DATE     ,
  p_fax                            IN  VARCHAR2 ,
  p_fax_area_code                  IN  VARCHAR2 ,
  p_telex                          IN  VARCHAR2 ,
  p_terms_date_basis               IN  VARCHAR2 ,
  p_distribution_set_id            IN  NUMBER   ,
  p_accts_pay_code_combo_id        IN  NUMBER   ,
  p_prepay_code_combination_id     IN  NUMBER   ,
  p_pay_group_lookup_code          IN  VARCHAR2 ,
  p_payment_priority               IN  NUMBER   ,
  p_terms_id                       IN  NUMBER   ,
  p_invoice_amount_limit           IN  NUMBER   ,
  p_pay_date_basis_lookup_code     IN  VARCHAR2 ,
  p_always_take_disc_flag          IN  VARCHAR2 ,
  p_invoice_currency_code          IN  VARCHAR2 ,
  p_payment_currency_code          IN  VARCHAR2 ,
  p_vendor_site_id                 IN  NUMBER   ,
  p_last_update_date               IN  DATE     ,
  p_last_updated_by                IN  NUMBER   ,
  p_vendor_id                      IN  NUMBER   ,
  p_vendor_site_code               IN  VARCHAR2 ,
  p_vendor_site_code_alt           IN  VARCHAR2 ,
  p_purchasing_site_flag           IN  VARCHAR2 ,
  p_rfq_only_site_flag             IN  VARCHAR2 ,
  p_pay_site_flag                  IN  VARCHAR2 ,
  p_attention_ar_flag              IN  VARCHAR2 ,
  p_hold_all_payments_flag         IN  VARCHAR2 ,
  p_hold_future_payments_flag      IN  VARCHAR2 ,
  p_hold_reason                    IN  VARCHAR2 ,
  p_hold_unmatched_invoices_flag   IN  VARCHAR2 ,
  p_tax_reporting_site_flag        IN  VARCHAR2 ,
  p_attribute_category             IN  VARCHAR2 ,
  p_attribute1                     IN  VARCHAR2 ,
  p_attribute2                     IN  VARCHAR2 ,
  p_attribute3                     IN  VARCHAR2 ,
  p_attribute4                     IN  VARCHAR2 ,
  p_attribute5                     IN  VARCHAR2 ,
  p_attribute6                     IN  VARCHAR2 ,
  p_attribute7                     IN  VARCHAR2 ,
  p_attribute8                     IN  VARCHAR2 ,
  p_attribute9                     IN  VARCHAR2 ,
  p_attribute10                    IN  VARCHAR2 ,
  p_attribute11                    IN  VARCHAR2 ,
  p_attribute12                    IN  VARCHAR2 ,
  p_attribute13                    IN  VARCHAR2 ,
  p_attribute14                    IN  VARCHAR2 ,
  p_attribute15                    IN  VARCHAR2 ,
  p_validation_number              IN  NUMBER   ,
  p_exclude_freight_from_discnt    IN  VARCHAR2 ,
  p_bank_charge_bearer             IN  VARCHAR2 ,
  p_org_id                         IN  NUMBER   ,
  p_check_digits                   IN  VARCHAR2 ,
  p_allow_awt_flag                 IN  VARCHAR2 ,
  p_awt_group_id                   IN  NUMBER   ,
  p_pay_awt_group_id                   IN  NUMBER   ,
  p_default_pay_site_id            IN  NUMBER   ,
  p_pay_on_code                    IN  VARCHAR2 ,
  p_pay_on_receipt_summary_code    IN  VARCHAR2 ,
  p_global_attribute_category      IN  VARCHAR2 ,
  p_global_attribute1              IN  VARCHAR2 ,
  p_global_attribute2              IN  VARCHAR2 ,
  p_global_attribute3              IN  VARCHAR2 ,
  p_global_attribute4              IN  VARCHAR2 ,
  p_global_attribute5              IN  VARCHAR2 ,
  p_global_attribute6              IN  VARCHAR2 ,
  p_global_attribute7              IN  VARCHAR2 ,
  p_global_attribute8              IN  VARCHAR2 ,
  p_global_attribute9              IN  VARCHAR2 ,
  p_global_attribute10             IN  VARCHAR2 ,
  p_global_attribute11             IN  VARCHAR2 ,
  p_global_attribute12             IN  VARCHAR2 ,
  p_global_attribute13             IN  VARCHAR2 ,
  p_global_attribute14             IN  VARCHAR2 ,
  p_global_attribute15             IN  VARCHAR2 ,
  p_global_attribute16             IN  VARCHAR2 ,
  p_global_attribute17             IN  VARCHAR2 ,
  p_global_attribute18             IN  VARCHAR2 ,
  p_global_attribute19             IN  VARCHAR2 ,
  p_global_attribute20             IN  VARCHAR2 ,
  p_tp_header_id                   IN  NUMBER   ,
  p_edi_id_number                  IN  VARCHAR2 ,
  p_ece_tp_location_code           IN  VARCHAR2 ,
  p_pcard_site_flag                IN  VARCHAR2 ,
  p_match_option                   IN  VARCHAR2 ,
  p_country_of_origin_code         IN  VARCHAR2 ,
  p_future_dated_payment_ccid      IN  NUMBER   ,
  p_create_debit_memo_flag         IN  VARCHAR2 ,
  p_supplier_notif_method          IN  VARCHAR2 ,
  p_email_address                  IN  VARCHAR2 ,
  p_primary_pay_site_flag          IN  VARCHAR2 ,
  p_shipping_control               IN  VARCHAR2 ,
  p_selling_company_identifier     IN  VARCHAR2 ,
  p_gapless_inv_num_flag           IN  VARCHAR2 ,
  p_location_id                    IN  NUMBER   ,
  p_party_site_id                  IN  NUMBER   ,
  p_org_name                       IN  VARCHAR2 ,
  p_duns_number                    IN  VARCHAR2 ,
  p_address_style                  IN  VARCHAR2 ,
  p_language                       IN  VARCHAR2 ,
  p_province                       IN  VARCHAR2 ,
  p_country                        IN  VARCHAR2 ,
  p_address_line1                  IN  VARCHAR2 ,
  p_address_line2                  IN  VARCHAR2 ,
  p_address_line3                  IN  VARCHAR2 ,
  p_address_line4                  IN  VARCHAR2 ,
  p_address_lines_alt              IN  VARCHAR2 ,
  p_county                         IN  VARCHAR2 ,
  p_city                           IN  VARCHAR2 ,
  p_state                          IN  VARCHAR2 ,
  p_zip                            IN  VARCHAR2 ,
  p_terms_name                     IN  VARCHAR2 ,
  p_default_terms_id               IN  NUMBER   ,
  p_awt_group_name                 IN  VARCHAR2 ,
  p_pay_awt_group_name                 IN  VARCHAR2 ,
  p_distribution_set_name          IN  VARCHAR2 ,
  p_ship_to_location_code          IN  VARCHAR2 ,
  p_bill_to_location_code          IN  VARCHAR2 ,
  p_default_dist_set_id            IN  NUMBER   ,
  p_default_ship_to_loc_id         IN  NUMBER   ,
  p_default_bill_to_loc_id         IN  NUMBER   ,
  p_tolerance_id                   IN  NUMBER   ,
  p_tolerance_name                 IN  VARCHAR2 ,
  p_retainage_rate                 IN  NUMBER   ,
  p_mode              		   IN  VARCHAR2,
  x_return_status     		   OUT NOCOPY VARCHAR2,
  x_error_msg         		   OUT NOCOPY VARCHAR2,
  x_party_site_valid  		   OUT NOCOPY VARCHAR2,
  x_location_valid    		   OUT NOCOPY VARCHAR2
);



--
-- Begin Supplier Hub: Data Publication
--
-- This version of EGO's UDA Process User Attributes Data API is
-- almost identical to the original version in ego_user_attrs_data_pub
-- with the exception of hardcoding the object name HZ_PARTIES which
-- is the only object name expected when accessing UDA for Supplier
-- related entities.
--
-- Another minor difference is the following optional parameters.  In the
-- original EGO API they are defined as having DEFAULT fnd_api.g_false.
-- This can be finessed as memory is allocated for each even if
-- user skips them.  Now changed to DEFAULT NULL, retaining the same
-- default semantics by NVL in the body.  This is done according to
-- current performance coding standard.
--
--    p_init_error_handler            IN   VARCHAR2   DEFAULT NULL,
--    p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT NULL,
--    p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT NULL,
--    p_log_errors                    IN   VARCHAR2   DEFAULT NULL,
--    p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT NULL,
--    p_commit                        IN   VARCHAR2   DEFAULT NULL,
--
-- Mon Aug 31 09:26:11 PDT 2009 bso
--
/*#
 * Create, update or delete User-Defined Attribute data for Supplier.
 * This is a straight-forward wrapper of the same procedure in
 * EGO_USER_ATTRS_DATA_PUB package.  Please refer to that package for
 * more information.
 *
 * @param p_api_version Current version is 1.0
 * @param p_attributes_row_table Contains row-level data and metadata
 * about each attribute group being processed.  See EGO_USER_ATTR_ROW_OBJ
 * in EGO_USER_ATTRS_DATA_PUB package for more information.
 * @param p_attributes_data_table Contains data and metadata about each
 * attribute being processed.  See EGO_USER_ATTR_DATA_OBJ
 * in EGO_USER_ATTRS_DATA_PUB package for more information.
 * @param p_pk_column_name_value_pairs Contains the Primary Key column
 * names and values that identify the specific object instance to which
 * this data applies.
 * See EGO_COL_NAME_VALUE_PAIR_OBJ
 * in EGO_USER_ATTRS_DATA_PUB package for more information.
 * @param p_class_code_name_value_pairs Contains the Classification Code(s)
 * for the specific object instance to which this data applies.
 * See EGO_COL_NAME_VALUE_PAIR_OBJ
 * in EGO_USER_ATTRS_DATA_PUB package for more information.
 * @param p_user_privileges_on_object Contains the list of privileges
 * granted to the current user on the specific object instance identified
 * by p_pk_column_name_value_pairs.
 * See EGO_USER_ATTRS_DATA_PUB package for more information.
 * @param p_entity_id Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_index Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_code Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_debug_level Used in debugging.  Valid values range from 0 (no
 * debugging) to 3 (full debugging).  The debug file is created in the
 * first directory in the list returned by the following query:
 * SELECT VALUE FROM V$PARAMETER WHERE NAME = 'utl_file_dir';
 * @param p_init_error_handler Indicates whether to initialize ERROR_HANDLER
 * message stack (and open debug session, if applicable).
 * Default value NULL means FND_API.G_FALSE.
 * @param p_write_to_concurrent_log Indicates whether to log ERROR_HANDLER
 * messages to concurrent log (only applicable when called from concurrent
 * program and when p_log_errors is passed as FND_API.G_TRUE).
 * Default value NULL means FND_API.G_FALSE.
 * @param p_init_fnd_msg_list Indicates whether to initialize FND_MSG_PUB
 * message stack.
 * Default value NULL means FND_API.G_FALSE.
 * @param p_log_errors Indicates whether to write ERROR_HANDLER message
 * stack to MTL_INTERFACE_ERRORS, the concurrent log (if applicable),
 * and the debug file (if applicable); if FND_API.G_FALSE is passed,
 * messages will still be added to ERROR_HANDLER's message stack, but
 * the message stack will not be written to any destination.
 * Default value NULL means FND_API.G_FALSE.
 * @param p_add_errors_to_fnd_stack Indicates whether messages written
 * to ERROR_HANDLER message stack will also be written to FND_MSG_PUB
 * message stack.
 * Default value NULL means FND_API.G_FALSE.
 * @param p_commit Indicates whether to commit work for all attribute
 * group rows that are processed successfully; if FND_API.G_FALSE is
 * passed, the API will not commit any work.
 * Default value NULL means FND_API.G_FALSE.
 * @param x_failed_row_id_list Returns a comma-delimited list of
 * ROW_IDENTIFIERs (the field in EGO_USER_ATTR_ROW_OBJ, which is
 * discussed above) indicating attribute group rows that failed
 * in processing.  An error will be logged for each failed row.
 * @param x_return_status Returns one of three values indicating the
 * most serious error encountered during processing:
 * FND_API.G_RET_STS_SUCCESS if no errors occurred,
 * FND_API.G_RET_STS_ERROR if at least one row encountered an error, and
 * FND_API.G_RET_STS_UNEXP_ERROR if at least one row encountered an
 * unexpected error.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 * @rep:displayname Process User-Defined Attributes Data
 */
PROCEDURE Process_User_Attrs_Data (
    p_api_version                   IN   NUMBER,
    p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE,
    p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE,
    p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY,
    p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY,
    p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL,
    p_entity_id                     IN   NUMBER     DEFAULT NULL,
    p_entity_index                  IN   NUMBER     DEFAULT NULL,
    p_entity_code                   IN   VARCHAR2   DEFAULT NULL,
    p_debug_level                   IN   NUMBER     DEFAULT 0,
    p_init_error_handler            IN   VARCHAR2   DEFAULT NULL,
    p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT NULL,
    p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT NULL,
    p_log_errors                    IN   VARCHAR2   DEFAULT NULL,
    p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT NULL,
    p_commit                        IN   VARCHAR2   DEFAULT NULL,
    x_failed_row_id_list            OUT NOCOPY VARCHAR2,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_errorcode                     OUT NOCOPY NUMBER,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2
);


--
-- This version of EGO's UDA Get User Attributes Data API is
-- almost identical to the original version in ego_user_attrs_data_pub
-- with the exception of hardcoding the object name HZ_PARTIES which
-- is the only object name expected when accessing UDA for Supplier
-- related entities.
--
-- Another minor difference is the following optional parameters.  In the
-- original EGO API they are defined as having DEFAULT fnd_api.g_false.
-- This can be finessed as memory is allocated for each even if
-- user skips them.  Now changed to DEFAULT NULL, retaining the same
-- default semantics by NVL in the body.  This is done according to
-- current performance coding standard.
--
--    p_init_error_handler            IN   VARCHAR2   DEFAULT NULL,
--    p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT NULL,
--    p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT NULL,
--
-- Tue Sep  1 09:51:26 PDT 2009 bso R12.1.2
--
/*#
 * Retrieves requested User-Defined Attribute data for one Supplier instance.
 * Parameters provide identifying data and metadata for an object instance,
 * as well as an EGO_ATTR_GROUP_REQUEST_TABLE specifying
 * the data to fetch.  The procedure fetches the requested data from the
 * database (transforming internal values to display values as necessary)
 * and returns it in the form of two tables: an EGO_USER_ATTR_ROW_TABLE and
 * a corresponding EGO_USER_ATTR_DATA_TABLE.
 * For more information about EGO table data types and parameters
 * refer to the EGO_USER_ATTRS_DATA_PUB package.
 *
 * @param p_api_version Current version is 1.0
 * @param p_pk_column_name_value_pairs Contains the Primary Key column
 * names and values that identify the specific object instance to which
 * this data applies.
 * @param p_attr_group_request_table Contains a list of elements, each
 * of which identifies an attribute group whose data to retrieve.
 * @param p_user_privileges_on_object Contains the list of privileges
 * granted to the current user on the specific object instance identified
 * by p_pk_column_name_value_pairs.
 * @param p_entity_id Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_index Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_code Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_debug_level Used in debugging.  Valid values range from 0 (no
 * debugging) to 3 (full debugging).  The debug file is created in the
 * first directory in the list returned by the following query:
 * SELECT VALUE FROM V$PARAMETER WHERE NAME = 'utl_file_dir';
 * @param p_init_error_handler Indicates whether to initialize ERROR_HANDLER
 * message stack (and open debug session, if applicable)
 * Default value NULL means FND_API.G_FALSE.
 * @param p_init_fnd_msg_list Indicates whether to initialize FND_MSG_PUB
 * message stack.
 * Default value NULL means FND_API.G_FALSE.
 * @param p_add_errors_to_fnd_stack Indicates whether messages written
 * to ERROR_HANDLER message stack will also be written to FND_MSG_PUB
 * message stack.
 * Default value NULL means FND_API.G_FALSE.
 * @param x_attributes_row_table Contains row-level data and metadata
 * about each attribute group whose data is being returned.
 * @param x_attributes_data_table Contains data and metadata about each
 * attribute whose data is being returned.
 * @param x_return_status Returns one of three values indicating the
 * most serious error encountered during processing:
 * FND_API.G_RET_STS_SUCCESS if no errors occurred,
 * FND_API.G_RET_STS_ERROR if at least one error occurred, and
 * FND_API.G_RET_STS_UNEXP_ERROR if at least one unexpected error occurred.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 * @rep:displayname Get User-Defined Attributes Data
 */
PROCEDURE Get_User_Attrs_Data (
    p_api_version                   IN   NUMBER,
    p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY,
    p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE,
    p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL,
    p_entity_id                     IN   VARCHAR2   DEFAULT NULL,
    p_entity_index                  IN   NUMBER     DEFAULT NULL,
    p_entity_code                   IN   VARCHAR2   DEFAULT NULL,
    p_debug_level                   IN   NUMBER     DEFAULT 0,
    p_init_error_handler            IN   VARCHAR2   DEFAULT NULL,
    p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT NULL,
    p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT NULL,
    x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE,
    x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_errorcode                     OUT NOCOPY NUMBER,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2
);

--
-- End Supplier Hub: Data Publication
--


END POS_VENDOR_PUB_PKG;

/
