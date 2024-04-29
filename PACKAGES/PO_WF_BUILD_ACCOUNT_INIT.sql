--------------------------------------------------------
--  DDL for Package PO_WF_BUILD_ACCOUNT_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WF_BUILD_ACCOUNT_INIT" AUTHID CURRENT_USER AS
/* $Header: POXWPOSS.pls 120.3 2005/09/14 23:23:54 pchintal noship $ */

 /*=======================================================================+
 | FILENAME
 |   POXWPOSS.pls
 |
 | DESCRIPTION
 |   PL/SQL specifications for package:  PO_WF_BUILD_ACCOUNT_INIT
 |
 | NOTES        Imran Ali Created 08/11/97
 | MODIFIED    (MM/DD/YY)
 *=======================================================================*/

--
-- FUNCTION Start_Workflow
--


FUNCTION all_returned_segments_null_sv(x_charge_account_flex VARCHAR2,
                                       x_coa_id NUMBER)
  RETURN BOOLEAN;


FUNCTION Start_Workflow(

  --< Shared Proc FPJ Start >
  x_purchasing_ou_id            IN NUMBER, -- POU's org ID
  x_transaction_flow_header_id  IN NUMBER,
  x_dest_charge_success         IN OUT NOCOPY BOOLEAN,
  x_dest_variance_success       IN OUT NOCOPY BOOLEAN,
  x_dest_charge_account_id      IN OUT NOCOPY NUMBER,
  x_dest_variance_account_id    IN OUT NOCOPY NUMBER,
  x_dest_charge_account_desc    IN OUT NOCOPY VARCHAR2,
  x_dest_variance_account_desc  IN OUT NOCOPY VARCHAR2,
  x_dest_charge_account_flex    IN OUT NOCOPY VARCHAR2,
  x_dest_variance_account_flex  IN OUT NOCOPY VARCHAR2,
  --< Shared Proc FPJ End >

  x_charge_success              IN OUT NOCOPY BOOLEAN,
  x_budget_success              IN OUT NOCOPY BOOLEAN,
  x_accrual_success             IN OUT NOCOPY BOOLEAN,
  x_variance_success            IN OUT NOCOPY BOOLEAN,
  x_code_combination_id         IN OUT NOCOPY NUMBER,
  x_budget_account_id           IN OUT NOCOPY NUMBER,
  x_accrual_account_id          IN OUT NOCOPY NUMBER,
  x_variance_account_id         IN OUT NOCOPY NUMBER,
  x_charge_account_flex         IN OUT NOCOPY VARCHAR2,
  x_budget_account_flex         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_flex        IN OUT NOCOPY VARCHAR2,
  x_variance_account_flex       IN OUT NOCOPY VARCHAR2,
  x_charge_account_desc         IN OUT NOCOPY VARCHAR2,
  x_budget_account_desc         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_desc        IN OUT NOCOPY VARCHAR2,
  x_variance_account_desc       IN OUT NOCOPY VARCHAR2,
  x_coa_id                      NUMBER,
  x_bom_resource_id             NUMBER,
  x_bom_cost_element_id         NUMBER,
  x_category_id                 NUMBER,
  x_destination_type_code       VARCHAR2,
  x_deliver_to_location_id      NUMBER,
  x_destination_organization_id NUMBER,
  x_destination_subinventory    VARCHAR2,
  x_expenditure_type            VARCHAR2,
  x_expenditure_organization_id NUMBER,
  x_expenditure_item_date       DATE,
  x_item_id                     NUMBER,
  x_line_type_id                NUMBER,
  x_result_billable_flag        VARCHAR2,
  x_agent_id                    NUMBER,
  x_project_id                  NUMBER,
  x_from_type_lookup_code       VARCHAR2,
  x_from_header_id              NUMBER,
  x_from_line_id                NUMBER,
  x_task_id                     NUMBER,
  x_deliver_to_person_id        NUMBER,
  x_type_lookup_code            VARCHAR2,
  x_vendor_id                   NUMBER,
  x_wip_entity_id               NUMBER,
  x_wip_entity_type             VARCHAR2,
  x_wip_line_id                 NUMBER,
  x_wip_repetitive_schedule_id  NUMBER,
  x_wip_operation_seq_num       NUMBER,
  x_wip_resource_seq_num        NUMBER,
  x_po_encumberance_flag        VARCHAR2,
  x_gl_encumbered_date          DATE,

  -- because of changes due to WF synch mode this input parameter is not used.
  wf_itemkey                    IN OUT NOCOPY VARCHAR2,
  x_new_combination             IN OUT NOCOPY BOOLEAN,

  header_att1    VARCHAR2, header_att2    VARCHAR2, header_att3    VARCHAR2,
  header_att4    VARCHAR2, header_att5    VARCHAR2, header_att6    VARCHAR2,
  header_att7    VARCHAR2, header_att8    VARCHAR2, header_att9    VARCHAR2,
  header_att10   VARCHAR2, header_att11   VARCHAR2, header_att12   VARCHAR2,
  header_att13   VARCHAR2, header_att14   VARCHAR2, header_att15   VARCHAR2,

  line_att1      VARCHAR2, line_att2      VARCHAR2, line_att3      VARCHAR2,
  line_att4      VARCHAR2, line_att5      VARCHAR2, line_att6      VARCHAR2,
  line_att7      VARCHAR2, line_att8      VARCHAR2, line_att9      VARCHAR2,
  line_att10     VARCHAR2, line_att11     VARCHAR2, line_att12     VARCHAR2,
  line_att13     VARCHAR2, line_att14     VARCHAR2, line_att15     VARCHAR2,

  shipment_att1  VARCHAR2, shipment_att2  VARCHAR2, shipment_att3  VARCHAR2,
  shipment_att4  VARCHAR2, shipment_att5  VARCHAR2, shipment_att6  VARCHAR2,
  shipment_att7  VARCHAR2, shipment_att8  VARCHAR2, shipment_att9  VARCHAR2,
  shipment_att10 VARCHAR2, shipment_att11 VARCHAR2, shipment_att12 VARCHAR2,
  shipment_att13 VARCHAR2, shipment_att14 VARCHAR2, shipment_att15 VARCHAR2,

  distribution_att1  VARCHAR2, distribution_att2  VARCHAR2,
  distribution_att3  VARCHAR2, distribution_att4  VARCHAR2,
  distribution_att5  VARCHAR2, distribution_att6  VARCHAR2,
  distribution_att7  VARCHAR2, distribution_att8  VARCHAR2,
  distribution_att9  VARCHAR2, distribution_att10 VARCHAR2,
  distribution_att11 VARCHAR2, distribution_att12 VARCHAR2,
  distribution_att13 VARCHAR2, distribution_att14 VARCHAR2,
  distribution_att15 VARCHAR2,

  FB_ERROR_MSG     IN OUT NOCOPY VARCHAR2,
  p_distribution_type IN VARCHAR2 DEFAULT NULL, --<Complex Work R12>
  p_payment_type  IN VARCHAR2 DEFAULT NULL,  --<Complex Work R12>
  x_award_id	   NUMBER DEFAULT NULL,    --OGM_0.0 changes added award_id
  x_vendor_site_id NUMBER DEFAULT NULL,    -- B1548597 RVK Common Receiving
  p_func_unit_price  IN NUMBER DEFAULT NULL  --<BUG 3407630>, Bug 3463242
) RETURN BOOLEAN;

