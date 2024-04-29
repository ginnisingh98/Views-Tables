--------------------------------------------------------
--  DDL for Package INV_RESERVATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_PVT" AUTHID CURRENT_USER as
/* $Header: INVRSV3S.pls 120.8.12010000.3 2013/02/18 18:25:54 avrose ship $*/

/**** {{ R12 Enhanced reservations code changes }}****/
--Procedure convert_missing_to_null
PROCEDURE convert_missing_to_null
  (p_rsv_rec IN inv_reservation_global.mtl_reservation_rec_type
   , x_rsv_rec OUT NOCOPY inv_reservation_global.mtl_reservation_rec_type);
/*** End R12 ***/

-- Procedure
--   query_reservation
-- Description
--   This  procedure returns all reservations that satisfy the user
--   specified criteria.
-- Input Parameters
--   p_query_input
--     used to specify query criteria
--   p_lock_records
--     fnd_api.g_true or fnd_api.g_false (default).
--     Specify whether to lock matching records
--   p_sort_by_req_date
--     Specify whether to sort the return records by requirement date
--     see INVRSVGS.pls for details
--   p_cancel_order_mode
--     Specify whether to sort the return records by ship_ready_flag
--     and detailed quantity during cancellation of orders
--
-- Output Parameters
--   x_error_code
--     This error code is only meaningful if x_return_status equals
--     fnd_api.g_ret_sts_error.
--     see INVRSVGS.pls for error code definition
PROCEDURE query_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_query_input               IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date          IN  NUMBER   DEFAULT inv_reservation_global.g_query_no_sort
   , p_cancel_order_mode         IN  NUMBER   DEFAULT inv_reservation_global.g_cancel_order_no
   , x_mtl_reservation_tbl       OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count OUT NOCOPY NUMBER
   , x_error_code                OUT NOCOPY NUMBER
   );

/**** {{ R12 Enhanced reservations code changes }}****/
PROCEDURE query_reservation (
p_api_version_number        	IN     	NUMBER
, p_init_msg_lst              	IN     	VARCHAR2 DEFAULT fnd_api.g_false
, x_return_status             	OUT   	NOCOPY VARCHAR2
, x_msg_count                 	OUT    	NOCOPY NUMBER
, x_msg_data                  	OUT    	NOCOPY VARCHAR2
, p_query_input               	IN     	inv_reservation_global.mtl_reservation_rec_type
, p_lock_records              	IN     	VARCHAR2 DEFAULT fnd_api.g_false
, p_sort_by_req_date          	IN     	NUMBER DEFAULT inv_reservation_global.g_query_no_sort
, p_cancel_order_mode         	IN     	NUMBER DEFAULT inv_reservation_global.g_cancel_order_no
, p_serial_number_table	        IN	inv_reservation_global.rsv_serial_number_table
, x_mtl_reservation_tbl       	OUT    	NOCOPY inv_reservation_global.mtl_reservation_tbl_type
, x_mtl_reservation_tbl_count 	OUT    	NOCOPY NUMBER
, x_serial_number_table	        OUT	NOCOPY inv_reservation_global.rsv_serial_number_table
, x_serial_number_table_count	OUT 	NOCOPY NUMBER
, x_error_code                	OUT    	NOCOPY NUMBER
);

 /*** End R12 ***/
--
-- INVCONV - add out parameter x_secondary_quantity_reserved
PROCEDURE create_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec
              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number
              IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number
              OUT NOCOPY inv_reservation_global.serial_number_tbl_type
   , p_partial_reservation_flag  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag      IN  NUMBER DEFAULT 0
   , x_quantity_reserved         OUT NOCOPY NUMBER
   , x_secondary_quantity_reserved  OUT NOCOPY NUMBER
   , x_reservation_id            OUT NOCOPY NUMBER
   /**** {{ R12 Enhanced reservations code changes }}****/
  , p_partial_rsv_exists        IN  BOOLEAN DEFAULT FALSE
  /*** End R12 ***/
  , p_substitute_flag           IN  BOOLEAN DEFAULT FALSE /* Bug 6044651 */
  );

