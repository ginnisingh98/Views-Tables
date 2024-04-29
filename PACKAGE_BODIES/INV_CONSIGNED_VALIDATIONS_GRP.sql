--------------------------------------------------------
--  DDL for Package Body INV_CONSIGNED_VALIDATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSIGNED_VALIDATIONS_GRP" AS
/* $Header: INVVMIGB.pls 120.1 2005/06/16 15:31:39 appldev  $ */


/*------------------------*
 * GET_CONSIGNED_QUANTITY *
 *------------------------*/
/** This API will return VMI/consigned Quantity */


PROCEDURE GET_CONSIGNED_QUANTITY(
   p_api_version_number       IN  NUMBER
,  p_init_msg_lst             IN  VARCHAR2
,  x_return_status            OUT NOCOPY VARCHAR2
,  x_msg_count                OUT NOCOPY NUMBER
,  x_msg_data                 OUT NOCOPY VARCHAR2
,  p_tree_mode                IN NUMBER
,  p_organization_id          IN NUMBER
,  p_owning_org_id            IN NUMBER
,  p_planning_org_id          IN NUMBER
,  p_inventory_item_id        IN NUMBER
,  p_is_revision_control      IN VARCHAR2
,  p_is_lot_control           IN VARCHAR2
,  p_is_serial_control        IN VARCHAR2
,  p_revision                 IN VARCHAR2
,  p_lot_number               IN VARCHAR2
,  p_lot_expiration_date      IN DATE
,  p_subinventory_code        IN VARCHAR2
,  p_locator_id               IN NUMBER
,  p_source_type_id           IN NUMBER
,  p_demand_source_line_id    IN NUMBER
,  p_demand_source_header_id  IN NUMBER
,  p_demand_source_name       IN VARCHAR2
,  p_onhand_source            IN NUMBER
,  p_cost_group_id            IN NUMBER
,  p_query_mode               IN NUMBER
,  x_qoh                      OUT NOCOPY NUMBER
,  x_att  				      OUT NOCOPY NUMBER
) IS

-- invConv changes begin : Calling the overloaded API
l_sqoh        NUMBER;
l_satt        NUMBER;
BEGIN

GET_CONSIGNED_QUANTITY(
   p_api_version_number       => p_api_version_number
,  p_init_msg_lst             => p_init_msg_lst
,  x_return_status            => x_return_status
,  x_msg_count                => x_msg_count
,  x_msg_data                 => x_msg_data
,  p_tree_mode                => p_tree_mode
,  p_organization_id          => p_organization_id
,  p_owning_org_id            => p_owning_org_id
,  p_planning_org_id          => p_planning_org_id
,  p_inventory_item_id        => p_inventory_item_id
,  p_is_revision_control      => p_is_revision_control
,  p_is_lot_control           => p_is_lot_control
,  p_is_serial_control        => p_is_serial_control
,  p_revision                 => p_revision
,  p_lot_number               => p_lot_number
,  p_lot_expiration_date      => p_lot_expiration_date
,  p_subinventory_code        => p_subinventory_code
,  p_locator_id               => p_locator_id
,  p_grade_code               => NULL                         -- invConv change
,  p_source_type_id           => p_source_type_id
,  p_demand_source_line_id    => p_demand_source_line_id
,  p_demand_source_header_id  => p_demand_source_header_id
,  p_demand_source_name       => p_demand_source_name
,  p_onhand_source            => p_onhand_source
,  p_cost_group_id            => p_cost_group_id
,  p_query_mode               => p_query_mode
,  x_qoh                      => x_qoh
,  x_att                      => x_att
,  x_sqoh                     => l_sqoh                        -- invConv change
,  x_satt                     => l_satt);                      -- invConv change
-- invConv changes end.

END GET_CONSIGNED_QUANTITY;

