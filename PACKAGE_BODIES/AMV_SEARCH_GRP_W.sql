--------------------------------------------------------
--  DDL for Package Body AMV_SEARCH_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_SEARCH_GRP_W" as
  /* $Header: amvwsrgb.pls 120.2 2005/06/30 08:44 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure find_repositories(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_object_version_number  NUMBER
    , p_repository_id  NUMBER
    , p_repository_code  VARCHAR2
    , p_repository_name  VARCHAR2
    , p_status  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_searchrep_array amv_search_pvt.amv_searchrep_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    amv_search_grp.find_repositories(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_object_version_number,
      p_repository_id,
      p_repository_code,
      p_repository_name,
      p_status,
      ddx_searchrep_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    amv_search_pvt_w.rosetta_table_copy_out_p7(ddx_searchrep_array, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      );
  end;

  procedure find_repository_areas(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
  )

  as
    ddp_searcharea_obj amv_search_pvt.amv_searchara_obj_type;
    ddx_searcharea_array amv_search_pvt.amv_searchara_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_searcharea_obj.repository_id := rosetta_g_miss_num_map(p7_a0);
    ddp_searcharea_obj.repository_code := p7_a1;
    ddp_searcharea_obj.area_indicator := p7_a2;
    ddp_searcharea_obj.area_id := rosetta_g_miss_num_map(p7_a3);
    ddp_searcharea_obj.area_code := p7_a4;
    ddp_searcharea_obj.area_name := p7_a5;
    ddp_searcharea_obj.status := p7_a6;
    ddp_searcharea_obj.object_version_number := rosetta_g_miss_num_map(p7_a7);


    -- here's the delegated call to the old PL/SQL routine
    amv_search_grp.find_repository_areas(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_searcharea_obj,
      ddx_searcharea_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_search_pvt_w.rosetta_table_copy_out_p9(ddx_searcharea_array, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      );
  end;

  procedure content_search(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_area_array JTF_VARCHAR2_TABLE_4000
    , p_content_array JTF_VARCHAR2_TABLE_4000
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_400
    , p_imt_string  VARCHAR2
    , p_days  NUMBER
    , p_user_id  NUMBER
    , p_category_id JTF_NUMBER_TABLE
    , p_include_subcats  VARCHAR2
    , p_external_contents  VARCHAR2
    , p18_a0 out nocopy  NUMBER
    , p18_a1 out nocopy  NUMBER
    , p18_a2 out nocopy  NUMBER
    , p19_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p19_a3 out nocopy JTF_NUMBER_TABLE
    , p19_a4 out nocopy JTF_NUMBER_TABLE
    , p19_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p17_a0  NUMBER := 0-1962.0724
    , p17_a1  NUMBER := 0-1962.0724
    , p17_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_area_array amv_search_pvt.amv_char_varray_type;
    ddp_content_array amv_search_pvt.amv_char_varray_type;
    ddp_param_array amv_search_pvt.amv_searchpar_varray_type;
    ddp_category_id amv_search_pvt.amv_number_varray_type;
    ddp_request_obj amv_search_pvt.amv_request_obj_type;
    ddx_return_obj amv_search_pvt.amv_return_obj_type;
    ddx_searchres_array amv_search_pvt.amv_searchres_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_search_pvt_w.rosetta_table_copy_in_p0(ddp_area_array, p_area_array);

    amv_search_pvt_w.rosetta_table_copy_in_p0(ddp_content_array, p_content_array);

    amv_search_pvt_w.rosetta_table_copy_in_p11(ddp_param_array, p10_a0
      , p10_a1
      );




    amv_search_pvt_w.rosetta_table_copy_in_p1(ddp_category_id, p_category_id);



    ddp_request_obj.records_requested := rosetta_g_miss_num_map(p17_a0);
    ddp_request_obj.start_record_position := rosetta_g_miss_num_map(p17_a1);
    ddp_request_obj.return_total_count_flag := p17_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_search_grp.content_search(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_application_id,
      ddp_area_array,
      ddp_content_array,
      ddp_param_array,
      p_imt_string,
      p_days,
      p_user_id,
      ddp_category_id,
      p_include_subcats,
      p_external_contents,
      ddp_request_obj,
      ddx_return_obj,
      ddx_searchres_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















    p18_a0 := rosetta_g_miss_num_map(ddx_return_obj.returned_record_count);
    p18_a1 := rosetta_g_miss_num_map(ddx_return_obj.next_record_position);
    p18_a2 := rosetta_g_miss_num_map(ddx_return_obj.total_record_count);

    amv_search_pvt_w.rosetta_table_copy_out_p13(ddx_searchres_array, p19_a0
      , p19_a1
      , p19_a2
      , p19_a3
      , p19_a4
      , p19_a5
      , p19_a6
      , p19_a7
      , p19_a8
      );
  end;

end amv_search_grp_w;

/
