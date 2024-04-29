--------------------------------------------------------
--  DDL for Package Body IGC_CC_PO_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_PO_INTERFACE_PKG" AS
/*$Header: IGCCCPIB.pls 120.14.12010000.2 2008/08/04 14:49:33 sasukuma ship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_PO_INTERFACE_PKG';

  -- The flag determines whether to print debug information or not.
  g_debug_flag        VARCHAR2(1);

PROCEDURE Initialize_Header_Row(p_mode            IN    VARCHAR2,
                                p_encumbrance_on  IN    VARCHAR2,
                                p_cc_headers_rec  IN    igc_cc_headers%ROWTYPE,
                                p_po_headers_rec  IN    OUT NOCOPY po_headers_all%ROWTYPE)
IS

   l_po_headers_rec po_headers_all%ROWTYPE;
   l_employee_id NUMBER;
   E_EMPLOYEE_NOT_FOUND EXCEPTION;
BEGIN
   -- Bug 3605536 GSCC warnings fixed
   l_employee_id  := 0;

   /* Initialize CC related attributes */
   /* Insert */

   IF (p_mode = 'I') THEN
      SELECT po_headers_s.NEXTVAL
      INTO l_po_headers_rec.po_header_id
      FROM dual;
   ELSE
      /* Update */
      l_po_headers_rec         := p_po_headers_rec;
   END IF;

   BEGIN
     SELECT employee_id
     INTO l_employee_id
     FROM fnd_user
     WHERE user_id = p_cc_headers_rec.cc_preparer_user_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('IGC','IGC_CC_PREPARER_EMPLOYEE_ID');
        fnd_message.set_token('PREPARER_ID',to_char(p_cc_headers_rec.cc_preparer_user_id),TRUE);
        fnd_msg_pub.add;
        RAISE E_EMPLOYEE_NOT_FOUND;
   END;

   -- bug 2973033 - ssmales 30-May-2003 added IF statement below for preparers without linked employee
   IF l_employee_id IS NULL THEN
      fnd_message.set_name('IGC','IGC_CC_PREPARER_EMPLOYEE_ID');
      fnd_message.set_token('PREPARER_ID',to_char(p_cc_headers_rec.cc_preparer_user_id),TRUE);
      fnd_msg_pub.add;
      RAISE E_EMPLOYEE_NOT_FOUND;
   END IF;

   l_po_headers_rec.agent_id                    := l_employee_id;
   l_po_headers_rec.segment1                    := p_cc_headers_rec.cc_num;
   l_po_headers_rec.vendor_id                   := p_cc_headers_rec.vendor_id;
   l_po_headers_rec.vendor_site_id              := p_cc_headers_rec.vendor_site_id;
   l_po_headers_rec.vendor_contact_id           := p_cc_headers_rec.vendor_contact_id;
   l_po_headers_rec.ship_to_location_id         := p_cc_headers_rec.location_id;
   l_po_headers_rec.bill_to_location_id         := p_cc_headers_rec.location_id;
   l_po_headers_rec.terms_id                    := p_cc_headers_rec.term_id;
   l_po_headers_rec.revision_num                := p_cc_headers_rec.cc_version_num;
   l_po_headers_rec.currency_code               := p_cc_headers_rec.currency_code;
   l_po_headers_rec.rate_type                   := p_cc_headers_rec.conversion_type;
   l_po_headers_rec.rate_date                   := p_cc_headers_rec.conversion_date;
   l_po_headers_rec.rate                        := p_cc_headers_rec.conversion_rate;
   l_po_headers_rec.org_id                      := p_cc_headers_rec.org_id;
   l_po_headers_rec.last_update_login           := p_cc_headers_rec.last_update_login;
   l_po_headers_rec.creation_date               := p_cc_headers_rec.creation_date;
   l_po_headers_rec.created_by                  := p_cc_headers_rec.created_by;
   l_po_headers_rec.last_update_date            := p_cc_headers_rec.last_update_date;
   l_po_headers_rec.last_updated_by             := p_cc_headers_rec.last_updated_by;

   /* Standard default values  PO Columns */

   IF (p_mode = 'I') THEN
      l_po_headers_rec.type_lookup_code            := 'STANDARD';
      l_po_headers_rec.summary_flag                := 'N';
      l_po_headers_rec.enabled_flag                := 'Y';
      l_po_headers_rec.fob_lookup_code             := 'Destination';
      l_po_headers_rec.freight_terms_lookup_code   := 'TBD';
      l_po_headers_rec.print_count                 := 0;
      l_po_headers_rec.confirming_order_flag       := 'N';
      l_po_headers_rec.acceptance_required_flag    := 'N';
      l_po_headers_rec.cancel_flag                 := 'N';
      l_po_headers_rec.firm_status_lookup_code     := 'N';
      l_po_headers_rec.frozen_flag                 := 'N';
      l_po_headers_rec.supply_agreement_flag       := 'N';
   END IF;

   /* Check Contract Commitment document control status and approval status and
      encumbrance status to set approved_flag, approved_date and authorization status columns
      of PO */

   IF (p_cc_headers_rec.cc_apprvl_status = 'AP') AND
        (p_cc_headers_rec.cc_ctrl_status = 'O')  AND
          ( ((p_encumbrance_on = FND_API.G_TRUE) AND (p_cc_headers_rec.cc_encmbrnc_status = 'C')) OR
            ((p_encumbrance_on = FND_API.G_FALSE) AND (p_cc_headers_rec.cc_encmbrnc_status = 'N'))
       ) THEN

       l_po_headers_rec.authorization_status        := 'APPROVED';
       l_po_headers_rec.approved_flag               := 'Y';
       l_po_headers_rec.approved_date               := sysdate;
   ELSE
       l_po_headers_rec.authorization_status        := NULL;
       l_po_headers_rec.approved_flag               := 'N';
       l_po_headers_rec.approved_date               := NULL;
   END IF;


   IF (p_mode = 'I') THEN
      l_po_headers_rec.segment2                    := NULL;
      l_po_headers_rec.segment3                    := NULL;
      l_po_headers_rec.segment4                    := NULL;
      l_po_headers_rec.segment5                    := NULL;
      l_po_headers_rec.start_date_active           := NULL;
      l_po_headers_rec.end_date_active             := NULL;
      l_po_headers_rec.ship_via_lookup_code        := NULL;
      l_po_headers_rec.status_lookup_code          := NULL;
      l_po_headers_rec.from_header_id              := NULL;
      l_po_headers_rec.from_type_lookup_code       := NULL;
      l_po_headers_rec.start_date                  := NULL;
      l_po_headers_rec.end_date                    := NULL;
      l_po_headers_rec.blanket_total_amount        := NULL;
      l_po_headers_rec.revised_date                := NULL;
      l_po_headers_rec.amount_limit                := NULL;
      l_po_headers_rec.min_release_amount          := NULL;
      l_po_headers_rec.note_to_authorizer          := NULL;
      l_po_headers_rec.note_to_vendor              := NULL;
      l_po_headers_rec.note_to_receiver            := NULL;
      l_po_headers_rec.printed_date                := NULL;
      l_po_headers_rec.vendor_order_num            := NULL;
      l_po_headers_rec.comments                    := NULL;
      l_po_headers_rec.reply_date                  := NULL;
      l_po_headers_rec.reply_method_lookup_code    := NULL;
      l_po_headers_rec.rfq_close_date              := NULL;
      l_po_headers_rec.quote_type_lookup_code      := NULL;
      l_po_headers_rec.quotation_class_code        := NULL;
      l_po_headers_rec.quote_warning_delay_unit    := NULL;
      l_po_headers_rec.quote_warning_delay         := NULL;
      l_po_headers_rec.quote_vendor_quote_number   := NULL;
      l_po_headers_rec.acceptance_due_date         := NULL;
      l_po_headers_rec.closed_date                 := NULL;
      l_po_headers_rec.user_hold_flag              := NULL;
      l_po_headers_rec.approval_required_flag      := NULL;
      l_po_headers_rec.firm_date                   := NULL;
      l_po_headers_rec.attribute_category          := NULL;
      l_po_headers_rec.attribute1                  := NULL;
      l_po_headers_rec.attribute2                  := NULL;
      l_po_headers_rec.attribute3                  := NULL;
      l_po_headers_rec.attribute4                  := NULL;
      l_po_headers_rec.attribute5                  := NULL;
      l_po_headers_rec.attribute6                  := NULL;
      l_po_headers_rec.attribute7                  := NULL;
      l_po_headers_rec.attribute8                  := NULL;
      l_po_headers_rec.attribute9                  := NULL;
      l_po_headers_rec.attribute10                 := NULL;
      l_po_headers_rec.attribute11                 := NULL;
      l_po_headers_rec.attribute12                 := NULL;
      l_po_headers_rec.attribute13                 := NULL;
      l_po_headers_rec.attribute14                 := NULL;
      l_po_headers_rec.attribute15                 := NULL;
      l_po_headers_rec.closed_code                 := NULL;
      l_po_headers_rec.ussgl_transaction_code      := NULL;
      l_po_headers_rec.government_context          := NULL;
      l_po_headers_rec.request_id                  := NULL;
      l_po_headers_rec.program_application_id      := NULL;
      l_po_headers_rec.program_id                  := NULL;
      l_po_headers_rec.program_update_date         := NULL;
      l_po_headers_rec.edi_processed_flag          := NULL;
      l_po_headers_rec.edi_processed_status        := NULL;
      l_po_headers_rec.global_attribute_category   := NULL;
      l_po_headers_rec.global_attribute1           := NULL;
      l_po_headers_rec.global_attribute2           := NULL;
      l_po_headers_rec.global_attribute3           := NULL;
      l_po_headers_rec.global_attribute4           := NULL;
      l_po_headers_rec.global_attribute5           := NULL;
      l_po_headers_rec.global_attribute6           := NULL;
      l_po_headers_rec.global_attribute7           := NULL;
      l_po_headers_rec.global_attribute8           := NULL;
      l_po_headers_rec.global_attribute9           := NULL;
      l_po_headers_rec.global_attribute10          := NULL;
      l_po_headers_rec.global_attribute11          := NULL;
      l_po_headers_rec.global_attribute12          := NULL;
      l_po_headers_rec.global_attribute13          := NULL;
      l_po_headers_rec.global_attribute14          := NULL;
      l_po_headers_rec.global_attribute15          := NULL;
      l_po_headers_rec.global_attribute16          := NULL;
      l_po_headers_rec.global_attribute17          := NULL;
      l_po_headers_rec.global_attribute18          := NULL;
      l_po_headers_rec.global_attribute19          := NULL;
      l_po_headers_rec.global_attribute20          := NULL;
      l_po_headers_rec.interface_source_code       := NULL;
      l_po_headers_rec.reference_num               := NULL;
      l_po_headers_rec.wf_item_type                := NULL;
      l_po_headers_rec.wf_item_key                 := NULL;
      l_po_headers_rec.mrc_rate_type               := NULL;
      l_po_headers_rec.mrc_rate_date               := NULL;
      l_po_headers_rec.mrc_rate                    := NULL;
      l_po_headers_rec.pcard_id                    := NULL;
      l_po_headers_rec.price_update_tolerance      := NULL;
      l_po_headers_rec.pay_on_code                 := NULL;
   END IF;

   p_po_headers_rec := l_po_headers_rec;

