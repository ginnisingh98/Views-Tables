--------------------------------------------------------
--  DDL for Package Body GMD_SEARCH_REPLACE_VERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SEARCH_REPLACE_VERS" AS
/* $Header: GMDSREPB.pls 120.8.12010000.2 2008/11/12 18:39:43 rnalla ship $ */

G_PKG_NAME VARCHAR2(32);

/*======================================================================
--  PROCEDURE :
--   create_new_routing
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new routing while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    create_new_routing(    p_routing_id IN  NUMBER,
			     p_Organization_id IN NUMBER,
                             p_effective_start_date IN VARCHAR2,
                             p_effective_end_date IN VARCHAR2,
                             p_inactive_ind IN NUMBER,
                             p_owner IN NUMBER,
                             p_old_operation IN NUMBER,
                             p_new_operation IN NUMBER,
                             p_routing_class IN VARCHAR2,
                             x_routing_id OUT NOCOPY NUMBER)
--
--
-- BUG 5197863 Validate the routing start and end dates
-- Bug 5493773 Removed NVL for the end date as the end date can be NULL
--===================================================================== */

PROCEDURE create_new_routing(p_routing_id IN  NUMBER,
                             p_effective_start_date IN VARCHAR2,
                             p_effective_end_date IN VARCHAR2,
                             p_inactive_ind IN NUMBER,
                             p_owner IN NUMBER,
                             p_old_operation IN NUMBER,
                             p_new_operation IN NUMBER,
                             p_routing_class IN VARCHAR2,
                             x_routing_id OUT NOCOPY NUMBER) IS

  X_routing_vers        NUMBER;
  X_row         NUMBER := 0;

  CURSOR Cur_routing_id IS
    SELECT gem5_routing_id_s.NEXTVAL
    FROM   FND_DUAL;
  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   fm_rout_hdr
    WHERE  routing_id = p_routing_id;
  X_hdr_rec       Cur_get_hdr%ROWTYPE;
  CURSOR Cur_rout_vers IS
    SELECT MAX(routing_vers) + 1
    FROM   fm_rout_hdr
    WHERE  routing_no = X_hdr_rec.routing_no;

  CURSOR Cur_get_dtl IS
    SELECT *
    FROM   fm_rout_dtl
    WHERE  routing_id = p_routing_id;
  TYPE detail_tab IS TABLE OF Cur_get_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
  X_dtl_tbl detail_tab;
  X_return_status       VARCHAR2(1);
  X_message_count       NUMBER;
  X_message_list        VARCHAR2(2000);
  l_entity_status       gmd_api_grp.status_rec_type;

  --BUG 5197863 Added l_ret and VALIDATION_FAILURE
  l_ret                 NUMBER;
  VALIDATION_FAILURE    EXCEPTION;

  l_gmo_enabled         VARCHAR2(1);
  l_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;

  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  -- BUG 5197863 GMD_ROUTINGS_PVT.Validate_dates validates the start and end dates
  -- and also validates the dates with operation dates.

  -- Bug# 5493773 Removed NVL for the end date as the end date can be NULL
  l_ret := GMD_ROUTINGS_PVT.Validate_dates(p_routing_id,
      NVL( FND_DATE.canonical_to_date(p_effective_start_date) ,X_hdr_rec.effective_start_date ),
       FND_DATE.canonical_to_date(p_effective_end_date) );

  IF l_ret < 0 THEN
    RAISE VALIDATION_FAILURE ;
  END IF;

  FOR get_rec IN Cur_get_dtl LOOP
    X_row := X_row + 1;
    X_dtl_tbl(X_row) := get_rec;
  END LOOP;

  OPEN Cur_rout_vers;
  FETCH Cur_rout_vers INTO X_routing_vers;
  CLOSE Cur_rout_vers;

  OPEN Cur_routing_id;
  FETCH Cur_routing_id INTO x_routing_id;
  CLOSE Cur_routing_id;


  /* Check if GMO is enabled */
  l_gmo_enabled :=  gmo_setup_grp.is_gmo_enabled;
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'ROUTING',
				         p_entity_id	=> p_routing_id,
                                         x_name_array   => l_source_name_array,
                                         x_key_array    => l_source_key_array,
			                 x_return_status => x_return_status);
  END IF;

  /* Insert header record */
    -- BUG 5197863 Added NVL to effective end date
    GMD_ROUTINGS_PKG.INSERT_ROW(
    X_ROWID => x_hdr_rec.ROW_ID,
    X_ROUTING_ID => x_routing_id,
    X_owner_organization_id => x_hdr_rec.owner_organization_id,
    X_ROUTING_NO => x_hdr_rec.ROUTING_NO,
    X_ROUTING_VERS => X_routing_vers,
    X_ROUTING_CLASS => NVL(p_routing_class, x_hdr_rec.routing_class), -- 4116557
    X_ROUTING_QTY => x_hdr_rec.ROUTING_QTY,
    X_ROUTING_UOM => x_hdr_rec.ROUTING_UOM,
    X_DELETE_MARK => 0,
    X_TEXT_CODE => x_hdr_rec.TEXT_CODE,
    X_INACTIVE_IND => 0,
    X_ENFORCE_STEP_DEPENDENCY => x_hdr_rec.enforce_step_dependency,
    X_IN_USE => 0,
    X_CONTIGUOUS_IND => x_hdr_rec.CONTIGUOUS_IND,
    X_ATTRIBUTE1 => x_hdr_rec.ATTRIBUTE1,
    X_ATTRIBUTE2 => x_hdr_rec.ATTRIBUTE2,
    X_ATTRIBUTE3 => x_hdr_rec.ATTRIBUTE3,
    X_ATTRIBUTE4 => x_hdr_rec.ATTRIBUTE4,
    X_ATTRIBUTE5 => x_hdr_rec.ATTRIBUTE5,
    X_ATTRIBUTE6 => x_hdr_rec.ATTRIBUTE6,
    X_ATTRIBUTE7 => x_hdr_rec.ATTRIBUTE7,
    X_ATTRIBUTE8 => x_hdr_rec.ATTRIBUTE8,
    X_ATTRIBUTE9 => x_hdr_rec.ATTRIBUTE9,
    X_ATTRIBUTE10 => x_hdr_rec.ATTRIBUTE10,
    X_ATTRIBUTE11 => x_hdr_rec.ATTRIBUTE11,
    X_ATTRIBUTE12 => x_hdr_rec.ATTRIBUTE12,
    X_ATTRIBUTE13 => x_hdr_rec.ATTRIBUTE13,
    X_ATTRIBUTE14 => x_hdr_rec.ATTRIBUTE14,
    X_ATTRIBUTE15 => x_hdr_rec.ATTRIBUTE15,
    X_ATTRIBUTE16 => x_hdr_rec.ATTRIBUTE16,
    X_ATTRIBUTE17 => x_hdr_rec.ATTRIBUTE17,
    X_ATTRIBUTE18 => x_hdr_rec.ATTRIBUTE18,
    X_ATTRIBUTE19 => x_hdr_rec.ATTRIBUTE19,
    X_ATTRIBUTE20 => x_hdr_rec.ATTRIBUTE20,
    X_ATTRIBUTE21 => x_hdr_rec.ATTRIBUTE21,
    X_ATTRIBUTE22 => x_hdr_rec.ATTRIBUTE22,
    X_ATTRIBUTE23 => x_hdr_rec.ATTRIBUTE23,
    X_ATTRIBUTE24 => x_hdr_rec.ATTRIBUTE24,
    X_ATTRIBUTE25 => x_hdr_rec.ATTRIBUTE25,
    X_ATTRIBUTE26 => x_hdr_rec.ATTRIBUTE26,
    X_ATTRIBUTE27 => x_hdr_rec.ATTRIBUTE27,
    X_ATTRIBUTE28 => x_hdr_rec.ATTRIBUTE28,
    X_ATTRIBUTE29 => x_hdr_rec.ATTRIBUTE29,
    X_ATTRIBUTE30 => x_hdr_rec.ATTRIBUTE30,
    X_ATTRIBUTE_CATEGORY => x_hdr_rec.ATTRIBUTE_CATEGORY,
    X_EFFECTIVE_START_DATE => NVL( FND_DATE.canonical_to_date(p_effective_start_date) ,X_hdr_rec.effective_start_date ),
    X_EFFECTIVE_END_DATE =>  NVL(FND_DATE.canonical_to_date (p_effective_end_date) ,X_hdr_rec.effective_end_date ),
    X_OWNER_ID => NVL(p_owner,X_hdr_rec.owner_id),
    X_PROJECT_ID => x_hdr_rec.PROJECT_ID,
    X_PROCESS_LOSS => x_hdr_rec.PROCESS_LOSS,
    X_ROUTING_STATUS => 100,
    X_ROUTING_DESC => x_hdr_rec.ROUTING_DESC,
    X_CREATION_DATE =>  SYSDATE,
    X_CREATED_BY => P_created_by,
    X_LAST_UPDATE_DATE =>  SYSDATE,
    X_LAST_UPDATED_BY => P_login_id,
    X_LAST_UPDATE_LOGIN => P_login_id);


  /* Insert detail records */
  FOR i IN 1..X_dtl_tbl.count LOOP
    INSERT INTO fm_rout_dtl
               (routing_id, routingstep_no, routingstep_id, oprn_id, step_qty, steprelease_type,
                text_code, creation_date, created_by, last_update_login, last_update_date,
                last_updated_by, attribute1, attribute2, attribute3, attribute4, attribute5,
                attribute6, attribute7, attribute8, attribute9, attribute10,
                attribute11, attribute12, attribute13, attribute14, attribute15,
                attribute16, attribute17, attribute18, attribute19, attribute20,
                attribute21, attribute22, attribute23, attribute24, attribute25,
                attribute26, attribute27, attribute28, attribute29, attribute30,
                attribute_category)
    VALUES      (x_routing_id, X_dtl_tbl(i).routingstep_no, gem5_routingstep_id_s.NEXTVAL,
                 DECODE(X_dtl_tbl(i).oprn_id,p_old_operation,p_new_operation,X_dtl_tbl(i).oprn_id),
                 X_dtl_tbl(i).step_qty, X_dtl_tbl(i).steprelease_type,
                 X_dtl_tbl(i).text_code, SYSDATE, P_created_by, P_login_id, SYSDATE, P_created_by,
                 X_dtl_tbl(i).attribute1, X_dtl_tbl(i).attribute2, X_dtl_tbl(i).attribute3,
                 X_dtl_tbl(i).attribute4, X_dtl_tbl(i).attribute5, X_dtl_tbl(i).attribute6,
                 X_dtl_tbl(i).attribute7, X_dtl_tbl(i).attribute8, X_dtl_tbl(i).attribute9,
                 X_dtl_tbl(i).attribute10, X_dtl_tbl(i).attribute11, X_dtl_tbl(i).attribute12,
                 X_dtl_tbl(i).attribute13, X_dtl_tbl(i).attribute14, X_dtl_tbl(i).attribute15,
                 X_dtl_tbl(i).attribute16, X_dtl_tbl(i).attribute17, X_dtl_tbl(i).attribute18,
                 X_dtl_tbl(i).attribute19, X_dtl_tbl(i).attribute20, X_dtl_tbl(i).attribute21,
                 X_dtl_tbl(i).attribute22, X_dtl_tbl(i).attribute23, X_dtl_tbl(i).attribute24,
                 X_dtl_tbl(i).attribute25, X_dtl_tbl(i).attribute26, X_dtl_tbl(i).attribute27,
                 X_dtl_tbl(i).attribute28, X_dtl_tbl(i).attribute29, X_dtl_tbl(i).attribute30,
                 X_dtl_tbl(i).attribute_category);
  END LOOP;

  -- If GMO is enabled, copy the new PI's from old entity to new entity
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'ROUTING',
				         p_entity_id	=> x_routing_id,
                                         x_name_array   => l_target_name_array,
                                         x_key_array    => l_target_key_array,
			                 x_return_status => x_return_status);

    GMD_PROCESS_INSTR_UTILS.Copy_Process_Instructions  (
                                p_source_name_array      => l_source_name_array,
                                p_source_key_array       => l_source_key_array,
                                p_target_name_array      => l_target_name_array,
                                p_target_key_array       => l_target_key_array,
			        x_return_status          => x_return_status);
  END IF;

  COMMIT;

  --Getting the default status for the owner orgn code or null orgn of recipe from parameters table
  gmd_api_grp.get_status_details (V_entity_type   => 'ROUTING',
                                  V_orgn_id       => x_hdr_rec.owner_organization_id,
                                  X_entity_status => l_entity_status);
  --Add this code after the call to gmd_routings_pkg.insert_row.
  IF (l_entity_status.entity_status <> 100) THEN
    Gmd_status_pub.modify_status ( p_api_version        => 1
                                 , p_init_msg_list      => TRUE
                                 , p_entity_name        =>'ROUTING'
                                 , p_entity_id          => x_routing_id
                                 , p_entity_no          => NULL
                                 , p_entity_version     => NULL
                                 , p_to_status          => l_entity_status.entity_status
                                 , p_ignore_flag        => FALSE
                                 , x_message_count      => x_message_count
                                 , x_message_list       => x_message_list
                                 , x_return_status      => X_return_status);
    IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
       FND_MSG_PUB.count_and_get (p_count   => x_message_count
                                 ,p_encoded => FND_API.g_false
                                 ,p_data    => x_message_list);
       X_message_list := FND_MSG_PUB.get (p_msg_index => X_message_count
                                         ,p_encoded => 'F');
       FND_FILE.PUT(FND_FILE.LOG,X_message_list);
       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    END IF; --x_return_status  NOT IN (FND_API.g_ret_sts_success,'P')
  END IF; --l_entity_status.entity_status <> 100
  COMMIT;
