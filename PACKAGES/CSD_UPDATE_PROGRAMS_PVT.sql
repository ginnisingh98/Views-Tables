--------------------------------------------------------
--  DDL for Package CSD_UPDATE_PROGRAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_UPDATE_PROGRAMS_PVT" AUTHID CURRENT_USER as
/* $Header: csddrcls.pls 120.3 2008/04/12 01:25:38 takwong ship $ */

/*-------------------------------------------------------------------------------------*/
/*      Name           : Activity_rec_type                                             */
/*      Package name   : csd_update_programs_pvt                                       */
/*      Type           : type definition, private                                      */
/*      Description    : Record to hold information about the activity                 */
/*-------------------------------------------------------------------------------------*/

TYPE Activity_Rec_Type IS RECORD
(     REPAIR_HISTORY_ID                       csd_repair_history.REPAIR_HISTORY_ID%type,
      REPAIR_LINE_ID                          csd_repair_history.REPAIR_LINE_ID%type,
      REQUEST_ID                              csd_repair_history.REQUEST_ID%type,
      PROGRAM_ID                              csd_repair_history.PROGRAM_ID%type,
      PROGRAM_APPLICATION_ID                  csd_repair_history.PROGRAM_APPLICATION_ID%type,
      PROGRAM_UPDATE_DATE                     csd_repair_history.PROGRAM_UPDATE_DATE%type,
      EVENT_CODE                              csd_repair_history.EVENT_CODE%type,
      ACTION_CODE                             NUMBER,
      EVENT_DATE                              csd_repair_history.EVENT_DATE%type,
      QUANTITY                                csd_repair_history.QUANTITY%type,
      PARAMN1                                 csd_repair_history.PARAMN1%type,
      PARAMN2                                 csd_repair_history.PARAMN2%type,
      PARAMN3                                 csd_repair_history.PARAMN3%type,
      PARAMN4                                 csd_repair_history.PARAMN4%type,
      PARAMN5                                 csd_repair_history.PARAMN5%type,
      PARAMN6                                 csd_repair_history.PARAMN6%type,
      PARAMN7                                 csd_repair_history.PARAMN7%type,
      PARAMN8                                 csd_repair_history.PARAMN8%type,
      PARAMN9                                 csd_repair_history.PARAMN9%type,
      PARAMN10                                csd_repair_history.PARAMN10%type,
      PARAMC1                                 csd_repair_history.PARAMC1%type,
      PARAMC2                                 csd_repair_history.PARAMC2%type,
      PARAMC3                                 csd_repair_history.PARAMC3%type,
      PARAMC4                                 csd_repair_history.PARAMC4%type,
      PARAMC5                                 csd_repair_history.PARAMC5%type,
      PARAMC6                                 csd_repair_history.PARAMC6%type,
      PARAMC7                                 csd_repair_history.PARAMC7%type,
      PARAMC8                                 csd_repair_history.PARAMC8%type,
      PARAMC9                                 csd_repair_history.PARAMC9%type,
      PARAMC10                                csd_repair_history.PARAMC10%type,
      PARAMD1                                 csd_repair_history.PARAMD1%type,
      PARAMD2                                 csd_repair_history.PARAMD2%type,
      PARAMD3                                 csd_repair_history.PARAMD3%type,
      PARAMD4                                 csd_repair_history.PARAMD4%type,
      PARAMD5                                 csd_repair_history.PARAMD5%type,
      PARAMD6                                 csd_repair_history.PARAMD6%type,
      PARAMD7                                 csd_repair_history.PARAMD7%type,
      PARAMD8                                 csd_repair_history.PARAMD8%type,
      PARAMD9                                 csd_repair_history.PARAMD9%type,
      PARAMD10                                csd_repair_history.PARAMD10%type,
      ATTRIBUTE_CATEGORY                      csd_repair_history.ATTRIBUTE_CATEGORY%type,
      ATTRIBUTE1                              csd_repair_history.ATTRIBUTE1%type,
      ATTRIBUTE2                              csd_repair_history.ATTRIBUTE2%type,
      ATTRIBUTE3                              csd_repair_history.ATTRIBUTE3%type,
      ATTRIBUTE4                              csd_repair_history.ATTRIBUTE4%type,
      ATTRIBUTE5                              csd_repair_history.ATTRIBUTE5%type,
      ATTRIBUTE6                              csd_repair_history.ATTRIBUTE6%type,
      ATTRIBUTE7                              csd_repair_history.ATTRIBUTE7%type,
      ATTRIBUTE8                              csd_repair_history.ATTRIBUTE8%type,
      ATTRIBUTE9                              csd_repair_history.ATTRIBUTE9%type,
      ATTRIBUTE10                             csd_repair_history.ATTRIBUTE10%type,
      ATTRIBUTE11                             csd_repair_history.ATTRIBUTE11%type,
      ATTRIBUTE12                             csd_repair_history.ATTRIBUTE12%type,
      ATTRIBUTE13                             csd_repair_history.ATTRIBUTE13%type,
      ATTRIBUTE14                             csd_repair_history.ATTRIBUTE14%type,
      ATTRIBUTE15                             csd_repair_history.ATTRIBUTE15%type,
      OBJECT_VERSION_NUMBER                   csd_repair_history.OBJECT_VERSION_NUMBER%type
    );

