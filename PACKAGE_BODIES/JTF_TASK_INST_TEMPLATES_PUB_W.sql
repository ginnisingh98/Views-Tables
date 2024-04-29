--------------------------------------------------------
--  DDL for Package Body JTF_TASK_INST_TEMPLATES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_INST_TEMPLATES_PUB_W" as
  /* $Header: jtfpttwb.pls 120.3 2006/04/26 04:35 knayyar ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy jtf_task_inst_templates_pub.task_details_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_id := a0(indx);
          t(ddindx).task_template_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_task_inst_templates_pub.task_details_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_id;
          a1(indx) := t(ddindx).task_template_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_task_inst_templates_pub.task_contact_points_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_template_id := a0(indx);
          t(ddindx).phone_id := a1(indx);
          t(ddindx).primary_key := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_task_inst_templates_pub.task_contact_points_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_template_id;
          a1(indx) := t(ddindx).phone_id;
          a2(indx) := t(ddindx).primary_key;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p6(t out nocopy jtf_task_inst_templates_pub.task_template_info_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
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
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_template_id := a0(indx);
          t(ddindx).task_name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).task_type_id := a3(indx);
          t(ddindx).task_status_id := a4(indx);
          t(ddindx).task_priority_id := a5(indx);
          t(ddindx).owner_type_code := a6(indx);
          t(ddindx).owner_id := a7(indx);
          t(ddindx).planned_start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).planned_end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).scheduled_start_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).scheduled_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).actual_start_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).actual_end_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).p_date_selected := a14(indx);
          t(ddindx).timezone_id := a15(indx);
          t(ddindx).duration := a16(indx);
          t(ddindx).duration_uom := a17(indx);
          t(ddindx).planned_effort := a18(indx);
          t(ddindx).planned_effort_uom := a19(indx);
          t(ddindx).private_flag := a20(indx);
          t(ddindx).restrict_closure_flag := a21(indx);
          t(ddindx).palm_flag := a22(indx);
          t(ddindx).wince_flag := a23(indx);
          t(ddindx).laptop_flag := a24(indx);
          t(ddindx).device1_flag := a25(indx);
          t(ddindx).device2_flag := a26(indx);
          t(ddindx).device3_flag := a27(indx);
          t(ddindx).show_on_calendar := a28(indx);
          t(ddindx).enable_workflow := a29(indx);
          t(ddindx).attribute1 := a30(indx);
          t(ddindx).attribute2 := a31(indx);
          t(ddindx).attribute3 := a32(indx);
          t(ddindx).attribute4 := a33(indx);
          t(ddindx).attribute5 := a34(indx);
          t(ddindx).attribute6 := a35(indx);
          t(ddindx).attribute7 := a36(indx);
          t(ddindx).attribute8 := a37(indx);
          t(ddindx).attribute9 := a38(indx);
          t(ddindx).attribute10 := a39(indx);
          t(ddindx).attribute11 := a40(indx);
          t(ddindx).attribute12 := a41(indx);
          t(ddindx).attribute13 := a42(indx);
          t(ddindx).attribute14 := a43(indx);
          t(ddindx).attribute15 := a44(indx);
          t(ddindx).attribute_category := a45(indx);
          t(ddindx).task_confirmation_status := a46(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t jtf_task_inst_templates_pub.task_template_info_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
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
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
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
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
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
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_template_id;
          a1(indx) := t(ddindx).task_name;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).task_type_id;
          a4(indx) := t(ddindx).task_status_id;
          a5(indx) := t(ddindx).task_priority_id;
          a6(indx) := t(ddindx).owner_type_code;
          a7(indx) := t(ddindx).owner_id;
          a8(indx) := t(ddindx).planned_start_date;
          a9(indx) := t(ddindx).planned_end_date;
          a10(indx) := t(ddindx).scheduled_start_date;
          a11(indx) := t(ddindx).scheduled_end_date;
          a12(indx) := t(ddindx).actual_start_date;
          a13(indx) := t(ddindx).actual_end_date;
          a14(indx) := t(ddindx).p_date_selected;
          a15(indx) := t(ddindx).timezone_id;
          a16(indx) := t(ddindx).duration;
          a17(indx) := t(ddindx).duration_uom;
          a18(indx) := t(ddindx).planned_effort;
          a19(indx) := t(ddindx).planned_effort_uom;
          a20(indx) := t(ddindx).private_flag;
          a21(indx) := t(ddindx).restrict_closure_flag;
          a22(indx) := t(ddindx).palm_flag;
          a23(indx) := t(ddindx).wince_flag;
          a24(indx) := t(ddindx).laptop_flag;
          a25(indx) := t(ddindx).device1_flag;
          a26(indx) := t(ddindx).device2_flag;
          a27(indx) := t(ddindx).device3_flag;
          a28(indx) := t(ddindx).show_on_calendar;
          a29(indx) := t(ddindx).enable_workflow;
          a30(indx) := t(ddindx).attribute1;
          a31(indx) := t(ddindx).attribute2;
          a32(indx) := t(ddindx).attribute3;
          a33(indx) := t(ddindx).attribute4;
          a34(indx) := t(ddindx).attribute5;
          a35(indx) := t(ddindx).attribute6;
          a36(indx) := t(ddindx).attribute7;
          a37(indx) := t(ddindx).attribute8;
          a38(indx) := t(ddindx).attribute9;
          a39(indx) := t(ddindx).attribute10;
          a40(indx) := t(ddindx).attribute11;
          a41(indx) := t(ddindx).attribute12;
          a42(indx) := t(ddindx).attribute13;
          a43(indx) := t(ddindx).attribute14;
          a44(indx) := t(ddindx).attribute15;
          a45(indx) := t(ddindx).attribute_category;
          a46(indx) := t(ddindx).task_confirmation_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_task_from_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  VARCHAR2
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  DATE
    , p3_a10  DATE
    , p3_a11  DATE
    , p3_a12  DATE
    , p3_a13  DATE
    , p3_a14  DATE
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  VARCHAR2
    , p3_a48  VARCHAR2
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_DATE_TABLE
    , p4_a10 JTF_DATE_TABLE
    , p4_a11 JTF_DATE_TABLE
    , p4_a12 JTF_DATE_TABLE
    , p4_a13 JTF_DATE_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_VARCHAR2_TABLE_100
    , p4_a21 JTF_VARCHAR2_TABLE_100
    , p4_a22 JTF_VARCHAR2_TABLE_100
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_VARCHAR2_TABLE_100
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_VARCHAR2_TABLE_100
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_VARCHAR2_TABLE_100
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_VARCHAR2_TABLE_200
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_VARCHAR2_TABLE_200
    , p4_a42 JTF_VARCHAR2_TABLE_200
    , p4_a43 JTF_VARCHAR2_TABLE_200
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_100
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_task_template_group_info jtf_task_inst_templates_pub.task_template_group_info;
    ddp_task_templates_tbl jtf_task_inst_templates_pub.task_template_info_tbl;
    ddp_task_contact_points_tbl jtf_task_inst_templates_pub.task_contact_points_tbl;
    ddx_task_details_tbl jtf_task_inst_templates_pub.task_details_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_task_template_group_info.task_template_group_id := p3_a0;
    ddp_task_template_group_info.owner_type_code := p3_a1;
    ddp_task_template_group_info.owner_id := p3_a2;
    ddp_task_template_group_info.source_object_id := p3_a3;
    ddp_task_template_group_info.source_object_name := p3_a4;
    ddp_task_template_group_info.assigned_by_id := p3_a5;
    ddp_task_template_group_info.cust_account_id := p3_a6;
    ddp_task_template_group_info.customer_id := p3_a7;
    ddp_task_template_group_info.address_id := p3_a8;
    ddp_task_template_group_info.actual_start_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_task_template_group_info.actual_end_date := rosetta_g_miss_date_in_map(p3_a10);
    ddp_task_template_group_info.planned_start_date := rosetta_g_miss_date_in_map(p3_a11);
    ddp_task_template_group_info.planned_end_date := rosetta_g_miss_date_in_map(p3_a12);
    ddp_task_template_group_info.scheduled_start_date := rosetta_g_miss_date_in_map(p3_a13);
    ddp_task_template_group_info.scheduled_end_date := rosetta_g_miss_date_in_map(p3_a14);
    ddp_task_template_group_info.palm_flag := p3_a15;
    ddp_task_template_group_info.wince_flag := p3_a16;
    ddp_task_template_group_info.laptop_flag := p3_a17;
    ddp_task_template_group_info.device1_flag := p3_a18;
    ddp_task_template_group_info.device2_flag := p3_a19;
    ddp_task_template_group_info.device3_flag := p3_a20;
    ddp_task_template_group_info.parent_task_id := p3_a21;
    ddp_task_template_group_info.percentage_complete := p3_a22;
    ddp_task_template_group_info.timezone_id := p3_a23;
    ddp_task_template_group_info.actual_effort := p3_a24;
    ddp_task_template_group_info.actual_effort_uom := p3_a25;
    ddp_task_template_group_info.reason_code := p3_a26;
    ddp_task_template_group_info.bound_mode_code := p3_a27;
    ddp_task_template_group_info.soft_bound_flag := p3_a28;
    ddp_task_template_group_info.workflow_process_id := p3_a29;
    ddp_task_template_group_info.owner_territory_id := p3_a30;
    ddp_task_template_group_info.costs := p3_a31;
    ddp_task_template_group_info.currency_code := p3_a32;
    ddp_task_template_group_info.attribute1 := p3_a33;
    ddp_task_template_group_info.attribute2 := p3_a34;
    ddp_task_template_group_info.attribute3 := p3_a35;
    ddp_task_template_group_info.attribute4 := p3_a36;
    ddp_task_template_group_info.attribute5 := p3_a37;
    ddp_task_template_group_info.attribute6 := p3_a38;
    ddp_task_template_group_info.attribute7 := p3_a39;
    ddp_task_template_group_info.attribute8 := p3_a40;
    ddp_task_template_group_info.attribute9 := p3_a41;
    ddp_task_template_group_info.attribute10 := p3_a42;
    ddp_task_template_group_info.attribute11 := p3_a43;
    ddp_task_template_group_info.attribute12 := p3_a44;
    ddp_task_template_group_info.attribute13 := p3_a45;
    ddp_task_template_group_info.attribute14 := p3_a46;
    ddp_task_template_group_info.attribute15 := p3_a47;
    ddp_task_template_group_info.attribute_category := p3_a48;
    ddp_task_template_group_info.date_selected := p3_a49;
    ddp_task_template_group_info.show_on_calendar := p3_a50;
    ddp_task_template_group_info.location_id := p3_a51;

    jtf_task_inst_templates_pub_w.rosetta_table_copy_in_p6(ddp_task_templates_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      );

    jtf_task_inst_templates_pub_w.rosetta_table_copy_in_p3(ddp_task_contact_points_tbl, p5_a0
      , p5_a1
      , p5_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    jtf_task_inst_templates_pub.create_task_from_template(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_task_template_group_info,
      ddp_task_templates_tbl,
      ddp_task_contact_points_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_task_details_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    jtf_task_inst_templates_pub_w.rosetta_table_copy_out_p1(ddx_task_details_tbl, p9_a0
      , p9_a1
      );
  end;

end jtf_task_inst_templates_pub_w;

/
