--------------------------------------------------------
--  DDL for Package AP_TAX_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_TAX_ENGINE_PKG" AUTHID CURRENT_USER as
/* $Header: aptxengs.pls 120.2 2005/10/06 18:11:38 hongliu noship $ */

TYPE tax_info_rec_type IS RECORD
(

-- This record holds general information used by the tax engine about
-- each transaction, transaction line and tax line. Records in this
-- global can change on each row returned from any of the tax views.

----------------------------------------------------------------------
--  Primary Keys
----------------------------------------------------------------------
trx_header_id                   po_headers_all.po_header_id%TYPE,
trx_line_id                     po_lines_all.po_line_id%TYPE,
trx_shipment_id                 po_line_locations_all.line_location_id%TYPE,
trx_distribution_id             po_distributions_all.po_distribution_id%TYPE,


----------------------------------------------------------------------
--  Transaction Information
----------------------------------------------------------------------
tax_line_number                 varchar2(1),
set_of_books_id                 po_distributions_all.set_of_books_id%TYPE,
request_id                      po_headers_all.request_id%TYPE,
trx_number                      ap_invoices_all.invoice_num%TYPE,
previous_trx_header_id          number(15),
trx_date                        po_headers_all.last_update_date%TYPE,
trx_currency_code               po_headers_all.currency_code%TYPE,
exchange_rate                   po_headers_all.rate%TYPE,
minimum_accountable_unit        fnd_currencies.minimum_accountable_unit%TYPE,
precision                       fnd_currencies.precision%TYPE,
ship_from_supplier_id           po_headers_all.vendor_id%TYPE,
ship_from_supplier_number       po_vendors.segment1%TYPE,
ship_from_supplier_name         po_vendors.vendor_name%TYPE,
ship_from_site_use_id           po_headers_all.vendor_site_id%TYPE,
ship_from_country               po_vendor_sites_all.country%TYPE,
ship_from_state                 po_vendor_sites_all.state%TYPE,
ship_from_county                po_vendor_sites_all.county%TYPE,
-- Modified the definition of ship_to_city for bug 3480512 ..
ship_from_city                  po_vendor_sites_all.city%TYPE,
ship_from_province              varchar2(150),
ship_from_postal_code           po_vendor_sites_all.zip%TYPE,
ship_from_in_city_limits_flag   varchar2(1),
ship_from_geocode               varchar2(1),
line_number                     po_lines_all.line_num%TYPE,
trx_line_type                   po_line_types_tl.line_type%TYPE,
inventory_item_id               po_lines_all.item_id%TYPE,
part_number                     mtl_system_items.segment1%TYPE,
quantity                        po_line_locations_all.quantity%TYPE,
quantity_ordered                po_distributions_all.quantity_ordered%TYPE,
unit_price                      po_lines_all.unit_price%TYPE,
price_override                  po_line_locations_all.price_override%TYPE,
taxable_flag                    po_line_locations_all.taxable_flag%TYPE,
code_combination_id             po_distributions_all.code_combination_id%TYPE,
fob_code                        po_headers_all.fob_lookup_code%TYPE,
previous_trx_line_id            ap_invoice_distributions_all.po_distribution_id%TYPE,
ussgl_transaction_code          po_lines_all.ussgl_transaction_code%TYPE,
ussgl_trx_code_context          po_lines_all.government_context%TYPE,
ship_to_location_id             po_line_locations_all.ship_to_location_id%TYPE,
ship_to_organization_id         po_line_locations_all.ship_to_organization_id%TYPE,
ship_to_warehouse_id            varchar2(1),
ship_to_country                 hr_locations_all.country%TYPE,
ship_to_state                   varchar2(150),
ship_to_county                  varchar2(150),
ship_to_city                    hz_locations.city%TYPE,
ship_to_province                varchar2(150),
ship_to_postal_code             hr_locations_all.postal_code%TYPE,
ship_to_in_city_limits_flag     varchar2(1),
ship_to_geocode                 varchar2(1),
poo_address_code                varchar2(1),
poa_address_code                varchar2(1),
tax_code_id                     ap_tax_codes_all.tax_id%TYPE,
tax_code                        ap_tax_codes_all.name%TYPE,
tax_user_override_flag          po_line_locations_all.tax_user_override_flag%TYPE,
tax_rate                        ap_tax_codes_all.tax_rate%TYPE,
total_tax_amount                po_distributions_all.recoverable_tax%TYPE,
recoverable_tax                 po_distributions_all.recoverable_tax%TYPE,
nonrecoverable_tax              po_distributions_all.nonrecoverable_tax%TYPE,
location_qualifier              varchar2(1),
compounding_precedence          varchar2(1),
tax_exemption_id                varchar2(1),
tax_exception_id                varchar2(1),
vendor_control_exemptions       varchar2(1),
tax_recovery_rate               po_distributions_all.recovery_rate%TYPE,
tax_recovery_override_flag      po_distributions_all.tax_recovery_override_flag%TYPE,
global_attribute1               po_line_locations_all.global_attribute1%TYPE,
global_attribute2               po_line_locations_all.global_attribute2%TYPE,
global_attribute3               po_line_locations_all.global_attribute3%TYPE,
global_attribute4               po_line_locations_all.global_attribute4%TYPE,
global_attribute5               po_line_locations_all.global_attribute5%TYPE,
global_numeric_attribute1       varchar2(1),
global_numeric_attribute2       varchar2(1),
global_numeric_attribute3       varchar2(1),
global_numeric_attribute4       varchar2(1),
global_numeric_attribute5       varchar2(1),
tax_exempt_flag                 varchar2(1),
tax_exempt_number               varchar2(1),
tax_exempt_reason_code          varchar2(1),
company_code                    varchar2(1),
division_code                   varchar2(1),
audit_flag                      varchar2(1),
tax_header_level_flag           varchar2(1),
--tax_rounding_rule               po_vendor_sites_all.ap_tax_rounding_rule%TYPE,
tax_rounding_rule               ap_supplier_sites_all.ap_tax_rounding_rule%TYPE,
tax_type                        ap_tax_codes_all.tax_type%TYPE,
tax_description                 ap_tax_codes_all.description%TYPE,
allow_tax_code_override_flag    gl_tax_option_accounts.allow_tax_code_override_flag%TYPE,
project_id                      ap_invoice_distributions_all.project_id%TYPE,
task_id                         ap_invoice_distributions_all.task_id%TYPE,
award_id                        ap_invoice_distributions_all.award_id%TYPE,
expenditure_type                ap_invoice_distributions_all.expenditure_type%TYPE,
expenditure_organization_id     ap_invoice_distributions_all.expenditure_organization_id%TYPE,
expenditure_item_date           ap_invoice_distributions_all.expenditure_item_date%TYPE,
pa_quantity                     ap_invoice_distributions_all.pa_quantity%TYPE,
tax_minimum_accountable_unit    financials_system_params_all.minimum_accountable_unit%TYPE,
tax_precision                   financials_system_params_all.precision%TYPE,
amount_includes_tax_flag        ap_invoice_distributions_all.amount_includes_tax_flag%TYPE,
tax_calculated_flag             ap_invoice_distributions_all.tax_calculated_flag%TYPE,
tax_recoverable_flag            ap_invoice_distributions_all.tax_recoverable_flag%TYPE,
currency_unit_price             po_requisition_lines_all.currency_unit_price%TYPE,
account_gl_date                 ap_invoice_distributions_all.accounting_date%TYPE,
prepay_tax_parent_id            NUMBER,
invoice_includes_prepay_flag    varchar2(1),
-- Added for the bug 2373358 by zmohiudd..
rcv_transaction_id ap_invoice_distributions_all.rcv_transaction_id%TYPE,
-- added for bug 3672005
assets_tracking_flag            ap_invoice_distributions_all.assets_tracking_flag%TYPE
);


