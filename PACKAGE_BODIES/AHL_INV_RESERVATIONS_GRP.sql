--------------------------------------------------------
--  DDL for Package Body AHL_INV_RESERVATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_INV_RESERVATIONS_GRP" AS
/* $Header: AHLGRSVB.pls 120.9 2005/12/08 02:33 anraj noship $ */

------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;


-- The purpose of this API is to get the final availability of the document line for which the reservation is being
--	created/ modified.This procedure will be called by the inventory APIs to get the expected availability at the
-- document level. The reason being that the actual ordered/receipt quantity on the document may not reflect the
-- expected quantity that is pending. Reservation API needs to know the final availability so that the ATR (available
-- to reserve) can be calculated.
PROCEDURE get_available_supply_demand (
			  p_api_version_number     		IN     	NUMBER
			, p_init_msg_lst             		IN	      VARCHAR2
			, x_return_status            		OUT    	NOCOPY VARCHAR2
  			, x_msg_count                		OUT    	NOCOPY NUMBER
			, x_msg_data                 		OUT    	NOCOPY VARCHAR2
			, p_organization_id					IN 		NUMBER
			, p_item_id								IN 		NUMBER
			, p_revision							IN 		VARCHAR2
			, p_lot_number							IN			VARCHAR2
			, p_subinventory_code				IN			VARCHAR2
			, p_locator_id							IN 		NUMBER
			, p_supply_demand_code				IN			NUMBER
			, p_supply_demand_type_id			IN			NUMBER
			, p_supply_demand_header_id		IN			NUMBER
			, p_supply_demand_line_id			IN			NUMBER
			, p_supply_demand_line_detail		IN			NUMBER
			, p_lpn_id								IN			NUMBER
			, p_project_id							IN			NUMBER
			, p_task_id								IN			NUMBER
			, x_available_quantity				OUT      NOCOPY NUMBER
			, x_source_uom_code					OUT		NOCOPY VARCHAR2
			,  x_source_primary_uom_code		OUT		NOCOPY VARCHAR2
)
IS
   -- Variables for logging
   l_log_current_level          NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_log_procedure         NUMBER      := FND_LOG.LEVEL_PROCEDURE;
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'get_available_supply_demand';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_init_msg_list               VARCHAR2(1)       := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   -- CURSOR to get the requested quanity and the compelted quantity
   CURSOR get_mtl_dtls_cur (c_scheduled_material_id IN NUMBER)
   IS
	   SELECT   requested_quantity,
	            NVL(completed_quantity, 0) completed_quantity
	   FROM     ahl_schedule_materials
	   WHERE    scheduled_material_id = c_scheduled_material_id;

   -- cursor to get the reserved quantity from the WMS tables
   CURSOR get_rsvd_qty_csr(c_scheduled_material_id IN NUMBER)
   IS
      SELECT   SUM(primary_reservation_quantity) reserved_quantity
      FROM     mtl_reservations mrsv,ahl_schedule_materials asmt
      WHERE    mrsv.demand_source_line_detail = c_scheduled_material_id
      AND      mrsv.external_source_code = 'AHL'
      AND      mrsv.demand_source_line_detail = asmt.scheduled_material_id
      AND      mrsv.organization_id = asmt.organization_id
      AND      mrsv.requirement_date = asmt.requested_date
      AND      mrsv.inventory_item_id = asmt.inventory_item_id
      GROUP BY mrsv.demand_source_line_detail;

   -- local variables to be used
   l_reserved_quantity   NUMBER := null;
   l_requested_quantity  NUMBER := null;
   l_completed_quantity  NUMBER := null;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT GET_AVAILABLE_SUPP_DMND_GRP;

   -- Initialize return status to success before any code logic/validation
   x_return_status   := FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version_number, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_lst)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;

   -- Validate the Supply Demand Code
   -- 1 is 'SUPPLY' and 2 is 'DEMAND' as per WMS TDD
   IF p_supply_demand_code <> 2 THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_AGAINST_DMND_ONLY' );
      -- The reservations should be against demand, not supply.
      FND_MSG_PUB.add;
      -- log the error
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            fnd_log.level_statement,
           'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'The reservations should be against demand, not supply.'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Validate the Supply Demand line Detail
   IF p_supply_demand_line_detail IS  NULL OR p_supply_demand_line_detail = fnd_api.g_miss_num  THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_DMND_LINE_DTL_MAND' );
      FND_MSG_PUB.add;
      -- Demand Line Detail is required for CMRO reservations
      -- log the error
      IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'Demand Line Detail is required for CMRO reservations'
      );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Get the Reserved Quantity
   OPEN get_rsvd_qty_csr(p_supply_demand_line_detail);
   FETCH get_rsvd_qty_csr INTO l_reserved_quantity;
   CLOSE get_rsvd_qty_csr;
   -- if no items have been reserved, set it to 0
   IF l_reserved_quantity IS NULL THEN
      l_reserved_quantity := 0;
   END IF;

   -- Get the requested and completed quantity
   OPEN get_mtl_dtls_cur(p_supply_demand_line_detail);
   FETCH get_mtl_dtls_cur INTO l_requested_quantity,l_completed_quantity;
   CLOSE get_mtl_dtls_cur;

   -- Get the available quantity to reserve
   -- Available quantity to reserve will be the requested Quantity minus the quanity alreadu issued
   -- minus the quantity that is reserved
   --x_available_quantity := l_requested_quantity - l_completed_quantity - l_reserved_quantity;

   -- AnRaj: Modified code, we are not subtracting reserved quantity from CMRO because this is being done in WMS also
    x_available_quantity := l_requested_quantity - l_completed_quantity ;

   IF (l_log_statement  >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'x_available_quantity' || x_available_quantity
      );
   END IF;

   -- End logging
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;

   -- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'get_available_supply_demand',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);
