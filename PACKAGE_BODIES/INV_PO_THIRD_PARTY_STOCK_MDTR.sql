--------------------------------------------------------
--  DDL for Package Body INV_PO_THIRD_PARTY_STOCK_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PO_THIRD_PARTY_STOCK_MDTR" AS
-- $Header: INVMPOXB.pls 120.5 2006/03/15 00:43:24 kdevadas noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMPOXB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Consigned inventory INV/PO dependency wrapper API                  |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Get_Blanket_Number                                                |
--|     Generate_Account                                                  |
--|     Get_Asl_Info                                                      |
--|     Create_Documents                                                  |
--|     Get_Elapsed_Info                                                  |
--|     Update_Asl                                                        |
--|     Get_Price_Break                                                   |
--|     Is_Global                                                         |
--|     archive_po                                                        |
--|     get_total                                                         |
--|                                                                       |
--| HISTORY                                                               |
--|     12/01/02 pseshadr   Created                                       |
--|     12/01/02 dherring   Created     								  |
--|     09-Mar-06 kdevadas  get_break_price API changed for Advanced 	  |
--|				  			Pricing updtake - bug 5076263				  |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_PO_THIRD_PARTY_STOCK_MDTR';


--===================
-- PROCEDURES AND FUNCTIONS
--===================


--========================================================================
-- PROCEDURE : Get_Blanket_Number            PUBLIC
-- PARAMETERS: p_inventory_item_id           Item
--             p_item_revision               Item Revision
--             p_vendor_site_id              Vendor Site
--             p_organization_id             Inventory Organization
--             x_document_header_id          PO header id
--             x_document_line_id            PO line id
--             x_global_flag                 Flag to indicate if manual numb.
--                                           is set in case of GA
-- COMMENT   : Return document if a valid blanket exists for item,
--             supplier site,organization combination.
--             This procedure is invoked when
--             performing a Transfer to regular stock transaction.
--========================================================================
PROCEDURE Get_Blanket_Number
( p_inventory_item_id             IN   NUMBER
, p_item_revision                 IN   VARCHAR2
, p_vendor_site_id                IN   NUMBER
, p_organization_id               IN   NUMBER
, p_transaction_date              IN   DATE
, x_document_header_id            OUT  NOCOPY NUMBER
, x_document_line_id              OUT  NOCOPY NUMBER
, x_global_flag                   OUT  NOCOPY VARCHAR2
)
IS
l_vendor_id               NUMBER;
l_vendor_site_id          NUMBER;
l_org_id                  NUMBER;
l_po_num_code             VARCHAR2(25);
x_document_type_code      VARCHAR2(50);
x_document_line_num       NUMBER;
x_vendor_contact_id       NUMBER;
x_vendor_product_num      VARCHAR2(25);
x_buyer_id                NUMBER;
x_currency_code           VARCHAR2(10);
x_item_rev                NUMBER;
x_purchasing_uom          VARCHAR2(25);
x_asl_id                  NUMBER ;
x_multi_org               VARCHAR2(10) := 'N';
l_fp_org_id               NUMBER;
l_vs_org_id               NUMBER;
l_debug                   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


CURSOR c_fp IS
  SELECT
    NVL(org_id,-99)
  FROM
    financials_system_parameters;


