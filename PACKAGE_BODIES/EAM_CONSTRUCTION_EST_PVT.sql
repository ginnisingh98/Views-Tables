--------------------------------------------------------
--  DDL for Package Body EAM_CONSTRUCTION_EST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTRUCTION_EST_PVT" AS
/* $Header: EAMVCESB.pls 120.0.12010000.27 2009/01/23 11:01:50 dsingire noship $ */
-- Start of Comments
-- Package name     : EAM_CONSTRUCTION_EST_PVT
-- Purpose          : Privatre Package Body for Construction estimate
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'EAM_CONSTRUCTION_EST_PVT';
G_FILE_NAME      CONSTANT VARCHAR2(12) := 'EAMVCESB.pls';
G_DEBUG_FILENAME CONSTANT VARCHAR2(50) := 'EAM_CONSTRUCTION_EST_DBG.log';

PROCEDURE INIT_DEBUG(
  p_init_msg_list       IN VARCHAR2,
  p_debug_filename      IN VARCHAR2 := G_DEBUG_FILENAME,
  p_debug_file_mode     IN VARCHAR2 := 'w',
  p_debug               IN OUT NOCOPY VARCHAR2
)
IS
  l_output_dir          VARCHAR2(512);
  l_mesg_token_tbl      EAM_ERROR_MESSAGE_PVT.MESG_TOKEN_TBL_TYPE;
	l_out_mesg_token_tbl  EAM_ERROR_MESSAGE_PVT.MESG_TOKEN_TBL_TYPE;
	l_token_tbl           EAM_ERROR_MESSAGE_PVT.TOKEN_TBL_TYPE;
  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
  p_debug := NVL(FND_PROFILE.VALUE('EAM_DEBUG'), 'N');
  EAM_PROCESS_WO_PVT.SET_DEBUG(p_debug);

  EAM_ERROR_MESSAGE_PVT.SET_BO_IDENTIFIER(p_bo_identifier => 'EAM');

  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    EAM_ERROR_MESSAGE_PVT.INITIALIZE;
  END IF;

  EAM_WORKORDER_UTIL_PKG.LOG_PATH(l_output_dir);

  IF p_debug = 'Y' THEN
    IF trim(l_output_dir) IS NULL OR trim(l_output_dir) = '' THEN
      l_out_mesg_token_tbl := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.ADD_ERROR_TOKEN(
        p_message_text       => 'Debug is set to Y so an output directory' ||
                                ' must be specified. Debug will be turned' ||
                                ' off since no directory is specified',
        p_mesg_token_tbl     => l_mesg_token_tbl,
        x_mesg_token_tbl     => l_out_mesg_token_tbl,
        p_token_tbl          => l_token_tbl);
      l_mesg_token_tbl := l_out_mesg_token_tbl;
      p_debug := 'N';
      EAM_PROCESS_WO_PVT.SET_DEBUG(p_debug);
    END IF;

    IF trim(p_debug_filename) IS NULL OR trim(p_debug_filename) = '' THEN
      l_out_mesg_token_tbl := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token(
        p_Message_text       => 'Debug is set to Y so an output filename'  ||
                                ' must be specified. Debug will be turned' ||
                                ' off since no filename is specified',
        p_Mesg_Token_Tbl     => l_mesg_token_tbl,
        x_Mesg_Token_Tbl     => l_out_mesg_token_tbl,
        p_Token_Tbl          => l_token_tbl);
      l_mesg_token_tbl := l_out_mesg_token_tbl;
      p_debug:= 'N';
      EAM_PROCESS_WO_PVT.SET_DEBUG(p_debug);
    END IF;

    IF p_debug = 'Y' THEN
      l_out_mesg_token_tbl := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Open_Debug_Session(
        p_debug_filename     => p_debug_filename,
        p_output_dir         => l_output_dir,
        p_debug_file_mode    => p_debug_file_mode,
        x_return_status      => l_return_status,
        p_mesg_token_tbl     => l_mesg_token_tbl,
        x_mesg_token_tbl     => l_out_mesg_token_tbl);
      l_mesg_token_tbl := l_out_mesg_token_tbl;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        p_debug:= 'N';
        EAM_PROCESS_WO_PVT.SET_DEBUG(p_debug);
      END IF;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END INIT_DEBUG;

PROCEDURE DEBUG(p_message IN VARCHAR2) IS
BEGIN
  EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG(p_message);
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END DEBUG;

PROCEDURE GET_UNIT_RESOURCE_COST(
    p_resource_id               IN NUMBER
  , p_cost_type_id 				IN NUMBER
  , p_ext_precision  			IN NUMBER
  , p_org_id   			        IN NUMBER
  , x_unit_resource_value       OUT NOCOPY NUMBER
  , x_return_status             OUT NOCOPY VARCHAR2
)
IS

BEGIN

  SELECT ROUND(DECODE(BR.FUNCTIONAL_CURRENCY_FLAG, 1, 1,
    NVL(CRC.RESOURCE_RATE,0)) * 1 -- 1 TO REPRESENT UNIT RESOURCE QUANTITY
    * DECODE(NULL, 1, NULL, 2, 1, 1) ,p_ext_precision)
    INTO X_UNIT_RESOURCE_VALUE
    FROM CST_RESOURCE_COSTS CRC, BOM_RESOURCES BR
    WHERE CRC.RESOURCE_ID = p_resource_id
    AND BR.RESOURCE_ID = CRC.RESOURCE_ID
    AND BR.ORGANIZATION_ID = p_org_id
    AND CRC.COST_TYPE_ID    = p_cost_type_id;
  x_return_status := 'S';

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'E';
END GET_UNIT_RESOURCE_COST;

PROCEDURE GET_UNIT_STOCKED_MAT_COST(
    p_inv_id                    IN NUMBER
  , p_cost_method 				IN NUMBER
  , p_cost_group_id 			IN NUMBER
  , p_org_id   			        IN NUMBER
  , p_ext_precision  			IN NUMBER
  , x_unit_mat_value            OUT NOCOPY NUMBER
  , x_return_status             OUT NOCOPY VARCHAR2
)
IS

BEGIN

  SELECT ROUND(SUM( 1 * -- 1 TO REPRESENT UNIT MAT QUANTITY
  DECODE(MSI.EAM_ITEM_TYPE, 3,DECODE(NULL,'Y',0, NVL(CCICV.ITEM_COST,0)), NVL(CCICV.ITEM_COST,0))), p_ext_precision) MAT_VALUE
  INTO x_unit_mat_value
   FROM CST_CG_ITEM_COSTS_VIEW CCICV,
  MTL_SYSTEM_ITEMS_B MSI
  WHERE CCICV.INVENTORY_ITEM_ID = p_inv_id
AND CCICV.ORGANIZATION_ID       = p_org_id
AND CCICV.COST_GROUP_ID         = DECODE(p_cost_method,1,1, p_cost_group_id)
AND MSI.ORGANIZATION_ID         = p_org_id
AND MSI.INVENTORY_ITEM_ID       = p_inv_id
AND MSI.STOCK_ENABLED_FLAG      = 'Y';

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'E';
END GET_UNIT_STOCKED_MAT_COST;

PROCEDURE GET_UNIT_NON_STOCKED_MAT_COST(
    p_inv_id                    IN NUMBER
  , p_org_id   			        IN NUMBER
  , p_ext_precision  			IN NUMBER
  , x_unit_mat_value            OUT NOCOPY NUMBER
  , x_return_status             OUT NOCOPY VARCHAR2
)
IS

BEGIN
   SELECT ROUND(MSIK.LIST_PRICE_PER_UNIT,p_ext_precision)
   INTO x_unit_mat_value
   FROM MTL_SYSTEM_ITEMS_VL MSIK
  WHERE MSIK.ORGANIZATION_ID = p_org_id
AND MSIK.INVENTORY_ITEM_ID   = p_inv_id
AND MSIK.STOCK_ENABLED_FLAG  = 'N';

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'E';
END GET_UNIT_NON_STOCKED_MAT_COST;

PROCEDURE EXPLODE_INITIAL_ESTIMATE(
      p_api_version            IN  NUMBER        := 1.0
    , p_init_msg_list          IN  VARCHAR2      := 'F'
    , p_commit                  IN  VARCHAR2
    , p_estimate_id             IN  NUMBER
    , x_ce_msg_tbl              OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_MESSAGE_TBL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count              OUT NOCOPY NUMBER
    , x_msg_data               OUT NOCOPY VARCHAR2)
IS

  l_in_eam_ce_wo_lines_tbl EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL;
  l_out_eam_ce_wo_lines_tbl EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL;
  l_estimate_id NUMBER := p_estimate_id;
  l_return_status VARCHAR2(1);

BEGIN
  debug('Calling API EXPLODE_INITIAL_ESTIMATE');
  debug('p_estimate_id  - ' || p_estimate_id);

  SAVEPOINT EXPLODE_INITIAL_ESTIMATE;

  -- The initial loading of exploded activities
  -- EXPLODE_CE_ACTIVITIES to explode the activites and the construction units
  EXPLODE_CE_ACTIVITIES(
      p_estimate_id             => l_estimate_id
    , p_eam_ce_wo_lines_tbl     => l_in_eam_ce_wo_lines_tbl
    , x_eam_ce_wo_lines_tbl     => l_out_eam_ce_wo_lines_tbl
    , x_ce_msg_tbl              => x_ce_msg_tbl
    , x_return_status           => l_return_status
  );

   IF nvl(l_return_status,'S') <> 'S' THEN
    -- Log error, but continue processing
    l_return_status := 'E';
    debug('Error EXPLODE_CE_ACTIVITIES');
    RAISE FND_API.G_EXC_ERROR;
   END IF; -- nvl(l_return_status,'S') <> 'S'

   -- All the associated acitivites are exploeded and
   -- available in l_out_eam_ce_wo_lines_tbl
   -- Insert all the work order lines in to
   -- EAM_CE_WORK_ORDER_LINES, but dont commit the data
   INSERT_ALL_WO_LINES(
   p_api_version             => 1.0
  , p_init_msg_list          => FND_API.G_FALSE
  , p_commit                 => p_commit
  , p_estimate_id            => l_estimate_id
  , p_eam_ce_wo_lines_tbl    => l_out_eam_ce_wo_lines_tbl
  , x_return_status          => l_return_status
  , x_msg_count              => x_msg_count
  , x_msg_data               => x_msg_data
  );

   IF nvl(l_return_status,'S') <> 'S' THEN
    -- Log error, but continue processing
    l_return_status := 'E';
    debug('Error INSERT_ALL_WO_LINES');
    RAISE FND_API.G_EXC_ERROR;
   END IF; -- nvl(l_return_status,'S') <> 'S'
  x_return_status := FND_API.G_RET_STS_SUCCESS;
   debug ('End EXPLODE_INITIAL_ESTIMATE');
   --COMMIT;
EXCEPTION
 	WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO EXPLODE_INITIAL_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO EXPLODE_INITIAL_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO EXPLODE_INITIAL_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'EXPLODE_INITIAL_ESTIMATE');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data  => x_msg_data);

END EXPLODE_INITIAL_ESTIMATE;

PROCEDURE DELETE_WO_LINE(
    p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                        IN VARCHAR2
  , p_work_order_line_id            IN NUMBER
  , x_return_status                 OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
)
IS

BEGIN
  SAVEPOINT DELETE_WO_LINE;

  -- Validate input parameters

   IF (p_work_order_line_id IS NULL) THEN
    --FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    --FND_MESSAGE.SET_TOKEN('PARAMETER', 'ORGANIZATION_ID');
    --FND_MESSAGE.SET_TOKEN('VALUE', p_parent_wo_line_rec.ORGANIZATION_ID);
    --FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   EAM_CE_WORK_ORDER_LINES_PKG.DELETE_ROW(
    p_work_order_line_id => p_work_order_line_id
   );

  IF NVL(p_commit,'F') = 'T' THEN
    debug('Committing');
    COMMIT;
  END IF;
  x_return_status := 'S';

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_WO_LINE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_WO_LINE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO DELETE_WO_LINE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'DELETE_WO_LINE');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data  => x_msg_data);
END DELETE_WO_LINE;

PROCEDURE INSERT_PARENT_WO_LINE(
    p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                 IN VARCHAR2
  , p_estimate_id            IN NUMBER
  , p_parent_wo_line_rec     IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_PARENT_WO_REC
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
)

IS

  l_estimate_rec          EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC;
  l_parent_ce_wo_line_rec EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_REC;
  l_creation_date         DATE                  := SYSDATE;
  l_created_by            NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_date     DATE                  := SYSDATE;
  l_last_updated_by       NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_login    NUMBER;
  l_wo_line_id_seq        NUMBER;
  l_parent_wo_num         NUMBER;

  CURSOR EST_PARENT_CSR IS
     SELECT ESTIMATE_ID    ,
      ORGANIZATION_ID      ,
      CREATE_PARENT_WO_FLAG,
      PARENT_WO_ID
    FROM EAM_CONSTRUCTION_ESTIMATES
    WHERE ESTIMATE_ID = p_estimate_id
    AND ORGANIZATION_ID = p_parent_wo_line_rec.ORGANIZATION_ID;

  l_estimate_parent_rec     EST_PARENT_CSR%ROWTYPE;

