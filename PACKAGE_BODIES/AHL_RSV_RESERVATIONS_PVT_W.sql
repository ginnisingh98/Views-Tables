--------------------------------------------------------
--  DDL for Package Body AHL_RSV_RESERVATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RSV_RESERVATIONS_PVT_W" as
  /* $Header: AHLWRSVB.pls 120.0 2005/07/01 03:22 anraj noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_rsv_reservations_pvt.serial_number_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := a0(indx);
          t(ddindx).serial_number := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_rsv_reservations_pvt.serial_number_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := t(ddindx).inventory_item_id;
          a1(indx) := t(ddindx).serial_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_reservation(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_scheduled_material_id  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_serial_number_tbl ahl_rsv_reservations_pvt.serial_number_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_rsv_reservations_pvt_w.rosetta_table_copy_in_p2(ddp_serial_number_tbl, p9_a0
      , p9_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_rsv_reservations_pvt.create_reservation(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_scheduled_material_id,
      ddp_serial_number_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end ahl_rsv_reservations_pvt_w;

/
