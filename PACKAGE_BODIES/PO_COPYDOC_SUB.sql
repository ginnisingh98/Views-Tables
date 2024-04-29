--------------------------------------------------------
--  DDL for Package Body PO_COPYDOC_SUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COPYDOC_SUB" AS
/* $Header: POXCPSUB.pls 120.6.12010000.10 2013/06/18 16:10:03 vegajula ship $*/

-- Cursor definitions:

  CURSOR po_line_cursor(x_po_header_id po_lines.po_header_id%TYPE) IS
    SELECT *
    FROM   PO_LINES
    WHERE  po_header_id = x_po_header_id
    ORDER BY line_num;

/* Bug# 3528563, We only need to consider the PRICE BREAKS while
 * validating Blankets. Without the condition on the shipment_type
 * it was also picking the Release while doing the validations since
 * Blankets and Releases share the po_line_id in PO_LINES_ALL.
 * This happened when Releases were entered for a BPA and the BPA
 * had to be re-approved after being REJECTED.
 * The same has to be done for Scheculed Relases too. */
  CURSOR po_shipment_cursor(x_po_line_id po_line_locations.po_line_id%TYPE) IS
    SELECT *
    FROM   PO_LINE_LOCATIONS
    WHERE  po_line_id = x_po_line_id
    AND    shipment_type not in ('BLANKET','SCHEDULED')
    ORDER BY shipment_num;

  CURSOR po_distribution_cursor(x_line_location_id po_distributions.line_location_id%TYPE) IS
    SELECT *
    FROM  PO_DISTRIBUTIONS POD
    WHERE POD.line_location_id = x_line_location_id
    AND   POD.distribution_type <> 'AGREEMENT'  --<ENCUMBRANCE FPJ>
    ORDER BY distribution_num;

  --<ENCUMBRANCE FPJ: added new cursor for encumbered BPA dists>
  CURSOR pa_distribution_cursor(x_po_header_id po_distributions.po_header_id%TYPE) IS
    SELECT *
    FROM  PO_DISTRIBUTIONS POD
    WHERE POD.po_header_id = x_po_header_id
    AND   POD.distribution_type = 'AGREEMENT'
    ORDER BY distribution_num;

-- end of cursor definitions

-- private functions

PROCEDURE get_fsp_values(
  x_ship_to_location_id        IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id        IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_ship_via_lookup_code       IN OUT NOCOPY  po_headers.ship_via_lookup_code%TYPE,
  x_fob_lookup_code            IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code      IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id                   IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id           IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                   IN OUT NOCOPY  po_online_report_text.sequence%TYPE
);

PROCEDURE get_vendor_values(
  x_vendor_id              IN      po_headers.vendor_id%TYPE,
  x_ship_to_location_id    IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id    IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_ship_via_lookup_code   IN OUT NOCOPY  po_headers.ship_via_lookup_code%TYPE,
  x_fob_lookup_code        IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code  IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id               IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id       IN      po_online_report_text.online_report_id%TYPE,
  x_sequence               IN OUT NOCOPY  po_online_report_text.sequence%TYPE
);

PROCEDURE get_vendor_site_values(
  x_vendor_id              IN      po_headers.vendor_id%TYPE,
  x_vendor_site_id         IN      po_headers.vendor_site_id%TYPE,
  x_ship_to_location_id    IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id    IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_ship_via_lookup_code   IN OUT NOCOPY  po_headers.ship_via_lookup_code%TYPE,
  x_fob_lookup_code        IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code  IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id               IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id       IN      po_online_report_text.online_report_id%TYPE,
  x_sequence               IN OUT NOCOPY  po_online_report_text.sequence%TYPE
);

PROCEDURE validate_buyer_id(
  x_buyer_id              IN OUT NOCOPY po_headers.agent_id%TYPE,
  x_online_report_id      IN     po_online_report_text.online_report_id%TYPE,
  x_sequence              IN OUT NOCOPY po_online_report_text.line_num%TYPE
);


PROCEDURE validate_vendor(
  x_sob_id                         IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id                     IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_vendor_id                  IN OUT NOCOPY  po_headers.vendor_id%TYPE,
  x_vendor_site_id             IN OUT NOCOPY  po_headers.vendor_site_id%TYPE,
  x_vendor_contact_id          IN OUT NOCOPY  po_headers.vendor_contact_id%TYPE,
  x_ship_to_location_id        IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id        IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_ship_via_lookup_code       IN OUT NOCOPY  po_headers.ship_via_lookup_code%TYPE,
  x_fob_lookup_code            IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code      IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id                   IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id               IN  po_online_report_text.online_report_id%TYPE,
  x_sequence                       IN OUT NOCOPY  po_online_report_text.sequence%TYPE
);

PROCEDURE validate_location_terms(
  x_sob_id                     IN      financials_system_parameters.set_of_books_id%TYPE,
  x_ship_to_location_id        IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id        IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_fob_lookup_code            IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code      IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id                   IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id           IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                   IN OUT NOCOPY  po_online_report_text.sequence%TYPE
);

PROCEDURE validate_item(
  x_item_id             IN OUT NOCOPY  po_lines.item_id%TYPE,
  x_item_description    IN OUT NOCOPY  po_lines.item_description%TYPE,
  x_item_revision       IN OUT NOCOPY  po_lines.item_revision%TYPE,
  x_category_id         IN OUT NOCOPY  po_lines.category_id%TYPE,
  x_line_type_id        IN      po_lines.line_type_id%TYPE,
  x_inv_org_id          IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num            IN      po_online_report_text.line_num%TYPE,
  x_return_code         OUT NOCOPY     NUMBER
);

