--------------------------------------------------------
--  DDL for Package Body AHL_PRD_SERN_CHANGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_SERN_CHANGE_PVT_W" as
  /* $Header: AHLWSNCB.pls 120.2 2008/03/06 00:24:36 adivenka ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_sern_change_pvt.sernum_change_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).workorder_id := a0(indx);
          t(ddindx).job_number := a1(indx);
          t(ddindx).item_number := a2(indx);
          t(ddindx).new_item_number := a3(indx);
          t(ddindx).new_lot_number := a4(indx);
          t(ddindx).new_item_rev_number := a5(indx);
          t(ddindx).osp_line_id := a6(indx);
          t(ddindx).instance_id := a7(indx);
          t(ddindx).current_serial_number := a8(indx);
          t(ddindx).current_serail_tag := a9(indx);
          t(ddindx).new_serial_number := a10(indx);
          t(ddindx).new_serial_tag_code := a11(indx);
          t(ddindx).new_serial_tag_mean := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_prd_sern_change_pvt.sernum_change_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).workorder_id;
          a1(indx) := t(ddindx).job_number;
          a2(indx) := t(ddindx).item_number;
          a3(indx) := t(ddindx).new_item_number;
          a4(indx) := t(ddindx).new_lot_number;
          a5(indx) := t(ddindx).new_item_rev_number;
          a6(indx) := t(ddindx).osp_line_id;
          a7(indx) := t(ddindx).instance_id;
          a8(indx) := t(ddindx).current_serial_number;
          a9(indx) := t(ddindx).current_serail_tag;
          a10(indx) := t(ddindx).new_serial_number;
          a11(indx) := t(ddindx).new_serial_tag_code;
          a12(indx) := t(ddindx).new_serial_tag_mean;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure process_serialnum_change(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_warning_msg_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_serialnum_change_rec ahl_prd_sern_change_pvt.sernum_change_rec_type;
    ddx_warning_msg_tbl ahl_uc_validation_pub.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_serialnum_change_rec.workorder_id := p4_a0;
    ddp_serialnum_change_rec.job_number := p4_a1;
    ddp_serialnum_change_rec.item_number := p4_a2;
    ddp_serialnum_change_rec.new_item_number := p4_a3;
    ddp_serialnum_change_rec.new_lot_number := p4_a4;
    ddp_serialnum_change_rec.new_item_rev_number := p4_a5;
    ddp_serialnum_change_rec.osp_line_id := p4_a6;
    ddp_serialnum_change_rec.instance_id := p4_a7;
    ddp_serialnum_change_rec.current_serial_number := p4_a8;
    ddp_serialnum_change_rec.current_serail_tag := p4_a9;
    ddp_serialnum_change_rec.new_serial_number := p4_a10;
    ddp_serialnum_change_rec.new_serial_tag_code := p4_a11;
    ddp_serialnum_change_rec.new_serial_tag_mean := p4_a12;





    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_sern_change_pvt.process_serialnum_change(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_serialnum_change_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_warning_msg_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ahl_uc_validation_pub_w.rosetta_table_copy_out_p0(ddx_warning_msg_tbl, x_warning_msg_tbl);
  end;

end ahl_prd_sern_change_pvt_w;

/
