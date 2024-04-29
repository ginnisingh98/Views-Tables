--------------------------------------------------------
--  DDL for Package Body AMV_CATEGORY_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CATEGORY_GRP_W" as
  /* $Header: amvwcagb.pls 120.2 2005/06/30 07:43 appldev ship $ */
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

  procedure reorder_category(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_category_id_array JTF_NUMBER_TABLE
    , p_category_new_order JTF_NUMBER_TABLE
  )

  as
    ddp_category_id_array amv_category_pvt.amv_number_varray_type;
    ddp_category_new_order amv_category_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_category_pvt_w.rosetta_table_copy_in_p3(ddp_category_id_array, p_category_id_array);

    amv_category_pvt_w.rosetta_table_copy_in_p3(ddp_category_new_order, p_category_new_order);

    -- here's the delegated call to the old PL/SQL routine
    amv_category_grp.reorder_category(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_application_id,
      ddp_category_id_array,
      ddp_category_new_order);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure find_categories(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_category_name  VARCHAR2
    , p_parent_category_id  NUMBER
    , p_ignore_hierarchy  VARCHAR2
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  NUMBER
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_NUMBER_TABLE
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p13_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_request_obj amv_category_pvt.amv_request_obj_type;
    ddx_return_obj amv_category_pvt.amv_return_obj_type;
    ddx_chan_category_rec_array amv_category_pvt.amv_category_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_request_obj.records_requested := rosetta_g_miss_num_map(p11_a0);
    ddp_request_obj.start_record_position := rosetta_g_miss_num_map(p11_a1);
    ddp_request_obj.return_total_count_flag := p11_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_category_grp.find_categories(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_application_id,
      p_category_name,
      p_parent_category_id,
      p_ignore_hierarchy,
      ddp_request_obj,
      ddx_return_obj,
      ddx_chan_category_rec_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    p12_a0 := rosetta_g_miss_num_map(ddx_return_obj.returned_record_count);
    p12_a1 := rosetta_g_miss_num_map(ddx_return_obj.next_record_position);
    p12_a2 := rosetta_g_miss_num_map(ddx_return_obj.total_record_count);

    amv_category_pvt_w.rosetta_table_copy_out_p7(ddx_chan_category_rec_array, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      );
  end;

  procedure get_channelspercategory(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_category_id  NUMBER
    , p_include_subcats  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_content_chan_array amv_category_pvt.amv_cat_hierarchy_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_category_grp.get_channelspercategory(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_category_id,
      p_include_subcats,
      ddx_content_chan_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    amv_category_pvt_w.rosetta_table_copy_out_p10(ddx_content_chan_array, p9_a0
      , p9_a1
      , p9_a2
      );
  end;

  procedure get_catparentshierarchy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_category_id  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_category_hierarchy amv_category_pvt.amv_cat_hierarchy_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    amv_category_grp.get_catparentshierarchy(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_category_id,
      ddx_category_hierarchy);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_category_pvt_w.rosetta_table_copy_out_p10(ddx_category_hierarchy, p8_a0
      , p8_a1
      , p8_a2
      );
  end;

  procedure get_catchildrenhierarchy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_category_id  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_category_hierarchy amv_category_pvt.amv_cat_hierarchy_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    amv_category_grp.get_catchildrenhierarchy(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_category_id,
      ddx_category_hierarchy);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_category_pvt_w.rosetta_table_copy_out_p10(ddx_category_hierarchy, p8_a0
      , p8_a1
      , p8_a2
      );
  end;

  procedure get_chncategoryhierarchy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , x_channel_name out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_category_hierarchy amv_category_pvt.amv_cat_hierarchy_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_category_grp.get_chncategoryhierarchy(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      x_channel_name,
      ddx_category_hierarchy);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    amv_category_pvt_w.rosetta_table_copy_out_p10(ddx_category_hierarchy, p9_a0
      , p9_a1
      , p9_a2
      );
  end;

  procedure get_itemspercategory(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_category_id  NUMBER
    , p_include_subcats  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_request_obj amv_category_pvt.amv_request_obj_type;
    ddp_category_sort amv_category_pvt.amv_sort_obj_type;
    ddx_return_obj amv_category_pvt.amv_return_obj_type;
    ddx_items_array amv_category_pvt.amv_cat_hierarchy_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_request_obj.records_requested := rosetta_g_miss_num_map(p9_a0);
    ddp_request_obj.start_record_position := rosetta_g_miss_num_map(p9_a1);
    ddp_request_obj.return_total_count_flag := p9_a2;

    ddp_category_sort.sort_col := p10_a0;
    ddp_category_sort.sort_dir := p10_a1;



    -- here's the delegated call to the old PL/SQL routine
    amv_category_grp.get_itemspercategory(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_category_id,
      p_include_subcats,
      ddp_request_obj,
      ddp_category_sort,
      ddx_return_obj,
      ddx_items_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddx_return_obj.returned_record_count);
    p11_a1 := rosetta_g_miss_num_map(ddx_return_obj.next_record_position);
    p11_a2 := rosetta_g_miss_num_map(ddx_return_obj.total_record_count);

    amv_category_pvt_w.rosetta_table_copy_out_p10(ddx_items_array, p12_a0
      , p12_a1
      , p12_a2
      );
  end;

end amv_category_grp_w;

/
