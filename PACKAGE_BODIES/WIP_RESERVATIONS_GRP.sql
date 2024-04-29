--------------------------------------------------------
--  DDL for Package Body WIP_RESERVATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RESERVATIONS_GRP" AS
/* $Header: wipsogpb.pls 120.5 2006/07/07 23:58:01 kboonyap noship $ */

PROCEDURE get_available_supply_demand (
 p_api_version_number                   IN      NUMBER default 1.0
, p_init_msg_lst                        IN      VARCHAR2
,x_return_status                        OUT     NOCOPY VARCHAR2
, x_msg_count                           OUT     NOCOPY NUMBER
, x_msg_data                            OUT     NOCOPY VARCHAR2
, x_available_quantity                  OUT     NOCOPY NUMBER
, x_source_primary_uom_code             OUT     NOCOPY VARCHAR2
, x_source_uom_code                     OUT     NOCOPY VARCHAR2
, p_organization_id                     IN      NUMBER default null
, p_item_id                             IN      NUMBER default null
, p_revision                            IN      VARCHAR2 default null
, p_lot_number                          IN      VARCHAR2 default null
, p_subinventory_code                   IN      VARCHAR2 default null
, p_locator_id                          IN      NUMBER default null
, p_supply_demand_code                  IN      NUMBER
, p_supply_demand_type_id               IN      NUMBER
, p_supply_demand_header_id             IN      NUMBER
, p_supply_demand_line_id               IN      NUMBER
, p_supply_demand_line_detail           IN      NUMBER default FND_API.G_MISS_NUM
, p_lpn_id                              IN      NUMBER default FND_API.G_MISS_NUM
, p_project_id                          IN      NUMBER default null
, p_task_id                             IN      NUMBER default null
, p_return_txn                          IN      NUMBER default 0
) IS
l_params       wip_logger.param_tbl_t;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
l_returnStatus VARCHAR2(1);
l_errMsg       VARCHAR2(240);
l_msgCount     NUMBER;
l_msgData      VARCHAR2(2000);
l_crossDock_qty NUMBER;
BEGIN

-- write parameter value to log file
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        l_params(1).paramName   := ' p_organization_id';
        l_params(1).paramValue  :=  p_organization_id;
        l_params(2).paramName   := 'p_item_id';
        l_params(2).paramValue  :=  p_item_id;
        l_params(3).paramName   := 'p_revision';
        l_params(3).paramValue  :=  p_revision;
        l_params(4).paramName   := 'p_lot_number';
        l_params(4).paramValue  :=  p_lot_number;
        l_params(5).paramName   := 'p_subinventory_code';
        l_params(5).paramValue  :=  p_subinventory_code;
        l_params(6).paramName   := 'p_locator_id';
        l_params(6).paramValue  :=  p_locator_id;
        l_params(7).paramName   := 'p_supply_demand_code';
        l_params(7).paramValue  :=  p_supply_demand_code;
        l_params(8).paramName   := 'p_supply_demand_type_id';
        l_params(8).paramValue  :=  p_supply_demand_type_id;
        l_params(9).paramName   := 'p_supply_demand_header_id';
        l_params(9).paramValue  :=  p_supply_demand_header_id;
        l_params(10).paramName   := 'p_return_txn';
        l_params(10).paramValue  :=  p_return_txn;

 wip_logger.entryPoint
       (p_procName => 'wip_reservations_grp.get_available_supply_demand',
        p_params   => l_params,
        x_returnStatus => l_returnStatus);
      END IF;

x_return_status := fnd_api.g_ret_sts_success;

