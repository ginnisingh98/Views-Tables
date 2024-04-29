--------------------------------------------------------
--  DDL for Package Body INV_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_PVT" AS
/* $Header: INVVITMB.pls 120.33.12010000.16 2011/03/08 14:09:55 ccsingh ship $ */
G_PKG_NAME       CONSTANT   VARCHAR2(30)  :=  'INV_ITEM_PVT';

-- =============================================================================
--                   Package variables, constants and cursors
-- =============================================================================

/*
-- Pre-defined validation levels
--
G_VALID_LEVEL_NONE      CONSTANT   NUMBER  :=  0;
G_VALID_LEVEL_FULL      CONSTANT   NUMBER  :=  100;

-- Return codes
--
G_RET_STS_SUCCESS       CONSTANT   VARCHAR2(1)  :=  'S';
G_RET_STS_ERROR         CONSTANT   VARCHAR2(1)  :=  'E';
G_RET_STS_UNEXP_ERROR   CONSTANT   VARCHAR2(1)  :=  'U';

-- Error exceptions
--
G_EXC_ERROR                EXCEPTION;
G_EXC_UNEXPECTED_ERROR     EXCEPTION;
*/

SUBTYPE Attribute_Code_type  IS mtl_item_attributes.attribute_name%TYPE;  -- VARCHAR2(50)

TYPE Attribute_Code_tbl_type IS TABLE OF Attribute_Code_type
                                INDEX BY BINARY_INTEGER;

g_Master_Attribute_tbl      Attribute_Code_tbl_type;
g_Master_Org_ID             NUMBER;
g_Org_ID                    NUMBER;
G_IS_MASTER_ATTR_MODIFIED     VARCHAR2(1) := 'N';
/*Bug 6407303 Adding a new parameter to check for the master attribute */

------------------------- Get_Master_Org_ID ----------------------------------
FUNCTION Get_Master_Org_ID(p_Org_ID  IN   NUMBER) RETURN  NUMBER IS
BEGIN

   IF ((g_Master_Org_ID IS NULL ) OR NOT(g_Org_ID = p_Org_ID)) THEN
      g_Org_ID := p_Org_ID;
      SELECT  master_organization_id
      INTO  g_Master_Org_ID
      FROM  mtl_parameters
      WHERE  organization_id = p_Org_ID;
   END IF;
   RETURN ( g_Master_Org_ID );

END Get_Master_Org_ID;

/*-------------------------- Get_Master_Attributes ---------------------------*/

-- =============================================================================
--  Procedure:		Get_Master_Attributes
--
--  Description:
--    Store master-controlled attribute codes into a package pl/sql table.
-- =============================================================================

PROCEDURE Get_Master_Attributes
(
   x_return_status    OUT   NOCOPY VARCHAR2
)
IS
   l_api_name     CONSTANT  VARCHAR2(30)  :=  'Get_Master_Attributes';

   --------------------------------------------------------
   -- Fetch master-controlled attributes which values need
   -- to be propagated to org items.
   --------------------------------------------------------

   CURSOR Master_Attribute_csr
   IS
     SELECT  SUBSTR(attribute_name, 18)  Attribute_Code
     FROM  mtl_item_attributes
     WHERE  control_level = 1
       AND  attribute_group_id_gui IN
            (20, 25, 30, 31, 35, 40, 41, 51,
             60, 62, 65, 70, 80, 90, 100, 120 /* Start Bug 3713912 */,130/* End Bug 3713912 */);

   l_Master_Attribute_Code    Attribute_Code_type;
   i                          BINARY_INTEGER;

BEGIN

   IF ( g_Master_Attribute_tbl.COUNT = 0 ) THEN

      OPEN Master_Attribute_csr;

      -- Loop through item attributes

      i := 0;

      LOOP
         i := i + 1;

         FETCH Master_Attribute_csr INTO l_Master_Attribute_Code;
         EXIT WHEN ( Master_Attribute_csr%NOTFOUND );

         g_Master_Attribute_tbl (i) := l_Master_Attribute_Code;

         IF ( l_Master_Attribute_Code = 'PRIMARY_UOM_CODE' ) THEN
            i := i + 1;
            g_Master_Attribute_tbl (i) := 'PRIMARY_UNIT_OF_MEASURE';
         END IF;

      END LOOP;  -- Loop through item attributes

      CLOSE Master_Attribute_csr;

   END IF;  -- (g_Master_Attribute_tbl.COUNT = 0)

   -- Set return status
   x_return_status := FND_API.g_RET_STS_SUCCESS;

EXCEPTION

   WHEN others THEN

      IF ( Master_Attribute_csr%ISOPEN ) THEN
         CLOSE Master_Attribute_csr;
      END IF;

      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level
         ( FND_MSG_PUB.g_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (   p_pkg_name         =>  G_PKG_NAME
         ,   p_procedure_name   =>  l_api_name
--       ,   p_error_text       =>  'UNEXP_ERROR : ' || SQLERRM
         );
      END IF;

END Get_Master_Attributes;


/*------------------------------ Lock_Org_Items ------------------------------*/

PROCEDURE Lock_Org_Items
(
    p_Item_ID         IN   NUMBER
,   p_Org_ID          IN   NUMBER
,   p_lock_Master     IN   VARCHAR2   :=  FND_API.g_TRUE
,   p_lock_Orgs       IN   VARCHAR2   :=  FND_API.g_FALSE
,   x_return_status   OUT NOCOPY VARCHAR2
)
IS
  l_api_name    CONSTANT  VARCHAR2(30)  :=  'Lock_Org_Items';
/*
  l_Item_ID         NUMBER ;
  l_Org_ID          NUMBER ;
*/
  l_return_status   VARCHAR2(1);
BEGIN

  OPEN INV_ITEM_API.Item_csr
       (
           p_Item_ID        =>  p_Item_ID
       ,   p_Org_ID         =>  p_Org_ID
       ,   p_fetch_Master   =>  p_lock_Master
       ,   p_fetch_Orgs     =>  p_lock_Orgs
       );

  CLOSE INV_ITEM_API.Item_csr;

  OPEN INV_ITEM_API.Item_TL_csr
       (
           p_Item_ID        =>  p_Item_ID
       ,   p_Org_ID         =>  p_Org_ID
       ,   p_fetch_Master   =>  p_lock_Master
       ,   p_fetch_Orgs     =>  p_lock_Orgs
       );

  CLOSE INV_ITEM_API.Item_TL_csr;

EXCEPTION

/*
  -- row locking exception
  --
  WHEN FND_API.g_EXC_ THEN
     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
     fnd_message.Set_Name( 'INV', 'Cannot_Lock_Item_rec' );
     FND_MSG_PUB.Add;
     RAISE;
*/

  WHEN OTHERS THEN

     IF ( INV_ITEM_API.Item_csr%ISOPEN ) THEN
        CLOSE INV_ITEM_API.Item_csr;
     END IF;

     IF ( INV_ITEM_API.Item_TL_csr%ISOPEN ) THEN
        CLOSE INV_ITEM_API.Item_TL_csr;
     END IF;

     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
     fnd_message.Set_Name( 'INV', 'Cannot_Lock_Item_rec' );
     FND_MSG_PUB.Add;
     RAISE;

END Lock_Org_Items;


/*----------------------------- Update_Org_Items -----------------------------*/

PROCEDURE Update_Org_Items
(
    p_init_msg_list        IN   VARCHAR2       :=  FND_API.g_FALSE
,   p_commit               IN   VARCHAR2       :=  FND_API.g_FALSE
,   p_lock_rows            IN   VARCHAR2       :=  FND_API.g_TRUE
,   p_validation_level     IN   NUMBER         :=  FND_API.g_VALID_LEVEL_FULL
,   p_Item_rec             IN   INV_ITEM_API.Item_rec_type
,   p_update_changes_only  IN   VARCHAR2       :=  FND_API.g_FALSE
,   p_validate_Master      IN   VARCHAR2       :=  FND_API.g_TRUE
,   x_return_status        OUT NOCOPY VARCHAR2
,   x_msg_count            OUT NOCOPY NUMBER
,   x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name    CONSTANT  VARCHAR2(30)  :=  'Update_Org_Items';

  p_Item_ID         NUMBER;
  p_Org_ID          NUMBER;
  p_Master_Org_ID   NUMBER;
  p_Org_is_Master   BOOLEAN;

--  l_Item_ID         NUMBER;
--  l_Org_ID          NUMBER;

  l_Item_rec               INV_ITEM_API.Item_rec_type;
  m_Item_rec               INV_ITEM_API.Item_rec_type;

--  l_Item_TL_rec            INV_ITEM_API.Item_TL_rec_type;

  l_Attribute_Code         Attribute_Code_type;
  l_update_Item_TL         BOOLEAN;
--  l_Lang_Flag              VARCHAR2(1);
  l_Lang_Flag              FND_LANGUAGES.INSTALLED_FLAG%TYPE;

  l_return_status          VARCHAR2(1);
--Added for 11.5.10
  l_vmiorconsign_enabled   NUMBER;
  l_consign_enabled        NUMBER;
  l_exists                 NUMBER;


   CURSOR org_parameters_csr(c_organization_id NUMBER)
   IS
     SELECT  process_enabled_flag, wms_enabled_flag,
             eam_enabled_flag, primary_cost_method,
	     trading_partner_org_flag
     FROM  mtl_parameters
     WHERE organization_id = c_organization_id;

l_process_enabled        VARCHAR2(1);
l_eam_enabled            VARCHAR2(1);
l_wms_enabled            VARCHAR2(1);
l_primary_cost_method    NUMBER;
l_trading_partner_org    VARCHAR2(1);


  -- Added for bug 5236494
  CURSOR status_attr_control IS
  SELECT attribute_name, status_control_code,control_level /*Bug#6911195 Added control_level*/
  FROM   mtl_item_attributes
  WHERE  status_control_code IS NOT NULL;

  CURSOR  status_attr_values (p_item_status_code VARCHAR2) IS
  SELECT  attribute_name, attribute_value
  FROM    mtl_status_attribute_values
  WHERE   inventory_item_status_code = p_item_status_code;

  -- bug 9944329, get org level controlled status attributes
  CURSOR  org_status_attr_values_csr (p_item_status_code VARCHAR2) IS
  SELECT status.attribute_name, attribute_value, status_control_code
  FROM mtl_status_attribute_values status, mtl_item_attributes control
 WHERE inventory_item_status_code =p_item_status_code
   AND status.attribute_name = control.attribute_name
   AND control_level = 2;

  l_status_attr            VARCHAR2(50);
  l_status_ctrl            NUMBER;
  l_bom_enabled_status	   VARCHAR2(1);
  l_purchasable_status	   VARCHAR2(1);
  l_transactable_status	   VARCHAR2(1);
  l_stockable_status	   VARCHAR2(1);
  l_wip_status		   VARCHAR2(1);
  l_cust_ord_status	   VARCHAR2(1);
  l_int_ord_status	   VARCHAR2(1);
  l_invoiceable_status	   VARCHAR2(1);

  /*Added for Bug# 6911195 Begin*/
     l_status_ctrl_lvl                NUMBER;
     l_bom_enabled_status_ctrl        VARCHAR2(1);
     l_purchasable_status_ctrl        VARCHAR2(1);
     l_transactable_status_ctrl       VARCHAR2(1);
     l_stockable_status_ctrl          VARCHAR2(1);
     l_wip_status_ctrl                VARCHAR2(1);
     l_cust_ord_status_ctrl           VARCHAR2(1);
     l_int_ord_status_ctrl            VARCHAR2(1);
     l_invoiceable_status_ctrl        VARCHAR2(1);
   /*Added for Bug# 6911195 End*/

  l_attr_name		   VARCHAR2(50);
  l_attr_value		   VARCHAR2(1);
  l_bom_enabled_value	   VARCHAR2(1);
  l_purchasable_value	   VARCHAR2(1);
  l_transactable_value	   VARCHAR2(1);
  l_stockable_value	   VARCHAR2(1);
  l_wip_value		   VARCHAR2(1);
  l_cust_ord_value	   VARCHAR2(1);
  l_int_ord_value	   VARCHAR2(1);
  l_invoiceable_value	   VARCHAR2(1);
  -- End of bug 5236494
  l_update_child_rec Boolean := FALSE; --Bug: 5220205
  --bug 9944329
  l_status_code_changed Boolean := FALSE;
  l_status_code_control_level        NUMBER;
  l_org_status_attribute_name               VARCHAR2(50);
  l_org_status_attribute_value              VARCHAR2(1);
  l_org_status_attribute_control     NUMBER;
  --End bug 9944329
BEGIN

  -- Set savepoint
  SAVEPOINT Update_Org_Items_PVT;

  -- Initialize message list
  --
  IF ( FND_API.to_Boolean (p_init_msg_list) ) THEN
     FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  --
  x_return_status := FND_API.g_RET_STS_SUCCESS;

  p_Item_ID := p_Item_rec.INVENTORY_ITEM_ID ;
  p_Org_ID  := p_Item_rec.ORGANIZATION_ID ;

  IF ( p_Item_ID IS NULL ) OR
     ( p_Org_ID  IS NULL )
  THEN
     fnd_message.SET_NAME( 'INV', 'INV_MISS_OrgItem_ID' );
     FND_MSG_PUB.Add;
     RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
  END IF;



  -- At this point it is sufficient to check (above) that item id
  -- is not missing.
/*
  -- Check if item record has any attribute values assigned
  --
  IF ( INV_ITEM_Lib.Is_Item_rec_Missing( p_Item_rec ) ) THEN
     fnd_message.SET_NAME( 'INV', 'INV_MISS_Item_rec' );
     FND_MSG_PUB.Add;
     RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
  END IF;
*/

  ------------------------
  -- Lock org item rows --
  ------------------------

  IF ( FND_API.to_Boolean (p_lock_rows) ) THEN

     INV_ITEM_PVT.Lock_Org_Items
     (
         p_Item_ID         =>  p_Item_ID
     ,   p_Org_ID          =>  p_Org_ID
     ,   p_lock_Master     =>  FND_API.g_TRUE
     ,   p_lock_Orgs       =>  FND_API.g_TRUE
     ,   x_return_status   =>  l_return_status
     );

  END IF;  --  Lock org item rows

  -- Get current language installation status (B or I)
  -- to see if it is base language
  --
  SELECT  INSTALLED_FLAG INTO l_Lang_Flag
  FROM  FND_LANGUAGES
  WHERE  LANGUAGE_CODE = userenv('LANG');

  --------------------------------------------
  -- Open item query and fetch a first row. --
  -- The first row is master item, if p_Org --
  -- is master organization.                --
  --------------------------------------------

  OPEN INV_ITEM_API.Item_csr
       (
           p_Item_ID        =>  p_Item_ID
       ,   p_Org_ID         =>  p_Org_ID
       ,   p_fetch_Master   =>  FND_API.g_TRUE
       ,   p_fetch_Orgs     =>  FND_API.g_TRUE
       );
  FETCH INV_ITEM_API.Item_csr INTO l_Item_rec;

  IF ( INV_ITEM_API.Item_csr%NOTFOUND ) THEN
     CLOSE INV_ITEM_API.Item_csr;
     fnd_message.SET_NAME( 'INV', 'INV_Update_Org_Items_notfound' );
     FND_MSG_PUB.Add;
     RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Get master org ID from the fetched record
  -- (parameter p_Item_rec may not have this value)
  --
  p_Master_Org_ID := l_Item_rec.MASTER_ORGANIZATION_ID ;

  p_Org_is_Master := ( p_Org_ID = p_Master_Org_ID );

  ----------------------------------------------------------
  -- Depending on the input parameter, copy either        --
  -- input item record "as is", or changed atributes only --
  ----------------------------------------------------------

  IF ( FND_API.to_Boolean (p_update_changes_only) )
  THEN
     -- Update changed attributes only - not implemented yet
/*
     INV_ITEM_Lib.Copy_Changed_Attributes
     (
         p_Item_rec   =>  p_Item_rec
     ,   x_Item_rec   =>  l_Item_rec
     );
*/
     l_Item_rec := p_Item_rec ;
  ELSE
     l_Item_rec := p_Item_rec ;
  END IF;

/*
  -- Value layer

  -- Attribute defaulting
*/

  -------------------------------------------------------
  -- Item validation, depending on the input parameter --
  -------------------------------------------------------

  IF ( FND_API.to_Boolean (p_validate_Master) ) THEN

     IF (l_Item_rec.inventory_item_flag ='N' AND
         l_Item_rec.stock_enabled_flag ='Y' ) THEN
       fnd_message.SET_NAME('INV', 'INVALID_INV_STK_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
     ELSIF (l_Item_rec.stock_enabled_flag ='N' AND
            l_Item_rec.mtl_transactions_enabled_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_STK_TRX_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
	 --added for bug 8575398, pop up exception when check_shortages_flag = Y and transactions_enabled_flag = N
	 ELSIF (l_Item_rec.check_shortages_flag ='Y' AND
            l_Item_rec.mtl_transactions_enabled_flag ='N' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_CHK_TRX_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
     ELSIF (l_Item_rec.purchasing_item_flag ='N' AND
            l_Item_rec.purchasing_enabled_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_PI_PE_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
     ELSIF (l_Item_rec.customer_order_flag ='N' AND
            l_Item_rec.customer_order_enabled_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_CO_COE_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
     ELSIF (l_Item_rec.internal_order_flag ='N' AND
            l_Item_rec.internal_order_enabled_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_IO_IOE_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
/** Bug: 3546140 Removed for PLM RBOM
     ELSIF (l_Item_rec.inventory_item_flag = 'N' AND
            l_Item_rec.contract_item_type_code IS NULL AND
            l_Item_rec.bom_enabled_flag = 'Y') THEN
       fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
       fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_BOM_ENABLED', TRUE);
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
***/
     ELSIF ( ( l_item_rec.inventory_item_flag = 'N'
           OR  l_item_rec.bom_item_type <> 4 )
           AND l_Item_rec.build_in_wip_flag ='Y' ) THEN
       FND_MESSAGE.Set_Name ('INV', 'INVALID_INV_WIP_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;

     ELSIF ( l_Item_rec.EFFECTIVITY_CONTROL = 2 ) AND
           ( l_Item_rec.SERIAL_NUMBER_CONTROL_CODE NOT IN (2, 5) ) THEN
       fnd_message.SET_NAME('INV', 'ITM-EFFC-INVALID SERIAL CTRL-2');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;

     ELSIF (l_Item_rec.serviceable_product_flag = 'Y' AND
            nvl(l_Item_rec.comms_nl_trackable_flag,'N') = 'N') THEN
       fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
       fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_IB_TRACKING_SERVICEABLE', TRUE);
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
--Added for 11.5.10 validations
     ELSE
       INVIDIT3.VMI_Table_Queries(
           P_org_id                =>  l_Item_rec.organization_id
         , P_item_id               =>  l_Item_rec.inventory_item_id
         , X_vmiorconsign_enabled  =>  l_vmiorconsign_enabled
         , X_consign_enabled	   =>  l_consign_enabled
         );
       IF ( (l_vmiorconsign_enabled = 1 AND
            (NVL(l_Item_rec.outside_operation_flag,'N') = 'Y' OR
	     l_Item_rec.eam_item_type IS NOT NULL OR
             NVL(l_Item_rec.mtl_transactions_enabled_flag,'N') = 'N' OR
             NVL(l_Item_rec.stock_enabled_flag,'N') = 'N'))
            OR
	    (l_consign_enabled = 1 AND NVL(l_Item_rec.inventory_asset_flag,'N') = 'N')
            ) THEN
                fnd_message.SET_NAME ('INV', 'INV_INVALID_VMI_COMB');
                FND_MSG_PUB.Add;
                l_return_status := FND_API.g_RET_STS_ERROR;
       END IF;
     END IF;

/*
     INV_ITEM_PVT.Validate_Item
     (
         p_validation_level  =>  p_validation_level
     ,   p_Item_rec          =>  l_Item_rec
     ,   x_return_status     =>  l_return_status
     ,   x_msg_count         =>  x_msg_count
     ,   x_msg_data          =>  x_msg_data
     );
*/

     IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
        RAISE FND_API.g_EXC_ERROR;
     ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
     END IF;

  END IF;  -- validate master

  ----------------------------
  -- Update master item row --
  ----------------------------

  INV_ITEM_API.Update_Item_Row
  (
      p_Item_rec          =>  l_Item_rec
  ,   p_update_Item_TL    =>  TRUE
  ,   p_Lang_Flag         =>  l_Lang_Flag
  ,   x_return_status     =>  l_return_status
  );

  -------------------------------------------------
  -- Continue with org items, if p_Org is master --
  -------------------------------------------------

  ----------------------------------- p_Org is master ---
  IF ( p_Org_is_Master ) THEN

     -- Save master item record
     --
     m_Item_rec := l_Item_rec;

     -- Get a list of master control level attributes

     Get_Master_Attributes ( x_return_status  =>  l_return_status );

     IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
        RAISE FND_API.g_EXC_ERROR;
     ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
     END IF;
/*
     ELSE
       fnd_message.Set_Name( 'INV', 'Master_Attribute.COUNT <> 0' );
       FND_MSG_PUB.Add;
       RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
*/

/*   Following fix needs to be reverted for 5645595
     -- Added for bug 5236494
     -- Fetching status setting for each status controlled attribute
     OPEN status_attr_control;
     LOOP
	FETCH status_attr_control INTO l_status_attr, l_status_ctrl;
	EXIT when status_attr_control%NOTFOUND;

	IF l_status_attr = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG' THEN
	    l_bom_enabled_status := l_status_ctrl;
	ELSIF l_status_attr = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG' THEN
	    l_purchasable_status := l_status_ctrl;
	ELSIF l_status_attr = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG' THEN
	    l_transactable_status := l_status_ctrl;
	ELSIF l_status_attr = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG' THEN
	    l_stockable_status := l_status_ctrl;
	ELSIF l_status_attr = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG' THEN
	    l_wip_status := l_status_ctrl;
	ELSIF l_status_attr = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG' THEN
	    l_cust_ord_status := l_status_ctrl;
	ELSIF l_status_attr = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG' THEN
	    l_int_ord_status := l_status_ctrl;
	ELSIF l_status_attr = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG' THEN
	    l_invoiceable_status := l_status_ctrl;
	END IF;

     END LOOP;
     CLOSE status_attr_control;

     -- Fetching attribute value for each status controlled attribute
     -- corresponding to master organization's status code
     OPEN status_attr_values (m_Item_rec.INVENTORY_ITEM_STATUS_CODE);
     LOOP
	FETCH status_attr_values INTO l_attr_name, l_attr_value;
	EXIT when status_attr_values%NOTFOUND;

	IF l_attr_name = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG' THEN
	    l_bom_enabled_value := l_attr_value;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG' THEN
	    l_purchasable_value := l_attr_value;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG' THEN
	    l_transactable_value := l_attr_value;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG' THEN
	    l_stockable_value := l_attr_value;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG' THEN
	    l_wip_value := l_attr_value;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG' THEN
	    l_cust_ord_value := l_attr_value;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG' THEN
	    l_int_ord_value := l_attr_value;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG' THEN
	    l_invoiceable_value := l_attr_value;
	END IF;

     END LOOP;
     CLOSE status_attr_values; */
     -- End of bug 5236494

     --Added for Bug# 6911195 Begin --
     -- Fetching attribute value for each status controlled attribute
     -- corresponding to master organization's status code
     OPEN status_attr_values (m_Item_rec.INVENTORY_ITEM_STATUS_CODE);
     LOOP
	FETCH status_attr_values INTO l_attr_name, l_attr_value;
	EXIT when status_attr_values%NOTFOUND;

	IF l_attr_name = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG' THEN
	    l_bom_enabled_value := l_attr_value;
	    l_bom_enabled_status_ctrl := l_status_ctrl_lvl;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG' THEN
	    l_purchasable_value := l_attr_value;
            l_purchasable_status_ctrl := l_status_ctrl_lvl;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG' THEN
	    l_transactable_value := l_attr_value;
	    l_transactable_status_ctrl := l_status_ctrl_lvl;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG' THEN
	    l_stockable_value := l_attr_value;
            l_stockable_status_ctrl := l_status_ctrl_lvl;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG' THEN
	    l_wip_value := l_attr_value;
            l_wip_status_ctrl := l_status_ctrl_lvl;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG' THEN
	    l_cust_ord_value := l_attr_value;
	    l_cust_ord_status_ctrl := l_status_ctrl_lvl;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG' THEN
	    l_int_ord_value := l_attr_value;
	    l_int_ord_status_ctrl := l_status_ctrl_lvl;
	ELSIF l_attr_name = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG' THEN
	    l_invoiceable_value := l_attr_value;
            l_invoiceable_status_ctrl := l_status_ctrl_lvl;
	END IF;

     END LOOP;
     CLOSE status_attr_values;
--Added for Bug# 6911195 --

-- bug 9944329, get status code attribute control level
  SELECT control_level
  INTO l_status_code_control_level
  FROM mtl_item_attributes
 WHERE attribute_name = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';
  --------------------------------
  LOOP  -- loop through org items

     FETCH INV_ITEM_API.Item_csr INTO l_Item_rec;

     EXIT WHEN INV_ITEM_API.Item_csr%NOTFOUND;

     ----------------------------------
     -- Loop through item attributes --
     ----------------------------------

     l_update_Item_TL := FALSE;
     l_update_child_rec     := FALSE;  --Bug: 5220205
  -- Bug 4388141. Populate long description in l_item_rec.long_description
     SELECT description , long_description
     INTO   l_item_rec.description , l_item_rec.long_description
     FROM   mtl_system_items_tl
     WHERE  inventory_item_id = l_item_rec.inventory_item_id
     AND    organization_id = l_item_rec.organization_id
     AND    language = userenv('LANG');
	--bug 9944329, check if status has been changed in master org
			if l_Item_rec.INVENTORY_ITEM_STATUS_CODE <> m_Item_rec.INVENTORY_ITEM_STATUS_CODE  then
				l_status_code_changed := TRUE;
			end if;

     FOR i IN 1 .. g_Master_Attribute_tbl.COUNT LOOP
        l_Attribute_Code := g_Master_Attribute_tbl (i);
        -- Copy master level attribute over to an org item

        IF ( l_Attribute_Code = 'DESCRIPTION'                       ) THEN
	   IF l_Item_rec.DESCRIPTION <> m_Item_rec.DESCRIPTION THEN
              l_Item_rec.DESCRIPTION := m_Item_rec.DESCRIPTION;
              l_update_Item_TL := TRUE;
              l_update_child_rec := TRUE;
	   END IF;
	ELSIF ( l_Attribute_Code = 'LONG_DESCRIPTION'               ) THEN
	   IF NVL(l_Item_rec.LONG_DESCRIPTION,'@@@') <> NVL(m_Item_rec.LONG_DESCRIPTION,'@@@') THEN
	      l_Item_rec.LONG_DESCRIPTION := m_Item_rec.LONG_DESCRIPTION;
              l_update_Item_TL := TRUE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PRIMARY_UOM_CODE'               ) THEN
           l_Item_rec.PRIMARY_UOM_CODE := m_Item_rec.PRIMARY_UOM_CODE;
        ELSIF ( l_Attribute_Code = 'PRIMARY_UNIT_OF_MEASURE'        ) THEN
           l_Item_rec.PRIMARY_UNIT_OF_MEASURE := m_Item_rec.PRIMARY_UNIT_OF_MEASURE;

        ELSIF ( l_Attribute_Code = 'ITEM_TYPE'                      ) THEN
           l_Item_rec.ITEM_TYPE                      := m_Item_rec.ITEM_TYPE;
           l_update_child_rec := TRUE;		-- Bug 	6450473

        ELSIF ( l_Attribute_Code = 'INVENTORY_ITEM_STATUS_CODE'     ) THEN
	   --Added for Bug: 5236494
	   IF l_Item_rec.INVENTORY_ITEM_STATUS_CODE <> m_Item_rec.INVENTORY_ITEM_STATUS_CODE THEN
 	      /*   Following fix needs to be reverted for 5645595
		-- If status setting is not 'Not Used' then populate child organization's
		-- status controlled attributes with attribute value fetched earlier.
		IF l_stockable_status <> 3 THEN
		    l_Item_rec.STOCK_ENABLED_FLAG := l_stockable_value;
		END IF;
		IF l_transactable_status <> 3 THEN
		    l_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG := l_transactable_value;
		END IF;
		IF l_bom_enabled_status <> 3 THEN
		    l_Item_rec.BOM_ENABLED_FLAG := l_bom_enabled_value;
		END IF;
		IF l_purchasable_status <> 3 THEN
		    l_Item_rec.PURCHASING_ENABLED_FLAG := l_purchasable_value;
		END IF;
		IF l_wip_status <> 3 THEN
		    l_Item_rec.BUILD_IN_WIP_FLAG := l_wip_value;
		END IF;
		IF l_cust_ord_status <> 3 THEN
		    l_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG := l_cust_ord_value;
		END IF;
		IF l_int_ord_status <> 3 THEN
		    l_Item_rec.INTERNAL_ORDER_ENABLED_FLAG := l_int_ord_value;
		END IF;
		IF l_invoiceable_status <> 3 THEN
		    l_Item_rec.INVOICE_ENABLED_FLAG := l_invoiceable_value;
		END IF; */
	   -- End of bug 5236494

	    --Added for Bug# 6911195--BEGIN--

		IF l_stockable_status <> 3 and l_stockable_status_ctrl <> 1 THEN   /*Added additional condition to set the value of the
											status attributes only if they or Org controlled*/
		    l_Item_rec.STOCK_ENABLED_FLAG := l_stockable_value;
		END IF;
		IF l_transactable_status <> 3 AND l_transactable_status_ctrl <> 1 THEN
		    l_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG := l_transactable_value;
		END IF;
		IF l_bom_enabled_status <> 3 AND l_bom_enabled_status_ctrl <> 1 THEN
		    l_Item_rec.BOM_ENABLED_FLAG := l_bom_enabled_value;
		END IF;
		IF l_purchasable_status <> 3 AND l_purchasable_status  <> 1 THEN
		    l_Item_rec.PURCHASING_ENABLED_FLAG := l_purchasable_value;
		END IF;
		IF l_wip_status <> 3 AND l_wip_status <> 1 THEN
		    l_Item_rec.BUILD_IN_WIP_FLAG := l_wip_value;
		END IF;
		IF l_cust_ord_status <> 3 AND l_cust_ord_status <> 1  THEN
		    l_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG := l_cust_ord_value;
		END IF;
		IF l_int_ord_status <> 3 AND l_int_ord_status <> 1 THEN
		    l_Item_rec.INTERNAL_ORDER_ENABLED_FLAG := l_int_ord_value;
		END IF;
		IF l_invoiceable_status <> 3 AND l_invoiceable_status  <> 1  THEN
		    l_Item_rec.INVOICE_ENABLED_FLAG := l_invoiceable_value;
		END IF;

               --Added for Bug# 6911195-- End--
	        l_Item_rec.INVENTORY_ITEM_STATUS_CODE     := m_Item_rec.INVENTORY_ITEM_STATUS_CODE;
                l_update_child_rec := TRUE;
	   END IF;

            --Inventory Attribute Group
        ELSIF ( l_Attribute_Code = 'INVENTORY_ITEM_FLAG') THEN
	   IF (NVL(l_Item_rec.INVENTORY_ITEM_FLAG,'!')  <> NVL(m_Item_rec.INVENTORY_ITEM_FLAG,'!')) THEN
              l_Item_rec.INVENTORY_ITEM_FLAG            := m_Item_rec.INVENTORY_ITEM_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'STOCK_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.STOCK_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.STOCK_ENABLED_FLAG,'!')) THEN
              l_Item_rec.STOCK_ENABLED_FLAG             := m_Item_rec.STOCK_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MTL_TRANSACTIONS_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG,'!')) THEN
              l_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG  := m_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'REVISION_QTY_CONTROL_CODE') THEN
	   IF (NVL(l_Item_rec.REVISION_QTY_CONTROL_CODE,-999999)  <> NVL(m_Item_rec.REVISION_QTY_CONTROL_CODE,-999999)) THEN
              l_Item_rec.REVISION_QTY_CONTROL_CODE      := m_Item_rec.REVISION_QTY_CONTROL_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RESERVABLE_TYPE') THEN
	   IF (NVL(l_Item_rec.RESERVABLE_TYPE,-999999)  <> NVL(m_Item_rec.RESERVABLE_TYPE,-999999)) THEN
              l_Item_rec.RESERVABLE_TYPE                := m_Item_rec.RESERVABLE_TYPE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CHECK_SHORTAGES_FLAG') THEN
	   IF (NVL(l_Item_rec.CHECK_SHORTAGES_FLAG,'!')  <> NVL(m_Item_rec.CHECK_SHORTAGES_FLAG,'!')) THEN
              l_Item_rec.CHECK_SHORTAGES_FLAG           := m_Item_rec.CHECK_SHORTAGES_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LOT_CONTROL_CODE') THEN
	   IF (NVL(l_Item_rec.LOT_CONTROL_CODE,-999999)  <> NVL(m_Item_rec.LOT_CONTROL_CODE,-999999)) THEN
              l_Item_rec.LOT_CONTROL_CODE               := m_Item_rec.LOT_CONTROL_CODE;
              l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'AUTO_LOT_ALPHA_PREFIX') THEN
	   IF (NVL(l_Item_rec.AUTO_LOT_ALPHA_PREFIX,'!')  <> NVL(m_Item_rec.AUTO_LOT_ALPHA_PREFIX,'!')) THEN
              l_Item_rec.AUTO_LOT_ALPHA_PREFIX          := m_Item_rec.AUTO_LOT_ALPHA_PREFIX;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'START_AUTO_LOT_NUMBER') THEN
	   IF (NVL(l_Item_rec.START_AUTO_LOT_NUMBER,-999999)  <> NVL(m_Item_rec.START_AUTO_LOT_NUMBER,-999999)) THEN
              l_Item_rec.START_AUTO_LOT_NUMBER          := m_Item_rec.START_AUTO_LOT_NUMBER;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SHELF_LIFE_CODE') THEN
	   IF (NVL(l_Item_rec.SHELF_LIFE_CODE,-999999)  <> NVL(m_Item_rec.SHELF_LIFE_CODE,-999999)) THEN
              l_Item_rec.SHELF_LIFE_CODE                := m_Item_rec.SHELF_LIFE_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SHELF_LIFE_DAYS') THEN
	   IF (NVL(l_Item_rec.SHELF_LIFE_DAYS,-999999)  <> NVL(m_Item_rec.SHELF_LIFE_DAYS,-999999)) THEN
              l_Item_rec.SHELF_LIFE_DAYS                := m_Item_rec.SHELF_LIFE_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CYCLE_COUNT_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.CYCLE_COUNT_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.CYCLE_COUNT_ENABLED_FLAG,'!')) THEN
              l_Item_rec.CYCLE_COUNT_ENABLED_FLAG       := m_Item_rec.CYCLE_COUNT_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'NEGATIVE_MEASUREMENT_ERROR') THEN
	   IF (NVL(l_Item_rec.NEGATIVE_MEASUREMENT_ERROR,-999999)  <> NVL(m_Item_rec.NEGATIVE_MEASUREMENT_ERROR,-999999)) THEN
              l_Item_rec.NEGATIVE_MEASUREMENT_ERROR     := m_Item_rec.NEGATIVE_MEASUREMENT_ERROR;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'POSITIVE_MEASUREMENT_ERROR') THEN
	   IF (NVL(l_Item_rec.POSITIVE_MEASUREMENT_ERROR,-999999)  <> NVL(m_Item_rec.POSITIVE_MEASUREMENT_ERROR,-999999)) THEN
              l_Item_rec.POSITIVE_MEASUREMENT_ERROR     := m_Item_rec.POSITIVE_MEASUREMENT_ERROR;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERIAL_NUMBER_CONTROL_CODE') THEN
	   IF (NVL(l_Item_rec.SERIAL_NUMBER_CONTROL_CODE,-999999)  <> NVL(m_Item_rec.SERIAL_NUMBER_CONTROL_CODE,-999999)) THEN
              l_Item_rec.SERIAL_NUMBER_CONTROL_CODE     := m_Item_rec.SERIAL_NUMBER_CONTROL_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'AUTO_SERIAL_ALPHA_PREFIX') THEN
	   IF (NVL(l_Item_rec.AUTO_SERIAL_ALPHA_PREFIX,'!')  <> NVL(m_Item_rec.AUTO_SERIAL_ALPHA_PREFIX,'!')) THEN
              l_Item_rec.AUTO_SERIAL_ALPHA_PREFIX       := m_Item_rec.AUTO_SERIAL_ALPHA_PREFIX;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'START_AUTO_SERIAL_NUMBER') THEN
	   IF (NVL(l_Item_rec.START_AUTO_SERIAL_NUMBER,-999999)  <> NVL(m_Item_rec.START_AUTO_SERIAL_NUMBER,-999999)) THEN
              l_Item_rec.START_AUTO_SERIAL_NUMBER       := m_Item_rec.START_AUTO_SERIAL_NUMBER;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LOCATION_CONTROL_CODE') THEN
	   IF (NVL(l_Item_rec.LOCATION_CONTROL_CODE,-999999)  <> NVL(m_Item_rec.LOCATION_CONTROL_CODE,-999999)) THEN
              l_Item_rec.LOCATION_CONTROL_CODE          := m_Item_rec.LOCATION_CONTROL_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RESTRICT_SUBINVENTORIES_CODE') THEN
	   IF (NVL(l_Item_rec.RESTRICT_SUBINVENTORIES_CODE,-999999)  <> NVL(m_Item_rec.RESTRICT_SUBINVENTORIES_CODE,-999999)) THEN
              l_Item_rec.RESTRICT_SUBINVENTORIES_CODE   := m_Item_rec.RESTRICT_SUBINVENTORIES_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RESTRICT_LOCATORS_CODE') THEN
	   IF (NVL(l_Item_rec.RESTRICT_LOCATORS_CODE,-999999)  <> NVL(m_Item_rec.RESTRICT_LOCATORS_CODE,-999999)) THEN
              l_Item_rec.RESTRICT_LOCATORS_CODE         := m_Item_rec.RESTRICT_LOCATORS_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LOT_STATUS_ENABLED') THEN
	   IF (NVL(l_Item_rec.LOT_STATUS_ENABLED,'!')  <> NVL(m_Item_rec.LOT_STATUS_ENABLED,'!')) THEN
              l_Item_rec.LOT_STATUS_ENABLED := m_Item_rec.LOT_STATUS_ENABLED ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DEFAULT_LOT_STATUS_ID') THEN
	   IF (NVL(l_Item_rec.DEFAULT_LOT_STATUS_ID,-999999)  <> NVL(m_Item_rec.DEFAULT_LOT_STATUS_ID,-999999)) THEN
              l_Item_rec.DEFAULT_LOT_STATUS_ID := m_Item_rec.DEFAULT_LOT_STATUS_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERIAL_STATUS_ENABLED') THEN
	   IF (NVL(l_Item_rec.SERIAL_STATUS_ENABLED,'!')  <> NVL(m_Item_rec.SERIAL_STATUS_ENABLED,'!')) THEN
              l_Item_rec.SERIAL_STATUS_ENABLED := m_Item_rec.SERIAL_STATUS_ENABLED;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DEFAULT_SERIAL_STATUS_ID') THEN
	   IF (NVL(l_Item_rec.DEFAULT_SERIAL_STATUS_ID,-999999)  <> NVL(m_Item_rec.DEFAULT_SERIAL_STATUS_ID,-999999)) THEN
              l_Item_rec.DEFAULT_SERIAL_STATUS_ID := m_Item_rec.DEFAULT_SERIAL_STATUS_ID ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LOT_SPLIT_ENABLED') THEN
	   IF (NVL(l_Item_rec.LOT_SPLIT_ENABLED,'!')  <> NVL(m_Item_rec.LOT_SPLIT_ENABLED,'!')) THEN
              l_Item_rec.LOT_SPLIT_ENABLED := m_Item_rec.LOT_SPLIT_ENABLED ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LOT_MERGE_ENABLED') THEN
	   IF (NVL(l_Item_rec.LOT_MERGE_ENABLED,'!')  <> NVL(m_Item_rec.LOT_MERGE_ENABLED,'!')) THEN
              l_Item_rec.LOT_MERGE_ENABLED := m_Item_rec.LOT_MERGE_ENABLED ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LOT_TRANSLATE_ENABLED') THEN
	   IF (NVL(l_Item_rec.LOT_TRANSLATE_ENABLED,'!')  <> NVL(m_Item_rec.LOT_TRANSLATE_ENABLED,'!')) THEN
              l_Item_rec.LOT_TRANSLATE_ENABLED      :=  m_Item_rec.LOT_TRANSLATE_ENABLED;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LOT_SUBSTITUTION_ENABLED') THEN
	   IF (NVL(l_Item_rec.LOT_SUBSTITUTION_ENABLED,'!')  <> NVL(m_Item_rec.LOT_SUBSTITUTION_ENABLED,'!')) THEN
              l_Item_rec.LOT_SUBSTITUTION_ENABLED     :=  m_Item_rec.LOT_SUBSTITUTION_ENABLED;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'BULK_PICKED_FLAG') THEN
	   IF (NVL(l_Item_rec.BULK_PICKED_FLAG,'!')  <> NVL(m_Item_rec.BULK_PICKED_FLAG,'!')) THEN
              l_Item_rec.BULK_PICKED_FLAG := m_Item_rec.BULK_PICKED_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LOT_DIVISIBLE_FLAG') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.LOT_DIVISIBLE_FLAG,'!')  <> NVL(m_Item_rec.LOT_DIVISIBLE_FLAG,'!')) THEN
              l_Item_rec.LOT_DIVISIBLE_FLAG := m_Item_rec.LOT_DIVISIBLE_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MATURITY_DAYS') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.MATURITY_DAYS,-999999)  <> NVL(m_Item_rec.MATURITY_DAYS,-999999)) THEN
              l_Item_rec.MATURITY_DAYS := m_Item_rec.MATURITY_DAYS ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'HOLD_DAYS') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.HOLD_DAYS,-999999)  <> NVL(m_Item_rec.HOLD_DAYS,-999999)) THEN
              l_Item_rec.HOLD_DAYS := m_Item_rec.HOLD_DAYS ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RETEST_INTERVAL') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.RETEST_INTERVAL,-999999)  <> NVL(m_Item_rec.RETEST_INTERVAL,-999999)) THEN
              l_Item_rec.RETEST_INTERVAL := m_Item_rec.RETEST_INTERVAL ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'EXPIRATION_ACTION_INTERVAL') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.EXPIRATION_ACTION_INTERVAL,-999999)  <> NVL(m_Item_rec.EXPIRATION_ACTION_INTERVAL,-999999)) THEN
              l_Item_rec.EXPIRATION_ACTION_INTERVAL := m_Item_rec.EXPIRATION_ACTION_INTERVAL ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'EXPIRATION_ACTION_CODE') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.EXPIRATION_ACTION_CODE,'!')  <> NVL(m_Item_rec.EXPIRATION_ACTION_CODE,'!')) THEN
              l_Item_rec.EXPIRATION_ACTION_CODE := m_Item_rec.EXPIRATION_ACTION_CODE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'GRADE_CONTROL_FLAG') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.GRADE_CONTROL_FLAG,'!')  <> NVL(m_Item_rec.GRADE_CONTROL_FLAG,'!')) THEN
              l_Item_rec.GRADE_CONTROL_FLAG := m_Item_rec.GRADE_CONTROL_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DEFAULT_GRADE') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.DEFAULT_GRADE,'!')  <> NVL(m_Item_rec.DEFAULT_GRADE,'!')) THEN
              l_Item_rec.DEFAULT_GRADE := m_Item_rec.DEFAULT_GRADE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CHILD_LOT_FLAG') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.CHILD_LOT_FLAG,'!')  <> NVL(m_Item_rec.CHILD_LOT_FLAG,'!')) THEN
              l_Item_rec.CHILD_LOT_FLAG := m_Item_rec.CHILD_LOT_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PARENT_CHILD_GENERATION_FLAG') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.PARENT_CHILD_GENERATION_FLAG,'!')  <> NVL(m_Item_rec.PARENT_CHILD_GENERATION_FLAG,'!')) THEN
              l_Item_rec.PARENT_CHILD_GENERATION_FLAG := m_Item_rec.PARENT_CHILD_GENERATION_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CHILD_LOT_PREFIX') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.CHILD_LOT_PREFIX,'!')  <> NVL(m_Item_rec.CHILD_LOT_PREFIX,'!')) THEN
              l_Item_rec.CHILD_LOT_PREFIX := m_Item_rec.CHILD_LOT_PREFIX ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CHILD_LOT_STARTING_NUMBER') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.CHILD_LOT_STARTING_NUMBER,-999999)  <> NVL(m_Item_rec.CHILD_LOT_STARTING_NUMBER,-999999)) THEN
              l_Item_rec.CHILD_LOT_STARTING_NUMBER := m_Item_rec.CHILD_LOT_STARTING_NUMBER ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CHILD_LOT_VALIDATION_FLAG') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.CHILD_LOT_VALIDATION_FLAG,'!')  <> NVL(m_Item_rec.CHILD_LOT_VALIDATION_FLAG,'!')) THEN
              l_Item_rec.CHILD_LOT_VALIDATION_FLAG := m_Item_rec.CHILD_LOT_VALIDATION_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'COPY_LOT_ATTRIBUTE_FLAG') THEN        --Bug: 5396073
	   IF (NVL(l_Item_rec.COPY_LOT_ATTRIBUTE_FLAG,'!')  <> NVL(m_Item_rec.COPY_LOT_ATTRIBUTE_FLAG,'!')) THEN
              l_Item_rec.COPY_LOT_ATTRIBUTE_FLAG := m_Item_rec.COPY_LOT_ATTRIBUTE_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        -- Serial_Tagging Enh -- bug 9913552
        ELSIF ( l_Attribute_Code = 'SERIAL_TAGGING_FLAG') THEN
	   IF (NVL(l_Item_rec.SERIAL_TAGGING_FLAG,'!')  <> NVL(m_Item_rec.SERIAL_TAGGING_FLAG,'!')) THEN
              l_Item_rec.SERIAL_TAGGING_FLAG := m_Item_rec.SERIAL_TAGGING_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
            --BOM Attribute Group
        ELSIF ( l_Attribute_Code = 'BOM_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.BOM_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.BOM_ENABLED_FLAG,'!')) THEN
              l_Item_rec.BOM_ENABLED_FLAG               := m_Item_rec.BOM_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'BOM_ITEM_TYPE') THEN
	   IF (NVL(l_Item_rec.BOM_ITEM_TYPE,-999999)  <> NVL(m_Item_rec.BOM_ITEM_TYPE,-999999)) THEN
              l_Item_rec.BOM_ITEM_TYPE                  := m_Item_rec.BOM_ITEM_TYPE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'BASE_ITEM_ID') THEN
	   IF (NVL(l_Item_rec.BASE_ITEM_ID,-999999)  <> NVL(m_Item_rec.BASE_ITEM_ID,-999999)) THEN
              l_Item_rec.BASE_ITEM_ID                   := m_Item_rec.BASE_ITEM_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'AUTO_CREATED_CONFIG_FLAG') THEN
	   IF (NVL(l_Item_rec.AUTO_CREATED_CONFIG_FLAG,'!')  <> NVL(m_Item_rec.AUTO_CREATED_CONFIG_FLAG,'!')) THEN
              l_Item_rec.AUTO_CREATED_CONFIG_FLAG       := m_Item_rec.AUTO_CREATED_CONFIG_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ENG_ITEM_FLAG') THEN
	   IF (NVL(l_Item_rec.ENG_ITEM_FLAG,'!')  <> NVL(m_Item_rec.ENG_ITEM_FLAG,'!')) THEN
              l_Item_rec.ENG_ITEM_FLAG                  := m_Item_rec.ENG_ITEM_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'EFFECTIVITY_CONTROL')  THEN
	   IF (NVL(l_Item_rec.EFFECTIVITY_CONTROL,-999999)  <> NVL(m_Item_rec.EFFECTIVITY_CONTROL,-999999)) THEN
              l_Item_rec.EFFECTIVITY_CONTROL            := m_Item_rec.EFFECTIVITY_CONTROL;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CONFIG_MODEL_TYPE') THEN
	    IF (NVL(l_Item_rec.CONFIG_MODEL_TYPE,'!')  <> NVL(m_Item_rec.CONFIG_MODEL_TYPE,'!')) THEN
               l_Item_rec.CONFIG_MODEL_TYPE          :=  m_Item_rec.CONFIG_MODEL_TYPE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'CONFIG_ORGS') THEN
	    IF (NVL(l_Item_rec.CONFIG_ORGS,'!')  <> NVL(m_Item_rec.CONFIG_ORGS,'!')) THEN
               l_Item_rec.CONFIG_ORGS    :=  m_Item_rec.CONFIG_ORGS;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'CONFIG_MATCH')  THEN
	    IF (NVL(l_Item_rec.CONFIG_MATCH,'!')  <> NVL(m_Item_rec.CONFIG_MATCH,'!')) THEN
               l_Item_rec.CONFIG_MATCH     :=  m_Item_rec.CONFIG_MATCH;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'ENGINEERING_ECN_CODE') THEN
	   IF (NVL(l_Item_rec.ENGINEERING_ECN_CODE,'!')  <> NVL(m_Item_rec.ENGINEERING_ECN_CODE,'!')) THEN
              l_Item_rec.ENGINEERING_ECN_CODE           := m_Item_rec.ENGINEERING_ECN_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
       ELSIF ( l_Attribute_Code = 'ENGINEERING_ITEM_ID') THEN
	   IF (NVL(l_Item_rec.ENGINEERING_ITEM_ID,-999999)  <> NVL(m_Item_rec.ENGINEERING_ITEM_ID,-999999)) THEN
              l_Item_rec.ENGINEERING_ITEM_ID            := m_Item_rec.ENGINEERING_ITEM_ID;
              l_update_child_rec := TRUE;
	   END IF;

            --Asset Management Group
        ELSIF ( l_Attribute_Code = 'EAM_ITEM_TYPE') THEN
	    IF (NVL(l_Item_rec.EAM_ITEM_TYPE,-999999)  <> NVL(m_Item_rec.EAM_ITEM_TYPE,-999999)) THEN
               l_Item_rec.EAM_ITEM_TYPE := m_Item_rec.EAM_ITEM_TYPE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'EAM_ACTIVITY_TYPE_CODE') THEN
	    IF (NVL(l_Item_rec.EAM_ACTIVITY_TYPE_CODE,'!')  <> NVL(m_Item_rec.EAM_ACTIVITY_TYPE_CODE,'!')) THEN
               l_Item_rec.EAM_ACTIVITY_TYPE_CODE := m_Item_rec.EAM_ACTIVITY_TYPE_CODE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'EAM_ACTIVITY_CAUSE_CODE') THEN
	    IF (NVL(l_Item_rec.EAM_ACTIVITY_CAUSE_CODE,'!')  <> NVL(m_Item_rec.EAM_ACTIVITY_CAUSE_CODE,'!')) THEN
               l_Item_rec.EAM_ACTIVITY_CAUSE_CODE := m_Item_rec.EAM_ACTIVITY_CAUSE_CODE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'EAM_ACTIVITY_SOURCE_CODE') THEN
	    IF (NVL(l_Item_rec.EAM_ACTIVITY_SOURCE_CODE,'!')  <> NVL(m_Item_rec.EAM_ACTIVITY_SOURCE_CODE,'!')) THEN
               l_Item_rec.EAM_ACTIVITY_SOURCE_CODE          :=  m_Item_rec.EAM_ACTIVITY_SOURCE_CODE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'EAM_ACT_NOTIFICATION_FLAG') THEN
	    IF (NVL(l_Item_rec.EAM_ACT_NOTIFICATION_FLAG,'!')  <> NVL(m_Item_rec.EAM_ACT_NOTIFICATION_FLAG,'!')) THEN
               l_Item_rec.EAM_ACT_NOTIFICATION_FLAG := m_Item_rec.EAM_ACT_NOTIFICATION_FLAG;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'EAM_ACT_SHUTDOWN_STATUS') THEN
	    IF (NVL(l_Item_rec.EAM_ACT_SHUTDOWN_STATUS,'!')  <> NVL(m_Item_rec.EAM_ACT_SHUTDOWN_STATUS,'!')) THEN
               l_Item_rec.EAM_ACT_SHUTDOWN_STATUS := m_Item_rec.EAM_ACT_SHUTDOWN_STATUS;
	       l_update_child_rec := TRUE;
	    END IF;

            --Costing Attribute Group
        ELSIF ( l_Attribute_Code = 'COSTING_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.COSTING_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.COSTING_ENABLED_FLAG,'!')) THEN
              l_Item_rec.COSTING_ENABLED_FLAG           := m_Item_rec.COSTING_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INVENTORY_ASSET_FLAG') THEN
	   IF (NVL(l_Item_rec.INVENTORY_ASSET_FLAG,'!')  <> NVL(m_Item_rec.INVENTORY_ASSET_FLAG,'!')) THEN
              l_Item_rec.INVENTORY_ASSET_FLAG           := m_Item_rec.INVENTORY_ASSET_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DEFAULT_INCLUDE_IN_ROLLUP_FLAG') THEN
	   IF (NVL(l_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,'!')  <> NVL(m_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,'!')) THEN
              l_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG := m_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'COST_OF_SALES_ACCOUNT') THEN
	   IF (NVL(l_Item_rec.COST_OF_SALES_ACCOUNT,-999999)  <> NVL(m_Item_rec.COST_OF_SALES_ACCOUNT,-999999)) THEN
              l_Item_rec.COST_OF_SALES_ACCOUNT          := m_Item_rec.COST_OF_SALES_ACCOUNT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'STD_LOT_SIZE') THEN
	   IF (NVL(l_Item_rec.STD_LOT_SIZE,-999999)  <> NVL(m_Item_rec.STD_LOT_SIZE,-999999)) THEN
              l_Item_rec.STD_LOT_SIZE                   := m_Item_rec.STD_LOT_SIZE;
	      l_update_child_rec := TRUE;
	   END IF;

            --Purchasing Attribute Group
        ELSIF ( l_Attribute_Code = 'PURCHASING_ITEM_FLAG') THEN
	   IF (NVL(l_Item_rec.PURCHASING_ITEM_FLAG,'!')  <> NVL(m_Item_rec.PURCHASING_ITEM_FLAG,'!')) THEN
              l_Item_rec.PURCHASING_ITEM_FLAG           := m_Item_rec.PURCHASING_ITEM_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PURCHASING_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.PURCHASING_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.PURCHASING_ENABLED_FLAG,'!')) THEN
              l_Item_rec.PURCHASING_ENABLED_FLAG        := m_Item_rec.PURCHASING_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MUST_USE_APPROVED_VENDOR_FLAG') THEN
	   IF (NVL(l_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG,'!')  <> NVL(m_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG,'!')) THEN
              l_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG  := m_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ALLOW_ITEM_DESC_UPDATE_FLAG') THEN
	   IF (NVL(l_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG,'!')  <> NVL(m_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG,'!')) THEN
              l_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG    := m_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RFQ_REQUIRED_FLAG') THEN
	   IF (NVL(l_Item_rec.RFQ_REQUIRED_FLAG,'!')  <> NVL(m_Item_rec.RFQ_REQUIRED_FLAG,'!')) THEN
              l_Item_rec.RFQ_REQUIRED_FLAG              := m_Item_rec.RFQ_REQUIRED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OUTSIDE_OPERATION_FLAG') THEN
	   IF (NVL(l_Item_rec.OUTSIDE_OPERATION_FLAG,'!')  <> NVL(m_Item_rec.OUTSIDE_OPERATION_FLAG,'!')) THEN
              l_Item_rec.OUTSIDE_OPERATION_FLAG         := m_Item_rec.OUTSIDE_OPERATION_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OUTSIDE_OPERATION_UOM_TYPE') THEN
	   IF (NVL(l_Item_rec.OUTSIDE_OPERATION_UOM_TYPE,'!')  <> NVL(m_Item_rec.OUTSIDE_OPERATION_UOM_TYPE,'!')) THEN
              l_Item_rec.OUTSIDE_OPERATION_UOM_TYPE     := m_Item_rec.OUTSIDE_OPERATION_UOM_TYPE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'TAXABLE_FLAG') THEN
	   IF (NVL(l_Item_rec.TAXABLE_FLAG,'!')  <> NVL(m_Item_rec.TAXABLE_FLAG,'!')) THEN
              l_Item_rec.TAXABLE_FLAG                   := m_Item_rec.TAXABLE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
       ELSIF ( l_Attribute_Code = 'PURCHASING_TAX_CODE')  THEN
	   IF (NVL(l_Item_rec.PURCHASING_TAX_CODE,'!')  <> NVL(m_Item_rec.PURCHASING_TAX_CODE,'!')) THEN
              l_Item_rec.PURCHASING_TAX_CODE            := m_Item_rec.PURCHASING_TAX_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RECEIPT_REQUIRED_FLAG') THEN
	   IF (NVL(l_Item_rec.RECEIPT_REQUIRED_FLAG,'!')  <> NVL(m_Item_rec.RECEIPT_REQUIRED_FLAG,'!')) THEN
              l_Item_rec.RECEIPT_REQUIRED_FLAG          := m_Item_rec.RECEIPT_REQUIRED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INSPECTION_REQUIRED_FLAG') THEN
	   IF (NVL(l_Item_rec.INSPECTION_REQUIRED_FLAG,'!')  <> NVL(m_Item_rec.INSPECTION_REQUIRED_FLAG,'!')) THEN
              l_Item_rec.INSPECTION_REQUIRED_FLAG       := m_Item_rec.INSPECTION_REQUIRED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'BUYER_ID') THEN
	   IF (NVL(l_Item_rec.BUYER_ID,-999999)  <> NVL(m_Item_rec.BUYER_ID,-999999)) THEN
              l_Item_rec.BUYER_ID                       := m_Item_rec.BUYER_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'UNIT_OF_ISSUE') THEN
	   IF (NVL(l_Item_rec.UNIT_OF_ISSUE,'!')  <> NVL(m_Item_rec.UNIT_OF_ISSUE,'!')) THEN
              l_Item_rec.UNIT_OF_ISSUE                  := m_Item_rec.UNIT_OF_ISSUE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RECEIVE_CLOSE_TOLERANCE') THEN
	   IF (NVL(l_Item_rec.RECEIVE_CLOSE_TOLERANCE,-999999)  <> NVL(m_Item_rec.RECEIVE_CLOSE_TOLERANCE,-999999)) THEN
              l_Item_rec.RECEIVE_CLOSE_TOLERANCE        := m_Item_rec.RECEIVE_CLOSE_TOLERANCE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INVOICE_CLOSE_TOLERANCE') THEN
	   IF (NVL(l_Item_rec.INVOICE_CLOSE_TOLERANCE,-999999)  <> NVL(m_Item_rec.INVOICE_CLOSE_TOLERANCE,-999999)) THEN
              l_Item_rec.INVOICE_CLOSE_TOLERANCE        := m_Item_rec.INVOICE_CLOSE_TOLERANCE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'UN_NUMBER_ID') THEN
	   IF (NVL(l_Item_rec.UN_NUMBER_ID,-999999)  <> NVL(m_Item_rec.UN_NUMBER_ID,-999999)) THEN
              l_Item_rec.UN_NUMBER_ID                   := m_Item_rec.UN_NUMBER_ID;
	      l_update_child_rec := TRUE;
	   END IF;
	ELSIF ( l_Attribute_Code = 'HAZARD_CLASS_ID') THEN
	   IF (NVL(l_Item_rec.HAZARD_CLASS_ID,-999999)  <> NVL(m_Item_rec.HAZARD_CLASS_ID,-999999)) THEN
              l_Item_rec.HAZARD_CLASS_ID                := m_Item_rec.HAZARD_CLASS_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LIST_PRICE_PER_UNIT') THEN
	   IF (NVL(l_Item_rec.LIST_PRICE_PER_UNIT,-999999)  <> NVL(m_Item_rec.LIST_PRICE_PER_UNIT,-999999)) THEN
              l_Item_rec.LIST_PRICE_PER_UNIT            := m_Item_rec.LIST_PRICE_PER_UNIT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MARKET_PRICE') THEN
	   IF (NVL(l_Item_rec.MARKET_PRICE,-999999)  <> NVL(m_Item_rec.MARKET_PRICE,-999999)) THEN
              l_Item_rec.MARKET_PRICE                   := m_Item_rec.MARKET_PRICE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PRICE_TOLERANCE_PERCENT') THEN
	   IF (NVL(l_Item_rec.PRICE_TOLERANCE_PERCENT,-999999)  <> NVL(m_Item_rec.PRICE_TOLERANCE_PERCENT,-999999)) THEN
              l_Item_rec.PRICE_TOLERANCE_PERCENT        := m_Item_rec.PRICE_TOLERANCE_PERCENT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ROUNDING_FACTOR') THEN
	   IF (NVL(l_Item_rec.ROUNDING_FACTOR,-999999)  <> NVL(m_Item_rec.ROUNDING_FACTOR,-999999)) THEN
              l_Item_rec.ROUNDING_FACTOR                := m_Item_rec.ROUNDING_FACTOR;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ENCUMBRANCE_ACCOUNT') THEN
	   IF (NVL(l_Item_rec.ENCUMBRANCE_ACCOUNT,-999999)  <> NVL(m_Item_rec.ENCUMBRANCE_ACCOUNT,-999999)) THEN
              l_Item_rec.ENCUMBRANCE_ACCOUNT            := m_Item_rec.ENCUMBRANCE_ACCOUNT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'EXPENSE_ACCOUNT') THEN
	   IF (NVL(l_Item_rec.EXPENSE_ACCOUNT,-999999)  <> NVL(m_Item_rec.EXPENSE_ACCOUNT,-999999)) THEN
              l_Item_rec.EXPENSE_ACCOUNT                := m_Item_rec.EXPENSE_ACCOUNT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ASSET_CATEGORY_ID') THEN
	   IF (NVL(l_Item_rec.ASSET_CATEGORY_ID,-999999)  <> NVL(m_Item_rec.ASSET_CATEGORY_ID,-999999)) THEN
              l_Item_rec.ASSET_CATEGORY_ID              := m_Item_rec.ASSET_CATEGORY_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OUTSOURCED_ASSEMBLY') THEN
	   IF (NVL(l_Item_rec.OUTSOURCED_ASSEMBLY,-999999)  <> NVL(m_Item_rec.OUTSOURCED_ASSEMBLY,-999999)) THEN
              l_Item_rec.OUTSOURCED_ASSEMBLY              := m_Item_rec.OUTSOURCED_ASSEMBLY;
	      l_update_child_rec := TRUE;
	   END IF;

             --Receiving Attribute Group
        ELSIF ( l_Attribute_Code = 'RECEIPT_DAYS_EXCEPTION_CODE') THEN
	   IF (NVL(l_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE,'!')  <> NVL(m_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE,'!')) THEN
              l_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE    := m_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DAYS_EARLY_RECEIPT_ALLOWED') THEN
	   IF (NVL(l_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED,-999999)  <> NVL(m_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED,-999999)) THEN
              l_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED     := m_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DAYS_LATE_RECEIPT_ALLOWED')  THEN
	   IF (NVL(l_Item_rec.DAYS_LATE_RECEIPT_ALLOWED,-999999)  <> NVL(m_Item_rec.DAYS_LATE_RECEIPT_ALLOWED,-999999)) THEN
              l_Item_rec.DAYS_LATE_RECEIPT_ALLOWED      := m_Item_rec.DAYS_LATE_RECEIPT_ALLOWED;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'QTY_RCV_EXCEPTION_CODE') THEN
	   IF (NVL(l_Item_rec.QTY_RCV_EXCEPTION_CODE,'!')  <> NVL(m_Item_rec.QTY_RCV_EXCEPTION_CODE,'!')) THEN
              l_Item_rec.QTY_RCV_EXCEPTION_CODE         := m_Item_rec.QTY_RCV_EXCEPTION_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'QTY_RCV_TOLERANCE')  THEN
	   IF (NVL(l_Item_rec.QTY_RCV_TOLERANCE,-999999)  <> NVL(m_Item_rec.QTY_RCV_TOLERANCE,-999999)) THEN
              l_Item_rec.QTY_RCV_TOLERANCE              := m_Item_rec.QTY_RCV_TOLERANCE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ALLOW_SUBSTITUTE_RECEIPTS_FLAG') THEN
	   IF (NVL(l_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,'!')  <> NVL(m_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,'!')) THEN
              l_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := m_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ALLOW_UNORDERED_RECEIPTS_FLAG')  THEN
	   IF (NVL(l_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG,'!')  <> NVL(m_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG,'!')) THEN
              l_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG  := m_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ALLOW_EXPRESS_DELIVERY_FLAG') THEN
	   IF (NVL(l_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG,'!')  <> NVL(m_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG,'!')) THEN
              l_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG    := m_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RECEIVING_ROUTING_ID') THEN
	   IF (NVL(l_Item_rec.RECEIVING_ROUTING_ID,-999999)  <> NVL(m_Item_rec.RECEIVING_ROUTING_ID,-999999)) THEN
              l_Item_rec.RECEIVING_ROUTING_ID           := m_Item_rec.RECEIVING_ROUTING_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ENFORCE_SHIP_TO_LOCATION_CODE') THEN
	   IF (NVL(l_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE,'!')  <> NVL(m_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE,'!')) THEN
              l_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE  := m_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE;
	      l_update_child_rec := TRUE;
	   END IF;

            --Physical Attributes
        ELSIF ( l_Attribute_Code = 'WEIGHT_UOM_CODE') THEN
	   IF (NVL(l_Item_rec.WEIGHT_UOM_CODE,'!')  <> NVL(m_Item_rec.WEIGHT_UOM_CODE,'!')) THEN
              l_Item_rec.WEIGHT_UOM_CODE                := m_Item_rec.WEIGHT_UOM_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'UNIT_WEIGHT') THEN
	   IF (NVL(l_Item_rec.UNIT_WEIGHT,-999999)  <> NVL(m_Item_rec.UNIT_WEIGHT,-999999)) THEN
              l_Item_rec.UNIT_WEIGHT                    := m_Item_rec.UNIT_WEIGHT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VOLUME_UOM_CODE') THEN
	   IF (NVL(l_Item_rec.VOLUME_UOM_CODE,'!')  <> NVL(m_Item_rec.VOLUME_UOM_CODE,'!')) THEN
              l_Item_rec.VOLUME_UOM_CODE                := m_Item_rec.VOLUME_UOM_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'UNIT_VOLUME') THEN
	   IF (NVL(l_Item_rec.UNIT_VOLUME,-999999)  <> NVL(m_Item_rec.UNIT_VOLUME,-999999)) THEN
              l_Item_rec.UNIT_VOLUME                    := m_Item_rec.UNIT_VOLUME;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CONTAINER_ITEM_FLAG') THEN
	   IF (NVL(l_Item_rec.CONTAINER_ITEM_FLAG,'!')  <> NVL(m_Item_rec.CONTAINER_ITEM_FLAG,'!')) THEN
              l_Item_rec.CONTAINER_ITEM_FLAG            := m_Item_rec.CONTAINER_ITEM_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VEHICLE_ITEM_FLAG') THEN
	   IF (NVL(l_Item_rec.VEHICLE_ITEM_FLAG,'!')  <> NVL(m_Item_rec.VEHICLE_ITEM_FLAG,'!')) THEN
              l_Item_rec.VEHICLE_ITEM_FLAG              := m_Item_rec.VEHICLE_ITEM_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CONTAINER_TYPE_CODE') THEN
	   IF (NVL(l_Item_rec.CONTAINER_TYPE_CODE,'!')  <> NVL(m_Item_rec.CONTAINER_TYPE_CODE,'!')) THEN
	      l_Item_rec.CONTAINER_TYPE_CODE            := m_Item_rec.CONTAINER_TYPE_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INTERNAL_VOLUME') THEN
	   IF (NVL(l_Item_rec.INTERNAL_VOLUME,-999999)  <> NVL(m_Item_rec.INTERNAL_VOLUME,-999999)) THEN
              l_Item_rec.INTERNAL_VOLUME                := m_Item_rec.INTERNAL_VOLUME;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MAXIMUM_LOAD_WEIGHT') THEN
	   IF (NVL(l_Item_rec.MAXIMUM_LOAD_WEIGHT,-999999)  <> NVL(m_Item_rec.MAXIMUM_LOAD_WEIGHT,-999999)) THEN
              l_Item_rec.MAXIMUM_LOAD_WEIGHT            := m_Item_rec.MAXIMUM_LOAD_WEIGHT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MINIMUM_FILL_PERCENT') THEN
	   IF (NVL(l_Item_rec.MINIMUM_FILL_PERCENT,-999999)  <> NVL(m_Item_rec.MINIMUM_FILL_PERCENT,-999999)) THEN
              l_Item_rec.MINIMUM_FILL_PERCENT           := m_Item_rec.MINIMUM_FILL_PERCENT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DIMENSION_UOM_CODE') THEN
	   IF (NVL(l_Item_rec.DIMENSION_UOM_CODE,'!')  <> NVL(m_Item_rec.DIMENSION_UOM_CODE,'!')) THEN
              l_Item_rec.DIMENSION_UOM_CODE := m_Item_rec.DIMENSION_UOM_CODE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'UNIT_LENGTH') THEN
	   IF (NVL(l_Item_rec.UNIT_LENGTH,-999999)  <> NVL(m_Item_rec.UNIT_LENGTH,-999999)) THEN
              l_Item_rec.UNIT_LENGTH := m_Item_rec.UNIT_LENGTH ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'UNIT_WIDTH') THEN
	   IF (NVL(l_Item_rec.UNIT_WIDTH,-999999)  <> NVL(m_Item_rec.UNIT_WIDTH,-999999)) THEN
              l_Item_rec.UNIT_WIDTH := m_Item_rec.UNIT_WIDTH ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'UNIT_HEIGHT') THEN
	   IF (NVL(l_Item_rec.UNIT_HEIGHT,-999999)  <> NVL(m_Item_rec.UNIT_HEIGHT,-999999)) THEN
              l_Item_rec.UNIT_HEIGHT := m_Item_rec.UNIT_HEIGHT ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'COLLATERAL_FLAG') THEN
	   IF (NVL(l_Item_rec.COLLATERAL_FLAG,'!')  <> NVL(m_Item_rec.COLLATERAL_FLAG,'!')) THEN
              l_Item_rec.COLLATERAL_FLAG                := m_Item_rec.COLLATERAL_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'EVENT_FLAG') THEN
	   IF (NVL(l_Item_rec.EVENT_FLAG,'!')  <> NVL(m_Item_rec.EVENT_FLAG,'!')) THEN
              l_Item_rec.EVENT_FLAG := m_Item_rec.EVENT_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'EQUIPMENT_TYPE') THEN
	   IF (NVL(l_Item_rec.EQUIPMENT_TYPE,-999999)  <> NVL(m_Item_rec.EQUIPMENT_TYPE,-999999)) THEN
              l_Item_rec.EQUIPMENT_TYPE := m_Item_rec.EQUIPMENT_TYPE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ELECTRONIC_FLAG') THEN
	   IF (NVL(l_Item_rec.ELECTRONIC_FLAG,'!')  <> NVL(m_Item_rec.ELECTRONIC_FLAG,'!')) THEN
              l_Item_rec.ELECTRONIC_FLAG := m_Item_rec.ELECTRONIC_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DOWNLOADABLE_FLAG') THEN
	   IF (NVL(l_Item_rec.DOWNLOADABLE_FLAG,'!')  <> NVL(m_Item_rec.DOWNLOADABLE_FLAG,'!')) THEN
              l_Item_rec.DOWNLOADABLE_FLAG := m_Item_rec.DOWNLOADABLE_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INDIVISIBLE_FLAG') THEN
	   IF (NVL(l_Item_rec.INDIVISIBLE_FLAG,'!')  <> NVL(m_Item_rec.INDIVISIBLE_FLAG,'!')) THEN
              l_Item_rec.INDIVISIBLE_FLAG := m_Item_rec.INDIVISIBLE_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;

            --General Planning
        ELSIF ( l_Attribute_Code = 'INVENTORY_PLANNING_CODE') THEN
	   IF (NVL(l_Item_rec.INVENTORY_PLANNING_CODE,-999999)  <> NVL(m_Item_rec.INVENTORY_PLANNING_CODE,-999999)) THEN
              l_Item_rec.INVENTORY_PLANNING_CODE        := m_Item_rec.INVENTORY_PLANNING_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PLANNER_CODE') THEN
	   IF (NVL(l_Item_rec.PLANNER_CODE,'!')  <> NVL(m_Item_rec.PLANNER_CODE,'!')) THEN
              l_Item_rec.PLANNER_CODE                   := m_Item_rec.PLANNER_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PLANNING_MAKE_BUY_CODE') THEN
	   IF (NVL(l_Item_rec.PLANNING_MAKE_BUY_CODE,-999999)  <> NVL(m_Item_rec.PLANNING_MAKE_BUY_CODE,-999999)) THEN
              l_Item_rec.PLANNING_MAKE_BUY_CODE         := m_Item_rec.PLANNING_MAKE_BUY_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MIN_MINMAX_QUANTITY') THEN
	   IF (NVL(l_Item_rec.MIN_MINMAX_QUANTITY,-999999)  <> NVL(m_Item_rec.MIN_MINMAX_QUANTITY,-999999)) THEN
              l_Item_rec.MIN_MINMAX_QUANTITY            := m_Item_rec.MIN_MINMAX_QUANTITY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MAX_MINMAX_QUANTITY') THEN
	   IF (NVL(l_Item_rec.MAX_MINMAX_QUANTITY,-999999)  <> NVL(m_Item_rec.MAX_MINMAX_QUANTITY,-999999)) THEN
              l_Item_rec.MAX_MINMAX_QUANTITY            := m_Item_rec.MAX_MINMAX_QUANTITY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MINIMUM_ORDER_QUANTITY') THEN
	   IF (NVL(l_Item_rec.MINIMUM_ORDER_QUANTITY,-999999)  <> NVL(m_Item_rec.MINIMUM_ORDER_QUANTITY,-999999)) THEN
              l_Item_rec.MINIMUM_ORDER_QUANTITY         := m_Item_rec.MINIMUM_ORDER_QUANTITY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MAXIMUM_ORDER_QUANTITY') THEN
	   IF (NVL(l_Item_rec.MAXIMUM_ORDER_QUANTITY,-999999)  <> NVL(m_Item_rec.MAXIMUM_ORDER_QUANTITY,-999999)) THEN
              l_Item_rec.MAXIMUM_ORDER_QUANTITY         := m_Item_rec.MAXIMUM_ORDER_QUANTITY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ORDER_COST') THEN
	   IF (NVL(l_Item_rec.ORDER_COST,-999999)  <> NVL(m_Item_rec.ORDER_COST,-999999)) THEN
              l_Item_rec.ORDER_COST                     := m_Item_rec.ORDER_COST;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CARRYING_COST') THEN
	   IF (NVL(l_Item_rec.CARRYING_COST,-999999)  <> NVL(m_Item_rec.CARRYING_COST,-999999)) THEN
              l_Item_rec.CARRYING_COST                  := m_Item_rec.CARRYING_COST;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VMI_MINIMUM_UNITS') THEN
	   IF (NVL(l_Item_rec.VMI_MINIMUM_UNITS,-999999)  <> NVL(m_Item_rec.VMI_MINIMUM_UNITS,-999999)) THEN
              l_Item_rec.VMI_MINIMUM_UNITS                       := m_Item_rec.VMI_MINIMUM_UNITS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VMI_MINIMUM_DAYS') THEN
	   IF (NVL(l_Item_rec.VMI_MINIMUM_DAYS,-999999)  <> NVL(m_Item_rec.VMI_MINIMUM_DAYS,-999999)) THEN
              l_Item_rec.VMI_MINIMUM_DAYS                       := m_Item_rec.VMI_MINIMUM_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VMI_MAXIMUM_UNITS') THEN
	   IF (NVL(l_Item_rec.VMI_MAXIMUM_UNITS,-999999)  <> NVL(m_Item_rec.VMI_MAXIMUM_UNITS,-999999)) THEN
              l_Item_rec.VMI_MAXIMUM_UNITS                       := m_Item_rec.VMI_MAXIMUM_UNITS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VMI_MAXIMUM_DAYS') THEN
	   IF (NVL(l_Item_rec.VMI_MAXIMUM_DAYS,-999999)  <> NVL(m_Item_rec.VMI_MAXIMUM_DAYS,-999999)) THEN
              l_Item_rec.VMI_MAXIMUM_DAYS                       := m_Item_rec.VMI_MAXIMUM_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VMI_FIXED_ORDER_QUANTITY') THEN
	   IF (NVL(l_Item_rec.VMI_FIXED_ORDER_QUANTITY,-999999)  <> NVL(m_Item_rec.VMI_FIXED_ORDER_QUANTITY,-999999)) THEN
              l_Item_rec.VMI_FIXED_ORDER_QUANTITY               := m_Item_rec.VMI_FIXED_ORDER_QUANTITY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SO_AUTHORIZATION_FLAG') THEN
	   IF (NVL(l_Item_rec.SO_AUTHORIZATION_FLAG,-999999)  <> NVL(m_Item_rec.SO_AUTHORIZATION_FLAG,-999999)) THEN
              l_Item_rec.SO_AUTHORIZATION_FLAG                       := m_Item_rec.SO_AUTHORIZATION_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CONSIGNED_FLAG')  THEN
	   IF (NVL(l_Item_rec.CONSIGNED_FLAG,-999999)  <> NVL(m_Item_rec.CONSIGNED_FLAG,-999999)) THEN
              l_Item_rec.CONSIGNED_FLAG                       := m_Item_rec.CONSIGNED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ASN_AUTOEXPIRE_FLAG')  THEN
	   IF (NVL(l_Item_rec.ASN_AUTOEXPIRE_FLAG,-999999)  <> NVL(m_Item_rec.ASN_AUTOEXPIRE_FLAG,-999999)) THEN
              l_Item_rec.ASN_AUTOEXPIRE_FLAG                       := m_Item_rec.ASN_AUTOEXPIRE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VMI_FORECAST_TYPE') THEN
	   IF (NVL(l_Item_rec.VMI_FORECAST_TYPE,-999999)  <> NVL(m_Item_rec.VMI_FORECAST_TYPE,-999999)) THEN
              l_Item_rec.VMI_FORECAST_TYPE                       := m_Item_rec.VMI_FORECAST_TYPE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'FORECAST_HORIZON') THEN
	   IF (NVL(l_Item_rec.FORECAST_HORIZON,-999999)  <> NVL(m_Item_rec.FORECAST_HORIZON,-999999)) THEN
              l_Item_rec.FORECAST_HORIZON                       := m_Item_rec.FORECAST_HORIZON;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SOURCE_TYPE') THEN
	   IF (NVL(l_Item_rec.SOURCE_TYPE,-999999)  <> NVL(m_Item_rec.SOURCE_TYPE,-999999)) THEN
              l_Item_rec.SOURCE_TYPE                    := m_Item_rec.SOURCE_TYPE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SOURCE_ORGANIZATION_ID') THEN
	   IF (NVL(l_Item_rec.SOURCE_ORGANIZATION_ID,-999999)  <> NVL(m_Item_rec.SOURCE_ORGANIZATION_ID,-999999)) THEN
              l_Item_rec.SOURCE_ORGANIZATION_ID         := m_Item_rec.SOURCE_ORGANIZATION_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SOURCE_SUBINVENTORY') THEN
	   IF (NVL(l_Item_rec.SOURCE_SUBINVENTORY,'!')  <> NVL(m_Item_rec.SOURCE_SUBINVENTORY,'!')) THEN
              l_Item_rec.SOURCE_SUBINVENTORY            := m_Item_rec.SOURCE_SUBINVENTORY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MRP_SAFETY_STOCK_CODE') THEN
	   IF (NVL(l_Item_rec.MRP_SAFETY_STOCK_CODE,-999999)  <> NVL(m_Item_rec.MRP_SAFETY_STOCK_CODE,-999999)) THEN
              l_Item_rec.MRP_SAFETY_STOCK_CODE          := m_Item_rec.MRP_SAFETY_STOCK_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SAFETY_STOCK_BUCKET_DAYS') THEN
	   IF (NVL(l_Item_rec.SAFETY_STOCK_BUCKET_DAYS,-999999)  <> NVL(m_Item_rec.SAFETY_STOCK_BUCKET_DAYS,-999999)) THEN
              l_Item_rec.SAFETY_STOCK_BUCKET_DAYS       := m_Item_rec.SAFETY_STOCK_BUCKET_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MRP_SAFETY_STOCK_PERCENT') THEN
	   IF (NVL(l_Item_rec.MRP_SAFETY_STOCK_PERCENT,-999999)  <> NVL(m_Item_rec.MRP_SAFETY_STOCK_PERCENT,-999999)) THEN
              l_Item_rec.MRP_SAFETY_STOCK_PERCENT       := m_Item_rec.MRP_SAFETY_STOCK_PERCENT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'FIXED_ORDER_QUANTITY') THEN
	   IF (NVL(l_Item_rec.FIXED_ORDER_QUANTITY,-999999)  <> NVL(m_Item_rec.FIXED_ORDER_QUANTITY,-999999)) THEN
              l_Item_rec.FIXED_ORDER_QUANTITY           := m_Item_rec.FIXED_ORDER_QUANTITY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'FIXED_LOT_MULTIPLIER') THEN
	   IF (NVL(l_Item_rec.FIXED_LOT_MULTIPLIER,-999999)  <> NVL(m_Item_rec.FIXED_LOT_MULTIPLIER,-999999)) THEN
              l_Item_rec.FIXED_LOT_MULTIPLIER           := m_Item_rec.FIXED_LOT_MULTIPLIER;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'FIXED_DAYS_SUPPLY') THEN
	   IF (NVL(l_Item_rec.FIXED_DAYS_SUPPLY,-999999)  <> NVL(m_Item_rec.FIXED_DAYS_SUPPLY,-999999)) THEN
              l_Item_rec.FIXED_DAYS_SUPPLY              := m_Item_rec.FIXED_DAYS_SUPPLY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SUBCONTRACTING_COMPONENT') THEN   --Bug: 5396073
	   IF (NVL(l_Item_rec.SUBCONTRACTING_COMPONENT,-999999)  <> NVL(m_Item_rec.SUBCONTRACTING_COMPONENT,-999999)) THEN
              l_Item_rec.SUBCONTRACTING_COMPONENT              := m_Item_rec.SUBCONTRACTING_COMPONENT;
	      l_update_child_rec := TRUE;
	   END IF;

            --MPS/MRP Planning
        ELSIF ( l_Attribute_Code = 'MRP_PLANNING_CODE') THEN
	   IF (NVL(l_Item_rec.MRP_PLANNING_CODE,-999999)  <> NVL(m_Item_rec.MRP_PLANNING_CODE,-999999)) THEN
              l_Item_rec.MRP_PLANNING_CODE              := m_Item_rec.MRP_PLANNING_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ATO_FORECAST_CONTROL')  THEN
	   IF (NVL(l_Item_rec.ATO_FORECAST_CONTROL,-999999)  <> NVL(m_Item_rec.ATO_FORECAST_CONTROL,-999999)) THEN
              l_Item_rec.ATO_FORECAST_CONTROL           := m_Item_rec.ATO_FORECAST_CONTROL;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PLANNING_EXCEPTION_SET') THEN
	   IF (NVL(l_Item_rec.PLANNING_EXCEPTION_SET,'!')  <> NVL(m_Item_rec.PLANNING_EXCEPTION_SET,'!')) THEN
              l_Item_rec.PLANNING_EXCEPTION_SET         := m_Item_rec.PLANNING_EXCEPTION_SET;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'END_ASSEMBLY_PEGGING_FLAG') THEN
	   IF (NVL(l_Item_rec.END_ASSEMBLY_PEGGING_FLAG,'!')  <> NVL(m_Item_rec.END_ASSEMBLY_PEGGING_FLAG,'!')) THEN
              l_Item_rec.END_ASSEMBLY_PEGGING_FLAG      := m_Item_rec.END_ASSEMBLY_PEGGING_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PLANNED_INV_POINT_FLAG') THEN
	   IF (NVL(l_Item_rec.PLANNED_INV_POINT_FLAG,'!')  <> NVL(m_Item_rec.PLANNED_INV_POINT_FLAG,'!')) THEN
              l_Item_rec.PLANNED_INV_POINT_FLAG     :=  m_Item_rec.PLANNED_INV_POINT_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CREATE_SUPPLY_FLAG') THEN
	   IF (NVL(l_Item_rec.CREATE_SUPPLY_FLAG,'!')  <> NVL(m_Item_rec.CREATE_SUPPLY_FLAG,'!')) THEN
              l_Item_rec.CREATE_SUPPLY_FLAG         :=  m_Item_rec.CREATE_SUPPLY_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'EXCLUDE_FROM_BUDGET_FLAG')   THEN
	   IF (NVL(l_Item_rec.EXCLUDE_FROM_BUDGET_FLAG,-999999)  <> NVL(m_Item_rec.EXCLUDE_FROM_BUDGET_FLAG,-999999)) THEN
              l_Item_rec.EXCLUDE_FROM_BUDGET_FLAG                       := m_Item_rec.EXCLUDE_FROM_BUDGET_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ROUNDING_CONTROL_TYPE')  THEN
	   IF (NVL(l_Item_rec.ROUNDING_CONTROL_TYPE,-999999)  <> NVL(m_Item_rec.ROUNDING_CONTROL_TYPE,-999999)) THEN
              l_Item_rec.ROUNDING_CONTROL_TYPE          := m_Item_rec.ROUNDING_CONTROL_TYPE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SHRINKAGE_RATE') THEN
	   IF (NVL(l_Item_rec.SHRINKAGE_RATE,-999999)  <> NVL(m_Item_rec.SHRINKAGE_RATE,-999999)) THEN
              l_Item_rec.SHRINKAGE_RATE                 := m_Item_rec.SHRINKAGE_RATE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ACCEPTABLE_EARLY_DAYS') THEN
	   IF (NVL(l_Item_rec.ACCEPTABLE_EARLY_DAYS,-999999)  <> NVL(m_Item_rec.ACCEPTABLE_EARLY_DAYS,-999999)) THEN
              l_Item_rec.ACCEPTABLE_EARLY_DAYS          := m_Item_rec.ACCEPTABLE_EARLY_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'REPETITIVE_PLANNING_FLAG') THEN
	   IF (NVL(l_Item_rec.REPETITIVE_PLANNING_FLAG,'!')  <> NVL(m_Item_rec.REPETITIVE_PLANNING_FLAG,'!')) THEN
              l_Item_rec.REPETITIVE_PLANNING_FLAG       := m_Item_rec.REPETITIVE_PLANNING_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OVERRUN_PERCENTAGE') THEN
	   IF (NVL(l_Item_rec.OVERRUN_PERCENTAGE,-999999)  <> NVL(m_Item_rec.OVERRUN_PERCENTAGE,-999999)) THEN
              l_Item_rec.OVERRUN_PERCENTAGE             := m_Item_rec.OVERRUN_PERCENTAGE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ACCEPTABLE_RATE_INCREASE') THEN
	   IF (NVL(l_Item_rec.ACCEPTABLE_RATE_INCREASE,-999999)  <> NVL(m_Item_rec.ACCEPTABLE_RATE_INCREASE,-999999)) THEN
              l_Item_rec.ACCEPTABLE_RATE_INCREASE       := m_Item_rec.ACCEPTABLE_RATE_INCREASE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ACCEPTABLE_RATE_DECREASE')  THEN
	   IF (NVL(l_Item_rec.ACCEPTABLE_RATE_DECREASE,-999999)  <> NVL(m_Item_rec.ACCEPTABLE_RATE_DECREASE,-999999)) THEN
              l_Item_rec.ACCEPTABLE_RATE_DECREASE       := m_Item_rec.ACCEPTABLE_RATE_DECREASE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MRP_CALCULATE_ATP_FLAG') THEN
	   IF (NVL(l_Item_rec.MRP_CALCULATE_ATP_FLAG,'!')  <> NVL(m_Item_rec.MRP_CALCULATE_ATP_FLAG,'!')) THEN
              l_Item_rec.MRP_CALCULATE_ATP_FLAG         := m_Item_rec.MRP_CALCULATE_ATP_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'AUTO_REDUCE_MPS')  THEN
	   IF (NVL(l_Item_rec.AUTO_REDUCE_MPS,-999999)  <> NVL(m_Item_rec.AUTO_REDUCE_MPS,-999999)) THEN
              l_Item_rec.AUTO_REDUCE_MPS                := m_Item_rec.AUTO_REDUCE_MPS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PLANNING_TIME_FENCE_CODE') THEN
	   IF (NVL(l_Item_rec.PLANNING_TIME_FENCE_CODE,-999999)  <> NVL(m_Item_rec.PLANNING_TIME_FENCE_CODE,-999999)) THEN
              l_Item_rec.PLANNING_TIME_FENCE_CODE       := m_Item_rec.PLANNING_TIME_FENCE_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PLANNING_TIME_FENCE_DAYS') THEN
	   IF (NVL(l_Item_rec.PLANNING_TIME_FENCE_DAYS,-999999)  <> NVL(m_Item_rec.PLANNING_TIME_FENCE_DAYS,-999999)) THEN
              l_Item_rec.PLANNING_TIME_FENCE_DAYS       := m_Item_rec.PLANNING_TIME_FENCE_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DEMAND_TIME_FENCE_CODE') THEN
	   IF (NVL(l_Item_rec.DEMAND_TIME_FENCE_CODE,-999999)  <> NVL(m_Item_rec.DEMAND_TIME_FENCE_CODE,-999999)) THEN
              l_Item_rec.DEMAND_TIME_FENCE_CODE         := m_Item_rec.DEMAND_TIME_FENCE_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DEMAND_TIME_FENCE_DAYS') THEN
	   IF (NVL(l_Item_rec.DEMAND_TIME_FENCE_DAYS,-999999)  <> NVL(m_Item_rec.DEMAND_TIME_FENCE_DAYS,-999999)) THEN
              l_Item_rec.DEMAND_TIME_FENCE_DAYS         := m_Item_rec.DEMAND_TIME_FENCE_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RELEASE_TIME_FENCE_CODE') THEN
	   IF (NVL(l_Item_rec.RELEASE_TIME_FENCE_CODE,-999999)  <> NVL(m_Item_rec.RELEASE_TIME_FENCE_CODE,-999999)) THEN
              l_Item_rec.RELEASE_TIME_FENCE_CODE        := m_Item_rec.RELEASE_TIME_FENCE_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RELEASE_TIME_FENCE_DAYS') THEN
	   IF (NVL(l_Item_rec.RELEASE_TIME_FENCE_DAYS,-999999)  <> NVL(m_Item_rec.RELEASE_TIME_FENCE_DAYS,-999999)) THEN
              l_Item_rec.RELEASE_TIME_FENCE_DAYS        := m_Item_rec.RELEASE_TIME_FENCE_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SUBSTITUTION_WINDOW_CODE') THEN
	   IF (NVL(l_Item_rec.SUBSTITUTION_WINDOW_CODE,-999999)  <> NVL(m_Item_rec.SUBSTITUTION_WINDOW_CODE,-999999)) THEN
              l_Item_rec.SUBSTITUTION_WINDOW_CODE   :=  m_Item_rec.SUBSTITUTION_WINDOW_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SUBSTITUTION_WINDOW_DAYS') THEN
	   IF (NVL(l_Item_rec.SUBSTITUTION_WINDOW_DAYS,-999999)  <> NVL(m_Item_rec.SUBSTITUTION_WINDOW_DAYS,-999999)) THEN
              l_Item_rec.SUBSTITUTION_WINDOW_DAYS   :=  m_Item_rec.SUBSTITUTION_WINDOW_DAYS;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DAYS_TGT_INV_SUPPLY') THEN
	   IF (NVL(l_Item_rec.DAYS_TGT_INV_SUPPLY,-999999)  <> NVL(m_Item_rec.DAYS_TGT_INV_SUPPLY,-999999)) THEN
              l_Item_rec.DAYS_TGT_INV_SUPPLY                       := m_Item_rec.DAYS_TGT_INV_SUPPLY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DAYS_TGT_INV_WINDOW') THEN
	   IF (NVL(l_Item_rec.DAYS_TGT_INV_WINDOW,-999999)  <> NVL(m_Item_rec.DAYS_TGT_INV_WINDOW,-999999)) THEN
              l_Item_rec.DAYS_TGT_INV_WINDOW                       := m_Item_rec.DAYS_TGT_INV_WINDOW;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DAYS_MAX_INV_SUPPLY')  THEN
	   IF (NVL(l_Item_rec.DAYS_MAX_INV_SUPPLY,-999999)  <> NVL(m_Item_rec.DAYS_MAX_INV_SUPPLY,-999999)) THEN
              l_Item_rec.DAYS_MAX_INV_SUPPLY                       := m_Item_rec.DAYS_MAX_INV_SUPPLY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DAYS_MAX_INV_WINDOW') THEN
	   IF (NVL(l_Item_rec.DAYS_MAX_INV_WINDOW,-999999)  <> NVL(m_Item_rec.DAYS_MAX_INV_WINDOW,-999999)) THEN
              l_Item_rec.DAYS_MAX_INV_WINDOW                       := m_Item_rec.DAYS_MAX_INV_WINDOW;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CRITICAL_COMPONENT_FLAG') THEN
	   IF (NVL(l_Item_rec.CRITICAL_COMPONENT_FLAG,-999999)  <> NVL(m_Item_rec.CRITICAL_COMPONENT_FLAG,-999999)) THEN
              l_Item_rec.CRITICAL_COMPONENT_FLAG                       := m_Item_rec.CRITICAL_COMPONENT_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CONTINOUS_TRANSFER') THEN
	   IF (NVL(l_Item_rec.CONTINOUS_TRANSFER,-999999)  <> NVL(m_Item_rec.CONTINOUS_TRANSFER,-999999)) THEN
              l_Item_rec.CONTINOUS_TRANSFER                       := m_Item_rec.CONTINOUS_TRANSFER;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CONVERGENCE') THEN
	   IF (NVL(l_Item_rec.CONVERGENCE,-999999)  <> NVL(m_Item_rec.CONVERGENCE,-999999)) THEN
              l_Item_rec.CONVERGENCE                       := m_Item_rec.CONVERGENCE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DIVERGENCE') THEN
	   IF (NVL(l_Item_rec.DIVERGENCE,-999999)  <> NVL(m_Item_rec.DIVERGENCE,-999999)) THEN
              l_Item_rec.DIVERGENCE                        := m_Item_rec.DIVERGENCE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DRP_PLANNED_FLAG') THEN
	   IF (NVL(l_Item_rec.DRP_PLANNED_FLAG,-999999)  <> NVL(m_Item_rec.DRP_PLANNED_FLAG,-999999)) THEN
              l_Item_rec.DRP_PLANNED_FLAG                       := m_Item_rec.DRP_PLANNED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'REPAIR_LEADTIME') THEN   --Bug: 5396073
	   IF (NVL(l_Item_rec.REPAIR_LEADTIME,-999999)  <> NVL(m_Item_rec.REPAIR_LEADTIME,-999999)) THEN
              l_Item_rec.REPAIR_LEADTIME                       := m_Item_rec.REPAIR_LEADTIME;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'REPAIR_YIELD') THEN   --Bug: 5396073
	   IF (NVL(l_Item_rec.REPAIR_YIELD,-999999)  <> NVL(m_Item_rec.REPAIR_YIELD,-999999)) THEN
              l_Item_rec.REPAIR_YIELD                       := m_Item_rec.REPAIR_YIELD;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PREPOSITION_POINT') THEN   --Bug: 5396073
	   IF (NVL(l_Item_rec.PREPOSITION_POINT,'!')  <> NVL(m_Item_rec.PREPOSITION_POINT,'!')) THEN
              l_Item_rec.PREPOSITION_POINT                       := m_Item_rec.PREPOSITION_POINT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'REPAIR_PROGRAM') THEN   --Bug: 5396073
	   IF (NVL(l_Item_rec.REPAIR_PROGRAM,-999999)  <> NVL(m_Item_rec.REPAIR_PROGRAM,-999999)) THEN
              l_Item_rec.REPAIR_PROGRAM                       := m_Item_rec.REPAIR_PROGRAM;
	      l_update_child_rec := TRUE;
	   END IF;

            --Lead Times
        ELSIF ( l_Attribute_Code = 'PREPROCESSING_LEAD_TIME') THEN
	   IF (NVL(l_Item_rec.PREPROCESSING_LEAD_TIME,-999999)  <> NVL(m_Item_rec.PREPROCESSING_LEAD_TIME,-999999)) THEN
              l_Item_rec.PREPROCESSING_LEAD_TIME        := m_Item_rec.PREPROCESSING_LEAD_TIME;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'FULL_LEAD_TIME') THEN
	   IF (NVL(l_Item_rec.FULL_LEAD_TIME,-999999)  <> NVL(m_Item_rec.FULL_LEAD_TIME,-999999)) THEN
              l_Item_rec.FULL_LEAD_TIME                 := m_Item_rec.FULL_LEAD_TIME ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'POSTPROCESSING_LEAD_TIME') THEN
	   IF (NVL(l_Item_rec.POSTPROCESSING_LEAD_TIME,-999999)  <> NVL(m_Item_rec.POSTPROCESSING_LEAD_TIME,-999999)) THEN
              l_Item_rec.POSTPROCESSING_LEAD_TIME       := m_Item_rec.POSTPROCESSING_LEAD_TIME;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'FIXED_LEAD_TIME') THEN
	   IF (NVL(l_Item_rec.FIXED_LEAD_TIME,-999999)  <> NVL(m_Item_rec.FIXED_LEAD_TIME,-999999)) THEN
              l_Item_rec.FIXED_LEAD_TIME                := m_Item_rec.FIXED_LEAD_TIME;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VARIABLE_LEAD_TIME') THEN
	   IF (NVL(l_Item_rec.VARIABLE_LEAD_TIME,-999999)  <> NVL(m_Item_rec.VARIABLE_LEAD_TIME,-999999)) THEN
              l_Item_rec.VARIABLE_LEAD_TIME             := m_Item_rec.VARIABLE_LEAD_TIME             ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CUM_MANUFACTURING_LEAD_TIME') THEN
	   IF (NVL(l_Item_rec.CUM_MANUFACTURING_LEAD_TIME,-999999)  <> NVL(m_Item_rec.CUM_MANUFACTURING_LEAD_TIME,-999999)) THEN
              l_Item_rec.CUM_MANUFACTURING_LEAD_TIME    := m_Item_rec.CUM_MANUFACTURING_LEAD_TIME    ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CUMULATIVE_TOTAL_LEAD_TIME')  THEN
	   IF (NVL(l_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME,-999999)  <> NVL(m_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME,-999999)) THEN
              l_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME     := m_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'LEAD_TIME_LOT_SIZE') THEN
	   IF (NVL(l_Item_rec.LEAD_TIME_LOT_SIZE,-999999)  <> NVL(m_Item_rec.LEAD_TIME_LOT_SIZE,-999999)) THEN
              l_Item_rec.LEAD_TIME_LOT_SIZE             := m_Item_rec.LEAD_TIME_LOT_SIZE;
	      l_update_child_rec := TRUE;
	   END IF;

	    --Work In Progress
        ELSIF ( l_Attribute_Code = 'BUILD_IN_WIP_FLAG') THEN
	   IF (NVL(l_Item_rec.BUILD_IN_WIP_FLAG,'!')  <> NVL(m_Item_rec.BUILD_IN_WIP_FLAG,'!')) THEN
              l_Item_rec.BUILD_IN_WIP_FLAG              := m_Item_rec.BUILD_IN_WIP_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'WIP_SUPPLY_TYPE') THEN
	   IF (NVL(l_Item_rec.WIP_SUPPLY_TYPE,-999999)  <> NVL(m_Item_rec.WIP_SUPPLY_TYPE,-999999)) THEN
              l_Item_rec.WIP_SUPPLY_TYPE                := m_Item_rec.WIP_SUPPLY_TYPE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'WIP_SUPPLY_SUBINVENTORY')  THEN
	   IF (NVL(l_Item_rec.WIP_SUPPLY_SUBINVENTORY,'!')  <> NVL(m_Item_rec.WIP_SUPPLY_SUBINVENTORY,'!')) THEN
             l_Item_rec.WIP_SUPPLY_SUBINVENTORY        := m_Item_rec.WIP_SUPPLY_SUBINVENTORY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'WIP_SUPPLY_LOCATOR_ID') THEN
	   IF (NVL(l_Item_rec.WIP_SUPPLY_LOCATOR_ID,-999999)  <> NVL(m_Item_rec.WIP_SUPPLY_LOCATOR_ID,-999999)) THEN
              l_Item_rec.WIP_SUPPLY_LOCATOR_ID          := m_Item_rec.WIP_SUPPLY_LOCATOR_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OVERCOMPLETION_TOLERANCE_TYPE') THEN
	   IF (NVL(l_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE,-999999)  <> NVL(m_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE,-999999) ) THEN
              l_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE  := m_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE  ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OVERCOMPLETION_TOLERANCE_VALUE') THEN
	   IF (NVL(l_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE,-999999)  <> NVL(m_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE,-999999)) THEN
              l_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE := m_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INVENTORY_CARRY_PENALTY') THEN
	   IF (NVL(l_Item_rec.INVENTORY_CARRY_PENALTY,-999999)  <> NVL(m_Item_rec.INVENTORY_CARRY_PENALTY,-999999)) THEN
              l_Item_rec.INVENTORY_CARRY_PENALTY := m_Item_rec.INVENTORY_CARRY_PENALTY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OPERATION_SLACK_PENALTY') THEN
	   IF (NVL(l_Item_rec.OPERATION_SLACK_PENALTY,-999999)  <> NVL(m_Item_rec.OPERATION_SLACK_PENALTY,-999999)) THEN
              l_Item_rec.OPERATION_SLACK_PENALTY := m_Item_rec.OPERATION_SLACK_PENALTY;
	      l_update_child_rec := TRUE;
	   END IF;

            --Order Management
        ELSIF ( l_Attribute_Code = 'CUSTOMER_ORDER_FLAG') THEN
	   IF (NVL(l_Item_rec.CUSTOMER_ORDER_FLAG,'!')  <> NVL(m_Item_rec.CUSTOMER_ORDER_FLAG,'!')) THEN
              l_Item_rec.CUSTOMER_ORDER_FLAG            := m_Item_rec.CUSTOMER_ORDER_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CUSTOMER_ORDER_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG,'!')) THEN
              l_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG    := m_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INTERNAL_ORDER_FLAG') THEN
	   IF (NVL(l_Item_rec.INTERNAL_ORDER_FLAG,'!')  <> NVL(m_Item_rec.INTERNAL_ORDER_FLAG,'!')) THEN
              l_Item_rec.INTERNAL_ORDER_FLAG            := m_Item_rec.INTERNAL_ORDER_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INTERNAL_ORDER_ENABLED_FLAG') THEN
	    IF (NVL(l_Item_rec.INTERNAL_ORDER_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.INTERNAL_ORDER_ENABLED_FLAG,'!')) THEN
              l_Item_rec.INTERNAL_ORDER_ENABLED_FLAG    := m_Item_rec.INTERNAL_ORDER_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SHIPPABLE_ITEM_FLAG') THEN
	   IF (NVL(l_Item_rec.SHIPPABLE_ITEM_FLAG,'!')  <> NVL(m_Item_rec.SHIPPABLE_ITEM_FLAG,'!')) THEN
              l_Item_rec.SHIPPABLE_ITEM_FLAG            := m_Item_rec.SHIPPABLE_ITEM_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SO_TRANSACTIONS_FLAG') THEN
	   IF (NVL(l_Item_rec.SO_TRANSACTIONS_FLAG,'!')  <> NVL(m_Item_rec.SO_TRANSACTIONS_FLAG,'!')) THEN
              l_Item_rec.SO_TRANSACTIONS_FLAG           := m_Item_rec.SO_TRANSACTIONS_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DEFAULT_SHIPPING_ORG') THEN
	   IF (NVL(l_Item_rec.DEFAULT_SHIPPING_ORG,-999999)  <> NVL(m_Item_rec.DEFAULT_SHIPPING_ORG,-999999)) THEN
              l_Item_rec.DEFAULT_SHIPPING_ORG           := m_Item_rec.DEFAULT_SHIPPING_ORG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DEFAULT_SO_SOURCE_TYPE') THEN
	    IF (NVL(l_Item_rec.DEFAULT_SO_SOURCE_TYPE,'!')  <> NVL(m_Item_rec.DEFAULT_SO_SOURCE_TYPE,'!')) THEN
               l_Item_rec.DEFAULT_SO_SOURCE_TYPE     :=  m_Item_rec.DEFAULT_SO_SOURCE_TYPE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'PICK_COMPONENTS_FLAG') THEN
	   IF (NVL(l_Item_rec.PICK_COMPONENTS_FLAG,'!')  <> NVL(m_Item_rec.PICK_COMPONENTS_FLAG,'!')) THEN
              l_Item_rec.PICK_COMPONENTS_FLAG           := m_Item_rec.PICK_COMPONENTS_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ATP_FLAG')  THEN
	   IF (NVL(l_Item_rec.ATP_FLAG,'!')  <> NVL(m_Item_rec.ATP_FLAG,'!')) THEN
              l_Item_rec.ATP_FLAG                       := m_Item_rec.ATP_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'REPLENISH_TO_ORDER_FLAG') THEN
	   IF (NVL(l_Item_rec.REPLENISH_TO_ORDER_FLAG,'!')  <> NVL(m_Item_rec.REPLENISH_TO_ORDER_FLAG,'!')) THEN
              l_Item_rec.REPLENISH_TO_ORDER_FLAG        := m_Item_rec.REPLENISH_TO_ORDER_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ATP_COMPONENTS_FLAG') THEN
	   IF (NVL(l_Item_rec.ATP_COMPONENTS_FLAG,'!')  <> NVL(m_Item_rec.ATP_COMPONENTS_FLAG,'!')) THEN
              l_Item_rec.ATP_COMPONENTS_FLAG            := m_Item_rec.ATP_COMPONENTS_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ATP_RULE_ID') THEN
	   IF (NVL(l_Item_rec.ATP_RULE_ID,-999999)  <> NVL(m_Item_rec.ATP_RULE_ID,-999999)) THEN
              l_Item_rec.ATP_RULE_ID                    := m_Item_rec.ATP_RULE_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SHIP_MODEL_COMPLETE_FLAG') THEN
	   IF (NVL(l_Item_rec.SHIP_MODEL_COMPLETE_FLAG,'!')  <> NVL(m_Item_rec.SHIP_MODEL_COMPLETE_FLAG,'!')) THEN
              l_Item_rec.SHIP_MODEL_COMPLETE_FLAG       := m_Item_rec.SHIP_MODEL_COMPLETE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RETURNABLE_FLAG') THEN
	   IF (NVL(l_Item_rec.RETURNABLE_FLAG,'!')  <> NVL(m_Item_rec.RETURNABLE_FLAG,'!')) THEN
              l_Item_rec.RETURNABLE_FLAG                := m_Item_rec.RETURNABLE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RETURN_INSPECTION_REQUIREMENT') THEN
	   IF (NVL(l_Item_rec.RETURN_INSPECTION_REQUIREMENT,-999999)  <> NVL(m_Item_rec.RETURN_INSPECTION_REQUIREMENT,-999999)) THEN
           l_Item_rec.RETURN_INSPECTION_REQUIREMENT  := m_Item_rec.RETURN_INSPECTION_REQUIREMENT;
	   l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'FINANCING_ALLOWED_FLAG') THEN
	   IF (NVL(l_Item_rec.FINANCING_ALLOWED_FLAG,'!')  <> NVL(m_Item_rec.FINANCING_ALLOWED_FLAG,'!')) THEN
              l_Item_rec.FINANCING_ALLOWED_FLAG := m_Item_rec.FINANCING_ALLOWED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OVER_SHIPMENT_TOLERANCE') THEN
	   IF (NVL(l_Item_rec.OVER_SHIPMENT_TOLERANCE,-999999)  <> NVL(m_Item_rec.OVER_SHIPMENT_TOLERANCE,-999999)) THEN
              l_Item_rec.OVER_SHIPMENT_TOLERANCE        := m_Item_rec.OVER_SHIPMENT_TOLERANCE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'UNDER_SHIPMENT_TOLERANCE') THEN
	   IF (NVL(l_Item_rec.UNDER_SHIPMENT_TOLERANCE,-999999)  <> NVL(m_Item_rec.UNDER_SHIPMENT_TOLERANCE,-999999)) THEN
              l_Item_rec.UNDER_SHIPMENT_TOLERANCE       := m_Item_rec.UNDER_SHIPMENT_TOLERANCE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'OVER_RETURN_TOLERANCE') THEN
	   IF (NVL(l_Item_rec.OVER_RETURN_TOLERANCE,-999999)  <> NVL(m_Item_rec.OVER_RETURN_TOLERANCE,-999999)) THEN
              l_Item_rec.OVER_RETURN_TOLERANCE          := m_Item_rec.OVER_RETURN_TOLERANCE;
	      l_update_child_rec := TRUE;
	   END IF;
	ELSIF ( l_Attribute_Code = 'UNDER_RETURN_TOLERANCE') THEN
	   IF (NVL(l_Item_rec.UNDER_RETURN_TOLERANCE,-999999)  <> NVL(m_Item_rec.UNDER_RETURN_TOLERANCE,-999999)) THEN
              l_Item_rec.UNDER_RETURN_TOLERANCE         := m_Item_rec.UNDER_RETURN_TOLERANCE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PICKING_RULE_ID') THEN
	   IF (NVL(l_Item_rec.PICKING_RULE_ID,-999999)  <> NVL(m_Item_rec.PICKING_RULE_ID,-999999)) THEN
              l_Item_rec.PICKING_RULE_ID                := m_Item_rec.PICKING_RULE_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'VOL_DISCOUNT_EXEMPT_FLAG') THEN
	   IF (NVL(l_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG,'!')  <> NVL(m_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG,'!')) THEN
              l_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG := m_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'COUPON_EXEMPT_FLAG') THEN
	   IF (NVL(l_Item_rec.COUPON_EXEMPT_FLAG,'!')  <> NVL(m_Item_rec.COUPON_EXEMPT_FLAG,'!')) THEN
              l_Item_rec.COUPON_EXEMPT_FLAG := m_Item_rec.COUPON_EXEMPT_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CHARGE_PERIODICITY_CODE') THEN  --Added for Bug: 5355168
	   IF (NVL(l_Item_rec.CHARGE_PERIODICITY_CODE,'!')  <> NVL(m_Item_rec.CHARGE_PERIODICITY_CODE,'!')) THEN
              l_Item_rec.CHARGE_PERIODICITY_CODE := m_Item_rec.CHARGE_PERIODICITY_CODE ;
	      l_update_child_rec := TRUE;
	   END IF;

            --Invoicing Attributes
        ELSIF ( l_Attribute_Code = 'INVOICEABLE_ITEM_FLAG') THEN
	   IF (NVL(l_Item_rec.INVOICEABLE_ITEM_FLAG,'!')  <> NVL(m_Item_rec.INVOICEABLE_ITEM_FLAG,'!')) THEN
              l_Item_rec.INVOICEABLE_ITEM_FLAG          := m_Item_rec.INVOICEABLE_ITEM_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INVOICE_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.INVOICE_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.INVOICE_ENABLED_FLAG,'!')) THEN
              l_Item_rec.INVOICE_ENABLED_FLAG           := m_Item_rec.INVOICE_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ACCOUNTING_RULE_ID') THEN
	   IF (NVL(l_Item_rec.ACCOUNTING_RULE_ID,-999999)  <> NVL(m_Item_rec.ACCOUNTING_RULE_ID,-999999)) THEN
              l_Item_rec.ACCOUNTING_RULE_ID             := m_Item_rec.ACCOUNTING_RULE_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'INVOICING_RULE_ID') THEN
	   IF (NVL(l_Item_rec.INVOICING_RULE_ID,-999999)  <> NVL(m_Item_rec.INVOICING_RULE_ID,-999999)) THEN
              l_Item_rec.INVOICING_RULE_ID              := m_Item_rec.INVOICING_RULE_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'TAX_CODE') THEN
	   IF (NVL(l_Item_rec.TAX_CODE,'!')  <> NVL(m_Item_rec.TAX_CODE,'!')) THEN
              l_Item_rec.TAX_CODE                       := m_Item_rec.TAX_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SALES_ACCOUNT') THEN
	   IF (NVL(l_Item_rec.SALES_ACCOUNT,-999999)  <> NVL(m_Item_rec.SALES_ACCOUNT,-999999)) THEN
              l_Item_rec.SALES_ACCOUNT                  := m_Item_rec.SALES_ACCOUNT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PAYMENT_TERMS_ID') THEN
	   IF (NVL(l_Item_rec.PAYMENT_TERMS_ID,-999999)  <> NVL(m_Item_rec.PAYMENT_TERMS_ID,-999999)) THEN
             l_Item_rec.PAYMENT_TERMS_ID               := m_Item_rec.PAYMENT_TERMS_ID;
	     l_update_child_rec := TRUE;
	   END IF;

	    --Service Attributes
        ELSIF ( l_Attribute_Code = 'CONTRACT_ITEM_TYPE_CODE') THEN
	    IF (NVL(l_Item_rec.CONTRACT_ITEM_TYPE_CODE,'!')  <> NVL(m_Item_rec.CONTRACT_ITEM_TYPE_CODE,'!')) THEN
               l_Item_rec.CONTRACT_ITEM_TYPE_CODE    :=  m_Item_rec.CONTRACT_ITEM_TYPE_CODE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'COVERAGE_SCHEDULE_ID') THEN
	   IF (NVL(l_Item_rec.COVERAGE_SCHEDULE_ID,-999999)  <> NVL(m_Item_rec.COVERAGE_SCHEDULE_ID,-999999)) THEN
              l_Item_rec.COVERAGE_SCHEDULE_ID           := m_Item_rec.COVERAGE_SCHEDULE_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERVICE_DURATION_PERIOD_CODE') THEN
	   IF (NVL(l_Item_rec.SERVICE_DURATION_PERIOD_CODE,'!')  <> NVL(m_Item_rec.SERVICE_DURATION_PERIOD_CODE,'!')) THEN
              l_Item_rec.SERVICE_DURATION_PERIOD_CODE   := m_Item_rec.SERVICE_DURATION_PERIOD_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MATERIAL_BILLABLE_FLAG') THEN
	   IF (NVL(l_Item_rec.MATERIAL_BILLABLE_FLAG,'!')  <> NVL(m_Item_rec.MATERIAL_BILLABLE_FLAG,'!')) THEN
              l_Item_rec.MATERIAL_BILLABLE_FLAG         := m_Item_rec.MATERIAL_BILLABLE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERV_REQ_ENABLED_CODE') THEN
	    IF (NVL(l_Item_rec.SERV_REQ_ENABLED_CODE,'!')  <> NVL(m_Item_rec.SERV_REQ_ENABLED_CODE,'!')) THEN
               l_Item_rec.SERV_REQ_ENABLED_CODE      :=  m_Item_rec.SERV_REQ_ENABLED_CODE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'COMMS_ACTIVATION_REQD_FLAG') THEN
	   IF (NVL(l_Item_rec.COMMS_ACTIVATION_REQD_FLAG,'!')  <> NVL(m_Item_rec.COMMS_ACTIVATION_REQD_FLAG,'!')) THEN
              l_Item_rec.COMMS_ACTIVATION_REQD_FLAG := m_Item_rec.COMMS_ACTIVATION_REQD_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERV_BILLING_ENABLED_FLAG') THEN
	    IF (NVL(l_Item_rec.SERV_BILLING_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.SERV_BILLING_ENABLED_FLAG,'!')) THEN
               l_Item_rec.SERV_BILLING_ENABLED_FLAG  :=  m_Item_rec.SERV_BILLING_ENABLED_FLAG;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'DEFECT_TRACKING_ON_FLAG') THEN
	   IF (NVL(l_Item_rec.DEFECT_TRACKING_ON_FLAG,'!')  <> NVL(m_Item_rec.DEFECT_TRACKING_ON_FLAG,'!')) THEN
              l_Item_rec.DEFECT_TRACKING_ON_FLAG := m_Item_rec.DEFECT_TRACKING_ON_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RECOVERED_PART_DISP_CODE') THEN
	   IF (NVL(l_Item_rec.RECOVERED_PART_DISP_CODE,'!')  <> NVL(m_Item_rec.RECOVERED_PART_DISP_CODE,'!')) THEN
              l_Item_rec.RECOVERED_PART_DISP_CODE := m_Item_rec.RECOVERED_PART_DISP_CODE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'COMMS_NL_TRACKABLE_FLAG') THEN
	   IF (NVL(l_Item_rec.COMMS_NL_TRACKABLE_FLAG,'!')  <> NVL(m_Item_rec.COMMS_NL_TRACKABLE_FLAG,'!')) THEN
              l_Item_rec.COMMS_NL_TRACKABLE_FLAG := m_Item_rec.COMMS_NL_TRACKABLE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ASSET_CREATION_CODE') THEN
	   IF (NVL(l_Item_rec.ASSET_CREATION_CODE,'!')  <> NVL(m_Item_rec.ASSET_CREATION_CODE,'!')) THEN
              l_Item_rec.ASSET_CREATION_CODE := m_Item_rec.ASSET_CREATION_CODE ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERVICE_DURATION') THEN
	   IF (NVL(l_Item_rec.SERVICE_DURATION,-999999)  <> NVL(m_Item_rec.SERVICE_DURATION,-999999)) THEN
              l_Item_rec.SERVICE_DURATION               := m_Item_rec.SERVICE_DURATION;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'IB_ITEM_INSTANCE_CLASS') THEN
	    IF (NVL(l_Item_rec.IB_ITEM_INSTANCE_CLASS,'!')  <> NVL(m_Item_rec.IB_ITEM_INSTANCE_CLASS,'!')) THEN
               l_Item_rec.IB_ITEM_INSTANCE_CLASS     :=  m_Item_rec.IB_ITEM_INSTANCE_CLASS;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'PREVENTIVE_MAINTENANCE_FLAG') THEN
	   IF (NVL(l_Item_rec.PREVENTIVE_MAINTENANCE_FLAG,'!')  <> NVL(m_Item_rec.PREVENTIVE_MAINTENANCE_FLAG,'!')) THEN
              l_Item_rec.PREVENTIVE_MAINTENANCE_FLAG    := m_Item_rec.PREVENTIVE_MAINTENANCE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PRORATE_SERVICE_FLAG') THEN
	   IF (NVL(l_Item_rec.PRORATE_SERVICE_FLAG,'!')  <> NVL(m_Item_rec.PRORATE_SERVICE_FLAG,'!')) THEN
              l_Item_rec.PRORATE_SERVICE_FLAG           := m_Item_rec.PRORATE_SERVICE_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'WARRANTY_VENDOR_ID') THEN
	   IF (NVL(l_Item_rec.WARRANTY_VENDOR_ID,-999999)  <> NVL(m_Item_rec.WARRANTY_VENDOR_ID,-999999)) THEN
              l_Item_rec.WARRANTY_VENDOR_ID             := m_Item_rec.WARRANTY_VENDOR_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MAX_WARRANTY_AMOUNT') THEN
	   IF (NVL(l_Item_rec.MAX_WARRANTY_AMOUNT,-999999)  <> NVL(m_Item_rec.MAX_WARRANTY_AMOUNT,-999999)) THEN
              l_Item_rec.MAX_WARRANTY_AMOUNT            := m_Item_rec.MAX_WARRANTY_AMOUNT;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RESPONSE_TIME_PERIOD_CODE') THEN
	   IF (NVL(l_Item_rec.RESPONSE_TIME_PERIOD_CODE,'!')  <> NVL(m_Item_rec.RESPONSE_TIME_PERIOD_CODE,'!')) THEN
              l_Item_rec.RESPONSE_TIME_PERIOD_CODE      := m_Item_rec.RESPONSE_TIME_PERIOD_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'RESPONSE_TIME_VALUE') THEN
	   IF (NVL(l_Item_rec.RESPONSE_TIME_VALUE,-999999)  <> NVL(m_Item_rec.RESPONSE_TIME_VALUE,-999999)) THEN
              l_Item_rec.RESPONSE_TIME_VALUE            := m_Item_rec.RESPONSE_TIME_VALUE;
	      l_update_child_rec := TRUE;
	   END IF;

	    --Web Option
        ELSIF ( l_Attribute_Code = 'WEB_STATUS') THEN
	   IF (NVL(l_Item_rec.WEB_STATUS,'!')  <> NVL(m_Item_rec.WEB_STATUS,'!')) THEN
              l_Item_rec.WEB_STATUS := m_Item_rec.WEB_STATUS ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'ORDERABLE_ON_WEB_FLAG') THEN
	   IF (NVL(l_Item_rec.ORDERABLE_ON_WEB_FLAG,'!')  <> NVL(m_Item_rec.ORDERABLE_ON_WEB_FLAG,'!')) THEN
              l_Item_rec.ORDERABLE_ON_WEB_FLAG := m_Item_rec.ORDERABLE_ON_WEB_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'BACK_ORDERABLE_FLAG') THEN
	   IF (NVL(l_Item_rec.BACK_ORDERABLE_FLAG,'!')  <> NVL(m_Item_rec.BACK_ORDERABLE_FLAG,'!')) THEN
              l_Item_rec.BACK_ORDERABLE_FLAG := m_Item_rec.BACK_ORDERABLE_FLAG ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'MINIMUM_LICENSE_QUANTITY') THEN
	    IF (NVL(l_Item_rec.MINIMUM_LICENSE_QUANTITY,-999999)  <> NVL(m_Item_rec.MINIMUM_LICENSE_QUANTITY,-999999)) THEN
               l_Item_rec.MINIMUM_LICENSE_QUANTITY          :=  m_Item_rec.MINIMUM_LICENSE_QUANTITY;
	       l_update_child_rec := TRUE;
	    END IF;
            --Main Attributes
        ELSIF ( l_Attribute_Code = 'SEGMENT1') THEN
	   IF (NVL(l_Item_rec.SEGMENT1,'!')  <> NVL(m_Item_rec.SEGMENT1,'!')) THEN
              l_Item_rec.SEGMENT1                       := m_Item_rec.SEGMENT1;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT2') THEN
	   IF (NVL(l_Item_rec.SEGMENT2,'!')  <> NVL(m_Item_rec.SEGMENT2,'!')) THEN
              l_Item_rec.SEGMENT2                       := m_Item_rec.SEGMENT2 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT3') THEN
	   IF (NVL(l_Item_rec.SEGMENT3,'!')  <> NVL(m_Item_rec.SEGMENT3,'!')) THEN
              l_Item_rec.SEGMENT3                       := m_Item_rec.SEGMENT3;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT4') THEN
	   IF (NVL(l_Item_rec.SEGMENT4,'!')  <> NVL(m_Item_rec.SEGMENT4,'!')) THEN
              l_Item_rec.SEGMENT4                       := m_Item_rec.SEGMENT4 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT5') THEN
	   IF (NVL(l_Item_rec.SEGMENT5,'!')  <> NVL(m_Item_rec.SEGMENT5,'!')) THEN
              l_Item_rec.SEGMENT5                       := m_Item_rec.SEGMENT5 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT6') THEN
	   IF (NVL(l_Item_rec.SEGMENT6,'!')  <> NVL(m_Item_rec.SEGMENT6,'!')) THEN
              l_Item_rec.SEGMENT6                       := m_Item_rec.SEGMENT6 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT7') THEN
	   IF (NVL(l_Item_rec.SEGMENT7,'!')  <> NVL(m_Item_rec.SEGMENT7,'!')) THEN
              l_Item_rec.SEGMENT7                       := m_Item_rec.SEGMENT7 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT8') THEN
	   IF (NVL(l_Item_rec.SEGMENT8,'!')  <> NVL(m_Item_rec.SEGMENT8,'!')) THEN
              l_Item_rec.SEGMENT8                       := m_Item_rec.SEGMENT8 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT9') THEN
	   IF (NVL(l_Item_rec.SEGMENT9,'!')  <> NVL(m_Item_rec.SEGMENT9,'!')) THEN
              l_Item_rec.SEGMENT9                       := m_Item_rec.SEGMENT9 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT10') THEN
	   IF (NVL(l_Item_rec.SEGMENT10,'!')  <> NVL(m_Item_rec.SEGMENT10,'!')) THEN
              l_Item_rec.SEGMENT10                      := m_Item_rec.SEGMENT10;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT11') THEN
	   IF (NVL(l_Item_rec.SEGMENT11,'!')  <> NVL(m_Item_rec.SEGMENT11,'!')) THEN
              l_Item_rec.SEGMENT11                      := m_Item_rec.SEGMENT11 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT12') THEN
	   IF (NVL(l_Item_rec.SEGMENT12,'!')  <> NVL(m_Item_rec.SEGMENT12,'!')) THEN
              l_Item_rec.SEGMENT12                      := m_Item_rec.SEGMENT12 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT13') THEN
	   IF (NVL(l_Item_rec.SEGMENT13,'!')  <> NVL(m_Item_rec.SEGMENT13,'!')) THEN
              l_Item_rec.SEGMENT13                      := m_Item_rec.SEGMENT13 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT14') THEN
	   IF (NVL(l_Item_rec.SEGMENT14,'!')  <> NVL(m_Item_rec.SEGMENT14,'!')) THEN
              l_Item_rec.SEGMENT14                      := m_Item_rec.SEGMENT14;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT15') THEN
	   IF (NVL(l_Item_rec.SEGMENT15,'!')  <> NVL(m_Item_rec.SEGMENT15,'!')) THEN
              l_Item_rec.SEGMENT15                      := m_Item_rec.SEGMENT15 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT16') THEN
	   IF (NVL(l_Item_rec.SEGMENT16,'!')  <> NVL(m_Item_rec.SEGMENT16,'!')) THEN
              l_Item_rec.SEGMENT16                      := m_Item_rec.SEGMENT16 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT17') THEN
	   IF (NVL(l_Item_rec.SEGMENT17,'!')  <> NVL(m_Item_rec.SEGMENT17,'!')) THEN
              l_Item_rec.SEGMENT17                      := m_Item_rec.SEGMENT17 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT18') THEN
	   IF (NVL(l_Item_rec.SEGMENT18,'!')  <> NVL(m_Item_rec.SEGMENT18,'!')) THEN
              l_Item_rec.SEGMENT18                      := m_Item_rec.SEGMENT18 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT19') THEN
	   IF (NVL(l_Item_rec.SEGMENT19,'!')  <> NVL(m_Item_rec.SEGMENT19,'!')) THEN
              l_Item_rec.SEGMENT19                      := m_Item_rec.SEGMENT19 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SEGMENT20') THEN
	   IF (NVL(l_Item_rec.SEGMENT20,'!')  <> NVL(m_Item_rec.SEGMENT20,'!')) THEN
              l_Item_rec.SEGMENT20                      := m_Item_rec.SEGMENT20 ;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'DUAL_UOM_CONTROL') THEN
	    IF (NVL(l_Item_rec.DUAL_UOM_CONTROL,-999999)  <> NVL(m_Item_rec.DUAL_UOM_CONTROL,-999999)) THEN
               l_Item_rec.DUAL_UOM_CONTROL := m_Item_rec.DUAL_UOM_CONTROL;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'SECONDARY_UOM_CODE') THEN
	    IF (NVL(l_Item_rec.SECONDARY_UOM_CODE,'!')  <> NVL(m_Item_rec.SECONDARY_UOM_CODE,'!')) THEN
               l_Item_rec.SECONDARY_UOM_CODE := m_Item_rec.SECONDARY_UOM_CODE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'DUAL_UOM_DEVIATION_HIGH') THEN
	    IF (NVL(l_Item_rec.DUAL_UOM_DEVIATION_HIGH,-999999)  <> NVL(m_Item_rec.DUAL_UOM_DEVIATION_HIGH,-999999)) THEN
               l_Item_rec.DUAL_UOM_DEVIATION_HIGH := m_Item_rec.DUAL_UOM_DEVIATION_HIGH;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'DUAL_UOM_DEVIATION_LOW') THEN
	    IF (NVL(l_Item_rec.DUAL_UOM_DEVIATION_LOW,-999999)  <> NVL(m_Item_rec.DUAL_UOM_DEVIATION_LOW,-999999)) THEN
               l_Item_rec.DUAL_UOM_DEVIATION_LOW := m_Item_rec.DUAL_UOM_DEVIATION_LOW;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'ALLOWED_UNITS_LOOKUP_CODE') THEN
	   IF (NVL(l_Item_rec.ALLOWED_UNITS_LOOKUP_CODE,-999999)  <> NVL(m_Item_rec.ALLOWED_UNITS_LOOKUP_CODE,-999999)) THEN
              l_Item_rec.ALLOWED_UNITS_LOOKUP_CODE      := m_Item_rec.ALLOWED_UNITS_LOOKUP_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'TRACKING_QUANTITY_IND') THEN
	    IF NVL(l_Item_rec.TRACKING_QUANTITY_IND,'!')  <> NVL(m_Item_rec.TRACKING_QUANTITY_IND,'!') THEN
               l_Item_rec.TRACKING_QUANTITY_IND     :=  m_Item_rec.TRACKING_QUANTITY_IND;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'ONT_PRICING_QTY_SOURCE') THEN
	    IF (NVL(l_Item_rec.ONT_PRICING_QTY_SOURCE,'!')  <> NVL(m_Item_rec.ONT_PRICING_QTY_SOURCE,'!')) THEN
               l_Item_rec.ONT_PRICING_QTY_SOURCE    :=  m_Item_rec.ONT_PRICING_QTY_SOURCE;
	       l_update_child_rec := TRUE;
	    END IF;
        ELSIF ( l_Attribute_Code = 'SECONDARY_DEFAULT_IND') THEN
	    IF (NVL(l_Item_rec.SECONDARY_DEFAULT_IND,'!')  <> NVL(m_Item_rec.SECONDARY_DEFAULT_IND,'!')) THEN
               l_Item_rec.SECONDARY_DEFAULT_IND     :=  m_Item_rec.SECONDARY_DEFAULT_IND;
	       l_update_child_rec := TRUE;
	    END IF;

          --110
        ELSIF ( l_Attribute_Code = 'NEW_REVISION_CODE') THEN
	   IF (NVL(l_Item_rec.NEW_REVISION_CODE,'!')  <> NVL(m_Item_rec.NEW_REVISION_CODE,'!')) THEN
              l_Item_rec.NEW_REVISION_CODE              := m_Item_rec.NEW_REVISION_CODE;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'BASE_WARRANTY_SERVICE_ID') THEN
	   IF (NVL(l_Item_rec.BASE_WARRANTY_SERVICE_ID,-999999)  <> NVL(m_Item_rec.BASE_WARRANTY_SERVICE_ID,-999999)) THEN
              l_Item_rec.BASE_WARRANTY_SERVICE_ID       := m_Item_rec.BASE_WARRANTY_SERVICE_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PRIMARY_SPECIALIST_ID') THEN
	   IF (NVL(l_Item_rec.PRIMARY_SPECIALIST_ID,-999999)  <> NVL(m_Item_rec.PRIMARY_SPECIALIST_ID,-999999)) THEN
              l_Item_rec.PRIMARY_SPECIALIST_ID          := m_Item_rec.PRIMARY_SPECIALIST_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SECONDARY_SPECIALIST_ID') THEN
	   IF (NVL(l_Item_rec.SECONDARY_SPECIALIST_ID,-999999)  <> NVL(m_Item_rec.SECONDARY_SPECIALIST_ID,-999999)) THEN
              l_Item_rec.SECONDARY_SPECIALIST_ID        := m_Item_rec.SECONDARY_SPECIALIST_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERVICEABLE_COMPONENT_FLAG') THEN
	   IF (NVL(l_Item_rec.SERVICEABLE_COMPONENT_FLAG,'!')  <> NVL(m_Item_rec.SERVICEABLE_COMPONENT_FLAG,'!')) THEN
              l_Item_rec.SERVICEABLE_COMPONENT_FLAG     := m_Item_rec.SERVICEABLE_COMPONENT_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERVICEABLE_ITEM_CLASS_ID') THEN
	   IF (NVL(l_Item_rec.SERVICEABLE_ITEM_CLASS_ID,-999999)  <> NVL(m_Item_rec.SERVICEABLE_ITEM_CLASS_ID,-999999)) THEN
              l_Item_rec.SERVICEABLE_ITEM_CLASS_ID      := m_Item_rec.SERVICEABLE_ITEM_CLASS_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERVICEABLE_PRODUCT_FLAG') THEN
	   IF (NVL(l_Item_rec.SERVICEABLE_PRODUCT_FLAG,'!')  <> NVL(m_Item_rec.SERVICEABLE_PRODUCT_FLAG,'!')) THEN
              l_Item_rec.SERVICEABLE_PRODUCT_FLAG       := m_Item_rec.SERVICEABLE_PRODUCT_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'SERVICE_STARTING_DELAY') THEN
	   IF (NVL(l_Item_rec.SERVICE_STARTING_DELAY,-999999)  <> NVL(m_Item_rec.SERVICE_STARTING_DELAY,-999999)) THEN
              l_Item_rec.SERVICE_STARTING_DELAY         := m_Item_rec.SERVICE_STARTING_DELAY;
	      l_update_child_rec := TRUE;
	   END IF;

          --Process Manufacturing Attribute Group
        ELSIF ( l_Attribute_Code = 'RECIPE_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.RECIPE_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.RECIPE_ENABLED_FLAG,'!')) THEN
              l_Item_rec.RECIPE_ENABLED_FLAG         := m_Item_rec.RECIPE_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'CAS_NUMBER') THEN
	   IF (NVL(l_Item_rec.CAS_NUMBER,'!')  <> NVL(m_Item_rec.CAS_NUMBER,'!')) THEN
              l_Item_rec.CAS_NUMBER         := m_Item_rec.CAS_NUMBER;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'HAZARDOUS_MATERIAL_FLAG') THEN
	   IF (NVL(l_Item_rec.HAZARDOUS_MATERIAL_FLAG,'!')  <> NVL(m_Item_rec.HAZARDOUS_MATERIAL_FLAG,'!')) THEN
              l_Item_rec.HAZARDOUS_MATERIAL_FLAG         := m_Item_rec.HAZARDOUS_MATERIAL_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PROCESS_COSTING_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.PROCESS_COSTING_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.PROCESS_COSTING_ENABLED_FLAG,'!')) THEN
              l_Item_rec.PROCESS_COSTING_ENABLED_FLAG         := m_Item_rec.PROCESS_COSTING_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PROCESS_EXECUTION_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG,'!')) THEN
              l_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG         := m_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PROCESS_QUALITY_ENABLED_FLAG') THEN
	   IF (NVL(l_Item_rec.PROCESS_QUALITY_ENABLED_FLAG,'!')  <> NVL(m_Item_rec.PROCESS_QUALITY_ENABLED_FLAG,'!')) THEN
              l_Item_rec.PROCESS_QUALITY_ENABLED_FLAG         := m_Item_rec.PROCESS_QUALITY_ENABLED_FLAG;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PROCESS_SUPPLY_LOCATOR_ID') THEN
	   IF (NVL(l_Item_rec.PROCESS_SUPPLY_LOCATOR_ID,-999999)  <> NVL(m_Item_rec.PROCESS_SUPPLY_LOCATOR_ID,-999999)) THEN
              l_Item_rec.PROCESS_SUPPLY_LOCATOR_ID         := m_Item_rec.PROCESS_SUPPLY_LOCATOR_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PROCESS_SUPPLY_SUBINVENTORY') THEN
	   IF (NVL(l_Item_rec.PROCESS_SUPPLY_SUBINVENTORY,'!')  <> NVL(m_Item_rec.PROCESS_SUPPLY_SUBINVENTORY,'!')) THEN
              l_Item_rec.PROCESS_SUPPLY_SUBINVENTORY         := m_Item_rec.PROCESS_SUPPLY_SUBINVENTORY;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PROCESS_YIELD_LOCATOR_ID') THEN
	   IF (NVL(l_Item_rec.PROCESS_YIELD_LOCATOR_ID,-999999)  <> NVL(m_Item_rec.PROCESS_YIELD_LOCATOR_ID,-999999)) THEN
              l_Item_rec.PROCESS_YIELD_LOCATOR_ID         := m_Item_rec.PROCESS_YIELD_LOCATOR_ID;
	      l_update_child_rec := TRUE;
	   END IF;
        ELSIF ( l_Attribute_Code = 'PROCESS_YIELD_SUBINVENTORY') THEN
	   IF (NVL(l_Item_rec.PROCESS_YIELD_SUBINVENTORY,'!')  <> NVL(m_Item_rec.PROCESS_YIELD_SUBINVENTORY,'!')) THEN
              l_Item_rec.PROCESS_YIELD_SUBINVENTORY         := m_Item_rec.PROCESS_YIELD_SUBINVENTORY;
	      l_update_child_rec := TRUE;
	   END IF;
	-- Fix for Bug#6644711
        ELSIF ( l_Attribute_Code = 'DEFAULT_MATERIAL_STATUS_ID') THEN
	   IF (NVL(l_Item_rec.DEFAULT_MATERIAL_STATUS_ID,-999999)  <> NVL(m_Item_rec.DEFAULT_MATERIAL_STATUS_ID,-999999)) THEN
              l_Item_rec.DEFAULT_MATERIAL_STATUS_ID := m_Item_rec.DEFAULT_MATERIAL_STATUS_ID;
	      l_update_child_rec := TRUE;
	   END IF;
      --Start: 5365622
        ELSIF ( l_Attribute_Code = 'ITEM_TYPE') THEN
	   IF (NVL(l_Item_rec.ITEM_TYPE,'!')  <> NVL(m_Item_rec.ITEM_TYPE,'!')) THEN
              l_Item_rec.ITEM_TYPE       := m_Item_rec.ITEM_TYPE;
	      l_update_child_rec := TRUE;
	   END IF;
      -- End: 5365622

        -- Derived Service attribute columns get updated in INV_ITEM_API.Update_Item_Row.
        --ELSIF ( l_Attribute_Code = 'SERVICE_ITEM_FLAG'           ) THEN
        --    l_Item_rec.SERVICE_ITEM_FLAG          :=  m_Item_rec.SERVICE_ITEM_FLAG;
        --ELSIF ( l_Attribute_Code = 'VENDOR_WARRANTY_FLAG'        ) THEN
        --    l_Item_rec.VENDOR_WARRANTY_FLAG       :=  m_Item_rec.VENDOR_WARRANTY_FLAG;
        --ELSIF ( l_Attribute_Code = 'USAGE_ITEM_FLAG'             ) THEN
        --    l_Item_rec.USAGE_ITEM_FLAG            :=  m_Item_rec.USAGE_ITEM_FLAG;
        --

/*11.5.10        ELSIF ( l_Attribute_Code = 'SUBSCRIPTION_DEPEND_FLAG'    ) THEN
            l_Item_rec.SUBSCRIPTION_DEPEND_FLAG   :=  m_Item_rec.SUBSCRIPTION_DEPEND_FLAG;
*/

/*11.5.10        ELSIF ( l_Attribute_Code = 'SERV_IMPORTANCE_LEVEL'       ) THEN
            l_Item_rec.SERV_IMPORTANCE_LEVEL      :=  m_Item_rec.SERV_IMPORTANCE_LEVEL;
*/
        ELSIF ( l_Attribute_Code = 'DESC_FLEX' ) THEN
           --------------------------------------------------------------------------
           -- Currently only Org control level is allowed for descriptive flexfield.
           -- When Master control is allowed, add logic to copy ATTRIBUTE[1-15].
           --------------------------------------------------------------------------
           NULL;
        ELSIF ( l_Attribute_Code = 'GLOBAL_DESC_FLEX' ) THEN
           NULL;

        ELSE
           --------------------------
           -- Invalid attribute code
           --------------------------
           x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

           FND_MESSAGE.Set_Name ('INV', 'INV_INVALID_ATTRIBUTE_CODE');
           FND_MESSAGE.Set_Token ('PACKAGE_NAME', G_PKG_NAME);
           FND_MESSAGE.Set_Token ('PROCEDURE_NAME', l_api_name);
           FND_MESSAGE.Set_Token ('ATTRIBUTE_CODE', l_Attribute_Code);
           FND_MSG_PUB.Add;
        --   RETURN;
           RAISE FND_API.g_EXC_UNEXPECTED_ERROR;

        END IF;  -- ( l_Attribute_Code = ... )

        -- Copy attributes done by code above.
        /*
           INV_ITEM_Lib.copy_Attribute
           (
               p_Attribute_Code  =>  l_Attribute_Code
           ,   p_Item_rec        =>  m_Item_rec
           ,   x_Item_rec        =>  l_Item_rec
           ,   x_return_status   =>  l_return_status
           );

           x_return_status := l_return_status;
           IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
              RAISE FND_API.g_EXC_ERROR;
           ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
              RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
           END IF;
        */

     END LOOP;  -- loop through item attributes
     l_Item_rec.OPTION_SPECIFIC_SOURCED   :=  m_Item_rec.OPTION_SPECIFIC_SOURCED; --11.5.10

     --bug 9944329 start, if status code has been changed in master org and status is controlled at master level
     --if the status attributes is under default value control/set value, need populate default value to org item
     if l_status_code_control_level = 1  and l_status_code_changed then
        OPEN org_status_attr_values_csr(m_Item_rec.INVENTORY_ITEM_STATUS_CODE);
        LOOP
				FETCH org_status_attr_values_csr INTO l_org_status_attribute_name, l_org_status_attribute_value, l_org_status_attribute_control;
				EXIT when org_status_attr_values_csr%NOTFOUND;

					if l_org_status_attribute_name = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG' and l_org_status_attribute_control <> 3 then
					  l_Item_rec.RECIPE_ENABLED_FLAG := l_org_status_attribute_value;
					end if;
					if l_org_status_attribute_name = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG' and l_org_status_attribute_control <> 3 then
						if l_Item_rec.inventory_item_flag = 'N' or  l_Item_rec.RECIPE_ENABLED_FLAG = 'N' then
						  l_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG := 'N';
						ELSE
						  l_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG := l_org_status_attribute_value;
						end if;
					end if;

				END LOOP;
				CLOSE org_status_attr_values_csr;
     end if ;
     --bug 9944329 end
     -------------------------------------------

     -- Copy WHO update column information
     IF l_update_child_rec = TRUE THEN
        l_Item_rec.LAST_UPDATE_DATE  := m_Item_rec.LAST_UPDATE_DATE;
        l_Item_rec.LAST_UPDATED_BY   := m_Item_rec.LAST_UPDATED_BY;
        l_Item_rec.LAST_UPDATE_LOGIN := m_Item_rec.LAST_UPDATE_LOGIN;
     END IF;
     -------------------------
     -- Org Item validation --
     -------------------------

/*
     INV_ITEM_PVT.Validate_Item
     (
         p_validation_level  =>  p_validation_level
     ,   p_Item_rec          =>  l_Item_rec
     ,   x_return_status     =>  l_return_status
     ,   x_msg_count         =>  x_msg_count
     ,   x_msg_data          =>  x_msg_data
     );
*/
     OPEN org_parameters_csr(l_item_rec.organization_id);
     FETCH org_parameters_csr INTO l_process_enabled, l_wms_enabled,
                                   l_eam_enabled,l_primary_cost_method,
				   l_trading_partner_org;
     CLOSE org_parameters_csr;

     INVIDIT3.VMI_Table_Queries(
           P_org_id                =>  l_Item_rec.organization_id
         , P_item_id               =>  l_Item_rec.inventory_item_id
         , X_vmiorconsign_enabled  =>  l_vmiorconsign_enabled
         , X_consign_enabled	   =>  l_consign_enabled
         );

     IF (l_Item_rec.inventory_item_flag ='N' AND
         l_Item_rec.stock_enabled_flag ='Y' ) THEN
       fnd_message.SET_NAME('INV', 'INVALID_INV_STK_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
     ELSIF (l_Item_rec.stock_enabled_flag ='N' AND
            l_Item_rec.mtl_transactions_enabled_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_STK_TRX_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
     --added for bug 8575398, pop up exception when check_shortages_flag = Y and transactions_enabled_flag = N
	 ELSIF (l_Item_rec.check_shortages_flag ='Y' AND
            l_Item_rec.mtl_transactions_enabled_flag ='N' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_CHK_TRX_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
	 ELSIF (l_Item_rec.purchasing_item_flag ='N' AND
            l_Item_rec.purchasing_enabled_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_PI_PE_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
     ELSIF (l_Item_rec.customer_order_flag ='N' AND
            l_Item_rec.customer_order_enabled_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_CO_COE_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;

     -- Added for Bug 5443289
     ELSIF (l_Item_rec.bom_item_type IN (3,5) AND
            l_Item_rec.customer_order_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INV_CUSTOMER');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
     -- End of Bug 5443289

     ELSIF (l_Item_rec.internal_order_flag ='N' AND
            l_Item_rec.internal_order_enabled_flag ='Y' )THEN
       fnd_message.SET_NAME('INV', 'INVALID_IO_IOE_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
/** Bug: 3546140 Removed for PLM RBOM
     ELSIF (l_Item_rec.inventory_item_flag = 'N' AND
            l_Item_rec.contract_item_type_code IS NULL AND
            l_Item_rec.bom_enabled_flag = 'Y') THEN
       fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
       fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_BOM_ENABLED', TRUE);
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
***/
     ELSIF ( ( l_item_rec.inventory_item_flag = 'N'
           OR  l_item_rec.bom_item_type <> 4 )
           AND l_Item_rec.build_in_wip_flag ='Y' ) THEN
       FND_MESSAGE.Set_Name ('INV', 'INVALID_INV_WIP_FLAG_COMB');
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;

     ELSIF ( l_Item_rec.EFFECTIVITY_CONTROL = 2 ) AND
           ( l_Item_rec.SERIAL_NUMBER_CONTROL_CODE NOT IN (2, 5) ) THEN
        fnd_message.SET_NAME('INV', 'ITM-EFFC-INVALID SERIAL CTRL-2');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.g_RET_STS_ERROR;

     ELSIF (l_Item_rec.serviceable_product_flag = 'Y' AND
            nvl(l_Item_rec.comms_nl_trackable_flag,'N') = 'N') THEN
       fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
       fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_IB_TRACKING_SERVICEABLE', TRUE);
       FND_MSG_PUB.Add;
       l_return_status := FND_API.g_RET_STS_ERROR;
--Added for 11.5.10 validations
     ELSIF ( (l_vmiorconsign_enabled = 1 AND
            (NVL(l_Item_rec.outside_operation_flag,'N') = 'Y' OR
	     l_Item_rec.eam_item_type IS NOT NULL OR
             NVL(l_Item_rec.mtl_transactions_enabled_flag,'N') = 'N' OR
             NVL(l_Item_rec.stock_enabled_flag,'N') = 'N'))
            OR
	    (l_consign_enabled = 1 AND NVL(l_Item_rec.inventory_asset_flag,'N') = 'N')
            ) THEN
                fnd_message.SET_NAME ('INV', 'INV_INVALID_VMI_COMB');
                FND_MSG_PUB.Add;
                l_return_status := FND_API.g_RET_STS_ERROR;

     /* R12 Attribute validations -Anmurali */
     /*           Inventory Attribute Group         */

     /* Changing this validation to exclude Process Org check -Bug 4902120 */
     /*Comment the code to fix 7477872
     ELSIF ((l_item_rec.bom_enabled_flag = 'Y' OR l_item_rec.bom_item_type IN (1,2)) AND
             l_item_rec.tracking_quantity_ind = 'PS') THEN
	 fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_TRACKING_OPM_BOM_ATTR', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

     ELSIF ( l_item_rec.lot_control_code = 1 AND l_item_rec.grade_control_flag = 'Y' ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_INVALID_GRADE_CONTROL', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;
   */

     ELSIF ( l_item_rec.grade_control_flag = 'N' AND l_item_rec.default_grade IS NOT NULL ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_INVALID_DEFAULT_GRADE_NULL', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.lot_control_code = 1 AND l_item_rec.lot_divisible_flag = 'Y' ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_INVALID_LOT_DIVISIBLE', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.lot_control_code = 1 AND l_item_rec.lot_split_enabled = 'Y' ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_INVALID_LOT_SPLIT_ENABLED', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.lot_control_code = 1 AND l_item_rec.child_lot_flag = 'Y' ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_INVALID_CHILD_LOT_FLAG', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

	    /*          Asset Management Attribute Group         */

    ELSIF (( l_item_rec.eam_item_type = 1 OR
            (l_item_rec.eam_item_type = 3 AND l_item_rec.serial_number_control_code <> 1 )) AND
        NVL(l_item_rec.comms_nl_trackable_flag , 'N') <> 'Y') THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_EAM_IB_TRACKABLE', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.eam_item_type = 2 AND l_item_rec.serial_number_control_code <> 1 ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_EAM_ACTIVITY_NEVER_SERIAL', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.eam_item_type = 1 AND l_item_rec.serial_number_control_code NOT IN (2,5) ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_EAM_ASSET_GRP_NO_SERIAL', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.eam_item_type = 1 AND l_item_rec.effectivity_control <> 2 ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_EAM_ASSET_UNIT_CONTROL', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

	    /*         Purchasing Attribute Group         */

    ELSIF (   l_item_rec.purchasing_tax_code IS NOT NULL AND
          NVL(l_item_rec.taxable_flag,'N') <> 'Y') THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_NOT_TAXABLE_ITEM', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.outsourced_assembly = 1 AND
           (l_process_enabled = 'Y' OR l_wms_enabled = 'Y' OR l_eam_enabled = 'Y') ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_OS_ASMBLY_INVALID_ORG', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( NVL(l_item_rec.release_time_fence_code,6) <> 7 AND
            NVL(l_trading_partner_org,'N') = 'Y' AND
	        l_item_rec.outsourced_assembly = 1 ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_OS_ASMBLY_TP_TIME_FENSE', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;
    -- Fix for bug#6447581
    -- ELSIF ( l_item_rec.outsourced_assembly = 1 AND l_primary_cost_method <> 1) THEN
    --     fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
    --     fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_OS_ASMBLY_STD_COST_ORG', TRUE);
    --	 FND_MSG_PUB.Add;
    --     l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.outsourced_assembly = 1 AND
          NOT(l_item_rec.bom_item_type = 4 AND l_item_rec.effectivity_control = 1) ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_OS_ASMBLY_INVALID_BOM_ATTR', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.outsourced_assembly = 1 AND l_item_rec.outside_operation_flag = 'Y') THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_OS_ASMBLY_OUTSIDE_OPRN', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.outsourced_assembly = 1 AND
          ( /*l_item_rec.internal_order_flag ='Y' OR l_item_rec.internal_order_enabled_flag = 'Y' OR*/-- Bug 9246127
	    l_item_rec.pick_components_flag = 'Y' OR l_item_rec.replenish_to_order_flag = 'Y' ) ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_OS_ASMBLY_INVALID_OM_ATTR', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

	       /*           General Planning Attribute Group       */

    ELSIF ( l_item_rec.mrp_safety_stock_code <> 1 AND
            l_item_rec.drp_planned_flag = 2 AND
            /* modified from in (6,9) to = 6 for bug 9838290 to keep align with INVIDITM forms validation*/
	    l_item_rec.mrp_planning_code = 6 ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_SAFETY_STOCK', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.subcontracting_component IN (2,3) AND
       (NOT (l_process_enabled = 'N' AND
            l_wms_enabled     = 'N' AND
            l_eam_enabled     = 'N' ) ) ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_OS_ASMBLY_INVALID_ORG', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

    ELSIF ( l_item_rec.subcontracting_component IN (2,3) AND l_primary_cost_method <> 1 ) THEN
         fnd_message.SET_NAME ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
         fnd_message.SET_TOKEN ('ERROR_MESSAGE_NAME', 'INV_OS_ASMBLY_STD_COST_ORG', TRUE);
	 FND_MSG_PUB.Add;
         l_return_status := FND_API.g_RET_STS_ERROR;

     END IF;

               /*              Invoicing Attribute Group              */
	                       --* Added for Bug 5207014

     IF l_Item_rec.TAX_CODE IS NOT NULL THEN
	BEGIN
	/* Fix for bug 7162580- Tax Codes are stored at O.U. level, so added a subquery
	   to fetch the operating_unit */
       /*Bug 6843376 Modified the query which fetch the Operating unit */
          SELECT 1 INTO l_exists
            FROM ZX_OUTPUT_CLASSIFICATIONS_V
           WHERE lookup_code  = l_item_rec.TAX_CODE
             AND enabled_flag = 'Y'
             AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
             AND org_id IN (-99, (SELECT org_information3 FROM  hr_organization_information
                                    WHERE ( ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
                                     AND ORGANIZATION_ID=l_Item_rec.organization_id))
	     AND rownum = 1;
     	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     fnd_message.SET_NAME('INV', 'INV_IOI_INVALID_TAX_CODE_ORG');
	     FND_MSG_PUB.Add;
  	     l_return_status := FND_API.g_RET_STS_ERROR;
        END;
     END IF;
	                        --* End of Bug 5207014

     IF l_Item_rec.PURCHASING_TAX_CODE IS NOT NULL THEN
	BEGIN
	/* Fix for bug 7162580- Tax Codes are stored at O.U. level, so added a subquery
	   to fetch the operating_unit */
    /*Bug 6843376 Modified the query which fetch the Operating unit */
          SELECT 1 INTO l_exists
            FROM ZX_INPUT_CLASSIFICATIONS_V
           WHERE nvl(tax_type,'X') not in ('AWT','OFFSET') --Modified to fix bug 7588091
             AND enabled_flag = 'Y'
             AND sysdate between start_date_active and  nvl(end_date_active,sysdate)
             AND lookup_code  = l_Item_rec.PURCHASING_TAX_CODE
               AND org_id IN (-99, (SELECT org_information3 FROM  hr_organization_information
                                     WHERE ( ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
                                      AND ORGANIZATION_ID=l_Item_rec.organization_id))
	       AND rownum = 1;
     	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     fnd_message.SET_NAME('INV', 'INV_IOI_PUR_TAX_CODE');
	     FND_MSG_PUB.Add;
  	     l_return_status := FND_API.g_RET_STS_ERROR;
        END;
     END IF;


     -- Check for errors
     IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
        RAISE FND_API.g_EXC_ERROR;
     ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
     END IF;

     ---------------------------------
     -- Update current org item row --
     ---------------------------------
     IF l_update_child_rec = TRUE THEN
	Set_Is_Master_Attr_Modified('Y'); /*Bug 6407303, Set the parameter */
        INV_ITEM_API.Update_Item_Row
        (
            p_Item_rec          =>  l_Item_rec
        ,   p_update_Item_TL    =>  l_update_Item_TL
        ,   p_Lang_Flag         =>  l_Lang_Flag
        ,   x_return_status     =>  l_return_status
        );
     END IF;
  END LOOP;  -- loop through org items
  ------------------------------------

  END IF;  -- p_Org is master
  ----------------------------------- p_Org is master ---

  CLOSE INV_ITEM_API.Item_csr;

  IF ( FND_API.to_Boolean (p_commit) ) THEN
     COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
  (   p_count  =>  x_msg_count
  ,   p_data   =>  x_msg_data
  );

EXCEPTION

  WHEN FND_API.g_EXC_ERROR THEN

     IF ( INV_ITEM_API.Item_csr%ISOPEN ) THEN
        CLOSE INV_ITEM_API.Item_csr;
     END IF;

     ROLLBACK TO Update_Org_Items_PVT;
     x_return_status := FND_API.g_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

  WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN

     IF ( INV_ITEM_API.Item_csr%ISOPEN ) THEN
        CLOSE INV_ITEM_API.Item_csr;
     END IF;

     ROLLBACK TO Update_Org_Items_PVT;
     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

  WHEN others THEN

     IF ( INV_ITEM_API.Item_csr%ISOPEN ) THEN
        CLOSE INV_ITEM_API.Item_csr;
     END IF;

     ROLLBACK TO Update_Org_Items_PVT;
     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level
        ( FND_MSG_PUB.g_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg
        (   p_pkg_name         =>  G_PKG_NAME
        ,   p_procedure_name   =>  l_api_name
        ,   p_error_text       =>  'UNEXP_ERROR : ' || SQLERRM
        );
     END IF;

     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

END Update_Org_Items;


/*------------------------------- Get_Org_Item -------------------------------*/

PROCEDURE Get_Org_Item
(
    p_init_msg_list    IN   VARCHAR2       :=  FND_API.g_FALSE
,   p_Item_ID          IN   NUMBER
,   p_Org_ID           IN   NUMBER
,   p_Language         IN   VARCHAR2	   :=  FND_API.g_MISS_CHAR
,   x_Item_rec         OUT  NOCOPY  INV_ITEM_API.Item_rec_type
,   x_return_status    OUT  NOCOPY VARCHAR2
,   x_msg_count        OUT  NOCOPY NUMBER
,   x_msg_data         OUT  NOCOPY VARCHAR2
)
IS
  l_api_name    CONSTANT  VARCHAR2(30)  :=  'Get_Org_Item';
/*
  l_Item_ID         NUMBER ;
  l_Org_ID          NUMBER ;

  l_return_status   VARCHAR2(1) ;
*/
BEGIN

  -- Initialize message list
  --
  IF ( FND_API.to_Boolean (p_init_msg_list) ) THEN
     FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  --
  x_return_status := FND_API.g_RET_STS_SUCCESS;

  IF ( p_Item_ID IS NULL ) OR
     ( p_Org_ID  IS NULL )
  THEN
     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
     fnd_message.SET_NAME( 'INV', 'INV_MISS_OrgItem_ID' );
     FND_MSG_PUB.Add;
     RETURN;
  END IF;

/*
  -- Get the translation row
  --
  IF ( p_Language <> FND_API.g_MISS_CHAR ) THEN

  END IF;
*/

  -----------------------------------
  -- Open item query on base table --
  -----------------------------------

  OPEN INV_ITEM_API.Item_csr
       (
           p_Item_ID        =>  p_Item_ID
       ,   p_Org_ID         =>  p_Org_ID
       ,   p_fetch_Master   =>  FND_API.g_TRUE
       ,   p_fetch_Orgs     =>  FND_API.g_FALSE
       );

  -- Fetch org item row
  --
  FETCH INV_ITEM_API.Item_csr INTO x_Item_rec;

  IF ( INV_ITEM_API.Item_csr%NOTFOUND ) THEN
     CLOSE INV_ITEM_API.Item_csr;
     fnd_message.SET_NAME( 'INV', 'INV_Get_Org_Item_notfound' );
     FND_MSG_PUB.Add;
     RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
  END IF;

  CLOSE INV_ITEM_API.Item_csr;

  FND_MSG_PUB.Count_And_Get
  (   p_count  =>  x_msg_count
  ,   p_data   =>  x_msg_data
  );

EXCEPTION

  WHEN FND_API.g_EXC_ERROR THEN

     IF ( INV_ITEM_API.Item_csr%ISOPEN ) THEN
        CLOSE INV_ITEM_API.Item_csr;
     END IF;

     x_return_status := FND_API.g_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

  WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN

     IF ( INV_ITEM_API.Item_csr%ISOPEN ) THEN
        CLOSE INV_ITEM_API.Item_csr;
     END IF;

     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

  WHEN others THEN

     IF ( INV_ITEM_API.Item_csr%ISOPEN ) THEN
        CLOSE INV_ITEM_API.Item_csr;
     END IF;

     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level
        ( FND_MSG_PUB.g_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg
        (   p_pkg_name         =>  G_PKG_NAME
        ,   p_procedure_name   =>  l_api_name
--        ,   p_error_text       =>  'UNEXP_ERROR : '
        );
     END IF;

     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

END Get_Org_Item;


/*------------------------------ Validate_Item -------------------------------*/


-- Item record validation is currently performed within Update_Org_Items.

/*
PROCEDURE Validate_Item
(
    p_validation_level  IN   NUMBER         :=  FND_API.g_VALID_LEVEL_FULL
,   p_Item_rec          IN   INV_ITEM_API.Item_rec_type
,   x_return_status     OUT  NOCOPY VARCHAR2
,   x_msg_count         OUT  NOCOPY NUMBER
,   x_msg_data          OUT  NOCOPY VARCHAR2
)
IS
  l_api_name    CONSTANT  VARCHAR2(30)  :=  'Validate_Item';

  l_Item_rec        INV_ITEM_API.Item_rec_type ;
  l_Item_ID         NUMBER ;
  l_Org_ID          NUMBER ;

  l_return_status   VARCHAR2(1) ;
BEGIN

  l_Item_ID := p_Item_rec.INVENTORY_ITEM_ID ;
  l_Org_ID  := p_Item_rec.ORGANIZATION_ID ;

  -- Initialize API return status to success
  --
  x_return_status := FND_API.g_RET_STS_SUCCESS;

  IF ( l_Item_ID IS NULL ) OR
     ( l_Org_ID  IS NULL )
  THEN
     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
     fnd_message.SET_NAME( 'INV', 'INV_MISS_OrgItem_ID' );
     FND_MSG_PUB.Add;
     RETURN;
  END IF;

     --
     -- Validate Dependency attributes
     --

     INV_ITEM_Validation.Attribute_Dependency
     (
         p_Item_rec        =>  p_Item_rec
     ,   x_return_status   =>  l_return_status
     );

     -- Raise an error as soon as the first fault is encountered

     IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
        RAISE FND_API.g_EXC_ERROR;
     ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
     END IF;

     --
     -- Validate Effectivity_Control attribute
     --

     INV_ITEM_Validation.Effectivity_Control
     (
         p_Item_rec        =>  p_Item_rec
     ,   x_return_status   =>  l_return_status
     );

     IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
        RAISE FND_API.g_EXC_ERROR;
     ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
     END IF;

     --
     --

  FND_MSG_PUB.Count_And_Get
  (   p_count  =>  x_msg_count
  ,   p_data   =>  x_msg_data
  );

EXCEPTION

  WHEN FND_API.g_EXC_ERROR THEN
     x_return_status := FND_API.g_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

  WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

  WHEN OTHERS THEN
     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level
        ( FND_MSG_PUB.g_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg
        (   p_pkg_name         =>  G_PKG_NAME
        ,   p_procedure_name   =>  l_api_name
--        ,   p_error_text       =>  'UNEXP_ERROR : XXX'
        );
     END IF;

     FND_MSG_PUB.Count_And_Get
     (   p_count  =>  x_msg_count
     ,   p_data   =>  x_msg_data
     );

END Validate_Item;
*/

PROCEDURE get_segments_string(
   P_Segment_Rec     IN     INV_ITEM_API.Item_rec_type
  ,P_Segment_String  OUT    NOCOPY VARCHAR2)
IS
   l_segment_string VARCHAR2(2000) := NULL ;
BEGIN

   IF P_Segment_Rec.segment1  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT1  = '''|| REPLACE(P_Segment_Rec.segment1,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT1 is NULL';
   END IF;
   IF P_Segment_Rec.segment2  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT2  = '''|| REPLACE(P_Segment_Rec.segment2,'''','''''')||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT2 is NULL';
   END IF;
   IF P_Segment_Rec.segment3  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT3  = '''|| REPLACE(P_Segment_Rec.segment3,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT3 is NULL';
   END IF;
   IF P_Segment_Rec.segment4  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT4  = '''|| REPLACE(P_Segment_Rec.segment4,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT4 is NULL';
   END IF;
   IF P_Segment_Rec.segment5  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT5  = '''|| REPLACE(P_Segment_Rec.segment5,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT5 is NULL';
   END IF;
   IF P_Segment_Rec.segment6  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT6  = '''|| REPLACE(P_Segment_Rec.segment6,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT6 is NULL';
   END IF;
   IF P_Segment_Rec.segment7  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT7  = '''|| REPLACE(P_Segment_Rec.segment7,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT7 is NULL';
   END IF;
   IF P_Segment_Rec.segment8  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT8  = '''|| REPLACE(P_Segment_Rec.segment8,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT8 is NULL';
   END IF;
   IF P_Segment_Rec.segment9  IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT9  = '''|| REPLACE(P_Segment_Rec.segment9,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT9 is NULL';
   END IF;
   IF P_Segment_Rec.segment10 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT10 = '''|| REPLACE(P_Segment_Rec.segment10,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT10 is NULL';
   END IF;
   IF P_Segment_Rec.segment11 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT11 = '''|| REPLACE(P_Segment_Rec.segment11,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT11 is NULL';
   END IF;
   IF P_Segment_Rec.segment12 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT12 = '''|| REPLACE(P_Segment_Rec.segment12,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT12 is NULL';
   END IF;
   IF P_Segment_Rec.segment13 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT13 = '''|| REPLACE(P_Segment_Rec.segment13,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT13 is NULL';
   END IF;
   IF P_Segment_Rec.segment14 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT14 = '''|| REPLACE(P_Segment_Rec.segment14,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT14 is NULL';
   END IF;
   IF P_Segment_Rec.segment15 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT15 = '''||REPLACE(P_Segment_Rec.segment15,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT15 is NULL';
   END IF;
   IF P_Segment_Rec.segment16 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT16 = '''|| REPLACE(P_Segment_Rec.segment16,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT16 is NULL';
   END IF;
   IF P_Segment_Rec.segment17 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT17 = '''|| REPLACE(P_Segment_Rec.segment17,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT17 is NULL';
   END IF;
   IF P_Segment_Rec.segment18 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT18 = '''|| REPLACE(P_Segment_Rec.segment18,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT18 is NULL';
   END IF;
   IF P_Segment_Rec.segment19 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT19 = '''|| REPLACE(P_Segment_Rec.segment19,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT19 is NULL';
   END IF;
   IF P_Segment_Rec.segment20 IS NOT NULL THEN
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT20 = '''|| REPLACE(P_Segment_Rec.segment20,'''','''''') ||'''';
   ELSE
      l_segment_string := l_segment_string || ' AND MSI.SEGMENT20 is NULL';
   END IF;

   P_Segment_String := l_segment_string;

END get_segments_string;



PROCEDURE Check_Item_Number (
   P_Segment_Rec            IN     INV_ITEM_API.Item_rec_type
  ,P_Item_Id                IN OUT NOCOPY MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
  ,P_Description            IN OUT NOCOPY MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE
  ,P_unit_of_measure        IN OUT NOCOPY MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE%TYPE
  ,P_Item_Catalog_Group_Id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.ITEM_CATALOG_GROUP_ID%TYPE)
IS

   l_sql_stmt         VARCHAR2(3200);
   l_segments_string  VARCHAR2(1000);
   l_cursor           INTEGER := NULL;
   l_rows_processed   INTEGER := NULL;

BEGIN

   l_sql_stmt := 'SELECT INVENTORY_ITEM_ID,
                       	 ITEM_CATALOG_GROUP_ID,
	          	 PRIMARY_UNIT_OF_MEASURE,
		       	 DESCRIPTION
	           FROM	 MTL_SYSTEM_ITEMS_B_KFV MSI,
			 MTL_PARAMETERS P
	           WHERE MSI.ORGANIZATION_ID = P.ORGANIZATION_ID ';

   get_segments_string(P_Segment_Rec    => P_Segment_Rec
                      ,P_Segment_String => l_segments_string);

   IF (l_segments_string IS NOT NULL) THEN
      l_sql_stmt := l_sql_stmt || l_segments_string;
   END IF;

   l_sql_stmt := l_sql_stmt || ' ORDER BY MSI.CREATION_DATE ';

   l_cursor := DBMS_SQL.OPEN_CURSOR;

   DBMS_SQL.PARSE( l_cursor, l_sql_stmt , DBMS_SQL.NATIVE );
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, P_Item_Id);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 2, P_Item_Catalog_Group_Id);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 3, P_unit_of_measure,25);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 4, P_Description,240);

   l_rows_processed := DBMS_SQL.EXECUTE(l_cursor);

   IF ( DBMS_SQL.FETCH_ROWS(l_cursor) > 0 ) THEN
      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, P_Item_Id);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 2, P_Item_Catalog_Group_Id);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 3, P_unit_of_measure);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 4, P_Description);
   ELSE
      P_Item_Id               := NULL;
      P_Description           := NULL;
      P_unit_of_measure       := NULL;
      P_Item_Catalog_Group_Id := NULL;
   END IF;

   DBMS_SQL.CLOSE_CURSOR(l_cursor);

EXCEPTION
   WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(l_cursor);
      END IF;
      RAISE;
END Check_Item_Number;

PROCEDURE Insert_Row(P_Item_Rec           IN     INV_ITEM_API.Item_rec_type
                    ,x_row_Id             OUT    NOCOPY ROWID)
IS

   CURSOR c_ego_exists IS
      SELECT  'Y'
      FROM    FND_OBJECTS
      WHERE   OBJ_NAME ='EGO_ITEM';

   l_Inventory_Item_ID        NUMBER  :=  P_Item_Rec.INVENTORY_ITEM_ID;
   l_Organization_ID          NUMBER  :=  P_Item_Rec.ORGANIZATION_ID;

   l_return_status            VARCHAR2(1);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);

   -- Variables holding derived attribute values.

   l_Primary_Unit_of_Measure    VARCHAR2(25);
   l_SERVICE_ITEM_FLAG          VARCHAR2(1);
   l_VENDOR_WARRANTY_FLAG       VARCHAR2(1);
   l_USAGE_ITEM_FLAG            VARCHAR2(1);
   l_party_id                   FND_USER.CUSTOMER_ID%TYPE;
   l_grant_guid                 fnd_grants.grant_guid%TYPE;
   l_ego_exists                 VARCHAR2(1) := 'N';
   l_master_org                 VARCHAR2(1); --R12: Business Events
   l_mast_organization_id       MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE;

BEGIN
   -- Primary_Unit_of_Measure lookup

   SELECT  unit_of_measure	--* Bug 5192495 reverted Bug 4465182 Select translated unit of measure value
   INTO    l_Primary_Unit_of_Measure
   FROM    mtl_units_of_measure_vl
   WHERE   uom_code = P_Item_Rec.PRIMARY_UOM_CODE;

   -- Get derived attribute values.
   -- Service Item, Warranty, Usage flag attributes are dependent on
   -- and derived from Contract Item Type; supported for view only.

   IF ( P_Item_Rec.CONTRACT_ITEM_TYPE_CODE = 'SERVICE' ) THEN
      l_SERVICE_ITEM_FLAG    := 'Y';
      l_VENDOR_WARRANTY_FLAG := 'N';
      l_USAGE_ITEM_FLAG      := NULL;
   ELSIF ( P_Item_Rec.CONTRACT_ITEM_TYPE_CODE = 'WARRANTY' ) THEN
      l_SERVICE_ITEM_FLAG    := 'Y';
      l_VENDOR_WARRANTY_FLAG := 'Y';
      l_USAGE_ITEM_FLAG      := NULL;
   ELSIF ( P_Item_Rec.CONTRACT_ITEM_TYPE_CODE = 'USAGE' ) THEN
      l_SERVICE_ITEM_FLAG    := 'N';
      l_VENDOR_WARRANTY_FLAG := 'N';
      l_USAGE_ITEM_FLAG      := 'Y';
   ELSE
      l_SERVICE_ITEM_FLAG    := 'N';
      l_VENDOR_WARRANTY_FLAG := 'N';
      l_USAGE_ITEM_FLAG      := NULL;
   END IF;

   INSERT INTO MTL_SYSTEM_ITEMS_B(
    DESCRIPTION,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    SUMMARY_FLAG,
    ENABLED_FLAG,
--    START_DATE_ACTIVE,     Commented for Bug: 4457440
--    END_DATE_ACTIVE,       Commented for Bug: 4457440
    PRIMARY_UOM_CODE,
    PRIMARY_UNIT_OF_MEASURE,
    ALLOWED_UNITS_LOOKUP_CODE,
    OVERCOMPLETION_TOLERANCE_TYPE,
    OVERCOMPLETION_TOLERANCE_VALUE,
    EFFECTIVITY_CONTROL,
    CHECK_SHORTAGES_FLAG,
    FULL_LEAD_TIME,
    ORDER_COST,
    MRP_SAFETY_STOCK_PERCENT,
    MRP_SAFETY_STOCK_CODE,
    MIN_MINMAX_QUANTITY,
    MAX_MINMAX_QUANTITY,
    MINIMUM_ORDER_QUANTITY,
    FIXED_ORDER_QUANTITY,
    FIXED_DAYS_SUPPLY,
    MAXIMUM_ORDER_QUANTITY,
    ATP_RULE_ID,
    PICKING_RULE_ID,
    RESERVABLE_TYPE,
    POSITIVE_MEASUREMENT_ERROR,
    NEGATIVE_MEASUREMENT_ERROR,
    ENGINEERING_ECN_CODE,
    ENGINEERING_ITEM_ID,
    ENGINEERING_DATE,
    SERVICE_STARTING_DELAY,
    SERVICEABLE_COMPONENT_FLAG,
    SERVICEABLE_PRODUCT_FLAG,
    PAYMENT_TERMS_ID,
    PREVENTIVE_MAINTENANCE_FLAG,
    MATERIAL_BILLABLE_FLAG,
    PRORATE_SERVICE_FLAG,
    COVERAGE_SCHEDULE_ID,
    SERVICE_DURATION_PERIOD_CODE,
    SERVICE_DURATION,
    INVOICEABLE_ITEM_FLAG,
    TAX_CODE,
    INVOICE_ENABLED_FLAG,
    MUST_USE_APPROVED_VENDOR_FLAG,
    OUTSIDE_OPERATION_FLAG,
    OUTSIDE_OPERATION_UOM_TYPE,
    SAFETY_STOCK_BUCKET_DAYS,
    AUTO_REDUCE_MPS,
    COSTING_ENABLED_FLAG,
    AUTO_CREATED_CONFIG_FLAG,
    CYCLE_COUNT_ENABLED_FLAG,
    ITEM_TYPE,
    MODEL_CONFIG_CLAUSE_NAME,
    SHIP_MODEL_COMPLETE_FLAG,
    MRP_PLANNING_CODE,
    RETURN_INSPECTION_REQUIREMENT,
    ATO_FORECAST_CONTROL,
    RELEASE_TIME_FENCE_CODE,
    RELEASE_TIME_FENCE_DAYS,
    CONTAINER_ITEM_FLAG,
    VEHICLE_ITEM_FLAG,
    MAXIMUM_LOAD_WEIGHT,
    MINIMUM_FILL_PERCENT,
    CONTAINER_TYPE_CODE,
    INTERNAL_VOLUME,
   -- PRODUCT_FAMILY_ITEM_ID,   - Bug 4408694
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
    GLOBAL_ATTRIBUTE20,
    PURCHASING_TAX_CODE,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    PURCHASING_ITEM_FLAG,
    SHIPPABLE_ITEM_FLAG,
    CUSTOMER_ORDER_FLAG,
    INTERNAL_ORDER_FLAG,
    INVENTORY_ITEM_FLAG,
    ENG_ITEM_FLAG,
    INVENTORY_ASSET_FLAG,
    PURCHASING_ENABLED_FLAG,
    CUSTOMER_ORDER_ENABLED_FLAG,
    INTERNAL_ORDER_ENABLED_FLAG,
    SO_TRANSACTIONS_FLAG,
    MTL_TRANSACTIONS_ENABLED_FLAG,
    STOCK_ENABLED_FLAG,
    BOM_ENABLED_FLAG,
    BUILD_IN_WIP_FLAG,
    REVISION_QTY_CONTROL_CODE,
    ITEM_CATALOG_GROUP_ID,
    CATALOG_STATUS_FLAG,
    RETURNABLE_FLAG,
    DEFAULT_SHIPPING_ORG,
    COLLATERAL_FLAG,
    TAXABLE_FLAG,
    QTY_RCV_EXCEPTION_CODE,
    ALLOW_ITEM_DESC_UPDATE_FLAG,
    INSPECTION_REQUIRED_FLAG,
    RECEIPT_REQUIRED_FLAG,
    MARKET_PRICE,
    HAZARD_CLASS_ID,
    RFQ_REQUIRED_FLAG,
    QTY_RCV_TOLERANCE,
    LIST_PRICE_PER_UNIT,
    UN_NUMBER_ID,
    PRICE_TOLERANCE_PERCENT,
    ASSET_CATEGORY_ID,
    ROUNDING_FACTOR,
    UNIT_OF_ISSUE,
    ENFORCE_SHIP_TO_LOCATION_CODE,
    ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
    ALLOW_UNORDERED_RECEIPTS_FLAG,
    ALLOW_EXPRESS_DELIVERY_FLAG,
    DAYS_EARLY_RECEIPT_ALLOWED,
    DAYS_LATE_RECEIPT_ALLOWED,
    RECEIPT_DAYS_EXCEPTION_CODE,
    RECEIVING_ROUTING_ID,
    INVOICE_CLOSE_TOLERANCE,
    RECEIVE_CLOSE_TOLERANCE,
    AUTO_LOT_ALPHA_PREFIX,
    START_AUTO_LOT_NUMBER,
    LOT_CONTROL_CODE,
    SHELF_LIFE_CODE,
    SHELF_LIFE_DAYS,
    SERIAL_NUMBER_CONTROL_CODE,
    START_AUTO_SERIAL_NUMBER,
    AUTO_SERIAL_ALPHA_PREFIX,
    SOURCE_TYPE,
    SOURCE_ORGANIZATION_ID,
    SOURCE_SUBINVENTORY,
    EXPENSE_ACCOUNT,
    ENCUMBRANCE_ACCOUNT,
    RESTRICT_SUBINVENTORIES_CODE,
    UNIT_WEIGHT,
    WEIGHT_UOM_CODE,
    VOLUME_UOM_CODE,
    UNIT_VOLUME,
    RESTRICT_LOCATORS_CODE,
    LOCATION_CONTROL_CODE,
    SHRINKAGE_RATE,
    ACCEPTABLE_EARLY_DAYS,
    PLANNING_TIME_FENCE_CODE,
    DEMAND_TIME_FENCE_CODE,
    LEAD_TIME_LOT_SIZE,
    STD_LOT_SIZE,
    CUM_MANUFACTURING_LEAD_TIME,
    OVERRUN_PERCENTAGE,
    MRP_CALCULATE_ATP_FLAG,
    ACCEPTABLE_RATE_INCREASE,
    ACCEPTABLE_RATE_DECREASE,
    CUMULATIVE_TOTAL_LEAD_TIME,
    PLANNING_TIME_FENCE_DAYS,
    DEMAND_TIME_FENCE_DAYS,
    END_ASSEMBLY_PEGGING_FLAG,
    REPETITIVE_PLANNING_FLAG,
    PLANNING_EXCEPTION_SET,
    BOM_ITEM_TYPE,
    PICK_COMPONENTS_FLAG,
    REPLENISH_TO_ORDER_FLAG,
    BASE_ITEM_ID,
    ATP_COMPONENTS_FLAG,
    ATP_FLAG,
    FIXED_LEAD_TIME,
    VARIABLE_LEAD_TIME,
    WIP_SUPPLY_LOCATOR_ID,
    WIP_SUPPLY_TYPE,
    WIP_SUPPLY_SUBINVENTORY,
    COST_OF_SALES_ACCOUNT,
    SALES_ACCOUNT,
    DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
    INVENTORY_ITEM_STATUS_CODE,
    INVENTORY_PLANNING_CODE,
    PLANNER_CODE,
    PLANNING_MAKE_BUY_CODE,
    FIXED_LOT_MULTIPLIER,
    ROUNDING_CONTROL_TYPE,
    CARRYING_COST,
    POSTPROCESSING_LEAD_TIME,
    PREPROCESSING_LEAD_TIME,
    BUYER_ID,
    ACCOUNTING_RULE_ID,
    INVOICING_RULE_ID,
    OVER_SHIPMENT_TOLERANCE,
    UNDER_SHIPMENT_TOLERANCE,
    OVER_RETURN_TOLERANCE,
    UNDER_RETURN_TOLERANCE,
    EQUIPMENT_TYPE,
    RECOVERED_PART_DISP_CODE,
    DEFECT_TRACKING_ON_FLAG,
    EVENT_FLAG,
    ELECTRONIC_FLAG,
    DOWNLOADABLE_FLAG,
    VOL_DISCOUNT_EXEMPT_FLAG,
    COUPON_EXEMPT_FLAG,
    COMMS_NL_TRACKABLE_FLAG,
    ASSET_CREATION_CODE,
    COMMS_ACTIVATION_REQD_FLAG,
    ORDERABLE_ON_WEB_FLAG,
    BACK_ORDERABLE_FLAG,
    WEB_STATUS,
    INDIVISIBLE_FLAG,
    DIMENSION_UOM_CODE,
    UNIT_LENGTH,
    UNIT_WIDTH,
    UNIT_HEIGHT,
    BULK_PICKED_FLAG,
    LOT_STATUS_ENABLED,
    DEFAULT_LOT_STATUS_ID,
    SERIAL_STATUS_ENABLED,
    DEFAULT_SERIAL_STATUS_ID,
    LOT_SPLIT_ENABLED,
    LOT_MERGE_ENABLED,
    INVENTORY_CARRY_PENALTY,
    OPERATION_SLACK_PENALTY,
    FINANCING_ALLOWED_FLAG,
    EAM_ITEM_TYPE,
    EAM_ACTIVITY_TYPE_CODE,
    EAM_ACTIVITY_CAUSE_CODE,
    EAM_ACT_NOTIFICATION_FLAG,
    EAM_ACT_SHUTDOWN_STATUS,
    DUAL_UOM_CONTROL,
    SECONDARY_UOM_CODE,
    DUAL_UOM_DEVIATION_HIGH,
    DUAL_UOM_DEVIATION_LOW,
    SERVICE_ITEM_FLAG,
    VENDOR_WARRANTY_FLAG,
    USAGE_ITEM_FLAG,
    CONTRACT_ITEM_TYPE_CODE,
    SUBSCRIPTION_DEPEND_FLAG,
    SERV_REQ_ENABLED_CODE,
    SERV_BILLING_ENABLED_FLAG,
    SERV_IMPORTANCE_LEVEL,
    PLANNED_INV_POINT_FLAG,
    LOT_TRANSLATE_ENABLED,
    DEFAULT_SO_SOURCE_TYPE,
    CREATE_SUPPLY_FLAG,
    SUBSTITUTION_WINDOW_CODE,
    SUBSTITUTION_WINDOW_DAYS,
    IB_ITEM_INSTANCE_CLASS,
    CONFIG_MODEL_TYPE,
    --Added as part of 11.5.9 ENH
    LOT_SUBSTITUTION_ENABLED,
    MINIMUM_LICENSE_QUANTITY,
    EAM_ACTIVITY_SOURCE_CODE,
    --Added as part of 11.5.10 ENH
    TRACKING_QUANTITY_IND ,
    ONT_PRICING_QTY_SOURCE,
    SECONDARY_DEFAULT_IND ,
    OPTION_SPECIFIC_SOURCED,
    CONFIG_ORGS,
    CONFIG_MATCH,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT11,
    SEGMENT12,
    SEGMENT13,
    SEGMENT14,
    SEGMENT15,
    SEGMENT16,
    SEGMENT17,
    SEGMENT18,
    SEGMENT19,
    SEGMENT20,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    LIFECYCLE_ID,
    CURRENT_PHASE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN ,
    VMI_MINIMUM_UNITS,
    VMI_MINIMUM_DAYS,
    VMI_MAXIMUM_UNITS,
    VMI_MAXIMUM_DAYS ,
    VMI_FIXED_ORDER_QUANTITY ,
    SO_AUTHORIZATION_FLAG ,
    CONSIGNED_FLAG   ,
    ASN_AUTOEXPIRE_FLAG ,
    VMI_FORECAST_TYPE ,
    FORECAST_HORIZON  ,
    EXCLUDE_FROM_BUDGET_FLAG  ,
    DAYS_TGT_INV_SUPPLY  ,
    DAYS_TGT_INV_WINDOW  ,
    DAYS_MAX_INV_SUPPLY  ,
    DAYS_MAX_INV_WINDOW   ,
    DRP_PLANNED_FLAG     ,
    CRITICAL_COMPONENT_FLAG  ,
    CONTINOUS_TRANSFER   ,
    CONVERGENCE         ,
    DIVERGENCE
    /* Start Bug 3713912 */--Added For R12 ENH
    ,LOT_DIVISIBLE_FLAG,
GRADE_CONTROL_FLAG,
DEFAULT_GRADE,
CHILD_LOT_FLAG,
PARENT_CHILD_GENERATION_FLAG,
CHILD_LOT_PREFIX,
CHILD_LOT_STARTING_NUMBER,
CHILD_LOT_VALIDATION_FLAG,
COPY_LOT_ATTRIBUTE_FLAG,
RECIPE_ENABLED_FLAG,
PROCESS_QUALITY_ENABLED_FLAG,
PROCESS_EXECUTION_ENABLED_FLAG,
PROCESS_COSTING_ENABLED_FLAG,
PROCESS_SUPPLY_SUBINVENTORY,
PROCESS_SUPPLY_LOCATOR_ID,
PROCESS_YIELD_SUBINVENTORY,
PROCESS_YIELD_LOCATOR_ID,
HAZARDOUS_MATERIAL_FLAG,
CAS_NUMBER,
RETEST_INTERVAL,
EXPIRATION_ACTION_INTERVAL,
EXPIRATION_ACTION_CODE,
MATURITY_DAYS,
HOLD_DAYS,
ATTRIBUTE16,
ATTRIBUTE17,
ATTRIBUTE18,
ATTRIBUTE19,
ATTRIBUTE20,
ATTRIBUTE21,
ATTRIBUTE22,
ATTRIBUTE23,
ATTRIBUTE24,
ATTRIBUTE25,
ATTRIBUTE26,
ATTRIBUTE27,
ATTRIBUTE28,
ATTRIBUTE29,
ATTRIBUTE30,
    /* End Bug 3713912 */
    CHARGE_PERIODICITY_CODE,
    REPAIR_LEADTIME,
    REPAIR_YIELD ,
    PREPOSITION_POINT,
    REPAIR_PROGRAM,
    SUBCONTRACTING_COMPONENT,
    OUTSOURCED_ASSEMBLY,
    /*  Bug 4224512 Updating the object version number - Anmurali */
OBJECT_VERSION_NUMBER,
   -- Fix for Bug#6644711
   DEFAULT_MATERIAL_STATUS_ID,
   -- Serial_Tagging Enh -- bug 9913552
   SERIAL_TAGGING_FLAG
    )
   VALUES  (
   ltrim(rtrim(P_Item_Rec.DESCRIPTION)),
    P_Item_Rec.INVENTORY_ITEM_ID,
    P_Item_Rec.ORGANIZATION_ID,
    P_Item_Rec.SUMMARY_FLAG,
    P_Item_Rec.ENABLED_FLAG,
--    P_Item_Rec.START_DATE_ACTIVE,       Commented for Bug: 4457440
--    P_Item_Rec.END_DATE_ACTIVE,         Commented for Bug: 4457440
    P_Item_Rec.PRIMARY_UOM_CODE,
    l_Primary_Unit_of_Measure,
    P_Item_Rec.ALLOWED_UNITS_LOOKUP_CODE,
    P_Item_Rec.OVERCOMPLETION_TOLERANCE_TYPE,
    P_Item_Rec.OVERCOMPLETION_TOLERANCE_VALUE,
    P_Item_Rec.EFFECTIVITY_CONTROL,
    P_Item_Rec.CHECK_SHORTAGES_FLAG,
    P_Item_Rec.FULL_LEAD_TIME,
    P_Item_Rec.ORDER_COST,
    P_Item_Rec.MRP_SAFETY_STOCK_PERCENT,
    P_Item_Rec.MRP_SAFETY_STOCK_CODE,
    P_Item_Rec.MIN_MINMAX_QUANTITY,
    P_Item_Rec.MAX_MINMAX_QUANTITY,
    P_Item_Rec.MINIMUM_ORDER_QUANTITY,
    P_Item_Rec.FIXED_ORDER_QUANTITY,
    P_Item_Rec.FIXED_DAYS_SUPPLY,
    P_Item_Rec.MAXIMUM_ORDER_QUANTITY,
    P_Item_Rec.ATP_RULE_ID,
    P_Item_Rec.PICKING_RULE_ID,
    P_Item_Rec.RESERVABLE_TYPE,
    P_Item_Rec.POSITIVE_MEASUREMENT_ERROR,
    P_Item_Rec.NEGATIVE_MEASUREMENT_ERROR,
    P_Item_Rec.ENGINEERING_ECN_CODE,
    P_Item_Rec.ENGINEERING_ITEM_ID,
    P_Item_Rec.ENGINEERING_DATE,
    P_Item_Rec.SERVICE_STARTING_DELAY,
    P_Item_Rec.SERVICEABLE_COMPONENT_FLAG,
    P_Item_Rec.SERVICEABLE_PRODUCT_FLAG,
    P_Item_Rec.PAYMENT_TERMS_ID,
    P_Item_Rec.PREVENTIVE_MAINTENANCE_FLAG,
    P_Item_Rec.MATERIAL_BILLABLE_FLAG,
    P_Item_Rec.PRORATE_SERVICE_FLAG,
    P_Item_Rec.COVERAGE_SCHEDULE_ID,
    P_Item_Rec.SERVICE_DURATION_PERIOD_CODE,
    P_Item_Rec.SERVICE_DURATION,
    P_Item_Rec.INVOICEABLE_ITEM_FLAG,
    P_Item_Rec.TAX_CODE,
    P_Item_Rec.INVOICE_ENABLED_FLAG,
    P_Item_Rec.MUST_USE_APPROVED_VENDOR_FLAG,
    P_Item_Rec.OUTSIDE_OPERATION_FLAG,
    P_Item_Rec.OUTSIDE_OPERATION_UOM_TYPE,
    P_Item_Rec.SAFETY_STOCK_BUCKET_DAYS,
    P_Item_Rec.AUTO_REDUCE_MPS,
    P_Item_Rec.COSTING_ENABLED_FLAG,
    P_Item_Rec.AUTO_CREATED_CONFIG_FLAG,
    P_Item_Rec.CYCLE_COUNT_ENABLED_FLAG,
    P_Item_Rec.ITEM_TYPE,
    P_Item_Rec.MODEL_CONFIG_CLAUSE_NAME,
    P_Item_Rec.SHIP_MODEL_COMPLETE_FLAG,
    P_Item_Rec.MRP_PLANNING_CODE,
    P_Item_Rec.RETURN_INSPECTION_REQUIREMENT,
    P_Item_Rec.ATO_FORECAST_CONTROL,
    P_Item_Rec.RELEASE_TIME_FENCE_CODE,
    P_Item_Rec.RELEASE_TIME_FENCE_DAYS,
    P_Item_Rec.CONTAINER_ITEM_FLAG,
    P_Item_Rec.VEHICLE_ITEM_FLAG,
    P_Item_Rec.MAXIMUM_LOAD_WEIGHT,
    P_Item_Rec.MINIMUM_FILL_PERCENT,
    P_Item_Rec.CONTAINER_TYPE_CODE,
    P_Item_Rec.INTERNAL_VOLUME,
 --   P_Item_Rec.PRODUCT_FAMILY_ITEM_ID,   - Bug 4408694
    P_Item_Rec.GLOBAL_ATTRIBUTE_CATEGORY,
    P_Item_Rec.GLOBAL_ATTRIBUTE1,
    P_Item_Rec.GLOBAL_ATTRIBUTE2,
    P_Item_Rec.GLOBAL_ATTRIBUTE3,
    P_Item_Rec.GLOBAL_ATTRIBUTE4,
    P_Item_Rec.GLOBAL_ATTRIBUTE5,
    P_Item_Rec.GLOBAL_ATTRIBUTE6,
    P_Item_Rec.GLOBAL_ATTRIBUTE7,
    P_Item_Rec.GLOBAL_ATTRIBUTE8,
    P_Item_Rec.GLOBAL_ATTRIBUTE9,
    P_Item_Rec.GLOBAL_ATTRIBUTE10,
    P_Item_Rec.GLOBAL_ATTRIBUTE11,
    P_Item_Rec.GLOBAL_ATTRIBUTE12,
    P_Item_Rec.GLOBAL_ATTRIBUTE13,
    P_Item_Rec.GLOBAL_ATTRIBUTE14,
    P_Item_Rec.GLOBAL_ATTRIBUTE15,
    P_Item_Rec.GLOBAL_ATTRIBUTE16,
    P_Item_Rec.GLOBAL_ATTRIBUTE17,
    P_Item_Rec.GLOBAL_ATTRIBUTE18,
    P_Item_Rec.GLOBAL_ATTRIBUTE19,
    P_Item_Rec.GLOBAL_ATTRIBUTE20,
    P_Item_Rec.PURCHASING_TAX_CODE,
    P_Item_Rec.ATTRIBUTE6,
    P_Item_Rec.ATTRIBUTE7,
    P_Item_Rec.ATTRIBUTE8,
    P_Item_Rec.ATTRIBUTE9,
    P_Item_Rec.ATTRIBUTE10,
    P_Item_Rec.ATTRIBUTE11,
    P_Item_Rec.ATTRIBUTE12,
    P_Item_Rec.ATTRIBUTE13,
    P_Item_Rec.ATTRIBUTE14,
    P_Item_Rec.ATTRIBUTE15,
    P_Item_Rec.PURCHASING_ITEM_FLAG,
    P_Item_Rec.SHIPPABLE_ITEM_FLAG,
    P_Item_Rec.CUSTOMER_ORDER_FLAG,
    P_Item_Rec.INTERNAL_ORDER_FLAG,
    P_Item_Rec.INVENTORY_ITEM_FLAG,
    P_Item_Rec.ENG_ITEM_FLAG,
    P_Item_Rec.INVENTORY_ASSET_FLAG,
    P_Item_Rec.PURCHASING_ENABLED_FLAG,
    P_Item_Rec.CUSTOMER_ORDER_ENABLED_FLAG,
    P_Item_Rec.INTERNAL_ORDER_ENABLED_FLAG,
    P_Item_Rec.SO_TRANSACTIONS_FLAG,
    P_Item_Rec.MTL_TRANSACTIONS_ENABLED_FLAG,
    P_Item_Rec.STOCK_ENABLED_FLAG,
    P_Item_Rec.BOM_ENABLED_FLAG,
    P_Item_Rec.BUILD_IN_WIP_FLAG,
    P_Item_Rec.REVISION_QTY_CONTROL_CODE,
    P_Item_Rec.ITEM_CATALOG_GROUP_ID, --Bug: 2805253 NVL(P_Item_Rec.ITEM_CATALOG_GROUP_ID,1),
    P_Item_Rec.CATALOG_STATUS_FLAG,
    P_Item_Rec.RETURNABLE_FLAG,
    P_Item_Rec.DEFAULT_SHIPPING_ORG,
    P_Item_Rec.COLLATERAL_FLAG,
    P_Item_Rec.TAXABLE_FLAG,
    P_Item_Rec.QTY_RCV_EXCEPTION_CODE,
    P_Item_Rec.ALLOW_ITEM_DESC_UPDATE_FLAG,
    P_Item_Rec.INSPECTION_REQUIRED_FLAG,
    P_Item_Rec.RECEIPT_REQUIRED_FLAG,
    P_Item_Rec.MARKET_PRICE,
    P_Item_Rec.HAZARD_CLASS_ID,
    P_Item_Rec.RFQ_REQUIRED_FLAG,
    P_Item_Rec.QTY_RCV_TOLERANCE,
    P_Item_Rec.LIST_PRICE_PER_UNIT,
    P_Item_Rec.UN_NUMBER_ID,
    P_Item_Rec.PRICE_TOLERANCE_PERCENT,
    P_Item_Rec.ASSET_CATEGORY_ID,
    P_Item_Rec.ROUNDING_FACTOR,
    P_Item_Rec.UNIT_OF_ISSUE,
    P_Item_Rec.ENFORCE_SHIP_TO_LOCATION_CODE,
    P_Item_Rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
    P_Item_Rec.ALLOW_UNORDERED_RECEIPTS_FLAG,
    P_Item_Rec.ALLOW_EXPRESS_DELIVERY_FLAG,
    P_Item_Rec.DAYS_EARLY_RECEIPT_ALLOWED,
    P_Item_Rec.DAYS_LATE_RECEIPT_ALLOWED,
    P_Item_Rec.RECEIPT_DAYS_EXCEPTION_CODE,
    P_Item_Rec.RECEIVING_ROUTING_ID,
    P_Item_Rec.INVOICE_CLOSE_TOLERANCE,
    P_Item_Rec.RECEIVE_CLOSE_TOLERANCE,
    P_Item_Rec.AUTO_LOT_ALPHA_PREFIX,
    P_Item_Rec.START_AUTO_LOT_NUMBER,
    P_Item_Rec.LOT_CONTROL_CODE,
    P_Item_Rec.SHELF_LIFE_CODE,
    P_Item_Rec.SHELF_LIFE_DAYS,
    P_Item_Rec.SERIAL_NUMBER_CONTROL_CODE,
    P_Item_Rec.START_AUTO_SERIAL_NUMBER,
    P_Item_Rec.AUTO_SERIAL_ALPHA_PREFIX,
    P_Item_Rec.SOURCE_TYPE,
    P_Item_Rec.SOURCE_ORGANIZATION_ID,
    P_Item_Rec.SOURCE_SUBINVENTORY,
    P_Item_Rec.EXPENSE_ACCOUNT,
    P_Item_Rec.ENCUMBRANCE_ACCOUNT,
    P_Item_Rec.RESTRICT_SUBINVENTORIES_CODE,
    P_Item_Rec.UNIT_WEIGHT,
    P_Item_Rec.WEIGHT_UOM_CODE,
    P_Item_Rec.VOLUME_UOM_CODE,
    P_Item_Rec.UNIT_VOLUME,
    P_Item_Rec.RESTRICT_LOCATORS_CODE,
    P_Item_Rec.LOCATION_CONTROL_CODE,
    P_Item_Rec.SHRINKAGE_RATE,
    P_Item_Rec.ACCEPTABLE_EARLY_DAYS,
    P_Item_Rec.PLANNING_TIME_FENCE_CODE,
    P_Item_Rec.DEMAND_TIME_FENCE_CODE,
    P_Item_Rec.LEAD_TIME_LOT_SIZE,
    P_Item_Rec.STD_LOT_SIZE,
    P_Item_Rec.CUM_MANUFACTURING_LEAD_TIME,
    P_Item_Rec.OVERRUN_PERCENTAGE,
    P_Item_Rec.MRP_CALCULATE_ATP_FLAG,
    P_Item_Rec.ACCEPTABLE_RATE_INCREASE,
    P_Item_Rec.ACCEPTABLE_RATE_DECREASE,
    P_Item_Rec.CUMULATIVE_TOTAL_LEAD_TIME,
    P_Item_Rec.PLANNING_TIME_FENCE_DAYS,
    P_Item_Rec.DEMAND_TIME_FENCE_DAYS,
    P_Item_Rec.END_ASSEMBLY_PEGGING_FLAG,
    P_Item_Rec.REPETITIVE_PLANNING_FLAG,
    P_Item_Rec.PLANNING_EXCEPTION_SET,
    P_Item_Rec.BOM_ITEM_TYPE,
    P_Item_Rec.PICK_COMPONENTS_FLAG,
    P_Item_Rec.REPLENISH_TO_ORDER_FLAG,
    P_Item_Rec.BASE_ITEM_ID,
    P_Item_Rec.ATP_COMPONENTS_FLAG,
    P_Item_Rec.ATP_FLAG,
    P_Item_Rec.FIXED_LEAD_TIME,
    P_Item_Rec.VARIABLE_LEAD_TIME,
    P_Item_Rec.WIP_SUPPLY_LOCATOR_ID,
    P_Item_Rec.WIP_SUPPLY_TYPE,
    P_Item_Rec.WIP_SUPPLY_SUBINVENTORY,
    P_Item_Rec.COST_OF_SALES_ACCOUNT,
    P_Item_Rec.SALES_ACCOUNT,
    P_Item_Rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
    P_Item_Rec.INVENTORY_ITEM_STATUS_CODE,
    P_Item_Rec.INVENTORY_PLANNING_CODE,
    P_Item_Rec.PLANNER_CODE,
    P_Item_Rec.PLANNING_MAKE_BUY_CODE,
    P_Item_Rec.FIXED_LOT_MULTIPLIER,
    P_Item_Rec.ROUNDING_CONTROL_TYPE,
    P_Item_Rec.CARRYING_COST,
    P_Item_Rec.POSTPROCESSING_LEAD_TIME,
    P_Item_Rec.PREPROCESSING_LEAD_TIME,
    P_Item_Rec.BUYER_ID,
    P_Item_Rec.ACCOUNTING_RULE_ID,
    P_Item_Rec.INVOICING_RULE_ID,
    P_Item_Rec.OVER_SHIPMENT_TOLERANCE,
    P_Item_Rec.UNDER_SHIPMENT_TOLERANCE,
    P_Item_Rec.OVER_RETURN_TOLERANCE,
    P_Item_Rec.UNDER_RETURN_TOLERANCE,
    P_Item_Rec.EQUIPMENT_TYPE,
    P_Item_Rec.RECOVERED_PART_DISP_CODE,
    P_Item_Rec.DEFECT_TRACKING_ON_FLAG,
    P_Item_Rec.EVENT_FLAG,
    P_Item_Rec.ELECTRONIC_FLAG,
    P_Item_Rec.DOWNLOADABLE_FLAG,
    P_Item_Rec.VOL_DISCOUNT_EXEMPT_FLAG,
    P_Item_Rec.COUPON_EXEMPT_FLAG,
    P_Item_Rec.COMMS_NL_TRACKABLE_FLAG,
    P_Item_Rec.ASSET_CREATION_CODE,
    P_Item_Rec.COMMS_ACTIVATION_REQD_FLAG,
    P_Item_Rec.ORDERABLE_ON_WEB_FLAG,
    P_Item_Rec.BACK_ORDERABLE_FLAG,
    P_Item_Rec.WEB_STATUS,
    P_Item_Rec.INDIVISIBLE_FLAG,
    P_Item_Rec.DIMENSION_UOM_CODE,
    P_Item_Rec.UNIT_LENGTH,
    P_Item_Rec.UNIT_WIDTH,
    P_Item_Rec.UNIT_HEIGHT,
    P_Item_Rec.BULK_PICKED_FLAG,
    P_Item_Rec.LOT_STATUS_ENABLED,
    P_Item_Rec.DEFAULT_LOT_STATUS_ID,
    P_Item_Rec.SERIAL_STATUS_ENABLED,
    P_Item_Rec.DEFAULT_SERIAL_STATUS_ID,
    P_Item_Rec.LOT_SPLIT_ENABLED,
    P_Item_Rec.LOT_MERGE_ENABLED,
    P_Item_Rec.INVENTORY_CARRY_PENALTY,
    P_Item_Rec.OPERATION_SLACK_PENALTY,
    P_Item_Rec.FINANCING_ALLOWED_FLAG,
    P_Item_Rec.EAM_ITEM_TYPE,
    P_Item_Rec.EAM_ACTIVITY_TYPE_CODE,
    P_Item_Rec.EAM_ACTIVITY_CAUSE_CODE,
    P_Item_Rec.EAM_ACT_NOTIFICATION_FLAG,
    P_Item_Rec.EAM_ACT_SHUTDOWN_STATUS,
    P_Item_Rec.DUAL_UOM_CONTROL,
    P_Item_Rec.SECONDARY_UOM_CODE,
    P_Item_Rec.DUAL_UOM_DEVIATION_HIGH,
    P_Item_Rec.DUAL_UOM_DEVIATION_LOW,
    l_SERVICE_ITEM_FLAG,
    l_VENDOR_WARRANTY_FLAG,
    l_USAGE_ITEM_FLAG,
    P_Item_Rec.CONTRACT_ITEM_TYPE_CODE,
    P_Item_Rec.SUBSCRIPTION_DEPEND_FLAG,
    P_Item_Rec.SERV_REQ_ENABLED_CODE,
    P_Item_Rec.SERV_BILLING_ENABLED_FLAG,
    P_Item_Rec.SERV_IMPORTANCE_LEVEL,
    P_Item_Rec.PLANNED_INV_POINT_FLAG,
    P_Item_Rec.LOT_TRANSLATE_ENABLED,
    P_Item_Rec.DEFAULT_SO_SOURCE_TYPE,
    P_Item_Rec.CREATE_SUPPLY_FLAG,
    P_Item_Rec.SUBSTITUTION_WINDOW_CODE,
    P_Item_Rec.SUBSTITUTION_WINDOW_DAYS,
    P_Item_Rec.IB_ITEM_INSTANCE_CLASS,
    P_Item_Rec.CONFIG_MODEL_TYPE,
    P_Item_Rec.LOT_SUBSTITUTION_ENABLED,
    P_Item_Rec.MINIMUM_LICENSE_QUANTITY,
    P_Item_Rec.EAM_ACTIVITY_SOURCE_CODE,
-- Added for 11.5.10
    P_Item_Rec.TRACKING_QUANTITY_IND ,
    P_Item_Rec.ONT_PRICING_QTY_SOURCE,
    P_Item_Rec.SECONDARY_DEFAULT_IND ,
    P_Item_Rec.OPTION_SPECIFIC_SOURCED,
    p_Item_rec.CONFIG_ORGS,
    p_Item_rec.CONFIG_MATCH,
    P_Item_Rec.SEGMENT1,
    P_Item_Rec.SEGMENT2,
    P_Item_Rec.SEGMENT3,
    P_Item_Rec.SEGMENT4,
    P_Item_Rec.SEGMENT5,
    P_Item_Rec.SEGMENT6,
    P_Item_Rec.SEGMENT7,
    P_Item_Rec.SEGMENT8,
    P_Item_Rec.SEGMENT9,
    P_Item_Rec.SEGMENT10,
    P_Item_Rec.SEGMENT11,
    P_Item_Rec.SEGMENT12,
    P_Item_Rec.SEGMENT13,
    P_Item_Rec.SEGMENT14,
    P_Item_Rec.SEGMENT15,
    P_Item_Rec.SEGMENT16,
    P_Item_Rec.SEGMENT17,
    P_Item_Rec.SEGMENT18,
    P_Item_Rec.SEGMENT19,
    P_Item_Rec.SEGMENT20,
    P_Item_Rec.ATTRIBUTE_CATEGORY,
    P_Item_Rec.ATTRIBUTE1,
    P_Item_Rec.ATTRIBUTE2,
    P_Item_Rec.ATTRIBUTE3,
    P_Item_Rec.ATTRIBUTE4,
    P_Item_Rec.ATTRIBUTE5,
    P_Item_Rec.LIFECYCLE_ID,
    P_Item_Rec.CURRENT_PHASE_ID,
    P_Item_Rec.CREATION_DATE,
    P_Item_Rec.CREATED_BY,
    P_Item_Rec.LAST_UPDATE_DATE,
    P_Item_Rec.LAST_UPDATED_BY,
    P_Item_Rec.LAST_UPDATE_LOGIN,
    P_Item_Rec.VMI_MINIMUM_UNITS,
    P_Item_Rec.VMI_MINIMUM_DAYS,
    P_Item_Rec.VMI_MAXIMUM_UNITS,
    P_Item_Rec.VMI_MAXIMUM_DAYS ,
    P_Item_Rec.VMI_FIXED_ORDER_QUANTITY ,
    P_Item_Rec.SO_AUTHORIZATION_FLAG ,
    P_Item_Rec.CONSIGNED_FLAG   ,
    P_Item_Rec.ASN_AUTOEXPIRE_FLAG ,
    P_Item_Rec.VMI_FORECAST_TYPE ,
    P_Item_Rec.FORECAST_HORIZON  ,
    P_Item_Rec.EXCLUDE_FROM_BUDGET_FLAG  ,
    P_Item_Rec.DAYS_TGT_INV_SUPPLY  ,
    P_Item_Rec.DAYS_TGT_INV_WINDOW  ,
    P_Item_Rec.DAYS_MAX_INV_SUPPLY  ,
    P_Item_Rec.DAYS_MAX_INV_WINDOW   ,
    P_Item_Rec.DRP_PLANNED_FLAG     ,
    P_Item_Rec.CRITICAL_COMPONENT_FLAG  ,
    P_Item_Rec.CONTINOUS_TRANSFER   ,
    P_Item_Rec.CONVERGENCE         ,
    P_Item_Rec.DIVERGENCE,
    /* Start Bug 3713912 */--Added for R12
    P_Item_rec.LOT_DIVISIBLE_FLAG,
    P_Item_Rec.GRADE_CONTROL_FLAG,
    P_Item_Rec.DEFAULT_GRADE,
    P_Item_Rec.CHILD_LOT_FLAG,
    P_Item_Rec.PARENT_CHILD_GENERATION_FLAG,
    P_Item_Rec.CHILD_LOT_PREFIX,
    P_Item_Rec.CHILD_LOT_STARTING_NUMBER,
    P_Item_Rec.CHILD_LOT_VALIDATION_FLAG,
    P_Item_Rec.COPY_LOT_ATTRIBUTE_FLAG,
    P_Item_Rec.RECIPE_ENABLED_FLAG,
    P_Item_Rec.PROCESS_QUALITY_ENABLED_FLAG,
    P_Item_Rec.PROCESS_EXECUTION_ENABLED_FLAG,
    P_Item_Rec.PROCESS_COSTING_ENABLED_FLAG,
    P_Item_Rec.PROCESS_SUPPLY_SUBINVENTORY,
    P_Item_Rec.PROCESS_SUPPLY_LOCATOR_ID,
    P_Item_Rec.PROCESS_YIELD_SUBINVENTORY,
    P_Item_Rec.PROCESS_YIELD_LOCATOR_ID,
    P_Item_Rec.HAZARDOUS_MATERIAL_FLAG,
    P_Item_Rec.CAS_NUMBER,
    P_Item_Rec.RETEST_INTERVAL,
    P_Item_Rec.EXPIRATION_ACTION_INTERVAL,
    P_Item_Rec.EXPIRATION_ACTION_CODE,
    P_Item_Rec.MATURITY_DAYS,
    P_Item_Rec.HOLD_DAYS,
    P_Item_Rec.ATTRIBUTE16,
    P_Item_Rec.ATTRIBUTE17,
    P_Item_Rec.ATTRIBUTE18,
    P_Item_Rec.ATTRIBUTE19,
    P_Item_Rec.ATTRIBUTE20,
    P_Item_Rec.ATTRIBUTE21,
    P_Item_Rec.ATTRIBUTE22,
    P_Item_Rec.ATTRIBUTE23,
    P_Item_Rec.ATTRIBUTE24,
    P_Item_Rec.ATTRIBUTE25,
    P_Item_Rec.ATTRIBUTE26,
    P_Item_Rec.ATTRIBUTE27,
    P_Item_Rec.ATTRIBUTE28,
    P_Item_Rec.ATTRIBUTE29,
    P_Item_Rec.ATTRIBUTE30,
    /* End Bug 3713912 */
    p_Item_rec.CHARGE_PERIODICITY_CODE,
    p_Item_rec.REPAIR_LEADTIME,
    p_Item_rec.REPAIR_YIELD,
    p_Item_rec.PREPOSITION_POINT,
    p_Item_rec.REPAIR_PROGRAM,
    p_Item_rec.SUBCONTRACTING_COMPONENT,
    p_Item_rec.OUTSOURCED_ASSEMBLY,
   /*  Bug 4224512 Updating the object version number - Anmurali */
   1,
   -- Fix for Bug#6644711
   p_Item_rec.DEFAULT_MATERIAL_STATUS_ID,
   --Serial_Tagging Enh -- bug 9913552
   p_Item_rec.SERIAL_TAGGING_FLAG
   )
    RETURNING ROWID INTO x_row_Id;

   IF (P_Item_Rec.organization_id = Get_Master_Org_ID (P_Item_Rec.organization_id) ) THEN
      -- If the Org is master, insert the source language translated columns
      -- for child organizations.

      INSERT INTO MTL_SYSTEM_ITEMS_TL(
       INVENTORY_ITEM_ID,
       ORGANIZATION_ID,
       LANGUAGE,
       SOURCE_LANG,
       DESCRIPTION,
       LONG_DESCRIPTION,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN )
      SELECT
       P_Item_Rec.INVENTORY_ITEM_ID,
       P_Item_Rec.ORGANIZATION_ID,
       L.LANGUAGE_CODE,
       USERENV('LANG'),
       ltrim(rtrim(P_Item_Rec.DESCRIPTION)),
       ltrim(rtrim(P_Item_Rec.LONG_DESCRIPTION)),
       P_Item_Rec.LAST_UPDATE_DATE,
       P_Item_Rec.LAST_UPDATED_BY,
       P_Item_Rec.CREATION_DATE,
       P_Item_Rec.CREATED_BY,
       P_Item_Rec.LAST_UPDATE_LOGIN
      FROM  FND_LANGUAGES  L
      WHERE  L.INSTALLED_FLAG in ('I', 'B')
      AND  NOT EXISTS
         ( SELECT NULL
           FROM  MTL_SYSTEM_ITEMS_TL  T
           WHERE T.INVENTORY_ITEM_ID = P_Item_Rec.INVENTORY_ITEM_ID
           AND   T.ORGANIZATION_ID = P_Item_Rec.ORGANIZATION_ID
           AND   T.LANGUAGE = L.LANGUAGE_CODE);
   ELSE
      -- If the Org is not master, then while creating new child items,
      -- copy translated columns from the master item record.
      INSERT INTO MTL_SYSTEM_ITEMS_TL  (
       INVENTORY_ITEM_ID,
       ORGANIZATION_ID,
       LANGUAGE,
       SOURCE_LANG,
       DESCRIPTION,
       LONG_DESCRIPTION,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN)
      SELECT
       P_Item_Rec.INVENTORY_ITEM_ID,
       P_Item_Rec.ORGANIZATION_ID,
       MSI.LANGUAGE,
       MSI.SOURCE_LANG,
       ltrim(rtrim(MSI.DESCRIPTION)),
       ltrim(rtrim(MSI.LONG_DESCRIPTION)),
       P_Item_Rec.LAST_UPDATE_DATE,
       P_Item_Rec.LAST_UPDATED_BY,
       P_Item_Rec.CREATION_DATE,
       P_Item_Rec.CREATED_BY,
       P_Item_Rec.LAST_UPDATE_LOGIN
      FROM
       MTL_SYSTEM_ITEMS_TL  MSI,
       MTL_PARAMETERS       MP
      WHERE
          MSI.INVENTORY_ITEM_ID = P_Item_Rec.INVENTORY_ITEM_ID
      AND  MSI.ORGANIZATION_ID   = MP.MASTER_ORGANIZATION_ID
      AND  MP.ORGANIZATION_ID = P_Item_Rec.ORGANIZATION_ID;
   END IF;

   --
   -- Finally, send messages to dependent business objects.
   --
   --Bug: 2718703 checking for ENI product before calling their package
   IF ( INV_Item_Util.g_Appl_Inst.ENI <> 0 ) THEN

      EXECUTE IMMEDIATE
      ' BEGIN                                                           '||
      '    ENI_ITEMS_STAR_PKG.Insert_Items_In_Star(                     '||
      '       p_api_version         =>  1.0                             '||
      '    ,  p_init_msg_list       =>  FND_API.g_TRUE                  '||
      '    ,  p_inventory_item_id   => :l_Inventory_Item_ID             '||
      '    ,  p_organization_id     => :l_Organization_ID               '||
      '    ,  x_return_status       => :l_return_status                 '||
      '    ,  x_msg_count           => :l_msg_count                     '||
      '    ,  x_msg_data            => :l_msg_data   );                 '||
      ' END;'
      USING IN l_Inventory_Item_ID, IN l_Organization_ID, OUT l_return_status, OUT l_msg_count, OUT l_msg_data;

      IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
         FND_MESSAGE.Set_Encoded (l_msg_data);
         APP_EXCEPTION.Raise_Exception;
      ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
         FND_MESSAGE.Set_Encoded (l_msg_data);
         APP_EXCEPTION.Raise_Exception;
      END IF;

   END IF;

   --Bug: 2728939 Calling add grant if EGO is installed
   OPEN  c_ego_exists;
   FETCH c_ego_exists INTO l_ego_exists;
   CLOSE c_ego_exists;

   -- For Internal Users , Customer_Id may not getting populated in FND_USER
   -- Hence checking USER_ID from ego_people_v which always return all registered
   -- Users (Customer, Internal and Vendor)
   -- Bug Fix : 3048453
   --3797291: Using fnd_grants API instead of EGO API.
   IF (l_ego_exists = 'Y'  AND INV_Item_Util.g_Appl_Inst.EGO <> 0 ) THEN
      l_party_id := NULL;
      BEGIN

         --4932512 : Replacing ego_people with ego_user
         SELECT party_id INTO l_party_id
         FROM EGO_USER_V
         WHERE USER_ID = FND_GLOBAL.User_ID;

         IF l_party_id IS NOT NULL THEN
            FND_GRANTS_PKG.GRANT_FUNCTION(
               P_API_VERSION        => 1.0
              ,P_MENU_NAME          => 'EGO_ITEM_OWNER'
              ,P_OBJECT_NAME        => 'EGO_ITEM'
              ,P_INSTANCE_TYPE      => 'INSTANCE'
              ,P_INSTANCE_PK1_VALUE => l_Inventory_Item_ID
              ,P_INSTANCE_PK2_VALUE => l_Organization_ID
              ,P_GRANTEE_KEY        => 'HZ_PARTY:'||TO_CHAR(l_party_id)
              ,P_START_DATE         => SYSDATE
              ,P_END_DATE           => NULL
              ,X_GRANT_GUID         => l_grant_Guid
              ,X_SUCCESS            => l_return_status
              ,X_ERRORCODE          => l_msg_count);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;

   /* R12: Business Event Enhancement:
   Raise Event if Item got Created successfully */
   BEGIN
      INV_ITEM_EVENTS_PVT.Raise_Events(
           p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_CREATE_EVENT'
          ,p_dml_type          => 'CREATE'
          ,p_inventory_item_id => P_Item_Rec.INVENTORY_ITEM_ID
          ,p_item_description  => ltrim(rtrim(P_Item_Rec.DESCRIPTION))
          ,p_organization_id   => P_Item_Rec.ORGANIZATION_Id );
      EXCEPTION
          WHEN OTHERS THEN
             NULL;
   END;

   l_mast_organization_id := Get_Master_Org_ID(P_Item_Rec.organization_id);

   IF (P_Item_Rec.organization_id = l_mast_organization_id ) THEN
      l_master_org := 'Y';
   ELSE
      l_master_org := 'N';
   END IF;

   BEGIN
     IF l_master_org = 'N' THEN
          INV_ITEM_EVENTS_PVT.Invoke_JAI_API(
             p_action_type              =>  'ASSIGN'
           , p_organization_id          =>  p_item_rec.organization_id
           , p_inventory_item_id        =>  p_item_rec.inventory_item_id
           , p_source_organization_id   =>  l_mast_organization_id
           , p_source_inventory_item_id =>  p_item_rec.inventory_item_id
           , p_set_process_id           =>  NULL
           , p_called_from              =>  'INVVITM.pls');
     END IF;
   EXCEPTION
        WHEN OTHERS THEN
           NULL;
   END;
   --R12: Business Event Enhancement
END Insert_Row;


PROCEDURE Update_Row(P_Item_Rec  IN   INV_ITEM_API.Item_rec_type)
IS

   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN

    INV_ITEM_PVT.Update_Org_Items(
      p_init_msg_list     =>  fnd_api.g_TRUE
     ,p_commit            =>  fnd_api.g_FALSE
     ,p_lock_rows         =>  fnd_api.g_FALSE
     ,p_validation_level  =>  fnd_api.g_VALID_LEVEL_FULL
     ,p_Item_rec          =>  P_Item_Rec
     ,p_validate_Master   =>  fnd_api.g_FALSE
     ,x_return_status     =>  l_return_status
     ,x_msg_count         =>  l_msg_count
     ,x_msg_data          =>  l_msg_data);

     IF ( l_return_status = fnd_api.g_RET_STS_ERROR ) THEN
        fnd_message.SET_ENCODED( l_msg_data );
        Raise FND_API.g_EXC_UNEXPECTED_ERROR;
     ELSIF ( l_return_status = fnd_api.g_RET_STS_UNEXP_ERROR ) THEN
        fnd_message.SET_ENCODED( l_msg_data );
        Raise FND_API.g_EXC_UNEXPECTED_ERROR;
     END IF;

     --
     -- Finally, send messages to dependent business objects.
     --
END Update_Row;

--Jalaj Srivastava Bug 5017588
--added to check if sec uom class is mismatched

PROCEDURE check_mismatch_of_secuom_class(
 p_inventory_item_id        IN     NUMBER
,p_secondary_uom_class      IN     MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE)
IS
  Cursor c_check_sec_uom_class(Vinventory_item_id  mtl_system_items_b.inventory_item_id%TYPE) IS
    SELECT  muomv.UOM_CLASS
    FROM    MTL_UNITS_OF_MEASURE_VL muomv, mtl_system_items_b msib
    WHERE   muomv.uom_code  = msib.secondary_uom_code
    AND     msib.inventory_item_id = Vinventory_item_id
    AND     msib.secondary_uom_code IS NOT NULL
    AND     ROWNUM = 1;

   l_sec_uom_class        MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE := NULL;
BEGIN
  --check for uom class in other orgs
  OPEN  c_check_sec_uom_class(Vinventory_item_id => p_inventory_item_id);
  FETCH c_check_sec_uom_class INTO l_sec_uom_class;
  IF (c_check_sec_uom_class%NOTFOUND) THEN
    l_sec_uom_class := NULL;
  END IF;
  CLOSE c_check_sec_uom_class;
  --raise error if item exists anywhere else with a different sec uom class
  IF (l_sec_uom_class <> p_secondary_uom_class) THEN
    FND_MESSAGE.SET_NAME('INV','INV_SEC_UOM_MISMATCH_CLASS');
    Raise FND_API.g_EXC_UNEXPECTED_ERROR;
  END IF;

END check_mismatch_of_secuom_class;

PROCEDURE Create_Item(
 P_Item_Rec                 IN     INV_ITEM_API.Item_rec_type
,P_Item_Category_Struct_Id  IN     NUMBER
,P_Inv_Install              IN     NUMBER
,P_Master_Org_Id            IN     MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
,P_Category_Set_Id          IN     NUMBER
,P_Item_Category_Id         IN     NUMBER
,P_Event                    IN     VARCHAR2 DEFAULT 'INSERT'
,x_row_Id                   OUT    NOCOPY ROWID
,P_Default_Move_Order_Sub_Inv IN VARCHAR2 -- Item Transaction Defaults for 11.5.9
,P_Default_Receiving_Sub_Inv  IN VARCHAR2
,P_Default_Shipping_Sub_Inv   IN VARCHAR2)
IS

   Cursor c_get_uom_class(cp_uom  mtl_units_of_measure_vl.unit_of_measure%TYPE
                          /* Bug 3713912 */ ,cp_uom_code mtl_units_of_measure_vl.uom_code%TYPE) IS
      SELECT  UOM_CLASS
      FROM    MTL_UNITS_OF_MEASURE_VL
      WHERE   UNIT_OF_MEASURE = cp_uom
              OR uom_code = cp_uom_code;

   Cursor c_get_item_count(cp_Org_Id   MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
                          ,cp_Item_Id  MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE)
   IS
      SELECT  COUNT(1)
      FROM    MTL_SYSTEM_ITEMS
      WHERE   INVENTORY_ITEM_ID  = cp_Item_Id
      AND     ORGANIZATION_ID    = cp_org_id;

   l_item_count       NUMBER :=0;
   l_primary_uom      MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE%TYPE;
   l_primary_uom_code MTL_UNITS_OF_MEASURE_VL.UOM_CODE%TYPE;
   l_new_item_id      MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE;
   l_unit_of_measure  MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE%TYPE;
   l_uom_class        MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE := NULL;
   l_rec_uom_class    MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
   l_description      MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE;
   l_catalog_grp_id   NUMBER;
   l_folder_item_cat_id NUMBER := NULL;
   /* Bug 3713912 */
   l_rec_sec_uom_class    MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
   l_master_org        VARCHAR2(1);
BEGIN
  --Jalaj Srivastava Bug 5017588
  IF (P_Item_rec.secondary_uom_code IS NOT NULL) THEN
    --get the uom class for the current record
    OPEN  c_get_uom_class(cp_uom => NULL, cp_uom_code => P_Item_rec.secondary_uom_code);
    FETCH c_get_uom_class INTO l_rec_sec_uom_class;
    CLOSE c_get_uom_class;
  END IF;
  --{
  IF P_Event <> 'ORG_ASSIGN' THEN
     --Item uniqueness procedure
      Check_Item_Number (
         P_Segment_Rec            => P_Item_Rec
        ,P_Item_Id                => l_new_item_id
        ,P_Description            => l_description
        ,P_unit_of_measure        => l_unit_of_measure
        ,P_Item_Catalog_Group_Id  => l_catalog_grp_id);
      --{
      IF l_new_item_id IS NOT NULL THEN

         --Item exists with same segment combinations
         --If in the same org grp raise error otherwise match on catlog and uom class.

         OPEN c_get_item_count(cp_org_id   => P_Item_rec.organization_id
                              ,cp_Item_Id  => l_new_item_id);

         FETCH c_get_item_count INTO l_item_count;
         CLOSE c_get_item_count;
         IF l_item_count > 0 THEN
            FND_MESSAGE.SET_NAME('INV','INV_DUPLICATE_ITEM');
            Raise FND_API.g_EXC_UNEXPECTED_ERROR;
         END IF;
         IF l_catalog_grp_id <> P_Item_Rec.item_catalog_group_id THEN
            FND_MESSAGE.SET_NAME( 'INV','INV_MISMATCH_CATALOG' );
            Raise FND_API.g_EXC_UNEXPECTED_ERROR;
         END IF;

         OPEN  c_get_uom_class(cp_uom => l_unit_of_measure, cp_uom_code => NULL);
         FETCH c_get_uom_class INTO l_uom_class;
         CLOSE c_get_uom_class;
         OPEN  c_get_uom_class(cp_uom => P_Item_Rec.primary_unit_of_measure, cp_uom_code => NULL);
         FETCH c_get_uom_class INTO l_rec_uom_class;
         CLOSE   c_get_uom_class;

         IF l_uom_class <> l_rec_uom_class THEN
            FND_MESSAGE.SET_NAME('INV','INV_MISMATCH_CLASS');
            Raise FND_API.g_EXC_UNEXPECTED_ERROR;
         END IF;
         --Jalaj Srivastava Bug 5017588
         --check for mismatch of sec uom class.
         check_mismatch_of_secuom_class( p_inventory_item_id   => l_new_item_id
                                         ,p_secondary_uom_class => l_rec_sec_uom_class);
      END IF;--}
   --Jalaj Srivastava Bug 5017588
   ELSIF P_Event = 'ORG_ASSIGN' THEN
     --check for mismatch of sec uom class.
     --sec uom may now also be changed via org assignment
     --item created as non dual may be defined as dual while doing org assign.
     check_mismatch_of_secuom_class( p_inventory_item_id   => P_Item_rec.inventory_item_id
                                     ,p_secondary_uom_class => l_rec_sec_uom_class);
   END IF;--}

   --Insert the item row
   INSERT_ROW(P_Item_Rec          => P_Item_Rec,
              x_row_id            => x_row_Id);

   IF P_Event ='ORG_ASSIGN' THEN
      l_primary_uom       := NULL;
      l_primary_uom_code  := NULL;
      l_rec_uom_class     := NULL;
   ELSE
      INVIDIT3.Set_Inv_Item_id(P_Item_Rec.INVENTORY_ITEM_ID);
      l_primary_uom       := P_Item_rec.primary_unit_of_measure;
      l_primary_uom_code  := P_Item_rec.primary_uom_code;
   END IF;

   IF l_rec_uom_class IS NULL THEN
      OPEN  c_get_uom_class(cp_uom => P_Item_Rec.primary_unit_of_measure, cp_uom_code => NULL);
      FETCH c_get_uom_class INTO l_rec_uom_class;
      CLOSE   c_get_uom_class;
   END IF;

   IF P_Item_Category_Struct_Id IS NOT NULL THEN
      l_folder_item_cat_id := P_Item_Category_Id;
   ELSE
      l_folder_item_cat_id := NULL;
   END IF;

   INVIDIT2.Table_Inserts (
	X_EVENT                      => P_Event,
	X_ITEM_ID                    => P_Item_Rec.inventory_item_id,
	X_ORG_ID                     => P_Item_rec.organization_id,
	X_MASTER_ORG_ID              => P_Master_Org_Id,
	X_STATUS_CODE                => P_Item_rec.inventory_item_status_code,
	X_INVENTORY_ITEM_FLAG        => P_Item_rec.inventory_item_flag,
	X_PURCHASING_ITEM_FLAG       => P_Item_rec.purchasing_item_flag,
	X_INTERNAL_ORDER_FLAG        => P_Item_rec.internal_order_flag,
	X_MRP_PLANNING_CODE          => P_Item_rec.mrp_planning_code,
	X_SERVICEABLE_PRODUCT_FLAG   => P_Item_rec.serviceable_product_flag,
	X_COSTING_ENABLED_FLAG       => P_Item_rec.costing_enabled_flag,
	X_ENG_ITEM_FLAG              => P_Item_rec.eng_item_flag,
	X_CUSTOMER_ORDER_FLAG        => P_Item_rec.customer_order_flag,
	X_EAM_ITEM_TYPE              => P_Item_rec.eam_item_type,
	X_CONTRACT_ITEM_TYPE_CODE    => P_Item_rec.contract_item_type_code,
	P_FOLDER_CATEGORY_SET_ID     => P_Category_set_id,
	P_FOLDER_ITEM_CATEGORY_ID    => l_folder_item_cat_id,
	X_ALLOWED_UNIT_CODE          => P_Item_rec.allowed_units_lookup_code,
	X_PRIMARY_UOM                => l_primary_uom,
	X_PRIMARY_UOM_CODE           => l_primary_uom_code,
	X_PRIMARY_UOM_CLASS          => l_rec_uom_class,
	X_INV_INSTALL                => P_inv_install,
	X_LAST_UPDATED_BY            => P_Item_rec.last_updated_by,
	X_LAST_UPDATE_LOGIN          => P_Item_rec.last_update_login,
	X_ITEM_CATALOG_GROUP_ID      => -1
  ,P_Default_Move_Order_Sub_Inv  => P_Default_Move_Order_Sub_Inv
  ,P_Default_Receiving_Sub_Inv   => P_Default_Receiving_Sub_Inv
  ,P_Default_Shipping_Sub_Inv    => P_Default_Shipping_Sub_Inv
  ,P_Lifecycle_Id                => P_Item_rec.Lifecycle_Id
  ,P_Current_Phase_Id            => P_Item_rec.Current_Phase_id);

   --Call ICX APIs
   IF (P_Item_Rec.organization_id = P_Master_Org_Id ) THEN
      l_master_org := 'Y';
   ELSE
      l_master_org := 'N';
   END IF;

   BEGIN
     INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
           p_entity_type       => 'ITEM'
          ,p_dml_type          => 'CREATE'
          ,p_inventory_item_id => P_Item_Rec.INVENTORY_ITEM_ID
          ,p_item_description  => ltrim(rtrim(P_Item_Rec.DESCRIPTION))
          ,p_organization_id   => P_Item_Rec.ORGANIZATION_Id
          ,p_master_org_flag   => l_master_org );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

EXCEPTION
   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      x_row_Id             := NULL;
      IF c_get_uom_class%ISOPEN THEN
         CLOSE c_get_uom_class;
      END IF;
      IF c_get_item_count%ISOPEN THEN
         CLOSE c_get_item_count;
      END IF;
      app_exception.raise_exception;

   WHEN OTHERS THEN
      x_row_Id             := NULL;
      IF c_get_uom_class%ISOPEN THEN
         CLOSE c_get_uom_class;
      END IF;
      IF c_get_item_count%ISOPEN THEN
         CLOSE c_get_item_count;
      END IF;
      app_exception.raise_exception;

END Create_Item;


PROCEDURE Delete_Cost_Details(
 P_Item_Id             IN MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE
,P_Org_Id              IN MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE
,P_Asset_Flag          IN MTL_SYSTEM_ITEMS_B.INVENTORY_ASSET_FLAG%TYPE
,P_Cost_Txn            IN NUMBER
,P_Last_Updated_By     IN MTL_SYSTEM_ITEMS_B.LAST_UPDATED_BY%TYPE
,P_Last_Updated_Login  IN MTL_SYSTEM_ITEMS_B.LAST_UPDATE_LOGIN%TYPE)
IS

   l_prim_cost_method 	MTL_PARAMETERS.PRIMARY_COST_METHOD%TYPE;
/* l_profile_exists    BOOLEAN;
   l_profile_val        VARCHAR2(240); Bug 4247149*/

BEGIN
   IF NVL(P_cost_txn,-99) <> 1 THEN

      SELECT  	primary_cost_method
      INTO      l_prim_cost_method
      FROM      mtl_parameters
      WHERE	ORGANIZATION_ID = p_org_id;

      UPDATE cst_item_costs
      SET    inventory_asset_flag    = decode(P_Asset_Flag,'Y', 1, 2)
            ,LAST_UPDATED_BY         = P_Last_Updated_By
            ,LAST_UPDATE_DATE        = SYSDATE
            ,LAST_UPDATE_LOGIN       = P_Last_Updated_Login
            ,PL_MATERIAL             = 0
            ,PL_MATERIAL_OVERHEAD    = 0
            ,PL_RESOURCE             = 0
            ,PL_OUTSIDE_PROCESSING   = 0
            ,PL_OVERHEAD             = 0
            ,TL_MATERIAL             = 0
            ,TL_MATERIAL_OVERHEAD    = 0
            ,TL_RESOURCE             = 0
            ,TL_OUTSIDE_PROCESSING   = 0
            ,TL_OVERHEAD             = 0
            ,MATERIAL_COST           = 0
            ,MATERIAL_OVERHEAD_COST  = 0
            ,RESOURCE_COST           = 0
            ,OUTSIDE_PROCESSING_COST = 0
            ,OVERHEAD_COST           = 0
            ,PL_ITEM_COST            = 0
            ,TL_ITEM_COST            = 0
            ,ITEM_COST               = 0
            ,UNBURDENED_COST         = 0
            ,BURDEN_COST             = 0
      WHERE  organization_id   = P_Org_Id
      AND    inventory_item_id = p_Item_Id
      AND    cost_type_id      = l_prim_cost_method;

      UPDATE cst_quantity_layers
      SET    LAST_UPDATED_BY         = P_Last_Updated_By
            ,LAST_UPDATE_DATE        = SYSDATE
            ,LAST_UPDATE_LOGIN       = P_Last_Updated_Login
            ,PL_MATERIAL             = 0
            ,PL_MATERIAL_OVERHEAD    = 0
            ,PL_RESOURCE             = 0
            ,PL_OUTSIDE_PROCESSING   = 0
            ,PL_OVERHEAD             = 0
            ,TL_MATERIAL             = 0
            ,TL_MATERIAL_OVERHEAD    = 0
            ,TL_RESOURCE             = 0
            ,TL_OUTSIDE_PROCESSING   = 0
            ,TL_OVERHEAD             = 0
            ,MATERIAL_COST           = 0
            ,MATERIAL_OVERHEAD_COST  = 0
            ,RESOURCE_COST           = 0
            ,OUTSIDE_PROCESSING_COST = 0
            ,OVERHEAD_COST           = 0
            ,PL_ITEM_COST            = 0
            ,TL_ITEM_COST            = 0
            ,ITEM_COST               = 0
            ,UNBURDENED_COST         = 0
            ,BURDEN_COST             = 0
      WHERE  organization_id   = P_Org_Id
      AND    inventory_item_id = P_Item_id;

      DELETE cst_item_cost_details
      WHERE  inventory_item_id = P_Item_id
      AND    organization_id   = P_Org_Id
      AND    cost_type_id      = l_prim_cost_method;

/*    l_profile_exists := FND_PROFILE.DEFINED('CST_AVG_COSTING_OPTION');

      IF l_profile_exists  THEN
        FND_PROFILE.GET ('CST_AVG_COSTING_OPTION',l_profile_val);
      END IF; Bug 4247149*/

      IF (l_prim_cost_method IN (2,5,6))
/*         AND l_profile_exists AND (l_profile_val = '2'))  Bug 4247149*/
      THEN
         DELETE cst_layer_cost_details
         WHERE  layer_id IN ( SELECT layer_id
	                      FROM   cst_quantity_layers
  		              WHERE  inventory_item_id = P_Item_Id
                              AND    organization_id   = P_Org_Id );
         IF  (l_prim_cost_method IN (5,6))  THEN
      	    CSTPLENG.update_inv_layer_cost(
	         I_ORG_ID   => P_Org_Id
		,I_ITEM_ID  => P_Item_id
		,I_USERID   => P_Last_Updated_By
		,I_LOGIN_ID => P_Last_Updated_Login);
         END IF;
      END IF;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
END Delete_Cost_Details;

PROCEDURE Update_Item(
 P_Item_Rec                 IN  INV_ITEM_API.Item_rec_type
,P_Item_Category_Struct_Id  IN  NUMBER
,P_Inv_Install              IN  NUMBER
,P_Master_Org_Id            IN  MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
,P_Category_Set_Id          IN  NUMBER
,P_Item_Category_Id         IN  NUMBER
,P_Mode                     IN  VARCHAR2
,P_Updateble_Item           IN  VARCHAR2
,P_Cost_Txn                 IN  VARCHAR2
,P_Item_Cost_Details        IN  VARCHAR2
,P_Inv_Item_status_old      IN  MTL_SYSTEM_ITEMS_FVL.INVENTORY_ITEM_STATUS_CODE%TYPE
,P_Default_Move_Order_Sub_Inv IN VARCHAR2 -- Item Transaction Defaults for 11.5.9
,P_Default_Receiving_Sub_Inv  IN VARCHAR2
,P_Default_Shipping_Sub_Inv   IN VARCHAR2
) IS

   Cursor c_get_uom_class(cp_uom  mtl_units_of_measure_vl.unit_of_measure%TYPE) IS
      SELECT  UOM_CLASS
      FROM    MTL_UNITS_OF_MEASURE_VL
      WHERE   UNIT_OF_MEASURE = cp_uom;

   l_rec_uom_class         MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
   l_folder_item_cat_id    NUMBER := NULL;
   l_cst_item_type         MTL_SYSTEM_ITEMS_FVL.PLANNING_MAKE_BUY_CODE%TYPE;
   l_Inventory_Item_status MTL_SYSTEM_ITEMS_FVL.INVENTORY_ITEM_STATUS_CODE%TYPE;
   l_event	           VARCHAR2(10);
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);
   l_master_org            VARCHAR2(1); --R12: Business Events
   -- bug 11710464
   l_last_updated_by       NUMBER;
   l_last_update_date      DATE;
   l_last_update_login     NUMBER;

   -- Bug 8512945 with base bug 8417326 : Start
   l_org_id		   MTL_PARAMETERS.ORGANIZATION_ID%TYPE;
   l_exists VARCHAR2(1) := 'N';
   l_control_level NUMBER;

  Cursor c_get_child_costing_orgs(org_id MTL_PARAMETERS.ORGANIZATION_ID%TYPE) IS
	SELECT ORGANIZATION_ID
	FROM MTL_PARAMETERS
	WHERE ORGANIZATION_ID = org_id
	OR ORGANIZATION_ID IN
	    (SELECT ORGANIZATION_ID FROM MTL_PARAMETERS
	    WHERE MASTER_ORGANIZATION_ID = org_id
	    AND PRIMARY_COST_METHOD in (2,5,6)
	    AND (1=(select control_level from mtl_item_attributes
                  where attribute_name= 'MTL_SYSTEM_ITEMS.INVENTORY_ASSET_FLAG')
		)
	    );
   -- Bug 8512945 with base bug 8417326 : End

BEGIN

   -- Bug 8512945 with base bug 8417326 : Start
   select control_level INTO l_control_level
   from mtl_item_attributes
   where attribute_name= 'MTL_SYSTEM_ITEMS.PLANNING_MAKE_BUY_CODE';

   -- Loop through the child orgs if the inv asset flag are controlled at master level
   OPEN c_get_child_costing_orgs(org_id => P_Item_rec.organization_id);
   LOOP
   FETCH c_get_child_costing_orgs INTO l_org_id;
   EXIT WHEN c_get_child_costing_orgs%NOTFOUND;

   IF P_Item_Cost_Details = 'D' THEN
      Delete_Cost_Details(
         P_Item_Id             => P_Item_Rec.inventory_item_id
	,P_Org_Id              => l_org_id	-- Bug 8512945 with base bug 8417326
	,P_Asset_Flag          => P_Item_rec.inventory_asset_flag
	,P_Cost_Txn            => P_Cost_Txn
	,P_Last_Updated_By     => P_Item_Rec.last_updated_by
	,P_Last_Updated_Login  => P_Item_Rec.last_update_login);
   END IF;

   IF P_Item_Cost_Details = 'I' THEN

      Delete_Cost_Details(
         P_Item_Id             => P_Item_Rec.inventory_item_id
	,P_Org_Id              => l_org_id	-- Bug 8512945 with base bug 8417326
	,P_Asset_Flag          => P_Item_rec.inventory_asset_flag
	,P_Cost_Txn            => P_Cost_Txn
	,P_Last_Updated_By     => P_Item_Rec.last_updated_by
	,P_Last_Updated_Login  => P_Item_Rec.last_update_login);

        /* Bug 8512945 with base bug 8417326 : Below BEGIN Block is added  */
      BEGIN
        SELECT 'Y' INTO l_exists
        FROM mtl_system_items_b
        WHERE inventory_item_id =  P_Item_Rec.inventory_item_id
        AND organization_id = l_org_id;

        IF (P_Item_rec.organization_id  = l_org_id) THEN
	    		IF P_Item_Rec.planning_make_buy_code IN (1,2) THEN
							l_cst_item_type := P_Item_Rec.planning_make_buy_code;
	    		ELSE
							l_cst_item_type := 2;
	    		END IF;
        ELSE
            IF (l_control_level = 1) THEN
               IF P_Item_Rec.planning_make_buy_code IN (1,2) THEN
		   						l_cst_item_type := P_Item_Rec.planning_make_buy_code;
               ELSE
		   						l_cst_item_type := 2;
               END IF;
            ELSE
              SELECT planning_make_buy_code INTO l_cst_item_type
              FROM mtl_system_items_b
              WHERE inventory_item_id =  P_Item_Rec.inventory_item_id
              AND organization_id = l_org_id;
            END IF;
        END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_exists := 'N';
      END;


       -- Bug 8512945 with base bug 8417326 : Added the belwo If condition
    	IF (l_exists = 'Y')THEN

     	INVIDIT2.Insert_Cost_Details (
	 			x_item_id         => P_Item_rec.inventory_item_id
				,x_org_id          => l_org_id	-- Bug 8512945 with base bug 8417326
     		,x_inv_install     => P_Inv_Install
     		,x_last_updated_by => P_Item_rec.last_updated_by
     		,x_cst_item_type   => l_cst_item_type );
   		END IF;
     END IF;
   END LOOP;
   CLOSE c_get_child_costing_orgs;
   /* Bug 8512945 with base bug 8417326 : End */

   INVIDIT3.Set_Inv_Item_id(P_Item_Rec.INVENTORY_ITEM_ID);

   IF P_Mode = 'DEFINE' AND P_Item_rec.costing_enabled_flag = 'Y' THEN
      INVIDIT2.Insert_Costing_Category(
	 x_item_id => P_Item_rec.inventory_item_id
	,x_org_id  => P_Item_rec.organization_id);
   END IF;

   Update_Row(P_Item_Rec => P_Item_Rec);
   -- bug 11710464
   SELECT last_updated_by,last_update_date,LAST_UPDATE_LOGIN
   INTO l_last_updated_by ,l_last_update_date,l_last_update_login
   FROM
   mtl_system_items_b WHERE inventory_item_id=P_Item_rec.inventory_item_id
   AND organization_id=  P_Master_Org_Id;



   IF P_mode = 'DEFINE' THEN
      IF  P_Updateble_Item = 'ALL' THEN
      	  UPDATE mtl_system_items_b
      	  SET    segment1 = P_Item_rec.segment1
  	        ,segment2 = P_Item_rec.segment2
	        ,segment3 = P_Item_rec.segment3
		,segment4 = P_Item_rec.segment4
		,segment5 = P_Item_rec.segment5
		,segment6 = P_Item_rec.segment6
		,segment7 = P_Item_rec.segment7
		,segment8 = P_Item_rec.segment8
		,segment9 = P_Item_rec.segment9
		,segment10 = P_Item_rec.segment10
		,segment11 = P_Item_rec.segment11
		,segment12 = P_Item_rec.segment12
		,segment13 = P_Item_rec.segment13
		,segment14 = P_Item_rec.segment14
		,segment15 = P_Item_rec.segment15
		,segment16 = P_Item_rec.segment16
		,segment17 = P_Item_rec.segment17
		,segment18 = P_Item_rec.segment18
		,segment19 = P_Item_rec.segment19
		,segment20 = P_Item_rec.segment20
		-- bug 11710464
                ,last_updated_by   = l_last_updated_by
                ,last_update_date  = l_last_update_date
                ,LAST_UPDATE_LOGIN = l_last_update_login
          WHERE   inventory_item_id =  P_Item_rec.inventory_item_id;
       END IF;
    END IF;

    IF P_Inv_Item_status_old = P_Item_rec.inventory_item_status_code THEN
       l_Inventory_Item_status := NULL;
    ELSE
       l_Inventory_Item_status := P_Item_rec.inventory_item_status_code;
    END IF;

    IF ( P_mode = 'DEFINE' )  THEN
       l_event := 'UPDATE';
    ELSIF (P_mode = 'UPDATE' )  THEN
       l_event := 'ITEM_ORG';
    END IF;

   IF l_rec_uom_class IS NULL THEN
      OPEN  c_get_uom_class(cp_uom => P_Item_Rec.primary_unit_of_measure);
      FETCH c_get_uom_class INTO l_rec_uom_class;
      CLOSE   c_get_uom_class;
   END IF;

   IF P_Item_Category_Struct_Id IS NOT NULL THEN
      l_folder_item_cat_id := P_Item_Category_Id;
   ELSE
      l_folder_item_cat_id := NULL;
   END IF;

   INVIDIT2.Table_Inserts (
	X_EVENT                      => l_event,
	X_ITEM_ID                    => P_Item_Rec.inventory_item_id,
	X_ORG_ID                     => P_Item_rec.organization_id,
	X_MASTER_ORG_ID              => P_Master_Org_Id,
	X_STATUS_CODE                => l_Inventory_Item_status,
	X_INVENTORY_ITEM_FLAG        => P_Item_rec.inventory_item_flag,
	X_PURCHASING_ITEM_FLAG       => P_Item_rec.purchasing_item_flag,
	X_INTERNAL_ORDER_FLAG        => P_Item_rec.internal_order_flag,
	X_MRP_PLANNING_CODE          => P_Item_rec.mrp_planning_code,
	X_SERVICEABLE_PRODUCT_FLAG   => P_Item_rec.serviceable_product_flag,
	X_COSTING_ENABLED_FLAG       => P_Item_rec.costing_enabled_flag,
	X_ENG_ITEM_FLAG              => P_Item_rec.eng_item_flag,
	X_CUSTOMER_ORDER_FLAG        => P_Item_rec.customer_order_flag,
	X_EAM_ITEM_TYPE              => P_Item_rec.eam_item_type,
	X_CONTRACT_ITEM_TYPE_CODE    => P_Item_rec.contract_item_type_code,
	P_FOLDER_CATEGORY_SET_ID     => P_Category_set_id,
	P_FOLDER_ITEM_CATEGORY_ID    => l_folder_item_cat_id,
	X_ALLOWED_UNIT_CODE          => P_Item_rec.allowed_units_lookup_code,
	X_PRIMARY_UOM                => P_Item_rec.primary_unit_of_measure,
	X_PRIMARY_UOM_CODE           => P_Item_rec.primary_uom_code,
	X_PRIMARY_UOM_CLASS          => l_rec_uom_class,
	X_INV_INSTALL                => P_inv_install,
	X_LAST_UPDATED_BY            => P_Item_rec.last_updated_by,
	X_LAST_UPDATE_LOGIN          => P_Item_rec.last_update_login,
	X_ITEM_CATALOG_GROUP_ID      => P_Item_rec.item_catalog_group_id
      , P_Default_Move_Order_Sub_Inv => P_Default_Move_Order_Sub_Inv
      , P_Default_Receiving_Sub_Inv  => P_Default_Receiving_Sub_Inv
      , P_Default_Shipping_Sub_Inv   => P_Default_Shipping_Sub_Inv
      , P_Lifecycle_Id                => P_Item_rec.Lifecycle_Id
      , P_Current_Phase_Id            => P_Item_rec.Current_Phase_id);

     --Bug: 2803712 Moved the below call from update_row()
     --Bug: 2718703 checking for ENI product before calling their package
     IF ( INV_Item_Util.g_Appl_Inst.ENI <> 0 ) THEN
        EXECUTE IMMEDIATE
        ' BEGIN                                                           '||
        '    ENI_ITEMS_STAR_PKG.Update_Items_In_Star(                     '||
        '       p_api_version         =>  1.0                             '||
        '    ,  p_init_msg_list       =>  FND_API.g_TRUE                  '||
        '    ,  p_inventory_item_id   => :P_Item_Rec.INVENTORY_ITEM_ID    '||
        '    ,  p_organization_id     => :P_Item_Rec.ORGANIZATION_ID      '||
        '    ,  x_return_status       => :l_return_status                 '||
        '    ,  x_msg_count           => :l_msg_count                     '||
        '    ,  x_msg_data            => :l_msg_data   );                 '||
        ' END;'
        USING IN P_Item_Rec.INVENTORY_ITEM_ID, IN P_Item_Rec.ORGANIZATION_ID, OUT l_return_status, OUT l_msg_count, OUT l_msg_data;

        IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
           FND_MESSAGE.Set_Encoded (l_msg_data);
           Raise FND_API.g_EXC_UNEXPECTED_ERROR;
        ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
           FND_MESSAGE.Set_Encoded (l_msg_data);
           Raise FND_API.g_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

  /* R12: Business Event Enhancement :
  Raise Event if Item got Updated successfully */
  BEGIN
     INV_ITEM_EVENTS_PVT.Raise_Events(
            p_event_name        => 'EGO_WF_WRAPPER_PVT.G_ITEM_UPDATE_EVENT'
           ,p_dml_type          => 'UPDATE'
           ,p_inventory_item_id => p_Item_rec.INVENTORY_ITEM_ID
           ,p_organization_id   => p_Item_rec.ORGANIZATION_ID
           ,p_item_description  => p_Item_rec.DESCRIPTION
         );
     EXCEPTION
         WHEN OTHERS THEN
            NULL;
  END;

  --Call ICX APIs
  BEGIN
     IF ( p_Master_Org_id = p_Item_rec.ORGANIZATION_ID ) THEN
        l_master_org := 'Y';
     ELSE
        l_master_org := 'N';
     END IF;
     INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
           p_entity_type       => 'ITEM'
          ,p_dml_type          => 'UPDATE'
          ,p_inventory_item_id => P_Item_Rec.INVENTORY_ITEM_ID
          ,p_item_description  => P_Item_Rec.DESCRIPTION
          ,p_organization_id   => P_Item_Rec.ORGANIZATION_ID
          ,p_master_org_flag   => l_master_org );
     EXCEPTION
         WHEN OTHERS THEN
            NULL;
  END;
  --R12: Business Event Enhancement


EXCEPTION
   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      IF c_get_uom_class%ISOPEN THEN
         CLOSE c_get_uom_class;
      END IF;
      app_exception.raise_exception;

   WHEN OTHERS THEN
      IF c_get_uom_class%ISOPEN THEN
         CLOSE c_get_uom_class;
      END IF;
      app_exception.raise_exception;
END Update_Item;

-- ------------------ LOCK_ITEM -------------------
PROCEDURE Lock_Item( P_Item_Rec  IN  INV_ITEM_API.Item_rec_type) IS

   CURSOR c_item_details IS
    SELECT
      PRIMARY_UOM_CODE,
      ALLOWED_UNITS_LOOKUP_CODE,
      OVERCOMPLETION_TOLERANCE_TYPE,
      OVERCOMPLETION_TOLERANCE_VALUE,
      EFFECTIVITY_CONTROL,
      CHECK_SHORTAGES_FLAG,
      FULL_LEAD_TIME,
      ORDER_COST,
      MRP_SAFETY_STOCK_PERCENT,
      MRP_SAFETY_STOCK_CODE,
      MIN_MINMAX_QUANTITY,
      MAX_MINMAX_QUANTITY,
      MINIMUM_ORDER_QUANTITY,
      FIXED_ORDER_QUANTITY,
      FIXED_DAYS_SUPPLY,
      MAXIMUM_ORDER_QUANTITY,
      ATP_RULE_ID,
      PICKING_RULE_ID,
      RESERVABLE_TYPE,
      POSITIVE_MEASUREMENT_ERROR,
      NEGATIVE_MEASUREMENT_ERROR,
      ENGINEERING_ECN_CODE,
      ENGINEERING_ITEM_ID,
      ENGINEERING_DATE,
      SERVICE_STARTING_DELAY,
      SERVICEABLE_COMPONENT_FLAG,
      SERVICEABLE_PRODUCT_FLAG,
      PAYMENT_TERMS_ID,
      PREVENTIVE_MAINTENANCE_FLAG,
      MATERIAL_BILLABLE_FLAG,
      PRORATE_SERVICE_FLAG,
      COVERAGE_SCHEDULE_ID,
      SERVICE_DURATION_PERIOD_CODE,
      SERVICE_DURATION,
      INVOICEABLE_ITEM_FLAG,
      TAX_CODE,
      INVOICE_ENABLED_FLAG,
      MUST_USE_APPROVED_VENDOR_FLAG,
      OUTSIDE_OPERATION_FLAG,
      OUTSIDE_OPERATION_UOM_TYPE,
      SAFETY_STOCK_BUCKET_DAYS,
      AUTO_REDUCE_MPS,
      COSTING_ENABLED_FLAG,
      AUTO_CREATED_CONFIG_FLAG,
      CYCLE_COUNT_ENABLED_FLAG,
      ITEM_TYPE,
      MODEL_CONFIG_CLAUSE_NAME,
      SHIP_MODEL_COMPLETE_FLAG,
      MRP_PLANNING_CODE,
      RETURN_INSPECTION_REQUIREMENT,
      ATO_FORECAST_CONTROL,
      RELEASE_TIME_FENCE_CODE,
      RELEASE_TIME_FENCE_DAYS,
      CONTAINER_ITEM_FLAG,
      VEHICLE_ITEM_FLAG,
      MAXIMUM_LOAD_WEIGHT,
      MINIMUM_FILL_PERCENT,
      CONTAINER_TYPE_CODE,
      INTERNAL_VOLUME,
      PRODUCT_FAMILY_ITEM_ID,
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
      GLOBAL_ATTRIBUTE20,
      PURCHASING_TAX_CODE,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      PURCHASING_ITEM_FLAG,
      SHIPPABLE_ITEM_FLAG,
      CUSTOMER_ORDER_FLAG,
      INTERNAL_ORDER_FLAG,
      INVENTORY_ITEM_FLAG,
      ENG_ITEM_FLAG,
      INVENTORY_ASSET_FLAG,
      PURCHASING_ENABLED_FLAG,
      CUSTOMER_ORDER_ENABLED_FLAG,
      INTERNAL_ORDER_ENABLED_FLAG,
      SO_TRANSACTIONS_FLAG,
      MTL_TRANSACTIONS_ENABLED_FLAG,
      STOCK_ENABLED_FLAG,
      BOM_ENABLED_FLAG,
      BUILD_IN_WIP_FLAG,
      REVISION_QTY_CONTROL_CODE,
      ITEM_CATALOG_GROUP_ID,
      CATALOG_STATUS_FLAG,
      RETURNABLE_FLAG,
      DEFAULT_SHIPPING_ORG,
      COLLATERAL_FLAG,
      TAXABLE_FLAG,
      QTY_RCV_EXCEPTION_CODE,
      ALLOW_ITEM_DESC_UPDATE_FLAG,
      INSPECTION_REQUIRED_FLAG,
      RECEIPT_REQUIRED_FLAG,
      MARKET_PRICE,
      HAZARD_CLASS_ID,
      RFQ_REQUIRED_FLAG,
      QTY_RCV_TOLERANCE,
      LIST_PRICE_PER_UNIT,
      UN_NUMBER_ID,
      PRICE_TOLERANCE_PERCENT,
      ASSET_CATEGORY_ID,
      ROUNDING_FACTOR,
      UNIT_OF_ISSUE,
      ENFORCE_SHIP_TO_LOCATION_CODE,
      ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
      ALLOW_UNORDERED_RECEIPTS_FLAG,
      ALLOW_EXPRESS_DELIVERY_FLAG,
      DAYS_EARLY_RECEIPT_ALLOWED,
      DAYS_LATE_RECEIPT_ALLOWED,
      RECEIPT_DAYS_EXCEPTION_CODE,
      RECEIVING_ROUTING_ID,
      INVOICE_CLOSE_TOLERANCE,
      RECEIVE_CLOSE_TOLERANCE,
      AUTO_LOT_ALPHA_PREFIX,
      START_AUTO_LOT_NUMBER,
      LOT_CONTROL_CODE,
      SHELF_LIFE_CODE,
      SHELF_LIFE_DAYS,
      SERIAL_NUMBER_CONTROL_CODE,
      START_AUTO_SERIAL_NUMBER,
      AUTO_SERIAL_ALPHA_PREFIX,
      SOURCE_TYPE,
      SOURCE_ORGANIZATION_ID,
      SOURCE_SUBINVENTORY,
      EXPENSE_ACCOUNT,
      ENCUMBRANCE_ACCOUNT,
      RESTRICT_SUBINVENTORIES_CODE,
      UNIT_WEIGHT,
      WEIGHT_UOM_CODE,
      VOLUME_UOM_CODE,
      UNIT_VOLUME,
      RESTRICT_LOCATORS_CODE,
      LOCATION_CONTROL_CODE,
      SHRINKAGE_RATE,
      ACCEPTABLE_EARLY_DAYS,
      PLANNING_TIME_FENCE_CODE,
      DEMAND_TIME_FENCE_CODE,
      LEAD_TIME_LOT_SIZE,
      STD_LOT_SIZE,
      CUM_MANUFACTURING_LEAD_TIME,
      OVERRUN_PERCENTAGE,
      MRP_CALCULATE_ATP_FLAG,
      ACCEPTABLE_RATE_INCREASE,
      ACCEPTABLE_RATE_DECREASE,
      CUMULATIVE_TOTAL_LEAD_TIME,
      PLANNING_TIME_FENCE_DAYS,
      DEMAND_TIME_FENCE_DAYS,
      END_ASSEMBLY_PEGGING_FLAG,
      REPETITIVE_PLANNING_FLAG,
      PLANNING_EXCEPTION_SET,
      BOM_ITEM_TYPE,
      PICK_COMPONENTS_FLAG,
      REPLENISH_TO_ORDER_FLAG,
      BASE_ITEM_ID,
      ATP_COMPONENTS_FLAG,
      ATP_FLAG,
      FIXED_LEAD_TIME,
      VARIABLE_LEAD_TIME,
      WIP_SUPPLY_LOCATOR_ID,
      WIP_SUPPLY_TYPE,
      WIP_SUPPLY_SUBINVENTORY,
      COST_OF_SALES_ACCOUNT,
      SALES_ACCOUNT,
      DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
      INVENTORY_ITEM_STATUS_CODE,
      INVENTORY_PLANNING_CODE,
      PLANNER_CODE,
      PLANNING_MAKE_BUY_CODE,
      FIXED_LOT_MULTIPLIER,
      ROUNDING_CONTROL_TYPE,
      CARRYING_COST,
      POSTPROCESSING_LEAD_TIME,
      PREPROCESSING_LEAD_TIME,
      SUMMARY_FLAG,
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      BUYER_ID,
      ACCOUNTING_RULE_ID,
      INVOICING_RULE_ID,
      OVER_SHIPMENT_TOLERANCE,
      UNDER_SHIPMENT_TOLERANCE,
      OVER_RETURN_TOLERANCE,
      UNDER_RETURN_TOLERANCE,
      EQUIPMENT_TYPE,
      RECOVERED_PART_DISP_CODE,
      DEFECT_TRACKING_ON_FLAG,
      EVENT_FLAG,
      ELECTRONIC_FLAG,
      DOWNLOADABLE_FLAG,
      VOL_DISCOUNT_EXEMPT_FLAG,
      COUPON_EXEMPT_FLAG,
      COMMS_NL_TRACKABLE_FLAG,
      ASSET_CREATION_CODE,
      COMMS_ACTIVATION_REQD_FLAG,
      ORDERABLE_ON_WEB_FLAG,
      BACK_ORDERABLE_FLAG,
      WEB_STATUS,
      INDIVISIBLE_FLAG
    , DIMENSION_UOM_CODE
    , UNIT_LENGTH
    , UNIT_WIDTH
    , UNIT_HEIGHT
    , BULK_PICKED_FLAG
    , LOT_STATUS_ENABLED
    , DEFAULT_LOT_STATUS_ID
    , SERIAL_STATUS_ENABLED
    , DEFAULT_SERIAL_STATUS_ID
    , LOT_SPLIT_ENABLED
    , LOT_MERGE_ENABLED
    , INVENTORY_CARRY_PENALTY
    , OPERATION_SLACK_PENALTY
    , FINANCING_ALLOWED_FLAG
    , EAM_ITEM_TYPE
    , EAM_ACTIVITY_TYPE_CODE
    , EAM_ACTIVITY_CAUSE_CODE
    , EAM_ACT_NOTIFICATION_FLAG
    , EAM_ACT_SHUTDOWN_STATUS
    , DUAL_UOM_CONTROL
    , SECONDARY_UOM_CODE
    , DUAL_UOM_DEVIATION_HIGH
    , DUAL_UOM_DEVIATION_LOW
    , CONTRACT_ITEM_TYPE_CODE
--    , SUBSCRIPTION_DEPEND_FLAG
    ,  SERV_REQ_ENABLED_CODE
    ,  SERV_BILLING_ENABLED_FLAG
--    ,  SERV_IMPORTANCE_LEVEL
    ,  PLANNED_INV_POINT_FLAG
    ,  LOT_TRANSLATE_ENABLED
    ,  DEFAULT_SO_SOURCE_TYPE
    ,  CREATE_SUPPLY_FLAG
    ,  SUBSTITUTION_WINDOW_CODE
    ,  SUBSTITUTION_WINDOW_DAYS
    ,  IB_ITEM_INSTANCE_CLASS
    ,  CONFIG_MODEL_TYPE
    --Added as part of 11.5.9 ENH
    ,  LOT_SUBSTITUTION_ENABLED
    ,  MINIMUM_LICENSE_QUANTITY
    ,  EAM_ACTIVITY_SOURCE_CODE
    --Added as part of 11.5.10 ENH
    ,  TRACKING_QUANTITY_IND
    ,  ONT_PRICING_QTY_SOURCE
    ,  SECONDARY_DEFAULT_IND
    ,  CONFIG_ORGS
    ,  CONFIG_MATCH
    , SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT11,
      SEGMENT12,
      SEGMENT13,
      SEGMENT14,
      SEGMENT15,
      SEGMENT16,
      SEGMENT17,
      SEGMENT18,
      SEGMENT19,
      SEGMENT20,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5 ,
      VMI_MINIMUM_UNITS,
      VMI_MINIMUM_DAYS  ,
      VMI_MAXIMUM_UNITS  ,
      VMI_MAXIMUM_DAYS ,
      VMI_FIXED_ORDER_QUANTITY  ,
      SO_AUTHORIZATION_FLAG   ,
      CONSIGNED_FLAG        ,
      ASN_AUTOEXPIRE_FLAG   ,
      VMI_FORECAST_TYPE    ,
      FORECAST_HORIZON      ,
      EXCLUDE_FROM_BUDGET_FLAG  ,
      DAYS_TGT_INV_SUPPLY       ,
      DAYS_TGT_INV_WINDOW     ,
      DAYS_MAX_INV_SUPPLY     ,
      DAYS_MAX_INV_WINDOW     ,
      DRP_PLANNED_FLAG       ,
      CRITICAL_COMPONENT_FLAG   ,
      CONTINOUS_TRANSFER       ,
      CONVERGENCE             ,
      DIVERGENCE
    /* Start Bug 3713912 */-- Added for R12
    ,LOT_DIVISIBLE_FLAG,
GRADE_CONTROL_FLAG,
DEFAULT_GRADE,
CHILD_LOT_FLAG,
PARENT_CHILD_GENERATION_FLAG,
CHILD_LOT_PREFIX,
CHILD_LOT_STARTING_NUMBER,
CHILD_LOT_VALIDATION_FLAG,
COPY_LOT_ATTRIBUTE_FLAG,
RECIPE_ENABLED_FLAG,
PROCESS_QUALITY_ENABLED_FLAG,
PROCESS_EXECUTION_ENABLED_FLAG,
PROCESS_COSTING_ENABLED_FLAG,
PROCESS_SUPPLY_SUBINVENTORY,
PROCESS_SUPPLY_LOCATOR_ID,
PROCESS_YIELD_SUBINVENTORY,
PROCESS_YIELD_LOCATOR_ID,
HAZARDOUS_MATERIAL_FLAG,
CAS_NUMBER,
RETEST_INTERVAL,
EXPIRATION_ACTION_INTERVAL,
EXPIRATION_ACTION_CODE,
MATURITY_DAYS,
HOLD_DAYS,
ATTRIBUTE16,
ATTRIBUTE17,
ATTRIBUTE18,
ATTRIBUTE19,
ATTRIBUTE20,
ATTRIBUTE21,
ATTRIBUTE22,
ATTRIBUTE23,
ATTRIBUTE24,
ATTRIBUTE25,
ATTRIBUTE26,
ATTRIBUTE27,
ATTRIBUTE28,
ATTRIBUTE29,
ATTRIBUTE30
    /* End Bug 3713912 */
    ,  CHARGE_PERIODICITY_CODE
    ,  REPAIR_LEADTIME
    ,  REPAIR_YIELD
    ,  PREPOSITION_POINT
    ,  REPAIR_PROGRAM
    ,  SUBCONTRACTING_COMPONENT
    ,  OUTSOURCED_ASSEMBLY
    -- Fix for Bug#6644711
    ,  DEFAULT_MATERIAL_STATUS_ID
    -- Serial_Tagging Enh -- bug 9913552
    ,  SERIAL_TAGGING_FLAG
    from  MTL_SYSTEM_ITEMS_B
    where  INVENTORY_ITEM_ID = P_Item_Rec.inventory_item_id
      and  ORGANIZATION_ID   = P_Item_rec.organization_id
    for update of INVENTORY_ITEM_ID nowait;

   CURSOR c_get_item_description IS
    SELECT
      DESCRIPTION,
      LONG_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    FROM  MTL_SYSTEM_ITEMS_TL
    WHERE  INVENTORY_ITEM_ID = P_Item_Rec.inventory_item_id
    AND    ORGANIZATION_ID   = P_Item_rec.organization_id
    for update of INVENTORY_ITEM_ID nowait;

   recinfo          c_item_details%ROWTYPE;
   item_tl          c_get_item_description%ROWTYPE;
   l_return_status  VARCHAR2(1);

BEGIN

   OPEN c_item_details;
   FETCH c_item_details INTO recinfo;

   IF (c_item_details%NOTFOUND) THEN
      CLOSE c_item_details;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   CLOSE c_item_details;

   IF (((recinfo.PRIMARY_UOM_CODE = P_Item_Rec.PRIMARY_UOM_CODE)
           OR ((recinfo.PRIMARY_UOM_CODE is null) AND (P_Item_Rec.PRIMARY_UOM_CODE is null)))
      AND ((recinfo.ALLOWED_UNITS_LOOKUP_CODE = P_Item_Rec.ALLOWED_UNITS_LOOKUP_CODE)
           OR ((recinfo.ALLOWED_UNITS_LOOKUP_CODE is null) AND (P_Item_Rec.ALLOWED_UNITS_LOOKUP_CODE is null)))
      AND ((recinfo.OVERCOMPLETION_TOLERANCE_TYPE = P_Item_Rec.OVERCOMPLETION_TOLERANCE_TYPE)
           OR ((recinfo.OVERCOMPLETION_TOLERANCE_TYPE is null) AND (P_Item_Rec.OVERCOMPLETION_TOLERANCE_TYPE is null)))
      AND ((recinfo.OVERCOMPLETION_TOLERANCE_VALUE = P_Item_Rec.OVERCOMPLETION_TOLERANCE_VALUE)
           OR ((recinfo.OVERCOMPLETION_TOLERANCE_VALUE is null) AND (P_Item_Rec.OVERCOMPLETION_TOLERANCE_VALUE is null)))
      AND ((recinfo.EFFECTIVITY_CONTROL = P_Item_Rec.EFFECTIVITY_CONTROL)
           OR ((recinfo.EFFECTIVITY_CONTROL is null) AND (P_Item_Rec.EFFECTIVITY_CONTROL is null)))
      AND ((recinfo.CHECK_SHORTAGES_FLAG = P_Item_Rec.CHECK_SHORTAGES_FLAG)
           OR ((recinfo.CHECK_SHORTAGES_FLAG is null) AND (P_Item_Rec.CHECK_SHORTAGES_FLAG is null)))
      AND ((recinfo.FULL_LEAD_TIME = P_Item_Rec.FULL_LEAD_TIME)
           OR ((recinfo.FULL_LEAD_TIME is null) AND (P_Item_Rec.FULL_LEAD_TIME is null)))
      AND ((recinfo.ORDER_COST = P_Item_Rec.ORDER_COST)
           OR ((recinfo.ORDER_COST is null) AND (P_Item_Rec.ORDER_COST is null)))
      AND ((recinfo.MRP_SAFETY_STOCK_PERCENT = P_Item_Rec.MRP_SAFETY_STOCK_PERCENT)
           OR ((recinfo.MRP_SAFETY_STOCK_PERCENT is null) AND (P_Item_Rec.MRP_SAFETY_STOCK_PERCENT is null)))
      AND ((recinfo.MRP_SAFETY_STOCK_CODE = P_Item_Rec.MRP_SAFETY_STOCK_CODE)
           OR ((recinfo.MRP_SAFETY_STOCK_CODE is null) AND (P_Item_Rec.MRP_SAFETY_STOCK_CODE is null)))
      AND ((recinfo.MIN_MINMAX_QUANTITY = P_Item_Rec.MIN_MINMAX_QUANTITY)
           OR ((recinfo.MIN_MINMAX_QUANTITY is null) AND (P_Item_Rec.MIN_MINMAX_QUANTITY is null)))
      AND ((recinfo.MAX_MINMAX_QUANTITY = P_Item_Rec.MAX_MINMAX_QUANTITY)
           OR ((recinfo.MAX_MINMAX_QUANTITY is null) AND (P_Item_Rec.MAX_MINMAX_QUANTITY is null)))
      AND ((recinfo.MINIMUM_ORDER_QUANTITY = P_Item_Rec.MINIMUM_ORDER_QUANTITY)
           OR ((recinfo.MINIMUM_ORDER_QUANTITY is null) AND (P_Item_Rec.MINIMUM_ORDER_QUANTITY is null)))
      AND ((recinfo.FIXED_ORDER_QUANTITY = P_Item_Rec.FIXED_ORDER_QUANTITY)
           OR ((recinfo.FIXED_ORDER_QUANTITY is null) AND (P_Item_Rec.FIXED_ORDER_QUANTITY is null)))
      AND ((recinfo.FIXED_DAYS_SUPPLY = P_Item_Rec.FIXED_DAYS_SUPPLY)
           OR ((recinfo.FIXED_DAYS_SUPPLY is null) AND (P_Item_Rec.FIXED_DAYS_SUPPLY is null)))
      AND ((recinfo.MAXIMUM_ORDER_QUANTITY = P_Item_Rec.MAXIMUM_ORDER_QUANTITY)
           OR ((recinfo.MAXIMUM_ORDER_QUANTITY is null) AND (P_Item_Rec.MAXIMUM_ORDER_QUANTITY is null)))
      AND ((recinfo.ATP_RULE_ID = P_Item_Rec.ATP_RULE_ID)
           OR ((recinfo.ATP_RULE_ID is null) AND (P_Item_Rec.ATP_RULE_ID is null)))
      AND ((recinfo.PICKING_RULE_ID = P_Item_Rec.PICKING_RULE_ID)
           OR ((recinfo.PICKING_RULE_ID is null) AND (P_Item_Rec.PICKING_RULE_ID is null)))
      AND ((recinfo.RESERVABLE_TYPE = P_Item_Rec.RESERVABLE_TYPE)
           OR ((recinfo.RESERVABLE_TYPE is null) AND (P_Item_Rec.RESERVABLE_TYPE is null)))
      AND ((recinfo.POSITIVE_MEASUREMENT_ERROR = P_Item_Rec.POSITIVE_MEASUREMENT_ERROR)
           OR ((recinfo.POSITIVE_MEASUREMENT_ERROR is null) AND (P_Item_Rec.POSITIVE_MEASUREMENT_ERROR is null)))
      AND ((recinfo.NEGATIVE_MEASUREMENT_ERROR = P_Item_Rec.NEGATIVE_MEASUREMENT_ERROR)
           OR ((recinfo.NEGATIVE_MEASUREMENT_ERROR is null) AND (P_Item_Rec.NEGATIVE_MEASUREMENT_ERROR is null)))
      AND ((recinfo.ENGINEERING_ECN_CODE = P_Item_Rec.ENGINEERING_ECN_CODE)
           OR ((recinfo.ENGINEERING_ECN_CODE is null) AND (P_Item_Rec.ENGINEERING_ECN_CODE is null)))
      AND ((recinfo.ENGINEERING_ITEM_ID = P_Item_Rec.ENGINEERING_ITEM_ID)
           OR ((recinfo.ENGINEERING_ITEM_ID is null) AND (P_Item_Rec.ENGINEERING_ITEM_ID is null)))
      AND ((recinfo.ENGINEERING_DATE = P_Item_Rec.ENGINEERING_DATE)
           OR ((recinfo.ENGINEERING_DATE is null) AND (P_Item_Rec.ENGINEERING_DATE is null)))
      AND ((recinfo.SERVICE_STARTING_DELAY = P_Item_Rec.SERVICE_STARTING_DELAY)
           OR ((recinfo.SERVICE_STARTING_DELAY is null) AND (P_Item_Rec.SERVICE_STARTING_DELAY is null)))
      AND ((recinfo.SERVICEABLE_COMPONENT_FLAG = P_Item_Rec.SERVICEABLE_COMPONENT_FLAG)
           OR ((recinfo.SERVICEABLE_COMPONENT_FLAG is null) AND (P_Item_Rec.SERVICEABLE_COMPONENT_FLAG is null)))
      AND (recinfo.SERVICEABLE_PRODUCT_FLAG = P_Item_Rec.SERVICEABLE_PRODUCT_FLAG)
      AND ((recinfo.PAYMENT_TERMS_ID = P_Item_Rec.PAYMENT_TERMS_ID)
           OR ((recinfo.PAYMENT_TERMS_ID is null) AND (P_Item_Rec.PAYMENT_TERMS_ID is null)))
      AND ((recinfo.PREVENTIVE_MAINTENANCE_FLAG = P_Item_Rec.PREVENTIVE_MAINTENANCE_FLAG)
           OR ((recinfo.PREVENTIVE_MAINTENANCE_FLAG is null) AND (P_Item_Rec.PREVENTIVE_MAINTENANCE_FLAG is null)))
      AND ((recinfo.MATERIAL_BILLABLE_FLAG = P_Item_Rec.MATERIAL_BILLABLE_FLAG)
           OR ((recinfo.MATERIAL_BILLABLE_FLAG is null) AND (P_Item_Rec.MATERIAL_BILLABLE_FLAG is null)))
      AND ((recinfo.PRORATE_SERVICE_FLAG = P_Item_Rec.PRORATE_SERVICE_FLAG)
           OR ((recinfo.PRORATE_SERVICE_FLAG is null) AND (P_Item_Rec.PRORATE_SERVICE_FLAG is null)))
      AND ((recinfo.COVERAGE_SCHEDULE_ID = P_Item_Rec.COVERAGE_SCHEDULE_ID)
           OR ((recinfo.COVERAGE_SCHEDULE_ID is null) AND (P_Item_Rec.COVERAGE_SCHEDULE_ID is null)))
      AND ((recinfo.SERVICE_DURATION_PERIOD_CODE = P_Item_Rec.SERVICE_DURATION_PERIOD_CODE)
           OR ((recinfo.SERVICE_DURATION_PERIOD_CODE is null) AND (P_Item_Rec.SERVICE_DURATION_PERIOD_CODE is null)))
      AND ((recinfo.SERVICE_DURATION = P_Item_Rec.SERVICE_DURATION)
           OR ((recinfo.SERVICE_DURATION is null) AND (P_Item_Rec.SERVICE_DURATION is null)))
      AND (recinfo.INVOICEABLE_ITEM_FLAG = P_Item_Rec.INVOICEABLE_ITEM_FLAG)
      AND ((recinfo.TAX_CODE = P_Item_Rec.TAX_CODE)
           OR ((recinfo.TAX_CODE is null) AND (P_Item_Rec.TAX_CODE is null)))
      AND (recinfo.INVOICE_ENABLED_FLAG = P_Item_Rec.INVOICE_ENABLED_FLAG)
      AND (recinfo.MUST_USE_APPROVED_VENDOR_FLAG = P_Item_Rec.MUST_USE_APPROVED_VENDOR_FLAG)
      AND (recinfo.OUTSIDE_OPERATION_FLAG = P_Item_Rec.OUTSIDE_OPERATION_FLAG)
      AND ((recinfo.OUTSIDE_OPERATION_UOM_TYPE = P_Item_Rec.OUTSIDE_OPERATION_UOM_TYPE)
           OR ((recinfo.OUTSIDE_OPERATION_UOM_TYPE is null) AND (P_Item_Rec.OUTSIDE_OPERATION_UOM_TYPE is null)))
      AND ((recinfo.SAFETY_STOCK_BUCKET_DAYS = P_Item_Rec.SAFETY_STOCK_BUCKET_DAYS)
           OR ((recinfo.SAFETY_STOCK_BUCKET_DAYS is null) AND (P_Item_Rec.SAFETY_STOCK_BUCKET_DAYS is null)))
      AND ((recinfo.AUTO_REDUCE_MPS = P_Item_Rec.AUTO_REDUCE_MPS)
           OR ((recinfo.AUTO_REDUCE_MPS is null) AND (P_Item_Rec.AUTO_REDUCE_MPS is null)))
      AND (recinfo.COSTING_ENABLED_FLAG = P_Item_Rec.COSTING_ENABLED_FLAG)
      AND (recinfo.AUTO_CREATED_CONFIG_FLAG = P_Item_Rec.AUTO_CREATED_CONFIG_FLAG)
      AND (recinfo.CYCLE_COUNT_ENABLED_FLAG = P_Item_Rec.CYCLE_COUNT_ENABLED_FLAG)
      AND ((recinfo.ITEM_TYPE = P_Item_Rec.ITEM_TYPE)
           OR ((recinfo.ITEM_TYPE is null) AND (P_Item_Rec.ITEM_TYPE is null)))
      AND ((recinfo.SHIP_MODEL_COMPLETE_FLAG = P_Item_Rec.SHIP_MODEL_COMPLETE_FLAG)
           OR ((recinfo.SHIP_MODEL_COMPLETE_FLAG is null) AND (P_Item_Rec.SHIP_MODEL_COMPLETE_FLAG is null)))
      AND ((recinfo.MRP_PLANNING_CODE = P_Item_Rec.MRP_PLANNING_CODE)
           OR ((recinfo.MRP_PLANNING_CODE is null) AND (P_Item_Rec.MRP_PLANNING_CODE is null)))
      AND ((recinfo.RETURN_INSPECTION_REQUIREMENT = P_Item_Rec.RETURN_INSPECTION_REQUIREMENT)
           OR ((recinfo.RETURN_INSPECTION_REQUIREMENT is null) AND (P_Item_Rec.RETURN_INSPECTION_REQUIREMENT is null)))
      AND ((recinfo.ATO_FORECAST_CONTROL = P_Item_Rec.ATO_FORECAST_CONTROL)
           OR ((recinfo.ATO_FORECAST_CONTROL is null) AND (P_Item_Rec.ATO_FORECAST_CONTROL is null)))
      AND ((recinfo.RELEASE_TIME_FENCE_CODE = P_Item_Rec.RELEASE_TIME_FENCE_CODE)
           OR ((recinfo.RELEASE_TIME_FENCE_CODE is null) AND (P_Item_Rec.RELEASE_TIME_FENCE_CODE is null)))
      AND ((recinfo.RELEASE_TIME_FENCE_DAYS = P_Item_Rec.RELEASE_TIME_FENCE_DAYS)
           OR ((recinfo.RELEASE_TIME_FENCE_DAYS is null) AND (P_Item_Rec.RELEASE_TIME_FENCE_DAYS is null)))
      AND ((recinfo.CONTAINER_ITEM_FLAG = P_Item_Rec.CONTAINER_ITEM_FLAG)
           OR ((recinfo.CONTAINER_ITEM_FLAG is null) AND (P_Item_Rec.CONTAINER_ITEM_FLAG is null)))
      AND ((recinfo.VEHICLE_ITEM_FLAG = P_Item_Rec.VEHICLE_ITEM_FLAG)
           OR ((recinfo.VEHICLE_ITEM_FLAG is null) AND (P_Item_Rec.VEHICLE_ITEM_FLAG is null)))
      AND ((recinfo.MAXIMUM_LOAD_WEIGHT = P_Item_Rec.MAXIMUM_LOAD_WEIGHT)
           OR ((recinfo.MAXIMUM_LOAD_WEIGHT is null) AND (P_Item_Rec.MAXIMUM_LOAD_WEIGHT is null)))
      AND ((recinfo.MINIMUM_FILL_PERCENT = P_Item_Rec.MINIMUM_FILL_PERCENT)
           OR ((recinfo.MINIMUM_FILL_PERCENT is null) AND (P_Item_Rec.MINIMUM_FILL_PERCENT is null)))
      AND ((recinfo.CONTAINER_TYPE_CODE = P_Item_Rec.CONTAINER_TYPE_CODE)
           OR ((recinfo.CONTAINER_TYPE_CODE is null) AND (P_Item_Rec.CONTAINER_TYPE_CODE is null)))
      AND ((recinfo.INTERNAL_VOLUME = P_Item_Rec.INTERNAL_VOLUME)
           OR ((recinfo.INTERNAL_VOLUME is null) AND (P_Item_Rec.INTERNAL_VOLUME is null)))
      AND ((recinfo.PRODUCT_FAMILY_ITEM_ID = P_Item_Rec.PRODUCT_FAMILY_ITEM_ID)
           OR ((recinfo.PRODUCT_FAMILY_ITEM_ID is null) AND (P_Item_Rec.PRODUCT_FAMILY_ITEM_ID is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE_CATEGORY = P_Item_Rec.GLOBAL_ATTRIBUTE_CATEGORY)
           OR ((recinfo.GLOBAL_ATTRIBUTE_CATEGORY is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE1 = P_Item_Rec.GLOBAL_ATTRIBUTE1)
           OR ((recinfo.GLOBAL_ATTRIBUTE1 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE1 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE2 = P_Item_Rec.GLOBAL_ATTRIBUTE2)
           OR ((recinfo.GLOBAL_ATTRIBUTE2 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE2 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE3 = P_Item_Rec.GLOBAL_ATTRIBUTE3)
           OR ((recinfo.GLOBAL_ATTRIBUTE3 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE3 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE4 = P_Item_Rec.GLOBAL_ATTRIBUTE4)
           OR ((recinfo.GLOBAL_ATTRIBUTE4 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE4 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE5 = P_Item_Rec.GLOBAL_ATTRIBUTE5)
           OR ((recinfo.GLOBAL_ATTRIBUTE5 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE5 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE6 = P_Item_Rec.GLOBAL_ATTRIBUTE6)
           OR ((recinfo.GLOBAL_ATTRIBUTE6 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE6 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE7 = P_Item_Rec.GLOBAL_ATTRIBUTE7)
           OR ((recinfo.GLOBAL_ATTRIBUTE7 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE7 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE8 = P_Item_Rec.GLOBAL_ATTRIBUTE8)
           OR ((recinfo.GLOBAL_ATTRIBUTE8 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE8 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE9 = P_Item_Rec.GLOBAL_ATTRIBUTE9)
           OR ((recinfo.GLOBAL_ATTRIBUTE9 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE9 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE10 = P_Item_Rec.GLOBAL_ATTRIBUTE10)
           OR ((recinfo.GLOBAL_ATTRIBUTE10 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE10 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE11 = P_Item_Rec.GLOBAL_ATTRIBUTE11)
           OR ((recinfo.GLOBAL_ATTRIBUTE11 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE11 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE12 = P_Item_Rec.GLOBAL_ATTRIBUTE12)
           OR ((recinfo.GLOBAL_ATTRIBUTE12 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE12 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE13 = P_Item_Rec.GLOBAL_ATTRIBUTE13)
           OR ((recinfo.GLOBAL_ATTRIBUTE13 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE13 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE14 = P_Item_Rec.GLOBAL_ATTRIBUTE14)
           OR ((recinfo.GLOBAL_ATTRIBUTE14 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE14 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE15 = P_Item_Rec.GLOBAL_ATTRIBUTE15)
           OR ((recinfo.GLOBAL_ATTRIBUTE15 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE15 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE16 = P_Item_Rec.GLOBAL_ATTRIBUTE16)
           OR ((recinfo.GLOBAL_ATTRIBUTE16 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE16 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE17 = P_Item_Rec.GLOBAL_ATTRIBUTE17)
           OR ((recinfo.GLOBAL_ATTRIBUTE17 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE17 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE18 = P_Item_Rec.GLOBAL_ATTRIBUTE18)
           OR ((recinfo.GLOBAL_ATTRIBUTE18 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE18 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE19 = P_Item_Rec.GLOBAL_ATTRIBUTE19)
           OR ((recinfo.GLOBAL_ATTRIBUTE19 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE19 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE20 = P_Item_Rec.GLOBAL_ATTRIBUTE20)
           OR ((recinfo.GLOBAL_ATTRIBUTE20 is null) AND (P_Item_Rec.GLOBAL_ATTRIBUTE20 is null)))
      AND ((recinfo.PURCHASING_TAX_CODE = P_Item_Rec.PURCHASING_TAX_CODE)
           OR ((recinfo.PURCHASING_TAX_CODE is null) AND (P_Item_Rec.PURCHASING_TAX_CODE is null)))
      AND ((recinfo.ATTRIBUTE6 = P_Item_Rec.ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_Item_Rec.ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_Item_Rec.ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_Item_Rec.ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_Item_Rec.ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_Item_Rec.ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_Item_Rec.ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_Item_Rec.ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_Item_Rec.ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_Item_Rec.ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_Item_Rec.ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_Item_Rec.ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = P_Item_Rec.ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_Item_Rec.ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_Item_Rec.ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_Item_Rec.ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_Item_Rec.ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_Item_Rec.ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_Item_Rec.ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_Item_Rec.ATTRIBUTE15 is null)))
      AND (recinfo.PURCHASING_ITEM_FLAG = P_Item_Rec.PURCHASING_ITEM_FLAG)
      AND (recinfo.SHIPPABLE_ITEM_FLAG = P_Item_Rec.SHIPPABLE_ITEM_FLAG)
      AND (recinfo.CUSTOMER_ORDER_FLAG = P_Item_Rec.CUSTOMER_ORDER_FLAG)
      AND (recinfo.INTERNAL_ORDER_FLAG = P_Item_Rec.INTERNAL_ORDER_FLAG)
      AND (recinfo.INVENTORY_ITEM_FLAG = P_Item_Rec.INVENTORY_ITEM_FLAG)
      AND (recinfo.ENG_ITEM_FLAG = P_Item_Rec.ENG_ITEM_FLAG)
      AND (recinfo.INVENTORY_ASSET_FLAG = P_Item_Rec.INVENTORY_ASSET_FLAG)
      AND (recinfo.PURCHASING_ENABLED_FLAG = P_Item_Rec.PURCHASING_ENABLED_FLAG)
      AND (recinfo.CUSTOMER_ORDER_ENABLED_FLAG = P_Item_Rec.CUSTOMER_ORDER_ENABLED_FLAG)
      AND (recinfo.INTERNAL_ORDER_ENABLED_FLAG = P_Item_Rec.INTERNAL_ORDER_ENABLED_FLAG)
      AND (recinfo.SO_TRANSACTIONS_FLAG = P_Item_Rec.SO_TRANSACTIONS_FLAG)
      AND (recinfo.MTL_TRANSACTIONS_ENABLED_FLAG = P_Item_Rec.MTL_TRANSACTIONS_ENABLED_FLAG)
      AND (recinfo.STOCK_ENABLED_FLAG = P_Item_Rec.STOCK_ENABLED_FLAG)
      AND (recinfo.BOM_ENABLED_FLAG = P_Item_Rec.BOM_ENABLED_FLAG)
      AND (recinfo.BUILD_IN_WIP_FLAG = P_Item_Rec.BUILD_IN_WIP_FLAG)
      AND ((recinfo.REVISION_QTY_CONTROL_CODE = P_Item_Rec.REVISION_QTY_CONTROL_CODE)
           OR ((recinfo.REVISION_QTY_CONTROL_CODE is null) AND (P_Item_Rec.REVISION_QTY_CONTROL_CODE is null)))
      AND ((recinfo.ITEM_CATALOG_GROUP_ID = P_Item_Rec.ITEM_CATALOG_GROUP_ID)
           OR ((recinfo.ITEM_CATALOG_GROUP_ID is null) AND (P_Item_Rec.ITEM_CATALOG_GROUP_ID is null)))
      AND ((recinfo.CATALOG_STATUS_FLAG = P_Item_Rec.CATALOG_STATUS_FLAG)
           OR ((recinfo.CATALOG_STATUS_FLAG is null) AND (P_Item_Rec.CATALOG_STATUS_FLAG is null)))
      AND ((recinfo.RETURNABLE_FLAG = P_Item_Rec.RETURNABLE_FLAG)
           OR ((recinfo.RETURNABLE_FLAG is null) AND (P_Item_Rec.RETURNABLE_FLAG is null)))
      AND ((recinfo.DEFAULT_SHIPPING_ORG = P_Item_Rec.DEFAULT_SHIPPING_ORG)
           OR ((recinfo.DEFAULT_SHIPPING_ORG is null) AND (P_Item_Rec.DEFAULT_SHIPPING_ORG is null)))
      AND ((recinfo.COLLATERAL_FLAG = P_Item_Rec.COLLATERAL_FLAG)
           OR ((recinfo.COLLATERAL_FLAG is null) AND (P_Item_Rec.COLLATERAL_FLAG is null)))
      AND ((recinfo.TAXABLE_FLAG = P_Item_Rec.TAXABLE_FLAG)
           OR ((recinfo.TAXABLE_FLAG is null) AND (P_Item_Rec.TAXABLE_FLAG is null)))
      AND ((recinfo.QTY_RCV_EXCEPTION_CODE = P_Item_Rec.QTY_RCV_EXCEPTION_CODE)
           OR ((recinfo.QTY_RCV_EXCEPTION_CODE is null) AND (P_Item_Rec.QTY_RCV_EXCEPTION_CODE is null)))
      AND ((recinfo.ALLOW_ITEM_DESC_UPDATE_FLAG = P_Item_Rec.ALLOW_ITEM_DESC_UPDATE_FLAG)
           OR ((recinfo.ALLOW_ITEM_DESC_UPDATE_FLAG is null) AND (P_Item_Rec.ALLOW_ITEM_DESC_UPDATE_FLAG is null)))
      AND ((recinfo.INSPECTION_REQUIRED_FLAG = P_Item_Rec.INSPECTION_REQUIRED_FLAG)
           OR ((recinfo.INSPECTION_REQUIRED_FLAG is null) AND (P_Item_Rec.INSPECTION_REQUIRED_FLAG is null)))
      AND ((recinfo.RECEIPT_REQUIRED_FLAG = P_Item_Rec.RECEIPT_REQUIRED_FLAG)
           OR ((recinfo.RECEIPT_REQUIRED_FLAG is null) AND (P_Item_Rec.RECEIPT_REQUIRED_FLAG is null)))
      AND ((recinfo.MARKET_PRICE = P_Item_Rec.MARKET_PRICE)
           OR ((recinfo.MARKET_PRICE is null) AND (P_Item_Rec.MARKET_PRICE is null)))
      AND ((recinfo.HAZARD_CLASS_ID = P_Item_Rec.HAZARD_CLASS_ID)
           OR ((recinfo.HAZARD_CLASS_ID is null) AND (P_Item_Rec.HAZARD_CLASS_ID is null)))
      AND ((recinfo.RFQ_REQUIRED_FLAG = P_Item_Rec.RFQ_REQUIRED_FLAG)
           OR ((recinfo.RFQ_REQUIRED_FLAG is null) AND (P_Item_Rec.RFQ_REQUIRED_FLAG is null)))
      AND ((recinfo.QTY_RCV_TOLERANCE = P_Item_Rec.QTY_RCV_TOLERANCE)
           OR ((recinfo.QTY_RCV_TOLERANCE is null) AND (P_Item_Rec.QTY_RCV_TOLERANCE is null)))
      AND ((recinfo.LIST_PRICE_PER_UNIT = P_Item_Rec.LIST_PRICE_PER_UNIT)
           OR ((recinfo.LIST_PRICE_PER_UNIT is null) AND (P_Item_Rec.LIST_PRICE_PER_UNIT is null)))
      AND ((recinfo.UN_NUMBER_ID = P_Item_Rec.UN_NUMBER_ID)
           OR ((recinfo.UN_NUMBER_ID is null) AND (P_Item_Rec.UN_NUMBER_ID is null)))
      AND ((recinfo.PRICE_TOLERANCE_PERCENT = P_Item_Rec.PRICE_TOLERANCE_PERCENT)
           OR ((recinfo.PRICE_TOLERANCE_PERCENT is null) AND (P_Item_Rec.PRICE_TOLERANCE_PERCENT is null)))
      AND ((recinfo.ASSET_CATEGORY_ID = P_Item_Rec.ASSET_CATEGORY_ID)
           OR ((recinfo.ASSET_CATEGORY_ID is null) AND (P_Item_Rec.ASSET_CATEGORY_ID is null)))
      AND ((recinfo.ROUNDING_FACTOR = P_Item_Rec.ROUNDING_FACTOR)
           OR ((recinfo.ROUNDING_FACTOR is null) AND (P_Item_Rec.ROUNDING_FACTOR is null)))
      AND ((recinfo.UNIT_OF_ISSUE = P_Item_Rec.UNIT_OF_ISSUE)
           OR ((recinfo.UNIT_OF_ISSUE is null) AND (P_Item_Rec.UNIT_OF_ISSUE is null)))
      AND ((recinfo.ENFORCE_SHIP_TO_LOCATION_CODE = P_Item_Rec.ENFORCE_SHIP_TO_LOCATION_CODE)
           OR ((recinfo.ENFORCE_SHIP_TO_LOCATION_CODE is null) AND (P_Item_Rec.ENFORCE_SHIP_TO_LOCATION_CODE is null)))
      AND ((recinfo.ALLOW_SUBSTITUTE_RECEIPTS_FLAG = P_Item_Rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG)
           OR ((recinfo.ALLOW_SUBSTITUTE_RECEIPTS_FLAG is null) AND (P_Item_Rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG is null)))
      AND ((recinfo.ALLOW_UNORDERED_RECEIPTS_FLAG = P_Item_Rec.ALLOW_UNORDERED_RECEIPTS_FLAG)
           OR ((recinfo.ALLOW_UNORDERED_RECEIPTS_FLAG is null) AND (P_Item_Rec.ALLOW_UNORDERED_RECEIPTS_FLAG is null)))
      AND ((recinfo.ALLOW_EXPRESS_DELIVERY_FLAG = P_Item_Rec.ALLOW_EXPRESS_DELIVERY_FLAG)
           OR ((recinfo.ALLOW_EXPRESS_DELIVERY_FLAG is null) AND (P_Item_Rec.ALLOW_EXPRESS_DELIVERY_FLAG is null)))
      AND ((recinfo.DAYS_EARLY_RECEIPT_ALLOWED = P_Item_Rec.DAYS_EARLY_RECEIPT_ALLOWED)
           OR ((recinfo.DAYS_EARLY_RECEIPT_ALLOWED is null) AND (P_Item_Rec.DAYS_EARLY_RECEIPT_ALLOWED is null)))
      AND ((recinfo.DAYS_LATE_RECEIPT_ALLOWED = P_Item_Rec.DAYS_LATE_RECEIPT_ALLOWED)
           OR ((recinfo.DAYS_LATE_RECEIPT_ALLOWED is null) AND (P_Item_Rec.DAYS_LATE_RECEIPT_ALLOWED is null)))
      AND ((recinfo.RECEIPT_DAYS_EXCEPTION_CODE = P_Item_Rec.RECEIPT_DAYS_EXCEPTION_CODE)
           OR ((recinfo.RECEIPT_DAYS_EXCEPTION_CODE is null) AND (P_Item_Rec.RECEIPT_DAYS_EXCEPTION_CODE is null)))
      AND ((recinfo.RECEIVING_ROUTING_ID = P_Item_Rec.RECEIVING_ROUTING_ID)
           OR ((recinfo.RECEIVING_ROUTING_ID is null) AND (P_Item_Rec.RECEIVING_ROUTING_ID is null)))
      AND ((recinfo.INVOICE_CLOSE_TOLERANCE = P_Item_Rec.INVOICE_CLOSE_TOLERANCE)
           OR ((recinfo.INVOICE_CLOSE_TOLERANCE is null) AND (P_Item_Rec.INVOICE_CLOSE_TOLERANCE is null)))
      AND ((recinfo.RECEIVE_CLOSE_TOLERANCE = P_Item_Rec.RECEIVE_CLOSE_TOLERANCE)
           OR ((recinfo.RECEIVE_CLOSE_TOLERANCE is null) AND (P_Item_Rec.RECEIVE_CLOSE_TOLERANCE is null)))
      AND ((recinfo.AUTO_LOT_ALPHA_PREFIX = P_Item_Rec.AUTO_LOT_ALPHA_PREFIX)
           OR ((recinfo.AUTO_LOT_ALPHA_PREFIX is null) AND (P_Item_Rec.AUTO_LOT_ALPHA_PREFIX is null)))
      AND ((recinfo.START_AUTO_LOT_NUMBER = P_Item_Rec.START_AUTO_LOT_NUMBER)
           OR ((recinfo.START_AUTO_LOT_NUMBER is null) AND (P_Item_Rec.START_AUTO_LOT_NUMBER is null)))
      AND ((recinfo.LOT_CONTROL_CODE = P_Item_Rec.LOT_CONTROL_CODE)
           OR ((recinfo.LOT_CONTROL_CODE is null) AND (P_Item_Rec.LOT_CONTROL_CODE is null)))
      AND ((recinfo.SHELF_LIFE_CODE = P_Item_Rec.SHELF_LIFE_CODE)
           OR ((recinfo.SHELF_LIFE_CODE is null) AND (P_Item_Rec.SHELF_LIFE_CODE is null)))
      AND ((recinfo.SHELF_LIFE_DAYS = P_Item_Rec.SHELF_LIFE_DAYS)
           OR ((recinfo.SHELF_LIFE_DAYS is null) AND (P_Item_Rec.SHELF_LIFE_DAYS is null)))
      AND ((recinfo.SERIAL_NUMBER_CONTROL_CODE = P_Item_Rec.SERIAL_NUMBER_CONTROL_CODE)
           OR ((recinfo.SERIAL_NUMBER_CONTROL_CODE is null) AND (P_Item_Rec.SERIAL_NUMBER_CONTROL_CODE is null)))
      AND ((recinfo.START_AUTO_SERIAL_NUMBER = P_Item_Rec.START_AUTO_SERIAL_NUMBER)
           OR ((recinfo.START_AUTO_SERIAL_NUMBER is null) AND (P_Item_Rec.START_AUTO_SERIAL_NUMBER is null)))
      AND ((recinfo.AUTO_SERIAL_ALPHA_PREFIX = P_Item_Rec.AUTO_SERIAL_ALPHA_PREFIX)
           OR ((recinfo.AUTO_SERIAL_ALPHA_PREFIX is null) AND (P_Item_Rec.AUTO_SERIAL_ALPHA_PREFIX is null)))
      AND ((recinfo.SOURCE_TYPE = P_Item_Rec.SOURCE_TYPE)
           OR ((recinfo.SOURCE_TYPE is null) AND (P_Item_Rec.SOURCE_TYPE is null)))
      AND ((recinfo.SOURCE_ORGANIZATION_ID = P_Item_Rec.SOURCE_ORGANIZATION_ID)
           OR ((recinfo.SOURCE_ORGANIZATION_ID is null) AND (P_Item_Rec.SOURCE_ORGANIZATION_ID is null)))
      AND ((recinfo.SOURCE_SUBINVENTORY = P_Item_Rec.SOURCE_SUBINVENTORY)
           OR ((recinfo.SOURCE_SUBINVENTORY is null) AND (P_Item_Rec.SOURCE_SUBINVENTORY is null)))
      AND ((recinfo.EXPENSE_ACCOUNT = P_Item_Rec.EXPENSE_ACCOUNT)
           OR ((recinfo.EXPENSE_ACCOUNT is null) AND (P_Item_Rec.EXPENSE_ACCOUNT is null)))
      AND ((recinfo.ENCUMBRANCE_ACCOUNT = P_Item_Rec.ENCUMBRANCE_ACCOUNT)
           OR ((recinfo.ENCUMBRANCE_ACCOUNT is null) AND (P_Item_Rec.ENCUMBRANCE_ACCOUNT is null)))
      AND ((recinfo.RESTRICT_SUBINVENTORIES_CODE = P_Item_Rec.RESTRICT_SUBINVENTORIES_CODE)
           OR ((recinfo.RESTRICT_SUBINVENTORIES_CODE is null) AND (P_Item_Rec.RESTRICT_SUBINVENTORIES_CODE is null)))
      AND ((recinfo.UNIT_WEIGHT = P_Item_Rec.UNIT_WEIGHT)
           OR ((recinfo.UNIT_WEIGHT is null) AND (P_Item_Rec.UNIT_WEIGHT is null)))
      AND ((recinfo.WEIGHT_UOM_CODE = P_Item_Rec.WEIGHT_UOM_CODE)
           OR ((recinfo.WEIGHT_UOM_CODE is null) AND (P_Item_Rec.WEIGHT_UOM_CODE is null)))
      AND ((recinfo.VOLUME_UOM_CODE = P_Item_Rec.VOLUME_UOM_CODE)
           OR ((recinfo.VOLUME_UOM_CODE is null) AND (P_Item_Rec.VOLUME_UOM_CODE is null)))
      AND ((recinfo.UNIT_VOLUME = P_Item_Rec.UNIT_VOLUME)
           OR ((recinfo.UNIT_VOLUME is null) AND (P_Item_Rec.UNIT_VOLUME is null)))
      AND ((recinfo.RESTRICT_LOCATORS_CODE = P_Item_Rec.RESTRICT_LOCATORS_CODE)
           OR ((recinfo.RESTRICT_LOCATORS_CODE is null) AND (P_Item_Rec.RESTRICT_LOCATORS_CODE is null)))
      AND ((recinfo.LOCATION_CONTROL_CODE = P_Item_Rec.LOCATION_CONTROL_CODE)
           OR ((recinfo.LOCATION_CONTROL_CODE is null) AND (P_Item_Rec.LOCATION_CONTROL_CODE is null)))
      AND ((recinfo.SHRINKAGE_RATE = P_Item_Rec.SHRINKAGE_RATE)
           OR ((recinfo.SHRINKAGE_RATE is null) AND (P_Item_Rec.SHRINKAGE_RATE is null)))
      AND ((recinfo.ACCEPTABLE_EARLY_DAYS = P_Item_Rec.ACCEPTABLE_EARLY_DAYS)
           OR ((recinfo.ACCEPTABLE_EARLY_DAYS is null) AND (P_Item_Rec.ACCEPTABLE_EARLY_DAYS is null)))
      AND ((recinfo.PLANNING_TIME_FENCE_CODE = P_Item_Rec.PLANNING_TIME_FENCE_CODE)
           OR ((recinfo.PLANNING_TIME_FENCE_CODE is null) AND (P_Item_Rec.PLANNING_TIME_FENCE_CODE is null)))
      AND ((recinfo.DEMAND_TIME_FENCE_CODE = P_Item_Rec.DEMAND_TIME_FENCE_CODE)
           OR ((recinfo.DEMAND_TIME_FENCE_CODE is null) AND (P_Item_Rec.DEMAND_TIME_FENCE_CODE is null)))
      AND ((recinfo.LEAD_TIME_LOT_SIZE = P_Item_Rec.LEAD_TIME_LOT_SIZE)
           OR ((recinfo.LEAD_TIME_LOT_SIZE is null) AND (P_Item_Rec.LEAD_TIME_LOT_SIZE is null)))
      AND ((recinfo.STD_LOT_SIZE = P_Item_Rec.STD_LOT_SIZE)
           OR ((recinfo.STD_LOT_SIZE is null) AND (P_Item_Rec.STD_LOT_SIZE is null)))
      AND ((recinfo.CUM_MANUFACTURING_LEAD_TIME = P_Item_Rec.CUM_MANUFACTURING_LEAD_TIME)
           OR ((recinfo.CUM_MANUFACTURING_LEAD_TIME is null) AND (P_Item_Rec.CUM_MANUFACTURING_LEAD_TIME is null)))
      AND ((recinfo.OVERRUN_PERCENTAGE = P_Item_Rec.OVERRUN_PERCENTAGE)
           OR ((recinfo.OVERRUN_PERCENTAGE is null) AND (P_Item_Rec.OVERRUN_PERCENTAGE is null)))
      AND ((recinfo.MRP_CALCULATE_ATP_FLAG = P_Item_Rec.MRP_CALCULATE_ATP_FLAG)
           OR ((recinfo.MRP_CALCULATE_ATP_FLAG is null) AND (P_Item_Rec.MRP_CALCULATE_ATP_FLAG is null)))
      AND ((recinfo.ACCEPTABLE_RATE_INCREASE = P_Item_Rec.ACCEPTABLE_RATE_INCREASE)
           OR ((recinfo.ACCEPTABLE_RATE_INCREASE is null) AND (P_Item_Rec.ACCEPTABLE_RATE_INCREASE is null)))
      AND ((recinfo.ACCEPTABLE_RATE_DECREASE = P_Item_Rec.ACCEPTABLE_RATE_DECREASE)
           OR ((recinfo.ACCEPTABLE_RATE_DECREASE is null) AND (P_Item_Rec.ACCEPTABLE_RATE_DECREASE is null)))
      AND ((recinfo.CUMULATIVE_TOTAL_LEAD_TIME = P_Item_Rec.CUMULATIVE_TOTAL_LEAD_TIME)
           OR ((recinfo.CUMULATIVE_TOTAL_LEAD_TIME is null) AND (P_Item_Rec.CUMULATIVE_TOTAL_LEAD_TIME is null)))
      AND ((recinfo.PLANNING_TIME_FENCE_DAYS = P_Item_Rec.PLANNING_TIME_FENCE_DAYS)
           OR ((recinfo.PLANNING_TIME_FENCE_DAYS is null) AND (P_Item_Rec.PLANNING_TIME_FENCE_DAYS is null)))
      AND ((recinfo.DEMAND_TIME_FENCE_DAYS = P_Item_Rec.DEMAND_TIME_FENCE_DAYS)
           OR ((recinfo.DEMAND_TIME_FENCE_DAYS is null) AND (P_Item_Rec.DEMAND_TIME_FENCE_DAYS is null)))
      AND ((recinfo.END_ASSEMBLY_PEGGING_FLAG = P_Item_Rec.END_ASSEMBLY_PEGGING_FLAG)
           OR ((recinfo.END_ASSEMBLY_PEGGING_FLAG is null) AND (P_Item_Rec.END_ASSEMBLY_PEGGING_FLAG is null)))
      AND ((recinfo.REPETITIVE_PLANNING_FLAG = P_Item_Rec.REPETITIVE_PLANNING_FLAG)
           OR ((recinfo.REPETITIVE_PLANNING_FLAG is null) AND (P_Item_Rec.REPETITIVE_PLANNING_FLAG is null)))
      AND ((recinfo.PLANNING_EXCEPTION_SET = P_Item_Rec.PLANNING_EXCEPTION_SET)
           OR ((recinfo.PLANNING_EXCEPTION_SET is null) AND (P_Item_Rec.PLANNING_EXCEPTION_SET is null)))
      AND (recinfo.BOM_ITEM_TYPE = P_Item_Rec.BOM_ITEM_TYPE)
      AND (recinfo.PICK_COMPONENTS_FLAG = P_Item_Rec.PICK_COMPONENTS_FLAG)
      AND (recinfo.REPLENISH_TO_ORDER_FLAG = P_Item_Rec.REPLENISH_TO_ORDER_FLAG)
      AND ((recinfo.BASE_ITEM_ID = P_Item_Rec.BASE_ITEM_ID)
           OR ((recinfo.BASE_ITEM_ID is null) AND (P_Item_Rec.BASE_ITEM_ID is null)))
      AND (recinfo.ATP_COMPONENTS_FLAG = P_Item_Rec.ATP_COMPONENTS_FLAG)
      AND (recinfo.ATP_FLAG = P_Item_Rec.ATP_FLAG)
      AND ((recinfo.FIXED_LEAD_TIME = P_Item_Rec.FIXED_LEAD_TIME)
           OR ((recinfo.FIXED_LEAD_TIME is null) AND (P_Item_Rec.FIXED_LEAD_TIME is null)))
      AND ((recinfo.VARIABLE_LEAD_TIME = P_Item_Rec.VARIABLE_LEAD_TIME)
           OR ((recinfo.VARIABLE_LEAD_TIME is null) AND (P_Item_Rec.VARIABLE_LEAD_TIME is null)))
      AND ((recinfo.WIP_SUPPLY_LOCATOR_ID = P_Item_Rec.WIP_SUPPLY_LOCATOR_ID)
           OR ((recinfo.WIP_SUPPLY_LOCATOR_ID is null) AND (P_Item_Rec.WIP_SUPPLY_LOCATOR_ID is null)))
      AND ((recinfo.WIP_SUPPLY_TYPE = P_Item_Rec.WIP_SUPPLY_TYPE)
           OR ((recinfo.WIP_SUPPLY_TYPE is null) AND (P_Item_Rec.WIP_SUPPLY_TYPE is null)))
      AND ((recinfo.WIP_SUPPLY_SUBINVENTORY = P_Item_Rec.WIP_SUPPLY_SUBINVENTORY)
           OR ((recinfo.WIP_SUPPLY_SUBINVENTORY is null) AND (P_Item_Rec.WIP_SUPPLY_SUBINVENTORY is null)))
      AND ((recinfo.COST_OF_SALES_ACCOUNT = P_Item_Rec.COST_OF_SALES_ACCOUNT)
           OR ((recinfo.COST_OF_SALES_ACCOUNT is null) AND (P_Item_Rec.COST_OF_SALES_ACCOUNT is null)))
      AND ((recinfo.SALES_ACCOUNT = P_Item_Rec.SALES_ACCOUNT)
           OR ((recinfo.SALES_ACCOUNT is null) AND (P_Item_Rec.SALES_ACCOUNT is null)))
      AND ((recinfo.DEFAULT_INCLUDE_IN_ROLLUP_FLAG = P_Item_Rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG)
           OR ((recinfo.DEFAULT_INCLUDE_IN_ROLLUP_FLAG is null) AND (P_Item_Rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG is null)))
      AND ((recinfo.INVENTORY_ITEM_STATUS_CODE = P_Item_Rec.INVENTORY_ITEM_STATUS_CODE)
           OR ((recinfo.INVENTORY_ITEM_STATUS_CODE is null) AND (P_Item_Rec.INVENTORY_ITEM_STATUS_CODE is null)))
      AND ((recinfo.INVENTORY_PLANNING_CODE = P_Item_Rec.INVENTORY_PLANNING_CODE)
           OR ((recinfo.INVENTORY_PLANNING_CODE is null) AND (P_Item_Rec.INVENTORY_PLANNING_CODE is null)))
      AND ((recinfo.PLANNER_CODE = P_Item_Rec.PLANNER_CODE)
           OR ((recinfo.PLANNER_CODE is null) AND (P_Item_Rec.PLANNER_CODE is null)))
      AND ((recinfo.PLANNING_MAKE_BUY_CODE = P_Item_Rec.PLANNING_MAKE_BUY_CODE)
           OR ((recinfo.PLANNING_MAKE_BUY_CODE is null) AND (P_Item_Rec.PLANNING_MAKE_BUY_CODE is null)))
      AND ((recinfo.FIXED_LOT_MULTIPLIER = P_Item_Rec.FIXED_LOT_MULTIPLIER)
           OR ((recinfo.FIXED_LOT_MULTIPLIER is null) AND (P_Item_Rec.FIXED_LOT_MULTIPLIER is null)))
      AND ((recinfo.ROUNDING_CONTROL_TYPE = P_Item_Rec.ROUNDING_CONTROL_TYPE)
           OR ((recinfo.ROUNDING_CONTROL_TYPE is null) AND (P_Item_Rec.ROUNDING_CONTROL_TYPE is null)))
      AND ((recinfo.CARRYING_COST = P_Item_Rec.CARRYING_COST)
           OR ((recinfo.CARRYING_COST is null) AND (P_Item_Rec.CARRYING_COST is null)))
      AND ((recinfo.POSTPROCESSING_LEAD_TIME = P_Item_Rec.POSTPROCESSING_LEAD_TIME)
           OR ((recinfo.POSTPROCESSING_LEAD_TIME is null) AND (P_Item_Rec.POSTPROCESSING_LEAD_TIME is null)))
      AND ((recinfo.PREPROCESSING_LEAD_TIME = P_Item_Rec.PREPROCESSING_LEAD_TIME)
           OR ((recinfo.PREPROCESSING_LEAD_TIME is null) AND (P_Item_Rec.PREPROCESSING_LEAD_TIME is null)))
      AND (recinfo.SUMMARY_FLAG = P_Item_Rec.SUMMARY_FLAG)
      AND (recinfo.ENABLED_FLAG = P_Item_Rec.ENABLED_FLAG)
      AND ((recinfo.START_DATE_ACTIVE = P_Item_Rec.START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (P_Item_Rec.START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = P_Item_Rec.END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (P_Item_Rec.END_DATE_ACTIVE is null)))
      AND ((recinfo.BUYER_ID = P_Item_Rec.BUYER_ID)
           OR ((recinfo.BUYER_ID is null) AND (P_Item_Rec.BUYER_ID is null)))
      AND ((recinfo.ACCOUNTING_RULE_ID = P_Item_Rec.ACCOUNTING_RULE_ID)
           OR ((recinfo.ACCOUNTING_RULE_ID is null) AND (P_Item_Rec.ACCOUNTING_RULE_ID is null)))
      AND ((recinfo.INVOICING_RULE_ID = P_Item_Rec.INVOICING_RULE_ID)
           OR ((recinfo.INVOICING_RULE_ID is null) AND (P_Item_Rec.INVOICING_RULE_ID is null)))
      AND ( (recinfo.OVER_SHIPMENT_TOLERANCE = P_Item_Rec.OVER_SHIPMENT_TOLERANCE)
           OR ((recinfo.OVER_SHIPMENT_TOLERANCE is null) AND (P_Item_Rec.OVER_SHIPMENT_TOLERANCE is null)) )
      AND ( (recinfo.UNDER_SHIPMENT_TOLERANCE = P_Item_Rec.UNDER_SHIPMENT_TOLERANCE)
           OR ((recinfo.UNDER_SHIPMENT_TOLERANCE is null) AND (P_Item_Rec.UNDER_SHIPMENT_TOLERANCE is null)) )
      AND ( (recinfo.OVER_RETURN_TOLERANCE = P_Item_Rec.OVER_RETURN_TOLERANCE)
           OR ((recinfo.OVER_RETURN_TOLERANCE is null) AND (P_Item_Rec.OVER_RETURN_TOLERANCE is null)) )
      AND ( (recinfo.UNDER_RETURN_TOLERANCE = P_Item_Rec.UNDER_RETURN_TOLERANCE)
           OR ((recinfo.UNDER_RETURN_TOLERANCE is null) AND (P_Item_Rec.UNDER_RETURN_TOLERANCE is null)) )
      AND ( (recinfo.EQUIPMENT_TYPE = P_Item_Rec.EQUIPMENT_TYPE)
           OR ((recinfo.EQUIPMENT_TYPE is null) AND (P_Item_Rec.EQUIPMENT_TYPE is null)) )
      AND ( (recinfo.RECOVERED_PART_DISP_CODE = P_Item_Rec.RECOVERED_PART_DISP_CODE)
           OR ((recinfo.RECOVERED_PART_DISP_CODE is null) AND (P_Item_Rec.RECOVERED_PART_DISP_CODE is null)) )
      AND ( (recinfo.DEFECT_TRACKING_ON_FLAG = P_Item_Rec.DEFECT_TRACKING_ON_FLAG)
           OR ((recinfo.DEFECT_TRACKING_ON_FLAG is null) AND (P_Item_Rec.DEFECT_TRACKING_ON_FLAG is null)) )
      AND ( (recinfo.EVENT_FLAG = P_Item_Rec.EVENT_FLAG)
           OR ((recinfo.EVENT_FLAG is null) AND (P_Item_Rec.EVENT_FLAG is null)) )
      AND ( (recinfo.ELECTRONIC_FLAG = P_Item_Rec.ELECTRONIC_FLAG)
           OR ((recinfo.ELECTRONIC_FLAG is null) AND (P_Item_Rec.ELECTRONIC_FLAG is null)) )
      AND ( (recinfo.DOWNLOADABLE_FLAG = P_Item_Rec.DOWNLOADABLE_FLAG)
           OR ((recinfo.DOWNLOADABLE_FLAG is null) AND (P_Item_Rec.DOWNLOADABLE_FLAG is null)) )
      AND ( (recinfo.VOL_DISCOUNT_EXEMPT_FLAG = P_Item_Rec.VOL_DISCOUNT_EXEMPT_FLAG)
           OR ((recinfo.VOL_DISCOUNT_EXEMPT_FLAG is null) AND (P_Item_Rec.VOL_DISCOUNT_EXEMPT_FLAG is null)) )
      AND ( (recinfo.COUPON_EXEMPT_FLAG = P_Item_Rec.COUPON_EXEMPT_FLAG)
           OR ((recinfo.COUPON_EXEMPT_FLAG is null) AND (P_Item_Rec.COUPON_EXEMPT_FLAG is null)) )
      AND ( (recinfo.COMMS_NL_TRACKABLE_FLAG = P_Item_Rec.COMMS_NL_TRACKABLE_FLAG)
           OR ((recinfo.COMMS_NL_TRACKABLE_FLAG is null) AND (P_Item_Rec.COMMS_NL_TRACKABLE_FLAG is null)) )
      AND ( (recinfo.ASSET_CREATION_CODE = P_Item_Rec.ASSET_CREATION_CODE)
           OR ((recinfo.ASSET_CREATION_CODE is null) AND (P_Item_Rec.ASSET_CREATION_CODE is null)) )
      AND ( (recinfo.COMMS_ACTIVATION_REQD_FLAG = P_Item_Rec.COMMS_ACTIVATION_REQD_FLAG)
           OR ((recinfo.COMMS_ACTIVATION_REQD_FLAG is null) AND (P_Item_Rec.COMMS_ACTIVATION_REQD_FLAG is null)) )
      AND ( (recinfo.ORDERABLE_ON_WEB_FLAG = P_Item_Rec.ORDERABLE_ON_WEB_FLAG)
           OR ((recinfo.ORDERABLE_ON_WEB_FLAG is null) AND (P_Item_Rec.ORDERABLE_ON_WEB_FLAG is null)) )
      AND ( (recinfo.BACK_ORDERABLE_FLAG = P_Item_Rec.BACK_ORDERABLE_FLAG)
           OR ((recinfo.BACK_ORDERABLE_FLAG is null) AND (P_Item_Rec.BACK_ORDERABLE_FLAG is null)) )
      AND ( (recinfo.WEB_STATUS = P_Item_Rec.WEB_STATUS)
           OR ((recinfo.WEB_STATUS is null) AND (P_Item_Rec.WEB_STATUS is null)) )
      AND ( (recinfo.INDIVISIBLE_FLAG = P_Item_Rec.INDIVISIBLE_FLAG)
           OR ((recinfo.INDIVISIBLE_FLAG is null) AND (P_Item_Rec.INDIVISIBLE_FLAG is null)) )
      AND ( (recinfo.DIMENSION_UOM_CODE = P_Item_Rec.DIMENSION_UOM_CODE)
           OR ((recinfo.DIMENSION_UOM_CODE is null) AND (P_Item_Rec.DIMENSION_UOM_CODE is null)) )
      AND ( (recinfo.UNIT_LENGTH = P_Item_Rec.UNIT_LENGTH)
           OR ((recinfo.UNIT_LENGTH is null) AND (P_Item_Rec.UNIT_LENGTH is null)) )
      AND ( (recinfo.UNIT_WIDTH = P_Item_Rec.UNIT_WIDTH)
           OR ((recinfo.UNIT_WIDTH is null) AND (P_Item_Rec.UNIT_WIDTH is null)) )
      AND ( (recinfo.UNIT_HEIGHT = P_Item_Rec.UNIT_HEIGHT)
           OR ((recinfo.UNIT_HEIGHT is null) AND (P_Item_Rec.UNIT_HEIGHT is null)) )
      AND ( (recinfo.BULK_PICKED_FLAG = P_Item_Rec.BULK_PICKED_FLAG)
           OR ((recinfo.BULK_PICKED_FLAG is null) AND (P_Item_Rec.BULK_PICKED_FLAG is null)) )
      AND ( (recinfo.LOT_STATUS_ENABLED = P_Item_Rec.LOT_STATUS_ENABLED)
           OR ((recinfo.LOT_STATUS_ENABLED is null) AND (P_Item_Rec.LOT_STATUS_ENABLED is null)) )
      AND ( (recinfo.DEFAULT_LOT_STATUS_ID = P_Item_Rec.DEFAULT_LOT_STATUS_ID)
           OR ((recinfo.DEFAULT_LOT_STATUS_ID is null) AND (P_Item_Rec.DEFAULT_LOT_STATUS_ID is null)) )
      AND ( (recinfo.SERIAL_STATUS_ENABLED = P_Item_Rec.SERIAL_STATUS_ENABLED)
           OR ((recinfo.SERIAL_STATUS_ENABLED is null) AND (P_Item_Rec.SERIAL_STATUS_ENABLED is null)) )
      AND ( (recinfo.DEFAULT_SERIAL_STATUS_ID = P_Item_Rec.DEFAULT_SERIAL_STATUS_ID)
           OR ((recinfo.DEFAULT_SERIAL_STATUS_ID is null) AND (P_Item_Rec.DEFAULT_SERIAL_STATUS_ID is null)) )
      AND ( (recinfo.LOT_SPLIT_ENABLED = P_Item_Rec.LOT_SPLIT_ENABLED)
           OR ((recinfo.LOT_SPLIT_ENABLED is null) AND (P_Item_Rec.LOT_SPLIT_ENABLED is null)) )
      AND ( (recinfo.LOT_MERGE_ENABLED = P_Item_Rec.LOT_MERGE_ENABLED)
           OR ((recinfo.LOT_MERGE_ENABLED is null) AND (P_Item_Rec.LOT_MERGE_ENABLED is null)) )
      AND ( (recinfo.INVENTORY_CARRY_PENALTY = P_Item_Rec.INVENTORY_CARRY_PENALTY)
           OR ((recinfo.INVENTORY_CARRY_PENALTY is null) AND (P_Item_Rec.INVENTORY_CARRY_PENALTY is null)) )
      AND ( (recinfo.OPERATION_SLACK_PENALTY = P_Item_Rec.OPERATION_SLACK_PENALTY)
           OR ((recinfo.OPERATION_SLACK_PENALTY is null) AND (P_Item_Rec.OPERATION_SLACK_PENALTY is null)) )
      AND ( (recinfo.FINANCING_ALLOWED_FLAG = P_Item_Rec.FINANCING_ALLOWED_FLAG)
           OR ((recinfo.FINANCING_ALLOWED_FLAG is null) AND (P_Item_Rec.FINANCING_ALLOWED_FLAG is null)) )
      AND ( (recinfo.EAM_ITEM_TYPE = P_Item_Rec.EAM_ITEM_TYPE)
           OR ((recinfo.EAM_ITEM_TYPE is null) AND (P_Item_Rec.EAM_ITEM_TYPE is null)) )
      AND ( (recinfo.EAM_ACTIVITY_TYPE_CODE = P_Item_Rec.EAM_ACTIVITY_TYPE_CODE)
           OR ((recinfo.EAM_ACTIVITY_TYPE_CODE is null) AND (P_Item_Rec.EAM_ACTIVITY_TYPE_CODE is null)) )
      AND ( (recinfo.EAM_ACTIVITY_CAUSE_CODE = P_Item_Rec.EAM_ACTIVITY_CAUSE_CODE)
           OR ((recinfo.EAM_ACTIVITY_CAUSE_CODE is null) AND (P_Item_Rec.EAM_ACTIVITY_CAUSE_CODE is null)) )
      AND ( (recinfo.EAM_ACT_NOTIFICATION_FLAG = P_Item_Rec.EAM_ACT_NOTIFICATION_FLAG)
           OR ((recinfo.EAM_ACT_NOTIFICATION_FLAG is null) AND (P_Item_Rec.EAM_ACT_NOTIFICATION_FLAG is null)) )
      AND ( (recinfo.EAM_ACT_SHUTDOWN_STATUS = P_Item_Rec.EAM_ACT_SHUTDOWN_STATUS)
           OR ((recinfo.EAM_ACT_SHUTDOWN_STATUS is null) AND (P_Item_Rec.EAM_ACT_SHUTDOWN_STATUS is null)) )
      AND ( (recinfo.DUAL_UOM_CONTROL = P_Item_Rec.DUAL_UOM_CONTROL)
           OR ((recinfo.DUAL_UOM_CONTROL is null) AND (P_Item_Rec.DUAL_UOM_CONTROL is null)) )
      AND ( (recinfo.SECONDARY_UOM_CODE = P_Item_Rec.SECONDARY_UOM_CODE)
           OR ((recinfo.SECONDARY_UOM_CODE is null) AND (P_Item_Rec.SECONDARY_UOM_CODE is null)) )
      AND ( (recinfo.DUAL_UOM_DEVIATION_HIGH = P_Item_Rec.DUAL_UOM_DEVIATION_HIGH)
           OR ((recinfo.DUAL_UOM_DEVIATION_HIGH is null) AND (P_Item_Rec.DUAL_UOM_DEVIATION_HIGH is null)) )
      AND ( (recinfo.DUAL_UOM_DEVIATION_LOW = P_Item_Rec.DUAL_UOM_DEVIATION_LOW)
           OR ((recinfo.DUAL_UOM_DEVIATION_LOW is null) AND (P_Item_Rec.DUAL_UOM_DEVIATION_LOW is null)) )
      AND ( (recinfo.CONTRACT_ITEM_TYPE_CODE = P_Item_Rec.CONTRACT_ITEM_TYPE_CODE)
           OR ((recinfo.CONTRACT_ITEM_TYPE_CODE is null) AND (P_Item_Rec.CONTRACT_ITEM_TYPE_CODE is null)) )
/*      AND ( (recinfo.SUBSCRIPTION_DEPEND_FLAG = P_Item_Rec.SUBSCRIPTION_DEPEND_FLAG)
           OR ((recinfo.SUBSCRIPTION_DEPEND_FLAG is null) AND (P_Item_Rec.SUBSCRIPTION_DEPEND_FLAG is null)) )
*/      AND ( (recinfo.SERV_REQ_ENABLED_CODE = P_Item_Rec.SERV_REQ_ENABLED_CODE)
           OR ( (recinfo.SERV_REQ_ENABLED_CODE is null) AND (P_Item_Rec.SERV_REQ_ENABLED_CODE is null) ) )
      AND ( (recinfo.SERV_BILLING_ENABLED_FLAG = P_Item_Rec.SERV_BILLING_ENABLED_FLAG)
           OR ( (recinfo.SERV_BILLING_ENABLED_FLAG is null) AND (P_Item_Rec.SERV_BILLING_ENABLED_FLAG is null) ) )
/*      AND ( (recinfo.SERV_IMPORTANCE_LEVEL = P_Item_Rec.SERV_IMPORTANCE_LEVEL)
           OR ( (recinfo.SERV_IMPORTANCE_LEVEL is null) AND (P_Item_Rec.SERV_IMPORTANCE_LEVEL is null) ) )
*/      AND ( (recinfo.PLANNED_INV_POINT_FLAG = P_Item_Rec.PLANNED_INV_POINT_FLAG)
           OR ( (recinfo.PLANNED_INV_POINT_FLAG is null) AND (P_Item_Rec.PLANNED_INV_POINT_FLAG is null) ) )
      AND ( (recinfo.LOT_TRANSLATE_ENABLED = P_Item_Rec.LOT_TRANSLATE_ENABLED)
           OR ( (recinfo.LOT_TRANSLATE_ENABLED IS NULL) AND (P_Item_Rec.LOT_TRANSLATE_ENABLED IS NULL) ) )
      AND ( recinfo.DEFAULT_SO_SOURCE_TYPE = P_Item_Rec.DEFAULT_SO_SOURCE_TYPE )
      AND ( recinfo.CREATE_SUPPLY_FLAG = P_Item_Rec.CREATE_SUPPLY_FLAG )
      AND ( (recinfo.SUBSTITUTION_WINDOW_CODE = P_Item_Rec.SUBSTITUTION_WINDOW_CODE)
           OR ( (recinfo.SUBSTITUTION_WINDOW_CODE IS NULL) AND (P_Item_Rec.SUBSTITUTION_WINDOW_CODE IS NULL) ) )
      AND ( (recinfo.SUBSTITUTION_WINDOW_DAYS = P_Item_Rec.SUBSTITUTION_WINDOW_DAYS)
           OR ( (recinfo.SUBSTITUTION_WINDOW_DAYS IS NULL) AND (P_Item_Rec.SUBSTITUTION_WINDOW_DAYS IS NULL) ) )
      AND ( (recinfo.IB_ITEM_INSTANCE_CLASS = P_Item_Rec.IB_ITEM_INSTANCE_CLASS)
           OR ( (recinfo.IB_ITEM_INSTANCE_CLASS IS NULL) AND (P_Item_Rec.IB_ITEM_INSTANCE_CLASS IS NULL) ) )
      AND ( (recinfo.CONFIG_MODEL_TYPE = P_Item_Rec.CONFIG_MODEL_TYPE)
           OR ( (recinfo.CONFIG_MODEL_TYPE IS NULL) AND (P_Item_Rec.CONFIG_MODEL_TYPE IS NULL) ) )
  --Added as part of 11.5.9 Enh
      AND ( (recinfo.LOT_SUBSTITUTION_ENABLED = P_Item_Rec.LOT_SUBSTITUTION_ENABLED)
           OR ( (recinfo.LOT_SUBSTITUTION_ENABLED IS NULL) AND (P_Item_Rec.LOT_SUBSTITUTION_ENABLED IS NULL) ) )
      AND ( (recinfo.MINIMUM_LICENSE_QUANTITY = P_Item_Rec.MINIMUM_LICENSE_QUANTITY)
           OR ( (recinfo.MINIMUM_LICENSE_QUANTITY IS NULL) AND (P_Item_Rec.MINIMUM_LICENSE_QUANTITY IS NULL) ) )
      AND ( (recinfo.EAM_ACTIVITY_SOURCE_CODE = P_Item_Rec.EAM_ACTIVITY_SOURCE_CODE)
           OR ( (recinfo.EAM_ACTIVITY_SOURCE_CODE IS NULL) AND (P_Item_Rec.EAM_ACTIVITY_SOURCE_CODE IS NULL) ) )
  --Added as part of 11.5.10 Enh
      AND ( (recinfo.TRACKING_QUANTITY_IND = P_Item_Rec.TRACKING_QUANTITY_IND)
           OR ( (recinfo.TRACKING_QUANTITY_IND IS NULL) AND (P_Item_Rec.TRACKING_QUANTITY_IND IS NULL) ) )
      AND ( (recinfo.ONT_PRICING_QTY_SOURCE = P_Item_Rec.ONT_PRICING_QTY_SOURCE)
           OR ( (recinfo.ONT_PRICING_QTY_SOURCE IS NULL) AND (P_Item_Rec.ONT_PRICING_QTY_SOURCE IS NULL) ) )
      AND ( (recinfo.SECONDARY_DEFAULT_IND = P_Item_Rec.SECONDARY_DEFAULT_IND)
           OR ( (recinfo.SECONDARY_DEFAULT_IND IS NULL) AND (P_Item_Rec.SECONDARY_DEFAULT_IND IS NULL) ) )
      AND ( (recinfo.CONFIG_ORGS = P_Item_Rec.CONFIG_ORGS)
           OR ( (recinfo.CONFIG_ORGS IS NULL) AND (P_Item_Rec.CONFIG_ORGS IS NULL) ) )
      AND ( (recinfo.CONFIG_MATCH = P_Item_Rec.CONFIG_MATCH)
           OR ( (recinfo.CONFIG_MATCH IS NULL) AND (P_Item_Rec.CONFIG_MATCH IS NULL) ) )
      AND ((recinfo.SEGMENT1 = P_Item_Rec.SEGMENT1)
           OR ((recinfo.SEGMENT1 is null) AND (P_Item_Rec.SEGMENT1 is null)))
      AND ((recinfo.SEGMENT2 = P_Item_Rec.SEGMENT2)
           OR ((recinfo.SEGMENT2 is null) AND (P_Item_Rec.SEGMENT2 is null)))
      AND ((recinfo.SEGMENT3 = P_Item_Rec.SEGMENT3)
           OR ((recinfo.SEGMENT3 is null) AND (P_Item_Rec.SEGMENT3 is null)))
      AND ((recinfo.SEGMENT4 = P_Item_Rec.SEGMENT4)
           OR ((recinfo.SEGMENT4 is null) AND (P_Item_Rec.SEGMENT4 is null)))
      AND ((recinfo.SEGMENT5 = P_Item_Rec.SEGMENT5)
           OR ((recinfo.SEGMENT5 is null) AND (P_Item_Rec.SEGMENT5 is null)))
      AND ((recinfo.SEGMENT6 = P_Item_Rec.SEGMENT6)
           OR ((recinfo.SEGMENT6 is null) AND (P_Item_Rec.SEGMENT6 is null)))
      AND ((recinfo.SEGMENT7 = P_Item_Rec.SEGMENT7)
           OR ((recinfo.SEGMENT7 is null) AND (P_Item_Rec.SEGMENT7 is null)))
      AND ((recinfo.SEGMENT8 = P_Item_Rec.SEGMENT8)
           OR ((recinfo.SEGMENT8 is null) AND (P_Item_Rec.SEGMENT8 is null)))
      AND ((recinfo.SEGMENT9 = P_Item_Rec.SEGMENT9)
           OR ((recinfo.SEGMENT9 is null) AND (P_Item_Rec.SEGMENT9 is null)))
      AND ((recinfo.SEGMENT10 = P_Item_Rec.SEGMENT10)
           OR ((recinfo.SEGMENT10 is null) AND (P_Item_Rec.SEGMENT10 is null)))
      AND ((recinfo.SEGMENT11 = P_Item_Rec.SEGMENT11)
           OR ((recinfo.SEGMENT11 is null) AND (P_Item_Rec.SEGMENT11 is null)))
      AND ((recinfo.SEGMENT12 = P_Item_Rec.SEGMENT12)
           OR ((recinfo.SEGMENT12 is null) AND (P_Item_Rec.SEGMENT12 is null)))
      AND ((recinfo.SEGMENT13 = P_Item_Rec.SEGMENT13)
           OR ((recinfo.SEGMENT13 is null) AND (P_Item_Rec.SEGMENT13 is null)))
      AND ((recinfo.SEGMENT14 = P_Item_Rec.SEGMENT14)
           OR ((recinfo.SEGMENT14 is null) AND (P_Item_Rec.SEGMENT14 is null)))
      AND ((recinfo.SEGMENT15 = P_Item_Rec.SEGMENT15)
           OR ((recinfo.SEGMENT15 is null) AND (P_Item_Rec.SEGMENT15 is null)))
      AND ((recinfo.SEGMENT16 = P_Item_Rec.SEGMENT16)
          OR ((recinfo.SEGMENT16 is null) AND (P_Item_Rec.SEGMENT16 is null)))
      AND ((recinfo.SEGMENT17 = P_Item_Rec.SEGMENT17)
          OR ((recinfo.SEGMENT17 is null) AND (P_Item_Rec.SEGMENT17 is null)))
      AND ((recinfo.SEGMENT18 = P_Item_Rec.SEGMENT18)
          OR ((recinfo.SEGMENT18 is null) AND (P_Item_Rec.SEGMENT18 is null)))
      AND ((recinfo.SEGMENT19 = P_Item_Rec.SEGMENT19)
          OR ((recinfo.SEGMENT19 is null) AND (P_Item_Rec.SEGMENT19 is null)))
      AND ((recinfo.SEGMENT20 = P_Item_Rec.SEGMENT20)
          OR ((recinfo.SEGMENT20 is null) AND (P_Item_Rec.SEGMENT20 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = P_Item_Rec.ATTRIBUTE_CATEGORY)
          OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (P_Item_Rec.ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = P_Item_Rec.ATTRIBUTE1)
          OR ((recinfo.ATTRIBUTE1 is null) AND (P_Item_Rec.ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_Item_Rec.ATTRIBUTE2)
          OR ((recinfo.ATTRIBUTE2 is null) AND (P_Item_Rec.ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_Item_Rec.ATTRIBUTE3)
          OR ((recinfo.ATTRIBUTE3 is null) AND (P_Item_Rec.ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_Item_Rec.ATTRIBUTE4)
          OR ((recinfo.ATTRIBUTE4 is null) AND (P_Item_Rec.ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_Item_Rec.ATTRIBUTE5)
          OR ((recinfo.ATTRIBUTE5 is null) AND (P_Item_Rec.ATTRIBUTE5 is null))))
/* Start Bug 3713912 */ --Added for R12
AND ((recinfo.LOT_DIVISIBLE_FLAG			 = P_Item_Rec.LOT_DIVISIBLE_FLAG			)
 OR ((recinfo.LOT_DIVISIBLE_FLAG			 is null) AND (P_Item_Rec.LOT_DIVISIBLE_FLAG		 is null)))
AND ((recinfo.GRADE_CONTROL_FLAG			 = P_Item_Rec.GRADE_CONTROL_FLAG			)
 OR ((recinfo.GRADE_CONTROL_FLAG			 is null) AND (P_Item_Rec.GRADE_CONTROL_FLAG		 is null)))
AND ((recinfo.DEFAULT_GRADE				 = P_Item_Rec.DEFAULT_GRADE				)
 OR ((recinfo.DEFAULT_GRADE				 is null) AND (P_Item_Rec.DEFAULT_GRADE			 is null)))
AND ((recinfo.CHILD_LOT_FLAG			 = P_Item_Rec.CHILD_LOT_FLAG			)
 OR ((recinfo.CHILD_LOT_FLAG			 is null) AND (P_Item_Rec.CHILD_LOT_FLAG		 is null)))
AND ((recinfo.PARENT_CHILD_GENERATION_FLAG		 = P_Item_Rec.PARENT_CHILD_GENERATION_FLAG		)
 OR ((recinfo.PARENT_CHILD_GENERATION_FLAG		 is null) AND (P_Item_Rec.PARENT_CHILD_GENERATION_FLAG	 is null)))
AND ((recinfo.CHILD_LOT_PREFIX			 = P_Item_Rec.CHILD_LOT_PREFIX			)
 OR ((recinfo.CHILD_LOT_PREFIX			 is null) AND (P_Item_Rec.CHILD_LOT_PREFIX		 is null)))
AND ((recinfo.CHILD_LOT_STARTING_NUMBER            	 = P_Item_Rec.CHILD_LOT_STARTING_NUMBER            	)
 OR ((recinfo.CHILD_LOT_STARTING_NUMBER            	 is null) AND (P_Item_Rec.CHILD_LOT_STARTING_NUMBER             is null)))
AND ((recinfo.CHILD_LOT_VALIDATION_FLAG		 = P_Item_Rec.CHILD_LOT_VALIDATION_FLAG		)
 OR ((recinfo.CHILD_LOT_VALIDATION_FLAG		 is null) AND (P_Item_Rec.CHILD_LOT_VALIDATION_FLAG	 is null)))
AND ((recinfo.COPY_LOT_ATTRIBUTE_FLAG		 = P_Item_Rec.COPY_LOT_ATTRIBUTE_FLAG		)
 OR ((recinfo.COPY_LOT_ATTRIBUTE_FLAG		 is null) AND (P_Item_Rec.COPY_LOT_ATTRIBUTE_FLAG	 is null)))
AND ((recinfo.RECIPE_ENABLED_FLAG			 = P_Item_Rec.RECIPE_ENABLED_FLAG			)
 OR ((recinfo.RECIPE_ENABLED_FLAG			 is null) AND (P_Item_Rec.RECIPE_ENABLED_FLAG		 is null)))
AND ((recinfo.PROCESS_QUALITY_ENABLED_FLAG		 = P_Item_Rec.PROCESS_QUALITY_ENABLED_FLAG		)
 OR ((recinfo.PROCESS_QUALITY_ENABLED_FLAG		 is null) AND (P_Item_Rec.PROCESS_QUALITY_ENABLED_FLAG	 is null)))
AND ((recinfo.PROCESS_EXECUTION_ENABLED_FLAG 	 = P_Item_Rec.PROCESS_EXECUTION_ENABLED_FLAG 	)
 OR ((recinfo.PROCESS_EXECUTION_ENABLED_FLAG 	 is null) AND (P_Item_Rec.PROCESS_EXECUTION_ENABLED_FLAG  is null)))
AND ((recinfo.PROCESS_COSTING_ENABLED_FLAG		 = P_Item_Rec.PROCESS_COSTING_ENABLED_FLAG		)
 OR ((recinfo.PROCESS_COSTING_ENABLED_FLAG		 is null) AND (P_Item_Rec.PROCESS_COSTING_ENABLED_FLAG	 is null)))
AND ((recinfo.PROCESS_SUPPLY_SUBINVENTORY		 = P_Item_Rec.PROCESS_SUPPLY_SUBINVENTORY		)
 OR ((recinfo.PROCESS_SUPPLY_SUBINVENTORY		 is null) AND (P_Item_Rec.PROCESS_SUPPLY_SUBINVENTORY	 is null)))
AND ((recinfo.PROCESS_SUPPLY_LOCATOR_ID				 = P_Item_Rec.PROCESS_SUPPLY_LOCATOR_ID				)
 OR ((recinfo.PROCESS_SUPPLY_LOCATOR_ID				 is null) AND (P_Item_Rec.PROCESS_SUPPLY_LOCATOR_ID			 is null)))
AND ((recinfo.PROCESS_YIELD_SUBINVENTORY		 = P_Item_Rec.PROCESS_YIELD_SUBINVENTORY		)
OR ((recinfo.PROCESS_YIELD_SUBINVENTORY		 is null) AND (P_Item_Rec.PROCESS_YIELD_SUBINVENTORY	 is null)))
AND ((recinfo.PROCESS_YIELD_LOCATOR_ID				 = P_Item_Rec.PROCESS_YIELD_LOCATOR_ID				)
 OR ((recinfo.PROCESS_YIELD_LOCATOR_ID				 is null) AND (P_Item_Rec.PROCESS_YIELD_LOCATOR_ID			 is null)))
AND ((recinfo.HAZARDOUS_MATERIAL_FLAG		 = P_Item_Rec.HAZARDOUS_MATERIAL_FLAG		)
 OR ((recinfo.HAZARDOUS_MATERIAL_FLAG		 is null) AND (P_Item_Rec.HAZARDOUS_MATERIAL_FLAG	 is null)))
AND ((recinfo.CAS_NUMBER				 = P_Item_Rec.CAS_NUMBER				)
 OR ((recinfo.CAS_NUMBER				 is null) AND (P_Item_Rec.CAS_NUMBER			 is null)))
AND ((recinfo.RETEST_INTERVAL		            	 = P_Item_Rec.RETEST_INTERVAL		            	)
 OR ((recinfo.RETEST_INTERVAL		            	 is null) AND (P_Item_Rec.RETEST_INTERVAL		             is null)))
AND ((recinfo.EXPIRATION_ACTION_INTERVAL	            	 = P_Item_Rec.EXPIRATION_ACTION_INTERVAL	            	)
 OR ((recinfo.EXPIRATION_ACTION_INTERVAL	            	 is null) AND (P_Item_Rec.EXPIRATION_ACTION_INTERVAL	             is null)))
AND ((recinfo.EXPIRATION_ACTION_CODE		 = P_Item_Rec.EXPIRATION_ACTION_CODE		)
 OR ((recinfo.EXPIRATION_ACTION_CODE		 is null) AND (P_Item_Rec.EXPIRATION_ACTION_CODE	 is null)))
AND ((recinfo.MATURITY_DAYS			         	 = P_Item_Rec.MATURITY_DAYS			         	)
 OR ((recinfo.MATURITY_DAYS			         	 is null) AND (P_Item_Rec.MATURITY_DAYS			          is null)))
AND ((recinfo.HOLD_DAYS			 	 = P_Item_Rec.HOLD_DAYS			 	)
 OR ((recinfo.HOLD_DAYS			 	 is null) AND (P_Item_Rec.HOLD_DAYS			  is null)))
AND ((recinfo.ATTRIBUTE16		  		 = P_Item_Rec.ATTRIBUTE16		  		)
 OR ((recinfo.ATTRIBUTE16		  		 is null) AND (P_Item_Rec.ATTRIBUTE16		  	 is null)))
AND ((recinfo.ATTRIBUTE17		  		 = P_Item_Rec.ATTRIBUTE17		  		)
 OR ((recinfo.ATTRIBUTE17		  		 is null) AND (P_Item_Rec.ATTRIBUTE17		  	 is null)))
AND ((recinfo.ATTRIBUTE18	  			 = P_Item_Rec.ATTRIBUTE18	  			)
 OR ((recinfo.ATTRIBUTE18	  			 is null) AND (P_Item_Rec.ATTRIBUTE18	  		 is null)))
AND ((recinfo.ATTRIBUTE19	  			 = P_Item_Rec.ATTRIBUTE19	  			)
 OR ((recinfo.ATTRIBUTE19	  			 is null) AND (P_Item_Rec.ATTRIBUTE19	  		 is null)))
AND ((recinfo.ATTRIBUTE20		  		 = P_Item_Rec.ATTRIBUTE20		  		)
 OR ((recinfo.ATTRIBUTE20		  		 is null) AND (P_Item_Rec.ATTRIBUTE20		  	 is null)))
AND ((recinfo.ATTRIBUTE21		  		 = P_Item_Rec.ATTRIBUTE21		  		)
 OR ((recinfo.ATTRIBUTE21		  		 is null) AND (P_Item_Rec.ATTRIBUTE21		  	 is null)))
AND ((recinfo.ATTRIBUTE22	  			 = P_Item_Rec.ATTRIBUTE22	  			)
 OR ((recinfo.ATTRIBUTE22	  			 is null) AND (P_Item_Rec.ATTRIBUTE22	  		 is null)))
AND ((recinfo.ATTRIBUTE23	  			 = P_Item_Rec.ATTRIBUTE23	  			)
 OR ((recinfo.ATTRIBUTE23	  			 is null) AND (P_Item_Rec.ATTRIBUTE23	  		 is null)))
AND ((recinfo.ATTRIBUTE24	  			 = P_Item_Rec.ATTRIBUTE24	  			)
 OR ((recinfo.ATTRIBUTE24	  			 is null) AND (P_Item_Rec.ATTRIBUTE24	  		 is null)))
AND ((recinfo.ATTRIBUTE25		  		 = P_Item_Rec.ATTRIBUTE25		  		)
 OR ((recinfo.ATTRIBUTE25		  		 is null) AND (P_Item_Rec.ATTRIBUTE25		  	 is null)))
AND ((recinfo.ATTRIBUTE26		  		 = P_Item_Rec.ATTRIBUTE26		  		)
 OR ((recinfo.ATTRIBUTE26		  		 is null) AND (P_Item_Rec.ATTRIBUTE26		  	 is null)))
AND ((recinfo.ATTRIBUTE27	  			 = P_Item_Rec.ATTRIBUTE27	  			)
 OR ((recinfo.ATTRIBUTE27	  			 is null) AND (P_Item_Rec.ATTRIBUTE27	  		 is null)))
AND ((recinfo.ATTRIBUTE28	  			 = P_Item_Rec.ATTRIBUTE28	  			)
 OR ((recinfo.ATTRIBUTE28	  			 is null) AND (P_Item_Rec.ATTRIBUTE28	  		 is null)))
AND ((recinfo.ATTRIBUTE29				 = P_Item_Rec.ATTRIBUTE29				)
 OR ((recinfo.ATTRIBUTE29				 is null) AND (P_Item_Rec.ATTRIBUTE29			 is null)))
AND ((recinfo.ATTRIBUTE30		  		 = P_Item_Rec.ATTRIBUTE30		  		)
 OR ((recinfo.ATTRIBUTE30		  		 is null) AND (P_Item_Rec.ATTRIBUTE30		  	 is null)))
/* End Bug 3713912 */
    AND ((recinfo.CHARGE_PERIODICITY_CODE = p_Item_Rec.CHARGE_PERIODICITY_CODE)
           OR (recinfo.CHARGE_PERIODICITY_CODE IS NULL AND  p_Item_Rec.CHARGE_PERIODICITY_CODE IS NULL))
    AND ((recinfo.REPAIR_LEADTIME = p_Item_Rec.REPAIR_LEADTIME)
           OR(recinfo.REPAIR_LEADTIME IS NULL AND  p_Item_Rec.REPAIR_LEADTIME IS NULL))
    AND ((recinfo.REPAIR_YIELD = p_Item_Rec.REPAIR_YIELD)
           OR(recinfo.REPAIR_YIELD IS NULL AND  p_Item_Rec.REPAIR_YIELD IS NULL))
    AND ((recinfo.PREPOSITION_POINT = p_Item_Rec.PREPOSITION_POINT)
           OR(recinfo.PREPOSITION_POINT IS NULL AND  p_Item_Rec.PREPOSITION_POINT IS NULL))
    AND ((recinfo.REPAIR_PROGRAM = p_Item_Rec.REPAIR_PROGRAM)
           OR(recinfo.REPAIR_PROGRAM IS NULL AND  p_Item_Rec.REPAIR_PROGRAM IS NULL))
    AND ((recinfo.SUBCONTRACTING_COMPONENT = p_Item_Rec.SUBCONTRACTING_COMPONENT)
           OR(recinfo.SUBCONTRACTING_COMPONENT IS NULL AND  p_Item_Rec.SUBCONTRACTING_COMPONENT IS NULL))
    AND ((recinfo.OUTSOURCED_ASSEMBLY = p_Item_Rec.OUTSOURCED_ASSEMBLY)
           OR(recinfo.OUTSOURCED_ASSEMBLY IS NULL AND  p_Item_Rec.OUTSOURCED_ASSEMBLY IS NULL))
    -- Fix for Bug#6644711
    AND ( (recinfo.DEFAULT_MATERIAL_STATUS_ID = P_Item_Rec.DEFAULT_MATERIAL_STATUS_ID)
           OR ((recinfo.DEFAULT_MATERIAL_STATUS_ID is null) AND (P_Item_Rec.DEFAULT_MATERIAL_STATUS_ID is null)))
     -- Serial_Tagging Enh -- bug 9913552
    AND ( (recinfo.SERIAL_TAGGING_FLAG = P_Item_Rec.SERIAL_TAGGING_FLAG)
           OR ((recinfo.SERIAL_TAGGING_FLAG is null) AND (P_Item_Rec.SERIAL_TAGGING_FLAG is null)) )
   THEN
      NULL;
   ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;


   FOR item_tl IN c_get_item_description
   LOOP
      IF (item_tl.BASELANG = 'Y') THEN
         IF(((item_tl.DESCRIPTION = P_Item_Rec.DESCRIPTION)
              OR ((item_tl.DESCRIPTION is null) AND (P_Item_Rec.DESCRIPTION is null)) )
           AND((item_tl.LONG_DESCRIPTION = P_Item_Rec.LONG_DESCRIPTION)
              OR ((item_tl.LONG_DESCRIPTION is null) AND (P_Item_Rec.LONG_DESCRIPTION is null))))
         THEN
           NULL;
         ELSE
            FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
            Raise FND_API.g_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
   END LOOP;


  IF ( P_Item_rec.organization_id = Get_Master_Org_ID (P_Item_rec.organization_id) ) THEN
     -- Lock organization items
     INV_ITEM_PVT.Lock_Org_Items (
         p_Item_ID         =>  P_Item_Rec.inventory_item_id
     ,   p_Org_ID          =>  P_Item_rec.organization_id
     ,   p_lock_Master     =>  fnd_api.g_TRUE
     ,   p_lock_Orgs       =>  fnd_api.g_TRUE
     ,   x_return_status   =>  l_return_status);

  END IF;

EXCEPTION
   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      IF ( c_item_details%ISOPEN ) THEN
        CLOSE c_item_details;
      END IF;
      IF ( c_get_item_description%ISOPEN ) THEN
        CLOSE c_get_item_description ;
      END IF;
      app_exception.raise_exception;

END Lock_Item;

-- ------------------ DELETE_ROW -------------------

PROCEDURE DELETE_ROW IS
BEGIN
  -- DELETE_ROW cannot be used to delete Item records.
  RAISE_APPLICATION_ERROR (-20000, 'Cannot delete Item using MTL_SYSTEM_ITEMS_PKG.DELETE_ROW');
END DELETE_ROW;

-- ------------------- ADD_LANGUAGE --------------------

PROCEDURE ADD_LANGUAGE IS
BEGIN

/*   DELETE FROM MTL_SYSTEM_ITEMS_TL T
   WHERE  NOT EXISTS ( SELECT NULL
                       FROM   MTL_SYSTEM_ITEMS_B  B
                       WHERE  B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
                       AND    B.ORGANIZATION_ID   = T.ORGANIZATION_ID);

   UPDATE MTL_SYSTEM_ITEMS_TL T
   SET(  DESCRIPTION
      ,  LONG_DESCRIPTION) = (SELECT  ltrim(rtrim(B.DESCRIPTION))
   			           ,  ltrim(rtrim(B.LONG_DESCRIPTION))
		              FROM  MTL_SYSTEM_ITEMS_TL  B
                              WHERE B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
                              AND   B.ORGANIZATION_ID   = T.ORGANIZATION_ID
                              AND   B.LANGUAGE          = T.SOURCE_LANG)
   WHERE(T.INVENTORY_ITEM_ID
      ,  T.ORGANIZATION_ID
      ,  T.LANGUAGE) IN (SELECT  SUBT.INVENTORY_ITEM_ID,
                                 SUBT.ORGANIZATION_ID,
                                 SUBT.LANGUAGE
                         FROM    MTL_SYSTEM_ITEMS_TL  SUBB,
                                 MTL_SYSTEM_ITEMS_TL  SUBT
                         WHERE   SUBB.INVENTORY_ITEM_ID = SUBT.INVENTORY_ITEM_ID
                         AND     SUBB.ORGANIZATION_ID = SUBT.ORGANIZATION_ID
                         AND     SUBB.LANGUAGE = SUBT.SOURCE_LANG
                         AND  (( SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                                or ( SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null )
                                or ( SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null ) )
                         OR   ( SUBB.LONG_DESCRIPTION <> SUBT.LONG_DESCRIPTION
                           or ( SUBB.LONG_DESCRIPTION is null and SUBT.LONG_DESCRIPTION is not null )
                           or ( SUBB.LONG_DESCRIPTION is not null and SUBT.LONG_DESCRIPTION is null ))));

*/
   INSERT INTO MTL_SYSTEM_ITEMS_TL  (
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    DESCRIPTION,
    LONG_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG )
   SELECT
    B.INVENTORY_ITEM_ID,
    B.ORGANIZATION_ID,
    ltrim(rtrim(B.DESCRIPTION)),
    ltrim(rtrim(B.LONG_DESCRIPTION)),
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
   FROM MTL_SYSTEM_ITEMS_TL  B,
        FND_LANGUAGES        L
   WHERE L.INSTALLED_FLAG in ('I', 'B')
   AND   B.LANGUAGE = userenv('LANG')
   AND   NOT EXISTS( SELECT NULL
                     FROM   MTL_SYSTEM_ITEMS_TL  T
                     WHERE  T.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                     AND    T.ORGANIZATION_ID   = B.ORGANIZATION_ID
                     AND    T.LANGUAGE          = L.LANGUAGE_CODE);

   --Commit and call sync index so that iM index is in sync.
   COMMIT;
   INV_ITEM_PVT.SYNC_IM_INDEX;
END ADD_LANGUAGE;


-- ------------------- UPDATE_NLS_TO_ORG --------------------

PROCEDURE UPDATE_NLS_TO_ORG(
   X_INVENTORY_ITEM_ID IN VARCHAR2,
   X_ORGANIZATION_ID   IN VARCHAR2,
   X_LANGUAGE          IN VARCHAR2,
   X_DESCRIPTION       IN VARCHAR2,
   X_LONG_DESCRIPTION  IN VARCHAR2) IS

   CURSOR Item_csr IS
      SELECT INVENTORY_ITEM_ID
            ,ORGANIZATION_ID
            ,LANGUAGE
            ,SOURCE_LANG
            ,DESCRIPTION
            ,LONG_DESCRIPTION
      FROM   MTL_SYSTEM_ITEMS_TL
      WHERE  INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID
      AND  ORGANIZATION_ID IN ( SELECT  ORGANIZATION_ID
                                FROM  MTL_PARAMETERS
                                WHERE  MASTER_ORGANIZATION_ID = X_ORGANIZATION_ID
                                AND  ORGANIZATION_ID         <> X_ORGANIZATION_ID)
      AND  LANGUAGE = X_LANGUAGE
      FOR UPDATE OF INVENTORY_ITEM_ID;

   l_desc_control              mtl_item_attributes.control_level%type;
   l_longdesc_control          mtl_item_attributes.control_level%type;

BEGIN

   begin
      select control_level
      into l_desc_control
      from mtl_item_attributes
      where attribute_name = 'MTL_SYSTEM_ITEMS.DESCRIPTION';
   exception
      when no_data_found then
       l_desc_control := 0;
   end;

   begin
      select control_level
      into l_longdesc_control
      from mtl_item_attributes
      where attribute_name = 'MTL_SYSTEM_ITEMS.LONG_DESCRIPTION';
   exception
      when no_data_found then
       l_longdesc_control := 0;
   end;

     if ((length(x_description)) <> length(rtrim(x_description))) then
      fnd_message.Set_Name( 'INV', 'INV_DESCR_TRAILING_SPACES' );
       app_exception.raise_exception;
    end if;

     if ((length(x_long_description)) <> length(rtrim(x_long_description))) then
      fnd_message.Set_Name( 'INV', 'INV_LONGDESCR_TRAILING_SPACES' );
       app_exception.raise_exception;
        return ;
    end if;

     --- bug 8717482 vggarg added validations for leaing spaces also.
            if ((length(x_description)) <> length(ltrim(x_description))) then
         fnd_message.Set_Name( 'INV', 'INV_DESCR_LEADING_SPACES' );
          app_exception.raise_exception;
       end if;

        if ((length(x_long_description)) <> length(ltrim(x_long_description))) then
         fnd_message.Set_Name( 'INV', 'INV_LONGDESCR_LEADING_SPACES' );
          app_exception.raise_exception;
           return ;
       end if;
   --- bug  8717482 vggarg end changes

       /*
   update mtl_system_items_tl
   set description         = ltrim(rtrim(x_description)),
       long_description    = ltrim(rtrim(x_long_description)),
       source_lang         = x_language,
       last_updated_by     = fnd_profile.value('USER_ID'),
       last_update_login   = fnd_profile.value('LOGIN_ID')
   WHERE  INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID
    AND  ORGANIZATION_ID =  X_ORGANIZATION_ID;

*/
   for c1 in Item_csr
   loop
      if (l_desc_control = 1) then
         update mtl_system_items_tl
         set description         = ltrim(rtrim(x_description)),
             source_lang         = x_language,
             last_update_date    = sysdate,
             last_updated_by     = fnd_profile.value('USER_ID'),
             last_update_login   = fnd_profile.value('LOGIN_ID')
         where CURRENT OF Item_csr;

      end if;

      if (l_longdesc_control = 1) then
         update mtl_system_items_tl
         set long_description    = ltrim(rtrim(x_long_description)),
             source_lang         = x_language,
             last_update_date    = sysdate,
             last_updated_by     = fnd_profile.value('USER_ID'),
             last_update_login   = fnd_profile.value('LOGIN_ID')
         where CURRENT OF Item_csr;

      end if;
   end loop;
   return;
END UPDATE_NLS_TO_ORG;

--Sync iM index after item creation,updation and org assignment.
PROCEDURE SYNC_IM_INDEX IS

   CURSOR c_ego_exists IS
      SELECT  'Y'
      FROM    FND_OBJECTS
      WHERE   OBJ_NAME ='EGO_ITEM';

   l_ego_exists                 VARCHAR2(1) := 'N';
   l_object_exists              VARCHAR2(1) := 'N';

BEGIN
   OPEN  c_ego_exists;
   FETCH c_ego_exists INTO l_ego_exists;
   CLOSE c_ego_exists;
   l_ego_exists := nvl(l_ego_exists,'N');

   IF (l_ego_exists = 'Y'  AND INV_Item_Util.g_Appl_Inst.EGO <> 0 ) THEN
      l_object_exists := INV_ITEM_UTIL.Object_Exists
                              (p_object_type => 'PACKAGE BODY'
                              ,p_object_name => 'EGO_ITEM_TEXT_UTIL');
      IF l_object_exists = 'Y' THEN
            EXECUTE IMMEDIATE
               ' BEGIN                                 '||
               '    EGO_ITEM_TEXT_UTIL.SYNC_INDEX;     '||
               ' EXCEPTION                             '||
               ' WHEN OTHERS THEN                      '||
               '    NULL;                              '||
               ' END;';
      END IF;
   END IF;

   -- Call IP Intermedia Sync
   INV_ITEM_EVENTS_PVT.Sync_IP_IM_Index;

   EXCEPTION
      WHEN OTHERS THEN
      IF c_ego_exists%ISOPEN THEN
         CLOSE c_ego_exists;
      END IF;
END SYNC_IM_INDEX;

-- Added as part of Bug Fix 3623450 to Check whether the master item record
-- is locked.  Called from item form COPY_ITEM block DONE and COPY button's W-B-P
PROCEDURE Check_Master_Record_Locked( P_Item_Rec  IN  INV_ITEM_API.Item_rec_type) IS

   CURSOR c_item_name IS
    SELECT
      SEGMENT1
    from  MTL_SYSTEM_ITEMS_B
    where  INVENTORY_ITEM_ID = P_Item_Rec.inventory_item_id
      and  ORGANIZATION_ID   = P_Item_rec.organization_id
    for update of INVENTORY_ITEM_ID nowait;

   recinfo          c_item_name%ROWTYPE;
   l_return_status  VARCHAR2(1);

BEGIN

   OPEN c_item_name;
   FETCH c_item_name INTO recinfo;

   IF (c_item_name%NOTFOUND) THEN
      CLOSE c_item_name;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   CLOSE c_item_name;

EXCEPTION
   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      IF ( c_item_name%ISOPEN ) THEN
        CLOSE c_item_name;
      END IF;
      app_exception.raise_exception;

END Check_Master_Record_Locked;

/*Bug 6407303 Adding new functions to se and get the value of the attribute G_IS_MASTER_ATTR_MODIFIED  */
    FUNCTION Get_Is_Master_Attr_Modified RETURN VARCHAR2 IS
     BEGIN
         RETURN (G_IS_MASTER_ATTR_MODIFIED);
     END  Get_Is_Master_Attr_Modified;

     PROCEDURE Set_Is_Master_Attr_Modified(p_is_master_attr_modified VARCHAR2) IS
     BEGIN
        G_IS_MASTER_ATTR_MODIFIED := p_is_master_attr_modified;
     END  Set_Is_Master_Attr_Modified;

/*Bug 6407303 */

END INV_ITEM_PVT;

/
