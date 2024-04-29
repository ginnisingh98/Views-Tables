--------------------------------------------------------
--  DDL for Package Body WMS_OP_PLAN_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OP_PLAN_DETAILS_PKG" AS
/* $Header: WMSOPLDB.pls 120.0 2005/05/25 08:53:00 appldev noship $ */
--
PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT nocopy VARCHAR2
  ,x_operation_plan_detail_id 	    IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_operation_plan_id              IN     NUMBER
  ,x_operation_type                 IN     NUMBER
  ,x_operation_sequence             IN     NUMBER
  ,x_bulk_pick_type                 IN     NUMBER
  ,x_drop_lpn_option                IN     NUMBER
  ,x_wait_for_group_completion      IN     VARCHAR2
  ,x_system_dispatched              IN     VARCHAR2
  ,x_op_segment_completed           IN     VARCHAR2
  ,x_zone_selection_criteria        IN     NUMBER
  ,x_pre_specified_zone_id          IN     NUMBER
  ,x_zone_selection_api_id          IN     NUMBER
  ,x_sub_selection_criteria         IN     NUMBER
  ,x_pre_specified_sub_code         IN     VARCHAR2
  ,x_sub_selection_api_id           IN     NUMBER
  ,x_loc_selection_criteria         IN     NUMBER
  ,x_pre_specified_loc_id           IN     NUMBER
  ,x_loc_selection_api_id           IN     NUMBER
  ,x_activity_segment               IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  --,x_task_mode                      IN     NUMBER  (out of scope for patchset 'J')
  --,x_operation_method               IN     NUMBER  (out of scope for patchset 'J')
  ,x_lpn_selection_criteria         IN     NUMBER
  ,x_lpn_selection_api_id           IN     NUMBER
  --,x_catch_secondary_qty            IN     NUMBER  (out of scope for patchset 'J')
  ,x_loc_mtrl_grp_rule_id           IN     NUMBER
  ,x_lpn_mtrl_grp_rule_id           IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_is_in_inventory                IN     VARCHAR2
  ,x_subsequent_op_plan_id          IN     NUMBER
  ,x_consolidation_method_id            IN     NUMBER
  )IS
    CURSOR C IS SELECT ROWID FROM WMS_OP_PLAN_DETAILS
      WHERE operation_plan_detail_id = x_operation_plan_detail_id
      AND   operation_plan_id = x_operation_plan_id;
BEGIN
   INSERT INTO WMS_OP_PLAN_DETAILS (
       operation_plan_id
      ,operation_plan_detail_id
      ,operation_type
      ,operation_sequence
      ,bulk_pick_type
      ,drop_lpn_option
      ,wait_for_group_completion
      ,system_dispatched
      ,op_segment_completed
      ,zone_selection_criteria
      ,pre_specified_zone_id
      ,zone_selection_api_id
      ,sub_selection_criteria
      ,pre_specified_sub_code
      ,sub_selection_api_id
      ,loc_selection_criteria
      ,pre_specified_loc_id
      ,loc_selection_api_id
      ,activity_segment
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
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
      --,task_mode  (out of scope for patchset 'J')
      --,operation_method  (out of scope for patchset 'J')
      ,lpn_selection_criteria
      ,lpn_selection_api_id
      --,catch_secondary_qty  (out of scope for patchset 'J')
      ,loc_mtrl_grp_rule_id
      ,lpn_mtrl_grp_rule_id
      ,organization_id
     ,is_in_inventory
     ,subsequent_op_plan_id
     ,consolidation_method_id
    ) values (
       x_operation_plan_id
      ,x_operation_plan_detail_id
      ,x_operation_type
      ,x_operation_sequence
      ,x_bulk_pick_type
      ,x_drop_lpn_option
      ,x_wait_for_group_completion
      ,x_system_dispatched
      ,x_op_segment_completed
      ,x_zone_selection_criteria
      ,x_pre_specified_zone_id
      ,x_zone_selection_api_id
      ,x_sub_selection_criteria
      ,x_pre_specified_sub_code
      ,x_sub_selection_api_id
      ,x_loc_selection_criteria
      ,x_pre_specified_loc_id
      ,x_loc_selection_api_id
      ,x_activity_segment
      ,x_created_by
      ,x_creation_date
      ,x_last_updated_by
      ,x_last_update_date
      ,x_last_update_login
      ,x_attribute_category
      ,x_attribute1
      ,x_attribute2
      ,x_attribute3
      ,x_attribute4
      ,x_attribute5
      ,x_attribute6
      ,x_attribute7
      ,x_attribute8
      ,x_attribute9
      ,x_attribute10
      ,x_attribute11
      ,x_attribute12
      ,x_attribute13
      ,x_attribute14
      ,x_attribute15
      --,x_task_mode  (out of scope for patchset 'J')
      --,x_operation_method  (out of scope for patchset 'J')
      ,x_lpn_selection_criteria
      ,x_lpn_selection_api_id
      --,x_catch_secondary_qty  (out of scope for patchset 'J')
      ,x_loc_mtrl_grp_rule_id
      ,x_lpn_mtrl_grp_rule_id
      ,x_organization_id
      ,x_is_in_inventory
     ,x_subsequent_op_plan_id
     ,x_consolidation_method_id
   );

  OPEN C;
  FETCH C INTO x_rowid;
  IF (C%NOTFOUND) THEN
     CLOSE C;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END INSERT_ROW;