/* If API is called with parameter p_supply_demand_code being demand */
 IF ( p_supply_demand_code = 1 ) THEN
  IF ( p_return_txn = 0) THEN -- If it is normal transaction
   SELECT
     (WDJ.START_QUANTITY - WDJ.QUANTITY_COMPLETED - WDJ.QUANTITY_SCRAPPED) ,
      MSIK.PRIMARY_UOM_CODE
   INTO
      x_available_quantity ,
      x_source_primary_uom_code
   FROM WIP_DISCRETE_JOBS WDJ ,
        MTL_SYSTEM_ITEMS_KFV MSIK
   WHERE  WDJ.WIP_ENTITY_ID = p_supply_demand_header_id
     AND WDJ.PRIMARY_ITEM_ID = MSIK.INVENTORY_ITEM_ID
     AND WDJ.ORGANIZATION_ID = MSIK.ORGANIZATION_ID ;
     x_source_uom_code := x_source_primary_uom_code ;

   SELECT NVL(SUM(mtrl.primary_quantity),0)
     INTO l_crossDock_qty
     FROM mtl_txn_request_lines mtrl,
          wms_license_plate_numbers wlpn
    WHERE mtrl.organization_id = p_organization_id
      AND mtrl.inventory_item_id = p_item_id
      AND NVL(mtrl.quantity_delivered, 0) = 0
      AND mtrl.txn_source_id = p_supply_demand_header_id
      AND mtrl.lpn_id = wlpn.lpn_id
      AND wlpn.lpn_context = 2 -- WIP
      AND mtrl.line_status <> inv_globals.g_to_status_closed;

      x_available_quantity :=  x_available_quantity + l_crossDock_qty ;
  ELSE -- If it is return Transaction
   SELECT
     (WDJ.START_QUANTITY - WDJ.QUANTITY_COMPLETED - WDJ.QUANTITY_SCRAPPED) +
     WDJ.QUANTITY_COMPLETED,
      MSIK.PRIMARY_UOM_CODE
   INTO
      x_available_quantity ,
      x_source_primary_uom_code
   FROM WIP_DISCRETE_JOBS WDJ ,
        MTL_SYSTEM_ITEMS_KFV MSIK
   WHERE  WDJ.WIP_ENTITY_ID = p_supply_demand_header_id
     AND WDJ.PRIMARY_ITEM_ID = MSIK.INVENTORY_ITEM_ID
     AND WDJ.ORGANIZATION_ID = MSIK.ORGANIZATION_ID ;
     x_source_uom_code := x_source_primary_uom_code ;

 END IF; -- End if for p_return_txn

 ELSE
   fnd_message.set_name('WIP', 'WIP_SUPPLY_SOURCE');
   fnd_msg_pub.ADD;
   x_return_status := fnd_api.g_ret_sts_error;
 END IF;
 IF (l_logLevel <= wip_constants.trace_logging) THEN
     wip_logger.exitPoint(p_procName => 'wip_reservations_grp.get_available_supply_demand',
                          p_procReturnStatus => x_return_status,
                          p_msg => 'Success',
                          x_returnStatus => l_returnStatus);
 END IF;
 EXCEPTION
  WHEN OTHERS THEN
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
  IF (l_logLevel <= wip_constants.trace_logging) THEN
     wip_logger.exitPoint(p_procName => 'wip_reservations_grp.get_available_supply_demand',
                          p_procReturnStatus => x_return_status,
                          p_msg => l_errMsg,
                          x_returnStatus => l_returnStatus);
   END IF;
   fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
   fnd_message.set_token('MESSAGE', l_errMsg);
   fnd_msg_pub.add;

END get_available_supply_demand ;

PROCEDURE validate_supply_demand (
x_return_status                         OUT     NOCOPY VARCHAR2
, x_msg_count                           OUT     NOCOPY NUMBER
, x_msg_data                            OUT     NOCOPY VARCHAR2
, x_valid_status                        OUT      NOCOPY VARCHAR2
, p_organization_id                     IN      NUMBER
, p_item_id                             IN      NUMBER
, p_supply_demand_code                  IN      NUMBER
, p_supply_demand_type_id               IN      NUMBER
, p_supply_demand_header_id             IN      NUMBER
, p_supply_demand_line_id               IN      NUMBER
, p_supply_demand_line_detail           IN      NUMBER default FND_API.G_MISS_NUM
, p_demand_ship_date                    IN      DATE
, p_expected_receipt_date               IN      DATE
, p_api_version_number                  IN      NUMBER default 1.0
,p_init_msg_lst                 IN VARCHAR2
) IS
l_params       wip_logger.param_tbl_t;
L_logLevel     NUMBER := fnd_log.g_current_runtime_level;
l_returnStatus VARCHAR2(1);
l_errMsg       VARCHAR2(240);
l_msgCount     NUMBER;
l_msgData      VARCHAR2(2000);
--l_available_qty  NUMBER ;
l_status_type    NUMBER ;
l_crossDock_qty  NUMBER;
BEGIN
-- write parameter value to log file
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        l_params(1).paramName   := ' p_organization_id';
        l_params(1).paramValue  :=  p_organization_id;
        l_params(2).paramName   := 'p_item_id';
        l_params(2).paramValue  :=  p_item_id;
        l_params(3).paramName   := 'p_supply_demand_code';
        l_params(3).paramValue  :=  p_supply_demand_code;
        l_params(4).paramName   := 'p_supply_demand_type_id';
        l_params(4).paramValue  :=  p_supply_demand_type_id;
        l_params(5).paramName   := 'p_supply_demand_header_id';
        l_params(5).paramValue  :=  p_supply_demand_header_id;

 wip_logger.entryPoint
       (p_procName => 'wip_reservations_grp.validate_supply_demand',
        p_params   => l_params,
        x_returnStatus => l_returnStatus);
      END IF;

