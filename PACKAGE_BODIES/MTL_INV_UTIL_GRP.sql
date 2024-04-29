--------------------------------------------------------
--  DDL for Package Body MTL_INV_UTIL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_INV_UTIL_GRP" AS
/* $Header: INVGIVUB.pls 120.2.12010000.4 2009/08/21 11:05:34 pbonthu ship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_INV_UTIL_GRP';

procedure mdebug(msg in varchar2)
is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
   --dbms_output.put_line(msg);
    inv_log_util.trace(msg , g_pkg_name || ' ',9);
end;


  --
  -- Gets the item cost for a specific item.
  PROCEDURE Get_Item_Cost(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2,
  p_commit IN VARCHAR2 ,
  p_validation_level IN NUMBER ,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_organization_id IN NUMBER ,
  p_inventory_item_id IN NUMBER ,
  p_locator_id IN NUMBER ,
  x_item_cost OUT NOCOPY NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Get_Item_Cost
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- selects the cost of the specific item
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_organization_id IN NUMBER (required)
    -- ID OF the organization
    --
    -- p_inventory_item_id IN NUMBER (required)
    -- ID OF the infentory item
    --
    -- p_locator_id IN NUMBER (optional - defaulted)
    -- default = NULL (IF dynamic locator)
    -- Locator ID
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --  x_item_cost  OUT NUMBER
    --  selected item cost
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_locator_Id    NUMBER := p_locator_id;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Get_Item_Cost';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Get_Item_Cost;
       --
/*
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
*/
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
       -- We doing this for dynamic locator.
       IF (L_locator_Id = -1) THEN   -- XXX ???
          L_locator_Id := NULL;
       END IF;

    /* Bug# 2942493
    ** Instead of duplicating the code, reusing the common utility to
    ** to get the item cost. That way its easier to maintain.
    */

    INV_UTILITIES.GET_ITEM_COST(
       v_org_id     => p_organization_id,
       v_item_id    => p_inventory_item_id,
       v_locator_id => L_locator_Id,
       v_item_cost  => x_item_cost);

    IF (x_item_cost = -999) THEN
      x_item_cost := 0;
    END IF;

	     IF (l_debug = 1) THEN
   	     mdebug('start4 '||to_char(x_item_cost));
	     END IF;


       -- END of API body