--
--
PROCEDURE UPDATE_ROW (
   x_operation_plan_detail_id 	    IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_operation_plan_id              IN     NUMBER
  ,x_operation_type                 IN     NUMBER
  ,x_operation_sequence             IN     NUMBER
  ,x_bulk_pick_type                 IN     NUMBER
  ,x_drop_lpn_option                IN     NUMBER
  ,x_wait_for_group_completion      IN     VARCHAR2
  ,x_system_dispatched              IN     VARCHAR2
  ,x_op_segment_completed           IN     VARCHAR2
  ,x_zone_selection_criteria        IN     NUMBER
  ,x_pre_specified_zone_id          IN     NUMBER
  ,x_zone_selection_api_id          IN     NUMBER
  ,x_sub_selection_criteria         IN     NUMBER
  ,x_pre_specified_sub_code         IN     VARCHAR2
  ,x_sub_selection_api_id           IN     NUMBER
  ,x_loc_selection_criteria         IN     NUMBER
  ,x_pre_specified_loc_id           IN     NUMBER
  ,x_loc_selection_api_id           IN     NUMBER
  ,x_activity_segment               IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  --,x_task_mode                      IN     NUMBER  (out of scope for patchset 'J')
  --,x_operation_method               IN     NUMBER  (out of scope for patchset 'J')
  ,x_lpn_selection_criteria         IN     NUMBER
  ,x_lpn_selection_api_id           IN     NUMBER
  --,x_catch_secondary_qty            IN     NUMBER  (out of scope for patchset 'J')
  ,x_loc_mtrl_grp_rule_id           IN     NUMBER
  ,x_lpn_mtrl_grp_rule_id           IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_is_in_inventory                IN     VARCHAR2
  ,x_subsequent_op_plan_id          IN     NUMBER
  ,x_consolidation_method_id            IN     NUMBER
  )IS
BEGIN
   UPDATE WMS_OP_PLAN_DETAILS SET
       last_updated_by 	= x_last_updated_by
      ,last_update_date = x_last_update_date
      ,last_update_login = x_last_update_login
      ,operation_type = x_operation_type
      ,operation_sequence = x_operation_sequence
      ,bulk_pick_type = x_bulk_pick_type
      ,drop_lpn_option = x_drop_lpn_option
      ,wait_for_group_completion = x_wait_for_group_completion
      ,system_dispatched  = x_system_dispatched
      ,op_segment_completed = x_op_segment_completed
      ,zone_selection_criteria = x_zone_selection_criteria
      ,pre_specified_zone_id = x_pre_specified_zone_id
      ,zone_selection_api_id = x_zone_selection_api_id
      ,sub_selection_criteria = x_sub_selection_criteria
      ,pre_specified_sub_code = x_pre_specified_sub_code
      ,sub_selection_api_id = x_sub_selection_api_id
      ,loc_selection_criteria = x_loc_selection_criteria
      ,pre_specified_loc_id = x_pre_specified_loc_id
      ,loc_selection_api_id  = x_loc_selection_api_id
      ,activity_segment = x_activity_segment
      ,attribute_category = x_attribute_category
      ,attribute1 = x_attribute1
      ,attribute2 = x_attribute2
      ,attribute3 = x_attribute3
      ,attribute4 = x_attribute4
      ,attribute5 = x_attribute5
      ,attribute6 = x_attribute6
      ,attribute7 = x_attribute7
      ,attribute8 = x_attribute8
      ,attribute9 = x_attribute9
      ,attribute10 = x_attribute10
      ,attribute11 = x_attribute11
      ,attribute12 = x_attribute12
      ,attribute13 = x_attribute13
      ,attribute14 = x_attribute14
      ,attribute15 = x_attribute15
      --,task_mode = x_task_mode  (out of scope for patchset 'J')
      --,operation_method = x_operation_method  (out of scope for patchset 'J')
      ,lpn_selection_criteria = x_lpn_selection_criteria
      ,lpn_selection_api_id = x_lpn_selection_api_id
      --,catch_secondary_qty = x_catch_secondary_qty  (out of scope for patchset 'J')
      ,loc_mtrl_grp_rule_id = x_loc_mtrl_grp_rule_id
      ,lpn_mtrl_grp_rule_id = x_lpn_mtrl_grp_rule_id
      ,organization_id = x_organization_id
     ,is_in_inventory = x_is_in_inventory
     ,subsequent_op_plan_id = x_subsequent_op_plan_id
     ,consolidation_method_id = x_consolidation_method_id
   WHERE operation_plan_detail_id = x_operation_plan_detail_id
   AND   operation_plan_id = x_operation_plan_id;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;