-- Define a record of type Activity_Rec_Type
activity_rec  Activity_Rec_Type;

/*-------------------------------------------------------------------------------------*/
/* Procedure name: Convert_to_RO_uom                                                   */
/* Description   : Procedure to convert the qty into Repair Order UOM                  */
/*                 Logistics lines could be created with different UOM than the one on */
/*                 repair order                                                        */
/* Called from   : Called from Update API (SO_RCV_UPDATE,SO_SHIP_UPDATE)               */
/*                                                                                     */
/* STANDARD PARAMETERS                                                                 */
/*   In Parameters :                                                                   */
/*                                                                                     */
/*   Output Parameters:                                                                */
/*     x_return_status     VARCHAR2      Return status of the API                      */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*     p_to_uom_code     VARCHAR2 Required   RO Unit of measure                        */
/*     p_item_id         NUMBER   Required   Inventory Item Id                         */
/*     p_from_uom        VARCHAR2 Conditionaly Required Needed for receiving lines     */
/*     p_from_uom_code   VARCHAR2 Conditionaly Required Needed for shipping lines      */
/*     p_from_quantity   NUMBER   Required   Transaction quantity                      */
/*   Out parameters                                                                    */
/*     x_result_quantity   NUMBER        converted qty in Repair Order UOM             */
/*                                                                                     */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure CONVERT_TO_RO_UOM
          (x_return_status   OUT NOCOPY  VARCHAR2,
           p_to_uom_code     IN varchar2,
           p_item_id         IN NUMBER,
  	     p_from_uom        IN varchar2,
           p_from_uom_code   IN varchar2,
           p_from_quantity   IN number,
           x_result_quantity OUT NOCOPY number );

/*-------------------------------------------------------------------------------------*/
/* Procedure name: LOG_ACTIVITY                                                        */
/* Description   : Procedure called for logging activity                               */
/*                                                                                     */
/* Called from   : Called from all the api                                             */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_activity_rec    RECORD TYPE   Activity record type                             */
/* Output Parameter :                                                                  */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure LOG_ACTIVITY
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_activity_rec         IN   activity_rec_type );


/*-------------------------------------------------------------------------------------*/
/* Procedure name: JOB_COMPLETION_UPDATE                                               */
/* Description   : Procedure called from wip_update API to update the completed qty    */
/*                 It also logs activity for the job completion                        */
/* Called from   : Called from WIP_Update API                                          */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure JOB_COMPLETION_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_repair_line_id       IN   NUMBER );

/*-------------------------------------------------------------------------------------*/
/* Procedure name: JOB_CREATION_UPDATE                                                 */
/* Description   : Procedure called from wip_update API to update the wip entity Id    */
/*                 for the new jobs created by the WIP Mass Load concurrent program    */
/* Called from   : Called from WIP_Update API                                          */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*                                                                                     */
/*-------------------------------------------------------------------------------------*/

