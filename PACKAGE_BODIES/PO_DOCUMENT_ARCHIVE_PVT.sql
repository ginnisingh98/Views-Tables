--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ARCHIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ARCHIVE_PVT" AS
/* $Header: POXPIARB.pls 120.10.12010000.10 2012/10/09 21:52:54 rarajar ship $ */

G_PKG_NAME CONSTANT varchar2(30) := 'PO_DOCUMENT_ARCHIVE_PVT';
G_MODULE_PREFIX CONSTANT VARCHAR2(60) := 'po.plsql.' || G_PKG_NAME || '.';
G_FND_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_FND_DEBUG_LEVEL VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_LEVEL'),'0');

D_PACKAGE_BASE CONSTANT VARCHAR2(50) := PO_LOG.get_package_base(G_PKG_NAME);
D_archive_attribute_values CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'archive_attribute_values');
D_archive_attr_values_tlp CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'archive_attr_values_tlp');

--<Enhanced Pricing Start:>
D_archive_price_adjustments CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'archive_price_adjustments');
D_archive_price_adj_attribs CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'archive_price_adj_attribs');
--<Enhanced Pricing End>

PROCEDURE archive_attribute_values
(
  p_po_header_id IN NUMBER
, p_revision_num IN NUMBER
);

PROCEDURE archive_attr_values_tlp
(
  p_po_header_id IN NUMBER
, p_revision_num IN NUMBER
);

--<Enhanced Pricing Start:>
PROCEDURE archive_price_adjustments
(
  p_po_header_id IN NUMBER
, p_revision_num IN NUMBER
);
PROCEDURE archive_price_adj_attribs
(
  p_po_header_id IN NUMBER
, p_revision_num IN NUMBER
);
--<Enhanced Pricing End>

