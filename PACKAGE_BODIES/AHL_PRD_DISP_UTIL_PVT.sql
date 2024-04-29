--------------------------------------------------------
--  DDL for Package Body AHL_PRD_DISP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_DISP_UTIL_PVT" AS
/* $Header: AHLVDIUB.pls 120.8 2008/01/29 14:06:11 sathapli ship $ */

-- Define global internal variables and cursors
G_PKG_NAME    VARCHAR2(30) := 'AHL_PRD_DISP_UTIL_PVT';
G_APP_NAME         CONSTANT  VARCHAR2(3) := 'AHL';
G_WO_STATUS_COMPLETE  CONSTANT NUMBER := 1;

G_LOG_PREFIX  VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.';

G_ISSUE_ID  CONSTANT NUMBER := 35;
G_RETURN_ID CONSTANT NUMBER := 43;

-- Start of Comments  --
-- Define procedure get_disposition_list
-- Procedure name: get_disposition_list
-- Type: Private
-- Function: API to get all dispositions for a job. This API is used  to replace the
--           disposition view which is too complicated to build
-- Pre-reqs:
--
-- Parameters:
--   p_workorder_id    IN NUMBER Required, to identify the job
--   p_start_row       IN NUMBER specify the start row to populate into search result table
--   p_rows_per_page   IN NUMBER specify the number of row to be populated in the search result table
--   p_disp_filter_rec IN disp_filter_rec_type, to store the record structure with which
--                        to restrict the disposition list result
--   x_results_count   OUT NUMBER, row count from the query, this number can be more than the
--                        number of row in search result table
--   x_disp_list_tbl   OUT disp_list_tbl_type, to store the disposition list result
-- Version: Initial Version   1.0
--
-- End of Comments  --

PROCEDURE get_disposition_list(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  --p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_workorder_id          IN  NUMBER,
  p_start_row             IN  NUMBER,
  p_rows_per_page         IN  NUMBER,
  p_disp_filter_rec       IN  disp_filter_rec_type,
  x_results_count         OUT NOCOPY NUMBER,
  x_disp_list_tbl         OUT NOCOPY disp_list_tbl_type)
IS
  CURSOR get_job_attrs IS
--begin performance tuning
/*    SELECT job_number,
           organization_id,
           job_status_code
      FROM ahl_workorders_v
     WHERE workorder_id = p_workorder_id;
     */
 SELECT 'x'
      FROM ahl_workorders
     WHERE workorder_id = p_workorder_id;
     l_job_attrs get_job_attrs%ROWTYPE;
--end performance tuning

  CURSOR get_item_group_id(c_item_group_name VARCHAR2) IS
    SELECT item_group_id
      FROM ahl_item_groups_b
     WHERE name = c_item_group_name;

  CURSOR check_inv_item_id(c_inventory_item_id NUMBER, c_organization_id NUMBER) IS
    SELECT inventory_item_id
      FROM mtl_system_items_kfv
     WHERE inventory_item_id = c_inventory_item_id
       AND organization_id = c_organization_id;

  CURSOR get_inv_item_id(c_item_number VARCHAR2, c_organization_id NUMBER) IS
    SELECT inventory_item_id
      FROM mtl_system_items_kfv
     WHERE concatenated_segments = c_item_number
       AND organization_id = c_organization_id;

  CURSOR check_con_status_id(c_status_id VARCHAR2) IS
    SELECT status_id
      FROM mtl_material_statuses
     WHERE status_id = c_status_id;

  CURSOR get_con_status_id(c_status_code VARCHAR2) IS
    SELECT status_id
      FROM mtl_material_statuses
     WHERE status_code = c_status_code;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