END Initialize_Header_Row;


PROCEDURE Initialize_Lines_Row(p_mode               IN     VARCHAR2,
                               p_po_header_id       IN     NUMBER,
                               p_org_id             IN     NUMBER,
                               p_cc_acct_lines_rec  IN     igc_cc_acct_lines%ROWTYPE,
                               p_po_lines_rec       IN OUT NOCOPY po_lines_all%ROWTYPE,
                               p_yr_start_date      IN     DATE,
                               p_yr_end_date        IN     DATE)
IS
   l_po_lines_rec po_lines_all%ROWTYPE;
   l_line_type_id po_line_types_tl.line_type_id%TYPE;
   E_CC_PO_LINE_TYPE EXCEPTION;

   -- M van der geest, added 18-OKT-2001
   l_icx_lang VARCHAR2(30);

   -- bug 4097669, start 1
   l_order_type_lookup_code       po_line_types_b.order_type_lookup_code%TYPE;
   l_purchase_basis               po_line_types_b.purchase_basis%TYPE;
   l_matching_basis               po_line_types_b.matching_basis%TYPE;
   -- bug 4097669, end 1

BEGIN
   /* Insert */
   IF (p_mode = 'I') THEN
      SELECT po_lines_s.NEXTVAL
      INTO l_po_lines_rec.po_line_id
      FROM dual;
   ELSE
     /* Update */
     l_po_lines_rec         := p_po_lines_rec;
   END IF;

   l_po_lines_rec.last_update_date           := p_cc_acct_lines_rec.last_update_date;
   l_po_lines_rec.last_updated_by            := p_cc_acct_lines_rec.last_updated_by;
   l_po_lines_rec.po_header_id               := p_po_header_id;

   BEGIN
      -- M van der Geest, added 18-Oct-2001
      fnd_profile.get('ICX_LANGUAGE',l_icx_lang);

      SELECT line_type_id
      INTO l_line_type_id
      FROM po_line_types_tl
      WHERE line_type = 'IGC CONTRACT COMMITMENT'
      AND LANGUAGE = DECODE(l_icx_lang,'AMERICAN','US',
                                       'DUTCH','NL','US');

      -- bug 4097669, start 2
      SELECT order_type_lookup_code,
             purchase_basis,
             matching_basis
      INTO   l_order_type_lookup_code,
             l_purchase_basis,
             l_matching_basis
      FROM po_line_types_b
      WHERE line_type_id = l_line_type_id;
      -- bug 4097669, end 2
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_message.set_name('IGC','IGC_CC_PO_LINE_TYPE');
         fnd_message.set_token('PO_LINE_TYPE','IGC CONTRACT COMMITMENT',TRUE);
         fnd_msg_pub.add;
         RAISE E_CC_PO_LINE_TYPE;
   END;

   l_po_lines_rec.line_type_id               := l_line_type_id;

   -- bug 4097669, start 3
   l_po_lines_rec.order_type_lookup_code     := l_order_type_lookup_code;
   l_po_lines_rec.purchase_basis             := l_purchase_basis;
   l_po_lines_rec.matching_basis             := l_matching_basis;
   -- bug 4097669, end 3

   l_po_lines_rec.line_num                   := p_cc_acct_lines_rec.cc_acct_line_num;
   l_po_lines_rec.last_update_login          := p_cc_acct_lines_rec.last_update_login;
   l_po_lines_rec.creation_date              := p_cc_acct_lines_rec.creation_date;
   l_po_lines_rec.created_by                 := p_cc_acct_lines_rec.created_by;

   l_po_lines_rec.taxable_flag               := p_cc_acct_lines_rec.cc_acct_taxable_flag ;

   l_po_lines_rec.tax_name         := p_cc_acct_lines_rec.tax_classif_code;

    /* tax_classif_code of igc_cc_acct_lines is assigned to tax_name of po_lines_all
   for r12 EBtax uptake for CC */

   /* Commented for bug 6472296 - r12 EBtax uptake for CC
   BEGIN
     SELECT apt.name,ccal.tax_id
     INTO l_po_lines_rec.tax_name, l_po_lines_rec.tax_code_id
     FROM igc_cc_acct_lines ccal,
          ap_tax_codes      apt
     WHERE ccal.cc_acct_line_id = p_cc_acct_lines_rec.cc_acct_line_id
     AND   apt.tax_id = ccal.tax_id;
   EXCEPTION -- 3326801
     WHEN NO_DATA_FOUND THEN
        -- Continue processing.
        NULL;
   END ;
   */

   /* Current year payment forecast only */

   SELECT SUM(cc_det_pf_entered_amt)
   INTO l_po_lines_rec.quantity
   FROM igc_cc_det_pf
   WHERE cc_acct_line_id = p_cc_acct_lines_rec.cc_acct_line_id AND
   /* Commented this part of code to fix bug 1576123 (cc_det_pf_date >= p_yr_start_date  AND */
   ( cc_det_pf_date <= p_yr_end_date)  ;

   l_po_lines_rec.org_id                      := p_org_id;
   l_po_lines_rec.project_id                  := p_cc_acct_lines_rec.project_id;
   l_po_lines_rec.task_id                     := p_cc_acct_lines_rec.task_id;

   IF (p_mode = 'I') THEN
      l_po_lines_rec.category_id                 := NULL;                             /* Bug 1390901 */
      l_po_lines_rec.item_description            := p_cc_acct_lines_rec.cc_acct_desc; /*Bug 1372370 */
      l_po_lines_rec.unit_meas_lookup_code       := 'Each';  /* Bug 3605536 */
      l_po_lines_rec.allow_price_override_flag   := 'N';
      l_po_lines_rec.list_price_per_unit         := 1;
      l_po_lines_rec.unit_price                  := 1;
      l_po_lines_rec.unordered_flag              := 'N';
      l_po_lines_rec.closed_flag                 := 'N';
      l_po_lines_rec.cancel_flag                 := 'N';
      l_po_lines_rec.price_type_lookup_code      := 'FIXED';
      l_po_lines_rec.capital_expense_flag        := 'N';
      l_po_lines_rec.negotiated_by_preparer_flag := 'N';

      l_po_lines_rec.item_id                    := NULL;
      l_po_lines_rec.item_revision              := NULL;
      l_po_lines_rec.quantity_committed         := NULL;
      l_po_lines_rec.committed_amount           := NULL;
      l_po_lines_rec.not_to_exceed_price        := NULL;
      l_po_lines_rec.un_number_id               := NULL;
      l_po_lines_rec.hazard_class_id            := NULL;
      l_po_lines_rec.note_to_vendor             := NULL;
      l_po_lines_rec.from_header_id             := NULL;
      l_po_lines_rec.from_line_id               := NULL;
      l_po_lines_rec.min_order_quantity         := NULL;
      l_po_lines_rec.max_order_quantity         := NULL;
      l_po_lines_rec.qty_rcv_tolerance          := NULL;
      l_po_lines_rec.over_tolerance_error_flag  := NULL;
      l_po_lines_rec.market_price               := NULL;
      l_po_lines_rec.user_hold_flag             := NULL;
      l_po_lines_rec.cancelled_by               := NULL;
      l_po_lines_rec.cancel_date                := NULL;
      l_po_lines_rec.cancel_reason              := NULL;
      l_po_lines_rec.firm_status_lookup_code    := NULL;
      l_po_lines_rec.firm_date                  := NULL;
      l_po_lines_rec.vendor_product_num         := NULL;
      l_po_lines_rec.contract_num               := NULL;
      l_po_lines_rec.type_1099                  := NULL;
      l_po_lines_rec.attribute_category         := NULL;
      l_po_lines_rec.attribute1                 := NULL;
      l_po_lines_rec.attribute2                 := NULL;
      l_po_lines_rec.attribute3                 := NULL;
      l_po_lines_rec.attribute4                 := NULL;
      l_po_lines_rec.attribute5                 := NULL;
      l_po_lines_rec.attribute6                 := NULL;
      l_po_lines_rec.attribute7                 := NULL;
      l_po_lines_rec.attribute8                 := NULL;
      l_po_lines_rec.attribute9                 := NULL;
      l_po_lines_rec.attribute10                := NULL;
      l_po_lines_rec.reference_num              := NULL;
      l_po_lines_rec.attribute11                := NULL;
      l_po_lines_rec.attribute12                := NULL;
      l_po_lines_rec.attribute13                := NULL;
      l_po_lines_rec.attribute14                := NULL;
      l_po_lines_rec.attribute15                := NULL;
      l_po_lines_rec.min_release_amount         := NULL;
      l_po_lines_rec.closed_code                := NULL;
      l_po_lines_rec.price_break_lookup_code    := NULL;
      l_po_lines_rec.ussgl_transaction_code     := NULL;
      l_po_lines_rec.government_context         := NULL;
      l_po_lines_rec.request_id                 := NULL;
      l_po_lines_rec.program_application_id     := NULL;
      l_po_lines_rec.program_id                 := NULL;
      l_po_lines_rec.program_update_date        := NULL;
      l_po_lines_rec.closed_date                := NULL;
      l_po_lines_rec.closed_reason              := NULL;
      l_po_lines_rec.closed_by                  := NULL;
      l_po_lines_rec.transaction_reason_code    := NULL;
      l_po_lines_rec.qc_grade                   := NULL;
      l_po_lines_rec.base_uom                   := NULL;
      l_po_lines_rec.base_qty                   := NULL;
      l_po_lines_rec.secondary_uom              := NULL;
      l_po_lines_rec.secondary_qty              := NULL;
      l_po_lines_rec.global_attribute_category  := NULL;
      l_po_lines_rec.global_attribute1          := NULL;
      l_po_lines_rec.global_attribute2          := NULL;
      l_po_lines_rec.global_attribute3          := NULL;
      l_po_lines_rec.global_attribute4          := NULL;
      l_po_lines_rec.global_attribute5          := NULL;
      l_po_lines_rec.global_attribute6          := NULL;
      l_po_lines_rec.global_attribute7          := NULL;
      l_po_lines_rec.global_attribute8          := NULL;
      l_po_lines_rec.global_attribute9          := NULL;
      l_po_lines_rec.global_attribute10         := NULL;
      l_po_lines_rec.global_attribute11         := NULL;
      l_po_lines_rec.global_attribute12         := NULL;
      l_po_lines_rec.global_attribute13         := NULL;
      l_po_lines_rec.global_attribute14         := NULL;
      l_po_lines_rec.global_attribute15         := NULL;
      l_po_lines_rec.global_attribute16         := NULL;
      l_po_lines_rec.global_attribute17         := NULL;
      l_po_lines_rec.global_attribute18         := NULL;
      l_po_lines_rec.global_attribute19         := NULL;
      l_po_lines_rec.global_attribute20         := NULL;
      l_po_lines_rec.line_reference_num         := NULL;
      l_po_lines_rec.expiration_date            := NULL;
      l_po_lines_rec.base_unit_price            := 1; /* Bug 6341012 */
   END IF;

   p_po_lines_rec := l_po_lines_rec;