BEGIN

   SAVEPOINT INSERT_PARENT_WO_LINE;

   -- Validate input parameters

   IF (p_parent_wo_line_rec.ORGANIZATION_ID IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ORGANIZATION_ID');
    FND_MESSAGE.SET_TOKEN('VALUE', p_parent_wo_line_rec.ORGANIZATION_ID);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_estimate_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ESTIMATE_NUMBER');
    FND_MESSAGE.SET_TOKEN('VALUE', p_estimate_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- If the parent details already exist, update the estimate
  OPEN EST_PARENT_CSR;
  FETCH EST_PARENT_CSR INTO l_estimate_parent_rec;
  CLOSE EST_PARENT_CSR;


  -- Update the estimate table with the create parent flag
  -- and parent work order number
  -- Construct estimate rec with the parent wo details
  l_estimate_rec.ESTIMATE_ID := p_estimate_id;
  l_estimate_rec.ORGANIZATION_ID := p_parent_wo_line_rec.ORGANIZATION_ID;
  l_estimate_rec.ESTIMATE_NUMBER := FND_API.G_MISS_CHAR;
  l_estimate_rec.ESTIMATE_DESCRIPTION := FND_API.G_MISS_CHAR;
  l_estimate_rec.GROUPING_OPTION := FND_API.G_MISS_NUM;

  -- If the create parent flag is Y then the
  -- PARENT_WO_ID holds the ESTIMATE_WORK_ORDER_LINE_ID
  -- CE work order lines table
  -- If the create parent flag is N the the
  -- PARENT_WO_ID holds the wip entity id of the
  -- existing work order
  IF p_parent_wo_line_rec.CREATE_PARENT_FLAG = 'Y' THEN
    -- PARENT_WO_ID holds ESTIMATE_WORK_ORDER_LINE_ID
    -- The the corresponding ESTIMATE_WORK_ORDER_LINE_ID contains all the
    -- parent work order details

    IF NVL(l_estimate_parent_rec.PARENT_WO_ID,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
      AND NVL(l_estimate_parent_rec.CREATE_PARENT_WO_FLAG,'N') <> 'N' THEN

      l_wo_line_id_seq := l_estimate_parent_rec.PARENT_WO_ID;

      EAM_CE_WORK_ORDER_LINES_PKG.UPDATE_ROW(
         p_estimate_work_order_line_id    =>    l_wo_line_id_seq
        ,p_estimate_work_order_id         =>    FND_API.G_MISS_NUM
        ,p_src_cu_id                      =>    FND_API.G_MISS_NUM
        ,p_src_activity_id                =>    FND_API.G_MISS_NUM
        ,p_src_activity_qty               =>    FND_API.G_MISS_NUM
        ,p_src_op_seq_num                 =>    FND_API.G_MISS_NUM
        ,p_src_acct_class_code            =>    FND_API.G_MISS_CHAR
        ,p_src_diff_id                    =>    FND_API.G_MISS_NUM
        ,p_diff_qty                       =>    FND_API.G_MISS_NUM
        ,p_estimate_id                    =>    p_estimate_id
        ,p_organization_id                =>    p_parent_wo_line_rec.ORGANIZATION_ID
        ,p_work_order_seq_num             =>    FND_API.G_MISS_NUM
        ,p_work_order_number              =>    p_parent_wo_line_rec.PARENT_WORK_ORDER_NUMBER
        ,p_work_order_description         =>    p_parent_wo_line_rec.WORK_ORDER_DESCRIPTION
        ,p_ref_wip_entity_id              =>    FND_API.G_MISS_NUM
        ,p_primary_item_id                =>    FND_API.G_MISS_NUM
        ,p_status_type                    =>    FND_API.G_MISS_NUM
        ,p_acct_class_code                =>    p_parent_wo_line_rec.ACCT_CLASS_CODE
        ,p_scheduled_start_date           =>    sysdate
        ,p_scheduled_completion_date      =>    FND_API.G_MISS_DATE
        ,p_project_id                     =>    p_parent_wo_line_rec.PROJECT_ID
        ,p_task_id                        =>    p_parent_wo_line_rec.TASK_ID
        ,p_maintenance_object_id          =>    p_parent_wo_line_rec.MAINTENANCE_OBJECT_ID
        ,p_maintenance_object_type        =>    p_parent_wo_line_rec.MAINTENANCE_OBJECT_TYPE
        ,p_maintenance_object_source      =>    p_parent_wo_line_rec.MAINTENANCE_OBJECT_SOURCE
        ,p_owning_department_id           =>    p_parent_wo_line_rec.OWNING_DEPARTMENT_ID
        ,p_user_defined_status_id         =>    p_parent_wo_line_rec.STATUS_TYPE
        ,p_op_seq_num                     =>    FND_API.G_MISS_NUM
        ,p_op_description                 =>    FND_API.G_MISS_CHAR
        ,p_standard_operation_id          =>    FND_API.G_MISS_NUM
        ,p_op_department_id               =>    FND_API.G_MISS_NUM
        ,p_op_long_description            =>    FND_API.G_MISS_CHAR
        ,p_res_seq_num                    =>    FND_API.G_MISS_NUM
        ,p_res_id                         =>    FND_API.G_MISS_NUM
        ,p_res_uom                        =>    FND_API.G_MISS_CHAR
        ,p_res_basis_type                 =>    FND_API.G_MISS_NUM
        ,p_res_usage_rate_or_amount       =>    FND_API.G_MISS_NUM
        ,p_res_required_units             =>    FND_API.G_MISS_NUM
        ,p_res_assigned_units             =>    FND_API.G_MISS_NUM
        ,p_item_type                      =>    FND_API.G_MISS_NUM
        ,p_required_quantity              =>    FND_API.G_MISS_NUM
        ,p_unit_price                     =>    FND_API.G_MISS_NUM
        ,p_uom                            =>    FND_API.G_MISS_CHAR
        ,p_basis_type                     =>    FND_API.G_MISS_NUM
        ,p_suggested_vendor_name          =>    FND_API.G_MISS_CHAR
        ,p_suggested_vendor_id            =>    FND_API.G_MISS_NUM
        ,p_suggested_vendor_site          =>    FND_API.G_MISS_CHAR
        ,p_suggested_vendor_site_id       =>    FND_API.G_MISS_NUM
        ,p_mat_inventory_item_id          =>    FND_API.G_MISS_NUM
        ,p_mat_component_seq_num          =>    FND_API.G_MISS_NUM
        ,p_mat_supply_subinventory        =>    FND_API.G_MISS_CHAR
        ,p_mat_supply_locator_id          =>    FND_API.G_MISS_NUM
        ,p_di_amount                      =>    FND_API.G_MISS_NUM
        ,p_di_order_type_lookup_code      =>    FND_API.G_MISS_CHAR
        ,p_di_description                 =>    FND_API.G_MISS_CHAR
        ,p_di_purchase_category_id        =>    FND_API.G_MISS_NUM
        ,p_di_auto_request_material       =>    FND_API.G_MISS_CHAR
        ,p_di_need_by_date                =>    FND_API.G_MISS_DATE
        ,p_work_order_line_cost           =>    FND_API.G_MISS_NUM
        ,p_creation_date                  =>    sysdate
        ,p_created_by                     =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_date               =>    sysdate
        ,p_last_updated_by                =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_login              =>    FND_GLOBAL.LOGIN_ID
        ,p_work_order_type                =>    FND_API.G_MISS_NUM
        ,p_activity_type                  =>    FND_API.G_MISS_NUM
        ,p_activity_source                =>    FND_API.G_MISS_NUM
        ,p_activity_cause                 =>    FND_API.G_MISS_NUM
        ,p_available_qty                  =>    FND_API.G_MISS_NUM
        ,p_item_comments                  =>    FND_API.G_MISS_CHAR
        ,p_cu_qty                         =>    FND_API.G_MISS_NUM
        ,p_res_sch_flag                   =>    FND_API.G_MISS_NUM
        );

    ELSE

      SELECT EAM_CE_WORK_ORDER_LINES_S.NEXTVAL INTO l_wo_line_id_seq FROM DUAL;

      EAM_CE_WORK_ORDER_LINES_PKG.INSERT_ROW(
         p_estimate_work_order_line_id    =>    l_wo_line_id_seq
        ,p_estimate_work_order_id         =>    FND_API.G_MISS_NUM
        ,p_src_cu_id                      =>    FND_API.G_MISS_NUM
        ,p_src_activity_id                =>    FND_API.G_MISS_NUM
        ,p_src_activity_qty               =>    FND_API.G_MISS_NUM
        ,p_src_op_seq_num                 =>    FND_API.G_MISS_NUM
        ,p_src_acct_class_code            =>    FND_API.G_MISS_CHAR
        ,p_src_diff_id                    =>    FND_API.G_MISS_NUM
        ,p_diff_qty                       =>    FND_API.G_MISS_NUM
        ,p_estimate_id                    =>    p_estimate_id
        ,p_organization_id                =>    p_parent_wo_line_rec.ORGANIZATION_ID
        ,p_work_order_seq_num             =>    FND_API.G_MISS_NUM
        ,p_work_order_number              =>    p_parent_wo_line_rec.PARENT_WORK_ORDER_NUMBER
        ,p_work_order_description         =>    p_parent_wo_line_rec.WORK_ORDER_DESCRIPTION
        ,p_ref_wip_entity_id              =>    FND_API.G_MISS_NUM
        ,p_primary_item_id                =>    FND_API.G_MISS_NUM
        ,p_status_type                    =>    FND_API.G_MISS_NUM
        ,p_acct_class_code                =>    p_parent_wo_line_rec.ACCT_CLASS_CODE
        ,p_scheduled_start_date           =>    sysdate
        ,p_scheduled_completion_date      =>    FND_API.G_MISS_DATE
        ,p_project_id                     =>    p_parent_wo_line_rec.PROJECT_ID
        ,p_task_id                        =>    p_parent_wo_line_rec.TASK_ID
        ,p_maintenance_object_id          =>    p_parent_wo_line_rec.MAINTENANCE_OBJECT_ID
        ,p_maintenance_object_type        =>    p_parent_wo_line_rec.MAINTENANCE_OBJECT_TYPE
        ,p_maintenance_object_source      =>    p_parent_wo_line_rec.MAINTENANCE_OBJECT_SOURCE
        ,p_owning_department_id           =>    p_parent_wo_line_rec.OWNING_DEPARTMENT_ID
        ,p_user_defined_status_id         =>    p_parent_wo_line_rec.STATUS_TYPE
        ,p_op_seq_num                     =>    FND_API.G_MISS_NUM
        ,p_op_description                 =>    FND_API.G_MISS_CHAR
        ,p_standard_operation_id          =>    FND_API.G_MISS_NUM
        ,p_op_department_id               =>    FND_API.G_MISS_NUM
        ,p_op_long_description            =>    FND_API.G_MISS_CHAR
        ,p_res_seq_num                    =>    FND_API.G_MISS_NUM
        ,p_res_id                         =>    FND_API.G_MISS_NUM
        ,p_res_uom                        =>    FND_API.G_MISS_CHAR
        ,p_res_basis_type                 =>    FND_API.G_MISS_NUM
        ,p_res_usage_rate_or_amount       =>    FND_API.G_MISS_NUM
        ,p_res_required_units             =>    FND_API.G_MISS_NUM
        ,p_res_assigned_units             =>    FND_API.G_MISS_NUM
        ,p_item_type                      =>    FND_API.G_MISS_NUM
        ,p_required_quantity              =>    FND_API.G_MISS_NUM
        ,p_unit_price                     =>    FND_API.G_MISS_NUM
        ,p_uom                            =>    FND_API.G_MISS_CHAR
        ,p_basis_type                     =>    FND_API.G_MISS_NUM
        ,p_suggested_vendor_name          =>    FND_API.G_MISS_CHAR
        ,p_suggested_vendor_id            =>    FND_API.G_MISS_NUM
        ,p_suggested_vendor_site          =>    FND_API.G_MISS_CHAR
        ,p_suggested_vendor_site_id       =>    FND_API.G_MISS_NUM
        ,p_mat_inventory_item_id          =>    FND_API.G_MISS_NUM
        ,p_mat_component_seq_num          =>    FND_API.G_MISS_NUM
        ,p_mat_supply_subinventory        =>    FND_API.G_MISS_CHAR
        ,p_mat_supply_locator_id          =>    FND_API.G_MISS_NUM
        ,p_di_amount                      =>    FND_API.G_MISS_NUM
        ,p_di_order_type_lookup_code      =>    FND_API.G_MISS_CHAR
        ,p_di_description                 =>    FND_API.G_MISS_CHAR
        ,p_di_purchase_category_id        =>    FND_API.G_MISS_NUM
        ,p_di_auto_request_material       =>    FND_API.G_MISS_CHAR
        ,p_di_need_by_date                =>    FND_API.G_MISS_DATE
        ,p_work_order_line_cost           =>    FND_API.G_MISS_NUM
        ,p_creation_date                  =>    sysdate
        ,p_created_by                     =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_date               =>    sysdate
        ,p_last_updated_by                =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_login              =>    FND_GLOBAL.LOGIN_ID
        ,p_work_order_type                =>    FND_API.G_MISS_NUM
        ,p_activity_type                  =>    FND_API.G_MISS_NUM
        ,p_activity_source                =>    FND_API.G_MISS_NUM
        ,p_activity_cause                 =>    FND_API.G_MISS_NUM
        ,p_available_qty                  =>    FND_API.G_MISS_NUM
        ,p_item_comments                  =>    FND_API.G_MISS_CHAR
        ,p_cu_qty                         =>    FND_API.G_MISS_NUM
        ,p_res_sch_flag                   =>    FND_API.G_MISS_NUM
        );


    END IF; -- IF l_estimate_parent_rec.PARENT_WO_ID IS NULL THEN

    -- Update the estimates table with the ESTIMATE_WORK_ORDER_LINE_ID
    -- generated
    EAM_CONSTRUCTION_ESTIMATES_PKG.UPDATE_ROW(
      p_ESTIMATE_ID               => p_estimate_id,
      p_ORGANIZATION_ID           => l_estimate_rec.ORGANIZATION_ID,
      p_ESTIMATE_NUMBER           => l_estimate_rec.ESTIMATE_NUMBER,
      p_ESTIMATE_DESCRIPTION      => l_estimate_rec.ESTIMATE_DESCRIPTION,
      p_GROUPING_OPTION           => l_estimate_rec.GROUPING_OPTION,
      p_PARENT_WO_ID              => l_wo_line_id_seq,
      p_CREATE_PARENT_WO_FLAG     => p_parent_wo_line_rec.CREATE_PARENT_FLAG,
      p_CREATION_DATE             => l_creation_date,
      p_CREATED_BY                => l_created_by,
      p_LAST_UPDATE_DATE          => l_last_updated_date,
      p_LAST_UPDATED_BY           => l_last_updated_by,
      p_LAST_UPDATE_LOGIN         => l_last_updated_login,
      p_ATTRIBUTE_CATEGORY        => l_estimate_rec.attribute_category,
		  p_ATTRIBUTE1                => l_estimate_rec.attribute1,
		  p_ATTRIBUTE2                => l_estimate_rec.attribute2,
		  p_ATTRIBUTE3                => l_estimate_rec.attribute3,
		  p_ATTRIBUTE4                => l_estimate_rec.attribute4,
		  p_ATTRIBUTE5                => l_estimate_rec.attribute5,
		  p_ATTRIBUTE6                => l_estimate_rec.attribute6,
		  p_ATTRIBUTE7                => l_estimate_rec.attribute7,
		  p_ATTRIBUTE8                => l_estimate_rec.attribute8,
		  p_ATTRIBUTE9                => l_estimate_rec.attribute9,
		  p_ATTRIBUTE10               => l_estimate_rec.attribute10,
		  p_ATTRIBUTE11               => l_estimate_rec.attribute11,
		  p_ATTRIBUTE12               => l_estimate_rec.attribute12,
		  p_ATTRIBUTE13               => l_estimate_rec.attribute13,
		  p_ATTRIBUTE14               => l_estimate_rec.attribute14,
		  p_ATTRIBUTE15     		      => l_estimate_rec.attribute15
      );

  ELSE

  IF  nvl(p_parent_wo_line_rec.PARENT_WORK_ORDER_NUMBER,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  -- p_parent_wo_line_rec.CREATE_PARENT_FLAG is 'N' the PARENT_WORK_ORDER_NUMBER is
  -- existing wip entity id
  -- Update the estimates table with the wip entity id (PARENT_WORK_ORDER_NUMBER)
  -- of the existing work order


  l_parent_wo_num := TO_NUMBER(p_parent_wo_line_rec.PARENT_WORK_ORDER_NUMBER);

    EAM_CONSTRUCTION_ESTIMATES_PKG.UPDATE_ROW(
      p_ESTIMATE_ID               => p_estimate_id,
      p_ORGANIZATION_ID           => l_estimate_rec.ORGANIZATION_ID,
      p_ESTIMATE_NUMBER           => l_estimate_rec.ESTIMATE_NUMBER,
      p_ESTIMATE_DESCRIPTION      => l_estimate_rec.ESTIMATE_DESCRIPTION,
      p_GROUPING_OPTION           => l_estimate_rec.GROUPING_OPTION,
      p_PARENT_WO_ID              => l_parent_wo_num,
      p_CREATE_PARENT_WO_FLAG     => p_parent_wo_line_rec.CREATE_PARENT_FLAG,
      p_CREATION_DATE             => l_creation_date,
      p_CREATED_BY                => l_created_by,
      p_LAST_UPDATE_DATE          => l_last_updated_date,
      p_LAST_UPDATED_BY           => l_last_updated_by,
      p_LAST_UPDATE_LOGIN         => l_last_updated_login,
      p_ATTRIBUTE_CATEGORY        => l_estimate_rec.attribute_category,
      p_ATTRIBUTE1                => l_estimate_rec.attribute1,
      p_ATTRIBUTE2                => l_estimate_rec.attribute2,
      p_ATTRIBUTE3                => l_estimate_rec.attribute3,
      p_ATTRIBUTE4                => l_estimate_rec.attribute4,
      p_ATTRIBUTE5                => l_estimate_rec.attribute5,
      p_ATTRIBUTE6                => l_estimate_rec.attribute6,
      p_ATTRIBUTE7                => l_estimate_rec.attribute7,
      p_ATTRIBUTE8                => l_estimate_rec.attribute8,
      p_ATTRIBUTE9                => l_estimate_rec.attribute9,
      p_ATTRIBUTE10               => l_estimate_rec.attribute10,
      p_ATTRIBUTE11               => l_estimate_rec.attribute11,
      p_ATTRIBUTE12               => l_estimate_rec.attribute12,
      p_ATTRIBUTE13               => l_estimate_rec.attribute13,
      p_ATTRIBUTE14               => l_estimate_rec.attribute14,
      p_ATTRIBUTE15     		      => l_estimate_rec.attribute15
      );

    -- If the create work order flag has been switched from Y to N
    -- then delete the work order line created when the flag was Y
    IF NVL(l_estimate_parent_rec.CREATE_PARENT_WO_FLAG,'N') = 'Y' AND
      NVL(l_estimate_parent_rec.PARENT_WO_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
        EAM_CE_WORK_ORDER_LINES_PKG.DELETE_ROW (
          p_work_order_line_id => l_estimate_parent_rec.PARENT_WO_ID
        );
     END IF; --  NVL(l_estimate_parent_rec.CREATE_PARENT_WO_FLAG,'N') = 'Y'
    ELSE
      -- No parent record entered
      -- make work order number in the estimate table as null
      EAM_CONSTRUCTION_ESTIMATES_PKG.UPDATE_ROW(
      p_ESTIMATE_ID               => p_estimate_id,
      p_ORGANIZATION_ID           => l_estimate_rec.ORGANIZATION_ID,
      p_ESTIMATE_NUMBER           => l_estimate_rec.ESTIMATE_NUMBER,
      p_ESTIMATE_DESCRIPTION      => l_estimate_rec.ESTIMATE_DESCRIPTION,
      p_GROUPING_OPTION           => l_estimate_rec.GROUPING_OPTION,
      p_PARENT_WO_ID              => NULL,
      p_CREATE_PARENT_WO_FLAG     => p_parent_wo_line_rec.CREATE_PARENT_FLAG,
      p_CREATION_DATE             => l_creation_date,
      p_CREATED_BY                => l_created_by,
      p_LAST_UPDATE_DATE          => l_last_updated_date,
      p_LAST_UPDATED_BY           => l_last_updated_by,
      p_LAST_UPDATE_LOGIN         => l_last_updated_login,
      p_ATTRIBUTE_CATEGORY        => l_estimate_rec.attribute_category,
      p_ATTRIBUTE1                => l_estimate_rec.attribute1,
      p_ATTRIBUTE2                => l_estimate_rec.attribute2,
      p_ATTRIBUTE3                => l_estimate_rec.attribute3,
      p_ATTRIBUTE4                => l_estimate_rec.attribute4,
      p_ATTRIBUTE5                => l_estimate_rec.attribute5,
      p_ATTRIBUTE6                => l_estimate_rec.attribute6,
      p_ATTRIBUTE7                => l_estimate_rec.attribute7,
      p_ATTRIBUTE8                => l_estimate_rec.attribute8,
      p_ATTRIBUTE9                => l_estimate_rec.attribute9,
      p_ATTRIBUTE10               => l_estimate_rec.attribute10,
      p_ATTRIBUTE11               => l_estimate_rec.attribute11,
      p_ATTRIBUTE12               => l_estimate_rec.attribute12,
      p_ATTRIBUTE13               => l_estimate_rec.attribute13,
      p_ATTRIBUTE14               => l_estimate_rec.attribute14,
      p_ATTRIBUTE15     		      => l_estimate_rec.attribute15
      );

      IF NVL(l_estimate_parent_rec.CREATE_PARENT_WO_FLAG,'N') = 'Y' AND
          NVL(l_estimate_parent_rec.PARENT_WO_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
      EAM_CE_WORK_ORDER_LINES_PKG.DELETE_ROW (
        p_work_order_line_id => l_estimate_parent_rec.PARENT_WO_ID
      );
    END IF;
    END IF;
  END IF; -- p_parent_wo_line_rec.CREATE_PARENT_FLAG = 'Y'
  IF NVL(p_commit,'F') = 'T' THEN
    debug('Committing');
    COMMIT;
  END IF;
  x_return_status := 'S';
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INSERT_PARENT_WO_LINE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INSERT_PARENT_WO_LINE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO INSERT_PARENT_WO_LINE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'INSERT_PARENT_WO_LINE');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data  => x_msg_data);
END INSERT_PARENT_WO_LINE;

PROCEDURE EXPLODE_STD_OP(
    p_std_op_id              IN NUMBER
  , p_op_seq                 IN NUMBER
  , p_op_seq_desc            IN VARCHAR2
  , p_org_id                 IN NUMBER
  , p_estimate_id            IN NUMBER
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
)
IS

  CURSOR STD_OP_RES_CUR IS
		SELECT
    p_op_seq OPERATION_SEQ_NUM,
    p_op_seq_desc OPERATION_DESC,
    BSOR.RESOURCE_SEQ_NUM,
    BSO.ORGANIZATION_ID,
    BSOR.LAST_UPDATE_DATE,
    BSOR.LAST_UPDATED_BY,
    BSOR.CREATION_DATE,
    BSOR.CREATED_BY,
    BSOR.LAST_UPDATE_LOGIN,
    BSOR.REQUEST_ID,
    BSOR.PROGRAM_APPLICATION_ID,
    BSOR.PROGRAM_ID,
    BSOR.PROGRAM_UPDATE_DATE,
    BSOR.RESOURCE_ID,
    BR.UNIT_OF_MEASURE,
    BSOR.BASIS_TYPE,
    BSOR.USAGE_RATE_OR_AMOUNT,
    BSOR.ACTIVITY_ID,
    BSOR.SCHEDULE_FLAG,
    BSOR.ASSIGNED_UNITS,
    DECODE(BSOR.AUTOCHARGE_TYPE,1,2,4,3,2,2,3,3,2) AUTOCHARGE_TYPE,
    BSOR.STANDARD_RATE_FLAG,
    0 APPLIED_RESOURCE_UNITS,
    0 APPLIED_RESOURCE_VALUE,
    SYSDATE START_DATE,
    BSO.DEPARTMENT_ID,
    DECODE(BSOR.SCHEDULE_FLAG,2,NULL,BSOR.RESOURCE_SEQ_NUM)  ,
    BSOR.SUBSTITUTE_GROUP_NUM
      FROM BOM_STANDARD_OPERATIONS BSO,
        BOM_STD_OP_RESOURCES BSOR,
        BOM_RESOURCES BR
      WHERE BSO.STANDARD_OPERATION_ID = BSOR.STANDARD_OPERATION_ID
      AND BR.RESOURCE_ID = BSOR.RESOURCE_ID
      AND BSO.STANDARD_OPERATION_ID = p_std_op_id
      AND BSO.ORGANIZATION_ID = p_org_id;

  l_cost_type_id    NUMBER := 0;
  l_cost_group_id 	NUMBER := 0;
  l_primary_cost_method NUMBER := 0;
  l_ext_precision  NUMBER := 0 ;
  l_unit_cost NUMBER := 0;

BEGIN
  --SAVEPOINT EXPLODE_STD_OP;
  -- Get the Cost Type ID
    BEGIN
      SELECT NVL(MP.DEFAULT_COST_GROUP_ID,-1) ,
        DECODE (MP.PRIMARY_COST_METHOD, 1, MP.PRIMARY_COST_METHOD, NVL(MP.AVG_RATES_COST_TYPE_ID,-1)),
        MP.PRIMARY_COST_METHOD
        INTO l_cost_group_id, l_cost_type_id,
        l_primary_cost_method
        FROM MTL_PARAMETERS MP
        WHERE ORGANIZATION_ID = p_org_id;

       SELECT EXTENDED_PRECISION
        INTO l_ext_precision
        FROM FND_CURRENCIES FC,
        GL_SETS_OF_BOOKS SOB   ,
        HR_ORGANIZATION_INFORMATION HROI
        WHERE HROI.ORGANIZATION_ID     = p_org_id
        AND HROI.ORG_INFORMATION1        = TO_CHAR(SOB.SET_OF_BOOKS_ID)
        AND HROI.ORG_INFORMATION_CONTEXT = 'Accounting Information'
        AND SOB.CURRENCY_CODE         = FC.CURRENCY_CODE
        AND FC.ENABLED_FLAG           = 'Y';

    EXCEPTION
    WHEN OTHERS THEN
      l_cost_type_id := 0 ;
      l_cost_group_id := 0;
      l_primary_cost_method := 0;
      l_ext_precision := 5;
    END;


  FOR std_op_rec IN STD_OP_RES_CUR LOOP

    IF NVL(std_op_rec.RESOURCE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
        -- Calculate Cost
        GET_UNIT_RESOURCE_COST(
          p_resource_id         => std_op_rec.RESOURCE_ID
        , p_cost_type_id 				=> l_cost_type_id
        , p_ext_precision       => l_ext_precision
        , p_org_id   			      => p_org_id
        , x_unit_resource_value => l_unit_cost
        , x_return_status       => x_return_status
        );

        IF nvl(x_return_status,'S') <> 'S' THEN
          -- Log error, but continue processing
          x_return_status := 'E';
          RAISE FND_API.G_EXC_ERROR;
         END IF; -- nvl(l_return_status,'S') <> 'S'
    END IF;

    -- Call EAM_CE_WORK_ORDER_LINES_PKG.INSERT_ROW
    -- to insert wo line row

    EAM_CE_WORK_ORDER_LINES_PKG.INSERT_ROW(
     p_estimate_work_order_line_id    =>    NULL
    ,p_estimate_work_order_id         =>    FND_API.G_MISS_NUM
    ,p_src_cu_id                      =>    NULL
    ,p_src_activity_id                =>    NULL
    ,p_src_activity_qty               =>    NULL
    ,p_src_op_seq_num                 =>    NULL
    ,p_src_acct_class_code            =>    NULL
    ,p_src_diff_id                    =>    NULL
    ,p_diff_qty                       =>    NULL
    ,p_estimate_id                    =>    p_estimate_id
    ,p_organization_id                =>    p_org_id
    ,p_work_order_seq_num             =>    NULL
    ,p_work_order_number              =>    NULL
    ,p_work_order_description         =>    NULL
    ,p_ref_wip_entity_id              =>    NULL
    ,p_primary_item_id                =>    NULL
    ,p_status_type                    =>    NULL
    ,p_acct_class_code                =>    NULL
    ,p_scheduled_start_date           =>    std_op_rec.START_DATE
    ,p_scheduled_completion_date      =>    NULL
    ,p_project_id                     =>    NULL
    ,p_task_id                        =>    NULL
    ,p_maintenance_object_id          =>    NULL
    ,p_maintenance_object_type        =>    NULL
    ,p_maintenance_object_source      =>    NULL
    ,p_owning_department_id           =>    std_op_rec.DEPARTMENT_ID
    ,p_user_defined_status_id         =>    NULL
    ,p_op_seq_num                     =>    std_op_rec.OPERATION_SEQ_NUM
    ,p_op_description                 =>    std_op_rec.OPERATION_DESC
    ,p_standard_operation_id          =>    p_std_op_id
    ,p_op_department_id               =>    std_op_rec.DEPARTMENT_ID
    ,p_op_long_description            =>    NULL
    ,p_res_seq_num                    =>    std_op_rec.RESOURCE_SEQ_NUM
    ,p_res_id                         =>    std_op_rec.RESOURCE_ID
    ,p_res_uom                        =>    std_op_rec.UNIT_OF_MEASURE
    ,p_res_basis_type                 =>    std_op_rec.BASIS_TYPE
    ,p_res_usage_rate_or_amount       =>    std_op_rec.USAGE_RATE_OR_AMOUNT
    ,p_res_required_units             =>    std_op_rec.USAGE_RATE_OR_AMOUNT
    ,p_res_assigned_units             =>    std_op_rec.ASSIGNED_UNITS
    ,p_item_type                      =>    NULL
    ,p_required_quantity              =>    std_op_rec.USAGE_RATE_OR_AMOUNT
    ,p_unit_price                     =>    l_unit_cost
    ,p_uom                            =>    NULL
    ,p_basis_type                     =>    NULL
    ,p_suggested_vendor_name          =>    NULL
    ,p_suggested_vendor_id            =>    NULL
    ,p_suggested_vendor_site          =>    NULL
    ,p_suggested_vendor_site_id       =>    NULL
    ,p_mat_inventory_item_id          =>    NULL
    ,p_mat_component_seq_num          =>    NULL
    ,p_mat_supply_subinventory        =>    NULL
    ,p_mat_supply_locator_id          =>    NULL
    ,p_di_amount                      =>    NULL
    ,p_di_order_type_lookup_code      =>    NULL
    ,p_di_description                 =>    NULL
    ,p_di_purchase_category_id        =>    NULL
    ,p_di_auto_request_material       =>    NULL
    ,p_di_need_by_date                =>    NULL
    ,p_work_order_line_cost           =>    l_unit_cost
    ,p_creation_date                  =>    sysdate
    ,p_created_by                     =>    FND_GLOBAL.LOGIN_ID
    ,p_last_update_date               =>    sysdate
    ,p_last_updated_by                =>    FND_GLOBAL.LOGIN_ID
    ,p_last_update_login              =>    FND_GLOBAL.LOGIN_ID
    ,p_work_order_type                =>    NULL
    ,p_activity_type                  =>    NULL
    ,p_activity_source                =>    NULL
    ,p_activity_cause                 =>    NULL
    ,p_available_qty                  =>    NULL
    ,p_item_comments                  =>    NULL
    ,p_cu_qty                         =>    NULL
    ,p_res_sch_flag                   =>    std_op_rec.SCHEDULE_FLAG
    );

  END LOOP; -- FOR std_op_rec IN STD_OP_RES_CUR LOOP
   x_return_status := 'S';
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    --ROLLBACK TO EXPLODE_STD_OP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   -- ROLLBACK TO EXPLODE_STD_OP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
   -- ROLLBACK TO EXPLODE_STD_OP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'EXPLODE_STD_OP');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data  => x_msg_data);
END EXPLODE_STD_OP;


PROCEDURE INSERT_ALL_WO_LINES(
    p_api_version                 IN  NUMBER        := 1.0
  , p_init_msg_list               IN  VARCHAR2      := FND_API.G_FALSE
  , p_commit                 IN VARCHAR2
  , p_estimate_id            IN NUMBER
  , p_eam_ce_wo_lines_tbl    IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_ce_tab_index    NUMBER := 0;
  l_cost_type_id    NUMBER := 0;
  l_cost_group_id 	NUMBER := 0;
  l_primary_cost_method NUMBER := 0;
  l_ext_precision  NUMBER := 0 ;
  l_return_status VARCHAR2(1);
  l_org_id NUMBER := 0;
  l_unit_cost NUMBER := 0;

  CURSOR GET_SYSTEM_STATUS (p_user_defined_status_id IN NUMBER) IS
    SELECT
    SYSTEM_STATUS
     FROM EAM_WO_STATUSES_V
    WHERE STATUS_ID = p_user_defined_status_id
  AND ENABLED_FLAG       = 'Y';

  l_system_status_rec     GET_SYSTEM_STATUS%ROWTYPE;

BEGIN

    SAVEPOINT INSERT_ALL_WO_LINES;
    debug('Total Count ' || p_eam_ce_wo_lines_tbl.COUNT);

    -- Get the Cost Type ID
    BEGIN
    IF p_eam_ce_wo_lines_tbl.COUNT > 0 THEN
    -- Get the org id from the first record
    l_org_id := p_eam_ce_wo_lines_tbl(1).ORGANIZATION_ID;

    SELECT NVL(MP.DEFAULT_COST_GROUP_ID,-1) ,
      DECODE (MP.PRIMARY_COST_METHOD, 1, MP.PRIMARY_COST_METHOD, NVL(MP.AVG_RATES_COST_TYPE_ID,-1)),
      MP.PRIMARY_COST_METHOD
      INTO l_cost_group_id, l_cost_type_id,
      l_primary_cost_method
      FROM MTL_PARAMETERS MP
      WHERE ORGANIZATION_ID = l_org_id;

     SELECT EXTENDED_PRECISION
      INTO l_ext_precision
      FROM FND_CURRENCIES FC,
      GL_SETS_OF_BOOKS SOB   ,
      HR_ORGANIZATION_INFORMATION HROI
      WHERE HROI.ORGANIZATION_ID     = l_org_id
      AND HROI.ORG_INFORMATION1        = TO_CHAR(SOB.SET_OF_BOOKS_ID)
      AND HROI.ORG_INFORMATION_CONTEXT = 'Accounting Information'
      AND SOB.CURRENCY_CODE         = FC.CURRENCY_CODE
      AND FC.ENABLED_FLAG           = 'Y';
    ELSE
      l_cost_type_id := 0 ;
      l_cost_group_id := 0;
      l_primary_cost_method := 0;
      l_ext_precision := 5;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
      l_cost_type_id := 0 ;
      l_cost_group_id := 0;
      l_primary_cost_method := 0;
      l_ext_precision := 5;
    END;

   IF p_eam_ce_wo_lines_tbl.COUNT > 0 THEN


    /*
    -- When new set of work order lines are being estimated
    -- The old WO lines needs to be deleted
    -- None of these operations are committed until saved
    --
    EAM_CE_WORK_ORDER_LINES_PKG.DELETE_ALL_WITH_ESTIMATE_ID(
      p_estimate_id  => p_estimate_id
    );
    */
    -- If the p_estimate_work_order_line_id exists then update the
    -- ce work order lines, else insert new row

    --EAM_CONSTRUCTION_MESSAGE_PVT.DUMP_CE_WO_TBL(
    --p_eam_ce_wo_lines_tbl => p_eam_ce_wo_lines_tbl);

    FOR l_ce_tab_index IN p_eam_ce_wo_lines_tbl.FIRST .. p_eam_ce_wo_lines_tbl.LAST
    LOOP

      -- Assigning unit cost before recalculating
      l_unit_cost := p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_LINE_COST;

      IF p_eam_ce_wo_lines_tbl(l_ce_tab_index).ESTIMATE_WORK_ORDER_LINE_ID IS NOT NULL THEN

        -- If the resource is modified the cost needs to be calcuated again
        IF NVL(p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
            -- Calculate Cost
            GET_UNIT_RESOURCE_COST(
              p_resource_id         => p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_ID
            , p_cost_type_id 				=> l_cost_type_id
            , p_ext_precision       => l_ext_precision
            , p_org_id   			      => p_eam_ce_wo_lines_tbl(l_ce_tab_index).ORGANIZATION_ID
            , x_unit_resource_value => l_unit_cost
            , x_return_status       => l_return_status
            );

            IF nvl(l_return_status,'S') <> 'S' THEN
              -- Log error, but continue processing
              x_return_status := 'E';
              RAISE FND_API.G_EXC_ERROR;
             END IF; -- nvl(l_return_status,'S') <> 'S'
        END IF;

        -- Get the system status from user defined status id
        BEGIN
          OPEN GET_SYSTEM_STATUS(p_eam_ce_wo_lines_tbl(l_ce_tab_index).USER_DEFINED_STATUS_ID);
          FETCH GET_SYSTEM_STATUS INTO l_system_status_rec;
          CLOSE GET_SYSTEM_STATUS;
        EXCEPTION
          WHEN OTHERS THEN
            l_system_status_rec.SYSTEM_STATUS := p_eam_ce_wo_lines_tbl(l_ce_tab_index).USER_DEFINED_STATUS_ID;
        END;

        -- Call UPDATE_ROW TO update the changes
        EAM_CE_WORK_ORDER_LINES_PKG.UPDATE_ROW(
         p_estimate_work_order_line_id    =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ESTIMATE_WORK_ORDER_LINE_ID
        ,p_estimate_work_order_id         =>    FND_API.G_MISS_NUM
        ,p_src_cu_id                      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_CU_ID
        ,p_src_activity_id                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_ACTIVITY_ID
        ,p_src_activity_qty               =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_ACTIVITY_QTY
        ,p_src_op_seq_num                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_OP_SEQ_NUM
        ,p_src_acct_class_code            =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_ACCT_CLASS_CODE
        ,p_src_diff_id                    =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DIFFICULTY_ID
        ,p_diff_qty                       =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DIFFICULTY_QTY
        ,p_estimate_id                    =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ESTIMATE_ID
        ,p_organization_id                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ORGANIZATION_ID
        ,p_work_order_seq_num             =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_SEQ_NUM
        ,p_work_order_number              =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_NUMBER
        ,p_work_order_description         =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_DESCRIPTION
        ,p_ref_wip_entity_id              =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).REF_WIP_ENTITY_ID
        ,p_primary_item_id                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).PRIMARY_ITEM_ID
        ,p_status_type                    =>    l_system_status_rec.SYSTEM_STATUS
        ,p_acct_class_code                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ACCT_CLASS_CODE
        ,p_scheduled_start_date           =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SCHEDULED_START_DATE
        ,p_scheduled_completion_date      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SCHEDULED_COMPLETION_DATE
        ,p_project_id                     =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).PROJECT_ID
        ,p_task_id                        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).TASK_ID
        ,p_maintenance_object_id          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAINTENANCE_OBJECT_ID
        ,p_maintenance_object_type        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAINTENANCE_OBJECT_TYPE
        ,p_maintenance_object_source      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAINTENANCE_OBJECT_SOURCE
        ,p_owning_department_id           =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OWNING_DEPARTMENT_ID
        ,p_user_defined_status_id         =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).USER_DEFINED_STATUS_ID
        ,p_op_seq_num                     =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OP_SEQ_NUM
        ,p_op_description                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OP_DESCRIPTION
        ,p_standard_operation_id          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).STANDARD_OPERATION_ID
        ,p_op_department_id               =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OP_DEPARTMENT_ID
        ,p_op_long_description            =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OP_LONG_DESCRIPTION
        ,p_res_seq_num                    =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_SEQ_NUM
        ,p_res_id                         =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_ID
        ,p_res_uom                        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_UOM
        ,p_res_basis_type                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_BASIS_TYPE
        ,p_res_usage_rate_or_amount       =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_USAGE_RATE_OR_AMOUNT
        ,p_res_required_units             =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_REQUIRED_UNITS
        ,p_res_assigned_units             =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_ASSIGNED_UNITS
        ,p_item_type                      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ITEM_TYPE
        ,p_required_quantity              =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).REQUIRED_QUANTITY
        ,p_unit_price                     =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).UNIT_PRICE
        ,p_uom                            =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).UOM
        ,p_basis_type                     =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).BASIS_TYPE
        ,p_suggested_vendor_name          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SUGGESTED_VENDOR_NAME
        ,p_suggested_vendor_id            =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SUGGESTED_VENDOR_ID
        ,p_suggested_vendor_site          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SUGGESTED_VENDOR_SITE
        ,p_suggested_vendor_site_id       =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SUGGESTED_VENDOR_SITE_ID
        ,p_mat_inventory_item_id          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAT_INVENTORY_ITEM_ID
        ,p_mat_component_seq_num          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAT_COMPONENT_SEQ_NUM
        ,p_mat_supply_subinventory        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAT_SUPPLY_SUBINVENTORY
        ,p_mat_supply_locator_id          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAT_SUPPLY_LOCATOR_ID
        ,p_di_amount                      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_AMOUNT
        ,p_di_order_type_lookup_code      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_ORDER_TYPE_LOOKUP_CODE
        ,p_di_description                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_DESCRIPTION
        ,p_di_purchase_category_id        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_PURCHASE_CATEGORY_ID
        ,p_di_auto_request_material       =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_AUTO_REQUEST_MATERIAL
        ,p_di_need_by_date                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_NEED_BY_DATE
        ,p_work_order_line_cost           =>    l_unit_cost
        ,p_creation_date                  =>    sysdate
        ,p_created_by                     =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_date               =>    sysdate
        ,p_last_updated_by                =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_login              =>    FND_GLOBAL.LOGIN_ID
        ,p_work_order_type                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_TYPE
        ,p_activity_type                  =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ACTIVITY_TYPE
        ,p_activity_source                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ACTIVITY_SOURCE
        ,p_activity_cause                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ACTIVITY_CAUSE
        ,p_available_qty                  =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).AVAILABLE_QUANTITY
        ,p_item_comments                  =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ITEM_COMMENTS
        ,p_cu_qty                         =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).CU_QTY
        ,p_res_sch_flag                   =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_SCHEDULED_FLAG
        );

      ELSE

        -- Assigning unit cost before recalculating
        l_unit_cost := p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_LINE_COST;

        -- If the resource is modified the cost needs to be calcuated again
        IF NVL(p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
            -- Calculate Cost
            GET_UNIT_RESOURCE_COST(
              p_resource_id         => p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_ID
            , p_cost_type_id 				=> l_cost_type_id
            , p_ext_precision       => l_ext_precision
            , p_org_id   			      => p_eam_ce_wo_lines_tbl(l_ce_tab_index).ORGANIZATION_ID
            , x_unit_resource_value => l_unit_cost
            , x_return_status       => l_return_status
            );

            IF nvl(l_return_status,'S') <> 'S' THEN
              -- Log error, but continue processing
              x_return_status := 'E';
              RAISE FND_API.G_EXC_ERROR;
             END IF; -- nvl(l_return_status,'S') <> 'S'
        END IF;

         -- Get the system status from user defined status id
        BEGIN
          OPEN GET_SYSTEM_STATUS(p_eam_ce_wo_lines_tbl(l_ce_tab_index).USER_DEFINED_STATUS_ID);
          FETCH GET_SYSTEM_STATUS INTO l_system_status_rec;
          CLOSE GET_SYSTEM_STATUS;
        EXCEPTION
          WHEN OTHERS THEN
            l_system_status_rec.SYSTEM_STATUS := p_eam_ce_wo_lines_tbl(l_ce_tab_index).USER_DEFINED_STATUS_ID;
        END;

        -- Call EAM_CE_WORK_ORDER_LINES_PKG.INSERT_ROW
        -- to insert wo line row

        EAM_CE_WORK_ORDER_LINES_PKG.INSERT_ROW(
         p_estimate_work_order_line_id    =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ESTIMATE_WORK_ORDER_LINE_ID
        ,p_estimate_work_order_id         =>    FND_API.G_MISS_NUM
        ,p_src_cu_id                      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_CU_ID
        ,p_src_activity_id                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_ACTIVITY_ID
        ,p_src_activity_qty               =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_ACTIVITY_QTY
        ,p_src_op_seq_num                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_OP_SEQ_NUM
        ,p_src_acct_class_code            =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SRC_ACCT_CLASS_CODE
        ,p_src_diff_id                    =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DIFFICULTY_ID
        ,p_diff_qty                       =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DIFFICULTY_QTY
        ,p_estimate_id                    =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ESTIMATE_ID
        ,p_organization_id                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ORGANIZATION_ID
        ,p_work_order_seq_num             =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_SEQ_NUM
        ,p_work_order_number              =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_NUMBER
        ,p_work_order_description         =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_DESCRIPTION
        ,p_ref_wip_entity_id              =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).REF_WIP_ENTITY_ID
        ,p_primary_item_id                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).PRIMARY_ITEM_ID
        ,p_status_type                    =>    l_system_status_rec.SYSTEM_STATUS
        ,p_acct_class_code                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ACCT_CLASS_CODE
        ,p_scheduled_start_date           =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SCHEDULED_START_DATE
        ,p_scheduled_completion_date      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SCHEDULED_COMPLETION_DATE
        ,p_project_id                     =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).PROJECT_ID
        ,p_task_id                        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).TASK_ID
        ,p_maintenance_object_id          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAINTENANCE_OBJECT_ID
        ,p_maintenance_object_type        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAINTENANCE_OBJECT_TYPE
        ,p_maintenance_object_source      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAINTENANCE_OBJECT_SOURCE
        ,p_owning_department_id           =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OWNING_DEPARTMENT_ID
        ,p_user_defined_status_id         =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).USER_DEFINED_STATUS_ID
        ,p_op_seq_num                     =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OP_SEQ_NUM
        ,p_op_description                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OP_DESCRIPTION
        ,p_standard_operation_id          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).STANDARD_OPERATION_ID
        ,p_op_department_id               =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OP_DEPARTMENT_ID
        ,p_op_long_description            =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).OP_LONG_DESCRIPTION
        ,p_res_seq_num                    =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_SEQ_NUM
        ,p_res_id                         =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_ID
        ,p_res_uom                        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_UOM
        ,p_res_basis_type                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_BASIS_TYPE
        ,p_res_usage_rate_or_amount       =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_USAGE_RATE_OR_AMOUNT
        ,p_res_required_units             =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_REQUIRED_UNITS
        ,p_res_assigned_units             =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_ASSIGNED_UNITS
        ,p_item_type                      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ITEM_TYPE
        ,p_required_quantity              =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).REQUIRED_QUANTITY
        ,p_unit_price                     =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).UNIT_PRICE
        ,p_uom                            =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).UOM
        ,p_basis_type                     =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).BASIS_TYPE
        ,p_suggested_vendor_name          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SUGGESTED_VENDOR_NAME
        ,p_suggested_vendor_id            =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SUGGESTED_VENDOR_ID
        ,p_suggested_vendor_site          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SUGGESTED_VENDOR_SITE
        ,p_suggested_vendor_site_id       =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).SUGGESTED_VENDOR_SITE_ID
        ,p_mat_inventory_item_id          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAT_INVENTORY_ITEM_ID
        ,p_mat_component_seq_num          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAT_COMPONENT_SEQ_NUM
        ,p_mat_supply_subinventory        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAT_SUPPLY_SUBINVENTORY
        ,p_mat_supply_locator_id          =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).MAT_SUPPLY_LOCATOR_ID
        ,p_di_amount                      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_AMOUNT
        ,p_di_order_type_lookup_code      =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_ORDER_TYPE_LOOKUP_CODE
        ,p_di_description                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_DESCRIPTION
        ,p_di_purchase_category_id        =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_PURCHASE_CATEGORY_ID
        ,p_di_auto_request_material       =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_AUTO_REQUEST_MATERIAL
        ,p_di_need_by_date                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).DI_NEED_BY_DATE
        ,p_work_order_line_cost           =>    l_unit_cost
        ,p_creation_date                  =>    sysdate
        ,p_created_by                     =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_date               =>    sysdate
        ,p_last_updated_by                =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_login              =>    FND_GLOBAL.LOGIN_ID
        ,p_work_order_type                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).WORK_ORDER_TYPE
        ,p_activity_type                  =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ACTIVITY_TYPE
        ,p_activity_source                =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ACTIVITY_SOURCE
        ,p_activity_cause                 =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ACTIVITY_CAUSE
        ,p_available_qty                  =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).AVAILABLE_QUANTITY
        ,p_item_comments                  =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).ITEM_COMMENTS
        ,p_cu_qty                         =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).CU_QTY
        ,p_res_sch_flag                   =>    p_eam_ce_wo_lines_tbl(l_ce_tab_index).RES_SCHEDULED_FLAG
        );
      END IF; -- p_eam_ce_wo_lines_tbl(l_ce_tab_index).ESTIMATE_WORK_ORDER_LINE_ID IS NOT NULL
    END LOOP;  -- l_ce_tab_index IN p_eam_ce_wo_lines_tbl.FIRST .. p_eam_ce_wo_lines_tbl.LAST
  END IF; --  p_eam_ce_wo_lines_tbl.COUNT > 0

  IF NVL(p_commit,'F') = 'T' THEN
    debug('Committing');
    COMMIT;
  END IF;
 x_return_status := 'S';
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INSERT_ALL_WO_LINES;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INSERT_ALL_WO_LINES;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO INSERT_ALL_WO_LINES;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'INSERT_ALL_WO_LINES');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data  => x_msg_data);
END INSERT_ALL_WO_LINES;