-- invConv changes begin : Overloaded API
PROCEDURE GET_CONSIGNED_QUANTITY(
   p_api_version_number       IN  NUMBER
,  p_init_msg_lst             IN  VARCHAR2
,  x_return_status            OUT NOCOPY VARCHAR2
,  x_msg_count                OUT NOCOPY NUMBER
,  x_msg_data                 OUT NOCOPY VARCHAR2
,  p_tree_mode                IN NUMBER
,  p_organization_id          IN NUMBER
,  p_owning_org_id            IN NUMBER
,  p_planning_org_id          IN NUMBER
,  p_inventory_item_id        IN NUMBER
,  p_is_revision_control      IN VARCHAR2
,  p_is_lot_control           IN VARCHAR2
,  p_is_serial_control        IN VARCHAR2
,  p_revision                 IN VARCHAR2
,  p_lot_number               IN VARCHAR2
,  p_lot_expiration_date      IN DATE
,  p_subinventory_code        IN VARCHAR2
,  p_locator_id               IN NUMBER
,  p_grade_code               IN VARCHAR2                   -- invConv changes
,  p_source_type_id           IN NUMBER
,  p_demand_source_line_id    IN NUMBER
,  p_demand_source_header_id  IN NUMBER
,  p_demand_source_name       IN VARCHAR2
,  p_onhand_source            IN NUMBER
,  p_cost_group_id            IN NUMBER
,  p_query_mode               IN NUMBER
,  x_qoh                      OUT NOCOPY NUMBER
,  x_att                      OUT NOCOPY NUMBER
,  x_sqoh                     OUT NOCOPY NUMBER             -- invConv changes
,  x_satt                     OUT NOCOPY NUMBER             -- invConv changes
) IS

    l_api_version_number        CONSTANT NUMBER       := 1.0;
    l_api_name                  CONSTANT VARCHAR2(30) := 'GET_CONSIGNED_QUANTITY';
    l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

	IF (l_debug = 1) THEN
   	inv_log_util.trace('****** GET_CONSIGNED_QUANTITIES *******','CONSIGNED_VALIDATIONS_GRP',9);
   	inv_log_util.trace(' Org, Owning_org, planning_org='|| p_organization_id ||','
		|| p_owning_org_id ||','||p_planning_org_id,'CONSIGNED_VALIDATIONS_GRP',9);
   	inv_log_util.trace(' Item, Is Rev, Lot, Serial controlled: '||p_inventory_item_id|| ','||
		p_is_revision_control ||','|| p_is_lot_control ||','|| p_is_serial_control,'CONSIGNED_VALIDATIONS_GRP',9);
   	inv_log_util.trace(' Rev, Lot, LotExpDate: '|| p_revision ||','||p_lot_number ||','|| p_lot_expiration_date,'CONSIGNED_VALIDATIONS_GRP',9);
   	inv_log_util.trace(' Sub, Loc: '||p_subinventory_code||','||p_locator_id,'CONSIGNED_VALIDATIONS_GRP',9);
   	inv_log_util.trace(' SourceTypeID, DemdSrcLineID, DemdSrcHdrID, DemdSrcName: ' ||
		p_source_type_id ||',' ||p_demand_source_line_id || ','||
		p_demand_source_header_id || ',' || p_demand_source_name,'CONSIGNED_VALIDATIONS_GRP',9);
   	inv_log_util.trace(' OnhandSource, CstGroupID, QueryMode: '|| p_onhand_source || ','||
		p_cost_group_id ||',' ||p_query_mode,'CONSIGNED_VALIDATIONS_GRP',9);
    END IF;

    INV_CONSIGNED_VALIDATIONS.GET_CONSIGNED_QUANTITY(
        x_return_status       	 =>  l_return_status
      , x_return_msg          	 =>  x_msg_data
      , p_tree_mode           	 =>  p_tree_mode
      , p_organization_id     	 =>  p_organization_id
      , p_owning_org_id       	 =>  p_owning_org_id
      , p_planning_org_id     	 =>  p_planning_org_id
      , p_inventory_item_id   	 =>  p_inventory_item_id
      , p_is_revision_control 	 =>  p_is_revision_control
      , p_is_lot_control      	 =>  p_is_lot_control
      , p_is_serial_control   	 =>  p_is_serial_control
      , p_revision            	 =>  p_revision
      , p_lot_number          	 =>  p_lot_number
      , p_lot_expiration_date 	 =>  p_lot_expiration_date
      , p_subinventory_code   	 =>  p_subinventory_code
      , p_locator_id          	 =>  p_locator_id
      , p_grade_code             =>  p_grade_code                      -- invConv change
      , p_source_type_id      	 =>  p_source_type_id
      , p_demand_source_line_id	 =>  p_demand_source_line_id
      , p_demand_source_header_id=>  p_demand_source_header_id
      , p_demand_source_name 	 =>  p_demand_source_name
      , p_onhand_source      	 =>  p_onhand_source
      , p_cost_group_id      	 =>  p_cost_group_id
      , p_query_mode         	 =>  p_query_mode
      , x_qoh                	 =>  x_qoh
      , x_att                	 =>  x_att
      , x_sqoh                	 =>  x_sqoh                           -- invConv change
      , x_satt                	 =>  x_satt                           -- invConv change
    );


	IF l_return_status = fnd_api.g_ret_sts_error THEN
	   RAISE fnd_api.g_exc_error;
	END IF ;

	IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	x_return_status := l_return_status;

    IF(l_debug=1)THEN
        inv_log_util.trace('Finished calling INV_CONSIGNED_VALIDATIONS.GET_CONSIGNED_QUANTITY','CONSIGNED_VALIDATIONS',9);
	END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END get_consigned_quantity;