--This procedure is a overlodaed procedure
--Here the partial reservations are honoured.
-- INVCONV - Incorporate secondary_quantity_reserved as an OUT parameter
PROCEDURE update_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , x_quantity_reserved         OUT NOCOPY NUMBER
   , x_secondary_quantity_reserved OUT NOCOPY NUMBER
   , p_original_rsv_rec          IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number    IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number          IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_partial_reservation_flag  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_check_availability        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_over_reservation_flag     IN  NUMBER DEFAULT 0
   );

--This procedure updates the reservation and will in turn call the
-- overloaded update_reservation
PROCEDURE update_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_original_rsv_rec          IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number    IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number          IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_check_availability        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_over_reservation_flag      IN  NUMBER DEFAULT 0
   );


--
PROCEDURE delete_reservation
  (
     p_api_version_number       IN  NUMBER
   , p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   , p_rsv_rec
      IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number
                IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag          IN  VARCHAR2 DEFAULT fnd_api.g_true
   );
--
-- INVCONV - Incorporate secondary quantities into signature
PROCEDURE relieve_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec
      IN  inv_reservation_global.mtl_reservation_rec_type
   , p_primary_relieved_quantity IN NUMBER
   , p_secondary_relieved_quantity  IN NUMBER
   , p_relieve_all               IN VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_serial_number
      IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_primary_relieved_quantity OUT NOCOPY NUMBER
   , x_secondary_relieved_quantity  OUT NOCOPY NUMBER
   , x_primary_remain_quantity   OUT NOCOPY NUMBER
   , x_secondary_remain_quantity OUT NOCOPY NUMBER
   );


PROCEDURE transfer_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_original_rsv_rec
                IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec
                IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number
                IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag   IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag      IN  NUMBER DEFAULT 0
   , x_reservation_id    OUT NOCOPY NUMBER
   );

/**** {{ R12 Enhanced reservations code changes }}****/
-- Overloaded this API as the original transfer reservation did not have
-- the to serial number table as an input
PROCEDURE transfer_reservation
  (
   p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_original_rsv_rec
   IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec
   IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number
   IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number  IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag   IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag      IN  NUMBER DEFAULT 0
   , x_reservation_id    OUT NOCOPY NUMBER
   );
/*** End R12 ***/

--
/*
** ----------------------------------------------------------------------
** For Order Management(OM) use only. Please read below:
** MUST PASS DEMAND SOURCE HEADER ID AND DEMAND SOURCE LINE ID
** ----------------------------------------------------------------------
** This API has been written exclusively for Order Management, who query
** reservations extensively.
** The generic query reservation API, query_reservation(see signature above)
** builds a dynamic SQL to satisfy all callers as it does not know what the
** search criteria is, at design time.
** The dynamic SQL consumes soft parse time, which reduces performance.
** An excessive use of query_reservation contributes to performance
** degradation because of soft parse times.
** Since we know what OM would always use to query reservations
** - demand source header and demand source line, a new API
** with static SQL would be be effective, with reduced performance impact.
** ----------------------------------------------------------------------
** Since OM has been using query_reservation before this, the signature of the
** new API below remains the same to cause minimal impact.
** ----------------------------------------------------------------------
*/

PROCEDURE query_reservation_om_hdr_line
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_query_input
            IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date
            IN  NUMBER   DEFAULT inv_reservation_global.g_query_no_sort
   , p_cancel_order_mode
            IN  NUMBER   DEFAULT inv_reservation_global.g_cancel_order_no
   , x_mtl_reservation_tbl
                          OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count OUT NOCOPY NUMBER
   , x_error_code                OUT NOCOPY NUMBER
   );

