--------------------------------------------------------
--  DDL for Package INV_SALESORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SALESORDER" AUTHID CURRENT_USER AS
/* $Header: INVSOOMS.pls 120.1 2005/06/20 11:10:43 appldev ship $ */
/*#
 * This package can be used to manage sales orders that are represented in
 * MTL Sales Orders, the Oracle Inventory sales order key flexfield. Records can be created
 * deleted and information retrieved from MTL Sales orders.
 * @rep:scope public
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname Inventory Sales Orders
 * @rep:category BUSINESS_ENTITY INV_SALES_ORDERS
 */
/*----------------------------------------------------------------------------+
 |Procedure create_salesorder (
 |		p_api_version_number	IN	NUMBER, -- version number, 1.0
 |		p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
 |		p_segment1		IN	NUMBER, -- the order number
 |		p_segment2		IN	VARCHAR2, -- order type for non OOM, order
 |                                                            header id for OOM
 |		p_segment3		IN	VARCHAR2,-- order source
 |		p_validate_full		IN	NUMBER DEFAULT 1, -- do full flex validation
 |		p_validation_date	IN	DATE, -- date of creation
 |		x_salesorder_id		OUT NOCOPY	NUMBER, -- returned SO id
 |		x_message_data		OUT NOCOPY	VARCHAR2, -- error message data
 |		x_message_count		OUT NOCOPY	NUMBER, -- number of messages on stack
 |		x_return_status		OUT NOCOPY	VARCHAR2) -- return status
 |
 | x_return status could be:
 |  (1)fnd_api.g_ret_success, when procedure completes successfully
 |  (2)fnd_api.g_exc_error, when procedure completes with error. Examine x_message_data
 |  (3)fnd_api.g_exc_unexpected_error, when an unexpected error occurs. Examine
 |  x_message_data
 | The parameter p_validate_full is defualted to 1 which means that flex field APIs
 | are used to create sales orer flex field. When set to 0, we do the creation of the
 | sales order flex field manually. This is faster, but does not do all the validation
 | that the flex field API would do. Set this option to 0 only if you know what you are doing.
 +----------------------------------------------------------------------------------*/

/*#
 * This procedure is used to create a single MTL Sales Order record
 * @param p_api_version_number API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not
 * @param p_segment1 the order number
 * @param p_segment2 the order type
 * @param p_segment3 the order source
 * @param p_validate_full is defualted to 1 which means that flex field APIs are used to create sales orer flex field. When set to 0 the creation of the sales order flex field done manually
 * @param p_validation_date date if creation
 * @param x_return_status Returns the status to indicate success or failure of execution
 * @param x_message_count Returns number of error message in the error message stack in case of failure
 * @param x_message_data Returns the error message in case of failure
 * @param x_salesorder_id Returned sales order id
 * @return Returns the status with value fnd_api.g_ret_success to indicate successful processing and value fnd_api.g_exc_error or fnd_api.g_exc_unexpected_error to indicate failure processing
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Material Create MTL Sales Order
 */
   Procedure create_salesorder (
		p_api_version_number	IN	NUMBER,
		p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_segment1		IN	NUMBER,
		p_segment2		IN	VARCHAR2,
		p_segment3		IN	VARCHAR2,
		p_validate_full		IN	NUMBER DEFAULT 1,
		p_validation_date	IN	DATE,
		x_salesorder_id		OUT NOCOPY	NUMBER,
		x_message_data		OUT NOCOPY	VARCHAR2,
		x_message_count		OUT NOCOPY	NUMBER,
		x_return_status		OUT NOCOPY	VARCHAR2);


