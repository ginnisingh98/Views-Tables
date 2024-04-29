--------------------------------------------------------
--  DDL for Package Body PO_THIRD_PARTY_STOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_THIRD_PARTY_STOCK_GRP" as
--$Header: POXGTPSB.pls 120.7.12010000.4 2014/07/03 06:44:29 shipwu ship $

--+===========================================================================+
--|                    Copyright (c) 2002, 2014 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            POXGTPSB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          This package is used to the VMI and consigned from |
--|                        supplier validation                                |
--|                                                                           |
--|  FUNCTION/PROCEDURE:   validate_local_asl                                 |
--|                        validate_global_asl                                |
--|                        exist_tps_asl                                      |
--|                        get_asl_attributes                                 |
--|                        validate_supplier_purge                            |
--|                        validate_supplier_merge                            |
--|                        is_expense_item                                    |
--|                        consigned_status_affected                          |
--|                                                                           |
--|                                                                           |
--|  HISTORY:              Created : 18-SEP-2002 : fdubois                    |
--|                        Modified: 22-SEP-2002 : fdubois                    |
--|                                  added exist_tps_asl                      |
--+===========================================================================+

--=============================================
-- CONSTANTS
--=============================================
G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'po.plsql.' || G_PKG_NAME || '.';

--=============================================
-- GLOBAL VARIABLES
--=============================================
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
-- <ACHTML R12 START>
D_PACKAGE_BASE CONSTANT VARCHAR2(50) := PO_LOG.get_package_base('PO_THIRD_PARTY_STOCK_GRP');

D_get_consigned_flag CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_consigned_flag');
-- <ACHTML R12 END>

--==========================================================================
--  FUNCTION NAME:  Validate_Local_Asl
--
--  DESCRIPTION:    the function returns TRUE if the Local ASL can be
--                  VMI or Consigned from Supplier for the IN parameters
--                  (define the ASL and the validation type). False
--                  otherwise. It then also returns the Validation Error
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
--                  16-Jan-03 VMA       Bug #2660359: Added validation for
--                                      automatic PO/REQ numbering for
--                                      Consigned/VMI.
--                  21-Jan-03 VMA       Bug #2723366: Added validation for
--                                      non-transactable or non-stockable
--                                      item.
--                  28-Jan-03 VMA       Bug #2660359: Removed validation for
--                                      automatic numbering for Consigned/VMI
--                                      due to a change in functional
--                                      requirement.
--                  21-Mar-03 VMA       Bug #2862335: Added validation for AX.
--                  03-Apr-03 VMA       Bug #2885607: Added check for AX
--                                      profile option
--                  10-Feb-04 VMA       Bug #3170458: Added return value in
--                                      exception handling block
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
RETURN BOOLEAN IS

l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Local_ASL';
l_api_version       CONSTANT NUMBER := 1.0;
l_inv_app_id        CONSTANT NUMBER := 401;

l_purch_flag        FINANCIALS_SYSTEM_PARAMS_ALL.PURCH_ENCUMBRANCE_FLAG%TYPE;
l_req_flag          FINANCIALS_SYSTEM_PARAMS_ALL.REQ_ENCUMBRANCE_FLAG%TYPE;
l_sob_id            FINANCIALS_SYSTEM_PARAMS_ALL.SET_OF_BOOKS_ID%TYPE;
l_whse_code         IC_WHSE_MST.WHSE_CODE%TYPE;
l_OSP_flag          MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_FLAG%TYPE;
l_bom               MTL_SYSTEM_ITEMS.BOM_ITEM_TYPE%TYPE;
l_replenish         MTL_SYSTEM_ITEMS.REPLENISH_TO_ORDER_FLAG%TYPE;
l_autoconfig        MTL_SYSTEM_ITEMS.AUTO_CREATED_CONFIG_FLAG%TYPE;
l_base              MTL_SYSTEM_ITEMS.BASE_ITEM_ID%TYPE;
l_eam               MTL_SYSTEM_ITEMS.EAM_ITEM_TYPE%TYPE;
l_asset             MTL_SYSTEM_ITEMS.INVENTORY_ASSET_FLAG%TYPE;
l_transactable      MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG%TYPE;
l_stockable         MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG%TYPE;
l_po_num_code       PO_SYSTEM_PARAMETERS.USER_DEFINED_PO_NUM_CODE%TYPE;
l_req_num_code      PO_SYSTEM_PARAMETERS.USER_DEFINED_REQ_NUM_CODE%TYPE;


e_fail_validation   EXCEPTION;

BEGIN

  IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                   , G_MODULE_PREFIX || l_api_name || '.invoked'
                   , 'Entry');
    END IF;
  END IF;

  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- First Validate the Encumbrance for the local ASL
  -- get the encumbrance flags for the OU linked to the vendor site id
  --
  -- Bug #2682335: Also retrieve the Set of Books ID for AX validation.
  --
  SELECT  fspa.purch_encumbrance_flag,
          fspa.req_encumbrance_flag,
          fspa.set_of_books_id
  INTO    l_purch_flag ,
          l_req_flag ,
          l_sob_id
  FROM    FINANCIALS_SYSTEM_PARAMS_ALL fspa ,
          po_vendor_sites_all pvs
  WHERE   pvs.vendor_site_id = p_supplier_site_id
  AND     NVL(fspa.org_id,-99) = NVL(pvs.org_id,-99) ;

  -- *** ENCUMBRANCE ACCOUNTING VALIDATION ***
  -- First check for the encumbrance
  IF l_purch_flag = 'Y' OR l_req_flag = 'Y'
  THEN
    -- Set the Validation error message
    IF p_validation_type = 'VMI' THEN
      x_validation_error_name := 'PO_VMI_ENCUMBRANCE_ENABLED' ;
    ELSIF p_validation_type = 'SUP_CONS' THEN
      x_validation_error_name := 'PO_SUP_CONS_ENCUMBRANCE' ;
    END IF ;
    -- Fail validation
    RAISE e_fail_validation;
  END IF ;


  --- *** Bug 2862335: AX Validation for Consign ASL   ***
  --- *** Bug 2885607: Add check for AX profile option ***
  --- Consign is not allowed if AX's support for Consign is not installed
  --- and the operating unit uses AX for inventory
