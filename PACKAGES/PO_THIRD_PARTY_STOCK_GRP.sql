--------------------------------------------------------
--  DDL for Package PO_THIRD_PARTY_STOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_THIRD_PARTY_STOCK_GRP" AUTHID CURRENT_USER as
--$Header: POXGTPSS.pls 120.3.12010000.2 2014/07/03 06:43:48 shipwu ship $
--+===========================================================================+
--|                    Copyright (c) 2002, 2014 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            POXGTPSS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          This package is used to the VMI and consigned from |
--|                        supplier validation                                |
--|                                                                           |
--|  HISTORY:              18-SEP-2002 : fdubois                              |
--+===========================================================================+

G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_THIRD_PARTY_STOCK_GRP';

--==========================================================================
--  FUNCTION NAME:  Validate_Local_Asl
--
--  DESCRIPTION:    the function returns TRUE if the Local ASL can be
--                  VMI or Consigned from Supplier for the IN parameters
--                  (define the ASL and the validation type). False
--                  otherwize. It then also return the Validation Error
--                  Message name
--
--  PARAMETERS:  In:  p_api_version        Standard API parameter
--                    p_init_msg_list      Standard API parameter
--                    p_commit             Standard API parameter
--                    p_validation_level   Standard API parameter
--                    p_inventory_item_id  Item identifier
--                    p_supplier_site_id   Supplier site identifier
--                    p_inventory_org_id   Inventory Organization
--                    p_validation_type    Validation to perform:
--                                         VMI or SUP_CONS
--
--              Out:  x_return_status      Standard API parameter
--                    x_msg_count          Standard API parameter
--                    x_msg_data           Standard API parameter
--                    x_validation_error_name  Error message name
--
--           Return: TRUE if OK to have Local VMI/Consigned from supplier ASL
--
--
--  DESIGN REFERENCES:	ASL_CONSSUP_DLD.doc
--
--
--  CHANGE HISTORY:	18-Sep-02	FDUBOIS   Created.
--                  15-Jan-03 VMA       Add standard API parameters to comply
--                                      with PL/SQL API standard.
--===========================================================================
FUNCTION  validate_local_asl
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, p_commit                  IN  VARCHAR2
, p_validation_level        IN  NUMBER
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_inventory_item_id       IN  NUMBER
, p_supplier_site_id        IN  NUMBER
, p_inventory_org_id        IN  NUMBER
, p_validation_type         IN  VARCHAR2
, x_validation_error_name   OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN;


--===========================================================================
--  FUNCTION NAME:  Validate_Global_Asl
--
--  DESCRIPTION:    the function retunrs TRUE if the Global ASL can be
--                  VMI or Consigned from supplier for the IN parameters
--                  (define the ASL). False otherwize. It then also
--                  return the Validation Error Message name
--
--  PARAMETERS:  In:  p_api_version        Standard API parameter
--                    p_init_msg_list      Standard API parameter
--                    p_commit             Standard API parameter
--                    p_validation_level   Standard API parameter
--                    p_inventory_item_id  Item identifier
--                    p_supplier_site_id   Supplier site identifier
--                    p_validation_type    Validation to perform:
--                                         VMI or SUP_CONS
--
--              Out:  x_return_status      Standard API parameter
--                    x_msg_count          Standard API parameter
--                    x_msg_data           Standard API parameter
--                    x_validation_error_name  Error message name
--
--           Return: TRUE if OK to have Global VMI/Consigned ASL
--
--
--  DESIGN REFERENCES:	ASL_CONSSUP_DLD.doc
--
--  CHANGE HISTORY:	22-Sep-02	FDUBOIS   Created.
--                  15-Jan-03 VMA       Add standard API parameters to comply
--                                      with PL/SQL API standard.
--===========================================================================
FUNCTION  validate_global_asl
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, p_commit                  IN  VARCHAR2
, p_validation_level        IN  NUMBER
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_inventory_item_id       IN  NUMBER
, p_supplier_site_id        IN  NUMBER
, p_inventory_org_id  IN  NUMBER default -1 --Bug 18998399
, p_validation_type         IN  VARCHAR2
, x_validation_error_name   OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN;

--===========================================================================
--  FUNCTION NAME:	Exist_TPS_ASL
--
--  DESCRIPTION:  the function returns TRUE if there exist a
--                VMI/Consined ASL within the Operating Unit.
--                If there is none it returns FALSE.
--
--  PARAMETERS:
--            Return: TRUE if exists VMI/Consigned ASL
--
--  DESIGN REFERENCES:	APXSSFSO_CONSSUP_DLD.doc
--
--  CHANGE HISTORY:	26-Sep-02	FDUBOIS   Created.
--===========================================================================
FUNCTION  Exist_TPS_ASL RETURN BOOLEAN;