/*-------------------------------------------------------------------------------------+
 | This procedure is used for getting the Oracle Order Management (OOM) order_header_id
 | when a SO id is passed to it. It retruns a negative one (-1), if the SO id was created
 | by another system (not OOM).
 | x_return status could be:
 |  (1)fnd_api.g_ret_success, when procedure completes successfully
 |  (2)fnd_api.g_exc_error, when procedure completes with error. Examine x_message_data
 |  (3)fnd_api.g_exc_unexpected_error, when an unexpected error occurs. Examine
 |  x_message_data
 +-------------------------------------------------------------------------------------*/
/*#
 * This Procedure is used to get Order Management Order Header ID using MTL sales order id
 * @param p_salesorder_id Returned sales order id
 * @param x_oe_header_id Returned sales order id
 * @param x_return_status Returns the status to indicate success or failure of execution
 * @return Returns the status with value fnd_api.g_ret_success to indicate successful processing and value fnd_api.g_exc_error or fnd_api.g_exc_unexpected_error to indicate failure processing
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Header ID For MTL Sales Order
 */
Procedure get_oeheader_for_salesorder(
		p_salesorder_id		IN	NUMBER,
		x_oe_header_id		OUT NOCOPY	NUMBER,
		x_return_status		OUT NOCOPY	VARCHAR2);

/*----------------------------------------------------------------------------------------+
 | This function,  get_salesorder_for_oeheader, can be used to get a sales order id       |
 | starting from an Order Management order header id. If there is no matching             |
 |sales order id, a null is returned.	                                                  |
 +----------------------------------------------------------------------------------------*/
/*#
 * This function is used to get sales order using Order Management Order Header ID
 * @param p_oe_header_id Sales order header id
 * @return Returns the MTL sales order id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get MTL Sales Order ID for Sales Order Header
 */
function get_salesorder_for_oeheader(
		p_oe_header_id		IN	NUMBER) RETURN NUMBER;

/*----------------------------------------------------------------------------------------+
 | This function,  synch_salesorders_with_om, is used to update an existing sales order   |
 | with new segment values for either order_number and/or order type and/or order source  |
 | given an original order number and/or order type and/or order source. This API is      |
 | is provided because in Order Management the order number and order type can be updated |
 | even after a sales order has been created. The input parameter "multiple_rows"         |
 | determines whether it is teh intention of the caller to update multiple rows.	  |
 +----------------------------------------------------------------------------------------*/
/*#
 * This function,  synch_salesorders_with_om, is used to update an existing sales order
 * with new segment values for either order_number and/or order type and/or order source
 * given an original order number and/or order type and/or order source. This API is
 * is provided because in Order Management the order number and order type can be updated
 * even after a sales order has been created.
 * @param p_original_order_number the order number
 * @param p_original_order_type the order type
 * @param p_original_source_code the order source
 * @param p_new_order_number the new order number
 * @param p_new_order_type the new order type
 * @param p_new_order_source the new order source
 * @param p_multiple_rows indicated whether caller intends to update multiple rows
 * @return Returns the MTL sales order id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get MTL Sales Order ID for Sales Order Header
 */
function synch_salesorders_with_om(
		p_original_order_number	IN	VARCHAR2,
		p_original_order_type	IN	VARCHAR2,
		p_original_source_code	IN	VARCHAR2,
		p_new_order_number	IN	VARCHAR2,
		p_new_order_type	IN	VARCHAR2,
		p_new_order_source	IN	VARCHAR2,
		p_multiple_rows		IN	VARCHAR2 default 'N') return number ;
/*------------------------------------------------------------------
Added this function as OM  utility is giving Operating unit specfic
and inventory doesnt look  at opertaing unit*/
FUNCTION Get_Header_Id (p_order_number    IN  NUMBER,
                        p_order_type      IN  VARCHAR2,
                        p_order_source    IN  VARCHAR2)
RETURN NUMBER;