/*Bug#4340538 Commented the below piece of code since the AX packages are obsoleted
  IF p_validation_type = 'SUP_CONS' THEN
    IF NVL(FND_PROFILE.value('AX_SUPPLIER_CONSIGNED_ENABLED'), 'N') = 'N'
       AND AX_SETUP_PKG.ax_exists(p_sob_id  => l_sob_id,
                                  p_appl_id => l_inv_app_id)
    THEN
      x_validation_error_name := 'PO_SUP_CONS_AX';
      RAISE e_fail_validation;
    END IF;
  END IF;
*/
  -- get the needed info to the VMI and Consigned from supplier
  -- local ASL validation

  SELECT  -- INVCONV imst.whse_code      OPM Org code
          msi.outside_operation_flag      , -- OSP flag
          msi.bom_item_type               ,
          msi.replenish_to_order_flag     ,
          msi.auto_created_config_flag    ,
          msi.base_item_id                ,
          msi.eam_item_type               ,
          msi.inventory_asset_flag        ,
          NVL(msi.mtl_transactions_enabled_flag, 'N'),
          NVL(msi.stock_enabled_flag, 'N')
  INTO    -- INVCONV l_whse_code
          l_OSP_flag  ,
          l_bom       ,
          l_replenish ,
          l_autoconfig,
          l_base      ,
          l_eam       ,
          l_asset     ,
          l_transactable,
          l_stockable
  FROM    MTL_SYSTEM_ITEMS msi
          -- INVCONV IC_WHSE_MST imst
  WHERE   -- INVCONV msi.organization_id       =  imst.mtl_organization_id (+)
          msi.inventory_item_id     =  p_inventory_item_id
  AND     msi.organization_id       =  p_inventory_org_id ;

  -- *** OPM ITEM validation
  -- INVCONV
/*  IF l_whse_code IS NOT NULL THEN
    -- Set the Validation error message
    IF p_validation_type = 'VMI' THEN
      x_validation_error_name := 'PO_VMI_OPM_ORG_LOCAL' ;
    ELSIF p_validation_type = 'SUP_CONS' THEN
      x_validation_error_name := 'PO_SUP_CONS_OPM_ORG_LOCAL' ;
    END IF ;
    RAISE e_fail_validation;
  END IF ; */
  -- End INVCONV

  -- *** OSP ITEM validation
  IF l_OSP_flag = 'Y' THEN
    -- Set the Validation error message
    IF p_validation_type = 'VMI' THEN
      x_validation_error_name := 'PO_VMI_OSP_ITEM' ;
    ELSIF p_validation_type = 'SUP_CONS' THEN
      x_validation_error_name := 'PO_SUP_CONS_OSP_ITEM' ;
    END IF ;
    RAISE e_fail_validation;
  END IF ;

  -- *** CTO ITEM VALIDATION ***
  -- check for CTO Item
  IF l_bom IN (1,2)
  OR ( l_replenish = 'Y' AND l_base IS NULL AND l_autoconfig = 'Y')
  THEN
    -- Set the Validation error message
    IF p_validation_type = 'VMI' THEN
      x_validation_error_name := 'PO_VMI_CTO_ITEM' ;
    ELSIF p_validation_type = 'SUP_CONS' THEN
      x_validation_error_name := 'PO_SUP_CONS_CTO_ITEM' ;
    END IF ;
    RAISE e_fail_validation;
  END IF ;

  -- *** EAM ITEM VALIDATION ***
  -- check for EAM Item
  IF l_eam IS NOT NULL THEN
    -- Set the Validation error message
    IF p_validation_type = 'VMI' THEN
      x_validation_error_name := 'PO_VMI_EAM_ITEM' ;
    ELSIF p_validation_type = 'SUP_CONS' THEN
      x_validation_error_name := 'PO_SUP_CONS_EAM_ITEM' ;
    END IF ;
    RAISE e_fail_validation;
  END IF ;

  -- *** Inventory Asset ITEM VALIDATION ***
  -- check for Inventory Item
  -- Bug 3582786 : moved the 'raise' inside the condition
  -- for consigned
  IF l_asset <> 'Y' THEN
    -- Set the Validation error message
    IF p_validation_type = 'SUP_CONS' THEN
      x_validation_error_name := 'PO_SUP_CONS_INV_ASSET_ITEM' ;
      RAISE e_fail_validation;
    END IF ;
  END IF ;

  -- *** TRANSACTABLE AND STOCKABLE ITEM VALIDATION ***
  -- check for non-transactable or non-stockable Item
  -- Bug 3582786 : extended the validation for VMI also
  IF (l_transactable = 'N' OR l_stockable = 'N') THEN
    -- Set the Validation error message
    IF p_validation_type = 'VMI' THEN
      x_validation_error_name := 'PO_VMI_NON_TRX_STOCK_ITEM';
    ELSIF p_validation_type = 'SUP_CONS' THEN
      x_validation_error_name := 'PO_SUP_CONS_NON_TRX_STOCK_ITEM';
    END IF ;
    RAISE e_fail_validation;
  END IF;

  -- Pass validation if e_fail_validation has not been raised
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data);
  IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
    END IF;
  END IF;
  RETURN TRUE;

EXCEPTION
  WHEN e_fail_validation THEN
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data);
    IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name || '.invoked'
                    , 'Exit');
      END IF;
    END IF;
    RETURN FALSE ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_validation_error_name := 'PO_SUP_CONS_UNEXPECTED_ERROR';
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.String( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_error'
                    , 'Incompatible API version');
      END IF;
    END IF;
    RETURN FALSE;

  WHEN OTHERS THEN
    x_validation_error_name := 'PO_SUP_CONS_UNEXPECTED_ERROR';
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
      END IF;
    END IF;
    RETURN FALSE;

END validate_local_asl ;

--===========================================================================
--  FUNCTION NAME:  Validate_Global_Asl
--
--  DESCRIPTION:    the function returns TRUE if the Global ASL can be
--                  VMI or Consigned from supplier for the IN parameters
--                  (define the ASL). False otherwise. It then also
--                  returns the Validation Error Message name
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
--                  15-Jan-03 VMA       Bug #2677786: Add standard API
--                                      parameters to comply with PL/SQL
--                                      API standard.
--                  16-Jan-03 VMA       Bug #2660359: Added validation for
--                                      automatic PO/REQ numbering for
--                                      Consigned/VMI.
--                  21-Jan-03 VMA       Bug #2723366: Added validation for
--                                      non-transactable or non-stockable
--                                      item.
--                  28-Jan-03 VMA       Bug #2660359: Removed validation for
--                                      automatic numbering for Consigned/VMI
--                                      due to a change in functional
--                                      requirement.
--                  21-Mar-03 VMA       Bug #2862335: Added validation for AX
--                  03-Apr-03 VMA       Bug #2885607: Added check for AX
--                                      profile option
--                  10-Feb-04 VMA       Bug #3170458: Added return value in
--                                      exception handling block
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
, p_inventory_org_id        IN  NUMBER default -1 --Bug 18998399
, p_validation_type         IN  VARCHAR2
, x_validation_error_name   OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN IS

