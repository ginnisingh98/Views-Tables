--------------------------------------------------------
--  DDL for Package PO_REQ_WF_BUILD_ACCOUNT_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_WF_BUILD_ACCOUNT_INIT" AUTHID CURRENT_USER AS
/* $Header: POXWRQSS.pls 120.0.12010000.1 2008/07/24 14:29:06 appldev ship $ */

 /*=======================================================================+
 | FILENAME
 |   POXWRQSS.pls
 |
 | DESCRIPTION
 |   PL/SQL specifications for package:  PO_REQ_WF_BUILD_ACCOUNT_INIT
 |
 | NOTES        Imran Ali Created 09/9/97
 | MODIFIED    (MM/DD/YY)         03/31/98
 *=======================================================================*/

--
-- FUNCTION Start_Workflow
--

FUNCTION Start_Workflow (
   x_charge_success       IN OUT NOCOPY  BOOLEAN,  x_budget_success        IN OUT NOCOPY   BOOLEAN,
   x_accrual_success      IN OUT NOCOPY  BOOLEAN,  x_variance_success      IN OUT NOCOPY   BOOLEAN,
   x_code_combination_id  IN OUT NOCOPY  NUMBER,   x_budget_account_id     IN OUT NOCOPY   NUMBER,
   x_accrual_account_id   IN OUT NOCOPY  NUMBER,   x_variance_account_id   IN OUT NOCOPY   NUMBER,
   x_charge_account_flex  IN OUT NOCOPY  VARCHAR2, x_budget_account_flex   IN OUT NOCOPY   VARCHAR2,
   x_accrual_account_flex IN OUT NOCOPY  VARCHAR2, x_variance_account_flex IN OUT NOCOPY   VARCHAR2,
   x_charge_account_desc  IN OUT NOCOPY  VARCHAR2, x_budget_account_desc   IN OUT NOCOPY   VARCHAR2,
   x_accrual_account_desc IN OUT NOCOPY  VARCHAR2, x_variance_account_desc IN OUT NOCOPY   VARCHAR2,
   x_coa_id                       NUMBER,   x_bom_resource_id                NUMBER,
   x_bom_cost_element_id          NUMBER,   x_category_id                    NUMBER,
   x_destination_type_code        VARCHAR2, x_deliver_to_location_id         NUMBER,
   x_destination_organization_id  NUMBER,   x_destination_subinventory       VARCHAR2,
   x_expenditure_type             VARCHAR2,
   x_expenditure_organization_id  NUMBER,   x_expenditure_item_date          DATE,
   x_item_id                      NUMBER,   x_line_type_id                   NUMBER,
   x_result_billable_flag         VARCHAR2, x_preparer_id                    NUMBER,
   x_project_id                   NUMBER,
   x_document_type_code		  VARCHAR2,
   x_blanket_po_header_id	  NUMBER,
   x_source_type_code		  VARCHAR2,
   x_source_organization_id	  NUMBER,
   x_source_subinventory	  VARCHAR2,
   x_task_id                      NUMBER,   x_deliver_to_person_id           NUMBER,
   x_type_lookup_code             VARCHAR2, x_suggested_vendor_id            NUMBER,
   x_wip_entity_id                NUMBER,   x_wip_entity_type                VARCHAR2,
   x_wip_line_id                  NUMBER,   x_wip_repetitive_schedule_id     NUMBER,
   x_wip_operation_seq_num        NUMBER,   x_wip_resource_seq_num           NUMBER,
   x_po_encumberance_flag         VARCHAR2, x_gl_encumbered_date             DATE,
   wf_itemkey		  IN OUT NOCOPY  VARCHAR2, x_new_combination	    IN OUT NOCOPY   BOOLEAN,

   header_att1  VARCHAR2, header_att2   VARCHAR2, header_att3  VARCHAR2, header_att4  VARCHAR2,
   header_att5  VARCHAR2, header_att6   VARCHAR2, header_att7  VARCHAR2, header_att8  VARCHAR2,
   header_att9   VARCHAR2, header_att10  VARCHAR2, header_att11  VARCHAR2,
   header_att12  VARCHAR2, header_att13  VARCHAR2, header_att14  VARCHAR2,header_att15  VARCHAR2,

   line_att1   VARCHAR2, line_att2   VARCHAR2, line_att3   VARCHAR2, line_att4   VARCHAR2,
   line_att5   VARCHAR2, line_att6   VARCHAR2, line_att7   VARCHAR2, line_att8   VARCHAR2,
   line_att9   VARCHAR2, line_att10  VARCHAR2, line_att11  VARCHAR2, line_att12  VARCHAR2,
   line_att13  VARCHAR2, line_att14  VARCHAR2, line_att15  VARCHAR2,

   distribution_att1   VARCHAR2, distribution_att2   VARCHAR2, distribution_att3   VARCHAR2,
   distribution_att4   VARCHAR2, distribution_att5   VARCHAR2, distribution_att6   VARCHAR2,
   distribution_att7   VARCHAR2, distribution_att8   VARCHAR2, distribution_att9   VARCHAR2,
   distribution_att10  VARCHAR2, distribution_att11  VARCHAR2, distribution_att12  VARCHAR2,
   distribution_att13  VARCHAR2, distribution_att14  VARCHAR2, distribution_att15  VARCHAR2,

   FB_ERROR_MSG IN  OUT NOCOPY VARCHAR2,
   x_award_id 	NUMBER default NULL, -- OGM_0.0 changes.
   x_suggested_vendor_site_id NUMBER default NULL,  -- B1548597 Common Receiving RVK
   p_unit_price IN NUMBER DEFAULT NULL,  --<BUG 3407630>
   p_blanket_po_line_num IN NUMBER DEFAULT NULL  --<BUG 3611341>
) RETURN Boolean;

PROCEDURE debug_on;

PROCEDURE debug_off;

end  PO_REQ_WF_BUILD_ACCOUNT_INIT;

/
