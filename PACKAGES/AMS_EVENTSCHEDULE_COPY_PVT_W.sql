--------------------------------------------------------
--  DDL for Package AMS_EVENTSCHEDULE_COPY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENTSCHEDULE_COPY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswescs.pls 115.4 2004/04/08 09:11:27 anchaudh ship $ */
  procedure copy_event_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_source_object_id  NUMBER
    , p_attributes_table JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , x_new_object_id OUT NOCOPY  NUMBER
    , x_custom_setup_id OUT NOCOPY  NUMBER
  );
end ams_eventschedule_copy_pvt_w;

 

/