Procedure JOB_CREATION_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_repair_line_id       IN   NUMBER );

/*-------------------------------------------------------------------------------------*/
/* Procedure name: RECEIPTS_UPDATE                                                     */
/* Description   : Procedure called from the UI to update the depot tables             */
/*                 for the receipts against RMA/Internal Requisitions. It calls        */
/*                 RMA_RCV_UPDATE and IO_RCV_UPDATE to process RMA and IO respectively */
/* Called from   : Called from Depot Repair UI                                         */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_order_header_id  NUMBER   Optional   Interal sales order Id                    */
/*    p_internal_order_flag VARCHAR2 Required  Order Type; Possible values -'Y','N'    */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure RECEIPTS_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_internal_order_flag  IN   VARCHAR2,
          p_order_header_id      IN   NUMBER,
          p_repair_line_id       IN   NUMBER,
          p_past_num_of_days     IN   NUMBER DEFAULT NULL); --bug#6753684, 6742512

/*-------------------------------------------------------------------------------------*/
/* Procedure name: RMA_RCV_UPDATE                                                      */
/* Description   : Procedure called from the update API to update the depot tables     */
/*                 for the receipts against RMA. It also logs activities for accept    */
/*                 reject txn lines                                                    */
/* Called from   : Called from RECEIPTS_UPDATE API                                     */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure RMA_RCV_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_repair_line_id       IN   NUMBER,
          p_past_num_of_days     IN   NUMBER DEFAULT NULL); --bug#6753684, 6742512


/*-------------------------------------------------------------------------------------*/
/* Procedure name: IO_RCV_UPDATE                                                       */
/* Description   : Procedure called from the Update api to update the depot tables     */
/*                 for the receipts against Internal Requisitions                      */
/*                 It also logs activities for accept reject txn lines                 */
/* Called from   : Called from RECEIPTS_UPDATE API                                     */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_order_header_id  NUMBER   Optional   Interal sales order Id                    */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure IO_RCV_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_order_header_id      IN   NUMBER );

/*-------------------------------------------------------------------------------------*/
/* Procedure name: IO_RCV_UPDATE_MOVE_OUT                                              */
/* Description   : Procedure called from the Update api to update the depot tables     */
/*                 for the receipts against Internal Requisitions for move out line    */
/*                 It also logs activities for accept reject txn lines                 */
/* Called from   : Called from SHIP_UPDATE API                                         */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_order_header_id  NUMBER   Optional   Internal sales order Id                   */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   24-Apr-2007  swai  Initial Creation.  Bug#5564180 /FP# 5845995                    */
/*-------------------------------------------------------------------------------------*/

Procedure IO_RCV_UPDATE_MOVE_OUT
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_order_header_id      IN   NUMBER );

/*-------------------------------------------------------------------------------------*/
/* Procedure name: SHIP_UPDATE                                                         */
/* Description   : Procedure called from the UI to update the depot tables             */
/*                 for the shipment against regular sales order/Internal Sales Order   */
/*                 It calls SO_SHIP_UPDATE and IO_SHIP_UPDATE  to process sales order  */
/*                 and internal sales order                                            */
/* Called from   : Called from Depot Repair UI                                         */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_order_header_id  NUMBER   Optional   Interal sales order Id                    */
/*    p_internal_order_flag VARCHAR2 Required  Order Type; Possible values -'Y','N'    */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure SHIP_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_internal_order_flag  IN   VARCHAR2,
          p_order_header_id      IN   NUMBER,
          p_repair_line_id       IN   NUMBER,
          p_past_num_of_days     IN   NUMBER DEFAULT NULL); --bug#6753684, 6742512

/*-------------------------------------------------------------------------------------*/
/* Procedure name: SO_SHIP_UPDATE                                                      */
/* Description   : Procedure called from the Update api to update the depot tables     */
/*                 for the shipment against sales order                                */
/*                 It also logs activities for the deliver txn lines                   */
/* Called from   : Called from RECEIPTS_UPDATE API                                     */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure SO_SHIP_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_repair_line_id       IN   NUMBER,
          p_past_num_of_days     IN   NUMBER DEFAULT NULL); --bug#6753684, 6742512