-- The OFF and ON quantity for the search UI table needs to be set with the
-- newly added columns of the view AHL_PART_CHANGES_V, instead of the instance quantity.
  CURSOR get_part_change_instance(c_part_change_id NUMBER) IS
    SELECT OFFC.inventory_item_id off_inv_item_id,
           OFFI.concatenated_segments off_item_number,
           OFFC.instance_number off_instance_number,
           OFFC.serial_number off_serial_number,
           OFFC.lot_number off_lot_number,
           -- OFFC.quantity off_quantity,
           PC.removed_quantity off_quantity,
           OFFC.unit_of_measure off_uom,
           ONC.inventory_item_id on_inv_item_id,
           ONI.concatenated_segments on_item_number,
           ONC.instance_number on_instance_number,
           ONC.serial_number on_serial_number,
           ONC.lot_number on_lot_number,
           -- ONC.quantity on_quantity,
           PC.installed_quantity on_quantity,
           ONC.unit_of_measure on_uom
     FROM ahl_part_changes_v PC,
          csi_item_instances OFFC,
          mtl_system_items_kfv OFFI,
          csi_item_instances ONC,
          mtl_system_items_kfv ONI
    WHERE PC.part_change_id = c_part_change_id
      AND PC.removed_instance_id = OFFC.instance_id (+)
      AND PC.installed_instance_id = ONC.instance_id (+)
      AND OFFC.inventory_item_id = OFFI.inventory_item_id (+)
      AND OFFC.inv_master_organization_id = OFFI.organization_id (+)
      AND ONC.inventory_item_id = ONI.inventory_item_id (+)
      AND ONC.inv_master_organization_id = ONI.organization_id (+);
  l_part_change_instance get_part_change_instance%ROWTYPE;

  CURSOR get_disp_mtl_txn_assoc (c_disposition_id NUMBER) IS
    SELECT MT.transaction_type_id transaction_type_id,
           DM.uom uom,
           sum(DM.quantity) quantity,
           count(MT.transaction_type_id) rec_no
      FROM ahl_workorder_mtl_txns MT,
           ahl_prd_disp_mtl_txns DM
     WHERE DM.disposition_id = c_disposition_id
       AND MT.workorder_mtl_txn_id = DM.workorder_mtl_txn_id
  GROUP BY MT.transaction_type_id, DM.uom
    HAVING MT.transaction_type_id IN (G_ISSUE_ID, G_RETURN_ID);

  CURSOR get_disp_mtl_txn(c_disposition_id NUMBER, c_txn_type_id NUMBER) IS
    SELECT MT.transaction_type_id transaction_type_id,
           MT.inventory_item_id inv_item_id,
           IV.concatenated_segments item_number,
           MT.serial_number serial_number,
           MT.lot_number lot_number,
           DM.quantity quantity,
           DM.uom uom
      FROM ahl_workorder_mtl_txns MT,
           ahl_prd_disp_mtl_txns DM,
           mtl_system_items_kfv IV
     WHERE DM.disposition_id = c_disposition_id
       AND MT.workorder_mtl_txn_id = DM.workorder_mtl_txn_id
       AND MT.transaction_type_id = c_txn_type_id
       AND MT.inventory_item_id = IV.inventory_item_id
       AND MT.organization_id = IV.organization_id;
  l_disp_mtl_txn get_disp_mtl_txn%ROWTYPE;

  l_api_name       CONSTANT   VARCHAR2(30)   := 'get_disposition_list';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  l_disposition_id    NUMBER;
  l_part_change_id    NUMBER;
  l_path_position_id  NUMBER;
  l_path_pos_common_id  NUMBER;
  l_path_position_ref VARCHAR2(80);
  l_inv_item_id       NUMBER;
  l_item_number       VARCHAR2(40);
  l_item_group_id     NUMBER;
  l_item_group_name   VARCHAR2(80);
  l_con_status_id     NUMBER;
  l_con_status_code   VARCHAR2(80);
  l_instance_id       NUMBER;
  l_instance_number   VARCHAR2(30);
  l_serial_number     VARCHAR2(30);
  l_lot_number        MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;
  l_quantity          NUMBER;
  l_uom               VARCHAR2(3);
  l_immediate_disp_code VARCHAR2(30);
  l_immediate_disp      VARCHAR2(80);
  l_secondary_disp_code VARCHAR2(30);
  l_secondary_disp      VARCHAR2(80);
  l_disp_status_code  VARCHAR2(30);
  l_disp_status       VARCHAR2(80);
  l_condition_id      NUMBER;
  l_condition_code    VARCHAR2(80);
  l_issue_no          NUMBER;
  l_return_no         NUMBER;

  l_sql_str        VARCHAR2(10000);
  l_from_string       VARCHAR2(5000);
  l_where_str      VARCHAR2(10000);
  l_count_query       VARCHAR2(10000);
  l_and_str           VARCHAR(20);

  i                   NUMBER;
  l_bind_index        NUMBER := 1;
  l_count             NUMBER;
  l_cur_index         NUMBER;
  l_start_row         NUMBER;
  l_msg_index         NUMBER;
  l_translated_msg    VARCHAR2(100);
  l_cur               AHL_OSP_UTIL_PKG.ahl_search_csr;
  l_conditions        AHL_OSP_UTIL_PKG.ahl_conditions_tbl;

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT get_disposition_list;

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

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||': Begin API',
                   'At the start of the procedure and p_workorder_id = '||p_workorder_id||
                   ' p_start_row = '||p_start_row||' p_rows_per_page='||p_rows_per_page);
  END IF;

  --Validate the input parameter p_workorder_id
  OPEN get_job_attrs;
  FETCH get_job_attrs INTO l_job_attrs;
  IF get_job_attrs%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL', 'AHL_PRD_DISP_JOB_ID_INVALID');
    FND_MESSAGE.set_token('JOBID', p_workorder_id);
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    CLOSE get_job_attrs;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE get_job_attrs;
  END IF;

  --For the field of path position, if the user wants to use the condition, then it must be
  --triggered by LOV, and the search is based on the id instead of value. Also the search uses
  --only the version neutral common id even if the user uses the version specific path position id.
  IF (p_disp_filter_rec.path_position_ref IS NOT NULL AND p_disp_filter_rec.path_position_id IS NOT NULL) THEN
    SELECT path_pos_common_id INTO l_path_pos_common_id
      FROM ahl_mc_path_positions
     WHERE path_position_id = p_disp_filter_rec.path_position_id;
  END IF;

  /* This is an API for search page, so the value to id conversion is really not necessary

  --Convert values to IDs of the filter record

  --Convert item_group_name to item_group_id

  --Convert item_number to inventory_item_id
  IF (p_disp_filter_rec.inventory_item_id IS NOT NULL) THEN
    --This includes three cases: 1) id only 2) value and id while id is correct but value may be wrong
    --3) value and id while value is correct but id maybe wrong. It is better to handle these three cases
    --differently. But here we ignore the warning message which should be sent to user if value is wrong
    --in case 20 and totally ignore the correct value of case 3). But this case will cover regular LOV
    --return mode in which both value and id will be correct.
    OPEN check_inv_item_id(p_disp_filter_rec.inventory_item_id, l_job_attrs.organization_id);
    FETCH check_inv_item_id INTO l_inv_item_id;
    IF check_inv_item_id%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_ITEM_ID_INVALID');
      FND_MESSAGE.set_token('ITEMID', p_disp_filter_rec.inventory_item_id);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      CLOSE check_inv_item_id;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_inv_item_id;
    END IF;
  ELSIF (p_disp_filter_rec.inventory_item_id IS NULL AND
         p_disp_filter_rec.item_number IS NOT NULL) THEN
    --This includes the case in which only value is provided.
    OPEN get_inv_item_id(p_disp_filter_rec.item_number, l_job_attrs.organization_id);
    FETCH get_inv_item_id INTO l_inv_item_id;
    IF get_inv_item_id%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_ITEM_NUM_INVALID');
      FND_MESSAGE.set_token('ITEM', p_disp_filter_rec.item_number);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      CLOSE get_inv_item_id;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_inv_item_id;
    END IF;
  END IF;
  --Convert condition_code to condition_id
  IF (p_disp_filter_rec.condition_id IS NOT NULL) THEN
    OPEN check_con_status_id(p_disp_filter_rec.condition_id);
    FETCH check_con_status_id INTO l_con_status_id;
    IF check_con_status_id%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_CON_STATUS_ID_INVALID');
      FND_MESSAGE.set_token('STATUSID', p_disp_filter_rec.condition_id);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      CLOSE check_con_status_id;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_con_status_id;
    END IF;
  ELSIF (p_disp_filter_rec.condition_id IS NULL AND
         p_disp_filter_rec.condition_code IS NOT NULL) THEN
    --This includes the case in which only value is provided.
    OPEN get_con_status_id(p_disp_filter_rec.condition_code);
    FETCH get_con_status_id INTO l_con_status_id;
    IF get_con_status_id%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_CON_STATUS_INVALID');
      FND_MESSAGE.set_token('STAUS', p_disp_filter_rec.condition_code);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      CLOSE get_con_status_id;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_con_status_id;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': Finish the value to id conversion and validation',
			       'At the end of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': l_path_position_id='||l_path_position_id||
                   'l_path_pos_comm_id='||l_path_pos_comm_id||'l_item_group_id='||l_item_group_id||
                   'l_inv_item_id='||l_inv_item_id||'l_con_status_id='||l_con_status_id);
  END IF;
  */
  --Build dynamic query to get all dispositions related to the job

  l_sql_str := 'SELECT disposition_id, part_change_id, path_position_id, position_reference, ';
  l_sql_str := l_sql_str||'inventory_item_id, item_number, instance_id, instance_number, ';
  l_sql_str := l_sql_str||'serial_number, lot_number, quantity, uom, ';
  l_sql_str := l_sql_str||'immediate_disposition_code, immediate_type, secondary_disposition_code, ';
  l_sql_str := l_sql_str||'secondary_type, status_code, status, condition_id, condition_code, item_group_id, item_group_name ';
  l_sql_str := l_sql_str||'FROM ahl_prd_dispositions_v DIS ';

  l_where_str := ' workorder_id = (:b' || l_bind_index || ')';
  l_conditions(l_bind_index) := p_workorder_id;
  l_bind_index := l_bind_index + 1;
  l_and_str := ' AND ';

  IF (l_path_pos_common_id IS NOT NULL) THEN
    l_where_str := l_where_str ||l_and_str ||' path_pos_common_id = (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := l_path_pos_common_id;
    l_bind_index := l_bind_index + 1;
    l_and_str := ' AND ';
  END IF;

  IF (p_disp_filter_rec.item_group_name IS NOT NULL) THEN
    l_where_str := l_where_str || l_and_str || ' item_group_name = (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_disp_filter_rec.item_group_name;
    l_bind_index := l_bind_index + 1;
    l_and_str := ' AND ';
  END IF;

  IF (p_disp_filter_rec.item_number IS NOT NULL) THEN
    l_where_str := l_where_str || l_and_str || ' item_number = (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_disp_filter_rec.item_number;
    l_bind_index := l_bind_index + 1;
    l_and_str := ' AND ';
  END IF;

  IF (p_disp_filter_rec.condition_code IS NOT NULL) THEN
    l_where_str := l_where_str || l_and_str || ' condition_code = (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_disp_filter_rec.condition_code;
    l_bind_index := l_bind_index + 1;
    l_and_str := ' AND ';
  END IF;

  IF (p_disp_filter_rec.immediate_disp_code IS NOT NULL AND p_disp_filter_rec.immediate_disp_code <> 'NULL') THEN
    l_where_str := l_where_str || l_and_str || ' immediate_disposition_code = (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_disp_filter_rec.immediate_disp_code;
    l_bind_index := l_bind_index + 1;
    l_and_str := ' AND ';
  ELSIF (p_disp_filter_rec.immediate_disp_code = 'NULL') THEN
    l_where_str := l_where_str || l_and_str || ' immediate_disposition_code IS NULL ';
    l_and_str := ' AND ';
  END IF;

  IF (p_disp_filter_rec.secondary_disp_code IS NOT NULL AND p_disp_filter_rec.secondary_disp_code <> 'NULL') THEN
    l_where_str := l_where_str || l_and_str || ' secondary_disposition_code = (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_disp_filter_rec.secondary_disp_code;
    l_bind_index := l_bind_index + 1;
    l_and_str := ' AND ';
  ELSIF (p_disp_filter_rec.secondary_disp_code = 'NULL') THEN
    l_where_str := l_where_str || l_and_str || ' secondary_disposition_code IS NULL ';
    l_and_str := ' AND ';
  END IF;

  IF (p_disp_filter_rec.disp_status_code IS NOT NULL AND p_disp_filter_rec.disp_status_code <> 'NULL') THEN
    l_where_str := l_where_str || l_and_str || ' status_code = (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_disp_filter_rec.disp_status_code;
    l_bind_index := l_bind_index + 1;
    l_and_str := ' AND ';
  ELSIF (p_disp_filter_rec.disp_status_code = 'NULL') THEN
    l_where_str := l_where_str || l_and_str || ' status_code IS NULL ';
    l_and_str := ' AND ';
  END IF;

  IF (p_disp_filter_rec.item_type_code IS NOT NULL) THEN
    l_where_str := l_where_str || l_and_str || ' decode(nvl(trackable_flag, ''N''), ''Y'', ''TRACKED'',''NON_TRACKED'') = (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_disp_filter_rec.item_type_code;
    l_bind_index := l_bind_index + 1;
    --l_and_str := ' AND ';
  END IF;

  IF l_where_str IS NOT NULL THEN
     l_sql_str := l_sql_str || ' WHERE ' || l_where_str ;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': Within the API',
			       'p_disp_filter_rec.condition_code='||p_disp_filter_rec.condition_code);
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': Within the API',
			       'l_sql_str='||substr(l_sql_str, 1, 254));
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': Within the API',
			       'l_sql_str='||substr(l_sql_str, 255, 500));
  END IF;
  --dbms_output.put_line(substr(l_sql_str,1, 254));
  --dbms_output.put_line(substr(l_sql_str,255, 500));

  l_count_query := 'SELECT COUNT(*) FROM (' || l_sql_str || ')';
  BEGIN
    AHL_OSP_UTIL_PKG.EXEC_IMMEDIATE(l_conditions, l_count_query, x_results_count);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_results_count := 0;
  END;

  IF x_results_count > 0 THEN
    l_sql_str := l_sql_str || ' ORDER BY DIS.disposition_id ';

    AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_cur, l_conditions, l_sql_str);
    i := 1;
    l_cur_index := 1;

    IF p_start_row > x_results_count THEN
      l_start_row := 1;
    ELSE
      l_start_row := p_start_row;
    END IF;

    LOOP
      FETCH l_cur INTO l_disposition_id,
                     l_part_change_id,
                     l_path_position_id,
                     l_path_position_ref,
                     l_inv_item_id,
                     l_item_number,
                     l_instance_id,
                     l_instance_number,
                     l_serial_number,
                     l_lot_number,
                     l_quantity,
                     l_uom,
                     l_immediate_disp_code,
                     l_immediate_disp,
                     l_secondary_disp_code,
                     l_secondary_disp,
                     l_disp_status_code,
                     l_disp_status,
                     l_condition_id,
                     l_condition_code,
                     l_item_group_id,
                     l_item_group_name;


      EXIT WHEN (l_cur%NOTFOUND OR l_cur_index = l_start_row + p_rows_per_page);   -- stop fetching

      IF (l_cur_index >= l_start_row AND l_cur_index < l_start_row + p_rows_per_page) THEN
        x_disp_list_tbl(i).disposition_id := l_disposition_id;
        x_disp_list_tbl(i).part_change_id := l_part_change_id;
        x_disp_list_tbl(i).path_position_id := l_path_position_id;
        x_disp_list_tbl(i).path_position_ref := l_path_position_ref;

        -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
        -- OFF details should not be filled for dispositions for empty positions, which
        -- are used only for installation.
        IF (l_item_number IS NOT NULL) THEN
          x_disp_list_tbl(i).off_inv_item_id := l_inv_item_id;
          x_disp_list_tbl(i).off_item_number := l_item_number;
          x_disp_list_tbl(i).off_instance_id := l_instance_id;
          x_disp_list_tbl(i).off_instance_number := l_instance_number;
          x_disp_list_tbl(i).off_serial_number := l_serial_number;
          x_disp_list_tbl(i).off_lot_number := l_lot_number;
          x_disp_list_tbl(i).off_quantity := l_quantity;
          x_disp_list_tbl(i).off_uom := l_uom;
        END IF;

        x_disp_list_tbl(i).immediate_disp_code := l_immediate_disp_code;
        x_disp_list_tbl(i).immediate_disp := l_immediate_disp;
        x_disp_list_tbl(i).secondary_disp_code := l_secondary_disp_code;
        x_disp_list_tbl(i).secondary_disp := l_secondary_disp;
        x_disp_list_tbl(i).disp_status_code := l_disp_status_code;
        x_disp_list_tbl(i).disp_status := l_disp_status;
        x_disp_list_tbl(i).condition_id := l_condition_id;
        x_disp_list_tbl(i).condition_code := l_condition_code;
        x_disp_list_tbl(i).item_group_id := l_item_group_id;
        x_disp_list_tbl(i).item_group_name := l_item_group_name;
        i := i+1;
      END IF;
      l_cur_index := l_cur_index + 1;
    END LOOP;
    CLOSE l_cur;

    --dbms_output.put_line('After getting the result table');

    FOR i IN x_disp_list_tbl.FIRST..x_disp_list_tbl.LAST LOOP
      IF x_disp_list_tbl(i).part_change_id IS NOT NULL THEN
      --There is a part change associated with this disposition
        OPEN get_part_change_instance(x_disp_list_tbl(i).part_change_id);
        FETCH get_part_change_instance INTO l_part_change_instance;

        -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
        -- ON details should not be filled for dispositions used for removal of non-serialised items.
        IF (install_part_change_valid(x_disp_list_tbl(i).disposition_id)='Y' AND
            NOT (x_disp_list_tbl(i).off_serial_number IS NULL AND
                 x_disp_list_tbl(i).off_item_number   IS NOT NULL)) THEN
          x_disp_list_tbl(i).on_inv_item_id := l_part_change_instance.on_inv_item_id;
          x_disp_list_tbl(i).on_item_number := l_part_change_instance.on_item_number;
          x_disp_list_tbl(i).on_instance_number := l_part_change_instance.on_instance_number;
          x_disp_list_tbl(i).on_serial_number := l_part_change_instance.on_serial_number;
          x_disp_list_tbl(i).on_lot_number := l_part_change_instance.on_lot_number;
          x_disp_list_tbl(i).on_quantity := l_part_change_instance.on_quantity;
          x_disp_list_tbl(i).on_uom := l_part_change_instance.on_uom;
        ELSE
          x_disp_list_tbl(i).on_inv_item_id := NULL;
          x_disp_list_tbl(i).on_item_number := NULL;
          x_disp_list_tbl(i).on_instance_number := NULL;
          x_disp_list_tbl(i).on_serial_number := NULL;
          x_disp_list_tbl(i).on_lot_number := NULL;
          x_disp_list_tbl(i).on_quantity := NULL;
          x_disp_list_tbl(i).on_uom := NULL;
        END IF;

        -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
        -- OFF details should not be filled for dispositions for empty positions, which
        -- are used only for installation.
        IF (x_disp_list_tbl(i).off_item_number IS NOT NULL) THEN

          -- Updated by RBHAVSAR for Bug fix 6456199 on Oct 10, 2007.
          -- If serial number is present for disposition then it should not be overwritten with
          -- parts change serial number and part number because part number change could have changed
          -- the part number and serial number. We need to display the original serial number  and
          -- part number as at the time of disposition.

          -- Commented out the setting of item
          -- x_disp_list_tbl(i).off_inv_item_id := l_part_change_instance.off_inv_item_id;
          -- x_disp_list_tbl(i).off_item_number := l_part_change_instance.off_item_number;
          -- Added If check for serial number so that the values are changed only for Non Serialized case
          IF (x_disp_list_tbl(i).off_serial_number IS NULL) THEN
              x_disp_list_tbl(i).off_instance_number := l_part_change_instance.off_instance_number;
              x_disp_list_tbl(i).off_serial_number := l_part_change_instance.off_serial_number;
              x_disp_list_tbl(i).off_lot_number := l_part_change_instance.off_lot_number;
              x_disp_list_tbl(i).off_quantity := l_part_change_instance.off_quantity;
              x_disp_list_tbl(i).off_uom := l_part_change_instance.off_uom;
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  G_LOG_PREFIX||l_api_name,
                  'x_disp_list_tbl(i).off_inv_item_id '|| x_disp_list_tbl(i).off_inv_item_id||
                  'x_disp_list_tbl(i).off_item_number ' || x_disp_list_tbl(i).off_item_number );
              END IF;
          END IF;

          -- End of change by RBHAVSAR for Bug fix 6456199 on Oct 10, 2007

        -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
        -- For installation against empty positions (typically for non-serialised items),
        -- fetch the ON quantity directly from the base table ahl_part_changes.
        ELSE
            SELECT quantity
            INTO   x_disp_list_tbl(i).on_quantity
            FROM   ahl_part_changes
            WHERE  part_change_id = x_disp_list_tbl(i).part_change_id;
        END IF;

        CLOSE get_part_change_instance;
      ELSE
        l_issue_no := 0;
        l_return_no := 0;
        For l_disp_mtl_txn_assoc IN get_disp_mtl_txn_assoc(x_disp_list_tbl(i).disposition_id) LOOP
        --This cursor can return only 0, 1, or 2 at most records
          IF l_disp_mtl_txn_assoc.transaction_type_id = G_ISSUE_ID THEN
            x_disp_list_tbl(i).on_quantity := l_disp_mtl_txn_assoc.quantity;
            x_disp_list_tbl(i).on_uom := l_disp_mtl_txn_assoc.uom;
            l_issue_no := l_disp_mtl_txn_assoc.rec_no;
          ELSIF l_disp_mtl_txn_assoc.transaction_type_id = G_RETURN_ID THEN
            x_disp_list_tbl(i).off_quantity := l_disp_mtl_txn_assoc.quantity;
            x_disp_list_tbl(i).off_uom := l_disp_mtl_txn_assoc.uom;
            l_return_no := l_disp_mtl_txn_assoc.rec_no;
          END IF;
        END LOOP;

        IF l_return_no = 0 THEN
        --There is no RETURN material transation associated to the disposition at all
        --We have to clear the off_quantity and off_uom because the disposition entity
        --may have them defined.
        --And if l_issue_no = 0 then by default all ON related attributes will be null.
          x_disp_list_tbl(i).off_quantity := NULL;
          x_disp_list_tbl(i).off_uom := NULL;
        END IF;
        IF l_return_no >= 1 THEN
        --If there exists one RETURN mtl txn associated to this disposition, it could be
        --tracked item or non-tracked item
        --If there exist multiple RETURN mtl txns associated to this disposition, they could
        --only be non-tracked items, but these items are the same.
          OPEN get_disp_mtl_txn(x_disp_list_tbl(i).disposition_id, G_RETURN_ID);
          FETCH get_disp_mtl_txn INTO l_disp_mtl_txn;
          x_disp_list_tbl(i).off_inv_item_id := l_disp_mtl_txn.inv_item_id;
          x_disp_list_tbl(i).off_item_number := l_disp_mtl_txn.item_number;
          IF l_return_no = 1 THEN
            x_disp_list_tbl(i).off_serial_number := l_disp_mtl_txn.serial_number;
            x_disp_list_tbl(i).off_lot_number := l_disp_mtl_txn.lot_number;
          ELSE
            x_disp_list_tbl(i).off_serial_number := null;
            x_disp_list_tbl(i).off_lot_number := null;
          END IF;
          CLOSE get_disp_mtl_txn;
        END IF;
        IF l_issue_no = 1 THEN
        --There exists one ISSUE mtl txn associated to this disposition, it could be
        --tracked item or non-tracked item
          OPEN get_disp_mtl_txn(x_disp_list_tbl(i).disposition_id, G_ISSUE_ID);
          FETCH get_disp_mtl_txn INTO l_disp_mtl_txn;
          x_disp_list_tbl(i).on_inv_item_id := l_disp_mtl_txn.inv_item_id;
          x_disp_list_tbl(i).on_item_number := l_disp_mtl_txn.item_number;
          x_disp_list_tbl(i).on_serial_number := l_disp_mtl_txn.serial_number;
          x_disp_list_tbl(i).on_lot_number := l_disp_mtl_txn.lot_number;
          CLOSE get_disp_mtl_txn;
        END IF;
        IF l_issue_no > 1 THEN
        --There exist multiple ISSUE mtl txns associated to this disposition, they could
        --only non-tracked items, and these items can be different. Not sure that the
        --items could also be tracked, even if it is possible, then the items should be the same.
          OPEN get_disp_mtl_txn(x_disp_list_tbl(i).disposition_id, G_ISSUE_ID);
          FETCH get_disp_mtl_txn INTO l_disp_mtl_txn;
          x_disp_list_tbl(i).on_inv_item_id := l_disp_mtl_txn.inv_item_id;
          x_disp_list_tbl(i).on_item_number := l_disp_mtl_txn.item_number;
          LOOP
            FETCH get_disp_mtl_txn INTO l_disp_mtl_txn;
            EXIT WHEN get_disp_mtl_txn%NOTFOUND;
            IF x_disp_list_tbl(i).on_inv_item_id <> l_disp_mtl_txn.inv_item_id THEN
              x_disp_list_tbl(i).on_inv_item_id := NULL;
              --In this case we need to assign constant '<MULTIPLE>' to on_item_number,
              --but it is translatable, so we put it into the message table and fetch back
              --the translated one. And then we need to remove this particular message from
              --the message otherwise it will interfere with other regular meaningful messages.
              FND_MESSAGE.set_name('AHL', 'AHL_PRD_CONST_MULTIPLE');
              FND_MSG_PUB.add;
              FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                              p_encoded => FND_API.G_FALSE,
                              p_data => l_translated_msg,
                              p_msg_index_out => l_msg_index);
              FND_MSG_PUB.delete_msg(l_msg_index);
              x_disp_list_tbl(i).on_item_number := l_translated_msg;
              EXIT;
            END IF;
          END LOOP;
          CLOSE get_disp_mtl_txn;
        END IF;
        --Handle the special case in which a blank record will be displayed in the UI when
        --creating default job dispositions. In this case, the disposition's item_group_id is not null but we
        --don't display item_group_name in the UI and the off_item_id is null, so we use the
        --off_item_number column to display the item_group_name to save the width of the table.
        IF (x_disp_list_tbl(i).off_inv_item_id IS NULL AND
          x_disp_list_tbl(i).item_group_id IS NOT NULL) THEN
          --In this case we need to assign '<ITEM GROUP NAME>:'+item_group_name to off_item_number,
          --but it is translatable, so we put it into the message table and fetch back
          --the translated one. And then we need to remove this particular message from
          --the message otherwise it will interfere with other regular meaningful messages.
          /* After discussion with Jay, now decided to display it just as <Item Group Name> (09/22/04)
          FND_MESSAGE.set_name('AHL', 'AHL_PRD_CONST_IG_NAME');
          FND_MSG_PUB.add;
          FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                          p_encoded => FND_API.G_FALSE,
                          p_data => l_translated_msg,
                          p_msg_index_out => l_msg_index);
          FND_MSG_PUB.delete_msg(l_msg_index);
          x_disp_list_tbl(i).off_item_number := '<'||l_translated_msg||'>:'||x_disp_list_tbl(i).item_group_name;
          */
          x_disp_list_tbl(i).off_item_number := '<'||x_disp_list_tbl(i).item_group_name||'>';

        END IF;
      END IF;
    END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||': After normal execution',
			       'At the end of the procedure');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --ROLLBACK TO get_disposition_list;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --ROLLBACK TO get_disposition_list;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    --ROLLBACK TO get_disposition_list;
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

