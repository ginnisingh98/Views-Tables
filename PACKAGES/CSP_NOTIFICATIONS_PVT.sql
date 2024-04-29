--------------------------------------------------------
--  DDL for Package CSP_NOTIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_NOTIFICATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvpnos.pls 115.7 2002/11/26 06:05:39 hhaugeru ship $ */
-- Start of comments
--  API name    : calculate_loop
--  Type        : Private
--  Function    :
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version                   Standards input
--              p_parts_loop_id                 Parts loop identifier
--              p_inventory_item_id             Item identifier
--              p_include_intransit_mo          Flag to include intransit move orders
--              p_include_interorg_transfers    Flag to include interorg transfers
--              p_include_sales_orders          Flag to include sales orders
--              p_include_move_orders           Flag to include move orders
--              p_include_requisitions          Flag to include requisitions
--              p_include_purchase_orders       Flag to include purchase orders
--              p_include_work_orders           Flag to include work orders
--              p_include_onhand_good           Flag to include onhand good
--              p_include_onhand_bad            Flag to include onhand bad
--              p_tolerance_percent             Tolerance percent allowed
--
--  OUT     :   x_above                         Positive number indicates above level
--              x_below                         Positive number indicates below level
--              x_not_enough_good_parts         Positive number indicates not enough good parts
--              x_quantity_level                Quantity level in parts loop for this item
--              x_onhand_good                   Quantity of onhand good parts.
--              x_min_good                      Minimun onhand good allowed
--              x_total_loop_quantity           Total quantity should be in loop
--              x_return_status                 standard output parameter
--              x_msg_count                     standard output parameter
--              x_msg_data                      standard output parameter
--
--  Version : Current version   1.0
--              Changed....
--            previous version  none
--              Changed....
--            .
--            .
--            previous version  none
--              Changed....
--            Initial version   1.0
--
--  Notes       :
--              Api is used to calculate an item's quantity in released
--              work orders within the time fence for a specified subinventory.
--
-- End of comments

PROCEDURE calculate_loop
( p_api_version           IN      NUMBER,
  p_parts_loop_id         IN      NUMBER,
  p_inventory_item_id     IN      NUMBER,
  p_include_intransit_mo          VARCHAR2 DEFAULT null,
  p_include_interorg_transfers    VARCHAR2 DEFAULT null,
  p_include_sales_orders          VARCHAR2 DEFAULT null,
  p_include_move_orders           VARCHAR2 DEFAULT null,
  p_include_requisitions          VARCHAR2 DEFAULT null,
  p_include_purchase_orders       VARCHAR2 DEFAULT null,
  p_include_work_orders           VARCHAR2 DEFAULT null,
  p_include_onhand_good           VARCHAR2 DEFAULT null,
  p_include_onhand_bad            VARCHAR2 DEFAULT null,
  p_tolerance_percent             NUMBER   DEFAULT null,
  x_above                  OUT NOCOPY    NUMBER,
  x_below                  OUT NOCOPY    NUMBER,
  x_not_enough_good_parts  OUT NOCOPY    NUMBER,
  x_quantity_level         OUT NOCOPY    NUMBER,
  x_onhand_good            OUT NOCOPY    NUMBER,
  x_min_good               OUT NOCOPY    NUMBER,
  x_total_loop_quantity    OUT NOCOPY    NUMBER,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2
);

-- Start of comments
--  API name    : find_notifications
--  Type        : Private
--  Function    :
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       Standards input
--              p_organization_id   Organization identifier
--              p_inventory_item_id Item identifier
--              p_subinventory_code Name of subinventory
--              p_time_fence        Number of days in time fence
--
--  OUT     :   x_return_status     standard output parameter
--              x_msg_count         standard output parameter
--              x_msg_data          standard output parameter
--
--  Version : Current version   1.0
--              Changed....
--            previous version  none
--              Changed....
--            .
--            .
--            previous version  none
--              Changed....
--            Initial version   1.0
--
--  Notes       :
--              Api is used to calculate an item's quantity in released
--              work orders within the time fence for a specified subinventory.
--
-- End of comments
PROCEDURE create_notifications
(   errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_api_version           IN  NUMBER,
    p_organization_id	   IN  NUMBER
);
END;

 

/
