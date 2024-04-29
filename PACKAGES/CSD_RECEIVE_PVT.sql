--------------------------------------------------------
--  DDL for Package CSD_RECEIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RECEIVE_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvrcvs.pls 120.1 2005/07/29 16:53:30 mshirkol noship $ */

   /*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: RECEIVE_ITEM                                                                        */
/* description   : Populates the Receive open interface tables and calls the Receive processor. This handles */
/*                 all types of receives a) Direct b) Standard                       */
/* Called from   : CSDREPLN.pld. logistics tab.*/
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_receive_rec         CSD_RECEIVE_UTIL.RCV_REC_TYPE      Required                             */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE receive_item (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_rcv_error_msg_tbl        OUT NOCOPY csd_receive_util.rcv_error_msg_tbl,
      p_receive_tbl              IN OUT NOCOPY csd_receive_util.rcv_tbl_type
   );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: POPULATE_INTF_TBLS                                                                          */
/* description   : Inserts records into open interface tables for receiving.                                                             */
/* Called from   : CSD_RCV_PVT.RECEIVE_ITEM api */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_receive_rec         CSD_RECEIVE_UTIL.RCV_REC_TYPE      Required                             */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*                 x_request_group_id    NUMBER      Required                                                */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE populate_rcv_intf_tbls (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_receive_tbl              IN       csd_receive_util.rcv_tbl_type,
      x_request_group_id         OUT NOCOPY NUMBER
   );


/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: RCV_REQ_ONLINE                                                                          */
/* description   : This API will submit the request for receiving in the online mode.                       */
/* Called from   : CSD_RCV_PVT.RECEIVE_ITEM api*/
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_request_group_id    NUMBER      Required  request group which is processed by the       */
/*                                                             request                                       */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE rcv_req_online (
      p_api_version              IN       NUMBER,
      p_commit                   IN       VARCHAR2,
      p_init_msg_list            IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_request_group_id         IN       NUMBER
   );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: DELETE_INTF_TBLS                                                                          */
/* description   : Deletes records in RCV_HEADERS_INTERFACE, RCV_TRANSACTIONS_INTERFACE., PO_INTERFACE_ERRORS*/
/*                 MTL_TRANSACTION_LOTS_INTERFACE_TBL, MTL_SERIAL_NUMBERS_INTERFACE_TBL tables.                                                                                   */
/* Called from   : receive_item api                                                                          */
/* Input Parm    :                                                                                           */
/*                 p_request_group_id            NUMBER      Required                                                */
/* Output Parm   : x_return_status               VARCHAR2    Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE delete_intf_tbls (
      x_return_status      OUT NOCOPY      VARCHAR2,
      p_request_group_id   IN              NUMBER
   );


END csd_receive_pvt;
 

/