END get_disposition_list;

------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Get_Part_Change_Disposition
--  Type        : Private
--  Function    : Fetch the disposition for part change UI
--  Pre-reqs    :
--  Parameters  : p_parent_instance_id: parent csi item instance_id
--                p_workorder_id: workorder_id
--                p_unit_config_header_id: top unit header id
--                p_relationship_id: position for installation/removal
--                x_disposition_rec: returning disposition record
--                x_imm_disp_type_tbl: returning immediate disposition type
--                x_sec_disp_type_tbl: returning secondary dispositions
--
--                SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
--                p_instance_id: Added to support IB Trees. Pass the instance id to get the disposition for the given instance.
--
--
--  End of Comments.

PROCEDURE Get_Part_Change_Disposition (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_workorder_id          IN NUMBER,
    --p_unit_config_header_id IN NUMBER, replaced by p_workorder_id by Jerry on 09/20/04
    p_parent_instance_id    IN NUMBER,
    p_relationship_id       IN NUMBER,
    p_instance_id           IN NUMBER,
    x_disposition_rec     OUT NOCOPY AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    x_imm_disp_type_tbl    OUT NOCOPY Disp_Type_Tbl_Type,
    x_sec_disp_type_tbl    OUT NOCOPY Disp_Type_Tbl_Type)
    IS
--
--Check if position is empty or filled
CURSOR check_installed_csr (p_parent_id IN NUMBER,
                            p_relationship_id IN NUMBER) IS