END Initialize_Lines_Row;


PROCEDURE Initialize_Line_Locs_Row(p_mode             IN VARCHAR2,
                                   p_encumbrance_on   IN VARCHAR2,
                                   p_po_headers_rec   IN po_headers_all%ROWTYPE,
                                   p_po_lines_rec     IN po_lines_all%ROWTYPE,
                                   p_po_line_locs_rec IN OUT NOCOPY po_line_locations_all%ROWTYPE)
IS
   l_po_line_locs_rec po_line_locations_all%ROWTYPE;

BEGIN
   /* Insert */
   IF (p_mode = 'I') THEN
      SELECT po_line_locations_s.nextval
      INTO l_po_line_locs_rec.line_location_id
      FROM DUAL;
   ELSE
      l_po_line_locs_rec := p_po_line_locs_rec;
   END IF;

   l_po_line_locs_rec.po_header_id                   := p_po_lines_rec.po_header_id ;
   l_po_line_locs_rec.po_line_id                     := p_po_lines_rec.po_line_id ;
   l_po_line_locs_rec.shipment_num                   := p_po_lines_rec.line_num;
   l_po_line_locs_rec.last_update_date               := p_po_lines_rec.last_update_date;
   l_po_line_locs_rec.last_updated_by                := p_po_lines_rec.last_updated_by;
   l_po_line_locs_rec.last_update_login              := p_po_lines_rec.last_update_login;
   l_po_line_locs_rec.creation_date                  := p_po_lines_rec.creation_date;
   l_po_line_locs_rec.created_by                     := p_po_lines_rec.created_by;
   l_po_line_locs_rec.quantity                       := p_po_lines_rec.quantity;
   l_po_line_locs_rec.ship_to_location_id            := p_po_headers_rec.ship_to_location_id;
   l_po_line_locs_rec.tax_code_id                    := p_po_lines_rec.tax_code_id;
   l_po_line_locs_rec.taxable_flag                   := p_po_lines_rec.taxable_flag;
   l_po_line_locs_rec.tax_name                       := p_po_lines_rec.tax_name ;
   l_po_line_locs_rec.terms_id                       := p_po_headers_rec.terms_id;
   l_po_line_locs_rec.approved_flag                  := p_po_headers_rec.approved_flag;
   l_po_line_locs_rec.approved_date                  := p_po_headers_rec.approved_date;
   l_po_line_locs_rec.ship_to_organization_id        := p_po_headers_rec.org_id;
   l_po_line_locs_rec.org_id                         := p_po_headers_rec.org_id;


   IF (p_mode = 'I') THEN
      l_po_line_locs_rec.quantity_received              := 0;
      l_po_line_locs_rec.quantity_accepted              := 0;
      l_po_line_locs_rec.quantity_rejected              := 0;
      l_po_line_locs_rec.quantity_billed                := 0;
      l_po_line_locs_rec.quantity_cancelled             := 0;
      l_po_line_locs_rec.price_override                 := 1;
   END IF;

   IF (p_encumbrance_on = FND_API.G_TRUE) THEN
      l_po_line_locs_rec.encumbered_flag            := 'Y';
   ELSE
      l_po_line_locs_rec.encumbered_flag            := 'N';
   END IF;

   IF (p_mode = 'I') THEN
      l_po_line_locs_rec.cancel_flag                    := 'N';
      l_po_line_locs_rec.firm_status_lookup_code        := 'N';
      l_po_line_locs_rec.inspection_required_flag       := 'N';
      l_po_line_locs_rec.receipt_required_flag          := 'N';
      l_po_line_locs_rec.qty_rcv_tolerance              := 0;
      l_po_line_locs_rec.qty_rcv_exception_code         := 'WARNING';
      l_po_line_locs_rec.enforce_ship_to_location_code  := 'WARNING';
      l_po_line_locs_rec.allow_substitute_receipts_flag := 'Y';
      l_po_line_locs_rec.days_early_receipt_allowed     := 0;
      l_po_line_locs_rec.days_late_receipt_allowed      := 99;
      l_po_line_locs_rec.receipt_days_exception_code    := 'WARNING';
      l_po_line_locs_rec.invoice_close_tolerance        := 0;
      l_po_line_locs_rec.receive_close_tolerance        := 0;
      l_po_line_locs_rec.shipment_type                  := 'STANDARD';
      l_po_line_locs_rec.closed_code                    := 'OPEN';
      l_po_line_locs_rec.receiving_routing_id           := 2;
      l_po_line_locs_rec.accrue_on_receipt_flag         := 'N';
      l_po_line_locs_rec.tax_user_override_flag         := 'N';
      l_po_line_locs_rec.match_option                   := 'P';
      l_po_line_locs_rec.calculate_tax_flag             := 'N';

      l_po_line_locs_rec.unit_meas_lookup_code          := 'Each';  /* Bug 6341012 */
      l_po_line_locs_rec.po_release_id                  := NULL;
      l_po_line_locs_rec.ship_via_lookup_code           := NULL;
      l_po_line_locs_rec.need_by_date                   := NULL;
      l_po_line_locs_rec.promised_date                  := NULL;
      l_po_line_locs_rec.last_accept_date               := NULL;

      l_po_line_locs_rec.encumbered_date                := NULL;
      l_po_line_locs_rec.unencumbered_quantity          := NULL;
      l_po_line_locs_rec.fob_lookup_code                := NULL;
      l_po_line_locs_rec.freight_terms_lookup_code      := NULL;
      l_po_line_locs_rec.estimated_tax_amount           := NULL;
      l_po_line_locs_rec.from_header_id                 := NULL;
      l_po_line_locs_rec.from_line_id                   := NULL;
      l_po_line_locs_rec.from_line_location_id          := NULL;
      l_po_line_locs_rec.start_date                     := NULL;
      l_po_line_locs_rec.end_date                       := NULL;
      l_po_line_locs_rec.lead_time                      := NULL;
      l_po_line_locs_rec.lead_time_unit                 := NULL;
      l_po_line_locs_rec.price_discount                 := NULL;
      l_po_line_locs_rec.closed_flag                    := NULL;
      l_po_line_locs_rec.cancelled_by                   := NULL;
      l_po_line_locs_rec.cancel_date                    := NULL;
      l_po_line_locs_rec.cancel_reason                  := NULL;
      l_po_line_locs_rec.firm_date                      := NULL;
      l_po_line_locs_rec.attribute_category             := NULL;
      l_po_line_locs_rec.attribute1                     := NULL;
      l_po_line_locs_rec.attribute2                     := NULL;
      l_po_line_locs_rec.attribute3                     := NULL;
      l_po_line_locs_rec.attribute4                     := NULL;
      l_po_line_locs_rec.attribute5                     := NULL;
      l_po_line_locs_rec.attribute6                     := NULL;
      l_po_line_locs_rec.attribute7                     := NULL;
      l_po_line_locs_rec.attribute8                     := NULL;
      l_po_line_locs_rec.attribute9                     := NULL;
      l_po_line_locs_rec.attribute10                    := NULL;
      l_po_line_locs_rec.unit_of_measure_class          := NULL;
      l_po_line_locs_rec.encumber_now                   := NULL;
      l_po_line_locs_rec.attribute11                    := NULL;
      l_po_line_locs_rec.attribute12                    := NULL;
      l_po_line_locs_rec.attribute13                    := NULL;
      l_po_line_locs_rec.attribute14                    := NULL;
      l_po_line_locs_rec.attribute15                    := NULL;
      l_po_line_locs_rec.source_shipment_id             := NULL;
      l_po_line_locs_rec.request_id                     := NULL;
      l_po_line_locs_rec.program_application_id         := NULL;
      l_po_line_locs_rec.program_id                     := NULL;
      l_po_line_locs_rec.program_update_date            := NULL;
      l_po_line_locs_rec.ussgl_transaction_code         := NULL;
      l_po_line_locs_rec.government_context             := NULL;
      l_po_line_locs_rec.closed_reason                  := NULL;
      l_po_line_locs_rec.closed_date                    := NULL;
      l_po_line_locs_rec.closed_by                      := NULL;
      l_po_line_locs_rec.global_attribute1              := NULL;
      l_po_line_locs_rec.global_attribute2              := NULL;
      l_po_line_locs_rec.global_attribute3              := NULL;
      l_po_line_locs_rec.global_attribute4              := NULL;
      l_po_line_locs_rec.global_attribute5              := NULL;
      l_po_line_locs_rec.global_attribute6              := NULL;
      l_po_line_locs_rec.global_attribute7              := NULL;
      l_po_line_locs_rec.global_attribute8              := NULL;
      l_po_line_locs_rec.global_attribute9              := NULL;
      l_po_line_locs_rec.global_attribute10             := NULL;
      l_po_line_locs_rec.global_attribute11             := NULL;
      l_po_line_locs_rec.global_attribute12             := NULL;
      l_po_line_locs_rec.global_attribute13             := NULL;
      l_po_line_locs_rec.global_attribute14             := NULL;
      l_po_line_locs_rec.global_attribute15             := NULL;
      l_po_line_locs_rec.global_attribute16             := NULL;
      l_po_line_locs_rec.global_attribute17             := NULL;
      l_po_line_locs_rec.global_attribute18             := NULL;
      l_po_line_locs_rec.global_attribute19             := NULL;
      l_po_line_locs_rec.global_attribute20             := NULL;
      l_po_line_locs_rec.global_attribute_category      := NULL;
      l_po_line_locs_rec.quantity_shipped               := NULL;
      l_po_line_locs_rec.country_of_origin_code         := NULL;
      l_po_line_locs_rec.change_promised_date_reason    := NULL;

      l_po_line_locs_rec.matching_Basis    := p_po_lines_rec.matching_basis;  /* Bug 6341012 */

     /* Bug 7110860  Outsourced Assembly value is 1 for Shikyu and 2 for Non- Shikyu, For IGC it should be 2*/
      l_po_line_locs_rec.outsourced_assembly := 2;
   END IF;

     IF (p_mode = 'U') THEN
       /* Bug 7110860  Outsourced Assembly value is 1 for Shikyu and 2 for Non- Shikyu, For IGC it should be 2*/
        l_po_line_locs_rec.outsourced_assembly := 2;
     END IF;

   p_po_line_locs_rec := l_po_line_locs_rec;