END get_available_supply_demand;

-- The purpose of this API is to validate whether a supply or a demand line for which the reservation is being
-- created/ modified is a valid document line. This procedure will be called by the inventory APIs to validate a
-- supply or a demand document, if the supply/demand document line is non-inventory
PROCEDURE validate_supply_demand (
			  p_api_version_number     		IN     	NUMBER
		  	, p_init_msg_lst             		IN       VARCHAR2
			, x_return_status            		OUT    	NOCOPY VARCHAR2
  			, x_msg_count                		OUT    	NOCOPY NUMBER
			, x_msg_data                 		OUT    	NOCOPY VARCHAR2
			, p_organization_id					IN			NUMBER
			, p_item_id								IN			NUMBER
			, p_supply_demand_code				IN			NUMBER
			, p_supply_demand_type_id			IN			NUMBER
			, p_supply_demand_header_id		IN			NUMBER
			, p_supply_demand_line_id			IN			NUMBER
			, p_supply_demand_line_detail		IN			NUMBER
			, p_demand_ship_date					IN			DATE
			, p_expected_receipt_date			IN			DATE
			, x_valid_status						OUT      NOCOPY VARCHAR2
)
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'validate_supply_demand';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_init_msg_list               VARCHAR2(1)       := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

   -- Validating the details if it is of type INV
   CURSOR get_mtl_dtls_inv_cur ( c_scheduled_material_id IN NUMBER,
                                 c_visit_task_id IN NUMBER,
                                 c_rt_oper_material_id IN NUMBER,
                                 c_organization_id IN NUMBER,
                                 c_item_id IN NUMBER)
   IS
	   SELECT   scheduled_material_id
	   FROM     ahl_schedule_materials
	   WHERE    scheduled_material_id = c_SCHEDULED_MATERIAL_ID
	   AND      organization_id = c_organization_ID
	   AND      inventory_item_id = c_item_ID
	   AND      visit_task_id = c_visit_task_ID
	   AND      rt_oper_material_id = c_rt_oper_material_id
	   AND      status = 'ACTIVE'
	   AND      requested_quantity <>0
	   AND      EXISTS ( SELECT 1
	                     FROM ahl_visit_tasks_b vt
	                     WHERE vt.status_code = 'PLANNING'
	                     AND vt.visit_task_id =   c_visit_task_id);
   -- Validating the details if it is of type WIP
   CURSOR get_mtl_dtls_wip_cur ( c_scheduled_material_id IN NUMBER,
                                 c_wip_entity_id IN NUMBER,
                                 c_oper_seq_num IN NUMBER,
                                 c_organization_id IN NUMBER,
                                 c_item_id IN NUMBER)
   IS
	   SELECT scheduled_material_id
	   FROM ahl_schedule_materials
	   WHERE scheduled_material_id = c_scheduled_material_id
      AND  organization_id = c_organization_id
	   AND  inventory_item_id = c_item_id
	   AND  Operation_sequence = c_oper_seq_num
	   AND  status = 'ACTIVE'
	   AND  requested_quantity <>0
	   AND  visit_task_id = (  SELECT   aw.visit_task_id
	                           FROM     ahl_visit_tasks_b vt, ahl_workorders aw
	                           WHERE    vt.status_code IN ('PLANNING','RELEASED')
	                           AND      aw.wip_entity_id = c_wip_entity_id
	                           AND      aw.status_code in ('1','3')
	                           AND      aw.visit_task_id= vt.visit_task_id );
   -- local variables
   l_scheduled_material_id    NUMBER := null;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT VALIDATE_SUPPLY_DEMAND_GRP;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version_number, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_lst)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;
   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure '
      );
   END IF;

   -- log all the input parameters
   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_organization_id-->' || p_organization_id
      );
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_item_id-->' || p_item_id
      );
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_supply_demand_code-->' || p_supply_demand_code
      );
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_supply_demand_type_id-->' || p_supply_demand_type_id
      );
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_supply_demand_header_id-->' || p_supply_demand_header_id
      );
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_supply_demand_line_id-->' || p_supply_demand_line_id
      );
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_supply_demand_line_detail-->' || p_supply_demand_line_detail
      );
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_demand_ship_date-->' || p_demand_ship_date
      );
      fnd_log.string
      (
         fnd_log.level_statement,'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_expected_receipt_date-->' || p_expected_receipt_date
      );
   END IF;

   -- Validate the Supply Demand Code
   -- 1 : 'SUPPLY' 2 : 'DEMAND'.
   IF p_supply_demand_code <> 2 THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_AGAINST_DMND_ONLY' );
      FND_MSG_PUB.add;
      --The reservations should be against demand, not supply.
      -- log the error
      IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'The reservations should be against demand, not supply.'
      );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- p_supply_demand_header_id null check
   IF p_supply_demand_header_id IS NULL OR p_supply_demand_header_id = fnd_api.g_miss_num THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_DMND_HDR_MAND' );
      FND_MSG_PUB.add;
      -- Demand header is required for CMRO reservations
      -- log the error
      IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'Demand header is required for CMRO reservations'
      );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- p_supply_demand_line_id null check
   IF p_supply_demand_line_id IS NULL OR p_supply_demand_line_id = fnd_api.g_miss_num THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_DMND_LINE_MAND' );
      FND_MSG_PUB.add;
      -- Demand Line is required for CMRO reservations
      -- log the error
      IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'Demand Line is required for CMRO reservations'
      );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- p_supply_demand_line_detail null check
   IF p_supply_demand_line_detail IS NULL OR p_supply_demand_line_detail = fnd_api.g_miss_num  THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_DMND_LINE_DTL_MAND' );
      FND_MSG_PUB.add;
      -- Demand Line Detail is required for CMRO reservations
      -- log the error
      IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'Demand Line Detail is required for CMRO reservations'
      );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

      -- p_supply_demand_line_detail null check
   IF p_organization_id IS NULL OR p_organization_id =  fnd_api.g_miss_num THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_ORG_MAND_VLD_SUP_DMND' );
      FND_MSG_PUB.add;
      -- Organization is mandatory in validate_supply_demand.
      -- log the error
      IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'Organization is mandatory in validate_supply_demand.'
      );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- p_supply_demand_line_detail null check
   IF p_item_id IS NULL OR p_item_id = fnd_api.g_miss_num  THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_ITM_MAND_VLD_SUP_DMND' );
      FND_MSG_PUB.add;
      -- Item ID is mandatory in validate_supply_demand.
      -- log the error
      IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'Item ID is mandatory in validate_supply_demand.'
      );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Validate the details by seeing whether they exist
   IF p_supply_demand_type_id = inv_reservation_global.g_source_type_inv THEN
      OPEN get_mtl_dtls_inv_cur(   p_supply_demand_line_detail,
                                          p_supply_demand_header_id,
                                          p_supply_demand_line_id,
                                          p_organization_id,
                                          p_item_id);
      FETCH get_mtl_dtls_inv_cur INTO l_scheduled_material_id;
      CLOSE get_mtl_dtls_inv_cur;
   ELSIF p_supply_demand_type_id = inv_reservation_global.g_source_type_wip THEN
	   OPEN get_mtl_dtls_wip_cur (  p_supply_demand_line_detail,
                                          p_supply_demand_header_id,
                                          p_supply_demand_line_id,
                                          p_organization_id,
                                          p_item_id);
      FETCH get_mtl_dtls_wip_cur INTO l_scheduled_material_id;
      CLOSE get_mtl_dtls_wip_cur;
   ELSE
      FND_MESSAGE.set_name( 'AHL', 'AHL_RSV_SUP_DEM_TYPE_INVLD' );
      FND_MSG_PUB.add;
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Wrong value for Supply Demand Type.'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- set the return value.
   IF l_scheduled_material_id is null THEN
	       x_valid_status := 'N';
	ELSE
	       x_valid_status := 'Y';
	END IF;
   IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Return Value: x_valid_status' || x_valid_status
         );
   END IF;


   -- End logging
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;

   -- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'get_available_supply_demand',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);
END validate_supply_demand;

END AHL_INV_RESERVATIONS_GRP;

/