SELECT csi.instance_id
FROM csi_item_instances csi, csi_ii_relationships rel
WHERE csi.instance_id = rel.subject_id
    AND REL.object_id = p_parent_id
    AND REL.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(REL.ACTIVE_START_DATE, sysdate-1)) <= TRUNC(sysdate)
    AND TRUNC(nvl(REL.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    AND TO_NUMBER(REL.position_reference) = p_relationship_id;
--
--Fetch all information for the disposition_rec object for path + item
--Must share same path position, same inventory item, but no part removal yet
--Also not complete or terminated
CURSOR get_rem_disposition_csr (p_path_position_id IN NUMBER,
                                p_instance_id IN NUMBER) IS
/*
SELECT disp.disposition_id,
      disp.object_version_number,
      disp.last_update_date,
      disp.last_updated_by,
      disp.creation_date,
      disp.created_by,
      disp.last_update_login,
      disp.workorder_id,
      disp.part_change_id,
      disp.path_position_id,
      disp.item_number,
      disp.inventory_item_id,
      disp.organization_id,
      disp.instance_number,
      disp.instance_id,
      disp.item_group_id,
      disp.item_group_name,
      disp.serial_number,
      disp.lot_number,
      disp.quantity,
      disp.uom,
      disp.condition_id,
      disp.condition_code,
      disp.immediate_disposition_code,
      disp.immediate_type,
      disp.secondary_disposition_code,
      disp.secondary_type,
      disp.status_code,
      disp.status,
      disp.collection_id,
      disp.primary_service_request_id,
      disp.non_routine_workorder_id,
      disp.comments,
      INC.INCIDENT_SEVERITY_ID SEVERITY_ID,
      SEV.NAME SEVERITY_NAME,
      INC.PROBLEM_CODE,
      PCODE.MEANING PROBLEM_MEANING,
      INC.SUMMARY
FROM AHL_PRD_DISPOSITIONS_V disp, AHL_MC_PATH_POSITIONS pp,
     CS_INCIDENTS_ALL_VL INC, CS_INCIDENT_SEVERITIES_VL SEV,
     FND_LOOKUP_VALUES_VL PCODE
  WHERE disp.path_pos_common_id = pp.path_pos_common_id
  AND pp.path_position_id = p_path_position_id
  AND disp.part_change_id IS NULL
  AND disp.workorder_id = p_workorder_id
  AND nvl(disp.immediate_disposition_code,'NULL') <> 'NOT_RECEIVED'
  AND (disp.status_code IS NULL OR disp.status_code NOT IN ('COMPLETE', 'TERMINATED'))
  AND disp.instance_id = p_instance_id
  AND INC.INCIDENT_ID (+) = disp.primary_service_request_id
  AND SEV.INCIDENT_SEVERITY_ID (+) = INC.INCIDENT_SEVERITY_ID
  AND PCODE.LOOKUP_TYPE (+) = 'REQUEST_PROBLEM_CODE'
  AND PCODE.LOOKUP_CODE (+) = INC.PROBLEM_CODE;
*/
  SELECT disp.disposition_id,
         disp.object_version_number,
         disp.last_update_date,
         disp.last_updated_by,
         disp.creation_date,
         disp.created_by,
         disp.last_update_login,
         disp.workorder_id,
         disp.part_change_id,
         disp.path_position_id,
         MTL.CONCATENATED_SEGMENTS ITEM_NUMBER,
         disp.inventory_item_id,
         disp.organization_id,
         CSI.INSTANCE_NUMBER,
         disp.instance_id,
         disp.item_group_id,
         GRP.NAME ITEM_GROUP_NAME,
         disp.serial_number,
         disp.lot_number,
         disp.quantity,
         disp.uom,
         disp.condition_id,
         cond.STATUS_CODE CONDITION_CODE,
         disp.immediate_disposition_code,
         FND1.MEANING immediate_type,
         disp.secondary_disposition_code,
         FND2.MEANING secondary_type,
         disp.status_code,
         FND3.MEANING status,
         disp.collection_id,
         disp.primary_service_request_id,
         disp.non_routine_workorder_id,
         displ.comments,
         INC.INCIDENT_SEVERITY_ID SEVERITY_ID,
         SEV.NAME SEVERITY_NAME,
         INC.PROBLEM_CODE,
         PCODE.MEANING PROBLEM_MEANING,
         INCL.SUMMARY
FROM     AHL_PRD_DISPOSITIONS_b disp,
         AHL_PRD_DISPOSITIONS_tl displ,
         AHL_MC_PATH_POSITIONS pp,
         MTL_SYSTEM_ITEMS_KFV MTL,
         CSI_ITEM_INSTANCES CSI,
         AHL_ITEM_GROUPS_B GRP,
         MTL_MATERIAL_STATUSES_TL COND,
         CS_INCIDENTS_ALL_B INC,
         CS_INCIDENTS_ALL_TL INCL,
         CS_INCIDENT_SEVERITIES_TL SEV,
         FND_LOOKUP_VALUES PCODE,
         FND_LOOKUP_VALUES FND1,
         FND_LOOKUP_VALUES FND2,
         FND_LOOKUP_VALUES FND3
WHERE    pp.path_pos_common_id IN (
					SELECT PATH_POS_COMMON_ID
					FROM   AHL_MC_PATH_POSITIONS
					WHERE  PATH_POSITION_ID = p_path_position_id
				    )
AND      disp.path_position_id = pp.path_position_id
AND      disp.workorder_id =p_workorder_id
AND      disp.instance_id = p_instance_id
AND      disp.part_change_id IS NULL
AND      nvl(disp.immediate_disposition_code,'NULL') <> 'NOT_RECEIVED'
AND      (disp.status_code IS NULL OR disp.status_code NOT IN ('COMPLETE', 'TERMINATED'))
AND      INC.INCIDENT_ID (+) = disp.primary_service_request_id
AND      SEV.INCIDENT_SEVERITY_ID (+) = INC.INCIDENT_SEVERITY_ID
AND      SEV.language(+) = USERENV('LANG')
AND      PCODE.LOOKUP_TYPE (+) = 'REQUEST_PROBLEM_CODE'
AND      PCODE.LOOKUP_CODE (+) = INC.PROBLEM_CODE
AND      PCODE.language(+) = USERENV('LANG')
AND      disp.disposition_id = displ.disposition_id
AND      displ.language = USERENV('LANG')
AND      disp.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID (+)
AND      disp.ORGANIZATION_ID = MTL.organization_id (+)
AND      disp.INSTANCE_ID = CSI.INSTANCE_ID (+)
AND      disp.ITEM_GROUP_ID = GRP.ITEM_GROUP_ID (+)
AND      disp.condition_id = COND.status_id (+)
AND      COND.language(+) = USERENV('LANG')
AND      FND1.LOOKUP_TYPE (+)= 'AHL_IMMED_DISP_TYPE'
AND      disp.immediate_disposition_code = FND1.LOOKUP_CODE (+)
AND      FND1.LANGUAGE(+) =   USERENV('LANG')
AND      FND2.LOOKUP_TYPE (+)= 'AHL_SECND_DISP_TYPE'
AND      disp.SECONDARY_DISPOSITION_CODE = FND2.LOOKUP_CODE (+)
AND      FND2.LANGUAGE(+) =   USERENV('LANG')
AND      FND3.LOOKUP_TYPE (+)= 'AHL_DISP_STATUS'
AND      disp.STATUS_CODE = FND3.LOOKUP_CODE (+)
AND      FND3.LANGUAGE(+) =   USERENV('LANG')
AND      INCL.INCIDENT_ID (+) = INC.INCIDENT_ID
AND      INCL.language(+) = USERENV('LANG');
--
--Fetch all information for the disposition_rec object for path + item
--Must share same path position for empty position
--Also not complete or terminated
CURSOR get_inst_disposition_csr (p_path_position_id IN NUMBER) IS
/*
SELECT disp.disposition_id,
      disp.object_version_number,
      disp.last_update_date,
      disp.last_updated_by,
      disp.creation_date,
      disp.created_by,
      disp.last_update_login,
      disp.workorder_id,
      disp.part_change_id,
      disp.path_position_id,
      disp.item_number,
      disp.inventory_item_id,
      disp.organization_id,
      disp.instance_number,
      disp.instance_id,
      disp.item_group_id,
      disp.item_group_name,
      disp.serial_number,
      disp.lot_number,
      disp.quantity,
      disp.uom,
      disp.condition_id,
      disp.condition_code,
      disp.immediate_disposition_code,
      disp.immediate_type,
      disp.secondary_disposition_code,
      disp.secondary_type,
      disp.status_code,
      disp.status,
      disp.collection_id,
      disp.primary_service_request_id,
      disp.non_routine_workorder_id,
      disp.comments,
      INC.INCIDENT_SEVERITY_ID SEVERITY_ID,
      SEV.NAME SEVERITY_NAME,
      INC.PROBLEM_CODE,
      PCODE.MEANING PROBLEM_MEANING,
      INC.SUMMARY
FROM AHL_PRD_DISPOSITIONS_V disp, AHL_MC_PATH_POSITIONS pp,
     CS_INCIDENTS_ALL_VL INC,
     CS_INCIDENT_SEVERITIES_VL SEV, FND_LOOKUP_VALUES_VL PCODE
  WHERE disp.path_pos_common_id =pp.path_pos_common_id
  AND pp.path_position_id = p_path_position_id
  AND disp.part_change_id IS NULL
  AND disp.workorder_id = p_workorder_id
  AND (disp.status_code IS NULL OR disp.status_code NOT IN ('COMPLETE', 'TERMINATED'))
  AND disp.immediate_disposition_code = 'NOT_RECEIVED'
  AND INC.INCIDENT_ID (+) = disp.primary_service_request_id
  AND SEV.INCIDENT_SEVERITY_ID (+) = INC.INCIDENT_SEVERITY_ID
  AND PCODE.LOOKUP_TYPE (+) = 'REQUEST_PROBLEM_CODE'
  AND PCODE.LOOKUP_CODE (+) = INC.PROBLEM_CODE;
*/
SELECT   disp.disposition_id,
         disp.object_version_number,
         disp.last_update_date,
         disp.last_updated_by,
         disp.creation_date,
         disp.created_by,
         disp.last_update_login,
         disp.workorder_id,
         disp.part_change_id,
         disp.path_position_id,
         MTL.CONCATENATED_SEGMENTS ITEM_NUMBER,
         disp.inventory_item_id,
         disp.organization_id,
         CSI.INSTANCE_NUMBER,
         disp.instance_id,
         disp.item_group_id,
         GRP.NAME ITEM_GROUP_NAME,
         disp.serial_number,
         disp.lot_number,
         disp.quantity,
         disp.uom,
         disp.condition_id,
         cond.STATUS_CODE CONDITION_CODE,
         disp.immediate_disposition_code,
         FND1.MEANING immediate_type,
         disp.secondary_disposition_code,
         FND2.MEANING secondary_type,
         disp.status_code,
         FND3.MEANING status,
         disp.collection_id,
         disp.primary_service_request_id,
         disp.non_routine_workorder_id,
         displ.comments,
         INC.INCIDENT_SEVERITY_ID SEVERITY_ID,
         SEV.NAME SEVERITY_NAME,
         INC.PROBLEM_CODE,
         PCODE.MEANING PROBLEM_MEANING,
         INCL.SUMMARY
FROM     AHL_PRD_DISPOSITIONS_b disp,
         AHL_PRD_DISPOSITIONS_tl displ,
         AHL_MC_PATH_POSITIONS pp,
         CS_INCIDENTS_ALL_B INC,
         CS_INCIDENTS_ALL_TL INCL,
         CS_INCIDENT_SEVERITIES_TL SEV,
         FND_LOOKUP_VALUES PCODE,
         MTL_SYSTEM_ITEMS_KFV MTL,
         CSI_ITEM_INSTANCES CSI,
         AHL_ITEM_GROUPS_B GRP,
         MTL_MATERIAL_STATUSES_TL COND,
         FND_LOOKUP_VALUES FND1,
         FND_LOOKUP_VALUES FND2,
         FND_LOOKUP_VALUES FND3
WHERE    pp.path_pos_common_id IN (
					SELECT PATH_POS_COMMON_ID
					FROM   AHL_MC_PATH_POSITIONS
					WHERE  PATH_POSITION_ID = p_path_position_id
				    )
AND      disp.path_position_id = pp.path_position_id
AND      disp.part_change_id IS NULL
AND      disp.workorder_id = p_workorder_id
AND      (disp.status_code IS NULL OR disp.status_code NOT IN ('COMPLETE', 'TERMINATED'))
AND      disp.immediate_disposition_code = 'NOT_RECEIVED'
AND      INC.INCIDENT_ID (+) = disp.primary_service_request_id
AND      SEV.INCIDENT_SEVERITY_ID (+) = INC.INCIDENT_SEVERITY_ID
AND      PCODE.LOOKUP_TYPE (+) = 'REQUEST_PROBLEM_CODE'
AND      PCODE.LOOKUP_CODE (+) = INC.PROBLEM_CODE
AND      PCODE.LANGUAGE(+) = USERENV('LANG')
AND      disp.disposition_id = displ.disposition_id
AND      displ.LANGUAGE = USERENV('LANG')
AND      disp.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID (+)
AND      disp.ORGANIZATION_ID = MTL.organization_id (+)
AND      disp.INSTANCE_ID = CSI.INSTANCE_ID (+)
AND      disp.ITEM_GROUP_ID = GRP.ITEM_GROUP_ID (+)
AND      disp.condition_id = COND.status_id (+)
AND      COND.LANGUAGE(+) = USERENV('LANG')
AND      FND1.LOOKUP_TYPE (+)= 'AHL_IMMED_DISP_TYPE'
AND      disp.immediate_disposition_code = FND1.LOOKUP_CODE (+)
AND      FND1.LANGUAGE(+) =   USERENV('LANG')
AND      FND2.LOOKUP_TYPE (+)= 'AHL_SECND_DISP_TYPE'
AND      disp.SECONDARY_DISPOSITION_CODE = FND2.LOOKUP_CODE (+)
AND      FND2.LANGUAGE(+) =   USERENV('LANG')
AND      FND3.LOOKUP_TYPE (+)= 'AHL_DISP_STATUS'
AND      disp.STATUS_CODE = FND3.LOOKUP_CODE (+)
AND      FND3.LANGUAGE(+) =   USERENV('LANG')
AND      INCL.INCIDENT_ID (+) = INC.INCIDENT_ID
AND      INCL.LANGUAGE(+) = USERENV('LANG');

--For the disposition whose immediate type is not necessary to be
--Not Received, has Part Change Removal occurred but not installation
--occurred yet. Added by Jerry on 01/06/2005
CURSOR get_inst_disposition_csr1 (p_path_position_id IN NUMBER) IS
-- AnRaj: Changed the query to improve performance,Bug# 4911881 Issue 3
/*
SELECT disp.disposition_id,
      disp.object_version_number,
      disp.last_update_date,
      disp.last_updated_by,
      disp.creation_date,
      disp.created_by,
      disp.last_update_login,
      disp.workorder_id,
      disp.part_change_id,
      disp.path_position_id,
      disp.item_number,
      disp.inventory_item_id,
      disp.organization_id,
      disp.instance_number,
      disp.instance_id,
      disp.item_group_id,
      disp.item_group_name,
      disp.serial_number,
      disp.lot_number,
      disp.quantity,
      disp.uom,
      disp.condition_id,
      disp.condition_code,
      disp.immediate_disposition_code,
      disp.immediate_type,
      disp.secondary_disposition_code,
      disp.secondary_type,
      disp.status_code,
      disp.status,
      disp.collection_id,
      disp.primary_service_request_id,
      disp.non_routine_workorder_id,
      disp.comments,
      INC.INCIDENT_SEVERITY_ID SEVERITY_ID,
      SEV.NAME SEVERITY_NAME,
      INC.PROBLEM_CODE,
      PCODE.MEANING PROBLEM_MEANING,
      INC.SUMMARY
FROM AHL_PRD_DISPOSITIONS_V disp, AHL_MC_PATH_POSITIONS pp,
     CS_INCIDENTS_ALL_VL INC,
     CS_INCIDENT_SEVERITIES_VL SEV, FND_LOOKUP_VALUES_VL PCODE,
     AHL_PART_CHANGES_V PC
  WHERE disp.path_pos_common_id =pp.path_pos_common_id
  AND pp.path_position_id = p_path_position_id
  AND disp.part_change_id IS NOT NULL
  AND disp.workorder_id = p_workorder_id
  AND (disp.status_code IS NULL OR disp.status_code NOT IN ('COMPLETE', 'TERMINATED'))
  AND INC.INCIDENT_ID (+) = disp.primary_service_request_id
  AND SEV.INCIDENT_SEVERITY_ID (+) = INC.INCIDENT_SEVERITY_ID
  AND PCODE.LOOKUP_TYPE (+) = 'REQUEST_PROBLEM_CODE'
  AND PCODE.LOOKUP_CODE (+) = INC.PROBLEM_CODE
  AND disp.part_change_id = PC.part_change_id
  AND PC.removed_instance_id IS NOT NULL
  AND PC.installed_part_change_id IS NULL;
*/
SELECT  disp.disposition_id,
        disp.object_version_number,
        disp.last_update_date,
        disp.last_updated_by,
        disp.creation_date,
        disp.created_by,
        disp.last_update_login,
        disp.workorder_id,
        disp.part_change_id,
        disp.path_position_id,
        MTL.CONCATENATED_SEGMENTS ITEM_NUMBER,
        disp.inventory_item_id,
        disp.organization_id,
        CSI.INSTANCE_NUMBER,
        disp.instance_id,
        disp.item_group_id,
        GRP.NAME ITEM_GROUP_NAME,
        disp.serial_number,
        disp.lot_number,
        disp.quantity,
        disp.uom,
        disp.condition_id,
        COND.STATUS_CODE CONDITION_CODE,
        disp.immediate_disposition_code,
        FND1.MEANING immediate_type,
        disp.secondary_disposition_code,
        FND2.MEANING secondary_type,
        disp.status_code,
        FND3.MEANING status,
        disp.collection_id,
        disp.primary_service_request_id,
        disp.non_routine_workorder_id,
        displ.comments,
        INC.INCIDENT_SEVERITY_ID SEVERITY_ID,
        SEV.NAME SEVERITY_NAME,
        INC.PROBLEM_CODE,
        PCODE.MEANING PROBLEM_MEANING,
        INCL.SUMMARY
FROM    AHL_PRD_DISPOSITIONS_b disp,
        AHL_PRD_DISPOSITIONS_tl displ,
        AHL_MC_PATH_POSITIONS pp,
        FND_LOOKUP_VALUES FND1,
        FND_LOOKUP_VALUES FND2,
        FND_LOOKUP_VALUES FND3,
        MTL_MATERIAL_STATUSES_TL COND,
        AHL_ITEM_GROUPS_B GRP,
        MTL_SYSTEM_ITEMS_KFV MTL,
        CSI_ITEM_INSTANCES CSI,
        CS_INCIDENTS_ALL_B INC,
        CS_INCIDENTS_ALL_TL INCL,
        CS_INCIDENT_SEVERITIES_TL SEV,
        FND_LOOKUP_VALUES PCODE,
        AHL_PART_CHANGES_V PC
WHERE	pp.path_pos_common_id IN (
					SELECT PATH_POS_COMMON_ID
					FROM   AHL_MC_PATH_POSITIONS
					WHERE  PATH_POSITION_ID = p_path_position_id
				    )
AND     disp.path_position_id = pp.path_position_id
AND     disp.disposition_id = displ.disposition_id
AND     displ.language = USERENV('LANG')
AND     disp.part_change_id IS NOT NULL
AND     disp.workorder_id = p_workorder_id
AND     (disp.status_code IS NULL OR disp.status_code NOT IN ('COMPLETE','TERMINATED'))
AND     FND1.LOOKUP_TYPE (+)= 'AHL_IMMED_DISP_TYPE'
AND     disp.immediate_disposition_code = FND1.LOOKUP_CODE (+)
AND     FND1.LANGUAGE(+) =   USERENV('LANG')
AND     FND2.LOOKUP_TYPE (+)= 'AHL_SECND_DISP_TYPE'
AND     disp.SECONDARY_DISPOSITION_CODE = FND2.LOOKUP_CODE (+)
AND     FND2.LANGUAGE(+) =   USERENV('LANG')
AND     FND3.LOOKUP_TYPE (+)= 'AHL_DISP_STATUS'
AND     disp.STATUS_CODE = FND3.LOOKUP_CODE (+)
AND     FND3.LANGUAGE(+) =   USERENV('LANG')
AND     disp.condition_id = COND.status_id (+)
AND     COND.language(+) = USERENV('LANG')
AND     disp.ITEM_GROUP_ID = GRP.ITEM_GROUP_ID (+)
AND     disp.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID (+)
AND     disp.ORGANIZATION_ID = MTL.organization_id (+)
AND     disp.INSTANCE_ID = CSI.INSTANCE_ID (+)
AND     INC.INCIDENT_ID (+) = disp.primary_service_request_id
AND     SEV.INCIDENT_SEVERITY_ID (+) = INC.INCIDENT_SEVERITY_ID
AND     SEV.language(+) = USERENV('LANG')
AND     INCL.INCIDENT_ID (+) = INC.INCIDENT_ID
AND     INCL.language(+) = USERENV('LANG')
AND     PCODE.LOOKUP_TYPE (+) = 'REQUEST_PROBLEM_CODE'
AND     PCODE.LOOKUP_CODE (+) = INC.PROBLEM_CODE
AND     PCODE.language(+) = USERENV('LANG')
AND     disp.part_change_id = PC.part_change_id
AND     PC.removed_instance_id IS NOT NULL
AND     PC.installed_part_change_id IS NULL;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
-- Cursor to get all the non-complete and non-terminated dispositions matching the workorder_id and instance_id.
-- Used for supporting IB trees and hierarchies.
-- NOTE: If need be, then the cursor query can be tuned for better performance on the same lines as the other cursors above.
CURSOR get_instance_disposition_csr (p_workorder_id IN NUMBER,
                                     p_instance_id  IN NUMBER) IS
SELECT disp.disposition_id,
       disp.object_version_number,
       disp.last_update_date,
       disp.last_updated_by,
       disp.creation_date,
       disp.created_by,
       disp.last_update_login,
       disp.workorder_id,
       disp.part_change_id,
       disp.path_position_id,
       disp.item_number,
       disp.inventory_item_id,
       disp.organization_id,
       disp.instance_number,
       disp.instance_id,
       disp.item_group_id,
       disp.item_group_name,
       disp.serial_number,
       disp.lot_number,
       disp.quantity,
       disp.uom,
       disp.condition_id,
       disp.condition_code,
       disp.immediate_disposition_code,
       disp.immediate_type,
       disp.secondary_disposition_code,
       disp.secondary_type,
       disp.status_code,
       disp.status,
       disp.collection_id,
       disp.primary_service_request_id,
       disp.non_routine_workorder_id,
       disp.comments,
       INC.INCIDENT_SEVERITY_ID SEVERITY_ID,
       SEV.NAME SEVERITY_NAME,
       INC.PROBLEM_CODE,
       PCODE.MEANING PROBLEM_MEANING,
       INC.SUMMARY
FROM AHL_PRD_DISPOSITIONS_V disp, CS_INCIDENTS_ALL_VL INC,
     CS_INCIDENT_SEVERITIES_VL SEV, FND_LOOKUP_VALUES_VL PCODE
WHERE disp.workorder_id = p_workorder_id
AND disp.instance_id = p_instance_id
AND (disp.status_code NOT IN ('COMPLETE', 'TERMINATED'))
AND disp.part_change_id IS  NULL
AND disp.path_position_id IS  NULL
AND INC.INCIDENT_ID (+) = disp.primary_service_request_id
AND SEV.INCIDENT_SEVERITY_ID (+) = INC.INCIDENT_SEVERITY_ID
AND PCODE.LOOKUP_TYPE (+) = 'REQUEST_PROBLEM_CODE'
AND PCODE.LOOKUP_CODE (+) = INC.PROBLEM_CODE;

--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Part_Change_Disposition';
l_path_position_ID   NUMBER;
l_csi_instance_id  NUMBER;
l_disp_rec       get_rem_disposition_csr%ROWTYPE;
l_found_flag     boolean;

l_temp_disp_rec    get_rem_disposition_csr%ROWTYPE;

--
BEGIN
   -- Standard start of API savepoint
    SAVEPOINT Get_Part_Change_Disp_Pvt;

    -- Initialize Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     G_LOG_PREFIX||l_api_name||': Begin API',
                     'Entering the Procedure.');
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     G_LOG_PREFIX||l_api_name,
                     'About to call AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID with ' ||
                     'p_csi_item_instance_id = ' || p_parent_instance_id ||
                     ', p_relationship_id = ' || p_relationship_id);
     END IF;

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
    -- Check for p_relationship_id.
    IF (p_relationship_id IS NULL) THEN
        OPEN get_instance_disposition_csr (p_workorder_id, p_instance_id);
        FETCH get_instance_disposition_csr into l_disp_rec;

        IF (get_instance_disposition_csr%FOUND) THEN
            l_found_flag := true;
            FETCH get_instance_disposition_csr into l_temp_disp_rec;
            -- If more than one matching disposition: Pass -1 so that Part Change can handle this appropriately.
            IF (get_instance_disposition_csr%FOUND) THEN
               x_disposition_rec.disposition_id := -1;
            END IF;
        ELSE
            l_found_flag := false;
        END IF;
        CLOSE get_instance_disposition_csr;
    ELSE

     -- find the path_position_id for the position
     AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID (
          p_api_version => 1.0,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_csi_item_instance_id => p_parent_instance_id,
          p_relationship_id  => p_relationship_id,
          x_path_position_id  => l_path_position_id);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     G_LOG_PREFIX||l_api_name,
                     'Returned from call to AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID.' ||
                     ' x_path_position_id = ' || l_path_position_id);
    END IF;
    l_found_flag := false;
    --dbms_output.put_line ('POS ID'||l_path_position_id);
    --Check whether the position is installed or not
    OPEN check_installed_csr (p_parent_instance_id, p_relationship_id);
    FETCH check_installed_csr into l_csi_instance_id;
    --If installed
    IF (check_installed_csr%FOUND) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       G_LOG_PREFIX||l_api_name,
                      'Instance is installed. Getting disposition for ' ||
                      ' l_path_position_id = ' || l_path_position_id ||
                      ' and l_csi_instance_id = ' || l_csi_instance_id);
      END IF;
      --Fetch the disposition for Part Removal
      OPEN get_rem_disposition_csr (l_path_position_id, l_csi_instance_id);
      FETCH get_rem_disposition_csr INTO l_disp_rec;
      --Check if matching disposition is found..
      IF (get_rem_disposition_csr%FOUND) THEN
       l_found_flag := true;

       -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
       FETCH get_rem_disposition_csr INTO l_temp_disp_rec;
       -- If more than one matching disposition: Pass -1 so that Part Change can handle this appropriately.
       IF (get_rem_disposition_csr%FOUND) THEN
         x_disposition_rec.disposition_id := -1;
       END IF;
      END IF;
      CLOSE get_rem_disposition_csr;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       G_LOG_PREFIX||l_api_name,
                      'Instance is NOT installed. Getting disposition for ' ||
                      'l_path_position_id = ' || l_path_position_id);
      END IF;
      OPEN get_inst_disposition_csr (l_path_position_id);
      FETCH get_inst_disposition_csr INTO l_disp_rec;
      --Check if matching disposition is found..
      IF (get_inst_disposition_csr%FOUND) THEN
        l_found_flag := true;
      ELSE
        OPEN get_inst_disposition_csr1 (l_path_position_id);
        FETCH get_inst_disposition_csr1 INTO l_disp_rec;
        IF (get_inst_disposition_csr1%FOUND) THEN
          l_found_flag := true;
        END IF;
        CLOSE get_inst_disposition_csr1;
      END IF;
      CLOSE get_inst_disposition_csr;
    END IF;
    CLOSE check_installed_csr;
    END IF; -- (p_relationship_id IS NULL)

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 17-Dec-2007
    -- Check for the disposition id not being set as -1 in the above checks.
    IF (l_found_flag = true AND (NVL(x_disposition_rec.disposition_id,0) <> -1)) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         G_LOG_PREFIX||l_api_name,
                        'Found matching Disposition. l_disp_rec.disposition_id = ' || l_disp_rec.disposition_id);
        END IF;
        x_disposition_rec.disposition_id := l_disp_rec.disposition_id;
        --x_disposition_rec.object_version_number:=x_disposition_rec.object_version_number;
        x_disposition_rec.object_version_number:= l_disp_rec.object_version_number;
        --x_disposition_rec.LAST_UPDATE_DATE := x_disposition_rec.LAST_UPDATE_DATE;
        x_disposition_rec.LAST_UPDATE_DATE := l_disp_rec.LAST_UPDATE_DATE;
        x_disposition_rec.LAST_UPDATED_BY :=l_disp_rec.LAST_UPDATED_BY;
        x_disposition_rec.CREATION_DATE:=l_disp_rec.CREATION_DATE;
        x_disposition_rec.CREATED_BY:=l_disp_rec.CREATED_BY;
        x_disposition_rec.LAST_UPDATE_LOGIN:=l_disp_rec.LAST_UPDATE_LOGIN;
        x_disposition_rec.WORKORDER_ID:=l_disp_rec.WORKORDER_ID;
        x_disposition_rec.PART_CHANGE_ID:=l_disp_rec.PART_CHANGE_ID;
        x_disposition_rec.PATH_POSITION_ID:=l_disp_rec.PATH_POSITION_ID;
        x_disposition_rec.INVENTORY_ITEM_ID:=l_disp_rec.INVENTORY_ITEM_ID;
        x_disposition_rec.ITEM_ORG_ID:=l_disp_rec.ORGANIZATION_ID;
        x_disposition_rec.ITEM_GROUP_ID:=l_disp_rec.ITEM_GROUP_ID;
        x_disposition_rec.CONDITION_ID:=l_disp_rec.CONDITION_ID;
        x_disposition_rec.INSTANCE_ID:=l_disp_rec.INSTANCE_ID;
        x_disposition_rec.COLLECTION_ID:=l_disp_rec.COLLECTION_ID;
        x_disposition_rec.PRIMARY_SERVICE_REQUEST_ID:=l_disp_rec.PRIMARY_SERVICE_REQUEST_ID;
        x_disposition_rec.NON_ROUTINE_WORKORDER_ID:=l_disp_rec.NON_ROUTINE_WORKORDER_ID;
        x_disposition_rec.SERIAL_NUMBER:=l_disp_rec.SERIAL_NUMBER;
        x_disposition_rec.LOT_NUMBER:=l_disp_rec.LOT_NUMBER;
        x_disposition_rec.IMMEDIATE_DISPOSITION_CODE:=l_disp_rec.IMMEDIATE_DISPOSITION_CODE;
        x_disposition_rec.SECONDARY_DISPOSITION_CODE:=l_disp_rec.SECONDARY_DISPOSITION_CODE;
        x_disposition_rec.STATUS_CODE:=l_disp_rec.STATUS_CODE;
        x_disposition_rec.QUANTITY:=l_disp_rec.QUANTITY;
        x_disposition_rec.UOM:=l_disp_rec.UOM;
        x_disposition_rec.COMMENTS:= l_disp_rec.comments;
        x_disposition_rec.SEVERITY_ID:=l_disp_rec.SEVERITY_ID;
        x_disposition_rec.PROBLEM_CODE:=l_disp_rec.PROBLEM_CODE;
        x_disposition_rec.SUMMARY:=l_disp_rec.SUMMARY;
        x_disposition_rec.IMMEDIATE_DISPOSITION:=l_disp_rec.IMMEDIATE_TYPE;
        x_disposition_rec.SECONDARY_DISPOSITION:=l_disp_rec.SECONDARY_TYPE;
        x_disposition_rec.CONDITION_MEANING:=l_disp_rec.CONDITION_CODE;
        x_disposition_rec.INSTANCE_NUMBER:=l_disp_rec.INSTANCE_NUMBER;
        x_disposition_rec.ITEM_NUMBER:=l_disp_rec.ITEM_NUMBER;
        x_disposition_rec.ITEM_GROUP_NAME:=l_disp_rec.ITEM_GROUP_NAME;
        x_disposition_rec.DISPOSITION_STATUS:=l_disp_rec.STATUS;
        x_disposition_rec.SEVERITY_NAME:=l_disp_rec.SEVERITY_NAME;
        x_disposition_rec.PROBLEM_MEANING:=l_disp_rec.PROBLEM_MEANING;

        Ahl_prd_disp_util_pvt.Get_Available_Disp_Types (
    		p_api_version       => 1.0,
		    p_commit            => FND_API.G_FALSE,
  	    	x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_disposition_id       =>   x_disposition_rec.disposition_id,
    		x_imm_disp_type_tbl    => x_imm_disp_type_tbl,
            x_sec_disp_type_tbl    => x_sec_disp_type_tbl);
     ELSE
         --No matching disposition, must create new.
         --x_disposition_rec is null
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            G_LOG_PREFIX||l_api_name,
                            'Could not find any matching Disposition.');
         END IF;
         Ahl_prd_disp_util_pvt.Get_Available_Disp_Types (
    		p_api_version       => 1.0,
		    p_commit            => FND_API.G_FALSE,
  	    	x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_disposition_id       => null,
    		x_imm_disp_type_tbl    => x_imm_disp_type_tbl,
            x_sec_disp_type_tbl    => x_sec_disp_type_tbl);
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Get_Part_Change_Disp_Pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Get_Part_Change_Disp_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Get_Part_Change_Disp_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Get_Part_Change_Disposition;