/*
** ---------------------------------------------------------------------------
** procedure	: upd_reservation_pup
** description	: This procedure updates the reservations when LPN consolidation
**		  or spilt happens in staging.
**
** i/p 		:
** p_organization_id
**	identifier of organization in which reservation needs to be update
** p_demand_source_header_id
**	source header id for which item is reserved
** p_demand_source_line_id
**	source line id for which item is reserved
** p_from_subinventory_code
**	Subinventory where item was before merge/split of LPN
** p_from_locator_id
**	Locator id where item was before merge/split of LPN
** p_to_subinventory_code
**	Subinventory where item is after merge/split of LPN
** p_to_locator_id
**	Locator id where item is after merge/split of LPN
** p_inventory_item_id
**	Item id
** p_revision
**	Revision for revision controlled item
** p_lot_number
**	Lot number for lot controlled item
** p_quantity
**	Quantity
** p_uom
**	Unit of measure
**
** o/p:
** x_return_status
** 	return status indicating success, error, unexpected error
** x_msg_count
** 	number of messages in message list
** x_msg_data
** 	if the number of messages in message list is 1, contains
**     	message text
** ---------------------------------------------------------------------------
*/

PROCEDURE UPD_RESERVATION_PUP (	x_return_status			OUT NOCOPY VARCHAR2,
			    	x_msg_count 	 		OUT NOCOPY NUMBER,
			    	x_msg_data			OUT NOCOPY VARCHAR2,
				p_commit           		IN  VARCHAR2 := FND_API.g_false,
				p_init_msg_list    		IN  VARCHAR2 := FND_API.g_false,
			    	p_organization_id		IN  NUMBER,
				p_demand_source_header_id	IN  NUMBER,
				p_demand_source_line_id		IN  NUMBER,
				p_from_subinventory_code	IN  VARCHAR2,
				p_from_locator_id		IN  NUMBER,
				p_to_subinventory_code		IN  VARCHAR2,
				p_to_locator_id			IN  NUMBER,
				p_inventory_item_id		IN  NUMBER,
				p_revision			IN  VARCHAR2,
				p_lot_number			IN  VARCHAR2,
				p_quantity			IN  NUMBER,
				p_uom				IN  VARCHAR2,
				p_validation_flag               IN  VARCHAR2 := fnd_api.g_false,
				p_force_reservation_flag        IN  VARCHAR2 := fnd_api.g_false
			  );

/*
** ---------------------------------------------------------------------------
** procedure	: Upd_Reservation_PUP_New
** description	: This procedure updates the reservations when LPN consolidation
**		  or spilt happens in staging.
**
** i/p 		:
** p_organization_id
**	identifier of organization in which reservation needs to be update
** p_demand_source_header_id
**	source header id for which item is reserved
** p_demand_source_line_id
**	source line id for which item is reserved
** p_from_subinventory_code
**	Subinventory where item was before merge/split of LPN
** p_from_locator_id
**	Locator id where item was before merge/split of LPN
** p_to_subinventory_code
**	Subinventory where item is after merge/split of LPN
** p_to_locator_id
**	Locator id where item is after merge/split of LPN
** p_inventory_item_id
**	Item id
** p_revision
**	Revision for revision controlled item
** p_lot_number
**	Lot number for lot controlled item
** p_quantity
**	Quantity
** p_uom
**	Unit of measure
** p_lpn_id
**      lpn_id of the LPN for the new reservation line
** p_requirement_date
**      Requirement Date
** o/p:
** x_return_status
** 	return status indicating success, error, unexpected error
** x_msg_count
** 	number of messages in message list
** x_msg_data
** 	if the number of messages in message list is 1, contains
**     	message text
** ---------------------------------------------------------------------------
*/
PROCEDURE Upd_Reservation_PUP_New(
  x_return_status           OUT    NOCOPY VARCHAR2
, x_msg_count               OUT    NOCOPY NUMBER
, x_msg_data                OUT    NOCOPY VARCHAR2
, p_commit                  IN     VARCHAR2 := fnd_api.g_false
, p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false
, p_organization_id         IN     NUMBER
, p_demand_source_header_id IN     NUMBER
, p_demand_source_line_id   IN     NUMBER
, p_from_subinventory_code  IN     VARCHAR2
, p_from_locator_id         IN     NUMBER
, p_to_subinventory_code    IN     VARCHAR2
, p_to_locator_id           IN     NUMBER
, p_inventory_item_id       IN     NUMBER
, p_revision                IN     VARCHAR2
, p_lot_number              IN     VARCHAR2
, p_quantity                IN     NUMBER
, p_uom                     IN     VARCHAR2
, p_lpn_id                  IN     NUMBER   := NULL
, p_validation_flag         IN     VARCHAR2 := fnd_api.g_false
, p_force_reservation_flag  IN     VARCHAR2 := fnd_api.g_false
, p_requirement_date        IN     DATE DEFAULT NULL -- bug 2879208
, p_source_lpn_id           IN     NUMBER   := NULL  -- Bug 4016953/3871066
, p_demand_source_name      IN     VARCHAR2 DEFAULT NULL -- RTV Project
  );