l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Global_ASL';
l_api_version       CONSTANT NUMBER := 1.0;
l_inv_app_id        CONSTANT NUMBER := 401;

l_purch_flag        FINANCIALS_SYSTEM_PARAMS_ALL.PURCH_ENCUMBRANCE_FLAG%TYPE;
l_req_flag          FINANCIALS_SYSTEM_PARAMS_ALL.REQ_ENCUMBRANCE_FLAG%TYPE;
l_sob_id            FINANCIALS_SYSTEM_PARAMS_ALL.SET_OF_BOOKS_ID%TYPE;
l_po_num_code       PO_SYSTEM_PARAMETERS.USER_DEFINED_PO_NUM_CODE%TYPE;
l_req_num_code      PO_SYSTEM_PARAMETERS.USER_DEFINED_REQ_NUM_CODE%TYPE;

e_fail_validation   EXCEPTION;

--Bug 18998399 Start
l_local_transactable      MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG%TYPE;
l_local_stockable         MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG%TYPE;
--Bug 18998399 End

-- This cursor brings the info needed to validate the Global ASL
-- For INV and consign from supplier.
-- It brings back the Item/Inventory Org Info for all inventory Org
-- / Item linked to the SOB that is associated with the supplier site
-- Operating Unit
cursor c_valid_global_asl (p_inventory_item_id      NUMBER ,
                           p_supplier_site_id       NUMBER ) is
select hoi.organization_id ,
       DECODE(HOI.ORG_INFORMATION_CONTEXT, 'Accounting Information',
       TO_NUMBER(HOI.ORG_INFORMATION3), TO_NUMBER(NULL)) operating_unit ,
       -- INVCONV imst.whse_code ,
       msi.item_type ,
       msi.outside_operation_flag ,
       msi.eam_item_type ,
       msi.base_item_id ,
       msi.bom_item_type ,
       msi.replenish_to_order_flag ,
       msi.auto_created_config_flag ,
       msi.inventory_asset_flag ,
       msi.mtl_transactions_enabled_flag ,
       msi.stock_enabled_flag
from   gl_sets_of_books gsob ,
       hr_organization_units hou ,
       hr_organization_information hoi ,
       mtl_parameters mp ,
       hr_organization_information hoi2 ,
       mtl_system_items msi
       -- INVCONV ic_whse_mst imst
where  HOU.ORGANIZATION_ID = HOI.ORGANIZATION_ID
and    HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
and    HOI.ORG_INFORMATION_CONTEXT||'' ='Accounting Information'
and    HOI.ORG_INFORMATION1 = TO_CHAR(GSOB.SET_OF_BOOKS_ID)
and    hoi.organization_id = hoi2.organization_id
and    hoi2.org_information_context = 'CLASS'
and    hoi2.org_information1 = 'INV'
and    msi.organization_id = hoi.organization_id
and    msi.inventory_item_id = p_inventory_item_id
and    SYSDATE between Nvl(hou.DATE_FROM, SYSDATE-1) and Nvl(hou.DATE_TO, SYSDATE+1) --Bug 18294823
-- INVCONV and    hoi.organization_id = imst.mtl_organization_id (+)
and    GSOB.SET_OF_BOOKS_ID =  (
       select set_of_books_id
       from   po_vendor_sites_all pvsa ,
              financials_system_params_all fspa
       where  pvsa.vendor_site_id = p_supplier_site_id
       and    NVL(fspa.org_id,-99)= NVL(pvsa.org_id,-99)
       ) ;

BEGIN

  IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                   , G_MODULE_PREFIX || l_api_name || '.invoked'
                   , 'Entry');
    END IF;
  END IF;

  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- First Validate the Encumbrance for the GLobal ASL
  -- get the encumbrance flags for the OU linked to the vendor site id
  --
  -- Bug #2682335: Also retrieve the Set of Books ID for AX validation.
  --
  SELECT  fspa.purch_encumbrance_flag,
          fspa.req_encumbrance_flag,
          fspa.set_of_books_id
  INTO    l_purch_flag ,
          l_req_flag ,
          l_sob_id
  FROM    FINANCIALS_SYSTEM_PARAMS_ALL fspa ,
          po_vendor_sites_all pvs
  WHERE   pvs.vendor_site_id = p_supplier_site_id
  AND     NVL(fspa.org_id,-99) = NVL(pvs.org_id,-99) ;

  -- *** ENCUMBRANCE ACCOUNTING VALIDATION ***
  -- First check for the encumbrance
  IF l_purch_flag = 'Y' OR l_req_flag = 'Y'
  THEN
    -- Set the Validation error message
    IF p_validation_type = 'VMI' THEN
      x_validation_error_name := 'PO_VMI_ENCUMBRANCE_ENABLED' ;
    ELSIF p_validation_type = 'SUP_CONS' THEN
      x_validation_error_name := 'PO_SUP_CONS_ENCUMBRANCE' ;
    END IF ;
    -- Fail validation
    RAISE e_fail_validation;
  END IF ;

  --- *** Bug 2862335: AX Validation for Consign ASL   ***
  --- *** Bug 2885607: Add check for AX profile option ***
  --- Consign is not allowed if AX's support for Consign is not installed
  --- and the operating unit uses AX for inventory