-- BUG 5197863 handle the exception.
EXCEPTION WHEN
  VALIDATION_FAILURE THEN
   x_routing_id := NULL;
END create_new_routing;

/*======================================================================
--  PROCEDURE :
--   create_new_operation
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new operation while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--        create_new_operation(p_oprn_id IN  NUMBER,
                               p_old_activity IN VARCHAR2,
                               p_activity IN VARCHAR2,
                               p_effective_start_date IN VARCHAR2,
                               p_effective_end_date IN VARCHAR2,
                               p_operation_class IN VARCHAR2,
                               p_inactive_ind IN NUMBER,
                               p_old_resource IN VARCHAR2,
                               p_resource IN VARCHAR2,
                               x_oprn_id OUT NOCOPY NUMBER) IS
--
--
--===================================================================== */
PROCEDURE create_new_operation(p_oprn_id IN  NUMBER,
                               p_old_activity IN VARCHAR2,
                               p_activity IN VARCHAR2,
                               p_effective_start_date IN VARCHAR2,
                               p_effective_end_date IN VARCHAR2,
                               p_operation_class IN VARCHAR2,
                               p_inactive_ind IN NUMBER,
                               p_old_resource IN VARCHAR2,
                               p_resource IN VARCHAR2,
                               x_oprn_id OUT NOCOPY NUMBER) IS
  CURSOR Cur_gen_oprn_id IS
    SELECT GEM5_OPRN_ID_S.NEXTVAL
    FROM   FND_DUAL;
  CURSOR Cur_gen_oprnline_id IS
    SELECT GEM5_OPRNLINE_ID_S.NEXTVAL
    FROM   FND_DUAL;

  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   gmd_operations_vl
    WHERE  oprn_id = p_oprn_id;
  X_hdr_rec       Cur_get_hdr%ROWTYPE;
  CURSOR Cur_get_vers IS
    SELECT MAX(oprn_vers) + 1
    FROM   gmd_operations_vl
    WHERE  oprn_no = X_hdr_rec.oprn_no;

  CURSOR Cur_get_actv IS
    SELECT *
    FROM   gmd_operation_activities
    WHERE  oprn_id = p_oprn_id;
  TYPE actv_tab IS TABLE OF Cur_get_actv%ROWTYPE INDEX BY BINARY_INTEGER;
  X_actv_tbl       actv_tab;

  CURSOR Cur_get_rsrc(V_oprn_line_id NUMBER) IS
    SELECT *
    FROM   gmd_operation_resources
    WHERE  oprn_line_id = V_oprn_line_id;
  TYPE rsrc_tab IS TABLE OF Cur_get_rsrc%ROWTYPE INDEX BY BINARY_INTEGER;
  X_rsrc_tbl    rsrc_tab;

  X_oprn_vers   NUMBER;
  X_oprn_line_id        NUMBER;
  X_row         NUMBER := 0;
  X_rsrc_cnt      NUMBER := 0;

  X_return_status       VARCHAR2(1);
  X_message_count       NUMBER;
  X_message_list        VARCHAR2(2000);
  l_entity_status       gmd_api_grp.status_rec_type;

  l_gmo_enabled         VARCHAR2(1);
  l_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  FOR get_actv IN Cur_get_actv LOOP
    X_row             := X_row + 1;
    X_actv_tbl(X_row) := get_actv;
    FOR get_rsrc IN Cur_get_rsrc(get_actv.oprn_line_id) LOOP
      X_rsrc_cnt             := X_rsrc_cnt + 1;
      X_rsrc_tbl(X_rsrc_cnt) := get_rsrc;
    END LOOP;
  END LOOP;

  OPEN Cur_get_vers;
  FETCH Cur_get_vers INTO X_oprn_vers;
  CLOSE Cur_get_vers;
  OPEN Cur_gen_oprn_id;
  FETCH Cur_gen_oprn_id INTO x_oprn_id;
  CLOSE Cur_gen_oprn_id;

  /* Check if GMO is enabled */
  l_gmo_enabled :=  gmo_setup_grp.is_gmo_enabled;
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'OPERATION',
				         p_entity_id	=> p_oprn_id,
                                         x_name_array   => l_source_name_array,
                                         x_key_array    => l_source_key_array,
			                 x_return_status => x_return_status);
  END IF;


  /* Insert header record */
    GMD_OPERATIONS_PKG.INSERT_ROW(
    X_ROWID => x_hdr_rec.ROW_ID,
    X_OPRN_ID => x_oprn_id,
    X_ATTRIBUTE30 => x_hdr_rec.ATTRIBUTE30,
    X_ATTRIBUTE_CATEGORY => x_hdr_rec.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE25 => x_hdr_rec.ATTRIBUTE25,
    X_ATTRIBUTE26 => x_hdr_rec.ATTRIBUTE26,
    X_ATTRIBUTE27 => x_hdr_rec.ATTRIBUTE27,
    X_ATTRIBUTE28 => x_hdr_rec.ATTRIBUTE28,
    X_ATTRIBUTE29 => x_hdr_rec.ATTRIBUTE29,
    X_ATTRIBUTE22 => x_hdr_rec.ATTRIBUTE22,
    X_ATTRIBUTE23 => x_hdr_rec.ATTRIBUTE23,
    X_ATTRIBUTE24 => x_hdr_rec.ATTRIBUTE24,
    X_OPRN_NO => x_hdr_rec.OPRN_NO,
    X_OPRN_VERS => X_oprn_vers,
    X_PROCESS_QTY_UOM => x_hdr_rec.PROCESS_QTY_UOM,
    X_OPRN_CLASS => NVL(p_operation_class,x_hdr_rec.oprn_class), -- 4116557
    X_INACTIVE_IND =>  NVL(p_inactive_ind,0),
    X_EFFECTIVE_START_DATE => NVL(FND_DATE.canonical_to_date(p_effective_start_date) ,X_hdr_rec.effective_start_date ),
    X_EFFECTIVE_END_DATE =>  FND_DATE.canonical_to_date( p_effective_end_date ),
    X_DELETE_MARK => 0,
    X_TEXT_CODE => x_hdr_rec.TEXT_CODE,
    X_ATTRIBUTE1 => x_hdr_rec.ATTRIBUTE1,
    X_ATTRIBUTE2 => x_hdr_rec.ATTRIBUTE2,
    X_ATTRIBUTE3 => x_hdr_rec.ATTRIBUTE3,
    X_ATTRIBUTE4 => x_hdr_rec.ATTRIBUTE4,
    X_ATTRIBUTE5 => x_hdr_rec.ATTRIBUTE5,
    X_ATTRIBUTE6 => x_hdr_rec.ATTRIBUTE6,
    X_ATTRIBUTE7 => x_hdr_rec.ATTRIBUTE7,
    X_ATTRIBUTE8 => x_hdr_rec.ATTRIBUTE8,
    X_ATTRIBUTE9 => x_hdr_rec.ATTRIBUTE9,
    X_ATTRIBUTE10 => x_hdr_rec.ATTRIBUTE10,
    X_ATTRIBUTE11 => x_hdr_rec.ATTRIBUTE11,
    X_ATTRIBUTE12 => x_hdr_rec.ATTRIBUTE12,
    X_ATTRIBUTE13 => x_hdr_rec.ATTRIBUTE13,
    X_ATTRIBUTE14 => x_hdr_rec.ATTRIBUTE14,
    X_ATTRIBUTE15 => x_hdr_rec.ATTRIBUTE15,
    X_ATTRIBUTE16 => x_hdr_rec.ATTRIBUTE16,
    X_ATTRIBUTE17 => x_hdr_rec.ATTRIBUTE17,
    X_ATTRIBUTE18 => x_hdr_rec.ATTRIBUTE18,
    X_ATTRIBUTE19 => x_hdr_rec.ATTRIBUTE19,
    X_ATTRIBUTE20 => x_hdr_rec.ATTRIBUTE20,
    X_ATTRIBUTE21 => x_hdr_rec.ATTRIBUTE21,
    X_OPERATION_STATUS => 100,
    X_owner_organization_id => x_hdr_rec.owner_organization_id,
    X_OPRN_DESC => x_hdr_rec.OPRN_DESC,
    X_CREATION_DATE =>  SYSDATE,
    X_CREATED_BY => P_created_by,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => P_created_by,
    X_LAST_UPDATE_LOGIN => P_login_id);


  /* Insert Activities */
  X_rsrc_cnt := 0;
  FOR i IN 1..X_actv_tbl.count LOOP
    OPEN Cur_gen_oprnline_id;
    FETCH Cur_gen_oprnline_id INTO X_oprn_line_id;
    CLOSE Cur_gen_oprnline_id;
    INSERT INTO gmd_operation_activities
               (oprn_id, oprn_line_id, activity, activity_factor, delete_mark, text_code, last_updated_by,
                created_by, last_update_date, creation_date, last_update_login, attribute1, attribute2,
                attribute3, attribute4, attribute5, attribute6, attribute7, attribute8, attribute9,
                attribute10, attribute11, attribute12, attribute13, attribute14, attribute15, attribute16,
                attribute17, attribute18, attribute19, attribute20, attribute21, attribute22, attribute23,
                attribute24, attribute25, attribute26, attribute27, attribute28, attribute29, attribute30,
                attribute_category, offset_interval, break_ind, max_break)
    VALUES     (x_oprn_id, X_oprn_line_id, DECODE(X_actv_tbl(i).activity,p_old_activity,p_activity,X_actv_tbl(i).activity)
               , X_actv_tbl(i).activity_factor, 0,
                X_actv_tbl(i).text_code, P_created_by, P_created_by, SYSDATE, SYSDATE, P_login_id,
                X_actv_tbl(i).attribute1, X_actv_tbl(i).attribute2, X_actv_tbl(i).attribute3,
                X_actv_tbl(i).attribute4, X_actv_tbl(i).attribute5, X_actv_tbl(i).attribute6,
                X_actv_tbl(i).attribute7, X_actv_tbl(i).attribute8, X_actv_tbl(i).attribute9,
                X_actv_tbl(i).attribute10, X_actv_tbl(i).attribute11, X_actv_tbl(i).attribute12,
                X_actv_tbl(i).attribute13, X_actv_tbl(i).attribute14, X_actv_tbl(i).attribute15,
                X_actv_tbl(i).attribute16, X_actv_tbl(i).attribute17, X_actv_tbl(i).attribute18,
                X_actv_tbl(i).attribute19, X_actv_tbl(i).attribute20, X_actv_tbl(i).attribute21,
                X_actv_tbl(i).attribute22, X_actv_tbl(i).attribute23, X_actv_tbl(i).attribute24,
                X_actv_tbl(i).attribute25, X_actv_tbl(i).attribute26, X_actv_tbl(i).attribute27,
                X_actv_tbl(i).attribute28, X_actv_tbl(i).attribute29, X_actv_tbl(i).attribute30,
                X_actv_tbl(i).attribute_category, X_actv_tbl(i).offset_interval, x_actv_tbl(i).break_ind, x_actv_tbl(i).max_break);
    LOOP
      X_rsrc_cnt := X_rsrc_cnt + 1;
      IF (X_rsrc_cnt > X_rsrc_tbl.count) THEN
        EXIT;
      END IF;
      IF (X_actv_tbl(i).oprn_line_id = X_rsrc_tbl(X_rsrc_cnt).oprn_line_id) THEN
        INSERT INTO gmd_operation_resources
                   (oprn_line_id, resources, resource_usage, resource_count, process_qty,
                    prim_rsrc_ind, scale_type, cost_analysis_code, cost_cmpntcls_id, resource_usage_uom,
                    offset_interval, delete_mark, text_code, created_by, last_updated_by,
                    last_update_date, creation_date, last_update_login, attribute1, attribute2,
                    attribute3, attribute4, attribute5, attribute6, attribute7, attribute8,
                    attribute9, attribute10, attribute11, attribute12, attribute13, attribute14,
                    attribute15, attribute16, attribute17, attribute18, attribute19, attribute20,
                    attribute21, attribute22, attribute23, attribute24, attribute25, attribute26,
                    attribute27, attribute28, attribute29, attribute30, attribute_category,
                    resource_process_uom, min_capacity, max_capacity, resource_capacity_uom, process_parameter_1,
                    process_parameter_2, process_parameter_3, process_parameter_4, process_parameter_5)
        VALUES     (X_oprn_line_id, DECODE(X_rsrc_tbl(X_rsrc_cnt).resources,p_old_resource,p_resource,X_rsrc_tbl(X_rsrc_cnt).resources),
                    X_rsrc_tbl(X_rsrc_cnt).resource_usage,
                    X_rsrc_tbl(X_rsrc_cnt).resource_count, X_rsrc_tbl(X_rsrc_cnt).process_qty,
                    X_rsrc_tbl(X_rsrc_cnt).prim_rsrc_ind, X_rsrc_tbl(X_rsrc_cnt).scale_type,
                    X_rsrc_tbl(X_rsrc_cnt).cost_analysis_code, X_rsrc_tbl(X_rsrc_cnt).cost_cmpntcls_id,
                    X_rsrc_tbl(X_rsrc_cnt).resource_usage_uom, X_rsrc_tbl(X_rsrc_cnt).offset_interval, X_rsrc_tbl(X_rsrc_cnt).delete_mark,
                    X_rsrc_tbl(X_rsrc_cnt).text_code, P_created_by, P_created_by, SYSDATE, SYSDATE, P_login_id,
                    X_rsrc_tbl(X_rsrc_cnt).attribute1, X_rsrc_tbl(X_rsrc_cnt).attribute2,
                    X_rsrc_tbl(X_rsrc_cnt).attribute3, X_rsrc_tbl(X_rsrc_cnt).attribute4,
                    X_rsrc_tbl(X_rsrc_cnt).attribute5, X_rsrc_tbl(X_rsrc_cnt).attribute6,
                    X_rsrc_tbl(X_rsrc_cnt).attribute7, X_rsrc_tbl(X_rsrc_cnt).attribute8,
                    X_rsrc_tbl(X_rsrc_cnt).attribute9, X_rsrc_tbl(X_rsrc_cnt).attribute10,
                    X_rsrc_tbl(X_rsrc_cnt).attribute11, X_rsrc_tbl(X_rsrc_cnt).attribute12,
                    X_rsrc_tbl(X_rsrc_cnt).attribute13, X_rsrc_tbl(X_rsrc_cnt).attribute14,
                    X_rsrc_tbl(X_rsrc_cnt).attribute15, X_rsrc_tbl(X_rsrc_cnt).attribute16,
                    X_rsrc_tbl(X_rsrc_cnt).attribute17, X_rsrc_tbl(X_rsrc_cnt).attribute18,
                    X_rsrc_tbl(X_rsrc_cnt).attribute19, X_rsrc_tbl(X_rsrc_cnt).attribute20,
                    X_rsrc_tbl(X_rsrc_cnt).attribute21, X_rsrc_tbl(X_rsrc_cnt).attribute22,
                    X_rsrc_tbl(X_rsrc_cnt).attribute23, X_rsrc_tbl(X_rsrc_cnt).attribute24,
                    X_rsrc_tbl(X_rsrc_cnt).attribute25, X_rsrc_tbl(X_rsrc_cnt).attribute26,
                    X_rsrc_tbl(X_rsrc_cnt).attribute27, X_rsrc_tbl(X_rsrc_cnt).attribute28,
                    X_rsrc_tbl(X_rsrc_cnt).attribute29, X_rsrc_tbl(X_rsrc_cnt).attribute30,
                    X_rsrc_tbl(X_rsrc_cnt).attribute_category, X_rsrc_tbl(X_rsrc_cnt).resource_process_uom,
                    X_rsrc_tbl(X_rsrc_cnt).min_capacity, X_rsrc_tbl(X_rsrc_cnt).max_capacity,
                    X_rsrc_tbl(X_rsrc_cnt).resource_capacity_uom, X_rsrc_tbl(X_rsrc_cnt).process_parameter_1,
                    X_rsrc_tbl(X_rsrc_cnt).process_parameter_2, X_rsrc_tbl(X_rsrc_cnt).process_parameter_3,
                    X_rsrc_tbl(X_rsrc_cnt).process_parameter_4, X_rsrc_tbl(X_rsrc_cnt).process_parameter_5);
      ELSE
        X_rsrc_cnt := X_rsrc_cnt - 1;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;

  -- If GMO is enabled, copy the new PI's from old entity to new entity
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'OPERATION',
				         p_entity_id	=> x_oprn_id,
                                         x_name_array   => l_target_name_array,
                                         x_key_array    => l_target_key_array,
			                 x_return_status => x_return_status);

    GMD_PROCESS_INSTR_UTILS.Copy_Process_Instructions  (
                                p_source_name_array      => l_source_name_array,
                                p_source_key_array       => l_source_key_array,
                                p_target_name_array      => l_target_name_array,
                                p_target_key_array       => l_target_key_array,
			        x_return_status          => x_return_status);
  END IF;

  COMMIT;

  --Getting the default status for the owner orgn code or null orgn of recipe from parameters table
  gmd_api_grp.get_status_details (V_entity_type   => 'OPERATION',
                                  V_orgn_id       => x_hdr_rec.owner_organization_id,
                                  X_entity_status => l_entity_status);
  --Add this code after the call to gmd_routings_pkg.insert_row.
  IF (l_entity_status.entity_status <> 100) THEN
    Gmd_status_pub.modify_status ( p_api_version        => 1
                                 , p_init_msg_list      => TRUE
                                 , p_entity_name        =>'OPERATION'
                                 , p_entity_id          => x_oprn_id
                                 , p_entity_no          => NULL
                                 , p_entity_version     => NULL
                                 , p_to_status          => l_entity_status.entity_status
                                 , p_ignore_flag        => FALSE
                                 , x_message_count      => x_message_count
                                 , x_message_list       => x_message_list
                                 , x_return_status      => X_return_status);
    IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
       FND_MSG_PUB.count_and_get (p_count   => x_message_count
                                 ,p_encoded => FND_API.g_false
                                 ,p_data    => x_message_list);
       X_message_list := FND_MSG_PUB.get (p_msg_index => X_message_count
                                         ,p_encoded => 'F');
       FND_FILE.PUT(FND_FILE.LOG,X_message_list);
       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    END IF; --x_return_status  NOT IN (FND_API.g_ret_sts_success,'P')
  END IF; --l_entity_status.entity_status <> 100
  COMMIT;

