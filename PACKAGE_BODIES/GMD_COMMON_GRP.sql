--------------------------------------------------------
--  DDL for Package Body GMD_COMMON_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COMMON_GRP" AS
--$Header: GMDGCOMB.pls 120.2 2006/01/02 02:13:22 svankada noship $ */

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_COMMON_GRP';

   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;

-- Start of comments
--+=======================================================================================================+
--|                   Copyright (c) 1998 Oracle Corporation
--|                          Redwood Shores, CA, USA
--|                            All rights reserved.
--+========================================================================================================+
--| File Name          : GMDGCOMB.pls
--| Package Name       : GMD_COMMON_GRP
--| Type               : Group
--|
--| Notes
--|    This package contains common group layer APIs for Quality
--|
--| HISTORY
--|    S. Feinstein     05-Jan-2005 Created.
--|
--+========================================================================================================+

--+========================================================================================================+
--| API Name    : item_is_locator_controlled
--| TYPE        : Group
--|
--| NOTE: Values for locator control are:
--|       =1    None: Inventory transactions within this organization do not require locator information.
--|       =2    Prespecified only: Inventory transactions within this organization require a valid,
--|             predefined locator for each item.
--|       =3    Dynamic entry allowed: Inventory transactions within this organization require a locator
--|             for each item. You can choose a valid, predefined locator, or define a locator dynamically
--|             at the time of transaction.
--|       =4    Determined at subinventory level: Inventory transactions use locator  control information
--|             that you define at the subinventory level.
--|       =5    Determined at item level: Inventory transactions use locator  control information that you
--|             define at the item level.
--|
--| HISTORY
--|    S. Feinstein        05-Jan-2005	Created.
--+===========================================================================================================+