------------------------
-- Start of Comments --
--  Procedure name    : Get_Available_Disp_Types
--  Type        : Private
--  Function    : Fetch the available disposition types for given disposition
--  Pre-reqs    :
--  Parameters  : p_disposition_id: The disposition id to fetch against
--                x_imm_disp_type_tbl: returning immediate disposition type
--                x_sec_disp_type_tbl: returning secondary dispositions
--
--
--  End of Comments.

PROCEDURE Get_Available_Disp_Types (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_disposition_id        IN NUMBER,
    x_imm_disp_type_tbl    OUT NOCOPY Disp_Type_Tbl_Type,
    x_sec_disp_type_tbl    OUT NOCOPY Disp_Type_Tbl_Type)
IS
--
--AnRaj: Changed for Performance Bug#4911881
CURSOR get_disp_rec_csr (p_disp_id IN NUMBER) IS
/* SELECT *
   FROM AHL_PRD_DISPOSITIONS_V
   WHERE disposition_id = p_disp_id;
*/
   SELECT   B.status_code,
            B.immediate_disposition_code,
            FND1.MEANING IMMEDIATE_TYPE,
            B.secondary_disposition_code,
            FND2.MEANING SECONDARY_TYPE,
            B.part_change_id,
            decode(B.instance_id, null, decode(B.path_position_id, null, 'N', 'Y'), 'Y') TRACKABLE_FLAG
   FROM     AHL_PRD_DISPOSITIONS_B B, FND_LOOKUPS FND1, FND_LOOKUPS FND2
   WHERE    FND1.LOOKUP_TYPE (+) = 'AHL_IMMED_DISP_TYPE'
   AND      B.immediate_disposition_code = FND1.LOOKUP_CODE (+)
   AND      FND2.LOOKUP_TYPE (+) = 'AHL_SECND_DISP_TYPE'
   AND      B.SECONDARY_DISPOSITION_CODE = FND2.LOOKUP_CODE (+)
   AND      B.disposition_id = p_disp_id;
