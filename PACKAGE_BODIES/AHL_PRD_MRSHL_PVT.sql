--------------------------------------------------------
--  DDL for Package Body AHL_PRD_MRSHL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_MRSHL_PVT" AS
 /* $Header: AHLVPMLB.pls 120.8.12010000.2 2009/06/22 22:57:21 sikumar ship $ */

G_PKG_NAME   VARCHAR2(30)  := 'AHL_PRD_MRSHL_PVT';

PROCEDURE get_uc_mrshl_details(
        p_unit_header_id           IN NUMBER,
        p_visit_id                 IN	   NUMBER,
   		x_Uc_mrshl_details_tbl     OUT NOCOPY mrshl_details_tbl_type);
PROCEDURE get_inst_mrshl_details(
        p_item_instance_id         IN NUMBER,
        p_visit_id                 IN	   NUMBER,
   		x_inst_mrshl_details_tbl     OUT NOCOPY mrshl_details_tbl_type);

FUNCTION GET_ONHAND_AVAILABLE(
P_ORG_ID IN NUMBER,
P_ITEM_ID IN NUMBER,
p_SUBINVENTORY VARCHAR2,
p_locator_id NUMBER) RETURN NUMBER
IS

onhand NUMBER;
CURSOR Q1(p_org_id NUMBER, P_ITEM_ID NUMBER,p_SUBINVENTORY VARCHAR2,p_locator_id NUMBER ) IS
SELECT SUM(TRANSACTION_QUANTITY)
FROM MTL_ONHAND_QUANTITIES
WHERE ORGANIZATION_ID = p_org_id
AND INVENTORY_ITEM_ID = P_ITEM_ID
AND LOCATOR_ID = p_locator_id
AND SUBINVENTORY_CODE = p_SUBINVENTORY;

BEGIN
    OPEN Q1(P_ORG_ID,P_ITEM_ID,p_SUBINVENTORY,p_locator_id);
    FETCH Q1 INTO onhand;
    IF(Q1%NOTFOUND) THEN
        onhand := 0;
    END IF;
    CLOSE Q1;
    IF(NVL(onhand,-1) < 0) THEN
      onhand := 0;
    END IF;
    return onhand;
END GET_ONHAND_AVAILABLE;

FUNCTION GET_ONHAND_NOTAVAILABLE(
P_ORG_ID IN NUMBER,
P_ITEM_ID IN NUMBER,
p_SUBINVENTORY VARCHAR2,
p_locator_id NUMBER) RETURN NUMBER
IS

onhand NUMBER;
CURSOR Q1(p_org_id NUMBER, p_item_Id NUMBER,p_locator_id NUMBER) IS
SELECT SUM(TRANSACTION_QUANTITY)
FROM MTL_ONHAND_QUANTITIES
WHERE ORGANIZATION_ID = p_org_id
AND INVENTORY_ITEM_ID = p_item_id
AND LOCATOR_ID <> p_locator_id;
--AND SUBINVENTORY_CODE <> p_SUBINVENTORY;

BEGIN
    OPEN Q1(P_ORG_ID,P_ITEM_ID,p_locator_id);
    FETCH Q1 INTO onhand;
    IF(Q1%NOTFOUND ) THEN
        onhand := 0;
    END IF;
    CLOSE Q1;
    IF(NVL(onhand,-1) < 0) THEN
      onhand := 0;
    END IF;
    return onhand;
END GET_ONHAND_NOTAVAILABLE;

PROCEDURE Get_unavailable_items
 		(
   		p_api_version        IN    NUMBER     := 1.0,
   		p_init_msg_list      IN    VARCHAR2   := FND_API.G_FALSE,
   		p_commit             IN    VARCHAR2   := FND_API.G_FALSE,
   		p_validation_level   IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   		p_default            IN    VARCHAR2   := FND_API.G_FALSE,
   		p_module_type        IN    VARCHAR2   := NULL,
 		p_Mrshl_search_rec  IN	   Mrshl_search_rec_type,
   		x_Unavailable_items_tbl    OUT NOCOPY Unavailable_items_Tbl_Type,
   		x_return_status            OUT NOCOPY           VARCHAR2,
   		x_msg_count                OUT NOCOPY           NUMBER,
   		x_msg_data                 OUT NOCOPY           VARCHAR2
 ) IS

 l_api_name       CONSTANT   VARCHAR2(30)   := 'Get_unavailable_items';
 l_api_version    CONSTANT   NUMBER         := 1.0;

 l_unavailable_items_tbl Unavailable_items_Tbl_Type;
 j NUMBER;

CURSOR get_root_items_instance_csr(p_visit_id NUMBER,
p_item_instance_id NUMBER) IS
SELECT VTS.instance_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id = p_item_instance_id
AND WO.status_code <> 22
AND ROWNUM < 2;

l_root_instance_id NUMBER;

CURSOR get_unavailable_items_csr(
      p_visit_id NUMBER,
      p_root_instance_id NUMBER,
      p_workorder_name VARCHAR2,
      p_part_number VARCHAR2,
      p_part_desc VARCHAR2,
      p_locator_id NUMBER,
      p_subinventory_code VARCHAR2,
      p_fetch_mode VARCHAR2) IS
SELECT * FROM(
SELECT ASML.scheduled_material_id,AWOS.workorder_id,AWOS.job_number,AWOS.job_status_code,AWOS.job_status_meaning,ASML.operation_sequence,  MSIK.concatenated_segments ,
MSIK.description, MSIK.primary_uom_code,MSIK.primary_unit_of_measure,
WIRO.REQUIRED_QUANTITY , WIRO.DATE_REQUIRED,
asml.scheduled_quantity ,asml.scheduled_date ,
 nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0) issued_quantity,
asml.inventory_item_id,
ASML.organization_id,
AWOS.wip_entity_id,
AWOS.visit_id,
DECODE(MSIK.SERIAL_NUMBER_CONTROL_CODE,1,'N','Y') Is_Serialized,
DECODE(NVL(MSIK.LOT_CONTROL_CODE,-1),1,'N','Y') Is_Lot_Controlled,
DECODE(NVL(MSIK.REVISION_QTY_CONTROL_CODE,-1),1,'N','Y') Is_Revision_Controlled,
GET_ONHAND_AVAILABLE(ASML.organization_id,ASML.inventory_item_id,
                  p_subinventory_code,p_locator_id) AVAILABLE_QUANTITY,
GET_ONHAND_NOTAVAILABLE(ASML.organization_id,ASML.inventory_item_id,
                  p_subinventory_code,p_locator_id) NOT_AVAILABLE_QUANTITY,
ASML.requested_quantity QTY_PER_ASSEMBLY,
ASML.scheduled_date EXCEPTION_DATE,
(SELECT nvl(SUM(mrv.primary_reservation_quantity),0) FROM mtl_reservations MRV
WHERE  MRV.INVENTORY_ITEM_ID =WIRO.INVENTORY_ITEM_ID
AND MRV. EXTERNAL_SOURCE_CODE = 'AHL'
AND MRV.DEMAND_SOURCE_HEADER_ID = WIRO.WIP_ENTITY_ID
AND MRV.DEMAND_SOURCE_LINE_ID =WIRO.OPERATION_SEQ_NUM) RESERVED_QUANTITY
from ahl_search_workorders_v AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id IN(
SELECT instance_id FROM csi_item_instances WHERE INSTANCE_ID   = p_root_instance_id
UNION
SELECT
        SUBJECT_ID INSTANCE_ID
FROM    CSI_II_RELATIONSHIPS
WHERE   1=1
START WITH OBJECT_ID                           = p_root_instance_id /*root instance id*/
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
--CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID
CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
)) )REQ WHERE
REQ.concatenated_segments LIKE NVL(p_part_number,'%')
AND REQ.description LIKE NVL(p_part_desc,'%')
AND REQ.job_number LIKE NVL(p_workorder_name,'%')
AND REQ.REQUIRED_QUANTITY > (REQ.issued_quantity + REQ.AVAILABLE_QUANTITY)
AND decode(p_fetch_mode,'UM',REQ.NOT_AVAILABLE_QUANTITY,1) > 0
AND decode(p_fetch_mode,'UI',REQ.REQUIRED_QUANTITY - (REQ.issued_quantity +
    REQ.AVAILABLE_QUANTITY + REQ.NOT_AVAILABLE_QUANTITY  ),1) > 0;

CURSOR get_unavailable_items_csr1(
      p_visit_id NUMBER,
      p_workorder_name VARCHAR2,
      p_part_number VARCHAR2,
      p_part_desc VARCHAR2,
      p_locator_id NUMBER,
      p_subinventory_code VARCHAR2,
      p_fetch_mode VARCHAR2) IS
SELECT * FROM(
SELECT ASML.scheduled_material_id,AWOS.workorder_id,AWOS.job_number,AWOS.job_status_code,AWOS.job_status_meaning,ASML.operation_sequence,  MSIK.concatenated_segments ,
MSIK.description, MSIK.primary_uom_code,MSIK.primary_unit_of_measure,
WIRO.REQUIRED_QUANTITY , WIRO.DATE_REQUIRED,
asml.scheduled_quantity ,asml.scheduled_date ,
 nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0) issued_quantity,
asml.inventory_item_id,
ASML.organization_id,
AWOS.wip_entity_id,
AWOS.visit_id,
DECODE(MSIK.SERIAL_NUMBER_CONTROL_CODE,1,'N','Y') Is_Serialized,
DECODE(NVL(MSIK.LOT_CONTROL_CODE,-1),1,'N','Y') Is_Lot_Controlled,
DECODE(NVL(MSIK.REVISION_QTY_CONTROL_CODE,-1),1,'N','Y') Is_Revision_Controlled,
GET_ONHAND_AVAILABLE(ASML.organization_id,ASML.inventory_item_id,
                  p_subinventory_code,p_locator_id) AVAILABLE_QUANTITY,
GET_ONHAND_NOTAVAILABLE(ASML.organization_id,ASML.inventory_item_id,
                  p_subinventory_code,p_locator_id) NOT_AVAILABLE_QUANTITY,
