--------------------------------------------------------
--  DDL for Package Body AHL_LTP_RESRC_LEVL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_RESRC_LEVL_PUB_W" as
  /* $Header: AHLWRLGB.pls 120.2 2006/05/04 07:41 anraj noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_ltp_resrc_levl_pub.aval_resources_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).period_string := a0(indx);
          t(ddindx).period_start := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).period_end := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).required_capacity := a3(indx);
          t(ddindx).dept_name := a4(indx);
          t(ddindx).resource_id := a5(indx);
          t(ddindx).resource_type := a6(indx);
          t(ddindx).resource_type_meaning := a7(indx);
          t(ddindx).resource_name := a8(indx);
          t(ddindx).resource_description := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_ltp_resrc_levl_pub.aval_resources_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).period_string;
          a1(indx) := t(ddindx).period_start;
          a2(indx) := t(ddindx).period_end;
          a3(indx) := t(ddindx).required_capacity;
          a4(indx) := t(ddindx).dept_name;
          a5(indx) := t(ddindx).resource_id;
          a6(indx) := t(ddindx).resource_type;
          a7(indx) := t(ddindx).resource_type_meaning;
          a8(indx) := t(ddindx).resource_name;
          a9(indx) := t(ddindx).resource_description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_ltp_resrc_levl_pub.resource_con_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).visit_id := a0(indx);
          t(ddindx).task_id := a1(indx);
          t(ddindx).visit_name := a2(indx);
          t(ddindx).visit_task_name := a3(indx);
          t(ddindx).task_type_code := a4(indx);
          t(ddindx).dept_name := a5(indx);
          t(ddindx).quantity := a6(indx);
          t(ddindx).required_units := a7(indx);
          t(ddindx).available_units := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_ltp_resrc_levl_pub.resource_con_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).visit_id;
          a1(indx) := t(ddindx).task_id;
          a2(indx) := t(ddindx).visit_name;
          a3(indx) := t(ddindx).visit_task_name;
          a4(indx) := t(ddindx).task_type_code;
          a5(indx) := t(ddindx).dept_name;
          a6(indx) := t(ddindx).quantity;
          a7(indx) := t(ddindx).required_units;
          a8(indx) := t(ddindx).available_units;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure derive_resource_capacity(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  DATE
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_DATE_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_req_resources ahl_ltp_resrc_levl_pub.req_resources_rec;
    ddx_aval_resources_tbl ahl_ltp_resrc_levl_pub.aval_resources_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_req_resources.org_name := p5_a0;
    ddp_req_resources.dept_name := p5_a1;
    ddp_req_resources.dept_id := p5_a2;
    ddp_req_resources.plan_id := p5_a3;
    ddp_req_resources.start_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_req_resources.end_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_req_resources.display_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_req_resources.display_end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_req_resources.uom_code := p5_a8;
    ddp_req_resources.required_capacity := p5_a9;
    ddp_req_resources.resource_id := p5_a10;
    ddp_req_resources.resource_type := p5_a11;
    ddp_req_resources.aso_bom_type := p5_a12;
    ddp_req_resources.resource_type_meaning := p5_a13;





    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_resrc_levl_pub.derive_resource_capacity(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_req_resources,
      ddx_aval_resources_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_ltp_resrc_levl_pub_w.rosetta_table_copy_out_p3(ddx_aval_resources_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );



  end;

  procedure derive_resource_consum(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  DATE
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_req_resources ahl_ltp_resrc_levl_pub.req_resources_rec;
    ddx_resource_con_tbl ahl_ltp_resrc_levl_pub.resource_con_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_req_resources.org_name := p5_a0;
    ddp_req_resources.dept_name := p5_a1;
    ddp_req_resources.dept_id := p5_a2;
    ddp_req_resources.plan_id := p5_a3;
    ddp_req_resources.start_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_req_resources.end_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_req_resources.display_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_req_resources.display_end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_req_resources.uom_code := p5_a8;
    ddp_req_resources.required_capacity := p5_a9;
    ddp_req_resources.resource_id := p5_a10;
    ddp_req_resources.resource_type := p5_a11;
    ddp_req_resources.aso_bom_type := p5_a12;
    ddp_req_resources.resource_type_meaning := p5_a13;





    -- here's the delegated call to the old PL/SQL routine
    ahl_ltp_resrc_levl_pub.derive_resource_consum(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_req_resources,
      ddx_resource_con_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_ltp_resrc_levl_pub_w.rosetta_table_copy_out_p4(ddx_resource_con_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );



  end;

end ahl_ltp_resrc_levl_pub_w;

/