--
PROCEDURE LOAD_ROW (
   x_operation_plan_detail_id 	    IN     NUMBER
  ,x_owner                          IN     VARCHAR2
  ,x_last_update_date               IN     VARCHAR2
  ,x_operation_plan_id              IN     NUMBER
  ,x_operation_type                 IN     NUMBER
  ,x_operation_sequence             IN     NUMBER
  ,x_bulk_pick_type                 IN     NUMBER
  ,x_drop_lpn_option                IN     NUMBER
  ,x_wait_for_group_completion      IN     VARCHAR2
  ,x_system_dispatched              IN     VARCHAR2
  ,x_op_segment_completed           IN     VARCHAR2
  ,x_zone_selection_criteria        IN     NUMBER
  ,x_pre_specified_zone_id          IN     NUMBER
  ,x_zone_selection_api_id          IN     NUMBER
  ,x_sub_selection_criteria         IN     NUMBER
  ,x_pre_specified_sub_code         IN     VARCHAR2
  ,x_sub_selection_api_id           IN     NUMBER
  ,x_loc_selection_criteria         IN     NUMBER
  ,x_pre_specified_loc_id           IN     NUMBER
  ,x_loc_selection_api_id           IN     NUMBER
  ,x_activity_segment               IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  --,x_task_mode                      IN     NUMBER  (out of scope for patchset 'J')
  --,x_operation_method               IN     NUMBER  (out of scope for patchset 'J')
  ,x_lpn_selection_criteria         IN     NUMBER
  ,x_lpn_selection_api_id           IN     NUMBER
  --,x_catch_secondary_qty            IN     NUMBER  (out of scope for patchset 'J')
  ,x_loc_mtrl_grp_rule_id           IN     NUMBER
  ,x_lpn_mtrl_grp_rule_id           IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_is_in_inventory                IN     VARCHAR2
  ,x_subsequent_op_plan_id          IN     NUMBER
  ,x_consolidation_method_id            IN     NUMBER
  ) IS