ASML.requested_quantity QTY_PER_ASSEMBLY,
ASML.scheduled_date EXCEPTION_DATE,
(SELECT nvl(SUM(mrv.primary_reservation_quantity),0) FROM mtl_reservations MRV
WHERE  MRV.INVENTORY_ITEM_ID =WIRO.INVENTORY_ITEM_ID
AND MRV. EXTERNAL_SOURCE_CODE = 'AHL'
AND MRV.DEMAND_SOURCE_HEADER_ID = WIRO.WIP_ENTITY_ID
AND MRV.DEMAND_SOURCE_LINE_ID =WIRO.OPERATION_SEQ_NUM) RESERVED_QUANTITY
from ahl_search_workorders_v AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
))REQ WHERE
REQ.concatenated_segments LIKE NVL(p_part_number,'%')
AND REQ.description LIKE NVL(p_part_desc,'%')
AND REQ.job_number LIKE NVL(p_workorder_name,'%')
AND REQ.REQUIRED_QUANTITY > (REQ.issued_quantity + REQ.AVAILABLE_QUANTITY)
AND decode(p_fetch_mode,'UM',REQ.NOT_AVAILABLE_QUANTITY,1) > 0
AND decode(p_fetch_mode,'UI',REQ.REQUIRED_QUANTITY - (REQ.issued_quantity +
    REQ.AVAILABLE_QUANTITY + REQ.NOT_AVAILABLE_QUANTITY  ),1) > 0;

CURSOR visit_info_csr(p_visit_id NUMBER)IS
SELECT inv_locator_id, subinventory, locator_segments FROM ahl_prd_visits_v
WHERE visit_id = p_visit_id;
l_locator_id NUMBER;
l_subinventory VARCHAR2(10);
l_locator_segments VARCHAR2(240);

CURSOR serialized_item_info(p_org_id NUMBER,
                            p_inventory_item_id NUMBER,
                            p_subinventory_code VARCHAR2,
                            p_locator_id NUMBER) IS
select msn.serial_number , msn.lot_number ,msn.revision,
       msn.current_subinventory_code,msn.current_locator_id,

       decode(msi.segment19, null, mil.concatenated_segments, INV_PROJECT.GET_LOCSEGS(mil.concatenated_segments) ||
       fnd_flex_ext.get_delimiter('INV', 'MTLL',  101) || INV_ProjectLocator_PUB.get_project_number(msi.segment19) ||
       fnd_flex_ext.get_delimiter('INV', 'MTLL',  101) || INV_ProjectLocator_PUB.get_task_number(msi.segment20))
locator_segments
from mtl_serial_numbers msn,
mtl_system_items_kfv mkfv,
mtl_item_locations_kfv mil,
mtl_item_locations msi
WHERE msi.inventory_item_id = mkfv.inventory_item_id
and   msi.organization_id=mkfv.organization_id
and msn.inventory_item_id = mkfv.inventory_item_id
and    msn.current_organization_id=mkfv.organization_id
and    msn.current_locator_id = mil.INVENTORY_locatION_ID (+)
and    msn.current_locator_id = msi.INVENTORY_locatION_ID (+)
and    mkfv.serial_number_control_code <> 1
and    msn.current_status=3
and    msn.inventory_item_id = p_inventory_item_id
and    msn.current_organization_id = p_org_id
and    msn.current_locator_id <> p_locator_id;
--AND    msn.current_subinventory_code <> p_subinventory_code;


 BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Visit_id : ' || p_Mrshl_search_rec.Visit_id
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.item_instance_id : ' || p_Mrshl_search_rec.item_instance_id
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Workorder_name : ' || p_Mrshl_search_rec.Workorder_name
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Item_name : ' || p_Mrshl_search_rec.Item_name
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Item_Desc : ' || p_Mrshl_search_rec.Item_Desc
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Search_mode : ' || p_Mrshl_search_rec.Search_mode
                   );
  END IF;
  OPEN visit_info_csr(p_Mrshl_search_rec.Visit_id);
  FETCH visit_info_csr INTO l_locator_id, l_subinventory,l_locator_segments;
  CLOSE visit_info_csr;

   IF(p_Mrshl_search_rec.item_instance_id IS NOT NULL)THEN
     /* OPEN get_root_items_instance_csr(p_Mrshl_search_rec.Visit_id,
                                    p_Mrshl_search_rec.item_instance_id);
      FETCH get_root_items_instance_csr INTO l_root_instance_id;
      IF(get_root_items_instance_csr%NOTFOUND)THEN
        RETURN;
      END IF;
      CLOSE get_root_items_instance_csr;*/
      l_root_instance_id := p_Mrshl_search_rec.item_instance_id;
   END IF;
   j := 1;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :l_root_instance_id : ' || l_root_instance_id
       );
   END IF;

   IF(l_root_instance_id IS NOT NULL)THEN
     FOR unavail_item_csr IN get_unavailable_items_csr(
                                 p_Mrshl_search_rec.Visit_id,
                                 l_root_instance_id,
                                 p_Mrshl_search_rec.Workorder_name,
                                 p_Mrshl_search_rec.Item_name,
                                 p_Mrshl_search_rec.Item_Desc,
                                 NVL(l_locator_id,-1) ,
                                 NVL(l_subinventory,'x'),
                                 p_Mrshl_search_rec.Search_mode) LOOP
        l_unavailable_items_tbl(j).Scheduled_material_id := unavail_item_csr.scheduled_material_id;
        l_unavailable_items_tbl(j).Inventory_item_id := unavail_item_csr.inventory_item_id;
        l_unavailable_items_tbl(j).Item_name := unavail_item_csr.concatenated_segments;
        l_unavailable_items_tbl(j).Item_Desc := unavail_item_csr.description;
        l_unavailable_items_tbl(j).Workorder_id := unavail_item_csr.Workorder_id;
        l_unavailable_items_tbl(j).Workorder_Name := unavail_item_csr.job_number;
        l_unavailable_items_tbl(j).Organization_id := unavail_item_csr.Organization_id;
        l_unavailable_items_tbl(j).Visit_id := unavail_item_csr.Visit_id;
        l_unavailable_items_tbl(j).Wip_Entity_Id := unavail_item_csr.Wip_Entity_Id;
        l_unavailable_items_tbl(j).wo_status := unavail_item_csr.job_status_meaning;
        l_unavailable_items_tbl(j).wo_status_code := unavail_item_csr.job_status_code;
        l_unavailable_items_tbl(j).Op_seq := unavail_item_csr.operation_sequence;
        l_unavailable_items_tbl(j).UOM := unavail_item_csr.primary_uom_code;
        l_unavailable_items_tbl(j).UOM_DESC := unavail_item_csr.primary_unit_of_measure;
        l_unavailable_items_tbl(j).Required_quantity := unavail_item_csr.REQUIRED_QUANTITY;
        l_unavailable_items_tbl(j).Required_date := unavail_item_csr.DATE_REQUIRED;
        l_unavailable_items_tbl(j).Issued_Quantity := unavail_item_csr.issued_quantity;
        l_unavailable_items_tbl(j).Qty_per_assembly := unavail_item_csr.Qty_per_assembly;
        l_unavailable_items_tbl(j).Scheduled_date := unavail_item_csr.scheduled_date;
        l_unavailable_items_tbl(j).Scheduled_Quantity := unavail_item_csr.scheduled_quantity;
        l_unavailable_items_tbl(j).Is_serialized := unavail_item_csr.Is_serialized;
        l_unavailable_items_tbl(j).Is_Lot_Controlled := unavail_item_csr.Is_Lot_Controlled;
        l_unavailable_items_tbl(j).Is_Revision_Controlled := unavail_item_csr.Is_Revision_Controlled;
        l_unavailable_items_tbl(j).quantity := unavail_item_csr.not_available_quantity;
        l_unavailable_items_tbl(j).onhand_quantity := unavail_item_csr.not_available_quantity;
        l_unavailable_items_tbl(j).exception_date := unavail_item_csr.exception_date;
        l_unavailable_items_tbl(j).reserved_quantity := unavail_item_csr.reserved_quantity;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                ' :unavail_item_csr.not_available_quantity : ' || unavail_item_csr.not_available_quantity
            );
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                ' :unavail_item_csr.REQUIRED_QUANTITY : ' || unavail_item_csr.REQUIRED_QUANTITY
            );
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                ' :unavail_item_csr.Issued_Quantity : ' || unavail_item_csr.Issued_Quantity
            );
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                ' :unavail_item_csr.available_quantity  : ' || unavail_item_csr.available_quantity
            );
        END IF;
        IF p_Mrshl_search_rec.Search_mode = 'UM' THEN
          IF(l_unavailable_items_tbl(j).quantity >
            (l_unavailable_items_tbl(j).Required_quantity - (
                      l_unavailable_items_tbl(j).Issued_Quantity +
                      unavail_item_csr.available_quantity)))THEN
             l_unavailable_items_tbl(j).quantity := l_unavailable_items_tbl(j).Required_quantity -
                      (l_unavailable_items_tbl(j).Issued_Quantity +
                      unavail_item_csr.available_quantity);
          END IF;
          IF(unavail_item_csr.not_available_quantity = 1 AND l_unavailable_items_tbl(j).Is_serialized = 'Y')THEN
            OPEN serialized_item_info(unavail_item_csr.organization_id,
                                   unavail_item_csr.inventory_item_id, l_subinventory, l_locator_id);
           FETCH serialized_item_info INTO l_unavailable_items_tbl(j).Serial_Number,
                                          l_unavailable_items_tbl(j).Lot,
                                          l_unavailable_items_tbl(j).Revision,
                                          l_unavailable_items_tbl(j).Subinventory,
                                          l_unavailable_items_tbl(j).Locator_id,
                                          l_unavailable_items_tbl(j).Locator_segments;
           CLOSE serialized_item_info;
          END IF;
        ELSIF p_Mrshl_search_rec.Search_mode = 'UI' THEN
          l_unavailable_items_tbl(j).quantity := l_unavailable_items_tbl(j).Required_quantity
             - (l_unavailable_items_tbl(j).Issued_Quantity +
                unavail_item_csr.available_quantity + l_unavailable_items_tbl(j).quantity);

        END IF;
        j:= j+1;
     END LOOP;
   ELSE
     FOR unavail_item_csr IN get_unavailable_items_csr1(
                                 p_Mrshl_search_rec.Visit_id,
                                 p_Mrshl_search_rec.Workorder_name,
                                 p_Mrshl_search_rec.Item_name,
                                 p_Mrshl_search_rec.Item_Desc,
                                 NVL(l_locator_id,-1) ,
                                 NVL(l_subinventory,'x'),
                                 p_Mrshl_search_rec.Search_mode) LOOP
        l_unavailable_items_tbl(j).Scheduled_material_id := unavail_item_csr.scheduled_material_id;
        l_unavailable_items_tbl(j).Inventory_item_id := unavail_item_csr.inventory_item_id;
        l_unavailable_items_tbl(j).Item_name := unavail_item_csr.concatenated_segments;
        l_unavailable_items_tbl(j).Item_Desc := unavail_item_csr.description;
        l_unavailable_items_tbl(j).Workorder_id := unavail_item_csr.Workorder_id;
        l_unavailable_items_tbl(j).Workorder_Name := unavail_item_csr.job_number;
        l_unavailable_items_tbl(j).Organization_id := unavail_item_csr.Organization_id;
        l_unavailable_items_tbl(j).Visit_id := unavail_item_csr.Visit_id;
        l_unavailable_items_tbl(j).Wip_Entity_Id := unavail_item_csr.Wip_Entity_Id;
        l_unavailable_items_tbl(j).wo_status := unavail_item_csr.job_status_meaning;
        l_unavailable_items_tbl(j).wo_status_code := unavail_item_csr.job_status_code;
        l_unavailable_items_tbl(j).Op_seq := unavail_item_csr.operation_sequence;
        l_unavailable_items_tbl(j).UOM := unavail_item_csr.primary_uom_code;
        l_unavailable_items_tbl(j).UOM_DESC := unavail_item_csr.primary_unit_of_measure;
        l_unavailable_items_tbl(j).Required_quantity := unavail_item_csr.REQUIRED_QUANTITY;
        l_unavailable_items_tbl(j).Required_date := unavail_item_csr.DATE_REQUIRED;
        l_unavailable_items_tbl(j).Issued_Quantity := unavail_item_csr.issued_quantity;
        l_unavailable_items_tbl(j).Qty_per_assembly := unavail_item_csr.Qty_per_assembly;
        l_unavailable_items_tbl(j).Scheduled_date := unavail_item_csr.scheduled_date;
        l_unavailable_items_tbl(j).Scheduled_Quantity := unavail_item_csr.scheduled_quantity;
        l_unavailable_items_tbl(j).Is_serialized := unavail_item_csr.Is_serialized;
        l_unavailable_items_tbl(j).Is_Lot_Controlled := unavail_item_csr.Is_Lot_Controlled;
        l_unavailable_items_tbl(j).Is_Revision_Controlled := unavail_item_csr.Is_Revision_Controlled;
        l_unavailable_items_tbl(j).onhand_quantity := unavail_item_csr.not_available_quantity;
        l_unavailable_items_tbl(j).exception_date := unavail_item_csr.exception_date;
        l_unavailable_items_tbl(j).reserved_quantity := unavail_item_csr.reserved_quantity;
        IF( p_Mrshl_search_rec.Search_mode = 'UM')THEN
         l_unavailable_items_tbl(j).quantity := unavail_item_csr.not_available_quantity;
         IF(l_unavailable_items_tbl(j).quantity >
           (l_unavailable_items_tbl(j).Required_quantity -
                      l_unavailable_items_tbl(j).Issued_Quantity -
                      unavail_item_csr.available_quantity))THEN
           l_unavailable_items_tbl(j).quantity := (l_unavailable_items_tbl(j).Required_quantity -
                      l_unavailable_items_tbl(j).Issued_Quantity -
                      unavail_item_csr.available_quantity);
         END IF;
         IF(unavail_item_csr.not_available_quantity = 1 AND l_unavailable_items_tbl(j).Is_serialized = 'Y')THEN
          OPEN serialized_item_info(unavail_item_csr.organization_id,
                                   unavail_item_csr.inventory_item_id, l_subinventory, l_locator_id);
          FETCH serialized_item_info INTO l_unavailable_items_tbl(j).Serial_Number,
                                          l_unavailable_items_tbl(j).Lot,
                                          l_unavailable_items_tbl(j).Revision,
                                          l_unavailable_items_tbl(j).Subinventory,
                                          l_unavailable_items_tbl(j).Locator_id,
                                          l_unavailable_items_tbl(j).Locator_segments;
          CLOSE serialized_item_info;
         END IF;
        ELSIF ( p_Mrshl_search_rec.Search_mode = 'UI')THEN
          l_unavailable_items_tbl(j).quantity := l_unavailable_items_tbl(j).Required_quantity -
                      (l_unavailable_items_tbl(j).Issued_Quantity +
                      unavail_item_csr.available_quantity +
                      unavail_item_csr.not_available_quantity);
        END IF;

        j:= j+1;
     END LOOP;
   END IF;
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :j : ' || j);
   END IF;
   x_unavailable_items_tbl := l_unavailable_items_tbl;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
 END Get_unavailable_items;

 PROCEDURE Get_available_items
 		(
   		p_api_version        IN    NUMBER     := 1.0,
   		p_init_msg_list      IN    VARCHAR2   := FND_API.G_FALSE,
   		p_commit             IN    VARCHAR2   := FND_API.G_FALSE,
   		p_validation_level   IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   		p_default            IN    VARCHAR2   := FND_API.G_FALSE,
   		p_module_type        IN    VARCHAR2   := NULL,
 		p_Mrshl_search_rec  IN	   Mrshl_search_rec_type,
   		x_available_items_tbl      OUT NOCOPY Available_items_Tbl_Type,
   		x_return_status            OUT NOCOPY           VARCHAR2,
   		x_msg_count                OUT NOCOPY           NUMBER,
   		x_msg_data                 OUT NOCOPY           VARCHAR2
 )IS