--
CURSOR get_immed_disp_types_csr IS
SELECT lookup_code, meaning
FROM fnd_lookups
WHERE  lookup_type = 'AHL_IMMED_DISP_TYPE'
AND Lookup_code <> 'NULL';
--
CURSOR get_second_disp_types_csr IS
SELECT lookup_code, meaning
FROM fnd_lookups
WHERE  lookup_type = 'AHL_SECND_DISP_TYPE'
AND Lookup_code <> 'NULL';

--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Avail_Disp_Type';
l_disp_rec         get_disp_rec_csr%ROWTYPE;
l_type_rec       AHL_PRD_DISP_UTIL_PVT.Disp_Type_Rec_Type;
i               NUMBER;
--
BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
     FND_MSG_PUB.initialize;
  END IF;

  i:=0;
   --Fetch the current disposition types or ids
   OPEN  get_disp_rec_csr (p_disposition_id);
   FETCH get_disp_rec_csr INTO l_disp_rec;

   --dbms_output.put_line('status => ' ||l_disp_rec.status_code);
   --dbms_output.put_line('imm_type => ' ||l_disp_rec.immediate_disposition_code);
   --dbms_output.put_line('secondary_type => ' ||l_disp_rec.secondary_disposition_code);

   IF (get_disp_rec_csr%FOUND) THEN
    --For No change in immed. or secondary type
    IF (l_disp_rec.status_code = 'TERMINATED' OR
        --l_disp_rec.immediate_disposition_code ='NOT_RECEIVED' OR
        --Jerry commented out the above line on 01/17/2005 for fixing bug 4094927
        l_disp_rec.immediate_disposition_code ='SCRAP' OR
       (l_disp_rec.status_code ='COMPLETE' AND            --Complete but not NR,NA
        l_disp_rec.immediate_disposition_code NOT IN ('NOT_REMOVED','NA'))) THEN

        IF (l_disp_rec.immediate_disposition_code IS NOT NULL and
            l_disp_rec.immediate_type IS NOT NULL) THEN
         l_type_rec.code := l_disp_rec.immediate_disposition_code;
         l_type_rec.meaning :=  l_disp_rec.immediate_type;
         x_imm_disp_type_tbl(0):= l_type_rec;
        END IF;

        IF (l_disp_rec.secondary_disposition_code IS NOT NULL and
           l_disp_rec.secondary_type IS NOT NULL) THEN
          l_type_rec.code := l_disp_rec.secondary_disposition_code;
          l_type_rec.meaning :=  l_disp_rec.secondary_type;
          x_sec_disp_type_tbl(0):= l_type_rec;
        END IF;

    --immediate is fixed.
    ELSIF(l_disp_rec.immediate_disposition_code IN ('NON_CONF','BFS')) THEN

       -- Immediate disposition is fixed.
     IF (l_disp_rec.immediate_disposition_code IS NOT NULL and
            l_disp_rec.immediate_type IS NOT NULL) THEN
       l_type_rec.code := l_disp_rec.immediate_disposition_code;
       l_type_rec.meaning :=  l_disp_rec.immediate_type;
       x_imm_disp_type_tbl(0):= l_type_rec;
     END IF;

     --For SCRAP, restrict secondary disposition
     IF (l_disp_rec.secondary_disposition_code = 'SCRAP' ) THEN
        IF (l_disp_rec.secondary_disposition_code IS NOT NULL and
           l_disp_rec.secondary_type IS NOT NULL) THEN
          l_type_rec.code := l_disp_rec.secondary_disposition_code;
          l_type_rec.meaning :=  l_disp_rec.secondary_type;
          x_sec_disp_type_tbl(0):= l_type_rec;
        END IF;

     ELSE
         i:=0;
         OPEN get_second_disp_types_csr;
         LOOP
            FETCH get_second_disp_types_csr INTO l_type_rec.CODE, l_type_rec.meaning;
            EXIT WHEN get_second_disp_types_csr%NOTFOUND;
            --All others are valid.
            --For Rework-NR, it's either not trackable or not removed
            --IF (l_type_rec.CODE <> 'REWORK_NR' OR
            --     (l_type_rec.CODE = 'REWORK_NR' AND
            --      (l_disp_rec.trackable_flag <> 'Y' OR
            --       l_disp_rec.part_change_id IS NULL))) THEN
            -- Jerry update the condition on 02/17/2005 for fixing bug 4189553
            IF ((l_type_rec.code <> 'REWORK_NR' AND l_type_rec.code <> 'REWORK_RR') OR
                (l_type_rec.code = 'REWORK_NR' AND l_disp_rec.trackable_flag = 'Y'
                                             AND l_disp_rec.part_change_id IS NULL) OR
                (l_type_rec.code = 'REWORK_RR' AND l_disp_rec.trackable_flag = 'Y')) THEN
              x_sec_disp_type_tbl(i) := l_type_rec;
              i:=i+1;
            END IF;
         END LOOP;
         CLOSE get_second_disp_types_csr;
     END IF;

    ELSIF(l_disp_rec.immediate_disposition_code IN ('USE_AS_IS','RTV','RTC')) THEN

     i:=0;
     --Return all immediate except NRemoved,NA,NReceived
     OPEN get_immed_disp_types_csr;
     LOOP
      FETCH get_immed_disp_types_csr INTO l_type_rec.CODE, l_type_rec.meaning;
      EXIT WHEN get_immed_disp_types_csr%NOTFOUND;
       IF (l_type_rec.code NOT IN ('NOT_RECEIVED','NA','NOT_REMOVED')) THEN
         x_imm_disp_type_tbl(i) := l_type_rec;
         i:=i+1;
       END IF;
     END LOOP;
     CLOSE get_immed_disp_types_csr;

     i:=0;
    OPEN get_second_disp_types_csr;
    LOOP
       FETCH get_second_disp_types_csr INTO l_type_rec.CODE, l_type_rec.meaning;
       EXIT WHEN get_second_disp_types_csr%NOTFOUND;
              x_sec_disp_type_tbl(i) := l_type_rec;
              i:=i+1;
       END LOOP;
    CLOSE get_second_disp_types_csr;

    ELSIF(l_disp_rec.immediate_disposition_code IN ('NOT_REMOVED', 'NA')) THEN

     i:=0;
     --Return all immediate except Not Received
     OPEN get_immed_disp_types_csr;
     LOOP
      FETCH get_immed_disp_types_csr INTO l_type_rec.CODE, l_type_rec.meaning;
      EXIT WHEN get_immed_disp_types_csr%NOTFOUND;
       IF (l_type_rec.code NOT IN ('NOT_RECEIVED')) THEN
         x_imm_disp_type_tbl(i) := l_type_rec;
         i:=i+1;
       END IF;
     END LOOP;
     CLOSE get_immed_disp_types_csr;
   ELSE
     --Return every disposition type case
     i:=0;
     OPEN get_immed_disp_types_csr;
     LOOP
      FETCH get_immed_disp_types_csr INTO l_type_rec.CODE, l_type_rec.meaning;
      EXIT WHEN get_immed_disp_types_csr%NOTFOUND;
        x_imm_disp_type_tbl(i) := l_type_rec;
        i:=i+1;
     END LOOP;
     CLOSE get_immed_disp_types_csr;

     --Fetch the secondary disposition types
     i:=0;
     OPEN get_second_disp_types_csr;
     LOOP
      FETCH get_second_disp_types_csr INTO l_type_rec.CODE, l_type_rec.meaning;
      EXIT WHEN get_second_disp_types_csr%NOTFOUND;
        x_sec_disp_type_tbl(i) := l_type_rec;
        i:=i+1;
     END LOOP;
     CLOSE get_second_disp_types_csr;
   END IF;
  ELSE
     --Return every disposition type case when disp view is not found
     i:=0;
     OPEN get_immed_disp_types_csr;
     LOOP
      FETCH get_immed_disp_types_csr INTO l_type_rec.CODE, l_type_rec.meaning;
      EXIT WHEN get_immed_disp_types_csr%NOTFOUND;
        x_imm_disp_type_tbl(i) := l_type_rec;
        i:=i+1;
     END LOOP;
     CLOSE get_immed_disp_types_csr;

     --Fetch the secondary disposition types
     i:=0;
     OPEN get_second_disp_types_csr;
     LOOP
      FETCH get_second_disp_types_csr INTO l_type_rec.CODE, l_type_rec.meaning;
      EXIT WHEN get_second_disp_types_csr%NOTFOUND;
        x_sec_disp_type_tbl(i) := l_type_rec;
        i:=i+1;
     END LOOP;
     CLOSE get_second_disp_types_csr;
  END IF;
  CLOSE get_disp_rec_csr;