/*  This API returns the onhand quantity for planning purpose */

PROCEDURE GET_PLANNING_QUANTITY(
   p_api_version_number IN  NUMBER
,  p_init_msg_lst       IN  VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  p_include_nonnet     IN  NUMBER
,  p_level              IN  NUMBER
,  p_org_id             IN  NUMBER
,  p_subinv             IN  VARCHAR2
,  p_item_id            IN  NUMBER
,  x_planning_qty       OUT NOCOPY NUMBER
) IS

-- invConv changes begion : calling the overloaded API
l_planning_sqty         NUMBER;
BEGIN
GET_PLANNING_QUANTITY(
   p_api_version_number => p_api_version_number
,  p_init_msg_lst       => p_init_msg_lst
,  x_return_status      => x_return_status
,  x_msg_count          => x_msg_count
,  x_msg_data           => x_msg_data
,  p_include_nonnet     => p_include_nonnet
,  p_level              => p_level
,  p_org_id             => p_org_id
,  p_subinv             => p_subinv
,  p_item_id            => p_item_id
,  p_grade_code         => NULL
,  x_planning_qty       => x_planning_qty
,  x_planning_sqty      => l_planning_sqty);
-- invConv changes end.

END GET_PLANNING_QUANTITY;

-- invConv changes begin : new overloaded API
PROCEDURE GET_PLANNING_QUANTITY(
   p_api_version_number IN  NUMBER
,  p_init_msg_lst       IN  VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  p_include_nonnet     IN  NUMBER
,  p_level              IN  NUMBER
,  p_org_id             IN  NUMBER
,  p_subinv             IN  VARCHAR2
,  p_item_id            IN  NUMBER
,  p_grade_code         IN  VARCHAR2                       -- invConv change
,  x_planning_qty       OUT NOCOPY NUMBER
,  x_planning_sqty      OUT NOCOPY NUMBER                  -- invConv change
) IS


    l_api_version_number        CONSTANT NUMBER       := 1.0;
    l_api_name                  CONSTANT VARCHAR2(30) := 'GET_PLANNING_QUANTITY';
    l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_qty NUMBER := 0;
    l_sqty NUMBER := NULL;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    IF (l_debug=1) THEN
        inv_log_util.trace('*** GET_PLANNING_QUANTITY ***','CONSIGNED_VALIDATIONS_GRP',9);
        inv_log_util.trace('p_include_nonnet=' || to_char(p_include_nonnet)   ||
                  ', p_level='        || to_char(p_level)            ||
                  ', p_org_id='       || to_char(p_org_id)           ||
                  ', p_subinv='       || p_subinv                    ||
                  ', p_item_id='      || to_char(p_item_id)
                  , 'CONSIGNED_VALIDATIONS_GRP', 9);
    END IF;

    -- invConv changes begin : calling API that returns secondary qty too
    -- l_qty := INV_CONSIGNED_VALIDATIONS.GET_PLANNING_QUANTITY(
    --              P_INCLUDE_NONNET =>   P_INCLUDE_NONNET
    --            , P_LEVEL          =>   P_LEVEL
    --            , P_ORG_ID         =>   P_ORG_ID
    --            , P_SUBINV         =>   P_SUBINV
    --            , P_ITEM_ID        =>   P_ITEM_ID);
    --
    INV_CONSIGNED_VALIDATIONS.GET_PLANNING_QUANTITY(
                 P_INCLUDE_NONNET =>   P_INCLUDE_NONNET
               , P_LEVEL          =>   P_LEVEL
               , P_ORG_ID         =>   P_ORG_ID
               , P_SUBINV         =>   P_SUBINV
               , P_ITEM_ID        =>   P_ITEM_ID
               , P_GRADE_CODE     =>   P_GRADE_CODE
               , X_QOH            =>   l_qty
               , X_SQOH           =>   l_sqty);
    -- invConv changes end.

    x_return_status := l_return_status;
    x_planning_qty := l_qty;
    x_planning_sqty := l_sqty;            -- invConv changes

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END GET_PLANNING_QUANTITY;