-------------------------------------------------------------------------------
--Start of Comments
--Name: CHECK_PO_ARCHIVE
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get the current revision number and check if it is already archived
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived
--OUT:
--x_revision_num
--  The revision number of the PO
--x_return_status
--  'Y' if archive needed
--  'N' if archive not needed
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE CHECK_PO_ARCHIVE(p_document_id  IN         NUMBER,
                 x_revision_num       OUT NOCOPY NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'CHECK_PO_ARCHIVE';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_arch_revision_num NUMBER;

BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  -- SQL What: Select current revision number and archived revision number
  -- SQL Why : Check if the document is approved and not archived
  SELECT NVL(ph.revision_num, 0),
         NVL(pha.revision_num, -1)
  INTO   x_revision_num, l_arch_revision_num
  FROM   PO_HEADERS_ALL PH,
         PO_HEADERS_ARCHIVE_ALL PHA
  WHERE  ph.po_header_id = p_document_id
  AND    ph.approved_date IS NOT NULL
  AND    ph.approved_flag = 'Y'
  AND    ph.po_header_id = pha.po_header_id (+)
  AND    pha.latest_external_flag(+) = 'Y';

  l_progress := '020';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF x_revision_num = l_arch_revision_num THEN
    x_return_status := 'N';
  ELSE
    x_return_status := 'Y';
  END IF; /*x_revision_num = l_arch_revision_num*/

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of CHECK_PO_ARCHIVE()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    x_return_status := 'N';
END CHECK_PO_ARCHIVE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: CHECK_RELEASE_ARCHIVE
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get the current revision number and check if it is already archived
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived
--OUT:
--x_revision_num
--  The revision number of the Release
--x_return_status
--  'Y' if archive needed
--  'N' if archive not needed
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE CHECK_RELEASE_ARCHIVE(p_document_id IN         NUMBER,
                      x_revision_num  OUT NOCOPY NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'CHECK_RELEASE_ARCHIVE';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_arch_revision_num NUMBER;

BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  -- SQL What: Select current revision number and archived revision number
  -- SQL Why : Check if the document is approved and not archived
  SELECT NVL(ph.revision_num, 0),
         NVL(pha.revision_num, -1)
  INTO   x_revision_num, l_arch_revision_num
  FROM   PO_RELEASES_ALL PH,
         PO_RELEASES_ARCHIVE_ALL PHA
  WHERE  ph.po_release_id = p_document_id
  AND    ph.approved_date IS NOT NULL
  AND    ph.approved_flag = 'Y'
  AND    ph.po_release_id = pha.po_release_id (+)
  AND    pha.latest_external_flag(+) = 'Y';

  l_progress := '020';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF x_revision_num = l_arch_revision_num THEN
    x_return_status := 'N';
  ELSE
    x_return_status := 'Y';
  END IF; /*x_revision_num = l_arch_revision_num*/

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of CHECK_RELEASE_ARCHIVE()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    x_return_status := 'N';
END CHECK_RELEASE_ARCHIVE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ARCHIVE_HEADER
--Pre-reqs:
--  None.
--Modifies:
--  PO_HEADERS_ARCHIVE
--Locks:
--  None.
--Function:
--  Archive PO Header
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ARCHIVE_HEADER(p_document_id    IN         NUMBER)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_HEADER';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);

BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Update PO_HEADERS_ARCHIVE to reset latest_external_flag');
  END IF;

  UPDATE PO_HEADERS_ARCHIVE_ALL
  SET    latest_external_flag = 'N'
  WHERE  po_header_id         = p_document_id
  AND    latest_external_flag = 'Y';

  l_progress := '020';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Insert PO_HEADERS_ARCHIVE ');
  END IF;

  INSERT INTO PO_HEADERS_ARCHIVE_ALL
  (acceptance_due_date    ,
   acceptance_required_flag ,
   agent_id     ,
   amount_limit     ,
   approval_required_flag   ,
   approved_date    ,
   approved_flag    ,
   attribute1     ,
   attribute10      ,
   attribute11      ,
   attribute12      ,
   attribute13      ,
   attribute14      ,
   attribute15      ,
   attribute2     ,
   attribute3     ,
   attribute4     ,
   attribute5     ,
   attribute6     ,
   attribute7     ,
   attribute8     ,
   attribute9     ,
   attribute_category   ,
   authorization_status   ,
   bill_to_location_id    ,
   blanket_total_amount   ,
   cancel_flag      ,
   cbc_accounting_date    ,
   change_requested_by    ,
   change_summary     ,
   closed_code      ,
   closed_date      ,
   comments     ,
   confirming_order_flag  ,
   consigned_consumption_flag ,
   consume_req_demand_flag  ,
   conterms_articles_upd_date ,
   conterms_deliv_upd_date  ,
   conterms_exist_flag    ,
   created_by     ,
   creation_date    ,
   currency_code    ,
   edi_processed_flag   ,
   edi_processed_status   ,
   enabled_flag     ,
   encumbrance_required_flag  ,
   end_date     ,
   end_date_active    ,
   firm_date      ,
   firm_status_lookup_code  ,
   fob_lookup_code    ,
   freight_terms_lookup_code  ,
   from_header_id     ,
   from_type_lookup_code  ,
   frozen_flag      ,
   global_agreement_flag  ,
   global_attribute1    ,
   global_attribute10   ,
   global_attribute11   ,
   global_attribute12   ,
   global_attribute13   ,
   global_attribute14   ,
   global_attribute15   ,
   global_attribute16   ,
   global_attribute17   ,
   global_attribute18   ,
   global_attribute19   ,
   global_attribute2    ,
   global_attribute20   ,
   global_attribute3    ,
   global_attribute4    ,
   global_attribute5    ,
   global_attribute6    ,
   global_attribute7    ,
   global_attribute8    ,
   global_attribute9    ,
   global_attribute_category  ,
   government_context   ,
   interface_source_code  ,
   last_update_date   ,
   last_update_login    ,
   last_updated_by    ,
   min_release_amount   ,
   mrc_rate     ,
   mrc_rate_date    ,
   mrc_rate_type    ,
   note_to_authorizer   ,
   note_to_receiver   ,
   note_to_vendor     ,
   org_id       ,
   pay_on_code      ,
   pcard_id     ,
   pending_signature_flag   ,
   po_header_id     ,
   price_update_tolerance   ,
   print_count      ,
   printed_date     ,
   program_application_id   ,
   program_id     ,
   program_update_date    ,
   quotation_class_code   ,
   quote_type_lookup_code   ,
   quote_vendor_quote_number  ,
   quote_warning_delay    ,
   quote_warning_delay_unit ,
   rate       ,
   rate_date      ,
   rate_type      ,
   reference_num    ,
   reply_date     ,
   reply_method_lookup_code ,
   request_id     ,
   revised_date     ,
   revision_num     ,
   rfq_close_date     ,
   segment1     ,
   segment2     ,
   segment3     ,
   segment4     ,
   segment5     ,
   ship_to_location_id    ,
   ship_via_lookup_code   ,
   shipping_control   ,
   start_date     ,
   start_date_active    ,
   status_lookup_code   ,
   summary_flag     ,
   supply_agreement_flag  ,
   terms_id     ,
   type_lookup_code   ,
   user_hold_flag     ,
   vendor_contact_id    ,
   vendor_id      ,
   vendor_order_num   ,
   vendor_site_id     ,
   wf_item_key      ,
   wf_item_type     ,
   xml_change_send_date   ,
   xml_flag     ,
   xml_send_date    ,
   latest_external_flag,
   document_creation_method   -- <DBI FPJ>
   ,submit_date          --<DBI Req Fulfillment 11.5.11>
   ,style_id             --<R12 STYLES PHASE II>
   ,created_language     --<Unified Catalog R12>
   ,cpa_reference        --<Unified Catalog R12>
   ,last_updated_program --<Unified Catalog R12>
   ,pay_when_paid -- E and C ER
   ,ame_approval_id -- PO AME Approval Workflow changes
   ,ame_transaction_type -- PO AME Approval Workflow changes
   ,enable_all_sites --<ER 9824167, GCPA Enable All Sites changes>
  )
  SELECT
   acceptance_due_date    ,
   acceptance_required_flag ,
   agent_id     ,
   amount_limit     ,
   approval_required_flag   ,
   approved_date    ,
   approved_flag    ,
   attribute1     ,
   attribute10      ,
   attribute11      ,
   attribute12      ,
   attribute13      ,
   attribute14      ,
   attribute15      ,
   attribute2     ,
   attribute3     ,
   attribute4     ,
   attribute5     ,
   attribute6     ,
   attribute7     ,
   attribute8     ,
   attribute9     ,
   attribute_category   ,
   authorization_status   ,
   bill_to_location_id    ,
   blanket_total_amount   ,
   cancel_flag      ,
   cbc_accounting_date    ,
   change_requested_by    ,
   change_summary     ,
   closed_code      ,
   closed_date      ,
   comments     ,
   confirming_order_flag  ,
   consigned_consumption_flag ,
   consume_req_demand_flag  ,
   conterms_articles_upd_date ,
   conterms_deliv_upd_date  ,
   conterms_exist_flag    ,
   created_by     ,
   creation_date    ,
   currency_code    ,
   -- Bug 3438383, EDI Team expects EDI columns NULL
   -- edi_processed_flag  ,
   -- edi_processed_status  ,
   NULL       ,
   NULL       ,
   enabled_flag     ,
   encumbrance_required_flag  ,
   end_date     ,
   end_date_active    ,
   firm_date      ,
   firm_status_lookup_code  ,
   fob_lookup_code    ,
   freight_terms_lookup_code  ,
   from_header_id     ,
   from_type_lookup_code  ,
   frozen_flag      ,
   global_agreement_flag  ,
   global_attribute1    ,
   global_attribute10   ,
   global_attribute11   ,
   global_attribute12   ,
   global_attribute13   ,
   global_attribute14   ,
   global_attribute15   ,
   global_attribute16   ,
   global_attribute17   ,
   global_attribute18   ,
   global_attribute19   ,
   global_attribute2    ,
   global_attribute20   ,
   global_attribute3    ,
   global_attribute4    ,
   global_attribute5    ,
   global_attribute6    ,
   global_attribute7    ,
   global_attribute8    ,
   global_attribute9    ,
   global_attribute_category  ,
   government_context   ,
   interface_source_code  ,
   last_update_date   ,
   last_update_login    ,
   last_updated_by    ,
   min_release_amount   ,
   mrc_rate     ,
   mrc_rate_date    ,
   mrc_rate_type    ,
   note_to_authorizer   ,
   note_to_receiver   ,
   note_to_vendor     ,
   org_id       ,
   pay_on_code      ,
   pcard_id     ,
   pending_signature_flag   ,
   po_header_id     ,
   price_update_tolerance   ,
   print_count      ,
   printed_date     ,
   program_application_id   ,
   program_id     ,
   program_update_date    ,
   quotation_class_code   ,
   quote_type_lookup_code   ,
   quote_vendor_quote_number  ,
   quote_warning_delay    ,
   quote_warning_delay_unit ,
   rate       ,
   rate_date      ,
   rate_type      ,
   reference_num    ,
   reply_date     ,
   reply_method_lookup_code ,
   request_id     ,
   revised_date     ,
   revision_num     ,
   rfq_close_date     ,
   segment1     ,
   segment2     ,
   segment3     ,
   segment4     ,
   segment5     ,
   ship_to_location_id    ,
   ship_via_lookup_code   ,
   shipping_control   ,
   start_date     ,
   start_date_active    ,
   status_lookup_code   ,
   summary_flag     ,
   supply_agreement_flag  ,
   terms_id     ,
   type_lookup_code   ,
   user_hold_flag     ,
   vendor_contact_id    ,
   vendor_id      ,
   vendor_order_num   ,
   vendor_site_id     ,
   wf_item_key      ,
   wf_item_type     ,
   xml_change_send_date   ,
   xml_flag     ,
   xml_send_date    ,
   'Y',
   document_creation_method   -- <DBI FPJ>
   ,submit_date          --<DBI Req Fulfillment 11.5.11>
   ,style_id             --<R12 STYLES PHASE II>
   , created_language     --<Unified Catalog R12>
   , cpa_reference        --<Unified Catalog R12>
   , last_updated_program --<Unified Catalog R12>
   ,pay_when_paid -- E and C ER
   ,ame_approval_id -- PO AME Approval Workflow changes
   ,ame_transaction_type -- PO AME Approval Workflow changes
   ,enable_all_sites --<ER 9824167, GCPA Enable All Sites changes>
  FROM  PO_HEADERS_ALL
  WHERE po_header_id = p_document_id;

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of ARCHIVE_HEADER()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    RAISE;
END ARCHIVE_HEADER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ARCHIVE_RELEASE
--Pre-reqs:
--  None.
--Modifies:
--  PO_RELEASES_ARCHIVE
--Locks:
--  None.
--Function:
--  Archive the release header
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ARCHIVE_RELEASE(p_document_id   IN         NUMBER)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_RELEASE';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);

BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Update PO_HEADERS_ARCHIVE to reset latest_external_flag');
  END IF;

  UPDATE PO_RELEASES_ARCHIVE_ALL
  SET    latest_external_flag = 'N'
  WHERE  po_release_id        = p_document_id
  AND    latest_external_flag = 'Y';

  l_progress := '020';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Insert PO_RELEASES_ARCHIVE ');
  END IF;

  -- Archiving the releases
  INSERT INTO PO_RELEASES_ARCHIVE_ALL
  (acceptance_due_date      ,
   acceptance_required_flag   ,
   agent_id       ,
   approved_date      ,
   approved_flag      ,
   attribute1       ,
   attribute10        ,
   attribute11        ,
   attribute12        ,
   attribute13        ,
   attribute14        ,
   attribute15        ,
   attribute2       ,
   attribute3       ,
   attribute4       ,
   attribute5       ,
   attribute6       ,
   attribute7       ,
   attribute8       ,
   attribute9       ,
   attribute_category     ,
   authorization_status     ,
   cancel_date        ,
   cancel_flag        ,
   cancel_reason      ,
   cancelled_by       ,
   cbc_accounting_date      ,
   change_requested_by      ,
   change_summary       ,
   closed_code        ,
   consigned_consumption_flag   ,
   created_by       ,
   creation_date      ,
   edi_processed_flag     ,
   firm_date        ,
   firm_status_lookup_code    ,
   frozen_flag        ,
   global_attribute1      ,
   global_attribute10     ,
   global_attribute11     ,
   global_attribute12     ,
   global_attribute13     ,
   global_attribute14     ,
   global_attribute15     ,
   global_attribute16     ,
   global_attribute17     ,
   global_attribute18     ,
   global_attribute19     ,
   global_attribute2      ,
   global_attribute20     ,
   global_attribute3      ,
   global_attribute4      ,
   global_attribute5      ,
   global_attribute6      ,
   global_attribute7      ,
   global_attribute8      ,
   global_attribute9      ,
   global_attribute_category    ,
   government_context     ,
   hold_by        ,
   hold_date        ,
   hold_flag        ,
   hold_reason        ,
   last_update_date     ,
   last_update_login      ,
   last_updated_by      ,
   note_to_vendor       ,
   org_id         ,
   pay_on_code        ,
   pcard_id       ,
   po_header_id       ,
   po_release_id      ,
   print_count        ,
   printed_date       ,
   program_application_id     ,
   program_id       ,
   program_update_date      ,
   release_date       ,
   release_num        ,
   release_type       ,
   request_id       ,
   revised_date       ,
   revision_num       ,
   shipping_control     ,
   vendor_order_num     ,
   wf_item_key        ,
   wf_item_type       ,
   xml_change_send_date     ,
   xml_flag       ,
   xml_send_date      ,
   latest_external_flag,
   document_creation_method   -- <DBI FPJ>
   , submit_date             --<DBI Req Fulfillment 11.5.11>
  )
  SELECT
   acceptance_due_date      ,
   acceptance_required_flag   ,
   agent_id       ,
   approved_date      ,
   approved_flag      ,
   attribute1       ,
   attribute10        ,
   attribute11        ,
   attribute12        ,
   attribute13        ,
   attribute14        ,
   attribute15        ,
   attribute2       ,
   attribute3       ,
   attribute4       ,
   attribute5       ,
   attribute6       ,
   attribute7       ,
   attribute8       ,
   attribute9       ,
   attribute_category     ,
   authorization_status     ,
   cancel_date        ,
   cancel_flag        ,
   cancel_reason      ,
   cancelled_by       ,
   cbc_accounting_date      ,
   change_requested_by      ,
   change_summary       ,
   closed_code        ,
   consigned_consumption_flag   ,
   created_by       ,
   creation_date      ,
   -- Bug 3438383, EDI Team expects EDI columns NULL
   -- edi_processed_flag    ,
   NULL         ,
   firm_date        ,
   firm_status_lookup_code    ,
   frozen_flag        ,
   global_attribute1      ,
   global_attribute10     ,
   global_attribute11     ,
   global_attribute12     ,
   global_attribute13     ,
   global_attribute14     ,
   global_attribute15     ,
   global_attribute16     ,
   global_attribute17     ,
   global_attribute18     ,
   global_attribute19     ,
   global_attribute2      ,
   global_attribute20     ,
   global_attribute3      ,
   global_attribute4      ,
   global_attribute5      ,
   global_attribute6      ,
   global_attribute7      ,
   global_attribute8      ,
   global_attribute9      ,
   global_attribute_category    ,
   government_context     ,
   hold_by        ,
   hold_date        ,
   hold_flag        ,
   hold_reason        ,
   last_update_date     ,
   last_update_login      ,
   last_updated_by      ,
   note_to_vendor       ,
   org_id         ,
   pay_on_code        ,
   pcard_id       ,
   po_header_id       ,
   po_release_id      ,
   print_count        ,
   printed_date       ,
   program_application_id     ,
   program_id       ,
   program_update_date      ,
   release_date       ,
   release_num        ,
   release_type       ,
   request_id       ,
   revised_date       ,
   revision_num       ,
   shipping_control     ,
   vendor_order_num     ,
   wf_item_key        ,
   wf_item_type       ,
   xml_change_send_date     ,
   xml_flag       ,
   xml_send_date      ,
   'Y',
   document_creation_method   -- <DBI FPJ>
   , submit_date             --<DBI Req Fulfillment 11.5.11>
  FROM  PO_RELEASES_ALL
  WHERE po_release_id = p_document_id;

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of ARCHIVE_RELEASE()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    RAISE;
END ARCHIVE_RELEASE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ARCHIVE_LINES
--Pre-reqs:
--  None.
--Modifies:
--  PO_LINES_ARCHIVE
--Locks:
--  None.
--Function:
--  Arcives the po document lines.
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived.
--p_revision_num
--  The revision of the document that needs to be archived.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ARCHIVE_LINES(p_document_id   IN NUMBER,
      p_revision_num    IN NUMBER)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_LINES';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_revision_num  NUMBER;
  l_continue    BOOLEAN := FALSE;

BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'INSERT PO_LINES_ARCHIVE');
  END IF;

/*Bug7286203 - Added some fields to archival check so that cancellation and archival are in sync*/

  INSERT INTO PO_LINES_ARCHIVE_ALL
  (allow_price_override_flag,
   amount,
   attribute1,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute_category,
   auction_display_number,
   auction_header_id,
   auction_line_number,
   base_qty,
   base_unit_price, -- <FPJ Advanced Price>
   base_uom,
   bid_line_number,
   bid_number,
   cancel_date,
   cancel_flag,
   cancel_reason,
   cancelled_by,
   capital_expense_flag,
   category_id,
   closed_by,
   closed_code,
   closed_date,
   closed_flag,
   closed_reason,
   committed_amount,
   contract_id,
   contract_num,
   contractor_first_name,
   contractor_last_name,
   created_by,
   creation_date,
   expiration_date,
   firm_date,
   firm_status_lookup_code,
   from_header_id,
   from_line_id,
   global_attribute1,
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
   global_attribute2,
   global_attribute20,
   global_attribute3,
   global_attribute4,
   global_attribute5,
   global_attribute6,
   global_attribute7,
   global_attribute8,
   global_attribute9,
   global_attribute_category,
   government_context,
   hazard_class_id,
   item_description,
   item_id,
   item_revision,
   job_id,
   last_update_date,
   last_update_login,
   last_updated_by,
   line_num,
   line_reference_num,
   line_type_id,
   list_price_per_unit,
   manual_price_change_flag, --<MANUAL PRICE OVERRIDE FPJ>
   market_price,
   max_order_quantity,
   min_order_quantity,
   min_release_amount,
   negotiated_by_preparer_flag,
   not_to_exceed_price,
   note_to_vendor,
   oke_contract_header_id,
   oke_contract_version_id,
   org_id,
   over_tolerance_error_flag,
   po_header_id,
   po_line_id,
   preferred_grade,
   price_break_lookup_code,
   price_type_lookup_code,
   program_application_id,
   program_id,
   program_update_date,
   project_id,
   qc_grade,
   qty_rcv_tolerance,
   quantity,
   quantity_committed,
   reference_num,
   request_id,
   retroactive_date,
   secondary_qty,
   secondary_quantity,
   secondary_unit_of_measure,
   secondary_uom,
   start_date,
   -- <SVC_NOTIFICATIONS START>
   svc_amount_notif_sent,
   svc_completion_notif_sent,
   -- <SVC_NOTIFICATIONS END>
   supplier_ref_number,
   task_id,
   tax_code_id,
   tax_name,
   taxable_flag,
   transaction_reason_code,
   type_1099,
   un_number_id,
   unit_meas_lookup_code,
   unit_price,
   unordered_flag,
   user_hold_flag,
   vendor_product_num,
   latest_external_flag,
   revision_num,
   order_type_lookup_code, -- <Complex Work R12>
   matching_basis,         -- <Complex Work R12>
   purchase_basis,         -- <Complex Work R12>
   max_retainage_amount,   -- <Complex Work R12>
   retainage_rate,         -- <Complex Work R12>
   progress_payment_rate,  -- <Complex Work R12>
   recoupment_rate         -- <Complex Work R12>
   , catalog_name          --<Unified Catalog R12>
   , supplier_part_auxid   --<Unified Catalog R12>
   , ip_category_id        --<Unified Catalog R12>
   , last_updated_program  --<Unified Catalog R12>
)
  SELECT
   POL.allow_price_override_flag,
   POL.amount,
   POL.attribute1,
   POL.attribute10,
   POL.attribute11,
   POL.attribute12,
   POL.attribute13,
   POL.attribute14,
   POL.attribute15,
   POL.attribute2,
   POL.attribute3,
   POL.attribute4,
   POL.attribute5,
   POL.attribute6,
   POL.attribute7,
   POL.attribute8,
   POL.attribute9,
   POL.attribute_category,
   POL.auction_display_number,
   POL.auction_header_id,
   POL.auction_line_number,
   POL.base_qty,
   POL.base_unit_price,   -- <FPJ Advanced Price>
   POL.base_uom,
   POL.bid_line_number,
   POL.bid_number,
   POL.cancel_date,
   POL.cancel_flag,
   POL.cancel_reason,
   POL.cancelled_by,
   POL.capital_expense_flag,
   POL.category_id,
   POL.closed_by,
   POL.closed_code,
   POL.closed_date,
   POL.closed_flag,
   POL.closed_reason,
   POL.committed_amount,
   POL.contract_id,
   POL.contract_num,
   POL.contractor_first_name,
   POL.contractor_last_name,
   POL.created_by,
   POL.creation_date,
   POL.expiration_date,
   POL.firm_date,
   POL.firm_status_lookup_code,
   POL.from_header_id,
   POL.from_line_id,
   POL.global_attribute1,
   POL.global_attribute10,
   POL.global_attribute11,
   POL.global_attribute12,
   POL.global_attribute13,
   POL.global_attribute14,
   POL.global_attribute15,
   POL.global_attribute16,
   POL.global_attribute17,
   POL.global_attribute18,
   POL.global_attribute19,
   POL.global_attribute2,
   POL.global_attribute20,
   POL.global_attribute3,
   POL.global_attribute4,
   POL.global_attribute5,
   POL.global_attribute6,
   POL.global_attribute7,
   POL.global_attribute8,
   POL.global_attribute9,
   POL.global_attribute_category,
   POL.government_context,
   POL.hazard_class_id,
   POL.item_description,
   POL.item_id,
   POL.item_revision,
   POL.job_id,
   POL.last_update_date,
   POL.last_update_login,
   POL.last_updated_by,
   POL.line_num,
   POL.line_reference_num,
   POL.line_type_id,
   POL.list_price_per_unit,
   POL.manual_price_change_flag, --<MANUAL PRICE OVERRIDE FPJ>
   POL.market_price,
   POL.max_order_quantity,
   POL.min_order_quantity,
   POL.min_release_amount,
   POL.negotiated_by_preparer_flag,
   POL.not_to_exceed_price,
   POL.note_to_vendor,
   POL.oke_contract_header_id,
   POL.oke_contract_version_id,
   POL.org_id,
   POL.over_tolerance_error_flag,
   POL.po_header_id,
   POL.po_line_id,
   POL.preferred_grade,
   POL.price_break_lookup_code,
   POL.price_type_lookup_code,
   POL.program_application_id,
   POL.program_id,
   POL.program_update_date,
   POL.project_id,
   POL.qc_grade,
   POL.qty_rcv_tolerance,
   POL.quantity,
   POL.quantity_committed,
   POL.reference_num,
   POL.request_id,
   POL.retroactive_date,
   POL.secondary_qty,
   POL.secondary_quantity,
   POL.secondary_unit_of_measure,
   POL.secondary_uom,
   POL.start_date,
   -- <SVC_NOTIFICATIONS START>
   POL.svc_amount_notif_sent,
   POL.svc_completion_notif_sent,
   -- <SVC_NOTIFICATIONS END>
   POL.supplier_ref_number,
   POL.task_id,
   POL.tax_code_id,
   POL.tax_name,
   POL.taxable_flag,
   POL.transaction_reason_code,
   POL.type_1099,
   POL.un_number_id,
   POL.unit_meas_lookup_code,
   POL.unit_price,
   POL.unordered_flag,
   POL.user_hold_flag,
   POL.vendor_product_num,
   'Y',
   p_revision_num,
   POL.order_type_lookup_code, -- <Complex Work R12>
   POL.matching_basis,         -- <Complex Work R12>
   POL.purchase_basis,         -- <Complex Work R12>
   POL.max_retainage_amount,   -- <Complex Work R12>
   POL.retainage_rate,         -- <Complex Work R12>
   POL.progress_payment_rate,  -- <Complex Work R12>
   POL.recoupment_rate         -- <Complex Work R12>
   , POL.catalog_name          --<Unified Catalog R12>
   , POL.supplier_part_auxid   --<Unified Catalog R12>
   , POL.ip_category_id        --<Unified Catalog R12>
   , POL.last_updated_program  --<Unified Catalog R12>
 FROM  PO_LINES_ALL POL,
       PO_LINES_ARCHIVE_ALL POLA
 WHERE POL.po_header_id              = p_document_id
 AND   POL.po_line_id                = POLA.po_line_id (+)
 AND   POLA.latest_external_flag (+) = 'Y'
 AND   ((POLA.po_line_id is NULL) OR
        (POL.amount IS NULL AND POLA.amount IS NOT NULL OR
         POL.amount IS NOT NULL AND POLA.amount IS NULL OR
         POL.amount <> POLA.amount) OR
        -- <FPJ Advanced Price START>
        (POL.base_unit_price IS NULL AND POLA.base_unit_price IS NOT NULL OR
         POL.base_unit_price IS NOT NULL AND POLA.base_unit_price IS NULL OR
         POL.base_unit_price <> POLA.base_unit_price) OR
        -- <FPJ Advanced Price END>
        (POL.cancel_flag IS NULL AND POLA.cancel_flag IS NOT NULL OR
         POL.cancel_flag IS NOT NULL AND POLA.cancel_flag IS NULL OR
         POL.cancel_flag <> POLA.cancel_flag) OR
        (POL.closed_flag IS NULL AND POLA.closed_flag IS NOT NULL OR
         POL.closed_flag IS NOT NULL AND POLA.closed_flag IS NULL OR
         POL.closed_flag <> POLA.closed_flag) OR
        (POL.committed_amount IS NULL AND POLA.committed_amount IS NOT NULL OR
         POL.committed_amount IS NOT NULL AND POLA.committed_amount IS NULL OR
         POL.committed_amount <> POLA.committed_amount) OR
        (POL.contract_id IS NULL AND POLA.contract_id IS NOT NULL OR
         POL.contract_id IS NOT NULL AND POLA.contract_id IS NULL OR
         POL.contract_id <> POLA.contract_id) OR
        (POL.contractor_first_name IS NULL AND POLA.contractor_first_name IS NOT NULL OR
         POL.contractor_first_name IS NOT NULL AND POLA.contractor_first_name IS NULL OR
         POL.contractor_first_name <> POLA.contractor_first_name) OR
        (POL.contractor_last_name IS NULL AND POLA.contractor_last_name IS NOT NULL OR
         POL.contractor_last_name IS NOT NULL AND POLA.contractor_last_name IS NULL OR
         POL.contractor_last_name <> POLA.contractor_last_name) OR
        (POL.expiration_date IS NULL AND POLA.expiration_date IS NOT NULL OR
         POL.expiration_date IS NOT NULL AND POLA.expiration_date IS NULL OR
         POL.expiration_date <> POLA.expiration_date) OR
        (POL.from_header_id IS NULL AND POLA.from_header_id IS NOT NULL OR
         POL.from_header_id IS NOT NULL AND POLA.from_header_id IS NULL OR
         POL.from_header_id <> POLA.from_header_id) OR
        (POL.from_line_id IS NULL AND POLA.from_line_id IS NOT NULL OR
         POL.from_line_id IS NOT NULL AND POLA.from_line_id IS NULL OR
         POL.from_line_id <> POLA.from_line_id) OR
        (POL.hazard_class_id IS NULL AND POLA.hazard_class_id IS NOT NULL OR
         POL.hazard_class_id IS NOT NULL AND POLA.hazard_class_id IS NULL OR
         POL.hazard_class_id <> POLA.hazard_class_id) OR
        (POL.item_description IS NULL AND POLA.item_description IS NOT NULL OR
         POL.item_description IS NOT NULL AND POLA.item_description IS NULL OR
         POL.item_description <> POLA.item_description) OR
        (POL.item_id IS NULL AND POLA.item_id IS NOT NULL OR
         POL.item_id IS NOT NULL AND POLA.item_id IS NULL OR
         POL.item_id <> POLA.item_id) OR
        (POL.item_revision IS NULL AND POLA.item_revision IS NOT NULL OR
         POL.item_revision IS NOT NULL AND POLA.item_revision IS NULL OR
         POL.item_revision <> POLA.item_revision) OR
        (POL.job_id IS NULL AND POLA.job_id IS NOT NULL OR
         POL.job_id IS NOT NULL AND POLA.job_id IS NULL OR
         POL.job_id <> POLA.job_id) OR
        (POL.line_num IS NULL AND POLA.line_num IS NOT NULL OR
         POL.line_num IS NOT NULL AND POLA.line_num IS NULL OR
         POL.line_num <> POLA.line_num) OR
        (POL.note_to_vendor IS NULL AND POLA.note_to_vendor IS NOT NULL OR
         POL.note_to_vendor IS NOT NULL AND POLA.note_to_vendor IS NULL OR
         POL.note_to_vendor <> POLA.note_to_vendor) OR
        (POL.price_type_lookup_code IS NULL AND POLA.price_type_lookup_code IS NOT NULL OR
         POL.price_type_lookup_code IS NOT NULL AND POLA.price_type_lookup_code IS NULL OR
         POL.price_type_lookup_code <> POLA.price_type_lookup_code) OR
        (POL.quantity IS NULL AND POLA.quantity IS NOT NULL OR
         POL.quantity IS NOT NULL AND POLA.quantity IS NULL OR
         POL.quantity <> POLA.quantity) OR
        (POL.quantity_committed IS NULL AND POLA.quantity_committed IS NOT NULL OR
         POL.quantity_committed IS NOT NULL AND POLA.quantity_committed IS NULL OR
         POL.quantity_committed <> POLA.quantity_committed) OR
        (POL.start_date IS NULL AND POLA.start_date IS NOT NULL OR
         POL.start_date IS NOT NULL AND POLA.start_date IS NULL OR
         POL.start_date <> POLA.start_date) OR
        (POL.unit_meas_lookup_code IS NULL AND POLA.unit_meas_lookup_code IS NOT NULL OR
         POL.unit_meas_lookup_code IS NOT NULL AND POLA.unit_meas_lookup_code IS NULL OR
         POL.unit_meas_lookup_code <> POLA.unit_meas_lookup_code) OR
        (POL.unit_price IS NULL AND POLA.unit_price IS NOT NULL OR
         POL.unit_price IS NOT NULL AND POLA.unit_price IS NULL OR
         POL.unit_price <> POLA.unit_price) OR
        -- Bug 3471211
        (POL.not_to_exceed_price IS NULL AND POLA.not_to_exceed_price IS NOT NULL OR
         POL.not_to_exceed_price IS NOT NULL AND POLA.not_to_exceed_price IS NULL OR
         POL.not_to_exceed_price <> POLA.not_to_exceed_price) OR
        (POL.un_number_id IS NULL AND POLA.un_number_id IS NOT NULL OR
         POL.un_number_id IS NOT NULL AND POLA.un_number_id IS NULL OR
         POL.un_number_id <> POLA.un_number_id) OR
        (POL.vendor_product_num IS NULL AND POLA.vendor_product_num IS NOT NULL OR
         POL.vendor_product_num IS NOT NULL AND POLA.vendor_product_num IS NULL OR
         POL.vendor_product_num <> POLA.vendor_product_num) OR
         -- <Complex Work R12 Start>
        (POL.max_retainage_amount IS NULL AND POLA.max_retainage_amount IS NOT NULL OR
         POL.max_retainage_amount IS NOT NULL AND POLA.max_retainage_amount IS NULL OR
         POL.max_retainage_amount <> POLA.max_retainage_amount) OR
        (POL.retainage_rate IS NULL AND POLA.retainage_rate IS NOT NULL OR
         POL.retainage_rate IS NOT NULL AND POLA.retainage_rate IS NULL OR
         POL.retainage_rate <> POLA.retainage_rate) OR
        (POL.progress_payment_rate IS NULL AND POLA.progress_payment_rate IS NOT NULL OR
         POL.progress_payment_rate IS NOT NULL AND POLA.progress_payment_rate IS NULL OR
         POL.progress_payment_rate <> POLA.progress_payment_rate) OR
        (POL.recoupment_rate IS NULL AND POLA.recoupment_rate IS NOT NULL OR
         POL.recoupment_rate IS NOT NULL AND POLA.recoupment_rate IS NULL OR
         POL.recoupment_rate <> POLA.recoupment_rate) OR
         -- <Complex Work R12 End>
         -- <SVC_NOTIFICATIONS START>
         ((POL.svc_amount_notif_sent IS NULL AND
           POLA.svc_amount_notif_sent IS NOT NULL) OR
          (POL.svc_amount_notif_sent IS NOT NULL AND
           POLA.svc_amount_notif_sent IS NULL) OR
          (POL.svc_amount_notif_sent <> POLA.svc_amount_notif_sent)) OR
         ((POL.svc_completion_notif_sent IS NULL AND
           POLA.svc_completion_notif_sent IS NOT NULL) OR
          (POL.svc_completion_notif_sent IS NOT NULL AND
           POLA.svc_completion_notif_sent IS NULL) OR
          (POL.svc_completion_notif_sent <> POLA.svc_completion_notif_sent))
         -- <SVC_NOTIFICATIONS END>
		 /*14222356 reverting the fix made in 7286203 to archive change in closed_code since this is causing the change order report to print closed lines without other changes which is not relevent
         (POL.closed_code IS NULL AND POLA.closed_code IS NOT NULL OR
          POL.closed_code IS NOT NULL AND POLA.closed_code IS NULL OR
          POL.closed_code <> POLA.closed_code) --Bug7286203*/
         );

  l_continue := (SQL%ROWCOUNT > 0);

  IF l_continue THEN
    l_progress := '020';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'Update PO_LINES_ARCHIVE to reset latest_external_flag');
    END IF;

    -- If a row was inserted into PO_LINES_ARCHIVE, then set the appropriate flags
    UPDATE PO_LINES_ARCHIVE_ALL POL1
    SET    latest_external_flag = 'N'
    WHERE  po_header_id         = p_document_id
    AND    latest_external_flag = 'Y'
    AND    revision_num         < p_revision_num
    AND    EXISTS
           (SELECT 'A new archived row'
            FROM   PO_LINES_ARCHIVE_ALL POL2
            WHERE  POL2.po_line_id           = POL1.po_line_id
            AND    POL2.latest_external_flag = 'Y'
            AND    POL2.revision_num         = p_revision_num);
  ELSE
    l_progress := '030';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'No need to reset latest_external_flag');
    END IF;
  END IF; /* IF l_continue */

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of ARCHIVE_LINES()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    RAISE;
END ARCHIVE_LINES;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ARCHIVE_LINE_LOCATIONS
--Pre-reqs:
--  None.
--Modifies:
--  PO_LINE_LOCATIONS_ARCHIVE
--Locks:
--  None.
--Function:
--  Arcives the po document line locations.
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived.
--p_document_type
--  The type of the document to archive
--    PO : For Standard/Planned
--    PA : For Blanket/Contract
--    RELEASE : Release
--p_revision_num
--  The revision of the document that needs to be archived.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ARCHIVE_LINE_LOCATIONS(p_document_id    IN NUMBER,
         p_document_type  IN VARCHAR2,
               p_revision_num   IN NUMBER)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_LINE_LOCATIONS';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_revision_num  NUMBER;
  l_continue    BOOLEAN := FALSE;

BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'INSERT PO_LINE_LOCATIONS_ARCHIVE');
  END IF;

  INSERT INTO PO_LINE_LOCATIONS_ARCHIVE_ALL
  (accrue_on_receipt_flag,
   allow_substitute_receipts_flag,
   amount,
   amount_accepted,
   amount_billed,
   amount_cancelled,
   amount_received,
   amount_rejected,
   approved_date,
   approved_flag,
   attribute1,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute_category,
   calculate_tax_flag,
   cancel_date,
   cancel_flag,
   cancel_reason,
   cancelled_by,
   change_promised_date_reason,
   closed_by,
   closed_code,
   closed_date,
   closed_flag,
   closed_reason,
   consigned_flag,
   country_of_origin_code,
   created_by,
   creation_date,
   days_early_receipt_allowed,
   days_late_receipt_allowed,
   drop_ship_flag,
   encumber_now,
   encumbered_date,
   encumbered_flag,
   end_date,
   enforce_ship_to_location_code,
   estimated_tax_amount,
   final_match_flag,  --<BUG 3431828>
   firm_date,
   firm_status_lookup_code,
   fob_lookup_code,
   freight_terms_lookup_code,
   from_header_id,
   from_line_id,
   from_line_location_id,
   global_attribute1,
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
   global_attribute2,
   global_attribute20,
   global_attribute3,
   global_attribute4,
   global_attribute5,
   global_attribute6,
   global_attribute7,
   global_attribute8,
   global_attribute9,
   global_attribute_category,
   government_context,
   inspection_required_flag,
   invoice_close_tolerance,
   last_accept_date,
   last_update_date,
   last_update_login,
   last_updated_by,
   lead_time,
   lead_time_unit,
   line_location_id,
   manual_price_change_flag, --<MANUAL PRICE OVERRIDE FPJ>
   match_option,
   need_by_date,
   note_to_receiver,
   org_id,
   po_header_id,
   po_line_id,
   po_release_id,
   preferred_grade,
   price_discount,
   price_override,
   program_application_id,
   program_id,
   program_update_date,
   promised_date,
   qty_rcv_exception_code,
   qty_rcv_tolerance,
   quantity,
   quantity_accepted,
   quantity_billed,
   quantity_cancelled,
   quantity_received,
   quantity_rejected,
   quantity_shipped,
   receipt_days_exception_code,
   receipt_required_flag,
   receive_close_tolerance,
   receiving_routing_id,
   request_id,
   retroactive_date,
   sales_order_update_date,
   secondary_quantity,
   secondary_quantity_accepted,
   secondary_quantity_cancelled,
   secondary_quantity_received,
   secondary_quantity_rejected,
   secondary_unit_of_measure,
   ship_to_location_id,
   ship_to_organization_id,
   ship_via_lookup_code,
   shipment_num,
   shipment_type,
   source_shipment_id,
   start_date,
   supplier_order_line_number,
   tax_code_id,
   tax_user_override_flag,
   taxable_flag,
   terms_id,
   transaction_flow_header_id,
   unencumbered_quantity,
   unit_meas_lookup_code,
   unit_of_measure_class,
   vmi_flag,
   latest_external_flag,
   revision_num
   --<DBI Req Fulfillment 11.5.11 Start>
   ,shipment_closed_date
   ,closed_for_receiving_date
   ,closed_for_invoice_date
   --<DBI Req Fulfillment 11.5.11 End>
   -- <Complex Work R12 Start>
   , value_basis
   , matching_basis
   , description
   , payment_type
   , work_approver_id
   , bid_payment_id
   , quantity_financed
   , amount_financed
   , quantity_recouped
   , amount_recouped
   , retainage_withheld_amount
   , retainage_released_amount
   -- <Complex work R12 End>
   , outsourced_assembly --<SHIKYU R12>
  )
  SELECT
   POL.accrue_on_receipt_flag,
   POL.allow_substitute_receipts_flag,
   POL.amount,
   POL.amount_accepted,
   POL.amount_billed,
   POL.amount_cancelled,
   POL.amount_received,
   POL.amount_rejected,
   POL.approved_date,
   POL.approved_flag,
   POL.attribute1,
   POL.attribute10,
   POL.attribute11,
   POL.attribute12,
   POL.attribute13,
   POL.attribute14,
   POL.attribute15,
   POL.attribute2,
   POL.attribute3,
   POL.attribute4,
   POL.attribute5,
   POL.attribute6,
   POL.attribute7,
   POL.attribute8,
   POL.attribute9,
   POL.attribute_category,
   POL.calculate_tax_flag,
   POL.cancel_date,
   POL.cancel_flag,
   POL.cancel_reason,
   POL.cancelled_by,
   POL.change_promised_date_reason,
   POL.closed_by,
   POL.closed_code,
   POL.closed_date,
   POL.closed_flag,
   POL.closed_reason,
   POL.consigned_flag,
   POL.country_of_origin_code,
   POL.created_by,
   POL.creation_date,
   POL.days_early_receipt_allowed,
   POL.days_late_receipt_allowed,
   POL.drop_ship_flag,
   POL.encumber_now,
   POL.encumbered_date,
   POL.encumbered_flag,
   POL.end_date,
   POL.enforce_ship_to_location_code,
   POL.estimated_tax_amount,
   POL.final_match_flag,  --<BUG 3431828>
   POL.firm_date,
   POL.firm_status_lookup_code,
   POL.fob_lookup_code,
   POL.freight_terms_lookup_code,
   POL.from_header_id,
   POL.from_line_id,
   POL.from_line_location_id,
   POL.global_attribute1,
   POL.global_attribute10,
   POL.global_attribute11,
   POL.global_attribute12,
   POL.global_attribute13,
   POL.global_attribute14,
   POL.global_attribute15,
   POL.global_attribute16,
   POL.global_attribute17,
   POL.global_attribute18,
   POL.global_attribute19,
   POL.global_attribute2,
   POL.global_attribute20,
   POL.global_attribute3,
   POL.global_attribute4,
   POL.global_attribute5,
   POL.global_attribute6,
   POL.global_attribute7,
   POL.global_attribute8,
   POL.global_attribute9,
   POL.global_attribute_category,
   POL.government_context,
   POL.inspection_required_flag,
   POL.invoice_close_tolerance,
   POL.last_accept_date,
   POL.last_update_date,
   POL.last_update_login,
   POL.last_updated_by,
   POL.lead_time,
   POL.lead_time_unit,
   POL.line_location_id,
   POL.manual_price_change_flag, --<MANUAL PRICE OVERRIDE FPJ>
   POL.match_option,
   POL.need_by_date,
   POL.note_to_receiver,
   POL.org_id,
   POL.po_header_id,
   POL.po_line_id,
   POL.po_release_id,
   POL.preferred_grade,
   POL.price_discount,
   POL.price_override,
   POL.program_application_id,
   POL.program_id,
   POL.program_update_date,
   POL.promised_date,
   POL.qty_rcv_exception_code,
   POL.qty_rcv_tolerance,
   POL.quantity,
   POL.quantity_accepted,
   POL.quantity_billed,
   POL.quantity_cancelled,
   POL.quantity_received,
   POL.quantity_rejected,
   POL.quantity_shipped,
   POL.receipt_days_exception_code,
   POL.receipt_required_flag,
   POL.receive_close_tolerance,
   POL.receiving_routing_id,
   POL.request_id,
   POL.retroactive_date,
   POL.sales_order_update_date,
   POL.secondary_quantity,
   POL.secondary_quantity_accepted,
   POL.secondary_quantity_cancelled,
   POL.secondary_quantity_received,
   POL.secondary_quantity_rejected,
   POL.secondary_unit_of_measure,
   POL.ship_to_location_id,
   POL.ship_to_organization_id,
   POL.ship_via_lookup_code,
   POL.shipment_num,
   POL.shipment_type,
   POL.source_shipment_id,
   POL.start_date,
   POL.supplier_order_line_number,
   POL.tax_code_id,
   POL.tax_user_override_flag,
   POL.taxable_flag,
   POL.terms_id,
   POL.transaction_flow_header_id,
   POL.unencumbered_quantity,
   POL.unit_meas_lookup_code,
   POL.unit_of_measure_class,
   POL.vmi_flag,
   'Y',
   p_revision_num
   --<DBI Req Fulfillment 11.5.11 Start>
   ,POL.shipment_closed_date
   ,POL.closed_for_receiving_date
   ,POL.closed_for_invoice_date
   --<DBI Req Fulfillment 11.5.11 End>
   -- <Complex Work R12 Start>
   , POL.value_basis
   , POL.matching_basis
   , POL.description
   , POL.payment_type
   , POL.work_approver_id
   , POL.bid_payment_id
   , POL.quantity_financed
   , POL.amount_financed
   , POL.quantity_recouped
   , POL.amount_recouped
   , POL.retainage_withheld_amount
   , POL.retainage_released_amount
   -- <Complex work R12 End>
   , POL.outsourced_assembly --<SHIKYU R12>
 FROM  PO_LINE_LOCATIONS_ALL POL,
       PO_LINE_LOCATIONS_ARCHIVE_ALL POLA
 WHERE ((p_document_type = 'RELEASE' AND
         POL.po_release_id = p_document_id) OR
  (p_document_type <> 'RELEASE' AND         -- Bug 3210749
   POL.po_header_id = p_document_id AND
     POL.po_release_id IS NULL))
 AND   POL.line_location_id          = POLA.line_location_id (+)
 AND   POLA.latest_external_flag (+) = 'Y'
 AND   ((POLA.line_location_id is NULL) OR
        (POL.amount IS NULL AND POLA.amount IS NOT NULL OR
         POL.amount IS NOT NULL AND POLA.amount IS NULL OR
         POL.amount <> POLA.amount) OR
        (POL.cancel_flag IS NULL AND POLA.cancel_flag IS NOT NULL OR
         POL.cancel_flag IS NOT NULL AND POLA.cancel_flag IS NULL OR
         POL.cancel_flag <> POLA.cancel_flag) OR
        (POL.end_date IS NULL AND POLA.end_date IS NOT NULL OR
         POL.end_date IS NOT NULL AND POLA.end_date IS NULL OR
         POL.end_date <> POLA.end_date) OR
        (POL.last_accept_date IS NULL AND POLA.last_accept_date IS NOT NULL OR
         POL.last_accept_date IS NOT NULL AND POLA.last_accept_date IS NULL OR
         POL.last_accept_date <> POLA.last_accept_date) OR
        (POL.need_by_date IS NULL AND POLA.need_by_date IS NOT NULL OR
         POL.need_by_date IS NOT NULL AND POLA.need_by_date IS NULL OR
         POL.need_by_date <> POLA.need_by_date) OR
        (POL.price_override IS NULL AND POLA.price_override IS NOT NULL OR
         POL.price_override IS NOT NULL AND POLA.price_override IS NULL OR
         POL.price_override <> POLA.price_override) OR
        (POL.promised_date IS NULL AND POLA.promised_date IS NOT NULL OR
         POL.promised_date IS NOT NULL AND POLA.promised_date IS NULL OR
         POL.promised_date <> POLA.promised_date) OR
        (POL.quantity IS NULL AND POLA.quantity IS NOT NULL OR
         POL.quantity IS NOT NULL AND POLA.quantity IS NULL OR
         POL.quantity <> POLA.quantity) OR
        (POL.shipment_num IS NULL AND POLA.shipment_num IS NOT NULL OR
         POL.shipment_num IS NOT NULL AND POLA.shipment_num IS NULL OR
         POL.shipment_num <> POLA.shipment_num) OR
        --<Complex Work R12 Start>
        (POL.payment_type IS NULL AND POLA.payment_type IS NOT NULL OR
         POL.payment_type IS NOT NULL AND POLA.payment_type IS NULL OR
         POL.payment_type <> POLA.payment_type) OR
        (POL.description IS NULL AND POLA.description IS NOT NULL OR
         POL.description IS NOT NULL AND POLA.description IS NULL OR
         POL.description <> POLA.description) OR
        (POL.work_approver_id IS NULL AND POLA.work_approver_id IS NOT NULL OR
         POL.work_approver_id IS NOT NULL AND POLA.work_approver_id IS NULL OR
         POL.work_approver_id <> POLA.work_approver_id) OR
        --<Complex Work R12 End>
        (POL.ship_to_location_id IS NULL AND POLA.ship_to_location_id IS NOT NULL OR
         POL.ship_to_location_id IS NOT NULL AND POLA.ship_to_location_id IS NULL OR
         POL.ship_to_location_id <> POLA.ship_to_location_id) OR
        (POL.start_date IS NULL AND POLA.start_date IS NOT NULL OR
         POL.start_date IS NOT NULL AND POLA.start_date IS NULL OR
         POL.start_date <> POLA.start_date) OR
        (POL.taxable_flag IS NULL AND POLA.taxable_flag IS NOT NULL OR
         POL.taxable_flag IS NOT NULL AND POLA.taxable_flag IS NULL OR
         POL.taxable_flag <> POLA.taxable_flag) OR
       (POL.sales_order_update_date IS NULL AND POLA.sales_order_update_date IS NOT NULL OR --BUG7286203
         POL.sales_order_update_date IS NOT NULL AND POLA.sales_order_update_date IS NULL OR
         POL.sales_order_update_date <> POLA.sales_order_update_date));

  l_continue := (SQL%ROWCOUNT > 0);

  IF l_continue THEN
    l_progress := '020';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'Update PO_LINE_LOCATIONS_ARCHIVE to reset latest_external_flag');
    END IF;


    -- If a row was inserted into PO_LINES_ARCHIVE, then set the appropriate flags

    -- Start Bug 3648767: Split up update statement on p_document_type
    -- so that the the cost-based optimizer will choose to
    -- use the indexes on po_release_id and po_header_id.
    -- Comments removed for bug 3210749

    IF (p_document_type = 'RELEASE') THEN

      UPDATE PO_LINE_LOCATIONS_ARCHIVE_ALL POL1
        SET  latest_external_flag = 'N'
      WHERE  po_release_id = p_document_id
        AND  latest_external_flag = 'Y'
        AND  revision_num < p_revision_num
        AND  EXISTS
           (SELECT 'A new archived row'
            FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL POL2
            WHERE  POL2.line_location_id     = POL1.line_location_id
            AND    POL2.latest_external_flag = 'Y'
            AND    POL2.revision_num         = p_revision_num
           );

    ELSE
      -- p_document_type <> 'RELEASE'

      UPDATE PO_LINE_LOCATIONS_ARCHIVE_ALL POL1
        SET  latest_external_flag = 'N'
      WHERE ((po_header_id = p_document_id) AND (po_release_id IS NULL))
        AND  latest_external_flag = 'Y'
        AND  revision_num < p_revision_num
        AND  EXISTS
           (SELECT 'A new archived row'
            FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL POL2
            WHERE  POL2.line_location_id     = POL1.line_location_id
            AND    POL2.latest_external_flag = 'Y'
            AND    POL2.revision_num         = p_revision_num
           );

    END IF;  -- IF p_document_type = 'RELEASE'

    -- End Bug 3648767

  ELSE
    l_progress := '030';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'No need to reset latest_external_flag');
    END IF;
  END IF; /* IF l_continue */

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of ARCHIVE_LINE_LOCATIONS()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    RAISE;

END ARCHIVE_LINE_LOCATIONS;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ARCHIVE_DISTRIBUTIONS
--Pre-reqs:
--  None.
--Modifies:
--  PO_DISTRIBUTIONS_ARCHIVE
--Locks:
--  None.
--Function:
--  Arcives the po document distributions.
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived.
--p_document_type
--  The type of the document to archive
--    PO : For Standard/Planned
--    PA : For Blanket/Contract
--    RELEASE : Release
--p_revision_num
--  The revision of the document that needs to be archived.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ARCHIVE_DISTRIBUTIONS(p_document_id   IN NUMBER,
        p_document_type   IN VARCHAR2,
              p_revision_num    IN NUMBER)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_DISTRIBUTIONS';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_revision_num  NUMBER;
  l_continue    BOOLEAN := FALSE;

  -- Bug 3648552
  l_po_header_id  PO_HEADERS_ALL.po_header_id%TYPE;
  l_po_release_id PO_RELEASES_ALL.po_release_id%TYPE;


BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'INSERT PO_DISTRIBUTIONS_ARCHIVE');
  END IF;

  INSERT INTO PO_DISTRIBUTIONS_ARCHIVE_ALL
  (accrual_account_id,
   accrue_on_receipt_flag,
   accrued_flag,
   amount_billed,
   amount_cancelled,
   amount_delivered,
   amount_ordered,
   amount_to_encumber,
   attribute1,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute_category,
   award_id,
   bom_resource_id,
   budget_account_id,
   code_combination_id,
   created_by,
   creation_date,
   deliver_to_location_id,
   deliver_to_person_id,
   destination_context,
   destination_organization_id,
   destination_subinventory,
   destination_type_code,
   distribution_num,
   distribution_type,
   encumbered_amount,
   encumbered_flag,
   end_item_unit_number,
   expenditure_item_date,
   expenditure_organization_id,
   expenditure_type,
   failed_funds_lookup_code,
   gl_cancelled_date,
   gl_closed_date,
   gl_encumbered_date,
   gl_encumbered_period_name,
   government_context,
   invoice_adjustment_flag,
   kanban_card_id,
   last_update_date,
   last_update_login,
   last_updated_by,
   line_location_id,
   mrc_encumbered_amount,
   mrc_rate,
   mrc_rate_date,
   mrc_unencumbered_amount,
   nonrecoverable_tax,
   oke_contract_deliverable_id,
   oke_contract_line_id,
   org_id,
   po_distribution_id,
   po_header_id,
   po_line_id,
   po_release_id,
   prevent_encumbrance_flag,
   program_application_id,
   program_id,
   program_update_date,
   project_accounting_context,
   project_id,
   quantity_billed,
   quantity_cancelled,
   quantity_delivered,
   quantity_ordered,
   rate,
   rate_date,
   recoverable_tax,
   recovery_rate,
   req_distribution_id,
   req_header_reference_num,
   req_line_reference_num,
   request_id,
   set_of_books_id,
   source_distribution_id,
   task_id,
   tax_recovery_override_flag,
   unencumbered_amount,
   unencumbered_quantity,
   variance_account_id,
   wip_entity_id,
   wip_line_id,
   wip_operation_seq_num,
   wip_repetitive_schedule_id,
   wip_resource_seq_num,
   latest_external_flag,
   revision_num,
   -- <Complex Work R12 Start>
   quantity_financed,
   amount_financed,
   quantity_recouped,
   amount_recouped,
   retainage_withheld_amount,
   retainage_released_amount,
   -- <Complex Work R12 End>
    GLOBAL_ATTRIBUTE_CATEGORY,
    GLOBAL_ATTRIBUTE1,
    GLOBAL_ATTRIBUTE2,
    GLOBAL_ATTRIBUTE3,
    GLOBAL_ATTRIBUTE4,
    GLOBAL_ATTRIBUTE5,
    GLOBAL_ATTRIBUTE6,
    GLOBAL_ATTRIBUTE7,
    GLOBAL_ATTRIBUTE8,
    GLOBAL_ATTRIBUTE9,
    GLOBAL_ATTRIBUTE10,
    GLOBAL_ATTRIBUTE11,
    GLOBAL_ATTRIBUTE12,
    GLOBAL_ATTRIBUTE13,
    GLOBAL_ATTRIBUTE14,
    GLOBAL_ATTRIBUTE15,
    GLOBAL_ATTRIBUTE16,
    GLOBAL_ATTRIBUTE17,
    GLOBAL_ATTRIBUTE18,
    GLOBAL_ATTRIBUTE19,
    GLOBAL_ATTRIBUTE20
)
  SELECT
   POD.accrual_account_id,
   POD.accrue_on_receipt_flag,
   POD.accrued_flag,
   POD.amount_billed,
   POD.amount_cancelled,
   POD.amount_delivered,
   POD.amount_ordered,
   POD.amount_to_encumber,
   POD.attribute1,
   POD.attribute10,
   POD.attribute11,
   POD.attribute12,
   POD.attribute13,
   POD.attribute14,
   POD.attribute15,
   POD.attribute2,
   POD.attribute3,
   POD.attribute4,
   POD.attribute5,
   POD.attribute6,
   POD.attribute7,
   POD.attribute8,
   POD.attribute9,
   POD.attribute_category,
   POD.award_id,
   POD.bom_resource_id,
   POD.budget_account_id,
   POD.code_combination_id,
   POD.created_by,
   POD.creation_date,
   POD.deliver_to_location_id,
   POD.deliver_to_person_id,
   POD.destination_context,
   POD.destination_organization_id,
   POD.destination_subinventory,
   POD.destination_type_code,
   POD.distribution_num,
   POD.distribution_type,
   POD.encumbered_amount,
   POD.encumbered_flag,
   POD.end_item_unit_number,
   POD.expenditure_item_date,
   POD.expenditure_organization_id,
   POD.expenditure_type,
   POD.failed_funds_lookup_code,
   POD.gl_cancelled_date,
   POD.gl_closed_date,
   POD.gl_encumbered_date,
   POD.gl_encumbered_period_name,
   POD.government_context,
   POD.invoice_adjustment_flag,
   POD.kanban_card_id,
   POD.last_update_date,
   POD.last_update_login,
   POD.last_updated_by,
   POD.line_location_id,
   POD.mrc_encumbered_amount,
   POD.mrc_rate,
   POD.mrc_rate_date,
   POD.mrc_unencumbered_amount,
   POD.nonrecoverable_tax,
   POD.oke_contract_deliverable_id,
   POD.oke_contract_line_id,
   POD.org_id,
   POD.po_distribution_id,
   POD.po_header_id,
   POD.po_line_id,
   POD.po_release_id,
   POD.prevent_encumbrance_flag,
   POD.program_application_id,
   POD.program_id,
   POD.program_update_date,
   POD.project_accounting_context,
   POD.project_id,
   POD.quantity_billed,
   POD.quantity_cancelled,
   POD.quantity_delivered,
   POD.quantity_ordered,
   POD.rate,
   POD.rate_date,
   POD.recoverable_tax,
   POD.recovery_rate,
   POD.req_distribution_id,
   POD.req_header_reference_num,
   POD.req_line_reference_num,
   POD.request_id,
   POD.set_of_books_id,
   POD.source_distribution_id,
   POD.task_id,
   POD.tax_recovery_override_flag,
   POD.unencumbered_amount,
   POD.unencumbered_quantity,
   POD.variance_account_id,
   POD.wip_entity_id,
   POD.wip_line_id,
   POD.wip_operation_seq_num,
   POD.wip_repetitive_schedule_id,
   POD.wip_resource_seq_num,
   'Y',
   p_revision_num,
   -- <Complex Work R12 Start>
   POD.quantity_financed,
   POD.amount_financed,
   POD.quantity_recouped,
   POD.amount_recouped,
   POD.retainage_withheld_amount,
   POD.retainage_released_amount,
   -- <Complex Work R12 End>
   POD.GLOBAL_ATTRIBUTE_CATEGORY,
  POD.GLOBAL_ATTRIBUTE1,
  POD.GLOBAL_ATTRIBUTE2,
  POD.GLOBAL_ATTRIBUTE3,
  POD.GLOBAL_ATTRIBUTE4,
  POD.GLOBAL_ATTRIBUTE5,
  POD.GLOBAL_ATTRIBUTE6,
  POD.GLOBAL_ATTRIBUTE7,
  POD.GLOBAL_ATTRIBUTE8,
  POD.GLOBAL_ATTRIBUTE9,
  POD.GLOBAL_ATTRIBUTE10,
  POD.GLOBAL_ATTRIBUTE11,
  POD.GLOBAL_ATTRIBUTE12,
  POD.GLOBAL_ATTRIBUTE13,
  POD.GLOBAL_ATTRIBUTE14,
  POD.GLOBAL_ATTRIBUTE15,
  POD.GLOBAL_ATTRIBUTE16,
  POD.GLOBAL_ATTRIBUTE17,
  POD.GLOBAL_ATTRIBUTE18,
  POD.GLOBAL_ATTRIBUTE19,
  POD.GLOBAL_ATTRIBUTE20
 FROM  PO_DISTRIBUTIONS_ALL POD,
       PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
 WHERE ((p_document_type = 'RELEASE' AND
         POD.po_release_id = p_document_id) OR
  (p_document_type <> 'RELEASE' AND         -- Bug 3210749
   POD.po_header_id = p_document_id AND
     POD.po_release_id IS NULL))
 AND   POD.po_distribution_id = PODA.po_distribution_id (+)
 AND   PODA.latest_external_flag (+) = 'Y'
 AND   ((PODA.po_distribution_id is NULL) OR
        -- <Bug 4723667 start Removing the check for amount billed in version 120.9>
        (POD.amount_ordered IS NULL AND PODA.amount_ordered IS NOT NULL OR
         POD.amount_ordered IS NOT NULL AND PODA.amount_ordered IS NULL OR
         POD.amount_ordered <> PODA.amount_ordered) OR
        -- <Bug 3862108 START>
        (POD.amount_cancelled IS NULL AND PODA.amount_cancelled IS NOT NULL OR
         POD.amount_cancelled IS NOT NULL AND PODA.amount_cancelled IS NULL OR
         POD.amount_cancelled <> PODA.amount_cancelled) OR
        -- <Bug 3862108 END>
        (POD.deliver_to_person_id IS NULL AND PODA.deliver_to_person_id IS NOT NULL OR
         POD.deliver_to_person_id IS NOT NULL AND PODA.deliver_to_person_id IS NULL OR
         POD.deliver_to_person_id <> PODA.deliver_to_person_id) OR
        (POD.distribution_num IS NULL AND PODA.distribution_num IS NOT NULL OR
         POD.distribution_num IS NOT NULL AND PODA.distribution_num IS NULL OR
         POD.distribution_num <> PODA.distribution_num) OR
        -- <Bug 4723667 start Removing the check for quantity billed in version 120.9>
        (POD.quantity_ordered IS NULL AND PODA.quantity_ordered IS NOT NULL OR
         POD.quantity_ordered IS NOT NULL AND PODA.quantity_ordered IS NULL OR
         POD.quantity_ordered <> PODA.quantity_ordered) OR
        -- <Complex Work R12 Start>
        (POD.quantity_financed IS NULL AND PODA.quantity_financed IS NOT NULL OR
         POD.quantity_financed IS NOT NULL AND PODA.quantity_financed IS NULL OR
         POD.quantity_financed <> PODA.quantity_financed) OR
        (POD.amount_financed IS NULL AND PODA.amount_financed IS NOT NULL OR
         POD.amount_financed IS NOT NULL AND PODA.amount_financed IS NULL OR
         POD.amount_financed <> PODA.amount_financed) OR
        (POD.quantity_recouped IS NULL AND PODA.quantity_recouped IS NOT NULL OR
         POD.quantity_recouped IS NOT NULL AND PODA.quantity_recouped IS NULL OR
         POD.quantity_recouped <> PODA.quantity_recouped) OR
        (POD.amount_recouped IS NULL AND PODA.amount_recouped IS NOT NULL OR
         POD.amount_recouped IS NOT NULL AND PODA.amount_recouped IS NULL OR
         POD.amount_recouped <> PODA.amount_recouped) OR
        (POD.retainage_withheld_amount IS NULL AND PODA.retainage_withheld_amount IS NOT NULL OR
         POD.retainage_withheld_amount IS NOT NULL AND PODA.retainage_withheld_amount IS NULL OR
         POD.retainage_withheld_amount <> PODA.retainage_withheld_amount) OR
        (POD.retainage_released_amount IS NULL AND PODA.retainage_released_amount IS NOT NULL OR
         POD.retainage_released_amount IS NOT NULL AND PODA.retainage_released_amount IS NULL OR
         POD.retainage_released_amount <> PODA.retainage_released_amount) OR
        -- <Complex Work R12 End>
        -- <Bug 3862108 START>
        (POD.quantity_cancelled IS NULL AND PODA.quantity_cancelled IS NOT NULL OR
         POD.quantity_cancelled IS NOT NULL AND PODA.quantity_cancelled IS NULL OR
         POD.quantity_cancelled <> PODA.quantity_cancelled) OR
        -- <Bug 3862108 END>
        -- <Bug 3191712 START>
        (POD.nonrecoverable_tax IS NULL AND PODA.nonrecoverable_tax IS NOT NULL OR
         POD.nonrecoverable_tax IS NOT NULL AND PODA.nonrecoverable_tax IS NULL OR
         POD.nonrecoverable_tax <> PODA.nonrecoverable_tax) OR
        (POD.recoverable_tax IS NULL AND PODA.recoverable_tax IS NOT NULL OR
         POD.recoverable_tax IS NOT NULL AND PODA.recoverable_tax IS NULL OR
         POD.recoverable_tax <> PODA.recoverable_tax) OR
        -- <Bug 3191712 END>
        (POD.recovery_rate IS NULL AND PODA.recovery_rate IS NOT NULL OR --BUG7286203
         POD.recovery_rate IS NOT NULL AND PODA.recovery_rate IS NULL OR
         POD.recovery_rate <> PODA.recovery_rate)
       );

  l_continue := (SQL%ROWCOUNT > 0);

  IF l_continue THEN
    l_progress := '020';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'Update PO_DISTRIBUTIONS_ARCHIVE to reset latest_external_flag');
    END IF;

    -- Bug 3648552 START
    -- Get PO_HEADER_ID for Release since there is no index on
    -- PO_DISTRIBUTIONS_ARCHIVE_ALL.po_release_id
    IF (p_document_type = 'RELEASE') THEN
      SELECT po_header_id
      INTO  l_po_header_id
      FROM  po_releases_all
      WHERE  po_release_id = p_document_id;
      l_po_release_id := p_document_id;
    ELSE
      l_po_header_id := p_document_id;
      l_po_release_id := NULL;
    END IF;
    -- Bug 3648552 END

    -- If a row was inserted into PO_DISTRIBUTIONS_ARCHIVE, then set the appropriate flags
    UPDATE PO_DISTRIBUTIONS_ARCHIVE_ALL POD1
    SET    latest_external_flag = 'N'
    -- Bug 3648552 START
    WHERE  po_header_id = l_po_header_id
    -- Bug 3713788: fixed regression caused by bug 3648552
    AND    NVL(po_release_id, -99) = NVL(l_po_release_id, -99)
    -- Bug 3648552 END
    AND    latest_external_flag = 'Y'
    AND    revision_num < p_revision_num
    AND    EXISTS
           (SELECT 'A new archived row'
            FROM   PO_DISTRIBUTIONS_ARCHIVE_ALL POD2
            WHERE  POD2.po_distribution_id   = POD1.po_distribution_id
            AND    POD2.latest_external_flag = 'Y'
            AND    POD2.revision_num         = p_revision_num);
  ELSE
    l_progress := '030';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'No need to reset latest_external_flag');
    END IF;
  END IF; /* IF l_continue */

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of ARCHIVE_DISTRIBUTIONS()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    RAISE;
END ARCHIVE_DISTRIBUTIONS;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ARCHIVE_ORG_ASSIGNMENTS
--Pre-reqs:
--  None.
--Modifies:
--  PO_GA_ORG_ASSIGNMENTS_ARCHIVE
--Locks:
--  None.
--Function:
--  Arcives the global agreement org assignments.
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived.
--p_revision_num
--  The revision of the document that needs to be archived.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ARCHIVE_ORG_ASSIGNMENTS(p_document_id   IN NUMBER,
                p_revision_num  IN NUMBER)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_ORG_ASSIGNMENTS';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_revision_num  NUMBER;
  l_continue    BOOLEAN := FALSE;

BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'INSERT PO_GA_ORG_ASSIGNMENTS_ARCHIVE');
  END IF;

  INSERT INTO PO_GA_ORG_ASSIGNMENTS_ARCHIVE
  (org_assignment_id              , --<HTML Agreement R12>
   created_by       ,
   creation_date      ,
   enabled_flag       ,
   last_updated_by      ,
   last_update_date     ,
   last_update_login      ,
   organization_id      ,
   po_header_id       ,
   purchasing_org_id      ,
   vendor_site_id     ,
   latest_external_flag     ,
   revision_num       )
  SELECT
   POG.org_assignment_id          , --<HTML Agreement R12>
   POG.created_by     ,
   POG.creation_date      ,
   POG.enabled_flag     ,
   POG.last_updated_by      ,
   POG.last_update_date   ,
   POG.last_update_login    ,
   POG.organization_id      ,
   POG.po_header_id     ,
   POG.purchasing_org_id    ,
   POG.vendor_site_id     ,
   'Y'          ,
   p_revision_num
 FROM  PO_GA_ORG_ASSIGNMENTS POG,
       PO_GA_ORG_ASSIGNMENTS_ARCHIVE POGA
 WHERE POG.po_header_id = p_document_id
 --AND   POG.po_header_id = POGA.po_header_id (+)
 --AND   POG.organization_id = POGA.organization_id (+)
 AND  POG.org_assignment_id = POGA.org_assignment_id (+) --<HTML Agreement R12>
 AND   POGA.latest_external_flag (+) = 'Y'
 AND   ((POGA.po_header_id is NULL) OR
        (POG.enabled_flag IS NULL AND POGA.enabled_flag IS NOT NULL OR
         POG.enabled_flag IS NOT NULL AND POGA.enabled_flag IS NULL OR
         POG.enabled_flag <> POGA.enabled_flag) OR
        (POG.purchasing_org_id IS NULL AND POGA.purchasing_org_id IS NOT NULL OR
         POG.purchasing_org_id IS NOT NULL AND POGA.purchasing_org_id IS NULL OR
         POG.purchasing_org_id <> POGA.purchasing_org_id) OR
        (POG.vendor_site_id IS NULL AND POGA.vendor_site_id IS NOT NULL OR
         POG.vendor_site_id IS NOT NULL AND POGA.vendor_site_id IS NULL OR
         POG.vendor_site_id <> POGA.vendor_site_id));

  l_continue := (SQL%ROWCOUNT > 0);

  IF l_continue THEN
    l_progress := '020';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'Update PO_GA_ORG_ASSIGNMENTS_ARCHIVE to reset latest_external_flag');
    END IF;

    -- If a row was inserted into PO_GA_ORG_ASSIGNMENTS_ARCHIVE, then set the appropriate flags
    UPDATE PO_GA_ORG_ASSIGNMENTS_ARCHIVE POG1
    SET    latest_external_flag = 'N'
    WHERE  po_header_id = p_document_id
    AND    latest_external_flag = 'Y'
    AND    revision_num < p_revision_num
    AND    EXISTS
           (SELECT 'A new archived row'
            FROM   PO_GA_ORG_ASSIGNMENTS_ARCHIVE POG2
            WHERE  POG2.org_assignment_id = POG1.org_assignment_id --<HTML Agreement R12>
            -- POG2.po_header_id   = POG1.po_header_id
            --AND    POG2.organization_id = POG1.organization_id
            AND    POG2.latest_external_flag = 'Y'
            AND    POG2.revision_num         = p_revision_num);
  ELSE
    l_progress := '030';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'No need to reset latest_external_flag');
    END IF;
  END IF; /* IF l_continue */

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of ARCHIVE_ORG_ASSIGNMENTS()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    RAISE;
END ARCHIVE_ORG_ASSIGNMENTS;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ARCHIVE_PRICE_DIFFS
--Pre-reqs:
--  None.
--Modifies:
--  PO_PRICE_DIFFERENTIALS_ARCHIVE
--Locks:
--  None.
--Function:
--  Arcives the price differentials.
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived.
--p_entity_type
--  The entity type of the document that needs to be archived.
--p_revision_num
--  The revision of the document that needs to be archived.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ARCHIVE_PRICE_DIFFS(p_document_id IN NUMBER,
            p_entity_type IN VARCHAR,
            p_revision_num  IN NUMBER)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_PRICE_DIFFS';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_continue    BOOLEAN := FALSE;

BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'INSERT PO_PRICE_DIFFERENTIALS_ARCHIVE');
  END IF;

  INSERT INTO PO_PRICE_DIFFERENTIALS_ARCHIVE
  (created_by      ,
   creation_date     ,
   enabled_flag      ,
   entity_id       ,
   entity_type       ,
   last_update_date    ,
   last_update_login     ,
   last_updated_by     ,
   max_multiplier    ,
   min_multiplier    ,
   multiplier      ,
   price_differential_id   ,
   price_differential_num  ,
   price_type      ,
   latest_external_flag    ,
   revision_num      )
  SELECT
   POR.created_by    ,
   POR.creation_date     ,
   POR.enabled_flag    ,
   POR.entity_id     ,
   POR.entity_type     ,
   POR.last_update_date  ,
   POR.last_update_login   ,
   POR.last_updated_by     ,
   POR.max_multiplier    ,
   POR.min_multiplier    ,
   POR.multiplier    ,
   POR.price_differential_id   ,
   POR.price_differential_num  ,
   POR.price_type    ,
   'Y'         ,
   p_revision_num
 FROM  PO_PRICE_DIFFERENTIALS POR,
       PO_PRICE_DIFFERENTIALS_ARCHIVE PORA
 WHERE ((p_entity_type = 'PRICE BREAK' AND
         POR.entity_id IN (SELECT line_location_id
                           FROM   PO_LINE_LOCATIONS_ALL
                           WHERE  po_header_id = p_document_id)) OR
        (p_entity_type IN ('PO LINE', 'BLANKET LINE') AND
         POR.entity_id IN (SELECT po_line_id
                           FROM   PO_LINES_ALL
                           WHERE  po_header_id = p_document_id)))
 AND   POR.entity_type = p_entity_type
 AND   POR.price_differential_id = PORA.price_differential_id (+)
 AND   PORA.latest_external_flag (+) = 'Y'
 AND   ((PORA.price_differential_id is NULL) OR
        (POR.enabled_flag IS NULL AND PORA.enabled_flag IS NOT NULL OR
         POR.enabled_flag IS NOT NULL AND PORA.enabled_flag IS NULL OR
         POR.enabled_flag <> PORA.enabled_flag) OR
        (POR.price_type IS NULL AND PORA.price_type IS NOT NULL OR
         POR.price_type IS NOT NULL AND PORA.price_type IS NULL OR
         POR.price_type <> PORA.price_type) OR
        (POR.min_multiplier IS NULL AND PORA.min_multiplier IS NOT NULL OR
         POR.min_multiplier IS NOT NULL AND PORA.min_multiplier IS NULL OR
         POR.min_multiplier <> PORA.min_multiplier) OR
        (POR.max_multiplier IS NULL AND PORA.max_multiplier IS NOT NULL OR
         POR.max_multiplier IS NOT NULL AND PORA.max_multiplier IS NULL OR
         POR.max_multiplier <> PORA.max_multiplier) OR
        (POR.multiplier IS NULL AND PORA.multiplier IS NOT NULL OR
         POR.multiplier IS NOT NULL AND PORA.multiplier IS NULL OR
         POR.multiplier <> PORA.multiplier) OR
        (POR.price_differential_num IS NULL AND PORA.price_differential_num IS NOT NULL OR --BUG7286203
         POR.price_differential_num IS NOT NULL AND PORA.price_differential_num IS NULL OR
         POR.price_differential_num <> PORA.price_differential_num));

  l_continue := (SQL%ROWCOUNT > 0);

  IF l_continue THEN
    l_progress := '020';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'Update PO_PRICE_DIFFERENTIALS_ARCHIVE to reset latest_external_flag');
    END IF;

    -- If a row was inserted into PO_PRICE_DIFFERENTIALS_ARCHIVE, then set the appropriate flags
    UPDATE PO_PRICE_DIFFERENTIALS_ARCHIVE POR1
    SET    latest_external_flag = 'N'
    WHERE  ((p_entity_type = 'PRICE BREAK' AND
             entity_id IN (SELECT line_location_id
                           FROM   PO_LINE_LOCATIONS_ALL
                           WHERE  po_header_id = p_document_id)) OR
            (p_entity_type IN ('PO LINE', 'BLANKET LINE') AND
             entity_id IN (SELECT po_line_id
                           FROM   PO_LINES_ALL
                           WHERE  po_header_id = p_document_id)))
    AND    entity_type = p_entity_type
    AND    latest_external_flag = 'Y'
    AND    revision_num < p_revision_num
    AND    EXISTS
           (SELECT 'A new archived row'
            FROM   PO_PRICE_DIFFERENTIALS_ARCHIVE POR2
            WHERE  POR2.price_differential_id = POR1.price_differential_id
            AND    POR2.latest_external_flag  = 'Y'
            AND    POR2.revision_num          = p_revision_num);
  ELSE
    l_progress := '030';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'No need to reset latest_external_flag');
    END IF;
  END IF; /* IF l_continue */

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of ARCHIVE_PRICE_DIFFS()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    RAISE;
END ARCHIVE_PRICE_DIFFS;


-------------------------------------------------------------------------------
--Start of Comments
--Name: ARCHIVE_CONTRACT_TERMS
--Pre-reqs:
--  None.
--Modifies:
--  OKC Tables
--Locks:
--  None.
--Function:
--  Call OKC procedure to arcive the contract terms
--Parameters:
--IN:
--p_document_id
--  The id of the document that needs to be archived.
--p_document_type
--  The entity type of the document that needs to be archived.
--p_document_subtype
--  The entity subtype of the document that needs to be archived.
--p_revision_num
--  The revision of the document that needs to be archived.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ARCHIVE_CONTRACT_TERMS(p_document_id    IN NUMBER,
               p_document_type  IN VARCHAR,
               p_document_subtype   IN VARCHAR,
               p_revision_num   IN NUMBER)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_CONTRACT_TERMS';
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_return_status VARCHAR2(1);
  l_msg_count   NUMBER;
  l_msg_data    VARCHAR2(2000);
  l_conterms_exist_flag   PO_HEADERS_ALL.conterms_exist_flag%TYPE;
  l_pending_signature_flag  PO_HEADERS_ALL.pending_signature_flag%TYPE;
  l_clear_amendment VARCHAR2(1);


BEGIN

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Select conterms_exist_flag - po_header_id: '||p_document_id);
  END IF;
  -- SQL What:Find out if contract terms exist
  -- SQL Why :Archive Contract Terms if needed
  SELECT NVL(conterms_exist_flag, 'N'),
         NVL(pending_signature_flag, 'N')
  INTO   l_conterms_exist_flag,
         l_pending_signature_flag
  FROM   po_headers_all
  WHERE  po_header_id = p_document_id;

  IF (l_conterms_exist_flag = 'Y') THEN
    l_progress := '020';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'OKC_TERMS_VERSION_GRP.version_doc() p_document_id: '||
                     p_document_id||', p_revision_num: '||p_revision_num);
    END IF;

    -- Bug 3616320 START
    -- Always call the OKC_TERMS_VERSION_GRP.VERSION_DOC with
    -- p_clear_amendments = 'N' to version the document
    -- IF l_pending_signature_flag <> 'Y' THEN
    --   l_clear_amendment := 'Y';
    -- ELSE
    --   l_clear_amendment := 'N';
    -- END IF; /*IF l_pending_signature_flag <> 'Y'*/
    l_clear_amendment := 'N';
    -- Bug 3616320 END

    OKC_TERMS_VERSION_GRP.version_doc(p_api_version => 1.0,
                                      p_doc_id    => p_document_id,
                                      p_doc_type  => p_document_type||'_'||
                                                           p_document_subtype,
                                      p_version_number  => p_revision_num,
                                      p_clear_amendment => l_clear_amendment,
                                      x_return_status => l_return_status,
                                      x_msg_data  => l_msg_data,
                                      x_msg_count => l_msg_count,
                                      p_include_gen_attach => 'N' );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) Then
      IF (l_return_status = FND_API.G_RET_STS_ERROR) Then
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; /* IF (l_return_status = FND_API.G_RET_STS_ERROR) */
    END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

    IF (l_pending_signature_flag <> 'Y') THEN

      l_progress := '030';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'PO_CONTERMS_WF_PVT.update_contract_terms() p_po_header_id: '||
                       p_document_id);
      END IF;
      -- Activate Contract Terms Deliverables now that PO revision is archived
      --
      -- Inform Contracts to activate deliverable, now that PO is successfully
      -- archived
      PO_CONTERMS_WF_PVT.UPDATE_CONTRACT_TERMS(
                        p_po_header_id  => p_document_id,
                        p_signed_date => SYSDATE,
                        x_return_status => l_return_status,
                        x_msg_data  => l_msg_data,
                        x_msg_count => l_msg_count);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) Then
        IF (l_return_status = FND_API.G_RET_STS_ERROR) Then
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF; /* IF (l_return_status = FND_API.G_RET_STS_ERROR) */
      END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

    END IF; /*IF (l_pending_signature_flag <> 'Y')*/

  END IF; /*IF (l_conterms_exist_flag = 'Y')*/

  l_progress := '050';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of ARCHIVE_CONTRACT_TERMS()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    RAISE;
END ARCHIVE_CONTRACT_TERMS;


-------------------------------------------------------------------------------
--Start of Comments
--Name: archive_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Arcives the document. Inserts an copy of the document in the
--  archive tables.
--Parameters:
--IN:
--p_api_version
--  Version number of API that caller expects. It should match the
--  l_api_version defined in the procedure (expected value : 1.0)
--p_document_id
--  The id of the document that needs to be archived.
--p_document_type
--  The type of the document to archive
--    PO : For Standard/Planned
--    PA : For Blanket/Contract
--    RELEASE : Release
--p_document_subtype
--  The subtype of the document.
--  Valid Document types and Document subtypes are
--    Document Type      Document Subtype
--    RELEASE      --->  SCHEDULED/BLANKET
--    PO           --->  PLANNED/STANDARD
--    PA           --->  CONTRACT/BLANKET
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_count
--  returns count of messages in the stack.
--x_msg_data
--  Contains error msg in case x_return_status returned
--  FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
/*
* Set a savepoint;
*
* Check if the current revision is already archived.
* Case entity.document_type is
* When PO
*   Case entity.document_subtype is
*     When STANDARD or PLANNED
*       archive PO_HEADERS
*       when modified archive PO_LINES, PO_LINE_LOCATIONS,
*         PO_PRICE_DIFFERENTIALS and PO_DISTRIBUTIONS.
*   End Case
* When PA
*   Case entity.document_subtype is
*     When BLANKET
*       archive PO_HEADERS
*       when modified archive PO_LINES, PO_LINE_LOCATIONS, PO_PRICE_DIFFERENTIALS
*                                       (for price breaks)
*     When CONTRACT
*       archive PO_HEADERS
*   End Case
*   If global_agreement_flag = Y (i.e. global blanket or global contract) --<BUG 3290647>
*     When modified, archive PO_GA_ORG_ASSIGNMENT
* When RELEASE
*   archive PO_RELEASES
*   when modified archive PO_LINE_LOCATIONS and PO_DISTRIBUTIONS.
* End Case
*
* IF error happens, rollback to the savepoint;
*
*/

PROCEDURE archive_po(p_api_version         IN         NUMBER,
           p_document_id         IN         NUMBER,
           p_document_type       IN         VARCHAR2,
           p_document_subtype    IN         VARCHAR2,
           x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
           x_msg_data            OUT NOCOPY VARCHAR2)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'ARCHIVE_PO';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_module              VARCHAR2(100);
  l_progress    VARCHAR2(3);
  l_revision_num  NUMBER;
  l_return_status VARCHAR2(1);
  l_ga_flag   PO_HEADERS_ALL.global_agreement_flag%TYPE;