BEGIN
      DECLARE
      l_operation_plan_detail_id   NUMBER;
      l_user_id          NUMBER := 0;
      l_row_id           VARCHAR2(64);
      --l_sysdate          DATE;
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      --SELECT Sysdate INTO l_sysdate FROM dual ;
      l_operation_plan_detail_id := fnd_number.canonical_to_number(x_operation_plan_detail_id);
      WMS_OP_PLAN_DETAILS_PKG.update_row (
         x_operation_plan_detail_id 	  => l_operation_plan_detail_id
        ,x_last_updated_by                => l_user_id
        ,x_last_update_date               => to_date(x_last_update_date,'yyyy/mm/dd')
        ,x_last_update_login              => 0
        ,x_operation_plan_id              => x_operation_plan_id
        ,x_operation_type                 => x_operation_type
        ,x_operation_sequence             => x_operation_sequence
        ,x_bulk_pick_type                 => x_bulk_pick_type
        ,x_drop_lpn_option                => x_drop_lpn_option
        ,x_wait_for_group_completion      => x_wait_for_group_completion
        ,x_system_dispatched              => x_system_dispatched
        ,x_op_segment_completed           => x_op_segment_completed
        ,x_zone_selection_criteria        => x_zone_selection_criteria
        ,x_pre_specified_zone_id          => x_pre_specified_zone_id
        ,x_zone_selection_api_id          => x_zone_selection_api_id
        ,x_sub_selection_criteria         => x_sub_selection_criteria
        ,x_pre_specified_sub_code         => x_pre_specified_sub_code
        ,x_sub_selection_api_id           => x_sub_selection_api_id
        ,x_loc_selection_criteria         => x_loc_selection_criteria
        ,x_pre_specified_loc_id           => x_pre_specified_loc_id
        ,x_loc_selection_api_id           => x_loc_selection_api_id
        ,x_activity_segment               => x_activity_segment
        ,x_attribute_category             => x_attribute_category
        ,x_attribute1                     => x_attribute1
        ,x_attribute2                     => x_attribute2
        ,x_attribute3                     => x_attribute3
        ,x_attribute4                     => x_attribute4
        ,x_attribute5                     => x_attribute5
        ,x_attribute6                     => x_attribute6
        ,x_attribute7                     => x_attribute7
        ,x_attribute8                     => x_attribute8
        ,x_attribute9                     => x_attribute9
        ,x_attribute10                    => x_attribute10
        ,x_attribute11                    => x_attribute11
        ,x_attribute12                    => x_attribute12
        ,x_attribute13                    => x_attribute13
        ,x_attribute14                    => x_attribute14
        ,x_attribute15                    => x_attribute15
        --,x_task_mode                      => x_task_mode  (out of scope for patchset 'J')
        --,x_operation_method               => x_operation_method  (out of scope for patchset 'J')
        ,x_lpn_selection_criteria         => x_lpn_selection_criteria
        ,x_lpn_selection_api_id           => x_lpn_selection_api_id
        --,x_catch_secondary_qty            => x_catch_secondary_qty  (out of scope for patchset 'J')
        ,x_loc_mtrl_grp_rule_id           => x_loc_mtrl_grp_rule_id
        ,x_lpn_mtrl_grp_rule_id           => x_lpn_mtrl_grp_rule_id
        ,x_organization_id                => x_organization_id
        ,x_is_in_inventory                => x_is_in_inventory
	,x_subsequent_op_plan_id          => x_subsequent_op_plan_id
	,x_consolidation_method_id        => x_consolidation_method_id
      );
   EXCEPTION
      WHEN no_data_found THEN
      WMS_OP_PLAN_DETAILS_PKG.insert_row (
	 x_rowid                     => l_row_id
        ,x_operation_plan_detail_id 	  => l_operation_plan_detail_id
        ,x_last_updated_by                => l_user_id
        ,x_last_update_date               => to_date(x_last_update_date,'yyyy/mm/dd')
	,x_created_by                     => l_user_id
	,x_creation_date                  => to_date(x_last_update_date,'yyyy/mm/dd')
        ,x_last_update_login              => 0
        ,x_operation_plan_id              => x_operation_plan_id
        ,x_operation_type                 => x_operation_type
        ,x_operation_sequence             => x_operation_sequence
        ,x_bulk_pick_type                 => x_bulk_pick_type
        ,x_drop_lpn_option                => x_drop_lpn_option
        ,x_wait_for_group_completion      => x_wait_for_group_completion
        ,x_system_dispatched              => x_system_dispatched
        ,x_op_segment_completed           => x_op_segment_completed
        ,x_zone_selection_criteria        => x_zone_selection_criteria
        ,x_pre_specified_zone_id          => x_pre_specified_zone_id
        ,x_zone_selection_api_id          => x_zone_selection_api_id
        ,x_sub_selection_criteria         => x_sub_selection_criteria
        ,x_pre_specified_sub_code         => x_pre_specified_sub_code
        ,x_sub_selection_api_id           => x_sub_selection_api_id
        ,x_loc_selection_criteria         => x_loc_selection_criteria
        ,x_pre_specified_loc_id           => x_pre_specified_loc_id
        ,x_loc_selection_api_id           => x_loc_selection_api_id
        ,x_activity_segment               => x_activity_segment
        ,x_attribute_category             => x_attribute_category
        ,x_attribute1                     => x_attribute1
        ,x_attribute2                     => x_attribute2
        ,x_attribute3                     => x_attribute3
        ,x_attribute4                     => x_attribute4
        ,x_attribute5                     => x_attribute5
        ,x_attribute6                     => x_attribute6
        ,x_attribute7                     => x_attribute7
        ,x_attribute8                     => x_attribute8
        ,x_attribute9                     => x_attribute9
        ,x_attribute10                    => x_attribute10
        ,x_attribute11                    => x_attribute11
        ,x_attribute12                    => x_attribute12
        ,x_attribute13                    => x_attribute13
        ,x_attribute14                    => x_attribute14
        ,x_attribute15                    => x_attribute15
        --,x_task_mode                      => x_task_mode  (out of scope for patchset 'J')
        --,x_operation_method               => x_operation_method  (out of scope for patchset 'J')
        ,x_lpn_selection_criteria         => x_lpn_selection_criteria
        ,x_lpn_selection_api_id           => x_lpn_selection_api_id
        --,x_catch_secondary_qty            => x_catch_secondary_qty  (out of scope for patchset 'J')
        ,x_loc_mtrl_grp_rule_id           => x_loc_mtrl_grp_rule_id
        ,x_lpn_mtrl_grp_rule_id           => x_lpn_mtrl_grp_rule_id
        ,x_organization_id                => x_organization_id
        ,x_is_in_inventory                => x_is_in_inventory
	,x_subsequent_op_plan_id          => x_subsequent_op_plan_id
	,x_consolidation_method_id        => x_consolidation_method_id
      );
   END;
