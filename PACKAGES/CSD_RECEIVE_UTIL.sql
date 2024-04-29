--------------------------------------------------------
--  DDL for Package CSD_RECEIVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RECEIVE_UTIL" AUTHID CURRENT_USER AS
/* $Header: csdvruts.pls 120.2 2006/03/09 11:29:45 mshirkol noship $ */

/*----------------------------------------------------*/
/* Record name: RCV_REC_TYPE                          */
/* description : Record used for interfacing the      */
/*               receiving API. This reocrd is used   */
/*               to pass information to the receiving */
/*               API to populate the interface tables */
/*----------------------------------------------------*/
   TYPE rcv_rec_type IS RECORD (
      customer_id              NUMBER,  -- value for this can not be G_MISS_NUM should be valid
                                        -- customer id or null
      customer_site_id         NUMBER,  -- value for this can not be G_MISS_NUM should be valid
                                        -- customer site id or null
      employee_id              NUMBER,
      quantity                 NUMBER,
      uom_code                 VARCHAR2 (3),
      unit_of_measure          VARCHAR2 (25),
      inventory_item_id        NUMBER,
      item_revision            VARCHAR2 (3),
      to_organization_id       NUMBER,
      destination_type_code    VARCHAR2 (25),
      subinventory             VARCHAR2 (30),
      locator_id               NUMBER,
      deliver_to_location_id   NUMBER,
      requisition_number       NUMBER,
      requisition_line_id      NUMBER,
      order_header_id          NUMBER,
      order_line_id            NUMBER,
      order_number             VARCHAR2 (30),
      doc_number               VARCHAR2 (30),
      internal_order_flag      VARCHAR2 (1),
      from_organization_id     NUMBER,
      expected_receipt_date    DATE,
      transaction_date         DATE,
      ship_to_location_id      NUMBER,
      serial_number            VARCHAR2 (30),
      lot_number               VARCHAR2 (80), -- fix for bug#4625226
      category_id              NUMBER,
      routing_header_id        NUMBER,
      primary_unit_of_measure  VARCHAR2(25),
      lot_control_code         NUMBER,
      serial_control_code      NUMBER,
      currency_code            VARCHAR2 (3),
      -- Added for internal orders
      shipped_date                date,
      shipment_number          VARCHAR2(30),
      shipment_header_id       NUMBER,
      shipment_line_id         NUMBER
   );

   TYPE rcv_tbl_type IS TABLE OF rcv_rec_type
      INDEX BY BINARY_INTEGER;

/*----------------------------------------------------*/
/* Record name : RCV_ERROR_MSG_REC                    */
/* description : Record used to capture the error     */
/*               messages for a order header and line */
/*----------------------------------------------------*/
   TYPE rcv_error_msg_rec IS RECORD
   (
     group_id                   NUMBER,
     header_interface_id        NUMBER,
     interface_transaction_id   NUMBER,
     order_header_id            NUMBER,
     order_line_id              NUMBER,
     column_name                VARCHAR2(30),
     error_message              VARCHAR2(2000)
   );

   TYPE rcv_error_msg_tbl IS TABLE OF rcv_error_msg_rec
   INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------------------------*/
/* function name: is_auto_rcv_available                                              */
/* description   : This function will check if the item is eligible for auto receive */
/*                                                                              */
/* Called from   : This is called from the LOGISTICS UI and also the            */
/*                 CSD_RECEIVE_PVT.RECEIVE_ITEM  API.                           */
/* Input Parm    : p_inventory_item_id         NUMBER      inventory item id    */
/*                 p_inv_org_id                NUMBER      org id of the receiving */
/*                                                         sub inventory        */
/*                 p_internal_ro_flag          VARCHAR2    indicates if the repair */
/*                                                         order is internal    */
/*                 p_from_inv_org_id           NUMBER      org id from which the */
/*                                                         transfer is  made in the */
/*                                                         case if internal orders */
/* returns         Routing header id.         NUMBER                             */
/*------------------------------------------------------------------------------------*/


   FUNCTION is_auto_rcv_available (
      p_inventory_item_id        IN       NUMBER,
      p_inv_org_id               IN       NUMBER,
      p_internal_ro_flag         IN       VARCHAR2,
      p_from_inv_org_id          IN       NUMBER
   )
      RETURN NUMBER;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: VALIDATE_RCV_INPUT                                                                        */
/* description   : Validates the RMA data. Checks for mandatory fields for                                   */
/*                 Receiving Open interface API.                                                             */
/* Called from   : CSD_RECEIVE_PVT.RECEIVE_ITEM                                                 */
/* Input Parm    :
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_receive_rec         CSD_RCV_UTIL.RCV_REC_TYPE      Required                             */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE validate_rcv_input (
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      p_receive_rec              IN       csd_receive_util.rcv_rec_type
   );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: CHECK_RCV_ERRORS                                                                          */
/* description   : Checks the PO_INTERFACE_ERRORS table to see of there are any error records created by the */
/*                 receiving transaction processor..                                                             */
/* Called from   : CSD_RECEIVE_PVT.RECEIVE_ITEM */
/* Input Parm    :  p_request_group_id    NUMBER      Required                                                */
/* Output Parm   : x_return_status       VARCHAR2     Return status after the call. The status can be */
/*                                                    fnd_api.g_ret_sts_success (success)             */
/*                                                    fnd_api.g_ret_sts_error (error)                 */
/*                                                    fnd_api.g_ret_sts_unexp_error (unexpected)      */
/*                 x_rcv_error_tbl      rcv_error_tbl Returns table of rcv_error messages             */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE check_rcv_errors (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_rcv_error_msg_tbl 	       OUT NOCOPY csd_receive_util.rcv_error_msg_tbl,
      p_request_group_id         IN       NUMBER
   );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: get_employee_id                                                                         */
/* description   : This will return the employee id for the given user id.         */
/*                 */
/* Called from   : CSD_RECEIVE_PVT.RECEIVE_ITEM */
/* Input Parm    :  p_request_group_id    NUMBER    Required                                                */
/* Output Parm   : x_return_status       VARCHAR2   Return status after the call. The status can be*/
/*                                                  fnd_api.g_ret_sts_success (success)            */
/*                                                  fnd_api.g_ret_sts_error (error)                */
/*                                                  fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE get_employee_id (
      p_user_id                  IN       NUMBER,
      x_employee_id              OUT NOCOPY NUMBER
   );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: get_rcv_item_params                                                                        */
/* description   : This will populate some required fields in the receiving data structure    */
/*                 */
/* Called from   : CSD_RECEIVE_PVT.RECEIVE_ITEM */
/* Input Parm    : p_receive_rec         CSD_RCV_UTIL.RCV_REC_TYPE      Required                             */
/* Output Parm   : x_return_status       VARCHAR2   Return status after the call. The status can be*/
/*                                                  fnd_api.g_ret_sts_success (success)            */
/*                                                  fnd_api.g_ret_sts_error (error)                */
/*                                                  fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE get_rcv_item_params (
      p_receive_rec              IN OUT NOCOPY csd_receive_util.rcv_rec_type
   );
END csd_receive_util;
 

/
