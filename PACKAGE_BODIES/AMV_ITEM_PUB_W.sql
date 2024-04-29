--------------------------------------------------------
--  DDL for Package Body AMV_ITEM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_ITEM_PUB_W" as
  /* $Header: amvwitmb.pls 120.2 2005/06/30 08:04 appldev ship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy amv_item_pub.amv_char_varray_type, a0 JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_item_pub.amv_char_varray_type();
  else
      if a0.count > 0 then
      t := amv_item_pub.amv_char_varray_type();
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
  procedure rosetta_table_copy_out_p0(t amv_item_pub.amv_char_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_4000) as
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

  procedure rosetta_table_copy_in_p1(t out nocopy amv_item_pub.amv_number_varray_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_item_pub.amv_number_varray_type();
  else
      if a0.count > 0 then
      t := amv_item_pub.amv_number_varray_type();
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
  procedure rosetta_table_copy_out_p1(t amv_item_pub.amv_number_varray_type, a0 out nocopy JTF_NUMBER_TABLE) as
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

  procedure rosetta_table_copy_in_p6(t out nocopy amv_item_pub.amv_simple_item_obj_varray, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_2000
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_2000
    , a25 JTF_VARCHAR2_TABLE_2000
    , a26 JTF_VARCHAR2_TABLE_2000
    , a27 JTF_VARCHAR2_TABLE_2000
    , a28 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_item_pub.amv_simple_item_obj_varray();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_item_pub.amv_simple_item_obj_varray();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).application_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).external_access_flag := a8(indx);
          t(ddindx).item_name := a9(indx);
          t(ddindx).description := a10(indx);
          t(ddindx).text_string := a11(indx);
          t(ddindx).language_code := a12(indx);
          t(ddindx).status_code := a13(indx);
          t(ddindx).effective_start_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).item_type := a16(indx);
          t(ddindx).url_string := a17(indx);
          t(ddindx).publication_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).priority := a19(indx);
          t(ddindx).content_type_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).owner_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).default_approver_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).item_destination_type := a23(indx);
          t(ddindx).file_id_list := a24(indx);
          t(ddindx).persp_id_list := a25(indx);
          t(ddindx).persp_name_list := a26(indx);
          t(ddindx).author_list := a27(indx);
          t(ddindx).keyword_list := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t amv_item_pub.amv_simple_item_obj_varray, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_2000
    , a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , a28 out nocopy JTF_VARCHAR2_TABLE_2000
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
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_2000();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_2000();
    a25 := JTF_VARCHAR2_TABLE_2000();
    a26 := JTF_VARCHAR2_TABLE_2000();
    a27 := JTF_VARCHAR2_TABLE_2000();
    a28 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_2000();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_2000();
      a25 := JTF_VARCHAR2_TABLE_2000();
      a26 := JTF_VARCHAR2_TABLE_2000();
      a27 := JTF_VARCHAR2_TABLE_2000();
      a28 := JTF_VARCHAR2_TABLE_2000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := t(ddindx).last_update_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).application_id);
          a8(indx) := t(ddindx).external_access_flag;
          a9(indx) := t(ddindx).item_name;
          a10(indx) := t(ddindx).description;
          a11(indx) := t(ddindx).text_string;
          a12(indx) := t(ddindx).language_code;
          a13(indx) := t(ddindx).status_code;
          a14(indx) := t(ddindx).effective_start_date;
          a15(indx) := t(ddindx).expiration_date;
          a16(indx) := t(ddindx).item_type;
          a17(indx) := t(ddindx).url_string;
          a18(indx) := t(ddindx).publication_date;
          a19(indx) := t(ddindx).priority;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).content_type_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).owner_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).default_approver_id);
          a23(indx) := t(ddindx).item_destination_type;
          a24(indx) := t(ddindx).file_id_list;
          a25(indx) := t(ddindx).persp_id_list;
          a26(indx) := t(ddindx).persp_name_list;
          a27(indx) := t(ddindx).author_list;
          a28(indx) := t(ddindx).keyword_list;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy amv_item_pub.amv_nameid_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_item_pub.amv_nameid_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_item_pub.amv_nameid_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).name := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t amv_item_pub.amv_nameid_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure create_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id_array JTF_NUMBER_TABLE
    , p_file_array JTF_NUMBER_TABLE
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p_author_array JTF_VARCHAR2_TABLE_4000
    , p_keyword_array JTF_VARCHAR2_TABLE_4000
    , x_item_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  DATE := fnd_api.g_miss_date
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  DATE := fnd_api.g_miss_date
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  DATE := fnd_api.g_miss_date
    , p8_a15  DATE := fnd_api.g_miss_date
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  DATE := fnd_api.g_miss_date
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  NUMBER := 0-1962.0724
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_id_array amv_item_pub.amv_number_varray_type;
    ddp_item_obj amv_item_pub.amv_item_obj_type;
    ddp_file_array amv_item_pub.amv_number_varray_type;
    ddp_persp_array amv_item_pub.amv_nameid_varray_type;
    ddp_author_array amv_item_pub.amv_char_varray_type;
    ddp_keyword_array amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    amv_item_pub_w.rosetta_table_copy_in_p1(ddp_channel_id_array, p_channel_id_array);

    ddp_item_obj.item_id := rosetta_g_miss_num_map(p8_a0);
    ddp_item_obj.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_item_obj.creation_date := rosetta_g_miss_date_in_map(p8_a2);
    ddp_item_obj.created_by := rosetta_g_miss_num_map(p8_a3);
    ddp_item_obj.last_update_date := rosetta_g_miss_date_in_map(p8_a4);
    ddp_item_obj.last_updated_by := rosetta_g_miss_num_map(p8_a5);
    ddp_item_obj.last_update_login := rosetta_g_miss_num_map(p8_a6);
    ddp_item_obj.application_id := rosetta_g_miss_num_map(p8_a7);
    ddp_item_obj.external_access_flag := p8_a8;
    ddp_item_obj.item_name := p8_a9;
    ddp_item_obj.description := p8_a10;
    ddp_item_obj.text_string := p8_a11;
    ddp_item_obj.language_code := p8_a12;
    ddp_item_obj.status_code := p8_a13;
    ddp_item_obj.effective_start_date := rosetta_g_miss_date_in_map(p8_a14);
    ddp_item_obj.expiration_date := rosetta_g_miss_date_in_map(p8_a15);
    ddp_item_obj.item_type := p8_a16;
    ddp_item_obj.url_string := p8_a17;
    ddp_item_obj.publication_date := rosetta_g_miss_date_in_map(p8_a18);
    ddp_item_obj.priority := p8_a19;
    ddp_item_obj.content_type_id := rosetta_g_miss_num_map(p8_a20);
    ddp_item_obj.owner_id := rosetta_g_miss_num_map(p8_a21);
    ddp_item_obj.default_approver_id := rosetta_g_miss_num_map(p8_a22);
    ddp_item_obj.item_destination_type := p8_a23;

    amv_item_pub_w.rosetta_table_copy_in_p1(ddp_file_array, p_file_array);

    amv_item_pub_w.rosetta_table_copy_in_p8(ddp_persp_array, p10_a0
      , p10_a1
      );

    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_author_array, p_author_array);

    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_keyword_array, p_keyword_array);


    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.create_item(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_id_array,
      ddp_item_obj,
      ddp_file_array,
      ddp_persp_array,
      ddp_author_array,
      ddp_keyword_array,
      x_item_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure update_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id_array JTF_NUMBER_TABLE
    , p_file_array JTF_NUMBER_TABLE
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p_author_array JTF_VARCHAR2_TABLE_4000
    , p_keyword_array JTF_VARCHAR2_TABLE_4000
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  DATE := fnd_api.g_miss_date
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  DATE := fnd_api.g_miss_date
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  DATE := fnd_api.g_miss_date
    , p8_a15  DATE := fnd_api.g_miss_date
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  DATE := fnd_api.g_miss_date
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  NUMBER := 0-1962.0724
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_id_array amv_item_pub.amv_number_varray_type;
    ddp_item_obj amv_item_pub.amv_item_obj_type;
    ddp_file_array amv_item_pub.amv_number_varray_type;
    ddp_persp_array amv_item_pub.amv_nameid_varray_type;
    ddp_author_array amv_item_pub.amv_char_varray_type;
    ddp_keyword_array amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    amv_item_pub_w.rosetta_table_copy_in_p1(ddp_channel_id_array, p_channel_id_array);

    ddp_item_obj.item_id := rosetta_g_miss_num_map(p8_a0);
    ddp_item_obj.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_item_obj.creation_date := rosetta_g_miss_date_in_map(p8_a2);
    ddp_item_obj.created_by := rosetta_g_miss_num_map(p8_a3);
    ddp_item_obj.last_update_date := rosetta_g_miss_date_in_map(p8_a4);
    ddp_item_obj.last_updated_by := rosetta_g_miss_num_map(p8_a5);
    ddp_item_obj.last_update_login := rosetta_g_miss_num_map(p8_a6);
    ddp_item_obj.application_id := rosetta_g_miss_num_map(p8_a7);
    ddp_item_obj.external_access_flag := p8_a8;
    ddp_item_obj.item_name := p8_a9;
    ddp_item_obj.description := p8_a10;
    ddp_item_obj.text_string := p8_a11;
    ddp_item_obj.language_code := p8_a12;
    ddp_item_obj.status_code := p8_a13;
    ddp_item_obj.effective_start_date := rosetta_g_miss_date_in_map(p8_a14);
    ddp_item_obj.expiration_date := rosetta_g_miss_date_in_map(p8_a15);
    ddp_item_obj.item_type := p8_a16;
    ddp_item_obj.url_string := p8_a17;
    ddp_item_obj.publication_date := rosetta_g_miss_date_in_map(p8_a18);
    ddp_item_obj.priority := p8_a19;
    ddp_item_obj.content_type_id := rosetta_g_miss_num_map(p8_a20);
    ddp_item_obj.owner_id := rosetta_g_miss_num_map(p8_a21);
    ddp_item_obj.default_approver_id := rosetta_g_miss_num_map(p8_a22);
    ddp_item_obj.item_destination_type := p8_a23;

    amv_item_pub_w.rosetta_table_copy_in_p1(ddp_file_array, p_file_array);

    amv_item_pub_w.rosetta_table_copy_in_p8(ddp_persp_array, p10_a0
      , p10_a1
      );

    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_author_array, p_author_array);

    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_keyword_array, p_keyword_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.update_item(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_id_array,
      ddp_item_obj,
      ddp_file_array,
      ddp_persp_array,
      ddp_author_array,
      ddp_keyword_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure get_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  DATE
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  DATE
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  NUMBER
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  VARCHAR2
    , x_file_array out nocopy JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , x_author_array out nocopy JTF_VARCHAR2_TABLE_4000
    , x_keyword_array out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_item_obj amv_item_pub.amv_item_obj_type;
    ddx_file_array amv_item_pub.amv_number_varray_type;
    ddx_persp_array amv_item_pub.amv_nameid_varray_type;
    ddx_author_array amv_item_pub.amv_char_varray_type;
    ddx_keyword_array amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.get_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddx_item_obj,
      ddx_file_array,
      ddx_persp_array,
      ddx_author_array,
      ddx_keyword_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_item_obj.item_id);
    p7_a1 := rosetta_g_miss_num_map(ddx_item_obj.object_version_number);
    p7_a2 := ddx_item_obj.creation_date;
    p7_a3 := rosetta_g_miss_num_map(ddx_item_obj.created_by);
    p7_a4 := ddx_item_obj.last_update_date;
    p7_a5 := rosetta_g_miss_num_map(ddx_item_obj.last_updated_by);
    p7_a6 := rosetta_g_miss_num_map(ddx_item_obj.last_update_login);
    p7_a7 := rosetta_g_miss_num_map(ddx_item_obj.application_id);
    p7_a8 := ddx_item_obj.external_access_flag;
    p7_a9 := ddx_item_obj.item_name;
    p7_a10 := ddx_item_obj.description;
    p7_a11 := ddx_item_obj.text_string;
    p7_a12 := ddx_item_obj.language_code;
    p7_a13 := ddx_item_obj.status_code;
    p7_a14 := ddx_item_obj.effective_start_date;
    p7_a15 := ddx_item_obj.expiration_date;
    p7_a16 := ddx_item_obj.item_type;
    p7_a17 := ddx_item_obj.url_string;
    p7_a18 := ddx_item_obj.publication_date;
    p7_a19 := ddx_item_obj.priority;
    p7_a20 := rosetta_g_miss_num_map(ddx_item_obj.content_type_id);
    p7_a21 := rosetta_g_miss_num_map(ddx_item_obj.owner_id);
    p7_a22 := rosetta_g_miss_num_map(ddx_item_obj.default_approver_id);
    p7_a23 := ddx_item_obj.item_destination_type;

    amv_item_pub_w.rosetta_table_copy_out_p1(ddx_file_array, x_file_array);

    amv_item_pub_w.rosetta_table_copy_out_p8(ddx_persp_array, p9_a0
      , p9_a1
      );

    amv_item_pub_w.rosetta_table_copy_out_p0(ddx_author_array, x_author_array);

    amv_item_pub_w.rosetta_table_copy_out_p0(ddx_keyword_array, x_keyword_array);
  end;

  procedure find_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_name  VARCHAR2
    , p_description  VARCHAR2
    , p_item_type  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_DATE_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_DATE_TABLE
    , p11_a5 out nocopy JTF_NUMBER_TABLE
    , p11_a6 out nocopy JTF_NUMBER_TABLE
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_DATE_TABLE
    , p11_a15 out nocopy JTF_DATE_TABLE
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a18 out nocopy JTF_DATE_TABLE
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_NUMBER_TABLE
    , p11_a21 out nocopy JTF_NUMBER_TABLE
    , p11_a22 out nocopy JTF_NUMBER_TABLE
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_subset_request_obj amv_item_pub.amv_request_obj_type;
    ddx_subset_return_obj amv_item_pub.amv_return_obj_type;
    ddx_item_obj_array amv_item_pub.amv_simple_item_obj_varray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_subset_request_obj.records_requested := rosetta_g_miss_num_map(p9_a0);
    ddp_subset_request_obj.start_record_position := rosetta_g_miss_num_map(p9_a1);
    ddp_subset_request_obj.return_total_count_flag := p9_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.find_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_name,
      p_description,
      p_item_type,
      ddp_subset_request_obj,
      ddx_subset_return_obj,
      ddx_item_obj_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_subset_return_obj.returned_record_count);
    p10_a1 := rosetta_g_miss_num_map(ddx_subset_return_obj.next_record_position);
    p10_a2 := rosetta_g_miss_num_map(ddx_subset_return_obj.total_record_count);

    amv_item_pub_w.rosetta_table_copy_out_p6(ddx_item_obj_array, p11_a0
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
      );
  end;

  procedure add_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_varray JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_keyword_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_keyword_varray, p_keyword_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.add_itemkeyword(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddp_keyword_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure delete_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_varray JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_keyword_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_keyword_varray, p_keyword_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.delete_itemkeyword(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddp_keyword_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure replace_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_varray JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_keyword_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_keyword_varray, p_keyword_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.replace_itemkeyword(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddp_keyword_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , x_keyword_varray out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_keyword_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.get_itemkeyword(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddx_keyword_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    amv_item_pub_w.rosetta_table_copy_out_p0(ddx_keyword_varray, x_keyword_varray);
  end;

  procedure add_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_author_varray JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_author_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_author_varray, p_author_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.add_itemauthor(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddp_author_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure delete_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_author_varray JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_author_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_author_varray, p_author_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.delete_itemauthor(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddp_author_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure replace_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_author_varray JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_author_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_in_p0(ddp_author_varray, p_author_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.replace_itemauthor(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddp_author_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , x_author_varray out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_author_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.get_itemauthor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddx_author_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    amv_item_pub_w.rosetta_table_copy_out_p0(ddx_author_varray, x_author_varray);
  end;

  procedure add_itemfile(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_item_id  NUMBER
    , p_file_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_file_id_varray amv_item_pub.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    amv_item_pub_w.rosetta_table_copy_in_p1(ddp_file_id_varray, p_file_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.add_itemfile(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_application_id,
      p_item_id,
      ddp_file_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure delete_itemfile(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_file_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_file_id_varray amv_item_pub.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_in_p1(ddp_file_id_varray, p_file_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.delete_itemfile(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddp_file_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure replace_itemfile(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_file_id_varray JTF_NUMBER_TABLE
  )

  as
    ddp_file_id_varray amv_item_pub.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_in_p1(ddp_file_id_varray, p_file_id_varray);

    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.replace_itemfile(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddp_file_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_itemfile(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , x_file_id_varray out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_file_id_varray amv_item_pub.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.get_itemfile(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      ddx_file_id_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    amv_item_pub_w.rosetta_table_copy_out_p1(ddx_file_id_varray, x_file_id_varray);
  end;

  procedure get_usermessage(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_id  NUMBER
    , x_item_id_varray out nocopy JTF_NUMBER_TABLE
    , x_message_varray out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_item_id_varray amv_item_pub.amv_number_varray_type;
    ddx_message_varray amv_item_pub.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.get_usermessage(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_user_id,
      ddx_item_id_varray,
      ddx_message_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    amv_item_pub_w.rosetta_table_copy_out_p1(ddx_item_id_varray, x_item_id_varray);

    amv_item_pub_w.rosetta_table_copy_out_p0(ddx_message_varray, x_message_varray);
  end;

  procedure get_usermessage2(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_id  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_DATE_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_DATE_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_DATE_TABLE
    , p7_a15 out nocopy JTF_DATE_TABLE
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a18 out nocopy JTF_DATE_TABLE
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a20 out nocopy JTF_NUMBER_TABLE
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_NUMBER_TABLE
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddx_item_varray amv_item_pub.amv_simple_item_obj_varray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.get_usermessage2(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_user_id,
      ddx_item_varray);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    amv_item_pub_w.rosetta_table_copy_out_p6(ddx_item_varray, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      );
  end;

  procedure get_channelsperitem(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_item_id  NUMBER
    , p_match_type  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_channel_array amv_item_pub.amv_nameid_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    amv_item_pub.get_channelsperitem(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_item_id,
      p_match_type,
      ddx_channel_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_item_pub_w.rosetta_table_copy_out_p8(ddx_channel_array, p8_a0
      , p8_a1
      );
  end;

end amv_item_pub_w;

/