END  Initialize_Line_Locs_Row;


PROCEDURE Initialize_Distributions_Row(p_mode                   IN       VARCHAR2,
                                       p_encumbrance_on         IN       VARCHAR2,
                                       p_cc_headers_rec         IN       igc_cc_headers%ROWTYPE,
                                       p_cc_acct_lines_rec      IN       igc_cc_acct_lines%ROWTYPE,
                                       p_cc_pmt_fcst_rec        IN       igc_cc_det_pf%ROWTYPE,
                                       p_po_line_locs_rec       IN       po_line_locations_all%ROWTYPE,
                                       p_po_dist_rec            IN OUT NOCOPY   po_distributions_all%ROWTYPE )
IS
   l_po_dist_rec po_distributions_all%ROWTYPE;
   E_CC_GL_PERIOD EXCEPTION;
BEGIN
   IF (p_mode = 'I') THEN
      SELECT po_distributions_s.nextval
      INTO l_po_dist_rec.po_distribution_id
      FROM DUAL;
   ELSE
      l_po_dist_rec := p_po_dist_rec ;                                         /* CC */
   END IF;

   l_po_dist_rec.po_header_id                := p_po_line_locs_rec.po_header_id;
   l_po_dist_rec.po_line_id                  := p_po_line_locs_rec.po_line_id;
   l_po_dist_rec.line_location_id            := p_po_line_locs_rec.line_location_id;
   l_po_dist_rec.distribution_num            := p_cc_pmt_fcst_rec.cc_det_pf_line_num;
   -- Added for PRC.FP.J, 3173178
   -- PO Standalone patch 3205071 is a pre-req for this change
   l_po_dist_rec.distribution_type           := 'STANDARD';

   IF (p_encumbrance_on = FND_API.G_TRUE) THEN
      l_po_dist_rec.encumbered_flag             := p_po_line_locs_rec.encumbered_flag;
      l_po_dist_rec.gl_encumbered_date          := p_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date;
      l_po_dist_rec.encumbered_amount           := p_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_amt;
      /* Removed the hard coded reference to period type of CC Month to fix bug 1427486*/
      BEGIN
         SELECT period_name
         INTO l_po_dist_rec.gl_encumbered_period_name
         FROM   gl_periods gp, gl_sets_of_books gb
         WHERE gb.set_of_books_id          = p_cc_headers_rec.set_of_books_id AND
               gp.period_set_name          = gb.period_set_name AND
               /* Begin Fix for bug 1569257 */
               gp.adjustment_period_flag   = 'N' AND
               /* End Fix for bug 1569257  */
               gb.accounted_period_type    = gp.period_type AND
               ( (gp.start_date <= TRUNC(l_po_dist_rec.gl_encumbered_date) ) AND
                          (gp.end_date   >= TRUNC(l_po_dist_rec.gl_encumbered_date) ) );

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('IGC','IGC_CC_GL_PERIOD_NOT_FOUND');
             fnd_message.set_token('PF_LINE_NUM',p_cc_pmt_fcst_rec.cc_det_pf_line_num,TRUE);
             fnd_msg_pub.add;
            RAISE E_CC_GL_PERIOD;
      END;
   ELSE
      l_po_dist_rec.encumbered_flag             := 'N';
      l_po_dist_rec.gl_encumbered_date          := NULL;
      l_po_dist_rec.encumbered_amount           := NULL;
      l_po_dist_rec.gl_encumbered_period_name   := NULL;
   END IF;

   l_po_dist_rec.rate_date                   := p_cc_headers_rec.conversion_date;
   l_po_dist_rec.rate                        := p_cc_headers_rec.conversion_rate;
   l_po_dist_rec.org_id                      := p_cc_headers_rec.org_id;
   l_po_dist_rec.set_of_books_id             := p_cc_headers_rec.set_of_books_id;
   l_po_dist_rec.quantity_ordered            := p_cc_pmt_fcst_rec.cc_det_pf_entered_amt;
   l_po_dist_rec.last_update_login           := p_cc_pmt_fcst_rec.last_update_login;
   l_po_dist_rec.last_update_date            := p_cc_pmt_fcst_rec.last_update_date;
   l_po_dist_rec.last_updated_by             := p_cc_pmt_fcst_rec.last_updated_by;
   l_po_dist_rec.creation_date               := p_cc_pmt_fcst_rec.creation_date;
   l_po_dist_rec.created_by                  := p_cc_pmt_fcst_rec.created_by;
   l_po_dist_rec.variance_account_id         := NULL;
   l_po_dist_rec.accrual_account_id          := NULL;
   l_po_dist_rec.code_combination_id         := p_cc_acct_lines_rec.cc_charge_code_combination_id;
   l_po_dist_rec.budget_account_id           := p_cc_acct_lines_rec.cc_budget_code_combination_id;

   /*  Begin Project accounting related columns */

   l_po_dist_rec.project_id                   := p_cc_acct_lines_rec.project_id;
   l_po_dist_rec.task_id                      := p_cc_acct_lines_rec.task_id;
   l_po_dist_rec.expenditure_type             := p_cc_acct_lines_rec.expenditure_type;
   l_po_dist_rec.expenditure_organization_id  := p_cc_acct_lines_rec.expenditure_org_id;
   l_po_dist_rec.expenditure_item_date        := p_cc_acct_lines_rec.expenditure_item_date;

   IF (l_po_dist_rec.project_id IS NOT NULL) THEN
       l_po_dist_rec.project_accounting_context   := 'Y';
   ELSE
       l_po_dist_rec.project_accounting_context   := 'N';
   END IF;

   /* End Project accounting related columns */

   IF (p_mode = 'I') THEN
      l_po_dist_rec.quantity_delivered           := 0;
      l_po_dist_rec.quantity_billed              := 0;
      l_po_dist_rec.quantity_cancelled           := 0;
      l_po_dist_rec.amount_billed                := 0;
      l_po_dist_rec.destination_type_code        := 'EXPENSE';
      l_po_dist_rec.prevent_encumbrance_flag     := 'N';
      l_po_dist_rec.destination_context          := 'EXPENSE';
      l_po_dist_rec.accrue_on_receipt_flag       := 'N';
      l_po_dist_rec.tax_recovery_override_flag   := 'N';

      l_po_dist_rec.po_release_id                := NULL;
      l_po_dist_rec.req_header_reference_num     := p_cc_headers_rec.cc_header_id;
      l_po_dist_rec.req_line_reference_num       := p_cc_pmt_fcst_rec.cc_det_pf_line_id;
      l_po_dist_rec.req_distribution_id          := NULL;
      l_po_dist_rec.deliver_to_location_id       := NULL;
      l_po_dist_rec.deliver_to_person_id         := NULL;
      l_po_dist_rec.accrued_flag                 := NULL;
      l_po_dist_rec.unencumbered_quantity        := NULL;
      l_po_dist_rec.unencumbered_amount          := NULL;
      l_po_dist_rec.failed_funds_lookup_code     := NULL;
      l_po_dist_rec.gl_cancelled_date            := NULL;
      l_po_dist_rec.destination_organization_id  := NULL;
      l_po_dist_rec.destination_subinventory     := NULL;
      l_po_dist_rec.attribute_category           := NULL;
      l_po_dist_rec.attribute1                   := NULL;
      l_po_dist_rec.attribute2                   := NULL;
      l_po_dist_rec.attribute3                   := NULL;
      l_po_dist_rec.attribute4                   := NULL;
      l_po_dist_rec.attribute5                   := NULL;
      l_po_dist_rec.attribute6                   := NULL;
      l_po_dist_rec.attribute7                   := NULL;
      l_po_dist_rec.attribute8                   := NULL;
      l_po_dist_rec.attribute9                   := NULL;
      l_po_dist_rec.attribute10                  := NULL;
      l_po_dist_rec.attribute11                  := NULL;
      l_po_dist_rec.attribute12                  := NULL;
      l_po_dist_rec.attribute13                  := NULL;
      l_po_dist_rec.attribute14                  := NULL;
      l_po_dist_rec.attribute15                  := NULL;
      l_po_dist_rec.wip_entity_id                := NULL;
      l_po_dist_rec.wip_operation_seq_num        := NULL;
      l_po_dist_rec.wip_resource_seq_num         := NULL;
      l_po_dist_rec.wip_repetitive_schedule_id   := NULL;
      l_po_dist_rec.wip_line_id                  := NULL;
      l_po_dist_rec.bom_resource_id              := NULL;
      l_po_dist_rec.ussgl_transaction_code       := NULL;
      l_po_dist_rec.government_context           := NULL;
      l_po_dist_rec.source_distribution_id       := NULL;
      l_po_dist_rec.request_id                   := NULL;
      l_po_dist_rec.program_application_id       := NULL;
      l_po_dist_rec.program_id                   := NULL;
      l_po_dist_rec.program_update_date          := NULL;
      l_po_dist_rec.gl_closed_date               := NULL;
      l_po_dist_rec.kanban_card_id               := NULL;
      l_po_dist_rec.award_id                     := NULL;
      l_po_dist_rec.mrc_rate_date                := NULL;
      l_po_dist_rec.mrc_rate                     := NULL;
      l_po_dist_rec.mrc_encumbered_amount        := NULL;
      l_po_dist_rec.mrc_unencumbered_amount      := NULL;
      l_po_dist_rec.end_item_unit_number         := NULL;
      l_po_dist_rec.recoverable_tax              := NULL;
      l_po_dist_rec.nonrecoverable_tax           := NULL;
      l_po_dist_rec.recovery_rate                := NULL;
   END IF;


   p_po_dist_rec := l_po_dist_rec;