x_return_status := fnd_api.g_ret_sts_success;

/* If API is called  with  parameter p_supply_demand_code  being demand */

 IF ( p_supply_demand_code = 1 ) then
    /* Fixed bug 5371701. Got confirmation from Vishy that we do not have to
      check quantity as part of this API because quantity will be checked in
      get_available_supply_demand() procedure anyway. This API should check
      only that the job has a valid status to be reserved against sales order.
      The logic below does not work for return transaction because
      quantity_completed will be updated after a call to this API. This mean
      availableQty will always be zero if user already complete the whole
      quantity.
    */
   SELECT
 --     (WDJ.START_QUANTITY -WDJ.QUANTITY_COMPLETED - WDJ.QUANTITY_SCRAPPED) ,
        WDJ.STATUS_TYPE
   INTO
 --      l_available_qty,
       l_status_type
   FROM WIP_DISCRETE_JOBS WDJ
   WHERE
        WDJ.WIP_ENTITY_ID = p_supply_demand_header_id ;

   SELECT NVL(SUM(mtrl.primary_quantity),0)
     INTO l_crossDock_qty
     FROM mtl_txn_request_lines mtrl,
          wms_license_plate_numbers wlpn
    WHERE mtrl.organization_id = p_organization_id
      AND mtrl.inventory_item_id = p_item_id
      AND NVL(mtrl.quantity_delivered, 0) = 0
      AND mtrl.txn_source_id = p_supply_demand_header_id
      AND mtrl.lpn_id = wlpn.lpn_id
      AND wlpn.lpn_context = 2 -- WIP
      AND mtrl.line_status <> inv_globals.g_to_status_closed;
  /*
   l_available_qty := l_available_qty + l_crossDock_qty ;

   IF  l_available_qty <=0 then
      x_valid_status := 'N' ;
   END IF;
   */
   IF ( (l_status_type NOT IN
                (WIP_CONSTANTS.UNRELEASED,
                 WIP_CONSTANTS.RELEASED,
                 WIP_CONSTANTS.HOLD,
                 WIP_CONSTANTS.COMP_CHRG)) OR
        ((l_status_type = WIP_CONSTANTS.COMP_CHRG) AND
         (NVL(l_crossDock_qty,0) <= 0 ) ) )
    THEN
      x_valid_status := 'N' ;
   END IF;
 ELSE
   /* If API is called with parameter p_supply_demand_code being Supply
        Error Out with appropriate error message */
     fnd_message.set_name('WIP', 'WIP_SUPPLY_SOURCE');
     fnd_msg_pub.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
 END IF ; -- p_supply_demand_code if condition

 -- Fixed bug 5371701. x_valid_status was not set and there is no call to
 -- wip_logger.exitPoint().
 x_valid_status := 'Y';
 IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.log(p_msg          => 'x_valid_status = ' || x_valid_status,
                   x_returnStatus => l_returnStatus);
    wip_logger.exitPoint(p_procName => 'wip_reservations_grp.validate_supply_demand',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'Success',
                         x_returnStatus => l_returnStatus);
 END IF;
/* Need to handle exceptions and return unexpected error to the return status */
 EXCEPTION
  WHEN OTHERS THEN
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
  IF (l_logLevel <= wip_constants.trace_logging) THEN
     wip_logger.exitPoint(p_procName => 'wip_reservations_grp.validate_supply_demand',
                          p_procReturnStatus => x_return_status,
                          p_msg => l_errMsg,
                          x_returnStatus => l_returnStatus);
   END IF;
   fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
   fnd_message.set_token('MESSAGE', l_errMsg);
   fnd_msg_pub.add;
END validate_supply_demand ;

END  wip_reservations_grp;

/