/*Bug#4340538 Commented the below piece of code since the AX packages are obsoleted

   IF p_validation_type = 'SUP_CONS' THEN
    IF NVL(FND_PROFILE.value('AX_SUPPLIER_CONSIGNED_ENABLED'), 'N') = 'N'
       AND AX_SETUP_PKG.ax_exists(p_sob_id  => l_sob_id,
                                  p_appl_id => l_inv_app_id)
    THEN
      x_validation_error_name := 'PO_SUP_CONS_AX';
      RAISE e_fail_validation;
    END IF;
  END IF;
*/

    --Bug 18998399 Start: Get the values of mtl_transactions_enabled_flag and
	--stock_enabled_flag of the current inv org.
    IF p_inventory_org_id <> -1 THEN
      SELECT NVL(msi.mtl_transactions_enabled_flag, 'N'),
          NVL(msi.stock_enabled_flag, 'N')
      INTO    l_local_transactable,
              l_local_stockable
      FROM    MTL_SYSTEM_ITEMS msi
      WHERE   msi.inventory_item_id     =  p_inventory_item_id
      AND     msi.organization_id       =  p_inventory_org_id ;
	  ELSE
	    l_local_transactable := 'N';
		  l_local_stockable := 'N';
	  END IF;
    --Bug 18998399 End

  -- Fetch the cursor into the record and loop
  FOR c_valid_global_asl_rec IN
  c_valid_global_asl(p_inventory_item_id, p_supplier_site_id)
  LOOP

    -- INVCONV
    -- *** OPM ITEM VALIDATION ***
    -- First check for OPM Item
/*    IF c_valid_global_asl_rec.whse_code IS NOT NULL
    THEN
      -- Set the Validation error message
      IF p_validation_type = 'VMI' THEN
        x_validation_error_name := 'PO_VMI_OPM_ORG_GLOBAL' ;
        exit;         -- exit the loop
      ELSIF p_validation_type = 'SUP_CONS' THEN
        x_validation_error_name := 'PO_SUP_CONS_OPM_ORG_GLOBAL' ;
        exit;         -- exit the loop
      END IF;
    END IF; */
-- End INVCONV

    -- *** OSP ITEM VALIDATION ***
    -- First check for OSP Item
    IF c_valid_global_asl_rec.outside_operation_flag = 'Y'
    THEN
      IF p_validation_type = 'VMI' THEN
        x_validation_error_name := 'PO_VMI_OSP_ITEM' ;
        exit;         -- exit the loop
      ELSIF p_validation_type = 'SUP_CONS' THEN
        x_validation_error_name := 'PO_SUP_CONS_OSP_ITEM' ;
        exit ;        -- exit the loop
      END IF ;
    END IF ;

    -- *** CTO ITEM VALIDATION ***
    -- First check for CTO Item
    IF c_valid_global_asl_rec.bom_item_type IN (1,2)
    OR ( c_valid_global_asl_rec.replenish_to_order_flag = 'Y' AND
         c_valid_global_asl_rec.base_item_id IS NULL AND
         c_valid_global_asl_rec.auto_created_config_flag = 'Y')
    THEN
      -- Set the Validation error message
      IF p_validation_type = 'VMI' THEN
        x_validation_error_name := 'PO_VMI_CTO_ITEM' ;
        exit ;        -- exit the loop
      ELSIF p_validation_type = 'SUP_CONS' THEN
        x_validation_error_name := 'PO_SUP_CONS_CTO_ITEM' ;
        exit ;        -- exit the loop
      END IF ;
    END IF ;

    -- *** EAM ITEM VALIDATION ***
    -- First check for EAM Item
    IF c_valid_global_asl_rec.eam_item_type IS NOT NULL
    THEN
      -- Set the Validation error message
      IF p_validation_type = 'VMI' THEN
        x_validation_error_name := 'PO_VMI_EAM_ITEM' ;
        exit ;        -- exit the loop
      ELSIF p_validation_type = 'SUP_CONS' THEN
        x_validation_error_name := 'PO_SUP_CONS_EAM_ITEM' ;
        exit ;        -- exit the loop
      END IF ;
    END IF ;

    -- *** Inventory Asset ITEM VALIDATION ***
    -- check for Inventory Item
    IF c_valid_global_asl_rec.inventory_asset_flag <> 'Y' THEN
      -- Set the Validation error message
      IF p_validation_type = 'SUP_CONS' THEN
        x_validation_error_name := 'PO_SUP_CONS_INV_ASSET_ITEM' ;
        exit ;        -- exit the loop
      END IF ;
    END IF ;

    -- *** TRANSACTABLE AND STOCKABLE ITEM VALIDATION ***
    -- check for non-transactable or non-stockable Item
    -- Bug 3582786 : extended the validation for VMI also
    --Bug 18998399 Start: Get the values of mtl_transactions_enabled_flag and
	--stock_enabled_flag of the current inv org.
    IF (NVL(c_valid_global_asl_rec.mtl_transactions_enabled_flag, 'N') = 'N'
       OR NVL(c_valid_global_asl_rec.stock_enabled_flag, 'N') = 'N')
    THEN
      IF p_validation_type = 'VMI' THEN
        IF (l_local_transactable = 'N' OR l_local_stockable = 'N') THEN
            x_validation_error_name := 'PO_VMI_NON_TRX_STOCK_ITEM';
			exit;
		END IF;
      ELSIF p_validation_type = 'SUP_CONS' THEN
        x_validation_error_name := 'PO_SUP_CONS_NON_TRX_STOCK_ITEM';
        exit;
      END IF ;
    END IF;
    --Bug 18998399 End

  END LOOP ;


  -- Test if one record failed the validation
  IF x_validation_error_name IS NOT NULL
  THEN
    RAISE e_fail_validation;
  END IF;


  -- Pass validation if e_fail_validation has not been raised
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data);
  IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
    END IF;
  END IF;
  RETURN TRUE ;

EXCEPTION
  WHEN e_fail_validation THEN
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data);
    IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_api_name || '.invoked'
                    , 'Exit');
      END IF;
    END IF;
    RETURN FALSE ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_validation_error_name := 'PO_SUP_CONS_UNEXPECTED_ERROR';
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.String( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_error'
                    , 'Incompatible API version');
      END IF;
    END IF;
    RETURN FALSE;

  WHEN OTHERS THEN

    x_validation_error_name := 'PO_SUP_CONS_UNEXPECTED_ERROR';
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
      END IF;
    END IF;
    RETURN FALSE;

END validate_global_asl ;

--===========================================================================
--  FUNCTION NAME:	Exist_TPS_ASL
--
--  DESCRIPTION:  the function returns TRUE if there exist a
--                VMI/Consined ASL within the Operating Unit.
--                If there is none it returns FALSE.
--
--  PARAMETERS:
--           Return: TRUE if exists VMI/Consigned ASL
--
--  DESIGN REFERENCES:	APXSSFSO_CONSSUP_DLD.doc
--
--  CHANGE HISTORY:	26-Sep-02	FDUBOIS   Created.
--                  14-OCT-02 FDUBOIS   Added logic for the function
--===========================================================================
FUNCTION Exist_TPS_ASL RETURN BOOLEAN IS