/*
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
*/
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Get_Item_Cost;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Get_Item_Cost;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Get_Item_Cost;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- calculate the system quantity of an given item
  PROCEDURE Calculate_Systemquantity(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 ,
  p_commit IN VARCHAR2  ,
  p_validation_level IN NUMBER ,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_organization_id IN NUMBER ,
  p_inventory_item_id IN NUMBER ,
  p_subinventory IN VARCHAR2 ,
  p_lot_number IN VARCHAR2 ,
  p_revision IN VARCHAR2 ,
  p_locator_id IN NUMBER ,
  p_cost_group_id IN NUMBER ,
  p_serial_number IN VARCHAR2 ,
  p_serial_number_control IN NUMBER ,
  p_serial_count_option IN NUMBER ,
  x_system_quantity OUT NOCOPY NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Calculate_Systemquantity
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_serial_number IN VARCHAR2 (required)
    --
    --  p_inventory_item_id IN NUMBER (required)
    --
    --  p_organization_id IN NUMBER (required)
    --
    --  p_subinventory IN VARCHAR2 (required)
    --
    --  p_LOT_NUMBER IN VARCHAR2 (required)
    --
    --  p_REVISION IN VARCHAR2 (required)
    --
    --  p_LOCATOR_ID IN NUMBER (required)
    --
    -- p_serial_number_control_code IN NUMBER (required)
    --
    -- p_serial_count_option
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
     --   x_system_quantity OUT NUMBER - qty specified in UOM of G_UOM_CODE
     -- which would be either count uom if count info was specified
     -- or primary uom if count info was entered into the primary uom
     -- quantity field of interface rec
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       CURSOR L_SysQty_Csr(itemid IN NUMBER, org IN NUMBER,
             subinv IN VARCHAR2, rev IN VARCHAR2, loc IN NUMBER,
             lot IN VARCHAR2, cost IN NUMBER) IS
          SELECT
          NVL(sum(primary_transaction_quantity), 0) SYSTEM_QUANTITY
          FROM MTL_ONHAND_QUANTITIES_DETAIL
          WHERE inventory_item_id = itemid
          AND organization_id = org
          AND subinventory_code = subinv
          AND NVL(lot_number, '@') = NVL(lot, '@')
          AND NVL(revision, '@') = NVL(rev, '@')
          AND NVL(locator_id, 99) = NVL(loc, 99)
          AND NVL(cost_group_id, -1) = NVL(cost, -1)
          AND NVL(containerized_flag, 2) = 2;
       --
       CURSOR L_SysQtySer_Csr(itemid IN NUMBER, org IN NUMBER,
             subinv IN VARCHAR2, rev IN VARCHAR2, loc IN NUMBER,
             lot IN VARCHAR2, ser IN VARCHAR2) IS
          SELECT
          NVL(sum(DECODE(msn.current_status, 3, 1, 0)), 0) SYSTEM_QUANTITY
          FROM mtl_serial_numbers msn
          WHERE msn.serial_number = NVL(ser, serial_number)
          AND msn.inventory_item_id = itemid
          AND msn.current_organization_id = org
          AND msn.current_subinventory_code = subinv
          AND NVL(msn.LOT_NUMBER, 'XX') = NVL(lot, 'XX')
          AND NVL(msn.REVISION, 'XXX') = NVL(rev, 'XXX')
          AND NVL(msn.CURRENT_LOCATOR_ID, -2) = NVL(loc, -2);
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Calculate_Systemquantity';
    BEGIN
IF (l_debug = 1) THEN
   MDEBUG( 'Begin of Calculate_Systemquantity1');
END IF;
       -- Standard start of API savepoint
       SAVEPOINT Calculate_Systemquantity;
       --
       -- for Testing marked by suresh
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       --
       IF (l_debug = 1) THEN
          MDEBUG( 'Begin of Calculate_Systemquantity2');
       END IF;
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;

       --
IF (l_debug = 1) THEN
   MDEBUG( 'Begin of Calculate_Systemquantity3');
END IF;
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_system_quantity := NULL;
       --
       -- API body
       --

IF (l_debug = 1) THEN
   MDEBUG( 'Begin of Calculate_Systemquantity4');
END IF;
       IF(p_serial_number_control IN (1, 6) OR
             p_serial_count_option = 1) THEN
          --
          FOR c_rec IN L_SysQty_Csr(p_inventory_item_id,
                p_organization_id, p_subinventory,
                p_revision, p_locator_id,
                p_lot_number, p_cost_group_id) LOOP
             --
             x_system_quantity := c_rec.system_quantity;
IF (l_debug = 1) THEN
   MDEBUG( 'Calc.SystemQty : Inside loop-1 ');
END IF;
             --
          END LOOP;
IF (l_debug = 1) THEN
   MDEBUG( 'Calc.SystemQty =: '||to_char(x_system_quantity));
END IF;
          -- serial control
       ELSIF
          (p_serial_number_control IN(2, 5) AND
             p_serial_count_option > 1) THEN
          FOR c_rec IN L_SysQtySer_Csr(p_inventory_item_id,
                p_organization_id, p_subinventory,
                p_revision, p_locator_id,
                p_lot_number, p_serial_number) LOOP
             --
             x_system_quantity := c_rec.system_quantity;
IF (l_debug = 1) THEN
   MDEBUG( 'Calc.SystemQty : Inside loop-2 ');
END IF;
             --
          END LOOP;
IF (l_debug = 1) THEN
   MDEBUG( 'Calc.SystemQty 2=: '||to_char(x_system_quantity));
END IF;
       END IF;
       IF MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE <> MTL_CCEOI_VAR_PVT.G_UOM_CODE
       THEN
             x_system_quantity := nvl( INV_CONVERT.inv_um_convert(
             item_id =>p_inventory_item_id
             , precision => 5
             , from_quantity => x_system_quantity
             , from_unit => MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE
             , to_unit => MTL_CCEOI_VAR_PVT.G_UOM_CODE
             , from_name => NULL
             , to_name => NULL
             ),0);
IF (l_debug = 1) THEN
   MDEBUG( 'Calc.convert System Qty =: '||to_char(x_system_quantity));
END IF;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Calculate_Systemquantity;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Calc.sys : Exception Error ' || sqlerrm);
END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Calculate_Systemquantity;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Calc.sys : Unexp Exception Error: '|| sqlerrm);
END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Calc.sys : Others Exception Error ' || sqlerrm);
END IF;
       ROLLBACK TO Calculate_Systemquantity;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;


  -- BEGIN INVCONV
  -- Overloaded procedure to return secondary quantity
  PROCEDURE calculate_systemquantity (
     p_api_version             IN              NUMBER,
     p_init_msg_list           IN              VARCHAR2,
     p_commit                  IN              VARCHAR2,
     p_validation_level        IN              NUMBER,
     x_return_status           OUT NOCOPY      VARCHAR2,
     x_msg_count               OUT NOCOPY      NUMBER,
     x_msg_data                OUT NOCOPY      VARCHAR2,
     p_organization_id         IN              NUMBER,
     p_inventory_item_id       IN              NUMBER,
     p_subinventory            IN              VARCHAR2,
     p_lot_number              IN              VARCHAR2,
     p_revision                IN              VARCHAR2,
     p_locator_id              IN              NUMBER,
     p_cost_group_id           IN              NUMBER,
     p_serial_number           IN              VARCHAR2,
     p_serial_number_control   IN              NUMBER,
     p_serial_count_option     IN              NUMBER,
     x_system_quantity         OUT NOCOPY      NUMBER,
     x_sec_system_quantity     OUT NOCOPY      NUMBER
  )
  IS
     l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
     -- Start OF comments
     -- API name  : Calculate_Systemquantity
     -- TYPE      : Private
     -- Pre-reqs  : None
     -- FUNCTION  :
     -- Parameters:
     --     IN    :
     --  p_api_version      IN  NUMBER (required)
     --  API Version of this procedure
     --
     --  p_init_msg_list   IN  VARCHAR2 (optional)
     --    DEFAULT = FND_API.G_FALSE,
     --
     -- p_commit           IN  VARCHAR2 (optional)
     --     DEFAULT = FND_API.G_FALSE
     --
     --  p_validation_level IN  NUMBER (optional)
     --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
     --
     --  p_serial_number IN VARCHAR2 (required)
     --
     --  p_inventory_item_id IN NUMBER (required)
     --
     --  p_organization_id IN NUMBER (required)
     --
     --  p_subinventory IN VARCHAR2 (required)
     --
     --  p_LOT_NUMBER IN VARCHAR2 (required)
     --
     --  p_REVISION IN VARCHAR2 (required)
     --
     --  p_LOCATOR_ID IN NUMBER (required)
     --
     -- p_serial_number_control_code IN NUMBER (required)
     --
     -- p_serial_count_option
     --
     --     OUT   :
     --  X_return_status    OUT NUMBER
     --  Result of all the operations
     --
     --   x_msg_count        OUT NUMBER,
     --
     --   x_msg_data         OUT VARCHAR2,
     --
     -- x_system_quantity OUT NUMBER - qty specified in UOM of G_UOM_CODE
     -- which would be either count uom if count info was specified
     -- or primary uom if count info was entered into the primary uom
     -- quantity field of interface rec
     --
     -- x_sec_system_quantity OUT NUMBER - qty specified in UOM of G_UOM_CODE
     -- which would be either count uom if count info was specified
     -- or primary uom if count info was entered into the primary uom
     -- quantity field of interface rec
     --
     -- Version: Current Version 0.9
     --              Changed : Nothing
     --          No Previous Version 0.0
     --          Initial version 0.9
     -- Notes  : Note text
     -- END OF comments
     DECLARE
        --
        CURSOR l_sysqty_csr (
  	 itemid   IN   NUMBER,
  	 org      IN   NUMBER,
  	 subinv   IN   VARCHAR2,
  	 rev      IN   VARCHAR2,
  	 loc      IN   NUMBER,
  	 lot      IN   VARCHAR2,
  	 COST     IN   NUMBER
        )
        IS
  	 SELECT NVL (SUM (primary_transaction_quantity), 0) system_quantity,
  	        NVL (SUM (secondary_transaction_quantity), 0) secondary_system_quantity
  	   FROM mtl_onhand_quantities_detail
  	  WHERE inventory_item_id = itemid
  	    AND organization_id = org
  	    AND subinventory_code = subinv
  	    AND NVL (lot_number, '@') = NVL (lot, '@')
  	    AND NVL (revision, '@') = NVL (rev, '@')
  	    AND NVL (locator_id, 99) = NVL (loc, 99)
  	    AND NVL (cost_group_id, -1) = NVL (COST, -1)
  	    AND NVL (containerized_flag, 2) = 2;

        --
        CURSOR l_sysqtyser_csr (
  	 itemid   IN   NUMBER,
  	 org      IN   NUMBER,
  	 subinv   IN   VARCHAR2,
  	 rev      IN   VARCHAR2,
  	 loc      IN   NUMBER,
  	 lot      IN   VARCHAR2,
  	 ser      IN   VARCHAR2
        )
        IS
  	 SELECT NVL (SUM (DECODE (msn.current_status, 3, 1, 0)),
  		     0
  		    ) system_quantity
  	   FROM mtl_serial_numbers msn
  	  WHERE msn.serial_number = NVL (ser, serial_number)
  	    AND msn.inventory_item_id = itemid
  	    AND msn.current_organization_id = org
  	    AND msn.current_subinventory_code = subinv
  	    AND NVL (msn.lot_number, 'XX') = NVL (lot, 'XX')
  	    AND NVL (msn.revision, 'XXX') = NVL (rev, 'XXX')
  	    AND NVL (msn.current_locator_id, -2) = NVL (loc, -2);

        --
        l_api_version   CONSTANT NUMBER        := 0.9;
        l_api_name      CONSTANT VARCHAR2 (30) := 'Calculate_Systemquantity2';
     BEGIN
        IF (l_debug = 1)
        THEN
  	 mdebug ('Begin of Calculate_Systemquantity1');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT calculate_systemquantity;

        --
        -- for Testing marked by suresh
        -- Standard Call to check for call compatibility
        IF NOT fnd_api.compatible_api_call (l_api_version,
  					  p_api_version,
  					  l_api_name,
  					  g_pkg_name
  					 )
        THEN
  	 RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --
        IF (l_debug = 1)
        THEN
  	 mdebug ('Begin of Calculate_Systemquantity2');
        END IF;

        -- Initialize message list if p_init_msg_list is set to true
        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
  	 fnd_msg_pub.initialize;
        END IF;

        --
        IF (l_debug = 1)
        THEN
  	 mdebug ('Begin of Calculate_Systemquantity3');
        END IF;

        -- Initialisize API return status to access
        x_return_status := fnd_api.g_ret_sts_success;
        x_system_quantity := NULL;
	x_sec_system_quantity := NULL;

        --
        -- API body
        --
        IF (l_debug = 1)
        THEN
  	 mdebug ('Begin of Calculate_Systemquantity4');
        END IF;

        IF (p_serial_number_control IN (1, 6) OR p_serial_count_option = 1)
        THEN
  	 --
  	 FOR c_rec IN l_sysqty_csr (p_inventory_item_id,
  				    p_organization_id,
  				    p_subinventory,
  				    p_revision,
  				    p_locator_id,
  				    p_lot_number,
  				    p_cost_group_id
  				   )
  	 LOOP
  	    --
  	    x_system_quantity := c_rec.system_quantity;
	    x_sec_system_quantity := c_rec.secondary_system_quantity;

  	    IF (l_debug = 1)
  	    THEN
  	       mdebug ('Calc.SystemQty : Inside loop-1 ');
  	    END IF;
  	 --
  	 END LOOP;

  	 IF (l_debug = 1)
  	 THEN
  	    mdebug ('Calc.SystemQty =: ' || TO_CHAR (x_system_quantity));
  	    mdebug ('Calc. Secondary SystemQty =: ' || TO_CHAR (x_sec_system_quantity));
  	 END IF;
        -- serial control
        ELSIF (p_serial_number_control IN (2, 5) AND p_serial_count_option > 1)
        THEN
  	 FOR c_rec IN l_sysqtyser_csr (p_inventory_item_id,
  				       p_organization_id,
  				       p_subinventory,
  				       p_revision,
  				       p_locator_id,
  				       p_lot_number,
  				       p_serial_number
  				      )
  	 LOOP
  	    --
  	    x_system_quantity := c_rec.system_quantity;
	    x_sec_system_quantity := NULL;

  	    IF (l_debug = 1)
  	    THEN
  	       mdebug ('Calc.SystemQty : Inside loop-2 ');
  	    END IF;
  	 --
  	 END LOOP;

  	 IF (l_debug = 1)
  	 THEN
  	    mdebug ('Calc.SystemQty 2=: ' || TO_CHAR (x_system_quantity));
  	 END IF;
        END IF;

        IF mtl_cceoi_var_pvt.g_primary_uom_code <> mtl_cceoi_var_pvt.g_uom_code
        THEN
  	 x_system_quantity :=
  	    NVL
  	       (inv_convert.inv_um_convert
  			   (item_id            => p_inventory_item_id,
  			    PRECISION          => 5,
  			    from_quantity      => x_system_quantity,
  			    from_unit          => mtl_cceoi_var_pvt.g_primary_uom_code,
  			    to_unit            => mtl_cceoi_var_pvt.g_uom_code,
  			    from_name          => NULL,
  			    to_name            => NULL
  			   ),
  		0
  	       );

  	 IF (l_debug = 1)
  	 THEN
  	    mdebug ('Calc.convert System Qty =: ' || TO_CHAR (x_system_quantity));
  	 END IF;
        END IF;

        --
        -- END of API body
        -- Standard check of p_commit
        IF fnd_api.to_boolean (p_commit)
        THEN
  	 COMMIT;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get (p_count      => x_msg_count,
  				 p_data       => x_msg_data);
     EXCEPTION
        WHEN fnd_api.g_exc_error
        THEN
  	 --
  	 ROLLBACK TO calculate_systemquantity;

  	 --
  	 IF (l_debug = 1)
  	 THEN
  	    mdebug ('Calc.sys : Exception Error ' || SQLERRM);
  	 END IF;

  	 x_return_status := fnd_api.g_ret_sts_error;
  	 --
  	 fnd_msg_pub.count_and_get (p_count      => x_msg_count,
  				    p_data       => x_msg_data
  				   );
        --
        WHEN fnd_api.g_exc_unexpected_error
        THEN
  	 --
  	 ROLLBACK TO calculate_systemquantity;

  	 --
  	 IF (l_debug = 1)
  	 THEN
  	    mdebug ('Calc.sys : Unexp Exception Error: ' || SQLERRM);
  	 END IF;

  	 x_return_status := fnd_api.g_ret_sts_unexp_error;
  	 --
  	 fnd_msg_pub.count_and_get (p_count      => x_msg_count,
  				    p_data       => x_msg_data
  				   );
        --
        WHEN OTHERS
        THEN
  	 --
  	 IF (l_debug = 1)
  	 THEN
  	    mdebug ('Calc.sys : Others Exception Error ' || SQLERRM);
  	 END IF;

  	 ROLLBACK TO calculate_systemquantity;
  	 --
  	 x_return_status := fnd_api.g_ret_sts_unexp_error;

  	 --
  	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
  	 THEN
  	    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
  	 END IF;

  	 --
  	 fnd_msg_pub.count_and_get (p_count      => x_msg_count,
  				    p_data       => x_msg_data
  				   );
     END;
  END;
  -- END INVCONV

/*============================================================================+
|  Copyright (c) 1998 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| PROGRAM NAME: MTL_INVCCEOI_SERIAL.pls
| PURPOSE:      Description
|
| DESIGN:
|
| CALLING FORMAT:
|    MTL_INV_SERIAL_CHK user/pass arg1 ...
|
| CALLED BY:    Oracle Manufacturing Form
|
| HISTORY
| 22-May-98     Suresh      Created
+============================================================================*/
/*-------------------------------------------------------------------------+
|  Every serial number is given a current_status which indicates where the
|  unit is and for what transactions it is available.  Supported statuses
|  are:
|      o 1  The unit is defined but has not been received into or issued out
|           of stores.
|      o 3  The unit has been received into stores.
|      o 4  The unit has been issued out of stores.
|      o 5  The unit has been issued out of stores and now resides in
|           intransit.
|  In addition, there are several types of serial control which determine
|  under what conditions serialized units are required.  Supported serial
|  controls are:
|      o 1  No serial number control.
|      o 2  Predefined S/N - full control.
|      o 3  Predefined S/N - inventory receipt.
|      o 5  Dynamic entry at inventory receipt.
|      o 6  Dynamic entry at sales order issue.
|
| Dynamically create a new serial number record.  We must
| follow the serial number uniqueness criteria specified
| in the inventory parameters of this organization.  The
| possible criteria are:
|
|  o 1  Unique serial numbers within inventory items.
|       No duplicate serial numbers for any particular
|       inventory item across all organizations.
|
|       A serial number may be assigned to at most one
|       unit of each item across all organizations. This
|       translates into at most one record in
|       MTL_SERIAL_NUMBERS for each combination of
|       SERIAL_NUMBER and INVENTORY_ITEM_ID.
|
|  o 2  Unique serial numbers within organization.
|       No duplicate serial numbers within any particular
|       organization.
|
|       A serial number may be assigned to at most one unit
|       of one item in each organization, with the caveat
|       that the same serial number may not be assigned to
|       the same item in two different organizations.  This
|       translates into at most one record in
|       MTL_SERIAL_NUMBERS for each combination of
|       SERIAL_NUMBER and INVENTORY_ITEM_ID with the
|       overriding condition that there be at most one
|       record for any given combination of SERIAL_NUMBER
|       and ORGANIZATION_ID.
|
|  o 3  Unique serial numbers across organizations.
|       No duplicate serial numbers in the entire system.
|
|       A serial number may be assigned to at most one unit
|       of one item across all organizations.  This
|       translates into at most one record in
|       MTL_SERIAL_NUMBERS for each value of SERIAL_NUMBER.
+--------------------------------------------------------------------------*/
FUNCTION  CHECK_SERIAL_NUMBER_LOCATION
(
  P_SERIAL_NUMBER        IN   VARCHAR2,
  P_ITEM_ID              IN   NUMBER,
  P_ORGANIZATION_ID      IN   NUMBER,
  P_SERIAL_NUMBER_TYPE   IN   NUMBER,
  P_SERIAL_CONTROL       IN   NUMBER,
  P_REVISION             IN   VARCHAR2,
  P_LOT_NUMBER           IN   VARCHAR2,
  P_SUBINVENTORY         IN   VARCHAR2,
  P_LOCATOR_ID           IN   NUMBER,
  P_ISSUE_RECEIPT        IN   VARCHAR2 -- R -receipt I - issue

) RETURN BOOLEAN IS
  -- Declare Local variables
  L_current_status          NUMBER(38);
  L_current_revision        VARCHAR2(4);
  L_current_lot_number      VARCHAR2(80); -- INVCONV
  L_current_subinventory    VARCHAR2(10);
  L_current_locator_id      NUMBER(38) ;
  L_current_organization_id NUMBER(38) ;
  L_nothing                 VARCHAR2(30);
  L_user_id                 NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF P_SERIAL_CONTROL NOT IN (2,5) THEN
     RETURN(FALSE);
  END IF;
  /*-------------------------------------------+
  |  Check for existence of the serial number
  +-------------------------------------------*/
  BEGIN
IF (l_debug = 1) THEN
   MDEBUG( 'Begin of CheckSerl');
END IF;
     -- Validate Serial Number for exist
     SELECT  decode(current_status,6,1,current_status),
             revision,
             lot_number,
             current_subinventory_code,
             current_locator_id,
             current_organization_id
     INTO    L_current_status,
             L_current_revision,
             L_current_lot_number,
             L_current_subinventory,
             L_current_locator_id,
             L_current_organization_id
     FROM    MTL_SERIAL_NUMBERS
     WHERE   inventory_item_id = P_Item_id
     AND     serial_number = P_serial_number;
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - found');
END IF;
     IF (P_ISSUE_RECEIPT = 'I' and L_current_status = 3
        and P_ORGANIZATION_ID = L_current_organization_id
        and P_REVISION = L_current_revision
        and P_LOCATOR_ID = L_current_locator_id
        and P_LOT_NUMBER = L_current_lot_number
        and P_SUBINVENTORY = L_current_subinventory )
        OR
       (P_ISSUE_RECEIPT IN ('I','R')  and L_current_status = 1
           and P_ORGANIZATION_ID = L_current_organization_id)
        OR
       (P_ISSUE_RECEIPT = 'R' and L_current_status = 4)
     THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - conditin satisfied');
END IF;
        RETURN(TRUE);
     ELSE
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - conditin not satisfied');
END IF;
        RETURN(FALSE);
     END IF;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - no-data-found-1');
END IF;
       IF P_SERIAL_CONTROL = 5 THEN   -- Dynamic Serial Control Check
          -- UniqueCheck Routine
          BEGIN
            IF P_SERIAL_NUMBER_TYPE = 2 THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Serl No - 2');
END IF;
               BEGIN
                 SELECT 'x'
                 INTO    L_nothing
                 FROM    MTL_SERIAL_NUMBERS
                 WHERE   SERIAL_NUMBER = P_serial_number
                 AND     CURRENT_ORGANIZATION_ID + 0 = P_organization_id;
                 IF L_nothing IS NOT NULL then
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - data-found-2');
END IF;
                    RETURN(FALSE);
                 END IF;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    BEGIN
                       SELECT  'x'
                       INTO L_nothing
                       FROM MTL_SERIAL_NUMBERS S,
                            MTL_PARAMETERS P
                       WHERE S.CURRENT_ORGANIZATION_ID = P.ORGANIZATION_ID
                       AND   S.SERIAL_NUMBER = P_serial_number
                       AND   P.SERIAL_NUMBER_TYPE = 3;
                       IF L_nothing IS NOT NULL then
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - data-found-3');
END IF;
                          RETURN(FALSE);
                       END IF;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          -- Dynamic Create Serial No.
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - data-not found-Dynamic creation');
END IF;
        		  L_user_id := FND_GLOBAL.USER_ID ;
       			   begin
           		   INSERT INTO MTL_SERIAL_NUMBERS
           	  	     (INVENTORY_ITEM_ID,
             		      SERIAL_NUMBER,
           		      LAST_UPDATE_DATE,
             		      LAST_UPDATED_BY,
     		              INITIALIZATION_DATE,
              		      CREATION_DATE,
                	      CREATED_BY,
                              LAST_UPDATE_LOGIN,
                              CURRENT_STATUS,
                              CURRENT_ORGANIZATION_ID)
                           VALUES
                              (P_item_id, P_SERIAL_NUMBER, sysdate,
                              L_user_id, sysdate, sysdate,
                              L_user_id, -1, 6,P_organization_id);

                           exception
                              when others then null;
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - data-not found-Dynamic creation - exception');
END IF;
                           end;
                          RETURN(TRUE);
                       WHEN OTHERS THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - data-not found-exception');
END IF;
                          RETURN(FALSE);
                    END;
                 WHEN OTHERS THEN
                    RETURN(FALSE);
               END;
            ELSIF P_SERIAL_NUMBER_TYPE = 3 THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Serl No - 3');
END IF;
               BEGIN
                  SELECT 'x'
                  INTO  L_nothing
                  FROM  MTL_SERIAL_NUMBERS
                  WHERE SERIAL_NUMBER = P_serial_number;
                  IF L_nothing IS NOT NULL THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Serl No found - 1');
END IF;
                     RETURN(FALSE);
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Serl No inserting - 1');
END IF;
                     L_user_id := FND_GLOBAL.USER_ID ;
                     begin
                        INSERT INTO MTL_SERIAL_NUMBERS
                        (INVENTORY_ITEM_ID,
                        SERIAL_NUMBER,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        INITIALIZATION_DATE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        CURRENT_STATUS,
                        CURRENT_ORGANIZATION_ID)
                        VALUES
                        (P_item_id, P_SERIAL_NUMBER, sysdate,
                         L_user_id, sysdate, sysdate,
                         L_user_id, -1, 6, P_ORGANIZATION_ID);

                      exception
                         when others then null;
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Serl No inserting Except- 1');
END IF;
                     end;
                     RETURN(TRUE);
                  WHEN OTHERS THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Serl No inserting Except- 2');
END IF;
                     RETURN(FALSE);
               END;
            ELSIF P_SERIAL_NUMBER_TYPE = 1 THEN
                    BEGIN
                       SELECT  'x'
                       INTO L_nothing
                       FROM MTL_SERIAL_NUMBERS S,
                            MTL_PARAMETERS  P
                       WHERE S.INVENTORY_ITEM_ID = P_item_id
                       AND   S.CURRENT_ORGANIZATION_ID = P.ORGANIZATION_ID
                       AND   S.SERIAL_NUMBER = P_serial_number
                       AND   P.SERIAL_NUMBER_TYPE = 1;
                       IF L_nothing IS NOT NULL then
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - data-found-4');
END IF;
                          RETURN(FALSE);
                       END IF;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                     L_user_id := FND_GLOBAL.USER_ID ;
                     begin
                        INSERT INTO MTL_SERIAL_NUMBERS
                        (INVENTORY_ITEM_ID,
                        SERIAL_NUMBER,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        INITIALIZATION_DATE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        CURRENT_STATUS,
                        CURRENT_ORGANIZATION_ID)
                        VALUES
                        (P_item_id, P_SERIAL_NUMBER, sysdate,
                         L_user_id, sysdate, sysdate,
                         L_user_id, -1, 6, P_ORGANIZATION_ID);

                      exception
                         when others then null;
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Serl No inserting Except- 4');
END IF;
                     end;
                  WHEN OTHERS THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Serl No inserting Except- 4');
END IF;
                     RETURN(FALSE);
               END;
            END IF;
          END ;
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Last');
END IF;
          RETURN(TRUE);
       ELSE
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Last - 2');
END IF;
          RETURN(FALSE);
       END IF;
     WHEN OTHERS THEN
IF (l_debug = 1) THEN
   MDEBUG( 'CheckSerl - Last - 3');
END IF;
          RETURN(FALSE);
  END;
END;


PROCEDURE Get_LPN_Item_SysQty
(
	p_api_version		IN  	NUMBER
, 	p_init_msg_lst		IN  	VARCHAR2
,	p_commit		IN	VARCHAR2
, 	x_return_status		OUT 	NOCOPY VARCHAR2
, 	x_msg_count		OUT 	NOCOPY NUMBER
, 	x_msg_data		OUT 	NOCOPY VARCHAR2
,  	p_organization_id    	IN    	NUMBER
,	p_lpn_id		IN	NUMBER
,	p_inventory_item_id	IN	NUMBER
,	p_lot_number		IN 	VARCHAR2
,	p_revision		IN	VARCHAR2
,	p_serial_number		IN	VARCHAR2
,	p_cost_group_id		IN	NUMBER
,	x_lpn_systemqty 	OUT	NOCOPY NUMBER
)
IS
  l_subinventory_code	VARCHAR2(25);
  l_locator_id		      NUMBER;
  l_result		         NUMBER;
  l_org 		            INV_Validate.ORG;
  l_lpn                 WMS_CONTAINER_PUB.LPN;
  l_content_item	      INV_Validate.ITEM;
  l_lot             	   INV_Validate.LOT;
  l_loaded_sys_qty      NUMBER; --bug 2640378

  e_Invalid_Inputs	EXCEPTION;

  L_api_version CONSTANT NUMBER := 0.9;
  L_api_name CONSTANT VARCHAR2(30) := 'Get_LPN_Item_SysQty';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Get_LPN_Item_SysQty;

  -- Standard Call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version
     , p_api_version
     , l_api_name
     , G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialisize API return status to access
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Validate Inputs
   -- Validate Organization ID
   IF (p_organization_id IS NOT NULL) THEN
     l_org.organization_id := p_organization_id;
     l_result := INV_Validate.Organization(l_org);
     IF (l_result = INV_Validate.F) THEN
       IF (l_debug = 1) THEN
          mdebug('invalid org id');
       END IF;
       RAISE e_Invalid_Inputs;
     END IF;
   END IF;

   -- Validate LPN
   IF p_lpn_id IS NOT NULL THEN
     l_lpn.lpn_id := p_lpn_id;
     l_lpn.license_plate_number := NULL;
     l_result := WMS_CONTAINER_PUB.Validate_LPN(l_lpn);
     IF (l_result = INV_Validate.F) THEN
       IF (l_debug = 1) THEN
          mdebug('invalid lpn id');
       END IF;
       FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
       FND_MSG_PUB.ADD;
       RAISE e_Invalid_Inputs;
     END IF;
   END IF;

   -- Validate Inventory Item ID
   IF (p_inventory_item_id IS NOT NULL) THEN
      l_content_item.inventory_item_id := p_inventory_item_id;
      l_result := INV_Validate.inventory_item(l_content_item, l_org);
      IF (l_result = INV_Validate.F) THEN
         IF (l_debug = 1) THEN
            mdebug('invalid inventory item id');
         END IF;
	 RAISE e_Invalid_Inputs;
      END IF;
   END IF;

/*
   -- Validate Lot Number
   IF (p_container_item_id IS NOT NULL) THEN
      IF (l_container_item.lot_control_code = 2) THEN
	 IF (p_lot_number IS NOT NULL) THEN
	    l_lot.lot_number := p_lot_number;
	    l_result := INV_Validate.Lot_Number(l_lot, l_org, l_container_item,
						l_sub, l_locator, p_revision);
	    IF (l_result = INV_Validate.F) THEN
	       IF (l_debug = 1) THEN
   	       mdebug('invalid lot number');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LOT');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF;
      END IF;
   END IF;

   -- Validate Revision Number
   IF (p_container_item_id IS NOT NULL) THEN
      IF (l_container_item.revision_qty_control_code = 2) THEN
	 IF (p_revision IS NOT NULL) THEN
	    l_result := INV_Validate.Revision(p_revision, l_org, l_container_item);
	    IF (l_result = INV_Validate.F) THEN
	       IF (l_debug = 1) THEN
   	       mdebug('invalid revision number');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_REVISION');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF;
      END IF;
   END IF;

   -- Validate Serial Number
   IF (p_serial_number IS NOT NULL) THEN
	   l_serial.serial_number := p_serial_number;
	   l_result := INV_Validate.validate_serial(l_serial, l_org, l_container_item,
						    								  l_sub, l_lot, l_locator, p_revision);
	   IF (l_result = INV_Validate.F) THEN
	      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SERIAL');
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	END IF;
*/

     SELECT subinventory_code, locator_id
     INTO   l_subinventory_code, l_locator_id
     FROM   WMS_LICENSE_PLATE_NUMBERS
     WHERE  organization_id = p_organization_id
     AND    lpn_id = p_lpn_id;

   -- Find quantity of item within container.
   IF (p_serial_number IS NULL) THEN
    BEGIN
	   SELECT nvl(sum(quantity),0)  --BUG3026540
	   INTO   x_lpn_systemqty
	   FROM   WMS_LPN_CONTENTS
	   WHERE  parent_lpn_id = p_lpn_id
	   AND    organization_id = p_organization_id
	   AND    inventory_item_id = p_inventory_item_id
	   AND    NVL(lot_number, '@')  = NVL(p_lot_number, '@')
	   AND    NVL(revision, '@') = NVL(p_revision, '@')
	   AND    NVL(serial_number, '@') = NVL(p_serial_number, '@');
	  -- AND    NVL(cost_group_id, -1) = NVL(p_cost_group_id, -1); Bug#8323599

      --bug 2640378  start
      select nvl(sum(quantity),0)
      into   l_loaded_sys_qty
      from   wms_loaded_quantities_v
      where  nvl(content_lpn_id,nvl(lpn_id,-1)) = p_lpn_id
      and    inventory_item_id = p_inventory_item_id
      and    NVL(lot_number, '@')  = NVL(p_lot_number, '@')
      and    NVL(revision, '@') = NVL(p_revision, '@');
     -- and    NVL(cost_group_id, -1) = NVL(p_cost_group_id, -1);--bug3681566

      IF (l_debug = 1) THEN
         mdebug('LPN ID ' || p_lpn_id ||' loaded quantity ' || l_loaded_sys_qty);
      END IF;
      IF l_loaded_sys_qty > 0 THEN
         x_lpn_systemqty := x_lpn_systemqty - l_loaded_sys_qty;
      END IF; -- bug 2640378
   EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	    x_lpn_systemqty := 0;
   END;

 ELSE   -- serial number is not null
      IF (l_debug = 1) THEN
         mdebug('serial being counted ' || p_serial_number);
      END IF;
      SELECT COUNT(*)
	   INTO x_lpn_systemqty
	   FROM mtl_serial_numbers
	   WHERE lpn_id = p_lpn_id
	   AND inventory_item_id = p_inventory_item_id
	   AND current_organization_id = p_organization_id
	   AND serial_number = p_serial_number
	   AND NVL(lot_number, '@')  = NVL(p_lot_number, '@')
	   AND NVL(revision, '@') = NVL(p_revision, '@')
	   AND NVL(cost_group_id, -1) = NVL(p_cost_group_id, -1)
      AND INV_CYC_LOVS.is_serial_loaded(p_organization_id,p_inventory_item_id,p_serial_number,p_lpn_id) = 2;
  END IF;

  IF (x_lpn_systemqty IS NULL) THEN
      x_lpn_systemqty := 0;
  END IF;

EXCEPTION
   WHEN e_Invalid_Inputs THEN
      ROLLBACK TO Get_LPN_Item_SysQty;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
      IF (l_debug = 1) THEN
         mdebug('Invalid Inputs');
      END IF;

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mdebug('SQLERRM : '|| SQLERRM);
      END IF;
      x_lpn_systemqty := 0;

END Get_LPN_Item_SysQty;

-- BEGIN INVCONV
-- Overloaded procedure to return secondary quantity
PROCEDURE Get_LPN_Item_SysQty (
   p_api_version              IN         NUMBER
 , p_init_msg_lst             IN         VARCHAR2
 , p_commit                   IN         VARCHAR2
 , x_return_status            OUT NOCOPY VARCHAR2
 , x_msg_count                OUT NOCOPY NUMBER
 , x_msg_data                 OUT NOCOPY VARCHAR2
 , p_organization_id          IN         NUMBER
 , p_lpn_id                   IN         NUMBER
 , p_inventory_item_id        IN         NUMBER
 , p_lot_number               IN         VARCHAR2
 , p_revision                 IN         VARCHAR2
 , p_serial_number            IN         VARCHAR2
 , p_cost_group_id            IN         NUMBER
 , x_lpn_systemqty            OUT NOCOPY NUMBER
 , x_lpn_sec_systemqty        OUT NOCOPY NUMBER
) IS
   l_subinventory_code      VARCHAR2 (25);
   l_locator_id             NUMBER;
   l_result                 NUMBER;
   l_org                    inv_validate.org;
   l_lpn                    wms_container_pub.lpn;
   l_content_item           inv_validate.item;
   l_lot                    inv_validate.lot;
   l_loaded_sys_qty         NUMBER;
   l_loaded_sec_sys_qty     NUMBER;
   e_invalid_inputs         EXCEPTION;
   l_api_version   CONSTANT NUMBER                := 0.9;
   l_api_name      CONSTANT VARCHAR2 (30)         := 'Get_LPN_Item_SysQty2';
   l_debug                  NUMBER                := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT get_lpn_item_sysqty;

   -- Standard Call to check for call compatibility
   IF NOT fnd_api.compatible_api_call (l_api_version
                                     , p_api_version
                                     , l_api_name
                                     , g_pkg_name
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialisize API return status to access
   x_return_status := fnd_api.g_ret_sts_success;

   -- Validate Inputs
   -- Validate Organization ID
   IF (p_organization_id IS NOT NULL) THEN
      l_org.organization_id := p_organization_id;
      l_result := inv_validate.ORGANIZATION (l_org);

      IF (l_result = inv_validate.f) THEN
         IF (l_debug = 1) THEN
            mdebug ('invalid org id');
         END IF;

         RAISE e_invalid_inputs;
      END IF;
   END IF;

   -- Validate LPN
   IF p_lpn_id IS NOT NULL THEN
      l_lpn.lpn_id := p_lpn_id;
      l_lpn.license_plate_number := NULL;
      l_result := wms_container_pub.validate_lpn (l_lpn);

      IF (l_result = inv_validate.f) THEN
         IF (l_debug = 1) THEN
            mdebug ('invalid lpn id');
         END IF;

         fnd_message.set_name ('WMS', 'WMS_CONT_INVALID_LPN');
         fnd_msg_pub.ADD;
         RAISE e_invalid_inputs;
      END IF;
   END IF;

   -- Validate Inventory Item ID
   IF (p_inventory_item_id IS NOT NULL) THEN
      l_content_item.inventory_item_id := p_inventory_item_id;
      l_result := inv_validate.inventory_item (l_content_item, l_org);

      IF (l_result = inv_validate.f) THEN
         IF (l_debug = 1) THEN
            mdebug ('invalid inventory item id');
         END IF;

         RAISE e_invalid_inputs;
      END IF;
   END IF;

   SELECT subinventory_code
        , locator_id
     INTO l_subinventory_code
        , l_locator_id
     FROM wms_license_plate_numbers
    WHERE organization_id = p_organization_id
      AND lpn_id = p_lpn_id;

   -- Find quantity of item within container.
   IF (p_serial_number IS NULL) THEN
      BEGIN
          --For R12 we need to consider primary_quantity instead of quantity from WLC (bug 6833992)
         SELECT NVL (SUM (primary_quantity), 0)
              , NVL (SUM (secondary_quantity), 0)
           INTO x_lpn_systemqty
              , x_lpn_sec_systemqty
           FROM wms_lpn_contents
          WHERE parent_lpn_id = p_lpn_id
            AND organization_id = p_organization_id
            AND inventory_item_id = p_inventory_item_id
            AND NVL (lot_number, '@') = NVL (p_lot_number, '@')
            AND NVL (revision, '@') = NVL (p_revision, '@')
            AND NVL (serial_number, '@') = NVL (p_serial_number, '@')
            AND NVL (cost_group_id, -1) = NVL (p_cost_group_id, -1);

         SELECT NVL (SUM (quantity), 0)
              , NVL (SUM (secondary_quantity), 0)
           INTO l_loaded_sys_qty
              , l_loaded_sec_sys_qty
           FROM wms_loaded_quantities_v
          WHERE NVL (content_lpn_id, NVL (lpn_id, -1) ) = p_lpn_id
            AND inventory_item_id = p_inventory_item_id
            AND NVL (lot_number, '@') = NVL (p_lot_number, '@')
            AND NVL (revision, '@') = NVL (p_revision, '@');

         IF (l_debug = 1) THEN
            mdebug ('LPN ID ' || p_lpn_id || ' loaded quantity ' || l_loaded_sys_qty);
         END IF;

         IF l_loaded_sys_qty > 0 THEN
            x_lpn_systemqty := x_lpn_systemqty - l_loaded_sys_qty;
         END IF;

         IF l_loaded_sec_sys_qty > 0 THEN
            x_lpn_sec_systemqty := x_lpn_sec_systemqty - l_loaded_sec_sys_qty;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_lpn_systemqty := 0;
            x_lpn_sec_systemqty := 0;
      END;
   ELSE   -- serial number is not null
      IF (l_debug = 1) THEN
         mdebug ('serial being counted ' || p_serial_number);
      END IF;

      SELECT COUNT (*)
        INTO x_lpn_systemqty
        FROM mtl_serial_numbers
       WHERE lpn_id = p_lpn_id
         AND inventory_item_id = p_inventory_item_id
         AND current_organization_id = p_organization_id
         AND serial_number = p_serial_number
         AND NVL (lot_number, '@') = NVL (p_lot_number, '@')
         AND NVL (revision, '@') = NVL (p_revision, '@')
         AND NVL (cost_group_id, -1) = NVL (p_cost_group_id, -1)
         AND inv_cyc_lovs.is_serial_loaded (p_organization_id
                                          , p_inventory_item_id
                                          , p_serial_number
                                          , p_lpn_id
                                           ) = 2;

      x_lpn_sec_systemqty := 0;
   END IF;

   IF (x_lpn_systemqty IS NULL) THEN
      x_lpn_systemqty := 0;
   END IF;
EXCEPTION
   WHEN e_invalid_inputs THEN
      ROLLBACK TO get_lpn_item_sysqty;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
         mdebug ('Invalid Inputs');
      END IF;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         mdebug ('Others exception');
      END IF;

      x_lpn_systemqty := 0;
      x_lpn_sec_systemqty := 0;
END Get_LPN_Item_SysQty;
-- END INVCONV

FUNCTION Exists_CC_Entries
(
	p_organization_id	IN	NUMBER
,	p_parent_lpn_id		IN	NUMBER
,  	p_inventory_item_id	IN 	NUMBER
,	p_cost_group_id		IN	NUMBER
,	p_lot_number		IN	VARCHAR2
,	p_revision		IN	VARCHAR2
,	p_serial_number		IN	VARCHAR2
)
RETURN BOOLEAN IS

CURSOR cce_csr IS
  SELECT inventory_item_id
  FROM   MTL_CYCLE_COUNT_ENTRIES
  WHERE  organization_id = p_organization_id
  AND	 parent_lpn_id = p_parent_lpn_id
  AND    inventory_item_id = p_inventory_item_id
  AND    NVL(lot_number, '@') = NVL(p_lot_number, '@')
  AND    NVL(revision, '@') = NVL(p_revision, '@')
  AND    NVL(serial_number, '@') = NVL(p_serial_number, '@')
  AND    NVL(cost_group_id, -1) = NVL(p_cost_group_id, -1)
  AND    entry_status_code IN (1, 3)
  AND    cycle_count_header_id = MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID;   -- 8300310

l_dummy MTL_CYCLE_COUNT_ENTRIES.inventory_item_id%TYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  OPEN cce_csr;
  FETCH cce_csr INTO l_dummy;
  IF cce_csr%FOUND THEN
    CLOSE cce_csr;
    RETURN TRUE;
  END IF;
  CLOSE cce_csr;
  RETURN FALSE;

EXCEPTION
   WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      RETURN FALSE;

   WHEN OTHERS THEN
      RETURN FALSE;

END Exists_CC_Entries;


FUNCTION Exists_CC_Items
(
 	p_cc_header_id		IN 	VARCHAR2
,	p_inventory_item_id	IN	NUMBER
)
RETURN BOOLEAN IS

CURSOR cci_csr IS
  SELECT inventory_item_id
  FROM   MTL_CYCLE_COUNT_ITEMS
  WHERE  inventory_item_id = p_inventory_item_id
  AND    cycle_count_header_id = p_cc_header_id;

l_dummy MTL_CYCLE_COUNT_ITEMS.inventory_item_id%TYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  OPEN cci_csr;
  FETCH cci_csr INTO l_dummy;
  IF cci_csr%FOUND THEN
    CLOSE cci_csr;
    RETURN TRUE;
  END IF;
  CLOSE cci_csr;
  RETURN FALSE;

EXCEPTION
   WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      RETURN FALSE;

   WHEN OTHERS THEN
      RETURN FALSE;

END Exists_CC_Items;

--R12 Procedure to purge the mtl_item_bulkload_recs table
PROCEDURE purge_bulkloadrecs_table
  ( p_request_id NUMBER               ,
    p_commit     BOOLEAN DEFAULT TRUE
   ) IS
BEGIN
   DELETE
   FROM MTL_ITEM_BULKLOAD_RECS
   WHERE REQUEST_ID = p_request_id;

   IF p_commit = TRUE THEN
      COMMIT;
   END IF;
END purge_bulkloadrecs_table;
--R12

END MTL_INV_UTIL_GRP;

/