END  Initialize_Distributions_Row;

/*-------------------------------------------------------------------------*/

/*=======================================================================+
 |                       PROCEDURE Update_PO_Approved_Flag               |
 +=======================================================================*/

PROCEDURE Update_PO_Approved_Flag
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  p_cc_header_id                  IN       NUMBER
)
IS

  l_api_name                      CONSTANT VARCHAR2(30)   := 'Update_PO_Approved_Flag';
  l_api_version                   CONSTANT NUMBER         :=  1.0;

  l_cc_headers_rec                igc_cc_headers%ROWTYPE;
  l_cc_acct_lines_rec             igc_cc_acct_lines%ROWTYPE;

  l_po_headers_rec                po_headers_all%ROWTYPE;
  l_po_lines_rec                  po_lines_all%ROWTYPE;
  l_po_line_locs_rec              po_line_locations_all%ROWTYPE;

  l_po_found                      BOOLEAN;
  l_new_account_line              BOOLEAN;
  l_encumbrance_on                VARCHAR2(1);

  l_msg_data                      VARCHAR2(1000);
  l_error_message                 VARCHAR2(1000);
  l_msg_count                     NUMBER;
  l_return_status                 VARCHAR2(1);

  e_cc_not_found                  EXCEPTION;
  e_po_not_found                  EXCEPTION;
  e_cc_type                       EXCEPTION;
  e_cc_state                      EXCEPTION;
  e_line_locations                EXCEPTION;
  e_internal_error                EXCEPTION;
        e_unable_to_open_po             EXCEPTION;

  l_start_date                    gl_periods.start_date%TYPE;
  l_end_date                      gl_periods.end_date%TYPE;
        l_curr_year_pf_lines            NUMBER;

  /* Start Date and End Date of current fiscal year for set of books
           indicated by p_sob_id */

        CURSOR c_fiscal_year_dates(p_sob_id NUMBER)
        IS
        SELECT MIN(start_date) start_date, MAX(end_date) end_date
        FROM    GL_PERIODS GP,
                GL_SETS_OF_BOOKS GB
        WHERE
              GP.period_set_name          = GB.period_set_name       AND
              GP.period_type              = GB.accounted_period_type AND
              GB.set_of_books_id          = p_sob_id                 AND
              TO_CHAR(start_date, 'YYYY') = to_char(sysdate, 'YYYY') AND
              TO_CHAR(end_date, 'YYYY')   = to_char(sysdate, 'YYYY') AND
              GP.adjustment_period_flag   = 'N';

  /* Contract Commitment account lines  */

  CURSOR c_account_lines(t_cc_header_id NUMBER) IS
          SELECT *
          FROM  igc_cc_acct_lines
          WHERE cc_header_id = t_cc_header_id;

BEGIN
-- Bug 3605536 GSCC Warnings fixed

  l_po_found            := FALSE;
  l_new_account_line    := FALSE;
  l_encumbrance_on      := FND_API.G_TRUE;
        l_curr_year_pf_lines  :=  0;

  SAVEPOINT Update_PO_Approved_Flag;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_msg_data := NULL;
  l_msg_count := 0;

      /* Check whether Contract Commitment exists or not */

  BEGIN

    SELECT * INTO l_cc_headers_rec
          FROM igc_cc_headers
    WHERE cc_header_id = p_cc_header_id;

  EXCEPTION
    WHEN no_data_found
    THEN
      fnd_message.set_name('IGC','IGC_CC_NOT_FOUND');
      fnd_message.set_token('CC_NUM',to_char(p_cc_header_id),TRUE);
      fnd_msg_pub.add;
      RAISE E_CC_NOT_FOUND;
  END;

  IF ( (l_cc_headers_rec.cc_type IS NOT NULL) AND
             (l_cc_headers_rec.cc_type = 'C') )
  THEN
    fnd_message.set_name('IGC','IGC_CC_INVALID_CC_TYPE');
    fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
    fnd_msg_pub.add;
    RAISE e_cc_type;
  END IF;

  IF ((l_cc_headers_rec.cc_state IS NOT NULL) AND
            ((l_cc_headers_rec.cc_state = 'CL') OR (l_cc_headers_rec.cc_state = 'PR')))
  THEN
    fnd_message.set_name('IGC','IGC_CC_INVALID_CC_STATE');
    fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
    fnd_msg_pub.add;
    RAISE e_cc_state;
  END IF;

  /* Begin fix for bug 1715221 */
        /* Get the start date and end date of current fiscal year */
        OPEN c_fiscal_year_dates(l_cc_headers_rec.set_of_books_id);
        FETCH c_fiscal_year_dates INTO l_start_date, l_end_date;
        CLOSE c_fiscal_year_dates;

  /* Check whether current fiscal year payment forecast lines exist in CC */

  BEGIN
    l_curr_year_pf_lines := 0;

    SELECT count(cc_det_pf_line_id)
          INTO   l_curr_year_pf_lines
    FROM   igc_cc_det_pf a, igc_cc_acct_lines b, igc_cc_headers c
                WHERE
                  NVL(a.cc_det_pf_date,l_end_date + 1) <= l_end_date  AND
                        a.cc_acct_line_id = b.cc_acct_line_id AND
                        b.cc_header_id = c.cc_header_id AND
                        c.cc_header_id = p_cc_header_id;

  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
         l_curr_year_pf_lines := 0;
  END;

  IF (l_curr_year_pf_lines = 0)
  THEN
    fnd_message.set_name('IGC','IGC_CC_UNABLE_TO_OPEN_PO');
    fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
    fnd_msg_pub.add;
    RAISE e_unable_to_open_po;
  ELSIF (l_curr_year_pf_lines > 0)
  THEN
          /* Check whether Contract Commitment is already populated in PO Tables */
          l_po_found := TRUE;

    BEGIN

            SELECT * INTO l_po_headers_rec
                  FROM PO_HEADERS_ALL
            WHERE   segment1 = l_cc_headers_rec.cc_num AND
                    type_lookup_code = 'STANDARD' AND
            org_id = l_cc_headers_rec.org_id;
    EXCEPTION
      WHEN no_data_found
                  THEN
        fnd_message.set_name('IGC','IGC_CC_PO_NOT_FOUND');
        fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
        fnd_msg_pub.add;
                           RAISE e_po_not_found;
          END;
  END IF;
  /* End fix for bug 1715221 */

        /* Check whether encumbrance is turned on */

  IGC_CC_BUDGETARY_CTRL_PKG.Check_Budgetary_Ctrl_On
  (
    1.0,
    FND_API.G_FALSE,
    FND_API.G_VALID_LEVEL_FULL,
    l_return_status,
    l_msg_count,
    l_msg_data ,
    l_cc_headers_rec.org_id,
    l_cc_headers_rec.set_of_books_id,
    l_cc_headers_rec.cc_state,
    l_encumbrance_on
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    RAISE e_internal_error;
  END IF;

  /* Corresponding PO exists */

  IF (l_po_found)
        THEN

    /* Contract Commitment in Confirmed State and approved
       and document control status has changed from ENTERED->OPENED, OPENED->ON HOLD,
       OPENED->CLOSED, CLOSED->OPENED */

    IF (l_cc_headers_rec.cc_apprvl_status = 'AP') AND
       (l_cc_headers_rec.cc_state = 'CM') AND
                   (
      ((l_encumbrance_on = FND_API.G_TRUE) AND (l_cc_headers_rec.cc_encmbrnc_status = 'C')) OR
                        ((l_encumbrance_on = FND_API.G_FALSE) AND (l_cc_headers_rec.cc_encmbrnc_status = 'N'))
                    )
    THEN
                  IF (l_cc_headers_rec.cc_ctrl_status = 'O')
      THEN
        l_po_headers_rec.authorization_status        := 'APPROVED';
        l_po_headers_rec.approved_flag               := 'Y';
        l_po_headers_rec.approved_date               := sysdate;
      ELSE
                    l_po_headers_rec.authorization_status        := NULL;
                    l_po_headers_rec.approved_flag               := 'N';
                          l_po_headers_rec.approved_date               := NULL;
                  END IF;
    END IF;

    /* Contract Commitment has been Changed in Confirmed state
               and approval status is Requires Reapproval*/

    IF (l_cc_headers_rec.cc_apprvl_status <> 'AP')  AND
       (l_cc_headers_rec.cc_state = 'CM')
    THEN
                  l_po_headers_rec.authorization_status        := NULL;
            l_po_headers_rec.approved_flag               := 'N';
                        l_po_headers_rec.approved_date               := NULL;
    END IF;

    /* Contract Commitment in Complete state*/
    IF (l_cc_headers_rec.cc_state = 'CT')
    THEN
                  l_po_headers_rec.authorization_status        := NULL;
            l_po_headers_rec.approved_flag               := 'N';
                        l_po_headers_rec.approved_date               := NULL;
    END IF;

                IGC_CC_PO_HEADERS_ALL_PVT.Update_Row(1.0,
                 FND_API.G_FALSE,
                 FND_API.G_FALSE,
                                                     FND_API.G_VALID_LEVEL_NONE,
                 l_return_status,
                                                     l_msg_count,
                 l_msg_data,
                       l_po_headers_rec);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE e_internal_error;
    END IF;

                OPEN c_account_lines(p_cc_header_id);

          LOOP

            FETCH c_account_lines INTO l_cc_acct_lines_rec;

          EXIT WHEN c_account_lines%NOTFOUND;

      /* Check whether it is a new account line */

                        l_new_account_line := FALSE;

      BEGIN

                              SELECT * INTO l_po_lines_rec
                              FROM   po_lines_all pol
              WHERE
                                        pol.po_header_id = l_po_headers_rec.po_header_id AND
                      pol.line_num = l_cc_acct_lines_rec.cc_acct_line_num;
                        EXCEPTION
        WHEN NO_DATA_FOUND
                                THEN
                l_new_account_line := TRUE;
      END;

            IF (l_new_account_line = FALSE)
      THEN
        BEGIN

                                SELECT * INTO l_po_line_locs_rec
                                FROM   po_line_locations_all pll
                WHERE
                                          pll.po_header_id = l_po_headers_rec.po_header_id AND
                        pll.po_line_id   = l_po_lines_rec.po_line_id;
                          EXCEPTION
          WHEN NO_DATA_FOUND
                                   THEN
            RAISE e_line_locations;
        END;
      END IF;

      /* Existing account line */
       IF ( NOT l_new_account_line)
       THEN
            l_po_line_locs_rec.approved_flag   := l_po_headers_rec.approved_flag;
                  l_po_line_locs_rec.approved_date   := l_po_headers_rec.approved_date;
                   /* Bug 7110860  Outsourced Assembly value is 1 for Shikyu and 2 for Non- Shikyu, For IGC it should be 2*/
                    IF (l_po_line_locs_rec.outsourced_assembly IS NULL) THEN
                       l_po_line_locs_rec.outsourced_assembly := 2;
                    END IF;

                                  IGC_CC_PO_LINE_LOCS_ALL_PVT.Update_Row(1.0,
                                     FND_API.G_FALSE,
                                     FND_API.G_FALSE,
                                                                         FND_API.G_VALID_LEVEL_NONE,
                                     l_return_status,
                                                                         l_msg_count,
                                     l_msg_data,
                                           l_po_line_locs_rec);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
          RAISE e_internal_error;
        END IF;

                         END IF;
      /* Existing account line */

                END LOOP;
    /* Account_Lines_Cursor */

                CLOSE c_account_lines;

         END IF; /* PO Exisists */

   IF FND_API.To_Boolean(p_commit)
   THEN
    COMMIT WORK;
   END IF;

EXCEPTION

  WHEN E_INTERNAL_ERROR
  THEN
                ROLLBACK TO Update_PO_Approved_Flag;
    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
                ROLLBACK TO Update_PO_Approved_Flag;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data );

  WHEN  E_CC_NOT_FOUND OR E_CC_STATE OR E_CC_TYPE OR E_PO_NOT_FOUND OR E_LINE_LOCATIONS OR E_UNABLE_TO_OPEN_PO
  THEN
                ROLLBACK TO Update_PO_Approved_Flag;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

  WHEN OTHERS
  THEN
                ROLLBACK TO Update_PO_Approved_Flag;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