l_api_name       CONSTANT   VARCHAR2(30)   := 'Get_available_items';
l_api_version    CONSTANT   NUMBER         := 1.0;
l_available_items_tbl Available_items_Tbl_Type;
j NUMBER;

CURSOR get_root_items_instance_csr(p_visit_id NUMBER,
p_item_instance_id NUMBER) IS
SELECT VTS.instance_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id = p_item_instance_id
AND WO.status_code <> 22
AND ROWNUM < 2;

l_root_instance_id NUMBER;

CURSOR get_available_items_csr(
      p_visit_id NUMBER,
      p_root_instance_id NUMBER,
      p_workorder_name VARCHAR2,
      p_part_number VARCHAR2,
      p_part_desc VARCHAR2,
      p_locator_id NUMBER,
      p_subinventory_code VARCHAR2) IS
SELECT * FROM(
SELECT AWOS.workorder_id,AWOS.job_number,AWOS.job_status_code,AWOS.job_status_meaning,ASML.operation_sequence,  MSIK.concatenated_segments ,
MSIK.description, MSIK.primary_uom_code,MSIK.primary_unit_of_measure,
WIRO.REQUIRED_QUANTITY , WIRO.DATE_REQUIRED,
asml.scheduled_quantity ,asml.scheduled_date ,
 nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0) issued_quantity,
asml.inventory_item_id,
ASML.organization_id,
ASML.scheduled_material_id,
AWOS.wip_entity_id,
AWOS.visit_id,
DECODE(MSIK.SERIAL_NUMBER_CONTROL_CODE,1,'N','Y') Is_Serialized,
DECODE(NVL(MSIK.LOT_CONTROL_CODE,-1),1,'N','Y') Is_Lot_Controlled,
DECODE(NVL(MSIK.REVISION_QTY_CONTROL_CODE,-1),1,'N','Y') Is_Revision_Controlled,
GET_ONHAND_AVAILABLE(ASML.organization_id,ASML.inventory_item_id,
                  p_subinventory_code,p_locator_id) AVAILABLE_QUANTITY,
ASML.requested_quantity QTY_PER_ASSEMBLY,
ASML.scheduled_date EXCEPTION_DATE,
(SELECT nvl(SUM(mrv.primary_reservation_quantity),0) FROM mtl_reservations MRV
WHERE  MRV.INVENTORY_ITEM_ID =WIRO.INVENTORY_ITEM_ID
AND MRV. EXTERNAL_SOURCE_CODE = 'AHL'
AND MRV.DEMAND_SOURCE_HEADER_ID = WIRO.WIP_ENTITY_ID
AND MRV.DEMAND_SOURCE_LINE_ID =WIRO.OPERATION_SEQ_NUM) RESERVED_QUANTITY
from ahl_search_workorders_v AWOS, ahl_schedule_materials ASML,
     WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
AND ASML.inventory_item_id = MSIK.inventory_item_id
AND ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID
AND asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id IN(
SELECT instance_id FROM csi_item_instances WHERE INSTANCE_ID   = p_root_instance_id
UNION
SELECT
        SUBJECT_ID INSTANCE_ID
FROM    CSI_II_RELATIONSHIPS
WHERE   1=1
START WITH OBJECT_ID                           = p_root_instance_id /*root instance id*/
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
--CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID
CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
)))REQ WHERE
REQ.concatenated_segments LIKE NVL(p_part_number,'%')
AND REQ.description LIKE NVL(p_part_desc,'%')
AND REQ.job_number LIKE NVL(p_workorder_name,'%')
AND REQ.REQUIRED_QUANTITY > REQ.issued_quantity
AND AVAILABLE_QUANTITY > 0;

CURSOR get_available_items_csr1(
      p_visit_id NUMBER,
      p_workorder_name VARCHAR2,
      p_part_number VARCHAR2,
      p_part_desc VARCHAR2,
      p_locator_id NUMBER,
      p_subinventory_code VARCHAR2) IS
SELECT * FROM(SELECT AWOS.workorder_id,AWOS.job_number,AWOS.job_status_code,AWOS.job_status_meaning,ASML.operation_sequence,  MSIK.concatenated_segments ,
MSIK.description, MSIK.primary_uom_code,MSIK.primary_unit_of_measure,
WIRO.REQUIRED_QUANTITY , WIRO.DATE_REQUIRED,
asml.scheduled_quantity ,asml.scheduled_date ,
 nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0) issued_quantity,
asml.inventory_item_id,
ASML.organization_id,
ASML.scheduled_material_id,
AWOS.wip_entity_id,
AWOS.visit_id,
DECODE(MSIK.SERIAL_NUMBER_CONTROL_CODE,1,'N','Y') Is_Serialized,
DECODE(NVL(MSIK.LOT_CONTROL_CODE,-1),1,'N','Y') Is_Lot_Controlled,
DECODE(NVL(MSIK.REVISION_QTY_CONTROL_CODE,-1),1,'N','Y') Is_Revision_Controlled,
GET_ONHAND_AVAILABLE(ASML.organization_id,ASML.inventory_item_id,
                  p_subinventory_code,p_locator_id) AVAILABLE_QUANTITY,
ASML.requested_quantity QTY_PER_ASSEMBLY,
ASML.scheduled_date EXCEPTION_DATE,
(SELECT nvl(SUM(mrv.primary_reservation_quantity),0) FROM mtl_reservations MRV
WHERE  MRV.INVENTORY_ITEM_ID =WIRO.INVENTORY_ITEM_ID
AND MRV. EXTERNAL_SOURCE_CODE = 'AHL'
AND MRV.DEMAND_SOURCE_HEADER_ID = WIRO.WIP_ENTITY_ID
AND MRV.DEMAND_SOURCE_LINE_ID =WIRO.OPERATION_SEQ_NUM) RESERVED_QUANTITY
from ahl_search_workorders_v AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
))REQ WHERE
REQ.concatenated_segments LIKE NVL(p_part_number,'%')
AND REQ.description LIKE NVL(p_part_desc,'%')
AND REQ.job_number LIKE NVL(p_workorder_name,'%')
AND REQ.REQUIRED_QUANTITY > REQ.issued_quantity
AND AVAILABLE_QUANTITY > 0;