PROCEDURE EXPLODE_CE_ACTIVITIES(
      p_estimate_id             IN  NUMBER
    , p_eam_ce_wo_lines_tbl     IN  EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
    , x_eam_ce_wo_lines_tbl     OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
    , x_ce_msg_tbl              OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_MESSAGE_TBL
    , x_return_status           OUT NOCOPY VARCHAR2
)
IS
  l_eam_wo_rec                 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
  l_eam_op_tbl                 EAM_PROCESS_WO_PUB.eam_op_tbl_type;
  l_eam_op_network_tbl         EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
  l_eam_res_tbl                EAM_PROCESS_WO_PUB.eam_res_tbl_type;
  l_eam_res_inst_tbl           EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
  l_eam_sub_res_tbl            EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
  l_eam_res_usage_tbl          EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
  l_eam_mat_req_tbl            EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;

  l_out_eam_wo_rec             EAM_PROCESS_WO_PUB.eam_wo_rec_type;
  l_out_eam_op_tbl             EAM_PROCESS_WO_PUB.eam_op_tbl_type;
  l_out_eam_op_network_tbl     EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
  l_out_eam_res_tbl            EAM_PROCESS_WO_PUB.eam_res_tbl_type;
  l_out_eam_res_inst_tbl       EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
  l_out_eam_sub_res_tbl        EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
  l_out_eam_res_usage_tbl      EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
  l_out_eam_mat_req_tbl        EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;

  l_mesg_token_tbl             EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_ce_association_rec         EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_REC;

  l_return_status              VARCHAR2(1);
  l_estimate_id                NUMBER := p_estimate_id;
  l_eam_ce_wo_lines_tbl        EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL := p_eam_ce_wo_lines_tbl;
  x_upd_eam_ce_wo_lines_tbl    EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL;

  l_debug_filename             VARCHAR(50)           := G_DEBUG_FILENAME;
  l_debug                      VARCHAR2(1)           := 'N';

CURSOR ESTIMATION_ASSOCIATION_CSR IS
  SELECT  ESTIMATE_ASSOCIATION_ID,
          ORGANIZATION_ID,
          ESTIMATE_ID,
          CU_ID,
          ACCT_CLASS_CODE,
          ACTIVITY_ID,
          ACTIVITY_QTY,
          RESOURCE_MULTIPLIER,
          DIFFICULTY_ID,
          CU_QTY
FROM EAM_ESTIMATE_ASSOCIATIONS
WHERE ESTIMATE_ID = p_estimate_id;

BEGIN
  INIT_DEBUG(
    p_init_msg_list       => FND_API.G_TRUE,
    p_debug_filename      => l_debug_filename,
    p_debug_file_mode     => 'w',
    p_debug               => l_debug);

  IF (l_debug = 'Y') THEN
    DEBUG('Start EXPLODE_CE_ACTIVITIES');
  END IF;

  -- The cursor ESTIMATION_ASSOCIATION_CSR contains all the activity associated
  -- with the estimate. Loop through the acitivity to explode the resource,
  -- material.
  FOR l_estimation_association_rec IN ESTIMATION_ASSOCIATION_CSR
  LOOP
  -- Populate the work order record l_eam_wo_rec with activity id, organization id
  -- status
  IF (l_debug = 'Y') THEN
    DEBUG('Getting Values from the Cursor ESTIMATION_ASSOCIATION_CSR');
    DEBUG('l_estimation_association_rec.ACTIVITY_ID - ' || l_estimation_association_rec.ACTIVITY_ID);
  END IF;

  l_eam_wo_rec.asset_activity_id := l_estimation_association_rec.ACTIVITY_ID;
  l_eam_wo_rec.organization_id := l_estimation_association_rec.ORGANIZATION_ID;
  l_eam_wo_rec.scheduled_start_date := sysdate;
  l_eam_wo_rec.status_type := NULL;
  l_eam_wo_rec.alternate_bom_designator := NULL;

  -- Initializing resource, material tables
  -- This initialization is required as it clears our the records from
  -- previous EXPLODE_ACTIVITY call
  l_eam_op_tbl              := INIT_EAM_OP_TBL_TYPE;
  l_eam_op_network_tbl      := INIT_EAM_OP_NTK_TBL_TYPE;
  l_eam_res_tbl             := INIT_EAM_RES_TBL_TYPE;
  l_eam_res_inst_tbl        := INIT_EAM_RES_INST_TBL_TYPE;
  l_eam_sub_res_tbl         := INIT_EAM_SUB_RES_TBL_TYPE;
  l_eam_res_usage_tbl       := INIT_EAM_RES_USG_TBL_TYPE;
  l_eam_mat_req_tbl         := INIT_EAM_MAT_REQ_TBL_TYPE;

  -- Calling EAM_EXPLODE_ACTIVITY_PVT.EXPLODE_ACTIVITY to explode the activities
  EAM_EXPLODE_ACTIVITY_PVT.EXPLODE_ACTIVITY
    (  p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL
    ,  p_eam_wo_rec               =>  l_eam_wo_rec
    ,  p_eam_op_tbl               =>  l_eam_op_tbl
    ,  p_eam_op_network_tbl       =>  l_eam_op_network_tbl
    ,  p_eam_res_tbl              =>  l_eam_res_tbl
    ,  p_eam_res_inst_tbl         =>  l_eam_res_inst_tbl
    ,  p_eam_sub_res_tbl          =>  l_eam_sub_res_tbl
    ,  p_eam_res_usage_tbl        =>  l_eam_res_usage_tbl
    ,  p_eam_mat_req_tbl          =>  l_eam_mat_req_tbl
    ,  x_eam_wo_rec               =>  l_out_eam_wo_rec
    ,  x_eam_op_tbl               =>  l_out_eam_op_tbl
    ,  x_eam_op_network_tbl       =>  l_out_eam_op_network_tbl
    ,  x_eam_res_tbl              =>  l_out_eam_res_tbl
    ,  x_eam_res_inst_tbl         =>  l_out_eam_res_inst_tbl
    ,  x_eam_sub_res_tbl          =>  l_out_eam_sub_res_tbl
    ,  x_eam_res_usage_tbl        =>  l_out_eam_res_usage_tbl
    ,  x_eam_mat_req_tbl          =>  l_out_eam_mat_req_tbl
    ,  x_mesg_token_tbl           =>  l_mesg_token_tbl
    ,  x_return_status            =>  l_return_status
    );

   IF nvl(l_return_status,'S') <> 'S' THEN
    -- Log error, but continue processing
    l_return_status := 'E';
   END IF; -- nvl(l_return_status,'S') <> 'S'

   IF (l_debug = 'Y') THEN
     DEBUG('l_out_eam_op_tbl.count - ' || l_out_eam_op_tbl.count);
     DEBUG('l_out_eam_res_tbl.count - ' || l_out_eam_res_tbl.count);
     DEBUG('l_out_eam_mat_req_tbl.count - ' || l_out_eam_mat_req_tbl.count);
   END IF;

   -- Building the source association rec. This source association record
   -- contains the estimate id, cu id, activity id which resulted in the
   -- current resource, material explosion
   l_ce_association_rec.ESTIMATE_ID := l_estimation_association_rec.ESTIMATE_ID;
   l_ce_association_rec.ORGANIZATION_ID := l_estimation_association_rec.ORGANIZATION_ID;
   l_ce_association_rec.CU_ID := l_estimation_association_rec.CU_ID;
   l_ce_association_rec.ACCT_CLASS_CODE := l_estimation_association_rec.ACCT_CLASS_CODE;
   l_ce_association_rec.ACTIVITY_ID := l_estimation_association_rec.ACTIVITY_ID;
   l_ce_association_rec.ACTIVITY_QTY := l_estimation_association_rec.ACTIVITY_QTY;
   l_ce_association_rec.RESOURCE_MULTIPLIER := l_estimation_association_rec.RESOURCE_MULTIPLIER;
   l_ce_association_rec.DIFFICULTY_ID := l_estimation_association_rec.DIFFICULTY_ID;
   l_ce_association_rec.CU_QTY := l_estimation_association_rec.CU_QTY;

   -- Populate the WO lines table with the exploded operations and material
   -- table
   POPULATE_CE_WORK_ORDER_LINES(
      p_estimate_id             => l_estimate_id
    , p_ce_associatin_rec       => l_ce_association_rec
    , p_eam_ce_wo_lines_tbl     => l_eam_ce_wo_lines_tbl
    , p_eam_op_tbl              => l_out_eam_op_tbl
    , p_eam_op_network_tbl      => l_out_eam_op_network_tbl
    , p_eam_res_tbl             => l_out_eam_res_tbl
    , p_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
    , p_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
    , p_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
    , p_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
    , x_eam_ce_wo_lines_tbl     => x_upd_eam_ce_wo_lines_tbl
    , x_return_status           => l_return_status
  );

  IF nvl(l_return_status,'S') <> 'S' THEN
    -- Log error, but continue processing
    l_return_status := 'E';
   END IF; -- nvl(l_return_status,'S') <> 'S'

  -- Copying the output of POPULATE_CE_WORK_ORDER_LINES back in to the input
  -- so that the addition of operations/material lines is appended at the
  -- end of the work order lines
  l_eam_ce_wo_lines_tbl := x_upd_eam_ce_wo_lines_tbl;

  END LOOP; -- l_estimation_association_rec IN ESTIMATION_ASSOCIATION_CSR

   -- Log l_eam_ce_wo_lines_tbl entries
  --EAM_CONSTRUCTION_MESSAGE_PVT.DUMP_CE_WO_TBL(p_eam_ce_wo_lines_tbl => x_upd_eam_ce_wo_lines_tbl);

  -- Copy the exploded operations, resource, material table to the out params
  x_eam_ce_wo_lines_tbl := x_upd_eam_ce_wo_lines_tbl;
  x_return_status := 'S';

  -- Delete all the association entry
  DELETE FROM EAM_ESTIMATE_ASSOCIATIONS WHERE ESTIMATE_ID = p_estimate_id;

  IF (l_debug = 'Y') THEN
    DEBUG('End EXPLODE_CE_ACTIVITIES');
  END IF;
EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'E';
END EXPLODE_CE_ACTIVITIES;

PROCEDURE POPULATE_CE_WORK_ORDER_LINES(
      p_estimate_id             IN  NUMBER
    , p_ce_associatin_rec       IN  EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_REC
    , p_eam_ce_wo_lines_tbl     IN  EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
    , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
    , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
    , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
    , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
    , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
    , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
    , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
    , x_eam_ce_wo_lines_tbl     OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
    , x_return_status           OUT NOCOPY VARCHAR2)
IS

  l_eam_ce_wo_lines_tbl EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL;
  l_wo_lines_count  NUMBER := p_eam_ce_wo_lines_tbl.COUNT;
  l_op_tbl_count    NUMBER := p_eam_op_tbl.COUNT;
  l_res_tbl_count   NUMBER := p_eam_res_tbl.COUNT;
  l_mat_tbl_count   NUMBER := p_eam_mat_req_tbl.COUNT;

  l_wo_ind          NUMBER := 0;
  l_op_index        NUMBER := 0;
  l_res_index       NUMBER := 0;
  l_mat_index       NUMBER := 0;
  l_ce_tab_index    NUMBER := 0;
  l_cost_type_id    NUMBER := 0;
  l_cost_group_id 	NUMBER := 0;
  l_primary_cost_method NUMBER := 0;
  l_ext_precision  NUMBER := 0 ;
  l_return_status VARCHAR2(1);

BEGIN

  -- Populating the ce work order lines from the operations, material table
  -- The p_eam_ce_wo_lines_tbl contains the input work order lines
  l_eam_ce_wo_lines_tbl := p_eam_ce_wo_lines_tbl;
  l_wo_ind := l_wo_lines_count;

  debug('Populating Work Order Lines Table');

  -- Get the Cost Type ID
  BEGIN
	SELECT NVL(MP.DEFAULT_COST_GROUP_ID,-1) ,
		DECODE (MP.PRIMARY_COST_METHOD, 1, MP.PRIMARY_COST_METHOD, NVL(MP.AVG_RATES_COST_TYPE_ID,-1)),
		MP.PRIMARY_COST_METHOD
		INTO l_cost_group_id, l_cost_type_id,
		l_primary_cost_method
		FROM MTL_PARAMETERS MP
		WHERE ORGANIZATION_ID = p_ce_associatin_rec.ORGANIZATION_ID;

	 SELECT EXTENDED_PRECISION
		INTO l_ext_precision
		FROM FND_CURRENCIES FC,
		GL_SETS_OF_BOOKS SOB   ,
		HR_ORGANIZATION_INFORMATION HROI
		WHERE HROI.ORGANIZATION_ID     = p_ce_associatin_rec.ORGANIZATION_ID
		AND HROI.ORG_INFORMATION1        = TO_CHAR(SOB.SET_OF_BOOKS_ID)
		AND HROI.ORG_INFORMATION_CONTEXT = 'Accounting Information'
		AND SOB.CURRENCY_CODE         = FC.CURRENCY_CODE
		AND FC.ENABLED_FLAG           = 'Y';

  EXCEPTION
	WHEN OTHERS THEN
    l_cost_type_id := 0 ;
    l_cost_group_id := 0;
    l_primary_cost_method := 0;
    l_ext_precision := 5;
  END;

  -- Populating operations table
  IF l_op_tbl_count > 0 THEN
    FOR l_op_index IN p_eam_op_tbl.FIRST .. p_eam_op_tbl.LAST
    LOOP

    -- Populating the resources which are part of the same operation sequence
      IF l_res_tbl_count > 0 THEN
        FOR l_res_index IN p_eam_res_tbl.FIRST .. p_eam_res_tbl.LAST
        LOOP
          IF p_eam_res_tbl(l_res_index).OPERATION_SEQ_NUM = p_eam_op_tbl(l_op_index).OPERATION_SEQ_NUM THEN

            l_wo_ind := l_wo_ind + 1;

            l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_CU_ID       := p_ce_associatin_rec.CU_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_ACTIVITY_ID := p_ce_associatin_rec.ACTIVITY_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_ACTIVITY_QTY := p_ce_associatin_rec.ACTIVITY_QTY;
            l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_ACCT_CLASS_CODE := p_ce_associatin_rec.ACCT_CLASS_CODE;
            l_eam_ce_wo_lines_tbl(l_wo_ind).ORGANIZATION_ID := p_ce_associatin_rec.ORGANIZATION_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).ESTIMATE_ID := p_ce_associatin_rec.ESTIMATE_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).DIFFICULTY_QTY := p_ce_associatin_rec.RESOURCE_MULTIPLIER;
            l_eam_ce_wo_lines_tbl(l_wo_ind).DIFFICULTY_ID := p_ce_associatin_rec.DIFFICULTY_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).CU_QTY := p_ce_associatin_rec.CU_QTY;

            -- Defaulting Class Code to SRC_ACCT_CLASS_CODE
            l_eam_ce_wo_lines_tbl(l_wo_ind).ACCT_CLASS_CODE := p_ce_associatin_rec.ACCT_CLASS_CODE;

            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_SEQ_NUM := p_eam_op_tbl(l_op_index).OPERATION_SEQ_NUM;
            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_DESCRIPTION := p_eam_op_tbl(l_op_index).DESCRIPTION;
            l_eam_ce_wo_lines_tbl(l_wo_ind).STANDARD_OPERATION_ID := p_eam_op_tbl(l_op_index).STANDARD_OPERATION_ID;
            --l_eam_ce_wo_lines_tbl(l_wo_ind).STANDARD_OPERATION_ID := null;
            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_DEPARTMENT_ID := p_eam_op_tbl(l_op_index).DEPARTMENT_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_LONG_DESCRIPTION := p_eam_op_tbl(l_op_index).LONG_DESCRIPTION;

            -- Defaulting owning department id with operation department id
            l_eam_ce_wo_lines_tbl(l_wo_ind).OWNING_DEPARTMENT_ID := p_eam_op_tbl(l_op_index).DEPARTMENT_ID;

            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_SEQ_NUM := p_eam_op_tbl(l_op_index).OPERATION_SEQ_NUM;
            l_eam_ce_wo_lines_tbl(l_wo_ind).RES_SEQ_NUM := p_eam_res_tbl(l_res_index).RESOURCE_SEQ_NUM;
            l_eam_ce_wo_lines_tbl(l_wo_ind).RES_ID := p_eam_res_tbl(l_res_index).RESOURCE_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).RES_UOM := p_eam_res_tbl(l_res_index).UOM_CODE;
            l_eam_ce_wo_lines_tbl(l_wo_ind).RES_BASIS_TYPE := p_eam_res_tbl(l_res_index).BASIS_TYPE;
            l_eam_ce_wo_lines_tbl(l_wo_ind).RES_USAGE_RATE_OR_AMOUNT := p_eam_res_tbl(l_res_index).USAGE_RATE_OR_AMOUNT;
            --l_eam_ce_wo_lines_tbl(l_wo_ind).RES_REQUIRED_UNITS := p_eam_res_tbl(l_res_index).APPLIED_RESOURCE_UNITS;
            l_eam_ce_wo_lines_tbl(l_wo_ind).RES_ASSIGNED_UNITS := p_eam_res_tbl(l_res_index).ASSIGNED_UNITS;
            l_eam_ce_wo_lines_tbl(l_wo_ind).RES_SCHEDULED_FLAG := p_eam_res_tbl(l_res_index).SCHEDULED_FLAG;

            -- Calculate the total usuage amount
            l_eam_ce_wo_lines_tbl(l_wo_ind).REQUIRED_QUANTITY :=
              NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).CU_QTY,1) *
              NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).DIFFICULTY_QTY,1) *
              NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_ACTIVITY_QTY,1) *
              NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).RES_USAGE_RATE_OR_AMOUNT,1);

            -- Calculate Cost
            GET_UNIT_RESOURCE_COST(
              p_resource_id         => l_eam_ce_wo_lines_tbl(l_wo_ind).RES_ID
            , p_cost_type_id 				=> l_cost_type_id
            , p_ext_precision       => l_ext_precision
            , p_org_id   			      => p_ce_associatin_rec.ORGANIZATION_ID
            , x_unit_resource_value => l_eam_ce_wo_lines_tbl(l_wo_ind).WORK_ORDER_LINE_COST
            , x_return_status       => l_return_status
            );

            IF nvl(l_return_status,'S') <> 'S' THEN
              -- Log error, but continue processing
              x_return_status := 'E';
              RAISE FND_API.G_EXC_ERROR;
             END IF; -- nvl(l_return_status,'S') <> 'S'

            --l_wo_ind := l_wo_ind + 1;
          END IF; -- p_eam_res_tbl(l_res_index).OPERATION_SEQ_NUM = p_eam_op_tbl(l_op_index).OPERATION_SEQ_NUM
        END LOOP; -- l_res_index IN p_eam_res_tbl.FIRST .. p_eam_res_tbl.LAST
      END IF; -- l_res_tbl_count > 0

      -- Need to determine the following attributes
      -- UOM
      -- ITEM_TYPE
      -- BASIS_TYPE
      -- SUGGESTED_VENDOR_SITE
      -- SUGGESTED_VENDOR_SITE_ID
      -- DI_AMOUNT
      -- DI_ORDER_TYPE_LOOKUP_CODE
      -- DI_DESCRIPTION
      -- DI_PURCHASE_CATEGORY_ID
      -- WORK_ORDER_LINE_COST

      -- Populating the material req which are part of the same operation sequence
      debug('Total Number Material Requirements Entry - ' || l_mat_tbl_count);
      IF l_mat_tbl_count > 0 THEN
        FOR l_mat_index IN p_eam_mat_req_tbl.FIRST .. p_eam_mat_req_tbl.LAST
        LOOP
          IF p_eam_mat_req_tbl(l_mat_index).OPERATION_SEQ_NUM = p_eam_op_tbl(l_op_index).OPERATION_SEQ_NUM THEN

            l_wo_ind := l_wo_ind + 1;

            l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_CU_ID       := p_ce_associatin_rec.CU_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_ACTIVITY_ID := p_ce_associatin_rec.ACTIVITY_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_ACTIVITY_QTY := p_ce_associatin_rec.ACTIVITY_QTY;
            l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_ACCT_CLASS_CODE := p_ce_associatin_rec.ACCT_CLASS_CODE;
            l_eam_ce_wo_lines_tbl(l_wo_ind).ORGANIZATION_ID := p_ce_associatin_rec.ORGANIZATION_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).ESTIMATE_ID := p_ce_associatin_rec.ESTIMATE_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).DIFFICULTY_QTY := p_ce_associatin_rec.RESOURCE_MULTIPLIER;
            l_eam_ce_wo_lines_tbl(l_wo_ind).DIFFICULTY_ID := p_ce_associatin_rec.DIFFICULTY_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).CU_QTY := p_ce_associatin_rec.CU_QTY;
            -- Defaulting Class Code to SRC_ACCT_CLASS_CODE
            l_eam_ce_wo_lines_tbl(l_wo_ind).ACCT_CLASS_CODE := p_ce_associatin_rec.ACCT_CLASS_CODE;

            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_SEQ_NUM := p_eam_op_tbl(l_op_index).OPERATION_SEQ_NUM;
            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_DESCRIPTION := p_eam_op_tbl(l_op_index).DESCRIPTION;
            l_eam_ce_wo_lines_tbl(l_wo_ind).STANDARD_OPERATION_ID := p_eam_op_tbl(l_op_index).STANDARD_OPERATION_ID;
            --l_eam_ce_wo_lines_tbl(l_wo_ind).STANDARD_OPERATION_ID := null;
            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_DEPARTMENT_ID := p_eam_op_tbl(l_op_index).DEPARTMENT_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_LONG_DESCRIPTION := p_eam_op_tbl(l_op_index).LONG_DESCRIPTION;

            -- Defaulting owning department id with operation department id
            l_eam_ce_wo_lines_tbl(l_wo_ind).OWNING_DEPARTMENT_ID := p_eam_op_tbl(l_op_index).DEPARTMENT_ID;

            l_eam_ce_wo_lines_tbl(l_wo_ind).OP_SEQ_NUM := p_eam_op_tbl(l_op_index).OPERATION_SEQ_NUM;
            l_eam_ce_wo_lines_tbl(l_wo_ind).RES_USAGE_RATE_OR_AMOUNT := p_eam_mat_req_tbl(l_mat_index).QUANTITY_PER_ASSEMBLY;
            --l_eam_ce_wo_lines_tbl(l_wo_ind).REQUIRED_QUANTITY := p_eam_mat_req_tbl(l_mat_index).REQUIRED_QUANTITY;
            l_eam_ce_wo_lines_tbl(l_wo_ind).UNIT_PRICE := p_eam_mat_req_tbl(l_mat_index).UNIT_PRICE;
            l_eam_ce_wo_lines_tbl(l_wo_ind).SUGGESTED_VENDOR_NAME := p_eam_mat_req_tbl(l_mat_index).SUGGESTED_VENDOR_NAME;
            l_eam_ce_wo_lines_tbl(l_wo_ind).MAT_INVENTORY_ITEM_ID := p_eam_mat_req_tbl(l_mat_index).INVENTORY_ITEM_ID;

            IF (EAM_WL_UTIL_PKG.IS_STOCK_ENABLE(
              p_inventory_item_id => l_eam_ce_wo_lines_tbl(l_wo_ind).MAT_INVENTORY_ITEM_ID,
              p_organization_id   => p_ce_associatin_rec.ORGANIZATION_ID) = 'Y' ) THEN
              -- Stocked Inventory
              l_eam_ce_wo_lines_tbl(l_wo_ind).ITEM_TYPE := 1;
            ELSE -- Non Stock Direct
              l_eam_ce_wo_lines_tbl(l_wo_ind).ITEM_TYPE := 2;
            END IF; -- Stock enabled


            l_eam_ce_wo_lines_tbl(l_wo_ind).MAT_COMPONENT_SEQ_NUM := p_eam_mat_req_tbl(l_mat_index).COMPONENT_SEQUENCE_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).MAT_SUPPLY_SUBINVENTORY := p_eam_mat_req_tbl(l_mat_index).SUPPLY_SUBINVENTORY;
            l_eam_ce_wo_lines_tbl(l_wo_ind).MAT_SUPPLY_LOCATOR_ID := p_eam_mat_req_tbl(l_mat_index).VENDOR_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).SUGGESTED_VENDOR_ID := p_eam_mat_req_tbl(l_mat_index).SUPPLY_LOCATOR_ID;
            l_eam_ce_wo_lines_tbl(l_wo_ind).DI_AUTO_REQUEST_MATERIAL := p_eam_mat_req_tbl(l_mat_index).AUTO_REQUEST_MATERIAL;
            l_eam_ce_wo_lines_tbl(l_wo_ind).MAT_SUPPLY_LOCATOR_ID := p_eam_mat_req_tbl(l_mat_index).SUPPLY_LOCATOR_ID;

            l_eam_ce_wo_lines_tbl(l_wo_ind).REQUIRED_QUANTITY :=
              NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).CU_QTY,1) *
              NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).SRC_ACTIVITY_QTY,1) *
              NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).RES_USAGE_RATE_OR_AMOUNT,1);

            -- Calculate Cost based on the item type
            IF NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).ITEM_TYPE, '1') = 1 THEN

                GET_UNIT_STOCKED_MAT_COST(
                  p_inv_id            => l_eam_ce_wo_lines_tbl(l_wo_ind).MAT_INVENTORY_ITEM_ID
                , p_cost_method 			=> l_primary_cost_method
                , p_cost_group_id 		=> l_cost_group_id
                , p_org_id   			    => p_ce_associatin_rec.ORGANIZATION_ID
                , p_ext_precision  		=> l_ext_precision
                , x_unit_mat_value    => l_eam_ce_wo_lines_tbl(l_wo_ind).WORK_ORDER_LINE_COST
                , x_return_status     => l_return_status
                );

            ELSIF NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).ITEM_TYPE, '1') = 2 THEN

                GET_UNIT_NON_STOCKED_MAT_COST(
                  p_inv_id            => l_eam_ce_wo_lines_tbl(l_wo_ind).MAT_INVENTORY_ITEM_ID
                , p_org_id   			    => p_ce_associatin_rec.ORGANIZATION_ID
                , p_ext_precision  		=> l_ext_precision
                , x_unit_mat_value    => l_eam_ce_wo_lines_tbl(l_wo_ind).WORK_ORDER_LINE_COST
                , x_return_status     => l_return_status
                );

            END IF; -- NVL(l_eam_ce_wo_lines_tbl(l_wo_ind).ITEM_TYPE, '1')

            IF nvl(l_return_status,'S') <> 'S' THEN
              -- Log error, but continue processing
              x_return_status := 'E';
              RAISE FND_API.G_EXC_ERROR;
             END IF; -- nvl(l_return_status,'S') <> 'S'

            --l_wo_ind := l_wo_ind + 1;
          END IF; --p_eam_mat_req_tbl(l_mat_index).OPERATION_SEQ_NUM = p_eam_op_tbl(l_op_index).OPERATION_SEQ_NUM
        END LOOP; -- l_mat_index IN p_eam_mat_req_tbl.FIRST .. p_eam_mat_req_tbl.LAST
      END IF; -- l_mat_tbl_count > 0

   END LOOP; -- l_op_index IN p_eam_op_tbl.FIRST .. p_eam_op_tbl.LAST
  END IF; -- l_op_tbl_count > 0

  -- This block populates the common attributes for all the work order lines
  -- Also once all the attribute are populated, it calles
  -- EAM_CE_WORK_ORDER_LINES_PKG.INSERT_ROW
 /* IF l_wo_ind > 0 THEN
    FOR l_ce_tab_index IN l_eam_ce_wo_lines_tbl.FIRST .. l_eam_ce_wo_lines_tbl.LAST
    LOOP


      -- Following not moified
      --l_eam_ce_wo_lines_tbl(l_wo_ind).WORK_ORDER_SEQ_NUM := NULL;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).WORK_ORDER_NUMBER := NULL;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).WORK_ORDER_DESCRIPTION := NULL;

      --l_eam_ce_wo_lines_tbl(l_wo_ind).PRIMARY_ITEM_ID := NULL;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).STATUS_TYPE := NULL;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).ACCT_CLASS_CODE := NULL;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).SCHEDULED_START_DATE := p_ce_associatin_rec.ESTIMATE_ID;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).SCHEDULED_COMPLETION_DATE := p_ce_associatin_rec.ESTIMATE_ID;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).PROJECT_ID := p_ce_associatin_rec.ESTIMATE_ID;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).TASK_ID := p_ce_associatin_rec.ESTIMATE_ID;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).MAINTENANCE_OBJECT_ID := p_ce_associatin_rec.ESTIMATE_ID;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).MAINTENANCE_OBJECT_TYPE := p_ce_associatin_rec.ESTIMATE_ID;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).MAINTENANCE_OBJECT_SOURCE := p_ce_associatin_rec.ESTIMATE_ID;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).OWNING_DEPARTMENT_ID := p_ce_associatin_rec.ESTIMATE_ID;
      --l_eam_ce_wo_lines_tbl(l_wo_ind).USER_DEFINED_STATUS_ID       := p_ce_associatin_rec.CU_ID;

    END LOOP;  -- l_ce_tab_index IN p_eam_ce_wo_lines_tbl.FIRST .. p_eam_ce_wo_lines_tbl.LAST
  END IF; --  l_wo_ind > 0
  */
  -- debug('Done populating Work Order Lines table');

  -- Copy the output table
  x_eam_ce_wo_lines_tbl := l_eam_ce_wo_lines_tbl;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := 'E';
  debug('In to FND_API.G_EXC_ERROR in POPULATE_CE_WORK_ORDER_LINES');
WHEN OTHERS THEN
  x_return_status := 'E';
  debug('In to Others exception in POPULATE_CE_WORK_ORDER_LINES');
END POPULATE_CE_WORK_ORDER_LINES;

FUNCTION INIT_EAM_OP_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_op_tbl_type
  IS
  l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
  BEGIN
    RETURN l_eam_op_tbl;
END INIT_EAM_OP_TBL_TYPE;

FUNCTION INIT_EAM_OP_NTK_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
  IS
  l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
  BEGIN
    RETURN l_eam_op_network_tbl;
END INIT_EAM_OP_NTK_TBL_TYPE;

FUNCTION INIT_EAM_RES_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_res_tbl_type
  IS
  l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
  BEGIN
    RETURN l_eam_res_tbl;
END INIT_EAM_RES_TBL_TYPE;

