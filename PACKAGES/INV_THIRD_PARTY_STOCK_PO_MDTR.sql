--------------------------------------------------------
--  DDL for Package INV_THIRD_PARTY_STOCK_PO_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_THIRD_PARTY_STOCK_PO_MDTR" AUTHID CURRENT_USER AS
-- $Header: INVCPODS.pls 115.4 2002/12/07 00:34:53 dherring noship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCPODS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consiged Inventory INV/PO dependency wrapper API                  |
--| HISTORY                                                               |
--|     09/30/2002 pseshadr       Created                                 |
--+========================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE   : Get_Blanket_Number          PUBLIC
-- PARAMETERS: p_inventory_item_id           Item
--             p_vendor_site_id              Vendor Site
--             p_organization_id             Inventory Organization
--             x_document_header_id          PO Header id
--             x_document_line_id            PO line id
-- COMMENT   : Return document_id if a valid blanket exists for item,
--             supplier site,organization combination.
--             This procedure is invoked to get the most recent blanket when
--             performing a Transfer to regular stock transaction.
--========================================================================
PROCEDURE Get_Blanket_Number
( p_inventory_item_id   IN   NUMBER
, p_vendor_site_id      IN   NUMBER
, p_organization_id     IN   NUMBER
, x_document_header_id  OUT NOCOPY  NUMBER
, x_document_line_id    OUT NOCOPY  NUMBER
);


