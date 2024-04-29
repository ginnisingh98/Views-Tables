--------------------------------------------------------
--  DDL for Package Body EAM_WORKORDER_UTIL_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKORDER_UTIL_PKG_W" as
  /* $Header: EAMVWUPB.pls 120.0 2005/06/08 02:51:21 appldev noship $ eam_workorder_util_pkg_w.pkb 115.0 2005/05/23 07:08:38 grajan noship $*/

  procedure rosetta_table_copy_in_p7(t out nocopy eam_workorder_util_pkg.t_workflow_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).seq_no := a0(indx);
          t(ddindx).approver := a1(indx);
          t(ddindx).status := a2(indx);
          t(ddindx).status_date := a3(indx);
          t(ddindx).email := a4(indx);
          t(ddindx).telephone := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;

  procedure rosetta_table_copy_out_p7(t eam_workorder_util_pkg.t_workflow_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_400();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_400();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).seq_no;
          a1(indx) := t(ddindx).approver;
          a2(indx) := t(ddindx).status;
          a3(indx) := t(ddindx).status_date;
          a4(indx) := t(ddindx).email;
          a5(indx) := t(ddindx).telephone;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure get_workflow_details(p_item_type  String
    , p_item_key  String
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_workflow_table eam_workorder_util_pkg.t_workflow_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    eam_workorder_util_pkg.get_workflow_details(p_item_type,
      p_item_key,
      ddx_workflow_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    eam_workorder_util_pkg_w.rosetta_table_copy_out_p7(ddx_workflow_table, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      );
  end;

end eam_workorder_util_pkg_w;

/