/*
** ---------------------------------------------------------------------------
** procedure	: TRANSFER_LPN_TRX_RESERVATION
** description	: This procedure is called by the transaction manager to transfer a
**		  			  reservation when LPN consolidation or spilt happens in staging..
**
** i/p 		:
** p_transaction_temp_id
** temp id of line in mtl_material_transaction_temp being processed
** p_organization_id
**	identifier of organization in which reservation needs to be update
** p_lpn_id
**	lpn being split of consolidated and is in need for a reservation transfer
** p_from_subinventory_code
**	Subinventory where item was before merge/split of LPN
** p_from_locator_id
**	Locator id where item was before merge/split of LPN
** p_to_subinventory_code
**	Subinventory where item is after merge/split of LPN
** p_to_locator_id
**	Locator id where item is after merge/split of LPN
** p_inventory_item_id
**	Item id
** p_revision
**	Revision for revision controlled item
** p_lot_number
**	Lot number for lot controlled item
** p_trx_quantity
**	Quantity
** p_trx_uom
**	Unit of measure
**
** o/p:
** x_return_status
** 	return status indicating success, error, unexpected error
** x_msg_count
** 	number of messages in message list
** x_msg_data
** 	if the number of messages in message list is 1, contains
**     	message text
** ---------------------------------------------------------------------------
*/

Procedure TRANSFER_LPN_TRX_RESERVATION
( 	x_return_status				OUT 	NOCOPY VARCHAR2,
	x_msg_count     				OUT 	NOCOPY NUMBER,
	x_msg_data   					OUT 	NOCOPY VARCHAR2,
	p_commit        				IN  	VARCHAR2 := FND_API.g_false,
	p_init_msg_list  				IN  	VARCHAR2 := FND_API.g_false,
	p_transaction_temp_id		IN		NUMBER	:= 0,
	p_organization_id				IN 	NUMBER,
	p_lpn_id 						IN 	NUMBER,
	p_from_subinventory_code	IN  	VARCHAR2,
   p_from_locator_id  			IN  	NUMBER,
   p_to_subinventory_code  	IN  	VARCHAR2,
   p_to_locator_id   			IN  	NUMBER,
   p_inventory_item_id  		IN  	NUMBER	:= NULL,
   p_revision   					IN  	VARCHAR2	:= NULL,
   p_lot_number   				IN  	VARCHAR2	:= NULL,
   p_trx_quantity   				IN  	NUMBER	:= NULL,
   p_trx_uom						IN		VARCHAR2	:= NULL
);
--These Procedures are used for storing and deleting reservations
--if onhand and availability fails after do_check.
PROCEDURE   Insert_rsv_temp( p_organization_id               NUMBER
                            ,p_inventory_item_id            NUMBER
                            ,p_primary_reservation_quantity NUMBER
                            ,p_tree_id                      NUMBER
                            ,p_reservation_id               NUMBER
                            ,x_return_status      OUT       NOCOPY VARCHAR2
                            ,p_demand_source_line_id        NUMBER
                            ,p_demand_source_header_id      NUMBER
                            ,p_demand_source_name           VARCHAR2);
PROCEDURE  Do_check_for_commit( p_api_version_number  IN  NUMBER
     , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
     , x_return_status       OUT NOCOPY VARCHAR2
     , x_msg_count           OUT NOCOPY NUMBER
     , x_msg_data            OUT NOCOPY VARCHAR2
     ,x_failed_rsv_temp_tbl  OUT NOCOPY inv_reservation_global.mtl_failed_rsv_tbl_type);

PROCEDURE print_rsv_rec(p_rsv_rec IN inv_reservation_global.mtl_reservation_rec_type);


