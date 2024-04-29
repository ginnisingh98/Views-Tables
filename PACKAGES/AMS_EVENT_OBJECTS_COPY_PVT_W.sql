--------------------------------------------------------
--  DDL for Package AMS_EVENT_OBJECTS_COPY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENT_OBJECTS_COPY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amsweocs.pls 115.6 2003/07/30 08:38:43 anchaudh ship $ */
   procedure copy_event_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_object_id  NUMBER
    , p_attributes_table JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , x_new_object_id out nocopy  NUMBER
    , x_custom_setup_id out nocopy  NUMBER
  );
end ams_event_objects_copy_pvt_w;

 

/