EXCEPTION
 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Get_Available_Disp_Types;


-- Function to determine if the incident specified is the
-- primary Non Conformance for the disposition specified.
-- If it is the primary NC, 'Y' is returned.
-- If not, 'N' is returned.
-- 'N' is returned in case of any invalid inputs also.
FUNCTION Get_Primary_SR_Flag(p_disposition_id IN NUMBER,
                             p_incident_id    IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR get_primary_sr_csr IS
    SELECT PRIMARY_SERVICE_REQUEST_ID
    FROM AHL_PRD_DISPOSITIONS_B
    WHERE DISPOSITION_ID = p_disposition_id;

  l_primary_sr_id        NUMBER;
  l_return_value         VARCHAR2(1);

  L_DEBUG_KEY            CONSTANT VARCHAR2(150) :=
'ahl.plsql.AHL_PRD_DISPOSITIONS_UTIL.Get_Primary_SR_Flag';

BEGIN
  OPEN get_primary_sr_csr;
  FETCH get_primary_sr_csr INTO l_primary_sr_id;
  IF(get_primary_sr_csr%NOTFOUND) THEN
    l_return_value := 'N';
  ELSIF (l_primary_sr_id = p_incident_id) THEN
    l_return_value := 'Y';
  ELSE
    l_return_value := 'N';
  END IF;
  CLOSE get_primary_sr_csr;

  RETURN l_return_value;
END Get_Primary_SR_Flag;

-- Start of Comments --
--  Procedure name    : Create_Disp_Mtl_Requirement
--  Type              : Private
--  Function          : Private API to create a Material requirements for a Disposition.
--                      If the disposition has neither an item nor a Position Path, an
--                      exception is raised. If the disposition is for a position that is
--                      empty, this API gets the item group for the position and picks one
--                      item from the item group and creates a material requirement for that item.
--                      If the requirement was created successfully, a message is returned
--                      via x_msg_data indicating the item, the quantity and the UOM of the
--                      requirement created.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Create_Disp_Mtl_Requirement Parameters:
--      p_disposition_id                IN      NUMBER       Required
--         The Id of disposition for which to create the material requirement.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.


PROCEDURE Create_Disp_Mtl_Requirement (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2,
    p_disposition_id      IN           NUMBER
) IS

--Begin Performance Tuning fix
CURSOR get_disp_dtls_csr(p_disp_id IN NUMBER) IS
/*
SELECT disp.inventory_item_id, disp.item_number, disp.workorder_id,
vi.organization_id, disp.path_position_id, disp.quantity, disp.uom,
disp.wo_operation_id
FROM AHL_PRD_DISPOSITIONS_V disp, AHL_WORKORDERS wo, AHL_VISITS_B VI
--the organization_id in ahl_prd_dispostions_b is not necessary to be the same as the job org,
--especially when the disposition is for a non empty position(instance''s last_vld_org_id), but
--here we need the job organization.
WHERE disp.workorder_id = wo.workorder_id
   and wo.visit_id = vi.visit_id
   AND disp.disposition_id = p_disp_id
   */
select   disp.inventory_item_id,
         mtl.concatenated_segments item_number,
         disp.workorder_id,
         vi.organization_id,
         disp.path_position_id,
         disp.quantity,
         disp.uom,
         disp.wo_operation_id
from     ahl_prd_dispositions_vl disp,
         mtl_system_items_kfv mtl,
         ahl_workorders wo,
         ahl_visits_b vi
where    disp.workorder_id = wo.workorder_id
and      wo.visit_id = vi.visit_id
and      disp.disposition_id = p_disp_id
AND      disp.inventory_item_id = mtl.inventory_item_id(+)
AND      disp.organization_id = mtl.organization_id (+);

/*
SELECT disp.inventory_item_id, disp.item_number, disp.workorder_id,
wo.organization_id, disp.path_position_id, disp.quantity, disp.uom,
disp.wo_operation_id
FROM AHL_PRD_DISPOSITIONS_V disp, AHL_WORKORDERS_V wo
--the organization_id in ahl_prd_dispostions_b is not necessary to be the same as the job org,
--especially when the disposition is for a non empty position(instance's last_vld_org_id), but
--here we need the job organization.
WHERE disp.workorder_id = wo.workorder_id
AND disposition_id = p_disp_id;*/
--End Performance Tuning fix


CURSOR get_relnship_id_csr (p_path_position_id IN NUMBER) IS
SELECT rel.relationship_id
FROM AHL_MC_RELATIONSHIPS rel, AHL_MC_HEADERS_B mc, AHL_MC_PATH_POSITION_NODES node
WHERE rel.mc_header_id = mc.mc_header_id
AND node.position_key = rel.position_key
AND node.mc_id = mc.mc_id
AND nvl(node.version_number, mc.version_number) = mc.version_number
AND node.path_position_id = p_path_position_id
AND node.sequence = (select max(sequence)
            from AHL_MC_PATH_POSITION_NODES
            WHERE path_position_id = p_path_position_id)
ORDER by mc.version_number desc;

--
--Based on the position, fetch the highest priority item from item group.
CURSOR get_empty_pos_item_csr(p_relationship_id IN NUMBER,
                              p_org_id   IN NUMBER ) IS
SELECT ia.inventory_item_id, mtl.concatenated_segments, ia.quantity, ia.uom_code
FROM AHL_ITEM_ASSOCIATIONS_B ia, MTL_SYSTEM_ITEMS_KFV mtl,
 AHL_MC_RELATIONSHIPS rel, MTL_PARAMETERS morgs
WHERE ia.inventory_item_id = mtl.inventory_item_id
AND mtl.organization_id = p_org_id                --Make sure item is defined for p_org_id
AND ia.inventory_org_id = morgs.master_organization_id
AND morgs.organization_id = p_org_id
AND ia.item_group_id = rel.item_group_id
AND rel.relationship_id = p_relationship_id
AND ia.interchange_type_code in ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
ORDER by ia.priority asc;

--
-- look into sub-unit top nodes for best matched item.
CURSOR get_pos_subut_item_csr(p_relationship_id IN NUMBER,
                              p_org_id   IN NUMBER ) IS
SELECT ia.inventory_item_id, mtl.concatenated_segments, ia.quantity, ia.uom_code
FROM AHL_ITEM_ASSOCIATIONS_B ia, MTL_SYSTEM_ITEMS_KFV mtl,
 AHL_MC_RELATIONSHIPS rel, AHL_MC_CONFIG_RELATIONS crel, MTL_PARAMETERS morgs
WHERE ia.inventory_item_id = mtl.inventory_item_id
AND mtl.organization_id = p_org_id                --Make sure item is defined for p_org_id
AND ia.inventory_org_id = morgs.master_organization_id
AND morgs.organization_id = p_org_id
AND ia.item_group_id = rel.item_group_id
AND rel.mc_header_id = crel.mc_header_id
AND rel.parent_relationship_id IS NULL
AND crel.relationship_id = p_relationship_id
AND ia.interchange_type_code in ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
ORDER by crel.priority asc, ia.priority asc;

--Fetch the 1st open workorder operation (not complete) for workorder
CURSOR get_workorder_oper_csr (p_workorder_id IN NUMBER) IS
SELECT workorder_operation_id
FROM AHL_WORKORDER_OPERATIONS
WHERE workorder_id = p_workorder_id
AND status_code <> G_WO_STATUS_COMPLETE
ORDER BY operation_sequence_num asc;

--
--Check whether the material requirement for the same item has already existed
CURSOR check_mtl_requirement(c_item_id NUMBER, c_org_id NUMBER,
                             c_operation_id NUMBER) IS
SELECT scheduled_material_id,
       object_version_number,
       requested_quantity,
       uom,
       inventory_item_id
  FROM AHL_SCHEDULE_MATERIALS
 WHERE inventory_item_id = c_item_id
   AND workorder_operation_id = c_operation_id
   AND organization_id = c_org_id
   AND requested_quantity <> 0
   AND status = 'ACTIVE';
l_mtl_requirement  check_mtl_requirement%ROWTYPE;

l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Create_Disp_Mtl_Requirement';
l_req_material_rec  AHL_PP_Materials_PVT.req_material_rec_type;
l_req_material_tbl  AHL_PP_Materials_PVT.req_material_tbl_type;
l_req_material_u_rec  AHL_PP_Materials_PVT.req_material_rec_type;
l_req_material_u_tbl  AHL_PP_Materials_PVT.req_material_tbl_type;
l_disp_rec        get_disp_dtls_csr%ROWTYPE;
l_item_number    MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;
l_relationship_id   NUMBER;
l_job_return_status VARCHAR2(1);
l_delta_quantity    NUMBER;
-- Added on 1/8/05 by JR to fix Bug 4097327
-- To give a different confirmation message for update
l_update_flag       BOOLEAN := false;


--
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Create_Disp_Mtl_Req_Pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
     FND_MSG_PUB.initialize;
  END IF;

  --Fetch the disposition for Part Removal
  OPEN get_disp_dtls_csr (p_disposition_id);
  FETCH get_disp_dtls_csr INTO l_disp_rec;
  --Check if matching disposition is found..
  IF (get_disp_dtls_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_ID_INVALID');
       FND_MESSAGE.Set_Token('DISPOSITION_ID', p_disposition_id);
       FND_MSG_PUB.ADD;
       CLOSE get_disp_dtls_csr;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_disp_dtls_csr;

  --Throw an error if both item and position are null
  IF (l_disp_rec.inventory_item_id IS NULL AND
      l_disp_rec.path_position_id IS NULL) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_ITEM_POS_NULL');
       FND_MSG_PUB.ADD;
       RAISE  FND_API.G_EXC_ERROR;
  ELSIF (l_disp_rec.inventory_item_id IS NULL AND
         l_disp_rec.path_position_id IS NOT NULL) THEN
     --get the position relationship id (Use the 1st one)
     OPEN get_relnship_id_csr (l_disp_rec.path_position_id);
     FETCH get_relnship_id_csr INTO l_relationship_id;
     CLOSE get_relnship_id_csr;

     l_req_material_rec.organization_id := l_disp_rec.organization_id;

     --Now fetch the item informations from item group of the position.
     OPEN get_empty_pos_item_csr (l_relationship_id, l_disp_rec.organization_id);
     FETCH get_empty_pos_item_csr INTO l_req_material_rec.inventory_item_id,
                                    l_item_number,
                                    l_disp_rec.quantity,
                                    l_disp_rec.uom;

     --If no item group at position, check the subconfig associations.
     IF (get_empty_pos_item_csr%NOTFOUND) THEN
       OPEN get_pos_subut_item_csr (l_relationship_id, l_disp_rec.organization_id);
       FETCH get_pos_subut_item_csr INTO l_req_material_rec.inventory_item_id,
                                    l_item_number,
                                    l_disp_rec.quantity,
                                    l_disp_rec.uom;
        IF (get_pos_subut_item_csr%NOTFOUND) THEN
         	CLOSE get_pos_subut_item_csr;
         	CLOSE get_empty_pos_item_csr;

         	--Raise the exception because for workorder org, no matching item found.
         	--Can not create Mtl Req because there is no inventory item
			FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_ITEM_ORG_INV');
       		FND_MSG_PUB.ADD;
       		RAISE  FND_API.G_EXC_ERROR;
       END IF;
       CLOSE get_pos_subut_item_csr;
     END IF;
     CLOSE get_empty_pos_item_csr;

  ELSE
      l_req_material_rec.inventory_item_id := l_disp_rec.inventory_item_id;
      l_req_material_rec.organization_id := l_disp_rec.organization_id;
      l_item_number := l_disp_rec.item_number;
  END IF;


  --Convert to primary UOM
  l_req_material_rec.requested_quantity :=
                AHL_LTP_MTL_REQ_PVT.get_primary_uom_qty(l_req_material_rec.inventory_item_id,
                        l_disp_rec.uom,l_disp_rec.quantity);

  l_req_material_rec.UOM_CODE :=
                AHL_LTP_MTL_REQ_PVT.get_primary_uom(l_req_material_rec.inventory_item_id,
                                            l_disp_rec.organization_id);

  --The default requested date is sysdate
  l_req_material_rec.requested_date := TRUNC(sysdate);

  l_req_material_rec.workorder_id := l_disp_rec.workorder_id;

  -- Get the workorder operation id and decide if one or the other
  IF (l_disp_rec.wo_operation_id IS NOT NULL) THEN
    l_req_material_rec.workorder_operation_id := l_disp_rec.wo_operation_id;
  ELSE
    --If null, fetch the 1st open workorder operation for given workorder
    OPEN get_workorder_oper_csr (l_disp_rec.workorder_id);
    FETCH get_workorder_oper_csr INTO l_req_material_rec.workorder_operation_id;
    CLOSE get_workorder_oper_csr;
  END IF;


  l_req_material_tbl(0) := l_req_material_rec;

  OPEN check_mtl_requirement(l_req_material_rec.inventory_item_id,
                             l_req_material_rec.organization_id,
                             l_req_material_rec.workorder_operation_id);
  FETCH check_mtl_requirement INTO l_mtl_requirement;
  IF check_mtl_requirement%FOUND THEN
    close check_mtl_requirement;
    l_req_material_u_rec.schedule_material_id := l_mtl_requirement.scheduled_material_id;
    l_req_material_u_rec.object_version_number := l_mtl_requirement.object_version_number;
    l_delta_quantity := inv_convert.inv_um_convert(item_id => l_mtl_requirement.inventory_item_id,
                               precision => 6,
                               from_quantity => l_disp_rec.quantity,
                               from_unit => l_disp_rec.uom,
                               to_unit => l_mtl_requirement.uom,
                               from_name => null,
                               to_name => null);
    l_req_material_u_rec.requested_quantity := l_mtl_requirement.requested_quantity + l_delta_quantity;
    l_req_material_u_rec.OPERATION_FLAG := 'U';
    l_req_material_u_tbl(1) := l_req_material_u_rec;

    IF (FND_LOG.LEVEL_EVENT>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                     G_LOG_PREFIX||l_api_name||': Within the API',
                     'Just before calling API: Ahl_PP_Materials_PVT.Process_Material_Request');
    END IF;
    Ahl_PP_Materials_PVT.Process_Material_Request (
      p_api_version         => 1.0,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => p_validation_level,
      p_module_type         => 'API',
      p_x_req_material_tbl  => l_req_material_u_tbl,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data);
    -- Added on 1/8/05 by JR to fix Bug 4097327
    -- To give a different confirmation message for update
    l_update_flag := true;

  ELSE
    close check_mtl_requirement;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     G_LOG_PREFIX||l_api_name||': Within the API',
                     'Just before calling API: Ahl_PP_Materials_PVT.Create_Material_Reqst');
    END IF;
    Ahl_PP_Materials_PVT.Create_Material_Reqst (
      p_api_version         => 1.0,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => p_validation_level,
      p_interface_flag      => 'Y',  --push to WIP
      p_x_req_material_tbl  => l_req_material_tbl,
      x_job_return_status   => l_job_return_status,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data);
  END IF;
  --Standard check to count messages
   x_msg_count := Fnd_Msg_Pub.count_msg;
   IF x_msg_count > 0 THEN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                      G_LOG_PREFIX||l_api_name||': Within the API',
                      'Error occurred after calling the API in Ahl_PP_Materials_PVT and x_return_status='||
                      x_return_status||', x_msg_count='||x_msg_count);
     END IF;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Generate success error message for display purposes in UI.
   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       -- Added on 1/8/05 by JR to fix Bug 4097327
       -- To give a different confirmation message for update
       IF (l_update_flag = true) THEN
         FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_MTL_REQ_UPDATED');
         FND_MESSAGE.Set_Token('QUANTITY',
l_req_material_u_rec.requested_quantity);
         FND_MESSAGE.Set_Token('UOM', l_mtl_requirement.uom);
       ELSE
         FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_MTL_REQ_SUCCESS');
         FND_MESSAGE.Set_Token('QUANTITY',
l_req_material_rec.requested_quantity);
         FND_MESSAGE.Set_Token('UOM', l_req_material_rec.uom_code);
       END IF;
       FND_MESSAGE.Set_Token('ITEM', l_item_number);
       FND_MSG_PUB.ADD;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   --Count and Get messages (optional)
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Create_Disp_Mtl_Req_Pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Create_Disp_Mtl_Req_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Create_Disp_Mtl_Req_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Create_Disp_Mtl_Requirement;

