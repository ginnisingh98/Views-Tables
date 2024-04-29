--------------------------------------------------------
--  DDL for Package Body EAM_ITEM_ACTIVITIES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ITEM_ACTIVITIES_PUB_W" as
  /* $Header: EAMWIAAB.pls 120.0 2005/05/25 16:32:37 appldev noship $ */
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
  )

  as
    ddp_pm_last_service_tbl eam_pm_last_service_pub.pm_last_service_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














































    eam_pm_last_service_pub_w.rosetta_table_copy_in_p1(ddp_pm_last_service_tbl, p46_a0
      , p46_a1
      , p46_a2
      , p46_a3
      );

    -- here's the delegated call to the old PL/SQL routine
    eam_item_activities_pub.insert_item_activities(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_asset_activity_id,
      p_inventory_item_id,
      p_organization_id,
      p_owningdepartment_id,
      p_maintenance_object_id,
      p_creation_organization_id,
      p_start_date_active,
      p_end_date_active,
      p_priority_code,
      p_activity_cause_code,
      p_activity_type_code,
      p_shutdown_type_code,
      p_maintenance_object_type,
      p_tmpl_flag,
      p_class_code,
      p_activity_source_code,
      p_serial_number,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_tagging_required_flag,
      p_last_service_start_date,
      p_last_service_end_date,
      p_prev_service_start_date,
      p_prev_service_end_date,
      p_last_scheduled_start_date,
      p_last_scheduled_end_date,
      p_prev_scheduled_start_date,
      p_prev_scheduled_end_date,
      p_wip_entity_id,
      p_source_tmpl_id,
      ddp_pm_last_service_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














































  end;

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
  )

  as
    ddp_pm_last_service_tbl eam_pm_last_service_pub.pm_last_service_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















































    eam_pm_last_service_pub_w.rosetta_table_copy_in_p1(ddp_pm_last_service_tbl, p47_a0
      , p47_a1
      , p47_a2
      , p47_a3
      );

    -- here's the delegated call to the old PL/SQL routine
    eam_item_activities_pub.update_item_activities(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_activity_association_id,
      p_asset_activity_id,
      p_inventory_item_id,
      p_organization_id,
      p_owningdepartment_id,
      p_maintenance_object_id,
      p_creation_organization_id,
      p_start_date_active,
      p_end_date_active,
      p_priority_code,
      p_activity_cause_code,
      p_activity_type_code,
      p_shutdown_type_code,
      p_maintenance_object_type,
      p_tmpl_flag,
      p_class_code,
      p_activity_source_code,
      p_serial_number,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_tagging_required_flag,
      p_last_service_start_date,
      p_last_service_end_date,
      p_prev_service_start_date,
      p_prev_service_end_date,
      p_last_scheduled_start_date,
      p_last_scheduled_end_date,
      p_prev_scheduled_start_date,
      p_prev_scheduled_end_date,
      p_wip_entity_id,
      p_source_tmpl_id,
      ddp_pm_last_service_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















































  end;

end eam_item_activities_pub_w;

/
