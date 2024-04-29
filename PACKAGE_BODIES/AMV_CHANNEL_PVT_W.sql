--------------------------------------------------------
--  DDL for Package Body AMV_CHANNEL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CHANNEL_PVT_W" as
  /* $Header: amvwchab.pls 120.2 2005/06/30 07:50 appldev ship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy amv_channel_pvt.amv_char_varray_type, a0 JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_channel_pvt.amv_char_varray_type();
  else
      if a0.count > 0 then
      t := amv_channel_pvt.amv_char_varray_type();
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
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t amv_channel_pvt.amv_char_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_4000) as
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
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy amv_channel_pvt.amv_number_varray_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_channel_pvt.amv_number_varray_type();
  else
      if a0.count > 0 then
      t := amv_channel_pvt.amv_number_varray_type();
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t amv_channel_pvt.amv_number_varray_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p5(t out nocopy amv_channel_pvt.amv_channel_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_channel_pvt.amv_channel_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_channel_pvt.amv_channel_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).channel_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).channel_name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).channel_type := a4(indx);
          t(ddindx).channel_category_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).status := a6(indx);
          t(ddindx).owner_user_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).default_approver_user_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).effective_start_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).access_level_type := a11(indx);
          t(ddindx).pub_need_approval_flag := a12(indx);
          t(ddindx).sub_need_approval_flag := a13(indx);
          t(ddindx).match_on_all_criteria_flag := a14(indx);
          t(ddindx).match_on_keyword_flag := a15(indx);
          t(ddindx).match_on_author_flag := a16(indx);
          t(ddindx).match_on_perspective_flag := a17(indx);
          t(ddindx).match_on_item_type_flag := a18(indx);
          t(ddindx).match_on_content_type_flag := a19(indx);
          t(ddindx).match_on_time_flag := a20(indx);
          t(ddindx).application_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).external_access_flag := a22(indx);
          t(ddindx).item_match_count := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).last_match_time := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).notification_interval_type := a25(indx);
          t(ddindx).last_notification_time := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).attribute_category := a27(indx);
          t(ddindx).attribute1 := a28(indx);
          t(ddindx).attribute2 := a29(indx);
          t(ddindx).attribute3 := a30(indx);
          t(ddindx).attribute4 := a31(indx);
          t(ddindx).attribute5 := a32(indx);
          t(ddindx).attribute6 := a33(indx);
          t(ddindx).attribute7 := a34(indx);
          t(ddindx).attribute8 := a35(indx);
          t(ddindx).attribute9 := a36(indx);
          t(ddindx).attribute10 := a37(indx);
          t(ddindx).attribute11 := a38(indx);
          t(ddindx).attribute12 := a39(indx);
          t(ddindx).attribute13 := a40(indx);
          t(ddindx).attribute14 := a41(indx);
          t(ddindx).attribute15 := a42(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t amv_channel_pvt.amv_channel_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
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
    a16 := null;
    a17 := null;
    a18 := null;
    a19 := null;
    a20 := null;
    a21 := null;
    a22 := null;
    a23 := null;
    a24 := null;
    a25 := null;
    a26 := null;
    a27 := null;
    a28 := null;
    a29 := null;
    a30 := null;
    a31 := null;
    a32 := null;
    a33 := null;
    a34 := null;
    a35 := null;
    a36 := null;
    a37 := null;
    a38 := null;
    a39 := null;
    a40 := null;
    a41 := null;
    a42 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
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
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).channel_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).channel_name;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).channel_type;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).channel_category_id);
          a6(indx) := t(ddindx).status;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).owner_user_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).default_approver_user_id);
          a9(indx) := t(ddindx).effective_start_date;
          a10(indx) := t(ddindx).expiration_date;
          a11(indx) := t(ddindx).access_level_type;
          a12(indx) := t(ddindx).pub_need_approval_flag;
          a13(indx) := t(ddindx).sub_need_approval_flag;
          a14(indx) := t(ddindx).match_on_all_criteria_flag;
          a15(indx) := t(ddindx).match_on_keyword_flag;
          a16(indx) := t(ddindx).match_on_author_flag;
          a17(indx) := t(ddindx).match_on_perspective_flag;
          a18(indx) := t(ddindx).match_on_item_type_flag;
          a19(indx) := t(ddindx).match_on_content_type_flag;
          a20(indx) := t(ddindx).match_on_time_flag;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).application_id);
          a22(indx) := t(ddindx).external_access_flag;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).item_match_count);
          a24(indx) := t(ddindx).last_match_time;
          a25(indx) := t(ddindx).notification_interval_type;
          a26(indx) := t(ddindx).last_notification_time;
          a27(indx) := t(ddindx).attribute_category;
          a28(indx) := t(ddindx).attribute1;
          a29(indx) := t(ddindx).attribute2;
          a30(indx) := t(ddindx).attribute3;
          a31(indx) := t(ddindx).attribute4;
          a32(indx) := t(ddindx).attribute5;
          a33(indx) := t(ddindx).attribute6;
          a34(indx) := t(ddindx).attribute7;
          a35(indx) := t(ddindx).attribute8;
          a36(indx) := t(ddindx).attribute9;
          a37(indx) := t(ddindx).attribute10;
          a38(indx) := t(ddindx).attribute11;
          a39(indx) := t(ddindx).attribute12;
          a40(indx) := t(ddindx).attribute13;
          a41(indx) := t(ddindx).attribute14;
          a42(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure add_channel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , x_channel_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.add_channel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure add_publicchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , x_channel_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.add_publicchannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure add_protectedchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , x_channel_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.add_protectedchannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure add_privatechannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , x_channel_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.add_privatechannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure add_groupchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , x_channel_id out nocopy  NUMBER
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  DATE := fnd_api.g_miss_date
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  VARCHAR2 := fnd_api.g_miss_char
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  DATE := fnd_api.g_miss_date
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  DATE := fnd_api.g_miss_date
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p9_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p9_a1);
    ddp_channel_record.channel_name := p9_a2;
    ddp_channel_record.description := p9_a3;
    ddp_channel_record.channel_type := p9_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p9_a5);
    ddp_channel_record.status := p9_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p9_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p9_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p9_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p9_a10);
    ddp_channel_record.access_level_type := p9_a11;
    ddp_channel_record.pub_need_approval_flag := p9_a12;
    ddp_channel_record.sub_need_approval_flag := p9_a13;
    ddp_channel_record.match_on_all_criteria_flag := p9_a14;
    ddp_channel_record.match_on_keyword_flag := p9_a15;
    ddp_channel_record.match_on_author_flag := p9_a16;
    ddp_channel_record.match_on_perspective_flag := p9_a17;
    ddp_channel_record.match_on_item_type_flag := p9_a18;
    ddp_channel_record.match_on_content_type_flag := p9_a19;
    ddp_channel_record.match_on_time_flag := p9_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p9_a21);
    ddp_channel_record.external_access_flag := p9_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p9_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p9_a24);
    ddp_channel_record.notification_interval_type := p9_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p9_a26);
    ddp_channel_record.attribute_category := p9_a27;
    ddp_channel_record.attribute1 := p9_a28;
    ddp_channel_record.attribute2 := p9_a29;
    ddp_channel_record.attribute3 := p9_a30;
    ddp_channel_record.attribute4 := p9_a31;
    ddp_channel_record.attribute5 := p9_a32;
    ddp_channel_record.attribute6 := p9_a33;
    ddp_channel_record.attribute7 := p9_a34;
    ddp_channel_record.attribute8 := p9_a35;
    ddp_channel_record.attribute9 := p9_a36;
    ddp_channel_record.attribute10 := p9_a37;
    ddp_channel_record.attribute11 := p9_a38;
    ddp_channel_record.attribute12 := p9_a39;
    ddp_channel_record.attribute13 := p9_a40;
    ddp_channel_record.attribute14 := p9_a41;
    ddp_channel_record.attribute15 := p9_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.add_groupchannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_channel(p_api_version  NUMBER
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
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.update_channel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_channel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  NUMBER
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  DATE
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  VARCHAR2
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  NUMBER
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  NUMBER
    , p10_a24 out nocopy  DATE
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  VARCHAR2
    , p10_a34 out nocopy  VARCHAR2
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  VARCHAR2
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  VARCHAR2
  )

  as
    ddx_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.get_channel(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_channel_record);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_channel_record.channel_id);
    p10_a1 := rosetta_g_miss_num_map(ddx_channel_record.object_version_number);
    p10_a2 := ddx_channel_record.channel_name;
    p10_a3 := ddx_channel_record.description;
    p10_a4 := ddx_channel_record.channel_type;
    p10_a5 := rosetta_g_miss_num_map(ddx_channel_record.channel_category_id);
    p10_a6 := ddx_channel_record.status;
    p10_a7 := rosetta_g_miss_num_map(ddx_channel_record.owner_user_id);
    p10_a8 := rosetta_g_miss_num_map(ddx_channel_record.default_approver_user_id);
    p10_a9 := ddx_channel_record.effective_start_date;
    p10_a10 := ddx_channel_record.expiration_date;
    p10_a11 := ddx_channel_record.access_level_type;
    p10_a12 := ddx_channel_record.pub_need_approval_flag;
    p10_a13 := ddx_channel_record.sub_need_approval_flag;
    p10_a14 := ddx_channel_record.match_on_all_criteria_flag;
    p10_a15 := ddx_channel_record.match_on_keyword_flag;
    p10_a16 := ddx_channel_record.match_on_author_flag;
    p10_a17 := ddx_channel_record.match_on_perspective_flag;
    p10_a18 := ddx_channel_record.match_on_item_type_flag;
    p10_a19 := ddx_channel_record.match_on_content_type_flag;
    p10_a20 := ddx_channel_record.match_on_time_flag;
    p10_a21 := rosetta_g_miss_num_map(ddx_channel_record.application_id);
    p10_a22 := ddx_channel_record.external_access_flag;
    p10_a23 := rosetta_g_miss_num_map(ddx_channel_record.item_match_count);
    p10_a24 := ddx_channel_record.last_match_time;
    p10_a25 := ddx_channel_record.notification_interval_type;
    p10_a26 := ddx_channel_record.last_notification_time;
    p10_a27 := ddx_channel_record.attribute_category;
    p10_a28 := ddx_channel_record.attribute1;
    p10_a29 := ddx_channel_record.attribute2;
    p10_a30 := ddx_channel_record.attribute3;
    p10_a31 := ddx_channel_record.attribute4;
    p10_a32 := ddx_channel_record.attribute5;
    p10_a33 := ddx_channel_record.attribute6;
    p10_a34 := ddx_channel_record.attribute7;
    p10_a35 := ddx_channel_record.attribute8;
    p10_a36 := ddx_channel_record.attribute9;
    p10_a37 := ddx_channel_record.attribute10;
    p10_a38 := ddx_channel_record.attribute11;
    p10_a39 := ddx_channel_record.attribute12;
    p10_a40 := ddx_channel_record.attribute13;
    p10_a41 := ddx_channel_record.attribute14;
    p10_a42 := ddx_channel_record.attribute15;
  end;

  procedure set_channelcontenttypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_content_type_id_array JTF_NUMBER_TABLE
  )

  as
    ddp_content_type_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p1(ddp_content_type_id_array, p_content_type_id_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.set_channelcontenttypes(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_content_type_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelcontenttypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_content_type_id_array out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_content_type_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.get_channelcontenttypes(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_content_type_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p1(ddx_content_type_id_array, x_content_type_id_array);
  end;

  procedure set_channelperspectives(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_perspective_id_array JTF_NUMBER_TABLE
  )

  as
    ddp_perspective_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p1(ddp_perspective_id_array, p_perspective_id_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.set_channelperspectives(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_perspective_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelperspectives(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_perspective_id_array out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_perspective_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.get_channelperspectives(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_perspective_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p1(ddx_perspective_id_array, x_perspective_id_array);
  end;

  procedure set_channelitemtypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_item_type_array JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_item_type_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p0(ddp_item_type_array, p_item_type_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.set_channelitemtypes(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_item_type_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelitemtypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_item_type_array out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_item_type_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.get_channelitemtypes(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_item_type_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p0(ddx_item_type_array, x_item_type_array);
  end;

  procedure set_channelkeywords(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_keywords_array JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_keywords_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p0(ddp_keywords_array, p_keywords_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.set_channelkeywords(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_keywords_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelkeywords(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_keywords_array out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_keywords_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.get_channelkeywords(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_keywords_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p0(ddx_keywords_array, x_keywords_array);
  end;

  procedure set_channelauthors(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_authors_array JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_authors_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p0(ddp_authors_array, p_authors_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.set_channelauthors(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_authors_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelauthors(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_authors_array out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_authors_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.get_channelauthors(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_authors_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p0(ddx_authors_array, x_authors_array);
  end;

  procedure get_itemsperchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_item_status  VARCHAR2
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  NUMBER
    , x_document_id_array out nocopy JTF_NUMBER_TABLE
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_subset_request_rec amv_channel_pvt.amv_request_obj_type;
    ddx_subset_return_rec amv_channel_pvt.amv_return_obj_type;
    ddx_document_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_subset_request_rec.records_requested := rosetta_g_miss_num_map(p11_a0);
    ddp_subset_request_rec.start_record_position := rosetta_g_miss_num_map(p11_a1);
    ddp_subset_request_rec.return_total_count_flag := p11_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.get_itemsperchannel(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      p_item_status,
      ddp_subset_request_rec,
      ddx_subset_return_rec,
      ddx_document_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    p12_a0 := rosetta_g_miss_num_map(ddx_subset_return_rec.returned_record_count);
    p12_a1 := rosetta_g_miss_num_map(ddx_subset_return_rec.next_record_position);
    p12_a2 := rosetta_g_miss_num_map(ddx_subset_return_rec.total_record_count);

    amv_channel_pvt_w.rosetta_table_copy_out_p1(ddx_document_id_array, x_document_id_array);
  end;

  procedure find_channels(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_sort_by  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_NUMBER_TABLE
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_NUMBER_TABLE
    , p11_a9 out nocopy JTF_DATE_TABLE
    , p11_a10 out nocopy JTF_DATE_TABLE
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a21 out nocopy JTF_NUMBER_TABLE
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a23 out nocopy JTF_NUMBER_TABLE
    , p11_a24 out nocopy JTF_DATE_TABLE
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a26 out nocopy JTF_DATE_TABLE
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  DATE := fnd_api.g_miss_date
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_criteria_rec amv_channel_pvt.amv_channel_obj_type;
    ddp_subset_request_rec amv_channel_pvt.amv_request_obj_type;
    ddx_subset_return_rec amv_channel_pvt.amv_return_obj_type;
    ddx_content_chan_array amv_channel_pvt.amv_channel_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_criteria_rec.channel_id := rosetta_g_miss_num_map(p7_a0);
    ddp_criteria_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_criteria_rec.channel_name := p7_a2;
    ddp_criteria_rec.description := p7_a3;
    ddp_criteria_rec.channel_type := p7_a4;
    ddp_criteria_rec.channel_category_id := rosetta_g_miss_num_map(p7_a5);
    ddp_criteria_rec.status := p7_a6;
    ddp_criteria_rec.owner_user_id := rosetta_g_miss_num_map(p7_a7);
    ddp_criteria_rec.default_approver_user_id := rosetta_g_miss_num_map(p7_a8);
    ddp_criteria_rec.effective_start_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_criteria_rec.expiration_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_criteria_rec.access_level_type := p7_a11;
    ddp_criteria_rec.pub_need_approval_flag := p7_a12;
    ddp_criteria_rec.sub_need_approval_flag := p7_a13;
    ddp_criteria_rec.match_on_all_criteria_flag := p7_a14;
    ddp_criteria_rec.match_on_keyword_flag := p7_a15;
    ddp_criteria_rec.match_on_author_flag := p7_a16;
    ddp_criteria_rec.match_on_perspective_flag := p7_a17;
    ddp_criteria_rec.match_on_item_type_flag := p7_a18;
    ddp_criteria_rec.match_on_content_type_flag := p7_a19;
    ddp_criteria_rec.match_on_time_flag := p7_a20;
    ddp_criteria_rec.application_id := rosetta_g_miss_num_map(p7_a21);
    ddp_criteria_rec.external_access_flag := p7_a22;
    ddp_criteria_rec.item_match_count := rosetta_g_miss_num_map(p7_a23);
    ddp_criteria_rec.last_match_time := rosetta_g_miss_date_in_map(p7_a24);
    ddp_criteria_rec.notification_interval_type := p7_a25;
    ddp_criteria_rec.last_notification_time := rosetta_g_miss_date_in_map(p7_a26);
    ddp_criteria_rec.attribute_category := p7_a27;
    ddp_criteria_rec.attribute1 := p7_a28;
    ddp_criteria_rec.attribute2 := p7_a29;
    ddp_criteria_rec.attribute3 := p7_a30;
    ddp_criteria_rec.attribute4 := p7_a31;
    ddp_criteria_rec.attribute5 := p7_a32;
    ddp_criteria_rec.attribute6 := p7_a33;
    ddp_criteria_rec.attribute7 := p7_a34;
    ddp_criteria_rec.attribute8 := p7_a35;
    ddp_criteria_rec.attribute9 := p7_a36;
    ddp_criteria_rec.attribute10 := p7_a37;
    ddp_criteria_rec.attribute11 := p7_a38;
    ddp_criteria_rec.attribute12 := p7_a39;
    ddp_criteria_rec.attribute13 := p7_a40;
    ddp_criteria_rec.attribute14 := p7_a41;
    ddp_criteria_rec.attribute15 := p7_a42;


    ddp_subset_request_rec.records_requested := rosetta_g_miss_num_map(p9_a0);
    ddp_subset_request_rec.start_record_position := rosetta_g_miss_num_map(p9_a1);
    ddp_subset_request_rec.return_total_count_flag := p9_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_channel_pvt.find_channels(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_criteria_rec,
      p_sort_by,
      ddp_subset_request_rec,
      ddx_subset_return_rec,
      ddx_content_chan_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_subset_return_rec.returned_record_count);
    p10_a1 := rosetta_g_miss_num_map(ddx_subset_return_rec.next_record_position);
    p10_a2 := rosetta_g_miss_num_map(ddx_subset_return_rec.total_record_count);

    amv_channel_pvt_w.rosetta_table_copy_out_p5(ddx_content_chan_array, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      );
  end;

end amv_channel_pvt_w;

/