PROCEDURE item_is_locator_controlled (
                      p_organization_id   IN    NUMBER
                     ,p_subinventory      IN    VARCHAR2
                     ,p_inventory_item_id IN    NUMBER
                     ,x_locator_type      OUT NOCOPY   NUMBER
                     ,x_return_status     OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_subinventory(subinventory varchar2 ) IS
       SELECT Locator_type
       FROM   mtl_secondary_inventories
       WHERE  secondary_inventory_name = subinventory
         AND  organization_id          = p_organization_id;

    CURSOR Cur_item (item_id number ) IS
       SELECT location_control_code
       FROM   mtl_system_items_b_kfv
       WHERE  organization_id     = p_organization_id
         AND  inventory_item_id   = item_id;

    CURSOR Cur_organization  IS
       SELECT stock_locator_control_code
       FROM   mtl_parameters
       WHERE  organization_id    = p_organization_id ;

    subinventory_ctrl NUMBER;
    organization_ctrl NUMBER;
    item_ctrl         NUMBER;


BEGIN
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line('Entered Procedure ITEM_IS_LOCATOR_CONTROLLED');
           gmd_debug.put_line('p_organization_id : '   || p_organization_id);
           gmd_debug.put_line('p_subinventory : '      || p_subinventory);
           gmd_debug.put_line('p_inventory_item_id : ' || p_inventory_item_id);
        END IF;


        IF   p_subinventory      IS NULL
          OR p_organization_id   IS NULL
          /*OR p_inventory_item_id IS NULL   --bug# 4916503 */
       THEN
            x_locator_type := 0;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        OPEN  cur_subinventory( p_subinventory );
        FETCH cur_subinventory INTO subinventory_ctrl;
        CLOSE cur_subinventory;

           gmd_debug.put_line('subinventory ctrl = '||subinventory_ctrl);

        OPEN  cur_item(p_inventory_item_id );
        FETCH cur_item INTO item_ctrl;
        CLOSE cur_item;
           gmd_debug.put_line('item ctrl = '||item_ctrl);

        --OPEN  cur_organization(p_organization_id);
        OPEN  cur_organization;
        FETCH cur_organization INTO organization_ctrl;
        CLOSE cur_organization;
           gmd_debug.put_line('organization ctrl = '||organization_ctrl||'  org id='||p_organization_id);

	If organization_ctrl in (1,2,3) then
             x_locator_type := organization_ctrl;
	ELSIF organization_ctrl = 4
	   AND subinventory_ctrl in (1,2,3) then
             x_locator_type := subinventory_ctrl;
	ELSIF subinventory_ctrl = 5
	   AND item_ctrl  in (1,2,3) then
             x_locator_type := item_ctrl;
	ELSE
             x_locator_type := 0;
             x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
           gmd_debug.put_line('x_locator_type ='||x_locator_type);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
 WHEN OTHERS THEN
      x_locator_type := 0;
      fnd_msg_pub.add_exc_msg (g_pkg_name );
      x_return_status := FND_API.g_ret_sts_unexp_error;

END item_is_locator_controlled;


--+========================================================================================================+
--| API Name    : get_organization_type
--| TYPE        : Group
--|
--| HISTORY
--|    S. Feinstein        05-Jan-2005	Created.
--+===========================================================================================================+
PROCEDURE Get_organization_type ( p_organization_id IN  Number
                        ,x_plant           OUT NOCOPY NUMBER
              	        ,x_lab             OUT NOCOPY NUMBER
                        ,x_return_status   OUT NOCOPY VARCHAR2) IS

     CURSOR Cur_get_lab_plant_ind IS
        SELECT plant_ind, lab_ind
        FROM gmd_parameters_hdr
        WHERE organization_id = P_organization_id;

     --gmd_parameters  GMD_PARAMETERS_DTL_PKG.parameter_rec_type;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN  Cur_get_lab_plant_ind;
     FETCH Cur_get_lab_plant_ind INTO x_plant,
                                      x_lab;
     CLOSE Cur_get_lab_plant_ind;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG (g_pkg_name );
END get_organization_type;


--+========================================================================================================+
--| API Name    : get_lot_attributes
--| TYPE        : Group
--|
--| HISTORY
--|    S. Feinstein        01-Jun-2005  Created.
--+===========================================================================================================+
PROCEDURE Get_lot_attributes ( p_organization_id    IN  NUMBER
                              ,p_inventory_item_id  IN  NUMBER
                              ,p_lot_number         IN  VARCHAR2
                              ,p_parent_lot_number  IN  VARCHAR2
                              ,x_lot_status_code    OUT NOCOPY VARCHAR2
                              ,x_grade_code         OUT NOCOPY VARCHAR2
                              ,x_return_status      OUT NOCOPY VARCHAR2) IS

     CURSOR Cur_get_lot_attrib IS
         SELECT status_id,
                grade_code
         FROM mtl_lot_numbers
         WHERE  inventory_item_id  =  p_inventory_item_id
           AND  organization_id    =  p_organization_id
           AND  ((p_lot_number IS NULL) OR (lot_number  =  p_lot_number))
           AND  ((parent_lot_number  =  p_parent_lot_number)
               OR (parent_lot_number IS NULL)
               OR (p_parent_lot_number IS NULL));

    p_lot_status_id   NUMBER;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN  Cur_get_lot_attrib;
     FETCH Cur_get_lot_attrib INTO p_lot_status_id,
                                   x_grade_code;
     CLOSE Cur_get_lot_attrib;

     IF p_lot_status_id IS NOT NULL THEN
        SELECT status_code into x_lot_status_code
        FROM   mtl_material_statuses
        WHERE  status_id = p_lot_status_id;
     END IF;

     IF (l_debug = 'Y') THEN
           gmd_debug.put_line('Entered Procedure get_lot_attributes');
           gmd_debug.put_line('p_organization_id : '   || p_organization_id);
           gmd_debug.put_line('p_lot_number : '      || p_lot_number);
           gmd_debug.put_line('p_inventory_item_id : ' || p_inventory_item_id);
           gmd_debug.put_line('p_lot_status_id : ' || p_lot_status_id);
     END IF;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG (g_pkg_name );
END get_lot_attributes;

END GMD_COMMON_GRP;


/