PROCEDURE convert_quantity(x_return_status OUT NOCOPY VARCHAR2, px_rsv_rec IN OUT NOCOPY inv_reservation_global.mtl_reservation_rec_type);

/**** {{ R12 Enhanced reservations code changes }}****/
/*  This API will take a set of parameters and return the wip entity type and the job type as output. */

PROCEDURE get_wip_entity_type
  (
   p_api_version_number	 IN     NUMBER
   , p_init_msg_lst      IN     VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status     OUT   	NOCOPY VARCHAR2
   , x_msg_count         OUT    NOCOPY NUMBER
   , x_msg_data          OUT    NOCOPY VARCHAR2
   , p_organization_id   IN	NUMBER DEFAULT NULL
   , p_item_id	         IN	NUMBER DEFAULT NULL
   , p_source_type_id    IN	NUMBER DEFAULT INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP
   , p_source_header_id	 IN	NUMBER
   , p_source_line_id	 IN    	NUMBER
   , p_source_line_detail IN	NUMBER
   , x_wip_entity_type	 OUT NOCOPY NUMBER
   , x_wip_job_type	 OUT NOCOPY VARCHAR2
   );

/*===============================================================================*
| Procedure                                                                      |
|   update_serial_rsv_quantity                                                   |
| Description                                                                    |
|   This procedure is to update the serial_reservation_quantity in               |
|   mtl_reservations when the serial number's group mark id and reservation_id   |
|   is mark or serial number is unmark                                           |
| Input Parameters                                                               |
|   p_reservation_id                                                             |
|     Reservation ID stamps with the serial number                               |
|   p_update_serial_qty                                                          |
|     the quantity that needs to update for serial_reservation_quantity in       |
|     mtl_reservations                                                           |
|     if the serial is marked and reserved, the value of p_update_serial_qty is  |
|     positive because the serial_reservation_quantity should be increased.      |
|     if the serial is unmarked and unreserved, the value of p_update_serial_qty |
|     is negative because the serial_reservation_quantity should be decrased.    |
*================================================================================*/

PROCEDURE update_serial_rsv_quantity(
           x_return_status       OUT NOCOPY VARCHAR2
          ,x_msg_count           OUT NOCOPY NUMBER
          ,x_msg_data            OUT NOCOPY VARCHAR2
          ,p_reservation_id      IN  NUMBER
          ,p_update_serial_qty   IN  NUMBER);

/*=================================================================================*
| Procedure                                                                        |
|   is_serial_number_reserved                                                      |
| Description                                                                      |
|   This procedure checks whether a serial or a group of serials passed to         |
|   this API have been reserved or not.  This API would return all the             |
|   serials with the reservation ID tied to the serial number                      |
| Input Parameters                                                                 |
|   p_api_version_number                                                           |
|     API version number                                                           |
|   p_init_msg_lst                                                                 |
|     Whether initialize the error message list or not                             |
|     Should be fnd_api.g_false or fnd_api.g_true                                  |
|   p_serial_number_tbl                                                            |
|     table of serials to check whether the serials have been reserved or not      |
| Output Parameters                                                                |
|   x_return_status                                                                |
|     return status indicating success, error, unexpected error                    |
|   x_msg_count                                                                    |
|     number of messages in message list                                           |
|   x_msg_data                                                                     |
|     if the number of messages in message list is 1, contains                     |
|     message text                                                                 |
|   x_serial_number_tbl                                                            |
|     the table of serials with the reservation ID tied to it                      |
|                                                                                  |
*==================================================================================*/

PROCEDURE is_serial_number_reserved
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_serial_number_tbl         IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number_tbl         OUT NOCOPY inv_reservation_global.rsv_serial_number_table
  );

