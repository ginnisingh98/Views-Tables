--------------------------------------------------------
--  DDL for Package Body OZF_TASK_GROUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TASK_GROUP_PVT_W" as
  /* $Header: ozfwttgb.pls 115.0 2003/06/26 05:12:58 mchang noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ozf_task_group_pvt.task_group_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ozf_task_group_pvt.task_group_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ozf_task_group_pvt.task_group_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_template_group_id := a0(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := a2(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := a4(indx);
          t(ddindx).last_update_login := a5(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).source_object_type_code := a8(indx);
          t(ddindx).object_version_number := a9(indx);
          t(ddindx).attribute_category := a10(indx);
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          t(ddindx).reason_type := a26(indx);
          t(ddindx).template_group_name := a27(indx);
          t(ddindx).description := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_task_group_pvt.task_group_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_4000
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
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_4000();
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
          a0(indx) := t(ddindx).task_template_group_id;
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := t(ddindx).last_updated_by;
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := t(ddindx).created_by;
          a5(indx) := t(ddindx).last_update_login;
          a6(indx) := t(ddindx).start_date_active;
          a7(indx) := t(ddindx).end_date_active;
          a8(indx) := t(ddindx).source_object_type_code;
          a9(indx) := t(ddindx).object_version_number;
          a10(indx) := t(ddindx).attribute_category;
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          a26(indx) := t(ddindx).reason_type;
          a27(indx) := t(ddindx).template_group_name;
          a28(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p5(t out nocopy ozf_task_group_pvt.ozf_sort_data, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ozf_task_group_pvt.ozf_sort_data();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ozf_task_group_pvt.ozf_sort_data();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).field_name := a0(indx);
          t(ddindx).asc_dsc_flag := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ozf_task_group_pvt.ozf_sort_data, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).field_name;
          a1(indx) := t(ddindx).asc_dsc_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_task_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  DATE
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , x_task_template_group_id out nocopy  NUMBER
  )

  as
    ddp_task_group ozf_task_group_pvt.task_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_task_group.task_template_group_id := p7_a0;
    ddp_task_group.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_task_group.last_updated_by := p7_a2;
    ddp_task_group.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_task_group.created_by := p7_a4;
    ddp_task_group.last_update_login := p7_a5;
    ddp_task_group.start_date_active := rosetta_g_miss_date_in_map(p7_a6);
    ddp_task_group.end_date_active := rosetta_g_miss_date_in_map(p7_a7);
    ddp_task_group.source_object_type_code := p7_a8;
    ddp_task_group.object_version_number := p7_a9;
    ddp_task_group.attribute_category := p7_a10;
    ddp_task_group.attribute1 := p7_a11;
    ddp_task_group.attribute2 := p7_a12;
    ddp_task_group.attribute3 := p7_a13;
    ddp_task_group.attribute4 := p7_a14;
    ddp_task_group.attribute5 := p7_a15;
    ddp_task_group.attribute6 := p7_a16;
    ddp_task_group.attribute7 := p7_a17;
    ddp_task_group.attribute8 := p7_a18;
    ddp_task_group.attribute9 := p7_a19;
    ddp_task_group.attribute10 := p7_a20;
    ddp_task_group.attribute11 := p7_a21;
    ddp_task_group.attribute12 := p7_a22;
    ddp_task_group.attribute13 := p7_a23;
    ddp_task_group.attribute14 := p7_a24;
    ddp_task_group.attribute15 := p7_a25;
    ddp_task_group.reason_type := p7_a26;
    ddp_task_group.template_group_name := p7_a27;
    ddp_task_group.description := p7_a28;


    -- here's the delegated call to the old PL/SQL routine
    ozf_task_group_pvt.create_task_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_task_group,
      x_task_template_group_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_task_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  DATE
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_task_group ozf_task_group_pvt.task_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_task_group.task_template_group_id := p7_a0;
    ddp_task_group.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_task_group.last_updated_by := p7_a2;
    ddp_task_group.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_task_group.created_by := p7_a4;
    ddp_task_group.last_update_login := p7_a5;
    ddp_task_group.start_date_active := rosetta_g_miss_date_in_map(p7_a6);
    ddp_task_group.end_date_active := rosetta_g_miss_date_in_map(p7_a7);
    ddp_task_group.source_object_type_code := p7_a8;
    ddp_task_group.object_version_number := p7_a9;
    ddp_task_group.attribute_category := p7_a10;
    ddp_task_group.attribute1 := p7_a11;
    ddp_task_group.attribute2 := p7_a12;
    ddp_task_group.attribute3 := p7_a13;
    ddp_task_group.attribute4 := p7_a14;
    ddp_task_group.attribute5 := p7_a15;
    ddp_task_group.attribute6 := p7_a16;
    ddp_task_group.attribute7 := p7_a17;
    ddp_task_group.attribute8 := p7_a18;
    ddp_task_group.attribute9 := p7_a19;
    ddp_task_group.attribute10 := p7_a20;
    ddp_task_group.attribute11 := p7_a21;
    ddp_task_group.attribute12 := p7_a22;
    ddp_task_group.attribute13 := p7_a23;
    ddp_task_group.attribute14 := p7_a24;
    ddp_task_group.attribute15 := p7_a25;
    ddp_task_group.reason_type := p7_a26;
    ddp_task_group.template_group_name := p7_a27;
    ddp_task_group.description := p7_a28;


    -- here's the delegated call to the old PL/SQL routine
    ozf_task_group_pvt.update_task_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_task_group,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_task_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_task_template_group_id  NUMBER
    , p_template_group_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p11_a0 JTF_VARCHAR2_TABLE_100
    , p11_a1 JTF_VARCHAR2_TABLE_100
    , p12_a0  NUMBER
    , p12_a1  NUMBER
    , p12_a2  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_DATE_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_DATE_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_DATE_TABLE
    , p14_a7 out nocopy JTF_DATE_TABLE
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_NUMBER_TABLE
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a28 out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_start_date_active date;
    ddp_end_date_active date;
    ddp_sort_data ozf_task_group_pvt.ozf_sort_data;
    ddp_request_rec ozf_task_group_pvt.ozf_request_rec_type;
    ddx_return_rec ozf_task_group_pvt.ozf_return_rec_type;
    ddx_task_group ozf_task_group_pvt.task_group_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_start_date_active := rosetta_g_miss_date_in_map(p_start_date_active);

    ddp_end_date_active := rosetta_g_miss_date_in_map(p_end_date_active);

    ozf_task_group_pvt_w.rosetta_table_copy_in_p5(ddp_sort_data, p11_a0
      , p11_a1
      );

    ddp_request_rec.records_requested := p12_a0;
    ddp_request_rec.start_record_position := p12_a1;
    ddp_request_rec.return_total_count_flag := p12_a2;



    -- here's the delegated call to the old PL/SQL routine
    ozf_task_group_pvt.get_task_group(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      p_task_template_group_id,
      p_template_group_name,
      p_source_object_type_code,
      ddp_start_date_active,
      ddp_end_date_active,
      ddp_sort_data,
      ddp_request_rec,
      ddx_return_rec,
      ddx_task_group);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    p13_a0 := ddx_return_rec.returned_record_count;
    p13_a1 := ddx_return_rec.next_record_position;
    p13_a2 := ddx_return_rec.total_record_count;

    ozf_task_group_pvt_w.rosetta_table_copy_out_p1(ddx_task_group, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      , p14_a22
      , p14_a23
      , p14_a24
      , p14_a25
      , p14_a26
      , p14_a27
      , p14_a28
      );
  end;

  procedure validate_task_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  DATE
    , p6_a7  DATE
    , p6_a8  VARCHAR2
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
  )

  as
    ddp_task_group ozf_task_group_pvt.task_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_task_group.task_template_group_id := p6_a0;
    ddp_task_group.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_task_group.last_updated_by := p6_a2;
    ddp_task_group.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_task_group.created_by := p6_a4;
    ddp_task_group.last_update_login := p6_a5;
    ddp_task_group.start_date_active := rosetta_g_miss_date_in_map(p6_a6);
    ddp_task_group.end_date_active := rosetta_g_miss_date_in_map(p6_a7);
    ddp_task_group.source_object_type_code := p6_a8;
    ddp_task_group.object_version_number := p6_a9;
    ddp_task_group.attribute_category := p6_a10;
    ddp_task_group.attribute1 := p6_a11;
    ddp_task_group.attribute2 := p6_a12;
    ddp_task_group.attribute3 := p6_a13;
    ddp_task_group.attribute4 := p6_a14;
    ddp_task_group.attribute5 := p6_a15;
    ddp_task_group.attribute6 := p6_a16;
    ddp_task_group.attribute7 := p6_a17;
    ddp_task_group.attribute8 := p6_a18;
    ddp_task_group.attribute9 := p6_a19;
    ddp_task_group.attribute10 := p6_a20;
    ddp_task_group.attribute11 := p6_a21;
    ddp_task_group.attribute12 := p6_a22;
    ddp_task_group.attribute13 := p6_a23;
    ddp_task_group.attribute14 := p6_a24;
    ddp_task_group.attribute15 := p6_a25;
    ddp_task_group.reason_type := p6_a26;
    ddp_task_group.template_group_name := p6_a27;
    ddp_task_group.description := p6_a28;

    -- here's the delegated call to the old PL/SQL routine
    ozf_task_group_pvt.validate_task_group(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_task_group);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_task_group_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  DATE
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  DATE
    , p2_a7  DATE
    , p2_a8  VARCHAR2
    , p2_a9  NUMBER
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
  )

  as
    ddp_task_group_rec ozf_task_group_pvt.task_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_task_group_rec.task_template_group_id := p2_a0;
    ddp_task_group_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_task_group_rec.last_updated_by := p2_a2;
    ddp_task_group_rec.creation_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_task_group_rec.created_by := p2_a4;
    ddp_task_group_rec.last_update_login := p2_a5;
    ddp_task_group_rec.start_date_active := rosetta_g_miss_date_in_map(p2_a6);
    ddp_task_group_rec.end_date_active := rosetta_g_miss_date_in_map(p2_a7);
    ddp_task_group_rec.source_object_type_code := p2_a8;
    ddp_task_group_rec.object_version_number := p2_a9;
    ddp_task_group_rec.attribute_category := p2_a10;
    ddp_task_group_rec.attribute1 := p2_a11;
    ddp_task_group_rec.attribute2 := p2_a12;
    ddp_task_group_rec.attribute3 := p2_a13;
    ddp_task_group_rec.attribute4 := p2_a14;
    ddp_task_group_rec.attribute5 := p2_a15;
    ddp_task_group_rec.attribute6 := p2_a16;
    ddp_task_group_rec.attribute7 := p2_a17;
    ddp_task_group_rec.attribute8 := p2_a18;
    ddp_task_group_rec.attribute9 := p2_a19;
    ddp_task_group_rec.attribute10 := p2_a20;
    ddp_task_group_rec.attribute11 := p2_a21;
    ddp_task_group_rec.attribute12 := p2_a22;
    ddp_task_group_rec.attribute13 := p2_a23;
    ddp_task_group_rec.attribute14 := p2_a24;
    ddp_task_group_rec.attribute15 := p2_a25;
    ddp_task_group_rec.reason_type := p2_a26;
    ddp_task_group_rec.template_group_name := p2_a27;
    ddp_task_group_rec.description := p2_a28;

    -- here's the delegated call to the old PL/SQL routine
    ozf_task_group_pvt.check_task_group_items(p_validation_mode,
      x_return_status,
      ddp_task_group_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_task_group_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  DATE
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  DATE
    , p1_a7  DATE
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_task_group_rec ozf_task_group_pvt.task_group_rec_type;
    ddp_complete_rec ozf_task_group_pvt.task_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_task_group_rec.task_template_group_id := p0_a0;
    ddp_task_group_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_task_group_rec.last_updated_by := p0_a2;
    ddp_task_group_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_task_group_rec.created_by := p0_a4;
    ddp_task_group_rec.last_update_login := p0_a5;
    ddp_task_group_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a6);
    ddp_task_group_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a7);
    ddp_task_group_rec.source_object_type_code := p0_a8;
    ddp_task_group_rec.object_version_number := p0_a9;
    ddp_task_group_rec.attribute_category := p0_a10;
    ddp_task_group_rec.attribute1 := p0_a11;
    ddp_task_group_rec.attribute2 := p0_a12;
    ddp_task_group_rec.attribute3 := p0_a13;
    ddp_task_group_rec.attribute4 := p0_a14;
    ddp_task_group_rec.attribute5 := p0_a15;
    ddp_task_group_rec.attribute6 := p0_a16;
    ddp_task_group_rec.attribute7 := p0_a17;
    ddp_task_group_rec.attribute8 := p0_a18;
    ddp_task_group_rec.attribute9 := p0_a19;
    ddp_task_group_rec.attribute10 := p0_a20;
    ddp_task_group_rec.attribute11 := p0_a21;
    ddp_task_group_rec.attribute12 := p0_a22;
    ddp_task_group_rec.attribute13 := p0_a23;
    ddp_task_group_rec.attribute14 := p0_a24;
    ddp_task_group_rec.attribute15 := p0_a25;
    ddp_task_group_rec.reason_type := p0_a26;
    ddp_task_group_rec.template_group_name := p0_a27;
    ddp_task_group_rec.description := p0_a28;

    ddp_complete_rec.task_template_group_id := p1_a0;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := p1_a4;
    ddp_complete_rec.last_update_login := p1_a5;
    ddp_complete_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a6);
    ddp_complete_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a7);
    ddp_complete_rec.source_object_type_code := p1_a8;
    ddp_complete_rec.object_version_number := p1_a9;
    ddp_complete_rec.attribute_category := p1_a10;
    ddp_complete_rec.attribute1 := p1_a11;
    ddp_complete_rec.attribute2 := p1_a12;
    ddp_complete_rec.attribute3 := p1_a13;
    ddp_complete_rec.attribute4 := p1_a14;
    ddp_complete_rec.attribute5 := p1_a15;
    ddp_complete_rec.attribute6 := p1_a16;
    ddp_complete_rec.attribute7 := p1_a17;
    ddp_complete_rec.attribute8 := p1_a18;
    ddp_complete_rec.attribute9 := p1_a19;
    ddp_complete_rec.attribute10 := p1_a20;
    ddp_complete_rec.attribute11 := p1_a21;
    ddp_complete_rec.attribute12 := p1_a22;
    ddp_complete_rec.attribute13 := p1_a23;
    ddp_complete_rec.attribute14 := p1_a24;
    ddp_complete_rec.attribute15 := p1_a25;
    ddp_complete_rec.reason_type := p1_a26;
    ddp_complete_rec.template_group_name := p1_a27;
    ddp_complete_rec.description := p1_a28;


    -- here's the delegated call to the old PL/SQL routine
    ozf_task_group_pvt.check_task_group_record(ddp_task_group_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_task_group_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  DATE
    , p0_a7 out nocopy  DATE
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
  )

  as
    ddx_task_group_rec ozf_task_group_pvt.task_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_task_group_pvt.init_task_group_rec(ddx_task_group_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_task_group_rec.task_template_group_id;
    p0_a1 := ddx_task_group_rec.last_update_date;
    p0_a2 := ddx_task_group_rec.last_updated_by;
    p0_a3 := ddx_task_group_rec.creation_date;
    p0_a4 := ddx_task_group_rec.created_by;
    p0_a5 := ddx_task_group_rec.last_update_login;
    p0_a6 := ddx_task_group_rec.start_date_active;
    p0_a7 := ddx_task_group_rec.end_date_active;
    p0_a8 := ddx_task_group_rec.source_object_type_code;
    p0_a9 := ddx_task_group_rec.object_version_number;
    p0_a10 := ddx_task_group_rec.attribute_category;
    p0_a11 := ddx_task_group_rec.attribute1;
    p0_a12 := ddx_task_group_rec.attribute2;
    p0_a13 := ddx_task_group_rec.attribute3;
    p0_a14 := ddx_task_group_rec.attribute4;
    p0_a15 := ddx_task_group_rec.attribute5;
    p0_a16 := ddx_task_group_rec.attribute6;
    p0_a17 := ddx_task_group_rec.attribute7;
    p0_a18 := ddx_task_group_rec.attribute8;
    p0_a19 := ddx_task_group_rec.attribute9;
    p0_a20 := ddx_task_group_rec.attribute10;
    p0_a21 := ddx_task_group_rec.attribute11;
    p0_a22 := ddx_task_group_rec.attribute12;
    p0_a23 := ddx_task_group_rec.attribute13;
    p0_a24 := ddx_task_group_rec.attribute14;
    p0_a25 := ddx_task_group_rec.attribute15;
    p0_a26 := ddx_task_group_rec.reason_type;
    p0_a27 := ddx_task_group_rec.template_group_name;
    p0_a28 := ddx_task_group_rec.description;
  end;

  procedure complete_task_group_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  DATE
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  DATE
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
  )

  as
    ddp_task_group_rec ozf_task_group_pvt.task_group_rec_type;
    ddx_complete_rec ozf_task_group_pvt.task_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_task_group_rec.task_template_group_id := p0_a0;
    ddp_task_group_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_task_group_rec.last_updated_by := p0_a2;
    ddp_task_group_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_task_group_rec.created_by := p0_a4;
    ddp_task_group_rec.last_update_login := p0_a5;
    ddp_task_group_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a6);
    ddp_task_group_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a7);
    ddp_task_group_rec.source_object_type_code := p0_a8;
    ddp_task_group_rec.object_version_number := p0_a9;
    ddp_task_group_rec.attribute_category := p0_a10;
    ddp_task_group_rec.attribute1 := p0_a11;
    ddp_task_group_rec.attribute2 := p0_a12;
    ddp_task_group_rec.attribute3 := p0_a13;
    ddp_task_group_rec.attribute4 := p0_a14;
    ddp_task_group_rec.attribute5 := p0_a15;
    ddp_task_group_rec.attribute6 := p0_a16;
    ddp_task_group_rec.attribute7 := p0_a17;
    ddp_task_group_rec.attribute8 := p0_a18;
    ddp_task_group_rec.attribute9 := p0_a19;
    ddp_task_group_rec.attribute10 := p0_a20;
    ddp_task_group_rec.attribute11 := p0_a21;
    ddp_task_group_rec.attribute12 := p0_a22;
    ddp_task_group_rec.attribute13 := p0_a23;
    ddp_task_group_rec.attribute14 := p0_a24;
    ddp_task_group_rec.attribute15 := p0_a25;
    ddp_task_group_rec.reason_type := p0_a26;
    ddp_task_group_rec.template_group_name := p0_a27;
    ddp_task_group_rec.description := p0_a28;


    -- here's the delegated call to the old PL/SQL routine
    ozf_task_group_pvt.complete_task_group_rec(ddp_task_group_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.task_template_group_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.start_date_active;
    p1_a7 := ddx_complete_rec.end_date_active;
    p1_a8 := ddx_complete_rec.source_object_type_code;
    p1_a9 := ddx_complete_rec.object_version_number;
    p1_a10 := ddx_complete_rec.attribute_category;
    p1_a11 := ddx_complete_rec.attribute1;
    p1_a12 := ddx_complete_rec.attribute2;
    p1_a13 := ddx_complete_rec.attribute3;
    p1_a14 := ddx_complete_rec.attribute4;
    p1_a15 := ddx_complete_rec.attribute5;
    p1_a16 := ddx_complete_rec.attribute6;
    p1_a17 := ddx_complete_rec.attribute7;
    p1_a18 := ddx_complete_rec.attribute8;
    p1_a19 := ddx_complete_rec.attribute9;
    p1_a20 := ddx_complete_rec.attribute10;
    p1_a21 := ddx_complete_rec.attribute11;
    p1_a22 := ddx_complete_rec.attribute12;
    p1_a23 := ddx_complete_rec.attribute13;
    p1_a24 := ddx_complete_rec.attribute14;
    p1_a25 := ddx_complete_rec.attribute15;
    p1_a26 := ddx_complete_rec.reason_type;
    p1_a27 := ddx_complete_rec.template_group_name;
    p1_a28 := ddx_complete_rec.description;
  end;

end ozf_task_group_pvt_w;

/