/*----------------------------------------------------------------------------+
 |Procedure create_mtl_sales_orders_bulk (
 |		p_api_version_number	IN	NUMBER, -- version number, 1.0
 |		p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
 |		p_header_rec		IN	OE_BULK_ORDER_PVT.HEADER_REC_TYPE
 |		x_message_data		OUT NOCOPY	VARCHAR2, -- error message data
 |		x_message_count		OUT NOCOPY	NUMBER, -- number of messages on stack
 |		x_return_status		OUT NOCOPY	VARCHAR2) -- return status
 |
 | x_return status could be:
 |  (1)fnd_api.g_ret_success, when procedure completes successfully
 |  (2)fnd_api.g_exc_error, when procedure completes with error. Examine x_message_data
 |  (3)fnd_api.g_exc_unexpected_error, when an unexpected error occurs. Examine
 |  x_message_data
 | This API directly inserts into mtl_sales_orders all the rows passed in using the table
 | p_header_rec.
 +----------------------------------------------------------------------------------*/
/*#
 * This procedure inserts the records passed into mtl_sales_orders directly
 * @param p_api_version_number API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not
 * @param p_header_rec list of record to be inserted into mtl_sales_orders
 * @param x_return_status Returns the status to indicate success or failure of execution
 * @param x_message_count Returns number of error message in the error message stack in case of failure
 * @param x_message_data Returns the error message in case of failure
 * @return Returns the status with value fnd_api.g_ret_success to indicate successful processing and value fnd_api.g_exc_error or fnd_api.g_exc_unexpected_error to indicate failure processing
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Bulk Create MTL Sales Order
 */
Procedure create_mtl_sales_orders_bulk (
                p_api_version_number    IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
                p_header_rec            IN      OE_BULK_ORDER_PVT.HEADER_REC_TYPE,
                x_message_data          OUT NOCOPY     VARCHAR2,
                x_message_count         OUT NOCOPY     NUMBER,
                x_return_status         OUT NOCOPY     VARCHAR2);


/*----------------------------------------------------------------------------+
 |Procedure delete_mtl_sales_orders_bulk (
 |		p_api_version_number	IN	NUMBER, -- version number, 1.0
 |		p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
 |		p_error_rec		IN	OE_BULK_ORDER_PVT.INVALID_HDR_REC_TYPE
 |		x_message_data		OUT NOCOPY	VARCHAR2, -- error message data
 |		x_message_count		OUT NOCOPY	NUMBER, -- number of messages on stack
 |		x_return_status		OUT NOCOPY	VARCHAR2) -- return status
 |
 | x_return status could be:
 |  (1)fnd_api.g_ret_success, when procedure completes successfully
 |  (2)fnd_api.g_exc_error, when procedure completes with error. Examine x_message_data
 |  (3)fnd_api.g_exc_unexpected_error, when an unexpected error occurs. Examine
 |  x_message_data
 | This API deletes from mtl_sales_orders for orders with errors. These orders are
 | passed in via p_erro_rec.
 +----------------------------------------------------------------------------------*/
/*#
 * This procedure deletes the records passed from mtl_sales_orders directly
 * @param p_api_version_number API Version of this procedure. Current version is 1.0
 * @param p_error_rec list of sales orders to be deleted from mtl_sales_orders
 * @param p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not
 * @param x_return_status Returns the status to indicate success or failure of execution
 * @param x_message_count Returns number of error message in the error message stack in case of failure
 * @param x_message_data Returns the error message in case of failure
 * @return Returns the status with value fnd_api.g_ret_success to indicate successful processing and value fnd_api.g_exc_error or fnd_api.g_exc_unexpected_error to indicate failure processing
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Bulk Delete MTL Sales Order
 */
PROCEDURE delete_mtl_sales_orders_bulk(
                p_api_version_number    IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
                p_error_rec             IN      OE_BULK_ORDER_PVT.INVALID_HDR_REC_TYPE,
                x_message_data          OUT NOCOPY     VARCHAR2,
                x_message_count         OUT NOCOPY     NUMBER,
                x_return_status         OUT NOCOPY     VARCHAR2);

end inv_salesorder ;


 

/