END LOAD_ROW;


--added by Grace 07/28/03
PROCEDURE LOCK_ROW (
   x_operation_plan_detail_id 	    IN     NUMBER
  ,x_operation_plan_id              IN     NUMBER
  ,x_operation_type                 IN     NUMBER
  ,x_operation_sequence             IN     NUMBER
  ,x_bulk_pick_type                 IN     NUMBER
  ,x_drop_lpn_option                IN     NUMBER
  ,x_wait_for_group_completion      IN     VARCHAR2
  ,x_system_dispatched              IN     VARCHAR2
  ,x_op_segment_completed           IN     VARCHAR2
  ,x_zone_selection_criteria        IN     NUMBER
  ,x_pre_specified_zone_id          IN     NUMBER
  ,x_zone_selection_api_id          IN     NUMBER
  ,x_sub_selection_criteria         IN     NUMBER
  ,x_pre_specified_sub_code         IN     VARCHAR2
  ,x_sub_selection_api_id           IN     NUMBER
  ,x_loc_selection_criteria         IN     NUMBER
  ,x_pre_specified_loc_id           IN     NUMBER
  ,x_loc_selection_api_id           IN     NUMBER
  ,x_activity_segment               IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  --,x_task_mode                      IN     NUMBER  (out of scope for patchset 'J')
  --,x_operation_method               IN     NUMBER  (out of scope for patchset 'J')
  ,x_lpn_selection_criteria         IN     NUMBER
  ,x_lpn_selection_api_id           IN     NUMBER
  --,x_catch_secondary_qty            IN     NUMBER  (out of scope for patchset 'J')
  ,x_loc_mtrl_grp_rule_id           IN     NUMBER
  ,x_lpn_mtrl_grp_rule_id           IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_is_in_inventory                IN     VARCHAR2
  ,x_subsequent_op_plan_id          IN     NUMBER
  ,x_consolidation_method_id            IN     NUMBER
  ) IS
     CURSOR C IS SELECT
   operation_plan_id
  ,operation_type
  ,operation_sequence
  ,bulk_pick_type
  ,drop_lpn_option
  ,wait_for_group_completion
  ,system_dispatched
  ,op_segment_completed
  ,zone_selection_criteria
  ,pre_specified_zone_id
  ,zone_selection_api_id
  ,sub_selection_criteria
  ,pre_specified_sub_code
  ,sub_selection_api_id
  ,loc_selection_criteria
  ,pre_specified_loc_id
  ,loc_selection_api_id
  ,activity_segment
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
  --,x_task_mode                      IN     NUMBER  (out of scope for patchset 'J')
  --,x_operation_method               IN     NUMBER  (out of scope for patchset 'J')
  ,lpn_selection_criteria
  ,lpn_selection_api_id
  --,x_catch_secondary_qty            IN     NUMBER  (out of scope for patchset 'J')
  ,loc_mtrl_grp_rule_id
  ,lpn_mtrl_grp_rule_id
  ,organization_id
  ,is_in_inventory
  ,subsequent_op_plan_id
  ,consolidation_method_id
       from wms_op_plan_details
	where operation_plan_detail_id = x_operation_plan_detail_id
  	for UPDATE of OPERATION_PLAN_DETAIL_ID NOWAIT;
