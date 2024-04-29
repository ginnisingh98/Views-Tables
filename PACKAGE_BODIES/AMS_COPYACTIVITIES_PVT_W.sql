--------------------------------------------------------
--  DDL for Package Body AMS_COPYACTIVITIES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_COPYACTIVITIES_PVT_W" as
  /* $Header: amsacpab.pls 120.0 2005/08/10 00:02:13 appldev noship $ */
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
  )

  as
    ddp_camp_elements_rec ams_copyactivities_pvt.camp_elements_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_camp_elements_rec.p_access := p10_a0;
    ddp_camp_elements_rec.p_geo_areas := p10_a1;
    ddp_camp_elements_rec.p_products := p10_a2;
    ddp_camp_elements_rec.p_sub_camp := p10_a3;
    ddp_camp_elements_rec.p_offers := p10_a4;
    ddp_camp_elements_rec.p_attachments := p10_a5;
    ddp_camp_elements_rec.p_messages := p10_a6;
    ddp_camp_elements_rec.p_obj_asso := p10_a7;
    ddp_camp_elements_rec.p_segments := p10_a8;
    ddp_camp_elements_rec.p_resources := p10_a9;
    ddp_camp_elements_rec.p_tasks := p10_a10;
    ddp_camp_elements_rec.p_partners := p10_a11;
    ddp_camp_elements_rec.p_camp_sch := p10_a12;



    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_campaign(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_campaign_id,
      p_src_camp_id,
      p_new_camp_name,
      p_par_camp_id,
      p_source_code,
      ddp_camp_elements_rec,
      p_end_date,
      p_start_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

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
  )

  as
    ddp_camp_elements_rec ams_copyactivities_pvt.camp_elements_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_camp_elements_rec.p_access := p10_a0;
    ddp_camp_elements_rec.p_geo_areas := p10_a1;
    ddp_camp_elements_rec.p_products := p10_a2;
    ddp_camp_elements_rec.p_sub_camp := p10_a3;
    ddp_camp_elements_rec.p_offers := p10_a4;
    ddp_camp_elements_rec.p_attachments := p10_a5;
    ddp_camp_elements_rec.p_messages := p10_a6;
    ddp_camp_elements_rec.p_obj_asso := p10_a7;
    ddp_camp_elements_rec.p_segments := p10_a8;
    ddp_camp_elements_rec.p_resources := p10_a9;
    ddp_camp_elements_rec.p_tasks := p10_a10;
    ddp_camp_elements_rec.p_partners := p10_a11;
    ddp_camp_elements_rec.p_camp_sch := p10_a12;




    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_campaign(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_campaign_id,
      p_src_camp_id,
      p_new_camp_name,
      p_par_camp_id,
      p_source_code,
      ddp_camp_elements_rec,
      p_end_date,
      p_start_date,
      x_transaction_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

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
  )

  as
    ddp_eveh_elements_rec ams_copyactivities_pvt.eveh_elements_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_eveh_elements_rec.p_products := p9_a0;
    ddp_eveh_elements_rec.p_sub_eveh := p9_a1;
    ddp_eveh_elements_rec.p_attachments := p9_a2;
    ddp_eveh_elements_rec.p_offers := p9_a3;
    ddp_eveh_elements_rec.p_messages := p9_a4;
    ddp_eveh_elements_rec.p_resources := p9_a5;
    ddp_eveh_elements_rec.p_obj_asso := p9_a6;
    ddp_eveh_elements_rec.p_geo_areas := p9_a7;
    ddp_eveh_elements_rec.p_event_offer := p9_a8;
    ddp_eveh_elements_rec.p_segments := p9_a9;




    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_event_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_eveh_id,
      p_src_eveh_id,
      p_new_eveh_name,
      p_par_eveh_id,
      ddp_eveh_elements_rec,
      p_start_date,
      p_end_date,
      p_source_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

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
  )

  as
    ddp_eveo_elements_rec ams_copyactivities_pvt.eveo_elements_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_eveo_elements_rec.p_geo_areas := p10_a0;
    ddp_eveo_elements_rec.p_products := p10_a1;
    ddp_eveo_elements_rec.p_segments := p10_a2;
    ddp_eveo_elements_rec.p_sub_eveo := p10_a3;
    ddp_eveo_elements_rec.p_attachments := p10_a4;
    ddp_eveo_elements_rec.p_resources := p10_a5;
    ddp_eveo_elements_rec.p_offers := p10_a6;
    ddp_eveo_elements_rec.p_messages := p10_a7;
    ddp_eveo_elements_rec.p_obj_asso := p10_a8;




    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_event_offer(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_eveo_id,
      p_src_eveo_id,
      p_event_header_id,
      p_new_eveo_name,
      p_par_eveo_id,
      ddp_eveo_elements_rec,
      p_start_date,
      p_end_date,
      p_source_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

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
  )

  as
    ddp_deli_elements_rec ams_copyactivities_pvt.deli_elements_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_deli_elements_rec.p_attachments := p9_a0;
    ddp_deli_elements_rec.p_kitflag := p9_a1;
    ddp_deli_elements_rec.p_access := p9_a2;
    ddp_deli_elements_rec.p_products := p9_a3;
    ddp_deli_elements_rec.p_offers := p9_a4;
    ddp_deli_elements_rec.p_obj_asso := p9_a5;
    ddp_deli_elements_rec.p_bus_party := p9_a6;
    ddp_deli_elements_rec.p_geo_areas := p9_a7;
    ddp_deli_elements_rec.p_categories := p9_a8;


    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_deliverables(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_deliverable_id,
      p_src_deliv_id,
      p_new_deliv_name,
      p_new_deliv_code,
      ddp_deli_elements_rec,
      p_new_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

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
  )

  as
    ddp_eveh_elements_rec ams_copyactivities_pvt.eveh_elements_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_eveh_elements_rec.p_products := p9_a0;
    ddp_eveh_elements_rec.p_sub_eveh := p9_a1;
    ddp_eveh_elements_rec.p_attachments := p9_a2;
    ddp_eveh_elements_rec.p_offers := p9_a3;
    ddp_eveh_elements_rec.p_messages := p9_a4;
    ddp_eveh_elements_rec.p_resources := p9_a5;
    ddp_eveh_elements_rec.p_obj_asso := p9_a6;
    ddp_eveh_elements_rec.p_geo_areas := p9_a7;
    ddp_eveh_elements_rec.p_event_offer := p9_a8;
    ddp_eveh_elements_rec.p_segments := p9_a9;





    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_event_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_eveh_id,
      p_src_eveh_id,
      p_new_eveh_name,
      p_par_eveh_id,
      ddp_eveh_elements_rec,
      p_start_date,
      p_end_date,
      x_transaction_id,
      p_source_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

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
  )

  as
    ddp_eveo_elements_rec ams_copyactivities_pvt.eveo_elements_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_eveo_elements_rec.p_geo_areas := p10_a0;
    ddp_eveo_elements_rec.p_products := p10_a1;
    ddp_eveo_elements_rec.p_segments := p10_a2;
    ddp_eveo_elements_rec.p_sub_eveo := p10_a3;
    ddp_eveo_elements_rec.p_attachments := p10_a4;
    ddp_eveo_elements_rec.p_resources := p10_a5;
    ddp_eveo_elements_rec.p_offers := p10_a6;
    ddp_eveo_elements_rec.p_messages := p10_a7;
    ddp_eveo_elements_rec.p_obj_asso := p10_a8;





    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_event_offer(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_eveo_id,
      p_src_eveo_id,
      p_event_header_id,
      p_new_eveo_name,
      p_par_eveo_id,
      ddp_eveo_elements_rec,
      p_start_date,
      p_end_date,
      x_transaction_id,
      p_source_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

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
  )

  as
    ddp_deli_elements_rec ams_copyactivities_pvt.deli_elements_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_deli_elements_rec.p_attachments := p9_a0;
    ddp_deli_elements_rec.p_kitflag := p9_a1;
    ddp_deli_elements_rec.p_access := p9_a2;
    ddp_deli_elements_rec.p_products := p9_a3;
    ddp_deli_elements_rec.p_offers := p9_a4;
    ddp_deli_elements_rec.p_obj_asso := p9_a5;
    ddp_deli_elements_rec.p_bus_party := p9_a6;
    ddp_deli_elements_rec.p_geo_areas := p9_a7;
    ddp_deli_elements_rec.p_categories := p9_a8;



    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_deliverables(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_deliverable_id,
      p_src_deliv_id,
      p_new_deliv_name,
      p_new_deliv_code,
      ddp_deli_elements_rec,
      p_new_version,
      x_transaction_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

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
  )

  as
    ddp_attr_list ams_copyactivities_pvt.schedule_attr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_attr_list.p_agen := p9_a0;
    ddp_attr_list.p_atch := p9_a1;
    ddp_attr_list.p_catg := p9_a2;
    ddp_attr_list.p_cell := p9_a3;
    ddp_attr_list.p_delv := p9_a4;
    ddp_attr_list.p_mesg := p9_a5;
    ddp_attr_list.p_prod := p9_a6;
    ddp_attr_list.p_ptnr := p9_a7;
    ddp_attr_list.p_regs := p9_a8;
    ddp_attr_list.p_content := p9_a9;
    ddp_attr_list.p_tgrp := p9_a10;
    ddp_attr_list.p_colt := p9_a11;

    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_schedule_attributes(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_object_type,
      p_src_object_id,
      p_tar_object_id,
      ddp_attr_list);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

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
  )

  as
    ddp_attributes_table ams_cpyutility_pvt.copy_attributes_table_type;
    ddp_copy_columns_table ams_cpyutility_pvt.copy_columns_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_cpyutility_pvt_w.rosetta_table_copy_in_p0(ddp_attributes_table, p_attributes_table);

    ams_cpyutility_pvt_w.rosetta_table_copy_in_p2(ddp_copy_columns_table, p9_a0
      , p9_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    ams_copyactivities_pvt.copy_campaign_new(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_object_id,
      ddp_attributes_table,
      ddp_copy_columns_table,
      x_new_object_id,
      x_custom_setup_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end ams_copyactivities_pvt_w;

/