/*-------------------------------------------------------------------------------------*/
/* Procedure name: IO_SHIP_UPDATE                                                      */
/* Description   : Procedure called from the Update api to update the depot tables     */
/*                 for the shipment against Internal sales order                       */
/*                 It also logs activities for the deliver txn lines                   */
/* Called from   : Called from RECEIPTS_UPDATE API                                     */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_order_header_id  NUMBER   Optional   Interal sales order Id                    */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure IO_SHIP_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_order_header_id      IN   NUMBER );

/*-------------------------------------------------------------------------------------*/
/* Procedure name: WIP_UPDATE                                                          */
/* Description  : Procedure called from the UI to update the depot tables              */
/*                for the WIP Job creation/Completion                                  */
/*                                                                                     */
/* Called from   : Called from Depot Repair UI                                         */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*    p_api_version       NUMBER    Required  Api Version number                       */
/*    p_init_msg_list     VARCHAR2  Optional  To Initialize message stack              */
/*    p_commit            VARCHAR2  Optional  Commits in API                           */
/*    p_validation_level  NUMBER    Optional  validation level                         */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   x_return_status     VARCHAR2      Return status of the API                        */
/*   x_msg_count         NUMBER        Number of messages in stack                     */
/*   x_msg_data          VARCHAR2      Error Message from message stack                */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_upd_job_completion        Required   Order Type; Possible values -'Y','N'      */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure WIP_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_upd_job_completion   IN   VARCHAR2,
          p_repair_line_id       IN   NUMBER );

/*-------------------------------------------------------------------------------------*/
/* Procedure name: RECEIPTS_UPDATE_CONC_PROG                                           */
/* Description  : Procedure called by concurrent program to update the depot tables    */
/*                for the receipts against RMA/Internal Requisitions                   */
/*                                                                                     */
/* Called from   : Called from Receipt update concurrent program                       */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   errbuf              VARCHAR2      Error message                                   */
/*   retcode             VARCHAR2      Error Code                                      */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_order_type       VARCHAR2 Required   Order Type; Possible values- 'I','E'      */
/*    p_order_header_id  NUMBER   Optional   Internal sales Order Id                   */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure RECEIPTS_UPDATE_CONC_PROG
           (errbuf              OUT NOCOPY    varchar2,
            retcode             OUT NOCOPY    varchar2,
            p_order_type        IN            varchar2,
            p_order_header_id   IN            number,
            p_repair_line_id    IN            number,
            p_past_num_of_days  IN            number DEFAULT NULL); --bug#6753684, 6742512

/*-------------------------------------------------------------------------------------*/
/* Procedure name: WIP_UPDATE_CONC_PROG                                                */
/* Description  : Procedure called by concurrent program to update the depot tables    */
/*                for the WIP Job Creation/ Completion                                 */
/*                                                                                     */
/* Called from   : Called from Wip Update Concurrent Program                           */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   errbuf              VARCHAR2      Error message                                   */
/*   retcode             VARCHAR2      Error Code                                      */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_upd_job_completion        Required   Order Type; Possible values -'Y','N'      */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure WIP_UPDATE_CONC_PROG
           (errbuf             OUT NOCOPY    varchar2,
            retcode            OUT NOCOPY    varchar2,
            p_repair_line_id     IN          number,
            p_upd_job_completion IN          varchar2);

/*-------------------------------------------------------------------------------------*/
/* Procedure name: SHIP_UPDATE_CONC_PROG                                               */
/* Description  : Procedure called by concurrent program to update the depot tables    */
/*                for the shipment against Sales order/Internal Sales Order            */
/*                                                                                     */
/* Called from   : Called from Receipt update concurrent program                       */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   errbuf              VARCHAR2      Error message                                   */
/*   retcode             VARCHAR2      Eeror Code                                      */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_order_type       VARCHAR2 Required   Order Type; Possible values- 'I','E'      */
/*    p_order_header_id  NUMBER   Optional   Internal sales Order Id                   */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure SHIP_UPDATE_CONC_PROG
            (errbuf             OUT NOCOPY    varchar2,
             retcode            OUT NOCOPY    varchar2,
             p_order_type        IN           varchar2,
             p_order_header_id   IN           number,
             p_repair_line_id    IN           number,
             p_past_num_of_days  IN           number DEFAULT NULL); --bug#6753684, 6742512

