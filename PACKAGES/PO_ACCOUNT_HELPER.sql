--------------------------------------------------------
--  DDL for Package PO_ACCOUNT_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ACCOUNT_HELPER" AUTHID CURRENT_USER AS
-- $Header: PO_ACCOUNT_HELPER.pls 120.1.12010000.6 2014/07/21 11:43:09 shipwu ship $

-- initial revision uses FPJ/complex work signature
FUNCTION build_accounts(
  x_purchasing_ou_id            IN NUMBER -- POU's org ID
, x_transaction_flow_header_id  IN NUMBER
, x_dest_charge_success         IN OUT NOCOPY BOOLEAN
, x_dest_variance_success       IN OUT NOCOPY BOOLEAN
, x_dest_charge_account_id      IN OUT NOCOPY NUMBER
, x_dest_variance_account_id    IN OUT NOCOPY NUMBER
, x_dest_charge_account_desc    IN OUT NOCOPY VARCHAR2
, x_dest_variance_account_desc  IN OUT NOCOPY VARCHAR2
, x_dest_charge_account_flex    IN OUT NOCOPY VARCHAR2
, x_dest_variance_account_flex  IN OUT NOCOPY VARCHAR2

, x_charge_success              IN OUT NOCOPY BOOLEAN
, x_budget_success              IN OUT NOCOPY BOOLEAN
, x_accrual_success             IN OUT NOCOPY BOOLEAN
, x_variance_success            IN OUT NOCOPY BOOLEAN
, x_code_combination_id         IN OUT NOCOPY NUMBER
, x_budget_account_id           IN OUT NOCOPY NUMBER
, x_accrual_account_id          IN OUT NOCOPY NUMBER
, x_variance_account_id         IN OUT NOCOPY NUMBER
, x_charge_account_flex         IN OUT NOCOPY VARCHAR2
, x_budget_account_flex         IN OUT NOCOPY VARCHAR2
, x_accrual_account_flex        IN OUT NOCOPY VARCHAR2
, x_variance_account_flex       IN OUT NOCOPY VARCHAR2
, x_charge_account_desc         IN OUT NOCOPY VARCHAR2
, x_budget_account_desc         IN OUT NOCOPY VARCHAR2
, x_accrual_account_desc        IN OUT NOCOPY VARCHAR2
, x_variance_account_desc       IN OUT NOCOPY VARCHAR2
, x_coa_id                      NUMBER
, x_bom_resource_id             NUMBER
, x_bom_cost_element_id         NUMBER
, x_category_id                 NUMBER
, x_destination_type_code       VARCHAR2
, x_deliver_to_location_id      NUMBER
, x_destination_organization_id NUMBER
, x_destination_subinventory    VARCHAR2
, x_expenditure_type            VARCHAR2
, x_expenditure_organization_id NUMBER
, x_expenditure_item_date       DATE
, x_item_id                     NUMBER
, x_line_type_id                NUMBER
, x_result_billable_flag        VARCHAR2
, x_agent_id                    NUMBER
, x_project_id                  NUMBER
, x_from_type_lookup_code       VARCHAR2
, x_from_header_id              NUMBER
, x_from_line_id                NUMBER
, x_task_id                     NUMBER
, x_deliver_to_person_id        NUMBER
, x_type_lookup_code            VARCHAR2
, x_vendor_id                   NUMBER
, x_wip_entity_id               NUMBER
, x_wip_entity_type             VARCHAR2
, x_wip_line_id                 NUMBER
, x_wip_repetitive_schedule_id  NUMBER
, x_wip_operation_seq_num       NUMBER
, x_wip_resource_seq_num        NUMBER
, x_po_encumberance_flag        VARCHAR2
, x_gl_encumbered_date          DATE

, wf_itemkey                    IN OUT NOCOPY VARCHAR2
, x_new_combination             IN OUT NOCOPY BOOLEAN

, header_att1    VARCHAR2
, header_att2    VARCHAR2
, header_att3    VARCHAR2
, header_att4    VARCHAR2
, header_att5    VARCHAR2
, header_att6    VARCHAR2
, header_att7    VARCHAR2
, header_att8    VARCHAR2
, header_att9    VARCHAR2
, header_att10   VARCHAR2
, header_att11   VARCHAR2
, header_att12   VARCHAR2
, header_att13   VARCHAR2
, header_att14   VARCHAR2
, header_att15   VARCHAR2

, line_att1      VARCHAR2
, line_att2      VARCHAR2
, line_att3      VARCHAR2
, line_att4      VARCHAR2
, line_att5      VARCHAR2
, line_att6      VARCHAR2
, line_att7      VARCHAR2
, line_att8      VARCHAR2
, line_att9      VARCHAR2
, line_att10     VARCHAR2
, line_att11     VARCHAR2
, line_att12     VARCHAR2
, line_att13     VARCHAR2
, line_att14     VARCHAR2
, line_att15     VARCHAR2

, shipment_att1  VARCHAR2
, shipment_att2  VARCHAR2
, shipment_att3  VARCHAR2
, shipment_att4  VARCHAR2
, shipment_att5  VARCHAR2
, shipment_att6  VARCHAR2
, shipment_att7  VARCHAR2
, shipment_att8  VARCHAR2
, shipment_att9  VARCHAR2
, shipment_att10 VARCHAR2
, shipment_att11 VARCHAR2
, shipment_att12 VARCHAR2
, shipment_att13 VARCHAR2
, shipment_att14 VARCHAR2
, shipment_att15 VARCHAR2

, distribution_att1  VARCHAR2
, distribution_att2  VARCHAR2
, distribution_att3  VARCHAR2
, distribution_att4  VARCHAR2
, distribution_att5  VARCHAR2
, distribution_att6  VARCHAR2
, distribution_att7  VARCHAR2
, distribution_att8  VARCHAR2
, distribution_att9  VARCHAR2
, distribution_att10 VARCHAR2
, distribution_att11 VARCHAR2
, distribution_att12 VARCHAR2
, distribution_att13 VARCHAR2
, distribution_att14 VARCHAR2
, distribution_att15 VARCHAR2

, FB_ERROR_MSG          IN OUT NOCOPY VARCHAR2
, p_distribution_type   IN VARCHAR2 DEFAULT NULL
, p_payment_type        IN VARCHAR2 DEFAULT NULL
, x_award_id	        NUMBER DEFAULT NULL
, x_vendor_site_id      NUMBER DEFAULT NULL
, p_func_unit_price     IN NUMBER DEFAULT NULL
, p_distribution_id     IN NUMBER --<HTML Orders/Agreements R12>
, p_award_number        IN VARCHAR2 --<HTML Orders/Agreements R12>
) RETURN BOOLEAN;