/*=================================================================================*
| Procedure                                                                        |
|   is_serial_reserved                                                             |
| Description                                                                      |
|   This procedure checks whether a serial or a group of serials passed to         |
|   this API have been reserved or not.  This API would return all the             |
|   serials along with the entire reservation tied to the serial number if the     |
|   serial number is reserved                                                      |
| Input Parameters                                                                 |
|   p_api_version_number                                                           |
|     API version number                                                           |
|   p_init_msg_lst                                                                 |
|     Whether initialize the error message list or not                             |
|     Should be fnd_api.g_false or fnd_api.g_true                                  |
|   p_serial_number_tbl                                                            |
|     table of serials to check whether the serials have been reserved or not      |
| Output Parameters                                                                |
|   x_return_status                                                                |
|     return status indicating success, error, unexpected error                    |
|   x_msg_count                                                                    |
|     number of messages in message list                                           |
|   x_msg_data                                                                     |
|     if the number of messages in message list is 1, contains                     |
|     message text                                                                 |
|   x_serial_number_tbl                                                            |
|     the table of serials with the reservation ID tied to it                      |
|   x_mtl_reservation_tbl                                                          |
|     the table of reservation record with the serial number that is reserved      |
|                                                                                  |
*==================================================================================*/

PROCEDURE is_serial_reserved
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_serial_number_tbl         IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number_tbl         OUT NOCOPY inv_reservation_global.rsv_serial_number_table
   , x_mtl_reservation_tbl       OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
  );

PROCEDURE Transfer_Reservation_SubXfer
  ( p_api_version_number         IN  NUMBER  DEFAULT 1.0
  , p_init_msg_lst               IN  VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status              OUT NOCOPY VARCHAR2
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2
  , p_Inventory_Item_Id          IN  Number
  , p_Organization_id            IN  Number
  , p_original_Reservation_Id    IN  Number
  , p_From_Serial_Number         IN  Varchar2
  , p_to_SubInventory            IN  Varchar2
  , p_To_Locator_Id              IN  Number
  , p_to_serial_number           IN  Varchar2
  , p_validation_flag            IN  VARCHAR2
  , x_to_reservation_id          OUT NOCOPY NUMBER
  );

/*=================================================================================*
| Procedure                                                                        |
|   transfer_serial_rsv_in_LPN                                                     |
| Description                                                                      |
|   This procedure is to transfer serial reservation where the serial is in lpn    |
|   and there is no lpn in the reservation. If the p_outermost_lpn_id is passed    |
|   ,then transfer all the serial reservations where the serial is in the inner    |
|   lpn. If p_lpn_id is passed, then transfer the reservation that has any serials |
|   reserved in the LPN and no LPN is reserved in the same reservation.            |
|   Either p_outermost_lpn_id or p_lpn_id will be populated.                       |
| Input Parameters                                                                 |
|   p_organization_id                                                              |
|     Organization id of the reservation to transfer                               |
|   p_inventory_item_id                                                            |
|     Invnetory item id of the reservation to transfer                             |
|   p_lpn_id                                                                       |
|     LPN id to check if any serials reserved in it                                |
|   p_outermost_lpn_id                                                             |
|     The outermost lpn to check if any serials reserved in all the lpns in the    |
|     outermost lpn                                                                |
| Output Parameters                                                                |
|   x_return_status                                                                |
|     return status indicating success, error, unexpected error                    |
|   x_msg_count                                                                    |
|     number of messages in message list                                           |
|   x_msg_data                                                                     |
|     if the number of messages in message list is 1, contains                     |
|     message text                                                                 |
|                                                                                  |
*==================================================================================*/
PROCEDURE transfer_serial_rsv_in_LPN
  (
     x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_organization_id           IN  NUMBER
   , p_inventory_item_id         IN  NUMBER DEFAULT NULL
   , p_lpn_id                    IN  NUMBER
   , p_outermost_lpn_id          IN  NUMBER
   , p_to_subinventory_code      IN  VARCHAR2
   , p_to_locator_id             IN  NUMBER
  );

/*** End R12 ***/