CURSOR visit_info_csr(p_visit_id NUMBER)IS
SELECT inv_locator_id, subinventory, locator_segments FROM ahl_prd_visits_v
WHERE visit_id = p_visit_id;
l_locator_id NUMBER;
l_subinventory VARCHAR2(10);
l_locator_segments VARCHAR2(240);

CURSOR serialized_item_info(p_org_id NUMBER,
                            p_inventory_item_id NUMBER,
                            p_subinventory_code VARCHAR2,
                            p_locator_id NUMBER) IS
select msn.serial_number , msn.lot_number ,msn.revision
from mtl_serial_numbers msn,
mtl_system_items_kfv mkfv,
mtl_item_locations_kfv mil
where msn.inventory_item_id = mkfv.inventory_item_id
and    msn.current_organization_id=mkfv.organization_id
and    msn.current_locator_id = mil.INVENTORY_locatION_ID (+)
and    mkfv.serial_number_control_code <> 1
and    msn.current_status=3
and    msn.inventory_item_id = p_inventory_item_id
and    msn.current_organization_id = p_org_id
and    msn.current_locator_id = p_locator_id
and    msn.current_subinventory_code = p_subinventory_code;



 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Visit_id : ' || p_Mrshl_search_rec.Visit_id
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.item_instance_id : ' || p_Mrshl_search_rec.item_instance_id
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Workorder_name : ' || p_Mrshl_search_rec.Workorder_name
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Item_name : ' || p_Mrshl_search_rec.Item_name
                   );
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :p_Mrshl_search_rec.Item_Desc : ' || p_Mrshl_search_rec.Item_Desc
                   );
  END IF;

  OPEN visit_info_csr(p_Mrshl_search_rec.Visit_id);
  FETCH visit_info_csr INTO l_locator_id, l_subinventory,l_locator_segments;
  CLOSE visit_info_csr;

   IF(p_Mrshl_search_rec.item_instance_id IS NOT NULL)THEN
      /*OPEN get_root_items_instance_csr(p_Mrshl_search_rec.Visit_id,
                                    p_Mrshl_search_rec.item_instance_id);
      FETCH get_root_items_instance_csr INTO l_root_instance_id;
      IF(get_root_items_instance_csr%NOTFOUND)THEN
        RETURN;
      END IF;
      CLOSE get_root_items_instance_csr;*/
      l_root_instance_id := p_Mrshl_search_rec.item_instance_id;
   END IF;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' :l_root_instance_id : ' || l_root_instance_id
                   );
   END IF;
   j := 1;

   IF(l_root_instance_id IS NOT NULL)THEN
     FOR avail_item_csr IN get_available_items_csr(
                                 p_Mrshl_search_rec.Visit_id,
                                 l_root_instance_id,
                                 p_Mrshl_search_rec.Workorder_name,
                                 p_Mrshl_search_rec.Item_name,
                                 p_Mrshl_search_rec.Item_Desc,
                                 NVL(l_locator_id,-1) ,
                                 NVL(l_subinventory,'x')) LOOP
        l_available_items_tbl(j).Scheduled_material_id := avail_item_csr.scheduled_material_id;
        l_available_items_tbl(j).Inventory_item_id := avail_item_csr.inventory_item_id;
        l_available_items_tbl(j).Item_name := avail_item_csr.concatenated_segments;
        l_available_items_tbl(j).Item_Desc := avail_item_csr.description;
        l_available_items_tbl(j).Workorder_id := avail_item_csr.Workorder_id;
        l_available_items_tbl(j).Workorder_Name := avail_item_csr.job_number;
        l_available_items_tbl(j).Organization_id := avail_item_csr.Organization_id;
        l_available_items_tbl(j).Visit_id := avail_item_csr.Visit_id;
        l_available_items_tbl(j).Wip_Entity_Id := avail_item_csr.Wip_Entity_Id;
        l_available_items_tbl(j).wo_status := avail_item_csr.job_status_meaning;
        l_available_items_tbl(j).wo_status_code := avail_item_csr.job_status_code;
        l_available_items_tbl(j).Op_seq := avail_item_csr.operation_sequence;
        l_available_items_tbl(j).UOM := avail_item_csr.primary_uom_code;
        l_available_items_tbl(j).UOM_DESC := avail_item_csr.primary_unit_of_measure;
        l_available_items_tbl(j).Required_quantity := avail_item_csr.REQUIRED_QUANTITY;
        l_available_items_tbl(j).Required_date := avail_item_csr.DATE_REQUIRED;
        l_available_items_tbl(j).Issued_Quantity := avail_item_csr.issued_quantity;
        l_available_items_tbl(j).Scheduled_date := avail_item_csr.scheduled_date;
        l_available_items_tbl(j).Scheduled_Quantity := avail_item_csr.scheduled_quantity;
        l_available_items_tbl(j).Subinventory := l_subinventory;
        l_available_items_tbl(j).Locator_id := l_locator_id;
        l_available_items_tbl(j).Locator_segments := l_locator_segments;
        l_available_items_tbl(j).Qty_per_assembly := avail_item_csr.Qty_per_assembly;
        l_available_items_tbl(j).Is_serialized := avail_item_csr.Is_serialized;
        l_available_items_tbl(j).Is_Lot_Controlled := avail_item_csr.Is_Lot_Controlled;
        l_available_items_tbl(j).Is_Revision_Controlled := avail_item_csr.Is_Revision_Controlled;
        l_available_items_tbl(j).quantity := avail_item_csr.available_quantity;
        l_available_items_tbl(j).onhand_quantity := avail_item_csr.available_quantity;
        l_available_items_tbl(j).exception_date := avail_item_csr.exception_date;
        l_available_items_tbl(j).reserved_quantity := avail_item_csr.reserved_quantity;
        IF(l_available_items_tbl(j).quantity >
           (l_available_items_tbl(j).Required_quantity -
                      l_available_items_tbl(j).Issued_Quantity))THEN
           l_available_items_tbl(j).quantity := (l_available_items_tbl(j).Required_quantity -
                      l_available_items_tbl(j).Issued_Quantity);
        END IF;
        IF(avail_item_csr.available_quantity = 1 AND l_available_items_tbl(j).Is_serialized = 'Y')THEN
          OPEN serialized_item_info(avail_item_csr.organization_id,
                                   avail_item_csr.inventory_item_id, l_subinventory, l_locator_id);
          FETCH serialized_item_info INTO l_available_items_tbl(j).Serial_Number,
                                          l_available_items_tbl(j).Lot,
                                          l_available_items_tbl(j).Revision;
          CLOSE serialized_item_info;
        END IF;
        j:= j+1;
     END LOOP;
   ELSE
     FOR avail_item_csr IN get_available_items_csr1(
                                 p_Mrshl_search_rec.Visit_id,
                                 p_Mrshl_search_rec.Workorder_name,
                                 p_Mrshl_search_rec.Item_name,
                                 p_Mrshl_search_rec.Item_Desc,
                                 NVL(l_locator_id,-1) ,
                                 NVL(l_subinventory,'x')) LOOP
        l_available_items_tbl(j).Scheduled_material_id := avail_item_csr.scheduled_material_id;
        l_available_items_tbl(j).Inventory_item_id := avail_item_csr.inventory_item_id;
        l_available_items_tbl(j).Item_name := avail_item_csr.concatenated_segments;
        l_available_items_tbl(j).Item_Desc := avail_item_csr.description;
        l_available_items_tbl(j).Workorder_id := avail_item_csr.Workorder_id;
        l_available_items_tbl(j).Workorder_Name := avail_item_csr.job_number;
        l_available_items_tbl(j).Organization_id := avail_item_csr.Organization_id;
        l_available_items_tbl(j).Visit_id := avail_item_csr.Visit_id;
        l_available_items_tbl(j).Wip_Entity_Id := avail_item_csr.Wip_Entity_Id;
        l_available_items_tbl(j).wo_status := avail_item_csr.job_status_meaning;
        l_available_items_tbl(j).wo_status_code := avail_item_csr.job_status_code;
        l_available_items_tbl(j).Op_seq := avail_item_csr.operation_sequence;
        l_available_items_tbl(j).UOM := avail_item_csr.primary_uom_code;
        l_available_items_tbl(j).UOM_DESC := avail_item_csr.primary_unit_of_measure;
        l_available_items_tbl(j).Required_quantity := avail_item_csr.REQUIRED_QUANTITY;
        l_available_items_tbl(j).Required_date := avail_item_csr.DATE_REQUIRED;
        l_available_items_tbl(j).Issued_Quantity := avail_item_csr.issued_quantity;
        l_available_items_tbl(j).Scheduled_date := avail_item_csr.scheduled_date;
        l_available_items_tbl(j).Scheduled_Quantity := avail_item_csr.scheduled_quantity;
        l_available_items_tbl(j).Qty_per_assembly := avail_item_csr.Qty_per_assembly;
        l_available_items_tbl(j).Subinventory := l_subinventory;
        l_available_items_tbl(j).Locator_id := l_locator_id;
        l_available_items_tbl(j).Locator_segments := l_locator_segments;
        l_available_items_tbl(j).Is_serialized := avail_item_csr.Is_serialized;
        l_available_items_tbl(j).Is_Lot_Controlled := avail_item_csr.Is_Lot_Controlled;
        l_available_items_tbl(j).Is_Revision_Controlled := avail_item_csr.Is_Revision_Controlled;
        l_available_items_tbl(j).quantity := avail_item_csr.available_quantity;
        l_available_items_tbl(j).onhand_quantity := avail_item_csr.available_quantity;
        l_available_items_tbl(j).exception_date := avail_item_csr.exception_date;
        l_available_items_tbl(j).reserved_quantity := avail_item_csr.reserved_quantity;
        IF(l_available_items_tbl(j).quantity >
           (l_available_items_tbl(j).Required_quantity -
                      l_available_items_tbl(j).Issued_Quantity))THEN
           l_available_items_tbl(j).quantity := (l_available_items_tbl(j).Required_quantity -
                      l_available_items_tbl(j).Issued_Quantity);
        END IF;
        IF(avail_item_csr.available_quantity = 1 AND l_available_items_tbl(j).Is_serialized = 'Y')THEN
          OPEN serialized_item_info(avail_item_csr.organization_id,
                                   avail_item_csr.inventory_item_id, l_subinventory, l_locator_id);
          FETCH serialized_item_info INTO l_available_items_tbl(j).Serial_Number,
                                          l_available_items_tbl(j).Lot,
                                          l_available_items_tbl(j).Revision;
          CLOSE serialized_item_info;
        END IF;
        j:= j+1;
     END LOOP;
   END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
       ' Count  : ' || to_char(j -1));
    END IF;
   x_available_items_tbl := l_available_items_tbl;
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
 END Get_available_items;
