--------------------------------------------------------
--  DDL for Package WIP_RESERVATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_RESERVATIONS_GRP" AUTHID CURRENT_USER AS
/* $Header: wipsogps.pls 120.1 2005/09/28 04:26 mraman noship $ */

/***************************************************************************
|         PROCEDURE get_available_supply_demand()
|***************************************************************************
|
| The purpose of this API is to get the final availability of the
| document line for which the reservation is being created/ modified.
| This procedure will be called by the inventory APIs to get the expected
| availability at the document level.
|
| Various Parameters enlisted
|
|  x_return_status  -	Returns the status to the calling API
|
|  x_msg_count 	    -   Returns the message count in the stack
|
|  x_msg_data	    -   Returns the messages from the stack
|
|  x_available_quantity	 Returns the final available quantity on the
|                        document line for which the reservation is
			 being made
|
| x_source_uom_code	  Returns the UOM of the source document
|
| x_source_primary_uom_code	Returns the primary UOM of the
				source document
|
| p_organization_id   -	Organization id of the document to be
			validated
|
| p_item_id	      - Inventory item id of the document to be validated
|
| p_revision	      - Revision of the item
|
| p_lot_number	      - Lot number of the item
|
| p_subinventory_code  - Subinventory code
|
| p_locator_id	       - Locator id of the subinventory if the
|                        subinventory is locator controlled
|
| p_supply_demand_code	     - The action determines whether the
				calling API
|                              is querying for a supply or demand
|
| p_supply_demand_type_id   - This holds the demand type for which
			      the availability is to be checked
| p_supply_demand_header_id - This holds the header information of
|			      the demand document for which the
			      availability is to be checked
| p_supply_demand_line_id   - This holds the line information of
			      the demand document for which the
			      availability is to be checked
| p_supply_demand_line_detail	- This holds the line information of
                                  the demand document for which
				  the availability is to be checked
| p_lpn_id	      -    This is the lpn for the supply document
			   for which the availability is going to
			   be computed
| P_project_id	      -	   This holds the project id for the
			   demand document
| P_task_id	      -    This holds the task id for the
|			   demand document
| p_api_version_number -   Api version number
|
| p_init_msg_lst      -  	To initialize message list or not
|
| p_return_txn        -    To differentiate between return transaction and
|                          Other transactions
|
|
***************************************************************************/

PROCEDURE get_available_supply_demand (
 p_api_version_number     		IN     	NUMBER default 1.0
, p_init_msg_lst             		IN      VARCHAR2
,x_return_status            		OUT    	NOCOPY VARCHAR2
, x_msg_count                		OUT    	NOCOPY NUMBER
, x_msg_data                 		OUT    	NOCOPY VARCHAR2
, x_available_quantity			OUT      NOCOPY NUMBER
, x_source_primary_uom_code	        OUT      NOCOPY VARCHAR2
, x_source_uom_code			OUT      NOCOPY VARCHAR2
, p_organization_id			IN 	NUMBER default null
, p_item_id				IN 	NUMBER default null
, p_revision				IN 	VARCHAR2 default null
, p_lot_number			        IN	VARCHAR2 default null
, p_subinventory_code		        IN	VARCHAR2 default null
, p_locator_id			        IN 	NUMBER default null
, p_supply_demand_code		        IN	NUMBER
, p_supply_demand_type_id		IN	NUMBER
, p_supply_demand_header_id		IN	NUMBER
, p_supply_demand_line_id		IN	NUMBER
, p_supply_demand_line_detail		IN	NUMBER default FND_API.G_MISS_NUM
, p_lpn_id				IN	NUMBER default FND_API.G_MISS_NUM
, p_project_id			        IN	NUMBER default null
, p_task_id				IN	NUMBER default null
, p_return_txn                          IN      NUMBER default  0
) ;

/***************************************************************************
|         PROCEDURE validate_supply_demand ()
|***************************************************************************
|
| The purpose of this API is to validate whether a supply or a demand line
| for which the reservation is being created/ modified is a valid document line.
| This API will return a 'Y' or 'N', and the process will continue if the
| returned value is 'Y'.
|
| x_return_status     - Returns the status to the calling API
|
| x_msg_count         -	Returns the message count in the stack
|
| x_msg_data	      - Returns the messages from the stack
|
| x_valid_status      -	Returns whether the supply or demand
|			document is valid or not
| p_organization_id	Organization id of the document to be validated
|
| P_item_id		- Inventory item id of the document to be
			  validated
| p_supply_demand_code	- The action determines whether the calling
|			  API is querying for a supply or demand
| p_supply_demand_type_id   - This holds the demand type for which
			      the availability is to be checked
| p_supply_demand_header_id - This holds the header information of the
			      demand document for which the availability
			      is to be checked
| p_supply_demand_line_id   - This holds the line information of the demand
			      document for which the availability is to
			      be checked
| p_supply_demand_line_detail - This holds the line information of the demand
			      document for which the availability is to
			      be checked
| p_demand_ship_date	     - This is will be filled in for reservations
                               that are crossdocked. For non-crossdocked
			       reservations, this will be the need-by-date
			       of the demand
| p_expected_receipt_date    - This is will be filled in for reservations
			      that are crossdocked.
			      For non-crossdocked reservations, this will be null.
| p_api_version_number	    - Api version number
|
| p_init_msg_lst            - To initialize message list or not
|
***************************************************************************/

PROCEDURE validate_supply_demand (
x_return_status            		OUT    	NOCOPY VARCHAR2
, x_msg_count                		OUT    	NOCOPY NUMBER
, x_msg_data                 		OUT    	NOCOPY VARCHAR2
, x_valid_status			OUT      NOCOPY VARCHAR2
, p_organization_id			IN	NUMBER
, p_item_id				IN	NUMBER
, p_supply_demand_code			IN	NUMBER
, p_supply_demand_type_id		IN	NUMBER
, p_supply_demand_header_id		IN	NUMBER
, p_supply_demand_line_id		IN	NUMBER
, p_supply_demand_line_detail		IN	NUMBER default FND_API.G_MISS_NUM
, p_demand_ship_date			IN	DATE
, p_expected_receipt_date		IN	DATE
, p_api_version_number     		IN     	NUMBER default 1.0
,p_init_msg_lst		        IN VARCHAR2
) ;

END wip_reservations_grp ;


 

/