FUNCTION INIT_EAM_RES_INST_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
  IS
  l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
  BEGIN
    RETURN l_eam_res_inst_tbl;
END INIT_EAM_RES_INST_TBL_TYPE;

FUNCTION INIT_EAM_SUB_RES_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
  IS
  l_eam_sub_res_tbl  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
  BEGIN
    RETURN l_eam_sub_res_tbl;
END INIT_EAM_SUB_RES_TBL_TYPE;

FUNCTION INIT_EAM_RES_USG_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
  IS
  l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
  BEGIN
    RETURN l_eam_res_usage_tbl;
END INIT_EAM_RES_USG_TBL_TYPE;

FUNCTION INIT_EAM_MAT_REQ_TBL_TYPE RETURN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
  IS
  l_eam_mat_req_tbl  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
  BEGIN
    RETURN l_eam_mat_req_tbl;
END INIT_EAM_MAT_REQ_TBL_TYPE;

PROCEDURE GET_CU_RECS(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_org_id            IN NUMBER,
          px_cu_tbl           IN OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_UNITS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'GET_CU_RECS';
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_debug_filename      VARCHAR(50)           := G_DEBUG_FILENAME;
  l_debug               VARCHAR2(1)           := 'N';
  l_index               NUMBER                := 0;
BEGIN
  SAVEPOINT GET_CU_RECS;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.INITIALIZE;
  END IF;

  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INIT_DEBUG(
    p_init_msg_list       => p_init_msg_list,
    p_debug_filename      => l_debug_filename,
    p_debug_file_mode     => 'W',
    p_debug               => l_debug);

  IF (l_debug = 'Y') THEN
    DEBUG('GET_CU_RECS '  ||
      p_api_version       ||'-'||
      p_commit            ||'-'||
      p_init_msg_list     ||'-'||
      p_validation_level);
    DEBUG('Organization ID : ' || p_org_id);
  END IF;

  IF px_cu_tbl.COUNT > 0 THEN
    l_index := 0;
    WHILE l_index < px_cu_tbl.COUNT LOOP
      BEGIN
        l_index := l_index + 1;
        SELECT CU_NAME,
               DESCRIPTION,
               ORGANIZATION_ID,
               CU_EFFECTIVE_FROM,
               CU_EFFECTIVE_TO
        INTO   px_cu_tbl(l_index).CU_NAME,
               px_cu_tbl(l_index).DESCRIPTION,
               px_cu_tbl(l_index).ORGANIZATION_ID,
               px_cu_tbl(l_index).CU_EFFECTIVE_FROM,
               px_cu_tbl(l_index).CU_EFFECTIVE_TO
        FROM   EAM_CONSTRUCTION_UNITS
        WHERE  CU_ID = px_cu_tbl(l_index).CU_ID
        AND    ORGANIZATION_ID = p_org_id
        AND    CU_EFFECTIVE_FROM <= SYSDATE
        AND    (CU_EFFECTIVE_TO IS NULL OR CU_EFFECTIVE_TO > SYSDATE);

        IF (l_debug = 'Y') THEN
          DEBUG('CU record ' || l_index);
          DEBUG(' CU_ID                : ' || px_cu_tbl(l_index).CU_ID);
          DEBUG(' CU_NAME              : ' || px_cu_tbl(l_index).CU_NAME);
          DEBUG(' DESCRIPTION          : ' || px_cu_tbl(l_index).DESCRIPTION);
          DEBUG(' ORGANIZATION_ID      : ' || px_cu_tbl(l_index).ORGANIZATION_ID);
          DEBUG(' CU_EFFECTIVE_FROM    : ' || px_cu_tbl(l_index).CU_EFFECTIVE_FROM);
          DEBUG(' CU_EFFECTIVE_TO      : ' || px_cu_tbl(l_index).CU_EFFECTIVE_TO);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('EAM','EAM_INVALID_CU_ID');
          FND_MESSAGE.SET_TOKEN('CU_ID', px_cu_tbl(l_index).CU_ID);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END;
    END LOOP;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO GET_CU_RECS;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO GET_CU_RECS;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO GET_CU_RECS;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
END GET_CU_RECS;

PROCEDURE GET_CU_ACTIVITIES(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_cu_id             IN NUMBER,
          x_activities_tbl    OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  CURSOR cu_activities_cur IS
    SELECT ECU.CU_ID,
           ECU.ORGANIZATION_ID,
           ECUD.ACCT_CLASS_CODE,
           ECUD.ACTIVITY_ID,
           ECUD.CU_ACTIVITY_QTY
    FROM   EAM_CONSTRUCTION_UNITS ECU,
           EAM_CONSTRUCTION_UNIT_DETAILS ECUD
    WHERE  ECU.CU_ID = p_cu_id
    AND    ECU.CU_ID = ECUD.CU_ID
    AND    ECU.CU_EFFECTIVE_FROM < SYSDATE + 1
    AND    (ECU.CU_EFFECTIVE_TO IS NULL OR ECU.CU_EFFECTIVE_TO > SYSDATE)
    AND    (ECUD.CU_ACTIVITY_EFFECTIVE_TO IS NULL OR ECUD.CU_ACTIVITY_EFFECTIVE_TO > SYSDATE);

  l_api_name            CONSTANT VARCHAR2(30) := 'GET_CU_ACTIVITIES';
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_debug_filename      VARCHAR(50)           := G_DEBUG_FILENAME;
  l_debug               VARCHAR2(1)           := 'N';
  l_activity_count      NUMBER                := 0;
  l_activities_rec      EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_REC;
BEGIN
  SAVEPOINT GET_CU_ACTIVITIES;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.INITIALIZE;
  END IF;

  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INIT_DEBUG(
    p_init_msg_list       => p_init_msg_list,
    p_debug_filename      => l_debug_filename,
    p_debug_file_mode     => 'W',
    p_debug               => l_debug);

  IF (l_debug = 'Y') THEN
    DEBUG('GET_CU_ACTIVITIES ' ||
           p_api_version       ||'-'||
           p_commit            ||'-'||
           p_init_msg_list     ||'-'||
           p_validation_level);
    DEBUG('Construction Unit ID : ' || p_cu_id);
  END IF;

  FOR cu_activity_rec IN cu_activities_cur
  LOOP
    l_activity_count := l_activity_count + 1;

    l_activities_rec.CU_ID               := cu_activity_rec.CU_ID;
    l_activities_rec.CU_QTY              := NULL;
    l_activities_rec.ORGANIZATION_ID     := cu_activity_rec.ORGANIZATION_ID;
    l_activities_rec.ACCT_CLASS_CODE     := cu_activity_rec.ACCT_CLASS_CODE;
    l_activities_rec.ACTIVITY_ID         := cu_activity_rec.ACTIVITY_ID;
    l_activities_rec.ACTIVITY_QTY        := cu_activity_rec.CU_ACTIVITY_QTY;

    IF l_activities_rec.CU_ID IS NOT NULL THEN
      BEGIN
        SELECT CU_NAME,
               DESCRIPTION
        INTO   l_activities_rec.CU_NAME,
               l_activities_rec.CU_DESCRIPTION
        FROM   EAM_CONSTRUCTION_UNITS
        WHERE  CU_ID = l_activities_rec.CU_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    IF l_activities_rec.ACTIVITY_ID IS NOT NULL THEN
      BEGIN
        SELECT CONCATENATED_SEGMENTS,
               DESCRIPTION
        INTO   l_activities_rec.ACTIVITY_NAME,
               l_activities_rec.ACTIVITY_DESCRIPTION
        FROM   MTL_SYSTEM_ITEMS_KFV
        WHERE  INVENTORY_ITEM_ID = l_activities_rec.ACTIVITY_ID
        AND    ORGANIZATION_ID = l_activities_rec.ORGANIZATION_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    x_activities_tbl(l_activity_count)   := l_activities_rec;

    IF (l_debug = 'Y') THEN
      DEBUG('CU activity ' || l_activity_count);
      DEBUG(' CU_ID                : ' || x_activities_tbl(l_activity_count).CU_ID);
      DEBUG(' CU_QTY               : ' || x_activities_tbl(l_activity_count).CU_QTY);
      DEBUG(' CU_NAME              : ' || x_activities_tbl(l_activity_count).CU_NAME);
      DEBUG(' CU_DESCRIPTION       : ' || x_activities_tbl(l_activity_count).CU_DESCRIPTION);
      DEBUG(' ORGANIZATION_ID      : ' || x_activities_tbl(l_activity_count).ORGANIZATION_ID);
      DEBUG(' ACCT_CLASS_CODE      : ' || x_activities_tbl(l_activity_count).ACCT_CLASS_CODE);
      DEBUG(' ACTIVITY_ID          : ' || x_activities_tbl(l_activity_count).ACTIVITY_ID);
      DEBUG(' ACTIVITY_NAME        : ' || x_activities_tbl(l_activity_count).ACTIVITY_NAME);
      DEBUG(' ACTIVITY_DESCRIPTION : ' || x_activities_tbl(l_activity_count).ACTIVITY_DESCRIPTION);
      DEBUG(' ACTIVITY_QTY         : ' || x_activities_tbl(l_activity_count).ACTIVITY_QTY);
      DEBUG(' DIFFICULTY_ID        : ' || x_activities_tbl(l_activity_count).DIFFICULTY_ID);
      DEBUG(' RESOURCE_MULTIPLIER  : ' || x_activities_tbl(l_activity_count).RESOURCE_MULTIPLIER);
    END IF;
  END LOOP;

  IF (l_debug = 'Y') THEN
    DEBUG('x_return_status : ' || x_return_status);
    DEBUG('x_msg_count     : ' || x_msg_count);
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO GET_CU_ACTIVITIES;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO GET_CU_ACTIVITIES;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO GET_CU_ACTIVITIES;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
END GET_CU_ACTIVITIES;

PROCEDURE CREATE_ESTIMATE(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          px_estimate_rec     IN OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_ESTIMATE';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_debug_filename        VARCHAR(50)           := G_DEBUG_FILENAME;
  l_debug                 VARCHAR2(1)           := 'N';
  l_creation_date         DATE                  := SYSDATE;
  l_created_by            NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_date     DATE                  := SYSDATE;
  l_last_updated_by       NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_login    NUMBER;
  l_estimate_exist        VARCHAR2(1)           := 'N';
BEGIN
  SAVEPOINT CREATE_ESTIMATE;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.INITIALIZE;
  END IF;

  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INIT_DEBUG(
    p_init_msg_list       => p_init_msg_list,
    p_debug_filename      => l_debug_filename,
    p_debug_file_mode     => 'W',
    p_debug               => l_debug);

  IF (l_debug = 'Y') THEN
    DEBUG('CREATE_ESTIMATE ' ||
           p_api_version       ||'-'||
           p_commit            ||'-'||
           p_init_msg_list     ||'-'||
           p_validation_level);
    DEBUG('ESTIMATE_ID           : ' || px_estimate_rec.ESTIMATE_ID);
    DEBUG('ORGANIZATION_ID       : ' || px_estimate_rec.ORGANIZATION_ID);
    DEBUG('ESTIMATE_NUMBER       : ' || px_estimate_rec.ESTIMATE_NUMBER);
    DEBUG('ESTIMATE_DESCRIPTION  : ' || px_estimate_rec.ESTIMATE_DESCRIPTION);
    DEBUG('GROUPING_OPTION       : ' || px_estimate_rec.GROUPING_OPTION);
    DEBUG('PARENT_WO_ID          : ' || px_estimate_rec.PARENT_WO_ID);
    DEBUG('CREATE_PARENT_WO_FLAG : ' || px_estimate_rec.CREATE_PARENT_WO_FLAG);
  END IF;

  IF (px_estimate_rec.ORGANIZATION_ID IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ORGANIZATION_ID');
    FND_MESSAGE.SET_TOKEN('VALUE', px_estimate_rec.ORGANIZATION_ID);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (px_estimate_rec.ESTIMATE_NUMBER IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ESTIMATE_NUMBER');
    FND_MESSAGE.SET_TOKEN('VALUE', px_estimate_rec.ESTIMATE_NUMBER);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    BEGIN
      SELECT 'Y'
      INTO   l_estimate_exist
      FROM   EAM_CONSTRUCTION_ESTIMATES
      WHERE  ESTIMATE_NUMBER = px_estimate_rec.ESTIMATE_NUMBER
      AND    ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_estimate_exist := 'N';
    END;
    IF l_estimate_exist = 'Y' THEN
      FND_MESSAGE.SET_NAME('EAM','EAM_ESTIMATE_NAME_UNIQUE');
      FND_MESSAGE.SET_TOKEN('ESTIMATE_NAME', px_estimate_rec.ESTIMATE_NUMBER);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  EAM_CONSTRUCTION_ESTIMATES_PKG.INSERT_ROW(
      px_ESTIMATE_ID              => px_estimate_rec.ESTIMATE_ID,
      p_ORGANIZATION_ID           => px_estimate_rec.ORGANIZATION_ID,
      p_ESTIMATE_NUMBER           => px_estimate_rec.ESTIMATE_NUMBER,
      p_ESTIMATE_DESCRIPTION      => px_estimate_rec.ESTIMATE_DESCRIPTION,
      p_GROUPING_OPTION           => px_estimate_rec.GROUPING_OPTION,
      p_PARENT_WO_ID              => px_estimate_rec.PARENT_WO_ID,
      p_CREATE_PARENT_WO_FLAG     => px_estimate_rec.CREATE_PARENT_WO_FLAG,
      p_CREATION_DATE             => l_creation_date,
      p_CREATED_BY                => l_created_by,
      p_LAST_UPDATE_DATE          => l_last_updated_date,
      p_LAST_UPDATED_BY           => l_last_updated_by,
      p_LAST_UPDATE_LOGIN         => l_last_updated_login,
      p_ATTRIBUTE_CATEGORY        => px_estimate_rec.attribute_category,
		  p_ATTRIBUTE1                => px_estimate_rec.attribute1,
		  p_ATTRIBUTE2                => px_estimate_rec.attribute2,
		  p_ATTRIBUTE3                => px_estimate_rec.attribute3,
		  p_ATTRIBUTE4                => px_estimate_rec.attribute4,
		  p_ATTRIBUTE5                => px_estimate_rec.attribute5,
		  p_ATTRIBUTE6                => px_estimate_rec.attribute6,
		  p_ATTRIBUTE7                => px_estimate_rec.attribute7,
		  p_ATTRIBUTE8                => px_estimate_rec.attribute8,
		  p_ATTRIBUTE9                => px_estimate_rec.attribute9,
		  p_ATTRIBUTE10               => px_estimate_rec.attribute10,
		  p_ATTRIBUTE11               => px_estimate_rec.attribute11,
		  p_ATTRIBUTE12               => px_estimate_rec.attribute12,
		  p_ATTRIBUTE13               => px_estimate_rec.attribute13,
		  p_ATTRIBUTE14               => px_estimate_rec.attribute14,
		  p_ATTRIBUTE15     		      => px_estimate_rec.attribute15
      );

  IF (l_debug = 'Y') THEN
    DEBUG('Created estimate with ID : ' || px_estimate_rec.ESTIMATE_ID);
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (l_debug = 'Y') THEN
    DEBUG('x_return_status : ' || x_return_status);
    DEBUG('x_msg_count     : ' || x_msg_count);
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO CREATE_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
END CREATE_ESTIMATE;

PROCEDURE UPDATE_ESTIMATE(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_estimate_rec      IN EAM_EST_DATASTRUCTURES_PUB.EAM_CONSTRUCTION_ESTIMATE_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_ESTIMATE';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_debug_filename        VARCHAR(50)           := G_DEBUG_FILENAME;
  l_debug                 VARCHAR2(1)           := 'N';
  l_creation_date         DATE                  := SYSDATE;
  l_created_by            NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_date     DATE                  := SYSDATE;
  l_last_updated_by       NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_login    NUMBER;
  l_estimate_exist        VARCHAR2(1)           := 'N';
  l_parent_creation_flag VARCHAR(1) := FND_API.G_MISS_CHAR;
  l_parent_wo_id NUMBER := FND_API.G_MISS_NUM;

BEGIN
  SAVEPOINT UPDATE_ESTIMATE;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.INITIALIZE;
  END IF;

  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INIT_DEBUG(
    p_init_msg_list       => p_init_msg_list,
    p_debug_filename      => l_debug_filename,
    p_debug_file_mode     => 'W',
    p_debug               => l_debug);

  IF (l_debug = 'Y') THEN
    DEBUG('UPDATE_ESTIMATE ' ||
           p_api_version       ||'-'||
           p_commit            ||'-'||
           p_init_msg_list     ||'-'||
           p_validation_level);
    DEBUG('ESTIMATE_ID           : ' || p_estimate_rec.ESTIMATE_ID);
    DEBUG('ORGANIZATION_ID       : ' || p_estimate_rec.ORGANIZATION_ID);
    DEBUG('ESTIMATE_NUMBER       : ' || p_estimate_rec.ESTIMATE_NUMBER);
    DEBUG('ESTIMATE_DESCRIPTION  : ' || p_estimate_rec.ESTIMATE_DESCRIPTION);
    DEBUG('GROUPING_OPTION       : ' || p_estimate_rec.GROUPING_OPTION);
    DEBUG('PARENT_WO_ID          : ' || p_estimate_rec.PARENT_WO_ID);
    DEBUG('CREATE_PARENT_WO_FLAG : ' || p_estimate_rec.CREATE_PARENT_WO_FLAG);
  END IF;

  IF (p_estimate_rec.ESTIMATE_ID IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ESTIMATE_ID');
    FND_MESSAGE.SET_TOKEN('VALUE', p_estimate_rec.ESTIMATE_ID);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_estimate_rec.ORGANIZATION_ID IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ORGANIZATION_ID');
    FND_MESSAGE.SET_TOKEN('VALUE', p_estimate_rec.ORGANIZATION_ID);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_estimate_rec.ESTIMATE_NUMBER IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ESTIMATE_NUMBER');
    FND_MESSAGE.SET_TOKEN('VALUE', p_estimate_rec.ESTIMATE_NUMBER);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    BEGIN
      SELECT 'Y'
      INTO   l_estimate_exist
      FROM   EAM_CONSTRUCTION_ESTIMATES
      WHERE  ESTIMATE_NUMBER = p_estimate_rec.ESTIMATE_NUMBER
      AND    ESTIMATE_ID <> p_estimate_rec.ESTIMATE_ID
      AND    ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_estimate_exist := 'N';
    END;
    IF l_estimate_exist = 'Y' THEN
      FND_MESSAGE.SET_NAME('EAM','EAM_ESTIMATE_NAME_UNIQUE');
      FND_MESSAGE.SET_TOKEN('ESTIMATE_NAME', p_estimate_rec.ESTIMATE_NUMBER);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Verifying data
  IF NVL(p_estimate_rec.PARENT_WO_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM OR
    p_estimate_rec.PARENT_WO_ID IS NOT NULL THEN
    l_parent_wo_id := p_estimate_rec.PARENT_WO_ID;
  END IF; -- NVL(p_estimate_rec.PARENT_WO_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM

  IF NVL(p_estimate_rec.CREATE_PARENT_WO_FLAG, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
    p_estimate_rec.CREATE_PARENT_WO_FLAG IS NOT NULL THEN
    l_parent_creation_flag := p_estimate_rec.CREATE_PARENT_WO_FLAG;
  END IF; -- NVL(p_estimate_rec.PARENT_WO_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM


  EAM_CONSTRUCTION_ESTIMATES_PKG.UPDATE_ROW(
      p_ESTIMATE_ID               => p_estimate_rec.ESTIMATE_ID,
      p_ORGANIZATION_ID           => p_estimate_rec.ORGANIZATION_ID,
      p_ESTIMATE_NUMBER           => p_estimate_rec.ESTIMATE_NUMBER,
      p_ESTIMATE_DESCRIPTION      => p_estimate_rec.ESTIMATE_DESCRIPTION,
      p_GROUPING_OPTION           => p_estimate_rec.GROUPING_OPTION,
      p_PARENT_WO_ID              => l_parent_wo_id,
      p_CREATE_PARENT_WO_FLAG     => l_parent_creation_flag,
      p_CREATION_DATE             => l_creation_date,
      p_CREATED_BY                => l_created_by,
      p_LAST_UPDATE_DATE          => l_last_updated_date,
      p_LAST_UPDATED_BY           => l_last_updated_by,
      p_LAST_UPDATE_LOGIN         => l_last_updated_login,
      p_ATTRIBUTE_CATEGORY        => p_estimate_rec.attribute_category,
		  p_ATTRIBUTE1                => p_estimate_rec.attribute1,
		  p_ATTRIBUTE2                => p_estimate_rec.attribute2,
		  p_ATTRIBUTE3                => p_estimate_rec.attribute3,
		  p_ATTRIBUTE4                => p_estimate_rec.attribute4,
		  p_ATTRIBUTE5                => p_estimate_rec.attribute5,
		  p_ATTRIBUTE6                => p_estimate_rec.attribute6,
		  p_ATTRIBUTE7                => p_estimate_rec.attribute7,
		  p_ATTRIBUTE8                => p_estimate_rec.attribute8,
		  p_ATTRIBUTE9                => p_estimate_rec.attribute9,
		  p_ATTRIBUTE10               => p_estimate_rec.attribute10,
		  p_ATTRIBUTE11               => p_estimate_rec.attribute11,
		  p_ATTRIBUTE12               => p_estimate_rec.attribute12,
		  p_ATTRIBUTE13               => p_estimate_rec.attribute13,
		  p_ATTRIBUTE14               => p_estimate_rec.attribute14,
		  p_ATTRIBUTE15     		      => p_estimate_rec.attribute15
      );

  IF (l_debug = 'Y') THEN
    DEBUG('Update estimate with ID : ' || p_estimate_rec.ESTIMATE_ID);
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (l_debug = 'Y') THEN
    DEBUG('x_return_status : ' || x_return_status);
    DEBUG('x_msg_count     : ' || x_msg_count);
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_ESTIMATE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
END UPDATE_ESTIMATE;

PROCEDURE SET_ACTIVITIES_FOR_CE(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_ce_id             IN NUMBER,
          px_activities_tbl   IN OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_ESTIMATE_ASSOCIATIONS_TBL,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'SET_ACTIVITIES_FOR_CE';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_debug_filename        VARCHAR(50)           := G_DEBUG_FILENAME;
  l_debug                 VARCHAR2(1)           := 'N';
  l_index                 NUMBER                := 0;
  l_est_association_id    NUMBER;
  l_ce_id                 NUMBER;
  l_organization_id       NUMBER;
  l_cu_id                 NUMBER;
  l_cu_qty                NUMBER;
  l_acct_class_code       VARCHAR2(10);
  l_activity_id           NUMBER;
  l_activity_qty          NUMBER;
  l_difficulty_id         NUMBER;
  l_resource_multiplier   NUMBER;
  l_creation_date         DATE                  := SYSDATE;
  l_created_by            NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_date     DATE                  := SYSDATE;
  l_last_updated_by       NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_login    NUMBER;
BEGIN
  SAVEPOINT SET_ACTIVITIES_FOR_CE;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.INITIALIZE;
  END IF;

  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INIT_DEBUG(
    p_init_msg_list       => p_init_msg_list,
    p_debug_filename      => l_debug_filename,
    p_debug_file_mode     => 'W',
    p_debug               => l_debug);

  IF (l_debug = 'Y') THEN
    DEBUG('SET_ACTIVITIES_FOR_CE ' ||
           p_api_version       ||'-'||
           p_commit            ||'-'||
           p_init_msg_list     ||'-'||
           p_validation_level);
    DEBUG('Construction Estimate ID : ' || p_ce_id);
    IF px_activities_tbl.COUNT > 0 THEN
      l_index := 0;
      WHILE l_index < px_activities_tbl.COUNT LOOP
        l_index := l_index + 1;
        DEBUG('Association ' || l_index || ' :');
        DEBUG(' ESTIMATE_ASSOCIATION_ID : ' || px_activities_tbl(l_index).ESTIMATE_ASSOCIATION_ID);
        DEBUG(' ORGANIZATION_ID         : ' || px_activities_tbl(l_index).ORGANIZATION_ID);
        DEBUG(' ESTIMATE_ID             : ' || px_activities_tbl(l_index).ESTIMATE_ID);
        DEBUG(' CU_ID                   : ' || px_activities_tbl(l_index).CU_ID);
        DEBUG(' CU_QTY                  : ' || px_activities_tbl(l_index).CU_QTY);
        DEBUG(' ACCT_CLASS_CODE         : ' || px_activities_tbl(l_index).ACCT_CLASS_CODE);
        DEBUG(' ACTIVITY_ID             : ' || px_activities_tbl(l_index).ACTIVITY_ID);
        DEBUG(' ACTIVITY_QTY            : ' || px_activities_tbl(l_index).ACTIVITY_QTY);
        DEBUG(' DIFFICULTY_ID           : ' || px_activities_tbl(l_index).DIFFICULTY_ID);
        DEBUG(' RESOURCE_MULTIPLIER     : ' || px_activities_tbl(l_index).RESOURCE_MULTIPLIER);
      END LOOP;
    END IF;
  END IF;

  --Validate Construction Estimate ID exist
  IF p_ce_id IS NULL THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_INVALID_CE_ID');
    FND_MESSAGE.SET_TOKEN('CE_ID', p_ce_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BEGIN
    SELECT ESTIMATE_ID,
           ORGANIZATION_ID
    INTO   l_ce_id,
           l_organization_id
    FROM   EAM_CONSTRUCTION_ESTIMATES
    WHERE  ESTIMATE_ID = p_ce_id;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('EAM','EAM_INVALID_CE_ID');
      FND_MESSAGE.SET_TOKEN('CE_ID', p_ce_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;

  IF px_activities_tbl.COUNT > 0 THEN
    l_index := 0;
    WHILE l_index < px_activities_tbl.COUNT LOOP
      l_index := l_index + 1;
      IF (px_activities_tbl(l_index).ORGANIZATION_ID IS NOT NULL AND px_activities_tbl(l_index).ORGANIZATION_ID <> l_organization_id) THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'ORGANIZATION_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', px_activities_tbl(l_index).ORGANIZATION_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (px_activities_tbl(l_index).ESTIMATE_ID IS NOT NULL AND px_activities_tbl(l_index).ESTIMATE_ID <> l_ce_id) THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'ESTIMATE_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', px_activities_tbl(l_index).ESTIMATE_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_cu_id := px_activities_tbl(l_index).CU_ID;

      IF (px_activities_tbl(l_index).CU_QTY IS NULL OR px_activities_tbl(l_index).CU_QTY < 1) THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'CU_QTY');
        FND_MESSAGE.SET_TOKEN('VALUE', px_activities_tbl(l_index).CU_QTY);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_cu_qty := px_activities_tbl(l_index).CU_QTY;

      /*IF (px_activities_tbl(l_index).ACCT_CLASS_CODE IS NULL) THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'ACCT_CLASS_CODE');
        FND_MESSAGE.SET_TOKEN('VALUE', px_activities_tbl(l_index).ACCT_CLASS_CODE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;*/
      l_acct_class_code := px_activities_tbl(l_index).ACCT_CLASS_CODE;

      IF (px_activities_tbl(l_index).ACTIVITY_ID IS NULL) THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'ACTIVITY_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', px_activities_tbl(l_index).ACTIVITY_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_activity_id := px_activities_tbl(l_index).ACTIVITY_ID;

      IF (px_activities_tbl(l_index).ACTIVITY_QTY IS NULL) THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'ACTIVITY_QTY');
        FND_MESSAGE.SET_TOKEN('VALUE', px_activities_tbl(l_index).ACTIVITY_QTY);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_activity_qty := px_activities_tbl(l_index).ACTIVITY_QTY;

      l_difficulty_id := px_activities_tbl(l_index).DIFFICULTY_ID;

      IF (px_activities_tbl(l_index).RESOURCE_MULTIPLIER IS NULL) THEN
        FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'RESOURCE_MULTIPLIER');
        FND_MESSAGE.SET_TOKEN('VALUE', px_activities_tbl(l_index).RESOURCE_MULTIPLIER);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resource_multiplier := px_activities_tbl(l_index).RESOURCE_MULTIPLIER;
      l_est_association_id  := NULL;

      EAM_ESTIMATE_ASSOCIATIONS_PKG.INSERT_ROW(
          px_ESTIMATE_ASSOCIATION_ID  => l_est_association_id,
          p_ORGANIZATION_ID           => l_organization_id,
          p_ESTIMATE_ID               => l_ce_id,
          p_CU_ID                     => l_cu_id,
          p_CU_QTY                    => l_cu_qty,
          p_ACCT_CLASS_CODE           => l_acct_class_code,
          p_ACTIVITY_ID               => l_activity_id,
          p_ACTIVITY_QTY              => l_activity_qty,
          p_DIFFICULTY_ID             => l_difficulty_id,
          p_RESOURCE_MULTIPLIER       => l_resource_multiplier,
          p_CREATION_DATE             => l_creation_date,
          p_CREATED_BY                => l_created_by,
          p_LAST_UPDATE_DATE          => l_last_updated_date,
          p_LAST_UPDATED_BY           => l_last_updated_by,
          p_LAST_UPDATE_LOGIN         => l_last_updated_login
         );

      IF (l_debug = 'Y') THEN
        DEBUG('Created Estimate Association with ID : ' || l_est_association_id);
      END IF;
      px_activities_tbl(l_index).ESTIMATE_ASSOCIATION_ID := l_est_association_id;
    END LOOP;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (l_debug = 'Y') THEN
    DEBUG('x_return_status : ' || x_return_status);
    DEBUG('x_msg_count     : ' || x_msg_count);
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO SET_ACTIVITIES_FOR_CE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO SET_ACTIVITIES_FOR_CE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO SET_ACTIVITIES_FOR_CE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
END SET_ACTIVITIES_FOR_CE;

--This is a private procedure which will retrive the wo lines for a construction
--estimate from the EAM_CE_WORK_ORDER_LINES table in the proper order based on
--the p_group_option parameter.
--This procedure does not do any error handling, but it may throw error, thus
--the calling procedure should have logic in place to catch possible error thrown
--from this procedure.
PROCEDURE GET_CE_WO_LNS_BY_GROUP_OPT(
          p_ce_id             IN NUMBER,
          p_group_option      IN VARCHAR2,
          x_ce_wo_ln_tbl      OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL)
IS
  --The group by 'None' option gets the lines in the order they are stored in the table.
  CURSOR none_cur IS
    SELECT    *
    FROM      EAM_CE_WORK_ORDER_LINES
    WHERE     ESTIMATE_ID = p_ce_id
    AND       estimate_work_order_line_id NOT IN (SELECT parent_wo_id
                                              FROM  EAM_CONSTRUCTION_ESTIMATES
                                              WHERE estimate_id = p_ce_id
                                              AND nvl(create_parent_wo_flag, 'N') = 'Y');

  --The group by 'Single Work Order', 'Construction Unit' and 'Activity' options all work as follow:
  --  First of all, order by src_cu_id, which is a view only field
  --  Second, order by src_activity_id, which is also a view only field
  --  Third, order by op_seq_num, which was defaulted from src_op_seq_num and later updated through UI
  --  Lastly, within the same op_seq_num:
  --    1. Display the resources first, order by res_seq_num
  --    2. Display the inventory materials second, order by mat_component_seq_num
  --    3. Display the direct items last, order by di_description
  CURSOR general_cur IS
    SELECT    ECWOL.*,
              NVL(ECWOL.OP_SEQ_NUM, ECWOL.SRC_OP_SEQ_NUM)   OP_SEQ_NUM_DERIVED
    FROM      EAM_CE_WORK_ORDER_LINES   ECWOL
    WHERE     ECWOL.ESTIMATE_ID = p_ce_id
    AND       ECWOL.estimate_work_order_line_id NOT IN (SELECT parent_wo_id
                                              FROM  EAM_CONSTRUCTION_ESTIMATES
                                              WHERE estimate_id = p_ce_id
                                              AND nvl(create_parent_wo_flag, 'N') = 'Y')
    ORDER BY  ECWOL.SRC_CU_ID,
              ECWOL.SRC_ACTIVITY_ID,
              OP_SEQ_NUM_DERIVED,
              ECWOL.RES_SEQ_NUM,
              ECWOL.MAT_COMPONENT_SEQ_NUM,
              ECWOL.DI_DESCRIPTION;

  --The group by 'WIP Accounting Class' option works as follow:
  --  First of all, order by src_acct_class_code
  --  Second, order by src_cu_id, which is a view only field
  --  Third, order by src_activity_id, which is also a view only field
  --  Fourth, order by op_seq_num, which was defaulted from src_op_seq_num and later updated through UI
  --  Lastly, within the same op_seq_num:
  --    1. Display the resources first, order by res_seq_num
  --    2. Display the inventory materials second, order by mat_component_seq_num
  --    3. Display the direct items last, order by di_description
  CURSOR wip_acct_cur IS
    SELECT    ECWOL.*,
              NVL(ECWOL.OP_SEQ_NUM, ECWOL.SRC_OP_SEQ_NUM)             OP_SEQ_NUM_DERIVED
    FROM      EAM_CE_WORK_ORDER_LINES   ECWOL
    WHERE     ECWOL.ESTIMATE_ID = p_ce_id
    AND       ECWOL.estimate_work_order_line_id NOT IN (SELECT parent_wo_id
                                                  FROM  EAM_CONSTRUCTION_ESTIMATES
                                                  WHERE estimate_id = p_ce_id
                                                  AND nvl(create_parent_wo_flag, 'N') = 'Y')
    ORDER BY  ECWOL.SRC_ACCT_CLASS_CODE,
              ECWOL.SRC_CU_ID,
              ECWOL.SRC_ACTIVITY_ID,
              OP_SEQ_NUM_DERIVED,
              ECWOL.RES_SEQ_NUM,
              ECWOL.MAT_COMPONENT_SEQ_NUM,
              ECWOL.DI_DESCRIPTION;

  l_ce_wo_ln_rec          EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_REC;
  l_wo_ln_index           NUMBER := 0;
BEGIN
  IF p_group_option = 'None' THEN
    --Populate x_ce_wo_ln_tbl
    l_wo_ln_index := 0;
    FOR wo_line_rec IN none_cur LOOP
      l_wo_ln_index := l_wo_ln_index + 1;

      l_ce_wo_ln_rec.ESTIMATE_WORK_ORDER_LINE_ID := wo_line_rec.ESTIMATE_WORK_ORDER_LINE_ID;
      l_ce_wo_ln_rec.SRC_CU_ID := wo_line_rec.SRC_CU_ID;
      l_ce_wo_ln_rec.SRC_ACTIVITY_ID := wo_line_rec.SRC_ACTIVITY_ID;
      l_ce_wo_ln_rec.SRC_ACTIVITY_QTY := wo_line_rec.SRC_ACTIVITY_QTY;
      l_ce_wo_ln_rec.DIFFICULTY_ID := wo_line_rec.SRC_DIFFICULTY_ID;
      l_ce_wo_ln_rec.DIFFICULTY_QTY := wo_line_rec.DIFFICULTY_QTY;
      l_ce_wo_ln_rec.CU_QTY := wo_line_rec.CU_QTY;
      l_ce_wo_ln_rec.SRC_OP_SEQ_NUM := wo_line_rec.SRC_OP_SEQ_NUM;
      l_ce_wo_ln_rec.SRC_ACCT_CLASS_CODE := wo_line_rec.SRC_ACCT_CLASS_CODE;
      l_ce_wo_ln_rec.ESTIMATE_ID := wo_line_rec.ESTIMATE_ID;
      l_ce_wo_ln_rec.ORGANIZATION_ID := wo_line_rec.ORGANIZATION_ID;
      l_ce_wo_ln_rec.WORK_ORDER_SEQ_NUM := wo_line_rec.WORK_ORDER_SEQ_NUM;
      l_ce_wo_ln_rec.WORK_ORDER_NUMBER := wo_line_rec.WORK_ORDER_NUMBER;
      l_ce_wo_ln_rec.WORK_ORDER_DESCRIPTION := wo_line_rec.WORK_ORDER_DESCRIPTION;
      l_ce_wo_ln_rec.REF_WIP_ENTITY_ID := wo_line_rec.REF_WIP_ENTITY_ID;
      l_ce_wo_ln_rec.PRIMARY_ITEM_ID := wo_line_rec.PRIMARY_ITEM_ID;
      l_ce_wo_ln_rec.ACCT_CLASS_CODE := wo_line_rec.ACCT_CLASS_CODE;
      l_ce_wo_ln_rec.STATUS_TYPE := wo_line_rec.STATUS_TYPE;
      l_ce_wo_ln_rec.SCHEDULED_START_DATE := wo_line_rec.SCHEDULED_START_DATE;
      l_ce_wo_ln_rec.SCHEDULED_COMPLETION_DATE := wo_line_rec.SCHEDULED_COMPLETION_DATE;
      l_ce_wo_ln_rec.PROJECT_ID := wo_line_rec.PROJECT_ID;
      l_ce_wo_ln_rec.TASK_ID := wo_line_rec.TASK_ID;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_ID := wo_line_rec.MAINTENANCE_OBJECT_ID;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_TYPE := wo_line_rec.MAINTENANCE_OBJECT_TYPE;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_SOURCE := wo_line_rec.MAINTENANCE_OBJECT_SOURCE;
      l_ce_wo_ln_rec.OWNING_DEPARTMENT_ID := wo_line_rec.OWNING_DEPARTMENT_ID;
      l_ce_wo_ln_rec.USER_DEFINED_STATUS_ID := wo_line_rec.USER_DEFINED_STATUS_ID;
      l_ce_wo_ln_rec.OP_SEQ_NUM := wo_line_rec.OP_SEQ_NUM;
      l_ce_wo_ln_rec.OP_DESCRIPTION := wo_line_rec.OP_DESCRIPTION;
      l_ce_wo_ln_rec.STANDARD_OPERATION_ID := wo_line_rec.STANDARD_OPERATION_ID;
      l_ce_wo_ln_rec.OP_DEPARTMENT_ID := wo_line_rec.OP_DEPARTMENT_ID;
      l_ce_wo_ln_rec.OP_LONG_DESCRIPTION := wo_line_rec.OP_LONG_DESCRIPTION;
      l_ce_wo_ln_rec.RES_SEQ_NUM := wo_line_rec.RES_SEQ_NUM;
      l_ce_wo_ln_rec.RES_ID := wo_line_rec.RES_ID;
      l_ce_wo_ln_rec.RES_UOM := wo_line_rec.RES_UOM;
      l_ce_wo_ln_rec.RES_BASIS_TYPE := wo_line_rec.RES_BASIS_TYPE;
      l_ce_wo_ln_rec.RES_USAGE_RATE_OR_AMOUNT := wo_line_rec.RES_USAGE_RATE_OR_AMOUNT;
      l_ce_wo_ln_rec.RES_REQUIRED_UNITS := wo_line_rec.RES_REQUIRED_UNITS;
      l_ce_wo_ln_rec.RES_ASSIGNED_UNITS := wo_line_rec.RES_ASSIGNED_UNITS;
      l_ce_wo_ln_rec.ITEM_TYPE := wo_line_rec.ITEM_TYPE;
      l_ce_wo_ln_rec.REQUIRED_QUANTITY := wo_line_rec.REQUIRED_QUANTITY;
      l_ce_wo_ln_rec.UNIT_PRICE := wo_line_rec.UNIT_PRICE;
      l_ce_wo_ln_rec.UOM := wo_line_rec.UOM;
      l_ce_wo_ln_rec.BASIS_TYPE := wo_line_rec.BASIS_TYPE;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_NAME := wo_line_rec.SUGGESTED_VENDOR_NAME;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_ID := wo_line_rec.SUGGESTED_VENDOR_ID;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_SITE := wo_line_rec.SUGGESTED_VENDOR_SITE;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_SITE_ID := wo_line_rec.SUGGESTED_VENDOR_SITE_ID;
      l_ce_wo_ln_rec.MAT_INVENTORY_ITEM_ID := wo_line_rec.MAT_INVENTORY_ITEM_ID;
      l_ce_wo_ln_rec.MAT_COMPONENT_SEQ_NUM := wo_line_rec.MAT_COMPONENT_SEQ_NUM;
      l_ce_wo_ln_rec.MAT_SUPPLY_SUBINVENTORY := wo_line_rec.MAT_SUPPLY_SUBINVENTORY;
      l_ce_wo_ln_rec.MAT_SUPPLY_LOCATOR_ID := wo_line_rec.MAT_SUPPLY_LOCATOR_ID;
      l_ce_wo_ln_rec.DI_AMOUNT := wo_line_rec.DI_AMOUNT;
      l_ce_wo_ln_rec.DI_ORDER_TYPE_LOOKUP_CODE := wo_line_rec.DI_ORDER_TYPE_LOOKUP_CODE;
      l_ce_wo_ln_rec.DI_DESCRIPTION := wo_line_rec.DI_DESCRIPTION;
      l_ce_wo_ln_rec.DI_PURCHASE_CATEGORY_ID := wo_line_rec.DI_PURCHASE_CATEGORY_ID;
      l_ce_wo_ln_rec.DI_AUTO_REQUEST_MATERIAL := wo_line_rec.DI_AUTO_REQUEST_MATERIAL;
      l_ce_wo_ln_rec.DI_NEED_BY_DATE := wo_line_rec.DI_NEED_BY_DATE;
      l_ce_wo_ln_rec.WORK_ORDER_LINE_COST := wo_line_rec.WO_LINE_PER_UNIT_COST;

      l_ce_wo_ln_rec.RES_SCHEDULED_FLAG := wo_line_rec.RES_SCHEDULED_FLAG;
      l_ce_wo_ln_rec.AVAILABLE_QUANTITY := wo_line_rec.ITEM_COMMENTS;
      l_ce_wo_ln_rec.ITEM_COMMENTS := wo_line_rec.ITEM_COMMENTS;
      l_ce_wo_ln_rec.CU_QTY := wo_line_rec.CU_QTY;

      -- Addtl WO Details which are not in the defaults region must be set to null
      l_ce_wo_ln_rec.WORK_ORDER_TYPE := wo_line_rec.WORK_ORDER_TYPE;
      l_ce_wo_ln_rec.ACTIVITY_TYPE := wo_line_rec.ACTIVITY_TYPE;
      l_ce_wo_ln_rec.ACTIVITY_CAUSE := wo_line_rec.ACTIVITY_CAUSE;
      l_ce_wo_ln_rec.ACTIVITY_SOURCE := wo_line_rec.ACTIVITY_SOURCE;


      x_ce_wo_ln_tbl(l_wo_ln_index) := l_ce_wo_ln_rec;
    END LOOP;
  ELSIF   p_group_option = 'Single Work Order'
    OR p_group_option = 'Construction Unit'
    OR p_group_option = 'Activity'
  THEN
    --Populate x_ce_wo_ln_tbl
    l_wo_ln_index := 0;
    FOR wo_line_rec IN general_cur LOOP
      l_wo_ln_index := l_wo_ln_index + 1;

      l_ce_wo_ln_rec.ESTIMATE_WORK_ORDER_LINE_ID := wo_line_rec.ESTIMATE_WORK_ORDER_LINE_ID;
      l_ce_wo_ln_rec.SRC_CU_ID := wo_line_rec.SRC_CU_ID;
      l_ce_wo_ln_rec.SRC_ACTIVITY_ID := wo_line_rec.SRC_ACTIVITY_ID;
      l_ce_wo_ln_rec.SRC_ACTIVITY_QTY := wo_line_rec.SRC_ACTIVITY_QTY;
      l_ce_wo_ln_rec.DIFFICULTY_ID := wo_line_rec.SRC_DIFFICULTY_ID;
      l_ce_wo_ln_rec.DIFFICULTY_QTY := wo_line_rec.DIFFICULTY_QTY;
      l_ce_wo_ln_rec.CU_QTY := wo_line_rec.CU_QTY;
      l_ce_wo_ln_rec.SRC_OP_SEQ_NUM := wo_line_rec.SRC_OP_SEQ_NUM;
      l_ce_wo_ln_rec.SRC_ACCT_CLASS_CODE := wo_line_rec.SRC_ACCT_CLASS_CODE;
      l_ce_wo_ln_rec.ESTIMATE_ID := wo_line_rec.ESTIMATE_ID;
      l_ce_wo_ln_rec.ORGANIZATION_ID := wo_line_rec.ORGANIZATION_ID;
      l_ce_wo_ln_rec.WORK_ORDER_SEQ_NUM := wo_line_rec.WORK_ORDER_SEQ_NUM;
      l_ce_wo_ln_rec.WORK_ORDER_NUMBER := wo_line_rec.WORK_ORDER_NUMBER;
      l_ce_wo_ln_rec.WORK_ORDER_DESCRIPTION := wo_line_rec.WORK_ORDER_DESCRIPTION;
      l_ce_wo_ln_rec.REF_WIP_ENTITY_ID := wo_line_rec.REF_WIP_ENTITY_ID;
      l_ce_wo_ln_rec.PRIMARY_ITEM_ID := wo_line_rec.PRIMARY_ITEM_ID;
      l_ce_wo_ln_rec.ACCT_CLASS_CODE := wo_line_rec.ACCT_CLASS_CODE;
      l_ce_wo_ln_rec.STATUS_TYPE := wo_line_rec.STATUS_TYPE;
      l_ce_wo_ln_rec.SCHEDULED_START_DATE := wo_line_rec.SCHEDULED_START_DATE;
      l_ce_wo_ln_rec.SCHEDULED_COMPLETION_DATE := wo_line_rec.SCHEDULED_COMPLETION_DATE;
      l_ce_wo_ln_rec.PROJECT_ID := wo_line_rec.PROJECT_ID;
      l_ce_wo_ln_rec.TASK_ID := wo_line_rec.TASK_ID;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_ID := wo_line_rec.MAINTENANCE_OBJECT_ID;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_TYPE := wo_line_rec.MAINTENANCE_OBJECT_TYPE;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_SOURCE := wo_line_rec.MAINTENANCE_OBJECT_SOURCE;
      l_ce_wo_ln_rec.OWNING_DEPARTMENT_ID := wo_line_rec.OWNING_DEPARTMENT_ID;
      l_ce_wo_ln_rec.USER_DEFINED_STATUS_ID := wo_line_rec.USER_DEFINED_STATUS_ID;
      l_ce_wo_ln_rec.OP_SEQ_NUM := wo_line_rec.OP_SEQ_NUM_DERIVED;              --NVL(OP_SEQ_NUM, SRC_OP_SEQ_NUM)
      l_ce_wo_ln_rec.OP_DESCRIPTION := wo_line_rec.OP_DESCRIPTION;
      l_ce_wo_ln_rec.STANDARD_OPERATION_ID := wo_line_rec.STANDARD_OPERATION_ID;
      l_ce_wo_ln_rec.OP_DEPARTMENT_ID := wo_line_rec.OP_DEPARTMENT_ID;
      l_ce_wo_ln_rec.OP_LONG_DESCRIPTION := wo_line_rec.OP_LONG_DESCRIPTION;
      l_ce_wo_ln_rec.RES_SEQ_NUM := wo_line_rec.RES_SEQ_NUM;
      l_ce_wo_ln_rec.RES_ID := wo_line_rec.RES_ID;
      l_ce_wo_ln_rec.RES_UOM := wo_line_rec.RES_UOM;
      l_ce_wo_ln_rec.RES_BASIS_TYPE := wo_line_rec.RES_BASIS_TYPE;
      l_ce_wo_ln_rec.RES_USAGE_RATE_OR_AMOUNT := wo_line_rec.RES_USAGE_RATE_OR_AMOUNT;
      l_ce_wo_ln_rec.RES_REQUIRED_UNITS := wo_line_rec.RES_REQUIRED_UNITS;
      l_ce_wo_ln_rec.RES_ASSIGNED_UNITS := wo_line_rec.RES_ASSIGNED_UNITS;
      l_ce_wo_ln_rec.ITEM_TYPE := wo_line_rec.ITEM_TYPE;
      l_ce_wo_ln_rec.REQUIRED_QUANTITY := wo_line_rec.REQUIRED_QUANTITY;
      l_ce_wo_ln_rec.UNIT_PRICE := wo_line_rec.UNIT_PRICE;
      l_ce_wo_ln_rec.UOM := wo_line_rec.UOM;
      l_ce_wo_ln_rec.BASIS_TYPE := wo_line_rec.BASIS_TYPE;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_NAME := wo_line_rec.SUGGESTED_VENDOR_NAME;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_ID := wo_line_rec.SUGGESTED_VENDOR_ID;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_SITE := wo_line_rec.SUGGESTED_VENDOR_SITE;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_SITE_ID := wo_line_rec.SUGGESTED_VENDOR_SITE_ID;
      l_ce_wo_ln_rec.MAT_INVENTORY_ITEM_ID := wo_line_rec.MAT_INVENTORY_ITEM_ID;
      l_ce_wo_ln_rec.MAT_COMPONENT_SEQ_NUM := wo_line_rec.MAT_COMPONENT_SEQ_NUM;
      l_ce_wo_ln_rec.MAT_SUPPLY_SUBINVENTORY := wo_line_rec.MAT_SUPPLY_SUBINVENTORY;
      l_ce_wo_ln_rec.MAT_SUPPLY_LOCATOR_ID := wo_line_rec.MAT_SUPPLY_LOCATOR_ID;
      l_ce_wo_ln_rec.DI_AMOUNT := wo_line_rec.DI_AMOUNT;
      l_ce_wo_ln_rec.DI_ORDER_TYPE_LOOKUP_CODE := wo_line_rec.DI_ORDER_TYPE_LOOKUP_CODE;
      l_ce_wo_ln_rec.DI_DESCRIPTION := wo_line_rec.DI_DESCRIPTION;
      l_ce_wo_ln_rec.DI_PURCHASE_CATEGORY_ID := wo_line_rec.DI_PURCHASE_CATEGORY_ID;
      l_ce_wo_ln_rec.DI_AUTO_REQUEST_MATERIAL := wo_line_rec.DI_AUTO_REQUEST_MATERIAL;
      l_ce_wo_ln_rec.DI_NEED_BY_DATE := wo_line_rec.DI_NEED_BY_DATE;
      l_ce_wo_ln_rec.WORK_ORDER_LINE_COST := wo_line_rec.WO_LINE_PER_UNIT_COST;
      l_ce_wo_ln_rec.RES_SCHEDULED_FLAG := wo_line_rec.RES_SCHEDULED_FLAG;
      l_ce_wo_ln_rec.AVAILABLE_QUANTITY := wo_line_rec.ITEM_COMMENTS;
      l_ce_wo_ln_rec.ITEM_COMMENTS := wo_line_rec.ITEM_COMMENTS;
      l_ce_wo_ln_rec.CU_QTY := wo_line_rec.CU_QTY;

      -- Addtl WO Details which are not in the defaults region must be set to null
      l_ce_wo_ln_rec.WORK_ORDER_TYPE := wo_line_rec.WORK_ORDER_TYPE;
      l_ce_wo_ln_rec.ACTIVITY_TYPE := wo_line_rec.ACTIVITY_TYPE;
      l_ce_wo_ln_rec.ACTIVITY_CAUSE := wo_line_rec.ACTIVITY_CAUSE;
      l_ce_wo_ln_rec.ACTIVITY_SOURCE := wo_line_rec.ACTIVITY_SOURCE;

      x_ce_wo_ln_tbl(l_wo_ln_index) := l_ce_wo_ln_rec;
    END LOOP;
  ELSIF p_group_option = 'WIP Accounting Class' THEN
    --Populate x_ce_wo_ln_tbl
    l_wo_ln_index := 0;
    FOR wo_line_rec IN wip_acct_cur LOOP
      l_wo_ln_index := l_wo_ln_index + 1;

      l_ce_wo_ln_rec.ESTIMATE_WORK_ORDER_LINE_ID := wo_line_rec.ESTIMATE_WORK_ORDER_LINE_ID;
      l_ce_wo_ln_rec.SRC_CU_ID := wo_line_rec.SRC_CU_ID;
      l_ce_wo_ln_rec.SRC_ACTIVITY_ID := wo_line_rec.SRC_ACTIVITY_ID;
      l_ce_wo_ln_rec.SRC_ACTIVITY_QTY := wo_line_rec.SRC_ACTIVITY_QTY;
      l_ce_wo_ln_rec.DIFFICULTY_ID := wo_line_rec.SRC_DIFFICULTY_ID;
      l_ce_wo_ln_rec.DIFFICULTY_QTY := wo_line_rec.DIFFICULTY_QTY;
      l_ce_wo_ln_rec.CU_QTY := wo_line_rec.CU_QTY;
      l_ce_wo_ln_rec.SRC_OP_SEQ_NUM := wo_line_rec.SRC_OP_SEQ_NUM;
      l_ce_wo_ln_rec.SRC_ACCT_CLASS_CODE := wo_line_rec.SRC_ACCT_CLASS_CODE;
      l_ce_wo_ln_rec.ESTIMATE_ID := wo_line_rec.ESTIMATE_ID;
      l_ce_wo_ln_rec.ORGANIZATION_ID := wo_line_rec.ORGANIZATION_ID;
      l_ce_wo_ln_rec.WORK_ORDER_SEQ_NUM := wo_line_rec.WORK_ORDER_SEQ_NUM;
      l_ce_wo_ln_rec.WORK_ORDER_NUMBER := wo_line_rec.WORK_ORDER_NUMBER;
      l_ce_wo_ln_rec.WORK_ORDER_DESCRIPTION := wo_line_rec.WORK_ORDER_DESCRIPTION;
      l_ce_wo_ln_rec.REF_WIP_ENTITY_ID := wo_line_rec.REF_WIP_ENTITY_ID;
      l_ce_wo_ln_rec.PRIMARY_ITEM_ID := wo_line_rec.PRIMARY_ITEM_ID;
      l_ce_wo_ln_rec.ACCT_CLASS_CODE := NVL(wo_line_rec.ACCT_CLASS_CODE, wo_line_rec.SRC_ACCT_CLASS_CODE);
      l_ce_wo_ln_rec.STATUS_TYPE := wo_line_rec.STATUS_TYPE;
      l_ce_wo_ln_rec.SCHEDULED_START_DATE := wo_line_rec.SCHEDULED_START_DATE;
      l_ce_wo_ln_rec.SCHEDULED_COMPLETION_DATE := wo_line_rec.SCHEDULED_COMPLETION_DATE;
      l_ce_wo_ln_rec.PROJECT_ID := wo_line_rec.PROJECT_ID;
      l_ce_wo_ln_rec.TASK_ID := wo_line_rec.TASK_ID;
      l_ce_wo_ln_rec.USER_DEFINED_STATUS_ID := wo_line_rec.USER_DEFINED_STATUS_ID;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_ID := wo_line_rec.MAINTENANCE_OBJECT_ID;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_TYPE := wo_line_rec.MAINTENANCE_OBJECT_TYPE;
      l_ce_wo_ln_rec.MAINTENANCE_OBJECT_SOURCE := wo_line_rec.MAINTENANCE_OBJECT_SOURCE;
      l_ce_wo_ln_rec.OWNING_DEPARTMENT_ID := wo_line_rec.OWNING_DEPARTMENT_ID;
      l_ce_wo_ln_rec.OP_SEQ_NUM := wo_line_rec.OP_SEQ_NUM_DERIVED;              --NVL(OP_SEQ_NUM, SRC_OP_SEQ_NUM)
      l_ce_wo_ln_rec.OP_DESCRIPTION := wo_line_rec.OP_DESCRIPTION;
      l_ce_wo_ln_rec.STANDARD_OPERATION_ID := wo_line_rec.STANDARD_OPERATION_ID;
      l_ce_wo_ln_rec.OP_DEPARTMENT_ID := wo_line_rec.OP_DEPARTMENT_ID;
      l_ce_wo_ln_rec.OP_LONG_DESCRIPTION := wo_line_rec.OP_LONG_DESCRIPTION;
      l_ce_wo_ln_rec.RES_SEQ_NUM := wo_line_rec.RES_SEQ_NUM;
      l_ce_wo_ln_rec.RES_ID := wo_line_rec.RES_ID;
      l_ce_wo_ln_rec.RES_UOM := wo_line_rec.RES_UOM;
      l_ce_wo_ln_rec.RES_BASIS_TYPE := wo_line_rec.RES_BASIS_TYPE;
      l_ce_wo_ln_rec.RES_USAGE_RATE_OR_AMOUNT := wo_line_rec.RES_USAGE_RATE_OR_AMOUNT;
      l_ce_wo_ln_rec.RES_REQUIRED_UNITS := wo_line_rec.RES_REQUIRED_UNITS;
      l_ce_wo_ln_rec.RES_ASSIGNED_UNITS := wo_line_rec.RES_ASSIGNED_UNITS;
      l_ce_wo_ln_rec.ITEM_TYPE := wo_line_rec.ITEM_TYPE;
      l_ce_wo_ln_rec.REQUIRED_QUANTITY := wo_line_rec.REQUIRED_QUANTITY;
      l_ce_wo_ln_rec.UNIT_PRICE := wo_line_rec.UNIT_PRICE;
      l_ce_wo_ln_rec.UOM := wo_line_rec.UOM;
      l_ce_wo_ln_rec.BASIS_TYPE := wo_line_rec.BASIS_TYPE;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_NAME := wo_line_rec.SUGGESTED_VENDOR_NAME;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_ID := wo_line_rec.SUGGESTED_VENDOR_ID;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_SITE := wo_line_rec.SUGGESTED_VENDOR_SITE;
      l_ce_wo_ln_rec.SUGGESTED_VENDOR_SITE_ID := wo_line_rec.SUGGESTED_VENDOR_SITE_ID;
      l_ce_wo_ln_rec.MAT_INVENTORY_ITEM_ID := wo_line_rec.MAT_INVENTORY_ITEM_ID;
      l_ce_wo_ln_rec.MAT_COMPONENT_SEQ_NUM := wo_line_rec.MAT_COMPONENT_SEQ_NUM;
      l_ce_wo_ln_rec.MAT_SUPPLY_SUBINVENTORY := wo_line_rec.MAT_SUPPLY_SUBINVENTORY;
      l_ce_wo_ln_rec.MAT_SUPPLY_LOCATOR_ID := wo_line_rec.MAT_SUPPLY_LOCATOR_ID;
      l_ce_wo_ln_rec.DI_AMOUNT := wo_line_rec.DI_AMOUNT;
      l_ce_wo_ln_rec.DI_ORDER_TYPE_LOOKUP_CODE := wo_line_rec.DI_ORDER_TYPE_LOOKUP_CODE;
      l_ce_wo_ln_rec.DI_DESCRIPTION := wo_line_rec.DI_DESCRIPTION;
      l_ce_wo_ln_rec.DI_PURCHASE_CATEGORY_ID := wo_line_rec.DI_PURCHASE_CATEGORY_ID;
      l_ce_wo_ln_rec.DI_AUTO_REQUEST_MATERIAL := wo_line_rec.DI_AUTO_REQUEST_MATERIAL;
      l_ce_wo_ln_rec.DI_NEED_BY_DATE := wo_line_rec.DI_NEED_BY_DATE;
      l_ce_wo_ln_rec.WORK_ORDER_LINE_COST := wo_line_rec.WO_LINE_PER_UNIT_COST;
      l_ce_wo_ln_rec.RES_SCHEDULED_FLAG := wo_line_rec.RES_SCHEDULED_FLAG;
      l_ce_wo_ln_rec.AVAILABLE_QUANTITY := wo_line_rec.ITEM_COMMENTS;
      l_ce_wo_ln_rec.ITEM_COMMENTS := wo_line_rec.ITEM_COMMENTS;
      l_ce_wo_ln_rec.CU_QTY := wo_line_rec.CU_QTY;

      -- Addtl WO Details which are not in the defaults region must be set to null
      l_ce_wo_ln_rec.WORK_ORDER_TYPE := wo_line_rec.WORK_ORDER_TYPE;
      l_ce_wo_ln_rec.ACTIVITY_TYPE := wo_line_rec.ACTIVITY_TYPE;
      l_ce_wo_ln_rec.ACTIVITY_CAUSE := wo_line_rec.ACTIVITY_CAUSE;
      l_ce_wo_ln_rec.ACTIVITY_SOURCE := wo_line_rec.ACTIVITY_SOURCE;

      x_ce_wo_ln_tbl(l_wo_ln_index) := l_ce_wo_ln_rec;
    END LOOP;
  ELSE
    --Unsupported group option
    FND_MESSAGE.SET_NAME('EAM','EAM_UNSUPPORTED_GROUP_OPTION');
    FND_MESSAGE.SET_TOKEN('OPTION', p_group_option);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
END GET_CE_WO_LNS_BY_GROUP_OPT;

--This is a private procedure, it takes a wo defaults record and a list of wo
--lines for a particular construction estimate, and it sets the values for the
--wo lines based on the wo defaults and the group option in the wo defaults.
--This procedure does not do any error handling, but it may throw error, thus
--the calling procedure should have logic in place to catch possible error thrown
--from this procedure.
PROCEDURE SET_WO_LNS_FROM_WO_DEFAULTS(
          p_ce_wo_defaults    IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WO_DEFAULTS_REC,
          p_group_option      IN VARCHAR2,
          px_ce_wo_ln_tbl     IN OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
          )
IS
BEGIN
  IF px_ce_wo_ln_tbl.COUNT > 0 THEN
    FOR i IN px_ce_wo_ln_tbl.FIRST..px_ce_wo_ln_tbl.LAST LOOP
      IF p_group_option = 'None' THEN
        --NULL out everything
        px_ce_wo_ln_tbl(i).WORK_ORDER_NUMBER           := NULL;
        px_ce_wo_ln_tbl(i).SCHEDULED_START_DATE        := NULL;
        px_ce_wo_ln_tbl(i).SCHEDULED_COMPLETION_DATE   := NULL;
        px_ce_wo_ln_tbl(i).USER_DEFINED_STATUS_ID      := NULL;
        px_ce_wo_ln_tbl(i).WORK_ORDER_DESCRIPTION      := NULL;
        px_ce_wo_ln_tbl(i).PROJECT_ID                  := NULL;
        px_ce_wo_ln_tbl(i).TASK_ID                     := NULL;
        px_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_ID       := NULL;
        px_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_TYPE     := NULL;
        px_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_SOURCE   := NULL;
        --px_ce_wo_ln_tbl(i).ACCT_CLASS_CODE             := NULL;
      ELSE
        --Always use the value of SCHEDULED_START_DATE, SCHEDULED_COMPLETION_DATE, USER_DEFINED_STATUS_ID,
        --WORK_ORDER_DESCRIPTION, PROJECT_ID, TASK_ID, MAINTENANCE_OBJECT_ID, MAINTENANCE_OBJECT_TYPE
        --and MAINTENANCE_OBJECT_SOURCE passed in
        px_ce_wo_ln_tbl(i).WORK_ORDER_NUMBER           := NULL;
        px_ce_wo_ln_tbl(i).SCHEDULED_START_DATE        := p_ce_wo_defaults.SCHEDULED_START_DATE;
        px_ce_wo_ln_tbl(i).SCHEDULED_COMPLETION_DATE   := p_ce_wo_defaults.SCHEDULED_COMPLETION_DATE;
        px_ce_wo_ln_tbl(i).USER_DEFINED_STATUS_ID      := p_ce_wo_defaults.USER_DEFINED_STATUS_ID;
        px_ce_wo_ln_tbl(i).WORK_ORDER_DESCRIPTION      := p_ce_wo_defaults.WORK_ORDER_DESCRIPTION;
        px_ce_wo_ln_tbl(i).PROJECT_ID                  := p_ce_wo_defaults.PROJECT_ID;
        px_ce_wo_ln_tbl(i).TASK_ID                     := p_ce_wo_defaults.TASK_ID;
        px_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_ID       := p_ce_wo_defaults.MAINTENANCE_OBJECT_ID;
        px_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_TYPE     := p_ce_wo_defaults.MAINTENANCE_OBJECT_TYPE;
        px_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_SOURCE   := p_ce_wo_defaults.MAINTENANCE_OBJECT_SOURCE;
        IF (p_ce_wo_defaults.ACCT_CLASS_CODE IS NOT NULL) THEN
          px_ce_wo_ln_tbl(i).ACCT_CLASS_CODE             := p_ce_wo_defaults.ACCT_CLASS_CODE;
        END IF;

        IF p_group_option = 'Single Work Order' THEN
          --Only copy WORK_ORDER_NUMBER for group option 'Single Work Order'
          px_ce_wo_ln_tbl(i).WORK_ORDER_NUMBER         := p_ce_wo_defaults.DEFAULT_WORK_ORDER_NUMBER;
        ELSIF p_group_option <> 'WIP Accounting Class'
          AND p_group_option <> 'Activity'
          AND p_group_option <> 'Construction Unit' THEN
          --Unsupported group option
          FND_MESSAGE.SET_NAME('EAM','EAM_UNSUPPORTED_GROUP_OPTION');
          FND_MESSAGE.SET_TOKEN('OPTION', p_group_option);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;
END SET_WO_LNS_FROM_WO_DEFAULTS;

--This is a private procedure, it takes a sorted list of wo lines as input,
--then resolves the work_order_seq_num and op_seq_num contention based on
--the p_group_option parameter. The work_order_seq_num starts from 1 in increment
--of 1, and the op_seq_num starts from 10 in increment of 10.
--This procedure does not do any error handling, but it may throw error, thus
--the calling procedure should have logic in place to catch possible error thrown
--from this procedure.
PROCEDURE RESOLVE_SORT_CONTENTION(
          p_group_option      IN VARCHAR2,
          px_ce_wo_ln_tbl     IN OUT NOCOPY EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL
          )
IS
  l_new_wo_seq_num        NUMBER;
  l_new_op_seq_num        NUMBER;
  l_tmp_cu_id             NUMBER;
  l_tmp_actvity_id        NUMBER;
  l_tmp_op_seq_num        NUMBER;
  l_tmp_acct_class_code   VARCHAR2(10);
BEGIN
  IF px_ce_wo_ln_tbl.COUNT > 0 THEN
    FOR i IN px_ce_wo_ln_tbl.FIRST..px_ce_wo_ln_tbl.LAST LOOP
      IF p_group_option = 'Single Work Order' THEN
        IF i = 1 THEN
          l_tmp_cu_id       := px_ce_wo_ln_tbl(i).SRC_CU_ID;
          l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
          l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;

          l_new_wo_seq_num  := 1;
          l_new_op_seq_num  := 10;
        ELSE
          IF (NVL(l_tmp_cu_id, 0) = NVL(px_ce_wo_ln_tbl(i).SRC_CU_ID, 0)) THEN
            --Same CU as the last wo line
            IF (l_tmp_actvity_id  = px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID) THEN
              --Same activity as the last wo line
              IF (l_tmp_op_seq_num  <> px_ce_wo_ln_tbl(i).OP_SEQ_NUM) THEN
                --Different op_seq_num as the last wo line
                --Update l_tmp_op_seq_num with new op_seq_num
                l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
                --Increase l_new_op_seq_num by 10
                l_new_op_seq_num := l_new_op_seq_num + 10;
              END IF;
            ELSE
              --Different activity as the last wo line
              --Update l_tmp_actvity_id and l_tmp_op_seq_num
              l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
              l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
              --Increase l_new_op_seq_num by 10
              l_new_op_seq_num := l_new_op_seq_num + 10;
            END IF;
          ELSE
            --Different CU as the last wo line
            --Update l_tmp_cu_id, l_tmp_actvity_id and l_tmp_op_seq_num
            l_tmp_cu_id       := px_ce_wo_ln_tbl(i).SRC_CU_ID;
            l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
            l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
            --Increase l_new_op_seq_num by 10
            l_new_op_seq_num := l_new_op_seq_num + 10;
          END IF;
        END IF;

        --Set new values for work_order_seq_num and op_seq_num
        px_ce_wo_ln_tbl(i).WORK_ORDER_SEQ_NUM          := l_new_wo_seq_num;
        px_ce_wo_ln_tbl(i).OP_SEQ_NUM                  := l_new_op_seq_num;
      ELSIF p_group_option = 'Construction Unit' THEN
        IF i = 1 THEN
          l_tmp_cu_id       := px_ce_wo_ln_tbl(i).SRC_CU_ID;
          l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
          l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;

          l_new_wo_seq_num  := 1;
          l_new_op_seq_num  := 10;
        ELSE
          IF (NVL(l_tmp_cu_id, 0) = NVL(px_ce_wo_ln_tbl(i).SRC_CU_ID, 0)) THEN
            --Same CU as the last wo line
            IF (l_tmp_actvity_id  = px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID) THEN
              --Same activity as the last wo line
              IF (l_tmp_op_seq_num  <> px_ce_wo_ln_tbl(i).OP_SEQ_NUM) THEN
                --Different op_seq_num as the last wo line
                --Update l_tmp_op_seq_num with new op_seq_num
                l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
                --Increase l_new_op_seq_num by 10
                l_new_op_seq_num := l_new_op_seq_num + 10;
              END IF;
            ELSE
              --Different activity as the last wo line
              --Update l_tmp_actvity_id and l_tmp_op_seq_num
              l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
              l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
              --Increase l_new_op_seq_num by 10
              l_new_op_seq_num := l_new_op_seq_num + 10;
            END IF;
          ELSE
            --Different CU as the last wo line
            --Update l_tmp_cu_id, l_tmp_actvity_id and l_tmp_op_seq_num
            l_tmp_cu_id       := px_ce_wo_ln_tbl(i).SRC_CU_ID;
            l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
            l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
            --Increase l_new_wo_seq_num by 1
            --Reset l_new_op_seq_num to 10
            l_new_wo_seq_num  := l_new_wo_seq_num + 1;
            l_new_op_seq_num  := 10;
          END IF;
        END IF;

        --Set new values for work_order_seq_num and op_seq_num
        px_ce_wo_ln_tbl(i).WORK_ORDER_SEQ_NUM          := l_new_wo_seq_num;
        px_ce_wo_ln_tbl(i).OP_SEQ_NUM                  := l_new_op_seq_num;
      ELSIF p_group_option = 'Activity' THEN
        IF i = 1 THEN
          l_tmp_cu_id       := px_ce_wo_ln_tbl(i).SRC_CU_ID;
          l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
          l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;

          l_new_wo_seq_num  := 1;
          l_new_op_seq_num  := 10;
        ELSE
          IF (NVL(l_tmp_cu_id, 0) = NVL(px_ce_wo_ln_tbl(i).SRC_CU_ID, 0)) THEN
            --Same CU as the last wo line
            IF (l_tmp_actvity_id  = px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID) THEN
              --Same activity as the last wo line
              IF (l_tmp_op_seq_num  <> px_ce_wo_ln_tbl(i).OP_SEQ_NUM) THEN
                --Different op_seq_num as the last wo line
                --Update l_tmp_op_seq_num with new op_seq_num
                l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
                --Increase l_new_op_seq_num by 10
                l_new_op_seq_num := l_new_op_seq_num + 10;
              END IF;
            ELSE
              --Different activity as the last wo line
              --Update l_tmp_actvity_id and l_tmp_op_seq_num
              l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
              l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
              --Increase l_new_wo_seq_num by 1
              --Reset l_new_op_seq_num to 10
              l_new_wo_seq_num  := l_new_wo_seq_num + 1;
              l_new_op_seq_num  := 10;
            END IF;
          ELSE
            --Different CU as the last wo line
            --Update l_tmp_cu_id, l_tmp_actvity_id and l_tmp_op_seq_num
            l_tmp_cu_id       := px_ce_wo_ln_tbl(i).SRC_CU_ID;
            l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
            l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
            --Increase l_new_wo_seq_num by 1
            --Reset l_new_op_seq_num to 10
            l_new_wo_seq_num  := l_new_wo_seq_num + 1;
            l_new_op_seq_num  := 10;
          END IF;
        END IF;

        --Set new values for work_order_seq_num and op_seq_num
        px_ce_wo_ln_tbl(i).WORK_ORDER_SEQ_NUM          := l_new_wo_seq_num;
        px_ce_wo_ln_tbl(i).OP_SEQ_NUM                  := l_new_op_seq_num;
      ELSIF p_group_option = 'WIP Accounting Class' THEN
        IF i = 1 THEN
          l_tmp_acct_class_code := NVL(px_ce_wo_ln_tbl(i).ACCT_CLASS_CODE, 'DEFAULT');
          l_tmp_cu_id           := px_ce_wo_ln_tbl(i).SRC_CU_ID;
          l_tmp_actvity_id      := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
          l_tmp_op_seq_num      := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;

          l_new_wo_seq_num  := 1;
          l_new_op_seq_num  := 10;
        ELSE
          IF (NVL(l_tmp_acct_class_code, 'DEFAULT') = NVL(px_ce_wo_ln_tbl(i).ACCT_CLASS_CODE, 'DEFAULT')) THEN
            --Same WIP accounting class code as the last wo line
            IF (NVL(l_tmp_cu_id, 0) = NVL(px_ce_wo_ln_tbl(i).SRC_CU_ID, 0)) THEN
              --Same CU as the last wo line
              IF (l_tmp_actvity_id  = px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID) THEN
                --Same activity as the last wo line
                IF (l_tmp_op_seq_num  <> px_ce_wo_ln_tbl(i).OP_SEQ_NUM) THEN
                  --Different op_seq_num as the last wo line
                  --Update l_tmp_op_seq_num with new op_seq_num
                  l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
                  --Increase l_new_op_seq_num by 10
                  l_new_op_seq_num := l_new_op_seq_num + 10;
                END IF;
              ELSE
                --Different activity as the last wo line
                --Update l_tmp_actvity_id and l_tmp_op_seq_num
                l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
                l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
                --Increase l_new_op_seq_num by 10
                l_new_op_seq_num := l_new_op_seq_num + 10;
              END IF;
            ELSE
              --Different CU as the last wo line
              --Update l_tmp_cu_id, l_tmp_actvity_id and l_tmp_op_seq_num
              l_tmp_cu_id       := px_ce_wo_ln_tbl(i).SRC_CU_ID;
              l_tmp_actvity_id  := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
              l_tmp_op_seq_num  := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
              --Increase l_new_op_seq_num by 10
              l_new_op_seq_num := l_new_op_seq_num + 10;
            END IF;
          ELSE
            --Different WIP accounting class code as the last wo line
            --Update l_tmp_acct_class_code, l_tmp_cu_id, l_tmp_actvity_id and l_tmp_op_seq_num
            l_tmp_acct_class_code := px_ce_wo_ln_tbl(i).ACCT_CLASS_CODE;
            l_tmp_cu_id           := px_ce_wo_ln_tbl(i).SRC_CU_ID;
            l_tmp_actvity_id      := px_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID;
            l_tmp_op_seq_num      := px_ce_wo_ln_tbl(i).OP_SEQ_NUM;
            --Increase l_new_wo_seq_num by 1
            --Reset l_new_op_seq_num to 10
            l_new_wo_seq_num  := l_new_wo_seq_num + 1;
            l_new_op_seq_num  := 10;
          END IF;
        END IF;

        --Set new values for work_order_seq_num and op_seq_num
        px_ce_wo_ln_tbl(i).WORK_ORDER_SEQ_NUM          := l_new_wo_seq_num;
        px_ce_wo_ln_tbl(i).OP_SEQ_NUM                  := l_new_op_seq_num;
      ELSIF p_group_option = 'None' THEN
        --NULL out work_order_seq_num and op_seq_num
        px_ce_wo_ln_tbl(i).WORK_ORDER_SEQ_NUM          := NULL;
        --px_ce_wo_ln_tbl(i).OP_SEQ_NUM                  := NULL;
      ELSE
        --Unsupported group option
        FND_MESSAGE.SET_NAME('EAM','EAM_UNSUPPORTED_GROUP_OPTION');
        FND_MESSAGE.SET_TOKEN('OPTION', p_group_option);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF;
END RESOLVE_SORT_CONTENTION;

PROCEDURE UPDATE_CE_WO_LNS_BY_GROUP_OPT(
          p_api_version       IN NUMBER,
          p_commit            IN VARCHAR2,
          p_init_msg_list     IN VARCHAR2,
          p_validation_level  IN NUMBER,
          p_ce_wo_defaults    IN EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WO_DEFAULTS_REC,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  --Note: When order by a column, all rows with that column having the value of NULL
  --would come last in the sorted list

  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_CE_WO_LNS_BY_GROUP_OPT';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_debug_filename        VARCHAR(50)           := G_DEBUG_FILENAME;
  l_debug                 VARCHAR2(1)           := 'N';
  l_group_option          VARCHAR2(80);
  l_ce_wo_ln_tbl          EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_TBL;
BEGIN
  SAVEPOINT UPDATE_CE_WO_LNS_BY_GROUP_OPT;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.INITIALIZE;
  END IF;

  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INIT_DEBUG(
    p_init_msg_list       => p_init_msg_list,
    p_debug_filename      => l_debug_filename,
    p_debug_file_mode     => 'W',
    p_debug               => l_debug);

  IF (l_debug = 'Y') THEN
    DEBUG('UPDATE_CE_WO_LNS_BY_GROUP_OPT ' ||
           p_api_version       ||'-'||
           p_commit            ||'-'||
           p_init_msg_list     ||'-'||
           p_validation_level);
    DEBUG('DUMP EAM_CE_WO_DEFAULTS_REC');
    DEBUG(' ESTIMATE_ID               : ' || p_ce_wo_defaults.ESTIMATE_ID);
    DEBUG(' DEFAULT_WORK_ORDER_NUMBER : ' || p_ce_wo_defaults.DEFAULT_WORK_ORDER_NUMBER);
    DEBUG(' ORGANIZATION_ID           : ' || p_ce_wo_defaults.ORGANIZATION_ID);
    DEBUG(' ASSET_GROUP_ID            : ' || p_ce_wo_defaults.ASSET_GROUP_ID);
    DEBUG(' ASSET_NUMBER              : ' || p_ce_wo_defaults.ASSET_NUMBER);
    DEBUG(' MAINTENANCE_OBJECT_ID     : ' || p_ce_wo_defaults.MAINTENANCE_OBJECT_ID);
    DEBUG(' MAINTENANCE_OBJECT_TYPE   : ' || p_ce_wo_defaults.MAINTENANCE_OBJECT_TYPE);
    DEBUG(' MAINTENANCE_OBJECT_SOURCE : ' || p_ce_wo_defaults.MAINTENANCE_OBJECT_SOURCE);
    DEBUG(' WORK_ORDER_DESCRIPTION    : ' || p_ce_wo_defaults.WORK_ORDER_DESCRIPTION);
    DEBUG(' ACCT_CLASS_CODE           : ' || p_ce_wo_defaults.ACCT_CLASS_CODE);
    DEBUG(' PROJECT_ID                : ' || p_ce_wo_defaults.PROJECT_ID);
    DEBUG(' TASK_ID                   : ' || p_ce_wo_defaults.TASK_ID);
    DEBUG(' SCHEDULED_START_DATE      : ' || p_ce_wo_defaults.SCHEDULED_START_DATE);
    DEBUG(' SCHEDULED_COMPLETION_DATE : ' || p_ce_wo_defaults.SCHEDULED_COMPLETION_DATE);
    DEBUG(' USER_DEFINED_STATUS_ID    : ' || p_ce_wo_defaults.USER_DEFINED_STATUS_ID);
    DEBUG(' GROUPING_OPTION           : ' || p_ce_wo_defaults.GROUPING_OPTION);
  END IF;

  BEGIN
    SELECT MEANING
    INTO l_group_option
    FROM MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'CONSTRUCTION_GROUP_OPTIONS'
    AND ENABLED_FLAG = 'Y'
    AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE-1)
    AND NVL(END_DATE_ACTIVE, SYSDATE+1)
    AND LOOKUP_CODE = p_ce_wo_defaults.GROUPING_OPTION;
  EXCEPTION
    WHEN OTHERS THEN
      --Unsupported group option
      FND_MESSAGE.SET_NAME('EAM','EAM_ERROR_DERIVE_GROUP_OPTION');
      FND_MESSAGE.SET_TOKEN('OPTION_ID', p_ce_wo_defaults.GROUPING_OPTION);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;

 IF l_group_option = 'None'
    OR  l_group_option = 'Activity'
    OR  l_group_option = 'Construction Unit'
    OR  l_group_option = 'Single Work Order'
    OR  l_group_option = 'WIP Accounting Class'
  THEN
    --First retrive the wo lines for this estimate in the order specified by the group option
    GET_CE_WO_LNS_BY_GROUP_OPT(
      p_ce_id         => p_ce_wo_defaults.ESTIMATE_ID,
      p_group_option  => l_group_option,
      x_ce_wo_ln_tbl  => l_ce_wo_ln_tbl);

    IF l_ce_wo_ln_tbl.COUNT > 0 THEN
      SET_WO_LNS_FROM_WO_DEFAULTS(
        p_ce_wo_defaults => p_ce_wo_defaults,
        p_group_option   => l_group_option,
        px_ce_wo_ln_tbl  => l_ce_wo_ln_tbl);

      RESOLVE_SORT_CONTENTION(
        p_group_option   => l_group_option,
        px_ce_wo_ln_tbl  => l_ce_wo_ln_tbl);
    END IF;
  ELSE
    --Unsupported group option
    FND_MESSAGE.SET_NAME('EAM','EAM_UNSUPPORTED_GROUP_OPTION');
    FND_MESSAGE.SET_TOKEN('OPTION', l_group_option);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Now update the wo lines
  IF l_ce_wo_ln_tbl.COUNT > 0 THEN
    FOR i IN l_ce_wo_ln_tbl.FIRST..l_ce_wo_ln_tbl.LAST LOOP
      EAM_CE_WORK_ORDER_LINES_PKG.UPDATE_ROW(
        p_estimate_work_order_line_id    	=> l_ce_wo_ln_tbl(i).ESTIMATE_WORK_ORDER_LINE_ID,
        p_estimate_work_order_id          => FND_API.G_MISS_NUM,
        p_src_cu_id                       => l_ce_wo_ln_tbl(i).SRC_CU_ID,
        p_src_activity_id                	=> l_ce_wo_ln_tbl(i).SRC_ACTIVITY_ID,
        p_src_activity_qty                => l_ce_wo_ln_tbl(i).SRC_ACTIVITY_QTY,
        p_src_op_seq_num                 	=> l_ce_wo_ln_tbl(i).SRC_OP_SEQ_NUM,
        p_src_acct_class_code             => l_ce_wo_ln_tbl(i).SRC_ACCT_CLASS_CODE,
        p_src_diff_id                     => l_ce_wo_ln_tbl(i).DIFFICULTY_ID,
        p_diff_qty                        => l_ce_wo_ln_tbl(i).DIFFICULTY_QTY,
        p_estimate_id                    	=> l_ce_wo_ln_tbl(i).ESTIMATE_ID,
        p_organization_id                	=> l_ce_wo_ln_tbl(i).ORGANIZATION_ID,
        p_work_order_seq_num             	=> l_ce_wo_ln_tbl(i).WORK_ORDER_SEQ_NUM,
        p_work_order_number              	=> l_ce_wo_ln_tbl(i).WORK_ORDER_NUMBER,
        p_work_order_description         	=> l_ce_wo_ln_tbl(i).WORK_ORDER_DESCRIPTION,
        p_ref_wip_entity_id              	=> l_ce_wo_ln_tbl(i).REF_WIP_ENTITY_ID,
        p_primary_item_id                	=> l_ce_wo_ln_tbl(i).PRIMARY_ITEM_ID,
        p_status_type                    	=> l_ce_wo_ln_tbl(i).STATUS_TYPE,
        p_acct_class_code                	=> l_ce_wo_ln_tbl(i).ACCT_CLASS_CODE,
        p_scheduled_start_date           	=> l_ce_wo_ln_tbl(i).SCHEDULED_START_DATE,
        p_scheduled_completion_date      	=> l_ce_wo_ln_tbl(i).SCHEDULED_COMPLETION_DATE,
        p_project_id                     	=> l_ce_wo_ln_tbl(i).PROJECT_ID,
        p_task_id                        	=> l_ce_wo_ln_tbl(i).TASK_ID,
        p_maintenance_object_id          	=> l_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_ID,
        p_maintenance_object_type        	=> l_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_TYPE,
        p_maintenance_object_source      	=> l_ce_wo_ln_tbl(i).MAINTENANCE_OBJECT_SOURCE,
        p_owning_department_id           	=> l_ce_wo_ln_tbl(i).OWNING_DEPARTMENT_ID,
        p_user_defined_status_id         	=> l_ce_wo_ln_tbl(i).USER_DEFINED_STATUS_ID,
        p_op_seq_num                     	=> l_ce_wo_ln_tbl(i).OP_SEQ_NUM,
        p_op_description                 	=> l_ce_wo_ln_tbl(i).OP_DESCRIPTION,
        p_standard_operation_id          	=> l_ce_wo_ln_tbl(i).STANDARD_OPERATION_ID,
        p_op_department_id               	=> l_ce_wo_ln_tbl(i).OP_DEPARTMENT_ID,
        p_op_long_description            	=> l_ce_wo_ln_tbl(i).OP_LONG_DESCRIPTION,
        p_res_seq_num                    	=> l_ce_wo_ln_tbl(i).RES_SEQ_NUM,
        p_res_id                         	=> l_ce_wo_ln_tbl(i).RES_ID,
        p_res_uom                        	=> l_ce_wo_ln_tbl(i).RES_UOM,
        p_res_basis_type                 	=> l_ce_wo_ln_tbl(i).RES_BASIS_TYPE,
        p_res_usage_rate_or_amount       	=> l_ce_wo_ln_tbl(i).RES_USAGE_RATE_OR_AMOUNT,
        p_res_required_units             	=> l_ce_wo_ln_tbl(i).RES_REQUIRED_UNITS,
        p_res_assigned_units             	=> l_ce_wo_ln_tbl(i).RES_ASSIGNED_UNITS,
        p_item_type                       => l_ce_wo_ln_tbl(i).ITEM_TYPE,
        p_required_quantity               => l_ce_wo_ln_tbl(i).REQUIRED_QUANTITY,
        p_unit_price                      => l_ce_wo_ln_tbl(i).UNIT_PRICE,
        p_uom                             => l_ce_wo_ln_tbl(i).UOM,
        p_basis_type                      => l_ce_wo_ln_tbl(i).BASIS_TYPE,
        p_suggested_vendor_name           => l_ce_wo_ln_tbl(i).SUGGESTED_VENDOR_NAME,
        p_suggested_vendor_id             => l_ce_wo_ln_tbl(i).SUGGESTED_VENDOR_ID,
        p_suggested_vendor_site           => l_ce_wo_ln_tbl(i).SUGGESTED_VENDOR_SITE,
        p_suggested_vendor_site_id        => l_ce_wo_ln_tbl(i).SUGGESTED_VENDOR_SITE_ID,
        p_mat_inventory_item_id           => l_ce_wo_ln_tbl(i).MAT_INVENTORY_ITEM_ID,
        p_mat_component_seq_num           => l_ce_wo_ln_tbl(i).MAT_COMPONENT_SEQ_NUM,
        p_mat_supply_subinventory         => l_ce_wo_ln_tbl(i).MAT_SUPPLY_SUBINVENTORY,
        p_mat_supply_locator_id           => l_ce_wo_ln_tbl(i).MAT_SUPPLY_LOCATOR_ID,
        p_di_amount                       => l_ce_wo_ln_tbl(i).DI_AMOUNT,
        p_di_order_type_lookup_code       => l_ce_wo_ln_tbl(i).DI_ORDER_TYPE_LOOKUP_CODE,
        p_di_description                  => l_ce_wo_ln_tbl(i).DI_DESCRIPTION,
        p_di_purchase_category_id         => l_ce_wo_ln_tbl(i).DI_PURCHASE_CATEGORY_ID,
        p_di_auto_request_material        => l_ce_wo_ln_tbl(i).DI_AUTO_REQUEST_MATERIAL,
        p_di_need_by_date                 => l_ce_wo_ln_tbl(i).DI_NEED_BY_DATE,
        p_work_order_line_cost           	=> l_ce_wo_ln_tbl(i).WORK_ORDER_LINE_COST,
        p_creation_date                   => FND_API.G_MISS_DATE,
        p_created_by                     	=> FND_API.G_MISS_NUM,
        p_last_update_date               	=> SYSDATE,
        p_last_updated_by                	=> FND_GLOBAL.USER_ID,
        p_last_update_login  	            => FND_GLOBAL.USER_ID
        ,p_work_order_type                =>   l_ce_wo_ln_tbl(i).WORK_ORDER_TYPE
        ,p_activity_type                  =>   l_ce_wo_ln_tbl(i).ACTIVITY_TYPE
        ,p_activity_source                =>    l_ce_wo_ln_tbl(i).ACTIVITY_SOURCE
        ,p_activity_cause                 =>    l_ce_wo_ln_tbl(i).ACTIVITY_CAUSE
        ,p_available_qty                  =>   l_ce_wo_ln_tbl(i).AVAILABLE_QUANTITY
        ,p_item_comments                  =>   l_ce_wo_ln_tbl(i).ITEM_COMMENTS
        ,p_cu_qty                         =>   l_ce_wo_ln_tbl(i).CU_QTY
        ,p_res_sch_flag                   =>   l_ce_wo_ln_tbl(i).RES_SCHEDULED_FLAG);
    END LOOP;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_CE_WO_LNS_BY_GROUP_OPT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_CE_WO_LNS_BY_GROUP_OPT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_CE_WO_LNS_BY_GROUP_OPT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
END UPDATE_CE_WO_LNS_BY_GROUP_OPT;

PROCEDURE CREATE_CU_WORKORDERS(
       p_api_version                 IN    NUMBER        := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_estimate_id                 IN    NUMBER
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
      ,p_organization_id             IN    NUMBER
      ,p_debug_filename          IN  VARCHAR2 := 'EAM_CU_DEBUG.log'
      ,p_debug_file_mode         IN  VARCHAR2 := 'w'
)

IS

	l_api_name           CONSTANT VARCHAR(30) := 'create_cu_workorders';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_return_status      VARCHAR2(250);
	l_stmt_num  NUMBER := 0;

	l_wo_seq_exists NUMBER := 0;
	l_wo_exists NUMBER := 0;
	l_noasset NUMBER :=0;
	l_header_id NUMBER := 0;
	l_batch_id NUMBER := 0;
	l_op_seq NUMBER := 0;
	l_res_seq NUMBER :=-99;
	l_mat_seq NUMBER := -99;
	l_direct_desc VARCHAR2(30) := NULL;
	l_api_message VARCHAR2(1000);
	l_msg_count                 NUMBER := 0;
	l_msg_data                  VARCHAR2(8000);
	l_wo_seq NUMBER := 0;
	l_previous_wo_seq NUMBER := 0;
	l_previous_op_seq NUMBER := 0;
	l_previous_res_seq NUMBER := 0;
	l_parent_wo NUMBER;
	wo NUMBER := 0;
	op NUMBER :=0;
	res NUMBER :=0;
	mat NUMBER :=0;
	di NUMBER :=0;
	l_output_dir VARCHAR2(512);
	l_debug VARCHAR2(1) := 'Y';
	l_create_parent VARCHAR2(1) := 'N';
	l_parent_job_id NUMBER := -99;
	l_parent_wip_entity_id NUMBER := -99;
	i NUMBER := 0;

	msg_index number;
	temp_err_mesg varchar2(4000);


	l_ce_lines_rec EAM_CE_WORK_ORDER_LINES%ROWTYPE;
	l_ce_parent_rec EAM_CE_WORK_ORDER_LINES%ROWTYPE;
	--l_ce_lines_tbl celines_table_type;

	l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_out_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;
	l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

	l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_eam_empty_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_eam_wo_tbl EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_op_rec EAM_PROCESS_WO_PUB.eam_op_rec_type;
	l_eam_empty_op_rec EAM_PROCESS_WO_PUB.eam_op_rec_type;
	l_eam_res_rec EAM_PROCESS_WO_PUB.eam_res_rec_type;
	l_eam_mat_rec EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
	l_eam_direct_rec EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;

	l_eam_op_tbl EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_wo_comp_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_workorder_rec1 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_workorder_rec2 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_workorder_rec3 EAM_PROCESS_WO_PUB.eam_wo_rec_type;

	l_eam_op_tbl1  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_tbl2  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_op_network_tbl1  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_op_network_tbl2  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_tbl1  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_tbl2  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_res_inst_tbl1  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_res_inst_tbl2  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_sub_res_tbl1   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_sub_res_tbl2   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_res_usage_tbl1  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_res_usage_tbl2  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_mat_req_tbl1   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_mat_req_tbl2   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_wip_entity_id            NUMBER;
	l_wip_entity_name          VARCHAR2(240);

	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl1      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl2      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_relation_rec      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;

	l_eam_wo_tbl1               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl2               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl3               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;

	l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_direct_items_tbl_1	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

   CURSOR c_ecwl IS
    SELECT *
    FROM EAM_CE_WORK_ORDER_LINES
    WHERE organization_id = p_organization_id
    AND estimate_id = p_estimate_id
    AND estimate_work_order_line_id NOT IN (SELECT parent_wo_id
                    FROM EAM_CONSTRUCTION_ESTIMATES
                    WHERE ORGANIZATION_ID = P_ORGANIzATION_ID
                    AND estimate_id = p_estimate_id
                    AND nvl(create_parent_wo_flag, 'N') = 'Y'
                    )
    ORDER BY
          work_order_seq_num,
          op_seq_num,
          res_seq_num;

BEGIN

   -------------------------------------------------------------------------
    -- standard start of API savepoint
    -------------------------------------------------------------------------
     --dbms_output.put_line('1');
    SAVEPOINT CREATE_CU_WORKORDERS;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------
     --dbms_output.put_line('2');
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_return_status := fnd_api.g_ret_sts_success;

    -- assign to local variables
    l_stmt_num := 10;

    -------------------------------------------------------------------------
    -- Open Debug
    -------------------------------------------------------------------------

        EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);
          -- Set the global variable for debug.

        IF l_debug = 'Y'
        THEN

            IF trim(l_output_dir) IS NULL OR trim(l_output_dir) = ''
            THEN

            -- If debug is Y then out dir must be specified

                l_out_mesg_token_tbl := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_text       => 'Debug is set to Y so an output directory' || ' must be specified. Debug will be turned' || ' off since no directory is specified'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_out_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
                 );
                l_mesg_token_tbl := l_out_mesg_token_tbl;

               l_debug := 'N';

            END IF;

            IF trim(p_debug_filename) IS NULL OR trim(p_debug_filename) = ''
            THEN

                l_out_mesg_token_tbl := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_text       => 'Debug is set to Y so an output filename' || ' must be specified. Debug will be turned' || ' off since no filename is specified'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_out_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
                 );
                l_mesg_token_tbl := l_out_mesg_token_tbl;

                l_debug:= 'N';

            END IF;

           IF l_debug = 'Y'
            THEN
                l_out_mesg_token_tbl    := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Open_Debug_Session
                (  p_debug_filename     => p_debug_filename
                ,  p_output_dir         => l_output_dir
                ,  p_debug_file_mode    => p_debug_file_mode
                ,  x_return_status      => l_return_status
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  x_mesg_token_tbl     => l_out_mesg_token_tbl
                 );
                l_mesg_token_tbl        := l_out_mesg_token_tbl;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    --dbms_output.put_line ('Unable to open file for debug');
                    EAM_PROCESS_WO_PVT.Set_Debug('N');
                END IF;
            END IF;

        END IF;

    -------------------------------------------------------------------------
    -- Select parent WO details
    -------------------------------------------------------------------------

      SELECT nvl(create_parent_wo_flag, 'N'), parent_wo_id
      INTO l_create_parent, l_parent_job_id
      FROM EAM_CONSTRUCTION_ESTIMATES
      WHERE organization_id = p_organization_id
      AND estimate_id = p_estimate_id;

    -------------------------------------------------------------------------
    -- Check All CE Lines have a WO Sequence
    -------------------------------------------------------------------------
      BEGIN
         --dbms_output.put_line('3');

       IF nvl(l_create_parent, 'N') = 'N' THEN
        --dbms_output.put_line('create parent no');
        SELECT 1
        INTO l_wo_seq_exists
        FROM EAM_CE_WORK_ORDER_LINES
        WHERE organization_id = p_organization_id
        AND estimate_id = p_estimate_id
        AND work_order_seq_num IS NULL
        AND rownum = 1;

       ELSE
        --dbms_output.put_line('create parent yes');
        SELECT 1
        INTO l_wo_seq_exists
        FROM EAM_CE_WORK_ORDER_LINES
        WHERE organization_id = p_organization_id
        AND estimate_id = p_estimate_id
        AND work_order_seq_num IS NULL
        AND estimate_work_order_line_id <> l_parent_job_id
        AND rownum = 1;

       END IF;

        l_stmt_num := 20;

        IF l_wo_seq_exists = 1 THEN
          /* lOG errro */
           --dbms_output.put_line('4');
          RAISE FND_API.g_exc_error;
        END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

      END;



    -------------------------------------------------------------------------
    -- Check NO CE LINE already has a work order
    -------------------------------------------------------------------------
      BEGIN
         --dbms_output.put_line('3');
        SELECT 1
        INTO l_wo_exists
        FROM EAM_CE_WORK_ORDER_LINES
        WHERE organization_id = p_organization_id
        AND estimate_id = p_estimate_id
        AND estimate_work_order_id IS NOT NULL
        AND rownum = 1;

        l_stmt_num := 25;

        IF l_wo_exists = 1 THEN
          /* lOG errro */
           --dbms_output.put_line('4');
          RAISE FND_API.g_exc_error;
        END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

      END;

    -------------------------------------------------------------------------
    -- Check all WO lines have an asset
    -------------------------------------------------------------------------
      BEGIN
         --dbms_output.put_line('5');
        SELECT 1
        INTO l_noasset
        FROM EAM_CE_WORK_ORDER_LINES
        WHERE organization_id = p_organization_id
        AND estimate_id = p_estimate_id
        AND maintenance_object_id IS NULL
        AND rownum = 1;

        l_stmt_num := 29;

        IF l_noasset = 1 THEN
          /* lOG errro */
           --dbms_output.put_line('4');
          RAISE FND_API.g_exc_error;
        END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

      END;

    -------------------------------------------------------------------------
    -- First Create the Parent WO
    -------------------------------------------------------------------------
    l_stmt_num := 30;

    BEGIN

      --dbms_output.put_line('Creating parent');

      IF NVL(l_create_parent, 'N') = 'Y' THEN
        /* Create the Parent WO */
        --dbms_output.put_line('Creating parent 2' || l_parent_job_id);
        BEGIN
        SELECT *
        INTO l_ce_parent_rec
        FROM EAM_CE_WORK_ORDER_LINES
        WHERE estimate_work_order_line_id = l_parent_job_id;
        --dbms_output.put_line('Creating parent 3' || l_parent_job_id);

        l_eam_wo_rec := l_eam_empty_wo_rec;
        l_eam_wo_tbl := l_eam_wo_tbl3;

        l_eam_wo_rec.header_id := 1;
        l_eam_wo_rec.batch_id := 1;
        l_stmt_num := 35;
        --dbms_output.put_line('Calling PWO');
        Populate_WO   (
          p_parent_wo  => null
         , p_ce_line_rec       => l_ce_parent_rec
        ,  x_eam_wo_rec       => l_eam_wo_rec
        ,  x_return_status     => l_return_status
        ,  x_msg_count        => l_msg_count
        ,  x_msg_data         => l_msg_data);
        --dbms_output.put_line('Back Calling PWO');

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            --dbms_output.put_line('New WO error...');
            --EAM_CONSTRUCTION_MESSAGE_PVT.debug(l_msg_data);
             l_api_message := 'Populate_WO returned error';
             --FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_pub.add;
             RAISE FND_API.g_exc_error;
        END IF;

        l_eam_wo_tbl(1) := l_eam_wo_rec;
        --dbms_output.put_line('Calling WO API for parent');
          EAM_PROCESS_WO_PUB.Process_Master_Child_WO
          ( p_bo_identifier           => 'EAM'
          , p_init_msg_list           => TRUE
          , p_api_version_number      => 1.0
          , p_eam_wo_tbl              => l_eam_wo_tbl
          , p_eam_wo_relations_tbl   => l_eam_wo_relations_tbl
          , p_eam_op_tbl              => l_eam_op_tbl
          , p_eam_op_network_tbl      => l_eam_op_network_tbl
          , p_eam_res_tbl             => l_eam_res_tbl
          , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
          , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
          , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
          , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
          , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
          , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
          , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
          , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
          , p_eam_counter_prop_tbl     => l_eam_counter_prop_tbl
          , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
          , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
          , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
          , p_eam_request_tbl          => l_eam_request_tbl
          , x_eam_wo_tbl              => l_eam_wo_tbl1
          , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
          , x_eam_op_tbl              => l_eam_op_tbl1
          , x_eam_op_network_tbl      => l_eam_op_network_tbl1
          , x_eam_res_tbl             => l_eam_res_tbl1
          , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
          , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
          , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
          , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
          , x_eam_direct_items_tbl    =>   l_eam_direct_items_tbl_1
          , x_eam_wo_comp_tbl        => l_out_eam_wo_comp_tbl
          , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
          , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
          , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
          , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
          , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
          , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
          , x_eam_request_tbl          => l_out_eam_request_tbl
          , x_return_status           => l_return_status
          , x_msg_count               => l_msg_count
          , p_debug                   => 'Y' --NVL(fnd_profile.value('EAM_DEBUG'), 'N')
          , p_debug_filename          => 'createcu3.log'
          , p_output_dir              => l_output_dir
          , p_commit                  => 'N'
          , p_debug_file_mode         => 'w'
          );
            --dbms_output.put_line('Back from creating pwo');
            x_return_status := l_return_status;
            x_msg_count   := l_msg_count;
            --dbms_output.put_line('Back from creating pwo' || l_return_status || x_return_status);


            IF(x_return_status <> 'S') then
              --dbms_output.put_line('Error after creating pwo' || SQLERRM);
               --  ROLLBACK TO CREATE_CU_WORKORDERS;
              RAISE  FND_API.G_EXC_ERROR;
            END IF;

           UPDATE  EAM_CE_WORK_ORDER_LINES
           SET estimate_work_order_id = l_eam_wo_tbl1(1).wip_entity_id
           WHERE estimate_work_order_line_id = l_parent_job_id;

           UPDATE eam_work_order_details
           SET estimate_id = p_estimate_id
           WHERE wip_entity_id = l_eam_wo_tbl1(1).wip_entity_id
           AND organization_id = l_eam_wo_tbl1(1).organization_id;

           l_parent_job_id := l_eam_wo_tbl1(1).wip_entity_id;


        EXCEPTION
          WHEN OTHERS THEN
            --dbms_output.put_line('Creating parent 2' || l_stmt_num || SQLERRM);
            RAISE FND_API.g_exc_error;
        END;


      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE FND_API.g_exc_error;

    END;

    -------------------------------------------------------------------------
    -- For each Work Order line, populate the WO API tables
    -------------------------------------------------------------------------
    l_eam_wo_tbl1 := l_eam_wo_tbl2; --making the wo table empty again

    l_stmt_num := 80;
    FOR c_ecwl_rec IN c_ecwl LOOP

      l_stmt_num := 82;

      l_wo_seq := c_ecwl_rec.work_order_seq_num;

      --dbms_output.put_line('Inside loop...');

      IF (l_debug = 'Y') THEN
       EAM_ERROR_MESSAGE_PVT.Write_Debug('Inside the Loop ...') ;
      END IF;

      IF (l_previous_wo_seq = 0) OR (l_wo_seq <> l_previous_wo_seq) THEN

      /* New Work Order*/
      --dbms_output.put_line('New WO...');
        l_stmt_num := 86;
        wo := wo + 1;
        l_eam_wo_rec := l_eam_empty_wo_rec;
        l_eam_relation_rec := null;

        --dbms_output.put_line('New WO...' || wo);

        l_eam_wo_rec.header_id := wo;
        l_eam_wo_rec.batch_id := l_wo_seq;
        l_stmt_num := 88;

        Populate_WO   ( p_parent_wo        => null
        ,  p_ce_line_rec       => c_ecwl_rec
        ,  x_eam_wo_rec       => l_eam_wo_rec
        ,  x_return_status     => l_return_status
        ,  x_msg_count        => l_msg_count
        ,  x_msg_data         => l_msg_data);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            --dbms_output.put_line('New WO error...' || wo);
            --EAM_CONSTRUCTION_MESSAGE_PVT.debug(l_msg_data);
             l_api_message := 'Populate_WO returned error';
             --FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_pub.add;
             RAISE FND_API.g_exc_error;
        END IF;


        l_eam_wo_tbl(wo) := l_eam_wo_rec;
        l_previous_wo_seq := l_wo_seq;

        --dbms_output.put_line('WO...' || l_eam_wo_tbl(1).header_id);

        /* Populate the Relationship Record */
        IF nvl(l_parent_job_id, -99) <> -99 THEN

          l_eam_relation_rec.batch_id  :=  wo;
          l_eam_relation_rec.parent_object_id := l_parent_job_id;
          l_eam_relation_rec.parent_object_type_id := 1;
          l_eam_relation_rec.parent_header_id := l_parent_job_id;
          l_eam_relation_rec.child_object_type_id := 1;
          l_eam_relation_rec.child_header_id    :=wo;
          l_eam_relation_rec.child_object_id    :=wo;
          l_eam_relation_rec.parent_relationship_type  := 1;
          l_eam_relation_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

          l_eam_wo_relations_tbl(wo)   := l_eam_relation_rec;

        END IF;

      END IF; --wo seq comparison

      l_op_seq := c_ecwl_rec.op_seq_num;

      IF (l_op_seq <> l_previous_op_seq) OR (l_previous_op_seq =0 ) THEN
        /* New Operation */
        l_stmt_num := 92;
        op := op + 1;
        l_eam_op_rec := l_eam_empty_op_rec;

        l_eam_op_rec.header_id := wo;
        l_eam_op_rec.batch_id := l_wo_seq;

        POPULATE_OPERATION (  p_ce_line_rec      => c_ecwl_rec
        ,  x_eam_op_rec        => l_eam_op_rec
        ,  x_return_status    => l_return_status
        ,  x_msg_count         => l_msg_count
        ,  x_msg_data         => l_msg_data);


         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            --EAM_CONSTRUCTION_MESSAGE_PVT.debug(l_msg_data);
             l_api_message := 'POPULATE_OPERATION returned error';
             --FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_pub.add;
             RAISE FND_API.g_exc_error;
        END IF;


        l_eam_op_tbl(op) := l_eam_op_rec;
        l_previous_op_seq := l_op_seq;

      END IF; --op seq comparison

      l_res_seq := c_ecwl_rec.res_id;
      --dbms_output.put_line('Inside resource- ID...' || l_res_seq);

      IF (l_res_seq IS NOT null) OR (l_res_seq <> -99) OR (l_res_seq <> FND_API.G_MISS_NUM)  THEN
       --dbms_output.put_line('Inside resource...' || l_eam_wo_tbl(1).header_id);
        /* This is a Resource Line */
        l_stmt_num := 120;
        res := res + 1;
        l_eam_res_rec := null;

        l_eam_res_rec.header_id := wo;
        l_eam_res_rec.batch_id := l_wo_seq;

        POPULATE_RESOURCE (  p_ce_line_rec      => c_ecwl_rec
        ,  x_eam_res_rec        => l_eam_res_rec
        ,  x_return_status    => l_return_status
        ,  x_msg_count         => l_msg_count
        ,  x_msg_data         => l_msg_data);


         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            --EAM_CONSTRUCTION_MESSAGE_PVT.debug(l_msg_data);
             l_api_message := 'POPULATE_RESOURCE returned error';
             --FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_pub.add;
             RAISE FND_API.g_exc_error;
        END IF;


        l_eam_res_tbl(res) := l_eam_res_rec;

      END IF; --res id comparison

      l_mat_seq := c_ecwl_rec.mat_inventory_item_id;
      --dbms_output.put_line('Inside material- ID...' || l_mat_seq);

      IF (l_mat_seq IS NOT null) OR (l_mat_seq <> -99) OR (l_mat_seq <> FND_API.G_MISS_NUM)  THEN
       --dbms_output.put_line('Inside mat...' || l_eam_wo_tbl(1).header_id);
        /* This is a Material Line */
        l_stmt_num := 140;
        mat := mat + 1;
        l_eam_mat_rec := null;

        l_eam_mat_rec.header_id := wo;
        l_eam_mat_rec.batch_id := l_wo_seq;

        POPULATE_MATERIAL (  p_ce_line_rec      => c_ecwl_rec
        ,  x_eam_mat_rec        => l_eam_mat_rec
        ,  x_eam_direct_rec        => l_eam_direct_rec
        ,  x_return_status    => l_return_status
        ,  x_msg_count         => l_msg_count
        ,  x_msg_data         => l_msg_data);


         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            --EAM_CONSTRUCTION_MESSAGE_PVT.debug(l_msg_data);
             l_api_message := 'POPULATE_MATERIAL returned error';
             --FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_pub.add;
             RAISE FND_API.g_exc_error;
        END IF;


        l_eam_mat_req_tbl(mat) := l_eam_mat_rec;

      END IF; --mat id comparison

      l_direct_desc := c_ecwl_rec.di_description;
      --dbms_output.put_line('Inside direct- ID...' || l_direct_desc);

      IF (l_direct_desc IS NOT null) OR (l_direct_desc <> FND_API.G_MISS_CHAR)  THEN
       --dbms_output.put_line('Inside direct...' || l_eam_wo_tbl(1).header_id);
        /* This is a Material Line */
        l_stmt_num := 160;
        di := di + 1;
        l_eam_direct_rec := null;

        l_eam_direct_rec.header_id := wo;
        l_eam_direct_rec.batch_id := l_wo_seq;

        POPULATE_MATERIAL (  p_ce_line_rec      => c_ecwl_rec
        ,  x_eam_mat_rec        => l_eam_mat_rec
        ,  x_eam_direct_rec        => l_eam_direct_rec
        ,  x_return_status    => l_return_status
        ,  x_msg_count         => l_msg_count
        ,  x_msg_data         => l_msg_data);


         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            --EAM_CONSTRUCTION_MESSAGE_PVT.debug(l_msg_data);
             l_api_message := 'POPULATE_MATERIAL returned error';
             --FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
             FND_MESSAGE.set_token('TEXT', l_api_message);
             FND_MSG_pub.add;
             RAISE FND_API.g_exc_error;
        END IF;


        l_eam_direct_items_tbl(di) := l_eam_direct_rec;

      END IF; --direct desc comparison

    END LOOP;

    /* Call the WO API */
    --dbms_output.put_line('Calling WO API');
    /* --dbms_output.put_line('l_eam_wo_tbl(1).header_id...' || l_eam_wo_tbl(1).header_id);
      --dbms_output.put_line('l_eam_wo_tbl(2).header_id...' || l_eam_wo_tbl(2).header_id);
       --dbms_output.put_line('l_eam_wo_tbl(1).name...' || l_eam_wo_tbl(1).wip_entity_name);
        --dbms_output.put_line('l_eam_wo_tbl(2).name...' || l_eam_wo_tbl(2).wip_entity_name);
        --dbms_output.put_line('l_eam_op_tbl(1).header...' || l_eam_op_tbl(1).header_id);
        --dbms_output.put_line('l_eam_op_tbl(2).header...' || l_eam_op_tbl(2).header_id);*/
          EAM_PROCESS_WO_PUB.Process_Master_Child_WO
          ( p_bo_identifier           => 'EAM'
          , p_init_msg_list           => TRUE
          , p_api_version_number      => 1.0
          , p_eam_wo_tbl              => l_eam_wo_tbl
          , p_eam_wo_relations_tbl   => l_eam_wo_relations_tbl
          , p_eam_op_tbl              => l_eam_op_tbl
          , p_eam_op_network_tbl      => l_eam_op_network_tbl
          , p_eam_res_tbl             => l_eam_res_tbl
          , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
          , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
          , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
          , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
          , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
          , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
          , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
          , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
          , p_eam_counter_prop_tbl     => l_eam_counter_prop_tbl
          , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
          , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
          , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
          , p_eam_request_tbl          => l_eam_request_tbl
          , x_eam_wo_tbl              => l_eam_wo_tbl1
          , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
          , x_eam_op_tbl              => l_eam_op_tbl1
          , x_eam_op_network_tbl      => l_eam_op_network_tbl1
          , x_eam_res_tbl             => l_eam_res_tbl1
          , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
          , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
          , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
          , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
          , x_eam_direct_items_tbl    =>   l_eam_direct_items_tbl_1
          , x_eam_wo_comp_tbl        => l_out_eam_wo_comp_tbl
          , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
          , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
          , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
          , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
          , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
          , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
          , x_eam_request_tbl          => l_out_eam_request_tbl
          , x_return_status           => l_return_status
          , x_msg_count               => l_msg_count
          , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
          , p_debug_filename          => 'createcu1.log'
          , p_output_dir              => l_output_dir
          , p_commit                  => 'N'
          , p_debug_file_mode         => 'w'
          );

             x_return_status := l_return_status;
             x_msg_count   := l_msg_count;


           IF(x_return_status<>'S') then
              RAISE  FND_API.G_EXC_ERROR;
          END IF;


   /*       --dbms_output.put_line('----l_return_status---' || l_return_status);
	  --dbms_output.put_line('----x_eam_wo_rec---' || l_eam_wo_tbl1(1).WIP_ENTITY_name);
          --dbms_output.put_line('----x_eam_wo_rec---' || l_eam_wo_tbl1(2).WIP_ENTITY_name);*/

          FOR i IN l_eam_wo_tbl1.FIRST..l_eam_wo_tbl1.LAST LOOP
            BEGIN
              UPDATE  EAM_CE_WORK_ORDER_LINES
              SET estimate_work_order_id = l_eam_wo_tbl1(i).wip_entity_id
              WHERE work_order_seq_num = l_eam_wo_tbl1(i).batch_id
              and estimate_id = p_estimate_id;

              UPDATE eam_work_order_details
              SET estimate_id = p_estimate_id
              WHERE wip_entity_id = l_eam_wo_tbl1(i).wip_entity_id
              AND organization_id = l_eam_wo_tbl1(i).organization_id;

            EXCEPTION
              WHEN OTHERS THEN
                RAISE FND_API.G_EXC_ERROR;
            END;
          END LOOP;

          COMMIT;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      --ROLLBACK TO
       ROLLBACK TO CREATE_CU_WORKORDERS;
      x_return_status := fnd_api.g_ret_sts_error;
       --dbms_output.put_line('exzc');

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO CREATE_CU_WORKORDERS;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       --dbms_output.put_line('unex');

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       --dbms_output.put_line('others' || l_stmt_num);
      --
       ROLLBACK TO CREATE_CU_WORKORDERS;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'EAM_CONSTRUCTION_EST_PVT'
              , 'Create_CU_Workorders : l_stmt_num - '||to_char(l_stmt_num)
              );

        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END CREATE_CU_WORKORDERS;

procedure populate_WO(
           p_parent_wo         IN  NUMBER
        ,  p_init_msg_list     VARCHAR2 := FND_API.G_FALSE
        ,  p_ce_line_rec       IN  EAM_CE_WORK_ORDER_LINES%ROWTYPE
        ,  x_eam_wo_rec        IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
        ,  x_return_status     OUT NOCOPY VARCHAR2
        ,  x_msg_count         OUT NOCOPY  NUMBER
        ,  x_msg_data          OUT NOCOPY  VARCHAR2
) IS

  l_eam_wo_rec      EAM_PROCESS_WO_PUB.eam_wo_rec_type;
  l_stmt_num        NUMBER := 0;
  l_string          VARCHAR2(2000);
  l_item_id         NUMBER;
  l_eam_item        NUMBER;
  l_failure_required varchar2(1); -- bug 7675526
  BEGIN

  l_string := 'Inside' || G_PKG_NAME || '.Populate_WO';

  x_return_status := fnd_api.g_ret_sts_success;

   IF fnd_api.to_Boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
  end if;

  /* Is this the parent WO record */
  /* Not a parent WO record */

  /* This is a new work order */


  l_stmt_num := 50;
  l_eam_wo_rec := x_eam_wo_rec;

  --dbms_output.put_line('PWO: 1');

  /* Populate the WO Number if it has been provided by the user in the estimate */
  if p_ce_line_rec.work_order_number is not null then
      l_eam_wo_rec.wip_entity_name := p_ce_line_rec.work_order_number;
  end if;

  l_stmt_num := 60;

  l_eam_wo_rec.organization_id := p_ce_line_rec.organization_id;
  l_eam_wo_rec.FIRM_PLANNED_FLAG := 2;
  l_eam_wo_rec.description := p_ce_line_rec.work_order_description;
  --l_eam_wo_rec.inventory_item_id := p_ce_line_rec.inventory_item_id;
  l_eam_wo_rec.maintenance_object_id := p_ce_line_rec.maintenance_object_id;
  l_eam_wo_rec.maintenance_object_id := p_ce_line_rec.maintenance_object_id;
  l_eam_wo_rec.maintenance_object_type := p_ce_line_rec.maintenance_object_type;
  l_eam_wo_rec.maintenance_object_source := nvl(p_ce_line_rec.maintenance_object_source, 1);
  l_eam_wo_rec.class_code := p_ce_line_rec.acct_class_code;
  l_eam_wo_rec.activity_type := p_ce_line_rec.activity_type;
  l_eam_wo_rec.activity_cause := p_ce_line_rec.activity_cause;
  l_eam_wo_rec.activity_source := p_ce_line_rec.activity_source;
  l_eam_wo_rec.work_order_type := p_ce_line_rec.work_order_type;
  l_eam_wo_rec.status_type := nvl(p_ce_line_rec.status_type, 1);
  l_eam_wo_rec.job_quantity := 1;
  l_eam_wo_rec.owning_department := p_ce_line_rec.owning_department_id;
  l_eam_wo_rec.project_id := p_ce_line_rec.project_id;
  l_eam_wo_rec.task_id := p_ce_line_rec.task_id;
  --l_eam_wo_rec.parent_wip_entity_id := p_ce_line_rec.activity_soure;
  l_eam_wo_rec.scheduled_start_date := nvl(p_ce_line_rec.scheduled_start_date, sysdate);
  l_eam_wo_rec.scheduled_completion_date := nvl(p_ce_line_rec.scheduled_completion_date, sysdate);
  l_eam_wo_rec.user_defined_status_id := p_ce_line_rec.user_defined_status_id;
  --dbms_output.put_line('PWO: 1.5');
  l_eam_wo_rec.user_id := fnd_global.user_id;
  --dbms_output.put_line('PWO: 1.51');
  l_eam_wo_rec.responsibility_id := 55240; --fnd_glabal.resp_id
  l_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;

  l_stmt_num := 70;
  --dbms_output.put_line('PWO: 2');

BEGIN
  SELECT cii.inventory_item_id, msi.eam_item_type
  INTO l_item_id, l_eam_item
  FROM csi_item_instances cii, mtl_system_items_b msi
  WHERE cii.inventory_item_id = msi.inventory_item_id
  AND cii.last_vld_organization_id = msi.organization_id
  AND cii.instance_id = p_ce_line_rec.maintenance_object_id;

  IF l_eam_item = 1 THEN
    l_eam_wo_rec.asset_group_id := l_item_id;
    l_eam_wo_rec.rebuild_item_id := null;
  ELSIF l_eam_item = 3 THEN
    l_eam_wo_rec.rebuild_item_id := l_item_id;
    l_eam_wo_rec.asset_group_id := null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DEBUG('Cannot find the item id');
    RAISE FND_API.g_exc_error;
END;

--Populate the failure entry record -- bug 7675526  Begin

BEGIN


	 SELECT efsa.failure_code_required
	 INTO l_failure_required
	 FROM eam_failure_set_associations efsa , eam_failure_sets  efs
	 WHERE efsa.inventory_item_id = l_item_id
	 AND efsa.set_id = efs.set_id (+)
	 AND (efsa.EFFECTIVE_END_DATE is null or efs.EFFECTIVE_END_DATE >= sysdate )
	 AND ( efs.EFFECTIVE_END_DATE is null or efs.EFFECTIVE_END_DATE >=sysdate ) ;

 EXCEPTION
 WHEN OTHERS THEN
	 l_failure_required := null;
 END;

l_eam_wo_rec.failure_code_required := l_failure_required; -- bug 7675526  End

/*Add code for estimate id */

l_stmt_num := 80;
x_eam_wo_rec := l_eam_wo_rec;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'EAM_CONSTRUCTION_EST_PVT'
              , 'Populate_WO : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );


END populate_WO;

procedure POPULATE_OPERATION(
           p_ce_line_rec       IN  EAM_CE_WORK_ORDER_LINES%ROWTYPE
        ,  p_init_msg_list     VARCHAR2 := FND_API.G_FALSE
        ,  x_eam_op_rec        IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
        ,  x_return_status     OUT NOCOPY VARCHAR2
        ,  x_msg_count         OUT NOCOPY  NUMBER
        ,  x_msg_data          OUT NOCOPY  VARCHAR2
) IS

  l_eam_op_rec      EAM_PROCESS_WO_PUB.eam_op_rec_type;
  l_stmt_num        NUMBER := 0;
  BEGIN

  IF fnd_api.to_Boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
        end if;

    x_return_status := fnd_api.g_ret_sts_success;

  l_eam_op_rec := x_eam_op_rec;

  l_eam_op_rec.organization_id := p_ce_line_rec.organization_id;
  l_eam_op_rec.operation_seq_num := p_ce_line_rec.op_seq_num;
  --l_eam_op_rec.standard_operation_id := p_ce_line_rec.standard_operation_id;
  l_eam_op_rec.standard_operation_id := null;
  l_eam_op_rec.department_id := p_ce_line_rec.op_department_id;
  l_eam_op_rec.description := p_ce_line_rec.op_description;
  l_eam_op_rec.start_date := nvl(p_ce_line_rec.scheduled_start_date, sysdate);
  l_eam_op_rec.completion_date := nvl(p_ce_line_rec.scheduled_completion_date, sysdate);
  l_eam_op_rec.long_description := p_ce_line_rec.op_long_description;
  l_eam_op_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;



  x_eam_op_rec := l_eam_op_rec;


    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --EAM_CONSTRUCTION_MESSAGE_PVT.DEBUG('EAM_CONSTRUCTION_EST_PVT.POPULATE_OPERATION: Statement(' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,240));
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'EAM_CONSTRUCTION_EST_PVT'
              , 'Populate_WO : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );

END POPULATE_OPERATION;

procedure POPULATE_RESOURCE(
           p_ce_line_rec       IN  EAM_CE_WORK_ORDER_LINES%ROWTYPE
        ,  p_init_msg_list     VARCHAR2 := FND_API.G_FALSE
        ,  x_eam_res_rec        IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_rec_type
        ,  x_return_status     OUT NOCOPY VARCHAR2
        ,  x_msg_count         OUT NOCOPY  NUMBER
        ,  x_msg_data          OUT NOCOPY  VARCHAR2
) IS

  l_eam_res_rec      EAM_PROCESS_WO_PUB.eam_res_rec_type;
  l_stmt_num        NUMBER := 0;
  l_autocharge  NUMBER;
  BEGIN

  IF fnd_api.to_Boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
        end if;

    x_return_status := fnd_api.g_ret_sts_success;

  l_eam_res_rec := x_eam_res_rec;

  l_eam_res_rec.organization_id := p_ce_line_rec.organization_id;
  l_eam_res_rec.SCHEDULED_FLAG := p_ce_line_rec.RES_SCHEDULED_FLAG;
  l_eam_res_rec.operation_seq_num := p_ce_line_rec.op_seq_num;
  l_eam_res_rec.resource_seq_num := p_ce_line_rec.res_seq_num;
  l_eam_res_rec.department_id := p_ce_line_rec.op_department_id;
  l_eam_res_rec.resource_id := p_ce_line_rec.res_id;
  l_eam_res_rec.uom_code := p_ce_line_rec.res_uom;
  l_eam_res_rec.basis_type := p_ce_line_rec.res_basis_type;
  l_eam_res_rec.usage_rate_or_amount := p_ce_line_rec.required_quantity;
  l_eam_res_rec.assigned_units := nvl(p_ce_line_rec.res_assigned_units,1);
  l_eam_res_rec.start_date := nvl(p_ce_line_rec.scheduled_start_date, sysdate);
  l_eam_res_rec.completion_date := nvl(p_ce_line_rec.scheduled_completion_date, sysdate);
  l_eam_res_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

  /* Get Charge Type: Ideally this should be copied into the CE table as part of the Activity explosion -
   but since the charge type was not included in the data model, deriving it here. In future this may be
   a good ebhancement */

BEGIN
   select DECODE(BOR.AUTOCHARGE_TYPE,1,2,4,3,3,3,2) autocharge
   into l_autocharge
  from BOM_OPERATION_RESOURCES  BOR, BOM_OPERATIONAL_ROUTINGS BORT, BOM_OPERATION_SEQUENCES  BOS
  where BOR.RESOURCE_ID = p_ce_line_rec.res_id
  and BORT.assembly_item_id      = p_ce_line_rec.SRC_ACTIVITY_ID
  AND    BORT.organization_id       = p_ce_line_rec.organization_id
  AND    BOS.ROUTING_SEQUENCE_ID    = BORT.COMMON_ROUTING_SEQUENCE_ID
  AND    BOS.OPERATION_SEQUENCE_ID = BOR.OPERATION_SEQUENCE_ID
  AND    BOS.EFFECTIVITY_DATE      <=  sysdate
  AND    NVL(BOS.DISABLE_DATE, sysdate + 2) >= sysdate
  AND    (BOR.ACD_TYPE IS NULL OR BOR.ACD_TYPE <> 3);

EXCEPTION
  WHEN OTHERS THEN
    l_autocharge := 3; --default it to PO Receipt for manually added rows
END;

  l_eam_res_rec.autocharge_type := l_autocharge;

  x_eam_res_rec := l_eam_res_rec;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --EAM_CONSTRUCTION_MESSAGE_PVT.DEBUG('EAM_CONSTRUCTION_EST_PVT.POPULATE_RESOURCE: Statement(' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,240));
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'EAM_CONSTRUCTION_EST_PVT'
              , 'POPULATE_RESOURCE : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );

END POPULATE_RESOURCE;

procedure POPULATE_MATERIAL(
           p_ce_line_rec       IN  EAM_CE_WORK_ORDER_LINES%ROWTYPE
        ,  p_init_msg_list     VARCHAR2 := FND_API.G_FALSE
        ,  x_eam_mat_rec       IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        ,  x_eam_direct_rec    IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
        ,  x_return_status     OUT NOCOPY VARCHAR2
        ,  x_msg_count         OUT NOCOPY  NUMBER
        ,  x_msg_data          OUT NOCOPY  VARCHAR2
) IS

  l_eam_mat_rec      EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
  l_eam_direct_rec   EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
  l_stmt_num        NUMBER := 0;
  BEGIN

  IF fnd_api.to_Boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
        end if;

   x_return_status := fnd_api.g_ret_sts_success;

  l_eam_mat_rec := x_eam_mat_rec;
  l_eam_direct_rec := x_eam_direct_rec;

  IF p_ce_line_rec.mat_inventory_item_id IS NOT NULL THEN
    l_eam_mat_rec.organization_id := p_ce_line_rec.organization_id;
    l_eam_mat_rec.operation_seq_num := p_ce_line_rec.op_seq_num;
    l_eam_mat_rec.inventory_item_id := p_ce_line_rec.mat_inventory_item_id;
    l_eam_mat_rec.department_id := p_ce_line_rec.op_department_id;
    l_eam_mat_rec.date_required := nvl(p_ce_line_rec.scheduled_start_date, sysdate);
    l_eam_mat_rec.required_quantity := p_ce_line_rec.required_quantity;
    l_eam_mat_rec.QUANTITY_PER_ASSEMBLY := p_ce_line_rec.required_quantity;
    l_eam_mat_rec.supply_subinventory := p_ce_line_rec.mat_supply_subinventory;
    l_eam_mat_rec.supply_locator_id := p_ce_line_rec.mat_supply_locator_id;
    --l_eam_mat_rec.component_sequence_id := p_ce_line_rec.organization_id;
    l_eam_mat_rec.comments := p_ce_line_rec.item_comments;
    l_eam_mat_rec.SUGGESTED_VENDOR_NAME := p_ce_line_rec.SUGGESTED_VENDOR_NAME;
    l_eam_mat_rec.vendor_id := p_ce_line_rec.suggested_vendor_id;
    --l_eam_mat_rec.unit_price := p_ce_line_rec.item_comments;
    l_eam_mat_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

  ELSE
    l_eam_direct_rec.organization_id := p_ce_line_rec.organization_id;
    l_eam_direct_rec.description := p_ce_line_rec.di_description;
    l_eam_direct_rec.purchasing_category_id := p_ce_line_rec.di_purchase_category_id;
    --l_eam_direct_rec.direct_item_sequence_id := p_ce_line_rec.organization_id;
    l_eam_direct_rec.operation_seq_num := p_ce_line_rec.op_seq_num;
    l_eam_direct_rec.department_id := p_ce_line_rec.op_department_id;
    l_eam_direct_rec.SUGGESTED_VENDOR_NAME := p_ce_line_rec.SUGGESTED_VENDOR_NAME;
    l_eam_direct_rec.SUGGESTED_VENDOR_ID := p_ce_line_rec.SUGGESTED_VENDOR_ID;
    l_eam_direct_rec.SUGGESTED_VENDOR_SITE := p_ce_line_rec.SUGGESTED_VENDOR_SITE;
    l_eam_direct_rec.SUGGESTED_VENDOR_SITE_ID := p_ce_line_rec.SUGGESTED_VENDOR_SITE_ID;
    --l_eam_direct_rec.unit_price := p_ce_line_rec.SUGGESTED_VENDOR_ID;
    l_eam_direct_rec.required_quantity := p_ce_line_rec.required_quantity;
    --l_eam_direct_rec.uom := p_ce_line_rec.SUGGESTED_VENDOR_SITE;
    l_eam_direct_rec.need_by_date := p_ce_line_rec.di_need_by_date;
    l_eam_direct_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

  END IF; --stockable or non-stockable item


  x_eam_mat_rec := l_eam_mat_rec;
  x_eam_direct_rec := l_eam_direct_rec;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

   -- Print messages to log file


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --EAM_CONSTRUCTION_MESSAGE_PVT.DEBUG('EAM_CONSTRUCTION_EST_PVT.POPULATE_RESOURCE: Statement(' || to_char(l_stmt_num) || '): ' || substr(SQLERRM,1,240));
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'EAM_CONSTRUCTION_EST_PVT'
              , 'POPULATE_RESOURCE : Statement - '|| to_char(l_stmt_num)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );

END POPULATE_MATERIAL;

PROCEDURE COPY_EST_WORKBENCH(
    p_api_version            IN    NUMBER        := 1.0
  , p_init_msg_list          IN    VARCHAR2      := 'F'
  , p_commit                 IN VARCHAR2
  , p_src_estimate_id            IN NUMBER
  , p_org_id                 IN NUMBER
  , p_cpy_estimate_id        OUT NOCOPY NUMBER
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count                   OUT NOCOPY   NUMBER
  , x_msg_data                    OUT NOCOPY   VARCHAR2
)

IS


  l_est_workorder_line_rec     EAM_EST_DATASTRUCTURES_PUB.EAM_CE_WORK_ORDER_LINES_REC;
  l_creation_date         DATE                  := SYSDATE;
  l_created_by            NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_date     DATE                  := SYSDATE;
  l_last_updated_by       NUMBER                := FND_GLOBAL.USER_ID;
  l_last_updated_login    NUMBER;
  l_parent_estimate_wo_line_id NUMBER := 0;
  l_wo_line_id_seq NUMBER :=0;

  CURSOR SRC_EST_WORKORDER_LINES_CUR IS
    SELECT CEWOL.*
      FROM EAM_CE_WORK_ORDER_LINES CEWOL
      WHERE ESTIMATE_ID = p_src_estimate_id
      AND ORGANIZATION_ID = p_org_id
      ORDER BY ESTIMATE_WORK_ORDER_LINE_ID;

  CURSOR SRC_ESTIMATES_CUR IS
  SELECT ECE.*
    FROM EAM_CONSTRUCTION_ESTIMATES ECE
    WHERE ESTIMATE_ID = p_src_estimate_id
    AND ORGANIZATION_ID = p_org_id;
 l_estimate_rec               SRC_ESTIMATES_CUR%ROWTYPE;

BEGIN
  SAVEPOINT COPY_EST_WORKBENCH;
  -- Copy the following from the src estimate id
  -- Estimate Entries in EAM_CONSTRUCTION_ESTIMATES
  -- Estimate Work Bench Enteries in EAM_CE_WORK_ORDER_LINES
  -- Clear out WO Order Related details

  -- Checking input parameters
  IF (p_org_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ORGANIZATION_ID');
    FND_MESSAGE.SET_TOKEN('VALUE', p_org_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_src_estimate_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('EAM','EAM_EA_INVALID_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'ESTIMATE_ID');
    FND_MESSAGE.SET_TOKEN('VALUE', p_src_estimate_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Fetch the Estimates Cursor
  OPEN SRC_ESTIMATES_CUR;
  FETCH SRC_ESTIMATES_CUR INTO l_estimate_rec;
  CLOSE SRC_ESTIMATES_CUR;

  -- Initialize destination estimate rec
  -- and call EAM_CONSTRUCTION_ESTIMATES_PKG.INSERT_ROW API
  l_estimate_rec.ESTIMATE_ID := NULL;
  l_estimate_rec.ESTIMATE_NUMBER := 'Copy of ' || l_estimate_rec.ESTIMATE_NUMBER;
  IF l_estimate_rec.ESTIMATE_DESCRIPTION IS NULL THEN
    l_estimate_rec.ESTIMATE_DESCRIPTION := '';
  ELSE
    l_estimate_rec.ESTIMATE_DESCRIPTION := 'Copy of ' || l_estimate_rec.ESTIMATE_DESCRIPTION;
  END IF;  -- l_estimate_rec.ESTIMATE_DESCRIPTION IS NULL

  IF NVL(l_estimate_rec.CREATE_PARENT_WO_FLAG,'N') = 'Y' AND
      NVL(l_estimate_rec.PARENT_WO_ID,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM  THEN
    -- In this case the PARENT_WO_ID corresponds to the
    -- ESTIMATE_WORK_ORDER_LINE_ID in the ce work order lines table
    -- This parent information needs to be copied and updated

    -- The parent Work order id will be updated after inserting in to lines table
    l_parent_estimate_wo_line_id := l_estimate_rec.PARENT_WO_ID;
    l_estimate_rec.PARENT_WO_ID := NULL;
    l_estimate_rec.CREATE_PARENT_WO_FLAG := 'Y';

  ELSIF NVL(l_estimate_rec.CREATE_PARENT_WO_FLAG,'N') = 'N' AND
      NVL(l_estimate_rec.PARENT_WO_ID,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN

    l_estimate_rec.PARENT_WO_ID := NULL;
    l_estimate_rec.CREATE_PARENT_WO_FLAG := 'N';

  ELSIF NVL(l_estimate_rec.CREATE_PARENT_WO_FLAG,'N') = 'N' AND
      NVL(l_estimate_rec.PARENT_WO_ID,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

    -- l_estimate_rec.PARENT_WO_ID := NULL;
    l_estimate_rec.CREATE_PARENT_WO_FLAG := 'N';

  ELSE

    l_estimate_rec.PARENT_WO_ID := NULL;
    l_estimate_rec.CREATE_PARENT_WO_FLAG := 'N';

  END IF; -- NVL(l_estimate_rec.CREATE_PARENT_WO_FLAG,'N') = 'Y'


  EAM_CONSTRUCTION_ESTIMATES_PKG.INSERT_ROW(
      px_ESTIMATE_ID              => l_estimate_rec.ESTIMATE_ID,
      p_ORGANIZATION_ID           => l_estimate_rec.ORGANIZATION_ID,
      p_ESTIMATE_NUMBER           => l_estimate_rec.ESTIMATE_NUMBER,
      p_ESTIMATE_DESCRIPTION      => l_estimate_rec.ESTIMATE_DESCRIPTION,
      p_GROUPING_OPTION           => l_estimate_rec.GROUPING_OPTION,
      p_PARENT_WO_ID              => l_estimate_rec.PARENT_WO_ID,
      p_CREATE_PARENT_WO_FLAG     => l_estimate_rec.CREATE_PARENT_WO_FLAG,
      p_CREATION_DATE             => l_creation_date,
      p_CREATED_BY                => l_created_by,
      p_LAST_UPDATE_DATE          => l_last_updated_date,
      p_LAST_UPDATED_BY           => l_last_updated_by,
      p_LAST_UPDATE_LOGIN         => l_last_updated_login,
      p_ATTRIBUTE_CATEGORY        => l_estimate_rec.attribute_category,
		  p_ATTRIBUTE1                => l_estimate_rec.attribute1,
		  p_ATTRIBUTE2                => l_estimate_rec.attribute2,
		  p_ATTRIBUTE3                => l_estimate_rec.attribute3,
		  p_ATTRIBUTE4                => l_estimate_rec.attribute4,
		  p_ATTRIBUTE5                => l_estimate_rec.attribute5,
		  p_ATTRIBUTE6                => l_estimate_rec.attribute6,
		  p_ATTRIBUTE7                => l_estimate_rec.attribute7,
		  p_ATTRIBUTE8                => l_estimate_rec.attribute8,
		  p_ATTRIBUTE9                => l_estimate_rec.attribute9,
		  p_ATTRIBUTE10               => l_estimate_rec.attribute10,
		  p_ATTRIBUTE11               => l_estimate_rec.attribute11,
		  p_ATTRIBUTE12               => l_estimate_rec.attribute12,
		  p_ATTRIBUTE13               => l_estimate_rec.attribute13,
		  p_ATTRIBUTE14               => l_estimate_rec.attribute14,
		  p_ATTRIBUTE15     		      => l_estimate_rec.attribute15
      );

  IF nvl(x_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
    -- Log error, but continue processing
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
   END IF; -- nvl(l_return_status,'S') <> 'S'

  -- Newly Copied Estimate ID
  p_cpy_estimate_id := l_estimate_rec.ESTIMATE_ID;

  -- Need to copy Work Order Lines
  FOR l_est_workorder_line_rec IN SRC_EST_WORKORDER_LINES_CUR
  LOOP
   -- Clear Estimate WO Line id
   -- and work order related details
   IF (l_estimate_rec.CREATE_PARENT_WO_FLAG = 'Y' AND
   l_parent_estimate_wo_line_id = l_est_workorder_line_rec.ESTIMATE_WORK_ORDER_LINE_ID) THEN

   SELECT EAM_CE_WORK_ORDER_LINES_S.NEXTVAL INTO l_wo_line_id_seq FROM DUAL;

    EAM_CE_WORK_ORDER_LINES_PKG.INSERT_ROW(
         p_estimate_work_order_line_id    =>    l_wo_line_id_seq
        ,p_estimate_work_order_id         =>    NULL
        ,p_src_cu_id                      =>    l_est_workorder_line_rec.SRC_CU_ID
        ,p_src_activity_id                =>    l_est_workorder_line_rec.SRC_ACTIVITY_ID
        ,p_src_activity_qty               =>    l_est_workorder_line_rec.SRC_ACTIVITY_QTY
        ,p_src_op_seq_num                 =>    l_est_workorder_line_rec.SRC_OP_SEQ_NUM
        ,p_src_acct_class_code            =>    l_est_workorder_line_rec.SRC_ACCT_CLASS_CODE
        ,p_src_diff_id                    =>    l_est_workorder_line_rec.SRC_DIFFICULTY_ID
        ,p_diff_qty                       =>    l_est_workorder_line_rec.DIFFICULTY_QTY
        ,p_estimate_id                    =>    p_cpy_estimate_id
        ,p_organization_id                =>    l_est_workorder_line_rec.ORGANIZATION_ID
        ,p_work_order_seq_num             =>    NULL
        ,p_work_order_number              =>    NULL
        ,p_work_order_description         =>    NULL
        ,p_ref_wip_entity_id              =>    NULL
        ,p_primary_item_id                =>    l_est_workorder_line_rec.PRIMARY_ITEM_ID
        ,p_status_type                    =>    l_est_workorder_line_rec.STATUS_TYPE
        ,p_acct_class_code                =>    l_est_workorder_line_rec.ACCT_CLASS_CODE
        ,p_scheduled_start_date           =>    sysdate
        ,p_scheduled_completion_date      =>    NULL
        ,p_project_id                     =>    l_est_workorder_line_rec.PROJECT_ID
        ,p_task_id                        =>    l_est_workorder_line_rec.TASK_ID
        ,p_maintenance_object_id          =>    NULL
        ,p_maintenance_object_type        =>    NULL
        ,p_maintenance_object_source      =>    NULL
        ,p_owning_department_id           =>    l_est_workorder_line_rec.OWNING_DEPARTMENT_ID
        ,p_user_defined_status_id         =>    NULL
        ,p_op_seq_num                     =>    l_est_workorder_line_rec.OP_SEQ_NUM
        ,p_op_description                 =>    l_est_workorder_line_rec.OP_DESCRIPTION
        ,p_standard_operation_id          =>    l_est_workorder_line_rec.STANDARD_OPERATION_ID
        ,p_op_department_id               =>    l_est_workorder_line_rec.OP_DEPARTMENT_ID
        ,p_op_long_description            =>    l_est_workorder_line_rec.OP_LONG_DESCRIPTION
        ,p_res_seq_num                    =>    l_est_workorder_line_rec.RES_SEQ_NUM
        ,p_res_id                         =>    l_est_workorder_line_rec.RES_ID
        ,p_res_uom                        =>    l_est_workorder_line_rec.RES_UOM
        ,p_res_basis_type                 =>    l_est_workorder_line_rec.RES_BASIS_TYPE
        ,p_res_usage_rate_or_amount       =>    l_est_workorder_line_rec.RES_USAGE_RATE_OR_AMOUNT
        ,p_res_required_units             =>    l_est_workorder_line_rec.RES_REQUIRED_UNITS
        ,p_res_assigned_units             =>    l_est_workorder_line_rec.RES_ASSIGNED_UNITS
        ,p_item_type                      =>    l_est_workorder_line_rec.ITEM_TYPE
        ,p_required_quantity              =>    l_est_workorder_line_rec.REQUIRED_QUANTITY
        ,p_unit_price                     =>    l_est_workorder_line_rec.UNIT_PRICE
        ,p_uom                            =>    l_est_workorder_line_rec.UOM
        ,p_basis_type                     =>    l_est_workorder_line_rec.BASIS_TYPE
        ,p_suggested_vendor_name          =>    l_est_workorder_line_rec.SUGGESTED_VENDOR_NAME
        ,p_suggested_vendor_id            =>    l_est_workorder_line_rec.SUGGESTED_VENDOR_ID
        ,p_suggested_vendor_site          =>    l_est_workorder_line_rec.SUGGESTED_VENDOR_SITE
        ,p_suggested_vendor_site_id       =>    l_est_workorder_line_rec.SUGGESTED_VENDOR_SITE_ID
        ,p_mat_inventory_item_id          =>    l_est_workorder_line_rec.MAT_INVENTORY_ITEM_ID
        ,p_mat_component_seq_num          =>    l_est_workorder_line_rec.MAT_COMPONENT_SEQ_NUM
        ,p_mat_supply_subinventory        =>    l_est_workorder_line_rec.MAT_SUPPLY_SUBINVENTORY
        ,p_mat_supply_locator_id          =>    l_est_workorder_line_rec.MAT_SUPPLY_LOCATOR_ID
        ,p_di_amount                      =>    l_est_workorder_line_rec.DI_AMOUNT
        ,p_di_order_type_lookup_code      =>    l_est_workorder_line_rec.DI_ORDER_TYPE_LOOKUP_CODE
        ,p_di_description                 =>    l_est_workorder_line_rec.DI_DESCRIPTION
        ,p_di_purchase_category_id        =>    l_est_workorder_line_rec.DI_PURCHASE_CATEGORY_ID
        ,p_di_auto_request_material       =>    l_est_workorder_line_rec.DI_AUTO_REQUEST_MATERIAL
        ,p_di_need_by_date                =>    l_est_workorder_line_rec.DI_NEED_BY_DATE
        ,p_work_order_line_cost           =>    l_est_workorder_line_rec.WO_LINE_PER_UNIT_COST
        ,p_creation_date                  =>    sysdate
        ,p_created_by                     =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_date               =>    sysdate
        ,p_last_updated_by                =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_login              =>    FND_GLOBAL.LOGIN_ID
        ,p_work_order_type                =>    l_est_workorder_line_rec.WORK_ORDER_TYPE
        ,p_activity_type                  =>    l_est_workorder_line_rec.ACTIVITY_TYPE
        ,p_activity_source                =>    l_est_workorder_line_rec.ACTIVITY_SOURCE
        ,p_activity_cause                 =>    l_est_workorder_line_rec.ACTIVITY_CAUSE
        ,p_available_qty                  =>    l_est_workorder_line_rec.AVAILABLE_QUANTITY
        ,p_item_comments                  =>    l_est_workorder_line_rec.ITEM_COMMENTS
        ,p_cu_qty                         =>    l_est_workorder_line_rec.CU_QTY
        ,p_res_sch_flag                   =>    l_est_workorder_line_rec.RES_SCHEDULED_FLAG
        );

        -- Update the estimate with the estimate line id
        EAM_CONSTRUCTION_ESTIMATES_PKG.UPDATE_ROW(
        p_ESTIMATE_ID               => l_estimate_rec.ESTIMATE_ID,
        p_ORGANIZATION_ID           => l_estimate_rec.ORGANIZATION_ID,
        p_ESTIMATE_NUMBER           => l_estimate_rec.ESTIMATE_NUMBER,
        p_ESTIMATE_DESCRIPTION      => l_estimate_rec.ESTIMATE_DESCRIPTION,
        p_GROUPING_OPTION           => l_estimate_rec.GROUPING_OPTION,
        p_PARENT_WO_ID              => l_wo_line_id_seq,
        p_CREATE_PARENT_WO_FLAG     => l_estimate_rec.CREATE_PARENT_WO_FLAG,
        p_CREATION_DATE             => l_creation_date,
        p_CREATED_BY                => l_created_by,
        p_LAST_UPDATE_DATE          => l_last_updated_date,
        p_LAST_UPDATED_BY           => l_last_updated_by,
        p_LAST_UPDATE_LOGIN         => l_last_updated_login,
        p_ATTRIBUTE_CATEGORY        => l_estimate_rec.attribute_category,
        p_ATTRIBUTE1                => l_estimate_rec.attribute1,
        p_ATTRIBUTE2                => l_estimate_rec.attribute2,
        p_ATTRIBUTE3                => l_estimate_rec.attribute3,
        p_ATTRIBUTE4                => l_estimate_rec.attribute4,
        p_ATTRIBUTE5                => l_estimate_rec.attribute5,
        p_ATTRIBUTE6                => l_estimate_rec.attribute6,
        p_ATTRIBUTE7                => l_estimate_rec.attribute7,
        p_ATTRIBUTE8                => l_estimate_rec.attribute8,
        p_ATTRIBUTE9                => l_estimate_rec.attribute9,
        p_ATTRIBUTE10               => l_estimate_rec.attribute10,
        p_ATTRIBUTE11               => l_estimate_rec.attribute11,
        p_ATTRIBUTE12               => l_estimate_rec.attribute12,
        p_ATTRIBUTE13               => l_estimate_rec.attribute13,
        p_ATTRIBUTE14               => l_estimate_rec.attribute14,
        p_ATTRIBUTE15     		      => l_estimate_rec.attribute15
      );

   ELSE
     EAM_CE_WORK_ORDER_LINES_PKG.INSERT_ROW(
         p_estimate_work_order_line_id    =>    NULL
        ,p_estimate_work_order_id         =>    NULL
        ,p_src_cu_id                      =>    l_est_workorder_line_rec.SRC_CU_ID
        ,p_src_activity_id                =>    l_est_workorder_line_rec.SRC_ACTIVITY_ID
        ,p_src_activity_qty               =>    l_est_workorder_line_rec.SRC_ACTIVITY_QTY
        ,p_src_op_seq_num                 =>    l_est_workorder_line_rec.SRC_OP_SEQ_NUM
        ,p_src_acct_class_code            =>    l_est_workorder_line_rec.SRC_ACCT_CLASS_CODE
        ,p_src_diff_id                    =>    l_est_workorder_line_rec.SRC_DIFFICULTY_ID
        ,p_diff_qty                       =>    l_est_workorder_line_rec.DIFFICULTY_QTY
        ,p_estimate_id                    =>    p_cpy_estimate_id
        ,p_organization_id                =>    l_est_workorder_line_rec.ORGANIZATION_ID
        ,p_work_order_seq_num             =>    NULL
        ,p_work_order_number              =>    NULL
        ,p_work_order_description         =>    NULL
        ,p_ref_wip_entity_id              =>    NULL
        ,p_primary_item_id                =>    l_est_workorder_line_rec.PRIMARY_ITEM_ID
        ,p_status_type                    =>    l_est_workorder_line_rec.STATUS_TYPE
        ,p_acct_class_code                =>    l_est_workorder_line_rec.ACCT_CLASS_CODE
        ,p_scheduled_start_date           =>    sysdate
        ,p_scheduled_completion_date      =>    NULL
        ,p_project_id                     =>    l_est_workorder_line_rec.PROJECT_ID
        ,p_task_id                        =>    l_est_workorder_line_rec.TASK_ID
        ,p_maintenance_object_id          =>    NULL
        ,p_maintenance_object_type        =>    NULL
        ,p_maintenance_object_source      =>    NULL
        ,p_owning_department_id           =>    l_est_workorder_line_rec.OWNING_DEPARTMENT_ID
        ,p_user_defined_status_id         =>    l_est_workorder_line_rec.USER_DEFINED_STATUS_ID
        ,p_op_seq_num                     =>    l_est_workorder_line_rec.OP_SEQ_NUM
        ,p_op_description                 =>    l_est_workorder_line_rec.OP_DESCRIPTION
        ,p_standard_operation_id          =>    l_est_workorder_line_rec.STANDARD_OPERATION_ID
        ,p_op_department_id               =>    l_est_workorder_line_rec.OP_DEPARTMENT_ID
        ,p_op_long_description            =>    l_est_workorder_line_rec.OP_LONG_DESCRIPTION
        ,p_res_seq_num                    =>    l_est_workorder_line_rec.RES_SEQ_NUM
        ,p_res_id                         =>    l_est_workorder_line_rec.RES_ID
        ,p_res_uom                        =>    l_est_workorder_line_rec.RES_UOM
        ,p_res_basis_type                 =>    l_est_workorder_line_rec.RES_BASIS_TYPE
        ,p_res_usage_rate_or_amount       =>    l_est_workorder_line_rec.RES_USAGE_RATE_OR_AMOUNT
        ,p_res_required_units             =>    l_est_workorder_line_rec.RES_REQUIRED_UNITS
        ,p_res_assigned_units             =>    l_est_workorder_line_rec.RES_ASSIGNED_UNITS
        ,p_item_type                      =>    l_est_workorder_line_rec.ITEM_TYPE
        ,p_required_quantity              =>    l_est_workorder_line_rec.REQUIRED_QUANTITY
        ,p_unit_price                     =>    l_est_workorder_line_rec.UNIT_PRICE
        ,p_uom                            =>    l_est_workorder_line_rec.UOM
        ,p_basis_type                     =>    l_est_workorder_line_rec.BASIS_TYPE
        ,p_suggested_vendor_name          =>    l_est_workorder_line_rec.SUGGESTED_VENDOR_NAME
        ,p_suggested_vendor_id            =>    l_est_workorder_line_rec.SUGGESTED_VENDOR_ID
        ,p_suggested_vendor_site          =>    l_est_workorder_line_rec.SUGGESTED_VENDOR_SITE
        ,p_suggested_vendor_site_id       =>    l_est_workorder_line_rec.SUGGESTED_VENDOR_SITE_ID
        ,p_mat_inventory_item_id          =>    l_est_workorder_line_rec.MAT_INVENTORY_ITEM_ID
        ,p_mat_component_seq_num          =>    l_est_workorder_line_rec.MAT_COMPONENT_SEQ_NUM
        ,p_mat_supply_subinventory        =>    l_est_workorder_line_rec.MAT_SUPPLY_SUBINVENTORY
        ,p_mat_supply_locator_id          =>    l_est_workorder_line_rec.MAT_SUPPLY_LOCATOR_ID
        ,p_di_amount                      =>    l_est_workorder_line_rec.DI_AMOUNT
        ,p_di_order_type_lookup_code      =>    l_est_workorder_line_rec.DI_ORDER_TYPE_LOOKUP_CODE
        ,p_di_description                 =>    l_est_workorder_line_rec.DI_DESCRIPTION
        ,p_di_purchase_category_id        =>    l_est_workorder_line_rec.DI_PURCHASE_CATEGORY_ID
        ,p_di_auto_request_material       =>    l_est_workorder_line_rec.DI_AUTO_REQUEST_MATERIAL
        ,p_di_need_by_date                =>    l_est_workorder_line_rec.DI_NEED_BY_DATE
        ,p_work_order_line_cost           =>    l_est_workorder_line_rec.WO_LINE_PER_UNIT_COST
        ,p_creation_date                  =>    sysdate
        ,p_created_by                     =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_date               =>    sysdate
        ,p_last_updated_by                =>    FND_GLOBAL.LOGIN_ID
        ,p_last_update_login              =>    FND_GLOBAL.LOGIN_ID
        ,p_work_order_type                =>    l_est_workorder_line_rec.WORK_ORDER_TYPE
        ,p_activity_type                  =>    l_est_workorder_line_rec.ACTIVITY_TYPE
        ,p_activity_source                =>    l_est_workorder_line_rec.ACTIVITY_SOURCE
        ,p_activity_cause                 =>    l_est_workorder_line_rec.ACTIVITY_CAUSE
        ,p_available_qty                  =>    l_est_workorder_line_rec.AVAILABLE_QUANTITY
        ,p_item_comments                  =>    l_est_workorder_line_rec.ITEM_COMMENTS
        ,p_cu_qty                         =>    l_est_workorder_line_rec.CU_QTY
        ,p_res_sch_flag                   =>    l_est_workorder_line_rec.RES_SCHEDULED_FLAG
        );
   END IF;



  END LOOP;

  IF NVL(p_commit,'F') = 'T' THEN
    COMMIT;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO COPY_EST_WORKBENCH;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO COPY_EST_WORKBENCH;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO COPY_EST_WORKBENCH;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'COPY_EST_WORKBENCH');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END COPY_EST_WORKBENCH;

End EAM_CONSTRUCTION_EST_PVT;

/
