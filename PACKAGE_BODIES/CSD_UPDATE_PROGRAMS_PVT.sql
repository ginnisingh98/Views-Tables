--------------------------------------------------------
--  DDL for Package Body CSD_UPDATE_PROGRAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_UPDATE_PROGRAMS_PVT" as
/* $Header: csddrclb.pls 120.12.12010000.9 2010/04/19 18:33:42 nnadig ship $ */

/* --------------------------------------*/
/* Define global variables               */
/* --------------------------------------*/

G_PKG_NAME  CONSTANT VARCHAR2(30)  := 'CSD_UPDATE_PROGRAMS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(30)  := 'csddrclb.pls';

-- Global variable for storing the debug level
G_debug_level number   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


--bug#8261344
G_CSD_RET_STS_WARNING CONSTANT VARCHAR2(1) := 'W';


-- Added by Vijay 10/22/04
TYPE RCPT_LINES_Rec_Type IS RECORD
(
    rma_number               oe_order_headers_all.order_number%type,
    rma_header_id            oe_order_headers_all.header_id%type ,
    line_id                  oe_order_lines_all.line_id%type ,
    rma_line_number          oe_order_lines_all.line_number%type ,
    inventory_item_id        oe_order_lines_all.inventory_item_id%type,
    org_name                 hr_all_organization_units.name%type ,
    organization_id          rcv_transactions.organization_id%type,
    unit_of_measure          rcv_transactions.unit_of_measure%type,
    received_quantity        rcv_transactions.quantity%type ,
    received_date            rcv_transactions.transaction_date%type ,
    transaction_id           rcv_transactions.transaction_id%type,
    subinventory             rcv_transactions.subinventory%type,
    locator_id               rcv_transactions.locator_id%type,
    transaction_type         rcv_transactions.transaction_type%type,
    ro_serial_number         csd_repairs.serial_number%type ,
    repair_number            csd_repairs.repair_number%type,
    ro_uom                   csd_repairs.unit_of_measure%type,
    ro_item_id               csd_repairs.inventory_item_id%type ,
    product_transaction_id   csd_product_transactions.product_transaction_id%type,
    repair_line_id           csd_product_transactions.repair_line_id%type,
    action_code              csd_product_transactions.action_code%type,
    source_serial_number     csd_product_transactions.source_serial_number%type,
    source_instance_id       csd_product_transactions.source_instance_id%type,
    prod_txn_recd_qty        csd_product_transactions.quantity_received%type,
    estimate_quantity        cs_estimate_details.quantity_required%type ,
    est_order_line_id        cs_estimate_details.order_line_id%type ,
    prod_txn_item_id         cs_estimate_details.inventory_item_id%type
 );

TYPE IO_RCPT_LINES_Rec_Type IS RECORD
(
    product_transaction_id csd_product_transactions.PRODUCT_TRANSACTION_ID%type,
    prod_txn_status        csd_product_transactions.PROD_TXN_STATUS%type,
    repair_line_id         csd_product_transactions.REPAIR_LINE_ID%type,
    order_header_id        csd_product_transactions.ORDER_HEADER_ID%type,
    order_line_id          csd_product_transactions.ORDER_LINE_ID%type,
    req_header_id          csd_product_transactions.REQ_HEADER_ID%type,
    req_line_id            csd_product_transactions.REPAIR_LINE_ID%type,
    prod_txn_rcvd_qty      csd_product_transactions.quantity_received%type,
    ro_qty                 csd_repairs.quantity%type,
    ro_rcvd_qty            csd_repairs.quantity_rcvd%type,
    inventory_item_id      csd_repairs.inventory_item_id%type,
    ro_uom                 csd_repairs.unit_of_measure%type,
    requisition_number     po_requisition_headers_all.segment1%type,
    ordered_quantity       oe_order_lines_all.ordered_quantity%type,
	order_number           oe_order_headers_all.order_number%type
 );

TYPE SHIP_LINES_Rec_Type IS RECORD
(
    shipped_serial_num     wsh_serial_numbers.fm_serial_number%type,
    lot_number             wsh_delivery_details.lot_number%type ,
    revision               wsh_delivery_details.revision%type ,
    subinv                 wsh_delivery_details.subinventory%type ,
    requested_quantity     wsh_delivery_details.requested_quantity%type,
    shipped_quantity       wsh_delivery_details.shipped_quantity%type,
    delivery_detail_id     wsh_delivery_details.delivery_detail_id%type,
    shipped_uom            wsh_delivery_details.requested_quantity_uom%type ,
    inventory_item_id      wsh_delivery_details.inventory_item_id%type ,
    organization_id        wsh_delivery_details.organization_id%type,
    order_number           wsh_delivery_details.source_header_number%type ,
    sales_order_header     wsh_delivery_details.source_header_id%type ,
    locator_id             wsh_delivery_details.locator_id%type,
    order_line_number      oe_order_lines_all.line_number%type ,
    date_shipped           oe_order_lines_all.actual_shipment_date%type ,
    line_id                oe_order_lines_all.line_id%type ,             --Bug#6779806
    repair_number          csd_repairs.repair_number%type,
    repair_line_id         csd_repairs.repair_line_id%type,
    ro_uom                 csd_repairs.unit_of_measure%type ,
    ro_item_id             csd_repairs.inventory_item_id%type ,
    estimate_quantity      cs_estimate_details.quantity_required%type ,
    prod_txn_serial_num    csd_product_transactions.source_serial_number%type ,
    source_instance_id     csd_product_transactions.source_instance_id%type,
    product_transaction_id csd_product_transactions.product_transaction_id%type,
    action_code            csd_product_transactions.action_code%type,
    delivery_name          wsh_new_deliveries.name%type ,
    org_name               hr_all_organization_units.name%type
);
TYPE IO_SHIP_LINES_Rec_Type IS RECORD
(
 header_id                    oe_order_lines_all.header_id%type,
 line_id                      oe_order_lines_all.line_id%type,
 ordered_quantity             oe_order_lines_all.ordered_quantity%type,
 req_header_id                oe_order_lines_all.source_document_id%type ,
 req_line_id                  oe_order_lines_all.source_document_line_id%type ,
 req_number                   oe_order_lines_all.orig_sys_document_ref%type ,
 inventory_item_id           oe_order_lines_all.inventory_item_id%type,
 shipment_date                oe_order_lines_all.actual_shipment_date%type ,
 delivery_detail_id          wsh_delivery_details.delivery_detail_id%type,
 shipped_quantity             wsh_delivery_details.shipped_quantity%type,
 del_line_serial_num          wsh_serial_numbers.fm_serial_number%type ,
 lot_number                   wsh_delivery_details .lot_number%type,
 subinventory                 wsh_delivery_details .subinventory%type,
 locator_id                   wsh_delivery_details .locator_id%type,
 organization_id              wsh_delivery_details .organization_id%type,
 released_status              wsh_delivery_details .released_status%type,
 requested_quantity           wsh_delivery_details .requested_quantity%type,
 order_number                 wsh_delivery_details .source_header_number%type ,
 source_organization_id       po_requisition_lines_all.source_organization_id%type,
 source_subinventory          po_requisition_lines_all.source_subinventory%type,
 destination_organization_id  po_requisition_lines_all.destination_organization_id%type,
 destination_subinventory     po_requisition_lines_all.destination_subinventory%type,
 serial_number_control_code   mtl_system_items.serial_number_control_code%type,
 lot_control_code             mtl_system_items.lot_control_code%type,
 requisition_number           po_requisition_headers_all.segment1%type ,
 source_org_name              hr_all_organization_units.name%type ,
 destination_org_name         hr_all_organization_units.name%type ,
 txn_source_id                mtl_txn_request_lines.txn_source_id%type
);

TYPE JOB_COMPLETION_Rec_Type IS RECORD
(
    repair_job_xref_id         CSD_REPAIR_JOB_XREF.repair_job_xref_id%type,
    wip_entity_id              CSD_REPAIR_JOB_XREF.wip_entity_id%type,
    repair_line_id             CSD_REPAIR_JOB_XREF.repair_line_id%type,
    allocated_comp_qty         CSD_REPAIR_JOB_XREF.quantity_completed%type ,
    allocated_job_qty          CSD_REPAIR_JOB_XREF.quantity%type ,
    organization_id            CSD_REPAIR_JOB_XREF.organization_id%type,
    repair_number              CSD_REPAIRS.repair_number%type,
    promise_date               CSD_REPAIRS.promise_date%type,
    ro_serial_num              CSD_REPAIRS.serial_number%type ,
    ro_item_id                 CSD_REPAIRS.inventory_item_id%type ,
    job_completed_qty          WIP_DISCRETE_JOBS.quantity_completed%type ,
    job_qty                    WIP_DISCRETE_JOBS.start_quantity%type ,
    date_completed             WIP_DISCRETE_JOBS.date_completed%type,
    job_item_id                WIP_DISCRETE_JOBS.primary_item_id%type,
    wip_entity_name            WIP_ENTITIES.wip_entity_name%type,
    serial_number_control_code MTL_SYSTEM_ITEMS.serial_number_control_code%type

);

TYPE JOB_CREATION_Rec_Type IS RECORD
(
 repair_job_xref_id CSD_REPAIR_JOB_XREF.repair_job_xref_id%type,
 repair_line_id     CSD_REPAIR_JOB_XREF.repair_line_id%type,
 organization_id    CSD_REPAIR_JOB_XREF.organization_id%type,
 allocated_job_qty  CSD_REPAIR_JOB_XREF.quantity%type ,
 wip_entity_id      WIP_ENTITIES.wip_entity_id%type,
 wip_entity_name    WIP_ENTITIES.wip_entity_name%type,
 job_qty            WIP_DISCRETE_JOBS.start_quantity%type ,
 creation_date      WIP_DISCRETE_JOBS.creation_date%type
);

--------------------
 PROCEDURE check_for_cancelled_order(p_repair_line_id NUMBER);
/*-------------------------------------------------------------------------------------*/
/* Function  name: DEBUG                                                               */
/* Description   : Logs the debug message                                              */
/* Called from   : Called from Update API                                              */
/*                                                                                     */
/* STANDARD PARAMETERS                                                                 */
/*   In Parameters :                                                                   */
/*      p_message        Required    Debug message that needs to be logged             */
/*      p_mod_name       Required    Module name                                       */
/*      p_severity_level Required    Severity level                                    */
/*   Output Parameters:                                                                */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*   Out parameters                                                                    */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure DEBUG
          (p_message  in varchar2,
           p_mod_name in varchar2,
           p_severity_level in number
           ) IS

  -- Variables used in FND Log
  l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
  l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
  l_event_level  number   := FND_LOG.LEVEL_EVENT;
  l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;

BEGIN

  IF p_severity_level = 1 THEN
    IF ( l_stat_level >= G_debug_level) THEN
        FND_LOG.STRING(l_stat_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 2 THEN
    IF ( l_proc_level >= G_debug_level) THEN
        FND_LOG.STRING(l_proc_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 3 THEN
    IF ( l_event_level >= G_debug_level) THEN
        FND_LOG.STRING(l_event_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 4 THEN
    IF ( l_excep_level >= G_debug_level) THEN
        FND_LOG.STRING(l_excep_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 5 THEN
    IF ( l_error_level >= G_debug_level) THEN
        FND_LOG.STRING(l_error_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 6 THEN
    IF ( l_unexp_level >= G_debug_level) THEN
        FND_LOG.STRING(l_unexp_level,p_mod_name,p_message);
    END IF;
  END IF;

END DEBUG;

/*-------------------------------------------------------------------------------------*/
/* Function  name: INIT_ACTIVITY_REC                                                   */
/* Description   : Initialize the activity record                                      */
/* Called from   : Called from Update API                                              */
/*                                                                                     */
/* STANDARD PARAMETERS                                                                 */
/*   In Parameters :                                                                   */
/*   Output Parameters:                                                                */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*   Out parameters                                                                    */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Function INIT_ACTIVITY_REC RETURN csd_update_programs_pvt.activity_rec_type IS
   l_activity_rec  activity_rec_type;
BEGIN
      -- Initialize all the in the activity record
      l_activity_rec.REPAIR_HISTORY_ID  := NULL;
      l_activity_rec.REPAIR_LINE_ID     := NULL;
      l_activity_rec.REQUEST_ID         := NULL;
      l_activity_rec.PROGRAM_ID         := NULL;
      l_activity_rec.PROGRAM_APPLICATION_ID  := NULL;
      l_activity_rec.PROGRAM_UPDATE_DATE     := NULL;
      l_activity_rec.EVENT_CODE         := NULL;
      l_activity_rec.ACTION_CODE        := NULL;
      l_activity_rec.EVENT_DATE         := NULL;
      l_activity_rec.QUANTITY           := NULL;
      l_activity_rec.PARAMN1            := NULL;
      l_activity_rec.PARAMN2            := NULL;
      l_activity_rec.PARAMN3            := NULL;
      l_activity_rec.PARAMN4            := NULL;
      l_activity_rec.PARAMN5            := NULL;
      l_activity_rec.PARAMN6            := NULL;
      l_activity_rec.PARAMN7            := NULL;
      l_activity_rec.PARAMN8            := NULL;
      l_activity_rec.PARAMN9            := NULL;
      l_activity_rec.PARAMN10           := NULL;
      l_activity_rec.PARAMC1            := NULL;
      l_activity_rec.PARAMC2            := NULL;
      l_activity_rec.PARAMC3            := NULL;
      l_activity_rec.PARAMC4            := NULL;
      l_activity_rec.PARAMC5            := NULL;
      l_activity_rec.PARAMC6            := NULL;
      l_activity_rec.PARAMC7            := NULL;
      l_activity_rec.PARAMC8            := NULL;
      l_activity_rec.PARAMC9            := NULL;
      l_activity_rec.PARAMC10           := NULL;
      l_activity_rec.PARAMD1            := NULL;
      l_activity_rec.PARAMD2            := NULL;
      l_activity_rec.PARAMD3            := NULL;
      l_activity_rec.PARAMD4            := NULL;
      l_activity_rec.PARAMD5            := NULL;
      l_activity_rec.PARAMD6            := NULL;
      l_activity_rec.PARAMD7            := NULL;
      l_activity_rec.PARAMD8            := NULL;
      l_activity_rec.PARAMD9            := NULL;
      l_activity_rec.PARAMD10           := NULL;
      l_activity_rec.ATTRIBUTE_CATEGORY := NULL;
      l_activity_rec.ATTRIBUTE1         := NULL;
      l_activity_rec.ATTRIBUTE2         := NULL;
      l_activity_rec.ATTRIBUTE3         := NULL;
      l_activity_rec.ATTRIBUTE4         := NULL;
      l_activity_rec.ATTRIBUTE5         := NULL;
      l_activity_rec.ATTRIBUTE6         := NULL;
      l_activity_rec.ATTRIBUTE7         := NULL;
      l_activity_rec.ATTRIBUTE8         := NULL;
      l_activity_rec.ATTRIBUTE9         := NULL;
      l_activity_rec.ATTRIBUTE10        := NULL;
      l_activity_rec.ATTRIBUTE11        := NULL;
      l_activity_rec.ATTRIBUTE12        := NULL;
      l_activity_rec.ATTRIBUTE13        := NULL;
      l_activity_rec.ATTRIBUTE14        := NULL;
      l_activity_rec.ATTRIBUTE15        := NULL;
      l_activity_rec.OBJECT_VERSION_NUMBER   := NULL;

  -- Return the initialized activity record
  RETURN l_activity_rec;
END INIT_ACTIVITY_REC;

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
/*     p_to_uom          VARCHAR2 Required   RO Unit of measure                        */
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
           p_from_uom_code   in varchar2,
           p_from_quantity   IN number,
           x_result_quantity OUT NOCOPY number
           ) IS

  -- Standard variables
  l_api_name         CONSTANT VARCHAR2(30)   := 'CONVERT_TO_RO_UOM';
  l_api_version      CONSTANT NUMBER         := 1.0;

  -- Variables used in the API
  l_from_uom_code    mtl_units_of_measure.uom_code%type;

  -- Variables used in FND Log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.convert_to_ro_uom';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT  CONV_TO_RO_UOM;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Api body starts
    Debug('At the Beginning of Convert_to_RO_uom',l_mod_name,1);

    -- Derive the uom code from uom name
    IF (NVL(p_from_uom_code, 'ZZZ') = 'ZZZ') THEN
      Begin
        select uom_code
        into l_from_uom_code
        from mtl_units_of_measure
        where unit_of_measure = p_from_uom;
      Exception
        WHEN NO_DATA_FOUND THEN
          IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_UOM_MISSING');
             fnd_message.set_token('UOM',p_from_uom);
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
          ELSE
             fnd_message.set_name('CSD','CSD_UOM_MISSING');
             fnd_message.set_token('UOM',p_from_uom);
             fnd_msg_pub.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        WHEN TOO_MANY_ROWS THEN
          IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_MANY_UOM_FOUND');
             fnd_message.set_token('UOM',p_from_uom);
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
          ELSE
             fnd_message.set_name('CSD','CSD_MANY_UOM_FOUND');
             fnd_message.set_token('UOM',p_from_uom);
             fnd_msg_pub.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      End;
   Else
       -- assign the uom code if it is passed to the api
       l_from_uom_code := p_from_uom_code;
   END IF;

    -- Call the inventory api to convert the quantity
    -- from one UOM to another UOM.
    -- Only if the repair order UOM is different than the
    -- l_from_uom_code, the inv api is called
   IF p_to_uom_code <> l_from_uom_code THEN
        x_result_quantity := inv_convert.inv_um_convert(
                                     p_item_id ,
                                     2,
                                     p_from_quantity,
                                     l_from_uom_code,
                                     p_to_uom_code,
                                     null,
                                     null);

       -- if the inv_convert api fails then it returns -99999
       IF  x_result_quantity < 0 then
          IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_INV_UM_CONV_FAILED');
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
          ELSE
             fnd_message.set_name('CSD','CSD_INV_UM_CONV_FAILED');
             fnd_msg_pub.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   ELSE
       x_result_quantity := p_from_quantity;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR exception',l_mod_name,4);
          ROLLBACK TO CONV_TO_RO_UOM;
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR exception',l_mod_name,4);
          ROLLBACK TO CONV_TO_RO_UOM;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
          Debug('In OTHERS exception',l_mod_name,4);
          ROLLBACK TO CONV_TO_RO_UOM;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
End CONVERT_TO_RO_UOM;

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
          p_activity_rec         IN   activity_rec_type
         ) IS

  -- Standard Variables
  l_api_name          CONSTANT VARCHAR2(30)   := 'LOG_ACTIVITY';
  l_api_version       CONSTANT NUMBER         := 1.0;

  -- Variables used in API
  l_rep_hist_id       NUMBER;

  -- Variable used in FND log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.log_activity';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  LOG_ACTIVITY;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug messages
   Debug('At the beginning of log_activity api',l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Debug messages
   Debug('p_EVENT_CODE ='||p_activity_rec.EVENT_CODE,l_mod_name,1);
   Debug('p_activity_rec.paramn1 ='||p_activity_rec.paramn1,l_mod_name,1);
   Debug('p_activity_rec.paramn2 ='||p_activity_rec.paramn2,l_mod_name,1);

   -- need not validate the values passed in activity record
   -- as these values are validated by the calling API
   -- If this API is used by other programs, then we need to
   -- validate the values passed in the activity record

   -- Debug messages
   Debug('Calling Validate_And_Write',l_mod_name,2);

   -- Since the repair history Id is in/out parameter
   -- I need to define a variable and pass the variable to API
   l_rep_hist_id := p_activity_rec.REPAIR_HISTORY_ID;

    -- Calling Validate_And_Write to log activity
    -- Except for the who columns, all the values from
    -- p_activity_rec are passed to the Validate_And_Write api.
    CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
                                P_Api_Version_Number      => p_api_version,
                                P_Init_Msg_List           => p_init_msg_list,
                                P_Commit                  => p_commit,
                                p_validation_level        => null, --p_validation_level,
                                p_action_code             => p_activity_rec.action_code,
                                px_REPAIR_HISTORY_ID      => l_rep_hist_id,
                                p_OBJECT_VERSION_NUMBER   => p_activity_rec.object_version_number,
                                p_REQUEST_ID              => p_activity_rec.request_id,
                                p_PROGRAM_ID              => p_activity_rec.program_id,
                                p_PROGRAM_APPLICATION_ID  => p_activity_rec.program_application_id,
                                p_PROGRAM_UPDATE_DATE     => p_activity_rec.program_update_date,
                                p_CREATED_BY              => fnd_global.user_id,
                                p_CREATION_DATE           => sysdate,
                                p_LAST_UPDATED_BY         => fnd_global.user_id,
                                p_LAST_UPDATE_DATE        => sysdate,
                                p_REPAIR_LINE_ID          => p_activity_rec.repair_line_id,
                                p_EVENT_CODE  => p_activity_rec.event_code,
                                p_EVENT_DATE  => p_activity_rec.event_date,
                                p_QUANTITY    => p_activity_rec.quantity,
                                p_PARAMN1     => p_activity_rec.paramn1,
                                p_PARAMN2     => p_activity_rec.paramn2,
                                p_PARAMN3     => p_activity_rec.paramn3,
                                p_PARAMN4     => p_activity_rec.paramn4,
                                p_PARAMN5     => p_activity_rec.paramn5,
                                p_PARAMN6     => p_activity_rec.paramn6,
                                p_PARAMN7     => p_activity_rec.paramn7,
                                p_PARAMN8     => p_activity_rec.paramn8,
                                p_PARAMN9     => p_activity_rec.paramn9,
                                p_PARAMN10    => p_activity_rec.paramn10,
                                p_PARAMC1     => p_activity_rec.paramc1,
                                p_PARAMC2     => p_activity_rec.paramc2,
                                p_PARAMC3     => p_activity_rec.paramc3,
                                p_PARAMC4     => p_activity_rec.paramc4,
                                p_PARAMC5     => p_activity_rec.paramc5,
                                p_PARAMC6     => p_activity_rec.paramc6,
                                p_PARAMC7     => p_activity_rec.paramc7,
                                p_PARAMC8     => p_activity_rec.paramc8,
                                p_PARAMC9     => p_activity_rec.paramc9,
                                p_PARAMC10    => p_activity_rec.paramc10,
                                p_PARAMD1     => p_activity_rec.paramd1,
                                p_PARAMD2     => p_activity_rec.paramd2,
                                p_PARAMD3     => p_activity_rec.paramd3,
                                p_PARAMD4     => p_activity_rec.paramd4,
                                p_PARAMD5     => p_activity_rec.paramd5,
                                p_PARAMD6     => p_activity_rec.paramd6,
                                p_PARAMD7     => p_activity_rec.paramd7,
                                p_PARAMD8     => p_activity_rec.paramd8,
                                p_PARAMD9     => p_activity_rec.paramd9,
                                p_PARAMD10    => p_activity_rec.paramd10,
                                p_ATTRIBUTE_CATEGORY  => p_activity_rec.attribute_category,
                                p_ATTRIBUTE1    => p_activity_rec.attribute1,
                                p_ATTRIBUTE2    => p_activity_rec.attribute2,
                                p_ATTRIBUTE3    => p_activity_rec.attribute3,
                                p_ATTRIBUTE4    => p_activity_rec.attribute4,
                                p_ATTRIBUTE5    => p_activity_rec.attribute5,
                                p_ATTRIBUTE6    => p_activity_rec.attribute6,
                                p_ATTRIBUTE7    => p_activity_rec.attribute7,
                                p_ATTRIBUTE8    => p_activity_rec.attribute8,
                                p_ATTRIBUTE9    => p_activity_rec.attribute9,
                                p_ATTRIBUTE10   => p_activity_rec.attribute10,
                                p_ATTRIBUTE11   => p_activity_rec.attribute11,
                                p_ATTRIBUTE12   => p_activity_rec.attribute12,
                                p_ATTRIBUTE13   => p_activity_rec.attribute13,
                                p_ATTRIBUTE14   => p_activity_rec.attribute14,
                                p_ATTRIBUTE15   => p_activity_rec.attribute15,
                                p_LAST_UPDATE_LOGIN => null,
                                X_Return_Status => x_return_status,
                                X_Msg_Count     => x_msg_count,
                                X_Msg_Data      => x_msg_data  );

   -- Debug messages
   Debug('x_return_status from Validate_And_Write ='||x_return_status,l_mod_name,2);

   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        Debug('Validate_And_Write api failed ',l_mod_name,4);
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR exception',l_mod_name,4);
          ROLLBACK TO  LOG_ACTIVITY;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR exception',l_mod_name,4);
          ROLLBACK TO  LOG_ACTIVITY;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('In OTHERS exception',l_mod_name,4 );
          ROLLBACK TO  LOG_ACTIVITY;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END  LOG_ACTIVITY;

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

Procedure  JOB_COMPLETION_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_repair_line_id       IN   NUMBER
	  ) IS

  -- Standard Variables
  l_api_name          CONSTANT VARCHAR2(30)   := 'WIP_UPDATE';
  l_api_version       CONSTANT NUMBER         := 1.0;

  -- Variables used in the program
  l_rep_hist_id       NUMBER;
  l_total_rec         NUMBER:= 0;
  l_completed_qty     NUMBER;
  l_remaining_qty     NUMBER;
  l_total_qty         NUMBER;
  l_update_qty        NUMBER;
  l_count             NUMBER;
  l_dummy             varchar2(30);
  l_commit_size       NUMBER := 500;
  l_msg_text          VARCHAR2(2000);
  l_mtl_trx_id        NUMBER;
  l_mtl_trx_date      DATE;
  l_mtl_serial_num    mtl_unit_transactions.serial_number%type;
  l_mtl_subinv        mtl_material_transactions.subinventory_code%type;
  l_SN_mismatch       BOOLEAN := FALSE;

  l_ro_count NUMBER ; ---Added by vijay to put ro count in JC event

  -- Define a record of activity_rec_type
  l_activity_rec      activity_rec_type;

  -- Variable used in FND log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.job_completion_update';

  -- User defined exception
  SKIP_RECORD   EXCEPTION;

   -- This cursor gets all the records in csd_repair_job_xref for which
   -- the completed qty is less than the allocated
   -- for the given repair line id,  11/9/04: Vijay
   Cursor REPAIR_JOBS( p_rep_line_id in number )IS
    SELECT
      crj.repair_job_xref_id,
      crj.wip_entity_id,
      crj.repair_line_id,
      crj.quantity_completed allocated_comp_qty,
      crj.quantity allocated_job_qty,
      crj.organization_id,
      cra.repair_number,
      cra.promise_date,
      cra.serial_number ro_serial_num,
      cra.inventory_item_id ro_item_id,
      wdj.quantity_completed job_completed_qty,
      wdj.start_quantity job_qty,
      wdj.date_completed,
      wdj.primary_item_id job_item_id,
      we.wip_entity_name,
      mtl.serial_number_control_code
    from CSD_REPAIR_JOB_XREF crj,
         CSD_REPAIRS cra,
         WIP_DISCRETE_JOBS wdj,
         WIP_ENTITIES we,
         MTL_SYSTEM_ITEMS mtl
    where wdj.wip_entity_id  = crj.wip_entity_id
     and  we.wip_entity_id   = wdj.wip_entity_id
     and  crj.repair_line_id = cra.repair_line_id
     and  crj.organization_id = mtl.organization_id
     and  crj.inventory_item_id = mtl.inventory_item_id
     and  (crj.quantity - nvl(crj.quantity_completed,0)) > 0
     and   cra.repair_line_id  = p_rep_line_id
     and  nvl(wdj.quantity_completed,0) > 0
     order by crj.wip_entity_id, cra.promise_date;

   -- This cursor gets all the records in csd_repair_job_xref for which
   -- the completed qty is less than the allocated
   -- all records irrespective of rep_line_id 11/9/04: Vijay
   Cursor REPAIR_JOBS_ALL IS
    SELECT
      crj.repair_job_xref_id,
      crj.wip_entity_id,
      crj.repair_line_id,
      crj.quantity_completed allocated_comp_qty,
      crj.quantity allocated_job_qty,
      crj.organization_id,
      cra.repair_number,
      cra.promise_date,
      cra.serial_number ro_serial_num,
      cra.inventory_item_id ro_item_id,
      wdj.quantity_completed job_completed_qty,
      wdj.start_quantity job_qty,
      wdj.date_completed,
      wdj.primary_item_id job_item_id,
      we.wip_entity_name,
      mtl.serial_number_control_code
    from CSD_REPAIR_JOB_XREF crj,
         CSD_REPAIRS cra,
         WIP_DISCRETE_JOBS wdj,
         WIP_ENTITIES we,
         MTL_SYSTEM_ITEMS mtl
    where wdj.wip_entity_id  = crj.wip_entity_id
     and  we.wip_entity_id   = wdj.wip_entity_id
     and  crj.repair_line_id = cra.repair_line_id
     and  crj.organization_id = mtl.organization_id
     and  crj.inventory_item_id = mtl.inventory_item_id
     and  (crj.quantity - nvl(crj.quantity_completed,0)) > 0
     and  nvl(wdj.quantity_completed,0) > 0
     order by crj.wip_entity_id, cra.promise_date;

   -- Added by Vijay 11/9/04
   JOB JOB_COMPLETION_REC_TYPE;


   -- This cursor gets all the material txns for the wip_entity_id
   -- WIP Completion Txn Types has transaction_action_id=31
   -- and transaction_source_type_id = 5
   Cursor Get_mtl_txns (p_entity_id in number) IS
    select subinventory_code,
           transaction_quantity,
           transaction_id,
           transaction_date
    from  mtl_material_transactions mtl
    where mtl.transaction_source_id      = p_entity_id
     and  mtl.transaction_source_type_id = 5  -- Job or Schedule
     and  mtl.transaction_action_id      = 31;-- Wip Assembly Completion


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  JOB_COMPLETION_UPDATE;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug messages
   Debug('At the Beginning of JOB_COMPLETION_UPDATE',l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Keep the record count
   l_count := 0;

   -- Code does not handle the following scenarios
   --   1. Cancelled WIP Job
   --        Eric is going to check why a Job is cancelled. Based on that
   --        a course of action will be taken
   --   2. Overcompletion
   --        It has decided to ignore the overcompleted quantity
   --   3. Return to WIP Job after completion
   --        It needs to be handled asap
   -- It will be discussed with PM and done as phase II project

   -- Get all the records that have job completed
   --FOR JOB in Repair_Jobs( p_repair_line_id )
   IF(p_repair_line_Id is null) THEN
     OPEN Repair_Jobs_ALL;
   ELSE
     OPEN Repair_Jobs(p_repair_line_id);
   END IF;

   LOOP
    BEGIN

      IF(p_repair_line_Id is null) THEN
        FETCH  Repair_Jobs_ALL INTO Job;
        EXIT WHEN Repair_Jobs_ALL%NOTFOUND;
      ELSE
        FETCH Repair_Jobs INTO Job;
        EXIT WHEN Repair_Jobs%NOTFOUND;
      END IF;
      -- savepoint
      SAVEPOINT  Job_Completion;

          -- Debug messages
       Debug('wip_entity_id      ='||TO_CHAR(job.wip_entity_id),l_mod_name,1);
  	   Debug('repair_line_id     ='||TO_CHAR(job.repair_line_id),l_mod_name,1);
       Debug('quantity_completed ='||TO_CHAR(job.job_completed_qty),l_mod_name,1);
	   Debug('quantity           ='||TO_CHAR(job.job_qty),l_mod_name,1);

	   --Get the sum of completed quantity from csd_repair_job_xref
	   select nvl(sum(quantity_completed),0), count(repair_line_id) ---Added by vijay
         into l_completed_qty, l_ro_count   ----------------------------to put ro count in JC event
         from csd_repair_job_xref
         where wip_entity_id = JOB.wip_entity_id;

         l_ro_count := nvl(l_ro_Count,0); --Added by vijay to put ro count in JC event

         -- Calculate the remaining qty to be processed
         -- Using NVL in SQL statement is much expensive than in a variable
   	    l_remaining_qty := nvl(JOB.job_completed_qty,0) - l_completed_qty;

         -- Debug messages
         Debug('l_remaining_qty    ='||TO_CHAR(l_remaining_qty),l_mod_name,1);
   	    Debug('l_completed_qty    ='||TO_CHAR(l_completed_qty),l_mod_name,1);

         -- Using NVL in SQL statement is much expensive than in a variable
         IF ((nvl(JOB.allocated_job_qty,0) - nvl(JOB.allocated_comp_qty,0)) <= l_remaining_qty) then
	         l_remaining_qty := (nvl(JOB.allocated_job_qty,0) - nvl(JOB.allocated_comp_qty,0)) ;
         END IF;

          -- Debug messages
         Debug('l_remaining_qty        ='||TO_CHAR(l_remaining_qty),l_mod_name,1);
         Debug('Serial Num Control Code='||JOB.serial_number_control_code,l_mod_name,1);

          -- Only if the remaining qty > 0 then process the record
          -- It needs to be processed differently depending on the item definition
          --   1. Serialized at inventory receipt and Pre-defined
          --   2. Non-Serialized and Serial Control at sales order issue
          --
          -- If the item is pre-defined or at inventory receipt, the serial number
          -- is entered while completing the job. The serial number is stored in
          -- mtl_unit_transactions table. So the serial number can be matched to
          -- the serial number on repair order and the repair order is updated
          -- with the completed qty. But if the wip job is for upgrade, then the
          -- repair order item is different then the item on the WIP job. So if
          -- it is upgrade then the completion qty is updated based on the
          -- promise date
          --
          -- If the item is non-serialized and serialized at SO issue then
          -- the completion qty is updated based on the promise date

         IF l_remaining_qty > 0 then
            IF JOB.serial_number_control_code in (2,5) THEN
                -- Serialized at inventory receipt and Pre-defined
                -- In WIP_DISCRETE_JOBS
                --   Job Name    Job Id      Start Qty   Completion Qty   Completion Subinv
                --    W1          1121         10             10
                --
                --  MTL_MATERIAL_TRANSACTIONS
                --    Txn Id   Job ID   Txn Qty    Completion Subinv
                --      M1      1121      2           FGI
                --      M2      1121      8           Stores
                --
                -- MTL_UNIT_TRANSACTIONS
                --
                --   Txn Id  Serial Number   Subinv
                --     M1       SN1           FGI
                --     M2       SN2           FGI
                --     .         .
                --     M10      SN10          Stores
                -- The wip job is created for the same item on the repair order
			 -- It is not an upgrade
                IF JOB.ro_item_id = JOB.job_item_id THEN
                   BEGIN
                     Select mt.transaction_id,
                            mt.transaction_date,
                            mt.subinventory_code
                     into   l_mtl_trx_id,
                            l_mtl_trx_date,
                            l_mtl_subinv
                     from  mtl_material_transactions mt,
                           mtl_unit_transactions mut
                     where mt.transaction_id = mut.transaction_id
                      and  mt.transaction_source_id      = JOB.wip_entity_id
                      and  mt.transaction_source_type_id = 5  -- Job or Schedule
                      and  mt.transaction_action_id      = 31 -- Wip Assembly Completion
                      and  mut.serial_number             = JOB.ro_serial_num
                      and  mt.inventory_item_id          = JOB.ro_item_id;

                        -- Update csd_repair_job_xref with qty completed
                        update csd_repair_job_xref
                        set quantity_completed = nvl(quantity_completed,0) + 1,
		                  object_version_number = object_version_number+1,
                            last_update_date   = sysdate,
                            last_updated_by    = fnd_global.user_id,
                            last_update_login  = fnd_global.login_id
                        where repair_job_xref_id = JOB.repair_job_xref_id;
                        IF SQL%NOTFOUND THEN
                            IF ( l_error_level >= G_debug_level)  THEN
                               FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                               FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',JOB.repair_job_xref_id );
                               FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                            ELSE
                               FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                               FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',JOB.repair_job_xref_id );
                               FND_MSG_PUB.ADD;
                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                        End IF;

                        -- Initialize the activity rec
                        l_activity_rec := INIT_ACTIVITY_REC ;

                         -- Assign the values for activity record
                        l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                        l_activity_rec.REPAIR_LINE_ID :=  JOB.repair_line_id;
                        l_activity_rec.EVENT_CODE     :=  'JC';
                        l_activity_rec.ACTION_CODE    :=  0;
                        l_activity_rec.EVENT_DATE     :=  l_mtl_trx_date;
                        l_activity_rec.QUANTITY       :=  JOB.job_completed_qty;
                        l_activity_rec.PARAMN1        :=  JOB.organization_id;
                        l_activity_rec.PARAMN3        :=  l_mtl_trx_id;
                        l_activity_rec.PARAMN4        :=  JOB.wip_entity_id;
                        l_activity_rec.PARAMN5        :=  1;
                        l_activity_rec.PARAMN6        :=  l_ro_count;
                        l_activity_rec.PARAMC1        :=  l_mtl_subinv;
                        l_activity_rec.PARAMC2        :=  JOB.wip_entity_name;
                        l_activity_rec.PARAMC3        :=  JOB.ro_serial_num;
                        l_activity_rec.OBJECT_VERSION_NUMBER := null;

                        Debug('Calling LOG_ACTIVITY',l_mod_name,2);

                        -- Calling LOG_ACTIVITY for logging activity
                        -- for job completion
                        LOG_ACTIVITY
                            ( p_api_version     => p_api_version,
                              p_commit          => p_commit,
                              p_init_msg_list   => p_init_msg_list,
                              p_validation_level => p_validation_level,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_activity_rec    => l_activity_rec );

                       Debug('x_return_status from LOG_ACTIVITY ='||x_return_status,l_mod_name,2);
                       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                          Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;
                        l_SN_mismatch := FALSE;
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        l_SN_mismatch := TRUE;
                   END;

                   -- While issuing the assembly to WIP Job, user could issue
			    -- a wrong serial number. So that could result in mismatch
			    -- of serial number
			    -- Repair Job XRef
			    -- RO Num  Item   Qty  Job  Serial Num
			    -- R1       A      1    W1     Sn1
			    -- R2       A      1    W1     Sn2
			    -- R3       A      1    W1     Sn3
			    --
			    -- Wip Discrete Jobs
			    --  Job  Start Qty  Comp Qty
			    --   W1      3         3
			    --
			    -- MTL Material Transactions
			    -- Mtl Txn Id   Txn Qty   SubInv
			    --   M1           2        FGI
			    --   M2           1        Stores
			    -- MTL Unit Txns
			    -- Mtl Txn Id    Serial Num
			    --   M1            Sn2
			    --   M1            Sn9
			    --   M2            Sn11
			    -- It needs to be matched in the following manner
			    -- RO Num  RO Serial Num   Comp Serial Num
			    -- R1            Sn1         Sn9
			    -- R2            Sn2         Sn2
			    -- R3            Sn3         Sn11
                   IF l_SN_mismatch THEN
                      BEGIN
					Select mt.transaction_id,
                                mt.transaction_date,
                                mut.serial_number,
                                mt.subinventory_code
                         into   l_mtl_trx_id,
                                l_mtl_trx_date,
                                l_mtl_serial_num,
                                l_mtl_subinv
                         from  mtl_material_transactions mt,
                               mtl_unit_transactions mut
                         where mt.transaction_id = mut.transaction_id
                          and  mt.transaction_source_id      = JOB.wip_entity_id
                          and  mt.transaction_source_type_id = 5  -- Job or Schedule
                          and  mt.transaction_action_id      = 31 -- Wip Assembly Completion
                          and  mut.serial_number not in (select crh.paramc3
                                                         from   csd_repair_history crh,
                                                                csd_repair_job_xref crj
                                                         where  crh.repair_line_id = crj.repair_line_id
                                                          and   crj.wip_entity_id  = JOB.wip_entity_id
                                                          and   crh.event_code     = 'JC')
                          and  mut.serial_number not in (Select cra.serial_number
					                                from   csd_repairs cra,
											         csd_repair_job_xref crj
											  where cra.repair_line_id = crj.repair_line_id
											   and  crj.wip_entity_id  = JOB.wip_entity_id
											   and  cra.serial_number is not null)
		     		 and rownum = 1;

                        -- Update csd_repair_job_xref with qty completed
                        update csd_repair_job_xref
                        set quantity_completed = nvl(quantity_completed,0) + 1,
		                  object_version_number = object_version_number+1,
                            last_update_date   = sysdate,
                            last_updated_by    = fnd_global.user_id,
                            last_update_login  = fnd_global.login_id
                        where repair_job_xref_id = JOB.repair_job_xref_id;
                        IF SQL%NOTFOUND THEN
                            IF ( l_error_level >= G_debug_level)  THEN
                               FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                               FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',JOB.repair_job_xref_id );
                               FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                            ELSE
                               FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                               FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',JOB.repair_job_xref_id );
                               FND_MSG_PUB.ADD;
                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                        End IF;

				    -- Initialize the activity rec
                        l_activity_rec := INIT_ACTIVITY_REC ;

                         -- Assign the values for activity record
                        l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                        l_activity_rec.REPAIR_LINE_ID :=  JOB.repair_line_id;
                        l_activity_rec.EVENT_CODE     :=  'JCA';
                        l_activity_rec.ACTION_CODE    :=  0;
                        l_activity_rec.EVENT_DATE     :=  l_mtl_trx_date;
                        l_activity_rec.QUANTITY       :=  null;
                        l_activity_rec.PARAMN1        :=  JOB.organization_id;
                        l_activity_rec.PARAMN3        :=  l_mtl_trx_id;
                        l_activity_rec.PARAMN4        :=  JOB.wip_entity_id;
                        l_activity_rec.PARAMN6        :=  l_ro_count;
                        l_activity_rec.PARAMC1        :=  l_mtl_serial_num ;
                        l_activity_rec.PARAMC2        :=  JOB.ro_serial_num ;
                        l_activity_rec.OBJECT_VERSION_NUMBER := null;

                        Debug('Calling LOG_ACTIVITY ',l_mod_name,2);
                        -- Calling LOG_ACTIVITY for logging activity
                        -- When the completed serial number does not match
				    -- with the repair order serial number
                        LOG_ACTIVITY
                            ( p_api_version     => p_api_version,
                              p_commit          => p_commit,
                              p_init_msg_list   => p_init_msg_list,
                              p_validation_level => p_validation_level,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_activity_rec    => l_activity_rec );

                       Debug('x_return_status from LOG_ACTIVITY ='||x_return_status,l_mod_name,2);
                       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                          Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;


				    -- Initialize the activity rec
                        l_activity_rec := INIT_ACTIVITY_REC ;

                         -- Assign the values for activity record
                        l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                        l_activity_rec.REPAIR_LINE_ID :=  JOB.repair_line_id;
                        l_activity_rec.EVENT_CODE     :=  'JC';
                        l_activity_rec.ACTION_CODE    :=  0;
                        l_activity_rec.EVENT_DATE     :=  l_mtl_trx_date;
                        l_activity_rec.QUANTITY       :=  JOB.job_completed_qty;
                        l_activity_rec.PARAMN1        :=  JOB.organization_id;
                        l_activity_rec.PARAMN3        :=  l_mtl_trx_id;
                        l_activity_rec.PARAMN4        :=  JOB.wip_entity_id;
                        l_activity_rec.PARAMN5        :=  1;
                        l_activity_rec.PARAMN6        :=  l_ro_count;
                        l_activity_rec.PARAMC1        :=  l_mtl_subinv;
                        l_activity_rec.PARAMC2        :=  JOB.wip_entity_name;
                        l_activity_rec.PARAMC3        :=  l_mtl_serial_num;
                        l_activity_rec.OBJECT_VERSION_NUMBER := null;

                        Debug('Calling LOG_ACTIVITY ',l_mod_name,2);
                        -- Calling LOG_ACTIVITY for logging activity
                        -- for job completion
                        LOG_ACTIVITY
                            ( p_api_version     => p_api_version,
                              p_commit          => p_commit,
                              p_init_msg_list   => p_init_msg_list,
                              p_validation_level => p_validation_level,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_activity_rec    => l_activity_rec );

                       Debug('x_return_status from LOG_ACTIVITY ='||x_return_status,l_mod_name,2);
                       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                          Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;

                      EXCEPTION
				     WHEN NO_DATA_FOUND THEN
                           NULL;
				  END;

			    END IF;

                ELSE
			     -- In case of upgrade, the wip job is submitted for the upgraded item,
				-- which is different then the item on the repair order
                      BEGIN
                         Select mt.transaction_id,
                                mt.transaction_date,
                                mut.serial_number,
                                mt.subinventory_code
                         into   l_mtl_trx_id,
                                l_mtl_trx_date,
                                l_mtl_serial_num,
                                l_mtl_subinv
                         from  mtl_material_transactions mt,
                               mtl_unit_transactions mut
                         where mt.transaction_id = mut.transaction_id
                          and  mt.transaction_source_id      = JOB.wip_entity_id
                          and  mt.transaction_source_type_id = 5  -- Job or Schedule
                          and  mt.transaction_action_id      = 31 -- Wip Assembly Completion
                          and  mut.serial_number not in (select crh.paramc3
                                                         from   csd_repair_history crh,
                                                                csd_repair_job_xref crj
                                                         where  crh.repair_line_id = crj.repair_line_id
                                                          and   crj.wip_entity_id  = JOB.wip_entity_id
                                                          and   crh.event_code     = 'JC')
                          and rownum = 1;

                        -- Update csd_repair_job_xref with qty completed
                        update csd_repair_job_xref
                        set quantity_completed = nvl(quantity_completed,0) + 1,
		                  object_version_number = object_version_number+1,
                            last_update_date = sysdate,
                            last_updated_by  = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                        where repair_job_xref_id = JOB.repair_job_xref_id;
                        IF SQL%NOTFOUND THEN
                            IF ( l_error_level >= G_debug_level)  THEN
                               FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                               FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',JOB.repair_job_xref_id );
                               FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                            ELSE
                               FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                               FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',JOB.repair_job_xref_id );
                               FND_MSG_PUB.ADD;
                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                        End IF;

                        -- Initialize the activity rec
                        l_activity_rec := INIT_ACTIVITY_REC ;

                         -- Assign the values for activity record
                        l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                        l_activity_rec.REPAIR_LINE_ID :=  JOB.repair_line_id;
                        l_activity_rec.EVENT_CODE     :=  'JC';
                        l_activity_rec.ACTION_CODE    :=  0;
                        l_activity_rec.EVENT_DATE     :=  l_mtl_trx_date;
                        l_activity_rec.QUANTITY       :=  JOB.job_completed_qty;
                        l_activity_rec.PARAMN1        :=  JOB.organization_id;
                        l_activity_rec.PARAMN3        :=  l_mtl_trx_id;
                        l_activity_rec.PARAMN4        :=  JOB.wip_entity_id;
                        l_activity_rec.PARAMN5        :=  1;
                        l_activity_rec.PARAMN6        :=  l_ro_count;
                        l_activity_rec.PARAMC1        :=  l_mtl_subinv;
                        l_activity_rec.PARAMC2        :=  JOB.wip_entity_name;
                        l_activity_rec.PARAMC3        :=  l_mtl_serial_num;
                        l_activity_rec.OBJECT_VERSION_NUMBER := null;

                        Debug('Calling LOG_ACTIVITY ',l_mod_name,2);
                        -- Calling LOG_ACTIVITY for logging activity
                        -- for job completion
                        LOG_ACTIVITY
                            ( p_api_version     => p_api_version,
                              p_commit          => p_commit,
                              p_init_msg_list   => p_init_msg_list,
                              p_validation_level => p_validation_level,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_activity_rec    => l_activity_rec );

                       Debug('x_return_status from LOG_ACTIVITY ='||x_return_status,l_mod_name,2);
                       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                          Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;

                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                           IF ( l_error_level >= G_debug_level)  THEN
                              FND_MESSAGE.SET_NAME('CSD','CSD_INV_WIP_ENTITY_ID');
                              FND_MESSAGE.SET_TOKEN('WIP_ENTITY_ID',JOB.wip_entity_id );
                              FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                           ELSE
                              FND_MESSAGE.SET_NAME('CSD','CSD_INV_WIP_ENTITY_ID');
                              FND_MESSAGE.SET_TOKEN('WIP_ENTITY_ID',JOB.wip_entity_id );
                              FND_MSG_PUB.ADD;
                           END IF;
                           RAISE FND_API.G_EXC_ERROR;
                     END;
                END IF;

            ELSE
                -- This scenario is for the serialized item at sales order issue and non-serialized
                -- In WIP_DISCRETE_JOBS
                --   Job Name    Job Id      Start Qty   Completion Qty   Completion Subinv
                --    W1          1121         10             10
                --
                --  MTL_MATERIAL_TRANSACTIONS
                --    Txn Id   Job ID   Txn Qty    Completion Subinv
                --      M1      1121      2           FGI
                --      M2      1121      8           Stores
              FOR MTL in Get_mtl_txns(JOB.wip_entity_id)
     	        LOOP
                 BEGIN
                    -- Debug messages
                   Debug('l_remaining_qty    ='||TO_CHAR(l_remaining_qty),l_mod_name,1);
        	        IF l_remaining_qty <= 0 then
                        -- exit the loop if nothing to process
                        Exit;
    	             ELSE
                      SELECT nvl(SUM(paramn5),0)
            		  INTO l_total_qty
            		  FROM CSD_REPAIR_HISTORY
            		  WHERE paramn3   = MTL.transaction_id
            		   AND  paramn4   = JOB.wip_entity_id
            		   AND  event_Code= 'JC';

                        -- Debug messages
                        Debug('l_total_qty    ='||TO_CHAR(l_total_qty),l_mod_name,1);

                        IF (nvl(MTL.transaction_quantity,0) - l_total_qty)> 0 THEN
             		   If (l_remaining_qty > (nvl(MTL.transaction_quantity,0) - l_total_qty)) then
                             l_remaining_qty  := l_remaining_qty - (nvl(MTL.transaction_quantity,0) - l_total_qty);
            		         l_update_qty     := (nvl(MTL.transaction_quantity,0) - l_total_qty);
             		   ELSE
            			    l_update_Qty     := l_remaining_qty;
            			    l_remaining_qty  := 0;
            		   END IF;

                            -- Debug messages
                            Debug('l_update_Qty    ='||TO_CHAR(l_update_Qty),l_mod_name,1);
                            Debug('l_remaining_qty ='||TO_CHAR(l_remaining_qty),l_mod_name,1);

                            -- Update csd_repair_job_xref with qty completed
                            update csd_repair_job_xref
                            set quantity_completed = nvl(quantity_completed,0) + NVL(l_update_qty,0),
		                      object_version_number = object_version_number+1,
                                last_update_date = sysdate,
                                last_updated_by  = fnd_global.user_id,
                                last_update_login = fnd_global.login_id
                            where repair_job_xref_id = JOB.repair_job_xref_id;
                            IF SQL%NOTFOUND THEN
                                IF ( l_error_level >= G_debug_level)  THEN
                                   FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                                   FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',JOB.repair_job_xref_id );
                                   FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                                ELSE
                                   FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                                   FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',JOB.repair_job_xref_id );
                                   FND_MSG_PUB.ADD;
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                            End IF;

                            -- Initialize the activity rec
                            l_activity_rec := INIT_ACTIVITY_REC ;

                             -- Assign the values for activity record
                            l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                            l_activity_rec.REPAIR_LINE_ID :=  JOB.repair_line_id;
                            l_activity_rec.EVENT_CODE     :=  'JC';
                            l_activity_rec.ACTION_CODE    :=  0;
                            l_activity_rec.EVENT_DATE     :=  MTL.transaction_date;
                            l_activity_rec.QUANTITY       :=  JOB.job_completed_qty;
                            l_activity_rec.PARAMN1        :=  JOB.organization_id;
                            l_activity_rec.PARAMN3        :=  MTL.transaction_id;
                            l_activity_rec.PARAMN4        :=  JOB.wip_entity_id;
                            l_activity_rec.PARAMN5        :=  l_update_qty;
                            l_activity_rec.PARAMN6        :=  l_ro_count;
                            l_activity_rec.PARAMC1        :=  MTL.subinventory_code;
                            l_activity_rec.PARAMC2        :=  JOB.wip_entity_name;
                            l_activity_rec.OBJECT_VERSION_NUMBER := null;

                            Debug('Calling LOG_ACTIVITY ',l_mod_name,2);

                            -- Calling LOG_ACTIVITY for logging activity
                            -- for job completion
                            LOG_ACTIVITY
                                ( p_api_version     => p_api_version,
                                  p_commit          => p_commit,
                                  p_init_msg_list   => p_init_msg_list,
                                  p_validation_level => p_validation_level,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count,
                                  x_msg_data        => x_msg_data,
                                  p_activity_rec    => l_activity_rec );

                           Debug('x_return_status from LOG_ACTIVITY ='||x_return_status,l_mod_name,2);
                           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                              Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                              RAISE FND_API.G_EXC_ERROR;
                           END IF;
                      END IF; --IF (MTL.transaction_quantity - l_total_qty)> 0
                  END IF;-- if l_remaining_qty <=0

              EXCEPTION
                   WHEN FND_API.G_EXC_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
              END;
            END LOOP; -- MTL cursor

        END IF; -- end if serial_number_control_code (2,5)
     END IF;-- if l_remaining_qty >0

    -- Increment if the record is processed successfully
    l_total_rec := l_total_rec + 1;
    Exception
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO JOB_COMPLETION;
          --x_return_status := FND_API.G_RET_STS_ERROR ;
          -- In case of error, exit the loop. It could rarely fail
          -- rollback the current record but commit the processed records
          --exit;
       WHEN SKIP_RECORD THEN
          NULL;
       WHEN OTHERS THEN
          ROLLBACK TO JOB_COMPLETION;
          --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          -- In case of error, exit the loop. It could rarely fail
          -- rollback the current record but commit the processed records
          --exit;
    END;

     -- Commit for every 500 records
     -- one should COMMIT less frequently within a PL/SQL loop to
     -- prevent ORA-1555 (Snapshot too old) errors
     l_count := l_count+1;
     IF mod(l_count, l_commit_size) = 0 THEN -- Commit every 500 records
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
     END IF;

  END LOOP; -- JOB Cursor

  --vijay 11/9/04

   IF(Repair_Jobs_ALL%ISOPEN ) THEN
       CLOSE Repair_Jobs_ALL;
   END IF;
   IF(Repair_Jobs%ISOPEN ) THEN
       CLOSE Repair_Jobs;
   END IF;


  -- Log messages for the number of records processed
  fnd_message.set_name('CSD','CSD_DRC_WIP_REC_PROC');
  fnd_message.set_token('TOT_REC',to_char(l_total_rec));
  FND_MSG_PUB.ADD;

  -- Retrive the message from the msg stack
  l_msg_text := fnd_message.get;

  -- Log the number of records processed in concurrent program output and log file
  fnd_file.put_line(fnd_file.log,l_msg_text);
  fnd_file.put_line(fnd_file.output,l_msg_text);

  -- Debug message
  Debug(l_msg_text,l_mod_name,1 );

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
  END IF;

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR exception',l_mod_name,4);
          ROLLBACK TO JOB_COMPLETION_UPDATE;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR exception',l_mod_name,4);
          ROLLBACK TO JOB_COMPLETION_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('In OTHERS exception',l_mod_name,4);
          ROLLBACK TO JOB_COMPLETION_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END JOB_COMPLETION_UPDATE;

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
/* Output Parameter :                                                                  */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*                                                                                     */
/*-------------------------------------------------------------------------------------*/

Procedure  JOB_CREATION_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_repair_line_id       IN   NUMBER
  	    ) IS

  --Standard variables
  l_api_name             CONSTANT VARCHAR2(30)   := 'JOB_CREATION_UPDATE';
  l_api_version          CONSTANT NUMBER         := 1.0;

  -- Variables used in the program
  l_rep_hist_id       NUMBER;
  l_total_rec         NUMBER:= 0;
  l_update_qty        NUMBER;
  l_count             NUMBER;
  l_dummy             varchar2(30);
  l_commit_size       NUMBER := 500;

  -- activity record
  l_activity_rec      activity_rec_type;

  -- Variable used in FND log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.job_creation_update';

  -- This cursor gets all the records in csd_repair_job_xref
  -- that does not have wip_entity_id.
  --Cursor split into two to remove OR condition
  -- Vijay 11/9/04
  Cursor JOB_CREATION( p_rep_line_id in number )IS
    SELECT
      crj.repair_job_xref_id,
      crj.repair_line_id,
      crj.organization_id,
      crj.quantity allocated_job_qty,
      we.wip_entity_id,
      we.wip_entity_name,
      wdj.start_quantity job_qty,
      wdj.creation_date
    from  CSD_REPAIR_JOB_XREF crj,
          WIP_ENTITIES we,
          wip_discrete_jobs wdj
    where wdj.wip_entity_id   = we.wip_entity_id
     and  crj.job_name        = we.wip_entity_name
     and  crj.organization_id = we.organization_id
     and  crj.repair_line_id = p_rep_line_id
     and  crj.wip_entity_id is null;
  -- This cursor gets all the records in csd_repair_job_xref
  -- that does not have wip_entity_id.
  Cursor JOB_CREATION_ALL IS
    SELECT
      crj.repair_job_xref_id,
      crj.repair_line_id,
      crj.organization_id,
      crj.quantity allocated_job_qty,
      we.wip_entity_id,
      we.wip_entity_name,
      wdj.start_quantity job_qty,
      wdj.creation_date
    from  CSD_REPAIR_JOB_XREF crj,
          WIP_ENTITIES we,
          wip_discrete_jobs wdj
    where wdj.wip_entity_id   = we.wip_entity_id
     and  crj.job_name        = we.wip_entity_name
     and  crj.organization_id = we.organization_id
     and  crj.wip_entity_id is null;
--Vijay 11/9/04
  K JOB_CREATION_Rec_Type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   JOB_CREATION_UPDATE;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug messages
   Debug('At the Beginning of JOB_CREATION_UPDATE',l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Keeping the running total of the records
   -- for commiting purpose
   l_count := 0;

    -- When Jobs are created from the UI, a record is inserted in csd_repair_job_xref
    -- with the job name. Once the WIP Job is created in wip_discrete_jobs
    -- then the update program will find the wip_entity_id and update it.
    -- Also it updates the quantity_in_wip in the csd_repairs with Job start quantity
    --
    -- When the WIP Job is submitted from the UI, the record would look as follows:
    --  CSD_REPAIR_JOB_XREF
    --   Repair Job   Repair Order   Allocated Qty   Job Name  Job Qty   Wip_entity_ID
    --     RJ1         R1                1            JOB1        3
    --     RJ2         R2                1            JOB1        3
    --     RJ3         R3                1            JOB1        3
    --
    -- After Running the Update Program the record would look as follows:
    --  CSD_REPAIR_JOB_XREF
    --   Repair Job   Repair Order   Allocated Qty   Job Name  Job Qty   Wip_entity_ID
    --     RJ1         R1                1            JOB1        3         1121
    --     RJ2         R2                1            JOB1        3         1121
    --     RJ3         R3                1            JOB1        3         1121
    --FOR K IN Job_Creation ( p_repair_line_id )
   IF(p_repair_line_Id is null) THEN
     OPEN Job_Creation_ALL;
   ELSE
     OPEN Job_Creation (p_repair_line_id);
   END IF;

   LOOP
    BEGIN

      IF(p_repair_line_Id is null) THEN
        FETCH  Job_Creation_ALL INTO K;
        EXIT WHEN Job_Creation_ALL%NOTFOUND;
      ELSE
        FETCH Job_Creation  INTO K;
        EXIT WHEN Job_Creation %NOTFOUND;
      END IF;
         -- savepoint
         SAVEPOINT  Job_Creation;

         -- Debug Messages
         Debug('wip_entity_id    ='||K.wip_entity_id,l_mod_name,1);
         Debug('Logging activity for Job creation',l_mod_name,1);

         -- Initialize the activity rec
         l_activity_rec := INIT_ACTIVITY_REC ;

         -- Assign the values for activity record
         l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
         l_activity_rec.REPAIR_LINE_ID := K.repair_line_id;
         l_activity_rec.EVENT_CODE     := 'JS';
         l_activity_rec.ACTION_CODE    := 0;
         l_activity_rec.EVENT_DATE     := K.creation_date;
         l_activity_rec.QUANTITY       := K.job_qty;
         l_activity_rec.PARAMN1        := k.wip_entity_id;
         l_activity_rec.PARAMN2        := k.organization_id;
         l_activity_rec.PARAMN5        :=  K.allocated_job_qty;
         l_activity_rec.PARAMC1        :=  K.wip_entity_name;
         l_activity_rec.OBJECT_VERSION_NUMBER := null;

         -- Debug Messages
         Debug('Calling LOG_ACTIVITY',l_mod_name,2);

         -- Calling LOG_ACTIVITY for logging activity
         -- for job creation
         LOG_ACTIVITY
                ( p_api_version     => p_api_version,
                  p_commit          => p_commit,
                  p_init_msg_list   => p_init_msg_list,
                  p_validation_level => p_validation_level,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_activity_rec    => l_activity_rec );

         -- Debug Messages
         Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Updating csd_repair_job_xref with the wip_entity_id
         Update csd_repair_job_xref
         set wip_entity_id        = K.wip_entity_id,
		   object_version_number = object_version_number+1,
             last_update_date = sysdate,
             last_updated_by  = fnd_global.user_id,
             last_update_login = fnd_global.login_id
         where repair_job_xref_id = K.repair_job_xref_id;
         IF SQL%NOTFOUND THEN
             IF ( l_error_level >= G_debug_level)  THEN
                 FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                 FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',K.repair_job_xref_id );
                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
             ELSE
                 FND_MESSAGE.SET_NAME('CSD','CSD_JOB_XREF_UPD_FAILED');
                 FND_MESSAGE.SET_TOKEN('REP_JOB_XREF_ID',K.repair_job_xref_id );
                 FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
         End IF;

         -- Updating repair order with the Job allocated qty
         Update csd_repairs
         set  quantity_in_wip = NVL(quantity_in_wip,0) + K.allocated_job_qty,
              last_update_date = sysdate,
              last_updated_by  = fnd_global.user_id,
		    object_version_number = object_version_number+1,
              last_update_login = fnd_global.login_id
         where repair_line_id = K.repair_line_id;
         IF SQL%NOTFOUND THEN
             IF ( l_error_level >= G_debug_level)  THEN
                 FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                 FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',K.repair_line_id );
                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
             ELSE
                 FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                 FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',K.repair_line_id );
                 FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
         End IF;

       Exception
           WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO JOB_CREATION;
              --x_return_status := FND_API.G_RET_STS_ERROR ;
              -- exit the loop in case of error. Commit the processed records
              -- but rollback the current error record
              --exit;
           WHEN OTHERS THEN
              ROLLBACK TO JOB_CREATION;
              --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              -- exit the loop in case of error. Commit the processed records
              -- but rollback the current error record
              --exit;
       END;
         -- Commit for every 500 records
         -- one should COMMIT less frequently within a PL/SQL loop to
         -- prevent ORA-1555 (Snapshot too old) errors
         l_count := l_count+1;
 	    IF mod(l_count, l_commit_size) = 0 THEN -- Commit every 500 records
             IF FND_API.To_Boolean( p_commit ) THEN
                 COMMIT WORK;
             END IF;
	    END IF;
  END LOOP; -- End of Job Creation activity

  --Vijay 11/9/04

  IF(Job_Creation_ALL%ISOPEN ) THEN
       CLOSE Job_Creation_ALL;
  END IF;
  IF(Job_Creation%ISOPEN ) THEN
      CLOSE Job_Creation;
  END IF;


  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
  END IF;

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR exception',l_mod_name,4);
          ROLLBACK TO  JOB_CREATION_UPDATE;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR exception',l_mod_name,4);
          ROLLBACK TO  JOB_CREATION_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('In OTHERS exception',l_mod_name,4);
          ROLLBACK TO  JOB_CREATION_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END JOB_CREATION_UPDATE;

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
/* Output Parameter :                                                                  */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure  RECEIPTS_UPDATE
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
          p_past_num_of_days     IN   NUMBER DEFAULT NULL   ----bug#6753684, 6742512
	  ) IS

  --Standard variables
  l_api_name             CONSTANT VARCHAR2(30)   := 'RECEIPTS_UPDATE';
  l_api_version          CONSTANT NUMBER         := 1.0;

  -- Variable used in FND log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.receipts_update';

--bug#8261344
  l_return_status      	 varchar2(1);
  l_msg_data_warning	    VARCHAR2(30000);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  RECEIPTS_UPDATE;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Log the api name in the log file
   Debug('At the Beginning of Receipts_update',l_mod_name,1);
   Debug('p_internal_order_flag   ='||p_internal_order_flag,l_mod_name,1);
   Debug('p_order_header_id       ='||p_order_header_id,l_mod_name,1);
   Debug('p_repair_line_id        ='||p_repair_line_id,l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Api body starts
   IF p_internal_order_flag = 'Y' then

       Debug('Calling IO_SHIP_UPDATE API',l_mod_name,2);
       -- Call the api for processing the shipment against
       -- internal orders
       IO_SHIP_UPDATE
        ( p_api_version          => p_api_version,
          p_commit               => p_commit     ,
          p_init_msg_list        => p_init_msg_list,
          p_validation_level     => p_validation_level,
          x_return_status        => x_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data ,
          p_order_header_id      => p_order_header_id );

       -- Debug messages
       Debug('Return Status from IO_SHIP_UPDATE API :'||x_return_status,l_mod_name,2);
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          Debug('IO_SHIP_UPDATE failed',l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       Debug('Calling IO_RCV_UPDATE API',l_mod_name,2);
       -- Call the api for processing the receipt against
       -- internal requisition
       IO_RCV_UPDATE
        ( p_api_version          => p_api_version,
          p_commit               => p_commit     ,
          p_init_msg_list        => p_init_msg_list,
          p_validation_level     => p_validation_level,
          x_return_status        => x_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data ,
          p_order_header_id      => p_order_header_id );

       -- Debug messages
       Debug('Return Status from IO_RCV_UPDATE API :'||x_return_status,l_mod_name,2);
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          Debug('IO_RCV_UPDATE failed',l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   Else
        -- Debug messages
        Debug('Calling RMA_RCV_UPDATE API',l_mod_name,2);
        -- Call the api for processing the receipts against RMA
        RMA_RCV_UPDATE
        ( p_api_version          => p_api_version,
          p_commit               => p_commit     ,
          p_init_msg_list        => p_init_msg_list,
          p_validation_level     => p_validation_level,
          x_return_status        => l_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data ,
          p_repair_line_id       => p_repair_line_id,
          p_past_num_of_days     => p_past_num_of_days);

       -- Debug messages
       Debug('Return Status from RMA_RCV_UPDATE API :'||l_return_status,l_mod_name,2);


	   --bug#8261344
	   If (l_return_status = G_CSD_RET_STS_WARNING and p_repair_line_id is null) Then
          Debug('RMA_RCV_UPDATE Warning message',l_mod_name,4);

		  Debug('x_msg_count :'||x_msg_count,l_mod_name,2);
		  Debug('x_msg_data :'||x_msg_data,l_mod_name,2);

		  l_msg_data_warning := null;
          -- Concatenate the message from the message stack
          IF x_msg_count >= 1 then
            FOR i IN 1..x_msg_count LOOP
                l_msg_data_warning := l_msg_data_warning ||' : '||FND_MSG_PUB.Get(i,FND_API.G_FALSE) ;
				Debug('l_msg_data_warning loop :'||l_msg_data_warning,l_mod_name,2);
            END LOOP ;
          END IF ;
          Debug(l_msg_data_warning,l_mod_name,4);
       ELSIF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          Debug('RMA_RCV_UPDATE failed',l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  End If;

  -- bug#7497790, 12.1 FP, subhat.
	-- automatically update RO status when item is received.
	-- dont show any error messages. Pass p_validation_level = fnd_api.g_valid_level_full to receive messages.
		csd_repairs_util.auto_update_ro_status(
                        p_api_version 	 => 1,
                        p_commit       	 => p_commit,
                        p_init_msg_list  => p_init_msg_list,
                        p_repair_line_id => p_repair_line_id,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        p_event          => 'RECEIVE',
						            p_validation_level => fnd_api.g_valid_level_none);
	-- end bug#7497790, 12.1 FP, subhat.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
  END IF;

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

  --bug#8261344
  If (l_return_status = G_CSD_RET_STS_WARNING and p_repair_line_id is null) THEN
		x_return_status := l_return_status;
		x_msg_data		:= l_msg_data_warning;
  END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR exception',l_mod_name,4 );
          -- As we are committing the processed records  in the inner APIs
		-- so we rollback only if the p_commit='F'
		IF NOT(FND_API.To_Boolean( p_commit )) THEN
              ROLLBACK TO RECEIPTS_UPDATE;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR exception',l_mod_name,4 );
          IF ( l_error_level >= G_debug_level)  THEN
              fnd_message.set_name('CSD','CSD_SQL_ERROR');
              fnd_message.set_token('SQLERRM',SQLERRM);
              fnd_message.set_token('SQLCODE',SQLCODE);
              FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
          END If;
          -- As we are committing the processed records  in the inner APIs
		-- so we rollback only if the p_commit='F'
		IF NOT(FND_API.To_Boolean( p_commit )) THEN
              ROLLBACK TO RECEIPTS_UPDATE;
          END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('In OTHERS exception',l_mod_name,4 );
          IF ( l_error_level >= G_debug_level)  THEN
              fnd_message.set_name('CSD','CSD_SQL_ERROR');
              fnd_message.set_token('SQLERRM',SQLERRM);
              fnd_message.set_token('SQLCODE',SQLCODE);
              FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
          END If;
          -- As we are committing the processed records  in the inner APIs
		-- so we rollback only if the p_commit='F'
		IF NOT(FND_API.To_Boolean( p_commit )) THEN
              ROLLBACK TO RECEIPTS_UPDATE;
          END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END RECEIPTS_UPDATE;

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
/* Output Parameter :                                                                  */
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
          p_past_num_of_days     IN   NUMBER  DEFAULT NULL)  ----bug#6753684, 6742512
IS


  -- Standard Variables
  l_api_name            CONSTANT VARCHAR2(30)   := 'RMA_RCV_UPDATE';
  l_api_version         CONSTANT NUMBER         := 1.0;

  -- Variables used in the program
  l_total_records       number;
  l_rep_hist_id         number;
  l_result_quantity     number;
  l_repair_line_id      NUMBER;
  l_prod_txn_id         NUMBER;
  l_accept_qty          NUMBER;
  l_reject_qty          NUMBER;
  l_st_serial_num       mtl_serial_numbers.serial_number%type;
  l_dummy               varchar2(30);
  l_lot_number          mtl_lot_numbers.lot_number%type;
  l_ro_reject_qty       NUMBER;
  l_commit_size         NUMBER := 500;
  l_srl_ctl_code        mtl_system_items.serial_number_control_code%type;
  l_lot_ctl_code        mtl_system_items.lot_control_code%type;
  l_ib_flag             mtl_system_items.comms_nl_trackable_flag%type;
  l_instance_id         csi_item_instances.instance_id%type;
  l_prod_txn_status     csd_product_transactions.prod_txn_status%type;

  -- activity record
  l_activity_rec      activity_rec_type;

--bug#6753684, 6742512
  l_From_Date  Date;
  l_TO_Date    Date;

  -- Variables for FND Log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.rma_rcv_update';

  -- User defined exceptions
  SKIP_RECORD  EXCEPTION;

  --bug#8261344
  l_skip_record           BOOLEAN := FALSE;
  l_warning_return		  BOOLEAN := FALSE;

  CURSOR RECEIPT_LINES IS
  SELECT
       oeh.order_number rma_number,
       oeh.header_id rma_header_id,
       oel.line_id ,
       oel.line_number rma_line_number,
       oel.inventory_item_id,
       haou.name org_name,
       rcvt.organization_id,
       rcvt.unit_of_measure,
       rcvt.quantity received_quantity,
       rcvt.transaction_date received_date,
       rcvt.transaction_id,
       rcvt.subinventory,
       rcvt.locator_id,
       rcvt.transaction_type,
       cra.serial_number ro_serial_number,
       cra.repair_number,
       cra.unit_of_measure ro_uom,
       cra.inventory_item_id ro_item_id,
       cpt.product_transaction_id,
       cpt.repair_line_id,
       cpt.action_code,
       cpt.source_serial_number,
	  cpt.source_instance_id,
	  cpt.quantity_received prod_txn_recd_qty,
       abs(ced.quantity_required) estimate_quantity,
       ced.order_line_id est_order_line_id,
       ced.inventory_item_id prod_txn_item_id
  FROM csd_product_transactions cpt,
       cs_estimate_details ced,
       csd_repairs cra,
       rcv_transactions rcvt,
       oe_order_headers_all oeh,
       oe_order_lines_all oel,
       hr_all_organization_units haou
  WHERE cpt.action_type    in ('RMA', 'RMA_THIRD_PTY') -- excluded walk-in-receipt as it is going off
  AND   cpt.prod_txn_status    in (  'BOOKED', 'SUBMITTED')
  AND   ced.order_header_id is not null
  AND   rcvt.oe_order_line_id = ced.order_line_id    ----bug#6753684, 6742512
  AND   rcvt.oe_order_header_id = ced.order_header_id  ----bug#6753684, 6742512
  AND   ced.source_code        = 'DR'
  AND   ced.estimate_detail_id = cpt.estimate_detail_id
  AND   cra.repair_line_id     = cpt.repair_line_id
  AND   oeh.header_id          = ced.order_header_id
  AND   oel.header_id          = oeh.header_id
  AND   rcvt.oe_order_line_id  = oel.line_id
  AND   rcvt.transaction_type in ('DELIVER','ACCEPT','REJECT')
  AND   rcvt.source_document_code = 'RMA'
  AND   rcvt.organization_id   = haou.organization_id
  AND   NOT EXISTS
        (SELECT 'X'
         FROM  csd_repair_history crh
         WHERE crh.repair_line_id = cpt.repair_line_id
          AND  event_code         = decode(rcvt.transaction_type,
                                           'DELIVER','RR',
                                           'ACCEPT', 'IP',
                                           'REJECT','IP','')
          AND  paramn1            = rcvt.transaction_id)

  AND  ((ced.QUANTITY_REQUIRED < -1
	           AND oel.line_id in ( Select line_id
                              from oe_order_lines_all oel1
             	               start with oel1.line_id = ced.order_line_id
     		                 connect by prior oel1.line_id = oel1.split_from_line_id
     		                 and oel1.shipped_quantity is not null
     		                 and oel1.header_id = oeh.header_id))
			OR (ced.QUANTITY_REQUIRED = -1
			    AND ced.ORDER_LINE_ID = oel.LINE_ID));

/* Fixed bug#6753684,

	New cursor added for batch processing.This cursor takes two parameter
	p_from_date and p_to_date. These dates are compared with the creation date
	of repair order. Only repair order created during this period are considered
	for Depot Receipt Update to improve performance.
*/
  CURSOR RECEIPT_LINES_BY_DATE( p_from_Date Date, p_to_Date Date ) IS
  SELECT
       oeh.order_number rma_number,
       oeh.header_id rma_header_id,
       oel.line_id ,
       oel.line_number rma_line_number,
       oel.inventory_item_id,
       haou.name org_name,
       rcvt.organization_id,
       rcvt.unit_of_measure,
       rcvt.quantity received_quantity,
       rcvt.transaction_date received_date,
       rcvt.transaction_id,
       rcvt.subinventory,
       rcvt.locator_id,
       rcvt.transaction_type,
       cra.serial_number ro_serial_number,
       cra.repair_number,
       cra.unit_of_measure ro_uom,
       cra.inventory_item_id ro_item_id,
       cpt.product_transaction_id,
       cpt.repair_line_id,
       cpt.action_code,
       cpt.source_serial_number,
	  cpt.source_instance_id,
	  cpt.quantity_received prod_txn_recd_qty,
       abs(ced.quantity_required) estimate_quantity,
       ced.order_line_id est_order_line_id,
       ced.inventory_item_id prod_txn_item_id
  FROM csd_product_transactions cpt,
       cs_estimate_details ced,
       csd_repairs cra,
       rcv_transactions rcvt,
       oe_order_headers_all oeh,
       oe_order_lines_all oel,
       hr_all_organization_units haou
  WHERE cra.creation_date between p_from_date and p_to_date
  AND   cpt.action_type    in ('RMA', 'RMA_THIRD_PTY') -- excluded walk-in-receipt as it is going off
  AND   cpt.prod_txn_status    in (  'BOOKED', 'SUBMITTED')
  AND   ced.order_header_id is not null
  AND   rcvt.oe_order_line_id = ced.order_line_id    ----bug#6753684, 6742512
  AND   rcvt.oe_order_header_id = ced.order_header_id  ----bug#6753684, 6742512
  AND   ced.source_code        = 'DR'
  AND   ced.estimate_detail_id = cpt.estimate_detail_id
  AND   cra.repair_line_id     = cpt.repair_line_id
  AND   oeh.header_id          = ced.order_header_id
  AND   oel.header_id          = oeh.header_id
  AND   rcvt.oe_order_line_id  = oel.line_id
  AND   rcvt.transaction_type in ('DELIVER','ACCEPT','REJECT')
  AND   rcvt.source_document_code = 'RMA'
  AND   rcvt.organization_id   = haou.organization_id
  AND   NOT EXISTS
        (SELECT 'X'
         FROM  csd_repair_history crh
         WHERE crh.repair_line_id = cpt.repair_line_id
          AND  event_code         = decode(rcvt.transaction_type,
                                           'DELIVER','RR',
                                           'ACCEPT', 'IP',
                                           'REJECT','IP','')
          AND  paramn1            = rcvt.transaction_id)

  AND  ((ced.QUANTITY_REQUIRED < -1
	           AND oel.line_id in ( Select line_id
                              from oe_order_lines_all oel1
             	               start with oel1.line_id = ced.order_line_id
     		                 connect by prior oel1.line_id = oel1.split_from_line_id
     		                 and oel1.shipped_quantity is not null
     		                 and oel1.header_id = oeh.header_id))
			OR (ced.QUANTITY_REQUIRED = -1
			    AND ced.ORDER_LINE_ID = oel.LINE_ID));


  CURSOR RECEIPT_LINES_RO(p_repair_line_id NUMBER) IS
  SELECT
     oeh.order_number rma_number,
     oeh.header_id rma_header_id,
     oel.line_id ,
     oel.line_number rma_line_number,
     oel.inventory_item_id,
     haou.name org_name,
     rcvt.organization_id,
     rcvt.unit_of_measure,
     rcvt.quantity received_quantity,
     rcvt.transaction_date received_date,
     rcvt.transaction_id,
     rcvt.subinventory,
     rcvt.locator_id,
     rcvt.transaction_type,
     cra.serial_number ro_serial_number,
     cra.repair_number,
     cra.unit_of_measure ro_uom,
     cra.inventory_item_id ro_item_id,
     cpt.product_transaction_id,
     cpt.repair_line_id,
     cpt.action_code,
     cpt.source_serial_number,
     cpt.source_instance_id,
     cpt.quantity_received prod_txn_recd_qty,
     abs(ced.quantity_required) estimate_quantity,
     ced.order_line_id est_order_line_id,
     ced.inventory_item_id prod_txn_item_id
 FROM hr_all_organization_units haou,
      csd_repairs cra,
      oe_order_headers_all oeh,
      oe_order_lines_all oel,
      rcv_transactions rcvt,
      cs_estimate_details ced,
      csd_product_transactions cpt
 WHERE cpt.repair_line_id = p_repair_line_id
       AND   cpt.action_type    in ('RMA', 'RMA_THIRD_PTY') -- excluded walk-in-receipt as it is going off
       AND   cpt.prod_txn_status    in (  'BOOKED', 'SUBMITTED')
       AND   ced.order_header_id is not null
       AND   rcvt.oe_order_line_id = ced.order_line_id       ----bug#6753684, 6742512
       AND   rcvt.oe_order_header_id = ced.order_header_id   ----bug#6753684, 6742512
       AND   ced.source_code        = 'DR'
       AND   ced.estimate_detail_id = cpt.estimate_detail_id
       AND   cra.repair_line_id     = cpt.repair_line_id
       AND   oeh.header_id          = ced.order_header_id
       AND   oel.header_id          = oeh.header_id
       AND   rcvt.oe_order_line_id  = oel.line_id
       AND   rcvt.transaction_type in ('DELIVER','ACCEPT','REJECT')
       AND   rcvt.source_document_code = 'RMA'
       AND   rcvt.organization_id   = haou.organization_id
       AND   NOT EXISTS
             (SELECT 'X'
              FROM  csd_repair_history crh
              WHERE crh.repair_line_id = cpt.repair_line_id
               AND  event_code         = decode(rcvt.transaction_type,
                                                'DELIVER','RR',
                                                'ACCEPT', 'IP',
                                                'REJECT','IP','')
               AND  paramn1            = rcvt.transaction_id)


       AND  ((ced.QUANTITY_REQUIRED < -1
	           AND oel.line_id in ( Select line_id
                              from oe_order_lines_all oel1
             	               start with oel1.line_id = ced.order_line_id
     		                 connect by prior oel1.line_id = oel1.split_from_line_id
     		                 and oel1.shipped_quantity is not null
     		                 and oel1.header_id = oeh.header_id))
			OR (ced.QUANTITY_REQUIRED = -1
			    AND ced.ORDER_LINE_ID = oel.LINE_ID));

  I RCPT_LINES_Rec_Type;


 --- cursor for Cancelled orders...
 CURSOR Cur_Cancelled_repair_lines IS
 SELECT cra.REPAIR_LINE_ID
 FROM csd_repairs cra,
      cs_estimate_details ced,
      csd_product_transactions cpt
 WHERE  cpt.action_type    in ('RMA', 'RMA_THIRD_PTY')
       AND   cpt.prod_txn_status    in (  'BOOKED', 'SUBMITTED')
       AND   ced.order_header_id is not null
       AND   ced.source_code        = 'DR'
       AND   ced.estimate_detail_id = cpt.estimate_detail_id
       AND   cra.repair_line_id     = cpt.repair_line_id;


  -- Cursor that gets the serial number and lot number
  -- for the rcv txn id
  Cursor rcv_txn_serial_num (p_txn_id in number) is
  select rst.serial_num,
         rst.lot_num
  from rcv_serial_transactions rst,
       rcv_transactions rt
  where rt.transaction_id   = p_txn_id
   and  rst.transaction_id  = rt.transaction_id;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  RMA_RCV_UPDATE;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug messages
   Debug('At the Beginning of RMA_RCV_UPDATE',l_mod_name,1);
   Debug('Repair Line Id ='||to_char(p_repair_line_id),l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Api body starts

   -- Validate the repair line id
   -- bugfix 4423818 : We need to validate only if p_repair_line_id is NOT NULL
   IF(p_repair_line_id is NOT NULL ) THEN
     IF NOT(csd_process_util.validate_rep_line_id(p_repair_line_id)) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Assign the number of processed records in this variable
   l_total_records := 0;

--bug#8261344
   l_warning_return:= FALSE;
   l_skip_record := FALSE;

   -- Selects all the receipts lines that have accept,reject,deliver
   -- transaction type
   -- 1. Serialized
   --  BEFORE RECEIVING
   --  Repair Order
   --    RO NUM  RO Type  Qty    SN   rcvd Qty
   --      R1      RR      1     SN1
   --  Product Txn
   --   Prod Txn   RO Num   Est Line  Est Qty   SN   Subinv   rcvd Qty
   --     P1        R1         C1       1       SN1
   --
   -- AFTER RECEIVING and running the update program
   --  Repair Order
   --    RO NUM  RO Type  Qty   SN   rcvd Qty
   --      R1      RR      1    SN9       1
   --
   --  RCV Lines
   --   Txn Id  Txn Type  Parent Txn Id  Ord Line  Qty  SN    Subinv
   --     T1     ACCEPT                    L1
   --     T2     DELIVER      T1           L1       1   SN9    FGI
   --
   --  Product Txn
   --   Prod Txn   RO Num   Est Line  Est Qty   SN     Subinv  Rcvd Qty
   --     P1        R1         C1       1       SN9    FGI        1
   --
   -- 2. Non-Serialized
   --  BEFORE RECEIVING
   --  Repair Order
   --    RO NUM  RO Type  Qty    SN   rcvd Qty
   --      R1      RR      3
   --  Product Txn
   --   Prod Txn   RO Num   Est Line  Est Qty   SN   Subinv    rcvd Qty
   --     P1        R1         C1       3
   -- AFTER SHIPMENT and running the update program
   --  Repair Order
   --    RO NUM  RO Type  Qty   SN   rcvd Qty  rejected Qty
   --      R1      RR      3            2         1
   --
   --  RCV Lines
   --   Txn Id  Txn Type  Parent Txn Id  Ord Line  Qty  SN    Subinv
   --     T1     ACCEPT                    L1
   --     T2     DELIVER      T1           L1       2               FGI
   --     T3     REJECT                    L1       1
   --
   --  Product Txn
   --   Prod Txn   RO Num   Est Line  Est Qty   SN     Subinv  rcvd Qty
   --     P1        R1         C1       3               FGI        2
   --

   IF(p_repair_line_id is null) THEN
        If (p_past_num_of_days Is Null) Then
            OPEN RECEIPT_LINES;
        Else
            l_From_Date := sysdate - (p_past_num_of_days +1 ) ;
            l_TO_Date   := Sysdate + 1;
            OPEN RECEIPT_LINES_BY_DATE(l_From_Date , l_To_Date);        ----bug#6753684, 6742512
        End If;
   ELSE
        OPEN RECEIPT_LINES_RO(p_repair_line_id);
   END IF;


   LOOP

    IF(p_repair_line_id is null) THEN
        If (p_past_num_of_days Is Null) Then
            FETCH RECEIPT_LINES INTO I;
            exit when RECEIPT_LINES%NOTFOUND;
        else
            FETCH RECEIPT_LINES_BY_DATE INTO I;             ----bug#6753684, 6742512
            exit when RECEIPT_LINES_BY_DATE%NOTFOUND;
        end if;
    ELSE
        FETCH RECEIPT_LINES_RO INTO I;
        exit when RECEIPT_LINES_RO%NOTFOUND;
    END IF;


    BEGIN
     -- savepoint
     SAVEPOINT RECEIPT_LINES;

     IF I.transaction_type = 'ACCEPT' THEN
        -- Log activities for the accept transaction

         l_accept_qty := I.received_quantity;
         l_reject_qty := 0;

         -- Initialize the activity rec
         l_activity_rec := INIT_ACTIVITY_REC ;

         -- Assign the values for activity record
         l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
         l_activity_rec.REPAIR_LINE_ID := I.repair_line_id;
         l_activity_rec.EVENT_CODE     := 'IP';
         l_activity_rec.ACTION_CODE    := 0;
         l_activity_rec.EVENT_DATE     := I.received_date;
         l_activity_rec.QUANTITY       := null;
         l_activity_rec.PARAMN1        := I.transaction_id;
         l_activity_rec.PARAMN2        := I.rma_header_id;
         l_activity_rec.PARAMN3        := l_accept_qty;
         l_activity_rec.PARAMN4        := l_reject_qty;
         l_activity_rec.PARAMN5        := I.line_id;
         l_activity_rec.PARAMC1        := I.rma_number;
         l_activity_rec.PARAMC2        := I.subinventory;
         l_activity_rec.OBJECT_VERSION_NUMBER := null;

         -- Debug Messages
         Debug('Calling LOG_ACTIVITY',l_mod_name,2);

         -- Calling LOG_ACTIVITY for logging activity
         -- accept receiving txn
         LOG_ACTIVITY
              ( p_api_version     => p_api_version,
                p_commit          => p_commit,
                p_init_msg_list   => p_init_msg_list,
                p_validation_level => p_validation_level,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_activity_rec    => l_activity_rec );

         -- Debug Messages
        Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
             RAISE FND_API.G_EXC_ERROR;
        END IF;

      ELSIF I.transaction_type = 'REJECT' then
         -- Log activities for the reject transactions

          l_accept_qty := 0;
          l_reject_qty := I.received_quantity;

          -- Initialize the activity rec
          l_activity_rec := INIT_ACTIVITY_REC ;

          -- Assign the values for activity record
          l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
          l_activity_rec.REPAIR_LINE_ID := I.repair_line_id;
          l_activity_rec.EVENT_CODE     := 'IP';
          l_activity_rec.ACTION_CODE    := 0;
          l_activity_rec.EVENT_DATE     := I.received_date;
          l_activity_rec.QUANTITY       := null;
          l_activity_rec.PARAMN1        := I.transaction_id;
          l_activity_rec.PARAMN2        := I.rma_header_id;
          l_activity_rec.PARAMN3        := l_accept_qty;
          l_activity_rec.PARAMN4        := l_reject_qty;
          l_activity_rec.PARAMN5        := I.line_id;
          l_activity_rec.PARAMC1        := I.rma_number;
          l_activity_rec.PARAMC2        := I.subinventory;
          l_activity_rec.OBJECT_VERSION_NUMBER := null;

         -- Debug Messages
         Debug('Calling LOG_ACTIVITY',l_mod_name,2);

         -- Calling LOG_ACTIVITY for logging activity
         -- reject receiving transactions
         LOG_ACTIVITY
              ( p_api_version     => p_api_version,
                p_commit          => p_commit,
                p_init_msg_list   => p_init_msg_list,
                p_validation_level => p_validation_level,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_activity_rec    => l_activity_rec );

         -- Debug Messages
        Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
             RAISE FND_API.G_EXC_ERROR;
        END IF;

      ElSIF I.transaction_type = 'DELIVER' then
         --Log activities for the deliver transaction
	    --Log actvities for the receipts of the item and the received serial number does
         --not match with the one on the product txns

        --Debug messages
        Debug('Repair_Line_id ='||to_char(i.repair_line_id),l_mod_name,1);
        Debug('Rma Number     ='||I.rma_number,l_mod_name,1);
        Debug('Transaction_id ='||to_char(i.transaction_id),l_mod_name,1);
        Debug('Inv_Item id    ='||to_char(i.inventory_item_id),l_mod_name,1);
        Debug('Receiving Org  ='||to_char(i.organization_id),l_mod_name,1);

        -- Check if the item is serialized or non-serialized
        Begin
           select serial_number_control_code,
                lot_control_code,
                comms_nl_trackable_flag
 	      into l_srl_ctl_code,
                l_lot_ctl_code,
                l_ib_flag
	      from mtl_system_items
	      where inventory_item_id  = i.inventory_item_id
	       and  organization_id    = i.organization_id;
        Exception
          When no_data_found then
            IF ( l_error_level >= G_debug_level) THEN
               fnd_message.set_name('CSD','CSD_INV_ITEM_ID');
               fnd_message.set_token('ITEM_ID',I.inventory_item_id);
               FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
            ELSE
               fnd_message.set_name('CSD','CSD_INV_ITEM_ID');
               fnd_message.set_token('ITEM_ID',I.inventory_item_id);
               fnd_msg_pub.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          When others then
            Debug('In Others exception',l_mod_name,4);
            RAISE FND_API.G_EXC_ERROR;
       End;

	  Debug('Serial Num Ctl Code  ='||TO_CHAR(l_srl_ctl_code),l_mod_name,1);
	  Debug('Lot Ctl Code         ='||TO_CHAR(l_lot_ctl_code),l_mod_name,1);
	  Debug('IB Flag              ='||l_ib_flag,l_mod_name,1);

       IF l_srl_ctl_code in (2,5,6) THEN

         -- Item is serialized
         -- Opening the cursor for getting the received
         -- serial number
         Open rcv_txn_serial_num(i.transaction_id );
         Fetch rcv_txn_serial_num into l_st_serial_num, l_lot_number;
         IF (rcv_txn_serial_num%NOTFOUND) THEN
             IF ( l_error_level >= G_debug_level)  THEN
                 FND_MESSAGE.SET_NAME('CSD','CSD_SERIAL_NUM_MISSING');
                 FND_MESSAGE.SET_TOKEN('TXN_ID',i.transaction_id);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
             ELSE
                 FND_MESSAGE.SET_NAME('CSD','CSD_SERIAL_NUM_MISSING');
                 FND_MESSAGE.SET_TOKEN('TXN_ID',i.transaction_id);
                 FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
         END IF;
	    -- Close the cursor
         If rcv_txn_serial_num %isopen then
             close rcv_txn_serial_num ;
         End if;

         Debug('Rcv  Txn  Serial_num  ='||l_st_serial_num,l_mod_name,1);
         Debug('Prod Txn  serial_num  ='||I.SOURCE_SERIAL_NUMBER,l_mod_name,1);
         Debug('Lot number            ='||l_lot_number,l_mod_name,1);

         -- Get the instance Id from the rcvd serial number
         IF NVL(l_ib_flag,'N') = 'Y' THEN
	     BEGIN
            Select instance_id
            into   l_instance_id
            from  csi_item_instances
            where inventory_item_id = I.inventory_item_id
             and  serial_number     = l_st_serial_num;      --bug#8261344
		   --and  instance_usage_code = 'IN_INVENTORY';
          EXCEPTION
           WHEN NO_DATA_FOUND THEN
             IF ( l_error_level >= G_debug_level)  THEN
                 FND_MESSAGE.SET_NAME('CSD','CSD_INSTANCE_MISSING');
                 FND_MESSAGE.SET_TOKEN('SERIAL_NUM',l_st_serial_num);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
             ELSE
                 FND_MESSAGE.SET_NAME('CSD','CSD_INSTANCE_MISSING');
                 FND_MESSAGE.SET_TOKEN('SERIAL_NUM',l_st_serial_num);
                 FND_MSG_PUB.ADD;
             END IF;

             --RAISE FND_API.G_EXC_ERROR;
             --bug#8261344
    			 IF(p_repair_line_id is not null or (NVL(fnd_profile.value('CSD_LOGISTICS_PROGRAM_ERROR'), 'S') <> 'A')) THEN
				    RAISE FND_API.G_EXC_ERROR;
    			 else
				     l_skip_record := TRUE;
				     l_warning_return := TRUE;
    			 end if;

	       Debug(' Could not find any IB instance for the Serial Num ='||l_st_serial_num, l_mod_name,1);
           WHEN TOO_MANY_ROWS THEN
             IF ( l_error_level >= G_debug_level)  THEN
                 FND_MESSAGE.SET_NAME('CSD','CSD_FOUND_MANY_INSTANCE');
                 FND_MESSAGE.SET_TOKEN('SERIAL_NUM',l_st_serial_num);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
             ELSE
                 FND_MESSAGE.SET_NAME('CSD','CSD_FOUND_MANY_INSTANCE');
                 FND_MESSAGE.SET_TOKEN('SERIAL_NUM',l_st_serial_num);
                 FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
	       Debug(' Found many IB instance for the Serial Num ='||l_st_serial_num, l_mod_name,1);
          END;
         ELSE
             l_instance_id := NULL;
	   END IF;

         -- If the item on prod txn is same as the order line and
         -- the serial number does not match with the received serial number
         -- then log activity for serial number mismatch
         IF (l_st_serial_num <> I.SOURCE_SERIAL_NUMBER) AND
            (I.prod_txn_item_id = I.inventory_item_id) and NOT(l_skip_record) THEN   --bug#8261344


                -- Initialize the activity rec
                l_activity_rec := INIT_ACTIVITY_REC ;

                -- Assign the values for activity record
                l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                l_activity_rec.REPAIR_LINE_ID := I.repair_line_id;
                l_activity_rec.EVENT_CODE     := 'RSC';
                l_activity_rec.ACTION_CODE    := 0;
                l_activity_rec.EVENT_DATE     := I.received_date;
                l_activity_rec.QUANTITY       := null;
                l_activity_rec.PARAMN1        := I.transaction_id;
                l_activity_rec.PARAMN2        := i.rma_line_number;
                l_activity_rec.PARAMN6        := I.rma_header_id;
                l_activity_rec.PARAMC1        := I.subinventory;
                l_activity_rec.PARAMC2        := I.rma_number;
                l_activity_rec.PARAMC3        := I.source_serial_number; -- prod txn serial num
                l_activity_rec.PARAMC4        := l_st_serial_num;        -- rcvd serial num
                l_activity_rec.OBJECT_VERSION_NUMBER := null;

                -- Debug Messages
                Debug('Calling LOG_ACTIVITY',l_mod_name,2);

                -- Calling LOG_ACTIVITY for logging activity
                -- Serial number mismatch
                LOG_ACTIVITY
                       ( p_api_version     => p_api_version,
                         p_commit          => p_commit,
                         p_init_msg_list   => p_init_msg_list,
                         p_validation_level => p_validation_level,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_activity_rec    => l_activity_rec );

                -- Debug Messages
                Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
         End IF;   --end for  IF (l_st_serial_num <> I.SOURCE_SERIAL_NUMBER)

       ELSE   ---esle for IF l_srl_ctl_code in (2,5,6)
           -- Non-Serialized item
           l_st_serial_num := NULL;

		 IF nvl(l_ib_flag,'N')= 'Y' THEN
		    l_instance_id   := I.source_instance_id;
		 Else
		    l_instance_id   := NULL;
           End if;

           --lot_control_code = 1 No control
           --lot_control_code = 2 Full control
           IF l_lot_ctl_code = 2 THEN
              BEGIN
                 Select lot_num
                 into  l_lot_number
                 from  rcv_lot_transactions
                 where source_transaction_id = I.transaction_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  IF ( l_error_level >= G_debug_level) THEN
                      fnd_message.set_name('CSD','CSD_INV_ITEM_ID');
                      fnd_message.set_token('ITEM_ID',I.inventory_item_id);
                      FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                  ELSE
                      fnd_message.set_name('CSD','CSD_INV_ITEM_ID');
                      fnd_message.set_token('ITEM_ID',I.inventory_item_id);
                      fnd_msg_pub.add;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
              END;
           ELSE
              l_lot_number := NULL;
           END IF;  --end for IF l_lot_ctl_code = 2
       END IF; -- End of logging activity for SN change


     If NOT(l_skip_record) Then   --bug#8261344
       Debug('inside of l_skip record ',l_mod_name,2);

       -- Only if the item on RO matches with the item
       -- on order_line_id, call the convert api
       IF I.ro_item_id = I.inventory_item_id THEN

          Debug('Calling CONVERT_TO_RO_UOM ',l_mod_name,2);
          -- Converting the received qty to UOM
          -- on the repair order
          CONVERT_TO_RO_UOM
            ( x_return_status   => x_return_status
             ,p_to_uom_code     => i.ro_uom
             ,p_item_id         => i.inventory_item_id
             ,p_from_uom        => i.unit_of_measure
             ,p_from_uom_code   => NULL
             ,p_from_quantity   => i.received_quantity
             ,x_result_quantity => l_result_quantity);

          Debug('Return Status from CONVERT_TO_RO_UOM '||x_return_status,l_mod_name,2);
          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             Debug('CONVERT_TO_RO_UOM failed ',l_mod_name,4);
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       Else
          l_result_quantity := NVL(i.received_quantity,0);
       END IF;
       Debug('l_result_quantity='||TO_CHAR(l_result_quantity),l_mod_name,1);

       -- Update csd_repairs only if the action code is
	  -- cust_prod or exchange
       IF I.action_code in ( 'CUST_PROD','EXCHANGE') then

	    IF I.ro_item_id = I.inventory_item_id THEN
	     -- Update the serial num and instance id if the item on ro
	     -- is same as prod txn
          update csd_repairs
          set quantity_rcvd = nvl(quantity_rcvd,0)+ l_result_quantity,
		 object_version_number = object_version_number+1,
             customer_product_id = l_instance_id,
             serial_number = l_st_serial_num,
             last_update_date = sysdate,
             last_updated_by  = fnd_global.user_id,
             last_update_login = fnd_global.login_id
          where repair_line_id = I.repair_line_id;
          IF SQL%NOTFOUND THEN
            IF ( l_error_level >= G_debug_level) THEN
               fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
               fnd_message.set_token('REPAIR_LINE_ID',I.repair_line_id);
               FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
            ELSE
               fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
               fnd_message.set_token('REPAIR_LINE_ID',I.repair_line_id);
               fnd_msg_pub.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

	    ELSE
	     -- Update the qty if the item on ro
	     -- is not same as prod txn
          update csd_repairs
          set quantity_rcvd = nvl(quantity_rcvd,0)+ l_result_quantity,
		    object_version_number = object_version_number+1,
              last_update_date = sysdate,
              last_updated_by  = fnd_global.user_id,
              last_update_login = fnd_global.login_id
          where repair_line_id = I.repair_line_id;
          IF SQL%NOTFOUND THEN
            IF ( l_error_level >= G_debug_level) THEN
               fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
               fnd_message.set_token('REPAIR_LINE_ID',I.repair_line_id);
               FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
            ELSE
               fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
               fnd_message.set_token('REPAIR_LINE_ID',I.repair_line_id);
               fnd_msg_pub.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

	    END IF;
       End If;

      IF  nvl(I.prod_txn_recd_qty,0) + nvl(I.received_quantity,0) = I.estimate_quantity THEN
        l_prod_txn_status := 'RECEIVED';
  	 ELSE
        l_prod_txn_status := 'BOOKED';
	 END IF;

      -- Update the quantity received,locator id, lot number
      Update csd_product_transactions
      set sub_inventory = I.subinventory,
          locator_id    = I.locator_id,
          lot_number_rcvd      = l_lot_number,
          source_instance_id   = l_instance_id,
          source_serial_number = l_st_serial_num,
          quantity_received = nvl(quantity_received,0) + nvl(I.received_quantity,0),
		prod_txn_status   = l_prod_txn_status,
		object_version_number = object_version_number+1,
          last_update_date = sysdate,
          last_updated_by  = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE  product_transaction_id = i.product_transaction_id;
      IF SQL%NOTFOUND THEN
         IF ( l_error_level >= G_debug_level) THEN
              fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
              fnd_message.set_token('PROD_TXN_ID',I.product_transaction_id);
              FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
         ELSE
              fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
              fnd_message.set_token('PROD_TXN_ID',I.product_transaction_id);
              fnd_msg_pub.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      fnd_message.set_name('CSD','CSD_DRC_RMA_RECEIPT');
      fnd_message.set_token('RMA_NO',i.rma_number);
      fnd_message.set_token('REP_NO',i.repair_number);
      fnd_message.set_token('QTY_RCVD',to_char(i.received_quantity));
      FND_MSG_PUB.ADD;

      -- Debug message
      Debug(fnd_message.get,l_mod_name,1);

      -- Log messages in concurrent log and output file
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      -- Initialize the activity rec
      l_activity_rec := INIT_ACTIVITY_REC ;

      -- Assign the values for activity record
      l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
      l_activity_rec.REPAIR_LINE_ID := I.repair_line_id;
      l_activity_rec.EVENT_CODE     := 'RR';
      l_activity_rec.ACTION_CODE    := 0;
      l_activity_rec.EVENT_DATE     := I.received_date;
      l_activity_rec.QUANTITY       := I.received_quantity;
      l_activity_rec.PARAMN1        := I.transaction_id;
      l_activity_rec.PARAMN2        := i.rma_line_number;
      l_activity_rec.PARAMN3        := i.organization_id;
      l_activity_rec.PARAMN6        := I.rma_header_id;
      l_activity_rec.PARAMC1        := I.subinventory;
      l_activity_rec.PARAMC2        := I.rma_number;
      l_activity_rec.PARAMC3        := I.org_name;
      l_activity_rec.OBJECT_VERSION_NUMBER := null;

      -- Debug Messages
      Debug('Calling LOG_ACTIVITY',l_mod_name,2);

      -- Calling LOG_ACTIVITY for logging activity
      -- receipt of the item
      LOG_ACTIVITY
           ( p_api_version     => p_api_version,
             p_commit          => p_commit,
             p_init_msg_list   => p_init_msg_list,
             p_validation_level => p_validation_level,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_activity_rec    => l_activity_rec );

       -- Debug Messages
       Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
             RAISE FND_API.G_EXC_ERROR;
       END IF;

     End if;    --end if NOT(l_skip_record)  --bug#8261344

   END IF;

     -- Commit for every 500 records
     -- one should COMMIT less frequently within a PL/SQL loop to
     -- prevent ORA-1555 (Snapshot too old) errors

    --bug#8261344
	  If NOT(l_skip_record) Then
	   	l_total_records := l_total_records + 1;
	  end if;
     IF mod(l_total_records, l_commit_size) = 0 THEN -- Commit every 500 records
         IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT WORK;
         END IF;
     END IF;

	--bug#8261344
	 l_skip_record := FALSE;

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO RECEIPT_LINES;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           EXIT;
           -- In case of error, exit the loop. Commit the processed records
           -- and rollback the error record
           -- RAISE FND_API.G_EXC_ERROR;
       WHEN SKIP_RECORD THEN
           NULL;
    END;
  END LOOP;


  ------------ process cancelled orders.
   Debug('processing cancelled orders in RMA_RCV_UPDATE',l_mod_name,1);
  if(p_repair_line_id is not null) then
     Debug('processing repairline['||p_repair_line_id||']',l_mod_name,1);
  	Check_for_Cancelled_order(p_repair_line_id);
  else
  	FOR Repln_Rec in Cur_Cancelled_repair_lines
	LOOP
          Debug('processing repairline['||repln_rec.repair_line_id||']',l_mod_name,1);
		check_for_cancelled_order(Repln_rec.Repair_line_id);
	END LOOP;
  End if;
   Debug('At the end of processing cancelled orders in RMA_RCV_UPDATE',l_mod_name,1);
  -----------------------


 --Added by Vijay 11/4/04
  IF(RECEIPT_LINES%ISOPEN) THEN
      CLOSE RECEIPT_LINES;
  END IF;
  IF(RECEIPT_LINES_RO%ISOPEN) THEN
      CLOSE RECEIPT_LINES_RO;
  END IF;

  IF(RECEIPT_LINES_BY_DATE%ISOPEN) THEN
      CLOSE RECEIPT_LINES_BY_DATE;
  END IF;

  -- Log seed messages for the number of records
  -- processed by rma update
  fnd_message.set_name('CSD','CSD_DRC_RMA_TOT_REC_PROC');
  fnd_message.set_token('TOT_REC',to_char(l_total_records));
  FND_MSG_PUB.ADD;

  -- Debug Messages
  Debug(fnd_message.get,l_mod_name,1);

  -- Log the number of records processed in concurrent
  -- program output and log file
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.put_line(fnd_file.output,fnd_message.get);

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
  END IF;

--bug#8261344
  If (l_warning_return) THEN
	  x_return_status := G_CSD_RET_STS_WARNING;
  End if;

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data  );
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR exception',l_mod_name,4 );
          ROLLBACK TO RMA_RCV_UPDATE;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR exception',l_mod_name,4 );
          ROLLBACK TO RMA_RCV_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('In OTHERS exception',l_mod_name,4 );
          ROLLBACK TO RMA_RCV_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END RMA_RCV_UPDATE;

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
/*    p_order_header_id  NUMBER   Optional   Internal sales order Id                   */
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
          p_order_header_id      IN   NUMBER
        ) IS

  -- Standard variables
  l_api_name            CONSTANT VARCHAR2(30) := 'IO_RCV_UPDATE';
  l_api_version         CONSTANT NUMBER       := 1.0;

  -- Variables used in API
  l_rep_hist_id         number;
  l_dummy               varchar2(30);
  l_serialized_flag     boolean;
  l_ord_remaining_qty   number := 0;
  l_prod_txn_exists     boolean;
  l_prod_txn_id         number := NULL;
  l_prod_txn_status     csd_product_transactions.prod_txn_status%type;
  l_total_qty           number;
  l_total_del_qty       number;
  l_total_accept_qty    number;
  l_total_reject_qty    number;
  l_pt_accept_qty       number;
  l_pt_reject_qty       number;
  l_pt_del_qty          number;
  l_accept_qty          number;
  l_reject_qty          number;
  l_serial_num          MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;
  l_lot_num             MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;
  l_rep_line_id         number;
  l_rcvd_qty            number;
  l_line_qty            number;
  l_line_del_qty        number;
  l_sub_inv             varchar2(80);
  l_instance_id         number;

  -- activity record
  l_activity_rec      activity_rec_type;

  -- Variable for the FND log file
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.io_rcv_update';

  -- User defined exception
  SKIP_RECORD    EXCEPTION;
  PROCESS_ERROR  EXCEPTION;

  -- Cursor to get the ro and product txn lines
  --
  CURSOR GET_RO_PROD_TXN_LINES_ALL IS
   select  cpt.product_transaction_id,
           cpt.prod_txn_status,
           cpt.repair_line_id,
           cpt.order_header_id,
           cpt.order_line_id,
           cpt.req_header_id,
           cpt.req_line_id,
           nvl(cpt.quantity_received,0) prod_txn_rcvd_qty,
           cra.quantity ro_qty,
           cra.quantity_rcvd ro_rcvd_qty,
           cra.inventory_item_id,
           cra.unit_of_measure ro_uom,
           prh.segment1 requisition_number,
           oel.ordered_quantity,
		 oeh.order_number
   from  csd_product_transactions cpt,
         csd_repairs cra,
         po_requisition_headers_all prh,
         oe_order_lines_all oel,
	    oe_order_headers_all oeh
   where cpt.repair_line_id = cra.repair_line_id
    AND  cpt.req_header_id  = prh.requisition_header_id
    AND  cpt.order_line_id  = oel.line_id
    AND  oel.header_id      = oeh.header_id
    AND  cpt.action_type    = 'MOVE_IN'
    AND  cpt.action_code    = 'DEFECTIVES'
    AND  cpt.prod_txn_status = 'SHIPPED'
    AND  cpt.order_line_id is not null
    --Vijay 11/4/04
--    AND  (p_ord_header_id IS null OR p_ord_header_id = cpt.order_header_id)
    AND  nvl(cra.quantity_rcvd,0) < cra.quantity;

--Begin Vijay 11/4/04
  -- Cursor to get the ro and product txn lines
  -- for the order header id
  CURSOR GET_RO_PROD_TXN_LINES (p_ord_header_id in number) IS
   select  cpt.product_transaction_id,
           cpt.prod_txn_status,
           cpt.repair_line_id,
           cpt.order_header_id,
           cpt.order_line_id,
           cpt.req_header_id,
           cpt.req_line_id,
           nvl(cpt.quantity_received,0) prod_txn_rcvd_qty,
           cra.quantity ro_qty,
           cra.quantity_rcvd ro_rcvd_qty,
           cra.inventory_item_id,
           cra.unit_of_measure ro_uom,
           prh.segment1 requisition_number,
           oel.ordered_quantity,
		 oeh.order_number
   from  csd_product_transactions cpt,
         csd_repairs cra,
         po_requisition_headers_all prh,
         oe_order_lines_all oel,
	    oe_order_headers_all oeh
   where cpt.repair_line_id = cra.repair_line_id
    AND  cpt.req_header_id  = prh.requisition_header_id
    AND  cpt.order_line_id  = oel.line_id
    AND  oel.header_id      = oeh.header_id
    AND  cpt.action_type    = 'MOVE_IN'
    AND  cpt.action_code    = 'DEFECTIVES'
    AND  cpt.prod_txn_status = 'SHIPPED'
    AND  cpt.order_line_id is not null
    AND   cpt.order_header_id = p_ord_header_id
    AND  nvl(cra.quantity_rcvd,0) < cra.quantity;

   RO IO_RCPT_LINES_Rec_Type;
--End Vijay 11/4/04


  -- Cursor to get all the rcv txn lines of transaction type
  -- DELIVER,REJECT,ACCEPT type
  CURSOR GET_RCV_LINES (p_req_line_id in number) IS
   select rcv.transaction_id,
          rcv.quantity rcvd_qty,
          rcv.unit_of_measure,
          rcv.subinventory,
          rcv.locator_id,
		rcv.organization_id,
          rcv.transaction_date received_date,
          rcv.transaction_type,
          rcv.shipment_header_id,
          rcv.shipment_line_id,
          prl.item_id,
          prl.destination_organization_id inv_org_id,
          prl.quantity requisition_qty,
          prh.segment1 requirement_number,
          mtl.serial_number_control_code,
		mtl.comms_nl_trackable_flag ib_flag,
          mtl.lot_control_code,
    	     hao.name org_name
   from  rcv_transactions rcv,
         po_requisition_lines_all prl,
         po_requisition_headers_all prh,
         mtl_system_items mtl,
         hr_all_organization_units hao
   where rcv.requisition_line_id = prl.requisition_line_id
    and  prl.item_id             = mtl.inventory_item_id
    and  prl.destination_organization_id = mtl.organization_id
    and  prl.requisition_header_id = prh.requisition_header_id
    and  rcv.requisition_line_id = p_req_line_id
    and  hao.organization_id     = rcv.organization_id
    and  rcv.transaction_type in ('DELIVER','ACCEPT','REJECT');

    -- Cursor to get the deliver txn line for the
    -- specific txn id
    CURSOR DELIVER_LINES (p_txn_id in number) IS
      Select rcvt.transaction_id,
             rcvt.transaction_date received_date,
             rcvt.subinventory,
             rcvt.quantity rcvd_qty,
             rcvt.organization_id,
             rcvt.locator_id,
		   hao.name org_name
      from  rcv_transactions rcvt,
	       hr_all_organization_units hao
     where rcvt.parent_transaction_id = p_txn_id
      and  rcvt.transaction_type  = 'DELIVER';

    CURSOR ORDER_INFO (p_ord_header_id in number) IS
     Select distinct
	       order_header_id,
	       order_line_id
     from  csd_product_transactions
	where order_header_id = p_ord_header_id
      AND  action_type     = 'MOVE_IN'
      AND  action_code     = 'DEFECTIVES'
	 AND  prod_txn_status = 'SHIPPED';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  IO_RCV_UPDATE;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug messages
   Debug('Beginning of IO_RCV_UPDATE',l_mod_name,1);
   Debug('Order Header Id='||to_char(p_order_header_id),l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Api body starts

   -- In case of Internal orders, the product txns are stamped
   -- with the order header id and line id.
   -- So Validate if it exists in csd_product_transactions
   IF  NVL(p_order_header_id,-999) <> -999 THEN
      BEGIN
          select 'EXISTS'
          into  l_dummy
          from  oe_order_headers_all oeh,
                po_requisition_headers_all prh
          where oeh.source_document_id = prh.requisition_header_id
           and  oeh.header_id = p_order_header_id
           and  exists (select 'x'
                       from csd_product_transactions cpt
                       where cpt.action_type = 'MOVE_IN'
                        and  cpt.action_code = 'DEFECTIVES'
                        and  cpt.order_header_id = oeh.header_id);
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             IF ( l_error_level >= G_debug_level) THEN
                 fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                 fnd_message.set_token('HEADER_ID',p_order_header_id);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
             ELSE
                 fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                 fnd_message.set_token('HEADER_ID',p_order_header_id);
                 fnd_msg_pub.add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
     END;
   END IF;


   --Loops thro the received lines that have txn type -'DELIVER','ACCEPT','REJECT'
   --While Processing the ACCEPT/REJECT txn lines, it also check if there is
   --any deliver txn lines with the parent txn id. If it finds then it also
   --update the delivered qty and logs activity for the deliver txns.
   --   Order Line
   --
   --    Line Id  Header Id   Ord Qty   Split_from_line_id
   --     L1          H1        1
   --     L2          H1        2           L1
   --     L3          H1        1           L2
   --
   --   RCV Lines
   --    Txn Id    Txn Type   Qty   Ord Line Id  Parent Txn Id
   --      T1      ACCEPT      1        L1
   --      T2      ACCEPT      2        L2
   --      T3      REJECT      1        L3
   --      T4      DELIVER     1        L1           T1
   --      T5      DELIVER     2        L2           T2
   --
   --
   --   1. Non- Serial
   --
   --     RO    RO  Qty  Prod Txn   Ord Line   Ord Header  Line Qty
   --     RO1    4       P1          L1           H1         1
   --     RO1    4       P2          L2           H1         2
   --     RO1    4       P3          L3           H1         1
   --   2. Serial
   --
   --     RO    RO  Qty  Prod Txn   Ord Line   Ord Header  Line Qty
   --     RO1    1        P1          L1           H1         1
   --     RO2    1        P2          L2           H1         1
   --     RO3    1        P3          L2           H1         1
   --     RO4    1        P4          L1           H1         1
   --
   -- THE PROGRAM IGNORES THE DELIVERED QUANTITY AGAINST THE REJECT TRANSACTIONS
   -- NEED TO REVIEW WITH PM AND IMPLEMENT AS A PHASE II PROJECT

   IF(p_order_header_id is null) THEN
      OPEN GET_RO_PROD_TXN_LINES_All;
   else
      OPEN GET_RO_PROD_TXN_LINES(p_order_header_id);
   END IF;


   /* Changed FOr loop for splitting the cursor : vijay 11/4/04*/
   --FOR RO IN GET_RO_PROD_TXN_LINES( p_order_header_id )
   LOOP
     BEGIN
       IF(p_order_header_id is null) THEN
          FETCH GET_RO_PROD_TXN_LINES_All INTO RO;
          EXIT WHEN GET_RO_PROD_TXN_LINES_All%NOTFOUND ;
       else
          FETCH GET_RO_PROD_TXN_LINES INTO RO;
          EXIT WHEN GET_RO_PROD_TXN_LINES%NOTFOUND ;
       END IF;

       -- savepoint
       SAVEPOINT RCV_LINES;

       -- Debug messages
       Debug('In RO loop',l_mod_name,1);

       FOR RCV IN GET_RCV_LINES (RO.req_line_id)
       LOOP
        BEGIN
          -- Debug messages
          Debug('In RCV loop',l_mod_name,1);

          IF RCV.transaction_type = 'ACCEPT' THEN
              --Handles Inspection Required Routing options

              -- Debug messages
              Debug('Processing Accept txn types',l_mod_name,1);

              select nvl(sum(paramn3),0)
              into  l_total_accept_qty
              from  csd_repair_history crh
              where crh.event_code = 'IP'
               and  crh.paramn1    = RCV.transaction_id;

              -- Debug messages
              Debug('l_total_accept_qty :'||l_total_accept_qty,l_mod_name,1);
              IF nvl(l_total_accept_qty,0) >= nvl(RCV.rcvd_qty,0) THEN
                  -- Debug messages
                  Debug('Skipping the record ',l_mod_name,1);
                  RAISE SKIP_RECORD;
              END IF;

              select nvl(sum(paramn4),0), nvl(sum(paramn3),0)
              into  l_pt_reject_qty, l_pt_accept_qty
              from  csd_repair_history crh
              where crh.event_code = 'IP'
               and  crh.paramn2    = RO.product_transaction_id;
               -- Debug messages
              Debug('l_pt_reject_qty :'||l_pt_reject_qty,l_mod_name,1);
              Debug('l_pt_accept_qty :'||l_pt_accept_qty,l_mod_name,1);

              IF RCV.serial_number_control_code in (2,5,6) THEN
                   l_line_qty := RO.ro_qty;
              ELSE
                   l_line_qty  := RO.ordered_quantity;
              END IF;

               -- Debug messages
              Debug('l_line_qty :'||l_line_qty,l_mod_name,1);

              IF (l_pt_reject_qty + l_pt_accept_qty) >= l_line_qty THEN
                   -- Debug messages
                  Debug('Exiting the RCV loop',l_mod_name,1);
                  EXIT;
              ELSE
                  l_accept_qty  :=  l_line_qty -(l_pt_reject_qty + l_pt_accept_qty);
                  IF RCV.rcvd_qty < l_accept_qty THEN
                       l_accept_qty := RCV.rcvd_qty;
                  END IF;
              END IF;


		    IF RCV.serial_number_control_code in (2,5,6) THEN
                 l_accept_qty := 1 ;
		    ELSE
                 l_accept_qty := l_accept_qty - l_total_accept_qty ;
		    END IF;

              -- Debug messages
              Debug('l_accept_qty :'||l_accept_qty,l_mod_name,1);

              -- Initialize the activity rec
              l_activity_rec := INIT_ACTIVITY_REC ;

              -- Assign the values for activity record
              l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
              l_activity_rec.REPAIR_LINE_ID := RO.repair_line_id;
              l_activity_rec.EVENT_CODE     := 'IP';
              l_activity_rec.ACTION_CODE    := 0;
              l_activity_rec.EVENT_DATE     := RCV.received_date;
              l_activity_rec.QUANTITY       := l_accept_qty;
              l_activity_rec.PARAMN1        := RCV.transaction_id;
              l_activity_rec.PARAMN2        := RO.product_transaction_id;
              l_activity_rec.PARAMN3        := l_accept_qty;
              l_activity_rec.PARAMN6        :=  RO.req_header_id;
              l_activity_rec.PARAMC1        :=  RO.requisition_number ;
              l_activity_rec.PARAMC2        :=  RCV.subinventory;
              l_activity_rec.OBJECT_VERSION_NUMBER := null;

              -- Debug Messages
              Debug('Calling LOG_ACTIVITY',l_mod_name,2);

              -- Calling LOG_ACTIVITY for logging activity
              LOG_ACTIVITY
                    ( p_api_version     => p_api_version,
                      p_commit          => p_commit,
                      p_init_msg_list   => p_init_msg_list,
                      p_validation_level => p_validation_level,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_activity_rec    => l_activity_rec );

              -- Debug Messages
              Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- Check if there are "DELIVER" txn lines against the accept lines
              -- If found, then process the deliver lines also
              FOR DEL IN DELIVER_LINES(RCV.transaction_id)
              LOOP
               BEGIN
                 -- Debug messages
                 Debug('In DEL Loop ',l_mod_name,1);

                 select nvl(sum(quantity),0)
                  into  l_total_del_qty
                  from csd_repair_history crh
                 where crh.event_code = 'RRI'
                  and  crh.paramn1    = DEL.transaction_id;
                 -- Debug messages
                 Debug('l_total_del_qty : '||l_total_del_qty,l_mod_name,1);

                 IF l_total_del_qty >= DEL.rcvd_qty THEN
                     -- Debug messages
                     Debug('Skipping the record',l_mod_name,1);
                     RAISE SKIP_RECORD;
                 END IF;

                 select nvl(sum(quantity),0)
                  into  l_pt_del_qty
                  from csd_repair_history crh
                 where crh.event_code = 'RRI'
                  and  crh.paramn2 = RO.product_transaction_id;
                  -- Debug messages
                  Debug('l_pt_del_qty : '||l_pt_del_qty,l_mod_name,1);

                 IF RCV.serial_number_control_code in (2,5,6) THEN
                     -- SERIALIZED CASE
                     Begin
                      select rcvt.serial_num,
                             rcvt.lot_num
                       into  l_serial_num,
                             l_lot_num
                       from  rcv_serial_transactions rcvt
                      where  rcvt.transaction_id = DEL.transaction_id
                       and   rownum = 1
                       and   not exists (Select 'NOT EXIST'
                                         from csd_repairs cra,
                                              csd_product_transactions cpt
                                         where cra.repair_line_id = cpt.repair_line_id
                                          and  cpt.action_type    = 'MOVE_IN'
                                          and  cpt.order_header_id = ro.order_header_id
                                          and  cra.serial_number  = rcvt.serial_num);
                    Exception
                        WHEN NO_DATA_FOUND THEN
                             IF ( l_error_level >= G_debug_level) THEN
                                fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                                fnd_message.set_token('TXN_ID',DEL.transaction_id);
                                FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                             ELSE
                                fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                                fnd_message.set_token('TXN_ID',DEL.transaction_id);
                                fnd_msg_pub.add;
                             END If;
                             RAISE PROCESS_ERROR;
                    END;
                    -- Get the instance id from
				-- installbase tables
				IF NVL(RCV.ib_flag,'N') = 'Y' THEN
				  BEGIN
                         Select instance_id
				     into   l_instance_id
				     from  csi_item_instances
				     where inventory_item_id = RCV.item_id
				      and  serial_number     = l_serial_num;
				  Exception
				     When NO_DATA_FOUND THEN
                            IF ( l_error_level >= G_debug_level) THEN
                                fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                                fnd_message.set_token('SERIAL_NUM',l_serial_num);
                                FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                            ELSE
                                fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                                fnd_message.set_token('SERIAL_NUM',l_serial_num);
                                fnd_msg_pub.add;
                            END If;
				     When Others THEN
                            IF ( l_error_level >= G_debug_level) THEN
                                fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                                fnd_message.set_token('SERIAL_NUM',l_serial_num);
                                FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                            ELSE
                                fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                                fnd_message.set_token('SERIAL_NUM',l_serial_num);
                                fnd_msg_pub.add;
                            END If;
                      End;
                    ELSE
				  l_instance_id := NULL;
                    END If;

                    l_line_del_qty  := RO.ro_qty;
                ELSE
                    -- Non-Serialized Case
                    l_serial_num := NULL;
                    l_line_del_qty   := RO.ordered_quantity;
                    l_instance_id := NULL;

                    --lot_control_code = 1 No control
                    --lot_control_code = 2 Full control
                   IF RCV.lot_control_code = 2 THEN
                     BEGIN
                       Select lot_num
                       into   l_lot_num
                       from rcv_lot_transactions
                       where source_transaction_id = DEL.transaction_id;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',DEL.transaction_id);
                              FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',DEL.transaction_id);
                              fnd_msg_pub.add;
                          END IF;
                          RAISE FND_API.G_EXC_ERROR;
                    END;
                  ELSE
                      l_lot_num := NULL;
                  END IF;
                END IF;

                IF l_pt_del_qty >= l_line_del_qty THEN
                    -- Debug messages
                    Debug('Exiting the loop',l_mod_name,1);
                    EXIT;
                ELSE
                    l_rcvd_qty := l_line_del_qty - l_pt_del_qty ;
                    IF DEL.rcvd_qty < l_rcvd_qty THEN
                        l_rcvd_qty := DEL.rcvd_qty;
                    END IF;
                END IF;

			 IF RCV.serial_number_control_code in (2,5,6) THEN
                   l_rcvd_qty  := 1;
			 ELSE
                   l_rcvd_qty  := l_rcvd_qty - l_total_del_qty;
                END IF;

                -- Debug messages
                Debug('l_rcvd_qty : '||l_rcvd_qty,l_mod_name,1);

                -- Update the serial number on repair order
                -- with the rcvd serial number
                UPDATE CSD_REPAIRS
                SET SERIAL_NUMBER = l_serial_num,
                    quantity_rcvd = nvl(quantity_rcvd,0) + l_rcvd_qty,
			     customer_product_id = l_instance_id,
		          object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE repair_line_id = RO.repair_line_id;
                IF SQL%NOTFOUND THEN
                   IF ( l_error_level >= G_debug_level) THEN
                        fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                        fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                        FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                   ELSE
                        fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                        fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                        fnd_msg_pub.add;
                   END IF;
                   RAISE PROCESS_ERROR;
                END IF;

                -- Updating the product txn with the serial number,lot number
                -- qty rcvd and subinventory
                -- sub_inventory_rcvd is used for IO and subinventory column
                -- is used for the regular RMA
                UPDATE CSD_PRODUCT_TRANSACTIONS
                SET SOURCE_SERIAL_NUMBER = l_serial_num,
			     source_instance_id   = l_instance_id,
                    LOT_NUMBER_RCVD      = l_lot_num,
                    LOCATOR_ID           = DEL.locator_id,
                    QUANTITY_RECEIVED  = NVL(QUANTITY_RECEIVED,0) + l_rcvd_qty,
                    SUB_INVENTORY_RCVD = DEL.subinventory,
		          object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE product_transaction_id = RO.product_transaction_id;
                IF SQL%NOTFOUND THEN
                     IF ( l_error_level >= G_debug_level) THEN
                         fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                         fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                         FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                     ELSE
                         fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                         fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                         fnd_msg_pub.add;
                     END IF;
                     RAISE PROCESS_ERROR;
                END IF;

			 IF RCV.serial_number_control_code in (2,5,6) THEN
			    UPDATE CSD_PRODUCT_TRANSACTIONS
                   SET prod_txn_status       = 'RECEIVED',
		             object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   WHERE product_transaction_id = RO.product_transaction_id;
                ELSE
			    UPDATE CSD_PRODUCT_TRANSACTIONS
                   SET prod_txn_status       = 'RECEIVED',
		             object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   WHERE quantity_received = RO.ordered_quantity
			    and   product_transaction_id = RO.product_transaction_id;
			 END IF;

                -- Initialize the activity rec
                l_activity_rec := INIT_ACTIVITY_REC ;

                -- Assign the values for activity record
                l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                l_activity_rec.REPAIR_LINE_ID := RO.repair_line_id;
                l_activity_rec.EVENT_CODE     := 'RRI';
                l_activity_rec.ACTION_CODE    := 0;
                l_activity_rec.EVENT_DATE     := DEL.received_date;
                l_activity_rec.QUANTITY       := l_rcvd_qty;
                l_activity_rec.PARAMN1        := DEL.transaction_id;
                l_activity_rec.PARAMN2        := RO.product_transaction_id;
                l_activity_rec.PARAMN3        := DEL.organization_id;
                l_activity_rec.PARAMN6        := RO.req_header_id;
                l_activity_rec.PARAMC1        := RO.order_number;
                l_activity_rec.PARAMC2        := RO.requisition_number;
                l_activity_rec.PARAMC3        := DEL.org_name;
                l_activity_rec.PARAMC4        := DEL.subinventory;
                l_activity_rec.OBJECT_VERSION_NUMBER := null;

                -- Debug Messages
                Debug('Calling LOG_ACTIVITY',l_mod_name,2);

                -- Calling LOG_ACTIVITY for logging activity
                -- Receipt of item against Internal Requisition
                LOG_ACTIVITY
                     ( p_api_version     => p_api_version,
                       p_commit          => p_commit,
                       p_init_msg_list   => p_init_msg_list,
                       p_validation_level => p_validation_level,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_activity_rec    => l_activity_rec );

                -- Debug Messages
                Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_pt_del_qty + l_rcvd_qty) >= l_line_del_qty  THEN
                    Debug(' Exiting the DEL loop',l_mod_name,1);
                    EXIT;
                END IF;
              Exception
                    WHEN PROCESS_ERROR THEN
                         Debug('In process_error exception ',l_mod_name,4);
                         RAISE PROCESS_ERROR;
                    WHEN SKIP_RECORD THEN
                         NULL;
              END;
            END LOOP; -- end of delivery lines

            IF (l_pt_reject_qty+ l_pt_accept_qty + l_accept_qty)>= l_line_qty THEN
                  Debug('Exiting RCV the loop ',l_mod_name,1);
                  EXIT;
            END IF;

       ELSIF RCV.transaction_type = 'REJECT' THEN
               -- Handles Inspection Required routing option

               select nvl(sum(paramn4),0)
                into  l_total_reject_qty
               from  csd_repair_history crh
               where crh.event_code = 'IP'
                and  crh.paramn1    = RCV.transaction_id;
               IF l_total_reject_qty >= RCV.rcvd_qty THEN
                   -- Debug messages
                   Debug('Skipping the record ',l_mod_name,1);
                   RAISE SKIP_RECORD;
               END IF;

               select nvl(sum(paramn3),0),nvl(sum(paramn4),0)
                into  l_pt_accept_qty, l_pt_reject_qty
               from  csd_repair_history crh
               where crh.event_code = 'IP'
                and  crh.paramn2 = RO.product_transaction_id;
               -- Debug messages
              Debug('l_pt_accept_qty'||l_pt_accept_qty,l_mod_name,1);
              Debug('l_pt_reject_qty'||l_pt_reject_qty,l_mod_name,1);

              IF RCV.serial_number_control_code in (2,5,6) THEN
                  l_line_qty := 1;
              ELSE
                  l_line_qty  := RO.ordered_quantity;
              END IF;
              IF l_pt_accept_qty+ l_pt_reject_qty >= l_line_qty THEN
                   -- Debug messages
                   Debug('Exiting the loop ',l_mod_name,1);
                   EXIT;
              ELSE
                  l_reject_qty := l_line_qty- (l_pt_accept_qty+ l_pt_reject_qty);
                  IF RCV.rcvd_qty < l_reject_qty THEN
                      l_reject_qty := RCV.rcvd_qty;
                  END IF;
              END IF;

		    IF RCV.serial_number_control_code in (2,5,6) THEN
                 l_reject_qty := 1;
		    ELSE
                 l_reject_qty := l_reject_qty - l_total_reject_qty;
              END IF;

              -- Debug messages
              Debug('l_reject_qty'||l_reject_qty,l_mod_name,1);

               -- Initialize the activity rec
              l_activity_rec := INIT_ACTIVITY_REC ;

               -- Assign the values for activity record
              l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
              l_activity_rec.REPAIR_LINE_ID :=  RO.repair_line_id;
              l_activity_rec.EVENT_CODE     :=  'IP';
              l_activity_rec.ACTION_CODE    :=  0;
              l_activity_rec.EVENT_DATE     :=  RCV.received_date;
              l_activity_rec.QUANTITY       :=  l_reject_qty;
              l_activity_rec.PARAMN1        :=  RCV.transaction_id;
              l_activity_rec.PARAMN2        :=  RO.product_transaction_id;
              l_activity_rec.PARAMN3        :=  null;
              l_activity_rec.PARAMN4        :=  l_reject_qty;
              l_activity_rec.PARAMN6        :=  RO.req_header_id;
              l_activity_rec.PARAMC1        :=  RO.requisition_number;
              l_activity_rec.PARAMC2        :=  rcv.subinventory;
              l_activity_rec.OBJECT_VERSION_NUMBER := null;

              -- Debug Messages
              Debug('Calling LOG_ACTIVITY',l_mod_name,2);

              -- Calling LOG_ACTIVITY for logging activity
              LOG_ACTIVITY
                     ( p_api_version     => p_api_version,
                       p_commit          => p_commit,
                       p_init_msg_list   => p_init_msg_list,
                       p_validation_level => p_validation_level,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_activity_rec    => l_activity_rec );

              -- Debug Messages
             Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

              -- Check if there are "DELIVER" txn lines against the reject lines
              -- If found, then process the deliver lines also
              FOR DEL IN DELIVER_LINES(RCV.transaction_id)
              LOOP
               BEGIN
                 -- Debug messages
                 Debug('In DEL Loop ',l_mod_name,1);

                 select nvl(sum(quantity),0)
                  into  l_total_del_qty
                  from csd_repair_history crh
                 where crh.event_code = 'RRI'
                  and  crh.paramn1    = DEL.transaction_id;
                 -- Debug messages
                 Debug('l_total_del_qty : '||l_total_del_qty,l_mod_name,1);

                 IF l_total_del_qty >= DEL.rcvd_qty THEN
                     -- Debug messages
                     Debug('Skipping the record',l_mod_name,1);
                     RAISE SKIP_RECORD;
                 END IF;

                 select nvl(sum(quantity),0)
                  into  l_pt_del_qty
                  from csd_repair_history crh
                 where crh.event_code = 'RRI'
                  and  crh.paramn2 = RO.product_transaction_id;
                  -- Debug messages
                  Debug('l_pt_del_qty : '||l_pt_del_qty,l_mod_name,1);

                 IF RCV.serial_number_control_code in (2,5,6) THEN
                     -- SERIALIZED CASE
                     Begin
                      select rcvt.serial_num,
                             rcvt.lot_num
                       into  l_serial_num,
                             l_lot_num
                       from  rcv_serial_transactions rcvt
                      where  rcvt.transaction_id = DEL.transaction_id
                       and   rownum = 1
                       and   not exists (Select 'NOT EXIST'
                                         from csd_repairs cra,
                                              csd_product_transactions cpt
                                         where cra.repair_line_id = cpt.repair_line_id
                                          and  cpt.action_type    = 'MOVE_IN'
                                          and  cpt.order_header_id = ro.order_header_id
                                          and  cra.serial_number  = rcvt.serial_num);
                    Exception
                        WHEN NO_DATA_FOUND THEN
                             IF ( l_error_level >= G_debug_level) THEN
                                fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                                fnd_message.set_token('TXN_ID',DEL.transaction_id);
                                FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                             ELSE
                                fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                                fnd_message.set_token('TXN_ID',DEL.transaction_id);
                                fnd_msg_pub.add;
                             END If;
                             RAISE PROCESS_ERROR;
                    END;
                    -- Get the instance id from
		          -- installbase tables
		          IF NVL(RCV.ib_flag,'N') = 'Y' THEN
				  BEGIN
                         Select instance_id
			          into   l_instance_id
			          from  csi_item_instances
			          where inventory_item_id = RCV.item_id
			           and  serial_number     = l_serial_num;
		            Exception
			         When NO_DATA_FOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                             fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                             fnd_message.set_token('SERIAL_NUM',l_serial_num);
                             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                             fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                             fnd_message.set_token('SERIAL_NUM',l_serial_num);
                             fnd_msg_pub.add;
                          END If;
			         When Others THEN
                          IF ( l_error_level >= G_debug_level) THEN
                             fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                             fnd_message.set_token('SERIAL_NUM',l_serial_num);
                             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                             fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                             fnd_message.set_token('SERIAL_NUM',l_serial_num);
                             fnd_msg_pub.add;
                          END If;
                      End;
                    ELSE
				  l_instance_id := NULL;
                    END IF;

                   l_line_del_qty  := RO.ro_qty;
                ELSE
                    -- Non-Serialized Case
                    l_serial_num := NULL;
                    l_line_del_qty   := RO.ordered_quantity;
                    l_instance_id  := NULL;

                    --lot_control_code = 1 No control
                    --lot_control_code = 2 Full control
                   IF RCV.lot_control_code = 2 THEN
                     BEGIN
                       Select lot_num
                       into   l_lot_num
                       from rcv_lot_transactions
                       where source_transaction_id = DEL.transaction_id;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',DEL.transaction_id);
                              FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',DEL.transaction_id);
                              fnd_msg_pub.add;
                          END IF;
                          RAISE FND_API.G_EXC_ERROR;
                    END;
                  ELSE
                      l_lot_num := NULL;
                  END IF;
                END IF;

                IF l_pt_del_qty >= l_line_del_qty THEN
                    -- Debug messages
                    Debug('Exiting the loop',l_mod_name,1);
                    EXIT;
                ELSE
                    l_rcvd_qty := l_line_del_qty - l_pt_del_qty ;
                    IF DEL.rcvd_qty < l_rcvd_qty THEN
                        l_rcvd_qty := DEL.rcvd_qty;
                    END IF;
                END IF;

			 IF RCV.serial_number_control_code in (2,5,6) THEN
                   l_rcvd_qty  := 1;
			 ELSE
                   l_rcvd_qty  := l_rcvd_qty - l_total_del_qty;
                END IF;

                -- Debug messages
                Debug('l_rcvd_qty : '||l_rcvd_qty,l_mod_name,1);

                -- Update the serial number on repair order
                -- with the rcvd serial number
                UPDATE CSD_REPAIRS
                SET SERIAL_NUMBER = l_serial_num,
                    quantity_rcvd = nvl(quantity_rcvd,0) + l_rcvd_qty,
				customer_product_id   = l_instance_id,
		          object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE repair_line_id = RO.repair_line_id;
                IF SQL%NOTFOUND THEN
                   IF ( l_error_level >= G_debug_level) THEN
                        fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                        fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                        FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                   ELSE
                        fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                        fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                        fnd_msg_pub.add;
                   END IF;
                   RAISE PROCESS_ERROR;
                END IF;


                -- Updating the product txn with the serial number,lot number
                -- qty rcvd and subinventory
                -- sub_inventory_rcvd is used for IO and subinventory column
                -- is used for the regular RMA
                UPDATE CSD_PRODUCT_TRANSACTIONS
                SET SOURCE_SERIAL_NUMBER = l_serial_num,
			     source_instance_id   = l_instance_id,
                    LOT_NUMBER_RCVD      = l_lot_num,
                    LOCATOR_ID           = DEL.locator_id,
                    QUANTITY_RECEIVED  = NVL(QUANTITY_RECEIVED,0) + l_rcvd_qty,
                    SUB_INVENTORY_RCVD = DEL.subinventory,
		          object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE product_transaction_id = RO.product_transaction_id;
                IF SQL%NOTFOUND THEN
                     IF ( l_error_level >= G_debug_level) THEN
                         fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                         fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                         FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                     ELSE
                         fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                         fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                         fnd_msg_pub.add;
                     END IF;
                     RAISE PROCESS_ERROR;
                END IF;

                IF RCV.serial_number_control_code in (2,5,6) THEN
			    UPDATE CSD_PRODUCT_TRANSACTIONS
                   SET prod_txn_status       = 'RECEIVED',
		             object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   WHERE product_transaction_id = RO.product_transaction_id;

			 ELSE
			    UPDATE CSD_PRODUCT_TRANSACTIONS
                   SET prod_txn_status       = 'RECEIVED',
		             object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   WHERE quantity_received = RO.ordered_quantity
			    and   product_transaction_id = RO.product_transaction_id;
                END IF;

                -- Initialize the activity rec
                l_activity_rec := INIT_ACTIVITY_REC ;

                -- Assign the values for activity record
                l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                l_activity_rec.REPAIR_LINE_ID := RO.repair_line_id;
                l_activity_rec.EVENT_CODE     := 'RRI';
                l_activity_rec.ACTION_CODE    := 0;
                l_activity_rec.EVENT_DATE     := DEL.received_date;
                l_activity_rec.QUANTITY       := l_rcvd_qty;
                l_activity_rec.PARAMN1        := DEL.transaction_id;
                l_activity_rec.PARAMN2        := RO.product_transaction_id;
                l_activity_rec.PARAMN3        := DEL.organization_id;
                l_activity_rec.PARAMN6        := RO.req_header_id;
                l_activity_rec.PARAMC1        := RO.order_number;
                l_activity_rec.PARAMC2        := RO.requisition_number;
                l_activity_rec.PARAMC3        := DEL.org_name;
                l_activity_rec.PARAMC4        := DEL.subinventory;
                l_activity_rec.OBJECT_VERSION_NUMBER := null;

                -- Debug Messages
                Debug('Calling LOG_ACTIVITY',l_mod_name,2);

                -- Calling LOG_ACTIVITY for logging activity
                -- Receipt of item against Internal Requisition
                LOG_ACTIVITY
                     ( p_api_version     => p_api_version,
                       p_commit          => p_commit,
                       p_init_msg_list   => p_init_msg_list,
                       p_validation_level => p_validation_level,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_activity_rec    => l_activity_rec );

                -- Debug Messages
                Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_pt_del_qty + l_rcvd_qty) >= l_line_del_qty  THEN
                    Debug(' Exiting the DEL loop',l_mod_name,1);
                    EXIT;
                END IF;
              Exception
                    WHEN PROCESS_ERROR THEN
                         Debug('In process_error exception ',l_mod_name,4);
                         RAISE PROCESS_ERROR;
                    WHEN SKIP_RECORD THEN
                         NULL;
              END;
            END LOOP; -- end of delivery lines

            IF l_pt_accept_qty+ l_pt_reject_qty+ l_reject_qty >= l_line_qty THEN
                 Debug(' Exiting the RCV loop',l_mod_name,1);
                 EXIT;
            END IF;

      ELSIF RCV.transaction_type = 'DELIVER' THEN
         -- Handles the Direct Delivery and standard routing options

           select nvl(sum(quantity),0)
            into  l_total_qty
            from csd_repair_history crh
           where crh.event_code = 'RRI'
            and  crh.paramn1    = RCV.transaction_id;
           IF l_total_qty >= RCV.rcvd_qty THEN
              -- Debug messages
              Debug(' Skipping the record',l_mod_name,1);
              RAISE SKIP_RECORD;
           END IF;

           select nvl(sum(quantity),0)
           into  l_pt_del_qty
           from  csd_repair_history crh
           where crh.event_code = 'RRI'
            and  paramn2        = RO.product_transaction_id;

           -- Debug messages
           Debug('l_pt_reject_qty='||l_pt_reject_qty,l_mod_name,1);
           Debug('l_pt_del_qty   ='||l_pt_del_qty,l_mod_name,1);

           IF RCV.serial_number_control_code in (2,5,6) THEN
               -- SERIALIZED AND LOT CONTROLLED CASE
              l_line_qty  := RO.ro_qty;
               Begin
                select rcvt.serial_num,
                       rcvt.lot_num
                 into  l_serial_num,
                       l_lot_num
                 from  rcv_serial_transactions rcvt
                where  rcvt.transaction_id = RCV.transaction_id
                 and   rownum = 1
                 and   not exists (Select 'NOT EXIST'
                                   from csd_repairs cra,
                                        csd_product_transactions cpt
                                   where cra.repair_line_id = cpt.repair_line_id
                                    and  cpt.order_header_id = ro.order_header_id
                                    and  cra.serial_number  = rcvt.serial_num);
              Exception
                WHEN NO_DATA_FOUND THEN
                    IF ( l_error_level >= G_debug_level) THEN
                        fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                        fnd_message.set_token('TXN_ID',RCV.transaction_id);
                        FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                    ELSE
                        fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                        fnd_message.set_token('TXN_ID',RCV.transaction_id);
                        fnd_msg_pub.add;
                    END IF;
                    RAISE PROCESS_ERROR;
              END;

              -- Get the instance id from
		    -- installbase tables
		    IF NVL(RCV.ib_flag,'N') = 'Y' THEN
		      BEGIN
                 Select instance_id
			  into   l_instance_id
			  from csi_item_instances
			  where inventory_item_id = RCV.item_id
			   and  serial_number     = l_serial_num;
		      Exception
			    When NO_DATA_FOUND THEN
                      IF ( l_error_level >= G_debug_level) THEN
                           fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                           fnd_message.set_token('SERIAL_NUM',l_serial_num);
                           FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                      ELSE
                           fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                           fnd_message.set_token('SERIAL_NUM',l_serial_num);
                           fnd_msg_pub.add;
                      END If;
			    When Others THEN
                      IF ( l_error_level >= G_debug_level) THEN
                           fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                           fnd_message.set_token('SERIAL_NUM',l_serial_num);
                           FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                      ELSE
                           fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                           fnd_message.set_token('SERIAL_NUM',l_serial_num);
                           fnd_msg_pub.add;
                      END If;
               End;
	   	    ELSE
                l_instance_id := NULL;
		    END IF;
	    ELSE
              -- Non-Serialized Case but lot controlled
              l_serial_num := NULL;
              l_line_qty   := RO.ordered_quantity;
              l_instance_id := NULL;

              --lot_control_code = 1 No control
              --lot_control_code = 2 Full control
              IF RCV.lot_control_code = 2 THEN
                  BEGIN
                     Select lot_num
                     into   l_lot_num
                     from rcv_lot_transactions
                     where source_transaction_id = RCV.transaction_id;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',RCV.transaction_id);
                              FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',RCV.transaction_id);
                              fnd_msg_pub.add;
                          END IF;
                          RAISE FND_API.G_EXC_ERROR;
                 END;
              ELSE
                  -- Non-Serialized Case but not lot controlled
                     l_lot_num := NULL;
              END IF;
          END IF;

          IF l_pt_del_qty >= l_line_qty  THEN
                Debug(' EXiting the RCV Loop',l_mod_name,1);
                EXIT;
          ELSE
                l_rcvd_qty :=  l_line_qty  - l_pt_del_qty;
                IF RCV.rcvd_qty <  l_rcvd_qty THEN
                    l_rcvd_qty := RCV.rcvd_qty;
                END IF;
          END IF;

          IF RCV.serial_number_control_code in (2,5,6) THEN
		   l_rcvd_qty := 1;
		ELSE
		   l_rcvd_qty := l_rcvd_qty - l_total_qty;
          END IF;

          -- Debug messages
          Debug('l_rcvd_qty'||l_rcvd_qty,l_mod_name,1);

          -- Update repair order with the rcvd serial number
          -- and the rcvd qty
          UPDATE CSD_REPAIRS
          SET SERIAL_NUMBER = l_serial_num,
              quantity_rcvd = nvl(quantity_rcvd,0) + l_rcvd_qty,
		    customer_product_id = l_instance_id,
		    object_version_number = object_version_number+1,
              last_update_date = sysdate,
              last_updated_by  = fnd_global.user_id,
              last_update_login = fnd_global.login_id
          WHERE repair_line_id = RO.repair_line_id;
          IF SQL%NOTFOUND THEN
               IF ( l_error_level >= G_debug_level) THEN
                    fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                    fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                    FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
               ELSE
                    fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                    fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                    fnd_msg_pub.add;
               END IF;
               RAISE PROCESS_ERROR;
          END IF;


          -- Update product txn with the rcvd serial number,lot number
          -- locator id, sub inv, status and the rcvd qty
          UPDATE CSD_PRODUCT_TRANSACTIONS
          SET SOURCE_SERIAL_NUMBER = l_serial_num,
		    source_instance_id   = l_instance_id,
              LOT_NUMBER_RCVD      = l_lot_num,
              QUANTITY_RECEIVED = NVL(QUANTITY_RECEIVED,0) + l_rcvd_qty,
              SUB_INVENTORY_RCVD= RCV.subinventory,
              LOCATOR_ID        = RCV.locator_id,
		    object_version_number = object_version_number+1,
              last_update_date = sysdate,
              last_updated_by  = fnd_global.user_id,
              last_update_login = fnd_global.login_id
          WHERE product_transaction_id = RO.product_transaction_id;
          IF SQL%NOTFOUND THEN
              IF ( l_error_level >= G_debug_level) THEN
                    fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                    fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                    FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
              ELSE
                    fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                    fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                    fnd_msg_pub.add;
              END IF;
              RAISE PROCESS_ERROR;
          END IF;

          IF RCV.serial_number_control_code in (2,5,6) THEN
		   UPDATE CSD_PRODUCT_TRANSACTIONS
             SET prod_txn_status       = 'RECEIVED',
                 object_version_number = object_version_number+1,
                 last_update_date = sysdate,
                 last_updated_by  = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
             WHERE product_transaction_id = RO.product_transaction_id;
          ELSE
		   UPDATE CSD_PRODUCT_TRANSACTIONS
             SET prod_txn_status       = 'RECEIVED',
                 object_version_number = object_version_number+1,
                 last_update_date = sysdate,
                 last_updated_by  = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
             WHERE quantity_received = RO.ordered_quantity
             and   product_transaction_id = RO.product_transaction_id;
		END IF;

          -- Initialize the activity rec
          l_activity_rec := INIT_ACTIVITY_REC ;

          -- Assign the values for activity record
          l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
          l_activity_rec.REPAIR_LINE_ID := RO.repair_line_id;
          l_activity_rec.EVENT_CODE     := 'RRI';
          l_activity_rec.ACTION_CODE    := 0;
          l_activity_rec.EVENT_DATE     := RCV.received_date;
          l_activity_rec.QUANTITY       := l_rcvd_qty;
          l_activity_rec.PARAMN1        := RCV.transaction_id;
          l_activity_rec.PARAMN2        := RO.product_transaction_id;
          l_activity_rec.PARAMN3        := RCV.organization_id;
          l_activity_rec.PARAMN6        :=  RO.req_header_id;
          l_activity_rec.PARAMC1        :=  RO.order_number;
          l_activity_rec.PARAMC2        :=  RO.requisition_number;
          l_activity_rec.PARAMC3        :=  RCV.org_name;
          l_activity_rec.PARAMC4        :=  RCV.subinventory;
          l_activity_rec.OBJECT_VERSION_NUMBER := null;

          -- Debug Messages
          Debug('Calling LOG_ACTIVITY',l_mod_name,2);

          -- Calling LOG_ACTIVITY for logging activity
          LOG_ACTIVITY
                ( p_api_version     => p_api_version,
                  p_commit          => p_commit,
                  p_init_msg_list   => p_init_msg_list,
                  p_validation_level => p_validation_level,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_activity_rec    => l_activity_rec );

            -- Debug Messages
            Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                Debug('LOG_ACTIVITY api failed ',l_mod_name,1);
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF  l_pt_del_qty+ l_rcvd_qty >= l_line_qty   THEN
                Debug(' exiting the RCV loop',l_mod_name,1);
                EXIT;
           END IF;
          END IF;
        Exception
           WHEN PROCESS_ERROR THEN
                 Debug(' In Process error exception',l_mod_name,4);
                 RAISE PROCESS_ERROR;
            WHEN SKIP_RECORD THEN
                 NULL;
        END;
       END LOOP;
     Exception
        WHEN PROCESS_ERROR THEN
            ROLLBACK TO RCV_LINES;
            Debug(' In Process error exception, exiting the loop',l_mod_name,1);
            -- In case of error, exit the loop. Commit the processed records
            -- and rollback the error record
            --RAISE FND_API.G_EXC_ERROR;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT;
     END;
   END LOOP;

    --Added by Vijay 11/4/04
   IF(GET_RO_PROD_TXN_LINES_All%ISOPEN) THEN
       CLOSE GET_RO_PROD_TXN_LINES_All;
   END IF;
   IF(GET_RO_PROD_TXN_LINES%ISOPEN) THEN
       CLOSE GET_RO_PROD_TXN_LINES;
   END IF;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data);
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR exception',l_mod_name,4);
          ROLLBACK TO IO_RCV_UPDATE;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR exception',l_mod_name,4);
          ROLLBACK TO IO_RCV_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('In OTHERS exception',l_mod_name,4);
          ROLLBACK TO IO_RCV_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END IO_RCV_UPDATE;


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
/*   24-Apr-2007  swai  Initial Creation.  Bug#5564180 / FP#5845995                    */
/*-------------------------------------------------------------------------------------*/

Procedure IO_RCV_UPDATE_MOVE_OUT
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_order_header_id      IN   NUMBER
        ) IS

  -- Standard variables
  l_api_name            CONSTANT VARCHAR2(30) := 'IO_RCV_UPDATE_MOVE_OUT';
  l_api_version         CONSTANT NUMBER       := 1.0;

  -- Variables used in API
  l_rep_hist_id         number;
  l_dummy               varchar2(30);
  l_serialized_flag     boolean;
  l_ord_remaining_qty   number := 0;
  l_prod_txn_exists     boolean;
  l_prod_txn_id         number := NULL;
  l_prod_txn_status     csd_product_transactions.prod_txn_status%type;
  l_total_qty           number;
  l_total_del_qty       number;
  l_total_accept_qty    number;
  l_total_reject_qty    number;
  l_pt_accept_qty       number;
  l_pt_reject_qty       number;
  l_pt_del_qty          number;
  l_accept_qty          number;
  l_reject_qty          number;
  l_serial_num          MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;
  l_lot_num             MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;
  l_rep_line_id         number;
  l_rcvd_qty            number;
  l_line_qty            number;
  l_line_del_qty        number;
  l_sub_inv             varchar2(80);
  l_instance_id         number;

  -- activity record
  l_activity_rec      activity_rec_type;

  -- Variable for the FND log file
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.io_rcv_update_move_out';

  -- User defined exception
  SKIP_RECORD    EXCEPTION;
  PROCESS_ERROR  EXCEPTION;

  -- Cursor to get the ro and product txn lines
  --
  CURSOR GET_RO_PROD_TXN_LINES_ALL IS
   select  cpt.product_transaction_id,
           cpt.prod_txn_status,
           cpt.repair_line_id,
           cpt.order_header_id,
           cpt.order_line_id,
           cpt.req_header_id,
           cpt.req_line_id,
           nvl(cpt.quantity_received,0) prod_txn_rcvd_qty,
           cra.quantity ro_qty,
           cra.quantity_rcvd ro_rcvd_qty,
           cra.inventory_item_id,
           cra.unit_of_measure ro_uom,
           prh.segment1 requisition_number,
           oel.ordered_quantity,
                 oeh.order_number
   from  csd_product_transactions cpt,
         csd_repairs cra,
         po_requisition_headers_all prh,
         oe_order_lines_all oel,
            oe_order_headers_all oeh
   where cpt.repair_line_id = cra.repair_line_id
    AND  cpt.req_header_id  = prh.requisition_header_id
    AND  cpt.order_line_id  = oel.line_id
    AND  oel.header_id      = oeh.header_id
    AND  cpt.action_type    = 'MOVE_OUT'
    AND  cpt.action_code    = 'USABLES'
    AND  cpt.prod_txn_status = 'SHIPPED'
    AND  cpt.order_line_id is not null;
    /*Bug#5564180/FP#5845995 below condition is not required for move out line
      otherwise once the move in line is received the move out line
     will not be updated with status received */
--    AND  nvl(cra.quantity_rcvd,0) < cra.quantity;

  -- Cursor to get the ro and product txn lines
  -- for the order header id
  CURSOR GET_RO_PROD_TXN_LINES (p_ord_header_id in number) IS
   select  cpt.product_transaction_id,
           cpt.prod_txn_status,
           cpt.repair_line_id,
           cpt.order_header_id,
           cpt.order_line_id,
           cpt.req_header_id,
           cpt.req_line_id,
           nvl(cpt.quantity_received,0) prod_txn_rcvd_qty,
           cra.quantity ro_qty,
           cra.quantity_rcvd ro_rcvd_qty,
           cra.inventory_item_id,
           cra.unit_of_measure ro_uom,
           prh.segment1 requisition_number,
           oel.ordered_quantity,
                 oeh.order_number
   from  csd_product_transactions cpt,
         csd_repairs cra,
         po_requisition_headers_all prh,
         oe_order_lines_all oel,
            oe_order_headers_all oeh
   where cpt.repair_line_id = cra.repair_line_id
    AND  cpt.req_header_id  = prh.requisition_header_id
    AND  cpt.order_line_id  = oel.line_id
    AND  oel.header_id      = oeh.header_id
    AND  cpt.action_type    = 'MOVE_OUT'
    AND  cpt.action_code    = 'USABLES'
    AND  cpt.prod_txn_status = 'SHIPPED'
    AND  cpt.order_line_id is not null
    AND   cpt.order_header_id = p_ord_header_id;
    /*Bug#5564180/FP#5845995 below condition not required for move out line
      otherwise once the move in line is received the move out line will
     not be updated with status received */
--    AND  nvl(cra.quantity_rcvd,0) < cra.quantity;

   RO IO_RCPT_LINES_Rec_Type;


  -- Cursor to get all the rcv txn lines of transaction type
  -- DELIVER,REJECT,ACCEPT type
  CURSOR GET_RCV_LINES (p_req_line_id in number) IS
   select rcv.transaction_id,
          rcv.quantity rcvd_qty,
          rcv.unit_of_measure,
          rcv.subinventory,
          rcv.locator_id,
                rcv.organization_id,
          rcv.transaction_date received_date,
          rcv.transaction_type,
          rcv.shipment_header_id,
          rcv.shipment_line_id,
          prl.item_id,
          prl.destination_organization_id inv_org_id,
          prl.quantity requisition_qty,
          prh.segment1 requirement_number,
          mtl.serial_number_control_code,
                mtl.comms_nl_trackable_flag ib_flag,
          mtl.lot_control_code,
             hao.name org_name
   from  rcv_transactions rcv,
         po_requisition_lines_all prl,
         po_requisition_headers_all prh,
         mtl_system_items mtl,
         hr_all_organization_units hao
   where rcv.requisition_line_id = prl.requisition_line_id
    and  prl.item_id             = mtl.inventory_item_id
    and  prl.destination_organization_id = mtl.organization_id
    and  prl.requisition_header_id = prh.requisition_header_id
    and  rcv.requisition_line_id = p_req_line_id
    and  hao.organization_id     = rcv.organization_id
    and  rcv.transaction_type in ('DELIVER','ACCEPT','REJECT');

    -- Cursor to get the deliver txn line for the
    -- specific txn id
    CURSOR DELIVER_LINES (p_txn_id in number) IS
      Select rcvt.transaction_id,
             rcvt.transaction_date received_date,
             rcvt.subinventory,
             rcvt.quantity rcvd_qty,
             rcvt.organization_id,
             rcvt.locator_id,
                   hao.name org_name
      from  rcv_transactions rcvt,
               hr_all_organization_units hao
     where rcvt.parent_transaction_id = p_txn_id
      and  rcvt.transaction_type  = 'DELIVER';

    CURSOR ORDER_INFO (p_ord_header_id in number) IS
     Select distinct
               order_header_id,
               order_line_id
     from  csd_product_transactions
        where order_header_id = p_ord_header_id
      AND  action_type     = 'MOVE_OUT'
      AND  action_code     = 'USABLES'
         AND  prod_txn_status = 'SHIPPED';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  IO_RCV_UPDATE_MOVE_OUT;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug messages
   Debug('Beginning of IO_RCV_UPDATE_MOVE_OUT',l_mod_name,1);
   Debug('Order Header Id='||to_char(p_order_header_id),l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Api body starts

   -- In case of Internal orders, the product txns are stamped
   -- with the order header id and line id.
   -- So Validate if it exists in csd_product_transactions
   IF  NVL(p_order_header_id,-999) <> -999 THEN
      BEGIN
          select 'EXISTS'
          into  l_dummy
          from  oe_order_headers_all oeh,
                po_requisition_headers_all prh
          where oeh.source_document_id = prh.requisition_header_id
           and  oeh.header_id = p_order_header_id
           and  exists (select 'x'
                       from csd_product_transactions cpt
                       where cpt.action_type = 'MOVE_OUT'
                        and  cpt.action_code = 'USABLES'
                        and  cpt.order_header_id = oeh.header_id);
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             IF ( l_error_level >= G_debug_level) THEN
                 fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                 fnd_message.set_token('HEADER_ID',p_order_header_id);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
             ELSE
                 fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                 fnd_message.set_token('HEADER_ID',p_order_header_id);
                 fnd_msg_pub.add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
     END;
   END IF;


   --Loops thro the received lines that have txn type -'DELIVER','ACCEPT','REJECT'
   --While Processing the ACCEPT/REJECT txn lines, it also check if there is
   --any deliver txn lines with the parent txn id. If it finds then it also
   --update the delivered qty and logs activity for the deliver txns.
   --   Order Line
   --
   --    Line Id  Header Id   Ord Qty   Split_from_line_id
   --     L1          H1        1
   --     L2          H1        2           L1
   --     L3          H1        1           L2
   --
   --   RCV Lines
   --    Txn Id    Txn Type   Qty   Ord Line Id  Parent Txn Id
   --      T1      ACCEPT      1        L1
   --      T2      ACCEPT      2        L2
   --      T3      REJECT      1        L3
   --      T4      DELIVER     1        L1           T1
   --      T5      DELIVER     2        L2           T2
   --
   --
   --   1. Non- Serial
   --
   --     RO    RO  Qty  Prod Txn   Ord Line   Ord Header  Line Qty
   --     RO1    4       P1          L1           H1         1
   --     RO1    4       P2          L2           H1         2
   --     RO1    4       P3          L3           H1         1
   --   2. Serial
   --
   --     RO    RO  Qty  Prod Txn   Ord Line   Ord Header  Line Qty
   --     RO1    1        P1          L1           H1         1
   --     RO2    1        P2          L2           H1         1
   --     RO3    1        P3          L2           H1         1
   --     RO4    1        P4          L1           H1         1
   --
   -- THE PROGRAM IGNORES THE DELIVERED QUANTITY AGAINST THE REJECT TRANSACTIONS
   -- NEED TO REVIEW WITH PM AND IMPLEMENT AS A PHASE II PROJECT

   IF(p_order_header_id is null) THEN
      OPEN GET_RO_PROD_TXN_LINES_All;
   else
      OPEN GET_RO_PROD_TXN_LINES(p_order_header_id);
   END IF;


   /* Changed FOr loop for splitting the cursor : vijay 11/4/04*/
   --FOR RO IN GET_RO_PROD_TXN_LINES( p_order_header_id )
   LOOP
     BEGIN
       IF(p_order_header_id is null) THEN
          FETCH GET_RO_PROD_TXN_LINES_All INTO RO;
          EXIT WHEN GET_RO_PROD_TXN_LINES_All%NOTFOUND ;
       else
          FETCH GET_RO_PROD_TXN_LINES INTO RO;
          EXIT WHEN GET_RO_PROD_TXN_LINES%NOTFOUND ;
       END IF;

       -- savepoint
       SAVEPOINT RCV_LINES;

       -- Debug messages
       Debug('In RO loop',l_mod_name,1);

       FOR RCV IN GET_RCV_LINES (RO.req_line_id)
       LOOP
        BEGIN
          -- Debug messages
          Debug('In RCV loop',l_mod_name,1);

          IF RCV.transaction_type = 'ACCEPT' THEN
              --Handles Inspection Required Routing options

              -- Debug messages
              Debug('Processing Accept txn types',l_mod_name,1);

              select nvl(sum(paramn3),0)
              into  l_total_accept_qty
              from  csd_repair_history crh
              where crh.event_code = 'IP'
               and  crh.paramn1    = RCV.transaction_id;

              -- Debug messages
              Debug('l_total_accept_qty :'||l_total_accept_qty,l_mod_name,1);
              IF nvl(l_total_accept_qty,0) >= nvl(RCV.rcvd_qty,0) THEN
                  -- Debug messages
                  Debug('Skipping the record ',l_mod_name,1);
                  RAISE SKIP_RECORD;
              END IF;

              select nvl(sum(paramn4),0), nvl(sum(paramn3),0)
              into  l_pt_reject_qty, l_pt_accept_qty
              from  csd_repair_history crh
              where crh.event_code = 'IP'
               and  crh.paramn2    = RO.product_transaction_id;
               -- Debug messages
              Debug('l_pt_reject_qty :'||l_pt_reject_qty,l_mod_name,1);
              Debug('l_pt_accept_qty :'||l_pt_accept_qty,l_mod_name,1);

              IF RCV.serial_number_control_code in (2,5,6) THEN
                   l_line_qty := RO.ro_qty;
              ELSE
                   l_line_qty  := RO.ordered_quantity;
              END IF;

               -- Debug messages
              Debug('l_line_qty :'||l_line_qty,l_mod_name,1);

              IF (l_pt_reject_qty + l_pt_accept_qty) >= l_line_qty THEN
                   -- Debug messages
                  Debug('Exiting the RCV loop',l_mod_name,1);
                  EXIT;
              ELSE
                  l_accept_qty  :=  l_line_qty -(l_pt_reject_qty + l_pt_accept_qty);
                  IF RCV.rcvd_qty < l_accept_qty THEN
                       l_accept_qty := RCV.rcvd_qty;
                  END IF;
              END IF;


                    IF RCV.serial_number_control_code in (2,5,6) THEN
                 l_accept_qty := 1 ;
                    ELSE
                 l_accept_qty := l_accept_qty - l_total_accept_qty ;
                    END IF;

              -- Debug messages
              Debug('l_accept_qty :'||l_accept_qty,l_mod_name,1);

              -- Initialize the activity rec
              l_activity_rec := INIT_ACTIVITY_REC ;

              -- Assign the values for activity record
              l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
              l_activity_rec.REPAIR_LINE_ID := RO.repair_line_id;
              l_activity_rec.EVENT_CODE     := 'IP';
              l_activity_rec.ACTION_CODE    := 0;
              l_activity_rec.EVENT_DATE     := RCV.received_date;
              l_activity_rec.QUANTITY       := l_accept_qty;
              l_activity_rec.PARAMN1        := RCV.transaction_id;
              l_activity_rec.PARAMN2        := RO.product_transaction_id;
              l_activity_rec.PARAMN3        := l_accept_qty;
              l_activity_rec.PARAMN6        :=  RO.req_header_id;
              l_activity_rec.PARAMC1        :=  RO.requisition_number ;
              l_activity_rec.PARAMC2        :=  RCV.subinventory;
              l_activity_rec.OBJECT_VERSION_NUMBER := null;

              -- Debug Messages
              Debug('Calling LOG_ACTIVITY',l_mod_name,2);

              -- Calling LOG_ACTIVITY for logging activity
              LOG_ACTIVITY
                    ( p_api_version     => p_api_version,
                      p_commit          => p_commit,
                      p_init_msg_list   => p_init_msg_list,
                      p_validation_level => p_validation_level,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_activity_rec    => l_activity_rec );

              -- Debug Messages
              Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- Check if there are "DELIVER" txn lines against the accept lines
              -- If found, then process the deliver lines also
              FOR DEL IN DELIVER_LINES(RCV.transaction_id)
              LOOP
               BEGIN
                 -- Debug messages
                 Debug('In DEL Loop ',l_mod_name,1);

                 select nvl(sum(quantity),0)
                  into  l_total_del_qty
                  from csd_repair_history crh
                 where crh.event_code = 'RRI'
                  and  crh.paramn1    = DEL.transaction_id;
                 -- Debug messages
                 Debug('l_total_del_qty : '||l_total_del_qty,l_mod_name,1);

                 IF l_total_del_qty >= DEL.rcvd_qty THEN
                     -- Debug messages
                     Debug('Skipping the record',l_mod_name,1);
                     RAISE SKIP_RECORD;
                 END IF;

                 select nvl(sum(quantity),0)
                  into  l_pt_del_qty
                  from csd_repair_history crh
                 where crh.event_code = 'RRI'
                  and  crh.paramn2 = RO.product_transaction_id;
                  -- Debug messages
                  Debug('l_pt_del_qty : '||l_pt_del_qty,l_mod_name,1);

                 IF RCV.serial_number_control_code in (2,5,6) THEN
                     -- SERIALIZED CASE
                     Begin
                      select rcvt.serial_num,
                             rcvt.lot_num
                       into  l_serial_num,
                             l_lot_num
                       from  rcv_serial_transactions rcvt
                      where  rcvt.transaction_id = DEL.transaction_id
                       and   rownum = 1
                       and   not exists (Select 'NOT EXIST'
                                         from csd_repairs cra,
                                              csd_product_transactions cpt
                                         where cra.repair_line_id = cpt.repair_line_id
                                          and  cpt.action_type    = 'MOVE_OUT'
                                          and  cpt.order_header_id = ro.order_header_id
                                          and  cra.serial_number  = rcvt.serial_num);
                    Exception
                        WHEN NO_DATA_FOUND THEN
                             IF ( l_error_level >= G_debug_level) THEN
                                fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                                fnd_message.set_token('TXN_ID',DEL.transaction_id);
                                FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                             ELSE
                                fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                                fnd_message.set_token('TXN_ID',DEL.transaction_id);
                                fnd_msg_pub.add;
                             END If;
                             RAISE PROCESS_ERROR;
                    END;
                    -- Get the instance id from
                                -- installbase tables
                                IF NVL(RCV.ib_flag,'N') = 'Y' THEN
                                  BEGIN
                         Select instance_id
                                     into   l_instance_id
                                     from  csi_item_instances
                                     where inventory_item_id = RCV.item_id
                                      and  serial_number     = l_serial_num;
                                  Exception
                                     When NO_DATA_FOUND THEN
                            IF ( l_error_level >= G_debug_level) THEN
                                fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                                fnd_message.set_token('SERIAL_NUM',l_serial_num);
                                FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                            ELSE
                                fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                                fnd_message.set_token('SERIAL_NUM',l_serial_num);
                                fnd_msg_pub.add;
                            END If;
                                     When Others THEN
                            IF ( l_error_level >= G_debug_level) THEN
                                fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                                fnd_message.set_token('SERIAL_NUM',l_serial_num);
                                FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                            ELSE
                                fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                                fnd_message.set_token('SERIAL_NUM',l_serial_num);
                                fnd_msg_pub.add;
                            END If;
                      End;
                    ELSE
                                  l_instance_id := NULL;
                    END If;

                    l_line_del_qty  := RO.ro_qty;
                ELSE
                    -- Non-Serialized Case
                    l_serial_num := NULL;
                    l_line_del_qty   := RO.ordered_quantity;
                    l_instance_id := NULL;

                    --lot_control_code = 1 No control
                    --lot_control_code = 2 Full control
                   IF RCV.lot_control_code = 2 THEN
                     BEGIN
                       Select lot_num
                       into   l_lot_num
                       from rcv_lot_transactions
                       where source_transaction_id = DEL.transaction_id;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',DEL.transaction_id);
                              FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',DEL.transaction_id);
                              fnd_msg_pub.add;
                          END IF;
                          RAISE FND_API.G_EXC_ERROR;
                    END;
                  ELSE
                      l_lot_num := NULL;
                  END IF;
                END IF;

                IF l_pt_del_qty >= l_line_del_qty THEN
                    -- Debug messages
                    Debug('Exiting the loop',l_mod_name,1);
                    EXIT;
                ELSE
                    l_rcvd_qty := l_line_del_qty - l_pt_del_qty ;
                    IF DEL.rcvd_qty < l_rcvd_qty THEN
                        l_rcvd_qty := DEL.rcvd_qty;
                    END IF;
                END IF;

                         IF RCV.serial_number_control_code in (2,5,6) THEN
                   l_rcvd_qty  := 1;
                         ELSE
                   l_rcvd_qty  := l_rcvd_qty - l_total_del_qty;
                END IF;

                -- Debug messages
                Debug('l_rcvd_qty : '||l_rcvd_qty,l_mod_name,1);

                -- Update the serial number on repair order
                -- with the rcvd serial number
             /*Bug#5564180/FP#5845995 Move out line should not update the received quantity of
             RO. Move out line should not change the serial and instance number of RO
             so commenting the below query
             */
             /*
                UPDATE CSD_REPAIRS
                SET SERIAL_NUMBER = l_serial_num,
                    quantity_rcvd = nvl(quantity_rcvd,0) + l_rcvd_qty,
                             customer_product_id = l_instance_id,
                          object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE repair_line_id = RO.repair_line_id;
                IF SQL%NOTFOUND THEN
                   IF ( l_error_level >= G_debug_level) THEN
                        fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                        fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                        FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                   ELSE
                        fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                        fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                        fnd_msg_pub.add;
                   END IF;
                   RAISE PROCESS_ERROR;
                END IF;
                */
                -- Updating the product txn with the serial number,lot number
                -- qty rcvd and subinventory
                -- sub_inventory_rcvd is used for IO and subinventory column
                -- is used for the regular RMA
                UPDATE CSD_PRODUCT_TRANSACTIONS
                SET SOURCE_SERIAL_NUMBER = l_serial_num,
                             source_instance_id   = l_instance_id,
                    LOT_NUMBER_RCVD      = l_lot_num,
                    LOCATOR_ID           = DEL.locator_id,
                    QUANTITY_RECEIVED  = NVL(QUANTITY_RECEIVED,0) + l_rcvd_qty,
                    SUB_INVENTORY_RCVD = DEL.subinventory,
                          object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE product_transaction_id = RO.product_transaction_id;
                IF SQL%NOTFOUND THEN
                     IF ( l_error_level >= G_debug_level) THEN
                         fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                         fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                         FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                     ELSE
                         fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                         fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                         fnd_msg_pub.add;
                     END IF;
                     RAISE PROCESS_ERROR;
                END IF;

                         IF RCV.serial_number_control_code in (2,5,6) THEN
                            UPDATE CSD_PRODUCT_TRANSACTIONS
                   SET prod_txn_status       = 'RECEIVED',
                             object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   WHERE product_transaction_id = RO.product_transaction_id;
                ELSE
                            UPDATE CSD_PRODUCT_TRANSACTIONS
                   SET prod_txn_status       = 'RECEIVED',
                             object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   WHERE quantity_received = RO.ordered_quantity
                            and   product_transaction_id = RO.product_transaction_id;
                         END IF;

                -- Initialize the activity rec
                l_activity_rec := INIT_ACTIVITY_REC ;

                -- Assign the values for activity record
                l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                l_activity_rec.REPAIR_LINE_ID := RO.repair_line_id;
                l_activity_rec.EVENT_CODE     := 'RRI';
                l_activity_rec.ACTION_CODE    := 0;
                l_activity_rec.EVENT_DATE     := DEL.received_date;
                l_activity_rec.QUANTITY       := l_rcvd_qty;
                l_activity_rec.PARAMN1        := DEL.transaction_id;
                l_activity_rec.PARAMN2        := RO.product_transaction_id;
                l_activity_rec.PARAMN3        := DEL.organization_id;
                l_activity_rec.PARAMN6        := RO.req_header_id;
                l_activity_rec.PARAMC1        := RO.order_number;
                l_activity_rec.PARAMC2        := RO.requisition_number;
                l_activity_rec.PARAMC3        := DEL.org_name;
                l_activity_rec.PARAMC4        := DEL.subinventory;
                l_activity_rec.OBJECT_VERSION_NUMBER := null;

                -- Debug Messages
                Debug('Calling LOG_ACTIVITY',l_mod_name,2);

                -- Calling LOG_ACTIVITY for logging activity
                -- Receipt of item against Internal Requisition
                LOG_ACTIVITY
                     ( p_api_version     => p_api_version,
                       p_commit          => p_commit,
                       p_init_msg_list   => p_init_msg_list,
                       p_validation_level => p_validation_level,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_activity_rec    => l_activity_rec );

                -- Debug Messages
                Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_pt_del_qty + l_rcvd_qty) >= l_line_del_qty  THEN
                    Debug(' Exiting the DEL loop',l_mod_name,1);
                    EXIT;
                END IF;
              Exception
                    WHEN PROCESS_ERROR THEN
                         Debug('In process_error exception ',l_mod_name,4);
                         RAISE PROCESS_ERROR;
                    WHEN SKIP_RECORD THEN
                         NULL;
              END;
            END LOOP; -- end of delivery lines

            IF (l_pt_reject_qty+ l_pt_accept_qty + l_accept_qty)>= l_line_qty THEN
                  Debug('Exiting RCV the loop ',l_mod_name,1);
                  EXIT;
            END IF;

       ELSIF RCV.transaction_type = 'REJECT' THEN
               -- Handles Inspection Required routing option

               select nvl(sum(paramn4),0)
                into  l_total_reject_qty
               from  csd_repair_history crh
               where crh.event_code = 'IP'
                and  crh.paramn1    = RCV.transaction_id;
               IF l_total_reject_qty >= RCV.rcvd_qty THEN
                   -- Debug messages
                   Debug('Skipping the record ',l_mod_name,1);
                   RAISE SKIP_RECORD;
               END IF;

               select nvl(sum(paramn3),0),nvl(sum(paramn4),0)
                into  l_pt_accept_qty, l_pt_reject_qty
               from  csd_repair_history crh
               where crh.event_code = 'IP'
                and  crh.paramn2 = RO.product_transaction_id;
               -- Debug messages
              Debug('l_pt_accept_qty'||l_pt_accept_qty,l_mod_name,1);
              Debug('l_pt_reject_qty'||l_pt_reject_qty,l_mod_name,1);

              IF RCV.serial_number_control_code in (2,5,6) THEN
                  l_line_qty := 1;
              ELSE
                  l_line_qty  := RO.ordered_quantity;
              END IF;
              IF l_pt_accept_qty+ l_pt_reject_qty >= l_line_qty THEN
                   -- Debug messages
                   Debug('Exiting the loop ',l_mod_name,1);
                   EXIT;
              ELSE
                  l_reject_qty := l_line_qty- (l_pt_accept_qty+ l_pt_reject_qty);
                  IF RCV.rcvd_qty < l_reject_qty THEN
                      l_reject_qty := RCV.rcvd_qty;
                  END IF;
              END IF;

                    IF RCV.serial_number_control_code in (2,5,6) THEN
                 l_reject_qty := 1;
                    ELSE
                 l_reject_qty := l_reject_qty - l_total_reject_qty;
              END IF;

              -- Debug messages
              Debug('l_reject_qty'||l_reject_qty,l_mod_name,1);

               -- Initialize the activity rec
              l_activity_rec := INIT_ACTIVITY_REC ;

               -- Assign the values for activity record
              l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
              l_activity_rec.REPAIR_LINE_ID :=  RO.repair_line_id;
              l_activity_rec.EVENT_CODE     :=  'IP';
              l_activity_rec.ACTION_CODE    :=  0;
              l_activity_rec.EVENT_DATE     :=  RCV.received_date;
              l_activity_rec.QUANTITY       :=  l_reject_qty;
              l_activity_rec.PARAMN1        :=  RCV.transaction_id;
              l_activity_rec.PARAMN2        :=  RO.product_transaction_id;
              l_activity_rec.PARAMN3        :=  null;
              l_activity_rec.PARAMN4        :=  l_reject_qty;
              l_activity_rec.PARAMN6        :=  RO.req_header_id;
              l_activity_rec.PARAMC1        :=  RO.requisition_number;
              l_activity_rec.PARAMC2        :=  rcv.subinventory;
              l_activity_rec.OBJECT_VERSION_NUMBER := null;

              -- Debug Messages
              Debug('Calling LOG_ACTIVITY',l_mod_name,2);

              -- Calling LOG_ACTIVITY for logging activity
              LOG_ACTIVITY
                     ( p_api_version     => p_api_version,
                       p_commit          => p_commit,
                       p_init_msg_list   => p_init_msg_list,
                       p_validation_level => p_validation_level,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_activity_rec    => l_activity_rec );

              -- Debug Messages
             Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

              -- Check if there are "DELIVER" txn lines against the reject lines
              -- If found, then process the deliver lines also
              FOR DEL IN DELIVER_LINES(RCV.transaction_id)
              LOOP
               BEGIN
                 -- Debug messages
                 Debug('In DEL Loop ',l_mod_name,1);

                 select nvl(sum(quantity),0)
                  into  l_total_del_qty
                  from csd_repair_history crh
                 where crh.event_code = 'RRI'
                  and  crh.paramn1    = DEL.transaction_id;
                 -- Debug messages
                 Debug('l_total_del_qty : '||l_total_del_qty,l_mod_name,1);

                 IF l_total_del_qty >= DEL.rcvd_qty THEN
                     -- Debug messages
                     Debug('Skipping the record',l_mod_name,1);
                     RAISE SKIP_RECORD;
                 END IF;

                 select nvl(sum(quantity),0)
                  into  l_pt_del_qty
                  from csd_repair_history crh
                 where crh.event_code = 'RRI'
                  and  crh.paramn2 = RO.product_transaction_id;
                  -- Debug messages
                  Debug('l_pt_del_qty : '||l_pt_del_qty,l_mod_name,1);

                 IF RCV.serial_number_control_code in (2,5,6) THEN
                     -- SERIALIZED CASE
                     Begin
                      select rcvt.serial_num,
                             rcvt.lot_num
                       into  l_serial_num,
                             l_lot_num
                       from  rcv_serial_transactions rcvt
                      where  rcvt.transaction_id = DEL.transaction_id
                       and   rownum = 1
                       and   not exists (Select 'NOT EXIST'
                                         from csd_repairs cra,
                                              csd_product_transactions cpt
                                         where cra.repair_line_id = cpt.repair_line_id
                                          and  cpt.action_type    = 'MOVE_OUT'
                                          and  cpt.order_header_id = ro.order_header_id
                                          and  cra.serial_number  = rcvt.serial_num);
                    Exception
                        WHEN NO_DATA_FOUND THEN
                             IF ( l_error_level >= G_debug_level) THEN
                                fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                                fnd_message.set_token('TXN_ID',DEL.transaction_id);
                                FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                             ELSE
                                fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                                fnd_message.set_token('TXN_ID',DEL.transaction_id);
                                fnd_msg_pub.add;
                             END If;
                             RAISE PROCESS_ERROR;
                    END;
                    -- Get the instance id from
                          -- installbase tables
                          IF NVL(RCV.ib_flag,'N') = 'Y' THEN
                                  BEGIN
                         Select instance_id
                                  into   l_instance_id
                                  from  csi_item_instances
                                  where inventory_item_id = RCV.item_id
                                   and  serial_number     = l_serial_num;
                            Exception
                                 When NO_DATA_FOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                             fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                             fnd_message.set_token('SERIAL_NUM',l_serial_num);
                             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                             fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                             fnd_message.set_token('SERIAL_NUM',l_serial_num);
                             fnd_msg_pub.add;
                          END If;
                                 When Others THEN
                          IF ( l_error_level >= G_debug_level) THEN
                             fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                             fnd_message.set_token('SERIAL_NUM',l_serial_num);
                             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                             fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                             fnd_message.set_token('SERIAL_NUM',l_serial_num);
                             fnd_msg_pub.add;
                          END If;
                      End;
                    ELSE
                                  l_instance_id := NULL;
                    END IF;

                   l_line_del_qty  := RO.ro_qty;
                ELSE
                    -- Non-Serialized Case
                    l_serial_num := NULL;
                    l_line_del_qty   := RO.ordered_quantity;
                    l_instance_id  := NULL;

                    --lot_control_code = 1 No control
                    --lot_control_code = 2 Full control
                   IF RCV.lot_control_code = 2 THEN
                     BEGIN
                       Select lot_num
                       into   l_lot_num
                       from rcv_lot_transactions
                       where source_transaction_id = DEL.transaction_id;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',DEL.transaction_id);
                              FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',DEL.transaction_id);
                              fnd_msg_pub.add;
                          END IF;
                          RAISE FND_API.G_EXC_ERROR;
                    END;
                  ELSE
                      l_lot_num := NULL;
                  END IF;
                END IF;

                IF l_pt_del_qty >= l_line_del_qty THEN
                    -- Debug messages
                    Debug('Exiting the loop',l_mod_name,1);
                    EXIT;
                ELSE
                    l_rcvd_qty := l_line_del_qty - l_pt_del_qty ;
                    IF DEL.rcvd_qty < l_rcvd_qty THEN
                        l_rcvd_qty := DEL.rcvd_qty;
                    END IF;
                END IF;

                         IF RCV.serial_number_control_code in (2,5,6) THEN
                   l_rcvd_qty  := 1;
                         ELSE
                   l_rcvd_qty  := l_rcvd_qty - l_total_del_qty;
                END IF;

                -- Debug messages
                Debug('l_rcvd_qty : '||l_rcvd_qty,l_mod_name,1);

                -- Update the serial number on repair order
                -- with the rcvd serial number
                /*Bug#5564180/FP#5845995 Move out line should not update the received quantity of
                RO. Move out line should not change the serial and instance number of RO
                 so commenting the below query
               */
            /*
                UPDATE CSD_REPAIRS
                SET SERIAL_NUMBER = l_serial_num,
                    quantity_rcvd = nvl(quantity_rcvd,0) + l_rcvd_qty,
                                customer_product_id   = l_instance_id,
                          object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE repair_line_id = RO.repair_line_id;
                IF SQL%NOTFOUND THEN
                   IF ( l_error_level >= G_debug_level) THEN
                        fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                        fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                        FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                   ELSE
                        fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                        fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                        fnd_msg_pub.add;
                   END IF;
                   RAISE PROCESS_ERROR;
                END IF;
                */

                -- Updating the product txn with the serial number,lot number
                -- qty rcvd and subinventory
                -- sub_inventory_rcvd is used for IO and subinventory column
                -- is used for the regular RMA
                UPDATE CSD_PRODUCT_TRANSACTIONS
                SET SOURCE_SERIAL_NUMBER = l_serial_num,
                             source_instance_id   = l_instance_id,
                    LOT_NUMBER_RCVD      = l_lot_num,
                    LOCATOR_ID           = DEL.locator_id,
                    QUANTITY_RECEIVED  = NVL(QUANTITY_RECEIVED,0) + l_rcvd_qty,
                    SUB_INVENTORY_RCVD = DEL.subinventory,
                          object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE product_transaction_id = RO.product_transaction_id;
                IF SQL%NOTFOUND THEN
                     IF ( l_error_level >= G_debug_level) THEN
                         fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                         fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                         FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                     ELSE
                         fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                         fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                         fnd_msg_pub.add;
                     END IF;
                     RAISE PROCESS_ERROR;
                END IF;

                IF RCV.serial_number_control_code in (2,5,6) THEN
                            UPDATE CSD_PRODUCT_TRANSACTIONS
                   SET prod_txn_status       = 'RECEIVED',
                             object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   WHERE product_transaction_id = RO.product_transaction_id;

                         ELSE
                            UPDATE CSD_PRODUCT_TRANSACTIONS
                   SET prod_txn_status       = 'RECEIVED',
                             object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   WHERE quantity_received = RO.ordered_quantity
                            and   product_transaction_id = RO.product_transaction_id;
                END IF;

                -- Initialize the activity rec
                l_activity_rec := INIT_ACTIVITY_REC ;

                -- Assign the values for activity record
                l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                l_activity_rec.REPAIR_LINE_ID := RO.repair_line_id;
                l_activity_rec.EVENT_CODE     := 'RRI';
                l_activity_rec.ACTION_CODE    := 0;
                l_activity_rec.EVENT_DATE     := DEL.received_date;
                l_activity_rec.QUANTITY       := l_rcvd_qty;
                l_activity_rec.PARAMN1        := DEL.transaction_id;
                l_activity_rec.PARAMN2        := RO.product_transaction_id;
                l_activity_rec.PARAMN3        := DEL.organization_id;
                l_activity_rec.PARAMN6        := RO.req_header_id;
                l_activity_rec.PARAMC1        := RO.order_number;
                l_activity_rec.PARAMC2        := RO.requisition_number;
                l_activity_rec.PARAMC3        := DEL.org_name;
                l_activity_rec.PARAMC4        := DEL.subinventory;
                l_activity_rec.OBJECT_VERSION_NUMBER := null;

                -- Debug Messages
                Debug('Calling LOG_ACTIVITY',l_mod_name,2);

                -- Calling LOG_ACTIVITY for logging activity
                -- Receipt of item against Internal Requisition
                LOG_ACTIVITY
                     ( p_api_version     => p_api_version,
                       p_commit          => p_commit,
                       p_init_msg_list   => p_init_msg_list,
                       p_validation_level => p_validation_level,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_activity_rec    => l_activity_rec );

                -- Debug Messages
                Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_pt_del_qty + l_rcvd_qty) >= l_line_del_qty  THEN
                    Debug(' Exiting the DEL loop',l_mod_name,1);
                    EXIT;
                END IF;
              Exception
                    WHEN PROCESS_ERROR THEN
                         Debug('In process_error exception ',l_mod_name,4);
                         RAISE PROCESS_ERROR;
                    WHEN SKIP_RECORD THEN
                         NULL;
              END;
            END LOOP; -- end of delivery lines

            IF l_pt_accept_qty+ l_pt_reject_qty+ l_reject_qty >= l_line_qty THEN
                 Debug(' Exiting the RCV loop',l_mod_name,1);
                 EXIT;
            END IF;

      ELSIF RCV.transaction_type = 'DELIVER' THEN
         -- Handles the Direct Delivery and standard routing options

           select nvl(sum(quantity),0)
            into  l_total_qty
            from csd_repair_history crh
           where crh.event_code = 'RRI'
            and  crh.paramn1    = RCV.transaction_id;
           IF l_total_qty >= RCV.rcvd_qty THEN
              -- Debug messages
              Debug(' Skipping the record',l_mod_name,1);
              RAISE SKIP_RECORD;
           END IF;

           select nvl(sum(quantity),0)
           into  l_pt_del_qty
           from  csd_repair_history crh
           where crh.event_code = 'RRI'
            and  paramn2        = RO.product_transaction_id;

           -- Debug messages
           Debug('l_pt_reject_qty='||l_pt_reject_qty,l_mod_name,1);
           Debug('l_pt_del_qty   ='||l_pt_del_qty,l_mod_name,1);

           IF RCV.serial_number_control_code in (2,5,6) THEN
               -- SERIALIZED AND LOT CONTROLLED CASE
              l_line_qty  := RO.ro_qty;
               Begin
                select rcvt.serial_num,
                       rcvt.lot_num
                 into  l_serial_num,
                       l_lot_num
                 from  rcv_serial_transactions rcvt
                where  rcvt.transaction_id = RCV.transaction_id
                 and   rownum = 1;

--bug#7452134.
--Due to bug#7452134, the customer BROOKS AUTOMATION ran into this issue if they
--try to recieve an item from diff operating unit. When user click update logistic
--button, then this error raising. From what I see on the customer's environment
--This code (condition) should not be here. I am not sure why we are checking
--the serial number in the production transaction table. After commented this
--condition, it worked for the customer.
--                 and   not exists (Select 'NOT EXIST'
--                                   from csd_repairs cra,
--                                        csd_product_transactions cpt
--                                   where cra.repair_line_id = cpt.repair_line_id
--                                    and  cpt.order_header_id = ro.order_header_id
--                                    and  cra.serial_number  = rcvt.serial_num);
              Exception
                WHEN NO_DATA_FOUND THEN
                    IF ( l_error_level >= G_debug_level) THEN
                        fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                        fnd_message.set_token('TXN_ID',RCV.transaction_id);
                        FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                    ELSE
                        fnd_message.set_name('CSD','CSD_SERIAL_NUM_MISSING');
                        fnd_message.set_token('TXN_ID',RCV.transaction_id);
                        fnd_msg_pub.add;
                    END IF;
                    RAISE PROCESS_ERROR;
              END;

              -- Get the instance id from
                    -- installbase tables
                    IF NVL(RCV.ib_flag,'N') = 'Y' THEN
                      BEGIN
                 Select instance_id
                          into   l_instance_id
                          from csi_item_instances
                          where inventory_item_id = RCV.item_id
                           and  serial_number     = l_serial_num;
                      Exception
                            When NO_DATA_FOUND THEN
                      IF ( l_error_level >= G_debug_level) THEN
                           fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                           fnd_message.set_token('SERIAL_NUM',l_serial_num);
                           FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                      ELSE
                           fnd_message.set_name('CSD','CSD_ITEM_INSTANCE_MISSING');
                           fnd_message.set_token('SERIAL_NUM',l_serial_num);
                           fnd_msg_pub.add;
                      END If;
                            When Others THEN
                      IF ( l_error_level >= G_debug_level) THEN
                           fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                           fnd_message.set_token('SERIAL_NUM',l_serial_num);
                           FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                      ELSE
                           fnd_message.set_name('CSD','CSD_INV_SERIAL_NUM');
                           fnd_message.set_token('SERIAL_NUM',l_serial_num);
                           fnd_msg_pub.add;
                      END If;
               End;
                       ELSE
                l_instance_id := NULL;
                    END IF;
            ELSE
              -- Non-Serialized Case but lot controlled
              l_serial_num := NULL;
              l_line_qty   := RO.ordered_quantity;
              l_instance_id := NULL;

              --lot_control_code = 1 No control
              --lot_control_code = 2 Full control
              IF RCV.lot_control_code = 2 THEN
                  BEGIN
                     Select lot_num
                     into   l_lot_num
                     from rcv_lot_transactions
                     where source_transaction_id = RCV.transaction_id;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',RCV.transaction_id);
                              FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                              fnd_message.set_name('CSD','CSD_INV_TXN_ID');
                              fnd_message.set_token('TXN_ID',RCV.transaction_id);
                              fnd_msg_pub.add;
                          END IF;
                          RAISE FND_API.G_EXC_ERROR;
                 END;
              ELSE
                  -- Non-Serialized Case but not lot controlled
                     l_lot_num := NULL;
              END IF;
          END IF;

          IF l_pt_del_qty >= l_line_qty  THEN
                Debug(' EXiting the RCV Loop',l_mod_name,1);
                EXIT;
          ELSE
                l_rcvd_qty :=  l_line_qty  - l_pt_del_qty;
                IF RCV.rcvd_qty <  l_rcvd_qty THEN
                    l_rcvd_qty := RCV.rcvd_qty;
                END IF;
          END IF;

          IF RCV.serial_number_control_code in (2,5,6) THEN
                   l_rcvd_qty := 1;
                ELSE
                   l_rcvd_qty := l_rcvd_qty - l_total_qty;
          END IF;

          -- Debug messages
          Debug('l_rcvd_qty'||l_rcvd_qty,l_mod_name,1);

          -- Update repair order with the rcvd serial number
          -- and the rcvd qty
                /*Bug#5564180/FP#5845995 Move out line should not update the received quantity of
                 RO. Move out line should not change the serial and instance number of RO
                 so commenting the below query
                */
        /*
          UPDATE CSD_REPAIRS
          SET SERIAL_NUMBER = l_serial_num,
              quantity_rcvd = nvl(quantity_rcvd,0) + l_rcvd_qty,
                    customer_product_id = l_instance_id,
                    object_version_number = object_version_number+1,
              last_update_date = sysdate,
              last_updated_by  = fnd_global.user_id,
              last_update_login = fnd_global.login_id
          WHERE repair_line_id = RO.repair_line_id;
          IF SQL%NOTFOUND THEN
               IF ( l_error_level >= G_debug_level) THEN
                    fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                    fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                    FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
               ELSE
                    fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
                    fnd_message.set_token('REPAIR_LINE_ID',RO.repair_line_id);
                    fnd_msg_pub.add;
               END IF;
               RAISE PROCESS_ERROR;
          END IF;
          */

          -- Update product txn with the rcvd serial number,lot number
          -- locator id, sub inv, status and the rcvd qty
          UPDATE CSD_PRODUCT_TRANSACTIONS
          SET SOURCE_SERIAL_NUMBER = l_serial_num,
                    source_instance_id   = l_instance_id,
              LOT_NUMBER_RCVD      = l_lot_num,
              QUANTITY_RECEIVED = NVL(QUANTITY_RECEIVED,0) + l_rcvd_qty,
              SUB_INVENTORY_RCVD= RCV.subinventory,
              LOCATOR_ID        = RCV.locator_id,
                    object_version_number = object_version_number+1,
              last_update_date = sysdate,
              last_updated_by  = fnd_global.user_id,
              last_update_login = fnd_global.login_id
          WHERE product_transaction_id = RO.product_transaction_id;
          IF SQL%NOTFOUND THEN
              IF ( l_error_level >= G_debug_level) THEN
                    fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                    fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                    FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
              ELSE
                    fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
                    fnd_message.set_token('PROD_TXN_ID',RO.product_transaction_id);
                    fnd_msg_pub.add;
              END IF;
              RAISE PROCESS_ERROR;
          END IF;

          IF RCV.serial_number_control_code in (2,5,6) THEN
                   UPDATE CSD_PRODUCT_TRANSACTIONS
             SET prod_txn_status       = 'RECEIVED',
                 object_version_number = object_version_number+1,
                 last_update_date = sysdate,
                 last_updated_by  = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
             WHERE product_transaction_id = RO.product_transaction_id;
          ELSE
                   UPDATE CSD_PRODUCT_TRANSACTIONS
             SET prod_txn_status       = 'RECEIVED',
                 object_version_number = object_version_number+1,
                 last_update_date = sysdate,
                 last_updated_by  = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
             WHERE quantity_received = RO.ordered_quantity
             and   product_transaction_id = RO.product_transaction_id;
                END IF;

          -- Initialize the activity rec
          l_activity_rec := INIT_ACTIVITY_REC ;

          -- Assign the values for activity record
          l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
          l_activity_rec.REPAIR_LINE_ID := RO.repair_line_id;
          l_activity_rec.EVENT_CODE     := 'RRI';
          l_activity_rec.ACTION_CODE    := 0;
          l_activity_rec.EVENT_DATE     := RCV.received_date;
          l_activity_rec.QUANTITY       := l_rcvd_qty;
          l_activity_rec.PARAMN1        := RCV.transaction_id;
          l_activity_rec.PARAMN2        := RO.product_transaction_id;
          l_activity_rec.PARAMN3        := RCV.organization_id;
          l_activity_rec.PARAMN6        :=  RO.req_header_id;
          l_activity_rec.PARAMC1        :=  RO.order_number;
          l_activity_rec.PARAMC2        :=  RO.requisition_number;
          l_activity_rec.PARAMC3        :=  RCV.org_name;
          l_activity_rec.PARAMC4        :=  RCV.subinventory;
          l_activity_rec.OBJECT_VERSION_NUMBER := null;

          -- Debug Messages
          Debug('Calling LOG_ACTIVITY',l_mod_name,2);

          -- Calling LOG_ACTIVITY for logging activity
          LOG_ACTIVITY
                ( p_api_version     => p_api_version,
                  p_commit          => p_commit,
                  p_init_msg_list   => p_init_msg_list,
                  p_validation_level => p_validation_level,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_activity_rec    => l_activity_rec );

            -- Debug Messages
            Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                Debug('LOG_ACTIVITY api failed ',l_mod_name,1);
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF  l_pt_del_qty+ l_rcvd_qty >= l_line_qty   THEN
                Debug(' exiting the RCV loop',l_mod_name,1);
                EXIT;
           END IF;
          END IF;
        Exception
           WHEN PROCESS_ERROR THEN
                 Debug(' In Process error exception',l_mod_name,4);
                 RAISE PROCESS_ERROR;
            WHEN SKIP_RECORD THEN
                 NULL;
        END;
       END LOOP;
     Exception
        WHEN PROCESS_ERROR THEN
            ROLLBACK TO RCV_LINES;
            Debug(' In Process error exception, exiting the loop',l_mod_name,1);
            -- In case of error, exit the loop. Commit the processed records
            -- and rollback the error record
            --RAISE FND_API.G_EXC_ERROR;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT;
     END;
   END LOOP;

    --Added by Vijay 11/4/04
   IF(GET_RO_PROD_TXN_LINES_All%ISOPEN) THEN
       CLOSE GET_RO_PROD_TXN_LINES_All;
   END IF;
   IF(GET_RO_PROD_TXN_LINES%ISOPEN) THEN
       CLOSE GET_RO_PROD_TXN_LINES;
   END IF;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data);
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR exception',l_mod_name,4);
          ROLLBACK TO IO_RCV_UPDATE_MOVE_OUT;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR exception',l_mod_name,4);
          ROLLBACK TO IO_RCV_UPDATE_MOVE_OUT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('In OTHERS exception',l_mod_name,4);
          ROLLBACK TO IO_RCV_UPDATE_MOVE_OUT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END IO_RCV_UPDATE_MOVE_OUT;

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

Procedure  SHIP_UPDATE
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
          p_past_num_of_days     IN   NUMBER DEFAULT NULL)   ----bug#6753684, 6742512
IS

  -- Standard Variables
  l_api_name             CONSTANT VARCHAR2(30)   := 'SHIPMENT_UPDATE';
  l_api_version          CONSTANT NUMBER         := 1.0;

  -- Variables in FND log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.ship_update';

--bug#8261344
  l_return_status        varchar2(1);
  l_msg_data_warning	    VARCHAR2(30000);


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  SHIP_UPDATE;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Log the api name in the log file
   Debug('At the Beginning of shipment Update ',l_mod_name,1);
   Debug('p_internal_order_flag ='||p_internal_order_flag,l_mod_name,1);
   Debug('p_order_header_id     ='||p_order_header_id,l_mod_name,1);
   Debug('p_repair_line_id      ='||p_repair_line_id,l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Api body starts
   IF p_internal_order_flag = 'Y' then
       Debug('Calling IO_SHIP_UPDATE ',l_mod_name,2);
       -- Call the api for processing of shipment against internal order
       IO_SHIP_UPDATE
        ( p_api_version          => p_api_version,
          p_commit               => p_commit     ,
          p_init_msg_list        => p_init_msg_list,
          p_validation_level     => p_validation_level,
          x_return_status        => x_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data ,
          p_order_header_id      => p_order_header_id);

       Debug('Return status from IO_SHIP_UPDATE '||x_return_status,l_mod_name,2);
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          Debug('IO_SHIP_UPDATE failed ',l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      /*Fixed for bug#5564180/FP#5845995
        Call to API IO_RCV_UPDATE_MOVE_OUT is added so that
        move out line can be updated for receiving in destination
        organization.
      */
       Debug('Calling IO_RCV_UPDATE_MOVE_OUT API',l_mod_name,2);
       -- Call the api for processing the receipt against
       -- internal requisition
       IO_RCV_UPDATE_MOVE_OUT
        ( p_api_version          => p_api_version,
          p_commit               => p_commit     ,
          p_init_msg_list        => p_init_msg_list,
          p_validation_level     => p_validation_level,
          x_return_status        => x_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data ,
          p_order_header_id      => p_order_header_id );

       -- Debug messages
       Debug('Return Status from IO_RCV_UPDATE_MOVE_OUT :'||x_return_status,l_mod_name,2);
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          Debug('IO_RCV_UPDATE_MOVE_OUT failed',l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
       END IF;


   Else
        Debug('Calling SO_SHIP_UPDATE ',l_mod_name,2);
        -- Call the api for processing sales order
        SO_SHIP_UPDATE
        ( p_api_version          => p_api_version,
          p_commit               => p_commit     ,
          p_init_msg_list        => p_init_msg_list,
          p_validation_level     => p_validation_level,
          x_return_status        => l_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data ,
          p_repair_line_id       => p_repair_line_id,
          p_past_num_of_days     => p_past_num_of_days);

       Debug('Return status from SO_SHIP_UPDATE '||l_return_status,l_mod_name,2);

	     --bug#8261344
	     If (l_return_status = G_CSD_RET_STS_WARNING and p_repair_line_id is null) Then
            Debug('RMA_RCV_UPDATE Warning message',l_mod_name,4);

		      Debug('x_msg_count :'||x_msg_count,l_mod_name,2);
		      Debug('x_msg_data :'||x_msg_data,l_mod_name,2);

		      l_msg_data_warning := null;
              -- Concatenate the message from the message stack
              IF x_msg_count >= 1 then
                FOR i IN 1..x_msg_count LOOP
                    l_msg_data_warning := l_msg_data_warning ||' : '||FND_MSG_PUB.Get(i,FND_API.G_FALSE) ;
				    Debug('l_msg_data_warning loop :'||l_msg_data_warning,l_mod_name,2);
                END LOOP ;
              END IF ;
              Debug(l_msg_data_warning,l_mod_name,4);

       ELSIF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          Debug('SO_SHIP_UPDATE failed ',l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  End If;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
  END IF;

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

  --bug#8261344
  If (l_return_status = G_CSD_RET_STS_WARNING and p_repair_line_id is null) THEN
		x_return_status := l_return_status;
		x_msg_data		:= l_msg_data_warning;
  END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('In FND_API.G_EXC_ERROR Exception ',l_mod_name,4);
          -- As we commit the processed records in the inner APIs
		-- so we rollback only if the p_commit= 'F'
		IF NOT(FND_API.To_Boolean( p_commit )) THEN
             ROLLBACK TO SHIP_UPDATE;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('In FND_API.G_EXC_UNEXPECTED_ERROR Exception',l_mod_name,4);
          IF ( l_error_level >= G_debug_level)  THEN
              fnd_message.set_name('CSD','CSD_SQL_ERROR');
              fnd_message.set_token('SQLERRM',SQLERRM);
              fnd_message.set_token('SQLCODE',SQLCODE);
              FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
          END If;
          -- As we commit the processed records in the inner APIs
		-- so we rollback only if the p_commit= 'F'
		IF NOT(FND_API.To_Boolean( p_commit )) THEN
             ROLLBACK TO SHIP_UPDATE;
          END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('In OTHERS Exception',l_mod_name,4);
          IF ( l_error_level >= G_debug_level)  THEN
              fnd_message.set_name('CSD','CSD_SQL_ERROR');
              fnd_message.set_token('SQLERRM',SQLERRM);
              fnd_message.set_token('SQLCODE',SQLCODE);
              FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
          END If;
          -- As we commit the processed records in the inner APIs
		-- so we rollback only if the p_commit= 'F'
		IF NOT(FND_API.To_Boolean( p_commit )) THEN
             ROLLBACK TO SHIP_UPDATE;
          END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END SHIP_UPDATE;

/*-------------------------------------------------------------------------------------*/
/* Procedure name: SO_SHIP_UPDATE                                                      */
/* Description   : Procedure called from the Update api to update the depot tables     */
/*                 for the shipment against sales order                                */
/*                 It also logs activities for the deliver txn lines                   */
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
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id                      */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/


PROCEDURE  SO_SHIP_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_repair_line_id       IN   NUMBER,
          p_past_num_of_days     IN   NUMBER  DEFAULT NULL)  ----bug#6753684, 6742512
IS


--Cursor split into to by Vijay 11/4/04 one without repair line and
-- one with repair line.
  -- Cursor to get all the shipment lines
  Cursor SHIPMENT_LINES_ALL is
  select
    ---changed to fix 3801614 , added dsn.serial_number if dd.serial_number is null
    nvl(dd.serial_number, dsn.fm_serial_number) shipped_serial_num,
    dd.lot_number lot_number,
    dd.revision revision,
    dd.subinventory subinv,
    dd.requested_quantity,
    dd.shipped_quantity,
    dd.delivery_detail_id,
    dd.requested_quantity_uom shipped_uom,
    dd.inventory_item_id ,
    dd.organization_id,
    dd.source_header_number order_number,
    dd.source_header_id sales_order_header,
    dd.locator_id,
    oel.line_number order_line_number,
    oel.actual_shipment_date date_shipped,
    oel.line_id,                            --Bug#6779806
    cra.repair_number,
    cra.repair_line_id,
    cra.unit_of_measure ro_uom,
    cra.inventory_item_id ro_item_id,
    ced.quantity_required estimate_quantity,
    cpt.source_serial_number prod_txn_serial_num,
    cpt.source_instance_id,
    cpt.product_transaction_id,
    cpt.action_code,
    wnd.name delivery_name,
    hao.name org_name
  from
    csd_product_transactions cpt,
    cs_estimate_details ced,
    csd_repairs cra,
    wsh_delivery_details dd ,
    wsh_serial_numbers dsn,--Added to fix 3801614
--Changed to view from table, bug:  4341784
    wsh_delivery_assignments_v wda,
    wsh_new_deliveries wnd,
    oe_order_lines_all oel,
    hr_all_organization_units hao
 Where cpt.action_type in ('SHIP', 'SHIP_THIRD_PTY') -- Walk-in-issue will be changed to ship
  AND  cpt.estimate_detail_id = ced.estimate_detail_id
  AND  dd.delivery_detail_id  = wda.delivery_detail_id
  AND  dd.delivery_detail_id  = dsn.delivery_detail_id(+) --Added to fix 3801614
  AND  dd.organization_id     = hao.organization_id
  AND  wda.delivery_id        = wnd.delivery_id
  AND  cpt.repair_line_id     = cra.repair_line_id
  AND  ced.order_header_id    = oel.header_id
  AND  ced.order_line_id      = oel.line_id          ----bug#6753684, 6742512
  AND  dd.source_header_id    = ced.order_header_id  ----bug#6753684, 6742512
  AND  dd.source_line_id      = ced.order_line_id    ----bug#6753684, 6742512
  AND  dd.source_header_id    = oel.header_id     ----bug#6753684, 6742512
  AND  dd.source_line_id      = oel.line_id
  AND  dd.source_code = 'OE'     -- 4423818
  AND  dd.released_status     in ('C','I')
  AND  ced.source_code        = 'DR'
  AND  not exists
        (select 'NOT EXIST'
          from csd_repair_history crh
         where crh.repair_line_id = cpt.repair_line_id
          and  crh.paramn1        = dd.delivery_detail_id
          and  event_code         = 'PS')
  AND  oel.line_id in ( Select line_id
                        from oe_order_lines_all oel1
         	            start with oel1.line_id = ced.order_line_id
	    	            connect by prior oel1.line_id = oel1.split_from_line_id
		                and oel1.shipped_quantity is not null
		                and oel1.header_id = oel.header_id);

/* Fixed bug#6753684, 6742512
	New cursor added for batch processing.This cursor takes two parameter
	p_from_date and p_to_date. These dates are compared with the creation date
	of repair order. Only repair order created during this period are considered
	for Depot Shipment Update to improve performance.
*/
  Cursor SHIPMENT_LINES_BY_DATE( p_from_Date Date, p_to_Date Date ) is
  select
    ---changed to fix 3801614 , added dsn.serial_number if dd.serial_number is null
    nvl(dd.serial_number, dsn.fm_serial_number) shipped_serial_num,
    dd.lot_number lot_number,
    dd.revision revision,
    dd.subinventory subinv,
    dd.requested_quantity,
    dd.shipped_quantity,
    dd.delivery_detail_id,
    dd.requested_quantity_uom shipped_uom,
    dd.inventory_item_id ,
    dd.organization_id,
    dd.source_header_number order_number,
    dd.source_header_id sales_order_header,
    dd.locator_id,
    oel.line_number order_line_number,
    oel.actual_shipment_date date_shipped,
    oel.line_id,                            --Bug#6779806
    cra.repair_number,
    cra.repair_line_id,
    cra.unit_of_measure ro_uom,
    cra.inventory_item_id ro_item_id,
    ced.quantity_required estimate_quantity,
    cpt.source_serial_number prod_txn_serial_num,
    cpt.source_instance_id,
    cpt.product_transaction_id,
    cpt.action_code,
    wnd.name delivery_name,
    hao.name org_name
  from
    csd_product_transactions cpt,
    cs_estimate_details ced,
    csd_repairs cra,
    wsh_delivery_details dd ,
    wsh_serial_numbers dsn,--Added to fix 3801614
--Changed to view from table, bug:  4341784
    wsh_delivery_assignments_v wda,
    wsh_new_deliveries wnd,
    oe_order_lines_all oel,
    hr_all_organization_units hao
Where cra.creation_date between p_from_date and p_to_date
  AND  cpt.action_type in ('SHIP', 'SHIP_THIRD_PTY') -- Walk-in-issue will be changed to ship
  AND  cpt.estimate_detail_id = ced.estimate_detail_id
  AND  dd.delivery_detail_id  = wda.delivery_detail_id
  AND  dd.delivery_detail_id  = dsn.delivery_detail_id(+) --Added to fix 3801614
  AND  dd.organization_id     = hao.organization_id
  AND  wda.delivery_id        = wnd.delivery_id
  AND  cpt.repair_line_id     = cra.repair_line_id
  AND  ced.order_header_id    = oel.header_id
  AND  ced.order_line_id      = oel.line_id          ----bug#6753684, 6742512
  AND  dd.source_header_id    = ced.order_header_id  ----bug#6753684, 6742512
  AND  dd.source_line_id      = ced.order_line_id    ----bug#6753684, 6742512
  AND  dd.source_header_id    = oel.header_id     ----bug#6753684, 6742512
  AND  dd.source_line_id      = oel.line_id
  AND  dd.source_code = 'OE'     -- 4423818
  AND  dd.released_status     in ('C','I')
  AND  ced.source_code        = 'DR'
  AND  not exists
        (select 'NOT EXIST'
          from csd_repair_history crh
         where crh.repair_line_id = cpt.repair_line_id
          and  crh.paramn1        = dd.delivery_detail_id
          and  event_code         = 'PS')
  AND  oel.line_id in ( Select line_id
                        from oe_order_lines_all oel1
         	            start with oel1.line_id = ced.order_line_id
	    	            connect by prior oel1.line_id = oel1.split_from_line_id
		                and oel1.shipped_quantity is not null
		                and oel1.header_id = oel.header_id);


  -- recrd type var to get the column values into
  I SHIP_LINES_Rec_Type ;
  -- Cursor to get all the shipment lines for the
  -- specific repair line id
  -- Changed by Vijay to remove OR condition on repair line if
  -- bug fix 3162163

  -- 12.1 FP bug#7551078, subhat.
  -- need to pick up only those ship lines which have source type as OE.
  -- There can be multiple delivery lines for the same sales order or
  -- the source_line_id in wsh_delivery_details can be same for OKE ship lines and
  -- OE ship lines.
  Cursor SHIPMENT_LINES ( p_repair_line_id in number) is
  select
    ---changed to fix 3801614 , added dsn.serial_number if dd.serial_number is null
    nvl(dd.serial_number, dsn.fm_serial_number) shipped_serial_num,
    dd.lot_number lot_number,
    dd.revision revision,
    dd.subinventory subinv,
    dd.requested_quantity,
    dd.shipped_quantity,
    dd.delivery_detail_id,
    dd.requested_quantity_uom shipped_uom,
    dd.inventory_item_id ,
    dd.organization_id,
    dd.source_header_number order_number,
    dd.source_header_id sales_order_header,
    dd.locator_id,
    oel.line_number order_line_number,
    oel.actual_shipment_date date_shipped,
    oel.line_id,                            --Bug#6779806
    cra.repair_number,
    cra.repair_line_id,
    cra.unit_of_measure ro_uom,
    cra.inventory_item_id ro_item_id,
    ced.quantity_required estimate_quantity,
    cpt.source_serial_number prod_txn_serial_num,
    cpt.source_instance_id,
    cpt.product_transaction_id,
    cpt.action_code,
    wnd.name delivery_name,
    hao.name org_name
  from
    csd_product_transactions cpt,
    cs_estimate_details ced,
    csd_repairs cra,
    wsh_delivery_details dd ,
    wsh_serial_numbers dsn,--Added to fix 3801614
--Changed to view from table, bug:  4341784
    wsh_delivery_assignments_v wda,
    wsh_new_deliveries wnd,
    oe_order_lines_all oel,
    hr_all_organization_units hao
 Where cpt.action_type in ('SHIP', 'SHIP_THIRD_PTY') -- Walk-in-issue will be changed to ship
  AND  cpt.estimate_detail_id = ced.estimate_detail_id
  AND  dd.delivery_detail_id  = wda.delivery_detail_id
  AND  dd.delivery_detail_id  = dsn.delivery_detail_id(+) --Added to fix 3801614
  AND  dd.organization_id     = hao.organization_id
  AND  wda.delivery_id        = wnd.delivery_id
  AND  cpt.repair_line_id     = cra.repair_line_id
  AND  ced.order_header_id    = oel.header_id
  AND  dd.source_line_id      = oel.line_id
  AND  dd.released_status     in ('C','I')
  AND  ced.source_code        = 'DR'
  AND  dd.source_code         = 'OE' -- 12.1 FP bug#7551078, subhat
  AND  not exists
        (select 'NOT EXIST'
          from csd_repair_history crh
         where crh.repair_line_id = cpt.repair_line_id
          and  crh.paramn1        = dd.delivery_detail_id
          and  event_code         = 'PS')
  AND  cpt.repair_line_id = p_repair_line_id
  AND  oel.line_id in ( Select line_id
                        from oe_order_lines_all oel1
         	            start with oel1.line_id = ced.order_line_id
	    	            connect by prior oel1.line_id = oel1.split_from_line_id
		                and oel1.shipped_quantity is not null
		                and oel1.header_id = oel.header_id);
  -- There is a concern for performance as I am using connect by clause
  -- Need to check with the performance team if there is a workaround
  -- Otherwise the logic has to be changed

 --- cursor for Cancelled orders...
 CURSOR Cur_Cancelled_repair_lines IS
 SELECT cra.REPAIR_LINE_ID
 FROM csd_repairs cra,
      cs_estimate_details ced,
      csd_product_transactions cpt
 WHERE  cpt.action_type    in ('SHIP', 'SHIP_THIRD_PTY')
       AND   cpt.prod_txn_status    in (  'BOOKED', 'SUBMITTED')
       AND   ced.order_header_id is not null
       AND   ced.source_code        = 'DR'
       AND   ced.estimate_detail_id = cpt.estimate_detail_id
       AND   cra.repair_line_id     = cpt.repair_line_id;

 --Bug#6779806
 CURSOR cur_get_instance_id(p_order_line_id number, p_inventory_item_id number)
 IS
 SELECT instance_id
 FROM csi_item_instances
 WHERE last_oe_order_line_id = p_order_line_id
 AND inventory_item_id = p_inventory_item_id;

 --Bug#6779806
 l_enable_update_instance	VARCHAR2(1);


  -- Standard variables
  l_api_name          CONSTANT VARCHAR2(30)   := 'SO_SHIP_UPDATE';
  l_api_version       CONSTANT NUMBER         := 1.0;

  -- Variables used in the program
  l_serialized        BOOLEAN;
  l_rep_hist_id       NUMBER;
  l_result_ship_qty   NUMBER;
  l_total_records     NUMBER;
  l_dummy             varchar2(30);
  l_commit_size       NUMBER := 500;
  l_instance_id       csi_item_instances.instance_id%type;
  l_ib_flag           mtl_system_items.comms_nl_trackable_flag%type;
  l_srl_ctl_code      mtl_system_items.serial_number_control_code%type;

  -- activity record
  l_activity_rec      activity_rec_type;

--bug#6753684, 6742512
  l_From_Date  Date;
  l_TO_Date    Date;

  -- Variables used for FND Log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.so_ship_update';

  --bug#8261344
  l_skip_record           BOOLEAN := FALSE;
  l_warning_return		  BOOLEAN := FALSE;

  --bug#7572853
  l_flag             NUMBER;

 BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  SO_SHIP_UPDATE;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_flag := 0; -- bug#7572853

   -- Debug messages
   Debug('At the Beginning of ship Update ',l_mod_name,1);
   Debug('Repair Line Id ='||p_repair_line_id,l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Api body starts

   -- Validate the repair line id
   -- bugfix 4423818 : We need to validate only if p_repair_line_id is NOT NULL
   IF(p_repair_line_id is NOT NULL ) THEN
     IF NOT(csd_process_util.validate_rep_line_id(p_repair_line_id)) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   --Bug#6779806
   --get the profile value:
   --CSD: Update Instance Number on Shipped Lines for Non-Serialized Installed Base Item
   l_enable_update_instance := nvl(FND_PROFILE.VALUE('CSD_UPDATE_INSTANCE_ID_FOR_NON_S_IB'), 'N');

   -- Keep count of number of records
   l_total_records := 0;

--bug#8261344
   l_warning_return:= FALSE;
   l_skip_record := FALSE;


   -- Select all the delivery lines that are shipped and does not have
   -- activity logged against the repair order
   -- 1. Serialized
   --  BEFORE SHIPMENT
   --  Repair Order
   --    RO NUM  RO Type  Qty    SN   shipped Qty
   --      R1      RR      1     SN1
   --  Product Txn
   --   Prod Txn   RO Num   Est Line  Est Qty   SN   Subinv   shipped Qty
   --     P1        R1         C1       1       SN1
   --
   -- AFTER SHIPMENT and running the update program
   --  Repair Order
   --    RO NUM  RO Type  Qty   SN   shipped Qty
   --      R1      RR      1    SN9       1
   --
   --  Delivery Lines
   --   Del Line  Ord Line  Qty  SN    Subinv
   --     D1        L1       1   SN9    FGI
   --
   --  Product Txn
   --   Prod Txn   RO Num   Est Line  Est Qty   SN     Subinv  Shipped Qty
   --     P1        R1         C1       1       SN9    FGI        1
   --
   -- 2. Non-Serialized
   --  BEFORE SHIPMENT
   --  Repair Order
   --    RO NUM  RO Type  Qty    SN   shipped Qty
   --      R1      RR      3
   --  Product Txn
   --   Prod Txn   RO Num   Est Line  Est Qty   SN   Subinv    shipped Qty
   --     P1        R1         C1       3
   -- AFTER SHIPMENT and running the update program
   --  Repair Order
   --    RO NUM  RO Type  Qty   SN  shipped Qty
   --      R1      RR      3            3
   --
   --  Delivery Lines
   --   Del Line  Ord Line  Qty  SN    Subinv
   --     D1        L1       1          FGI
   --     D2        L2       2          FGI
   --  Product Txn
   --   Prod Txn   RO Num   Est Line  Est Qty   SN     Subinv  Shipped Qty
   --     P1        R1         C1       3               FGI        3
   --
   /* For loop changed to loop to open different
   cursors based on p_repair_line_id value.
   Bug fix 3162163, Vijay  11/4/04
   */
   --FOR I IN SHIPMENT_LINES (p_repair_line_id)
   IF(p_repair_line_Id is null) THEN
     If (p_past_num_of_days Is Null) Then
        OPEN SHIPMENT_LINES_ALL;
     Else
        l_From_Date := sysdate - (p_past_num_of_days +1 ) ;
        l_TO_Date   := Sysdate + 1;
        OPEN SHIPMENT_LINES_BY_DATE(l_From_Date , l_To_Date);   ----bug#6753684, 6742512
     End If;
   ELSE
     OPEN SHIPMENT_LINES(p_repair_line_id);
   END IF;

   LOOP
    BEGIN

      IF(p_repair_line_Id is null) THEN
        If (p_past_num_of_days Is Null) Then
            FETCH  SHIPMENT_LINES_ALL INTO I;
            EXIT WHEN SHIPMENT_LINES_ALL%NOTFOUND;
        else
            FETCH  SHIPMENT_LINES_BY_DATE INTO I;           ----bug#6753684, 6742512
            EXIT WHEN SHIPMENT_LINES_BY_DATE%NOTFOUND;
        end if;
      ELSE
        FETCH SHIPMENT_LINES INTO I;
        EXIT WHEN SHIPMENT_LINES%NOTFOUND;
      END IF;


     -- savepoint
     SAVEPOINT  SHIPMENT_LINES;

-- bug#7285024
-- There could be data discrepancy between OM status and Shipping status in which
-- OM thinks the line is shipped but Shipping has not shipped yet.
-- Only process the prod txn line if shipped date from shiping tables is not null.
-- cursor queries have not been changed to incorporate this check due to performance
-- issues with checking not null.
-- Date shipped is checked instead of Shipping status since we are not sure exactly
-- which statuses map to a shipped line, but all shipped items must have a ship date.
-- Note: the date_shipped is required column in the depot history table.
	 If (I.date_shipped is not null) then

		 Debug('Order number      ='||I.order_number,l_mod_name,1);
		 Debug('Repair number     ='||I.repair_number,l_mod_name,1);
		 Debug('Shipped quantity  ='||TO_CHAR(I.shipped_quantity),l_mod_name,1);
		 Debug('Inventory item id ='||TO_CHAR(I.inventory_item_id),l_mod_name,1);
		 Debug('Organization id   ='||TO_CHAR(I.Organization_id),l_mod_name,1);

		 Begin
		   select serial_number_control_code,
				  comms_nl_trackable_flag
			into l_srl_ctl_code,
				 l_ib_flag
    		  from mtl_system_items
    		  where inventory_item_id  = i.inventory_item_id
    		   and  organization_id    = i.organization_id;
		 Exception
		   When no_data_found then
			IF ( l_error_level >= G_debug_level) THEN
				  fnd_message.set_name('CSD','CSD_INVALID_INVENTORY_ITEM');
				  FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
			ELSE
				  fnd_message.set_name('CSD','CSD_INVALID_INVENTORY_ITEM');
				  fnd_msg_pub.add;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		 End;

		 IF l_srl_ctl_code in (2,5,6) THEN
			Debug('Item is Serialized',l_mod_name,1);
			l_serialized := TRUE;
		 ELSE
			 Debug('Item is Non-Serialized',l_mod_name,1);
			 l_serialized := FALSE;
		 END IF;

		 IF l_serialized AND
			I.ro_item_id = I.inventory_item_id AND
			I.prod_txn_serial_num <> I.shipped_serial_num THEN

			  -- Initialize the activity rec
			  l_activity_rec := INIT_ACTIVITY_REC ;

			  -- Assign the values for activity record
			  l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
			  l_activity_rec.REPAIR_LINE_ID := I.repair_line_id;
			  l_activity_rec.EVENT_CODE     := 'SSC';
			  l_activity_rec.ACTION_CODE    := 0;
			  l_activity_rec.EVENT_DATE     := I.date_shipped;
			  l_activity_rec.QUANTITY       := null;
			  l_activity_rec.PARAMN1        := i.delivery_detail_id;
			  l_activity_rec.PARAMN2        := i.order_line_number;
			  l_activity_rec.PARAMC2        := i.delivery_name;
			  l_activity_rec.PARAMC3        := i.prod_txn_serial_num;
			  l_activity_rec.PARAMC4        := i.shipped_serial_num;
			  l_activity_rec.OBJECT_VERSION_NUMBER := null;

			  -- Debug Messages
			  Debug('Calling LOG_ACTIVITY',l_mod_name,2);

			  -- Calling LOG_ACTIVITY for logging activity
			  -- if serial number on product txn does not match
			  -- with the shipped serial number
			  LOG_ACTIVITY
					 ( p_api_version     => p_api_version,
					   p_commit          => p_commit,
					   p_init_msg_list   => p_init_msg_list,
					   p_validation_level => p_validation_level,
					   x_return_status   => x_return_status,
					   x_msg_count       => x_msg_count,
					   x_msg_data        => x_msg_data,
					   p_activity_rec    => l_activity_rec );

			   -- Debug Messages
			  Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
			  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				 Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
				 RAISE FND_API.G_EXC_ERROR;
			  END IF;

		 END IF; -- end of serial number mismatch

		 -- Only if the item on the RO is same as the one on
		 -- product txn, then call the convert API
		 IF I.ro_item_id = I.inventory_item_id THEN

		  -- Debug messages
		  Debug('Calling CONVERT_TO_RO_uom ',l_mod_name,2);

		  -- Converting the shipped qty to RO UOM
		  CONVERT_TO_RO_UOM
			( x_return_status   => x_return_status
			 ,p_to_uom_code     => i.ro_uom
			 ,p_item_id         => i.inventory_item_id
			 ,p_from_uom        => NULL
			 ,p_from_uom_code   => i.shipped_uom
			 ,p_from_quantity   => i.shipped_quantity
			 ,x_result_quantity => l_result_ship_qty);

		  -- Debug messages
		  Debug('Return Status from CONVERT_TO_RO_uom :'||x_return_status,l_mod_name,2);
		  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			 Debug('CONVERT_TO_RO_uom api failed ',l_mod_name,4);
			 RAISE FND_API.G_EXC_ERROR;
		  END IF;
		ELSE
			l_result_ship_qty := I.shipped_quantity;
		END IF;

		-- Update repair orders only for the following action codes
		IF I.action_code in ( 'CUST_PROD','EXCHANGE','REPLACEMENT') then
			-- Updating the repair order with qty
			update csd_repairs
			set quantity_shipped = nvl(quantity_shipped,0)+l_result_ship_qty,
			  object_version_number = object_version_number+1,
			  last_update_date = sysdate,
			  last_updated_by  = fnd_global.user_id,
			  last_update_login = fnd_global.login_id
			where repair_line_id = I.repair_line_id;
			 IF SQL%NOTFOUND THEN
			   IF ( l_error_level >= G_debug_level) THEN
				  fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
				  fnd_message.set_token('REPAIR_LINE_ID',I.repair_line_id);
				  FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
			   ELSE
				  fnd_message.set_name('CSD','CSD_RO_UPD_FAILED');
				  fnd_message.set_token('REPAIR_LINE_ID',I.repair_line_id);
				  fnd_msg_pub.add;
			   END IF;
			   RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;


		IF l_serialized and
		   nvl(l_ib_flag,'N') = 'Y' THEN
		  Begin
			Select instance_id
		   into l_instance_id
		   from csi_item_instances
		   where inventory_item_id = I.inventory_item_id
			 and  serial_number      = I.shipped_serial_num;  --bug#8261344
		  Exception
		   When No_Data_Found then
		  /*Fixed for bug#5563369
		  Correct message name CSD_INSTANCE_MISSING is used instead of
		  CSD_INV_INSTANCE_ID.
		  */
			  IF ( l_error_level >= G_debug_level) THEN
				  fnd_message.set_name('CSD','CSD_INSTANCE_MISSING');
				  fnd_message.set_token('SERIAL_NUM',I.shipped_serial_num);
			  fnd_msg_pub.add;
				  FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
			  fnd_file.put_line(fnd_file.log, fnd_message.get);
			  ELSE
				  fnd_message.set_name('CSD','CSD_INSTANCE_MISSING');
				  fnd_message.set_token('SERIAL_NUM',I.shipped_serial_num);
				  fnd_msg_pub.add;
			  fnd_file.put_line(fnd_file.log, fnd_message.get);
			  /*Fixed for bug#5563369
					Correct message name CSD_INSTANCE_MISSING is used instead of
					CSD_INV_INSTANCE_ID.
				  */
			  END IF;

		      --bug#8261344
 		      IF(p_repair_line_id is not null or (NVL(fnd_profile.value('CSD_LOGISTICS_PROGRAM_ERROR'), 'S') <> 'A')) THEN
    			   RAISE FND_API.G_EXC_ERROR;
		      else
    --			RAISE FND_API.G_EXC_ERROR;
    		 	 l_skip_record := TRUE;
    			 l_warning_return := TRUE;
		      end if;
	          Debug(' Could not find any IB instance for the Serial Num ='||I.shipped_serial_num, l_mod_name,1);

		   When OTHERS then
			  IF ( l_error_level >= G_debug_level) THEN
				  fnd_message.set_name('CSD','CSD_INSTANCE_MISSING');
				  fnd_message.set_token('SERIAL_NUM',I.shipped_serial_num);
			  fnd_msg_pub.add;
				  FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
			  fnd_file.put_line(fnd_file.log, fnd_message.get);
			  ELSE
			  fnd_message.set_name('CSD','CSD_INSTANCE_MISSING');
				  fnd_message.set_token('SERIAL_NUM',I.shipped_serial_num);
				  fnd_msg_pub.add;
			  fnd_file.put_line(fnd_file.log, fnd_message.get);
			  END IF;
			  RAISE FND_API.G_EXC_ERROR;
		 End;

		--bug#6779806
		ELSIF (nvl(l_ib_flag,'N') = 'Y') THEN
			IF (l_enable_update_instance ='Y') THEN
				Open cur_get_instance_id(I.line_id,I.inventory_item_id);
				Fetch cur_get_instance_id into l_instance_id;
				Close cur_get_instance_id;
			else
				l_instance_id := I.source_instance_id;
			end if;
		Else
		   l_instance_id := I.source_instance_id;
		End If;


   Debug('serial number before if skip reord ='||I.shipped_serial_num, l_mod_name,1);

   If NOT(l_skip_record) Then   --bug#8261344

		-- Updating the product txn with qty,subinventory,lot number
		-- locator id
		update csd_product_transactions
		set sub_inventory = i.subinv,
		  lot_number    = i.lot_number,
			quantity_shipped = nvl(quantity_shipped,0)+I.shipped_quantity,
			locator_id       = i.locator_id,
			source_serial_number = i.shipped_serial_num,
		  source_instance_id   = l_instance_id,
			object_version_number = object_version_number+1,
			last_update_date = sysdate,
			last_updated_by  = fnd_global.user_id,
			last_update_login = fnd_global.login_id
		where product_transaction_id = i.product_transaction_id ;
		IF SQL%NOTFOUND THEN
			IF ( l_error_level >= G_debug_level) THEN
				  fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
				  fnd_message.set_token('PROD_TXN_ID',I.product_transaction_id);
				  FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
			ELSE
				  fnd_message.set_name('CSD','CSD_PROD_TXN_UPD_FAILED');
				  fnd_message.set_token('PROD_TXN_ID',I.product_transaction_id);
				  fnd_msg_pub.add;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		-- Updating the product txn with the status
		-- if the line qty is fully rcvd
		update csd_product_transactions
		set prod_txn_status = 'SHIPPED',
			object_version_number = object_version_number+1,
			last_update_date = sysdate,
			last_updated_by  = fnd_global.user_id,
			last_update_login = fnd_global.login_id
		where nvl(quantity_shipped,0) = I.estimate_quantity
		 and  product_transaction_id = i.product_transaction_id ;

	        --bug#7572853 begin
                l_flag := 0;
                --The following procedure is user hooks for the customer.
                --the parameter l_flag always return 0 on the default package CSD_UPDATE_SHIP_PROGRAM_CUHK
                --please see package spec and body CSD_UPDATE_SHIP_PROGRAM_CUHK for the definition
                CSD_UPDATE_SHIP_PROGRAM_CUHK.POST_UPDATE_PROD_TXN(
                  p_repair_line_id                        =>      I.repair_line_id,
                  p_product_transaction_id        =>      i.product_transaction_id,
                  p_instance_id                           =>  l_instance_id,
                  p_comms_nl_trackable_flag       =>      l_ib_flag,
                  p_action_code                           =>  I.action_code,
                  x_flag                                          =>      l_flag,
                  x_return_status                         =>      x_return_status,
                  x_msg_count                                     =>      x_msg_count,
                  x_msg_data                                      =>      x_msg_data
                );
                -- Debug Messages
                Debug('after call POST_UPDATE_PROD_TXN l_flag '||l_flag,l_mod_name,2);
                Debug('Return Status from CSD_UPDATE_SHIP_PROGRAM_CUHK:'||x_return_status,l_mod_name,2);
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  Debug('POST_UPDATE_PROD_TXN api failed ',l_mod_name,4);
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                Debug('l_flag '||l_flag,l_mod_name,2);

                If (l_flag = 0) then
		--bug#7572853 end

		--Bug#6779806
		 IF (NOT(l_serialized) and (nvl(l_ib_flag,'N') = 'Y')
			 and (l_instance_id is null)
			 and (l_enable_update_instance ='Y')) then
				--do nothing
				--due to csi_item_instances has not update the instance id yet
				--It is update by the concurent program.
				--if there is not instance id yet, we don't want to
				--update the history table
				null;
		 ELSE

			 -- Initialize the activity rec
			 l_activity_rec := INIT_ACTIVITY_REC ;

			 -- Assign the values for activity record
			 l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
			 l_activity_rec.REPAIR_LINE_ID := I.repair_line_id;
			 l_activity_rec.EVENT_CODE     := 'PS';
			 l_activity_rec.ACTION_CODE    := 0;
			 l_activity_rec.EVENT_DATE     := I.date_shipped;
			 l_activity_rec.QUANTITY       := l_result_ship_qty;
			 l_activity_rec.PARAMN1        := i.delivery_detail_id;
			 l_activity_rec.PARAMN2        := i.order_line_number;
			 l_activity_rec.PARAMN3        := i.organization_id;
			 l_activity_rec.PARAMC2        :=  i.delivery_name;
			 l_activity_rec.PARAMC3        :=  i.org_name;
			 l_activity_rec.PARAMC4        :=  i.subinv;
			 l_activity_rec.OBJECT_VERSION_NUMBER := null;

			 -- Debug Messages
			 Debug('Calling LOG_ACTIVITY',l_mod_name,2);

			 -- Calling LOG_ACTIVITY for logging activity
			 -- shipped delivery lines
			 LOG_ACTIVITY
					 ( p_api_version     => p_api_version,
					   p_commit          => p_commit,
					   p_init_msg_list   => p_init_msg_list,
					   p_validation_level => p_validation_level,
					   x_return_status   => x_return_status,
					   x_msg_count       => x_msg_count,
					   x_msg_data        => x_msg_data,
					   p_activity_rec    => l_activity_rec );

			   -- Debug Messages
			   Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
			   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				 Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
				 RAISE FND_API.G_EXC_ERROR;
			   END IF;

		  END IF;
                end if; --end if (l_flag = ) Bug 7572853

     End if;    --end if NOT(l_skip_record)  --bug#8261344

	End if; --end If (I.date_shipped is not null) --bug#7285024

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            Debug('In FND_API.G_EXC_ERROR EXCEPTION',l_mod_name,4);
            ROLLBACK TO SHIPMENT_LINES;
            -- In case of error, exit the loop. Commit the processed records
            -- and rollback the error record
            --RAISE FND_API.G_EXC_ERROR;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT;
    END;
       -- Commit for every 500 records
       -- one should COMMIT less frequently within a PL/SQL loop to
       -- prevent ORA-1555 (Snapshot too old) errors

	 --bug#8261344
	    If NOT(l_skip_record) Then
	       l_total_records := l_total_records + 1;
	    end if;
       IF mod(l_total_records, l_commit_size) = 0 THEN -- Commit every 500 records
           IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
           END IF;
	   END IF;

	--bug#8261344
	 l_skip_record := FALSE;

   END LOOP;

   IF(SHIPMENT_LINES_ALL%ISOPEN ) THEN
       CLOSE SHIPMENT_LINES_ALL;
   END IF;
   IF(SHIPMENT_LINES%ISOPEN ) THEN
       CLOSE SHIPMENT_LINES;
   END IF;
   IF(SHIPMENT_LINES_BY_DATE%ISOPEN ) THEN
       CLOSE SHIPMENT_LINES_BY_DATE;
   END IF;

  ------------ process cancelled orders.
   Debug('processing cancelled orders in SO_SHIP_UPDATE',l_mod_name,1);
  if(p_repair_line_id is not null) then
     Debug('processing repairline['||p_repair_line_id||']',l_mod_name,1);
  	Check_for_Cancelled_order(p_repair_line_id);
  else
  	FOR Repln_Rec in Cur_Cancelled_repair_lines
	LOOP
          Debug('processing repairline['||repln_rec.repair_line_id||']',l_mod_name,1);
		check_for_cancelled_order(Repln_rec.Repair_line_id);
	END LOOP;
  End if;
   Debug('At the end of processing cancelled orders in SO_SHIP_UPDATE',l_mod_name,1);
  -----------------------

   -- Log seeded messages for the number of processed records
   fnd_message.set_name('CSD','CSD_DRC_SHIP_TOTAL_REC_PROC');
   fnd_message.set_token('TOT_REC',to_char(l_total_records));
   FND_MSG_PUB.ADD;

   -- Debug messages
   Debug(fnd_message.get,l_mod_name,1);

   -- Log messages in the concurrent log and output file
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   fnd_file.put_line(fnd_file.output,fnd_message.get);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

--bug#8261344
   If (l_warning_return) THEN
 	  x_return_status := G_CSD_RET_STS_WARNING;
   End if;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
          (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data);

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          Debug('FND_API.G_EXC_ERROR  Exception',l_mod_name,4);
          ROLLBACK TO SO_SHIP_UPDATE;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          Debug('FND_API.G_EXC_UNEXPECTED_ERROR Exception',l_mod_name,4);
          ROLLBACK TO SO_SHIP_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          Debug('OTHERS Exception',l_mod_name,4);
          ROLLBACK TO SO_SHIP_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END SO_SHIP_UPDATE;


/*-------------------------------------------------------------------------------------*/
/* Procedure name: IO_SHIP_UPDATE                                                      */
/* Description   : Procedure called from the Update api to update the depot tables     */
/*                 for the shipment against Internal sales order                       */
/*                 It also logs activities for the deliver txn lines                   */
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
/*    p_order_header_id  NUMBER   Optional   Interal sales order Id                    */
/* Output Parm :                                                                       */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

PROCEDURE IO_SHIP_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_order_header_id      IN   NUMBER
        ) IS

  -- Cursor to get all the order lines for a
  -- specific order header id
  --Chnaged the cursor to remove the OR condition on the repair line id.
  --Vijay 11/4/04
  --saupadhy 04/15/05 : BUg# 4279958 : Problem: When partial Shipping is done for both
  -- move_in and Move_Out lines,only first shiplines information is updated on logistics lines
  -- subsequest so lines information is not updated.
  -- Cause: Cursors Delivery_Lines and Delivery_lines_all have hard join with mtl_trx_lines table.
  -- Records in this table are created only when so line is shipped. In partial shipping scenario, if
  -- second line is not shipped at the time update logistics program is run then, it will never be
  -- created after update logistics program is run for the first ship line.
  -- Solution: Hard Join with Mtl_Trx_line is replaced with outer join.
  CURSOR DELIVERY_LINES (p_ord_header_id in number) IS
   Select  oel.header_id,
           oel.line_id,
           oel.ordered_quantity,
           oel.source_document_id req_header_id,
           oel.source_document_line_id req_line_id,
           oel.orig_sys_document_ref req_number,
           oel.inventory_item_id,
           oel.actual_shipment_date shipment_date,
           dd.delivery_detail_id,
           dd.shipped_quantity,
    ---changed to fix 3801614 , added dsn.serial_number if dd.serial_number is null
           nvl(dd.serial_number,dsn.fm_serial_number) del_line_serial_num,
           --dd.serial_number del_line_serial_num,
           dd.lot_number,
           dd.subinventory,
           dd.locator_id,
           dd.organization_id,
           dd.released_status,
           dd.requested_quantity,
	     dd.source_header_number order_number,
           prl.source_organization_id,
	     prl.source_subinventory,
	     prl.destination_organization_id,
	     prl.destination_subinventory,
           mtl.serial_number_control_code,
           mtl.lot_control_code,
	     prh.segment1 requisition_number,
	     hao.name source_org_name,
	     hao1.name destination_org_name,
           trl.txn_source_id
    from   oe_order_lines_all oel,
           wsh_delivery_details dd,
           wsh_serial_numbers dsn,--Added to fix 3801614
           po_requisition_lines_all prl,
	     po_requisition_headers_all prh,
           mtl_system_items mtl,
	     hr_all_organization_units hao,
	     hr_all_organization_units hao1,
           mtl_txn_request_lines trl
   where   oel.header_id   = p_ord_header_id
    and    oel.line_id          = dd.source_line_id
    and    oel.header_id        = dd.source_header_id
    and    prl.requisition_header_id   = prh.requisition_header_id
    and    hao.organization_id  = dd.organization_id
    and    hao1.organization_id = prl.destination_organization_id
    and    oel.source_document_line_id = prl.requisition_line_id
    and    oel.ship_from_org_id = mtl.organization_id
    and    oel.inventory_item_id= mtl.inventory_item_id
    and    dd.move_order_line_id = trl.line_id(+) -- Added to fix 4279958
    and    dd.delivery_detail_id  = dsn.delivery_detail_id(+) --Added to fix 3801614
    and    exists (Select 'x'
                   from csd_product_transactions cpt
			 where cpt.order_header_id = oel.header_id
                    and  cpt.prod_txn_status in ('BOOKED','RELEASED'));

-- New Cursor  for all delivery lines.
  CURSOR DELIVERY_LINES_ALL IS
   Select  oel.header_id,
           oel.line_id,
           oel.ordered_quantity,
           oel.source_document_id req_header_id,
           oel.source_document_line_id req_line_id,
           oel.orig_sys_document_ref req_number,
           oel.inventory_item_id,
           oel.actual_shipment_date shipment_date,
           dd.delivery_detail_id,
           dd.shipped_quantity,
    ---changed to fix 3801614 , added dsn.serial_number if dd.serial_number is null
           nvl(dd.serial_number,dsn.fm_serial_number) del_line_serial_num,
           --dd.serial_number del_line_serial_num,
           dd.lot_number,
           dd.subinventory,
           dd.locator_id,
           dd.organization_id,
           dd.released_status,
           dd.requested_quantity,
	     dd.source_header_number order_number,
           prl.source_organization_id,
	     prl.source_subinventory,
	     prl.destination_organization_id,
	     prl.destination_subinventory,
           mtl.serial_number_control_code,
           mtl.lot_control_code,
	     prh.segment1 requisition_number,
	     hao.name source_org_name,
	     hao1.name destination_org_name,
           trl.txn_source_id
    from   oe_order_lines_all oel,
           wsh_delivery_details dd,
           wsh_serial_numbers dsn,--Added to fix 3801614
           po_requisition_lines_all prl,
	     po_requisition_headers_all prh,
           mtl_system_items mtl,
	     hr_all_organization_units hao,
	     hr_all_organization_units hao1,
           mtl_txn_request_lines trl
   where   oel.line_id          = dd.source_line_id
    and    oel.header_id        = dd.source_header_id
    and    prl.requisition_header_id   = prh.requisition_header_id
    and    hao.organization_id  = dd.organization_id
    and    hao1.organization_id = prl.destination_organization_id
    and    oel.source_document_line_id = prl.requisition_line_id
    and    oel.ship_from_org_id = mtl.organization_id
    and    oel.inventory_item_id= mtl.inventory_item_id
    and    dd.move_order_line_id = trl.line_id(+)  -- Added to fix 4279958
    and    dd.delivery_detail_id  = dsn.delivery_detail_id(+) --Added to fix 3801614
    and    exists (Select 'x'
                   from csd_product_transactions cpt
			 where cpt.order_header_id = oel.header_id
                    and  cpt.prod_txn_status in ('BOOKED','RELEASED'));


--record tpye to hold delivery lines record selected from the cursor
--above
    del  IO_SHIP_LINES_Rec_Type;

   -- Cursor that gets all unit txn
   -- for delivery detail id
    Cursor MTL_UNIT_TXN ( p_del_line_id in number, p_txn_src_id in number ) is
      select
         mut.subinventory_code,
         mut.locator_id,
         mut.serial_number,
         mtl.transaction_id
      from mtl_material_transactions mtl,
           mtl_unit_transactions mut
      where mtl.transaction_id     = mut.transaction_id
       and  mtl.transaction_source_type_id = 8  -- Internal Order
       and  mtl.transaction_type_id  in (50, 62,54,34)
       and  mtl.picking_line_id    = p_del_line_id
       and  mtl.transaction_source_id = p_txn_src_id ;

   -- Cursor that gets all unit txn
   -- for delivery detail id. If the item is lot controlled
   -- and serial controlled item then need to join
   -- with MTL_TRANSACTION_LOT_NUMBERS
    Cursor MTL_UNIT_LOT_TXN ( p_del_line_id in number,p_txn_src_id in number ) is
      select
         mut.subinventory_code,
         mut.locator_id,
         mut.serial_number,
         mtl.transaction_id
      from MTL_TRANSACTION_LOT_NUMBERS mln,
           mtl_unit_transactions mut,
           mtl_material_transactions mtl
      WHERE MLN.SERIAL_TRANSACTION_ID = mut.transaction_id
      and  mln.transaction_id = mtl.transaction_id
      and  mtl.transaction_source_type_id = 8  -- Internal Order
      and  mtl.transaction_type_id  in ( 50,62,54,34)
      and  mtl.picking_line_id    = p_del_line_id
      and  mtl.transaction_source_id = p_txn_src_id ;

   -- Standard variables
   l_api_name          CONSTANT VARCHAR2(30)   := 'IO_SHIP_UPDATE';
   l_api_version       CONSTANT NUMBER         := 1.0;

   -- Variables used by the API
   l_rep_hist_id         NUMBER;
   l_dummy               varchar2(30);
   l_total_qty           number;
   l_total_del_qty       number;
   l_serialized_flag     boolean;
   l_log_activity        boolean;
   l_prod_txn_exists     boolean;
   l_serial_num          mtl_serial_numbers.serial_number%type;
   l_lot_num             mtl_lot_numbers.lot_number%type;
   l_rep_line_id         number;
   l_remaining_qty       number;
   l_shipped_qty         number;
   l_pt_line_qty         number;
   l_pt_shipped_qty      number;
   l_total_shipped_qty   number;
   l_prod_txn_shipped_qty number;
   l_action_type         csd_product_transactions.action_type%type;
   l_action_code         csd_product_transactions.action_code%type;
   l_prod_txn_id         number := NULL;
   l_prod_txn_status     csd_product_transactions.prod_txn_status%type ;
   l_release_so_flag     csd_product_transactions.release_sales_order_flag%type ;
   l_ship_so_flag        csd_product_transactions.ship_sales_order_flag%type ;
   l_qty_shipped         number;

   -- activity record
   l_activity_rec      activity_rec_type;

   -- Variables for the FND Log
   l_error_level  number   := FND_LOG.LEVEL_ERROR;
   l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.io_ship_update';

   -- User defined exception
   PROCESS_ERROR  EXCEPTION;
   SKIP_RECORD    EXCEPTION;

 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT  IO_SHIP_UPDATE;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Debug('At the Beginning of IO_SHIP_UPDATE',l_mod_name,1 );
   Debug('Order Header Id ='||p_order_header_id,l_mod_name,1);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Api body starts

   -- In case of Internal orders, the product txns are stamped
   -- with the order header id and line id.
   -- So Validate if it exists in csd_product_transactions
   IF  NVL(p_order_header_id,-999) <> -999 THEN
      BEGIN
          select 'EXISTS'
          into  l_dummy
          from  oe_order_headers_all oeh,
                po_requisition_headers_all prh
          where oeh.source_document_id = prh.requisition_header_id
           and  oeh.header_id = p_order_header_id
           and  exists (select 'x'
                       from csd_product_transactions cpt
                       where cpt.order_header_id = oeh.header_id );
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             IF ( l_error_level >= G_debug_level) THEN
                 fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                 fnd_message.set_token('HEADER_ID',p_order_header_id);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
             ELSE
                 fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                 fnd_message.set_token('HEADER_ID',p_order_header_id);
                 fnd_msg_pub.add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
     END;
   END IF;

   --FOR DEL in DELIVERY_LINES(p_order_header_id)
   IF(p_order_header_Id is null) THEN
     OPEN DELIVERY_LINES_ALL;
   ELSE
     OPEN DELIVERY_LINES(p_order_header_id);
   END IF;

   LOOP
    BEGIN

      IF(p_order_header_Id is null) THEN
        FETCH  DELIVERY_LINES_ALL INTO del;
        EXIT WHEN DELIVERY_LINES_ALL%NOTFOUND;
      ELSE
        FETCH DELIVERY_LINES INTO del;
        EXIT WHEN DELIVERY_LINES%NOTFOUND;
      END IF;

       -- Savepoint
       SAVEPOINT ORDER_LINES;

       -- Debug messages
       Debug('DEL.header_id ='||DEL.header_id,l_mod_name,1);

       -- Get the action type and action code
       -- for the product txn line
       Begin
         select action_type,
                action_code
         into   l_action_type,
                l_action_code
         from  csd_product_transactions
         where order_header_id = DEL.header_id
          and  rownum = 1;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
             IF ( l_error_level >= G_debug_level) THEN
                 fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                 fnd_message.set_token('HEADER_ID',DEL.header_id);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
             ELSE
                 fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                 fnd_message.set_token('HEADER_ID',DEL.header_id);
                 fnd_msg_pub.add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
       END;

       -- Debug messages
       Debug('l_action_type ='||l_action_type,l_mod_name,1);
       Debug('l_action_code ='||l_action_code,l_mod_name,1);

       IF DEL.released_status in ('I','C') THEN
            l_release_so_flag := 'Y';
            l_ship_so_flag    := 'Y';
	        l_prod_txn_status := 'SHIPPED';
       ELSIF DEL.released_status = 'Y' THEN
            l_release_so_flag := 'Y';
            l_ship_so_flag    := 'N';
	        l_prod_txn_status := 'RELEASED';
       ELSE
  	      l_release_so_flag := 'N';
            l_ship_so_flag    := 'N';
	      l_prod_txn_status := 'BOOKED';
       END IF;


       IF l_action_type = 'MOVE_IN' THEN

            -- Move-In case
            Debug('Processing the move-in lines ',l_mod_name,1);

           Select nvl(sum(quantity_shipped),0)
           into  l_total_shipped_qty
           from  csd_product_transactions
           where action_type = 'MOVE_IN'
           and   action_code = 'DEFECTIVES'
           and   order_line_id = DEL.line_id
           and   order_header_id = DEL.header_id;

            -- Debug messages
           Debug('l_total_shipped_qty= '||l_total_shipped_qty,l_mod_name,1);

           IF l_total_shipped_qty >= DEL.shipped_quantity THEN
                  -- Debug messages
                  Debug('Skipping the record ',l_mod_name,1);
                  RAISE SKIP_RECORD;
           END IF;

         -- Debug messages
         Debug('serial_number_control_code ='||DEL.serial_number_control_code,l_mod_name,1);

         IF DEL.serial_number_control_code = 1 THEN

              -- Non-Serialized case
              Debug('Item Is Non-Serialized ',l_mod_name,1);

        	  --Initialize the variables
   	          l_prod_txn_id := NULL;

              -- Check if the product txn exists
              -- for the order line and header id
              BEGIN
               Select product_transaction_id,
                      repair_line_id
               into   l_prod_txn_id,
                      l_rep_line_id
               from  csd_product_transactions
               where order_header_id = DEL.header_id
                and  order_line_id   = DEL.line_id
                and  action_type     = l_action_type
                and  action_code     = l_action_code;
                Debug('Product txn exist',l_mod_name,1);
                l_prod_txn_exists := TRUE;
              EXCEPTION
                When NO_DATA_FOUND then
                  Debug('Product txn does not exist',l_mod_name,1);
                  l_prod_txn_exists := FALSE;
              END;

            IF l_prod_txn_exists THEN
              --If product txn exist then update the shipped qty and the status
              UPDATE CSD_PRODUCT_TRANSACTIONS
              SET quantity_shipped = nvl(quantity_shipped,0) + nvl(DEL.shipped_quantity,0),
                  sub_inventory    =  DEL.subinventory,
                  lot_number       =  DEL.lot_number,
                  locator_id       =  DEL.locator_id,
                  release_sales_order_flag = l_release_so_flag,
                  ship_sales_order_flag    = l_ship_so_flag,
                  prod_txn_status  = l_prod_txn_status,
  		      object_version_number = object_version_number+1,
                  last_update_date = sysdate,
                  last_updated_by  = fnd_global.user_id,
                  last_update_login = fnd_global.login_id
              WHERE product_transaction_id = l_prod_txn_id;
               IF SQL%NOTFOUND THEN
                    IF ( l_error_level >= G_debug_level) THEN
                        fnd_message.set_name('CSD','CSD_INV_PROD_TXN_ID');
                        fnd_message.set_token('PROD_TXN_ID',l_prod_txn_id);
                        FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                    ELSE
                        fnd_message.set_name('CSD','CSD_INV_PROD_TXN_ID');
                        fnd_message.set_token('PROD_TXN_ID',l_prod_txn_id);
                        fnd_msg_pub.add;
                    END IF;
                    RAISE PROCESS_ERROR;
               END IF;

            ELSE -- product txn does not exist
    	        -- If product txn does not exist then insert a product txn for the
  	        -- split order line
              -- Get the repair line id for the order header id
              Begin
                Select repair_line_id
                 into  l_rep_line_id
                from   csd_product_transactions
                where  order_header_id = DEL.header_id
                 and   action_type     = l_action_type
                 and   action_code     = l_action_code
                 and   rownum = 1;
              Exception
                WHEN NO_DATA_FOUND THEN
                 IF ( l_error_level >= G_debug_level) THEN
                    fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                    fnd_message.set_token('ORDER_HEADER_ID',DEL.header_id);
                    FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                 ELSE
                    fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                    fnd_message.set_token('ORDER_HEADER_ID',DEL.header_id);
                    fnd_msg_pub.add;
                 END IF;
                 RAISE PROCESS_ERROR;
              End;
              Begin
                 Debug('Calling CSD_PRODUCT_TRANSACTIONS_PKG.INSERT_ROW',l_mod_name,2);
                 CSD_PRODUCT_TRANSACTIONS_PKG.INSERT_ROW
                   (px_PRODUCT_TRANSACTION_ID   => l_prod_txn_id,
                    p_REPAIR_LINE_ID            => l_rep_line_id,
                    p_ESTIMATE_DETAIL_ID        => NULL,
                    p_ACTION_TYPE               => l_action_type,
                    p_ACTION_CODE               => l_action_code,
                    p_LOT_NUMBER                => DEL.lot_number,
                    p_SUB_INVENTORY             => DEL.subinventory,
                    p_INTERFACE_TO_OM_FLAG      => 'Y',
                    p_BOOK_SALES_ORDER_FLAG     => 'Y',
                    p_RELEASE_SALES_ORDER_FLAG  => l_release_so_flag,
                    p_SHIP_SALES_ORDER_FLAG     => l_ship_so_flag,
                    p_PROD_TXN_STATUS           => l_prod_txn_status,
                    p_PROD_TXN_CODE             => '',
                    p_LAST_UPDATE_DATE          => sysdate,
                    p_CREATION_DATE             => sysdate,
                    p_LAST_UPDATED_BY           => fnd_global.user_id,
                    p_CREATED_BY                => fnd_global.user_id,
                    p_LAST_UPDATE_LOGIN         => null,
                    p_ATTRIBUTE1                => '',
                    p_ATTRIBUTE2                => '',
                    p_ATTRIBUTE3                => '',
                    p_ATTRIBUTE4                => '',
                    p_ATTRIBUTE5                => '',
                    p_ATTRIBUTE6                => '',
                    p_ATTRIBUTE7                => '',
                    p_ATTRIBUTE8                => '',
                    p_ATTRIBUTE9                => '',
                    p_ATTRIBUTE10               => '',
                    p_ATTRIBUTE11               => '',
                    p_ATTRIBUTE12               => '',
                    p_ATTRIBUTE13               => '',
                    p_ATTRIBUTE14               => '',
                    p_ATTRIBUTE15               => '',
                    p_CONTEXT                   => '',
                    p_OBJECT_VERSION_NUMBER     => 1,
                    P_REQ_HEADER_ID             => DEL.req_header_id,
           	        P_REQ_LINE_ID               => DEL.req_line_id,
            	  P_ORDER_HEADER_ID           => DEL.header_id,
            	  P_ORDER_LINE_ID             => DEL.line_id,
            	  P_PRD_TXN_QTY_RECEIVED      => 0,
            	  P_PRD_TXN_QTY_SHIPPED       => nvl(DEL.shipped_quantity,0),
            	  P_SOURCE_SERIAL_NUMBER      => '',
            	  P_SOURCE_INSTANCE_ID        => NULL,
            	  P_NON_SOURCE_SERIAL_NUMBER  => '',
            	  P_NON_SOURCE_INSTANCE_ID    => NULL,
                    P_LOCATOR_ID                => DEL.locator_id,
            	  P_SUB_INVENTORY_RCVD        => '',
            	  P_LOT_NUMBER_RCVD           => '',
			        P_PICKING_RULE_ID           => null,
                   P_PROJECT_ID                => null,
                   P_TASK_ID                   => null,
                   P_UNIT_NUMBER               => '');
             Exception
               When Others then
                 IF ( l_error_level >= G_debug_level) THEN
                     fnd_message.set_name('CSD','CSD_PROD_TXN_INSERT_FAILED');
                     FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                 ELSE
                     fnd_message.set_name('CSD','CSD_PROD_TXN_INSERT_FAILED');
                     fnd_msg_pub.add;
                 END IF;
                 RAISE PROCESS_ERROR;
             END;
           END IF;

         ELSE -- Serialized scenario

           --Initialize the variables
    	     l_prod_txn_id := NULL;

           -- Check if the product txn exists
           -- for the order line and header id
           BEGIN
                 Select product_transaction_id,
                        repair_line_id
                 into   l_prod_txn_id,
                        l_rep_line_id
                 from  csd_product_transactions
                 where order_header_id = DEL.header_id
                  and  order_line_id   = DEL.line_id
                  and  action_type     = l_action_type
                  and  action_code     = l_action_code
                  and  rownum =1;
                  Debug('Product txn exist',l_mod_name,1);
                  l_prod_txn_exists := TRUE;
           EXCEPTION
               When NO_DATA_FOUND then
                    Debug('Product txn does not exist',l_mod_name,1);
                    l_prod_txn_exists := FALSE;
           END;

    	     IF DEL.released_status in ('I','C') THEN
                l_qty_shipped := 1;
           ELSE
                l_qty_shipped := 0;
    	     END IF;

           IF l_prod_txn_exists THEN
                       UPDATE CSD_PRODUCT_TRANSACTIONS
                       SET quantity_shipped = l_qty_shipped,
                           release_sales_order_flag = l_release_so_flag,
                           ship_sales_order_flag    = l_ship_so_flag,
                           prod_txn_status  = l_prod_txn_status,
                           sub_inventory    = DEL.subinventory,
                           lot_number       = DEL.lot_number,
                           locator_id       = DEL.locator_id,
      			   object_version_number = object_version_number+1,
                           last_update_date = sysdate,
                           last_updated_by  = fnd_global.user_id,
                           last_update_login = fnd_global.login_id
                       WHERE order_header_id = DEL.header_id
                        and  order_line_id   = DEL.line_id
                        and  action_type     = l_action_type
                        and  action_code     = l_action_code
                        and  prod_txn_status in('BOOKED','RELEASED')
                        and  rownum <= nvl(DEL.requested_quantity,0) ;
                       IF SQL%NOTFOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                             fnd_message.set_name('CSD','CSD_INV_ORDER_LINE_ID');
                             fnd_message.set_token('ORDER_LINE_ID',DEL.line_id);
                             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                             fnd_message.set_name('CSD','CSD_INV_ORDER_LINE_ID');
                             fnd_message.set_token('ORDER_LINE_ID',DEL.line_id);
                             fnd_msg_pub.add;
                          END IF;
                          RAISE PROCESS_ERROR;
                       END IF;
           ELSE
                       UPDATE CSD_PRODUCT_TRANSACTIONS
                       SET quantity_shipped = l_qty_shipped,
                           order_line_id    = DEL.line_id,
                           release_sales_order_flag = l_release_so_flag,
                           ship_sales_order_flag    = l_ship_so_flag,
                           prod_txn_status  = l_prod_txn_status,
                           sub_inventory    = DEL.subinventory,
                           lot_number       = DEL.lot_number,
                           locator_id       = DEL.locator_id,
  			         object_version_number = object_version_number+1,
                           last_update_date = sysdate,
                           last_updated_by  = fnd_global.user_id,
                           last_update_login = fnd_global.login_id
                       WHERE order_header_id = DEL.header_id
                        and  action_type     = l_action_type
                        and  action_code     = l_action_code
                        and  prod_txn_status  in ('BOOKED','RELEASED')
                        and  rownum <= nvl(DEL.requested_quantity,0);
                       IF SQL%NOTFOUND THEN
                          IF ( l_error_level >= G_debug_level) THEN
                             fnd_message.set_name('CSD','CSD_INV_ORDER_LINE_ID');
                             fnd_message.set_token('ORDER_LINE_ID',DEL.line_id);
                             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                          ELSE
                             fnd_message.set_name('CSD','CSD_INV_ORDER_LINE_ID');
                             fnd_message.set_token('ORDER_LINE_ID',DEL.line_id);
                             fnd_msg_pub.add;
                          END IF;
                          RAISE PROCESS_ERROR;
                       END IF;
           END IF;

         END IF;

       ELSE -- action_type = 'MOVE_OUT'

            -- Move-out Lines
           Debug('Processing the move-out lines ',l_mod_name,1);

           Select nvl(sum(quantity),0)
           into l_total_shipped_qty
           from csd_repair_history
           where event_code = 'PSI'
           and  paramn1    = DEL.delivery_detail_id;

            -- Debug messages
           Debug('l_total_shipped_qty= '||l_total_shipped_qty,l_mod_name,1);
           IF l_total_shipped_qty >= DEL.shipped_quantity THEN
                  -- Debug messages
                  Debug('Skipping the record ',l_mod_name,1);
                  RAISE SKIP_RECORD;
           END IF;

            -- Processing starts for item is pre-deined/serialized inv receipt
            -- In case of partial shipment against the move-out internal orders
            -- the order lines gets split. But the product txn exist only for the
            -- original order line id and header id. In such case the update program
            -- will create new product txn lines for the split order lines
            --
            --BEFORE SPLIT
            --
            --  Order Lines
            --      Line Id    Header Id  Qty  Shipped Qty  PO Line Id  Split_From Line_id
            --        L1         H1        10      0          PL1
            --
            --  Delivery Lines
            --    Del Line Id    Ord Line Id   Shipped Qty  Rel Status
            --       D1             L1              0          R/Y
            --
            --  Repair Order
            --     RO Number       RO qty   Shipped Qty
            --       R1            10          0
            --
            --  PRODUCT TXN
            --    Prod Txn      Line Id   Header Id   PO Line Id    Shipped Qty
            --     P1            L1         H1          PL1             0
            --
            --
            --  AFTER ORDER LINE SPLIT (Partial Shipping)
            --  Order Lines
            --     Line Id    Header Id  Qty  Shipped Qty  PO Line Id  Split_From Line_id
            --       L1         H1        6     6          PL1
            --       L2         H1        1     1          PL1           L1
            --       L3         H1        3     3          PL1           L2
            --
            --  Delivery Lines
            --    Del Line Id    Ord Line Id   Shipped Qty
            --       D1             L1              6
            --       D2             L2              1
            --       D3             L3              3
            --
            --  Repair Order
            --     RO Number       RO qty   Shipped Qty
            --       R1            10          0
            --
            --  PRODUCT TXN
            --    Prod Txn      Line Id   Header Id   PO Line Id    Shipped Qty
            --     P1            L1         H1          PL1             6
            --     P2            L2         H1          PL1             1
            --     P3            L3         H1          PL1             3
            --
            --
     	      IF DEL.serial_number_control_code = 1 THEN

          	    --Initialize the variables
      	    l_prod_txn_id := NULL;

                -- Check if the product txn exists
                -- for the order line and header id
                BEGIN
                 Select product_transaction_id,
                        repair_line_id
                 into   l_prod_txn_id,
                        l_rep_line_id
                 from  csd_product_transactions
                 where order_header_id = DEL.header_id
                  and  order_line_id   = DEL.line_id
                  and  action_type     = l_action_type
                  and  action_code     = l_action_code;
                  Debug('Product txn exist',l_mod_name,1);
                  l_prod_txn_exists := TRUE;
                EXCEPTION
                 When NO_DATA_FOUND then
                    Debug('Product txn does not exist',l_mod_name,1);
                    l_prod_txn_exists := FALSE;
                END;

                -- Non-Serialized case
                Debug('Item Is Non-Serialized ',l_mod_name,1);

              IF l_prod_txn_exists THEN
                --If product txn exist then update the shipped qty and the status
                UPDATE CSD_PRODUCT_TRANSACTIONS
                SET quantity_shipped = nvl(quantity_shipped,0) + nvl(DEL.shipped_quantity,0),
                    sub_inventory    =  DEL.subinventory,
                    lot_number       =  DEL.lot_number,
                    locator_id       =  DEL.locator_id,
                    release_sales_order_flag = l_release_so_flag,
                    ship_sales_order_flag    = l_ship_so_flag,
                    prod_txn_status  = l_prod_txn_status,
    		        object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE product_transaction_id = l_prod_txn_id;
                 IF SQL%NOTFOUND THEN
                      IF ( l_error_level >= G_debug_level) THEN
                          fnd_message.set_name('CSD','CSD_INV_PROD_TXN_ID');
                          fnd_message.set_token('PROD_TXN_ID',l_prod_txn_id);
                          FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                      ELSE
                          fnd_message.set_name('CSD','CSD_INV_PROD_TXN_ID');
                          fnd_message.set_token('PROD_TXN_ID',l_prod_txn_id);
                          fnd_msg_pub.add;
                      END IF;
                      RAISE PROCESS_ERROR;
                 END IF;

              ELSE -- product txn does not exist
       	    -- If product txn does not exist then insert a product txn for the
    	          -- split order line
                -- Get the repair line id for the order header id
                Begin
                  Select repair_line_id
                   into  l_rep_line_id
                  from   csd_product_transactions
                  where  order_header_id = DEL.header_id
                   and   action_type     = l_action_type
                   and   action_code     = l_action_code
                   and   rownum = 1;
                Exception
                  WHEN NO_DATA_FOUND THEN
                   IF ( l_error_level >= G_debug_level) THEN
                      fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                      fnd_message.set_token('ORDER_HEADER_ID',DEL.header_id);
                      FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                   ELSE
                      fnd_message.set_name('CSD','CSD_INV_ORD_HEADER_ID');
                      fnd_message.set_token('ORDER_HEADER_ID',DEL.header_id);
                      fnd_msg_pub.add;
                   END IF;
                   RAISE PROCESS_ERROR;
                End;
                Begin
                   Debug('Calling CSD_PRODUCT_TRANSACTIONS_PKG.INSERT_ROW',l_mod_name,2);
                   CSD_PRODUCT_TRANSACTIONS_PKG.INSERT_ROW
                     (px_PRODUCT_TRANSACTION_ID   => l_prod_txn_id,
                      p_REPAIR_LINE_ID            => l_rep_line_id,
                      p_ESTIMATE_DETAIL_ID        => NULL,
                      p_ACTION_TYPE               => l_action_type,
                      p_ACTION_CODE               => l_action_code,
                      p_LOT_NUMBER                => DEL.lot_number,
                      p_SUB_INVENTORY             => DEL.subinventory,
                      p_INTERFACE_TO_OM_FLAG      => 'Y',
                      p_BOOK_SALES_ORDER_FLAG     => 'Y',
                      p_RELEASE_SALES_ORDER_FLAG  => l_release_so_flag,
                      p_SHIP_SALES_ORDER_FLAG     => l_ship_so_flag,
                      p_PROD_TXN_STATUS           => l_prod_txn_status,
                      p_PROD_TXN_CODE             => '',
                      p_LAST_UPDATE_DATE          => sysdate,
                      p_CREATION_DATE             => sysdate,
                      p_LAST_UPDATED_BY           => fnd_global.user_id,
                      p_CREATED_BY                => fnd_global.user_id,
                      p_LAST_UPDATE_LOGIN         => null,
                      p_ATTRIBUTE1                => '',
                      p_ATTRIBUTE2                => '',
                      p_ATTRIBUTE3                => '',
                      p_ATTRIBUTE4                => '',
                      p_ATTRIBUTE5                => '',
                      p_ATTRIBUTE6                => '',
                      p_ATTRIBUTE7                => '',
                      p_ATTRIBUTE8                => '',
                      p_ATTRIBUTE9                => '',
                      p_ATTRIBUTE10               => '',
                      p_ATTRIBUTE11               => '',
                      p_ATTRIBUTE12               => '',
                      p_ATTRIBUTE13               => '',
                      p_ATTRIBUTE14               => '',
                      p_ATTRIBUTE15               => '',
                      p_CONTEXT                   => '',
                      p_OBJECT_VERSION_NUMBER     => 1,
                      P_REQ_HEADER_ID             => DEL.req_header_id,
             	    P_REQ_LINE_ID               => DEL.req_line_id,
              	    P_ORDER_HEADER_ID           => DEL.header_id,
              	    P_ORDER_LINE_ID             => DEL.line_id,
              	    P_PRD_TXN_QTY_RECEIVED      => 0,
              	    P_PRD_TXN_QTY_SHIPPED       => nvl(DEL.shipped_quantity,0),
              	    P_SOURCE_SERIAL_NUMBER      => '',
              	    P_SOURCE_INSTANCE_ID        => NULL,
              	    P_NON_SOURCE_SERIAL_NUMBER  => '',
              	    P_NON_SOURCE_INSTANCE_ID    => NULL,
                      P_LOCATOR_ID                => DEL.locator_id,
              	    P_SUB_INVENTORY_RCVD        => '',
              	    P_LOT_NUMBER_RCVD           => '',
			          P_PICKING_RULE_ID           => null,
                   P_PROJECT_ID                => null,
                   P_TASK_ID                   => null,
                   P_UNIT_NUMBER               => '');

               Exception
                 When Others then
                   IF ( l_error_level >= G_debug_level) THEN
                       fnd_message.set_name('CSD','CSD_PROD_TXN_INSERT_FAILED');
                       FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                   ELSE
                       fnd_message.set_name('CSD','CSD_PROD_TXN_INSERT_FAILED');
                       fnd_msg_pub.add;
                   END IF;
                   RAISE PROCESS_ERROR;
               END;
             END IF; -- end if prod_txn_exists

             IF DEL.released_status in ('C','I') THEN

                -- Updating the repair order with shipped_qty
                Update csd_repairs
                set quantity_shipped = nvl(quantity_shipped,0) + DEL.shipped_quantity,
                    object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                where repair_line_id = l_rep_line_id;
                IF SQL%NOTFOUND THEN
                       IF ( l_error_level >= G_debug_level)  THEN
                              FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                              FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                              FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                       ELSE
                              FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                              FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                              FND_MSG_PUB.ADD;
                       END IF;
                       RAISE PROCESS_ERROR;
                END IF;

              -- Initialize the activity rec
              l_activity_rec := INIT_ACTIVITY_REC ;

              -- Assign the values for activity record
              l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
              l_activity_rec.REPAIR_LINE_ID := l_rep_line_id;
              l_activity_rec.EVENT_CODE     := 'PSI';
              l_activity_rec.ACTION_CODE    := 0;
              l_activity_rec.EVENT_DATE     := DEL.shipment_date;
              l_activity_rec.QUANTITY       := DEL.shipped_quantity;
              l_activity_rec.PARAMN1        := DEL.delivery_detail_id;
              l_activity_rec.PARAMN2        := l_prod_txn_id;
              l_activity_rec.PARAMN3        := DEL.source_organization_id;
              l_activity_rec.PARAMN5        := DEL.destination_organization_id;
              l_activity_rec.PARAMC1        := DEL.order_number;
              l_activity_rec.PARAMC2        := DEL.requisition_number;
              l_activity_rec.PARAMC3        := DEL.source_org_name;
              l_activity_rec.PARAMC4        := DEL.source_subinventory;
              l_activity_rec.PARAMC5        := DEL.destination_org_name;
              l_activity_rec.PARAMC6        := DEL.destination_subinventory;
              l_activity_rec.OBJECT_VERSION_NUMBER := null;

             -- Debug Messages
             Debug('Calling LOG_ACTIVITY',l_mod_name,2);

             -- Calling LOG_ACTIVITY for logging activity
             LOG_ACTIVITY
                    ( p_api_version     => p_api_version,
                      p_commit          => p_commit,
                      p_init_msg_list   => p_init_msg_list,
                      p_validation_level => p_validation_level,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_activity_rec    => l_activity_rec );

               -- Debug Messages
              Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);

              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

             END IF; -- end of del.released_status in ('c','i')

            ELSE --DEL.serial_number_control_code <> 1 THEN

             Debug('DEL.LOT_CONTROL_CODE ='||DEL.LOT_CONTROL_CODE ,l_mod_name,1);

             -- In case of item serialized at sales order issue, the serial number is stored
             -- in the material unit transactions. Need to join the mtl_material_transactions
             -- with mtl_unit_transactions to get the serial numbers.
             --  Serial Number Control Code = 6 (Serialized at Sales order Issue)
             --   Delivery Lines
             --     Del Line Id    Order Line Id   Shipped Qty
             --        D1            L1              6
             --        D2            L2              3
             --        D3            L2              1
             --
             --  Unit Trxs
             --   Txn Id    Del Line id  Serial Num
             --     T1         D1           SN11
             --     T2         D1           SN12
             --     T3         D1           SN13
             --     T4         D1           SN14
             --     T5         D1           SN15
             --     T6         D1           SN16
             --     T7         D2           SN17
             --     T8         D2           SN18
             --     T9         D2           SN19
             --     T10        D3           SN20
             --
            IF DEL.LOT_CONTROL_CODE = 1 THEN
             Debug(' Item is not lot controlled',l_mod_name,1);

             FOR UT in MTL_UNIT_TXN (DEL.delivery_detail_id, DEL.txn_source_id)
             LOOP
              BEGIN
                  Begin
			    -- saupadhy 3757519 07102004 Commented line Supercession_inv_item_id is null
			    -- as this may not be true.
			    -- Added line cpt.Order_Header_id = Del.Header_Id as this
                   Select cpt.product_transaction_id,
                          cpt.repair_line_id
                    into  l_prod_txn_id,
                          l_rep_line_id
                   from   csd_product_transactions cpt,
                          csd_repairs cra
                   where cpt.order_header_id = DEL.Header_id
                   and   cpt.action_type    = 'MOVE_OUT'
                   and   cpt.action_code    = 'USABLES'
                   and   cpt.prod_txn_status  in ('BOOKED', 'RELEASED')
                   -- and   cra.supercession_inv_item_id is null
  			    and   cpt.source_serial_number is null
			    and   cpt.repair_line_id = cra.repair_line_id
  			    and   cra.serial_number  = UT.serial_number ;

                   Debug('Product txn line found',l_mod_name,1);

                   -- Updating the product txns with status,shipped_qty
                   Update csd_product_transactions
                   set prod_txn_status  = 'SHIPPED',
                       quantity_shipped =  1,
                       sub_inventory    =  DEL.subinventory,
                       locator_id       =  DEL.locator_id,
                       lot_number       =  DEL.lot_number,
                       release_sales_order_flag = 'Y',
                       ship_sales_order_flag = 'Y',
                       order_line_id    = DEL.line_id,
                       source_serial_number = UT.serial_number,
                       object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   where product_transaction_id = l_prod_txn_id;
                    IF SQL%NOTFOUND THEN
                       IF ( l_error_level >= G_debug_level)  THEN
                         FND_MESSAGE.SET_NAME('CSD','CSD_INV_PROD_TXN_ID');
                         FND_MESSAGE.SET_TOKEN('PROD_TXN_ID',l_prod_txn_id);
                         FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                       ELSE
                         FND_MESSAGE.SET_NAME('CSD','CSD_INV_PROD_TXN_ID');
                         FND_MESSAGE.SET_TOKEN('PROD_TXN_ID',l_prod_txn_id);
                         FND_MSG_PUB.ADD;
                       END IF;
                       RAISE PROCESS_ERROR;
                    END IF;

                   -- Updating the repair order with shipped_qty
                   Update csd_repairs
                   set quantity_shipped = 1,
                       object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   where repair_line_id = l_rep_line_id;
                   IF SQL%NOTFOUND THEN
                      IF ( l_error_level >= G_debug_level)  THEN
                         FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                         FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                         FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                      ELSE
                         FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                         FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                         FND_MSG_PUB.ADD;
                      END IF;
                      RAISE PROCESS_ERROR;
                   END IF;
                       -- product txn exist
                      l_prod_txn_exists := TRUE;
                 Exception
                    WHEN NO_DATA_FOUND THEN
                       Debug('Product txn line not found',l_mod_name,1);
                       -- product txn does not exist
                       l_prod_txn_exists := FALSE;
                 End;

                        --If the serial number on the unit transactions may not be in the
      			-- same order as the product txn. In a delivery some serial numbers could find
      			-- repair order/product txn combination. But some may not have a matching serial number
      			-- So we do not want to take repair order/product txn which could have a matching serial
      			-- number in the later unit transactions
      			--
      			-- Product Txn
      			-- Prod Txn  RO Num Qty RO Serial Num
      			--  P1         R1    1     SN1
      			--  P2         R2    1     SN2
      			--  P3         R3    1     SN3
      			--  P4         R4    1     SN4
      			--  P5         R5    1     SN5
      			--
      			-- Delivery Lines
      			-- Del Id  Ship Qty Ord Line
      			--  D1       2        L1
      			--  D2       3        L2
      			--
      			-- Unit Transactions
      			-- Txn Id  Del Id  Qty  Serial Num
      			--  M1       D1    1     SN5
      			--  M2       D1    1     SN1
      			--  M3       D2    1     SN9
      			--  M4       D2    1     SN2
      			--  M5       D2    1     SN3
      			-- The serial number would finally matched as follows:
      			-- Ro Num Prod Txn RO SN  UTSerial Num
      			--  R1      P1      SN1      SN1
      			--  R2      P2      SN2      SN2
      			--  R3      P3      SN3      SN3
      			--  R4      P4      SN4      SN9
      			--  R5      P5      SN5      SN5
                 IF NOT(l_prod_txn_exists) THEN
                     Begin
                       Select cpt.product_transaction_id,
                              cpt.repair_line_id
                        into  l_prod_txn_id,
                              l_rep_line_id
                       from   csd_product_transactions cpt,
                              csd_repairs cra
                       where  cpt.repair_line_id  = cra.repair_line_id
                        and   cpt.order_header_id = DEL.header_id
                        and   cpt.source_serial_number is null
                        and   cpt.action_type    = 'MOVE_OUT'
                        and   cpt.action_code    = 'USABLES'
                        and   cpt.prod_txn_status in ('BOOKED','RELEASED')
                        and   cra.serial_number not in
                                         (select
                                               mut.serial_number
                                          from mtl_material_transactions mtl,
                                               mtl_unit_transactions mut,
  							     wsh_delivery_details wdd
                                          where mtl.transaction_id     = mut.transaction_id
                                           and  mtl.transaction_source_type_id = 8  -- Internal Order
                                           and  mtl.transaction_type_id  in ( 50,62,54,34)
                                           and  mtl.transaction_source_id = DEL.txn_source_id
                                           and  mtl.picking_line_id    = wdd.delivery_detail_id
  						       and  wdd.source_header_id   = DEL.header_id)
                        and   rownum = 1;

                         -- Updating the product txns with status,shipped_qty
                         Update csd_product_transactions
                         set prod_txn_status  = 'SHIPPED',
                             quantity_shipped =  1,
                             sub_inventory    =  DEL.subinventory,
                             locator_id       =  DEL.locator_id,
                             lot_number       =  DEL.lot_number,
                             release_sales_order_flag = 'Y',
                             ship_sales_order_flag = 'Y',
                             order_line_id    = DEL.line_id,
                             source_serial_number = UT.serial_number,
                             object_version_number = object_version_number+1,
                             last_update_date = sysdate,
                             last_updated_by  = fnd_global.user_id,
                             last_update_login = fnd_global.login_id
                         where product_transaction_id = l_prod_txn_id;
                         IF SQL%NOTFOUND THEN
                               IF ( l_error_level >= G_debug_level)  THEN
                                  FND_MESSAGE.SET_NAME('CSD','CSD_PROD_TXN_UPD_FAILED');
                                  FND_MESSAGE.SET_TOKEN('PROD_TXN_ID',l_prod_txn_id);
                                  FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                               ELSE
                                  FND_MESSAGE.SET_NAME('CSD','CSD_PROD_TXN_UPD_FAILED');
                                  FND_MESSAGE.SET_TOKEN('PROD_TXN_ID',l_prod_txn_id);
                                  FND_MSG_PUB.ADD;
                               END IF;
                               RAISE PROCESS_ERROR;
                         END IF;

                         -- Updating the repair order with shipped_qty
                         Update csd_repairs
                         set quantity_shipped = 1,
                             object_version_number = object_version_number+1,
                             last_update_date = sysdate,
                             last_updated_by  = fnd_global.user_id,
                             last_update_login = fnd_global.login_id
                         where repair_line_id = l_rep_line_id;
                         IF SQL%NOTFOUND THEN
                               IF ( l_error_level >= G_debug_level)  THEN
                                 FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                                 FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                               ELSE
                                 FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                                 FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                                 FND_MSG_PUB.ADD;
                               END IF;
                               RAISE PROCESS_ERROR;
                         END IF;
                     Exception
                        WHEN NO_DATA_FOUND THEN
                           Debug('In NO_DATA_FOUND exception ',l_mod_name,4);
                           RAISE PROCESS_ERROR;
                        WHEN OTHERS THEN
                           Debug('In Others exception ',l_mod_name,4);
                           RAISE PROCESS_ERROR;
                     End;
                 End If; --not(l_prod_txn_exist)

                      -- Initialize the activity rec
                      l_activity_rec := INIT_ACTIVITY_REC ;

                      -- Assign the values for activity record
                      l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                      l_activity_rec.REPAIR_LINE_ID := l_rep_line_id;
                      l_activity_rec.EVENT_CODE     := 'PSI';
                      l_activity_rec.ACTION_CODE    := 0;
                      l_activity_rec.EVENT_DATE     := DEL.shipment_date;
                      l_activity_rec.QUANTITY       := 1;
                      l_activity_rec.PARAMN1        := DEL.delivery_detail_id;
                      l_activity_rec.PARAMN2        := l_prod_txn_id;
                      l_activity_rec.PARAMN3        := DEL.source_organization_id;
                      l_activity_rec.PARAMN5        := DEL.destination_organization_id;
                      l_activity_rec.PARAMC1        := DEL.order_number;
                      l_activity_rec.PARAMC2        := DEL.requisition_number;
                      l_activity_rec.PARAMC3        := DEL.source_org_name;
                      l_activity_rec.PARAMC4        := DEL.source_subinventory;
                      l_activity_rec.PARAMC5        := DEL.destination_org_name;
                      l_activity_rec.PARAMC6        := DEL.destination_subinventory;
                      l_activity_rec.OBJECT_VERSION_NUMBER := null;

                   -- Debug Messages
                   Debug('Calling LOG_ACTIVITY',l_mod_name,2);

                   -- Calling LOG_ACTIVITY for logging activity
                   -- Shipment against internal sales order
                   LOG_ACTIVITY
                          ( p_api_version     => p_api_version,
                            p_commit          => p_commit,
                            p_init_msg_list   => p_init_msg_list,
                            p_validation_level => p_validation_level,
                            x_return_status   => x_return_status,
                            x_msg_count       => x_msg_count,
                            x_msg_data        => x_msg_data,
                            p_activity_rec    => l_activity_rec );

                  -- Debug Messages
                  Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
                  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                     Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

               EXCEPTION
                 WHEN  PROCESS_ERROR  THEN
                       Debug('Encountered PROCESS_ERROR exception in UT cursor',l_mod_name,1);
                       RAISE FND_API.G_EXC_ERROR;
                 WHEN  SKIP_RECORD    THEN
                       Debug('Skipping record in UT cursor',l_mod_name,1);
                       NULL;
               END;
             END LOOP;

        ELSE  -- LOT CONTROLLED AND SERIAL CONTROLLED ITEM

           Debug(' Item is lot controlled',l_mod_name,1);

           FOR UT in MTL_UNIT_LOT_TXN (DEL.delivery_detail_id, DEL.txn_source_id )
            LOOP
              BEGIN
                  Begin
                   Select cpt.product_transaction_id,
                          cpt.repair_line_id
                    into  l_prod_txn_id,
                          l_rep_line_id
                   from   csd_product_transactions cpt,
                          csd_repairs cra
                   where  cpt.repair_line_id = cra.repair_line_id
                    and   cra.supercession_inv_item_id is null
  		        and   cpt.source_serial_number is null
  			  and   cra.serial_number  = UT.serial_number
                    and   cpt.action_type    = 'MOVE_OUT'
                    and   cpt.action_code    = 'USABLES'
                    and   cpt.prod_txn_status  in ('BOOKED', 'RELEASED');

                   Debug('Product txn line found',l_mod_name,1);

                   -- Updating the product txns with status,shipped_qty
                   Update csd_product_transactions
                   set prod_txn_status  = 'SHIPPED',
                       quantity_shipped =  1,
                       sub_inventory    =  DEL.subinventory,
                       locator_id       =  DEL.locator_id,
                       lot_number       =  DEL.lot_number,
                       release_sales_order_flag = 'Y',
                       ship_sales_order_flag = 'Y',
                       order_line_id    = DEL.line_id,
                       source_serial_number = UT.serial_number,
                       object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   where product_transaction_id = l_prod_txn_id;
                    IF SQL%NOTFOUND THEN
                       IF ( l_error_level >= G_debug_level)  THEN
                         FND_MESSAGE.SET_NAME('CSD','CSD_INV_PROD_TXN_ID');
                         FND_MESSAGE.SET_TOKEN('PROD_TXN_ID',l_prod_txn_id);
                         FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                       ELSE
                         FND_MESSAGE.SET_NAME('CSD','CSD_INV_PROD_TXN_ID');
                         FND_MESSAGE.SET_TOKEN('PROD_TXN_ID',l_prod_txn_id);
                         FND_MSG_PUB.ADD;
                       END IF;
                       RAISE PROCESS_ERROR;
                    END IF;

                   -- Updating the repair order with shipped_qty
                   Update csd_repairs
                   set quantity_shipped = 1,
                       object_version_number = object_version_number+1,
                       last_update_date = sysdate,
                       last_updated_by  = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                   where repair_line_id = l_rep_line_id;
                   IF SQL%NOTFOUND THEN
                      IF ( l_error_level >= G_debug_level)  THEN
                         FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                         FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                         FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                      ELSE
                         FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                         FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                         FND_MSG_PUB.ADD;
                      END IF;
                      RAISE PROCESS_ERROR;
                   END IF;
                       -- product txn exist
                      l_prod_txn_exists := TRUE;
                 Exception
                    WHEN NO_DATA_FOUND THEN
                       Debug('Product txn line not found',l_mod_name,1);
                       -- product txn does not exist
                       l_prod_txn_exists := FALSE;
                 End;

                        --If the serial number on the unit transactions may not be in the
      			-- same order as the product txn. In a delivery some serial numbers could find
      			-- repair order/product txn combination. But some may not have a matching serial number
      			-- So we do not want to take repair order/product txn which could have a matching serial
      			-- number in the later unit transactions
      			--
      			-- Product Txn
      			-- Prod Txn  RO Num Qty RO Serial Num
      			--  P1         R1    1     SN1
      			--  P2         R2    1     SN2
      			--  P3         R3    1     SN3
      			--  P4         R4    1     SN4
      			--  P5         R5    1     SN5
      			--
      			-- Delivery Lines
      			-- Del Id  Ship Qty Ord Line
      			--  D1       2        L1
      			--  D2       3        L2
      			--
      			-- Unit Transactions
      			-- Txn Id  Del Id  Qty  Serial Num
      			--  M1       D1    1     SN5
      			--  M2       D1    1     SN1
      			--  M3       D2    1     SN9
      			--  M4       D2    1     SN2
      			--  M5       D2    1     SN3
      			-- The serial number would finally matched as follows:
      			-- Ro Num Prod Txn RO SN  UTSerial Num
      			--  R1      P1      SN1      SN1
      			--  R2      P2      SN2      SN2
      			--  R3      P3      SN3      SN3
      			--  R4      P4      SN4      SN9
      			--  R5      P5      SN5      SN5
                 IF NOT(l_prod_txn_exists) THEN
                     Begin
                       Select cpt.product_transaction_id,
                              cpt.repair_line_id
                        into  l_prod_txn_id,
                              l_rep_line_id
                       from   csd_product_transactions cpt,
                              csd_repairs cra
                       where  cpt.repair_line_id  = cra.repair_line_id
                        and   cpt.order_header_id = DEL.header_id
                        and   cpt.source_serial_number is null
                        and   cpt.action_type    = 'MOVE_OUT'
                        and   cpt.action_code    = 'USABLES'
                        and   cpt.prod_txn_status in ('BOOKED','RELEASED')
                        and   cra.serial_number not in
                                         (select
                                               mut.serial_number
                                          from mtl_material_transactions mtl,
                                               mtl_unit_transactions mut,
  							   wsh_delivery_details wdd
                                          where mtl.transaction_id     = mut.transaction_id
                                           and  mtl.transaction_source_type_id = 8  -- Internal Order
                                           and  mtl.transaction_type_id  in ( 50,62,54,34)
                                           and  mtl.transaction_source_id = DEL.txn_source_id
                                           and  mtl.picking_line_id    = wdd.delivery_detail_id
  						     and  wdd.source_header_id   = DEL.header_id)
                        and   rownum = 1;

                         -- Updating the product txns with status,shipped_qty
                         Update csd_product_transactions
                         set prod_txn_status  = 'SHIPPED',
                             quantity_shipped =  1,
                             sub_inventory    =  DEL.subinventory,
                             locator_id       =  DEL.locator_id,
                             lot_number       =  DEL.lot_number,
                             release_sales_order_flag = 'Y',
                             ship_sales_order_flag = 'Y',
                             order_line_id    = DEL.line_id,
                             source_serial_number = UT.serial_number,
                             object_version_number = object_version_number+1,
                             last_update_date = sysdate,
                             last_updated_by  = fnd_global.user_id,
                             last_update_login = fnd_global.login_id
                         where product_transaction_id = l_prod_txn_id;
                         IF SQL%NOTFOUND THEN
                               IF ( l_error_level >= G_debug_level)  THEN
                                  FND_MESSAGE.SET_NAME('CSD','CSD_PROD_TXN_UPD_FAILED');
                                  FND_MESSAGE.SET_TOKEN('PROD_TXN_ID',l_prod_txn_id);
                                  FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                               ELSE
                                  FND_MESSAGE.SET_NAME('CSD','CSD_PROD_TXN_UPD_FAILED');
                                  FND_MESSAGE.SET_TOKEN('PROD_TXN_ID',l_prod_txn_id);
                                  FND_MSG_PUB.ADD;
                               END IF;
                               RAISE PROCESS_ERROR;
                         END IF;

                         -- Updating the repair order with shipped_qty
                         Update csd_repairs
                         set quantity_shipped = 1,
                             object_version_number = object_version_number+1,
                             last_update_date = sysdate,
                             last_updated_by  = fnd_global.user_id,
                             last_update_login = fnd_global.login_id
                         where repair_line_id = l_rep_line_id;
                         IF SQL%NOTFOUND THEN
                               IF ( l_error_level >= G_debug_level)  THEN
                                 FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                                 FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
                               ELSE
                                 FND_MESSAGE.SET_NAME('CSD','CSD_RO_UPD_FAILED');
                                 FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',l_rep_line_id);
                                 FND_MSG_PUB.ADD;
                               END IF;
                               RAISE PROCESS_ERROR;
                         END IF;
                     Exception
                        WHEN NO_DATA_FOUND THEN
                           Debug('In NO_DATA_FOUND exception ',l_mod_name,4);
                           RAISE PROCESS_ERROR;
                        WHEN OTHERS THEN
                           Debug('In Others exception ',l_mod_name,4);
                           RAISE PROCESS_ERROR;
                     End;
                 End If; --not(l_prod_txn_exist)

                      -- Initialize the activity rec
                      l_activity_rec := INIT_ACTIVITY_REC ;

                      -- Assign the values for activity record
                      l_activity_rec.REPAIR_HISTORY_ID := l_rep_hist_id;
                      l_activity_rec.REPAIR_LINE_ID := l_rep_line_id;
                      l_activity_rec.EVENT_CODE     := 'PSI';
                      l_activity_rec.ACTION_CODE    := 0;
                      l_activity_rec.EVENT_DATE     := DEL.shipment_date;
                      l_activity_rec.QUANTITY       := 1;
                      l_activity_rec.PARAMN1        := DEL.delivery_detail_id;
                      l_activity_rec.PARAMN2        := l_prod_txn_id;
                      l_activity_rec.PARAMN3        := DEL.source_organization_id;
                      l_activity_rec.PARAMN5        := DEL.destination_organization_id;
                      l_activity_rec.PARAMC1        := DEL.order_number;
                      l_activity_rec.PARAMC2        := DEL.requisition_number;
                      l_activity_rec.PARAMC3        := DEL.source_org_name;
                      l_activity_rec.PARAMC4        := DEL.source_subinventory;
                      l_activity_rec.PARAMC5        := DEL.destination_org_name;
                      l_activity_rec.PARAMC6        := DEL.destination_subinventory;
                      l_activity_rec.OBJECT_VERSION_NUMBER := null;

                   -- Debug Messages
                   Debug('Calling LOG_ACTIVITY',l_mod_name,2);

                   -- Calling LOG_ACTIVITY for logging activity
                   -- Shipment against internal sales order
                   LOG_ACTIVITY
                          ( p_api_version     => p_api_version,
                            p_commit          => p_commit,
                            p_init_msg_list   => p_init_msg_list,
                            p_validation_level => p_validation_level,
                            x_return_status   => x_return_status,
                            x_msg_count       => x_msg_count,
                            x_msg_data        => x_msg_data,
                            p_activity_rec    => l_activity_rec );

                  -- Debug Messages
                  Debug('Return Status from LOG_ACTIVITY:'||x_return_status,l_mod_name,2);
                  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                     Debug('LOG_ACTIVITY api failed ',l_mod_name,4);
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

               EXCEPTION
                 WHEN  PROCESS_ERROR  THEN
                       Debug('Encountered PROCESS_ERROR exception in UT cursor',l_mod_name,1);
                       RAISE FND_API.G_EXC_ERROR;
                 WHEN  SKIP_RECORD    THEN
                       Debug('Skipping record in UT cursor',l_mod_name,1);
                       NULL;
               END;
             END LOOP;

           END IF;

          END IF; -- IF DEL.serial_number_control_code = 1

       END IF; -- end if l_action_type = 'MOVE_IN'

     EXCEPTION
       WHEN  PROCESS_ERROR  THEN
             Debug('Encountered PROCESS_ERROR exception in DELUT cursor',l_mod_name,1);
             RAISE FND_API.G_EXC_ERROR;
       WHEN  SKIP_RECORD    THEN
             NULL;
       WHEN OTHERS THEN
             Debug('Encountered OTHERS in DEL cursor',l_mod_name,1);
             RAISE FND_API.G_EXC_ERROR;
     END;
   END LOOP;

   IF(DELIVERY_LINES_ALL%ISOPEN ) THEN
       CLOSE DELIVERY_LINES_ALL;
   END IF;
   IF(DELIVERY_LINES%ISOPEN ) THEN
       CLOSE DELIVERY_LINES;
   END IF;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
          (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data);

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO IO_SHIP_UPDATE;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO IO_SHIP_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO IO_SHIP_UPDATE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

END IO_SHIP_UPDATE;

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

Procedure  WIP_UPDATE
        ( p_api_version          IN   NUMBER,
          p_commit               IN   VARCHAR2,
          p_init_msg_list        IN   VARCHAR2,
          p_validation_level     IN   NUMBER,
          x_return_status        OUT  NOCOPY  VARCHAR2,
          x_msg_count            OUT  NOCOPY  NUMBER,
          x_msg_data             OUT  NOCOPY  VARCHAR2,
          p_upd_job_completion   IN   VARCHAR2,
          p_repair_line_id       IN   NUMBER
         ) IS

  -- Standard Variables
  l_api_name          CONSTANT VARCHAR2(30)   := 'WIP_UPDATE';
  l_api_version       CONSTANT NUMBER         := 1.0;

  -- Variables used in the program
  l_dummy             varchar2(30);

  -- Variables used for FND log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.wip_update';

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT  WIP_UPDATE;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Debug Messages
     Debug('At the Beginning of Wip_update ',l_mod_name,1);
     Debug('Repair Line Id ='||p_repair_line_id,l_mod_name,1);

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name   ,
                                         G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;

     -- Api body starts

     -- Validate the repair line id
     IF  p_repair_line_id is not null THEN
         IF NOT(csd_process_util.validate_rep_line_id(p_repair_line_id)) THEN
              Debug('Validate_rep_line_id failed',l_mod_name,1);
              RAISE FND_API.G_EXC_ERROR;
         END IF;
     END IF;

     -- Debug messages
     Debug('Calling  JOB_CREATION_UPDATE',l_mod_name,2);

     JOB_CREATION_UPDATE
        ( p_api_version          =>  p_api_version,
          p_commit               =>  p_commit,
          p_init_msg_list        =>  p_init_msg_list,
          p_validation_level     =>  p_validation_level,
          x_return_status        =>  x_return_status,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data ,
          p_repair_line_id       =>  p_repair_line_id);

     -- Debug messages
    Debug('Return Status from  JOB_CREATION_UPDATE :'||x_return_status,l_mod_name,2);

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          -- Debug messages
          Debug(' JOB_CREATION_UPDATE failed ',l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NVL(p_upd_job_completion,'Y') = 'Y' THEN
      -- Only if the update_job_completion is 'Y', then
      -- call the completion update api

      -- Debug messages
      Debug('Calling  JOB_COMPLETION_UPDATE',l_mod_name,2);

      JOB_COMPLETION_UPDATE
        ( p_api_version          =>  p_api_version,
          p_commit               =>  p_commit,
          p_init_msg_list        =>  p_init_msg_list,
          p_validation_level     =>  p_validation_level,
          x_return_status        =>  x_return_status,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data ,
          p_repair_line_id       =>  p_repair_line_id);

      -- Debug messages
      Debug('Return Status from  JOB_COMPLETION_UPDATE :'||x_return_status,l_mod_name,2);

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          -- Debug messages
          Debug(' JOB_COMPLETION_UPDATE failed ',l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get
            (p_count  =>  x_msg_count,
             p_data   =>  x_msg_data);
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              Debug('In FND_API.G_EXC_ERROR  Exception',l_mod_name,4);
              -- As we commit the processed records in the inner APIs
		    -- so we rollback only if the p_commit = 'F'
		    IF NOT(FND_API.To_Boolean( p_commit )) THEN
                  ROLLBACK TO WIP_UPDATE;
		    END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
                    (p_count  =>  x_msg_count,
                     p_data   =>  x_msg_data  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              Debug('In FND_API.G_EXC_UNEXPECTED_ERROR Exception',l_mod_name,4);
              IF ( l_error_level >= G_debug_level)  THEN
                 fnd_message.set_name('CSD','CSD_SQL_ERROR');
                 fnd_message.set_token('SQLERRM',SQLERRM);
                 fnd_message.set_token('SQLCODE',SQLCODE);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
              END If;
              -- As we commit the processed records in the inner APIs
		    -- so we rollback only if the p_commit = 'F'
              IF NOT(FND_API.To_Boolean( p_commit )) THEN
                  ROLLBACK TO WIP_UPDATE;
		    END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              Debug('In OTHERS Exception',l_mod_name,4);
              IF ( l_error_level >= G_debug_level)  THEN
                 fnd_message.set_name('CSD','CSD_SQL_ERROR');
                 fnd_message.set_token('SQLERRM',SQLERRM);
                 fnd_message.set_token('SQLCODE',SQLCODE);
                 FND_LOG.MESSAGE(l_error_level,l_mod_name,FALSE);
              END If;
              -- As we commit the processed records in the inner APIs
		    -- so we rollback only if the p_commit = 'F'
              IF NOT(FND_API.To_Boolean( p_commit )) THEN
                  ROLLBACK TO WIP_UPDATE;
		    END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                  FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
              END IF;
              FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );
End WIP_UPDATE;

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

Procedure  RECEIPTS_UPDATE_CONC_PROG
           (errbuf              OUT NOCOPY    varchar2,
            retcode             OUT NOCOPY    varchar2,
            p_order_type        IN            varchar2,
            p_order_header_id   IN            number,
            p_repair_line_id    IN            number,
            p_past_num_of_days  IN            NUMBER  DEFAULT NULL)  ----bug#6753684, 6742512
IS

  --Standard Variables
  l_api_name          CONSTANT VARCHAR2(30)   := 'RECEIPTS_UPDATE_CONC_PROG';
  l_api_version       CONSTANT NUMBER         := 1.0;

  -- Variable used in the API
  l_internal_order_flag  VARCHAR2(1);

  -- Concurrent Program return status
  l_success_status    CONSTANT VARCHAR2(1) := '0';
  l_warning_status    CONSTANT VARCHAR2(1) := '1';
  l_error_status      CONSTANT VARCHAR2(1) := '2';

  -- Variables used in the program
  l_return_status     VARCHAR2(30);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(30000);  --bug#8261344

  -- Variables for FND Log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.receipts_update_conc_prog';

BEGIN
      -- Initialize API return status to success
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Initialize the error code and error buffer
      retcode := l_success_status;
      errbuf  := '';

      -- Debug messages
      Debug('At the Beginning of receipts_update_conc_prog',l_mod_name,1);

      IF NVL(p_order_type,'E') = 'I' THEN
           l_internal_order_flag := 'Y';
      Else
           l_internal_order_flag := 'N';
      End if;

      -- Debug messages
      Debug('Calling RECEIPTS_UPDATE',l_mod_name,2);

      -- Api body starts
      RECEIPTS_UPDATE
        ( p_api_version          =>  l_api_version,
          p_commit               =>  FND_API.G_TRUE,
          p_init_msg_list        =>  FND_API.G_TRUE,
          p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
          x_return_status        =>  l_return_status,
          x_msg_count            =>  l_msg_count,
          x_msg_data             =>  l_msg_data,
          p_internal_order_flag  =>  l_internal_order_flag,
          p_order_header_id      =>  p_order_header_id,
          p_repair_line_id       =>  p_repair_line_id,
          p_past_num_of_days     =>  p_past_num_of_days);

      -- Debug messages
      Debug('Return Status from RECEIPTS_UPDATE :'||l_return_status,l_mod_name,2);

	   --bug#8261344
	  If (l_return_status = G_CSD_RET_STS_WARNING and p_repair_line_id is null) THEN
		   retcode := l_warning_status;
		   errbuf  := l_msg_data;
      ElSIF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          -- Concatenate the message from the message stack
          IF l_msg_count > 1 then
            FOR i IN 1..l_msg_count LOOP
                l_msg_data := l_msg_data||FND_MSG_PUB.Get(i,FND_API.G_FALSE) ;
            END LOOP ;
          END IF ;
          Debug(l_msg_data,l_mod_name,4);
          RAISE FND_API.G_EXC_ERROR;
      END IF;

Exception
   WHEN FND_API.G_EXC_ERROR THEN
       retcode := l_error_status;
       errbuf  := l_msg_data;
   WHEN Others then
       -- Handle others exception
       retcode := l_error_status;
       errbuf  := l_msg_data;
END RECEIPTS_UPDATE_CONC_PROG;

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

Procedure  WIP_UPDATE_CONC_PROG
           (errbuf             OUT NOCOPY    varchar2,
            retcode            OUT NOCOPY    varchar2,
            p_repair_line_id   IN            number,
            p_upd_job_completion IN          varchar2) IS

  -- Standard variables
  l_api_name          CONSTANT VARCHAR2(30)   := 'WIP_UPDATE_CONC_PROG';
  l_api_version       CONSTANT NUMBER         := 1.0;

  -- Variables used in the program
  l_return_status     VARCHAR2(30);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(20000);

  -- Concurrent Program return status
  l_success_status    CONSTANT VARCHAR2(1) := '0';
  l_warning_status    CONSTANT VARCHAR2(1) := '1';
  l_error_status      CONSTANT VARCHAR2(1) := '2';

  -- Variables for FND log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.wip_update_conc_prog';

BEGIN
      -- Initialize API return status to success
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Initialize the error buffer and error code
      retcode := l_success_status;
      errbuf  := '';

      -- Debug Statement
      Debug('At the Beginning of wip_update_conc_prog',l_mod_name,1);
      Debug('p_repair_line_id ='||p_repair_line_id,l_mod_name,1);

      -- Api body starts
      -- Debug statement
      Debug('Calling WIP_UPDATE',l_mod_name,2);

      -- Call wip update api. If repair line Id is passed,
      -- then send the repair line Id. Else it will take all the
      -- unprocessed repair orders
      WIP_UPDATE
        ( p_api_version          =>  l_api_version,
          p_commit               =>  FND_API.G_TRUE,
          p_init_msg_list        =>  FND_API.G_TRUE,
          p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
          x_return_status        =>  l_return_status,
          x_msg_count            =>  l_msg_count,
          x_msg_data             =>  l_msg_data,
          p_upd_job_completion   =>  p_upd_job_completion,
          p_repair_line_id       =>  p_repair_line_id);

     -- Debug statement
     Debug('Return Status from WIP_UPDATE :'||l_return_status,l_mod_name,2);

     -- Raise error message if the API returns status <> 'S'
     IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         IF l_msg_count > 1 then
            FOR i IN 1..l_msg_count LOOP
               l_msg_data := l_msg_data||FND_MSG_PUB.Get(i,FND_API.G_FALSE) ;
            END LOOP ;
         END IF ;
         Debug(l_msg_data,l_mod_name,4);
         RAISE FND_API.G_EXC_ERROR;
     END IF;

Exception
   WHEN FND_API.G_EXC_ERROR THEN
       retcode := l_error_status;
       errbuf  := l_msg_data;
   WHEN Others then
       -- Handle others exception
       retcode := l_error_status;
       errbuf  := l_msg_data;
END WIP_UPDATE_CONC_PROG;

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

PROCEDURE SHIP_UPDATE_CONC_PROG
         (errbuf            OUT NOCOPY  VARCHAR2,
          retcode           OUT NOCOPY  VARCHAR2,
          p_order_type      IN          VARCHAR2,
          p_order_header_id IN          NUMBER,
          p_repair_line_id  IN          NUMBER,
          p_past_num_of_days  IN        NUMBER DEFAULT NULL)   ----bug#6753684, 6742512
IS

  -- Standard Variables
  l_api_version  CONSTANT NUMBER := 1.0;
  l_return_status varchar2(1);
  l_msg_count     number;
  l_msg_data      varchar2(30000);  --bug#8261344


  -- Variables used in API
  l_internal_order_flag  varchar2(1);

    -- Concurrent Program return status
  l_success_status    CONSTANT VARCHAR2(1) := '0';
  l_warning_status    CONSTANT VARCHAR2(1) := '1';
  l_error_status      CONSTANT VARCHAR2(1) := '2';

  -- Variables for the FND Log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.ship_update_conc_prog';

Begin
      -- Initialize API return status to success
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Initialize the error message and error buffer
      retcode := l_success_status;
      errbuf  := '';

      -- Debug message
      Debug('Beginning of ship_update_conc_prog ',l_mod_name,1);

      -- Api body starts
      IF NVL(p_order_type,'E') = 'I' THEN
          l_internal_order_flag := 'Y';
      Else
          l_internal_order_flag := 'N';
      End if;

      -- Debug message
      Debug('Calling SHIP_UPDATE ',l_mod_name,2);

      SHIP_UPDATE
        ( p_api_version          =>  l_api_version,
          p_commit               =>  FND_API.G_TRUE,
          p_init_msg_list        =>  FND_API.G_TRUE,
          p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
          x_return_status        =>  l_return_status,
          x_msg_count            =>  l_msg_count,
          x_msg_data             =>  l_msg_data,
          p_internal_order_flag  =>  l_internal_order_flag,
          p_order_header_id      =>  p_order_header_id,
          p_repair_line_id       =>  p_repair_line_id,
          p_past_num_of_days     =>  p_past_num_of_days);

      -- Debug message
      Debug('Return Status from SHIP_UPDATE :'||l_return_status,l_mod_name,2);

	     --bug#8261344
	  If (l_return_status = G_CSD_RET_STS_WARNING and p_repair_line_id is null) THEN
		     retcode := l_warning_status;
		     errbuf  := l_msg_data;
      ELSIF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         -- Concatenate the message from the message stack
         IF l_msg_count > 1 then
            FOR i IN 1..l_msg_count LOOP
               l_msg_data := l_msg_data||FND_MSG_PUB.Get(i,FND_API.G_FALSE) ;
            END LOOP ;
         END IF ;
         Debug(l_msg_data,l_mod_name,4);
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
Exception
   WHEN FND_API.G_EXC_ERROR THEN
       retcode := l_error_status;
       errbuf  := l_msg_data;
   WHEN Others then
       -- Handle others exception
       retcode := l_error_status;
       errbuf  := l_msg_data;
End SHIP_UPDATE_CONC_PROG;


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
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

PROCEDURE  TASK_UPDATE_CONC_PROG
      ( errbuf                  OUT NOCOPY    varchar2,
        retcode                 OUT NOCOPY    varchar2,
        p_repair_line_id        IN            number ) is

       CURSOR  c_updated_tasks( p_repair_line_id in number ) is
       select  tsk.task_id
               ,rep.repair_line_id
               --,max(hist.repair_history_id) repair_history_id
         from  csd_repair_tasks_v tsk
              ,csd_repair_history hist
              ,csd_repairs rep
        where  rep.repair_line_id = tsk.source_object_id
          and tsk.source_object_id = hist.repair_line_id
         and tsk.task_id = hist.paramn1
          and ( tsk.task_status_id <> hist.paramn5 or tsk.owner_id <> hist.paramn3)
        and  rep.repair_line_id = nvl(p_repair_line_id, rep.repair_line_id)  -- travi 181201 change
       group by tsk.task_id, rep.repair_line_id;

       CURSOR  c_tasks_to_updt(l_task_id number, l_repair_line_id in number, l_rep_hist_id in number) is
       Select  tsk.task_id,            -- hist.paramn1
               tsk.last_updated_by,    -- hist.paramn2
               tsk.owner_id,           -- hist.paramn3
               tsk.assigned_by_id,        -- hist.paramn4
               tsk.task_status_id,     -- hist.paramn5
               tsk.task_number,        -- hist.paramc1
               tsk.owner_type,         -- hist.paramc2
               tsk.owner,              -- hist.paramc3
               null assignee_type,      -- hist.paramc4
               null assignee_name,      -- hist.paramc5
               tsk.task_status,        -- hist.paramc6
               tsk.planned_start_date, -- hist.paramd1
               tsk.actual_start_date,  -- hist.paramd2
               tsk.actual_end_date,    -- hist.paramd3
               tsk.last_update_date,   -- hist.paramd4
               hist.paramc3,           -- tsk.owner
               hist.paramc6            -- tsk.task_status
         from  CSD_REPAIR_TASKS_V tsk
              ,csd_repair_history hist
        where  tsk.source_object_type_code = 'DR'
          and  tsk.task_id                 = l_task_id
          and  tsk.source_object_id        = l_repair_line_id
          and  hist.repair_history_id      = l_rep_hist_id
          and  hist.paramn1                = tsk.task_id
          and  hist.repair_line_id         = tsk.source_object_id
          and  (tsk.task_status_id <> hist.paramn5 or tsk.owner_id <> hist.paramn3);

      -- Standard Variables
      l_api_name               CONSTANT VARCHAR2(30)   := 'VALIDATE_AND_WRITE';
      l_api_version            CONSTANT NUMBER         := 1.0;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(2000);
      l_msg_index              NUMBER;
      x_return_status          VARCHAR2(1);
      x_msg_count              NUMBER;
      x_msg_data               VARCHAR2(2000);

      -- Variables used in program
      l_return_status          VARCHAR2(1);
      l_repair_history_id      NUMBER;
      v_total_records          number;
      l_event_code             VARCHAR2(30) := '';
      l_task_id                number;
      l_repair_line_id         number;
      l_rep_hist_id            number;
      l_paramn1                NUMBER;
      l_paramn2                NUMBER;
      l_paramn3                NUMBER;
      l_paramn4                NUMBER;
      l_paramn5                NUMBER;
      l_paramc1                VARCHAR2(240);
      l_paramc2                VARCHAR2(240);
      l_paramc3                VARCHAR2(240);
      l_paramc4                VARCHAR2(240);
      l_paramc5                VARCHAR2(240);
      l_paramc6                VARCHAR2(240);
      l_paramd1                DATE;
      l_paramd2                DATE;
      l_paramd3                DATE;
      l_paramd4                DATE;
      l_owner                  VARCHAR2(240);
      l_task_status            VARCHAR2(240);

      -- Variables for FND Log
      l_error_level  number   := FND_LOG.LEVEL_ERROR;
      l_mod_name     varchar2(2000) := 'csd.plsql.csd_update_programs_pvt.task_update_conc_prog';

 BEGIN

 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Initialize the error message and error buffer
 retcode := '0';
 errbuf  := '';

 v_total_records := 0;

 -- travi added p_repair_line_id
 FOR R in c_updated_tasks( p_repair_line_id )
 loop

    l_event_code := '';
    l_task_id        := '';
    l_repair_line_id := '';
    l_rep_hist_id    := '';
    l_paramn1        := ''; -- task id
    l_paramn2        := ''; -- last updated by
    l_paramn3        := ''; -- owner id
    l_paramn4        := ''; -- assigned by id
    l_paramn5        := ''; -- status id
    l_paramc1        := ''; -- task number
    l_paramc2        := ''; -- owner type
    l_paramc3        := ''; -- owner name
    l_paramc4        := ''; -- null assignee type
    l_paramc5        := ''; -- null assignee name
    l_paramc6        := ''; -- status
    l_paramd1        := ''; -- planned start date
    l_paramd2        := ''; -- actual start date
    l_paramd3        := ''; -- actual end date
    l_paramd4        := ''; -- last updated date
    l_owner          := ''; -- tsk.owner
    l_task_status    := ''; -- tsk.task_status

     select max(hist2.repair_history_id)
     into l_rep_hist_id
     from CSD_REPAIR_HISTORY hist2
     where hist2.repair_line_id = R.repair_line_id
     and hist2.paramn1          = R.task_id;

     l_task_id        := R.task_id;
     l_repair_line_id := R.repair_line_id;

     IF (l_rep_hist_id is not null) then

         OPEN c_tasks_to_updt(l_task_id, l_repair_line_id, l_rep_hist_id);
         FETCH c_tasks_to_updt
          INTO l_paramn1, -- task id
               l_paramn2, -- last updated by
               l_paramn3, -- owner id
               l_paramn4, -- assigned by id
               l_paramn5, -- status id
               l_paramc1, -- task number
               l_paramc2, -- owner type
               l_paramc3, -- owner name
               l_paramc4, -- null assignee type
               l_paramc5, -- null assignee name
               l_paramc6, -- status
               l_paramd1, -- planned start date
               l_paramd2, -- actual start date
               l_paramd3, -- actual end date
               l_paramd4, -- last updated date
               l_owner,   -- tsk.owner
               l_task_status;  -- -- tsk.task_status

         CLOSE c_tasks_to_updt;

         if (l_task_status <> l_paramc6) then
             l_event_code := 'TSC';
         elsif (l_owner <> l_paramc3) then
             l_event_code := 'TOC';
         end if;

      -- ---------------------------------------------------------
      -- Repair history row inserted for TOC or TSC only
      -- ---------------------------------------------------------
      IF (l_event_code in ('TOC', 'TSC')) then

      -- --------------------------------
      -- Begin Update repair task history
      -- --------------------------------
      -- Standard Start of API savepoint
         SAVEPOINT  Update_rep_task_hist;

      -- ---------------
      -- Api body starts
      -- ---------------
         Debug('Calling Validate_And_Write ',l_mod_name,2);

         CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write
          (p_Api_Version_Number       => l_api_version ,
           p_init_msg_list            => FND_API.G_FALSE,
           p_commit                   => FND_API.G_FALSE,
           p_validation_level         => NULL,
           p_action_code              => 0,
           px_REPAIR_HISTORY_ID       => l_repair_history_id,
           p_OBJECT_VERSION_NUMBER    => null,                     -- travi ovn validation
           p_REQUEST_ID               => null,
           p_PROGRAM_ID               => null,
           p_PROGRAM_APPLICATION_ID   => null,
           p_PROGRAM_UPDATE_DATE      => null,
           p_CREATED_BY               => FND_GLOBAL.USER_ID,
           p_CREATION_DATE            => sysdate,
           p_LAST_UPDATED_BY          => FND_GLOBAL.USER_ID,
           p_LAST_UPDATE_DATE         => sysdate,
           p_repair_line_id           => l_repair_line_id,
           p_EVENT_CODE               => l_event_code,
           p_EVENT_DATE               => sysdate,
           p_QUANTITY                 => null,
           p_PARAMN1                  => l_paramn1,
           p_PARAMN2                  => l_paramn2,
           p_PARAMN3                  => l_paramn3,
           p_PARAMN4                  => l_paramn4,
           p_PARAMN5                  => l_paramn5,
           p_PARAMN6                  => null,
           p_PARAMN7                  => null,
           p_PARAMN8                  => null,
           p_PARAMN9                  => null,
           p_PARAMN10                 => FND_GLOBAL.USER_ID,
           p_PARAMC1                  => l_paramc1,
           p_PARAMC2                  => l_paramc2,
           p_PARAMC3                  => l_paramc3,
           p_PARAMC4                  => l_paramc4,
           p_PARAMC5                  => l_paramc5,
           p_PARAMC6                  => l_paramc6,
           p_PARAMC7                  => null,
           p_PARAMC8                  => null,
           p_PARAMC9                  => null,
           p_PARAMC10                 => null,
           p_PARAMD1                  => l_paramd1,
           p_PARAMD2                  => l_paramd1,
           p_PARAMD3                  => l_paramd1,
           p_PARAMD4                  => l_paramd1,
           p_PARAMD5                  => null,
           p_PARAMD6                  => null,
           p_PARAMD7                  => null,
           p_PARAMD8                  => null,
           p_PARAMD9                  => null,
           p_PARAMD10                 => null,
           p_ATTRIBUTE_CATEGORY       => null,
           p_ATTRIBUTE1               => null,
           p_ATTRIBUTE2               => null,
           p_ATTRIBUTE3               => null,
           p_ATTRIBUTE4               => null,
           p_ATTRIBUTE5               => null,
           p_ATTRIBUTE6               => null,
           p_ATTRIBUTE7               => null,
           p_ATTRIBUTE8               => null,
           p_ATTRIBUTE9               => null,
           p_ATTRIBUTE10              => null,
           p_ATTRIBUTE11              => null,
           p_ATTRIBUTE12              => null,
           p_ATTRIBUTE13              => null,
           p_ATTRIBUTE14              => null,
           p_ATTRIBUTE15              => null,
           p_LAST_UPDATE_LOGIN        => FND_GLOBAL.CONC_LOGIN_ID,
           X_Return_Status            => x_return_status,
           X_Msg_Count                => x_msg_count,
           X_Msg_Data                 => x_msg_data
          );

        Debug('Return Status from Validate_And_Write :'||x_return_status,l_mod_name,2);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            -- Debug messages
            Debug(' JOB_COMPLETION_UPDATE failed ',l_mod_name,4);
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- -------------------
        -- Api body ends here
        -- -------------------
        v_total_records := v_total_records + 1;
     end if; -- End of TOC/TSC check

    end if; -- End of check for l_rep_hist_id
  end loop;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( FND_API.G_FALSE ) THEN
       COMMIT WORK;
  END IF;

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get
         (p_count  =>  x_msg_count,
          p_data   =>  x_msg_data );

 EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_rep_task_hist;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Update_rep_task_hist;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data  );
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Update_rep_task_hist;
              IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                  FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
              END IF;
                  FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

 END TASK_UPDATE_CONC_PROG;


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
 PROCEDURE  PROD_TXN_STATUS_UPD(p_repair_line_id   in  number,
                                p_commit           in varchar2)

 is


 CURSOR c_product_transaction_id(p_repair_line_id    IN number) is
     SELECT c.product_transaction_id, a.booked_flag
     FROM oe_order_lines_all a,
          cs_estimate_details b,
          csd_product_transactions c
     WHERE a.line_id = b.order_line_id
     AND b.estimate_detail_id = c.estimate_detail_id
     and c.prod_txn_status = 'SUBMITTED'
     and a.booked_flag = 'Y'
     and c.book_sales_order_flag = 'N'
     and b.order_header_id in
     (
 	 select p.order_header_id
 	 from   cs_estimate_details p, csd_product_transactions q
 	 where  p.estimate_detail_id=q.estimate_detail_id
 	 and    q.repair_line_id=p_repair_line_id
      );

 begin

     FOR C in c_product_transaction_id(p_repair_line_id)
     Loop
         IF C.booked_flag = 'Y' THEN
             UPDATE csd_product_transactions
             SET prod_txn_status = 'BOOKED', book_sales_order_flag = 'Y'
             WHERE product_transaction_id = C.product_transaction_id;
         END IF;
     end loop;

     IF c_product_transaction_id%isopen then
       CLOSE c_product_transaction_id;
     END IF;

     if(p_commit = FND_API.G_TRUE) THEN
        commit;
     END IF;
 End;


 /*-------------------------------------------------------------------------------------*/
 /* Procedure name: check_for_cancelled_order                                       */
 /* Description  :  Procedure called to update all the logistics lines status to        */
 /*                 cancelled if the corresponding order line is cancelled.             */
 /*                                                                                     */
 /*                                                                                     */
 /* Called from   : RMA_RCV_UPDATE, IO_RCV_UPDATE , SHIP_UPDATE, IO_SHIP_UPDATE         */
 /* STANDARD PARAMETERS                                                                 */
 /*  In Parameters :                                                                    */
 /*                                                                                     */
 /*  Output Parameters:                                                                 */
 /*                                                                                     */
 /* NON-STANDARD PARAMETERS                                                             */
 /*   In Parameters                                                                     */
 /*    p_repair_line_id   NUMBER                                                        */
 /* Output Parm :                                                                       */
 /* Change Hist :                                                                       */
 /*   30/June/2005  vparvath  Initial Creation.                                        */
 /*-------------------------------------------------------------------------------------*/
 PROCEDURE check_for_cancelled_order(p_repair_line_id NUMBER) IS

  CURSOR CANCELLED_ORDER_LINES(p_repair_line_id NUMBER) IS
  SELECT DISTINCT cpt.product_transaction_id PRODUCT_TXN_ID
  FROM oe_order_headers_all oeh,
      oe_order_lines_all oel,
      cs_estimate_details ced,
      csd_product_transactions cpt
  WHERE cpt.repair_line_id = p_repair_line_id
       AND   cpt.action_type    in ('RMA', 'SHIP', 'RMA_THIRD_PTY', 'SHIP_THIRD_PTY')
       AND   cpt.prod_txn_status    in (  'BOOKED', 'SUBMITTED')
       AND   ced.order_header_id is not null
       AND   ced.source_code        = 'DR'
       AND   ced.estimate_detail_id = cpt.estimate_detail_id
       AND   oeh.header_id          = ced.order_header_id
       AND   oel.header_id          = oeh.header_id
       and   ced.order_line_id       = oel.line_id
       /*fixed for bug#5846050 only cancelled line should be updated not all the lines */
       --AND   oel.cancelled_flag     = 'Y'
       AND   oel.ordered_quantity     = 0 -- indicates the order line is cancelled.
	  ; -- skip partial ship/receive case, current behavour is
	  -- if the original line is cancelled the product transaction
	  -- will show as cancelled.
	  /***
       AND  ((ced.QUANTITY_REQUIRED < -1
	           AND oel.line_id in ( Select line_id
                              from oe_order_lines_all oel1
             	               start with oel1.line_id = ced.order_line_id
     		                 connect by prior oel1.line_id = oel1.split_from_line_id
     		                 and oel1.shipped_quantity is not null
     		                 and oel1.header_id = oeh.header_id))
			OR (ced.QUANTITY_REQUIRED = -1
			    AND ced.ORDER_LINE_ID = oel.LINE_ID));
	 **********/

  l_product_txn_id NUMBER;
  C_PRODTXN_CANCELLED VARCHAR2(30) := 'CANCELLED';

 BEGIN

    FOR ORD_LINES IN CANCELLED_ORDER_LINES( p_repair_line_id) LOOP
      l_product_txn_id := ORD_LINES.PRODUCT_TXN_ID;
      BEGIN
        UPDATE CSD_PRODUCT_TRANSACTIONS
        SET PROD_TXN_STATUS = C_PRODTXN_CANCELLED,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
            LAST_UPDATED_BY   = FND_GLOBAL.USER_ID
        WHERE PRODUCT_TRANSACTION_ID = l_product_txn_id;
      EXCEPTION
          WHEN OTHERS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
    END LOOP;

 END check_for_cancelled_order;


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
             resultout in out nocopy varchar2) IS

l_line_id               number;
l_orig_source_code      varchar2(10);
l_orig_source_id        number;
l_line_category_code    varchar2(30);
l_order_header_id       number;
l_return_status         varchar2(3);
l_msg_count             number;
l_msg_data              varchar2(2000);
l_msg_index_out         number;
l_module_name           varchar2(30);


Cursor get_est_line_details ( p_line_id in number ) is
select
  est.original_source_code,
  est.original_source_id,
  est.line_category_code,
  est.order_header_id
from
  cs_estimate_details est
where
est.order_line_id = p_line_id;

BEGIN

  IF ( funcmode = 'RUN' ) THEN

    l_line_id := to_number(itemkey);

    --
    -- Derive the wf roles for the Contact id
    --
    Open get_est_line_details (l_line_id);
    Fetch get_est_line_details into l_orig_source_code,
      l_orig_source_id,l_line_category_code,l_order_header_id;
    Close get_est_line_details;

    IF ( l_orig_source_code = 'DR' ) THEN

      IF ( l_line_category_code = 'RETURN') THEN

        l_module_name := 'LOGISTICS_RECEIPTS_UPDATE';

        CSD_UPDATE_PROGRAMS_PVT.RECEIPTS_UPDATE
          ( p_api_version          => 1.0,
            p_commit               => 'T',
            p_init_msg_list        => 'T',
            p_validation_level     => CSD_PROCESS_UTIL.G_VALID_LEVEL_FULL,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_internal_order_flag  => 'N',
            p_order_header_id      => null,
            p_repair_line_id       => l_orig_source_id);

        IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          resultout := 'COMPLETE:ERROR';
        ELSE
          resultout := 'COMPLETE:SUCCESS';
        END IF;

      ELSIF ( l_line_category_code = 'ORDER') THEN

        l_module_name := 'LOGISTICS_SHIP_UPDATE';

        CSD_UPDATE_PROGRAMS_PVT.SHIP_UPDATE
          ( p_api_version          => 1.0,
            p_commit               => 'T',
            p_init_msg_list        => 'T',
            p_validation_level     => CSD_PROCESS_UTIL.G_VALID_LEVEL_FULL,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_internal_order_flag  => 'N' ,
            p_order_header_id      => null,
            p_repair_line_id       => l_orig_source_id);

        IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          resultout := 'COMPLETE:ERROR';
        ELSE
          resultout := 'COMPLETE:SUCCESS';
        END IF;

      END IF;

      -- If the return status is error then raise
      -- the Business Event
      IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        CSD_REPAIRS_PVT.LAUNCH_WFEXCEPTION_BEVENT(
                         p_return_status  => l_return_status,
                         p_msg_count      => l_msg_count,
                         p_msg_data       => l_msg_data,
                         p_repair_line_id => l_orig_source_id,
                         p_module_name    => l_module_name);

      END IF;

    END IF;

    return;

  END IF;



EXCEPTION
WHEN OTHERS THEN
  WF_CORE.CONTEXT('CSD_UPDATE_PROGRAMS_PVT','UPDATE_LOGISTICS_WF',itemtype,
                  itemkey,to_char(actid),funcmode);
  raise;
END;

END CSD_UPDATE_PROGRAMS_PVT;

/