BEGIN

  -- Call the document sourcing API which returns the most recent
  -- document type and document number for the item,supplier site
  -- and organization.

  -- Get the vendor id from vendor site;

  l_vendor_site_id := p_vendor_site_id;

  SELECT
    vendor_id
  , org_id
  INTO
    l_vendor_id
  , l_vs_org_id
  FROM
    po_vendor_sites_all
  WHERE vendor_site_id = l_vendor_site_id;

  -- Get the most recent valid blanket PO for the item,supplier,org
  -- combination.The document sourcing API sources from blankets and
  -- quotations if destination_doc_type is REQ. However, if both a
  -- blanket and quotation exists, it returns the blanket info always.

  OPEN c_fp;
  FETCH c_fp
  INTO
    l_fp_org_id;

  IF c_fp%NOTFOUND
  THEN
    INV_LOG_UTIL.trace('No data in FSP :','INV_THIRD_PARTY_STOCK_PVT',9);
    l_fp_org_id := NULL;
  ELSE
    INV_LOG_UTIL.trace('Org id set is :'||l_fp_org_id,'INV_THIRD_PARTY_STOCK_PVT',9);
  END IF;
  CLOSE c_fp;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace('Values passed to Document Sourcing :','INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('Item is : '||p_inventory_item_id,'INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('Vendor  is : '||l_vendor_id,'INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('Organization  is : '||p_organization_id,'INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('Currency  is : '||x_currency_code,'INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('Rev  is : '||p_item_revision,'INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('Site  is : '||l_vendor_site_id,'INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('Multiorg  is :N','INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('Destination doc type  is :REQ','INV_THIRD_PARTY_STOCK_PVT',9);
  END IF;


  IF NVL(l_vs_org_id,-99) <> NVL(l_fp_org_id,-99)
  THEN
    INV_LOG_UTIL.trace('Different operating unit :','INV_THIRD_PARTY_STOCK_PVT',9);
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_vs_org_id);
    --MO_GLOBAL.Init('PO');
    MO_GLOBAL.set_policy_context('S',l_vs_org_id);

    INV_LOG_UTIL.trace('Now setting OU to :'||l_vs_org_id,'INV_THIRD_PARTY_STOCK_PVT',9);
  END IF;

  MO_GLOBAL.set_policy_context('S',l_vs_org_id);

  PO_AUTOSOURCE_SV.document_sourcing
  ( x_item_id              => p_inventory_item_id
  , x_vendor_id            => l_vendor_id
  , x_destination_doc_type => 'REQ'
  , x_organization_id      => p_organization_id
  , x_currency_code        => x_currency_code
  , x_item_rev             => p_item_revision
  , x_autosource_date      => NVL(p_transaction_date,SYSDATE)
  , x_vendor_site_id       => l_vendor_site_id
  , x_document_header_id   => x_document_header_id
  , x_document_type_code   => x_document_type_code
  , x_document_line_num    => x_document_line_num
  , x_document_line_id     => x_document_line_id
  , x_vendor_contact_id    => x_vendor_contact_id
  , x_vendor_product_num   => x_vendor_product_num
  , x_buyer_id             => x_buyer_id
  , x_purchasing_uom       => x_purchasing_uom
  , x_asl_id               => x_asl_id
  , x_multi_org            => x_multi_org
  );


  -- Check if the doc type is blanket;

  IF (x_document_type_code <> 'BLANKET') OR (x_document_header_id IS NULL)
  THEN
    x_document_header_id := NULL;
    x_document_line_id   := NULL;
    x_global_flag        := 'N';
  ELSE
    -- Check if the blanket is a global agreement

    IF is_global(x_document_header_id)
    THEN

      SELECT
        org_id
      INTO
        l_org_id
      FROM
        po_vendor_sites_all
      WHERE vendor_site_id = l_vendor_site_id;

      SELECT
        user_defined_po_num_code
      INTO
        l_po_num_code
      FROM
        po_system_parameters_all
      WHERE  NVL(org_id,-99) = NVL(l_org_id,-99);

      -- If the blanket is a GA, and automatic numbering is not set,
      -- set the global flag to Y, so that we can fail the consumption
      -- with the appropriate error message.

      IF l_po_num_code <> 'AUTOMATIC'
      THEN
        x_document_header_id := NULL;
        x_document_line_id   := NULL;
        x_global_flag        := 'Y';
      ELSE
        x_global_flag        := 'N';
      END IF;

    END IF;
  END IF;
END Get_Blanket_Number;

--========================================================================
-- PROCEDURE : Get_Blanket_Number            PUBLIC
-- PARAMETERS: p_inventory_item_id           Item
--             p_item_revision               Item Revision
--             p_vendor_site_id              Vendor Site
--             p_organization_id             Inventory Organization
--             x_document_header_id          PO header id
--             x_document_line_id            PO line id
--             x_global_flag                 Flag to indicate if manual numb.
--                                           is set in case of GA
-- COMMENT   : Return document if a valid blanket exists for item,
--             supplier site,organization combination.
--             This procedure is invoked when
--             performing a Transfer to regular stock transaction.
--========================================================================
PROCEDURE Get_Blanket_Number
( p_inventory_item_id             IN   NUMBER
, p_item_revision                 IN   VARCHAR2
, p_vendor_site_id                IN   NUMBER
, p_organization_id               IN   NUMBER
, x_document_header_id            OUT  NOCOPY NUMBER
, x_document_line_id              OUT  NOCOPY NUMBER
, x_global_flag                   OUT  NOCOPY VARCHAR2
)
IS
l_document_header_id  NUMBER;
l_document_line_id    NUMBER;
l_global_flag         VARCHAR2(1);

BEGIN
  INV_PO_THIRD_PARTY_STOCK_MDTR.Get_Blanket_Number
  ( p_inventory_item_id   => p_inventory_item_id
  , p_item_revision       => p_item_revision
  , p_vendor_site_id      => p_vendor_site_id
  , p_organization_id     => p_organization_id
  , p_transaction_date    => TRUNC(SYSDATE)
  , x_document_header_id  => l_document_header_id
  , x_document_line_id    => l_document_line_id
  , x_global_flag         => l_global_flag
  );

  x_document_header_id := l_document_header_id;
  x_document_line_id   := l_document_line_id;
  x_global_flag        := l_global_flag;

END Get_Blanket_Number;

--========================================================================
-- PROCEDURE  :  Generate_Account              PUBLIC
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
--               to the PO Account builder
--========================================================================

PROCEDURE  Generate_Account
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
 , p_fb_error_msg                  IN OUT NOCOPY VARCHAR2
 , p_Award_id                      IN NUMBER
 , p_vendor_site_id                IN NUMBER
)
IS
l_success                      BOOLEAN;
l_new_combination              BOOLEAN;
l_charge_success               BOOLEAN := TRUE;
l_budget_success               BOOLEAN := TRUE;
l_accrual_success              BOOLEAN := TRUE;
l_variance_success             BOOLEAN := TRUE;
l_coa_id                       NUMBER;
l_bom_resource_id              NUMBER;
l_bom_cost_element_id          NUMBER;
l_category_id                  NUMBER;
l_destination_type_code        VARCHAR2(50);
l_deliver_to_location_id       NUMBER;
l_destination_organization_id  NUMBER ;
l_destination_subinventory     VARCHAR2(50);
l_expenditure_type             VARCHAR2(50);
l_expenditure_organization_id  NUMBER ;
l_expenditure_item_date        DATE;
l_item_id                      NUMBER ;
l_line_type_id                 NUMBER ;
l_result_billable_flag         VARCHAR2(50);
l_agent_id                     NUMBER ;
l_project_id                   NUMBER;
l_from_type_lookup_code        VARCHAR2(50);
l_from_header_id               NUMBER;
l_from_line_id                 NUMBER;
l_task_id                      NUMBER;
l_deliver_to_person_id         NUMBER;
l_type_lookup_code             VARCHAR2(50);
l_vendor_id                    NUMBER ;
l_vendor_site_id               NUMBER ;
l_wip_entity_id                NUMBER;
l_wip_entity_type              VARCHAR2(50);
l_wip_line_id                  NUMBER;
l_wip_repetitive_schedule_id   NUMBER;
l_wip_operation_seq_num        NUMBER;
l_wip_resource_seq_num         NUMBER;
l_gl_encumbered_date           DATE;
l_code_combination_id          NUMBER;
l_accrual_account_id           NUMBER;
l_variance_account_id          NUMBER;
l_charge_account_id            NUMBER;
l_budget_account_id            NUMBER;
l_award_id                     NUMBER;
l_charge_account_flex          VARCHAR2(2000);
l_budget_account_flex          VARCHAR2(2000);
l_accrual_account_flex         VARCHAR2(2000);
l_variance_account_flex        VARCHAR2(2000);
l_charge_account_desc          VARCHAR2(2000);
l_budget_account_desc          VARCHAR2(2000);
l_accrual_account_desc         VARCHAR2(2000);
l_variance_account_desc        VARCHAR2(2000);
l_charge_field_name            VARCHAR2(60);
l_budget_field_name            VARCHAR2(60);
l_accrual_field_name           VARCHAR2(60);
l_variance_field_name          VARCHAR2(60);
l_charge_desc_field_name       VARCHAR2(60);
l_budget_desc_field_name       VARCHAR2(60);
l_accrual_desc_field_name      VARCHAR2(60);
l_variance_desc_field_name     VARCHAR2(60);
l_progress                     VARCHAR2(3) := '001';
l_new_ccid                     NUMBER;
l_ccid_returned                BOOLEAN := FALSE;
l_header_att1                  VARCHAR2(150) := NULL;
l_header_att2                  VARCHAR2(150) := NULL;
l_header_att3                  VARCHAR2(150) := NULL;
l_header_att4                  VARCHAR2(150) := NULL;
l_header_att5                  VARCHAR2(150) := NULL;
l_header_att6                  VARCHAR2(150) := NULL;
l_header_att7                  VARCHAR2(150) := NULL;
l_header_att8                  VARCHAR2(150) := NULL;
l_header_att9                  VARCHAR2(150) := NULL;
l_header_att10                 VARCHAR2(150) := NULL;
l_header_att11                 VARCHAR2(150) := NULL;
l_header_att12                 VARCHAR2(150) := NULL;
l_header_att13                 VARCHAR2(150) := NULL;
l_header_att14                 VARCHAR2(150) := NULL;
l_header_att15                 VARCHAR2(150) := NULL;
l_line_att1                    VARCHAR2(150) := NULL;
l_line_att2                    VARCHAR2(150) := NULL;
l_line_att3                    VARCHAR2(150) := NULL;
l_line_att4                    VARCHAR2(150) := NULL;
l_line_att5                    VARCHAR2(150) := NULL;
l_line_att6                    VARCHAR2(150) := NULL;
l_line_att7                    VARCHAR2(150) := NULL;
l_line_att8                    VARCHAR2(150) := NULL;
l_line_att9                    VARCHAR2(150) := NULL;
l_line_att10                   VARCHAR2(150) := NULL;
l_line_att11                   VARCHAR2(150) := NULL;
l_line_att12                   VARCHAR2(150) := NULL;
l_line_att13                   VARCHAR2(150) := NULL;
l_line_att14                   VARCHAR2(150) := NULL;
l_line_att15                   VARCHAR2(150) := NULL;
l_header_name                  VARCHAR2(20);
l_acc_field_name               VARCHAR2(60);
l_concat_segs                  VARCHAR2(240);
l_concat_desc                  VARCHAR2(2000);
l_wf_itemkey                   VARCHAR2(80);
l_po_encumberance_flag         VARCHAR2(2) ;
l_ccid_passed_in               BOOLEAN := FALSE;
l_new_ccid_generated           BOOLEAN := FALSE;
l_debug                        BOOLEAN := TRUE;
l_shipment_att1                VARCHAR2(150);
l_shipment_att2                VARCHAR2(150);
l_shipment_att3                VARCHAR2(150) ;
l_shipment_att4                VARCHAR2(150) ;
l_shipment_att5                VARCHAR2(150) ;
l_shipment_att6                VARCHAR2(150) ;
l_shipment_att7                VARCHAR2(150) ;
l_shipment_att8                VARCHAR2(150) ;
l_shipment_att9                VARCHAR2(150) ;
l_shipment_att10               VARCHAR2(150) ;
l_shipment_att11               VARCHAR2(150) ;
l_shipment_att12               VARCHAR2(150) ;
l_shipment_att13               VARCHAR2(150) ;
l_shipment_att14               VARCHAR2(150) ;
l_shipment_att15               VARCHAR2(150) ;
l_distribution_att1            VARCHAR2(150) ;
l_distribution_att2            VARCHAR2(150) ;
l_distribution_att3            VARCHAR2(150) ;
l_distribution_att4            VARCHAR2(150) ;
l_distribution_att5            VARCHAR2(150) ;
l_distribution_att6            VARCHAR2(150) ;
l_distribution_att7            VARCHAR2(150);
l_distribution_att8            VARCHAR2(150);
l_distribution_att9            VARCHAR2(150);
l_distribution_att10           VARCHAR2(150) ;
l_distribution_att11           VARCHAR2(150) ;
l_distribution_att12           VARCHAR2(150) ;
l_distribution_att13           VARCHAR2(150) ;
l_distribution_att14           VARCHAR2(150) ;
l_distribution_att15           VARCHAR2(150) ;
l_fb_error_msg                 VARCHAR2(2000);
l_dest_charge_success          BOOLEAN;
l_dest_variance_success        BOOLEAN;
l_dest_charge_account_id       NUMBER;
l_dest_variance_account_id     NUMBER;
l_dest_charge_account_desc     VARCHAR2(2000);
l_dest_variance_account_desc   VARCHAR2(2000);
l_dest_charge_account_flex     VARCHAR2(2000);
l_dest_variance_account_flex   VARCHAR2(2000);

BEGIN

  l_charge_success              := p_charge_success;
  l_budget_success              := p_budget_success;
  l_accrual_success             := p_accrual_success;
  l_variance_success            := p_variance_success;
  l_code_combination_id         := p_code_combination_id;
  l_budget_account_id           := p_budget_account_id;
  l_accrual_account_id          := p_accrual_account_id;
  l_variance_account_id         := p_variance_account_id;
  l_charge_account_flex         := p_charge_account_flex;
  l_budget_account_flex         := p_budget_account_flex;
  l_accrual_account_flex        := p_accrual_account_flex;
  l_variance_account_flex       := p_variance_account_flex;
  l_charge_account_desc         := p_charge_account_desc;
  l_budget_account_desc         := p_budget_account_desc;
  l_accrual_account_desc        := p_accrual_account_desc;
  l_variance_account_desc       := p_variance_account_desc;
  l_coa_id                      := p_coa_id;
  l_bom_resource_id             := p_bom_resource_id;
  l_bom_cost_element_id         := p_bom_cost_element_id;
  l_category_id                 := p_category_id;
  l_destination_type_code       := p_destination_type_code;
  l_deliver_to_location_id      := p_deliver_to_location_id;
  l_destination_organization_id := p_destination_organization_id;
  l_destination_subinventory    := p_destination_subinventory;
  l_expenditure_type            := p_expenditure_type;
  l_expenditure_organization_id := p_expenditure_organization_id;
  l_expenditure_item_date       := p_expenditure_item_date;
  l_item_id                     := p_item_id;
  l_line_type_id                := p_line_type_id;
  l_result_billable_flag        := p_result_billable_flag;
  l_agent_id                    := p_agent_id;
  l_project_id                  := p_project_id;
  l_from_type_lookup_code       := p_from_type_lookup_code;
  l_from_header_id              := p_from_header_id;
  l_from_line_id                := p_from_line_id;
  l_task_id                     := p_task_id;
  l_deliver_to_person_id        := p_deliver_to_person_id;
  l_type_lookup_code            := p_type_lookup_code;
  l_vendor_id                   := p_vendor_id;
  l_vendor_site_id              := p_vendor_site_id;
  l_wip_entity_id               := p_wip_entity_id;
  l_wip_entity_type             := p_wip_entity_type;
  l_wip_line_id                 := p_wip_line_id ;
  l_wip_repetitive_schedule_id  := p_wip_repetitive_schedule_id;
  l_wip_operation_seq_num       := p_wip_operation_seq_num;
  l_wip_resource_seq_num        := p_wip_resource_seq_num;
  l_po_encumberance_flag        := p_po_encumberance_flag;
  l_gl_encumbered_date          := p_gl_encumbered_date;
  l_wf_itemkey                  := p_wf_itemkey;
  l_new_combination             := p_new_combination;
  l_header_att1                 := p_header_att1;
  l_header_att2                 := p_header_att2;
  l_header_att3                 := p_header_att3;
  l_header_att4                 := p_header_att4;
  l_header_att5                 := p_header_att5;
  l_header_att6                 := p_header_att6;
  l_header_att7                 := p_header_att7;
  l_header_att8                 := p_header_att8;
  l_header_att9                 := p_header_att9;
  l_header_att10                := p_header_att10;
  l_header_att11                := p_header_att11;
  l_header_att12                := p_header_att12;
  l_header_att13                := p_header_att13;
  l_header_att14                := p_header_att14;
  l_header_att15                := p_header_att15;
  l_line_att1                   := p_line_att1;
  l_line_att2                   := p_line_att2;
  l_line_att3                   := p_line_att3;
  l_line_att4                   := p_line_att4;
  l_line_att5                   := p_line_att5;
  l_line_att6                   := p_line_att6;
  l_line_att7                   := p_line_att7;
  l_line_att8                   := p_line_att8;
  l_line_att9                   := p_line_att9;
  l_line_att10                  := p_line_att10;
  l_line_att11                  := p_line_att11;
  l_line_att12                  := p_line_att12;
  l_line_att13                  := p_line_att13;
  l_line_att14                  := p_line_att14;
  l_line_att15                  := p_line_att15;
  l_shipment_att1               := p_shipment_att1;
  l_shipment_att2               := p_shipment_att2;
  l_shipment_att3               := p_shipment_att3;
  l_shipment_att4               := p_shipment_att4;
  l_shipment_att5               := p_shipment_att5;
  l_shipment_att6               := p_shipment_att6;
  l_shipment_att7               := p_shipment_att7;
  l_shipment_att8               := p_shipment_att8;
  l_shipment_att9               := p_shipment_att9;
  l_shipment_att10              := p_shipment_att10;
  l_shipment_att11              := p_shipment_att11;
  l_shipment_att12              := p_shipment_att12;
  l_shipment_att13              := p_shipment_att13;
  l_shipment_att14              := p_shipment_att14;
  l_shipment_att15              := p_shipment_att15;
  l_distribution_att1           := p_distribution_att1;
  l_distribution_att2           := p_distribution_att2;
  l_distribution_att3           := p_distribution_att3;
  l_distribution_att4           := p_distribution_att4;
  l_distribution_att5           := p_distribution_att5;
  l_distribution_att6           := p_distribution_att6;
  l_distribution_att7           := p_distribution_att7;
  l_distribution_att8           := p_distribution_att8;
  l_distribution_att9           := p_distribution_att9;
  l_distribution_att10          := p_distribution_att10;
  l_distribution_att11          := p_distribution_att11;
  l_distribution_att12          := p_distribution_att12;
  l_distribution_att13          := p_distribution_att13;
  l_distribution_att14          := p_distribution_att14;
  l_distribution_att15          := p_distribution_att15;
  l_fb_error_msg                := p_fb_error_msg;
  l_award_id                    := p_award_id;

  l_success := PO_WF_BUILD_ACCOUNT_INIT.Start_Workflow
               ( x_charge_success                 => l_charge_success
               , x_budget_success                 => l_budget_success
               , x_accrual_success                => l_accrual_success
               , x_variance_success               => l_variance_success
               , x_code_combination_id            => l_code_combination_id
               , x_budget_account_id              => l_budget_account_id
               , x_accrual_account_id             => l_accrual_account_id
               , x_variance_account_id            => l_variance_account_id
               , x_charge_account_flex            => l_charge_account_flex
               , x_budget_account_flex            => l_budget_account_flex
               , x_accrual_account_flex           => l_accrual_account_flex
               , x_variance_account_flex          => l_variance_account_flex
               , x_charge_account_desc            => l_charge_account_desc
               , x_budget_account_desc            => l_budget_account_desc
               , x_accrual_account_desc           => l_accrual_account_desc
               , x_variance_account_desc          => l_variance_account_desc
               , x_coa_id                         => l_coa_id
               , x_bom_resource_id                => l_bom_resource_id
               , x_bom_cost_element_id            => l_bom_cost_element_id
               , x_category_id                    => l_category_id
               , x_destination_type_code          => l_destination_type_code
               , x_deliver_to_location_id         => l_deliver_to_location_id
               , x_destination_organization_id    =>
                   l_destination_organization_id
               , x_destination_subinventory       =>
                   l_destination_subinventory
               , x_expenditure_type               => l_expenditure_type
               , x_expenditure_organization_id    =>
                   l_expenditure_organization_id
               , x_expenditure_item_date          => l_expenditure_item_date
               , x_item_id                        => l_item_id
               , x_line_type_id                   => l_line_type_id
               , x_result_billable_flag           => l_result_billable_flag
               , x_agent_id                       => l_agent_id
               , x_project_id                     => l_project_id
               , x_from_type_lookup_code          => l_from_type_lookup_code
               , x_from_header_id                 => l_from_header_id
               , x_from_line_id                   => l_from_line_id
               , x_task_id                        => l_task_id
               , x_deliver_to_person_id           => l_deliver_to_person_id
               , x_type_lookup_code               => l_type_lookup_code
               , x_vendor_id                      => l_vendor_id
               , x_wip_entity_id                  => l_wip_entity_id
               , x_wip_entity_type                => l_wip_entity_type
               , x_wip_line_id                    => l_wip_line_id
               , x_wip_repetitive_schedule_id     =>
                   l_wip_repetitive_schedule_id
               , x_wip_operation_seq_num          => l_wip_operation_seq_num
               , x_wip_resource_seq_num           => l_wip_resource_seq_num
               , x_po_encumberance_flag           => l_po_encumberance_flag
               , x_gl_encumbered_date             => l_gl_encumbered_date
               , wf_itemkey                       => l_wf_itemkey
               , x_new_combination                => l_new_combination
               , header_att1                      => l_header_att1
               , header_att2                      => l_header_att2
               , header_att3                      => l_header_att3
               , header_att4                      => l_header_att4
               , header_att5                      => l_header_att5
               , header_att6                      => l_header_att6
               , header_att7                      => l_header_att7
               , header_att8                      => l_header_att8
               , header_att9                      => l_header_att9
               , header_att10                     => l_header_att10
               , header_att11                     => l_header_att11
               , header_att12                     => l_header_att12
               , header_att13                     => l_header_att13
               , header_att14                     => l_header_att14
               , header_att15                     => l_header_att15
               , line_att1                        => l_line_att1
               , line_att2                        => l_line_att2
               , line_att3                        => l_line_att3
               , line_att4                        => l_line_att4
               , line_att5                        => l_line_att5
               , line_att6                        => l_line_att6
               , line_att7                        => l_line_att7
               , line_att8                        => l_line_att8
               , line_att9                        => l_line_att9
               , line_att10                       => l_line_att10
               , line_att11                       => l_line_att11
               , line_att12                       => l_line_att12
               , line_att13                       => l_line_att13
               , line_att14                       => l_line_att14
               , line_att15                       => l_line_att15
               , shipment_att1                    => l_shipment_att1
               , shipment_att2                    => l_shipment_att2
               , shipment_att3                    => l_shipment_att3
               , shipment_att4                    => l_shipment_att4
               , shipment_att5                    => l_shipment_att5
               , shipment_att6                    => l_shipment_att6
               , shipment_att7                    => l_shipment_att7
               , shipment_att8                    => l_shipment_att8
               , shipment_att9                    => l_shipment_att9
               , shipment_att10                   => l_shipment_att10
               , shipment_att11                   => l_shipment_att11
               , shipment_att12                   => l_shipment_att12
               , shipment_att13                   => l_shipment_att13
               , shipment_att14                   => l_shipment_att14
               , shipment_att15                   => l_shipment_att15
               , distribution_att1                => l_distribution_att1
               , distribution_att2                => l_distribution_att2
               , distribution_att3                => l_distribution_att3
               , distribution_att4                => l_distribution_att4
               , distribution_att5                => l_distribution_att5
               , distribution_att6                => l_distribution_att6
               , distribution_att7                => l_distribution_att7
               , distribution_att8                => l_distribution_att8
               , distribution_att9                => l_distribution_att9
               , distribution_att10               => l_distribution_att10
               , distribution_att11               => l_distribution_att11
               , distribution_att12               => l_distribution_att12
               , distribution_att13               => l_distribution_att13
               , distribution_att14               => l_distribution_att14
               , distribution_att15               => l_distribution_att15
               , FB_ERROR_MSG                     => l_fb_error_msg
               , x_Award_id                       => l_award_id
               , x_vendor_site_id                 => l_vendor_site_id
               );

  p_charge_account_id   := l_code_combination_id;
  p_accrual_account_id  := l_accrual_account_id;
  p_variance_account_id := l_variance_account_id;

  IF NOT l_success
  THEN
    -- Pass the message back to the calling pgm so that
    -- it is added to the message stack;
    p_fb_error_msg := 'INV_CONS_SUP_GEN_ACCT';
  ELSE
    p_fb_error_msg := NULL;
  END IF;

END Generate_Account;

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
)
IS
l_asl_id             NUMBER;
l_vendor_product_num VARCHAR2(25);
l_purchasing_uom     VARCHAR2(25);
l_item_id            NUMBER;
l_vendor_id          NUMBER;
l_vendor_site_id     NUMBER;
l_using_organization_id NUMBER;
l_cons_sup_flag      VARCHAR2(1);
l_enable_vmi_flag    VARCHAR2(1);
l_last_billing_date  DATE;
l_consigned_billing_cycle  NUMBER;
l_vmi_min_qty        NUMBER;
l_vmi_max_qty        NUMBER;
l_vmi_auto_replenish_flag  VARCHAR2(1);
l_vmi_replenishment_approval VARCHAR2(40);

BEGIN

  l_item_id               := p_item_id;
  l_vendor_id             := p_vendor_id;
  l_vendor_site_id        := p_vendor_site_id;
  l_using_organization_id := p_using_organization_id;

  PO_AUTOSOURCE_SV.get_asl_info
  ( x_item_id                       => l_item_id
  , x_vendor_id                     => l_vendor_id
  , x_vendor_site_id                => l_vendor_site_id
  , x_using_organization_id         => l_using_organization_id
  , x_asl_id                        => l_asl_id
  , x_vendor_product_num            => l_vendor_product_num
  , x_purchasing_uom                => l_purchasing_uom
  , x_consigned_from_supplier_flag  => l_cons_sup_flag
  , x_enable_vmi_flag               => l_enable_vmi_flag
  , x_last_billing_date             => l_last_billing_date
  , x_consigned_billing_cycle       => l_consigned_billing_cycle
  , x_vmi_min_qty                   => l_vmi_min_qty
  , x_vmi_max_qty                   => l_vmi_max_qty
  , x_vmi_auto_replenish_flag       => l_vmi_auto_replenish_flag
  , x_vmi_replenishment_approval    => l_vmi_replenishment_approval
  );


  IF l_asl_id IS NOT NULL AND NVL(l_cons_sup_flag, 'N') = 'N' THEN
    l_asl_id := NULL;
  END IF;

  x_asl_id             := l_asl_id;
  x_vendor_product_num := l_vendor_product_num;
  x_purchasing_uom     := l_purchasing_uom;

END Get_Asl_Info;

--========================================================================
-- PROCEDURE  : Get_Elapsed_Info                 PUBLIC
-- PARAMETERS: p_org_id                org id
--             p_asl_id                asl id
--             x_bill_date_elapsed     indicates if txn can be processed
-- COMMENT:    Wrapper for get asl info sql in purchasing
--========================================================================
PROCEDURE Get_Elapsed_Info
( p_org_id               IN NUMBER
, p_asl_id               IN NUMBER
, x_bill_date_elapsed    OUT NOCOPY NUMBER
)
IS
l_org_id             NUMBER;
l_asl_id             NUMBER;
l_bill_date_elapsed  NUMBER;
BEGIN

  l_org_id := p_org_id;
  l_asl_id := p_asl_id;

  SELECT COUNT(*)
  INTO l_bill_date_elapsed
  FROM po_asl_attributes
  WHERE TRUNC(last_billing_date) +
        NVL(consigned_billing_cycle,0) > TRUNC(SYSDATE)
  AND asl_id = l_asl_id ;

  x_bill_date_elapsed := l_bill_date_elapsed;

END Get_Elapsed_Info;

--========================================================================
-- PROCEDURE  : Update_Asl                   PUBLIC
-- PARAMETERS : p_asl_id                     Asl Id
-- COMMENT    : Update the billing date of the current asl
--========================================================================
PROCEDURE update_asl
( p_asl_id        IN NUMBER
)
IS
l_asl_id             NUMBER;
BEGIN

  l_asl_id := p_asl_id;

  -- Update the billing date of the current asl

  UPDATE
    po_asl_attributes
  SET last_billing_date = SYSDATE
  WHERE asl_id = l_asl_id;

END update_asl;

--========================================================================
-- PROCEDURE  : Create_Documents             PUBLIC
-- PARAMETERS : p_batch_id                   Batch Id
--              p_document_id                Document Id that was created
--              p_document_number            Document number
--              p_line                       Number of lines created
--              x_error_code                 Return status
-- COMMENT    : Wrapper to the PO autocreate to create document
--              This is invoked by Create Consumption Advice
--========================================================================
PROCEDURE create_documents
( p_batch_id        IN NUMBER
, p_document_id     IN OUT NOCOPY NUMBER
, p_document_number IN OUT NOCOPY VARCHAR2
, p_line            IN OUT NOCOPY NUMBER
, x_error_code      OUT NOCOPY NUMBER
)
IS

BEGIN

  -- Invoke the Autocreate to create the consumption advice

  PO_INTERFACE_S.create_documents
  ( x_batch_id                   => p_batch_id
  , x_document_id                => p_document_id
  , x_document_number            => p_document_number
  , x_number_lines               => p_line
  , x_errorcode                  => x_error_code
  );
END create_documents;

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
-- COMMENT   : Call the PO API to get price breaks
--             This is invoked by Get_PO_Info procedure to calculate
--             the PO price for the transaction.
--========================================================================
/* get break price API changed for Advanced Pricing Uptake - Bug 5076263 */
PROCEDURE get_break_price(
  p_api_version       IN  NUMBER
, p_order_quantity    IN  NUMBER
, p_ship_to_org       IN  NUMBER
, p_ship_to_loc       IN  NUMBER
, p_po_line_id 	      IN  NUMBER
, p_cum_flag 	      IN  BOOLEAN
, p_need_by_date   	  IN  DATE
, p_line_location_id  IN  NUMBER
, p_contract_id 	  IN  NUMBER
, p_org_id 			  IN  NUMBER
, p_supplier_id       IN  NUMBER
, p_supplier_site_id  IN  NUMBER
, p_creation_date     IN  DATE
, p_order_header_id   IN  NUMBER
, p_order_line_id     IN  NUMBER
, p_line_type_id      IN  NUMBER
, p_item_revision     IN  VARCHAR2
, p_item_id           IN  NUMBER
, p_category_id       IN  NUMBER
, p_supplier_item_num IN  VARCHAR2
, p_uom 			  IN  VARCHAR2
, p_in_price 		  IN  NUMBER
, p_currency_code 	  IN  VARCHAR2
, x_base_unit_price   OUT NOCOPY NUMBER
, x_price_break_id 	  OUT NOCOPY NUMBER
, x_price 			  OUT NOCOPY NUMBER
, x_return_status 	  OUT NOCOPY VARCHAR2 )
IS
BEGIN
  -- Call the price break API to calculate price breaks
  PO_SOURCING2_SV.get_break_price
    ( p_api_version		 => p_api_version
	, p_order_quantity   => p_order_quantity
    , p_ship_to_org      => p_ship_to_org
    , p_ship_to_loc      => p_ship_to_loc
    , p_po_line_id       => p_po_line_id
    , p_cum_flag         => p_cum_flag
    , p_need_by_date     => p_need_by_date
    , p_line_location_id => p_line_location_id
    , p_contract_id	     => p_contract_id
	, p_org_id			 => p_org_id
	, p_supplier_id		 => p_supplier_id
	, p_supplier_site_id => p_supplier_site_id
	, p_creation_date	 => p_creation_date
	, p_order_header_id	 => p_order_header_id
	, p_order_line_id	 => p_order_line_id
	, p_line_type_id	 => p_line_type_id
	, p_item_revision	 => p_item_revision
	, p_item_id		     => p_item_id
	, p_category_id		 => p_category_id
	, p_supplier_item_num=> p_supplier_item_num
	, p_uom				 => p_uom
	, p_in_price		 => p_in_price
	, p_currency_code    => p_currency_code
    , x_base_unit_price	 => x_base_unit_price
    , x_price_break_id   => x_price_break_id
    , x_price            => x_price
    , x_return_status    => x_return_status
    );


END get_break_price;

--========================================================================
-- FUNCTION  : Is_Global                     PUBLIC
-- PARAMETERS: p_order_quantity              Quantity
--             p_ship_to_org                 Ship to Org
--             p_ship_to_loc                 Ship to location
--             p_po_line_id                  PO Line Id
--             p_cum_flag                    Cumulative flag
--             p_need_by_date                Need by Date
--             p_line_location_id            Line location
--             x_po_price                    PO price without tax
-- COMMENT   : Call the PO API to check for Global Agreement
--========================================================================
FUNCTION is_global
( p_header_id    IN NUMBER
) RETURN BOOLEAN
IS
 l_global_flag  BOOLEAN;
BEGIN
  -- Invoke the PO API to check if it is a global agreement
  l_global_flag := PO_GA_COMMON_GRP.is_global(p_header_id);

  RETURN NVL(l_global_flag,FALSE);
END is_global;


--========================================================================
-- PROCEDURE  : archive_po                  PUBLIC
-- PARAMETERS : p_api_version               API version
--              p_document_id               Document Id
--              p_document_type             Document Type
--              p_document_subtype          Document subtype
--              x_return_status             Return status
--              x_msg_data                  Message
-- COMMENT    : Wrapper to the PO archiving to archive PO
--========================================================================
PROCEDURE archive_po
( p_api_version      IN NUMBER
, p_document_id      IN NUMBER
, p_document_type    IN VARCHAR2
, p_document_subtype IN VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
l_api_version      NUMBER;
l_document_id      NUMBER;
l_document_type    VARCHAR2(30);
l_document_subtype VARCHAR2(30);
l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(2000);
l_msg_count        NUMBER;
BEGIN

  l_api_version      := p_api_version;
  l_document_id      := p_document_id;
  l_document_type    := p_document_type;
  l_document_subtype := p_document_subtype;

  PO_DOCUMENT_ARCHIVE_GRP.archive_po
  ( p_api_version      => l_api_version
  , p_document_id      => l_document_id
  , p_document_type    => l_document_type
  , p_document_subtype => l_document_subtype
  , x_return_status    => l_return_status
  , x_msg_data         => l_msg_data
  );

  x_return_status     := l_return_status;

  x_msg_data          := l_msg_data;

END archive_po;

--========================================================================
-- PROCEDURE  : indicate_global                  PUBLIC
-- PARAMETERS : p_transaction_source_id
-- COMMENT    : determine if records in mtl_consumption_transactions
--            : as belonging to a global or local agreement
--========================================================================
PROCEDURE indicate_global
( p_transaction_source_id      IN  NUMBER
, x_global_agreement_flag      OUT NOCOPY VARCHAR2
)
IS
l_global_agreement_flag      VARCHAR2(1);
l_transaction_source_id      NUMBER;
BEGIN

  l_transaction_source_id := p_transaction_source_id;

  SELECT
    NVL(global_agreement_flag,'N')
  INTO
    l_global_agreement_flag
  FROM
    po_headers_all
  WHERE
    po_header_id = l_transaction_source_id;

  x_global_agreement_flag := l_global_agreement_flag;

END indicate_global;

--========================================================================
-- FUNCTION  : get_Total               PUBLIC
-- PARAMETERS: p_object_type           Object
--             p_header_id             Header Id
-- COMMENT   : Call the PO API to check for total released amt for a blanket
--========================================================================
FUNCTION get_Total
( p_header_id    IN NUMBER
, p_object_type  IN VARCHAR2
) RETURN NUMBER
IS
l_total_amt   NUMBER;
l_header_id   NUMBER;
l_object_type VARCHAR2(1);

BEGIN
  l_object_type := p_object_type;
  l_header_id   := p_header_id;

  -- Invoke the PO API to get the total released amounts
  l_total_amt := PO_CORE_S.get_total( x_object_type => l_object_type
                                    , x_object_id   => l_header_id
                                    );

  RETURN NVL(l_total_amt,0);

END get_Total;

END INV_PO_THIRD_PARTY_STOCK_MDTR;

/