--Bug 4239469: Added this new procedure to get the available qty
/*  This API returns the onhand quantity for planning/atp purpose */

PROCEDURE get_planning_sd_quantity
  (
     p_api_version_number IN  NUMBER
     ,  p_init_msg_lst       IN  VARCHAR2
     ,  x_return_status      OUT NOCOPY VARCHAR2
     ,  x_msg_count          OUT NOCOPY NUMBER
     ,  x_msg_data           OUT NOCOPY VARCHAR2
     ,  p_onhand_source      IN  NUMBER
     ,  p_org_id             IN  NUMBER
     ,  p_item_id            IN  NUMBER
     ,  x_planning_qty       OUT NOCOPY NUMBER
     ) IS

	l_api_version_number        CONSTANT NUMBER       := 1.0;
	l_api_name                  CONSTANT VARCHAR2(30) := 'GET_PLANNING_SD_QUANTITY';
	l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
	l_qty NUMBER := 0;
	l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call
     (l_api_version_number
      , p_api_version_number
      , l_api_name
      , G_PKG_NAME
      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF (l_debug=1) THEN
      inv_log_util.trace('*** GET_PLANNING_SD_QUANTITY ***','CONSIGNED_VALIDATIONS_GRP',9);
      inv_log_util.trace('p_onhand_source=' || to_char(p_onhand_source)   ||
			 ', p_org_id='       || to_char(p_org_id)           ||
			 ', p_item_id='      || to_char(p_item_id)
			 , 'CONSIGNED_VALIDATIONS_GRP', 9);
   END IF;

   l_qty := INV_CONSIGNED_VALIDATIONS.get_planning_sd_quantity
     (
       P_ONHAND_SOURCE  =>   P_ONHAND_SOURCE
       , P_ORG_ID         =>   P_ORG_ID
       , P_ITEM_ID        =>   P_ITEM_ID);

   x_return_status := l_return_status;
   x_planning_qty := l_qty;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count => x_msg_count
	   , p_data  => x_msg_data
	   );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
	   , p_data   => x_msg_data
	   );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
	      , l_api_name
	      );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
	   , p_data   => x_msg_data
	   );

END GET_PLANNING_SD_QUANTITY;


END INV_CONSIGNED_VALIDATIONS_GRP;

/
