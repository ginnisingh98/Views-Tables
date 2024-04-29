--------------------------------------------------------
--  DDL for Package AMS_COPYACTIVITIES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_COPYACTIVITIES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amsacpas.pls 120.0 2005/08/10 00:01:07 appldev noship $ */
  procedure copy_campaign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_campaign_id out nocopy  NUMBER
    , p_src_camp_id  NUMBER
    , p_new_camp_name  VARCHAR2
    , p_par_camp_id  NUMBER
    , p_source_code  VARCHAR2
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  VARCHAR2
    , p10_a4  VARCHAR2
    , p10_a5  VARCHAR2
    , p10_a6  VARCHAR2
    , p10_a7  VARCHAR2
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p_end_date  DATE
    , p_start_date  DATE
  );
  procedure copy_campaign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_campaign_id out nocopy  NUMBER
    , p_src_camp_id  NUMBER
    , p_new_camp_name  VARCHAR2
    , p_par_camp_id  NUMBER
    , p_source_code  VARCHAR2
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  VARCHAR2
    , p10_a4  VARCHAR2
    , p10_a5  VARCHAR2
    , p10_a6  VARCHAR2
    , p10_a7  VARCHAR2
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p_end_date  DATE
    , p_start_date  DATE
    , x_transaction_id out nocopy  NUMBER
  );
  procedure copy_event_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_eveh_id out nocopy  NUMBER
    , p_src_eveh_id  NUMBER
    , p_new_eveh_name  VARCHAR2
    , p_par_eveh_id  NUMBER
    , p9_a0  VARCHAR2
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , p_source_code  VARCHAR2
  );
  procedure copy_event_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_eveo_id out nocopy  NUMBER
    , p_src_eveo_id  NUMBER
    , p_event_header_id  NUMBER
    , p_new_eveo_name  VARCHAR2
    , p_par_eveo_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  VARCHAR2
    , p10_a4  VARCHAR2
    , p10_a5  VARCHAR2
    , p10_a6  VARCHAR2
    , p10_a7  VARCHAR2
    , p10_a8  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , p_source_code  VARCHAR2
  );
  procedure copy_deliverables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_deliverable_id out nocopy  NUMBER
    , p_src_deliv_id  NUMBER
    , p_new_deliv_name  VARCHAR2
    , p_new_deliv_code  VARCHAR2
    , p9_a0  VARCHAR2
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p_new_version  VARCHAR2
  );
  procedure copy_event_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_eveh_id out nocopy  NUMBER
    , p_src_eveh_id  NUMBER
    , p_new_eveh_name  VARCHAR2
    , p_par_eveh_id  NUMBER
    , p9_a0  VARCHAR2
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , x_transaction_id out nocopy  NUMBER
    , p_source_code  VARCHAR2
  );
  procedure copy_event_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_eveo_id out nocopy  NUMBER
    , p_src_eveo_id  NUMBER
    , p_event_header_id  NUMBER
    , p_new_eveo_name  VARCHAR2
    , p_par_eveo_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  VARCHAR2
    , p10_a4  VARCHAR2
    , p10_a5  VARCHAR2
    , p10_a6  VARCHAR2
    , p10_a7  VARCHAR2
    , p10_a8  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , x_transaction_id out nocopy  NUMBER
    , p_source_code  VARCHAR2
  );
  procedure copy_deliverables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_deliverable_id out nocopy  NUMBER
    , p_src_deliv_id  NUMBER
    , p_new_deliv_name  VARCHAR2
    , p_new_deliv_code  VARCHAR2
    , p9_a0  VARCHAR2
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p_new_version  VARCHAR2
    , x_transaction_id out nocopy  NUMBER
  );
  procedure copy_schedule_attributes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_type  VARCHAR2
    , p_src_object_id  NUMBER
    , p_tar_object_id  NUMBER
    , p9_a0  VARCHAR2
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
  );
  procedure copy_campaign_new(p_api_version  NUMBER
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
end ams_copyactivities_pvt_w;

 

/
