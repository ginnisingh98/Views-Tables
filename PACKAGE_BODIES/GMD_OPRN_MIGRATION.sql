--------------------------------------------------------
--  DDL for Package Body GMD_OPRN_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPRN_MIGRATION" AS
 /* $Header: GMDOMIGB.pls 120.1 2006/07/18 14:17:05 kmotupal noship $ */

 PROCEDURE INSERT_GMD_OPERATIONS IS

   CURSOR Cur_Formula_Id(prouting_id NUMBER) IS
     SELECT formula_Id
     FROM   fm_form_eff_bak
     WHERE  routing_id = prouting_id;

   CURSOR Cur_Routing_id(poprn_Id NUMBER) IS
     SELECT routing_Id
     FROM   fm_rout_dtl
     WHERE  oprn_id = poprn_Id;

   /*Bug#3601848 - Thomas Daniel */
   /*Added exists clause as the migration was getting rerun for the customer */
   /*upgrading from 11.5.9 to 11.5.10 and the deleted activity and resources */
   /*were getting added */
   CURSOR Cur_get_oprn_id IS
     SELECT *
     FROM gmd_operations_b o
     WHERE operation_status  IS NULL;

   l_orgn_code        VARCHAR2(6);
   l_oprn_Id          NUMBER;
   l_operation_status GMD_STATUS.status_code%TYPE := '700';
   l_formula_id       NUMBER;
   l_return_val       NUMBER;
   l_routing_id       NUMBER;
   error_msg          VARCHAR2(2000);

 BEGIN
   FOR oprn_rout_rec IN Cur_get_oprn_ID LOOP
     BEGIN
       l_operation_status := '700'; -- Bug 5383916
       /* To determine the operation status - which by default is 700 */
       FOR get_routing_rec IN Cur_Routing_id(oprn_rout_rec.oprn_id)  LOOP
         FOR get_formula_rec IN Cur_Formula_id(get_routing_rec.routing_id) LOOP
           l_return_val := GMDFMVAL_PUB.locked_effectivity_val(get_formula_rec.formula_Id);
           IF l_return_val <> 0 THEN
              l_operation_status := '900';
              EXIT;
           ELSE
              l_operation_status := '700';
           END IF;
         END LOOP;
       END LOOP;

       /* If the operation is inactive or it is marked for purge
          then we make it obsoleted */
       IF ((oprn_rout_rec.inactive_ind = 1) OR (oprn_rout_rec.delete_mark = 1)) THEN
          l_operation_status := '1000';
       END IF;

       /* Update the gmd_operations_b and tl table */
       UPDATE gmd_operations_b
       SET    operation_status     = l_operation_status,
              effective_start_date = oprn_rout_rec.creation_date,
              owner_orgn_code      =
                   fnd_profile.value_specific('GEMMS_DEFAULT_ORGN',oprn_rout_rec.created_by)
       WHERE  oprn_id = oprn_rout_rec.oprn_id;

       /*Bug#3601848 - Thomas Daniel */
       /*Added call to insert the operation components passing the operation id */
       /*to avoid a blind population of all the activities */
       Insert_GMD_Operation_Comps (p_oprn_id => oprn_rout_rec.oprn_id);

     EXCEPTION
       WHEN OTHERS THEN
          error_msg := SQLERRM;
          GMD_RECIPE_MIGRATION.insert_message (p_source_table => 'FM_OPRN_MST'
                                   ,p_target_table => 'GMD_OPERATIONS'
                                   ,p_source_id    => oprn_rout_rec.oprn_id
                                   ,p_target_id    => oprn_rout_rec.oprn_id
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'U');
     END;
   END LOOP; /* for insert in gmd operations */
 END INSERT_GMD_OPERATIONS;

 PROCEDURE INSERT_GMD_OPERATION_COMPS (P_Oprn_id IN NUMBER) IS
   /*Bug#3601848 - Thomas Daniel */
   /*Added oprn_id as parameter to this procedure and restricting the activities */
   /*to only those for which the operation was not migrated earlier */
   CURSOR get_activity IS
     SELECT *
     FROM   fm_oprn_dtl_bak
     WHERE  oprn_id = P_oprn_id
     ORDER BY activity;

   v_activity     varchar2(16);
   v_oprn_line_id number := 0;
 BEGIN
   OPEN get_activity;
   FETCH get_activity into v_activity_rec;
   WHILE ( get_activity % FOUND ) LOOP
   /* activity has been replaced with oprn_line_id to insert even same activity */
     IF (v_activity_rec.oprn_line_id = v_oprn_line_id) THEN
        insert_operation_resource(P_oprn_id,v_oprn_line_id);
     ELSE
        insert_operation_activity;
        v_activity        := v_activity_rec.activity;
        v_oprn_line_id    := v_activity_rec.oprn_line_id;
        insert_operation_resource(P_oprn_id,v_oprn_line_id);
     END IF;
     FETCH get_activity INTO v_activity_rec;

   END LOOP;
   CLOSE get_activity;
   /*Bug#3601848 - Thomas Daniel */
   /*Commented the commit as this procedure is now being called from insert operation*/
   -- COMMIT;
 END INSERT_GMD_OPERATION_COMPS;

 PROCEDURE INSERT_OPERATION_ACTIVITY IS
   error_msg VARCHAR2(240);
 BEGIN
   INSERT INTO gmd_operation_activities
   (oprn_line_id
   ,oprn_id
   ,activity
   ,offset_interval
   ,activity_factor
   ,delete_mark
   ,text_code
   ,creation_date
   ,created_by
   ,last_updated_by
   ,last_update_date
   ,last_update_login
   ,attribute1
   ,attribute2
   ,attribute3
   ,attribute4
   ,attribute5
   ,attribute6
   ,attribute7
   ,attribute8
   ,attribute9
   ,attribute10
   ,attribute11
   ,attribute12
   ,attribute13
   ,attribute14
   ,attribute15
   ,attribute16
   ,attribute17
   ,attribute18
   ,attribute19
   ,attribute20
   ,attribute21
   ,attribute22
   ,attribute23
   ,attribute24
   ,attribute25
   ,attribute26
   ,attribute27
   ,attribute28
   ,attribute29
   ,attribute30
   ,attribute_category)
   SELECT v_activity_rec.oprn_line_id
   ,v_activity_rec.oprn_id
   ,v_activity_rec.activity
   ,v_activity_rec.offset_interval
   ,1  /* Activity Factor */
   ,0  /* Delete mark */
   ,v_activity_rec.text_code
   ,v_activity_rec.creation_date
   ,v_activity_rec.created_by
   ,v_activity_rec.last_updated_by
   ,v_activity_rec.last_update_date
   ,v_activity_rec.last_update_login
   ,v_activity_rec.attribute1
   ,v_activity_rec.attribute2
   ,v_activity_rec.attribute3
   ,v_activity_rec.attribute4
   ,v_activity_rec.attribute5
   ,v_activity_rec.attribute6
   ,v_activity_rec.attribute7
   ,v_activity_rec.attribute8
   ,v_activity_rec.attribute9
   ,v_activity_rec.attribute10
   ,v_activity_rec.attribute11
   ,v_activity_rec.attribute12
   ,v_activity_rec.attribute13
   ,v_activity_rec.attribute14
   ,v_activity_rec.attribute15
   ,v_activity_rec.attribute16
   ,v_activity_rec.attribute17
   ,v_activity_rec.attribute18
   ,v_activity_rec.attribute19
   ,v_activity_rec.attribute20
   ,v_activity_rec.attribute21
   ,v_activity_rec.attribute22
   ,v_activity_rec.attribute23
   ,v_activity_rec.attribute24
   ,v_activity_rec.attribute25
   ,v_activity_rec.attribute26
   ,v_activity_rec.attribute27
   ,v_activity_rec.attribute28
   ,v_activity_rec.attribute29
   ,v_activity_rec.attribute30
   ,v_activity_rec.attribute_category
  FROM dual
  WHERE NOT EXISTS (SELECT 1
                    FROM gmd_operation_activities
                    WHERE oprn_line_id = v_activity_rec.oprn_line_id);
 EXCEPTION
    WHEN OTHERS THEN
      error_msg := SQLERRM;
      GMD_RECIPE_MIGRATION.insert_message (p_source_table => 'FM_OPRN_DTL'
                                   ,p_target_table => 'GMD_OPERATION_ACTIVITIES'
                                   ,p_source_id    => v_activity_rec.activity
                                   ,p_target_id    => v_activity_rec.activity
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'U');
 END INSERT_OPERATION_ACTIVITY;


 PROCEDURE INSERT_OPERATION_RESOURCE(p_oprn_id NUMBER,p_oprn_line_id NUMBER) IS
   CURSOR get_resource_capacity IS
     SELECT min_capacity
            ,max_capacity
            ,capacity_uom
     FROM   cr_rsrc_dtl
     WHERE  resources = v_activity_rec.resources;

   v_min_capacity NUMBER;
   v_max_capacity NUMBER;
   v_capacity_uom varchar2(4);
   v_process_uom varchar2(4);
   error_msg  varchar2(240);
   invalid_err exception;--BUG#3316385
 BEGIN
    OPEN get_resource_capacity;
    FETCH get_resource_capacity INTO
          v_min_capacity
          ,v_max_capacity
          ,v_capacity_uom;
    CLOSE get_resource_capacity;

    SELECT PROCESS_QTY_UM
    INTO   v_process_uom
    FROM   gmd_operations
    WHERE  oprn_id = p_oprn_id;

    --BEGIN BUG#3316385
    IF v_activity_rec.process_qty = 0 AND v_activity_rec.resource_usage <> 0
    AND v_activity_rec.scale_type in (1,2) THEN
      RAISE invalid_err;
    END IF;
    --END BUG#3316385
    INSERT INTO gmd_operation_resources (
          oprn_line_id
         ,resources
         ,resource_usage
         ,resource_count
         ,usage_um
         ,process_qty
         ,process_uom /* Process UOM */
         ,prim_rsrc_ind
         ,scale_type
         ,cost_analysis_code
         ,cost_cmpntcls_id
         ,offset_interval
         ,delete_mark
         ,text_code
         ,Min_Capacity
         ,Max_capacity
         ,capacity_uom /* Capacity UOM */
         ,attribute_category
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
         ,attribute16
         ,attribute17
         ,attribute18
         ,attribute19
         ,attribute20
         ,attribute21
         ,attribute22
         ,attribute23
         ,attribute24
         ,attribute25
         ,attribute26
         ,attribute27
         ,attribute28
         ,attribute29
         ,attribute30
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,Process_parameter_1
         ,Process_parameter_2
         ,Process_parameter_3
         ,Process_parameter_4
         ,Process_parameter_5)
    SELECT p_oprn_line_id
         ,v_activity_rec.resources
         ,v_activity_rec.resource_usage
         ,v_activity_rec.resource_count
         ,v_activity_rec.usage_um
         ,v_activity_rec.process_qty
         ,v_process_uom /* Process UOM */
         ,v_activity_rec.prim_rsrc_ind
         ,v_activity_rec.scale_type
         ,v_activity_rec.cost_analysis_code
         ,v_activity_rec.cost_cmpntcls_id
         ,v_activity_rec.offset_interval
         ,0 /* delete mark */
         ,v_activity_rec.text_code
         ,v_min_capacity /* Min Capacity */
         ,v_max_capacity /* Max capacity */
         ,v_capacity_uom /* Capacity UOM */
         ,v_activity_rec.attribute_category
         ,v_activity_rec.attribute1
         ,v_activity_rec.attribute2
         ,v_activity_rec.attribute3
         ,v_activity_rec.attribute4
         ,v_activity_rec.attribute5
         ,v_activity_rec.attribute6
         ,v_activity_rec.attribute7
         ,v_activity_rec.attribute8
         ,v_activity_rec.attribute9
         ,v_activity_rec.attribute10
         ,v_activity_rec.attribute11
         ,v_activity_rec.attribute12
         ,v_activity_rec.attribute13
         ,v_activity_rec.attribute14
         ,v_activity_rec.attribute15
         ,v_activity_rec.attribute16
         ,v_activity_rec.attribute17
         ,v_activity_rec.attribute18
         ,v_activity_rec.attribute19
         ,v_activity_rec.attribute20
         ,v_activity_rec.attribute21
         ,v_activity_rec.attribute22
         ,v_activity_rec.attribute23
         ,v_activity_rec.attribute24
         ,v_activity_rec.attribute25
         ,v_activity_rec.attribute26
         ,v_activity_rec.attribute27
         ,v_activity_rec.attribute28
         ,v_activity_rec.attribute29
         ,v_activity_rec.attribute30
         ,v_activity_rec.creation_date
         ,v_activity_rec.created_by
         ,v_activity_rec.last_update_date
         ,v_activity_rec.last_updated_by
         ,v_activity_rec.last_update_login
         ,NULL /* Process parameter 1 */
         ,NULL /* Process parameter 2 */
         ,NULL /* Process parameter 3 */
         ,NULL /* Process parameter 4 */
         ,NULL /* Process parameter 5 */
    FROM dual
    WHERE NOT EXISTS (SELECT 1
                      FROM gmd_operation_resources
                      WHERE oprn_line_id = p_oprn_line_id AND
                            resources    = v_activity_rec.resources);

  EXCEPTION
    --BEGIN BUG#3316385
    WHEN invalid_err THEN
      error_msg := 'Invalid Combination of Process Quantity,Usage and Scale Type';
      GMD_RECIPE_MIGRATION.insert_message (p_source_table => 'FM_OPRN_DTL'
                                   ,p_target_table => 'GMD_OPERATION_RESOURCES'
                                   ,p_source_id    => v_activity_rec.resources
                                   ,p_target_id    => v_activity_rec.resources
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'U');
    --END BUG#3316385
    WHEN OTHERS THEN
      error_msg := SQLERRM;
      GMD_RECIPE_MIGRATION.insert_message (p_source_table => 'FM_OPRN_DTL'
                                   ,p_target_table => 'GMD_OPERATION_RESOURCES'
                                   ,p_source_id    => v_activity_rec.resources
                                   ,p_target_id    => v_activity_rec.resources
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'U');
 END INSERT_OPERATION_RESOURCE;

 END GMD_OPRN_MIGRATION;

/