/*
p_mode can be as follows "IC", "CO" as follows
	IC - In complete
	CO - Completed
	TO - Total
*/
 FUNCTION Get_workorder_count
 (
   		p_visit_id                 IN NUMBER,
   		p_item_instance_id         IN NUMBER,
   		p_mode                     IN VARCHAR2
 ) RETURN NUMBER IS

 CURSOR comp_inst_wo_count_csr(p_visit_id NUMBER,p_item_instance_id  NUMBER) IS
 SELECT COUNT(*)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE IN('4','5','7','12')
 AND workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id  = p_item_instance_id);

 CURSOR comp_cumm_inst_wo_count_csr(p_visit_id NUMBER,p_item_instance_id  NUMBER) IS
 SELECT COUNT(*)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE IN('4','5','7','12')
 AND workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id IN(
SELECT instance_id FROM csi_item_instances WHERE INSTANCE_ID   = p_item_instance_id
UNION
SELECT
        SUBJECT_ID INSTANCE_ID
FROM    CSI_II_RELATIONSHIPS
WHERE   1=1
START WITH OBJECT_ID                           = p_item_instance_id /*root instance id*/
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
--CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID
CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
));


 CURSOR total_inst_wo_count_csr(p_visit_id NUMBER,p_item_instance_id  NUMBER) IS
 SELECT COUNT(*)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE <> '22'
 AND workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
 WO.visit_id = p_visit_id
 AND WO.visit_id = VTS.visit_id
 AND WO.visit_task_id = VTS.visit_task_id
 AND VTS.instance_id  = p_item_instance_id);

 CURSOR total_cumm_inst_wo_count_csr(p_visit_id NUMBER,p_item_instance_id  NUMBER) IS
 SELECT COUNT(*)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE <> '22'
 AND workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id IN(
SELECT instance_id FROM csi_item_instances WHERE INSTANCE_ID   = p_item_instance_id
UNION
SELECT
        SUBJECT_ID INSTANCE_ID
FROM    CSI_II_RELATIONSHIPS
WHERE   1=1
START WITH OBJECT_ID                           = p_item_instance_id /*root instance id*/
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
--CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID
CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
));

 CURSOR comp_visit_wo_count_csr(p_visit_id NUMBER) IS
 SELECT COUNT(*)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE IN('4','5','7','12');


 CURSOR total_visit_wo_count_csr(p_visit_id NUMBER) IS
 SELECT COUNT(*)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE <> '22';

 l_quantity NUMBER;


 BEGIN
    mo_global.init('AHL');
   l_quantity :=0;
   IF(p_mode IN ('CO','COC'))THEN
      IF(p_item_instance_id IS NULL)THEN
        OPEN comp_visit_wo_count_csr(p_visit_id);
        FETCH comp_visit_wo_count_csr INTO l_quantity;
        CLOSE comp_visit_wo_count_csr;
      ELSIF p_mode = 'CO' THEN
        OPEN comp_inst_wo_count_csr(p_visit_id,p_item_instance_id);
        FETCH comp_inst_wo_count_csr INTO l_quantity;
        CLOSE comp_inst_wo_count_csr;
      ELSIF p_mode = 'COC' THEN
        OPEN comp_cumm_inst_wo_count_csr(p_visit_id,p_item_instance_id);
        FETCH comp_cumm_inst_wo_count_csr INTO l_quantity;
        CLOSE comp_cumm_inst_wo_count_csr;
      END IF;
   ELSIF (p_mode IN ('TO','TOC'))THEN
      IF(p_item_instance_id IS NULL)THEN
        OPEN total_visit_wo_count_csr(p_visit_id);
        FETCH total_visit_wo_count_csr INTO l_quantity;
        CLOSE total_visit_wo_count_csr;
      ELSIF p_mode = 'TO' THEN
        OPEN total_inst_wo_count_csr(p_visit_id,p_item_instance_id);
        FETCH total_inst_wo_count_csr INTO l_quantity;
        CLOSE total_inst_wo_count_csr;
      ELSIF p_mode = 'TOC' THEN
        OPEN total_cumm_inst_wo_count_csr(p_visit_id,p_item_instance_id);
        FETCH total_cumm_inst_wo_count_csr INTO l_quantity;
        CLOSE total_cumm_inst_wo_count_csr;
      END IF;
   END IF;
   RETURN NVL(l_quantity,0);
 END Get_workorder_count;
 /*
  p_mode can be as follows
  MU - Material unavailable
    MU - Material unavailable
    MUC - Material unavailable Cummulative
	MA - Material Avaialble
	MAC - Material Avaialble Cummulative
	MR - Material Required
	MRC - Material Required Cummulative
	MI - Material Issued
	MIC - Material Issued Cummulative
 */
 FUNCTION Get_item_count
 (
   		p_visit_id                 IN NUMBER,
   		p_item_instance_id         IN NUMBER :=NULL,
   		p_mode                     IN VARCHAR2
 ) RETURN NUMBER IS

CURSOR get_inst_required_qty(p_visit_id NUMBER,p_item_instance_id NUMBER) IS
SELECT SUM(WIRO.REQUIRED_QUANTITY)
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id  = p_item_instance_id);

CURSOR get_cumm_inst_required_qty(p_visit_id NUMBER,p_item_instance_id NUMBER)IS
SELECT SUM(WIRO.REQUIRED_QUANTITY)
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id IN(
SELECT instance_id FROM csi_item_instances WHERE INSTANCE_ID   = p_item_instance_id
UNION
SELECT
        SUBJECT_ID INSTANCE_ID
FROM    CSI_II_RELATIONSHIPS
WHERE   1=1
START WITH OBJECT_ID                           = p_item_instance_id /*root instance id*/
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
--CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID
CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
));

CURSOR get_visit_required_qty(p_visit_id NUMBER) IS
SELECT SUM(WIRO.REQUIRED_QUANTITY)
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id);

CURSOR get_inst_issued_qty(p_visit_id NUMBER,p_item_instance_id NUMBER) IS
SELECT SUM( nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0)) issued_qty
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id  = p_item_instance_id);

CURSOR get_cumm_inst_issued_qty(p_visit_id NUMBER,p_item_instance_id NUMBER)IS
SELECT SUM( nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0)) issued_qty
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id IN(
SELECT instance_id FROM csi_item_instances WHERE INSTANCE_ID   = p_item_instance_id
UNION
SELECT
        SUBJECT_ID INSTANCE_ID
FROM    CSI_II_RELATIONSHIPS
WHERE   1=1
START WITH OBJECT_ID                           = p_item_instance_id /*root instance id*/
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
--CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID
CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
));

CURSOR get_visit_issued_qty(p_visit_id NUMBER) IS
SELECT SUM( nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0)) issued_qty
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id);

CURSOR get_inst_avail_qty(p_visit_id NUMBER,p_item_instance_id NUMBER,
                          p_subinventory_code VARCHAR2,
                          p_locator_id NUMBER) IS
SELECT  SUM(WIRO.REQUIRED_QUANTITY) REQUIRED_QUANTITY,
SUM( nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0)) issued_qty,
SUM(GET_ONHAND_AVAILABLE(
ASML.organization_id,
ASML.inventory_item_id,
p_subinventory_code,
p_locator_id)) available_quantity
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id  = p_item_instance_id)
GROUP BY asml.inventory_item_id,ASML.organization_id,AWOS.WIP_ENTITY_ID,ASML.OPERATION_SEQUENCE;

CURSOR get_cumm_inst_avail_qty(p_visit_id NUMBER,p_item_instance_id NUMBER,
                          p_subinventory_code VARCHAR2,
                          p_locator_id NUMBER)IS
SELECT SUM(WIRO.REQUIRED_QUANTITY) REQUIRED_QUANTITY,
SUM( nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0)) issued_qty,
SUM(GET_ONHAND_AVAILABLE(
ASML.organization_id,
ASML.inventory_item_id,
p_subinventory_code,
p_locator_id)) available_quantity
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id
AND VTS.instance_id IN(
SELECT instance_id FROM csi_item_instances WHERE INSTANCE_ID   = p_item_instance_id
UNION
SELECT
        SUBJECT_ID INSTANCE_ID
FROM    CSI_II_RELATIONSHIPS
WHERE   1=1
START WITH OBJECT_ID                           = p_item_instance_id /*root instance id*/
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
--CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID
CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
))
GROUP BY asml.inventory_item_id,ASML.organization_id,AWOS.WIP_ENTITY_ID,ASML.OPERATION_SEQUENCE;

CURSOR get_visit_avail_qty(p_visit_id NUMBER,
                          p_subinventory_code VARCHAR2,
                          p_locator_id NUMBER) IS
SELECT SUM(WIRO.REQUIRED_QUANTITY) REQUIRED_QUANTITY,
SUM( nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0)) issued_qty,
SUM(GET_ONHAND_AVAILABLE(
ASML.organization_id,
ASML.inventory_item_id,
p_subinventory_code,
p_locator_id)) available_quantity
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.workorder_id IN (SELECT workorder_id FROM ahl_workorders WO,ahl_visit_tasks_b VTS WHERE
WO.visit_id = p_visit_id
AND WO.visit_id = VTS.visit_id
AND WO.visit_task_id = VTS.visit_task_id)
GROUP BY asml.inventory_item_id,ASML.organization_id,AWOS.WIP_ENTITY_ID,ASML.OPERATION_SEQUENCE;

CURSOR visit_info_csr(p_visit_id NUMBER)IS
SELECT inv_locator_id, subinventory, locator_segments FROM ahl_prd_visits_v
WHERE visit_id = p_visit_id;
l_locator_id NUMBER;
l_subinventory VARCHAR2(10);
l_locator_segments VARCHAR2(240);


