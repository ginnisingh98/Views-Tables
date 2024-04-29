--------------------------------------------------------
--  DDL for Package Body OZF_TASK_TEMPLATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TASK_TEMPLATE_PVT_W" as
  /* $Header: ozfwtteb.pls 115.0 2003/06/26 05:12:54 mchang noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ozf_task_template_pvt.ozf_task_template_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
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
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ozf_task_template_pvt.ozf_task_template_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ozf_task_template_pvt.ozf_task_template_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_template_id := a0(indx);
          t(ddindx).task_name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).reason_code_id := a3(indx);
          t(ddindx).reason_code := a4(indx);
          t(ddindx).task_number := a5(indx);
          t(ddindx).task_type_id := a6(indx);
          t(ddindx).task_type_name := a7(indx);
          t(ddindx).task_status_id := a8(indx);
          t(ddindx).task_status_name := a9(indx);
          t(ddindx).task_priority_id := a10(indx);
          t(ddindx).task_priority_name := a11(indx);
          t(ddindx).duration := a12(indx);
          t(ddindx).duration_uom := a13(indx);
          t(ddindx).object_version_number := a14(indx);
          t(ddindx).attribute_category := a15(indx);
          t(ddindx).attribute1 := a16(indx);
          t(ddindx).attribute2 := a17(indx);
          t(ddindx).attribute3 := a18(indx);
          t(ddindx).attribute4 := a19(indx);
          t(ddindx).attribute5 := a20(indx);
          t(ddindx).attribute6 := a21(indx);
          t(ddindx).attribute7 := a22(indx);
          t(ddindx).attribute8 := a23(indx);
          t(ddindx).attribute9 := a24(indx);
          t(ddindx).attribute10 := a25(indx);
          t(ddindx).attribute11 := a26(indx);
          t(ddindx).attribute12 := a27(indx);
          t(ddindx).attribute13 := a28(indx);
          t(ddindx).attribute14 := a29(indx);
          t(ddindx).attribute15 := a30(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_task_template_pvt.ozf_task_template_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
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
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
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
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
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
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_template_id;
          a1(indx) := t(ddindx).task_name;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).reason_code_id;
          a4(indx) := t(ddindx).reason_code;
          a5(indx) := t(ddindx).task_number;
          a6(indx) := t(ddindx).task_type_id;
          a7(indx) := t(ddindx).task_type_name;
          a8(indx) := t(ddindx).task_status_id;
          a9(indx) := t(ddindx).task_status_name;
          a10(indx) := t(ddindx).task_priority_id;
          a11(indx) := t(ddindx).task_priority_name;
          a12(indx) := t(ddindx).duration;
          a13(indx) := t(ddindx).duration_uom;
          a14(indx) := t(ddindx).object_version_number;
          a15(indx) := t(ddindx).attribute_category;
          a16(indx) := t(ddindx).attribute1;
          a17(indx) := t(ddindx).attribute2;
          a18(indx) := t(ddindx).attribute3;
          a19(indx) := t(ddindx).attribute4;
          a20(indx) := t(ddindx).attribute5;
          a21(indx) := t(ddindx).attribute6;
          a22(indx) := t(ddindx).attribute7;
          a23(indx) := t(ddindx).attribute8;
          a24(indx) := t(ddindx).attribute9;
          a25(indx) := t(ddindx).attribute10;
          a26(indx) := t(ddindx).attribute11;
          a27(indx) := t(ddindx).attribute12;
          a28(indx) := t(ddindx).attribute13;
          a29(indx) := t(ddindx).attribute14;
          a30(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy ozf_task_template_pvt.ozf_number_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ozf_task_template_pvt.ozf_number_tbl_type();
  else
      if a0.count > 0 then
      t := ozf_task_template_pvt.ozf_number_tbl_type();
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
  procedure rosetta_table_copy_out_p2(t ozf_task_template_pvt.ozf_number_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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

  procedure create_tasktemplate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_100
    , p7_a2 JTF_VARCHAR2_TABLE_4000
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_VARCHAR2_TABLE_200
    , p7_a17 JTF_VARCHAR2_TABLE_200
    , p7_a18 JTF_VARCHAR2_TABLE_200
    , p7_a19 JTF_VARCHAR2_TABLE_200
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , x_task_template_id out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_task_template ozf_task_template_pvt.ozf_task_template_tbl_type;
    ddx_task_template_id ozf_task_template_pvt.ozf_number_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_task_template_pvt_w.rosetta_table_copy_in_p1(ddp_task_template, p7_a0
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
      , p7_a29
      , p7_a30
      );


    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.create_tasktemplate(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_task_template,
      ddx_task_template_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ozf_task_template_pvt_w.rosetta_table_copy_out_p2(ddx_task_template_id, x_task_template_id);
  end;

  procedure update_tasktemplate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_100
    , p7_a2 JTF_VARCHAR2_TABLE_4000
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_VARCHAR2_TABLE_200
    , p7_a17 JTF_VARCHAR2_TABLE_200
    , p7_a18 JTF_VARCHAR2_TABLE_200
    , p7_a19 JTF_VARCHAR2_TABLE_200
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , x_object_version_number out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_task_template ozf_task_template_pvt.ozf_task_template_tbl_type;
    ddx_object_version_number ozf_task_template_pvt.ozf_number_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_task_template_pvt_w.rosetta_table_copy_in_p1(ddp_task_template, p7_a0
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
      , p7_a29
      , p7_a30
      );


    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.update_tasktemplate(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_task_template,
      ddx_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ozf_task_template_pvt_w.rosetta_table_copy_out_p2(ddx_object_version_number, x_object_version_number);
  end;

  procedure delete_tasktemplate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_task_template_id JTF_NUMBER_TABLE
    , p_object_version_number JTF_NUMBER_TABLE
  )

  as
    ddp_task_template_id ozf_task_template_pvt.ozf_number_tbl_type;
    ddp_object_version_number ozf_task_template_pvt.ozf_number_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_task_template_pvt_w.rosetta_table_copy_in_p2(ddp_task_template_id, p_task_template_id);

    ozf_task_template_pvt_w.rosetta_table_copy_in_p2(ddp_object_version_number, p_object_version_number);

    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.delete_tasktemplate(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_task_template_id,
      ddp_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_tasktemplate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_reason_code_id  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddx_task_template ozf_task_template_pvt.ozf_task_template_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.get_tasktemplate(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      p_reason_code_id,
      ddx_task_template);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ozf_task_template_pvt_w.rosetta_table_copy_out_p1(ddx_task_template, p8_a0
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
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      );
  end;

  procedure validate_tasktemplate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  VARCHAR2
    , p6_a3  NUMBER
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
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
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
  )

  as
    ddp_task_template ozf_task_template_pvt.ozf_task_template_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_task_template.task_template_id := p6_a0;
    ddp_task_template.task_name := p6_a1;
    ddp_task_template.description := p6_a2;
    ddp_task_template.reason_code_id := p6_a3;
    ddp_task_template.reason_code := p6_a4;
    ddp_task_template.task_number := p6_a5;
    ddp_task_template.task_type_id := p6_a6;
    ddp_task_template.task_type_name := p6_a7;
    ddp_task_template.task_status_id := p6_a8;
    ddp_task_template.task_status_name := p6_a9;
    ddp_task_template.task_priority_id := p6_a10;
    ddp_task_template.task_priority_name := p6_a11;
    ddp_task_template.duration := p6_a12;
    ddp_task_template.duration_uom := p6_a13;
    ddp_task_template.object_version_number := p6_a14;
    ddp_task_template.attribute_category := p6_a15;
    ddp_task_template.attribute1 := p6_a16;
    ddp_task_template.attribute2 := p6_a17;
    ddp_task_template.attribute3 := p6_a18;
    ddp_task_template.attribute4 := p6_a19;
    ddp_task_template.attribute5 := p6_a20;
    ddp_task_template.attribute6 := p6_a21;
    ddp_task_template.attribute7 := p6_a22;
    ddp_task_template.attribute8 := p6_a23;
    ddp_task_template.attribute9 := p6_a24;
    ddp_task_template.attribute10 := p6_a25;
    ddp_task_template.attribute11 := p6_a26;
    ddp_task_template.attribute12 := p6_a27;
    ddp_task_template.attribute13 := p6_a28;
    ddp_task_template.attribute14 := p6_a29;
    ddp_task_template.attribute15 := p6_a30;

    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.validate_tasktemplate(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_task_template);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_tasktemplate_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  NUMBER
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  NUMBER
    , p2_a9  VARCHAR2
    , p2_a10  NUMBER
    , p2_a11  VARCHAR2
    , p2_a12  NUMBER
    , p2_a13  VARCHAR2
    , p2_a14  NUMBER
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
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
  )

  as
    ddp_task_template_rec ozf_task_template_pvt.ozf_task_template_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_task_template_rec.task_template_id := p2_a0;
    ddp_task_template_rec.task_name := p2_a1;
    ddp_task_template_rec.description := p2_a2;
    ddp_task_template_rec.reason_code_id := p2_a3;
    ddp_task_template_rec.reason_code := p2_a4;
    ddp_task_template_rec.task_number := p2_a5;
    ddp_task_template_rec.task_type_id := p2_a6;
    ddp_task_template_rec.task_type_name := p2_a7;
    ddp_task_template_rec.task_status_id := p2_a8;
    ddp_task_template_rec.task_status_name := p2_a9;
    ddp_task_template_rec.task_priority_id := p2_a10;
    ddp_task_template_rec.task_priority_name := p2_a11;
    ddp_task_template_rec.duration := p2_a12;
    ddp_task_template_rec.duration_uom := p2_a13;
    ddp_task_template_rec.object_version_number := p2_a14;
    ddp_task_template_rec.attribute_category := p2_a15;
    ddp_task_template_rec.attribute1 := p2_a16;
    ddp_task_template_rec.attribute2 := p2_a17;
    ddp_task_template_rec.attribute3 := p2_a18;
    ddp_task_template_rec.attribute4 := p2_a19;
    ddp_task_template_rec.attribute5 := p2_a20;
    ddp_task_template_rec.attribute6 := p2_a21;
    ddp_task_template_rec.attribute7 := p2_a22;
    ddp_task_template_rec.attribute8 := p2_a23;
    ddp_task_template_rec.attribute9 := p2_a24;
    ddp_task_template_rec.attribute10 := p2_a25;
    ddp_task_template_rec.attribute11 := p2_a26;
    ddp_task_template_rec.attribute12 := p2_a27;
    ddp_task_template_rec.attribute13 := p2_a28;
    ddp_task_template_rec.attribute14 := p2_a29;
    ddp_task_template_rec.attribute15 := p2_a30;

    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.check_tasktemplate_items(p_validation_mode,
      x_return_status,
      ddp_task_template_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_tasktemplate_record(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
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
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  VARCHAR2
    , p1_a2  VARCHAR2
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
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
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_task_template_rec ozf_task_template_pvt.ozf_task_template_rec_type;
    ddp_complete_rec ozf_task_template_pvt.ozf_task_template_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_task_template_rec.task_template_id := p0_a0;
    ddp_task_template_rec.task_name := p0_a1;
    ddp_task_template_rec.description := p0_a2;
    ddp_task_template_rec.reason_code_id := p0_a3;
    ddp_task_template_rec.reason_code := p0_a4;
    ddp_task_template_rec.task_number := p0_a5;
    ddp_task_template_rec.task_type_id := p0_a6;
    ddp_task_template_rec.task_type_name := p0_a7;
    ddp_task_template_rec.task_status_id := p0_a8;
    ddp_task_template_rec.task_status_name := p0_a9;
    ddp_task_template_rec.task_priority_id := p0_a10;
    ddp_task_template_rec.task_priority_name := p0_a11;
    ddp_task_template_rec.duration := p0_a12;
    ddp_task_template_rec.duration_uom := p0_a13;
    ddp_task_template_rec.object_version_number := p0_a14;
    ddp_task_template_rec.attribute_category := p0_a15;
    ddp_task_template_rec.attribute1 := p0_a16;
    ddp_task_template_rec.attribute2 := p0_a17;
    ddp_task_template_rec.attribute3 := p0_a18;
    ddp_task_template_rec.attribute4 := p0_a19;
    ddp_task_template_rec.attribute5 := p0_a20;
    ddp_task_template_rec.attribute6 := p0_a21;
    ddp_task_template_rec.attribute7 := p0_a22;
    ddp_task_template_rec.attribute8 := p0_a23;
    ddp_task_template_rec.attribute9 := p0_a24;
    ddp_task_template_rec.attribute10 := p0_a25;
    ddp_task_template_rec.attribute11 := p0_a26;
    ddp_task_template_rec.attribute12 := p0_a27;
    ddp_task_template_rec.attribute13 := p0_a28;
    ddp_task_template_rec.attribute14 := p0_a29;
    ddp_task_template_rec.attribute15 := p0_a30;

    ddp_complete_rec.task_template_id := p1_a0;
    ddp_complete_rec.task_name := p1_a1;
    ddp_complete_rec.description := p1_a2;
    ddp_complete_rec.reason_code_id := p1_a3;
    ddp_complete_rec.reason_code := p1_a4;
    ddp_complete_rec.task_number := p1_a5;
    ddp_complete_rec.task_type_id := p1_a6;
    ddp_complete_rec.task_type_name := p1_a7;
    ddp_complete_rec.task_status_id := p1_a8;
    ddp_complete_rec.task_status_name := p1_a9;
    ddp_complete_rec.task_priority_id := p1_a10;
    ddp_complete_rec.task_priority_name := p1_a11;
    ddp_complete_rec.duration := p1_a12;
    ddp_complete_rec.duration_uom := p1_a13;
    ddp_complete_rec.object_version_number := p1_a14;
    ddp_complete_rec.attribute_category := p1_a15;
    ddp_complete_rec.attribute1 := p1_a16;
    ddp_complete_rec.attribute2 := p1_a17;
    ddp_complete_rec.attribute3 := p1_a18;
    ddp_complete_rec.attribute4 := p1_a19;
    ddp_complete_rec.attribute5 := p1_a20;
    ddp_complete_rec.attribute6 := p1_a21;
    ddp_complete_rec.attribute7 := p1_a22;
    ddp_complete_rec.attribute8 := p1_a23;
    ddp_complete_rec.attribute9 := p1_a24;
    ddp_complete_rec.attribute10 := p1_a25;
    ddp_complete_rec.attribute11 := p1_a26;
    ddp_complete_rec.attribute12 := p1_a27;
    ddp_complete_rec.attribute13 := p1_a28;
    ddp_complete_rec.attribute14 := p1_a29;
    ddp_complete_rec.attribute15 := p1_a30;


    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.check_tasktemplate_record(ddp_task_template_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_reason_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  VARCHAR2
    , p0_a2 out nocopy  VARCHAR2
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  VARCHAR2
    , p0_a5 out nocopy  VARCHAR2
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  VARCHAR2
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  NUMBER
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
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
  )

  as
    ddx_task_template_rec ozf_task_template_pvt.ozf_task_template_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.init_reason_rec(ddx_task_template_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_task_template_rec.task_template_id;
    p0_a1 := ddx_task_template_rec.task_name;
    p0_a2 := ddx_task_template_rec.description;
    p0_a3 := ddx_task_template_rec.reason_code_id;
    p0_a4 := ddx_task_template_rec.reason_code;
    p0_a5 := ddx_task_template_rec.task_number;
    p0_a6 := ddx_task_template_rec.task_type_id;
    p0_a7 := ddx_task_template_rec.task_type_name;
    p0_a8 := ddx_task_template_rec.task_status_id;
    p0_a9 := ddx_task_template_rec.task_status_name;
    p0_a10 := ddx_task_template_rec.task_priority_id;
    p0_a11 := ddx_task_template_rec.task_priority_name;
    p0_a12 := ddx_task_template_rec.duration;
    p0_a13 := ddx_task_template_rec.duration_uom;
    p0_a14 := ddx_task_template_rec.object_version_number;
    p0_a15 := ddx_task_template_rec.attribute_category;
    p0_a16 := ddx_task_template_rec.attribute1;
    p0_a17 := ddx_task_template_rec.attribute2;
    p0_a18 := ddx_task_template_rec.attribute3;
    p0_a19 := ddx_task_template_rec.attribute4;
    p0_a20 := ddx_task_template_rec.attribute5;
    p0_a21 := ddx_task_template_rec.attribute6;
    p0_a22 := ddx_task_template_rec.attribute7;
    p0_a23 := ddx_task_template_rec.attribute8;
    p0_a24 := ddx_task_template_rec.attribute9;
    p0_a25 := ddx_task_template_rec.attribute10;
    p0_a26 := ddx_task_template_rec.attribute11;
    p0_a27 := ddx_task_template_rec.attribute12;
    p0_a28 := ddx_task_template_rec.attribute13;
    p0_a29 := ddx_task_template_rec.attribute14;
    p0_a30 := ddx_task_template_rec.attribute15;
  end;

  procedure complete_tasktemplate_rec(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
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
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  VARCHAR2
    , p1_a5 out nocopy  VARCHAR2
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
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
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
  )

  as
    ddp_task_template_rec ozf_task_template_pvt.ozf_task_template_rec_type;
    ddx_complete_rec ozf_task_template_pvt.ozf_task_template_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_task_template_rec.task_template_id := p0_a0;
    ddp_task_template_rec.task_name := p0_a1;
    ddp_task_template_rec.description := p0_a2;
    ddp_task_template_rec.reason_code_id := p0_a3;
    ddp_task_template_rec.reason_code := p0_a4;
    ddp_task_template_rec.task_number := p0_a5;
    ddp_task_template_rec.task_type_id := p0_a6;
    ddp_task_template_rec.task_type_name := p0_a7;
    ddp_task_template_rec.task_status_id := p0_a8;
    ddp_task_template_rec.task_status_name := p0_a9;
    ddp_task_template_rec.task_priority_id := p0_a10;
    ddp_task_template_rec.task_priority_name := p0_a11;
    ddp_task_template_rec.duration := p0_a12;
    ddp_task_template_rec.duration_uom := p0_a13;
    ddp_task_template_rec.object_version_number := p0_a14;
    ddp_task_template_rec.attribute_category := p0_a15;
    ddp_task_template_rec.attribute1 := p0_a16;
    ddp_task_template_rec.attribute2 := p0_a17;
    ddp_task_template_rec.attribute3 := p0_a18;
    ddp_task_template_rec.attribute4 := p0_a19;
    ddp_task_template_rec.attribute5 := p0_a20;
    ddp_task_template_rec.attribute6 := p0_a21;
    ddp_task_template_rec.attribute7 := p0_a22;
    ddp_task_template_rec.attribute8 := p0_a23;
    ddp_task_template_rec.attribute9 := p0_a24;
    ddp_task_template_rec.attribute10 := p0_a25;
    ddp_task_template_rec.attribute11 := p0_a26;
    ddp_task_template_rec.attribute12 := p0_a27;
    ddp_task_template_rec.attribute13 := p0_a28;
    ddp_task_template_rec.attribute14 := p0_a29;
    ddp_task_template_rec.attribute15 := p0_a30;


    -- here's the delegated call to the old PL/SQL routine
    ozf_task_template_pvt.complete_tasktemplate_rec(ddp_task_template_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.task_template_id;
    p1_a1 := ddx_complete_rec.task_name;
    p1_a2 := ddx_complete_rec.description;
    p1_a3 := ddx_complete_rec.reason_code_id;
    p1_a4 := ddx_complete_rec.reason_code;
    p1_a5 := ddx_complete_rec.task_number;
    p1_a6 := ddx_complete_rec.task_type_id;
    p1_a7 := ddx_complete_rec.task_type_name;
    p1_a8 := ddx_complete_rec.task_status_id;
    p1_a9 := ddx_complete_rec.task_status_name;
    p1_a10 := ddx_complete_rec.task_priority_id;
    p1_a11 := ddx_complete_rec.task_priority_name;
    p1_a12 := ddx_complete_rec.duration;
    p1_a13 := ddx_complete_rec.duration_uom;
    p1_a14 := ddx_complete_rec.object_version_number;
    p1_a15 := ddx_complete_rec.attribute_category;
    p1_a16 := ddx_complete_rec.attribute1;
    p1_a17 := ddx_complete_rec.attribute2;
    p1_a18 := ddx_complete_rec.attribute3;
    p1_a19 := ddx_complete_rec.attribute4;
    p1_a20 := ddx_complete_rec.attribute5;
    p1_a21 := ddx_complete_rec.attribute6;
    p1_a22 := ddx_complete_rec.attribute7;
    p1_a23 := ddx_complete_rec.attribute8;
    p1_a24 := ddx_complete_rec.attribute9;
    p1_a25 := ddx_complete_rec.attribute10;
    p1_a26 := ddx_complete_rec.attribute11;
    p1_a27 := ddx_complete_rec.attribute12;
    p1_a28 := ddx_complete_rec.attribute13;
    p1_a29 := ddx_complete_rec.attribute14;
    p1_a30 := ddx_complete_rec.attribute15;
  end;

end ozf_task_template_pvt_w;

/
