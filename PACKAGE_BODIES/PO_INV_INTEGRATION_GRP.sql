--------------------------------------------------------
--  DDL for Package Body PO_INV_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INV_INTEGRATION_GRP" AS
/* $Header: PO_INV_INTEGRATION_GRP.plb 120.1 2005/08/19 16:26:06 dreddy noship $ */

G_PKG_NAME             CONSTANT VARCHAR2(30) := 'PO_INV_INTEGRATION_GRP';

-------------------------------------------------------------------------------
--Start of Comments
--Name: inv_um_convert
--Pre-reqs:
--  none
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Converts the given quantity from one uom to the other
--Parameters:
--IN:
--p_api_version
--  Initial API version : Expected value is 1.0
--p_item_id
-- Inventory Item Id for whxih the conversion is defined
--p_from_quantity
-- Quantity to be converted
--p_from_unit_of_measure
--  The unit of measure to be converted from
--p_to_unit_of_measure
--  The unit of measure to be converted to
--OUT:
--x_to_quantity
--  Qty converted from from_uom to the to_uom
--x_ret_status
--  (a) FND_API.G_RET_STS_SUCCESS - 'S' if successful
--  (b) FND_API.G_RET_STS_ERROR - 'E' if known error occurs
--  (c) FND_API.G_RET_STS_UNEXP_ERROR - 'U' if unexpected error occurs
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_converted_qty(p_api_version    IN NUMBER,
                         p_item_id   IN number,
                         p_from_quantity        IN NUMBER,
                         p_from_unit_of_measure IN VARCHAR2,
                         p_to_unit_of_measure   IN VARCHAR2 ,
                         x_to_quantity    OUT NOCOPY NUMBER,
                         x_return_status  OUT NOCOPY VARCHAR2 ) IS

l_api_name              CONSTANT VARCHAR2(30) := 'get_converted_qty';
l_api_version           CONSTANT NUMBER := 1.0;

l_to_quantity           NUMBER := null;

BEGIN
 -- Initialise the return status
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- check for API version
 IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) )
 THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   return;
 END IF;

 -- Call the Inv API to get the qty
 l_to_quantity := INV_CONVERT.inv_um_convert (
         item_id        => p_item_id,
         precision      => 5,
         from_quantity  => p_from_quantity,
         from_unit      => null,
         to_unit        => null,
         from_name	=> p_from_unit_of_measure,
         to_name	=> p_to_unit_of_measure );

 IF l_to_quantity < 0 THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME('INV','INV_INVALID_UOM_CONV');
   FND_MESSAGE.SET_TOKEN ('VALUE1',p_from_unit_of_measure);
   FND_MESSAGE.SET_TOKEN ('VALUE2',p_to_unit_of_measure);
   FND_MSG_PUB.ADD;
 ELSE
   x_to_quantity := l_to_quantity;
 END IF;

EXCEPTION
When Others then
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

-------------------------------------------------------------------------------
--Start of Comments
--Name: within_deviation
--Pre-reqs:
--  none
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Checks if the given primary and secondary quantities are within the allowed
--  deviation for the primary and secondary UOM's
--Parameters:
--IN:
--p_api_version
--  Initial API version : Expected value is 1.0
--p_organization_id
-- Inventory Organization id to validate the item in
--p_item_id
-- Inventory Item Id for which the deviation is defined
--p_pri_quantity
-- Primary Quantity
--p_sec_quantity
--  Secondary Quantity
--p_pri_unit_of_measure
--  The unit of measure corresponding to primary qty
--p_sec_unit_of_measure
--  The unit of measure corresponding to secondary qty
--OUT:
--x_ret_status
--  (a) FND_API.G_RET_STS_SUCCESS - 'S' if successful
--  (b) FND_API.G_RET_STS_ERROR - 'E' if known error occurs
--  (c) FND_API.G_RET_STS_UNEXP_ERROR - 'U' if unexpected error occurs
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE within_deviation(p_api_version    IN NUMBER,
                           p_organization_id     IN NUMBER,
                           p_item_id             IN NUMBER,
                           p_pri_quantity        IN NUMBER,
                           p_sec_quantity        IN NUMBER,
                           p_pri_unit_of_measure IN VARCHAR2,
                           p_sec_unit_of_measure IN VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_data       OUT NOCOPY VARCHAR2) IS

l_api_name              CONSTANT VARCHAR2(30) := 'within_deviation';
l_api_version           CONSTANT NUMBER := 1.0;

l_return_code           NUMBER;

BEGIN
 -- Initialise the return status
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- check for API version
 IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) )
 THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   return;
 END IF;

 -- call the inv API to check deviation
 l_return_code := INV_CONVERT.within_deviation(
      p_organization_id     => p_organization_id,
      p_inventory_item_id   => p_item_id,
      p_lot_number          => null,
      p_precision           => 5,
      p_quantity            => p_pri_quantity,
      p_uom_code1           => null,
      p_quantity2           => p_sec_quantity,
      p_uom_code2           => null,
      p_unit_of_measure1    => p_pri_unit_of_measure,
      p_unit_of_measure2    => p_sec_unit_of_measure);

 IF l_return_code = 0 THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := FND_MESSAGE.get_encoded;
 END IF;


EXCEPTION
When Others then
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

END PO_INV_INTEGRATION_GRP;

/
