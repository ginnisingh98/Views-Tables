--------------------------------------------------------
--  DDL for Package CSD_INTERNAL_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_INTERNAL_ORDERS_PVT" AUTHID CURRENT_USER AS
/* $Header: csdviors.pls 120.0.12010000.4 2010/05/13 14:48:53 subhat noship $ */
-- Start of Comments
-- Package name     : CSD_INTERNAL_ORDERS_PVT
-- Purpose          : This package will contain all the procedures and functions used by the Internal.
--		      Orders. Usage of this package is strictly confined to Oracle Depot Repair
--		      Development.
--
-- History          : 06/04/2010, Created by Sudheer Bhat
-- NOTE             :
-- End of Comments

g_pkg_name constant varchar2(30) := 'CSD_INTERNAL_ORDERS_PVT';

PROCEDURE create_internal_requisition(
								p_api_version 			IN NUMBER,
								p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_product_txn_id        IN NUMBER,
								p_destination_ou        IN NUMBER,
								p_destination_org       IN NUMBER,
								p_destination_loc_id    IN NUMBER,
								p_source_ou				IN NUMBER,
								p_source_org            IN NUMBER,
								p_need_by_date			IN DATE,
								x_requisition           OUT NOCOPY VARCHAR2,
								x_requisition_id		OUT NOCOPY NUMBER,
								x_msg_count             OUT NOCOPY NUMBER,
								x_msg_data              OUT NOCOPY VARCHAR2,
								x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE create_internal_move_orders(
								errbuf 		   			OUT NOCOPY VARCHAR2,
	                            retcode 		   		OUT NOCOPY VARCHAR2,
	                            p_product_txn_id        IN NUMBER,
								p_destination_ou        IN NUMBER,
								p_destination_org       IN NUMBER,
								p_destination_loc_id    IN NUMBER,
								p_source_ou				IN NUMBER,
								p_source_org            IN NUMBER,
								p_need_by_date			IN DATE
								);

PROCEDURE pick_release_internal_order(
								p_api_version 			IN NUMBER,
								p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_product_txn_id        IN NUMBER,
								p_order_header_id       IN NUMBER,
								p_orig_quantity   		IN NUMBER,
								p_shipped_quantity      IN NUMBER,
								p_order_line_id         IN NUMBER,
								x_msg_count             OUT NOCOPY NUMBER,
								x_msg_data              OUT NOCOPY VARCHAR2,
								x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE ship_confirm_internal_order(
								p_api_version 			IN NUMBER,
								p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								p_product_txn_id        IN NUMBER,
								p_order_header_id       IN NUMBER,
								p_orig_quantity   		IN NUMBER,
								p_shipped_quantity      IN NUMBER,
								p_order_line_id         IN NUMBER,
								p_fm_serial_num_tbl		IN JTF_VARCHAR2_TABLE_100,
								p_to_serial_num_tbl		IN JTF_VARCHAR2_TABLE_100,
								p_is_sn_range			IN VARCHAR2,
								p_is_reservable			IN VARCHAR2,
								p_lot_num				IN VARCHAR2,
								p_rev					IN VARCHAR2,
								p_quantity_tbl			IN JTF_NUMBER_TABLE,
								x_msg_count             OUT NOCOPY NUMBER,
								x_msg_data              OUT NOCOPY VARCHAR2,
								x_return_status         OUT NOCOPY VARCHAR2);
/********************************************************************************************/
/* Function Name: IS_SERIAL_RANGE_VALID														*/
/* Description: Validates if the generated SN range is valid or not. The moment we find the */
/* 				range invalid, then we break.												*/
/* Returns: 1 if the range is valid, 0 if its not											*/
/********************************************************************************************/

PROCEDURE IS_SERIAL_RANGE_VALID(p_sn_range_tbl			IN JTF_VARCHAR2_TABLE_100,
							   p_inv_item_id			IN NUMBER,
							   p_current_org_id			IN NUMBER,
							   p_subinventory			IN VARCHAR2 DEFAULT NULL,
							   p_out					OUT NOCOPY NUMBER);

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: RECEIVE_INTERNAL_ORDER                                                                    */
/* description   : Receives an item specified via Internal Sales Order.										 */
/* Called from   : Internal move orders API.                                                                 */
/* Input Parm    :                                                                                           */
/*                 												                                             */
/* Output Parm   : x_return_status               VARCHAR2    Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/

PROCEDURE RECEIVE_INTERNAL_ORDER(p_api_version 		IN NUMBER,
								 p_init_msg_list	IN VARCHAR2 DEFAULT fnd_api.g_false,
								 p_commit			IN VARCHAR2 DEFAULT fnd_api.g_false,
								 p_product_txn_id   IN NUMBER,
								 p_order_header_id	IN NUMBER,
								 p_order_line_id	IN NUMBER,
								 x_return_status	OUT NOCOPY VARCHAR2,
								 x_msg_count		OUT NOCOPY NUMBER,
								 x_msg_data			OUT NOCOPY VARCHAR2
								 );
END CSD_INTERNAL_ORDERS_PVT;

/
