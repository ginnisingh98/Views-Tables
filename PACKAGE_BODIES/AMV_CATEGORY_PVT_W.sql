--------------------------------------------------------
--  DDL for Package Body AMV_CATEGORY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CATEGORY_PVT_W" as
  /* $Header: amvwcatb.pls 120.2 2005/06/30 07:45 appldev ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy amv_category_pvt.amv_char_varray_type, a0 JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_category_pvt.amv_char_varray_type();
  else
      if a0.count > 0 then
      t := amv_category_pvt.amv_char_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t amv_category_pvt.amv_char_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy amv_category_pvt.amv_number_varray_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_category_pvt.amv_number_varray_type();
  else
      if a0.count > 0 then
      t := amv_category_pvt.amv_number_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t amv_category_pvt.amv_number_varray_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p7(t out nocopy amv_category_pvt.amv_category_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_category_pvt.amv_category_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_category_pvt.amv_category_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).category_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).parent_category_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).category_order := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).channel_count := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).category_name := a5(indx);
          t(ddindx).description := a6(indx);
          t(ddindx).count := rosetta_g_miss_num_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t amv_category_pvt.amv_category_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).category_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).parent_category_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).category_order);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).channel_count);
          a5(indx) := t(ddindx).category_name;
          a6(indx) := t(ddindx).description;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).count);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p10(t out nocopy amv_category_pvt.amv_cat_hierarchy_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_category_pvt.amv_cat_hierarchy_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_category_pvt.amv_cat_hierarchy_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).hierarchy_level := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).name := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t amv_category_pvt.amv_cat_hierarchy_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).hierarchy_level);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a2(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

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
    amv_category_pvt.reorder_category(p_api_version,
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
    , p_parent_category_name  VARCHAR2
    , p_ignore_hierarchy  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a7 out nocopy JTF_NUMBER_TABLE
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_request_obj amv_category_pvt.amv_request_obj_type;
    ddx_return_obj amv_category_pvt.amv_return_obj_type;
    ddx_chan_category_rec_array amv_category_pvt.amv_category_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_request_obj.records_requested := rosetta_g_miss_num_map(p12_a0);
    ddp_request_obj.start_record_position := rosetta_g_miss_num_map(p12_a1);
    ddp_request_obj.return_total_count_flag := p12_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_category_pvt.find_categories(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_application_id,
      p_category_name,
      p_parent_category_id,
      p_parent_category_name,
      p_ignore_hierarchy,
      ddp_request_obj,
      ddx_return_obj,
      ddx_chan_category_rec_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    p13_a0 := rosetta_g_miss_num_map(ddx_return_obj.returned_record_count);
    p13_a1 := rosetta_g_miss_num_map(ddx_return_obj.next_record_position);
    p13_a2 := rosetta_g_miss_num_map(ddx_return_obj.total_record_count);

    amv_category_pvt_w.rosetta_table_copy_out_p7(ddx_chan_category_rec_array, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
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
    amv_category_pvt.get_channelspercategory(p_api_version,
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

  procedure get_itemspercategory(p_api_version  NUMBER
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
    ddx_items_array amv_category_pvt.amv_cat_hierarchy_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_category_pvt.get_itemspercategory(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_category_id,
      p_include_subcats,
      ddx_items_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    amv_category_pvt_w.rosetta_table_copy_out_p10(ddx_items_array, p9_a0
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
    amv_category_pvt.get_itemspercategory(p_api_version,
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
    amv_category_pvt.get_catparentshierarchy(p_api_version,
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
    amv_category_pvt.get_catchildrenhierarchy(p_api_version,
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
    amv_category_pvt.get_chncategoryhierarchy(p_api_version,
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

end amv_category_pvt_w;

/