BEGIN

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  l_progress := '010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                    'Set SavePoint');
  END IF;

  --Standard Start API savepoint
  SAVEPOINT PO_ARCHIVE_SP;

  l_progress := '020';
  IF (p_document_type = 'PO') THEN
    l_progress := '030';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'check_po_archive(PO) p_document_id: '||p_document_id);
    END IF;
    check_po_archive(p_document_id, l_revision_num, l_return_status);

    IF (l_return_status = 'Y') THEN
      l_progress := '040';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_header() p_document_id: '||p_document_id);
      END IF;
      archive_header(p_document_id);

      l_progress := '050';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_lines() p_document_id: '||p_document_id||
                        ', l_revision_num: '||l_revision_num);
      END IF;
      archive_lines(p_document_id, l_revision_num);

      --<Enhanced Pricing Start: Archive Price Adjustments>
      l_progress := '52';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'archive_price_adjustments() p_document_id: '||p_document_id||
                       ', l_revision_num: '||l_revision_num);
      END IF;
      archive_price_adjustments
      (
        p_po_header_id => p_document_id
      , p_revision_num => l_revision_num
      );

      l_progress := '56';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'archive_price_adj_attribs() p_document_id: '||p_document_id||
                       ', l_revision_num: '||l_revision_num);
      END IF;
      archive_price_adj_attribs
      (
        p_po_header_id => p_document_id
      , p_revision_num => l_revision_num
      );
      --<Enhanced Pricing End>

      l_progress := '060';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'archive_price_diffs() p_document_id: '||p_document_id||
                       ', p_entity_type: PO LINE'||
                       ', l_revision_num: '||l_revision_num);
      END IF;
      archive_price_diffs(p_document_id, 'PO LINE', l_revision_num);

      l_progress := '070';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_line_locations() p_document_id: '||p_document_id||
                        ', p_document_type: '||p_document_type||
                        ', l_revision_num: '||l_revision_num);
      END IF;
      archive_line_locations(p_document_id, p_document_type, l_revision_num);

      l_progress := '080';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_distributions() p_document_id: '||p_document_id||
                        ', p_document_type: '||p_document_type||
                        ', l_revision_num: '||l_revision_num);
      END IF;
      archive_distributions(p_document_id, p_document_type, l_revision_num);

      l_progress := '090';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_contract_terms() p_document_id: '||p_document_id||
                        ', p_document_type: '||p_document_type||
                        ', p_document_subtype: '||p_document_subtype||
                        ', p_revision_num: '||l_revision_num);
      END IF;
      archive_contract_terms(p_document_id, p_document_type,
                             p_document_subtype, l_revision_num);

    END IF; /*IF (l_return_status = 'Y')*/
  ELSIF (p_document_type = 'PA') THEN
    l_progress := '100';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'check_po_archive(PA) p_document_id: '||p_document_id);
    END IF;
    check_po_archive(p_document_id, l_revision_num, l_return_status);

    IF (l_return_status = 'Y') THEN
      l_progress := '110';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_header() p_document_id: '||p_document_id);
      END IF;
      archive_header(p_document_id);

      IF (p_document_subtype = 'BLANKET') THEN
        l_progress := '120';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
        IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'archive_lines() p_document_id: '||p_document_id||
                         ', l_revision_num: '||l_revision_num);
        END IF;
        archive_lines(p_document_id, l_revision_num);

        --<Enhanced Pricing Start: Archive Price Adjustments>
        l_progress := '122';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
        IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'archive_price_adjustments() p_document_id: '||p_document_id||
                         ', l_revision_num: '||l_revision_num);
        END IF;
        archive_price_adjustments
        (
          p_po_header_id => p_document_id
        , p_revision_num => l_revision_num
        );

        l_progress := '126';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
        IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'archive_price_adj_attribs() p_document_id: '||p_document_id||
                         ', l_revision_num: '||l_revision_num);
        END IF;
        archive_price_adj_attribs
        (
          p_po_header_id => p_document_id
        , p_revision_num => l_revision_num
        );
        --<Enhanced Pricing End>

        --<Unified catalog R12: Start>
        -- Archive the Attribute Values and TLP rows (for BPA/GBPA only)
        archive_attribute_values
        (
          p_po_header_id => p_document_id
        , p_revision_num => l_revision_num
        );

        archive_attr_values_tlp
        (
          p_po_header_id => p_document_id
        , p_revision_num => l_revision_num
        );
        --<Unified catalog R12: End>

        l_progress := '130';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
        IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'archive_price_diffs() p_document_id: '||p_document_id||
                         ', p_entity_type: BLANKET LINE'||
                         ', l_revision_num: '||l_revision_num);
        END IF;
        archive_price_diffs(p_document_id, 'BLANKET LINE', l_revision_num);


        l_progress := '140';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
        IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'archive_line_locations() p_document_id: '||p_document_id||
                         ', p_document_type: '||p_document_type||
                         ', l_revision_num: '||l_revision_num);
        END IF;
        archive_line_locations(p_document_id, p_document_type, l_revision_num);

        l_progress := '150';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
        IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'archive_price_diffs() p_document_id: '||p_document_id||
                         ', p_entity_type: BLANKET LINE'||
                         ', l_revision_num: '||l_revision_num);
        END IF;
        archive_price_diffs(p_document_id, 'PRICE BREAK', l_revision_num);

        -- Bug 3215784 START
        -- Since Encumbrance code will create distribution record for BPA,
        -- archive_distribution routine should be called
        l_progress := '155';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                    'archive_distributions() p_document_id: '||p_document_id||
                    ', p_document_type: '||p_document_type||
                    ', l_revision_num: '||l_revision_num);
  END IF;
  archive_distributions(p_document_id, p_document_type, l_revision_num);
        -- Bug 3215784 END

      END IF; /*IF (p_document_subtype = 'BLANKET')*/ --<BUG 3290647>

      --<BUG 3290647>
      --Archive org assignments for global contracts as well as global blankets.

      l_progress := '160';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'Select global agreement flag - po_header_id: '||p_document_id);
      END IF;
      -- SQL What:Find out if it is a global agreement
      -- SQL Why :Archive org_assignment table if needed
      SELECT NVL(global_agreement_flag, 'N')
      INTO   l_ga_flag
      FROM   po_headers_all
      WHERE  po_header_id = p_document_id;

      IF (l_ga_flag = 'Y') THEN
          l_progress := '170';
          l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
          IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                           'archive_org_assignments() p_document_id: '||p_document_id||
                           ', l_revision_num: '||l_revision_num);
          END IF;
          archive_org_assignments(p_document_id, l_revision_num);

      END IF; /*IF (l_ga_flag = 'Y') THEN*/

      l_progress := '180';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_contract_terms() p_document_id: '||p_document_id||
                        ', p_document_type: '||p_document_type||
                        ', p_document_subtype: '||p_document_subtype||
                        ', p_revision_num: '||l_revision_num);
      END IF;
      archive_contract_terms(p_document_id, p_document_type,
                             p_document_subtype, l_revision_num);

    END IF; /*IF (l_return_status = 'Y')*/
  ELSE
    l_progress := '200';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'check_release_archive() p_document_id: '||p_document_id);
    END IF;
    check_release_archive(p_document_id, l_revision_num, l_return_status);

    IF (l_return_status = 'Y') THEN
      l_progress := '210';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'archive_release() p_document_id: '||p_document_id);
      END IF;
      archive_release(p_document_id);

      l_progress := '220';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_line_locations() p_document_id: '||p_document_id||
                        ', p_document_type: '||p_document_type||
                        ', l_revision_num: '||l_revision_num);
      END IF;
      archive_line_locations(p_document_id, p_document_type, l_revision_num);

      l_progress := '230';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                        'archive_distributions() p_document_id: '||p_document_id||
                        ', p_document_type: '||p_document_type||
                        ', l_revision_num: '||l_revision_num);
      END IF;
      archive_distributions(p_document_id, p_document_type, l_revision_num);
    END IF; /*IF (l_return_status = 'Y')*/
  END IF; /*IF (p_document_type = 'PO')*/

  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get
  (p_count => x_msg_count,
   p_data  => x_msg_data
  );
  l_progress := '300';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL <= FND_LOG.LEVEL_STATEMENT THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                    'Returning from PVT package');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_progress := '310';
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PO_ARCHIVE_SP;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get
    (p_count => x_msg_count,
     p_data  => x_msg_data
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PO_ARCHIVE_SP;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get
    (p_count => x_msg_count,
     p_data  => x_msg_data
    );
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO PO_ARCHIVE_SP;
    IF (G_FND_DEBUG = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, l_module,
                     'EXCEPTION: '||sqlerrm);
      END IF;
    END IF;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get
    (p_count => x_msg_count,
     p_data  => x_msg_data
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END ARCHIVE_PO;

-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_line_archived
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if the given line is archived.
--Parameters:
--IN:
--p_po_line_id
--  Unique ID of line to check for archival.
--Returns:
--  TRUE if the line exists in the Archive table. FALSE, otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_line_archived
(
    p_po_line_id               IN     NUMBER
)
RETURN BOOLEAN
IS
    CURSOR archived_line_csr IS
        SELECT 'Line archive records'
        FROM   po_lines_archive_all
        WHERE  po_line_id = p_po_line_id;

    l_archived_line_csr_type          archived_line_csr%ROWTYPE;
    l_line_is_archived                BOOLEAN;

BEGIN

    OPEN archived_line_csr;
    FETCH archived_line_csr INTO l_archived_line_csr_type;
    l_line_is_archived := archived_line_csr%FOUND;
    CLOSE archived_line_csr;

    return (l_line_is_archived);

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_DOCUMENT_ARCHIVE_PVT.is_line_archived','000',sqlcode);
        RAISE;

END is_line_archived;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_line_location_archived
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if the given line is archived.
--Parameters:
--IN:
--p_po_line_id
--  Unique ID of line to check for archival.
--Returns:
--  TRUE if the line exists in the Archive table. FALSE, otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_line_location_archived
(
    p_line_location_id               IN     NUMBER
)
RETURN BOOLEAN
IS
    CURSOR archived_line_location_csr IS
        SELECT 'Line archive records'
        FROM   po_line_locations_archive_all
        WHERE  line_location_id = p_line_location_id;

    l_archive_csr_type              archived_line_location_csr%ROWTYPE;
    l_line_location_is_archived     BOOLEAN;

BEGIN

    OPEN archived_line_location_csr;
    FETCH archived_line_location_csr INTO l_archive_csr_type;
    l_line_location_is_archived := archived_line_location_csr%FOUND;
    CLOSE archived_line_location_csr;

    return (l_line_location_is_archived);

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_DOCUMENT_ARCHIVE_PVT.is_line_location_archived','000',sqlcode);
        RAISE;

END is_line_location_archived;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_price_differential_archived
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if the given line is archived.
--Parameters:
--IN:
--p_po_line_id
--  Unique ID of line to check for archival.
--Returns:
--  TRUE if the line exists in the Archive table. FALSE, otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_price_differential_archived
(
    p_price_differential_id               IN     NUMBER
)
RETURN BOOLEAN
IS
    CURSOR archived_price_diff_csr IS
        SELECT 'Price Differential archive records'
        FROM   po_price_differentials_archive
        WHERE  price_differential_id = p_price_differential_id;

    l_archive_csr_type               archived_price_diff_csr%ROWTYPE;
    l_price_diff_is_archived BOOLEAN;

BEGIN

    OPEN archived_price_diff_csr;
    FETCH archived_price_diff_csr INTO l_archive_csr_type;
    l_price_diff_is_archived := archived_price_diff_csr%FOUND;
    CLOSE archived_price_diff_csr;

    return (l_price_diff_is_archived);

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_DOCUMENT_ARCHIVE_PVT.is_price_differential_archived','000',sqlcode);
        RAISE;

END is_price_differential_archived;

------------------------------------------------------------------- Bug 3565522
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_archive_mode
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if the given document is archived on approve or communicate
--Parameters:
--IN:
--p_doc_type
--  type of the document to be checked - PO or BLANKET
--p_doc_subtype
--  sub type of the document to be checked - RELEASE or STANDARD
--Return
-- Archive mode - APPROVE or PRINT
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_archive_mode
(   p_doc_type      IN     VARCHAR2 ,
    p_doc_subtype   IN     VARCHAR2
) RETURN VARCHAR2
IS

l_archive_mode  PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;

BEGIN

   -- SQL What: Get archive mode for Standard PO, Release
   -- SQL Why : To Determine when the document is approved

   SELECT nvl(archive_external_revision_code,'PRINT')
   INTO   l_archive_mode
   FROM   po_document_types
   WHERE  document_type_code = p_doc_type
   AND    document_subtype   = p_doc_subtype;

   RETURN l_archive_mode;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.sql_error('PO_DOCUMENT_ARCHIVE_PVT.get_archive_mode','000',sqlcode);
  RAISE;
END;

-------------------------------------------------------------------------------
--Start of Comments
--Name: archive_attribute_values
--Pre-reqs:
--  None.
--Modifies:
--  PO_ATTR_VALUES_ARCHIVE
--Locks:
--  None.
--Function:
--  Archive Item Attribute Values
--Parameters:
--IN:
--p_po_header_id
--  The PO_HEADER_ID of the document that needs to be archived
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE archive_attribute_values
(
  p_po_header_id IN NUMBER
, p_revision_num IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_archive_attribute_values;
  l_progress VARCHAR2(4) := '000';

  --bug 8809927
  cursor c is select po_line_id from po_lines_archive_all
  where po_header_id = p_po_header_id
  and revision_num = p_revision_num;
  l_po_line_id po_lines_all.po_line_id%type;

BEGIN
  l_progress := '000';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
    PO_LOG.proc_begin(d_mod,'p_revision_num',p_revision_num);
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Calling INSERT'); END IF;

  l_progress := '010';

  -- bug 8809927
  OPEN c;
  LOOP
  FETCH c INTO l_po_line_id;
  EXIT WHEN c%notfound;

      INSERT INTO PO_ATTR_VALUES_ARCHIVE
       (
         attribute_values_id,
         revision_num,
         po_line_id,
         req_template_name,
         req_template_line_num,
         ip_category_id,
         inventory_item_id,
         org_id,
         manufacturer_part_num,
         thumbnail_image,
         supplier_url,
         manufacturer_url,
         attachment_url,
         unspsc,
         availability,
         lead_time,
         text_base_attribute1,
         text_base_attribute2,
         text_base_attribute3,
         text_base_attribute4,
         text_base_attribute5,
         text_base_attribute6,
         text_base_attribute7,
         text_base_attribute8,
         text_base_attribute9,
         text_base_attribute10,
         text_base_attribute11,
         text_base_attribute12,
         text_base_attribute13,
         text_base_attribute14,
         text_base_attribute15,
         text_base_attribute16,
         text_base_attribute17,
         text_base_attribute18,
         text_base_attribute19,
         text_base_attribute20,
         text_base_attribute21,
         text_base_attribute22,
         text_base_attribute23,
         text_base_attribute24,
         text_base_attribute25,
         text_base_attribute26,
         text_base_attribute27,
         text_base_attribute28,
         text_base_attribute29,
         text_base_attribute30,
         text_base_attribute31,
         text_base_attribute32,
         text_base_attribute33,
         text_base_attribute34,
         text_base_attribute35,
         text_base_attribute36,
         text_base_attribute37,
         text_base_attribute38,
         text_base_attribute39,
         text_base_attribute40,
         text_base_attribute41,
         text_base_attribute42,
         text_base_attribute43,
         text_base_attribute44,
         text_base_attribute45,
         text_base_attribute46,
         text_base_attribute47,
         text_base_attribute48,
         text_base_attribute49,
         text_base_attribute50,
         text_base_attribute51,
         text_base_attribute52,
         text_base_attribute53,
         text_base_attribute54,
         text_base_attribute55,
         text_base_attribute56,
         text_base_attribute57,
         text_base_attribute58,
         text_base_attribute59,
         text_base_attribute60,
         text_base_attribute61,
         text_base_attribute62,
         text_base_attribute63,
         text_base_attribute64,
         text_base_attribute65,
         text_base_attribute66,
         text_base_attribute67,
         text_base_attribute68,
         text_base_attribute69,
         text_base_attribute70,
         text_base_attribute71,
         text_base_attribute72,
         text_base_attribute73,
         text_base_attribute74,
         text_base_attribute75,
         text_base_attribute76,
         text_base_attribute77,
         text_base_attribute78,
         text_base_attribute79,
         text_base_attribute80,
         text_base_attribute81,
         text_base_attribute82,
         text_base_attribute83,
         text_base_attribute84,
         text_base_attribute85,
         text_base_attribute86,
         text_base_attribute87,
         text_base_attribute88,
         text_base_attribute89,
         text_base_attribute90,
         text_base_attribute91,
         text_base_attribute92,
         text_base_attribute93,
         text_base_attribute94,
         text_base_attribute95,
         text_base_attribute96,
         text_base_attribute97,
         text_base_attribute98,
         text_base_attribute99,
         text_base_attribute100,
         num_base_attribute1,
         num_base_attribute2,
         num_base_attribute3,
         num_base_attribute4,
         num_base_attribute5,
         num_base_attribute6,
         num_base_attribute7,
         num_base_attribute8,
         num_base_attribute9,
         num_base_attribute10,
         num_base_attribute11,
         num_base_attribute12,
         num_base_attribute13,
         num_base_attribute14,
         num_base_attribute15,
         num_base_attribute16,
         num_base_attribute17,
         num_base_attribute18,
         num_base_attribute19,
         num_base_attribute20,
         num_base_attribute21,
         num_base_attribute22,
         num_base_attribute23,
         num_base_attribute24,
         num_base_attribute25,
         num_base_attribute26,
         num_base_attribute27,
         num_base_attribute28,
         num_base_attribute29,
         num_base_attribute30,
         num_base_attribute31,
         num_base_attribute32,
         num_base_attribute33,
         num_base_attribute34,
         num_base_attribute35,
         num_base_attribute36,
         num_base_attribute37,
         num_base_attribute38,
         num_base_attribute39,
         num_base_attribute40,
         num_base_attribute41,
         num_base_attribute42,
         num_base_attribute43,
         num_base_attribute44,
         num_base_attribute45,
         num_base_attribute46,
         num_base_attribute47,
         num_base_attribute48,
         num_base_attribute49,
         num_base_attribute50,
         num_base_attribute51,
         num_base_attribute52,
         num_base_attribute53,
         num_base_attribute54,
         num_base_attribute55,
         num_base_attribute56,
         num_base_attribute57,
         num_base_attribute58,
         num_base_attribute59,
         num_base_attribute60,
         num_base_attribute61,
         num_base_attribute62,
         num_base_attribute63,
         num_base_attribute64,
         num_base_attribute65,
         num_base_attribute66,
         num_base_attribute67,
         num_base_attribute68,
         num_base_attribute69,
         num_base_attribute70,
         num_base_attribute71,
         num_base_attribute72,
         num_base_attribute73,
         num_base_attribute74,
         num_base_attribute75,
         num_base_attribute76,
         num_base_attribute77,
         num_base_attribute78,
         num_base_attribute79,
         num_base_attribute80,
         num_base_attribute81,
         num_base_attribute82,
         num_base_attribute83,
         num_base_attribute84,
         num_base_attribute85,
         num_base_attribute86,
         num_base_attribute87,
         num_base_attribute88,
         num_base_attribute89,
         num_base_attribute90,
         num_base_attribute91,
         num_base_attribute92,
         num_base_attribute93,
         num_base_attribute94,
         num_base_attribute95,
         num_base_attribute96,
         num_base_attribute97,
         num_base_attribute98,
         num_base_attribute99,
         num_base_attribute100,
         text_cat_attribute1,
         text_cat_attribute2,
         text_cat_attribute3,
         text_cat_attribute4,
         text_cat_attribute5,
         text_cat_attribute6,
         text_cat_attribute7,
         text_cat_attribute8,
         text_cat_attribute9,
         text_cat_attribute10,
         text_cat_attribute11,
         text_cat_attribute12,
         text_cat_attribute13,
         text_cat_attribute14,
         text_cat_attribute15,
         text_cat_attribute16,
         text_cat_attribute17,
         text_cat_attribute18,
         text_cat_attribute19,
         text_cat_attribute20,
         text_cat_attribute21,
         text_cat_attribute22,
         text_cat_attribute23,
         text_cat_attribute24,
         text_cat_attribute25,
         text_cat_attribute26,
         text_cat_attribute27,
         text_cat_attribute28,
         text_cat_attribute29,
         text_cat_attribute30,
         text_cat_attribute31,
         text_cat_attribute32,
         text_cat_attribute33,
         text_cat_attribute34,
         text_cat_attribute35,
         text_cat_attribute36,
         text_cat_attribute37,
         text_cat_attribute38,
         text_cat_attribute39,
         text_cat_attribute40,
         text_cat_attribute41,
         text_cat_attribute42,
         text_cat_attribute43,
         text_cat_attribute44,
         text_cat_attribute45,
         text_cat_attribute46,
         text_cat_attribute47,
         text_cat_attribute48,
         text_cat_attribute49,
         text_cat_attribute50,
         num_cat_attribute1,
         num_cat_attribute2,
         num_cat_attribute3,
         num_cat_attribute4,
         num_cat_attribute5,
         num_cat_attribute6,
         num_cat_attribute7,
         num_cat_attribute8,
         num_cat_attribute9,
         num_cat_attribute10,
         num_cat_attribute11,
         num_cat_attribute12,
         num_cat_attribute13,
         num_cat_attribute14,
         num_cat_attribute15,
         num_cat_attribute16,
         num_cat_attribute17,
         num_cat_attribute18,
         num_cat_attribute19,
         num_cat_attribute20,
         num_cat_attribute21,
         num_cat_attribute22,
         num_cat_attribute23,
         num_cat_attribute24,
         num_cat_attribute25,
         num_cat_attribute26,
         num_cat_attribute27,
         num_cat_attribute28,
         num_cat_attribute29,
         num_cat_attribute30,
         num_cat_attribute31,
         num_cat_attribute32,
         num_cat_attribute33,
         num_cat_attribute34,
         num_cat_attribute35,
         num_cat_attribute36,
         num_cat_attribute37,
         num_cat_attribute38,
         num_cat_attribute39,
         num_cat_attribute40,
         num_cat_attribute41,
         num_cat_attribute42,
         num_cat_attribute43,
         num_cat_attribute44,
         num_cat_attribute45,
         num_cat_attribute46,
         num_cat_attribute47,
         num_cat_attribute48,
         num_cat_attribute49,
         num_cat_attribute50,
         last_update_login,
         last_updated_by,
         last_update_date,
         created_by,
         creation_date,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         last_updated_program,
         latest_external_flag
       )
      SELECT
         ATTR.attribute_values_id,
         p_revision_num,
         ATTR.po_line_id,
         ATTR.req_template_name,
         ATTR.req_template_line_num,
         ATTR.ip_category_id,
         ATTR.inventory_item_id,
         ATTR.org_id,
         ATTR.manufacturer_part_num,
         ATTR.thumbnail_image,
         ATTR.supplier_url,
         ATTR.manufacturer_url,
         ATTR.attachment_url,
         ATTR.unspsc,
         ATTR.availability,
         ATTR.lead_time,
         ATTR.text_base_attribute1,
         ATTR.text_base_attribute2,
         ATTR.text_base_attribute3,
         ATTR.text_base_attribute4,
         ATTR.text_base_attribute5,
         ATTR.text_base_attribute6,
         ATTR.text_base_attribute7,
         ATTR.text_base_attribute8,
         ATTR.text_base_attribute9,
         ATTR.text_base_attribute10,
         ATTR.text_base_attribute11,
         ATTR.text_base_attribute12,
         ATTR.text_base_attribute13,
         ATTR.text_base_attribute14,
         ATTR.text_base_attribute15,
         ATTR.text_base_attribute16,
         ATTR.text_base_attribute17,
         ATTR.text_base_attribute18,
         ATTR.text_base_attribute19,
         ATTR.text_base_attribute20,
         ATTR.text_base_attribute21,
         ATTR.text_base_attribute22,
         ATTR.text_base_attribute23,
         ATTR.text_base_attribute24,
         ATTR.text_base_attribute25,
         ATTR.text_base_attribute26,
         ATTR.text_base_attribute27,
         ATTR.text_base_attribute28,
         ATTR.text_base_attribute29,
         ATTR.text_base_attribute30,
         ATTR.text_base_attribute31,
         ATTR.text_base_attribute32,
         ATTR.text_base_attribute33,
         ATTR.text_base_attribute34,
         ATTR.text_base_attribute35,
         ATTR.text_base_attribute36,
         ATTR.text_base_attribute37,
         ATTR.text_base_attribute38,
         ATTR.text_base_attribute39,
         ATTR.text_base_attribute40,
         ATTR.text_base_attribute41,
         ATTR.text_base_attribute42,
         ATTR.text_base_attribute43,
         ATTR.text_base_attribute44,
         ATTR.text_base_attribute45,
         ATTR.text_base_attribute46,
         ATTR.text_base_attribute47,
         ATTR.text_base_attribute48,
         ATTR.text_base_attribute49,
         ATTR.text_base_attribute50,
         ATTR.text_base_attribute51,
         ATTR.text_base_attribute52,
         ATTR.text_base_attribute53,
         ATTR.text_base_attribute54,
         ATTR.text_base_attribute55,
         ATTR.text_base_attribute56,
         ATTR.text_base_attribute57,
         ATTR.text_base_attribute58,
         ATTR.text_base_attribute59,
         ATTR.text_base_attribute60,
         ATTR.text_base_attribute61,
         ATTR.text_base_attribute62,
         ATTR.text_base_attribute63,
         ATTR.text_base_attribute64,
         ATTR.text_base_attribute65,
         ATTR.text_base_attribute66,
         ATTR.text_base_attribute67,
         ATTR.text_base_attribute68,
         ATTR.text_base_attribute69,
         ATTR.text_base_attribute70,
         ATTR.text_base_attribute71,
         ATTR.text_base_attribute72,
         ATTR.text_base_attribute73,
         ATTR.text_base_attribute74,
         ATTR.text_base_attribute75,
         ATTR.text_base_attribute76,
         ATTR.text_base_attribute77,
         ATTR.text_base_attribute78,
         ATTR.text_base_attribute79,
         ATTR.text_base_attribute80,
         ATTR.text_base_attribute81,
         ATTR.text_base_attribute82,
         ATTR.text_base_attribute83,
         ATTR.text_base_attribute84,
         ATTR.text_base_attribute85,
         ATTR.text_base_attribute86,
         ATTR.text_base_attribute87,
         ATTR.text_base_attribute88,
         ATTR.text_base_attribute89,
         ATTR.text_base_attribute90,
         ATTR.text_base_attribute91,
         ATTR.text_base_attribute92,
         ATTR.text_base_attribute93,
         ATTR.text_base_attribute94,
         ATTR.text_base_attribute95,
         ATTR.text_base_attribute96,
         ATTR.text_base_attribute97,
         ATTR.text_base_attribute98,
         ATTR.text_base_attribute99,
         ATTR.text_base_attribute100,
         ATTR.num_base_attribute1,
         ATTR.num_base_attribute2,
         ATTR.num_base_attribute3,
         ATTR.num_base_attribute4,
         ATTR.num_base_attribute5,
         ATTR.num_base_attribute6,
         ATTR.num_base_attribute7,
         ATTR.num_base_attribute8,
         ATTR.num_base_attribute9,
         ATTR.num_base_attribute10,
         ATTR.num_base_attribute11,
         ATTR.num_base_attribute12,
         ATTR.num_base_attribute13,
         ATTR.num_base_attribute14,
         ATTR.num_base_attribute15,
         ATTR.num_base_attribute16,
         ATTR.num_base_attribute17,
         ATTR.num_base_attribute18,
         ATTR.num_base_attribute19,
         ATTR.num_base_attribute20,
         ATTR.num_base_attribute21,
         ATTR.num_base_attribute22,
         ATTR.num_base_attribute23,
         ATTR.num_base_attribute24,
         ATTR.num_base_attribute25,
         ATTR.num_base_attribute26,
         ATTR.num_base_attribute27,
         ATTR.num_base_attribute28,
         ATTR.num_base_attribute29,
         ATTR.num_base_attribute30,
         ATTR.num_base_attribute31,
         ATTR.num_base_attribute32,
         ATTR.num_base_attribute33,
         ATTR.num_base_attribute34,
         ATTR.num_base_attribute35,
         ATTR.num_base_attribute36,
         ATTR.num_base_attribute37,
         ATTR.num_base_attribute38,
         ATTR.num_base_attribute39,
         ATTR.num_base_attribute40,
         ATTR.num_base_attribute41,
         ATTR.num_base_attribute42,
         ATTR.num_base_attribute43,
         ATTR.num_base_attribute44,
         ATTR.num_base_attribute45,
         ATTR.num_base_attribute46,
         ATTR.num_base_attribute47,
         ATTR.num_base_attribute48,
         ATTR.num_base_attribute49,
         ATTR.num_base_attribute50,
         ATTR.num_base_attribute51,
         ATTR.num_base_attribute52,
         ATTR.num_base_attribute53,
         ATTR.num_base_attribute54,
         ATTR.num_base_attribute55,
         ATTR.num_base_attribute56,
         ATTR.num_base_attribute57,
         ATTR.num_base_attribute58,
         ATTR.num_base_attribute59,
         ATTR.num_base_attribute60,
         ATTR.num_base_attribute61,
         ATTR.num_base_attribute62,
         ATTR.num_base_attribute63,
         ATTR.num_base_attribute64,
         ATTR.num_base_attribute65,
         ATTR.num_base_attribute66,
         ATTR.num_base_attribute67,
         ATTR.num_base_attribute68,
         ATTR.num_base_attribute69,
         ATTR.num_base_attribute70,
         ATTR.num_base_attribute71,
         ATTR.num_base_attribute72,
         ATTR.num_base_attribute73,
         ATTR.num_base_attribute74,
         ATTR.num_base_attribute75,
         ATTR.num_base_attribute76,
         ATTR.num_base_attribute77,
         ATTR.num_base_attribute78,
         ATTR.num_base_attribute79,
         ATTR.num_base_attribute80,
         ATTR.num_base_attribute81,
         ATTR.num_base_attribute82,
         ATTR.num_base_attribute83,
         ATTR.num_base_attribute84,
         ATTR.num_base_attribute85,
         ATTR.num_base_attribute86,
         ATTR.num_base_attribute87,
         ATTR.num_base_attribute88,
         ATTR.num_base_attribute89,
         ATTR.num_base_attribute90,
         ATTR.num_base_attribute91,
         ATTR.num_base_attribute92,
         ATTR.num_base_attribute93,
         ATTR.num_base_attribute94,
         ATTR.num_base_attribute95,
         ATTR.num_base_attribute96,
         ATTR.num_base_attribute97,
         ATTR.num_base_attribute98,
         ATTR.num_base_attribute99,
         ATTR.num_base_attribute100,
         ATTR.text_cat_attribute1,
         ATTR.text_cat_attribute2,
         ATTR.text_cat_attribute3,
         ATTR.text_cat_attribute4,
         ATTR.text_cat_attribute5,
         ATTR.text_cat_attribute6,
         ATTR.text_cat_attribute7,
         ATTR.text_cat_attribute8,
         ATTR.text_cat_attribute9,
         ATTR.text_cat_attribute10,
         ATTR.text_cat_attribute11,
         ATTR.text_cat_attribute12,
         ATTR.text_cat_attribute13,
         ATTR.text_cat_attribute14,
         ATTR.text_cat_attribute15,
         ATTR.text_cat_attribute16,
         ATTR.text_cat_attribute17,
         ATTR.text_cat_attribute18,
         ATTR.text_cat_attribute19,
         ATTR.text_cat_attribute20,
         ATTR.text_cat_attribute21,
         ATTR.text_cat_attribute22,
         ATTR.text_cat_attribute23,
         ATTR.text_cat_attribute24,
         ATTR.text_cat_attribute25,
         ATTR.text_cat_attribute26,
         ATTR.text_cat_attribute27,
         ATTR.text_cat_attribute28,
         ATTR.text_cat_attribute29,
         ATTR.text_cat_attribute30,
         ATTR.text_cat_attribute31,
         ATTR.text_cat_attribute32,
         ATTR.text_cat_attribute33,
         ATTR.text_cat_attribute34,
         ATTR.text_cat_attribute35,
         ATTR.text_cat_attribute36,
         ATTR.text_cat_attribute37,
         ATTR.text_cat_attribute38,
         ATTR.text_cat_attribute39,
         ATTR.text_cat_attribute40,
         ATTR.text_cat_attribute41,
         ATTR.text_cat_attribute42,
         ATTR.text_cat_attribute43,
         ATTR.text_cat_attribute44,
         ATTR.text_cat_attribute45,
         ATTR.text_cat_attribute46,
         ATTR.text_cat_attribute47,
         ATTR.text_cat_attribute48,
         ATTR.text_cat_attribute49,
         ATTR.text_cat_attribute50,
         ATTR.num_cat_attribute1,
         ATTR.num_cat_attribute2,
         ATTR.num_cat_attribute3,
         ATTR.num_cat_attribute4,
         ATTR.num_cat_attribute5,
         ATTR.num_cat_attribute6,
         ATTR.num_cat_attribute7,
         ATTR.num_cat_attribute8,
         ATTR.num_cat_attribute9,
         ATTR.num_cat_attribute10,
         ATTR.num_cat_attribute11,
         ATTR.num_cat_attribute12,
         ATTR.num_cat_attribute13,
         ATTR.num_cat_attribute14,
         ATTR.num_cat_attribute15,
         ATTR.num_cat_attribute16,
         ATTR.num_cat_attribute17,
         ATTR.num_cat_attribute18,
         ATTR.num_cat_attribute19,
         ATTR.num_cat_attribute20,
         ATTR.num_cat_attribute21,
         ATTR.num_cat_attribute22,
         ATTR.num_cat_attribute23,
         ATTR.num_cat_attribute24,
         ATTR.num_cat_attribute25,
         ATTR.num_cat_attribute26,
         ATTR.num_cat_attribute27,
         ATTR.num_cat_attribute28,
         ATTR.num_cat_attribute29,
         ATTR.num_cat_attribute30,
         ATTR.num_cat_attribute31,
         ATTR.num_cat_attribute32,
         ATTR.num_cat_attribute33,
         ATTR.num_cat_attribute34,
         ATTR.num_cat_attribute35,
         ATTR.num_cat_attribute36,
         ATTR.num_cat_attribute37,
         ATTR.num_cat_attribute38,
         ATTR.num_cat_attribute39,
         ATTR.num_cat_attribute40,
         ATTR.num_cat_attribute41,
         ATTR.num_cat_attribute42,
         ATTR.num_cat_attribute43,
         ATTR.num_cat_attribute44,
         ATTR.num_cat_attribute45,
         ATTR.num_cat_attribute46,
         ATTR.num_cat_attribute47,
         ATTR.num_cat_attribute48,
         ATTR.num_cat_attribute49,
         ATTR.num_cat_attribute50,
         ATTR.last_update_login,
         ATTR.last_updated_by,
         ATTR.last_update_date,
         ATTR.created_by,
         ATTR.creation_date,
         ATTR.request_id,
         ATTR.program_application_id,
         ATTR.program_id,
         ATTR.program_update_date,
         ATTR.last_updated_program,
         'Y' -- latest_external_flag
      FROM PO_ATTRIBUTE_VALUES ATTR,
           PO_LINES_ALL POL
      WHERE ATTR.po_line_id = POL.po_line_id
        AND POL.po_header_id = p_po_header_id
	and pol.po_line_id = l_po_line_id;   -- bug 8809927
     end loop;
   close c;

  OPEN c;
  LOOP
  FETCH c INTO l_po_line_id;
  EXIT WHEN c%notfound;

    UPDATE PO_ATTR_VALUES_ARCHIVE PAVA1
      SET    PAVA1.latest_external_flag = 'N'
      WHERE  PAVA1.po_line_id = l_po_line_id
      AND    PAVA1.latest_external_flag = 'Y'
      AND    PAVA1.revision_num < p_revision_num
      AND    EXISTS
            (SELECT 'A new archived row'
              FROM   PO_ATTR_VALUES_ARCHIVE PAVA2
              WHERE  PAVA2.po_line_id   = PAVA1.po_line_id
              AND    PAVA2.latest_external_flag = 'Y'
              AND    PAVA2.revision_num         = p_revision_num);
    END LOOP;
    CLOSE c;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows INSERTed into ATTR archive='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END archive_attribute_values;

-------------------------------------------------------------------------------
--Start of Comments
--Name: archive_attr_values_tlp
--Pre-reqs:
--  None.
--Modifies:
--  PO_ATTR_VALUES_TLP_ARCHIVE
--Locks:
--  None.
--Function:
--  Archive Item Attribute Values TLP
--Parameters:
--IN:
--p_po_header_id
--  The PO_HEADER_ID of the document that needs to be archived
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE archive_attr_values_tlp
(
  p_po_header_id IN NUMBER
, p_revision_num IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_archive_attr_values_tlp;
  l_progress VARCHAR2(4) := '000';

  -- bug 8809927
  cursor c is select po_line_id from po_lines_archive_all
  where po_header_id = p_po_header_id
  and revision_num = p_revision_num;
  l_po_line_id po_lines_all.po_line_id%type;

BEGIN
  l_progress := '000';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
    PO_LOG.proc_begin(d_mod,'p_revision_num',p_revision_num);
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Calling INSERT'); END IF;

  l_progress := '010';

  -- bug 8809927
  OPEN c;
  LOOP
  FETCH c INTO l_po_line_id;
  EXIT WHEN c%notfound;


      INSERT INTO PO_ATTR_VALUES_TLP_ARCHIVE
       (
         attribute_values_tlp_id,
         revision_num,
         latest_external_flag,
         po_line_id,
         req_template_name,
         req_template_line_num,
         ip_category_id,
         inventory_item_id,
         org_id,
         language,
         description,
         manufacturer,
         comments,
         alias,
         long_description,
         tl_text_base_attribute1,
         tl_text_base_attribute2,
         tl_text_base_attribute3,
         tl_text_base_attribute4,
         tl_text_base_attribute5,
         tl_text_base_attribute6,
         tl_text_base_attribute7,
         tl_text_base_attribute8,
         tl_text_base_attribute9,
         tl_text_base_attribute10,
         tl_text_base_attribute11,
         tl_text_base_attribute12,
         tl_text_base_attribute13,
         tl_text_base_attribute14,
         tl_text_base_attribute15,
         tl_text_base_attribute16,
         tl_text_base_attribute17,
         tl_text_base_attribute18,
         tl_text_base_attribute19,
         tl_text_base_attribute20,
         tl_text_base_attribute21,
         tl_text_base_attribute22,
         tl_text_base_attribute23,
         tl_text_base_attribute24,
         tl_text_base_attribute25,
         tl_text_base_attribute26,
         tl_text_base_attribute27,
         tl_text_base_attribute28,
         tl_text_base_attribute29,
         tl_text_base_attribute30,
         tl_text_base_attribute31,
         tl_text_base_attribute32,
         tl_text_base_attribute33,
         tl_text_base_attribute34,
         tl_text_base_attribute35,
         tl_text_base_attribute36,
         tl_text_base_attribute37,
         tl_text_base_attribute38,
         tl_text_base_attribute39,
         tl_text_base_attribute40,
         tl_text_base_attribute41,
         tl_text_base_attribute42,
         tl_text_base_attribute43,
         tl_text_base_attribute44,
         tl_text_base_attribute45,
         tl_text_base_attribute46,
         tl_text_base_attribute47,
         tl_text_base_attribute48,
         tl_text_base_attribute49,
         tl_text_base_attribute50,
         tl_text_base_attribute51,
         tl_text_base_attribute52,
         tl_text_base_attribute53,
         tl_text_base_attribute54,
         tl_text_base_attribute55,
         tl_text_base_attribute56,
         tl_text_base_attribute57,
         tl_text_base_attribute58,
         tl_text_base_attribute59,
         tl_text_base_attribute60,
         tl_text_base_attribute61,
         tl_text_base_attribute62,
         tl_text_base_attribute63,
         tl_text_base_attribute64,
         tl_text_base_attribute65,
         tl_text_base_attribute66,
         tl_text_base_attribute67,
         tl_text_base_attribute68,
         tl_text_base_attribute69,
         tl_text_base_attribute70,
         tl_text_base_attribute71,
         tl_text_base_attribute72,
         tl_text_base_attribute73,
         tl_text_base_attribute74,
         tl_text_base_attribute75,
         tl_text_base_attribute76,
         tl_text_base_attribute77,
         tl_text_base_attribute78,
         tl_text_base_attribute79,
         tl_text_base_attribute80,
         tl_text_base_attribute81,
         tl_text_base_attribute82,
         tl_text_base_attribute83,
         tl_text_base_attribute84,
         tl_text_base_attribute85,
         tl_text_base_attribute86,
         tl_text_base_attribute87,
         tl_text_base_attribute88,
         tl_text_base_attribute89,
         tl_text_base_attribute90,
         tl_text_base_attribute91,
         tl_text_base_attribute92,
         tl_text_base_attribute93,
         tl_text_base_attribute94,
         tl_text_base_attribute95,
         tl_text_base_attribute96,
         tl_text_base_attribute97,
         tl_text_base_attribute98,
         tl_text_base_attribute99,
         tl_text_base_attribute100,
         tl_text_cat_attribute1,
         tl_text_cat_attribute2,
         tl_text_cat_attribute3,
         tl_text_cat_attribute4,
         tl_text_cat_attribute5,
         tl_text_cat_attribute6,
         tl_text_cat_attribute7,
         tl_text_cat_attribute8,
         tl_text_cat_attribute9,
         tl_text_cat_attribute10,
         tl_text_cat_attribute11,
         tl_text_cat_attribute12,
         tl_text_cat_attribute13,
         tl_text_cat_attribute14,
         tl_text_cat_attribute15,
         tl_text_cat_attribute16,
         tl_text_cat_attribute17,
         tl_text_cat_attribute18,
         tl_text_cat_attribute19,
         tl_text_cat_attribute20,
         tl_text_cat_attribute21,
         tl_text_cat_attribute22,
         tl_text_cat_attribute23,
         tl_text_cat_attribute24,
         tl_text_cat_attribute25,
         tl_text_cat_attribute26,
         tl_text_cat_attribute27,
         tl_text_cat_attribute28,
         tl_text_cat_attribute29,
         tl_text_cat_attribute30,
         tl_text_cat_attribute31,
         tl_text_cat_attribute32,
         tl_text_cat_attribute33,
         tl_text_cat_attribute34,
         tl_text_cat_attribute35,
         tl_text_cat_attribute36,
         tl_text_cat_attribute37,
         tl_text_cat_attribute38,
         tl_text_cat_attribute39,
         tl_text_cat_attribute40,
         tl_text_cat_attribute41,
         tl_text_cat_attribute42,
         tl_text_cat_attribute43,
         tl_text_cat_attribute44,
         tl_text_cat_attribute45,
         tl_text_cat_attribute46,
         tl_text_cat_attribute47,
         tl_text_cat_attribute48,
         tl_text_cat_attribute49,
         tl_text_cat_attribute50,
         last_update_login,
         last_updated_by,
         last_update_date,
         created_by,
         creation_date,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         last_updated_program
       )
      SELECT
         TLP.attribute_values_tlp_id,
         p_revision_num, -- revision_num
         'Y', -- latest_external_flag,
         TLP.po_line_id,
         TLP.req_template_name,
         TLP.req_template_line_num,
         TLP.ip_category_id,
         TLP.inventory_item_id,
         TLP.org_id,
         TLP.language,
         TLP.description,
         TLP.manufacturer,
         TLP.comments,
         TLP.alias,
         TLP.long_description,
         TLP.tl_text_base_attribute1,
         TLP.tl_text_base_attribute2,
         TLP.tl_text_base_attribute3,
         TLP.tl_text_base_attribute4,
         TLP.tl_text_base_attribute5,
         TLP.tl_text_base_attribute6,
         TLP.tl_text_base_attribute7,
         TLP.tl_text_base_attribute8,
         TLP.tl_text_base_attribute9,
         TLP.tl_text_base_attribute10,
         TLP.tl_text_base_attribute11,
         TLP.tl_text_base_attribute12,
         TLP.tl_text_base_attribute13,
         TLP.tl_text_base_attribute14,
         TLP.tl_text_base_attribute15,
         TLP.tl_text_base_attribute16,
         TLP.tl_text_base_attribute17,
         TLP.tl_text_base_attribute18,
         TLP.tl_text_base_attribute19,
         TLP.tl_text_base_attribute20,
         TLP.tl_text_base_attribute21,
         TLP.tl_text_base_attribute22,
         TLP.tl_text_base_attribute23,
         TLP.tl_text_base_attribute24,
         TLP.tl_text_base_attribute25,
         TLP.tl_text_base_attribute26,
         TLP.tl_text_base_attribute27,
         TLP.tl_text_base_attribute28,
         TLP.tl_text_base_attribute29,
         TLP.tl_text_base_attribute30,
         TLP.tl_text_base_attribute31,
         TLP.tl_text_base_attribute32,
         TLP.tl_text_base_attribute33,
         TLP.tl_text_base_attribute34,
         TLP.tl_text_base_attribute35,
         TLP.tl_text_base_attribute36,
         TLP.tl_text_base_attribute37,
         TLP.tl_text_base_attribute38,
         TLP.tl_text_base_attribute39,
         TLP.tl_text_base_attribute40,
         TLP.tl_text_base_attribute41,
         TLP.tl_text_base_attribute42,
         TLP.tl_text_base_attribute43,
         TLP.tl_text_base_attribute44,
         TLP.tl_text_base_attribute45,
         TLP.tl_text_base_attribute46,
         TLP.tl_text_base_attribute47,
         TLP.tl_text_base_attribute48,
         TLP.tl_text_base_attribute49,
         TLP.tl_text_base_attribute50,
         TLP.tl_text_base_attribute51,
         TLP.tl_text_base_attribute52,
         TLP.tl_text_base_attribute53,
         TLP.tl_text_base_attribute54,
         TLP.tl_text_base_attribute55,
         TLP.tl_text_base_attribute56,
         TLP.tl_text_base_attribute57,
         TLP.tl_text_base_attribute58,
         TLP.tl_text_base_attribute59,
         TLP.tl_text_base_attribute60,
         TLP.tl_text_base_attribute61,
         TLP.tl_text_base_attribute62,
         TLP.tl_text_base_attribute63,
         TLP.tl_text_base_attribute64,
         TLP.tl_text_base_attribute65,
         TLP.tl_text_base_attribute66,
         TLP.tl_text_base_attribute67,
         TLP.tl_text_base_attribute68,
         TLP.tl_text_base_attribute69,
         TLP.tl_text_base_attribute70,
         TLP.tl_text_base_attribute71,
         TLP.tl_text_base_attribute72,
         TLP.tl_text_base_attribute73,
         TLP.tl_text_base_attribute74,
         TLP.tl_text_base_attribute75,
         TLP.tl_text_base_attribute76,
         TLP.tl_text_base_attribute77,
         TLP.tl_text_base_attribute78,
         TLP.tl_text_base_attribute79,
         TLP.tl_text_base_attribute80,
         TLP.tl_text_base_attribute81,
         TLP.tl_text_base_attribute82,
         TLP.tl_text_base_attribute83,
         TLP.tl_text_base_attribute84,
         TLP.tl_text_base_attribute85,
         TLP.tl_text_base_attribute86,
         TLP.tl_text_base_attribute87,
         TLP.tl_text_base_attribute88,
         TLP.tl_text_base_attribute89,
         TLP.tl_text_base_attribute90,
         TLP.tl_text_base_attribute91,
         TLP.tl_text_base_attribute92,
         TLP.tl_text_base_attribute93,
         TLP.tl_text_base_attribute94,
         TLP.tl_text_base_attribute95,
         TLP.tl_text_base_attribute96,
         TLP.tl_text_base_attribute97,
         TLP.tl_text_base_attribute98,
         TLP.tl_text_base_attribute99,
         TLP.tl_text_base_attribute100,
         TLP.tl_text_cat_attribute1,
         TLP.tl_text_cat_attribute2,
         TLP.tl_text_cat_attribute3,
         TLP.tl_text_cat_attribute4,
         TLP.tl_text_cat_attribute5,
         TLP.tl_text_cat_attribute6,
         TLP.tl_text_cat_attribute7,
         TLP.tl_text_cat_attribute8,
         TLP.tl_text_cat_attribute9,
         TLP.tl_text_cat_attribute10,
         TLP.tl_text_cat_attribute11,
         TLP.tl_text_cat_attribute12,
         TLP.tl_text_cat_attribute13,
         TLP.tl_text_cat_attribute14,
         TLP.tl_text_cat_attribute15,
         TLP.tl_text_cat_attribute16,
         TLP.tl_text_cat_attribute17,
         TLP.tl_text_cat_attribute18,
         TLP.tl_text_cat_attribute19,
         TLP.tl_text_cat_attribute20,
         TLP.tl_text_cat_attribute21,
         TLP.tl_text_cat_attribute22,
         TLP.tl_text_cat_attribute23,
         TLP.tl_text_cat_attribute24,
         TLP.tl_text_cat_attribute25,
         TLP.tl_text_cat_attribute26,
         TLP.tl_text_cat_attribute27,
         TLP.tl_text_cat_attribute28,
         TLP.tl_text_cat_attribute29,
         TLP.tl_text_cat_attribute30,
         TLP.tl_text_cat_attribute31,
         TLP.tl_text_cat_attribute32,
         TLP.tl_text_cat_attribute33,
         TLP.tl_text_cat_attribute34,
         TLP.tl_text_cat_attribute35,
         TLP.tl_text_cat_attribute36,
         TLP.tl_text_cat_attribute37,
         TLP.tl_text_cat_attribute38,
         TLP.tl_text_cat_attribute39,
         TLP.tl_text_cat_attribute40,
         TLP.tl_text_cat_attribute41,
         TLP.tl_text_cat_attribute42,
         TLP.tl_text_cat_attribute43,
         TLP.tl_text_cat_attribute44,
         TLP.tl_text_cat_attribute45,
         TLP.tl_text_cat_attribute46,
         TLP.tl_text_cat_attribute47,
         TLP.tl_text_cat_attribute48,
         TLP.tl_text_cat_attribute49,
         TLP.tl_text_cat_attribute50,
         TLP.last_update_login,
         TLP.last_updated_by,
         TLP.last_update_date,
         TLP.created_by,
         TLP.creation_date,
         TLP.request_id,
         TLP.program_application_id,
         TLP.program_id,
         TLP.program_update_date,
         TLP.last_updated_program
      FROM PO_ATTRIBUTE_VALUES_TLP TLP,
           PO_LINES_ALL POL
      WHERE TLP.po_line_id = POL.po_line_id
        AND POL.po_header_id = p_po_header_id
        AND pol.po_line_id = l_po_line_id; -- bug 8809927
     end loop;
   CLOSE c;

  OPEN c;
  LOOP
  FETCH c INTO l_po_line_id;
  EXIT WHEN c%notfound;

    UPDATE PO_ATTR_VALUES_TLP_ARCHIVE PAVTA1
      SET    PAVTA1.latest_external_flag = 'N'
      WHERE  PAVTA1.po_line_id = l_po_line_id
      AND    PAVTA1.latest_external_flag = 'Y'
      AND    PAVTA1.revision_num < p_revision_num
      AND    EXISTS
            (SELECT 'A new archived row'
              FROM   PO_ATTR_VALUES_TLP_ARCHIVE PAVTA2
              WHERE  PAVTA2.po_line_id   = PAVTA1.po_line_id
              AND    PAVTA2.latest_external_flag = 'Y'
              AND    PAVTA2.revision_num         = p_revision_num);
    END LOOP;
    CLOSE c;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows INSERTed into TLP archive='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END archive_attr_values_tlp;

--<Enhanced Pricing Start: Archive Price Adjustments>
-------------------------------------------------------------------------------
--Start of Comments
--Name: archive_price_adjustments
--Pre-reqs:
--  None.
--Modifies:
--  PO_PRICE_ADJUSTMENTS_ARCHIVE
--Locks:
--  None.
--Function:
--  Archive Price Adjustments
--Parameters:
--IN:
--p_po_header_id
--  The PO_HEADER_ID of the document that needs to be archived
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE archive_price_adjustments
( p_po_header_id IN NUMBER
, p_revision_num IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_archive_price_adjustments;
  l_progress VARCHAR2(4) := '000';
BEGIN
  l_progress := '000';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
    PO_LOG.proc_begin(d_mod,'p_revision_num',p_revision_num);
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Calling INSERT'); END IF;

  l_progress := '010';
      INSERT INTO PO_PRICE_ADJUSTMENTS_ARCHIVE
       (
         price_adjustment_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id,
         po_header_id,
         automatic_flag,
         po_line_id,
         context,
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
         orig_sys_discount_ref,
         change_sequence,
         list_header_id,
         list_type_code,
         list_line_id,
         list_line_type_code,
         modified_from,
         modified_to,
         update_allowed,
         change_reason_code,
         change_reason_text,
         updated_flag,
         applied_flag,
         operand,
         arithmetic_operator,
         cost_id,
         tax_code,
         tax_exempt_flag,
         tax_exempt_number,
         tax_exempt_reason_code,
         parent_adjustment_id,
         invoiced_flag,
         estimated_flag,
         inc_in_sales_performance,
         adjusted_amount,
         pricing_phase_id,
         charge_type_code,
         charge_subtype_code,
         range_break_quantity,
         accrual_conversion_rate,
         pricing_group_sequence,
         accrual_flag,
         list_line_no,
         source_system_code,
         benefit_qty,
         benefit_uom_code,
         print_on_invoice_flag,
         expiration_date,
         rebate_transaction_type_code,
         rebate_transaction_reference,
         rebate_payment_system_code,
         redeemed_date,
         redeemed_flag,
         modifier_level_code,
         price_break_type_code,
         substitution_attribute,
         proration_type_code,
         include_on_returns_flag,
         credit_or_charge_flag,
         ac_context,
         ac_attribute1,
         ac_attribute2,
         ac_attribute3,
         ac_attribute4,
         ac_attribute5,
         ac_attribute6,
         ac_attribute7,
         ac_attribute8,
         ac_attribute9,
         ac_attribute10,
         ac_attribute11,
         ac_attribute12,
         ac_attribute13,
         ac_attribute14,
         ac_attribute15,
         operand_per_pqty,
         adjusted_amount_per_pqty,
         interco_invoiced_flag,
         invoiced_amount,
         retrobill_request_id,
         tax_rate_id,
         latest_external_flag,
         revision_num
       )
      SELECT
         ADJ.price_adjustment_id,
         ADJ.creation_date,
         ADJ.created_by,
         ADJ.last_update_date,
         ADJ.last_updated_by,
         ADJ.last_update_login,
         ADJ.program_application_id,
         ADJ.program_id,
         ADJ.program_update_date,
         ADJ.request_id,
         ADJ.po_header_id,
         ADJ.automatic_flag,
         ADJ.po_line_id,
         ADJ.context,
         ADJ.attribute1,
         ADJ.attribute2,
         ADJ.attribute3,
         ADJ.attribute4,
         ADJ.attribute5,
         ADJ.attribute6,
         ADJ.attribute7,
         ADJ.attribute8,
         ADJ.attribute9,
         ADJ.attribute10,
         ADJ.attribute11,
         ADJ.attribute12,
         ADJ.attribute13,
         ADJ.attribute14,
         ADJ.attribute15,
         ADJ.orig_sys_discount_ref,
         ADJ.change_sequence,
         ADJ.list_header_id,
         ADJ.list_type_code,
         ADJ.list_line_id,
         ADJ.list_line_type_code,
         ADJ.modified_from,
         ADJ.modified_to,
         ADJ.update_allowed,
         ADJ.change_reason_code,
         ADJ.change_reason_text,
         ADJ.updated_flag,
         ADJ.applied_flag,
         ADJ.operand,
         ADJ.arithmetic_operator,
         ADJ.cost_id,
         ADJ.tax_code,
         ADJ.tax_exempt_flag,
         ADJ.tax_exempt_number,
         ADJ.tax_exempt_reason_code,
         ADJ.parent_adjustment_id,
         ADJ.invoiced_flag,
         ADJ.estimated_flag,
         ADJ.inc_in_sales_performance,
         ADJ.adjusted_amount,
         ADJ.pricing_phase_id,
         ADJ.charge_type_code,
         ADJ.charge_subtype_code,
         ADJ.range_break_quantity,
         ADJ.accrual_conversion_rate,
         ADJ.pricing_group_sequence,
         ADJ.accrual_flag,
         ADJ.list_line_no,
         ADJ.source_system_code,
         ADJ.benefit_qty,
         ADJ.benefit_uom_code,
         ADJ.print_on_invoice_flag,
         ADJ.expiration_date,
         ADJ.rebate_transaction_type_code,
         ADJ.rebate_transaction_reference,
         ADJ.rebate_payment_system_code,
         ADJ.redeemed_date,
         ADJ.redeemed_flag,
         ADJ.modifier_level_code,
         ADJ.price_break_type_code,
         ADJ.substitution_attribute,
         ADJ.proration_type_code,
         ADJ.include_on_returns_flag,
         ADJ.credit_or_charge_flag,
         ADJ.ac_context,
         ADJ.ac_attribute1,
         ADJ.ac_attribute2,
         ADJ.ac_attribute3,
         ADJ.ac_attribute4,
         ADJ.ac_attribute5,
         ADJ.ac_attribute6,
         ADJ.ac_attribute7,
         ADJ.ac_attribute8,
         ADJ.ac_attribute9,
         ADJ.ac_attribute10,
         ADJ.ac_attribute11,
         ADJ.ac_attribute12,
         ADJ.ac_attribute13,
         ADJ.ac_attribute14,
         ADJ.ac_attribute15,
         ADJ.operand_per_pqty,
         ADJ.adjusted_amount_per_pqty,
         ADJ.interco_invoiced_flag,
         ADJ.invoiced_amount,
         ADJ.retrobill_request_id,
         ADJ.tax_rate_id,
         'Y', -- latest_external_flag
         p_revision_num
      FROM PO_PRICE_ADJUSTMENTS ADJ,
           PO_LINES_ALL POL
      WHERE ADJ.po_line_id = POL.po_line_id
      AND POL.po_header_id = p_po_header_id;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows INSERTed into PRICE ADJUSTMENTS archive='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END archive_price_adjustments;

-------------------------------------------------------------------------------
--Start of Comments
--Name: archive_price_adj_attribs
--Pre-reqs:
--  None.
--Modifies:
--  PO_PRICE_ADJ_ATTRIBS_ARCHIVE
--Locks:
--  None.
--Function:
--  Archive Price Adjustment Attributes
--Parameters:
--IN:
--p_po_header_id
--  The PO_HEADER_ID of the document that needs to be archived
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE archive_price_adj_attribs
(
  p_po_header_id IN NUMBER
, p_revision_num IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_archive_price_adj_attribs;
  l_progress VARCHAR2(4) := '000';
BEGIN
  l_progress := '000';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
    PO_LOG.proc_begin(d_mod,'p_revision_num',p_revision_num);
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Calling INSERT'); END IF;

  l_progress := '010';
      INSERT INTO PO_PRICE_ADJ_ATTRIBS_ARCHIVE
       (
         price_adjustment_id,
         pricing_context,
         pricing_attribute,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id,
         pricing_attr_value_from,
         pricing_attr_value_to,
         comparison_operator,
         flex_title,
         price_adj_attrib_id,
         latest_external_flag,
         revision_num
       )
      SELECT
         ATTR.price_adjustment_id,
         ATTR.pricing_context,
         ATTR.pricing_attribute,
         ATTR.creation_date,
         ATTR.created_by,
         ATTR.last_update_date,
         ATTR.last_updated_by,
         ATTR.last_update_login,
         ATTR.program_application_id,
         ATTR.program_id,
         ATTR.program_update_date,
         ATTR.request_id,
         ATTR.pricing_attr_value_from,
         ATTR.pricing_attr_value_to,
         ATTR.comparison_operator,
         ATTR.flex_title,
         ATTR.price_adj_attrib_id,
         'Y', -- latest_external_flag
         p_revision_num
      FROM PO_PRICE_ADJ_ATTRIBS ATTR,
           PO_PRICE_ADJUSTMENTS ADJ,
           PO_LINES_ALL POL
      WHERE ATTR.price_adjustment_id = ADJ.price_adjustment_id
      AND ADJ.po_line_id = POL.po_line_id
      AND POL.po_header_id = p_po_header_id;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows INSERTed into PRICE ADJUSTMENT ATTRIBUTES archive='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END archive_price_adj_attribs;
--<Enhanced Pricing End>

END PO_DOCUMENT_ARCHIVE_PVT;

/