--------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Create_SR_Disp_Link
--  Type              : Private
--  Function          : Private API to create a SR Link between the Disposition
--                      and the new SR object
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Create_SR_Disp_Link Parameters:
--      p_disposition_id                IN      NUMBER       Required
--         The Id of disposition for which to create SR link.
--      p_service_request_id            IN      Number       Required
--         The ID of Sevice Request for which to create SR link.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_SR_Disp_Link (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2,
    p_service_request_id  IN           NUMBER,
    p_disposition_id      IN           NUMBER,
    x_link_id             OUT NOCOPY  NUMBER
) IS
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Create_SR_Disp_Link';
l_link_rec  CS_INCIDENTLINKS_PUB.CS_INCIDENT_LINK_REC_TYPE;
l_object_version_number NUMBER;
l_reciprocal_link_id    NUMBER;
l_dummy_num             NUMBER;

--
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Create_SR_Disp_Link_Pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
     FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||': Begining of the API',
                   'At the start of the API and p_service_request_id ='||
                   p_service_request_id||', p_disposition_id='||p_disposition_id);
  END IF;

  --validate the input parameters
  BEGIN
    select 1 INTO l_dummy_num
    from ahl_prd_dispositions_b
    where disposition_id = p_disposition_id
    and nvl(status_code, ' ') <> 'TERMINATED';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      fnd_message.set_token('NAME','p_disposition_id');
      fnd_message.set_token('VALUE',p_disposition_id);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
  END;

  BEGIN
    select 1 INTO l_dummy_num
    from cs_incidents
    where incident_id = p_service_request_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      fnd_message.set_token('NAME','p_service_request_id');
      fnd_message.set_token('VALUE',p_service_request_id);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
  END;

  --- Create link between Disposition and Service Request
  l_link_rec := NULL;
  l_link_rec.subject_id := p_service_request_id;
  l_link_rec.subject_type := 'SR';
  l_link_rec.object_id := p_disposition_id;
  --l_link_rec.object_number := l_disp_rec.immediate_disposition_code;
  l_link_rec.object_type := 'AHL_PRD_DISP';
  l_link_rec.link_type_id := 6; --Refers to link type
  l_link_rec.request_id := fnd_global.conc_request_id;
  l_link_rec.program_application_id := fnd_global.prog_appl_id;
  l_link_rec.program_id := fnd_global.conc_program_id;
  l_link_rec.program_update_date := sysdate;

  IF (FND_LOG.LEVEL_EVENT>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                   G_LOG_PREFIX||l_api_name||': Within the API',
                   'Just before calling cs_incidentlinks_pub.create_incidentlink and subject_id='||
                   p_service_request_id||', object_id='||p_disposition_id);
  END IF;
  cs_incidentlinks_pub.create_incidentlink(
					p_api_version 	=> 2.0,
					p_init_msg_list => FND_API.G_FALSE,
					p_commit 	=> FND_API.G_FALSE,
					p_resp_appl_id  => FND_GLOBAL.RESP_APPL_ID,
					p_resp_id	=> FND_GLOBAL.RESP_ID,
					p_user_id 	=> FND_GLOBAL.USER_ID,
					p_login_id	=> NULL,
					p_org_id	=> fnd_profile.value('ORG_ID'),
					p_link_rec	=> l_link_rec,
					x_return_status => x_return_status,
					x_msg_count => x_msg_count,
					x_msg_data  => x_msg_data,
					x_object_version_number => l_object_version_number,
					x_reciprocal_link_id => l_reciprocal_link_id,
					x_link_id	     => x_link_id);

   IF (FND_LOG.LEVEL_EVENT>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                    G_LOG_PREFIX||l_api_name||': Within the API',
                    'After calling cs_incidentlinks_pub.create_incidentlink and x_return_status='||
                    x_return_status||', x_reciprocal_link_id='||l_reciprocal_link_id||', x_link_id='||
                    x_link_id);
   END IF;
   If (x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
     fnd_message.set_name('AHL','AHL_PRD_SR_LINK_CREATE_ERROR');
     fnd_message.set_token('VALUE1',p_disposition_id);
     fnd_msg_pub.add;
     RAISE FND_API.G_EXC_ERROR;
   End If;

  IF (FND_LOG.LEVEL_PROCEDURE>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||': End of the API',
                   'At the end of the API after normal execution.');
  END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   --Count and Get messages (optional)
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Create_SR_Disp_Link_Pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Create_SR_Disp_Link_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Create_SR_Disp_Link_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   END Create_SR_Disp_Link;


-- Function to get the Unit Config Header Id from the workorder Id
-- Tries to get the instance from the Workorder's Visit Task First.
-- If not possible, gets the instance from the Visit.
-- This instance is matched against top nodes of UCs and the matching
-- UC's header id is returned.
-- If no match is found, null is returned.
FUNCTION Get_WO_Unit_Id(p_workorder_id IN NUMBER)
RETURN NUMBER
IS

  CURSOR get_instance_id_csr IS
    SELECT VTS.INSTANCE_ID, VST.ITEM_INSTANCE_ID
    FROM AHL_WORKORDERS WO, AHL_VISITS_B VST, AHL_VISIT_TASKS_B VTS
    WHERE WO.WORKORDER_ID = p_workorder_id AND
          VST.VISIT_ID = WO.VISIT_ID AND
          VTS.VISIT_TASK_ID = WO.VISIT_TASK_ID;



  L_DEBUG_KEY            CONSTANT VARCHAR2(150) := 'ahl.plsql.AHL_PRD_DISP_UTIL_PVT.Get_WO_Unit_Id';
  l_return_value NUMBER;
  l_visit_instance_id NUMBER;
  l_visit_task_instance_id NUMBER;
  l_curr_instance_id NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   L_DEBUG_KEY || '.begin',
                   'Getting UC Header Id for workorder with Id: ' || p_workorder_id);
  END IF;
  OPEN get_instance_id_csr;
  FETCH get_instance_id_csr INTO l_visit_task_instance_id, l_visit_instance_id;
  CLOSE get_instance_id_csr;
  l_curr_instance_id := NVL(l_visit_task_instance_id, l_visit_instance_id);
  l_return_value := AHL_UTIL_UC_PKG.get_uc_header_id(l_curr_instance_id);
  IF (l_return_value IS NULL) THEN
    IF (l_curr_instance_id = l_visit_instance_id) THEN
      -- Task Instance is null, Visit header instance does not belong to an UC.
      null;  -- Return null
    ELSE
      -- Task instance does not belong to an UC. Try to get from Visit Header Level
      l_return_value := AHL_UTIL_UC_PKG.get_uc_header_id(l_visit_instance_id);
    END IF;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   L_DEBUG_KEY || '.end',
                   'Got UC Header Id ' || l_return_value || ' for workorder with Id: ' || p_workorder_id);
  END IF;
  RETURN l_return_value;
END Get_WO_Unit_Id;

-- Function added by Jerry on 01/05/2005 for fixing bug 4093642
-- If the installation part change occurrs after the disposition was termindated,
-- then even if the removal part change against which the disposition was created,
-- is linked with this installation part change id, then this kind of link doesn't
-- make sense and we should break it
FUNCTION install_part_change_valid(p_disposition_id IN NUMBER)
RETURN VARCHAR2 IS

  CURSOR get_timestamps IS
    SELECT ap.last_update_date, ac.creation_date
      FROM ahl_prd_dispositions_b ap,
           ahl_part_changes_v pc,
           ahl_part_changes ac
     WHERE ap.disposition_id = p_disposition_id
       AND ap.part_change_id = pc.part_change_id
       AND pc.installed_part_change_id = ac.part_change_id;
  l_get_timestamps get_timestamps%ROWTYPE;
  l_return_val VARCHAR2(1);
BEGIN
  l_return_val := 'Y';
  OPEN get_timestamps;
  FETCH get_timestamps INTO l_get_timestamps;
  IF (get_timestamps%FOUND AND l_get_timestamps.last_update_date<l_get_timestamps.creation_date) THEN
    l_return_val := 'N';
  END IF;
  CLOSE get_timestamps;
  RETURN l_return_val;
END;

End AHL_PRD_DISP_UTIL_PVT;

/