/*=============================================================================
|Procedure                                                                     |
  |    get_demand_reservable_qty                                                 |
  | Description
  |   helper procedure called from update_reservation and
  |   transfer_reservation to get available to reserve qty
  |   for the demand source
  |Input parameters:
  |-- all demand information from the from record such as demand type,
  |header, line and line detail
  |-- all demand information from the to record such as demand type,
  |header, line and line detail
  |-- from primary reservation qty
  |-- to primary reservation qty
  |-- to record's item information such as organization id, item id, uom
  |code, project and task information
  |
  |Output Parameters:
  |x_reservable_qty - The available quantity to reserve for the demand
  |record currently being reserved
  x_|qty_available - The available quantity for the document being reserved
=============================================================================*/


  PROCEDURE get_demand_reservable_qty
  ( x_return_status                OUT NOCOPY VARCHAR2
  , x_msg_count                    OUT NOCOPY NUMBER
  , x_msg_data                     OUT NOCOPY VARCHAR2
  , p_fm_demand_source_type_id     IN NUMBER
  , p_fm_demand_source_header_id   IN NUMBER
  , p_fm_demand_source_line_id     IN NUMBER
  , p_fm_demand_source_line_detail IN NUMBER
  , p_fm_primary_reservation_qty   IN NUMBER
  , p_fm_secondary_reservation_qty   IN NUMBER
  , p_to_demand_source_type_id     IN NUMBER
  , p_to_demand_source_header_id   IN NUMBER
  , p_to_demand_source_line_id     IN NUMBER
  , p_to_demand_source_line_detail IN NUMBER
  , p_to_primary_reservation_qty   IN NUMBER
  , p_to_organization_id           IN NUMBER
  , p_to_inventory_item_id         IN NUMBER
  , p_to_primary_uom_code          IN VARCHAR
  , p_to_project_id                IN NUMBER
  , p_to_task_id                   IN NUMBER
  , x_reservable_qty               OUT NOCOPY NUMBER
  , x_qty_available                OUT NOCOPY NUMBER
  , x_reservable_qty2               OUT NOCOPY NUMBER
  , x_qty_available2                OUT NOCOPY NUMBER
  );


/*=============================================================================
|Procedure                                                                     |
  |    get_supply_reservable_qty                                                 |
  | Description
  |   helper procedure called from update_reservation and
  |   transfer_reservation to get available to reserve qty
  |   for the supply source
  |Input parameters:
  |   all supply information from the from record such as supply type,
  |header, line and line detail
  | all supply information from the to record such as supply type,
  |header, line and line detail
  |-- from primary reservation qty
  |-- to primary reservation qty
  |-- to record's item information such as organization id, item id, uom
  |code, project and task information
  |
  |Output Parameters:
  |x_reservable_qty - The available quantity to reserve for the supply
  |record currently being reserved
  x_|qty_available - The available quantity for the document being reserved
=============================================================================*/

PROCEDURE get_supply_reservable_qty
  ( x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_fm_supply_source_type_id     IN NUMBER
    , p_fm_supply_source_header_id   IN NUMBER
    , p_fm_supply_source_line_id     IN NUMBER
    , p_fm_supply_source_line_detail IN NUMBER
    , p_fm_primary_reservation_qty   IN NUMBER
    , p_to_supply_source_type_id     IN NUMBER
    , p_to_supply_source_header_id   IN NUMBER
    , p_to_supply_source_line_id     IN NUMBER
    , p_to_supply_source_line_detail IN NUMBER
    , p_to_primary_reservation_qty   IN NUMBER
    , p_to_organization_id           IN NUMBER
    , p_to_inventory_item_id         IN NUMBER
    , p_to_revision                  IN VARCHAR2
    , p_to_lot_number                IN VARCHAR2
    , p_to_subinventory_code         IN VARCHAR2
    , p_to_locator_id                IN NUMBER
    , p_to_lpn_id                    IN NUMBER
    , p_to_project_id                IN NUMBER
  , p_to_task_id                     IN NUMBER
  , x_reservable_qty                 OUT NOCOPY NUMBER
  , x_qty_available                  OUT NOCOPY NUMBER
  );

 PROCEDURE get_ship_qty_tolerance
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2  Default Fnd_API.G_False
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_demand_type_id                IN  NUMBER
   , p_demand_header_id              IN  NUMBER
   , p_demand_line_id                IN  NUMBER
   , x_reservation_margin_above      OUT NOCOPY NUMBER                   -- INVCONV
   );

 FUNCTION lot_divisible
   (p_inventory_item_id             IN  NUMBER
    , p_organization_id             IN  NUMBER)
    RETURN BOOLEAN;


END inv_reservation_pvt;

/