--<Bug 15917496>: added procedure online_rebuild_accounts
PROCEDURE online_rebuild_accounts
  (
    p_document_id      IN NUMBER
  , p_document_type    IN VARCHAR2
  , p_document_subtype IN VARCHAR2
  , p_draft_id IN NUMBER DEFAULT NULL
  , p_commit           IN VARCHAR2   default 'N'   --Bug 18273891
  , p_po_line_id_tbl   IN PO_TBL_NUMBER default NULL --Bug 19161517
  , x_online_report_id OUT NOCOPY NUMBER
  , x_return_status     OUT NOCOPY VARCHAR2 --E: error, S: success
);

--<Bug 16747691>: added function req_rebuild_accounts

FUNCTION req_build_accounts(
  x_charge_success              IN OUT NOCOPY BOOLEAN
, x_budget_success              IN OUT NOCOPY BOOLEAN
, x_accrual_success             IN OUT NOCOPY BOOLEAN
, x_variance_success            IN OUT NOCOPY BOOLEAN
, x_code_combination_id         IN OUT NOCOPY NUMBER
, x_budget_account_id           IN OUT NOCOPY NUMBER
, x_accrual_account_id          IN OUT NOCOPY NUMBER
, x_variance_account_id         IN OUT NOCOPY NUMBER
, x_charge_account_flex         IN OUT NOCOPY VARCHAR2
, x_budget_account_flex         IN OUT NOCOPY VARCHAR2
, x_accrual_account_flex        IN OUT NOCOPY VARCHAR2
, x_variance_account_flex       IN OUT NOCOPY VARCHAR2
, x_charge_account_desc         IN OUT NOCOPY VARCHAR2
, x_budget_account_desc         IN OUT NOCOPY VARCHAR2
, x_accrual_account_desc        IN OUT NOCOPY VARCHAR2
, x_variance_account_desc       IN OUT NOCOPY VARCHAR2
, x_distribution_id             NUMBER
, x_coa_id                      NUMBER
, x_bom_resource_id             NUMBER
, x_bom_cost_element_id         NUMBER
, x_category_id                 NUMBER
, x_destination_type_code       VARCHAR2
, x_deliver_to_location_id      NUMBER
, x_destination_organization_id NUMBER
, x_destination_subinventory    VARCHAR2
, x_expenditure_type            VARCHAR2
, x_expenditure_organization_id NUMBER
, x_expenditure_item_date       DATE
, x_item_id                     NUMBER
, x_line_type_id                NUMBER
, x_result_billable_flag        VARCHAR2
, x_preparer_id                    NUMBER
, x_project_id                  NUMBER
, x_document_type_code          VARCHAR2
, x_blanket_po_header_id        NUMBER
, x_source_type_code		  VARCHAR2
, x_source_organization_id	  NUMBER
, x_source_subinventory	  VARCHAR2
, x_task_id                     NUMBER
, x_deliver_to_person_id        NUMBER
, x_type_lookup_code            VARCHAR2
, x_suggested_vendor_id                   NUMBER
, x_wip_entity_id               NUMBER
, x_wip_entity_type             VARCHAR2
, x_wip_line_id                 NUMBER
, x_wip_repetitive_schedule_id  NUMBER
, x_wip_operation_seq_num       NUMBER
, x_wip_resource_seq_num        NUMBER
, x_po_encumberance_flag        VARCHAR2
, x_gl_encumbered_date          DATE

, wf_itemkey                    IN OUT NOCOPY VARCHAR2
, x_new_combination             IN OUT NOCOPY BOOLEAN

, header_att1    VARCHAR2
, header_att2    VARCHAR2
, header_att3    VARCHAR2
, header_att4    VARCHAR2
, header_att5    VARCHAR2
, header_att6    VARCHAR2
, header_att7    VARCHAR2
, header_att8    VARCHAR2
, header_att9    VARCHAR2
, header_att10   VARCHAR2
, header_att11   VARCHAR2
, header_att12   VARCHAR2
, header_att13   VARCHAR2
, header_att14   VARCHAR2
, header_att15   VARCHAR2

, line_att1      VARCHAR2
, line_att2      VARCHAR2
, line_att3      VARCHAR2
, line_att4      VARCHAR2
, line_att5      VARCHAR2
, line_att6      VARCHAR2
, line_att7      VARCHAR2
, line_att8      VARCHAR2
, line_att9      VARCHAR2
, line_att10     VARCHAR2
, line_att11     VARCHAR2
, line_att12     VARCHAR2
, line_att13     VARCHAR2
, line_att14     VARCHAR2
, line_att15     VARCHAR2

, distribution_att1  VARCHAR2
, distribution_att2  VARCHAR2
, distribution_att3  VARCHAR2
, distribution_att4  VARCHAR2
, distribution_att5  VARCHAR2
, distribution_att6  VARCHAR2
, distribution_att7  VARCHAR2
, distribution_att8  VARCHAR2
, distribution_att9  VARCHAR2
, distribution_att10 VARCHAR2
, distribution_att11 VARCHAR2
, distribution_att12 VARCHAR2
, distribution_att13 VARCHAR2
, distribution_att14 VARCHAR2
, distribution_att15 VARCHAR2

, FB_ERROR_MSG          IN OUT NOCOPY VARCHAR2
, x_award_id	        NUMBER DEFAULT NULL
, x_suggested_vendor_site_id      NUMBER DEFAULT NULL
, p_unit_price     IN NUMBER DEFAULT NULL
, p_blanket_po_line_num      IN NUMBER DEFAULT NULL
, p_award_number        IN VARCHAR2
) RETURN BOOLEAN;


--<Bug 16747691>: added procedure req_online_rebuild_accounts

PROCEDURE req_online_rebuild_accounts
  (
    p_document_id      IN NUMBER
  , p_document_type    IN VARCHAR2
  , p_document_subtype IN VARCHAR2
  , p_document_line_id IN NUMBER
  , x_online_report_id OUT NOCOPY NUMBER
  , x_return_status OUT NOCOPY VARCHAR2);



END PO_ACCOUNT_HELPER;

/
