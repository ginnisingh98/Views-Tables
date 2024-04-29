--------------------------------------------------------
--  DDL for Package WMS_OP_PLAN_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OP_PLAN_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSOPLDS.pls 120.0 2005/05/24 18:20:06 appldev noship $ */
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
  );

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
  );

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
  );

--
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
  );



-- added by Grace Xiao 07/28/03
PROCEDURE delete_row (
  x_operation_plan_detail_id		    IN	   NUMBER
  );




--
END WMS_OP_PLAN_DETAILS_PKG;

 

/
