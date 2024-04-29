--------------------------------------------------------
--  DDL for Package Body AHL_PRD_WO_LOGIN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_WO_LOGIN_PVT_W" as
  /* $Header: AHLVLGWB.pls 120.0 2005/09/08 08:12 sracha noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_wo_login_pvt.wo_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).workorder_id := a0(indx);
          t(ddindx).is_login_allowed := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_prd_wo_login_pvt.wo_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).workorder_id;
          a1(indx) := t(ddindx).is_login_allowed;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_prd_wo_login_pvt.op_res_tbl_type, a0 JTF_NUMBER_TABLE
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
          t(ddindx).operation_seq_num := a0(indx);
          t(ddindx).resource_id := a1(indx);
          t(ddindx).is_login_allowed := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_prd_wo_login_pvt.op_res_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := t(ddindx).operation_seq_num;
          a1(indx) := t(ddindx).resource_id;
          a2(indx) := t(ddindx).is_login_allowed;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure get_wo_login_info(p_function_name  VARCHAR2
    , p_employee_id  NUMBER
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_wos ahl_prd_wo_login_pvt.wo_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ahl_prd_wo_login_pvt_w.rosetta_table_copy_in_p1(ddp_x_wos, p2_a0
      , p2_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_wo_login_pvt.get_wo_login_info(p_function_name,
      p_employee_id,
      ddp_x_wos);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    ahl_prd_wo_login_pvt_w.rosetta_table_copy_out_p1(ddp_x_wos, p2_a0
      , p2_a1
      );
  end;

  procedure get_op_res_login_info(p_workorder_id  NUMBER
    , p_employee_id  NUMBER
    , p_function_name  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
    , p3_a2 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_op_res ahl_prd_wo_login_pvt.op_res_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ahl_prd_wo_login_pvt_w.rosetta_table_copy_in_p3(ddp_x_op_res, p3_a0
      , p3_a1
      , p3_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_wo_login_pvt.get_op_res_login_info(p_workorder_id,
      p_employee_id,
      p_function_name,
      ddp_x_op_res);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    ahl_prd_wo_login_pvt_w.rosetta_table_copy_out_p3(ddp_x_op_res, p3_a0
      , p3_a1
      , p3_a2
      );
  end;

end ahl_prd_wo_login_pvt_w;

/
