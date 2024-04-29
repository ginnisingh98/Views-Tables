--------------------------------------------------------
--  DDL for Package Body AHL_PRD_PRINT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_PRINT_PVT_W" as
  /* $Header: AHLWPPRB.pls 120.0 2005/07/05 00:10 bachandr noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p0(t out nocopy ahl_prd_print_pvt.workorder_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
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
  procedure rosetta_table_copy_out_p0(t ahl_prd_print_pvt.workorder_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
  end rosetta_table_copy_out_p0;

  procedure gen_wo_xml(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_workorders_tbl JTF_NUMBER_TABLE
    , p_employee_id  NUMBER
    , p_user_role  VARCHAR2
    , p_material_req_flag  VARCHAR2
    , x_xml_data out nocopy  CLOB
    , p_concurrent_flag  VARCHAR2
  )

  as
    ddp_workorders_tbl ahl_prd_print_pvt.workorder_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_prd_print_pvt_w.rosetta_table_copy_in_p0(ddp_workorders_tbl, p_workorders_tbl);






    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_print_pvt.gen_wo_xml(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_workorders_tbl,
      p_employee_id,
      p_user_role,
      p_material_req_flag,
      x_xml_data,
      p_concurrent_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

end ahl_prd_print_pvt_w;

/
