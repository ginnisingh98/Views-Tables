--------------------------------------------------------
--  DDL for Package Body AHL_UMP_SMRINSTANCE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_SMRINSTANCE_PVT_W" as
  /* $Header: AHLSMRWB.pls 120.2.12010000.2 2008/12/27 18:03:47 sracha ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_ump_smrinstance_pvt.results_mrinstance_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_4000
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).program_type_meaning := a0(indx);
          t(ddindx).mr_title := a1(indx);
          t(ddindx).part_number := a2(indx);
          t(ddindx).serial_number := a3(indx);
          t(ddindx).uom_remain := a4(indx);
          t(ddindx).counter_name := a5(indx);
          t(ddindx).earliest_due_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).latest_due_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).tolerance_flag := a9(indx);
          t(ddindx).umr_status_code := a10(indx);
          t(ddindx).umr_status_meaning := a11(indx);
          t(ddindx).scheduled_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).visit_number := a13(indx);
          t(ddindx).visit_status := a14(indx);
          t(ddindx).assign_status := a15(indx);
          t(ddindx).service_req_id := a16(indx);
          t(ddindx).service_req_num := a17(indx);
          t(ddindx).service_req_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).originator_title := a19(indx);
          t(ddindx).dependant_title := a20(indx);
          t(ddindx).unit_effectivity_id := a21(indx);
          t(ddindx).mr_id := a22(indx);
          t(ddindx).csi_item_instance_id := a23(indx);
          t(ddindx).instance_number := a24(indx);
          t(ddindx).mr_interval_id := a25(indx);
          t(ddindx).unit_name := a26(indx);
          t(ddindx).program_title := a27(indx);
          t(ddindx).contract_number := a28(indx);
          t(ddindx).defer_from_ue_id := a29(indx);
          t(ddindx).defer_to_ue_id := a30(indx);
          t(ddindx).unit_effectivity_type := a31(indx);
          t(ddindx).object_type := a32(indx);
          t(ddindx).manually_planned_flag := a33(indx);
          t(ddindx).manually_planned_desc := a34(indx);
          t(ddindx).visit_id := a35(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_ump_smrinstance_pvt.results_mrinstance_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_4000();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_4000();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).program_type_meaning;
          a1(indx) := t(ddindx).mr_title;
          a2(indx) := t(ddindx).part_number;
          a3(indx) := t(ddindx).serial_number;
          a4(indx) := t(ddindx).uom_remain;
          a5(indx) := t(ddindx).counter_name;
          a6(indx) := t(ddindx).earliest_due_date;
          a7(indx) := t(ddindx).due_date;
          a8(indx) := t(ddindx).latest_due_date;
          a9(indx) := t(ddindx).tolerance_flag;
          a10(indx) := t(ddindx).umr_status_code;
          a11(indx) := t(ddindx).umr_status_meaning;
          a12(indx) := t(ddindx).scheduled_date;
          a13(indx) := t(ddindx).visit_number;
          a14(indx) := t(ddindx).visit_status;
          a15(indx) := t(ddindx).assign_status;
          a16(indx) := t(ddindx).service_req_id;
          a17(indx) := t(ddindx).service_req_num;
          a18(indx) := t(ddindx).service_req_date;
          a19(indx) := t(ddindx).originator_title;
          a20(indx) := t(ddindx).dependant_title;
          a21(indx) := t(ddindx).unit_effectivity_id;
          a22(indx) := t(ddindx).mr_id;
          a23(indx) := t(ddindx).csi_item_instance_id;
          a24(indx) := t(ddindx).instance_number;
          a25(indx) := t(ddindx).mr_interval_id;
          a26(indx) := t(ddindx).unit_name;
          a27(indx) := t(ddindx).program_title;
          a28(indx) := t(ddindx).contract_number;
          a29(indx) := t(ddindx).defer_from_ue_id;
          a30(indx) := t(ddindx).defer_to_ue_id;
          a31(indx) := t(ddindx).unit_effectivity_type;
          a32(indx) := t(ddindx).object_type;
          a33(indx) := t(ddindx).manually_planned_flag;
          a34(indx) := t(ddindx).manually_planned_desc;
          a35(indx) := t(ddindx).visit_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure search_mr_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p_start_row  NUMBER
    , p_rows_per_page  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  DATE
    , p8_a8  DATE
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  VARCHAR2
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  NUMBER
    , p8_a25  VARCHAR2
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_DATE_TABLE
    , p9_a7 out nocopy JTF_DATE_TABLE
    , p9_a8 out nocopy JTF_DATE_TABLE
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_DATE_TABLE
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_DATE_TABLE
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a25 out nocopy JTF_NUMBER_TABLE
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a30 out nocopy JTF_NUMBER_TABLE
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a35 out nocopy JTF_NUMBER_TABLE
    , x_results_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_search_mr_instance_rec ahl_ump_smrinstance_pvt.search_mrinstance_rec_type;
    ddx_results_mr_instance_tbl ahl_ump_smrinstance_pvt.results_mrinstance_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_search_mr_instance_rec.unit_name := p8_a0;
    ddp_search_mr_instance_rec.part_number := p8_a1;
    ddp_search_mr_instance_rec.serial_number := p8_a2;
    ddp_search_mr_instance_rec.sort_by := p8_a3;
    ddp_search_mr_instance_rec.mr_status := p8_a4;
    ddp_search_mr_instance_rec.mr_title := p8_a5;
    ddp_search_mr_instance_rec.program_type := p8_a6;
    ddp_search_mr_instance_rec.due_from := rosetta_g_miss_date_in_map(p8_a7);
    ddp_search_mr_instance_rec.due_to := rosetta_g_miss_date_in_map(p8_a8);
    ddp_search_mr_instance_rec.show_tolerance := p8_a9;
    ddp_search_mr_instance_rec.components_flag := p8_a10;
    ddp_search_mr_instance_rec.repetitive_flag := p8_a11;
    ddp_search_mr_instance_rec.contract_number := p8_a12;
    ddp_search_mr_instance_rec.contract_modifier := p8_a13;
    ddp_search_mr_instance_rec.service_line_id := p8_a14;
    ddp_search_mr_instance_rec.service_line_num := p8_a15;
    ddp_search_mr_instance_rec.program_id := p8_a16;
    ddp_search_mr_instance_rec.program_title := p8_a17;
    ddp_search_mr_instance_rec.show_groupmr := p8_a18;
    ddp_search_mr_instance_rec.object_type := p8_a19;
    ddp_search_mr_instance_rec.search_for_type := p8_a20;
    ddp_search_mr_instance_rec.visit_number := p8_a21;
    ddp_search_mr_instance_rec.visit_org_name := p8_a22;
    ddp_search_mr_instance_rec.visit_dept_name := p8_a23;
    ddp_search_mr_instance_rec.incident_type_id := p8_a24;
    ddp_search_mr_instance_rec.service_req_num := p8_a25;






    -- here's the delegated call to the old PL/SQL routine
    ahl_ump_smrinstance_pvt.search_mr_instances(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      p_start_row,
      p_rows_per_page,
      ddp_search_mr_instance_rec,
      ddx_results_mr_instance_tbl,
      x_results_count,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_ump_smrinstance_pvt_w.rosetta_table_copy_out_p2(ddx_results_mr_instance_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      );




  end;

end ahl_ump_smrinstance_pvt_w;

/
