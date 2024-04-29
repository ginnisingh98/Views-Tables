--------------------------------------------------------
--  DDL for Package Body INV_OA_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_OA_GEN_PVT" as
  /* $Header: INVOAGEB.pls 120.0 2005/06/28 16:26 jxlu noship $ */

  PROCEDURE BUILD_ASSEMBLY_LOT_SERIAL_TBL(
      x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_assembly_lot_serial_tbl assembly_lot_sel_tbl_type
  ) is
  begin
             /*-- Bulk insert the lot and serial records records
              FORALL i IN 1 .. p_assembly_lot_serial_tbl.COUNT
                INSERT INTO MTL_ALLOCATIONS_GTMP
                (Lot_number,
                 serial_number)
                 VALUES
                 (p_assembly_lot_serial_tbl(i).lot_number,
                  p_assembly_lot_serial_tbl(i).serial_number);  */

        DELETE MTL_ALLOCATIONS_GTMP;

        FOR i IN 1 .. p_assembly_lot_serial_tbl.COUNT LOOP
	      INSERT INTO MTL_ALLOCATIONS_GTMP
	      (Lot_number,
	       serial_number)
	       VALUES
	       (p_assembly_lot_serial_tbl(i).lot_number,
                p_assembly_lot_serial_tbl(i).serial_number);
        END LOOP;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy inv_oa_gen_pvt.assembly_lot_sel_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lot_number := a0(indx);
          t(ddindx).serial_number := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t inv_oa_gen_pvt.assembly_lot_sel_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).lot_number;
          a1(indx) := t(ddindx).serial_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure build_assembly_lot_serial_tbl(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_assembly_lot_serial_tbl inv_oa_gen_pvt.assembly_lot_sel_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    rosetta_table_copy_in_p1(ddp_assembly_lot_serial_tbl, p3_a0
      , p3_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    inv_oa_gen_pvt.build_assembly_lot_serial_tbl(x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_assembly_lot_serial_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;


end INV_OA_GEN_PVT;

/
