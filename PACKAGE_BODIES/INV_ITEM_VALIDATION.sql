--------------------------------------------------------
--  DDL for Package Body INV_ITEM_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_VALIDATION" AS
/* $Header: INVVIVAB.pls 120.2 2005/06/21 05:54:35 appldev ship $ */

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------

G_PKG_NAME       CONSTANT   VARCHAR2(30)  := 'INV_Item_Validation';


-- ==========================================================================
-- API Name:		Attribute_Dependency
-- ==========================================================================

PROCEDURE Attribute_Dependency
(
    p_Item_rec          IN   INV_Item_API.Item_rec_type
,   x_return_status     OUT  NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := fnd_api.g_RET_STS_SUCCESS ;

  if (p_Item_rec.inventory_item_flag ='N' AND
      p_Item_rec.stock_enabled_flag ='Y' ) THEN
    fnd_message.SET_NAME('INV', 'INVALID_INV_STK_FLAG_COMB');
    fnd_msg_pub.Add;
     x_return_status := fnd_api.g_RET_STS_ERROR ;
     RETURN;
  END IF;

  IF (p_Item_rec.stock_enabled_flag ='N' AND
      p_Item_rec.mtl_transactions_enabled_flag ='Y' )THEN
    fnd_message.SET_NAME('INV', 'INVALID_STK_TRX_FLAG_COMB');
    fnd_msg_pub.Add;
     x_return_status := fnd_api.g_RET_STS_ERROR ;
     RETURN;
  END IF;

  IF (p_Item_rec.purchasing_item_flag ='N' AND
      p_Item_rec.purchasing_enabled_flag ='Y' )THEN
    fnd_message.SET_NAME('INV', 'INVALID_PI_PE_FLAG_COMB');
    fnd_msg_pub.Add;
     x_return_status := fnd_api.g_RET_STS_ERROR ;
     RETURN;
  END IF;

  IF (p_Item_rec.customer_order_flag ='N' AND
      p_Item_rec.customer_order_enabled_flag ='Y' )THEN
    fnd_message.SET_NAME('INV', 'INVALID_CO_COE_FLAG_COMB');
    fnd_msg_pub.Add;
     x_return_status := fnd_api.g_RET_STS_ERROR ;
     RETURN;
  END IF;

  IF (p_Item_rec.internal_order_flag ='N' AND
      p_Item_rec.internal_order_enabled_flag ='Y' )THEN
    fnd_message.SET_NAME('INV', 'INVALID_IO_IOE_FLAG_COMB');
    fnd_msg_pub.Add;
     x_return_status := fnd_api.g_RET_STS_ERROR ;
     RETURN;
  END IF;

  /* Bug 1461892 */

  /* Changed due to introduction of Contract_Item_Type_Code attribute
     (bugs 1755412, 1960366). */

  ------------------------------------------------------------------------------
  -- BOM Allowed flag can be enabled only for Inventory Item or Contract Items.
  ------------------------------------------------------------------------------

  IF (     p_Item_rec.inventory_item_flag = 'N'
       AND p_Item_rec.contract_item_type_code IS NULL
       AND p_Item_rec.bom_enabled_flag = 'Y' )
  THEN
     FND_MESSAGE.Set_Name ('INV', 'INV_ITEM_MASTER_CTRL_ATTR_ERR');
     FND_MESSAGE.Set_Token ('ERROR_MESSAGE_NAME', 'INV_BOM_ENABLED', TRUE);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.g_RET_STS_ERROR;
     RETURN;
  END IF;

  ------------------------------------------------------------------------------
  --
  ------------------------------------------------------------------------------

  IF ( ( p_item_rec.inventory_item_flag = 'N' OR p_item_rec.bom_item_type <> 4 )
       AND p_Item_rec.build_in_wip_flag ='Y' )
  THEN

--    To get a message from the server to Client.
--    fnd_message.set_name('INV', 'IIF, BIT, BIWF '|| p_item_rec.inventory_item_flag||', '||to_char(p_item_rec.bom_item_type)||', '||p_item_rec.build_in_wip_flag);
--    fnd_message.RAISE_ERROR;

     FND_MESSAGE.Set_Name ('INV', 'INVALID_INV_WIP_FLAG_COMB');
     FND_MSG_PUB.Add;
     x_return_status := fnd_api.g_RET_STS_ERROR;
     RETURN;
  END IF;

END Attribute_Dependency;


-- ==========================================================================
-- API Name:		Effectivity_Control
-- ==========================================================================

PROCEDURE Effectivity_Control
(
    p_Item_rec          IN   INV_Item_API.Item_rec_type
,   x_return_status     OUT  NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := fnd_api.g_RET_STS_SUCCESS ;

  ---------------------------------------------------------------------------
  -- Serial Number Generation atrribute must be 'At Recept' or 'Predefined',
  -- if Effectivity Control is 'Model/Unit Number'.
  ---------------------------------------------------------------------------

  IF ( p_Item_rec.EFFECTIVITY_CONTROL = 2 ) AND
     ( p_Item_rec.SERIAL_NUMBER_CONTROL_CODE NOT IN (2, 5) )
  THEN
--     fnd_message.SET_NAME('INV', 'ITM-EFFC-Invalid Serial Ctrl');
     fnd_message.SET_NAME('INV', 'ITM-EFFC-INVALID SERIAL CTRL-2');
     fnd_msg_pub.Add;
     x_return_status := fnd_api.g_RET_STS_ERROR ;
     RETURN;
  END IF;

END Effectivity_Control;


END INV_Item_Validation;

/
