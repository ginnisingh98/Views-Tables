--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISIT_CST_PR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISIT_CST_PR_PVT_W" as
  /* $Header: AHLWVCPB.pls 120.1 2006/05/04 07:17 anraj noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_vwp_visit_cst_pr_pvt.cost_price_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_2000
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_400
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).visit_task_id := a0(indx);
          t(ddindx).visit_id := a1(indx);
          t(ddindx).mr_id := a2(indx);
          t(ddindx).actual_cost := a3(indx);
          t(ddindx).estimated_cost := a4(indx);
          t(ddindx).actual_price := a5(indx);
          t(ddindx).estimated_price := a6(indx);
          t(ddindx).currency := a7(indx);
          t(ddindx).snapshot_id := a8(indx);
          t(ddindx).object_version_number := a9(indx);
          t(ddindx).estimated_profit := a10(indx);
          t(ddindx).actual_profit := a11(indx);
          t(ddindx).outside_party_flag := a12(indx);
          t(ddindx).is_outside_pty_flag_updt := a13(indx);
          t(ddindx).is_cst_pr_info_required := a14(indx);
          t(ddindx).is_cst_struc_updated := a15(indx);
          t(ddindx).price_list_id := a16(indx);
          t(ddindx).price_list_name := a17(indx);
          t(ddindx).service_request_id := a18(indx);
          t(ddindx).customer_id := a19(indx);
          t(ddindx).organization_id := a20(indx);
          t(ddindx).visit_start_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).visit_end_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).mr_start_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).mr_end_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).task_start_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).task_end_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).task_name := a27(indx);
          t(ddindx).visit_task_number := a28(indx);
          t(ddindx).mr_title := a29(indx);
          t(ddindx).mr_description := a30(indx);
          t(ddindx).billing_item_id := a31(indx);
          t(ddindx).item_name := a32(indx);
          t(ddindx).item_description := a33(indx);
          t(ddindx).organization_name := a34(indx);
          t(ddindx).workorder_id := a35(indx);
          t(ddindx).master_wo_flag := a36(indx);
          t(ddindx).mr_session_id := a37(indx);
          t(ddindx).cost_session_id := a38(indx);
          t(ddindx).created_by := a39(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).last_updated_by := a41(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).last_update_login := a43(indx);
          t(ddindx).attribute_category := a44(indx);
          t(ddindx).attribute1 := a45(indx);
          t(ddindx).attribute2 := a46(indx);
          t(ddindx).attribute3 := a47(indx);
          t(ddindx).attribute4 := a48(indx);
          t(ddindx).attribute5 := a49(indx);
          t(ddindx).attribute6 := a50(indx);
          t(ddindx).attribute7 := a51(indx);
          t(ddindx).attribute8 := a52(indx);
          t(ddindx).attribute9 := a53(indx);
          t(ddindx).attribute10 := a54(indx);
          t(ddindx).attribute11 := a55(indx);
          t(ddindx).attribute12 := a56(indx);
          t(ddindx).attribute13 := a57(indx);
          t(ddindx).attribute14 := a58(indx);
          t(ddindx).attribute15 := a59(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_vwp_visit_cst_pr_pvt.cost_price_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_400
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_2000();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_400();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_200();
    a59 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_2000();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_400();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_200();
      a59 := JTF_VARCHAR2_TABLE_200();
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
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).visit_task_id;
          a1(indx) := t(ddindx).visit_id;
          a2(indx) := t(ddindx).mr_id;
          a3(indx) := t(ddindx).actual_cost;
          a4(indx) := t(ddindx).estimated_cost;
          a5(indx) := t(ddindx).actual_price;
          a6(indx) := t(ddindx).estimated_price;
          a7(indx) := t(ddindx).currency;
          a8(indx) := t(ddindx).snapshot_id;
          a9(indx) := t(ddindx).object_version_number;
          a10(indx) := t(ddindx).estimated_profit;
          a11(indx) := t(ddindx).actual_profit;
          a12(indx) := t(ddindx).outside_party_flag;
          a13(indx) := t(ddindx).is_outside_pty_flag_updt;
          a14(indx) := t(ddindx).is_cst_pr_info_required;
          a15(indx) := t(ddindx).is_cst_struc_updated;
          a16(indx) := t(ddindx).price_list_id;
          a17(indx) := t(ddindx).price_list_name;
          a18(indx) := t(ddindx).service_request_id;
          a19(indx) := t(ddindx).customer_id;
          a20(indx) := t(ddindx).organization_id;
          a21(indx) := t(ddindx).visit_start_date;
          a22(indx) := t(ddindx).visit_end_date;
          a23(indx) := t(ddindx).mr_start_date;
          a24(indx) := t(ddindx).mr_end_date;
          a25(indx) := t(ddindx).task_start_date;
          a26(indx) := t(ddindx).task_end_date;
          a27(indx) := t(ddindx).task_name;
          a28(indx) := t(ddindx).visit_task_number;
          a29(indx) := t(ddindx).mr_title;
          a30(indx) := t(ddindx).mr_description;
          a31(indx) := t(ddindx).billing_item_id;
          a32(indx) := t(ddindx).item_name;
          a33(indx) := t(ddindx).item_description;
          a34(indx) := t(ddindx).organization_name;
          a35(indx) := t(ddindx).workorder_id;
          a36(indx) := t(ddindx).master_wo_flag;
          a37(indx) := t(ddindx).mr_session_id;
          a38(indx) := t(ddindx).cost_session_id;
          a39(indx) := t(ddindx).created_by;
          a40(indx) := t(ddindx).creation_date;
          a41(indx) := t(ddindx).last_updated_by;
          a42(indx) := t(ddindx).last_update_date;
          a43(indx) := t(ddindx).last_update_login;
          a44(indx) := t(ddindx).attribute_category;
          a45(indx) := t(ddindx).attribute1;
          a46(indx) := t(ddindx).attribute2;
          a47(indx) := t(ddindx).attribute3;
          a48(indx) := t(ddindx).attribute4;
          a49(indx) := t(ddindx).attribute5;
          a50(indx) := t(ddindx).attribute6;
          a51(indx) := t(ddindx).attribute7;
          a52(indx) := t(ddindx).attribute8;
          a53(indx) := t(ddindx).attribute9;
          a54(indx) := t(ddindx).attribute10;
          a55(indx) := t(ddindx).attribute11;
          a56(indx) := t(ddindx).attribute12;
          a57(indx) := t(ddindx).attribute13;
          a58(indx) := t(ddindx).attribute14;
          a59(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_visit_cost_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_cost_price_rec.visit_task_id := p5_a0;
    ddp_x_cost_price_rec.visit_id := p5_a1;
    ddp_x_cost_price_rec.mr_id := p5_a2;
    ddp_x_cost_price_rec.actual_cost := p5_a3;
    ddp_x_cost_price_rec.estimated_cost := p5_a4;
    ddp_x_cost_price_rec.actual_price := p5_a5;
    ddp_x_cost_price_rec.estimated_price := p5_a6;
    ddp_x_cost_price_rec.currency := p5_a7;
    ddp_x_cost_price_rec.snapshot_id := p5_a8;
    ddp_x_cost_price_rec.object_version_number := p5_a9;
    ddp_x_cost_price_rec.estimated_profit := p5_a10;
    ddp_x_cost_price_rec.actual_profit := p5_a11;
    ddp_x_cost_price_rec.outside_party_flag := p5_a12;
    ddp_x_cost_price_rec.is_outside_pty_flag_updt := p5_a13;
    ddp_x_cost_price_rec.is_cst_pr_info_required := p5_a14;
    ddp_x_cost_price_rec.is_cst_struc_updated := p5_a15;
    ddp_x_cost_price_rec.price_list_id := p5_a16;
    ddp_x_cost_price_rec.price_list_name := p5_a17;
    ddp_x_cost_price_rec.service_request_id := p5_a18;
    ddp_x_cost_price_rec.customer_id := p5_a19;
    ddp_x_cost_price_rec.organization_id := p5_a20;
    ddp_x_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_x_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_x_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_x_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_x_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_x_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_x_cost_price_rec.task_name := p5_a27;
    ddp_x_cost_price_rec.visit_task_number := p5_a28;
    ddp_x_cost_price_rec.mr_title := p5_a29;
    ddp_x_cost_price_rec.mr_description := p5_a30;
    ddp_x_cost_price_rec.billing_item_id := p5_a31;
    ddp_x_cost_price_rec.item_name := p5_a32;
    ddp_x_cost_price_rec.item_description := p5_a33;
    ddp_x_cost_price_rec.organization_name := p5_a34;
    ddp_x_cost_price_rec.workorder_id := p5_a35;
    ddp_x_cost_price_rec.master_wo_flag := p5_a36;
    ddp_x_cost_price_rec.mr_session_id := p5_a37;
    ddp_x_cost_price_rec.cost_session_id := p5_a38;
    ddp_x_cost_price_rec.created_by := p5_a39;
    ddp_x_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_x_cost_price_rec.last_updated_by := p5_a41;
    ddp_x_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_x_cost_price_rec.last_update_login := p5_a43;
    ddp_x_cost_price_rec.attribute_category := p5_a44;
    ddp_x_cost_price_rec.attribute1 := p5_a45;
    ddp_x_cost_price_rec.attribute2 := p5_a46;
    ddp_x_cost_price_rec.attribute3 := p5_a47;
    ddp_x_cost_price_rec.attribute4 := p5_a48;
    ddp_x_cost_price_rec.attribute5 := p5_a49;
    ddp_x_cost_price_rec.attribute6 := p5_a50;
    ddp_x_cost_price_rec.attribute7 := p5_a51;
    ddp_x_cost_price_rec.attribute8 := p5_a52;
    ddp_x_cost_price_rec.attribute9 := p5_a53;
    ddp_x_cost_price_rec.attribute10 := p5_a54;
    ddp_x_cost_price_rec.attribute11 := p5_a55;
    ddp_x_cost_price_rec.attribute12 := p5_a56;
    ddp_x_cost_price_rec.attribute13 := p5_a57;
    ddp_x_cost_price_rec.attribute14 := p5_a58;
    ddp_x_cost_price_rec.attribute15 := p5_a59;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visit_cst_pr_pvt.get_visit_cost_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_cost_price_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_cost_price_rec.visit_task_id;
    p5_a1 := ddp_x_cost_price_rec.visit_id;
    p5_a2 := ddp_x_cost_price_rec.mr_id;
    p5_a3 := ddp_x_cost_price_rec.actual_cost;
    p5_a4 := ddp_x_cost_price_rec.estimated_cost;
    p5_a5 := ddp_x_cost_price_rec.actual_price;
    p5_a6 := ddp_x_cost_price_rec.estimated_price;
    p5_a7 := ddp_x_cost_price_rec.currency;
    p5_a8 := ddp_x_cost_price_rec.snapshot_id;
    p5_a9 := ddp_x_cost_price_rec.object_version_number;
    p5_a10 := ddp_x_cost_price_rec.estimated_profit;
    p5_a11 := ddp_x_cost_price_rec.actual_profit;
    p5_a12 := ddp_x_cost_price_rec.outside_party_flag;
    p5_a13 := ddp_x_cost_price_rec.is_outside_pty_flag_updt;
    p5_a14 := ddp_x_cost_price_rec.is_cst_pr_info_required;
    p5_a15 := ddp_x_cost_price_rec.is_cst_struc_updated;
    p5_a16 := ddp_x_cost_price_rec.price_list_id;
    p5_a17 := ddp_x_cost_price_rec.price_list_name;
    p5_a18 := ddp_x_cost_price_rec.service_request_id;
    p5_a19 := ddp_x_cost_price_rec.customer_id;
    p5_a20 := ddp_x_cost_price_rec.organization_id;
    p5_a21 := ddp_x_cost_price_rec.visit_start_date;
    p5_a22 := ddp_x_cost_price_rec.visit_end_date;
    p5_a23 := ddp_x_cost_price_rec.mr_start_date;
    p5_a24 := ddp_x_cost_price_rec.mr_end_date;
    p5_a25 := ddp_x_cost_price_rec.task_start_date;
    p5_a26 := ddp_x_cost_price_rec.task_end_date;
    p5_a27 := ddp_x_cost_price_rec.task_name;
    p5_a28 := ddp_x_cost_price_rec.visit_task_number;
    p5_a29 := ddp_x_cost_price_rec.mr_title;
    p5_a30 := ddp_x_cost_price_rec.mr_description;
    p5_a31 := ddp_x_cost_price_rec.billing_item_id;
    p5_a32 := ddp_x_cost_price_rec.item_name;
    p5_a33 := ddp_x_cost_price_rec.item_description;
    p5_a34 := ddp_x_cost_price_rec.organization_name;
    p5_a35 := ddp_x_cost_price_rec.workorder_id;
    p5_a36 := ddp_x_cost_price_rec.master_wo_flag;
    p5_a37 := ddp_x_cost_price_rec.mr_session_id;
    p5_a38 := ddp_x_cost_price_rec.cost_session_id;
    p5_a39 := ddp_x_cost_price_rec.created_by;
    p5_a40 := ddp_x_cost_price_rec.creation_date;
    p5_a41 := ddp_x_cost_price_rec.last_updated_by;
    p5_a42 := ddp_x_cost_price_rec.last_update_date;
    p5_a43 := ddp_x_cost_price_rec.last_update_login;
    p5_a44 := ddp_x_cost_price_rec.attribute_category;
    p5_a45 := ddp_x_cost_price_rec.attribute1;
    p5_a46 := ddp_x_cost_price_rec.attribute2;
    p5_a47 := ddp_x_cost_price_rec.attribute3;
    p5_a48 := ddp_x_cost_price_rec.attribute4;
    p5_a49 := ddp_x_cost_price_rec.attribute5;
    p5_a50 := ddp_x_cost_price_rec.attribute6;
    p5_a51 := ddp_x_cost_price_rec.attribute7;
    p5_a52 := ddp_x_cost_price_rec.attribute8;
    p5_a53 := ddp_x_cost_price_rec.attribute9;
    p5_a54 := ddp_x_cost_price_rec.attribute10;
    p5_a55 := ddp_x_cost_price_rec.attribute11;
    p5_a56 := ddp_x_cost_price_rec.attribute12;
    p5_a57 := ddp_x_cost_price_rec.attribute13;
    p5_a58 := ddp_x_cost_price_rec.attribute14;
    p5_a59 := ddp_x_cost_price_rec.attribute15;



  end;

  procedure estimate_visit_cost(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_cost_price_rec.visit_task_id := p5_a0;
    ddp_x_cost_price_rec.visit_id := p5_a1;
    ddp_x_cost_price_rec.mr_id := p5_a2;
    ddp_x_cost_price_rec.actual_cost := p5_a3;
    ddp_x_cost_price_rec.estimated_cost := p5_a4;
    ddp_x_cost_price_rec.actual_price := p5_a5;
    ddp_x_cost_price_rec.estimated_price := p5_a6;
    ddp_x_cost_price_rec.currency := p5_a7;
    ddp_x_cost_price_rec.snapshot_id := p5_a8;
    ddp_x_cost_price_rec.object_version_number := p5_a9;
    ddp_x_cost_price_rec.estimated_profit := p5_a10;
    ddp_x_cost_price_rec.actual_profit := p5_a11;
    ddp_x_cost_price_rec.outside_party_flag := p5_a12;
    ddp_x_cost_price_rec.is_outside_pty_flag_updt := p5_a13;
    ddp_x_cost_price_rec.is_cst_pr_info_required := p5_a14;
    ddp_x_cost_price_rec.is_cst_struc_updated := p5_a15;
    ddp_x_cost_price_rec.price_list_id := p5_a16;
    ddp_x_cost_price_rec.price_list_name := p5_a17;
    ddp_x_cost_price_rec.service_request_id := p5_a18;
    ddp_x_cost_price_rec.customer_id := p5_a19;
    ddp_x_cost_price_rec.organization_id := p5_a20;
    ddp_x_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_x_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_x_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_x_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_x_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_x_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_x_cost_price_rec.task_name := p5_a27;
    ddp_x_cost_price_rec.visit_task_number := p5_a28;
    ddp_x_cost_price_rec.mr_title := p5_a29;
    ddp_x_cost_price_rec.mr_description := p5_a30;
    ddp_x_cost_price_rec.billing_item_id := p5_a31;
    ddp_x_cost_price_rec.item_name := p5_a32;
    ddp_x_cost_price_rec.item_description := p5_a33;
    ddp_x_cost_price_rec.organization_name := p5_a34;
    ddp_x_cost_price_rec.workorder_id := p5_a35;
    ddp_x_cost_price_rec.master_wo_flag := p5_a36;
    ddp_x_cost_price_rec.mr_session_id := p5_a37;
    ddp_x_cost_price_rec.cost_session_id := p5_a38;
    ddp_x_cost_price_rec.created_by := p5_a39;
    ddp_x_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_x_cost_price_rec.last_updated_by := p5_a41;
    ddp_x_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_x_cost_price_rec.last_update_login := p5_a43;
    ddp_x_cost_price_rec.attribute_category := p5_a44;
    ddp_x_cost_price_rec.attribute1 := p5_a45;
    ddp_x_cost_price_rec.attribute2 := p5_a46;
    ddp_x_cost_price_rec.attribute3 := p5_a47;
    ddp_x_cost_price_rec.attribute4 := p5_a48;
    ddp_x_cost_price_rec.attribute5 := p5_a49;
    ddp_x_cost_price_rec.attribute6 := p5_a50;
    ddp_x_cost_price_rec.attribute7 := p5_a51;
    ddp_x_cost_price_rec.attribute8 := p5_a52;
    ddp_x_cost_price_rec.attribute9 := p5_a53;
    ddp_x_cost_price_rec.attribute10 := p5_a54;
    ddp_x_cost_price_rec.attribute11 := p5_a55;
    ddp_x_cost_price_rec.attribute12 := p5_a56;
    ddp_x_cost_price_rec.attribute13 := p5_a57;
    ddp_x_cost_price_rec.attribute14 := p5_a58;
    ddp_x_cost_price_rec.attribute15 := p5_a59;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visit_cst_pr_pvt.estimate_visit_cost(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_cost_price_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_cost_price_rec.visit_task_id;
    p5_a1 := ddp_x_cost_price_rec.visit_id;
    p5_a2 := ddp_x_cost_price_rec.mr_id;
    p5_a3 := ddp_x_cost_price_rec.actual_cost;
    p5_a4 := ddp_x_cost_price_rec.estimated_cost;
    p5_a5 := ddp_x_cost_price_rec.actual_price;
    p5_a6 := ddp_x_cost_price_rec.estimated_price;
    p5_a7 := ddp_x_cost_price_rec.currency;
    p5_a8 := ddp_x_cost_price_rec.snapshot_id;
    p5_a9 := ddp_x_cost_price_rec.object_version_number;
    p5_a10 := ddp_x_cost_price_rec.estimated_profit;
    p5_a11 := ddp_x_cost_price_rec.actual_profit;
    p5_a12 := ddp_x_cost_price_rec.outside_party_flag;
    p5_a13 := ddp_x_cost_price_rec.is_outside_pty_flag_updt;
    p5_a14 := ddp_x_cost_price_rec.is_cst_pr_info_required;
    p5_a15 := ddp_x_cost_price_rec.is_cst_struc_updated;
    p5_a16 := ddp_x_cost_price_rec.price_list_id;
    p5_a17 := ddp_x_cost_price_rec.price_list_name;
    p5_a18 := ddp_x_cost_price_rec.service_request_id;
    p5_a19 := ddp_x_cost_price_rec.customer_id;
    p5_a20 := ddp_x_cost_price_rec.organization_id;
    p5_a21 := ddp_x_cost_price_rec.visit_start_date;
    p5_a22 := ddp_x_cost_price_rec.visit_end_date;
    p5_a23 := ddp_x_cost_price_rec.mr_start_date;
    p5_a24 := ddp_x_cost_price_rec.mr_end_date;
    p5_a25 := ddp_x_cost_price_rec.task_start_date;
    p5_a26 := ddp_x_cost_price_rec.task_end_date;
    p5_a27 := ddp_x_cost_price_rec.task_name;
    p5_a28 := ddp_x_cost_price_rec.visit_task_number;
    p5_a29 := ddp_x_cost_price_rec.mr_title;
    p5_a30 := ddp_x_cost_price_rec.mr_description;
    p5_a31 := ddp_x_cost_price_rec.billing_item_id;
    p5_a32 := ddp_x_cost_price_rec.item_name;
    p5_a33 := ddp_x_cost_price_rec.item_description;
    p5_a34 := ddp_x_cost_price_rec.organization_name;
    p5_a35 := ddp_x_cost_price_rec.workorder_id;
    p5_a36 := ddp_x_cost_price_rec.master_wo_flag;
    p5_a37 := ddp_x_cost_price_rec.mr_session_id;
    p5_a38 := ddp_x_cost_price_rec.cost_session_id;
    p5_a39 := ddp_x_cost_price_rec.created_by;
    p5_a40 := ddp_x_cost_price_rec.creation_date;
    p5_a41 := ddp_x_cost_price_rec.last_updated_by;
    p5_a42 := ddp_x_cost_price_rec.last_update_date;
    p5_a43 := ddp_x_cost_price_rec.last_update_login;
    p5_a44 := ddp_x_cost_price_rec.attribute_category;
    p5_a45 := ddp_x_cost_price_rec.attribute1;
    p5_a46 := ddp_x_cost_price_rec.attribute2;
    p5_a47 := ddp_x_cost_price_rec.attribute3;
    p5_a48 := ddp_x_cost_price_rec.attribute4;
    p5_a49 := ddp_x_cost_price_rec.attribute5;
    p5_a50 := ddp_x_cost_price_rec.attribute6;
    p5_a51 := ddp_x_cost_price_rec.attribute7;
    p5_a52 := ddp_x_cost_price_rec.attribute8;
    p5_a53 := ddp_x_cost_price_rec.attribute9;
    p5_a54 := ddp_x_cost_price_rec.attribute10;
    p5_a55 := ddp_x_cost_price_rec.attribute11;
    p5_a56 := ddp_x_cost_price_rec.attribute12;
    p5_a57 := ddp_x_cost_price_rec.attribute13;
    p5_a58 := ddp_x_cost_price_rec.attribute14;
    p5_a59 := ddp_x_cost_price_rec.attribute15;



  end;

  procedure estimate_visit_price(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_cost_price_rec.visit_task_id := p5_a0;
    ddp_x_cost_price_rec.visit_id := p5_a1;
    ddp_x_cost_price_rec.mr_id := p5_a2;
    ddp_x_cost_price_rec.actual_cost := p5_a3;
    ddp_x_cost_price_rec.estimated_cost := p5_a4;
    ddp_x_cost_price_rec.actual_price := p5_a5;
    ddp_x_cost_price_rec.estimated_price := p5_a6;
    ddp_x_cost_price_rec.currency := p5_a7;
    ddp_x_cost_price_rec.snapshot_id := p5_a8;
    ddp_x_cost_price_rec.object_version_number := p5_a9;
    ddp_x_cost_price_rec.estimated_profit := p5_a10;
    ddp_x_cost_price_rec.actual_profit := p5_a11;
    ddp_x_cost_price_rec.outside_party_flag := p5_a12;
    ddp_x_cost_price_rec.is_outside_pty_flag_updt := p5_a13;
    ddp_x_cost_price_rec.is_cst_pr_info_required := p5_a14;
    ddp_x_cost_price_rec.is_cst_struc_updated := p5_a15;
    ddp_x_cost_price_rec.price_list_id := p5_a16;
    ddp_x_cost_price_rec.price_list_name := p5_a17;
    ddp_x_cost_price_rec.service_request_id := p5_a18;
    ddp_x_cost_price_rec.customer_id := p5_a19;
    ddp_x_cost_price_rec.organization_id := p5_a20;
    ddp_x_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_x_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_x_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_x_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_x_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_x_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_x_cost_price_rec.task_name := p5_a27;
    ddp_x_cost_price_rec.visit_task_number := p5_a28;
    ddp_x_cost_price_rec.mr_title := p5_a29;
    ddp_x_cost_price_rec.mr_description := p5_a30;
    ddp_x_cost_price_rec.billing_item_id := p5_a31;
    ddp_x_cost_price_rec.item_name := p5_a32;
    ddp_x_cost_price_rec.item_description := p5_a33;
    ddp_x_cost_price_rec.organization_name := p5_a34;
    ddp_x_cost_price_rec.workorder_id := p5_a35;
    ddp_x_cost_price_rec.master_wo_flag := p5_a36;
    ddp_x_cost_price_rec.mr_session_id := p5_a37;
    ddp_x_cost_price_rec.cost_session_id := p5_a38;
    ddp_x_cost_price_rec.created_by := p5_a39;
    ddp_x_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_x_cost_price_rec.last_updated_by := p5_a41;
    ddp_x_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_x_cost_price_rec.last_update_login := p5_a43;
    ddp_x_cost_price_rec.attribute_category := p5_a44;
    ddp_x_cost_price_rec.attribute1 := p5_a45;
    ddp_x_cost_price_rec.attribute2 := p5_a46;
    ddp_x_cost_price_rec.attribute3 := p5_a47;
    ddp_x_cost_price_rec.attribute4 := p5_a48;
    ddp_x_cost_price_rec.attribute5 := p5_a49;
    ddp_x_cost_price_rec.attribute6 := p5_a50;
    ddp_x_cost_price_rec.attribute7 := p5_a51;
    ddp_x_cost_price_rec.attribute8 := p5_a52;
    ddp_x_cost_price_rec.attribute9 := p5_a53;
    ddp_x_cost_price_rec.attribute10 := p5_a54;
    ddp_x_cost_price_rec.attribute11 := p5_a55;
    ddp_x_cost_price_rec.attribute12 := p5_a56;
    ddp_x_cost_price_rec.attribute13 := p5_a57;
    ddp_x_cost_price_rec.attribute14 := p5_a58;
    ddp_x_cost_price_rec.attribute15 := p5_a59;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visit_cst_pr_pvt.estimate_visit_price(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_cost_price_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_cost_price_rec.visit_task_id;
    p5_a1 := ddp_x_cost_price_rec.visit_id;
    p5_a2 := ddp_x_cost_price_rec.mr_id;
    p5_a3 := ddp_x_cost_price_rec.actual_cost;
    p5_a4 := ddp_x_cost_price_rec.estimated_cost;
    p5_a5 := ddp_x_cost_price_rec.actual_price;
    p5_a6 := ddp_x_cost_price_rec.estimated_price;
    p5_a7 := ddp_x_cost_price_rec.currency;
    p5_a8 := ddp_x_cost_price_rec.snapshot_id;
    p5_a9 := ddp_x_cost_price_rec.object_version_number;
    p5_a10 := ddp_x_cost_price_rec.estimated_profit;
    p5_a11 := ddp_x_cost_price_rec.actual_profit;
    p5_a12 := ddp_x_cost_price_rec.outside_party_flag;
    p5_a13 := ddp_x_cost_price_rec.is_outside_pty_flag_updt;
    p5_a14 := ddp_x_cost_price_rec.is_cst_pr_info_required;
    p5_a15 := ddp_x_cost_price_rec.is_cst_struc_updated;
    p5_a16 := ddp_x_cost_price_rec.price_list_id;
    p5_a17 := ddp_x_cost_price_rec.price_list_name;
    p5_a18 := ddp_x_cost_price_rec.service_request_id;
    p5_a19 := ddp_x_cost_price_rec.customer_id;
    p5_a20 := ddp_x_cost_price_rec.organization_id;
    p5_a21 := ddp_x_cost_price_rec.visit_start_date;
    p5_a22 := ddp_x_cost_price_rec.visit_end_date;
    p5_a23 := ddp_x_cost_price_rec.mr_start_date;
    p5_a24 := ddp_x_cost_price_rec.mr_end_date;
    p5_a25 := ddp_x_cost_price_rec.task_start_date;
    p5_a26 := ddp_x_cost_price_rec.task_end_date;
    p5_a27 := ddp_x_cost_price_rec.task_name;
    p5_a28 := ddp_x_cost_price_rec.visit_task_number;
    p5_a29 := ddp_x_cost_price_rec.mr_title;
    p5_a30 := ddp_x_cost_price_rec.mr_description;
    p5_a31 := ddp_x_cost_price_rec.billing_item_id;
    p5_a32 := ddp_x_cost_price_rec.item_name;
    p5_a33 := ddp_x_cost_price_rec.item_description;
    p5_a34 := ddp_x_cost_price_rec.organization_name;
    p5_a35 := ddp_x_cost_price_rec.workorder_id;
    p5_a36 := ddp_x_cost_price_rec.master_wo_flag;
    p5_a37 := ddp_x_cost_price_rec.mr_session_id;
    p5_a38 := ddp_x_cost_price_rec.cost_session_id;
    p5_a39 := ddp_x_cost_price_rec.created_by;
    p5_a40 := ddp_x_cost_price_rec.creation_date;
    p5_a41 := ddp_x_cost_price_rec.last_updated_by;
    p5_a42 := ddp_x_cost_price_rec.last_update_date;
    p5_a43 := ddp_x_cost_price_rec.last_update_login;
    p5_a44 := ddp_x_cost_price_rec.attribute_category;
    p5_a45 := ddp_x_cost_price_rec.attribute1;
    p5_a46 := ddp_x_cost_price_rec.attribute2;
    p5_a47 := ddp_x_cost_price_rec.attribute3;
    p5_a48 := ddp_x_cost_price_rec.attribute4;
    p5_a49 := ddp_x_cost_price_rec.attribute5;
    p5_a50 := ddp_x_cost_price_rec.attribute6;
    p5_a51 := ddp_x_cost_price_rec.attribute7;
    p5_a52 := ddp_x_cost_price_rec.attribute8;
    p5_a53 := ddp_x_cost_price_rec.attribute9;
    p5_a54 := ddp_x_cost_price_rec.attribute10;
    p5_a55 := ddp_x_cost_price_rec.attribute11;
    p5_a56 := ddp_x_cost_price_rec.attribute12;
    p5_a57 := ddp_x_cost_price_rec.attribute13;
    p5_a58 := ddp_x_cost_price_rec.attribute14;
    p5_a59 := ddp_x_cost_price_rec.attribute15;



  end;

  procedure create_cost_snapshot(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_cost_price_rec.visit_task_id := p5_a0;
    ddp_x_cost_price_rec.visit_id := p5_a1;
    ddp_x_cost_price_rec.mr_id := p5_a2;
    ddp_x_cost_price_rec.actual_cost := p5_a3;
    ddp_x_cost_price_rec.estimated_cost := p5_a4;
    ddp_x_cost_price_rec.actual_price := p5_a5;
    ddp_x_cost_price_rec.estimated_price := p5_a6;
    ddp_x_cost_price_rec.currency := p5_a7;
    ddp_x_cost_price_rec.snapshot_id := p5_a8;
    ddp_x_cost_price_rec.object_version_number := p5_a9;
    ddp_x_cost_price_rec.estimated_profit := p5_a10;
    ddp_x_cost_price_rec.actual_profit := p5_a11;
    ddp_x_cost_price_rec.outside_party_flag := p5_a12;
    ddp_x_cost_price_rec.is_outside_pty_flag_updt := p5_a13;
    ddp_x_cost_price_rec.is_cst_pr_info_required := p5_a14;
    ddp_x_cost_price_rec.is_cst_struc_updated := p5_a15;
    ddp_x_cost_price_rec.price_list_id := p5_a16;
    ddp_x_cost_price_rec.price_list_name := p5_a17;
    ddp_x_cost_price_rec.service_request_id := p5_a18;
    ddp_x_cost_price_rec.customer_id := p5_a19;
    ddp_x_cost_price_rec.organization_id := p5_a20;
    ddp_x_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_x_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_x_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_x_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_x_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_x_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_x_cost_price_rec.task_name := p5_a27;
    ddp_x_cost_price_rec.visit_task_number := p5_a28;
    ddp_x_cost_price_rec.mr_title := p5_a29;
    ddp_x_cost_price_rec.mr_description := p5_a30;
    ddp_x_cost_price_rec.billing_item_id := p5_a31;
    ddp_x_cost_price_rec.item_name := p5_a32;
    ddp_x_cost_price_rec.item_description := p5_a33;
    ddp_x_cost_price_rec.organization_name := p5_a34;
    ddp_x_cost_price_rec.workorder_id := p5_a35;
    ddp_x_cost_price_rec.master_wo_flag := p5_a36;
    ddp_x_cost_price_rec.mr_session_id := p5_a37;
    ddp_x_cost_price_rec.cost_session_id := p5_a38;
    ddp_x_cost_price_rec.created_by := p5_a39;
    ddp_x_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_x_cost_price_rec.last_updated_by := p5_a41;
    ddp_x_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_x_cost_price_rec.last_update_login := p5_a43;
    ddp_x_cost_price_rec.attribute_category := p5_a44;
    ddp_x_cost_price_rec.attribute1 := p5_a45;
    ddp_x_cost_price_rec.attribute2 := p5_a46;
    ddp_x_cost_price_rec.attribute3 := p5_a47;
    ddp_x_cost_price_rec.attribute4 := p5_a48;
    ddp_x_cost_price_rec.attribute5 := p5_a49;
    ddp_x_cost_price_rec.attribute6 := p5_a50;
    ddp_x_cost_price_rec.attribute7 := p5_a51;
    ddp_x_cost_price_rec.attribute8 := p5_a52;
    ddp_x_cost_price_rec.attribute9 := p5_a53;
    ddp_x_cost_price_rec.attribute10 := p5_a54;
    ddp_x_cost_price_rec.attribute11 := p5_a55;
    ddp_x_cost_price_rec.attribute12 := p5_a56;
    ddp_x_cost_price_rec.attribute13 := p5_a57;
    ddp_x_cost_price_rec.attribute14 := p5_a58;
    ddp_x_cost_price_rec.attribute15 := p5_a59;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visit_cst_pr_pvt.create_cost_snapshot(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_cost_price_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_cost_price_rec.visit_task_id;
    p5_a1 := ddp_x_cost_price_rec.visit_id;
    p5_a2 := ddp_x_cost_price_rec.mr_id;
    p5_a3 := ddp_x_cost_price_rec.actual_cost;
    p5_a4 := ddp_x_cost_price_rec.estimated_cost;
    p5_a5 := ddp_x_cost_price_rec.actual_price;
    p5_a6 := ddp_x_cost_price_rec.estimated_price;
    p5_a7 := ddp_x_cost_price_rec.currency;
    p5_a8 := ddp_x_cost_price_rec.snapshot_id;
    p5_a9 := ddp_x_cost_price_rec.object_version_number;
    p5_a10 := ddp_x_cost_price_rec.estimated_profit;
    p5_a11 := ddp_x_cost_price_rec.actual_profit;
    p5_a12 := ddp_x_cost_price_rec.outside_party_flag;
    p5_a13 := ddp_x_cost_price_rec.is_outside_pty_flag_updt;
    p5_a14 := ddp_x_cost_price_rec.is_cst_pr_info_required;
    p5_a15 := ddp_x_cost_price_rec.is_cst_struc_updated;
    p5_a16 := ddp_x_cost_price_rec.price_list_id;
    p5_a17 := ddp_x_cost_price_rec.price_list_name;
    p5_a18 := ddp_x_cost_price_rec.service_request_id;
    p5_a19 := ddp_x_cost_price_rec.customer_id;
    p5_a20 := ddp_x_cost_price_rec.organization_id;
    p5_a21 := ddp_x_cost_price_rec.visit_start_date;
    p5_a22 := ddp_x_cost_price_rec.visit_end_date;
    p5_a23 := ddp_x_cost_price_rec.mr_start_date;
    p5_a24 := ddp_x_cost_price_rec.mr_end_date;
    p5_a25 := ddp_x_cost_price_rec.task_start_date;
    p5_a26 := ddp_x_cost_price_rec.task_end_date;
    p5_a27 := ddp_x_cost_price_rec.task_name;
    p5_a28 := ddp_x_cost_price_rec.visit_task_number;
    p5_a29 := ddp_x_cost_price_rec.mr_title;
    p5_a30 := ddp_x_cost_price_rec.mr_description;
    p5_a31 := ddp_x_cost_price_rec.billing_item_id;
    p5_a32 := ddp_x_cost_price_rec.item_name;
    p5_a33 := ddp_x_cost_price_rec.item_description;
    p5_a34 := ddp_x_cost_price_rec.organization_name;
    p5_a35 := ddp_x_cost_price_rec.workorder_id;
    p5_a36 := ddp_x_cost_price_rec.master_wo_flag;
    p5_a37 := ddp_x_cost_price_rec.mr_session_id;
    p5_a38 := ddp_x_cost_price_rec.cost_session_id;
    p5_a39 := ddp_x_cost_price_rec.created_by;
    p5_a40 := ddp_x_cost_price_rec.creation_date;
    p5_a41 := ddp_x_cost_price_rec.last_updated_by;
    p5_a42 := ddp_x_cost_price_rec.last_update_date;
    p5_a43 := ddp_x_cost_price_rec.last_update_login;
    p5_a44 := ddp_x_cost_price_rec.attribute_category;
    p5_a45 := ddp_x_cost_price_rec.attribute1;
    p5_a46 := ddp_x_cost_price_rec.attribute2;
    p5_a47 := ddp_x_cost_price_rec.attribute3;
    p5_a48 := ddp_x_cost_price_rec.attribute4;
    p5_a49 := ddp_x_cost_price_rec.attribute5;
    p5_a50 := ddp_x_cost_price_rec.attribute6;
    p5_a51 := ddp_x_cost_price_rec.attribute7;
    p5_a52 := ddp_x_cost_price_rec.attribute8;
    p5_a53 := ddp_x_cost_price_rec.attribute9;
    p5_a54 := ddp_x_cost_price_rec.attribute10;
    p5_a55 := ddp_x_cost_price_rec.attribute11;
    p5_a56 := ddp_x_cost_price_rec.attribute12;
    p5_a57 := ddp_x_cost_price_rec.attribute13;
    p5_a58 := ddp_x_cost_price_rec.attribute14;
    p5_a59 := ddp_x_cost_price_rec.attribute15;



  end;

  procedure update_visit_cost_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_cost_price_rec.visit_task_id := p5_a0;
    ddp_x_cost_price_rec.visit_id := p5_a1;
    ddp_x_cost_price_rec.mr_id := p5_a2;
    ddp_x_cost_price_rec.actual_cost := p5_a3;
    ddp_x_cost_price_rec.estimated_cost := p5_a4;
    ddp_x_cost_price_rec.actual_price := p5_a5;
    ddp_x_cost_price_rec.estimated_price := p5_a6;
    ddp_x_cost_price_rec.currency := p5_a7;
    ddp_x_cost_price_rec.snapshot_id := p5_a8;
    ddp_x_cost_price_rec.object_version_number := p5_a9;
    ddp_x_cost_price_rec.estimated_profit := p5_a10;
    ddp_x_cost_price_rec.actual_profit := p5_a11;
    ddp_x_cost_price_rec.outside_party_flag := p5_a12;
    ddp_x_cost_price_rec.is_outside_pty_flag_updt := p5_a13;
    ddp_x_cost_price_rec.is_cst_pr_info_required := p5_a14;
    ddp_x_cost_price_rec.is_cst_struc_updated := p5_a15;
    ddp_x_cost_price_rec.price_list_id := p5_a16;
    ddp_x_cost_price_rec.price_list_name := p5_a17;
    ddp_x_cost_price_rec.service_request_id := p5_a18;
    ddp_x_cost_price_rec.customer_id := p5_a19;
    ddp_x_cost_price_rec.organization_id := p5_a20;
    ddp_x_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_x_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_x_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_x_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_x_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_x_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_x_cost_price_rec.task_name := p5_a27;
    ddp_x_cost_price_rec.visit_task_number := p5_a28;
    ddp_x_cost_price_rec.mr_title := p5_a29;
    ddp_x_cost_price_rec.mr_description := p5_a30;
    ddp_x_cost_price_rec.billing_item_id := p5_a31;
    ddp_x_cost_price_rec.item_name := p5_a32;
    ddp_x_cost_price_rec.item_description := p5_a33;
    ddp_x_cost_price_rec.organization_name := p5_a34;
    ddp_x_cost_price_rec.workorder_id := p5_a35;
    ddp_x_cost_price_rec.master_wo_flag := p5_a36;
    ddp_x_cost_price_rec.mr_session_id := p5_a37;
    ddp_x_cost_price_rec.cost_session_id := p5_a38;
    ddp_x_cost_price_rec.created_by := p5_a39;
    ddp_x_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_x_cost_price_rec.last_updated_by := p5_a41;
    ddp_x_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_x_cost_price_rec.last_update_login := p5_a43;
    ddp_x_cost_price_rec.attribute_category := p5_a44;
    ddp_x_cost_price_rec.attribute1 := p5_a45;
    ddp_x_cost_price_rec.attribute2 := p5_a46;
    ddp_x_cost_price_rec.attribute3 := p5_a47;
    ddp_x_cost_price_rec.attribute4 := p5_a48;
    ddp_x_cost_price_rec.attribute5 := p5_a49;
    ddp_x_cost_price_rec.attribute6 := p5_a50;
    ddp_x_cost_price_rec.attribute7 := p5_a51;
    ddp_x_cost_price_rec.attribute8 := p5_a52;
    ddp_x_cost_price_rec.attribute9 := p5_a53;
    ddp_x_cost_price_rec.attribute10 := p5_a54;
    ddp_x_cost_price_rec.attribute11 := p5_a55;
    ddp_x_cost_price_rec.attribute12 := p5_a56;
    ddp_x_cost_price_rec.attribute13 := p5_a57;
    ddp_x_cost_price_rec.attribute14 := p5_a58;
    ddp_x_cost_price_rec.attribute15 := p5_a59;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visit_cst_pr_pvt.update_visit_cost_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_cost_price_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_cost_price_rec.visit_task_id;
    p5_a1 := ddp_x_cost_price_rec.visit_id;
    p5_a2 := ddp_x_cost_price_rec.mr_id;
    p5_a3 := ddp_x_cost_price_rec.actual_cost;
    p5_a4 := ddp_x_cost_price_rec.estimated_cost;
    p5_a5 := ddp_x_cost_price_rec.actual_price;
    p5_a6 := ddp_x_cost_price_rec.estimated_price;
    p5_a7 := ddp_x_cost_price_rec.currency;
    p5_a8 := ddp_x_cost_price_rec.snapshot_id;
    p5_a9 := ddp_x_cost_price_rec.object_version_number;
    p5_a10 := ddp_x_cost_price_rec.estimated_profit;
    p5_a11 := ddp_x_cost_price_rec.actual_profit;
    p5_a12 := ddp_x_cost_price_rec.outside_party_flag;
    p5_a13 := ddp_x_cost_price_rec.is_outside_pty_flag_updt;
    p5_a14 := ddp_x_cost_price_rec.is_cst_pr_info_required;
    p5_a15 := ddp_x_cost_price_rec.is_cst_struc_updated;
    p5_a16 := ddp_x_cost_price_rec.price_list_id;
    p5_a17 := ddp_x_cost_price_rec.price_list_name;
    p5_a18 := ddp_x_cost_price_rec.service_request_id;
    p5_a19 := ddp_x_cost_price_rec.customer_id;
    p5_a20 := ddp_x_cost_price_rec.organization_id;
    p5_a21 := ddp_x_cost_price_rec.visit_start_date;
    p5_a22 := ddp_x_cost_price_rec.visit_end_date;
    p5_a23 := ddp_x_cost_price_rec.mr_start_date;
    p5_a24 := ddp_x_cost_price_rec.mr_end_date;
    p5_a25 := ddp_x_cost_price_rec.task_start_date;
    p5_a26 := ddp_x_cost_price_rec.task_end_date;
    p5_a27 := ddp_x_cost_price_rec.task_name;
    p5_a28 := ddp_x_cost_price_rec.visit_task_number;
    p5_a29 := ddp_x_cost_price_rec.mr_title;
    p5_a30 := ddp_x_cost_price_rec.mr_description;
    p5_a31 := ddp_x_cost_price_rec.billing_item_id;
    p5_a32 := ddp_x_cost_price_rec.item_name;
    p5_a33 := ddp_x_cost_price_rec.item_description;
    p5_a34 := ddp_x_cost_price_rec.organization_name;
    p5_a35 := ddp_x_cost_price_rec.workorder_id;
    p5_a36 := ddp_x_cost_price_rec.master_wo_flag;
    p5_a37 := ddp_x_cost_price_rec.mr_session_id;
    p5_a38 := ddp_x_cost_price_rec.cost_session_id;
    p5_a39 := ddp_x_cost_price_rec.created_by;
    p5_a40 := ddp_x_cost_price_rec.creation_date;
    p5_a41 := ddp_x_cost_price_rec.last_updated_by;
    p5_a42 := ddp_x_cost_price_rec.last_update_date;
    p5_a43 := ddp_x_cost_price_rec.last_update_login;
    p5_a44 := ddp_x_cost_price_rec.attribute_category;
    p5_a45 := ddp_x_cost_price_rec.attribute1;
    p5_a46 := ddp_x_cost_price_rec.attribute2;
    p5_a47 := ddp_x_cost_price_rec.attribute3;
    p5_a48 := ddp_x_cost_price_rec.attribute4;
    p5_a49 := ddp_x_cost_price_rec.attribute5;
    p5_a50 := ddp_x_cost_price_rec.attribute6;
    p5_a51 := ddp_x_cost_price_rec.attribute7;
    p5_a52 := ddp_x_cost_price_rec.attribute8;
    p5_a53 := ddp_x_cost_price_rec.attribute9;
    p5_a54 := ddp_x_cost_price_rec.attribute10;
    p5_a55 := ddp_x_cost_price_rec.attribute11;
    p5_a56 := ddp_x_cost_price_rec.attribute12;
    p5_a57 := ddp_x_cost_price_rec.attribute13;
    p5_a58 := ddp_x_cost_price_rec.attribute14;
    p5_a59 := ddp_x_cost_price_rec.attribute15;



  end;

  procedure get_visit_items_no_price(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  DATE
    , p8_a22  DATE
    , p8_a23  DATE
    , p8_a24  DATE
    , p8_a25  DATE
    , p8_a26  DATE
    , p8_a27  VARCHAR2
    , p8_a28  NUMBER
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  NUMBER
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  VARCHAR2
    , p8_a37  NUMBER
    , p8_a38  NUMBER
    , p8_a39  NUMBER
    , p8_a40  DATE
    , p8_a41  NUMBER
    , p8_a42  DATE
    , p8_a43  NUMBER
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  VARCHAR2
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  VARCHAR2
    , p8_a55  VARCHAR2
    , p8_a56  VARCHAR2
    , p8_a57  VARCHAR2
    , p8_a58  VARCHAR2
    , p8_a59  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_DATE_TABLE
    , p9_a22 out nocopy JTF_DATE_TABLE
    , p9_a23 out nocopy JTF_DATE_TABLE
    , p9_a24 out nocopy JTF_DATE_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_DATE_TABLE
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a31 out nocopy JTF_NUMBER_TABLE
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a35 out nocopy JTF_NUMBER_TABLE
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a37 out nocopy JTF_NUMBER_TABLE
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_DATE_TABLE
    , p9_a41 out nocopy JTF_NUMBER_TABLE
    , p9_a42 out nocopy JTF_DATE_TABLE
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a49 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddx_cost_price_tbl ahl_vwp_visit_cst_pr_pvt.cost_price_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_cost_price_rec.visit_task_id := p8_a0;
    ddp_cost_price_rec.visit_id := p8_a1;
    ddp_cost_price_rec.mr_id := p8_a2;
    ddp_cost_price_rec.actual_cost := p8_a3;
    ddp_cost_price_rec.estimated_cost := p8_a4;
    ddp_cost_price_rec.actual_price := p8_a5;
    ddp_cost_price_rec.estimated_price := p8_a6;
    ddp_cost_price_rec.currency := p8_a7;
    ddp_cost_price_rec.snapshot_id := p8_a8;
    ddp_cost_price_rec.object_version_number := p8_a9;
    ddp_cost_price_rec.estimated_profit := p8_a10;
    ddp_cost_price_rec.actual_profit := p8_a11;
    ddp_cost_price_rec.outside_party_flag := p8_a12;
    ddp_cost_price_rec.is_outside_pty_flag_updt := p8_a13;
    ddp_cost_price_rec.is_cst_pr_info_required := p8_a14;
    ddp_cost_price_rec.is_cst_struc_updated := p8_a15;
    ddp_cost_price_rec.price_list_id := p8_a16;
    ddp_cost_price_rec.price_list_name := p8_a17;
    ddp_cost_price_rec.service_request_id := p8_a18;
    ddp_cost_price_rec.customer_id := p8_a19;
    ddp_cost_price_rec.organization_id := p8_a20;
    ddp_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p8_a21);
    ddp_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p8_a22);
    ddp_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p8_a23);
    ddp_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p8_a24);
    ddp_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p8_a25);
    ddp_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p8_a26);
    ddp_cost_price_rec.task_name := p8_a27;
    ddp_cost_price_rec.visit_task_number := p8_a28;
    ddp_cost_price_rec.mr_title := p8_a29;
    ddp_cost_price_rec.mr_description := p8_a30;
    ddp_cost_price_rec.billing_item_id := p8_a31;
    ddp_cost_price_rec.item_name := p8_a32;
    ddp_cost_price_rec.item_description := p8_a33;
    ddp_cost_price_rec.organization_name := p8_a34;
    ddp_cost_price_rec.workorder_id := p8_a35;
    ddp_cost_price_rec.master_wo_flag := p8_a36;
    ddp_cost_price_rec.mr_session_id := p8_a37;
    ddp_cost_price_rec.cost_session_id := p8_a38;
    ddp_cost_price_rec.created_by := p8_a39;
    ddp_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p8_a40);
    ddp_cost_price_rec.last_updated_by := p8_a41;
    ddp_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a42);
    ddp_cost_price_rec.last_update_login := p8_a43;
    ddp_cost_price_rec.attribute_category := p8_a44;
    ddp_cost_price_rec.attribute1 := p8_a45;
    ddp_cost_price_rec.attribute2 := p8_a46;
    ddp_cost_price_rec.attribute3 := p8_a47;
    ddp_cost_price_rec.attribute4 := p8_a48;
    ddp_cost_price_rec.attribute5 := p8_a49;
    ddp_cost_price_rec.attribute6 := p8_a50;
    ddp_cost_price_rec.attribute7 := p8_a51;
    ddp_cost_price_rec.attribute8 := p8_a52;
    ddp_cost_price_rec.attribute9 := p8_a53;
    ddp_cost_price_rec.attribute10 := p8_a54;
    ddp_cost_price_rec.attribute11 := p8_a55;
    ddp_cost_price_rec.attribute12 := p8_a56;
    ddp_cost_price_rec.attribute13 := p8_a57;
    ddp_cost_price_rec.attribute14 := p8_a58;
    ddp_cost_price_rec.attribute15 := p8_a59;


    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_visit_cst_pr_pvt.get_visit_items_no_price(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cost_price_rec,
      ddx_cost_price_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_vwp_visit_cst_pr_pvt_w.rosetta_table_copy_out_p1(ddx_cost_price_tbl, p9_a0
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
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      );
  end;

end ahl_vwp_visit_cst_pr_pvt_w;

/