l_quantity NUMBER;
l_req_quantity NUMBER;
l_issued_qty NUMBER;
l_avail_qty NUMBER;
l_unavail_qty NUMBER;

 BEGIN
   mo_global.init('AHL');
   IF(p_mode IN ('MR','MRC'))THEN
      IF(p_item_instance_id IS NULL)THEN
        OPEN get_visit_required_qty(p_visit_id);
        FETCH get_visit_required_qty INTO l_quantity;
        CLOSE get_visit_required_qty;
      ELSIF p_mode = 'MR' THEN
        OPEN get_inst_required_qty(p_visit_id,p_item_instance_id);
        FETCH get_inst_required_qty INTO l_quantity;
        CLOSE get_inst_required_qty;
      ELSIF p_mode = 'MRC' THEN
        OPEN get_cumm_inst_required_qty(p_visit_id,p_item_instance_id);
        FETCH get_cumm_inst_required_qty INTO l_quantity;
        CLOSE get_cumm_inst_required_qty;
      END IF;
   ELSIF (p_mode IN ('MI','MIC'))THEN
      IF(p_item_instance_id IS NULL)THEN
        OPEN get_visit_issued_qty(p_visit_id);
        FETCH get_visit_issued_qty INTO l_quantity;
        CLOSE get_visit_issued_qty;
      ELSIF p_mode = 'MI' THEN
        OPEN get_inst_issued_qty(p_visit_id,p_item_instance_id);
        FETCH get_inst_issued_qty INTO l_quantity;
        CLOSE get_inst_issued_qty;
      ELSIF p_mode = 'MIC' THEN
        OPEN get_cumm_inst_issued_qty(p_visit_id,p_item_instance_id);
        FETCH get_cumm_inst_issued_qty INTO l_quantity;
        CLOSE get_cumm_inst_issued_qty;
      END IF;
   ELSIF (p_mode IN ('MA','MAC'))THEN
      OPEN visit_info_csr(p_visit_id);
      FETCH visit_info_csr INTO l_locator_id, l_subinventory,l_locator_segments;
      CLOSE visit_info_csr;

      l_avail_qty := 0;
      l_quantity := 0;
      IF(p_item_instance_id IS NULL)THEN
        FOR avail_rec IN get_visit_avail_qty(p_visit_id,l_subinventory,l_locator_id) LOOP
          l_avail_qty := 0;
          IF(avail_rec.required_quantity > (avail_rec.issued_qty + avail_rec.available_quantity))THEN
           l_avail_qty := avail_rec.available_quantity;
          ELSIF(avail_rec.required_quantity > avail_rec.issued_qty)THEN
           l_avail_qty := avail_rec.required_quantity - avail_rec.issued_qty;
          END IF;
          l_quantity := l_quantity + l_avail_qty;
        END LOOP;
      ELSIF p_mode = 'MA' THEN
        FOR avail_rec IN get_inst_avail_qty(p_visit_id,p_item_instance_id,l_subinventory,l_locator_id) LOOP
          l_avail_qty := 0;
          IF(avail_rec.required_quantity > ( avail_rec.issued_qty + avail_rec.available_quantity))THEN
           l_avail_qty := avail_rec.available_quantity;
          ELSIF(avail_rec.required_quantity > avail_rec.issued_qty)THEN
           l_avail_qty := avail_rec.required_quantity - avail_rec.issued_qty;
          END IF;
          l_quantity := l_quantity + l_avail_qty;
        END LOOP;

      ELSIF p_mode = 'MAC' THEN
        FOR avail_rec IN get_cumm_inst_avail_qty(p_visit_id,p_item_instance_id,l_subinventory,l_locator_id) LOOP
          l_avail_qty := 0;
          IF(avail_rec.required_quantity > ( avail_rec.issued_qty + avail_rec.available_quantity))THEN
           l_avail_qty := avail_rec.available_quantity;
          ELSIF(avail_rec.required_quantity > avail_rec.issued_qty)THEN
           l_avail_qty := avail_rec.required_quantity - avail_rec.issued_qty;
          END IF;
          l_quantity := l_quantity + l_avail_qty;
        END LOOP;
      END IF;

   ELSIF (p_mode IN ('MU','MUC'))THEN
      OPEN visit_info_csr(p_visit_id);
      FETCH visit_info_csr INTO l_locator_id, l_subinventory,l_locator_segments;
      CLOSE visit_info_csr;

      l_unavail_qty := 0;
      l_quantity := 0;

      IF(p_item_instance_id IS NULL)THEN
        FOR avail_rec IN get_visit_avail_qty(p_visit_id,l_subinventory,l_locator_id) LOOP
          l_unavail_qty := 0;
          IF((avail_rec.required_quantity - (avail_rec.issued_qty +  avail_rec.available_quantity)) > 0)THEN
           l_unavail_qty := avail_rec.required_quantity - (avail_rec.issued_qty +  avail_rec.available_quantity);
          ELSE
           l_unavail_qty := 0;
          END IF;
          l_quantity := l_quantity + l_unavail_qty;
        END LOOP;
      ELSIF p_mode = 'MU' THEN
        FOR avail_rec IN get_inst_avail_qty(p_visit_id,p_item_instance_id,l_subinventory,l_locator_id) LOOP
          l_unavail_qty := 0;
          IF((avail_rec.required_quantity - (avail_rec.issued_qty +  avail_rec.available_quantity)) > 0)THEN
           l_unavail_qty := avail_rec.required_quantity - (avail_rec.issued_qty +  avail_rec.available_quantity);
          ELSE
           l_unavail_qty := 0;
          END IF;
          l_quantity := l_quantity + l_unavail_qty;
        END LOOP;
      ELSIF p_mode = 'MUC' THEN
        FOR avail_rec IN get_cumm_inst_avail_qty(p_visit_id,p_item_instance_id,l_subinventory,l_locator_id) LOOP
          l_unavail_qty := 0;
          IF((avail_rec.required_quantity - (avail_rec.issued_qty +  avail_rec.available_quantity)) > 0)THEN
           l_unavail_qty := avail_rec.required_quantity - (avail_rec.issued_qty +  avail_rec.available_quantity);
          ELSE
           l_unavail_qty := 0;
          END IF;
          l_quantity := l_quantity + l_unavail_qty;
        END LOOP;
      END IF;
   END IF;
   RETURN NVL(l_quantity,0);
 END Get_item_count;

 FUNCTION Get_visit_completion_perc
 (
   		p_visit_id                 IN NUMBER
 ) RETURN NUMBER IS

 CURSOR completed_time_csr(p_visit_id NUMBER) IS
 SELECT nvl(SUM(SCHEDULED_END_DATE - SCHEDULED_START_DATE),0)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE IN('4','5','7','12')
 GROUP BY visit_id;

 CURSOR completed_wo_count_csr(p_visit_id NUMBER) IS
 SELECT count(*)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE IN('4','5','7','12')
 GROUP BY visit_id;

 CURSOR total_time_csr(p_visit_id NUMBER) IS
 SELECT nvl(SUM(SCHEDULED_END_DATE - SCHEDULED_START_DATE),0)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE <> '22'
 GROUP BY visit_id;

 CURSOR total_wo_count_csr(p_visit_id NUMBER) IS
 SELECT count(*)
 FROM AHL_SEARCH_WORKORDERS_V
 WHERE visit_id = p_visit_id
 AND JOB_STATUS_CODE <> '22'
 GROUP BY visit_id;

 total_time NUMBER;
 completed_time NUMBER;

 l_comp_percentage NUMBER;

 BEGIN
   OPEN completed_time_csr(p_visit_id);
   FETCH completed_time_csr INTO completed_time;
   CLOSE completed_time_csr;

   completed_time := NVL(completed_time,0);

   OPEN total_time_csr(p_visit_id);
   FETCH total_time_csr INTO total_time;
   CLOSE total_time_csr;

   IF(total_time = 0) THEN
     OPEN completed_wo_count_csr(p_visit_id);
     FETCH completed_wo_count_csr INTO completed_time;
     CLOSE completed_wo_count_csr;

     OPEN total_wo_count_csr(p_visit_id);
     FETCH total_wo_count_csr INTO total_time;
     CLOSE total_wo_count_csr;
   END IF;

   IF(total_time = 0) THEN
     RETURN 100;
   END IF;

   l_comp_percentage := ROUND((completed_time/total_time)*100);

   RETURN l_comp_percentage;

 END Get_visit_completion_perc;

 PROCEDURE Get_mrshl_details
 (
   		p_api_version        IN    NUMBER     := 1.0,
   		p_init_msg_list      IN    VARCHAR2   := FND_API.G_FALSE,
   		p_commit             IN    VARCHAR2   := FND_API.G_FALSE,
   		p_validation_level   IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   		p_default            IN    VARCHAR2   := FND_API.G_FALSE,
   		p_module_type        IN    VARCHAR2   := NULL,
 		p_unit_header_id     IN	   NUMBER,
 		p_item_instance_id   IN	   NUMBER,
        p_visit_id           IN	   NUMBER,
   		x_mrshl_details_tbl     OUT NOCOPY mrshl_details_tbl_type,
   		x_return_status            OUT NOCOPY           VARCHAR2,
   		x_msg_count                OUT NOCOPY           NUMBER,
   		x_msg_data                 OUT NOCOPY           VARCHAR2
 )IS


 l_api_name       CONSTANT   VARCHAR2(30)   := 'Get_marsh_details';
 l_api_version    CONSTANT   NUMBER         := 1.0;

 l_count NUMBER;

 BEGIN
   --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF(p_unit_header_id IS NOT NULL)THEN
     get_uc_mrshl_details(
        p_unit_header_id         => p_unit_header_id,
        p_visit_id               => p_visit_id,
   		x_Uc_mrshl_details_tbl      => x_mrshl_details_tbl);
  ELSIF(p_item_instance_id IS NOT NULL)THEN
        get_inst_mrshl_details(
        p_item_instance_id       => p_item_instance_id,
        p_visit_id               => p_visit_id,
   		x_inst_mrshl_details_tbl => x_mrshl_details_tbl);
  END IF;

  IF x_mrshl_details_tbl.FIRST IS NOT NULL THEN
    FOR i IN x_mrshl_details_tbl.FIRST..x_mrshl_details_tbl.LAST LOOP
       INSERT INTO ahl_prd_mb_uc_details
       (
         Unit_Header_id,
         Unit_Name,
         --Path_position_id,
         relationship_id,
         parent_rel_id,
         POSITION,
         IS_POSITION_SER_CTRLD,
         CURR_ITEM_ID,
         CURR_INSTANCE_ID,
         parent_instance_id,
         ALLOWED_QTY,
         CURR_ITEM_NUMBER,
         CURR_SERIAL_NUMBER,
         CURR_INSTLD_QTY,
         REQ_QTY,
         ISSUED_QTY,
         AVAILABLE_QTY,
         NOT_AVAILABLE_QTY,
         COMPL_WO_COUNT,
         TOTAL_WO_COUNT,
         CUMM_REQ_QTY,
         CUMM_ISSUED_QTY,
         CUMM_AVAILABLE_QTY,
         CUMM_NOT_AVAILABLE_QTY,
         CUMM_COMPL_WO_COUNT,
         CUMM_TOTAL_WO_COUNT,
         ROOT_INSTANCE_ID
       )VALUES
       (
         x_mrshl_details_tbl(i).Unit_Header_id,
         x_mrshl_details_tbl(i).Unit_Name,
         x_mrshl_details_tbl(i).relationship_id,
         x_mrshl_details_tbl(i).parent_rel_id,
         x_mrshl_details_tbl(i).POSITION,
         x_mrshl_details_tbl(i).IS_POSITION_SER_CTRLD,
         x_mrshl_details_tbl(i).CURR_ITEM_ID,
         x_mrshl_details_tbl(i).CURR_INSTANCE_ID,
         x_mrshl_details_tbl(i).parent_instance_id,
         x_mrshl_details_tbl(i).ALLOWED_QTY,
         x_mrshl_details_tbl(i).CURR_ITEM_NUMBER,
         x_mrshl_details_tbl(i).CURR_SERIAL_NUMBER,
         x_mrshl_details_tbl(i).CURR_INSTLD_QTY,
         x_mrshl_details_tbl(i).REQ_QTY,
         x_mrshl_details_tbl(i).ISSUED_QTY,
         x_mrshl_details_tbl(i).AVAILABLE_QTY,
         x_mrshl_details_tbl(i).NOT_AVAILABLE_QTY,
         x_mrshl_details_tbl(i).COMPL_WO_COUNT,
         x_mrshl_details_tbl(i).TOTAL_WO_COUNT,
         x_mrshl_details_tbl(i).CUMM_REQ_QTY,
         x_mrshl_details_tbl(i).CUMM_ISSUED_QTY,
         x_mrshl_details_tbl(i).CUMM_AVAILABLE_QTY,
         x_mrshl_details_tbl(i).CUMM_NOT_AVAILABLE_QTY,
         x_mrshl_details_tbl(i).CUMM_COMPL_WO_COUNT,
         x_mrshl_details_tbl(i).CUMM_TOTAL_WO_COUNT,
         x_mrshl_details_tbl(i).ROOT_INSTANCE_ID
       );
    END LOOP;
  END IF;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
                   'At the end of the procedure');
  END IF;

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT WORK;
  END IF;
  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
 END Get_mrshl_details;

 PROCEDURE get_uc_mrshl_details(
        p_unit_header_id           IN NUMBER,
        p_visit_id                 IN	   NUMBER,
   		x_Uc_mrshl_details_tbl     OUT NOCOPY mrshl_details_tbl_type) IS


 l_api_name       CONSTANT   VARCHAR2(30)   := 'get_uc_mrshl_details';
 l_Uc_mrshl_details_tbl mrshl_details_tbl_type;
 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_uc_descendant_tbl AHL_UC_TREE_PVT.uc_descendant_tbl_type;
 l_unit_name VARCHAR2(80);
 l_root_instance_id NUMBER;

 CURSOR uc_header_information(c_unit_header_id IN NUMBER) IS
 SELECT UC_NAME,CSI_INSTANCE_ID FROM ahl_unit_config_headers_v
 WHERE UC_HEADER_ID = c_unit_header_id;

 CURSOR get_part_info(c_instance_id NUMBER) IS
 SELECT M.inventory_item_id,M.concatenated_segments,C.serial_number,
        C.QUANTITY
 FROM mtl_system_items_kfv M, csi_item_instances C
 WHERE C.instance_id = c_instance_id
 AND C.inventory_item_id = M.inventory_item_id
 AND C.inv_master_organization_id = M.organization_id;

 /*CURSOR get_all_details(c_unit_header_id IN NUMBER) IS
 Select * FROM   ahl_prd_mb_uc_details
 WHERE UNIT_HEADER_ID = c_unit_header_id;*/

 CURSOR get_pos_dtls_csr(c_mc_relationship_id IN NUMBER,
                          c_instance_id        IN NUMBER) IS
   SELECT iasso.quantity Itm_qty,
          iasso.uom_code Itm_uom_code,
          iasso.revision Itm_revision,
          iasso.item_association_id,
          reln.quantity Posn_qty,
          reln.uom_code Posn_uom_code,
          reln.parent_relationship_id,
          reln.position_ref_code,
          csi.INVENTORY_ITEM_ID,
          csi.QUANTITY Inst_qty,
          csi.UNIT_OF_MEASURE Inst_uom_code
     FROM ahl_mc_relationships reln, ahl_item_associations_b iasso, csi_item_instances csi
    WHERE csi.INSTANCE_ID = c_instance_id
      AND reln.relationship_id = c_mc_relationship_id
      AND iasso.item_group_id = reln.item_group_id
      AND iasso.inventory_item_id = CSI.INVENTORY_ITEM_ID
      AND (iasso.revision IS NULL OR iasso.revision = CSI.INVENTORY_REVISION)
      AND iasso.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
      AND trunc(nvl(reln.active_start_date, sysdate)) <= trunc(sysdate)
      AND trunc(nvl(reln.active_end_date, sysdate+1)) > trunc(sysdate);

 l_pos_dtls_rec      get_pos_dtls_csr%ROWTYPE;

 j NUMBER;
 l_allowed_quantity NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  OPEN uc_header_information(p_unit_header_id);
  FETCH uc_header_information INTO l_unit_name,l_root_instance_id;
  CLOSE uc_header_information;

  AHL_UC_TREE_PVT.get_whole_uc_tree(
        p_api_version       =>  1.0,
        p_init_msg_list     => FND_API.G_TRUE,
        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data,
        p_uc_header_id      => p_unit_header_id,
        x_uc_descendant_tbl => l_uc_descendant_tbl);
  IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  j := 1;
  IF l_uc_descendant_tbl.FIRST IS NOT NULL THEN
   FOR i IN l_uc_descendant_tbl.FIRST..l_uc_descendant_tbl.LAST LOOP
    l_Uc_mrshl_details_tbl(j).Unit_Header_id := p_unit_header_id;
    l_Uc_mrshl_details_tbl(j).Unit_Name := l_unit_name;
    l_Uc_mrshl_details_tbl(j).root_instance_id := l_root_instance_id;

    l_Uc_mrshl_details_tbl(j).relationship_id := l_uc_descendant_tbl(i).relationship_id;
    l_Uc_mrshl_details_tbl(j).parent_rel_id := l_uc_descendant_tbl(i).parent_rel_id;
    l_Uc_mrshl_details_tbl(j).POSITION := l_uc_descendant_tbl(i).position_reference;

    l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID := l_uc_descendant_tbl(i).INSTANCE_ID;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'l_uc_descendant_tbl(i).INSTANCE_ID :: ' || l_uc_descendant_tbl(i).INSTANCE_ID);
    END IF;
    l_Uc_mrshl_details_tbl(j).parent_instance_id := l_uc_descendant_tbl(i).parent_instance_id;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'l_uc_descendant_tbl(i).parent_instance_id :: ' || l_uc_descendant_tbl(i).parent_instance_id);
    END IF;
    IF l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID IS NOT NULL THEN
     OPEN get_part_info(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID);
     FETCH get_part_info INTO l_Uc_mrshl_details_tbl(j).CURR_ITEM_ID,
                             l_Uc_mrshl_details_tbl(j).CURR_ITEM_NUMBER,
                             l_Uc_mrshl_details_tbl(j).CURR_SERIAL_NUMBER,
                             l_Uc_mrshl_details_tbl(j).CURR_INSTLD_QTY;
     CLOSE get_part_info;
    END IF;
    IF(l_Uc_mrshl_details_tbl(j).CURR_INSTLD_QTY IS NULL)THEN
      l_Uc_mrshl_details_tbl(j).CURR_INSTLD_QTY := 0;
    END IF;


    IF(l_Uc_mrshl_details_tbl(j).CURR_ITEM_NUMBER IS NOT NULL)THEN
      l_Uc_mrshl_details_tbl(j).POSITION := l_Uc_mrshl_details_tbl(j).POSITION || ' (' ||
                                              l_Uc_mrshl_details_tbl(j).CURR_ITEM_NUMBER;
       IF(l_Uc_mrshl_details_tbl(j).CURR_SERIAL_NUMBER IS NOT NULL)THEN
          l_Uc_mrshl_details_tbl(j).POSITION := l_Uc_mrshl_details_tbl(j).POSITION || '\' ||
                                              l_Uc_mrshl_details_tbl(j).CURR_SERIAL_NUMBER || ')';
       ELSE
          l_Uc_mrshl_details_tbl(j).POSITION := l_Uc_mrshl_details_tbl(j).POSITION || ')';
       END IF;
    END IF;

    l_Uc_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD :=
        AHL_MC_PATH_POSITION_PVT.Is_Position_Serial_Controlled(
          p_relationship_id  => l_Uc_mrshl_details_tbl(j).relationship_id,
          p_path_position_id => NULL
        );
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'l_Uc_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD :: ' || l_Uc_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD);
    END IF;
    IF(l_Uc_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD = 'Y')THEN
     l_Uc_mrshl_details_tbl(j).ALLOWED_QTY :=1;
    ELSE
     IF (l_uc_descendant_tbl(i).relationship_id IS NOT NULL) THEN
      OPEN get_pos_dtls_csr(c_mc_relationship_id => l_uc_descendant_tbl(i).relationship_id,
                            c_instance_id        => l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID);
      FETCH get_pos_dtls_csr INTO l_pos_dtls_rec;
      CLOSE get_pos_dtls_csr;

      IF (l_pos_dtls_rec.Itm_qty IS NULL OR l_pos_dtls_rec.Itm_qty = 0) THEN
        -- Pick the Quantity and UOM from Position level.
        l_pos_dtls_rec.Itm_qty      := l_pos_dtls_rec.Posn_qty;
        l_pos_dtls_rec.Itm_uom_code := l_pos_dtls_rec.Posn_uom_code;
      END IF;

      IF (l_pos_dtls_rec.Itm_uom_code <> l_pos_dtls_rec.Inst_uom_code) THEN
        -- UOMs are different: Convert Item UOM Qty to Inst UOM Qty
        l_allowed_quantity := inv_convert.inv_um_convert(item_id       => l_pos_dtls_rec.INVENTORY_ITEM_ID,
                                                 precision     => 6,
                                                 from_quantity => l_pos_dtls_rec.Itm_qty,
                                                 from_unit     => l_pos_dtls_rec.Itm_uom_code,
                                                 to_unit       => l_pos_dtls_rec.Inst_uom_code,
                                                 from_name     => NULL,
                                                 to_name       => NULL);
        l_pos_dtls_rec.Itm_qty := l_allowed_quantity;
        l_pos_dtls_rec.Itm_uom_code := l_pos_dtls_rec.Inst_uom_code;
      END IF;
      l_Uc_mrshl_details_tbl(j).ALLOWED_QTY := NVL(l_pos_dtls_rec.Itm_qty,0);
     END IF;
    END IF;
    /*
    MU - Material unavailable
    MUC - Material unavailable Cummulative
	MA - Material Avaialble
	MAC - Material Avaialble Cummulative
	MR - Material Required
	MRC - Material Required Cummulative
	MI - Material Issued
	MIC - Material Issued Cummulative
    */
    l_Uc_mrshl_details_tbl(j).REQ_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MR'
    );
    l_Uc_mrshl_details_tbl(j).CUMM_REQ_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MRC'
    );
    l_Uc_mrshl_details_tbl(j).ISSUED_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MI'
    );

    l_Uc_mrshl_details_tbl(j).CUMM_ISSUED_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MIC'
    );
    l_Uc_mrshl_details_tbl(j).AVAILABLE_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MA'
    );
    l_Uc_mrshl_details_tbl(j).CUMM_AVAILABLE_QTY :=  Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MAC'
    );
    l_Uc_mrshl_details_tbl(j).NOT_AVAILABLE_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MU'
    );
    l_Uc_mrshl_details_tbl(j).CUMM_NOT_AVAILABLE_QTY :=  Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MUC'
    );
    l_Uc_mrshl_details_tbl(j).COMPL_WO_COUNT := Get_workorder_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'CO'
    );
    l_Uc_mrshl_details_tbl(j).CUMM_COMPL_WO_COUNT := Get_workorder_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'COC'
    );
    l_Uc_mrshl_details_tbl(j).TOTAL_WO_COUNT := Get_workorder_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'TO'
    );
    l_Uc_mrshl_details_tbl(j).CUMM_TOTAL_WO_COUNT := Get_workorder_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'TOC'
    );
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'l_Uc_mrshl_details_tbl(j).TOTAL_WO_COUNT :: ' || l_Uc_mrshl_details_tbl(j).TOTAL_WO_COUNT);
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'l_Uc_mrshl_details_tbl(j) :: ' || i);
    END IF;
    j := j+1;
   END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'Done fetching details');
  END IF;

  x_Uc_mrshl_details_tbl := l_Uc_mrshl_details_tbl;
  /*IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'final fetch');
  END IF;
  FOR get_all_details_rec IN get_all_details(p_unit_header_id) LOOP
    x_Uc_mrshl_details_tbl(j).Unit_Header_id := get_all_details_rec.Unit_Header_id ;
    x_Uc_mrshl_details_tbl(j).Unit_Name := get_all_details_rec.Unit_Name ;
    x_Uc_mrshl_details_tbl(j).Path_position_id := get_all_details_rec.Path_position_id ;
    x_Uc_mrshl_details_tbl(j).relationship_id := get_all_details_rec.relationship_id ;
    x_Uc_mrshl_details_tbl(j).parent_rel_id := get_all_details_rec.parent_rel_id ;
    x_Uc_mrshl_details_tbl(j).POSITION := get_all_details_rec.POSITION ;
    x_Uc_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD := get_all_details_rec.IS_POSITION_SER_CTRLD ;
    x_Uc_mrshl_details_tbl(j).CURR_ITEM_ID := get_all_details_rec.CURR_ITEM_ID ;
    x_Uc_mrshl_details_tbl(j).CURR_INSTANCE_ID := get_all_details_rec.CURR_INSTANCE_ID ;
    x_Uc_mrshl_details_tbl(j).parent_instance_id := get_all_details_rec.parent_instance_id ;
    x_Uc_mrshl_details_tbl(j).ALLOWED_QTY := get_all_details_rec.ALLOWED_QTY ;
    x_Uc_mrshl_details_tbl(j).CURR_ITEM_NUMBER := get_all_details_rec.CURR_ITEM_NUMBER ;
    x_Uc_mrshl_details_tbl(j).CURR_SERIAL_NUMBER := get_all_details_rec.CURR_SERIAL_NUMBER ;
    x_Uc_mrshl_details_tbl(j).CURR_INSTLD_QTY := get_all_details_rec.CURR_INSTLD_QTY ;
    x_Uc_mrshl_details_tbl(j).REQ_QTY := get_all_details_rec.REQ_QTY ;
    x_Uc_mrshl_details_tbl(j).ISSUED_QTY := get_all_details_rec.ISSUED_QTY ;
    x_Uc_mrshl_details_tbl(j).AVAILABLE_QTY := get_all_details_rec.AVAILABLE_QTY ;
    x_Uc_mrshl_details_tbl(j).NOT_AVAILABLE_QTY := get_all_details_rec.NOT_AVAILABLE_QTY ;
    x_Uc_mrshl_details_tbl(j).COMPL_WO_COUNT  := get_all_details_rec.COMPL_WO_COUNT ;
    x_Uc_mrshl_details_tbl(j).TOTAL_WO_COUNT := get_all_details_rec.TOTAL_WO_COUNT ;
    x_Uc_mrshl_details_tbl(j).CUMM_REQ_QTY  := get_all_details_rec.CUMM_REQ_QTY ;
    x_Uc_mrshl_details_tbl(j).CUMM_ISSUED_QTY  := get_all_details_rec.CUMM_ISSUED_QTY ;
    x_Uc_mrshl_details_tbl(j).CUMM_AVAILABLE_QTY  := get_all_details_rec.CUMM_AVAILABLE_QTY ;
    x_Uc_mrshl_details_tbl(j).CUMM_NOT_AVAILABLE_QTY := get_all_details_rec.CUMM_NOT_AVAILABLE_QTY ;
    x_Uc_mrshl_details_tbl(j).CUMM_COMPL_WO_COUNT:= get_all_details_rec.CUMM_COMPL_WO_COUNT;
    x_Uc_mrshl_details_tbl(j).CUMM_TOTAL_WO_COUNT := get_all_details_rec.CUMM_TOTAL_WO_COUNT;
    j := j+1;
  END LOOP;*/

