--------------------------------------------------------
--  DDL for Package Body AMV_USER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_USER_PVT_W" as
  /* $Header: amvwusrb.pls 120.2 2005/06/30 08:50 appldev ship $ */
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

  procedure rosetta_table_copy_in_p31(t out nocopy amv_user_pvt.amv_char_varray_type, a0 JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_user_pvt.amv_char_varray_type();
  else
      if a0.count > 0 then
      t := amv_user_pvt.amv_char_varray_type();
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
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t amv_user_pvt.amv_char_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_4000) as
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
  end rosetta_table_copy_out_p31;

  procedure rosetta_table_copy_in_p32(t out nocopy amv_user_pvt.amv_number_varray_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_user_pvt.amv_number_varray_type();
  else
      if a0.count > 0 then
      t := amv_user_pvt.amv_number_varray_type();
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
  end rosetta_table_copy_in_p32;
  procedure rosetta_table_copy_out_p32(t amv_user_pvt.amv_number_varray_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p32;

  procedure rosetta_table_copy_in_p36(t out nocopy amv_user_pvt.amv_resource_obj_varray, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_user_pvt.amv_resource_obj_varray();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_user_pvt.amv_resource_obj_varray();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).person_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).user_name := a2(indx);
          t(ddindx).first_name := a3(indx);
          t(ddindx).last_name := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p36;
  procedure rosetta_table_copy_out_p36(t amv_user_pvt.amv_resource_obj_varray, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).person_id);
          a2(indx) := t(ddindx).user_name;
          a3(indx) := t(ddindx).first_name;
          a4(indx) := t(ddindx).last_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p36;

  procedure rosetta_table_copy_in_p38(t out nocopy amv_user_pvt.amv_group_obj_varray, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_user_pvt.amv_group_obj_varray();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_user_pvt.amv_group_obj_varray();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).group_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).group_name := a1(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).email_address := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).effective_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a6(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p38;
  procedure rosetta_table_copy_out_p38(t amv_user_pvt.amv_group_obj_varray, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
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
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).group_id);
          a1(indx) := t(ddindx).group_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := t(ddindx).email_address;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).effective_start_date;
          a6(indx) := t(ddindx).expiration_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p38;

  procedure rosetta_table_copy_in_p40(t out nocopy amv_user_pvt.amv_access_obj_varray, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_user_pvt.amv_access_obj_varray();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_user_pvt.amv_access_obj_varray();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).access_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).access_to_table_code := a2(indx);
          t(ddindx).access_to_table_record_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).user_or_group_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).user_or_group_type := a5(indx);
          t(ddindx).effective_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).can_view_flag := a8(indx);
          t(ddindx).can_create_flag := a9(indx);
          t(ddindx).can_delete_flag := a10(indx);
          t(ddindx).can_update_flag := a11(indx);
          t(ddindx).can_create_dist_rule_flag := a12(indx);
          t(ddindx).chl_approver_flag := a13(indx);
          t(ddindx).chl_required_flag := a14(indx);
          t(ddindx).chl_required_need_notif_flag := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p40;
  procedure rosetta_table_copy_out_p40(t amv_user_pvt.amv_access_obj_varray, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
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
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
    a12 := null;
    a13 := null;
    a14 := null;
    a15 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).access_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).access_to_table_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).access_to_table_record_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).user_or_group_id);
          a5(indx) := t(ddindx).user_or_group_type;
          a6(indx) := t(ddindx).effective_start_date;
          a7(indx) := t(ddindx).expiration_date;
          a8(indx) := t(ddindx).can_view_flag;
          a9(indx) := t(ddindx).can_create_flag;
          a10(indx) := t(ddindx).can_delete_flag;
          a11(indx) := t(ddindx).can_update_flag;
          a12(indx) := t(ddindx).can_create_dist_rule_flag;
          a13(indx) := t(ddindx).chl_approver_flag;
          a14(indx) := t(ddindx).chl_required_flag;
          a15(indx) := t(ddindx).chl_required_need_notif_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p40;

  procedure find_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_check_effective_date  VARCHAR2
    , p_user_name  VARCHAR2
    , p_last_name  VARCHAR2
    , p_first_name  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_subset_request_obj amv_user_pvt.amv_request_obj_type;
    ddx_subset_return_obj amv_user_pvt.amv_return_obj_type;
    ddx_resource_obj_array amv_user_pvt.amv_resource_obj_varray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_subset_request_obj.records_requested := rosetta_g_miss_num_map(p12_a0);
    ddp_subset_request_obj.start_record_position := rosetta_g_miss_num_map(p12_a1);
    ddp_subset_request_obj.return_total_count_flag := p12_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.find_resource(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_check_effective_date,
      p_user_name,
      p_last_name,
      p_first_name,
      ddp_subset_request_obj,
      ddx_subset_return_obj,
      ddx_resource_obj_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    p13_a0 := rosetta_g_miss_num_map(ddx_subset_return_obj.returned_record_count);
    p13_a1 := rosetta_g_miss_num_map(ddx_subset_return_obj.next_record_position);
    p13_a2 := rosetta_g_miss_num_map(ddx_subset_return_obj.total_record_count);

    amv_user_pvt_w.rosetta_table_copy_out_p36(ddx_resource_obj_array, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      );
  end;

  procedure find_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , x_role_code_varray out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_subset_request_obj amv_user_pvt.amv_request_obj_type;
    ddx_subset_return_obj amv_user_pvt.amv_return_obj_type;
    ddx_resource_obj_array amv_user_pvt.amv_resource_obj_varray;
    ddx_role_code_varray amv_user_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_subset_request_obj.records_requested := rosetta_g_miss_num_map(p9_a0);
    ddp_subset_request_obj.start_record_position := rosetta_g_miss_num_map(p9_a1);
    ddp_subset_request_obj.return_total_count_flag := p9_a2;




    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.find_resource(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_resource_name,
      ddp_subset_request_obj,
      ddx_subset_return_obj,
      ddx_resource_obj_array,
      ddx_role_code_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_subset_return_obj.returned_record_count);
    p10_a1 := rosetta_g_miss_num_map(ddx_subset_return_obj.next_record_position);
    p10_a2 := rosetta_g_miss_num_map(ddx_subset_return_obj.total_record_count);

    amv_user_pvt_w.rosetta_table_copy_out_p36(ddx_resource_obj_array, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      );

    amv_user_pvt_w.rosetta_table_copy_out_p31(ddx_role_code_varray, x_role_code_varray);
  end;

  procedure add_resourcerole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_role_id_varray amv_user_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_in_p32(ddp_role_id_varray, p_role_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.add_resourcerole(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      ddp_role_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure remove_resourcerole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_role_id_varray amv_user_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_in_p32(ddp_role_id_varray, p_role_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.remove_resourcerole(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      ddp_role_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure replace_resourcerole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_role_id_varray amv_user_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_in_p32(ddp_role_id_varray, p_role_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.replace_resourcerole(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      ddp_role_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure get_resourceroles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , x_role_id_varray out nocopy JTF_NUMBER_TABLE
    , x_role_code_varray out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_role_id_varray amv_user_pvt.amv_number_varray_type;
    ddx_role_code_varray amv_user_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_resourceroles(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      ddx_role_id_varray,
      ddx_role_code_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_user_pvt_w.rosetta_table_copy_out_p32(ddx_role_id_varray, x_role_id_varray);

    amv_user_pvt_w.rosetta_table_copy_out_p31(ddx_role_code_varray, x_role_code_varray);
  end;

  procedure add_grouprole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_role_id_varray amv_user_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_in_p32(ddp_role_id_varray, p_role_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.add_grouprole(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      ddp_role_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure remove_grouprole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_role_id_varray amv_user_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_in_p32(ddp_role_id_varray, p_role_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.remove_grouprole(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      ddp_role_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure replace_grouprole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_role_id_varray amv_user_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_in_p32(ddp_role_id_varray, p_role_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.replace_grouprole(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      ddp_role_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure get_grouproles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_check_effective_date  VARCHAR2
    , x_role_id_varray out nocopy JTF_NUMBER_TABLE
    , x_role_code_varray out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_role_id_varray amv_user_pvt.amv_number_varray_type;
    ddx_role_code_varray amv_user_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_grouproles(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_check_effective_date,
      ddx_role_id_varray,
      ddx_role_code_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_out_p32(ddx_role_id_varray, x_role_id_varray);

    amv_user_pvt_w.rosetta_table_copy_out_p31(ddx_role_code_varray, x_role_code_varray);
  end;

  procedure add_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_group_usage  VARCHAR2
    , p_email_address  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_group_id out nocopy  NUMBER
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);


    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.add_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_name,
      p_group_desc,
      p_group_usage,
      p_email_address,
      ddp_start_date,
      ddp_end_date,
      x_group_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure update_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_new_group_name  VARCHAR2
    , p_new_group_desc  VARCHAR2
    , p_group_usage  VARCHAR2
    , p_email_address  VARCHAR2
    , p_new_start_date  date
    , p_new_end_date  date
  )

  as
    ddp_new_start_date date;
    ddp_new_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    ddp_new_start_date := rosetta_g_miss_date_in_map(p_new_start_date);

    ddp_new_end_date := rosetta_g_miss_date_in_map(p_new_end_date);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_new_group_name,
      p_new_group_desc,
      p_group_usage,
      p_email_address,
      ddp_new_start_date,
      ddp_new_end_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure get_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
  )

  as
    ddx_group_obj amv_user_pvt.amv_group_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_group(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      ddx_group_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_group_obj.group_id);
    p8_a1 := ddx_group_obj.group_name;
    p8_a2 := rosetta_g_miss_num_map(ddx_group_obj.object_version_number);
    p8_a3 := ddx_group_obj.email_address;
    p8_a4 := ddx_group_obj.description;
    p8_a5 := ddx_group_obj.effective_start_date;
    p8_a6 := ddx_group_obj.expiration_date;
  end;

  procedure find_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_group_email  VARCHAR2
    , p_group_usage  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a5 out nocopy JTF_DATE_TABLE
    , p14_a6 out nocopy JTF_DATE_TABLE
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_subset_request_obj amv_user_pvt.amv_request_obj_type;
    ddx_subset_return_obj amv_user_pvt.amv_return_obj_type;
    ddx_group_obj_array amv_user_pvt.amv_group_obj_varray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_subset_request_obj.records_requested := rosetta_g_miss_num_map(p12_a0);
    ddp_subset_request_obj.start_record_position := rosetta_g_miss_num_map(p12_a1);
    ddp_subset_request_obj.return_total_count_flag := p12_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.find_group(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_group_name,
      p_group_desc,
      p_group_email,
      p_group_usage,
      ddp_subset_request_obj,
      ddx_subset_return_obj,
      ddx_group_obj_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    p13_a0 := rosetta_g_miss_num_map(ddx_subset_return_obj.returned_record_count);
    p13_a1 := rosetta_g_miss_num_map(ddx_subset_return_obj.next_record_position);
    p13_a2 := rosetta_g_miss_num_map(ddx_subset_return_obj.total_record_count);

    amv_user_pvt_w.rosetta_table_copy_out_p38(ddx_group_obj_array, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      );
  end;

  procedure find_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_group_name  VARCHAR2
    , p_group_usage  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a5 out nocopy JTF_DATE_TABLE
    , p12_a6 out nocopy JTF_DATE_TABLE
    , x_role_code_varray out nocopy JTF_VARCHAR2_TABLE_4000
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_subset_request_obj amv_user_pvt.amv_request_obj_type;
    ddx_subset_return_obj amv_user_pvt.amv_return_obj_type;
    ddx_group_obj_array amv_user_pvt.amv_group_obj_varray;
    ddx_role_code_varray amv_user_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_subset_request_obj.records_requested := rosetta_g_miss_num_map(p10_a0);
    ddp_subset_request_obj.start_record_position := rosetta_g_miss_num_map(p10_a1);
    ddp_subset_request_obj.return_total_count_flag := p10_a2;




    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.find_group(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_group_name,
      p_group_usage,
      ddp_subset_request_obj,
      ddx_subset_return_obj,
      ddx_group_obj_array,
      ddx_role_code_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddx_subset_return_obj.returned_record_count);
    p11_a1 := rosetta_g_miss_num_map(ddx_subset_return_obj.next_record_position);
    p11_a2 := rosetta_g_miss_num_map(ddx_subset_return_obj.total_record_count);

    amv_user_pvt_w.rosetta_table_copy_out_p38(ddx_group_obj_array, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      );

    amv_user_pvt_w.rosetta_table_copy_out_p31(ddx_role_code_varray, x_role_code_varray);
  end;

  procedure add_groupmember(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_resource_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_resource_id_varray amv_user_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_in_p32(ddp_resource_id_varray, p_resource_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.add_groupmember(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      ddp_resource_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure remove_groupmember(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_resource_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_resource_id_varray amv_user_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_in_p32(ddp_resource_id_varray, p_resource_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.remove_groupmember(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      ddp_resource_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  DATE := fnd_api.g_miss_date
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_obj amv_user_pvt.amv_access_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_access_obj.access_id := rosetta_g_miss_num_map(p8_a0);
    ddp_access_obj.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_access_obj.access_to_table_code := p8_a2;
    ddp_access_obj.access_to_table_record_id := rosetta_g_miss_num_map(p8_a3);
    ddp_access_obj.user_or_group_id := rosetta_g_miss_num_map(p8_a4);
    ddp_access_obj.user_or_group_type := p8_a5;
    ddp_access_obj.effective_start_date := rosetta_g_miss_date_in_map(p8_a6);
    ddp_access_obj.expiration_date := rosetta_g_miss_date_in_map(p8_a7);
    ddp_access_obj.can_view_flag := p8_a8;
    ddp_access_obj.can_create_flag := p8_a9;
    ddp_access_obj.can_delete_flag := p8_a10;
    ddp_access_obj.can_update_flag := p8_a11;
    ddp_access_obj.can_create_dist_rule_flag := p8_a12;
    ddp_access_obj.chl_approver_flag := p8_a13;
    ddp_access_obj.chl_required_flag := p8_a14;
    ddp_access_obj.chl_required_need_notif_flag := p8_a15;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_access(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_access_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_DATE_TABLE
    , p8_a7 JTF_DATE_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_100
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_100
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_access_obj_array amv_user_pvt.amv_access_obj_varray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_user_pvt_w.rosetta_table_copy_in_p40(ddp_access_obj_array, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      );

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_access(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_access_obj_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_resourceapplaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_application_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_access_flag_obj.can_view_flag := p10_a0;
    ddp_access_flag_obj.can_create_flag := p10_a1;
    ddp_access_flag_obj.can_delete_flag := p10_a2;
    ddp_access_flag_obj.can_update_flag := p10_a3;
    ddp_access_flag_obj.can_create_dist_rule_flag := p10_a4;
    ddp_access_flag_obj.chl_approver_flag := p10_a5;
    ddp_access_flag_obj.chl_required_flag := p10_a6;
    ddp_access_flag_obj.chl_required_need_notif_flag := p10_a7;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_resourceapplaccess(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_application_id,
      ddp_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_resourcechanaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_channel_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_access_flag_obj.can_view_flag := p10_a0;
    ddp_access_flag_obj.can_create_flag := p10_a1;
    ddp_access_flag_obj.can_delete_flag := p10_a2;
    ddp_access_flag_obj.can_update_flag := p10_a3;
    ddp_access_flag_obj.can_create_dist_rule_flag := p10_a4;
    ddp_access_flag_obj.chl_approver_flag := p10_a5;
    ddp_access_flag_obj.chl_required_flag := p10_a6;
    ddp_access_flag_obj.chl_required_need_notif_flag := p10_a7;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_resourcechanaccess(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_channel_id,
      ddp_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_resourcecateaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_category_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_access_flag_obj.can_view_flag := p10_a0;
    ddp_access_flag_obj.can_create_flag := p10_a1;
    ddp_access_flag_obj.can_delete_flag := p10_a2;
    ddp_access_flag_obj.can_update_flag := p10_a3;
    ddp_access_flag_obj.can_create_dist_rule_flag := p10_a4;
    ddp_access_flag_obj.chl_approver_flag := p10_a5;
    ddp_access_flag_obj.chl_required_flag := p10_a6;
    ddp_access_flag_obj.chl_required_need_notif_flag := p10_a7;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_resourcecateaccess(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_category_id,
      ddp_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_resourceitemaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_item_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_access_flag_obj.can_view_flag := p10_a0;
    ddp_access_flag_obj.can_create_flag := p10_a1;
    ddp_access_flag_obj.can_delete_flag := p10_a2;
    ddp_access_flag_obj.can_update_flag := p10_a3;
    ddp_access_flag_obj.can_create_dist_rule_flag := p10_a4;
    ddp_access_flag_obj.chl_approver_flag := p10_a5;
    ddp_access_flag_obj.chl_required_flag := p10_a6;
    ddp_access_flag_obj.chl_required_need_notif_flag := p10_a7;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_resourceitemaccess(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_item_id,
      ddp_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_groupapplaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_group_id  NUMBER
    , p_application_id  NUMBER
    , p11_a0  VARCHAR2 := fnd_api.g_miss_char
    , p11_a1  VARCHAR2 := fnd_api.g_miss_char
    , p11_a2  VARCHAR2 := fnd_api.g_miss_char
    , p11_a3  VARCHAR2 := fnd_api.g_miss_char
    , p11_a4  VARCHAR2 := fnd_api.g_miss_char
    , p11_a5  VARCHAR2 := fnd_api.g_miss_char
    , p11_a6  VARCHAR2 := fnd_api.g_miss_char
    , p11_a7  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_access_flag_obj.can_view_flag := p11_a0;
    ddp_access_flag_obj.can_create_flag := p11_a1;
    ddp_access_flag_obj.can_delete_flag := p11_a2;
    ddp_access_flag_obj.can_update_flag := p11_a3;
    ddp_access_flag_obj.can_create_dist_rule_flag := p11_a4;
    ddp_access_flag_obj.chl_approver_flag := p11_a5;
    ddp_access_flag_obj.chl_required_flag := p11_a6;
    ddp_access_flag_obj.chl_required_need_notif_flag := p11_a7;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_groupapplaccess(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_resource_id,
      p_group_id,
      p_application_id,
      ddp_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_groupchanaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_channel_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_access_flag_obj.can_view_flag := p10_a0;
    ddp_access_flag_obj.can_create_flag := p10_a1;
    ddp_access_flag_obj.can_delete_flag := p10_a2;
    ddp_access_flag_obj.can_update_flag := p10_a3;
    ddp_access_flag_obj.can_create_dist_rule_flag := p10_a4;
    ddp_access_flag_obj.chl_approver_flag := p10_a5;
    ddp_access_flag_obj.chl_required_flag := p10_a6;
    ddp_access_flag_obj.chl_required_need_notif_flag := p10_a7;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_groupchanaccess(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_channel_id,
      ddp_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_groupcateaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_category_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_access_flag_obj.can_view_flag := p10_a0;
    ddp_access_flag_obj.can_create_flag := p10_a1;
    ddp_access_flag_obj.can_delete_flag := p10_a2;
    ddp_access_flag_obj.can_update_flag := p10_a3;
    ddp_access_flag_obj.can_create_dist_rule_flag := p10_a4;
    ddp_access_flag_obj.chl_approver_flag := p10_a5;
    ddp_access_flag_obj.chl_required_flag := p10_a6;
    ddp_access_flag_obj.chl_required_need_notif_flag := p10_a7;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_groupcateaccess(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_category_id,
      ddp_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_groupitemaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_item_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_access_flag_obj.can_view_flag := p10_a0;
    ddp_access_flag_obj.can_create_flag := p10_a1;
    ddp_access_flag_obj.can_delete_flag := p10_a2;
    ddp_access_flag_obj.can_update_flag := p10_a3;
    ddp_access_flag_obj.can_create_dist_rule_flag := p10_a4;
    ddp_access_flag_obj.chl_approver_flag := p10_a5;
    ddp_access_flag_obj.chl_required_flag := p10_a6;
    ddp_access_flag_obj.chl_required_need_notif_flag := p10_a7;

    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.update_groupitemaccess(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_item_id,
      ddp_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure get_businessobjectaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_or_group_id  NUMBER
    , p_user_or_group_type  VARCHAR2
    , p_business_object_id  NUMBER
    , p_business_object_type  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  NUMBER
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  VARCHAR2
    , p11_a6 out nocopy  DATE
    , p11_a7 out nocopy  DATE
    , p11_a8 out nocopy  VARCHAR2
    , p11_a9 out nocopy  VARCHAR2
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  VARCHAR2
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  VARCHAR2
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  VARCHAR2
  )

  as
    ddx_access_obj amv_user_pvt.amv_access_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_businessobjectaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_user_or_group_id,
      p_user_or_group_type,
      p_business_object_id,
      p_business_object_type,
      ddx_access_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddx_access_obj.access_id);
    p11_a1 := rosetta_g_miss_num_map(ddx_access_obj.object_version_number);
    p11_a2 := ddx_access_obj.access_to_table_code;
    p11_a3 := rosetta_g_miss_num_map(ddx_access_obj.access_to_table_record_id);
    p11_a4 := rosetta_g_miss_num_map(ddx_access_obj.user_or_group_id);
    p11_a5 := ddx_access_obj.user_or_group_type;
    p11_a6 := ddx_access_obj.effective_start_date;
    p11_a7 := ddx_access_obj.expiration_date;
    p11_a8 := ddx_access_obj.can_view_flag;
    p11_a9 := ddx_access_obj.can_create_flag;
    p11_a10 := ddx_access_obj.can_delete_flag;
    p11_a11 := ddx_access_obj.can_update_flag;
    p11_a12 := ddx_access_obj.can_create_dist_rule_flag;
    p11_a13 := ddx_access_obj.chl_approver_flag;
    p11_a14 := ddx_access_obj.chl_required_flag;
    p11_a15 := ddx_access_obj.chl_required_need_notif_flag;
  end;

  procedure get_channelaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_or_group_id  NUMBER
    , p_user_or_group_type  VARCHAR2
    , x_channel_name_varray out nocopy JTF_VARCHAR2_TABLE_4000
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_DATE_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_channel_name_varray amv_user_pvt.amv_char_varray_type;
    ddx_access_obj_varray amv_user_pvt.amv_access_obj_varray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_channelaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_user_or_group_id,
      p_user_or_group_type,
      ddx_channel_name_varray,
      ddx_access_obj_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_out_p31(ddx_channel_name_varray, x_channel_name_varray);

    amv_user_pvt_w.rosetta_table_copy_out_p40(ddx_access_obj_varray, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      );
  end;

  procedure get_accessperchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_user_or_group_type  VARCHAR2
    , x_name_varray out nocopy JTF_VARCHAR2_TABLE_4000
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_DATE_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_name_varray amv_user_pvt.amv_char_varray_type;
    ddx_access_obj_varray amv_user_pvt.amv_access_obj_varray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_accessperchannel(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_user_or_group_type,
      ddx_name_varray,
      ddx_access_obj_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    amv_user_pvt_w.rosetta_table_copy_out_p31(ddx_name_varray, x_name_varray);

    amv_user_pvt_w.rosetta_table_copy_out_p40(ddx_access_obj_varray, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      );
  end;

  procedure get_businessobjectaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_check_effective_date  VARCHAR2
    , p_user_or_group_id  NUMBER
    , p_user_or_group_type  VARCHAR2
    , p_business_object_id  NUMBER
    , p_business_object_type  VARCHAR2
    , p13_a0 out nocopy  VARCHAR2
    , p13_a1 out nocopy  VARCHAR2
    , p13_a2 out nocopy  VARCHAR2
    , p13_a3 out nocopy  VARCHAR2
    , p13_a4 out nocopy  VARCHAR2
    , p13_a5 out nocopy  VARCHAR2
    , p13_a6 out nocopy  VARCHAR2
    , p13_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_businessobjectaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_include_group_flag,
      p_check_effective_date,
      p_user_or_group_id,
      p_user_or_group_type,
      p_business_object_id,
      p_business_object_type,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    p13_a0 := ddx_access_flag_obj.can_view_flag;
    p13_a1 := ddx_access_flag_obj.can_create_flag;
    p13_a2 := ddx_access_flag_obj.can_delete_flag;
    p13_a3 := ddx_access_flag_obj.can_update_flag;
    p13_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p13_a5 := ddx_access_flag_obj.chl_approver_flag;
    p13_a6 := ddx_access_flag_obj.chl_required_flag;
    p13_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

  procedure get_resourceapplaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_resource_id  NUMBER
    , p_application_id  NUMBER
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_resourceapplaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_include_group_flag,
      p_resource_id,
      p_application_id,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := ddx_access_flag_obj.can_view_flag;
    p10_a1 := ddx_access_flag_obj.can_create_flag;
    p10_a2 := ddx_access_flag_obj.can_delete_flag;
    p10_a3 := ddx_access_flag_obj.can_update_flag;
    p10_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p10_a5 := ddx_access_flag_obj.chl_approver_flag;
    p10_a6 := ddx_access_flag_obj.chl_required_flag;
    p10_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

  procedure get_resourcechanaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_resource_id  NUMBER
    , p_channel_id  NUMBER
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_resourcechanaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_include_group_flag,
      p_resource_id,
      p_channel_id,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := ddx_access_flag_obj.can_view_flag;
    p10_a1 := ddx_access_flag_obj.can_create_flag;
    p10_a2 := ddx_access_flag_obj.can_delete_flag;
    p10_a3 := ddx_access_flag_obj.can_update_flag;
    p10_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p10_a5 := ddx_access_flag_obj.chl_approver_flag;
    p10_a6 := ddx_access_flag_obj.chl_required_flag;
    p10_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

  procedure get_resourcecateaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_resource_id  NUMBER
    , p_category_id  NUMBER
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_resourcecateaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_include_group_flag,
      p_resource_id,
      p_category_id,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := ddx_access_flag_obj.can_view_flag;
    p10_a1 := ddx_access_flag_obj.can_create_flag;
    p10_a2 := ddx_access_flag_obj.can_delete_flag;
    p10_a3 := ddx_access_flag_obj.can_update_flag;
    p10_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p10_a5 := ddx_access_flag_obj.chl_approver_flag;
    p10_a6 := ddx_access_flag_obj.chl_required_flag;
    p10_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

  procedure get_resourceitemaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_resource_id  NUMBER
    , p_item_id  NUMBER
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_resourceitemaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_include_group_flag,
      p_resource_id,
      p_item_id,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := ddx_access_flag_obj.can_view_flag;
    p10_a1 := ddx_access_flag_obj.can_create_flag;
    p10_a2 := ddx_access_flag_obj.can_delete_flag;
    p10_a3 := ddx_access_flag_obj.can_update_flag;
    p10_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p10_a5 := ddx_access_flag_obj.chl_approver_flag;
    p10_a6 := ddx_access_flag_obj.chl_required_flag;
    p10_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

  procedure get_groupapplaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_application_id  NUMBER
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_groupapplaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_application_id,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_access_flag_obj.can_view_flag;
    p9_a1 := ddx_access_flag_obj.can_create_flag;
    p9_a2 := ddx_access_flag_obj.can_delete_flag;
    p9_a3 := ddx_access_flag_obj.can_update_flag;
    p9_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p9_a5 := ddx_access_flag_obj.chl_approver_flag;
    p9_a6 := ddx_access_flag_obj.chl_required_flag;
    p9_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

  procedure get_groupchanaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_channel_id  NUMBER
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_groupchanaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_channel_id,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_access_flag_obj.can_view_flag;
    p9_a1 := ddx_access_flag_obj.can_create_flag;
    p9_a2 := ddx_access_flag_obj.can_delete_flag;
    p9_a3 := ddx_access_flag_obj.can_update_flag;
    p9_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p9_a5 := ddx_access_flag_obj.chl_approver_flag;
    p9_a6 := ddx_access_flag_obj.chl_required_flag;
    p9_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

  procedure get_groupcateaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_category_id  NUMBER
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_groupcateaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_category_id,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_access_flag_obj.can_view_flag;
    p9_a1 := ddx_access_flag_obj.can_create_flag;
    p9_a2 := ddx_access_flag_obj.can_delete_flag;
    p9_a3 := ddx_access_flag_obj.can_update_flag;
    p9_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p9_a5 := ddx_access_flag_obj.chl_approver_flag;
    p9_a6 := ddx_access_flag_obj.chl_required_flag;
    p9_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

  procedure get_resourceitemaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_item_id  NUMBER
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
  )

  as
    ddx_access_flag_obj amv_user_pvt.amv_access_flag_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    amv_user_pvt.get_resourceitemaccess(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      p_item_id,
      ddx_access_flag_obj);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_access_flag_obj.can_view_flag;
    p9_a1 := ddx_access_flag_obj.can_create_flag;
    p9_a2 := ddx_access_flag_obj.can_delete_flag;
    p9_a3 := ddx_access_flag_obj.can_update_flag;
    p9_a4 := ddx_access_flag_obj.can_create_dist_rule_flag;
    p9_a5 := ddx_access_flag_obj.chl_approver_flag;
    p9_a6 := ddx_access_flag_obj.chl_required_flag;
    p9_a7 := ddx_access_flag_obj.chl_required_need_notif_flag;
  end;

end amv_user_pvt_w;

/