--===========================================================================
-- API NAME         : Validate_Supplier_Purge
-- API TYPE         : Public
-- DESCRIPTION      : Checks whether a supplier can be
--                    purged according to Consigned Inventory criteria.
--                    A supplier cannot be purged if any of its vendor site
--                    has on hand consigned stock. The function returns
--                    'TRUE' is the supplier does not have any on hand
--                    consigned stock - in this case the supplier may be
--                    purged. The function returns 'FALSE' if the supplier
--                    has on hand consigned stock - in this case, the
--                    supplier should not be purged.
--
-- PARAMETERS       : p_vendor_id
--
-- RETURN           : 'TRUE' if the purge may proceed; 'FALSE' if the purge
--                    should not proceed.
--
-- DESIGN DOC       : SUPPUR_CONSSUP_DLD.doc
--
-- HISTORY          : 11-12-02 vma    Created
--                    12-12-02 vma    The function Supplier_Owns_Tps in
--                                    INV_SUPPLIER_OWNED_STOCK_GRP
--                                    has been moved to
--                                    PO_INV_THIRD_PARTY_STOCK_MDTR.
--                                    Modify call accordingly.
--===========================================================================
FUNCTION Validate_Supplier_Purge(p_vendor_id IN NUMBER) RETURN VARCHAR2;

--===========================================================================
-- API NAME         : Validate_Supplier_Merge
-- TYPE             : Public
-- Pre-condition    : Supplier site exists. If the supplier site does not
--                    exist, x_can_merge will contain value FND_API.G_TRUE
-- DESCRIPTION      : Checks whether a supplier site can be
--                    merged according to Consigned/VMI criteria.
--                    A merge should fail if for the FROM supplier site:
--                     - on hand quantity exists in consigned or VMI stock
--                     - open consigned shipments exist
--                     - open consumption advices exist
--                     - open VMI release lines exist
--                     ('open' meaning neither FINALLY CLOSED nor CANCELLED)
--
-- PARAMETERS       : p_api_version        Standard API parameter
--                    p_init_msg_list      Standard API parameter
--                    p_commit             Standard API parameter
--                    p_validation_level   Standard API parameter
--                    x_return_status      Standard API parameter
--                    x_msg_count          Standard API parameter
--                    x_msg_data           Standard API parameter
--                    p_vendor_site_id     Vendor site id
--                    x_can_merge          FND_API.G_FALSE if the supplier
--                                         site cannot be merged;
--                                         FND_API.G_TRUE otherwise.
--                    x_validation_error   Name of validation error.
--                                         'PO_SUP_CONS_FAIL_MERGE_TPS' if
--                                         merge should fail because on hand
--                                         consigned/VMI stock exists;
--                                         'PO_SUP_CONS_FAIL_MERGE_DOC' if
--                                         merge should fail because open PO
--                                         documents exist.
--                    p_vendor_id          Vendor ID
--
-- DESIGN DOC       : SUPPUR_CONSSUP_DLD.doc
--
-- HISTORY          : 11-12-02 vma    Created
--                    12-12-02 vma    The function Sup_Site_Owns_Tps in
--                                    INV_SUPPLIER_OWNED_STOCK_GRP
--                                    has been moved to
--                                    PO_INV_THIRD_PARTY_STOCK_MDTR.
--                                    Modify call accordingly.
--                                    Added standard API parameters to
--                                    comply with PL/SQL API coding standard.
--===========================================================================
PROCEDURE Validate_Supplier_Merge
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2
, p_commit           IN  VARCHAR2
, p_validation_level IN  NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_vendor_site_id   IN  NUMBER
, p_vendor_id        IN  NUMBER
, x_can_merge        OUT NOCOPY VARCHAR2
, x_validation_error OUT NOCOPY VARCHAR2
);

--=============================================================================
-- API NAME      : Get_Asl_Attributes
-- TYPE          : PUBLIC
-- PRE-CONDITION : The inventory_item_id, vendor_id, vendor_site_id and
--                 using organization_id passed in should be not NULL, or else
--                 all the out parameters will have NULL values
-- DESCRIPTION   : This procedure returns the Consigned from Supplier
--                 and VMI setting of the ASL entry that corresponds to
--                 the passed in item/supplier/supplier site/organization
--		           combination, as OUT parameters.
-- PARAMETERS    :
--   p_api_version                  REQUIRED. API version
--   p_init_msg_list                REQUIRED. FND_API.G_TRUE to reset the
--                                            message list.
--                                            NULL value is regarded as
--                                            FND_API.G_FALSE.
--   x_return_status                REQUIRED. Value can be
--                                            FND_API.G_RET_STS_SUCCESS
--                                            FND_API.G_RET_STS_ERROR
--                                            FND_API.G_RET_STS_UNEXP_ERROR
--   x_msg_count                    REQUIRED. Number of messages on the message
--                                            list
--   x_msg_data                     REQUIRED. Return message data if message
--                                            count is 1
--   p_inventory_item_id            REQUIRED. Item identifier.
--   p_vendor_id                    REQUIRED. Supplier identifier.
--   p_vendor_site_id               REQUIRED. Supplier site identifier.
--   p_using_organization_id        REQUIRED. Identifier of the organization to
--                                            which the shipments are delivered
--                                            to.
--   x_consigned_from_supplier_flag REQUIRED. Consigned setting of the ASL
--   x_enable_vmi_flag              REQUIRED. VMI setting of the ASL
--   x_last_billing_date            REQUIRED. Last date when the consigned
--                                            consumption concurrent program
--                                            ran
--   x_consigned_billing_cycle      REQUIRED. The number of days before
--                                            summarizing the consigned POs
--  		                                  received and transfer the
--			                                  goods to regular stock
-- EXCEPTIONS    :
--
--=============================================================================
PROCEDURE Get_Asl_Attributes
( p_api_version                  IN  NUMBER
, p_init_msg_list                IN  VARCHAR2
, x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2
, p_inventory_item_id            IN  NUMBER
, p_vendor_id                    IN  NUMBER
, p_vendor_site_id               IN  NUMBER
, p_using_organization_id        IN  NUMBER
, x_consigned_from_supplier_flag OUT NOCOPY VARCHAR2
, x_enable_vmi_flag              OUT NOCOPY VARCHAR2
, x_last_billing_date            OUT NOCOPY DATE
, x_consigned_billing_cycle      OUT NOCOPY NUMBER);