g_tax_info_rec   tax_info_rec_type;

TYPE tax_info_rec_tbl_type IS TABLE OF tax_info_rec_type
     INDEX BY BINARY_INTEGER;

g_tax_info_tbl     AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type;
g_pdt_tax_info_tbl AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type;
g_appl_name        FND_APPLICATION.application_short_name%TYPE;

--Index of table g_tax_info_tbl
g_num INTEGER := 0;


-- Define record and table types to create allocations in AP_CHRG_ALLOCATIONS table
-- AP_CHRG_ALLOCATIONS links tax and taxable items.

TYPE tax_alloc_rec_type is RECORD (item_dist_id             NUMBER(15),
                                   allocated_amount         NUMBER,
                                   charge_dist_id           NUMBER(15));

TYPE tax_alloc_tbl_type is TABLE of tax_alloc_rec_type
                 index by BINARY_INTEGER;

g_rec_tax_alloc_tbl      tax_alloc_tbl_type;
g_nonrec_tax_alloc_tbl   tax_alloc_tbl_type;

--Indexes for table g_tax_info_tbl

g_rec_alloc_num INTEGER := 0;
g_nonrec_alloc_num INTEGER := 0;


TYPE system_info_rec_type IS RECORD
(
  --
  -- Note: This record holds general system-level tax information
  -- All tax information should be moved to the consolidated view structure,
  -- even if it resides at system level.
  --
        ap                           ap_system_parameters%ROWTYPE,
        inventory_organization_id    financials_system_params_all.org_id%TYPE
);