END Update_PO_Approved_Flag;

/*=======================================================================+
 |                       PROCEDURE Convert_CC_To_PO                      |
 +=======================================================================*/

PROCEDURE Convert_CC_To_PO
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  p_cc_header_id                  IN       NUMBER
)
IS

  l_api_name                      CONSTANT VARCHAR2(30)   := 'Convert_CC_To_PO';
  l_api_version                   CONSTANT NUMBER         :=  1.0;

  l_cc_headers_rec                igc_cc_headers%ROWTYPE;
  l_cc_acct_lines_rec             igc_cc_acct_lines%ROWTYPE;
  l_cc_pmt_fcst_rec               igc_cc_det_pf%ROWTYPE;

  l_po_headers_rec                po_headers_all%ROWTYPE;
  l_po_lines_rec                  po_lines_all%ROWTYPE;
  l_po_line_locs_rec              po_line_locations_all%ROWTYPE;
  l_po_dist_rec                   po_distributions_all%ROWTYPE;

  l_encumbered_period_name        gl_periods.period_name%TYPE;

  l_new_account_line              BOOLEAN;

  l_new_payment_forecast_line     BOOLEAN;

  l_po_found                      BOOLEAN;
  l_encumbrance_on                VARCHAR2(1);

  l_msg_data                      VARCHAR2(1000);
  l_error_message                 VARCHAR2(1000);
  l_msg_count                     NUMBER;
  l_return_status                 VARCHAR2(1);


  e_cc_not_found                  EXCEPTION;
  e_cc_type                       EXCEPTION;
  e_cc_state                      EXCEPTION;
  e_cc_not_encumbered             EXCEPTION;
  e_cc_not_approved               EXCEPTION;
  e_line_locations                EXCEPTION;
  e_internal_error                EXCEPTION;


  l_start_date                    gl_periods.start_date%TYPE;
  l_end_date                      gl_periods.end_date%TYPE;
        l_curr_year_pf_lines            NUMBER;

  /* Start Date and End Date of current fiscal year for set of books
           indicated by p_sob_id */

        CURSOR c_fiscal_year_dates(p_sob_id NUMBER)
        IS
        SELECT MIN(start_date) start_date, MAX(end_date) end_date
        FROM    GL_PERIODS GP,
                GL_SETS_OF_BOOKS GB
        WHERE
              GP.period_set_name          = GB.period_set_name       AND
              GP.period_type              = GB.accounted_period_type AND
              GB.set_of_books_id          = p_sob_id                 AND
              TO_CHAR(start_date, 'YYYY') = to_char(sysdate, 'YYYY') AND
              TO_CHAR(end_date, 'YYYY')   = to_char(sysdate, 'YYYY') AND
              GP.adjustment_period_flag   = 'N';

  /* Contract Commitment detail payment forecast  */
  CURSOR c_payment_forecast(t_cc_acct_line_id NUMBER) IS
  SELECT *
  FROM igc_cc_det_pf
  WHERE cc_acct_line_id =  t_cc_acct_line_id;

  /* Contract Commitment account lines  */

  CURSOR c_account_lines(t_cc_header_id NUMBER) IS
  SELECT *
        FROM  igc_cc_acct_lines ccac
        WHERE ccac.cc_header_id = t_cc_header_id;


BEGIN