--========================================================================
-- PROCEDURE  : Get_Asl_Info                 PUBLIC
-- PARAMETERS: p_item_id                     Item
--             p_vendor_id                   Vendor Id
--             p_vendor_site_id              Vendor Site Id
--             p_using_organization_id       organization
--             x_asl_id                      asl id
--             x_vendor_product_num          vendor product num
--             x_purchasing_uom              Purchasing UOM
-- COMMENT:    Wrapper for get asl info procedure in purchasing
--========================================================================
PROCEDURE Get_Asl_Info
( p_item_id               IN NUMBER
, p_vendor_id             IN NUMBER
, p_vendor_site_id        IN NUMBER
, p_using_organization_id IN NUMBER
, x_asl_id                OUT NOCOPY NUMBER
, x_vendor_product_num    OUT NOCOPY VARCHAR2
, x_purchasing_uom        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE  :  Start_Workflow                PUBLIC
-- PARAMETERS :  p_coa_id                      Chart of Accounts Id
--               p_destination_type_code       INVENTORY
--               p_type_lookup_code            Document type
--               p_item_id                     Item
--               p_vendor_id                   Vendor
--               p_vendor_site_id              Vendor Site
--               p_destination_organization_id Inventory Organization
--               p_po_encumberance_flag        PO encumberance
--               p_accrual_account_id          Accrual account
--               p_charge_account_id           Charge Account
--               p_variance_account_id         Variance Account
-- COMMENT   :   The above inputs are the only relevent parameters for
--               generation of accounts for consigned transaction. All
--               the other parameters that are required for the
--               procedure are passed in as NULL . This is a wrapper
--               to the PO Account generator.
--========================================================================

PROCEDURE  Start_Workflow
(  p_charge_success                IN OUT NOCOPY BOOLEAN
 , p_budget_success                IN OUT NOCOPY BOOLEAN
 , p_accrual_success               IN OUT NOCOPY BOOLEAN
 , p_variance_success              IN OUT NOCOPY BOOLEAN
 , p_code_combination_id           IN OUT NOCOPY NUMBER
 , p_charge_account_id             IN OUT NOCOPY NUMBER
 , p_budget_account_id             IN OUT NOCOPY NUMBER
 , p_accrual_account_id            IN OUT NOCOPY NUMBER
 , p_variance_account_id           IN OUT NOCOPY NUMBER
 , p_charge_account_flex           IN OUT NOCOPY VARCHAR2
 , p_budget_account_flex           IN OUT NOCOPY VARCHAR2
 , p_accrual_account_flex          IN OUT NOCOPY VARCHAR2
 , p_variance_account_flex         IN OUT NOCOPY VARCHAR2
 , p_charge_account_desc           IN OUT NOCOPY VARCHAR2
 , p_budget_account_desc           IN OUT NOCOPY VARCHAR2
 , p_accrual_account_desc          IN OUT NOCOPY VARCHAR2
 , p_variance_account_desc         IN OUT NOCOPY VARCHAR2
 , p_coa_id                        IN NUMBER
 , p_bom_resource_id               IN NUMBER
 , p_bom_cost_element_id           IN NUMBER
 , p_category_id                   IN NUMBER
 , p_destination_type_code         IN VARCHAR2
 , p_deliver_to_location_id        IN NUMBER
 , p_destination_organization_id   IN NUMBER
 , p_destination_subinventory      IN VARCHAR2
 , p_expenditure_type              IN VARCHAR2
 , p_expenditure_organization_id   IN NUMBER
 , p_expenditure_item_date         IN DATE
 , p_item_id                       IN NUMBER
 , p_line_type_id                  IN NUMBER
 , p_result_billable_flag          IN VARCHAR2
 , p_agent_id                      IN NUMBER
 , p_project_id                    IN NUMBER
 , p_from_type_lookup_code         IN VARCHAR2
 , p_from_header_id                IN NUMBER
 , p_from_line_id                  IN NUMBER
 , p_task_id                       IN NUMBER
 , p_deliver_to_person_id          IN NUMBER
 , p_type_lookup_code              IN VARCHAR2
 , p_vendor_id                     IN NUMBER
 , p_wip_entity_id                 IN NUMBER
 , p_wip_entity_type               IN VARCHAR2
 , p_wip_line_id                   IN NUMBER
 , p_wip_repetitive_schedule_id    IN NUMBER
 , p_wip_operation_seq_num         IN NUMBER
 , p_wip_resource_seq_num          IN NUMBER
 , p_po_encumberance_flag          IN VARCHAR2
 , p_gl_encumbered_date            IN DATE
 , p_wf_itemkey                    IN OUT NOCOPY VARCHAR2
 , p_new_combination               IN OUT NOCOPY BOOLEAN
 , p_header_att1                   IN VARCHAR2
 , p_header_att2                   IN VARCHAR2
 , p_header_att3                   IN VARCHAR2
 , p_header_att4                   IN VARCHAR2
 , p_header_att5                   IN VARCHAR2
 , p_header_att6                   IN VARCHAR2
 , p_header_att7                   IN VARCHAR2
 , p_header_att8                   IN VARCHAR2
 , p_header_att9                   IN VARCHAR2
 , p_header_att10                  IN VARCHAR2
 , p_header_att11                  IN VARCHAR2
 , p_header_att12                  IN VARCHAR2
 , p_header_att13                  IN VARCHAR2
 , p_header_att14                  IN VARCHAR2
 , p_header_att15                  IN VARCHAR2
 , p_line_att1                     IN VARCHAR2
 , p_line_att2                     IN VARCHAR2
 , p_line_att3                     IN VARCHAR2
 , p_line_att4                     IN VARCHAR2
 , p_line_att5                     IN VARCHAR2
 , p_line_att6                     IN VARCHAR2
 , p_line_att7                     IN VARCHAR2
 , p_line_att8                     IN VARCHAR2
 , p_line_att9                     IN VARCHAR2
 , p_line_att10                    IN VARCHAR2
 , p_line_att11                    IN VARCHAR2
 , p_line_att12                    IN VARCHAR2
 , p_line_att13                    IN VARCHAR2
 , p_line_att14                    IN VARCHAR2
 , p_line_att15                    IN VARCHAR2
 , p_shipment_att1                 IN VARCHAR2
 , p_shipment_att2                 IN VARCHAR2
 , p_shipment_att3                 IN VARCHAR2
 , p_shipment_att4                 IN VARCHAR2
 , p_shipment_att5                 IN VARCHAR2
 , p_shipment_att6                 IN VARCHAR2
 , p_shipment_att7                 IN VARCHAR2
 , p_shipment_att8                 IN VARCHAR2
 , p_shipment_att9                 IN VARCHAR2
 , p_shipment_att10                IN VARCHAR2
 , p_shipment_att11                IN VARCHAR2
 , p_shipment_att12                IN VARCHAR2
 , p_shipment_att13                IN VARCHAR2
 , p_shipment_att14                IN VARCHAR2
 , p_shipment_att15                IN VARCHAR2
 , p_distribution_att1             IN VARCHAR2
 , p_distribution_att2             IN VARCHAR2
 , p_distribution_att3             IN VARCHAR2
 , p_distribution_att4             IN VARCHAR2
 , p_distribution_att5             IN VARCHAR2
 , p_distribution_att6             IN VARCHAR2
 , p_distribution_att7             IN VARCHAR2
 , p_distribution_att8             IN VARCHAR2
 , p_distribution_att9             IN VARCHAR2
 , p_distribution_att10            IN VARCHAR2
 , p_distribution_att11            IN VARCHAR2
 , p_distribution_att12            IN VARCHAR2
 , p_distribution_att13            IN VARCHAR2
 , p_distribution_att14            IN VARCHAR2
 , p_distribution_att15            IN VARCHAR2
 , FB_ERROR_MSG                    IN OUT NOCOPY VARCHAR2
 , p_Award_id                      IN NUMBER
 , p_vendor_site_id                IN NUMBER
);

--========================================================================
-- PROCEDURE  : Create_Documents             PUBLIC
-- PARAMETERS : p_batch_id                   Batch Id
--              p_document_id                Document Id that was created
--              p_document_number            Document number
--              p_line                       Number of lines created
--              x_error_code                 Return status
-- COMMENT    : Wrapper to the PO autocreate to create document
--========================================================================
PROCEDURE create_documents
( p_batch_id        IN NUMBER
, p_document_id     IN OUT NOCOPY NUMBER
, p_document_number IN OUT NOCOPY VARCHAR2
, p_line            IN OUT NOCOPY NUMBER
, x_error_code      OUT NOCOPY NUMBER
);

--========================================================================
-- PROCEDURE  : Get_Break_Price              PUBLIC
-- PARAMETERS: p_order_quantity              Quantity
--             p_ship_to_org                 Ship to Org
--             p_ship_to_loc                 Ship to location
--             p_po_line_id                  PO Line Id
--             p_cum_flag                    Cumulative flag
--             p_need_by_date                Need by Date
--             p_line_location_id            Line location
--             x_po_price                    PO price without tax
-- COMMENT   : Wrapper to the PO API to get price breaks
--========================================================================
PROCEDURE get_break_price
( p_order_quantity    IN  NUMBER
, p_ship_to_org       IN  NUMBER
, p_ship_to_loc       IN  NUMBER
, p_po_line_id        IN  NUMBER
, p_cum_flag          IN  BOOLEAN
, p_need_by_date      IN  DATE
, p_line_location_id  IN  NUMBER
, x_po_price          OUT NOCOPY NUMBER
);

--========================================================================
-- FUNCTION  : Is_Global                     PUBLIC
-- PARAMETERS: p_header_id                   Blanket header Id
-- COMMENT   : Wrapper to the PO API to check for Global Agreement
--========================================================================
FUNCTION is_global
( p_header_id  IN NUMBER
) RETURN BOOLEAN;

END INV_THIRD_PARTY_STOCK_PO_MDTR;

 

/