recinfo		C%rowtype;


BEGIN
	OPEN C;
	fetch C into recinfo;
        if(C%NOTFOUND) then
		close C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;

	if (                   (recinfo.operation_plan_id = x_operation_plan_id)
	     AND               (recinfo.operation_type = X_operation_type)
	     AND               (recinfo.operation_sequence = X_operation_sequence)
	     AND        (      (recinfo.bulk_pick_type = X_bulk_pick_type)
			OR     (       (recinfo.bulk_pick_type is null)
				       AND (X_bulk_pick_type is null)))
	     AND        (      (recinfo.drop_lpn_option = X_drop_lpn_option)
			OR     (       (recinfo.drop_lpn_option is null)
				       AND (X_drop_lpn_option is null)))
             AND        (      (recinfo.wait_for_group_completion = X_wait_for_group_completion)
			OR     (       (recinfo.wait_for_group_completion is null)
				       AND (X_wait_for_group_completion is null)))
	     AND        (      (recinfo.system_dispatched = X_system_dispatched)
			OR     (       (recinfo.system_dispatched is null)
				       AND (X_system_dispatched is null)))
	     AND        (      (recinfo.op_segment_completed = X_op_segment_completed)
			OR     (       (recinfo.op_segment_completed is null)
	 			       AND (X_op_segment_completed is null)))
	     AND        (      (recinfo.zone_selection_criteria = X_zone_selection_criteria)
			OR     (       (recinfo.zone_selection_criteria is null)
				       AND (X_zone_selection_criteria is null)))
	     AND        (      (recinfo.pre_specified_zone_id = X_pre_specified_zone_id)
			OR     (       (recinfo.pre_specified_zone_id is null)
				       AND (X_pre_specified_zone_id is null)))
             AND        (      (recinfo.zone_selection_api_id = X_zone_selection_api_id)
			OR     (       (recinfo.zone_selection_api_id is null)
				       AND (X_zone_selection_api_id is null)))
             AND        (      (recinfo.sub_selection_criteria = X_sub_selection_criteria)
			OR     (       (recinfo.sub_selection_criteria is null)
				       AND (X_sub_selection_criteria is null)))
             AND        (      (recinfo.pre_specified_sub_code= X_pre_specified_sub_code)
			OR     (       (recinfo.pre_specified_sub_code is null)
				       AND (X_pre_specified_sub_code is null)))
	     AND        (      (recinfo.sub_selection_api_id = X_sub_selection_api_id)
			OR     (       (recinfo.sub_selection_api_id is null)
				       AND (X_sub_selection_api_id is null)))
             AND        (      (recinfo.loc_selection_criteria = X_loc_selection_criteria)
			OR     (       (recinfo.loc_selection_criteria is null)
				       AND (X_loc_selection_criteria is null)))
             AND        (      (recinfo.pre_specified_loc_id = X_pre_specified_loc_id)
			OR     (       (recinfo.pre_specified_loc_id is null)
				       AND (X_pre_specified_loc_id is null)))
             AND        (      (recinfo.loc_selection_api_id = X_loc_selection_api_id)
			OR     (       (recinfo.loc_selection_api_id is null)
				       AND (X_loc_selection_api_id is null)))
             AND        (      (recinfo.activity_segment = X_activity_segment)
			OR     (       (recinfo.activity_segment is null)
				       AND (X_activity_segment is null)))
             AND        (      (recinfo.attribute_category = X_attribute_category)
			OR     (       (recinfo.attribute_category is null)
				       AND (X_attribute_category is null)))
             AND        (      (recinfo.attribute1 = X_attribute1)
			OR     (       (recinfo.attribute1 is null)
				       AND (X_attribute1 is null)))
             AND        (      (recinfo.attribute2  = X_attribute2)
			OR     (       (recinfo.attribute2 is null)
				       AND (X_attribute2 is null)))
             AND        (      (recinfo.attribute3 = X_attribute3)
			OR     (       (recinfo.attribute3 is null)
				       AND (X_attribute3 is null)))
             AND        (      (recinfo.attribute4 = X_attribute4)
			OR     (       (recinfo.attribute4 is null)
				       AND (X_attribute4 is null)))
             AND        (      (recinfo.attribute5 = X_attribute5)
			OR     (       (recinfo.attribute5 is null)
				       AND (X_attribute5 is null)))
             AND        (      (recinfo.attribute6 = X_attribute6)
			OR     (       (recinfo.attribute6 is null)
				       AND (X_attribute6 is null)))
	     AND        (      (recinfo.attribute6 = X_attribute6)
			OR     (       (recinfo.attribute6 is null)
				       AND (X_attribute6 is null)))
             AND        (      (recinfo.attribute7 = X_attribute7)
			OR     (       (recinfo.attribute7 is null)
				       AND (X_attribute7 is null)))
             AND        (      (recinfo.attribute8 = X_attribute8)
			OR     (       (recinfo.attribute8 is null)
				       AND (X_attribute8 is null)))
             AND        (      (recinfo.attribute9 = X_attribute9)
			OR     (       (recinfo.attribute9 is null)
				       AND (X_attribute9 is null)))
             AND        (      (recinfo.attribute10 = x_attribute10)
			OR     (       (recinfo.attribute10 is null)
				       AND (x_attribute10 is null)))
             AND        (      (recinfo.attribute13 = x_attribute13)
			OR     (       (recinfo.attribute13 is null)
				       AND (x_attribute13 is null)))
             AND        (      (recinfo.attribute11 = x_attribute11)
			OR     (       (recinfo.attribute11 is null)
				       AND (x_attribute11 is null)))
             AND        (      (recinfo.attribute12 = x_attribute12)
			OR     (       (recinfo.attribute12 is null)
				       AND (x_attribute12 is null)))
             AND        (      (recinfo.attribute14 = x_attribute14)
			OR     (       (recinfo.attribute14 is null)
				       AND (x_attribute14 is null)))
             AND        (      (recinfo.attribute15 = x_attribute15)
			OR     (       (recinfo.attribute15 is null)
				       AND (x_attribute15 is null)))
             AND        (      (recinfo.lpn_selection_criteria = x_lpn_selection_criteria)
			OR     (       (recinfo.lpn_selection_criteria is null)
				       AND (x_lpn_selection_criteria is null)))
             AND        (      (recinfo.lpn_selection_api_id = x_lpn_selection_api_id)
			OR     (       (recinfo.lpn_selection_api_id is null)
				       AND (x_lpn_selection_api_id is null)))
             AND        (      (recinfo.loc_mtrl_grp_rule_id = x_loc_mtrl_grp_rule_id)
			OR     (       (recinfo.loc_mtrl_grp_rule_id is null)
				       AND (x_loc_mtrl_grp_rule_id is null)))
             AND        (      (recinfo.lpn_mtrl_grp_rule_id = x_lpn_mtrl_grp_rule_id)
			OR     (       (recinfo.lpn_mtrl_grp_rule_id is null)
				       AND (x_lpn_mtrl_grp_rule_id is null)))
             AND        (      (recinfo.organization_id = x_organization_id)
			OR     (       (recinfo.organization_id is null)
				       AND (x_organization_id is null)))
             AND        (      (recinfo.is_in_inventory = x_is_in_inventory)
			OR     (       (recinfo.is_in_inventory is null)
				       AND (x_is_in_inventory is null)))
	     AND        (      (recinfo.subsequent_op_plan_id = x_subsequent_op_plan_id)
			OR     (       (recinfo.subsequent_op_plan_id is null)
				       AND (x_subsequent_op_plan_id is null)))
             AND        (      (recinfo.consolidation_method_id = x_consolidation_method_id)
			OR     (       (recinfo.consolidation_method_id is null)
				       AND (x_consolidation_method_id is null)))
	) then
                  return;

	else
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                APP_EXCEPTION.Raise_Exception;
	end if;

END lock_row;




--  Added by Grace Xiao 07/28/03

PROCEDURE delete_row (
  x_operation_plan_detail_id  IN NUMBER
) IS

BEGIN

  delete from WMS_OP_PLAN_DETAILS
  where OPERATION_PLAN_DETAIL_ID = X_OPERATION_PLAN_DETAIL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END delete_row;



END WMS_OP_PLAN_DETAILS_PKG;

/