--=============================================================================
-- API NAME      : Get_Item_Inv_Asset_Flag
-- TYPE          : PUBLIC
-- PRE-CONDITION : Item must exist, or else the NO_DATA_FOUND exception
--                 would be thrown and the out parameter
--                 x_inventory_asset_flag would be set to NULL.
-- DESCRIPTION   : Get the INVENTORY_ASSET_FLAG for a particular item.  This
--                 procedure is typically for determining whether an item is
--                 expense or not.
-- PARAMETERS    :
--   p_api_version           REQUIRED. API version
--   p_init_msg_list         REQUIRED. FND_API.G_TRUE to reset the message
--                                     list.
--                                     NULL value is regarded as
--                                     FND_API.G_FALSE.
--   x_return_status         REQUIRED. Value can be
--                                     FND_API.G_RET_STS_SUCCESS
--                                     FND_API.G_RET_STS_ERROR
--                                     FND_API.G_RET_STS_UNEXP_ERROR
--   x_msg_count             REQUIRED. Number of messages on the message list
--   x_msg_data              REQUIRED. Return message data if message count
--                                     is 1
--   p_organization_id       REQUIRED. Identifier of the organization to
--                                     which the item was assigned to
--   p_inventory_item_id     REQUIRED. Item identifier.
--   x_inventory_asset_flag  REQUIRED. Inventory Asset Flag of the specified
--                                     item.
-- EXCEPTIONS    :
--
--=============================================================================
PROCEDURE Get_Item_Inv_Asset_Flag
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, x_inventory_asset_flag OUT NOCOPY VARCHAR2
);

--=============================================================================
-- API NAME      : Consigned_Status_Affected
-- TYPE          : PUBLIC
-- PRE-CONDITION : None
-- DESCRIPTION   : Returns 'Y' to the out parameter x_consigned_status_affected
--                 if the passed in vendor and vendor site would lead to changes
--                 of the the consigned status on any child shipments that
--                 belong to the PO specified by the passed in PO_HEADER_ID
-- PARAMETERS    :
--   p_api_version               REQUIRED. API version
--   p_init_msg_list             REQUIRED. FND_API.G_TRUE to reset the
--                                         message list.
--                                         NULL value is regarded as
--                                         FND_API.G_FALSE.
--   x_return_status             REQUIRED. Value can be
--                                         FND_API.G_RET_STS_SUCCESS
--                                         FND_API.G_RET_STS_ERROR
--                                         FND_API.G_RET_STS_UNEXP_ERROR
--   x_msg_count                 REQUIRED. Number of messages on the message
--                                         list
--   x_msg_data                  REQUIRED. Return message data if message
--                                         count is 1
--   p_vendor_id                 REQUIRED. Supplier identifier.
--   p_vendor_site_id            REQUIRED. Supplier Site identifier.
--   p_po_header_id              REQUIRED. Header identifier of the PO to be
--                                         validated
--   x_consigned_status_affected REQUIRED. Y if any of the shipment lines
--                                         would change in the consigned
--                                         status if adopting the passed in
--                                         vendor and vendor site. N otherwise.
-- EXCEPTIONS    :
--
--=============================================================================
PROCEDURE consigned_status_affected
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
, p_vendor_id                 IN NUMBER
, p_vendor_site_id            IN NUMBER
, p_po_header_id              IN NUMBER
, x_consigned_status_affected OUT NOCOPY VARCHAR2
);

-- <ACHTML R12 START>
FUNCTION get_consigned_flag(
  p_org_id IN NUMBER,
  p_item_id IN NUMBER,
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER,
  p_inv_org_id IN NUMBER --Bug 5976612 Added this new parameter.
) RETURN VARCHAR2;
-- <ACHTML R12 END>

PROCEDURE IS_ASL_CONSIGNED_FROM_SUPPLIER(p_use_ship_to_org_ids          IN PO_TBL_NUMBER,
                                         p_item_id                      IN NUMBER,
                                         p_vendor_id                    IN NUMBER,
                                         p_vendor_site_id               IN NUMBER,
                                         x_consigned_from_supplier_flag OUT NOCOPY VARCHAR2);

END PO_THIRD_PARTY_STOCK_GRP;

/