--Bug 3605536 GSCC Warnings fixed
  l_encumbered_period_name    := 'MAY-01';
        l_curr_year_pf_lines        :=  0;
  l_encumbrance_on            := FND_API.G_FALSE;
  l_new_account_line          := FALSE;
  l_new_payment_forecast_line := FALSE;
  l_po_found                  := FALSE;

  SAVEPOINT Convert_CC_To_PO;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_msg_data := NULL;
  l_msg_count := 0;


      /* Check whether Contract Commitment exists or not */

  BEGIN

    SELECT * INTO l_cc_headers_rec
          FROM igc_cc_headers
    WHERE cc_header_id = p_cc_header_id;

  EXCEPTION
    WHEN no_data_found
    THEN
      fnd_message.set_name('IGC','IGC_CC_NOT_FOUND');
      fnd_message.set_token('CC_NUM',to_char(p_cc_header_id),TRUE);
      fnd_msg_pub.add;
      RAISE E_CC_NOT_FOUND;
  END;

  IF ( (l_cc_headers_rec.cc_type IS NOT NULL) AND
             (l_cc_headers_rec.cc_type = 'C') )
  THEN
    fnd_message.set_name('IGC','IGC_CC_INVALID_CC_TYPE');
    fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
    fnd_msg_pub.add;
    RAISE e_cc_type;
  END IF;

  IF ((l_cc_headers_rec.cc_state IS NOT NULL) AND
            ((l_cc_headers_rec.cc_state = 'CL') OR (l_cc_headers_rec.cc_state = 'PR')))
  THEN
    fnd_message.set_name('IGC','IGC_CC_INVALID_CC_STATE');
    fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
    fnd_msg_pub.add;
    RAISE e_cc_state;
  END IF;

        /* Check whether encumbrance is turned on */

  IGC_CC_BUDGETARY_CTRL_PKG.Check_Budgetary_Ctrl_On
  (
    1.0,
    FND_API.G_FALSE,
    FND_API.G_VALID_LEVEL_FULL,
    l_return_status,
    l_msg_count,
    l_msg_data ,
    l_cc_headers_rec.org_id,
    l_cc_headers_rec.set_of_books_id,
    l_cc_headers_rec.cc_state,
    l_encumbrance_on
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    RAISE e_internal_error;
  END IF;

  /* Check whether contract commitment is Approved */

   IF (l_cc_headers_rec.cc_state = 'CM')
   THEN
          IF (l_cc_headers_rec.cc_apprvl_status = 'AP')
    THEN
      /* Check whether budetary control has been turned on */
            IF (l_encumbrance_on = FND_API.G_TRUE)
      THEN
        /* fix for bug 1567120 */
             IF (l_cc_headers_rec.cc_type = 'S') OR (l_cc_headers_rec.cc_type = 'R')
                           THEN
                        /* Check whether Contract Commitment is encumbered */
            IF (l_cc_headers_rec.cc_encmbrnc_status <> 'C')
                  THEN
                     fnd_message.set_name('IGC','IGC_CC_CC_NOT_ENCUMBERED');
                           fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
                     fnd_msg_pub.add;
                           RAISE e_cc_not_encumbered;
                    END IF;
                           END IF;
             END IF;
          ELSE
     /* Contract Commitment is not approved */
       fnd_message.set_name('IGC','IGC_CC_CC_NOT_APPROVED');
             fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
       fnd_msg_pub.add;
       RAISE e_cc_not_approved;
          END IF;
    END IF;

    /* Get the start date and end date of current fiscal year */
    OPEN c_fiscal_year_dates(l_cc_headers_rec.set_of_books_id);
          FETCH c_fiscal_year_dates INTO l_start_date, l_end_date;
    CLOSE c_fiscal_year_dates;

         /* Check whether Contract Commitment is already populated in PO Tables */

        l_po_found := TRUE;

  BEGIN

        SELECT * INTO l_po_headers_rec
              FROM PO_HEADERS_ALL
        WHERE segment1 = l_cc_headers_rec.cc_num AND
              type_lookup_code = 'STANDARD' AND
        org_id = l_cc_headers_rec.org_id;

  EXCEPTION
    WHEN no_data_found
                THEN
                     l_po_found := FALSE;
        END;

  IF (l_po_found = FALSE)
  THEN

    /* Check whether current fiscal year payment forecast lines exist in CC */

    BEGIN
      l_curr_year_pf_lines := 0;

      /* begin fix for bug 1578214 */

      SELECT count(cc_det_pf_line_id)
            INTO   l_curr_year_pf_lines
      FROM   igc_cc_det_pf a, igc_cc_acct_lines b, igc_cc_headers c
                  WHERE
                               NVL(a.cc_det_pf_date,l_end_date + 1) <= l_end_date  AND
                               a.cc_acct_line_id = b.cc_acct_line_id AND
                               b.cc_header_id = c.cc_header_id AND
                               c.cc_header_id = p_cc_header_id;

                        /* end  fix for bug 1578214 */

    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
           l_curr_year_pf_lines := 0;
    END;
  END IF;


  IF (l_curr_year_pf_lines = 0) AND (l_po_found = FALSE)
        THEN
    RETURN;
  END IF;


  /* Corresponding PO exists */

  IF (l_po_found)
        THEN
          Initialize_Header_Row('U',l_encumbrance_on, l_cc_headers_rec, l_po_headers_rec);
                IGC_CC_PO_HEADERS_ALL_PVT.Update_Row(1.0,
                 FND_API.G_FALSE,
                 FND_API.G_FALSE,
                                                     FND_API.G_VALID_LEVEL_NONE,
                 l_return_status,
                                                     l_msg_count,
                 l_msg_data,
                       l_po_headers_rec);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE e_internal_error;
    END IF;

                /* Find the changes made to Contract Commitment */

                OPEN c_account_lines(p_cc_header_id);

          LOOP

      FETCH c_account_lines INTO l_cc_acct_lines_rec;

      EXIT WHEN c_account_lines%NOTFOUND;

      /* Check whether it is a new account line */

      l_new_account_line := FALSE;

      BEGIN

                              SELECT * INTO l_po_lines_rec
                              FROM   po_lines_all pol
              WHERE
                                        pol.po_header_id = l_po_headers_rec.po_header_id AND
                      pol.line_num     = l_cc_acct_lines_rec.cc_acct_line_num;
                        EXCEPTION
        WHEN NO_DATA_FOUND
                                THEN
                l_new_account_line := TRUE;
      END;

      IF (l_new_account_line = FALSE)
      THEN
        BEGIN

                                SELECT *
                                  INTO l_po_line_locs_rec
                                  FROM  po_line_locations_all pll
                                 WHERE  pll.po_header_id = l_po_headers_rec.po_header_id
                                   AND  pll.po_line_id   = l_po_lines_rec.po_line_id;
         EXCEPTION
          WHEN NO_DATA_FOUND
                                  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
      END IF;

      BEGIN
        l_curr_year_pf_lines := 0;

        SELECT count(*)
              INTO   l_curr_year_pf_lines
        FROM   igc_cc_det_pf b
                     WHERE
                                        /* commented this part of code to fix bug 1576123 ( cc_det_pf_date >= l_start_date
                               AND */
                                        (cc_det_pf_date <= l_end_date ) AND
                                  b.cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_curr_year_pf_lines := 0;
      END;

      /* New account line */
                        IF (l_new_account_line) AND (l_curr_year_pf_lines > 0 )
                        THEN
        Initialize_Lines_Row('I',
                  l_po_headers_rec.po_header_id,
                        l_cc_headers_rec.org_id,
                        l_cc_acct_lines_rec,
                  l_po_lines_rec,
                                                      l_start_date,
                                                      l_end_date);

                                IGC_CC_PO_LINES_ALL_PVT.Insert_Row(1.0,
                                FND_API.G_FALSE,
                                FND_API.G_FALSE,
                                                                    FND_API.G_VALID_LEVEL_NONE,
                                l_return_status,
                                                                    l_msg_count,
                                l_msg_data,
                                      l_po_lines_rec);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
          RAISE e_internal_error;
        END IF;

              Initialize_Line_Locs_Row('I',
                 l_encumbrance_on,
                 l_po_headers_rec,
                 l_po_lines_rec,
                 l_po_line_locs_rec);

                                IGC_CC_PO_LINE_LOCS_ALL_PVT.Insert_Row(1.0,
                                FND_API.G_FALSE,
                                FND_API.G_FALSE,
                                                                    FND_API.G_VALID_LEVEL_NONE,
                                l_return_status,
                                                                    l_msg_count,
                                l_msg_data,
                                      l_po_line_locs_rec);

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
              THEN
          RAISE e_internal_error;
              END IF;

              OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

        LOOP
          FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

          EXIT WHEN c_payment_forecast%NOTFOUND;

          /* Current year payment forecast line */
                IF
                                           /* Commented this part of code to fix bug 1576123
                                            ( l_cc_pmt_fcst_rec.cc_det_pf_date >= l_start_date )
                                            AND */
                   ( l_cc_pmt_fcst_rec.cc_det_pf_date <= l_end_date )
          THEN

            Initialize_Distributions_Row('I',
                                                                       l_encumbrance_on,
                                               l_cc_headers_rec,
                                                                       l_cc_acct_lines_rec,
                                                                             l_cc_pmt_fcst_rec,
                                                                             l_po_line_locs_rec,
                                                                             l_po_dist_rec);

                                          IGC_CC_PO_DIST_ALL_PVT.Insert_Row(1.0,
                                        FND_API.G_FALSE,
                                              FND_API.G_FALSE,
                                                                                  FND_API.G_VALID_LEVEL_NONE,
                                              l_return_status,
                                                                                  l_msg_count,
                                              l_msg_data,
                                                    l_po_dist_rec);

                              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                              THEN
              RAISE e_internal_error;
                        END IF;
          END IF;
              END LOOP; /* payment forecast cursor */

              CLOSE c_payment_forecast;

       END IF; /* New account line */


      /* Existing account line */

       IF ( NOT l_new_account_line)
       THEN
        Initialize_Lines_Row('U',
                         l_po_headers_rec.po_header_id,
                   l_cc_headers_rec.org_id,
                   l_cc_acct_lines_rec,
                                                       l_po_lines_rec,
                                                       l_start_date,
                                                       l_end_date);

                                IGC_CC_PO_LINES_ALL_PVT.Update_Row(1.0,
                                 FND_API.G_FALSE,
                                 FND_API.G_FALSE,
                                                                     FND_API.G_VALID_LEVEL_NONE,
                                 l_return_status,
                                                                     l_msg_count,
                                 l_msg_data,
                                       l_po_lines_rec);
              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
              THEN
            RAISE e_internal_error;
              END IF;

        Initialize_Line_Locs_Row('U',
                 l_encumbrance_on,
                                   l_po_headers_rec,
                 l_po_lines_rec,
                 l_po_line_locs_rec);

                                IGC_CC_PO_LINE_LOCS_ALL_PVT.Update_Row(1.0,
                                     FND_API.G_FALSE,
                                     FND_API.G_FALSE,
                                                                         FND_API.G_VALID_LEVEL_NONE,
                                     l_return_status,
                                                                         l_msg_count,
                                     l_msg_data,
                                           l_po_line_locs_rec);

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
              THEN
            RAISE e_internal_error;
              END IF;

        l_new_payment_forecast_line := FALSE;

        OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

        LOOP
                FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;
                EXIT WHEN c_payment_forecast%NOTFOUND;
                      /* Check PO_DISTRIBUTIONS_ALL for the record */
                l_new_payment_forecast_line := FALSE;

                      BEGIN

                                              SELECT *
                                              INTO   l_po_dist_rec
                                              FROM
                                                  po_distributions_all pod
                              WHERE
                                                        pod.po_header_id = l_po_headers_rec.po_header_id AND
                                                        pod.po_line_id   = l_po_lines_rec.po_line_id AND
              pod.line_location_id = l_po_line_locs_rec.line_location_id AND
              pod.distribution_num = l_cc_pmt_fcst_rec.cc_det_pf_line_num;

                                        EXCEPTION
                         WHEN no_data_found
                         THEN
                                l_new_payment_forecast_line := TRUE;
                                        END;


                /* New payment forecast record */

                      IF (l_new_payment_forecast_line)
                      THEN
            /* Current year payment forecast line */
                  IF
                                                   /* Commented this part of code to fix bug 1576123
                                                     ( l_cc_pmt_fcst_rec.cc_det_pf_date >= l_start_date ) AND */
                       ( l_cc_pmt_fcst_rec.cc_det_pf_date <= l_end_date )
            THEN
                  Initialize_Distributions_Row('I',
                   l_encumbrance_on,
                                           l_cc_headers_rec,
                                                               l_cc_acct_lines_rec,
                                                               l_cc_pmt_fcst_rec,
                                                                   l_po_line_locs_rec,
                                                                   l_po_dist_rec);

                    IGC_CC_PO_DIST_ALL_PVT.Insert_Row(1.0,
                                                FND_API.G_FALSE,
                                                      FND_API.G_FALSE,
                                                                                          FND_API.G_VALID_LEVEL_NONE,
                                                      l_return_status,
                                                                                          l_msg_count,
                                                      l_msg_data,
                                                            l_po_dist_rec);


                                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                                THEN
                          RAISE e_internal_error;
                                END IF;
            END IF;

                  END IF; /* New payment forecast cursor */

            /* Existing payment forecast record */
            IF ( NOT l_new_payment_forecast_line)
            THEN
                  Initialize_Distributions_Row(
                                                           'U',
                 l_encumbrance_on,
                                         l_cc_headers_rec,
                                                           l_cc_acct_lines_rec,
                                                           l_cc_pmt_fcst_rec,
                                                           l_po_line_locs_rec,
                                                           l_po_dist_rec);

               IGC_CC_PO_DIST_ALL_PVT.Update_Row(1.0,
                                                FND_API.G_FALSE,
                                                FND_API.G_FALSE,
                                                                                    FND_API.G_VALID_LEVEL_NONE,
                                                l_return_status,
                                                                                    l_msg_count,
                                                l_msg_data,
                                                      l_po_dist_rec);

                                 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                                 THEN
              RAISE e_internal_error;
                                 END IF;

                                          END IF; /* Existing payment forecast record */

               END LOOP;  /* payment forecast cursor */

                           CLOSE c_payment_forecast;
                          END IF; /* Existing account line */
                END LOOP; /* Account_Lines_Cursor */
                CLOSE c_account_lines;

         END IF; /* PO Exisists */

  /* PO does not exist */

  IF ( not l_po_found ) AND (l_curr_year_pf_lines > 0)
  THEN
        /* Insert row into PO_HEADERS_ALL */

        Initialize_Header_Row('I',l_encumbrance_on, l_cc_headers_rec, l_po_headers_rec);

              IGC_CC_PO_HEADERS_ALL_PVT.Insert_Row(1.0,
                                          FND_API.G_FALSE,
                  FND_API.G_FALSE,
                                                FND_API.G_VALID_LEVEL_NONE,
                  l_return_status,
                                                l_msg_count,
                  l_msg_data,
                  l_po_headers_rec);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                              THEN
              RAISE e_internal_error;
                              END IF;

          /* Process Account Lines */

    OPEN c_account_lines(p_cc_header_id);

    LOOP

            FETCH c_account_lines INTO l_cc_acct_lines_rec;

            EXIT WHEN c_account_lines%NOTFOUND;

      BEGIN
        l_curr_year_pf_lines := 0;

        SELECT count(*)
              INTO   l_curr_year_pf_lines
        FROM   igc_cc_det_pf b
                     WHERE
                                         /* commented this part of code to fix bug 1576123 ( cc_det_pf_date >= l_start_date  AND */
                             (cc_det_pf_date <= l_end_date ) AND
                             b.cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_curr_year_pf_lines := 0;
      END;

      IF (l_curr_year_pf_lines > 0)
      THEN
            /* Insert row into PO_LINES_ALL */

                          Initialize_Lines_Row('I',
                  l_po_headers_rec.po_header_id,
                  l_cc_headers_rec.org_id,
                  l_cc_acct_lines_rec,
                  l_po_lines_rec,
                                                      l_start_date,
                                                      l_end_date);
                          IGC_CC_PO_LINES_ALL_PVT.Insert_Row(1.0,
                                                       FND_API.G_FALSE,
                               FND_API.G_FALSE,
                                                                   FND_API.G_VALID_LEVEL_NONE,
                                     l_return_status,
                                                                   l_msg_count,
                                     l_msg_data,
                                     l_po_lines_rec);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
              THEN
          RAISE e_internal_error;
        END IF;

              /* Insert row into PO_LINE_LOCATIONS_ALL */

                          Initialize_Line_Locs_Row('I',
                  l_encumbrance_on,
                  l_po_headers_rec,
                  l_po_lines_rec,
                  l_po_line_locs_rec);

                          IGC_CC_PO_LINE_LOCS_ALL_PVT.Insert_Row(1.0,
                                                           FND_API.G_FALSE,
                                         FND_API.G_FALSE,
                                                                       FND_API.G_VALID_LEVEL_NONE,
                                         l_return_status,
                                                                       l_msg_count,
                                         l_msg_data,
                                         l_po_line_locs_rec);

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
              THEN
          RAISE e_internal_error;
              END IF;

              /* Process payment forecast lines */

                    OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

                          LOOP
          FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

                EXIT WHEN c_payment_forecast%NOTFOUND;

          /* Current year payment forecast line */
                IF
                                           /* Commented this part of the code to fix bug 1576123
                                           ( l_cc_pmt_fcst_rec.cc_det_pf_date >= l_start_date )
                                           AND */

                   ( l_cc_pmt_fcst_rec.cc_det_pf_date <= l_end_date )
          THEN

                  Initialize_Distributions_Row('I',
                                                                       l_encumbrance_on,
                                                           l_cc_headers_rec,
                                                                             l_cc_acct_lines_rec,
                                                                             l_cc_pmt_fcst_rec,
                                                                 l_po_line_locs_rec,
                                                                 l_po_dist_rec);

                                                IGC_CC_PO_DIST_ALL_PVT.Insert_Row(1.0,
                                                                            FND_API.G_FALSE,
                                                    FND_API.G_FALSE,
                                                                                  FND_API.G_VALID_LEVEL_NONE,
                                                    l_return_status,
                                                                                  l_msg_count,
                                                    l_msg_data,
                                                    l_po_dist_rec);
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
            THEN
              RAISE e_internal_error;
                END IF;
          END IF;

                END LOOP; /* Payment forecast cursor */

            CLOSE c_payment_forecast;
      END IF;

               END LOOP; /*account lines cursor*/

         CLOSE c_account_lines;

  END IF; /* PO do not exist */


  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

EXCEPTION

  WHEN E_INTERNAL_ERROR
  THEN
                ROLLBACK TO Convert_CC_To_PO;
    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
                ROLLBACK TO Convert_CC_To_PO;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data );

  WHEN  E_CC_NOT_FOUND OR E_CC_STATE OR E_CC_TYPE OR E_CC_NOT_ENCUMBERED OR E_LINE_LOCATIONS
        OR E_CC_NOT_APPROVED
  THEN
                ROLLBACK TO Convert_CC_To_PO;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

  WHEN OTHERS
  THEN
                ROLLBACK TO Convert_CC_To_PO;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );


END Convert_CC_To_PO;

/*==========================================================================+
 |                       PROCEDURE Lock_PO_Row                              |
 +==========================================================================*/
PROCEDURE Lock_PO_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  p_cc_header_id              IN       NUMBER,
  x_row_locked                OUT NOCOPY      VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_PO_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  l_cc_headers_rec      igc_cc_headers%ROWTYPE;
  e_cc_not_found        EXCEPTION;
  e_po_not_found        EXCEPTION;


  Counter NUMBER;
  CURSOR C(p_cc_num VARCHAR2, p_org_id NUMBER)
  IS
    --SELECT *
                -- Reducing the number of columns selected reduces the shared
                -- memory used. Performance tuning project
    SELECT po_header_id
          FROM   po_headers_all
          WHERE  segment1 = p_cc_num AND
                 type_lookup_code = 'STANDARD' AND
                 org_id = p_org_id
    FOR UPDATE NOWAIT;

    Recinfo C%ROWTYPE;
BEGIN

  SAVEPOINT Lock_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                     p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  x_row_locked    := FND_API.G_TRUE ;

  /* Check whether Contract Commitment exists or not */

  BEGIN

    SELECT * INTO l_cc_headers_rec
          FROM igc_cc_headers
    WHERE cc_header_id = p_cc_header_id;

  EXCEPTION
    WHEN no_data_found
    THEN
      fnd_message.set_name('IGC','IGC_CC_NOT_FOUND');
      fnd_message.set_token('CC_NUM',to_char(p_cc_header_id),TRUE);
            fnd_msg_pub.add;
      RAISE E_CC_NOT_FOUND;
  END;


  OPEN C(l_cc_headers_rec.cc_num, l_cc_headers_rec.org_id);
  FETCH C INTO Recinfo;

  IF (C%NOTFOUND)
  THEN
    CLOSE C;
    fnd_message.set_name('IGC','IGC_CC_PO_NOT_FOUND');
    fnd_message.set_token('CC_NUM',l_cc_headers_rec.cc_num,TRUE);
    fnd_msg_pub.add;
                RAISE e_po_not_found;

  END IF;

  CLOSE C;

EXCEPTION
  WHEN  E_CC_NOT_FOUND OR E_PO_NOT_FOUND
  THEN
        ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_row_locked    := FND_API.G_FALSE;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );


    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION
  THEN

        ROLLBACK TO Lock_Row_Pvt ;
        x_row_locked    := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data );

  WHEN FND_API.G_EXC_ERROR
  THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
        x_row_locked    := FND_API.G_FALSE;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
        ROLLBACK TO Lock_Row_Pvt ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_row_locked    := FND_API.G_FALSE;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

  WHEN OTHERS
  THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_row_locked    := FND_API.G_FALSE;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                   l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

END Lock_PO_Row;
BEGIN
 -- Bug 3605536 GSCC Warnings fixed
  g_debug_flag   := 'N' ;

END IGC_CC_PO_INTERFACE_PKG;

/