END create_new_operation;

/*======================================================================
--  PROCEDURE :
--   create_new_recipe
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new recipe while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--        create_new_recipe(p_recipe_id IN  NUMBER,
                            p_routing_id IN NUMBER,
                            p_formula_id IN NUMBER,
                            powner_id  IN NUMBER,
                            powner_orgn_code IN VARCHAR2,
                            x_recipe_id OUT NOCOPY NUMBER) IS
--
--  Mohit Kapoor 24-Jul-2003 Bug 3037410 Added/Modified code in
--    order to restrict insertion of dependent records if
--    Formula / Routing is replaced in a recipe.
--  RLNAGARA Fixed Process Loss ME
--===================================================================== */
PROCEDURE create_new_recipe(p_recipe_id IN  NUMBER,
                            p_routing_id IN NUMBER,
                            p_formula_id IN NUMBER,
                            powner_id  IN NUMBER,
                            powner_orgn_code IN VARCHAR2,
    			    p_Organization_id IN NUMBER,
			    p_recipe_type IN NUMBER,
                            x_recipe_id OUT NOCOPY NUMBER) IS

  l_rowid               VARCHAR2(18);
  X_recipe_vers NUMBER;
  X_row         NUMBER;
  X_cnt         NUMBER;  --Bug 3037410 Mohit Kapoor

  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   gmd_recipes
    WHERE  recipe_id = p_recipe_id;
  X_hdr_rec            Cur_get_hdr%ROWTYPE;

  CURSOR Cur_process_loss IS
    SELECT *
    FROM   gmd_recipe_process_loss
    WHERE  recipe_id = p_recipe_id;
  TYPE proc_loss IS TABLE OF Cur_process_loss%ROWTYPE INDEX BY BINARY_INTEGER;
  X_proc_loss_tbl       proc_loss;

  CURSOR Cur_get_cust IS
    SELECT *
    FROM   gmd_recipe_customers
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_cust IS TABLE OF Cur_get_cust%ROWTYPE INDEX BY BINARY_INTEGER;
  X_cust_tbl    rcp_cust;

  CURSOR Cur_get_steps IS
    SELECT *
    FROM   gmd_recipe_routing_steps
    WHERE  recipe_id = p_recipe_id;

  TYPE rcp_steps IS TABLE OF Cur_get_steps%ROWTYPE INDEX BY BINARY_INTEGER;
  X_step_tbl    rcp_steps;

  CURSOR Cur_get_vr IS
    SELECT *
    FROM   gmd_recipe_validity_rules
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_vr IS TABLE OF Cur_get_vr%ROWTYPE INDEX BY BINARY_INTEGER;
  X_vr_tbl      rcp_vr;

  CURSOR Cur_get_actv IS
    SELECT *
    FROM   gmd_recipe_orgn_activities
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_actv IS TABLE OF Cur_get_actv%ROWTYPE INDEX BY BINARY_INTEGER;
  X_actv_tbl    rcp_actv;

  CURSOR Cur_get_rsrc IS
    SELECT *
    FROM   gmd_recipe_orgn_resources
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_rsrc IS TABLE OF Cur_get_rsrc%ROWTYPE INDEX BY BINARY_INTEGER;
  X_rsrc_tbl    rcp_rsrc;

  CURSOR Cur_step_mtl IS
    SELECT *
    FROM   gmd_recipe_step_materials
    WHERE  recipe_id = p_recipe_id;
  TYPE step_mtl IS TABLE OF Cur_step_mtl%ROWTYPE INDEX BY BINARY_INTEGER;
  X_stepmtl_tbl step_mtl;

  CURSOR Cur_recipe_vers IS
    SELECT MAX(recipe_version) + 1
    FROM   gmd_recipes
    WHERE  recipe_no = X_hdr_rec.recipe_no;
  CURSOR Cur_recipe_id IS
    SELECT gmd_recipe_id_s.NEXTVAL
    FROM   FND_DUAL;

  X_return_status       VARCHAR2(1);
  X_message_count       NUMBER;
  X_message_list        VARCHAR2(2000);
  l_entity_status       gmd_api_grp.status_rec_type;

  l_form_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_form_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_rout_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_rout_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;

  j PLS_INTEGER;

  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  X_row := 0;
  FOR get_loss IN Cur_process_loss LOOP
    X_row := X_row + 1;
    X_proc_loss_tbl(X_row) := get_loss;
  END LOOP;

  X_row := 0;
  FOR get_cust IN Cur_get_cust LOOP
    X_row := X_row + 1;
    X_cust_tbl(X_row) := get_cust;
  END LOOP;

  X_row := 0;
  FOR get_steps IN Cur_get_steps LOOP
    X_row := X_row + 1;
    X_step_tbl(X_row) := get_steps;
  END LOOP;

  X_row := 0;
  FOR get_vr IN Cur_get_vr LOOP
    X_row := X_row + 1;
    X_vr_tbl(X_row) := get_vr;
  END LOOP;

  X_row := 0;
  FOR get_actv IN Cur_get_actv LOOP
    X_row := X_row + 1;
    X_actv_tbl(X_row) := get_actv;
  END LOOP;

  X_row := 0;
  FOR get_rsrc IN Cur_get_rsrc LOOP
    X_row := X_row + 1;
    X_rsrc_tbl(X_row) := get_rsrc;
  END LOOP;

  X_row := 0;
  FOR get_step_mtl IN Cur_step_mtl LOOP
    X_row := X_row + 1;
    X_stepmtl_tbl(X_row) := get_step_mtl;
  END LOOP;

  OPEN Cur_recipe_vers;
  FETCH Cur_recipe_vers INTO X_recipe_vers;
  CLOSE Cur_recipe_vers;

  OPEN Cur_recipe_id;
  FETCH Cur_recipe_id INTO x_recipe_id;
  CLOSE Cur_recipe_id;
  gmd_recipes_mls.insert_row(X_ROWID                   => l_rowid,
                             X_RECIPE_ID               => x_recipe_id,
                             X_OWNER_ID                => NVL(powner_id,X_hdr_rec.owner_id),
                             X_OWNER_LAB_TYPE          => X_hdr_rec.owner_lab_type,
                             X_DELETE_MARK             => 0,
                             X_TEXT_CODE               => X_hdr_rec.text_code,
                             X_RECIPE_NO               => X_hdr_rec.recipe_no,
                             X_RECIPE_VERSION          => X_recipe_vers,
			     X_RECIPE_TYPE             => NVL(p_recipe_type, X_hdr_rec.recipe_type),
                             X_OWNER_ORGANIZATION_ID   => NVL(p_Organization_id,X_hdr_rec.owner_organization_id),
                             X_CREATION_ORGANIZATION_ID=> NVL(p_Organization_id,X_hdr_rec.owner_organization_id),
                             X_FORMULA_ID              => NVL(p_formula_id,x_hdr_rec.formula_id),
   -- Bug 4116557 added NVL for Roution_id.
                             X_ROUTING_ID              => NVL( p_routing_id,x_hdr_rec.routing_id),
                             X_PROJECT_ID              => X_hdr_rec.project_id,
                             X_RECIPE_STATUS           => 100,
                             X_CALCULATE_STEP_QUANTITY => X_hdr_rec.calculate_step_quantity,
                             X_PLANNED_PROCESS_LOSS    => X_hdr_rec.planned_process_loss,
			     X_CONTIGUOUS_IND	       => X_hdr_rec.contiguous_ind,
                             X_ENHANCED_PI_IND         => X_hdr_rec.enhanced_pi_ind,
                             X_RECIPE_DESCRIPTION      => X_hdr_rec.recipe_description,
                             X_ATTRIBUTE_CATEGORY      => X_hdr_rec.attribute_category,
                             X_ATTRIBUTE1              => X_hdr_rec.attribute1,
                             X_ATTRIBUTE2              => X_hdr_rec.attribute2,
                             X_ATTRIBUTE3              => X_hdr_rec.attribute3,
                             X_ATTRIBUTE4              => X_hdr_rec.attribute4,
                             X_ATTRIBUTE5              => X_hdr_rec.attribute5,
                             X_ATTRIBUTE6              => X_hdr_rec.attribute6,
                             X_ATTRIBUTE7              => X_hdr_rec.attribute7,
                             X_ATTRIBUTE8              => X_hdr_rec.attribute8,
                             X_ATTRIBUTE9              => X_hdr_rec.attribute9,
                             X_ATTRIBUTE10             => X_hdr_rec.attribute10,
                             X_ATTRIBUTE11             => X_hdr_rec.attribute11,
                             X_ATTRIBUTE12             => X_hdr_rec.attribute12,
                             X_ATTRIBUTE13             => X_hdr_rec.attribute13,
                             X_ATTRIBUTE14             => X_hdr_rec.attribute14,
                             X_ATTRIBUTE15             => X_hdr_rec.attribute15,
                             X_ATTRIBUTE16             => X_hdr_rec.attribute16,
                             X_ATTRIBUTE17             => X_hdr_rec.attribute17,
                             X_ATTRIBUTE18             => X_hdr_rec.attribute18,
                             X_ATTRIBUTE19             => X_hdr_rec.attribute19,
                             X_ATTRIBUTE20             => X_hdr_rec.attribute20,
                             X_ATTRIBUTE21             => X_hdr_rec.attribute21,
                             X_ATTRIBUTE22             => X_hdr_rec.attribute22,
                             X_ATTRIBUTE23             => X_hdr_rec.attribute23,
                             X_ATTRIBUTE24             => X_hdr_rec.attribute24,
                             X_ATTRIBUTE25             => X_hdr_rec.attribute25,
                             X_ATTRIBUTE26             => X_hdr_rec.attribute26,
                             X_ATTRIBUTE27             => X_hdr_rec.attribute27,
                             X_ATTRIBUTE28             => X_hdr_rec.attribute28,
                             X_ATTRIBUTE29             => X_hdr_rec.attribute29,
                             X_ATTRIBUTE30             => X_hdr_rec.attribute30,
                             X_CREATION_DATE           => SYSDATE,
                             X_CREATED_BY              => P_created_by,
                             X_LAST_UPDATE_DATE        => SYSDATE,
                             X_LAST_UPDATED_BY         => P_created_by,
                             X_LAST_UPDATE_LOGIN       => P_login_id,
			     X_FIXED_PROCESS_LOSS      => X_hdr_rec.fixed_process_loss, /*RLNAGARA  6811759*/
                             X_FIXED_PROCESS_LOSS_UOM  => X_hdr_rec.fixed_process_loss_uom);

  FOR i IN 1..X_proc_loss_tbl.count LOOP
    INSERT INTO gmd_recipe_process_loss(recipe_id, organization_id, process_loss, contiguous_ind, creation_date, created_by,
                                        last_updated_by, last_update_date, last_update_login,
                                        recipe_process_loss_id, text_code)
    VALUES                             (x_recipe_id, X_proc_loss_tbl(i).organization_id, X_proc_loss_tbl(i).process_loss,
					X_proc_loss_tbl(i).contiguous_ind, SYSDATE, P_created_by, P_created_by, SYSDATE, P_login_id,
                                        gmd_recipe_process_loss_id_s.NEXTVAL, X_proc_loss_tbl(i).text_code);
  END LOOP;
  FOR i IN 1..X_cust_tbl.count LOOP
    INSERT INTO gmd_recipe_customers(recipe_id, customer_id, created_by, creation_date, last_updated_by,
                                     last_update_login, text_code, last_update_date)
    VALUES                          (x_recipe_id, X_cust_tbl(i).customer_id, P_created_by, SYSDATE,
                                     P_created_by, P_login_id, X_cust_tbl(i).text_code, SYSDATE);
  END LOOP;

  -- Bug 3037410 Mohit Kapoor Added the if statement
  IF p_routing_id is NULL THEN
    FOR i IN 1..X_step_tbl.count LOOP
      INSERT INTO gmd_recipe_routing_steps(recipe_id, routingstep_id, step_qty, created_by, creation_date,
                                           last_update_date, last_update_login, text_code, last_updated_by,
                                           attribute1, attribute2, attribute3, attribute4, attribute5, attribute6,
                                           attribute7, attribute8, attribute9, attribute10, attribute11, attribute12,
                                           attribute13, attribute14, attribute15, attribute16, attribute17,
                                           attribute18, attribute19, attribute20, attribute21, attribute22,
                                           attribute23, attribute24, attribute25, attribute26, attribute27, attribute28,
                                           attribute29, attribute30, attribute_category, MASS_STD_UOM, VOLUME_STD_UOM,
                                           volume_qty, mass_qty)
      VALUES                              (x_recipe_id, X_step_tbl(i).routingstep_id, X_step_tbl(i).step_qty,
                                           P_created_by, SYSDATE, SYSDATE, P_login_id, X_step_tbl(i).text_code,
                                           P_created_by, X_step_tbl(i).attribute1, X_step_tbl(i).attribute2,
                                           X_step_tbl(i).attribute3, X_step_tbl(i).attribute4, X_step_tbl(i).attribute5,
                                           X_step_tbl(i).attribute6, X_step_tbl(i).attribute7, X_step_tbl(i).attribute8,
                                           X_step_tbl(i).attribute9, X_step_tbl(i).attribute10, X_step_tbl(i).attribute11,
                                           X_step_tbl(i).attribute12, X_step_tbl(i).attribute13, X_step_tbl(i).attribute14,
                                           X_step_tbl(i).attribute15, X_step_tbl(i).attribute16, X_step_tbl(i).attribute17,
                                           X_step_tbl(i).attribute18, X_step_tbl(i).attribute19, X_step_tbl(i).attribute20,
                                           X_step_tbl(i).attribute21, X_step_tbl(i).attribute22, X_step_tbl(i).attribute23,
                                           X_step_tbl(i).attribute24, X_step_tbl(i).attribute25, X_step_tbl(i).attribute26,
                                           X_step_tbl(i).attribute27, X_step_tbl(i).attribute28, X_step_tbl(i).attribute29,
                                           X_step_tbl(i).attribute30, X_step_tbl(i).attribute_category,
                                           X_step_tbl(i).MASS_STD_UOM, X_step_tbl(i).VOLUME_STD_UOM,
                                           X_step_tbl(i).volume_qty, X_step_tbl(i).mass_qty);
    END LOOP;
  END IF;  -- Bug 3037410

  FOR i IN 1..X_vr_tbl.count LOOP
    --Begin 3037410 Mohit Kapoor
    X_cnt := 1;
    IF p_formula_id IS NOT NULL THEN
      SELECT count(*) INTO X_cnt FROM fm_matl_dtl
      WHERE item_id = X_vr_tbl(i).item_id AND
            formula_id = p_formula_id AND
            line_type = 1;
    END IF;

    IF X_cnt > 0 THEN
    --End 3037410
      INSERT INTO gmd_recipe_validity_rules(recipe_validity_rule_id, recipe_id, organization_id, inventory_item_id, revision, recipe_use, preference,
                                            start_date, end_date, min_qty, max_qty, std_qty, detail_uom, inv_min_qty,
                                            inv_max_qty, text_code, attribute_category, attribute1, attribute2, attribute3,
                                            attribute4, attribute5, attribute6, attribute7, attribute8, attribute9,
                                            attribute10, attribute11, attribute12,  attribute13, attribute14,  attribute15,
                                            attribute16, attribute17, attribute18, attribute19, attribute20, attribute21,
                                            attribute22, attribute23, attribute24, attribute25, attribute26, attribute27,
                                            attribute28, attribute29, attribute30, created_by, creation_date,
                                            last_updated_by, last_update_date, last_update_login, delete_mark,
                                            lab_type, validity_rule_status)
      VALUES                               (gmd_recipe_validity_id_s.NEXTVAL, x_recipe_id, X_vr_tbl(i).organization_id,
                                            X_vr_tbl(i).inventory_item_id,X_vr_tbl(i).revision, X_vr_tbl(i).recipe_use, X_vr_tbl(i).preference,
                                            X_vr_tbl(i).start_date, X_vr_tbl(i).end_date, X_vr_tbl(i).min_qty,
                                            X_vr_tbl(i).max_qty, X_vr_tbl(i).std_qty, X_vr_tbl(i).detail_uom,
                                            X_vr_tbl(i).inv_min_qty, X_vr_tbl(i).inv_max_qty, X_vr_tbl(i).text_code,
                                            X_vr_tbl(i).attribute_category, X_vr_tbl(i).attribute1, X_vr_tbl(i).attribute2,
                                            X_vr_tbl(i).attribute3, X_vr_tbl(i).attribute4, X_vr_tbl(i).attribute5,
                                            X_vr_tbl(i).attribute6, X_vr_tbl(i).attribute7, X_vr_tbl(i).attribute8,
                                            X_vr_tbl(i).attribute9, X_vr_tbl(i).attribute10, X_vr_tbl(i).attribute11,
                                            X_vr_tbl(i).attribute12, X_vr_tbl(i).attribute13, X_vr_tbl(i).attribute14,
                                            X_vr_tbl(i).attribute15, X_vr_tbl(i).attribute16, X_vr_tbl(i).attribute17,
                                            X_vr_tbl(i).attribute18, X_vr_tbl(i).attribute19, X_vr_tbl(i).attribute20,
                                            X_vr_tbl(i).attribute21, X_vr_tbl(i).attribute22, X_vr_tbl(i).attribute23,
                                            X_vr_tbl(i).attribute24, X_vr_tbl(i).attribute25, X_vr_tbl(i).attribute26,
                                            X_vr_tbl(i).attribute27, X_vr_tbl(i).attribute28, X_vr_tbl(i).attribute29,
                                            X_vr_tbl(i).attribute30, P_created_by, SYSDATE, P_created_by, SYSDATE,
                                            P_login_id, 0, X_vr_tbl(i).lab_type, 100);
    END IF;   -- Bug 3037410
  END LOOP;

  -- Bug 3037410 Mohit Kapoor Added the if statement
  IF p_routing_id is NULL THEN
    FOR i IN 1..X_actv_tbl.count LOOP
      INSERT INTO gmd_recipe_orgn_activities(recipe_id, routingstep_id, activity_factor, attribute_category, attribute1,
                                             created_by, creation_date, last_updated_by, last_update_date,
                                             last_update_login, orgn_code, attribute2, attribute3, attribute4, attribute5,
                                             attribute6, attribute7, attribute8, attribute9, attribute10, attribute11,
                                             attribute12, attribute13, attribute14, attribute15, attribute16, attribute17,
                                             attribute18, attribute19, attribute20, attribute21, attribute22, attribute23,
                                             attribute24, attribute25, attribute26, attribute27, attribute28, attribute29,
                                             attribute30, text_code, oprn_line_id)
      VALUES                                (x_recipe_id, X_actv_tbl(i).routingstep_id, X_actv_tbl(i).activity_factor,
                                             X_actv_tbl(i).attribute_category, X_actv_tbl(i).attribute1,
                                             P_created_by, SYSDATE, P_created_by, SYSDATE, P_login_id,
                                             X_actv_tbl(i).orgn_code, X_actv_tbl(i).attribute2, X_actv_tbl(i).attribute3,
                                             X_actv_tbl(i).attribute4, X_actv_tbl(i).attribute5, X_actv_tbl(i).attribute6,
                                             X_actv_tbl(i).attribute7, X_actv_tbl(i).attribute8, X_actv_tbl(i).attribute9,
                                             X_actv_tbl(i).attribute10, X_actv_tbl(i).attribute11, X_actv_tbl(i).attribute12,
                                             X_actv_tbl(i).attribute13, X_actv_tbl(i).attribute14, X_actv_tbl(i).attribute15,
                                             X_actv_tbl(i).attribute16, X_actv_tbl(i).attribute17, X_actv_tbl(i).attribute18,
                                             X_actv_tbl(i).attribute19, X_actv_tbl(i).attribute20, X_actv_tbl(i).attribute21,
                                             X_actv_tbl(i).attribute22, X_actv_tbl(i).attribute23, X_actv_tbl(i).attribute24,
                                             X_actv_tbl(i).attribute25, X_actv_tbl(i).attribute26, X_actv_tbl(i).attribute27,
                                             X_actv_tbl(i).attribute28, X_actv_tbl(i).attribute29, X_actv_tbl(i).attribute30,
                                             X_actv_tbl(i).text_code, X_actv_tbl(i).oprn_line_id
                                             );
    END LOOP;

    FOR i IN 1..X_rsrc_tbl.count LOOP
      INSERT INTO gmd_recipe_orgn_resources(recipe_id, organization_id, routingstep_id, oprn_line_id, resources, creation_date,
                                            created_by, last_updated_by, last_update_date, min_capacity, max_capacity,
                                            last_update_login, text_code,
                                            attribute1, attribute2, attribute3, attribute4, attribute5, attribute6,
                                            attribute7, attribute8, attribute9, attribute10, attribute11, attribute12,
                                            attribute13, attribute14, attribute15, attribute16, attribute17, attribute18,
                                            attribute19, attribute20, attribute21, attribute22, attribute23, attribute24,
                                            attribute25, attribute26, attribute27, attribute28, attribute29, attribute30,
                                            attribute_category, process_parameter_5, process_parameter_4,
                                            process_parameter_3, process_parameter_2, process_parameter_1, process_um,
                                            usage_uom, resource_usage, process_qty)
      VALUES                               (x_recipe_id, X_rsrc_tbl(i).organization_id, X_rsrc_tbl(i).routingstep_id,
                                            X_rsrc_tbl(i).oprn_line_id, X_rsrc_tbl(i).resources, SYSDATE, P_created_by,
                                            P_created_by, SYSDATE, X_rsrc_tbl(i).min_capacity, X_rsrc_tbl(i).max_capacity,
                                            P_login_id,
                                            X_rsrc_tbl(i).text_code, X_rsrc_tbl(i).attribute1, X_rsrc_tbl(i).attribute2,
                                            X_rsrc_tbl(i).attribute3, X_rsrc_tbl(i).attribute4, X_rsrc_tbl(i).attribute5,
                                            X_rsrc_tbl(i).attribute6, X_rsrc_tbl(i).attribute7, X_rsrc_tbl(i).attribute8,
                                            X_rsrc_tbl(i).attribute9, X_rsrc_tbl(i).attribute10, X_rsrc_tbl(i).attribute11,
                                            X_rsrc_tbl(i).attribute12, X_rsrc_tbl(i).attribute13, X_rsrc_tbl(i).attribute14,
                                            X_rsrc_tbl(i).attribute15, X_rsrc_tbl(i).attribute16, X_rsrc_tbl(i).attribute17,
                                            X_rsrc_tbl(i).attribute18, X_rsrc_tbl(i).attribute19, X_rsrc_tbl(i).attribute20,
                                            X_rsrc_tbl(i).attribute21, X_rsrc_tbl(i).attribute22, X_rsrc_tbl(i).attribute23,
                                            X_rsrc_tbl(i).attribute24, X_rsrc_tbl(i).attribute25, X_rsrc_tbl(i).attribute26,
                                            X_rsrc_tbl(i).attribute27, X_rsrc_tbl(i).attribute28, X_rsrc_tbl(i).attribute29,
                                            X_rsrc_tbl(i).attribute30, X_rsrc_tbl(i).attribute_category,
                                            X_rsrc_tbl(i).process_parameter_5, X_rsrc_tbl(i).process_parameter_4,
                                            X_rsrc_tbl(i).process_parameter_3, X_rsrc_tbl(i).process_parameter_2,
                                            X_rsrc_tbl(i).process_parameter_1, X_rsrc_tbl(i).process_um,
                                            X_rsrc_tbl(i).usage_uom, X_rsrc_tbl(i).resource_usage, X_rsrc_tbl(i).process_qty);
    END LOOP;
  END IF;    -- Bug 3037410

  -- Bug 3037410 Mohit Kapoor Added the if statement
  IF p_routing_id is NULL AND p_formula_id is NULL THEN
    FOR i IN 1..X_stepmtl_tbl.count LOOP
      INSERT INTO gmd_recipe_step_materials(recipe_id, formulaline_id, routingstep_id, text_code, creation_date,
                                            created_by, last_updated_by, last_update_date, last_update_login)
      VALUES                               (x_recipe_id, X_stepmtl_tbl(i).formulaline_id, X_stepmtl_tbl(i).routingstep_id,
                                            X_stepmtl_tbl(i).text_code, SYSDATE, P_created_by, P_created_by, SYSDATE, P_login_id);
    END LOOP;
  END IF;   -- Bug 3037410


  IF gmo_setup_grp.is_gmo_enabled = 'Y' THEN
  -- If GMO is enabled, copy the new PI's from old entity to new entity

    IF X_hdr_rec.formula_id = NVL(p_formula_id, X_hdr_rec.formula_id) THEN
      GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name   => 'FORMULA',
	  			           p_entity_id	   => X_hdr_rec.formula_id,
                                           x_name_array    => l_form_source_name_array,
                                           x_key_array     => l_form_source_key_array,
			                   x_return_status => x_return_status);

      FOR i IN 1..l_form_source_key_array.COUNT
      LOOP
        l_source_name_array(i) := l_form_source_name_array(i);
        l_source_key_array(i) := p_recipe_id|| '$' ||l_form_source_key_array(i);
        l_target_name_array(i) := l_form_source_name_array(i);
        l_target_key_array(i) := x_recipe_id|| '$' ||l_form_source_key_array(i);
      END LOOP;
    END IF;

    IF (X_hdr_rec.routing_id IS NOT NULL) AND
       (X_hdr_rec.routing_id = NVL(p_routing_id, X_hdr_rec.routing_id)) THEN
      GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name   => 'ROUTING',
	  			           p_entity_id	   => X_hdr_rec.routing_id,
                                           x_name_array    => l_rout_source_name_array,
                                           x_key_array     => l_rout_source_key_array,
			                   x_return_status => x_return_status);

      j := l_source_name_array.COUNT;
      FOR i IN 1..l_rout_source_key_array.COUNT
      LOOP
        j := j + 1;
        l_source_name_array(j) := l_rout_source_name_array(i);
        l_source_key_array(j) := p_recipe_id|| '$' ||l_rout_source_key_array(i);
        l_target_name_array(j) := l_rout_source_name_array(i);
        l_target_key_array(j) := x_recipe_id|| '$' ||l_rout_source_key_array(i);
      END LOOP;
    END IF;

    GMD_PROCESS_INSTR_UTILS.Copy_Process_Instructions  (
                                p_source_name_array      => l_source_name_array,
                                p_source_key_array       => l_source_key_array,
                                p_target_name_array      => l_target_name_array,
                                p_target_key_array       => l_target_key_array,
			        x_return_status          => x_return_status);
  END IF;

  COMMIT;

  --Getting the default status for the owner orgn code or null orgn of recipe from parameters table
  gmd_api_grp.get_status_details (V_entity_type   => 'RECIPE',
                                  V_orgn_id       => NVL(p_Organization_id, X_hdr_rec.owner_organization_id),
                                  X_entity_status => l_entity_status);
  --Add this code after the call to gmd_routings_pkg.insert_row.
  IF (l_entity_status.entity_status <> 100) THEN
    Gmd_status_pub.modify_status ( p_api_version        => 1
                                 , p_init_msg_list      => TRUE
                                 , p_entity_name        =>'RECIPE'
                                 , p_entity_id          => x_recipe_id
                                 , p_entity_no          => NULL
                                 , p_entity_version     => NULL
                                 , p_to_status          => l_entity_status.entity_status
                                 , p_ignore_flag        => FALSE
                                 , x_message_count      => x_message_count
                                 , x_message_list       => x_message_list
                                 , x_return_status      => X_return_status);
    IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
       FND_MSG_PUB.count_and_get (p_count   => x_message_count
                                 ,p_encoded => FND_API.g_false
                                 ,p_data    => x_message_list);
       X_message_list := FND_MSG_PUB.get (p_msg_index => X_message_count
                                         ,p_encoded => 'F');
       FND_FILE.PUT(FND_FILE.LOG,X_message_list);
       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    END IF; --x_return_status  NOT IN (FND_API.g_ret_sts_success,'P')
  END IF; --l_entity_status.entity_status <> 100
  COMMIT;

