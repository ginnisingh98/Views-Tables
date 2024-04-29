--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_FIELD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_FIELD_PVT_W" as
  /* $Header: amswlsfb.pls 115.13 2004/03/18 20:30:01 usingh ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_list_src_field_pvt.list_src_field_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).list_source_field_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).de_list_source_type_code := a7(indx);
          t(ddindx).list_source_type_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).field_table_name := a9(indx);
          t(ddindx).field_column_name := a10(indx);
          t(ddindx).source_column_name := a11(indx);
          t(ddindx).source_column_meaning := a12(indx);
          t(ddindx).enabled_flag := a13(indx);
          t(ddindx).start_position := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).end_position := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).analytics_flag := a16(indx);
          t(ddindx).auto_binning_flag := a17(indx);
          t(ddindx).no_of_buckets := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).field_data_type := a19(indx);
          t(ddindx).field_data_size := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).default_ui_control := a21(indx);
          t(ddindx).field_lookup_type := a22(indx);
          t(ddindx).field_lookup_type_view_name := a23(indx);
          t(ddindx).allow_label_override := a24(indx);
          t(ddindx).field_usage_type := a25(indx);
          t(ddindx).dialog_enabled := a26(indx);
          t(ddindx).attb_lov_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).lov_defined_flag := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_list_src_field_pvt.list_src_field_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).list_source_field_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := t(ddindx).de_list_source_type_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).list_source_type_id);
          a9(indx) := t(ddindx).field_table_name;
          a10(indx) := t(ddindx).field_column_name;
          a11(indx) := t(ddindx).source_column_name;
          a12(indx) := t(ddindx).source_column_meaning;
          a13(indx) := t(ddindx).enabled_flag;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).start_position);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).end_position);
          a16(indx) := t(ddindx).analytics_flag;
          a17(indx) := t(ddindx).auto_binning_flag;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).no_of_buckets);
          a19(indx) := t(ddindx).field_data_type;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).field_data_size);
          a21(indx) := t(ddindx).default_ui_control;
          a22(indx) := t(ddindx).field_lookup_type;
          a23(indx) := t(ddindx).field_lookup_type_view_name;
          a24(indx) := t(ddindx).allow_label_override;
          a25(indx) := t(ddindx).field_usage_type;
          a26(indx) := t(ddindx).dialog_enabled;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).attb_lov_id);
          a28(indx) := t(ddindx).lov_defined_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_list_src_field(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_list_source_field_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_list_src_field_rec ams_list_src_field_pvt.list_src_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_src_field_rec.list_source_field_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_src_field_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_list_src_field_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_list_src_field_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_list_src_field_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_list_src_field_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_list_src_field_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_list_src_field_rec.de_list_source_type_code := p7_a7;
    ddp_list_src_field_rec.list_source_type_id := rosetta_g_miss_num_map(p7_a8);
    ddp_list_src_field_rec.field_table_name := p7_a9;
    ddp_list_src_field_rec.field_column_name := p7_a10;
    ddp_list_src_field_rec.source_column_name := p7_a11;
    ddp_list_src_field_rec.source_column_meaning := p7_a12;
    ddp_list_src_field_rec.enabled_flag := p7_a13;
    ddp_list_src_field_rec.start_position := rosetta_g_miss_num_map(p7_a14);
    ddp_list_src_field_rec.end_position := rosetta_g_miss_num_map(p7_a15);
    ddp_list_src_field_rec.analytics_flag := p7_a16;
    ddp_list_src_field_rec.auto_binning_flag := p7_a17;
    ddp_list_src_field_rec.no_of_buckets := rosetta_g_miss_num_map(p7_a18);
    ddp_list_src_field_rec.field_data_type := p7_a19;
    ddp_list_src_field_rec.field_data_size := rosetta_g_miss_num_map(p7_a20);
    ddp_list_src_field_rec.default_ui_control := p7_a21;
    ddp_list_src_field_rec.field_lookup_type := p7_a22;
    ddp_list_src_field_rec.field_lookup_type_view_name := p7_a23;
    ddp_list_src_field_rec.allow_label_override := p7_a24;
    ddp_list_src_field_rec.field_usage_type := p7_a25;
    ddp_list_src_field_rec.dialog_enabled := p7_a26;
    ddp_list_src_field_rec.attb_lov_id := rosetta_g_miss_num_map(p7_a27);
    ddp_list_src_field_rec.lov_defined_flag := p7_a28;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_src_field_pvt.create_list_src_field(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_src_field_rec,
      x_list_source_field_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_list_src_field(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_list_src_field_rec ams_list_src_field_pvt.list_src_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_src_field_rec.list_source_field_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_src_field_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_list_src_field_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_list_src_field_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_list_src_field_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_list_src_field_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_list_src_field_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_list_src_field_rec.de_list_source_type_code := p7_a7;
    ddp_list_src_field_rec.list_source_type_id := rosetta_g_miss_num_map(p7_a8);
    ddp_list_src_field_rec.field_table_name := p7_a9;
    ddp_list_src_field_rec.field_column_name := p7_a10;
    ddp_list_src_field_rec.source_column_name := p7_a11;
    ddp_list_src_field_rec.source_column_meaning := p7_a12;
    ddp_list_src_field_rec.enabled_flag := p7_a13;
    ddp_list_src_field_rec.start_position := rosetta_g_miss_num_map(p7_a14);
    ddp_list_src_field_rec.end_position := rosetta_g_miss_num_map(p7_a15);
    ddp_list_src_field_rec.analytics_flag := p7_a16;
    ddp_list_src_field_rec.auto_binning_flag := p7_a17;
    ddp_list_src_field_rec.no_of_buckets := rosetta_g_miss_num_map(p7_a18);
    ddp_list_src_field_rec.field_data_type := p7_a19;
    ddp_list_src_field_rec.field_data_size := rosetta_g_miss_num_map(p7_a20);
    ddp_list_src_field_rec.default_ui_control := p7_a21;
    ddp_list_src_field_rec.field_lookup_type := p7_a22;
    ddp_list_src_field_rec.field_lookup_type_view_name := p7_a23;
    ddp_list_src_field_rec.allow_label_override := p7_a24;
    ddp_list_src_field_rec.field_usage_type := p7_a25;
    ddp_list_src_field_rec.dialog_enabled := p7_a26;
    ddp_list_src_field_rec.attb_lov_id := rosetta_g_miss_num_map(p7_a27);
    ddp_list_src_field_rec.lov_defined_flag := p7_a28;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_src_field_pvt.update_list_src_field(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_src_field_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_list_src_field(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  NUMBER := 0-1962.0724
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  NUMBER := 0-1962.0724
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_list_src_field_rec ams_list_src_field_pvt.list_src_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_list_src_field_rec.list_source_field_id := rosetta_g_miss_num_map(p3_a0);
    ddp_list_src_field_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_list_src_field_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_list_src_field_rec.creation_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_list_src_field_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_list_src_field_rec.last_update_login := rosetta_g_miss_num_map(p3_a5);
    ddp_list_src_field_rec.object_version_number := rosetta_g_miss_num_map(p3_a6);
    ddp_list_src_field_rec.de_list_source_type_code := p3_a7;
    ddp_list_src_field_rec.list_source_type_id := rosetta_g_miss_num_map(p3_a8);
    ddp_list_src_field_rec.field_table_name := p3_a9;
    ddp_list_src_field_rec.field_column_name := p3_a10;
    ddp_list_src_field_rec.source_column_name := p3_a11;
    ddp_list_src_field_rec.source_column_meaning := p3_a12;
    ddp_list_src_field_rec.enabled_flag := p3_a13;
    ddp_list_src_field_rec.start_position := rosetta_g_miss_num_map(p3_a14);
    ddp_list_src_field_rec.end_position := rosetta_g_miss_num_map(p3_a15);
    ddp_list_src_field_rec.analytics_flag := p3_a16;
    ddp_list_src_field_rec.auto_binning_flag := p3_a17;
    ddp_list_src_field_rec.no_of_buckets := rosetta_g_miss_num_map(p3_a18);
    ddp_list_src_field_rec.field_data_type := p3_a19;
    ddp_list_src_field_rec.field_data_size := rosetta_g_miss_num_map(p3_a20);
    ddp_list_src_field_rec.default_ui_control := p3_a21;
    ddp_list_src_field_rec.field_lookup_type := p3_a22;
    ddp_list_src_field_rec.field_lookup_type_view_name := p3_a23;
    ddp_list_src_field_rec.allow_label_override := p3_a24;
    ddp_list_src_field_rec.field_usage_type := p3_a25;
    ddp_list_src_field_rec.dialog_enabled := p3_a26;
    ddp_list_src_field_rec.attb_lov_id := rosetta_g_miss_num_map(p3_a27);
    ddp_list_src_field_rec.lov_defined_flag := p3_a28;




    -- here's the delegated call to the old PL/SQL routine
    ams_list_src_field_pvt.validate_list_src_field(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_list_src_field_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_list_src_field_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_list_src_field_rec ams_list_src_field_pvt.list_src_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_list_src_field_rec.list_source_field_id := rosetta_g_miss_num_map(p0_a0);
    ddp_list_src_field_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_list_src_field_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_list_src_field_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_list_src_field_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_list_src_field_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_list_src_field_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_list_src_field_rec.de_list_source_type_code := p0_a7;
    ddp_list_src_field_rec.list_source_type_id := rosetta_g_miss_num_map(p0_a8);
    ddp_list_src_field_rec.field_table_name := p0_a9;
    ddp_list_src_field_rec.field_column_name := p0_a10;
    ddp_list_src_field_rec.source_column_name := p0_a11;
    ddp_list_src_field_rec.source_column_meaning := p0_a12;
    ddp_list_src_field_rec.enabled_flag := p0_a13;
    ddp_list_src_field_rec.start_position := rosetta_g_miss_num_map(p0_a14);
    ddp_list_src_field_rec.end_position := rosetta_g_miss_num_map(p0_a15);
    ddp_list_src_field_rec.analytics_flag := p0_a16;
    ddp_list_src_field_rec.auto_binning_flag := p0_a17;
    ddp_list_src_field_rec.no_of_buckets := rosetta_g_miss_num_map(p0_a18);
    ddp_list_src_field_rec.field_data_type := p0_a19;
    ddp_list_src_field_rec.field_data_size := rosetta_g_miss_num_map(p0_a20);
    ddp_list_src_field_rec.default_ui_control := p0_a21;
    ddp_list_src_field_rec.field_lookup_type := p0_a22;
    ddp_list_src_field_rec.field_lookup_type_view_name := p0_a23;
    ddp_list_src_field_rec.allow_label_override := p0_a24;
    ddp_list_src_field_rec.field_usage_type := p0_a25;
    ddp_list_src_field_rec.dialog_enabled := p0_a26;
    ddp_list_src_field_rec.attb_lov_id := rosetta_g_miss_num_map(p0_a27);
    ddp_list_src_field_rec.lov_defined_flag := p0_a28;



    -- here's the delegated call to the old PL/SQL routine
    ams_list_src_field_pvt.check_list_src_field_items(ddp_list_src_field_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_list_src_field_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_list_src_field_rec ams_list_src_field_pvt.list_src_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_list_src_field_rec.list_source_field_id := rosetta_g_miss_num_map(p5_a0);
    ddp_list_src_field_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_list_src_field_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_list_src_field_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_list_src_field_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_list_src_field_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_list_src_field_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_list_src_field_rec.de_list_source_type_code := p5_a7;
    ddp_list_src_field_rec.list_source_type_id := rosetta_g_miss_num_map(p5_a8);
    ddp_list_src_field_rec.field_table_name := p5_a9;
    ddp_list_src_field_rec.field_column_name := p5_a10;
    ddp_list_src_field_rec.source_column_name := p5_a11;
    ddp_list_src_field_rec.source_column_meaning := p5_a12;
    ddp_list_src_field_rec.enabled_flag := p5_a13;
    ddp_list_src_field_rec.start_position := rosetta_g_miss_num_map(p5_a14);
    ddp_list_src_field_rec.end_position := rosetta_g_miss_num_map(p5_a15);
    ddp_list_src_field_rec.analytics_flag := p5_a16;
    ddp_list_src_field_rec.auto_binning_flag := p5_a17;
    ddp_list_src_field_rec.no_of_buckets := rosetta_g_miss_num_map(p5_a18);
    ddp_list_src_field_rec.field_data_type := p5_a19;
    ddp_list_src_field_rec.field_data_size := rosetta_g_miss_num_map(p5_a20);
    ddp_list_src_field_rec.default_ui_control := p5_a21;
    ddp_list_src_field_rec.field_lookup_type := p5_a22;
    ddp_list_src_field_rec.field_lookup_type_view_name := p5_a23;
    ddp_list_src_field_rec.allow_label_override := p5_a24;
    ddp_list_src_field_rec.field_usage_type := p5_a25;
    ddp_list_src_field_rec.dialog_enabled := p5_a26;
    ddp_list_src_field_rec.attb_lov_id := rosetta_g_miss_num_map(p5_a27);
    ddp_list_src_field_rec.lov_defined_flag := p5_a28;

    -- here's the delegated call to the old PL/SQL routine
    ams_list_src_field_pvt.validate_list_src_field_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_src_field_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_list_src_field_pvt_w;

/