PROCEDURE validate_project_id(
  x_project_id               IN OUT NOCOPY po_distributions.project_id%TYPE,
-- <PO_PJM_VALIDATION FPI>
-- Removed the x_destination_type_code and x_ship_to_organization_id arguments.
-- Added NOCOPY to x_project_id and x_sequence.
--  x_destination_type_code    IN      po_distributions.destination_type_code%TYPE,
--  x_ship_to_organization_id  IN      NUMBER,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE validate_task_id(
  x_task_id                  IN OUT NOCOPY  NUMBER,
  x_project_id               IN      NUMBER,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE validate_account_id(
  x_account_id               IN OUT NOCOPY  NUMBER,
  x_account_type	     IN	     VARCHAR2,
  x_gl_date                  IN      DATE,
  x_sob_id                   IN      financials_system_parameters.set_of_books_id%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE validate_destination_type_code(
  x_destination_type_code    IN OUT NOCOPY  po_distributions.destination_type_code%TYPE,
  x_item_id                  IN      po_lines.item_id%TYPE,
  x_ship_org_id              IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_accrue_on_receipt_flag   IN      varchar2,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE,
  x_line_location_id         IN      po_line_locations.line_location_id%TYPE, -- CONSIGNED FPI START
  x_po_line_id               IN      po_lines.po_line_id%TYPE, -- Bug 3557910 Additional Input Parameter PO LINE ID
  p_transaction_flow_header_id IN    NUMBER     --< Bug 3546252 >
);

PROCEDURE validate_deliver_to_person_id(
  x_deliver_to_person_id     IN OUT NOCOPY  po_distributions.deliver_to_person_id%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE validate_osp_data( x_wip_entity_id               IN NUMBER,
			     x_wip_operation_seq_num       IN NUMBER,
			     x_wip_resource_seq_num        IN NUMBER,
			     x_wip_repetitive_schedule_id  IN NUMBER,
			     x_wip_line_id                 IN NUMBER,
			     x_destination_organization_id IN NUMBER,
  			     x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  			     x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  			     x_line_num                 IN      po_online_report_text.line_num%TYPE,
  			     x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  			     x_distribution_num         IN      po_online_report_text.distribution_num%TYPE);

PROCEDURE validate_deliver_to_loc_id(
  x_deliver_to_location_id   IN OUT NOCOPY  po_distributions.deliver_to_location_id%TYPE,
  x_ship_to_organization_id  IN      NUMBER,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE validate_dest_subinventory(
  x_destination_subinventory IN OUT NOCOPY  po_distributions.destination_subinventory%TYPE,
  x_ship_to_organization_id  IN      NUMBER,
  x_item_id                  IN      po_lines.item_id%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

--<ENCUMBRANCE FPJ : removed procedure validate_gl_encumbered_date>
-- this is now added to regular submission check (POXVDCKB.pls 115.30)

PROCEDURE validate_contract_num(
  p_contract_id      IN PO_LINES_ALL.contract_id%TYPE,   -- <GC FPJ>
  x_online_report_id IN po_online_report_text.online_report_id%TYPE,
  x_sequence         IN OUT NOCOPY po_online_report_text.sequence%TYPE,
  x_line_num         IN po_online_report_text.line_num%TYPE
);

--<Bug 2864544 mbhargav START>
--Procedure that validate that the referenced global agreement is not cancelled or
--finally closed
PROCEDURE validate_global_ref(
  p_from_header_id     IN po_headers_all.po_header_id%TYPE,
  p_from_line_id       IN po_lines_all.po_line_id%TYPE,
  p_online_report_id   IN po_online_report_text.online_report_id%TYPE,
  p_sequence           IN OUT NOCOPY po_online_report_text.sequence%TYPE,
  p_line_num           IN po_online_report_text.line_num%TYPE
);
--<Bug 2864544 mbhargav END>

-- SERVICES FPJ Start
-- Procedure to validate the temp labor Job on PO lines

PROCEDURE validate_job(
  p_job_id              IN            po_lines.job_id%TYPE,
  p_online_report_id    IN            po_online_report_text.online_report_id%TYPE,
  p_line_num            IN            po_online_report_text.line_num%TYPE,
  p_sequence            IN OUT NOCOPY po_online_report_text.sequence%TYPE
);

-- SERVICES FPJ End

--< Shared Proc FPJ Start >
PROCEDURE validate_transaction_flow
(
    p_ship_to_org_id             IN     NUMBER,
    p_transaction_flow_header_id IN     NUMBER,
    p_item_category_id           IN     NUMBER,
    p_online_report_id           IN     NUMBER,
    p_line_num                   IN     NUMBER,
    p_shipment_num               IN     NUMBER,
    p_item_id                    IN     NUMBER, -- Bug 3433867
    x_sequence                   IN OUT NOCOPY NUMBER
);

PROCEDURE validate_org_assignments
(
    p_po_header_id     IN     NUMBER,
    p_vendor_id        IN     NUMBER,
    p_online_report_id IN     NUMBER,
    x_sequence         IN OUT NOCOPY NUMBER
);

PROCEDURE populate_session_gt
(
    x_return_status    OUT    NOCOPY VARCHAR2,
    p_po_header_id     IN     NUMBER,
    p_online_report_id IN     NUMBER,
    x_sequence         IN OUT NOCOPY NUMBER,
    x_key              OUT    NOCOPY NUMBER
);
--< Shared Proc FPJ End >


-- Bug 3488117: Added validation procedures for expenditure fields

PROCEDURE validate_exp_item_date(
  x_project_id               IN NUMBER,
  x_task_id                  IN NUMBER,
  x_exp_item_date            IN OUT NOCOPY DATE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE validate_exp_type(
  x_project_id               IN NUMBER,
  x_exp_type                 IN OUT NOCOPY  po_distributions.expenditure_type%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE validate_exp_org(
  x_org_id                   IN OUT NOCOPY NUMBER,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

-- End Bug 3488117
-- Start bug 14296213: project end date validation for copied po

PROCEDURE validate_proj_end_date(
  x_project_id               IN NUMBER,
  x_task_id                  IN NUMBER,
--  x_exp_item_date            IN OUT NOCOPY DATE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE validate_task_end_date(
  x_project_id               IN NUMBER,
  x_task_id                  IN NUMBER,
--  x_exp_item_date            IN OUT NOCOPY DATE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
);

-- End bug 14296213
-- end private function declarations

PROCEDURE get_fsp_values(
  x_ship_to_location_id        IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id        IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_ship_via_lookup_code       IN OUT NOCOPY  po_headers.ship_via_lookup_code%TYPE,
  x_fob_lookup_code            IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code      IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id                   IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id           IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                   IN OUT NOCOPY  po_online_report_text.sequence%TYPE
) IS

  x_progress  VARCHAR2(4) := NULL;

BEGIN

  x_progress := '001';

  SELECT fsp.ship_to_location_id,
         fsp.bill_to_location_id,
         fsp.ship_via_lookup_code,
         fsp.fob_lookup_code,
         fsp.freight_terms_lookup_code,
         fsp.terms_id
  INTO   x_ship_to_location_id,
         x_bill_to_location_id,
         x_ship_via_lookup_code,
         x_fob_lookup_code,
         x_freight_terms_lu_code,
         x_terms_id
  FROM   FINANCIALS_SYSTEM_PARAMETERS fsp;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_ship_to_location_id   := NULL;
    x_bill_to_location_id   := NULL;
    x_ship_via_lookup_code  := NULL;
    x_fob_lookup_code       := NULL;
    x_freight_terms_lu_code := NULL;
    x_terms_id              := NULL;
    fnd_message.set_name('PO', 'PO_MISSING_FSP_VALUES');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 240),
                                0, 0, 0);
  WHEN OTHERS THEN
    x_ship_to_location_id   := NULL;
    x_bill_to_location_id   := NULL;
    x_ship_via_lookup_code  := NULL;
    x_fob_lookup_code       := NULL;
    x_freight_terms_lu_code := NULL;
    x_terms_id              := NULL;
    po_copydoc_s1.copydoc_sql_error('get_fsp_values', x_progress, sqlcode,
                                   x_online_report_id,
                                   x_sequence,
                                   0, 0, 0);
END get_fsp_values;


PROCEDURE get_vendor_values(
  x_vendor_id              IN      po_headers.vendor_id%TYPE,
  x_ship_to_location_id    IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id    IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_ship_via_lookup_code   IN OUT NOCOPY  po_headers.ship_via_lookup_code%TYPE,
  x_fob_lookup_code        IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code  IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id               IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id       IN      po_online_report_text.online_report_id%TYPE,
  x_sequence               IN OUT NOCOPY  po_online_report_text.sequence%TYPE
) IS

  x_progress  VARCHAR2(4) := NULL;

BEGIN

  x_progress := '001';

-- Bug# 4546121:All columns that referred to the obsolete columns in po_vendors have
--              been nulled out.
  SELECT null,
         null,
         null,
         null,
         null,
         terms_id
  INTO   x_ship_to_location_id,
         x_bill_to_location_id,
         x_ship_via_lookup_code,
         x_fob_lookup_code,
         x_freight_terms_lu_code,
         x_terms_id
  FROM   PO_VENDORS
  WHERE  vendor_id = x_vendor_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    get_fsp_values(x_ship_to_location_id,
                   x_bill_to_location_id,
                   x_ship_via_lookup_code,
                   x_fob_lookup_code,
                   x_freight_terms_lu_code,
                   x_terms_id,
                   x_online_report_id,
                   x_sequence);
  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('get_vendor_values', x_progress, sqlcode,
                                   x_online_report_id,
                                   x_sequence,
                                   0, 0, 0);
    get_fsp_values(x_ship_to_location_id,
                   x_bill_to_location_id,
                   x_ship_via_lookup_code,
                   x_fob_lookup_code,
                   x_freight_terms_lu_code,
                   x_terms_id,
                   x_online_report_id,
                   x_sequence);

END get_vendor_values;


PROCEDURE get_vendor_site_values(
  x_vendor_id              IN      po_headers.vendor_id%TYPE,
  x_vendor_site_id         IN      po_headers.vendor_site_id%TYPE,
  x_ship_to_location_id    IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id    IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_ship_via_lookup_code   IN OUT NOCOPY  po_headers.ship_via_lookup_code%TYPE,
  x_fob_lookup_code        IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code  IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id               IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id       IN      po_online_report_text.online_report_id%TYPE,
  x_sequence               IN OUT NOCOPY  po_online_report_text.sequence%TYPE
) IS

  x_progress  VARCHAR2(4) := NULL;

BEGIN

  x_progress := '001';

  SELECT ship_to_location_id,
         bill_to_location_id,
         ship_via_lookup_code,
         fob_lookup_code,
         freight_terms_lookup_code,
         terms_id
  INTO   x_ship_to_location_id,
         x_bill_to_location_id,
         x_ship_via_lookup_code,
         x_fob_lookup_code,
         x_freight_terms_lu_code,
         x_terms_id
  FROM   PO_VENDOR_SITES
  WHERE  vendor_id = x_vendor_id
  AND    vendor_site_id = x_vendor_site_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    get_vendor_values(x_vendor_id,
                      x_ship_to_location_id,
                      x_bill_to_location_id,
                      x_ship_via_lookup_code,
                      x_fob_lookup_code,
                      x_freight_terms_lu_code,
                      x_terms_id,
                      x_online_report_id,
                      x_sequence);
  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('get_vendor_site_values', x_progress, sqlcode,
                                   x_online_report_id,
                                   x_sequence,
                                   0, 0, 0);
    get_vendor_values(x_vendor_id,
                      x_ship_to_location_id,
                      x_bill_to_location_id,
                      x_ship_via_lookup_code,
                      x_fob_lookup_code,
                      x_freight_terms_lu_code,
                      x_terms_id,
                      x_online_report_id,
                      x_sequence);

END get_vendor_site_values;


PROCEDURE validate_buyer_id(
  x_buyer_id              IN OUT NOCOPY po_headers.agent_id%TYPE,
  x_online_report_id      IN     po_online_report_text.online_report_id%TYPE,
  x_sequence              IN OUT NOCOPY po_online_report_text.line_num%TYPE
) IS
  x_valid_flag  VARCHAR2(2) := NULL;
  x_progress    VARCHAR2(4) := NULL;

BEGIN

  -- This field has to be not NULL, because it's a mandatory field.
  --   unless DB is corrupted.

  IF (x_buyer_id IS NULL) THEN
    fnd_message.set_name('PO', 'PO_PO_MISSING_BUYER_ID');
    po_copydoc_s1.online_report(x_online_report_id,
				x_sequence,
				substr(fnd_message.get, 1, 240),
				0, 0, 0);

  ELSE
    x_progress := '001';

    SELECT distinct 'Y'
    INTO   x_valid_flag
    FROM   po_buyers_val_v
    WHERE  employee_id = (
           SELECT agent_id FROM po_agents
           WHERE sysdate between nvl(start_date_active, sysdate-1)
                         and nvl(end_date_active, sysdate+1)
             AND agent_id = x_buyer_id);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_buyer_id := NULL;
    fnd_message.set_name('PO', 'PO_RI_INVALID_SUGGESTED_BUYER');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 240),
                                0, 0, 0);
  WHEN OTHERS THEN
    x_buyer_id := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_buyer_id', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    0, 0, 0);

END validate_buyer_id;

PROCEDURE validate_vendor(
  x_sob_id                         IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id                     IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_vendor_id                  IN OUT NOCOPY  po_headers.vendor_id%TYPE,
  x_vendor_site_id             IN OUT NOCOPY  po_headers.vendor_site_id%TYPE,
  x_vendor_contact_id          IN OUT NOCOPY  po_headers.vendor_contact_id%TYPE,
  x_ship_to_location_id        IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id        IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_ship_via_lookup_code       IN OUT NOCOPY  po_headers.ship_via_lookup_code%TYPE,
  x_fob_lookup_code            IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code      IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id                   IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id               IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                       IN OUT NOCOPY  po_online_report_text.sequence%TYPE
) IS

  x_progress    VARCHAR2(4) := NULL;
  x_valid_flag  VARCHAR2(2) := NULL;

BEGIN

  x_progress := '001';
  BEGIN
    SELECT distinct 'Y'
    INTO   x_valid_flag
    FROM   PO_VENDORS
    WHERE  vendor_id = x_vendor_id
    AND    enabled_flag = 'Y'
    AND    SYSDATE BETWEEN nvl(start_date_active, SYSDATE-1)
                       AND nvl(end_date_active, SYSDATE+1);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('PO', 'PO_PDOI_INVALID_VENDOR');
      fnd_message.set_token('VALUE', to_char(x_vendor_id), FALSE);
      x_vendor_id := NULL;
      po_copydoc_s1.online_report(x_online_report_id,
                                  x_sequence,
                                  substr(fnd_message.get, 1, 240),
                                  0, 0, 0);
    WHEN OTHERS THEN
      x_vendor_id := NULL;
      po_copydoc_s1.copydoc_sql_error('validate_vendor', x_progress, sqlcode,
                                     x_online_report_id,
                                     x_sequence,
                                     0, 0, 0);
  END;

  IF (x_vendor_id IS NULL) THEN
    x_vendor_site_id := NULL;
    x_vendor_contact_id := NULL;
  ELSE
    x_progress := '002';
    BEGIN
      SELECT distinct 'Y'
      INTO   x_valid_flag
      FROM   PO_VENDOR_SITES
      WHERE  vendor_site_id = x_vendor_site_id
      AND    vendor_id = x_vendor_id
      AND    nvl(rfq_only_site_flag,'N') <> 'Y'
      AND    purchasing_site_flag = 'Y'
      AND    SYSDATE < nvl(inactive_date, SYSDATE + 1);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	fnd_message.set_name('PO', 'PO_PDOI_INVALID_VENDOR_SITE');
	fnd_message.set_token('VALUE', to_char(x_vendor_site_id), FALSE);
        x_vendor_site_id := NULL;
        po_copydoc_s1.online_report(x_online_report_id,
                                    x_sequence,
                                    substr(fnd_message.get, 1, 240),
                                    0, 0, 0);
      WHEN OTHERS THEN
        x_vendor_site_id := NULL;
        po_copydoc_s1.copydoc_sql_error('validate_vendor', x_progress, sqlcode,
                                      x_online_report_id,
                                      x_sequence,
                                      0, 0, 0);
    END;
    IF (x_vendor_site_id IS NULL) THEN
      x_vendor_contact_id := NULL;
    ELSE
      -- It's ok to have vendor contact null, but not ok if it's invalid
      IF (x_vendor_contact_id IS NOT NULL) THEN
      x_progress := '003';
      BEGIN
        SELECT distinct 'Y'
        INTO   x_valid_flag
        FROM   PO_VENDOR_CONTACTS
        WHERE  vendor_contact_id = x_vendor_contact_id
        AND    vendor_site_id = x_vendor_site_id
        AND    SYSDATE < nvl(inactive_date, SYSDATE+1);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  fnd_message.set_name('PO', 'PO_PDOI_INVALID_VDR_CNTCT');
	  fnd_message.set_token('VALUE', to_char(x_vendor_contact_id), FALSE);
          x_vendor_contact_id := NULL;
          po_copydoc_s1.online_report(x_online_report_id,
                                      x_sequence,
                                      substr(fnd_message.get, 1, 240),
                                      0, 0, 0);
        WHEN OTHERS THEN
          x_vendor_contact_id := NULL;
          po_copydoc_s1.copydoc_sql_error('validate_vendor', x_progress, sqlcode,
                                         x_online_report_id,
                                         x_sequence,
                                         0, 0, 0);
      END;
      END IF;
    END IF;
  END IF;

  /* Get values for ship_to_location_id,
  --                bill_to_location_id,
  --                ship_via_lookup_code,
  --                fob_lookup_code,
  --                freight_terms_lookup_code,
  --                and terms_id
  bug 1673520 : dreddy
  we do not need this as we dont care if the locations and terms on the
  vendor/vendor site and fsp are valid or not at the time of copying

  IF (x_vendor_id IS NULL) THEN
      -- we get the system defaults.
      get_fsp_values(x_ship_to_location_id,
                     x_bill_to_location_id,
                     x_ship_via_lookup_code,
                     x_fob_lookup_code,
                     x_freight_terms_lu_code,
                     x_terms_id,
                     x_online_report_id,
                     x_sequence);
  ELSE
    -- User provided a vendor_id and it's valid.
    IF (x_vendor_site_id IS NULL) THEN
      -- so we get the vendor values.
      get_vendor_values(x_vendor_id,
                        x_ship_to_location_id,
                        x_bill_to_location_id,
                        x_ship_via_lookup_code,
                        x_fob_lookup_code,
                        x_freight_terms_lu_code,
                        x_terms_id,
                        x_online_report_id,
                        x_sequence);
    ELSE
      -- Use values from vendor site.
      get_vendor_site_values(x_vendor_id,
                             x_vendor_site_id,
                             x_ship_to_location_id,
                             x_bill_to_location_id,
                             x_ship_via_lookup_code,
                             x_fob_lookup_code,
                             x_freight_terms_lu_code,
                             x_terms_id,
                             x_online_report_id,
                             x_sequence);
    END IF;
  END IF;
  */

END validate_vendor;

PROCEDURE validate_location_terms(
  x_sob_id                     IN      financials_system_parameters.set_of_books_id%TYPE,
  x_ship_to_location_id        IN OUT NOCOPY  po_headers.ship_to_location_id%TYPE,
  x_bill_to_location_id        IN OUT NOCOPY  po_headers.bill_to_location_id%TYPE,
  x_fob_lookup_code            IN OUT NOCOPY  po_headers.fob_lookup_code%TYPE,
  x_freight_terms_lu_code      IN OUT NOCOPY  po_headers.freight_terms_lookup_code%TYPE,
  x_terms_id                   IN OUT NOCOPY  po_headers.terms_id%TYPE,
  x_online_report_id           IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                   IN OUT NOCOPY  po_online_report_text.sequence%TYPE
) IS

  x_progress    VARCHAR2(4) := NULL;
  x_valid_flag  VARCHAR2(2) := NULL;

BEGIN

 IF (x_ship_to_location_id IS NOT NULL) THEN
    x_progress := '004';
    BEGIN
      SELECT distinct 'Y'
      INTO   x_valid_flag
      FROM   PO_SHIP_TO_LOC_ORG_V
      WHERE  location_id = x_ship_to_location_id
      AND    (set_of_books_id IS NULL OR set_of_books_id = x_sob_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_ship_to_location_id := NULL;
	fnd_message.set_name('PO', 'PO_PO_SHIP_LOCN_INVALID');
        po_copydoc_s1.online_report(x_online_report_id,
                                    x_sequence,
                                    substr(fnd_message.get, 1, 240),
                                    0, 0, 0);
      WHEN OTHERS THEN
        x_ship_to_location_id := NULL;
        po_copydoc_s1.copydoc_sql_error('validate_location_terms', x_progress, sqlcode,
                                       x_online_report_id,
                                       x_sequence,
                                       0, 0, 0);
    END;
  END IF;

  IF (x_bill_to_location_id IS NOT NULL) THEN
    x_progress := '005';
    BEGIN
      SELECT distinct 'Y'
      INTO   x_valid_flag
      FROM   HR_BILLING_LOCATIONS_PO_V
      WHERE  location_id = x_bill_to_location_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	fnd_message.set_name('PO', 'PO_PDOI_INVALID_BILL_LOC_ID');
	fnd_message.set_token('VALUE', to_char(x_bill_to_location_id));
        x_bill_to_location_id := NULL;
        po_copydoc_s1.online_report(x_online_report_id,
                                    x_sequence,
                                    substr(fnd_message.get, 1, 240),
                                    0, 0, 0);
      WHEN OTHERS THEN
        x_bill_to_location_id := NULL;
        po_copydoc_s1.copydoc_sql_error('validate_location_terms', x_progress, sqlcode,
                                       x_online_report_id,
                                       x_sequence,
                                       0, 0, 0);
    END;
  END IF;

  IF (x_fob_lookup_code IS NOT NULL) THEN
    x_progress := '007';
    BEGIN
      SELECT distinct 'Y'
      INTO   x_valid_flag
      FROM   PO_LOOKUP_CODES
      WHERE  lookup_type = 'FOB'
      AND    SYSDATE < nvl(inactive_date, SYSDATE+1)
      AND    lookup_code = x_fob_lookup_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	fnd_message.set_name('PO', 'PO_PDOI_INVALID_FOB');
	fnd_message.set_token('VALUE', x_fob_lookup_code, FALSE);
        x_fob_lookup_code := NULL;
        po_copydoc_s1.online_report(x_online_report_id,
                                    x_sequence,
                                    substr(fnd_message.get, 1, 240),
                                    0, 0, 0);
      WHEN OTHERS THEN
        x_fob_lookup_code := NULL;
        po_copydoc_s1.copydoc_sql_error('validate_location_terms', x_progress, sqlcode,
                                       x_online_report_id,
                                       x_sequence,
                                       0, 0, 0);
    END;
  END IF;

 IF (x_freight_terms_lu_code IS NOT NULL) THEN
    x_progress := '007';
    BEGIN
      SELECT distinct 'Y'
      INTO   x_valid_flag
      FROM   PO_LOOKUP_CODES
      WHERE  lookup_type = 'FREIGHT TERMS'
      AND    SYSDATE < nvl(inactive_date, SYSDATE+1)
      AND    lookup_code = x_freight_terms_lu_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	fnd_message.set_name('PO', 'PO_PDOI_INVALID_FREIGHT_TERMS');
	fnd_message.set_token('VALUE', x_freight_terms_lu_code, FALSE);
        x_freight_terms_lu_code := NULL;
        po_copydoc_s1.online_report(x_online_report_id,
                                    x_sequence,
                                    substr(fnd_message.get, 1, 240),
                                    0, 0, 0);
      WHEN OTHERS THEN
        x_freight_terms_lu_code := NULL;
        po_copydoc_s1.copydoc_sql_error('validate_location_terms', x_progress, sqlcode,
                                       x_online_report_id,
                                       x_sequence,
                                       0, 0, 0);
    END;
  END IF;

  IF (x_terms_id IS NOT NULL) THEN
    x_progress := '008';
    BEGIN
      SELECT distinct 'Y'
      INTO   x_valid_flag
      FROM   AP_TERMS_VAL_V
      WHERE  term_id = x_terms_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	fnd_message.set_name('PO', 'PO_PDOI_INVALID_PAY_TERMS');
	fnd_message.set_token('VALUE', to_char(x_terms_id), FALSE);
        x_terms_id := NULL;
        po_copydoc_s1.online_report(x_online_report_id,
                                    x_sequence,
                                    substr(fnd_message.get, 1, 240),
                                    0, 0, 0);
      WHEN OTHERS THEN
        x_terms_id := NULL;
        po_copydoc_s1.copydoc_sql_error('validate_location_terms', x_progress, sqlcode,
                                       x_online_report_id,
                                       x_sequence,
                                       0, 0, 0);
    END;
  END IF;

END validate_location_terms;


PROCEDURE validate_item(
  x_item_id             IN OUT NOCOPY  po_lines.item_id%TYPE,
  x_item_description    IN OUT NOCOPY  po_lines.item_description%TYPE,
  x_item_revision       IN OUT NOCOPY  po_lines.item_revision%TYPE,
  x_category_id         IN OUT NOCOPY  po_lines.category_id%TYPE,
  x_line_type_id        IN      po_lines.line_type_id%TYPE,
  x_inv_org_id          IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num            IN      po_online_report_text.line_num%TYPE,
  x_return_code         OUT NOCOPY     NUMBER
) IS

  x_progress    VARCHAR2(4);
  x_valid_flag  VARCHAR2(2);
  l_validate_flag   mtl_category_sets_v.validate_flag%TYPE; --Bug# 3222657
  l_category_set_id mtl_category_sets_v.category_set_id%TYPE;  --Bug# 3222657
BEGIN

  IF (x_item_id IS NOT NULL) THEN
    x_progress := '001';
    BEGIN
      SELECT distinct 'Y'
      INTO   x_valid_flag
      FROM   MTL_SYSTEM_ITEMS
      WHERE  inventory_item_id = x_item_id
      AND    purchasing_enabled_flag = 'Y'
      AND    organization_id = x_inv_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	fnd_message.set_name('PO', 'PO_PDOI_ITEM_INVALID');
	fnd_message.set_token('ITEM', to_char(x_item_id), FALSE);
        x_item_id := NULL;
        po_copydoc_s1.online_report(x_online_report_id,
                                    x_sequence,
                                    substr(fnd_message.get, 1, 240),
                                    x_line_num, 0, 0);
        x_return_code := -1;
        RETURN;
      WHEN OTHERS THEN
        x_item_id := NULL;
        po_copydoc_s1.copydoc_sql_error('validate_item', x_progress, sqlcode,
                                        x_online_report_id,
                                        x_sequence,
                                        x_line_num, 0, 0);
        RETURN;
        x_return_code := -1;
    END;

    IF (x_item_id IS NOT NULL) THEN
      -- Make sure if line_type is outside_operation, we have an
      -- outside_operation item as well
      x_progress := '002';
      BEGIN
        SELECT distinct 'Y'
        INTO   x_valid_flag
        FROM   MTL_SYSTEM_ITEMS MSI
        WHERE  MSI.inventory_item_id = x_item_id
        AND    MSI.organization_id = x_inv_org_id
        AND    (MSI.outside_operation_flag <> 'Y'
                OR (MSI.outside_operation_flag = 'Y'
                    AND EXISTS (SELECT 'op line type'
                                FROM   PO_LINE_TYPES PLT
                                WHERE  PLT.line_type_id = x_line_type_id
                                AND    PLT.outside_operation_flag = 'Y')
                   )
               );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_item_id := NULL;
     -- Bug 3488117: Truncate at 2000 characters instead of 240.
	  fnd_message.set_name('PO', 'PO_RI_LINE_TYPE_ITEM_MISMATCH');
          po_copydoc_s1.online_report(x_online_report_id,
                                      x_sequence,
                                      substr(fnd_message.get, 1, 2000),
                                      x_line_num, 0, 0);
          x_return_code := -1;
          RETURN;
        WHEN OTHERS THEN
          x_item_id := NULL;
          po_copydoc_s1.copydoc_sql_error('validate_item', x_progress, sqlcode,
                                          x_online_report_id,
                                          x_sequence,
                                          x_line_num, 0, 0);
          x_return_code := -1;
          RETURN;
      END;

      -- We have an item_id, so the line_type cannot be 'AMOUNT'
      x_progress := '002';
      BEGIN
        SELECT distinct 'Y'
        INTO   x_valid_flag
        FROM   PO_LINE_TYPES
        WHERE  line_type_id = x_line_type_id
        AND    order_type_lookup_code <> 'AMOUNT';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_item_id := NULL;
	  fnd_message.set_name('PO', 'PO_PDOI_MISMATCH_ITEM_ITEMTYPE');
          po_copydoc_s1.online_report(x_online_report_id,
                                      x_sequence,
                                      substr(fnd_message.get, 1, 240),
                                      x_line_num, 0, 0);
          x_return_code := -1;
          RETURN;
        WHEN OTHERS THEN
          x_item_id := NULL;
          po_copydoc_s1.copydoc_sql_error('validate_item', x_progress, sqlcode,
                                          x_online_report_id,
                                          x_sequence,
                                          x_line_num, 0, 0);
          x_return_code := -1;
          RETURN;
      END;

      IF (x_item_revision IS NOT NULL) THEN
        x_progress := '003';
        BEGIN
          SELECT distinct 'Y'
          INTO   x_valid_flag
          FROM   MTL_ITEM_REVISIONS_ORG_VAL_V
          WHERE  revision = x_item_revision
          AND    inventory_item_id = x_item_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
	    fnd_message.set_name('PO', 'PO_RI_INVALID_ITEM_REVISION');
	    fnd_message.set_token('VALUE', x_item_revision);
            x_item_revision := NULL;
            po_copydoc_s1.online_report(x_online_report_id,
                                        x_sequence,
                                        substr(fnd_message.get, 1, 240),
                                        x_line_num, 0, 0);
          WHEN OTHERS THEN
            x_item_revision := NULL;
            po_copydoc_s1.copydoc_sql_error('validate_item', x_progress, sqlcode,
                                            x_online_report_id,
                                            x_sequence,
                                            x_line_num, 0, 0);
        END;
      END IF;

      IF (x_category_id IS NULL) THEN
        x_progress := '004';
        BEGIN
          SELECT MIC.category_id
          INTO   x_category_id
          FROM   MTL_ITEM_CATEGORIES MIC,
                 MTL_DEFAULT_SETS_VIEW MDSV
          WHERE  MIC.inventory_item_id = x_item_id
          AND    MIC.organization_id = x_inv_org_id
          AND    MIC.category_set_id = MDSV.category_set_id
          AND    MDSV.functional_area_id = 2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
	    fnd_message.set_name('PO', 'PO_PO_MISSING_CATEGORY');
	    fnd_message.set_token('ITEM', to_char(x_item_id), FALSE);
            x_category_id := NULL;
            po_copydoc_s1.online_report(x_online_report_id,
                                        x_sequence,
                                        substr(fnd_message.get, 1, 240),
                                        x_line_num, 0, 0);
            x_return_code := -1;
            RETURN;
          WHEN OTHERS THEN
            x_category_id := NULL;
            po_copydoc_s1.copydoc_sql_error('validate_item', x_progress, sqlcode,
                                            x_online_report_id,
                                            x_sequence,
                                            x_line_num, 0, 0);
            x_return_code := -1;
            RETURN;
        END;

/* Bug #: 2179656
** Desc: Removed the check for validating that the PO line item belongs
** to the item category specified on the PO line. This was not allowing the
** users to reapprove the copied PO when the item category was changed but
** a non-copied PO could be approved even when the item category was changed
** for an item on the existing PO line. Keeping in sync the logic as per
** product management.

       ELSE
        x_progress := '005';
        BEGIN
          SELECT distinct 'Y'
          INTO   x_valid_flag
          FROM   MTL_ITEM_CATEGORIES MIC,
                 MTL_DEFAULT_SETS_VIEW MDSV
          WHERE  MIC.category_id = x_category_id
          AND    MIC.inventory_item_id = x_item_id
          AND    MIC.organization_id = x_inv_org_id
          AND    MIC.category_set_id = MDSV.category_set_id
          AND    MDSV.functional_area_id = 2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_category_id := NULL;
     -- Bug 3488117: Truncate at 2000 characters instead of 240.
	    fnd_message.set_name('PO', 'PO_RI_INVALID_CATEGORY_ID');
            po_copydoc_s1.online_report(x_online_report_id,
                                        x_sequence,
                                        substr(fnd_message.get, 1, 2000),
                                        x_line_num, 0, 0);
            x_return_code := -1;
            RETURN;
          WHEN OTHERS THEN
            x_category_id := NULL;
            po_copydoc_s1.copydoc_sql_error('validate_item', x_progress, sqlcode,
                                            x_online_report_id,
                                            x_sequence,
                                            x_line_num, 0, 0);
            x_return_code := -1;
            RETURN;
        END;
** End of Fix: Bug# 2179656 */

      END IF;
    END IF;
  ELSE
    x_item_revision := NULL;
    IF (x_category_id IS NULL) THEN
      fnd_message.set_name('PO', 'PO_RI_CAT_ID_ITEM_DESC_MISSING');
      po_copydoc_s1.online_report(x_online_report_id,
                                  x_sequence,
                                  substr(fnd_message.get, 1, 240),
                                  x_line_num, 0, 0);
      x_return_code := -1;
      RETURN;
    ELSE
      x_progress := '006';
      BEGIN

      -- Start Bug # 3222657
/*
   Bug# 3222657,  Commented out the following piece of code and fixed the Issue by
   validating on MTL_CATEGORY_SET_VALID_CATS only when the 'Enforce list of valid
   Categories' (validate_flag) is set to 'Y' for the Category Set.

	SELECT distinct 'Y'
        INTO   x_valid_flag
        FROM   MTL_CATEGORY_SET_VALID_CATS MCSVC,
               MTL_DEFAULT_SETS_VIEW MDSV
        WHERE  MCSVC.category_id = x_category_id
        AND    MCSVC.category_set_id = MDSV.category_set_id
        AND    MDSV.functional_area_id = 2;
*/
         Begin
            select validate_flag,
                   category_set_id
            INTO l_validate_flag,
                 l_category_set_id
            FROM MTL_DEFAULT_SETS_VIEW MDSV
            where MDSV.functional_area_id = 2;
          Exception
             when others then
                NULL;
          End;

          IF  l_validate_flag = 'Y' then

             SELECT distinct 'Y'
             INTO   x_valid_flag
             FROM   MTL_CATEGORY_SET_VALID_CATS MCSVC,
                    MTL_CATEGORIES_VL MCV
             WHERE  MCSVC.category_id = x_category_id
             AND    MCSVC.category_set_id = l_category_set_id
             AND    MCV.category_id = MCSVC.category_id
             AND    sysdate < nvl(mcv.disable_date, sysdate+1)
             AND    mcv.enabled_flag = 'Y';

          ELSE

             SELECT distinct 'Y'
             INTO   x_valid_flag
             FROM   MTL_CATEGORIES_VL MCV
             WHERE  MCV.category_id = x_category_id
             AND    sysdate < nvl(mcv.disable_date, sysdate+1)
             AND    mcv.enabled_flag = 'Y';

          END IF;
      -- End Bug # 3222657

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_category_id := NULL;
	  fnd_message.set_name('PO', 'PO_RI_INVALID_CATEGORY_ID');
          po_copydoc_s1.online_report(x_online_report_id,
                                      x_sequence,
                                      substr(fnd_message.get, 1, 240),
                                      x_line_num, 0, 0);
          x_return_code := -1;
          RETURN;
        WHEN OTHERS THEN
          x_category_id := NULL;
          po_copydoc_s1.copydoc_sql_error('validate_item', x_progress, sqlcode,
                                          x_online_report_id,
                                          x_sequence,
                                          x_line_num, 0, 0);
          x_return_code := -1;
          RETURN;
      END;
    END IF;
    IF (x_item_description IS NULL) THEN
      fnd_message.set_name('PO', 'PO_RI_CAT_ID_ITEM_DESC_MISSING');
      po_copydoc_s1.online_report(x_online_report_id,
                                  x_sequence,
                                  substr(fnd_message.get, 1, 240),
                                  x_line_num, 0, 0);
      x_return_code := -1;
      RETURN;
    END IF;
  END IF;

  x_return_code := 0;

EXCEPTION
  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('validate_item', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, 0, 0);
    x_return_code := -1;

END validate_item;

--Bug 16856753
--This procedure, called during copy doc, does validations on
--security rules too apart from normal validations.
PROCEDURE validate_account_id(
  x_account_id               IN OUT NOCOPY  NUMBER,
  x_account_type	     IN      VARCHAR2,
  x_gl_date                  IN      DATE,
  x_sob_id                   IN      financials_system_parameters.set_of_books_id%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
  x_valid_flag  VARCHAR2(2) := 'Y';
  x_progress    VARCHAR2(4) := NULL;
  l_coa gl_sets_of_books.chart_of_accounts_id%TYPE;

BEGIN

 x_progress := '001';

  -- Need to pass structure id to validate_account_wrapper.
  begin
  SELECT sob.chart_of_accounts_id
  INTO   l_coa
  FROM   gl_sets_of_books sob
  WHERE
  sob.set_of_books_id = x_sob_id;
  exception
  when others then
  x_valid_flag := 'N';
  end;

  IF (x_valid_flag = 'Y') THEN
    x_valid_flag := PO_DOCUMENT_CHECKS_PVT.validate_account_wrapper(p_structure_number => l_coa,
                                                  p_combination_id  => x_account_id,
                                                  p_val_date => nvl(x_gl_date, sysdate)
  						);
  END IF;

  IF (x_valid_flag = 'N') THEN
    x_account_id := NULL;
    IF x_account_type = 'BUDGET' THEN
	fnd_message.set_name('PO', 'PO_RI_INVALID_BUDGET_ACC_ID');
    ELSIF x_account_type = 'ACCRUAL' THEN
	fnd_message.set_name('PO', 'PO_RI_INVALID_ACCRUAL_ACC_ID');
    ELSIF x_account_type = 'CHARGE' THEN
	fnd_message.set_name('PO', 'PO_RI_INVALID_CHARGE_ACC_ID');
    ELSIF x_account_type = 'VARIANCE' THEN
	fnd_message.set_name('PO', 'PO_RI_INVALID_VARIANCE_ACC_ID');
    END IF;

    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 240),
                                x_line_num, x_shipment_num, x_distribution_num);
    END IF;

  Exception

  WHEN OTHERS THEN
    x_account_id := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_account_id', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);
--   RAISE COPYDOC_DIST_FAILURE;

END validate_account_id;

/* assume Oracle Project is installed */

/**
* Private Procedure: validate_project_id
* Requires: Destination type is EXPENSE.
* Modifies: PO_ONLINE_REPORT_TEXT
* Effects: Validates that the given project_id exists as a
*  chargeable PA project. If not, writes an error message to
*  PO_ONLINE_REPORT_TEXT.
* Returns: none
*/
PROCEDURE validate_project_id(
  x_project_id               IN OUT NOCOPY po_distributions.project_id%TYPE,
-- <PO_PJM_VALIDATION FPI>
-- Removed the x_destination_type_code and x_ship_to_organization_id arguments.
-- Added NOCOPY to x_project_id and x_sequence.
--  x_destination_type_code    IN      po_distributions.destination_type_code%TYPE,
--  x_ship_to_organization_id  IN      NUMBER,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

  IF (x_project_id IS NULL) THEN
    RETURN;
  END IF;

  -- validation

-- <PO_PJM_VALIDATION FPI>
-- Removed the IF statement and the ELSE clause, since now this procedure
-- will only be called if the destination type is EXPENSE.

--  IF x_destination_type_code = 'EXPENSE' THEN
     x_progress := '001';
     SELECT distinct 'Y'
     INTO   x_valid_flag
     FROM   pa_projects_expend_v
     WHERE  project_id=x_project_id;

-- <PO_PJM_VALIDATION FPI START>
/**
 ELSE
    x_progress := '002';
    SELECT distinct 'Y'
    INTO   x_valid_flag
    FROM   mtl_project_v m,
           pjm_project_parameters p
    WHERE  p.organization_id = x_ship_to_organization_id
    AND    m.project_id = p.project_id
    AND    m.project_id = x_project_id;
 END IF;
**/
-- <PO_PJM_VALIDATION FPI END>

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_project_id   := NULL;
     -- Bug 3488117: Truncate at 2000 characters instead of 240.
    fnd_message.set_name('PO', 'PO_RI_INVALID_PA_INFO');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 2000),
                                x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_project_id  :=NULL;
    po_copydoc_s1.copydoc_sql_error('validate_project_id', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);

--    RAISE COPYDOC_DIST_FAILURE;

END validate_project_id;

PROCEDURE validate_task_id(
  x_task_id                  IN OUT NOCOPY  NUMBER,
  x_project_id               IN      NUMBER,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

  IF ( x_task_id IS NULL) THEN
    RETURN;
  END IF;

  x_progress := '001';

  -- validation
  select distinct 'Y'
  into   x_valid_flag
  from   pa_tasks_expend_v
  where  project_id = x_project_id
  and    task_id = x_task_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_task_id := NULL;
     -- Bug 3488177: Truncate at 2000 characters instead of 240.
    fnd_message.set_name('PO', 'PO_RI_INVALID_PA_INFO');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 2000),
                                x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_task_id :=NULL;
    po_copydoc_s1.copydoc_sql_error('validate_task_id', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);
--    RAISE COPYDOC_DIST_FAILURE;

END validate_task_id;

-- Start Bug 3488117: Add code to validate expenditure fields.

PROCEDURE validate_exp_item_date(
  x_project_id               IN NUMBER,
  x_task_id                  IN NUMBER,
  x_exp_item_date            IN OUT NOCOPY DATE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
    x_valid_flag  VARCHAR2(2) := 'N';
    x_progress    VARCHAR2(4) := NULL;
BEGIN
   IF (x_exp_item_date is null) then
      RETURN;
   END IF;

   x_progress := '001';
   select distinct 'Y'
          into  x_valid_flag
          from pa_projects_all prj,
               pa_tasks tsk
          where
               prj.project_id = x_project_id
           and prj.project_id = tsk.project_id
           and tsk.task_id    = x_task_id
           and x_exp_item_date between
               nvl(prj.start_date,x_exp_item_date)
           and nvl(prj.completion_date,x_exp_item_date)
           and x_exp_item_date between
               nvl(tsk.start_date,x_exp_item_date)
           and nvl(tsk.completion_date,x_exp_item_date);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_exp_item_date := NULL;
    fnd_message.set_name('PO', 'PO_RI_INVALID_PA_INFO');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 2000),
                                x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_exp_item_date := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_exp_item_date', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);
 END  validate_exp_item_date;

PROCEDURE validate_exp_type(
  x_project_id               IN NUMBER,
  x_exp_type                 IN OUT NOCOPY  po_distributions.expenditure_type%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
    x_valid_flag  VARCHAR2(2) := 'N';
    x_progress    VARCHAR2(4) := NULL;
BEGIN
   IF (x_exp_type is null) then
      RETURN;
   END IF;

   x_progress := '001';
   SELECT
      'Y' into x_valid_flag
       FROM
            pa_expenditure_types_expend_v et
       WHERE
           system_linkage_function = 'VI' and
	  (et.project_id = x_project_id or et.project_id is null)  and
	  trunc(sysdate) between nvl(et.expnd_typ_start_date_active, trunc(sysdate)) and
	  nvl(et.expnd_typ_end_date_Active, trunc(sysdate))
	  and et.expenditure_type = x_exp_type;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_exp_type := NULL;
    fnd_message.set_name('PO', 'PO_RI_INVALID_PA_INFO');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 2000),
                                x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_exp_type := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_exp_type', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);
 END  validate_exp_type;

PROCEDURE validate_exp_org(
  x_org_id                   IN OUT NOCOPY NUMBER,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
    x_valid_flag  VARCHAR2(2) := 'N';
    x_progress    VARCHAR2(4) := NULL;
BEGIN
   IF (x_org_id is null) then
      RETURN;
   END IF;

   x_progress := '001';
   select 'Y'
           into x_valid_flag
   from  pa_organizations_expend_v pao
   where pao.active_flag = 'Y'
   and   pao.organization_id = x_org_id ;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_org_id := NULL;
    fnd_message.set_name('PO', 'PO_RI_INVALID_PA_INFO');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 2000),
                                x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_org_id := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_exp_org', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);
 END  validate_exp_org;

-- End Bug 3488117

-- Start bug 14296213: project end date validation for copied po
PROCEDURE validate_proj_end_date(
  x_project_id               IN NUMBER,
  x_task_id                  IN NUMBER,
--  x_exp_item_date            IN OUT NOCOPY DATE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
    x_valid_flag  VARCHAR2(2) := 'N';
    x_progress    VARCHAR2(4) := NULL;
BEGIN

   x_progress := '001';
      select distinct 'Y'
          into  x_valid_flag
          from pa_projects_all prj
          where prj.project_id = x_project_id
           and nvl(prj.completion_date,sysdate) >= sysdate;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('PO', 'PO_PA_PROJ_EXPIRED');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 2000),
                                x_line_num, x_shipment_num, x_distribution_num);


  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('validate_proj_end_date', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);

 END  validate_proj_end_date;

PROCEDURE validate_task_end_date(
  x_project_id               IN NUMBER,
  x_task_id                  IN NUMBER,
 -- x_exp_item_date            IN OUT NOCOPY DATE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
    x_valid_flag  VARCHAR2(2) := 'N';
    x_progress    VARCHAR2(4) := NULL;
BEGIN

   x_progress := '001';

  IF ( x_task_id IS NULL) THEN
    RETURN;
  END IF;

   select distinct 'Y'
          into  x_valid_flag
          from pa_projects_all prj,
               pa_tasks tsk
          where prj.project_id = x_project_id
           and prj.project_id = tsk.project_id
           and tsk.task_id    = x_task_id
           and nvl(tsk.completion_date,sysdate) >= sysdate;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('PO', 'PO_PA_TASK_EXPIRED');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 2000),
                                x_line_num, x_shipment_num, x_distribution_num);


  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('validate_task_end_date', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);

 END  validate_task_end_date;
-- End bug 14296213

PROCEDURE validate_destination_type_code(
  x_destination_type_code    IN OUT NOCOPY  po_distributions.destination_type_code%TYPE,
  x_item_id                  IN      po_lines.item_id%TYPE,
  x_ship_org_id              IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_accrue_on_receipt_flag   IN      varchar2,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE,
  x_line_location_id         IN      po_line_locations.line_location_id%TYPE, -- CONSIGNED FPI START
  x_po_line_id               IN      po_lines.po_line_id%TYPE, -- Bug 3557910
  p_transaction_flow_header_id IN    NUMBER     --< Bug 3546252 >
) IS

  x_valid_flag           VARCHAR2(2);
 /* x_expense_accrual_code po_system_parameters.expense_accrual_code%TYPE;Bug7351781*/
  x_item_status          VARCHAR2(1);
  x_progress             VARCHAR(4) := NULL;
  -- CONSIGNED FPI
  x_consigned_flag       po_line_locations.consigned_flag%TYPE := NULL;
  -- Bug 3557910 Start
  x_eam_install_status  VARCHAR2(10);
  x_eam_profile         VARCHAR2(10);
  x_osp_line_flag       VARCHAR2(10);
  -- END BUG 3557910

BEGIN

  x_progress := '001';

  /*SELECT expense_accrual_code
  INTO   x_expense_accrual_code
  FROM   po_system_parameters; Bug7351781 */

  -- CONSIGNED FPI START
  -- Bug Fix for #2713973: COPY PO WITH CONSIGNED SHIPMENT LINE FAILS
  SELECT consigned_flag
  INTO   x_consigned_flag
  FROM   po_line_locations
  WHERE  line_location_id = x_line_location_id;
  -- CONSIGNED FPI END

  po_items_sv2.get_item_status(x_item_id, x_ship_org_id, x_item_status);

  -- Business Rules
  -- item status
  -- 'O'  =  outside processing item
  --         - destination type must be SHOP FLOOR
  -- 'E'  =  item stockable in the org
  --         - destination type cannot be SHOP FLOOR
  -- 'D'  =  item defined but not stockable in org
  --         - destination type must be EXPENSE
  -- null =  item not defined in org
  --
  -- accrual on receipt
  -- 'N'     - destination type must be expense
  --         OR
  --         - the shipment is consigned
  --
  -- 'Y'     - if expense_accrual = PERIOD END
  --           then destination type code cannot be EXPENSE
  --         OR
  --         - there is a transaction flow defined  < Bug 3546252 >
  --
  -- Bug 3557910 Start
  -- If it is an eAM destination do that validations.

  x_progress := '0151';

   BEGIN

        SELECT NVL(PLT.OUTSIDE_OPERATION_FLAG,'N')
        INTO   x_osp_line_flag
        FROM   PO_LINE_TYPES PLT, PO_LINES POL
        WHERE  PLT.LINE_TYPE_ID = POL.LINE_TYPE_ID
        AND    POL.PO_LINE_ID = x_po_line_id;

   EXCEPTION
        WHEN NO_DATA_FOUND THEN
           x_osp_line_flag := NULL;
   END;

   x_progress := '0152';

   PO_SETUP_S1.GET_EAM_STARTUP(x_eam_install_status,x_eam_profile);
   /*Bug7351781 - matched the accrue on receipt flag with the corresponding destination type code*/

   x_progress := '0153';

  IF nvl(x_eam_install_status,'N') ='I' and
       nvl(x_eam_profile,'N')='Y'and
       nvl(x_osp_line_flag,'N') ='N' then

       --< Bug 3546252 > When a transaction flow exists, no need to check the
       -- accrue_on_receipt_flag.
       select distinct 'Y' valid
       into   x_valid_flag
       from   po_lookup_codes
       where  lookup_type = 'DESTINATION TYPE'
       and ( ( nvl(x_item_status,'D') = 'D'
               and lookup_code <> 'INVENTORY' )
          or ( nvl(x_item_status,'D') = 'E'
               and lookup_code <> 'SHOP FLOOR')
          or ( nvl(x_item_status,'D') = 'O'
               and lookup_code = 'SHOP FLOOR') )
       and ( ( nvl(x_consigned_flag,'N') = 'Y' and lookup_code = 'INVENTORY' )
           OR( p_transaction_flow_header_id IS NOT NULL )   --< Bug 3546252 >
           or( nvl(x_consigned_flag,'N') = 'N'
               and ( (nvl(x_accrue_on_receipt_flag,'Y') = 'N'
                      and lookup_code ='EXPENSE')
                  or ( nvl(x_accrue_on_receipt_flag,'Y') = 'Y'
                       and lookup_code IN ('EXPENSE','INVENTORY','SHOP FLOOR') ) ) ) ) --bug7351781
       and  lookup_code= x_destination_type_code;

   ELSE
  -- END BUG 3557910

  x_progress := '002';

  -- CONSIGNED FPI
  -- Bug Fix for #2713973: COPY PO WITH CONSIGNED SHIPMENT LINE FAILS
  -- Added the condition for accrue_on_receipt_flag to be 'N' if
  -- consigned_flag is 'Y'
  --< Bug 3546252 > When a transaction flow exists, no need to check the
  -- accrue_on_receipt_flag.
  select distinct 'Y' valid
  into   x_valid_flag
  from   po_lookup_codes
  where  lookup_type = 'DESTINATION TYPE'
  and ( ( nvl( x_item_status,'D') = 'D'
          and lookup_code = 'EXPENSE')
     or ( nvl( x_item_status,'D') = 'E'
          and lookup_code <> 'SHOP FLOOR')
     or ( nvl( x_item_status,'D') = 'O'
          and lookup_code = 'SHOP FLOOR') )  --bug 8538334 typo correction
  and ( ( nvl( x_accrue_on_receipt_flag,'Y') = 'N'
          and ( lookup_code = 'EXPENSE' or
                x_consigned_flag = 'Y') )
      OR (p_transaction_flow_header_id IS NOT NULL)   --< Bug 3546252 >
      OR  (nvl(x_accrue_on_receipt_flag,'Y') = 'N'
                      and lookup_code ='EXPENSE')
      OR ( nvl(x_accrue_on_receipt_flag,'Y') = 'Y'
                       and lookup_code IN ('EXPENSE','INVENTORY','SHOP FLOOR'))) --bug7351781
  and    lookup_code= x_destination_type_code;

END IF; --Bug 3557910
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_destination_type_code := NULL;
    fnd_message.set_name('PO', 'PO_RI_INVALID_DEST_TYPE_CODE');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 240),
                                x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_destination_type_code := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_destination_type_code', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);

END validate_destination_type_code;

/* deliver_to_person = Requestor */
PROCEDURE validate_deliver_to_person_id(
  x_deliver_to_person_id     IN OUT NOCOPY  po_distributions.deliver_to_person_id%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

  -- deliver_to_person is optional
  IF (x_deliver_to_person_id IS NULL) THEN
    RETURN;
  END IF;

  x_progress := '001';

  -- validation
  --R12 CWK removed inactive date where clause
 --8733572 bug,
 --IF(nvl(hr_general.get_xbg_profile,'N') = 'Y') then

 --Bug 13542908 Using per_workforce_current_x instead of per_employees_current_x
 SELECT distinct 'Y'
 INTO   x_valid_flag
 FROM per_workforce_current_x per, per_business_groups_perf pb
 WHERE per.business_group_id = pb.business_group_id
 AND per.person_id = x_deliver_to_person_id;

/*
 ELSE
  SELECT distinct 'Y'
  INTO   x_valid_flag
  FROM   hr_employees_current_v
  WHERE  employee_id = x_deliver_to_person_id;
END IF;
*/
--8733572 bug (if clause)

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_deliver_to_person_id := NULL;
    fnd_message.set_name('PO', 'PO_PO_INVALID_DEL_TO_PERSON');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 240),
                                x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_deliver_to_person_id := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_deliver_to_person_id', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);
--    RAISE COPYDOC_DIST_FAILURE;

END validate_deliver_to_person_id;


PROCEDURE validate_osp_data
(x_wip_entity_id               IN NUMBER,
 x_wip_operation_seq_num       IN NUMBER,
 x_wip_resource_seq_num        IN NUMBER,
 x_wip_repetitive_schedule_id  IN NUMBER,
 x_wip_line_id                 IN NUMBER,
 x_destination_organization_id IN NUMBER,
 x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
 x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
 x_line_num                 IN      po_online_report_text.line_num%TYPE,
 x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
 x_distribution_num         IN      po_online_report_text.distribution_num%TYPE)
 IS
 x_count   number;
 x_progress VARCHAR2(4) := '10';
 --Bug# 2090549 togeorge 11/05/2001
 --Modifed this procedure for adding eAM specific validations. And also
 --included the if conditions to check whether each value being validated
 --is not null, otherwise they would display error message even for a regular
 --PO (a non osp or the destination type is not 'SHOP FLOOR')
 x_entity_type   number;
BEGIN

	-- is this a valid wip job
	x_count :=null;
	IF x_wip_entity_id is NOT NULL and x_wip_line_id IS NULL THEN
	   begin
	   select entity_type
	     into x_entity_type
	     from wip_entities
            where wip_entity_id=x_wip_entity_id;
           exception
	    when others then
	    null;
	   end;
           if x_entity_type =6 then  --6 stands for eAM work orders
	      select count(*)
	        into x_count
	        from wip_entities we,
	             wip_discrete_jobs wdj
	       where we.wip_entity_id = wdj.wip_entity_id
	         and we.entity_type = 6
	         and wdj.status_type in (3,4,6);
	   else
	      select count(*) into x_count
	        from wip_osp_jobs_val_v job, pa_tasks task
	       where job.wip_entity_id = x_wip_entity_id
	         and job.organization_id = x_destination_organization_id
	         and task.task_id (+) = job.task_id;
           end if;
	   if (x_count < 1) then
		-- register error
	       	fnd_message.set_name('PO', 'PO_PO_INVALID_JOB');
       		po_copydoc_s1.online_report(x_online_report_id,
                                   	    x_sequence,
                                   	    substr(fnd_message.get, 1, 240),
                                   	    x_line_num, x_shipment_num,
					    x_distribution_num);
	   end if;
	end if;

	x_count :=null;
	IF x_wip_line_id is NOT NULL THEN
           x_progress := '15';
	   select count(*)
	     into x_count
	     from wip_osp_lines_val_v
	    where line_id = x_wip_line_id
	      and organization_id = x_destination_organization_id;
	   if (x_count < 1) then
		-- register error
	       	fnd_message.set_name('PO', 'PO_PO_INVALID_JOB_LINE');
       		po_copydoc_s1.online_report(x_online_report_id,
                                   	    x_sequence,
                                   	    substr(fnd_message.get, 1, 240),
                                   	    x_line_num, x_shipment_num,
					    x_distribution_num);
	   end if;
        END IF;

	x_count :=null;
	x_progress := '20';
	-- is this a valid operation sequence
        -- Bug 3557910. The eAM operation may not be
        -- a standard operation. Hence we need to outer join BSO.
        if x_wip_operation_seq_num is not null then
         if x_entity_type =6 then  --6 stands for eAM work orders
	   select count(*)
	     INTO x_count
	     from WIP_OPERATIONS WO,
	          BOM_STANDARD_OPERATIONS  BSO
	    WHERE WO.WIP_ENTITY_ID=x_wip_entity_id
	      AND operation_seq_num=x_wip_operation_seq_num
	      AND WO.STANDARD_OPERATION_ID = BSO.STANDARD_OPERATION_ID (+)    --Bug 3557910 Added Outer JOIN
	      AND nvl(BSO.OPERATION_TYPE,1) =1
	      AND BSO.line_id is null;

	 else
	   select count(*) into x_count
	     from wip_osp_operations_val_v
	    where operation_seq_num = x_wip_operation_seq_num
	      and organization_id = x_destination_organization_id
	      and ((wip_entity_id = x_wip_entity_id) and x_wip_line_id is null);

	   if (x_count < 1) then
		x_progress := '25';
		select count(*) into x_count
		from wip_osp_operations_val_v
		where operation_seq_num = x_wip_operation_seq_num
		and organization_id = x_destination_organization_id
		and repetitive_schedule_id = x_wip_repetitive_schedule_id;
	   end if;
         end if; /* x_entity_type =6 */
	 if (x_count < 1) then
		-- register error
	       	fnd_message.set_name('PO', 'PO_PO_INVALID_OPERATION_SEQ');
       		po_copydoc_s1.online_report(x_online_report_id,
                                   	    x_sequence,
                                   	    substr(fnd_message.get, 1, 240),
                                   	    x_line_num, x_shipment_num,
					    x_distribution_num);
	 end if;
	end if; /*x_wip_operation_seq_num is not null */

	x_progress := '30';
	-- is this a valid resource sequence
	x_count :=null;
        if x_wip_resource_seq_num is not null and x_entity_type <>6 then

	   select count(*) into x_count
	     from wip_osp_resources_val_v
	    where resource_seq_num = x_wip_resource_seq_num
	      and organization_id = x_destination_organization_id
	      and ((wip_entity_id = x_wip_entity_id and x_wip_line_id is null)
	       or repetitive_schedule_id = x_wip_repetitive_schedule_id)
	      and operation_seq_num = x_wip_operation_seq_num;

	   if (x_count < 1) then
		-- register error
	       	fnd_message.set_name('PO', 'PO_PO_INVALID_RESOURCE_SEQ');
       		po_copydoc_s1.online_report(x_online_report_id,
                                   	    x_sequence,
                                   	    substr(fnd_message.get, 1, 240),
                                   	    x_line_num, x_shipment_num,
					    x_distribution_num);
	   end if;
	end if;

EXCEPTION
  WHEN OTHERS THEN
   po_copydoc_s1.copydoc_sql_error('PO_COPYDOC_SUB.validate_osp_data',
				    x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num,
				    x_shipment_num,
				    x_distribution_num);
END;

/* Deliver To Location */
PROCEDURE validate_deliver_to_loc_id(
  x_deliver_to_location_id   IN OUT NOCOPY  po_distributions.deliver_to_location_id%TYPE,
  x_ship_to_organization_id  IN      NUMBER,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

  -- deliver_to_location is optional
  IF (x_deliver_to_location_id IS NULL) THEN
    RETURN;
  END IF;

  x_progress := '001';

  -- validation
  -- bug 1942696 hr_location changes to reflect the new view
  begin
   SELECT distinct 'Y'
   INTO   x_valid_flag
   FROM   HR_LOCATIONS_ALL
   WHERE  nvl(inventory_organization_id,x_ship_to_organization_id) = x_ship_to_organization_id
   AND    nvl(inactive_date, trunc(sysdate + 1)) > trunc(sysdate)
   AND    location_id = x_deliver_to_location_id;

  exception
      when no_data_found then
       SELECT distinct 'Y'
       INTO   x_valid_flag
       FROM   HZ_LOCATIONS
       WHERE  nvl(address_expiration_date, trunc(sysdate + 1)) > trunc(sysdate)
       AND    location_id = x_deliver_to_location_id;
  end;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       x_deliver_to_location_id := NULL;
       fnd_message.set_name('PO', 'PO_RI_INVALID_DEL_LOC_ID_DEST');
       -- Bug 3488117: Changed trunc size from 240 to 2000.
       po_copydoc_s1.online_report(x_online_report_id,
                                   x_sequence,
                                   substr(fnd_message.get, 1, 2000),
                                   x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_deliver_to_location_id := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_deliver_to_loc_id', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, x_shipment_num, x_distribution_num);
--    RAISE COPYDOC_DIST_FAILURE;

END validate_deliver_to_loc_id;

PROCEDURE validate_dest_subinventory(
  x_destination_subinventory IN OUT NOCOPY  po_distributions.destination_subinventory%TYPE,
  x_ship_to_organization_id  IN      NUMBER,
  x_item_id                  IN      po_lines.item_id%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_shipment_num             IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num         IN      po_online_report_text.distribution_num%TYPE
)IS
  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

BEGIN

  IF ( x_destination_subinventory IS NULL) THEN
    RETURN;
  END IF;

  x_progress := '001';

  -- validation
  select  distinct 'Y'
  into    x_valid_flag
  from    mtl_secondary_inventories msub
  where   msub.organization_id = nvl(x_ship_to_organization_id, msub.organization_id)
  and     nvl(msub.disable_date, trunc(sysdate+1)) > trunc(sysdate)
  and     (x_item_id is null
           or
          (x_item_id is not null
           and exists (select null
                       from   mtl_system_items msi
                       where  msi.organization_id = nvl(x_ship_to_organization_id, msi.organization_id)
                       and msi.inventory_item_id = x_item_id
                       and (msi.restrict_subinventories_code = 2
                       or (msi.restrict_subinventories_code = 1
                           and exists (select null
                                       from mtl_item_sub_inventories mis
                                       where mis.organization_id = nvl(x_ship_to_organization_id , mis.organization_id)
                                       and mis.inventory_item_id = msi.inventory_item_id
                                       and mis.secondary_inventory = msub.secondary_inventory_name))))))
  and msub.secondary_inventory_name =  x_destination_subinventory;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_destination_subinventory := NULL;
    fnd_message.set_name('PO', 'PO_RI_INVALID_DEST_SUBINV');
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 240),
                                x_line_num, x_shipment_num, x_distribution_num);

  WHEN OTHERS THEN
    x_destination_subinventory :=NULL;
    po_copydoc_s1.copydoc_sql_error('validate_dest_subinventory', x_progress, sqlcode,
                                   x_online_report_id,
                                   x_sequence,
                                   x_line_num, x_shipment_num, x_distribution_num);

--    RAISE COPYDOC_DIST_FAILURE;

END validate_dest_subinventory;


PROCEDURE validate_contract_num(
  p_contract_id      IN PO_LINES_ALL.contract_id%TYPE,   -- <GC FPJ>
  x_online_report_id IN po_online_report_text.online_report_id%TYPE,
  x_sequence         IN OUT NOCOPY po_online_report_text.sequence%TYPE,
  x_line_num         IN po_online_report_text.line_num%TYPE
) IS
  x_valid_flag  VARCHAR2(2);
  x_progress    VARCHAR2(4) := NULL;

  l_contract_doc_num PO_HEADERS_ALL.segment1%TYPE;  -- <GC FPJ>

BEGIN

  IF (p_contract_id IS NULL) THEN    -- <GC FPJ>
     RETURN;
  END IF;

  x_progress := '001';

  -- <GC FPJ START>
  -- Check frozen flag as we should not create a new po line referencing
  -- a frozen contract. Also, remove the check for enabled_flag as it is
  -- not used by PO. Moreover, effective date and approved flag check
  -- are removed since they are checked in regular submission check.
  -- The original query has been removed for clarity

  -- SQL What: Given a contract, make sure that the contract is still valid
  -- SQL Why:  This is part of the copy doc submission check

  SELECT 'Y'
  INTO   x_valid_flag
  FROM   po_headers_all POH
  WHERE  POH.po_header_id = p_contract_id
  AND    POH.type_lookup_code = 'CONTRACT'
  AND    POH.authorization_status = 'APPROVED'
  AND    NVL(POH.closed_code, 'OPEN') = 'OPEN'
  AND    NVL(POH.cancel_flag, 'N') <> 'Y'
  AND    NVL(POH.frozen_flag, 'N') <> 'Y';

  -- <GC FPJ END>

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- <GC FPJ>
    -- When the error is displayed, we should should contract number
    l_contract_doc_num := PO_HEADERS_SV4.get_doc_num
                          ( p_po_header_id => p_contract_id
                          );

    fnd_message.set_name('PO', 'PO_PO_INVALID_CONTRACT');
    fnd_message.set_token('VALUE', l_contract_doc_num, FALSE); -- <GC FPJ>

    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                substr(fnd_message.get, 1, 240),
                                x_line_num, 0, 0);
  WHEN OTHERS THEN

    po_copydoc_s1.copydoc_sql_error('validate_contract_num', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, 0, 0);

END validate_contract_num;

--<Bug 2864544 mbhargav START>
--Private procedure that validate that the referenced global agreement is not cancelled or
--finally closed
PROCEDURE validate_global_ref(
  p_from_header_id     IN po_headers_all.po_header_id%TYPE,
  p_from_line_id       IN po_lines_all.po_line_id%TYPE,
  p_online_report_id   IN po_online_report_text.online_report_id%TYPE,
  p_sequence           IN OUT NOCOPY po_online_report_text.sequence%TYPE,
  p_line_num           IN po_online_report_text.line_num%TYPE
) IS
  l_valid_flag  VARCHAR2(2);
  l_progress    VARCHAR2(4) := NULL;

BEGIN

  IF (p_from_header_id is NULL or p_from_line_id IS NULL) THEN
     RETURN;
  END IF;

  l_progress := '001';

  SELECT 'Y'
  INTO   l_valid_flag
  FROM   po_headers_all
  WHERE  po_header_id = p_from_header_id
  AND    nvl(closed_code,'OPEN') <> 'FINALLY CLOSED'
  AND    nvl(cancel_flag,'N') <> 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('PO', 'PO_SUB_CP_INVALID_GA_REF');
    po_copydoc_s1.online_report(p_online_report_id,
                                p_sequence,
                                substr(fnd_message.get, 1, 240),
                                p_line_num, 0, 0);
  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('validate_global_ref', l_progress, sqlcode,
                                    p_online_report_id,
                                    p_sequence,
                                    p_line_num, 0, 0);

END validate_global_ref;
--<Bug 2864544 mbhargav END>

--SERVICES FPJ Start
---------------------------------------------------------------------------------------------
--Start of Comments
--Name:         validate_job
--
--Pre-reqs:     None
--
--Modifies:     None
--
--Locks:        None
--
--Function:     This procedure validates the job on copied po document
--
--
--Parameters:
--IN:
--   p_job_id
--      Job id on the copied PO line
--   p_online_report_id
--      If of the error report to show errors if any
--   p_line_num
--      PO Line which is being validated
--IN OUT:
--   p_sequence
--      sequence of the online error report
--
--Testing:  -
--End of Comments
-------------------------------------------------------------------------------------------------
PROCEDURE validate_job(
  p_job_id              IN            po_lines.job_id%TYPE,
  p_online_report_id    IN            po_online_report_text.online_report_id%TYPE,
  p_line_num            IN            po_online_report_text.line_num%TYPE,
  p_sequence            IN OUT NOCOPY po_online_report_text.sequence%TYPE
) IS

 l_valid_flag  VARCHAR2(2);
 l_progress    VARCHAR2(4) := NULL;
 l_job_name    per_jobs_vl.name%TYPE;
 l_bg_name     per_business_groups_perf.name%TYPE;
 l_category    mtl_categories_kfv.concatenated_segments%TYPE;

BEGIN
 l_progress := '010';

  IF p_job_id is null THEN
    RETURN;
  END IF;

  -- Sql What : Get the job name for the given job_id
  -- Sql Why  : The Job name is used in the message token

    l_progress := '020';

    SELECT pj.name,
           pb.name
    INTO   l_job_name,
           l_bg_name
    FROM   per_jobs_vl pj,
           per_business_groups_perf pb
    WHERE  pj.business_group_id = pb.business_group_id
    AND    pj.job_id = p_job_id;


  -- Sql What : Check if the job exists in the Jobs table
  -- Sql Why  : Check if the Job is valid in HR
  Begin

    l_progress := '030';

    SELECT 'Y'
    INTO   l_valid_flag
    FROM   per_jobs
    WHERE  job_id = p_job_id
    AND    sysdate between date_from and nvl(date_to,sysdate+1);

  Exception

  When no_data_found Then

   IF nvl(hr_general.get_xbg_profile,'N') = 'Y' THEN
    fnd_message.set_name('PO', 'PO_SVC_JOB_INVALID_IN_HR_BG');
    fnd_message.set_token('JOB', l_job_name);
    fnd_message.set_token('BG',  l_bg_name);
   ELSE
    fnd_message.set_name('PO', 'PO_SVC_JOB_INVALID_IN_HR');
    fnd_message.set_token('JOB', l_job_name);
   END IF;

    po_copydoc_s1.online_report(p_online_report_id,
                                p_sequence,
                                substr(fnd_message.get, 1, 240),
                                p_line_num, 0, 0);
  End;

  -- Sql What : Check if the job exists in the Jobs table
  -- Sql Why  : Check if the Job is valid in HR
  Begin

    l_progress := '040';

    SELECT mtl.concatenated_segments
    INTO   l_category
    FROM   po_job_associations pja,
           mtl_categories_kfv mtl
    WHERE  pja.category_id = mtl.category_id
    AND    pja.job_id = p_job_id;

    SELECT 'Y'
    INTO   l_valid_flag
    FROM   po_job_associations
    WHERE  job_id = p_job_id
    AND    ( inactive_date is null
           OR trunc(sysdate) < trunc(inactive_date));

  Exception

  When no_data_found Then
    fnd_message.set_name('PO', 'PO_SVC_JOB_ASSOC_INVALID');
    fnd_message.set_token('JOB', l_job_name);
    fnd_message.set_token('CATEGORY', l_category);
    po_copydoc_s1.online_report(p_online_report_id,
                                p_sequence,
                                substr(fnd_message.get, 1, 240),
                                p_line_num, 0, 0);
  End;

  l_progress := '050';

EXCEPTION
WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('validate_job', l_progress, sqlcode,
                                    p_online_report_id,
                                    p_sequence,
                                    p_line_num, 0, 0);
END;

-- SERVICES FPJ End

PROCEDURE submission_check_copydoc(
  x_po_header_id      IN  po_headers.po_header_id%TYPE,
  x_online_report_id  IN  NUMBER,
  x_sob_id            IN  financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id        IN  financials_system_parameters.inventory_organization_id%TYPE) IS

  x_po_header_record        po_headers%ROWTYPE;
  x_po_line_record          po_lines%ROWTYPE;
  x_po_shipment_record      po_line_locations%ROWTYPE;
  x_po_distribution_record  po_distributions%ROWTYPE;

  x_line_num                 po_online_report_text.line_num%TYPE := NULL;
  x_shipment_num             po_online_report_text.shipment_num%TYPE := NULL;
  x_distribution_num         po_online_report_text.distribution_num%TYPE := NULL;

  x_progress                 VARCHAR2(4);
  x_sequence                 po_online_report_text.sequence%TYPE := 1;
  x_return_code              NUMBER := NULL;

  --<ENCUMBRANCE FPJ START>
  l_encumbrance_on           BOOLEAN;
  l_enc_type                 VARCHAR2(10);
  --<ENCUMBRANCE FPJ END>

  -- <PO_PJM_VALIDATION FPI START>
  l_val_proj_result     VARCHAR(1);
  l_val_proj_error_code VARCHAR2(80);
  -- <PO_PJM_VALIDATION FPI END>

  l_return_status VARCHAR2(1);                              --< Bug 3265539 >
  l_ship_to_ou_id FINANCIALS_SYSTEM_PARAMS_ALL.org_id%TYPE; --< Bug 3265539 >
  l_is_complex_work_po   BOOLEAN := FALSE;   --Bug6314548

  --<Bug 5332013 START>
   x_msg_application varchar2(30);
   x_msg_type varchar2(1);
   x_msg_token1 varchar2(30);
   x_msg_token2 varchar2(30);
   x_msg_token3 varchar2(30);
   x_msg_count number;
   x_msg_data varchar2(30);
   x_billable_flag varchar2(1);
  --<Bug 5332013 END>

BEGIN

  x_progress := '001';
  -- Get header info and validate header info:
  --    - buyer
  --    - vendor, vendor_site, vendor_contact
  --    - ship-to-locatioin, bill-to-location

  SELECT *
  INTO   x_po_header_record
  FROM   po_headers
  WHERE  po_header_id = x_po_header_id;

  /* Bug#6151431 ankusriv - FP for Bug#5871448 cvardia
  ** Desc : The below condition needs to be changed. We need to call Copy
  ** doc submission check only once when the PO is created and unapproved.
  **
  **
  ** Bug#2206125: kagarwal
  ** Desc: If the PO is for Re-approval we need not call the copy
  ** doc submission check - return with success.
  **
  **  if (nvl(x_po_header_record.approved_flag, 'N') = 'R') THEN
  **	RETURN;
  **  end if;
  */

  if (x_po_header_record.approved_date IS NOT NULL) THEN
    Return;
  end if;


  --<ENCUMBRANCE FPJ start>
  IF (x_po_header_record.type_lookup_code = 'BLANKET') THEN
     l_enc_type := 'PA';
  ELSE
     l_enc_type := 'PO';
  END IF;

  l_encumbrance_on := PO_CORE_S.is_encumbrance_on(
                         p_doc_type => l_enc_type
                      ,  p_org_id => NULL   --defaults to current context
                      );
  --<ENCUMBRANCE FPJ end>

  -- ship-to-location and bill-to-location validation is included
  -- in the validate_vendor procedure
  validate_vendor(x_sob_id,
                  x_inv_org_id,
                  x_po_header_record.vendor_id,
                  x_po_header_record.vendor_site_id,
                  x_po_header_record.vendor_contact_id,
                  x_po_header_record.ship_to_location_id,
                  x_po_header_record.bill_to_location_id,
                  x_po_header_record.ship_via_lookup_code,
                  x_po_header_record.fob_lookup_code,
                  x_po_header_record.freight_terms_lookup_code,
                  x_po_header_record.terms_id,
                  x_online_report_id,
                  x_sequence);

   /* the above procedure validates the location and terms on vendor. we need to
      validate these fields on the po header */
  validate_location_terms(x_sob_id,
                          x_po_header_record.ship_to_location_id,
                          x_po_header_record.bill_to_location_id,
                          x_po_header_record.fob_lookup_code,
                          x_po_header_record.freight_terms_lookup_code,
                          x_po_header_record.terms_id,
                          x_online_report_id,
                          x_sequence);

   validate_buyer_id(x_po_header_record.agent_id,
                    x_online_report_id,
                    x_sequence);

  --< Shared Proc FPJ Start >
  IF (x_po_header_record.global_agreement_flag = 'Y') THEN
      validate_org_assignments
          (p_po_header_id     => x_po_header_id,
           p_vendor_id        => x_po_header_record.vendor_id,
           p_online_report_id => x_online_report_id,
           x_sequence         => x_sequence);
  END IF;
  --< Shared Proc FPJ End >
  /*Bug	6314548 Check if the PO is complex PO.If so skip the check
   for validating destination_type_code for complex PO's */
    l_is_complex_work_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_po_header_id => x_po_header_id);

  --<ENCUMBRANCE FPJ START>
  IF nvl(x_po_header_record.encumbrance_required_flag, 'N') = 'Y' THEN
    --document is an encumbered BPA
    --the associated dist requires only a subset of the PO dist validations

    OPEN pa_distribution_cursor(x_po_header_id);
    <<BPADISTS>>
    LOOP
      FETCH pa_distribution_cursor INTO x_po_distribution_record;
      EXIT BPADISTS WHEN pa_distribution_cursor%NOTFOUND;

      -- Unlike PO, BPA distributions should NOT be validated on these fields:
      --    charge acct, accrual acct, variance acct IDs
      --    project/task information
      --    OSP information
      --    destination/deliver-to information

      validate_account_id(
         x_account_id => x_po_distribution_record.budget_account_id
      ,  x_account_type => 'BUDGET'
      ,  x_gl_date => x_po_distribution_record.gl_encumbered_date
      ,  x_sob_id => x_sob_id
      ,  x_online_report_id => x_online_report_id
      ,  x_sequence => x_sequence
      ,  x_line_num => NULL
      ,  x_shipment_num => NULL
      ,  x_distribution_num => x_po_distribution_record.distribution_num
      );

    END LOOP BPADISTS;
    CLOSE pa_distribution_cursor;  --bug 3447914: close the cursor

  ELSE
    --document is not an encumbered BPA
    --<ENCUMBRANCE FPJ END>

    OPEN po_line_cursor(x_po_header_id);
    <<LINES>>
    LOOP
      FETCH po_line_cursor INTO x_po_line_record;
      EXIT LINES WHEN po_line_cursor%NOTFOUND;

      x_line_num := x_po_line_record.line_num;
      -- Get each line and validate line info:
      --    - item
      --    - contract number

      validate_item(x_po_line_record.item_id,
		    x_po_line_record.item_description,
		    x_po_line_record.item_revision,
		    x_po_line_record.category_id,
		    x_po_line_record.line_type_id,
		    x_inv_org_id,
		    x_online_report_id,
		    x_sequence,
		    x_line_num,
		    x_return_code);

      validate_contract_num(x_po_line_record.contract_id,
			    x_online_report_id,
			    x_sequence,
			    x_line_num);

      --<Bug 2864544 mbhargav START>
      --Call to validate that the referenced global agreement is not cancelled or
      --finally closed
      IF (x_po_line_record.from_header_id is NOT NULL or
	  x_po_line_record.from_line_id is NOT NULL)
      THEN
	   validate_global_ref(x_po_line_record.from_header_id,
			  x_po_line_record.from_line_id,
			    x_online_report_id,
			    x_sequence,
			    x_line_num);
      END IF;
      --<Bug 2864544 mbhargav END>

      -- SERVICES FPJ Start
      -- Call the procedure to validate the HR job

	  validate_job(p_job_id            => x_po_line_record.job_id,
		       p_online_report_id  => x_online_report_id,
		       p_line_num          => x_line_num,
		       p_sequence          => x_sequence );

      -- SERVICES FPJ End

      OPEN po_shipment_cursor(x_po_line_record.po_line_id);
      <<SHIPMENTS>>
      LOOP
	FETCH po_shipment_cursor INTO x_po_shipment_record;
	EXIT SHIPMENTS WHEN po_shipment_cursor%NOTFOUND;

	x_shipment_num := x_po_shipment_record.shipment_num;
	-- Get each shipment and validate shipment info:

	--< Shared Proc FPJ Start >
	IF (x_po_shipment_record.shipment_type = 'STANDARD') THEN
	    validate_transaction_flow
	      (p_ship_to_org_id   => x_po_shipment_record.ship_to_organization_id,
	       p_transaction_flow_header_id =>
				  x_po_shipment_record.transaction_flow_header_id,
	       p_item_category_id => x_po_line_record.category_id,
	       p_online_report_id => x_online_report_id,
	       p_line_num         => x_line_num,
	       p_shipment_num     => x_shipment_num,
               p_item_id          => x_po_line_record.item_id, -- Bug 3433867
	       x_sequence         => x_sequence);
	END IF;
	--< Shared Proc FPJ End >

    --< Bug 3370735 Start >
    IF (x_po_header_record.type_lookup_code NOT IN ('BLANKET', 'RFQ'))
    THEN
        --< Bug 3265539 >
        -- Derive the operating unit associated with the ship-to org
        PO_CORE_S.get_inv_org_ou_id
            (x_return_status => l_return_status,
             p_inv_org_id    => x_po_shipment_record.ship_to_organization_id,
             x_ou_id         => l_ship_to_ou_id);

        IF (l_return_status <> FND_API.g_ret_sts_success) THEN
            RAISE APP_EXCEPTION.application_exception;
        END IF;
        --< Bug 3265539 End >

    END IF;
    --< Bug 3370735 End >

	OPEN po_distribution_cursor(x_po_shipment_record.line_location_id);
	<<DISTRIBUTIONS>>
	LOOP
	  FETCH po_distribution_cursor INTO x_po_distribution_record;
	  EXIT DISTRIBUTIONS WHEN po_distribution_cursor%NOTFOUND;

	  x_distribution_num := x_po_distribution_record.distribution_num;
	  -- Get each distribution and validate distribution info:
	  --    - deliver-to-person
	  --    - deliver-to-location, inventory_location
	  --    - charge, accrual, budget, variance account
	  --    - project id, task id

  /* kagarwal: Check only when PO encumbrance is on */

	  IF ((x_po_distribution_record.budget_account_id IS NOT NULL)
	     AND l_encumbrance_on) THEN
	    validate_account_id(x_po_distribution_record.budget_account_id,
				'BUDGET',
				x_po_distribution_record.gl_encumbered_date,
				x_sob_id,
				x_online_report_id,
				x_sequence,
				x_line_num,
				x_shipment_num,
				x_distribution_num);
	  END IF;

	  validate_account_id(x_po_distribution_record.code_combination_id,
			      'CHARGE',
			      x_po_distribution_record.gl_encumbered_date,
			      x_sob_id,
			      x_online_report_id,
			      x_sequence,
			      x_line_num,
			      x_shipment_num,
			      x_distribution_num);

	  validate_account_id(x_po_distribution_record.accrual_account_id,
			      'ACCRUAL',
			      x_po_distribution_record.gl_encumbered_date,
			      x_sob_id,
			      x_online_report_id,
			      x_sequence,
			      x_line_num,
			      x_shipment_num,
			      x_distribution_num);

	  validate_account_id(x_po_distribution_record.variance_account_id,
			      'VARIANCE',
			      x_po_distribution_record.gl_encumbered_date,
			      x_sob_id,
			      x_online_report_id,
			      x_sequence,
			      x_line_num,
			      x_shipment_num,
			      x_distribution_num);

	-- <PO_PJM_VALIDATION FPI>
	-- Added the IF statement and ELSE clause. Removed the
	-- x_destination_type_code and x_ship_to_organized_id arguments
	-- from validate_project_id.

    /*BUG6643377 Added the following IF condition to conditionally excecute the code depending on whether PO has a project reference or not*/

        IF x_po_distribution_record.project_id IS NOT NULL THEN

	IF (x_po_distribution_record.destination_type_code = 'EXPENSE') THEN

	validate_project_id(x_po_distribution_record.project_id,
  --                            x_po_distribution_record.destination_type_code,
  --                            x_po_shipment_record.ship_to_organization_id,
			      x_online_report_id,
			      x_sequence,
			      x_line_num,
			      x_shipment_num,
			      x_distribution_num);

	  validate_task_id(x_po_distribution_record.task_id,
			   x_po_distribution_record.project_id,
			   x_online_report_id,
			   x_sequence,
			   x_line_num,
			   x_shipment_num,
			   x_distribution_num);

     -- Start Bug 3488117: Do expenditure date, type, and org  validations.
     -- Start bug 14296213: project end date validation for copied po
        validate_proj_end_date(x_po_distribution_record.project_id,
                         x_po_distribution_record.task_id,
  			               -- x_po_distribution_record.expenditure_item_date,
                         x_online_report_id,
                         x_sequence,
                         x_line_num,
                         x_shipment_num,
                         x_distribution_num);

        validate_task_end_date(x_po_distribution_record.project_id,
                         x_po_distribution_record.task_id,
  			               -- x_po_distribution_record.expenditure_item_date,
                         x_online_report_id,
                         x_sequence,
                         x_line_num,
                         x_shipment_num,
                         x_distribution_num);
      -- End bug 14296213
        validate_exp_item_date(x_po_distribution_record.project_id,
                         x_po_distribution_record.task_id,
  			                x_po_distribution_record.expenditure_item_date,
                         x_online_report_id,
                         x_sequence,
                         x_line_num,
                         x_shipment_num,
                         x_distribution_num);

       	validate_exp_type(x_po_distribution_record.project_id,
                         x_po_distribution_record.expenditure_type,
                         x_online_report_id,
                         x_sequence,
                         x_line_num,
                         x_shipment_num,
                         x_distribution_num);

       	validate_exp_org(x_po_distribution_record.expenditure_organization_id,
                         x_online_report_id,
                         x_sequence,
                         x_line_num,
                         x_shipment_num,
                         x_distribution_num);
     -- End Bug 3488117

/* Bug# 5332013, Calling the PA api to do the transaction control validation*/
        -- <Start Bug# 5332013>
        pa_transactions_pub.validate_transaction(X_project_id=>x_po_distribution_record.project_id
                , X_task_id => x_po_distribution_record.task_id
                , X_ei_date => x_po_distribution_record.expenditure_item_date
                , X_expenditure_type => x_po_distribution_record.expenditure_type
                , X_non_labor_resource => ''
                , X_person_id => x_po_distribution_record.deliver_to_person_id
                , X_quantity => ''
                , X_denom_currency_code => ''
                , X_acct_currency_code => ''
                , X_denom_raw_cost => ''
                , X_acct_raw_cost => ''
                , X_acct_rate_type => ''
                , X_acct_rate_date => ''
                , X_acct_exchange_rate => ''
                , X_transfer_ei => ''
                , X_incurred_by_org_id => x_po_distribution_record.expenditure_organization_id
                , X_nl_resource_org_id => ''
                , X_transaction_source => ''
                , X_calling_module => 'POXPOEPO'
                , X_vendor_id => ''
                , X_entered_by_user_id => ''
                , X_attribute_category => ''
                , X_attribute1 => ''
                , X_attribute2 => ''
                , X_attribute3 => ''
                , X_attribute4 => ''
                , X_attribute5 => ''
                , X_attribute6 => ''
                , X_attribute7 => ''
                , X_attribute8 => ''
                , X_attribute9 => ''
                , X_attribute10 => ''
                , X_attribute11 => ''
                , X_attribute12 => ''
                , X_attribute13 => ''
                , X_attribute14 => ''
                , X_attribute15 => ''
                , X_msg_application => X_msg_application
                , X_msg_type => X_msg_type
                , X_msg_token1 => X_msg_token1
                , X_msg_token2 => X_msg_token2
                , X_msg_token3 => X_msg_token3
                , X_msg_count => X_msg_count
                , X_msg_data =>  X_msg_data
                , X_billable_flag => X_billable_flag);

           IF x_msg_type = 'E' and x_msg_data is not NULL THEN
	     -- Write the message to the PO_ONLINE_REPORT_TEXT table as an error.
	     po_copydoc_s1.online_report(x_online_report_id,
		x_sequence, x_msg_data,
		x_line_num, x_shipment_num, x_distribution_num,
		PO_COPYDOC_S1.G_ERROR_MESSAGE_TYPE);
           ELSIF x_msg_type = 'W' and x_msg_data is not NULL THEN
	     -- Write the message to the PO_ONLINE_REPORT_TEXT table as a warning.
	     po_copydoc_s1.online_report(x_online_report_id,
		x_sequence, x_msg_data,
		x_line_num, x_shipment_num, x_distribution_num,
		PO_COPYDOC_S1.G_WARNING_MESSAGE_TYPE);
           END IF;
        -- <End Bug# 5332013>

	-- <PO_PJM_VALIDATION FPI START>
	ELSE
        --< Bug 3265539 Start >
        -- Call PO wrapper procedure to validate the PJM project
        PO_PROJECT_DETAILS_SV.validate_proj_references_wpr
            (p_inventory_org_id => x_po_shipment_record.ship_to_organization_id,
             p_operating_unit   => l_ship_to_ou_id,
             p_project_id       => x_po_distribution_record.project_id,
             p_task_id          => x_po_distribution_record.task_id,
             p_date1            => x_po_shipment_record.need_by_date,
             p_date2            => x_po_shipment_record.promised_date,
             p_calling_function => 'POXCPSUB',
             x_error_code       => l_val_proj_error_code,
             x_return_code      => l_val_proj_result);

	   IF ( l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_failure) THEN
	     -- Write the message to the PO_ONLINE_REPORT_TEXT table as an error.
	     po_copydoc_s1.online_report(x_online_report_id,
		x_sequence, FND_MESSAGE.get,
		x_line_num, x_shipment_num, x_distribution_num,
		PO_COPYDOC_S1.G_ERROR_MESSAGE_TYPE);
	   ELSIF ( l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_warning) THEN
	     -- Write the message to the PO_ONLINE_REPORT_TEXT table as a warning.
	     po_copydoc_s1.online_report(x_online_report_id,
		x_sequence, FND_MESSAGE.get,
		x_line_num, x_shipment_num, x_distribution_num,
		PO_COPYDOC_S1.G_WARNING_MESSAGE_TYPE);
	   END IF;
        --< Bug 3265539 End >

	END IF; /* destination type is 'EXPENSE' */
	-- <PO_PJM_VALIDATION FPI END>
        END IF; --BUG6643377

	 /*Bug6314548 Donot call this validation if PO is complex work PO */
	 IF (NOT l_is_complex_work_po) then
	  validate_destination_type_code(x_po_distribution_record.destination_type_code,
					 x_po_line_record.item_id,
					 x_po_shipment_record.ship_to_organization_id,
					 nvl(x_po_distribution_record.accrue_on_receipt_flag,x_po_shipment_record.accrue_on_receipt_flag),
					 x_online_report_id,
					 x_sequence,
					 x_line_num,
					 x_shipment_num,
					 X_distribution_num,
					 x_po_shipment_record.line_location_id,
                                         x_po_line_record.po_line_id, ---Bug 3557910 Additional Input Parameter PO LINE ID
                                          x_po_shipment_record.transaction_flow_header_id);  --< Bug 3546252 >

          END IF; --Bug6314548

	  validate_deliver_to_loc_id(x_po_distribution_record.deliver_to_location_id,
				     x_po_shipment_record.ship_to_organization_id,
				     x_online_report_id,
				     x_sequence,
				     x_line_num,
				     x_shipment_num,
				     x_distribution_num);

	  validate_dest_subinventory(x_po_distribution_record.destination_subinventory,
				     x_po_shipment_record.ship_to_organization_id,
				     x_po_line_record.item_id,
				     x_online_report_id,
				     x_sequence,
				     x_line_num,
				     x_shipment_num,
				     x_distribution_num);

	  validate_deliver_to_person_id(x_po_distribution_record.deliver_to_person_id,
					x_online_report_id,
					x_sequence,
					x_line_num,
					x_shipment_num,
					x_distribution_num);

	  -- Validate OSP data ( Bug: 2072545 )
	  validate_osp_data(x_po_distribution_record.wip_entity_id,
			    x_po_distribution_record.wip_operation_seq_num,
			    x_po_distribution_record.wip_resource_seq_num,
			    x_po_distribution_record.wip_repetitive_schedule_id,
			    x_po_distribution_record.wip_line_id,
			    x_po_distribution_record.destination_organization_id,
			    x_online_report_id,
			    x_sequence,
			    x_line_num,
			    x_shipment_num,
			    x_distribution_num);

	END LOOP DISTRIBUTIONS;
	CLOSE po_distribution_cursor;

      END LOOP SHIPMENTS;
      CLOSE po_shipment_cursor;

    END LOOP LINES;
    CLOSE po_line_cursor;

  END IF;  -- doc is encumbered BPA check <ENCUMBRANCE FPJ>

EXCEPTION
  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('submission_check_copydoc', x_progress, sqlcode,
                                   x_online_report_id,
                                   x_sequence,
                                   x_line_num,x_shipment_num,x_distribution_num);

END submission_check_copydoc;

--< Shared Proc FPJ Start >
--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_transaction_flow
--Pre-reqs:
--  None.
--Modifies:
--  PO_ONLINE_REPORT_TEXT
--Locks:
--  None.
--Function:
--  Validates the transaction flow if it is not NULL.  If it is a valid
--  flow with respect to the ship-to org, then validation passes. Otherwise,
--  adds error to the online report.
--Parameters:
--IN:
--p_ship_to_org_id
--p_transaction_flow_header_id
--p_item_category_id
--p_online_report_id
--p_line_num
--p_shipment_num
--p_item_id
--IN OUT:
--x_sequence
--  PO_ONLINE_REPORT_TEXT.sequence.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_transaction_flow
(
    p_ship_to_org_id             IN     NUMBER,
    p_transaction_flow_header_id IN     NUMBER,
    p_item_category_id           IN     NUMBER,
    p_online_report_id           IN     NUMBER,
    p_line_num                   IN     NUMBER,
    p_shipment_num               IN     NUMBER,
    p_item_id                    IN     NUMBER, -- Bug 3433867
    x_sequence                   IN OUT NOCOPY NUMBER
)
IS

l_progress       VARCHAR2(3);
l_is_valid       BOOLEAN;
l_in_current_sob BOOLEAN;
l_check_txn_flow BOOLEAN;
l_return_status  VARCHAR2(1);

l_transaction_flow_header_id
    PO_LINE_LOCATIONS_ALL.transaction_flow_header_id%TYPE;

BEGIN
    l_progress := '000';

    IF (p_transaction_flow_header_id IS NOT NULL) THEN

        l_progress := '010';

        PO_SHARED_PROC_PVT.validate_ship_to_org
            (p_init_msg_list              => FND_API.g_false,
             x_return_status              => l_return_status,
             p_ship_to_org_id             => p_ship_to_org_id,
             p_item_category_id           => p_item_category_id,
             p_item_id                    => p_item_id, -- Bug 3433867
             x_is_valid                   => l_is_valid,
             x_in_current_sob             => l_in_current_sob,
             x_check_txn_flow             => l_check_txn_flow,
             x_transaction_flow_header_id => l_transaction_flow_header_id);

        l_progress := '020';

        IF (l_return_status <> FND_API.g_ret_sts_success) THEN
            FND_MESSAGE.set_encoded(encoded_message => FND_MSG_PUB.get);
            RAISE FND_API.g_exc_error;
        END IF;

        l_progress := '030';

        IF (NOT l_is_valid) OR
           (p_transaction_flow_header_id <>
            NVL(l_transaction_flow_header_id, -99))
        THEN
            FND_MESSAGE.set_name(application => 'PO',
                                 name        => 'PO_COPY_DOC_INVALID_TXN_FLOW');
            RAISE FND_API.g_exc_error;
        END IF;

    END IF;  --< if txn flow header ID not null >

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        PO_COPYDOC_S1.online_report
           (x_online_report_id => p_online_report_id,
            x_sequence         => x_sequence,
            x_message          => FND_MESSAGE.get,
            x_line_num         => p_line_num,
            x_shipment_num     => p_shipment_num,
            x_distribution_num => 0);
    WHEN OTHERS THEN
        PO_COPYDOC_S1.copydoc_sql_error
           (x_routine          => 'PO_COPYDOC_SUB.validate_transaction_flow',
            x_progress         => l_progress,
            x_sqlcode          => SQLCODE,
            x_online_report_id => p_online_report_id,
            x_sequence         => x_sequence,
            x_line_num         => p_line_num,
            x_shipment_num     => p_shipment_num,
            x_distribution_num => 0);
END validate_transaction_flow;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_org_assignments
--Pre-reqs:
--  None.
--Modifies:
--  PO_ONLINE_REPORT_TEXT
--  PO_SESSION_GT
--  PO_SESSION_GT_S
--Locks:
--  None.
--Function:
--  Validates all the enabled org assignments of the Global Agreement
--  p_po_header_id. Checks if the Requesting Org, Purchasing Org, and
--  Purchasing Site are still valid for all the enabled records. Inserts an
--  error message to PO_ONLINE_REPORT_TEXT table under ID p_online_report_id
--  for each check that fails.
--Parameters:
--IN:
--p_po_header_id
--  The PO header ID of the GA.
--p_vendor_id
--  The vendor ID of the GA header.
--p_online_report_id
--  The online report ID to write to if an error occurs.
--IN OUT:
--x_sequence
--  The online report sequence, which gets incremented when an error is
--  written to PO_ONLINE_REPORT_TEXT.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_org_assignments
(
    p_po_header_id     IN     NUMBER,
    p_vendor_id        IN     NUMBER,
    p_online_report_id IN     NUMBER,
    x_sequence         IN OUT NOCOPY NUMBER
)
IS

l_progress            VARCHAR2(3);
l_return_status       VARCHAR2(1);
l_user_id             NUMBER;
l_login_id            NUMBER;
l_err_prefix          VARCHAR2(256);
l_populate_failed_exc EXCEPTION;

l_key          PO_SESSION_GT.key%TYPE;
l_text_line    PO_ONLINE_REPORT_TEXT.text_line%TYPE;
l_message_type PO_ONLINE_REPORT_TEXT.message_type%TYPE;

BEGIN

    l_progress := '000';

    -- Populate the global session table with all enabled org assignments for
    -- the current GA.
    populate_session_gt(x_return_status    => l_return_status,
                        p_po_header_id     => p_po_header_id,
                        p_online_report_id => p_online_report_id,
                        x_sequence         => x_sequence,
                        x_key              => l_key);

    IF (l_return_status <> FND_API.g_ret_sts_success) THEN
        RAISE l_populate_failed_exc;
    END IF;

    l_progress := '010';

    l_user_id := FND_GLOBAL.user_id;
    l_login_id := FND_GLOBAL.login_id;
    l_message_type := PO_COPYDOC_S1.g_error_message_type;
    l_err_prefix := FND_MESSAGE.get_string(appin  => 'PO',
                                           namein => 'PO_GA_ORG_ASSIGN_PREFIX');

    --------------------------------------------------------------
    l_progress := '020';

    -- Validate the Requesting Orgs for all enabled org assignments
    l_text_line := FND_MESSAGE.get_string
                       (appin  => 'PO',
                        namein => 'PO_GA_INVALID_REQUESTING_ORG');
    INSERT INTO po_online_report_text
    (
           online_report_id,
           last_update_login,
           last_updated_by,
           last_update_date,
           created_by,
           creation_date,
           sequence,
           text_line,
           message_type
    )
    --SQL What: Check if the requesting orgs for enabled org assignments are
    --          still valid.
    --SQL Why: Insert an error for each invalid requesting org
    SELECT p_online_report_id,
           l_login_id,
           l_user_id,
           SYSDATE,
           l_user_id,
           SYSDATE,
           x_sequence + ROWNUM,
           SUBSTRB(l_err_prefix||psg.char1||l_text_line,1,2000),
           l_message_type
      FROM po_session_gt psg
     WHERE psg.key = l_key
       AND NOT EXISTS
           (SELECT 'is active ou'
              FROM hr_operating_units hou,
                   financials_system_params_all fspa,
                   po_system_parameters_all pspa
             WHERE hou.organization_id = psg.num1
               AND hou.organization_id = pspa.org_id
               AND pspa.org_id = fspa.org_id
               AND TRUNC(SYSDATE) BETWEEN TRUNC(hou.date_from)
                                      AND TRUNC(NVL(hou.date_to, SYSDATE+1))
           );

    --Increment the x_sequence with number of errors reported in last query
    x_sequence := x_sequence + SQL%ROWCOUNT;

    --------------------------------------------------------------
    l_progress := '030';

    -- Validate the Purchasing Orgs for all enabled org assignments
    l_text_line := FND_MESSAGE.get_string
                       (appin  => 'PO',
                        namein => 'PO_GA_INVALID_PURCHASING_ORG');
    INSERT INTO po_online_report_text
    (
           online_report_id,
           last_update_login,
           last_updated_by,
           last_update_date,
           created_by,
           creation_date,
           sequence,
           text_line,
           message_type
    )
    --SQL What: Check if the purchasing orgs for enabled org assignments are
    --          still valid.
    --SQL Why: Insert an error for each invalid purchasing org
    SELECT p_online_report_id,
           l_login_id,
           l_user_id,
           SYSDATE,
           l_user_id,
           SYSDATE,
           x_sequence + ROWNUM,
           SUBSTRB(l_err_prefix||psg.char1||l_text_line,1,2000),
           l_message_type
      FROM po_session_gt psg
     WHERE psg.key = l_key
       AND (NOT EXISTS
               (SELECT 'is active ou'
                  FROM hr_operating_units hou,
                       financials_system_params_all fspa,
                       po_system_parameters_all pspa
                 WHERE hou.organization_id = psg.num2
                   AND hou.organization_id = pspa.org_id
                   AND pspa.org_id = fspa.org_id
                   AND TRUNC(SYSDATE) BETWEEN TRUNC(hou.date_from)
                                          AND TRUNC(NVL(hou.date_to, SYSDATE+1))
               )
            OR
            NOT EXISTS
                (SELECT 'encumbrance check'
                   FROM financials_system_params_all fspa1,
                        financials_system_params_all fspa2
                  WHERE fspa1.org_id = psg.num1
                    AND fspa2.org_id = psg.num2
                    AND (   fspa1.org_id = fspa2.org_id
                         OR
                            (    NVL(fspa1.purch_encumbrance_flag,'N') = 'N'
                             AND NVL(fspa1.req_encumbrance_flag,'N') = 'N'
                             AND NVL(fspa2.purch_encumbrance_flag,'N') = 'N'
                             AND NVL(fspa2.req_encumbrance_flag,'N') = 'N'
                            )
                        )
                )
            OR
            NOT EXISTS
                (SELECT 'Valid vendor site for POU'
                   FROM po_vendor_sites_all pvsa
                  WHERE pvsa.vendor_id = p_vendor_id
                    AND pvsa.org_id = psg.num2
                    AND pvsa.purchasing_site_flag = 'Y'
                    AND NVL(pvsa.rfq_only_site_flag, 'N') = 'N'
                    AND TRUNC(SYSDATE) <
                        TRUNC(NVL(pvsa.inactive_date, SYSDATE+1))
                )
           );

    --Increment the x_sequence with number of errors reported in last query
    x_sequence := x_sequence + SQL%ROWCOUNT;

    --------------------------------------------------------------
    l_progress := '040';

    -- Validate the Purchasing Sites for all enabled org assignments
    l_text_line := FND_MESSAGE.get_string
                       (appin  => 'PO',
                        namein => 'PO_GA_INVALID_PURCHASING_SITE');
    INSERT INTO po_online_report_text
    (
           online_report_id,
           last_update_login,
           last_updated_by,
           last_update_date,
           created_by,
           creation_date,
           sequence,
           text_line,
           message_type
    )
    --SQL What: Check if the purchasing sites for enabled org assignments are
    --          still valid.
    --SQL Why: Insert an error for each invalid purchasing site
    SELECT p_online_report_id,
           l_login_id,
           l_user_id,
           SYSDATE,
           l_user_id,
           SYSDATE,
           x_sequence + ROWNUM,
           SUBSTRB(l_err_prefix||psg.char1||l_text_line,1,2000),
           l_message_type
      FROM po_session_gt psg
     WHERE psg.key = l_key
       AND NOT EXISTS
           (SELECT 'Valid vendor site'
              FROM po_vendor_sites_all pvsa
             WHERE pvsa.vendor_site_id = psg.num3
               AND pvsa.vendor_id = p_vendor_id
               AND pvsa.org_id = psg.num2
               AND pvsa.purchasing_site_flag = 'Y'
               AND NVL(pvsa.rfq_only_site_flag, 'N') = 'N'
               AND TRUNC(SYSDATE) < TRUNC(NVL(pvsa.inactive_date, SYSDATE+1))
           );

    --Increment the x_sequence with number of errors reported in last query
    x_sequence := x_sequence + SQL%ROWCOUNT;

EXCEPTION
    WHEN l_populate_failed_exc THEN
        -- If caught, error already inserted, so do nothing here.
        NULL;
    WHEN OTHERS THEN
        PO_COPYDOC_S1.copydoc_sql_error
            (x_routine          => 'PO_COPYDOC_SUB.validate_org_assignments',
             x_progress         => l_progress,
             x_sqlcode          => SQLCODE,
             x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_line_num         => 0,
             x_shipment_num     => 0,
             x_distribution_num => 0);
END validate_org_assignments;

--------------------------------------------------------------------------------
--Start of Comments
--Name: populate_session_gt
--Pre-reqs:
--  None.
--Modifies:
--  PO_SESSION_GT
--  PO_SESSION_GT_S
--Locks:
--  None.
--Function:
--  Populates the global session table PO_SESSION_GT with all the org
--  assignments of p_po_header_id that are enabled. The columns populated are:
--      key   -> x_key
--      num1  -> Requesting Org ID
--      num2  -> Purchasing Org ID
--      num3  -> Vendor Site ID
--      char1 -> Requesting Org Name
--Parameters:
--IN:
--p_po_header_id
--  The PO header ID of the GA.
--p_online_report_id
--  The online report ID to write to if an error occurs.
--IN OUT:
--x_sequence
--  The online report sequence, which gets incremented when an error is
--  written to PO_ONLINE_REPORT_TEXT.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - success
--  FND_API.g_ret_sts_unexp_error - unexpected error occurs
--x_key
--  The next value in the PO_SESSION_GT_S sequence to be used as the key for
--  all the data inserted.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE populate_session_gt
(
    x_return_status    OUT    NOCOPY VARCHAR2,
    p_po_header_id     IN     NUMBER,
    p_online_report_id IN     NUMBER,
    x_sequence         IN OUT NOCOPY NUMBER,
    x_key              OUT    NOCOPY NUMBER
)
IS

l_progress VARCHAR2(3);

BEGIN

    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    -- Get the key for the global session table to use for this GA
    SELECT po_session_gt_s.nextval
      INTO x_key
      FROM DUAL;

    l_progress := '010';

    -- Populate the global session table with all enabled org assignments for
    -- the current GA.
    INSERT INTO po_session_gt
    (
           key,
           num1,
           num2,
           num3,
           char1
    )
    --SQL What: Get info for all enabled org assignments of this GA
    --SQL Why: Store info temporarily for org assignment submission checks
    SELECT x_key,
           pgoa.organization_id,
           pgoa.purchasing_org_id,
           pgoa.vendor_site_id,
           hout.name
      FROM po_ga_org_assignments pgoa,
           hr_all_organization_units_tl hout
     WHERE pgoa.po_header_id = p_po_header_id
       AND pgoa.organization_id = hout.organization_id
       AND hout.language = USERENV('LANG')
       AND pgoa.enabled_flag = 'Y';

    IF (SQL%ROWCOUNT = 0) THEN
        -- Need to raise error if nothing gets inserted
        RAISE NO_DATA_FOUND;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        PO_COPYDOC_S1.copydoc_sql_error
            (x_routine          => 'PO_COPYDOC_SUB.populate_session_gt',
             x_progress         => l_progress,
             x_sqlcode          => SQLCODE,
             x_online_report_id => p_online_report_id,
             x_sequence         => x_sequence,
             x_line_num         => 0,
             x_shipment_num     => 0,
             x_distribution_num => 0);
END populate_session_gt;

--< Shared Proc FPJ End >

END po_copydoc_sub;

/