END create_new_recipe;

/*======================================================================
--  PROCEDURE :
--   create_formula
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new formula while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    create_formula(P_formula_id, X_formula_id);
--
--
--    07-07-2004   kkillams      Bug 3738941, added new validation to copy the attachments.
--===================================================================== */
PROCEDURE create_new_formula(p_formula_id IN  NUMBER,
                             p_formula_class IN VARCHAR2,
                             p_inactive_ind IN NUMBER,
                             p_new_ingredient IN NUMBER,
                             p_old_ingredient IN NUMBER,
		             p_old_ingr_revision IN VARCHAR2,
			     p_new_ingr_revision IN VARCHAR2,
                             p_owner_id IN NUMBER,
                             x_formula_id OUT NOCOPY NUMBER,
                             x_scale_factor NUMBER,
                             pCreate_Recipe    IN  NUMBER) IS

  X_formula_vers        NUMBER;
  X_row         NUMBER := 0;
  l_rowid               VARCHAR2(18);
  CURSOR Cur_formula_id IS
    SELECT gem5_formula_id_s.NEXTVAL
    FROM   FND_DUAL;
  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   fm_form_mst
    WHERE  formula_id = p_formula_id;
  X_hdr_rec       Cur_get_hdr%ROWTYPE;
  CURSOR Cur_formula_vers IS
    SELECT MAX(formula_vers) + 1
    FROM   fm_form_mst
    WHERE  formula_no = X_hdr_rec.formula_no;

  CURSOR Cur_get_dtl IS
    SELECT *
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id;

  CURSOR Cur_get_status (V_formula_id IN NUMBER) IS
    SELECT formula_status
    FROM   fm_form_mst_b
    WHERE  formula_id = V_formula_id;

  CURSOR Cur_get_auto_recipe(V_orgn_id    fm_form_mst_b.owner_organization_id%TYPE) IS
    SELECT creation_type
    FROM   gmd_recipe_generation
    WHERE  organization_id = V_orgn_id
    AND    creation_type IN (1,2)
    UNION
    SELECT creation_type
    FROM   gmd_recipe_generation
    WHERE  organization_id IS NULL
    AND    creation_type IN (1,2)
    AND    NOT EXISTS (SELECT 1
                         FROM   gmd_recipe_generation
                         WHERE  organization_id = V_orgn_id);
  --kkillams,bug 3738941
  CURSOR cur_form_att(cp_entity_name fnd_attached_documents.entity_name%TYPE,
                      cp_pk1_value   fnd_attached_documents.pk1_value%TYPE) IS
    SELECT 1
    FROM  fnd_attached_documents fad
    WHERE fad.entity_name = cp_entity_name
    AND   fad.pk1_value   = cp_pk1_value;

  l_formulaline_id   fm_matl_dtl.formulaline_id%TYPE;
  l_ingr_id	     fm_matl_dtl.inventory_item_id%TYPE;
  l_ingr_revision    fm_matl_dtl.revision%TYPE;
  l_dummy            NUMBER;

  TYPE detail_tab IS TABLE OF Cur_get_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
  X_dtl_tbl detail_tab;
  l_entity_status       gmd_api_grp.status_rec_type;
  X_return_status       VARCHAR2(1);
  X_message_count       NUMBER;
  X_message_list        VARCHAR2(2000);
  FORM_STATUS_ERR       EXCEPTION;
  X_formula_status      VARCHAR2(40);
  X_recipe_no           VARCHAR2(32);
  X_recipe_version      NUMBER;
  X_creation_type       NUMBER(5);

  l_gmo_enabled         VARCHAR2(1);
  l_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;

  -- Bug No.5985327 - Start
  --Created new variables to retrieve the output quantity from GMD_COMMON_VAL.calculate_total_qty procedure

  x_return_status_for_calc VARCHAR2(20);
  X_msg_cnt       NUMBER;
  X_msg_dat       VARCHAR2(100);
  X_status        VARCHAR2(1);
  l_output_qty   NUMBER;
  l_input_qty       NUMBER;
  l_uom           VARCHAR2(4);
  --Bug No.5985327 - End

  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  FOR get_rec IN Cur_get_dtl LOOP
    X_row := X_row + 1;
    X_dtl_tbl(X_row) := get_rec;
    IF (get_rec.inventory_item_id = p_old_ingredient) THEN
      x_dtl_tbl(x_row).qty := x_dtl_tbl(x_row).qty * nvl(x_scale_factor,1);
    END IF;
  END LOOP;

  OPEN Cur_formula_vers;
  FETCH Cur_formula_vers INTO X_formula_vers;
  CLOSE Cur_formula_vers;

  OPEN Cur_formula_id;
  FETCH Cur_formula_id INTO x_formula_id;
  CLOSE Cur_formula_id;

  /* Check if GMO is enabled */
  l_gmo_enabled :=  gmo_setup_grp.is_gmo_enabled;
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'FORMULA',
				         p_entity_id	=> p_formula_id,
                                         x_name_array   => l_source_name_array,
                                         x_key_array    => l_source_key_array,
			                 x_return_status => x_return_status);
  END IF;

  /* Insert header record */
  fm_form_mst_mls.insert_row(X_ROWID              => l_rowid,
                             X_FORMULA_ID               => X_formula_id,
                             X_MASTER_FORMULA_ID        => NULL,
                             X_OWNER_ORGANIZATION_ID    => X_hdr_rec.owner_organization_id,
                             X_TEXT_CODE                => X_hdr_rec.text_code,
                             X_DELETE_MARK              => 0,
                             X_TOTAL_INPUT_QTY          => 0,
                             X_PROJECT_ID               => X_hdr_rec.project_id,
                             X_TOTAL_OUTPUT_QTY         => 0,
                             X_FORMULA_STATUS           => 100,
                             X_OWNER_ID                 => NVL(p_owner_id,X_hdr_rec.owner_id),
                             X_FORMULA_NO               => X_hdr_rec.formula_no,
                             X_FORMULA_VERS             => X_formula_vers,
                             X_FORMULA_TYPE             => X_hdr_rec.formula_type,
                             X_IN_USE                   => 0,
                             X_INACTIVE_IND             => NVL(p_inactive_ind,0),
                             X_SCALE_TYPE               => X_hdr_rec.scale_type,
                             X_FORMULA_CLASS            => p_formula_class,
                             X_FMCONTROL_CLASS          => X_hdr_rec.fmcontrol_class,
                             X_FORMULA_DESC1            => X_hdr_rec.formula_desc1,
                             X_FORMULA_DESC2            => X_hdr_rec.formula_desc2,
                             X_CREATION_DATE            => SYSDATE,
                             X_CREATED_BY               => P_created_by,
                             X_LAST_UPDATE_DATE         => SYSDATE,
                             X_LAST_UPDATED_BY          => P_created_by,
                             X_LAST_UPDATE_LOGIN        => P_login_id,
                             X_ATTRIBUTE_CATEGORY       => X_hdr_rec.attribute_category,
                             X_ATTRIBUTE1               => X_hdr_rec.attribute1,
                             X_ATTRIBUTE2               => X_hdr_rec.attribute2,
                             X_ATTRIBUTE3               => X_hdr_rec.attribute3,
                             X_ATTRIBUTE4               => X_hdr_rec.attribute4,
                             X_ATTRIBUTE5               => X_hdr_rec.attribute5,
                             X_ATTRIBUTE6               => X_hdr_rec.attribute6,
                             X_ATTRIBUTE7               => X_hdr_rec.attribute7,
                             X_ATTRIBUTE8               => X_hdr_rec.attribute8,
                             X_ATTRIBUTE9               => X_hdr_rec.attribute9,
                             X_ATTRIBUTE10              => X_hdr_rec.attribute10,
                             X_ATTRIBUTE11              => X_hdr_rec.attribute11,
                             X_ATTRIBUTE12              => X_hdr_rec.attribute12,
                             X_ATTRIBUTE13              => X_hdr_rec.attribute13,
                             X_ATTRIBUTE14              => X_hdr_rec.attribute14,
                             X_ATTRIBUTE15              => X_hdr_rec.attribute15,
                             X_ATTRIBUTE16              => X_hdr_rec.attribute16,
                             X_ATTRIBUTE17              => X_hdr_rec.attribute17,
                             X_ATTRIBUTE18              => X_hdr_rec.attribute18,
                             X_ATTRIBUTE19              => X_hdr_rec.attribute19,
                             X_ATTRIBUTE20              => X_hdr_rec.attribute20,
                             X_ATTRIBUTE21              => X_hdr_rec.attribute21,
                             X_ATTRIBUTE22              => X_hdr_rec.attribute22,
                             X_ATTRIBUTE23              => X_hdr_rec.attribute23,
                             X_ATTRIBUTE24              => X_hdr_rec.attribute24,
                             X_ATTRIBUTE25              => X_hdr_rec.attribute25,
                             X_ATTRIBUTE26              => X_hdr_rec.attribute26,
                             X_ATTRIBUTE27              => X_hdr_rec.attribute27,
                             X_ATTRIBUTE28              => X_hdr_rec.attribute28,
                             X_ATTRIBUTE29              => X_hdr_rec.attribute29,
                             X_ATTRIBUTE30              => X_hdr_rec.attribute30,
                             X_YIELD_UOM                => x_hdr_rec.yield_uom,
                             X_AUTO_PRODUCT_CALC        => x_hdr_rec.auto_product_calc);
     --kkillams, Bug 3738941
     --Added following validation to copy the attachments
     OPEN cur_form_att('FM_FORM_MST_B',to_char(p_formula_id));
     FETCH cur_form_att INTO l_dummy;
     IF cur_form_att%FOUND THEN
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
          X_from_entity_name              => 'FM_FORM_MST_B',
          X_from_pk1_value                => TO_CHAR(p_formula_id),
          X_from_pk2_value                => NULL,
          X_from_pk3_value                => NULL,
          X_from_pk4_value                => NULL,
          X_from_pk5_value                => NULL,
          X_to_entity_name                => 'FM_FORM_MST_B',
          X_to_pk1_value                  => TO_CHAR(X_formula_id),
          X_to_pk2_value                  => NULL,
          X_to_pk3_value                  => NULL,
          X_to_pk4_value                  => NULL,
          X_to_pk5_value                  => NULL,
          X_created_by                    => FND_GLOBAL.USER_ID,
          X_last_update_login             => FND_GLOBAL.LOGIN_ID,
          X_program_application_id        => NULL,
          X_program_id                    => NULL,
          X_request_id                    => NULL );
     END IF;
     CLOSE cur_form_att;
  FOR i IN 1..X_dtl_tbl.count LOOP

    IF ((X_dtl_tbl(i).inventory_item_id = p_old_ingredient) AND (NVL(X_dtl_tbl(i).revision, -1) = NVL(p_old_ingr_revision, -1)) ) THEN
	l_ingr_id	:= p_new_ingredient;
	l_ingr_revision := p_new_ingr_revision;
    ELSE
	l_ingr_id	:= X_dtl_tbl(i).inventory_item_id;
	l_ingr_revision := X_dtl_tbl(i).revision;
    END IF;

    INSERT INTO fm_matl_dtl(formulaline_id, formula_id, line_type, line_no, inventory_item_id, revision, organization_id,
                            qty, detail_uom, release_type, scrap_factor, scale_type, cost_alloc,
                            phantom_type, rework_type, text_code, last_updated_by, created_by,
                            last_update_date, creation_date, last_update_login, attribute1,
                            attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
                            attribute8, attribute9, attribute10, attribute11, attribute12,
                            attribute13, attribute14, attribute15, attribute16, attribute17,
                            attribute18, attribute19, attribute20, attribute21, attribute22,
                            attribute23, attribute24, attribute25, attribute26, attribute27,
                            attribute28, attribute29, attribute30, attribute_category, tpformula_id,
                            scale_multiple, contribute_yield_ind, scale_uom, contribute_step_qty_ind,
                            scale_rounding_variance)
    VALUES                 (gem5_formulaline_id_s.NEXTVAL, X_formula_id, X_dtl_tbl(i).line_type, X_dtl_tbl(i).line_no,
                            l_ingr_id, l_ingr_revision, X_dtl_tbl(i).organization_id,
                            X_dtl_tbl(i).qty, X_dtl_tbl(i).detail_uom, X_dtl_tbl(i).release_type,
                            X_dtl_tbl(i).scrap_factor, X_dtl_tbl(i).scale_type, X_dtl_tbl(i).cost_alloc,
                            X_dtl_tbl(i).phantom_type, X_dtl_tbl(i).rework_type, X_dtl_tbl(i).text_code,
                            P_created_by, P_created_by, SYSDATE, SYSDATE, P_login_id, X_dtl_tbl(i).attribute1,
                            X_dtl_tbl(i).attribute2, X_dtl_tbl(i).attribute3, X_dtl_tbl(i).attribute4,
                            X_dtl_tbl(i).attribute5, X_dtl_tbl(i).attribute6, X_dtl_tbl(i).attribute7,
                            X_dtl_tbl(i).attribute8, X_dtl_tbl(i).attribute9, X_dtl_tbl(i).attribute10,
                            X_dtl_tbl(i).attribute11, X_dtl_tbl(i).attribute12, X_dtl_tbl(i).attribute13,
                            X_dtl_tbl(i).attribute14, X_dtl_tbl(i).attribute15, X_dtl_tbl(i).attribute16,
                            X_dtl_tbl(i).attribute17, X_dtl_tbl(i).attribute18, X_dtl_tbl(i).attribute19,
                            X_dtl_tbl(i).attribute20, X_dtl_tbl(i).attribute21, X_dtl_tbl(i).attribute22,
                            X_dtl_tbl(i).attribute23, X_dtl_tbl(i).attribute24, X_dtl_tbl(i).attribute25,
                            X_dtl_tbl(i).attribute26, X_dtl_tbl(i).attribute27, X_dtl_tbl(i).attribute28,
                            X_dtl_tbl(i).attribute29, X_dtl_tbl(i).attribute30, X_dtl_tbl(i).attribute_category,
                            X_dtl_tbl(i).tpformula_id, X_dtl_tbl(i).scale_multiple, X_dtl_tbl(i).contribute_yield_ind,
                            X_dtl_tbl(i).scale_uom, X_dtl_tbl(i).contribute_step_qty_ind,
                            X_dtl_tbl(i).scale_rounding_variance) RETURNING formulaline_id INTO l_formulaline_id;
     --kkillams, Bug 3738941
     --Added following validation to copy the attachments
     OPEN cur_form_att('FM_MATL_DTL',to_char(X_dtl_tbl(i).formulaline_id));
     FETCH cur_form_att INTO l_dummy;
     IF cur_form_att%FOUND THEN
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
          X_from_entity_name              => 'FM_MATL_DTL',
          X_from_pk1_value                => TO_CHAR(X_dtl_tbl(i).formulaline_id),
          X_from_pk2_value                => NULL,
          X_from_pk3_value                => NULL,
          X_from_pk4_value                => NULL,
          X_from_pk5_value                => NULL,
          X_to_entity_name                => 'FM_MATL_DTL',
          X_to_pk1_value                  => TO_CHAR(l_formulaline_id),
          X_to_pk2_value                  => NULL,
          X_to_pk3_value                  => NULL,
          X_to_pk4_value                  => NULL,
          X_to_pk5_value                  => NULL,
          X_created_by                    => FND_GLOBAL.USER_ID,
          X_last_update_login             => FND_GLOBAL.LOGIN_ID,
          X_program_application_id        => NULL,
          X_program_id                    => NULL,
          X_request_id                    => NULL );
       END IF;
       CLOSE cur_form_att;
  END LOOP;

  -- If GMO is enabled, copy the new PI's from old entity to new entity
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'FORMULA',
				         p_entity_id	=> x_formula_id,
                                         x_name_array   => l_target_name_array,
                                         x_key_array    => l_target_key_array,
			                 x_return_status => x_return_status);

    GMD_PROCESS_INSTR_UTILS.Copy_Process_Instructions  (
                                p_source_name_array      => l_source_name_array,
                                p_source_key_array       => l_source_key_array,
                                p_target_name_array      => l_target_name_array,
                                p_target_key_array       => l_target_key_array,
			        x_return_status          => x_return_status);
  END IF;

  COMMIT;

  --Bug No.5985327 - Start

   GMD_COMMON_VAL.calculate_total_qty(formula_id       => x_formula_id,
                  		      x_product_qty    => l_output_qty ,
                  		      x_ingredient_qty => l_input_qty ,
                  		      x_uom            => l_uom ,
                  		      x_return_status  => x_return_status_for_calc ,
                  		      x_msg_count      => X_msg_cnt ,
                  		      x_msg_data       => x_msg_dat );

   UPDATE fm_form_mst_b
   SET total_output_qty = l_output_qty,
       total_input_qty  = l_input_qty,
       formula_uom      = l_uom
   WHERE formula_id     = X_formula_id;

    COMMIT;
   --Bug No.5985327 - End

  --Getting the default status for the owner orgn code or null orgn of recipe from parameters table
  gmd_api_grp.get_status_details (V_entity_type   => 'FORMULA',
                                  V_orgn_id       => X_hdr_rec.owner_organization_id,
                                  X_entity_status => l_entity_status);

  IF (l_entity_status.entity_status <> 100) THEN
    gmd_status_pub.modify_status ( p_api_version        => 1
                                 , p_init_msg_list      => TRUE
                                 , p_entity_name        => 'FORMULA'
                                 , p_entity_id          => X_formula_id
                                 , p_entity_no          => NULL
                                 , p_entity_version     => NULL
                                 , p_to_status          => l_entity_status.entity_status
                                 , p_ignore_flag        => FALSE
                                 , x_message_count      => x_message_count
                                 , x_message_list       => x_message_list
                                 , x_return_status      => X_return_status);
    IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
      RAISE form_status_err;
    END IF; --x_return_status
  END IF; --l_entity_status.entity_status <> 100

  OPEN Cur_get_status (X_formula_id);
  FETCH Cur_get_status INTO X_formula_status;
  CLOSE Cur_get_status;

  IF (X_formula_status = l_entity_status.entity_status) THEN
    OPEN Cur_get_auto_recipe (X_hdr_rec.owner_organization_id);
    FETCH Cur_get_auto_recipe INTO X_creation_type;
    CLOSE Cur_get_auto_recipe;
    IF (NVL(X_creation_type, 0) = 1) OR
       (NVL(X_creation_type, 0) = 2 AND pCreate_Recipe = 1) THEN
      GMD_RECIPE_GENERATE.recipe_generate(X_hdr_rec.owner_organization_id, X_formula_id,
                                          X_return_status, X_recipe_no, X_recipe_version);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE form_status_err;
      ELSIF (X_recipe_no IS NOT NULL) AND
            (X_recipe_version IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_AUTOMATIC');
        FND_MESSAGE.SET_TOKEN('NAME', x_recipe_no);
        FND_MESSAGE.SET_TOKEN('VERSION', x_recipe_version);
        FND_FILE.PUT(FND_FILE.LOG, FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END IF;
    END IF; /*IF (NVL(X_creation_type, 0) = 1) OR*/
  END IF;/* IF (X_formula_status = l_entity_status.entity_status) */
  COMMIT;
EXCEPTION
  WHEN form_status_err THEN
    FND_MSG_PUB.count_and_get (p_count   => x_message_count
                              ,p_encoded => FND_API.g_false
                              ,p_data    => x_message_list);
    X_message_list := FND_MSG_PUB.get (p_msg_index => X_message_count
                                      ,p_encoded => 'F');
    FND_FILE.PUT(FND_FILE.LOG,X_message_list);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    ROLLBACK;
END create_new_formula;

END gmd_search_replace_vers;

/
