--------------------------------------------------------
--  DDL for Package AP_WEB_EXPORT_ER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_EXPORT_ER" AUTHID CURRENT_USER AS
  /* $Header: apwexpts.pls 120.11.12010000.5 2009/12/16 12:57:21 stalasil ship $ */

  g_debug_switch      VARCHAR2(1) := 'N';
  g_last_updated_by   NUMBER;
  g_last_update_login NUMBER;
  ------------------------------------------------------------------------
  -- Table Types for Expenses Headers
  ------------------------------------------------------------------------
  TYPE InvoiceInfoRecType IS RECORD(
    report_header_id           ap_expense_report_headers.report_header_id%TYPE,
    employee_id                ap_expense_report_headers.employee_id%TYPE,
    employee_number            per_all_people_f.employee_number%TYPE,
    week_end_date              ap_expense_report_headers.week_end_date%TYPE,
    invoice_num                ap_expense_report_headers.invoice_num%TYPE,
    total                      ap_expense_report_headers.total%TYPE,
    description                ap_expense_report_headers.description%TYPE,
    name                       per_all_people_f.full_name%TYPE,
    location_code              hr_locations.location_code%TYPE,
    address_line_1             hr_locations.address_line_1%TYPE,
    address_line_2             hr_locations.address_line_2%TYPE,
    address_line_3             hr_locations.address_line_3%TYPE,
    city                       hr_locations.town_or_city%TYPE,
    state                      hr_locations.region_2%TYPE,
    postal_code                hr_locations.postal_code%TYPE,
    province                   hr_locations.region_1%TYPE,
    county                     hr_locations.region_1%TYPE,
    country                    hr_locations.country%TYPE,
    vendor_id                  ap_suppliers.vendor_id%TYPE,
    header_vendor_id           ap_expense_report_headers.vendor_id%TYPE,
    --hold_lookup_code           ap_expense_report_headers.hold_lookup_code%TYPE,
    --nls_hold_code              ap_lookup_codes.displayed_field%TYPE,
    --hold_description           ap_lookup_codes.description%TYPE,
    created_by                 ap_expense_report_headers.created_by%TYPE,
    default_currency_code      ap_expense_report_headers.default_currency_code%TYPE,
    default_exchange_rate_type ap_expense_report_headers.default_exchange_rate_type%TYPE,
    default_exchange_rate      ap_expense_report_headers.default_exchange_rate%TYPE,
    default_exchange_date      ap_expense_report_headers.default_exchange_date%TYPE,
    accts_pay_ccid             ap_expense_report_headers.accts_pay_code_combination_id%TYPE,
    set_of_books_id            ap_expense_report_headers.set_of_books_id%TYPE,
    accounting_date            ap_expense_report_headers.accounting_date%TYPE,
    header_vendor_site_id      ap_expense_report_headers.vendor_site_id%TYPE,
    apply_advances_flag        ap_expense_report_headers.apply_advances_default%TYPE,
    advance_invoice_to_apply   ap_expense_report_headers.advance_invoice_to_apply%TYPE,
    amount_want_to_apply       ap_expense_report_headers.maximum_amount_to_apply%TYPE,
    home_or_office             ap_expense_report_headers.expense_check_address_flag%TYPE,
    current_emp_id             ap_expense_report_headers.employee_id%TYPE,
    voucher_num                ap_expense_report_headers.voucher_num%TYPE,
    base_amount                ap_expense_report_headers.total%TYPE,
    doc_category_code          ap_expense_report_headers.doc_category_code%TYPE,
    reference_1                ap_expense_report_headers.reference_1%TYPE,
    reference_2                ap_expense_report_headers.reference_2%TYPE,
    awt_group_id               ap_expense_report_headers.awt_group_id%TYPE,
    global_attribute1          ap_expense_report_headers.global_attribute1%TYPE,
    global_attribute2          ap_expense_report_headers.global_attribute2%TYPE,
    global_attribute3          ap_expense_report_headers.global_attribute3%TYPE,
    global_attribute4          ap_expense_report_headers.global_attribute4%TYPE,
    global_attribute5          ap_expense_report_headers.global_attribute5%TYPE,
    global_attribute6          ap_expense_report_headers.global_attribute6%TYPE,
    global_attribute7          ap_expense_report_headers.global_attribute7%TYPE,
    global_attribute8          ap_expense_report_headers.global_attribute8%TYPE,
    global_attribute9          ap_expense_report_headers.global_attribute9%TYPE,
    global_attribute10         ap_expense_report_headers.global_attribute10%TYPE,
    global_attribute11         ap_expense_report_headers.global_attribute11%TYPE,
    global_attribute12         ap_expense_report_headers.global_attribute12%TYPE,
    global_attribute13         ap_expense_report_headers.global_attribute13%TYPE,
    global_attribute14         ap_expense_report_headers.global_attribute14%TYPE,
    global_attribute15         ap_expense_report_headers.global_attribute15%TYPE,
    global_attribute16         ap_expense_report_headers.global_attribute16%TYPE,
    global_attribute17         ap_expense_report_headers.global_attribute17%TYPE,
    global_attribute18         ap_expense_report_headers.global_attribute18%TYPE,
    global_attribute19         ap_expense_report_headers.global_attribute19%TYPE,
    global_attribute20         ap_expense_report_headers.global_attribute20%TYPE,
    global_attribute_category  ap_expense_report_headers.global_attribute_category%TYPE,
    attribute1                 ap_expense_report_headers.attribute1%TYPE,
    attribute2                 ap_expense_report_headers.attribute2%TYPE,
    attribute3                 ap_expense_report_headers.attribute3%TYPE,
    attribute4                 ap_expense_report_headers.attribute4%TYPE,
    attribute5                 ap_expense_report_headers.attribute5%TYPE,
    attribute6                 ap_expense_report_headers.attribute6%TYPE,
    attribute7                 ap_expense_report_headers.attribute7%TYPE,
    attribute8                 ap_expense_report_headers.attribute8%TYPE,
    attribute9                 ap_expense_report_headers.attribute9%TYPE,
    attribute10                ap_expense_report_headers.attribute10%TYPE,
    attribute11                ap_expense_report_headers.attribute11%TYPE,
    attribute12                ap_expense_report_headers.attribute12%TYPE,
    attribute13                ap_expense_report_headers.attribute13%TYPE,
    attribute14                ap_expense_report_headers.attribute14%TYPE,
    attribute15                ap_expense_report_headers.attribute15%TYPE,
    attribute_category         ap_expense_report_headers.attribute_category%TYPE,
    payment_currency_code      ap_expense_report_headers.payment_currency_code%TYPE,
    payment_cross_rate_type    ap_expense_report_headers.payment_cross_rate_type%TYPE,
    payment_cross_rate_date    ap_expense_report_headers.payment_cross_rate_date%TYPE,
    payment_cross_rate         ap_expense_report_headers.payment_cross_rate%TYPE,
    prepay_num                 ap_expense_report_headers.prepay_num%TYPE,
    prepay_dist_num            ap_expense_report_headers.prepay_dist_num%TYPE,
    prepay_gl_date             ap_expense_report_headers.prepay_gl_date%TYPE,
    paid_on_behalf_employee_id ap_expense_report_headers.paid_on_behalf_employee_id%TYPE,
    amt_due_employee           ap_expense_report_headers.amt_due_employee%TYPE,
    amt_due_ccard_company      ap_expense_report_headers.amt_due_ccard_company%TYPE,
    per_information18_19       per_all_people_f.per_information18%TYPE,
    per_information_category   per_all_people_f.per_information_category%TYPE,
    source                     ap_expense_report_headers.source%TYPE,
    group_id                   ap_invoices_interface.group_id%TYPE,
    style                      hr_locations.style%TYPE,
    org_id                     ap_expense_report_headers_all.org_id%TYPE,
    invoice_id                 ap_invoices_interface.invoice_id%TYPE,
    invoice_type_lookup_code   ap_invoices_interface.invoice_type_lookup_code%TYPE,
    gl_date                    ap_invoices_interface.gl_date%TYPE,
    alternate_name             per_all_people_f.full_name%TYPE,
    amount_app_to_discount     ap_invoices_interface.amount_applicable_to_discount%TYPE,
    payment_method_code        iby_payment_methods_vl.payment_method_code%TYPE,
    is_contingent	       VARCHAR2(2));

  -----------------------------------------------------------------------
  -- Table Types for Expense Lines
  -----------------------------------------------------------------------

  TYPE InvoiceLinesInfoRecType IS RECORD(
    report_header_id           ap_expense_report_lines.report_header_id%TYPE,
    report_line_id             ap_expense_report_lines.report_line_id%TYPE,
    code_combination_id        ap_expense_report_lines.code_combination_id%TYPE,
    line_type_lookup_code      ap_lookup_codes.lookup_code%TYPE,
    line_vat_code              ap_expense_report_lines.vat_code%TYPE,
    line_tax_code_id           ap_expense_report_lines.tax_code_id%TYPE,
    distribution_amount_sign   NUMBER,
    stat_amount_sign           NUMBER,
    stat_amount                ap_expense_report_lines.stat_amount%TYPE,
    line_set_of_books_id       ap_expense_report_lines.set_of_books_id%TYPE,
    distribution_amount        ap_expense_report_lines.amount%TYPE,
    item_description           ap_expense_report_lines.item_description%TYPE,
    db_line_type               ap_expense_report_lines.line_type_lookup_code%TYPE,
    distribution_line_number   ap_expense_report_lines.distribution_line_number%TYPE,
    base_amount                ap_expense_report_lines.amount%TYPE,
    assets_tracking_flag       VARCHAR2(2),
    attribute1                 ap_expense_report_lines.attribute1%TYPE,
    attribute2                 ap_expense_report_lines.attribute2%TYPE,
    attribute3                 ap_expense_report_lines.attribute3%TYPE,
    attribute4                 ap_expense_report_lines.attribute4%TYPE,
    attribute5                 ap_expense_report_lines.attribute5%TYPE,
    attribute6                 ap_expense_report_lines.attribute6%TYPE,
    attribute7                 ap_expense_report_lines.attribute7%TYPE,
    attribute8                 ap_expense_report_lines.attribute8%TYPE,
    attribute9                 ap_expense_report_lines.attribute9%TYPE,
    attribute10                ap_expense_report_lines.attribute10%TYPE,
    attribute11                ap_expense_report_lines.attribute11%TYPE,
    attribute12                ap_expense_report_lines.attribute12%TYPE,
    attribute13                ap_expense_report_lines.attribute13%TYPE,
    attribute14                ap_expense_report_lines.attribute14%TYPE,
    attribute15                ap_expense_report_lines.attribute15%TYPE,
    attribute_category         ap_expense_report_lines.attribute_category%TYPE,
    pa_context                 ap_expense_report_lines.project_accounting_context%TYPE,
    project_id                 ap_expense_report_lines.project_id%TYPE,
    task_id                    ap_expense_report_lines.task_id%TYPE,
    exp_org_id                 ap_expense_report_lines.expenditure_organization_id%TYPE,
    expenditure_type           ap_expense_report_lines.expenditure_type%TYPE,
    expenditure_item_date      ap_expense_report_lines.expenditure_item_date%TYPE,
    pa_quantity                ap_expense_report_lines.pa_quantity%TYPE,
    reference_1                ap_expense_report_lines.reference_1%TYPE,
    reference_2                ap_expense_report_lines.reference_2%TYPE,
    awt_group_id               ap_expense_report_lines.awt_group_id%TYPE,
    amount_includes_tax_flag   ap_expense_report_lines.amount_includes_tax_flag%TYPE,
    tax_Code_Overide_flag      VARCHAR2(2),
    tax_recovery_rate          VARCHAR2(50),
    tax_recovery_override_flag VARCHAR2(2),
    tax_recoverable_flag       VARCHAR2(2),
    global_attribute1          ap_expense_report_lines.global_attribute1%TYPE,
    global_attribute2          ap_expense_report_lines.global_attribute2%TYPE,
    global_attribute3          ap_expense_report_lines.global_attribute3%TYPE,
    global_attribute4          ap_expense_report_lines.global_attribute4%TYPE,
    global_attribute5          ap_expense_report_lines.global_attribute5%TYPE,
    global_attribute6          ap_expense_report_lines.global_attribute6%TYPE,
    global_attribute7          ap_expense_report_lines.global_attribute7%TYPE,
    global_attribute8          ap_expense_report_lines.global_attribute8%TYPE,
    global_attribute9          ap_expense_report_lines.global_attribute9%TYPE,
    global_attribute10         ap_expense_report_lines.global_attribute10%TYPE,
    global_attribute11         ap_expense_report_lines.global_attribute11%TYPE,
    global_attribute12         ap_expense_report_lines.global_attribute12%TYPE,
    global_attribute13         ap_expense_report_lines.global_attribute13%TYPE,
    global_attribute14         ap_expense_report_lines.global_attribute14%TYPE,
    global_attribute15         ap_expense_report_lines.global_attribute15%TYPE,
    global_attribute16         ap_expense_report_lines.global_attribute16%TYPE,
    global_attribute17         ap_expense_report_lines.global_attribute17%TYPE,
    global_attribute18         ap_expense_report_lines.global_attribute18%TYPE,
    global_attribute19         ap_expense_report_lines.global_attribute19%TYPE,
    global_attribute20         ap_expense_report_lines.global_attribute20%TYPE,
    global_attribute_category  ap_expense_report_lines.global_attribute_category%TYPE,
    receipt_verified_flag      ap_expense_report_lines.receipt_verified_flag%TYPE,
    receipt_required_flag      ap_expense_report_lines.receipt_required_flag%TYPE,
    receipt_missing_flag       ap_expense_report_lines.receipt_missing_flag%TYPE,
    justification              ap_expense_report_lines.justification%TYPE,
    expense_group              ap_expense_report_lines.expense_group%TYPE,
    start_expense_date         ap_expense_report_lines.start_expense_date%TYPE,
    start_expense_date2        ap_expense_report_lines.start_expense_date%TYPE,
    end_expense_date           ap_expense_report_lines.end_expense_date%TYPE,
    merchant_document_number   ap_expense_report_lines.merchant_document_number%TYPE,
    merchant_name              ap_expense_report_lines.merchant_name%TYPE,
    merchant_reference         ap_expense_report_lines.merchant_reference%TYPE,
    merchant_tax_reg_number    ap_expense_report_lines.merchant_tax_reg_number%TYPE,
    merchant_taxpayer_id       ap_expense_report_lines.merchant_taxpayer_id%TYPE,
    country_of_supply          ap_expense_report_lines.country_of_supply%TYPE,
    receipt_currency_code      ap_expense_report_lines.receipt_currency_code%TYPE,
    receipt_conversion_rate    ap_expense_report_lines.receipt_conversion_rate%TYPE,
    receipt_currency_amount    ap_expense_report_lines.receipt_currency_amount%TYPE,
    daily_amount               ap_expense_report_lines.daily_amount%TYPE,
    web_parameter_id           ap_expense_report_lines.web_parameter_id%TYPE,
    adjustment_reason          ap_expense_report_lines.adjustment_reason%TYPE,
    credit_card_trx_id         ap_expense_report_lines.credit_card_trx_id%TYPE,
    company_prepaid_invoice_id ap_expense_report_lines.company_prepaid_invoice_id%TYPE,
    created_by                 ap_expense_report_lines.created_by%TYPE,
    pa_addition_flag           ap_invoice_lines_interface.pa_addition_flag%TYPE,
    type_1099                  ap_invoice_lines_interface.type_1099%TYPE,
    income_tax_region          ap_invoice_lines_interface.income_tax_region%TYPE,
    award_id                   ap_invoice_lines_interface.award_id%TYPE,
    invoice_id                 ap_invoice_lines_interface.invoice_id%TYPE,
    accounting_date            ap_invoice_lines_interface.accounting_date%TYPE,
    org_id                     ap_expense_report_lines_all.org_id%TYPE);

  TYPE InvoiceLinesRecTabType is TABLE of InvoiceLinesInfoRecType index by BINARY_INTEGER;

  TYPE VendorInfoRecType IS RECORD(
    vendor_id              ap_suppliers.vendor_id%TYPE,
    vendor_site_id         ap_supplier_sites.vendor_site_id%TYPE,
    employee_id            ap_expense_report_headers.employee_id%TYPE,
    party_id               ap_suppliers.party_id%TYPE,
    party_site_id          ap_supplier_sites.party_site_id%TYPE,
    home_or_office         VARCHAR2(2),
    terms_date_basis       ap_suppliers.terms_date_basis%TYPE,
    terms_id               ap_suppliers.terms_id%TYPE,
    pay_group              ap_suppliers.pay_group_lookup_code%TYPE,
    payment_priority       ap_suppliers.payment_priority%TYPE,
    liab_acc               ap_suppliers.accts_pay_code_combination_id%TYPE,
    prepay_ccid            ap_suppliers.prepay_code_combination_id%TYPE,
    always_take_disc_flag  ap_suppliers.always_take_disc_flag%TYPE,
    pay_date_basis         ap_suppliers.pay_date_basis_lookup_code%TYPE,
    vendor_name            ap_suppliers.vendor_name%TYPE,
    vendor_num             ap_suppliers.segment1%TYPE,
    allow_awt_flag         ap_supplier_sites.allow_awt_flag%TYPE,
    org_id                 ap_expense_report_headers.org_id%TYPE,
    address_line_1         hr_locations.address_line_1%TYPE,
    address_line_2         hr_locations.address_line_2%TYPE,
    address_line_3         hr_locations.address_line_3%TYPE,
    city                   hr_locations.town_or_city%TYPE,
    state                  hr_locations.region_2%TYPE,
    postal_code            hr_locations.postal_code%TYPE,
    province               hr_locations.region_1%TYPE,
    county                 hr_locations.region_1%TYPE,
    country                hr_locations.country%TYPE,
    style                  hr_locations.style%TYPE);

  ------------------------------------------------------------------------
  PROCEDURE UpdateDistsWithReceiptInfo(p_report_header_id IN NUMBER,
                                       p_debug_switch  IN VARCHAR2);
  ------------------------------------------------------------------------
  PROCEDURE ExportERtoAP(errbuf          OUT NOCOPY VARCHAR2,
                         retcode         OUT NOCOPY NUMBER,
                         p_batch_name    IN VARCHAR2,
                         p_source        IN VARCHAR2,
                         p_transfer_flag IN VARCHAR2,
                         p_gl_date       IN VARCHAR2,
                         p_group_id      IN VARCHAR2,
                         p_commit_cycles IN NUMBER,
                         p_debug_switch  IN VARCHAR2,
                         p_org_id        IN NUMBER,
                         p_role_name     IN VARCHAR2,
                         p_transfer_attachments IN VARCHAR2); --Bug#2823530 : Transfer Attachments to AP
  ------------------------------------------------------------------------
  FUNCTION ValidateERLines(p_report_header_id        IN NUMBER,
                           p_invoice_id              IN NUMBER,
                           p_transfer_flag           IN VARCHAR2,
                           p_base_currency           IN VARCHAR2,
                           p_set_of_books_id         IN NUMBER,
                           p_source                  IN VARCHAR2,
                           p_enable_recoverable_flag IN VARCHAR2,
                           p_invoice_lines_rec_tab   OUT NOCOPY InvoiceLinesRecTabType,
                           p_reject_code             OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN;
  ------------------------------------------------------------------------
  PROCEDURE InsertInvoiceInterface(p_invoice_rec InvoiceInfoRecType,
                                   p_vendor_rec  VendorInfoRecType);
  ------------------------------------------------------------------------
  --Bug: 6809570
  PROCEDURE InsertInvoiceLinesInterface(p_report_header_id        IN NUMBER,
                           p_invoice_id              IN NUMBER,
                           p_transfer_flag           IN VARCHAR2,
                           p_base_currency           IN VARCHAR2,
                           p_enable_recoverable_flag IN VARCHAR2);
  ------------------------------------------------------------------------
  FUNCTION GetVendorinfo(p_vendor_rec  IN OUT NOCOPY VendorInfoRecType,
                         p_reject_code OUT NOCOPY VARCHAR2) RETURN BOOLEAN;
  ------------------------------------------------------------------------
  FUNCTION CreatePayee(p_party_id  IN ap_suppliers.party_id%TYPE,
                       p_org_id    IN ap_expense_report_headers.org_id%TYPE,
                       p_reject_code OUT NOCOPY VARCHAR2) RETURN BOOLEAN;
  ------------------------------------------------------------------------

END AP_WEB_EXPORT_ER;

/