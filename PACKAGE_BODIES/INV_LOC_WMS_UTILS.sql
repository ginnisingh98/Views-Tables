--------------------------------------------------------
--  DDL for Package Body INV_LOC_WMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOC_WMS_UTILS" AS
/* $Header: INVLCPYB.pls 120.11.12010000.12 2010/02/16 19:16:05 sfulzele ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_LOC_WMS_UTILS';


-- to turn off debugger, comment out the line 'dbms_output.put_line(msg);'
PROCEDURE mdebug(msg in varchar2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- dbms_output.put_line(msg);
   INV_TRX_UTIL_PUB.TRACE(msg,'INV_LOC_WMS_UTILS ',9);
END;

-- This API returns the current and suggested volume, weight, and units capacity of a
-- given locator in the primary unit of measure
PROCEDURE get_locator_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    x_location_maximum_units    OUT NOCOPY NUMBER,   -- max number of units that can be stored in locator
    x_location_current_units    OUT NOCOPY NUMBER,   -- current number of units in locator
    x_location_suggested_units  OUT NOCOPY NUMBER,   -- suggested number of units to be put into locator
    x_location_available_units  OUT NOCOPY NUMBER,   -- number of units that can still be put into locator
    x_location_weight_uom_code  OUT NOCOPY VARCHAR2, -- the locator's unit of measure for weight
    x_max_weight                OUT NOCOPY NUMBER,   -- max weight the locator can take
    x_current_weight            OUT NOCOPY NUMBER,   -- current weight in the locator
    x_suggested_weight          OUT NOCOPY NUMBER,   -- suggested weight to be put into locator
    x_available_weight          OUT NOCOPY NUMBER,   -- weight the locator can still take
    x_volume_uom_code           OUT NOCOPY VARCHAR2, -- the locator's unit of measure for volume
    x_max_cubic_area            OUT NOCOPY NUMBER,   -- max volume the locator can take
    x_current_cubic_area        OUT NOCOPY NUMBER,   -- current volume in the locator
    x_suggested_cubic_area      OUT NOCOPY NUMBER,   -- suggested volume to be put into locator
    x_available_cubic_area      OUT NOCOPY NUMBER,   -- volume the locator can still take
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER    -- identifier of locator
  )
  IS
     l_physical_locator_id             NUMBER;
     l_locator_id                      NUMBER;
     l_inventory_location_id           NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* If the locator has a physical_location_id
     then use the physical_location_id for further
     processing.Else we have to use the inventory_location_id
     for further processing
   */
   /* Select all required values at same time
   SELECT physical_location_id ,
	  inventory_location_id
   INTO l_physical_locator_id,
	l_locator_id
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id; */

   SELECT
       physical_location_id,
       inventory_location_id,
       location_maximum_units,
       location_current_units,
       location_available_units,
       location_suggested_units,
       location_weight_uom_code,
       max_weight,
       current_weight,
       suggested_weight,
       available_weight,
       volume_uom_code,
       max_cubic_area,
       current_cubic_area,
       suggested_cubic_area,
       available_cubic_area
     INTO l_physical_locator_id,
       l_locator_id,
       x_location_maximum_units,
       x_location_current_units,
       x_location_available_units,
       x_location_suggested_units,
       x_location_weight_uom_code,
       x_max_weight,
       x_current_weight,
       x_suggested_weight,
       x_available_weight,
       x_volume_uom_code,
       x_max_cubic_area,
       x_current_cubic_area,
       x_suggested_cubic_area,
       x_available_cubic_area
     from mtl_item_locations
     where organization_id              = p_organization_id
       and   inventory_location_id      = p_inventory_location_id;

   IF (l_physical_locator_id is NOT null) AND (l_physical_locator_id <> p_inventory_location_id) THEN

     select
       location_maximum_units,
       location_current_units,
       location_available_units,
       location_suggested_units,
       location_weight_uom_code,
       max_weight,
       current_weight,
       suggested_weight,
       available_weight,
       volume_uom_code,
       max_cubic_area,
       current_cubic_area,
       suggested_cubic_area,
       available_cubic_area
     into
       x_location_maximum_units,
       x_location_current_units,
       x_location_available_units,
       x_location_suggested_units,
       x_location_weight_uom_code,
       x_max_weight,
       x_current_weight,
       x_suggested_weight,
       x_available_weight,
       x_volume_uom_code,
       x_max_cubic_area,
       x_current_cubic_area,
       x_suggested_cubic_area,
       x_available_cubic_area
     from mtl_item_locations
     where organization_id 		= p_organization_id
       and   inventory_location_id 	= l_physical_locator_id;

   END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name,
	      'get_locator_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

END get_locator_capacity;

-- This API only returns the current and suggested unit capacity of a
-- given locator
PROCEDURE get_locator_unit_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    x_location_maximum_units    OUT NOCOPY NUMBER,   -- max number of units that can be stored in locator
    x_location_current_units    OUT NOCOPY NUMBER,   -- current number of units in locator
    x_location_suggested_units  OUT NOCOPY NUMBER,   -- suggested number of units to be put into locator
    x_location_available_units  OUT NOCOPY NUMBER,   -- number of units that can still be put into locator
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER    -- identifier of locator
    )
  IS
     l_physical_locator_id             NUMBER;
     l_locator_id              NUMBER;
     l_inventory_location_id           NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* If the locator has a physical_location_id
     then use the physical_location_id for further
     processing.Else we have to use the inventory_location_id
     for further processing
   */
   /* Select all required values at same time
   SELECT physical_location_id ,
	  inventory_location_id
   INTO l_physical_locator_id,
	l_locator_id
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id; */
   SELECT physical_location_id ,
	  inventory_location_id ,
       location_maximum_units,
       location_current_units,
       location_available_units,
       location_suggested_units
   INTO l_physical_locator_id,
	l_locator_id,
        x_location_maximum_units,
        x_location_current_units,
        x_location_available_units,
        x_location_suggested_units
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id;

   IF (l_physical_locator_id is  NOT null) AND (l_physical_locator_id <> p_inventory_location_id) THEN
      select
         location_maximum_units,
         location_current_units,
         location_available_units,
         location_suggested_units
       into
         x_location_maximum_units,
         x_location_current_units,
         x_location_available_units,
         x_location_suggested_units
       from mtl_item_locations
       where organization_id 		= p_organization_id
         and inventory_location_id 	= l_physical_locator_id;  -- 7263312 changed to l_physical_locator_id
   END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'get_locator_unit_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

END get_locator_unit_capacity;


-- This API only returns the current and suggested weight capacity of a
-- given locator
PROCEDURE get_locator_weight_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    x_location_weight_uom_code  OUT NOCOPY VARCHAR2, -- the locator's unit of measure for weight
    x_max_weight                OUT NOCOPY NUMBER,   -- max weight the locator can take
    x_current_weight            OUT NOCOPY NUMBER,   -- current weight in the locator
    x_suggested_weight          OUT NOCOPY NUMBER,   -- suggested weight to be put into locator
    x_available_weight          OUT NOCOPY NUMBER,   -- weight the locator can still take
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER    -- identifier of locator
    )
  IS
     l_physical_locator_id             NUMBER;
     l_locator_id              NUMBER;
     l_inventory_location_id           NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* If the locator has a physical_location_id
     then use the physical_location_id for further
     processing.Else we have to use the inventory_location_id
     for further processing
   */
   /* Select all required values at same time
   SELECT physical_location_id ,
	  inventory_location_id
   INTO l_physical_locator_id,
	l_locator_id
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id; */
   SELECT physical_location_id ,
        inventory_location_id,
        location_weight_uom_code,
        max_weight,
        current_weight,
        suggested_weight,
        available_weight
   INTO l_physical_locator_id,
	l_locator_id,
        x_location_weight_uom_code,
        x_max_weight,
        x_current_weight,
        x_suggested_weight,
        x_available_weight
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id;

   IF (l_physical_locator_id is  NOT null) AND (l_physical_locator_id <> p_inventory_location_id) THEN
      select
         location_weight_uom_code,
         max_weight,
         current_weight,
         suggested_weight,
         available_weight
      into
         x_location_weight_uom_code,
         x_max_weight,
         x_current_weight,
         x_suggested_weight,
         x_available_weight
       from mtl_item_locations
       where organization_id 		= p_organization_id
         and   inventory_location_id 	= l_physical_locator_id;  -- 7263312 changed to l_physical_locator_id
   END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'get_locator_weight_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

END get_locator_weight_capacity;

-- This API only returns the current and suggested volume capacity of a
-- given locator
PROCEDURE get_locator_volume_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    x_volume_uom_code           OUT NOCOPY VARCHAR2, -- the locator's unit of measure for volume
    x_max_cubic_area            OUT NOCOPY NUMBER,   -- max volume the locator can take
    x_current_cubic_area        OUT NOCOPY NUMBER,   -- current volume in the locator
    x_suggested_cubic_area      OUT NOCOPY NUMBER,   -- suggested volume to be put into locator
    x_available_cubic_area      OUT NOCOPY NUMBER,   -- volume the locator can still take
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER    -- identifier of locator
    )
  IS
     l_physical_locator_id             NUMBER;
     l_locator_id              NUMBER;
     l_inventory_location_id           NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* If the locator has a physical_location_id
     then use the physical_location_id for further
     processing.Else we have to use the inventory_location_id
     for further processing
   */
   /* Select all required values at same time
   SELECT physical_location_id ,
	  inventory_location_id
   INTO l_physical_locator_id,
	l_locator_id
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id; */

   SELECT physical_location_id ,
      inventory_location_id,
       volume_uom_code,
       max_cubic_area,
       current_cubic_area,
       suggested_cubic_area,
       available_cubic_area
   INTO l_physical_locator_id,
	l_locator_id,
        x_volume_uom_code,
        x_max_cubic_area,
        x_current_cubic_area,
        x_suggested_cubic_area,
        x_available_cubic_area
    FROM mtl_item_locations
    WHERE organization_id 		= p_organization_id
       and   inventory_location_id 	= p_inventory_location_id;

   IF (l_physical_locator_id is NOT null) AND (l_physical_locator_id <> l_inventory_location_id) THEN
    select
       volume_uom_code,
       max_cubic_area,
       current_cubic_area,
       suggested_cubic_area,
       available_cubic_area
     into
       x_volume_uom_code,
       x_max_cubic_area,
       x_current_cubic_area,
       x_suggested_cubic_area,
       x_available_cubic_area
     from mtl_item_locations
     where organization_id 		= p_organization_id
       and   inventory_location_id 	= l_physical_locator_id;
   END IF;


EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'get_locator_volume_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

END get_locator_volume_capacity;


-- This API updates the current volume, weight and units capacity of a locator when items are
-- issued or received in the locator
PROCEDURE update_loc_curr_capacity_nauto
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER,   -- identifier of locator
    p_inventory_item_id         IN  NUMBER,   -- identifier of item
    p_primary_uom_flag          IN  VARCHAR2, -- 'Y' - transaction was in item's primary UOM
					      -- 'N' - transaction was NOT in item's primary UOM
					      --       or the information is not known
    p_transaction_uom_code      IN  VARCHAR2, -- UOM of the transacted material that causes the
					      -- locator capacity to get updated
    p_quantity                  IN  NUMBER,   -- transaction quantity in p_transaction_uom_code
    p_issue_flag                IN  VARCHAR2  -- 'Y' - Issue transaction
					      -- 'N' - Receipt transaction
  )
  IS
     -- item attributes
     l_item_primary_uom_code     varchar2(3);
     l_item_weight_uom_code 	 varchar2(3);
     l_item_unit_weight		 number;
     l_item_volume_uom_code	 varchar2(3);
     l_item_unit_volume		 number;
     -- transaction attributes
     l_quantity                  NUMBER;  -- local variable to check that p_quantity always > 0
     l_primary_quantity	         number;
     l_transacted_weight	 number;
     l_transacted_volume	 number;
     -- converted transaction attributes
     l_loc_uom_xacted_weight	 number;
     l_loc_uom_xacted_volume	 number;
     -- location attributes in units
     l_max_units       	         number;
     l_current_units	         number;
     l_suggested_units	         number;
     l_available_units	         number;
     -- location attributes in weight
     l_location_weight_uom_code	 varchar2(3);
     l_max_weight		 number;
     l_current_weight		 number;
     l_suggested_weight		 number;
     l_available_weight 	 number;
     -- location attributes in volume
     l_volume_uom_code		 varchar2(3);
     l_max_cubic_area		 number;
     l_current_cubic_area	 number;
     l_suggested_cubic_area	 number;
     l_available_cubic_area	 number;
     -- updated capacity
     l_update_units		 boolean := TRUE;  -- always update units
     l_update_weight		 boolean := FALSE; -- only update if have location and item UOMs
     l_update_volume		 boolean := FALSE; -- only update if have location and item UOMs
     -- updated location
     l_upd_loc_current_units	number;
     l_upd_loc_available_units	number;
     l_upd_loc_current_weight	number;
     l_upd_loc_available_weight	number;
     l_upd_loc_current_volume	number;
     l_upd_loc_available_volume	number;

     l_physical_locator_id             NUMBER;
     l_locator_id              NUMBER;
     l_inventory_location_id           NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    IF (l_debug = 1) THEN
       mdebug('In update_loc_curr_capacity_nauto');
    END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* If the locator has a physical_location_id
     then use the physical_location_id for further
     processing.Else we have to use the inventory_location_id
     for further processing
   */
   SELECT physical_location_id ,
	  inventory_location_id
   INTO l_physical_locator_id,
	l_locator_id
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id;

   IF l_physical_locator_id is null THEN
     l_inventory_location_id := l_locator_id;
   ELSE
     l_inventory_location_id := l_physical_locator_id;
   END IF;

   /*
   ############# If the locator capacity is infinite, then dont update anything, simply return#############
   */
   SELECT location_maximum_units, max_weight, max_cubic_area
   INTO l_max_units, l_max_weight, l_max_cubic_area
   FROM mtl_item_locations_kfv
   WHERE organization_id        = p_organization_id
     AND inventory_location_id  = l_inventory_location_id;

   IF l_max_units IS NULL AND l_max_weight IS NULL AND l_max_cubic_area IS NULL THEN
        return;
   END IF;

   -- Bug# 3067627
   IF (l_debug = 1) THEN
      mdebug('Before locking locator ' || l_inventory_location_id || ' in update_loc_curr_capacity_nauto');
   END IF;

   SELECT inventory_location_id INTO l_inventory_location_id
   FROM mtl_item_locations
   WHERE  inventory_location_id = l_inventory_location_id
       and organization_id = p_organization_id
   FOR UPDATE NOWAIT;

   IF (l_debug = 1) THEN
      mdebug('After locking locator ' || l_inventory_location_id || ' in update_loc_curr_capacity_nauto');
   END IF;

   -- ensure that the input quantity (p_quantity) is always positive regardless whether
   -- issue or receipt
   l_quantity :=Abs(p_quantity);

   -- select necessary data from mtl_system_items and mtl_item_locations
   select
     primary_uom_code,
     weight_uom_code,
     unit_weight,
     volume_uom_code,
     unit_volume
   into
     l_item_primary_uom_code,
     l_item_weight_uom_code,
     l_item_unit_weight,
     l_item_volume_uom_code,
     l_item_unit_volume
   from mtl_system_items
   where organization_id 	= p_organization_id
   and   inventory_item_id 	= p_inventory_item_id;

   select
     location_maximum_units,
     location_current_units,
     location_suggested_units,
     location_available_units,
     location_weight_uom_code,
     max_weight,
     current_weight,
     suggested_weight,
     available_weight,
     volume_uom_code,
     max_cubic_area,
     current_cubic_area,
     suggested_cubic_area,
     available_cubic_area
   into
     l_max_units,
     l_current_units,
     l_suggested_units,
     l_available_units,
     l_location_weight_uom_code,
     l_max_weight,
     l_current_weight,
     l_suggested_weight,
     l_available_weight,
     l_volume_uom_code,
     l_max_cubic_area,
     l_current_cubic_area,
     l_suggested_cubic_area,
     l_available_cubic_area
     from mtl_item_locations
     where organization_id 	= p_organization_id
     and   inventory_location_id 	= l_inventory_location_id;

   IF (l_debug = 1) THEN
      mdebug('After select: p_organization_id: '|| p_organization_id);
      mdebug('After select: p_inventory_item_id: '|| p_inventory_item_id);
      mdebug('After select: p_inventory_location_id: '|| l_inventory_location_id);
      mdebug('After select: l_current_units: '|| l_current_units);
      mdebug('After select: l_max_units: '|| l_max_units);
   END IF;

   -- Convert transaction quantity into primary quantity (l_primary_quantity) if needed
   -- Note: the p_primary_uom_flag is used when the transaction_uom is not known during
   -- running of the upgrade script
   IF (l_item_primary_uom_code <> p_transaction_uom_code)
     and (p_primary_uom_flag <> 'Y') then

	l_primary_quantity :=
		inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_quantity,
					    from_unit	  => p_transaction_uom_code,
					    to_unit	  => l_item_primary_uom_code,
					    from_name	  => null,
					    to_name	  => null);
   ELSE
      l_primary_quantity := l_quantity;
   END IF;
    IF (l_debug = 1) THEN
       mdebug('l_primary_quantity: '|| l_primary_quantity);
    END IF;

  -- if have enough info, set update_weight flag to true:
  -- convert transacted item weight to transacted location weight (if necessary)
  -- and set l_update_weight flag to TRUE
  IF (l_item_unit_weight > 0 and
      l_item_weight_uom_code is not null and
      l_location_weight_uom_code is not NULL) then


	l_transacted_weight := l_primary_quantity * l_item_unit_weight;

	IF (l_item_weight_uom_code <> l_location_weight_uom_code) then
	   l_loc_uom_xacted_weight :=
		  inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_transacted_weight,
					    from_unit	  => l_item_weight_uom_code,
					    to_unit	  => l_location_weight_uom_code,
					    from_name	  => null,
					    to_name	  => null) ;
	ELSE
	   l_loc_uom_xacted_weight := l_transacted_weight;
	END IF;

	l_update_weight := TRUE;
  END IF;

  --  if have enough info, set update_volume flag to true:
  --  convert transacted item volume to transacted location volume (if necessary)
  --  and set l_update_volume flag to TRUE
  IF (l_item_unit_volume > 0 and
      l_item_volume_uom_code is not null and
      l_volume_uom_code is not NULL) then


	l_transacted_volume := l_primary_quantity * l_item_unit_volume;
	IF (l_item_volume_uom_code <> l_volume_uom_code) then
	   l_loc_uom_xacted_volume :=
		  inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_transacted_volume,
					    from_unit	  => l_item_volume_uom_code,
					    to_unit	  => l_volume_uom_code,
					    from_name	  => null,
					    to_name	  => null);
	ELSE
	   l_loc_uom_xacted_volume := l_transacted_volume;
	END IF;

	l_update_volume := TRUE;
  END IF;

  -- update current weight
  IF (l_update_weight) then
     -- check that current_weight and suggested weight are not null or < 0
     -- if current_weight is null, drive current_weight to zero
     IF (l_current_weight IS NULL) OR (l_current_weight < 0) then
	l_current_weight := 0;
     END IF;
     -- if suggested_weight is negative or null, set l_suggested_weight to zero
     IF (l_suggested_weight IS NULL) OR (l_suggested_weight < 0) then
	l_suggested_weight := 0;
     END IF;

     -- if receipt (put into location), update current_weight
     -- we have checked that current_weight an xacted_weight > 0
     IF (Upper(p_issue_flag) = 'N') THEN
	l_upd_loc_current_weight := l_current_weight + l_loc_uom_xacted_weight;
	-- if max not defined, let available_weight be undefined
	-- assume that max_weight > 0 (the form takes care of this)
	IF (l_max_weight IS NULL) THEN
	   l_upd_loc_available_weight :=  NULL;
	 ELSE
	   -- update available weight, and make sure that it is > 0
	   l_upd_loc_available_weight := l_max_weight
	     - (l_upd_loc_current_weight + l_suggested_weight);
	   IF (l_upd_loc_available_weight < 0) THEN
	      l_upd_loc_available_weight := 0;
	   END IF;
	END IF;

	-- if issue: p_issue='Y' (take out of location)
      ELSIF (Upper(p_issue_flag) = 'Y') THEN
	-- update current weight
	l_upd_loc_current_weight := l_current_weight - l_loc_uom_xacted_weight;
	 -- update current_ weight, and make sure that it is > 0
	IF (l_upd_loc_current_weight < 0) THEN
	   l_upd_loc_current_weight := 0;
	END IF;
	-- if max not defined, let available_weight be undefined
	-- assume that max_weight > 0 (the form takes care of this)
	IF (l_max_weight IS NULL) THEN
	   l_upd_loc_available_weight :=  NULL;
	 ELSE
	   -- update available weight, and make sure that it is > 0
	   l_upd_loc_available_weight := l_max_weight
	     -  (l_upd_loc_current_weight + l_suggested_weight);
	   IF (l_upd_loc_available_weight < 0) THEN
	      l_upd_loc_available_weight := 0;
	   END IF;
	END IF;
	-- if p_issue_flag neither Y/N, raise error
      ELSE
	fnd_message.set_name('INV', 'INV_FIELD_INVALID');
	fnd_msg_pub.ADD;
	RAISE fnd_api.g_exc_error;
     END IF;
     -- if not updating weight, then just propagate current_weight to updated_weight.
   ELSE
     l_upd_loc_current_weight := l_current_weight;
     l_upd_loc_available_weight := l_available_weight;
  END IF;

   -- update current volume
  IF (l_update_volume) then
     -- check that current_volume and suggested volume are not null or < 0
     -- if current_volume is null, drive current_volume to zero
     IF (l_current_cubic_area IS NULL) OR (l_current_cubic_area < 0) then
	l_current_cubic_area := 0;
     END IF;
     -- if suggested_volume is negative or null, set l_suggested_volume to zero
     IF (l_suggested_cubic_area IS NULL) OR (l_suggested_cubic_area < 0) then
	l_suggested_cubic_area := 0;
     END IF;

     -- if receipt (put into location), update current_volume
     IF (Upper(p_issue_flag) = 'N') THEN
	l_upd_loc_current_volume := l_current_cubic_area + l_loc_uom_xacted_volume;
	-- if max not defined, let available_volume be undefined
	-- assume that max_volume > 0 (the form takes care of this)
	IF (l_max_cubic_area IS NULL) THEN
	   l_upd_loc_available_volume :=  NULL;
	 ELSE
	   -- update available volume, and make sure that it is > 0
	   l_upd_loc_available_volume := l_max_cubic_area
	     - (l_upd_loc_current_volume + l_suggested_cubic_area);
	   IF (l_upd_loc_available_volume < 0) THEN
	      l_upd_loc_available_volume := 0;
	   END IF;
	END IF;

	-- if issue: p_issue='Y' (take out of location)
      ELSIF (Upper(p_issue_flag) = 'Y') THEN
	-- update current volume
	l_upd_loc_current_volume := l_current_cubic_area - l_loc_uom_xacted_volume;
	-- update current_volume, and make sure that it is > 0
	IF (l_upd_loc_current_volume < 0) THEN
	   l_upd_loc_current_volume := 0;
	END IF;
	-- if max not defined, let available_volume be undefined
	-- assume that max_volume > 0 (the form takes care of this)
	IF (l_max_cubic_area IS NULL) THEN
	   l_upd_loc_available_volume :=  NULL;
	 ELSE
	   -- update available volume, and make sure that it is > 0
	   l_upd_loc_available_volume := l_max_cubic_area
	     - (l_upd_loc_current_volume + l_suggested_cubic_area);
	   IF (l_upd_loc_available_volume < 0) THEN
	      l_upd_loc_available_volume := 0;
	   END IF;
	END IF;
      ELSE
	fnd_message.set_name('WMS', 'Invalid input to p_issue_flag (receipt/issue)');
	fnd_msg_pub.ADD;
	RAISE fnd_api.g_exc_error;

     END IF;
   ELSE
     l_upd_loc_current_volume := l_current_cubic_area;
     l_upd_loc_available_volume := l_available_cubic_area;
  END IF;

 -- update current units
  IF (l_update_units) then
     -- check that current_units and suggested units are not null or < 0
     -- if current_units is null, drive current_units to zero
     IF (l_current_units IS NULL) OR (l_current_units < 0) then
	l_current_units := 0;
     END IF;
     -- if suggested_units is negative or null, set l_suggested_units to zero
     IF (l_suggested_units IS NULL) OR (l_suggested_units < 0) then
	l_suggested_units := 0;
     END IF;
     IF (l_debug = 1) THEN
        mdebug('l_current_units: '|| l_current_units);
     END IF;
     -- if receipt (put into location), update current_units
     IF (Upper(p_issue_flag) = 'N') THEN
	l_upd_loc_current_units := l_current_units + l_primary_quantity;
	-- if max not defined, let available_units be undefined
	-- assume that max_units > 0 (the form takes care of this)
	IF (l_max_units IS NULL) THEN
	   l_upd_loc_available_units :=  NULL;
	 ELSE
	   -- update available units, and make sure that it is > 0
	   l_upd_loc_available_units := l_max_units
	     - (l_upd_loc_current_units + l_suggested_units);
	   IF (l_upd_loc_available_units < 0) THEN
	      l_upd_loc_available_units := 0;
	   END IF;
	END IF;
	-- if issue: p_issue='Y' (take out of location)
      ELSIF (Upper(p_issue_flag) = 'Y') THEN
	-- update current units
	l_upd_loc_current_units := l_current_units - l_primary_quantity;
	-- update current_units, and make sure that it is > 0
	IF (l_upd_loc_current_units < 0) THEN
	   l_upd_loc_current_units := 0;
	END IF;
	-- if max not defined, let available_units be undefined
	-- assume that max_units > 0 (the form takes care of this)
	IF (l_max_units IS NULL) THEN
	   l_upd_loc_available_units :=  NULL;
	 ELSE
	   -- update available units, and make sure that it is > 0
	   l_upd_loc_available_units := l_max_units
	     -  (l_upd_loc_current_units + l_suggested_units);
	   IF (l_upd_loc_available_units < 0) THEN
	      l_upd_loc_available_units := 0;
	   END IF;
	END IF;
	-- if p_issue_flag neither Y/N, raise error
      ELSE
	fnd_message.set_name('WMS', 'Invalid input to p_issue_flag (receipt/issue)');
	fnd_msg_pub.ADD;
	RAISE fnd_api.g_exc_error;
     END IF;
   ELSE
     l_upd_loc_current_units := l_current_units;
     l_upd_loc_available_units := l_available_units;
  END IF;
  IF (l_debug = 1) THEN
     mdebug('l_upd_loc_current_units: '|| l_upd_loc_current_units);
  END IF;
  -- Now we update the table MTL_ITEM_LOCATIONS
  IF (l_update_weight) OR (l_update_volume) OR (l_update_units) THEN
     UPDATE mtl_item_locations
       SET
       location_current_units 	        = l_upd_loc_current_units,
       location_available_units 	= l_upd_loc_available_units,
       current_weight             	= l_upd_loc_current_weight,
       available_weight		        = l_upd_loc_available_weight,
       current_cubic_area		= l_upd_loc_current_volume,
       available_cubic_area 		= l_upd_loc_available_volume
       where   inventory_location_id = l_inventory_location_id
       and     organization_id           = p_organization_id;
  END IF;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'update_loc_curr_capacity_nauto'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END update_loc_curr_capacity_nauto;

-- This API updates the current volume, weight and units capacity of a locator when items are
-- issued or received in the locator
-- An autonomous commit is performed in the end
PROCEDURE update_loc_current_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER,   -- identifier of locator
    p_inventory_item_id         IN  NUMBER,   -- identifier of item
    p_primary_uom_flag          IN  VARCHAR2, -- 'Y' - transaction was in item's primary UOM
					      -- 'N' - transaction was NOT in item's primary UOM
					      --       or the information is not known
    p_transaction_uom_code      IN  VARCHAR2, -- UOM of the transacted material that causes the
					      -- locator capacity to get updated
    p_quantity                  IN  NUMBER,   -- transaction quantity in p_transaction_uom_code
    p_issue_flag                IN  VARCHAR2  -- 'Y' - Issue transaction
					      -- 'N' - Receipt transaction
  )
IS
     -- this whole function is an autonomous commit
     PRAGMA autonomous_transaction;

     l_return_status            varchar2(1);
     l_msg_count                number;
     l_msg_data                 varchar2(1000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  inv_loc_wms_utils.update_loc_curr_capacity_nauto
  ( x_return_status             => l_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data,
    p_organization_id           => p_organization_id,
    p_inventory_location_id     => p_inventory_location_id,
    p_inventory_item_id         => p_inventory_item_id,
    p_primary_uom_flag          => p_primary_uom_flag,
    p_transaction_uom_code      => p_transaction_uom_code,
    p_quantity                  => p_quantity,
    p_issue_flag                => p_issue_flag);

  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
		RAISE fnd_api.g_exc_error;
	    ELSE
		RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
  END IF;

  -- end of autonomous commit
  COMMIT;
EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'update_loc_current_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END update_loc_current_capacity;


-- This API updates the suggested volume, weight and units capacity of a locator when
-- drop off locator is suggested.
-- THIS API DOES NOT UPDATE EMPTY FLAG OF THE LOCATOR.

PROCEDURE update_loc_sugg_cap_wo_empf
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER,   -- identifier of locator
    p_inventory_item_id         IN  NUMBER,   -- identifier of item
    p_primary_uom_flag          IN  VARCHAR2, -- 'Y' - transaction was in item's primary UOM
					      -- 'N' - transaction was NOT in item's primary UOM
					      --       or the information is not known
    p_transaction_uom_code      IN  VARCHAR2, -- UOM of the transacted material that causes the
					      -- locator capacity to get updated
    p_quantity                  IN  NUMBER   -- transaction quantity in p_transaction_uom_code

  )
IS
     -- this whole function is an autonomous commit
     PRAGMA autonomous_transaction;

     l_return_status            varchar2(1);
     l_msg_count                number;
     l_msg_data                 varchar2(1000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  inv_loc_wms_utils.update_loc_sugg_capacity_nauto
  ( x_return_status             => l_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data,
    p_organization_id           => p_organization_id,
    p_inventory_location_id     => p_inventory_location_id,
    p_inventory_item_id         => p_inventory_item_id,
    p_primary_uom_flag          => p_primary_uom_flag,
    p_transaction_uom_code      => p_transaction_uom_code,
    p_quantity                  => p_quantity
  );

  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
		RAISE fnd_api.g_exc_error;
	    ELSE
		RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
  END IF;

  -- end of autonomous commit;
  COMMIT;
EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'update_loc_suggested_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END update_loc_sugg_cap_wo_empf;




-- This API updates the suggested volume, weight and units capacity of a locator when items are
--  received in the locator.  Suggestions are only receipt suggestions.
PROCEDURE update_loc_sugg_capacity_nauto
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER,   -- identifier of locator
    p_inventory_item_id         IN  NUMBER,   -- identifier of item
    p_primary_uom_flag          IN  VARCHAR2, -- 'Y' - transaction was in item's primary UOM
					      -- 'N' - transaction was NOT in item's primary UOM
					      --       or the information is not known
    p_transaction_uom_code      IN  VARCHAR2, -- UOM of the transacted material that causes the
					      -- locator capacity to get updated
    p_quantity                  IN  NUMBER   -- transaction quantity in p_transaction_uom_code

  )
  IS
     -- item attributes
     l_item_primary_uom_code     varchar2(3);
     l_item_weight_uom_code 	 varchar2(3);
     l_item_unit_weight		 number;
     l_item_volume_uom_code	 varchar2(3);
     l_item_unit_volume		 number;
     -- transaction attributes
     l_quantity                  NUMBER;  -- local variable to check that p_quantity always > 0
     l_primary_quantity	         number;
     l_transacted_weight	 number;
     l_transacted_volume	 number;
     -- converted transaction attributes
     l_loc_uom_xacted_weight	 number;
     l_loc_uom_xacted_volume	 number;
     -- location attributes in units
     l_max_units       	         number;
     l_current_units	         number;
     l_suggested_units	         number;
     l_available_units	         number;
     -- location attributes in weight
     l_location_weight_uom_code	 varchar2(3);
     l_max_weight		 number;
     l_current_weight		 number;
     l_suggested_weight		 number;
     l_available_weight 	 number;
     -- location attributes in volume
     l_volume_uom_code		 varchar2(3);
     l_max_cubic_area		 number;
     l_current_cubic_area	 number;
     l_suggested_cubic_area	 number;
     l_available_cubic_area	 number;
     -- updated capacity
     l_update_units		 boolean := TRUE;  -- always update units
     l_update_weight		 boolean := FALSE; -- only update if have location and item UOMs
     l_update_volume		 boolean := FALSE; -- only update if have location and item UOMs
     -- updated location
     l_upd_loc_suggested_units	number;
     l_upd_loc_available_units	number;
     l_upd_loc_suggested_weight	number;
     l_upd_loc_available_weight	number;
     l_upd_loc_suggested_volume	number;
     l_upd_loc_available_volume	number;

     l_physical_locator_id             NUMBER;
     l_locator_id              NUMBER;
     l_inventory_location_id           NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mdebug('In update_loc_sugg_capacity_nauto');
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* If the locator has a physical_location_id
     then use the physical_location_id for further
     processing.Else we have to use the inventory_location_id
     for further processing
   */
   SELECT physical_location_id ,
	  inventory_location_id
   INTO l_physical_locator_id,
	l_locator_id
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id;

   IF l_physical_locator_id is null THEN
     l_inventory_location_id := l_locator_id;
   ELSE
     l_inventory_location_id := l_physical_locator_id;
   END IF;

   /*
   ############# If the locator capacity is infinite, then dont update anything, simply return#############
   */
   SELECT location_maximum_units, max_weight, max_cubic_area
   INTO l_max_units, l_max_weight, l_max_cubic_area
   FROM mtl_item_locations_kfv
   WHERE organization_id        = p_organization_id
     AND inventory_location_id  = l_inventory_location_id;

   IF l_max_units IS NULL AND l_max_weight IS NULL AND l_max_cubic_area IS NULL THEN
        return;
   END IF;

   -- Bug# 3067627
   IF (l_debug = 1) THEN
      mdebug('Before locking locator ' || l_inventory_location_id || ' in update_loc_sugg_capacity_nauto');
   END IF;

   SELECT inventory_location_id INTO l_inventory_location_id
   FROM mtl_item_locations
   WHERE  inventory_location_id = l_inventory_location_id
       and organization_id = p_organization_id
   FOR UPDATE NOWAIT;

   IF (l_debug = 1) THEN
      mdebug('After locking locator ' || l_inventory_location_id || ' in update_loc_sugg_capacity_nauto');
   END IF;

   -- ensure that the input quantity (p_quantity) is always positive regardless whether
   -- issue or receipt
   l_quantity :=Abs(p_quantity);
   -- select necessary data from mtl_system_items and mtl_item_locations
   select
     primary_uom_code,
     weight_uom_code,
     unit_weight,
     volume_uom_code,
     unit_volume
   into
     l_item_primary_uom_code,
     l_item_weight_uom_code,
     l_item_unit_weight,
     l_item_volume_uom_code,
     l_item_unit_volume
   from mtl_system_items
   where organization_id 	= p_organization_id
   and   inventory_item_id 	= p_inventory_item_id;

   select
     location_maximum_units,
     location_current_units,
     location_suggested_units,
     location_available_units,
     location_weight_uom_code,
     max_weight,
     current_weight,
     suggested_weight,
     available_weight,
     volume_uom_code,
     max_cubic_area,
     current_cubic_area,
     suggested_cubic_area,
     available_cubic_area
   into
     l_max_units,
     l_current_units,
     l_suggested_units,
     l_available_units,
     l_location_weight_uom_code,
     l_max_weight,
     l_current_weight,
     l_suggested_weight,
     l_available_weight,
     l_volume_uom_code,
     l_max_cubic_area,
     l_current_cubic_area,
     l_suggested_cubic_area,
     l_available_cubic_area
     from mtl_item_locations
     where organization_id 	= p_organization_id
     and   inventory_location_id 	= l_inventory_location_id;

   IF (l_debug = 1) THEN
      mdebug('After select: p_organization_id: '|| p_organization_id);
      mdebug('After select: p_inventory_item_id: '|| p_inventory_item_id);
      mdebug('After select: p_inventory_location_id: '|| l_inventory_location_id);
      mdebug('After select: l_suggested_units: '|| l_suggested_units);
      mdebug('After select: l_max_units: '|| l_max_units);
   END IF;

     -- Convert transaction quantity into primary quantity (l_primary_quantity) if needed
   -- Note: the p_primary_uom_flag is used when the transaction_uom is not known during
   -- running of the upgrade script
   IF (l_item_primary_uom_code <> p_transaction_uom_code)
     and (p_primary_uom_flag <> 'Y') then

	l_primary_quantity :=
		inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_quantity,
					    from_unit	  => p_transaction_uom_code,
					    to_unit	  => l_item_primary_uom_code,
					    from_name	  => null,
					    to_name	  => null);
   ELSE
      l_primary_quantity := l_quantity;
  END IF;

  IF (l_debug = 1) THEN
     mdebug ('l_primary_quantity: '||l_primary_quantity);
  END IF;
  -- if have enough info, set update_weight flag to true:
  -- convert transacted item weight to transacted location weight (if necessary)
  -- and set l_update_weight flag to TRUE
  IF (l_item_unit_weight > 0 and
      l_item_weight_uom_code is not null and
      l_location_weight_uom_code is not NULL) then

	l_transacted_weight := l_primary_quantity * l_item_unit_weight;

	IF (l_item_weight_uom_code <> l_location_weight_uom_code) then
	   l_loc_uom_xacted_weight :=
		  inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_transacted_weight,
					    from_unit	  => l_item_weight_uom_code,
					    to_unit	  => l_location_weight_uom_code,
					    from_name	  => null,
					    to_name	  => null) ;
	ELSE
	   l_loc_uom_xacted_weight := l_transacted_weight;
	END IF;

	l_update_weight := TRUE;
  END IF;

  --  if have enough info, set update_volume flag to true:
  --  convert transacted item volume to transacted location volume (if necessary)
  --  and set l_update_volume flag to TRUE
  IF (l_item_unit_volume > 0 and
      l_item_volume_uom_code is not null and
      l_volume_uom_code is not NULL) then


	l_transacted_volume := l_primary_quantity * l_item_unit_volume;
	-- make sure that transcated_volume > 0
	IF (l_item_volume_uom_code <> l_volume_uom_code) then
	   l_loc_uom_xacted_volume :=
		  inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_transacted_volume,
					    from_unit	  => l_item_volume_uom_code,
					    to_unit	  => l_volume_uom_code,
					    from_name	  => null,
					    to_name	  => null);
	ELSE
	   l_loc_uom_xacted_volume := l_transacted_volume;
	END IF;

	l_update_volume := TRUE;
  END IF;

  -- update suggested weight when receiving
  IF (l_update_weight) then
     -- check that current_weight and suggested weight are not null or < 0
     -- if current_weight is null, drive current_weight to zero
     IF (l_current_weight IS NULL) OR (l_current_weight < 0) then
	l_current_weight := 0;
     END IF;
     -- if suggested_weight is negative or null, set l_suggested_weight to zero
     IF (l_suggested_weight IS NULL) OR (l_suggested_weight < 0) then
	l_suggested_weight := 0;
     END IF;

     -- when receipt (put into location), update suggested_weight
     -- Note: All suggestions are receipt suggestions
     l_upd_loc_suggested_weight := l_suggested_weight + l_loc_uom_xacted_weight;
     -- if max not defined, let available_weight be undefined
     -- assume that max_weight > 0 (the Form takes care of this)
     IF (l_max_weight IS NULL) THEN
	l_upd_loc_available_weight :=  NULL;
      ELSE
	-- update available weight, and make sure that it is > 0
	l_upd_loc_available_weight := l_max_weight
	  - (l_upd_loc_suggested_weight + l_current_weight);
	IF (l_upd_loc_available_weight < 0) THEN
	   l_upd_loc_available_weight := 0;
	END IF;
     END IF;
   ELSE
     -- if weight not updated, just propagate current suggested weight
     l_upd_loc_suggested_weight := l_suggested_weight;
     l_upd_loc_available_weight := l_available_weight;
  END IF;

   -- update suggested volume; Note: volume = cubic area
  IF (l_update_volume) then
     -- check that current_volume and suggested volume are not null or < 0
     -- if current_volume is null, drive current_volume to zero
     IF (l_current_cubic_area IS NULL) OR (l_current_cubic_area < 0) then
	l_current_cubic_area := 0;
     END IF;
     -- if suggested_volume is negative or null, set l_suggested_volume to zero
     IF (l_suggested_cubic_area IS NULL) OR (l_suggested_cubic_area < 0) then
	l_suggested_cubic_area := 0;
     END IF;

     -- when receipt (put into location)
     -- Note: All suggestions are receipt suggestions
     l_upd_loc_suggested_volume := l_suggested_cubic_area + l_loc_uom_xacted_volume;
     -- if max not defined, let available_volume be undefined
     -- assume that max_volume > 0 (the Form takes care of this)
     IF (l_max_cubic_area IS NULL) THEN
	l_upd_loc_available_volume :=  NULL;
      ELSE
	-- update available volume, and make sure that it is > 0
	l_upd_loc_available_volume := l_max_cubic_area
	  - (l_upd_loc_suggested_volume + l_current_cubic_area);
	IF (l_upd_loc_available_volume < 0) THEN
	   l_upd_loc_available_volume := 0;
	END IF;
     END IF;
   ELSE
     -- if volume not updated, just propagate current suggested volume
     l_upd_loc_suggested_volume := l_suggested_cubic_area;
     l_upd_loc_available_volume := l_available_cubic_area;
  END IF;

 -- update current units
  IF (l_update_units) then
    -- check that current_units and suggested units are not null or < 0
     -- if current_units is null, drive current_units to zero
     IF (l_current_units IS NULL) OR (l_current_units < 0) then
	l_current_units := 0;
     END IF;
     -- if suggested_units is negative or null, set l_suggested_units to zero
     IF (l_suggested_units IS NULL) OR (l_suggested_units < 0) then
	l_suggested_units := 0;
     END IF;

     -- when receipt (put into location), update suggested_units
     -- Note: All suggestions are receipt suggestions
     l_upd_loc_suggested_units := l_suggested_units + l_primary_quantity;
     -- if max not defined, let available_units be undefined
     -- assume that max_units > 0 (the Form takes care of this)
     IF (l_max_units IS NULL) THEN
	l_upd_loc_available_units :=  NULL;
      ELSE
	-- update available units, and make sure that it is > 0
	l_upd_loc_available_units := l_max_units
	  - (l_upd_loc_suggested_units + l_current_units);
	IF (l_upd_loc_available_units < 0) THEN
	   l_upd_loc_available_units := 0;
	END IF;
     END IF;
   ELSE
     -- if units not updated, just propagate current suggested units
     l_upd_loc_suggested_units := l_suggested_units;
     l_upd_loc_available_units := l_available_units;
  END IF;

  IF (l_debug = 1) THEN
     mdebug('l_upd_loc_suggested_units: '|| l_upd_loc_suggested_units);
  END IF;
  -- Now we update the table MTL_ITEM_LOCATIONS
  IF (l_update_weight) OR (l_update_volume) OR (l_update_units) THEN
     UPDATE mtl_item_locations
       SET
       location_suggested_units 	= l_upd_loc_suggested_units,
       location_available_units 	= l_upd_loc_available_units,
       suggested_weight             	= l_upd_loc_suggested_weight,
       available_weight		        = l_upd_loc_available_weight,
       suggested_cubic_area		= l_upd_loc_suggested_volume,
       available_cubic_area 		= l_upd_loc_available_volume
       where inventory_location_id = l_inventory_location_id
       and     organization_id           = p_organization_id;
  END IF;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'update_loc_sugg_capacity_nauto'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END update_loc_sugg_capacity_nauto;

-- This API updates the suggested volume, weight and units capacity of a locator when items are
-- received in the locator.  Suggestions are only receipt suggestions.
-- An autonomous commit is done in the end.
PROCEDURE update_loc_suggested_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER,   -- identifier of locator
    p_inventory_item_id         IN  NUMBER,   -- identifier of item
    p_primary_uom_flag          IN  VARCHAR2, -- 'Y' - transaction was in item's primary UOM
					      -- 'N' - transaction was NOT in item's primary UOM
					      --       or the information is not known
    p_transaction_uom_code      IN  VARCHAR2, -- UOM of the transacted material that causes the
					      -- locator capacity to get updated
    p_quantity                  IN  NUMBER   -- transaction quantity in p_transaction_uom_code

  )
IS
     -- this whole function is an autonomous commit
     PRAGMA autonomous_transaction;

     l_return_status            varchar2(1);
     l_msg_count                number;
     l_msg_data                 varchar2(1000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  inv_loc_wms_utils.update_loc_sugg_capacity_nauto
  ( x_return_status             => l_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data,
    p_organization_id           => p_organization_id,
    p_inventory_location_id     => p_inventory_location_id,
    p_inventory_item_id         => p_inventory_item_id,
    p_primary_uom_flag          => p_primary_uom_flag,
    p_transaction_uom_code      => p_transaction_uom_code,
    p_quantity                  => p_quantity
  );

  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
		RAISE fnd_api.g_exc_error;
	    ELSE
		RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
  END IF;

  -- Update empty_flag, mixed_item_flag. Pass transaction action of receipt
  -- regardless of whether suggestion is receipt or transfer

  INV_LOC_WMS_UTILS.LOC_EMPTY_MIXED_FLAG (
    X_RETURN_STATUS 		=> l_return_status
  , X_MSG_COUNT     		=> x_msg_count
  , X_MSG_DATA      		=> x_msg_data
  , p_organization_id           => p_organization_id
  , p_inventory_location_id     => p_inventory_location_id
  , p_inventory_item_id         => p_inventory_item_id
  , P_TRANSACTION_ACTION_ID  	=> 27
  , P_TRANSFER_ORGANIZATION  	=> NULL
  , P_TRANSFER_LOCATION_ID   	=> NULL
  , P_SOURCE                 	=> null);

  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
		RAISE fnd_api.g_exc_error;
	    ELSE
		RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
  END IF;

  -- end of autonomous commit;
  COMMIT;
EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'update_loc_suggested_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END update_loc_suggested_capacity;

-- This API reverts the updates of the suggested  volume, weight and units capacity of a locator
-- when an error in suggested receipt happens.
-- In other words, this API can be considered as issue suggestions (opposite of receipt suggestions)
PROCEDURE revert_loc_suggested_cap_nauto
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER,   -- identifier of locator
    p_inventory_item_id         IN  NUMBER,   -- identifier of item
    p_primary_uom_flag          IN  VARCHAR2, -- 'Y' - transaction was in item's primary UOM
					      -- 'N' - transaction was NOT in item's primary UOM
					      --       or the information is not known
    p_transaction_uom_code      IN  VARCHAR2, -- UOM of the transacted material that causes the
					      -- locator capacity to get updated
					      -- Note: can be NULL if p_primary_uom_flag = 'Y'
    p_quantity                  IN  NUMBER,    -- transaction quantity in p_transaction_uom_code
    p_content_lpn_id            IN  NUMBER   DEFAULT NUlL --bug#9159019 FPing fix for #8944467
  )
  IS

     -- item attributes
     l_item_primary_uom_code     varchar2(3);
     l_item_weight_uom_code 	 varchar2(3);
     l_item_unit_weight		 number;
     l_item_volume_uom_code	 varchar2(3);
     l_item_unit_volume		 number;
     -- transaction attributes
     l_quantity                  NUMBER;  -- local variable to check that p_quantity always > 0
     l_primary_quantity	         number;
     l_transacted_weight	 number;
     l_transacted_volume	 number;
     -- converted transaction attributes
     l_loc_uom_xacted_weight	 number;
     l_loc_uom_xacted_volume	 number;
     -- location attributes in units
     l_max_units       	         number;
     l_current_units	         number;
     l_suggested_units	         number;
     l_available_units	         number;
     -- location attributes in weight
     l_location_weight_uom_code	 varchar2(3);
     l_max_weight		 number;
     l_current_weight		 number;
     l_suggested_weight		 number;
     l_available_weight 	 number;
     -- location attributes in volume
     l_volume_uom_code		 varchar2(3);
     l_max_cubic_area		 number;
     l_current_cubic_area	 number;
     l_suggested_cubic_area	 number;
     l_available_cubic_area	 number;
     -- updated capacity
     l_update_units		 boolean := TRUE;  -- always update units
     l_update_weight		 boolean := FALSE; -- only update if have location and item UOMs
     l_update_volume		 boolean := FALSE; -- only update if have location and item UOMs
     -- updated location
     l_upd_loc_suggested_units	number;
     l_upd_loc_available_units	number;
     l_upd_loc_suggested_weight	number;
     l_upd_loc_available_weight	number;
     l_upd_loc_suggested_volume	number;
     l_upd_loc_available_volume	number;

     l_physical_locator_id     NUMBER;
     l_locator_id              NUMBER;
     l_inventory_location_id   NUMBER;

     l_return_status           varchar2(1);

     l_loc_counter 	      NUMBER := 10000;
     l_locator_locked         BOOLEAN := TRUE;
     l_source                 VARCHAR2(10) := NULL;
     resource_busy_detected   EXCEPTION;

     PRAGMA EXCEPTION_INIT(resource_busy_detected, -54);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SAVEPOINT revert_loc_suggested_cap_sp;--BUG 4890372

   IF (l_debug=1) THEN
      mdebug('Inside Procedure Revert Suggested Locator Capacity');
   END IF;
  /* If the locator has a physical_location_id
     then use the physical_location_id for further
     processing.Else we have to use the inventory_location_id
     for further processing
   */
   SELECT physical_location_id ,
	  inventory_location_id
   INTO l_physical_locator_id,
	l_locator_id
   FROM mtl_item_locations
   WHERE  inventory_location_id =p_inventory_location_id
       and organization_id = p_organization_id;

   IF l_physical_locator_id is null THEN
     l_inventory_location_id := l_locator_id;
   ELSE
     l_inventory_location_id := l_physical_locator_id;
   END IF;

   /*
   ############# If the locator capacity is infinite, then dont update anything, simply return#############
   */
   SELECT location_maximum_units, max_weight, max_cubic_area
   INTO l_max_units, l_max_weight, l_max_cubic_area
   FROM mtl_item_locations_kfv
   WHERE organization_id        = p_organization_id
     AND inventory_location_id  = l_inventory_location_id;

   IF l_max_units IS NULL AND l_max_weight IS NULL AND l_max_cubic_area IS NULL THEN
      IF (l_debug = 1) THEN  --Bug 8603740
	mdebug('Locator has infinite capcity, but we need to update emppty_flag and mixed_flag');
      END IF;
      l_source := 'INFINITE'; --8588344
      GOTO UPDATE_EMPTY_MIXED_FLAG;
   END IF;

   -- Bug# 3067627
   IF (l_debug = 1) THEN
      mdebug('Before locking locator ' || l_inventory_location_id || ' in revert_loc_suggested_capacity');
   END IF;

   WHILE ((l_loc_counter > 0) and (l_locator_locked))
   LOOP
      BEGIN

         SELECT inventory_location_id INTO l_inventory_location_id
         FROM mtl_item_locations
         WHERE  inventory_location_id = l_inventory_location_id
         AND    organization_id = p_organization_id
         FOR UPDATE NOWAIT;

         IF (l_debug = 1) THEN
            mdebug('After locking locator ' || l_inventory_location_id || ' in revert_loc_suggested_capacity');
         END IF;
         l_locator_locked := FALSE;


       EXCEPTION
           WHEN resource_busy_detected THEN
               l_loc_counter := l_loc_counter - 1;
               IF (l_loc_counter = 0) THEN
                   mdebug('exception ora-00054 ' || ' in revert_loc_suggested_capacity');
                   x_msg_count := 1;
                   x_msg_data  := sqlerrm;
                   RAISE;
               ELSE
                  IF (l_debug = 1) THEN
                      mdebug('locking locator - Attempt:  ' || 10001-l_loc_counter || ' in revert_loc_suggested_capacity');
                  END IF;
               END IF;
           WHEN OTHERS THEN
               RAISE fnd_api.g_exc_unexpected_error;
       END;
   END LOOP;



   -- ensure that the input quantity (p_quantity) is always positive regardless whether
   -- issue or receipt
   l_quantity :=Abs(p_quantity);
   -- select necessary data from mtl_system_items and mtl_item_locations
   select
     primary_uom_code,
     weight_uom_code,
     unit_weight,
     volume_uom_code,
     unit_volume
   into
     l_item_primary_uom_code,
     l_item_weight_uom_code,
     l_item_unit_weight,
     l_item_volume_uom_code,
     l_item_unit_volume
   from mtl_system_items
   where organization_id 	= p_organization_id
   and   inventory_item_id 	= p_inventory_item_id;

   select
     location_maximum_units,
     location_current_units,
     location_suggested_units,
     location_available_units,
     location_weight_uom_code,
     max_weight,
     current_weight,
     suggested_weight,
     available_weight,
     volume_uom_code,
     max_cubic_area,
     current_cubic_area,
     suggested_cubic_area,
     available_cubic_area
   into
     l_max_units,
     l_current_units,
     l_suggested_units,
     l_available_units,
     l_location_weight_uom_code,
     l_max_weight,
     l_current_weight,
     l_suggested_weight,
     l_available_weight,
     l_volume_uom_code,
     l_max_cubic_area,
     l_current_cubic_area,
     l_suggested_cubic_area,
     l_available_cubic_area
     from mtl_item_locations
     where organization_id 	= p_organization_id
     and   inventory_location_id 	= l_inventory_location_id;

   -- Convert transaction quantity into primary quantity (l_primary_quantity) if needed
   -- Note: the p_primary_uom_flag is used when the transaction_uom is not known during
   -- running of the upgrade script
   IF (l_item_primary_uom_code <> p_transaction_uom_code)
     and (p_primary_uom_flag <> 'Y') then

	l_primary_quantity :=
		inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_quantity,
					    from_unit	  => p_transaction_uom_code,
					    to_unit	  => l_item_primary_uom_code,
					    from_name	  => null,
					    to_name	  => null);
   ELSE
      l_primary_quantity := l_quantity;
  END IF;

  -- if have enough info, set update_weight flag to true:
  -- convert transacted item weight to transacted location weight (if necessary)
  -- and set l_update_weight flag to TRUE
  IF (l_item_unit_weight > 0 and
      l_item_weight_uom_code is not null and
      l_location_weight_uom_code is not NULL) then

	l_transacted_weight := l_primary_quantity * l_item_unit_weight;

	IF (l_item_weight_uom_code <> l_location_weight_uom_code) then
	   l_loc_uom_xacted_weight :=
		  inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_transacted_weight,
					    from_unit	  => l_item_weight_uom_code,
					    to_unit	  => l_location_weight_uom_code,
					    from_name	  => null,
					    to_name	  => null) ;
	ELSE
	   l_loc_uom_xacted_weight := l_transacted_weight;
	END IF;

	l_update_weight := TRUE;
  END IF;

  --  if have enough info, set update_volume flag to true:
  --  convert transacted item volume to transacted location volume (if necessary)
  --  and set l_update_volume flag to TRUE
  IF (l_item_unit_volume > 0 and
      l_item_volume_uom_code is not null and
      l_volume_uom_code is not NULL) then


	l_transacted_volume := l_primary_quantity * l_item_unit_volume;
	-- make sure that transcated_volume > 0
	IF (l_item_volume_uom_code <> l_volume_uom_code) then
	   l_loc_uom_xacted_volume :=
		  inv_convert.inv_um_convert( item_id 	  => p_inventory_item_id,
					    precision	  => null,
					    from_quantity => l_transacted_volume,
					    from_unit	  => l_item_volume_uom_code,
					    to_unit	  => l_volume_uom_code,
					    from_name	  => null,
					    to_name	  => null);
	ELSE
	   l_loc_uom_xacted_volume := l_transacted_volume;
	END IF;

	l_update_volume := TRUE;
  END IF;

  -- update suggested weight when issue
  IF (l_update_weight) then
     -- check that current_weight and suggested weight are not null or < 0
     -- if current_weight is null, drive current_weight to zero
     IF (l_current_weight IS NULL) OR (l_current_weight < 0) then
	l_current_weight := 0;
     END IF;
     -- if suggested_weight is negative or null, set l_suggested_weight to zero
     IF (l_suggested_weight IS NULL) OR (l_suggested_weight < 0) then
	l_suggested_weight := 0;
     END IF;

     -- when issue (take out of location), update suggested_weight
     -- Note: All suggestions are receipt suggestions, but this API is to correct
     -- an error in receipt.
     l_upd_loc_suggested_weight := l_suggested_weight - l_loc_uom_xacted_weight;
     -- update suggested_weight, and make sure that it is > 0
     IF (l_upd_loc_suggested_weight < 0) THEN
	l_upd_loc_suggested_weight := 0;
     END IF;
     -- if max not defined, let available_weight be undefined
     -- assume that max_weight > 0 (the Form takes care of this)
     IF (l_max_weight IS NULL) THEN
	l_upd_loc_available_weight :=  NULL;
      ELSE
	-- update available weight, and make sure that it is > 0
	l_upd_loc_available_weight := l_max_weight
	  - (l_upd_loc_suggested_weight + l_current_weight);
	IF (l_upd_loc_available_weight < 0) THEN
	   l_upd_loc_available_weight := 0;
	END IF;
     END IF;
   ELSE
     -- if weight not updated, just propagate current suggested weight
     l_upd_loc_suggested_weight := l_suggested_weight;
     l_upd_loc_available_weight := l_available_weight;
  END IF;

   -- update suggested volume; Note: volume = cubic area
  IF (l_update_volume) then
     -- check that current_volume and suggested volume are not null or < 0
     -- if current_volume is null, drive current_volume to zero
     IF (l_current_cubic_area IS NULL) OR (l_current_cubic_area < 0) then
	l_current_cubic_area := 0;
     END IF;
     -- if suggested_volume is negative or null, set l_suggested_volume to zero
     IF (l_suggested_cubic_area IS NULL) OR (l_suggested_cubic_area < 0) then
	l_suggested_cubic_area := 0;
     END IF;

     -- when issue (put into location)
     -- Note: All suggestions are receipt suggestions, but this API
     -- corrects an error in the receipt suggestion - hence an issue.
     l_upd_loc_suggested_volume := l_suggested_cubic_area - l_loc_uom_xacted_volume;
     -- update suggested_volume, and make sure that it is > 0
     IF (l_upd_loc_suggested_volume < 0) THEN
	l_upd_loc_suggested_volume := 0;
     END IF;
     -- if max not defined, let available_volume be undefined
     -- assume that max_volume > 0 (the Form takes care of this)
     IF (l_max_cubic_area IS NULL) THEN
	l_upd_loc_available_volume :=  NULL;
      ELSE
	-- update available volume, and make sure that it is > 0
	l_upd_loc_available_volume := l_max_cubic_area
	  - (l_upd_loc_suggested_volume + l_current_cubic_area);
	IF (l_upd_loc_available_volume < 0) THEN
	   l_upd_loc_available_volume := 0;
	END IF;
     END IF;
   ELSE
     -- if volume not updated, just propagate current suggested volume
     l_upd_loc_suggested_volume := l_suggested_cubic_area;
     l_upd_loc_available_volume := l_available_cubic_area;
  END IF;

 -- update current units
  IF (l_update_units) then
    -- check that current_units and suggested units are not null or < 0
     -- if current_units is null, drive current_units to zero
     IF (l_current_units IS NULL) OR (l_current_units < 0) then
	l_current_units := 0;
     END IF;
     -- if suggested_units is negative or null, set l_suggested_units to zero
     IF (l_suggested_units IS NULL) OR (l_suggested_units < 0) then
	l_suggested_units := 0;
     END IF;

     -- when issue (put into location), update suggested_units
     -- Note: All suggestions are receipt suggestions, but this API
     -- corrects error in receipt suggestions - hence, issue suggestions
     l_upd_loc_suggested_units := l_suggested_units - l_primary_quantity;
     -- update suggested_units, and make sure that it is > 0
     IF (l_upd_loc_suggested_units < 0) THEN
	l_upd_loc_suggested_units := 0;
     END IF;
     -- if max not defined, let available_units be undefined
     -- assume that max_units > 0 (the Form takes care of this)
     IF (l_max_units IS NULL) THEN
	l_upd_loc_available_units :=  NULL;
      ELSE
	-- update available units, and make sure that it is > 0
	l_upd_loc_available_units := l_max_units
	  - (l_upd_loc_suggested_units + l_current_units);
	IF (l_upd_loc_available_units < 0) THEN
	   l_upd_loc_available_units := 0;
	END IF;
     END IF;
   ELSE
     -- if units not updated, just propagate current suggested units
     l_upd_loc_suggested_units := l_suggested_units;
     l_upd_loc_available_units := l_available_units;
  END IF;

  -- Now we update the table MTL_ITEM_LOCATIONS
  IF (l_update_weight) OR (l_update_volume) OR (l_update_units) THEN
     UPDATE mtl_item_locations
       SET
       location_suggested_units 	= l_upd_loc_suggested_units,
       location_available_units 	= l_upd_loc_available_units,
       suggested_weight             	= l_upd_loc_suggested_weight,
       available_weight		        = l_upd_loc_available_weight,
       suggested_cubic_area		= l_upd_loc_suggested_volume,
       available_cubic_area 		= l_upd_loc_available_volume
       where inventory_location_id = l_inventory_location_id
       and   organization_id       = p_organization_id;
  END IF;

  <<UPDATE_EMPTY_MIXED_FLAG>>   --Bug 8603740
  -- Update empty_flag, mixed_item_flag. Pass transaction action of issue
--bug#9159019 FPing fix for #8944467 start
    IF (l_debug = 1) THEN
	mdebug('revert_loc_suggested_cap_nauto p_organization_id' ||p_organization_id);
	mdebug('revert_loc_suggested_cap_nauto l_inventory_location_id' ||l_inventory_location_id);
	mdebug('revert_loc_suggested_cap_nauto p_inventory_item_id'||p_inventory_item_id);
	mdebug('revert_loc_suggested_cap_nauto l_source' || l_source );
	mdebug('revert_loc_suggested_cap_nauto p_quantity' || p_quantity );
	mdebug('revert_loc_suggested_cap_nauto p_content_lpn_id' ||p_content_lpn_id );
    END IF;
	inv_loc_wms_utils.get_source_type( x_source => l_source ,
					p_locator_id => l_inventory_location_id,
					p_organization_id => p_organization_id,
					p_inventory_item_id=>p_inventory_item_id,
					p_content_lpn_id => p_content_lpn_id ,
					p_transaction_action_id => 1 ,
					p_primary_quantity => p_quantity );
    IF (l_debug = 1) THEN
         mdebug('revert_loc_suggested_cap_nauto  after executing inv_loc_wms_utils.get_source_type procedure l_source' || l_source);
    END IF;
--bug#9159019 FPing fix for #8944467 end

  INV_LOC_WMS_UTILS.LOC_EMPTY_MIXED_FLAG (
    X_RETURN_STATUS             => l_return_status
  , X_MSG_COUNT                 => x_msg_count
  , X_MSG_DATA                  => x_msg_data
  , p_organization_id           => p_organization_id
  , p_inventory_location_id     => l_inventory_location_id
  , p_inventory_item_id         => p_inventory_item_id
  , P_TRANSACTION_ACTION_ID     => 1
  , P_TRANSFER_ORGANIZATION     => NULL
  , P_TRANSFER_LOCATION_ID      => NULL
  , P_SOURCE                    => l_source);

  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE fnd_api.g_exc_error;
            ELSE
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
  END IF;


EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO revert_loc_suggested_cap_sp;--BUG 4890372
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO revert_loc_suggested_cap_sp;--BUG 4890372
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
     ROLLBACK TO revert_loc_suggested_cap_sp;--BUG 4890372
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN resource_busy_detected  THEN
     ROLLBACK TO revert_loc_suggested_cap_sp;--BUG 4890372
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      ROLLBACK TO revert_loc_suggested_cap_sp;--BUG 4890372
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , 'revert_loc_suggested_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END revert_loc_suggested_cap_nauto;

PROCEDURE revert_loc_suggested_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN  NUMBER,   -- identifier of locator
    p_inventory_item_id         IN  NUMBER,   -- identifier of item
    p_primary_uom_flag          IN  VARCHAR2, -- 'Y' - transaction was in item's primary UOM
					      -- 'N' - transaction was NOT in item's primary UOM
					      --       or the information is not known
    p_transaction_uom_code      IN  VARCHAR2, -- UOM of the transacted material that causes the
					      -- locator capacity to get updated
					      -- Note: can be NULL if p_primary_uom_flag = 'Y'
    p_quantity                  IN  NUMBER,    -- transaction quantity in p_transaction_uom_code
    p_content_lpn_id            IN  NUMBER DEFAULT NUlL --bug#9159019 FPing fix for #8944467
  )
  IS
	-- this whole function is an autonomous commit

     PRAGMA autonomous_transaction;
BEGIN
   revert_loc_suggested_cap_nauto
     (
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_organization_id => p_organization_id,
      p_inventory_location_id => p_inventory_location_id,
      p_inventory_item_id => p_inventory_item_id,
      p_primary_uom_flag => p_primary_uom_flag,
      p_transaction_uom_code => p_transaction_uom_code,
      p_quantity => p_quantity,
      p_content_lpn_id=>p_content_lpn_id --bug#9159019 FPing fix for #8944467
     );

   COMMIT;

END revert_loc_suggested_capacity;


PROCEDURE fetch_lpn_content_qty
   (
     p_lpn_id        IN          NUMBER
   , x_quantity      OUT NOCOPY  NUMBER
   )
IS
BEGIN
   SELECT nvl(sum(wlc.primary_quantity),0) /* Bug 5689378 */
     INTO x_quantity
     FROM wms_lpn_contents wlc
        , wms_license_plate_numbers wlpn
    WHERE wlc.parent_lpn_id = wlpn.lpn_id
      AND wlpn.outermost_lpn_id = p_lpn_id;
END fetch_lpn_content_qty;

PROCEDURE get_container_capacity
  (   x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , x_msg_data                  OUT NOCOPY VARCHAR2
    , p_locator_weight_uom        IN         VARCHAR2
    , p_locator_volume_uom        IN         VARCHAR2
    , p_lpn_id                    IN         NUMBER
    , p_organization_id           IN         NUMBER
    , x_container_item_wt         OUT NOCOPY NUMBER
    , x_container_item_vol        OUT NOCOPY NUMBER
    , x_lpn_gross_weight          OUT NOCOPY NUMBER
    , x_lpn_content_vol           OUT NOCOPY NUMBER
  )
IS
   l_lpn_gross_weight_uom_code   VARCHAR2(3);
   l_lpn_content_volume_uom_code VARCHAR2(3);
   l_lpn_gross_weight            NUMBER;
   l_lpn_content_volume          NUMBER;
   l_lpn_container_item_weight   NUMBER;
   l_lpn_container_item_vol      NUMBER;
   l_dummy                       VARCHAR2(1);
   l_lpn_weight                  NUMBER   := 0;
   l_gross_weight                NUMBER   := 0;
   l_lpn_volume                  NUMBER   := 0;
   l_content_volume              NUMBER   := 0;
   l_prog_name                   VARCHAR2(40) := 'get_container_capacity';
BEGIN
   INV_LOC_WMS_UTILS.lpn_attributes(
     x_return_status            =>   x_return_status
   , x_msg_data                 =>   x_msg_data
   , x_msg_count                =>   x_msg_count
   , x_gross_weight_uom_code    =>   l_lpn_gross_weight_uom_code
   , x_content_volume_uom_code  =>   l_lpn_content_volume_uom_code
   , x_gross_weight             =>   l_lpn_gross_weight
   , x_content_volume           =>   l_lpn_content_volume
   , x_container_item_weight    =>   l_lpn_container_item_weight
   , x_container_item_vol       =>   l_lpn_container_item_vol
   , x_lpn_exists_in_locator    =>   l_dummy
   , p_lpn_id                   =>   p_lpn_id
   , p_org_id                   =>   p_organization_id
   );
   -- Compute gross Weight
   if ((p_locator_weight_uom is not null) and
       (l_lpn_gross_weight_uom_code is not NULL)) then

      l_gross_weight := nvl(l_lpn_gross_weight,0);
       if (l_lpn_gross_weight_uom_code <>
           p_locator_weight_uom) then

        l_gross_weight :=
          inv_convert.inv_um_convert(
            item_id       => NULL,
            precision     => null,
            from_quantity => nvl(l_lpn_gross_weight,0),
            from_unit     => l_lpn_gross_weight_uom_code,
            to_unit       => p_locator_weight_uom,
            from_name     => null,
            to_name       => null) ;
       end if;

       IF l_gross_weight = -99999 THEN
          RAISE fnd_api.g_exc_error;
       END IF;
   end if;

   -- Compute content Volume
   if ((p_locator_volume_uom is not null) and
       (l_lpn_content_volume_uom_code is not null)) then
       l_content_volume := nvl(l_lpn_content_volume,0);
       if (l_lpn_content_volume_uom_code <>
           p_locator_volume_uom) then

        l_content_volume :=
          inv_convert.inv_um_convert(
            item_id       => NULL,
            precision     => null,
            from_quantity => nvl(l_lpn_content_volume,0),
            from_unit     => l_lpn_content_volume_uom_code,
            to_unit       => p_locator_volume_uom,
            from_name     => null,
            to_name       => null) ;
       end if;

       IF l_content_volume = -99999 THEN
          RAISE fnd_api.g_exc_error;
       END IF;
   end if;

   -- Compute container Weight
   if ((p_locator_weight_uom is not null) and
       (l_lpn_gross_weight_uom_code is not NULL)) then
       l_lpn_weight := nvl(l_lpn_container_item_weight,0);
       if (l_lpn_gross_weight_uom_code <>
           p_locator_weight_uom) then

        l_lpn_weight :=
          inv_convert.inv_um_convert(
            item_id       => NULL,
            precision     => null,
            from_quantity => nvl(l_lpn_container_item_weight,0),
            from_unit     => l_lpn_gross_weight_uom_code,
            to_unit       => p_locator_weight_uom,
            from_name     => null,
            to_name       => null) ;
       end if;

       IF l_lpn_weight = -99999 THEN
          RAISE fnd_api.g_exc_error;
       END IF;
   end if;

   -- Compute container Volume
   if ((p_locator_volume_uom is not null) and
       (l_lpn_content_volume_uom_code is not null)) then
       l_lpn_volume := nvl(l_lpn_container_item_vol,0);
       if (l_lpn_content_volume_uom_code <>
           p_locator_volume_uom) then

        l_lpn_volume :=
          inv_convert.inv_um_convert(
            item_id       => NULL,
            precision     => null,
            from_quantity => nvl(l_lpn_container_item_vol,0),
            from_unit     => l_lpn_content_volume_uom_code,
            to_unit       => p_locator_volume_uom,
            from_name     => null,
            to_name       => null) ;
       end if;

       IF l_lpn_volume = -99999 THEN
          RAISE fnd_api.g_exc_error;
       END IF;
   end if;
   x_container_item_wt  := l_lpn_weight;
   x_container_item_vol := l_lpn_volume;
   x_lpn_gross_weight   := l_gross_weight;
   x_lpn_content_vol    := l_content_volume;
   mdebug(l_prog_name||'container wt  :'||x_container_item_wt);
   mdebug(l_prog_name||'container vol :'||x_container_item_vol);
EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name,
	      'get_container_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END get_container_capacity;



-- This is an upgrade script that updates the locator's current capacity information
-- corresponding to each onhand quantity (or mmtt) record

-- Modified the procedure algorithm to improve the performance for bug#8575319

PROCEDURE locators_capacity_cleanup
     (x_return_status     OUT NOCOPY VARCHAR2 -- return status
      ,x_msg_count        OUT NOCOPY NUMBER   -- number of messages in the message queue
      ,x_msg_data         OUT NOCOPY VARCHAR2 -- message text when x_msg_count>0
      ,p_organization_id  IN NUMBER
      ,p_mixed_flag       IN VARCHAR2
      ,p_subinventory     IN VARCHAR2 DEFAULT NULL
      ,p_locator_id       IN NUMBER DEFAULT NULL)
IS

  l_prog_name                  VARCHAR2(40) := 'locators_capacity_cleanup:';

  TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE t_varchar2 IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE t_varchar2_small IS TABLE OF VARCHAR2(4) INDEX BY BINARY_INTEGER;

  /* Item Cache */
  TYPE r_item_info IS RECORD(inventory_item_id NUMBER,
                              item_primary_uom_code VARCHAR2(10),
                              item_weight_uom_code VARCHAR2(10),
                              item_unit_weight NUMBER,
                              item_volume_uom_code VARCHAR2(10),
                              item_unit_volume NUMBER);

  TYPE t_item_info_type IS TABLE OF R_ITEM_INFO INDEX BY BINARY_INTEGER;

  t_item_info                  T_ITEM_INFO_TYPE;


  /* LPN Cache */
  TYPE r_lpn_info IS RECORD(lpn_id NUMBER,
                             gross_weight_uom_code VARCHAR2(3),
                             content_volume_uom_code VARCHAR2(3),
                             gross_weight NUMBER := 0,
                             content_volume NUMBER := 0,
                             container_item_weight NUMBER := 0,
                             container_item_vol NUMBER := 0,
                             lpn_exists_in_locator VARCHAR2(1) := 'N',
                             lpn_already_considered VARCHAR2(1) := 'N');

  TYPE t_lpn_info_type IS TABLE OF R_LPN_INFO INDEX BY BINARY_INTEGER;

  t_lpn_info                   T_LPN_INFO_TYPE;


  /* Item Locator Cache - number of units of item in locator */
  TYPE r_item_units IS RECORD(inventory_item_id NUMBER,
                               location_current_units NUMBER,
                               location_suggested_units NUMBER);

  TYPE t_item_units_type IS TABLE OF R_ITEM_UNITS INDEX BY BINARY_INTEGER;

  t_item_units                 T_ITEM_UNITS_TYPE;


  /* Locator CACHE */
  t_locator                    T_NUMBER;
  t_location_weight_uom_code   T_VARCHAR2;
  t_volume_uom_code            T_VARCHAR2;
  t_location_maximum_units     T_NUMBER;
  t_max_weight                 T_NUMBER;
  t_max_cubic_area             T_NUMBER;
  t_location_current_units     T_NUMBER;
  t_location_suggested_units   T_NUMBER;
  t_location_available_units   T_NUMBER;
  t_current_weight             T_NUMBER;
  t_suggested_weight           T_NUMBER;
  t_available_weight           T_NUMBER;
  t_current_cubic_area         T_NUMBER;
  t_suggested_cubic_area       T_NUMBER;
  t_available_cubic_area       T_NUMBER;
  t_inventory_item_loc_id      T_NUMBER;
  t_empty_flag                 T_VARCHAR2_SMALL;
  t_mixed_items_flag           T_VARCHAR2_SMALL;
  t_record_source              T_VARCHAR2;
  t_inventory_item_id          T_NUMBER;
  t_transaction_quantity       T_NUMBER;
  t_containerized_flag         T_NUMBER;
  t_transaction_action_id      T_NUMBER;
  t_transfer_lpn_id            T_NUMBER;
  t_content_lpn_id             T_NUMBER;
  t_lpn_id                     T_NUMBER;
  t_transaction_status         T_NUMBER;
  t_physical_location_id       T_NUMBER;
  l_prev_physical_location_id  NUMBER :=0;
  l_prev_loc_maximum_units     NUMBER;
  l_prev_loc_max_weight        NUMBER;
  l_prev_loc_max_cubic_area    NUMBER;
  l_content_lpn_volume         NUMBER := 0;
  l_loc_count                  NUMBER := 0;
  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(1000);
  l_loop_count                 NUMBER;
  l_bulk_count                 NUMBER;
  l_count                      NUMBER;
  l_index                      NUMBER;
  l_transacted_weight          NUMBER;
  l_transacted_volume          NUMBER;
  l_item_id                    NUMBER;
  l_cnt_lpn_qty                NUMBER;
  --Variables for addressing the Bug 4333758
  l_allocated_txn_status       NUMBER := 2;
  l_txn_action_int_rcpt        NUMBER := inv_globals.g_action_intransitreceipt /* 12 */;
  l_txn_action_rcpt            NUMBER := inv_globals.g_action_receipt /* 27 */;
  l_txn_action_subxfer         NUMBER := inv_globals.g_action_subxfr /* 2 */;
  l_txn_action_orgxfer         NUMBER := inv_globals.g_action_orgxfr /* 3 */;
  l_txn_action_stgxfer         NUMBER := inv_globals.g_action_stgxfr /* 28 */;


  CURSOR c_onhand(l_locator_id NUMBER
                   ,l_subinventory VARCHAR2) IS
    /* Get MOQ */
    SELECT 'MOQ_RECORD'                                             record_source
           ,moq.inventory_item_id                                   inventory_item_id
           ,moq.primary_transaction_quantity                        transaction_quantity
           ,moq.containerized_flag                                  containerized_flag
           ,to_number(NULL)                                         transaction_action_id
           ,to_number(NULL)                                         transfer_lpn_id
           ,to_number(NULL)                                         content_lpn_id
           --TO_NUMBER(NULL)                    lpn_id,
           --moq.lpn_id                         lpn_id,
           ,wlpn.outermost_lpn_id lpn_id
           ,to_number(NULL)                                         transaction_status
           ,nvl(mil.physical_location_id,mil.inventory_location_id) physical_location_id
           ,mil.location_weight_uom_code
           ,mil.volume_uom_code
           ,mil.location_maximum_units
           ,mil.max_weight
           ,mil.max_cubic_area
    FROM   mtl_onhand_quantities_detail moq
           ,mtl_item_locations mil
           ,wms_license_plate_numbers wlpn
    WHERE  moq.locator_id = mil.inventory_location_id
    AND mil.organization_id = moq.organization_id
    AND mil.subinventory_code = moq.subinventory_code
    AND (l_locator_id IS NULL OR nvl(mil.physical_location_id,mil.inventory_location_id) = l_locator_id)
    --     AND   nvl(mil.physical_location_id,mil.inventory_location_id) = l_locator_id
    AND moq.organization_id = p_organization_id
    AND (l_subinventory IS NULL OR moq.subinventory_code =l_subinventory)
    --AND   moq.locator_id           = l_locator_id --6834052, Added to address Bug 4333758
    AND moq.transaction_quantity > 0
    AND moq.lpn_id = wlpn.lpn_id (+)
    UNION ALL
    /*
** We want all transactions that are pending. And we want all Putaway
** suggestions. However, we are dealing with just the Source location/sub
** in this side of the UNION.
*/
    SELECT 'MMTT_SOURCE_LOCATOR_RECORD'                             record_source
           ,mmtt.inventory_item_id                                  inventory_item_id
           ,mmtt.primary_quantity                                   transaction_quantity
           ,to_number(NULL)                                         containerized_flag
           ,mmtt.transaction_action_id                              transaction_action_id
           ,mmtt.transfer_lpn_id                                    transfer_lpn_id
           ,mmtt.content_lpn_id                                     content_lpn_id
           ,mmtt.lpn_id                                             lpn_id
           ,transaction_status                                      transaction_status
           ,nvl(mil.physical_location_id,mil.inventory_location_id) physical_location_id
           ,mil.location_weight_uom_code
           ,mil.volume_uom_code
           ,mil.location_maximum_units
           ,mil.max_weight
           ,mil.max_cubic_area
    FROM   mtl_material_transactions_temp mmtt
           ,mtl_item_locations mil
    WHERE  mmtt.locator_id = mil.inventory_location_id
    AND mil.organization_id = mmtt.organization_id
    AND mil.subinventory_code = mmtt.subinventory_code
    AND (l_locator_id IS NULL OR nvl(mil.physical_location_id,mil.inventory_location_id) = l_locator_id)
    --     AND   nvl(mil.physical_location_id,mil.inventory_location_id) = l_locator_id
    AND mmtt.organization_id = p_organization_id
    AND (l_subinventory IS NULL OR mmtt.subinventory_code =l_subinventory)
    --AND   mmtt.locator_id        = l_locator_id --6834052, Added to address Bug 4333758
    AND mmtt.posting_flag = 'Y'
    AND (nvl(mmtt.transaction_status,0) <> l_allocated_txn_status
         OR -- pending txns
          -- only receipt suggested transactions are used
          (nvl(mmtt.transaction_status,0) = l_allocated_txn_status
           AND mmtt.transaction_action_id IN (l_txn_action_int_rcpt,l_txn_action_rcpt)))
    UNION ALL
    /*
** We want all pending transactions and suggestions that are sub transfers.
** However, we only deal with the destination sub/locator in this side of UNION.
*/
    SELECT 'MMTT_DESTINATION_LOCATOR_RECORD'                        record_source
           ,mmtt.inventory_item_id                                  inventory_item_id
           ,mmtt.primary_quantity                                   transaction_quantity
           ,to_number(NULL)                                         containerized_flag
           ,mmtt.transaction_action_id                              transaction_action_id
           ,mmtt.transfer_lpn_id                                    transfer_lpn_id
           ,mmtt.content_lpn_id                                     content_lpn_id
           ,mmtt.lpn_id                                             lpn_id
           ,transaction_status                                      transaction_status
           ,nvl(mil.physical_location_id,mil.inventory_location_id) physical_location_id
           ,mil.location_weight_uom_code
           ,mil.volume_uom_code
           ,mil.location_maximum_units
           ,mil.max_weight
           ,mil.max_cubic_area
    FROM   mtl_material_transactions_temp mmtt
           ,mtl_item_locations mil
    WHERE  mmtt.transfer_to_location = mil.inventory_location_id
    AND mil.organization_id = mmtt.organization_id
    AND mil.subinventory_code = mmtt.transfer_subinventory -- Bug 5941137 For Destination Locator
    --     AND   nvl(mil.physical_location_id,mil.inventory_location_id) = l_locator_id
    AND mmtt.organization_id = p_organization_id
    AND (l_subinventory IS NULL OR mmtt.subinventory_code =l_subinventory)
    AND (l_locator_id IS NULL OR nvl(mil.physical_location_id,mil.inventory_location_id) = l_locator_id)
    --AND   mmtt.transfer_to_location    = l_locator_id --6834052, Added to address Bug 4333758
    AND mmtt.posting_flag = 'Y'
    AND mmtt.transaction_action_id IN (l_txn_action_subxfer,l_txn_action_orgxfer,l_txn_action_stgxfer)
    ORDER BY physical_location_id;
  l_commit_count               NUMBER := 0;
  l_debug                      NUMBER := nvl(fnd_profile.value('INV_DEBUG_TRACE'),0);
BEGIN
  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  SAVEPOINT locators_capacity_cleanup;

  IF (l_debug = 1) THEN
    mdebug(l_prog_name
           ||'Start Locator_Capacity_Clean_Up');
    mdebug('Entered Locator_Capacity_Clean_Up with parameters...');
    mdebug('p_organization_id : '||p_organization_id);
    mdebug('p_mixed_flag : '||p_mixed_flag);
    mdebug('p_subinventory : '||p_subinventory);
    mdebug('p_locator_id : '||p_locator_id);
  END IF;

  IF (l_debug = 1) THEN
    mdebug(l_prog_name
           ||'Before cleaning parent locators');
  END IF;


  UPDATE mtl_item_locations
              SET    location_current_units = 0
                     ,location_suggested_units = 0
                     ,location_available_units = location_maximum_units
                     ,current_weight = 0
                     ,suggested_weight = 0
                     ,available_weight = max_weight
                     ,current_cubic_area = 0
                     ,suggested_cubic_area = 0
                     ,available_cubic_area = max_cubic_area
                     ,inventory_item_id = NULL
                     ,empty_flag = 'Y'
                     ,mixed_items_flag = 'N'
		     , last_update_date     = sysdate                                                       /* Added for Bug 6363028 */
              WHERE  organization_id = p_organization_id
              AND nvl(physical_location_id,inventory_location_id) = inventory_location_id
              AND (p_locator_id IS NULL OR nvl(physical_location_id,inventory_location_id) = p_locator_id)
              AND (p_subinventory IS NULL OR subinventory_code =p_subinventory);


  IF (l_debug = 1) THEN
    mdebug(l_prog_name
           ||'After cleaning '||sql%ROWCOUNT||' parent locators');
  END IF;

  l_loop_count := 0;

  l_bulk_count := 0;

  OPEN c_onhand(p_locator_id,p_subinventory);

  LOOP
    /* Empty PL/SQL tables */

    t_location_weight_uom_code.DELETE;
    t_volume_uom_code.DELETE;
    t_location_maximum_units.DELETE;
    t_max_weight.DELETE;
    t_max_cubic_area.DELETE;
    t_record_source.DELETE;
    t_inventory_item_id.DELETE;
    t_transaction_quantity.DELETE;
    t_containerized_flag.DELETE;
    t_transaction_action_id.DELETE;
    t_transfer_lpn_id.DELETE;
    t_content_lpn_id.DELETE;
    t_lpn_id.DELETE;
    t_transaction_status.DELETE;
    t_physical_location_id.DELETE;

    FETCH c_onhand BULK COLLECT INTO
      t_record_source,
      t_inventory_item_id,
      t_transaction_quantity,
      t_containerized_flag,
      t_transaction_action_id,
      t_transfer_lpn_id,
      t_content_lpn_id,
      t_lpn_id,
      t_transaction_status,
      t_physical_location_id,
      t_location_weight_uom_code,
      t_volume_uom_code,
      t_location_maximum_units,
      t_max_weight,
      t_max_cubic_area
    LIMIT 500;

    l_loop_count := c_onhand%ROWCOUNT - l_bulk_count;

    IF (l_debug = 1) THEN
      mdebug('l_loop_count : '||l_loop_count);
      mdebug('l_bulk_count : '||l_bulk_count);
    END IF;

    -- Loop thru each locator
    FOR i IN 1.. l_loop_count LOOP

      IF (l_prev_physical_location_id <> t_physical_location_id(i)) THEN

        IF (l_loc_count > 0) THEN

          /*
          ** Determine empty, mixed items and item(if single item)
          */
          IF ((t_location_current_units(l_loc_count) + t_location_suggested_units(l_loc_count)) <= 0) THEN
            -- Empty
            t_inventory_item_loc_id(l_loc_count) := NULL;
            t_empty_flag(l_loc_count) := 'Y';
            t_mixed_items_flag(l_loc_count) := 'N';

          ELSIF (t_item_units.COUNT = 0) THEN
            -- Empty
            t_inventory_item_loc_id(l_loc_count) := NULL;
            t_empty_flag(l_loc_count) := 'Y';
            t_mixed_items_flag(l_loc_count) := 'N';

          ELSE

            l_count := 0;
            l_item_id := NULL;
            l_index := t_item_units.FIRST;

            LOOP
              IF ((t_item_units(l_index).location_current_units + t_item_units(l_index).location_suggested_units) > 0) THEN
                l_count := l_count + 1;
                l_item_id := t_item_units(l_index).inventory_item_id;
              END IF;

              IF (l_count > 1) THEN
                EXIT;
              END IF;

              EXIT WHEN l_index = t_item_units.LAST;
              l_index := t_item_units.NEXT(l_index);

            END LOOP;

            IF (l_count = 1) THEN
              -- Single Item
              t_inventory_item_loc_id(l_loc_count) := l_item_id;
              t_empty_flag(l_loc_count) := 'N';
              t_mixed_items_flag(l_loc_count) := 'N';

            ELSE
              -- Multiple Items
              t_inventory_item_loc_id(l_loc_count) := NULL;
              t_empty_flag(l_loc_count) := 'N';
              t_mixed_items_flag(l_loc_count) := 'Y';

            END IF;
          END IF;


          -- Set Available Units
          IF (l_prev_loc_maximum_units IS NULL) THEN
            t_location_available_units(l_loc_count) := NULL;
	    t_location_suggested_units(l_loc_count) := NULL;  --Bug#8368781
	    t_location_current_units(l_loc_count)   := NULL;  --Bug#8368781
          ELSE
            t_location_available_units(l_loc_count) := l_prev_loc_maximum_units - (t_location_current_units(l_loc_count) + t_location_suggested_units(l_loc_count));

            IF (t_location_available_units(l_loc_count) < 0) THEN
              t_location_available_units(l_loc_count) := 0;
            END IF;
          END IF;

          -- Set Available Weight
          IF (l_prev_loc_max_weight IS NULL) THEN
            t_available_weight(l_loc_count) := NULL;
	    t_suggested_weight(l_loc_count) := NULL;  --Bug#8368781
	    t_current_weight(l_loc_count)   := NULL;  --Bug#8368781
          ELSE
            t_available_weight(l_loc_count) := l_prev_loc_max_weight - (t_current_weight(l_loc_count) + t_suggested_weight(l_loc_count));

            IF (t_available_weight(l_loc_count) < 0) THEN
              t_available_weight(l_loc_count) := 0;
            END IF;
          END IF;

          -- Set Available Volume
          IF (l_prev_loc_max_cubic_area IS NULL) THEN
            t_available_cubic_area(l_loc_count) := NULL;
	    t_suggested_cubic_area(l_loc_count) := NULL;  --Bug#8368781
	    t_current_cubic_area(l_loc_count)   := NULL;  --Bug#8368781
          ELSE
            t_available_cubic_area(l_loc_count) := l_prev_loc_max_cubic_area - (t_current_cubic_area(l_loc_count) + t_suggested_cubic_area(l_loc_count));

            IF (t_available_cubic_area(l_loc_count) < 0) THEN
              t_available_cubic_area(l_loc_count) := 0;
            END IF;
          END IF;

          IF (l_loc_count = 500) THEN
            -- BULK update
            FORALL k IN t_locator.FIRST..t_locator.LAST
              UPDATE mtl_item_locations
              SET    location_current_units = t_location_current_units(k)
                     ,location_suggested_units = t_location_suggested_units(k)
                     ,location_available_units = t_location_available_units(k)
                     ,current_weight = t_current_weight(k)
                     ,suggested_weight = t_suggested_weight(k)
                     ,available_weight = t_available_weight(k)
                     ,current_cubic_area = t_current_cubic_area(k)
                     ,suggested_cubic_area = t_suggested_cubic_area(k)
                     ,available_cubic_area = t_available_cubic_area(k)
                     ,inventory_item_id = t_inventory_item_loc_id(k)
                     ,empty_flag = t_empty_flag(k)
                     ,mixed_items_flag = t_mixed_items_flag(k)
              WHERE  organization_id = p_organization_id
              AND inventory_location_id = t_locator(k);

            -- Commit 500 at a time. Last batch will have <= 500
            COMMIT;

            -- For logging purpose
            l_commit_count := l_commit_count + 1;

            IF (l_debug = 1) THEN
              inv_trx_util_pub.trace('After commit'
                                     ||', commit count: '
                                     ||to_char(l_commit_count)
                                     ||', last locator index: '
                                     ||to_char(t_physical_location_id.LAST)
                                     ||', last locator: '
                                     ||to_char(t_physical_location_id(t_physical_location_id.LAST)),
                                     'Locator_Capacity_Clean_Up',9);
            END IF;

            FOR k IN   t_locator.FIRST..t_locator.LAST LOOP
              inv_trx_util_pub.trace(t_locator(k));
            END LOOP;

            t_location_current_units.DELETE;
            t_location_suggested_units.DELETE;
            t_location_available_units.DELETE;
            t_current_weight.DELETE;
            t_suggested_weight.DELETE;
            t_available_weight.DELETE;
            t_current_cubic_area.DELETE;
            t_suggested_cubic_area.DELETE;
            t_available_cubic_area.DELETE;
            t_inventory_item_loc_id.DELETE;
            t_empty_flag.DELETE;
            t_mixed_items_flag.DELETE;
            t_locator.DELETE;

            l_loc_count := 0;

          END IF;
        END IF;

        l_loc_count := l_loc_count + 1;

        l_prev_physical_location_id := t_physical_location_id(i);
        l_prev_loc_maximum_units := t_location_maximum_units(i);
        l_prev_loc_max_weight := t_max_weight(i);
        l_prev_loc_max_cubic_area := t_max_cubic_area(i);

        t_locator(l_loc_count) := l_prev_physical_location_id;
        t_location_current_units(l_loc_count) := 0;
        t_location_suggested_units(l_loc_count) := 0;
        t_location_available_units(l_loc_count) := 0;
        t_current_weight(l_loc_count) := 0;
        t_suggested_weight(l_loc_count) := 0;
        t_available_weight(l_loc_count) := 0;
        t_current_cubic_area(l_loc_count) := 0;
        t_suggested_cubic_area(l_loc_count) := 0;
        t_available_cubic_area(l_loc_count) := 0;
        t_inventory_item_loc_id(l_loc_count) := 0;
        t_empty_flag(l_loc_count) := NULL;
        t_mixed_items_flag(l_loc_count) := NULL;

        -- Initialize Item Locator cache
        t_item_units.DELETE;
      END IF;

      /*****************************************************************************
      * Inventory item id will be -1 if the content_lpn_id is not null
      *****************************************************************************/
      IF (t_inventory_item_id(i) > 0) THEN
        IF NOT (t_item_info.exists(t_inventory_item_id(i))) THEN
          -- Item doesn't exist in cache. Hit the DB.
          SELECT inventory_item_id
                 ,primary_uom_code
                 ,weight_uom_code
                 ,unit_weight
                 ,volume_uom_code
                 ,unit_volume
          INTO   t_item_info(t_inventory_item_id(i)).inventory_item_id,t_item_info(t_inventory_item_id(i)).item_primary_uom_code,t_item_info(t_inventory_item_id(i)).item_weight_uom_code,t_item_info(t_inventory_item_id(i)).item_unit_weight,
                 t_item_info(t_inventory_item_id(i)).item_volume_uom_code,t_item_info(t_inventory_item_id(i)).item_unit_volume
          FROM   mtl_system_items
          WHERE  organization_id = p_organization_id
          AND inventory_item_id = t_inventory_item_id(i);
        END IF;

        IF NOT (t_item_units.exists(t_inventory_item_id(i))) THEN
          -- Item doesnt exist in Item Locator cache Initialize
          t_item_units(t_inventory_item_id(i)).inventory_item_id := t_inventory_item_id(i);

          t_item_units(t_inventory_item_id(i)).location_current_units := 0;

          t_item_units(t_inventory_item_id(i)).location_suggested_units := 0;
        END IF;

        -- MMTT quantity maybe negative
        t_transaction_quantity(i) := abs(t_transaction_quantity(i));

        -- Initialize
        l_transacted_weight := 0;

        l_transacted_volume := 0;

        -- Compute Weight
        IF ((t_location_weight_uom_code(i) IS NOT NULL)
            AND (t_item_info(t_inventory_item_id(i)).item_weight_uom_code IS NOT NULL)
            AND (t_item_info(t_inventory_item_id(i)).item_unit_weight > 0)) THEN
          l_transacted_weight := t_transaction_quantity(i) * t_item_info(t_inventory_item_id(i)).item_unit_weight;

          IF (t_item_info(t_inventory_item_id(i)).item_weight_uom_code <> t_location_weight_uom_code(i)) THEN
            l_transacted_weight := inv_convert.inv_um_convert(item_id => t_inventory_item_id(i),PRECISION => NULL,
                                                              from_quantity => l_transacted_weight,from_unit => t_item_info(t_inventory_item_id(i)).item_weight_uom_code,
                                                              to_unit => t_location_weight_uom_code(i),
                                                              from_name => NULL,to_name => NULL);
          END IF;

          IF (l_transacted_weight < 0) THEN
            l_transacted_weight := 0;
          END IF;
        END IF;

        -- Compute Volume
        IF ((t_volume_uom_code(i) IS NOT NULL)
            AND (t_item_info(t_inventory_item_id(i)).item_volume_uom_code IS NOT NULL)
            AND (t_item_info(t_inventory_item_id(i)).item_unit_volume > 0)) THEN
          l_transacted_volume := t_transaction_quantity(i) * t_item_info(t_inventory_item_id(i)).item_unit_volume;

          IF (t_item_info(t_inventory_item_id(i)).item_volume_uom_code <> t_volume_uom_code(i)) THEN
            l_transacted_volume := inv_convert.inv_um_convert(item_id => t_inventory_item_id(i),PRECISION => NULL,
                                                              from_quantity => l_transacted_volume,from_unit => t_item_info(t_inventory_item_id(i)).item_volume_uom_code,
                                                              to_unit => t_volume_uom_code(i),from_name => NULL,
                                                              to_name => NULL);
          END IF;

          IF (l_transacted_volume < 0) THEN
            l_transacted_volume := 0;
          END IF;
        END IF;
      END IF; --inventory_item_id > 0

      /*******************************************************************************
      * Fetch the details of the LPN if passed.
      *******************************************************************************/
      IF t_lpn_id(i) IS NOT NULL
         AND NOT t_lpn_info.exists(t_lpn_id(i)) THEN
        get_container_capacity(x_return_status => x_return_status,x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data,p_locator_weight_uom => t_location_weight_uom_code(i),
                               p_locator_volume_uom => t_volume_uom_code(i),
                               p_lpn_id => t_lpn_id(i),p_organization_id => p_organization_id,
                               x_container_item_wt => t_lpn_info(t_lpn_id(i)).container_item_weight,
                               x_container_item_vol => t_lpn_info(t_lpn_id(i)).container_item_vol,
                               x_lpn_gross_weight => t_lpn_info(t_lpn_id(i)).gross_weight,
                               x_lpn_content_vol => t_lpn_info(t_lpn_id(i)).content_volume);
      END IF;

      /*******************************************************************************
      * Fetch the details of the Content  LPN if passed.
      *******************************************************************************/
      IF t_content_lpn_id(i) IS NOT NULL
         AND NOT t_lpn_info.exists(t_content_lpn_id(i)) THEN
        get_container_capacity(x_return_status => x_return_status,x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data,p_locator_weight_uom => t_location_weight_uom_code(i),
                               p_locator_volume_uom => t_volume_uom_code(i),
                               p_lpn_id => t_content_lpn_id(i),p_organization_id => p_organization_id,
                               x_container_item_wt => t_lpn_info(t_content_lpn_id(i)).container_item_weight,
                               x_container_item_vol => t_lpn_info(t_content_lpn_id(i)).container_item_vol,
                               x_lpn_gross_weight => t_lpn_info(t_content_lpn_id(i)).gross_weight,
                               x_lpn_content_vol => t_lpn_info(t_content_lpn_id(i)).content_volume);
      END IF;

      /*******************************************************************************
      * Fetch the details of the Transfer LPN if passed.
      *******************************************************************************/
      IF t_transfer_lpn_id(i) IS NOT NULL
         AND NOT t_lpn_info.exists(t_transfer_lpn_id(i)) THEN
        get_container_capacity(x_return_status => x_return_status,x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data,p_locator_weight_uom => t_location_weight_uom_code(i),
                               p_locator_volume_uom => t_volume_uom_code(i),
                               p_lpn_id => t_transfer_lpn_id(i),p_organization_id => p_organization_id,
                               x_container_item_wt => t_lpn_info(t_transfer_lpn_id(i)).container_item_weight,
                               x_container_item_vol => t_lpn_info(t_transfer_lpn_id(i)).container_item_vol,
                               x_lpn_gross_weight => t_lpn_info(t_transfer_lpn_id(i)).gross_weight,
                               x_lpn_content_vol => t_lpn_info(t_transfer_lpn_id(i)).content_volume);
      END IF;

      /********************************************************************************
      * Check if the record is from MOQD or MMTT and process accordingly.
      ********************************************************************************/
      IF (t_record_source(i) = 'MOQ_RECORD') THEN
        -- Add Units
        t_item_units(t_inventory_item_id(i)).location_current_units := t_item_units(t_inventory_item_id(i)).location_current_units + t_transaction_quantity(i);

        t_location_current_units(l_loc_count) := t_location_current_units(l_loc_count) + t_transaction_quantity(i);

        -- lpn has not already been considered, then consider the container weight
        -- and volume.
        IF t_lpn_id(i) IS NOT NULL
           AND t_lpn_info(t_lpn_id(i)).lpn_exists_in_locator = 'N' THEN
          -- check if the content volume is > container item volume, in which case
          -- add the content volume, else add the container item volume.
          IF t_lpn_info(t_lpn_id(i)).content_volume < t_lpn_info(t_lpn_id(i)).container_item_vol THEN
            t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_lpn_id(i)).container_item_vol;
          ELSE
            t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_lpn_id(i)).content_volume;
          END IF;

          t_current_weight(l_loc_count) := t_current_weight(l_loc_count) + t_lpn_info(t_lpn_id(i)).gross_weight;

          t_lpn_info(t_lpn_id(i)).lpn_exists_in_locator := 'Y';

          mdebug(l_prog_name
                 ||'moq current wt is         :'
                 ||t_current_weight(l_loc_count));

          mdebug(l_prog_name
                 ||'moq current cubic area is :'
                 ||t_current_cubic_area(l_loc_count));
        ELSIF t_lpn_id(i) IS NULL THEN
          -- Loose Qty
          -- Add transacted weight
          t_current_weight(l_loc_count) := t_current_weight(l_loc_count) + l_transacted_weight;

          -- the MOQD record is for loose quantity. just add the transacted volume.
          t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume;

          mdebug(l_prog_name
                 ||'moq current wt is         :'
                 ||t_current_weight(l_loc_count));

          mdebug(l_prog_name
                 ||'moq current cubic area is :'
                 ||t_current_cubic_area(l_loc_count));
        END IF;
      ELSIF (t_record_source(i) = 'MMTT_SOURCE_LOCATOR_RECORD') THEN
        /********************************************************************************
        * The record is from MMTT. Check whether the transaction is a suggestion or a
        * Pending transaction. If it is a suggestion, then only suggested capacity is
        * modified.
        ********************************************************************************/
        IF (t_transaction_status(i) = 2) THEN  -- This is a Receipt Suggestion.

          --Add transacted weight
          t_suggested_weight(l_loc_count) := t_suggested_weight(l_loc_count) + l_transacted_weight;

          --Add transacted volume
          t_suggested_cubic_area(l_loc_count) := t_suggested_cubic_area(l_loc_count) + l_transacted_volume;

          -- Add Units
          t_item_units(t_inventory_item_id(i)).location_suggested_units := t_item_units(t_inventory_item_id(i)).location_suggested_units + t_transaction_quantity(i);

          t_location_suggested_units(l_loc_count) := t_location_suggested_units(l_loc_count) + t_transaction_quantity(i);
        ELSE
          IF (t_transaction_action_id(i) IN (12,27)) THEN    -- Receipt Pending Xn

            --Add transacted weight. this needs to be done irrespective of whether
            --the transaction has LPN or not.
            t_current_weight(l_loc_count) := t_current_weight(l_loc_count) + l_transacted_weight;

            -- Add Units
            t_item_units(t_inventory_item_id(i)).location_current_units := t_item_units(t_inventory_item_id(i)).location_current_units + t_transaction_quantity(i);

            t_location_current_units(l_loc_count) := t_location_current_units(l_loc_count) + t_transaction_quantity(i);

            --This is an LPN transation, Check if the lpn already exists in the locator.
            --If not, then we need to consider the container weight and volume.
            IF t_transfer_lpn_id(i) IS NOT NULL
               AND t_lpn_info(t_transfer_lpn_id(i)).lpn_exists_in_locator = 'N' THEN
              mdebug('**************lpn exists in locator***********'
                     ||t_lpn_info(t_transfer_lpn_id(i)).lpn_exists_in_locator);

              IF l_transacted_volume < t_lpn_info(t_transfer_lpn_id(i)).container_item_vol THEN
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_transfer_lpn_id(i)).container_item_vol;
              ELSE
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume;
              END IF;

              t_current_weight(l_loc_count) := t_current_weight(l_loc_count) + t_lpn_info(t_transfer_lpn_id(i)).container_item_weight;

              t_lpn_info(t_transfer_lpn_id(i)).lpn_exists_in_locator := 'Y';

              mdebug(l_prog_name
                     ||'mmtt current wt is         :'
                     ||t_current_weight(l_loc_count));

              mdebug(l_prog_name
                     ||'mmtt current cubic area is :'
                     ||t_current_cubic_area(l_loc_count));
            ELSIF t_transfer_lpn_id(i) IS NOT NULL THEN
              --The LPN already exists in the locator. so we need to check if the addition of this
              --quantity would overflow the container or not.
              IF t_lpn_info(t_transfer_lpn_id(i)).container_item_vol > t_lpn_info(t_transfer_lpn_id(i)).content_volume THEN
                IF l_transacted_volume > (t_lpn_info(t_transfer_lpn_id(i)).container_item_vol - t_lpn_info(t_transfer_lpn_id(i)).content_volume) THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume + t_lpn_info(t_transfer_lpn_id(i)).content_volume - t_lpn_info(t_transfer_lpn_id(i)).container_item_vol;
                END IF;

                mdebug(l_prog_name
                       ||'mmtt current wt is         :'
                       ||t_current_weight(l_loc_count));

                mdebug(l_prog_name
                       ||'mmtt current cubic area is :'
                       ||t_current_cubic_area(l_loc_count));
              ELSE
                --Already the LPN has more volume than the container. so just add the transacted
                --volume.
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume;

                mdebug(l_prog_name
                       ||'mmtt current wt is         :'
                       ||t_current_weight(l_loc_count));

                mdebug(l_prog_name
                       ||'mmtt current cubic area is :'
                       ||t_current_cubic_area(l_loc_count));
              END IF;
            ELSE
              -- loose quantity, just add the transacted volume
              t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume;

              mdebug(l_prog_name
                     ||'mmtt current wt is         :'
                     ||t_current_weight(l_loc_count));

              mdebug(l_prog_name
                     ||'mmtt current cubic area is :'
                     ||t_current_cubic_area(l_loc_count));
            END IF;

            IF t_transfer_lpn_id(i) IS NOT NULL THEN
              --need to update the LPN Cache with the transacted volume and weight.
              --This is needed as the record is still in MMTT and the LPN weight and
              --volume are not properly updated yet.
              t_lpn_info(t_transfer_lpn_id(i)).gross_weight := t_lpn_info(t_transfer_lpn_id(i)).gross_weight + l_transacted_weight;

              t_lpn_info(t_transfer_lpn_id(i)).content_volume := t_lpn_info(t_transfer_lpn_id(i)).content_volume + l_transacted_volume;
            END IF;
          ELSIF (t_transaction_action_id(i) IN (1,2,3,28)) THEN -- Issue Pending Xn

            --If the content lpn is stamped, the transaction quantity will always be -1.
            --so we need to fetch the actual transated qty from the LPN contents.
            IF t_content_lpn_id(i) IS NULL THEN
              t_current_weight(l_loc_count) := t_current_weight(l_loc_count) - l_transacted_weight;

              -- Minus Units
              t_item_units(t_inventory_item_id(i)).location_current_units := t_item_units(t_inventory_item_id(i)).location_current_units - t_transaction_quantity(i);

              t_location_current_units(l_loc_count) := t_location_current_units(l_loc_count) - t_transaction_quantity(i);
            END IF;

            IF t_content_lpn_id(i) IS NOT NULL
               AND t_lpn_info(t_content_lpn_id(i)).lpn_already_considered <> 'Y' THEN
              --Content LPN is not null => the whole LPN is being transacted.
              t_current_weight(l_loc_count) := t_current_weight(l_loc_count) - t_lpn_info(t_content_lpn_id(i)).gross_weight;

              IF t_lpn_info(t_content_lpn_id(i)).container_item_vol > t_lpn_info(t_content_lpn_id(i)).content_volume THEN
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - t_lpn_info(t_content_lpn_id(i)).container_item_vol;
              ELSE
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - t_lpn_info(t_content_lpn_id(i)).content_volume;
              END IF;

              t_lpn_info(t_content_lpn_id(i)).lpn_already_considered := 'Y';

              fetch_lpn_content_qty(p_lpn_id => t_content_lpn_id(i),x_quantity => l_cnt_lpn_qty);

              t_location_current_units(l_loc_count) := t_location_current_units(l_loc_count) - l_cnt_lpn_qty;

              mdebug(l_prog_name
                     ||'mmtt current wt is :'
                     ||t_current_weight(l_loc_count));

              mdebug(l_prog_name
                     ||'mmtt current cubic area is :'
                     ||t_current_cubic_area(l_loc_count));
            ELSE
              IF t_lpn_id(i) IS NOT NULL
                 AND t_lpn_info(t_lpn_id(i)).lpn_already_considered <> 'Y'
                 AND l_transacted_volume = t_lpn_info(t_lpn_id(i)).content_volume THEN
                --Transacting the entire LPN. Consider deducting container wt and vol.
                t_current_weight(l_loc_count) := t_current_weight(l_loc_count) - t_lpn_info(t_lpn_id(i)).container_item_weight;

                IF t_lpn_info(t_lpn_id(i)).container_item_vol > t_lpn_info(t_lpn_id(i)).content_volume THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - t_lpn_info(t_lpn_id(i)).container_item_vol;
                ELSE
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - t_lpn_info(t_lpn_id(i)).content_volume;
                END IF;

                t_lpn_info(t_lpn_id(i)).lpn_already_considered := 'Y';

                mdebug(l_prog_name
                       ||'mmtt current wt is :'
                       ||t_current_weight(l_loc_count));

                mdebug(l_prog_name
                       ||'mmtt current cubic area is :'
                       ||t_current_cubic_area(l_loc_count));
              ELSIF t_lpn_id(i) IS NOT NULL
                    AND t_lpn_info(t_lpn_id(i)).lpn_already_considered <> 'Y' THEN
                --Transacting partial LPN.
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - l_transacted_volume;

                t_lpn_info(t_lpn_id(i)).content_volume := t_lpn_info(t_lpn_id(i)).content_volume - l_transacted_volume;

                t_lpn_info(t_lpn_id(i)).gross_weight := t_lpn_info(t_lpn_id(i)).gross_weight - l_transacted_weight;

                mdebug(l_prog_name
                       ||'mmtt current wt is         :'
                       ||t_current_weight(l_loc_count));

                mdebug(l_prog_name
                       ||'mmtt current cubic area is :'
                       ||t_current_cubic_area(l_loc_count));
              ELSIF t_lpn_id(i) IS NULL THEN
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - l_transacted_volume;

                mdebug(l_prog_name
                       ||'mmtt current wt is         :'
                       ||t_current_weight(l_loc_count));

                mdebug(l_prog_name
                       ||'mmtt current cubic area is :'
                       ||t_current_cubic_area(l_loc_count));
              END IF;
            END IF;
          ELSIF (t_transaction_action_id(i) = 50) THEN  --Pack Transaction

            IF t_transfer_lpn_id(i) IS NOT NULL
               AND t_lpn_info(t_transfer_lpn_id(i)).lpn_exists_in_locator = 'N' THEN
              t_current_weight(l_loc_count) := t_current_weight(l_loc_count) + t_lpn_info(t_transfer_lpn_id(i)).container_item_weight;

              IF t_content_lpn_id(i) IS NULL THEN
                IF l_transacted_volume >= t_lpn_info(t_transfer_lpn_id(i)).container_item_vol THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count);
                ELSE
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_transfer_lpn_id(i)).container_item_vol - l_transacted_volume;
                END IF;
              ELSE
                IF t_lpn_info(t_content_lpn_id(i)).content_volume > t_lpn_info(t_content_lpn_id(i)).container_item_vol THEN
                  l_content_lpn_volume := t_lpn_info(t_content_lpn_id(i)).content_volume;
                ELSE
                  l_content_lpn_volume := t_lpn_info(t_content_lpn_id(i)).container_item_vol;
                END IF;

                IF l_content_lpn_volume >= t_lpn_info(t_transfer_lpn_id(i)).container_item_vol THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count);
                ELSE
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_transfer_lpn_id(i)).container_item_vol - l_content_lpn_volume;
                END IF;
              END IF;

              t_lpn_info(t_transfer_lpn_id(i)).lpn_exists_in_locator := 'Y';
            ELSIF t_transfer_lpn_id(i) IS NOT NULL THEN
              IF t_content_lpn_id(i) IS NULL THEN
                IF l_transacted_volume <= (t_lpn_info(t_transfer_lpn_id(i)).container_item_vol - t_lpn_info(t_transfer_lpn_id(i)).content_volume) THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - l_transacted_volume;
                ELSE
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_transfer_lpn_id(i)).content_volume - t_lpn_info(t_transfer_lpn_id(i)).container_item_vol;
                END IF;
              ELSE
                IF t_lpn_info(t_content_lpn_id(i)).content_volume > t_lpn_info(t_content_lpn_id(i)).container_item_vol THEN
                  l_content_lpn_volume := t_lpn_info(t_content_lpn_id(i)).content_volume;
                ELSE
                  l_content_lpn_volume := t_lpn_info(t_content_lpn_id(i)).container_item_vol;
                END IF;

                IF l_content_lpn_volume > (t_lpn_info(t_transfer_lpn_id(i)).container_item_vol - t_lpn_info(t_transfer_lpn_id(i)).content_volume) THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - l_content_lpn_volume;
                ELSE
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - t_lpn_info(t_transfer_lpn_id(i)).container_item_vol + t_lpn_info(t_transfer_lpn_id(i)).content_volume;
                END IF;
              END IF;
            END IF;

            IF t_content_lpn_id(i) IS NULL THEN
              t_lpn_info(t_transfer_lpn_id(i)).gross_weight := t_lpn_info(t_transfer_lpn_id(i)).gross_weight + l_transacted_weight;

              t_lpn_info(t_transfer_lpn_id(i)).content_volume := t_lpn_info(t_transfer_lpn_id(i)).content_volume + l_transacted_volume;
            ELSE
              t_lpn_info(t_transfer_lpn_id(i)).gross_weight := t_lpn_info(t_transfer_lpn_id(i)).gross_weight + t_lpn_info(t_content_lpn_id(i)).gross_weight;

              t_lpn_info(t_transfer_lpn_id(i)).content_volume := t_lpn_info(t_transfer_lpn_id(i)).content_volume + l_content_lpn_volume;
            END IF;
          ELSIF (t_transaction_action_id(i) = 51) THEN   --Unpack Transaction.

            IF t_content_lpn_id(i) IS NULL THEN
              IF t_lpn_info(t_lpn_id(i)).container_item_vol <> 0
                 AND (t_lpn_info(t_lpn_id(i)).content_volume - l_transacted_volume) < t_lpn_info(t_lpn_id(i)).container_item_vol THEN
                IF t_lpn_info(t_lpn_id(i)).content_volume > t_lpn_info(t_lpn_id(i)).container_item_vol THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - t_lpn_info(t_lpn_id(i)).content_volume + t_lpn_info(t_lpn_id(i)).container_item_vol + l_transacted_volume;
                ELSE
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume;
                END IF;
              END IF;

              --Bug#5049369.Changed t_transfer_lpn_id(i) to t_lpn_id(i)
              IF t_lpn_id(i) IS NOT NULL THEN -- Added for 4484753

                t_lpn_info(t_lpn_id(i)).gross_weight := t_lpn_info(t_lpn_id(i)).gross_weight - l_transacted_weight;

                t_lpn_info(t_lpn_id(i)).content_volume := t_lpn_info(t_lpn_id(i)).content_volume - l_transacted_volume;
              END IF;
            ELSE
              IF t_lpn_info(t_content_lpn_id(i)).content_volume > t_lpn_info(t_content_lpn_id(i)).container_item_vol THEN
                l_content_lpn_volume := t_lpn_info(t_content_lpn_id(i)).content_volume;
              ELSE
                l_content_lpn_volume := t_lpn_info(t_content_lpn_id(i)).container_item_vol;
              END IF;

              IF t_lpn_info(t_lpn_id(i)).container_item_vol <> 0
                 AND (t_lpn_info(t_lpn_id(i)).content_volume - l_content_lpn_volume) < t_lpn_info(t_lpn_id(i)).container_item_vol THEN
                IF t_lpn_info(t_lpn_id(i)).content_volume > t_lpn_info(t_lpn_id(i)).container_item_vol THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) - t_lpn_info(t_lpn_id(i)).content_volume + t_lpn_info(t_lpn_id(i)).container_item_vol + l_content_lpn_volume;
                ELSE
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_content_lpn_volume;
                END IF;
              END IF;

              --Bug#5049369.Changed t_transfer_lpn_id(i) to t_lpn_id(i)
              IF t_lpn_id(i) IS NOT NULL THEN -- added for 5229908

                t_lpn_info(t_lpn_id(i)).gross_weight := t_lpn_info(t_lpn_id(i)).gross_weight - t_lpn_info(t_content_lpn_id(i)).gross_weight;

                t_lpn_info(t_lpn_id(i)).content_volume := t_lpn_info(t_lpn_id(i)).content_volume - l_content_lpn_volume;
              END IF;
            END IF;
          END IF;
        END IF;
      ELSE   /* MMTT_DESTINATION_LOCATOR_RECORD */
        IF (t_transaction_status(i) = 2) THEN  -- Receipt Dest. Suggestion

          --Add transacted weight
          t_suggested_weight(l_loc_count) := t_suggested_weight(l_loc_count) + l_transacted_weight;

          --Add transacted volume
          t_suggested_cubic_area(l_loc_count) := t_suggested_cubic_area(l_loc_count) + l_transacted_volume;

          -- Add Units
          t_item_units(t_inventory_item_id(i)).location_suggested_units := t_item_units(t_inventory_item_id(i)).location_suggested_units + t_transaction_quantity(i);

          t_location_suggested_units(l_loc_count) := t_location_suggested_units(l_loc_count) + t_transaction_quantity(i);
        ELSE                               -- Receipt Dest. Pending Xn

          IF t_content_lpn_id(i) IS NULL THEN
            --Add transacted weight
            t_current_weight(l_loc_count) := t_current_weight(l_loc_count) + l_transacted_weight;

            -- Add Units
            t_item_units(t_inventory_item_id(i)).location_current_units := t_item_units(t_inventory_item_id(i)).location_current_units + t_transaction_quantity(i);

            t_location_current_units(l_loc_count) := t_location_current_units(l_loc_count) + t_transaction_quantity(i);
          END IF;

          IF t_content_lpn_id(i) IS NOT NULL THEN
            fetch_lpn_content_qty(p_lpn_id => t_content_lpn_id(i),x_quantity => l_cnt_lpn_qty);

            IF t_lpn_info(t_content_lpn_id(i)).content_volume < t_lpn_info(t_content_lpn_id(i)).container_item_vol THEN
              t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_content_lpn_id(i)).container_item_vol;
            ELSE
              t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_content_lpn_id(i)).content_volume;
            END IF;

            t_current_weight(l_loc_count) := t_current_weight(l_loc_count) + t_lpn_info(t_content_lpn_id(i)).gross_weight;

            mdebug(l_prog_name
                   ||'mmtt dest current wt is :'
                   ||t_current_weight(l_loc_count));

            mdebug(l_prog_name
                   ||'mmtt dest current cubic area is :'
                   ||t_current_cubic_area(l_loc_count));

            t_location_current_units(l_loc_count) := t_location_current_units(l_loc_count) + l_cnt_lpn_qty;
          ELSE
            IF t_transfer_lpn_id(i) IS NOT NULL
               AND t_lpn_info(t_transfer_lpn_id(i)).lpn_exists_in_locator = 'N' THEN
              IF l_transacted_volume < t_lpn_info(t_transfer_lpn_id(i)).container_item_vol THEN
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + t_lpn_info(t_transfer_lpn_id(i)).container_item_vol;
              ELSE
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume;
              END IF;

              t_current_weight(l_loc_count) := t_current_weight(l_loc_count) + t_lpn_info(t_transfer_lpn_id(i)).container_item_weight;

              t_lpn_info(t_transfer_lpn_id(i)).lpn_exists_in_locator := 'Y';

              mdebug(l_prog_name
                     ||'mmtt current wt is         :'
                     ||t_current_weight(l_loc_count));

              mdebug(l_prog_name
                     ||'mmtt current cubic area is :'
                     ||t_current_cubic_area(l_loc_count));
            --t_lpn_info(t_lpn_id(i)).lpn_already_considered := 'Y'
            ELSIF t_transfer_lpn_id(i) IS NOT NULL THEN
              IF t_lpn_info(t_transfer_lpn_id(i)).container_item_vol > t_lpn_info(t_transfer_lpn_id(i)).content_volume THEN
                IF l_transacted_volume > (t_lpn_info(t_transfer_lpn_id(i)).container_item_vol - t_lpn_info(t_transfer_lpn_id(i)).content_volume) THEN
                  t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume + t_lpn_info(t_transfer_lpn_id(i)).content_volume - t_lpn_info(t_transfer_lpn_id(i)).container_item_vol;
                END IF;

                mdebug(l_prog_name
                       ||'mmtt current wt is         :'
                       ||t_current_weight(l_loc_count));

                mdebug(l_prog_name
                       ||'mmtt current cubic area is :'
                       ||t_current_cubic_area(l_loc_count));
              ELSE
                t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume;

                mdebug(l_prog_name
                       ||'mmtt current wt is         :'
                       ||t_current_weight(l_loc_count));

                mdebug(l_prog_name
                       ||'mmtt current cubic area is :'
                       ||t_current_cubic_area(l_loc_count));
              END IF;
            ELSE -- loose quantity

              t_current_cubic_area(l_loc_count) := t_current_cubic_area(l_loc_count) + l_transacted_volume;

              mdebug(l_prog_name
                     ||'mmtt current wt is         :'
                     ||t_current_weight(l_loc_count));

              mdebug(l_prog_name
                     ||'mmtt current cubic area is :'
                     ||t_current_cubic_area(l_loc_count));
            END IF;  --t_transfer_lpn_id(i) IS NOT NULL
          END IF;    --t_content_lpn_id(i) IS NOT NULL THEN
        END IF;      --(t_transaction_status(i) = 2)
      END IF;        /* MMTT_DESTINATION_LOCATOR_RECORD */
    END LOOP;            -- l_loop_count

    l_bulk_count := c_onhand%ROWCOUNT;

    IF l_loop_count < 500 THEN
      FORALL k IN t_locator.FIRST..t_locator.LAST
        UPDATE mtl_item_locations
        SET    location_current_units = t_location_current_units(k)
               ,location_suggested_units = t_location_suggested_units(k)
               ,location_available_units = t_location_available_units(k)
               ,current_weight = t_current_weight(k)
               ,suggested_weight = t_suggested_weight(k)
               ,available_weight = t_available_weight(k)
               ,current_cubic_area = t_current_cubic_area(k)
               ,suggested_cubic_area = t_suggested_cubic_area(k)
               ,available_cubic_area = t_available_cubic_area(k)
               ,inventory_item_id = t_inventory_item_loc_id(k)
               ,empty_flag = t_empty_flag(k)
               ,mixed_items_flag = t_mixed_items_flag(k)
	       , last_update_date     = sysdate                                                       /* Added for Bug 6363028 */
        WHERE  organization_id = p_organization_id
        AND inventory_location_id = t_locator(k);

      -- Commit 500 at a time. Last batch will have <= 500
      COMMIT;

      -- For logging purpose
      l_commit_count := l_commit_count + 1;

      IF (l_debug = 1) THEN
        inv_trx_util_pub.trace('After commit'
                               ||', commit count: '
                               ||to_char(l_commit_count)
                               ||', last locator index: '
                               ||to_char(t_locator.LAST)
                               ||', last locator: '
                               ||to_char(t_physical_location_id(t_locator.LAST)),
                               'Locator_Capacity_Clean_Up',9);


      END IF;



      t_location_current_units.DELETE;
      t_location_suggested_units.DELETE;
      t_location_available_units.DELETE;
      t_current_weight.DELETE;
      t_suggested_weight.DELETE;
      t_available_weight.DELETE;
      t_current_cubic_area.DELETE;
      t_suggested_cubic_area.DELETE;
      t_available_cubic_area.DELETE;
      t_inventory_item_loc_id.DELETE;
      t_empty_flag.DELETE;
      t_mixed_items_flag.DELETE;
      t_locator.DELETE;

      l_loc_count := 0;

      EXIT;
    END IF;
  END LOOP;

  CLOSE c_onhand;

  IF (l_debug = 1) THEN
    inv_trx_util_pub.trace('End ','Locator_Capacity_Clean_Up',9);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    mdebug('Error:-'
           ||sqlerrm);

    ROLLBACK TO locators_capacity_cleanup ;

    x_return_status := fnd_api.g_ret_sts_error;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    mdebug('Error:-'
           ||sqlerrm);

    ROLLBACK TO locators_capacity_cleanup;

    x_return_status := fnd_api.g_ret_sts_unexp_error;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);
  WHEN OTHERS THEN
    mdebug('Error:-'
           ||sqlerrm);

    ROLLBACK TO locators_capacity_cleanup;

    x_return_status := fnd_api.g_ret_sts_unexp_error;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg('inv_loc_wms_utils','locator_capacity_cleanup');
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);
END locators_capacity_cleanup;


--  this API upgrades (cleans up) the capacity in each location thru concurrent request
PROCEDURE launch_upgrade(
    x_errorbuf         OUT  NOCOPY VARCHAR2,
    x_retcode          OUT  NOCOPY VARCHAR2,
    p_organization_id   IN  NUMBER,
    p_subinventory      IN  VARCHAR2,
    p_mixed_items_flag  IN  NUMBER
    )
IS
     l_return_status		varchar2(1);
     l_msg_count	        number;
     l_msg_data			varchar2(1000);
     l_conc_status               BOOLEAN;
     l_mixed_items_flag		varchar2(1);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

	IF (p_organization_id is null) THEN
	 fnd_message.set_name('INV', 'INV_ORG_REQUIRED');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;
	END IF;

        IF nvl(p_mixed_items_flag,2) = 1 then
          l_mixed_items_flag :='Y';
        else
          l_mixed_items_flag := null;
        END IF;

	-- call cleanup API
	inv_loc_wms_utils.locators_capacity_cleanup
	(    x_return_status       => l_return_status
	   , x_msg_count           => l_msg_count
	   , x_msg_data            => l_msg_data
	   , p_organization_id     => p_organization_id
	   , p_mixed_flag          => l_mixed_items_flag
	   , p_subinventory        => p_subinventory);

	IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	     IF (l_debug = 1) THEN
   	     INV_TRX_UTIL_PUB.TRACE('Locator capacity calc prog completed with Errors ', 'launch Upgrade',9);
	     END IF;
	     RAISE fnd_api.g_exc_error;
	    ELSE
	     IF (l_debug = 1) THEN
   	     INV_TRX_UTIL_PUB.TRACE('Locator capacity calc prog completed with Unexp errors ', 'launch Upgrade',9);
	     END IF;
	     RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
	ELSE
	     IF (l_debug = 1) THEN
   	     INV_TRX_UTIL_PUB.TRACE('Locator capacity calc prog completed successfully ', 'launch Upgrade',9);
	     END IF;
	      print_message();
	      l_conc_status := fnd_concurrent.set_completion_status('NORMAL','NORMAL');
	      x_retcode := RETCODE_SUCCESS;
	      x_errorbuf := NULL;
	END IF;

EXCEPTION
  WHEN fnd_api.g_exc_error THEN

       print_message();
       l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');
       x_retcode := RETCODE_ERROR;
       x_errorbuf := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

  WHEN fnd_api.g_exc_unexpected_error THEN

       print_message();
       l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');
       x_retcode := RETCODE_ERROR;
       x_errorbuf := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

  WHEN OTHERS THEN

       print_message();
       l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');
       x_retcode := RETCODE_ERROR;
       x_errorbuf := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

END launch_upgrade;

PROCEDURE print_message(dummy IN VARCHAR2 )IS

   l_msg_count    NUMBER;
   l_msg_data     VARCHAR2(2000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

       fnd_msg_pub.count_and_get(
	 p_count   => l_msg_count,
	 p_data    => l_msg_data,
	 p_encoded => 'F'
	 );

       FOR i IN 1..l_msg_count LOOP
	   l_msg_data := fnd_msg_pub.get(i, 'F');
	   fnd_file.put_line(fnd_file.log, l_msg_data);
       END LOOP;
       fnd_file.put_line(fnd_file.log, ' ');

       fnd_msg_pub.initialize;

EXCEPTION
   WHEN OTHERS THEN
	fnd_file.put_line(fnd_file.log, sqlerrm);

END print_message;


/************************************************************************************************
 * Procedure fetch_locator()                                                                    *
 * @Params :                                                                                    *
 *          1. Inventory Location Passed                                                        *
 *          2. Organization                                                                     *
 *          3. Actual Physical Locator ID                                                       *
 ************************************************************************************************/
PROCEDURE fetch_locator
   ( p_inventory_location_id    IN          NUMBER     -- inventory location id
   , p_organization_id          IN          NUMBER     -- organization
   , x_locator_id               OUT  NOCOPY NUMBER     -- actual physical location id
   )
IS
   l_loc_id                 NUMBER;
   l_physical_locator_id    NUMBER;
   l_debug                           NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   /*---------------------------------------------------------------------------------------------
     Check if the locator has a physical_location_id then use the physical_location_id for further
     processing.Else we have to use the inventory_location_id for further processing
     ---------------------------------------------------------------------------------------------*/
   SELECT   physical_location_id
	     ,   inventory_location_id
     INTO   l_physical_locator_id
	     ,   l_loc_id
     FROM   mtl_item_locations
    WHERE   inventory_location_id = p_inventory_location_id
      AND   organization_id = p_organization_id;

   /*---------------------------------------------------------------------------------------------
     If physical location id is null, then the location_id passes is normal locator, else it is a
     logical locator and we have to use the physical location id to fetch the capacity.
     ---------------------------------------------------------------------------------------------*/
   IF l_physical_locator_id IS NULL THEN
     x_locator_id := l_loc_id;
   ELSE
     x_locator_id := l_physical_locator_id;
   END IF;
END fetch_locator;

PROCEDURE fetch_loc_curr_capacity
   (
     p_inventory_location_id        IN         NUMBER     -- inventory location id
   , p_organization_id              IN         NUMBER     -- organization passed
   , x_loc_attr                     OUT NOCOPY LocatorRec -- Record Containing Locator Details
   )
IS
l_locator_weight_uom_code          VARCHAR2(3);
l_locator_max_weight               NUMBER;
l_locator_suggested_weight         NUMBER;
l_locator_suggested_cubic_area     NUMBER;
l_locator_current_weight           NUMBER;
l_locator_available_weight         NUMBER;
l_locator_volume_uom_code          VARCHAR2(3);
l_locator_max_cubic_area           NUMBER;
l_locator_current_cubic_area       NUMBER;
l_locator_available_cubic_area     NUMBER;
l_locator_maximum_units            NUMBER;
l_locator_current_units            NUMBER;
l_locator_available_units          NUMBER;
l_locator_suggested_units          NUMBER;
l_debug                            NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_proc_name                        VARCHAR2(20) := 'FETCH_LOCATOR: ';
BEGIN
   /*---------------------------------------------------------------------------------------------
     Fetch the locator's current capacity.
     ---------------------------------------------------------------------------------------------*/
   SELECT location_weight_uom_code
        , max_weight
        , suggested_weight
        , suggested_cubic_area
        , current_weight
        , available_weight
        , volume_uom_code
        , max_cubic_area
        , current_cubic_area
        , available_cubic_area
        , location_maximum_units
        , location_current_units
        , location_available_units
        , location_suggested_units
     INTO l_locator_weight_uom_code
        , l_locator_max_weight
        , l_locator_suggested_weight
        , l_locator_suggested_cubic_area
        , l_locator_current_weight
        , l_locator_available_weight
        , l_locator_volume_uom_code
        , l_locator_max_cubic_area
        , l_locator_current_cubic_area
        , l_locator_available_cubic_area
        , l_locator_maximum_units
        , l_locator_current_units
        , l_locator_available_units
        , l_locator_suggested_units
     FROM MTL_ITEM_LOCATIONS
    WHERE organization_id = p_organization_id
	   AND inventory_location_id = p_inventory_location_id;

   /*------------------------------------------------------------------------------------------
     Validate the locator_current_weight,suggested_weight, current volume and suggested volume,
     Current units and Suggested Units.
     ------------------------------------------------------------------------------------------*/

   IF l_locator_current_weight IS NULL OR l_locator_current_weight < 0 THEN
     l_locator_current_weight  := 0;
     IF (l_debug = 1) THEN
        mdebug(l_proc_name||'The l_locator_current_weight is ZERO');
     END IF;
   END IF;

   IF l_locator_suggested_weight IS NULL OR l_locator_suggested_weight <0 THEN
     l_locator_suggested_weight := 0;
     IF (l_debug = 1) THEN
        mdebug(l_proc_name||'The l_locator_suggested_weight is ZERO');
     END IF;
   END IF;

    IF l_locator_current_cubic_area IS NULL OR l_locator_current_cubic_area <0 THEN
       l_locator_current_cubic_area  := 0;
       IF (l_debug = 1) THEN
          mdebug(l_proc_name||'The l_locator_current_cubic_area is ZERO');
       END IF;
   END IF;

   IF l_locator_suggested_cubic_area IS NULL OR l_locator_suggested_cubic_area <0 THEN
      l_locator_suggested_cubic_area := 0;
       IF (l_debug = 1) THEN
          mdebug(l_proc_name||'The l_locator_suggested_cubic_area is ZERO');
       END IF;
   END IF;

   IF (l_locator_current_units IS NULL) OR (l_locator_current_units < 0) then
      l_locator_current_units := 0;
      IF (l_debug = 1) THEN
         mdebug(l_proc_name||'The l_locator_current units is ZERO');
      END IF;
   END IF;

   IF (l_locator_suggested_units IS NULL) OR (l_locator_suggested_units < 0) then
      l_locator_suggested_units := 0;
      IF (l_debug = 1) THEN
         mdebug(l_proc_name||'The l_locator_suggested units is ZERO');
      END IF;
   END IF;

   /*-------------------------------------------------------------------------------------------
     Note if the max_weight of the locator is not defined, then available weight is nulled out.
     Similarly, if the max_volume is not defined, then the available volume is nulled out.
     If the max_units is not defined, the available number of units is nulled out.
     -------------------------------------------------------------------------------------------*/

   IF l_locator_max_weight IS NULL THEN
      l_locator_available_weight := NULL;
      IF (l_debug = 1) THEN
         mdebug(l_proc_name||'The l_locator_MAX_weight is NULL and hence
                                    available weight is also NULLED out');
      END IF;
   END IF;

   IF l_locator_max_cubic_area is null THEN
      l_locator_available_cubic_area := null;
      IF (l_debug = 1) THEN
         mdebug(l_proc_name||'The l_locator_MAX_cubic_area is NULL and hence
                                    available cubic_area is also nulled out');
      END IF;
   END IF;

   IF (l_locator_maximum_units IS NULL) THEN
      l_locator_available_units :=  NULL;
      IF (l_debug = 1) THEN
         mdebug(l_proc_name||'The l_locator_MAX_units is NULL and hence
                                    available units is also nulled out');
      END IF;
   END IF;

x_loc_attr.l_locator_weight_uom_code           :=    l_locator_weight_uom_code;
x_loc_attr.l_locator_max_weight                :=    l_locator_max_weight;
x_loc_attr.l_locator_suggested_weight          :=    l_locator_suggested_weight;
x_loc_attr.l_locator_suggested_cubic_area      :=    l_locator_suggested_cubic_area;
x_loc_attr.l_locator_current_weight            :=    l_locator_current_weight;
x_loc_attr.l_locator_available_weight          :=    l_locator_available_weight;
x_loc_attr.l_locator_volume_uom_code           :=    l_locator_volume_uom_code;
x_loc_attr.l_locator_max_cubic_area            :=    l_locator_max_cubic_area;
x_loc_attr.l_locator_current_cubic_area        :=    l_locator_current_cubic_area;
x_loc_attr.l_locator_available_cubic_area      :=    l_locator_available_cubic_area;
x_loc_attr.l_locator_maximum_units             :=    l_locator_maximum_units;
x_loc_attr.l_locator_current_units             :=    l_locator_current_units;
x_loc_attr.l_locator_available_units           :=    l_locator_available_units;
x_loc_attr.l_locator_suggested_units           :=    l_locator_suggested_units;

END fetch_loc_curr_capacity;

PROCEDURE fetch_item_attributes(
     	      x_return_status            OUT NOCOPY VARCHAR2
          , x_msg_data                 OUT NOCOPY VARCHAR2
          , x_msg_count                OUT NOCOPY NUMBER
          , x_item_attr                OUT NOCOPY ItemRec
          , p_inventory_item_id        IN         NUMBER
          , p_transaction_uom_code     IN         NUMBER
          , p_primary_uom_flag         IN         VARCHAR2
          , p_locator_weight_uom_code  IN         VARCHAR2
          , p_locator_volume_uom_code  IN         VARCHAR2
          , p_quantity                 IN         NUMBER
          , p_organization_id          IN         NUMBER
          , p_container_item           IN         VARCHAR2
          )
IS
   l_debug                        NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_proc_name                    VARCHAR2(50) := 'FETCH_ITEM_ATTRIBUTES: ';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   item_attributes(
       x_return_status            =>    x_return_status
     , x_msg_data                 =>    x_msg_data
     , x_msg_count                =>    x_msg_count
     , x_item_weight_uom_code     =>    x_item_attr.l_item_weight_uom_code
     , x_item_unit_weight         =>    x_item_attr.l_item_unit_weight
     , x_item_volume_uom_code     =>    x_item_attr.l_item_volume_uom_code
     , x_item_unit_volume         =>    x_item_attr.l_item_unit_volume
     , x_item_xacted_weight       =>    x_item_attr.l_item_xacted_weight
     , x_item_xacted_volume       =>    x_item_attr.l_item_xacted_volume
     , p_inventory_item_id        =>    p_inventory_item_id
     , p_transaction_uom_code     =>    p_transaction_uom_code
     , p_primary_uom_flag         =>    p_primary_uom_flag
     , p_locator_weight_uom_code  =>    p_locator_weight_uom_code
     , p_locator_volume_uom_code  =>    p_locator_volume_uom_code
     , p_quantity                 =>    p_quantity
     , p_organization_id          =>    p_organization_id
     , p_container_item           =>    p_container_item
     );
   IF x_return_status =fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'The item weight UOM code  : '||x_item_attr.l_item_weight_uom_code);
      mdebug(l_proc_name||'item unit weight          : '||x_item_attr.l_item_unit_weight);
      mdebug(l_proc_name||'item volume UOM code      : '||x_item_attr.l_item_volume_uom_code);
      mdebug(l_proc_name||'item unit volume          : '||x_item_attr.l_item_unit_volume);
      mdebug(l_proc_name||'item extracted weight     : '||x_item_attr.l_item_xacted_weight);
      mdebug(l_proc_name||'item extracted volume     : '||x_item_attr.l_item_xacted_volume);
    END IF;

END fetch_item_attributes;


PROCEDURE fetch_lpn_attr
   (
     x_return_status                    OUT NOCOPY VARCHAR2  -- return status (success/error/unexpected_error)
   , x_msg_data                         OUT NOCOPY VARCHAR2  -- message text when x_msg-count > 0
   , x_msg_count                        OUT NOCOPY NUMBER    -- number of messages in message queue
   , x_lpn_attr                         OUT nocopy LpnRec
   , p_lpn_id                           IN         NUMBER    -- Content LPN ID
   , p_org_id                           IN         NUMBER    -- Organization ID
   , p_locator_volume_uom_code          IN         VARCHAR2  -- Locator Volume UOM Code
   , p_locator_weight_uom_code          IN         VARCHAR2  -- Locator Weight UOM Code
   )
IS
   l_lpn_content_volume              NUMBER;
   l_lpn_gross_weight_uom_code       VARCHAR2(3);
   l_lpn_content_volume_uom_code     VARCHAR2(3);
   l_lpn_gross_weight                NUMBER;
   l_lpn_container_item_weight       NUMBER;
   l_lpn_container_item_vol          NUMBER;
   l_lpn_exists_in_locator           VARCHAR2(1);
   l_proc_name                       VARCHAR2(50) := 'FETCH_LPN_ATTR: ';
   l_debug                           NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'Fetching of LPN attibutes ');
   END IF;
   INV_LOC_WMS_UTILS.lpn_attributes(
                         x_return_status            =>   x_return_status
                       , x_msg_data                 =>   x_msg_data
                       , x_msg_count                =>   x_msg_count
                       , x_gross_weight_uom_code    =>   l_lpn_gross_weight_uom_code
                       , x_content_volume_uom_code  =>   l_lpn_content_volume_uom_code
                       , x_gross_weight             =>   l_lpn_gross_weight
                       , x_content_volume           =>   l_lpn_content_volume
                       , x_container_item_weight    =>   l_lpn_container_item_weight
                       , x_container_item_vol       =>   l_lpn_container_item_vol
                       , x_lpn_exists_in_locator    =>   l_lpn_exists_in_locator
                       , p_lpn_id                   =>   p_lpn_id
                       , p_org_id                   =>   p_org_id
                       );

   IF x_return_status =fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

 /*--------------------------------------------------------------------------------------
   Convert the  Volume of the LPN into the Locator's Volume UOM code.
   --------------------------------------------------------------------------------------*/
   IF l_lpn_content_volume_uom_code IS NOT NULL AND
      p_locator_volume_uom_code IS NOT NULL AND
      l_lpn_content_volume >0  THEN
      IF (l_lpn_content_volume_uom_code <> p_locator_volume_uom_code) THEN
         l_lpn_content_volume := inv_convert.inv_um_convert(
                         item_id                    => null
                       , precision                  => null
                       , from_quantity              => l_lpn_content_volume
                       , from_unit                  => l_lpn_content_volume_uom_code
                       , to_unit                    => p_locator_volume_uom_code
                       , from_name                  => null
                       , to_name                    => null
                       );
      ELSE
        l_lpn_content_volume := l_lpn_content_volume;
      END IF;
   END IF;

 /*--------------------------------------------------------------------------------------
   Conversion is not defined. Raise form trigger failure.
   --------------------------------------------------------------------------------------*/
   IF l_lpn_content_volume = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'l_lpn_content_volume is '||to_char(l_lpn_content_volume));
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the container Volume into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF l_lpn_content_volume_uom_code IS NOT NULL
      AND  p_locator_volume_uom_code IS NOT NULL
      AND  l_lpn_container_item_vol >0  THEN
      IF (l_lpn_content_volume_uom_code <> p_locator_volume_uom_code) THEN
         l_lpn_container_item_vol := inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    l_lpn_container_item_vol
                       , from_unit                  =>    l_lpn_content_volume_uom_code
                       , to_unit                    =>    p_locator_volume_uom_code
                       , from_name                  =>    null
                       , to_name                    =>    null
                       );
      ELSE
         l_lpn_container_item_vol := l_lpn_container_item_vol ;
      END IF;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'l_lpn_container_item_vol is: '||to_char(l_lpn_container_item_vol));
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_lpn_container_item_vol = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the Gross Weight of the LPN into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF  l_lpn_gross_weight_uom_code IS NOT NULL AND
       p_locator_weight_uom_code IS NOT NULL   AND
       l_lpn_gross_weight >0  THEN
       IF (p_locator_weight_uom_code<> l_lpn_gross_weight_uom_code) THEN
          l_lpn_gross_weight := inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    l_lpn_gross_weight
                       , from_unit                  =>    l_lpn_gross_weight_uom_code
                       , to_unit	                   =>    p_locator_weight_uom_code
                       , from_name                  =>    null
                       , to_name	                   =>    null
                       );
       ELSE
          l_lpn_gross_weight :=l_lpn_gross_weight;
       END IF;
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_lpn_gross_weight = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the Container Item Weight of the LPN into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF  l_lpn_gross_weight_uom_code IS NOT NULL AND
       p_locator_weight_uom_code IS NOT NULL   AND
       l_lpn_container_item_weight >0  THEN
       IF (p_locator_weight_uom_code<> l_lpn_gross_weight_uom_code) THEN
          l_lpn_container_item_weight := inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    l_lpn_container_item_weight
                       , from_unit                  =>    l_lpn_gross_weight_uom_code
                       , to_unit	                   =>    p_locator_weight_uom_code
                       , from_name                  =>    null
                       , to_name	                   =>    null
                       );
       ELSE
          l_lpn_container_item_weight :=l_lpn_container_item_weight;
       END IF;
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_lpn_container_item_weight = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'End of Content LPN attibutes ');
   END IF;

   x_lpn_attr.l_gross_weight             :=  l_lpn_gross_weight;
   x_lpn_attr.l_content_volume           :=  l_lpn_content_volume;
   x_lpn_attr.l_container_item_weight    :=  l_lpn_container_item_weight;
   x_lpn_attr.l_container_item_vol       :=  l_lpn_container_item_vol;
   x_lpn_attr.l_gross_weight_uom_code    :=  l_lpn_gross_weight_uom_code;
   x_lpn_attr.l_content_volume_uom_code  :=  l_lpn_content_volume_uom_code;
   x_lpn_attr.l_lpn_exists_in_locator    :=  l_lpn_exists_in_locator;
END fetch_lpn_attr;


PROCEDURE fetch_transfer_lpn_attr
   (
     x_return_status                    OUT NOCOPY VARCHAR2  -- return status (success/error/unexpected_error)
   , x_msg_data                         OUT NOCOPY VARCHAR2  -- message text when x_msg-count > 0
   , x_msg_count                        OUT NOCOPY NUMBER    -- number of messages in message queue
   , x_trn_lpn_attr                     OUT NOCOPY LpnRec
   , p_lpn_id                           IN         NUMBER    -- Content LPN ID
   , p_org_id                           IN         NUMBER    -- Organization ID
   , p_locator_volume_uom_code          IN         VARCHAR2  -- Locator Volume UOM Code
   , p_locator_weight_uom_code          IN         VARCHAR2  -- Locator Weight UOM Code
   )
IS
l_trn_gross_weight                NUMBER;
l_trn_content_volume              NUMBER;
l_trn_container_item_weight       NUMBER;
l_trn_container_item_vol          NUMBER;
l_trn_gross_weight_uom_code       VARCHAR2(3);
l_trn_content_volume_uom_code     VARCHAR2(3);
l_trn_lpn_exists_in_locator       VARCHAR2(1);
l_proc_name                       VARCHAR2(50) := 'FETCH_TRANSFER_LPN_ATTR: ';
l_debug                           NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'Fetching of Transfer LPN attibutes ');
   END IF;
   INV_LOC_WMS_UTILS.lpn_attributes(
                         x_return_status            =>   x_return_status
                       , x_msg_data                 =>   x_msg_data
                       , x_msg_count                =>   x_msg_count
                       , x_gross_weight_uom_code    =>   l_trn_gross_weight_uom_code
                       , x_content_volume_uom_code  =>   l_trn_content_volume_uom_code
                       , x_gross_weight             =>   l_trn_gross_weight
                       , x_content_volume           =>   l_trn_content_volume
                       , x_container_item_weight    =>   l_trn_container_item_weight
                       , x_container_item_vol       =>   l_trn_container_item_vol
                       , x_lpn_exists_in_locator    =>   l_trn_lpn_exists_in_locator
                       , p_lpn_id                   =>   p_lpn_id
                       , p_org_id                   =>   p_org_id
                       );

   IF x_return_status =fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the content Volume of Transfer LPN into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF l_trn_content_volume_uom_code IS NOT NULL AND
      p_locator_volume_uom_code is not null AND
      l_trn_content_volume >0  THEN
      IF (l_trn_content_volume_uom_code <> p_locator_volume_uom_code) THEN
         l_trn_content_volume := inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    l_trn_content_volume
                       , from_unit                  =>    l_trn_content_volume_uom_code
                       , to_unit                    =>    p_locator_volume_uom_code
                       , from_name                  =>    null
                       , to_name                    =>    null
                       );
      ELSE
         l_trn_content_volume := l_trn_content_volume;
      END IF;
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_trn_content_volume = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'l_trn_content_volume is: '||to_char(l_trn_content_volume));
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the Gross Weight of the LPN into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF l_trn_gross_weight_uom_code IS NOT NULL AND
      p_locator_weight_uom_code IS NOT NULL AND
      l_trn_gross_weight >0  THEN
      IF (l_trn_gross_weight_uom_code <> p_locator_weight_uom_code) THEN
         l_trn_gross_weight := inv_convert.inv_um_convert(
                         item_id                   =>     null
                       , precision                 =>     null
                       , from_quantity             =>     l_trn_gross_weight
                       , from_unit                 =>     l_trn_gross_weight_uom_code
                       , to_unit                   =>     p_locator_weight_uom_code
                       , from_name                 =>     null
                       , to_name                   =>     null
                       );
      ELSE
         l_trn_gross_weight := l_trn_gross_weight;
      END IF;
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_trn_gross_weight = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'l_trn_gross_weight is: '||to_char(l_trn_gross_weight));
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the Gross Weight of the Container Items into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF l_trn_gross_weight_uom_code IS NOT NULL AND
      p_locator_weight_uom_code IS NOT NULL AND
      l_trn_container_item_weight >0 THEN
      IF (l_trn_gross_weight_uom_code <> p_locator_weight_uom_code) THEN
         l_trn_container_item_weight := inv_convert.inv_um_convert(
                         item_id                   =>     null
                       , precision                 =>     null
                       , from_quantity             =>     l_trn_container_item_weight
                       , from_unit                 =>     l_trn_gross_weight_uom_code
                       , to_unit                   =>     p_locator_weight_uom_code
                       , from_name                 =>     null
                       , to_name                   =>     null
                       );
      ELSE
         l_trn_container_item_weight := l_trn_container_item_weight ;
      END IF;
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_trn_container_item_weight = -99999 THEN
     RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
     mdebug(l_proc_name||'l_trn_container_item_weight is: '||to_char(l_trn_container_item_weight));
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the Gross Volume of the Container Items into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF l_trn_content_volume_uom_code IS NOT NULL AND
      p_locator_volume_uom_code IS NOT NULL AND
      l_trn_container_item_vol >0 THEN
      IF (l_trn_content_volume_uom_code <> p_locator_volume_uom_code) THEN
         l_trn_container_item_vol := inv_convert.inv_um_convert(
                         item_id                   =>     null
                       , precision                 =>     null
                       , from_quantity             =>     l_trn_container_item_vol
                       , from_unit                 =>     l_trn_content_volume_uom_code
                       , to_unit                   =>     p_locator_volume_uom_code
                       , from_name                 =>     null
                       , to_name                   =>     null
                       );
       ELSE
         l_trn_container_item_vol := l_trn_container_item_vol ;
       END IF;
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_trn_container_item_vol = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
     mdebug(l_proc_name||'l_trn_container_item_vol is: '||to_char(l_trn_container_item_vol));
   END IF;
   x_trn_lpn_attr.l_gross_weight             :=  l_trn_gross_weight;
   x_trn_lpn_attr.l_content_volume           :=  l_trn_content_volume;
   x_trn_lpn_attr.l_container_item_weight    :=  l_trn_container_item_weight;
   x_trn_lpn_attr.l_container_item_vol       :=  l_trn_container_item_vol;
   x_trn_lpn_attr.l_gross_weight_uom_code    :=  l_trn_gross_weight_uom_code;
   x_trn_lpn_attr.l_content_volume_uom_code  :=  l_trn_content_volume_uom_code;
   x_trn_lpn_attr.l_lpn_exists_in_locator    :=  l_trn_lpn_exists_in_locator;
END fetch_transfer_lpn_attr;

PROCEDURE fetch_content_lpn_attr
   (
     x_return_status                    OUT NOCOPY VARCHAR2
   , x_msg_data                         OUT NOCOPY VARCHAR2
   , x_msg_count                        OUT NOCOPY VARCHAR2
   , x_cnt_lpn_attr                     OUT NOCOPY LpnRec
   , x_cnt_lpn_qty                      OUT NOCOPY NUMBER
   , p_lpn_id                           IN         NUMBER    -- Content LPN ID
   , p_org_id                           IN         NUMBER    -- Organization ID
   , p_locator_volume_uom_code          IN         VARCHAR2  -- Locator Volume UOM Code
   , p_locator_weight_uom_code          IN         VARCHAR2  -- Locator Weight UOM Code
   )
IS
   l_cnt_gross_weight                NUMBER ;
   l_cnt_content_volume              NUMBER;
   l_cnt_container_item_weight       NUMBER;
   l_cnt_container_item_vol          NUMBER;
   l_cnt_gross_weight_uom_code       VARCHAR2(3);
   l_cnt_content_volume_uom_code     VARCHAR2(3);
   l_cnt_lpn_exists_in_locator       VARCHAR2(1);
   l_quantity                        NUMBER := 0;
   l_proc_name                       VARCHAR2(50) := 'FETCH_CONTENT_LPN_ATTR: ';
   l_debug                           NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'Fetching attributes of the Content lpn: '||to_char(p_lpn_id));
   END IF;
   INV_LOC_WMS_UTILS.lpn_attributes(
                         x_return_status            =>   x_return_status
                       , x_msg_data                 =>   x_msg_data
                       , x_msg_count                =>   x_msg_count
                       , x_gross_weight_uom_code    =>   l_cnt_gross_weight_uom_code
                       , x_content_volume_uom_code  =>   l_cnt_content_volume_uom_code
                       , x_gross_weight             =>   l_cnt_gross_weight
                       , x_content_volume           =>   l_cnt_content_volume
                       , x_container_item_weight    =>   l_cnt_container_item_weight
                       , x_container_item_vol       =>   l_cnt_container_item_vol
                       , x_lpn_exists_in_locator    =>   l_cnt_lpn_exists_in_locator
                       , p_lpn_id                   =>   p_lpn_id
                       , p_org_id                   =>   p_org_id
                       );

   /*--------------------------------------------------------------------------------------
     Convert the content Volume of Content LPN into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF l_cnt_content_volume_uom_code IS NOT NULL AND
      p_locator_volume_uom_code IS NOT NULL AND
      l_cnt_content_volume >0  THEN
      IF (l_cnt_content_volume_uom_code <> p_locator_volume_uom_code) THEN
         l_cnt_content_volume := inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    l_cnt_content_volume
                       , from_unit                  =>    l_cnt_content_volume_uom_code
                       , to_unit                    =>    p_locator_volume_uom_code
                       , from_name                  =>    null
                       , to_name                    =>    null
                       );
      ELSE
         l_cnt_content_volume := l_cnt_content_volume;
      END IF;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'l_cnt_content_volume is: '||to_char(l_cnt_content_volume));
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_cnt_content_volume = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the container Volume into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF l_cnt_content_volume_uom_code IS NOT NULL
      AND  p_locator_volume_uom_code IS NOT NULL
      AND  l_cnt_container_item_vol >0  THEN
      IF (l_cnt_content_volume_uom_code <> p_locator_volume_uom_code) THEN
         l_cnt_container_item_vol := inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    l_cnt_container_item_vol
                       , from_unit                  =>    l_cnt_content_volume_uom_code
                       , to_unit                    =>    p_locator_volume_uom_code
                       , from_name                  =>    null
                       , to_name                    =>    null
                       );
      ELSE
         l_cnt_container_item_vol := l_cnt_container_item_vol ;
      END IF;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'l_cnt_container_item_vol is: '||to_char(l_cnt_container_item_vol));
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_cnt_container_item_vol = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the Gross Weight of the LPN into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF  l_cnt_gross_weight_uom_code IS NOT NULL AND
       p_locator_weight_uom_code IS NOT NULL   AND
       l_cnt_gross_weight >0  THEN
       IF (p_locator_weight_uom_code<> l_cnt_gross_weight_uom_code) THEN
          l_cnt_gross_weight := inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    l_cnt_gross_weight
                       , from_unit                  =>    l_cnt_gross_weight_uom_code
                       , to_unit	                   =>    p_locator_weight_uom_code
                       , from_name                  =>    null
                       , to_name	                   =>    null
                       );
       ELSE
          l_cnt_gross_weight :=l_cnt_gross_weight;
       END IF;
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_cnt_gross_weight = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   /*--------------------------------------------------------------------------------------
     Convert the Container Item Weight of the LPN into the Locator's Volume UOM code.
     --------------------------------------------------------------------------------------*/
   IF  l_cnt_gross_weight_uom_code IS NOT NULL AND
       p_locator_weight_uom_code IS NOT NULL   AND
       l_cnt_container_item_weight >0  THEN
       IF (p_locator_weight_uom_code<> l_cnt_gross_weight_uom_code) THEN
          l_cnt_container_item_weight := inv_convert.inv_um_convert(
                         item_id                    =>    null
                       , precision                  =>    null
                       , from_quantity              =>    l_cnt_container_item_weight
                       , from_unit                  =>    l_cnt_gross_weight_uom_code
                       , to_unit	                   =>    p_locator_weight_uom_code
                       , from_name                  =>    null
                       , to_name	                   =>    null
                       );
       ELSE
          l_cnt_container_item_weight :=l_cnt_container_item_weight;
       END IF;
   END IF;

   /*--------------------------------------------------------------------------------------
     Conversion is not defined. Raise form trigger failure.
     --------------------------------------------------------------------------------------*/
   IF l_cnt_container_item_weight = -99999 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'End of Content LPN attibutes ');
   END IF;

   fetch_lpn_content_qty(
                          p_lpn_id             =>    p_lpn_id
                        , x_quantity           =>    x_cnt_lpn_qty
                        );

   x_cnt_lpn_attr.l_gross_weight             :=  l_cnt_gross_weight;
   x_cnt_lpn_attr.l_content_volume           :=  l_cnt_content_volume;
   x_cnt_lpn_attr.l_container_item_weight    :=  l_cnt_container_item_weight;
   x_cnt_lpn_attr.l_container_item_vol       :=  l_cnt_container_item_vol;
   x_cnt_lpn_attr.l_gross_weight_uom_code    :=  l_cnt_gross_weight_uom_code;
   x_cnt_lpn_attr.l_content_volume_uom_code  :=  l_cnt_content_volume_uom_code;
   x_cnt_lpn_attr.l_lpn_exists_in_locator    :=  l_cnt_lpn_exists_in_locator;
END fetch_content_lpn_attr;

PROCEDURE upd_lpn_loc_cpty_for_issue
   (
     x_return_status                 OUT    NOCOPY VARCHAR2
   , x_msg_data                      OUT    NOCOPY VARCHAR2
   , x_msg_count                     OUT    NOCOPY NUMBER
   , p_loc_attr                      IN            LocatorRec
   , p_content_lpn_id                IN            NUMBER
   , p_cnt_lpn_attr                  IN            LpnRec
   , p_transaction_action_id         IN            NUMBER
   , p_item_attr                     IN            ItemRec
   , p_quantity                      IN            NUMBER
   , p_inventory_location_id         IN            NUMBER
   , p_organization_id               IN            NUMBER
   )
IS
   l_proc_name                    VARCHAR2(50) := 'UPD_LPN_LOC_CPTY_FOR_ISSUE:';
   l_locator_current_cubic_area   NUMBER := 0;
   l_locator_available_cubic_area NUMBER;
   l_locator_current_weight       NUMBER := 0;
   l_locator_available_weight     NUMBER;
   l_locator_current_units        NUMBER := 0;
   l_locator_available_units      NUMBER;
   l_debug                        NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 1) THEN
    mdebug(l_proc_name||'transaction Type is issue ');
  END IF;

  /* Reduce the weight of the locator by the weight of the content lpn.*/
  l_locator_current_weight   := p_loc_attr.l_locator_current_weight - p_cnt_lpn_attr.l_gross_weight;
  IF l_locator_current_weight <0 THEN
     l_locator_current_weight := 0;
  END IF;

  l_locator_available_weight := p_loc_attr.l_locator_Max_weight-(l_locator_current_weight
                                                                  + p_loc_attr.l_locator_suggested_weight);
  IF l_locator_available_weight <0 THEN
     l_locator_available_weight := 0;
  END IF;
  INV_LOC_WMS_UTILS.cal_locator_current_volume(
                x_return_status               =>       x_return_status
              , x_msg_data                    =>       x_msg_data
              , x_msg_count                   =>       x_msg_count
              , x_locator_current_volume      =>       l_locator_current_cubic_area
              , p_trn_lpn_container_item_vol  =>       null
              , p_trn_lpn_content_volume      =>       null
              , p_cnt_lpn_container_item_vol  =>       p_cnt_lpn_attr.l_container_item_vol
              , p_cnt_lpn_content_volume      =>       p_cnt_lpn_attr.l_content_volume
              , p_lpn_container_item_vol      =>       null
              , p_lpn_content_volume          =>       null
              , p_xacted_volume               =>       p_cnt_lpn_attr.l_content_volume
              , p_locator_current_cubic_area  =>       p_loc_attr.l_locator_current_cubic_area
              , p_transaction_action_id       =>       p_transaction_action_id
              , p_transfer_lpn_id             =>       null
              , p_content_lpn_id              =>       p_content_lpn_id
              , p_lpn_id                      =>       null
              , p_trn_lpn_exists_in_loc       =>       null
             );
   IF x_return_status =fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_locator_current_units := p_loc_attr.l_locator_current_units - p_quantity;

   IF l_locator_current_units <0 THEN
      l_locator_current_units := 0;
   END IF;

   IF l_locator_current_cubic_area <0 THEN
      l_locator_current_cubic_area := 0;
   END IF;
   l_locator_available_cubic_area := p_loc_attr.l_locator_max_cubic_area-(l_locator_current_cubic_area +
                                                                   p_loc_attr.l_locator_suggested_cubic_area) ;
   IF l_locator_available_cubic_area <0 THEN
      l_locator_available_cubic_area := 0;
   END IF;

   l_locator_available_units := p_loc_attr.l_locator_maximum_units-(l_locator_current_units +
                                                                 p_loc_attr.l_locator_suggested_units) ;
   IF l_locator_available_units <0 THEN
      l_locator_available_units := 0;
   END IF;

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'issue transaction is successful ');
   END IF;

   UPDATE MTL_ITEM_LOCATIONS mil
      SET current_weight           = nvl(l_locator_current_weight,current_weight)
        , available_weight         = nvl(l_locator_available_weight,available_weight)
        , current_cubic_area       = nvl(l_locator_current_cubic_area,current_cubic_area)
        , available_cubic_area     = nvl(l_locator_available_cubic_area,available_cubic_area)
        , location_current_units   = nvl(l_locator_current_units,location_current_units)
        , location_available_units = nvl(l_locator_available_units,mil.location_available_units)
    WHERE inventory_location_id    = p_inventory_location_id
      AND organization_id          = p_organization_id;

   IF l_debug = 1 THEN
      mdebug(l_proc_name||'Locator Current Weight after update      : '||l_locator_current_weight);
      mdebug(l_proc_name||'Locator Available Weight after update    : '||l_locator_available_weight);
      mdebug(l_proc_name||'Locator Current Cubic Area after update  : '||l_locator_current_cubic_area);
      mdebug(l_proc_name||'Locator Available Cubic Area after update: '||l_locator_available_cubic_area);
      mdebug(l_proc_name||'Locator Current Units after update       : '||l_locator_current_units);
      mdebug(l_proc_name||'Locator Available Units after update     : '||l_locator_available_units);
   END IF;
END upd_lpn_loc_cpty_for_issue;

PROCEDURE upd_lpn_loc_cpty_for_rcpt
   (
     x_return_status                 OUT    NOCOPY VARCHAR2
   , x_msg_data                      OUT    NOCOPY VARCHAR2
   , x_msg_count                     OUT    NOCOPY NUMBER
   , p_loc_attr                      IN            LocatorRec
   , p_transfer_lpn_id               IN            NUMBER
   , p_trn_lpn_attr                  IN            LpnRec
   , p_transaction_action_id         IN            NUMBER
   , p_item_attr                     IN            ItemRec
   , p_quantity                      IN            NUMBER
   , p_inventory_location_id         IN            NUMBER
   , p_organization_id               IN            NUMBER
   )
IS
   l_proc_name                    VARCHAR2(50) := 'UPD_LPN_LOC_CPTY_FOR_RCPT:';
   l_locator_current_cubic_area   NUMBER := 0;
   l_locator_available_cubic_area NUMBER;
   l_locator_current_weight       NUMBER := 0;
   l_locator_available_weight     NUMBER;
   l_locator_current_units        NUMBER := 0;
   l_locator_available_units      NUMBER;
   l_debug                        NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 1) THEN
    mdebug(l_proc_name||'transaction Type is receipt ');
  END IF;

  /*-------------------------------------------------------------------------------------
    If Transfer LPN does not exist in the receipt locator and it is not null, then add the
    weight of the container item to the locator current weight
    -------------------------------------------------------------------------------------*/
  IF p_trn_lpn_attr.l_lpn_exists_in_locator ='N' AND p_transfer_lpn_id IS NOT NULL THEN
     l_locator_current_weight   := p_loc_attr.l_locator_current_weight + p_trn_lpn_attr.l_container_item_weight ;
     l_locator_current_weight   := l_locator_current_weight + p_item_attr.l_item_xacted_weight;
  ELSE
     l_locator_current_weight   := p_loc_attr.l_locator_current_weight + p_item_attr.l_item_xacted_weight;
  END IF;

  l_locator_available_weight := p_loc_attr.l_locator_Max_weight-(l_locator_current_weight +
                      p_loc_attr.l_locator_suggested_weight);
  IF l_locator_available_weight <0 THEN
     l_locator_available_weight := 0;
  END IF;

  l_locator_current_units   := p_loc_attr.l_locator_current_units + p_quantity;
  IF l_locator_current_units <0 THEN
     l_locator_current_units := 0;
  END IF;

  l_locator_available_units := p_loc_attr.l_locator_maximum_units-(l_locator_current_units +
                      p_loc_attr.l_locator_suggested_units);
  IF l_locator_available_units <0 THEN
     l_locator_available_units := 0;
  END IF;

  IF p_transfer_lpn_id IS NULL THEN
    l_locator_current_cubic_area := p_loc_attr.l_locator_current_cubic_area + p_item_attr.l_item_xacted_volume;
  ELSE
    INV_LOC_WMS_UTILS.cal_locator_current_volume(
              x_return_status               =>       x_return_status
            , x_msg_data                    =>       x_msg_data
            , x_msg_count                   =>       x_msg_count
            , x_locator_current_volume      =>       l_locator_current_cubic_area
            , p_trn_lpn_container_item_vol  =>       p_trn_lpn_attr.l_container_item_vol
            , p_trn_lpn_content_volume      =>       p_trn_lpn_attr.l_content_volume
            , p_cnt_lpn_container_item_vol  =>       null
            , p_cnt_lpn_content_volume      =>       null
            , p_lpn_container_item_vol      =>       p_trn_lpn_attr.l_container_item_vol
            , p_lpn_content_volume          =>       p_trn_lpn_attr.l_content_volume
            , p_xacted_volume               =>       p_item_attr.l_item_xacted_volume
            , p_locator_current_cubic_area  =>       p_loc_attr.l_locator_current_cubic_area
            , p_transaction_action_id       =>       p_transaction_action_id
            , p_transfer_lpn_id             =>       p_transfer_lpn_id
            , p_content_lpn_id              =>       null
            , p_lpn_id                      =>       p_transfer_lpn_id
            , p_trn_lpn_exists_in_loc       =>       p_trn_lpn_attr.l_lpn_exists_in_locator
            );
  END IF;

  l_locator_available_cubic_area := p_loc_attr.l_locator_Max_Cubic_area-(l_locator_current_cubic_area +
                            p_loc_attr.l_locator_suggested_cubic_area) ;
  IF l_locator_available_cubic_area <0 THEN
     l_locator_available_cubic_area := 0;
  END IF;

  UPDATE MTL_ITEM_LOCATIONS
     SET current_weight           = nvl(l_locator_current_weight,current_weight)
       , available_weight         = nvl(l_locator_available_weight,available_weight)
       , current_cubic_area       = nvl(l_locator_current_cubic_area,current_cubic_area)
       , available_cubic_area     = nvl(l_locator_available_cubic_area,available_cubic_area)
       , location_current_units   = nvl(l_locator_current_units,location_current_units)
       , location_available_units = nvl(l_locator_available_units,location_available_units)
   WHERE inventory_location_id    = p_inventory_location_id
     AND organization_id          = p_organization_id;

  IF l_debug = 1 THEN
     mdebug(l_proc_name||'Locator Current Weight after update      : '||l_locator_current_weight);
     mdebug(l_proc_name||'Locator Available Weight after update    : '||l_locator_available_weight);
     mdebug(l_proc_name||'Locator Current Cubic Area after update  : '||l_locator_current_cubic_area);
     mdebug(l_proc_name||'Locator Available Cubic Area after update: '||l_locator_available_cubic_area);
     mdebug(l_proc_name||'Locator Current Units after update       : '||l_locator_current_units);
     mdebug(l_proc_name||'Locator Available Units after update     : '||l_locator_available_units);
  END IF;

END upd_lpn_loc_cpty_for_rcpt;

-- bug#2876849. Added the two new parameters from org id and from loc id. These are needed
-- for a transfer transaction to decrement the capacity from the souce locator.
-- Also modified the code to handle case of Staging Xfr where the transfer_lpn_id is
-- populated in MMTT.

PROCEDURE upd_lpn_loc_cpty_for_xfr(
            x_return_status                   OUT NOCOPY VARCHAR2
          , x_msg_data                        OUT NOCOPY VARCHAR2
          , x_msg_count                       OUT NOCOPY VARCHAR2
          , p_loc_attr                        IN         LocatorRec
          , p_content_lpn_id                  IN         NUMBER
          , p_cnt_lpn_attr                    IN         LpnRec
          , p_trn_lpn_id                      IN         NUMBER
          , p_trn_lpn_attr                    IN         LpnRec
          , p_lpn_id                          IN         NUMBER
          , p_lpn_attr                        IN         LpnRec
          , p_transaction_action_id           IN         NUMBER
          , p_item_attr                       IN         ItemRec
          , p_quantity                        IN         NUMBER
          , p_inventory_location_id           IN         NUMBER
          , p_organization_id                 IN         NUMBER
          , p_inventory_item_id               IN         NUMBER
          , p_transaction_uom_code            IN         VARCHAR2
          , p_primary_uom_flag                IN         VARCHAR2
          , p_from_org_id                     IN         NUMBER
          , p_from_loc_id                     IN         NUMBER
          )
IS
   l_old_inventory_location_id            NUMBER;
   l_old_organization_id                  NUMBER :=p_from_org_id;
   l_old_locator_id                       NUMBER :=p_from_loc_id;
   l_old_loc_attr                         LocatorRec;
   l_cnt_lpn_attr                         LpnRec;
   l_lpn_attr                             LpnRec;
   l_item_attr                            ItemRec;
   l_old_loc_current_weight               NUMBER := 0;
   l_old_loc_available_weight             NUMBER;
   l_old_loc_current_vol                  NUMBER;
   l_old_loc_available_vol                NUMBER;
   l_old_loc_current_units                NUMBER := 0;
   l_old_loc_available_units              NUMBER;
   l_loc_current_weight                   NUMBER := 0;
   l_loc_available_weight                 NUMBER;
   l_loc_current_vol                      NUMBER := 0;
   l_loc_available_vol                    NUMBER;
   l_loc_current_units                    NUMBER := 0;
   l_loc_available_units                  NUMBER;
   l_quantity                             NUMBER := p_quantity;
   l_update_table                         BOOLEAN := TRUE;
   l_content_lpn_quantity                 NUMBER;

   l_proc_name                    VARCHAR2(50) := 'UPD_LPN_LOC_CPTY_FOR_XFR:';
   l_debug                        NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*--------------------------------------------------------------------------------------------
     Fetch the actual Inventory Location ID for the source Locator.
     --------------------------------------------------------------------------------------------*/

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'From Organization Id :'||l_old_organization_id);
      mdebug(l_proc_name||'From Locator ID      :'||l_old_locator_id);
   END IF;
   fetch_locator(
            p_inventory_location_id          =>    l_old_locator_id
          , p_organization_id                =>    l_old_organization_id
          , x_locator_id                     =>    l_old_inventory_location_id
          );

   -- Bug# 3067627
   IF (l_debug = 1) THEN
      mdebug('Before locking source locator ' || l_old_inventory_location_id || ' in UPD_LPN_LOC_CPTY_FOR_XFR');
   END IF;

   SELECT inventory_location_id INTO l_old_inventory_location_id
   FROM mtl_item_locations
   WHERE  inventory_location_id = l_old_inventory_location_id
       and organization_id = l_old_organization_id
   FOR UPDATE NOWAIT;

   IF (l_debug = 1) THEN
      mdebug('After locking source locator ' || l_old_inventory_location_id || ' in UPD_LPN_LOC_CPTY_FOR_XFR');
   END IF;

   /*---------------------------------------------------------------------------------------------
     Fetch the Source locator's current capacity.
     ---------------------------------------------------------------------------------------------*/
   fetch_loc_curr_capacity(
            p_inventory_location_id          =>    l_old_inventory_location_id
          , p_organization_id                =>    l_old_organization_id
          , x_loc_attr                       =>    l_old_loc_attr
          );

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'At the start of the program             : ');
      mdebug(l_proc_name||'The Source locator id used is           : '||l_old_inventory_location_id);
      mdebug(l_proc_name||'The attributes of Source locator follow : ');
      mdebug(l_proc_name||'l_Source_locator_weight_uom_code        : '||l_old_loc_attr.l_locator_weight_uom_code);
      mdebug(l_proc_name||'l_Source_locator_max_weight             : '||l_old_loc_attr.l_locator_max_weight);
      mdebug(l_proc_name||'l_Source_locator_suggested_weight       : '||l_old_loc_attr.l_locator_suggested_weight);
      mdebug(l_proc_name||'l_Source_locator_suggested_cubic_area   : '||l_old_loc_attr.l_locator_suggested_cubic_area);
      mdebug(l_proc_name||'l_Source_locator_current_weight         : '||l_old_loc_attr.l_locator_current_weight);
      mdebug(l_proc_name||'l_Source_locator_available_weight       : '||l_old_loc_attr.l_locator_available_weight);
      mdebug(l_proc_name||'l_Source_locator_volume_uom_code        : '||l_old_loc_attr.l_locator_volume_uom_code);
      mdebug(l_proc_name||'l_Source_locator_max_cubic_area         : '||l_old_loc_attr.l_locator_max_cubic_area);
      mdebug(l_proc_name||'l_Source_locator_current_cubic_area     : '||l_old_loc_attr.l_locator_current_cubic_area);
      mdebug(l_proc_name||'l_Source_locator_available_cubic_area   : '||l_old_loc_attr.l_locator_available_cubic_area);
      mdebug(l_proc_name||'l_Source_locator_max_units              : '||l_old_loc_attr.l_locator_maximum_units);
      mdebug(l_proc_name||'l_Source_locator_current_units          : '||l_old_loc_attr.l_locator_current_units);
      mdebug(l_proc_name||'l_Source_locator_available_units        : '||l_old_loc_attr.l_locator_available_units);
      mdebug(l_proc_name||'l_Source_locator_suggested_units        : '||l_old_loc_attr.l_locator_suggested_units);
      mdebug(l_proc_name||'transaction quantity                    : '||l_quantity);
    END IF;

    /*-------------------------------------------------------------------------------------------------------
      Get the attributes for the inventory_item_id that is passed as input parameter in source locators units
      -------------------------------------------------------------------------------------------------------*/

    IF  p_inventory_item_id IS NOT NULL AND p_inventory_item_id <>-1 THEN
        fetch_item_attributes(
     	      x_return_status            =>    x_return_status
          , x_msg_data                 =>    x_msg_data
          , x_msg_count                =>    x_msg_count
          , x_item_attr                =>    l_item_attr
          , p_inventory_item_id        =>    p_inventory_item_id
          , p_transaction_uom_code     =>    p_transaction_uom_code
          , p_primary_uom_flag         =>    p_primary_uom_flag
          , p_locator_weight_uom_code  =>    l_old_loc_attr.l_locator_weight_uom_code
          , p_locator_volume_uom_code  =>    l_old_loc_attr.l_locator_volume_uom_code
          , p_quantity                 =>    p_quantity
          , p_organization_id          =>    l_old_organization_id
          , p_container_item           =>    null
          );
        IF x_return_status =fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
           mdebug(l_proc_name||'The item weight UOM code  : '||l_item_attr.l_item_weight_uom_code);
           mdebug(l_proc_name||'item unit weight          : '||l_item_attr.l_item_unit_weight);
           mdebug(l_proc_name||'item volume UOM code      : '||l_item_attr.l_item_volume_uom_code);
           mdebug(l_proc_name||'item unit volume          : '||l_item_attr.l_item_unit_volume);
           mdebug(l_proc_name||'item extracted weight     : '||l_item_attr.l_item_xacted_weight);
           mdebug(l_proc_name||'item extracted volume     : '||l_item_attr.l_item_xacted_volume);
           mdebug(l_proc_name||'inventory item id         : '||p_inventory_item_id);
           mdebug(l_proc_name||'transaction uom code      : '||p_transaction_uom_code);
           mdebug(l_proc_name||'primary UOM flag          : '||p_primary_uom_flag);
           mdebug(l_proc_name||'locator weight UOM code   : '||l_old_loc_attr.l_locator_weight_uom_code);
           mdebug(l_proc_name||'locator volume UOM code   : '||l_old_loc_attr.l_locator_volume_uom_code);
           mdebug(l_proc_name||'transacted quantity       : '||p_quantity);
           mdebug(l_proc_name||'Organization id           : '||l_old_organization_id);
           mdebug(l_proc_name||'container item            : ');
         END IF;
    END IF;

    /*------------------------------------------------------------------------------------
      Fetch the attributes of Content LPN if passed, in Source locator's Units
      ------------------------------------------------------------------------------------*/

    IF p_content_lpn_id is not null THEN
       fetch_content_lpn_attr
          (
            x_return_status                =>    x_return_status
          , x_msg_data                     =>    x_msg_data
          , x_msg_count                    =>    x_msg_count
          , x_cnt_lpn_attr                 =>    l_cnt_lpn_attr
          , x_cnt_lpn_qty                  =>    l_content_lpn_quantity
          , p_lpn_id                       =>    p_content_lpn_id
          , p_org_id                       =>    p_organization_id
          , p_locator_volume_uom_code      =>    l_old_loc_attr.l_locator_volume_uom_code
          , p_locator_weight_uom_code      =>    l_old_loc_attr.l_locator_weight_uom_code
          );
        IF x_return_status =fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        IF p_inventory_item_id = -1 THEN
           l_quantity := l_content_lpn_quantity;
        END IF;
        IF (l_debug = 1) THEN
           mdebug(l_proc_name||'l_cnt_gross_weight_uom_code    : '||l_cnt_lpn_attr.l_gross_weight_uom_code);
           mdebug(l_proc_name||'l_cnt_content_volume_uom_code  : '||l_cnt_lpn_attr.l_content_volume_uom_code);
           mdebug(l_proc_name||'l_cnt_gross_weight             : '||l_cnt_lpn_attr.l_gross_weight);
           mdebug(l_proc_name||'l_cnt_content_volume           : '||l_cnt_lpn_attr.l_content_volume);
           mdebug(l_proc_name||'l_cnt_container_item_weight    : '||l_cnt_lpn_attr.l_container_item_weight);
           mdebug(l_proc_name||'l_cnt_container_item_vol       : '||l_cnt_lpn_attr.l_container_item_vol);
           mdebug(l_proc_name||'l_cnt_lpn_exists_in_locator    : '||l_cnt_lpn_attr.l_lpn_exists_in_locator);
           mdebug(l_proc_name||'p_content_lpn_id               : '||p_content_lpn_id);
           mdebug(l_proc_name||'p_organization_id              : '||p_organization_id);
           mdebug(l_proc_name||'locator weight UOM code        : '||l_old_loc_attr.l_locator_weight_uom_code);
           mdebug(l_proc_name||'lpn content qty                : '||l_quantity);
         END IF;
    END IF; /* End of p_content_lpn_id is not null */

    /*----------------------------------------------------------------------------------------
      Fetch the attributes of LPN if passed, in Source Locator's UOM
      ----------------------------------------------------------------------------------------*/

    IF p_lpn_id is not null THEN
       fetch_lpn_attr
          (
            x_return_status                =>    x_return_status
          , x_msg_data                     =>    x_msg_data
          , x_msg_count                    =>    x_msg_count
          , x_lpn_attr                     =>    l_lpn_attr
          , p_lpn_id                       =>    p_lpn_id
          , p_org_id                       =>    p_organization_id
          , p_locator_volume_uom_code      =>    l_old_loc_attr.l_locator_volume_uom_code
          , p_locator_weight_uom_code      =>    l_old_loc_attr.l_locator_weight_uom_code
          );
        IF x_return_status =fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        IF (l_debug = 1) THEN
           mdebug(l_proc_name||'l_lpn_gross_weight_uom_code    : '||l_lpn_attr.l_gross_weight_uom_code);
           mdebug(l_proc_name||'l_lpn_content_volume_uom_code  : '||l_lpn_attr.l_content_volume_uom_code);
           mdebug(l_proc_name||'l_lpn_gross_weight             : '||l_lpn_attr.l_gross_weight);
           mdebug(l_proc_name||'l_lpn_content_volume           : '||l_lpn_attr.l_content_volume);
           mdebug(l_proc_name||'l_lpn_container_item_weight    : '||l_lpn_attr.l_container_item_weight);
           mdebug(l_proc_name||'l_lpn_container_item_vol       : '||l_lpn_attr.l_container_item_vol);
           mdebug(l_proc_name||'l_lpn_exists_in_locator        : '||l_lpn_attr.l_lpn_exists_in_locator);
           mdebug(l_proc_name||'p_lpn_id                       : '||p_lpn_id);
           mdebug(l_proc_name||'p_organization_id              : '||p_organization_id);
           mdebug(l_proc_name||'locator weight UOM code        : '||l_old_loc_attr.l_locator_weight_uom_code);
           mdebug(l_proc_name||'locator volume UOM code        : '||l_old_loc_attr.l_locator_volume_uom_code);
         END IF;
    END IF; /*End of if lpn */

    /*-------------------------------------------------------------------------------------------------------
      First Update the Source Locator's Capacity.
        * If content lpn is passed  => Issue the lpn from the source locator.
        * If lpn id is passed       => check whether the whole lpn is being transfered or not. if so, need to
                                       decrement the container weight and volume, else decrement the transacted
                                       items weight and volume.
      Then Update the destination Locator's capacity.
        * If content lpn is passesd  => receive into it.
        * If transfer lpn is passed  => receive into it.
        * else                       => receive loose
      -------------------------------------------------------------------------------------------------------*/
/* Do update the locator capacity only if the locator capacity is finite */
  IF NOT (l_old_loc_attr.l_locator_maximum_units IS NULL AND l_old_loc_attr.l_locator_max_weight IS NULL AND l_old_loc_attr.l_locator_max_cubic_area IS NULL) THEN

    IF p_content_lpn_id IS NOT NULL THEN
       /*-----------------------------------------------------------------
         Issue Content LPN from the source locator
         -----------------------------------------------------------------*/
       upd_lpn_loc_cpty_for_issue(
            x_return_status                   =>        x_return_status
          , x_msg_data                        =>        x_msg_data
          , x_msg_count                       =>        x_msg_count
          , p_loc_attr                        =>        l_old_loc_attr
          , p_content_lpn_id                  =>        p_content_lpn_id
          , p_cnt_lpn_attr                    =>        l_cnt_lpn_attr
          , p_transaction_action_id           =>        1
          , p_item_attr                       =>        p_item_attr
          , p_quantity                        =>        l_quantity
          , p_inventory_location_id           =>        l_old_inventory_location_id
          , p_organization_id                 =>        l_old_organization_id
          );
       IF x_return_status =fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
       l_update_table := FALSE;
    ELSIF p_lpn_id IS NOT NULL THEN
          fetch_lpn_content_qty(
                                 p_lpn_id       =>    p_lpn_id
                               , x_quantity     =>    l_quantity
                               );
          IF p_quantity = l_quantity THEN
             /*-----------------------------------------------------------------
               Issue LPN from the source locator
               -----------------------------------------------------------------*/
             upd_lpn_loc_cpty_for_issue(
                  x_return_status                   =>        x_return_status
                , x_msg_data                        =>        x_msg_data
                , x_msg_count                       =>        x_msg_count
                , p_loc_attr                        =>        l_old_loc_attr
                , p_content_lpn_id                  =>        p_lpn_id
                , p_cnt_lpn_attr                    =>        l_lpn_attr
                , p_transaction_action_id           =>        1
                , p_item_attr                       =>        p_item_attr
                , p_quantity                        =>        l_quantity
                , p_inventory_location_id           =>        l_old_inventory_location_id
                , p_organization_id                 =>        l_old_organization_id
                );
             IF x_return_status =fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
             l_update_table := FALSE;
          ELSE
             /*-----------------------------------------------------------------
               Issue transacted Item Capacity from the source locator (LPN)
               -----------------------------------------------------------------*/
             l_old_loc_current_weight   := l_old_loc_attr.l_locator_current_weight - l_item_attr.l_item_xacted_weight;
             IF l_old_loc_current_weight <0 THEN
                l_old_loc_current_weight := 0;
             END IF;

             l_old_loc_available_weight := l_old_loc_attr.l_locator_max_weight - ( l_old_loc_current_weight +
                                               l_old_loc_attr.l_locator_suggested_weight);
             IF l_old_loc_available_weight <0 THEN
                l_old_loc_available_weight := 0;
             END IF;


             l_old_loc_current_units   :=  l_old_loc_attr.l_locator_current_units - p_quantity;

             IF l_old_loc_current_units <0 THEN
                l_old_loc_current_units := 0;
             END IF;

             l_old_loc_available_units := l_old_loc_attr.l_locator_maximum_units - ( l_old_loc_current_units +
                                          l_old_loc_attr.l_locator_suggested_units);
             IF l_old_loc_available_units <0 THEN
                l_old_loc_available_units := 0;
             END IF;

             IF l_lpn_attr.l_content_volume > l_lpn_attr.l_container_item_vol THEN
                IF l_lpn_attr.l_container_item_vol = 0
                   OR (l_lpn_attr.l_content_volume - l_item_attr.l_item_xacted_volume
                                                 >= l_lpn_attr.l_container_item_vol) THEN
                   l_old_loc_current_vol := l_old_loc_attr.l_locator_current_cubic_area - l_item_attr.l_item_xacted_volume;
                ELSIF (l_lpn_attr.l_content_volume - l_item_attr.l_item_xacted_volume
                                                 < l_lpn_attr.l_container_item_vol) THEN
                   l_old_loc_current_vol := l_old_loc_attr.l_locator_current_cubic_area -
                                            ( l_lpn_attr.l_content_volume - l_lpn_attr.l_container_item_vol );
                END IF;
             END IF;

             IF l_old_loc_current_vol < 0 THEN
                l_old_loc_current_vol := 0;
             END IF;

             l_old_loc_available_vol := l_old_loc_attr.l_locator_max_cubic_area - ( l_old_loc_current_vol
                                                                + l_old_loc_attr.l_locator_suggested_cubic_area);
             IF l_old_loc_available_vol < 0 THEN
                l_old_loc_available_vol := 0;
             END IF;
          END IF;
    ELSE
       /*-----------------------------------------------------------------
         Issue transacted Item Capacity from the source locator (LPN)
         -----------------------------------------------------------------*/
       l_old_loc_current_weight   := l_old_loc_attr.l_locator_current_weight - l_item_attr.l_item_xacted_weight;
       IF l_old_loc_current_weight <0 THEN
          l_old_loc_current_weight := 0;
       END IF;

       l_old_loc_available_weight := l_old_loc_attr.l_locator_max_weight - ( l_old_loc_current_weight +
                                         l_old_loc_attr.l_locator_suggested_weight);
       IF l_old_loc_available_weight <0 THEN
          l_old_loc_available_weight := 0;
       END IF;


       l_old_loc_current_units   :=  l_old_loc_attr.l_locator_current_units - p_quantity;

       IF l_old_loc_current_units <0 THEN
          l_old_loc_current_units := 0;
       END IF;

       l_old_loc_available_units := l_old_loc_attr.l_locator_maximum_units - ( l_old_loc_current_units +
                                    l_old_loc_attr.l_locator_suggested_units);
       IF l_old_loc_available_units <0 THEN
          l_old_loc_available_units := 0;
       END IF;

       l_old_loc_current_vol := l_old_loc_attr.l_locator_current_cubic_area - l_item_attr.l_item_xacted_volume;
       IF l_old_loc_current_vol < 0 THEN
          l_old_loc_current_vol := 0;
       END IF;

       l_old_loc_available_vol := l_old_loc_attr.l_locator_max_cubic_area - ( l_old_loc_current_vol
                                                          + l_old_loc_attr.l_locator_suggested_cubic_area);
       IF l_old_loc_available_vol < 0 THEN
          l_old_loc_available_vol := 0;
       END IF;
  END IF;

  IF l_update_table THEN
     UPDATE MTL_ITEM_LOCATIONS
        SET current_weight           = nvl(l_old_loc_current_weight,current_weight)
          , available_weight         = nvl(l_old_loc_available_weight,available_weight)
          , current_cubic_area       = nvl(l_old_loc_current_vol,current_cubic_area)
          , available_cubic_area     = nvl(l_old_loc_available_vol,available_cubic_area)
          , location_current_units   = nvl(l_old_loc_current_units,location_current_units)
          , location_available_units = nvl(l_old_loc_available_units,location_available_units)
      WHERE inventory_location_id    = l_old_inventory_location_id
        AND organization_id          = l_old_organization_id;
  END IF;
  END IF; /* Update locator capacity only if the locator capacity is finite */

/* Do update the locator capacity only if the locator capacity is finite */
 IF NOT (p_loc_attr.l_locator_maximum_units IS NULL AND p_loc_attr.l_locator_max_weight IS NULL AND p_loc_attr.l_locator_max_cubic_area IS NULL) THEN

    IF p_trn_lpn_id IS NOT NULL THEN
       /*-----------------------------------------------------------------
         Receive the transfer LPN into the destination Locator.
         -----------------------------------------------------------------*/
       upd_lpn_loc_cpty_for_rcpt (
            x_return_status                   =>        x_return_status
          , x_msg_data                        =>        x_msg_data
          , x_msg_count                       =>        x_msg_count
          , p_loc_attr                        =>        p_loc_attr
          , p_transfer_lpn_id                 =>        p_trn_lpn_id
          , p_trn_lpn_attr                    =>        p_trn_lpn_attr
          , p_transaction_action_id           =>        27
          , p_item_attr                       =>        p_item_attr
          , p_quantity                        =>        p_quantity
          , p_inventory_location_id           =>        p_inventory_location_id
          , p_organization_id                 =>        p_organization_id
          );
       IF x_return_status =fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    ELSIF p_content_lpn_id IS NOT NULL THEN
        /*-----------------------------------------------------------------
         Receive the Content LPN into the destination Locator.
         -----------------------------------------------------------------*/
       upd_lpn_loc_cpty_for_rcpt (
            x_return_status                   =>        x_return_status
          , x_msg_data                        =>        x_msg_data
          , x_msg_count                       =>        x_msg_count
          , p_loc_attr                        =>        p_loc_attr
          , p_transfer_lpn_id                 =>        p_content_lpn_id
          , p_trn_lpn_attr                    =>        p_cnt_lpn_attr
          , p_transaction_action_id           =>        27
          , p_item_attr                       =>        p_item_attr
          , p_quantity                        =>        l_quantity
          , p_inventory_location_id           =>        p_inventory_location_id
          , p_organization_id                 =>        p_organization_id
          );
       IF x_return_status =fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    ELSE
       /*-------------------------------------------------------------------
         Receive transacted loose Item Capacity into the destination locator
         -------------------------------------------------------------------*/
       l_loc_current_weight   := p_loc_attr.l_locator_current_weight + p_item_attr.l_item_xacted_weight;
       IF l_loc_current_weight <0 THEN
          l_loc_current_weight := 0;
       END IF;

       l_loc_available_weight := p_loc_attr.l_locator_max_weight - ( l_loc_current_weight +
                                         p_loc_attr.l_locator_suggested_weight);
       IF l_loc_available_weight <0 THEN
          l_loc_available_weight := 0;
       END IF;

       l_loc_current_units   :=  p_loc_attr.l_locator_current_units + p_quantity;

       IF l_loc_current_units <0 THEN
          l_loc_current_units := 0;
       END IF;

       l_loc_available_units := p_loc_attr.l_locator_maximum_units - ( l_loc_current_units +
                                    p_loc_attr.l_locator_suggested_units);
       IF l_loc_available_units <0 THEN
          l_loc_available_units := 0;
       END IF;

       l_loc_current_vol := p_loc_attr.l_locator_current_cubic_area + p_item_attr.l_item_xacted_volume;

       IF l_loc_current_vol < 0 THEN
          l_loc_current_vol := 0;
       END IF;

       l_loc_available_vol := p_loc_attr.l_locator_max_cubic_area - ( l_loc_current_vol
                                                          + p_loc_attr.l_locator_suggested_cubic_area);
       IF l_loc_available_vol < 0 THEN
          l_loc_available_vol := 0;
       END IF;

       UPDATE MTL_ITEM_LOCATIONS
          SET current_weight           = nvl(l_loc_current_weight,current_weight)
            , available_weight         = nvl(l_loc_available_weight,available_weight)
            , current_cubic_area       = nvl(l_loc_current_vol,current_cubic_area)
            , available_cubic_area     = nvl(l_loc_available_vol,available_cubic_area)
            , location_current_units   = nvl(l_loc_current_units,location_current_units)
            , location_available_units = nvl(l_loc_available_units,location_available_units)
        WHERE inventory_location_id    = p_inventory_location_id
          AND organization_id          = p_organization_id;
    END IF;
   END IF; /* Update locator capacity only if the locator capacity is finite */
END upd_lpn_loc_cpty_for_xfr;

PROCEDURE upd_lpn_loc_cpty_for_unpack
   (
     x_return_status                 OUT    NOCOPY VARCHAR2
   , x_msg_data                      OUT    NOCOPY VARCHAR2
   , x_msg_count                     OUT    NOCOPY NUMBER
   , p_content_lpn_id                IN            NUMBER
   , p_cnt_lpn_attr                  IN            LpnRec
   , p_lpn_id                        IN            NUMBER
   , p_lpn_attr                      IN            LpnRec
   , p_inventory_location_id         IN            NUMBER
   , p_loc_attr                      IN            LocatorRec
   , p_organization_id               IN            NUMBER
   , p_item_attr                     IN            ItemRec
   , p_quantity                      IN            NUMBER
   )
IS
   l_proc_name                    VARCHAR2(50) := 'UPD_LPN_LOC_CPTY_FOR_UNPACK:';
   l_locator_current_cubic_area   NUMBER := 0;
   l_locator_available_cubic_area NUMBER;
   l_locator_current_weight       NUMBER := 0;
   l_locator_available_weight     NUMBER;
   l_debug                        NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_content_qty                  NUMBER;
   l_lpn_qty                      NUMBER;
   l_content_lpn_vol              NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_locator_current_weight   := p_loc_attr.l_locator_current_weight;
  l_locator_available_weight := p_loc_attr.l_locator_available_weight;
  /*-------------------------------------------------------------------------------------------------
    Content LPN is null. UnPack material to loose.
    -------------------------------------------------------------------------------------------------*/
  IF p_content_lpn_id  IS NULL THEN
    IF (l_debug = 1) THEN
       mdebug(l_proc_name||'The p_content_id is null  -case Unpack ');
    END IF;
      INV_LOC_WMS_UTILS.cal_locator_current_volume(
                x_return_status               =>       x_return_status
              , x_msg_data                    =>       x_msg_data
              , x_msg_count                   =>       x_msg_count
              , x_locator_current_volume      =>       l_locator_current_cubic_area
              , p_trn_lpn_container_item_vol  =>       NULL
              , p_trn_lpn_content_volume      =>       NULL
              , p_cnt_lpn_container_item_vol  =>       null
              , p_cnt_lpn_content_volume      =>       null
              , p_lpn_container_item_vol      =>       p_lpn_attr.l_container_item_vol
              , p_lpn_content_volume          =>       p_lpn_attr.l_content_volume
              , p_xacted_volume               =>       p_item_attr.l_item_xacted_volume
              , p_locator_current_cubic_area  =>       p_loc_attr.l_locator_current_cubic_area
              , p_transaction_action_id       =>       51
              , p_transfer_lpn_id             =>       NULL
              , p_content_lpn_id              =>       null
              , p_lpn_id                      =>       p_lpn_id
              , p_trn_lpn_exists_in_loc       =>       p_lpn_attr.l_lpn_exists_in_locator
              );
    ELSE
    /*-------------------------------------------------------------------------------------------------
      Content LPN is NOT null. UnPack lpn from another LPN.
      -------------------------------------------------------------------------------------------------*/
    IF (l_debug = 1) THEN
       mdebug(l_proc_name||'The P_content_lpn_id is not null -case Unpack ');
    END IF;

    INV_LOC_WMS_UTILS.cal_locator_current_volume(
              x_return_status               =>       x_return_status
            , x_msg_data                    =>       x_msg_data
            , x_msg_count                   =>       x_msg_count
            , x_locator_current_volume      =>       l_locator_current_cubic_area
            , p_trn_lpn_container_item_vol  =>       NULL
            , p_trn_lpn_content_volume      =>       NULL
            , p_cnt_lpn_container_item_vol  =>       p_cnt_lpn_attr.l_container_item_vol
            , p_cnt_lpn_content_volume      =>       p_cnt_lpn_attr.l_content_volume
            , p_lpn_container_item_vol      =>       p_lpn_attr.l_container_item_vol
            , p_lpn_content_volume          =>       p_lpn_attr.l_content_volume
            , p_xacted_volume               =>       p_cnt_lpn_attr.l_content_volume
            , p_locator_current_cubic_area  =>       p_loc_attr.l_locator_current_cubic_area
            , p_transaction_action_id       =>       51
            , p_transfer_lpn_id             =>       NULL
            , p_content_lpn_id              =>       p_content_lpn_id
            , p_lpn_id                      =>       p_lpn_id
            , p_trn_lpn_exists_in_loc       =>       p_lpn_attr.l_lpn_exists_in_locator
            );
    END IF;
       IF (p_cnt_lpn_attr.l_content_volume < p_cnt_lpn_attr.l_container_item_vol)  THEN
          l_content_lpn_vol := p_cnt_lpn_attr.l_container_item_vol;
       ELSE
          l_content_lpn_vol := p_cnt_lpn_attr.l_content_volume;
       END IF;
       /* check if the entire LPN is being unpacked, if so then subtract the container capacity */
       IF (p_content_lpn_id IS NULL AND p_lpn_attr.l_content_volume = p_item_attr.l_item_xacted_volume) OR
           (p_content_lpn_id IS NOT NULL AND p_lpn_attr.l_content_volume = l_content_lpn_vol)
       THEN
              l_locator_current_weight   := l_locator_current_weight - p_lpn_attr.l_container_item_weight;
              l_locator_available_weight := p_loc_attr.l_locator_max_weight - ( l_locator_current_weight
                                                                +  p_loc_attr.l_locator_suggested_weight);
              l_locator_current_cubic_area := l_locator_current_cubic_area - p_lpn_attr.l_container_item_vol;
              IF (l_debug = 1) THEN
                 mdebug(l_proc_name||'l_locator_current_weight    : '||l_locator_current_weight);
                 mdebug(l_proc_name||'l_locator_current_cubic_area: '||l_locator_current_cubic_area);
              END IF;
       END IF;

    l_locator_available_cubic_area := p_loc_attr.l_locator_max_cubic_area - (l_locator_current_cubic_area
                                                                  + p_loc_attr.l_locator_suggested_cubic_area);
    IF l_locator_available_cubic_area < 0 THEN
       l_locator_available_cubic_area := 0;
    END IF;

    UPDATE MTL_ITEM_LOCATIONS
       SET current_cubic_area    = nvl(l_locator_current_cubic_area,current_cubic_area)
         , available_cubic_area  = nvl(l_locator_available_cubic_area,available_cubic_area)
         , current_weight        = nvl(l_locator_current_weight,current_weight)
         , available_weight      = nvl(l_locator_available_weight,available_weight)
     WHERE inventory_location_id = p_inventory_location_id
       AND organization_id       = p_organization_id;

    IF l_debug = 1 THEN
       mdebug(l_proc_name||'Locator Current Cubic Area after update  : '||l_locator_current_cubic_area);
       mdebug(l_proc_name||'Locator Available Cubic Area after update: '||l_locator_available_cubic_area);
       mdebug(l_proc_name||'Locator Current weight after update      : '||l_locator_current_weight);
       mdebug(l_proc_name||'Locator Available weight after update    : '||l_locator_available_weight);
    END IF;

END upd_lpn_loc_cpty_for_unpack;

PROCEDURE upd_lpn_loc_cpty_for_pack
   (
     x_return_status                 OUT    NOCOPY VARCHAR2
   , x_msg_data                      OUT    NOCOPY VARCHAR2
   , x_msg_count                     OUT    NOCOPY NUMBER
   , p_content_lpn_id                IN            NUMBER
   , p_cnt_lpn_attr                  IN            LpnRec
   , p_transfer_lpn_id               IN            NUMBER
   , p_trn_lpn_attr                  IN            LpnRec
   , p_inventory_location_id         IN            NUMBER
   , p_loc_attr                      IN            LocatorRec
   , p_organization_id               IN            NUMBER
   , p_item_attr                     IN            ItemRec
   , p_container_item_id             IN            NUMBER
   , p_cartonization_id              IN            NUMBER
   )
IS
   l_proc_name                    VARCHAR2(50) := 'UPD_LPN_LOC_CPTY_FOR_PACK:';
   l_locator_current_cubic_area   NUMBER;
   l_locator_available_cubic_area NUMBER;
   l_locator_current_weight       NUMBER;
   l_locator_available_weight     NUMBER;
   l_debug                        NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_container_item_weight        NUMBER;
   l_container_item_vol           NUMBER;
   l_content_volume               NUMBER;
   l_lpn_exists_in_locator        VARCHAR2(1);
   l_container_item_attr          ItemRec;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --if it is a cartonization txn, the the lpn would not contain the container item weight and volume
  --yet.
  IF (l_debug = 1) THEN
     mdebug(l_proc_name||'cartonization id  : '||p_cartonization_id);
     mdebug(l_proc_name||'transfer lpn id   : '||p_transfer_lpn_id);
     mdebug(l_proc_name||'container item id : '||p_container_item_id);
  END IF;

  IF (p_cartonization_id IS NOT NULL AND p_cartonization_id = p_transfer_lpn_id) THEN
     fetch_item_attributes(
         x_return_status            =>    x_return_status
       , x_msg_data                 =>    x_msg_data
       , x_msg_count                =>    x_msg_count
       , x_item_attr                =>    l_container_item_attr
       , p_inventory_item_id        =>    p_container_item_id
       , p_transaction_uom_code     =>    NULL
       , p_primary_uom_flag         =>    NULL
       , p_locator_weight_uom_code  =>    p_loc_attr.l_locator_weight_uom_code
       , p_locator_volume_uom_code  =>    p_loc_attr.l_locator_volume_uom_code
       , p_quantity                 =>    NULL
       , p_organization_id          =>    p_organization_id
       , p_container_item           =>    'Y'
       );
     IF x_return_status =fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error   THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (l_debug = 1) THEN
        mdebug(l_proc_name||'The item weight UOM code  : '||l_container_item_attr.l_item_weight_uom_code);
        mdebug(l_proc_name||'item unit weight          : '||l_container_item_attr.l_item_unit_weight);
        mdebug(l_proc_name||'item volume UOM code      : '||l_container_item_attr.l_item_volume_uom_code);
        mdebug(l_proc_name||'item unit volume          : '||l_container_item_attr.l_item_unit_volume);
        mdebug(l_proc_name||'item extracted weight     : '||l_container_item_attr.l_item_xacted_weight);
        mdebug(l_proc_name||'item extracted volume     : '||l_container_item_attr.l_item_xacted_volume);
        mdebug(l_proc_name||'inventory item id         : '||p_container_item_id);
        mdebug(l_proc_name||'transaction uom code      : '||NULL);
        mdebug(l_proc_name||'primary UOM flag          : '||NULL);
        mdebug(l_proc_name||'locator weight UOM code   : '||p_loc_attr.l_locator_weight_uom_code);
        mdebug(l_proc_name||'locator volume UOM code   : '||p_loc_attr.l_locator_volume_uom_code);
        mdebug(l_proc_name||'transacted quantity       : '||NULL);
        mdebug(l_proc_name||'Organization id           : '||p_organization_id);
        mdebug(l_proc_name||'container item            : Y');
      END IF;

     l_container_item_weight := l_container_item_attr.l_item_unit_weight;
     l_container_item_vol    := l_container_item_attr.l_item_unit_volume   ;
     l_content_volume := 0;
     l_lpn_exists_in_locator := 'N';
  ELSE
     l_container_item_weight := p_trn_lpn_attr.l_container_item_weight;
     l_container_item_vol    := p_trn_lpn_attr.l_container_item_vol;
     l_content_volume        := p_trn_lpn_attr.l_content_volume;
     l_lpn_exists_in_locator := p_trn_lpn_attr.l_lpn_exists_in_locator;
  END IF;

  l_locator_current_weight   := p_loc_attr.l_locator_current_weight;
  l_locator_available_weight := p_loc_attr.l_locator_available_weight;
  IF p_trn_lpn_attr.l_lpn_exists_in_locator = 'N' THEN
     l_locator_current_weight := l_locator_current_weight + l_container_item_weight;
     l_locator_available_weight := p_loc_attr.l_locator_max_weight - ( l_locator_current_weight +
                                                            p_loc_attr.l_locator_suggested_weight);
  END IF;

  /*-------------------------------------------------------------------------------------------------
    Content LPN is null. Pack loose material into an LPN.
    -------------------------------------------------------------------------------------------------*/
  IF p_content_lpn_id  IS NULL THEN
    IF (l_debug = 1) THEN
       mdebug(l_proc_name||'The p_content_id is null  -case pack ');
    END IF;
      INV_LOC_WMS_UTILS.cal_locator_current_volume(
                x_return_status               =>       x_return_status
              , x_msg_data                    =>       x_msg_data
              , x_msg_count                   =>       x_msg_count
              , x_locator_current_volume      =>       l_locator_current_cubic_area
              , p_trn_lpn_container_item_vol  =>       l_container_item_vol
              , p_trn_lpn_content_volume      =>       l_content_volume
              , p_cnt_lpn_container_item_vol  =>       null
              , p_cnt_lpn_content_volume      =>       null
              , p_lpn_container_item_vol      =>       null
              , p_lpn_content_volume          =>       null
              , p_xacted_volume               =>       p_item_attr.l_item_xacted_volume
              , p_locator_current_cubic_area  =>       p_loc_attr.l_locator_current_cubic_area
              , p_transaction_action_id       =>       50
              , p_transfer_lpn_id             =>       p_transfer_lpn_id
              , p_content_lpn_id              =>       null
              , p_lpn_id                      =>       null
              , p_trn_lpn_exists_in_loc       =>       l_lpn_exists_in_locator
              );
    ELSE
    /*-------------------------------------------------------------------------------------------------
      Content LPN is NOT null. Pack lpn into another LPN.
      -------------------------------------------------------------------------------------------------*/
    IF (l_debug = 1) THEN
       mdebug(l_proc_name||'The P_content_lpn_id is not null -case pack ');
    END IF;
    INV_LOC_WMS_UTILS.cal_locator_current_volume(
              x_return_status               =>       x_return_status
            , x_msg_data                    =>       x_msg_data
            , x_msg_count                   =>       x_msg_count
            , x_locator_current_volume      =>       l_locator_current_cubic_area
            , p_trn_lpn_container_item_vol  =>       l_container_item_vol
            , p_trn_lpn_content_volume      =>       l_content_volume
            , p_cnt_lpn_container_item_vol  =>       p_cnt_lpn_attr.l_container_item_vol
            , p_cnt_lpn_content_volume      =>       p_cnt_lpn_attr.l_content_volume
            , p_lpn_container_item_vol      =>       null
            , p_lpn_content_volume          =>       null
            , p_xacted_volume               =>       p_cnt_lpn_attr.l_content_volume
            , p_locator_current_cubic_area  =>       p_loc_attr.l_locator_current_cubic_area
            , p_transaction_action_id       =>       50
            , p_transfer_lpn_id             =>       p_transfer_lpn_id
            , p_content_lpn_id              =>       p_content_lpn_id
            , p_lpn_id                      =>       null
            , p_trn_lpn_exists_in_loc       =>       l_lpn_exists_in_locator
            );
    END IF;

    l_locator_available_cubic_area := p_loc_attr.l_locator_max_cubic_area - (l_locator_current_cubic_area
                                                                  + p_loc_attr.l_locator_suggested_cubic_area);
    IF l_locator_available_cubic_area < 0 THEN
       l_locator_available_cubic_area := 0;
    END IF;

    UPDATE MTL_ITEM_LOCATIONS
       SET current_cubic_area    = nvl(l_locator_current_cubic_area,current_cubic_area)
         , available_cubic_area  = nvl(l_locator_available_cubic_area,available_cubic_area)
         , current_weight        = nvl(l_locator_current_weight,current_weight)
         , available_weight      = nvl(l_locator_available_weight,available_weight)
     WHERE inventory_location_id = p_inventory_location_id
       AND organization_id       = p_organization_id;

    IF l_debug = 1 THEN
       mdebug(l_proc_name||'Locator Current Cubic Area after update  : '||l_locator_current_cubic_area);
       mdebug(l_proc_name||'Locator Available Cubic Area after update: '||l_locator_available_cubic_area);
       mdebug(l_proc_name||'Locator Current Weight After update      : '||l_locator_current_weight);
       mdebug(l_proc_name||'Locator Available Weight after update    : '||l_locator_available_weight);
    END IF;

END upd_lpn_loc_cpty_for_pack;

-- bug#2876849. Added the two new parameters from org id and from loc id. These are needed
-- for a transfer transaction to decrement the capacity from the souce locator.

PROCEDURE upd_lpn_loc_curr_cpty_nauto
  (  x_return_status             OUT NOCOPY VARCHAR2   -- return status (success/error/unexpected_error)
    ,x_msg_count                 OUT NOCOPY NUMBER     -- number of messages in the message queue
    ,x_msg_data                  OUT NOCOPY VARCHAR2   -- message text when x_msg_count>0
    ,p_organization_id           IN         NUMBER     -- org of locator whose capacity is to be determined
    ,p_inventory_location_id     IN         NUMBER     -- identifier of locator
    ,p_inventory_item_id         IN         NUMBER     -- identifier of item
    ,p_primary_uom_FLAG          IN         VARCHAR2   -- iF Y primary UOM
    ,p_transaction_uom_code      IN         VARCHAR2   -- UOM of the transacted material that causes the
	    			                                        -- locator capacity to get updated
    ,p_transaction_action_id     IN         NUMBER     -- transaction action id for pack,unpack,issue,receive,
 					                                        -- transfer
    ,p_lpn_id                    IN         NUMBER     -- lpn id
    ,p_transfer_lpn_id		      IN         NUMBER     -- transfer_lpn_id
    ,p_content_lpn_id	         IN         NUMBER     -- content_lpn_id
    ,p_quantity                  IN         NUMBER     -- Primary quantity in primary UOM.
    ,p_container_item_id         IN         NUMBER     DEFAULT NULL
    ,p_cartonization_id          IN         NUMBER     DEFAULT NULL
    ,p_from_org_id               IN         NUMBER     DEFAULT NULL
    ,p_from_loc_id               IN         NUMBER     DEFAULT NULL
  )
IS
     l_inventory_location_id           NUMBER;
     l_loc_attr                        LocatorRec;
     l_item_attr                       ItemRec;
     l_cnt_lpn_attr                    LpnRec;
     l_trn_lpn_attr                    LpnRec;
     l_lpn_attr                        LpnRec;
     l_quantity                        NUMBER := p_quantity;

     l_content_lpn_quantity            NUMBER;

    l_return_status                    VARCHAR2(1);
    l_msg_data                         VARCHAR2(1000);
    l_msg_count                        NUMBER;
    l_from_inventory_location_id       NUMBER;
    l_max_units                        NUMBER;
    l_max_weight                       NUMBER;
    l_max_cubic_area                   NUMBER;


/* Debug Check */
    l_debug                            NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_proc_name                        VARCHAR2(50) := 'UPD_LPN_LOC_CURR_CPTY_NOAUTO:';
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*--------------------------------------------------------------------------------------------
     Fetch the actual Inventory Location ID
     --------------------------------------------------------------------------------------------*/

   fetch_locator(
            p_inventory_location_id          =>    p_inventory_location_id
          , p_organization_id                =>    p_organization_id
          , x_locator_id                     =>    l_inventory_location_id
          );

 /*
      ############# If the locator capacity is infinite, then dont update anything, simply return#############
      */
      SELECT location_maximum_units, max_weight, max_cubic_area
      INTO l_max_units, l_max_weight, l_max_cubic_area
      FROM mtl_item_locations_kfv
      WHERE organization_id        = p_organization_id
        AND inventory_location_id  = l_inventory_location_id;

      IF l_max_units IS NULL AND l_max_weight IS NULL AND l_max_cubic_area IS NULL AND p_transaction_action_id NOT IN (2,3,28) THEN
           return;
      ELSIF p_transaction_action_id IN (2,3,28) AND l_max_units IS NULL AND l_max_weight IS NULL AND l_max_cubic_area IS NULL THEN
             fetch_locator( /* Fetch the physical location id for the from locator */
               p_inventory_location_id          =>    p_from_loc_id
             , p_organization_id                =>    p_from_org_id
             , x_locator_id                     =>    l_from_inventory_location_id
             );

             SELECT location_maximum_units, max_weight, max_cubic_area
              INTO l_max_units, l_max_weight, l_max_cubic_area
              FROM mtl_item_locations_kfv
              WHERE organization_id         = p_from_org_id
                AND inventory_location_id         = l_from_inventory_location_id;

             IF l_max_units IS NULL AND l_max_weight IS NULL AND l_max_cubic_area IS NULL THEN /* If from locator is infinite */
                   return;
             END IF;

      END IF;

   -- Bug# 3067627
   IF (l_debug = 1) THEN
      mdebug('Before locking locator ' || l_inventory_location_id || ' in UPD_LPN_LOC_CURR_CPTY_NOAUTO');
   END IF;

   SELECT inventory_location_id INTO l_inventory_location_id
   FROM mtl_item_locations
   WHERE  inventory_location_id = l_inventory_location_id
       and organization_id = p_organization_id
   FOR UPDATE NOWAIT;

   IF (l_debug = 1) THEN
      mdebug('After locking locator ' || l_inventory_location_id || ' in UPD_LPN_LOC_CURR_CPTY_NOAUTO');
   END IF;

   /*---------------------------------------------------------------------------------------------
     Fetch the locator's current capacity.
     ---------------------------------------------------------------------------------------------*/
   fetch_loc_curr_capacity(
            p_inventory_location_id          =>    l_inventory_location_id
          , p_organization_id                =>    p_organization_id
          , x_loc_attr                       =>    l_loc_attr
          );

   IF (l_debug = 1) THEN
      mdebug(l_proc_name||'At the start of the program      : ');
      mdebug(l_proc_name||'The locator id used is           : '||l_inventory_location_id);
      mdebug(l_proc_name||'The attributes of locator follow : ');
      mdebug(l_proc_name||'l_locator_weight_uom_code        : '||l_loc_attr.l_locator_weight_uom_code);
      mdebug(l_proc_name||'l_locator_max_weight             : '||l_loc_attr.l_locator_max_weight);
      mdebug(l_proc_name||'l_locator_suggested_weight       : '||l_loc_attr.l_locator_suggested_weight);
      mdebug(l_proc_name||'l_locator_suggested_cubic_area   : '||l_loc_attr.l_locator_suggested_cubic_area);
      mdebug(l_proc_name||'l_locator_current_weight         : '||l_loc_attr.l_locator_current_weight);
      mdebug(l_proc_name||'l_locator_available_weight       : '||l_loc_attr.l_locator_available_weight);
      mdebug(l_proc_name||'l_locator_volume_uom_code        : '||l_loc_attr.l_locator_volume_uom_code);
      mdebug(l_proc_name||'l_locator_max_cubic_area         : '||l_loc_attr.l_locator_max_cubic_area);
      mdebug(l_proc_name||'l_locator_current_cubic_area     : '||l_loc_attr.l_locator_current_cubic_area);
      mdebug(l_proc_name||'l_locator_available_cubic_area   : '||l_loc_attr.l_locator_available_cubic_area);
      mdebug(l_proc_name||'l_locator_max_units              : '||l_loc_attr.l_locator_maximum_units);
      mdebug(l_proc_name||'l_locator_current_units          : '||l_loc_attr.l_locator_current_units);
      mdebug(l_proc_name||'l_locator_available_units        : '||l_loc_attr.l_locator_available_units);
      mdebug(l_proc_name||'l_locator_suggested_units        : '||l_loc_attr.l_locator_suggested_units);
      mdebug(l_proc_name||'transaction quantity             : '||l_quantity);
    END IF;


    /*---------------------------------------------------------------------------------
      Get the attributes for the inventory_item_id that is passed as input parameter
      ---------------------------------------------------------------------------------*/

    IF  p_inventory_item_id IS NOT NULL AND p_inventory_item_id <>-1 THEN
        fetch_item_attributes(
     	      x_return_status            =>    l_return_status
          , x_msg_data                 =>    l_msg_data
          , x_msg_count                =>    l_msg_count
          , x_item_attr                =>    l_item_attr
          , p_inventory_item_id        =>    p_inventory_item_id
          , p_transaction_uom_code     =>    p_transaction_uom_code
          , p_primary_uom_flag         =>    p_primary_uom_flag
          , p_locator_weight_uom_code  =>    l_loc_attr.l_locator_weight_uom_code
          , p_locator_volume_uom_code  =>    l_loc_attr.l_locator_volume_uom_code
          , p_quantity                 =>    l_quantity
          , p_organization_id          =>    p_organization_id
          , p_container_item           =>    null
          );
        IF l_return_status =fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
           mdebug(l_proc_name||'The item weight UOM code  : '||l_item_attr.l_item_weight_uom_code);
           mdebug(l_proc_name||'item unit weight          : '||l_item_attr.l_item_unit_weight);
           mdebug(l_proc_name||'item volume UOM code      : '||l_item_attr.l_item_volume_uom_code);
           mdebug(l_proc_name||'item unit volume          : '||l_item_attr.l_item_unit_volume);
           mdebug(l_proc_name||'item extracted weight     : '||l_item_attr.l_item_xacted_weight);
           mdebug(l_proc_name||'item extracted volume     : '||l_item_attr.l_item_xacted_volume);
           mdebug(l_proc_name||'inventory item id         : '||p_inventory_item_id);
           mdebug(l_proc_name||'transaction uom code      : '||p_transaction_uom_code);
           mdebug(l_proc_name||'primary UOM flag          : '||p_primary_uom_flag);
           mdebug(l_proc_name||'locator weight UOM code   : '||l_loc_attr.l_locator_weight_uom_code);
           mdebug(l_proc_name||'locator volume UOM code   : '||l_loc_attr.l_locator_volume_uom_code);
           mdebug(l_proc_name||'transacted quantity       : '||l_quantity);
           mdebug(l_proc_name||'Organization id           : '||p_organization_id);
           mdebug(l_proc_name||'container item            : ');
         END IF;
    END IF;

    /*------------------------------------------------------------------------------------
      Fetch the attributes of Content LPN if passed
      ------------------------------------------------------------------------------------*/

    IF p_content_lpn_id is not null THEN
       fetch_content_lpn_attr
          (
            x_return_status                =>    l_return_status
          , x_msg_data                     =>    l_msg_data
          , x_msg_count                    =>    l_msg_count
          , x_cnt_lpn_attr                 =>    l_cnt_lpn_attr
          , x_cnt_lpn_qty                  =>    l_content_lpn_quantity
          , p_lpn_id                       =>    p_content_lpn_id
          , p_org_id                       =>    p_organization_id
          , p_locator_volume_uom_code      =>    l_loc_attr.l_locator_volume_uom_code
          , p_locator_weight_uom_code      =>    l_loc_attr.l_locator_weight_uom_code
          );
        IF l_return_status =fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF p_inventory_item_id = -1 THEN
           l_quantity := l_content_lpn_quantity;
        END IF;

        IF (l_debug = 1) THEN
           mdebug(l_proc_name||'l_cnt_gross_weight_uom_code    : '||l_cnt_lpn_attr.l_gross_weight_uom_code);
           mdebug(l_proc_name||'l_cnt_content_volume_uom_code  : '||l_cnt_lpn_attr.l_content_volume_uom_code);
           mdebug(l_proc_name||'l_cnt_gross_weight             : '||l_cnt_lpn_attr.l_gross_weight);
           mdebug(l_proc_name||'l_cnt_content_volume           : '||l_cnt_lpn_attr.l_content_volume);
           mdebug(l_proc_name||'l_cnt_container_item_weight    : '||l_cnt_lpn_attr.l_container_item_weight);
           mdebug(l_proc_name||'l_cnt_container_item_vol       : '||l_cnt_lpn_attr.l_container_item_vol);
           mdebug(l_proc_name||'l_cnt_lpn_exists_in_locator    : '||l_cnt_lpn_attr.l_lpn_exists_in_locator);
           mdebug(l_proc_name||'p_content_lpn_id               : '||p_content_lpn_id);
           mdebug(l_proc_name||'p_organization_id              : '||p_organization_id);
           mdebug(l_proc_name||'locator weight UOM code        : '||l_loc_attr.l_locator_weight_uom_code);
           mdebug(l_proc_name||'lpn content qty                : '||l_quantity);
         END IF;
    END IF; /* End of p_content_lpn_id is not null */

    /*----------------------------------------------------------------------------------------
      Fetch the attributes of Transfer LPN if passed
      ----------------------------------------------------------------------------------------*/
    IF p_transfer_lpn_id is not null THEN
       fetch_transfer_lpn_attr
          (
            x_return_status                =>    l_return_status
          , x_msg_data                     =>    l_msg_data
          , x_msg_count                    =>    l_msg_count
          , x_trn_lpn_attr                 =>    l_trn_lpn_attr
          , p_lpn_id                       =>    p_transfer_lpn_id
          , p_org_id                       =>    p_organization_id
          , p_locator_volume_uom_code      =>    l_loc_attr.l_locator_volume_uom_code
          , p_locator_weight_uom_code      =>    l_loc_attr.l_locator_weight_uom_code
          );
        IF l_return_status =fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        IF (l_debug = 1) THEN
           mdebug(l_proc_name||'l_trn_gross_weight_uom_code    : '||l_trn_lpn_attr.l_gross_weight_uom_code);
           mdebug(l_proc_name||'l_trn_content_volume_uom_code  : '||l_trn_lpn_attr.l_content_volume_uom_code);
           mdebug(l_proc_name||'l_trn_gross_weight             : '||l_trn_lpn_attr.l_gross_weight);
           mdebug(l_proc_name||'l_trn_content_volume           : '||l_trn_lpn_attr.l_content_volume);
           mdebug(l_proc_name||'l_trn_container_item_weight    : '||l_trn_lpn_attr.l_container_item_weight);
           mdebug(l_proc_name||'l_trn_container_item_vol       : '||l_trn_lpn_attr.l_container_item_vol);
           mdebug(l_proc_name||'l_trn_lpn_exists_in_locator    : '||l_trn_lpn_attr.l_lpn_exists_in_locator);
           mdebug(l_proc_name||'p_transfer_lpn_id              : '||p_transfer_lpn_id);
           mdebug(l_proc_name||'p_organization_id              : '||p_organization_id);
           mdebug(l_proc_name||'locator weight UOM code        : '||l_loc_attr.l_locator_weight_uom_code);
           mdebug(l_proc_name||'locator volume UOM code        : '||l_loc_attr.l_locator_volume_uom_code);
         END IF;
    END IF; /*End of if transfer lpn */

    /*----------------------------------------------------------------------------------------
      Fetch the attributes of LPN if passed
      ----------------------------------------------------------------------------------------*/

    IF p_lpn_id is not null THEN
       fetch_lpn_attr
          (
            x_return_status                =>    l_return_status
          , x_msg_data                     =>    l_msg_data
          , x_msg_count                    =>    l_msg_count
          , x_lpn_attr                     =>    l_lpn_attr
          , p_lpn_id                       =>    p_lpn_id
          , p_org_id                       =>    p_organization_id
          , p_locator_volume_uom_code      =>    l_loc_attr.l_locator_volume_uom_code
          , p_locator_weight_uom_code      =>    l_loc_attr.l_locator_weight_uom_code
          );
        IF l_return_status =fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        IF (l_debug = 1) THEN
           mdebug(l_proc_name||'l_lpn_gross_weight_uom_code    : '||l_lpn_attr.l_gross_weight_uom_code);
           mdebug(l_proc_name||'l_lpn_content_volume_uom_code  : '||l_lpn_attr.l_content_volume_uom_code);
           mdebug(l_proc_name||'l_lpn_gross_weight             : '||l_lpn_attr.l_gross_weight);
           mdebug(l_proc_name||'l_lpn_content_volume           : '||l_lpn_attr.l_content_volume);
           mdebug(l_proc_name||'l_lpn_container_item_weight    : '||l_lpn_attr.l_container_item_weight);
           mdebug(l_proc_name||'l_lpn_container_item_vol       : '||l_lpn_attr.l_container_item_vol);
           mdebug(l_proc_name||'l_lpn_exists_in_locator        : '||l_lpn_attr.l_lpn_exists_in_locator);
           mdebug(l_proc_name||'p_lpn_id                       : '||p_lpn_id);
           mdebug(l_proc_name||'p_organization_id              : '||p_organization_id);
           mdebug(l_proc_name||'locator weight UOM code        : '||l_loc_attr.l_locator_weight_uom_code);
           mdebug(l_proc_name||'locator volume UOM code        : '||l_loc_attr.l_locator_volume_uom_code);
         END IF;
    END IF; /*End of if lpn */

    /*---------------------------------------------------------------------------------------------------
      Check for the transaction action, and peform the updation accordingly.
      ---------------------------------------------------------------------------------------------------*/
    IF p_transaction_action_id = 50 THEN
       /*-------------------------------------------------------------------------------------------
                                             Pack Transaction
         -------------------------------------------------------------------------------------------*/
       IF (l_debug = 1) THEN
          mdebug(l_proc_name||'transaction action id is =50 i.e pack ');
       END IF;
       upd_lpn_loc_cpty_for_pack
         (
           x_return_status                    =>      l_return_status
         , x_msg_data                         =>      l_msg_data
         , x_msg_count                        =>      l_msg_count
         , p_content_lpn_id                   =>      p_content_lpn_id
         , p_cnt_lpn_attr                     =>      l_cnt_lpn_attr
         , p_transfer_lpn_id                  =>      p_transfer_lpn_id
         , p_trn_lpn_attr                     =>      l_trn_lpn_attr
         , p_inventory_location_id            =>      l_inventory_location_id
         , p_loc_attr                         =>      l_loc_attr
         , p_organization_id                  =>      p_organization_id
         , p_item_attr                        =>      l_item_attr
         , p_container_item_id                =>      p_container_item_id
         , p_cartonization_id                 =>      p_cartonization_id
         );
       IF l_return_status =fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
   ELSIF p_transaction_action_id = 51 THEN
       /*-------------------------------------------------------------------------------------------
                                             UnPack Transaction
         -------------------------------------------------------------------------------------------*/
       IF (l_debug = 1) THEN
          mdebug(l_proc_name||'transaction action id is =51 i.e Unpack ');
       END IF;
       upd_lpn_loc_cpty_for_unpack
         (
           x_return_status                    =>      l_return_status
         , x_msg_data                         =>      l_msg_data
         , x_msg_count                        =>      l_msg_count
         , p_content_lpn_id                   =>      p_content_lpn_id
         , p_cnt_lpn_attr                     =>      l_cnt_lpn_attr
         , p_lpn_id                           =>      p_lpn_id
         , p_lpn_attr                         =>      l_lpn_attr
         , p_inventory_location_id            =>      l_inventory_location_id
         , p_loc_attr                         =>      l_loc_attr
         , p_organization_id                  =>      p_organization_id
         , p_item_attr                        =>      l_item_attr
         , p_quantity                         =>      p_quantity
         );
       IF l_return_status =fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
   ELSIF p_transaction_action_id IN (27,12, 31) OR
        (p_transaction_action_id IN (40,41,42) AND p_transfer_lpn_id IS NOT NULL ) THEN --Bug#4750846
       /*-------------------------------------------------------------------------------------------
                                             Receipt Transaction
         -------------------------------------------------------------------------------------------*/
       IF (l_debug = 1) THEN
          mdebug(l_proc_name||'transaction type is receipt ');
       END IF;
       upd_lpn_loc_cpty_for_rcpt (
            x_return_status                   =>        l_return_status
          , x_msg_data                        =>        l_msg_data
          , x_msg_count                       =>        l_msg_count
          , p_loc_attr                        =>        l_loc_attr
          , p_transfer_lpn_id                 =>        p_transfer_lpn_id
          , p_trn_lpn_attr                    =>        l_trn_lpn_attr
          , p_transaction_action_id           =>        p_transaction_action_id
          , p_item_attr                       =>        l_item_attr
          , p_quantity                        =>        l_quantity
          , p_inventory_location_id           =>        l_inventory_location_id
          , p_organization_id                 =>        p_organization_id
          );
       IF l_return_status =fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
   ELSIF p_transaction_action_id IN (1,21,32,34) OR
        (p_transaction_action_id IN (40,41,42) AND p_lpn_id IS NOT NULL ) THEN --Bug#4750846
       /*-------------------------------------------------------------------------------------------
                                          Issue Transaction
         -------------------------------------------------------------------------------------------*/
       IF (l_debug = 1) THEN
          mdebug(l_proc_name||'transaction type is issue ');
       END IF;
       upd_lpn_loc_cpty_for_issue(
            x_return_status                   =>        l_return_status
          , x_msg_data                        =>        l_msg_data
          , x_msg_count                       =>        l_msg_count
          , p_loc_attr                        =>        l_loc_attr
          , p_content_lpn_id                  =>        p_content_lpn_id
          , p_cnt_lpn_attr                    =>        l_cnt_lpn_attr
          , p_transaction_action_id           =>        p_transaction_action_id
          , p_item_attr                       =>        l_item_attr
          , p_quantity                        =>        l_quantity
          , p_inventory_location_id           =>        l_inventory_location_id
          , p_organization_id                 =>        p_organization_id
          );
       IF l_return_status =fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    ELSIF p_transaction_action_id IN (2,3,28) THEN
       /*-------------------------------------------------------------------------------------------
                                           Transfer Transaction
        -------------------------------------------------------------------------------------------*/
       IF (l_debug = 1) THEN
          mdebug(l_proc_name||'transaction type is Transfer ');
       END IF;
       -- the xfr transaction is implemented as issue from source and receipt into dest locator.
       -- now, if an entire lpn is transferred (content lpn), then the same lpn is passed as
       -- content lpn during issue and as transfer lpn during rcpt. However, for receipt part of
       -- the txn the lpn attribute lpn_exists_in_locator should be made 'no' and the item_xacted
       -- weight must be made equal to the lpn content weight (this is just a hack to use the
       -- same procedure upd_lpn_loc_cpty_for_rcpt())
       IF p_content_lpn_id IS NOT NULL THEN
          l_cnt_lpn_attr.l_lpn_exists_in_locator := 'N';
          l_item_attr.l_item_xacted_weight := abs(l_cnt_lpn_attr.l_gross_weight
                                               - l_cnt_lpn_attr.l_container_item_weight);
          l_item_attr.l_item_xacted_volume := l_cnt_lpn_attr.l_content_volume;
       END IF;
       upd_lpn_loc_cpty_for_xfr(
            x_return_status                   =>        l_return_status
          , x_msg_data                        =>        l_msg_data
          , x_msg_count                       =>        l_msg_count
          , p_loc_attr                        =>        l_loc_attr
          , p_content_lpn_id                  =>        p_content_lpn_id
          , p_cnt_lpn_attr                    =>        l_cnt_lpn_attr
          , p_trn_lpn_id                      =>        p_transfer_lpn_id
          , p_trn_lpn_attr                    =>        l_trn_lpn_attr
          , p_lpn_id                          =>        p_lpn_id
          , p_lpn_attr                        =>        l_lpn_attr
          , p_transaction_action_id           =>        p_transaction_action_id
          , p_item_attr                       =>        l_item_attr
          , p_quantity                        =>        l_quantity
          , p_inventory_location_id           =>        l_inventory_location_id
          , p_organization_id                 =>        p_organization_id
          , p_inventory_item_id               =>        p_inventory_item_id
          , p_transaction_uom_code            =>        p_transaction_uom_code
          , p_primary_uom_flag                =>        p_primary_uom_flag
          , p_from_org_id                     =>        p_from_org_id
          , p_from_loc_id                     =>        p_from_loc_id
          );
       IF l_return_status =fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
   ELSIF p_transaction_action_id = (52) THEN
      /*-------------------------------------------------------------------------------------------
                                       LPN Split Transaction
        -------------------------------------------------------------------------------------------*/
      IF (l_debug = 1) THEN
          mdebug(l_proc_name||'transaction type is LPN split ');
      END IF;
      -- Call Unpack first to unpack from the from LPN (lpn_id)
      IF (l_debug = 1) THEN
         mdebug(l_proc_name||'Unpack part of Split Transaction ');
      END IF;
      upd_lpn_loc_cpty_for_unpack
        (
          x_return_status                    =>      l_return_status
        , x_msg_data                         =>      l_msg_data
        , x_msg_count                        =>      l_msg_count
        , p_content_lpn_id                   =>      NULL
        , p_cnt_lpn_attr                     =>      NULL
        , p_lpn_id                           =>      p_lpn_id
        , p_lpn_attr                         =>      l_lpn_attr
        , p_inventory_location_id            =>      l_inventory_location_id
        , p_loc_attr                         =>      l_loc_attr
        , p_organization_id                  =>      p_organization_id
        , p_item_attr                        =>      l_item_attr
        , p_quantity                         =>      p_quantity
        );
      IF l_return_status =fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Then Call pack to pack the items into to LPN (transfer_lpn_id)
      IF (l_debug = 1) THEN
         mdebug(l_proc_name||'Pack part of Split Transaction');
      END IF;
      upd_lpn_loc_cpty_for_pack
        (
          x_return_status                    =>      l_return_status
        , x_msg_data                         =>      l_msg_data
        , x_msg_count                        =>      l_msg_count
        , p_content_lpn_id                   =>      NULL
        , p_cnt_lpn_attr                     =>      NULL
        , p_transfer_lpn_id                  =>      p_transfer_lpn_id
        , p_trn_lpn_attr                     =>      l_trn_lpn_attr
        , p_inventory_location_id            =>      l_inventory_location_id
        , p_loc_attr                         =>      l_loc_attr
        , p_organization_id                  =>      p_organization_id
        , p_item_attr                        =>      l_item_attr
        , p_container_item_id                =>      p_container_item_id
        , p_cartonization_id                 =>      p_cartonization_id
        );
      IF l_return_status =fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
END upd_lpn_loc_curr_cpty_nauto;

-- bug#2876849. Added the two new parameters from org id and from loc id. These are needed
-- for a transfer transaction to decrement the capacity from the souce locator.

PROCEDURE update_lpn_loc_curr_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_inventory_item_id         IN         NUMBER,   -- identifier of item
    p_primary_uom_FLAG          IN         VARCHAR2, -- iF Y primary UOM
    p_transaction_uom_code      IN         VARCHAR2, -- UOM of the transacted material that causes the
					                                      -- locator capacity to get updated
    p_transaction_action_id	  IN         NUMBER,   -- transaction action id for pack,unpack,issue,receive,
					                                      -- transfer
    p_lpn_id                    IN         NUMBER,   -- lpn id
    p_transfer_lpn_id	        IN         NUMBER,   -- transfer_lpn_id
    p_content_lpn_id		        IN         NUMBER,   -- content_lpn_id
    p_quantity                  IN         NUMBER,   -- transaction quantity in p_transaction_uom_code
    p_container_item_id         IN         NUMBER DEFAULT NULL,
    p_cartonization_id          IN         NUMBER DEFAULT NULL,
    p_from_org_id               IN         NUMBER DEFAULT NULL,
    p_from_loc_id               IN         NUMBER DEFAULT NULL
  )
IS
PRAGMA autonomous_transaction;
   l_return_status             VARCHAR2(1);
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(1000);
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
 INV_LOC_WMS_UTILS.upd_lpn_loc_curr_cpty_nauto
  ( x_return_status             =>l_return_status,
    x_msg_count                 =>l_msg_count,
    x_msg_data                  =>l_msg_data,
    p_organization_id           => p_organization_id,
    p_inventory_location_id     => p_inventory_location_id,
    p_inventory_item_id         => p_inventory_item_id,
    p_primary_uom_FLAG          =>'Y',
    p_transaction_uom_code      =>p_transaction_uom_code,
    p_transaction_action_id	=>p_transaction_action_id,
    p_lpn_id                    =>p_lpn_id,
    p_transfer_lpn_id		=>p_transfer_lpn_id,
    p_content_lpn_id		=>p_content_lpn_id,
    p_quantity                  =>abs(p_quantity),
    p_container_item_id         => p_container_item_id,
    p_cartonization_id          => p_cartonization_id,
    p_from_org_id               => p_from_org_id,
    p_from_loc_id               => p_from_loc_id
  );

    if l_return_status <> fnd_api.g_ret_sts_success THEN
	IF l_return_status = fnd_api.g_ret_sts_error then
	   raise fnd_api.g_exc_error;
	ELSE
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;
    end if;

    commit;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      rollback;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      rollback;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      rollback;
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      rollback;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	      , 'update_lpn_loc_curr_capacity'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
END ;

PROCEDURE lpn_loc_capacity_clean_up(x_return_status   OUT NOCOPY varchar2 --return status
			       ,x_msg_count       OUT NOCOPY NUMBER --number of messages in message queue
			       ,x_msg_data        OUT NOCOPY varchar2 --message text when x_msg_count>0
			       ,p_organization_id IN NUMBER -- identier for the organization
			       ,p_mixed_flag      IN VARCHAR2
				    )
IS
 l_return_status varchar2(10);
 l_msg_data      varchar2(1000);
 l_msg_count number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    savepoint lpn_loc_cleanup;
   IF (l_debug = 1) THEN
      INV_TRX_UTIL_PUB.TRACE('In LPN_LOC_CAPACITY_clean_up Procedure ','lpn_loc_capacity_clean_up',9);
   END IF;

     INV_LOC_WMS_UTILS.LPN_LOC_CURRENT_CAPACITY (x_return_status   =>l_return_status,
			       x_msg_count       =>l_msg_count,
			       x_msg_data        => x_msg_data,
			       p_organization_id =>p_organization_id,
			       p_mixed_flag      => p_mixed_flag);

     IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
	IF (l_debug = 1) THEN
   	INV_TRX_UTIL_PUB.TRACE('Call to LPN_LOC_current_CAPACITY failed with Status E ','lpn_loc_capacity_clean_up',9);
	END IF;
	RAISE fnd_api.g_exc_error;
     ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('Call to LPN_LOC_current_CAPACITY failed with status U','lpn_loc_capacity_clean_up',9);
       END IF;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (l_debug = 1) THEN
        INV_TRX_UTIL_PUB.TRACE('Before call to lpn_loc_cleanup_mmtt','lpn_loc_capacity_clean_up',9);
     END IF;

     INV_LOC_WMS_UTILS.lpn_loc_cleanup_mmtt(x_return_status   =>l_return_status,
			  x_msg_count       =>l_msg_count,
			  x_msg_data       =>l_msg_data,
			  p_organization_id =>p_organization_id,
			  p_mixed_flag      =>p_mixed_flag);

     IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('Call to lpn_loc_cleanup_mmtt failed with status E','lpn_loc_capacity_clean_up',9);
       END IF;
	RAISE fnd_api.g_exc_error;
     ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('Call to lpn_loc_cleanup_mmtt failed with status U','lpn_loc_capacity_clean_up',9);
       END IF;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

EXCEPTION
 WHEN fnd_api.g_exc_error THEN
    --Fixed bug 2342723, do not rollback to savepoint
    -- Bug 3511690 rolling back to savepoint
    rollback to lpn_loc_cleanup;
    --rollback;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
    rollback to lpn_loc_cleanup;
    --rollback;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
     x_return_status := fnd_api.g_ret_sts_error;
    rollback to lpn_loc_cleanup;
    --rollback;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	    p_data  => x_msg_data
	  );
   WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    rollback to lpn_loc_cleanup;
    --rollback;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'INV_LOC_WMS_UTILS',
	      'lpn_loc_capacity_clean_up'
	      );
     END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END lpn_loc_capacity_clean_up;

PROCEDURE cal_locator_current_volume(
		x_return_status               OUT NOCOPY VARCHAR2, --return status
		x_msg_data                    OUT NOCOPY VARCHAR2, --message text when x_msg_count>0
		x_msg_count                   OUT NOCOPY NUMBER,   --number of messages in message queue
		x_locator_current_volume      OUT NOCOPY NUMBER,   --locator's current_cubic_area
		p_trn_lpn_container_item_vol  IN         NUMBER,   --container item volume associated with transfer LPN
		p_trn_lpn_content_volume      IN         NUMBER,   --Content volume of the Transfer LPN
		p_cnt_lpn_container_item_vol  IN         NUMBER,   --container item volume associated with content LPN
		p_cnt_lpn_content_volume      IN         NUMBER,   --Content volume of the Content LPN
		p_lpn_container_item_vol      IN         NUMBER,   --container item volume associated with LPN
		p_lpn_content_volume          IN         NUMBER,   --Content volume of the LPN
		p_xacted_volume               IN         NUMBER,   -- Transacted volume
		p_locator_current_cubic_area  IN         NUMBER,   --locator's current_cubic_area
		p_transaction_action_id       IN         NUMBER,   -- transaction action id for pack,unpack,issue,receive,Transfer
		p_transfer_lpn_id             IN         NUMBER,   --Transfer_LPN_ID
		p_content_lpn_id              IN         NUMBER,   --Content LPN_ID
		p_lpn_id                      IN         NUMBER,   --LPN_ID
		p_trn_lpn_exists_in_loc       IN         VARCHAR2  --Flag indicates if Transfer LPN exists in Locator.
							                                    -- Y if the Transfer LPN exists in locator.
							                                    -- N if the Transfer LPN does not exists in locator
					      )
IS
 l_locator_current_volume         NUMBER;
 l_trn_lpn_container_item_vol     NUMBER;
 l_trn_lpn_content_volume         NUMBER;
 l_cnt_lpn_container_item_vol     NUMBER;
 l_cnt_lpn_content_volume         NUMBER;
 l_xacted_volume                  NUMBER;
 l_trn_xacted_volume              NUMBER;
 l_trn_lpn_exists_in_loc          VARCHAR2(1);
 l_debug                          NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 l_proc_name                      VARCHAR2(40) := 'CAL_LOCATOR_CURRENT_VOL: ';
BEGIN
 l_locator_current_volume         :=p_locator_current_cubic_area;
 l_trn_lpn_container_item_vol     :=p_trn_lpn_container_item_vol;
 l_trn_lpn_content_volume         :=p_trn_lpn_content_volume;
 l_cnt_lpn_container_item_vol     :=p_cnt_lpn_container_item_vol;
 l_cnt_lpn_content_volume         :=p_cnt_lpn_content_volume;
 l_xacted_volume                  :=p_xacted_volume;
 l_trn_lpn_exists_in_loc          := p_trn_lpn_exists_in_loc;
 /*---------------------------------------------------------------------------------------------------
                                        Pack Transaction
   ---------------------------------------------------------------------------------------------------*/
 IF p_transaction_action_id =50  /*PACK */ THEN
    IF p_content_lpn_id IS NULL THEN
	/*-------------------------------------------------------------------------------------------------
     Packing loose item in locator into a Transfer LPN
     -------------------------------------------------------------------------------------------------*/
	  IF (l_debug = 1) THEN
         mdebug(l_proc_name||'The content_lpn_id is null -case pack ');
	  END IF;
     /*------------------------------------------------------------------
       LPN already exists in the locator, need not add the container vol
       ------------------------------------------------------------------*/
	  IF p_trn_lpn_exists_in_loc ='Y' THEN
	     IF (l_debug = 1) THEN
   	    mdebug(l_proc_name||'The p_trn_lpn__exists_in_loc is Y -case pack ');
	     END IF;
	     IF l_trn_lpn_content_volume > l_trn_lpn_container_item_vol THEN
		     x_locator_current_volume := l_locator_current_volume ;
	     ELSIF (l_trn_lpn_content_volume + l_xacted_volume) <= l_trn_lpn_container_item_vol THEN
		     x_locator_current_volume := l_locator_current_volume -l_xacted_volume;
	     ELSIF (l_trn_lpn_content_volume + l_xacted_volume) > l_trn_lpn_container_item_vol THEN
		     x_locator_current_volume := l_locator_current_volume -l_xacted_volume +(
					    l_trn_lpn_content_volume + l_xacted_volume -l_trn_lpn_container_item_vol);
	     END IF;
     /*------------------------------------------------------------------
       LPN does not exist in the locator, need to add the container vol
       ------------------------------------------------------------------*/
     ELSE
	    IF (l_debug = 1) THEN
   	    mdebug(l_proc_name||'The p_trn_lpn__exists_in_loc is N -case pack ');
	    END IF;
	    l_locator_current_volume  := l_locator_current_volume + l_trn_lpn_container_item_vol;
	    IF l_xacted_volume <= l_trn_lpn_container_item_vol THEN
		    x_locator_current_volume := l_locator_current_volume -l_xacted_volume;
	    ELSIF l_xacted_volume > l_trn_lpn_container_item_vol THEN
        -- In case the Transacted volume is > container Volume, the volume of locator does
        -- not change.
	     	x_locator_current_volume := l_locator_current_volume - l_trn_lpn_container_item_vol;
	    END IF;
	  END IF;
	/*-------------------------------------------------------------------------------------------------
     Packing Content LPN in locator into another Transfer LPN
     -------------------------------------------------------------------------------------------------*/
   ELSIF  p_content_lpn_id IS NOT NULL THEN
	  IF l_cnt_lpn_content_volume > l_cnt_lpn_container_item_vol THEN
	     l_locator_current_volume := l_locator_current_volume - l_cnt_lpn_content_volume;
		  l_trn_xacted_volume:= l_cnt_lpn_content_volume;
	  ELSIF l_cnt_lpn_content_volume <= l_cnt_lpn_container_item_vol  THEN
	        l_locator_current_volume := l_locator_current_volume - l_cnt_lpn_container_item_vol;
		     l_trn_xacted_volume:= l_cnt_lpn_container_item_vol;
	  END IF;
     /*--------------------------------------------------------------------------
       Transfer LPN already exists in the locator, need not add the container vol
       --------------------------------------------------------------------------*/
	  IF p_trn_lpn_exists_in_loc ='Y' THEN
	     IF l_trn_lpn_content_volume > l_trn_lpn_container_item_vol THEN
		     x_locator_current_volume := l_locator_current_volume + l_trn_xacted_volume;
		  ELSIF (l_trn_lpn_content_volume +l_trn_xacted_volume) <= l_trn_lpn_container_item_vol THEN
		         x_locator_current_volume :=l_locator_current_volume;
		  ELSIF (l_trn_lpn_content_volume +l_trn_xacted_volume) > l_trn_lpn_container_item_vol THEN
		         x_locator_current_volume :=l_locator_current_volume +
				  (l_trn_lpn_content_volume+l_trn_xacted_volume-l_trn_lpn_container_item_vol);
		  END IF;
     /*--------------------------------------------------------------------------
       Transfer LPN does not exist in the locator, need to add the container vol
       --------------------------------------------------------------------------*/
	  ELSE /* p_trn_lpn_exists_in_loc <>Y' */
	     l_locator_current_volume  := l_locator_current_volume + l_trn_lpn_container_item_vol;
	     IF l_trn_xacted_volume > l_trn_lpn_container_item_vol THEN
		     x_locator_current_volume :=l_locator_current_volume + (l_trn_xacted_volume-l_trn_lpn_container_item_vol);
	     ELSIF l_trn_xacted_volume <= l_trn_lpn_container_item_vol THEN
		        x_locator_current_volume :=l_locator_current_volume;
	     END IF;
	     IF (l_debug = 1) THEN
   	       mdebug(l_proc_name||'Trx type Pack content lpn _id is not null ');
             mdebug(l_proc_name||'The value of current volume is  :'||to_char(x_locator_current_volume));
	     END IF;
	  END IF;/* p_trn_lpn_exists_in_loc ='Y' */
   END IF;
  /*---------------------------------------------------------------------------------------------------
                                        UnPack Transaction
   ---------------------------------------------------------------------------------------------------*/
 ELSIF p_transaction_action_id =51 THEN
   IF p_content_lpn_id is null THEN
	   IF p_lpn_content_volume > p_lpn_container_item_vol THEN
	      IF (p_lpn_content_volume-l_xacted_volume) > p_lpn_container_item_vol THEN
	          x_locator_current_volume :=l_locator_current_volume;
	      ELSIF (p_lpn_content_volume-l_xacted_volume) <= p_lpn_container_item_vol THEN
          -- In case of unpack, if the content vol > container vol. then the
          -- volume calculation should be current + transacted - diff( Content and Container vol).
	        x_locator_current_volume :=l_locator_current_volume + l_xacted_volume -(
					      p_lpn_content_volume -p_lpn_container_item_vol);
	      END IF;
	   ELSIF p_lpn_content_volume <= p_lpn_container_item_vol THEN
		      x_locator_current_volume :=l_locator_current_volume + l_xacted_volume;
	   END IF;
   ELSE
	   IF l_cnt_lpn_content_volume > l_cnt_lpn_container_item_vol THEN
		   x_locator_current_volume := l_locator_current_volume + l_cnt_lpn_content_volume;
	   ELSE
		   x_locator_current_volume := l_locator_current_volume + l_cnt_lpn_container_item_vol;
	   END IF;
   END IF;
  /*---------------------------------------------------------------------------------------------------
                                        Receipt Transaction
   ---------------------------------------------------------------------------------------------------*/
 ELSIF p_transaction_action_id in (27,12,31) /*Receipt*/ THEN
	IF  p_trn_lpn_exists_in_loc ='Y' THEN
	    IF l_trn_lpn_content_volume > l_trn_lpn_container_item_vol THEN
	       x_locator_current_volume := l_locator_current_volume + l_xacted_volume;
	    ELSIF (l_trn_lpn_content_volume + l_xacted_volume) <= l_trn_lpn_container_item_vol THEN
		    x_locator_current_volume := l_locator_current_volume ;
	    ELSIF (l_trn_lpn_content_volume + l_xacted_volume) > l_trn_lpn_container_item_vol THEN
		    x_locator_current_volume := l_locator_current_volume + (l_trn_lpn_content_volume + l_xacted_volume
									-l_trn_lpn_container_item_vol);
	    END IF;
	ELSE
	    l_locator_current_volume  := l_locator_current_volume + l_trn_lpn_container_item_vol;
	    IF l_xacted_volume <= l_trn_lpn_container_item_vol THEN
	       x_locator_current_volume := l_locator_current_volume;
	    ELSIF l_xacted_volume > l_trn_lpn_container_item_vol THEN
	       x_locator_current_volume := l_locator_current_volume +(l_xacted_volume-l_trn_lpn_container_item_vol);
	    END IF;
	END IF;
  /*---------------------------------------------------------------------------------------------------
                                        Issue Transaction
   ---------------------------------------------------------------------------------------------------*/
  ELSIF p_transaction_action_id in (1,21,32,34)  THEN
	   IF l_cnt_lpn_content_volume > l_cnt_lpn_container_item_vol THEN
		   x_locator_current_volume := l_locator_current_volume - l_cnt_lpn_content_volume;
	   ELSIF l_cnt_lpn_content_volume <= l_cnt_lpn_container_item_vol  THEN
		   x_locator_current_volume := l_locator_current_volume - l_cnt_lpn_container_item_vol;
	   END IF;
  /*---------------------------------------------------------------------------------------------------
                                        Xfr Transaction
   ---------------------------------------------------------------------------------------------------*/
  ELSIF p_transaction_action_id in (2,3,28) /* TRANSFER */ THEN
	   IF l_cnt_lpn_content_volume > l_cnt_lpn_container_item_vol THEN
	      x_locator_current_volume := l_locator_current_volume - l_cnt_lpn_content_volume;
	   ELSIF l_cnt_lpn_content_volume <= l_cnt_lpn_container_item_vol  THEN
		   x_locator_current_volume := l_locator_current_volume - l_cnt_lpn_container_item_vol;
	   END IF;
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
   WHEN fnd_api.g_exc_unexpected_error THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
   WHEN NO_DATA_FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	      , 'cal_locator_current_volume'
	      );
     END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
END cal_locator_current_volume;

PROCEDURE lpn_attributes (
	   x_return_status             OUT NOCOPY VARCHAR2, -- Return status
	   x_msg_data                  OUT NOCOPY VARCHAR2,--message text when x_msg_count>0
	   x_msg_count                 OUT NOCOPY NUMBER,-- Count iof message in the message queue
	   x_gross_weight_uom_code     OUT NOCOPY VARCHAR2,--Gross_Weight_UOM_Code of the LPN
	   x_content_volume_uom_code   OUT NOCOPY VARCHAR2,--Content_Volume_UOM_Code of the LPN
	   x_gross_weight              OUT NOCOPY NUMBER,--Gross Weight of the LPN
	   x_content_volume            OUT NOCOPY NUMBER,--Content_Volume of the LPN
	   x_container_item_weight     OUT NOCOPY NUMBER,-- Container item's weight (in terms of Gross_weight_UOM_code)
						  -- associated with the LPN
	   x_container_item_vol        OUT NOCOPY NUMBER,-- Container item Volume's (in terms of Content_Volume_UOM_code)
						  -- associated with the LPN
	   x_lpn_exists_in_locator     OUT NOCOPY VARCHAR2,--Flag indicates if Transfer LPN exists in Locator.
						    -- Y if the Transfer LPN exists in locator.
						    -- N if the Transfer LPN does not exists in locator
	   p_lpn_id                    IN NUMBER,--Identifier of the LPN
	   p_org_id                    IN NUMBER--Identifier of the Organization
			)
IS
     l_gross_weight_uom_code       varchar2(3);
     l_content_volume_uom_code     varchar2(3);
     l_subinventory_code           varchar2(30);
     l_gross_weight                NUMBER ;
     l_content_volume              NUMBER;
     l_locator_id                  NUMBER;
     l_container_item_id           NUMBER;
     l_return_status               VARCHAR2(1);

     l_container_item_wt_uom_code   VARCHAR2(3);
     l_container_item_unit_weight   NUMBER;
     l_container_item_vol_uom_code  VARCHAR2(3);
     l_container_item_unit_volume   NUMBER;
     l_container_item_xacted_weight NUMBER;
     l_container_item_xacted_volume NUMBER;

     l_msg_data                     VARCHAR2(1000);
     l_msg_count                    NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
     BEGIN

	 SELECT GROSS_WEIGHT_UOM_CODE,
		CONTENT_VOLUME_UOM_CODE,
		GROSS_WEIGHT,
		CONTENT_VOLUME,
		LOCATOR_ID,
		SUBINVENTORY_CODE,
		INVENTORY_ITEM_ID
	  INTO  l_gross_weight_uom_code,
		l_content_volume_uom_code,
		l_gross_weight,
		l_content_volume,
		l_locator_id,
		l_subinventory_code,
		l_container_item_id
	   FROM wms_license_plate_numbers
	   WHERE lpn_id = p_lpn_id;
     exception
       when no_data_found  then
	null;
      end;

	   IF (l_debug = 1) THEN
   	   INV_TRX_UTIL_PUB.TRACE('The p_lpn_id  '||to_char(p_lpn_id),'LPN-ATTRIBUTE-UPDATE_LPN_LOC',9);
   	   INV_TRX_UTIL_PUB.TRACE('The attribute of the lpn_id are :'||
		   'l_gross_weight_uom_code :'||l_gross_weight_uom_code ||
		   'l_content_volume_uom_code :'||l_content_volume_uom_code ||
		   'l_Subinventory_code :'||l_subinventory_code||
		   'l_gross_weight '||to_char(l_gross_weight)||
		   'l_content_volume '||to_char(l_content_volume) ||
		   'l_locator_id '||to_char(l_locator_id) ||
		   'l_container_item_id '||to_char(l_container_item_id)
		   ,'LPN-ATTRIBUTE-UPDATE_LPN_LOC',9
		  );
	   END IF;

	   IF  l_container_item_id is not null THEN
	       INV_LOC_WMS_UTILS.item_attributes( l_return_status,
				l_msg_data,
				l_msg_count,
				L_CONTAINER_ITEM_WT_UOM_CODE,
				l_container_item_unit_weight,
				l_container_item_vol_uom_code,
				l_container_item_unit_volume,
				l_container_item_xacted_weight,
				l_container_item_xacted_volume,
				l_container_item_id,
				Null,
				null,
				null,
				null,
				null ,
				p_org_id,
				'Y'
			       );
	      IF l_return_status =fnd_api.g_ret_sts_error THEN
		 IF (l_debug = 1) THEN
   		 INV_TRX_UTIL_PUB.TRACE('Error fetching container item attributes - '||l_return_status , 'LPN-ATTRIBUTE-UPDATE_LPN_LOC',4);
		 END IF;
		 RAISE fnd_api.g_exc_error;
	      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error   THEN
		 IF (l_debug = 1) THEN
   		 INV_TRX_UTIL_PUB.TRACE('Error fetching container item attributes - '||l_return_status , 'LPN-ATTRIBUTE-UPDATE_LPN_LOC',4);
		 END IF;
		RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	   END IF;

	   IF  l_gross_weight_uom_code is not null AND
	       L_CONTAINER_ITEM_WT_UOM_CODE is not null AND
	       l_container_item_unit_weight >0  THEN
	       IF (l_gross_weight_uom_code <> L_CONTAINER_ITEM_WT_UOM_CODE) THEN

		 IF (l_debug = 1) THEN
   		 INV_TRX_UTIL_PUB.TRACE('Gross_weight_uom_weight code different from container item weight uom code', 'LPN-ATTRIBUTE-UPDATE_LPN_LOC',4);
		 END IF;
		   l_container_item_xacted_weight := inv_convert.inv_um_convert(
									  item_id       => null,
									  precision     => null,
									  from_quantity => l_container_item_unit_weight,
									  from_unit     => L_CONTAINER_ITEM_WT_UOM_CODE,
									  to_unit	=> l_gross_weight_uom_code,
									  from_name     => null,
									  to_name	=> null
										);

		ELSE
		    l_container_item_xacted_weight := l_container_item_unit_weight;
		END IF;
		IF l_container_item_xacted_weight = -99999 THEN
		    RAISE fnd_api.g_exc_error;
		END IF;
		 IF (l_debug = 1) THEN
   		 INV_TRX_UTIL_PUB.TRACE('l_container_item_xacted_weight is '||to_char(l_container_item_xacted_weight), 'LPN-ATTRIBUTE-UPDATE_LPN_LOC',4);
		 END IF;
	    END IF;

	     IF l_content_volume_uom_code is not null AND
	       l_container_item_vol_uom_code is not null AND
	       l_container_item_unit_volume >0  THEN
	       IF (l_content_volume_uom_code <> l_container_item_vol_uom_code) THEN

		  l_container_item_xacted_volume := inv_convert.inv_um_convert(
									   item_id       => null,
									   precision     => null,
									   from_quantity => l_container_item_unit_volume,
									   from_unit     => l_container_item_vol_uom_code,
									   to_unit	 => l_content_volume_uom_code,
									   from_name     => null,
									   to_name	 => null
										);
		ELSE
		   l_container_item_xacted_volume := l_container_item_unit_volume;
		END IF;
		 IF (l_debug = 1) THEN
   		 INV_TRX_UTIL_PUB.TRACE('l_container_item_xacted_volume is '||to_char(l_container_item_xacted_volume), 'LPN-ATTRIBUTE-UPDATE_LPN_LOC',4);
		 END IF;
		IF l_container_item_xacted_volume = -99999 THEN
		    RAISE fnd_api.g_exc_error;
		END IF;

	    END IF;

	   IF (l_debug = 1) THEN
   	   INV_TRX_UTIL_PUB.TRACE('The weight and volume of the Container item are :'||
		   'l_container_item_unit_weight :'||to_char(l_container_item_unit_weight) ||
		   'L_CONTAINER_ITEM_WT_UOM_CODE :'||L_CONTAINER_ITEM_WT_UOM_CODE ||
		   'l_container_item_unit_volume :'||to_char(l_container_item_unit_volume)||
		   'l_container_item_vol_uom_code'||l_container_item_vol_uom_code
		   ,'LPN-ATTRIBUTE-UPDATE_LPN_LOC',4
		  );
	   END IF;
	  IF l_subinventory_code is null and l_locator_id is null then
	       x_lpn_exists_in_locator := 'N';
	  ELSE
	       x_lpn_exists_in_locator := 'Y';
	  END IF;

	  x_gross_weight_uom_code     :=l_gross_weight_uom_code;
	  x_content_volume_uom_code   :=l_content_volume_uom_code;
	  x_gross_weight              :=nvl(l_gross_weight,0);
	  x_content_volume            :=nvl(l_content_volume,0);
	  x_container_item_weight     :=nvl(l_container_item_xacted_weight,0);
	  x_container_item_vol     :=nvl(l_container_item_xacted_volume,0);

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	      , 'lpn_attributes'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
END lpn_attributes;


PROCEDURE item_attributes(
	      x_return_status           OUT NOCOPY VARCHAR2,--return status
	      x_msg_data                OUT NOCOPY VARCHAR2,
	      x_msg_count               OUT NOCOPY NUMBER,  --Count of messages in the Message queue
	      x_item_weight_uom_code    OUT NOCOPY VARCHAR2,--Item's weight UOM_code
	      x_item_unit_weight        OUT NOCOPY NUMBER,  --Item's unit weight
	      x_item_volume_uom_code    OUT NOCOPY VARCHAR2,--Item's Volume UOM_Code
	      x_item_unit_volume        OUT NOCOPY NUMBER,  --Item's unit volume
	      x_item_xacted_weight      OUT NOCOPY NUMBER,  --Transacted weight of item
	      x_item_xacted_volume      OUT NOCOPY NUMBER, -- Transacted volume of item
	      p_inventory_item_id       IN  NUMBER,-- Identifier of Item
	      p_transaction_uom_code    IN  VARCHAR2 ,--UOM of the transacted material
	      p_primary_uom_flag        IN  VARCHAR2 ,--Y if Primary_UOM
	      p_locator_weight_uom_code IN VARCHAR2 ,--Locator's weight_UOM_Code
	      p_locator_volume_uom_code IN VARCHAR2 ,--Locator's Volume_UOM_Code
	      p_quantity                IN  NUMBER   ,--Transaction quantity
	      p_organization_id          IN NUMBER, -- Identier of the Organization
	      p_container_item          IN  VARCHAR2--Flag which indicates the item passed is a container item.
								--Y if the item is a container item
								-- N if the item is not a container item
		      )
IS
     l_item_primary_uom_code           VARCHAR2(3);
     l_item_weight_uom_code            VARCHAR2(3);
     l_item_unit_weight                NUMBER;
     l_item_volume_uom_code            VARCHAR2(3);
     l_item_unit_volume                NUMBER;

     l_container_item_id               NUMBER;
     l_subinventory_code               VARCHAR2(20);
     l_locator_id                      NUMBER;
     l_primary_uom_code                VARCHAR2(3);
     l_weight_uom_code                 varchar2(3);
     l_volume_uom_code                 varchar2(3);
     l_item_xacted_weight              NUMBER;
     l_item_xacted_volume              NUMBER;
     l_quantity                        NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

	 SELECT primary_uom_code
		,weight_uom_code
		,unit_weight
		,volume_uom_code
		,unit_volume
	 INTO
	    l_item_primary_uom_code
	   ,l_item_weight_uom_code
	   ,l_item_unit_weight
	   ,l_item_volume_uom_code
	   ,l_item_unit_volume
	 FROM
	    mtl_system_items
	 WHERE
	    inventory_item_id = p_inventory_item_id  and
	    organization_id   = p_organization_id;

	 IF (l_debug = 1) THEN
   	 INV_TRX_UTIL_PUB.TRACE('The attributes of p_inventory_item are :' ||
	       'l_item_primary_uom_code :'||l_item_primary_uom_code ||
	       'l_item_weight_uom_code  :'||l_item_weight_uom_code ||
	       'l_item_unit_weight  :'||to_char(l_item_unit_weight)||
	       'l_item_volume_uom_code :'||l_item_volume_uom_code ||
		'l_item_unit_volume :'||to_char(l_item_unit_volume),'UPD_LPN_LOC-ITEM_ATTRIBUTES',9
	     );
	 END IF;

	 IF l_item_unit_weight IS NULL THEN
	   IF (l_debug = 1) THEN
   	   INV_TRX_UTIL_PUB.TRACE('The item_unit_weight is either < 0 or null','UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
	   END IF;
	   l_item_unit_weight := 0;
	 ELSIF l_item_unit_volume IS NULL THEN
	   IF (l_debug = 1) THEN
   	   INV_TRX_UTIL_PUB.TRACE('The item_unit_volume is either < 0 or null','UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
	   END IF;
	   l_item_unit_volume := 0;
	 END IF;

	    /* Convert this unit_weight and unit_volume into
		locator's weight_uom_code and volume_uom_code
		if item_uom_code and locator's uom do not match
	     */

	  IF  l_item_weight_uom_code is not null AND
	      p_locator_weight_uom_code is not null AND
	      l_item_unit_weight >0  THEN
	      IF (p_locator_weight_uom_code <> l_weight_uom_code) THEN

		    l_item_unit_weight := inv_convert.inv_um_convert( item_id       => p_inventory_item_id,
								      precision     => null,
								      from_quantity => l_item_unit_weight,
								      from_unit     => l_item_weight_uom_code,
								      to_unit	    => p_locator_weight_uom_code,
								      from_name     => null,
								      to_name	    => null
								     );
	      ELSE
		 l_item_unit_weight := l_item_unit_weight;
	      END IF;
	      IF l_item_unit_weight = -99999 THEN
		  RAISE fnd_api.g_exc_error;
	      END IF;
	   END IF;

	   IF  l_item_volume_uom_code is not null AND
	       p_locator_volume_uom_code is not null AND
	       l_item_unit_volume >0  THEN

	       IF (p_locator_volume_uom_code<> l_volume_uom_code) THEN
		  l_item_unit_volume := inv_convert.inv_um_convert(item_id       => p_inventory_item_id,
								   precision     => null,
								   from_quantity => l_item_unit_volume,
								   from_unit     => l_item_volume_uom_code,
								   to_unit	 => p_locator_volume_uom_code,
								   from_name     => null,
								   to_name	 => null
								     );
	       ELSE
		      l_item_unit_volume := l_item_unit_volume;
	       END IF;
	       IF l_item_unit_volume = -99999 THEN
		   RAISE fnd_api.g_exc_error;
	       END IF;
	   END IF;
	   IF p_container_item ='Y' THEN

	      x_item_unit_weight     := nvl(l_item_unit_weight,0);
	      x_item_unit_volume     := nvl(l_item_unit_volume,0);
	      x_item_weight_uom_code := l_item_weight_uom_code;
	      x_item_volume_uom_code := l_item_volume_uom_code;
	      x_item_xacted_weight   := null;
	      x_item_xacted_volume   := null;

	    IF (l_debug = 1) THEN
   	    INV_TRX_UTIL_PUB.TRACE('Item passed is a container item ','UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
	    END IF;

	 ELSE /* Item passed is not a container item */

	       IF l_primary_uom_code <> p_transaction_uom_code  and p_primary_uom_flag <>'Y'  THEN

		  /* Convert the transaction_uom_qty into primary_uom_quantity if p_primary_uom_quantity_flag <>Y */
		  IF (l_debug = 1) THEN
   		  INV_TRX_UTIL_PUB.TRACE('The value of primary_uom_flag  <>y or PUOM is not equal to Transaction UOM', 'UPDATE_LPN_LOC_CURR_CAPACITY',9);
		  END IF;

		  l_quantity := inv_convert.inv_um_convert(item_id       => p_inventory_item_id,
						       precision     => null,
						       from_quantity =>p_quantity,
						       from_unit     => p_transaction_uom_code,
						       to_unit       => l_item_primary_uom_code,
						       from_name     => null,
						       to_name       => null
						     );
	       ELSE
		   l_quantity := p_quantity ;
	       END IF;

	       IF l_quantity = -99999 THEN
		   RAISE fnd_api.g_exc_error;
	       END IF;
	       IF (l_debug = 1) THEN
   	       INV_TRX_UTIL_PUB.TRACE('The value of l_quantity is '||to_char(l_quantity),'UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
	       END IF;

	       /* Check if the weight and volume uom code of item and locator are different.
		  If so convert the weight and volume code of item in terms of locator weight
		  and volume uom code
	       */

		 IF l_item_weight_uom_code is not null    AND
		    p_locator_weight_uom_code is not null AND
		    l_item_unit_weight >0  THEN

		    IF (l_debug = 1) THEN
   		    INV_TRX_UTIL_PUB.TRACE('check if the p_locator_weight_uom_code and l_item_weight_uom_code are same or not', 'UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
		    END IF;

		   l_item_xacted_weight := l_quantity *l_item_unit_weight;

		    IF  (l_item_weight_uom_code <> p_locator_weight_uom_code) THEN
			  IF (l_debug = 1) THEN
   			  INV_TRX_UTIL_PUB.TRACE('p_locator_weight_uom_code and l_item_weight_uom_code are not same', 'UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
			  END IF;

			l_item_xacted_weight := inv_convert.inv_um_convert(
							      item_id       => p_inventory_item_id,
							      precision     => null,
							      from_quantity => l_item_xacted_weight ,
							      from_unit     => l_item_weight_uom_code,
							      to_unit       => p_locator_weight_uom_code,
							      from_name     => null,
							      to_name       => null
								    );
			IF l_item_xacted_weight= -99999 THEN
			   RAISE fnd_api.g_exc_error;
			END IF;
		    END IF;
		  END IF;

		IF (l_debug = 1) THEN
   		INV_TRX_UTIL_PUB.TRACE('The value of l_item_xacted_weight  is ' ||to_char(l_item_xacted_weight), 'UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
		END IF;

		IF l_item_volume_uom_code IS NOT NULL and
		   p_locator_volume_uom_code  IS NOT NULL and
		   l_item_unit_volume >0 THEN

		   l_item_xacted_volume  := l_quantity *l_item_unit_volume;

		   IF  l_item_volume_uom_code <> p_locator_volume_uom_code THEN

		      IF (l_debug = 1) THEN
   		      INV_TRX_UTIL_PUB.TRACE('p_locator_volume_uom_code and l_item_volume_uom_code are same or not', 'UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
		      END IF;

		     l_item_xacted_volume  := inv_convert.inv_um_convert(item_id        => p_inventory_item_id,
									 precision      => null,
									 from_quantity  => l_item_xacted_volume,
									 from_unit      => l_item_volume_uom_code,
									 to_unit        => p_locator_volume_uom_code,
									 from_name      => null,
									 to_name        => null
									);
		  END IF;
		  IF l_item_xacted_volume= -99999 THEN
		      RAISE fnd_api.g_exc_error;
		  END IF;
	       END IF;

	      x_item_unit_weight     := nvl(l_item_unit_weight,0);
	      x_item_unit_volume     := nvl(l_item_unit_volume,0);
	      x_item_weight_uom_code := l_item_weight_uom_code;
	      x_item_volume_uom_code := l_item_volume_uom_code;
	      x_item_xacted_weight   := nvl(l_item_xacted_weight,0);
	      x_item_xacted_volume   := nvl(l_item_xacted_volume,0);

	    IF (l_debug = 1) THEN
   	    INV_TRX_UTIL_PUB.TRACE('The value of l_item_xacted_volume is ' ||to_char(l_item_xacted_volume), 'UPD_LPN_LOC-ITEM_ATTRIBUTES',4);
	    END IF;

	 END IF; /* End of p_container_item =Y */
EXCEPTION
      WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

      WHEN fnd_api.g_exc_unexpected_error THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	      , 'item_attributes'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
END ITEM_ATTRIBUTES;

PROCEDURE LOC_EMPTY_MIXED_FLAG_AUTO(
  X_RETURN_STATUS          OUT NOCOPY VARCHAR2
, X_MSG_COUNT              OUT NOCOPY NUMBER
, X_MSG_DATA               OUT NOCOPY VARCHAR2
, P_ORGANIZATION_ID        IN  NUMBER
, P_INVENTORY_LOCATION_ID  IN  NUMBER
, P_INVENTORY_ITEM_ID      IN  NUMBER
, P_TRANSACTION_ACTION_ID  IN  NUMBER
, P_TRANSFER_ORGANIZATION  IN  NUMBER
, P_TRANSFER_LOCATION_ID   IN  NUMBER
, P_SOURCE                 IN  VARCHAR2 )
is
   PRAGMA autonomous_transaction;

   l_return_status 		varchar2(1);
   l_msg_data			varchar2(1000);
   l_msg_count			number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
     x_return_status := fnd_api.g_ret_sts_success  ;

     INV_LOC_WMS_UTILS.LOC_EMPTY_MIXED_FLAG (
       X_RETURN_STATUS   	=> l_return_status
     , X_MSG_COUNT       	=> l_MSG_COUNT
     , X_MSG_DATA        	=> l_MSG_DATA
     , P_ORGANIZATION_ID 	=> p_organization_id
     , P_INVENTORY_LOCATION_ID  => p_inventory_location_id
     , P_INVENTORY_ITEM_ID      => p_inventory_item_id
     , P_TRANSACTION_ACTION_ID  => p_transaction_action_id
     , P_TRANSFER_ORGANIZATION  => p_transfer_organization
     , P_TRANSFER_LOCATION_ID   => p_transfer_location_id
     , P_SOURCE                 => p_source); --bug#9159019 FPing fix for #894446

    if l_return_status <> fnd_api.g_ret_sts_success THEN
	IF l_return_status = fnd_api.g_ret_sts_error then
	   raise fnd_api.g_exc_error;
	ELSE
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;
    end if;

    commit;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	      , 'LOC_EMPTY_MIXED_FLAG_AUTO'
	      );
	END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
END LOC_EMPTY_MIXED_FLAG_AUTO ;

PROCEDURE LOC_EMPTY_MIXED_FLAG(
  X_RETURN_STATUS          OUT NOCOPY VARCHAR2
, X_MSG_COUNT              OUT NOCOPY NUMBER
, X_MSG_DATA               OUT NOCOPY VARCHAR2
, P_ORGANIZATION_ID        IN  NUMBER
, P_INVENTORY_LOCATION_ID  IN  NUMBER
, P_INVENTORY_ITEM_ID      IN  NUMBER
, P_TRANSACTION_ACTION_ID  IN  NUMBER
, P_TRANSFER_ORGANIZATION  IN  NUMBER
, P_TRANSFER_LOCATION_ID   IN  NUMBER
, P_SOURCE                 IN  VARCHAR2 )
IS
    l_physical_locator_id             NUMBER;
    l_loc_id                          NUMBER;
    l_des_physical_locator_id         NUMBER;
    l_des_loc_id                      NUMBER;
    l_inventory_location_id           NUMBER;
    l_des_inventory_location_id       NUMBER;
    l_chk_flag                        NUMBER;
    l_mixed_flag                      VARCHAR2(1);
    l_empty_flag                      VARCHAR2(1);
    l_item_id                         NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      INV_TRX_UTIL_PUB.TRACE('In LOC_EMPTY_MIXED_FLAG Procedure ','LOC_EMPTY_MIXED_FLAG',10);
   END IF;

    -- Fixed bug 2342723, remove the savepoint
    -- savepoint loc_empty;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT physical_location_id ,
	  inventory_location_id
   INTO l_physical_locator_id,
	l_loc_id
   FROM mtl_item_locations
   WHERE  inventory_location_id = p_inventory_location_id
   and    organization_id       = p_organization_id;

   IF l_physical_locator_id is null THEN
     l_inventory_location_id := l_loc_id;
   ELSE
     l_inventory_location_id := l_physical_locator_id;
   END IF;

   -- Bug# 3067627
   IF (l_debug = 1) THEN
      mdebug('Before locking locator ' || l_inventory_location_id || ' in LOC_EMPTY_MIXED_FLAG(1)');
   END IF;

   SELECT inventory_location_id INTO l_inventory_location_id
   FROM mtl_item_locations
   WHERE  inventory_location_id = l_inventory_location_id
       and organization_id = p_organization_id
   FOR UPDATE NOWAIT;

   IF (l_debug = 1) THEN
      mdebug('After locking locator ' || l_inventory_location_id || ' in LOC_EMPTY_MIXED_FLAG(1)');
   END IF;

   IF P_TRANSACTION_ACTION_ID IN (27,12) /* Receipt */ THEN
       /* Check if there is more than one item in the locator either in
       ** loose state or packed in the LPN sitting in the same locator.
       ** Check in MOQD if there is any other item in the
       ** same locator other than the inventory item id passed as IN
       ** parameter. If found then we have to Flag Mixed Flag =Y' and null
       ** out the inventory Item id column in MIL.
       */

       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('Receipt transaction ','LOC_EMPTY_MIXED_FLAG',10);
       END IF;

       INV_LOC_WMS_UTILS.inv_loc_receipt (x_return_status     => X_return_status
				   ,X_MSG_COUNT         => X_msg_count
				   ,X_MSG_DATA          => X_msg_data
				   ,X_EMPTY_FLAG        => l_empty_flag
				   ,X_MIXED_FLAG        => l_mixed_flag
				   ,X_ITEM_ID           => l_item_id
				   ,P_LOCATOR_ID        => l_inventory_location_id
				   ,P_ORG_ID            => P_ORGANIZATION_ID
				   ,P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID
				   ) ;

       IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
             IF (l_debug = 1) THEN
                INV_TRX_UTIL_PUB.TRACE('Failed for Receipt transaction with status -E ', 'LOC_EMPTY_MIXED_FLAG',9);
             END IF;
	     RAISE fnd_api.g_exc_error;
       ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
	     IF (l_debug = 1) THEN
   	     INV_TRX_UTIL_PUB.TRACE('Failed for Receipt transaction with status -U ', 'LOC_EMPTY_MIXED_FLAG',9);
	     END IF;
	     RAISE fnd_api.g_exc_unexpected_error;
       END IF;

     ELSIF P_TRANSACTION_ACTION_ID in (1,21,32,34) /* Issue */  THEN
	  IF (l_debug = 1) THEN
   	  INV_TRX_UTIL_PUB.TRACE('Issue transaction ','LOC_EMPTY_MIXED_FLAG',10);
	  END IF;

	  INV_LOC_WMS_UTILS.inv_loc_issues  (x_return_status    => X_return_status
				   ,X_MSG_COUNT        => X_msg_count
				   ,X_MSG_DATA         => X_msg_data
				   ,X_EMPTY_FLAG       => l_empty_flag
				   ,X_MIXED_FLAG       => l_mixed_flag
				   ,X_ITEM_ID          => l_item_id
				   ,P_ORG_ID           => P_ORGANIZATION_ID
				   ,P_LOCATOR_ID       => l_inventory_location_id
				   ,P_INVENTORY_ITEM_ID=> P_INVENTORY_ITEM_ID
				   ,P_SOURCE           =>p_source
				    ) ;
	  IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
	       IF (l_debug = 1) THEN
   	       INV_TRX_UTIL_PUB.TRACE('Failed for Issue transaction with status -E ', 'LOC_EMPTY_MIXED_FLAG',9);
	       END IF;
               RAISE fnd_api.g_exc_error;
	  ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
	      IF (l_debug = 1) THEN
   	      INV_TRX_UTIL_PUB.TRACE('Failed for Issue transaction with status - U', 'LOC_EMPTY_MIXED_FLAG',9);
	      END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	  END IF;
    ELSIF p_transaction_action_id in(2,3,28) /* TRANSFER */ THEN

	IF (l_debug = 1) THEN
   	INV_TRX_UTIL_PUB.TRACE('Transfer transaction ','LOC_EMPTY_MIXED_FLAG',10);
	END IF;

        if (p_transfer_location_id > 0) then
          /* For the destination organization */

	  SELECT physical_location_id ,
		 inventory_location_id
	  INTO l_des_physical_locator_id,
	       l_des_loc_id
	  FROM mtl_item_locations
	  WHERE  inventory_location_id = p_transfer_location_id
	  and    organization_id       = p_transfer_organization;

	  IF l_des_physical_locator_id is null THEN
	    l_des_inventory_location_id := l_des_loc_id;
	  ELSE
	   l_des_inventory_location_id := l_des_physical_locator_id;
	  END IF;

	   -- Bug# 3067627
	   IF (l_debug = 1) THEN
	      mdebug('Before locking destination locator ' || l_des_inventory_location_id || ' in LOC_EMPTY_MIXED_FLAG(2)');
	   END IF;

	   SELECT inventory_location_id INTO l_des_inventory_location_id
	   FROM mtl_item_locations
	   WHERE  inventory_location_id = l_des_inventory_location_id
	       and organization_id = p_transfer_organization
	   FOR UPDATE NOWAIT;

	   IF (l_debug = 1) THEN
	      mdebug('After locking destination locator ' || l_des_inventory_location_id || ' in LOC_EMPTY_MIXED_FLAG(2)');
	   END IF;

          IF (l_debug = 1) THEN
             INV_TRX_UTIL_PUB.TRACE('Before call to Receipt transaction ', 'LOC_EMPTY_MIXED_FLAG',10);
          END IF;

	  INV_LOC_WMS_UTILS.inv_loc_receipt (
                                    x_return_status     => X_return_status
				   ,X_MSG_COUNT         => X_msg_count
				   ,X_MSG_DATA          => X_msg_data
				   ,X_EMPTY_FLAG        => l_empty_flag
				   ,X_MIXED_FLAG        => l_mixed_flag
				   ,X_ITEM_ID           => l_item_id
				   ,P_LOCATOR_ID        => l_des_inventory_location_id
				   ,P_ORG_ID            => P_TRANSFER_ORGANIZATION
				   ,P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID
				    ) ;
	  IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
		      IF (l_debug = 1) THEN
   		      INV_TRX_UTIL_PUB.TRACE('Failed for Receipt transaction with status -E ', 'LOC_EMPTY_MIXED_FLAG',9);
		      END IF;
		       RAISE fnd_api.g_exc_error;
	  ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
		      IF (l_debug = 1) THEN
   		      INV_TRX_UTIL_PUB.TRACE('Failed for Receipt transaction with status -U ', 'LOC_EMPTY_MIXED_FLAG',9);
		      END IF;
		       RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

	  IF (l_debug = 1) THEN
   	  INV_TRX_UTIL_PUB.TRACE('Before Updating destination locator ', 'LOC_EMPTY_MIXED_FLAG',10);
   	  INV_TRX_UTIL_PUB.TRACE('The values of Empty _Flag is '||l_empty_flag , 'LOC_EMPTY_MIXED_FLAG',10);
             INV_TRX_UTIL_PUB.TRACE('The values of Mixed_Flag is '||l_mixed_flag , 'LOC_EMPTY_MIXED_FLAG',10);
             INV_TRX_UTIL_PUB.TRACE('The values of Item ID is '||l_item_id , 'LOC_EMPTY_MIXED_FLAG',10);
          END IF;

--Fix for 8630843
--LAST_UPDATED_BY = fnd_global.user_id added to the update statment

          UPDATE MTL_ITEM_LOCATIONS mil
	          SET EMPTY_FLAG            = nvl(l_empty_flag,mil.empty_flag)
	            , MIXED_ITEMS_FLAG      = nvl(l_mixed_flag,mil.mixed_items_flag)
               , INVENTORY_ITEM_ID     = nvl(l_item_id,mil.inventory_item_id)
	       , LAST_UPDATE_DATE     = sysdate                                                       /* Added for Bug 6363028 */
           ,LAST_UPDATED_BY = fnd_global.user_id
           WHERE INVENTORY_LOCATION_ID = l_des_inventory_location_id
	          AND ORGANIZATION_ID       = P_TRANSFER_ORGANIZATION;

 	end if;

        /* For the Source Organization */

        IF (l_debug = 1) THEN
           INV_TRX_UTIL_PUB.TRACE('Before call to Issue transaction ','LOC_EMPTY_MIXED_FLAG',10);
        END IF;

        INV_LOC_WMS_UTILS.inv_loc_issues(x_return_status    => X_return_status
				   ,X_MSG_COUNT        => X_msg_count
				   ,X_MSG_DATA         => X_msg_data
				   ,X_EMPTY_FLAG       => l_empty_flag
				   ,X_MIXED_FLAG       => l_mixed_flag
				   ,X_ITEM_ID          => l_item_id
				   ,P_ORG_ID           => P_ORGANIZATION_ID
				   ,P_LOCATOR_ID       => l_inventory_location_id
				   ,P_INVENTORY_ITEM_ID=> P_INVENTORY_ITEM_ID
				   ,P_SOURCE           =>p_source
				    ) ;
        IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
		      IF (l_debug = 1) THEN
   		      INV_TRX_UTIL_PUB.TRACE('Failed for Issue transaction with status -E ', 'LOC_EMPTY_MIXED_FLAG',9);
		      END IF;
		       RAISE fnd_api.g_exc_error;
        ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
		       IF (l_debug = 1) THEN
   		       INV_TRX_UTIL_PUB.TRACE('Failed for Issue transaction with status - U', 'LOC_EMPTY_MIXED_FLAG',9);
		       END IF;
		       RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; /* End if for the transaction_action_id */

      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.TRACE('The values of Empty _Flag is '|| l_empty_flag , 'LOC_EMPTY_MIXED_FLAG',10);
         INV_TRX_UTIL_PUB.TRACE('The values of Mixed_Flag is '|| l_mixed_flag , 'LOC_EMPTY_MIXED_FLAG',10);
         INV_TRX_UTIL_PUB.TRACE('The values of Item ID is '|| l_item_id , 'LOC_EMPTY_MIXED_FLAG',10);
      END IF;

      --Bug#2756609. Should update empty_flag and mixed_items_flag only if
      --the values passed are not null.

--Fix for 8630843
--LAST_UPDATED_BY = fnd_global.user_id added to the update statment

      UPDATE MTL_ITEM_LOCATIONS MIL
         SET EMPTY_FLAG            = NVL(l_empty_flag,MIL.empty_flag)
           , MIXED_ITEMS_FLAG      = NVL(l_mixed_flag,MIL.mixed_items_flag)
           , INVENTORY_ITEM_ID     = NVL(l_item_id,MIL.inventory_item_id)
           , LAST_UPDATE_DATE     = sysdate                                                       /* Added for Bug 6363028 */
           , LAST_UPDATED_BY       = fnd_global.user_id
       WHERE INVENTORY_LOCATION_ID = l_inventory_location_id
         AND ORGANIZATION_ID       = P_ORGANIZATION_ID;

      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.TRACE('End of Procedure LOC_EMPTY_MIXED_FLAG ', 'LOC_EMPTY_MIXED_FLAG',10);
      END IF;
EXCEPTION
 WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    --Fixed bug 2342723, do not rollback to savepoint
    --ROLLBACK TO loc_empty;
    ROLLBACK;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	);
 WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
    --ROLLBACK TO loc_empty;
    ROLLBACK;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
 WHEN NO_DATA_FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;
    --ROLLBACK TO loc_empty;
    ROLLBACK;
 WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    --ROLLBACK TO loc_empty;
    ROLLBACK;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	    , 'LOC_EMPTY_MIXED_FLAG '
	    );
     END IF;
     fnd_msg_pub.count_and_get
	 ( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
END LOC_EMPTY_MIXED_FLAG;

procedure inv_loc_issues  (
  x_return_status     OUT NOCOPY VARCHAR2
, X_MSG_COUNT        OUT NOCOPY NUMBER
, X_MSG_DATA         OUT NOCOPY VARCHAR2
, X_EMPTY_FLAG       OUT NOCOPY VARCHAR2
, X_MIXED_FLAG       OUT NOCOPY VARCHAR2
, X_ITEM_ID          OUT NOCOPY NUMBER
, P_ORG_ID           IN NUMBER
, P_LOCATOR_ID       IN NUMBER
, P_INVENTORY_ITEM_ID IN NUMBER
, P_SOURCE           IN VARCHAR2 )
IS
    cursor item_cnt
    is
    SELECT inventory_item_id
    FROM MTL_ONHAND_QUANTITIES_DETAIL
    WHERE LOCATOR_ID = p_locator_id
    and   organization_id =p_org_id
    and   inventory_item_id <> p_inventory_item_id
    and   rownum <3
    group by inventory_item_id;

    l_loc_current_units    NUMBER;
    l_loc_suggested_units  NUMBER;
    l_chk_flag             NUMBER;
    l_item                 item_cnt%rowtype;
    l_mixed_flag           varchar2(1);
    l_empty_flag           varchar2(1);
    l_inventory_item_id    number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('In Procedure inv_loc_issues ','inv_loc_issues',10);
       END IF;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF P_SOURCE IS NULL THEN

	  IF (l_debug = 1) THEN
   	  INV_TRX_UTIL_PUB.TRACE('P_Source is null ','inv_loc_issues',10);
	  END IF;

	   SELECT LOCATION_CURRENT_UNITS,
                  location_suggested_units,
		  mixed_items_flag,
		  inventory_item_id,
		  empty_flag
	   INTO l_loc_current_units ,
                l_loc_suggested_units,
		l_mixed_flag,
		l_inventory_item_id,
		l_empty_flag
	   FROM MTL_ITEM_LOCATIONS
	   WHERE INVENTORY_LOCATION_ID = p_locator_id
	      AND ORGANIZATION_ID      = P_ORG_ID;

	   IF ((nvl(l_loc_current_units,0)   = 0)  and
               (nvl(l_loc_suggested_units,0) = 0)) THEN

	      IF (l_debug = 1) THEN
   	      INV_TRX_UTIL_PUB.TRACE('Current/Suggested units is 0 ','inv_loc_issues',10);
	      END IF;
	      x_empty_flag := 'Y';
	      x_mixed_flag := 'N';
	      x_item_id    := null;
	    ELSE
	      x_empty_flag := l_empty_flag;
	      x_mixed_flag := l_mixed_flag;
	      x_item_id    := l_inventory_item_id;
	   END IF;
	ELSE
	  IF (l_debug = 1) THEN
   	  INV_TRX_UTIL_PUB.TRACE('P_Source is not null ','inv_loc_issues',10);
	  END IF;
	       BEGIN
		  SELECT 1
		  INTO l_chk_flag
		  FROM dual
		  WHERE EXISTS (SELECT 1
				FROM MTL_ONHAND_QUANTITIES_DETAIL
				WHERE	LOCATOR_ID        = P_LOCATOR_ID
				   AND	ORGANIZATION_ID	  = P_ORG_ID
				   AND	INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
				 );
		     IF (l_debug = 1) THEN
   		     INV_TRX_UTIL_PUB.TRACE('Item exists in MOQD ','inv_loc_issues',10);
		     END IF;
		  BEGIN
		    SELECT 1
		    INTO l_chk_flag
		    FROM dual
		    WHERE EXISTS (SELECT 1
				  FROM  MTL_ONHAND_QUANTITIES_DETAIL
				  WHERE LOCATOR_ID        =  P_LOCATOR_ID
				    AND ORGANIZATION_ID   =  P_ORG_ID
				    AND INVENTORY_ITEM_ID <> P_INVENTORY_ITEM_ID
				  );
		    x_empty_flag :='N';
		    x_mixed_flag :='Y';
		    x_item_id := NULL;

		    IF (l_debug = 1) THEN
   		    INV_TRX_UTIL_PUB.TRACE('More than  one item exists in locator ', 'inv_loc_issues',10);
		    END IF;
		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		     IF (l_debug = 1) THEN
   		     INV_TRX_UTIL_PUB.TRACE('Only one item exists in locator', 'inv_loc_issues',10);
		     END IF;
		     x_empty_flag :='N';
		     x_mixed_flag :='N';
		     x_item_id    := p_inventory_item_id;
		  END;
		EXCEPTION
		     WHEN NO_DATA_FOUND	THEN
		     IF (l_debug = 1) THEN
   		     INV_TRX_UTIL_PUB.TRACE('Item passed does not exists in MOQD ', 'inv_loc_issues',10);
		     END IF;
		      open item_cnt;
		      loop
			fetch item_cnt into  l_item;
			exit when item_cnt%notfound or item_cnt%rowcount =2;
		      end loop;
			IF item_cnt%rowcount =0	THEN
			  IF (l_debug = 1) THEN
   			  INV_TRX_UTIL_PUB.TRACE('Locator is empty','inv_loc_issues',10);
			  END IF;
			   x_empty_flag	:= 'Y';
			   x_mixed_flag	:= 'N';
			   x_item_id :=	null;
			ELSIF item_cnt%rowcount	=1 THEN
			  IF (l_debug = 1) THEN
   			  INV_TRX_UTIL_PUB.TRACE('One item alone exists	in the locator', 'inv_loc_issues',10);
			  END IF;
			   x_empty_flag	:= 'N';
			   x_mixed_flag	:= 'N';
			   x_item_id :=	l_item.inventory_item_id;
			ELSIF item_cnt%rowcount	=2 THEN
			  IF (l_debug = 1) THEN
   			  INV_TRX_UTIL_PUB.TRACE('More than one	item alone exists in the locator', 'inv_loc_issues',10);
			  END IF;
			   x_empty_flag	:= 'N';
			   x_mixed_flag	:= 'Y';
			   x_item_id :=	null;
			END IF;
		      CLOSE ITEM_CNT;
		END;
	END IF; /* FOR P_SOURCE IS NULL*/
EXCEPTION
 WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	    , 'inv_loc_issues'
	    );
     END IF;
     fnd_msg_pub.count_and_get
	 ( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
END inv_loc_issues;

procedure inv_loc_receipt ( x_return_status     OUT NOCOPY VARCHAR2
			   ,X_MSG_COUNT         OUT NOCOPY NUMBER
			   ,X_MSG_DATA          OUT NOCOPY VARCHAR2
			   ,X_EMPTY_FLAG        OUT NOCOPY VARCHAR2
			   ,X_MIXED_FLAG        OUT NOCOPY VARCHAR2
			   ,X_ITEM_ID           OUT NOCOPY NUMBER
			   ,P_LOCATOR_ID        IN NUMBER
			   ,P_ORG_ID            IN NUMBER
			   ,P_INVENTORY_ITEM_ID IN NUMBER
			   )
is
   l_chk_flag number;
   l_subinventory_code varchar2(30); --Added variable for 3237709
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.TRACE('In Procedure inv_loc_receipt ','receipts',10);
      END IF;
    --Added to get subinventory bug3237709
 SELECT subinventory_code
   INTO l_subinventory_code
   FROM mtl_item_locations
   WHERE  inventory_location_id = p_locator_id
   and    organization_id       = p_org_id;

     BEGIN
	 SELECT 1
	 INTO l_chk_flag
	 FROM dual
	 WHERE EXISTS (
                       -- Onhand
		       SELECT 1
		       FROM  MTL_ONHAND_QUANTITIES_DETAIL
		       WHERE LOCATOR_ID     = P_LOCATOR_ID
			AND ORGANIZATION_ID = P_ORG_ID
			AND INVENTORY_ITEM_ID <> P_INVENTORY_ITEM_ID
                        AND SUBINVENTORY_CODE = l_subinventory_code --Added 3237709

                       UNION ALL --Bug 4566485

                       -- Pending/Suggestion receipts
	               SELECT 1
		       FROM  mtl_material_transactions_temp
		       WHERE LOCATOR_ID     = P_LOCATOR_ID
			AND ORGANIZATION_ID = P_ORG_ID
			AND INVENTORY_ITEM_ID <> P_INVENTORY_ITEM_ID
                        AND POSTING_FLAG    = 'Y'
                        AND transaction_action_id IN (12,27)
                        AND SUBINVENTORY_CODE = l_subinventory_code --Added 3237709

                       UNION ALL --Bug 4566485

                       -- Pending/Suggestion receipts on transfer side
	               SELECT 1
		       FROM  mtl_material_transactions_temp
		       WHERE TRANSFER_TO_LOCATION  = P_LOCATOR_ID
			AND ORGANIZATION_ID        = P_ORG_ID
			AND INVENTORY_ITEM_ID <> P_INVENTORY_ITEM_ID
                        AND POSTING_FLAG           = 'Y'
                        AND transaction_action_id IN (2,3,28)
                        AND SUBINVENTORY_CODE = l_subinventory_code --Added 3237709
		       );

	 X_EMPTY_FLAG := 'N';
	 X_mixed_flag := 'Y';
	 X_item_id    := NULL;

	IF (l_debug = 1) THEN
   	INV_TRX_UTIL_PUB.TRACE('More than 1 item exists in the locator','inv_loc_receipts',10);
	END IF;

       EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   IF (l_debug = 1) THEN
   	   INV_TRX_UTIL_PUB.TRACE('Only one item exists in the locator','inv_loc_receipts',10);
	   END IF;
	      X_EMPTY_FLAG := 'N';
	      x_mixed_flag := 'N';
	      x_item_id    := P_INVENTORY_ITEM_ID;
	END;
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;

     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	    , 'lpn_loc_receipt'
	    );
     END IF;

     fnd_msg_pub.count_and_get
	 ( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );
END inv_loc_receipt;

PROCEDURE lpn_loc_cleanup_mmtt(x_return_status   OUT NOCOPY varchar2 --return status
			  ,x_msg_count       OUT NOCOPY NUMBER --number of messages in message queue
			  ,x_msg_data        OUT NOCOPY varchar2 --message text when x_msg_count>0
			  ,p_organization_id IN NUMBER -- identier for the organization
			  ,p_mixed_flag      IN VARCHAR2
			  )
IS
 cursor mmtt_cur_mixed_flg is
  SELECT MMTT.organization_id,
	 MMTT.inventory_item_id,
	 MMTT.locator_id,
	 MMTT.transfer_organization,
	 MMTT.transfer_to_location,
	 MMTT.transaction_action_id,
	 MMTT.primary_quantity,
	 MMTT.transaction_quantity,
	 MMTT.transfer_lpn_id,
	 MMTT.content_lpn_id,
	 MMTT.lpn_id
   FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT,
	MTL_ITEM_LOCATIONS MIL
   WHERE MMTT.transaction_status <> 2
    AND MMTT.organization_id = p_organization_id
    AND MMTT.LOCATOR_ID = MIL.INVENTORY_LOCATION_ID
    AND MIL.MIXED_ITEMS_FLAG ='Y'
    AND MMTT.locator_id >0
    AND (MMTT.transfer_lpn_id is not null or
	 MMTT.content_lpn_id is not null or
	 MMTT.lpn_id is not null
	);

 cursor mmtt_cur is
  SELECT organization_id,
	 inventory_item_id,
	 locator_id,
	 transfer_organization,
	 transfer_to_location,
	transaction_action_id,
	primary_quantity,
	transaction_quantity,
	transfer_lpn_id,
	content_lpn_id,
	lpn_id
   FROM MTL_MATERIAL_TRANSACTIONS_TEMP
   WHERE transaction_status <> 2
    AND organization_id = p_organization_id
    and locator_id >0
    AND (transfer_lpn_id is not null or
	 content_lpn_id is not null or
	 lpn_id is not null
	);
 l_mmtt_cur_mixed_flg          mmtt_cur_mixed_flg%ROWTYPE;
 l_mmtt_cur                    mmtt_cur%ROWTYPE ;
 l_return_status               varchar2(10);
 l_msg_data                    varchar2(1000);
 l_msg_count                   number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    --Fixed bug 2342723, removed savepoint
    -- bug 3511690 retained the savepoint
    savepoint lpn_loc_mmtt_upd;
    IF p_mixed_flag IS NOT NULL THEN
     open  mmtt_cur_mixed_flg;
     loop
     fetch  mmtt_cur_mixed_flg into l_mmtt_cur_mixed_flg;
     exit when mmtt_cur_mixed_flg%NOTFOUND;
	 IF (l_debug = 1) THEN
   	 INV_TRX_UTIL_PUB.TRACE('Fetch from mmtt_cur_mixed_flg is success','LPN_LOC_CLEANUP_MMTT',4);
	 END IF;

	IF l_mmtt_cur_mixed_flg.transaction_action_id in (2,3,28) then
	    if l_mmtt_cur_mixed_flg.transfer_organization is null then
		l_mmtt_cur_mixed_flg.transfer_organization := l_mmtt_cur_mixed_flg.organization_id;
	     end if;
	    INV_LOC_WMS_UTILS.upd_lpn_loc_curr_cpty_nauto(x_return_status    => l_return_status,
					x_msg_count             => l_msg_count ,
					x_msg_data              => l_msg_data ,
					p_organization_id       => l_mmtt_cur_mixed_flg.transfer_organization,
					p_inventory_location_id => l_mmtt_cur_mixed_flg.transfer_to_location,
					p_inventory_item_id     => l_mmtt_cur_mixed_flg.inventory_item_id,
					p_primary_uom_flag      => 'Y',
					p_transaction_uom_code  => NULL,
					p_transaction_action_id => l_mmtt_cur_mixed_flg.transaction_action_id,
					p_lpn_id                => l_mmtt_cur_mixed_flg.lpn_id,
					p_transfer_lpn_id       => l_mmtt_cur_mixed_flg.transfer_lpn_id,
					p_content_lpn_id        => l_mmtt_cur_mixed_flg.content_lpn_id,
					p_quantity              => l_mmtt_cur_mixed_flg.primary_quantity
						);
	    IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
	       IF (l_debug = 1) THEN
   	       INV_TRX_UTIL_PUB.TRACE('Loc cpty calc -Transfer case- failed with status E','LPN_LOC_CLEANUP_MMTT',10);
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
	       IF (l_debug = 1) THEN
   	       INV_TRX_UTIL_PUB.TRACE('Loc cpty calc-Transfer case- failed with status U','LPN_LOC_CLEANUP_MMTT',10);
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	   INV_LOC_WMS_UTILS.LOC_EMPTY_MIXED_FLAG (
			     X_RETURN_STATUS          => l_return_status
			    ,X_MSG_COUNT              => l_MSG_COUNT
			    ,X_MSG_DATA               => l_MSG_DATA
			    ,P_ORGANIZATION_ID        => l_mmtt_cur_mixed_flg.organization_id
			    ,P_INVENTORY_LOCATION_ID  => l_mmtt_cur_mixed_flg.locator_id
			    ,P_INVENTORY_ITEM_ID      => l_mmtt_cur_mixed_flg.inventory_item_id
			    ,P_TRANSACTION_ACTION_ID  => l_mmtt_cur_mixed_flg.transaction_action_id
			    ,P_TRANSFER_ORGANIZATION  => l_mmtt_cur_mixed_flg.transfer_organization
			    ,P_TRANSFER_LOCATION_ID   => l_mmtt_cur_mixed_flg.transfer_to_location
			    ,P_SOURCE                 => 'CONCURRENT'
						 );
	    IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
	      IF (l_debug = 1) THEN
   	      INV_TRX_UTIL_PUB.TRACE('LOC_EMPTY_MIXED-Transfer Case failed with status E','LPN_LOC_CLEANUP_MMTT',10);
	      END IF;
	      RAISE fnd_api.g_exc_error;
	    ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
	     IF (l_debug = 1) THEN
   	     INV_TRX_UTIL_PUB.TRACE('LOC_EMPTY_MIXED-Transfer case failed with status U','LPN_LOC_CLEANUP_MMTT',10);
	     END IF;
	     RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	ELSE /* For transaction_action_id not in (2,3,28) */
	    INV_LOC_WMS_UTILS.upd_lpn_loc_curr_cpty_nauto(x_return_status    => l_return_status,
				     x_msg_count               => l_msg_count ,
				     x_msg_data                => l_msg_data ,
				     p_organization_id         => l_mmtt_cur_mixed_flg.organization_id,
				     p_inventory_location_id   => l_mmtt_cur_mixed_flg.locator_id,
				     p_inventory_item_id       => l_mmtt_cur_mixed_flg.inventory_item_id,
				     p_primary_uom_flag        => 'Y',
				     p_transaction_uom_code    => NULL,
				     p_transaction_action_id   =>l_mmtt_cur_mixed_flg.transaction_action_id,
				     p_lpn_id                  => l_mmtt_cur_mixed_flg.lpn_id,
				     p_transfer_lpn_id         => l_mmtt_cur_mixed_flg.transfer_lpn_id,
				     p_content_lpn_id          => l_mmtt_cur_mixed_flg.content_lpn_id,
				     p_quantity                => l_mmtt_cur_mixed_flg.primary_quantity
				     );
	     IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
		IF (l_debug = 1) THEN
   		INV_TRX_UTIL_PUB.TRACE('Loc cpty calc - failed with status E','LPN_LOC_CLEANUP_MMTT',10);
		END IF;
		RAISE fnd_api.g_exc_error;
	     ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
		IF (l_debug = 1) THEN
   		INV_TRX_UTIL_PUB.TRACE('Loc cpty calc - failed with status U','LPN_LOC_CLEANUP_MMTT',10);
		END IF;
		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	   INV_LOC_WMS_UTILS.LOC_EMPTY_MIXED_FLAG (
			     X_RETURN_STATUS          => l_return_status
			    ,X_MSG_COUNT              => l_MSG_COUNT
			    ,X_MSG_DATA               => l_MSG_DATA
			    ,P_ORGANIZATION_ID        => l_mmtt_cur_mixed_flg.organization_id
			    ,P_INVENTORY_LOCATION_ID  => l_mmtt_cur_mixed_flg.locator_id
			    ,P_INVENTORY_ITEM_ID      => l_mmtt_cur_mixed_flg.inventory_item_id
			    ,P_TRANSACTION_ACTION_ID  => l_mmtt_cur_mixed_flg.transaction_action_id
			    ,P_TRANSFER_ORGANIZATION  => NULL
			    ,P_TRANSFER_LOCATION_ID   => NULL
			    ,P_SOURCE                 => 'CONCURRENT'
						 );
	      IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
		 IF (l_debug = 1) THEN
   		 INV_TRX_UTIL_PUB.TRACE('LOC_EMPTY_MIXED failed with status E','LPN_LOC_CLEANUP_MMTT',10);
		 END IF;
		 RAISE fnd_api.g_exc_error;
	      ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
		 IF (l_debug = 1) THEN
   		 INV_TRX_UTIL_PUB.TRACE('LOC_EMPTY_MIXED failed with status U','LPN_LOC_CLEANUP_MMTT',10);
		 END IF;
		 RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	  END IF;
      END LOOP;
     close mmtt_cur_mixed_flg;

    ELSE /* P_MIXED_FLAG IS NULL */
    OPEN  mmtt_cur ;
     LOOP
     FETCH  mmtt_cur into l_mmtt_cur ;
     exit when mmtt_cur%NOTFOUND;
	IF (l_debug = 1) THEN
   	INV_TRX_UTIL_PUB.TRACE('Fetch from mmtt_cur is success','LPN_LOC_CLEANUP_MMTT',10);
	END IF;
	IF l_mmtt_cur.transaction_action_id in (2,3,28) then
	    if l_mmtt_cur.transfer_organization is null then
		l_mmtt_cur.transfer_organization := l_mmtt_cur.organization_id;
	     end if;
	    INV_LOC_WMS_UTILS.upd_lpn_loc_curr_cpty_nauto(x_return_status    => l_return_status,
					x_msg_count             => l_msg_count ,
					x_msg_data              => l_msg_data ,
					p_organization_id       => l_mmtt_cur.transfer_organization,
					p_inventory_location_id => l_mmtt_cur.transfer_to_location,
					p_inventory_item_id     => l_mmtt_cur.inventory_item_id,
					p_primary_uom_flag      => 'Y',
					p_transaction_uom_code  => NULL,
					p_transaction_action_id =>l_mmtt_cur.transaction_action_id,
					p_lpn_id                => l_mmtt_cur.lpn_id,
					p_transfer_lpn_id       => l_mmtt_cur.transfer_lpn_id,
					p_content_lpn_id        =>  l_mmtt_cur.content_lpn_id,
					p_quantity              => l_mmtt_cur.primary_quantity
						);
	     IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
		IF (l_debug = 1) THEN
   		INV_TRX_UTIL_PUB.TRACE('Loc cpty calc -Transfer case- failed with status E','LPN_LOC_CLEANUP_MMTT',10);
		END IF;
		RAISE fnd_api.g_exc_error;
	     ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
		IF (l_debug = 1) THEN
   		INV_TRX_UTIL_PUB.TRACE('Loc cpty calc -Transfer case- failed with status U','LPN_LOC_CLEANUP_MMTT',10);
		END IF;
		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	    INV_LOC_WMS_UTILS.LOC_EMPTY_MIXED_FLAG (
			     X_RETURN_STATUS          => l_return_status
			    ,X_MSG_COUNT              => l_MSG_COUNT
			    ,X_MSG_DATA               => l_MSG_DATA
			    ,P_ORGANIZATION_ID        => l_mmtt_cur.organization_id
			    ,P_INVENTORY_LOCATION_ID  => l_mmtt_cur.locator_id
			    ,P_INVENTORY_ITEM_ID      => l_mmtt_cur.inventory_item_id
			    ,P_TRANSACTION_ACTION_ID  => l_mmtt_cur.transaction_action_id
			    ,P_TRANSFER_ORGANIZATION  => l_mmtt_cur.transfer_organization
			    ,P_TRANSFER_LOCATION_ID   => l_mmtt_cur.transfer_to_location
			    ,P_SOURCE                 => 'CONCURRENT'
						 );
	     IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
	       IF (l_debug = 1) THEN
   	       INV_TRX_UTIL_PUB.TRACE('LOC_EMPTY_MIXED-Transfer Case failed with status E','LPN_LOC_CLEANUP_MMTT',10);
	       END IF;
	       RAISE fnd_api.g_exc_error;
	     ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
	       IF (l_debug = 1) THEN
   	       INV_TRX_UTIL_PUB.TRACE('LOC_EMPTY_MIXED-Transfer Case failed with status U','LPN_LOC_CLEANUP_MMTT',10);
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	  ELSE /* For transaction_action_id not in (2,3,28) */
	    INV_LOC_WMS_UTILS.upd_lpn_loc_curr_cpty_nauto(x_return_status    => l_return_status,
				     x_msg_count               => l_msg_count ,
				     x_msg_data                => l_msg_data ,
				     p_organization_id         => l_mmtt_cur.organization_id,
				     p_inventory_location_id   => l_mmtt_cur.locator_id,
				     p_inventory_item_id       => l_mmtt_cur.inventory_item_id,
				     p_primary_uom_flag        => 'Y',
				     p_transaction_uom_code    => NULL,
				     p_transaction_action_id   =>l_mmtt_cur.transaction_action_id,
				     p_lpn_id                  => l_mmtt_cur.lpn_id,
				     p_transfer_lpn_id         => l_mmtt_cur.transfer_lpn_id,
				     p_content_lpn_id          => l_mmtt_cur.content_lpn_id,
				     p_quantity                => l_mmtt_cur.primary_quantity
				     );
	    IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
	      IF (l_debug = 1) THEN
   	      INV_TRX_UTIL_PUB.TRACE('Loc cpty calc - failed with status E','LPN_LOC_CLEANUP_MMTT',10);
	      END IF;
	      RAISE fnd_api.g_exc_error;
	    ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
	      IF (l_debug = 1) THEN
   	      INV_TRX_UTIL_PUB.TRACE('Loc cpty calc - failed with status U','LPN_LOC_CLEANUP_MMTT',10);
	      END IF;
	      RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	      INV_LOC_WMS_UTILS.LOC_EMPTY_MIXED_FLAG (
			     X_RETURN_STATUS          => l_return_status
			    ,X_MSG_COUNT              => l_MSG_COUNT
			    ,X_MSG_DATA               => l_MSG_DATA
			    ,P_ORGANIZATION_ID        => l_mmtt_cur.organization_id
			    ,P_INVENTORY_LOCATION_ID  => l_mmtt_cur.locator_id
			    ,P_INVENTORY_ITEM_ID      => l_mmtt_cur.inventory_item_id
			    ,P_TRANSACTION_ACTION_ID  => l_mmtt_cur.transaction_action_id
			    ,P_TRANSFER_ORGANIZATION  => NULL
			    ,P_TRANSFER_LOCATION_ID   => NULL
			    ,P_SOURCE                 => 'CONCURRENT'
						 );
	       IF X_RETURN_STATUS =fnd_api.g_ret_sts_error THEN
		 IF (l_debug = 1) THEN
   		 INV_TRX_UTIL_PUB.TRACE('LOC_EMPTY_MIXED failed with Return status E','LPN_LOC_CLEANUP_MMTT',10);
		 END IF;
		 RAISE fnd_api.g_exc_error;
	       ELSIF X_RETURN_STATUS =fnd_api.g_ret_sts_unexp_error THEN
		  RAISE fnd_api.g_exc_unexpected_error;
		  IF (l_debug = 1) THEN
   		  INV_TRX_UTIL_PUB.TRACE('LOC_EMPTY_MIXED failed with Return status U','LPN_LOC_CLEANUP_MMTT',10);
		  END IF;
	       END IF;
	  END IF;
      END LOOP;
     CLOSE mmtt_cur;
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.TRACE('successful Completion of LPN_LOC_CLEANUP_MMTT ','LPN_LOC_CLEANUP_MMTT',10);
      END IF;
    END IF;
EXCEPTION

 WHEN fnd_api.g_exc_error THEN
    IF mmtt_cur_mixed_flg%ISOPEN then
       close mmtt_cur_mixed_flg;
    end if;
    IF mmtt_cur%isopen then
       close mmtt_cur;
    end if;
    --Fixed bug 2342723
    rollback to lpn_loc_mmtt_upd;
    --rollback;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
    IF mmtt_cur_mixed_flg%ISOPEN then
       close mmtt_cur_mixed_flg;
    end if;
    IF mmtt_cur%isopen then
       close mmtt_cur;
    end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
    rollback to lpn_loc_mmtt_upd;
    --rollback;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
    IF mmtt_cur_mixed_flg%ISOPEN then
       close mmtt_cur_mixed_flg;
    end if;
    IF mmtt_cur%isopen then
       close mmtt_cur;
    end if;
     x_return_status := fnd_api.g_ret_sts_error;
    rollback to lpn_loc_mmtt_upd;
    --rollback;

   WHEN OTHERS THEN
    IF mmtt_cur_mixed_flg%ISOPEN then
       close mmtt_cur_mixed_flg;
    end if;
    IF mmtt_cur%isopen then
       close mmtt_cur;
     end if;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    rollback to lpn_loc_mmtt_upd;
    --rollback;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'INV_LOC_WMS_UTILS',
	      'lpn_loc_cleanup_mmtt'
	      );
     END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END lpn_loc_cleanup_mmtt;
PROCEDURE LPN_LOC_CURRENT_CAPACITY (
				x_return_status   OUT NOCOPY varchar2 --return status
			       ,x_msg_count       OUT NOCOPY NUMBER --number of messages in message queue
			       ,x_msg_data        OUT NOCOPY varchar2 --message text when x_msg_count>0
			       ,p_organization_id IN NUMBER -- identier for the organization
			       ,p_mixed_flag      IN varchar2
						    )
IS
CURSOR current_cpty  is
  SELECT WLPN.locator_id,
  nvl(sum(DECODE(MIL.LOCATION_WEIGHT_UOM_CODE,WLPN.GROSS_WEIGHT_UOM_CODE,
						     WLPN.gross_weight,
					     GREATEST(INV_CONVERT.INV_UM_CONVERT(
							     null
							    ,null
							    ,WLPN.GROSS_WEIGHT
							    ,WLPN.GROSS_WEIGHT_UOM_CODE
							    ,MIL.LOCATION_WEIGHT_UOM_CODE
							    ,null
							   ,null),0))),0) gross_weight,

	 nvl(sum(DECODE(MIL.VOLUME_UOM_CODE,WLPN.CONTENT_VOLUME_UOM_CODE,
					       WLPN.content_volume,
					      GREATEST(INV_CONVERT.INV_UM_CONVERT(
							     null
							    ,null
							    ,WLPN.CONTENT_VOLUME
							    ,WLPN.CONTENT_VOLUME_UOM_CODE
							    ,MIL.VOLUME_UOM_CODE
							    ,null
							   ,null),0))),0) content_volume
  FROM wms_license_plate_numbers WLPN,
       MTL_ITEM_LOCATIONS MIL
  WHERE MIL.INVENTORY_LOCATION_ID = WLPN.LOCATOR_ID
    AND WLPN.organization_id =p_organization_id
    AND WLPN.lpn_context =1
    AND WLPN.parent_lpn_id is null
    AND WLPN.locator_id  >0
  GROUP by  WLPN.locator_id ;

 CURSOR curr_cpty_mixed_flg  is
  SELECT WLPN.locator_id,
	 nvl(sum(DECODE(MIL.LOCATION_WEIGHT_UOM_CODE,WLPN.GROSS_WEIGHT_UOM_CODE,
						     WLPN.gross_weight,
					     GREATEST(INV_CONVERT.INV_UM_CONVERT(
							     null
							    ,null
							    ,WLPN.GROSS_WEIGHT
							    ,WLPN.GROSS_WEIGHT_UOM_CODE
							    ,MIL.LOCATION_WEIGHT_UOM_CODE
							    ,null
							   ,null),0))),0) gross_weight,

	 nvl(sum(DECODE(MIL.VOLUME_UOM_CODE,WLPN.CONTENT_VOLUME_UOM_CODE,
					       WLPN.content_volume,
					      GREATEST(INV_CONVERT.INV_UM_CONVERT(
							     null
							    ,null
							    ,WLPN.CONTENT_VOLUME
							    ,WLPN.CONTENT_VOLUME_UOM_CODE
							    ,MIL.VOLUME_UOM_CODE
							    ,null
							   ,null),0))),0) content_volume
  FROM wms_license_plate_numbers WLPN,
       MTL_ITEM_LOCATIONS MIL
  WHERE WLPN.LOCATOR_ID =  MIL.INVENTORY_LOCATION_ID
    AND WLPN.organization_id =p_organization_id
    AND WLPN.lpn_context =1
    AND WLPN.parent_lpn_id is null
    AND WLPN.locator_id  >0
    AND MIL.MIXED_ITEMS_FLAG ='Y'
  GROUP by  WLPN.locator_id ;

 l_curr_cpty                   current_cpty%ROWTYPE;
 l_curr_cpty_mixed_flg         curr_cpty_mixed_flg%ROWTYPE ;
 l_physical_locator_id         NUMBER;
 l_locator_id                  NUMBER;
 l_inventory_location_id       NUMBER;
 l_return_status               VARCHAR2(1);
 l_msg_data                    VARCHAR2(1000);
 l_msg_count                   NUMBER;
 l_units                       NUMBER ;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    IF (l_debug = 1) THEN
       INV_TRX_UTIL_PUB.TRACE('In LPN_LOC_CURRENT_CAPACITY  Procedure ','LPN_LOC_CURRENT_CAPACITY',9);
    END IF;
   x_return_status := fnd_api.g_ret_sts_success;
   --Fixed bug 2342723, romoved the savepoint
   -- Bug 3511690 savepoint retained
   savepoint lpn_loc_cpty_upd;
   IF p_mixed_flag IS NOT NULL THEN
    OPEN curr_cpty_mixed_flg;
     LOOP
       FETCH curr_cpty_mixed_flg INTO l_curr_cpty_mixed_flg;
       EXIT WHEN curr_cpty_mixed_flg %NOTFOUND;
       /* If the locator has a physical_location_id
	  then use the physical_location_id for further
	  processing.Else we have to use the inventory_location_id
	  for further processing
	*/
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('Curr_cpty_mixed_flag is successful ','LPN_LOC_CURRENT_CAPACITY',10);
       END IF;
	l_inventory_location_id :=null;
	l_physical_locator_id :=null;
	l_locator_id :=null;

	SELECT physical_location_id ,
	       inventory_location_id
	INTO l_physical_locator_id,
	     l_locator_id
	FROM mtl_item_locations
	WHERE  inventory_location_id =l_curr_cpty.locator_id
	    and organization_id = p_organization_id;

	IF l_physical_locator_id is null THEN
	  l_inventory_location_id := l_locator_id;
	ELSE
	  l_inventory_location_id := l_physical_locator_id;
	END IF;
	/* Update current weight and current cubic area of the locator with the
	    LPN's gross weight and content volume
	*/
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('The value of locator _id is '||to_char(l_inventory_location_id), 'LPN_LOC_CURRENT_CAPACITY',10);
          INV_TRX_UTIL_PUB.TRACE('The value of org_id is'||to_char(p_organization_id),'LPN_LOC_CURRENT_CAPACITY',10);
          INV_TRX_UTIL_PUB.TRACE('The value of gross_weight is '||to_char(l_curr_cpty.gross_weight), 'LPN_LOC_CURRENT_CAPACITY',10);
          INV_TRX_UTIL_PUB.TRACE('The value of content_volume is '||to_char(l_curr_cpty.content_volume), 'LPN_LOC_CURRENT_CAPACITY',10);
       END IF;
       begin
        SELECT sum(abs(primary_transaction_quantity))
        into l_units
        FROM MTL_ONHAND_QUANTITIES_DETAIL
        WHERE locator_id = l_inventory_location_id
          AND containerized_flag = 1
          AND locator_id >0
          AND organization_id =p_organization_id;
       exception
         when no_data_found then
         null;
       end;

	UPDATE mtl_item_locations
	set current_weight=nvl(current_weight,0)+l_curr_cpty.gross_weight,
	    available_weight = max_weight-(nvl(suggested_weight,0) + nvl(current_weight,0)),
	   current_cubic_area = nvl(current_cubic_area,0) + l_curr_cpty.content_volume,
	   available_cubic_area = max_cubic_area -(nvl(suggested_cubic_area,0)+nvl(current_cubic_area,0)),
           LOCATION_CURRENT_UNITS = nvl(LOCATION_CURRENT_UNITS,0) + l_units,
           LOCATION_AVAILABLE_UNITS = greatest(nvl(LOCATION_MAXIMUM_UNITS,0)-(nvl(LOCATION_SUGGESTED_UNITS,0)+ nvl(LOCATION_CURRENT_UNITS,0)),0)
	where
	     inventory_location_id =l_inventory_location_id
	  and organization_id = p_organization_id;
     end loop;
     close curr_cpty_mixed_flg;

   ELSE
    open current_cpty;
     loop
      fetch current_cpty into  l_curr_cpty;
       exit when current_cpty%notfound;
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('Fetch from current_cpty is success','LPN_LOC_CURRENT_CAPACITY',10);
       END IF;

       /* If the locator has a physical_location_id
	  then use the physical_location_id for further
	  processing.Else we have to use the inventory_location_id
	  for further processing
	*/
	l_inventory_location_id :=null;
	l_physical_locator_id :=null;
	l_locator_id :=null;

	SELECT physical_location_id ,
	       inventory_location_id
	INTO l_physical_locator_id,
	     l_locator_id
	FROM mtl_item_locations
	WHERE  inventory_location_id =l_curr_cpty.locator_id
	    and organization_id = p_organization_id;

	IF l_physical_locator_id is null THEN
	  l_inventory_location_id := l_locator_id;
	ELSE
	  l_inventory_location_id := l_physical_locator_id;
	END IF;
	/* Update current weight and current cubic area of the locator with the
	    LPN gross weight and content volume
	*/
       IF (l_debug = 1) THEN
          INV_TRX_UTIL_PUB.TRACE('The value of locator _id is '||to_char(l_inventory_location_id), 'LPN_LOC_CURRENT_CAPACITY',10);
          INV_TRX_UTIL_PUB.TRACE('The value of org_id is'||to_char(p_organization_id),'LPN_LOC_CURRENT_CAPACITY',10);
          INV_TRX_UTIL_PUB.TRACE('The value of gross_weight is '||to_char(l_curr_cpty.gross_weight), 'LPN_LOC_CURRENT_CAPACITY',10);
          INV_TRX_UTIL_PUB.TRACE('The value of content_volume is '||to_char(l_curr_cpty.content_volume), 'LPN_LOC_CURRENT_CAPACITY',10);
       END IF;
       begin
        SELECT sum(abs(primary_transaction_quantity))
        into l_units
        FROM MTL_ONHAND_QUANTITIES_DETAIL
        WHERE locator_id = l_inventory_location_id
          AND containerized_flag = 1
          AND locator_id >0
          AND organization_id =p_organization_id;
       exception
          when no_data_found then
          null;
        end;

	UPDATE mtl_item_locations
	set current_weight=nvl(current_weight,0)+l_curr_cpty.gross_weight,
	    available_weight = max_weight-(nvl(suggested_weight,0) + nvl(current_weight,0)),
	   current_cubic_area = nvl(current_cubic_area,0) + l_curr_cpty.content_volume,
	   available_cubic_area = max_cubic_area -(nvl(suggested_cubic_area,0)+nvl(current_cubic_area,0)),
           LOCATION_CURRENT_UNITS = nvl(LOCATION_CURRENT_UNITS,0) + nvl(l_units,0),
           LOCATION_AVAILABLE_UNITS = greatest(nvl(LOCATION_MAXIMUM_UNITS,0)-(nvl(LOCATION_SUGGESTED_UNITS,0)+ nvl(LOCATION_CURRENT_UNITS,0)),0)
	where
	     inventory_location_id =l_inventory_location_id
	  and organization_id = p_organization_id;
     end loop;
   close current_cpty;
   END IF;
EXCEPTION
 WHEN fnd_api.g_exc_error THEN
    IF current_cpty%ISOPEN then
       close current_cpty;
    end if;
    IF curr_cpty_mixed_flg%isopen then
       close curr_cpty_mixed_flg;
    end if;
    -- Fixed bug 2342723, do not rollback to savepoint
    rollback to lpn_loc_cpty_upd;
    --rollback;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
    IF current_cpty%ISOPEN then
       close current_cpty;
    end if;
    IF curr_cpty_mixed_flg%isopen then
       close curr_cpty_mixed_flg;
    end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
    rollback to lpn_loc_cpty_upd;
    --rollback;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
    IF current_cpty%ISOPEN then
       close current_cpty;
    end if;
    IF curr_cpty_mixed_flg%isopen then
       close curr_cpty_mixed_flg;
    end if;
     x_return_status := fnd_api.g_ret_sts_error;
    rollback to lpn_loc_cpty_upd;
    --rollback;

   WHEN OTHERS THEN
    IF current_cpty%ISOPEN then
       close current_cpty;
    end if;
    IF curr_cpty_mixed_flg%isopen then
       close curr_cpty_mixed_flg;
     end if;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
     rollback to lpn_loc_cpty_upd;
    --rollback;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'INV_LOC_WMS_UTILS',
	      'LPN_LOC_CURRENT_CAPACITY'
	      );
     END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END LPN_LOC_CURRENT_CAPACITY;

procedure upd_empty_mixed_flag_rcv_loc ( x_return_status      OUT NOCOPY VARCHAR2
					 ,x_msg_count         OUT NOCOPY NUMBER
					 ,x_msg_data          OUT NOCOPY VARCHAR2
					 ,p_subinventory      IN VARCHAR2
					 ,p_locator_id        IN NUMBER
					 ,p_org_id            IN NUMBER
					 )
  is
     l_chk_flag number;
     l_empty_flag VARCHAR2(1) := 'Y';
     l_mixed_flag VARCHAR2(1) := 'N';
     l_mixed_num NUMBER := 0;

     l_physical_locator_id NUMBER := NULL;
     l_locator_id NUMBER;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_locator_id := p_locator_id;

   IF (l_debug = 1) THEN
      mdebug('UPD_EMPTY_MIXED_FLAG_RCV_LOC: Subinv : '||p_subinventory);
      mdebug('UPD_EMPTY_MIXED_FLAG_RCV_LOC: Loc ID : '||p_locator_id);
      mdebug('UPD_EMPTY_MIXED_FLAG_RCV_LOC: Org ID : '||p_org_id);
   END IF;

   -- Get the physical locator id for PJM.
   SELECT physical_location_id,
     inventory_location_id
     INTO l_physical_locator_id,
     l_locator_id
     FROM mtl_item_locations
     WHERE  inventory_location_id = p_locator_id
     and organization_id = p_org_id;

   IF (l_debug = 1) THEN
      mdebug('UPD_EMPTY_MIXED_FLAG_RCV_LOC: Physical Loc ID : '||l_physical_locator_id);
   END IF;

   IF l_physical_locator_id IS NOT NULL THEN
      l_locator_id := l_physical_locator_id;
   END IF;

   BEGIN
      SELECT 1
	INTO l_chk_flag
	FROM dual
	WHERE EXISTS (
		      SELECT 1
		      FROM  rcv_supply rs
		      WHERE rs.to_locator_id    = p_locator_id
		      AND rs.to_organization_id = p_org_id
		      AND rs.to_subinventory    = p_subinventory
		      AND rs.quantity           > 0
		      );

      l_empty_flag := 'N';
      l_mixed_flag := 'N';

      IF (l_debug = 1) THEN
	 mdebug('UPD_EMPTY_MIXED_FLAG_RCV_LOC: Locator is not empty');
      END IF;

      SELECT COUNT(DISTINCT item_id)
	INTO l_mixed_num
	FROM rcv_supply rs
	WHERE rs.to_locator_id    = p_locator_id
	AND rs.to_organization_id = p_org_id
	AND rs.to_subinventory    = p_subinventory
	AND rs.quantity           > 0;

      IF (l_mixed_num > 1) THEN
	 l_mixed_flag := 'Y';

	 IF (l_debug = 1) THEN
	    mdebug('UPD_EMPTY_MIXED_FLAG_RCV_LOC: Locator had Mixed Items');
	 END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	   IF (l_debug = 1) THEN
	      mdebug('UPD_EMPTY_MIXED_FLAG_RCV_LOC: Locator is empty');
	   END IF;
	   l_EMPTY_FLAG := 'Y';
	   l_mixed_flag := 'N';
   END;

   --Update the empty flag/mixed flag
   UPDATE mtl_item_locations mil
     SET empty_flag     = NVL(l_empty_flag,mil.empty_flag)
     , mixed_items_flag = NVL(l_mixed_flag,mil.mixed_items_flag)
     , last_update_date     = sysdate                                                       /* Added for Bug 6363028 */
     WHERE inventory_location_id = l_locator_id
     AND organization_id         = p_org_id;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg
	   (  'inv_loc_wms_utils'
	      , 'upd_empty_mixed_flag_rcv_loc'
	      );
      END IF;

      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
END upd_empty_mixed_flag_rcv_loc;

--Added following procedure for bug #6976034
procedure get_locator_id ( x_locator_id OUT NOCOPY NUMBER, p_locator VARCHAR2 ,p_org_id NUMBER ) IS

l_operation VARCHAR2(100);
l_locator VARCHAR2(32000)   := p_locator;
l_org_id  NUMBER            := p_org_id ;
l_val     BOOLEAN ;

BEGIN

fnd_flex_key_api.set_session_mode('seed_data');

l_operation := 'FIND_COMBINATION';

l_val := FND_FLEX_KEYVAL.Validate_Segs(
                  OPERATION        => l_operation,
                  APPL_SHORT_NAME  => 'INV',
                  KEY_FLEX_CODE    => 'MTLL',
                  STRUCTURE_NUMBER => 101,
                  CONCAT_SEGMENTS  => l_locator,
                  VALUES_OR_IDS    => 'I',
                  DATA_SET         => l_org_id ) ;

if l_val then
   x_locator_id := fnd_flex_keyval.combination_id;
else
   x_locator_id := NULL;
end if;

EXCEPTION
WHEN OTHERS THEN
   x_locator_id := NULL;
END get_locator_id;


-- 8721026
PROCEDURE get_source_type
  (
    x_source              OUT NOCOPY VARCHAR2,
    p_locator_id          IN NUMBER,
    p_organization_id     IN  NUMBER,   -- org of locator whose capacity is to be determined
    p_inventory_item_id   IN NUMBER,
    p_content_lpn_id      IN NUMBER,
    p_transaction_action_id  IN NUMBER,
    p_primary_quantity     IN NUMBER
  )
IS
  l_source_max_units      NUMBER;
  l_source_max_weight     NUMBER;
  l_source_max_cubic_area NUMBER;
  p_source                VARCHAR2(10) := NULL;
  l_onhand_for_others     NUMBER := NULL;
  l_onhand_qty_for_item   NUMBER := NULL;
  l_item_count            NUMBER := NULL;
  l_return_status              varchar2(1);
  l_msg_data                   varchar2(1000);
  l_msg_count                  number;

  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN

  --p_source := NULL;
  IF p_transaction_action_id IN(1,2,4,28) THEN
          SELECT location_maximum_units,
                 max_weight            ,
                 max_cubic_area
          INTO   l_source_max_units ,
                 l_source_max_weight,
                 l_source_max_cubic_area
          FROM   mtl_item_locations
          WHERE  inventory_location_id = p_locator_id
             AND organization_id       = p_organization_id;

  END IF;
  IF l_source_max_units IS NULL AND l_source_max_weight IS NULL AND l_source_max_cubic_area IS NULL THEN
          IF (l_debug         = 1) THEN
                  inv_trx_util_pub.TRACE('In DB TRIGGER - The locator id  '
                  || p_locator_id
                  ||' has infinite capacity', 'get_source_type', 4);
          END IF;
          l_item_count                         := 0;
          l_onhand_qty_for_item                := 0;
          IF p_transaction_action_id IN (1, 2, 4,28) THEN
                  IF p_content_lpn_id IS NOT NULL THEN
                          BEGIN
                                  SELECT 1
                                  INTO   l_onhand_for_others
                                  FROM   mtl_onhand_quantities_detail
                                  WHERE  locator_id      = p_locator_id
                                     AND organization_id = p_organization_id
                                     AND (
                                                lpn_id      <> p_content_lpn_id
                                             OR lpn_id IS NULL
                                         )
                                     AND rownum<2;

                          EXCEPTION
                          WHEN OTHERS THEN
                                  l_onhand_for_others := 0;
                                  inv_trx_util_pub.TRACE(' Exception is thrown when selecting l_onhand_for_others ' , 'get_source_type', 4);
                          END;
                          inv_trx_util_pub.TRACE(' After selecting l_onhand_for_others '
                          || l_onhand_for_others
                          || ' -- content_lpn_id --'
                          || p_content_lpn_id , 'get_source_type', 4);
                  END IF ;
                  IF p_content_lpn_id IS NOT NULL AND l_onhand_for_others = 1 THEN
                          p_source             := 'INFINITE';
                  ELSE
                          BEGIN
                                  inv_trx_util_pub.TRACE(' before selecting l_ietm_count, l_item_count is- '
                                  || l_item_count
                                  || 'p_inventory_item_id is -'
                                  || p_inventory_item_id
                                  || ' p_locator_id is-'
                                  ||p_locator_id , 'get_source_type', 4);
                                  IF (p_inventory_item_id > 0) THEN
                                          SELECT COUNT(DISTINCT inventory_item_id)
                                          INTO   l_item_count
                                          FROM   mtl_onhand_quantities_detail
                                          WHERE  locator_id         = p_locator_id
                                             AND organization_id    = p_organization_id
                                             AND inventory_item_id <> p_inventory_item_id;

                                  END IF;
                          EXCEPTION
                          WHEN OTHERS THEN
                                  inv_trx_util_pub.TRACE(' Exception is thrown when selecting l_item_count ' , 'get_source_type', 4);
                          END;
                          inv_trx_util_pub.TRACE(' After selecting l_item_count '
                          || l_item_count , 'get_source_type', 4);
                          IF l_item_count   > 0 THEN
                                  p_source := 'INFINITE';
                          ELSE
                                  BEGIN
                                          SELECT SUM(primary_transaction_quantity)
                                          INTO   l_onhand_qty_for_item
                                          FROM   mtl_onhand_quantities_detail
                                          WHERE  locator_id        = p_locator_id
                                             AND organization_id   = p_organization_id
                                             AND inventory_item_id = p_inventory_item_id;

                                  EXCEPTION
                                  WHEN OTHERS THEN
                                          inv_trx_util_pub.TRACE(' Exception is thrown when selecting l_onhand_qty_for_item ' , 'get_source_type', 4);
                                  END;
                                  inv_trx_util_pub.TRACE(' l_onhand_qty_for_item is'
                                  || l_onhand_qty_for_item, 'get_source_type', 4);
                                  inv_trx_util_pub.TRACE(' ABS(p_primary_quantity) is'
                                  || ABS(p_primary_quantity), 'get_source_type', 4);
                                  IF ABS(p_primary_quantity) < l_onhand_qty_for_item THEN
                                          p_source          := 'INFINITE';
                                  ELSE
                                          p_source:= NULL;
                                  END IF;
                          END IF;
                  END IF;
          END IF;
  END IF ;

  x_source:=p_source;

 inv_trx_util_pub.TRACE('  p_source 1 is - '|| p_source , 'get_source_type', 4);
 END get_source_type;

END inv_loc_wms_utils;

/
