--------------------------------------------------------
--  DDL for Package Body EAM_COPY_BOM_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_COPY_BOM_PKG_W" as
 /* $Header: EAMCPMRB.pls 120.2 2008/01/26 01:52:22 devijay ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy eam_copy_bom_pkg.t_bom_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).component_item_id := a0(indx);
          t(ddindx).description := a1(indx);
          t(ddindx).component_quantity := a2(indx);
          t(ddindx).uom := a3(indx);
          t(ddindx).wip_supply_type := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t eam_copy_bom_pkg.t_bom_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).component_item_id;
          a1(indx) := t(ddindx).description;
          a2(indx) := t(ddindx).component_quantity;
          a3(indx) := t(ddindx).uom;
          a4(indx) := t(ddindx).wip_supply_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy eam_copy_bom_pkg.t_component_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).component_item := a0(indx);
          t(ddindx).component_item_id := a1(indx);
          t(ddindx).operation_sequence_number := a2(indx);
          t(ddindx).quantity_per_assembly := a3(indx);
          t(ddindx).wip_supply_type := a4(indx);
          t(ddindx).supply_subinventory := a5(indx);
          t(ddindx).supply_locator_id := a6(indx);
          t(ddindx).supply_locator_name := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t eam_copy_bom_pkg.t_component_table, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).component_item;
          a1(indx) := t(ddindx).component_item_id;
          a2(indx) := t(ddindx).operation_sequence_number;
          a3(indx) := t(ddindx).quantity_per_assembly;
          a4(indx) := t(ddindx).wip_supply_type;
          a5(indx) := t(ddindx).supply_subinventory;
          a6(indx) := t(ddindx).supply_locator_id;
          a7(indx) := t(ddindx).supply_locator_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure copy_to_bom(p_organization_id  NUMBER
    , p_organization_code  VARCHAR2
    , p_asset_number  VARCHAR2
    , p_asset_group_id  NUMBER
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , x_error_code out nocopy  NUMBER
  )

  as
    ddp_component_table eam_copy_bom_pkg.t_component_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    eam_copy_bom_pkg_w.rosetta_table_copy_in_p3(ddp_component_table, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );


    -- here's the delegated call to the old PL/SQL routine
    eam_copy_bom_pkg.copy_to_bom(p_organization_id,
      p_organization_code,
      p_asset_number,
      p_asset_group_id,
      ddp_component_table,
      x_error_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure retrieve_asset_bom(p_organization_id  NUMBER
    , p_wip_entity_id  NUMBER
    , p_operation_seq_num  NUMBER
    , p_department_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_300
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_NUMBER_TABLE
    , x_error_code out nocopy  VARCHAR2
  )

  as
    ddp_bom_table eam_copy_bom_pkg.t_bom_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    eam_copy_bom_pkg_w.rosetta_table_copy_in_p2(ddp_bom_table, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      );


    -- here's the delegated call to the old PL/SQL routine
    eam_copy_bom_pkg.retrieve_asset_bom(p_organization_id,
      p_wip_entity_id,
      p_operation_seq_num,
      p_department_id,
      ddp_bom_table,
      x_error_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end eam_copy_bom_pkg_w;

/