l_exist_TPS_ASL         BOOLEAN ;
l_count_exist_TPS_ASL   NUMBER  ;

BEGIN
  -- Returns 1 if there exist a VMI or consign ASL within the current OU
  SELECT count('x')
  INTO   l_count_exist_TPS_ASL
  FROM   dual
  WHERE  exists
  (  SELECT 'X'
     FROM   po_approved_supplier_list  pasl,
            po_vendor_sites pvs ,
            po_asl_status_rules_v pasr ,
            po_asl_attributes paa
     WHERE  pasl.vendor_site_id = pvs.vendor_site_id
     AND    pasr.status_id = pasl.asl_status_id
     AND    pasr.business_rule like '2_SOURCING'
     AND    pasr.allow_action_flag like 'Y'
     AND   (  pasl.disable_flag = 'N'
           OR pasl.disable_flag IS NULL)
     AND   paa.asl_id = pasl.asl_id
     AND   (  paa.enable_vmi_flag =  'Y'
           OR paa.consigned_from_supplier_flag = 'Y')
   ) ;

  -- Assign the boolean value depending on the return count
  IF l_count_exist_TPS_ASL = 1 THEN
    l_exist_TPS_ASL := TRUE ;
  ELSE
    l_exist_TPS_ASL := FALSE ;
  END IF ;

  RETURN l_exist_TPS_ASL;

END exist_tps_asl ;

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
FUNCTION Validate_Supplier_Purge(p_vendor_id IN NUMBER)
RETURN VARCHAR2 IS

l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Supplier_Purge';
l_return_value VARCHAR2(10);

-- <DOC PURGE FPJ START>
l_return_value_tmp VARCHAR2(10);
l_rtn_status   VARCHAR2(1);
l_msg_count    NUMBER;
l_msg_data     VARCHAR2(2000);
-- <DOC PURGE FPJ END>

BEGIN
  IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                   , G_MODULE_PREFIX || l_api_name || '.invoked'
                   , 'Entry');
    END IF;
  END IF;

  IF PO_INV_THIRD_PARTY_STOCK_MDTR.Supplier_Owns_Tps(p_vendor_id) THEN
    l_return_value := 'FALSE';
  ELSE
    l_return_value := 'TRUE';
  END IF;

  -- <DOC PURGE FPJ START>
  -- Integrate with Sourcing to make sure that vendor purge is allowed for
  -- this vendor

  IF (l_return_value = 'TRUE') THEN

      l_return_value_tmp :=
          PON_VENDOR_PURGE_GRP.validate_vendor_purge
          ( p_api_version => 1.0,
            p_init_msg_list => FND_API.G_TRUE,
            x_return_status => l_rtn_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data,
            p_vendor_id     => p_vendor_id
          );

      IF (l_return_value_tmp = 'N') THEN

          IF g_fnd_debug = 'Y' THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                     , G_MODULE_PREFIX || l_api_name || '.010'
                     , 'PON rejects vnd_id ' || p_vendor_id ||
                       'from purge list');
              END IF;
          END IF;

          l_return_value := 'FALSE';
      END IF;
  END IF;

  -- <DOC PURGE FPJ END>


  IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
    END IF;
  END IF;

  RETURN l_return_value;

END Validate_Supplier_Purge;

--===========================================================================
-- API NAME         : Validate_Supplier_Merge
-- TYPE             : Public
-- Pre-condition    : Supplier site exists. If the supplier site does not
--                    exist, x_can_merge will contain value FND_API.G_TRUE
-- DESCRIPTION      : Checks whether a supplier site cannot be
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
--                                    comply with PL/SQL coding standard.
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
)
IS
  l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Supplier_Merge';
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_open         Number;

BEGIN

  IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
    END IF;
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API Initialization

  x_can_merge := FND_API.G_TRUE;

  IF FND_PROFILE.value('PO_SUPPLIER_CONSIGNED_ENABLED') = 'Y' AND
     FND_PROFILE.value('INV_SUPPLIER_CONSIGNED_ENABLED') = 'Y'
  THEN

    -- Check for on hand Consigned and VMI stock
    IF PO_INV_THIRD_PARTY_STOCK_MDTR.Sup_Site_Owns_Tps(p_vendor_site_id) THEN
      x_can_merge := FND_API.G_FALSE;
      x_validation_error := 'PO_SUP_CONS_FAIL_MERGE_TPS';

    ELSE

      -- Check for open PO documents:
      --   1. Consumption advices (standard PO)
      --   2. Consumption advices (release)
      --   3. VMI release lines
      --   4. Consigned shipments
      SELECT COUNT('x')
        INTO l_open
        FROM dual
       WHERE EXISTS
            (SELECT 'x'
               FROM po_headers_all
              WHERE consigned_consumption_flag = 'Y'
                AND type_lookup_code = 'STANDARD'
                AND vendor_site_id = p_vendor_site_id
                AND vendor_id = p_vendor_id --bug 3649022
                AND NVL(closed_code, 'a') <> 'FINALLY CLOSED'
                AND NVL(cancel_flag, 'N') = 'N')
       OR    EXISTS
            (SELECT 'x'
               FROM po_releases_all por, po_headers_all poh
              WHERE por.consigned_consumption_flag = 'Y'
                AND poh.vendor_site_id = p_vendor_site_id
                AND poh.vendor_id = p_vendor_id --bug 3649022
                AND poh.po_header_id = por.po_header_id
                AND nvl(por.closed_code, 'a') <> 'FINALLY CLOSED'
                AND nvl(por.cancel_flag, 'N') = 'N')
       OR    EXISTS
            (SELECT 'x'
               FROM po_line_locations_all pol, po_releases_all por,
                    po_headers_all poh
              WHERE poh.vendor_site_id = p_vendor_site_id
                AND poh.vendor_id = p_vendor_id --bug 3649022
                AND por.po_header_id = poh.po_header_id
                AND pol.po_release_id = por.po_release_id
                AND pol.vmi_flag = 'Y'
                AND NVL(pol.closed_code, 'a') <> 'FINALLY CLOSED'
                AND NVL(pol.cancel_flag, 'N') = 'N')
       OR    EXISTS
            (SELECT 'x'
               FROM po_line_locations_all pol, po_headers_all poh
              WHERE poh.vendor_site_id = p_vendor_site_id
                AND poh.vendor_id = p_vendor_id --bug 3649022
                AND poh.po_header_id = pol.po_header_id
                AND pol.consigned_flag = 'Y'
                AND nvl(pol.closed_code, 'a') <> 'FINALLY CLOSED'
                AND nvl(pol.cancel_flag, 'N') = 'N');

      IF l_open = 1 THEN
        x_can_merge := FND_API.G_FALSE;
        x_validation_error := 'PO_SUP_CONS_FAIL_MERGE_DOC';
      END IF;

    END IF;
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
    END IF;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF g_fnd_debug = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
         FND_LOG.String( FND_LOG.LEVEL_UNEXPECTED
                     , G_MODULE_PREFIX || l_api_name || '.unexpected_error'
                     , 'Incompatible API version');
       END IF;
     END IF;

   WHEN OTHERS THEN
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF g_fnd_debug = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
         FND_LOG.String( FND_LOG.LEVEL_UNEXPECTED
                     , G_MODULE_PREFIX || l_api_name || '.others_exception'
                     , 'Exception');
       END IF;
     END IF;