-- Bug# 3222499 : Overload the function to maintain the old signature
FUNCTION Start_Workflow(
  x_charge_success              IN OUT NOCOPY BOOLEAN,
  x_budget_success              IN OUT NOCOPY BOOLEAN,
  x_accrual_success             IN OUT NOCOPY BOOLEAN,
  x_variance_success            IN OUT NOCOPY BOOLEAN,
  x_code_combination_id         IN OUT NOCOPY NUMBER,
  x_budget_account_id           IN OUT NOCOPY NUMBER,
  x_accrual_account_id          IN OUT NOCOPY NUMBER,
  x_variance_account_id         IN OUT NOCOPY NUMBER,
  x_charge_account_flex         IN OUT NOCOPY VARCHAR2,
  x_budget_account_flex         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_flex        IN OUT NOCOPY VARCHAR2,
  x_variance_account_flex       IN OUT NOCOPY VARCHAR2,
  x_charge_account_desc         IN OUT NOCOPY VARCHAR2,
  x_budget_account_desc         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_desc        IN OUT NOCOPY VARCHAR2,
  x_variance_account_desc       IN OUT NOCOPY VARCHAR2,
  x_coa_id                      NUMBER,
  x_bom_resource_id             NUMBER,
  x_bom_cost_element_id         NUMBER,
  x_category_id                 NUMBER,
  x_destination_type_code       VARCHAR2,
  x_deliver_to_location_id      NUMBER,
  x_destination_organization_id NUMBER,
  x_destination_subinventory    VARCHAR2,
  x_expenditure_type            VARCHAR2,
  x_expenditure_organization_id NUMBER,
  x_expenditure_item_date       DATE,
  x_item_id                     NUMBER,
  x_line_type_id                NUMBER,
  x_result_billable_flag        VARCHAR2,
  x_agent_id                    NUMBER,
  x_project_id                  NUMBER,
  x_from_type_lookup_code       VARCHAR2,
  x_from_header_id              NUMBER,
  x_from_line_id                NUMBER,
  x_task_id                     NUMBER,
  x_deliver_to_person_id        NUMBER,
  x_type_lookup_code            VARCHAR2,
  x_vendor_id                   NUMBER,
  x_wip_entity_id               NUMBER,
  x_wip_entity_type             VARCHAR2,
  x_wip_line_id                 NUMBER,
  x_wip_repetitive_schedule_id  NUMBER,
  x_wip_operation_seq_num       NUMBER,
  x_wip_resource_seq_num        NUMBER,
  x_po_encumberance_flag        VARCHAR2,
  x_gl_encumbered_date          DATE,

  -- because of changes due to WF synch mode this input parameter is not used.
  wf_itemkey                    IN OUT NOCOPY VARCHAR2,
  x_new_combination             IN OUT NOCOPY BOOLEAN,

  header_att1    VARCHAR2, header_att2    VARCHAR2, header_att3    VARCHAR2,
  header_att4    VARCHAR2, header_att5    VARCHAR2, header_att6    VARCHAR2,
  header_att7    VARCHAR2, header_att8    VARCHAR2, header_att9    VARCHAR2,
  header_att10   VARCHAR2, header_att11   VARCHAR2, header_att12   VARCHAR2,
  header_att13   VARCHAR2, header_att14   VARCHAR2, header_att15   VARCHAR2,

  line_att1      VARCHAR2, line_att2      VARCHAR2, line_att3      VARCHAR2,
  line_att4      VARCHAR2, line_att5      VARCHAR2, line_att6      VARCHAR2,
  line_att7      VARCHAR2, line_att8      VARCHAR2, line_att9      VARCHAR2,
  line_att10     VARCHAR2, line_att11     VARCHAR2, line_att12     VARCHAR2,
  line_att13     VARCHAR2, line_att14     VARCHAR2, line_att15     VARCHAR2,

  shipment_att1  VARCHAR2, shipment_att2  VARCHAR2, shipment_att3  VARCHAR2,
  shipment_att4  VARCHAR2, shipment_att5  VARCHAR2, shipment_att6  VARCHAR2,
  shipment_att7  VARCHAR2, shipment_att8  VARCHAR2, shipment_att9  VARCHAR2,
  shipment_att10 VARCHAR2, shipment_att11 VARCHAR2, shipment_att12 VARCHAR2,
  shipment_att13 VARCHAR2, shipment_att14 VARCHAR2, shipment_att15 VARCHAR2,

  distribution_att1  VARCHAR2, distribution_att2  VARCHAR2,
  distribution_att3  VARCHAR2, distribution_att4  VARCHAR2,
  distribution_att5  VARCHAR2, distribution_att6  VARCHAR2,
  distribution_att7  VARCHAR2, distribution_att8  VARCHAR2,
  distribution_att9  VARCHAR2, distribution_att10 VARCHAR2,
  distribution_att11 VARCHAR2, distribution_att12 VARCHAR2,
  distribution_att13 VARCHAR2, distribution_att14 VARCHAR2,
  distribution_att15 VARCHAR2,

  FB_ERROR_MSG     IN OUT NOCOPY VARCHAR2,
  p_distribution_type IN VARCHAR2 DEFAULT NULL, --<Complex Work R12>
  p_payment_type  IN VARCHAR2 DEFAULT NULL,  --<Complex Work R12>
  x_award_id	   NUMBER DEFAULT NULL,   --OGM_0.0 changes added award_id
  x_vendor_site_id NUMBER DEFAULT NULL,   -- B1548597 RVK Common Receiving
  p_func_unit_price IN NUMBER DEFAULT NULL  --<BUG 3407630>, Bug 3463242
) RETURN BOOLEAN;

PROCEDURE debug_on;

PROCEDURE debug_off;

--< Shared Proc FPJ Start >

  -- The following 2 global constants are used to define the flow type
  -- for the PO AG workflow.
  g_po_accounts CONSTANT VARCHAR2(25) := 'PO_ACCOUNTS';
  g_destination_accounts CONSTANT VARCHAR2(25) := 'DESTINATION_ACCOUNTS';

--< Shared Proc FPJ End >

END  PO_WF_BUILD_ACCOUNT_INIT;

 

/
