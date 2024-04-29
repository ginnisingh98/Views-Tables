--------------------------------------------------------
--  DDL for Package Body AHL_UA_FLIGHT_SCHEDULES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UA_FLIGHT_SCHEDULES_PUB_W" as
  /* $Header: AHLUFSWB.pls 120.0 2005/05/26 00:59:51 appldev noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_ua_flight_schedules_pub.flight_visit_sch_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
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
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
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
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).unit_schedule_id := a0(indx);
          t(ddindx).flight_number := a1(indx);
          t(ddindx).segment := a2(indx);
          t(ddindx).est_departure_time := a3(indx);
          t(ddindx).actual_departure_time := a4(indx);
          t(ddindx).departure_dept_id := a5(indx);
          t(ddindx).departure_dept_code := a6(indx);
          t(ddindx).departure_org_id := a7(indx);
          t(ddindx).departure_org_code := a8(indx);
          t(ddindx).est_arrival_time := a9(indx);
          t(ddindx).actual_arrival_time := a10(indx);
          t(ddindx).arrival_dept_id := a11(indx);
          t(ddindx).arrival_dept_code := a12(indx);
          t(ddindx).arrival_org_id := a13(indx);
          t(ddindx).arrival_org_code := a14(indx);
          t(ddindx).preceding_us_id := a15(indx);
          t(ddindx).unit_config_header_id := a16(indx);
          t(ddindx).unit_config_name := a17(indx);
          t(ddindx).csi_instance_id := a18(indx);
          t(ddindx).instance_number := a19(indx);
          t(ddindx).item_number := a20(indx);
          t(ddindx).serial_number := a21(indx);
          t(ddindx).visit_reschedule_mode := a22(indx);
          t(ddindx).visit_reschedule_meaning := a23(indx);
          t(ddindx).object_version_number := a24(indx);
          t(ddindx).is_update_allowed := a25(indx);
          t(ddindx).is_delete_allowed := a26(indx);
          t(ddindx).visit_id := a27(indx);
          t(ddindx).visit_type_code := a28(indx);
          t(ddindx).visit_type_meaning := a29(indx);
          t(ddindx).visit_create_type := a30(indx);
          t(ddindx).visit_create_meaning := a31(indx);
          t(ddindx).attribute_category := a32(indx);
          t(ddindx).attribute1 := a33(indx);
          t(ddindx).attribute2 := a34(indx);
          t(ddindx).attribute3 := a35(indx);
          t(ddindx).attribute4 := a36(indx);
          t(ddindx).attribute5 := a37(indx);
          t(ddindx).attribute6 := a38(indx);
          t(ddindx).attribute7 := a39(indx);
          t(ddindx).attribute8 := a40(indx);
          t(ddindx).attribute9 := a41(indx);
          t(ddindx).attribute10 := a42(indx);
          t(ddindx).attribute11 := a43(indx);
          t(ddindx).attribute12 := a44(indx);
          t(ddindx).attribute13 := a45(indx);
          t(ddindx).attribute14 := a46(indx);
          t(ddindx).attribute15 := a47(indx);
          t(ddindx).dml_operation := a48(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_ua_flight_schedules_pub.flight_visit_sch_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
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
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
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
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
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
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
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
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
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
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).unit_schedule_id;
          a1(indx) := t(ddindx).flight_number;
          a2(indx) := t(ddindx).segment;
          a3(indx) := t(ddindx).est_departure_time;
          a4(indx) := t(ddindx).actual_departure_time;
          a5(indx) := t(ddindx).departure_dept_id;
          a6(indx) := t(ddindx).departure_dept_code;
          a7(indx) := t(ddindx).departure_org_id;
          a8(indx) := t(ddindx).departure_org_code;
          a9(indx) := t(ddindx).est_arrival_time;
          a10(indx) := t(ddindx).actual_arrival_time;
          a11(indx) := t(ddindx).arrival_dept_id;
          a12(indx) := t(ddindx).arrival_dept_code;
          a13(indx) := t(ddindx).arrival_org_id;
          a14(indx) := t(ddindx).arrival_org_code;
          a15(indx) := t(ddindx).preceding_us_id;
          a16(indx) := t(ddindx).unit_config_header_id;
          a17(indx) := t(ddindx).unit_config_name;
          a18(indx) := t(ddindx).csi_instance_id;
          a19(indx) := t(ddindx).instance_number;
          a20(indx) := t(ddindx).item_number;
          a21(indx) := t(ddindx).serial_number;
          a22(indx) := t(ddindx).visit_reschedule_mode;
          a23(indx) := t(ddindx).visit_reschedule_meaning;
          a24(indx) := t(ddindx).object_version_number;
          a25(indx) := t(ddindx).is_update_allowed;
          a26(indx) := t(ddindx).is_delete_allowed;
          a27(indx) := t(ddindx).visit_id;
          a28(indx) := t(ddindx).visit_type_code;
          a29(indx) := t(ddindx).visit_type_meaning;
          a30(indx) := t(ddindx).visit_create_type;
          a31(indx) := t(ddindx).visit_create_meaning;
          a32(indx) := t(ddindx).attribute_category;
          a33(indx) := t(ddindx).attribute1;
          a34(indx) := t(ddindx).attribute2;
          a35(indx) := t(ddindx).attribute3;
          a36(indx) := t(ddindx).attribute4;
          a37(indx) := t(ddindx).attribute5;
          a38(indx) := t(ddindx).attribute6;
          a39(indx) := t(ddindx).attribute7;
          a40(indx) := t(ddindx).attribute8;
          a41(indx) := t(ddindx).attribute9;
          a42(indx) := t(ddindx).attribute10;
          a43(indx) := t(ddindx).attribute11;
          a44(indx) := t(ddindx).attribute12;
          a45(indx) := t(ddindx).attribute13;
          a46(indx) := t(ddindx).attribute14;
          a47(indx) := t(ddindx).attribute15;
          a48(indx) := t(ddindx).dml_operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure get_flight_schedule_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  DATE
    , p9_a10  DATE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_DATE_TABLE
    , p10_a4 out nocopy JTF_DATE_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_DATE_TABLE
    , p10_a10 out nocopy JTF_DATE_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_NUMBER_TABLE
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_NUMBER_TABLE
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_flight_search_rec ahl_ua_flight_schedules_pub.flight_search_rec_type;
    ddx_flight_schedules_tbl ahl_ua_flight_schedules_pvt.flight_schedules_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_flight_search_rec.unit_schedule_id := p9_a0;
    ddp_flight_search_rec.unit_name := p9_a1;
    ddp_flight_search_rec.flight_number := p9_a2;
    ddp_flight_search_rec.item_number := p9_a3;
    ddp_flight_search_rec.serial_number := p9_a4;
    ddp_flight_search_rec.arrival_org_code := p9_a5;
    ddp_flight_search_rec.arrival_dept_code := p9_a6;
    ddp_flight_search_rec.departure_org_code := p9_a7;
    ddp_flight_search_rec.departure_dept_code := p9_a8;
    ddp_flight_search_rec.start_date := p9_a9;
    ddp_flight_search_rec.end_date := p9_a10;


    -- here's the delegated call to the old PL/SQL routine
    ahl_ua_flight_schedules_pub.get_flight_schedule_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_flight_search_rec,
      ddx_flight_schedules_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    ahl_ua_flight_schedules_pvt_w.rosetta_table_copy_out_p1(ddx_flight_schedules_tbl, p10_a0
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
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      );
  end;

  procedure process_flight_schedules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_DATE_TABLE
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_DATE_TABLE
    , p9_a10 in out nocopy JTF_DATE_TABLE
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 in out nocopy JTF_NUMBER_TABLE
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 in out nocopy JTF_NUMBER_TABLE
    , p9_a16 in out nocopy JTF_NUMBER_TABLE
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 in out nocopy JTF_NUMBER_TABLE
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a24 in out nocopy JTF_NUMBER_TABLE
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a27 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a44 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_flight_schedules_tbl ahl_ua_flight_schedules_pvt.flight_schedules_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_ua_flight_schedules_pvt_w.rosetta_table_copy_in_p1(ddp_x_flight_schedules_tbl, p9_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_ua_flight_schedules_pub.process_flight_schedules(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_flight_schedules_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_ua_flight_schedules_pvt_w.rosetta_table_copy_out_p1(ddp_x_flight_schedules_tbl, p9_a0
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
      );
  end;

  procedure process_flightvisit_sch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_DATE_TABLE
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_DATE_TABLE
    , p9_a10 in out nocopy JTF_DATE_TABLE
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 in out nocopy JTF_NUMBER_TABLE
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 in out nocopy JTF_NUMBER_TABLE
    , p9_a16 in out nocopy JTF_NUMBER_TABLE
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 in out nocopy JTF_NUMBER_TABLE
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a24 in out nocopy JTF_NUMBER_TABLE
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p9_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a48 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_flight_visit_sch_tbl ahl_ua_flight_schedules_pub.flight_visit_sch_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_ua_flight_schedules_pub_w.rosetta_table_copy_in_p2(ddp_x_flight_visit_sch_tbl, p9_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_ua_flight_schedules_pub.process_flightvisit_sch(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_flight_visit_sch_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_ua_flight_schedules_pub_w.rosetta_table_copy_out_p2(ddp_x_flight_visit_sch_tbl, p9_a0
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
      );
  end;

end ahl_ua_flight_schedules_pub_w;

/