END Validate_Supplier_Merge;

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
, x_consigned_billing_cycle      OUT NOCOPY NUMBER
)
IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Asl_Attributes';
l_api_version CONSTANT NUMBER       := 1.0;

l_asl_id                                           NUMBER := NULL;
l_vendor_product_num
  PO_APPROVED_SUPPLIER_LIS_VAL_V.PRIMARY_VENDOR_ITEM%TYPE := NULL;
l_purchasing_uom
  PO_ASL_ATTRIBUTES.PURCHASING_UNIT_OF_MEASURE%TYPE       := NULL;
l_using_organization_id                            NUMBER
                                       := p_using_organization_id;
l_vmi_min_qty                                      NUMBER := NULL;
l_vmi_max_qty                                      NUMBER := NULL;
l_vmi_auto_replenish_flag
  PO_ASL_ATTRIBUTES.ENABLE_VMI_AUTO_REPLENISH_FLAG%TYPE   := NULL;
l_vmi_replenishment_approval
  PO_ASL_ATTRIBUTES.VMI_REPLENISHMENT_APPROVAL%TYPE       := NULL;

BEGIN

  IF (g_fnd_debug = 'Y')
  THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
    END IF;
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  x_enable_vmi_flag := null;
  x_consigned_from_supplier_flag := null;
  x_last_billing_date := null;
  x_consigned_billing_cycle := null;

  IF(p_inventory_item_id is not null
     AND p_vendor_id is not null
     AND p_vendor_site_id is not null
     AND p_using_organization_id is not null)
  THEN
    PO_AUTOSOURCE_SV.get_asl_info
    ( x_item_id                      => p_inventory_item_id
    , x_vendor_id                    => p_vendor_id
    , x_vendor_site_id               => p_vendor_site_id
    , x_using_organization_id        => l_using_organization_id
    , x_asl_id                       => l_asl_id
    , x_vendor_product_num           => l_vendor_product_num
    , x_purchasing_uom               => l_purchasing_uom
    , x_consigned_from_supplier_flag => x_consigned_from_supplier_flag
    , x_enable_vmi_flag              => x_enable_vmi_flag
    , x_last_billing_date            => x_last_billing_date
    , x_consigned_billing_cycle      => x_consigned_billing_cycle
    , x_vmi_min_qty                  => l_vmi_min_qty
    , x_vmi_max_qty                  => l_vmi_max_qty
    , x_vmi_auto_replenish_flag      => l_vmi_auto_replenish_flag
    , x_vmi_replenishment_approval   => l_vmi_replenishment_approval
    );
  END IF;

  FND_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
    END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y')
    THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
      END IF;
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y')
    THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
      END IF;
    END IF;
END get_asl_attributes;

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
)
IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Item_Inv_Asset_Flag';
l_api_version CONSTANT NUMBER       := 1.0;

BEGIN

  IF (g_fnd_debug = 'Y')
  THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
    END IF;
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  SELECT NVL(inventory_asset_flag, 'N')
  INTO x_inventory_asset_flag
  FROM mtl_system_items_b
  WHERE inventory_item_id = p_inventory_item_id
  AND organization_id = p_organization_id;

  FND_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
    END IF;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_inventory_asset_flag := NULL;
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (g_fnd_debug = 'Y')
    THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.string(FND_LOG.LEVEL_ERROR
                    , G_MODULE_PREFIX || l_api_name || '.no_data_found'
                    , 'Exception');
      END IF;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y')
    THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
      END IF;
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y')
    THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
      END IF;
    END IF;

END Get_Item_Inv_Asset_Flag;

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
PROCEDURE Consigned_Status_Affected
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
, p_vendor_id                 IN NUMBER
, p_vendor_site_id            IN NUMBER
, p_po_header_id              IN NUMBER
, x_consigned_status_affected OUT NOCOPY VARCHAR2
)
IS
l_api_name    CONSTANT VARCHAR2(30) := 'Consigned_Status_Affected';
l_api_version CONSTANT NUMBER       := 1.0;

l_found                                     BOOLEAN   := FALSE;
l_line_location_id                          NUMBER    := NULL;
l_item_id                                   NUMBER    := NULL;
l_ship_to_organization_id                   NUMBER    := NULL;
l_consigned_flag
  PO_LINE_LOCATIONS.CONSIGNED_FLAG%TYPE               := NULL;
l_consigned_from_supplier_flag
  PO_ASL_ATTRIBUTES.CONSIGNED_FROM_SUPPLIER_FLAG%TYPE := NULL;
l_enable_vmi_flag
  PO_ASL_ATTRIBUTES.ENABLE_VMI_FLAG%TYPE              := NULL;
l_last_billing_date                         DATE      := NULL;
l_consigned_billing_cycle                   NUMBER    := NULL;

CURSOR C is
  SELECT DISTINCT   --pll.line_location_id, --Bug 14664015
                    pl.item_id,
                    pll.ship_to_organization_id,
	            pll.consigned_flag
  FROM              po_line_locations_all pll,
                    po_lines_all          pl
  WHERE             pll.po_header_id = p_po_header_id
  AND               pl.po_line_id = pll.po_line_id;