sysinfo system_info_rec_type;

ap                              ap_system_parameters%ROWTYPE;

inventory_organization_id       financials_system_params_all.inventory_organization_id%TYPE;


PROCEDURE calculate_tax
          (p_viewname                   IN  VARCHAR2,
           p_trx_header_id              IN  NUMBER,
           p_trx_line_id                IN  NUMBER,
           p_trx_shipment_id            IN  NUMBER,
           p_calling_sequence           IN  VARCHAR2,
           p_tax_info_tbl               IN OUT NOCOPY tax_info_rec_tbl_type
           );

PROCEDURE calculate_tax
          ( p_pdt_tax_info_tbl           IN  AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type
           ,p_application_name           IN  VARCHAR2
           ,p_tax_info_tbl               IN OUT NOCOPY AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type
           );

PROCEDURE copy_record
          (p_calling_sequence           IN VARCHAR2,
           p_tax_info_rec               IN tax_info_rec_type
           );


PROCEDURE initialize_g_tax_info_rec
          (p_calling_sequence           IN VARCHAR2
           );

/* Function called by view JG_AP_TAX_LINES_SUMMARY_V to provide multiple tax inclusive calculation solution. */
FUNCTION sum_tax_group_rate
          (p_tax_group_id               IN  ar_tax_group_codes_all.tax_group_id%TYPE,
           p_trx_date                   IN  ap_invoices_all.invoice_date%TYPE,
           p_vendor_site_id             IN  po_vendor_sites_all.vendor_site_id%TYPE
           )
                                        return NUMBER;

/* Function called by view AP_TAX_LINES_SUMMARY_V to provide inclusive tax calculation with offset solution. */
FUNCTION offset_factor
   (p_offset_tax_flag	     IN  ap_supplier_sites_all.offset_tax_flag%TYPE,
    p_amount_includes_tax_flag IN ap_invoice_distributions_all.amount_includes_tax_flag%TYPE,
    p_tax_rate		IN ap_tax_codes_all.tax_rate%TYPE,
    p_offset_tax_code_id     IN  ap_tax_codes_all.offset_tax_code_id%TYPE,
    p_trx_date         IN  ap_invoices_all.invoice_date%TYPE)
					 return NUMBER;

/* Function called by the tax view to get orginal amount (replace aid.amount) */
FUNCTION get_amount( p_invoice_distribution_id     NUMBER,
                     p_line_type_lookup_code       VARCHAR2,
                     p_amount_includes_tax_flag    VARCHAR2,
                     p_amount                      NUMBER )
                                        return NUMBER;

end AP_TAX_ENGINE_PKG;

 

/
