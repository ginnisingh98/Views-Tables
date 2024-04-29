--------------------------------------------------------
--  DDL for Package EAM_ITEM_ACTIVITIES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ITEM_ACTIVITIES_PUB_W" AUTHID CURRENT_USER as
  /* $Header: EAMWIAAS.pls 120.0 2005/05/25 15:59:01 appldev noship $ */
  procedure insert_item_activities(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_asset_activity_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_owningdepartment_id  NUMBER
    , p_maintenance_object_id  NUMBER
    , p_creation_organization_id  NUMBER
    , p_start_date_active  DATE
    , p_end_date_active  DATE
    , p_priority_code  VARCHAR2
    , p_activity_cause_code  VARCHAR2
    , p_activity_type_code  VARCHAR2
    , p_shutdown_type_code  VARCHAR2
    , p_maintenance_object_type  NUMBER
    , p_tmpl_flag  VARCHAR2
    , p_class_code  VARCHAR2
    , p_activity_source_code  VARCHAR2
    , p_serial_number  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_tagging_required_flag  VARCHAR2
    , p_last_service_start_date  DATE
    , p_last_service_end_date  DATE
    , p_prev_service_start_date  DATE
    , p_prev_service_end_date  DATE
    , p_last_scheduled_start_date  DATE
    , p_last_scheduled_end_date  DATE
    , p_prev_scheduled_start_date  DATE
    , p_prev_scheduled_end_date  DATE
    , p_wip_entity_id   NUMBER
    , p_source_tmpl_id  NUMBER
    , p46_a0 JTF_NUMBER_TABLE
    , p46_a1 JTF_NUMBER_TABLE
    , p46_a2 JTF_NUMBER_TABLE
    , p46_a3 JTF_NUMBER_TABLE
  );
  procedure update_item_activities(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_activity_association_id  NUMBER
    , p_asset_activity_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_owningdepartment_id  NUMBER
    , p_maintenance_object_id  NUMBER
    , p_creation_organization_id  NUMBER
    , p_start_date_active  DATE
    , p_end_date_active  DATE
    , p_priority_code  VARCHAR2
    , p_activity_cause_code  VARCHAR2
    , p_activity_type_code  VARCHAR2
    , p_shutdown_type_code  VARCHAR2
    , p_maintenance_object_type  NUMBER
    , p_tmpl_flag  VARCHAR2
    , p_class_code  VARCHAR2
    , p_activity_source_code  VARCHAR2
    , p_serial_number  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_tagging_required_flag  VARCHAR2
    , p_last_service_start_date  DATE
    , p_last_service_end_date  DATE
    , p_prev_service_start_date  DATE
    , p_prev_service_end_date  DATE
    , p_last_scheduled_start_date  DATE
    , p_last_scheduled_end_date  DATE
    , p_prev_scheduled_start_date  DATE
    , p_prev_scheduled_end_date  DATE
    , p_wip_entity_id   NUMBER
    , p_source_tmpl_id  NUMBER
    , p47_a0 JTF_NUMBER_TABLE
    , p47_a1 JTF_NUMBER_TABLE
    , p47_a2 JTF_NUMBER_TABLE
    , p47_a3 JTF_NUMBER_TABLE
  );
end eam_item_activities_pub_w;

 

/