BEGIN

  IF (g_fnd_debug = 'Y')
  THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
    END IF;
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  x_consigned_status_affected := NULL;

  OPEN C;
  LOOP

    FETCH C into --l_line_location_id,--Bug 14664015
                 l_item_id,
 	             l_ship_to_organization_id,
	  	         l_consigned_flag;

    EXIT WHEN C%NOTFOUND OR x_consigned_status_affected = 'Y';

    po_third_party_stock_grp.get_asl_attributes
    ( p_api_version                  => 1.0
    , p_init_msg_list                => NULL
    , x_return_status                => x_return_status
    , x_msg_count                    => x_msg_count
    , x_msg_data                     => x_msg_data
    , p_inventory_item_id            => l_item_id
    , p_vendor_id                    => p_vendor_id
    , p_vendor_site_id               => p_vendor_site_id
    , p_using_organization_id        => l_ship_to_organization_id
    , x_consigned_from_supplier_flag => l_consigned_from_supplier_flag
    , x_enable_vmi_flag              => l_enable_vmi_flag
    , x_last_billing_date            => l_last_billing_date
    , x_consigned_billing_cycle      => l_consigned_billing_cycle
    );

    IF(NVL(l_consigned_from_supplier_flag, 'N') <> NVL(l_consigned_flag, 'N'))
    THEN
      x_consigned_status_affected := 'Y';
    ELSE
      x_consigned_status_affected := 'N';
    END IF;

  END LOOP;
  CLOSE C;

  FND_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
    END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y')
    THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
      END IF;
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y')
    THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
      END IF;
    END IF;

END Consigned_Status_Affected;

-- <ACHTML R12 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name:  get_consigned_flag
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Gets the consigned flag for the shipment based on the operating unit, item,
--  supplier, and site. If either the operating unit or item passed in is null,
--  the consigned flag returned is 'N'.
--Parameters:
--IN:
--p_org_id
--  The operating unit ID.
--p_item_id
--  The item ID.
--p_supplier_id
--  The supplier ID.
--p_site_id
--  The site ID.
--RETURNS:
--  The 'Y' or 'N' consigned flag for the shipment.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_consigned_flag(
  p_org_id IN NUMBER,
  p_item_id IN NUMBER,
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER,
  p_inv_org_id IN NUMBER --Bug 5976612 Added this new parameter.
) RETURN VARCHAR2
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_consigned_flag;
  d_position NUMBER := 0;

  l_consigned_flag         PO_ASL_ATTRIBUTES.consigned_from_supplier_flag%TYPE;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_asset_flag             MTL_SYSTEM_ITEMS_B.inventory_asset_flag%TYPE;
  l_enable_vmi_flag        PO_ASL_ATTRIBUTES.enable_vmi_flag%TYPE;
  l_last_billing_date      PO_ASL_ATTRIBUTES.last_billing_date%TYPE;
  l_cons_billing_cycle     PO_ASL_ATTRIBUTES.consigned_billing_cycle%TYPE;
  -- <BUG 4951605>
  l_inventory_org_id
    FINANCIALS_SYSTEM_PARAMS_ALL.inventory_organization_id%TYPE;

  e_invalid_asset_flag     EXCEPTION;
  e_invalid_consigned_flag EXCEPTION;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
    PO_LOG.proc_begin(d_mod,'p_item_id',p_item_id);
    PO_LOG.proc_begin(d_mod,'p_supplier_id',p_supplier_id);
    PO_LOG.proc_begin(d_mod,'p_site_id',p_site_id);
  END IF;

  -- When either item ID or org ID is null, don't call get_item_inv_asset_flag
  -- because it will error out. Instead, just set consigned flag to 'N' and
  -- return that value.
  IF (p_item_id IS NULL OR (p_org_id IS NULL AND p_inv_org_id IS NULL)) -- Bug 5976612 Added the 'p_inv_org_id' check
  THEN
    l_consigned_flag := 'N';

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_return(d_mod, l_consigned_flag);
    END IF;

    RETURN l_consigned_flag;
  END IF;

/* Bug 5976612
  1.) Check if p_org_id is NOT NULL, If YES, then run the below query to fetch the inv org id
      to get the inv asset flag
  2.) Check if p_inv_org_id is NOT NULL, if YES, then don't run the query. Take the value of p_inv_org_id into
      l_inventory_org_id
               */

  IF   p_inv_org_id IS NULL
  THEN

  -- <BUG 4951605 START>
  -- Get the inventory org ID corresponding to the purchasing org ID.
  SELECT inventory_organization_id
  INTO l_inventory_org_id
  FROM financials_system_params_all
  WHERE org_id = p_org_id;
  -- <BUG 4951605 END>

  ELSE
      l_inventory_org_id :=p_inv_org_id;
  END IF; --Bug 5976612 end




  PO_THIRD_PARTY_STOCK_GRP.get_item_inv_asset_flag(
    p_api_version => 1.0,
    p_init_msg_list => NULL,
    x_return_status => l_return_status, -- OUT
    x_msg_count => l_msg_count, -- OUT
    x_msg_data => l_msg_data, -- OUT
    p_organization_id => l_inventory_org_id, -- IN <BUG 4951605>
    p_inventory_item_id => p_item_id, -- IN
    x_inventory_asset_flag => l_asset_flag -- OUT
  );

  d_position := 10;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'asset flag is: ' || l_asset_flag || ' and l_return_status is: ' || l_return_status);
  END IF;

  d_position := 20;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    RAISE e_invalid_asset_flag;
  END IF;

  d_position := 30;

  -- Set the consigned setting on the ASL as 'N' if the item is an
  -- expense item
  IF (NVL(l_asset_flag, 'N') = 'N')
  THEN
    l_consigned_flag := 'N';

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_return(d_mod, l_consigned_flag);
    END IF;

    RETURN l_consigned_flag;
  END IF;

  d_position := 40;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'consigned flag before call to get_asl_attributes is: ' || l_consigned_flag);
  END IF;

  PO_THIRD_PARTY_STOCK_GRP.get_asl_attributes(
    p_api_version => 1.0,
    p_init_msg_list => NULL,
    x_return_status => l_return_status, -- OUT
    x_msg_count => l_msg_count, -- OUT
    x_msg_data => l_msg_data, -- OUT
    p_inventory_item_id => p_item_id, -- IN
    p_vendor_id => p_supplier_id, -- IN
    p_vendor_site_id => p_site_id, -- IN
    p_using_organization_id => l_inventory_org_id, -- IN <BUG 4951605>
    x_consigned_from_supplier_flag => l_consigned_flag, -- OUT
    x_enable_vmi_flag => l_enable_vmi_flag, -- OUT
    x_last_billing_date => l_last_billing_date, -- OUT
    x_consigned_billing_cycle => l_cons_billing_cycle -- OUT
  );

  d_position := 50;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'consigned flag after call to get_asl_attributes is: ' || l_consigned_flag || ' and l_return_status is: ' || l_return_status);
  END IF;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    RAISE e_invalid_consigned_flag;
  END IF;

  l_consigned_flag := NVL(l_consigned_flag, 'N');

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_mod, l_consigned_flag);
  END IF;

  RETURN l_consigned_flag;