END get_uc_mrshl_details;

PROCEDURE get_inst_mrshl_details(
        p_item_instance_id         IN NUMBER,
        p_visit_id                 IN	   NUMBER,
   		x_inst_mrshl_details_tbl     OUT NOCOPY mrshl_details_tbl_type) IS

 l_api_name       CONSTANT   VARCHAR2(30)   := 'get_uc_mrshl_details';
 l_inst_mrshl_details_tbl mrshl_details_tbl_type;
 j NUMBER;

 CURSOR get_part_info(c_instance_id NUMBER) IS
 SELECT M.inventory_item_id,M.concatenated_segments,C.serial_number,
        DECODE(M.serial_number_control_code,'1','N','Y') is_serial_cntld,C.quantity
 FROM mtl_system_items_kfv M, csi_item_instances C
 WHERE C.instance_id = c_instance_id
 AND C.inventory_item_id = M.inventory_item_id
 AND C.inv_master_organization_id = M.organization_id;

 CURSOR instance_tree_csr(p_root_instance_id NUMBER) IS
 SELECT instance_id,to_number(NULL) parent_instance_id FROM csi_item_instances WHERE INSTANCE_ID   = p_root_instance_id
 UNION
 SELECT
        SUBJECT_ID INSTANCE_ID,
        OBJECT_ID PARENT_INSTANCE_ID
 FROM    CSI_II_RELATIONSHIPS
 WHERE   1=1
 START WITH OBJECT_ID                           = p_root_instance_id
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
 CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE);



BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  IF p_item_instance_id IS NOT NULL THEN

    j:= 1;
    FOR instance_rec IN instance_tree_csr(p_item_instance_id) LOOP
    l_inst_mrshl_details_tbl(j).root_instance_id := p_item_instance_id;
    l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID := instance_rec.instance_id;
    l_inst_mrshl_details_tbl(j).PARENT_INSTANCE_ID := instance_rec.parent_instance_id;


    IF l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID IS NOT NULL THEN
     OPEN get_part_info(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID);
     FETCH get_part_info INTO l_inst_mrshl_details_tbl(j).CURR_ITEM_ID,
                             l_inst_mrshl_details_tbl(j).CURR_ITEM_NUMBER,
                             l_inst_mrshl_details_tbl(j).CURR_SERIAL_NUMBER,
                             l_inst_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD,
                             l_inst_mrshl_details_tbl(j).CURR_INSTLD_QTY;
     CLOSE get_part_info;
    END IF;
    l_inst_mrshl_details_tbl(j).POSITION := l_inst_mrshl_details_tbl(j).CURR_ITEM_NUMBER;
    IF(l_inst_mrshl_details_tbl(j).CURR_SERIAL_NUMBER IS NOT NULL)THEN
      l_inst_mrshl_details_tbl(j).POSITION := l_inst_mrshl_details_tbl(j).POSITION || '(' ||
                                              l_inst_mrshl_details_tbl(j).CURR_SERIAL_NUMBER || ')';
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'l_inst_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD :: ' || l_inst_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD);
    END IF;
    IF(l_inst_mrshl_details_tbl(j).IS_POSITION_SER_CTRLD = 'Y')THEN
     l_inst_mrshl_details_tbl(j).ALLOWED_QTY :=1;
    END IF;
    /*
    MU - Material unavailable
    MUC - Material unavailable Cummulative
	MA - Material Avaialble
	MAC - Material Avaialble Cummulative
	MR - Material Required
	MRC - Material Required Cummulative
	MI - Material Issued
	MIC - Material Issued Cummulative
    */
    l_inst_mrshl_details_tbl(j).REQ_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MR'
    );
    l_inst_mrshl_details_tbl(j).CUMM_REQ_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MRC'
    );
    l_inst_mrshl_details_tbl(j).ISSUED_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MI'
    );

    l_inst_mrshl_details_tbl(j).CUMM_ISSUED_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MIC'
    );
    l_inst_mrshl_details_tbl(j).AVAILABLE_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MA'
    );
    l_inst_mrshl_details_tbl(j).CUMM_AVAILABLE_QTY :=  Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MAC'
    );
    l_inst_mrshl_details_tbl(j).NOT_AVAILABLE_QTY := Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MU'
    );
    l_inst_mrshl_details_tbl(j).CUMM_NOT_AVAILABLE_QTY :=  Get_item_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'MUC'
    );
    l_inst_mrshl_details_tbl(j).COMPL_WO_COUNT := Get_workorder_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'CO'
    );
    l_inst_mrshl_details_tbl(j).CUMM_COMPL_WO_COUNT := Get_workorder_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'COC'
    );
    l_inst_mrshl_details_tbl(j).TOTAL_WO_COUNT := Get_workorder_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'TO'
    );
    l_inst_mrshl_details_tbl(j).CUMM_TOTAL_WO_COUNT := Get_workorder_count
    (
   		p_visit_id                 => p_visit_id,
   		p_item_instance_id         => NVL(l_inst_mrshl_details_tbl(j).CURR_INSTANCE_ID,-1),
   		p_mode                     => 'TOC'
    );
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'l_inst_mrshl_details_tbl(j).TOTAL_WO_COUNT :: ' || l_inst_mrshl_details_tbl(j).TOTAL_WO_COUNT);
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'l_inst_mrshl_details_tbl(j) :: ' || j);
    END IF;
    j := j+1;
   END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   'Done fetching details');
  END IF;

  x_inst_mrshl_details_tbl := l_inst_mrshl_details_tbl;

END get_inst_mrshl_details;


END AHL_PRD_MRSHL_PVT;

/