/*-------------------------------------------------------------------------------------*/
/* Procedure name: TASK_UPDATE_CONC_PROG                                               */
/* Description  : Procedure called by concurrent program to update the depot tables    */
/*                for the task creation and update                                     */
/*                                                                                     */
/*                                                                                     */
/* Called from   : Called from Task Update concurrent program                          */
/* STANDARD PARAMETERS                                                                 */
/*  In Parameters :                                                                    */
/*                                                                                     */
/*  Output Parameters:                                                                 */
/*   errbuf              VARCHAR2      Error message                                   */
/*   retcode             VARCHAR2      Error Code                                      */
/*                                                                                     */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Changed the API name and logic remains same                   */
/*-------------------------------------------------------------------------------------*/

Procedure TASK_UPDATE_CONC_PROG
           (errbuf             OUT NOCOPY    varchar2,
            retcode            OUT NOCOPY    varchar2,
            p_repair_line_id   IN            number);

 /*-------------------------------------------------------------------------------------*/
 /* Procedure name: PROD_TXN_STATUS_UPD                                                 */
 /* Description  :  Procedure called to update all the logistics lines status to booked */
 /*                                                                                     */
 /*                                                                                     */
 /* Called from   : csd_process_pvt and CSDREPLN.pld                                    */
 /* STANDARD PARAMETERS                                                                 */
 /*  In Parameters :                                                                    */
 /*                                                                                     */
 /*  Output Parameters:                                                                 */
 /*                                                                                     */
 /* NON-STANDARD PARAMETERS                                                             */
 /*   In Parameters                                                                     */
 /*    p_repair_line_id   NUMBER                                                        */
 /*    p_commit           VARCHAR2                                                      */
 /* Output Parm :                                                                       */
 /* Change Hist :                                                                       */
 /*   12/20/04  mshirkol  Initial Creation. Fix for bug#4020651                         */
 /*-------------------------------------------------------------------------------------*/

Procedure  PROD_TXN_STATUS_UPD(p_repair_line_id   in  number,
                               p_commit           in  varchar2);


/*-------------------------------------------------------------------------------------*/
/* Procedure name: UPDATE_LOGISTIC_STATUS_WF                                           */
/* Description   : Procedure called from workflow process to update logistics          */
/*                 line status                                                         */
/*                                                                                     */
/* Called from   : Workflow                                                            */
/* PARAMETERS                                                                          */
/*  IN                                                                                 */
/*                                                                                     */
/*   itemtype  - type of the current item                                              */
/*   itemkey   - key of the current item                                               */
/*   actid     - process activity instance id                                          */
/*   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)             */
/*  OUT	                                                                               */
/*   result                                                                            */
/*       - COMPLETE[:<result>]                                                         */
/*           activity has completed with the indicated result                          */
/*       - WAITING                                                                     */
/*           activity is waiting for additional transitions                            */
/*       - DEFERED                                                                     */
/*           execution should be defered to background                                 */
/*       - NOTIFIED[:<notification_id>:<assigned_user>]                                */
/*           activity has notified an external entity that this                        */
/*           step must be performed.  A call to wf_engine.CompleteActivty              */
/*           will signal when this step is complete.  Optional                         */
/*           return of notification ID and assigned user.                              */
/*       - ERROR[:<error_code>]                                                        */
/*           function encountered an error.                                            */
/* Change Hist :                                                                       */
/*   04/18/06  mshirkol  Initial Creation.  ( Fix for bug#5610891 )                    */
/*-------------------------------------------------------------------------------------*/

Procedure UPDATE_LOGISTIC_STATUS_WF
            (itemtype  in varchar2,
             itemkey   in varchar2,
             actid     in number,
             funcmode  in varchar2,
             resultout in out nocopy varchar2);


End CSD_UPDATE_PROGRAMS_PVT ;

/