EXCEPTION
  WHEN e_invalid_asset_flag THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in get_consigned_flag: e_invalid_asset_flag');
    END IF;

    RAISE;
  WHEN e_invalid_consigned_flag THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in get_consigned_flag: e_invalid_consigned_flag');
    END IF;

    RAISE;
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in get_consigned_flag');
    END IF;

    RAISE;
END get_consigned_flag;
-- <ACHTML R12 END>
--<bug#4939669 START>
-----------------------------------------------------------------------------
--Start of Comments
--Name: IS_ASL_CONSIGNED_FROM_SUPPLIER
--Pre-reqs:
--Modifies:
--Locks:
--Function:
--  Checks if any of the given destination organizations has an asl
--  for a given item with the consigned_from_supplier flag set to Y
--Parameters:
--IN:
--p_use_ship_to_org_ids
--  Table of destination organization_ids
--p_item_id
--  Inventory item id of the item whose ASL would be scanned in the list
--  of destination organizations
--p_vendor_id
--  VendorId for which we need to find the ASL
--p_vendor_site_id
--  Vendor Site Id for which we need to find the ASL
--OUT:
--x_consigned_from_supplier_flag
--  Holds Y or N depending on wether any Destination Org has the
-- consigned_from_supplier flag set to Y or not
--Notes:
--End of Comments
-----------------------------------------------------------------------------

PROCEDURE IS_ASL_CONSIGNED_FROM_SUPPLIER(p_use_ship_to_org_ids          IN PO_TBL_NUMBER,
                                         p_item_id                      IN NUMBER,
                                         p_vendor_id                    IN NUMBER,
                                         p_vendor_site_id               IN NUMBER,
                                         x_consigned_from_supplier_flag OUT NOCOPY VARCHAR2)IS
  l_return_status           varchar2(1) := NULL;
  l_msg_count               number := NULL;
  l_msg_data                varchar2(2000) := NULL;
  l_item_inv_asset_flag     mtl_system_items_b.inventory_asset_flag%TYPE := 'N';
  l_enable_vmi_flag         po_asl_attributes.enable_vmi_flag%TYPE := NULL;
  l_last_billing_date       date := NULL;
  l_consigned_billing_cycle number := NULL;
  l_module_name CONSTANT VARCHAR2(100) := 'IS_ASL_CONSIGNED_FROM_SUPPLIER';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base( D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
 BEGIN
   IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_item_id', p_item_id);
    PO_LOG.proc_begin(d_module_base, 'p_vendor_id', p_vendor_id);
    PO_LOG.proc_begin(d_module_base, 'p_vendor_site_id', p_vendor_site_id);
    IF(p_use_ship_to_org_ids <> null)THEN
        FOR i in 1..p_use_ship_to_org_ids.count LOOP
            PO_LOG.proc_begin(d_module_base, 'p_use_ship_to_org_ids('||i||')', p_use_ship_to_org_ids(i));
        END LOOP;
    END IF;
  END IF;
  d_progress :=10;
  FOR i in 1..p_use_ship_to_org_ids.count LOOP
    IF (p_use_ship_to_org_ids(i) IS NOT NULL AND p_item_id IS NOT NULL AND
      p_vendor_id is not null AND p_vendor_site_id is not null) THEN
     d_progress :=20;
     PO_THIRD_PARTY_STOCK_GRP.Get_Item_Inv_Asset_Flag(p_api_version          => 1.0,
                                                      p_init_msg_list        => NULL,
                                                      x_return_status        => l_return_status,
                                                      x_msg_count            => l_msg_count,
                                                      x_msg_data             => l_msg_data,
                                                      p_organization_id      => p_use_ship_to_org_ids(i),
                                                      p_inventory_item_id    => p_item_id,
                                                      x_inventory_asset_flag => l_item_inv_asset_flag);
     IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,d_progress,'l_item_inv_asset_flag('||i||')= '||l_item_inv_asset_flag);
       PO_LOG.stmt(d_module_base,d_progress,'x_return_status('||i||')= '||l_return_status);
     END IF;
   END IF;
   -- if the item is not an expense item
   d_progress :=20;
   IF (l_item_inv_asset_flag = 'Y') THEN
     PO_THIRD_PARTY_STOCK_GRP.get_asl_attributes(p_api_version                  => 1.0,
                                                 p_init_msg_list                => NULL,
                                                 x_return_status                => l_return_status,
                                                 x_msg_count                    => l_msg_count,
                                                 x_msg_data                     => l_msg_data,
                                                 p_inventory_item_id            => p_item_id,
                                                 p_vendor_id                    => p_vendor_id,
                                                 p_vendor_site_id               => p_vendor_site_id,
                                                 p_using_organization_id        => p_use_ship_to_org_ids(i),
                                                 x_consigned_from_supplier_flag => x_consigned_from_supplier_flag,
                                                 x_enable_vmi_flag              => l_enable_vmi_flag,
                                                 x_last_billing_date            => l_last_billing_date,
                                                 x_consigned_billing_cycle      => l_consigned_billing_cycle);
     IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,d_progress,'x_consigned_from_supplier_flag=('||i||')= '||x_consigned_from_supplier_flag);
     END IF;

    IF(x_consigned_from_supplier_flag='Y')THEN
        RETURN;
    END IF;

   END IF;
  END LOOP;

  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
       PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
    END IF;
    RAISE;
END;
--<bug#4939669 END>
END PO_THIRD_PARTY_STOCK_GRP;

/
